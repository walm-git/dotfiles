### THIS FILE CONTAINS COMMANDS/FUNCTIONS THAT AUTORUN IN POWERSHELL STARTUP
### USE AS A $profile FILE

# Change powershell to only show current folder and drive letter
#function prompt 
#{
#   ( get-location ).drive.name + ":\" + "...\" + $( (get-item $pwd).Parent.Name ) + "\" + $( (get-item $pwd).Name ) +" > "
#}

# Oh my posh
oh-my-posh init pwsh --config ~/dotfiles/general/oh-my-posh.toml | Invoke-Expression

# Starship Invoke
# Invoke-Expression (&starship init powershell)

# Zoxide Invoke
Invoke-Expression (& { (zoxide init powershell | Out-String) })

## Aliases

Set-Alias f fastfetch
Set-Alias wget wget2
Set-Alias py python
Set-Alias vim nvim
Set-Alias create touch
Set-Alias n notepad
Set-Alias grep rg
Set-Alias ls shortlist
Set-Alias ll longlist

## Temporary variables
# Change 'CC' to 'gcc' for Mingw compatibility with Make
$env:CC = "gcc"
$env:YAZI_FILE_ONE = "C:\Program Files\Git\usr\bin\file.exe"
$env:YAZI_CONFIG_HOME = "C:\Users\walm\AppData\Roaming\yazi"
$env:EDITOR = "code"
$env:VISUAL = "code"

## Add to PATH
$env:PATH += ";C:\Program Files\7-Zip"

## Functions
function cd...  { Set-Location ..\.. }
function cd.... { Set-Location ..\..\.. }
function .. { z .. }
function ... { z ..\.. }
function .... { z ..\..\.. }

function y {
    $tmp = [System.IO.Path]::GetTempFileName()
    yazi $args --cwd-file="$tmp"
    $cwd = Get-Content -Path $tmp
    if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
        Set-Location -LiteralPath $cwd
    }
    Remove-Item -Path $tmp
}

function shortlist {
    param (
        [string]$Path = ".",
        [int]$MinimumSpacing = 2,
        [switch]$Recurse,
        [string]$Filter,
        [string]$Exclude,
        [string]$Include,
        [switch]$Force,
        [switch]$Hide,
        [switch]$Readonly,
        [switch]$System
    )

    $items = Get-ChildItem @PSBoundParameters
    $maxNameLength = ($items | Sort-Object { $_.Name.Length } | Select-Object -Last 1).Name.Length
    $windowWidth = $host.UI.RawUI.WindowSize.Width
    $itemsPerRow = [math]::Floor( ($windowWidth - $MinimumSpacing) / ($maxNameLength + $MinimumSpacing) )
    $count = 0
    $currentFolder = ""

    foreach ($item in $items) {
        if ($Recurse -and $item.DirectoryName -ne $currentFolder) {
            Write-Host
            Write-Host
            Write-Host "Folder: $($item.DirectoryName)"
            Write-Host
            $currentFolder = $item.DirectoryName
            $count = 0
        }
        
        $itemName = $item.Name.PadRight($maxNameLength)
        if ($item.PSIsContainer) {
            Write-Host $item.Name -ForegroundColor White -BackgroundColor Blue -NoNewline
            Write-Host (" " * ($maxNameLength - $item.Name.Length)) -NoNewline
        } elseif ($item.Extension -match "\.exe$|\.bat$|\.cmd$|\.ps1$") {
            Write-Host $itemName -ForegroundColor Green -NoNewline
        } else {
            Write-Host $itemName -ForegroundColor White -NoNewline
        }

        $count++
        if ($count -ge $itemsPerRow) {
            Write-Host
            $count = 0
        } else {
            Write-Host (" " * $MinimumSpacing) -NoNewline
        }
    }

    if ($count -ne 0) {
        Write-Host
    }
}


function longlist {
    param (
        [string]$Path = ".",
        [switch]$Recurse,
        [string]$Filter,
        [string]$Exclude,
        [string]$Include,
        [switch]$Force,
        [switch]$Hide,
        [switch]$Readonly,
        [switch]$System
    )

    $items = Get-ChildItem @PSBoundParameters
    foreach ($item in $items) {
        if ($item.PSIsContainer) {
            Write-Host $item.Name -ForegroundColor White -BackgroundColor Blue -NoNewline
            Write-Host "" -NoNewline  # Reset background color
        } elseif ($item.Extension -match "\.exe$|\.bat$|\.cmd$|\.ps1$") {
            Write-Host $item.Name -ForegroundColor Green -NoNewline
        } else {
            Write-Host $item.Name -ForegroundColor White -NoNewline
        }

        Write-Host ""
    }
}

function dirs
{
    if ($args.Count -gt 0)
    {
        Get-ChildItem -Recurse -Include "$args" | Foreach-Object FullName
    }
    else
    {
        Get-ChildItem -Recurse | Foreach-Object FullName
    }
}
function admin
{
    if ($args.Count -gt 0)
    {
        $argsList = "& '" + $args + "'"
        Start-Process "$psHome\pwsh.exe" -Verb runAs -ArgumentList $argsList
    }
    else {
        Start-Process "$psHome\pwsh.exe" -Verb runAs
    }
}
function uptime
{
    $ts = (Get-Date) - (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
    $str = [string]::Format("{0} days, {1} hours, {2} minutes, {3} seconds",
        $ts.Days, $ts.Hours, $ts.Minutes, $ts.Seconds)
    $str
}
function find-file($name)
{
    Get-ChildItem -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | select-object -expandproperty fullname
}
function touch($file) 
{
    "" | Out-File $file -Encoding ASCII
}
function which($name)
{
    Get-Command $name | Select-Object -ExpandProperty Definition
}
function pkill($name)
{
    Get-Process $name -ErrorAction SilentlyContinue | Stop-Process
}
function export ($name, $value)
{
    set-item -force -path env:$name -value $value
}

## runcc - compile a C file with gcc and run it, then clean up the binary
# Usage: runcc hello.c
function runcc {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Source
    )

    # On Windows an executable needs a .exe suffix; on Unix it doesn't.
    $isWin = if ($null -ne $IsWindows) { $IsWindows } else { $true }
    $exe = if ($isWin) { 'poopy.tmp.exe' } else { 'poopy.tmp' }

    try {
        # gcc <source> -o <exe>  (only run if the compile succeeds)
        gcc $Source -o $exe
        if ($LASTEXITCODE -eq 0) {
            & "./$exe"
        }
    }
    finally {
        # rm -f poopy.tmp - always clean up, even on compile error / Ctrl-C
        Remove-Item -Force -ErrorAction SilentlyContinue $exe
    }
}


# Find out if the current user identity is elevated (has admin rights)
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal $identity
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# If so and the current host is a command line, then change to red color 
# as warning to user that they are operating in an elevated context
if (($host.Name -match "ConsoleHost") -and ($isAdmin))
{
     $host.UI.RawUI.BackgroundColor = "DarkRed"
     $host.PrivateData.ErrorBackgroundColor = "White"
     $host.PrivateData.ErrorForegroundColor = "DarkRed"
     Clear-Host
}

# We don't need these any more; they were just temporary variables to get to $isAdmin. 
# Delete them to prevent cluttering up the user profile. 
Remove-Variable identity
Remove-Variable principal
# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
## WinUtil (Chris Titus Tech) - https://christitus.com/windows-tool/
# Type:  winutil          -> stable branch
#        winutil -Dev     -> development branch
# WinUtil needs Administrator, so this relaunches it elevated automatically.
function winutil {
    [CmdletBinding()]
    param([switch]$Dev)

    $url = if ($Dev) { 'https://christitus.com/windev' } else { 'https://christitus.com/win' }
    $command = "irm $url | iex"

    $principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if ($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Invoke-Expression $command
    }
    else {
        Write-Host 'WinUtil needs Administrator - relaunching elevated...' -ForegroundColor Yellow
        Start-Process -FilePath (Get-Process -Id $PID).Path `
                      -ArgumentList '-NoExit', '-NoProfile', '-Command', $command `
                      -Verb RunAs
    }
}

