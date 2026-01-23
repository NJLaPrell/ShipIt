#!/bin/bash

# Deployment Script
# Runs readiness checks and prepares deployment steps

set -euo pipefail

error_exit() {
    echo "ERROR: $1" >&2
    exit "${2:-1}"
}

ENVIRONMENT="${1:-}"
if [ -z "$ENVIRONMENT" ]; then
    error_exit "Usage: ./scripts/deploy.sh <environment>" 1
fi

if [ ! -x "./scripts/check-readiness.sh" ]; then
    error_exit "Missing readiness script: scripts/check-readiness.sh" 1
fi

echo "Running readiness checks for environment: $ENVIRONMENT"
./scripts/check-readiness.sh "$ENVIRONMENT"

echo "Readiness checks complete. Deployment is not executed by this script."
#!/bin/bash

# Deployment Script
# Handles deployment to various platforms

set -euo pipefail

error_exit() {
    echo "ERROR: $1" >&2
    exit "${2:-1}"
}

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ENVIRONMENT="${1:-production}"
PLATFORM="${2:-}"

echo -e "${BLUE}Deploying to $ENVIRONMENT...${NC}"
echo ""

# Check prerequisites
if [ ! -f "project.json" ]; then
    error_exit "project.json not found. Run /init-project first." 1
fi

# Run readiness checks
echo -e "${YELLOW}Running readiness checks...${NC}"
if [ -f "scripts/check-readiness.sh" ]; then
    if ! ./scripts/check-readiness.sh; then
        error_exit "Readiness checks failed. Fix issues before deploying." 1
    fi
else
    warning "check-readiness.sh not found, skipping checks"
fi
echo ""

# Determine platform
if [ -z "$PLATFORM" ]; then
    if [ -f "vercel.json" ] || [ -f ".vercel/project.json" ]; then
        PLATFORM="vercel"
    elif [ -f "netlify.toml" ]; then
        PLATFORM="netlify"
    elif [ -f "Dockerfile" ]; then
        PLATFORM="docker"
    elif [ -d "infrastructure" ] && [ -f "infrastructure/cdk.json" ]; then
        PLATFORM="aws-cdk"
    else
        echo -e "${YELLOW}Platform not detected. Available options:${NC}"
        echo "1) Vercel"
        echo "2) Netlify"
        echo "3) Docker"
        echo "4) AWS CDK"
        echo "5) Manual (no automation)"
        read -p "Select platform [1-5]: " platform_choice
        
        case $platform_choice in
            1) PLATFORM="vercel" ;;
            2) PLATFORM="netlify" ;;
            3) PLATFORM="docker" ;;
            4) PLATFORM="aws-cdk" ;;
            5) PLATFORM="manual" ;;
            *) PLATFORM="manual" ;;
        esac
    fi
fi

echo -e "${GREEN}Platform: $PLATFORM${NC}"
echo ""

# Create deployment history
DEPLOY_HISTORY="deployment-history.md"
if [ ! -f "$DEPLOY_HISTORY" ]; then
    cat > "$DEPLOY_HISTORY" << EOF
# Deployment History

## Deployments

EOF
fi

# Deploy based on platform
case $PLATFORM in
    vercel)
        echo -e "${YELLOW}Deploying to Vercel...${NC}"
        if command -v vercel >/dev/null 2>&1; then
            vercel --prod
        else
            error_exit "Vercel CLI not found. Install with: npm i -g vercel" 1
        fi
        ;;
    
    netlify)
        echo -e "${YELLOW}Deploying to Netlify...${NC}"
        if command -v netlify >/dev/null 2>&1; then
            netlify deploy --prod
        else
            error_exit "Netlify CLI not found. Install with: npm i -g netlify-cli" 1
        fi
        ;;
    
    docker)
        echo -e "${YELLOW}Building and deploying Docker image...${NC}"
        if [ ! -f "Dockerfile" ]; then
            error_exit "Dockerfile not found" 1
        fi
        IMAGE_NAME=$(jq -r '.name' project.json | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
        docker build -t "$IMAGE_NAME:latest" .
        echo -e "${GREEN}✓ Docker image built: $IMAGE_NAME:latest${NC}"
        echo -e "${YELLOW}Note: Push and deploy manually or configure registry${NC}"
        ;;
    
    aws-cdk)
        echo -e "${YELLOW}Deploying with AWS CDK...${NC}"
        if [ ! -d "infrastructure" ]; then
            error_exit "infrastructure directory not found" 1
        fi
        cd infrastructure || error_exit "Failed to enter infrastructure directory" 1
        if command -v cdk >/dev/null 2>&1; then
            cdk deploy --require-approval never
        else
            error_exit "AWS CDK CLI not found. Install with: npm i -g aws-cdk" 1
        fi
        cd ..
        ;;
    
    manual)
        echo -e "${YELLOW}Manual deployment mode${NC}"
        echo "Readiness checks passed. Deploy manually using your preferred method."
        echo ""
        echo "Suggested steps:"
        echo "1. Build: pnpm build (or equivalent)"
        echo "2. Test: pnpm test"
        echo "3. Deploy using your platform's method"
        ;;
    
    *)
        error_exit "Unknown platform: $PLATFORM" 1
        ;;
esac

# Record deployment
DEPLOY_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
cat >> "$DEPLOY_HISTORY" << EOF
### $DEPLOY_TIME - $ENVIRONMENT ($PLATFORM)
- Environment: $ENVIRONMENT
- Platform: $PLATFORM
- Status: deployed
- Readiness checks: passed

EOF

echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Deployment complete${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Verify deployment is healthy"
echo "2. Run smoke tests"
echo "3. Monitor logs and metrics"
echo ""
