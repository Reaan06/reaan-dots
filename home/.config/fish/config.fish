# ╭──────────────────────────────────────────────────────────────────────────╮
# │                                                                          │
# │   F I S H                                                                │
# │   interactive shell · path, prompt and tools                             │
# │                                                                          │
# │   github.com/Reaan06/reaan-dots                                          │
# │                                                                          │
# ╰──────────────────────────────────────────────────────────────────────────╯

set -g fish_greeting ""

# Keep local binaries first, followed by MATLAB installations when present.
set -gx PATH $HOME/.local/bin $PATH
for matlab_bin in /usr/local/MATLAB/*/bin
    if test -d "$matlab_bin"
        set -gx PATH $matlab_bin $PATH
    end
end

# Prefer Neovim, then Vim, and otherwise leave the editor unset.
for editor in nvim vim
    if command -q $editor
        set -gx EDITOR $editor
        set -gx VISUAL $editor
        break
    end
end

if status is-interactive
    if command -q starship
        starship init fish | source
    end

    # Fnm switches Node versions when the working directory changes.
    if command -q fnm
        fnm env --use-on-cd --shell fish | source
    end

    if command -q fzf
        fzf --fish | source
    end

    if command -q zoxide
        zoxide init fish | source
    end
end

# Yazi leaves the shell in the directory where it was closed.
function y
    set -l tmp (mktemp -t yazi-cwd.XXXXXX)
    command yazi $argv --cwd-file="$tmp"
    if test -r "$tmp"
        set -l cwd (command cat -- "$tmp")
        if test -n "$cwd"; and test "$cwd" != "$PWD"
            builtin cd -- "$cwd"
        end
    end
    command rm -f -- "$tmp"
end

# Fastfetch with the greeting scene selected in the settings. `fa koi` forces
# a scene, while `random` chooses one of the available scenes.
function fa
    set -l dir "$HOME/.local/state/quickshell"
    set -l choice ""
    if test (count $argv) -gt 0; and not string match -q -- '-*' $argv[1]
        if not test -f "$dir/greeting-$argv[1].gif"
            printf '%s\n' 'fa: no scene called '$argv[1]' — lava, critters, koi, invaders' >&2
            return 1
        end
        command fastfetch --logo "$dir/greeting-$argv[1].gif"
        return
    end
    if test -r "$dir/greeting"
        set choice (command cat "$dir/greeting")
    end
    set -l scenes $dir/greeting-*.gif
    if test "$choice" = random; and test (count $scenes) -gt 0; and test -f "$scenes[1]"
        command fastfetch --logo $scenes[(random 1 (count $scenes))] $argv
    else
        command fastfetch $argv
    end
end

alias cls='clear'
alias matrix='unimatrix -c cyan -s 96 -l m'
alias bonsai='cbonsai -l -k 6,3,14,11'
alias clock='tty-clock -c -s -n -C 6'

# Machine-specific settings stay outside the repository.
if test -r ~/.config/fish/config.local.fish
    source ~/.config/fish/config.local.fish
end
