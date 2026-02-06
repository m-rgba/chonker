FROM kasmweb/ubuntu-noble-desktop:1.18.0

USER root

# Include startup files
COPY config/startup.sh /tmp/startup.sh
COPY config/kasmvnc.yaml /tmp/kasmvnc.yaml

# Copy skills
# /.claude/skills > also works for OpenCode, Cursor CLI, and AmpCode
COPY skills /home/kasm-user/.claude/skills
COPY skills /home/kasm-user/.codex/skills
COPY skills /home/kasm-user/.gemini/skills

# System setup and packages
RUN apt-get update \
    && apt-get install -y curl \
    && mkdir -p -m 755 /etc/apt/keyrings \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get update \
    && apt-get install -y \
    nodejs \
    fd-find \
    ripgrep \
    unzip \
    gh \
    && ln -sf /usr/bin/fdfind /usr/local/bin/fd

# Installers
RUN curl -fsSL https://code-server.dev/install.sh | sh -s -- --method=standalone --prefix=/usr/local \
    && curl -fsSL https://opencode.ai/install | bash \
    && curl -fsSL https://ampcode.com/install.sh | bash \
    && curl -fsSL https://cursor.sh/cli/install.sh | sh \
    && curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR=/usr/local/bin sh

# Install node.js global packages
RUN npm install -g --force \
    agent-browser \
    @ast-grep/cli \
    @openai/codex \
    @anthropic-ai/claude-code \
    @google/gemini-cli \
    && agent-browser install --with-deps

# Install python deps 
RUN uv venv \
    && . .venv/bin/activate \
    && uv pip install marimo \
    && uv pip install browser-use \
    && uvx browser-use install

ENV PATH="/.venv/bin:$PATH"

# Setup code server extensions
RUN code-server --install-extension sst-dev.opencode \
    && code-server --install-extension openai.chatgpt \
    && code-server --install-extension anthropic.claude-code \
    && code-server --install-extension sourcegraph.amp \
    && code-server --install-extension bloop.vibe-kanban

# Configure startup scripts
RUN sed -i '/######## FUNCTION DECLARATIONS ##########/r /tmp/startup.sh' /dockerstartup/vnc_startup.sh \
    && sed -i '/STARTUP_COMPLETE=1/i start_code_server' /dockerstartup/vnc_startup.sh \
    && sed -i '/STARTUP_COMPLETE=1/i start_opencode_server' /dockerstartup/vnc_startup.sh \
    && sed -i '/STARTUP_COMPLETE=1/i start_marimo' /dockerstartup/vnc_startup.sh \
    && sed -i '/STARTUP_COMPLETE=1/i start_vibe_kanban' /dockerstartup/vnc_startup.sh \
    && sed -i '/log "Starting KasmVNC"/a mkdir -p $HOME/.vnc && cp /tmp/kasmvnc.yaml $HOME/.vnc/kasmvnc.yaml' /dockerstartup/vnc_startup.sh \
    && sed -i 's/ -sslOnly / /g' /dockerstartup/vnc_startup.sh \
    && rm /tmp/startup.sh

# Expose ports
EXPOSE 6901 8800 8801 8802 8803 8804

# Set VNC settings
ENV VNC_RESOLUTION=1024x768
ENV KASM_SVC_UPLOADS=0
ENV KASM_SVC_GAMEPAD=0
ENV KASM_SVC_PRINTER=0
ENV KASM_SVC_SMARTCARD=0

ENV DISABLE_AUTH=true
ENV VNCOPTIONS=-disableBasicAuth