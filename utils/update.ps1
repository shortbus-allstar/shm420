# Get the directory of the script
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Go up three levels to reach the MQNext folder
$mqNextDir = Join-Path (Split-Path -Parent $scriptDir) "..\.."

# Define relative paths based on the script's location and MQNext folder
$zipFilePath = Join-Path $mqNextDir "lua\shm420.zip"
$targetDir = Join-Path $mqNextDir "lua"
$extractDir = Join-Path $mqNextDir "lua\shm420"

# Create the target directory if it doesn't exist
if (-not (Test-Path -Path $extractDir)) {
    New-Item -ItemType Directory -Path $extractDir | Out-Null
}

# Extract contents to target directory, merge and overwrite conflicts
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($zipFilePath, $extractDir)

# Merge contents of newcontent into oldcontent
$sourceDir = Join-Path $extractDir "shm420"
$destinationDir = Join-Path $targetDir "shm420"

# Copy files and directories from newcontent into oldcontent, overwrite conflicts
Copy-Item -Path "$sourceDir\*" -Destination $destinationDir -Recurse -Force

# Remove the extra layer of shm420 directory created during extraction
$extraLayerPath = Join-Path $destinationDir "shm420"
$null = Move-Item -Path "$extraLayerPath\*" -Destination $destinationDir -Force -ErrorAction SilentlyContinue

# Remove the now empty extra layer directory
Remove-Item -Path $extraLayerPath -Force -Recurse -ErrorAction SilentlyContinue

Write-Host "Zip contents successfully merged into '$destinationDir'."


