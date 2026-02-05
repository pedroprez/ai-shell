#!/bin/bash
#
# ai-shell installer
# curl -fsSL https://raw.githubusercontent.com/pedroprez/ai-shell/main/install.sh | bash
#

set -e

REPO_URL="https://raw.githubusercontent.com/pedroprez/ai-shell/main"
INSTALL_DIR="$HOME/.local/bin"
SCRIPT_NAME="ai-shell.sh"
CONFIG_FILE="$HOME/.ai-shell.conf"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}🤖 ai-shell installer${NC}"
echo ""

# Detect OS
OS="$(uname -s)"
case "$OS" in
  Linux*)  OS_TYPE="Linux" ;;
  Darwin*) OS_TYPE="macOS" ;;
  *)       echo -e "${RED}Unsupported OS: $OS${NC}"; exit 1 ;;
esac
echo -e "Detected: ${GREEN}$OS_TYPE${NC}"

# Check for required tools
for cmd in curl jq; do
  if ! command -v $cmd &>/dev/null; then
    echo -e "${RED}Error: $cmd is required but not installed.${NC}"
    if [[ "$OS_TYPE" == "macOS" ]]; then
      echo "Install with: brew install $cmd"
    else
      echo "Install with: sudo apt install $cmd"
    fi
    exit 1
  fi
done

# Detect available providers
echo ""
echo -e "${CYAN}Checking available AI providers...${NC}"
PROVIDERS=()

if command -v ollama &>/dev/null; then
  echo -e "  Ollama: ${GREEN}found${NC}"
  PROVIDERS+=("ollama")
else
  echo -e "  Ollama: ${YELLOW}not installed${NC}"
fi

if command -v claude &>/dev/null; then
  echo -e "  Claude CLI: ${GREEN}found${NC}"
  PROVIDERS+=("claude")
else
  echo -e "  Claude CLI: ${YELLOW}not installed${NC}"
fi

if command -v gemini &>/dev/null; then
  echo -e "  Gemini CLI: ${GREEN}found${NC}"
  PROVIDERS+=("gemini")
else
  echo -e "  Gemini CLI: ${YELLOW}not installed${NC}"
fi

if [[ ${#PROVIDERS[@]} -eq 0 ]]; then
  echo ""
  echo -e "${RED}No AI provider found!${NC}"
  echo ""
  echo "Install at least one:"
  echo "  • Ollama (recommended): curl -fsSL https://ollama.ai/install.sh | sh"
  echo "  • Claude CLI: npm install -g @anthropic-ai/claude-cli"
  echo "  • Gemini CLI: pip install google-generativeai"
  exit 1
fi

# Select provider
echo ""
if [[ ${#PROVIDERS[@]} -eq 1 ]]; then
  SELECTED_PROVIDER="${PROVIDERS[0]}"
  echo -e "Using: ${GREEN}$SELECTED_PROVIDER${NC}"
else
  echo "Select your AI provider:"
  select opt in "${PROVIDERS[@]}"; do
    if [[ -n "$opt" ]]; then
      SELECTED_PROVIDER="$opt"
      break
    fi
  done
fi

# If Ollama, handle model selection
SELECTED_MODEL=""
if [[ "$SELECTED_PROVIDER" == "ollama" ]]; then
  echo ""
  
  # Check if Ollama is running
  if ! curl -s --max-time 2 http://localhost:11434/api/tags &>/dev/null; then
    echo -e "${YELLOW}Starting Ollama...${NC}"
    if [[ "$OS_TYPE" == "macOS" ]]; then
      open -a Ollama 2>/dev/null || ollama serve &>/dev/null &
    else
      ollama serve &>/dev/null &
    fi
    sleep 3
  fi

  # Get installed models
  INSTALLED_MODELS=$(curl -s http://localhost:11434/api/tags 2>/dev/null | jq -r '.models[].name' 2>/dev/null)
  
  if [[ -n "$INSTALLED_MODELS" ]]; then
    echo -e "${CYAN}Installed models:${NC}"
    echo "$INSTALLED_MODELS" | while read -r m; do echo "  • $m"; done
    echo ""
    echo "Select a model (or type a new one to install):"
    
    # Convert to array
    readarray -t MODEL_ARRAY <<< "$INSTALLED_MODELS"
    MODEL_ARRAY+=("Install new model...")
    
    select opt in "${MODEL_ARRAY[@]}"; do
      if [[ "$opt" == "Install new model..." ]]; then
        SELECTED_MODEL=""
        break
      elif [[ -n "$opt" ]]; then
        SELECTED_MODEL="$opt"
        break
      fi
    done
  fi

  # If no model selected, offer suggestions
  if [[ -z "$SELECTED_MODEL" ]]; then
    echo ""
    echo "Recommended lightweight models:"
    SUGGESTED_MODELS=("qwen2.5:3b" "llama3.2:3b" "phi3:mini")
    select opt in "${SUGGESTED_MODELS[@]}"; do
      if [[ -n "$opt" ]]; then
        SELECTED_MODEL="$opt"
        break
      fi
    done
    
    echo ""
    echo -e "${YELLOW}Downloading $SELECTED_MODEL...${NC}"
    echo "(This may take a few minutes)"
    ollama pull "$SELECTED_MODEL"
  fi
  
  echo -e "Model: ${GREEN}$SELECTED_MODEL${NC}"
fi

# Create install directory
mkdir -p "$INSTALL_DIR"

# Download script
echo ""
echo "Installing ai-shell..."
curl -fsSL "$REPO_URL/$SCRIPT_NAME" -o "$INSTALL_DIR/$SCRIPT_NAME"
chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

# Save configuration
echo "AI_PROVIDER=$SELECTED_PROVIDER" > "$CONFIG_FILE"
if [[ -n "$SELECTED_MODEL" ]]; then
  echo "AI_MODEL=$SELECTED_MODEL" >> "$CONFIG_FILE"
fi
echo -e "Config saved: ${GREEN}$CONFIG_FILE${NC}"

# Detect shell and config file
SHELL_NAME="$(basename "$SHELL")"
case "$SHELL_NAME" in
  zsh)  SHELL_RC="$HOME/.zshrc" ;;
  bash) SHELL_RC="$HOME/.bashrc" ;;
  *)    SHELL_RC="$HOME/.bashrc" ;;
esac

# Add source line if not present
SOURCE_LINE="source $INSTALL_DIR/$SCRIPT_NAME"
if ! grep -qF "$SOURCE_LINE" "$SHELL_RC" 2>/dev/null; then
  echo "" >> "$SHELL_RC"
  echo "# ai-shell - terminal AI assistant" >> "$SHELL_RC"
  echo "$SOURCE_LINE" >> "$SHELL_RC"
  echo -e "Added to: ${GREEN}$SHELL_RC${NC}"
fi

echo ""
echo -e "${GREEN}✅ Installation complete!${NC}"
echo ""
echo "Examples:"
echo "  /ai list files sorted by size"
echo "  /ia what is 25 * 4"
echo "  /ai what day is today"
echo ""
echo "Reloading shell..."
exec $SHELL
