#!/bin/bash
set -e

echo "==> Installing dependencies..."
sudo apt-get update -q
sudo apt-get install -y zsh curl git

echo "==> Installing oh-my-zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "oh-my-zsh already installed, skipping"
fi

echo "==> Installing powerlevel10k..."
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    ~/.oh-my-zsh/custom/themes/powerlevel10k
else
  git -C ~/.oh-my-zsh/custom/themes/powerlevel10k pull
fi

echo "==> Installing zsh plugins..."
declare -A plugins=(
  ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions"
  ["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting"
  ["zsh-completions"]="https://github.com/zsh-users/zsh-completions"
)

for plugin in "${!plugins[@]}"; do
  dir="$HOME/.oh-my-zsh/custom/plugins/$plugin"
  if [ ! -d "$dir" ]; then
    git clone "${plugins[$plugin]}" "$dir"
  else
    git -C "$dir" pull
  fi
done

echo "==> Installing mise..."
if ! command -v mise &>/dev/null; then
  curl https://mise.run | sh
else
  echo "mise already installed, skipping"
fi

echo "==> Symlinking dotfiles..."
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.p10k.zsh ~/.p10k.zsh
ln -sf ~/dotfiles/.zsh_aliases ~/.zsh_aliases

echo "==> Setting zsh as default shell..."
chsh -s $(which zsh)

echo "==> Symlinking mise config..."
mkdir -p ~/.config/mise
ln -sf ~/dotfiles/mise-config.toml ~/.config/mise/config.toml

echo "==> Installing mise global tools..."
~/.local/bin/mise install

echo "Done! Restart your shell or run: exec zsh"
