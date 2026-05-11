# Start the Python backend in a new PowerShell window and then run the Flutter app.
# Run this script from the repository root:
#   .\run-full-setup.ps1

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$backendDir = Join-Path $scriptDir 'backend'
$backendScript = 'scan_network_api.py'
$pythonExe = 'python'

function Abort($message) {
    Write-Host "ERROR: $message" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $backendDir)) {
    Abort "Backend directory not found: $backendDir"
}

if (-not (Get-Command $pythonExe -ErrorAction SilentlyContinue)) {
    Abort "Python is not installed or not available in PATH."
}

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Abort "Flutter is not installed or not available in PATH."
}

Write-Host "Starting scan API backend in a new PowerShell window..." -ForegroundColor Cyan
Start-Process -FilePath 'powershell.exe' -ArgumentList @('-NoExit','-NoProfile','-Command',"Set-Location -LiteralPath '$backendDir'; $pythonExe $backendScript") -WindowStyle Normal

Write-Host "Backend should now be running in a separate window." -ForegroundColor Green
Write-Host "Installing Flutter dependencies..." -ForegroundColor Cyan
Set-Location -LiteralPath $scriptDir
flutter pub get

Write-Host "Launching Flutter app on emulator emulator-5554..." -ForegroundColor Cyan
flutter run -d emulator-5554
