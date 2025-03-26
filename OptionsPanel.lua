--Lua file representing the Options -> AddOns panel for configuring the addon 

local addOnName, namespace = ...

--scale size for the WMT frame set
WMTFrameScale = 1;
-- RGB holders for the WarTrackFrame text
WarTextR = 1;
WarTextG = 1;
WarTextB = 1;
--RGBA holders for the WarTrackFrame background
WarFrameR = .1;
WarFrameG = .1;
WarFrameB = .1;
WarFrameTransparency = 0.7;

function SetSettingsButtonStates()
    --Sets the checked status of the buttons based on the saved variab;es
    MainTrackerFrameButton:SetChecked(FrameStates.MainFrame)
    LockFramesButton:SetChecked(FrameStates.lockFrameState)
    FactionLogoButton:SetChecked(FrameStates.logoState)
    TrackKillsButton:SetChecked(FrameStates.currKillState)
    ShowLastKillStreakButton:SetChecked(FrameStates.lastKillState)
    ShowHighestKillsButton:SetChecked(FrameStates.highestWarKillState)
    TrackBountyStatusButton:SetChecked(FrameStates.currBountyState)
    ShowTotalKillsButton:SetChecked(FrameStates.totalKillState)
    ShowPvpLvlButton:SetChecked(FrameStates.warPvPState)
    BountiesFrameButton:SetChecked(FrameStates.warBountiesState)
    namespace.ToggleNotificationsButton:SetChecked(ShowWarTrackWarningNotification)
    namespace.ToggleSoundNotificationsButton:SetChecked(PlayWarTrackWarningNotification)
    HideInCombatButton:SetChecked(WarHideCombatState)
    HideInPvPButton:SetChecked(WarHidePvPState)
    TrackKillingBlowsButton:SetChecked(KillingBlowState)
    CacheTrackerButton:SetChecked(CacheTrackerState)
    NotifyCachePartyButton:SetChecked(WarcacheParty)
    NotifyCacheGeneralButton:SetChecked(WarcacheGeneral)

    ResetOnDeathButton:SetChecked(KillingBlowResetDeath)
    ResetOnZoningButton:SetChecked(KillingBlowResetZone)
    ResetOnLoadButton:SetChecked(KillingBlowResetLoad)
    if(KillingBlowResetDeath == false and KillingBlowResetLoad == false and KillingBlowResetZone == false) then
        NeverResetButton:SetChecked(true)
    end
end

--Create the options panel frame
local WarTrackOptions = CreateFrame("Frame")
WarTrackOptions.name = addOnName
--InterfaceOptions_AddCategory(warTrackOptions)
category, layout = Settings.RegisterCanvasLayoutCategory(WarTrackOptions, WarTrackOptions.name, WarTrackOptions.name);
category.ID = WarTrackOptions.name
Settings.RegisterAddOnCategory(category);

--Add the addon title to the options panel
local title = WarTrackOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
title:SetTextColor(1, 1, .20)
title:SetPoint("CENTER", 0, 250)
title:SetText(addOnName)

--------------------SETTING UP THE OPTIONS PANEL BUTTONS - Buttons for enabling and disabling the text showing in the main panel
--War Frame Button
MainTrackerFrameButton = CreateFrame("CheckButton", "MainTrackerFrameButton_GlobalName", WarTrackOptions, "ChatConfigCheckButtonTemplate");
MainTrackerFrameButton:SetPoint("TOPLEFT", 16, -54);
MainTrackerFrameButton_GlobalNameText:SetText(" Display War Mode Tracker Frame");
MainTrackerFrameButton.tooltip = "Check to enable the War Mode Tracker Frame";
MainTrackerFrameButton:SetScript("OnClick",
        function(self)
            local checker = MainTrackerFrameButton:GetChecked()
            if checker then
                PlaySound(856) -- Check Click Sound
                FrameStates.MainFrame = true;
                ShowWarFrame(FrameStates.MainFrame);
                AdjustCacheFramePos()
            else
                PlaySound(857) -- Check Unclick Sound
                FrameStates.MainFrame = false;
                ShowWarFrame(FrameStates.MainFrame);
                AdjustCacheFramePos()
            end
        end);

--War Cache Tracker Button
CacheTrackerButton = CreateFrame("CheckButton", "CacheTrackerButton_GlobalName", WarTrackOptions, "ChatConfigCheckButtonTemplate");
CacheTrackerButton:SetPoint("CENTER", MainTrackerFrameButton, "CENTER", 300, 0);
CacheTrackerButton_GlobalNameText:SetText(" Enable the War Cache Tracker");
CacheTrackerButton.tooltip = "Check to enable the War Cache Tracker";
CacheTrackerButton:SetScript("OnClick",
        function(self)
            local checker = CacheTrackerButton:GetChecked()
            if checker then
                PlaySound(856) -- Check Click Sound
                CacheTrackerState = true;
                ShowWarCacheFrame(CacheTrackerState)
                AdjustCacheFramePos()
            else
                PlaySound(857) -- Check Unclick Sound
                CacheTrackerState = false;
                ShowWarCacheFrame(CacheTrackerState)
                AdjustCacheFramePos()
            end
        end);

--SendToPArty Button
NotifyCachePartyButton = CreateFrame("CheckButton", "NotifyCachePartyButton_GlobalName", WarTrackOptions, "ChatConfigCheckButtonTemplate");
NotifyCachePartyButton:SetPoint("TOPLEFT", CacheTrackerButton, "BOTTOMLEFT", 0, -4);
NotifyCachePartyButton_GlobalNameText:SetText(" Send a War Chest Notification to Party/Raid");
NotifyCachePartyButton.tooltip = "Check to send a message to the Party/Raid channel when you find a War Chest";
NotifyCachePartyButton:SetScript("OnClick",
        function(self)
            local checker = NotifyCachePartyButton:GetChecked()
            if checker then
                PlaySound(856) -- Check Click Sound
                WarcacheParty = true
            else
                PlaySound(857)
                WarcacheParty = false
            end
        end);

--SendToGeneral Button
NotifyCacheGeneralButton = CreateFrame("CheckButton", "NotifyCacheGeneralButton_GlobalName", WarTrackOptions, "ChatConfigCheckButtonTemplate");
NotifyCacheGeneralButton:SetPoint("TOPLEFT", NotifyCachePartyButton, "BOTTOMLEFT", 0, -4);
NotifyCacheGeneralButton_GlobalNameText:SetText(" Send a War Chest Notification to General");
NotifyCacheGeneralButton.tooltip = "Check to send a message to the General channel when you find a War Chest";
NotifyCacheGeneralButton:SetScript("OnClick",
        function(self)
            local checker = NotifyCacheGeneralButton:GetChecked()
            if checker then
                PlaySound(856) -- Check Click Sound
                WarcacheGeneral = true
            else
                PlaySound(857)
                WarcacheGeneral = false
            end
        end);

--War Notification Text Button
namespace.ToggleNotificationsButton = CreateFrame("CheckButton", "ToggleNotificationsButton_GlobalName", WarTrackOptions, "ChatConfigCheckButtonTemplate");
namespace.ToggleNotificationsButton:SetPoint("TOPLEFT", NotifyCacheGeneralButton, "BOTTOMLEFT", 0, -4);
ToggleNotificationsButton_GlobalNameText:SetText(" Display Notification Messages");
namespace.ToggleNotificationsButton.tooltip = "Check to enable Notification Messages";
namespace.ToggleNotificationsButton:SetScript("OnClick",
        function(self)
            local checker = namespace.ToggleNotificationsButton:GetChecked()
            if checker then
                PlaySound(856) -- Check Click Sound
                ShowWarTrackWarningNotification = true;
            else
                PlaySound(857) -- Check Unclick Sound
                ShowWarTrackWarningNotification = false;
            end
        end);

--War Notification Sound Button
namespace.ToggleSoundNotificationsButton = CreateFrame("CheckButton", "ToggleSoundNotificationsButton_GlobalName", WarTrackOptions, "ChatConfigCheckButtonTemplate");
namespace.ToggleSoundNotificationsButton:SetPoint("TOPLEFT", namespace.ToggleNotificationsButton, "BOTTOMLEFT", 20, -12);
ToggleSoundNotificationsButton_GlobalNameText:SetText(" Play the Notification Sound");
namespace.ToggleSoundNotificationsButton.tooltip = "Check to enable the Notification Sound";
namespace.ToggleSoundNotificationsButton:SetScript("OnClick",
        function(self)
            local checker = namespace.ToggleSoundNotificationsButton:GetChecked()
            if checker then
                PlaySound(856) -- Check Click Sound
                PlayWarTrackWarningNotification = true;
            else
                PlaySound(857) -- Check Unclick Sound
                PlayWarTrackWarningNotification = false;
            end
        end);






--Text for the options panel that displays the RGB specifications for the panel text color
local warKillBlowSetText = WarTrackOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal")
warKillBlowSetText:SetTextColor(1, 1, 1)
warKillBlowSetText:SetPoint("TOPLEFT", namespace.ToggleNotificationsButton, "BOTTOMLEFT", 0, -196)
warKillBlowSetText:SetText("Killing Blow Tracker Reset Events")

--ResetOnDeath Button
ResetOnDeathButton = CreateFrame("CheckButton", "ResetOnDeathButton_GlobalName", WarTrackOptions, "ChatConfigCheckButtonTemplate");
ResetOnDeathButton:SetPoint("TOPLEFT", warKillBlowSetText , "BOTTOMLEFT", 20, -12);
ResetOnDeathButton_GlobalNameText:SetText(" Reset on Death");
ResetOnDeathButton.tooltip = "Check to have the Killing Blow Tracker reset on player death";
ResetOnDeathButton:SetScript("OnClick",
        function(self)
            local checker = ResetOnDeathButton:GetChecked()
            if checker then
                PlaySound(856) -- Check Click Sound
                KillingBlowResetDeath = true
                NeverResetButton:SetChecked(false)
            else
                PlaySound(857)
                KillingBlowResetDeath = false;
            end
        end);

--ResetOnZone Button
ResetOnZoningButton = CreateFrame("CheckButton", "ResetOnZoningButton_GlobalName", WarTrackOptions, "ChatConfigCheckButtonTemplate");
ResetOnZoningButton:SetPoint("TOPLEFT", ResetOnDeathButton, "BOTTOMLEFT", 0, -4);
ResetOnZoningButton_GlobalNameText:SetText(" Reset on Zone Change");
ResetOnZoningButton.tooltip = "Check to have the Killing Blow Tracker reset on zone change";
ResetOnZoningButton:SetScript("OnClick",
        function(self)
            local checker = ResetOnZoningButton:GetChecked()
            if checker then
                PlaySound(856) -- Check Click Sound
                KillingBlowResetZone = true
                NeverResetButton:SetChecked(false)
            else
                PlaySound(857)
                KillingBlowResetZone = false
            end
        end);

--ResetOnLoad Button
ResetOnLoadButton = CreateFrame("CheckButton", "ResetOnLoadButton_GlobalName", WarTrackOptions, "ChatConfigCheckButtonTemplate");
ResetOnLoadButton:SetPoint("TOPLEFT", ResetOnZoningButton, "BOTTOMLEFT", 0, -4);
ResetOnLoadButton_GlobalNameText:SetText(" Reset on Load Screens");
ResetOnLoadButton.tooltip = "Check to have the Killing Blow Tracker reset on load screens";
ResetOnLoadButton:SetScript("OnClick",
        function(self)
            local checker = ResetOnLoadButton:GetChecked()
            if checker then
                PlaySound(856) -- Check Click Sound
                KillingBlowResetLoad = true
                NeverResetButton:SetChecked(false)
            else
                PlaySound(857)
                KillingBlowResetLoad = false
            end
        end);

--NeverReset Button
NeverResetButton = CreateFrame("CheckButton", "NeverResetButton_GlobalName", WarTrackOptions, "ChatConfigCheckButtonTemplate");
NeverResetButton:SetPoint("TOPLEFT", ResetOnLoadButton, "BOTTOMLEFT", 0, -4);
NeverResetButton_GlobalNameText:SetText(" Never Reset");
NeverResetButton.tooltip = "Check to have the Killing Blow Tracker never reset";
NeverResetButton:SetScript("OnClick",
        function(self)
            local checker = NeverResetButton:GetChecked()
            if checker then
                PlaySound(856) -- Check Click Sound
                KillingBlowResetDeath = false;
                KillingBlowResetLoad = false;
                KillingBlowResetZone = false;
                ResetOnDeathButton:SetChecked(false)
                ResetOnLoadButton:SetChecked(false)
                ResetOnZoningButton:SetChecked(false)
            else
                PlaySound(856)
                NeverResetButton:SetChecked(true)
            end
        end);




--Bounty Tracking Frame Button
BountiesFrameButton = CreateFrame("CheckButton", "BountiesFrameButton_GlobalName", WarTrackOptions, "ChatConfigCheckButtonTemplate");
BountiesFrameButton:SetPoint("TOPLEFT", MainTrackerFrameButton, "BOTTOMLEFT", 20, -12);
BountiesFrameButton_GlobalNameText:SetText(" Display War Bounty Tracker Frame");
BountiesFrameButton.tooltip = "Check to enable the War Mode Bounty Tracker Frame";
BountiesFrameButton:SetScript("OnClick",
        function(self)
            local checker = BountiesFrameButton:GetChecked()
            if checker then
                PlaySound(856) -- Check Click Sound
                FrameStates.warBountiesState = true;
                ShowBountyFrame(FrameStates.warBountiesState);
                AdjustCacheFramePos()
            else
                PlaySound(857) -- Check Unclick Sound
                FrameStates.warBountiesState = false;
                ShowBountyFrame(FrameStates.warBountiesState);
                AdjustCacheFramePos()
            end
        end);

--lock war frame button
LockFramesButton = CreateFrame("CheckButton", "LockFramesButton_GlobalName", WarTrackOptions, "ChatConfigCheckButtonTemplate");
LockFramesButton:SetPoint("TOPLEFT", BountiesFrameButton, "BOTTOMLEFT", 0, -12);
LockFramesButton_GlobalNameText:SetText(" Lock War Mode Tracker Frame");
LockFramesButton.tooltip = "Check to lock the War Mode Tracker Frame in place";
LockFramesButton:SetScript("OnClick",
        function(self)
            local checker = LockFramesButton:GetChecked()
            if checker then
                PlaySound(856) -- Check Click Sound
                FrameStates.lockFrameState = true;
                namespace.SetFramesInteractable(FrameStates.lockFrameState);
            else
                PlaySound(857) -- Check Unclick Sound
                FrameStates.lockFrameState = false;
                namespace.SetFramesInteractable(FrameStates.lockFrameState);
            end
        end);

--Hide in Combat frame button
HideInCombatButton = CreateFrame("CheckButton", "HideInCombatButton_GlobalName", WarTrackOptions, "ChatConfigCheckButtonTemplate");
HideInCombatButton:SetPoint("TOPLEFT", LockFramesButton, "BOTTOMLEFT", 0, -12);
HideInCombatButton_GlobalNameText:SetText(" Hide Frames in Combat");
HideInCombatButton.tooltip = "Check to hide the War Mode Tracker Frames when in combat";
HideInCombatButton:SetScript("OnClick",
        function(self)
            local checker = HideInCombatButton:GetChecked()
            if checker then
                PlaySound(856) -- Check Click Sound
                WarHideCombatState = true
            else
                PlaySound(857) -- Check Unclick Sound
                WarHideCombatState = false
            end
        end);

--Hide when not in War Mode frame button
HideInPvPButton = CreateFrame("CheckButton", "HideInPvPButton_GlobalName", WarTrackOptions, "ChatConfigCheckButtonTemplate");
HideInPvPButton:SetPoint("TOPLEFT", HideInCombatButton, "BOTTOMLEFT", 0, -12);
HideInPvPButton_GlobalNameText:SetText(" Hide Frames When Not In War Mode");
HideInPvPButton.tooltip = "Check to hide the War Mode Tracker Frames when not in War Mode";
HideInPvPButton:SetScript("OnClick",
        function(self)
            local checker = HideInPvPButton:GetChecked()
            if checker then
                PlaySound(856) -- Check Click Sound
                WarHidePvPState = true
                --placing it here to see what happens
                if(WarHidePvPState == true) then
                    if (C_PvP.IsWarModeActive() == false) then
                        WarGhostFrame:Hide()
                        if (warTrackFrame:IsShown() == true) then
                            warTrackFrame:Hide()
                        end
                        if(WarBountiesFrame:IsShown() == true) then
                            WarBountiesFrame:Hide()
                        end
                        if(WarCacheFrame:IsShown() == true)then
                            WarCacheFrame:Hide();
                        end
                    end
                end
            else
                PlaySound(857) -- Check Unclick Sound
                WarHidePvPState = false

                --placing it here to see what happens
                if(WarHidePvPState == false) then
                    WarGhostFrame:Show()
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
        end);

--faction banner war frame button
FactionLogoButton = CreateFrame("CheckButton", "FactionLogoButton_GlobalName", WarTrackOptions, "ChatConfigCheckButtonTemplate");
FactionLogoButton:SetPoint("TOPLEFT", HideInPvPButton, "BOTTOMLEFT", -20, -12);
FactionLogoButton_GlobalNameText:SetText(" Enable Faction Logo");
FactionLogoButton.tooltip = "Check to enable your Faction's logo";
FactionLogoButton:SetScript("OnClick",
        function(self)
            local checker = FactionLogoButton:GetChecked()
            if checker then
                PlaySound(856) -- Check Click Sound
                FrameStates.logoState = true;
                ShowFactionBanner(FrameStates.logoState);
            else
                PlaySound(857) -- Check Unclick Sound
                FrameStates.logoState = false;
                ShowFactionBanner(FrameStates.logoState);
            end
        end);

--Enable killing blows
TrackKillingBlowsButton = CreateFrame("CheckButton", "TrackKillingBlowsButton_GlobalName", WarTrackOptions, "ChatConfigCheckButtonTemplate");
TrackKillingBlowsButton:SetPoint("CENTER", FactionLogoButton, "CENTER", 300, 0);
TrackKillingBlowsButton_GlobalNameText:SetText(" Display Killing Blows");
TrackKillingBlowsButton.tooltip = "Check to enable the Killing Blows tracker";
TrackKillingBlowsButton:SetScript("OnClick",
        function(self)
            local checker = TrackKillingBlowsButton:GetChecked()
            if checker then
                PlaySound(856) -- Check Click Sound
                KillingBlowState = true
                ShowKillingBlowTracker(KillingBlowState)
            else
                PlaySound(857) -- Check Unclick Sound
                KillingBlowState = false
                ShowKillingBlowTracker(KillingBlowState)
            end
        end);

--pvp lvl frame button
ShowPvpLvlButton = CreateFrame("CheckButton", "ShowPvpLvlButton_GlobalName", WarTrackOptions, "ChatConfigCheckButtonTemplate");
ShowPvpLvlButton:SetPoint("TOPLEFT", FactionLogoButton, "BOTTOMLEFT", 0, -12);
ShowPvpLvlButton_GlobalNameText:SetText(" Display Honor Level");
ShowPvpLvlButton.tooltip = "Check to display your Honor Level";
ShowPvpLvlButton:SetScript("OnClick",
        function(self)
            local checker = ShowPvpLvlButton:GetChecked()
            if checker then
                PlaySound(856) -- Check Click Sound
                FrameStates.warPvPState = true;
                ShowPvPLevel(FrameStates.warPvPState);
            else
                PlaySound(857) -- Check Unclick Sound
                FrameStates.warPvPState = false;
                ShowPvPLevel(FrameStates.warPvPState);
            end
        end);

--Current Kills Button
TrackKillsButton = CreateFrame("CheckButton", "TrackKillsButton_GlobalName", WarTrackOptions, "ChatConfigCheckButtonTemplate");
TrackKillsButton:SetPoint("TOPLEFT", ShowPvpLvlButton, "BOTTOMLEFT", 0, -12);
TrackKillsButton_GlobalNameText:SetText(" Display Enemies Slain");
TrackKillsButton.tooltip = "Check to enable the Enemies Slain tracker";
TrackKillsButton:SetScript("OnClick",
        function(self)
            local checker = TrackKillsButton:GetChecked()
            if checker then
                PlaySound(856) -- Check Click Sound
                FrameStates.currKillState = true;
                ShowCurrentKills(FrameStates.currKillState);
            else
                PlaySound(857) -- Check Unclick Sound
                FrameStates.currKillState = false;
                ShowCurrentKills(FrameStates.currKillState);
            end
        end);

--Last Kills Button
ShowLastKillStreakButton = CreateFrame("CheckButton", "ShowLastKillStreakButton_GlobalName", WarTrackOptions, "ChatConfigCheckButtonTemplate");
ShowLastKillStreakButton:SetPoint("TOPLEFT", TrackKillsButton, "BOTTOMLEFT", 0, -12);
ShowLastKillStreakButton_GlobalNameText:SetText(" Display Last Kill Streak");
ShowLastKillStreakButton.tooltip = "Check to enable the Last Kill Streak tracker";
ShowLastKillStreakButton:SetScript("OnClick",
        function(self)
            local checker = ShowLastKillStreakButton:GetChecked()
            if checker then
                PlaySound(856) -- Check Click Sound
                FrameStates.lastKillState = true;
                ShowLastKill(FrameStates.lastKillState);
            else
                PlaySound(857) -- Check Unclick Sound
                FrameStates.lastKillState = false;
                ShowLastKill(FrameStates.lastKillState);
            end
        end);

--Highest Kills button
ShowHighestKillsButton = CreateFrame("CheckButton", "ShowHighestKillsButton_GlobalName", WarTrackOptions, "ChatConfigCheckButtonTemplate");
ShowHighestKillsButton:SetPoint("TOPLEFT", ShowLastKillStreakButton, "BOTTOMLEFT", 0, -12);
ShowHighestKillsButton_GlobalNameText:SetText(" Display Highest Kill Streak");
ShowHighestKillsButton.tooltip = "Check to enable the Highest Kill Streak tracker";
ShowHighestKillsButton:SetScript("OnClick",
        function(self)
            local checker = ShowHighestKillsButton:GetChecked()
            if checker then
                PlaySound(856) -- Check Click Sound
                FrameStates.highestWarKillState = true;
                ShowHighestKills(FrameStates.highestWarKillState);
            else
                PlaySound(857) -- Check Unclick Sound
                FrameStates.highestWarKillState = false;
                ShowHighestKills(FrameStates.highestWarKillState);
            end
        end);

--Current bounty button
TrackBountyStatusButton = CreateFrame("CheckButton", "TrackBountyStatusButton_GlobalName", WarTrackOptions, "ChatConfigCheckButtonTemplate");
TrackBountyStatusButton:SetPoint("TOPLEFT", ShowHighestKillsButton, "BOTTOMLEFT", 0, -12);
TrackBountyStatusButton_GlobalNameText:SetText(" Display Current Bounty Status");
TrackBountyStatusButton.tooltip = "Check to enable the Current Bounty Status tracker";
TrackBountyStatusButton:SetScript("OnClick",
        function(self)
            local checker = TrackBountyStatusButton:GetChecked()
            if checker then
                PlaySound(856) -- Check Click Sound
                FrameStates.currBountyState = true;
                ShowCurrentBounties(FrameStates.currBountyState);
            else
                PlaySound(857) -- Check Unclick Sound
                FrameStates.currBountyState = false;
                ShowCurrentBounties(FrameStates.currBountyState);
            end
        end);

--total kills button
ShowTotalKillsButton = CreateFrame("CheckButton", "ShowTotalKillsButton_GlobalName", WarTrackOptions, "ChatConfigCheckButtonTemplate");
ShowTotalKillsButton:SetPoint("TOPLEFT", TrackBountyStatusButton, "BOTTOMLEFT", 0, -12);
ShowTotalKillsButton_GlobalNameText:SetText(" Display Total Character PvP Kills");
ShowTotalKillsButton.tooltip = "Check to enable the Total Character PvP Kills tracker";
ShowTotalKillsButton:SetScript("OnClick",
        function(self)
            local checker = ShowTotalKillsButton:GetChecked()
            if checker then
                PlaySound(856) -- Check Click Sound
                FrameStates.totalKillState = true;
                ShowTotalKills(FrameStates.totalKillState);
            else
                PlaySound(857) -- Check Unclick Sound
                FrameStates.totalKillState = false;
                ShowTotalKills(FrameStates.totalKillState);
            end
        end);

--Text for the options panel that displays the RGB specifications for the panel text color
local rgbWarText = WarTrackOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal")
rgbWarText:SetTextColor(1, 1, 1)
rgbWarText:SetPoint("LEFT", ShowTotalKillsButton, "RIGHT", -12, -30)
rgbWarText:SetText("Panel Text Color (RGB)")
--Text for the options panel that displays the RGBA specifications for the panel BACKGROUND
local warFrameRGBAText = WarTrackOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal")
warFrameRGBAText:SetTextColor(1, 1, 1)
warFrameRGBAText:SetPoint("LEFT", rgbWarText, "RIGHT", 70, 0)
warFrameRGBAText:SetText("Panel Background Color (RGBA)")

--------------------SETTING UP THE SCALE SLIDER--------------------------------------------------

--Create text for the slider
local WMTScaleText = WarTrackOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal")
WMTScaleText:SetPoint("BOTTOMLEFT", 255, 250)
WMTScaleText:SetText("WMT Frame Scale: ")

--Creating the Slider for the wmtScaleSlider
namespace.WMTScaleSlider = CreateFrame("Slider", "wmtScaleSliderGlobalName", WarTrackOptions, "OptionsSliderTemplate")
namespace.WMTScaleSlider:SetWidth(125)
namespace.WMTScaleSlider:SetHeight(15)
namespace.WMTScaleSlider:SetOrientation('HORIZONTAL')
namespace.WMTScaleSlider:SetPoint("CENTER", WMTScaleText, 125, 0);
namespace.WMTScaleSlider.tooltipText = 'Set the scale for the WMT frames' --Creates a tooltip on mouseover.
getglobal(namespace.WMTScaleSlider:GetName() .. 'Low'):SetText('.5'); --Sets the left-side slider text
getglobal(namespace.WMTScaleSlider:GetName() .. 'High'):SetText('2'); --Sets the right-side slider text
namespace.WMTScaleSlider:SetValueStep(.01)
namespace.WMTScaleSlider:SetMinMaxValues(.5, 2)
namespace.WMTScaleSlider:SetObeyStepOnDrag(true)
namespace.WMTScaleSlider:SetValue(WMTFrameScale)

--Creating editbox to show number for the slider
namespace.WMTScaleEditbox = CreateFrame("EditBox", "wmtScaleEditBoxGlobalName", WarTrackOptions, "InputBoxTemplate")
namespace.WMTScaleEditbox:ClearAllPoints()
namespace.WMTScaleEditbox:ClearFocus()
namespace.WMTScaleEditbox:SetSize(70, 30)
namespace.WMTScaleEditbox:SetPoint("LEFT", namespace.WMTScaleSlider, "RIGHT", 15, 0)
namespace.WMTScaleEditbox:SetText(namespace.WMTScaleSlider:GetValue())
namespace.WMTScaleEditbox:SetAutoFocus(false)
namespace.WMTScaleEditbox:SetCursorPosition(0)

--Scripts for changing the Slider Values and text box values

--Slider <- Edit Box
namespace.WMTScaleSlider:SetScript("OnValueChanged", function(self, value)
    WMTFrameScale = value;
    warTrackGhost:SetScale(value)
    WarBountiesFrame:SetScale(value)
    WarCacheFrame:SetScale(value)
    namespace.WMTScaleEditbox:SetText(string.sub(value, 1, 4))
end)

--Edit Box -> Slider
namespace.WMTScaleEditbox:SetScript("OnEnterPressed", function(self)
    local val = self:GetText()
    if tonumber(val) then
        sliderMin, sliderMax = namespace.WMTScaleSlider:GetMinMaxValues()
        if (tonumber(val) >= sliderMin and tonumber(val) <= sliderMax) then
            WMTFrameScale = val;
            namespace.WMTScaleSlider:SetValue(WMTFrameScale)
            self:ClearFocus()
        end
    else
        self:ClearFocus()
    end
end)


--------------------SETTING RBG Button Edit Boxes ------------------------------------------------
--Creating editbox for the red RBG text value
namespace.RedWarBox = CreateFrame("EditBox", "Red Box", WarTrackOptions, "InputBoxTemplate")
namespace.RedWarBox:SetNumeric()
namespace.RedWarBox:ClearAllPoints()
namespace.RedWarBox:ClearFocus()
namespace.RedWarBox:SetSize(30, 30)
namespace.RedWarBox:SetPoint("LEFT", ShowTotalKillsButton, "RIGHT", -15, -55)
namespace.RedWarBox:SetText(WarTextR * 100)
namespace.RedWarBox:SetAutoFocus(false)
namespace.RedWarBox:SetCursorPosition(0)

--Editbox script Red
namespace.RedWarBox:SetScript("OnEnterPressed", function(self)
    local val = self:GetNumber()
    if (val <= 100) then
        WarTextR = (val / 100);
        namespace.SetFrameTextColors()
        self:ClearFocus()
    else
        WarTextR = 100;
        namespace.SetFrameTextColors()
        self:SetText(100)
    end
end)

--Green color value edit box setup
namespace.GreenWarBox = CreateFrame("EditBox", "Green Box", WarTrackOptions, "InputBoxTemplate")
namespace.GreenWarBox:SetNumeric()
namespace.GreenWarBox:ClearAllPoints()
namespace.GreenWarBox:ClearFocus()
namespace.GreenWarBox:SetSize(30, 30)
namespace.GreenWarBox:SetPoint("CENTER", namespace.RedWarBox, "RIGHT", 45, 0)
namespace.GreenWarBox:SetText(WarTextG * 100)
namespace.GreenWarBox:SetAutoFocus(false)
namespace.GreenWarBox:SetCursorPosition(0)

--Editbox script Green
namespace.GreenWarBox:SetScript("OnEnterPressed", function(self)
    local val = self:GetNumber()
    if (val <= 100) then
        WarTextG = (val / 100);
        namespace.SetFrameTextColors()
        self:ClearFocus()
    else
        WarTextG = 100;
        namespace.SetFrameTextColors()
        self:SetNumber(100)
    end
end)

--Blue color value edit box setup
namespace.BlueWarBox = CreateFrame("EditBox", "Blue Box", WarTrackOptions, "InputBoxTemplate")
namespace.BlueWarBox:SetNumeric()
namespace.BlueWarBox:ClearAllPoints()
namespace.BlueWarBox:ClearFocus()
namespace.BlueWarBox:SetSize(30, 30)
namespace.BlueWarBox:SetPoint("CENTER", namespace.GreenWarBox, "RIGHT", 45, 0)
namespace.BlueWarBox:SetText(WarTextB * 100)
namespace.BlueWarBox:SetAutoFocus(false)
namespace.BlueWarBox:SetCursorPosition(0)

--Editbox script Blue
namespace.BlueWarBox:SetScript("OnEnterPressed", function(self)
    local val = self:GetNumber()
    if (val <= 100) then
        WarTextB = (val / 100);
        namespace.SetFrameTextColors()
        self:ClearFocus()
    else
        WarTextB = 100;
        namespace.SetFrameTextColors()
        self:SetNumber(100)
    end
end)


--Frame Red  value edit box setup
namespace.WarFrameRBox = CreateFrame("EditBox", "Warframe Red Box", WarTrackOptions, "InputBoxTemplate")
namespace.WarFrameRBox:SetNumeric()
namespace.WarFrameRBox:ClearAllPoints()
namespace.WarFrameRBox:ClearFocus()
namespace.WarFrameRBox:SetSize(30, 30)
namespace.WarFrameRBox:SetPoint("CENTER", BlueWarBox, "RIGHT", 85, 0)
namespace.WarFrameRBox:SetText(WarFrameR * 100)
namespace.WarFrameRBox:SetAutoFocus(false)
namespace.WarFrameRBox:SetCursorPosition(0)

--Editbox script Frame Red
namespace.WarFrameRBox:SetScript("OnEnterPressed", function(self)
    local val = self:GetNumber()
    if (val <= 100) then
        WarFrameR = (val / 100);
        namespace.SetFrameBackgrounds()
        self:ClearFocus()
    else
        WarFrameR = (100 / 10);
        namespace.SetFrameBackgrounds()
        self:SetNumber(100)
    end
end)

--Frame Green  value edit box setup
namespace.WarFrameGBox = CreateFrame("EditBox", "Warframe Green Box", WarTrackOptions, "InputBoxTemplate")
namespace.WarFrameGBox:SetNumeric()
namespace.WarFrameGBox:ClearAllPoints()
namespace.WarFrameGBox:ClearFocus()
namespace.WarFrameGBox:SetSize(30, 30)
namespace.WarFrameGBox:SetPoint("CENTER", namespace.WarFrameRBox, "RIGHT", 45, 0)
namespace.WarFrameGBox:SetText(WarFrameG * 100)
namespace.WarFrameGBox:SetAutoFocus(false)
namespace.WarFrameGBox:SetCursorPosition(0)

--Editbox script Frame Green
namespace.WarFrameGBox:SetScript("OnEnterPressed", function(self)
    local val = self:GetNumber()
    if (val <= 100) then
        WarFrameG = (val / 100);
        namespace.SetFrameBackgrounds()
        self:ClearFocus()
    else
        WarFrameG = (100 / 10);
        namespace.SetFrameBackgrounds()
        self:SetNumber(100)
    end
end)

--Frame Blue value edit box setup
namespace.WarFrameBBox = CreateFrame("EditBox", "Warframe Blue Box", WarTrackOptions, "InputBoxTemplate")
namespace.WarFrameBBox:SetNumeric()
namespace.WarFrameBBox:ClearAllPoints()
namespace.WarFrameBBox:ClearFocus()
namespace.WarFrameBBox:SetSize(30, 30)
namespace.WarFrameBBox:SetPoint("CENTER", namespace.WarFrameGBox, "RIGHT", 45, 0)
namespace.WarFrameBBox:SetText(WarFrameB * 100)
namespace.WarFrameBBox:SetAutoFocus(false)
namespace.WarFrameBBox:SetCursorPosition(0)

--Editbox script Frame Blue
namespace.WarFrameBBox:SetScript("OnEnterPressed", function(self)
    local val = self:GetNumber()
    if (val <= 100) then
        WarFrameB = (val / 100);
        namespace.SetFrameBackgrounds()
        self:ClearFocus()
    else
        WarFrameB = (100 / 10);
        namespace.SetFrameBackgrounds()
        self:SetNumber(100)
    end
end)

--Frame Alpha value edit box setup
namespace.WarFrameABox = CreateFrame("EditBox", "Warframe Alpha Box", WarTrackOptions, "InputBoxTemplate")
namespace.WarFrameABox:SetNumeric()
namespace.WarFrameABox:ClearAllPoints()
namespace.WarFrameABox:ClearFocus()
namespace.WarFrameABox:SetSize(30, 30)
namespace.WarFrameABox:SetPoint("CENTER", namespace.WarFrameBBox, "RIGHT", 45, 0)
namespace.WarFrameABox:SetText(WarFrameTransparency * 100)
namespace.WarFrameABox:SetAutoFocus(false)
namespace.WarFrameABox:SetCursorPosition(0)

--Editbox script Frame Alpha
namespace.WarFrameABox:SetScript("OnEnterPressed", function(self)
    local val = self:GetNumber()
    if (val <= 100) then
        WarFrameTransparency = (val / 100);
        namespace.SetFrameBackgrounds()
        self:ClearFocus()
    else
        WarFrameTransparency = (100 / 10);
        namespace.SetFrameBackgrounds()
        self:SetNumber(100)
    end
end)

-------CREATING THE RESET BUTTON FOR HIGHEST SCORE
local resetWarHighest = CreateFrame("Button", "Reset Highest Streak", WarTrackOptions, "BackdropTemplate")
resetWarHighest:SetPoint("LEFT", namespace.RedWarBox, "CENTER", -25, -28)
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
    HighestWarKills = 0;
    highestEnemiesText:SetText("Highest Streak: " .. HighestWarKills)
end)

--Script for the "Okay" button in the options menu, makes it so all edit boxes confirm and submit whats entered in them upon button press
WarTrackOptions.okay = function(self)
    local redWarVal = namespace.RedWarBox:GetText()
    WarTextR = (redWarVal / 100);
    namespace.RedWarBox:ClearFocus()

    local greenWarVal = namespace.GreenWarBox:GetText()
    WarTextG = (greenWarVal / 100);
    namespace.GreenWarBox:ClearFocus()

    local blueWarVal = BlueWarBox:GetText()
    WarTextB = (blueWarVal / 100);
    BlueWarBox:ClearFocus()

    local blueWarVal = BlueWarBox:GetText()
    WarTextB = (blueWarVal / 100);
    BlueWarBox:ClearFocus()

    local warFrameRVal = namespace.WarFrameRBox:GetText()
    WarFrameR = (warFrameRVal / 100);
    namespace.WarFrameRBox:ClearFocus()

    local warFrameGVal = namespace.WarFrameGBox:GetText()
    WarFrameG = (warFrameGVal / 100);
    namespace.WarFrameGBox:ClearFocus()

    local warFrameBVal = namespace.WarFrameBBox:GetText()
    WarFrameB = (warFrameBVal / 100);
    namespace.WarFrameBBox:ClearFocus()

    local WarFrameAVal = namespace.WarFrameABox:GetText()
    WarFrameTransparency = (WarFrameAVal / 100);
    namespace.WarFrameABox:ClearFocus()

    namespace.SetFrameBackgrounds()
    namespace.SetFrameTextColors()
end

----------------- FUNCTIONS -----------------------
function namespace.InitializeAddonMenu()
    --Set Editbox values for colors
    namespace.BlueWarBox:SetNumber(WarTextB * 100)
    namespace.GreenWarBox:SetNumber(WarTextG * 100)
    namespace.RedWarBox:SetNumber(WarTextR * 100)
    namespace.BlueWarBox:SetCursorPosition(0)
    namespace.GreenWarBox:SetCursorPosition(0)
    namespace.RedWarBox:SetCursorPosition(0)
    namespace.WarFrameRBox:SetCursorPosition(0)
    namespace.WarFrameBBox:SetCursorPosition(0)
    namespace.WarFrameGBox:SetCursorPosition(0)
    namespace.WarFrameABox:SetCursorPosition(0)
    namespace.WMTScaleSlider:SetValue(WMTFrameScale)
    namespace.WMTScaleEditbox:SetText(string.sub(WMTFrameScale, 1, 4))
    namespace.WMTScaleEditbox:SetCursorPosition(0)
end