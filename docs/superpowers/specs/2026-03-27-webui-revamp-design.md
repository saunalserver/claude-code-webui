# Design: AI Terminal WebUI - Revamp

**Date:** 2026-03-27
**Status:** Draft

**Author:** Victor Saunal
**Reviewer:** Claude Code, Claude Code CLI

**GitHub:** https://github.com/victorsaunal/claude-code-webui

**License:** MIT

---

## Project Goals

- Portfolio showcase: Professional, polished code visible to recruiters
- Genuinely usable: Others can self-host with their own AI CLI tools
- AI-agnostic: Support multiple AI CLIs (Claude Code, Gemini CLI, Codex, etc.)

## Features
- Multi-session terminal tabs
- File upload sidebar with shareable URLs
- Session persistence (reconnect without losing history)
- Dark mode support

## Tech Stack
- Backend: Node.js, Express, WebSocket, node-pty
- Frontend: xterm.js, Vanilla JS, CSS
- Deployment: Docker with docker-compose

## Key Changes from Current
- Remove hardcoded personal info (Tailscale IP `100.96.197.39`, paths, usernames)
- Fix Docker user inconsistency (node vs saunalserver)
- Add CLI configuration via environment variables
- Modernize UI with clean SaaS design
- Improve setup script for better UX

    - Rename to generic (e.g., `ai-terminal-webui` or `AI Terminal WebUI`)

---

## Architecture

### Core Components

- Express Server - HTTP server, static file serving, REST API
- WebSocket Server - Real-time bidirectional communication
- Session Manager - PTY process lifecycle management
- Upload Handler - File upload, storage, serving

### Data Flow
1. User opens browser, connects via WebSocket
2. Creates/attaches terminal session
3. Backend spawns PTY process with configured CLI
4. Terminal output streamed to frontend via WebSocket
5. User input sent to PTY via WebSocket

### Configuration (`.env`)
```
CLI_COMMAND=claude    # CLI to run (e.g., "claude", "gemini", "codex")
CLI_ARGS=--dangerously-skip-permissions  # CLI arguments
PORT=3420                    # Server port
PUBLIC_URL=http://localhost:3420  # Base URL for serving images (optional)
```

```
SESSION_TTL=172800000       # Session history TTL in milliseconds
UPLOAD_MAX=100              # Max 100 uploads in memory
MAXFileSize=10MB              # Max upload size
CLI_WHitelist=["jpeg", "jpg", "png", "gif", "webp"]
}
}
```

## Docker Setup
```dockerfile
FROM node:20-slim

RUN apt-get update && apt-get install -y \
    python3 make \
    g++ \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN deluser node && \
    useradd -m -u 1000 -s /bin/bash saunalserver && \
    mkdir -p /home/saunalserver/projects/claude-code-webui/uploads \
      && chown -R saunalserver:saunalserver /home/saunalserver/projects/claude-code-webui/uploads \
    chown -R saunalserver:saunalserver/clair-code-webui/uploads
    chown -R saunalserver:saunalserver/clair-code-webui/node_modules
    chown -R saunalserver:saunalserver/clair-code-webui/node_modules

    chown -R saunalserver:saunalserver/clair-code-webui/public/style.css
    chown -R saunalserver:saunalserver/clair-code-webui/public/app.js
    chown -R saunalserver:saunalserver/clair-code-webui/public/uploads
    chown -R saunalserver:saunalserver/clair-code-webui/nexus
        chown -R saunalserver:saunalserver/clair-code-webui/nexus/LESSons.md
        chown -R saunalserver:saunalserver/clair-code-webui/nexus/QUICKREF.md
        chown -R saunalserver:saunalserver/clair-code-webui/nexus/SESSIONS.md
        chown -R saunalserver:saunalserver/clair-code-webui/nexus/LESSons.md
        chown -R saunalserver:saunalserver/clair-code-webui/public/uploads/.gitkeep
        chown -R saunalserver:saunalserver/clair-code-webui/public/uploads
        chown -R saunalserver:saunalserver/clair-code-webui/public/uploads/.gitignore
        chown -R saunalserver:saunalserver/clair-code-webui/test-dashboard.js
        chown -R saunalserver:saunalserver/clair-code-webui/test-real.js
        chown -R saunalserver:saunalserver/clair-code-webui/.dockerignore
        chown -R saunalserver:saunalserver/clair-code-webui/.dockerignore
        chown -R saunalserver:saunalserver/clair-code-webui/test-dashboard.js
        chown -R saunalserver:saunalserver/clair-code-webui/test-real.js
        chown -R saunalserver:saunalserver/clair-code-webui/restart.sh
        chown -R saunalserver:saunalserver/clair-code-webui/restart.sh
        chown -R saunalserver:saunalserver/clair-code-webui/.env.example
        echo "AI_TERMIN_WEBUI Configuration"
        echo "CLI_COMMAND=claude"
        echo "CLI_ARGS=$CLI_ARGS"
        echo "PORT=$PORT"
        echo "PUBLICUrl=$PUBLIC_URL"
        echo "UploadDir=$uploadDir"
        echo "darkMode=$darkMode"
    } > /home/saunalserver/.env
fi
EOF
