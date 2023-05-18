require "OptionScreens/CharacterCreationProfession"
require "CDTools"
require "CDCharRandomizer"

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
    
    -- Not sure if there's a random range function in zomboid 
    local core_range = CDCharRandomizer.coreMax_i - CDCharRandomizer.coreMin_i;
    local core_num = ZombRand(core_range + 1) + CDCharRandomizer.coreMin_i;

    -- Get core traits
    local core_current = 0
    for index, trait in pairs(trait_table_ar) do
        local cost = trait.item:getCost();
        if math.abs(cost) > CDCharRandomizer.lowValueCutoff_i then
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