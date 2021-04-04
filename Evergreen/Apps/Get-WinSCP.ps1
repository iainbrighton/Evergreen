Function Get-WinSCP {
    <#
        .SYNOPSIS
            Get the current version and download URL for WinSCP.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param ()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Get latest version and download latest release via SourceForge API
    # Convert the returned release data into a useable object with Version, URI etc.
    $params = @{
        Uri          = $res.Get.Update.Uri
        Download     = $res.Get.Download
        MatchVersion = $res.Get.MatchVersion
    }
    $object = Get-SourceForgeRepoRelease @params
    Write-Output -InputObject $object
}
