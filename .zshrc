# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
  colored-man-pages
  zsh-autosuggestions
  zsh-syntax-highlighting
  history-substring-search
  vi-mode
  fzf
)

fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src

source $ZSH/oh-my-zsh.sh

# ─── Vi mode cursor shape ──────────────────────────────────────────────────────
# beam = insert mode, block = normal mode
function zle-keymap-select {
  if [[ $KEYMAP == vicmd ]]; then
    echo -ne '\e[2 q'  # steady block
  else
    echo -ne '\e[6 q'  # steady beam
  fi
}
zle -N zle-keymap-select
echo -ne '\e[6 q'
preexec() { echo -ne '\e[6 q' }

# Uncomment to use jk as Escape (like nvim):
# bindkey -M viins 'jk' vi-cmd-mode

# ─── History ──────────────────────────────────────────────────────────────────
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS
setopt SHARE_HISTORY

# ─── Smart replacements (falls back to default if not installed) ───────────────

# eza → ls (better ls with icons, git status, human sizes by default)
if command -v eza &>/dev/null; then
  alias ls='eza --icons'
  alias ll='eza -la --icons --git'
  alias ltc='eza --tree -L 2 | clip.exe'   # copy tree to clipboard (WSL)
else
  alias ll='ls -lah'
fi

# bat → cat (syntax highlighting, line numbers)
# WSL installs as batcat, other systems as bat
if command -v batcat &>/dev/null; then
  alias cat='batcat'
elif command -v bat &>/dev/null; then
  alias cat='bat'
fi

# zoxide → cd (smart jumping, learns your habits)
# z <name>  → jump to most visited match
# zi        → fuzzy picker of visited dirs
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
fi

# fzf (Ctrl+r, Ctrl+t, Alt+c — just works if installed, nothing breaks if not)
if command -v fzf &>/dev/null; then
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --preview "batcat --color=always {} 2>/dev/null || cat {}" --preview-window=hidden --bind "?:toggle-preview"'

  # use fd as engine if available (faster, respects .gitignore, no node_modules)
  if command -v fdfind &>/dev/null; then
    export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  fi
fi

# ripgrep → grep (faster, git-aware — used by nvim telescope automatically)
if command -v rg &>/dev/null; then
  alias grep='rg'
fi

# ─── Aliases ──────────────────────────────────────────────────────────────────
[ -f ~/.zsh_aliases ] && source ~/.zsh_aliases

# ─── Prompt ───────────────────────────────────────────────────────────────────
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ─── mise ─────────────────────────────────────────────────────────────────────
if command -v mise &>/dev/null; then
  eval "$(mise activate zsh)"
fi

# ─── fnox ─────────────────────────────────────────────────────────────────────
if command -v fnox &>/dev/null; then
  eval "$(fnox activate zsh)"
fi

#auto run tmux
