$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$image = Join-Path $repoRoot "build\sentinel.img"

if (-not (Test-Path $image)) {
    & (Join-Path $PSScriptRoot "build.ps1")
}

$qemuCandidates = @(
    "qemu-system-i386.exe",
    "D:\msys64\mingw64\bin\qemu-system-i386.exe",
    "D:\msys64\usr\bin\qemu-system-i386.exe"
)

$qemu = $null
foreach ($candidate in $qemuCandidates) {
    $command = Get-Command $candidate -ErrorAction SilentlyContinue
    if ($command) {
        $qemu = $command.Source
        break
    }
}

if (-not $qemu) {
    throw "QEMU was not found. In MSYS2 MinGW64, run: pacman -S --needed mingw-w64-x86_64-qemu"
}

& $qemu -drive "format=raw,file=$image" -boot c
