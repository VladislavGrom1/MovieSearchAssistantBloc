# AGENTS.md

## Команды

Flutter запускается только через `scripts/agent-flutter.ps1`: прямой `flutter.bat` зависает, потому что Flutter пишет lock-файл в `bin/cache` SDK вне рабочей папки.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/agent-flutter.ps1 test
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/agent-flutter.ps1 test test/presentation/bloc/ai_assistant_bloc_test.dart
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/agent-flutter.ps1 analyze lib test
```

`pwsh` на машине нет, только Windows PowerShell: именно `powershell.exe -NoProfile -ExecutionPolicy Bypass -File`.

Перед сдачей — одна команда с теми же проверками, что в CI (маршруты, глоссарий, analyze, тесты):

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/check.ps1
```

`-SkipAnalyze` / `-SkipTests` сокращают прогон во время итераций.

## Формат

CI формат не проверяет, и репозиторий не выровнен под `dart format` (171 из 189 файлов изменились бы). Форматируй только новые файлы; чужие целиком не трогай, иначе диффы тонут в шуме.

## Agent skills

### Issue tracker

Issues and specs live as markdown files under `.scratch/<feature-slug>/`. See `docs/agents/issue-tracker.md`.

### Triage labels

The five canonical triage roles use their default strings (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: one `GLOSSARY.md` plus `docs/adr/` at the repo root. See `docs/agents/domain.md`.

### AI-Ассистент

Экран, состояния, лента и хранение сессий: `docs/agents/ai-assistant.md`.

### Виджет-тесты

Общий стенд с телефонным вьюпортом, моками и ограниченным pump: `test/helpers/ai_assistant_test_harness.dart`. `pumpAndSettle` в тестах экрана не завершается — шиммеры постеров анимируются бесконечно.
