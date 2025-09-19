param (
    [string]$Action
)

# Debug log
$DebugLog = "C:\Program Files (x86)\ossec-agent\active-response\quarantine-debug.log"
Add-Content $DebugLog ("[$(Get-Date)] quarantine-host.ps1 invoked with action: $Action")

# Firewall rule names
$RuleAllowManager = "Wazuh-Quarantine-Allow-Manager"
$RuleBlockAll     = "Wazuh-Quarantine-Block-All"
$WazuhManagerIP   = "IP_WAZUH"

try {
    if ($Action -eq "add") {
        # Allow Wazuh manager outbound
        netsh advfirewall firewall add rule name=$RuleAllowManager dir=out action=allow remoteip=$WazuhManagerIP protocol=TCP
        # Block everything else outbound
        netsh advfirewall firewall add rule name=$RuleBlockAll dir=out action=block
        Add-Content $DebugLog ("[$(Get-Date)] Quarantine applied successfully")
    }
    elseif ($Action -eq "delete") {
        netsh advfirewall firewall delete rule name=$RuleBlockAll
        netsh advfirewall firewall delete rule name=$RuleAllowManager
        Add-Content $DebugLog ("[$(Get-Date)] Quarantine removed successfully")
    }
    else {
        Add-Content $DebugLog ("[$(Get-Date)] Invalid action. Use add|delete")
    }
} catch {
    Add-Content $DebugLog ("[$(Get-Date)] ERROR: $_")
}
