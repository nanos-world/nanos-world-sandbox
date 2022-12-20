RemoverGun = ToolGun.Inherit("RemoverGun")

function RemoverGun:Constructor(location, rotation)
	-- Calls parent ToolGun constructor
	ToolGun.Constructor(self, location, rotation, Color.RED)
end