#! /bin/zsh
#
# Uncomment line below to enable profiling of load times
# zmodload zsh/zprof

export NVM_DIR="$HOME/.nvm"
zstyle ':omz:plugins:nvm' lazy yes

eval $(gdircolors ~/.dircolors)

eval "$(starship init zsh)"
export VIRTUAL_ENV_DISABLE_PROMPT=1 # <--- Don't have venv modify the prompt when active, starship includes it

# Alias to interact with bare git repository for configuration.
# Used to add, update, delete, or otherwise manager configurations.
# Example: git checkout <branch> to get a configuration represented
#          by a specific branch.
alias config='/usr/bin/git --git-dir=$HOME/.configurations/ --work-tree=$HOME'

eval "$(direnv hook zsh)" # <--- Enable direnv (auto load/unload .envrc files after approval)

# Better ls alias for Mac
alias ls='gls --color'

setopt COMPLETE_IN_WORD

# Enable save history of 1000 cmds, write to a certain file
HISTFILE=~/.histfile
HISTSIZE=5000
SAVEHIST=10000

setopt    appendhistory     # Append history to the history file (no overwriting)
setopt    sharehistory      # Share history across terminals
setopt    incappendhistory  # Immediately append to the history file, not just when a term is killed

# Export some global settings
export EDITOR="nvim"
export LESS="-R"

autoload -Uz compinit
typeset -i updated_at=$(date +'%j' -r ~/.zcompdump 2>/dev/null || stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)
if [ $(date +'%j') != $updated_at ]; then
    compinit -i
else
    compinit -C -i
fi

autoload bashcompinit
bashcompinit
complete -C '/usr/local/bin/aws_completer' aws

# To update, run: antibody bundle < ~/.zsh_plugins.txt > ~/.zsh_plugins.sh
source ~/.zsh_plugins.sh


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


eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

function awsclearshell {
    echo unset AWS_SESSION_TOKEN
    echo unset AWS_ACCESS_KEY_ID
    echo unset AWS_SECRET_ACCCESS_KEY
}

function awsclear {
    eval $(awsclearshell)
}

function awsrole {
    aws sts get-caller-identity --duration-in-seconds 900 --profile $1 > /dev/null
    eval $(jq -r '.Credentials | "export AWS_ACCESS_KEY_ID="+.AccessKeyId, "export AWS_SECRET_ACCESS_KEY="+.SecretAccessKey, "export AWS_SESSION_TOKEN="+.SessionToken' < ~/.aws/cli/cache/$1--*.json)
}


secret () {
        output=~/"${1}".$(date +%s).enc
        gpg --encrypt --armor --output ${output} "${1}" && echo "${1} -> ${output}"
}

reveal () {
        output=$(echo "${1}" | rev | cut -c16- | rev)
        gpg --decrypt --output ${output} "${1}" && echo "${1} -> ${output}"
}

export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent
gpg-connect-agent updatestartuptty /bye > /dev/null

function bootstrap_yubikey_gpg {
    chmod 700 ~/.gnupg
    chmod 600 ~/.gnupg/gpg.conf ~/.gnupg/gpg-agent.conf

    # Refreshes shadow keys. You may want to try this command
    # individually if you're getting messages indicating there
    # is no secret key. If it doesn't work the first time, try
    # reinserting the key and running it again.
    gpg --card-status

    gpg --edit-card
}

function update_gpg_ownertrust {
    gpg --export-owner
}

function get_failed_report_factory_executions() {
    STATE_MACHINE_ARN=arn:aws:states:us-east-1:313750358190:stateMachine:ReportFactoryReportProcessStateMachine-prd
    aws --profile ${AWS_PROFILE:?Run this comamnd with AWS_PROFILE set to a non-empty value} stepfunctions list-executions --state-machine-arn $STATE_MACHINE_ARN | jq --raw-output '.executions[] | select(.status == "FAILED") | {arn: .executionArn, startTime: .startDate | todate}'
}

function get_report_factory_executions_as_csv() {
    STATE_MACHINE_ARN=arn:aws:states:us-east-1:313750358190:stateMachine:ReportFactoryReportProcessStateMachine-prd
    aws --profile ${AWS_PROFILE:?Run this comamnd with AWS_PROFILE set to a non-empty value} stepfunctions list-executions --state-machine-arn $STATE_MACHINE_ARN |  \
        jq -r '.executions | map({startDate: .startDate | todate, stopDate: (try (.stopDate | todate) catch "STILL RUNNING"), name: .name, status: .status, executionArn: .executionArn})
                           | (map(keys) | add | unique) as $cols | map(. as $row | $cols | map($row[.])) as $rows | $cols, $rows[] | @csv'
}

function get_report_factory_executions_raw() {
    STATE_MACHINE_ARN=arn:aws:states:us-east-1:313750358190:stateMachine:ReportFactoryReportProcessStateMachine-prd
    aws --profile ${AWS_PROFILE:?Run this comamnd with AWS_PROFILE set to a non-empty value} stepfunctions list-executions --state-machine-arn $STATE_MACHINE_ARN
}

function get_logs_for_machine_execution() {
    EXECUTION_ARN=${1:?An execution ARN must be provided as the first argument}
    AWS_PROFILE=${AWS_PROFILE:?Run this command with AWS_PROFILE set to a non-empty value}
    EXECUTION_LOGSTREAM=$(aws --profile $AWS_PROFILE stepfunctions get-execution-history --execution-arn $EXECUTION_ARN \
                         | jq --raw-output '.events[-2].stateEnteredEventDetails.input | fromjson | .error.Cause | fromjson | .Attempts[0].Container.LogStreamName')
    aws --profile $AWS_PROFILE logs get-log-events --log-group-name /aws/batch/job --log-stream-name $EXECUTION_LOGSTREAM | jq --raw-output '.events[].message'
}

#########################################################################
# From: https://gist.github.com/benkehoe/0d2985e56059437e489314d021be3fbe
# MIT No Attribution
#
# Copyright 2022 Ben Kehoe
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this
# software and associated documentation files (the "Software"), to deal in the Software
# without restriction, including without limitation the rights to use, copy, modify,
# merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# There are lots of well-built tools that completely manage your
# AWS profiles and login and credentials, like aws-vault and AWSume.
# This isn't that.
# I tend to prefer to go as lightweight as possible around AWS-produced tools.
# So all this does is set and unset your AWS_PROFILE environment variable.

# This code requires the AWS CLI v2 to function correctly, because it uses the
# aws configure list-profiles command for validation and auto-completion,
# and this command does not exist in the AWS CLI v1.
# AWS CLI v2 install instructions:
# https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html

# You might also be interested in aws-whoami
# which improves upon `aws sts get-caller-identity`
# https://github.com/benkehoe/aws-whoami
#########################################################################

aws-profile () {
  if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "USAGE:"
    echo "aws-profile              <- print out current value"
    echo "aws-profile PROFILE_NAME <- set PROFILE_NAME active"
    echo "aws-profile --unset      <- unset the env vars"
  elif [ -z "$1" ]; then
    if [ -z "$AWS_PROFILE$AWS_DEFAULT_PROFILE" ]; then
      echo "No profile is set"
      return 1
    else
      echo "$AWS_PROFILE$AWS_DEFAULT_PROFILE"
    fi
  elif [ "$1" = "--unset" ]; then
    AWS_PROFILE=
    AWS_DEFAULT_PROFILE=
    # removing the vars is needed because of https://github.com/aws/aws-cli/issues/5016
    export -n AWS_PROFILE AWS_DEFAULT_PROFILE
  else
    # this check needed because of https://github.com/aws/aws-cli/issues/5546
    # requires AWS CLI v2
    if ! aws configure list-profiles | grep --color=never -Fxq -- "$1"; then
      echo "$1 is not a valid profile"
      return 2
    else
      AWS_DEFAULT_PROFILE=
      export AWS_PROFILE=$1
      export -n AWS_DEFAULT_PROFILE
    fi;
  fi;
}
# completion is kinda slow, operating on the files directly would be faster but more work
# aws configure list-profiles is only available with the AWS CLI v2.
_aws-profile-completer () {
  COMPREPLY=(`aws configure list-profiles | grep --color=never ^${COMP_WORDS[COMP_CWORD]}`)
}
complete -F _aws-profile-completer aws-profile




### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/mylesloffler/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)

# Created by `pipx` on 2022-09-14 14:52:06
export PATH="$PATH:/Users/mylesloffler/.local/bin"

eval "$(_AWS_SSO_UTIL_COMPLETE=source_zsh aws-sso-util)"
