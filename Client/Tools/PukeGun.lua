PukeGun = Weapon.Inherit("PukeGun")

-- Tool Info
PukeGun.name = "Puke Gun"
PukeGun.category = "spawners"
PukeGun.image = "package://sandbox/Client/Media/Tools/PukeGun.webp"
PukeGun.description = "Pukes things out"
PukeGun.tab = "tools" -- Overrides the tab (so it won't get at 'weapons' tab)

-- Tool Tutorials
PukeGun.tutorials = {
	{ key = "LeftClick",	text = "puke out" },
	{ key = "ContextMenu",	text = "puke settings" },
}

-- Default options
PukeGun.options = {
	{ id = "watermelons", name = "Watermelons" },
	{ id = "veggies", name = "Veggies" },
	{ id = "trash_bags", name = "Trash Bags" },
	{ id = "bouncy_balls", name = "Bouncy Balls" },
	{ id = "balloons", name = "Balloons" },
	{ id = "propane_tanks", name = "Propane Tanks" },
	{ id = "tycoon", name = "Tycoon" },
	{ id = "ragdolls", name = "Ragdolls" },
}

-- Context Menu Items when picking up this Tool
PukeGun.picked_context_menu_items = {
	{
		label = "option",
		type = "select",
		options = PukeGun.options,
		callback = function(value)
			local puke_gun = Client.GetLocalPlayer():GetControlledCharacter():GetPicked()
			puke_gun:CallRemoteEvent("SetOption", value)
		end,
		value = function()
			local puke_gun = Client.GetLocalPlayer():GetControlledCharacter():GetPicked()
			return puke_gun:GetValue("Option") or "watermelons"
		end
	},
	{
		label = "force",
		type = "range",
		min = 1000,
		max = 10000,
		step = 100,
		callback = function(value)
			local puke_gun = Client.GetLocalPlayer():GetControlledCharacter():GetPicked()
			puke_gun:CallRemoteEvent("SetCustomForce", value)
		end,
		value = function()
			local puke_gun = Client.GetLocalPlayer():GetControlledCharacter():GetPicked()
			return puke_gun:GetValue("Force") or 3000
		end
	},
	{
		label = "cadence",
		type = "range",
		min = 0.05,
		max = 1,
		step = 0.05,
		callback = function(value)
			local puke_gun = Client.GetLocalPlayer():GetControlledCharacter():GetPicked()
			puke_gun:CallRemoteEvent("SetCadence", value)
		end,
		value = function()
			local puke_gun = Client.GetLocalPlayer():GetControlledCharacter():GetPicked()
			return puke_gun:GetCadence()
		end
	},
}