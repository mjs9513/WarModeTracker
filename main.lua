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
--scale size for the WMT frame set
wmtFrameScale = 1;
-- RGB holders for the WarTrackFrame text
warTextR = 1;
warTextG = 1;
warTextB = 1;
--RGBA holders for the WarTrackFrame background
warFrameR = .1;
warFrameG = .1;
warFrameB = .1;
warFrameTransparency = 0.7;
--Gets the player's PvP honor level
pvpWarRank = UnitHonorLevel("player")
--Gets the players total honorable kills
local totalWarKills, _,_ = GetPVPLifetimeStats();
local lastTotalWarKills, _,_ = GetPVPLifetimeStats();
--Gets the player's faction
local playerFaction = UnitFactionGroup("player");

--Table that will store the names of every bountied enemy in the zone, later converetd to list in variable belwo
local enemyWarBounties = {}

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
warShowStates = {
	["warFrameState"] = true,
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
function isBountied()
	bountyCount = AuraUtil.FindAuraByName("Bounty Hunted", "player", "NOT_CANCELABLE HARMFUL")
	if (bountyCount ~= nil) then
		currBounty = "ACTIVE"
		else
		currBounty = "INACTIVE"
		checkSelfNotification = true
	end
end

--returns the number of items within a 'source' table, TEST FUNCTION
function active_items(source)
	 return table.getn(source);
end

--CREATING GHOST Frame
warTrackGhost = CreateFrame("Frame", "WarGhostFrame", UIParent)
warTrackGhost:SetWidth(208) -- sets the width
warTrackGhost:SetHeight(100)  -- sets height
--these lines enable movement via mouse draggins
warTrackGhost:SetMovable(true)
warTrackGhost:EnableMouse(true)
warTrackGhost:RegisterForDrag("LeftButton")
warTrackGhost:SetUserPlaced(true)
--allows the mouse to be moved by the mouse
warTrackGhost:SetScript("OnDragStart", warTrackGhost.StartMoving)
warTrackGhost:SetScript("OnDragStop", warTrackGhost.StopMovingOrSizing)
warTrackGhost:SetFrameStrata("LOW")
WarGhostFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0);

-- Creating the main frame
warTrackFrame = CreateFrame("Frame", "WarModeFrame", warTrackGhost, "BackdropTemplate")
warTrackFrame:SetFrameStrata("BACKGROUND")
warTrackFrame:SetWidth(208) -- sets the width
warTrackFrame:SetHeight(100)  -- sets height

--creation of the war bounties tracker frame
warBountiesFrame = CreateFrame("Frame", "WarBountiesFrame", UIParent, "BackdropTemplate")
warBountiesFrame:SetFrameStrata("BACKGROUND")
warBountiesFrame:SetWidth(208) -- sets the width
warBountiesFrame:SetHeight(75) -- sets the height
warBountiesFrame:SetMovable(false)
warBountiesFrame:EnableMouse(true)
warBountiesFrame:SetPoint("BOTTOM", warTrackFrame, "BOTTOM", 0, -73) -- the y value was -86 before the addition of the killing blow tracker

--CREATE THE FRAME FOR WAR CACHE NOTICIATION
warCacheFrame = CreateFrame("Frame", "WarCacheFrame", UIParent, "BackdropTemplate")
warCacheFrame:SetFrameStrata("BACKGROUND")
warCacheFrame:SetWidth(208) -- sets the width
warCacheFrame:SetHeight(35) -- sets the height
warCacheFrame:SetMovable(false)
warCacheFrame:EnableMouse(true)

--adjust the frames such that the war cache frame snaps down to the bounty frames
--uses the GhostFrame to enable continuous movement
function AdjustCacheFramePos()
	if(warShowStates.warFrameState == true) then
		warCacheFrame:SetPoint("Center", warTrackFrame, "Center", 0, 65)
		if(active_items(enemyWarBounties) ~= nil and active_items(enemyWarBounties) ~= 0) then
			warBountiesFrame:SetPoint("BOTTOM", warTrackFrame, "BOTTOM", 0, -73)
		else
			warBountiesFrame:SetPoint("BOTTOM", warTrackFrame, "BOTTOM", 0, -18)
		end
		WarGhostFrame:SetHeight(160);
	else
			if(warShowStates.warBountiesState == true) then
				if(active_items(enemyWarBounties) ~= nil and active_items(enemyWarBounties) ~= 0) then
					warBountiesFrame:SetPoint("BOTTOM", warCacheFrame, "Center", 0, -90);
					else
					warBountiesFrame:SetPoint("BOTTOM", warCacheFrame, "Center", 0, -35);
				end
				warCacheFrame:SetPoint("TOP", WarGhostFrame, "TOP", 0, 0)
				WarGhostFrame:SetHeight(100);
			end
		end
	end

--sets whether or not the faction banner is that of the alliance or horde
local warFactBanner = warTrackFrame:CreateTexture(nil,"ARTWORK")
if (playerFaction == "Alliance") then
	warFactBanner:SetTexture("Interface\\Timer\\Alliance-Logo.blp")
else
	warFactBanner:SetTexture("Interface\\Timer\\Horde-Logo.blp")
end

--Creating the background image for the frames, bg file is the background file it will call from
--edgefile is the border file it will call from, tile is whether the bg image is tiled or stretched out
--edge size is the size of the edge, basicall border thickness
--insets is think the dimensions in which the background will draw by. Idea is take edge size and divide by 4 for each.
function warTrackFrameSet()
warTrackFrame:SetBackdrop( {
	bgFile = "Interface/Tooltips/UI-Tooltip-Background",
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
	tile = false, edgeSize = 10,
	insets = {left = 2.5, right = 2.5, top = 2.5, bottom = 2.5}});
warTrackFrame:SetBackdropColor(warFrameR, warFrameG, warFrameB, warFrameTransparency);
warTrackFrame:SetBackdropBorderColor(1, 1, 1)

warBountiesFrame:SetBackdrop( {
	bgFile = "Interface/Tooltips/UI-Tooltip-Background",
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
	tile = false, edgeSize = 10,
	insets = {left = 2.5, right = 2.5, top = 2.5, bottom = 2.5}});
warBountiesFrame:SetBackdropColor(warFrameR, warFrameG, warFrameB, warFrameTransparency);
warBountiesFrame:SetBackdropBorderColor(1, 1, 1)

warCacheFrame:SetBackdrop( {
	bgFile = "Interface/Tooltips/UI-Tooltip-Background",
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
	tile = false, edgeSize = 10,
	insets = {left = 2.5, right = 2.5, top = 2.5, bottom = 2.5}});
warCacheFrame:SetBackdropColor(warFrameR, warFrameG, warFrameB, warFrameTransparency);
warCacheFrame:SetBackdropBorderColor(1, 1, 1)

end

--text for honor level
local warHonorLvlText = warTrackFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
warHonorLvlText:SetPoint("CENTER", warFactBanner, "TOP", 0, -8)


--text for number of current kills
local warEnemiesText = warTrackFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
warEnemiesText:SetPoint("TOP", warTrackFrame, "TOP", 25, -5)

--text for tracking killing blows
local warTotalKillingBlowsText = warTrackFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
warTotalKillingBlowsText:SetPoint("CENTER", warEnemiesText, "TOP", 3, -21)

--text for the last kill streak
local warLastText = warTrackFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
warLastText:SetPoint("CENTER", warTotalKillingBlowsText, "TOP", 0, -21)



--text for highest number of kills
local highestEnemiesText = warTrackFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
highestEnemiesText:SetPoint("CENTER", warLastText, "TOP", 1, -21)



--text for tracking bounty status
local currBountyText = warTrackFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
currBountyText:SetPoint("CENTER", highestEnemiesText, "TOP", 2, -21)


--text for total number of kills on a character, adjusts the position based on the number for fitting purposes
local totalEnemiesText = warTrackFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
if (totalWarKills <= 1000) then
totalEnemiesText:SetPoint("CENTER", highestEnemiesText, "TOP", 0, -38)
else
	if (totalWarKills <= 10000) then
	totalEnemiesText:SetPoint("CENTER", highestEnemiesText, "TOP", -2, -38)
	else
	totalEnemiesText:SetPoint("CENTER", highestEnemiesText, "TOP", -8, -38)
	end
end



--positions the faction banner within the frame
warFactBanner:SetPoint("LEFT", warTrackFrame, "LEFT", -15, -5)
warFactBanner:SetWidth(100)
warFactBanner:SetHeight(100)

--sets the intiial point for warTrackFrame
warTrackFrame:SetPoint("CENTER", WarGhostFrame, "CENTER", 0, 0);
warTrackFrame:Show()
warBountiesFrame:Show()

--text for displaying the total number of bounties active
local currNumEnemyBounties = warBountiesFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
currNumEnemyBounties:SetPoint("CENTER", warBountiesFrame, "TOP", 0, -9)

--text for displaying the total number of bounties active
local enemyBountiesText = warBountiesFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
enemyBountiesText:SetPoint("CENTER", currNumEnemyBounties, "CENTER", -51, -30)
enemyBountiesText:SetText("Enemy Bounties: ")

--text for displaying the coords for a war CACHE
local warCacheText = warCacheFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
warCacheText:SetPoint("CENTER", warCacheFrame, "CENTER", 0, 0)
warCacheText:SetText("NO ACTIVE WAR CHESTS")

--Add the text to show enemy player names with bounties
local playerBountiesText = warBountiesFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
playerBountiesText:SetPoint("CENTER", currNumEnemyBounties, "CENTER", 40, -30)
playerBountiesText:SetWidth(110)
playerBountiesText:SetHeight(60)

--setup for the text that displays the bounty notifications on screen
local warModeNotificationText = warBountiesFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
warModeNotificationText:SetPoint("CENTER", UIParent,"TOP", 0, -125)
warModeNotificationText:SetText(" ")
warModeNotificationText:SetFont("Fonts\\FRIZQT__.TTF", 35)
warModeNotificationText:SetTextColor(1, .20, .20)
warModeNotificationText:Hide()

--function that sets the notification text, and the timer for which the notification text will display
function setWMTNotificationText(message, timer)
if (showWarTrackWarningNotification == true) then
		warModeNotificationText:SetText(message)
		if(playWarTrackWarningNotification == true) then
			PlaySoundFile(543587)
		end
		notificationTimer = timer
	end
end

--function for showing bounty notification text
function showNotificationText()
	warModeNotificationText:Show()
end

--function for hiding the notification text
function hideNotificationText()
	warModeNotificationText:Hide()
end

--resets the text for the War Cache Tracker
function ResetCacheText()
	warCacheText:SetText("NO ACTIVE WAR CHESTS")
end

--function for specifying whether the war frame is hidden or shown
function ShowWarFrame(frameState)
	if (frameState == true) then
	warTrackFrame:SetShown(true)
	else
	warTrackFrame:SetShown(false)
	end
end

--function for specifying whether the bounties frame is hidden or shown
function ShowBountyFrame(frameState)
	if (frameState == true) then
	warBountiesFrame:Show()
	else
	warBountiesFrame:Hide()
	end
end

--function for specifying whether the faction banner is hidden or shown
function showWarLogo(warLogoState)
	if (warLogoState == true) then
	warFactBanner:Show()
	else
	warFactBanner:Hide()
	end
end

--function for specifying whether the player pvp level is hidden or shown
function showWarPvPLevel(pvpLvlState)
	if (pvpLvlState == true) then
	warHonorLvlText:Show()
	else
	warHonorLvlText:Hide()
	end
end

--function for specifying whether the current enemy kill count is hidden or shown
function showWarCurrKill(currKillState)
	if (currKillState == true) then
	warEnemiesText:Show()
	else
	warEnemiesText:Hide()
	end
end

--function for specifying whether the last kill streak is hidden or shown
function showWarLastKill(lastKillState)
	if (lastKillState == true) then
	warLastText:Show()
	else
	warLastText:Hide()
	end
end

--function for specifying whether the highest kill streak is hidden or shown
function showWarHighestKill(highestKillState)
	if (highestKillState == true) then
	highestEnemiesText:Show()
	else
	highestEnemiesText:Hide()
	end
end

--function for specifying whether the bounty active/inactive text is hidden or shown
function showWarCurrBounty(currBountyState)
	if (currBountyState == true) then
	currBountyText:Show()
	else
	currBountyText:Hide()
	end
end

--function for specifying whether the total kill count is hidden or shown
function showWarTotalKill(totalKillState)
	if (totalKillState == true) then
	totalEnemiesText:Show()
	else
	totalEnemiesText:Hide()
	end
end

--function for specifying whether the main frame is movable or not. is hidden or shown
function showLockFrameState(lockState)
	if (lockState == false) then
	WarGhostFrame:EnableMouse(true)
	warBountiesFrame:EnableMouse(true)
	warCacheFrame:EnableMouse(true)
	else
	WarGhostFrame:EnableMouse(false)
	warBountiesFrame:EnableMouse(false)
	warCacheFrame:EnableMouse(false)
	end
end

function showWarKillingblow(killingState)
	if (killingState == true) then
	warTotalKillingBlowsText:Show()
	else
	warTotalKillingBlowsText:Hide()
	end
end

--function for setting the visible state of the War Cache Tracker
function showCacheTracker(cacheTrackerState)
	if (cacheTrackerState == true) then
		warCacheFrame:Show()
	else
		warCacheFrame:Hide()
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
function parseWarCacheMessage(oldCache, newCache)
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
		setWMTNotificationText("A WAR CHEST HAS BEEN SPOTTED", 6)
		return true;
	end
	if (((tonumber(newX) >= tonumber(oldX) + 15) or (tonumber(newX) <= tonumber(oldX) - 15)) or ((tonumber(newY) >= tonumber(oldY) + 15) or (tonumber(newY) <= tonumber(oldY) - 15))) then
		wmtLastCacheText = newCache
		wmtWarCacheText = newCache
		warCacheText:SetText("War Chest Spotted Near: " .. newX .. ", " .. newY)
		wmtCacheTimer = 200
		setWMTNotificationText("A WAR CHEST HAS BEEN SPOTTED", 6)
		return true;
	end
end

--Function for setting the text color in the War Tracker panel
function setWarTextColor()
warEnemiesText:SetTextColor(warTextR, warTextG, warTextB)
warTotalKillingBlowsText:SetTextColor(warTextR, warTextG, warTextB)
warLastText:SetTextColor(warTextR, warTextG, warTextB)
highestEnemiesText:SetTextColor(warTextR, warTextG, warTextB)
currBountyText:SetTextColor(warTextR, warTextG, warTextB)
totalEnemiesText:SetTextColor(warTextR, warTextG, warTextB)
warHonorLvlText:SetTextColor(warTextR, warTextG, warTextB)

currNumEnemyBounties:SetTextColor(warTextR, warTextG, warTextB)
playerBountiesText:SetTextColor(warTextR, warTextG, warTextB)
enemyBountiesText:SetTextColor(warTextR, warTextG, warTextB)
warCacheText:SetTextColor(warTextR, warTextG, warTextB)
end

--Function for setting up the text for the War Tracker panel, if there are no war bounties sets active bounties to 0, else gets num active bounties based on the list of names
--also sets the text to the list string
function setWarTrackText()
totalEnemiesText:SetText("Total Honor Kills: " .. totalWarKills)
highestEnemiesText:SetText("Highest Streak: " .. highestWarKills)
warLastText:SetText("Last Kill Streak: " .. lastWarKills)
warEnemiesText:SetText("Enemies Slain: " .. warKills)
currBountyText:SetText("Bounty Status: " .. currBounty)
warHonorLvlText:SetText("Lvl ".. pvpWarRank)
warTotalKillingBlowsText:SetText("Killing Blows: " .. totalWarKillingBlows)
	if(active_items(enemyWarBounties) ~= nil and active_items(enemyWarBounties) ~= 0) then
		currNumEnemyBounties:SetText("Active Enemy Bounties: " .. active_items(enemyWarBounties))
		playerBountiesText:SetText(namespace.enemyBountyList)
		--set the bounties frame to the natural height and location
		AdjustCacheFramePos()
		warBountiesFrame:SetHeight(75)
		enemyBountiesText:Show()
		else
		currNumEnemyBounties:SetText("Active Enemy Bounties: 0")
		playerBountiesText:SetText(namespace.enemyBountyList)
		--no enemy bounties, shrink the frame
		warBountiesFrame:SetHeight(20)
		if(warShowStates.warFrameState == false and warShowStates.warBountiesState == true) then
			AdjustCacheFramePos()
		else
			warBountiesFrame:SetPoint("BOTTOM", warTrackFrame, "BOTTOM", 0, -18)
		end
		enemyBountiesText:Hide()
	end
end

function setWarButtonChecks()
	--Sets the checked status of the buttons based on the saved variab;es
	warTrackFrameButton:SetChecked(warShowStates.warFrameState)
	lockWarFrameButton:SetChecked(warShowStates.lockFrameState)
	logoWarFrameButton:SetChecked(warShowStates.logoState)
	warKillsButton:SetChecked(warShowStates.currKillState)
	lastKillsButton:SetChecked(warShowStates.lastKillState)
	highestKillsButton:SetChecked(warShowStates.highestWarKillState)
	currBountyButton:SetChecked(warShowStates.currBountyState)
	totalKillsButton:SetChecked(warShowStates.totalKillState)
	pvpWarLvlButton:SetChecked(warShowStates.warPvPState)
	warBountyFrameButton:SetChecked(warShowStates.warBountiesState)
	warNotificationButton:SetChecked(showWarTrackWarningNotification)
	warSoundNotificationSoundButton:SetChecked(playWarTrackWarningNotification)
	HideWarCombatButton:SetChecked(warHideCombatState)
	HideWarPvPButton:SetChecked(warHidePvPState)
	enableWarKillingblowsButton:SetChecked(killingBlowState)
	warCacheButton:SetChecked(cacheTrackerState)
	warCachePartyButton:SetChecked(warcacheParty)
	warCacheGeneralButton:SetChecked(warcacheGeneral)

	warResetDeathButton:SetChecked(killingBlowResetDeath)
	warResetOnZoneButton:SetChecked(killingBlowResetZone)
	warResetOnLoadButton:SetChecked(killingBlowResetLoad)
	if(killingBlowResetDeath == false and killingBlowResetLoad == false and killingBlowResetZone == false) then
		warNeverResetButton:SetChecked(true)
	end
end

function setWarFrameStatus()
	--Sets the buttons to display on load based on saved variab;es
	ShowWarFrame(warShowStates.warFrameState);
	showWarCurrKill(warShowStates.currKillState);
	showWarLastKill(warShowStates.lastKillState);
	showWarHighestKill(warShowStates.highestWarKillState);
	showWarCurrBounty(warShowStates.currBountyState);
	showWarTotalKill(warShowStates.totalKillState);
	showWarLogo(warShowStates.logoState);
	showLockFrameState(warShowStates.lockFrameState)
	showWarPvPLevel(warShowStates.warPvPState)
	ShowBountyFrame(warShowStates.warBountiesState)
	showWarKillingblow(killingBlowState)
	showCacheTracker(cacheTrackerState)
end

function SetWMTStatus(status)
	if(status == true or status == false or status == 1 or status == 0) then
		  warShowStates.warFrameState = status
		  warShowStates.currKillState = status
		  warShowStates.lastKillState = status
		  warShowStates.highestWarKillState = status
		  warShowStates.currBountyState = status
		  warShowStates.totalKillState = status
		  warShowStates.logoState = status
		  warShowStates.warPvPState = status
		  warShowStates.warBountiesState = status
		  killingBlowState = status
		  cacheTrackerState = status
		  showWarTrackWarningNotification = status
		  playWarTrackWarningNotification = status
		  warcacheParty = status
		  warcacheGeneral = status
		else
			print("An error occured in setting the WMT status")
		end
end

--Creat the options panel frame
local warTrackOptions = CreateFrame("Frame")
warTrackOptions.name = addOnName
--InterfaceOptions_AddCategory(warTrackOptions)
category, layout = Settings.RegisterCanvasLayoutCategory(warTrackOptions, warTrackOptions.name, warTrackOptions.name);
category.ID = warTrackOptions.name
Settings.RegisterAddOnCategory(category);

--Add the addon title to the options panel
local title = warTrackOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
title:SetTextColor(1, 1, .20)
title:SetPoint("CENTER", 0, 250)
title:SetText(addOnName)

--------------------SETTING UP THE OPTIONS PANEL BUTTONS - Buttons for enabling and disabling the text showing in the main panel
--War Frame Button
warTrackFrameButton = CreateFrame("CheckButton", "warTrackFrameButton_GlobalName", warTrackOptions, "ChatConfigCheckButtonTemplate");
warTrackFrameButton:SetPoint("TOPLEFT", 16, -54);
warTrackFrameButton_GlobalNameText:SetText(" Display War Mode Tracker Frame");
warTrackFrameButton.tooltip = "Check to enable the War Mode Tracker Frame";
warTrackFrameButton:SetScript("OnClick",
  function(self)
			local checker = warTrackFrameButton:GetChecked()
			if checker then
				PlaySound(856) -- Check Click Sound
				warShowStates.warFrameState = true;
				ShowWarFrame(warShowStates.warFrameState);
				AdjustCacheFramePos()
			else
				PlaySound(857) -- Check Unclick Sound
				warShowStates.warFrameState = false;
				ShowWarFrame(warShowStates.warFrameState);
				AdjustCacheFramePos()
			end
	end);

	--War Cache Tracker Button
	warCacheButton = CreateFrame("CheckButton", "warCacheButton_GlobalName", warTrackOptions, "ChatConfigCheckButtonTemplate");
	warCacheButton:SetPoint("CENTER", warTrackFrameButton, "CENTER", 300, 0);
	warCacheButton_GlobalNameText:SetText(" Enable the War Cache Tracker");
	warCacheButton.tooltip = "Check to enable the War Cache Tracker";
	warCacheButton:SetScript("OnClick",
	  function(self)
				local checker = warCacheButton:GetChecked()
				if checker then
					PlaySound(856) -- Check Click Sound
					cacheTrackerState = true;
					showCacheTracker(cacheTrackerState)
					AdjustCacheFramePos()
				else
					PlaySound(857) -- Check Unclick Sound
					cacheTrackerState = false;
					showCacheTracker(cacheTrackerState)
					AdjustCacheFramePos()
				end
		end);

		--SendToPArty Button
		warCachePartyButton = CreateFrame("CheckButton", "warCachePartyButton_GlobalName", warTrackOptions, "ChatConfigCheckButtonTemplate");
		warCachePartyButton:SetPoint("TOPLEFT", warCacheButton , "BOTTOMLEFT", 0, -4);
		warCachePartyButton_GlobalNameText:SetText(" Send a War Chest Notification to Party/Raid");
		warCachePartyButton.tooltip = "Check to send a message to the Party/Raid channel when you find a War Chest";
		warCachePartyButton:SetScript("OnClick",
		  function(self)
					local checker = warCachePartyButton:GetChecked()
					if checker then
						PlaySound(856) -- Check Click Sound
						warcacheParty = true
					else
						PlaySound(857)
						warcacheParty = false
					end
			end);

			--SendToGeneral Button
			warCacheGeneralButton = CreateFrame("CheckButton", "warCacheGeneralButton_GlobalName", warTrackOptions, "ChatConfigCheckButtonTemplate");
			warCacheGeneralButton:SetPoint("TOPLEFT", warCachePartyButton , "BOTTOMLEFT", 0, -4);
			warCacheGeneralButton_GlobalNameText:SetText(" Send a War Chest Notification to General");
			warCacheGeneralButton.tooltip = "Check to send a message to the General channel when you find a War Chest";
			warCacheGeneralButton:SetScript("OnClick",
			  function(self)
						local checker = warCacheGeneralButton:GetChecked()
						if checker then
							PlaySound(856) -- Check Click Sound
							warcacheGeneral = true
						else
							PlaySound(857)
							warcacheGeneral = false
						end
				end);

--War Notification Text Button
warNotificationButton = CreateFrame("CheckButton", "warNotificationButton_GlobalName", warTrackOptions, "ChatConfigCheckButtonTemplate");
warNotificationButton:SetPoint("TOPLEFT", warCacheGeneralButton, "BOTTOMLEFT", 0, -4);
warNotificationButton_GlobalNameText:SetText(" Display Notification Messages");
warNotificationButton.tooltip = "Check to enable Notification Messages";
warNotificationButton:SetScript("OnClick",
  function(self)
			local checker = warNotificationButton:GetChecked()
			if checker then
				PlaySound(856) -- Check Click Sound
				showWarTrackWarningNotification = true;
			else
				PlaySound(857) -- Check Unclick Sound
				showWarTrackWarningNotification = false;
			end
	end);

--War Notification Sound Button
warSoundNotificationSoundButton = CreateFrame("CheckButton", "warSoundNotificationSoundButton_GlobalName", warTrackOptions, "ChatConfigCheckButtonTemplate");
warSoundNotificationSoundButton:SetPoint("TOPLEFT", warNotificationButton, "BOTTOMLEFT", 20, -12);
warSoundNotificationSoundButton_GlobalNameText:SetText(" Play the Notification Sound");
warSoundNotificationSoundButton.tooltip = "Check to enable the Notification Sound";
warSoundNotificationSoundButton:SetScript("OnClick",
  function(self)
			local checker = warSoundNotificationSoundButton:GetChecked()
			if checker then
				PlaySound(856) -- Check Click Sound
				playWarTrackWarningNotification = true;
			else
				PlaySound(857) -- Check Unclick Sound
				playWarTrackWarningNotification = false;
			end
	end);






--Text for the options panel that displays the RGB specifications for the panel text color
local warKillBlowSetText = warTrackOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal")
warKillBlowSetText:SetTextColor(1, 1, 1)
warKillBlowSetText:SetPoint("TOPLEFT", warNotificationButton, "BOTTOMLEFT", 0, -196)
warKillBlowSetText:SetText("Killing Blow Tracker Reset Events")

--ResetOnDeath Button
warResetDeathButton = CreateFrame("CheckButton", "warResetDeathButton_GlobalName", warTrackOptions, "ChatConfigCheckButtonTemplate");
warResetDeathButton:SetPoint("TOPLEFT", warKillBlowSetText , "BOTTOMLEFT", 20, -12);
warResetDeathButton_GlobalNameText:SetText(" Reset on Death");
warResetDeathButton.tooltip = "Check to have the Killing Blow Tracker reset on player death";
warResetDeathButton:SetScript("OnClick",
  function(self)
			local checker = warResetDeathButton:GetChecked()
			if checker then
				PlaySound(856) -- Check Click Sound
				killingBlowResetDeath = true
				warNeverResetButton:SetChecked(false)
			else
				PlaySound(857)
				killingBlowResetDeath = false;
			end
	end);

--ResetOnZone Button
warResetOnZoneButton = CreateFrame("CheckButton", "warResetOnZoneButton_GlobalName", warTrackOptions, "ChatConfigCheckButtonTemplate");
warResetOnZoneButton:SetPoint("TOPLEFT", warResetDeathButton , "BOTTOMLEFT", 0, -4);
warResetOnZoneButton_GlobalNameText:SetText(" Reset on Zone Change");
warResetOnZoneButton.tooltip = "Check to have the Killing Blow Tracker reset on zone change";
warResetOnZoneButton:SetScript("OnClick",
  function(self)
			local checker = warResetOnZoneButton:GetChecked()
			if checker then
				PlaySound(856) -- Check Click Sound
				killingBlowResetZone = true
				warNeverResetButton:SetChecked(false)
			else
				PlaySound(857)
				killingBlowResetZone = false
			end
	end);

--ResetOnLoad Button
warResetOnLoadButton = CreateFrame("CheckButton", "warResetOnLoadButton_GlobalName", warTrackOptions, "ChatConfigCheckButtonTemplate");
warResetOnLoadButton:SetPoint("TOPLEFT", warResetOnZoneButton , "BOTTOMLEFT", 0, -4);
warResetOnLoadButton_GlobalNameText:SetText(" Reset on Load Screens");
warResetOnLoadButton.tooltip = "Check to have the Killing Blow Tracker reset on load screens";
warResetOnLoadButton:SetScript("OnClick",
  function(self)
			local checker = warResetOnLoadButton:GetChecked()
			if checker then
				PlaySound(856) -- Check Click Sound
				killingBlowResetLoad = true
				warNeverResetButton:SetChecked(false)
			else
				PlaySound(857)
				killingBlowResetLoad = false
			end
	end);

--NeverReset Button
warNeverResetButton = CreateFrame("CheckButton", "warNeverResetButton_GlobalName", warTrackOptions, "ChatConfigCheckButtonTemplate");
warNeverResetButton:SetPoint("TOPLEFT", warResetOnLoadButton, "BOTTOMLEFT", 0, -4);
warNeverResetButton_GlobalNameText:SetText(" Never Reset");
warNeverResetButton.tooltip = "Check to have the Killing Blow Tracker never reset";
warNeverResetButton:SetScript("OnClick",
  function(self)
			local checker = warNeverResetButton:GetChecked()
			if checker then
				PlaySound(856) -- Check Click Sound
				killingBlowResetDeath = false;
				killingBlowResetLoad = false;
				killingBlowResetZone = false;
				warResetDeathButton:SetChecked(false)
				warResetOnLoadButton:SetChecked(false)
				warResetOnZoneButton:SetChecked(false)
			else
				PlaySound(856)
				warNeverResetButton:SetChecked(true)
			end
	end);




--Bounty Tracking Frame Button
warBountyFrameButton = CreateFrame("CheckButton", "warBountyFrameButton_GlobalName", warTrackOptions, "ChatConfigCheckButtonTemplate");
warBountyFrameButton:SetPoint("TOPLEFT", warTrackFrameButton, "BOTTOMLEFT", 20, -12);
warBountyFrameButton_GlobalNameText:SetText(" Display War Bounty Tracker Frame");
warBountyFrameButton.tooltip = "Check to enable the War Mode Bounty Tracker Frame";
warBountyFrameButton:SetScript("OnClick",
  function(self)
			local checker = warBountyFrameButton:GetChecked()
			if checker then
				PlaySound(856) -- Check Click Sound
				warShowStates.warBountiesState = true;
				ShowBountyFrame(warShowStates.warBountiesState);
				AdjustCacheFramePos()
			else
				PlaySound(857) -- Check Unclick Sound
				warShowStates.warBountiesState = false;
				ShowBountyFrame(warShowStates.warBountiesState);
				AdjustCacheFramePos()
			end
	end);

--lock war frame button
lockWarFrameButton = CreateFrame("CheckButton", "lockWarFrameButton_GlobalName", warTrackOptions, "ChatConfigCheckButtonTemplate");
lockWarFrameButton:SetPoint("TOPLEFT", warBountyFrameButton, "BOTTOMLEFT", 0, -12);
lockWarFrameButton_GlobalNameText:SetText(" Lock War Mode Tracker Frame");
lockWarFrameButton.tooltip = "Check to lock the War Mode Tracker Frame in place";
lockWarFrameButton:SetScript("OnClick",
  function(self)
			local checker = lockWarFrameButton:GetChecked()
			if checker then
				PlaySound(856) -- Check Click Sound
				warShowStates.lockFrameState = true;
				showLockFrameState(warShowStates.lockFrameState);
			else
				PlaySound(857) -- Check Unclick Sound
				warShowStates.lockFrameState = false;
				showLockFrameState(warShowStates.lockFrameState);
			end
	end);

	--Hide in Combat frame button
HideWarCombatButton = CreateFrame("CheckButton", "HideWarCombatButton_GlobalName", warTrackOptions, "ChatConfigCheckButtonTemplate");
HideWarCombatButton:SetPoint("TOPLEFT", lockWarFrameButton, "BOTTOMLEFT", 0, -12);
HideWarCombatButton_GlobalNameText:SetText(" Hide Frames in Combat");
HideWarCombatButton.tooltip = "Check to hide the War Mode Tracker Frames when in combat";
HideWarCombatButton:SetScript("OnClick",
  function(self)
			local checker = HideWarCombatButton:GetChecked()
			if checker then
				PlaySound(856) -- Check Click Sound
				warHideCombatState = true
			else
				PlaySound(857) -- Check Unclick Sound
				warHideCombatState = false
			end
	end);

	--Hide when not in War Mode frame button
HideWarPvPButton = CreateFrame("CheckButton", "HideWarPvPButton_GlobalName", warTrackOptions, "ChatConfigCheckButtonTemplate");
HideWarPvPButton:SetPoint("TOPLEFT", HideWarCombatButton, "BOTTOMLEFT", 0, -12);
HideWarPvPButton_GlobalNameText:SetText(" Hide Frames When Not In War Mode");
HideWarPvPButton.tooltip = "Check to hide the War Mode Tracker Frames when not in War Mode";
HideWarPvPButton:SetScript("OnClick",
  function(self)
			local checker = HideWarPvPButton:GetChecked()
			if checker then
				PlaySound(856) -- Check Click Sound
				warHidePvPState = true
				--placing it here to see what happens
				if(warHidePvPState == true) then
					if (C_PvP.IsWarModeActive() == false) then
						WarGhostFrame:Hide()
						if (warTrackFrame:IsShown() == true) then
							warTrackFrame:Hide()
						end
						if(warBountiesFrame:IsShown() == true) then
							warBountiesFrame:Hide()
						end
						if(warCacheFrame:IsShown() == true)then
							warCacheFrame:Hide();
						end
					end
				end
			else
				PlaySound(857) -- Check Unclick Sound
				warHidePvPState = false

				--placing it here to see what happens
				if(warHidePvPState == false) then
					WarGhostFrame:Show()
						if (warTrackFrame:IsShown() == false) then
							warTrackFrame:Show()
						end
						if(warBountiesFrame:IsShown() == false) then
							warBountiesFrame:Show()
						end
						if(warCacheFrame:IsShown() == false) then
							warCacheFrame:Show()
						end
					end
				end
	end);

--faction banner war frame button
logoWarFrameButton = CreateFrame("CheckButton", "logoWarFrameButton_GlobalName", warTrackOptions, "ChatConfigCheckButtonTemplate");
logoWarFrameButton:SetPoint("TOPLEFT", HideWarPvPButton, "BOTTOMLEFT", -20, -12);
logoWarFrameButton_GlobalNameText:SetText(" Enable Faction Logo");
logoWarFrameButton.tooltip = "Check to enable your Faction's logo";
logoWarFrameButton:SetScript("OnClick",
  function(self)
			local checker = logoWarFrameButton:GetChecked()
			if checker then
				PlaySound(856) -- Check Click Sound
				warShowStates.logoState = true;
				showWarLogo(warShowStates.logoState);
			else
				PlaySound(857) -- Check Unclick Sound
				warShowStates.logoState = false;
				showWarLogo(warShowStates.logoState);
			end
	end);

	--Enable killing blows
enableWarKillingblowsButton = CreateFrame("CheckButton", "enableWarKillingblowsButton_GlobalName", warTrackOptions, "ChatConfigCheckButtonTemplate");
enableWarKillingblowsButton:SetPoint("CENTER", logoWarFrameButton, "CENTER", 300, 0);
enableWarKillingblowsButton_GlobalNameText:SetText(" Display Killing Blows");
enableWarKillingblowsButton.tooltip = "Check to enable the Killing Blows tracker";
enableWarKillingblowsButton:SetScript("OnClick",
  function(self)
			local checker = enableWarKillingblowsButton:GetChecked()
			if checker then
				PlaySound(856) -- Check Click Sound
				killingBlowState = true
				showWarKillingblow(killingBlowState)
			else
				PlaySound(857) -- Check Unclick Sound
				killingBlowState = false
				showWarKillingblow(killingBlowState)
			end
	end);

--pvp lvl frame button
pvpWarLvlButton = CreateFrame("CheckButton", "pvpWarLvlButton_GlobalName", warTrackOptions, "ChatConfigCheckButtonTemplate");
pvpWarLvlButton:SetPoint("TOPLEFT", logoWarFrameButton, "BOTTOMLEFT", 0, -12);
pvpWarLvlButton_GlobalNameText:SetText(" Display Honor Level");
pvpWarLvlButton.tooltip = "Check to display your Honor Level";
pvpWarLvlButton:SetScript("OnClick",
  function(self)
			local checker = pvpWarLvlButton:GetChecked()
			if checker then
				PlaySound(856) -- Check Click Sound
				warShowStates.warPvPState = true;
				showWarPvPLevel(warShowStates.warPvPState);
			else
				PlaySound(857) -- Check Unclick Sound
				warShowStates.warPvPState = false;
				showWarPvPLevel(warShowStates.warPvPState);
			end
	end);

--Current Kills Button
warKillsButton = CreateFrame("CheckButton", "warKillsButton_GlobalName", warTrackOptions, "ChatConfigCheckButtonTemplate");
warKillsButton:SetPoint("TOPLEFT", pvpWarLvlButton, "BOTTOMLEFT", 0, -12);
warKillsButton_GlobalNameText:SetText(" Display Enemies Slain");
warKillsButton.tooltip = "Check to enable the Enemies Slain tracker";
warKillsButton:SetScript("OnClick",
  function(self)
			local checker = warKillsButton:GetChecked()
			if checker then
				PlaySound(856) -- Check Click Sound
				warShowStates.currKillState = true;
				showWarCurrKill(warShowStates.currKillState);
			else
				PlaySound(857) -- Check Unclick Sound
				warShowStates.currKillState = false;
				showWarCurrKill(warShowStates.currKillState);
			end
	end);

--Last Kills Button
lastKillsButton = CreateFrame("CheckButton", "lastKillsButton_GlobalName", warTrackOptions, "ChatConfigCheckButtonTemplate");
lastKillsButton:SetPoint("TOPLEFT", warKillsButton, "BOTTOMLEFT", 0, -12);
lastKillsButton_GlobalNameText:SetText(" Display Last Kill Streak");
lastKillsButton.tooltip = "Check to enable the Last Kill Streak tracker";
lastKillsButton:SetScript("OnClick",
  function(self)
			local checker = lastKillsButton:GetChecked()
			if checker then
				PlaySound(856) -- Check Click Sound
				warShowStates.lastKillState = true;
				showWarLastKill(warShowStates.lastKillState);
			else
				PlaySound(857) -- Check Unclick Sound
				warShowStates.lastKillState = false;
				showWarLastKill(warShowStates.lastKillState);
			end
	end);

--Highest Kills button
highestKillsButton = CreateFrame("CheckButton", "highestKillsButton_GlobalName", warTrackOptions, "ChatConfigCheckButtonTemplate");
highestKillsButton:SetPoint("TOPLEFT", lastKillsButton, "BOTTOMLEFT", 0, -12);
highestKillsButton_GlobalNameText:SetText(" Display Highest Kill Streak");
highestKillsButton.tooltip = "Check to enable the Highest Kill Streak tracker";
highestKillsButton:SetScript("OnClick",
  function(self)
			local checker = highestKillsButton:GetChecked()
			if checker then
				PlaySound(856) -- Check Click Sound
				warShowStates.highestWarKillState = true;
				showWarHighestKill(warShowStates.highestWarKillState);
			else
				PlaySound(857) -- Check Unclick Sound
				warShowStates.highestWarKillState = false;
				showWarHighestKill(warShowStates.highestWarKillState);
			end
	end);

--Current bounty button
currBountyButton = CreateFrame("CheckButton", "currBountyButton_GlobalName", warTrackOptions, "ChatConfigCheckButtonTemplate");
currBountyButton:SetPoint("TOPLEFT", highestKillsButton, "BOTTOMLEFT", 0, -12);
currBountyButton_GlobalNameText:SetText(" Display Current Bounty Status");
currBountyButton.tooltip = "Check to enable the Current Bounty Status tracker";
currBountyButton:SetScript("OnClick",
  function(self)
			local checker = currBountyButton:GetChecked()
			if checker then
				PlaySound(856) -- Check Click Sound
				warShowStates.currBountyState = true;
				showWarCurrBounty(warShowStates.currBountyState);
			else
				PlaySound(857) -- Check Unclick Sound
				warShowStates.currBountyState = false;
				showWarCurrBounty(warShowStates.currBountyState);
			end
	end);

--total kills button
totalKillsButton = CreateFrame("CheckButton", "totalKillsButton_GlobalName", warTrackOptions, "ChatConfigCheckButtonTemplate");
totalKillsButton:SetPoint("TOPLEFT", currBountyButton, "BOTTOMLEFT", 0, -12);
totalKillsButton_GlobalNameText:SetText(" Display Total Character PvP Kills");
totalKillsButton.tooltip = "Check to enable the Total Character PvP Kills tracker";
totalKillsButton:SetScript("OnClick",
  function(self)
			local checker = totalKillsButton:GetChecked()
			if checker then
				PlaySound(856) -- Check Click Sound
				warShowStates.totalKillState = true;
				showWarTotalKill(warShowStates.totalKillState);
			else
				PlaySound(857) -- Check Unclick Sound
				warShowStates.totalKillState = false;
				showWarTotalKill(warShowStates.totalKillState);
			end
	end);

--Text for the options panel that displays the RGB specifications for the panel text color
local rgbWarText = warTrackOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal")
rgbWarText:SetTextColor(1, 1, 1)
rgbWarText:SetPoint("LEFT", totalKillsButton, "RIGHT", -12, -30)
rgbWarText:SetText("Panel Text Color (RGB)")
--Text for the options panel that displays the RGBA specifications for the panel BACKGROUND
local warFrameRGBAText = warTrackOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal")
warFrameRGBAText:SetTextColor(1, 1, 1)
warFrameRGBAText:SetPoint("LEFT", rgbWarText, "RIGHT", 70, 0)
warFrameRGBAText:SetText("Panel Background Color (RGBA)")

--------------------SETTING UP THE SCALE SLIDER--------------------------------------------------

--Create text for the slider
local wmtScaleText = warTrackOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal")
wmtScaleText:SetPoint("BOTTOMLEFT", 255, 250)
wmtScaleText:SetText("WMT Frame Scale: ")

--Creating the Slider for the wmtScaleSlider
wmtScaleSlider = CreateFrame("Slider", "wmtScaleSliderGlobalName", warTrackOptions, "OptionsSliderTemplate")
wmtScaleSlider:SetWidth(125)
wmtScaleSlider:SetHeight(15)
wmtScaleSlider:SetOrientation('HORIZONTAL')
wmtScaleSlider:SetPoint("CENTER", wmtScaleText, 125, 0);
wmtScaleSlider.tooltipText = 'Set the scale for the WMT frames' --Creates a tooltip on mouseover.
getglobal(wmtScaleSlider:GetName() .. 'Low'):SetText('.5'); --Sets the left-side slider text
getglobal(wmtScaleSlider:GetName() .. 'High'):SetText('2'); --Sets the right-side slider text
wmtScaleSlider:SetValueStep(.01)
wmtScaleSlider:SetMinMaxValues(.5, 2)
wmtScaleSlider:SetObeyStepOnDrag(true)
wmtScaleSlider:SetValue(wmtFrameScale)

--Creating editbox to show number for the slider
wmtScaleEditbox = CreateFrame("EditBox", "wmtScaleEditBoxGlobalName", warTrackOptions, "InputBoxTemplate")
wmtScaleEditbox:ClearAllPoints()
wmtScaleEditbox:ClearFocus()
wmtScaleEditbox:SetSize(70, 30)
wmtScaleEditbox:SetPoint("LEFT", wmtScaleSlider, "RIGHT", 15, 0)
wmtScaleEditbox:SetText(wmtScaleSlider:GetValue())
wmtScaleEditbox:SetAutoFocus(false)
wmtScaleEditbox:SetCursorPosition(0)

--Scripts for changing the Slider Values and text box values

--Slider <- Edit Box
wmtScaleSlider:SetScript("OnValueChanged", function(self, value)
wmtFrameScale = value;
warTrackGhost:SetScale(value)
warBountiesFrame:SetScale(value)
warCacheFrame:SetScale(value)
wmtScaleEditbox:SetText(string.sub(value, 1, 4))
end)

--Edit Box -> Slider
wmtScaleEditbox:SetScript("OnEnterPressed", function(self)
local val = self:GetText()
if tonumber(val) then
sliderMin, sliderMax = wmtScaleSlider:GetMinMaxValues()
	if (tonumber(val) >= sliderMin and tonumber(val) <= sliderMax) then
		wmtFrameScale = val;
		wmtScaleSlider:SetValue(wmtFrameScale)
		self:ClearFocus()
	end
else
	self:ClearFocus()
end
end)


--------------------SETTING RBG Button Edit Boxes ------------------------------------------------
--Creating editbox for the red RBG text value
 redWarBox = CreateFrame("EditBox", "Red Box", warTrackOptions, "InputBoxTemplate")
 redWarBox:SetNumeric()
 redWarBox:ClearAllPoints()
 redWarBox:ClearFocus()
 redWarBox:SetSize(30, 30)
 redWarBox:SetPoint("LEFT", totalKillsButton, "RIGHT", -15, -55)
 redWarBox:SetText(warTextR * 100)
 redWarBox:SetAutoFocus(false)
 redWarBox:SetCursorPosition(0)

 --Editbox script Red
 redWarBox:SetScript("OnEnterPressed", function(self)
	local val = self:GetNumber()
	if (val <= 100) then
		warTextR = (val / 100);
		setWarTextColor()
		self:ClearFocus()
	else
	warTextR = 100;
	setWarTextColor()
	self:SetText(100)
	end
end)

--Green color value edit box setup
 greenWarBox = CreateFrame("EditBox", "Green Box", warTrackOptions, "InputBoxTemplate")
 greenWarBox:SetNumeric()
 greenWarBox:ClearAllPoints()
 greenWarBox:ClearFocus()
 greenWarBox:SetSize(30, 30)
 greenWarBox:SetPoint("CENTER", redWarBox, "RIGHT", 45, 0)
 greenWarBox:SetText(warTextG * 100)
 greenWarBox:SetAutoFocus(false)
 greenWarBox:SetCursorPosition(0)

 --Editbox script Green
 greenWarBox:SetScript("OnEnterPressed", function(self)
	local val = self:GetNumber()
	if (val <= 100) then
		warTextG = (val / 100);
		setWarTextColor()
		self:ClearFocus()
	else
	warTextG = 100;
	setWarTextColor()
	self:SetNumber(100)
	end
end)

--Blue color value edit box setup
 blueWarBox = CreateFrame("EditBox", "Blue Box", warTrackOptions, "InputBoxTemplate")
 blueWarBox:SetNumeric()
 blueWarBox:ClearAllPoints()
 blueWarBox:ClearFocus()
 blueWarBox:SetSize(30, 30)
 blueWarBox:SetPoint("CENTER", greenWarBox, "RIGHT", 45, 0)
 blueWarBox:SetText(warTextB * 100)
 blueWarBox:SetAutoFocus(false)
 blueWarBox:SetCursorPosition(0)

 --Editbox script Blue
 blueWarBox:SetScript("OnEnterPressed", function(self)
	local val = self:GetNumber()
	if (val <= 100) then
		warTextB = (val / 100);
		setWarTextColor()
		self:ClearFocus()
	else
	warTextB = 100;
	setWarTextColor()
	self:SetNumber(100)
	end
end)


--Frame Red  value edit box setup
 warFrameRBox = CreateFrame("EditBox", "Warframe Red Box", warTrackOptions, "InputBoxTemplate")
 warFrameRBox:SetNumeric()
 warFrameRBox:ClearAllPoints()
 warFrameRBox:ClearFocus()
 warFrameRBox:SetSize(30, 30)
 warFrameRBox:SetPoint("CENTER", blueWarBox, "RIGHT", 85, 0)
 warFrameRBox:SetText(warFrameR * 100)
 warFrameRBox:SetAutoFocus(false)
 warFrameRBox:SetCursorPosition(0)

 --Editbox script Frame Red
 warFrameRBox:SetScript("OnEnterPressed", function(self)
	local val = self:GetNumber()
	if (val <= 100) then
		warFrameR = (val / 100);
		warTrackFrameSet()
		self:ClearFocus()
	else
	warFrameR = (100 / 10);
	warTrackFrameSet()
	self:SetNumber(100)
	end
end)

--Frame Green  value edit box setup
 warFrameGBox = CreateFrame("EditBox", "Warframe Green Box", warTrackOptions, "InputBoxTemplate")
 warFrameGBox:SetNumeric()
 warFrameGBox:ClearAllPoints()
 warFrameGBox:ClearFocus()
 warFrameGBox:SetSize(30, 30)
 warFrameGBox:SetPoint("CENTER", warFrameRBox, "RIGHT", 45, 0)
 warFrameGBox:SetText(warFrameG * 100)
 warFrameGBox:SetAutoFocus(false)
 warFrameGBox:SetCursorPosition(0)

 --Editbox script Frame Green
 warFrameGBox:SetScript("OnEnterPressed", function(self)
	local val = self:GetNumber()
	if (val <= 100) then
		warFrameG = (val / 100);
		warTrackFrameSet()
		self:ClearFocus()
	else
	warFrameG = (100 / 10);
	warTrackFrameSet()
	self:SetNumber(100)
	end
end)

--Frame Blue value edit box setup
 warFrameBBox = CreateFrame("EditBox", "Warframe Blue Box", warTrackOptions, "InputBoxTemplate")
 warFrameBBox:SetNumeric()
 warFrameBBox:ClearAllPoints()
 warFrameBBox:ClearFocus()
 warFrameBBox:SetSize(30, 30)
 warFrameBBox:SetPoint("CENTER", warFrameGBox, "RIGHT", 45, 0)
 warFrameBBox:SetText(warFrameB * 100)
 warFrameBBox:SetAutoFocus(false)
 warFrameBBox:SetCursorPosition(0)

 --Editbox script Frame Blue
 warFrameBBox:SetScript("OnEnterPressed", function(self)
	local val = self:GetNumber()
	if (val <= 100) then
		warFrameB = (val / 100);
		warTrackFrameSet()
		self:ClearFocus()
	else
	warFrameB = (100 / 10);
	warTrackFrameSet()
	self:SetNumber(100)
	end
end)

--Frame Alpha value edit box setup
 warFrameABox = CreateFrame("EditBox", "Warframe Alpha Box", warTrackOptions, "InputBoxTemplate")
 warFrameABox:SetNumeric()
 warFrameABox:ClearAllPoints()
 warFrameABox:ClearFocus()
 warFrameABox:SetSize(30, 30)
 warFrameABox:SetPoint("CENTER", warFrameBBox, "RIGHT", 45, 0)
 warFrameABox:SetText(warFrameTransparency * 100)
 warFrameABox:SetAutoFocus(false)
 warFrameABox:SetCursorPosition(0)

 --Editbox script Frame Alpha
 warFrameABox:SetScript("OnEnterPressed", function(self)
	local val = self:GetNumber()
	if (val <= 100) then
		warFrameTransparency = (val / 100);
		warTrackFrameSet()
		self:ClearFocus()
	else
	warFrameTransparency = (100 / 10);
	warTrackFrameSet()
	self:SetNumber(100)
	end
end)

-------CREATING THE RESET BUTTON FOR HIGHEST SCORE
local resetWarHighest = CreateFrame("Button", "Reset Highest Streak", warTrackOptions, "BackdropTemplate")
resetWarHighest:SetPoint("LEFT", redWarBox, "CENTER", -25, -28)
resetWarHighest:SetWidth(175)
resetWarHighest:SetHeight(25)
resetWarHighest:SetText("RESET HIGHEST STREAK")
resetWarHighest:SetNormalFontObject("GameFontNormal")

--Setting the background for the reset button
resetWarHighest:SetBackdrop( {
	bgFile = "Interface/Tooltips/UI-Tooltip-Background",
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
	tile = false, edgeSize = 16,
	insets = {left = 2, right = 2, top = 4.5, bottom = 4.5}});
resetWarHighest:SetBackdropColor(.75, 0, .25);
resetWarHighest:SetBackdropBorderColor(1, 1, 1)

--Script for the reset button
resetWarHighest:SetScript("OnClick", function(self)
	highestWarKills = 0;
	highestEnemiesText:SetText("Highest Streak: " .. highestWarKills)
end)

--Script for the "Okay" button in the options menu, makes it so all edit boxes confirm and submit whats entered in them upon button press
warTrackOptions.okay = function(self)
	local redWarVal = redWarBox:GetText()
	warTextR = (redWarVal / 100);
	redWarBox:ClearFocus()

	local greenWarVal = greenWarBox:GetText()
	warTextG = (greenWarVal / 100);
	greenWarBox:ClearFocus()

	local blueWarVal = blueWarBox:GetText()
	warTextB = (blueWarVal / 100);
	blueWarBox:ClearFocus()

	local blueWarVal = blueWarBox:GetText()
	warTextB = (blueWarVal / 100);
	blueWarBox:ClearFocus()

	local warFrameRVal = warFrameRBox:GetText()
	warFrameR = (warFrameRVal / 100);
	warFrameRBox:ClearFocus()

	local warFrameGVal = warFrameGBox:GetText()
	warFrameG = (warFrameGVal / 100);
	warFrameGBox:ClearFocus()

	local warFrameBVal = warFrameBBox:GetText()
	warFrameB = (warFrameBVal / 100);
	warFrameBBox:ClearFocus()

	local warFrameAVal = warFrameABox:GetText()
	warFrameTransparency = (warFrameAVal / 100);
	warFrameABox:ClearFocus()

	warTrackFrameSet()
	setWarTextColor()
end

--SLASH COMMANDS
local function WMTSlashCommands(cmd, editbox)
	if(cmd == "nil" or cmd == "" or cmd == " ") then
		print("|cffff0000War Mode Tracker Commands:|r")
		print("|cffffff00 -'/wmt ON' - Turns on all features of War Mode Tracker|r")
		print("|cffffff00 -'/wmt OFF' - Turns off all features of War Mode Tracker|r")
		print("|cffffff00 -'/wmt LOCK' - Locks/Unlocks the WMT frame set|r")
		print("|cffffff00 -'/wmt HIDE IN COMBAT' - Toggles the Hide in Combat mode on/off for the WMT frame set |r")
		print("|cffffff00 -'/wmt HIDE IN PVE' - Toggles the Hide in PvE mode on/off for the WMT frame set |r")
		print("|cffffff00 -'/wmt MAIN FRAME' - Toggles the Main WMT frame On/Off |r")
		print("|cffffff00 -'/wmt BOUNTY FRAME' - Toggles the Bounty WMT frame On/Off |r")
		print("|cffffff00 -'/wmt CACHE FRAME' - Toggles the Cache WMT frame On/Off |r")
		print("|cffffff00 -'/wmt NOTIFY MESSAGE' - Toggles the Notification Messages On/Off |r")
		print("|cffffff00 -'/wmt NOTIFY SOUND' - Toggles the Notification Sound On/Off |r")
		print("|cffffff00 -'/wmt GENERAL MESSAGE' - Toggles the Cache Message for General Chat On/Off |r")
		print("|cffffff00 -'/wmt PARTY MESSAGE' - Toggles the Cache Message for Party Chat On/Off |r")
		print("|cffffff00For a full list of the Settings, go to 'Interface -> Addons -> War Mode Tracker' !|r")
	end
	if (string.lower(cmd) == "on") then
		print("|cffffff00 War Mode Tracker is now ON |r")
		SetWMTStatus(true)
		setWarFrameStatus()
		setWarButtonChecks()
		AdjustCacheFramePos()
	end
	if(string.lower(cmd) == "off") then
		print("|cffffff00 War Mode Tracker is now OFF |r")
		SetWMTStatus(false)
		setWarFrameStatus()
		setWarButtonChecks()
		AdjustCacheFramePos()
	end
	if(string.lower(cmd) == "lock") then
		if (warShowStates.lockFrameState == true) then
			print("|cffffff00 WMT Lock Status: UNLOCKED |r")
			warShowStates.lockFrameState = false
		else
			print("|cffffff00 WMT Lock Status: LOCKED |r")
			warShowStates.lockFrameState = true
		end
		setWarFrameStatus()
		setWarButtonChecks()
	end
	if(string.lower(cmd) == "hide in combat") then
		if(warHideCombatState == false) then
			print("|cffffff00 WMT Hide in Combat Status: ACTIVE |r")
			warHideCombatState = true
		else
			print("|cffffff00 WMT Hide in Combat Status: INACTIVE |r")
			warHideCombatState = false
		end
		setWarFrameStatus()
		setWarButtonChecks()
	end
	if(string.lower(cmd) == "hide in pve") then
		if(warHidePvPState == false) then
			print("|cffffff00 WMT Hide in PvE Status: ACTIVE |r")
			warHidePvPState = true
		else
			print("|cffffff00 WMT Hide in PvE Status: INACTIVE |r")
			warHidePvPState = false
			WarGhostFrame:Show()
		end
		setWarFrameStatus()
		setWarButtonChecks()
	end
	if(string.lower(cmd) == "main frame") then
		if(warShowStates.warFrameState == true) then
			print("|cffffff00 WMT Main Frame Status: INACTIVE |r")
			warShowStates.warFrameState = false
		else
			print("|cffffff00 WMT Main Frame Status: ACTIVE |r")
			warShowStates.warFrameState = true
		end
		setWarFrameStatus()
		setWarButtonChecks()
		AdjustCacheFramePos()
	end
	if(string.lower(cmd) == "bounty frame") then
		if(warShowStates.warBountiesState == true) then
			print("|cffffff00 WMT Bounty Frame Status: INACTIVE |r")
			warShowStates.warBountiesState = false
		else
			warShowStates.warBountiesState = true
			print("|cffffff00 WMT Bounty Frame Status: ACTIVE |r")
		end
		setWarFrameStatus()
		setWarButtonChecks()
		AdjustCacheFramePos()
	end
	if(string.lower(cmd) == "cache frame") then
		if(cacheTrackerState == true) then
			print("|cffffff00 WMT Cache Frame Status: INACTIVE |r")
			cacheTrackerState = false
		else
			print("|cffffff00 WMT Cache Frame Status: ACTIVE |r")
			cacheTrackerState = true
		end
		setWarFrameStatus()
		setWarButtonChecks()
		AdjustCacheFramePos()
	end
	if(string.lower(cmd) == "notify message") then
		if(showWarTrackWarningNotification == true) then
			print("|cffffff00 WMT Notification Messages Status: INACTIVE |r")
			showWarTrackWarningNotification = false
			playWarTrackWarningNotification = false
		else
			print("|cffffff00 WMT Notification Messages Status: ACTIVE |r")
			showWarTrackWarningNotification = true
		end
		setWarFrameStatus()
		setWarButtonChecks()
	end
	if(string.lower(cmd) == "notify sound") then
		if(showWarTrackWarningNotification == true) then
			if(playWarTrackWarningNotification == true) then
				print("|cffffff00 WMT Notification Sounds Status: INACTIVE |r")
				playWarTrackWarningNotification = false
			else
				print("|cffffff00 WMT Notification Sounds Status: ACTIVE |r")
				playWarTrackWarningNotification = true
			end
		else
			print("Cannot turn the WMT Notification Sound on while the Notification Messages are disabled")
		end
		setWarFrameStatus()
		setWarButtonChecks()
	end
	if(string.lower(cmd) == "general message") then
		if(warcacheGeneral == true) then
			print("|cffffff00 WMT General Chat Notification Messages: INACTIVE |r")
			warcacheGeneral = false
		else
			print("|cffffff00 WMT General Chat Notification Messages: ACTIVE |r")
			warcacheGeneral = true
		end
		setWarFrameStatus()
		setWarButtonChecks()
	end
	if(string.lower(cmd) == "party message") then
			if(warcacheParty == true) then
				print("|cffffff00 WMT Party Chat Notification Messages: INACTIVE |r")
				warcacheParty = false
			else
				print("|cffffff00 WMT Party Chat Notification Messages: ACTIVE |r")
				warcacheParty = true
			end
			setWarFrameStatus()
			setWarButtonChecks()
	end
end
--create the wmt slash command
SLASH_WMT1 = '/wmt'
-- register the wmt slash commant and call the WMTSlashCommands function
SlashCmdList["WMT"] = WMTSlashCommands

--Script fired off during events. Primary purpose is to set variables/text
local function OnWarUpdates(_, event, arg1, arg2, arg3, arg4)
	if (event == "PLAYER_ENTERING_WORLD") then
		--get the total honor kills and pvp rank
		totalWarKills = GetPVPLifetimeStats();
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
		warLastText:SetText("Last Kill Streak: " .. lastWarKills)

		--Set the panel text
		setWarTrackText();
		--Load the text color
		setWarTextColor();
		--setup the main panel background
		warTrackFrameSet();

		--Set Editbox values for colors
		blueWarBox:SetNumber(warTextB * 100)
		greenWarBox:SetNumber(warTextG * 100)
		redWarBox:SetNumber(warTextR * 100)
		blueWarBox:SetCursorPosition(0)
		greenWarBox:SetCursorPosition(0)
		redWarBox:SetCursorPosition(0)
		warFrameRBox:SetCursorPosition(0)
		warFrameBBox:SetCursorPosition(0)
		warFrameGBox:SetCursorPosition(0)
		warFrameABox:SetCursorPosition(0)
		wmtScaleSlider:SetValue(wmtFrameScale)
		wmtScaleEditbox:SetText(string.sub(wmtFrameScale, 1, 4))
		wmtScaleEditbox:SetCursorPosition(0)

		setWarFrameStatus() -- set the show status of the frames and elements
		setWarButtonChecks() -- set the button check statuses

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
		setWarTrackText()
	end
	if (event == "PLAYER_PVP_KILLS_CHANGED") then
		totalWarKills = GetPVPLifetimeStats();
		warKills = warKills + (totalWarKills - lastTotalWarKills)
		lastTotalWarKills = totalWarKills;
		if (highestWarKills <= warKills) then
			highestWarKills = warKills
		end
		pvpWarRank = UnitHonorLevel("player");
		setWarTrackText()
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
				setWarTrackText()
			end
		end
	end





	if (event=="PLAYER_REGEN_DISABLED") then
		warCombatState = true
		if (warHideCombatState == true) then
			WarGhostFrame:Hide();
			if(warShowStates.warFrameState == true) then
				warTrackFrame:Hide()
			end
			if(warShowStates.warBountiesState == true) then
				warBountiesFrame:Hide()
			end
			if(cacheTrackerState == true) then
				warCacheFrame:Hide()
			end
		end
	end
	if (event=="PLAYER_REGEN_ENABLED") then
		warCombatState = false
		WarGhostFrame:Show();
		if(warShowStates.warFrameState == true) then
				warTrackFrame:Show()
		end
		if(warShowStates.warBountiesState == true) then
			warBountiesFrame:Show()
		end
		if(cacheTrackerState == true) then
			warCacheFrame:Show()
		end
	end
	if(event=="ZONE_CHANGED_NEW_AREA") then
		if(killingBlowResetZone == true) then
			totalWarKillingBlows = 0
		end
		namespace.SearchForBounties()
		setWarTrackText()


	end
	if(event=="ZONE_CHANGED") then
		--show war track frame if its not currently showing and warhidepvpstate is false
		if(warHidePvPState == true) then
			WarGhostFrame:Show()
			if (C_PvP.IsWarModeActive() == true) then
				if (warTrackFrame:IsShown() == false) then
					warTrackFrame:Show()
				end
				if(warBountiesFrame:IsShown() == false) then
					warBountiesFrame:Show()
				end
				if(warCacheFrame:IsShown() == false) then
					warCacheFrame:Show()
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
						parseWarCacheMessage(wmtLastCacheText, arg2)
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
isBountied()
if (currBounty == "ACTIVE")then
currBountyText:SetText("Bounty Status: " .. currBounty)
	if (checkSelfNotification == true) then
	setWMTNotificationText("A BOUNTY HAS BEEN PLACED ON YOUR HEAD", 6)
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
	showNotificationText()
	else
	hideNotificationText()
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
if (warNotificationButton:GetChecked() == false) then
warSoundNotificationSoundButton:SetChecked(false)
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
		if(warBountiesFrame:IsShown() == true) then
			warBountiesFrame:Hide()
		end
		if(warCacheFrame:IsShown() == true) then
			warCacheFrame:Hide()
		end
	end
end

if (warShowStates.warFrameState == false) then
	if (warTrackFrame:IsShown() == true) then
		warTrackFrame:Hide()
	end
end

if (warShowStates.warBountiesState == false) then
	if (warBountiesFrame:IsShown() == true) then
		warBountiesFrame:Hide()
	end
end

if (cacheTrackerState == false) then
	if (warCacheFrame:IsShown() == true) then
		warCacheFrame:Hide()
	end
end

--sets the never reset button to active is all other buttons are off.
	if(killingBlowResetDeath == false and killingBlowResetLoad == false and killingBlowResetZone == false) then
		warNeverResetButton:SetChecked(true)
	end

end)
