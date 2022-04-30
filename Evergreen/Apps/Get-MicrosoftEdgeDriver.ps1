Function Get-MicrosoftEdgeDriver {
    <#
        .SYNOPSIS
            Returns the available Microsoft Edge Driver versions and downloads.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Query for each view
    foreach ($view in $res.Get.Update.Views.GetEnumerator()) {

        # Read the JSON and convert to a PowerShell object. Return the current release version of Edge
        $updateFeed = Invoke-RestMethodWrapper -Uri "$($res.Get.Update.Uri)$($res.Get.Update.Views[$view.Key])"

        # Read the JSON and build an array of platform, channel, architecture, version
        if ($Null -ne $updateFeed) {

            foreach ($platform in $res.Get.Update.Platform) {

                # For each product (Stable, Beta etc.)
                foreach ($channel in $res.Get.Update.Channels) {

                    foreach ($architecture in $res.Get.Update.Architectures) {

                        # Sort for the latest release
                        $latestRelease = ($updateFeed | Where-Object { $_.Product -eq $channel }).Releases | `
                            Where-Object { $_.Platform -eq $platform -and $_.Architecture -eq $architecture } | `
                            Sort-Object -Property @{ Expression = { [System.Version]$_.Version }; Descending = $true } | `
                            Select-Object -First 1

                        # Create the output object/s
                        ForEach ($release in $latestRelease) {
                            If ($release.Artifacts.Count -gt 0) {
                                $PSObject = [PSCustomObject] @{
                                    Version      = $release.ProductVersion
                                    Platform     = $release.Platform
                                    Channel      = $channel
                                    #Release      = $view.Name
                                    Architecture = $release.Architecture
                                    Date         = ConvertTo-DateTime -DateTime $release.PublishedTime -Pattern $res.Get.Update.DatePattern
                                    Hash         = $(If ($release.Artifacts.Hash.Count -gt 1) { $release.Artifacts.Hash[0] } Else { $release.Artifacts.Hash })
                                    URI          = $(If ($release.Artifacts.Location.Count -gt 1) { $release.Artifacts.Location[0] } Else { $release.Artifacts.Location })
                                }

                                # Output object to the pipeline
                                Write-Output -InputObject $PSObject
                            }
                        }
                    }
                }
            }
        }
        else {
            Write-Error -Message "$($MyInvocation.MyCommand): Failed to return content from: $($res.Get.Update.Uri)$($res.Get.Update.Views[$view.Key])."
        }
    }
}
