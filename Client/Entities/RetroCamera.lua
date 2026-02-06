RetroCamera = Prop.Inherit("RetroCamera")

RetroCamera.name = "Retro Camera"
RetroCamera.category = "devices"
RetroCamera.image = "package://sandbox/Client/Media/Entities/RetroCamera.webp"

RetroCamera.currently_grabbed = nil
RetroCamera.resolution = 256
RetroCamera.is_aiming = false
RetroCamera.aiming_old_viewmode = nil

RetroCamera.selected_context_menu_items = {
	{
		id = "retrocamera_takephoto",
		type = "button",
		label = "take photo",
		callback = function()
			ContextMenu.selected_entity:TakePhoto()
		end,
	},
}


function RetroCamera:OnSpawn()
	local location = self:GetLocation()

	self.scene_capture = SceneCapture(location, Rotator(), RetroCamera.resolution, RetroCamera.resolution, -1, 5000, 50, false)
	self.scene_capture:AttachTo(self, AttachmentRule.SnapToTarget, "", -1)
	self.scene_capture:SetRelativeLocation(Vector(0, 10, 10))
	self.scene_capture:SetRelativeRotation(Rotator(0, 90, 0))

	self.light = Light(location, Rotator(), Color.WHITE, LightType.Spot, 50, 1000, 50, 0, 5000, true, false, false)
	self.light:AttachTo(self, AttachmentRule.SnapToTarget, "", -1)
	self.light:SetRelativeLocation(Vector(0, 10, 10))
	self.light:SetRelativeRotation(Rotator(0, 90, 0))

	self.sound = Sound(self:GetLocation(), "package://sandbox/Client/Media/Entities/CameraClick.ogg", false, false, SoundType.SFX, 1, 1, 400, 3600, AttenuationFunction.Logarithmic, false, SoundLoopMode.Never, false)
	self.sound:AttachTo(self, AttachmentRule.SnapToTarget, "", -1)

	self.last_photo_time = 0
end

function RetroCamera:OnTakePhoto()
	self.sound:Play()

	self.light:SetVisibility(true)
	Timer.SetTimeout(function()
		self.light:SetVisibility(false)
	end, 100)
end

function RetroCamera:TakePhoto()
	-- Cooldown check (1 second cooldown)
	local curr_time = Client.GetTime()
	if (os.difftime(curr_time, self.last_photo_time) < 1000) then
		return
	end

	self.last_photo_time = curr_time

	-- Capture the photo
	self.scene_capture:CaptureScene()
	self.scene_capture:EncodeToBase64Async(ImageFormat.JPEG, function(base64)
		if (not self or not self:IsValid()) then return end
		self:CallRemoteEvent("TakePhoto", base64)
	end)
end

function RetroCamera.OnLeftClickPressed()
	if (not RetroCamera.currently_grabbed) then return end
	if (Input.IsMouseEnabled()) then return end

	RetroCamera.currently_grabbed:TakePhoto()
	return false
end

function RetroCamera:OnGrab(character)
	local local_player = Client.GetLocalPlayer()
	if (not local_player or local_player:GetControlledCharacter() ~= character) then return end

	RetroCamera.currently_grabbed = self

	Input.Bind("LeftClick", InputEvent.Pressed, RetroCamera.OnLeftClickPressed)

	self.screen = StaticMesh(self:GetLocation(), Rotator(), "nanos-world::SM_Plane", CollisionType.NoCollision)
	self.screen:AttachTo(self, AttachmentRule.SnapToTarget, "", -1)
	self.screen:SetRelativeLocation(Vector(7.5, -11, 12.5))
	self.screen:SetRelativeRotation(Rotator(0, 180, 90))
	self.screen:SetScale(Vector(0.075))

	self.scene_capture:SetRenderRate(0.033)

	self.screen:SetMaterialFromSceneCapture(self.scene_capture, 0)

	-- TODO generic on Grab?
	-- Adds tutorial on screen
	Tutorials.Show("Retro Camera", "Takes photographs and have it printed immediately", {
		{ key = "LeftMouseButton",	text = "takes a photo" },
		{ key = "Undo",				text = "undo last photo" },
		{ key = "MouseScrollUp",	text = "rotate camera" },
		{ key = "RightMouseButton",	text = "change rotation direction" },
	})
end

function RetroCamera:OnUnGrab(character)
	local local_player = Client.GetLocalPlayer()
	if (not local_player or local_player:GetControlledCharacter() ~= character) then return end

	RetroCamera.currently_grabbed = nil

	if (RetroCamera.is_aiming) then
		RetroCamera:OnRightClickReleased()
	end

	self.scene_capture:SetRenderRate(-1)
	self.screen:Destroy()

	Input.Unbind("LeftClick", InputEvent.Pressed, RetroCamera.OnLeftClickPressed)
	Input.Unbind("Aim", InputEvent.Pressed, RetroCamera.OnRightClickPressed)
	Input.Unbind("Aim", InputEvent.Released, RetroCamera.OnRightClickReleased)

	Tutorials.Hide()

end

RetroCamera.Subscribe("Spawn", RetroCamera.OnSpawn)
RetroCamera.Subscribe("Grab", RetroCamera.OnGrab)
RetroCamera.Subscribe("UnGrab", RetroCamera.OnUnGrab)
RetroCamera.SubscribeRemote("OnTakePhoto", RetroCamera.OnTakePhoto)
RetroCamera.SubscribeRemote("ForceTakePhoto", RetroCamera.TakePhoto)


Photograph = Prop.Inherit("Photograph")

-- Context Menu Items when selecting this Entity
Photograph.selected_context_menu_items = {
	{
		id = "photograph_text",
		type = "button",
		label = "copy base64",
		callback = function()
			Client.CopyToClipboard(ContextMenu.selected_entity:GetMaterialTextureParameter("Texture"))
			Client.ShowNotification("Base64 copied to clipboard!", NotificationType.Success, false, 5)
		end,
	},
}