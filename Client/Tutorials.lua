Tutorials = {}

-- Exposes Tutorials to other packages
Sandbox.Tutorials = Tutorials

function Tutorials.Parse(keys_data)
	local keys_parsed = {}

	for _, key_data in pairs(keys_data) do
		-- Get the mapped key or use it as Raw if didn't find (probably it's a raw key)
		local mapped_key = Input.GetMappedKeys(key_data.key)[1] or key_data.key

		-- Gets the image path
		local key_icon = Input.GetKeyIcon(mapped_key)

		table.insert(keys_parsed, { image = key_icon, text = key_data.text })
	end

	return keys_parsed
end

-- Shows the Tutorials UI
---@param title string             Tutorials title
---@param description string       Description
---@param keys_data table          Table of keys in the format
---@                               { { key = "KeyName", description = "What it does" }, ... }
function Tutorials.Show(title, description, keys_data)
	local keys_parsed = Tutorials.Parse(keys_data)
	Sandbox.HUD:CallEvent("ToggleTutorial", true, title, description, keys_parsed)
end

-- Hides the Tutorials UI
function Tutorials.Hide()
	Sandbox.HUD:CallEvent("ToggleTutorial", false)
end