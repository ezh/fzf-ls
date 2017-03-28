eval 'OUT=$(awk ''{sub(".*" $5 FS,"");gsub(/^\s+/, "", $0);gsub(/ -> .*$/, "", $0);print $0}'' <<< ''lrwxr-xr-x 1 root wheel 15 aliases -> postfix/aliase'')';echo $OUT
describe "test that --fzf-ls::preview"
    it "should generate correct preview alt"
read -r -d '' VAR <<'EOF'
        function --fzf-ls::preview::tree {
            SEDMAGIC='s;[^/]*/;|____;g;s;____|; |;g'
             find "$2" -maxdepth $1 -type d -print 2>/dev/null | sed -e "$SEDMAGIC"
        }
        FILE=$(awk '{
        # remove the beginning
        #     "lrwxr-xr-x 1 root wheel 15 aliases -> postfix/aliases"
        #     " aliases -> postfix/aliases"
        sub(".*" $5 FS,"");
        # remove leading whitespaces
        gsub(/^[        ]+/, "", $0);
        # remove symlink tail
        gsub(/ -> .*$/, "", $0);
        print $0
    }' <<< {})
        if [[ -d "./$FILE" ]]; then
            --fzf-ls::preview::tree 2 "./$FILE"
        else
             highlight -q --force -O xterm256 "./$FILE"
        fi
EOF
        echo "$(--fzf-ls::preview::alt)" > a
        echo "$VAR" > b
        assert equal "$(--fzf-ls::preview::alt)" "$VAR"
    end
    it "should be able to show preview window"
        local __fzf_ls__preview_flag='YES'
        local __fzf_ls__preview="--fzf-ls::preview::mock"
        local __fzf_ls__fzf_cmd="echo"
        local fzf_options_in=("x" "y" "z")

        function --fzf-ls::preview::mock { echo "test" }
        result=$(echo | --fzf-ls::main::executable::fzf fzf_options_in)
        assert equal "$result" 'x y z --preview-window=right:30% --preview=test --bind alt-j:preview-page-down,alt-k:preview-page-up --expect=;,.,,,ctrl-c,esc --toggle-sort=`'
    end
    it "should be able to hide preview window"
        local __fzf_ls__preview_flag=''
        local __fzf_ls__fzf_cmd="echo"
        local fzf_options_in=("x" "y" "z")

        function --fzf-ls::preview::mock { echo "test" }
        result=$(echo | --fzf-ls::main::executable::fzf fzf_options_in)
        assert equal "$result" 'x y z --bind alt-j:preview-page-down,alt-k:preview-page-up --expect=;,.,,,ctrl-c,esc --toggle-sort=`'
    end
end

