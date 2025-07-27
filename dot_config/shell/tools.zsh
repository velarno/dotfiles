# inits third-party tools
eval "$(zoxide init --cmd cd zsh)"
eval "$(thefuck --alias)"

if [[ -f "/opt/homebrew/bin/brew" ]] then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

source <(fzf --zsh)
