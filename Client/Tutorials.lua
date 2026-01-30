Tutorials = {

}

function Tutorials.Parse(tutorials_data)
	local tutorials_parsed = {}

	for _, tutorial_data in pairs(tutorials_data) do
		-- Get the mapped key or use it as Raw if didn't find (probably it's a raw key)
		local mapped_key = Input.GetMappedKeys(tutorial_data.key)[1] or tutorial_data.key

		-- Gets the image path
		local key_icon = Input.GetKeyIcon(mapped_key)

		table.insert(tutorials_parsed, { image = key_icon, text = tutorial_data.text })
	end

	return tutorials_parsed
end

function Tutorials.Show(name, tutorials_data)
	local tutorials_parsed = Tutorials.Parse(tutorials_data)
	MainHUD:CallEvent("ToggleTutorial", true, name, tutorials_parsed)
end

function Tutorials.Hide()
	MainHUD:CallEvent("ToggleTutorial", false)
end