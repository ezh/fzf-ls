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


# function with fzf-ls preview
__fzf_ls__preview='--fzf-ls::preview::alt'
# fzf-ls boolean preview flag for internal usage
__fzf_ls__preview_flag='YES'
# fzf-ls preview argument
__fzf_ls__preview_location='--preview-window=right:30%'


function --fzf-ls::preview {
    # preview with default tree command
    echo '
        FILE=$(awk '"'$__fzf_ls__ls_filter'"' <<< {}); \
        if [[ -d "'"$__fzf_ls__directory"'/$FILE" ]]
        then
            '"$__fzf_ls__sudo_cmd"' tree -d -L 2 -n "'"$__fzf_ls__directory"'/$FILE"
        else
            '"$__fzf_ls__sudo_cmd"' highlight -q --force -O xterm256 "'"$__fzf_ls__directory"'/$FILE"
        fi'
}


function --fzf-ls::preview::alt {
    # preview with custom --fzf-ls::preview::tree
    echo \
        'function --fzf-ls::preview::tree {
            SEDMAGIC='"'"'s;[^/]*/;|____;g;s;____|; |;g'"'"'
            '"$__fzf_ls__sudo_cmd"' find "$2" -maxdepth $1 -type d -print 2>/dev/null | sed -e "$SEDMAGIC"
        }
        FILE=$(awk '$__fzf_ls__ls_filter' <<< $AAA)
        #if [[ -d "'"$__fzf_ls__directory"'/$FILE" ]]; then
        #    --fzf-ls::preview::tree 2 "'"$__fzf_ls__directory"'/$FILE"
        #else
        #    '"$__fzf_ls__sudo_cmd"' highlight -q --force -O xterm256 "'"$__fzf_ls__directory"'/$FILE"
        #fi'
}

