#!/bin/bash

keyword=Suggestion:

command=$(echo "" | gh copilot suggest -t shell "$@" 2>/dev/null | grep $keyword -A2 | grep -v $keyword)
if [ -z "$command" ]; then
    #echo -e -n "\033[0;31m" # set color to red
    echo "Error from copilot"
    echo "Aborted."
    exit 1
fi

echo $command
