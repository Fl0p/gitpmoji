# GITPMOJI
========

Emoji-enhanced Git commits using AI suggestions
----------------------------------------------

GITPMOJI is a versatile tool that enhances your Git workflow using AI-powered suggestions. It can generate or update commit messages based on your code changes, providing detailed context for each commit. Additionally, it automatically adds relevant emojis to your commits, offering visual cues that make it easier to understand the nature of each change at a glance. This multi-functional approach transforms your commit history into a more informative and visually appealing log of your project's development.

## Description

GITPMOJI integrates with your Git workflow to analyze your commit messages and prepend them with appropriate emojis. It uses OpenAI's GPT-4o model to generate context-aware emoji suggestions based on the content of your commit messages.

## How It Works

1. When you make a commit, GITPMOJI intercepts the commit message using a Git hook.
2. The commit message and diff are sent to a custom script (`gpt.sh`) that communicates with the OpenAI API.
3. The API, using the GPT-4o model, analyzes the commit message and the diff and updates the commit message.
4. The suggested emoji is prepended to your original commit message.
5. The AI generates a commit message based on the diff changes added to at the end of the commit message.
6. The process respects any existing prefix in your commit messages, as defined by the GITPMOJI_PREFIX_RX environment variable.

This process happens seamlessly, requiring no additional action from the user after initial setup.

## How to use

1. add ~ to the end of your commit message to let AI update the commit message and add the emoji to it
2. add ~~ to the end of your commit message to let AI update the commit message based on the diff 
3. add ~~~ to the end of your commit message to let AI for both update the commit message based on the diff and add the emoji

## Setup as one liner wizzard

Just run :

navigate to your project directory and run:
```
curl -o install.sh https://raw.githubusercontent.com/Fl0p/gitpmoji/main/install.sh && bash install.sh && rm install.sh
```
and follow the instructions.

## Setup manually

- install jq
```
brew install jq
```
or
```
apt-get install jq
```

- download `prepare-commit-msg.sh` and `gpt.sh`

- Add environment variables to your `.env` file or create `.gitpmoji.env` file:

```
GITPMOJI_API_KEY=your_openai_api_key
GITPMOJI_PREFIX_RX="TICKET-[0-9]\{1,5\} \{0,1\}"
```

- make sure to have `prepare-commit-msg.sh` and `gpt.sh` executable

- put prepare-commit-msg.sh into .git/hooks/ or make symlink to it

## Usage

Simply write your commit messages as usual. GITPMOJI will automatically add relevant emojis to your commits.

## Examples

Check out the [commit messages](https://github.com/Fl0p/gitpmoji/commits/main/) in this repo
```
🩹️ typos fix. fix tilda removing~
📝 Update README.md to provide a more comprehensive description of GITPMOJI features
🩹 fix emoji placement
⚰️ Remove redundant echo
♻️ Update with commit message generation
🔧 Add Prefix support and .env file
➕ Add some predefined Emojis
🛠️ Refacroring GPT script
```

## Contributing

(Add contribution guidelines here)

## License

[LICENSE](LICENSE)

