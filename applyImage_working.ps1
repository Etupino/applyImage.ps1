# Prompt for username and password
$Username = Read-Host -Prompt "Enter username"
$Password = Read-Host -Prompt "Enter password" -AsSecureString

# Convert secure string password to plain text
$SecurePassword = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
$Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($SecurePassword)

# Create diskpart script file
$DiskpartScript = @"
LIST DISK
SEL DISK 0
CLEAN
CONVERT GPT
CREATE PARTITION EFI SIZE=256
ASSIGN LETTER=S
FORMAT QUICK FS=FAT32 LABEL="EFI"
CREATE PARTITION MSR SIZE=128
CREATE PARTITION PRIMARY
ASSIGN LETTER=C
FORMAT FS=NTFS QUICK LABEL="Windows"
EXIT
"@
$DiskpartScript | Out-File -FilePath "D:\diskpartscript.txt" -Encoding ASCII

# Execute diskpart commands
Start-Process -FilePath "diskpart.exe" -ArgumentList "/s D:\diskpartscript.txt" -Wait

# Remove diskpart script file
Remove-Item "D:\diskpartscript.txt"

# Map network drive
net use * "\\config-nas03-16\archive$"  /USER:$Username $Password

# Change to the new drive 
Set-Location -Path "M:"

# Run the capture command
dism /apply-image /imagefile:"\\config-nas03-16\archive$\X-Energy\XE_Engineering\XE_Engineering_110123.wim" /applydir:C:\ /index:1

# Run the BCD boot command
bcdboot C:\Windows /s S: /f UEFI
