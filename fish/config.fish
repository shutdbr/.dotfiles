# fish: keys, abbreviations, path, colours, prompt, sway on tty1.
# EDITOR comes from NixOS (packages.nix).

set -g fish_greeting

# vi keys; ctrl-f still accepts the autosuggestion
set -g fish_key_bindings fish_vi_key_bindings
function fish_user_key_bindings
    for mode in insert default visual
        bind -M $mode ctrl-f forward-char
    end
end

# abbreviations expand on space, so rf shows the full rm -rf before enter
if status is-interactive
    abbr -a snv sudoedit
    abbr -a md mkdir
    abbr -a rf rm -rf
    abbr -a cum g++ -std=c++17
    abbr -a cumass g++ -Wall -Wextra -Wconversion -Wsign-conversion
    abbr -a texcompile latexmk -pdf -lualatex -interaction=batchmode -f
end

fish_add_path -g ~/.local/bin ~/.config/emacs/bin

# only the colours that differ from fish's defaults (no italics in the pager)
set -g fish_color_command blue
set -g fish_color_user brmagenta
set -g fish_color_host magenta
set -g fish_pager_color_description yellow

# prompt: [user@host](~/full/path)> with the last dir bold and > red after a
# failed command. the cursor shape shows the vi mode, so no [I]/[N]
set -g fish_prompt_pwd_dir_length 0
function fish_mode_prompt; end
function fish_prompt
    set -l last $status
    set -l cwd (prompt_pwd)
    set -l dir_color $fish_color_cwd
    fish_is_root_user; and set dir_color $fish_color_cwd_root

    echo -n '['; set_color $fish_color_user; echo -n $USER
    set_color normal; echo -n '@'; set_color $fish_color_host; echo -n $hostname
    set_color normal; echo -n ']('
    set_color $dir_color; echo -n (string replace -r '[^/]*$' '' -- $cwd)
    set_color $dir_color --bold; echo -n (string match -r '[^/]*$' -- $cwd)
    set_color normal; echo -n ')'
    test $last -ne 0; and set_color $fish_color_status
    echo -n '> '; set_color normal
end

# tty1 login starts sway, last so it inherits everything above. its log
# goes to the journal: journalctl -t sway -b -1 after a bad session
if status is-login; and test -z "$WAYLAND_DISPLAY"; and test (tty) = /dev/tty1
    set -gx XDG_SESSION_TYPE wayland
    exec systemd-cat -t sway sway
end
