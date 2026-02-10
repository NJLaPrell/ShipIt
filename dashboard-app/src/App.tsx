import { useState, useEffect } from 'react';
import './App.css';

interface DashboardData {
  generated: string;
  projectName: string;
  intents: { intents: { id: string; status: string }[]; counts: Record<string, number> };
  workflow: { currentPhase: string; activeIntent: string; waitingForApproval: boolean };
  calibration: {
    decisions_count?: number;
    mae?: number;
    brier?: number;
    over_under?: string;
    bins?: unknown[];
  };
  docLinks: { path: string; label: string }[];
  drift: { raw?: string; hasMetrics?: boolean } | null;
  usage: { entryCount?: number; hasUsage?: boolean } | null;
}

function App() {
  const [data, setData] = useState<DashboardData | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  const loadData = async () => {
    setLoading(true);
    setError(null);
    try {
      const res = await fetch('/dashboard.json?t=' + Date.now());
      if (!res.ok) throw new Error('Failed to load dashboard data');
      const json = await res.json();
      setData(json);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Unknown error');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, []);

  if (loading && !data) {
    return (
      <div className="dashboard">
        <header>
          <h1>ShipIt Dashboard</h1>
        </header>
        <p className="loading">Loading...</p>
      </div>
    );
  }

  if (error && !data) {
    return (
      <div className="dashboard">
        <header>
          <h1>ShipIt Dashboard</h1>
        </header>
        <p className="error">
          {error}. Run <code>pnpm dashboard</code> from the repo root to export data first.
        </p>
      </div>
    );
  }

  const d = data!;
  const counts = d.intents?.counts ?? { planned: 0, active: 0, shipped: 0, killed: 0 };
  const workflow = d.workflow ?? {
    currentPhase: 'none',
    activeIntent: 'none',
    waitingForApproval: false,
  };

  return (
    <div className="dashboard">
      <header>
        <h1>ShipIt Dashboard</h1>
        <span className="project">{d.projectName}</span>
        <span className="generated">Updated: {new Date(d.generated).toLocaleString()}</span>
        <button type="button" className="refresh" onClick={loadData} title="Refresh data">
          Refresh
        </button>
      </header>

      {workflow.waitingForApproval && (
        <section className="gate-banner">
          ⏳ <strong>Waiting for approval</strong> — Human gate; check workflow state for details.
        </section>
      )}

      <section>
        <h2>Intents</h2>
        <div className="intent-counts">
          <div className="count planned">Planned: {counts.planned ?? 0}</div>
          <div className="count active">Active: {counts.active ?? 0}</div>
          <div className="count shipped">Shipped: {counts.shipped ?? 0}</div>
          <div className="count killed">Killed: {counts.killed ?? 0}</div>
        </div>
        <p className="current-phase">
          Current phase: <strong>{workflow.currentPhase}</strong>
          {workflow.activeIntent !== 'none' && (
            <>
              {' '}
              · Active intent: <strong>{workflow.activeIntent}</strong>
            </>
          )}
        </p>
      </section>

      <section>
        <h2>Documentation</h2>
        <ul className="doc-links">
          {d.docLinks?.map(({ path, label }) => (
            <li key={path}>
              <code>{path}</code> — {label}
            </li>
          ))}
        </ul>
        <p className="hint">Open these paths in your editor or file explorer.</p>
      </section>

      <section>
        <h2>Confidence calibration</h2>
        {d.calibration?.decisions_count ? (
          <div className="calibration">
            <p>Decisions: {d.calibration.decisions_count}</p>
            {d.calibration.mae != null && <p>MAE: {Number(d.calibration.mae).toFixed(3)}</p>}
            {d.calibration.over_under && <p>Status: {d.calibration.over_under}</p>}
          </div>
        ) : (
          <p>No calibration data yet. Run /verify to record decisions.</p>
        )}
      </section>

      {d.drift?.hasMetrics && (
        <section>
          <h2>Drift</h2>
          <pre className="drift-preview">{d.drift.raw?.slice(0, 500)}</pre>
        </section>
      )}

      {d.usage?.hasUsage && (
        <section>
          <h2>Usage</h2>
          <p>Usage entries: {d.usage.entryCount}</p>
        </section>
      )}
    </div>
  );
}

export default App;
