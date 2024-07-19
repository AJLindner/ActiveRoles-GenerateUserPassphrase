# ActiveRoles-GenerateUserPassphrase
A policy script module for Active Roles to generate a passphrase for an Active Directory user account, as an alternative to the built-in password generator. This script makes a web service call to the [EFF's large wordlist for passphrases](https://www.eff.org/files/2016/07/18/eff_large_wordlist.txt). Alternatively, you could download the file offline and use it locally instead. Documentation for the `New-RandomPassphrase` cmdlet can be found [here](https://github.com/AJLindner/Powershell-Goodies/blob/main/README.md#new-randompassphrase).

# Parameters
You can modify the following parameters when applying the script module to an Active Roles Administration Policy:
- **Delimiter** : The delimiter used to separate the randomly selected words in the passphrase.
  > Default: -
- **Number of Words** : How many words to select for the generated passphrase.
  > Default: 3
- **Number of Random Digits** : How many random numbers to append at the end of the generated passphrase.
  > Default: 3
- **Capitalize First Letter of Each Word** : Capitalizes the first letter of each word in the generated passphrase.
  > Default: True
- **Disable Manual Edit** : When set to TRUE, manually editing the password will be prohibited. Only password generation will be allowed.
  > Default: False

# Instructions
1. Create a new Powershell Policy Script Module and copy/paste the code, or import the .ps1 file as a script module.
2. Apply the script in an Administration Policy and edit the parameters as needed.
3. Apply the policy to the appropriate scope(s).
4. Be sure to _block inheritance_ of the "Built-in Policy - Password Generation" policy in the appropriate scope, or you will encounter errors.
