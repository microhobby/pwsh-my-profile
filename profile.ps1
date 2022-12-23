# Copyright (c) 2020 Matheus Castello
# MicroHobby licenses this file to you under the MIT license.
# See the LICENSE file in the project root for more information.

# supress warnings that we need to use
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidOverwritingBuiltInCmdlets', ""
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingWriteHost', ""
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingInvokeExpression', ""
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingPositionalParameters', ""
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidGlobalVars', ""
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', ""
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseShouldProcessForStateChangingFunctions', ""
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseSingularNouns', ""
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingEmptyCatchBlock', ""
)]
param()

# Aliases
#Set-Alias ls /usr/bin/ls --color=auto
#Set-Alias ls Get-ChildItem
#Set-Alias code code-insiders
#Set-Alias grep "Select-String"
#Set-Alias wget Invoke-WebRequest

# lets set the powerline in this profile
Import-Module PowerLine

# aux variables
$ERRORS_COUNT = 0
$ERROR_EMOJI = "😖", "😵", "🥴", "😭", "😱", "😡", "🤬", "🙃", "🤔", "🙄", `
    "🥺", "😫", "💀", "💩", "😰"

$global:EC = 0
$global:EXIT_CODE = 0
$Global:JobTop = $null

# clear the last win32 exit code
$global:LASTEXITCODE = 0
$global:MINUS_SECTS = 4

#$global:MAIN_COLOR is the main color background for the terminal sections
$global:MAIN_COLOR = "#eeeeee"

# get from the google cloud console https://console.cloud.google.com/apis/credentials
# $GOOGLE_CONSOLE_YOUTUBE_KEY=""

$REMOTE_HOSTNAME="server"
$CASTELLO_SERVER="192.168.0.33"
$DROPLET_IP="143.198.182.128"
$env:HOSTNAME=[System.Net.Dns]::GetHostName()

function gtc () {
    git commit -vs
}

function gts () {
    git status
}

function gtd () {
    git diff
}

function gta () {
    git add $args
}

function gtca () {
    git commit --amend
}

<#
.SYNOPSIS
    git remote -v [list all the remotes in a verbose way]
#>
function gtr () {
    git remote -v
}

function gtl () {
    git log
}

function gtlo () {
    git log --oneline
}

function gtp () {
    git push $args
}

function gtpo () {
    $gitRet = git rev-parse --abbrev-ref HEAD
    git push origin $gitRet $args
}

<#
.SYNOPSIS
    git reset HEAD -- $args [reset the files in $args]
#>
function gtrs () {
    git checkout HEAD -- $args
}

<#
.SYNOPSIS
    git cherry-pick $args [LE AWESOME 🍒 PICK]
#>
function gtcp () {
    git cherry-pick $args
}

<#
.SYNOPSIS
    git checkout -b $args [Create a new branch]
#>
function gtcb () {
    git checkout -b $args
}

<#
.SYNOPSIS
    git checkout $args [Checkout to branch]
#>
function gtb () {
    git checkout $args
}

<#
.SYNOPSIS
    git branch -a [List all branches]
#>
function gtba () {
    git branch -a
}

<#
.SYNOPSIS
    git branch -d $args [Delete branch locally and remote ⚠️]
#>
function gtbd () {
    git branch -d $args
    git push origin --delete $args
}

<#
.SYNOPSIS
    git rebase -i HEAD~$args [git rebase interactive]
#>
function gtrb () {
    git rebase -i HEAD~$args
}

<#
.SYNOPSIS
    git rebase --continue
#>
function gtrbc () {
    git rebase --continue
}

<#
.SYNOPSIS
    git rebase --abort
#>
function gtrba () {
    git rebase --abort
}

<#
.SYNOPSIS
    git fetch fork
#>
function gtff () {
    git fetch fork
}

<#
.SYNOPSIS
    git rebase
#>
function gtra () {
    git rebase $args
}

<#
.SYNOPSIS
    git init
#>
function gti () {
    git init
}

<#
.SYNOPSIS
    git config --global user.signingKey
#>
function gtck () {
    $_actualKey = (git config --global user.signingKey)

    if ($_actualKey -eq "9E8404E08DA8ED75") {
        Write-Host "Setting key for matheus@castello.eng.br"
        git config --global user.signingkey 7CB84B1084E5AA77
    } else {
        Write-Host "Setting key for matheus.castello@toradex.com"
        git config --global user.signingkey 9E8404E08DA8ED75
    }
}

function exec () {
    bash -c "exec $args"
}

function export ()
{
    foreach ($arg in $args) {
        $parts=$arg.Split("=")
        $name=$parts[0]
        $value=$parts[1]
        [System.Environment]::SetEnvironmentVariable($name, $value)
    }
}

# Digital ocean droplet remote connection --------------------------------------
function droplet () {
    ssh "root@$DROPLET_IP"
}

function copy-from-droplet () {
    scp "root@${DROPLET_IP}:${args}" .
}

function copy-to-droplet () {
    scp -r $args "root@${DROPLET_IP}:/home/castello"
}

function connect-to-droplet () {
    ssh "root@$DROPLET_IP"
}

# VS Code remote connection ----------------------------------------------------

function server () {
    if ($Global:IsLinux) {
        if (-not $env:WSL_DISTRO_NAME) {
            ssh -X castello@$DELL_SERVER
        } else {
            Write-Host -BackgroundColor DarkBlue -ForegroundColor White `
                "OPENING VS CODE"

            # open the remote connection from the Windows Side
            cmd.exe /C code --remote ssh-remote+$DELL_SERVER
            Write-Host -BackgroundColor DarkYellow -ForegroundColor White `
                "VS CODE ✅"
            Start-Sleep -Seconds 3

            # open the ssh
            ssh -X castello@$DELL_SERVER
        }
    } else {
        ssh castello@$DELL_SERVER
    }
}

# in the remote we need to update the sockets in the env
if ($env:HOSTNAME -eq $REMOTE_HOSTNAME) {
    function update-vscode-env {
        $codesPaths =
            Get-ChildItem /home/castello/.vscode-server-insiders/bin/*/bin `
                | Sort-Object LastAccessTime

        $env:PATH = $codesPaths[$codesPaths.Length -1].FullName `
                        + ":" + $env:PATH

        $socketPaths =
            Get-ChildItem /run/user/1000/vscode-ipc-*.sock `
                | Sort-Object LastAccessTime

        $env:VSCODE_IPC_HOOK_CLI =
            $socketPaths[$socketPaths.Length -1].FullName
    }

    function code {
        update-vscode-env
        ~/.vscode-server/bin/*/bin/code $args
    }
} else {
    function update-vscode-env {}
}

# VS Code remote connection ----------------------------------------------------

<#
.SYNOPSIS
    dfimage -sV=1.36 nginx:latest [try to recover a dockerfile from docker image]
#>
function dfimage () {
    docker run `
        -v /var/run/docker.sock:/var/run/docker.sock `
        --rm alpine/dfimage @args
    # dfimage -sV=1.36 nginx:latest
}

function Test-CommandExists {

    Param ($command)

    $oldPreference = $ErrorActionPreference

    $ErrorActionPreference = ‘stop’

    try {if(Get-Command $command){RETURN $true}}

    Catch { RETURN $false }

    Finally {$ErrorActionPreference=$oldPreference}

}

function CustomHelp () {
    try {
        $line = $cursor = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState(
            [ref] $line,
            [ref] $cursor
        )

        $helpDesc = "No help for you today 😥"
        $helpDesc = $helpDesc.PadRight($Host.UI.RawUI.BufferSize.Width - 6, " ")

        if ($line -like "* *" -or $line -like "./*" -or $line -like ".\*") {
            ClearCustomHelp
            return
        }
        else {
            # TODO: find a way to get the man from Linux
            if ($Global:IsLinux) {
                $help = $(man -f $line 2>&1)
                if ($help -like "*nothing appropriate*" -and (Test-CommandExists($line) -eq $true)) {
                    $help = Get-Help $line
                } elseif ($help -like "*nothing appropriate*") {
                    $help = "No help for you today 😥"
                }
            } else {
                if (Test-CommandExists($line) -eq $true) {
                    $help = Get-Help $line
                }
            }
        }

        if ($null -ne $help.Synopsis -and $help.Count -le 1) {
            #$helpDesc = $line
            $help = $help.Synopsis.Trim().Replace("`n", " ")
            $help = $help.Substring(0, [System.Math]::Min($Host.UI.RawUI.BufferSize.Width - 6, $help.length))
            $help = $help.PadRight($Host.UI.RawUI.BufferSize.Width - 6, " ")
            $helpDesc = $help
        } elseif ($Global:IsLinux) {
            # man
            $help = $help.Split("`n")[0]
            $help = $help.Substring(0, [System.Math]::Min($Host.UI.RawUI.BufferSize.Width - 6, $help.length))
            $help = $help.PadRight($Host.UI.RawUI.BufferSize.Width - 6, " ")
            $helpDesc = $help
        }

        $oldPosition = $Host.UI.RawUI.CursorPosition
        $maxY = $Host.UI.RawUI.BufferSize.Height - 1
        #$maxY = $oldPosition.Y + 6
        $Host.UI.RawUI.CursorPosition = @{ X = 0; Y = $maxY }

        Write-Host `
            -ForegroundColor White `
            -BackgroundColor DarkMagenta `
            -NoNewline "🆘➡️ $helpDesc "
        $Host.UI.RawUI.CursorPosition = $oldPosition
    }
    catch {
        # do nothing
        #Write-Error $Error[0]
    }

    # we calling this between calls ignore errors
    $Error.Clear()
}

function ClearCustomHelp {
    $help = ""
    $helpDesc = $help.PadRight($Host.UI.RawUI.BufferSize.Width, " ")
    $oldPosition = $Host.UI.RawUI.CursorPosition
    $maxY = $Host.UI.RawUI.BufferSize.Height - 1
    #$maxY = $oldPosition.Y + 6
    $Host.UI.RawUI.CursorPosition = @{ X = 0; Y = $maxY }

    Write-Host `
        -NoNewline "$helpDesc"
    $Host.UI.RawUI.CursorPosition = $oldPosition

    # we calling this between calls ignore errors
    $Error.Clear()
}

# set my powerline blocks
[System.Collections.Generic.List[ScriptBlock]]$Prompt = @(
    {
        $global:EC = $Error.Count
        $global:EXIT_CODE = $global:LASTEXITCODE
    }
    #{ "`t" } # On the first line, right-justify
    # docker ps
    # {
    #     # firts block have to check the errors
    #     # check the cmdlets and win32 errors
    #     $global:EC = $error.count
    #     $global:EXIT_CODE = $global:LASTEXITCODE

    #     # count docker images and how many containers are running now
    #     $dpsc = docker images -q | Measure-Object | `
    #                 Select-Object count -ExpandProperty Count
    #     $runs = docker ps -q | Measure-Object | `
    #                 Select-Object count -ExpandProperty Count

    #     if ( $runs ) {
    #         "🐳 :: 📦 $dpsc :: ▶ $runs"
    #     } else {
    #         "🐳 :: 📦 $dpsc"
    #     }
    # }
    # git modified
    {
        $diff = git status -s -uno | Measure-Object | `
            Select-Object count -ExpandProperty Count

        if ( $diff ) {
            " 📑 > $diff "
            $Global:Prompt.Colors[0] = "#b84a1c"
        }
        else {
            "."
            $Global:Prompt.Colors[0] = "$global:MAIN_COLOR"
        }
    }
    # my current path
    {
        if ($Global:IsWindows) {
            $CPATH = $executionContext.SessionState.Path.CurrentLocation.ToString().Split("\")
            -join (" 📂 ", $CPATH[$CPATH.Count - 2], "\", $CPATH[$CPATH.Count - 1], " ")
        }
        else {
            $CPATH = $executionContext.SessionState.Path.CurrentLocation.ToString().Split("/")
            -join (" 📂 ", $CPATH[$CPATH.Count - 2], "/", $CPATH[$CPATH.Count - 1], " ")
        }
    }
    {
        "`t"
    }
    {
        if ($Global:IsWindows) {
            $versions = [System.Environment]::OSVersion.Version
            $build = $versions.Build
            "🪟 Windows Build $build"
        }
        else {
            $distro = ([String](cat /etc/issue)).Split(" ");
            $name = $distro[0]
            $version = $distro[1]
            "🐧 Linux @$name $version"
        }
    }
    {
        # try {
        #     $subs = Invoke-RestMethod `
        #             -Uri "https://www.googleapis.com/youtube/v3/channels?part=statistics&id=UC431MbbedNKuIuDBPeSCdyg&key=$GOOGLE_CONSOLE_YOUTUBE_KEY"

        #     if ($null -ne $subs.items[0].statistics.subscriberCount) {
        #         $subs = $subs.items[0].statistics.subscriberCount
        #         "🧮 ${subs} "
        #     } else {
        #         "🧮 ♾️ "
        #     }
        # } catch {
        #     "🧮 ♾️ "
        # }
        "🐕"

        $Global:Prompt.Colors[3] = "#800f55"
    }
    {
        if ($Global:IsLinux -eq $false) {
            # so we have something that is not idle
            if (($Global:JobTop -ne $null) -and ($Global:JobTop.State -eq "Completed")) {
                $topProcess = Receive-Job -Job $Global:JobTop
                Remove-Job $Global:JobTop
                $Global:JobTop = $null
                $toptop = "💤"

                foreach ($item in $topProcess) {
                    if ($item.InstanceName.Contains("idle") -or
                        $item.InstanceName.Contains("_total") -or
                        $item.InstanceName.Contains("pwsh")
                    ) {
                        # continue
                    }
                    else {
                        $toptop = $item.InstanceName
                        "⚠️ ${toptop}"
                        $Global:Prompt.Colors[4] = "#b84a1c"
                        break
                    }
                }

                if ($toptop.Contains("💤")) {
                    "💤"
                    $Global:Prompt.Colors[4] = "#187823"
                }
            }
            elseif ($Global:JobTop -eq $null) {
                $Global:JobTop = Start-Job -ScriptBlock {
                    $NumberOfLogicalProcessors = (Get-CimInstance -class Win32_processor
                        | Measure-Object -Sum NumberOfLogicalProcessors
                    ).Sum
                    $topProcess = (Get-Counter '\Process(*)\% Processor Time').Countersamples
                    | Where-Object cookedvalue -gt ($NumberOfLogicalProcessors * 5)
                    | Sort-Object cookedvalue -Desc

                    return $topProcess
                }

                "💤"
                $Global:Prompt.Colors[4] = "#187823"
            }
            else {
                "💤"
                $Global:Prompt.Colors[4] = "#187823"
            }
        } else {
            $psret = $(ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu -o '|%c;%C' | head -n 2)
            $pts = $psret.Split("`n")[1].Split("|")[1].split(";")
            $cpu = $pts[1]
            $cmd = $pts[0].Trim()

            if ([System.Double]::Parse($cpu.Trim()) -gt 30) {
                "⚠️ ${cmd}"
                $Global:Prompt.Colors[4] = "#b84a1c"
            } else {
                "💤"
                $Global:Prompt.Colors[4] = "#187823"
            }
        }
    }
    { "`n" } # Start another line
    # git branch and cmd error check
    {
        $EC = $global:EC

        # execute git to check current branch
        $gitRet = git rev-parse --abbrev-ref HEAD

        if ($EC -gt $ERRORS_COUNT -or $EXIT_CODE -ne 0) {
            $ERRORS_COUNT = $EC

            if ( $gitRet ) {
                " &#xE0A0; $gitRet "
                # not git repo and the last cmd return a error
            }
            else {
                # get a ramdom emoji
                $ERROR_EMOJI[(Get-Random -Maximum $ERROR_EMOJI.count)]
            }

            $Global:Prompt.Colors[5] = "#821616"
            $Global:Prompt.Colors[7] = "#821616"

            # not git repo and all clear
        }
        else {
            if ( $gitRet ) {
                " &#xE0A0; $gitRet "
                # not git repo and the last cmd return a error
            }
            else {
                "👌"
            }

            $Global:Prompt.Colors[5] = "#187823"
            $Global:Prompt.Colors[7] = "#187823"
        }

        # clear the errors and last exit code for the next interaction
        $Error.Clear()
        $global:LASTEXITCODE = 0
    }
    # my user name
    { " castello 🎅" }
    # pipe
    { ">" * ($nestedPromptLevel + 1) }
)

# execute
Set-PowerLinePrompt `
    -PowerLineFont `
    -SetCurrentDirectory `
    -RestoreVirtualTerminal `
    -HideError `
    -Colors "$global:MAIN_COLOR", "$global:MAIN_COLOR", "$global:MAIN_COLOR", "$global:MAIN_COLOR", "$global:MAIN_COLOR", "#187823", "#600094", "$global:MAIN_COLOR"

# maintain the "explorer ." muscle memory
if ($Global:IsLinux) {
    if (-not $env:WSL_DISTRO_NAME) {
        function explorer { dolphin $args }
        function etcher { /home/castello/bin/balenaEtcher-1.7.9-x64.AppImage --disable-gpu-sandbox }
    }
    else {
        # wsl

        <#
        .SYNOPSIS
            Call the local /usr/share/code/code instead the Windows remote one
        #>
        function codewsl {
            /usr/share/code/code $args
        }

        <#
        .SYNOPSIS
            For wsl we call the Windows Explorer interop
        #>
        function explorer { wslview $args }

        # start ssh-agent for WSL add to /etc/profile
        # eval $(ssh-agent -s)

        # add the key
        # ssh-add

        # start Xforward
        # ssh -fT castello@$CASTELLO_SERVER sleep infinity

        # free Hyper-V memory
        function freeWSL {
            sudo bash -c 'sync; echo 1 > /proc/sys/vm/drop_caches'
        }

        <#
        .SYNOPSIS
            There is no systemd on WSL so we need to start dockerd
        #>
        function runDockerd {
            sudo bash -c 'dockerd > /dev/null 2>&1 &'
        }
    }

    # linux enviroment
    # Linux environment
    # enable color support of ls and also add handy aliases
    if ( Test-Path -Path /usr/bin/dircolors ) {
        test -r ~/.dircolors && $(dircolors -b ~/.dircolors | Out-Null) || $(dircolors -b | Out-Null)

        function l {
            /usr/bin/ls --color=auto $args
        }
        #alias dir='dir --color=auto'
        #alias vdir='vdir --color=auto'

        # function grep {
        #     /usr/bin/grep --color=auto $args
        # }
        function fgrep {
            /usr/bin/fgrep --color=auto $args
        }
        function egrep {
            /usr/bin/egrep --color=auto $args
        }
    }

    # colored GCC warnings and errors
    #$env:GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

    # some more ls aliases
    function ll { ls -alF $args }
    function la { ls -A $args }
    function lcf { ls -CF $args }

    function ls ()
    {
        /usr/bin/ls --color=auto -lah $args
    }

    # bash completation?
    # Install-Module -Name "PSBashCompletions"
    function __completation ($command) {
        Register-BashArgumentCompleter "$command" /usr/share/bash-completion/completions/$command
    }

    # register on demand
    Set-PSReadLineKeyHandler -Key Spacebar -ScriptBlock {
        $line = $cursor = $null

        # get the command
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref] $line, [ref] $cursor)
        # the key handled must be outputed
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert(' ')

        # check if we have the bash complestions mathc
        try {
            __completation $line
        }
        catch {
            # nothing to do here
        }

        # we calling this between calls ignore errors
        $Error.Clear()
    }

    # x11
    # for wsl2
    #$env:LIBGL_ALWAYS_INDIRECT=1
    #$env:DISPLAY="$(egrep -m 1 nameserver /etc/resolv.conf | awk '{print $2}'):0.0"

    # set the default theme
    #$env:THEME=$(wslsys -t)
    #$env:GTK_THEME="Pop"

    #if ( $THEME -match "dark" ) {
    #    $env:GTK_THEME="Pop-dark"
    #}

    # for .net
    #$env:DOTNET_ROOT = "/usr/lib/dotnet/dotnet6-6.0.110/sdk/6.0.110/"
    #$env:DOTNET_ROOT = "$env:HOME/dotnet"
    #$env:PATH = "/home/castello/dotnet:$env:PATH"

    # NUTTX
    $env:PATH="/opt/gcc/gcc-arm-none-eabi-10-2020-q4-major/bin:$env:PATH"
    #$env:PATH = "/opt/gcc/gcc-arm-none-eabi-9-2019-q4-major/bin:$env:PATH"
    $env:PICO_SDK_PATH = "/home/castello/tmp/pico-sdk"
    $env:PATH = "/opt/gcc/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14/bin:$env:PATH"
    #$env:PATH="/opt/gcc-riscvm32/riscv32-esp-elf/bin:$PATH"

    # ESPTOOL
    $env:PATH = "/home/castello/.local/bin:$env:PATH"

    # rustup
    $env:PATH = "/home/castello/.cargo/bin:$env:PATH"

    # go
    $env:PATH = "/usr/local/go/bin:$env:PATH"

    # micronucleus
    $env:PATH="/home/castello/.arduino15/packages/digistump/tools/micronucleus/2.0a4:$env:PATH"

    # set USERPROFILE
    $env:USERPROFILE = $env:HOME

    # set NXP M4 SDK
    $env:ARMGCC_DIR="/opt/gcc/gcc-arm-none-eabi-10-2020-q4-major/"
    $env:M4_SDK_ROOT_DIR="/home/castello/tmp/colibriM4"

    # add some QT Tools
    #$env:PATH = "/usr/lib/qt6/bin/:$env:PATH"
    $env:PATH = "/home/castello/Qt/6.2.4/gcc_64/bin/:$env:PATH"
    $env:PATH = "/home/castello/Qt/Tools/QtCreator/bin/:$env:PATH"
    $env:PATH = "/home/castello/Qt/Tools/QtDesignStudio/bin/:$env:PATH"

    # for WSL x11 client side
    #$env:DISPLAY="localhost:10.0"

    # for GPG pass
    $env:GPG_TTY=$(tty)
}
else {
    # Microsoft Windows
    Set-Alias grep "Select-String"
    Set-Alias wget Invoke-WebRequest

    function explorer { explorer.exe $args }

    function Show-Notification-Warn ($title, $text) {
        Add-Type -AssemblyName System.Windows.Forms
        $global:balloon = New-Object System.Windows.Forms.NotifyIcon

        $path = (Get-Process -id $pid).Path

        $balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
        $balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning
        $balloon.BalloonTipText = "${text}"
        $balloon.BalloonTipTitle = "${title}"

        $balloon.Visible = $true
        $balloon.ShowBalloonTip(5000)
    }

    function restartAPO {
        sudo net stop audiosrv
        sudo net start audiosrv
    }

    # add QT tools to the path
    $env:Qt6_DIR="D:\\Programs\\Qt\\6.3.1\\"
    $env:PATH = "$env:PATH;D:\\Programs\\Qt\\6.3.1\\"
    $env:PATH = "$env:PATH;D:\\Programs\\Qt\\Tools\\QtDesignStudio-3.5.0-preview\\bin\\"
    $env:PATH = "$env:PATH;D:\\Programs\\Qt\\Tools\\QtCreator\\bin\\"
    $env:PATH = "$env:PATH;D:\\Programs\\Qt\\Tools\\QtDesignStudio-3.5.0-preview\\bin\\"
    $env:PATH = "$env:PATH;D:\\Programs\\Qt\\6.3.1\\mingw_64\\bin\\"
    $env:PATH = "$env:PATH;D:\\Programs\\Qt\\Tools\\mingw1120_64\\bin\\"
    $env:PATH = "$env:PATH;D:\\Programs\\Qt\\Tools\\CMake_64\\bin\\"
    $env:PATH = "$env:PATH;C:\\Program Files (x86)\\GnuPG\\bin\\"
}

# autocomplete
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key Alt+i -ScriptBlock ${function:CustomHelp}
Set-PSReadLineKeyHandler -Key Escape -ScriptBlock ${function:ClearCustomHelp}
# Autocompletion for arrow keys
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
