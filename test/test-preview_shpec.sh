describe "test that --fzf-ls::preview"
    it "should generate correct preview alt"
read -r -d '' VAR <<'EOF'
function --fzf-ls::preview::tree {
            SEDMAGIC='s;[^/]*/;|____;g;s;____|; |;g'
            eval ' find $2 -maxdepth $1 -type d -print 2>/dev/null | sed -e "$SEDMAGIC"'
        }
        FILE=$(awk '{
    $1="";$2="";$3="";$4="";$5="";
    gsub(/^[ ]+/, "", $0);
    gsub(/ -> .*$/, "", $0);
    print $0}' <<< {})
        if [[ -d '.'/"$FILE" ]]; then
            --fzf-ls::preview::tree 2 '.'/"$FILE"
        else
            eval ' highlight -q --force -O xterm256 '.'/"$FILE"'
        fi
EOF
        unset FILE
        local test_preview=$(--fzf-ls::preview::alt | awk '1 { gsub(/{}.*/,
            "''dlrwxr-xr-x 1 root wheel 15 aliases -> postfix/aliases'')", $0); print}; NR==9 {exit}')
        eval $test_preview
        assert equal "$FILE" "aliases"
        #echo "$(--fzf-ls::preview::alt)" >| a
        #echo "$VAR" >| b
        assert equal "$(--fzf-ls::preview::alt)" "$VAR"
    end
    it "should be able to show preview window"
        local __fzf_ls__preview_flag='YES'
        local __fzf_ls__preview="--fzf-ls::preview::mock"
        local fzf_options_in=("x" "y" "z")

        function --fzf-ls::preview::mock { echo "test" }
        result=$(echo | --fzf-ls::main::executable::fzf "echo" fzf_options_in)
        assert equal "$result" 'x y z --preview-window=right:30% --preview=test --bind alt-j:preview-page-down,alt-k:preview-page-up --expect=;,.,,,ctrl-c,esc --toggle-sort=`'
    end
    it "should be able to hide preview window"
        local __fzf_ls__preview_flag=''
        local fzf_options_in=("x" "y" "z")

        result=$(echo | --fzf-ls::main::executable::fzf "echo" fzf_options_in)
        assert equal "$result" 'x y z --bind alt-j:preview-page-down,alt-k:preview-page-up --expect=;,.,,,ctrl-c,esc --toggle-sort=`'
    end
end

