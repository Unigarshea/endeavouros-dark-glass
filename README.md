# EndeavourOS KDE Dark-Glass Rice

Minimal, safe and opinionated rice for EndeavourOS (Wayland) with KDE Plasma.

Goal
- Dark + translucent "glass" visual (Breeze Dark + blur + Kvantum glass hints)
- Safe installer: backups, --dry-run, optional pacman/AUR installs
- Rounded window corners and KWin blur guidance
- Kitty configured with translucency
- Zsh configured with zsh-autosuggestions, zsh-syntax-highlighting and fzf integration (user needs to install plugins)

What's included
- install.sh — safe installer
- packages.txt / aur-packages.txt — suggested packages
- dotfiles/ — KDE, KWin, Kitty and Zsh configs
- notes.txt — manual steps & how-tos

Usage (quick)
1. Clone repo locally and inspect files.
2. Simulate: ./install.sh --dry-run
3. Run: ./install.sh

Backups
- The installer copies touched ~/.config files into ~/dotfiles-backup-<timestamp> before overwriting.

Customize
- Edit dotfiles/.config/kdeglobals, dotfiles/.config/kwinrc, dotfiles/.config/kitty/kitty.conf or dotfiles/.zshrc to taste.
