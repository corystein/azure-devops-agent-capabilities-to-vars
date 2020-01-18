Param(
    [string]$WorkingDirectory = $PSScriptRoot,
    [switch]$Publish,
    [string]$ACCOUNT = "",
    [string]$PUBLISHER = "",
    [string]$PAT,
    [string]$EXTENSION_NAME,
    [switch]$PublishFromFile
)


#####################################################
# Stop script on any error
#####################################################
$ErrorActionPreference = "Stop"
if ($Env:SYSTEM_DEBUG) {
    $DebugPreference = 'Continue'
    $VerbosePreference = "Continue"
}
$ProgressPreference = "SilentlyContinue"
#####################################################

##########################################################
# START : Validation
##########################################################
if ([String]::IsNullOrWhiteSpace($(Get-Command tfx -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Definition))) {
    throw "TFX CLI is missing" 
}
else {
    $(Get-Command tfx -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Definition)
    Write-Host "Found TFX CLI"
}

if (-not($PublishFromFile)) {
    if ([String]::IsNullOrWhiteSpace($(Get-Command tsc -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Definition))) {
        throw "TypeScript CLI is missing" 
    }
}

$WorkingDirectory = Resolve-Path -Path $WorkingDirectory
##########################################################
# END : Validation
##########################################################


#####################################################
# Input Parameters
#####################################################
Write-Host "Working Directory: ............. [$WorkingDirectory]"
Write-Host "Publish: ....................... [$Publish]"
if ($Publish) {
    Write-Host "Account: ....................... [$ACCOUNT]"    
    Write-Host "Publisher: ..................... [$PUBLISHER]"    
    Write-Host "Extension Name: ................ [$EXTENSION_NAME]"
}
Write-Host "Publish From File: ............. [$PublishFromFile]"
#####################################################

try {

    Push-Location -Path $WorkingDirectory

    if (-not($PublishFromFile)) {
        Push-Location -Path "../"

        ./build.ps1
        $tasks = @("get-build-definition-id")
        $tasks | ForEach-Object {
            Copy-Item -Path "*.psd1" -Destination "$WorkingDirectory/tasks/$_" -Force | Out-Null
            Copy-Item -Path "*.psm1" -Destination "$WorkingDirectory/tasks/$_" -Force | Out-Null
    
            switch ($_) {
                "get-build-definition-id" {
                    Copy-Item -Path "./Invoke-AzDO.ps1" -Destination "$WorkingDirectory/tasks/$_/powershell.ps1" -Force -Verbose
                }
            
            }    
        }
    
        Pop-Location

        #############################################
        # Build TypeScript tasks
        #############################################
        <#
        # Fix for VPN SSL issues
        npm set strict-ssl false

        $tasks = @("generate-build-info-file")
        $tasks | ForEach-Object {
            if ($PSVersionTable.PSEdition -ieq "Core") {
                Push-Location "$WorkingDirectory/tasks/$_"
            }
            else {
                # Windows
                Push-Location "$WorkingDirectory/tasks/$_"
            }
            npm install
            Write-Host "Last Exit Code: $($LASTEXITCODE)"
            tsc
            Pop-Location
        }
        #>
        #############################################

        tfx extension create --manifest-globs vss-extension.json

    }
    else {
        Write-Warning "Skipping compile of extension"
    }

    if ($Publish) {
        if (-not($PublishFromFile)) {
            Write-Host "Publish Extension..."

            tfx extension publish --manifest-globs vss-extension.json --share-with $ACCOUNT --service-url "https://marketplace.visualstudio.com/" --auth-type pat --token "$PAT" --publisher $PUBLISHER --no-prompt --trace-level
        }
        else {
            Write-Host "Publish Extension [From File]..."
            $ExtensionFile = Get-ChildItem -Filter '*.vsix' | Select-Object -First 1
            Write-Host "Extension File: $($ExtensionFile.FullName)"
            Write-Host "tfx extension publish --vsix $($ExtensionFile.FullName) --share-with $ACCOUNT --service-url `"https://marketplace.visualstudio.com/`" --auth-type pat --token `"$PAT`" --publisher $PUBLISHER --no-prompt --trace-level"
            tfx extension publish --vsix "$($ExtensionFile.FullName)" --share-with $ACCOUNT --service-url "https://marketplace.visualstudio.com/" --auth-type pat --token "$PAT" --publisher $PUBLISHER --no-prompt --trace-level
        }
        Write-Host "Last Exit Code: $LASTEXITCODE"
        if ($LASTEXITCODE -ne 0) { throw "Failure publishing extension" }
        Write-Host "Completed Publishing Extension"


        # Uninstall VSTS Extension
        Write-Host "Uninstalling Extension (if exists)..."
        $Authentication = [Text.Encoding]::ASCII.GetBytes(":$PAT")
        $Authentication = [System.Convert]::ToBase64String($Authentication)
        $Headers = @{
            Authorization = ("Basic {0}" -f $Authentication)
        }
        $Uri = "https://$ACCOUNT.extmgmt.visualstudio.com/_apis/extensionmanagement/installedextensionsbyname/$PUBLISHER/$($EXTENSION_NAME)?api-version=4.1-preview.1"
        Invoke-RestMethod -Method Delete -Uri $Uri -Headers $Headers -ContentType 'application/json'
        Write-Host "Completed Uninstalling Extension"


        # Install VSTS Extension
        Write-Host "Installing Extension..."
        $Uri = "https://{0}.visualstudio.com/" -f $ACCOUNT
        tfx extension install --service-url $Uri --auth-type pat --token "$PAT" --publisher $PUBLISHER --extension-id $EXTENSION_NAME --no-prompt --trace-level debug
        Write-Host "Completed Installing Extension"

    }

}
catch {
    throw
}
finally {
    Pop-Location
}