<#Author       : Akash Chawla
# Usage        : Install Language packs
#>

#######################################
#    Install language packs           #
#######################################


[CmdletBinding()]
  Param (
        [Parameter(
            Mandatory
        )]
        [ValidateSet("Arabic (Saudi Arabia)","Bulgarian (Bulgaria)","Chinese (Simplified, China)","Chinese (Traditional, Taiwan)","Croatian (Croatia)","Czech (Czech Republic)","Danish (Denmark)","Dutch (Netherlands)", "English (United Kingdom)", "Estonian (Estonia)", "Finnish (Finland)", "French (Canada)", "French (France)", "German (Germany)", "Greek (Greece)", "Hebrew (Israel)", "Hungarian (Hungary)", "Italian (Italy)", "Japanese (Japan)", "Korean (Korea)", "Latvian (Latvia)", "Lithuanian (Lithuania)", "Norwegian, Bokmål (Norway)", "Polish (Poland)", "Portuguese (Brazil)", "Portuguese (Portugal)", "Romanian (Romania)", "Russian (Russia)", "Serbian (Latin, Serbia)", "Slovak (Slovakia)", "Slovenian (Slovenia)", "Spanish (Mexico)", "Spanish (Spain)", "Swedish (Sweden)", "Thai (Thailand)", "Turkish (Turkey)", "Ukrainian (Ukraine)", "English (Australia)", "English (United States)")]
        [System.String[]]$LanguageList
    )

function Install-LanguagePack {
  
   
    <#
    Function to install language packs along with features on demand: 
    https://learn.microsoft.com/en-gb/powershell/module/languagepackmanagement/install-language?view=windowsserver2022-ps
    #>

    BEGIN {
        
        $templateFilePathFolder = "C:\AVDImage"
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        Write-host "Starting AVD AIB Customization: Install Language packs: $((Get-Date).ToUniversalTime()) "

         # populate dictionary
         $LanguagesDictionary = @{}
         $LanguagesDictionary.Add("Dutch (Netherlands)",	"nl-NL")
         $LanguagesDictionary.Add("English (United States)",	"en-US")

         # Disable LanguageComponentsInstaller while installing language packs
         # See Bug 45044965: Installing language pack fails with error: ERROR_SHARING_VIOLATION for more details
         Disable-ScheduledTask -TaskName "\Microsoft\Windows\LanguageComponentsInstaller\Installation"
         Disable-ScheduledTask -TaskName "\Microsoft\Windows\LanguageComponentsInstaller\ReconcileLanguageResources"
    } # Begin
    PROCESS {

        foreach ($Language in $LanguageList) {

            # retry in case we hit transient errors
            for($i=1; $i -le 5; $i++) {
                 try {
                    Write-Host "*** AVD AIB CUSTOMIZER PHASE : Install language packs -  Attempt: $i ***"   
                    $LanguageCode =  $LanguagesDictionary.$Language
                    Install-Language -Language $LanguageCode -ErrorAction Stop
                    Write-Host "*** AVD AIB CUSTOMIZER PHASE : Install language packs -  Installed language $LanguageCode ***"   
                    break
                }
                catch {
                    Write-Host "*** AVD AIB CUSTOMIZER PHASE : Install language packs - Exception occurred***"
                    Write-Host $PSItem.Exception
                    continue
                }
            }
        }
    } #Process
    END {

        #Cleanup
        if ((Test-Path -Path $templateFilePathFolder -ErrorAction SilentlyContinue)) {
            Remove-Item -Path $templateFilePathFolder -Force -Recurse -ErrorAction Continue
        }

        # Enable LanguageComponentsInstaller after language packs are installed
        Enable-ScheduledTask -TaskName "\Microsoft\Windows\LanguageComponentsInstaller\Installation"
        Enable-ScheduledTask -TaskName "\Microsoft\Windows\LanguageComponentsInstaller\ReconcileLanguageResources"
        $stopwatch.Stop()
        $elapsedTime = $stopwatch.Elapsed
        Write-Host "*** AVD AIB CUSTOMIZER PHASE : Install language packs -  Exit Code: $LASTEXITCODE ***"    
        Write-Host "Ending AVD AIB Customization : Install language packs - Time taken: $elapsedTime"
    } 
}

 Install-LanguagePack -LanguageList $LanguageList

 #############
#    END    #
#############
