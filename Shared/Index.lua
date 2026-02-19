-- Helper to load all files in a folder
function RequireAllLuaFilesInFolder(folder)
	local files = Package.GetFiles(folder, ".lua")
	for _, file in pairs(files) do
		Package.Require(file)
	end
end

-- Load all configs
RequireAllLuaFilesInFolder("Shared/Config")