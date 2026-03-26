# Claude Code WebUI

A sophisticated, multi-session web interface for the **Claude Code** CLI. This tool provides a powerful browser-based environment for AI-assisted development, featuring real-time terminal streaming and persistent session management.

## ✨ Key Features
- **Multi-Session Dashboard**: Run and manage multiple Claude Code sessions simultaneously in separate browser tabs.
- **Real-time Terminal Streaming**: Experience low-latency terminal output powered by `xterm.js` and WebSockets.
- **PTY Session Management**: Full PTY support via `node-pty`, providing a true terminal environment for Claude Code.
- **Persistent History**: Terminal history is maintained server-side, allowing you to reconnect to active sessions without losing context.
- **Integrated Image Support**: Secure, in-memory screenshot upload capabilities designed specifically for providing visual context to Claude.
- **Tailscale Ready**: Optimized for remote access via Tailscale, allowing you to code from anywhere securely.

## 🛠️ Tech Stack
- **Backend**: Node.js, Express, WebSocket (`ws`), `node-pty`
- **Frontend**: `xterm.js`, Vanilla JavaScript, CSS
- **Deployment**: Docker, Docker Compose

## 🚀 Quick Start (Docker)
The easiest way to run Claude Code WebUI is via Docker:

1. **Configure volumes**: Ensure your `.claude` config directory is accessible.
2. **Launch**:
   ```bash
   docker compose up -d --build
   ```
3. **Access**: Open `http://localhost:3420` in your browser.

## 🔧 Configuration
The application can be configured via environment variables:
- `PORT`: Server port (default: 3420)
- `PUBLIC_URL`: Base URL for serving uploaded images (optional)

## 🛡️ License
MIT
