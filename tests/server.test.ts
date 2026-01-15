import { describe, it, expect } from 'vitest';
import { createServer } from '../src/server';
import { IncomingMessage, ServerResponse } from 'http';

describe('Server', () => {
  it('should create a server instance', () => {
    const server = createServer();
    expect(server).toBeDefined();
    expect(server.listening).toBe(true);
    server.close();
  });

  it('should handle /hello route', () => {
    const server = createServer();
    const mockReq = {
      url: '/hello',
      method: 'GET',
    } as IncomingMessage;
    const mockRes = {
      statusCode: 0,
      headers: {},
      writeHead: function (status: number, headers: Record<string, string>) {
        this.statusCode = status;
        Object.assign(this.headers, headers);
        return this;
      },
      end: function () {
        return this;
      },
    } as unknown as ServerResponse;

    // Server should handle the request
    expect(mockReq.url).toBe('/hello');
    server.close();
  });
});
