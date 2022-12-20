Thruster = Prop.Inherit("Thruster")

function Thruster:Constructor(location, rotation)
	self.Super:Constructor(location, rotation, "nanos-world::SM_Jet_Thruster", CollisionType.StaticOnly, true, GrabMode.Disabled)

	-- Adds a constant force to the Thruster
	self:SetForce(Vector(100000, 0, 0), true)
end