# ai-shell 🤖

A quick AI assistant for your terminal. Supports multiple AI providers.

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/pedroprez/ai-shell/main/install.sh | bash
```

The installer will:
1. Detect available AI providers (Ollama, Claude CLI, Gemini CLI)
2. Let you choose which one to use
3. For Ollama: let you select from installed models or download a new one
4. Configure everything automatically

## Supported Providers

| Provider | Local | Setup |
|----------|-------|-------|
| **Ollama** | ✅ | `curl -fsSL https://ollama.ai/install.sh \| sh` |
| **Claude CLI** | ❌ | `npm install -g @anthropic-ai/claude-cli` |
| **Gemini CLI** | ❌ | `pip install google-generativeai` |

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
```

## Configuration

Config is stored in `~/.ai-shell.conf`:

```bash
AI_PROVIDER=ollama
AI_MODEL=qwen2.5:3b
```

To change provider or model, edit the file or re-run the installer.

### Environment Variables

You can also override via environment:

```bash
export AI_PROVIDER="claude"      # Use Claude instead
export AI_MODEL="llama3.2:3b"    # Different Ollama model
export AI_HOST="http://server:11434"  # Remote Ollama
```

## Supported Systems

- ✅ Linux (bash)
- ✅ macOS (zsh/bash)

## Inspiration

This project was inspired by [this tweet](https://x.com/DamianCatanzaro/status/2019223722406621612) from [@DamianCatanzaro](https://x.com/DamianCatanzaro).

## License

MIT
