#!/bin/bash

#bash script to run gpt-4o

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
You will be given a message and you will generate an emoji that best represents the message.
You will only generate emoji.
You will not generate any other characters than the emoji.
You will provide only one emoji for each message.
You answer should contain only single emoji followed by original message separated by single space, nothing else.
"

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
RESULT=$(echo $RESPONSE | jq -r '.choices[0].message.content' | sed 's/^"//;s/"$//')

echo $RESULT