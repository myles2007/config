#! /bin/zsh

source <(antibody init)
eval $(gdircolors ~/.dircolors)

# Better ls alias for Mac
alias ls='gls --color'

setopt COMPLETE_IN_WORD

# Enable save history of 1000 cmds, write to a certain file
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

# Export some global settings
export EDITOR="vim"
export LESS="-R"

autoload -Uz compinit
typeset -i updated_at=$(date +'%j' -r ~/.zcompdump 2>/dev/null || stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)
if [ $(date +'%j') != $updated_at ]; then
    compinit -i
else
    compinit -C -i
fi

# compinit -i
# autoload -U bashcompinit
# bashcompinit

PLUGINS="$HOME/.zsh_plugins"
antibody bundle < $PLUGINS


# ---- Completion ----
# Force rehash when command not found
_force_rehash() {
    (( CURRENT == 1 )) && rehash
    return 1
}


zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

# forces zsh to realize new commands
zstyle ':completion:*' completer _oldlist _expand _force_rehash _complete _match _ignored _approximate

# matches case insensitive for lowercase
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# pasting with tabs doesn't perform completion
zstyle ':completion:*' insert-tab pending

# menu if nb items > 2
zstyle ':completion:*' menu select=2

# Activate virtualenv bottles named .venv automatically upon cd
function chpwd() {
    if [ -d .venv ]; then
        . .venv/bin/activate
    fi
}

# If a home venv exists, turn it on
[[ -d ~/.venv  ]] && . ~/.venv/bin/activate

function awsclearshell {
    echo unset AWS_SESSION_TOKEN
    echo unset AWS_ACCESS_KEY_ID
    echo unset AWS_SECRET_ACCCESS_KEY
}

function awsclear {
    eval $(awsclearshell)
}

function awsrole {
    aws sts get-caller-identity --profile $1 > /dev/null
    eval $(jq -r '.Credentials | "export AWS_ACCESS_KEY_ID="+.AccessKeyId, "export AWS_SECRET_ACCESS_KEY="+.SecretAccessKey, "export AWS_SESSION_TOKEN="+.SessionToken' < ~/.aws/cli/cache/$1--*.json)
}
