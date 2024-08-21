#!/bin/bash

#bash script to run gpt-4o

#cd to the directory of the script
cd "$(dirname "$0")"

#load from env variable
if [ -f .gitpmoji.env ]; then
    source .gitpmoji.env
fi

# load from env variable
API_KEY=$GITPMOJI_API_KEY

# check if API_KEY is set
if [ -z "$API_KEY" ]; then
    echo "GITPMOJI_API_KEY is not set"
    exit 1
fi

# check if jq is installed
if ! command -v jq &> /dev/null
then
    echo "jq could not be found, please install it"
    exit 1
fi

# Function to display help message
display_help() {
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -m \"MESSAGE\"  Specify the commit message"
    echo "  -d DIFF.file    Specify the diff file. Will be used to generate the commit message"
    echo "  -e              Will analyze message and add the emoji"
    echo "  -h              Display this help message"
    echo
    echo "Example:"
    echo "  $0 -e -m \"Implement new feature\""
}

# Parse command line arguments
EMOJI=false
MESSAGE=""
RESULT=""

while getopts "hem:d:" opt; do
  case $opt in
    m)
      MESSAGE="$OPTARG"
      ;;
    d)
      DIFF="$OPTARG"
      ;;
    e)
      EMOJI=true
      ;;
    h)
      display_help
      exit 0
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      display_help
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      display_help
      exit 1
      ;;
  esac
done

# Shift the parsed options out of the argument list
shift $((OPTIND-1))

echo "MESSAGE: $MESSAGE"
echo "EMOJI: $EMOJI"
echo "DIFF: $DIFF"

# Check if both emoji and message are provided
if [ -z "$MESSAGE" ] && [ -z "$DIFF" ]; then
  echo "At least one of the following options is required: -m, -d"
  display_help
  exit 1
fi

generate_message() {
  if [ ! -f "$DIFF" ]; then
    echo "no such file $DIFF"
    exit 1
  fi
  DIFF_CONTENT=$(cat $DIFF)
  # Check the size of DIFF_CONTENT
  if [ ${#DIFF_CONTENT} -gt 100000 ]; then
    echo "Error: The diff content is too large. Maximum allowed is 100000 characters. (30000 tokens)"
    exit 1
  fi

  # Prepare the data for the API call
  SYSTEM_PROMPT="You are a system that generates git commit messages from diff.
  You will be given a diff and your task is to generate a git commit message.
  You will provide only one commit message for each diff.
  Your answer should contain only single commit message, nothing else.
  Use english language only.
  Use multiple lines for the response.
  Try to use maximum 100 words in the response.
  "

  PREFIX_RX="\"" 

  JSON='{
    "model": "gpt-4o",
    "messages": [
      {
        "role": "system",
        "content": $system_prompt
      },
      {
        "role": "user",
        "content": $prompt
      }
    ],
    "max_tokens": 200,
    "temperature": 0.999,
    "top_p": 1,
    "frequency_penalty": 0.0,
    "presence_penalty": 0.0
  }'

  DATA=$(jq -n --arg system_prompt "$SYSTEM_PROMPT" --arg prompt "$DIFF_CONTENT" "$JSON" )

  # Make the API call
  RESPONSE=$(curl -s \
                  -X POST "https://api.openai.com/v1/chat/completions" \
                  -H "Content-Type: application/json" \
                  -H "Authorization: Bearer $API_KEY" \
                  -d "$DATA")

  # Extract and display the answer
  echo $RESPONSE
  GPT_MESSAGE=$(echo $RESPONSE | jq -r '.choices[0].message.content' | sed 's/^"//;s/"$//')
  
  if [ -z "$MESSAGE" ]; then
    MESSAGE=$(echo -e "${GPT_MESSAGE}")
  else
    MESSAGE=$(echo -e ${MESSAGE} && echo -e "${GPT_MESSAGE}")
  fi
  RESULT=$(echo -e "${MESSAGE}")
}

generate_emoji() {
  # Prepare the data for the API call
  SYSTEM_PROMPT="You are a system that generates emoji for incoming messages.
  You will be given a message and your task is to generate an emoji that best represents the message.
  You will provide only one emoji for each message.
  Your answer should contain only single emoji, nothing else.
  If possible, use the emoji that is already in the message.
  If possible, use the emoji from the list below:
  | Emoji | Message |
  |-------|-------------|
  | 🎉 | Begin a project. start new priject. initial commit |
  | 🪲 | Fix a bug. bugfix |
  | 🚑 | Critical bug fix. hotfix. |
  | ✨ | Introduce new features. |
  | 📝 | Add or update documentation. |
  | 🚀 | Deploy stuff. |
  | 💄 | Add or update the UI and style files. |
  | 🎨 | Improve structure. cosmetic changes |
  | 🧹 | Run linter or formatter |
  | ⚡ | Improve performance. |
  | 🗑️ | Deprecate code. Remove code or files.|
  | ✅ | Add, update, or pass tests. unit-tests |
  | 🔒 | Fix security issues. |
  | 🔐 | Add or update secrets. |
  | 🔖 | Release / Version tags. |
  | 🚨 | Fix compiler / linter warnings. |
  | 🚧 | Work in progress. |
  | 💚 | Fix CI Build. |
  | ⬇️ | Downgrade dependencies. |
  | ⬆️ | Upgrade dependencies. |
  | 📌 | Pin dependencies to specific versions. |
  | 👷 | Add or update CI build system. |
  | 📈 | Add or update analytics. |
  | ♻️ | Refactor code. |
  | ➕ | Add a dependency. |
  | ➖ | Remove a dependency. |
  | 🔧 | Add or update configuration files. |
  | 🔨 | Add or update development scripts. |
  | 🌐 | Internationalization and localization. |
  | ✏️ | Fix typos. |
  | ⏪ | Revert changes. |
  | 🔀 | Merge branches. |
  | 📦 | Add or update compiled files or packages. |
  | 👽 | Update code due to external API changes. |
  | 🚚 | Move or rename resources. |
  | 📄 | Add or update license. |
  | 💥 | Introduce breaking changes. |
  | 🍱 | Add or update assets. |
  | ♿ | Add or improve accessibility. |
  | 💡 | Add or update comments in source code. |
  | 🗯 | Add or update text and literals. |
  | 🗃 | Perform database changes. |
  | 👥 | Add or update contributor(s). |
  | 🚸 | Improve user experience. |
  | 🏗 | Make architectural changes. |
  | 📱 | Work on responsive design. |
  | 🤡 | Mock things. |
  | 🙈 | Add or update a .gitignore file. |
  | 📸 | Add or update snapshots. |
  | 🏷️ | Add or update types. |
  | 🚩 | Add or update feature flags. |
  | 🥅 | Catch errors. |
  | 💫 | Add or update animations. |
  | 🛂 | Work on authorization. |
  | 🩹 | Simple fix for a non-critical issue. |
  | 🧐 | Data exploration/inspection. |
  | ⚰️ | Remove dead code. |
  | 🧪 | Add a failing test. |
  | 👔 | Add or update business logic. |
  | 🩺 | Add or update healthcheck. |
  | 🧱 | Infrastructure changes. |
  | 🧑‍💻 | Improve developer experience. |
  "

  PREFIX_RX="\"" 

  JSON='{
    "model": "gpt-4o",
    "messages": [
      {
        "role": "system",
        "content": $system_prompt
      },
      {
        "role": "user",
        "content": $prompt
      }
    ],
    "max_tokens": 100,
    "temperature": 0.999,
    "top_p": 1,
    "frequency_penalty": 0.0,
    "presence_penalty": 0.0
  }'

  DATA=$(jq -n --arg system_prompt "$SYSTEM_PROMPT" --arg prompt "$MESSAGE" "$JSON" )

  # Make the API call
  RESPONSE=$(curl -s \
                  -X POST "https://api.openai.com/v1/chat/completions" \
                  -H "Content-Type: application/json" \
                  -H "Authorization: Bearer $API_KEY" \
                  -d "$DATA")

  # Extract and display the answer
  EMOJI=$(echo $RESPONSE | jq -r '.choices[0].message.content' | sed 's/^"//;s/"$//')

  PREFIX="###"

  # check if GITPMOJI_PREFIX_RX is set
  GITPMOJI_PREFIX_RX=$GITPMOJI_PREFIX_RX
  if [ -z "$GITPMOJI_PREFIX_RX" ]; then
      PREFIX="###"
  else
      PREFIX=$GITPMOJI_PREFIX_RX
  fi

  RESULT=$(echo -e "${MESSAGE}" | sed "1s/^\($PREFIX\)\{0,1\}\(.*\)$/\1 $EMOJI\2/")
}

if [ "$DIFF" ]; then
  generate_message
fi

if [ "$EMOJI" = true ]; then
  generate_emoji
fi

echo -e "${RESULT}"
exit 0
