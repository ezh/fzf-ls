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

function -fzf-ls-command {
    local buffer header selected_lines buffer_lines header_lines options keys result

    # skip selection if there is '..'
    [[ "$1" == ".." ]] && shift && selected_lines=0 || selected_lines=$(wc -l <<< "$1")
    test -r $_FZF_LS_BUFFER && buffer=$(<$_FZF_LS_BUFFER) || buffer=""
    header=$(tac <<< $'----------\n'"Buffer:"$'\n'"$buffer"$'\n----------\n'"Selected:"$'\n'"$1")
    buffer_lines=$(wc -l <<< "$buffer")
    header_lines=$(wc -l <<< "$header")
    echo $selected_lines >| /tmp/aaa

    options=""
    [[ $selected_lines -gt 0 ]] && options="$options"$'\n'"c copy selected items"
    [[ $selected_lines -gt 0 ]] && options="$options"$'\n'"d delete selected items"
    [[ $selected_lines -gt 0 ]] && options="$options"$'\n'"e edit selected items"
    [[ $selected_lines -gt 0 ]] && options="$options"$'\n'"m move selected items"
    [[ $selected_lines -eq 1 ]] && options="$options"$'\n'"o open selected items"
    [[ $buffer_lines -gt 1 ]]   && options="$options"$'\n'"p paste buffered items"
    [[ $selected_lines -gt 0 ]] && options="$options"$'\n'"r return selected items"
    options=$(tail -n +2 <<< "$options")
    keys=$(awk 'BEGIN{ORS=","} {print $1}' <<< "$options")

    result=$(fzf --tac --header-lines=$header_lines --expect "esc,$keys" <<< "$header"$'\n'"$options")
    awk -v RS='' '{print $1}' <<< "$result"
}

