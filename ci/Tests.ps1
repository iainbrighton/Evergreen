<#
    .SYNOPSIS
        AppVeyor tests script.
#>
[OutputType()]
param ()

If (Get-Variable -Name projectRoot -ErrorAction SilentlyContinue) {

    # Invoke Pester tests and upload results to AppVeyor
    # Excluding download tests as this is problematic for a few reasons
    $res = Invoke-Pester -Path $tests -OutputFormat NUnitXml -OutputFile $output -PassThru -ExcludeTag "Download"
    If ($res.FailedCount -gt 0) { Throw "$($res.FailedCount) tests failed." }
    If (Test-Path -Path env:APPVEYOR_JOB_ID) {
        (New-Object 'System.Net.WebClient').UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", (Resolve-Path -Path $output))
    }
    Else {
        Write-Warning -Message "Cannot find: APPVEYOR_JOB_ID"
    }
}
Else {
    Write-Warning -Message "Required variable does not exist: projectRoot."
}

# Line break for readability in AppVeyor console
Write-Host ""
