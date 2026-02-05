#!/bin/bash
# ai-shell - Quick AI assistant for your terminal
# Supports: Ollama (local), Claude CLI, Gemini CLI
#
# Usage:
#   /ai how do I list hidden files        → ls -la
#   /ia what is 7+8-2                      → 13
#
# Configuration (~/.ai-shell.conf):
#   AI_PROVIDER=ollama|claude|gemini
#   AI_MODEL=qwen2.5:7b (for ollama)

CONFIG_FILE="$HOME/.ai-shell.conf"

# Load config
if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
fi

# Defaults
AI_PROVIDER="${AI_PROVIDER:-ollama}"
AI_MODEL="${AI_MODEL:-qwen2.5:7b}"
AI_HOST="${AI_HOST:-http://localhost:11434}"

SYSTEM_PROMPT="You are a concise terminal assistant. Based on the user's intent:

1. If they ask for a SHELL COMMAND (list files, search, compress, etc):
   → Return ONLY the command, no explanation, no backticks, no markdown.
   → Compatible with Linux/bash and macOS/zsh.

2. If they ask for a MATH CALCULATION:
   → Return ONLY the numeric result.

3. If they ask a GENERAL QUESTION:
   → Reply very briefly, 1 line max.

4. If the request is AMBIGUOUS or DANGEROUS (rm -rf, etc):
   → Return: echo 'Unsafe or ambiguous command'

IMPORTANT: Single line response. No additional explanations."

function _ai_ollama() {
  local prompt="$1"
  
  if ! curl -s --max-time 2 "$AI_HOST/api/tags" &>/dev/null; then
    echo "Error: Ollama is not running. Start with: ollama serve"
    return 1
  fi

  curl -s "$AI_HOST/api/generate" \
    -d "$(jq -n \
      --arg model "$AI_MODEL" \
      --arg prompt "$prompt" \
      --arg system "$SYSTEM_PROMPT" \
      '{model: $model, prompt: $prompt, system: $system, stream: false}')" \
    | jq -r '.response' | head -1
}

function _ai_claude() {
  local prompt="$1"
  
  if ! command -v claude &>/dev/null; then
    echo "Error: Claude CLI not installed. See: https://docs.anthropic.com/claude-cli"
    return 1
  fi

  echo "$prompt" | claude --print -p "$SYSTEM_PROMPT" 2>/dev/null | head -1
}

function _ai_gemini() {
  local prompt="$1"
  
  if ! command -v gemini &>/dev/null; then
    echo "Error: Gemini CLI not installed. Install with: pip install google-generativeai"
    return 1
  fi

  gemini -p "$SYSTEM_PROMPT" "$prompt" 2>/dev/null | head -1
}

function /ai() {
  local prompt="$*"
  
  if [[ -z "$prompt" ]]; then
    echo "Usage: /ai <question or intention>"
    echo "Provider: $AI_PROVIDER | Model: $AI_MODEL"
    echo ""
    echo "Examples:"
    echo "  /ai list files sorted by size"
    echo "  /ai what is 15% of 230"
    return 1
  fi

  case "$AI_PROVIDER" in
    ollama) _ai_ollama "$prompt" ;;
    claude) _ai_claude "$prompt" ;;
    gemini) _ai_gemini "$prompt" ;;
    *) echo "Unknown provider: $AI_PROVIDER" ;;
  esac
}

# Spanish alias
function /ia() { /ai "$@"; }
