Function Get-CitrixEndpointManagementFeed {
    <#
        .SYNOPSIS
            Reads the public Citrix Endpoint Management feed to return an array of versions and links to download pages.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param ()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Read the feed and filter for include and exclude strings and return output to the pipeline
    $gcfParams = @{
        Uri     = $res.Get.EndpointManagement.Uri
        Include = $res.Get.EndpointManagement.Include
        Exclude = $res.Get.EndpointManagement.Exclude
    }
    $Content = Get-CitrixRssFeed @gcfParams
    If ($Null -ne $Content) {
        Write-Output -InputObject $Content
    }
}
