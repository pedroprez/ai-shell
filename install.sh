#!/bin/bash
#
# ai-shell installer
# One-liner: curl -fsSL https://bitbucket.org/YOUR_USER/ai-shell/raw/main/install.sh | bash
#

set -e

REPO_URL="https://raw.githubusercontent.com/pedroprez/ai-shell/main"
INSTALL_DIR="$HOME/.local/bin"
SCRIPT_NAME="ai-shell.sh"
MODEL="qwen2.5:7b"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

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
      echo "Install with: sudo apt install $cmd  # or your package manager"
    fi
    exit 1
  fi
done

# Check for Ollama
if ! command -v ollama &>/dev/null; then
  echo -e "${RED}Error: Ollama is not installed.${NC}"
  echo ""
  echo "Install Ollama first:"
  if [[ "$OS_TYPE" == "macOS" ]]; then
    echo "  brew install ollama"
    echo "  # or download from https://ollama.ai"
  else
    echo "  curl -fsSL https://ollama.ai/install.sh | sh"
  fi
  echo ""
  echo "Then run this installer again."
  exit 1
fi
echo -e "Ollama: ${GREEN}found${NC}"

# Check if Ollama is running
if ! curl -s --max-time 2 http://localhost:11434/api/tags &>/dev/null; then
  echo -e "${YELLOW}Warning: Ollama is not running.${NC}"
  echo "Starting Ollama..."
  if [[ "$OS_TYPE" == "macOS" ]]; then
    open -a Ollama 2>/dev/null || ollama serve &>/dev/null &
  else
    ollama serve &>/dev/null &
  fi
  sleep 3
fi

# Check/download model
echo "Checking for model: $MODEL"
if ! ollama list | grep -q "$MODEL"; then
  echo -e "${YELLOW}Model not found. Downloading $MODEL...${NC}"
  echo "(This may take a few minutes)"
  ollama pull "$MODEL"
else
  echo -e "Model $MODEL: ${GREEN}found${NC}"
fi

# Create install directory
mkdir -p "$INSTALL_DIR"

# Download script
echo "Installing ai-shell..."
curl -fsSL "$REPO_URL/$SCRIPT_NAME" -o "$INSTALL_DIR/$SCRIPT_NAME"
chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

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
else
  echo -e "Already in: ${GREEN}$SHELL_RC${NC}"
fi

echo ""
echo -e "${GREEN}✅ Installation complete!${NC}"
echo ""
echo "To start using ai-shell now, run:"
echo -e "  ${YELLOW}source $SHELL_RC${NC}"
echo ""
echo "Usage examples:"
echo "  /ai list files sorted by size"
echo "  /ia what is 25 * 4"
echo "  /ai what day is today"
