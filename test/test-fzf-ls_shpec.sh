tmpfile=$(mktemp /tmp/shpec-output.XXXXXX)
trap 'rm $tmpfile' EXIT

describe "test that --fzf-ls::main::executable"
    it "should have --fzf-ls::main::executable"
        assert test "(( $+functions[--fzf-ls::main::executable] ))"
    end
    it "should have --fzf-ls::main::executable::ls"
        assert test "(( $+functions[--fzf-ls::main::executable::ls] ))"
    end
    it "should have --fzf-ls::main::executable::fzf"
        assert test "(( $+functions[--fzf-ls::main::executable::fzf] ))"
    end
    it "should pass default arguments"
        local ls_options_in=("a" "b" "c")
        local fzf_options_in=("x" "y" "z")

        echo -n >| $tmpfile
        functions[--fzf-ls::test:orig_a]=$functions[--fzf-ls::main::executable::ls]
        functions[--fzf-ls::test:orig_b]=$functions[--fzf-ls::main::executable::fzf]
        function --fzf-ls::preview::mock { echo "test" }
        function --fzf-ls::main::executable::ls { echo "${(P)1}" >> $tmpfile }
        function --fzf-ls::main::executable::fzf { echo "${(P)1}" >> $tmpfile }
        --fzf-ls::main::executable "fzf_options_in" "ls_options_in"
        functions[--fzf-ls::main::executable::ls]=$functions[--fzf-ls::test:orig_a]
        functions[--fzf-ls::main::executable::fzf]=$functions[--fzf-ls::test:orig_b]
        local result=("${(f)$(cat $tmpfile)}")

        assert equal "$result[2]" "a b c"
        assert equal "$result[1]" "x y z"
    end
    it "should be able to hide specific files"
        local __fzf_ls__hidden_flag=''
        local __fzf_ls__sudo_cmd="echo"
        local __fzf_ls__ls_cmd="\n\n"
        local ls_options_in=("a" "b" "c")

        result=$(--fzf-ls::main::executable::ls ls_options_in)
        assert equal "$result" " a b c --ignore=.??* ."
    end
    it "should be able to show all files"
        local __fzf_ls__hidden_flag='YES'
        local __fzf_ls__sudo_cmd="echo"
        local __fzf_ls__ls_cmd="\n\n"
        local ls_options_in=("a" "b" "c")

        result=$(--fzf-ls::main::executable::ls ls_options_in)
        assert equal "$result" " a b c --ignore=\.$ ."
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
    it "should generate correct default header"
        local __fzf_ls__sudo_cmd=''

        local result=("${(f)$(echo 123 | --fzf-ls::main::executable::fzf::header)}")
        local currentdir=$(pwd)

        assert test "echo '$result[1]' | grep -qG ';.*\..*hidden.*,.*preview.*A-K.*preview.*A-J.*preview.*C-C/Esc'"
        assert equal "$result[2]" "-> "$currentdir
        assert equal "$result[3]" "123"
    end
    it "should generate correct sudo header"
        local __fzf_ls__sudo_cmd='sudo'

        local result=("${(f)$(echo 123 | --fzf-ls::main::executable::fzf::header)}")
        local currentdir=$(pwd)

        assert test "echo '$result[1]' | grep -qG ';.*\..*hidden.*,.*preview.*A-K.*preview.*A-J.*preview.*C-C/Esc'"
        assert equal "$result[2]" "\u2605 SUDO -> "$currentdir
        assert equal "$result[3]" "123"
    end
    it "should generate correct list of fzf keys"
        assert equal $(--fzf-ls::main::executable::fzf::keys) ';,.,,,ctrl-c,esc'
    end
    it "should execute ls"
        local __fzf_ls__sudo_cmd=''
        local __fzf_ls__ls_cmd='ls'

        local ls_options_in=("-l" "-a")
        local result=("${(f)$(--fzf-ls::main::executable::ls ls_options_in)}")
        local expect_lines=$(ls -la | tail -n +3|wc -l)

        assert equal "$#result" "$expect_lines"
    end
end

