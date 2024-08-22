#!/bin/bash

# The first argument is the path to the commit message file.
COMMIT_MSG_FILE=$1
COMMIT_SOURCE=$2

# Skip the hook if this is a rebase or merge commit
if [ "$COMMIT_SOURCE" = "rebase" ] || [ -d "$(git rev-parse --git-dir)/rebase-merge" ] || [ -d "$(git rev-parse --git-dir)/rebase-apply" ]; then
    exit 0
fi

COMMIT_MSG=$(cat $COMMIT_MSG_FILE)
RESULT=$COMMIT_MSG

# Get the directory of the script, resolving symlinks
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# Check if variable starts with ~
if [[ $COMMIT_MSG == *~~~ ]]; then
    echo "The commit message ends with '~~~' It will be replaced by AI. Emoji will be added."
    COMMIT_MSG="${COMMIT_MSG%~~~}"
    RESULT=$(git diff --cached | "$SCRIPT_DIR/gpt.sh" -d -e -m "$COMMIT_MSG")
elif [[ $COMMIT_MSG == *~~ ]]; then
    echo "The commit message ends with '~~' It will be replaced by AI. Emoji will not be added."
    COMMIT_MSG="${COMMIT_MSG%~~}"
    RESULT=$(git diff --cached | "$SCRIPT_DIR/gpt.sh" -d -m "$COMMIT_MSG")
elif [[ $COMMIT_MSG == *~ ]]; then
    echo "The commit message ends with '~'. Only Emoji will be added by AI."
    COMMIT_MSG="${COMMIT_MSG%\~}"
    RESULT=$("$SCRIPT_DIR/gpt.sh" -e -m "$COMMIT_MSG")
else
    echo "The commit message does not end with '~', '~~', or '~~~'. Nothing to do."
fi

# Check if the previous command was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to generate emoji for commit message"
    exit 1
fi

echo "$RESULT"

# Overwrite the commit message file with the result
echo -e "${RESULT}" > $COMMIT_MSG_FILE

exit 0
