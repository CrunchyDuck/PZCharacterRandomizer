require "OptionScreens/CharacterCreationProfession"
require "CDTools"
require "CDCharRandomizer"
require "CDCharRandomizerSettings"

-- TODO: Randomize and move to next page.

local col_b = {a = 0.1, r = 1, g = 0, b = 0};
local col_r = {a = 0.1, r = 0, g = 1, b = 0};

-- Apologies for the indentation. This allows me to fold the different regions in my text editor.
-- [ Overwrites
    local ccp_create_base = CharacterCreationProfession.create;
    function CharacterCreationProfession:create()
        ccp_create_base(self);
        self:PrepareRandomizerSettings();

        local buttonHgt = getTextManager():getFontHeight(UIFont.Small) + 3 * 2;

        -- Add required positive trait
        local x = self.addTraitBtn:getX() - 100;
        self.requireTraitBtn = ISButton:new(x, (self.listboxTrait:getY() + self.listboxTrait:getHeight()) + self.traitButtonPad, 50, self.traitButtonHgt, "Toggle Require", self, self.OnButtonRequireTrait);
        self.requireTraitBtn.internal = "REQUIRETRAIT";
        self.requireTraitBtn:initialise();
        self.requireTraitBtn:instantiate();
        self.requireTraitBtn:setAnchorLeft(true);
        self.requireTraitBtn:setAnchorRight(false);
        self.requireTraitBtn:setAnchorTop(false);
        self.requireTraitBtn:setAnchorBottom(true);
        self.requireTraitBtn:setEnable(false);
        self.mainPanel:addChild(self.requireTraitBtn);

        -- Add required negative trait
        self.requireBadTraitBtn = ISButton:new(x, (self.listboxBadTrait:getY() + self.listboxBadTrait:getHeight()) + self.traitButtonPad, 50, self.traitButtonHgt, "Toggle Require", self, self.OnButtonRequireBadTrait);
        self.requireBadTraitBtn.internal = "REQUIREBADTRAIT";
        self.requireBadTraitBtn:initialise();
        self.requireBadTraitBtn:instantiate();
        self.requireBadTraitBtn:setAnchorLeft(true);
        self.requireBadTraitBtn:setAnchorRight(false);
        self.requireBadTraitBtn:setAnchorTop(false);
        self.requireBadTraitBtn:setAnchorBottom(true);
        self.requireBadTraitBtn:setEnable(false);
        self.mainPanel:addChild(self.requireBadTraitBtn);

        local require_butt_width = self.requireBadTraitBtn:getWidth();
        local x = self.addTraitBtn:getX() - require_butt_width - 10;
        self.requireBadTraitBtn:setX(x);
        self.requireTraitBtn:setX(x);

        -- Add banned positive trait
        local x = self.requireTraitBtn:getX() - 100;
        self.banTraitBtn = ISButton:new(x, self.requireTraitBtn:getY(), 50, self.traitButtonHgt, "Toggle Ban", self, self.OnButtonBanTrait);
        self.banTraitBtn.internal = "BANTRAIT";
        self.banTraitBtn:initialise();
        self.banTraitBtn:instantiate();
        self.banTraitBtn:setAnchorLeft(false);
        self.banTraitBtn:setAnchorRight(true);
        self.banTraitBtn:setAnchorTop(false);
        self.banTraitBtn:setAnchorBottom(true);
        self.banTraitBtn:setEnable(false);
        self.mainPanel:addChild(self.banTraitBtn);

        -- Add banned negative trait
        self.banBadTraitBtn = ISButton:new(x, self.requireBadTraitBtn:getY(), 50, self.traitButtonHgt, "Toggle Ban", self, self.OnButtonBanBadTrait);
        self.banBadTraitBtn.internal = "BANBADTRAIT";
        self.banBadTraitBtn:initialise();
        self.banBadTraitBtn:instantiate();
        self.banBadTraitBtn:setAnchorLeft(false);
        self.banBadTraitBtn:setAnchorRight(true);
        self.banBadTraitBtn:setAnchorTop(false);
        self.banBadTraitBtn:setAnchorBottom(true);
        self.banBadTraitBtn:setEnable(false);
        self.mainPanel:addChild(self.banBadTraitBtn);

        local ban_butt_width = self.banTraitBtn:getWidth();
        local x = self.requireBadTraitBtn:getX() - ban_butt_width - 7;
        self.banBadTraitBtn:setX(x);
        self.banTraitBtn:setX(x);

        local x = self.listboxProf:getX() + self.listboxProf:getWidth() - require_butt_width;
        local y = self.listboxProf:getY() + self.listboxProf:getHeight() + self.traitButtonPad;
        self.requireProfBtn = ISButton:new(x, y, 50, self.traitButtonHgt, "Toggle Require", self, self.OnButtonRequireProfession);
        self.requireProfBtn.internal = "REQUIREPROF";
        self.requireProfBtn:initialise();
        self.requireProfBtn:instantiate();
        self.requireProfBtn:setAnchorLeft(true);
        self.requireProfBtn:setAnchorRight(false);
        self.requireProfBtn:setAnchorTop(false);
        self.requireProfBtn:setAnchorBottom(true);
        self.requireProfBtn:setEnable(false);
        self.mainPanel:addChild(self.requireProfBtn);
        
        local x = self.requireProfBtn:getX() - ban_butt_width - 7;
        self.banProfBtn = ISButton:new(x, y, 50, self.traitButtonHgt, "Toggle Ban", self, self.OnButtonBanProfession);
        self.banProfBtn.internal = "BANPROF";
        self.banProfBtn:initialise();
        self.banProfBtn:instantiate();
        self.banProfBtn:setAnchorLeft(true);
        self.banProfBtn:setAnchorRight(false);
        self.banProfBtn:setAnchorTop(false);
        self.banProfBtn:setAnchorBottom(true);
        self.banProfBtn:setEnable(false);
        self.mainPanel:addChild(self.banProfBtn);

        local textWid = getTextManager():MeasureStringX(UIFont.Small, "BLIND RANDOMIZE");
        local blindButtonWid = math.max(100, textWid + 8 * 2) + 20
        local x = self.resetButton:getX() - 10 - blindButtonWid;
        self.blindButton = ISButton:new(x, self.resetButton:getY(), blindButtonWid, buttonHgt, "BLIND RANDOMIZE", self, self.OnButtonBlindRandomize);
        self.blindButton.internal = "RESETTRAITS";
        self.blindButton:initialise();
        self.blindButton:instantiate();
        self.blindButton:setAnchorLeft(false);
        self.blindButton:setAnchorRight(true);
        self.blindButton:setAnchorTop(false);
        self.blindButton:setAnchorBottom(true);
        self.blindButton.borderColor = { r = 1, g = 1, b = 1, a = 0.1 };
        self.mainPanel:addChild(self.blindButton);
    end

    local draw_trait_map_base = CharacterCreationProfession.drawTraitMap;
    function CharacterCreationProfession:drawTraitMap(y, item, alt)
        local trait_name = item.item:getType();
        if CDCharRandomizer.requiredTraits_hs[trait_name] == true then
            self:drawRect(0, y, self:getWidth(), self.itemheight - 1, col_r.a, col_r.r, col_r.g, col_r.b);
        elseif CDCharRandomizer.bannedTraits_hs[trait_name] == true then
            self:drawRect(0, y, self:getWidth(), self.itemheight - 1, col_b.a, col_b.r, col_b.g, col_b.b);
        end

        return draw_trait_map_base(self, y, item, alt);
    end

    local draw_prof_map_base = CharacterCreationProfession.drawProfessionMap;
    function CharacterCreationProfession:drawProfessionMap(y, item, alt)
        local prof_name = item.item:getType();
        if CDCharRandomizer.requiredProfession_str == prof_name then
            self:drawRect(0, y, self:getWidth(), self.itemheight - 1, col_r.a, col_r.r, col_r.g, col_r.b);
        elseif CDCharRandomizer.bannedProfessions_hs[prof_name] == true then
            self:drawRect(0, y, self:getWidth(), self.itemheight - 1, col_b.a, col_b.r, col_b.g, col_b.b);
        end

        return draw_prof_map_base(self, y, item, alt);
    end

    local visible_base = CharacterCreationProfession.setVisible;
    function CharacterCreationProfession:setVisible(visible, joypadData)
        visible_base(self, visible, joypadData);
        if visible ~= true then
            CDCharRandomizer.SaveRandomizerSettings();
        end
    end

    local select_bad_base = CharacterCreationProfession.onSelectBadTrait;
    function CharacterCreationProfession:onSelectBadTrait(item)
        select_bad_base(self, item);
        self.requireBadTraitBtn:setEnable(true);
        self.banBadTraitBtn:setEnable(true);
    end

    local select_base = CharacterCreationProfession.onSelectTrait;
    function CharacterCreationProfession:onSelectTrait(item)
        select_base(self, item);
        self.requireTraitBtn:setEnable(true);
        self.banTraitBtn:setEnable(true);
    end

    local prof_select_base = CharacterCreationProfession.onSelectProf;
    function CharacterCreationProfession:onSelectProf(item)
        prof_select_base(self, item);
        -- Why in the fresh hell is this called before create is called?
        if self.requireProfBtn ~= nil then
            self.requireProfBtn:setEnable(true);
            self.banProfBtn:setEnable(true);
        end
    end

    local add_base = CharacterCreationProfession.addTrait;
    function CharacterCreationProfession:addTrait(button, x, y)
        add_base(self, button, x, y);
        self.requireTraitBtn:setEnable(false);
        self.banTraitBtn:setEnable(false);
        self.requireBadTraitBtn:setEnable(false);
        self.banBadTraitBtn:setEnable(false);
    end
    
    local remove_base = CharacterCreationProfession.removeTrait;
    function CharacterCreationProfession:removeTrait()
        remove_base(self);
        self.requireTraitBtn:setEnable(false);
        self.banTraitBtn:setEnable(false);
        self.requireBadTraitBtn:setEnable(false);
        self.banBadTraitBtn:setEnable(false);
    end

    function CharacterCreationProfession:randomizeTraits()
        self:resetBuild();

        if CDCharRandomizer.requiredProfession_str == "" then
            local prof_list = CDTools:ShallowCopy(self.listboxProf.items);
            CDTools:FisherYatesShuffle(prof_list);

            local found_prof = false;
            for _, prof in pairs(prof_list) do
                if CDCharRandomizer.bannedProfessions_hs[prof.item:getType()] ~= true then
                    found_prof = true;
                    self.listboxProf.selected = prof.index;
                    self:onSelectProf(self.listboxProf.items[self.listboxProf.selected].item);
                end
            end
            if found_prof ~= true then
                print("CDCharRandomizer: Could not find a valid profession!");
            end
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
-- ]

-- [ Personal functions 
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
                return
            end
            self.listboxBadTrait.selected = i;
            self:onOptionMouseDown(self.addBadTraitBtn);
        -- Add positive
        elseif trait.item:getCost() > 0 then
            local i = CDTools:TableContains(self.listboxTrait.items, trait);
            if i == -1 then
                return
            end
            self.listboxTrait.selected = i;
            self:onOptionMouseDown(self.addTraitBtn);
        else
            print("CDCharRandomizer: Tried to add a trait with value of 0. I don't know how to!");
        end
    end
-- ]

-- [ Button events
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

    function CharacterCreationProfession:OnButtonBanProfession(button, x, y)
        if self.listboxProf.selected <= 0 then return end;
        local item = self.listboxProf.items[self.listboxProf.selected].item:getType();
        

        if CDCharRandomizer.requiredProfession_str == item then
            CDCharRandomizer.requiredProfession_str = "";
        end

        if CDCharRandomizer.bannedProfessions_hs[item] == true then
            CDCharRandomizer.bannedProfessions_hs[item] = nil;
        else
            CDCharRandomizer.bannedProfessions_hs[item] = true;
        end
    end

    function CharacterCreationProfession:OnButtonRequireProfession(button, x, y)
        if self.listboxProf.selected <= 0 then return end;
        local item = self.listboxProf.items[self.listboxProf.selected].item:getType();
        

        if CDCharRandomizer.bannedProfessions_hs[item] == true then
            CDCharRandomizer.bannedProfessions_hs[item] = nil;
        end

        if CDCharRandomizer.requiredProfession_str == item then
            CDCharRandomizer.requiredProfession_str = "";
        else
            CDCharRandomizer.requiredProfession_str = item;
        end
    end

    function CharacterCreationProfession:OnButtonBlindRandomize(button, x, y)
        self:randomizeTraits();
        -- Next button function, taken from onOptionMouseDown

        if self.infoRichText then
			self.infoRichText:removeFromUIManager()
			self.infoRichText = nil
		end
		MainScreen.instance.charCreationProfession:setVisible(false);
		MainScreen.instance.charCreationMain:setVisible(true, joypadData);
    end
-- ]