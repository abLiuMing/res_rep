[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$Manifest,
    [Parameter(Mandatory = $true)][string]$DownloadDir,
    [Parameter(Mandatory = $true)][string]$OutputDir
)

$ErrorActionPreference = "Stop"
$StagingDir = "$OutputDir.new"
if (Test-Path -LiteralPath $StagingDir) {
    Remove-Item -Recurse -Force -LiteralPath $StagingDir
}
New-Item -ItemType Directory -Force -Path $StagingDir | Out-Null

$ManifestDir = Split-Path -Parent $Manifest
$EffectConfig = [System.IO.Path]::GetFullPath((Join-Path $ManifestDir "../configs/effect.json"))
Copy-Item -LiteralPath $EffectConfig -Destination (Join-Path $StagingDir "effect.json")

foreach ($Line in Get-Content -LiteralPath $Manifest) {
    $Trimmed = $Line.Trim()
    if (-not $Trimmed -or $Trimmed.StartsWith("#")) { continue }
    $Fields = $Trimmed -split "\s+"
    if ($Fields.Count -ne 4) { throw "invalid manifest line: $Line" }

    $Name = $Fields[0]
    $Version = $Fields[1]
    $RelativeArtifact = $Fields[2].Replace("/", [System.IO.Path]::DirectorySeparatorChar)
    $SourceFile = Join-Path $DownloadDir $RelativeArtifact
    if (-not (Test-Path -LiteralPath $SourceFile -PathType Leaf)) {
        throw "missing resource: $SourceFile"
    }
    Copy-Item -LiteralPath $SourceFile -Destination (Join-Path $StagingDir "$Name-$Version.bin")
}

if (Test-Path -LiteralPath $OutputDir) {
    Remove-Item -Recurse -Force -LiteralPath $OutputDir
}
Move-Item -LiteralPath $StagingDir -Destination $OutputDir
Write-Host "resources built in $OutputDir"
