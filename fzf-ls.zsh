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


# function with fzf-ls action (reaction)
export _FZF_LS_ACTION="-fzf-ls-action"
# skip default fzf-ls aliases (define before plugin loader)
export _FZF_LS_ALIAS_SKIP=""
# location with copy/move/... buffer
export _FZF_LS_BUFFER="/tmp/fzf_ls_buffer.txt"
# function with fzf-ls command (menu)
export _FZF_LS_COMMAND="-fzf-ls-command"
# fzf-ls boolean exit flag for internal usage (it is always false at the beginning)
export _FZF_LS_VAR_STOP=""


#
# usage:
#     fzf-ls "sudo" "YES" "/full/path/to/fzf" "/dir"
# or
#     fzf-ls
# arguments:
#   - sudo command or empty value
#   - show hidden files boolean flag or empty value
#   - path to fzf executable or empty value
#   - path to target directory or empty value
#
function fzf-ls {
    local out selected key fzf_options fzf_location ls_options newlinefiles
    export _FZF_LS_VAR_STOP=""
    __fzf_ls__directory=$(readlink -e "${4:-.}")
    __fzf_ls__hidden_flag="$2"
    __fzf_ls__sudo_cmd="$1"
    fzf_location="${3:-$__fzf_ls__fzf_cmd}"
    fzf_options=("${__fzf_ls__fzf_options[@]}")
    ls_options=("${__fzf_ls__ls_options[@]}")

    # ask password if needed
    test -n "$__fzf_ls__sudo_cmd" && "$__fzf_ls__sudo_cmd" true
    while out=$(--fzf-ls::main::executable "$fzf_location" fzf_options ls_options); do
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

