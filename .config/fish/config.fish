#####################################
##==> Variables
#####################################
function shenv; set -gx $argv; end
source ~/.env

#####################################
##==> Aliases
#####################################
alias cls="clear"
alias g="git"
alias n="nvim"
alias m="micro"

### ALIASES ###
# vim and emacs
alias vim="nvim"
alias emacs="emacsclient -c -a 'emacs'" # GUI versions of Emacs
alias em="/usr/bin/emacs -nw" # Terminal version of Emacs
alias rem="killall emacs || echo 'Emacs server not running'; /usr/bin/emacs --daemon" # Kill Emacs and restart daemon..

# Changing "ls" to "eza"
alias ls='eza -al --color=always --group-directories-first' # my preferred listing
alias la='eza -a --color=always --group-directories-first'  # all files and dirs
alias ll='eza -l --color=always --group-directories-first'  # long format
alias lt='eza -aT --color=always --group-directories-first' # tree listing
alias l.='eza -al --color=always --group-directories-first ../' # ls on the PARENT directory
alias l..='eza -al --color=always --group-directories-first ../../' # ls on directory 2 levels up
alias l...='eza -al --color=always --group-directories-first ../../../' # ls on directory 3 levels up

# pacman and yay
alias pacsyu='sudo pacman -Syu'                  # update only standard pkgs
alias pacsyyu='sudo pacman -Syyu'                # Refresh pkglist & update standard pkgs
alias parsua='paru -Sua --noconfirm'             # update only AUR pkgs (paru)
alias parsyu='paru -Syu --noconfirm'             # update standard pkgs and AUR pkgs (paru)
alias unlock='sudo rm /var/lib/pacman/db.lck'    # remove pacman lock
alias orphan='sudo pacman -Rns $(pacman -Qtdq)' # remove orphaned packages (DANGEROUS!)

# get fastest mirrors
alias mirror="sudo reflector -f 30 -l 30 --number 10 --verbose --save /etc/pacman.d/mirrorlist"
alias mirrord="sudo reflector --latest 50 --number 20 --sort delay --save /etc/pacman.d/mirrorlist"
alias mirrors="sudo reflector --latest 50 --number 20 --sort score --save /etc/pacman.d/mirrorlist"
alias mirrora="sudo reflector --latest 50 --number 20 --sort age --save /etc/pacman.d/mirrorlist"

# adding flags
alias df='df -h'               # human-readable sizes
alias free='free -m'           # show sizes in MB
alias grep='grep --color=auto' # colorize output (good for log files)

# ps
alias psa="ps auxf"
alias psgrep="ps aux | grep -v grep | grep -i -e VSZ -e"
alias psmem='ps auxf | sort -nr -k 4'
alias pscpu='ps auxf | sort -nr -k 3'

# Merge Xresources
alias merge='xrdb -merge ~/.Xresources'

# git
alias addup='git add -u'
alias addall='git add .'
alias branch='git branch'
alias checkout='git checkout'
alias clone='git clone'
alias commit='git commit -m'
alias fetch='git fetch'
alias pull='git pull origin'
alias push='git push origin'
alias stat='git status'  # 'status' is protected name so using 'stat' instead
alias tag='git tag'
alias newtag='git tag -a'

# get error messages from journalctl
alias jctl="journalctl -p 3 -xb"

# gpg encryption
# verify signature for isos
alias gpg-check="gpg2 --keyserver-options auto-key-retrieve --verify"
# receive the key of a developer
alias gpg-retrieve="gpg2 --keyserver-options auto-key-retrieve --receive-keys"

# change your default USER shell
alias tobash="chsh $USER -s /bin/bash && echo 'Log out and log back in for change to take effect.'"
alias tozsh="chsh $USER -s /bin/zsh && echo 'Log out and log back in for change to take effect.'"
alias tofish="chsh $USER -s /bin/fish && echo 'Log out and log back in for change to take effect.'"

# bigger font in tty and regular font in tty
alias bigfont="setfont ter-132b"
alias regfont="setfont default8x16"

# bare git repo alias for managing my dotfiles
alias config="/usr/bin/git --git-dir=$HOME/dotfiles --work-tree=$HOME"

# termbin
alias tb="nc termbin.com 9999"

# the terminal rickroll
alias rr='curl -s -L https://raw.githubusercontent.com/keroserene/rickrollrc/master/roll.sh | bash'


#####################################
##==> Custom Functions
#####################################
function wget
    command wget --hsts-file="$XDG_DATA_HOME/wget-hsts" $argv
end

function nvidia-settings
    mkdir -p $XDG_CONFIG_HOME/nvidia/
    command nvidia-settings --config="$XDG_CONFIG_HOME/nvidia/settings" $argv
end

#####################################
##==> Interactive Session Settings
#####################################
if status is-interactive

end

#####################################
##==> Shell Customization
#####################################
starship init fish | source
set fish_greeting

#####################################
##==> Development Tools
#####################################
##==> Pyenv
pyenv init - | source

#####################################
##==> Fun Stuff
#####################################
pokemon-colorscripts --no-title -s -r 1,3,6
