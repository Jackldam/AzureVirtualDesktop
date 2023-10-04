function New-ResourceName {
    <#
.SYNOPSIS
    Generates standardized Azure resource names.
.DESCRIPTION
    This function takes workload, application, location, environment, and resource type as inputs and returns a standardized name for Azure resources.
.NOTES
    Ensure the final resource name adheres to the specific Azure resource naming limitations.
.EXAMPLE
    New-ResourceName -Workload "AVD" -Application "SharedResources" -Location "westeurope" -Environment "Production" -ResourceType "ApplicationGroup"
    Returns: avd-sharedresources-we-p-ap
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Workload,

        [Parameter(Mandatory = $true)]
        [string]
        $Application,

        [Parameter(Mandatory = $true)]
        [ValidateSet("westeurope", "northeurope", "eastus", "westus")] # Add more locations as needed
        [string]
        $Location,

        [Parameter(Mandatory = $true)]
        [ValidateSet("Development", "Testing", "Acceptance", "Production")]
        [string]
        $Environment,

        [Parameter(Mandatory = $true)]
        [ValidateSet("ApplicationGroup", "Keyvault", "ResourceGroup")]
        [string]
        $ResourceType
    )

    $LocationMapping = @{
        "westeurope"  = "we";
        "northeurope" = "ne";
        "eastus"      = "eu";
        "westus"      = "wu";
    }

    $EnvironmentMapping = @{
        "Development" = "d";
        "Testing"     = "t";
        "Acceptance"  = "a";
        "Production"  = "p";
    }

    $List = @(
        , $Workload.ToLower()
        , $Application.ToLower()
        , $LocationMapping[$Location]
        , $EnvironmentMapping[$Environment].ToLower()
    )

    $resourceName = switch ($ResourceType) {
        "ApplicationGroup" { "{0}-{1}-{2}-{3}-ap" -f $List }
        "Keyvault" { "{0}-{1}-{2}-{3}-kv" -f $List }
        "ResourceGroup" { "{0}-{1}-{2}-{3}-rg" -f $List }
        default { 
            Write-Error "Unsupported ResourceType: $ResourceType"
            return
        }
    }

    if ($resourceName.Length -gt 24) {
        throw "Resource name [$resourceName] exceeds the maximum length by $($resourceName.Length - 24) characters."
    }

    return $resourceName
}
