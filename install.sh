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

echo "Enter dir name where gitpmoji scripts will be installed."
echo "Just press enter for default '.gitpmoji' or use '.' to install in project root"
read -p "GITPMOJI_DIR=" GITPMOJI_DIR

if [ -z "$GITPMOJI_DIR" ]; then
    GITPMOJI_DIR=".gitpmoji"
fi

if [ "$GITPMOJI_DIR" = "." ]; then
    GITPMOJI_INSTALL_DIR="$TOP_LEVEL_GIT_DIR"
    echo "gitpmoji will be installed in project root: $GITPMOJI_INSTALL_DIR"
else
    GITPMOJI_INSTALL_DIR="$TOP_LEVEL_GIT_DIR/$GITPMOJI_DIR"
    echo "gitpmoji will be installed in $GITPMOJI_INSTALL_DIR"
    mkdir -p $GITPMOJI_INSTALL_DIR
fi
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
    echo "Creating .gitpmoji.env file..."
    
    # Create file with header comment
    cat << 'EOF' > .gitpmoji.env
# gitpmoji environment configuration file
# This file contains environment variables for gitpmoji
# You can also create a global config file at ~/.gitpmoji.env
# Local settings in this file will override global settings from ~/.gitpmoji.env

EOF

    # Source global config if exists
    echo "# Source global config if exists" >> .gitpmoji.env
    echo "if [ -f ~/.gitpmoji.env ]; then" >> .gitpmoji.env
    echo "    source ~/.gitpmoji.env" >> .gitpmoji.env
    echo "fi" >> .gitpmoji.env
    echo "" >> .gitpmoji.env
    
    # Load global config to check for existing variables
    if [ -f ~/.gitpmoji.env ]; then
        source ~/.gitpmoji.env
        echo "Found global config at ~/.gitpmoji.env"
    fi
    
    # Process GITPMOJI_API_KEY
    if [ -n "$GITPMOJI_API_KEY" ]; then
        echo "Global GITPMOJI_API_KEY found"
        echo "Use global GITPMOJI_API_KEY? (y/n)"
        read USE_GLOBAL_API_KEY
        if [ "$USE_GLOBAL_API_KEY" = "y" ]; then
            echo "#export GITPMOJI_API_KEY=\"_your_api_key_\"" >> .gitpmoji.env
        else
            echo "Enter your OpenAI API key (https://platform.openai.com/account/api-keys):"
            read -p "GITPMOJI_API_KEY=" api_key
            echo "export GITPMOJI_API_KEY=\"$api_key\"" >> .gitpmoji.env
        fi
    else
        echo "Enter your OpenAI API key (https://platform.openai.com/account/api-keys):"
        read -p "GITPMOJI_API_KEY=" api_key
        echo "export GITPMOJI_API_KEY=\"$api_key\"" >> .gitpmoji.env
    fi
    
    # Process GITPMOJI_API_BASE_URL
    if [ -n "$GITPMOJI_API_BASE_URL" ]; then
        echo "Global GITPMOJI_API_BASE_URL found: $GITPMOJI_API_BASE_URL"
        echo "Use global GITPMOJI_API_BASE_URL? (y/n)"
        read USE_GLOBAL_BASE_URL
        if [ "$USE_GLOBAL_BASE_URL" = "y" ]; then
            echo "#export GITPMOJI_API_BASE_URL=\"https://api.openai.com/v1\"" >> .gitpmoji.env
        else
            echo "Enter base url for OpenAI API (leave empty for default 'https://api.openai.com/v1')"
            read -p "GITPMOJI_API_BASE_URL=" base_url
            if [ -z "$base_url" ]; then
                base_url="https://api.openai.com/v1"
            fi
            echo "export GITPMOJI_API_BASE_URL=\"$base_url\"" >> .gitpmoji.env
        fi
    else
        echo "Enter base url for OpenAI API (leave empty for default 'https://api.openai.com/v1')"
        read -p "GITPMOJI_API_BASE_URL=" base_url
        if [ -z "$base_url" ]; then
            base_url="https://api.openai.com/v1"
        fi
        echo "export GITPMOJI_API_BASE_URL=\"$base_url\"" >> .gitpmoji.env
    fi
    
    # Process GITPMOJI_API_MODEL
    if [ -n "$GITPMOJI_API_MODEL" ]; then
        echo "Global GITPMOJI_API_MODEL found: $GITPMOJI_API_MODEL"
        echo "Use global GITPMOJI_API_MODEL? (y/n)"
        read USE_GLOBAL_MODEL
        if [ "$USE_GLOBAL_MODEL" = "y" ]; then
            echo "#export GITPMOJI_API_MODEL=\"gpt-4o\"" >> .gitpmoji.env
        else
            echo "Enter model for OpenAI API (leave empty for default 'gpt-4o')"
            read -p "GITPMOJI_API_MODEL=" model
            if [ -z "$model" ]; then
                model="gpt-4o"
            fi
            echo "export GITPMOJI_API_MODEL=\"$model\"" >> .gitpmoji.env
        fi
    else
        echo "Enter model for OpenAI API (leave empty for default 'gpt-4o')"
        read -p "GITPMOJI_API_MODEL=" model
        if [ -z "$model" ]; then
            model="gpt-4o"
        fi
        echo "export GITPMOJI_API_MODEL=\"$model\"" >> .gitpmoji.env
    fi
    
    # Process GITPMOJI_PREFIX_RX
    if [ -n "$GITPMOJI_PREFIX_RX" ]; then
        echo "Global GITPMOJI_PREFIX_RX found: $GITPMOJI_PREFIX_RX"
        echo "Use global GITPMOJI_PREFIX_RX? (y/n)"
        read USE_GLOBAL_PREFIX
        if [ "$USE_GLOBAL_PREFIX" = "y" ]; then
            echo "#export GITPMOJI_PREFIX_RX=\"\"" >> .gitpmoji.env
        else
            echo "Enter prefix for commit messages which will be untouched as first keyword for each message"
            echo "In format of sed RegExp use double backslash (\\\\) for escaping special symbols like {, }, ?, etc."
            read -p "GITPMOJI_PREFIX_RX=" prefix
            echo "export GITPMOJI_PREFIX_RX=\"$prefix\"" >> .gitpmoji.env
        fi
    else
        echo "Enter prefix for commit messages which will be untouched as first keyword for each message"
        echo "In format of sed RegExp use double backslash (\\\\) for escaping special symbols like {, }, ?, etc."
        read -p "GITPMOJI_PREFIX_RX=" prefix
        echo "export GITPMOJI_PREFIX_RX=\"$prefix\"" >> .gitpmoji.env
    fi
    
    echo ".gitpmoji.env created successfully"
    echo "--- start of .gitpmoji.env ---"
    cat .gitpmoji.env
    echo "--- end of .gitpmoji.env ---"
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

cd $HOOKS_DIR

# Simple relative path: from .git/hooks go up twice (../../) then into GITPMOJI_DIR
if [ "$GITPMOJI_DIR" = "." ]; then
    SYMLINK_PATH="../../prepare-commit-msg.sh"
else
    SYMLINK_PATH="../../$GITPMOJI_DIR/prepare-commit-msg.sh"
fi

echo "Creating symlink for prepare-commit-msg"
echo "ln -sf $SYMLINK_PATH prepare-commit-msg"

ln -sf $SYMLINK_PATH prepare-commit-msg

cd $TOP_LEVEL_GIT_DIR

echo "Git hooks successfully installed"
echo "You can now commit with gitpmoji. 🚀"
echo "To uninstall just remove $HOOKS_DIR/prepare-commit-msg and $GITPMOJI_INSTALL_DIR"

exit 0
