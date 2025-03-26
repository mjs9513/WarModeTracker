--Lua file containing functions for world pvp war chests
local addOnName, namespace = ...

--TODO: Get an instance ID of the check and set in cache text since not actually using it on the frame display
_wmtWarCacheText = "War Cache Located - " .. 0 ..  " - " .. 0 .. " - " .. "No Zone"
_wmtLastCacheText = "War Cache Located - " .. 0 ..  " - " .. 0 .. " - " .. "No Zone"

--variable for storing the name of the last check moused over by the player
local _warChestType = " ";

function namespace.ScanForChests()
    local cursorText = _G["GameTooltipTextLeft"..1]
    local textExtractor = cursorText:GetText()
    if(textExtractor == "War Supply Chest" or textExtractor == "Secret Supply Chest" or textExtractor == "War Supply Crate") then
        if (CacheTrackerState == true) then
            local posX, posY = C_Map.GetPlayerMapPosition(C_Map.GetBestMapForUnit("player"), "player"):GetXY()
            posX = math.floor(posX * 100)
            posY = math.floor(posY * 100)
            local zoneName = GetZoneText()
            _wmtWarCacheText = "War Cache Located - " .. posX ..  " - " .. posY .. " - " .. zoneName;
            _warChestType = textExtractor;
            textExtractor = ""; -- reset textExtractor to blank
            
            --if the messages are inconsistent with each other
            if(_wmtLastCacheText ~= _wmtWarCacheText) then
                if (CacheTrackerState == true) then
                    local posX, posY = C_Map.GetPlayerMapPosition(C_Map.GetBestMapForUnit("player"), "player"):GetXY()
                    posX = math.floor(posX * 100)
                    posY = math.floor(posY * 100)
                    local id,channelName = GetChannelName("WMT");
                    if (id > 0 and channelName ~= nil and namespace.GetNotificationTimer() <= 0) then
                        C_ChatInfo.SendAddonMessage("wmt:", _wmtWarCacheText, "CHANNEL", id)
                        C_ChatInfo.SendAddonMessage("wmt:", _wmtWarCacheText, "RAID")
                    end
                    --IF THE USER CURRENTLY DOES NOT HAVE AN ACTIVE WAR CHEST LOADED IN THEIR FRAME
                    if (namespace.WarCacheText:GetText() == "NO ACTIVE WAR CHESTS") then
                        --if they set to notify party, notify party on the mouseover
                        if(WarcacheParty == true) then
                            if (IsInRaid()) then
                                SendChatMessage("WMT: " .. _warChestType .. " located near " .. posX .. ", " .. posY, "RAID")
                            else if (IsInGroup()) then
                                SendChatMessage("WMT: " .. _warChestType .. " located near " .. posX .. ", " .. posY, "PARTY")
                            end
                            end
                        end
                        --if set to notify general, notify general on the mouseover
                        if(WarcacheGeneral == true) then
                            local wmtChatIndex = GetChannelName("General")
                            local wmtChatNewIndex = GetChannelName("General - " .. GetZoneText())
                            if (wmtChatIndex~=nil and wmtChatIndex ~= 0) then
                                SendChatMessage("WMT: " .. _warChestType .. " located near " .. posX .. ", " .. posY, "CHANNEL", nil, wmtChatIndex)
                            else
                                if(wmtChatNewIndex ~= nil) then
                                    SendChatMessage("WMT: " .. _warChestType .. " located near " .. posX .. ", " .. posY, "CHANNEL", nil, wmtChatNewIndex)
                                end
                            end

                        end
                    end
                    _wmtLastCacheText = _wmtWarCacheText
                    namespace.WarCacheText:SetText("War Chest Spotted Near: " .. posX .. ", " .. posY)
                    namespace.CacheMessageCD = 200
                end
            end
        end
    end
end 

function namespace.UpdateWarChestTools(elapsed)
    --if the war cache timer is not 0, then count down till its 0 then reset it
    if (namespace.CacheMessageCD ~= 0) then
        if (namespace.CacheMessageCD < 1) then
            namespace.ResetCacheText()
        end
        namespace.CacheMessageCD = namespace.CacheMessageCD - elapsed
    end
end 