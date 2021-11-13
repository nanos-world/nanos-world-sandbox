function SpawnCCTV(location, rotation)
	-- Spawns a TV prop
	local tv = Prop(location , rotation + Rotator(0, 90, 0), "nanos-world::SM_TV")
	local camera = Prop(location + rotation:UnrotateVector(Vector(150, 0, 0)), rotation, "nanos-world::SM_Camera")

	local cable = Cable(location or Vector())
	cable:AttachStartTo(camera, Vector(-85, 0, 0))
	cable:AttachEndTo(tv, Vector(0, 0, 10))
	cable:SetLinearLimits(ConstraintMotion.Limited, ConstraintMotion.Limited, ConstraintMotion.Limited, 10000, 0, true, 10000, 100)
	cable:SetMaterialColorParameter("Tint", Color.BLACK)
	cable:SetRenderingSettings(5, 4, 1)

	tv:SetValue("CCTV", camera, true)

	tv:Subscribe("Destroy", function(self)
		local camera_prop = self:GetValue("CCTV")
		if (camera_prop and camera_prop:IsValid()) then
			camera_prop:Destroy()
		end
	end)

	Events.BroadcastRemote("SpawnCCTV", tv, camera)

	return tv
end

-- Adds this to the Sandbox Spawn Menu
AddSpawnMenuItem("nanos-world", "entities", "CCTV", SpawnCCTV)