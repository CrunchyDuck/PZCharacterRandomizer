require "CDTools"

CDCharRandomizer = {};

CDCharRandomizer.requiredProfession_str = "";  -- return of zombie.characters.professions.ProfessionFactory.Profession.getType()
CDCharRandomizer.bannedProfessions_hs = {};  -- return of zombie.characters.professions.ProfessionFactory.Profession.getType()
-- I don't know if Trait.getType() is a unique identifier, but I couldn't find a way to access Trait.traitID. This might be it??
CDCharRandomizer.requiredTraits_hs = {};  -- K: return of zombie.characters.traits.TraitFactory.Trait.getType()
CDCharRandomizer.bannedTraits_hs = {};  -- K: return of zombie.characters.traits.TraitFactory.Trait.getType()
CDCharRandomizer.coreMin_i = 2;
CDCharRandomizer.coreMax_i = 5;
CDCharRandomizer.lowValueCutoff_i = 6;

CDCharRandomizerDefaults = CDTools:ShallowCopy(CDCharRandomizer);

function CDCharRandomizer:SaveRandomizerSettings()
	local writer = getFileWriter("CharacterRandomizerSettings.txt", true, false);
    local vals = {};
    local traits_serialized = "";

    for trait_name, _ in pairs(CDCharRandomizer.requiredTraits_hs) do
        traits_serialized = traits_serialized .. trait_name .. ";";
    end
    vals.requiredTraits_hs = traits_serialized;

    traits_serialized = "";
    for trait_name, _ in pairs(CDCharRandomizer.bannedTraits_hs) do
        traits_serialized = traits_serialized .. trait_name .. ";";
    end
    vals.bannedTraits_hs = traits_serialized;

    profs_serialized = "";
    for prof_name, _ in pairs(CDCharRandomizer.bannedProfessions_hs) do
        profs_serialized = profs_serialized .. prof_name .. ";";
    end
    vals.bannedProfessions_hs = profs_serialized;

    vals["requiredProfession_str"] = CDCharRandomizer.requiredProfession_str;
    vals["coreMin_i"] = CDCharRandomizer.coreMin_i;
    vals["coreMax_i"] = CDCharRandomizer.coreMax_i;
    vals["lowValueCutoff_i"] = CDCharRandomizer.lowValueCutoff_i;

    for k, v in pairs(vals) do
        writer:writeln(k .. "=" .. tostring(v));
    end

    writer:close();
end

function CDCharRandomizer:LoadRandomizerSettings()
	local loaded_data = {};
	local reader = getFileReader("CharacterRandomizerSettings.txt", false);
	if not reader then
		return;
	end

	while true do
		local line = reader:readLine();
		if not line then
			reader:close();
			break;
		end

		line = line:trim();
		if line ~= "" then
			local k, v = line:match("^(.+)=(.+)$");
			if k then
				k = k:trim();
				loaded_data[k] = v:trim();
            end
		end
	end

    -- Parse read values, or apply defaults.
    local curr_variable = "requiredProfession_str";
    if loaded_data[curr_variable] ~= nil then
        CDCharRandomizer[curr_variable] = loaded_data[curr_variable];
    else
        CDCharRandomizer[curr_variable] = CDCharRandomizerDefaults[curr_variable];
    end

    local curr_variable = "bannedProfessions_hs";
    if loaded_data[curr_variable] ~= nil then
        for prof_name in string.gmatch(loaded_data[curr_variable], "([^;]*);") do
            CDCharRandomizer[curr_variable][prof_name] = true;
        end
    else
        CDCharRandomizer[curr_variable] = CDCharRandomizerDefaults[curr_variable];
    end

    local curr_variable = "requiredTraits_hs";
    if loaded_data[curr_variable] ~= nil then
        for trait_name in string.gmatch(loaded_data[curr_variable], "([^;]*);") do
            CDCharRandomizer[curr_variable][trait_name] = true;
        end
    else
        CDCharRandomizer[curr_variable] = CDCharRandomizerDefaults[curr_variable];
    end
    
    local curr_variable = "bannedTraits_hs";
    if loaded_data[curr_variable] ~= nil then
        for trait_name in string.gmatch(loaded_data[curr_variable], "([^;]*);") do
            CDCharRandomizer[curr_variable][trait_name] = true;
        end
    else
        CDCharRandomizer[curr_variable] = CDCharRandomizerDefaults[curr_variable];
    end

    local curr_variable = "coreMin_i";
    if loaded_data[curr_variable] ~= nil then
        CDCharRandomizer[curr_variable] = tonumber(loaded_data[curr_variable]);
    else
        CDCharRandomizer[curr_variable] = CDCharRandomizerDefaults[curr_variable];
    end

    local curr_variable = "coreMax_i";
    if loaded_data[curr_variable] ~= nil then
        CDCharRandomizer[curr_variable] = tonumber(loaded_data[curr_variable]);
    else
        CDCharRandomizer[curr_variable] = CDCharRandomizerDefaults[curr_variable];
    end

    local curr_variable = "lowValueCutoff_i";
    if loaded_data[curr_variable] ~= nil then
        CDCharRandomizer[curr_variable] = tonumber(loaded_data[curr_variable]);
    else
        CDCharRandomizer[curr_variable] = CDCharRandomizerDefaults[curr_variable];
    end
end

CDCharRandomizer:LoadRandomizerSettings();