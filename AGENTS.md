# AGENTS.md

## Команды

Flutter запускается только через `scripts/agent-flutter.ps1` (и только с полным доступом к файловой системе):

```powershell
pwsh -File scripts/agent-flutter.ps1 test
pwsh -File scripts/agent-flutter.ps1 analyze lib test
```

Прямой `flutter.bat` из pwsh зависает: Flutter пишет lock-файл в `bin/cache` SDK, вне рабочей папки.

Перед сдачей работы прогоняются те же проверки, что и в CI:

```sh
sh scripts/check_routes_sync.sh   # экраны @RoutePage() против app_router.gr.dart
sh scripts/check_vocabulary.sh    # запрещённые глоссарием синонимы в lib/
```

## Agent skills

### Issue tracker

Issues and specs live as markdown files under `.scratch/<feature-slug>/`. See `docs/agents/issue-tracker.md`.

### Triage labels

The five canonical triage roles use their default strings (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: one `GLOSSARY.md` plus `docs/adr/` at the repo root. See `docs/agents/domain.md`.
