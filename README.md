# GITPMOJI
========

Emoji-enhanced Git commits using AI suggestions
----------------------------------------------

GITPMOJI is a clever tool that automatically adds relevant emojis to your Git commit messages using AI-powered suggestions. It enhances your commit history with visual cues, making it easier to quickly understand the nature of each commit at a glance.

## Description

GITPMOJI integrates with your Git workflow to analyze your commit messages and prepend them with appropriate emojis. It uses OpenAI's GPT-4 model to generate context-aware emoji suggestions based on the content of your commit messages.

## How It Works

1. When you make a commit, GITPMOJI intercepts the commit message using a Git hook.
2. The commit message is sent to a custom script (`gpt.sh`) that communicates with the OpenAI API.
3. The API, using the GPT-4o model, analyzes the commit message and suggests an appropriate emoji.
4. The suggested emoji is prepended to your original commit message.
5. The modified commit message (emoji + original message) is saved as the final commit message.

This process happens seamlessly, requiring no additional action from the user after initial setup.

## Setup as one liner wizzard

Just run :

```
curl -s https://raw.githubusercontent.com/Fl0p/gitpmoji/main/install.sh | bash
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
GITPMOJI_PREFIX_RX="TICKET-[0-9]+:"
```

- make sure to have `prepare-commit-msg.sh` and `gpt.sh` executable

- put prepare-commit-msg.sh into .git/hooks/ or make symlink to it

## Usage

Simply write your commit messages as usual. GITPMOJI will automatically add relevant emojis to your commits.

## Examples

Check out the commit messages in this repo
```
📝 Update Readme
🔄 skip the prepare-commit-msg hook during a rebase
📄 Fill readme with actual text
🚀 Add README.md
⚠️ Add error displayng
🚪 Add error exit
⚙️ Add prepare commit script
```

## Contributing

(Add contribution guidelines here)

## License

[LICENSE](LICENSE)

