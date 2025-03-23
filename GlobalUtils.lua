--Lua file containing global methods

local addOnName, namespace = ...

--function for searching for bounties in an area, gets the info then uses the objectID from the Vignettes to get the name of the bountied players.
--C_VignetteInfo.GetVignettes() gives info on all bounties in a zone. Also stores the names from the table to the string
--the bottom if statement also sets the text for the notification if a new enemy bounty has appeared based on the list of enemy bounties changing
function namespace.SearchForBounties()
    --_,vignetteGUID gets the GUID of the vignette. the _, is for the index, its a throwaway value. Just 1, 2, 3, etc.
    if(FrameStates.warBountiesState == true)then
        local enemyBountyNames = {}
        namespace.enemyBountyList = " "
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
        enemyWarBounties = enemyBountyNames
        for i = 1,table.getn(enemyWarBounties),1 do
            namespace.enemyBountyList = namespace.enemyBountyList .. " " .. tostring(enemyWarBounties[i].. ",")
        end
        if (table.getn(enemyBountyNames) > namespace.numEnemyBounties) then
            SetNotificationText("A NEW ENEMY BOUNTY HAS APPEARED", 6)
            namespace.numEnemyBounties = table.getn(enemyBountyNames)
        else
            namespace.numEnemyBounties = table.getn(enemyBountyNames)
        end
        SetTrackText()
    end
end
