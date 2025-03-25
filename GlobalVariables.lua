--Lua file containing globally required variables for all classes

local addOnName, namespace = ...

--Add namespace to global
_G[addOnName] = namespace;

namespace.TotalWarKills, _,_ = GetPVPLifetimeStats();

--Table that will store the names of every bountied enemy in the zone, later converetd to list in variable belwo
namespace.EnemyWarBounties = {}

--number of active bounties
namespace.numEnemyBounties = 0

--String that will store the names of bountied enemy players 
namespace.EnemyBountyList = " "