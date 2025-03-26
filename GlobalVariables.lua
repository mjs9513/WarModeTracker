--Lua file containing globally required variables for all classes

local addOnName, namespace = ...

--Add namespace to global
_G[addOnName] = namespace;

--Gets the player's faction
namespace.PlayerFaction = UnitFactionGroup("player");

namespace.TotalWarKills, _,_ = GetPVPLifetimeStats();
--stores current number of kills
WarKills = 0;
--container for last killing streak
LastWarKills = 0;
--container for highest killing streak
HighestWarKills = 0;
--stores the number of killing blows
TotalWarKillingBlows = 0
--Gets the player's PvP honor level
PvpWarRank = UnitHonorLevel("player") --ToDo: Replace with a variable that is just grabbed at run time? No need to store this
--variable for tracking the state in which killing blows will reset: 1 - Death, 2 - Zone change, 3 - Loading Screen
KillingBlowResetDeath = false;
KillingBlowResetZone = true;
KillingBlowResetLoad = true;
--Library that stores button states
FrameStates = {
    ["MainFrame"] = true,
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
KillingBlowState = true;
CacheTrackerState = true;

--Two booleans to track whether or not the text for the bounty notification, and the accompanying sound, should play
ShowWarTrackWarningNotification = true;
PlayWarTrackWarningNotification = true;
WarcacheParty = true;
WarcacheGeneral = false;
--two booleans for tracking whether the window is hidden or show in combat or when not in war mode
WarHidePvPState = false;
WarHideCombatState = false;

--Boolean for checking whether or not the player is in combat, specifically used for when hide in combat is checked and hide when not in war mode is unchecked
namespace.WarCombatState = false;

--string for bounty status
namespace.CurrentBountyStatus = "INACTIVE";

--boolean used to track if the player has gained a bounty
namespace.CanAlertBountied = true;

--Table that will store the names of every bountied enemy in the zone, later converetd to list in variable belwo
namespace.EnemyWarBounties = {};

--number of active bounties
namespace.numEnemyBounties = 0;

--String that will store the names of bountied enemy players 
namespace.EnemyBountyList = " ";
