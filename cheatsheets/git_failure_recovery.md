# Git Failure Recovery Cheatsheet

## Simplified Definition
Git failure recovery is restoring a safe working state without losing useful debugging evidence.

## Enterprise Context
Incident response often creates exploratory changes. Safe git handling preserves traceability.

## LinkedIn Skill Mapping
- Git
- CI/CD
- Release Engineering
- Troubleshooting

## Safe Commands
- `git status`
- `git switch -c fix/<ticket-id>`
- `git stash push -u -m "wip investigation"`
- `git restore --staged <file>`
- `git reflog`

## Warning
Avoid destructive resets in shared branches unless explicitly approved.
