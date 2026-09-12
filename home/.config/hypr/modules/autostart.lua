-- ╭──────────────────────────────────────────────────────────────────────────╮
-- │                                                                          │
-- │   A U T O S T A R T                                                      │
-- │   processes launched with the session                                    │
-- │                                                                          │
-- │   github.com/andreumassanet/impasto                                      │
-- │                                                                          │
-- ╰──────────────────────────────────────────────────────────────────────────╯

-- https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Quickshell owns org.freedesktop.Notifications, so no separate notification
-- daemon runs: only one process can hold that bus name.
hl.on("hyprland.start", function()
    hl.exec_cmd("qs -d")        -- · bar and notifications (quickshell)
    hl.exec_cmd("awww-daemon")  -- · wallpaper
end)

-- · plugins (see input.lua, look.lua), built by `./setup plugins`
--
-- Only reload once something is built: otherwise hyprpm shows a headers
-- notification on every login. Its store is per user under /var/cache.
hl.on("hyprland.start", function()
    hl.exec_cmd('test -d "/var/cache/hyprpm/$USER" && hyprpm reload')
end)

-- · polkit agent
--
-- Without one, privileged requests (mounting a disk, etc.) fail silently.
local polkit_agent = "/usr/lib/polkit-kde-authentication-agent-1"
hl.on("hyprland.start", function()
    hl.exec_cmd("test -x " .. polkit_agent .. " && " .. polkit_agent)
end)
