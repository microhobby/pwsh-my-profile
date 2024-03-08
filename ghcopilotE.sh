#!/bin/bash

keyword=Explanation:

command=$(echo "" | gh copilot explain "$@" 2>/dev/null | grep --color=always $keyword -A999 | grep --color=always -v $keyword)
if [ -z "$command" ]; then
    #echo -e -n "\033[0;31m" # set color to red
    echo "Error from copilot"
    echo "Aborted."
    exit 1
fi

echo -e $command
