-- Clear any old broken instances
getgenv().Abysall = nil
print("[Abysall Loader] Starting...")

local GameList = {
    [2440500124] = "Doors"
}

-- YOUR REPO
local BaseUrl = "https://raw.githubusercontent.com/smthneededyk/Abysall/refs/heads/main/"

getgenv().Abysall = {
    Legit = true,
    UILibrary = "Obsidian" 
}

print("[Abysall Loader] Loading Environment...")
local envOk, Environment = pcall(function()
    return loadstring(game:HttpGet(BaseUrl .. "Environment.luau"))()
end)

if envOk and Environment then
    getgenv().Abysall.Environment = Environment
    print("[Abysall Loader] Environment loaded.")
else
    warn("[Abysall Loader] FATAL: Failed to load Environment.luau.")
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

print("[Abysall Loader] Loading ESP...")
local espOk, ESPLibrary = pcall(function()
    return loadstring(game:HttpGet(BaseUrl .. "ESP.luau"))()
end)
if espOk then
    getgenv().Abysall.ESPLibrary = ESPLibrary
    print("[Abysall Loader] ESP loaded.")
else
    warn("[Abysall Loader] Failed to load ESP.luau.")
end

print("[Abysall Loader] Loading UserData...")
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
end

if not getgenv().Abysall.UILibrary then 
    getgenv().Abysall.UILibrary = "Obsidian" 
end

-- ==========================================
-- 🚨 THE ULTIMATE INTERFACE PATCHER 🚨
-- ==========================================
print("[Abysall Loader] Downloading and Patching Interface.luau...")
local httpOk, source = pcall(function()
    return game:HttpGet(BaseUrl .. "Interface.luau")
end)

if not httpOk or not source or source == "" then
    warn("[Abysall Loader] FATAL: Could not download Interface.luau.")
    return
end

-- 1. Redirect the broken Bocaj URLs to YOUR repo
source = source:gsub("https://raw.githubusercontent.com/bocaj111004/Abysall/refs/heads/main/", BaseUrl)

-- 2. Prevent the tabs from executing immediately (removes the () at the end)
source = source:gsub('ApplyInfoTab = loadstring%(game:HttpGet%(AbysallUrl %.%. "Components/InfoTab.luau"%)%)', 'ApplyInfoTab = loadstring(game:HttpGet(AbysallUrl .. "Components/InfoTab.luau"))')
source = source:gsub('ApplySettingsTab = loadstring%(game:HttpGet%(AbysallUrl %.%. "Components/SettingsTab.luau"%)%)', 'ApplySettingsTab = loadstring(game:HttpGet(AbysallUrl .. "Components/SettingsTab.luau"))')

-- 3. ADD THE MISSING `return Interface` to the end of the script!
if not source:find("return Interface") then
    source = source .. "\n\nreturn Interface\n"
end

print("[Abysall Loader] Compiling Interface.luau...")
local compileOk, funcOrErr = pcall(function()
    return loadstring(source)
end)

if not compileOk or not funcOrErr then
    warn("[Abysall Loader] FATAL: Syntax error in Interface.luau:\n" .. tostring(funcOrErr))
    return
end

print("[Abysall Loader] Executing Interface.luau...")
local execOk, Interface = pcall(funcOrErr)

if execOk and Interface then
    getgenv().Abysall.Interface = Interface
    print("[Abysall Loader] Interface loaded successfully!")
else
    warn("[Abysall Loader] FATAL: Error occurred while running Interface.luau:\n" .. tostring(Interface))
    return 
end
-- ==========================================

print("[Abysall Loader] Loading Analytics...")
local anaOk, Analytics = pcall(function()
    return loadstring(game:HttpGet(BaseUrl .. "Analytics.luau"))()
end)
if anaOk then
    getgenv().Abysall.Analytics = Analytics
end

print("[Abysall Loader] Hooking Window creation...")
if getgenv().Abysall.Interface.Library and getgenv().Abysall.Interface.Library.CreateWindow then
    local oldCreateWindow = getgenv().Abysall.Interface.Library.CreateWindow
    getgenv().Abysall.Interface.Library.CreateWindow = function(self, ...)
        local Window = oldCreateWindow(self, ...)
        
        -- Apply tabs now that Window exists
        if getgenv().Abysall.Interface.ApplyInfoTab then
            getgenv().Abysall.Interface.ApplyInfoTab(Window)
        end
        if getgenv().Abysall.Interface.ApplySettingsTab then
            getgenv().Abysall.Interface.ApplySettingsTab(Window)
        end
        
        return Window
    end
    print("[Abysall Loader] Window hook applied.")
else
    warn("[Abysall Loader] FATAL: Failed to hook window. UI Library missing.")
end

print("[Abysall Loader] Loading Game Loader...")
local CurrentGame = GameList[game.GameId]
local targetLoader = CurrentGame and "DLoader.luau" or "ULoader.luau"

local loadOk, loadErr = pcall(function()
    return loadstring(game:HttpGet(BaseUrl .. targetLoader))()
end)

if not loadOk then
    warn("[Abysall Loader] FATAL: Failed to load " .. targetLoader .. "\n" .. tostring(loadErr))
else
    print("[Abysall Loader] Done! Script loaded.")
end
