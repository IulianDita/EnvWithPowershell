#REQUIRES -Version 3.0

<#
.SYNOPSIS
    A script to add or remove folders to %PATH%
.DESCRIPTION
    It contains 2 functions, one for adding and one for removing. It reads the registry and does the modifications there.
.NOTES
    Filename       : AddRemovePath.ps1
    Author         : Iulian Dita (iulian.dita@gmail.com)
    Prerequisite   : PowerShell V3 over Vista and upper.
#>

if (-not ("win32.nativemethods" -as [type])) {
    # import sendmessagetimeout from win32
    add-type -Namespace Win32 -Name NativeMethods -MemberDefinition @"
[DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
public static extern IntPtr SendMessageTimeout(
   IntPtr hWnd, uint Msg, UIntPtr wParam, string lParam,
   uint fuFlags, uint uTimeout, out UIntPtr lpdwResult);
"@
}
 
$HWND_BROADCAST = [intptr]0xffff;
$WM_SETTINGCHANGE = 0x1a;
$result = [uintptr]::zero
 
function global:ADD-PATH
{
    [Cmdletbinding()]
    param ( 
        [parameter(Mandatory=$True, ValueFromPipeline=$True, Position=0)] 
        [string] $Folder
    )

    # Check if a folder variable has been supplied.
    if (!$Folder -or $Folder -eq "" -or $Folder -eq $null) { 
        throw 'No Folder Supplied. $ENV:PATH Unchanged'
    }

    # Get the current search path from the environment keys in the registry.
    $oldPath=$(Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).Path
    
    # Check if the new Folder is already in the path.
    if ($oldPath | Select-String -SimpleMatch $Folder){ 
        return 'Folder already within $ENV:PATH' 
    }
	
    # Set the New Path
    $newPath=$oldPath+';'+$Folder
    Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $newPath -ErrorAction Stop
   
    # Show our results back to the world
    return 'This is the new PATH content: '+$newPath

    # Notify all windows of environment block change
    [win32.nativemethods]::SendMessageTimeout($HWND_BROADCAST, $WM_SETTINGCHANGE, [uintptr]::Zero, "Environment", 2, 5000, [ref]$result)
}

function global:REMOVE-PATH {
    [Cmdletbinding()]
    param ( 
        [parameter(Mandatory=$True, ValueFromPipeline=$True, Position=0)]
        [String] $Folder
    )

    # Check if a folder variable has been supplied.
    if (!$Folder -or $Folder -eq "" -or $Folder -eq $NULL) { 
        throw 'No Folder Supplied. $ENV:PATH Unchanged'
    }

    # Add a leading ";" if missing
    if ($Folder[0] -ne ";") {
        $Folder = ";" + $Folder;
    }

    # Get the Current Search Path from the environment keys in the registry
    $newPath=$(Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).Path
    
    # Find the value to remove, replace it with $NULL. If it's not found, nothing will change and you get a message.
    if ($newPath -match [regex]::Escape($Folder)) { 
        $newPath=$newPath -replace [regex]::Escape($Folder),$NULL 
    } else { 
        return "The folder you mentioned does not exist in the PATH environment" 
    }
    
    # Update the Environment Path
    Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $newPath -ErrorAction Stop

    # Show what we just did
    return 'This is the new PATH content: '+$newPath

    # Notify all windows of environment block change
    [win32.nativemethods]::SendMessageTimeout($HWND_BROADCAST, $WM_SETTINGCHANGE, [uintptr]::Zero, "Environment", 2, 5000, [ref]$result)
}
