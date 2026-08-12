#!/usr/bin/env bash
# EndeavourOS KDE Dark-Glass rice installer (safe)
# Adds optional rounded corners, blur/translucency support, kitty transparency and zsh setup notes
# Usage: ./install.sh [--dry-run] [--no-packages]
set -euo pipefail

DRY=false
NO_PKGS=false
TIMESTAMP="$(date +%Y%m%d%H%M%S)"
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_DIR="$ROOT_DIR/dotfiles"

for arg in "$@"; do
  case $arg in
    --dry-run) DRY=true ;;
    --no-packages) NO_PKGS=true ;;
    -h|--help)
      echo "Usage: ./install.sh [--dry-run] [--no-packages]"
      exit 0
      ;;
  esac
done

echodo() {
  if $DRY; then
    echo "[DRY-RUN] $*"
  else
    echo "[RUN] $*"
    eval "$@"
  fi
}

# Basic checks
if [[ "$(uname -s)" != "Linux" ]]; then
  echo "This script is intended for Linux."
  exit 1
fi

echo "Preparing installer (dark-glass rice) — DRY=$DRY"

# 1) Backup relevant ~/.config files
BACKUP_DIR="$HOME/dotfiles-backup-$TIMESTAMP"
echodo mkdir -p "$BACKUP_DIR"
echo "Backing up existing ~/.config to $BACKUP_DIR (only files that might be touched)..."
if $DRY; then
  echo "[DRY-RUN] rsync -av --progress --backup --suffix=.bak.$TIMESTAMP --include='/.config/***' --exclude='*' \"$HOME/\" \"$BACKUP_DIR/\""
else
  rsync -av --progress --backup --suffix=".bak.$TIMESTAMP" \
    --include='/.config/***' --exclude='*' "$HOME/" "$BACKUP_DIR/" || true
fi

# 2) Install pacman packages
if ! $NO_PKGS; then
  PACKAGES_FILE="$ROOT_DIR/packages.txt"
  if [[ -f "$PACKAGES_FILE" ]]; then
    PKGS=$(grep -Ev '^\s*(#|$)' "$PACKAGES_FILE" | tr '\n' ' ')
    if [[ -n "$PKGS" ]]; then
      echo "Pacman packages to install: $PKGS"
      if $DRY; then
        echo "[DRY-RUN] sudo pacman -Syu --noconfirm $PKGS"
      else
        read -rp "Install pacman packages? [y/N] " yn
        if [[ "$yn" =~ ^[Yy]$ ]]; then
          sudo pacman -Syu --noconfirm $PKGS
        else
          echo "Skipping pacman package installation."
        fi
      fi
    fi
  fi

  # AUR packages (if any)
  AUR_FILE="$ROOT_DIR/aur-packages.txt"
  if [[ -f "$AUR_FILE" ]]; then
    AUR_PKGS=$(grep -Ev '^\s*(#|$)' "$AUR_FILE" | tr '\n' ' ')
    if [[ -n "$AUR_PKGS" ]]; then
      if command -v yay >/dev/null 2>&1 || command -v paru >/dev/null 2>&1; then
        AUR_HELPER=$(command -v yay || command -v paru)
        if $DRY; then
          echo "[DRY-RUN] $AUR_HELPER -S --noconfirm $AUR_PKGS"
        else
          read -rp "Install AUR packages with $AUR_HELPER? [y/N] " yn
          if [[ "$yn" =~ ^[Yy]$ ]]; then
            $AUR_HELPER -S --noconfirm $AUR_PKGS
          else
            echo "Skipping AUR installation."
          fi
        fi
      else
        echo "AUR helper (yay/paru) not found. To install AUR packages, install yay/paru or run them manually."
      fi
    fi
  fi
fi

# 3) Deploy dotfiles (rsync, with backups)
if [[ -d "$DOTFILES_DIR" ]]; then
  echo "Deploying dotfiles from $DOTFILES_DIR to $HOME"
  if $DRY; then
    echo "[DRY-RUN] rsync -av --progress --backup --suffix=.bak.$TIMESTAMP \"$DOTFILES_DIR/\" \"$HOME/\""
  else
    rsync -av --progress --backup --suffix=".bak.$TIMESTAMP" "$DOTFILES_DIR/" "$HOME/" || true
  fi
else
  echo "No dotfiles directory found at $DOTFILES_DIR"
fi

# 4) Kvantum: ensure config directory exists (user may install themes manually)
if $DRY; then
  echo "[DRY-RUN] mkdir -p \"$HOME/.config/Kvantum/\""
else
  mkdir -p "$HOME/.config/Kvantum/"
fi

# 5) Kitty config dir
if $DRY; then
  echo "[DRY-RUN] mkdir -p \"$HOME/.config/kitty/\""
else
  mkdir -p "$HOME/.config/kitty/"
fi

# 6) Ask about applying rounded corners and blur settings via kwriteconfig5
if ! $DRY; then
  read -rp "Apply KWin rounded corners + blur settings automatically (uses kwriteconfig5)? [y/N] " apply_ks
  if [[ "$apply_ks" =~ ^[Yy]$ ]]; then
    echo "Applying KWin hints (best-effort). You may need to enable the Blur effect and set decoration radius in System Settings."
    # Best-effort: enable compositing and set general blur/strength hints
    echodo kwriteconfig5 --file kwinrc --group Compositing --key Enabled true
    echodo kwriteconfig5 --file kwinrc --group Compositing --key BlurStrength 0.8
    # KDecoration2 themes may expose 'radius' in org.kde.kdecoration2; set a common key if available
    echodo kwriteconfig5 --file kwinrc --group org.kde.kdecoration2 --key radius 10
    # Note: some Plasma versions ignore radius key; user might need to pick a decoration theme with rounded corners
  else
    echo "Skipped automatic KWin changes. You can enable blur and set decoration radius manually in System Settings."
  fi
else
  echo "[DRY-RUN] (skipping automatic KWin changes in dry-run)"
fi

# 7) Ensure user local dirs exist
if $DRY; then
  echo "[DRY-RUN] mkdir -p \"$HOME/.local/share/plasma/\" \"$HOME/.local/share/icons/\""
else
  mkdir -p "$HOME/.local/share/plasma/" "$HOME/.local/share/icons/"
fi

# 8) Post-install: reload plasmashell (best-effort)
echo "Attempting to reload Plasma shell (if running)..."
if $DRY; then
  echo "[DRY-RUN] kquitapp5 plasmashell && kstart5 plasmashell"
else
  if command -v kquitapp5 >/dev/null 2>&1; then
    kquitapp5 plasmashell || true
    kstart5 plasmashell || true
    echo "Plasma shell reloaded (if available)."
  else
    echo "kquitapp5 not found. Please log out and back in or restart SDDM to apply changes."
  fi
fi

# 9) Final notes
echo "Done. Backups are in: $BACKUP_DIR"

echo "Next: check dotfiles/notes.txt for manual steps (Kvantum themes, enabling Blur effect, installing zsh plugins)."
