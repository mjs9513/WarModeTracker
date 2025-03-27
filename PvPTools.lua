--Lua file containing functions for world pvp bounties
local addOnName, namespace = ...

--gets the name of the player
local PLAYER_NAME = GetUnitName("player", false)

--Gets the players total honorable kills
local _lastTotalWarKills = GetPVPLifetimeStats();

function namespace.PvPToolsInitialize()
    _lastTotalWarKills = GetPVPLifetimeStats();
    --get the total honor kills and pvp rank
    TotalWarKills = GetPVPLifetimeStats();
    lastTotalWarKills = GetPVPLifetimeStats();
    PvpWarRank = UnitHonorLevel("player")
    --Reset war kills
    if (WarKills ~= 0) then
        LastWarKills = WarKills
        WarKills = 0;
    end
    --reset killing blows
    if(KillingBlowResetLoad == true) then
        TotalWarKillingBlows = 0
    end
end

function namespace.PvPToolsOnZoneChanged()
    if(KillingBlowResetZone == true) then
        TotalWarKillingBlows = 0
    end
    namespace.SearchForBounties()
end

function namespace.PvPToolsOnPlayerDeath()
    if (HighestWarKills < WarKills) then
        HighestWarKills = WarKills
    end
    LastWarKills = WarKills
    WarKills = 0
    if(KillingBlowResetDeath == true) then
        TotalWarKillingBlows = 0
    end
    namespace.SetTrackerTexts()
end

function namespace.PvPToolsUpdateKills()
    TotalWarKills = GetPVPLifetimeStats();
    WarKills = WarKills + (TotalWarKills - _lastTotalWarKills)
    _lastTotalWarKills = TotalWarKills;
    if (HighestWarKills <= WarKills) then
        HighestWarKills = WarKills
    end
    PvpWarRank = UnitHonorLevel("player");
    namespace.SetTrackerTexts()
    
    --ToDo: Find a better way to do this
    --Deregister the event so it only fires once this frame
    warTrackFrame:UnregisterEvent("PLAYER_PVP_KILLS_CHANGED");
end

function namespace.CheckForKillingBlows()
    local _,warEventType, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _ = CombatLogGetCurrentEventInfo()
    if(warEventType=="PARTY_KILL") then
        local warUnitType = strsplit("-", destGUID)
        if (warUnitType == "Player" and PLAYER_NAME == sourceName)then
            TotalWarKillingBlows = TotalWarKillingBlows + 1
            namespace.SetTrackerTexts()
        end
    end
end

    --function for searching for bounties in an area, gets the info then uses the objectID from the Vignettes to get the name of the bountied players.
--C_VignetteInfo.GetVignettes() gives info on all bounties in a zone. Also stores the names from the table to the string
--the bottom if statement also sets the text for the notification if a new enemy bounty has appeared based on the list of enemy bounties changing
function namespace.SearchForBounties()
    --_,vignetteGUID gets the GUID of the vignette. the _, is for the index, its a throwaway value. Just 1, 2, 3, etc.
    if(FrameStates.warBountiesState == true)then
        local enemyBountyNames = {}
        namespace.EnemyBountyList = " "
        for _, vignetteGUID in pairs(C_VignetteInfo.GetVignettes()) do
            local vignetteInfo = C_VignetteInfo.GetVignetteInfo(vignetteGUID)
            --ATEMPT TO INDEX A NILL VALUE, LINE 349 "vignetteInfo" - Fixed
            if (vignetteInfo ~= nil and vignetteInfo.type ~= nil) then
                if vignetteInfo.type == 1 then
                    local _, bountyClass, _, _, _, bountyName, _ = GetPlayerInfoByGUID(vignetteInfo.objectGUID)
                    if (bountyName ~= nil) then
                        if(bountyClass ~= nil) then
                            local coloredBounty
                            if(bountyClass == "DEATHKNIGHT") then
                                coloredBounty = "|cFFC41F3B" .. bountyName .. "|r"
                            end
                            if(bountyClass == "WARRIOR") then
                                coloredBounty = "|cFFC79C6E" .. bountyName .. "|r"
                            end
                            if(bountyClass == "PALADIN") then
                                coloredBounty = "|cFFF58CBA" .. bountyName .. "|r"
                            end
                            if(bountyClass == "HUNTER") then
                                coloredBounty = "|cFFABD473" .. bountyName .. "|r"
                            end
                            if(bountyClass == "ROGUE") then
                                coloredBounty = "|cFFFFF569" .. bountyName .. "|r"
                            end
                            if(bountyClass == "PRIEST") then
                                coloredBounty = "|cFFFFFFFF" .. bountyName .. "|r"
                            end
                            if(bountyClass == "SHAMAN") then
                                coloredBounty = "|cFF0070DE" .. bountyName .. "|r"
                            end
                            if(bountyClass == "MAGE") then
                                coloredBounty = "|cFF40C7EB" .. bountyName .. "|r"
                            end
                            if(bountyClass == "WARLOCK") then
                                coloredBounty = "|cFF8787ED" .. bountyName .. "|r"
                            end
                            if(bountyClass == "MONK") then
                                coloredBounty = "|cFF00FF96" .. bountyName .. "|r"
                            end
                            if(bountyClass == "DRUID") then
                                coloredBounty = "|cFFFF7D0A" .. bountyName .. "|r"
                            end
                            if(bountyClass == "DEMONHUNTER") then
                                coloredBounty = "|cFFA330C9" .. bountyName .. "|r"
                            end
                            table.insert(enemyBountyNames, coloredBounty)
                        else
                            table.insert(enemyBountyNames, bountyName)
                        end
                    end
                end
            end
        end
        namespace.EnemyWarBounties = enemyBountyNames
        for i = 1,table.getn(namespace.EnemyWarBounties),1 do               -- *condition* and *ifTrue* or *ifFalse*  === i != table.getn(warbounties) ? "," : ""
            namespace.EnemyBountyList = namespace.EnemyBountyList .. " "  .. (i ~= table.getn(namespace.EnemyWarBounties) and tostring(namespace.EnemyWarBounties[i]) .. "," or tostring(namespace.EnemyWarBounties[i]));
        end
        if (table.getn(enemyBountyNames) > namespace.numEnemyBounties) then
            namespace.SetNotificationText("A NEW ENEMY BOUNTY HAS APPEARED", 6)
            namespace.numEnemyBounties = table.getn(enemyBountyNames)
        else
            namespace.numEnemyBounties = table.getn(enemyBountyNames)
        end
        namespace.SetTrackerTexts()
    end
end

--Checks if the player is bountied. AuraUtil.FindAuraByName searches the player for a specified buff/debuff. Third parameter is the filter (one string separated by spaces), its very specific
--also sets checkSelfNotification to true if they dont have a bounty so the addon re-checks for the next bounty occurence
function namespace.IsBountied()
    hasBounty = AuraUtil.FindAuraByName("Bounty Hunted", "player", "NOT_CANCELABLE HARMFUL")
    if (hasBounty ~= nil) then
        namespace.CurrentBountyStatus = "ACTIVE"
        return true;
    else
        namespace.CurrentBountyStatus = "INACTIVE"
        namespace.CanAlertBountied = true
        return false;
    end
end