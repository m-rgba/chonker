
function start_code_server (){
    log 'Starting code-server'
    
    if [ -f /usr/bin/code-server ]; then
        CODE_SERVER_BIN="/usr/bin/code-server"
    elif [ -f /usr/local/bin/code-server ]; then
        CODE_SERVER_BIN="/usr/local/bin/code-server"
    else
        log "code-server binary not found in /usr/bin or /usr/local/bin" "ERROR"
        return
    fi
    
    # Use 0.0.0.0 to bind to all interfaces so it's accessible outside the container
    # Open the home directory by default
    # Log output to a file for debugging

    "$CODE_SERVER_BIN" --bind-addr 0.0.0.0:8801 --auth none > "$HOME/.vnc/code-server.log" 2>&1 &
    
    KASM_PROCS['code-server']=$!
    
    if [[ $DEBUG == true ]]; then
        echo -e "\n------------------ Started code-server ----------------------------"
        echo "code-server PID: ${KASM_PROCS['code-server']}";
    fi
}

function start_opencode_server (){
    log 'Starting OpenCode Server'
    
    # OpenCode is installed in ~/.opencode/bin/opencode
    export PATH="$HOME/.opencode/bin:$PATH"
    
    if ! command -v opencode &> /dev/null; then
        log "opencode binary not found checking default location" "WARNING"
        if [ -f "$HOME/.opencode/bin/opencode" ]; then
             log "Found opencode at $HOME/.opencode/bin/opencode"
             OPENCODE_BIN="$HOME/.opencode/bin/opencode"
        else
             log "opencode binary not found" "ERROR"
             return
        fi
    else
        OPENCODE_BIN="opencode"
    fi
    
    
    "$OPENCODE_BIN" web --port 8802 --hostname 0.0.0.0 > "$HOME/.vnc/opencode.log" 2>&1 &
    
    KASM_PROCS['opencode']=$!
    
    if [[ $DEBUG == true ]]; then
        echo -e "\n------------------ Started OpenCode Server ----------------------------"
        echo "OpenCode server PID: ${KASM_PROCS['opencode']}";
    fi
}

function start_marimo (){
    log 'Starting Marimo'
    
    # Marimo is installed in /usr/local/bin/marimo or in .venv
    
    # helper for venv if it exists
    if [ -f "/.venv/bin/activate" ]; then
        source /.venv/bin/activate
    elif [ -f "$HOME/.venv/bin/activate" ]; then
        source "$HOME/.venv/bin/activate"
    fi
    
    if ! command -v marimo &> /dev/null; then
        log "marimo binary not found checking default location" "WARNING"
         if [ -f "/usr/local/bin/marimo" ]; then
             log "Found marimo at /usr/local/bin/marimo"
             MARIMO_BIN="/usr/local/bin/marimo"
        else
             log "marimo binary not found" "ERROR"
             return
        fi
    else
        MARIMO_BIN="marimo"
    fi
    
    # Start Marimo    
    # Running in edit mode, headless, accessible from host
    mkdir -p "$HOME/notebooks"
    cd "$HOME/notebooks"
    "$MARIMO_BIN" edit --host 0.0.0.0 --port 8804 --headless --no-token > "$HOME/.vnc/marimo.log" 2>&1 &
    
    KASM_PROCS['marimo']=$!
    
    if [[ $DEBUG == true ]]; then
        echo -e "\n------------------ Started Marimo ----------------------------"
        echo "Marimo PID: ${KASM_PROCS['marimo']}";
    fi
}

function start_vibe_kanban (){
    log 'Starting Vibe Kanban'
        
    HOST=0.0.0.0 PORT=8803 npx vibe-kanban > "$HOME/.vnc/vibe-kanban.log" 2>&1 &
    
    KASM_PROCS['vibe-kanban']=$!
    
    if [[ $DEBUG == true ]]; then
        echo -e "\n------------------ Started Vibe Kanban ----------------------------"
        echo "Vibe Kanban PID: ${KASM_PROCS['vibe-kanban']}";
    fi
}