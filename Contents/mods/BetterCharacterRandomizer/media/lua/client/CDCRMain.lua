require "OptionScreens/CharacterCreationProfession"
require "CDTools"
require "CDCharRandomizer"
require "CDCharRandomizerSettings"

-- TODO: Ban/Require profession
-- TODO: Turn off buttons when adding/removing trait

local col_b = {a = 0.1, r = 1, g = 0, b = 0};
local col_r = {a = 0.1, r = 0, g = 1, b = 0};

local draw_trait_map_base = CharacterCreationProfession.drawTraitMap;
function CharacterCreationProfession:drawTraitMap(y, item, alt)
    local trait_name = item.item:getType();
    -- self:drawRect(0, y, self:getWidth(), self.itemheight - 1, col_r.a, col_r.r, col_r.g, col_r.b);
    if CDCharRandomizer.requiredTraits_hs[trait_name] == true then
        self:drawRect(0, y, self:getWidth(), self.itemheight - 1, col_r.a, col_r.r, col_r.g, col_r.b);
    elseif CDCharRandomizer.bannedTraits_hs[trait_name] == true then
        self:drawRect(0, y, self:getWidth(), self.itemheight - 1, col_b.a, col_b.r, col_b.g, col_b.b);
    end

    return draw_trait_map_base(self, y, item, alt);
end

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
    if CDCharRandomizer.requiredProfession_str == "" then
        local index = ZombRand(#self.listboxProf.items)+1;  -- I will comment this every time - YUCK ONE-INDEXING
        self.listboxProf.selected = index;
        self:onSelectProf(self.listboxProf.items[self.listboxProf.selected].item);
    else
        local found_profession = false;
        for i, v in pairs(self.listboxProf.items) do
            if v.item:getType() == CDCharRandomizer.requiredProfession_str then
                self.listboxProf.selected = i;
                self:onSelectProf(v.item);
                found_profession = true;
                break
            end
        end
        if not found_profession then
            print("CDCharRandomizer: Could not find profession with name " .. CDCharRandomizer.requiredProfession_str);
            local index = ZombRand(#self.listboxProf.items)+1;  -- I will comment this every time - YUCK ONE-INDEXING
            self.listboxProf.selected = index;
            self:onSelectProf(self.listboxProf.items[self.listboxProf.selected].item);
        end
    end

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
    CDTools:FisherYatesShuffle(trait_table_ar);
    
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
    local tt = CDTools:ShallowCopy(trait_table_ar);
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
        local i = CDTools:TableContains(self.listboxBadTrait.items, trait);
        if i == -1 then
            -- TODO: Figure out exception/debugging for this.
            return
        end
        self.listboxBadTrait.selected = i;
        self:onOptionMouseDown(self.addBadTraitBtn);
    -- Add positive
    elseif trait.item:getCost() > 0 then
        local i = CDTools:TableContains(self.listboxTrait.items, trait);
        if i == -1 then
            -- TODO: Figure out exception/debugging for this.
            return
        end
        self.listboxTrait.selected = i;
        self:onOptionMouseDown(self.addTraitBtn);
    else
        print("CDCharRandomizer: Tried to add a trait with value of 0. I don't know how to!");
    end
end

local ccp_create_base = CharacterCreationProfession.create;
function CharacterCreationProfession:create()
    ccp_create_base(self);
    self:PrepareRandomizerSettings();

    -- Add required positive trait
    local x = self.addTraitBtn:getX() - 100;
    self.addRequiredTraitBtn = ISButton:new(x, (self.listboxTrait:getY() + self.listboxTrait:getHeight()) + self.traitButtonPad, 50, self.traitButtonHgt, "Toggle Require", self, self.OnButtonRequireTrait);
    self.addRequiredTraitBtn.internal = "REQUIRETRAIT";
    self.addRequiredTraitBtn:initialise();
    self.addRequiredTraitBtn:instantiate();
    self.addRequiredTraitBtn:setAnchorLeft(true);
    self.addRequiredTraitBtn:setAnchorRight(false);
    self.addRequiredTraitBtn:setAnchorTop(false);
    self.addRequiredTraitBtn:setAnchorBottom(true);
    self.addRequiredTraitBtn:setEnable(false);
    --	self.addRequiredTraitBtn.borderColor = { r = 1, g = 1, b = 1, a = 0.1 };
    self.mainPanel:addChild(self.addRequiredTraitBtn);

    -- Add required negative trait
    self.addRequiredBadTraitBtn = ISButton:new(x, (self.listboxBadTrait:getY() + self.listboxBadTrait:getHeight()) + self.traitButtonPad, 50, self.traitButtonHgt, "Toggle Require", self, self.OnButtonRequireBadTrait);
    self.addRequiredBadTraitBtn.internal = "REQUIREBADTRAIT";
    self.addRequiredBadTraitBtn:initialise();
    self.addRequiredBadTraitBtn:instantiate();
    self.addRequiredBadTraitBtn:setAnchorLeft(true);
    self.addRequiredBadTraitBtn:setAnchorRight(false);
    self.addRequiredBadTraitBtn:setAnchorTop(false);
    self.addRequiredBadTraitBtn:setAnchorBottom(true);
    self.addRequiredBadTraitBtn:setEnable(false);
    --	self.addRequiredTraitBtn.borderColor = { r = 1, g = 1, b = 1, a = 0.1 };
    self.mainPanel:addChild(self.addRequiredBadTraitBtn);

    local x = self.addTraitBtn:getX() - self.addRequiredTraitBtn:getWidth() - 10;
    self.addRequiredBadTraitBtn:setX(x);
    self.addRequiredTraitBtn:setX(x);

    -- Add banned positive trait
    local x = self.addRequiredTraitBtn:getX() - 100;
	self.addBannedTraitBtn = ISButton:new(x, self.addRequiredTraitBtn:getY(), 50, self.traitButtonHgt, "Toggle Ban", self, self.OnButtonBanTrait);
    self.addBannedTraitBtn.internal = "BANTRAIT";
	self.addBannedTraitBtn:initialise();
	self.addBannedTraitBtn:instantiate();
	self.addBannedTraitBtn:setAnchorLeft(false);
	self.addBannedTraitBtn:setAnchorRight(true);
	self.addBannedTraitBtn:setAnchorTop(false);
	self.addBannedTraitBtn:setAnchorBottom(true);
    self.addBannedTraitBtn:setEnable(false);
	-- self.addBannedTraitBtn.borderColor = { r = 1, g = 1, b = 1, a = 0.1 };
	self.mainPanel:addChild(self.addBannedTraitBtn);

    -- Add banned negative trait
	self.addBannedBadTraitBtn = ISButton:new(x, self.addRequiredBadTraitBtn:getY(), 50, self.traitButtonHgt, "Toggle Ban", self, self.OnButtonBanBadTrait);
    self.addBannedBadTraitBtn.internal = "BANBADTRAIT";
	self.addBannedBadTraitBtn:initialise();
	self.addBannedBadTraitBtn:instantiate();
	self.addBannedBadTraitBtn:setAnchorLeft(false);
	self.addBannedBadTraitBtn:setAnchorRight(true);
	self.addBannedBadTraitBtn:setAnchorTop(false);
	self.addBannedBadTraitBtn:setAnchorBottom(true);
    self.addBannedBadTraitBtn:setEnable(false);
	-- self.addBannedBadTraitBtn.borderColor = { r = 1, g = 1, b = 1, a = 0.1 };
	self.mainPanel:addChild(self.addBannedBadTraitBtn);

    local x = self.addRequiredBadTraitBtn:getX() - self.addBannedTraitBtn:getWidth() - 7;
    self.addBannedBadTraitBtn:setX(x);
    self.addBannedTraitBtn:setX(x);
end

function CharacterCreationProfession:PrepareRandomizerSettings()
    -- Load settings from CDCharRandomizer
    local compare_trait_function = function(a, b)
        return a.item:getType() == b;
    end

	if CDCharRandomizer.requiredProfession_str ~= nil then
        local it = self.listboxProf.items;
        local p = CDCharRandomizer.requiredProfession_str;
		local i = CDTools:TableContains(it, p, compare_trait_function);
		if i ~= -1 then
			self.listboxProf.selected = i;
			self:onSelectProf(ProfessionFactory.getProfessions():get(i));
		else
			print("CDCharRandomizer: Could not find profession with name " .. CDCharRandomizer.requiredProfession_str);
		end
	end

    -- for trait_name, _ in pairs(CDCharRandomizer.requiredTraits_hs) do
    --     local i = CDTools:TableContains(self.listboxTrait.items, trait_name, compare_trait_function);
    --     if i ~= -1 then
    --         self.listboxTrait.selected = i;
    --         self:addTrait(self.listboxTrait, self.listboxRequiredTraits);
    --     else
    --         local i = CDTools:TableContains(self.listboxBadTrait.items, trait_name, compare_trait_function);
    --         if i ~= -1 then
    --             self.listboxBadTrait.selected = i;
    --             self:addTrait(self.listboxBadTrait, self.listboxRequiredTraits);
    --         else
    --             print("CDCharRandomizer: Could not find trait with name " .. trait_name);
    --         end
    --     end
    -- end

    -- for trait_name, _ in pairs(CDCharRandomizer.bannedTraits_hs) do
    --     local i = CDTools:TableContains(self.listboxTrait.items, trait_name, compare_trait_function);
    --     if i ~= -1 then
    --         self.listboxTrait.selected = i;
    --         self:addTrait(self.listboxTrait, self.listboxBannedTraits);
    --     else
    --         local i = CDTools:TableContains(self.listboxBadTrait.items, trait_name, compare_trait_function);
    --         if i ~= -1 then
    --             self.listboxBadTrait.selected = i;
    --             self:addTrait(self.listboxBadTrait, self.listboxBannedTraits);
    --         else
    --             print("CDCharRandomizer: Could not find trait with name " .. trait_name);
    --         end
    --     end
    -- end
end

function CharacterCreationProfession:OnButtonBanTrait(button, x, y)
    if self.listboxTrait.selected <= 0 then return end;
    local item = self.listboxTrait.items[self.listboxTrait.selected].item:getType();

    if CDCharRandomizer.requiredTraits_hs[item] == true then
        CDCharacterRandomizer.requiredTraits_hs[item] = nil;
    end

    if CDCharRandomizer.bannedTraits_hs[item] == true then
        CDCharRandomizer.bannedTraits_hs[item] = nil;
    else
        CDCharRandomizer.bannedTraits_hs[item] = true;
    end
end

function CharacterCreationProfession:OnButtonBanBadTrait(button, x, y)
    if self.listboxBadTrait.selected <= 0 then return end;
    local item = self.listboxBadTrait.items[self.listboxBadTrait.selected].item:getType();

    if CDCharRandomizer.requiredTraits_hs[item] == true then
        CDCharacterRandomizer.requiredTraits_hs[item] = nil;
    end

    if CDCharRandomizer.bannedTraits_hs[item] == true then
        CDCharRandomizer.bannedTraits_hs[item] = nil;
    else
        CDCharRandomizer.bannedTraits_hs[item] = true;
    end
end

function CharacterCreationProfession:OnButtonRequireTrait(button, x, y)
    if self.listboxTrait.selected <= 0 then return end;
    local item = self.listboxTrait.items[self.listboxTrait.selected].item:getType();

    if CDCharRandomizer.bannedTraits_hs[item] == true then
        CDCharacterRandomizer.bannedTraits_hs[item] = nil;
    end

    if CDCharRandomizer.requiredTraits_hs[item] == true then
        CDCharRandomizer.requiredTraits_hs[item] = nil;
    else
        CDCharRandomizer.requiredTraits_hs[item] = true;
    end
end

function CharacterCreationProfession:OnButtonRequireBadTrait(button, x, y)
    if self.listboxBadTrait.selected <= 0 then return end;
    local item = self.listboxBadTrait.items[self.listboxBadTrait.selected].item:getType();

    if CDCharRandomizer.bannedTraits_hs[item] == true then
        CDCharacterRandomizer.bannedTraits_hs[item] = nil;
    end

    if CDCharRandomizer.requiredTraits_hs[item] == true then
        CDCharRandomizer.requiredTraits_hs[item] = nil;
    else
        CDCharRandomizer.requiredTraits_hs[item] = true;
    end
end

local select_bad_base = CharacterCreationProfession.onSelectBadTrait;
function CharacterCreationProfession:onSelectBadTrait(item)
    select_bad_base(self, item);
    self.addRequiredBadTraitBtn:setEnable(true);
    self.addBannedBadTraitBtn:setEnable(true);
end

local select_base = CharacterCreationProfession.onSelectTrait;
function CharacterCreationProfession:onSelectTrait(item)
    select_base(self, item);
    self.addRequiredTraitBtn:setEnable(true);
    self.addBannedTraitBtn:setEnable(true);
end