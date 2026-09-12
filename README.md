<p align="center">
  <img src=".github/assets/banner.jpg" alt="impasto — the island, become the mark, over a painting of Mount Fuji" width="100%">
</p>

<p align="center">
  <b>A Hyprland shell whose colours come from a painting.</b><br>
  One black island that changes shape, a desk of widgets under the windows,<br>
  and every program around it repainted by whatever wallpaper is up.
</p>

<p align="center">
  <a href="https://github.com/andreumassanet/impasto/actions/workflows/check.yml"><img src="https://github.com/andreumassanet/impasto/actions/workflows/check.yml/badge.svg" alt="check"></a>
  <img src="https://img.shields.io/badge/Arch_Linux-1793d1?style=flat-square&logo=archlinux&logoColor=white" alt="Arch Linux">
  <img src="https://img.shields.io/badge/Hyprland-Lua_config-58e1ff?style=flat-square&logo=hyprland&logoColor=white" alt="Hyprland">
  <img src="https://img.shields.io/badge/Quickshell-0.3-000000?style=flat-square" alt="Quickshell">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-GPL--3.0-2e509e?style=flat-square" alt="GPL-3.0"></a>
</p>

<p align="center">
  <a href="#the-island">The island</a> ·
  <a href="#the-bar">The bar</a> ·
  <a href="#the-desktop">The desktop</a> ·
  <a href="#one-palette-everywhere">The palette</a> ·
  <a href="#the-terminal">The terminal</a> ·
  <a href="#installation">Installation</a> ·
  <a href="#keys">Keys</a>
</p>

<p align="center">
  <img src=".github/assets/hero.jpg" alt="The desk: the island with a track playing, widgets down the right, a note deck on the left edge, a terminal with the lava lamp greeting, and the dock" width="100%">
</p>

The name is the technique the wallpapers are painted in: paint laid on thick
enough to keep the mark of the brush. It is a shell first and a dotfiles
repository second — `home/.config/quickshell` is most of the code, and the rest
of `home/` is the desk it sits on: the terminal, the prompt, two editors, two
file managers, a browser, a chat client, the login screen. **Change the
wallpaper and all of it follows**, down to the folders in the file manager.

Everything in these pictures is the real shell, photographed.

## The island

<p align="center">
  <img src=".github/assets/island.gif" alt="The island at rest, opening a glance under the pointer, becoming the control centre, then the launcher doing a sum and listing the shell's places, then a notification arriving" width="100%">
</p>

**The island is one object that changes shape.** A black capsule in the middle
of the bar rests on the time, and everything else happens by it turning into
something: the glance when the pointer rests on it, the control centre when it
is clicked, the launcher, the overview, a notification, a game. Each is the
size of what is in it, so a list of networks opens as a list and not as a
control centre with a list inside it — and no panel has a title or a close
button: what opened it closes it.

What is running sits either side of the time — a track, a countdown, a take
being recorded — and every module on the bar opens into the island rather than
into a popup of its own.

<p align="center">
  <img src=".github/assets/island-details.jpg" alt="Module details in the island: the player, the battery, Claude Code's usage, the processor and memory, the recorder, the Wi-Fi list, the weather, the pet, the volume, the month with task dots, the tasks, a countdown and the GitHub wall" width="100%">
</p>

## The bar

<p align="center">
  <img src=".github/assets/bar-styles.jpg" alt="The same bar in its three styles: grouped round the island, spread to the two edges, and everything inside one capsule" width="100%">
</p>

**Three styles, one layout.** The two sides are arranged by dragging pieces out
of a catalogue onto a picture of the bar, and then drawn grouped round the
island, spread to the edges, or all inside one capsule. Nothing on it moves by
itself: an item is where you put it.

**Every module reads the same way, and it is two settings for the whole bar**:
its symbol or its ring — the charge, the volume, the countdown as a gauge —
with its figure beside it always, never, or only under the pointer. A piece
can be given a look of its own; the rest follow.

<p align="center">
  <img src=".github/assets/bar-modules.jpg" alt="A bar carrying every module, shown four ways: the symbol, the symbol and its figure, the ring, the ring and its figure" width="100%">
</p>

## The control centre

<p align="center">
  <img src=".github/assets/control-centre.jpg" alt="The control centre rearranged — the signature block, the player, a clock, the month, toggles, the pet, a note, the tasks, the weather — and the same panel being arranged, with the tray of blocks under it and the clock's inspector open" width="100%">
</p>

**A grid you arrange, six columns by eight rows.** The toggles, the sliders,
the player, the weather, the month, the notifications, a clock, the pet, a
note, the tasks and the repository's signature are blocks, dragged to a cell
and given one of the sizes they have a face for. The toggles are one block with
pages; which tiles it carries, and in what order, is that block's own.
Arranging happens on the panel itself, with a tray of live miniatures hanging
under the island — the same way the widgets on the wallpaper are arranged.

## The launcher

<p align="center">
  <img src=".github/assets/launcher.jpg" alt="The launcher in six modes: the applications ranked, a search, a sum, the shell's own places under the > sigil, a countdown, and the clipboard history with an image drawn in its row" width="100%">
</p>

**The first character says what the field is for.** Plain text searches
applications, `=` calculates and Enter copies the answer, `@` finds an open
window, `!` starts a countdown, `'` hands back something copied earlier, and
`>` is the shell itself — every panel, the settings, the jobs the control
centre does in one press, and the other sigils by name. Nothing is guessed, so
`100` is a search until you ask for a sum.

**It offers what you actually use.** Launches are counted with a month's
half-life, and what is kept on the dock leads until something has been used
more — the dock is the favourites list, so there is no second one. The
clipboard history is one of these modes and nothing else: `SUPER + V`,
type to filter, Enter to copy back, `SHIFT + Delete` to forget. A copied image
is drawn in its row, and what a password manager copies is never kept.

## The desktop

<p align="center">
  <img src=".github/assets/desktop-themes.jpg" alt="The same wall of widgets split down the middle: Modern on the left, figures with captions; Analogue on the right, a thermometer, a wall calendar, a battery cell, a knob, gauges, a parcel, a joystick" width="100%">
</p>

**Any module can live on the wallpaper**, on a grid whose street is the
compositor's own window gap, in four shapes — a square, a card, a large square
and a band — each saying a little more than the last. Nothing overlaps: a widget
dropped on an occupied square goes to the nearest free one.

**Two themes on the same modules.** *Modern* is a figure with a caption, every
face on one grid so six of them read as a set. *Analogue* draws each module as
an object you read by where something is — a clock with hands, the sky beside a
thermometer, a leaf off a wall calendar, a battery that fills, a fuel gauge, a
record that turns while it plays, an hourglass, a parcel with the count on its
label. The theme is one setting for the desktop and a choice per widget, so a
dial can sit beside a modern battery.

<p align="center">
  <img src=".github/assets/desktop-styles.jpg" alt="The same five widgets in four styles: a capsule, the accent as a ground, an outline, and bare contents on the painting" width="100%">
</p>

Arranging is done on the picture: the right button on the wallpaper opens a
menu, a tray of every module slides up, a corner is pulled for another shape,
and a click opens a card with that widget's own look. The widgets draw in the
desk's palette like every capsule on the bar — except the GitHub wall, which
stays grey-to-green because a contribution graph is green the way a low battery
is red.

## Notes and tasks

<p align="center">
  <img src=".github/assets/notes-and-tasks.jpg" alt="The deck of pastel notes in handwriting, one note open with the island become yellow paper, the kanban board with three lanes, and a task open with its day and lane" width="100%">
</p>

**A note is paper**: a pastel square, a title, and the body in handwriting,
`[ ]` and `[x]` drawn as boxes. `SUPER + S` opens the deck with New under the
ring, and an open note turns the island into the sheet. On the wallpaper a note
sits on a square, or stacks with others along an edge as tabs that peek out
under the pointer.

**A board for what has to be done.** `SUPER + K` is to do, doing, done, with
cards dragged between the lanes. A task is a line, whatever else there is to
say, a day and a lane — and the days show up as dots under the month wherever a
month is drawn, a finished task staying on its day, struck through. Notes and
tasks never read each other: a note has no state and no date.

## The arcade

<p align="center">
  <img src=".github/assets/arcade.jpg" alt="The arcade shelf, and eleven games in the island: Tetris, Whack-a-Mole, Solitaire, Space Blaster, Target Smash, Snake Sprint, 2048 Mini, Lights Out, Flood Colors, Hextris and Bot Bash" width="100%">
</p>

**Eleven small games, played in the island.** `SUPER + G` opens a shelf; slide
to a card and the island becomes that game's board, at its own size, with the
keyboard in it. One best per game is kept, and every game is drawn in the
palette's own tints, so the arcade follows the wallpaper like everything else.

## The pets

<p align="center">
  <img src=".github/assets/pets.jpg" alt="Five species — Dot, Sprout, Ember, Sol and Drift — as an egg, hatched, with their ears at level five and a star at level fifteen, and the five moods: beaming, content, peckish, lonely and asleep" width="100%">
</p>

**A family of five small creatures lives on the bar**, and nothing in it is ever
lost. One is out at a time and earns levels from being fed, played with and
kept where it can see you; the rest sleep on the shelf and wake exactly as they
were left. Each starts as an egg speckled in the coat it will hatch into, earns
its species' ears at level five and a star at fifteen, and the family grows by
one egg each time the levels across it cross a milestone — rolled from the
species still missing, so the last egg is always the one you do not have. There
is no death, and no punishment for a week away.

## One palette, everywhere

<p align="center">
  <img src=".github/assets/repaint.gif" alt="The wallpaper changing three times, and the bar, the widgets, the terminal and the system monitor repainting with each one" width="100%">
</p>

**The palette comes out of the painting.** Pick a wallpaper and its colours are
extracted and pushed everywhere at once: the island and its panels, the widgets,
kitty and the prompt, btop, cava, yazi and its preview, neovim while you are
typing in it, VSCodium, the GTK and Qt windows, KDE's applications, Thunar and
the colour of its folders, Vesktop, Zen's frame, Spotify through spicetify, the
pointer, and the greeting's pixel art. Or pick one of nine palettes instead.

<p align="center">
  <img src=".github/assets/appearance.jpg" alt="The appearance panel: a strip of the paintings on SUPER + T, and a strip of the palettes under it on SUPER + SHIFT + T" width="100%">
</p>

The desk comes with forty paintings, in the style it is named after:

<p align="center">
  <img src=".github/assets/wallpapers.jpg" alt="All forty wallpapers: cars, cats, coasts, a tiger in the snow, a pagoda under Mount Fuji, a Roman legion, a private jet" width="100%">
</p>

## The terminal

<p align="center">
  <img src=".github/assets/terminal.jpg" alt="kitty tiled three ways in the palette of a painting of a castle under a full moon: yazi previewing a wallpaper, a bonsai growing, and neovim editing the island's QML" width="100%">
</p>

The terminal wears the island's black with the wallpaper's colour in it, over a
blurred desk. The prompt is laid out like the bar — identity and place on the
left, status on the right, and nothing at all when there is nothing to say —
and `fa` greets you with fastfetch beside one of four animated scenes, drawn in
pixel art out of the current palette:

<table align="center">
  <tr>
    <td align="center" width="25%"><img src=".github/assets/greeting-lava.gif" alt="A lava lamp" width="100%"><br><sub><code>fa lava</code></sub></td>
    <td align="center" width="25%"><img src=".github/assets/greeting-critters.gif" alt="Critters under the stars" width="100%"><br><sub><code>fa critters</code></sub></td>
    <td align="center" width="25%"><img src=".github/assets/greeting-koi.gif" alt="Koi in a stone pond" width="100%"><br><sub><code>fa koi</code></sub></td>
    <td align="center" width="25%"><img src=".github/assets/greeting-invaders.gif" alt="Space Invaders" width="100%"><br><sub><code>fa invaders</code></sub></td>
  </tr>
</table>

`matrix`, `bonsai`, `clock` and `asciiquarium` draw in the terminal's own
sixteen colours, so the push that repaints kitty repaints them mid-frame.

## Every other window

<p align="center">
  <img src=".github/assets/windows.jpg" alt="VSCodium and Thunar side by side, both wearing the green of a painting of cliffs, Thunar's folders tinted to match" width="100%">
</p>

Windows from other toolkits follow the palette too, each through whatever its
toolkit exposes: a generated `gtk.css` for GTK, a platform theme
and `kdeglobals` for Qt and KDE, a whole colour-theme extension for VSCodium, a
user stylesheet for Vesktop and for Zen, an icon theme that re-points Papirus's
folders at the nearest of its colours. Right-click a picture in Thunar and **Set
as Wallpaper** repaints the whole desk from there.

## Lock and login

<p align="center">
  <img src=".github/assets/lock-and-login.jpg" alt="The lock screen over the blurred desk, and the SDDM login screen over a painting of brush strokes — the same clock, the same face, the same field" width="100%">
</p>

**The shell locks the session itself**, through the compositor's own
ext-session-lock, so the desk stays on screen behind the lock, blurred. It is
its own idle daemon too — lock, screen off and sleep, each able to be told
never, and a film playing holds all three off. **The login screen is the lock
screen with the desk taken away**: an SDDM theme with the same clock, the same
face and the same field, so locking the machine and booting it look like one
design.

## Settings

<p align="center">
  <img src=".github/assets/settings.jpg" alt="Four pages of the settings window: the bar arranged on a picture of it, the desktop's look, the appearance with the wallpaper transitions and the greeting scenes, and every key binding" width="100%">
</p>

**Settings is the one panel that is not the island** — an ordinary window, so
Hyprland moves it, resizes it and closes it like anything else, while the island
visibly reacts to what is being changed. Where an option is a shape, the
control is the shape: a real chip, a real bar, the real clock in the format on
offer. A setting made meaningless by another one stays where it is, dimmed,
with a line saying which switch did it. The window also speaks Spanish.

**Profiles** keep whole desks under names — the bar, the widgets, the dock,
the look, the keys, and the wallpaper with its palette — and switch between
them from System. The one in use saves itself as you go, like VS Code's. A
profile exports to a plain JSON file and imports on another machine; your
screens, your name and the language stay with the machine. Three come with the
desk, one for each style of bar — *Moon castle*, one capsule over analogue
objects; *Fuji*, grouped round a notch; *Night bay*, spread under a wall of
widgets. A fresh install starts on Moon castle, and the other two are on the
list.

## And the rest

<p align="center">
  <img src=".github/assets/and-the-rest.jpg" alt="The workspace overview with live windows, the capture surface with a region drawn on a photograph of the screen, the dock with a window menu open, the system statistics, and the pet's panel" width="100%">
</p>

- **The overview** is every workspace as a live scale model of the screen;
  drag a window from one to another.
- **One key to capture.** `SUPER + SHIFT + S` photographs the screen and lets
  you draw on the photograph — region, window or screen, as a picture or a
  recording, saved, copied, annotated or read as text. There is nothing to
  freeze, because what you are drawing on is already a picture.
- **The dock** is a shelf on any edge but the top: the applications you keep,
  then whatever else is open. A kept application that is running lights up in
  its own place.
- **Every key is on one sheet** — `SUPER + H` turns the island into all of
  them, read from the compositor as it opens.
- **The packages are a panel** — `SUPER + I` lists what is waiting to update,
  what is installed and what a name finds, in the repositories and the AUR at
  once; installing and updating open a terminal, because pacman asks questions.
- **The screens are remembered by which screens they are.** Arrange them on a
  canvas and the arrangement is kept for that set of monitors; close the lid
  with another one connected and the laptop's panel goes dark with its
  workspaces moved.
- **A night light, a colour picker, a recorder, the weather, updates, Claude
  Code's usage** — each a module, a widget, or a tile, and each missing program
  takes its own control away rather than failing under the finger.

## Components

| | | |
|---|---|---|
| 🪟 | Compositor | [Hyprland](https://hypr.land) |
| 🖱️ | Shake to find | [hypr-dynamic-cursors](https://github.com/VirtCode/hypr-dynamic-cursors) |
| 🫧 | Glass on the windows | [hyprglass](https://github.com/hyprnux/hyprglass) |
| 🐚 | Desktop shell | [Quickshell](https://quickshell.org) |
| 🖼️ | Wallpaper daemon | [awww](https://github.com/LGFae/swww) |
| 🖥️ | Terminal | [kitty](https://sw.kovidgoyal.net/kitty/) |
| ⌨️ | Interactive shell | [zsh](https://www.zsh.org) · [oh-my-zsh](https://ohmyz.sh) |
| ❯ | Prompt | [starship](https://starship.rs) |
| 🎨 | Greeting | [fastfetch](https://github.com/fastfetch-cli/fastfetch) |
| 📊 | System monitor | [btop](https://github.com/aristocratos/btop) |
| 🎵 | Audio visualiser | [cava](https://github.com/karlstav/cava) |
| 📁 | File manager | [yazi](https://yazi-rs.github.io) |
| 🗂️ | File manager in a window | [Thunar](https://docs.xfce.org/xfce/thunar/start) |
| ✏️ | Editor | [neovim](https://neovim.io) |
| 📝 | Editor in a window | [VSCodium](https://vscodium.com) |
| 🖼️ | Image viewer | [imv](https://sr.ht/~exec64/imv/) |
| 🪄 | Annotator | [satty](https://github.com/gabm/Satty) |
| 💬 | Chat | [Vesktop](https://github.com/Vencord/Vesktop) |
| 🎧 | Player | [Spotify](https://www.spotify.com) · [spicetify](https://spicetify.app) |
| 🌐 | Browser | [Zen](https://zen-browser.app) |
| 🔑 | Login screen | [SDDM](https://github.com/sddm/sddm) |

## Installation

Arch Linux, and a Hyprland recent enough to read a Lua configuration. Run it
from a terminal inside the Hyprland session — the plugins are built against the
compositor that is running:

```bash
git clone https://github.com/andreumassanet/impasto.git ~/impasto
cd ~/impasto
./setup install
```

In order, it installs the packages, the user folders,
oh-my-zsh and its two plugins, everything in `home/` copied into your home,
everything in `system/` copied into `/`, and the two Hyprland plugins. It asks
for your password through sudo — for pacman, and for the copy into `/`.

| Flag | |
|---|---|
| `--skip-packages` | install nothing; copy and build only |
| `--skip-system` | leave `/` alone — no login screen, and no password for it |
| `--skip-plugins` | no shake to find, no glass |
| `--aur-helper yay\|paru` | which helper builds the AUR half — built from the AUR if you have neither |
| `--noconfirm` | take the default at every question |
| `-n`, `--dry-run` | say what would happen, and do none of it |

```bash
./setup update       # git pull, then install again — the same flags
./setup uninstall    # remove everything setup installed that you have not edited since
./setup help         # every verb and flag
```

**Nothing is linked: `setup` copies**, and remembers what it wrote. A file of
yours already in the way the first time is moved to
`~/.local/state/impasto/backups/` before anything is written. A file you edit
afterwards is yours: an update leaves it where it is and puts the new version
beside it as `<name>.new`. And a file `setup` did not write — the themes the
shell generates, anything else of yours — is never touched, by an update or by
`uninstall`.

**Editing the repository?** A change is not on the desk until it is copied:
`./setup sync` does it once, and `./setup sync --watch` keeps doing it on every
save (it wants `inotify-tools`).

<details>
<summary><b>What every package is for</b></summary>
<br>

The packages are two lists, `packages/pacman.txt` and `packages/aur.txt`,
grouped by what each one is for, and `./setup packages` installs whatever of
them is missing — the first with pacman, the second with yay or paru. The first
two sections of the pacman list are the desk itself; every section after them
is one feature, and a line commented out is a package skipped.

The desktop needs `hyprland`, `quickshell`, `awww` and `imagemagick`, and the
terminal `kitty`, `zsh`, `oh-my-zsh`, `starship` and a Nerd Font — the prompt's
arrow is a Nerd Font glyph. `brightnessctl`, `wireplumber`, `nmcli`,
`bluez-utils` and `power-profiles-daemon` back the quick controls; each is
optional and its control disables itself when missing. `hyprsunset` is the
night light, run only while the filter is on.

`xdg-desktop-portal-hyprland` and `xdg-desktop-portal-gtk` are what an
application asks when it wants something it cannot take for itself — screen
sharing in a browser or in Vesktop, and every Open dialog. Neither needs
configuring: the Hyprland backend's default routing is already right, and the
file dialog is GTK3, so it follows the palette.

Captures need `grim` and `wl-clipboard`; `satty` annotates and `tesseract` reads
a region as text, and each one missing takes its own choice off the capture bar.
Recording wants `wf-recorder` or `wl-screenrec` (the second encodes on the GPU,
from the AUR); with neither, the recorder is not on the bar at all. Captures and
recordings land in a folder of their own inside your pictures and videos
folders, whatever your language calls those, and an `XDG_SCREENSHOTS_DIR` or
`XDG_SCREENCASTS_DIR` line in `~/.config/user-dirs.dirs` sends them elsewhere.
`hyprpicker` is the colour under the pointer. The clipboard history needs
nothing more: `wl-paste --watch` is what reads a selection without holding the
keyboard, so there is no `cliphist`.

`fzf`, `zoxide`, `fnm` and `yazi` are reached for by `.zshrc` only if they are
installed; `fastfetch` is the greeting; `btop`, `cava` and `yazi` get their
themes on the first palette push. `unimatrix`, `cbonsai`, `tty-clock` and
`asciiquarium` back the `matrix`, `bonsai` and `clock` aliases and need no
theme, because they draw in the terminal's own colours. `less` is not optional:
it is kitty's scrollback pager.

Two things are Hyprland plugins rather than options, built by `./setup plugins`
with `hyprpm` (which wants `cmake`, `meson`, `cpio`, `git` and `gcc`, a running
Hyprland, and a password — its store is root's). **Shake to find** grows the
pointer when it is shaken; **glass** frosts and bends the blur behind a window,
off by default and switched on in Settings → Appearance. A Hyprland update takes
both away until `hyprpm update` or `./setup plugins` has run. The pointer is a
single vector shape, so it stays sharp when it grows and can take the palette's
colour: `./setup cursors` fetches Bibata's SVGs and `hyprcursor-util` compiles
them.

</details>

<details>
<summary><b>Making the rest of the machine agree</b></summary>
<br>

What opens a file, whether a GTK application comes up dark and which icon theme
it draws are the machine's settings rather than files this repository can
carry, so they are commands, run once:

```bash
xdg-mime default imv.desktop image/jpeg image/png image/gif image/webp image/svg+xml
xdg-mime default nvim.desktop text/plain application/json
xdg-mime default thunar.desktop inode/directory
xdg-mime default zen.desktop application/pdf text/html     # or whichever browser you use
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
gsettings set org.gnome.desktop.interface icon-theme impasto
```

`impasto` is the icon theme the palette push writes: Papirus, with the folders
in the wallpaper's colour. `./setup install` seeds it, so the name resolves
before the shell has ever run.

</details>

<details>
<summary><b>The windows that need one command</b></summary>
<br>

**VSCodium** (`vscodium-bin`) gets its colour theme from the push as a whole
extension in `~/.vscode-oss/extensions/`; nothing has to be installed for that.
Its extensions (all from Open VSX), its font and its chrome are one command, run
with the editor closed — it merges into `settings.json` and keeps whatever else
is in there:

```bash
./setup vscodium
```

**Thunar** takes the palette like every GTK3 window and wants `tumbler`,
`ffmpegthumbnailer`, `gvfs` and `papirus-icon-theme`. Its settings live in
xfconf, a daemon rather than a file, so they are one command too — its toolbar,
its sorting, and five entries in the right-click menu: a terminal here, yazi
here, the editor, the path on the clipboard, and Set as Wallpaper:

```bash
./setup thunar
```

**Spotify** is themed by spicetify, which patches the client rather than reading
a file, so the push writes the colours and stops. This lands them, and is also
the repair after a Spotify update:

```bash
./setup spotify
```

**Zen** (`zen-browser-bin`) needs nothing: the push writes a `userChrome.css`
and the one preference that makes it read it into the profile, and the colours
arrive with the next window. Zen's own workspace theme picker stops having an
effect while this is on. **Vesktop** reads the push's stylesheet once it is
ticked under Vencord's themes. **Qt and KDE windows** need `qt6ct`, which the
push configures; without it they come up in Breeze's light grey.

</details>

<details>
<summary><b>The login screen</b></summary>
<br>

The SDDM theme is `system/`, copied into `/usr/share` by `install` — copied,
because sddm reads its theme as its own user and cannot see into a 0700 home.
`./setup system` does that part on its own. Try it before switching to it:

```bash
sddm-greeter-qt6 --test-mode --theme system/usr/share/sddm/themes/impasto
```

Then set `Current=impasto` under `[Theme]` in whichever file in
`/etc/sddm.conf.d/` sets it. The lock screen and the login screen read one
picture from one place, `/var/lib/impasto/faces/<username>.face.icon`; the
picture itself is yours to put there, and `uninstall` leaves that directory
alone.

`system/` also carries one line for logind: a tap on the power button is left
to the shell, which opens the session menu, instead of powering the machine
off. It applies from the next boot; holding the button is still the
firmware's own forced power-off.

</details>

## Keys

Every key belongs to a profile: Settings → Keys changes any of them, the
compositor's included, and switching profile switches them all. The three
example profiles use the common Hyprland conventions, and a few are worth
knowing first:

- <kbd>SUPER</kbd> <kbd>Return</kbd> a terminal, <kbd>SUPER</kbd> <kbd>Space</kbd>
  the launcher, <kbd>SUPER</kbd> <kbd>Q</kbd> closes the window
- <kbd>SUPER</kbd> <kbd>1</kbd>…<kbd>0</kbd> a workspace, <kbd>SUPER</kbd>
  <kbd>TAB</kbd> all of them at once
- <kbd>SUPER</kbd> <kbd>X</kbd> the session menu, <kbd>SUPER</kbd> <kbd>L</kbd>
  locks
- <kbd>SUPER</kbd> <kbd>H</kbd> every other key, on the island

## Structure

`home/` is `$HOME` as it is and `system/` is `/` as it is, so where a file sits
in the tree is where it lands. Every file written for this repository opens with
the same 76-column header, carrying its name, what it is, and this repository's
address; `./setup check` is what CI runs over all of it.

<details>
<summary><b>The tree</b></summary>
<br>

```
impasto/
├── setup                               the installer: install, update, sync, uninstall…
├── packages/                           pacman.txt · aur.txt — every package the desk runs
├── home/                               $HOME, as it is
│   ├── .config/
│   │   ├── hypr/
│   │   │   ├── hyprland.lua            entry point
│   │   │   └── modules/                monitors, look, input, keybinds…
│   │   ├── quickshell/
│   │   │   ├── shell.qml               entry point
│   │   │   ├── theme/                  tokens and palettes
│   │   │   ├── services/               state and processes
│   │   │   ├── components/             reusable atoms
│   │   │   ├── bar/                    the bar, its modules and the panels
│   │   │   ├── settings/               the settings window and its sections
│   │   │   ├── desktop/                widgets on the wallpaper, and their faces
│   │   │   ├── deck/                   the notes stacked along the edges
│   │   │   ├── dock/                   the shelf on the edge, and what is open
│   │   │   ├── capture/                the screen held still, and the box on it
│   │   │   ├── lock/                   the session held, through the compositor
│   │   │   └── scripts/                Python backends
│   │   ├── kitty/                      terminal: window, cursor, palette
│   │   ├── btop/                       system monitor, themed by the push
│   │   ├── cava/                       the visualiser, one line and a theme
│   │   ├── yazi/                       file manager: flavour, openers, keys
│   │   ├── nvim/                       the editor: options, theme, plugins
│   │   ├── gtk-3.0/ · gtk-4.0/         the GTK windows, coloured by the push
│   │   ├── fastfetch/                  the greeting, beside an animated scene
│   │   └── starship.toml               the prompt itself
│   ├── .local/share/
│   │   ├── wallpapers/                 the paintings
│   │   └── impasto/                    the palette board, its paint, the example profiles
│   └── .zshrc                          plugins, path, prompt and tools
└── system/                             /, as it is
    ├── etc/sddm.conf.d/                where the machine keeps a face
    └── usr/share/sddm/themes/impasto/
        ├── Main.qml                    the login screen
        └── components/                 its tokens, its capsules, its pickers
```

</details>

## Credits

The island's architecture is borrowed from these, which are worth your time
whether or not you use this repository. No code was copied from them; what
carried over are ideas — one file per island state, one transient signal for
every ephemeral event, input debounced to one frame, and a capture that
photographs the screen and draws the selection on the photograph.

- [Tide-island](https://github.com/enhaoswen/Tide-island) — the closest thing to
  a complete dynamic island for Hyprland
- [ChillPill-Shell](https://github.com/LUCKYS1NGHH/ChillPill-Shell) — a dynamic
  pill bar built to stay light without a dedicated GPU
- [k4](https://github.com/k4ditano/k4) — a dynamic island bar with a documented
  plugin API
- [HyprQuickshot](https://github.com/JamDon2/hyprquickshot) and its fork
  [HyprQuickFrame](https://github.com/Ronin-CK/HyprQuickFrame) — a capture
  surface in Quickshell
- [diegoMalagrida/dotfiles](https://github.com/diegoMalagrida/dotfiles) — an
  Arch Linux desk ready to install on a fresh system

Built on [Quickshell](https://quickshell.org) and [Hyprland](https://hypr.land).
The pointer is [Bibata](https://github.com/ful1e5/Bibata_Cursor), repainted;
the folders are [Papirus](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme),
re-pointed; the type is [Inter](https://rsms.me/inter/) and
[JetBrains Mono](https://www.jetbrains.com/lp/mono/). Six of the nine palettes
are other people's work, carried as they are:
[Catppuccin](https://catppuccin.com) Mocha and Latte,
[Tokyo Night](https://github.com/folke/tokyonight.nvim),
[Gruvbox](https://github.com/morhetz/gruvbox), [Nord](https://www.nordtheme.com)
and [Rosé Pine](https://rosepinetheme.com).

## License

Copyright © 2026 Andreu Massanet — released under the [GNU GPL-3.0](LICENSE).

You may use, study, change and share any of it. If you build on it and pass the
result on, it stays under the GPL and its source stays available. Keep the
header at the top of each file, which carries this repository's address, and a
line of credit back here is the kind thing to do.
