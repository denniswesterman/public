# Define the URL and destination path
$url = "https://raw.githubusercontent.com/denniswesterman/public/main/Tools/CMTrace.exe"
$destinationPath = "C:\Win365\Tools\CMTrace.exe"
$logDirectory = "C:\Logs\DownloadLogs"

# Create the destination directory if it doesn't exist
$destinationDirectory = [System.IO.Path]::GetDirectoryName($destinationPath)
if (-not (Test-Path -Path $destinationDirectory)) {
    New-Item -Path $destinationDirectory -ItemType Directory -Force
    Write-Log -Directory $logDirectory -Message "Created directory $destinationDirectory." -Component "FileDownload" -Type Info -LogCycle 30
}

# Create the log directory if it doesn't exist
if (-not (Test-Path -Path $logDirectory)) {
    New-Item -Path $logDirectory -ItemType Directory -Force
}

# Download the file using WebClient with logging
try {
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($url, $destinationPath)
    Write-Log -Directory $logDirectory -Message "Downloaded CMTrace.exe successfully." -Component "FileDownload" -Type Info -LogCycle 30
} catch {
    Write-Log -Directory $logDirectory -Message "Failed to download CMTrace.exe: $_" -Component "FileDownload" -Type Error -LogCycle 30
    throw $_
}
