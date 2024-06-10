# Copyright (c) 2020 Matheus Castello
# MicroHobby licenses this file to you under the MIT license.
# See the LICENSE file in the project root for more information.

# to use nvm for set node you need to first run it on bash

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
Set-Alias c clear
Set-Alias grep /usr/bin/grep
#Set-Alias wget Invoke-WebRequest

# lets set the powerline in this profile
Import-Module PowerLine

# the issue that this is fixing up is already fixed on the
# build 26052 of Windows conhost
function __fixup_utf8 ([string] $str) {
    # check the size of each char
    # foreach ($char in $str) {
    #     $charSize = [System.Text.Encoding]::UTF8.GetByteCount($char)
    #     if ($charSize -gt 4) {
    #         $str = $str.Replace($char, "$char`b")
    #     }
    # }

    # return $str

    # since is fixed, do nothing
    return $str
}

# aux variables
$ERRORS_COUNT = 0
#$env:USE_EMOJI = $false
$env:_MAIN_EMOJI = "👨‍💻"
$env:_MAIN_GLIPH = __fixup_utf8 "󰨞 "
$ERROR_EMOJI = "😖", "😵", "🥴", "😭", "😱", "😡", "🤬", "🙃", "🤔", "🙄", `
    "🥺", "😫", "💀", "💩", "😰"
$ERROR_GLIPH =
    __fixup_utf8 " 󰇸 ",
    __fixup_utf8 "  ",
    __fixup_utf8 "  ",
    __fixup_utf8 "  ",
    __fixup_utf8 " 󰫜 ",
    __fixup_utf8 "  ",
    __fixup_utf8 "  ",
    __fixup_utf8 "  ",
    __fixup_utf8 " 󱅧 ",
    __fixup_utf8 " 󰱭 ",
    __fixup_utf8 " 󰯈 ",
    __fixup_utf8 " 󰱵 ",
    __fixup_utf8 "  ",
    __fixup_utf8 " 󰻖 ",
    __fixup_utf8 " 󱕽 "

if ($env:USE_EMOJI -eq $true) {
    $_MAIN_FIG = $env:_MAIN_EMOJI
    $_OK_FIG = "👌"
    $_CHECK_FIG = "✅"
    $_ERROR_FIG = "❌"
    $_WARNING_FIG = "⚠️"
    $_LINUX_FIG = "🐧"
    $_KEY_FIG = "🔑"
    $_DANGER_FIG = "🚨"
    $_FOLDER_FIG = "📂"
    $_TIME_FIG = "🕑"
    $_SOS_FIG = "🆘"
    $_ARROW_FIG = "➡️"
    $_OOPS_FIG = "😓"
    $_SLEEP_FIG = "🥱"
    $_REPO_FIG = "📑"
    $_WIN_FIG = "🪟"
    $_DOCKER_FIG = "🐳"
    $_PACKAGE_FIG = "📦"
    $_ROBOT_FIG = "🤖"
} else {
    $_MAIN_FIG = $env:_MAIN_GLIPH
    $_OK_FIG = __fixup_utf8 " 󰩐 "
    $_CHECK_FIG = __fixup_utf8 "  "
    $_ERROR_FIG = __fixup_utf8 "  "
    $_WARNING_FIG = __fixup_utf8 "  "
    $_LINUX_FIG = __fixup_utf8 "  "
    $_KEY_FIG = __fixup_utf8 "  "
    $_DANGER_FIG = __fixup_utf8 " 󰌬 "
    $_FOLDER_FIG = __fixup_utf8 "  "
    $_TIME_FIG = __fixup_utf8 "  "
    $_SOS_FIG = __fixup_utf8 " 󰘥 "
    $_ARROW_FIG = __fixup_utf8 "  "
    $_OOPS_FIG = __fixup_utf8 "  "
    $_SLEEP_FIG = __fixup_utf8 " 󰒲 "
    $_REPO_FIG = __fixup_utf8 "  "
    $_WIN_FIG = __fixup_utf8 " 󰨡 "
    $_DOCKER_FIG = __fixup_utf8 " 󰡨 "
    $_PACKAGE_FIG = __fixup_utf8 "  "
    $_ROBOT_FIG = __fixup_utf8 "󰚩 "
}

# TODO: this can be done here because we using preview
# TODO: but soon when this will be merged on the stable
# TODO: we will need a way to disable globaly
# Disable-ExperimentalFeature PSCommandNotFoundSuggestion

$global:EC = 0
$global:EXIT_CODE = 0
$Global:JobTop = $null

# clear the last win32 exit code
$global:LASTEXITCODE = 0
$global:MINUS_SECTS = 4

#$global:MAIN_COLOR is the main color background for the terminal sections
$global:MAIN_COLOR = "#ffffff"

# get from the google cloud console https://console.cloud.google.com/apis/credentials
# $GOOGLE_CONSOLE_YOUTUBE_KEY=""

$REMOTE_HOSTNAME="server"
$CASTELLO_SERVER="192.168.0.39"
$BUILD_SERVER="10.12.1.214"
$DROPLET_IP="143.198.182.128"
$env:HOSTNAME=[System.Net.Dns]::GetHostName()

function _checkCopilotInstall () {
    $_ret = Get-Command gh
    if ($null -eq $_ret) {
        Write-Host `
            -ForegroundColor Red `
            "$_ERROR_FIG GitHub CLI not found, please install it: https://docs.github.com/en/copilot/github-copilot-in-the-cli/using-github-copilot-in-the-cli#prerequisites"
        return 69
    }

    # check if the copilot is installed
    $_ret = $(gh extension list)
    if (-not $_ret.Contains("copilot")) {
        Write-Host `
            -ForegroundColor Red `
            "$_ERROR_FIG GitHub Copilot not found, please install it: https://docs.github.com/en/copilot/github-copilot-in-the-cli/using-github-copilot-in-the-cli#prerequisites"
        return 69
    }
}

function copilotExplain () {
    # first check if the github CLI installed
    if (_checkCopilotInstall -eq 69) {
        return
    }

    try {

    $line = $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState(
        [ref] $line,
        [ref] $cursor
    )
    $oldPositionOriginalPosition = $Host.UI.RawUI.CursorPosition

    # put the cursor on the bottom of the terminal
    $maxY = $Host.UI.RawUI.BufferSize.Height - 2
    #$maxY = $oldPosition.Y + 6
    $Host.UI.RawUI.CursorPosition = @{ X = 0; Y = $maxY }

    # write that the copilot is thinking
    Write-Host -NoNewline "$_ROBOT_FIG : thinking ..."


    if ($line -eq "") {
        # clean the thiking
        $Host.UI.RawUI.CursorPosition = @{ X = 0; Y = $maxY }
        Write-Host -NoNewline "                   "
        $Host.UI.RawUI.CursorPosition = $oldPositionOriginalPosition

        return
    }
    else
    {
        # make the github call only getting from Explanation: to the end
        $help= $(bash -c "export TERM=xterm-256color; resize -s $($Host.UI.RawUI.WindowSize.Height) $($Host.UI.RawUI.$Host.UI.RawUI.WindowSize.Width) > /dev/null; echo `"`" | gh copilot explain `"$($line.ToString())`" 2>/dev/null | grep `"Explanation`" -A999")

        $help = $help -split "`n" | ForEach-Object { $_ -replace "`t", '' -replace ' +$', '' } | Out-String
        # remove trailing new lines
        $help = $help.TrimEnd()

        # add color scape sequences for all the string inside ``
        $help = $help -replace '(`[^`]*`)', "`e[33m`$1`e[0m"
    }

    # clean the thiking
    $Host.UI.RawUI.CursorPosition = @{ X = 0; Y = $maxY }
    Write-Host -NoNewline "                   "
    $Host.UI.RawUI.CursorPosition = $oldPositionOriginalPosition

    # send a new line
    Write-Host ""

    # write the help
    Write-Host `
        "$help"

    # wait a any input key
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

    # put the cursor back to the line
    $Host.UI.RawUI.CursorPosition = $oldPositionOriginalPosition
    } catch {
        $Host.UI.RawUI.CursorPosition = $oldPositionOriginalPosition
    }
}

function copilot () {
    # first check if the github CLI installed
    if (_checkCopilotInstall -eq 69) {
        return
    }

    # use it
    # get args
    #$_args = $args -join " "

    # move the cursor to the bottom of the terminal
    $line = $cursor = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState(
            [ref] $line,
            [ref] $cursor
        )

    $oldPositionOriginalPosition = $Host.UI.RawUI.CursorPosition
    $oldPosition = $Host.UI.RawUI.CursorPosition
    $maxY = $Host.UI.RawUI.BufferSize.Height - 2
    #$maxY = $oldPosition.Y + 6
    $Host.UI.RawUI.CursorPosition = @{ X = 0; Y = $maxY }

    # if we are in the last line so we need to scroll the buffer
    if (
        $oldPosition.Y -ige $maxY
    ) {
        $Host.UI.WriteLine("")
        $Host.UI.WriteLine("")
        $Host.UI.WriteLine("")
        $Host.UI.WriteLine("")
        $Host.UI.WriteLine("")

        $oldPositionOriginalPosition.Y = $oldPositionOriginalPosition.Y - 4
    }

    # draw the line
    $help = ""
    $helpDesc = $help.PadRight($Host.UI.RawUI.BufferSize.Width -1, " ")
    $oldPosition = $Host.UI.RawUI.CursorPosition
    $maxY = $Host.UI.RawUI.BufferSize.Height - 2
    #$maxY = $oldPosition.Y + 6
    $Host.UI.RawUI.CursorPosition = @{ X = 0; Y = $maxY }

    Write-Host `
        -NoNewline "`e[22;38;5;15;48;2;0;0;128m $helpDesc"
    $Host.UI.RawUI.CursorPosition = @{ X = 0; Y = $maxY }

    # print the robot emoji
    # read the input
    Write-Host `
        -NoNewline "$_ROBOT_FIG : "
    $_input = Read-Host
    $_input = $_input.Trim()

    # remember the copilot that we use powershell
    $_input = "$_input"

    # get it from the gh copilot
    $_ret = $(/home/castello/projects/P/pwsh-my-profile/ghcopilot.sh "$_input")
    $_ret = $_ret.Trim()

    # unlock the colors
    Write-Host `
        -NoNewline `
        "`e[0m"

    # clean the line
    $help = ""
    $helpDesc = $help.PadRight($Host.UI.RawUI.BufferSize.Width, " ")
    $oldPosition = $Host.UI.RawUI.CursorPosition
    $maxY = $Host.UI.RawUI.BufferSize.Height - 2
    #$maxY = $oldPosition.Y + 6
    $Host.UI.RawUI.CursorPosition = @{ X = 0; Y = $maxY }

    Write-Host `
        -NoNewline "$helpDesc"
    $Host.UI.RawUI.CursorPosition = $oldPosition

    # back to the original position
    $Host.UI.RawUI.CursorPosition = $oldPositionOriginalPosition
    # add the input to the buffer
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert($_ret)
}

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
    git rebase accepting all the inconming changes
#>
function gtrtheirs () {
    git rebase -X theirs $args
}

<#
.SYNOPSIS
    git config --global user.signingKey
#>
function gtck () {
    $_actualKey = (git config --global user.signingKey)
    $Global:SIGN_EMAIL = ""

    if ($_actualKey -eq "9E8404E08DA8ED75") {
        if ($true -eq $args[0]) {
            $Global:SIGN_EMAIL = "matheus.castello@toradex.com"
        } else {
            $Global:SIGN_EMAIL = "matheus@castello.eng.br"
            Write-Host "Setting key for matheus@castello.eng.br"
            git config --global user.email "matheus@castello.eng.br"
            git config --global user.name "Matheus Castello"
            git config --global user.signingkey 7CB84B1084E5AA77
        }
    } else {
        if ($true -eq $args[0]) {
            $Global:SIGN_EMAIL = "matheus@castello.eng.br"
        } else {
            $Global:SIGN_EMAIL = "matheus.castello@toradex.com"
            Write-Host "Setting key for matheus.castello@toradex.com"
            git config --global user.email "matheus.castello@toradex.com"
            git config --global user.name "Matheus Castello"
            git config --global user.signingkey 9E8404E08DA8ED75
        }
    }
}

$Global:SIGN_EMAIL=""
$Global:IN_GIT=$false
gtck($true)

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

function connect-to-server () {
    if ($Global:IsLinux) {
        if (-not $env:WSL_DISTRO_NAME) {
            ssh -X castello@$CASTELLO_SERVER
        } else {
            Write-Host -BackgroundColor DarkBlue -ForegroundColor White `
                "OPENING VS CODE"

            # open the remote connection from the Windows Side
            cmd.exe /C code --remote ssh-remote+$CASTELLO_SERVER
            Write-Host -BackgroundColor DarkYellow -ForegroundColor White `
                "VS CODE $_CHECK_FIG"
            Start-Sleep -Seconds 3

            # open the ssh
            ssh -X castello@$CASTELLO_SERVER
        }
    } else {
        ssh castello@$CASTELLO_SERVER
    }
}

function connect-to-build-server () {
    if ($Global:IsLinux) {
        if (-not $env:WSL_DISTRO_NAME) {
            ssh -X cam@$BUILD_SERVER
        } else {
            Write-Host -BackgroundColor DarkBlue -ForegroundColor White `
                "OPENING VS CODE"

            # open the remote connection from the Windows Side
            cmd.exe /C code --remote ssh-remote+$BUILD_SERVER
            Write-Host -BackgroundColor DarkYellow -ForegroundColor White `
                "VS CODE $_CHECK_FIG"
            Start-Sleep -Seconds 3

            # open the ssh
            ssh -X cam@$BUILD_SERVER
        }
    } else {
        ssh cam@$BUILD_SERVER
    }
}

# in the remote we need to update the sockets in the env
if ($env:HOSTNAME -eq $REMOTE_HOSTNAME) {
    function update-vscode-env {
        $codesPaths =
            Get-ChildItem /home/castello/.vscode-server/bin/*/bin `
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
        ~/.vscode-server/bin/*/bin/remote-cli/code $args
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

function _recurRegistrySearch ($namespace, $results = $null, $next = -1) {
    if ($null -eq $results) {
        $results = @()
    }

    if (-1 -eq $next) {
        $_data = curl -s "https://registry.hub.docker.com/v2/repositories/${namespace}?page_size=100" `
            | ConvertFrom-Json -Depth 100
    } elseif ($null -ne $next) {
        $_data = curl -s $next `
            | ConvertFrom-Json -Depth 100
    }

    # concat the results
    if ($null -ne $_data.results) {
        $results += $_data.results
    }

    if ($null -eq $next) {
        return $results
    } else {
        return _recurRegistrySearch $namespace $results $_data.next
    }
}

function _recurTagSearch ($namespace, $image, $results = $null, $next = -1) {
    if ($null -eq $results) {
        $results = @()
    }

    if (-1 -eq $next) {
        $_data = curl -s "https://registry.hub.docker.com/v2/repositories/${namespace}/${image}/tags/?page_size=100" `
            | ConvertFrom-Json -Depth 100
    } elseif ($null -ne $next) {
        $_data = curl -s $next `
            | ConvertFrom-Json -Depth 100
    }

    # concat the results
    if ($null -ne $_data.results) {
        $results += $_data.results
    }

    if ($null -eq $next) {
        return $results
    } else {
        return _recurTagSearch $namespace $image $results $_data.next
    }
}

<#
.SYNOPSIS
    search using the Docker API the tags from a image
#>
function dockersearch (
    [string]$namespace,
    [string]$image
) {
    $_results = _recurRegistrySearch $namespace

    $_results | ForEach-Object {
        if ($_.name.ToLower().Contains($image.ToLower())) {
            Write-Host "$namespace/$($_.name):"

            $_tags = _recurTagSearch $namespace $($_.name)

            $_tags | ForEach-Object {
                Write-Host -ForegroundColor DarkYellow "`t$($_.name)"

                $_.images | ForEach-Object {
                    Write-Host -ForegroundColor DarkGreen "`t`t$($_.architecture)"
                }
            }
        }
    }
}

function Test-CommandExists {

    Param ($command)

    $oldPreference = $ErrorActionPreference

    $ErrorActionPreference = ‘stop’

    try {if(Get-Command $command){RETURN $true}}

    Catch { RETURN $false }

    Finally {$ErrorActionPreference=$oldPreference}

}

function CustomSuggestion (
    [System.Collections.Generic.List[System.Management.Automation.CommandInfo]]$_cmds
) {
    try {
        $line = $cursor = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState(
            [ref] $line,
            [ref] $cursor
        )

        $helpDesc = "No help for you today $_OOPS_FIG"
        $helpDesc = $helpDesc.PadRight($Host.UI.RawUI.BufferSize.Width - 10, " ")

        $_cmdTip = $_cmds[0].Name
        $Global:LAST_CMD = $_cmdTip
        $help = "Execute ($_cmdTip) ?"
        $help = $help.PadRight($Host.UI.RawUI.BufferSize.Width - 10, " ")
        $helpDesc = $help

        $oldPosition = $Host.UI.RawUI.CursorPosition
        $maxY = $Host.UI.RawUI.BufferSize.Height - 1
        #$maxY = $oldPosition.Y + 6
        $Host.UI.RawUI.CursorPosition = @{ X = 0; Y = $maxY }

        # if we are in the last line so we need to scroll the buffer
        if (
            $oldPosition.Y -eq $maxY
        ) {
            $Host.UI.WriteLine("")
            $Host.UI.WriteLine("")
            $Host.UI.WriteLine("")
            $oldPosition.Y = $oldPosition.Y - 3
        }

        Write-Host `
            -ForegroundColor White `
            -BackgroundColor DarkBlue `
            -NoNewline "$_SOS_FIG $_ARROW_FIG $helpDesc "
        $Host.UI.RawUI.CursorPosition = $oldPosition
    }
    catch {
        # do nothing
        #Write-Error $Error[0]
    }

    # we calling this between calls ignore errsors
    $Error.Clear()
}

function CustomHelp () {
    try {
        $line = $cursor = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState(
            [ref] $line,
            [ref] $cursor
        )

        $helpDesc = "No help for you today $_OOPS_FIG"
        $helpDesc = $helpDesc.PadRight($Host.UI.RawUI.BufferSize.Width - 10, " ")

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
                    $help = "No help for you today $_OOPS_FIG"
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
            $help = $help.Substring(0, [System.Math]::Min($Host.UI.RawUI.BufferSize.Width - 10, $help.length))
            $help = $help.PadRight($Host.UI.RawUI.BufferSize.Width - 10, " ")
            $helpDesc = $help
        } elseif ($Global:IsLinux) {
            # man
            $help = $help.Split("`n")[0]
            $help = $help.Substring(0, [System.Math]::Min($Host.UI.RawUI.BufferSize.Width - 10, $help.length))
            $help = $help.PadRight($Host.UI.RawUI.BufferSize.Width - 10, " ")
            $helpDesc = $help
        }

        $oldPosition = $Host.UI.RawUI.CursorPosition
        $maxY = $Host.UI.RawUI.BufferSize.Height - 1
        #$maxY = $oldPosition.Y + 6
        $Host.UI.RawUI.CursorPosition = @{ X = 0; Y = $maxY }

        # if we are in the last line so we need to scroll the buffer
        if (
            $oldPosition.Y -eq $maxY
        ) {
            $Host.UI.WriteLine("")
            $Host.UI.WriteLine("")
            $oldPosition.Y = $oldPosition.Y - 2
        }

        Write-Host `
            -ForegroundColor White `
            -BackgroundColor DarkMagenta `
            -NoNewline "$_SOS_FIG $_ARROW_FIG $helpDesc"

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

function AcceptCustomHelp {
    $help = ""
    $helpDesc = $help.PadRight($Host.UI.RawUI.BufferSize.Width, " ")
    $oldPosition = $Host.UI.RawUI.CursorPosition
    $maxY = $Host.UI.RawUI.BufferSize.Height - 1
    #$maxY = $oldPosition.Y + 6
    $Host.UI.RawUI.CursorPosition = @{ X = 0; Y = $maxY }

    Write-Host `
        -NoNewline "$helpDesc"
    $Host.UI.RawUI.CursorPosition = $oldPosition

    # ok now inject the command
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert($Global:LAST_CMD)

    # we calling this between calls ignore errors
    $Error.Clear()
}

# set my powerline blocks
[System.Collections.Generic.List[ScriptBlock]]$Prompt = @(
    {
        $global:EC = $Error.Count
        $global:EXIT_CODE = $global:LASTEXITCODE
    }
    # { "`t" } # On the first line, right-justify
    # # docker ps
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
    #         "$_DOCKER_FIG :: $_PACKAGE_FIG $dpsc :: ▶ $runs"
    #     } else {
    #         "$_DOCKER_FIG :: $_PACKAGE_FIG $dpsc"
    #     }
    # }
    # git modified
    {
        $diff = git status -s -uno | Measure-Object | `
            Select-Object count -ExpandProperty Count

        if ( $diff ) {
            " $_REPO_FIG > $diff "
            $Global:IN_GIT = $true
            $Global:Prompt.Colors[0] = "#b84a1c"
        }
        else {
            "."
            $Global:IN_GIT = $false
            $Global:Prompt.Colors[0] = "$global:MAIN_COLOR"
        }
    }
    # my current path
    {
        if ($Global:IsWindows) {
            $CPATH = $executionContext.SessionState.Path.CurrentLocation.ToString().Split("\")
            -join (" $_FOLDER_FIG ", $CPATH[$CPATH.Count - 2], "\", $CPATH[$CPATH.Count - 1], " ")
        }
        else {
            $CPATH = $executionContext.SessionState.Path.CurrentLocation.ToString().Split("/")
            -join (" $_FOLDER_FIG ", $CPATH[$CPATH.Count - 2], "/", $CPATH[$CPATH.Count - 1], " ")
        }
    }
    {
        "`t"
    }
    {
        if ($Global:IsWindows) {
            $versions = [System.Environment]::OSVersion.Version
            $build = $versions.Build
            "$_WIN_FIG Windows Build $build"
        }
        else {
            $distro = ([String](cat /etc/issue)).Split(" ");
            $name = $distro[0]
            $version = $distro[1]
            "$_LINUX_FIG Linux @$name $version"
        }
    }
    {
        if ($Global:IN_GIT) {
            "$_KEY_FIG $Global:SIGN_EMAIL"
        } else {
            $_time = Get-Date -Format hh:mm
            "$_TIME_FIG $_time "
        }

        $Global:Prompt.Colors[3] = "#800f55"
    }
    {
        if ($Global:IsLinux -eq $false) {
            # so we have something that is not idle
            if (($Global:JobTop -ne $null) -and ($Global:JobTop.State -eq "Completed")) {
                $topProcess = Receive-Job -Job $Global:JobTop
                Remove-Job $Global:JobTop
                $Global:JobTop = $null
                $toptop = "sleep"

                foreach ($item in $topProcess) {
                    if ($item.InstanceName.Contains("idle") -or
                        $item.InstanceName.Contains("_total") -or
                        $item.InstanceName.Contains("pwsh")
                    ) {
                        # continue
                    }
                    else {
                        $toptop = $item.InstanceName
                        "$_WARNING_FIG ${toptop}"
                        $Global:Prompt.Colors[4] = "#b84a1c"
                        break
                    }
                }

                if ($toptop.Contains("sleep")) {
                    "$_SLEEP_FIG "
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

                "$_SLEEP_FIG "
                $Global:Prompt.Colors[4] = "#187823"
            }
            else {
                "$_SLEEP_FIG "
                $Global:Prompt.Colors[4] = "#187823"
            }
        } else {
            $psret = $(ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu -o '|%c' -o ';%C' | head -n 2)
            $pts = $psret.Split("`n")[1].Split("|")[1].split(";")
            $cpu = $pts[1]
            $cmd = $pts[0].Trim()

            if ([System.Double]::Parse($cpu.Trim()) -gt 30) {
                "$_WARNING_FIG ${cmd}"
                $Global:Prompt.Colors[4] = "#b84a1c"
            } else {
                "$_SLEEP_FIG "
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
            # check if the last command was found
            $_lastCommand = (Get-History -Count 1).CommandLine;
            if (
                -not (Get-Command $_lastCommand -ErrorAction SilentlyContinue)
            ) {
                # ok, show some options
                $_commands = (
                    Get-Command `
                        -UseFuzzyMatching `
                        -FuzzyMinimumDistance 1 $_lastCommand
                )

                CustomSuggestion($_commands)
            }
        }
        else {
            if ( $gitRet ) {
                " &#xE0A0; $gitRet "
                # not git repo and the last cmd return a error
            }
            else {
                "$_OK_FIG"
            }

            $Global:Prompt.Colors[5] = "#187823"
            $Global:Prompt.Colors[7] = "#187823"
        }

        # clear the errors and last exit code for the next interaction
        $Error.Clear()
        $global:LASTEXITCODE = 0
    }
    # my user name
    { " castello $_MAIN_FIG" }
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
            Note that we are creatin the socket in /mnt/wsl
        #>
        function runDockerd {
            #dockerd > /dev/null 2>&1 &
            sudo bash -c 'dockerd -H unix:///mnt/wsl/docker.sock > /dev/null 2>&1 &'
            sudo bash -c 'ln -s /mnt/wsl/docker.sock /var/run/docker.sock'
        }

        <#
        .SYNOPSIS
            There is no systemd on WSL so we need to start local taskium
        #>
        function runTaskium {
            # start background job
            Start-Job -Name taskium -ScriptBlock {
                # start taskium
                Set-Location /home/castello/tmp/matheuscastello/taskium/taskium.Wasm/
                dotnet run
            }
        }
    }

    # linux enviroment
    # Linux environment
    # enable color support of ls and also add handy aliases
    # if ( Test-Path -Path /usr/bin/dircolors ) {
    #     test -r ~/.dircolors && $(dircolors -b ~/.dircolors | Out-Null) || $(dircolors -b | Out-Null)
    #     #alias dir='dir --color=auto'
    #     #alias vdir='vdir --color=auto'
    # }

    function l {
        /usr/bin/ls --color=auto $args
    }

    # function grop {
    #     /usr/bin/grep $args
    # }

    # function fgrep {
    #     /usr/bin/fgrep $args
    # }

    # function egrep {
    #     /usr/bin/egrep $args
    # }

    # function wget {
    #     /usr/bin/wget $args
    # }

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

    function calvus (
        [string] $image,
        [string] $cmd = "bash"
    ) {
        # we need to mount bind the pwd and also share the x11 sockets
        docker run `
            -it `
            -v /tmp/.X11-unix:/tmp/.X11-unix `
            -v /home/castello:/home/castello `
            -v /etc/passwd:/etc/passwd:ro `
            -v /etc/group:/etc/group:ro `
            -v /etc/shadow:/etc/shadow:ro `
            -v /etc/sudoers:/etc/sudoers:ro `
        # also we need to have the same UID and GID
            -e DISPLAY=$DISPLAY `
            -e USER_ID=$(id -u) `
            -e GROUP_ID=$(id -g) `
            -e USER_NAME=$env:USER `
            -e HOME=$env:HOME `
            -e TERM=xterm-256color `
            $image $cmd
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
    # $env:DOTNET_ROOT = "$env:HOME/.dotnet/"
    # $env:PATH = "/home/castello/.dotnet:$env:PATH"

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
    # $env:PATH = "/home/castello/Qt/6.2.4/gcc_64/bin/:$env:PATH"
    # $env:PATH = "/home/castello/Qt/Tools/QtCreator/bin/:$env:PATH"
    # $env:PATH = "/home/castello/Qt/Tools/QtDesignStudio/bin/:$env:PATH"

    # for WSL x11 client side
    #$env:DISPLAY="localhost:10.0"

    # add repo
    $env:PATH = "/home/castello/bin/:$env:PATH"

    # for GPG pass
    $env:GPG_TTY=$(tty)

    # for use NVIDIA with D3D12
    #$env:MESA_D3D12_DEFAULT_ADAPTER_NAME="NVIDIA"
    #$env:MESA_LOADER_DRIVER_OVERRIDE="d3d12"
    #$env:LIBVA_DRIVER_NAME="d3d12"
    #$env:EGL_PLATFORM="surfaceless"

    # fuck all this GPU shit
    $env:LIBGL_ALWAYS_SOFTWARE="1"
    #$env:MESA_LOADER_DRIVER_OVERRIDE="kms_swrast"

    # for indirect rendering
    #$env:LIBGL_ALWAYS_INDIRECT="1"

    # THE OLD CONFIG
    # # for WSL x11 client side
    # #$env:DISPLAY="localhost:10.0"

    # # add repo
    # $env:PATH = "/home/castello/bin/:$env:PATH"

    # # for GPG pass
    # $env:GPG_TTY=$(tty)

    # # for use NVIDIA with D3D12
    # $env:MESA_D3D12_DEFAULT_ADAPTER_NAME="NVIDIA"
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

    # add the rpi imager
    $env:PATH = "$env:PATH;C:\\Program Files (x86)\\Raspberry Pi Imager\\"

    # add a socket in a job
    function startSocket {
        if ($null -eq $Global:SOCKET_JOB) {
            $Global:SOCKET_JOB = Start-ThreadJob -ScriptBlock {
                function Show-Notification-Warn ($title, $text) {
                    Add-Type -AssemblyName System.Windows.Forms
                    $global:balloon.Icon = $null
                    $global:balloon.Dispose()
                    $global:balloon = New-Object System.Windows.Forms.NotifyIcon

                    $path = (Get-Process -id $pid).Path

                    $balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
                    $balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning
                    $balloon.BalloonTipText = "${text}"
                    $balloon.Text = "Socket Notification"
                    $balloon.BalloonTipTitle = "${title}"

                    # events
                    $balloon.Add_Disposed({
                        $balloon.Icon = $null
                    })

                    $balloon.Visible = $true
                    $balloon.ShowBalloonTip(5000)
                }

                $socket = New-Object System.Net.Sockets.TcpListener -ArgumentList "0.0.0.0", 9000
                Show-Notification-Warn "socket" "Starting ..."
                $socket.Start()
                Write-Output "Socket started ..."
                Show-Notification-Warn "socket" "Started ..."

                while ($true) {
                    $client = $socket.AcceptTcpClient()
                    $stream = $client.GetStream()
                    $reader = New-Object System.IO.StreamReader -ArgumentList $stream
                    $writer = New-Object System.IO.StreamWriter -ArgumentList $stream

                    while ($reader.Peek() -ge 0) {
                        $line = $reader.ReadLine()
                        Write-Output $line
                        Show-Notification-Warn "socket" $line
                        $writer.Flush()
                    }

                    $stream.Close()
                    $client.Close()
                }
            }
        }
    }
}

# autocomplete
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key Alt+i -ScriptBlock ${function:CustomHelp}
Set-PSReadLineKeyHandler -Key Escape -ScriptBlock ${function:ClearCustomHelp}
Set-PSReadLineKeyHandler -Key Alt+o -ScriptBlock ${function:AcceptCustomHelp}
Set-PSReadLineKeyHandler -Key Alt+r -ScriptBlock ${function:Copilot}
Set-PSReadLineKeyHandler -Key Alt+e -ScriptBlock ${function:CopilotExplain}
# Autocompletion for arrow keys
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
