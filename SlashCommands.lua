--Lua file containing Slash command functionality for the addon
local addOnName, namespace = ...

--SLASH COMMANDS
function namespace.WMTSlashCommands(cmd, editbox)
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
        SetTrackerStates(true)
        InitializeMainFrame()
        SetSettingsButtonStates()
        AdjustCacheFramePos()
    end
    if(string.lower(cmd) == "off") then
        print("|cffffff00 War Mode Tracker is now OFF |r")
        SetTrackerStates(false)
        InitializeMainFrame()
        SetSettingsButtonStates()
        AdjustCacheFramePos()
    end
    if(string.lower(cmd) == "lock") then
        if (FrameStates.lockFrameState == true) then
            print("|cffffff00 WMT Lock Status: UNLOCKED |r")
            FrameStates.lockFrameState = false
        else
            print("|cffffff00 WMT Lock Status: LOCKED |r")
            FrameStates.lockFrameState = true
        end
        InitializeMainFrame()
        SetSettingsButtonStates()
    end
    if(string.lower(cmd) == "hide in combat") then
        if(warHideCombatState == false) then
            print("|cffffff00 WMT Hide in Combat Status: ACTIVE |r")
            warHideCombatState = true
        else
            print("|cffffff00 WMT Hide in Combat Status: INACTIVE |r")
            warHideCombatState = false
        end
        InitializeMainFrame()
        SetSettingsButtonStates()
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
        InitializeMainFrame()
        SetSettingsButtonStates()
    end
    if(string.lower(cmd) == "main frame") then
        if(FrameStates.MainFrame == true) then
            print("|cffffff00 WMT Main Frame Status: INACTIVE |r")
            FrameStates.MainFrame = false
        else
            print("|cffffff00 WMT Main Frame Status: ACTIVE |r")
            FrameStates.MainFrame = true
        end
        InitializeMainFrame()
        SetSettingsButtonStates()
        AdjustCacheFramePos()
    end
    if(string.lower(cmd) == "bounty frame") then
        if(FrameStates.warBountiesState == true) then
            print("|cffffff00 WMT Bounty Frame Status: INACTIVE |r")
            FrameStates.warBountiesState = false
        else
            FrameStates.warBountiesState = true
            print("|cffffff00 WMT Bounty Frame Status: ACTIVE |r")
        end
        InitializeMainFrame()
        SetSettingsButtonStates()
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
        InitializeMainFrame()
        SetSettingsButtonStates()
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
        InitializeMainFrame()
        SetSettingsButtonStates()
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
        InitializeMainFrame()
        SetSettingsButtonStates()
    end
    if(string.lower(cmd) == "general message") then
        if(warcacheGeneral == true) then
            print("|cffffff00 WMT General Chat Notification Messages: INACTIVE |r")
            warcacheGeneral = false
        else
            print("|cffffff00 WMT General Chat Notification Messages: ACTIVE |r")
            warcacheGeneral = true
        end
        InitializeMainFrame()
        SetSettingsButtonStates()
    end
    if(string.lower(cmd) == "party message") then
        if(warcacheParty == true) then
            print("|cffffff00 WMT Party Chat Notification Messages: INACTIVE |r")
            warcacheParty = false
        else
            print("|cffffff00 WMT Party Chat Notification Messages: ACTIVE |r")
            warcacheParty = true
        end
        InitializeMainFrame()
        SetSettingsButtonStates()
    end
end
--create the wmt slash command
SLASH_WMT1 = '/wmt'
-- register the wmt slash commant and call the WMTSlashCommands function
SlashCmdList["WMT"] = namespace.WMTSlashCommands
