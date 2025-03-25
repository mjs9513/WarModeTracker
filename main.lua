local addOnName, namespace = ...
--stores current number of kills
warKills = 0;

--gets the name of the player
local PLAYER_NAME = GetUnitName("player", false)

--stores the number of killing blows
totalWarKillingBlows = 0
--stores if you have a bounty
bountyCount = nil;
--string for bounty status
currBounty = "INACTIVE";
--container for last killing streak
lastWarKills = 0;
--container for highest killing streak
highestWarKills = 0;

--Gets the player's PvP honor level
pvpWarRank = UnitHonorLevel("player")
--Gets the players total honorable kills
local lastTotalWarKills, _,_ = GetPVPLifetimeStats();
--Gets the player's faction
local playerFaction = UnitFactionGroup("player");

--timer for the notification of bounties to display on screen
local notificationTimer = 0

--boolean used to track if the player has gained a bounty
checkSelfNotification = true
--Two booleans to track whether or not the text for the bounty notification, and the accompanying sound, should play
showWarTrackWarningNotification = true
playWarTrackWarningNotification = true

--two booleans for tracking whether the window is hidden or show in combat or when not in war mode
warHidePvPState = false
warHideCombatState = false
--Boolean for checking whether or not the player is in combat, specifically used for when hide in combat is checked and hide when not in war mode is unchecked
warCombatState = false

--variable for tracking the state in which killing blows will reset: 1 - Death, 2 - Zone change, 3 - Loading Screen
killingBlowResetDeath = false;
killingBlowResetZone = true;
killingBlowResetLoad = true;

--Library that stores button states
FrameStates = {
	["MainFrame"] = true,
	["warBountiesState"] = true,
	["lockFrameState"] = false,
	["logoState"] = true,
	["warPvPState"] = true,
	["currKillState"] = true,
	["currBountyState"] = true,
	["lastKillState"] = true,
	["highestWarKillState"] = true,
	["totalKillState"] = true,
}
killingBlowState = true;
cacheTrackerState = true;

warcacheParty = true;
warcacheGeneral = false;

wmtWarCacheText = "War Cache Located - " .. 0 ..  " - " .. 0 .. " - " .. "No Zone"
wmtLastCacheText = "War Cache Located - " .. 0 ..  " - " .. 0 .. " - " .. "No Zone"
local wmtPrefCheck;

--variable for storing the timer for the War Caches
local wmtCacheTimer = 0;

--variable for storing the name of the last check moused over by the player
local warChestType = " ";

--Checks if the player is bountied. AuraUtil.FindAuraByName searches the player for a specified buff/debuff. Third parameter is the filter (one string separated by spaces), its very specific
--also sets checkSelfNotification to true if they dont have a bounty so the addon re-checks for the next bounty occurence
function IsBountied()
	bountyCount = AuraUtil.FindAuraByName("Bounty Hunted", "player", "NOT_CANCELABLE HARMFUL")
	if (bountyCount ~= nil) then
		currBounty = "ACTIVE"
		else
		currBounty = "INACTIVE"
		checkSelfNotification = true
	end
end

function AdjustWMTChannelPos()
	if(GetChannelName("WMT") == 1) then
		local numChannels = C_ChatInfo.GetNumActiveChannels();
		for i=0,numChannels,1 do
			C_ChatInfo.SwapChatChannelsByChannelIndex(GetChannelName("WMT"), GetChannelName("WMT")+1);
		end
	end
end

--reads in and parses the War Cache Messages. If nil values, sets to 0s and throw aways
--if the zones are different, its a new war chest and updates appropriately
--if the location is 15 different in X or Y, its a new chest and updates it
function ParseWarCacheMessage(oldCache, newCache)
	local newMessage, newX, newY, newZoneName = strsplit("-", newCache)
	local oldMessage, oldX, oldY, oldZoneName = strsplit("-", oldCache)
	local currZone = GetZoneText()
	if (oldX == nil) then
		oldX = 0
	end
	if (oldY == nil) then
		oldY = 0
	end
	if (oldMessage == nil) then
		oldMessage = "Blank Message"
	end
	if(oldZoneName == nil) then
		oldZoneName = "No Zone"
	end
	currZone = string.gsub(currZone, " ", "");
	newZoneName = string.gsub(newZoneName, " ", "");
	oldZoneName = string.gsub(oldZoneName, " ", "");
	if (newZoneName ~= oldZoneName or newZoneName ~= currZone) then
		wmtLastCacheText = newCache
	 	wmtWarCacheText = newCache
		warCacheText:SetText("War Chest Spotted Near: " .. newX .. ", " .. newY)
		wmtCacheTimer = 200
		SetNotificationText("A WAR CHEST HAS BEEN SPOTTED", 6)
		return true;
	end
	if (((tonumber(newX) >= tonumber(oldX) + 15) or (tonumber(newX) <= tonumber(oldX) - 15)) or ((tonumber(newY) >= tonumber(oldY) + 15) or (tonumber(newY) <= tonumber(oldY) - 15))) then
		wmtLastCacheText = newCache
		wmtWarCacheText = newCache
		warCacheText:SetText("War Chest Spotted Near: " .. newX .. ", " .. newY)
		wmtCacheTimer = 200
		SetNotificationText("A WAR CHEST HAS BEEN SPOTTED", 6)
		return true;
	end
end

--Script fired off during events. Primary purpose is to set variables/text
local function OnWarUpdates(_, event, arg1, arg2, arg3, arg4)
	if (event == "PLAYER_ENTERING_WORLD") then
		--get the total honor kills and pvp rank
		TotalWarKills = GetPVPLifetimeStats();
		lastTotalWarKills = GetPVPLifetimeStats();
		pvpWarRank = UnitHonorLevel("player")
		--Reset war kills
		if (warKills ~= 0) then
		lastWarKills = warKills
		warKills = 0;
		end
		--reset killing blows
		if(killingBlowResetLoad == true) then
			totalWarKillingBlows = 0
		end
		
		namespace.SetLastKillStreakText("Last Kill Streak: " .. lastWarKills);

		--Set the panel text
		namespace.SetTrackerTexts();
		--Load the text color
		namespace.SetFrameTextColors();
		--setup the main panel background
		namespace.SetFrameBackgrounds();

		--Initialize the addon setting menu
		namespace.InitializeAddonMenu();
		

		InitializeMainFrame() -- set the show status of the frames and elements
		SetSettingsButtonStates() -- set the button check statuses

		--ajust the frames as needed
		AdjustCacheFramePos()
		--register the wmt prefix
		wmtPrefCheck = C_ChatInfo.RegisterAddonMessagePrefix("wmt:")
		AdjustWMTChannelPos()
		namespace.SearchForBounties()
	end
	if (event == "PLAYER_DEAD") then
		if (highestWarKills < warKills) then
			highestWarKills = warKills
		end
		lastWarKills = warKills
		warKills = 0
		if(killingBlowResetDeath == true) then
			totalWarKillingBlows = 0
		end
		SetTrackerTexts()
	end
	if (event == "PLAYER_PVP_KILLS_CHANGED") then
		TotalWarKills = GetPVPLifetimeStats();
		warKills = warKills + (TotalWarKills - lastTotalWarKills)
		lastTotalWarKills = TotalWarKills;
		if (highestWarKills <= warKills) then
			highestWarKills = warKills
		end
		pvpWarRank = UnitHonorLevel("player");
		SetTrackerTexts()
		warTrackFrame:UnregisterEvent("PLAYER_PVP_KILLS_CHANGED");
	end
	if (event == "VIGNETTES_UPDATED") then
	namespace.SearchForBounties()
--	setWarTrackText()
	end


	if (event=="COMBAT_LOG_EVENT_UNFILTERED") then
	local _,warEventType, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _ = CombatLogGetCurrentEventInfo()
		if(warEventType=="PARTY_KILL") then
		local warUnitType = strsplit("-", destGUID)
		if (warUnitType == "Player" and PLAYER_NAME == sourceName)then
				totalWarKillingBlows = totalWarKillingBlows + 1
				SetTrackerTexts()
			end
		end
	end





	if (event=="PLAYER_REGEN_DISABLED") then
		warCombatState = true
		if (warHideCombatState == true) then
			WarGhostFrame:Hide();
			if(FrameStates.MainFrame == true) then
				warTrackFrame:Hide()
			end
			if(FrameStates.warBountiesState == true) then
				WarBountiesFrame:Hide()
			end
			if(cacheTrackerState == true) then
				WarCacheFrame:Hide()
			end
		end
	end
	if (event=="PLAYER_REGEN_ENABLED") then
		warCombatState = false
		WarGhostFrame:Show();
		if(FrameStates.MainFrame == true) then
				warTrackFrame:Show()
		end
		if(FrameStates.warBountiesState == true) then
			WarBountiesFrame:Show()
		end
		if(cacheTrackerState == true) then
			WarCacheFrame:Show()
		end
	end
	if(event=="ZONE_CHANGED_NEW_AREA") then
		if(killingBlowResetZone == true) then
			totalWarKillingBlows = 0
		end
		namespace.SearchForBounties()
		SetTrackerTexts()


	end
	if(event=="ZONE_CHANGED") then
		--show war track frame if its not currently showing and warhidepvpstate is false
		if(warHidePvPState == true) then
			WarGhostFrame:Show()
			if (C_PvP.IsWarModeActive() == true) then
				if (warTrackFrame:IsShown() == false) then
					warTrackFrame:Show()
				end
				if(WarBountiesFrame:IsShown() == false) then
					WarBountiesFrame:Show()
				end
				if(WarCacheFrame:IsShown() == false) then
					WarCacheFrame:Show()
				end
			end
		end
	end


	if(event=="CURSOR_CHANGED") then
		local testText = _G["GameTooltipTextLeft"..1]
		local textExtractor = testText:GetText()
			if(textExtractor == "War Supply Chest" or textExtractor == "Secret Supply Chest" or textExtractor == "War Supply Crate") then
					if (cacheTrackerState == true) then
					local posX, posY = C_Map.GetPlayerMapPosition(C_Map.GetBestMapForUnit("player"), "player"):GetXY()
					posX = math.floor(posX * 100)
					posY = math.floor(posY * 100)
					local zoneName = GetZoneText()
					wmtWarCacheText = "War Cache Located - " .. posX ..  " - " .. posY .. " - " .. zoneName;
					warChestType = textExtractor;
					textExtractor = " "
				end
			end
		end
--if the messages are inconsistent with each other
		if(wmtLastCacheText ~= wmtWarCacheText) then
				if (cacheTrackerState == true) then
				local posX, posY = C_Map.GetPlayerMapPosition(C_Map.GetBestMapForUnit("player"), "player"):GetXY()
				posX = math.floor(posX * 100)
				posY = math.floor(posY * 100)
				local id,channelName = GetChannelName("WMT")
        if (id > 0 and channelName ~= nil and notificationTimer <= 0) then
        C_ChatInfo.SendAddonMessage("wmt:", wmtWarCacheText, "CHANNEL", id)
        C_ChatInfo.SendAddonMessage("wmt:", wmtWarCacheText, "RAID")
        end
        --IF THE USER CURRENTLY DOES NOT HAVE AN ACTIVE WAR CHEST LOADED IN THEIR FRAME
        if (warCacheText:GetText() == "NO ACTIVE WAR CHESTS") then
					--if they set to notify party, notify party on the mouseover
					if(warcacheParty == true) then
	          if (IsInRaid()) then
	            SendChatMessage("WMT: " .. warChestType .. " located near " .. posX .. ", " .. posY, "RAID")
	          else
	            if (IsInGroup()) then
	              SendChatMessage("WMT: " .. warChestType .. " located near " .. posX .. ", " .. posY, "PARTY")
	            end
	          end
					end
					--if set to notify general, notify general on the mouseover
					if(warcacheGeneral == true) then
						local wmtChatIndex = GetChannelName("General")
						local wmtChatNewIndex = GetChannelName("General - " .. GetZoneText())
						if (wmtChatIndex~=nil and wmtChatIndex ~= 0) then
							SendChatMessage("WMT: " .. warChestType .. " located near " .. posX .. ", " .. posY, "CHANNEL", nil, wmtChatIndex)
						else
							if(wmtChatNewIndex ~= nil) then
								SendChatMessage("WMT: " .. warChestType .. " located near " .. posX .. ", " .. posY, "CHANNEL", nil, wmtChatNewIndex)
							end
						end

					end
        end
				wmtLastCacheText = wmtWarCacheText
				warCacheText:SetText("War Chest Spotted Near: " .. posX .. ", " .. posY)
				wmtCacheTimer = 200
			end
		end
		--if the client sees a message with wmt, process that message and update accordingly
		if (event=="CHAT_MSG_ADDON") then
			if (arg1 == "wmt:") then
				if (cacheTrackerState == true) then
					local message, locX, locY, zoneName = strsplit("-", arg2)
					local currZone = GetZoneText()
					currZone = string.gsub(currZone, " ", "");
					zoneName = string.gsub(zoneName, " ", "");
					if (tostring(currZone) == tostring(zoneName)) then
						ParseWarCacheMessage(wmtLastCacheText, arg2)
					end
				end
			end
		end

		--when the channel_ui_upate event fires, if the number of channels the player is in is greater than 0
		--check if they are in the WMT channel, if they aren't join, if they are disable it and unregister this event
    if(event=="CHANNEL_UI_UPDATE") then
			if(GetNumDisplayChannels() >= 3) then
      --join the WMT CHANNEL
			if(GetChannelName("WMT") == 0) then
	      JoinTemporaryChannel("WMT",nil, 4, nil)
			end
			AdjustWMTChannelPos();
			--Check to make sure it isnt listed as the first channel, if it is make it the last one
      RemoveChatWindowChannel(0, "WMT")
      ChatFrame_RemoveChannel(DEFAULT_CHAT_FRAME, "WMT")
      warTrackFrame:UnregisterEvent("CHANNEL_UI_UPDATE") -- unregister so it only runs once
		end
  end
end
--registers all necessary events and sets the script
warTrackFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
warTrackFrame:RegisterEvent("PLAYER_DEAD")
warTrackFrame:RegisterEvent("PLAYER_PVP_KILLS_CHANGED")
warTrackFrame:RegisterEvent("VIGNETTES_UPDATED")
warTrackFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
warTrackFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
warTrackFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
warTrackFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
warTrackFrame:RegisterEvent("ZONE_CHANGED")
warTrackFrame:RegisterEvent("CURSOR_CHANGED")
warTrackFrame:RegisterEvent("CHAT_MSG_ADDON")
warTrackFrame:RegisterEvent("CHANNEL_UI_UPDATE")
warTrackFrame:SetScript("OnEvent", OnWarUpdates)

--Re register frame creation, checks for current bounty status and updates the panel if bountied, and checks for the PVP kill event being unregistered in main frame and reregisters (avoids multi firing events)
--Also updates the notification text, elapsed is the number of seconds taken between each frame. Subtracts that from the timer and when the timer is below 0, stops displaying the text. Else text is displayed
local reReg = CreateFrame("Frame")
reReg:SetScript("OnUpdate", function(_, elapsed)
IsBountied()
if (currBounty == "ACTIVE")then
currBountyText:SetText("Bounty Status: " .. currBounty)
	if (checkSelfNotification == true) then
	SetNotificationText("A BOUNTY HAS BEEN PLACED ON YOUR HEAD", 6)
	checkSelfNotification = false
	end
end
--is the pvp kills change event is not registered, re-registers it
if (warTrackFrame:IsEventRegistered("PLAYER_PVP_KILLS_CHANGED") == false) then
warTrackFrame:RegisterEvent("PLAYER_PVP_KILLS_CHANGED")
end
--if the notification timers are not 0, then shows the notification. If its less than 1 then it hides it. While its not 0 it subtracts from it
if (notificationTimer ~= 0) then
	if (notificationTimer > 1) then
	ShowNotificationText()
	else
	HideNotificationText()
	end
notificationTimer = notificationTimer - elapsed
end

--if the war cache timer is not 0, then count down till its 0 then reset it
if (wmtCacheTimer ~= 0) then
	if (wmtCacheTimer < 1) then
		ResetCacheText()
	end
wmtCacheTimer = wmtCacheTimer - elapsed
end

--checks in the notifcation button is set to false. If it is then also sets the play sound notification button to false as well.
if (namespace.ToggleNotificationsButton ~= nil and namespace.ToggleNotificationsButton:GetChecked() == false) then
	if(namespace.ToggleSoundNotificationsButton ~= nil) then
		namespace.ToggleSoundNotificationsButton:SetChecked(false)
	end
playWarTrackWarningNotification = false;
end

--Checks to see if warHidePvPStates is true, if it is then checks if war mode is active. If it isnt, it checks if the frames are showing, if they are hides them. This is for hiding frames when war mode is inactive
--also checks if the player is in combat or not with warCombatState which is set in the event registers section when the player enters/exists combat

if(warHidePvPState == true) then
	if (C_PvP.IsWarModeActive() == false) then
		WarGhostFrame:Hide()
		if (warTrackFrame:IsShown() == true) then
			warTrackFrame:Hide()
		end
		if(WarBountiesFrame:IsShown() == true) then
			WarBountiesFrame:Hide()
		end
		if(WarCacheFrame:IsShown() == true) then
			WarCacheFrame:Hide()
		end
	end
end

if (FrameStates.MainFrame == false) then
	if (warTrackFrame:IsShown() == true) then
		warTrackFrame:Hide()
	end
end

if (FrameStates.warBountiesState == false) then
	if (WarBountiesFrame:IsShown() == true) then
		WarBountiesFrame:Hide()
	end
end

if (cacheTrackerState == false) then
	if (WarCacheFrame:IsShown() == true) then
		WarCacheFrame:Hide()
	end
end

--sets the never reset button to active is all other buttons are off.
	if(killingBlowResetDeath == false and killingBlowResetLoad == false and killingBlowResetZone == false) then
		NeverResetButton:SetChecked(true)
	end

end)
