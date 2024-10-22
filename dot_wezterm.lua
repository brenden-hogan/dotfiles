local wezterm = require("wezterm")

local act = wezterm.action
local mux = wezterm.mux

local config = wezterm.config_builder()
local keys = {}

-- print the workspace name at the upper right
wezterm.on("update-right-status", function(window, pane)
  window:set_right_status(window:active_workspace())
end)
-- load plugin
local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")
-- set path to zoxide
workspace_switcher.zoxide_path = "/opt/homebrew/bin/zoxide"
-- workspace keymaps
table.insert(keys, { key = 's', mods = 'CTRL|SHIFT', action = workspace_switcher.switch_workspace() })
table.insert(keys, { key = 't', mods = 'CTRL|SHIFT', action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) })
table.insert(keys, { key = '[', mods = 'CTRL|SHIFT', action = act.SwitchWorkspaceRelative(1) })
table.insert(keys, { key = ']', mods = 'CTRL|SHIFT', action = act.SwitchWorkspaceRelative(-1) })

-- prompt for a name to use for a new workspace and switch to it.
table.insert(keys,
  {
    key = 'W',
    mods = 'CTRL|SHIFT',
    action = act.PromptInputLine {
      description = wezterm.format {
        { Attribute = { Intensity = 'Bold' } },
        { Foreground = { AnsiColor = 'Fuchsia' } },
        { Text = 'Enter name for new workspace' },
      },
      action = wezterm.action_callback(function(window, pane, line)
        -- line will be `nil` if they hit escape without entering anything
        -- An empty string if they just hit enter
        -- Or the actual line of text they wrote
        if line then
          window:perform_action(
            act.SwitchToWorkspace {
              name = line,
            },
            pane
          )
        end
      end),
    },
  })

-- mux keymaps
table.insert(keys, { key = '"', mods = 'CTRL|SHIFT', action = act.SplitVertical {domain= 'CurrentPaneDomain'}})
table.insert(keys, { key = '%', mods = 'CTRL|SHIFT', action = act.SplitHorizontal {domain= 'CurrentPaneDomain'}})


-- finish
config.keys = keys
return config
