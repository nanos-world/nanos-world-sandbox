Balloon = Prop.Inherit("Balloon")

Balloon.name = "Balloon"
Balloon.image = "assets://nanos-world/Thumbnails/SM_Balloon_01.jpg"
Balloon.category = "objects"

-- Context Menu Items when selecting this Entity
Balloon.selected_context_menu_items = {
	{
		label = "mesh",
		type = "select_image",
		options = BALLOON_ASSETS,
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetCustomMesh", value)
		end,
		value = function()
			return ContextMenu.selected_entity:GetMesh()
		end,
	},
	{
		label = "force",
		type = "range",
		min = -100,
		max = 200,
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetCustomForce", value * 1000)
		end,
		value = function()
			return math.ceil(ContextMenu.selected_entity:GetForce().Z / 1000)
		end,
	}
}

function Balloon:OnDestroy()
	-- Avoiding spawning particles and sound if it's too far
	if (self:GetDistanceFromCamera() > 5000) then return end

	local balloon_location = self:GetLocation()

	Sound(balloon_location, "nanos-world::A_Balloon_Pop", false, true, SoundType.SFX, 1, 1)
	Particle(balloon_location + Vector(0, 0, 30), Rotator(), "nanos-world::P_OmnidirectionalBurst", true, true):SetParameterColor("Color", self:GetMaterialColorParameter("Tint"))
end

Balloon.Subscribe("Destroy", Balloon.OnDestroy)