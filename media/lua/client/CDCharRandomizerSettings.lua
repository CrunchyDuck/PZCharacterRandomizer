--- I cannot express the blood that was shed to get this window functioning.
---
--- You would expect there to just be a "spawn window" function,
---   maybe something nice where you plug in some variables and get something back
--- oh dear, if only.
---
--- 600 lines of code are, to my understanding, the minimum requirement
---   for a blank window.
--- That, and also manually jacking into MainScreen with MainScreen:addChild,
---   and also handling all the instantiation of the window.
---
--- It took about half a day of work to get a blank window running,
---   trying to trace the non-euclidean structure of this codebase
---   is a test of great pathfinding.
---
--- It's truly impressive, the dedication shown by The Indie Stone
---   to make codebase mirror the rotting dead carcasses their game is focused on.

-- TODO: Add "null" profession.
require"ISUI/ISPanel"
require"ISUI/ISButton"
require"ISUI/ISInventoryPane"
require"ISUI/ISResizeWidget"
require"ISUI/ISRichTextPanel"
require"ISUI/ISMouseDrag"

require"defines"

CDCharRandomizerSettings = ISPanelJoypad:derive("CDCharRandomizerSettings");
local CDCharRandomizerSettingsListBox = ISScrollingListBox:derive("CDCharRandomizerSettingsListBox")
local CDCharRandomizerSettingsPresetPanel = ISPanelJoypad:derive("CDCharRandomizerSettingsPresetPanel")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_TITLE = getTextManager():getFontHeight(UIFont.Title)

-- -- -- -- --
-- -- -- -- --
-- -- -- -- --

function CDCharRandomizerSettingsListBox:render()
    ISScrollingListBox.render(self)
    if self.joyfocus then
        self:drawRectBorder(0, -self:getYScroll(), self:getWidth(), self:getHeight(), 0.4, 0.2, 1.0, 1.0);
        self:drawRectBorder(1, 1-self:getYScroll(), self:getWidth()-2, self:getHeight()-2, 0.4, 0.2, 1.0, 1.0);
    end
end

function CDCharRandomizerSettingsListBox:onJoypadDown(button, joypadData)
    if button == Joypad.BButton then
        joypadData.focus = self.parent.parent
        updateJoypadFocus(joypadData)
    else
        ISScrollingListBox.onJoypadDown(self, button, joypadData)
    end
end

function CDCharRandomizerSettingsListBox:onJoypadDirLeft(joypadData)
    joypadData.focus = self.joyfocusLeft
    updateJoypadFocus(joypadData)
end

function CDCharRandomizerSettingsListBox:onJoypadDirRight(joypadData)
    joypadData.focus = self.joyfocusRight
    updateJoypadFocus(joypadData)
end

function CDCharRandomizerSettingsListBox:onJoypadBeforeDeactivate(joypadData)
	self.parent.parent:onJoypadBeforeDeactivate(joypadData)
end

-- -- -- -- --
-- -- -- -- --
-- -- -- -- --

function CDCharRandomizerSettingsPresetPanel:render()
    ISPanelJoypad.render(self)
    if self.joyfocus then
        self:drawRectBorder(0 - 4, 0 - 4, self:getWidth() + 4 + 4, self:getHeight() + 4 + 4, 0.4, 0.2, 1.0, 1.0)
        self:drawRectBorder(0 - 3, 0 - 3, self:getWidth() + 3 + 3, self:getHeight() + 3 + 3, 0.4, 0.2, 1.0, 1.0)
    end
end

function CDCharRandomizerSettingsPresetPanel:onGainJoypadFocus(joypadData)
    ISPanelJoypad.onGainJoypadFocus(self, joypadData)
    if self.joypadButtons[self.joypadIndex] then
        self.joypadButtons[self.joypadIndex]:setJoypadFocused(true, joypadData)
    end
end

function CDCharRandomizerSettingsPresetPanel:onLoseJoypadFocus(joypadData)
    ISPanelJoypad.onLoseJoypadFocus(self, joypadData)
    self:clearJoypadFocus()
end

function CDCharRandomizerSettingsPresetPanel:onJoypadDown(button, joypadData)
    if button == Joypad.BButton and not self:isFocusOnControl() then
        joypadData.focus = self.parent.parent
        updateJoypadFocus(joypadData)
    else
        ISPanelJoypad.onJoypadDown(self, button, joypadData)
    end
end

function CDCharRandomizerSettingsPresetPanel:onJoypadDirUp(joypadData)
    if self:isFocusOnControl() then
        ISPanelJoypad.onJoypadDirUp(self, joypadData)
    else
        joypadData.focus = self.parent.parent.listboxProf
        updateJoypadFocus(joypadData)
    end
end

function CDCharRandomizerSettingsPresetPanel:onJoypadDirLeft(joypadData)
    if self.joypadIndex == 1 then
        joypadData.focus = self.parent.parent
        updateJoypadFocus(joypadData)
        return
    end
    ISPanelJoypad.onJoypadDirLeft(self, button, joypadData)
end

function CDCharRandomizerSettingsPresetPanel:onJoypadDirRight(joypadData)
    if self.joypadIndex == 3 then
        joypadData.focus = self.parent.parent
        updateJoypadFocus(joypadData)
        return
    end
    ISPanelJoypad.onJoypadDirRight(self, button, joypadData)
end

-- -- -- -- --
-- -- -- -- --
-- -- -- -- --

function CDCharRandomizerSettings:initialise()
    ISPanelJoypad.initialise(self);
end

--************************************************************************--
--** ISPanel:instantiate
--**
--************************************************************************--
function CDCharRandomizerSettings:instantiate()
	self.javaObject = UIElement.new(self);
	self.javaObject:setX(self.x);
	self.javaObject:setY(self.y);
	self.javaObject:setHeight(self.height);
	self.javaObject:setWidth(self.width);
	self.javaObject:setAnchorLeft(self.anchorLeft);
	self.javaObject:setAnchorRight(self.anchorRight);
	self.javaObject:setAnchorTop(self.anchorTop);
	self.javaObject:setAnchorBottom(self.anchorBottom);
	self:createChildren();
end

function CDCharRandomizerSettings:create()
	local buttonHgt = FONT_HGT_SMALL + 3 * 2
	
	self.maletex = getTexture("media/ui/maleicon.png");
	self.femaletex = getTexture("media/ui/femaleicon.png");

	self.freeTraits = {};

	self.pointToSpend = 0;

	local w = self.width * 0.75;
	local h = self.height * 0.8;
	if (w < 768) then
		w = 768;
	end
	local screenWid = self.width;
	local screenHgt = self.height;
	self.mainPanel = ISPanel:new((screenWid - w) / 2, (screenHgt - h) / 2, w, h);
	self.mainPanel.backgroundColor = { r = 0, g = 0, b = 0, a = 0.8 };
	self.mainPanel.borderColor = { r = 1, g = 1, b = 1, a = 0.5 };

	self.tablePadX = 20
	self.tableWidth = (self.mainPanel:getWidth() - 16 * 2 - self.tablePadX * 2) / 3
	self.topOfLists = 48
	self.tooltipHgt = FONT_HGT_SMALL
	if self.width <= 1980 then
		self.tooltipHgt = FONT_HGT_SMALL * 2
	end
	self.belowLists = 5 + buttonHgt + 4 + math.max(FONT_HGT_MEDIUM, self.tooltipHgt) + 5
	self.bottomOfLists = self.mainPanel:getHeight() - self.belowLists
	self.smallFontHgt = getTextManager():getFontFromEnum(UIFont.Small):getLineHeight() + 1
	self.mediumFontHgt = getTextManager():getFontFromEnum(UIFont.Medium):getLineHeight()
	self.traitButtonHgt = buttonHgt
	self.traitButtonPad = 6

	local traitButtonGap = self.traitButtonPad * 2 + self.traitButtonHgt
	local halfListHeight = (self.bottomOfLists - self.topOfLists - self.smallFontHgt - traitButtonGap) / 2

	self.mainPanel:initialise();
	self.mainPanel:setAnchorRight(true);
	self.mainPanel:setAnchorLeft(true);
	self.mainPanel:setAnchorBottom(true);
	self.mainPanel:setAnchorTop(true);
	self:addChild(self.mainPanel);

	self.backButton = ISButton:new(16, self.mainPanel.height - 5 - buttonHgt, 100, buttonHgt, getText("UI_btn_back"), self, self.OnButtonBack);
	self.backButton.internal = "BACK";
	self.backButton:initialise();
	self.backButton:instantiate();
	self.backButton:setAnchorLeft(true);
	self.backButton:setAnchorTop(false);
	self.backButton:setAnchorBottom(true);
	self.backButton.borderColor = { r = 1, g = 1, b = 1, a = 0.1 };
	self.mainPanel:addChild(self.backButton);

	-- required trait list
	self.listboxRequiredTraits = CDCharRandomizerSettingsListBox:new(((w / 3) * 2), self.topOfLists + self.smallFontHgt, self.tableWidth, halfListHeight);
	self.listboxRequiredTraits:initialise();
	self.listboxRequiredTraits:instantiate();
	self.listboxRequiredTraits:setAnchorLeft(true);
	self.listboxRequiredTraits:setAnchorRight(false);
	self.listboxRequiredTraits:setAnchorTop(true);
	self.listboxRequiredTraits:setAnchorBottom(true);
	self.listboxRequiredTraits.itemheight = 30;
	self.listboxRequiredTraits.selected = -1;
	self.listboxRequiredTraits.doDrawItem = CDCharRandomizerSettings.drawTraitMap;
	self.listboxRequiredTraits:setOnMouseDownFunction(self, CDCharRandomizerSettings.onSelectRequiredTrait);
	self.listboxRequiredTraits:setOnMouseDoubleClick(self, CDCharRandomizerSettings.onDblClickRequiredTrait);
    self.listboxRequiredTraits.resetSelectionOnChangeFocus = true;
    self.listboxRequiredTraits.drawBorder = true
    self.listboxRequiredTraits.fontHgt = self.fontHgt
	self.mainPanel:addChild(self.listboxRequiredTraits);

	-- banned trait list
	self.listboxBannedTraits = CDCharRandomizerSettingsListBox:new(((w / 3) * 2), self.listboxRequiredTraits:getY() + self.listboxRequiredTraits:getHeight() + traitButtonGap, self.tableWidth, halfListHeight);
	self.listboxBannedTraits:initialise();
	self.listboxBannedTraits:instantiate();
	self.listboxBannedTraits:setAnchorLeft(true);
	self.listboxBannedTraits:setAnchorRight(false);
	self.listboxBannedTraits:setAnchorTop(false);
	self.listboxBannedTraits:setAnchorBottom(true);
	self.listboxBannedTraits.itemheight = 30;
	self.listboxBannedTraits.selected = -1;
	self.listboxBannedTraits.doDrawItem = CDCharRandomizerSettings.drawTraitMap;  -- TODO: Check this.
	self.listboxBannedTraits:setOnMouseDownFunction(self, CDCharRandomizerSettings.onSelectBannedTrait);
	self.listboxBannedTraits:setOnMouseDoubleClick(self, CDCharRandomizerSettings.onDblClickBannedTrait);
    self.listboxBannedTraits.resetSelectionOnChangeFocus = true;
    self.listboxBannedTraits.drawBorder = true
    self.listboxBannedTraits.fontHgt = self.fontHgt
	self.mainPanel:addChild(self.listboxBannedTraits);

	-- the traits list choice
	self.listboxTrait = CDCharRandomizerSettingsListBox:new((w / 3), self.topOfLists + self.smallFontHgt, self.tableWidth, halfListHeight);
	self.listboxTrait:initialise();
	self.listboxTrait:instantiate();
	self.listboxTrait:setAnchorLeft(true);
	self.listboxTrait:setAnchorRight(false);
	self.listboxTrait:setAnchorTop(true);
	self.listboxTrait:setAnchorBottom(true);
	self.listboxTrait.itemheight = 30;
	self.listboxTrait.selected = -1;
	self:populateTraitList(self.listboxTrait);
	self.listboxTrait.doDrawItem = CDCharRandomizerSettings.drawTraitMap;
	self.listboxTrait:setOnMouseDownFunction(self, CDCharRandomizerSettings.onSelectTrait);
	self.listboxTrait:setOnMouseDoubleClick(self, CDCharRandomizerSettings.onDblClickTrait);
    self.listboxTrait.resetSelectionOnChangeFocus = true;
    self.listboxTrait.drawBorder = true
    self.listboxTrait.fontHgt = self.fontHgt
	self.mainPanel:addChild(self.listboxTrait);

    -- the bad traits list choice
    self.listboxBadTrait = CDCharRandomizerSettingsListBox:new((w / 3), self.listboxTrait:getY() + self.listboxTrait:getHeight() + traitButtonGap, self.tableWidth, halfListHeight);
    self.listboxBadTrait:initialise();
    self.listboxBadTrait:instantiate();
    self.listboxBadTrait:setAnchorLeft(true);
    self.listboxBadTrait:setAnchorRight(false);
    self.listboxBadTrait:setAnchorTop(false);
    self.listboxBadTrait:setAnchorBottom(true);
    self.listboxBadTrait.itemheight = 30;
    self.listboxBadTrait.selected = -1;
    self:populateBadTraitList(self.listboxBadTrait);
    self.listboxBadTrait.doDrawItem = CDCharRandomizerSettings.drawTraitMap;
    self.listboxBadTrait:setOnMouseDownFunction(self, CDCharRandomizerSettings.onSelectBadTrait);
    self.listboxBadTrait:setOnMouseDoubleClick(self, CDCharRandomizerSettings.onDblClickBadTrait);
    self.listboxBadTrait.resetSelectionOnChangeFocus = true;
    self.listboxBadTrait.drawBorder = true
    self.listboxBadTrait.fontHgt = self.fontHgt
    self.mainPanel:addChild(self.listboxBadTrait);

    -- Add required positive trait
    self.addRequiredTraitBtn = ISButton:new(self.listboxBadTrait:getX() + self.listboxBadTrait:getWidth() - 50, (self.listboxTrait:getY() + self.listboxTrait:getHeight()) + self.traitButtonPad, 50, self.traitButtonHgt, "Add Required", self, self.OnButtonAddRequiredTrait);
    self.addRequiredTraitBtn.internal = "ADDTRAIT";
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
    self.addRequiredBadTraitBtn = ISButton:new(self.listboxBadTrait:getX() + self.listboxBadTrait:getWidth() - 50, (self.listboxBadTrait:getY() + self.listboxBadTrait:getHeight()) + self.traitButtonPad, 50, self.traitButtonHgt, "Add Required", self, self.OnButtonAddRequiredBadTrait);
    self.addRequiredBadTraitBtn.internal = "ADDBADTRAIT";
    self.addRequiredBadTraitBtn:initialise();
    self.addRequiredBadTraitBtn:instantiate();
    self.addRequiredBadTraitBtn:setAnchorLeft(true);
    self.addRequiredBadTraitBtn:setAnchorRight(false);
    self.addRequiredBadTraitBtn:setAnchorTop(false);
    self.addRequiredBadTraitBtn:setAnchorBottom(true);
    self.addRequiredBadTraitBtn:setEnable(false);
    --	self.addRequiredTraitBtn.borderColor = { r = 1, g = 1, b = 1, a = 0.1 };
    self.mainPanel:addChild(self.addRequiredBadTraitBtn);

    -- Add banned positive trait
	self.addBannedTraitBtn = ISButton:new(self.addRequiredTraitBtn:getX() - 100, self.addRequiredTraitBtn:getY(), 50, self.traitButtonHgt, "Add Banned", self, self.OnButtonAddBannedTrait);
    self.addBannedTraitBtn.internal = "ADDBANNED";
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
	self.addBannedBadTraitBtn = ISButton:new(self.addRequiredBadTraitBtn:getX() - 100, self.addRequiredBadTraitBtn:getY(), 50, self.traitButtonHgt, "Add Banned", self, self.OnButtonAddBannedBadTrait);
    self.addBannedBadTraitBtn.internal = "ADDBADBANNED";
	self.addBannedBadTraitBtn:initialise();
	self.addBannedBadTraitBtn:instantiate();
	self.addBannedBadTraitBtn:setAnchorLeft(false);
	self.addBannedBadTraitBtn:setAnchorRight(true);
	self.addBannedBadTraitBtn:setAnchorTop(false);
	self.addBannedBadTraitBtn:setAnchorBottom(true);
    self.addBannedBadTraitBtn:setEnable(false);
	-- self.addBannedBadTraitBtn.borderColor = { r = 1, g = 1, b = 1, a = 0.1 };
	self.mainPanel:addChild(self.addBannedBadTraitBtn);

    -- Remove required trait
    self.removeRequiredTraitBtn = ISButton:new(self.listboxTrait:getX(), (self.listboxTrait:getY() + self.listboxTrait:getHeight()) + self.traitButtonPad, 50, self.traitButtonHgt, "Remove Required", self, self.OnButtonRemoveRequiredTrait);
    self.removeRequiredTraitBtn.internal = "REMOVEREQUIREDTRAIT";
    self.removeRequiredTraitBtn:initialise();
    self.removeRequiredTraitBtn:instantiate();
    self.removeRequiredTraitBtn:setAnchorLeft(true);
    self.removeRequiredTraitBtn:setAnchorRight(false);
    self.removeRequiredTraitBtn:setAnchorTop(false);
    self.removeRequiredTraitBtn:setAnchorBottom(true);
    self.removeRequiredTraitBtn:setEnable(false);
    self.mainPanel:addChild(self.removeRequiredTraitBtn);

    -- Remove banned trait
    local button_width = getTextManager():MeasureStringX(UIFont.Small, "Remove Banned");
    self.removeBannedTraitBtn = ISButton:new(self.listboxBannedTraits:getRight() - button_width, (self.listboxBannedTraits:getY() + self.listboxBannedTraits:getHeight()) + self.traitButtonPad, button_width, self.traitButtonHgt, "Remove Banned", self, self.OnButtonRemoveBannedTrait);
    self.removeBannedTraitBtn.internal = "REMOVEBANNEDTRAIT";
    self.removeBannedTraitBtn:initialise();
    self.removeBannedTraitBtn:instantiate();
    self.removeBannedTraitBtn:setAnchorLeft(true);
    self.removeBannedTraitBtn:setAnchorRight(false);
    self.removeBannedTraitBtn:setAnchorTop(false);
    self.removeBannedTraitBtn:setAnchorBottom(true);
    self.removeBannedTraitBtn:setEnable(false);
    self.mainPanel:addChild(self.removeBannedTraitBtn);

    -- the profession list choice
	self.listboxProf = CDCharRandomizerSettingsListBox:new(16, self.topOfLists, self.tableWidth, self.bottomOfLists - self.topOfLists);
	self.listboxProf:initialise();
	self.listboxProf:instantiate();
	self.listboxProf:setAnchorLeft(true);
	self.listboxProf:setAnchorRight(false);
	self.listboxProf:setAnchorTop(true);
	self.listboxProf:setAnchorBottom(true);
	self.listboxProf.itemheight = 70;
	self.listboxProf.selected = 1;
	self.listboxProf:setOnMouseDownFunction(self, CDCharRandomizerSettings.onSelectProf);
	self.listboxProf:setOnMouseDoubleClick(self, CDCharRandomizerSettings.onSelectProf);
	self:populateProfessionList(self.listboxProf);
	self.listboxProf.doDrawItem = CDCharRandomizerSettings.drawProfessionMap;
    self.listboxProf.drawBorder = true
    self.listboxProf.fontHgt = self.fontHgt
	self.mainPanel:addChild(self.listboxProf);

	self.tooltipRichText = ISRichTextPanel:new(16, self.listboxProf:getBottom() + 5, self.mainPanel.width - 16 - 200, self.tooltipHgt)
	self.tooltipRichText:setAnchorTop(false)
	self.tooltipRichText:setAnchorBottom(true)
	self.tooltipRichText:setAnchorRight(true)
	self.tooltipRichText:setMargins(0, 0, 0, 0)
	self.tooltipRichText.autosetheight = false
	self.tooltipRichText:setVisible(false) -- only visible using a controller
	self.mainPanel:addChild(self.tooltipRichText)

    self.listboxProf.joyfocusRight = self.listboxTrait
    self.listboxTrait.joyfocusLeft = self.listboxProf
    self.listboxTrait.joyfocusRight = self.listboxBadTrait
    self.listboxBadTrait.joyfocusLeft = self.listboxTrait
    self.listboxBadTrait.joyfocusRight = self.listboxRequiredTraits
    self.listboxRequiredTraits.joyfocusLeft = self.listboxBadTrait

	self:onSelectProf(ProfessionFactory.getProfessions():get(0));
end

function CDCharRandomizerSettings:new(x, y, width, height)
	-- using a virtual 100 height res for doing the UI, so it resizes properly on different rez's.

	local o = {}

	--o.data = {}
	o = ISPanelJoypad:new(x, y, width, height);
	setmetatable(o, self)
	self.__index = self
	o.x = 0;
	o.y = 0;
	o.backgroundColor = { r = 0, g = 0, b = 0, a = 0.0 };
	o.borderColor = { r = 1, g = 1, b = 1, a = 0.0 };
	o.itemheightoverride = {};
	o.anchorLeft = true;
	o.anchorRight = false;
	o.anchorTop = true;
	o.anchorBottom = false;
	o.profession = nil;
	o.defaultToppal = "Shirt_White";
	o.defaultBottomspal = "Trousers_White";
	o.defaultToppalColor = ColorInfo.new(1, 1, 1, 1);
	o.defaultBottomspalColor = ColorInfo.new(1, 1, 1, 1);
	o.defaultTop = "Shirt";
	o.defaultBottoms = "Trousers";
    o.whiteBar = getTexture("media/ui/whitebar.png");
	o.cost = 0;
	o.fontHgt = getTextManager():getFontFromEnum(UIFont.Small):getLineHeight()
	CDCharRandomizerSettings.instance = o;
	return o
end

function CharacterCreationMain.sortByCost(a, b)
    if a.item:getCost() == b.item:getCost() then
        return not string.sort(a.text, b.text)
    end
    return a.item:getCost() < b.item:getCost();
end

function CharacterCreationMain.sortByInvertCost(a, b)
    if a.item:getCost() == b.item:getCost() then
        return not string.sort(a.text, b.text)
    end
    return a.item:getCost() > b.item:getCost();
end

function CharacterCreationMain.sort(list)
    table.sort(list, CharacterCreationMain.sortByCost);
end

function CharacterCreationMain.invertSort(list)
    table.sort(list, CharacterCreationMain.sortByInvertCost);
end

function CDCharRandomizerSettings:setVisible(visible, joypadData)
	ISPanelJoypad.setVisible(self, visible, joypadData);
    if visible then
        self:PrepareRandomizerSettings();
    end
end

function CDCharRandomizerSettings:PrepareRandomizerSettings()
    -- Load settings from CDCharRandomizer
    local compare_trait_function = function(a, b)
        return a.item:getType() == b;
    end

    for trait_name, _ in pairs(CDCharRandomizer.requiredTraits_hs) do
        local i = CDTools.TableContains(self.listboxTrait.items, trait_name, compare_trait_function);
        if i ~= -1 then
            self.listboxTrait.selected = i;
            self:addTrait(self.listboxTrait, self.listboxRequiredTraits);
        else
            local i = CDTools.TableContains(self.listboxBadTrait.items, trait_name, compare_trait_function);
            if i ~= -1 then
                self.listboxBadTrait.selected = i;
                self:addTrait(self.listboxBadTrait, self.listboxRequiredTraits);
            else
                print("CDCharRandomizer: Could not find trait with name " .. trait_name);
            end
        end
    end

    for trait_name, _ in pairs(CDCharRandomizer.bannedTraits_hs) do
        local i = CDTools.TableContains(self.listboxTrait.items, trait_name, compare_trait_function);
        if i ~= -1 then
            self.listboxTrait.selected = i;
            self:addTrait(self.listboxTrait, self.listboxBannedTraits);
        else
            local i = CDTools.TableContains(self.listboxBadTrait.items, trait_name, compare_trait_function);
            if i ~= -1 then
                self.listboxBadTrait.selected = i;
                self:addTrait(self.listboxBadTrait, self.listboxBannedTraits);
            else
                print("CDCharRandomizer: Could not find trait with name " .. trait_name);
            end
        end
    end
end

-- {{ List element events 
function CDCharRandomizerSettings:onDblClickRequiredTrait(item)
	self:removeTrait(self.listboxRequiredTraits);
end

function CDCharRandomizerSettings:onDblClickBannedTrait(item)
	self:removeTrait(self.listboxBannedTraits);
end

function CDCharRandomizerSettings:onDblClickBadTrait(item)
	self:addTrait(self.listboxBadTrait, self.listboxRequiredTraits);
end

function CDCharRandomizerSettings:onDblClickTrait(item)
    self:addTrait(self.listboxTrait, self.listboxRequiredTraits);
end

function CDCharRandomizerSettings:onSelectProf(item)
    if self.profession ~= item then
        -- remove the previous free trait
        for j, k in pairs(self.freeTraits) do
            self.listboxRequiredTraits:removeItem(k:getLabel());
        end
        local removed = self.freeTraits
        self.freeTraits = {};

        -- Remove chosen traits that are excluded by the profession's free traits.
        for i=self.listboxRequiredTraits:size(),1,-1 do
            local selectedTrait = self.listboxRequiredTraits.items[i].item
            for j=1,item:getFreeTraits():size() do
                local freeTrait = TraitFactory.getTrait(item:getFreeTraits():get(j-1))
                if freeTrait:getMutuallyExclusiveTraits():contains(selectedTrait:getType()) then
                    self.listboxRequiredTraits.selected = i
                    self:removeTrait(self.listboxRequiredTraits);
                end
            end
        end

        -- we add the free trait that our selected profession give us
        for i = 0, item:getFreeTraits():size() - 1 do
            local freeTrait = TraitFactory.getTrait(item:getFreeTraits():get(i));
            local newTrait = self.listboxRequiredTraits:addItem(freeTrait:getLabel(), freeTrait);
            newTrait.tooltip = freeTrait:getDescription();
            table.insert(self.freeTraits, freeTrait);
            -- self:mutualyExclusive(freeTrait, false);
        end

        for _,trait in pairs(removed) do
            -- self:mutualyExclusive(trait, true)
        end

        self.profession = item;

		local desc = MainScreen.instance.desc;
		desc:setProfessionSkills(self.profession);
		desc:setProfession(self.profession:getType());

		self.cost = self.profession:getCost();
        CharacterCreationMain.sort(self.listboxTrait.items);
        CharacterCreationMain.invertSort(self.listboxBadTrait.items);
        CharacterCreationMain.sort(self.listboxRequiredTraits.items);
        CharacterCreationMain.instance:disableBtn()
     end
end

function CDCharRandomizerSettings:onSelectRequiredTrait(item)
	if item:isFree() then
		self.removeRequiredTraitBtn:setEnable(false);
	else
		self.removeRequiredTraitBtn:setEnable(true);
	end
end

function CDCharRandomizerSettings:onSelectBannedTrait(item)
	if item:isFree() then
		self.removeBannedTraitBtn:setEnable(false);
	else
		self.removeBannedTraitBtn:setEnable(true);
	end
end

function CDCharRandomizerSettings:onSelectTrait(item)
	self.addRequiredTraitBtn:setEnable(true);
    self.addBannedTraitBtn:setEnable(true);
end

function CDCharRandomizerSettings:onSelectBadTrait(item)
    self.addRequiredBadTraitBtn:setEnable(true);
    self.addBannedBadTraitBtn:setEnable(true);
end
-- }}

-- {{ Button events
function CDCharRandomizerSettings:OnButtonBack(button, x, y)
    CDCharRandomizer.requiredTraits_hs = {};
    for _, trait in pairs(self.listboxRequiredTraits.items) do
        CDCharRandomizer.requiredTraits_hs[trait.item:getType()] = true;
    end
    CDCharRandomizer.bannedTraits_hs = {};
    for _, trait in pairs(self.listboxBannedTraits.items) do
        CDCharRandomizer.bannedTraits_hs[trait.item:getType()] = true;
    end

    CDCharRandomizer.SaveRandomizerSettings();
    
    if self.infoRichText then
        self.infoRichText:removeFromUIManager()
        self.infoRichText = nil
    end

    local joypadData = JoypadState.getMainMenuJoypad() or CoopCharacterCreation.getJoypad();
    self:setVisible(false);
    MainScreen.instance.charCreationProfession:setVisible(true, joypadData);
end

function CDCharRandomizerSettings:OnButtonAddRequiredTrait(button, x, y)
    if self.listboxTrait.selected > 0 then
        self:addTrait(self.listboxTrait, self.listboxRequiredTraits);
    end
end

function CDCharRandomizerSettings:OnButtonAddRequiredBadTrait(button, x, y)
    if self.listboxBadTrait.selected > 0 then
        self:addTrait(self.listboxBadTrait, self.listboxRequiredTraits);
    end
end

function CDCharRandomizerSettings:OnButtonAddBannedTrait(button, x, y)
    if self.listboxTrait.selected > 0 then
        self:addTrait(self.listboxTrait, self.listboxBannedTraits);
    end
end

function CDCharRandomizerSettings:OnButtonAddBannedBadTrait(button, x, y)
    if self.listboxBadTrait.selected > 0 then
        self:addTrait(self.listboxBadTrait, self.listboxBannedTraits);
    end
end

function CDCharRandomizerSettings:OnButtonRemoveRequiredTrait(button, x, y)
    if self.listboxRequiredTraits.selected > 0 then
        self:removeTrait(self.listboxRequiredTraits);
    end
end

function CDCharRandomizerSettings:OnButtonRemoveBannedTrait(button, x, y)
    if self.listboxBannedTraits.selected > 0 then
        self:removeTrait(self.listboxBannedTraits);
    end
end
-- }}

function CDCharRandomizerSettings:addTrait(from_listbox, to_listbox)
	local selectedTrait = from_listbox.items[from_listbox.selected].text;
    
	local newItem = to_listbox:addItem(selectedTrait, from_listbox.items[from_listbox.selected].item);
	newItem.tooltip = from_listbox.items[from_listbox.selected].tooltip;
    
	-- remove from the available traits
    from_listbox:removeItem(selectedTrait);
    CharacterCreationMain.sort(self.listboxRequiredTraits.items);

	-- reset cursor
	-- self.listboxRequiredTraits.selected = -1;
	-- self.listboxBannedTraits.selected = -1;
    -- self.listboxBadTrait.selected = -1;
    -- self.listboxTrait.selected = -1;
	-- self.removeRequiredTraitBtn:setEnable(false);
	-- self.removeBannedTraitBtn:setEnable(false);
	-- self.addRequiredTraitBtn:setEnable(false);
	-- self.addBannedTraitBtn:setEnable(false);
    -- self.addRequiredBadTraitBtn:setEnable(false);
    -- self.addBannedBadTraitBtn:setEnable(false);
end

-- function CDCharRandomizerSettings:mutualyExclusive(trait, bAdd)
-- 	for i = 0, trait:getMutuallyExclusiveTraits():size() - 1 do
-- 		local exclusiveTrait = trait:getMutuallyExclusiveTraits():get(i);
--         exclusiveTrait = TraitFactory.getTrait(exclusiveTrait);
-- 		if exclusiveTrait:isFree() then
-- 			-- nothing
-- 		elseif not bAdd then
-- 			-- remove from our available traits list the exclusive ones
--             if exclusiveTrait:getCost() > 0 then
--                 self.listboxTrait:removeItem(exclusiveTrait:getLabel());
--             else
--                 self.listboxBadTrait:removeItem(exclusiveTrait:getLabel());
--             end
-- 		elseif not self:isTraitExcluded(exclusiveTrait) then
-- 			-- add the previously removed exclusive trait to the available ones
--             local newItem = {};
--             if exclusiveTrait:getCost() > 0 then
-- 			    newItem = self.listboxTrait:addItem(exclusiveTrait:getLabel(), exclusiveTrait);
--             else
--                 newItem = self.listboxBadTrait:addItem(exclusiveTrait:getLabel(), exclusiveTrait);
--             end
-- 			newItem.tooltip = exclusiveTrait:getDescription();
-- 		end
-- 	end
-- end

function CDCharRandomizerSettings:isTraitExcluded(trait)
	for i=1,self.listboxRequiredTraits:size() do
		local selectedTrait = self.listboxRequiredTraits.items[i].item
		local excludedTraits = selectedTrait:getMutuallyExclusiveTraits()
		if excludedTraits:contains(trait:getType()) then
			return true
		end
	end
	return false
end

function CDCharRandomizerSettings:removeTrait(target_listbox)
	local trait = target_listbox.items[target_listbox.selected].item
	if not trait:isFree() then
		-- remove from the selected traits
		target_listbox:removeItem(trait:getLabel());
		-- add to available traits
        local newItem = {};
        if trait:getCost() > 0 then
    		newItem = self.listboxTrait:addItem(trait:getLabel(), trait);
            CharacterCreationMain.sort(self.listboxTrait.items);
        -- self.listboxTrait.selected = -1;
        else
            newItem = self.listboxBadTrait:addItem(trait:getLabel(), trait);
            CharacterCreationMain.invertSort(self.listboxBadTrait.items);
        -- self.listboxBadTrait.selected = -1;
        end
		newItem.tooltip = trait:getDescription();

		-- reset cursor
		-- target_listbox.selected = -1;
		-- self.removeRequiredTraitBtn:setEnable(false);
		-- self.addRequiredTraitBtn:setEnable(false);
		-- self.addBannedTraitBtn:setEnable(false);
        -- self.addRequiredBadTraitBtn:setEnable(false);
        -- self.addBannedBadTraitBtn:setEnable(false);
	end
end

function CDCharRandomizerSettings:drawAvatar()
	if MainScreen.instance.avatar == nil then
		return;
	end

	local x = self:getAbsoluteX();
	local y = self:getAbsoluteY();
	x = x + 96 / 2;
	y = y + 165;

	MainScreen.instance.avatar:drawAt(x, y);
end

function CDCharRandomizerSettings:update()
	ISPanelJoypad.update(self)
end

-- I'm not sure what prerender actually does for the most part, so I'm leaving it untouched.
-- Much of the stuff I've added seems to work fine without any prerender added.
function CDCharRandomizerSettings:prerender()
	ISPanel.prerender(self);
	self:drawTextCentre("Character Randomizer Settings", self.width / 2, self.mainPanel.y - 10 - FONT_HGT_TITLE, 1, 1, 1, 1, UIFont.Title);

	-- resize our stuff
	local listWidth = (self.mainPanel:getWidth() - 16 * 2 - self.tablePadX * 2) / 3
	self.listboxProf:setWidth(listWidth);
	self.listboxTrait:setX(self.listboxProf:getX() + self.listboxProf:getWidth() + 20);
	self.listboxTrait:setWidth(listWidth);
    self.listboxBadTrait:setX(self.listboxTrait:getX());
    self.listboxBadTrait:setWidth(listWidth);
	self.listboxRequiredTraits:setX(self.listboxTrait:getX() + self.listboxTrait:getWidth() + 20);
	self.listboxRequiredTraits:setWidth(listWidth);
    self.listboxBannedTraits:setX(self.listboxRequiredTraits:getX());
    self.listboxBannedTraits:setWidth(listWidth);
	self.addRequiredBadTraitBtn:setX(self.listboxBadTrait:getRight() - self.addRequiredBadTraitBtn:getWidth());
    self.addRequiredTraitBtn:setX(self.listboxTrait:getRight() - self.addRequiredTraitBtn:getWidth());
    self.removeRequiredTraitBtn:setX(self.listboxRequiredTraits:getRight() - self.removeRequiredTraitBtn:getWidth());

	self.bottomOfLists = self.mainPanel:getHeight() - self.belowLists
	local traitButtonGap = self.traitButtonPad * 2 + self.traitButtonHgt
	local heightForHalfLists = self.bottomOfLists - self.topOfLists - self.smallFontHgt - traitButtonGap
	local halfListHeight1 = math.floor(heightForHalfLists / 2)
	local halfListHeight2 = heightForHalfLists - halfListHeight1

	self.listboxTrait:setHeight(halfListHeight1)
	self.addRequiredTraitBtn:setY(self.listboxTrait:getY() + halfListHeight1 + self.traitButtonPad)

	self.listboxRequiredTraits:setHeight(halfListHeight1)
	self.removeRequiredTraitBtn:setY(self.addRequiredTraitBtn:getY())
	
	self.listboxBadTrait:setY(self.listboxTrait:getY() + halfListHeight1 + traitButtonGap)
	self.listboxBadTrait:setHeight(halfListHeight2)
	self.addRequiredBadTraitBtn:setY(self.listboxBadTrait:getY() + halfListHeight2 + self.traitButtonPad)

	self.listboxBannedTraits:setY(self.listboxBadTrait:getY())
	self.listboxBannedTraits:setHeight(halfListHeight2)

	local joypadData = JoypadState.getMainMenuJoypad() or CoopCharacterCreation.getJoypad()
	if not joypadData or not joypadData:isConnected() then
		if not self.addRequiredTraitBtn:isVisible() then
			self.addRequiredTraitBtn:setVisible(true)
			self.addRequiredBadTraitBtn:setVisible(true)
			self.removeRequiredTraitBtn:setVisible(true)
			self.tooltipRichText:setVisible(false)

			self.addRequiredTraitBtn:setEnable(self.listboxTrait.items[self.listboxTrait.selected] ~= nil)
			self.addRequiredBadTraitBtn:setEnable(self.listboxBadTrait.items[self.listboxBadTrait.selected] ~= nil)
			self.removeRequiredTraitBtn:setEnable(self.listboxRequiredTraits.items[self.listboxRequiredTraits.selected] ~= nil)
		end
		return
	end
	if self.addRequiredTraitBtn:isVisible() then
		self.addRequiredTraitBtn:setVisible(false)
		self.addRequiredBadTraitBtn:setVisible(false)
		self.removeRequiredTraitBtn:setVisible(false)
		self.tooltipRichText:setVisible(true)
	end

	-- Update controller tooltip
	if self.listboxProf.joyfocus and self.listboxProf.items[self.listboxProf.selected] then
		self.tooltipLabel = self.listboxProf.items[self.listboxProf.selected].tooltip or ""
		self.tooltipLabel = self.tooltipLabel:gsub("\n", " <SPACE> <SPACE> <SPACE> ")
		self.tooltipColor = { r = 1.0, g = 1.0, b = 1.0 }
	elseif self.listboxTrait.joyfocus and self.listboxTrait.items[self.listboxTrait.selected] then
		self.tooltipLabel = self.listboxTrait.items[self.listboxTrait.selected].tooltip or ""
		self.tooltipLabel = self.tooltipLabel:gsub("\n", " <SPACE> <SPACE> <SPACE> ")
		self.tooltipColor = self:getTraitColor(self.listboxTrait.items[self.listboxTrait.selected].item)
	elseif self.listboxBadTrait.joyfocus and self.listboxBadTrait.items[self.listboxBadTrait.selected] then
		self.tooltipLabel = self.listboxBadTrait.items[self.listboxBadTrait.selected].tooltip or ""
		self.tooltipLabel = self.tooltipLabel:gsub("\n", " <SPACE> <SPACE> <SPACE> ")
		self.tooltipColor = self:getTraitColor(self.listboxBadTrait.items[self.listboxBadTrait.selected].item)
	elseif self.listboxRequiredTraits.joyfocus and self.listboxRequiredTraits.items[self.listboxRequiredTraits.selected] then
		self.tooltipLabel = self.listboxRequiredTraits.items[self.listboxRequiredTraits.selected].tooltip or ""
		self.tooltipLabel = self.tooltipLabel:gsub("\n", " <SPACE> <SPACE> <SPACE> ")
		self.tooltipColor = self:getTraitColor(self.listboxRequiredTraits.items[self.listboxRequiredTraits.selected].item)
	else
		self.tooltipLabel = nil
	end
end

function CDCharRandomizerSettings:render()
	local w = (self.mainPanel:getWidth() / 3);

	-- point to spend text
--	self:drawRect(self.mainPanel:getX() + 64, self.mainPanel:getY() + 161, self.mainPanel:getWidth() - 64 - 40, 1, 1, 0.3, 0.3, 0.3);
	-- local pointsY = self.mainPanel:getY() + self.backButton:getY() - 5 - self.mediumFontHgt
	-- pointsY = pointsY - (self.tooltipRichText.height - FONT_HGT_MEDIUM) / 2
	-- local pointsWid = getTextManager():MeasureStringX(UIFont.Medium, tostring(self:PointToSpend()))
	-- self:drawTextRight(getText("UI_characreation_pointToSpend"), self.mainPanel:getX() + self.mainPanel:getWidth() - pointsWid - 16 - 8, pointsY, 1, 1, 1, 1, UIFont.Medium);
	-- local pointString = self:PointToSpend() .. "";
	-- title over each table

	self:drawText("Required Occupation", self.mainPanel:getX() + 16, self.listboxProf:getAbsoluteY() - self.mediumFontHgt - 8, 1, 1, 1, 1, UIFont.Medium);
	self:drawText("Randomized Traits", self.listboxTrait:getAbsoluteX(), self.listboxProf:getAbsoluteY() - self.mediumFontHgt - 8, 1, 1, 1, 1, UIFont.Medium);
	self:drawText("Required Traits", self.listboxRequiredTraits:getAbsoluteX(), self.listboxProf:getAbsoluteY() - self.mediumFontHgt - 8, 1, 1, 1, 1, UIFont.Medium);
	self:drawText("Banned Traits", self.listboxBannedTraits:getAbsoluteX(), self.listboxBadTrait:getAbsoluteY() - self.mediumFontHgt - 8, 1, 1, 1, 1, UIFont.Medium);

	self:drawText(getText("UI_characreation_description"), self.mainPanel:getX() + self.listboxTrait:getX(), self.listboxTrait:getAbsoluteY() - self.smallFontHgt, 1, 1, 1, 1, UIFont.Small);
	self:drawTextRight(getText("UI_characreation_cost"), self.mainPanel:getX() + self.listboxTrait:getX() + self.listboxTrait:getWidth() - 11, self.listboxTrait:getAbsoluteY() - self.smallFontHgt, 1, 1, 1, 1, UIFont.Small);
	self:drawText(getText("UI_characreation_description"), self.mainPanel:getX() + self.listboxRequiredTraits:getX(), self.listboxRequiredTraits:getAbsoluteY() - self.smallFontHgt, 1, 1, 1, 1, UIFont.Small);
	self:drawTextRight(getText("UI_characreation_cost"), self.mainPanel:getX() + self.listboxRequiredTraits:getX() + self.listboxRequiredTraits:getWidth() - 11, self.listboxRequiredTraits:getAbsoluteY() - self.smallFontHgt, 1, 1, 1, 1, UIFont.Small);

	if self.tooltipLabel and self.tooltipLabel ~= "" then
		if self.tooltipRichText.text ~= self.tooltipLabel then
			self.tooltipRichText.text = string.format(" <RGB:%.2f,%.2f,%.2f> %s", self.tooltipColor.r, self.tooltipColor.g, self.tooltipColor.b, self.tooltipLabel)
			self.tooltipRichText:paginate()
		end
	end
end

function CDCharRandomizerSettings:PointToSpend()
	if SandboxVars and SandboxVars.CharacterFreePoints then
		return self.pointToSpend + self.cost + SandboxVars.CharacterFreePoints;
	end
	return self.pointToSpend + self.cost;
end

-- fetch all our profession to populate our list box
function CDCharRandomizerSettings:populateProfessionList(list)
	local professionList = ProfessionFactory.getProfessions();
	for i = 0, professionList:size() - 1 do
		local newitem = list:addItem(i, professionList:get(i));
        newitem.tooltip = professionList:get(i):getDescription();
	end
end

-- fetch all our traits to populate our list box
function CDCharRandomizerSettings:populateTraitList(list)
	local traitList = TraitFactory.getTraits();
	for i = 0, traitList:size() - 1 do
		local trait = traitList:get(i);
		if not trait:isFree() and trait:getCost() > 0 and ((trait:isRemoveInMP() and not isClient()) or not trait:isRemoveInMP()) then
			local newItem = list:addItem(trait:getLabel(), trait);
			newItem.tooltip = trait:getDescription();
		end
	end
end

function CDCharRandomizerSettings:populateBadTraitList(list)
    local traitList = TraitFactory.getTraits();
    for i = 0, traitList:size() - 1 do
        local trait = traitList:get(i);
        if not trait:isFree() and trait:getCost() < 0 and ((trait:isRemoveInMP() and not isClient()) or not trait:isRemoveInMP()) then
            local newItem = list:addItem(trait:getLabel(), trait);
            newItem.tooltip = trait:getDescription();
        end
    end
end

function CDCharRandomizerSettings:drawXpBoostMap(y, item, alt)

    local dy = (self.itemheight - self.fontHgt) / 2
    local hc = getCore():getGoodHighlitedColor()
    self:drawText(item.text, 16, y + dy, hc:getR(), hc:getG(), hc:getB(), 1, UIFont.Small);

    local percentage = "+ 75%";
--    self:drawTexture(CDCharRandomizerSettings.instance.greenBlits, self.width - 80, (y) + 12, 1, 1, 1, 1);
    if item.item.level == 2 then
        percentage = "+ 100%";
--        self:drawTexture(CDCharRandomizerSettings.instance.greenBlits, self.width - 76, (y) + 12, 1, 1, 1, 1);
    elseif item.item.level >= 3 then
        percentage = "+ 125%";
--        self:drawTexture(CDCharRandomizerSettings.instance.greenBlits, self.width - 76, (y) + 12, 1, 1, 1, 1);
--        self:drawTexture(CDCharRandomizerSettings.instance.greenBlits, self.width - 72, (y) + 12, 1, 1, 1, 1);
    end

    local textWid = getTextManager():MeasureStringX(UIFont.Small, item.text)
    local greenBlitsX = self.width - (68 + 10 * 4)
    local yy = y
    if 16 + textWid > greenBlitsX - 4 then
        yy = y + self.fontHgt
    end

    for i = 1,item.item.level do
        self:drawTexture(CDCharRandomizerSettings.instance.whiteBar, self.width - (68 + 10 * 4) + (i * 4), (yy) + dy + 4, 1, hc:getR(), hc:getG(), hc:getB());
    end
    if item.item.perk ~= Perks.Fitness and item.item.perk ~= Perks.Strength then
        self:drawTextRight(percentage, self.width - 16, yy + dy, hc:getR(), hc:getG(), hc:getB(), 1, UIFont.Small);
    end

    yy = yy + self.itemheight;

    self:drawRectBorder(0, (y), self:getWidth(), yy - y - 1, 0.5, self.borderColor.r, self.borderColor.g, self.borderColor.b);

    return yy;
end

function CDCharRandomizerSettings:getTraitColor(trait)
	local color
	if trait:getCost() > 0 then
        local hc = getCore():getGoodHighlitedColor()
        color = {r=hc:getR(), g=hc:getG(), b=hc:getB()}
	elseif trait:getCost() < 0 then
        local hc = getCore():getBadHighlitedColor()
        color = {r=hc:getR(), g=hc:getG(), b=hc:getB()}
	else
		color = {r = 1.0, g = 1.0, b = 1.0 }
	end
	return color
end

-- draw the list of available traits
function CDCharRandomizerSettings:drawTraitMap(y, item, alt)
	-- the rect over our item
	self:drawRectBorder(0, (y), self:getWidth(), self.itemheight - 1, 0.5, self.borderColor.r, self.borderColor.g, self.borderColor.b);

	-- if we selected an item, we display a grey rect over it
    local isMouseOver = self.mouseoverselected == item.index and not self:isMouseOverScrollBar()
	if self.selected == item.index then
		self:drawRect(0, (y), self:getWidth(), self.itemheight - 1, 0.3, 0.7, 0.35, 0.15);
    elseif isMouseOver then
        self:drawRect(1, y + 1, self:getWidth() - 2, item.height - 4, 0.95, 0.05, 0.05, 0.05);
	end

	-- icon of the trait
	local tex = item.item:getTexture()
	if tex then
		self:drawTexture(tex, 16-2, y + (self.itemheight - tex:getHeight()) / 2, 1, 1, 1, 1);
	end

	-- get the right color (green if it's a good trait, red if not)
    local r = getCore():getBadHighlitedColor():getR();
    local g = getCore():getBadHighlitedColor():getG();
    local b = getCore():getBadHighlitedColor():getB();
    -- if it cost point, it's a good trait
    if item.item:getCost() > 0 then
        r = getCore():getGoodHighlitedColor():getR();
        g = getCore():getGoodHighlitedColor():getG();
        b = getCore():getGoodHighlitedColor():getB();
	elseif item.item:getCost() == 0 then
		r = 1;
		g = 1;
		b = 1;
	end
	-- the name of the trait
	local w = 16;
	if item.item:getTexture() then
		w = item.item:getTexture():getWidth() + 20;
	end
    local dy = (self.itemheight - self.fontHgt) / 2
	self:drawText(item.item:getLabel(), w, y + dy, r, g, b, 0.9, UIFont.Small);

	-- the cost of the trait
	self:drawTextRight(item.item:getRightLabel(), self:getWidth() - 20, y + dy, r, g, b, 0.9, UIFont.Small);

	self.itemheightoverride[item.item:getLabel()] = self.itemheight;

	y = y + self.itemheightoverride[item.item:getLabel()];

	return y;
end

-- draw the list of profession
function CDCharRandomizerSettings:drawProfessionMap(y, item, alt)
	-- the rect over our item
	self:drawRectBorder(0, (y), self:getWidth(), self.itemheight - 1, 0.5, self.borderColor.r, self.borderColor.g, self.borderColor.b);

	-- if we selected an item, we display a grey rect over it
    local isMouseOver = self.mouseoverselected == item.index and not self:isMouseOverScrollBar()
	if self.selected == item.index then
		self:drawRect(0, (y), self:getWidth(), self.itemheight - 1, 0.3, 0.7, 0.35, 0.15);
    elseif isMouseOver then
        self:drawRect(1, y + 1, self:getWidth() - 2, item.height - 4, 0.95, 0.05, 0.05, 0.05);
	end

	-- icon of the profession
	if item.item:getTexture() then
		self:drawTexture(item.item:getTexture(), 8, y + (item.height - 64) / 2, 1, 1, 1, 1);
	end

	local x = 7;

	-- the name of the profession
	if item.item:getTexture() then
		x = 74;
	end
	self:drawText(item.item:getName(), x, y + (item.height - self.fontHgt) / 2, 0.9, 0.9, 0.9, 0.9, UIFont.Small);

	self.itemheightoverride[item.item:getName()] = self.itemheight;

	y = y + self.itemheightoverride[item.item:getName()];

	return y;
end

function CDCharRandomizerSettings.initWorld()
	if isDemo() then
		return
	end
	if getCore():getGameMode() == "Tutorial" then
		return
	end
	if MainScreen.instance == nil then
		return
	end

	getWorld():setLuaPlayerDesc(MainScreen.instance.desc);
	getWorld():getLuaTraits():clear()
	for i, v in pairs(CDCharRandomizerSettings.instance.listboxRequiredTraits.items) do
		getWorld():addLuaTrait(v.item:getType());
	end

	local spawnRegion = MapSpawnSelect.instance.selectedRegion
	if not spawnRegion then
		-- possible to skip MapSpawnSelect by going from LoadGameScreen to CharacterCreationMain
		-- i.e., double-clicking an existing savefile with a dead character
		spawnRegion = MapSpawnSelect.instance:useDefaultSpawnRegion()
	end
	if not spawnRegion then
		error "no spawn region was chosen, don't know where to spawn the player"
		return
	end
	print('using spawn region '..tostring(spawnRegion.name))
	-- we generate the spawn point for the profession choose
	local spawn = spawnRegion.points[MainScreen.instance.desc:getProfession()];
	if not spawn then
		spawn = spawnRegion.points["unemployed"];
	end
	if not spawn then
		error "there is no spawn point table for the player's profession, don't know where to spawn the player"
		return
	end
	print(#spawn..' possible spawn points')
	local randSpawnPoint = spawn[(ZombRand(#spawn) + 1)];
	getWorld():setLuaSpawnCellX(randSpawnPoint.worldX);
	getWorld():setLuaSpawnCellY(randSpawnPoint.worldY);
	getWorld():setLuaPosX(randSpawnPoint.posX);
	getWorld():setLuaPosY(randSpawnPoint.posY);
	getWorld():setLuaPosZ(randSpawnPoint.posZ or 0);
end

function CDCharRandomizerSettings:onGainJoypadFocus(joypadData)
--    print("character profession gain focus");
    ISPanelJoypad.onGainJoypadFocus(self, joypadData);
    self:setISButtonForA(self.playButton);
    self:setISButtonForB(self.backButton);
    self:setISButtonForY(self.randomButton);
	self:setISButtonForX(self.resetButton);
	--    self.listboxProf.selected = -1;
end

function CDCharRandomizerSettings:onLoseJoypadFocus(joypadData)
	self.playButton:clearJoypadButton()
	self.backButton:clearJoypadButton()
	self.randomButton:clearJoypadButton()
	self.resetButton:clearJoypadButton()
	ISPanelJoypad.onLoseJoypadFocus(self, joypadData)
end

function CDCharRandomizerSettings:onJoypadBeforeDeactivate(joypadData)
	-- Focus could be on one of the lists
	self.joyfocus = nil
end

function CDCharRandomizerSettings:onJoypadDirUp(joypadData)
    joypadData.focus = self.listboxProf
    updateJoypadFocus(joypadData)
end

function CDCharRandomizerSettings:onJoypadDirLeft(joypadData)
    joypadData.focus = self.presetPanel
    updateJoypadFocus(joypadData)
end

function CDCharRandomizerSettings:onJoypadDirRight(joypadData)
    joypadData.focus = self.presetPanel
    updateJoypadFocus(joypadData)
end

function CDCharRandomizerSettings:onResolutionChange(oldw, oldh, neww, newh)
	local w = neww * 0.75;
	local h = newh * 0.8;
	if (w < 768) then
		w = 768;
	end
	local screenWid = neww;
	local screenHgt = newh;
	self.mainPanel:setWidth(w)
	self.mainPanel:setHeight(h)
	self.mainPanel:setX((screenWid - w) / 2)
	self.mainPanel:setY((screenHgt - h) / 2)
	self.mainPanel:recalcSize()

--	MainScreen.instance.charCreationHeader:setX(self.mainPanel:getX());
--	MainScreen.instance.charCreationHeader:setY(self.mainPanel:getY());
end

function CDCharRandomizerSettings:presetExists(findText)
    return self.savedBuilds:find(function(text, data, findText)
        return text == findText
    end, findText) ~= -1
end

function CDCharRandomizerSettings:deleteBuildStep2(button, joypadData) -- {{{
    if joypadData then
        joypadData.focus = self.presetPanel
        updateJoypadFocus(joypadData)
    end

    if button.internal == "NO" then return end
    
    local delBuild = self.savedBuilds.options[self.savedBuilds.selected];

    local builds = BCRC.readSaveFile();
    builds[delBuild] = nil;

    local options = {};
    BCRC.writeSaveFile(builds);
    for key,val in pairs(builds) do
        if key ~= nil and val ~= nil then
            options[key] = 1;
        end
    end

    self.savedBuilds.options = {};
    for key,val in pairs(options) do
        table.insert(self.savedBuilds.options, key);
    end
    if self.savedBuilds.selected > #self.savedBuilds.options then
        self.savedBuilds.selected = #self.savedBuilds.options
    end
    self:loadBuild(self.savedBuilds)
--    luautils.okModal("Deleted build "..delBuild.."!", true);
end

BCRC = {};
BCRC.savefile = "saved_builds.txt";

function BCRC.inputModal(_centered, _width, _height, _posX, _posY, _text, _onclick, target, param1, param2) -- {{{
    -- based on luautils.okModal
    local posX = _posX or 0;
    local posY = _posY or 0;
    local width = _width or 230;
    local height = _height or 120;
    local centered = _centered;
    local txt = _text;
    local core = getCore();

    -- center the modal if necessary
    if centered then
        posX = core:getScreenWidth() * 0.5 - width * 0.5;
        posY = core:getScreenHeight() * 0.5 - height * 0.5;
    end

    -- ISModalDialog:new(x, y, width, height, text, yesno, target, onclick, player, param1, param2)
    local modal = ISTextBox:new(posX, posY, width, height, getText("UI_characreation_BuildSavePrompt"), _text or "", target, _onclick, param1, param2);
    modal:initialise();
    modal:setAlwaysOnTop(true)
    modal:setCapture(true)
    modal:addToUIManager();
    modal.yes:setTitle(getText("UI_btn_save"))
    modal.entry:focus()

    return modal;
end
-- }}}
function BCRC.readSaveFile() -- {{{
    local retVal = {};

    local saveFile = getFileReader(BCRC.savefile, true);
    local line = saveFile:readLine();
    while line ~= nil do
        local s = luautils.split(line, ":");
        retVal[s[1]] = s[2];
        line = saveFile:readLine();
    end
    saveFile:close();

    return retVal;
end
-- }}}
function BCRC.writeSaveFile(options) -- {{{
    local saved_builds = getFileWriter(BCRC.savefile, true, false); -- overwrite
    for key,val in pairs(options) do
        saved_builds:write(key..":"..val.."\n");
    end
    saved_builds:close();
end
-- }}}
BCRC.dump = function(o, lvl) -- {{{ Small function to dump an object.
    if lvl == nil then lvl = 5 end
    if lvl < 0 then return "SO ("..tostring(o)..")" end

    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if k == "prev" or k == "next" then
                s = s .. '['..k..'] = '..tostring(v);
            else
                if type(k) ~= 'number' then k = '"'..k..'"' end
                s = s .. '['..k..'] = ' .. BCRC.dump(v, lvl - 1) .. ',\n'
            end
        end
        return s .. '}\n'
    else
        return tostring(o)
    end
end
-- }}}
BCRC.pline = function (text) -- {{{ Print text to logfile
    print(tostring(text));
end

Events.OnInitWorld.Add(CDCharRandomizerSettings.initWorld);
