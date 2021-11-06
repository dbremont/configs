#!/bin/bash

# Git COMMIT-MSG hook for validating commit message
#See https://docs.google.com/document/d/1rk04jEuGfk9kYzfqCuOlPTSJw3hEDZJTBN5E5f1SALo/edit


MESSAGE=`head -n 1 "$1"`
FOOTER=`tail -n1 "$1"`

echo 
echo 
echo 'salida'
echo $MESSAGE
cat $1
echo $FOOTER
echo
echo

MAX_LENGTH=70
TYPES="chore demo docs feat fix refactor revert style test"
PATTERN="^([a-z]+)\([a-z\0-9\-\*]+\)\:\ (.*)$"
FOOTER_PATTERN="^Fix: [a-z\A-Z]+-[0-9]+$"

if [[ ${#MESSAGE} > $MAX_LENGTH ]]; then
     echo "ERROR: Commit message was ${#MESSAGE} characters long, but should be at most $MAX_LENGTH characters"
     exit 1
fi

if [[ "$MESSAGE" =~ ^WIP ]]; then
    exit 0
fi

if ! [[ "$MESSAGE" =~ $PATTERN ]]; then
    echo "ERROR: Commit message did not match 'type(scope): subject'"
    exit 1
fi

TYPE=${BASH_REMATCH[1]}

if ! [[ $TYPES =~ (^| )$TYPE($| ) ]]; then
    echo "ERROR: Commit message's type '$TYPE' must be one of '$TYPES'"
    exit 1
fi

if ! [[ "$FOOTER" =~ $FOOTER_PATTERN ]]; then
    echo "Error Footer did not match 'Fix: TEXT-NUMBER'"
    exit 1
fi

