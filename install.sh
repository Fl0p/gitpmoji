#!/bin/bash

#script for installing gitpmoji. oneliner
# to run it as one liner you can use this command:
# curl -s https://raw.githubusercontent.com/Fl0p/gitpmoji/main/install.sh | bash

CURRENT_DIR=$(pwd)
echo "gitpmoji will be installed in $CURRENT_DIR"

#check if jq is installed
if ! command -v jq &> /dev/null
then
    echo "jq could not be found, installing it"
    brew install jq
fi

#download from github
curl -o prepare-commit-msg.sh https://raw.githubusercontent.com/Fl0p/gitpmoji/main/prepare-commit-msg.sh
curl -o gpt.sh https://raw.githubusercontent.com/Fl0p/gitpmoji/main/gpt.sh

#make executable
chmod +x prepare-commit-msg.sh
chmod +x gpt.sh

#check if .gitpmoji.env exists
if [ -f .gitpmoji.env ]; then
    echo ".gitpmoji.env already exists, skipping setup environment variables"
    echo "--- start of .gitpmoji.env ---"
    cat .gitpmoji.env
    echo
    echo "--- end of .gitpmoji.env ---"
else
    echo ".gitpmoji.env does not exist, creating it"
    echo "Enter your OpenAI API key (https://platform.openai.com/account/api-keys):"
    read -p "GITPMOJI_API_KEY=" api_key
    echo "Enter prefix for commit messages which will be untouched as first keyword for each message"
    echo "In format of sed RegExp use double backslash (\\\\) for escaping special symbols like {, }, ?, etc."
    read -p "GITPMOJI_PREFIX_RX=" prefix

    echo "# Your api key you can get one here https://platform.openai.com/account/api-keys" > .gitpmoji.env
    echo "GITPMOJI_API_KEY=\"$api_key\""
    echo "export GITPMOJI_API_KEY=\"$api_key\"" >> .gitpmoji.env
    echo "# Regex for sed command. emoji will be placed after it if found" >> .gitpmoji.env
    echo "GITPMOJI_PREFIX_RX=\"$prefix\""
    echo "export GITPMOJI_PREFIX_RX=\"$prefix\"" >> .gitpmoji.env
fi


echo "Add file .gitpmoji.env to .gitignore if you want to keep your API key secret"

TOP_LEVEL_GIT_DIR=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")

HOOKS_DIR="$TOP_LEVEL_GIT_DIR/.git/hooks"
echo "hooks_dir: $HOOKS_DIR"

exit 0

# Get absolute path of the hooks directory
SOURCE="$(cd "$HOOKS_DIR"; pwd)"

# Get absolute path of the current directory
TARGET="$(cd "$CURRENT_DIR"; pwd)"

relative_path() {
    local common_part="$SOURCE" # for now
    local result="" # for now

    while [[ "${TARGET#"$common_part"}" == "${TARGET}" ]]; do
        # no match, means that candidate common part is not correct
        common_part="$(dirname "$common_part")"
        result="../${result}" # move to parent dir in relative path
    done

    if [[ "$common_part" == "/" ]]; then
        # special case for root (no common path)
        result="$result/"
    fi

    # since we now have identified the common part,
    # compute the non-common part
    local forward_part="${TARGET#"$common_part"}"

    # and now stick all parts together
    result="${result}${forward_part}"
    echo "$result"
}

RELATIVE_PATH=$(relative_path "$SOURCE" "$TARGET")

# echo "RELATIVE_PATH: $RELATIVE_PATH"

cd $HOOKS_DIR
ln -s $RELATIVE_PATH/prepare-commit-msg.sh prepare-commit-msg

cd $CURRENT_DIR
echo "Git hooks installed"
echo "You can now commit with gitpmoji"
echo "To uninstall just remove $HOOKS_DIR/prepare-commit-msg"