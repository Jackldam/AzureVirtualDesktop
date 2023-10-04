function New-KEK {
    param (
        [string]$VaultName
    )

    $AzKeyVaultKeyParams = @{
        VaultName = $VaultName
        Name      = "KEK" 
    }

    $AzKeyVaultKeyId = $(Get-AzKeyVaultKey @AzKeyVaultKeyParams).Id
    if (-not [bool]$AzKeyVaultKeyId) {
        $AzKeyVaultKeyId = $(Add-AzKeyVaultKey @AzKeyVaultKeyParams -KeyType RSA -Size 4096 -Destination Software).id
    }

    return $AzKeyVaultKeyId
}