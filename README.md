# GITPMOJI
========

Enhanced Git commits using AI
-----------------------------

GITPMOJI is a powerful AI-driven tool designed to enhance your Git workflow. It offers several key features:

1. Commit Message Generation: Analyzes your code changes (diff) and generates comprehensive commit messages, providing detailed context for each commit.

2. Code Change Evaluation: Assesses the impact and quality of your code changes, offering insights into the modifications made.

3. Emoji Decoration: Automatically adds relevant emojis to your commits, providing visual cues that make it easier to understand the nature of each change at a glance.

This multi-functional approach transforms your commit history into a more informative, insightful, and visually appealing log of your project's development. By leveraging AI to generate, evaluate, and decorate your commits, GITPMOJI helps maintain a clear and meaningful record of your project's evolution.

## How It Works

1. When you make a commit, GITPMOJI intercepts the commit message using a Git hook. So it works with all git clients and IDEs that use git hooks.
2. The commit message and diff are sent to a custom script (`gpt.sh`) that communicates with the OpenAI API.
3. The API, using the GPT-4o model, analyzes the commit message and the diff and updates the commit message.
4. The suggested emoji is prepended to your original commit message.
5. The AI generates a commit message based on the diff changes added to at the end of the original commit message.
6. Rating of the commit message is added to the end of the commit message.
7. The process respects any existing prefix in your commit messages, as defined by the GITPMOJI_PREFIX_RX environment variable.

This process happens seamlessly, requiring no additional action from the user after initial setup.

## How to use

1. add ~ to the end of your commit message to let AI update the commit message and add the emoji to it
2. add ~~ to the end of your commit message to let AI update the commit message based on the diff 
3. add ~~~ to the end of your commit message to let AI for both update the commit message and add the emoji
4. add * as the last character of your commit message to let AI add the rating to the end of the commit message
5. use composition like ~~~* or ~~* or ~* to let AI update the commit accordingly

## Assessing Code Changes

GITPMOJI also provides a feature to assess the quality of your code changes. You can use the `./gpt -a` command to evaluate the impact and quality of your code modifications. This command analyzes the git diff and provides a detailed assessment based on several factors such as code cleanliness, structure, readability, complexity, and overall code quality.

To use this feature, simply run:
```
git diff | ./gpt.sh -a -d
```

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
GITPMOJI_API_BASE_URL=https://api.openai.com/v1
GITPMOJI_API_MODEL=gpt-4o
```

> ❗ Note: 
> - GITPMOJI_API_BASE_URL is optional and defaults to https://api.openai.com/v1
> - GITPMOJI_API_MODEL is optional and defaults to gpt-4o

- make sure to have `prepare-commit-msg.sh` and `gpt.sh` executable

- rename `prepare-commit-msg.sh` to `prepare-commit-msg`

- put `prepare-commit-msg`, `gpt.sh` and `.gitpmoji.env` into `.git/hooks/`

## Usage

Simply write your commit messages as usual. GITPMOJI will automatically add relevant emojis to your commits.

## Examples

Check out the [commit messages](https://github.com/Fl0p/gitpmoji/commits/main/) in this repo

![Screenshot 2024-08-22 at 11 43 32](https://github.com/user-attachments/assets/f69ff571-e304-41c1-baec-7d53219bd756)

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

