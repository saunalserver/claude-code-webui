FROM node:20-slim

# Install build dependencies for node-pty and runtime dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    make \
    g++ \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Install Claude Code CLI
RUN npm install -g @anthropic-ai/claude-code

# Create non-root user for running claude (required for --dangerously-skip-permissions)
# Use appuser user with UID 1000 to match host
RUN deluser node && \
    useradd -m -u 1000 -s /bin/bash appuser && \
    mkdir -p /home/appuser && \
    chown -R appuser:appuser /home/appuser

# Set working directory for the app
WORKDIR /home/appuser

# Copy package files
COPY package.json package-lock.json* ./

# Install dependencies (as root, then chown)
RUN npm ci --only=production && \
    chown -R appuser:appuser /home/appuser

# Copy application files
COPY --chown=appuser:appuser . .

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 3420

# Set default environment
ENV PORT=3420
ENV NODE_ENV=production
ENV HOME=/home/appuser
ENV USER=appuser

# Start the server
CMD ["npm", "start"]
