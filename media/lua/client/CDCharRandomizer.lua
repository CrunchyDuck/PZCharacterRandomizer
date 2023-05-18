require "CDTools"

CDCharRandomizer = {};
CDCharRandomizer.requiredTraits_hs = {};  -- K: zombie.characters.traits.TraitFactory.Trait
CDCharRandomizer.requiredProfession = nil;  -- zombie.characters.professions.ProfessionFactory.Profession
CDCharRandomizer.coreMin_i = 2;
CDCharRandomizer.coreMax_i = 5;
CDCharRandomizer.lowValueCutoff_i = 4;

CDCharRandomizerDefaults = CDTools.ShallowCopy(CDCharRandomizer);

function CDCharRandomizer:SaveRandomizerSettings()
	local writer = getFileWriter("CharacterRandomizerSettings.txt", true, false);
    local vals = {};
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
    -- TODO: Default values.
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
    local curr_variable = "";

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