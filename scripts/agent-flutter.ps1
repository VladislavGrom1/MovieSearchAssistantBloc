<#
.SYNOPSIS
  Запускает Flutter CLI из агентской сессии DSH.

.DESCRIPTION
  Два известных ограничения окружения, из-за которых прямой вызов
  `flutter.bat ...` из pwsh зависает:

  1. Флачтер-тул пишет lock-файл в `$FLUTTER_ROOT\bin\cache\`, то есть вне
     рабочей папки. Песочница DSH этот путь не разрешает, вызов уходит
     в бесконечное ожидание. Поэтому нужен запуск с
     `sandbox_permissions: danger-full-access`.
  2. Сбор stdout дочернего процесса через конвейер в этом окружении
     блокируется. Поэтому вывод пишется в файлы через
     Start-Process -RedirectStandardOutput/-RedirectStandardError,
     а потом читается.

  Скрипт обходит второе ограничение и печатает вывод, но не может обойти
  первое: вызывать его всё равно нужно с danger-full-access.

.EXAMPLE
  pwsh -File scripts/agent-flutter.ps1 analyze lib test

.EXAMPLE
  pwsh -File scripts/agent-flutter.ps1 test test/presentation/bloc/ai_films_bloc_test.dart
#>
[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]] $FlutterArgs
)

$ErrorActionPreference = 'Stop'

if (-not $FlutterArgs -or $FlutterArgs.Count -eq 0) {
    Write-Error 'Передайте аргументы Flutter, например: agent-flutter.ps1 analyze lib test'
}

$flutterRoot = if ($env:FLUTTER_ROOT) { $env:FLUTTER_ROOT } else { 'E:\Programs\flutter' }
$dart = Join-Path $flutterRoot 'bin\cache\dart-sdk\bin\dart.exe'
$snapshot = Join-Path $flutterRoot 'bin\cache\flutter_tools.snapshot'

if (-not (Test-Path $dart)) { Write-Error "Не найден dart: $dart" }
if (-not (Test-Path $snapshot)) { Write-Error "Не найден flutter_tools.snapshot: $snapshot" }

$env:FLUTTER_ROOT = $flutterRoot

$stamp = [guid]::NewGuid().ToString('N')
$outFile = Join-Path $env:TEMP "flutter-$stamp.out"
$errFile = Join-Path $env:TEMP "flutter-$stamp.err"

try {
    $process = Start-Process -FilePath $dart `
        -ArgumentList (@($snapshot) + $FlutterArgs) `
        -NoNewWindow -PassThru `
        -RedirectStandardOutput $outFile `
        -RedirectStandardError $errFile

    $null = $process.WaitForExit()

    if (Test-Path $outFile) { Get-Content $outFile -Raw -ErrorAction SilentlyContinue }
    if (Test-Path $errFile) { Get-Content $errFile -Raw -ErrorAction SilentlyContinue }

    exit $process.ExitCode
}
finally {
    Remove-Item $outFile, $errFile -ErrorAction SilentlyContinue
}
