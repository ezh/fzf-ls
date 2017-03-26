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


function --fzf-ls::utils::hidden::toggle {
    # toggle __fzf_ls__hidden_flag
    test -n "$__fzf_ls__hidden_flag" && __fzf_ls__hidden_flag='' || __fzf_ls__hidden_flag='YES'
}


function --fzf-ls::utils::preview::toggle {
    # toggle __fzf_ls__preview_flag
    test -n "$__fzf_ls__preview_flag" && __fzf_ls__preview_flag='' || __fzf_ls__preview_flag='YES'
}

