require "OptionScreens/CharacterCreationProfession"
require "CDTools"

-- Required traits
-- Required category (like combat traits)
-- function CharacterCreationProfession:randomizeTraits() -- {{{
--     self:resetBuild();

--     local size = #self.listboxProf.items;
--     local prof = ZombRand(size)+1;
--     self.listboxProf.selected = prof;
--     self:onSelectProf(self.listboxProf.items[self.listboxProf.selected].item);

--     local numTraits = ZombRand(5);
--     for i=0,numTraits do
--         self.listboxTrait.selected = ZombRand(#self.listboxTrait.items)+1;
--         self:onOptionMouseDown(self.addTraitBtn);
--     end

--     local numBadTraits = ZombRand(5);
--     for i=0,numBadTraits do
--         self.listboxBadTrait.selected = ZombRand(#self.listboxBadTrait.items)+1;
--         self:onOptionMouseDown(self.addBadTraitBtn);
--     end

--     local rescue = 1000;
--     while rescue > 0 do
--         rescue = rescue - 1;
--         if self:PointToSpend() >= 0 and self:PointToSpend() <= 3 then
--             rescue = 0;
--         else
--             if self:PointToSpend() < 0 then
--                 -- Points are negative, try to increase
--                 if ZombRand(2) == 0 then
--                     -- remove a good trait
--                     local rescue2 = 5;
--                     while rescue2 > 0 do
--                         local i = ZombRand(#self.listboxTraitSelected.items)+1;
--                         if self.listboxTraitSelected.items[i].item:getCost() > 0 and math.abs(self.listboxTraitSelected.items[i].item:getCost()) <= math.abs(self:PointToSpend()) then
--                             self.listboxTraitSelected.selected = i;
--                             self:onOptionMouseDown(self.removeTraitBtn);
--                         end
--                         rescue2 = rescue2 - 1;
--                     end
--                 else
--                     -- add a bad trait
--                     self.listboxBadTrait.selected = ZombRand(#self.listboxBadTrait.items)+1;
--                     self:onOptionMouseDown(self.addBadTraitBtn);
--                 end
--             else
--                 -- Points are too positive, try to decrease
--                 if ZombRand(2) == 0 then
--                     -- remove a bad trait
--                     local rescue2 = 5;
--                     while rescue2 > 0 do
--                         local i = ZombRand(#self.listboxTraitSelected.items)+1;
--                         if self.listboxTraitSelected.items[i].item:getCost() < 0 and math.abs(self.listboxTraitSelected.items[i].item:getCost()) <= math.abs(self:PointToSpend()) then
--                             self.listboxTraitSelected.selected = i;
--                             self:onOptionMouseDown(self.removeTraitBtn);
--                         end
--                         rescue2 = rescue2 - 1;
--                     end
--                 else
--                     -- add a good trait
--                     self.listboxTrait.selected = ZombRand(#self.listboxTrait.items)+1;
--                     self:onOptionMouseDown(self.addTraitBtn);
--                 end
--             end
--         end
--     end
-- end

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

    --- Shuffle table. This will be our source of randomness.
    --- We will search through the table, from the first to the last element,
    ---   till a valid trait matches. Then we remove that item from table and use it.
    CDTools.FisherYatesShuffle(trait_table_ar);
    
    local low_value_cutoff = 4;
    -- Not sure if there's a random range function in zomboid 
    local core_min = 2;
    local core_max = 5;
    local core_num = ZombRand(core_max - core_min) + core_min;

    -- Get core traits
    local core_current = 0
    for index, trait in pairs(trait_table_ar) do
        local cost = trait.item:getCost();
        if math.abs(cost) > low_value_cutoff then
            self:CDAddTrait(trait);
            core_current = core_current + 1;
        end

        if core_current >= core_num then
            break
        end
    end

    if core_current < core_num then
        CDTools.CDDebug("Could not get core traits.");
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
