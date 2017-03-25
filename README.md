# fzf-ls

ls and fuzzy search

### Mac OS demo

![FZF-LS Demo](fzf-ls-demo.gif)

### Key features

* as fast as ```ls```;
* main block is less than 100 lines;
* VI keybindings;
* easy to customize;
* multipanel with TMUX;
* just ```while (out=ls | fzf); do something; done```

### My experience

Midnight Commander -> Ranger -> fzf-ls

### Supported commands

* `:c` - copy
* `:m` - move
* `:o` - open
* `:e` - edit with $EDITOR
* `:p` - paste
* `:r` - return selected items to shell

### Keybindings

* `CTRL-SPACE` or `:` - command mode
* `CTRL-P` - toggle preview
* `CTRL-C` or `ESC` - exit
* `~` - toggle hidden files
* `ALT-T` - preview up
* `ALT-H` - preview down

### Installation

set EDITOR environment variable to your editor

set OPEN_WITH environment variable to your `open with` program

##### Mac OS

```bash
brew install coreutils tree highlight
```

Tip - use http://www.hamsoftengineering.com/codeSharing/AllApplications/AllApplications.html as OPEN_WITH

##### Linux

Tip - use `mimeopen` as OPEN_WITH

#### Using Antigen

```bash
antigen bundle ezh/fzf-ls
```

#### Using ZGen

```bash
zgen load ezh/fzf-ls fzf-ls master
```

#### Using ZPlug

  ```bash
  zplug "ezh/fzf-ls"
  ```
