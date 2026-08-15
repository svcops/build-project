# AGENTS.md

## Shell Selection

These rules apply to all agents, subagents, and commands they launch on Windows.

- Default to PowerShell 7 (`pwsh`).
- If `pwsh` is unavailable, fall back to Windows PowerShell (`powershell.exe`).
- Use Git Bash for `.sh` files and POSIX-oriented script validation or execution.
- Use `pwsh` for `.ps1` files and Windows-native operations.
- When launching Git Bash from Windows, invoke the Git for Windows `bash.exe` by its full path, typically:
  `C:\Program Files\Git\bin\bash.exe`
- Never use the bare `bash` or `bash.exe` command to launch Git Bash because it may invoke WSL.
- Do not mix Bash and PowerShell syntax or nest shells unnecessarily.
