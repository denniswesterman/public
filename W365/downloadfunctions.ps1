# Define the base URL for the GitHub API and the target directory
$RepoApiUrl = 'https://api.github.com/repos/denniswesterman/public/contents/PSLibrary?ref=92a6656ba028670020480d489ada7728aaa441eb'
$LocalDirectory = 'C:\PSLibrary'

# Create the local directory if it doesn't exist
if (-not (Test-Path -Path $LocalDirectory)) {
    New-Item -Path $LocalDirectory -ItemType Directory -Force
}

# Set up headers for GitHub API request
$headers = @{
    Accept    = 'application/vnd.github.v3+json'
    UserAgent = 'PowershellScript'
}

# Get the list of files in the directory from the GitHub API
$fileList = Invoke-RestMethod -Uri $RepoApiUrl -Headers $headers

# Download each .ps1 file from the GitHub directory
foreach ($file in $fileList) {
    if ($file.name -like '*.ps1') {
        $fileUrl = $file.download_url
        $localFilePath = Join-Path $LocalDirectory $file.name
        Invoke-WebRequest -Uri $fileUrl -OutFile $localFilePath
    }
}

# Dot-source all downloaded .ps1 files
$ps1Files = Get-ChildItem -Path $LocalDirectory -Filter *.ps1
foreach ($ps1File in $ps1Files) {
    . $ps1File.FullName
}

# Load LoggingFunctions.ps1
. "C:\PSLibrary\LoggingFunctions.ps1"
# Example usage of a function from the downloaded files
$LogDirectory = 'C:\Logs\Setup'
Write-Log -Directory $LogDirectory -Message 'Downloaded and loaded all functions.' -Component 'Setup' -Type Info -LogCycle 30
