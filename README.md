# Chonker
Shipping the whole dev machine in a container.
Hiren's BootCD, but for AI.
```
    ___       ___       ___       ___       ___       ___       ___   
   /\  \     /\__\     /\  \     /\__\     /\__\     /\  \     /\  \  
  /::\  \   /:/__/_   /::\  \   /:| _|_   /:/ _/_   /::\  \   /::\  \ 
 /:/\:\__\ /::\/\__\ /:/\:\__\ /::|/\__\ /::-"\__\ /::\:\__\ /::\:\__\
 \:\ \/__/ \/\::/  / \:\/:/  / \/|::/  / \;:;-",-" \:\:\/  / \;:::/  /
  \:\__\     /:/  /   \::/  /    |:/  /   |:|  |    \:\/  /   |:\/__/ 
   \/__/     \/__/     \/__/     \/__/     \|__|     \/__/     \|__|    computer.
```

<div align="center">
  <table>
    <tr>
      <td width="70%"  align="left">
        A chonky container image for a stateful remote development environment.<br/>
        Good for letting your AIs run loose in a containerized environment.<br /><br />
         <strong>Clone the repo and get started with</strong>:<br/>
<pre>
docker compose up
</pre>
         <strong>Pre-installed with:</strong><br/>
<pre>
Claude Code     ast-grep         Kasm web desktop (Ubuntu 24.04)
OpenAI Codex    ripgrep          Code server (IDE)
OpenCode        fd-find          Marimo (Python notebook)
AMP             agent-browser    OpenCode server (web UI)
Cursor (CLI)    browser-use      Vibe-Kanbam
Gemini          + Agent Skils
</pre>
      </td>
      <td width="30%" align="left">
         <img width="457" height="629" alt="image" src="./readme.png" />         
      </td>
    </tr>
  </table>
</div>

> [!WARNING]
> My default this container runs without authentication on the services. Only recommended for local use.<br/>
> If you're running it as an exposed service, this **requires** a reverse proxy or VPN for auth.<br/>
> ---<br/>
> There is an example container which uses Caddy to add basic auth to your containers over port 80:<br/>
> You can run this with `docker compose -f docker-compose.caddy.example.yml up`.


## ⚙️ Container Services
```
Service                            Port
--------------------------------   -------------------------------------------------------------
Ubuntu 24.04 + Kasm web desktop    [8800:6901]   
Code server (hosted VSCode)        [8801]               
OpenCode server                    [8802]
Vibe-Kanbam                        [8803]
Marimo (Python notebook)           [8804] + IDE extension
```

## 🧠 AI CLIs
```
CLI                                How to access
--------------------------------   -------------------------------------------------------------
Claude Code                        `claude`   + IDE extension   
OpenAI Codex                       `codex`    + IDE extension               
OpenCode                           `opencode` + IDE extension               
AMP                                `amp`      + IDE extension               
Cursor                             `cursor`
```

## 🤸‍♂️ Skills
Some general power-ups which can help the agents go brrrr.\
These also come with `SKILL.md` files so the agents understand how to use them.
```
CLI                                What is it?
--------------------------------   -------------------------------------------------------------
ast-grep                           Structured search (abstract syntax tree - good for code).   
ripgrep                            Better / faster grep.               
fd-find                            Better / faster find - good for looking up files.               
agent-browser                      Fast + lower token usage agent browser (default).                
browser-use                        Traditional Playwright browser utility.
```

