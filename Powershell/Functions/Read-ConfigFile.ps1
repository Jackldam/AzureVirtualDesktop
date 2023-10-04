function Read-ConfigFile {
    [CmdletBinding()]
    param (
        # Path to the configuration file
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias("FullName")] # This allows Get-ChildItem's FullName property to bind to FilePath
        [ValidateNotNullOrEmpty()]
        [string]
        $FilePath
    )

    begin {
        # Check if the ConvertFrom-Yaml cmdlet is available
        if (-not (Get-Command ConvertFrom-Yaml -ErrorAction SilentlyContinue)) {
            throw "The cmdlet 'ConvertFrom-Yaml' is not available. Please ensure you have the necessary module installed."
        }
    }

    process {
        try {
            # Ensure file exists before processing
            if (-not (Test-Path -LiteralPath $FilePath -PathType Leaf)) {
                throw "File not found: $FilePath"
            }

            $hashTable = Get-Content -Path $FilePath -ErrorAction Stop | ConvertFrom-Yaml -ErrorAction Stop
            return [PSCustomObject]$hashTable

        } catch {
            # Write an error message and stop execution
            Write-Error -Message "Failed to read or convert the config file. Error: $_"
            return $null
        }
    }

    end {}
}