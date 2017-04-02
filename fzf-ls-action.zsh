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

function -fzf-ls-action {
    local files key afiles lfiles temp
    files="$1"
    key="$2"
    test -z "$key" && return

    # array of files
    afiles=("${(@f)files}")
    for (( i = 1; i <= $#afiles; i++ ))
    do
        afiles[i]=$(readlink -e "$__fzf_ls__directory/$afiles[i]")
    done
    # list of files 'a' 'b' 'c'
    lfiles="'"${(j:' ':)afiles}"'"

    case $key in
    esc)
        ;;
    c)
        echo ":copy:" >| $_FZF_LS_BUFFER
        echo ${(F)afiles} >> $_FZF_LS_BUFFER
        ;;
    d)
        echo ">>> rm -rfI $lfiles"
        eval "rm -rfI $lfiles"
        ;;
    e)
        eval "$EDITOR $lfiles"
        ;;
    m)
        echo ":move:" >| $_FZF_LS_BUFFER
        echo ${(F)afiles} >> $_FZF_LS_BUFFER
        ;;
    o)
        eval "$OPEN_WITH $lfiles"
        ;;
    p)
        buffer=$(<$_FZF_LS_BUFFER)
        afiles=("${(@f)buffer}")
        cmd=$afiles[1]
        afiles=("${afiles[@]:1}")
        lfiles="'"${(j:' ':)afiles}"'"
        if [[ "$cmd" == ":copy:" ]]
        then
            echo ">>> cp -rfi $lfiles ."
            eval "cp -rfi $lfiles ."
        elif [[ "$cmd" == ":move:" ]]
        then
            echo ">>> mv -fi $lfiles ."
            eval "mv -fi $lfiles . && rm $_FZF_LS_BUFFER"
        fi
        ;;
    r)
        cmd=""
        for (( i = 1; i <= $#afiles; i++ ))
        do
            cmd=$cmd' "'$afiles[i]'"'
        done
        print -z "$cmd"
        echo ${(F)afiles}
        tput rmcup
        export _FZF_LS_VAR_STOP=TRUE
        ;;
    esac
}

