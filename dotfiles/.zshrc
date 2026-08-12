# Zsh configuration (minimal for autosuggestions/completions/fzf)
# Put this file at ~/.zshrc (the installer will copy it to your home)

# Path and history
export ZSH="$HOME/.oh-my-zsh"
HISTFILE=$HOME/.local/share/zsh/history
HISTSIZE=5000
SAVEHIST=5000

# Use fzf if available for fuzzy completion
if command -v fzf >/dev/null 2>&1; then
  source /usr/share/fzf/key-bindings.zsh 2>/dev/null || true
fi

# zsh plugins (install zsh-autosuggestions and zsh-syntax-highlighting first)
if [[ -d "$HOME/.local/share/zsh-autosuggestions" ]]; then
  source "$HOME/.local/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi
if [[ -d "$HOME/.local/share/zsh-syntax-highlighting" ]]; then
  source "$HOME/.local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# Completion
autoload -Uz compinit && compinit

# Prompt: simple but informative
export PROMPT='%F{cyan}%n@%m%f %F{yellow}%~%f %# '

# Enable suggestions acceptance with right-arrow
bindkey '^[[C' autosuggest-accept

# Aliases
alias ll='ls -alF'
alias la='ls -A'

# If you use Oh-My-Zsh, keep default settings; otherwise this file is fine standalone.
