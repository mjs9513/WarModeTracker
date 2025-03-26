--Lua file representing the event notifications
local addOnName, namespace = ...

local _wmtPrefCheck;

--variable for storing the timer for the War Caches
namespace.CacheMessageCD = 0; --ToDo: make this not globally accessible. Make it accessible with getters

--timer for the notification of bounties to display on screen
local _notificationTimer = 0

--setup for the text that displays the bounty notifications on screen
namespace.WarModeNotificationText = WarBountiesFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
namespace.WarModeNotificationText:SetPoint("CENTER", UIParent,"TOP", 0, -125)
namespace.WarModeNotificationText:SetText(" ")
namespace.WarModeNotificationText:SetFont("Fonts\\FRIZQT__.TTF", 35)
namespace.WarModeNotificationText:SetTextColor(1, .20, .20)
namespace.WarModeNotificationText:Hide()

function namespace.GetNotificationTimer()
    return _notificationTimer;
end

--function that sets the notification text, and the timer for which the notification text will display
function namespace.SetNotificationText(message, timer)
    if (ShowWarTrackWarningNotification == true) then
        namespace.WarModeNotificationText:SetText(message)
        if(PlayWarTrackWarningNotification == true) then
            PlaySoundFile(543587)
        end
        _notificationTimer = timer
    end
end

--function for showing bounty notification text
function namespace.ShowNotificationText()
    namespace.WarModeNotificationText:Show()
end

--function for hiding the notification text
function namespace.HideNotificationText()
    namespace.WarModeNotificationText:Hide()
end

function namespace.InitializeAddonMessages()
    _wmtPrefCheck = C_ChatInfo.RegisterAddonMessagePrefix("wmt:")
    if(GetChannelName("WMT") == 1) then
        local numChannels = C_ChatInfo.GetNumActiveChannels();
        for i=0,numChannels,1 do
            C_ChatInfo.SwapChatChannelsByChannelIndex(GetChannelName("WMT"), GetChannelName("WMT")+1);
        end
    end
end

function namespace.CheckAndJoinAddonChannel()
    if(GetNumDisplayChannels() >= 3) then
        --join the WMT CHANNEL
        if(GetChannelName("WMT") == 0) then
            JoinTemporaryChannel("WMT",nil, 4, nil)
        end
        namespace.InitializeAddonMessages();
        --Check to make sure it isnt listed as the first channel, if it is make it the last one
        RemoveChatWindowChannel(0, "WMT")
        ChatFrame_RemoveChannel(DEFAULT_CHAT_FRAME, "WMT")
        warTrackFrame:UnregisterEvent("CHANNEL_UI_UPDATE") -- unregister so it only runs once
    end
end

function namespace.UpdateNotifications(elapsed)
    --if the notification timers are not 0, then shows the notification. If its less than 1 then it hides it. While its not 0 it subtracts from it
    if (_notificationTimer ~= 0) then
        if (_notificationTimer > 1) then
            namespace.ShowNotificationText()
        else
            namespace.HideNotificationText()
        end
        _notificationTimer = _notificationTimer - elapsed
    end
end

function namespace.ParseAddonMessage(arg1, arg2)
    if (arg1 == "wmt:") then
        if (CacheTrackerState == true) then
            local message, locX, locY, zoneName = strsplit("-", arg2)
            local currZone = GetZoneText()
            currZone = string.gsub(currZone, " ", "");
            zoneName = string.gsub(zoneName, " ", "");
            if (tostring(currZone) == tostring(zoneName)) then
                namespace.ParseWarCacheMessage(_wmtLastCacheText, arg2)
            end
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
        _wmtLastCacheText = newCache
        _wmtWarCacheText = newCache
        namespace.WarCacheText:SetText("War Chest Spotted Near: " .. newX .. ", " .. newY)
        namespace.CacheMessageCD = 200
        namespace.SetNotificationText("A WAR CHEST HAS BEEN SPOTTED", 6)
        return true;
    end
    if (((tonumber(newX) >= tonumber(oldX) + 15) or (tonumber(newX) <= tonumber(oldX) - 15)) or ((tonumber(newY) >= tonumber(oldY) + 15) or (tonumber(newY) <= tonumber(oldY) - 15))) then
        _wmtLastCacheText = newCache
        _wmtWarCacheText = newCache
        namespace.WarCacheText:SetText("War Chest Spotted Near: " .. newX .. ", " .. newY)
        namespace.CacheMessageCD = 200
        namespace.SetNotificationText("A WAR CHEST HAS BEEN SPOTTED", 6)
        return true;
    end
end