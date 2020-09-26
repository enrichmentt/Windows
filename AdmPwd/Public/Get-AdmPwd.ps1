
function Get-AdmPwd {
    <#
    .SYNOPSIS
    Gets password localadmin from active directory and Expiration Time password
    
    .PARAMETER ComputerName
    Computer Name password getting 
    
    .PARAMETER Credential
    Username to get the password from active directory
    
    .PARAMETER DomainName
    Set domain name
    
    .EXAMPLE
    Get-AdmPwd
    
    .EXAMPLE
    Get-AdmPwd -ComputerName %ServerName1%, %ServerName2%

    .EXAMPLE
    Get-AdmPwd -ComputerName %ServerName1%, %ServerName2% -Credential %UserName%
    
    .NOTES
    v. 0.0.1
    #>
    
    [CmdletBinding()]
    param (
        [string[]]$ComputerName = $env:COMPUTERNAME,
        [PSCredential]$Credential,
        [string]$DomainName = $env:USERDOMAIN
    )

    $AdcomputerParam = @{
        Server = $DomainName
    }

    if ($PSBoundParameters.ContainsKey('Credential')) {
        $AdcomputerParam.Credential = Get-Credential $Credential
    }

    foreach ($Comp in $ComputerName) {
        $AdcomputerParam.Identity = $Comp

        # Password from Active Directory field ms-Mcs-AdmPwd and ms-Mcs-AdmPwdExpirationTime
        try {
            $ExpirationTime = ''

            $PasswordInfo = Get-ADComputer @AdcomputerParam `
                -Properties ms-Mcs-AdmPwd, ms-Mcs-AdmPwdExpirationTime  `
                -ErrorAction Stop

            $Password = $PasswordInfo.'ms-Mcs-AdmPwd'
            if (-not [string]::IsNullOrWhiteSpace($PasswordInfo.'ms-Mcs-AdmPwdExpirationTime')) {
                $ExpirationTime = [datetime]::FromFileTime($PasswordInfo.'ms-Mcs-AdmPwdExpirationTime')
            }
        }
        catch {
            throw
        }


        # Finally, create output object and return
        $LapsObject = [PSCustomObject]@{
            'ServerName' = $AdcomputerParam.Identity
            Password         = $Password
            ExpirationTime   = $ExpirationTime
        }

        $LapsObject | Add-Member -MemberType AliasProperty -Name 'ServerName    ' -Value 'ServerName'
        # Set the default display properties for the returned object
        [String[]]$DefaultProperties = 'ServerName    ', 'Password', 'ExpirationTime'

        # Create the PSStandardMembers.DefaultDisplayPropertySet member
        $ddps = New-Object Management.Automation.PSPropertySet('DefaultDisplayPropertySet', $DefaultProperties)

        # Attach default display property set and output object
        $PSStandardMembers = [Management.Automation.PSMemberInfo[]]$ddps 
        $LapsObject | Add-Member -MemberType MemberSet -Name PSStandardMembers -Value $PSStandardMembers -PassThru
    }
}