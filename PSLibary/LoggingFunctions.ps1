<#
.SYNOPSIS
Writes a log entry to a log file.

.DESCRIPTION
The Write-Log function is used to write a log entry to a log file. It creates a log file in the specified directory if it doesn't exist and appends the log entry to the file. It also deletes log files older than a specified number of days.

.PARAMETER Directory
The directory where the log file will be created.

.PARAMETER Message
The log message to be written.

.PARAMETER Component
The component name associated with the log entry.

.PARAMETER Type
The type of the log entry. Valid values are "Info", "Warning", or "Error".

.PARAMETER LogCycle
The number of days after which old log files will be deleted.

.EXAMPLE
Write-Log -Directory "C:\Logs" -Message "This is a test log entry" -Component "Powershell" -Type Info -LogCycle 30
Writes an information log entry to the log file located in "C:\Logs" directory.

.EXAMPLE
Write-Log -Directory "C:\Logs" -Message "This is a test log entry" -Component "Intune" -Type Error -LogCycle 30
Writes an error log entry to the log file located in "C:\Logs" directory.

.EXAMPLE
Write-Log -Directory "C:\Logs" -Message "This is a test log entry" -Component "M365" -Type Warning -LogCycle 30
Writes a warning log entry to the log file located in "C:\Logs" directory.

.NOTES
Author: Dennis Westerman
Date: 31 May 2024
#>

function Write-Log {
    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $true)]
        [String]$Directory,

        [parameter(Mandatory = $true)]
        [String]$Message,

        [parameter(Mandatory = $true)]
        [String]$Component,

        [Parameter(Mandatory = $true)]
        [ValidateSet("Info", "Warning", "Error")]
        [String]$Type,

        [parameter(Mandatory = $true)]
        [Int]$LogCycle
    )

    switch ($Type) {
        "Info" { [int]$Type = 1 }
        "Warning" { [int]$Type = 2 }
        "Error" { [int]$Type = 3 }
    }

    # Ensure the directory exists
    if (-not (Test-Path -Path $Directory)) {
        New-Item -Path $Directory -ItemType Directory -Force
    }

    # Generate the log file path
    $LogFilePath = Join-Path $Directory "$(Get-Date -Format yyyy-MM-dd) $($Component).log"

    # Create a log entry
    $Content = "<![LOG[$Message]LOG]!>" + `
        "<time=`"$(Get-Date -Format "HH:mm:ss.ffffff")`" " + `
        "date=`"$(Get-Date -Format "M-d-yyyy")`" " + `
        "component=`"$Component`" " + `
        "context=`"$([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)`" " + `
        "type=`"$Type`" " + `
        "thread=`"$([Threading.Thread]::CurrentThread.ManagedThreadId)`" " + `
        "file=`"`">"

    # Write the line to the log file
    Add-Content -Path $LogFilePath -Value $Content

    # Delete old log files
    $Now = Get-Date
    Get-ChildItem -Path $Directory -Filter *.log | Where-Object { ($Now - $_.LastWriteTime).Days -gt $LogCycle } | Remove-Item
}
