Character.Subscribe("WeaponAimModeChange", function(self, old_state, new_state)

    local player = self:GetPlayer() ---- gets player
    local object = self:GetPicked() ---- gets item in hands

    if player and object then       ------ does only if player have an item in his hands
        if new_state == (AimMode.None) then
            self:SetWeaponAimMode(AimMode.ZoomedFar)  ---- redirects default holster of None to ZoomedFar
        end
        if new_state == (AimMode.Zoomed) then
            self:SetWeaponAimMode(AimMode.ADS)  ---- redirects default holster of Zoomed to ADS
        end
    end

end)

Character.Subscribe("PickUp", function(self, object)

    local player = self:GetPlayer()
    local object = self:GetPicked()

    if player and object then
        self:SetWeaponAimMode(AimMode.ZoomedFar)  ------ sets default holster to ZoomedFar on item pickup
    end
    
end)

Character.Subscribe("GaitModeChange", function(self, old_state, new_state)

    local player = self:GetPlayer()
    local object = self:GetPicked()
    local CurAimMode = self:GetWeaponAimMode()      -------- returns current Holster

    if player and object and new_state == (GaitMode.Sprinting) then   ---- checks if player is holding an item and is sprinting
        self:SetWeaponAimMode(AimMode.None)  ------ puts item down when player is sprinting for immersion
    elseif player and object then
        self:SetWeaponAimMode(CurAimMode) ------- sets it to whatever current Holster is if conditions are not met
    end

end)

Character.Subscribe("FallingModeChange", function(self, old_state, new_state)

    local player = self:GetPlayer()
    local object = self:GetPicked()
    local CurAimMode = self:GetWeaponAimMode()

    if player and object and new_state == (FallingMode.Falling) or player and object and new_state == (FallingMode.HighFalling) then
        self:SetWeaponAimMode(AimMode.None) ---- same thing as for sprinting but when player jumps or falls
    elseif player and object then
        self:SetWeaponAimMode(CurAimMode)
    end

end)