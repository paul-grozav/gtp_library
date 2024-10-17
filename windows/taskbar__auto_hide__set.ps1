# ============================================================================ #
# authors:
# - Tancredi-Paul Grozav <paul@grozav.info>
# ============================================================================ #
# Define the registry key path and property
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3"
$regProperty = "Settings"

# Get the current settings
$currentSettings = (Get-ItemProperty -Path $regPath -Name $regProperty).$regProperty

# Modify the 8th byte to enable auto-hide (set to 02 for auto-hide, or 03 to disable auto-hide)
$currentSettings[8] = 0x03  # Auto-hide

# Update the registry with the modified settings
Set-ItemProperty -Path $regPath -Name $regProperty -Value $currentSettings

# Restart the Explorer process to apply the change
Stop-Process -Name explorer -Force
Start-Process explorer
# ============================================================================ #
