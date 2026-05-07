$ErrorActionPreference = "Continue"
$repo = "C:\Users\nitye\.claude"
$logFile = Join-Path $repo "backup.log"

function Log($msg) {
    "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $msg" | Out-File -FilePath $logFile -Append -Encoding utf8
}

function Invoke-Git {
    param([Parameter(ValueFromRemainingArguments)] [string[]] $GitArgs)
    $output = & git @GitArgs 2>&1 | Out-String
    if ($LASTEXITCODE -ne 0) {
        throw "git $($GitArgs -join ' ') failed (exit $LASTEXITCODE): $output"
    }
    return $output.Trim()
}

try {
    Set-Location $repo
    Log "Starting monthly backup"

    Invoke-Git add -A . | Out-Null

    $staged = & git diff --cached --name-only
    if (-not $staged) {
        Log "No changes - nothing to commit"
        exit 0
    }

    $count = ($staged | Measure-Object -Line).Lines
    $msg = "Monthly backup $(Get-Date -Format 'yyyy-MM-dd') ($count files changed)"
    Invoke-Git commit -m $msg | Out-Null
    Log "Committed: $msg"

    $pushOut = Invoke-Git push
    Log "Push complete. $pushOut"
} catch {
    Log "ERROR: $_"
    exit 1
}
