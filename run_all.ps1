param(
    [switch]$SkipFlutter = $false
)

$projectRoot = Split-Path -Parent $PSCommandPath
$backendDir = Join-Path $projectRoot "scanner"

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "  LabNet Guardian System Startup" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[1/3] Starting Backend API Server..." -ForegroundColor Yellow
$apiJob = Start-Job -ScriptBlock {
    Set-Location $using:backendDir
    python scan_network_api.py
} -Name "LabNetAPI"

Start-Sleep -Seconds 2

Write-Host "[2/3] Waiting for API to be ready..." -ForegroundColor Yellow
$maxAttempts = 40
$apiReady = $false

for ($attempt = 0; $attempt -lt $maxAttempts; $attempt++) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:5000/api/status" -UseBasicParsing -TimeoutSec 15 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            $apiReady = $true
            Write-Host "OK: API is ready!" -ForegroundColor Green
            break
        }
    }
    catch {
        if ($attempt -lt $maxAttempts - 1) {
            Write-Host "  Waiting... ($($attempt+1)/$maxAttempts)" -ForegroundColor Gray
            Start-Sleep -Seconds 2
        }
    }
}

if (-not $apiReady) {
    Write-Host "ERROR: API failed to start" -ForegroundColor Red
    Stop-Job $apiJob
    exit 1
}

Write-Host ""

Write-Host "[3/3] Checking Flutter Configuration..." -ForegroundColor Yellow
$envPath = Join-Path $projectRoot ".env"

if (Test-Path $envPath) {
    $envContent = Get-Content $envPath
    if ($envContent -match "SCAN_API_URL") {
        Write-Host "OK: .env file configured" -ForegroundColor Green
    }
    else {
        Write-Host "Adding SCAN_API_URL to .env..." -ForegroundColor Yellow
        Add-Content $envPath "SCAN_API_URL=http://10.0.2.2:5000"
    }
}
else {
    Write-Host "Creating .env file..." -ForegroundColor Yellow
    @"
SCAN_API_URL=http://10.0.2.2:5000
"@ | Out-File -Encoding UTF8 $envPath
}

Write-Host ""
Write-Host "================================" -ForegroundColor Green
Write-Host "  SYSTEM READY" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host ""
Write-Host "API Server: http://localhost:5000" -ForegroundColor Cyan
Write-Host "  /api/devices - Device list with real speeds" -ForegroundColor Gray
Write-Host "  /api/summary - Network summary" -ForegroundColor Gray
Write-Host "  /api/alerts  - Detected anomalies" -ForegroundColor Gray
Write-Host ""

if ($SkipFlutter) {
    Write-Host "Next: Open another terminal and run:" -ForegroundColor Yellow
    Write-Host "  cd `"$projectRoot`"" -ForegroundColor White
    Write-Host "  flutter run" -ForegroundColor White
}
else {
    Write-Host "Launching Flutter in 2 seconds..." -ForegroundColor Yellow
    Start-Sleep -Seconds 2
    
    Write-Host ""
    Write-Host "Starting Flutter app..." -ForegroundColor Cyan
    Set-Location "$projectRoot"
    flutter run
}

Write-Host ""
Write-Host "Shutting down API server..." -ForegroundColor Yellow
Stop-Job $apiJob
Remove-Job $apiJob
Write-Host "Done!" -ForegroundColor Green
