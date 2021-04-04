Function Get-mRemoteNG {
    <#
        .SYNOPSIS
            Returns the available mRemoteNG versions.

        .NOTES
            Author: Trond Eirik Haavarstein 
            Twitter: @xenappblog
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param ()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name    

    # Pass the repo releases API URL and return a formatted object
    $params = @{
        Uri          = $res.Get.Uri
        MatchVersion = $res.Get.MatchVersion
        Filter       = $res.Get.MatchFileTypes
    }
    $object = Get-GitHubRepoRelease @params
    If ($object) {
        Write-Output -InputObject $object
    }
    Else {
        Write-Warning -Message "$($MyInvocation.MyCommand): Failed to return a usable object from the repo."
    }
}
