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


# Check if an argument is provided
if [ $# -eq 0 ]; then
    echo "Please provide a question as an argument."
    exit 1
fi

PROMPT="$*"
# echo "PROMPT: $PROMPT"
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

DATA=$(jq -n --arg system_prompt "$SYSTEM_PROMPT" --arg prompt "$PROMPT" "$JSON" )

# Make the API call
RESPONSE=$(curl -s \
                -X POST "https://api.openai.com/v1/chat/completions" \
                -H "Content-Type: application/json" \
                -H "Authorization: Bearer $API_KEY" \
                -d "$DATA")

# Extract and display the answer
EMOJI=$(echo $RESPONSE | jq -r '.choices[0].message.content' | sed 's/^"//;s/"$//')

PREFIX="-"

# check if GITPMOJI_PREFIX_RX is set
GITPMOJI_PREFIX_RX=$GITPMOJI_PREFIX_RX
if [ -z "$GITPMOJI_PREFIX_RX" ]; then
    PREFIX="-"
else
    PREFIX=$GITPMOJI_PREFIX_RX
fi

RESULT=$(echo $PROMPT | sed "s/^\($PREFIX \{0,1\}\)\{0,1\}\(.*\)$/\1$EMOJI \2/")

echo $RESULT
exit 0
