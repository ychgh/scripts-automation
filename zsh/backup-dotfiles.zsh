#!/usr/bin/env zsh
set -euo pipefail

backup_root="${1:-$HOME/backups/dotfiles}"
stamp="$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup_root"
target="$(mktemp -d "$backup_root/${stamp}.XXXXXX")"

for file in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.profile"; do
  [[ -f "$file" ]] && cp "$file" "$target/"
done

echo "Backed up dotfiles to $target"
