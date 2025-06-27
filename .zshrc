source /Users/leonata/dev/agkozak-zsh-prompt/agkozak-zsh-prompt.plugin.zsh

if [[ -z "$TMUX" ]]; then
  tmux new-session -A -s default
fi
