#!/bin/bash
# The first argument is the path to the commit message file.
COMMIT_MSG_FILE=$1
COMMIT_SOURCE=$2

# Skip the hook if this is a rebase or merge commit
if [ "$COMMIT_SOURCE" = "rebase" ] || [ -d "$(git rev-parse --git-dir)/rebase-merge" ] || [ -d "$(git rev-parse --git-dir)/rebase-apply" ]; then
    exit 0
fi

# Call gpt.sh with the commit message and store the result
# Get the directory of the script, resolving symlinks
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
RESULT=$("$SCRIPT_DIR/gpt.sh" "$(cat $COMMIT_MSG_FILE)")

# Check if the previous command was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to generate emoji for commit message"
    echo "$RESULT"
    exit 1
fi

# Overwrite the commit message file with the result
echo "$RESULT" > $COMMIT_MSG_FILE
