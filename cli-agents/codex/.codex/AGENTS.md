# Core Rules

- **MUST** use the Bash tool to execute all shell commands and scripts, including on Windows.
- For repositories on a Windows filesystem (`C:\...` or `/mnt/c/...`), **MUST** prefer native Windows Git by invoking `git.exe` from Bash. Use WSL `git` only for repositories stored inside the WSL filesystem.
- **MUST NOT** invoke PowerShell as the command shell or write inline PowerShell commands. Run `.ps1` files through their Bash wrapper; the wrapper may select `pwsh` or `powershell.exe` as required.
- After completing a larger task, if the change's impact scope is judged to be large, **MUST** call a reviewer for adversarial review; if the scope cannot be judged, **MUST** ask the user whether to call a reviewer for adversarial review.
- **MUST** prefer `aery-claude-code`'s `claude-code` for the adversarial-review reviewer; fall back to `terra xhigh` only when it is unavailable.
