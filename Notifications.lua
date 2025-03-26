--Lua file representing the event notifications
local addOnName, namespace = ...

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