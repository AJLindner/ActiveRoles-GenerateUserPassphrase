function onInit($Context)
{
    # Create script parameters to be configured via the policy object.   
    $var1 = $Context.AddParameter("Delimiter")
    $var1.Required = $true
    $var1.DefaultValue = "-"
    $var1.Description = "The delimiter used to separate the randomly selected words in the passphrase."
    
    $var2 = $Context.AddParameter("Number of Words")
    $var2.Required = $true
    $var2.Syntax = "int"
    $var2.DefaultValue = 3
    $var2.Description = "How many words to select for the generated passphrase."
    
    $var3 = $Context.AddParameter("Number of Random Digits")
    $var3.Required = $true
    $var3.Syntax = "int"
    $var3.DefaultValue = 3
    $var3.Description = "How many random numbers to append at the end of the generated passphrase."
    
    $var4 = $Context.AddParameter("Capitalize First Letter of Each Word")
    $var4.Required = $true
    $var4.Syntax = "boolean"
    $var4.PossibleValues = @($true,$false)
    $var4.DefaultValue = $true
    $var4.Description = "Capitalizes the first letter of each word in the generated passphrase."
    
    $var5 = $Context.AddParameter("Disable Manual Edit")
    $var5.Required = $true
    $var5.Syntax = "boolean"
    $var5.PossibleValues = @($true,$false)
    $var5.DefaultValue = $false
    $Var5.Description = "When set to TRUE, manually editing the password will be prohibited. Only password generation will be allowed. `n`nDefault Value:`nFALSE"

}

function New-RandomPassphrase {

    [cmdletbinding()]
    param( 
        [Parameter(Mandatory = $false, position = 0)]
        [string[]]
        $Words = (Invoke-RestMethod -Uri "https://www.eff.org/files/2016/07/18/eff_large_wordlist.txt" -Method Get | ConvertFrom-Csv -Delimiter "`t" -Header "id","word" | Select-Object -ExpandProperty Word),
    
        [Parameter(Mandatory = $false, position = 1)]
        [string]
        $Delimiter = "-",

        [Parameter(Mandatory = $false, position = 2)]
        [int]
        $WordCount = 3,

        [Parameter(Mandatory = $false, position = 3)]
        [int]
        $DigitCount = 0,

        [Parameter(Mandatory = $false, position = 4)]
        [switch]
        $Capitalize,

        [Parameter(Mandatory = $false, position = 5)]
        [switch]
        $AsSecureString

    )

    $PassphraseSegments = New-Object System.Collections.ArrayList

    1..$WordCount | ForEach-Object {
        do {
            $Word = $Words | Get-Random
        } until (
            $Word -notin $PassphraseSegments
        )

        if ($Capitalize) {
            $Word = $word.substring(0,1).ToUpper() + $word.substring(1).ToLower()
        }

        $PassphraseSegments.Add($word) | Out-Null
    }

    if ($DigitCount -gt 0) {
        $Number = (1..$DigitCount | ForEach-Object {
            0..9 | Get-Random
        }) -join ""

        $PassphraseSegments.Add($Number) | Out-Null
    }

    $Passphrase = $PassphraseSegments -join $Delimiter

    if ($AsSecureString) {
        $Passphrase = $Passphrase  | ConvertTo-SecureString -AsPlainText -Force
    }

    return $Passphrase

}

function onGetEffectivePolicy($Request)
{
    if ($Request.Class -ne "user" -and $Request.Class -ne "inetOrgPerson"){
        return
    }
    
    $PassphraseParams = @{
        Delimiter = $Context.Parameter("Delimiter")
        WordCount = $Context.Parameter("Number of Words")
        DigitCount = $Context.Parameter("Number of Random Digits")
        Capitalize = [boolean]$Context.Parameter("Capitalize First Letter of Each Word")
    }
    
    $DisableManualEdit = $Context.Parameter("Disable Manual Edit")

    # Mark password as server-side generated.
    $Request.SetEffectivePolicyInfo("edsaPassword", $Constants.EDS_EPI_UI_SERVER_SIDE_GENERATED, $true)

    if ($DisableManualEdit -eq $true){
        $Request.SetEffectivePolicyInfo("edsaPassword", $Constants.EDS_EPI_UI_AUTO_GENERATED, $true)
    }
    
    $Passphrase = New-RandomPassphrase @PassphraseParams
   
    # Set password value in form.
    $Request.SetEffectivePolicyInfo("edsaPassword", $Constants.EDS_EPI_UI_GENERATED_VALUE, $Passphrase)
}