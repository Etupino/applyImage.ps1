# Set the log directory and check if it exists
$logDir = "\\config-nas03-16\backup$\ImageCaptureErrorlog\capturelog"
if (!(Test-Path $logDir)) {
    # If the directory does not exist, create it
    New-Item -ItemType Directory -Force -Path $logDir
}

# Start the transcript
$ErrorActionPreference = "Continue"
$serialNumber = Get-Date -Format "yyyyMMddHHmmss"
Start-Transcript -Path "$logDir\log_$serialNumber.txt" -NoClobber -Append
#-NoClobber - if the file already exists, new data is appended to it instead of overwriting it.

# Prompt for username and password
$Username = Read-Host -Prompt "Enter username"
$Password = Read-Host -Prompt "Enter password" -AsSecureString

$serverPath = Read-Host -Prompt "sever/drive path"

$NewDrive = Read-Host -Prompt "Enter where you want to map the drive"
$accountName = Read-Host -Prompt "Enter accountName"


# Convert password to a plaintext string
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
$Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

# Map network drive
net use * $serverPath /user:$Username $Password

# Change to the new drive 
Set-Location -Path $NewDrive

# Check if the directory exists
if (!(Test-Path $accountName)) {
    # If the directory does not exist, create it
    New-Item -ItemType Directory -Force -Path $accountName
}

# Change into the new directory
Set-Location -Path $accountName

# Run the capture command
$dismCommand = 'dism /capture-image /imagefile:"' + $accountName + '.wim" /capturedir:c:\ /name:OS'
Invoke-Expression $dismCommand

# Stop the transcript
Stop-Transcript