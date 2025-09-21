#! /usr/bin/env bash

VERBOSE_LOGGING=${CHEZMOI_ENSURE_BOOTSTRAPPED_VERBOSE:=0}

function log_verbose() {
    if [[ $VERBOSE_LOGGING -eq 1 ]]; then
        echo "$@"
    fi
}

function ensure_homebrew_installed() {
    which -s brew
    if [[ $? != 0 ]] ; then
        curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
        log_verbose "Homebrew installed!"
    else
        log_verbose "Homebrew already installed."
    fi
}

function ensure_bitwarden_cli_installed() {
    which -s bw
    if [[ $? != 0 ]] ; then
        brew install bitwarden-cli
        log_verbose "Bitwarden CLI (bw) instlaled!"
    else
        log_verbose "Bitwarden CLI already installed"
    fi
}

function ensure_antidote_installed() {
    which -s antidote
    antidote_source="$(brew --prefix)/opt/antidote/share/antidote/antidote.zsh"

    if [[ ! -f $antidote_source ]] ; then
        brew install antidote
        log_verbose "Antidote installed (zsh plugin manager)"
    else
        log_verbose "Antidote already installed"
    fi
}


case "$(uname -s)" in
Darwin)
    ensure_homebrew_installed
    ensure_bitwarden_cli_installed
    ensure_antidote_installed
    ;;
*)
    log_verbose "Skipping Homebrew install; not MacOS"
    ;;
esac
