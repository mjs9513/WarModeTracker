--Lua file containing globally required variables for all classes

local addOnName, namespace = ...

--number of active bounties
namespace.numEnemyBounties = 0

--String that will store the names of bountied enemy players 
namespace.enemyBountyList = " "