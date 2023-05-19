require "OptionScreens/CharacterCreationProfession"
require "CDTools"
require "CDCharRandomizer"
require "CDCharRandomizerSettings"

-- TODO: UI for choosing traits in the character creation menu.
function CharacterCreationProfession:randomizeTraits()
    -- Pick the required profession
    -- (try to) Pick the required traits.
    --- Report trait conflicts.
    -- Pick the required categories
    -- Add new traits until a threshold is reached:
    --- no more traits
    --- max number of traits (positive or negative)
    --- max number of points (absolute)
    self:resetBuild();

    -- TODO: Required profession.
    local index = ZombRand(#self.listboxProf.items)+1;  -- I will comment this every time - YUCK ONE-INDEXING
    self.listboxProf.selected = index;
    self:onSelectProf(self.listboxProf.items[self.listboxProf.selected].item);

    --- For now, instead of using a truly random algorithm, I'm choosing a few "core" traits,
    ---   high value traits that the build is based around.
    --- Then, I add other traits to balance those "core" traits out.
    --- This is much more like how a human would choose traits,
    ---   and I believe leads to much more interesting designs,
    ---   rather than a scattershot of low-value uninteresting traits.

    -- Sort traits by their costs.
    local trait_table_ar = {};  -- V: zombie.characters.traits.TraitFactory.Trait
    --- While I could use TraitFactory.getTraits() and filter it myself,
    ---   it seems more sustainable to rely on the game's sorting and
    ---   simply iterate on both lists.
    for index, trait in pairs(self.listboxBadTrait.items) do
        trait_table_ar[#trait_table_ar + 1] = trait;
    end
    for index, trait in pairs(self.listboxTrait.items) do
        trait_table_ar[#trait_table_ar + 1] = trait;
    end

    self:CDHandleRequiredBannedTraits(trait_table_ar);

    --- Shuffle table. This will be our source of randomness.
    --- We will search through the table, from the first to the last element,
    ---   till a valid trait matches. Then we remove that item from table and use it.
    CDTools.FisherYatesShuffle(trait_table_ar);
    
    -- Not sure if there's a random range function in zomboid 
    local core_range = CDCharRandomizer.coreMax_i - CDCharRandomizer.coreMin_i;
    local core_num = ZombRand(core_range + 1) + CDCharRandomizer.coreMin_i;

    -- Get core traits
    local core_current = 0
    for index, trait in pairs(trait_table_ar) do
        local cost = trait.item:getCost();
        self:CDAddTrait(trait);
        core_current = core_current + 1;

        if core_current >= core_num then
            break
        end
    end

    if core_current < core_num then
        print("CDCharRandomizer: Could not get core traits.");
    end

    self:CDBalancePoints(trait_table_ar);
end

function CharacterCreationProfession:CDBalancePoints(trait_table_ar)
    local points = self:PointToSpend();
    if points == 0 then
        return;
    end

    if points > 0 then
        while points > 0 do
            local found_trait = false;
            points = self:PointToSpend();
    
            for i, trait in pairs(trait_table_ar) do
                local cost = trait.item:getCost();
                if cost > 0 and points >= cost then
                    self:CDAddTrait(trait);
                    table.remove(trait_table_ar, i);
                    found_trait = true;
                    break;
                end
            end
    
            if not found_trait then
                break
            end
        end
    else
        -- try to find the smallest negative value we can, in the random order.
        local negative_attempts = 0;
        while points < 0 do
            local found_trait = false;
            local bigger_negative = false;
            points = self:PointToSpend();
    
            for i, trait in pairs(trait_table_ar) do
                local cost = trait.item:getCost();
                if cost < points then
                    bigger_negative = true;
                end

                if cost < 0 and points + negative_attempts <= cost then
                    self:CDAddTrait(trait);
                    table.remove(trait_table_ar, i);
                    found_trait = true;
                    break;
                end
            end
    
            if found_trait then
                -- no continue? :/
            elseif not bigger_negative then
                print("CDCharacterRandomizer: Could not find enough negative traits of offset positive traits!");
                break
            else
                negative_attempts = negative_attempts - 1;
            end
        end
    end   
end

function CharacterCreationProfession:CDHandleRequiredBannedTraits(trait_table_ar)
    local tt = CDTools.ShallowCopy(trait_table_ar);
    local num_removed = 0;
    for index, trait in pairs(tt) do
        local trait_name = trait.item:getType();
        if CDCharRandomizer.requiredTraits_hs[trait_name] == true then
            self:CDAddTrait(trait);
            table.remove(trait_table_ar, index - num_removed);
            num_removed = num_removed + 1;
        elseif CDCharRandomizer.bannedTraits_hs[trait_name] == true then
            table.remove(trait_table_ar, index - num_removed);
            num_removed = num_removed + 1;
        end
    end
end

function CharacterCreationProfession:CDAddTrait(trait)
    -- Add negative
    if trait.item:getCost() < 0 then
        local i = CDTools.TableContains(self.listboxBadTrait.items, trait);
        if i == -1 then
            -- TODO: Figure out exception/debugging for this.
            return
        end
        self.listboxBadTrait.selected = i;
        self:onOptionMouseDown(self.addBadTraitBtn);
    -- Add positive
    elseif trait.item:getCost() > 0 then
        local i = CDTools.TableContains(self.listboxTrait.items, trait);
        if i == -1 then
            -- TODO: Figure out exception/debugging for this.
            return
        end
        self.listboxTrait.selected = i;
        self:onOptionMouseDown(self.addTraitBtn);
    else
        CDTools.CDDebug("Tried to add a trait with value of 0. I don't know how to!");
    end
end

local ccp_create_base = CharacterCreationProfession.create;
function CharacterCreationProfession:create()
    ccp_create_base(self);

    local button_text = "RANDOM SETTINGS";
    local textWid = getTextManager():MeasureStringX(UIFont.Small, button_text);
	local randomSettingsButtonWid = math.max(100, textWid + 8 * 2);
    self.randomSettingsButton = ISButton:new(self.resetButton:getX() - 10 - randomSettingsButtonWid, self.resetButton:getY(), randomSettingsButtonWid, self.resetButton.height, button_text, self, CharacterCreationProfession.OpenRandomizerSettings);
    self.randomSettingsButton:initialise();
    self.randomSettingsButton:instantiate();
    self.randomSettingsButton:setAnchorLeft(false);
    self.randomSettingsButton:setAnchorRight(true);
    self.randomSettingsButton:setAnchorTop(false);
    self.randomSettingsButton:setAnchorBottom(true);
    self.randomSettingsButton.borderColor = { r = 1, g = 1, b = 1, a = 0.1 };
    self.mainPanel:addChild(self.randomSettingsButton);
end

function CharacterCreationProfession:OpenRandomizerSettings()
    local joypadData = JoypadState.getMainMenuJoypad() or CoopCharacterCreation.getJoypad();
    MainScreen.instance.charCreationProfession:setVisible(false);
    CDCharRandomizerSettings:setVisible(true, joypadData);
end


local main_screen_instantiate_base = MainScreen.instantiate;
function MainScreen:instantiate()
    main_screen_instantiate_base(self);

    if not self.inGame and not isDemo() then
        CDCharRandomizerSettings = CDCharRandomizerSettings:new(0, 0, self.width, self.height);
        CDCharRandomizerSettings:initialise();
        CDCharRandomizerSettings:setVisible(false);
        CDCharRandomizerSettings:setAnchorRight(true);
        CDCharRandomizerSettings:setAnchorLeft(true);
        CDCharRandomizerSettings:setAnchorBottom(true);
        CDCharRandomizerSettings:setAnchorTop(true);
        CDCharRandomizerSettings.backgroundColor = {r=0, g=0, b=0, a=0.0};
        CDCharRandomizerSettings.borderColor = {r=1, g=1, b=1, a=0.0};

        self:addChild(CDCharRandomizerSettings);
        CDCharRandomizerSettings:create();
    end
end