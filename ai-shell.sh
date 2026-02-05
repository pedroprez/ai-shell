#!/bin/bash
# ai-shell - Quick AI assistant for your terminal using local Ollama
# https://bitbucket.org/your-username/ai-shell
#
# Usage:
#   /ai how do I list hidden files        → ls -la
#   /ia what is 7+8-2                      → 13
#   /ai what day is it in 100 days?       → Friday, May 16, 2025
#
# Configuration (optional):
#   export AI_MODEL="llama3.2:3b"         # Use a different model
#   export AI_HOST="http://server:11434"  # Use remote Ollama

AI_MODEL="${AI_MODEL:-qwen2.5:7b}"
AI_HOST="${AI_HOST:-http://localhost:11434}"

function /ai() {
  local prompt="$*"
  
  if [[ -z "$prompt" ]]; then
    echo "Usage: /ai <question or intention>"
    echo "Examples:"
    echo "  /ai list files sorted by size"
    echo "  /ai what is 15% of 230"
    echo "  /ai what is the capital of France"
    return 1
  fi

  # Check if Ollama is running
  if ! curl -s --max-time 2 "$AI_HOST/api/tags" &>/dev/null; then
    echo "Error: Ollama is not running at $AI_HOST"
    echo "Start it with: ollama serve"
    return 1
  fi

  local system_prompt="You are a concise terminal assistant. Based on the user's intent:

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

  curl -s "$AI_HOST/api/generate" \
    -d "$(jq -n \
      --arg model "$AI_MODEL" \
      --arg prompt "$prompt" \
      --arg system "$system_prompt" \
      '{model: $model, prompt: $prompt, system: $system, stream: false}')" \
    | jq -r '.response' | head -1
}

# Spanish alias
function /ia() { /ai "$@"; }
