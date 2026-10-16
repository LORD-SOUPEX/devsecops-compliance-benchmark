<#
.SYNOPSIS
    Synchronizes build and release artifacts between directories.

.DESCRIPTION
    The Sync-Artifacts script validates source and target storage locations,
    ensures required directories exist, and copies files with robust try/catch
    error handling and structured logging.

.PARAMETER SourcePath
    The source directory containing files to synchronize.

.PARAMETER DestinationPath
    The target directory where artifacts should be deposited.

.PARAMETER FileFilter
    Optional wildcard search pattern to filter artifacts. Defaults to '*.*'.

.EXAMPLE
    .\Sync-Artifacts.ps1 -SourcePath "C:\Build\Output" -DestinationPath "\\Share\Releases" -Verbose
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(
        Mandatory = $true,
        Position = 0,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true,
        HelpMessage = 'Source path containing artifacts to copy'
    )]
    [ValidateNotNullOrEmpty()]
    [string]$SourcePath,

    [Parameter(
        Mandatory = $true,
        Position = 1,
        ValueFromPipelineByPropertyName = $true,
        HelpMessage = 'Target path where artifacts should be synchronized'
    )]
    [ValidateNotNullOrEmpty()]
    [string]$DestinationPath,

    [Parameter(Mandatory = $false)]
    [string]$FileFilter = '*.*'
)

begin {
    Write-Verbose -Message "Initializing artifact synchronization process..."
    $syncedItemsCount = 0
}

process {
    try {
        Write-Verbose -Message "Validating source directory: $SourcePath"
        if (-not (Test-Path -LiteralPath $SourcePath -PathType Container)) {
            throw [System.IO.DirectoryNotFoundException]::new("Source directory does not exist: '$SourcePath'")
        }

        Write-Verbose -Message "Checking destination directory: $DestinationPath"
        if (-not (Test-Path -LiteralPath $DestinationPath -PathType Container)) {
            if ($PSCmdlet.ShouldProcess($DestinationPath, "Create target destination directory")) {
                $null = New-Item -Path $DestinationPath -ItemType Directory -Force
                Write-Verbose -Message "Created destination directory: $DestinationPath"
            }
        }

        $sourceFiles = Get-ChildItem -LiteralPath $SourcePath -Filter $FileFilter -File -Recurse

        if ($sourceFiles.Count -eq 0) {
            Write-Verbose -Message "No files matched filter '$FileFilter' in '$SourcePath'."
            return
        }

        foreach ($file in $sourceFiles) {
            $relativePath = $file.FullName.Substring($SourcePath.TrimEnd('\', '/').Length + 1)
            $destinationFile = Join-Path -Path $DestinationPath -ChildPath $relativePath
            $destinationDir = Split-Path -Path $destinationFile -Parent

            if (-not (Test-Path -LiteralPath $destinationDir -PathType Container)) {
                $null = New-Item -Path $destinationDir -ItemType Directory -Force
            }

            if ($PSCmdlet.ShouldProcess($file.FullName, "Copy artifact to $destinationFile")) {
                Copy-Item -LiteralPath $file.FullName -Destination $destinationFile -Force
                Write-Verbose -Message "Copied: $($file.Name) -> $destinationFile"
                $syncedItemsCount++
            }
        }

        [PSCustomObject]@{
            Status          = 'Completed'
            Source          = $SourcePath
            Destination     = $DestinationPath
            FilesSynced     = $syncedItemsCount
            ExecutionTime   = [System.DateTime]::UtcNow.ToString('o')
        }
    }
    catch {
        $errorMessage = "Synchronization failure occurred: $($_.Exception.Message)"
        Write-Error -Message $errorMessage
        throw $_
    }
}

end {
    Write-Verbose -Message "Artifact synchronization completed. Total files processed: $syncedItemsCount."
}
