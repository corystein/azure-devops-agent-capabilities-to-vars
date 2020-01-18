Param(
    [string]$WorkingDirectory = $PSScriptRoot,
    [switch]$Publish,
    [string]$ACCOUNT = "",
    [string]$PUBLISHER = "",
    [string]$PAT,
    [string]$EXTENSION_NAME
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

if ([String]::IsNullOrWhiteSpace($(Get-Command tsc -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Definition))) {
    throw "TypeScript CLI is missing" 
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
#####################################################

try {

    Push-Location -Path $WorkingDirectory

    # Fix for VPN SSL issues
    #npm set strict-ssl false

    $taskDir = Resolve-Path -Path "$WorkingDirectory/tasks"
    Write-Host "Tasks Directory: [$taskDir]"
    Get-ChildItem -Path $taskDir -Recurse -Directory -Depth 0 | ForEach-Object {
        Write-Host "Processing task folder [$_]..."
        Push-Location $_
        npm install
        Write-Host $LASTEXITCODE
        tsc
        Pop-Location
    
    }
    Write-Host "Completed Building TypeScript"
    tfx extension create --manifest-globs extension-manifest.json


    if ($Publish) {
        Write-Host "Publish Extension..."

        tfx extension publish --manifest-globs extension-manifest.json --share-with $ACCOUNT --service-url "https://marketplace.visualstudio.com/" --auth-type pat --token "$PAT" --publisher $PUBLISHER --no-prompt --trace-level
        Write-Host "Last Exit Code: $LASTEXITCODE"
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