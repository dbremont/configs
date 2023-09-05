function alias_if_exists() {
  # Does the alias only if the aliased program is installed
    if command -v $2 > /dev/null; then
        alias "$1"="$2"
    fi
}

path_remove() {
    PATH=$(echo -n "$PATH" | awk -v RS=: -v ORS=: "\$0 != \"$1\"" | sed 's/:$//')
}

path_append() {
    path_remove "$1"
    PATH="${PATH:+"$PATH:"}$1"
}

path_prepend() {
    path_remove "$1"
    PATH="$1${PATH:+":$PATH"}"
}

here() {
    local loc
    if [ "$#" -eq 1 ]; then
        loc=$(realpath "$1")
    else
        loc=$(realpath ".")
    fi
    ln -sfn "${loc}" "$HOME/.shell.here"
    echo "here -> $(readlink $HOME/.shell.here)"
}

there="$HOME/.shell.here"

there() {
    cd "$(readlink "${there}")"
}


setTerminalText () {
    # echo works in bash & zsh
    local mode=$1 ; shift
    echo -ne "\033]$mode;$@\007"
}

# Like a local wormhole
function snd() {
    mkdir -p /tmp/passage
    /bin/cp $1 /tmp/passage
    /bin/rm /tmp/passage/last &>/dev/null || true
    echo $1 > /tmp/passage/last
}

function rcv() {
    file=$(cat /tmp/passage/last)
    /bin/cp -i "/tmp/passage/$file" $file
    /bin/rm "/tmp/passage/$file"
}


# Complete from google
function auto() {
    url='https://www.google.com/complete/search?client=hp&hl=en&xhr=t'
    # NB: user-agent must be specified to get back UTF-8 data!
    curl -H 'user-agent: Mozilla/5.0' -sSG --data-urlencode "q=$*" "$url" |
        jq -r ".[1][][0]" |
        sed 's,</\?b>,,g'
}