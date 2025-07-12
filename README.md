# dotfiles

### for system stuff use
[Chris titus linutil](https://github.com/ChrisTitusTech/linutil)


## Installation

```sh
git clone https://github.com/KyokoSpl/dotfiles
cd dotfiles
cp -rf .config/ ~/.config/
cp -rf .themes ~/.themes/
cp -rf .local/ ~/.local/
cp .Xresources ~/
cp -r walls ~/

```

### DWM

> [!NOTE]
> You may want to keep the source directories of the tools you download in a suitable location for future reference as you may need to recompile them to apply configuration changes.

<details>
  <summary>Arch</summary>

  Install dependencies:

  ```sh
  sudo pacman -S --needed base-devel extra/git extra/libx11 extra/libxcb extra/libxinerama extra/libxft extra/imlib2
  ```

  If you find yourself missing a library then this can usually be found by searching for the file name using pacman:

  ```sh
  $ pacman -F Xlib-xcb.h
  extra/libx11 1.6.12-1 [installed: 1.7.2-1]
  usr/include/X11/Xlib-xcb.h
  ```

</details>

<details>
  <summary>Debian/Ubuntu</summary>

  Install dependencies:

  ```sh
  sudo apt install build-essential git libx11-dev libx11-xcb-dev libxcb-res0-dev libxinerama-dev libxft-dev libimlib2-dev
  ```

  It is worth checking the version of gcc on debian based systems as they may come with older implementations that can result in compilation errors.

  ```sh
  gcc --version
  ```

  You would expect at least v8.x or above here.

  If you find yourself missing a library then this can usually be found by searching for the file name using apt-file, a tool that have to be installed separately:

  ```sh
  $ sudo apt install apt-file
  $ sudo apt-file update
  $ apt-file search xcb/res.h
  libxcb-res0-dev: /usr/include/xcb/res.h
  ```

</details>



- Compiling
```sh
cd ~/.config/chadwm/chadwm/
sudo make install
```

- if problems with logging in occur reffer to [chadwm](https://github.com/siduck/chadwm)
    - the dwm build is based on it with a lot of custimisation for keybinds layout and workspace behavior
    - also refer to this if u want the eww button next to the workspace indicator to work

### St terminal

```sh
cd ~/.config/st/
sudo make install
```
### dmenu
- used for dm-scripts like screenshots and so on
```sh
cd ~/.config/dmenu
sudo make install
```


### powermenu

- using my own powermenu written in RUST

- install rust according to their [instructions](https://www.rust-lang.org/tools/install)

```sh
git clone https://github.com/KyokoSpl/powermenu
cd powermenu/
git checkout KyokoSpl-patch-1
cargo build
cp target/debug/powermenu ~/.cargo/bin/
```


### pkgs to install
- xbacklight
- picom
- volumeicon
- dash
- nitrogen
- arandr
- betterlockscreen (if not in your distro repos: [install](https://github.com/betterlockscreen/betterlockscreen?tab=readme-ov-file#installation)
- nm-applet (Networkmanager)
- dunst
- blueman-applet (blueman)
- caffeine-indicator (if distro has it)
- tmux 
- xclip
- pcmanfm
- firefox
- code
- rofi
- fish
- starship [install](https://starship.rs/guide/)
- Neovim (v 9+)
- Helix
- pokemon colorscript [install](https://gitlab.com/phoneybadger/pokemon-colorscripts#on-other-distros-and-macos)
- playerctl
- maim

