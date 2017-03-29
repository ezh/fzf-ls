#
# Copyright (C) 2017 Alexey Aksenov <ezh@ezh.msk.ru>.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.
#
# See the LICENSE for the specific language governing permissions and
# limitations under the License.


# key to start VI command mode
_fzf_ls_key_COMMAND=(";")
_fzf_ls_key_COMMAND_hint=(";")
# key toggle hidden files
_fzf_ls_key_HIDDEN=("~")
_fzf_ls_key_HIDDEN_hint=("~")
# key exit
_fzf_ls_key_EXIT=("esc" "ctrl-c")
_fzf_ls_key_EXIT_hint=("C-C/Esc")

# function with fzf-ls action (reaction)
export _FZF_LS_ACTION="-fzf-ls-action"
# skip default fzf-ls aliases (define before plugin loader)
export _FZF_LS_ALIAS_SKIP=""
# location with copy/move/... buffer
export _FZF_LS_BUFFER="/tmp/fzf_ls_buffer.txt"
# function with fzf-ls command (menu)
export _FZF_LS_COMMAND="-fzf-ls-command"
# location of fzf
export _FZF_LS_FZF="$(which fzf)"
# default array with fzf options
export _FZF_LS_FZF_OPTIONS=('-e' '+i' '-n6..' '--ansi' '--no-sort' '--reverse' '--header-lines=2' '-m' '--no-clear')
# default array with ls options
export _FZF_LS_LS_OPTIONS=('-alhN' '--group-directories-first' '--time-style=+' '--color')
# default ls pattern for 'all files visible' (except .)
export _FZF_LS_PATTERN_SHOW='--ignore=\.$'
# default ls pattern for 'dot files hidden'
export _FZF_LS_PATTERN_HIDE='--ignore=.??*'
# function with fzf-ls preview
export _FZF_LS_PREVIEW="-fzf-ls-preview-alt"
# fzf-ls preview argument array
export _FZF_LS_PREVIEW_LOCATION="--preview-window=right:30%"


# fzf-ls awk filter definition
export _FZF_LS_VAR_FILTER='{
        # remove the beginning
        #     "lrwxr-xr-x 1 root wheel 15 aliases -> postfix/aliases"
        #     " aliases -> postfix/aliases"
        sub(".*" $5 FS,"");
        # remove leading whitespaces
        gsub(/^[ \t]+/, "", $0);
        # remove symlink tail
        gsub(/ -> .*$/, "", $0);
        print $0
    }'
# fzf-ls boolean show hidden flag for internal usage
export _FZF_LS_VAR_HIDDEN=""
# fzf-ls boolean preview flag for internal usage
export _FZF_LS_VAR_PREVIEW="YES"
# fzf-ls boolean exit flag for internal usage (it is always false at the beginning)
export _FZF_LS_VAR_STOP=""
# fzf-ls string with sudo value (it is always set at the beginning from $1)
export _FZF_LS_VAR_SUDO=""
# fzf-ls working directory
export _FZF_LS_VAR_DIR="."


function -fzf-ls-preview {
    echo 'FILE=$(awk $_FZF_LS_VAR_FILTER <<< {}); \
        if [[ -d "$_FZF_LS_VAR_DIR/$FILE" ]]
        then
            $_FZF_LS_VAR_SUDO tree -d -L 2 -n "$_FZF_LS_VAR_DIR/$FILE"
        else
            $_FZF_LS_VAR_SUDO highlight -q --force -O xterm256 "$_FZF_LS_VAR_DIR/$FILE"
        fi'
}


function -fzf-ls-preview-alt() {
    echo '
        function fzf-ls-tree-preview {
            SEDMAGIC='"'"'s;[^/]*/;|____;g;s;____|; |;g'"'"'
            $_FZF_LS_VAR_SUDO find "$2" -maxdepth $1 -type d -print 2>/dev/null | sed -e "$SEDMAGIC"
        }
        FILE=$(awk $_FZF_LS_VAR_FILTER <<< {})
        if [[ -d "$_FZF_LS_VAR_DIR/$FILE" ]]
        then
            fzf-ls-tree-preview 2 "$_FZF_LS_VAR_DIR/$FILE"
        else
            $_FZF_LS_VAR_SUDO highlight -q --force -O xterm256 "$_FZF_LS_VAR_DIR/$FILE"
        fi'
}


function -fzf-ls-header {
    local sudo
    test -n "$_FZF_LS_VAR_SUDO" && sudo="SUDO " || sudo="" &&
        echo -n "$_fzf_ls_key_COMMAND_hint \u26a1, " &&
        echo -n "$_fzf_ls_key_HIDDEN_hint hidden\u00B1, " &&
        echo -n "C-P preview\u00B1, " &&
        echo -n "A-H preview\u2193, " &&
        echo -n "A-T preview\u2191, " &&
        echo "$_fzf_ls_key_EXIT_hint \u2620" &&
    echo -n "$sudo-> " &&
    pwd &&
    cat
}


#
# usage:
#     fzf-ls "sudo" "YES" "/full/path/to/fzf" "/dir"
# or
#     fzf-ls
function fzf-ls {
    local out selected key fzf_options fzf_location ls_options newlinefiles
    export _FZF_LS_VAR_STOP=""
    export _FZF_LS_VAR_SUDO="$1"
    export _FZF_LS_VAR_HIDDEN="$2"
    fzf_location="${3:-$_FZF_LS_FZF}"
    __fzf_ls__directory=$(readlink -e "${4:-.}")
    fzf_options=("${_FZF_LS_FZF_OPTIONS[@]}")
    ls_options=("${_FZF_LS_LS_OPTIONS[@]}")

    # ask password if needed
    test -n "$__fzf_ls__sudo_cmd" && "$__fzf_ls__sudo_cmd" true
    while out=$(--fzf-ls::main::executable fzf_options ls_options); do
        # http://unix.stackexchange.com/questions/29724/how-to-properly-collect-an-array-of-lines-in-zsh
        selected=("${(f)$(--fzf-ls::main::get-selected ""$out"")}")
        key=$selected[1]
        selected[1]=()
        selected=("${selected[@]}")
        if [[ -z "$key" ]]; then
            # key ENTER
            if [[ $#selected -eq 1 && -d "$__fzf_ls__directory/$selected" ]]
            then
                cd "$__fzf_ls__directory/$selected"
                __fzf_ls__directory=$(readlink -e .)
            else
                key=$($_FZF_LS_COMMAND "${(F)selected}")
                $_FZF_LS_ACTION ${(F)selected} $key
                test -n "$_FZF_LS_VAR_STOP" && return
            fi
        elif [[ "${__fzf_ls__key_COMMAND[(r)$key]}" == "$key" ]]; then
            # key COMMAND mode
            key=$($_FZF_LS_COMMAND "${(F)selected}")
            $_FZF_LS_ACTION ${(F)selected} $key
            test -n "$_FZF_LS_VAR_STOP" && return
        elif [[ "${__fzf_ls__key_EXIT[(r)$key]}" == "$key" ]]; then
            # key EXIT
            tput rmcup
            --fzf-ls::main::executable::ls ls_options
            return
        elif [[ "${__fzf_ls__key_HIDDEN[(r)$key]}" == "$key" ]]; then
            # key toggle HIDDEN
            --fzf-ls::utils::hidden::toggle
        elif [[ "${__fzf_ls__key_PREVIEW[(r)$key]}" == "$key" ]]; then
            # key toggle PREVIEW
            --fzf-ls::utils::preview::toggle
        else
            echo "Warning: unknown key $key" >&2
            sleep 1
        fi
  done
}

