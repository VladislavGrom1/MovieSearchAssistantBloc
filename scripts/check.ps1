<#
.SYNOPSIS
  Полный набор проверок перед сдачей: маршруты, глоссарий, analyze, тесты.

.DESCRIPTION
  Те же проверки, что гоняет CI (.github/workflows/flutter_cicd.yml), но
  локально и одной командой.

  Маршруты и глоссарий проверяются shell-скриптами, а `sh` в PATH этой машины
  нет, поэтому sh.exe ищется среди стандартных установок Git for Windows.

  `pwsh` на машине тоже нет: Flutter запускается через Windows PowerShell,
  который вызывает scripts/agent-flutter.ps1.

.EXAMPLE
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/check.ps1

.EXAMPLE
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/check.ps1 -SkipTests
#>
[CmdletBinding()]
param(
    [switch] $SkipAnalyze,
    [switch] $SkipTests
)

$ErrorActionPreference = 'Stop'

$scriptsDir = $PSScriptRoot
$failed = [System.Collections.Generic.List[string]]::new()

function Resolve-Sh {
    $candidates = @()

    if ($env:ProgramFiles) {
        $candidates += Join-Path $env:ProgramFiles 'Git\bin\sh.exe'
    }

    if (${env:ProgramFiles(x86)}) {
        $candidates += Join-Path ${env:ProgramFiles(x86)} 'Git\bin\sh.exe'
    }

    $candidates += 'E:\Programs\Git\bin\sh.exe'

    foreach ($candidate in $candidates) {
        if (Test-Path $candidate) {
            return $candidate
        }
    }

    $command = Get-Command sh.exe -ErrorAction SilentlyContinue

    if ($command) {
        return $command.Source
    }

    throw 'Не найден sh.exe (Git Bash). Установите Git for Windows.'
}

$sh = Resolve-Sh

foreach ($check in @('check_routes_sync.sh', 'check_vocabulary.sh')) {
    Write-Host "==> $check" -ForegroundColor Cyan
    & $sh (Join-Path $scriptsDir $check)

    if ($LASTEXITCODE -ne 0) {
        $failed.Add($check)
    }
}

$agentFlutter = Join-Path $scriptsDir 'agent-flutter.ps1'

if (-not $SkipAnalyze) {
    Write-Host '==> analyze lib test' -ForegroundColor Cyan
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $agentFlutter analyze lib test

    if ($LASTEXITCODE -ne 0) {
        $failed.Add('analyze')
    }
}

if (-not $SkipTests) {
    Write-Host '==> test' -ForegroundColor Cyan
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $agentFlutter test

    if ($LASTEXITCODE -ne 0) {
        $failed.Add('test')
    }
}

if ($failed.Count -gt 0) {
    Write-Host ''
    Write-Host "Провалено: $($failed -join ', ')" -ForegroundColor Red
    exit 1
}

Write-Host ''
Write-Host 'Все проверки прошли.' -ForegroundColor Green
