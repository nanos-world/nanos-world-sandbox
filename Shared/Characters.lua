function GetCharacterClasses()
    local character_classes = {}

    for k, character_class in pairs(Character.GetInheritedClasses(true)) do
        if (character_class.name ~= nil) then
            character_classes[character_class:GetName()] = character_class
        end
    end

    for k, character_class in pairs(CharacterSimple.GetInheritedClasses(true)) do
        if (character_class.name ~= nil) then
            character_classes[character_class:GetName()] = character_class
        end
    end

    return character_classes
end
