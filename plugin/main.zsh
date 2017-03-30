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


# fzf-ls directory
__fzf_ls__directory='.'
# location of fzf
__fzf_ls__fzf_cmd="$(which fzf)"
# fzf-ls boolean show hidden flag for internal usage
__fzf_ls__hidden_flag=''
# default ls pattern for 'all files visible' (except .)
__fzf_ls__hidden_pattern_hide='--ignore=.??*'
# default ls pattern for 'dot files hidden'
__fzf_ls__hidden_pattern_show='--ignore=\.$'
# fzf-ls ls command
__fzf_ls__ls_cmd='ls'
# fzf-ls awk filter definition
# 1. cut head "lrwxr-xr-x 1 root wheel 15 aliases -> postfix/aliases" -> "aliases -> postfix/aliases"
# 2. drop leading spaces
# 3. drop tail "aliases -> postfix/aliases" -> "aliases"
# 4. print
__fzf_ls__ls_filter='{
    $1="";$2="";$3="";$4="";$5="";
    gsub(/^[ ]+/, "", $0);
    gsub(/ -> .*$/, "", $0);
    print $0}'
# fzf-ls sudo command
__fzf_ls__sudo_cmd=''


function --fzf-ls::main::executable {
    # Core part: ls | fzf
    local fzf_location="$1"
    local fzf_options=(${(P)2})
    local ls_options=(${(P)3})
    --fzf-ls::main::executable::ls ls_options | --fzf-ls::main::executable::fzf "$fzf_location" fzf_options
}


function --fzf-ls::main::executable::ls {
    # Execute ls
    local ls_options=(${(P)1})
    # show hidden files if needed
    test -n "$__fzf_ls__hidden_flag" &&
        ls_options+=("$__fzf_ls__hidden_pattern_show") || ls_options+=("$__fzf_ls__hidden_pattern_hide")
    $__fzf_ls__sudo_cmd $__fzf_ls__ls_cmd "${ls_options[@]}" "$__fzf_ls__directory" | tail -n +3
}


function --fzf-ls::main::executable::fzf {
    # Execute FZF
    local fzf_location="$1"
    local fzf_options=(${(P)2})
    # add preview if needed
    test -n "$__fzf_ls__preview_flag" &&
        fzf_options+=("$__fzf_ls__preview_location" "--preview=$($__fzf_ls__preview)")
    --fzf-ls::main::executable::fzf::header | "$fzf_location" "${fzf_options[@]}" \
        --bind "$__fzf_ls__key_PREDOWN:preview-page-down,$__fzf_ls__key_PREUP:preview-page-up" \
        --expect=$(--fzf-ls::main::executable::fzf::keys) --toggle-sort=\`
}


function --fzf-ls::main::executable::fzf::keys {
    # Join $__fzf_ls__key_* arrays to comma separated list
    local keys=("${(j:,:)__fzf_ls__key_COMMAND}" "${(j:,:)__fzf_ls__key_HIDDEN}"
        "${(j:,:)__fzf_ls__key_PREVIEW}" "${(j:,:)__fzf_ls__key_EXIT}")
    echo "${(j:,:)keys}"
}


function --fzf-ls::main::executable::fzf::header {
    # Generate fzf header
    local sudo
    test -n "$__fzf_ls__sudo_cmd" && sudo="\u2605 SUDO " || sudo="" &&
    print -n \
        "$__fzf_ls__key_COMMAND_hint\u25B9\u26a1 " \
        "$__fzf_ls__key_HIDDEN_hint\u25B9hidden\u00B1 " \
        "$__fzf_ls__key_PREVIEW_hint\u25B9preview\u00B1 " \
        "$__fzf_ls__key_PREUP_hint\u25B9preview\u2193 " \
        "$__fzf_ls__key_PREDOWN_hint\u25B9preview\u2191 " \
        "$__fzf_ls__key_EXIT_hint\u25B9\u2620" \
        "\n${sudo}-> " && pwd && cat
}

function --fzf-ls::main::get-selected {
    # Get selected files
    local selected=("${(@f)1}")
    for (( i = 2; i <= $#selected; i++ )); do
        selected[i]=$(awk $__fzf_ls__ls_filter <<< $selected[i])
    done
    echo "${(F)selected}"
}

