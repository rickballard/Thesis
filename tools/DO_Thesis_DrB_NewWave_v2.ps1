param(
    [string]$GhRoot    = "$HOME\\Documents\\GitHub",
    [string]$RepoName  = "Thesis",
    [string]$WaveId,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$repo  = Join-Path $GhRoot $RepoName
$root  = Join-Path $repo "docs\\thesis\\DrB"
$waves = Join-Path $root "99_waves"

if (-not (Test-Path (Join-Path $repo ".git"))) {
    throw "Thesis repo at $repo is not a git repo (.git missing)."
}

if (-not $WaveId) {
    throw "WaveId is required, for example 'W001_CoLoadingBoot' or 'W010_LitScanA'."
}

if (-not (Test-Path $root)) {
    New-Item -ItemType Directory -Path $root -Force | Out-Null
}

if (-not (Test-Path $waves)) {
    New-Item -ItemType Directory -Path $waves -Force | Out-Null
}

$waveDir = Join-Path $waves $WaveId

if ((Test-Path $waveDir) -and -not $DryRun) {
    Write-Host "Wave folder already exists at $waveDir. Reusing."
} elseif (-not $DryRun) {
    New-Item -ItemType Directory -Path $waveDir | Out-Null
}

$uts = (Get-Date).ToUniversalTime().ToString("yyyyMMddTHHmmssZ")

$files = @{
    "wave_notes.md" = @"
# DrB Wave $WaveId - Notes

- UTS start: $uts
- Focus:
- Related chapters:
- CoLoading context:

## Key decisions

- [ ]

## Next actions

- [ ]

## CoVibe - Scope checklist

### DONE
- [ ]

### DOING
- [ ]

### PLANNED
- [ ]

## CoVibe - Scope checklist

### DONE
- [ ]

### DOING
- [ ]

### PLANNED
- [ ]
"@

    "wave_ai_log.md" = @"
# DrB Wave $WaveId - AI Support Log

Use this file to record which sessions, prompts, and tools
contributed to this wave, with links to CoBus notes where possible.

- Session ids:
- CoBus / CoSync notes:
"@

    "wave_todo.md" = @"
# DrB Wave $WaveId - TODO

## Must do in this wave

- [ ]

## Carry over to future waves

- [ ]
"@
}

if (-not $DryRun) {
    foreach($name in $files.Keys){
        $path = Join-Path $waveDir $name
        if (-not (Test-Path $path)) {
            $files[$name] | Set-Content -Path $path -Encoding UTF8
        }
    }
}

$index = Join-Path $waves "DrB_Waves_Index.md"
$line  = "- $WaveId  [notes](./$WaveId/wave_notes.md)  |  UTS start: $uts"

if (-not $DryRun) {
    if (-not (Test-Path $index)) {
@"
# DrB Waves Index

Each entry represents one focused working wave on the thesis.

$line
"@ | Set-Content -Path $index -Encoding UTF8
    } else {
        Add-Content -Path $index -Encoding UTF8 -Value $line
    }
}

if ($DryRun) {
    "DRYRUN: would create wave at $waveDir and update $index"
    return
}

Push-Location $repo
try {
    git add .
    $cts = (Get-Date).ToUniversalTime().ToString("yyyyMMddTHHmmssZ")
    git commit -m ("DrB: new wave scaffold {0} ({1})" -f $WaveId,$cts)
    git push
    "OK: new DrB wave scaffold created and pushed -> $waveDir"
}
finally {
    Pop-Location
}

