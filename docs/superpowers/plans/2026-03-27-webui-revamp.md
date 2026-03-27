# Implementation Plan: AI Terminal WebUI Revamp

**Date:** 2026-03-27
**Spec:** `docs/superpowers/specs/2026-03-27-webui-revamp-design.md`

---

## Overview

This plan transforms the existing Claude Code WebUI into a professional, AI-agnostic terminal interface suitable for portfolio showcase and real-world use.

## Execution Approach

**Inline Execution** - Tasks are executed sequentially in this session with checkpoints for review.

---

## Task 1: Remove Hardcoded Personal Info from server.js

**Goal:** Remove all hardcoded personal information (Tailscale IP, paths, usernames) from server.js.

**Files to modify:**
- `server.js` (lines 192-195, 272, 280-282, 295-313)

**Changes:**
1. Remove lines 192-195 (startup logs with Tailscale IP and hardcoded paths)
2. Update line 272 to use environment variable for home directory
3. Remove lines 295-313 (debug logs that expose auth token details)

**New code:**

```javascript
// Replace lines 192-195 with:
const server = app.listen(PORT, '0.0.0.0', () => {
  console.log(`AI Terminal WebUI running on http://0.0.0.0:${PORT}`);
  console.log(`Upload TTL: 48 hours (in-memory storage)`);
});

// Update line 272:
const cwd = payload?.cwd || process.env.HOME || '/home/appuser';

// Remove lines 295-313 (debug logs)
```

**Testing:**
- Start server, verify no personal info in console output
- Check that `console.log` statements don't expose sensitive data

**Commit message:** `refactor: remove hardcoded personal info from server.js`

---

## Task 2: Add CLI Configuration Environment Variables

**Goal:** Make the CLI tool configurable via environment variables instead of hardcoded.

**Files to modify:**
- `server.js` (line 316)

**Changes:**
1. Add environment variables for CLI configuration at top of file
2. Replace hardcoded `claude` command with configurable value

**New code:**

```javascript
// Add after line 16:
const CLI_COMMAND = process.env.CLI_COMMAND || 'claude';
const CLI_ARGS = process.env.CLI_ARGS || '--dangerously-skip-permissions';

// Replace line 316:
const ptyProcess = pty.spawn(CLI_COMMAND, CLI_ARGS.split(' '), {
  name: 'xterm-color',
  cwd: cwd,
  env: ptyEnv,
  cols: 80,
  rows: 24
});
```

**Testing:**
- Set `CLI_COMMAND=gemini` and verify it server tries to spawn `gemini`
- Set `CLI_COMMAND=codex` and verify server tries to spawn `codex`
- Default (no env var) should use `claude`

**Commit message:** `feat: add CLI configuration via environment variables`

---

## Task 3: Fix Docker Configuration

**Goal:** Fix user inconsistency between Dockerfile (saunalserver) and docker-compose.yml (node).

**Files to modify:**
- `Dockerfile` (lines 16-19, 43-44)
- `docker-compose.yml` (lines 11-13, 16-17)

**Changes:**

**Dockerfile:**
```dockerfile
# Replace lines 16-19 with:
RUN deluser node && \
    useradd -m -u 1000 -s /bin/bash appuser && \
    mkdir -p /home/appuser && \
    chown -R appuser:appuser /home/appuser

# Replace lines 43-44 with:
ENV HOME=/home/appuser
ENV USER=appuser
```

**docker-compose.yml:**
```yaml
# Replace lines 11-13 with:
volumes:
  # Mount workspace directory
  - ./workspace:/home/appuser/workspace
  # Mount Claude Code config for authentication
  - ~/.claude:/home/appuser/.claude

# Replace lines 16-17 with:
environment:
  - PORT=3420
  - HOME=/home/appuser
  - USER=appuser
```

**Testing:**
- Build Docker image: `docker build -t ai-terminal-webui .`
- Verify no build errors
- Check that user is `appuser` not `saunalserver`

**Commit message:** `fix: standardize Docker user to appuser`

---

## Task 4: Create .env.example File

**Goal:** Provide a template for users to configure the application.

**Files to create:**
- `.env.example`

**Content:**
```env
# AI Terminal WebUI Configuration

# CLI Configuration
# The command to run (e.g., claude, gemini, codex, or path to custom CLI)
CLI_COMMAND=claude

# Arguments to pass to the CLI
CLI_ARGS=--dangerously-skip-permissions

# Server Configuration
PORT=3420

# Optional: Public URL for serving uploaded files
# Leave empty to use the request's host
# PUBLIC_URL=https://your-domain.com

# Upload Configuration
# Max file size in bytes (default: 10MB)
# MAX_FILE_SIZE=10485760

# Upload TTL in hours (default: 48)
# UPLOAD_TTL=48
```

**Testing:**
- Copy `.env.example` to `.env`
- Verify server starts with default values
- Verify server uses custom values from `.env`

**Commit message:** `docs: add .env.example configuration template`

---

## Task 5: Improve Setup Script

**Goal:** Make the setup script more user-friendly and comprehensive.

**Files to modify:**
- `setup.sh`

**Changes:**
1. Add CLI configuration prompts
2. Add validation for prerequisites
3. Improve error handling
4. Add color output for better UX
5. Add option to install multiple CLIs

**New code:**
```bash
#!/bin/bash

# AI Terminal WebUI - Interactive Setup Script

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=======================================${NC}"
echo -e "${GREEN}   AI Terminal WebUI - Setup Wizard    ${NC}"
echo -e "${BLUE}=======================================${NC}"
echo ""

# Prerequisite check
echo -e "${YELLOW}Checking prerequisites...${NC}"
missing_deps=()

if ! command -v node &> /dev/null; then
    missing_deps+=("node")
fi

if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}Note: 'docker' not found. Docker is recommended.${NC}"
fi

if [ ${#missing_deps[@]} -gt 0 ]; then
    echo -e "${RED}Missing dependencies: ${missing_deps[*]}${NC}"
    echo "Please install missing dependencies and try again."
    exit 1
fi

echo "All prerequisites met."
echo ""

# Configuration
echo -e "${BLUE}--- CLI Configuration ---${NC}"

echo "Which AI CLI will you use?"
echo "  1) Claude Code (claude)"
echo "  2) Gemini CLI (gemini)"
echo "  3) Codex (codex)"
echo "  4) Custom (specify path)"
read -p "Enter choice [1-4]: " cli_choice

case $cli_choice in
    1) CLI_COMMAND="claude" ;;
    2) CLI_COMMAND="gemini" ;;
    3) CLI_COMMAND="codex" ;;
    4)
        read -p "Enter custom CLI command: " CLI_COMMAND
        ;;
    *) CLI_COMMAND="claude" ;;
esac

read -p "CLI arguments [default: --dangerously-skip-permissions]: " cli_args
CLI_ARGS=${cli_args:- --dangerously-skip-permissions}

# Server configuration
echo ""
echo -e "${BLUE}--- Server Configuration ---${NC}"
read -p "Server port [default: 3420]: " port
PORT=${port:-3420}

read -p "Public URL for uploads [leave empty if unknown]: " public_url

# Generate .env file
echo ""
echo -e "${YELLOW}Generating .env file...${NC}"
cat > .env << EOF
# AI Terminal WebUI Configuration
# Generated by setup script

CLI_COMMAND=$CLI_COMMAND
CLI_ARGS=$CLI_ARGS
PORT=$PORT
PUBLIC_URL=$public_url
EOF

echo -e "${GREEN}Configuration saved to .env!${NC}"
echo ""

# Docker setup
read -p "Start with Docker? (y/n): " docker_choice
if [[ "$docker_choice" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Building and starting container...${NC}"
    docker compose up -d --build
    echo -e "${GREEN}Container started!${NC}"
    echo -e "Access at: ${BLUE}http://localhost:${PORT}${NC}"
else
    read -p "Install local dependencies? (y/n): " install_choice
    if [[ "$install_choice" =~ ^[Yy]$ ]]; then
        npm install
        echo -e "${GREEN}Dependencies installed!${NC}"
        echo -e "Start with: ${BLUE}npm start${NC}"
    fi
fi

echo ""
echo -e "${BLUE}=======================================${NC}"
echo -e "${GREEN}   Setup Complete!${NC}"
echo -e "${BLUE}=======================================${NC}"
```

**Testing:**
- Run `./setup.sh`
- Select different CLI options
- Verify `.env` file is created correctly
- Verify Docker container starts

**Commit message:** `feat: improve setup script with CLI configuration`

---

## Task 6: Update .gitignore

**Goal:** Ensure sensitive files are not committed.

**Files to modify:**
- `.gitignore`

**Add:**
```gitignore
# Environment files
.env

# Uploads directory
uploads/

# IDE
.vscode/
.idea/

# OS files
.DS_Store
Thumbs.db

# Logs
*.log
npm-debug.log*
```

**Testing:**
- Create a `.env` file with secrets
- Run `git status`
- Verify `.env` is not listed

**Commit message:** `chore: update .gitignore for sensitive files`

---

## Task 7: Update README.md

**Goal:** Create comprehensive, professional documentation.

**Files to modify:**
- `README.md`

**New content:**
```markdown
# AI Terminal WebUI

A professional, multi-session web interface for AI CLI tools. Run Claude Code, Gemini CLI, Codex, or any terminal-based AI assistant in your browser with real-time terminal streaming and persistent session management.

## Features

- **Multi-Session Tabs** - Run multiple AI sessions simultaneously in separate browser tabs
- **Real-Time Terminal** - Low-latency terminal output powered by xterm.js and WebSockets
- **File Upload Sidebar** - Upload images and files to share with your AI assistant
- **Session Persistence** - Reconnect to active sessions without losing terminal history
- **AI-Agnostic** - Configure any CLI tool via environment variables

## Quick Start

### Using Docker (Recommended)

1. Clone the repository:
   ```bash
   git clone https://github.com/victorsaunal/claude-code-webui.git
   cd claude-code-webui
   ```

2. Run the setup script:
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

3. Open `http://localhost:3420` in your browser

### Manual Setup

1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` with your configuration:
   ```env
   CLI_COMMAND=claude
   CLI_ARGS=--dangerously-skip-permissions
   PORT=3420
   ```

3. Install dependencies:
   ```bash
   npm install
   ```

4. Start the server:
   ```bash
   npm start
   ```

## Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `CLI_COMMAND` | CLI to run (claude, gemini, codex, or path) | `claude` |
| `CLI_ARGS` | Arguments to pass to the CLI | `--dangerously-skip-permissions` |
| `PORT` | Server port | `3420` |
| `PUBLIC_URL` | Base URL for serving uploaded files | (empty) |

## Tech Stack

- **Backend:** Node.js, Express, WebSocket, node-pty
- **Frontend:** xterm.js, Vanilla JavaScript, CSS
- **Deployment:** Docker

## Security Notes

- This tool is designed for **local/self-hosted use** on trusted networks
- No authentication is built-in - protect with network-level security
- Uploaded files are stored in memory and expire after 48 hours
- Session history is limited to ~100KB to prevent memory exhaustion

## License

MIT
```

**Testing:**
- Read through the README
- Verify all links and commands work
- Verify feature list matches implementation

**Commit message:** `docs: rewrite README with comprehensive documentation`

---

## Task 8: Test Everything Locally

**Goal:** Verify all changes work correctly.

**Steps:**
1. Stop any running containers: `docker compose down`
2. Build fresh: `docker compose build --no-cache`
3. Start container: `docker compose up -d`
4. Check logs: `docker compose logs -f`
5. Open `http://localhost:3420`
6. Create a new terminal session
7. Upload a file
8. Switch between tabs
9. Close a tab
10. Check for any console errors

**Success criteria:**
- Server starts without errors
- No personal info in logs
- Terminal sessions work
- File upload works
- Tab management works
- No JavaScript console errors

**Commit message:** `test: verify all changes work correctly`

---

## Task 9: Final Commit and Push

**Goal:** Commit all changes and push to GitHub.

**Steps:**
1. Review all changes: `git status`
2. Stage all changes: `git add .`
3. Create commit:
   ```bash
   git commit -m "feat: revamp to AI Terminal WebUI

- Remove hardcoded personal info
- Add CLI configuration via environment variables
- Fix Docker user inconsistency
- Improve setup script
- Update documentation
- Add .env.example template"
   ```
4. Push to GitHub: `git push origin main`

**Success criteria:**
- All changes committed
- Push successful
- GitHub repo updated

---

## Summary

This plan transforms the Claude Code WebUI into a professional, AI-agnostic terminal interface suitable for portfolio showcase and real-world use.

**Total tasks:** 9
**Estimated complexity:** Medium
**Key changes:** Remove personal info, add CLI config, fix Docker, improve docs
