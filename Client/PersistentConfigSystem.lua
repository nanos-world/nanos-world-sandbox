-- Persistent Configuration System to be used with ToolGuns or any other entity
PersistentConfigSystem = {
	-- Overridden configs
	overridden_configs = Package.GetPersistentData("overridden_configs") or {}
}

-- Exposes PersistentConfigSystem to other packages
Sandbox.PersistentConfigSystem = PersistentConfigSystem


function PersistentConfigSystem.SaveConfig(class_name, config, value)
	Package.SetPersistentData("overridden_configs." .. class_name .. "." .. config, value)

	local overridden_configs = PersistentConfigSystem.overridden_configs[class_name]

	if (not overridden_configs) then
		PersistentConfigSystem.overridden_configs[class_name] = {}
		overridden_configs = PersistentConfigSystem.overridden_configs[class_name]
	end

	overridden_configs[config] = value
end

function PersistentConfigSystem.GetConfig(class_name, config_name)
	local overridden_configs = PersistentConfigSystem.overridden_configs[class_name]
	if (not overridden_configs) then return nil end

	return overridden_configs[config_name]
end