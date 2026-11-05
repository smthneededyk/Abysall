print("[Abysall Debug] 1. Loader started")

if getgenv().Abysall then
    warn("[Abysall Debug] Script is already running!")
    return 
end

local GameList = {
    [2440500124] = "Doors"
}

local BaseUrl = "https://raw.githubusercontent.com/bocaj111004/Abysall/refs/heads/main/"

getgenv().Abysall = {
    Legit = true,
    UILibrary = "Obsidian"
}

print("[Abysall Debug] 2. Loading Environment...")
task.wait(0.1) -- Prevent HTTP Rate Limiting
local envOk, Environment = pcall(function()
    return loadstring(game:HttpGet(BaseUrl .. "Environment.luau"))()
end)

if envOk and Environment then
    getgenv().Abysall.Environment = Environment
    print("[Abysall Debug] 2a. Environment loaded successfully.")
else
    warn("[Abysall Debug] FATAL: Environment.luau failed to load!\n", Environment)
    return
end

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

print("[Abysall Debug] 3. Loading ESP...")
task.wait(0.1)
local espOk, ESPLibrary = pcall(function()
    return loadstring(game:HttpGet(BaseUrl .. "ESP.luau"))()
end)
if espOk then
    getgenv().Abysall.ESPLibrary = ESPLibrary
    print("[Abysall Debug] 3a. ESP loaded.")
else
    warn("[Abysall Debug] Failed to load ESP.luau:\n", ESPLibrary)
end

print("[Abysall Debug] 4. Checking UserData...")
if getgenv().Abysall.Environment.writefile and getgenv().Abysall.Environment.readfile then
    if not getgenv().Abysall.Environment.isfile("Abysall/UserData.json") then
        local Data = { TotalExecutions = 0, UILibrary = "Obsidian" }
        getgenv().Abysall.Environment.writefile("Abysall/UserData.json", Services.HttpService:JSONEncode(Data))
    end

    local UserData = getgenv().Abysall.Environment.readfile("Abysall/UserData.json")
    local Decoded = Services.HttpService:JSONDecode(UserData)
    
    if not Decoded.TotalExecutions then Decoded.TotalExecutions = 0 end
    Decoded.TotalExecutions = Decoded.TotalExecutions + 1
    if not Decoded.UILibrary then Decoded.UILibrary = "Obsidian" end

    getgenv().Abysall.TotalExecutions = Decoded.TotalExecutions
    getgenv().Abysall.UILibrary = Decoded.UILibrary

    getgenv().Abysall.Environment.writefile("Abysall/UserData.json", Services.HttpService:JSONEncode(Decoded))
else
    print("[Abysall Debug] 4a. writefile/readfile not supported by executor. Using defaults.")
    getgenv().Abysall.TotalExecutions = 1
end

if not getgenv().Abysall.UILibrary then 
    getgenv().Abysall.UILibrary = "Obsidian" 
end

print("[Abysall Debug] 5. Loading Interface...")
task.wait(0.1)
local intOk, Interface = pcall(function()
    return loadstring(game:HttpGet(BaseUrl .. "Interface.luau"))()
end)

if intOk and Interface then
    getgenv().Abysall.Interface = Interface
    print("[Abysall Debug] 5a. Interface loaded.")
else
    warn("[Abysall Debug] FATAL: Interface.luau failed to load!\n", Interface)
    return 
end

print("[Abysall Debug] 6. Loading Analytics...")
task.wait(0.1)
local anaOk, Analytics = pcall(function()
    return loadstring(game:HttpGet(BaseUrl .. "Analytics.luau"))()
end)
if anaOk then
    getgenv().Abysall.Analytics = Analytics
else
    warn("[Abysall Debug] Failed to load Analytics.luau:\n", Analytics)
end

print("[Abysall Debug] 7. Applying CreateWindow hook...")
if getgenv().Abysall.Interface.Library and getgenv().Abysall.Interface.Library.CreateWindow then
    local oldCreateWindow = getgenv().Abysall.Interface.Library.CreateWindow
    getgenv().Abysall.Interface.Library.CreateWindow = function(self, ...)
        local Window = oldCreateWindow(self, ...)
        
        if getgenv().Abysall.Interface.ApplyInfoTab then
            getgenv().Abysall.Interface.ApplyInfoTab(Window)
        end
        if getgenv().Abysall.Interface.ApplySettingsTab then
            getgenv().Abysall.Interface.ApplySettingsTab(Window)
        end
        
        return Window
    end
    print("[Abysall Debug] 7a. Hook applied successfully.")
else
    warn("[Abysall Debug] FATAL: Could not hook CreateWindow. Library is missing!")
end

print("[Abysall Debug] 8. Loading Game Loader...")
task.wait(0.1)
local CurrentGame = GameList[game.GameId]
local targetLoader = CurrentGame and "DLoader.luau" or "ULoader.luau"

local loadOk, loadErr = pcall(function()
    return loadstring(game:HttpGet(BaseUrl .. targetLoader))()
end)

if not loadOk then
    warn("[Abysall Debug] FATAL: " .. targetLoader .. " failed to load!\n", loadErr)
else
    print("[Abysall Debug] 8a. " .. targetLoader .. " loaded successfully!")
end
