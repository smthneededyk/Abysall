-- Check if already loaded
if getgenv().Abysall then
    return 
end

local GameList = {
    [2440500124] = "Doors"
}

local BaseUrl = "https://raw.githubusercontent.com/smthneededyk/Abysall/refs/heads/main/"

-- 1. Initialize the global table FIRST so remote scripts can see it
getgenv().Abysall = {
    Legit = true,
    UILibrary = "Obsidian" -- Default fallback so Interface.luau doesn't break
}

-- 2. Safely load Environment
local envOk, Environment = pcall(function()
    return loadstring(game:HttpGet(BaseUrl .. "Environment.luau"))()
end)

if envOk and Environment then
    getgenv().Abysall.Environment = Environment
else
    warn("[Abysall Loader] Failed to load Environment.luau:\n", Environment)
    return
end

-- 3. Setup Services with CloneReference
local function CloneReference(Object)
    if getgenv().Abysall.Environment and getgenv().Abysall.Environment.cloneref then
        return getgenv().Abysall.Environment.cloneref(Object)
    else
        return Object
    end
end

local Services = setmetatable({}, {
    __index = function(self, Name)
        return CloneReference(game:GetService(Name))
    end
})

-- 4. Safely load ESP Library
local espOk, ESPLibrary = pcall(function()
    return loadstring(game:HttpGet(BaseUrl .. "ESP.luau"))()
end)
if espOk then
    getgenv().Abysall.ESPLibrary = ESPLibrary
else
    warn("[Abysall Loader] Failed to load ESP.luau:\n", ESPLibrary)
end

-- 5. Handle UserData (Safely)
if getgenv().Abysall.Environment.writefile and getgenv().Abysall.Environment.readfile then
    if not getgenv().Abysall.Environment.isfile("Abysall/UserData.json") then
        local Data = {
            TotalExecutions = 0,
            UILibrary = "Obsidian"
        }
        getgenv().Abysall.Environment.writefile("Abysall/UserData.json", Services.HttpService:JSONEncode(Data))
    end

    local UserData = getgenv().Abysall.Environment.readfile("Abysall/UserData.json")
    local Decoded = Services.HttpService:JSONDecode(UserData)
    
    if not Decoded.TotalExecutions then
        Decoded.TotalExecutions = 0    
    end
    Decoded.TotalExecutions = Decoded.TotalExecutions + 1

    if not Decoded.UILibrary then
        Decoded.UILibrary = "Obsidian"
    end

    getgenv().Abysall.TotalExecutions = Decoded.TotalExecutions
    getgenv().Abysall.UILibrary = Decoded.UILibrary

    getgenv().Abysall.Environment.writefile("Abysall/UserData.json", Services.HttpService:JSONEncode(Decoded))
end

-- 🚨 THE CRITICAL FIX 🚨
-- We MUST ensure UILibrary exists before Interface.luau reads it.
-- Otherwise, Interface.luau line 1 will crash with "index nil with 'Library'".
if not getgenv().Abysall.UILibrary then 
    getgenv().Abysall.UILibrary = "Obsidian" 
end

-- 6. Safely load Interface
local intOk, Interface = pcall(function()
    return loadstring(game:HttpGet(BaseUrl .. "Interface.luau"))()
end)

if intOk and Interface then
    getgenv().Abysall.Interface = Interface
else
    warn("[Abysall Loader] Failed to load Interface.luau:\n", Interface)
    return -- Stop execution, UI is broken
end

-- 7. Safely load Analytics
local anaOk, Analytics = pcall(function()
    return loadstring(game:HttpGet(BaseUrl .. "Analytics.luau"))()
end)
if anaOk then
    getgenv().Abysall.Analytics = Analytics
else
    warn("[Abysall Loader] Failed to load Analytics.luau:\n", Analytics)
end

-- 8. Load the specific Game / Universal script
local CurrentGame = GameList[game.GameId]
local targetLoader = CurrentGame and "DLoader.luau" or "ULoader.luau"

local loadOk, loadErr = pcall(function()
    return loadstring(game:HttpGet(BaseUrl .. targetLoader))()
end)

if not loadOk then
    warn("[Abysall Loader] Failed to load " .. targetLoader .. ":\n", loadErr)
end
