import { describe, it, expect } from 'vitest';
import { createHelloHandler } from '../../src/routes/hello';
import { IncomingMessage, ServerResponse } from 'http';

describe('Hello Endpoint', () => {
  it('should return JSON with message "Hello, World!"', () => {
    const handler = createHelloHandler();
    const mockRequest = {} as IncomingMessage;
    let responseBody = '';
    const mockResponse = {
      statusCode: 0,
      headers: {} as Record<string, string>,
      writeHead: function (status: number, headers: Record<string, string>) {
        this.statusCode = status;
        Object.assign(this.headers, headers);
        return this;
      },
      end: function (body: string) {
        responseBody = body;
        return this;
      },
    } as unknown as ServerResponse;

    handler(mockRequest, mockResponse);

    expect(mockResponse.statusCode).toBe(200);
    expect(mockResponse.headers['Content-Type']).toBe('application/json');
    const parsed = JSON.parse(responseBody);
    expect(parsed).toEqual({ message: 'Hello, World!' });
  });

  it('should respond in less than 200ms', () => {
    const handler = createHelloHandler();
    const mockRequest = {} as IncomingMessage;
    const mockResponse = {
      statusCode: 0,
      headers: {} as Record<string, string>,
      writeHead: function (status: number, headers: Record<string, string>) {
        this.statusCode = status;
        Object.assign(this.headers, headers);
        return this;
      },
      end: function () {
        return this;
      },
    } as unknown as ServerResponse;

    const start = Date.now();
    handler(mockRequest, mockResponse);
    const duration = Date.now() - start;

    expect(duration).toBeLessThan(200);
  });
});
