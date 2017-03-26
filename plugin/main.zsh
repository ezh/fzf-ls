
__fzf-ls::preview=""
__fzf-ls::preview::flag=""
__fzf-ls::preview::location=""
__fzf-ls::hidden::flag=""
__fzf-ls::hidden::pattern_hide=""
__fzf-ls::hidden::pattern_show=""


function --fzf-ls::main::executable {
    local option
    local ls_options
    # add preview if needed
    test -n "$__fzf-ls::preview::flag" &&
        fzf_options+=("$__fzf-ls::preview::location" "--preview=$($__fzf-ls::preview)")
    # show hidden files if needed
    test -n "$__fzf-ls::hidden::flag" &&
        ls_options+=("$__fzf-ls::hidden::pattern_hide") || ls_options+=("$__fzf-ls::hidden::pattern_hide")
    # ls | fzf
    #| tail -n +3 | \ -fzf-ls-header | )
}

function --fzf-ls::main::executable::ls {
$_FZF_LS_VAR_SUDO ls "${ls_options[@]}" "$_FZF_LS_VAR_DIR"
}

function --fzf-ls::main::executable::fzf {
"$fzf_location" "${fzf_options[@]}" \
            --bind 'alt-h:preview-page-down,alt-t:preview-page-up' \
            --expect="${(j:,:)_fzf_ls_key_COMMAND},${(j:,:)_fzf_ls_key_HIDDEN},${(j:,:)_fzf_ls_key_EXIT},"'ctrl-p,ctrl-z' --toggle-sort=\`
}
