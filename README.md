# ActiveRoles-GenerateUserPassphrase
A policy script module for Active Roles to generate a passphrase for a user account, as an alternative to the built-in password generator.

# Instructions
1. Create a new Powershell Policy Script Module and copy/paste the code, or import the .ps1 file as a script module.
2. Apply the script in an Administration Policy and edit the parameters as needed.
3. Apply the policy to the appropriate scope(s).
4. Be sure to _block inheritance_ of the "Built-in Policy - Password Generation" policy in the appropriate scope, or you will encounter errors.
