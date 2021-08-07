# Copyright (c) 2020 Matheus Castello
# MicroHobby licenses this file to you under the MIT license.
# See the LICENSE file in the project root for more information.

# Aliases
#Set-Alias ls /usr/bin/ls --color=auto
Set-Alias ls Get-ChildItem
Set-Alias code code-insiders 
Set-Alias grep "Select-String"
#Set-Alias wget Invoke-WebRequest

function gtc ()
{
    git commit -vs
}

function gts ()
{
    git status
}

# autocomplete
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
# Autocompletion for arrow keys
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward

# lets set the powerline in this profile
Import-Module PowerLine

# aux variables
$ERRORS_COUNT = 0
$ERROR_EMOJI = "😖", "😵", "🥴", "😭", "😱", "😡", "🤬", "🙃", "🤔", "🙄", `
    "🥺", "😫", "💀", "💩", "😰"

$global:EC = 0
$global:EXIT_CODE = 0

# clear the last win32 exit code
$global:LASTEXITCODE = 0
$global:MINUS_SECTS = 1

# set my powerline blocks
[System.Collections.Generic.List[ScriptBlock]]$Prompt = @(
    {
        $global:EC = $error.count
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
            " 📑 :: $diff "
        } else {
            "."
        }
    }
    # my current path
    {
        $CPATH = $executionContext.SessionState.Path.CurrentLocation.ToString().Split("/")
        -join(" 📂 ", $CPATH[$CPATH.Count -2], "/", $CPATH[$CPATH.Count -1], " ")
    }
    { "`n" } # Start another line
    # git branch and cmd error check
    {
        $EC = $global:EC
        $ERRORS_COUNT = $global:EXIT_CODE

        # execute git to check current branch
        $gitRet = git rev-parse --abbrev-ref HEAD
        
        if ( $EC -gt $ERRORS_COUNT -or $EXIT_CODE -ne 0) {
            $ERRORS_COUNT = $EC
            
            if ( $gitRet ) {
                " &#xE0A0; $gitRet "
                $Global:Prompt.Colors[3 - $global:MINUS_SECTS] = "#303030"
            # not git repo and the last cmd return a error
            } else {
                # get a ramdom emoji
                $ERROR_EMOJI[(Get-Random -Maximum $ERROR_EMOJI.count)]
            }

            $Global:Prompt.Colors[3 - $global:MINUS_SECTS] = "Red"
            $Global:Prompt.Colors[5 - $global:MINUS_SECTS] = "Red"
        
        # not git repo and all clear
        } else {
            if ( $gitRet ) {
                " &#xE0A0; $gitRet "
                $Global:Prompt.Colors[3 - $global:MINUS_SECTS] = "#303030"
            # not git repo and the last cmd return a error
            } else {
                "👌"
            }

            $Global:Prompt.Colors[3 - $global:MINUS_SECTS] = "#303030"
            $Global:Prompt.Colors[5 - $global:MINUS_SECTS] = "#303030"
        }
        
        # clear the errors and last exit code for the next interaction
        $error.clear()
        $global:LASTEXITCODE = 0
    }
    # my user name
    { " castello 💉" }
    # pipe
    { ">" * ($nestedPromptLevel + 1) }
)

# execute
Set-PowerLinePrompt `
     -PowerLineFont `
     -SetCurrentDirectory `
     -RestoreVirtualTerminal `
     -HideError `
     -Colors "#303030", "#303030", "#02d300", "#0087ff", "#303030"

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

# bash completation?
# Install-Module -Name "PSBashCompletions"
# TODO: on demmand
function __completation ($command) {
    Register-BashArgumentCompleter "$command" /usr/share/bash-completion/completions/$command
}

# ok
Get-ChildItem /usr/share/bash-completion/completions/ | 
    Where-Object {$_.Attributes -ne "Directory"} |
    Foreach-Object { __completation "$($_.Name)" }

# for WSL code
function code-wslg {
    /usr/share/code/code $args
}

# x11
# for wsl2
#$env:LIBGL_ALWAYS_INDIRECT=1
#$env:DISPLAY="$(egrep -m 1 nameserver /etc/resolv.conf | awk '{print $2}'):0.0"
#function explorer { explorer.exe $args }

# set the default theme
#$env:THEME=$(wslsys -t)
#$env:GTK_THEME="Pop"

#if ( $THEME -match "dark" ) {
#    $env:GTK_THEME="Pop-dark"
#}

# NUTTX
#$env:PATH="/opt/gcc/gcc-arm-none-eabi-10-2020-q4-major/bin:$PATH"
$env:PATH="/opt/gcc/gcc-arm-none-eabi-9-2019-q4-major/bin:$env:PATH"
$env:PICO_SDK_PATH="/home/castello/tmp/pico-sdk"
$env:PATH="/opt/gcc/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14/bin:$env:PATH"
#$env:PATH="/opt/gcc-riscvm32/riscv32-esp-elf/bin:$PATH"

# ESPTOOL
$env:PATH="/home/castello/.local/bin:$env:PATH"

# set USERPROFILE
$env:USERPROFILE=$env:HOME

# start ssh-agent for WSL
#$(ssh-agent | Out-Null)
