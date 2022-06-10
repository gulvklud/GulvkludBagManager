------------------------------------------------------------------------------------
-- FRAMES
------------------------------------------------------------------------------------

GBManager = CreateFrame("Frame", "GulvkludBagManager", UIParent);
GBManager:SetScript("OnEvent", function(_, ...) GBManager.OnEvent(...) end);
GBManager:RegisterEvent("PLAYER_ENTERING_WORLD");
GBManager:RegisterEvent("PLAYER_LOGOUT");
GBManager:RegisterEvent("BAG_UPDATE");
GBManager:RegisterEvent("MERCHANT_CLOSED");
GBManager:RegisterEvent("MERCHANT_SHOW");

GBManager.Chat = DEFAULT_CHAT_FRAME;

GBManager.Button = CreateFrame("Button", "GBManagerButton", GBManager, "SecureActionButtonTemplate")
GBManager.Button.DefaultMacro = "/gmb process all"
--GBManager.Button:RegisterForClicks("AnyDown","AnyUp")
GBManager.Button:RegisterForClicks("AnyDown")
GBManager.Button:SetAttribute("type","macro")
GBManager.Button:SetAttribute("macrotext", GBManager.Button.DefaultMacro)

GBManager.Button.KeyBind = function(key)

	--GBManager.Chat:AddMessage("Button.KeyBind:" .. key)

	if InCombatLockdown() then
		
		if not GBManager.Button:IsEventRegistered("PLAYER_REGEN_ENABLED") then

			GBManager.Button:RegisterEvent("PLAYER_REGEN_ENABLED");
			GBManager.Button:SetScript("OnEvent", function(_, event) GBManager.Button.KeyBind(key) end);
		end

		return
	end

	if GBManager.Button:IsEventRegistered("PLAYER_REGEN_ENABLED") then

		GBManager.Button:UnregisterEvent("PLAYER_REGEN_ENABLED");
	end

	SetOverrideBindingClick(GBManager.Button, true, key, GBManager.Button:GetName())
end

GBManager.Tooltip = CreateFrame("GameTooltip", "GBManagerTooltip", GBManager, "GameTooltipTemplate")
GBManager.Tooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
GBManager.Tooltip.GetLine = function(i)

	return _G[GBManager.Tooltip:GetName() .. "TextLeft" .. i]
end

------------------------------------------------------------------------------------
-- CONFIGURATION
------------------------------------------------------------------------------------

GBManager.config = {
	chatFrame = 1,
	key = "CTRL-V"
};

------------------------------------------------------------------------------------
-- VARIABLES
------------------------------------------------------------------------------------

GBManager.merchantOpen = false;
GBManager.abilities = {
	pickLock = {
		id = 1804,
		name = GetSpellInfo(1804),
		known = false
	},
	disenchant = {
		id = 13262,
		name = GetSpellInfo(13262),
		known = false
	},
	prospecting = {
		id = 31252,
		name = GetSpellInfo(31252),
		known = false
	}
};

------------------------------------------------------------------------------------
-- SLASH COMMANDS
------------------------------------------------------------------------------------

SLASH_GBManager1 = "/gbm";
SlashCmdList.GBManager = function(cmd)
		
	local params = { strsplit(" ", cmd) };
	
	if params[1] == "process"  then
		if params[2] == "all" then
			
			GBManager.ProcessBags();
		end

	elseif params[1] == "print"  then
		if params[2] == "next" then
			
			local bag, slot = GBManager.GetNextLockPickableBagSlot();
			if bag and slot then

				GBManager.Chat:AddMessage(bag .. ", " .. slot);
			end
		end
	else
		GBManager.Chat:AddMessage("");
		GBManager.Chat:AddMessage("|cFF8789B3\"/gbm|r " .. cmd .. "\" is not a valid command.");
		GBManager.Chat:AddMessage("");
		GBManager.Chat:AddMessage("|cFF8789B3GuvkludBagManager|r command list:");
		GBManager.Chat:AddMessage("------------------------------------------------");
		GBManager.Chat:AddMessage("|cFF8789B3/gbm|r iterate all");
		GBManager.Chat:AddMessage("");
	end
end

------------------------------------------------------------------------------------
-- EVENTS
------------------------------------------------------------------------------------

GBManager.OnUnload = function()

	GBManagerConfig = GBManager.config;
end

GBManager.OnLoad = function()

	if GBManagerConfig then
		
		GBManager.config = GBManagerConfig;
	end

	if GBManager.config.chatFrame then
		
		GBManager.Chat = _G["ChatFrame" ..  GBManager.config.chatFrame]
	end

	GBManager.Chat:AddMessage("|cFF8789B3GuvkludBagManager|r loaded.");

	if GetSpellInfo(GBManager.abilities.pickLock.name) then
		
		GBManager.abilities.pickLock.known = true;
		GBManager.Chat:AddMessage("|cFF8789B3GuvkludBagManager|r has detected " .. GetSpellLink(GBManager.abilities.pickLock.id) .. ".");
	end

	if GetSpellInfo(GBManager.abilities.disenchant.name) then
		
		GBManager.abilities.disenchant.known = true;
		GBManager.Chat:AddMessage("|cFF8789B3GuvkludBagManager|r has detected " .. GetSpellLink(GBManager.abilities.disenchant.id) .. ".");
	end

	if GetSpellInfo(GBManager.abilities.prospecting.name) then
		
		GBManager.abilities.prospecting.known = true;
		GBManager.Chat:AddMessage("|cFF8789B3GuvkludBagManager|r has detected " .. GetSpellLink(GBManager.abilities.prospecting.id) .. ".");
	end
	
	if GBManager.abilities.pickLock.known or GBManager.abilities.disenchant.known or GBManager.abilities.prospecting.known then
		
		GBManager.Button.KeyBind(GBManager.config.key)
		GBManager.Chat:AddMessage("|cFF8789B3GuvkludBagManager|r press [" .. GBManager.config.key .. "] to begin processing your bags.");
	end

	GBManager.AssignButtonMacro();
end

GBManager.OnCombatEnded = function()

	GBManager.Button.KeyBind(GBManager.config.key)
end

GBManager.OnBagsUpdated = function()

	GBManager.AssignButtonMacro();
end

GBManager.OnMerchantWindowOpened = function()

	GBManager.merchantOpen = true;
	GBManager.ProcessBags();
end

GBManager.OnMerchantWindowClosed = function()

	GBManager.merchantOpen = false;
end

GBManager.OnEvent = function(event, ...)

	if event == "PLAYER_ENTERING_WORLD" then
		
		GBManager.OnLoad()

	elseif event == "PLAYER_LOGOUT" then

		GBManager.OnUnload()

	elseif event == "PLAYER_REGEN_ENABLED" then
	
		GBManager.OnCombatEnded()
	
	elseif event == "BAG_UPDATE" then

		GBManager.OnBagsUpdated()

	elseif event == "MERCHANT_SHOW" then
		
		GBManager.OnMerchantWindowOpened()
	
	elseif event == "MERCHANT_CLOSED" then
		
		GBManager.OnMerchantWindowClosed()
	end
end

------------------------------------------------------------------------------------
--  CONDITIONALS
------------------------------------------------------------------------------------

GBManager.IsLocked = function(bag, slot)
	
	if not GetContainerItemInfo(bag, slot) then
		return false
	end

	GBManager.Tooltip:SetBagItem(bag, slot)
	GBManager.Tooltip:Show()

	for i = 1, GBManager.Tooltip:NumLines(), 1 do

		local line = GBManager.Tooltip.GetLine(i);
		local text = line:GetText()

		if string.find(text, "Locked") then

			return true
		end
	end

    return false
end

GBManager.CanPickLock = function(bag, slot)
	
	if not GetContainerItemInfo(bag, slot) then
		return false
	end

	GBManager.Tooltip:SetBagItem(bag, slot)
	GBManager.Tooltip:Show()

	for i = 1, GBManager.Tooltip:NumLines(), 1 do

		local line = GBManager.Tooltip.GetLine(i);
		local text = line:GetText()
		
		if string.find(text, "Locked") then
			-- Red		(red: 0.999, 	green: 0.125, 	blue: 0.125)
			-- Orange 	(red: 0.999, 	green: 0.5, 	blue: 0.25)
			-- Grey 	(red: 0.5,		green: 0.5, 	blue: 0.5)
			local red, green, blue = line:GetTextColor();
			--GBManager.Chat:AddMessage("Prospecting? bag["..bag..","..slot.."].lines["..i.."] = " .. text .. "(red: " .. red .. ", green: " .. green ..", blue: ".. blue .. ")")

			return green > 0.25 and blue > 0.25
		end
	end

    return false
end

--[[
GBManager.IsProspectable = function(bag, slot)
	
	if not GetContainerItemInfo(bag, slot) then
		return false
	end

	GBManager.Tooltip:SetBagItem(bag, slot)
	GBManager.Tooltip:Show()
	
	for i = 1, GBManager.Tooltip:NumLines(), 1 do

		local line = GBManager.Tooltip.GetLine(i);
		local text = line:GetText()

		if string.find(text, "Prospectable") then

			GBManager.Tooltip:Hide()
			return true
		end
	end

	GBManager.Tooltip:Hide()
    return false
end
]]

GBManager.CanProspect = function(bag, slot)
	
	local _, itemCount = GetContainerItemInfo(bag, slot);
	if not itemCount then
		return false
	end
	
	if itemCount < 5 then
		return false
	end

	GBManager.Tooltip:SetBagItem(bag, slot)
	GBManager.Tooltip:Show()

	for i = 1, GBManager.Tooltip:NumLines(), 1 do

		local line = GBManager.Tooltip.GetLine(i);
		local text = line:GetText()

		if string.find(text, "Prospectable") then
			-- Red		(red: 0.999, 	green: 0.125, 	blue: 0.125)
			-- White 	(red: 0.999, 	green: 0.999, 	blue: 0.999)
			local red, green, blue = line:GetTextColor()
			--GBManager.Chat:AddMessage("Prospecting? bag["..bag..","..slot.."].lines["..i.."] = " .. text .. "(red: " .. red .. ", green: " .. green ..", blue: ".. blue .. ")")

			return green > 0.25 and blue > 0.25
		end
	end

    return false
end

GBManager.IsListedItem = function(itemLink)

	local itemName, _, itemRarity, _, requiredLevel = GetItemInfo(itemLink)
	local playerLevel = UnitLevel("PLAYER")

    for index, value in ipairs(GBManager.items) do
        if value == itemName then
            return true
        end
    end

    return false
end

GBManager.CanBeDisenchanted = function(bag, slot)

	if not GBManager.abilities.disenchant then
		return false
	end

	return false

	--[[
	GBManager.Tooltip:SetBagItem(bag, slot)
	GBManager.Tooltip:Show()
	
	for i = 1, GBManager.Tooltip:NumLines(), 1 do

		local line = GBManager.Tooltip:GetLine(i);
		local text = line:GetText()
		if string.find(line, "Cannot be disenchanted") then

			return false
		end
	end

	GBManager.Tooltip:Hide()

	return true
	]]
end

------------------------------------------------------------------------------------
--  ENUMERABLES
------------------------------------------------------------------------------------

GBManager.AssignButtonMacro = function()

	if GBManager.abilities.pickLock.known then

		local bag, slot = GBManager.GetNextLockPickableBagSlot()
		if bag and slot then
			
			GBManager.Button:SetAttribute("macrotext", GBManager.Button.DefaultMacro .. "\n/cast " .. GBManager.abilities.pickLock.name .. "\n/use " .. bag .. " " .. slot);
			return
		end

		GBManager.Chat:AddMessage("Nothing to Lockpick...")
	end

	if GBManager.abilities.prospecting.known then

		local bag, slot = GBManager.GetNextProspectableBagSlot()
		if bag and slot then
			
			GBManager.Button:SetAttribute("macrotext", GBManager.Button.DefaultMacro .. "\n/cast " .. GBManager.abilities.prospecting.name .. "\n/use " .. bag .. " " .. slot);
			return
		end

		GBManager.Chat:AddMessage("Nothing to Prospect...")
	end

	GBManager.Button:SetAttribute("macrotext", GBManager.Button.DefaultMacro);
end

GBManager.GetNextLockPickableBagSlot = function()

	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do

			if GBManager.CanPickLock(bag, slot) then

				return bag, slot
			end
		end
	end
end

GBManager.GetNextProspectableBagSlot = function()
	
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do

			if GBManager.CanProspect(bag, slot) then

				return bag, slot
			end
		end
	end
end

------------------------------------------------------------------------------------
--  ACTIONS
------------------------------------------------------------------------------------

GBManager.ProcessBags = function()

	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			local _, itemCount, _, _, _, lootable, itemLink, _, noValue = GetContainerItemInfo(bag,slot)
			
			if itemLink then
				local itemName, _, itemRarity, itemLevel, requiredLevel, itemType, itemSubType, itemStackCount, _, _, itemSellPrice = GetItemInfo(itemLink)
				local playerLevel = UnitLevel("PLAYER")

				if itemRarity == 0 then
					
					GBManager.DestroyOrSell(bag, slot)
				
				elseif itemType == "Consumable" and itemSubType == "Food & Drink" and (playerLevel - requiredLevel) > 15 then

					GBManager.DestroyOrSell(bag, slot)

				elseif GBManager.IsListedItem(itemLink) then

					GBManager.DestroyOrSell(bag, slot)

				elseif lootable and not GBManager.IsLocked(bag, slot) then
					
					GBManager.OpenContainer(bag, slot)
				end
			end
		end
	end
end

GBManager.DestroyOrSell = function(bag, slot)
	
	local _, _, _, _, _, lootable, itemLink, _, noValue = GetContainerItemInfo(bag, slot)
	local _, _, _, _, _, _, _, itemStackCount, _, _, itemSellPrice = GetItemInfo(itemLink)

	if(GBManager.merchantOpen) then
		if not lootable and not noValue then

			GBManager.Chat:AddMessage("Vendoring: " .. itemLink)
			UseContainerItem(bag, slot)
		end

	elseif itemStackCount * itemSellPrice < 5000 then

		GBManager.Chat:AddMessage("Destroying: " .. itemLink)
		PickupContainerItem(bag, slot)
		DeleteCursorItem()
	end
end

GBManager.OpenContainer = function(bag, slot)

	if not GBManager.merchantOpen then
		
		UseContainerItem(bag, slot)
	end
end