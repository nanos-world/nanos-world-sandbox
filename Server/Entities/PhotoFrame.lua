PhotoFrame = Prop.Inherit("PhotoFrame")

ConfigureSpawnLimits("PhotoFrame", "Photo Frames", PhotoFrame.GetCount, "max_photo_frames")

function PhotoFrame:Constructor(location, rotation, tab, id, player)
	self.Super:Constructor(location or Vector(), (rotation or Rotator()) + Rotator(0, 90, 0), "nanos-world::SM_PhotoFrame")

	if (player) then
		Events.CallRemote("AddNotification", player, NotificationType.Info, "PHOTO_FRAME_TUTORIAL", "you can change the Photo Frame image by selecting it in the Context Menu", 10, 5)
	end
end

function PhotoFrame:OnSetPhoto(player, image)
	self:SetMaterialTextureParameter("Texture", image, 1)
end

PhotoFrame.SubscribeRemote("SetPhoto", PhotoFrame.OnSetPhoto)
