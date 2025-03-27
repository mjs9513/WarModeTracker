--TODOS:
--create method to clear war cache text, call it when zoning. Also clear war chest data when zone changes
--Create Update functions for each class in general? Treat it like OOP?
--Try creating OOP based class objects inside of local namespace? Very securely attach to addon?
--MOVE NOTIFICATIONUTILS ABOVE GLOBAL UTILS?

local addOnName, namespace = ...

--registers all necessary events for the OnEvent update script
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

--ToDo: Rename to be referencing that it updates on events firing off
--Script fired off during events. Update style method
local function OnWarUpdates(_, event, arg1, arg2, arg3, arg4)
	--Player entering world, initialize the addon
	if (event == "PLAYER_ENTERING_WORLD") then
		--Initialize PvPTools, loads in PvP Stats from the character
		namespace.PvPToolsInitialize();
		
		
		
		--TODO: MOVE TO AN INITIALIZE FRAMES METHOD ON WARMODEFRAMES.LUA
		namespace.InitializeMainFrame() -- set the show status of the frames and elements
		namespace.SetLastKillStreakText("Last Kill Streak: " .. LastWarKills);
		--Set the panel text
		namespace.SetTrackerTexts();
		--Load the text color
		namespace.SetFrameTextColors();
		--setup the main panel background
		namespace.SetFrameBackgrounds();

		
		
		--Initialize the addon setting menu
		namespace.InitializeAddonMenu();

		--ajust the frames as needed
		namespace.AdjustCacheFramePos() --ToDo: look into this, can it be condensed
		--register the wmt prefix
		namespace.InitializeAddonMessages()
		
		namespace.SearchForBounties() --Initial kickoff call to search for bounties in the area
	end
	
	if (event == "PLAYER_DEAD") then
		namespace.PvPToolsOnPlayerDeath();
	end
	if (event == "PLAYER_PVP_KILLS_CHANGED") then
		namespace.PvPToolsUpdateKills();
	end
	
	if (event == "VIGNETTES_UPDATED") then
		namespace.SearchForBounties()
		--ToDo: Check for WarCache spawning?
	end

	if (event=="COMBAT_LOG_EVENT_UNFILTERED") then
		namespace.CheckForKillingBlows();
	end
	
	if (event=="PLAYER_REGEN_DISABLED") then
		namespace.WarCombatState = true
		namespace.OnCombatEnter();
	end
	if (event=="PLAYER_REGEN_ENABLED") then
		namespace.WarCombatState = false
		namespace.OnCombatExit();
	end
	if(event=="ZONE_CHANGED_NEW_AREA") then
		namespace.PvPToolsOnZoneChanged();
		namespace.SetTrackerTexts();
	end
	if(event=="ZONE_CHANGED") then
		namespace.PvPToolsOnZoneChanged();
		namespace.WarModeFramesOnZoneChanged();
		namespace.SetTrackerTexts();
	end
	
	if(event=="CURSOR_CHANGED") then
		--Call the scan for chests function from WarChestTools
		namespace.ScanForChests();
	end
	
	--if the client sees a message with wmt, process that message and update accordingly
	if (event=="CHAT_MSG_ADDON") then
		namespace.ParseAddonMessage(arg1, arg2)
	end
	
	--when the channel_ui_upate event fires, if the number of channels the player is in is greater than 0
	--check if they are in the WMT channel, if they aren't join and initialize messages, if they are disable it and unregister this event
    if(event=="CHANNEL_UI_UPDATE") then
		namespace.CheckAndJoinAddonChannel();
	end
end
--Register the OnEvent update function to warTrackFrame
warTrackFrame:SetScript("OnEvent", OnWarUpdates)

--Re register frame creation, checks for current bounty status and updates the panel if bountied, and checks for the PVP kill event being unregistered in main frame and reregisters (avoids multi firing events)
--Also updates the notification text, elapsed is the number of seconds taken between each frame. Subtracts that from the timer and when the timer is below 0, stops displaying the text. Else text is displayed
local reReg = CreateFrame("Frame")

reReg:SetScript("OnUpdate", function(_, elapsed)
	--ToDo: Limit it so this only runs if in the outdoor world?
	--ToDo: Create Bounty Tools class?
	if(namespace.IsBountied() == true )then
		namespace.SetBountyStatus(namespace.CurrentBountyStatus);
		if (namespace.CanAlertBountied == true) then
			namespace.SetNotificationText("A BOUNTY HAS BEEN PLACED ON YOUR HEAD", 6)
			namespace.CanAlertBountied = false
		end
	end
	
	--is the pvp kills change event is not registered, re-registers it
	if (warTrackFrame:IsEventRegistered("PLAYER_PVP_KILLS_CHANGED") == false) then
		warTrackFrame:RegisterEvent("PLAYER_PVP_KILLS_CHANGED")
	end

	--Call update functions for notifications and war chest tools
	namespace.UpdateNotifications(elapsed);
	namespace.UpdateWarChestTools(elapsed);
	
	--checks in the notifcation button is set to false. If it is then also sets the play sound notification button to false as well.
	if (namespace.ToggleNotificationsButton ~= nil and namespace.ToggleNotificationsButton:GetChecked() == false) then
		if(namespace.ToggleSoundNotificationsButton ~= nil) then
			namespace.ToggleSoundNotificationsButton:SetChecked(false)
		end
		PlayWarTrackWarningNotification = false;
	end
	
	--Checks to see if warHidePvPStates is true, if it is then checks if war mode is active. If it isnt, it checks if the frames are showing, if they are hides them. This is for hiding frames when war mode is inactive
	--also checks if the player is in combat or not with warCombatState which is set in the event registers section when the player enters/exists combat
	if(WarHidePvPState == true) then
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
	
	if (CacheTrackerState == false) then
		if (WarCacheFrame:IsShown() == true) then
			WarCacheFrame:Hide()
		end
	end
	
	--sets the never reset button to active is all other buttons are off.
	if(KillingBlowResetDeath == false and KillingBlowResetLoad == false and KillingBlowResetZone == false) then
		NeverResetButton:SetChecked(true)
	end
end)
