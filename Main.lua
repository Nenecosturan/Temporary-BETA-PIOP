
-- •PIOP• CONNECT — ZENITH V2.1
-- Part 1
local scriptSource = [[loadstring(game:HttpGet('https://raw.githubusercontent.com/Nenecosturan/Ping-Improve-PIOP-2.0/main/Main.lua'))()]]
if queue_on_teleport then
    pcall(function() queue_on_teleport(scriptSource) end)
end

local Rayfield        = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local TeleportService = game:GetService("TeleportService")
local HttpService     = game:GetService("HttpService")
local Stats           = game:GetService("Stats")
local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local LocalPlayer     = Players.LocalPlayer
local PlaceId         = game.PlaceId

_G.AutoHopEnabled   = false
_G.AutoHopRunning   = false
_G.AntiAFKEnabled   = false 
_G.PingThreshold    = 300    

local function GetCurrentPing()
    local ok, val = pcall(function()
        return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5)
    end)
    return ok and val or 999
end
-- Part 2

local ServerCache = {} 

local function FetchServers(limit)
    limit = limit or 100
    local ok, result = pcall(function()
        return HttpService:JSONDecode(
            game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=" .. limit)
        )
    end)
    if ok and result and result.data then
        ServerCache = result.data
        return result.data
    end
    return nil
end

-- Fixed here:
local function FindBestServer(servers)
    local best = nil
    local bestScore = math.huge

    for _, server in ipairs(servers) do
        if server.id ~= game.JobId and server.playing < server.maxPlayers then
        
            local fillRatio = server.playing / math.max(server.maxPlayers, 1)
            if fillRatio < bestScore then
                bestScore = fillRatio
                best = server
            end
        end
    end
    return best
end

-- Fixed here:
local function ForceRegionHop(displayName)
    Rayfield:Notify({
        Title = "Scanning...",
        Content = displayName .. " founding most suitable server....",
        Duration = 3
    })

    local servers = FetchServers(100)
    if not servers then
        Rayfield:Notify({Title = "ERROR", Content = "Server list isn't avaible.", Duration = 4})
        return
    end

    local target = FindBestServer(servers)
    if target then
        Rayfield:Notify({
            Title = "Connecting!",
            Content = "Target: " .. target.playing .. "/" .. target.maxPlayers .. " Server with players",
            Duration = 3
        })
        TeleportService:TeleportToPlaceInstance(PlaceId, target.id, LocalPlayer)
    else
        Rayfield:Notify({
            Title = "❌ Server not founded",
            Content = "Theres no avaible server.",
            Duration = 5
        })
    end
end

-- Added with 2.0:
local function RejoinCurrentServer()
    TeleportService:TeleportToPlaceInstance(PlaceId, game.JobId, LocalPlayer)
end

-- Part 3:
-- Rayfield UI

local Window = Rayfield:CreateWindow({
    Name = "•PIOP• Connect | ZENITH 2.0[NEW]",
    LoadingTitle = "ANALYZING SOURCE...",
    LoadingSubtitle = "Loading Components",
    Theme = "Serenity",
    ConfigurationSaving = { Enabled = false }
})

local TabSmart   = Window:CreateTab("Smart Connect",        "Zap")
local TabManual  = Window:CreateTab("Manual Routes",        "Map")
local TabBrowser = Window:CreateTab("Server Browser",       "Search")
local TabInfo    = Window:CreateTab("Game Info & Version",  "Database")
local TabSettings= Window:CreateTab("Settings",              "Settings")
local TabBackup  = Window:CreateTab("Backup Script",        6034287525)

-- Part 4
-- Added with 2.0:

TabSmart:CreateParagraph({
    Title = "Current Server",
    Content = "ID: " .. game.JobId:sub(1, 18) .. "...\nPlayers: " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers
})

local PingLabel    = TabSmart:CreateLabel("📡 Analyzing Ping...")
local PingHistory  = TabSmart:CreateLabel("📊 Ping history: --")
local FPSLabel     = TabSmart:CreateLabel("🖥️ FPS: --")

-- Added with 2.0:
local pingHistory = {}
local MAX_HISTORY = 5

task.spawn(function()
    local frameCount = 0
    local lastFPSTime = tick()

    RunService.RenderStepped:Connect(function()
        frameCount += 1
        local now = tick()
        if now - lastFPSTime >= 1 then
            local fps = math.floor(frameCount / (now - lastFPSTime))
            frameCount = 0
            lastFPSTime = now
            local fpsIcon = fps >= 55 and "🟢" or fps >= 28 and "🟡" or "🔴"
            pcall(function() FPSLabel:Set("🖥️ FPS: " .. fps .. " " .. fpsIcon) end)
        end
    end)


    while task.wait(1) do
        local ping = GetCurrentPing()

        table.insert(pingHistory, ping)
        if #pingHistory > MAX_HISTORY then
            table.remove(pingHistory, 1)
        end

        local icon = ping < 61  and "🔵"
                  or ping < 100 and "🟢"
                  or ping < 150 and "🟡"
                  or ping < 200 and "🔴"
                  or "💀"
            
        local avg = 0
        for _, v in ipairs(pingHistory) do avg += v end
        avg = math.floor(avg / #pingHistory)

        local histStr = ""
        for _, v in ipairs(pingHistory) do
            histStr = histStr .. v .. "ms "
        end

        pcall(function()
            PingLabel:Set("📡 Live Ping: " .. ping .. " ms " .. icon .. " | avrg: " .. avg .. "ms")
            PingHistory:Set("📊 Last " .. MAX_HISTORY .. ": " .. histStr)
        end)
    end
end)

TabSmart:CreateButton({
    Name = "⚡ • Smart-Connect •⚡",
    Callback = function() ForceRegionHop("The Best Server") end
})

TabSmart:CreateButton({
    Name = "🔁 • Rejoin Into Current Server •",
    Callback = function()
        Rayfield:Notify({Title = "Reconnecting...", Content = "Rejoining into the current server.", Duration = 2})
        RejoinCurrentServer()
    end
})

TabSmart:CreateButton({
    Name = "📋 |Copy Server ID|",
    Callback = function()
        print("Server ID: " .. game.JobId)
        Rayfield:Notify({Title = "Copied", Content = "Server ID has been writed to Output.", Duration = 3})
    end
})-- 
============================================================================
-- Part 5
-- Added with 2.0:

TabManual:CreateParagraph({
    Title = "⚠️ -NOTE-",
    Content = "This feature might not work properly because of Roblox API,use an VPN for better result."
})

TabManual:CreateButton({Name = "• Germany / Holland • 🇩🇪", Callback = function() ForceRegionHop("EU-West") end})
TabManual:CreateButton({Name = "• France / Spain • 🇫🇷",    Callback = function() ForceRegionHop("EU-South") end})
TabManual:CreateButton({Name = "• Romania / Greece • 🇷🇴",  Callback = function() ForceRegionHop("EU-East") end})

-- YENİ: Ek bölge rotaları
TabManual:CreateButton({Name = "• USA East • 🇺🇸",          Callback = function() ForceRegionHop("US-East") end})
TabManual:CreateButton({Name = "• Singapore / Asia • 🌏",   Callback = function() ForceRegionHop("AS-South") end})

-- Part 6
-- Fixed and new with 2.0:

local scanCount = 0  

TabBrowser:CreateButton({
    Name = "🔄 • Scan & Refresh Servers •",
    Callback = function()
        scanCount += 1
        local currentScan = scanCount

        Rayfield:Notify({Title = "Scanning...", Content = "Getting Server list...", Duration = 2})

        local servers = FetchServers(10)
        if not servers then
            Rayfield:Notify({Title = "ERROR", Content = "Server list isn't avaible.", Duration = 4})
            return
        end

        table.sort(servers, function(a, b)
            return (a.playing / math.max(a.maxPlayers, 1)) < (b.playing / math.max(b.maxPlayers, 1))
        end)

        for i, v in ipairs(servers) do
            local current  = v.playing
            local max      = v.maxPlayers
            local pct      = math.floor((current / math.max(max, 1)) * 100)
            local isCurrent= v.id == game.JobId
            local status   = isCurrent and "📍 -Current-"
                          or current >= max and "🔴 Full"
                          or pct > 75 and "🟡 Almost Full"
                          or "🟢 Empty"

            -- Fixed:
            TabBrowser:CreateButton({
                Name = "[S" .. currentScan .. "] #" .. i .. " | 👥 " .. current .. "/" .. max .. " %" .. pct .. " | " .. status,
                Callback = function()
                    if isCurrent then
                        Rayfield:Notify({Title = "You're currently here", Content = "This is you'r current server", Duration = 3})
                        return
                    end
                    Rayfield:Notify({Title = "Connecting...", Content = current .. "/" .. max .. " Full server!", Duration = 2})
                    TeleportService:TeleportToPlaceInstance(PlaceId, v.id, LocalPlayer)
                end
            })
        end

        Rayfield:Notify({Title = "✅ Completed!", Content = #servers .. " Servers listed.", Duration = 3})
    end
})

-- New:
TabBrowser:CreateButton({
    Name = "🏃 • Connect into emptiest server •",
    Callback = function()
        if #ServerCache == 0 then
            Rayfield:Notify({Title = "Cache empty", Content = "Do Server Scan First!", Duration = 3})
            return
        end
        local target = FindBestServer(ServerCache)
        if target then
            TeleportService:TeleportToPlaceInstance(PlaceId, target.id, LocalPlayer)
        else
            Rayfield:Notify({Title = "Not Found", Content = "Scan again.", Duration = 3})
        end
    end
})-- 

-- Part 7
-- New with 2.0:

local serverStart = tick()

TabInfo:CreateParagraph({
    Title = "Game info",
    Content = "Place ID: " .. PlaceId .. "\nScript Version: V2.1 () (2026)\nGitHub: Nenecosturan/Ping-Improve-PIOP-2.0"
})

local UptimeLabel  = TabInfo:CreateLabel("⏱️ Server Uptime: --")
local PlayerLabel  = TabInfo:CreateLabel("👥 Players: --")

task.spawn(function()
    while task.wait(5) do
        local uptime  = math.floor(tick() - serverStart)
        local minutes = math.floor(uptime / 60)
        local seconds = uptime % 60

        pcall(function()
            UptimeLabel:Set("⏱️ Script Uptime: " .. minutes .. "Min " .. seconds .. "Sec")
            PlayerLabel:Set("👥 This Server: " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers)
        end)
    end
end)

-- Part 8
-- Fixed and new with 2.0

-- Fixed:
TabSettings:CreateSlider({
    Name = "Ping Spike threshold (ms)",
    Range = {100, 600},
    Increment = 25,
    CurrentValue = 300,
    Callback = function(Value)
        _G.PingThreshold = Value
        Rayfield:Notify({Title = "Changed", Content = "Auto-hop: " .. Value .. "ms Above", Duration = 2})
    end
})

-- Fixed:
TabSettings:CreateToggle({
    Name = "• Ping Spike Protection • (Auto-Hop)",
    CurrentValue = false,
    Callback = function(Value)
        _G.AutoHopEnabled = Value

        if Value and not _G.AutoHopRunning then
            _G.AutoHopRunning = true  

            task.spawn(function()
                Rayfield:Notify({Title = "Protection Active", Content = "Ping " .. _G.PingThreshold .. "if ms above auto-hop will be done.", Duration = 3})

                while _G.AutoHopEnabled do
                    task.wait(10)
                    local ping = GetCurrentPing()

                    if ping > _G.PingThreshold then
                        Rayfield:Notify({
                            Title = "⚠️ Ping Spike!",
                            Content = "Ping: " .. ping .. "ms — Changing Server...",
                            Duration = 4
                        })
                        ForceRegionHop("Auto-Hop")
                        task.wait(15)  -- Teleport sonrası stabilizasyon bekleme
                    end
                end

                _G.AutoHopRunning = false  -- Loop kapanınca flag'i sıfırla
            end)
        end
    end
})

-- New:
TabSettings:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = false,
    Callback = function(Value)
        _G.AntiAFKEnabled = Value

        if Value then
            task.spawn(function()
                while _G.AntiAFKEnabled do
                    task.wait(60)  -- Her 60 saniyede bir
                    if _G.AntiAFKEnabled then
                        -- Sanal jump input simüle et
                        local VirtualUser = game:GetService("VirtualUser")
                        pcall(function() VirtualUser:CaptureController() VirtualUser:ClickButton2(Vector2.new()) end)
                    end
                end
            end)
            Rayfield:Notify({Title = "Anti-AFK Active", Content = "Anti-afk is currently active.", Duration = 3})
        end
    end
})

TabSettings:CreateSlider({
    Name = "Render Quality |",
    Range = {1, 10},
    Increment = 1,
    CurrentValue = 10,
    Callback = function(Value)
        pcall(function() settings().Rendering.QualityLevel = Value end)
    end
})

-- New:
TabSettings:CreateButton({
    Name = "🗑️ • Refresh Ping history •",
    Callback = function()
        pingHistory = {}
        Rayfield:Notify({Title = "Refreshed", Content = "Refreshed Ping History.", Duration = 2})
    end
}) 
-- Part 9
-- New with 2.0:

TabBackup:CreateParagraph({
    Title = "Extra Script",
    Content = "Our backup script."
})

TabBackup:CreateButton({
    Name = "🚀 Load Backup Script (•PIOP•)",
    Callback = function()
        Rayfield:Notify({Title = "Loading...", Content = "Loading Source...", Duration = 3})
        local ok, err = pcall(function()
            loadstring(game:HttpGet(
                "https://raw.githubusercontent.com/Nenecosturan/Ping-Optimizer-PIOP-/refs/heads/main/Main.lua"
            ))()
        end)
        if ok then
            Rayfield:Notify({Title = "✅ Success", Content = "PIOP loaded.", Duration = 4})
        else
            Rayfield:Notify({Title = "❌ ERROR", Content = "PIOP Failed: " .. tostring(err):sub(1,60), Duration = 5})
        end
    end
})
