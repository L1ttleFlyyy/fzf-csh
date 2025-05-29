fzf-csh
=======

Enhanced C shell ([csh](https://en.wikipedia.org/wiki/C_shell)) integration for [fzf](https://github.com/junegunn/fzf) command line fuzzy finder.

Works with [tcsh](https://www.tcsh.org) and supports modern fzf environment variables and key bindings.

## Acknowledgments

This project builds upon the pioneering work of [graahnul-grom/fzf-csh](https://github.com/graahnul-grom/fzf-csh), which solved what many considered impossible: programmatic command-line text insertion in tcsh.

### Why tcsh Integration is **So Challenging**

**A personal suggestion**: steer away from csh/tcsh if possible! Use fish/zsh/bash and enjoy your life.

Unlike bash and zsh, which have sophisticated readline libraries allowing programmatic manipulation of the command line, tcsh provides no direct mechanism to insert text into the active input buffer from key bindings. This is a fundamental architectural difference:

- **bash/zsh**: Use widgets like `LBUFFER+="text"` and `zle redisplay` to insert text
- **tcsh**: No equivalent mechanism exists - key bindings can only execute commands or send literal key sequences

The original author discovered the brilliant solution: using tcsh's own `bindkey -s` system to dynamically create text-injection bindings, then immediately triggering them. This represents **the only known way** to achieve programmatic command-line text insertion in tcsh.


## Key Features

This enhanced version maintains the original's core innovation while adding modern fzf integration:

### Supported Key Bindings
- **Ctrl+R**: Fuzzy search through command history with enhanced options
- **Ctrl+T**: Fuzzy search files/directories and insert selected into command line  
- **Alt+C**: Fuzzy search a directory and cd into it

### Environment Variable Support
- `FZF_CTRL_T_COMMAND`: Custom command for file/directory listing
- `FZF_CTRL_T_OPTS`: Additional options for file selection
- `FZF_CTRL_R_OPTS`: Additional options for history search  
- `FZF_ALT_C_COMMAND`: Custom command for directory listing
- `FZF_ALT_C_OPTS`: Additional options for directory selection
- automatically supported by fzf
    - `FZF_DEFAULT_COMMAND`: default command feeding fzf
    - `FZF_DEFAULT_OPTS`: default fzf options

## How to Use

1. **Clone the repository:**
For example, clone to `$HOME/.local/share/fzf-csh`
```bash
git clone https://github.com/L1ttleFlyyy/fzf-csh.git $HOME/.local/share/fzf-csh
```

2. **Install the implementation script:**
Copy `fzf-csh-impl.csh` somewhere in your `$PATH` and make it executable:
Make sure `$HOME/.local/bin/` or the directory you choose is in your `$PATH`
```bash
cp $HOME/.local/share/fzf-csh/fzf-csh-impl.csh $HOME/.local/bin/ && \
chmod +x $HOME/.local/bin/fzf-csh-impl.csh
```

3. **Customize fzf (Optional):**
Check out [fd](https://github.com/sharkdp/fd) and [ripgrep](https://github.com/BurntSushi/ripgrep) if you haven't, wwway fater than the built-in `find`
```sh
# Example configuration
setenv FZF_DEFAULT_COMMAND "fd --type f --follow --hidden"
setenv FZF_CTRL_T_COMMAND "${FZF_DEFAULT_COMMAND}"
setenv FZF_ALT_C_COMMAND "fd --type d --follow --hidden"
setenv FZF_DEFAULT_OPTS "--height 50% --layout reverse --border"
```

4. **Source in your csh configuration:**
Add to your `.cshrc` or `.tcshrc`:
```sh
if ( -r "${HOME}/.local/share/fzf-csh/fzf-csh.csh" ) then
    source ${HOME}/.local/share/fzf-csh/fzf-csh.csh
endif
```


### Usage Notes

- Press the key binding first, then start typing to filter results
- **Ctrl+R**: Shows command history with timestamps; press Ctrl+R again to toggle chronological/relevance sorting
- **Ctrl+T**: Lists files/directories; respects `FZF_CTRL_T_COMMAND` or uses fzf's built-in file finder
- **Alt+C**: Shows directories; selected directory appears as `cd /path` on command line

### Temporary Directory Configuration

`fzf-csh` requires a writable temporary directory (defaults to `$HOME`). To use a different location:

```sh
setenv FZF_CSH_TMP_DIR /tmp
```

## Technical Implementation

This project uses the original's core insight: leveraging `bindkey -s` for dynamic text injection through a two-stage process:

1. **Auxiliary Key**: Executes fzf and creates temporary binding
2. **Trigger Key**: Immediately activates the temporary binding to inject text

The `fzf-csh-impl.csh` script generates escaped `bindkey` commands dynamically, achieving what direct command-line manipulation cannot.

## Compatibility

- **Tested with**: RHEL9 (but should work for most Linux distributions!)
- **Shell requirement**: tcsh (not bsd-csh)

### Linux Installation Notes

Ubuntu provides two packages: `csh` and `tcsh`. Use `tcsh`:
```bash
sudo apt install tcsh
# If both are installed:
sudo update-alternatives --config csh  # Select tcsh
```

## TODOs

- [ ] **Thread-safety**: Make temporary file handling reentrant for concurrent usage
- [ ] **Unit testing**: Add tests for the complex `sed` escaping logic
- [ ] **Deduplication**: Implement history deduplication without shell-breaking `!` characters
- [ ] **TMUX integration**: Add `FZF_TMUX` and `FZF_TMUX_OPTS` support

## License

BSD-2-Clause License

Copyright (c) 2022-2023 dmn (original fzf-csh)  
Copyright (c) 2025 L1ttleFlyyy (enhancements)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.