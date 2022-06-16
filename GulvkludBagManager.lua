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
GBManager.Button.DefaultMacro = "/gbm process all"
GBManager.Button:RegisterForClicks("AnyDown")
GBManager.Button:SetAttribute("type","macro")
GBManager.Button:SetAttribute("macrotext", GBManager.Button.DefaultMacro)

GBManager.Button.KeyBind = function(key)

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

GBManager.config = {};

GBManager.defaults = {
	key = "CTRL-V",
	chatFrame = 1,
	minimumValue = 5000
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

		-- todo: learn how to recursively iterate
		if not GBManager.config.key then
			GBManager.config.key = GBManager.defaults.key
		end

		if not GBManager.config.chatFrame then
			GBManager.config.chatFrame = GBManager.defaults.chatFrame
		end

		if not GBManager.config.minimumValue then
			GBManager.config.minimumValue = GBManager.defaults.minimumValue
		end
	end

	if GBManager.config.chatFrame then
		
		GBManager.Chat = _G["ChatFrame" ..  GBManager.config.chatFrame]
	end

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
	
	GBManager.Button.KeyBind(GBManager.config.key)
	GBManager.Chat:AddMessage("|cFF8789B3GuvkludBagManager|r press [" .. GBManager.config.key .. "] to begin processing your bags.");
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
	GBManager.Button:Disable()
	GBManager.ProcessBags();
end

GBManager.OnMerchantWindowClosed = function()

	GBManager.merchantOpen = false;
	GBManager.Button:Enable()
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

GBManager.IsItemMatch = function(itemLink)

	local itemName = GetItemInfo(itemLink)
	
	if itemName then
		for _, item in ipairs(GBManager.items) do

			if item == itemName then
				return true
			end
		end
	end

    return false
end

GBManager.IsDisenchantMatch = function(itemLink)

	local _, _, itemQuality, itemLevel, _, itemType, itemSubType = GetItemInfo(itemLink)

	if itemQuality and GBManager.disenchant[itemQuality] and itemLevel and itemType then
		--GBManager.Chat:AddMessage(itemLink .. "has Quality="..itemQuality..", itemLevel="..itemLevel..", itemType="..itemType..", itemSubType="..itemSubType)

		for index, item in pairs(GBManager.disenchant[itemQuality]) do 
			if item.type == itemType and item.level.min <= itemLevel and itemLevel <= item.level.max then
				
				if item.subTypes and not item.subTypes[itemSubType] then
					--GBManager.Chat:AddMessage(itemLink .. " is not valid subtype.")
					return false
				end

				if item.ignore then
					--GBManager.Chat:AddMessage(itemLink .. " is ignored.")
					return false
				end

				if item.vendor then
					--GBManager.Chat:AddMessage(itemLink .. " should be vendored.")
					return true, true
				end

				--GBManager.Chat:AddMessage(itemLink .. " should be disenchanted.")
				return true
			end
		end
	end;

	return false
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
	end

	if GBManager.abilities.prospecting.known then

		local bag, slot = GBManager.GetNextProspectableBagSlot()
		if bag and slot then
			
			GBManager.Button:SetAttribute("macrotext", GBManager.Button.DefaultMacro .. "\n/cast " .. GBManager.abilities.prospecting.name .. "\n/use " .. bag .. " " .. slot);
			return
		end
	end

	if GBManager.abilities.disenchant.known then

		local bag, slot = GBManager.GetNextDisenchantableBagSlot()
		if bag and slot then
			
			GBManager.Button:SetAttribute("macrotext", GBManager.Button.DefaultMacro .. "\n/cast " .. GBManager.abilities.disenchant.name .. "\n/use " .. bag .. " " .. slot);
			return
		end
	end

	if GBManager.abilities.pickLock.known then

		GBManager.Button:SetAttribute("macrotext", GBManager.Button.DefaultMacro .. "\n/cast " .. GBManager.abilities.pickLock.name);
		return
	end

	if GBManager.abilities.prospecting.known then

		GBManager.Button:SetAttribute("macrotext", GBManager.Button.DefaultMacro .. "\n/cast " .. GBManager.abilities.prospecting.name);
		return
	end

	if GBManager.abilities.disenchant.known then

		GBManager.Button:SetAttribute("macrotext", GBManager.Button.DefaultMacro .. "\n/cast " .. GBManager.abilities.disenchant.name);
		return
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

GBManager.GetNextDisenchantableBagSlot = function()
	
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do

			local _, _, _, _, _, _, itemLink = GetContainerItemInfo(bag,slot)
			if itemLink then

				local match, vendor = GBManager.IsDisenchantMatch(itemLink)
				if match and not vendor then

					return bag, slot
				end
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
				local itemName, _, itemQuality, itemLevel, requiredLevel, itemType, itemSubType, itemStackCount, _, _, itemSellPrice = GetItemInfo(itemLink)
				local playerLevel = UnitLevel("PLAYER")
				local _, vendor = GBManager.IsDisenchantMatch(itemLink)

				if vendor then

					GBManager.Sell(bag, slot)

				elseif itemQuality == 0 then
					
					GBManager.SellOrDestroy(bag, slot)
				
				elseif itemType == "Consumable" and itemSubType == "Food & Drink" and (playerLevel - requiredLevel) > 15 then

					GBManager.SellOrDestroy(bag, slot)

				elseif GBManager.items[itemName] then

					GBManager.SellOrDestroy(bag, slot)
					
				elseif lootable and not GBManager.IsLocked(bag, slot) then
					
					GBManager.OpenContainer(bag, slot)
				end
			end
		end
	end
end

GBManager.SellOrDestroy = function(bag, slot)
	
	local _, _, _, _, _, _, itemLink, _, _ = GetContainerItemInfo(bag,slot)
	local itemName, _, _, _, _, _, _, itemStackCount, _, _, itemSellPrice = GetItemInfo(itemLink)
	local stackValue = itemStackCount * itemSellPrice

	if not GBManager.Sell(bag, slot) then
		if GBManager.items[itemName] or itemStackCount * itemSellPrice < GBManager.config.minimumValue then

			GBManager.Chat:AddMessage("|cFF8789B3GBM|r destroying: " .. itemLink)
			PickupContainerItem(bag, slot)
			DeleteCursorItem()
		end
	end
end

GBManager.Sell = function(bag, slot)
	
	local _, _, _, _, _, lootable, itemLink, _, noValue = GetContainerItemInfo(bag, slot)

	if GBManager.merchantOpen and not lootable and not noValue then

		GBManager.Chat:AddMessage("|cFF8789B3GBM|r vendoring: " .. itemLink)
		UseContainerItem(bag, slot)

		return true
	end

	return false
end

GBManager.OpenContainer = function(bag, slot)

	if not GBManager.merchantOpen then
		
		UseContainerItem(bag, slot)
	end
end