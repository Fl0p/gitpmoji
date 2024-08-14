#!/bin/bash
# The first argument is the path to the commit message file.
COMMIT_MSG_FILE=$1

# Call gpt.sh with the commit message and store the result
RESULT=$(./gpt.sh "$(cat $COMMIT_MSG_FILE)")

# Check if the previous command was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to generate emoji for commit message"
    echo "$RESULT"
    exit 1
fi

# Overwrite the commit message file with the result
echo "$RESULT" > $COMMIT_MSG_FILE
