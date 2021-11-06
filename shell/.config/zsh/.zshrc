# Environment setup
if [ -f ~/.env ]; then
    source ~/.env
fi

# ALIASES
if [ -f ~/.aliases ]; then
    source ~/.aliases
fi

# LOCAL ENV
if [ -f ~/.local-env ]; then
    source ~/.local-env
fi
