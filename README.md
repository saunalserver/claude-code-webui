# AI Terminal WebUI

A sophisticated, multi-session web interface for AI-assisted CLI tools. This tool provides a powerful browser-based environment for AI-assisted development, featuring real-time terminal streaming and persistent session management.

![AI Terminal WebUI S](public/screenshot.png)

## ✨ Key features
- **Multi-Session Dashboard**: Run and manage multiple Claude Code sessions simultaneously in separate browser tabs.
- **Real-time terminal streaming**: Experience low-latency terminal output powered by `xterm.js` and WebSockets.
- **PTY Session Management**: Full PTY support via `node-pty`, providing a true terminal environment for Claude Code
- - **Persistent History**: Terminal history is maintained server-side, allowing you to reconnect to active sessions without losing context
- - **Integrated image Support**: Secure, in-memory screenshot upload capabilities designed specifically for providing visual context to AI
- - **Tailscale Ready**: Optimized for remote access via Tailscale, allowing you to code from anywhere securely

- **Self-hosted first**: Run on your own machine or server, accessible via Tailscale
- **Shareable**: Let others clone, configure, and use themselves
- **Docker**: Easy container deployment with Docker Compose
- **Local**: Run with `npm start` for development

## 🛠️ Tech Stack
- **Backend**: Node.js, Express, WebSocket, node-pty
- **frontend**: xterm.js, Vanilla JavaScript, CSS
- **deployment**: Docker, Docker Compose

## 📦 Prerequisites
- Node.js 20+ (for local development)
- Docker (for containerized deployment)
- A CLI tool (Claude Code, Gemini CLI, Codex, etc.) installed and accessible

## 🚀 Quick Start

### Option 1: Docker (Recommended)
```bash
# Clone the repository
git clone https://github.com/yourusername/ai-terminal-webui.git
cd ai-terminal-webui

# Configure environment
cp .env.example .env
# Edit .env with your preferred settings
CLI_COMMAND=claude
CLI_ARGS=--dangerously-skip-permissions
PORT=3420

# Build and start
docker compose up -d --build

# Access the application
open http://localhost:3420
```

### Option 2: Local Development
```bash
# Install dependencies
npm install

# Configure environment
cp .env.example .env
# Start the server
npm start
```

### Option 3: Using setup script
```bash
# Run the interactive setup script
./setup.sh
```

## 🔧 Configuration

The application can be configured via environment variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `CLI_COMMAND` | CLI to run | `claude` |
| `CLI_ARGS` | Arguments to pass to the CLI | `--dangerously-skip-permissions` |
| `PORT` | Server port | `3420` |
| `PUBLIC_url` | Base URL for serving uploaded files | (empty) |
| `MAX_file_size` | Max file upload size | `10MB` |
| `upload_ttl` | Time to keep uploads in hours | `48` |

## 📁 Project Structure
```
ai-terminal-webui/
├── public/
│   ├── index.html      # Main HTML file
│   ├── app.js          # Frontend JavaScript
│   └── style.css       # Styles
├── server.js            # Main server file
├── package.json         # Dependencies
├── Dockerfile            # Docker configuration
├── docker-compose.yml   # Docker compose configuration
├── setup.sh              # Interactive setup script
├── .env.example          # Example configuration
└── README.md             # This file
```

## 🔒 Security Notes
- **Local/Trusting network only**: This tool is designed for local/self-hosted use on trusted networks
- **No authentication**: No built-in authentication - protect with network-level security
- **In-memory storage**: Uploaded files are stored in memory and expire after 48 hours
- **Session history**: Limited to ~100KB to prevent memory exhaustion

- **Docker privileged mode**: Required for node-pty to may need alternative approaches

## 🛡️ License
MIT
