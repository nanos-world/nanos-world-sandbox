-- Subscribe for Client's custom event, for when the object is grabbed/dropped
Events:Subscribe("PickUp", function(player, object, is_grabbing)
    object:SetGravityEnabled(not is_grabbing)
    object:TranslateTo(object:GetLocation(), 0)
end)

-- Subscribe for Client's custom event, to update the position of the object he is grabbing
Events:Subscribe("UpdateObjectPosition", function(player, object, location)
    object:TranslateTo(location, 10)
end)

Prop(Vector(100, 100, 100), Rotator(), "NanosWorld::SM_Cube")
Prop(Vector(200, 100, 100), Rotator(), "NanosWorld::SM_Cube")
Prop(Vector(300, 100, 100), Rotator(), "NanosWorld::SM_Cube")