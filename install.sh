#!/bin/bash

#script for installing gitpmoji. oneliner
# to run it as one liner you can use this command:
# curl -s https://raw.githubusercontent.com/Fl0p/gitpmoji/main/install.sh | bash

CURRENT_DIR=$(pwd)

#check if jq is installed
if ! command -v jq &> /dev/null
then
    echo "jq could not be found, installing it"
    brew install jq
fi

echo "Current dir: $CURRENT_DIR"

TOP_LEVEL_GIT_DIR=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")

echo "Top level project dir: $TOP_LEVEL_GIT_DIR"
ls -la $TOP_LEVEL_GIT_DIR

echo "Enter dir name where gitpmoji scripts will be installed. use '.' for current dir. just press enter for default 'gitpmoji'"
read -p "GITPMOJI_DIR=" GITPMOJI_DIR

if [ -z "$GITPMOJI_DIR" ]; then
    GITPMOJI_DIR="gitpmoji"
fi

GITPMOJI_INSTALL_DIR="$TOP_LEVEL_GIT_DIR/$GITPMOJI_DIR"
echo "gitpmoji will be installed in $GITPMOJI_INSTALL_DIR"

mkdir -p $GITPMOJI_INSTALL_DIR
cd $GITPMOJI_INSTALL_DIR
pwd

#download from github
curl -o prepare-commit-msg.sh https://raw.githubusercontent.com/Fl0p/gitpmoji/main/prepare-commit-msg.sh
curl -o gpt.sh https://raw.githubusercontent.com/Fl0p/gitpmoji/main/gpt.sh

#make executable
chmod +x prepare-commit-msg.sh
chmod +x gpt.sh

echo "Do you want to add '$GITPMOJI_DIR' directory to gitignore?  (y/n)"
read GITPMOJI_ADD_TO_GITIGNORE

if [ "$GITPMOJI_ADD_TO_GITIGNORE" = "y" ]; then
    echo "" >> $TOP_LEVEL_GIT_DIR/.gitignore
    echo "# ignore gitpmoji directory" >> $TOP_LEVEL_GIT_DIR/.gitignore
    echo "$GITPMOJI_DIR" >> $TOP_LEVEL_GIT_DIR/.gitignore
fi

#check if .gitpmoji.env exists
if [ -f .gitpmoji.env ]; then
    echo "$GITPMOJI_DIR/.gitpmoji.env already exists, skipping setup environment variables"
    echo "--- start of .gitpmoji.env ---"
    cat .gitpmoji.env
    echo "--- end of .gitpmoji.env ---"
else
    echo ".gitpmoji.env does not exist, creating it"
    echo "Enter your OpenAI API key (https://platform.openai.com/account/api-keys):"
    read -p "GITPMOJI_API_KEY=" api_key
    echo "Enter prefix for commit messages which will be untouched as first keyword for each message"
    echo "In format of sed RegExp use double backslash (\\\\) for escaping special symbols like {, }, ?, etc."
    read -p "GITPMOJI_PREFIX_RX=" prefix
    echo "Enter base url for OpenAI API (leave empty for default 'https://api.openai.com/v1')"
    read -p "GITPMOJI_API_BASE_URL=" base_url
    if [ -z "$base_url" ]; then
        base_url="https://api.openai.com/v1"
    fi
    echo "Enter model for OpenAI API (leave empty for default 'gpt-4o')"
    read -p "GITPMOJI_API_MODEL=" model
    if [ -z "$model" ]; then
        model="gpt-4o"
    fi

    echo "GITPMOJI_API_KEY=\"$api_key\""
    echo "GITPMOJI_PREFIX_RX=\"$prefix\""
    echo "GITPMOJI_API_BASE_URL=\"$base_url\""
    echo "GITPMOJI_API_MODEL=\"$model\""
    
    cat << EOF > .gitpmoji.env
# Your api key you can get one here https://platform.openai.com/account/api-keys
export GITPMOJI_API_KEY="$api_key"
# Regex for sed command. emoji will be placed after it if found
export GITPMOJI_PREFIX_RX="$prefix"
export GITPMOJI_API_BASE_URL="$base_url"
export GITPMOJI_API_MODEL="$model"
EOF
fi

if [ "$GITPMOJI_ADD_TO_GITIGNORE" != "y" ]; then
    echo -e "\033[0;31m Do you want to add environment file '$GITPMOJI_DIR/.gitpmoji.env' to .gitignore to keep your API key secret? (y/n)\033[0m"    
    read GITPMOJI_ADD_ENV_TO_GITIGNORE
    if [ "$GITPMOJI_ADD_ENV_TO_GITIGNORE" = "y" ]; then
        echo "" >> $TOP_LEVEL_GIT_DIR/.gitignore
        echo "# ignore environment file for gitpmoji" >> $TOP_LEVEL_GIT_DIR/.gitignore
        echo "$GITPMOJI_DIR/.gitpmoji.env" >> $TOP_LEVEL_GIT_DIR/.gitignore
    fi
fi

cd $TOP_LEVEL_GIT_DIR

echo "Gitpmoji files installed in: $GITPMOJI_INSTALL_DIR"


HOOKS_DIR="$TOP_LEVEL_GIT_DIR/.git/hooks"
echo "git hooks dir: $HOOKS_DIR"

echo "Going to install git hook for prepare-commit-msg"

relative_path() {
    local common_part="$1" # for now
    local result="." # for now

    while [[ "${2#"$common_part"}" == "${2}" ]]; do
        # no match, means that candidate common part is not correct
        common_part="$(dirname "$common_part")"
        result="${result}/.." # move to parent dir in relative path
    done

    if [[ "$common_part" == "/" ]]; then
        # special case for root (no common path)
        result="$result/"
    fi

    # since we now have identified the common part,
    # compute the non-common part
    local forward_part="${2#"$common_part"}"
    # and now stick all parts together
    result="${result}${forward_part}"
    echo "$result"
}

echo "Looking for relative path between:"
# Get absolute path of gitpmoji install dir
TARGET="$(cd "$GITPMOJI_INSTALL_DIR"; pwd)"
# Get absolute path of the hooks directory
SOURCE="$(cd "$HOOKS_DIR"; pwd)"

echo "TARGET: $TARGET"
echo "SOURCE: $SOURCE"

RELATIVE_PATH=$(relative_path "$SOURCE" "$TARGET")

echo "RELATIVE_PATH: $RELATIVE_PATH"

cd $HOOKS_DIR

echo "Creating symlink for prepare-commit-msg"
echo "ln -sf $RELATIVE_PATH/prepare-commit-msg.sh prepare-commit-msg"

ln -sf $RELATIVE_PATH/prepare-commit-msg.sh prepare-commit-msg

cd $TOP_LEVEL_GIT_DIR

echo "Git hooks successfully installed"
echo "You can now commit with gitpmoji. 🚀"
echo "To uninstall just remove $HOOKS_DIR/prepare-commit-msg and $GITPMOJI_INSTALL_DIR"

exit 0
