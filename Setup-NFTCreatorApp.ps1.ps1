# Setup-NFTCreatorApp.ps1: A user-friendly script to create NFTs

# User-friendly formatting
function Write-Info($message) { Write-Host "[INFO] $message" -ForegroundColor Cyan }
function Write-Success($message) { Write-Host "[SUCCESS] $message" -ForegroundColor Green }
function Write-ErrorMsg($message) { Write-Host "[ERROR] $message" -ForegroundColor Red }

# Step 1: Set Target Directory
Write-Info "Test text"
$projectRoot = Read-Host "Please enter the full path to your project root (e.g., C:\Path\To\Project)"
if (-Not (Test-Path $projectRoot)) {
    Write-ErrorMsg "The specified path does not exist. Please check and run the script again."
    exit
}

# Step 2: Check for Broken Symbolic Link
$symbolicLink = Join-Path -Path $projectRoot -ChildPath "FibPlants_4"
if (Test-Path $symbolicLink) {
    $linkInfo = Get-Item $symbolicLink -ErrorAction SilentlyContinue
    if ($linkInfo.Attributes -match "ReparsePoint") {
        Write-Info "The symbolic link 'FibPlants_4' exists. Verifying its target..."
        $targetPath = $linkInfo.Target
        if (-Not (Test-Path $targetPath)) {
            Write-ErrorMsg "The symbolic link points to an invalid path: $targetPath"
            Write-Info "Removing the broken symbolic link..."
            Remove-Item -Path $symbolicLink -Force
            Write-Success "Broken symbolic link removed successfully."
        }
        else {
            Write-Success "The symbolic link is valid. Target path: $targetPath"
        }
    }
    else {
        Write-ErrorMsg "'FibPlants_4' is not a symbolic link. Exiting."
        exit
    }
}
else {
    Write-Info "The symbolic link 'FibPlants_4' does not exist."
}

# Step 3: Locate the Real Folder
Write-Info "Searching for the real 'FibPlants_4' directory..."
$realFolder = Get-ChildItem -Path $projectRoot -Recurse -Directory -Filter "FibPlants_4" -ErrorAction SilentlyContinue | Select-Object -First 1

if ($null -eq $realFolder) {
    Write-ErrorMsg "Could not find the 'FibPlants_4' directory. Please check manually."
    exit
}
else {
    Write-Success "Found the 'FibPlants_4' directory at: $($realFolder.FullName)"
}

# Step 4: Recreate Symbolic Link
Write-Info "Recreating the symbolic link..."
New-Item -Path $projectRoot -Name "FibPlants_4" -ItemType SymbolicLink -Target $realFolder.FullName -Force
Write-Success "Symbolic link recreated successfully. Target: $($realFolder.FullName)"

# Step 5: Check for setup.sh and Run It
$setupScript = Join-Path -Path $realFolder.FullName -ChildPath "setup.sh"

if (Test-Path $setupScript) {
    Write-Info "Found 'setup.sh' at: $setupScript"
    Write-Info "Running setup.sh..."
    & bash $setupScript
    if ($LASTEXITCODE -eq 0) {
        Write-Success "setup.sh executed successfully!"
    }
    else {
        Write-ErrorMsg "Error occurred while running setup.sh. Check the script for issues."
    }
}
else {
    Write-ErrorMsg "'setup.sh' not found in the 'FibPlants_4' directory."
}

Write-Info "Script execution complete. Thank you!"
