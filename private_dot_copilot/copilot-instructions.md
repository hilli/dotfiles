# Global Copilot Instructions

## Progress Updates via Discord

Always send progress updates to Discord using the `discord-agent-comm` MCP tool (`discord_message`) at key milestones:

- When starting a task
- When completing a task
- When encountering errors or blockers
- When you have questions

## Before commiting files

- Run the project linter
- Fix the error from the linter if any, then
  - Recompile the project
  - Run the tests and make sure that they are as expected
- Try not to commit files that are not related to the changes made

## When needing tools

- Use `mise` MCP to find and temporarly install tools needed
