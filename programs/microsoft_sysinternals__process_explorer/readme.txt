# ============================================================================ #
# authors:
# - Tancredi-Paul Grozav <paul@grozav.info>
# ============================================================================ #
# see: https://learn.microsoft.com/en-us/sysinternals/
# see: https://live.sysinternals.com/
# see latest version at:
#   https://learn.microsoft.com/en-us/sysinternals/downloads/process-explorer
# ============================================================================ #
version="17.06" &&
mkdir v${version} &&
cd v${version} &&
wget https://download.sysinternals.com/files/ProcessExplorer.zip &&
unzip ProcessExplorer.zip &&
true
# ============================================================================ #
