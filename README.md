# EnvWithPowershell

This PowerShell script allows you to add or remove folders to the PATH environment variable in Windows Vista and above

## Use ADD-PATH or REMOVE-PATH accordingly

### Adding a folder

```powershell
ADD-PATH "%folder_name%"
```

### Removing a fodler

```powershell
REMOVE-PATH "%folder_name%"
```

## Versions

### Current version: 0.7

### Version history

0.1 Initial version
0.2 Bug fixes
0.3 Cosmetic fixes, automatic removal of preceding ";"
0.4 Fixed double entries
0.5 Kill Explorer and CMD processes before making any modifications
0.6 Check if folder to be removed already exists in PATH
    Escaping special characters no longer needed for the removal function
0.7 Cleaned the code and removed some syntax mismatches
    Included the sendmessage function to avoid killing the explorer task
    Used [reges]::escape() to avoid running into troubles with the path-string and -match methode
