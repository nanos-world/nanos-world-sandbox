NameTags = {
	nametag_active = ""
}

Timer.SetInterval(function()
	-- Gets the local player
	local local_player = Client.GetLocalPlayer()
	if (not local_player) then return end

	local local_character = local_player:GetControlledCharacter()

	-- Gets the camera rotation and location
	local camera_rotation = local_player:GetCameraRotation()
	local start_location = local_player:GetCameraLocation()

	-- Calculates the direction vector based on the camera rotation
	local direction =  camera_rotation:GetForwardVector()

	-- Calculates the end location of the trace
	-- (start location + 1000 units in the direction of the camera)
	local end_location = start_location + direction * 1000

	local collision_trace = CollisionChannel.Pawn
	local trace_mode = TraceMode.ReturnEntity

	-- Do the trace
	local ignored_actors = {}
	if (local_character) then
		table.insert(ignored_actors, local_character)
	end

	local trace_result = Trace.LineSingle(start_location, end_location, collision_trace, trace_mode, ignored_actors)

	local trace_entity = trace_result.Entity

	-- If the trace was successful
	if (trace_result.Success and trace_entity and trace_entity:IsA(Character)) then
		local player = trace_entity:GetPlayer()
		if (player) then
			local player_name = player:GetName()
			if (NameTags.nametag_active ~= player_name) then
				NameTags.nametag_active = player_name
				MainHUD:CallEvent("ShowNameTag", true, player_name)
			end
		end
	elseif (NameTags.nametag_active ~= "") then
		NameTags.nametag_active = ""
		MainHUD:CallEvent("ShowNameTag", false)
	end
end, 100)