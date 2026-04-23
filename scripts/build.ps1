$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$source = Join-Path $repoRoot "src\boot\boot.asm"
$buildDir = Join-Path $repoRoot "build"
$image = Join-Path $buildDir "sentinel.img"

$nasmCandidates = @(
    "nasm.exe",
    "D:\msys64\mingw64\bin\nasm.exe",
    "D:\msys64\usr\bin\nasm.exe"
)

$nasm = $null
foreach ($candidate in $nasmCandidates) {
    $command = Get-Command $candidate -ErrorAction SilentlyContinue
    if ($command) {
        $nasm = $command.Source
        break
    }
}

if (-not $nasm) {
    throw "NASM was not found. Install it with MSYS2: pacman -S --needed mingw-w64-x86_64-nasm"
}

New-Item -ItemType Directory -Force -Path $buildDir | Out-Null

& $nasm -f bin $source -o $image

$size = (Get-Item $image).Length
if ($size -ne 512) {
    throw "Boot image must be exactly 512 bytes, but got $size bytes."
}

$bytes = [System.IO.File]::ReadAllBytes($image)
if ($bytes[510] -ne 0x55 -or $bytes[511] -ne 0xAA) {
    throw "Boot image is missing the BIOS 0x55AA signature."
}

Write-Host "Built $image"
Write-Host "Size: $size bytes"
Write-Host "Signature: 55 AA"
