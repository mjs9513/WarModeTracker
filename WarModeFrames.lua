--Lua file representing the tracker frames that the user views and interacts with
local addOnName, namespace = ...

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
WarBountiesFrame = CreateFrame("Frame", "WarBountiesFrame", UIParent, "BackdropTemplate")
WarBountiesFrame:SetFrameStrata("BACKGROUND")
WarBountiesFrame:SetWidth(208) -- sets the width
WarBountiesFrame:SetHeight(75) -- sets the height
WarBountiesFrame:SetMovable(false)
WarBountiesFrame:EnableMouse(true)
WarBountiesFrame:SetPoint("BOTTOM", warTrackFrame, "BOTTOM", 0, -73) -- the y value was -86 before the addition of the killing blow tracker

--CREATE THE FRAME FOR WAR CACHE NOTICIATION
WarCacheFrame = CreateFrame("Frame", "WarCacheFrame", UIParent, "BackdropTemplate")
WarCacheFrame:SetFrameStrata("BACKGROUND")
WarCacheFrame:SetWidth(208) -- sets the width
WarCacheFrame:SetHeight(35) -- sets the height
WarCacheFrame:SetMovable(false)
WarCacheFrame:EnableMouse(true)

--adjust the frames such that the war cache frame snaps down to the bounty frames
--uses the GhostFrame to enable continuous movement
function namespace.AdjustCacheFramePos()
    if(FrameStates.MainFrame == true) then
        WarCacheFrame:SetPoint("Center", warTrackFrame, "Center", 0, 65)
        if(namespace.GetActiveItems(namespace.EnemyWarBounties) ~= nil and namespace.GetActiveItems(namespace.EnemyWarBounties) ~= 0) then
            WarBountiesFrame:SetPoint("BOTTOM", warTrackFrame, "BOTTOM", 0, -73)
        else
            WarBountiesFrame:SetPoint("BOTTOM", warTrackFrame, "BOTTOM", 0, -18)
        end
        WarGhostFrame:SetHeight(160);
    else
        if(FrameStates.warBountiesState == true) then
            if(namespace.GetActiveItems(namespace.EnemyWarBounties) ~= nil and namespace.GetActiveItems(namespace.EnemyWarBounties) ~= 0) then
                WarBountiesFrame:SetPoint("BOTTOM", WarCacheFrame, "Center", 0, -90);
            else
                WarBountiesFrame:SetPoint("BOTTOM", WarCacheFrame, "Center", 0, -35);
            end
            WarCacheFrame:SetPoint("TOP", WarGhostFrame, "TOP", 0, 0)
            WarGhostFrame:SetHeight(100);
        end
    end
end

--sets whether or not the faction banner is that of the alliance or horde
local _factionBanner = warTrackFrame:CreateTexture(nil,"ARTWORK")
if (namespace.PlayerFaction == "Alliance") then
    _factionBanner:SetTexture("Interface\\Timer\\Alliance-Logo.blp")
else
    _factionBanner:SetTexture("Interface\\Timer\\Horde-Logo.blp")
end

--Creating the background image for the frames, bg file is the background file it will call from
--edgefile is the border file it will call from, tile is whether the bg image is tiled or stretched out
--edge size is the size of the edge, basicall border thickness
--insets is think the dimensions in which the background will draw by. Idea is take edge size and divide by 4 for each.
function namespace.SetFrameBackgrounds()
    warTrackFrame:SetBackdrop( {
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = false, edgeSize = 10,
        insets = {left = 2.5, right = 2.5, top = 2.5, bottom = 2.5}});
    warTrackFrame:SetBackdropColor(WarFrameR, WarFrameG, WarFrameB, WarFrameTransparency);
    warTrackFrame:SetBackdropBorderColor(1, 1, 1)

    WarBountiesFrame:SetBackdrop( {
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = false, edgeSize = 10,
        insets = {left = 2.5, right = 2.5, top = 2.5, bottom = 2.5}});
    WarBountiesFrame:SetBackdropColor(WarFrameR, WarFrameG, WarFrameB, WarFrameTransparency);
    WarBountiesFrame:SetBackdropBorderColor(1, 1, 1)

    WarCacheFrame:SetBackdrop( {
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = false, edgeSize = 10,
        insets = {left = 2.5, right = 2.5, top = 2.5, bottom = 2.5}});
    WarCacheFrame:SetBackdropColor(WarFrameR, WarFrameG, WarFrameB, WarFrameTransparency);
    WarCacheFrame:SetBackdropBorderColor(1, 1, 1)

end

--text for honor level
namespace.WarHonorLvlText = warTrackFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
namespace.WarHonorLvlText:SetPoint("CENTER", _factionBanner, "TOP", 0, -8)


--text for number of current kills
namespace.WarEnemiesText = warTrackFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
namespace.WarEnemiesText:SetPoint("TOP", warTrackFrame, "TOP", 25, -5)

--text for tracking killing blows
namespace.WarTotalKillingBlowsText = warTrackFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
namespace.WarTotalKillingBlowsText:SetPoint("CENTER", namespace.WarEnemiesText, "TOP", 3, -21)

--text for the last kill streak
namespace.LastKillText = warTrackFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
namespace.LastKillText:SetPoint("CENTER", namespace.WarTotalKillingBlowsText, "TOP", 0, -21)



--text for highest number of kills
namespace.HighestEnemiesText = warTrackFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
namespace.HighestEnemiesText:SetPoint("CENTER", namespace.LastKillText, "TOP", 1, -21)



--text for tracking bounty status
namespace.CurrBountyText = warTrackFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
namespace.CurrBountyText:SetPoint("CENTER", namespace.HighestEnemiesText, "TOP", 2, -21)


--text for total number of kills on a character, adjusts the position based on the number for fitting purposes
namespace.TotalEnemiesText = warTrackFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
if (namespace.TotalWarKills <= 1000) then
    namespace.TotalEnemiesText:SetPoint("CENTER", namespace.HighestEnemiesText, "TOP", 0, -38)
else
    if (namespace.TotalWarKills <= 10000) then
        namespace.TotalEnemiesText:SetPoint("CENTER", namespace.HighestEnemiesText, "TOP", -2, -38)
    else
        namespace.TotalEnemiesText:SetPoint("CENTER", namespace.HighestEnemiesText, "TOP", -8, -38)
    end
end

--positions the faction banner within the frame
_factionBanner:SetPoint("LEFT", warTrackFrame, "LEFT", -15, -5)
_factionBanner:SetWidth(100)
_factionBanner:SetHeight(100)

--sets the intiial point for warTrackFrame
warTrackFrame:SetPoint("CENTER", WarGhostFrame, "CENTER", 0, 0);
warTrackFrame:Show()
WarBountiesFrame:Show()

--text for displaying the total number of bounties active
namespace.CurrNumEnemyBounties = WarBountiesFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
namespace.CurrNumEnemyBounties:SetPoint("CENTER", WarBountiesFrame, "TOP", 0, -9)

--text for displaying the total number of bounties active
namespace.EnemyBountiesText = WarBountiesFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
namespace.EnemyBountiesText:SetPoint("CENTER", namespace.CurrNumEnemyBounties, "CENTER", -51, -30)
namespace.EnemyBountiesText:SetText("Enemy Bounties: ")

--text for displaying the coords for a war CACHE
namespace.WarCacheText = WarCacheFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
namespace.WarCacheText:SetPoint("CENTER", WarCacheFrame, "CENTER", 0, 0)
namespace.WarCacheText:SetText("NO ACTIVE WAR CHESTS")

--Add the text to show enemy player names with bounties
namespace.PlayerBountiesText = WarBountiesFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
namespace.PlayerBountiesText:SetPoint("CENTER", namespace.CurrNumEnemyBounties, "CENTER", 40, -30)
namespace.PlayerBountiesText:SetWidth(110)
namespace.PlayerBountiesText:SetHeight(60)

--resets the text for the War Cache Tracker
function namespace.ResetCacheText()
    namespace.WarCacheText:SetText("NO ACTIVE WAR CHESTS")
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
        WarBountiesFrame:Show()
    else
        WarBountiesFrame:Hide()
    end
end

--function for specifying whether the faction banner is hidden or shown
function ShowFactionBanner(warLogoState)
    if (warLogoState == true) then
        _factionBanner:Show()
    else
        _factionBanner:Hide()
    end
end

--function for specifying whether the player pvp level is hidden or shown
function ShowPvPLevel(pvpLvlState)
    if (pvpLvlState == true) then
        namespace.WarHonorLvlText:Show()
    else
        namespace.WarHonorLvlText:Hide()
    end
end

--function for specifying whether the current enemy kill count is hidden or shown
function ShowCurrentKills(currKillState)
    if (currKillState == true) then
        namespace.WarEnemiesText:Show()
    else
        namespace.WarEnemiesText:Hide()
    end
end

--function for specifying whether the last kill streak is hidden or shown
function ShowLastKill(lastKillState)
    if (lastKillState == true) then
        namespace.LastKillText:Show()
    else
        namespace.LastKillText:Hide()
    end
end

--function for specifying whether the highest kill streak is hidden or shown
function ShowHighestKills(highestKillState)
    if (highestKillState == true) then
        namespace.HighestEnemiesText:Show()
    else
        namespace.HighestEnemiesText:Hide()
    end
end

--function for specifying whether the bounty active/inactive text is hidden or shown
function ShowCurrentBounties(currBountyState)
    if (currBountyState == true) then
        namespace.CurrBountyText:Show()
    else
        namespace.CurrBountyText:Hide()
    end
end

--function for specifying whether the total kill count is hidden or shown
function ShowTotalKills(totalKillState)
    if (totalKillState == true) then
        namespace.TotalEnemiesText:Show()
    else
        namespace.TotalEnemiesText:Hide()
    end
end

function ShowKillingBlowTracker(killingState)
    if (killingState == true) then
        namespace.WarTotalKillingBlowsText:Show()
    else
        namespace.WarTotalKillingBlowsText:Hide()
    end
end

--function for setting the visible state of the War Cache Tracker
function ShowWarCacheFrame(cacheTrackerState)
    if (cacheTrackerState == true) then
        WarCacheFrame:Show()
    else
        WarCacheFrame:Hide()
    end
end

--Function for setting up the text for the War Tracker panel, if there are no war bounties sets active bounties to 0, else gets num active bounties based on the list of names
--also sets the text to the list string
function namespace.SetTrackerTexts()
    namespace.TotalEnemiesText:SetText("Total Honor Kills: " .. namespace.TotalWarKills)
    namespace.HighestEnemiesText:SetText("Highest Streak: " .. HighestWarKills)
    namespace.LastKillText:SetText("Last Kill Streak: " .. LastWarKills)
    namespace.WarEnemiesText:SetText("Enemies Slain: " .. WarKills)
    namespace.CurrBountyText:SetText("Bounty Status: " .. namespace.CurrentBountyStatus)
    namespace.WarHonorLvlText:SetText("Lvl ".. PvpWarRank)
    namespace.WarTotalKillingBlowsText:SetText("Killing Blows: " .. TotalWarKillingBlows)
    if(namespace.GetActiveItems(namespace.EnemyWarBounties) ~= nil and namespace.GetActiveItems(namespace.EnemyWarBounties) ~= 0) then
        namespace.CurrNumEnemyBounties:SetText("Active Enemy Bounties: " .. namespace.GetActiveItems(namespace.EnemyWarBounties))
        namespace.PlayerBountiesText:SetText(namespace.EnemyBountyList)
        --set the bounties frame to the natural height and location
        namespace.AdjustCacheFramePos()
        WarBountiesFrame:SetHeight(75)
        namespace.EnemyBountiesText:Show()
    else
        namespace.CurrNumEnemyBounties:SetText("Active Enemy Bounties: 0")
        namespace.PlayerBountiesText:SetText(namespace.enemyBountyList)
        --no enemy bounties, shrink the frame
        WarBountiesFrame:SetHeight(20)
        if(FrameStates.MainFrame == false and FrameStates.warBountiesState == true) then
            namespace.AdjustCacheFramePos()
        else
            WarBountiesFrame:SetPoint("BOTTOM", warTrackFrame, "BOTTOM", 0, -18)
        end
        namespace.EnemyBountiesText:Hide()
    end
end

function namespace.SetLastKillStreakText(newText)
    namespace.LastKillText:SetText(newText)
end

function namespace.SetBountyStatus(newText)
    namespace.CurrBountyText:SetText("Bounty Status: " .. newText)
end

function namespace.InitializeMainFrame()
    --Sets the buttons to display on load based on saved variables
    ShowWarFrame(FrameStates.MainFrame);
    ShowCurrentKills(FrameStates.currKillState);
    ShowLastKill(FrameStates.lastKillState);
    ShowHighestKills(FrameStates.highestWarKillState);
    ShowCurrentBounties(FrameStates.currBountyState);
    ShowTotalKills(FrameStates.totalKillState);
    ShowFactionBanner(FrameStates.logoState);
    namespace.SetFramesInteractable(FrameStates.lockFrameState)
    ShowPvPLevel(FrameStates.warPvPState)
    ShowBountyFrame(FrameStates.warBountiesState)
    ShowKillingBlowTracker(KillingBlowState)
    ShowWarCacheFrame(CacheTrackerState)
end

--Function for setting the text color in the War Tracker panel
function namespace.SetFrameTextColors()
    namespace.WarEnemiesText:SetTextColor(WarTextR, WarTextG, WarTextB)
    namespace.WarTotalKillingBlowsText:SetTextColor(WarTextR, WarTextG, WarTextB)
    namespace.LastKillText:SetTextColor(WarTextR, WarTextG, WarTextB)
    namespace.HighestEnemiesText:SetTextColor(WarTextR, WarTextG, WarTextB)
    namespace.CurrBountyText:SetTextColor(WarTextR, WarTextG, WarTextB)
    namespace.TotalEnemiesText:SetTextColor(WarTextR, WarTextG, WarTextB)
    namespace.WarHonorLvlText:SetTextColor(WarTextR, WarTextG, WarTextB)

    namespace.CurrNumEnemyBounties:SetTextColor(WarTextR, WarTextG, WarTextB)
    namespace.PlayerBountiesText:SetTextColor(WarTextR, WarTextG, WarTextB)
    namespace.EnemyBountiesText:SetTextColor(WarTextR, WarTextG, WarTextB)
    namespace.WarCacheText:SetTextColor(WarTextR, WarTextG, WarTextB)
end

--function for specifying whether the main frame is movable or not. is hidden or shown
function namespace.SetFramesInteractable(lockState)
    if (lockState == false) then
        WarGhostFrame:EnableMouse(true)
        WarBountiesFrame:EnableMouse(true)
        WarCacheFrame:EnableMouse(true)
    else
        WarGhostFrame:EnableMouse(false)
        WarBountiesFrame:EnableMouse(false)
        WarCacheFrame:EnableMouse(false)
    end
end