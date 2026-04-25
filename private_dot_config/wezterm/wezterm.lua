-- Pull in the wezterm API
local wezterm = require("wezterm")
local mux = wezterm.mux

-- Session manager plugin
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- Auto-save session with debounce
local save_pending = false
local function save_session()
	if save_pending then
		return
	end
	save_pending = true
	wezterm.time.call_after(5, function()
		local state = resurrect.workspace_state.get_workspace_state()
		resurrect.state_manager.save_state(state, "session")
		save_pending = false
	end)
end

-- Save when tabs/panes change
wezterm.on("update-status", save_session)

-- Restore session on startup and maximize
wezterm.on("gui-startup", function(cmd)
	local state = resurrect.state_manager.load_state("session", "workspace")
	if state then
		resurrect.workspace_state.restore_workspace(state, { relative = true, restore_text = true })
	else
		mux.spawn_window(cmd or {})
	end
	-- Maximize all windows after restore
	wezterm.time.call_after(0.5, function()
		for _, window in ipairs(mux.all_windows()) do
			window:gui_window():maximize()
		end
	end)
end)

-- Font Settings
-- config.font = wezterm.font("SauceCodePro Nerd Font")
-- config.font_size = 12
config.font = wezterm.font_with_fallback({
	{ family = "PixelMplus12", weight = "Regular" },
	{ family = "Unifont-JP", weight = "Regular" },
	{ family = "SauceCodePro Nerd Font", weight = "Regular" },
	{ family = "Noto Color Emoji", weight = "Regular" },
})
config.font_size = 14
-- config.font_size = 17

-- Suppress missing glyph warnings
config.warn_about_missing_glyphs = false

-- Color Scheme (WezTerm includes 700+ built-in schemes)
config.color_scheme = "Catppuccin Mocha"

-- Background Image
config.background = {
	{
		source = {
			File = wezterm.config_dir .. "/wallpapers/c_1.jpg",
		},
		hsb = { brightness = 0.02 },
	},
}

-- Tab Bar Configuration
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = false

-- Key Bindings
config.keys = {
	-- Split panes
	{ key = "d", mods = "CMD", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "d", mods = "CMD|SHIFT", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },

	-- Navigate panes
	{ key = "h", mods = "CMD|SHIFT", action = wezterm.action.ActivatePaneDirection("Left") },
	{ key = "l", mods = "CMD|SHIFT", action = wezterm.action.ActivatePaneDirection("Right") },
	{ key = "k", mods = "CMD|SHIFT", action = wezterm.action.ActivatePaneDirection("Up") },
	{ key = "j", mods = "CMD|SHIFT", action = wezterm.action.ActivatePaneDirection("Down") },

	-- Cycle through panes
	{
		key = "[",
		mods = "CMD",
		action = wezterm.action_callback(function(win, pane)
			local tab = win:active_tab()
			local panes = tab:panes_with_info()
			local active_idx = nil
			for i, p in ipairs(panes) do
				if p.is_active then
					active_idx = i
					break
				end
			end
			if active_idx then
				local next_idx = active_idx - 1
				if next_idx < 1 then
					next_idx = #panes
				end
				panes[next_idx].pane:activate()
			end
		end),
	},
	{
		key = "]",
		mods = "CMD",
		action = wezterm.action_callback(function(win, pane)
			local tab = win:active_tab()
			local panes = tab:panes_with_info()
			local active_idx = nil
			for i, p in ipairs(panes) do
				if p.is_active then
					active_idx = i
					break
				end
			end
			if active_idx then
				local next_idx = active_idx + 1
				if next_idx > #panes then
					next_idx = 1
				end
				panes[next_idx].pane:activate()
			end
		end),
	},

	-- Close pane
	{ key = "w", mods = "CMD", action = wezterm.action.CloseCurrentPane({ confirm = true }) },

	-- Tab navigation
	{ key = "1", mods = "CMD", action = wezterm.action.ActivateTab(0) },
	{ key = "2", mods = "CMD", action = wezterm.action.ActivateTab(1) },
	{ key = "3", mods = "CMD", action = wezterm.action.ActivateTab(2) },
	{ key = "4", mods = "CMD", action = wezterm.action.ActivateTab(3) },
	{ key = "5", mods = "CMD", action = wezterm.action.ActivateTab(4) },
	{ key = "6", mods = "CMD", action = wezterm.action.ActivateTab(5) },
	{ key = "7", mods = "CMD", action = wezterm.action.ActivateTab(6) },
	{ key = "8", mods = "CMD", action = wezterm.action.ActivateTab(7) },
	{ key = "9", mods = "CMD", action = wezterm.action.ActivateTab(-1) },

	-- Move tabs left/right (cover mapped normalization differences for bracket/brace keys)
	{ key = "[", mods = "CMD|SHIFT", action = wezterm.action.MoveTabRelative(-1) },
	{ key = "]", mods = "CMD|SHIFT", action = wezterm.action.MoveTabRelative(1) },
	{ key = "{", mods = "CMD", action = wezterm.action.MoveTabRelative(-1) },
	{ key = "}", mods = "CMD", action = wezterm.action.MoveTabRelative(1) },
	{ key = "{", mods = "CMD|SHIFT", action = wezterm.action.MoveTabRelative(-1) },
	{ key = "}", mods = "CMD|SHIFT", action = wezterm.action.MoveTabRelative(1) },

	-- Session management (resurrect)
	{
		key = "s",
		mods = "CMD|SHIFT",
		action = wezterm.action_callback(function(win, pane)
			local state = resurrect.workspace_state.get_workspace_state()
			resurrect.state_manager.save_state(state, "session")
			win:toast_notification("WezTerm", "Session saved", nil, 2000)
		end),
	},
	{
		key = "r",
		mods = "CMD|SHIFT",
		action = wezterm.action_callback(function(win, pane)
			local state = resurrect.state_manager.load_state("session", "workspace")
			if state then
				resurrect.workspace_state.restore_workspace(state, { relative = true, restore_text = true })
				win:toast_notification("WezTerm", "Session restored", nil, 2000)
			end
		end),
	},

	-- Quit with save (Cmd+Q)
	{
		key = "q",
		mods = "CMD",
		action = wezterm.action_callback(function(win, pane)
			local state = resurrect.workspace_state.get_workspace_state()
			resurrect.state_manager.save_state(state, "session")
			win:perform_action(wezterm.action.QuitApplication, pane)
		end),
	},

	-- Insert newline without sending (Shift+Enter) using bracketed paste
	{
		key = "Enter",
		mods = "SHIFT",
		action = wezterm.action.SendString("\x1b[200~\n\x1b[201~"),
	},
}

-- Finally, return the configuration to wezterm:
return config
