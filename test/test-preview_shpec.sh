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
        assert equal "$(--fzf-ls::preview::alt)" "$VAR"
    end
end

