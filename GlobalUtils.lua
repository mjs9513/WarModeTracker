--Lua file containing global methods

local addOnName, namespace = ...

--returns the number of items within a 'source' table, TEST FUNCTION
function namespace.GetActiveItems(source)
    return table.getn(source);
end