#!/bin/bash
# filepath: /home/kiki/gitclone/dotfiles/install.sh

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect package manager
detect_package_manager() {
    if command -v pacman &> /dev/null; then
        echo "pacman"
    elif command -v apt &> /dev/null; then
        echo "apt"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    elif command -v zypper &> /dev/null; then
        echo "zypper"
    else
        echo "unknown"
    fi
}

# Install DWM build dependencies
install_dwm_deps() {
    local pm=$(detect_package_manager)
    
    print_info "Installing DWM build dependencies..."
    
    case $pm in
        "pacman")
            sudo pacman -S --needed base-devel git libx11 libxcb libxinerama libxft imlib2
            ;;
        "apt")
            sudo apt update
            sudo apt install -y build-essential git libx11-dev libx11-xcb-dev libxcb-res0-dev libxinerama-dev libxft-dev libimlib2-dev
            ;;
        "dnf")
            sudo dnf install -y @development-tools git libX11-devel libXcb-devel libXinerama-devel libXft-devel imlib2-devel
            ;;
        "zypper")
            sudo zypper install -y -t pattern devel_basis
            sudo zypper install -y git libX11-devel libXcb-devel libXinerama-devel libXft-devel imlib2-devel
            ;;
        *)
            print_error "Unknown package manager. Please install DWM dependencies manually."
            return 1
            ;;
    esac
    
    print_success "DWM build dependencies installed"
}

# Install main packages
install_main_packages() {
    local pm=$(detect_package_manager)
    
    print_info "Installing main packages..."
    
    case $pm in
        "pacman")
            # Core packages
            sudo pacman -S --needed xorg-xbacklight picom volumeicon dash nitrogen arandr \
                networkmanager network-manager-applet dunst blueman xclip pcmanfm firefox \
                code rofi fish neovim helix playerctl maim
            
            # Optional packages
            if pacman -Ss caffeine &> /dev/null; then
                sudo pacman -S --needed caffeine
            else
                print_warning "caffeine not found in repos, skipping..."
            fi
            ;;
        "apt")
            sudo apt update
            sudo apt install -y xbacklight picom volumeicon dash nitrogen arandr \
                network-manager network-manager-gnome dunst blueman-applet xclip pcmanfm \
                firefox-esr rofi fish neovim helix playerctl maim
            
            # Try to install code (VS Code)
            if ! command -v code &> /dev/null; then
                print_info "Installing VS Code..."
                wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
                sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
                sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
                sudo apt update
                sudo apt install -y code
            fi
            
            # Optional packages
            if apt list caffeine 2>/dev/null | grep -q caffeine; then
                sudo apt install -y caffeine
            else
                print_warning "caffeine not found in repos, skipping..."
            fi
            ;;
        "dnf")
            sudo dnf install -y xbacklight picom volumeicon dash nitrogen arandr \
                NetworkManager-applet dunst blueman xclip pcmanfm firefox \
                rofi fish neovim helix playerctl maim
            
            # Try to install code
            if ! command -v code &> /dev/null; then
                sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
                sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
                sudo dnf install -y code
            fi
            ;;
        *)
            print_error "Unknown package manager. Please install packages manually from README.md"
            return 1
            ;;
    esac
    
    print_success "Main packages installed"
}

# Install external tools
install_external_tools() {
    print_info "Installing external tools..."
    
    # Install Rust if not present
    if ! command -v cargo &> /dev/null; then
        print_info "Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source ~/.cargo/env
        print_success "Rust installed"
    fi
    
    # Install Starship
    if ! command -v starship &> /dev/null; then
        print_info "Installing Starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
        print_success "Starship installed"
    fi
    
    # Install betterlockscreen
    if ! command -v betterlockscreen &> /dev/null; then
        print_info "Installing betterlockscreen..."
        wget https://github.com/betterlockscreen/betterlockscreen/archive/refs/heads/main.zip
        unzip -q main.zip
        cd betterlockscreen-main/
        chmod u+x betterlockscreen
        sudo cp betterlockscreen /usr/local/bin/
        cd ..
        rm -rf betterlockscreen-main/ main.zip
        print_success "betterlockscreen installed"
    fi
    
    # Install pokemon-colorscripts
    if ! command -v pokemon-colorscripts &> /dev/null; then
        print_info "Installing pokemon-colorscripts..."
        git clone https://gitlab.com/phoneybadger/pokemon-colorscripts.git
        cd pokemon-colorscripts/
        sudo ./install.sh
        cd ..
        rm -rf pokemon-colorscripts/
        print_success "pokemon-colorscripts installed"
    fi
}

# Check if running from correct directory
if [ ! -f "README.md" ] || [ ! -d ".config" ]; then
    print_error "Please run this script from the dotfiles directory"
    exit 1
fi

print_info "Starting dotfiles installation..."

# Ask user what to install
echo "What would you like to install?"
echo "1) Everything (dotfiles + dependencies + external tools)"
echo "2) Only dotfiles"
echo "3) Only dependencies"
echo "4) Custom selection"
read -p "Enter your choice (1-4): " choice

case $choice in
    1)
        INSTALL_DOTFILES=true
        INSTALL_DEPS=true
        INSTALL_EXTERNAL=true
        ;;
    2)
        INSTALL_DOTFILES=true
        INSTALL_DEPS=false
        INSTALL_EXTERNAL=false
        ;;
    3)
        INSTALL_DOTFILES=false
        INSTALL_DEPS=true
        INSTALL_EXTERNAL=false
        ;;
    4)
        read -p "Install dotfiles? (y/n): " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]] && INSTALL_DOTFILES=true || INSTALL_DOTFILES=false
        
        read -p "Install dependencies? (y/n): " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]] && INSTALL_DEPS=true || INSTALL_DEPS=false
        
        read -p "Install external tools? (y/n): " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]] && INSTALL_EXTERNAL=true || INSTALL_EXTERNAL=false
        ;;
    *)
        print_error "Invalid choice"
        exit 1
        ;;
esac

# Install dependencies first
if [ "$INSTALL_DEPS" = true ]; then
    install_dwm_deps
    install_main_packages
fi

# Install external tools
if [ "$INSTALL_EXTERNAL" = true ]; then
    install_external_tools
fi

# Install dotfiles
if [ "$INSTALL_DOTFILES" = true ]; then
    # Create necessary directories
    print_info "Creating necessary directories..."
    mkdir -p ~/.config
    mkdir -p ~/.themes
    mkdir -p ~/.local
    mkdir -p ~/.cargo/bin

    # Install dotfiles
    print_info "Installing configuration files..."
    cp -rf .config/ ~/.config/
    print_success "Copied .config directory"

    cp -rf .themes ~/.themes/
    print_success "Copied .themes directory"

    cp -rf .local/ ~/.local/
    print_success "Copied .local directory"

    cp .Xresources ~/
    print_success "Copied .Xresources"

    cp -r walls ~/
    print_success "Copied wallpapers"

    # Check if Rust is installed
    if ! command -v cargo &> /dev/null; then
        print_warning "Rust/Cargo not found. Please install Rust from https://www.rust-lang.org/tools/install"
        print_warning "Skipping Rust project compilation..."
    else
        print_info "Rust found. Compiling Rust projects..."
        
        # Compile powermenu
        if [ -d "powermenu" ]; then
            print_info "Building powermenu..."
            cd powermenu/
            cargo build --release
            cp target/release/powermenu ~/.cargo/bin/ 2>/dev/null || cp target/debug/powermenu ~/.cargo/bin/
            cd ..
            print_success "Powermenu compiled and installed"
        else
            print_warning "powermenu directory not found, skipping..."
        fi
        
        # Compile dwm-cheatsheet
        if [ -d "dwm-cheatsheet" ]; then
            print_info "Building dwm-cheatsheet..."
            cd dwm-cheatsheet/
            cargo build --release
            cp target/release/dwm-cheatsheet ~/.cargo/bin/ 2>/dev/null || cp target/debug/dwm-cheatsheet ~/.cargo/bin/
            cd ..
            print_success "DWM cheatsheet compiled and installed"
        else
            print_warning "dwm-cheatsheet directory not found, skipping..."
        fi
    fi

    # Compile DWM components
    print_info "Compiling DWM components..."

    # Check for build dependencies
    if ! command -v make &> /dev/null; then
        print_error "make not found. Please install build dependencies first."
        exit 1
    fi

    # Compile chadwm (DWM)
    if [ -d "$HOME/.config/chadwm/chadwm" ]; then
        print_info "Compiling chadwm..."
        cd ~/.config/chadwm/chadwm/
        rm -rf config.h 2>/dev/null || true
        if sudo make install; then
            print_success "chadwm compiled and installed"
        else
            print_error "Failed to compile chadwm. Check dependencies."
        fi
        cd - > /dev/null
    else
        print_warning "chadwm directory not found at ~/.config/chadwm/chadwm/"
    fi

    # Compile st terminal
    if [ -d "$HOME/.config/st" ]; then
        print_info "Compiling st terminal..."
        cd ~/.config/st/
        if sudo make install; then
            print_success "st terminal compiled and installed"
        else
            print_error "Failed to compile st terminal. Check dependencies."
        fi
        cd - > /dev/null
    else
        print_warning "st directory not found at ~/.config/st/"
    fi

    # Compile dmenu
    if [ -d "$HOME/.config/dmenu" ]; then
        print_info "Compiling dmenu..."
        cd ~/.config/dmenu/
        if sudo make install; then
            print_success "dmenu compiled and installed"
        else
            print_error "Failed to compile dmenu. Check dependencies."
        fi
        cd - > /dev/null
    else
        print_warning "dmenu directory not found at ~/.config/dmenu/"
    fi
fi

print_success "Installation completed!"

print_info "Next steps:"
echo "1. Add ~/.cargo/bin to your PATH if not already done"
echo "2. Logout and login again or restart your display manager"
echo "3. Run 'betterlockscreen -u /path/to/image' to set lockscreen wallpaper"

# Check if ~/.cargo/bin is in PATH
if [[ ":$PATH:" != *":$HOME/.cargo/bin:"* ]]; then
    print_warning "~/.cargo/bin is not in your PATH. Add it to your shell configuration:"
    echo "export PATH=\"\$HOME/.cargo/bin:\$PATH\""
fi

print_info "Installation script finished!"