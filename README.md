# ai-shell 🤖

A quick AI assistant for your terminal using local [Ollama](https://ollama.ai).

Ask questions, get shell commands, do math - all from your terminal with `/ai` or `/ia`.

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/pedroprez/ai-shell/main/install.sh | bash
```

## Requirements

- **Ollama** - Local LLM runtime ([install](https://ollama.ai))
- **curl** - HTTP client
- **jq** - JSON processor

The installer will check for these and guide you if anything is missing.

## Usage

```bash
# Get shell commands
/ai list files sorted by size
→ ls -lhS

/ai find all .js files modified today
→ find . -name "*.js" -mtime 0

# Do math
/ai what is 15% of 230
→ 34.5

/ia 7 + 8 - 2
→ 13

# Ask questions
/ai what is the capital of France
→ Paris

/ai what day is it in 100 days
→ Friday, May 16, 2025
```

## Configuration

Optional environment variables:

```bash
# Use a different model (default: qwen2.5:7b)
export AI_MODEL="llama3.2:3b"

# Use a remote Ollama server
export AI_HOST="http://192.168.1.100:11434"
```

Add these to your `~/.bashrc` or `~/.zshrc` to make them permanent.

## Supported Systems

- ✅ Linux (bash)
- ✅ macOS (zsh/bash)

## Uninstall

```bash
# Remove the script
rm ~/.local/bin/ai-shell.sh

# Remove the source line from your shell config
# Edit ~/.bashrc or ~/.zshrc and remove the ai-shell line
```

## Inspiration

This project was inspired by [this tweet](https://x.com/DamianCatanzaro/status/2019223722406621612) from [@DamianCatanzaro](https://x.com/DamianCatanzaro).

## License

MIT
