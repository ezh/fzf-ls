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
export _FZF_LS_FZF_OPTIONS=('-e' '+i' '-n6..' '--ansi' '--no-sort' '--reverse' '--header-lines=2' '-m')
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
    local out oarr key fzf_options fzf_location ls_options newlinefiles
    export _FZF_LS_VAR_STOP=""
    export _FZF_LS_VAR_SUDO="$1"
    export _FZF_LS_VAR_HIDDEN="$2"
    fzf_location="${3:-$_FZF_LS_FZF}"
    export _FZF_LS_VAR_DIR=$(readlink -e "${4:-.}")
    fzf_options=("${_FZF_LS_FZF_OPTIONS[@]}")
    ls_options=("${_FZF_LS_LS_OPTIONS[@]}")

    # ask password if needed
    test -n "$_FZF_LS_VAR_SUDO" && $_FZF_LS_VAR_SUDO true
    while out=$(
        # add preview if needed
        test -n "$_FZF_LS_VAR_PREVIEW" &&
            fzf_options+=("$_FZF_LS_PREVIEW_LOCATION") && fzf_options+=("--preview=$($_FZF_LS_PREVIEW)");
        # show hidden files if needed
        test -n "$_FZF_LS_VAR_HIDDEN" &&
            ls_options+=($_FZF_LS_PATTERN_HIDE) || ls_options+=($_FZF_LS_PATTERN_SHOW);
        # ls | fzf
        $_FZF_LS_VAR_SUDO ls "${ls_options[@]}" "$_FZF_LS_VAR_DIR" | tail -n +3 | \
            -fzf-ls-header | "$fzf_location" "${fzf_options[@]}" \
            --bind 'alt-h:preview-page-down,alt-t:preview-page-up' \
            --expect="${(j:,:)_fzf_ls_key_COMMAND},${(j:,:)_fzf_ls_key_HIDDEN},${(j:,:)_fzf_ls_key_EXIT},"'ctrl-p,ctrl-z' --toggle-sort=\`)
    do
        # http://unix.stackexchange.com/questions/29724/how-to-properly-collect-an-array-of-lines-in-zsh
        oarr=("${(@f)out}")
        key=$oarr[1]
        oarr=(${oarr:1})
        for (( i = 1; i <= $#oarr; i++ ))
        do
            oarr[i]=$(awk $_FZF_LS_VAR_FILTER <<< $oarr[i])
        done
        newlinefiles=${(F)oarr}
        if [[ -n "$key" && "${_fzf_ls_key_COMMAND[(r)$key]}" == "$key" ]]
        then
            # key COMMAND like ;
            key=$($_FZF_LS_COMMAND $newlinefiles)
            $_FZF_LS_ACTION "$newlinefiles" "$key"
            test -n "$_FZF_LS_VAR_STOP" && return
        elif [[ -n "$key" && "${_fzf_ls_key_EXIT[(r)$key]}" == "$key" ]]
        then
            # key EXIT like Esc
            ls_options=("${_FZF_LS_LS_OPTIONS[@]}")
            test -n "$_FZF_LS_VAR_HIDDEN" && ls_options+=($_FZF_LS_PATTERN_HIDE) ||
                ls_options+=($_FZF_LS_PATTERN_SHOW);
            $_FZF_LS_VAR_SUDO ls "${ls_options[@]}" "$_FZF_LS_VAR_DIR" | tail -n +3
            return
        elif [[ -n "$key" && "${_fzf_ls_key_HIDDEN[(r)$key]}" == "$key" ]]
        then
            # key toggle HIDDEN like ~
            test -n "$_FZF_LS_VAR_HIDDEN" && export _FZF_LS_VAR_HIDDEN="" || export _FZF_LS_VAR_HIDDEN=YES
        elif [[ "$key" == 'ctrl-p' ]]
        then
            test -n "$_FZF_LS_VAR_PREVIEW" && export _FZF_LS_VAR_PREVIEW="" || export _FZF_LS_VAR_PREVIEW=YES
        else
            if [[ $#oarr -eq 1 && -d "$_FZF_LS_VAR_DIR/$newlinefiles" ]]
            then
                cd "$_FZF_LS_VAR_DIR/$newlinefiles"
                export _FZF_LS_VAR_DIR=$(readlink -e .)
            else
                key=$($_FZF_LS_COMMAND $newlinefiles)
                $_FZF_LS_ACTION "$newlinefiles" "$key"
                test -n "$_FZF_LS_VAR_STOP" && return
            fi
        fi
  done
}

