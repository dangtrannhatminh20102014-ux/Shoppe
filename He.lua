repeat task.wait() until game:IsLoaded()

local EggHub = getgenv().EggHub or {}

local autoskip = EggHub.autoskip or true
local SellAllTower = EggHub.SellAllTower or false
local AtWave = EggHub.AtWave or 0
local autoCommander = EggHub.autoCommander or true
local url = EggHub.MarcoUrl or "https://example.com/mymacro.lua"
local difficulty = EggHub.Difficulty or "Easy"
local map = EggHub.Map or "Retro Stained Temple"
local replay = EggHub.Replay or false

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local remoteFunction = ReplicatedStorage:WaitForChild("RemoteFunction")
local remoteEvent = ReplicatedStorage:WaitForChild("RemoteEvent")

local vu = game:GetService("VirtualUser")

player.Idled:Connect(function()
    vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

local skipVotingFlag = false

local function skipVoting()
    task.spawn(function()
        while skipVotingFlag do
            pcall(function()
                remoteFunction:InvokeServer("Voting", "Skip")
            end)
            task.wait(1)
        end
    end)
end

local function firstskip()
    skipVotingFlag = true
    skipVoting()
    task.spawn(function()
        task.wait(5)
        skipVotingFlag = false
    end)
end

task.spawn(function()
    if workspace:FindFirstChild("Elevators") then
        local args = {
            [1] = "Multiplayer",
            [2] = "v2:start",
            [3] = {
                count = 1,
                mode = "survival",
                difficulty = difficulty
            }
        }
        remoteFunction:InvokeServer(unpack(args))
    else
        task.wait(10)
        remoteFunction:InvokeServer("LobbyVoting", "Override", map)
        remoteEvent:FireServer("LobbyVoting", "Vote", map, Vector3.new(14.947, 9.6, 55.556))
        remoteEvent:FireServer("LobbyVoting", "Ready")
        task.wait(7)
        remoteFunction:InvokeServer("Voting", "Skip")
        task.wait(1)
    end
end)

local towerFolder = workspace:WaitForChild("Towers")

local cashLabel = player.PlayerGui
    :WaitForChild("ReactUniversalHotbar")
    :WaitForChild("Frame")
    :WaitForChild("values")
    :WaitForChild("cash")
    :WaitForChild("amount")

local waveContainer = player.PlayerGui
    :WaitForChild("ReactGameTopGameDisplay")
    :WaitForChild("Frame")
    :WaitForChild("wave")
    :WaitForChild("container")

local gameOverGui = player.PlayerGui
    :WaitForChild("ReactGameNewRewards")
    :WaitForChild("Frame")
    :WaitForChild("gameOver")

local function getCash()
    local rawText = cashLabel.Text or ""
    local cleaned = rawText:gsub("[^%d%-]", "")
    return tonumber(cleaned) or 0
end

local function waitForCash(amount)
    while getCash() < amount do
        task.wait(1)
    end
end

local function safeInvoke(args, cost)
    waitForCash(cost)
    pcall(function()
        remoteFunction:InvokeServer(unpack(args))
    end)
    task.wait(0.5)
end

local function isSamePos(a, b, eps)
    eps = eps or 0.05
    return math.abs(a.X - b.X) <= eps
       and math.abs(a.Y - b.Y) <= eps
       and math.abs(a.Z - b.Z) <= eps
end

function place(x, y, z, name, cost)
    local pos = Vector3.new(x, y, z)
    safeInvoke({"Troops", "Pl\208\176ce", {Rotation = CFrame.new(), Position = pos}, name}, cost)
end

function upgrade(x, y, z, cost)
    local pos = Vector3.new(x, y, z)
    local tower
    for _, t in ipairs(towerFolder:GetChildren()) do
        local tPos = (t.PrimaryPart and t.PrimaryPart.Position) or t.Position
        if isSamePos(tPos, pos) then
            tower = t
            break
        end
    end
    if tower then
        safeInvoke({"Troops", "Upgrade", "Set", {Troop = tower}}, cost)
    end
end

function sell(x, y, z)
    local pos = Vector3.new(x, y, z)
    local tower
    for _, t in ipairs(towerFolder:GetChildren()) do
        local tPos = (t.PrimaryPart and t.PrimaryPart.Position) or t.Position
        if isSamePos(tPos, pos) then
            tower = t
            break
        end
    end
    if tower then
        pcall(function()
            remoteFunction:InvokeServer("Troops", "Se\108\108", {Troop = tower})
        end)
    end
end

function sellAllTowers()
    for _, tower in ipairs(towerFolder:GetChildren()) do
        pcall(function()
            remoteFunction:InvokeServer("Troops", "Se\108\108", {Troop = tower})
        end)
        task.wait(0.1)
    end
end

local function getWave()
    for _, label in ipairs(waveContainer:GetDescendants()) do
        if label:IsA("TextLabel") then
            local waveNum = tonumber(label.Text:match("^(%d+)"))
            if waveNum then
                return waveNum
            end
        end
    end
    return nil
end

local function loadMacro(url)
    local macroCode
    local success, err = pcall(function()
        macroCode = game:HttpGet(url)
    end)
    if not success then
        warn("Không thể load macro:", err)
        return
    end
    local func, loadErr = loadstring(macroCode)
    if not func then
        warn("Lỗi load macro:", loadErr)
        return
    end
    pcall(func)
end

task.spawn(function()
    loadMacro(url)
end)

for _, label in ipairs(waveContainer:GetDescendants()) do
    if label:IsA("TextLabel") then
        label:GetPropertyChangedSignal("Text"):Connect(function()
            local wave = getWave()
            if wave == AtWave and SellAllTower then
                sellAllTowers()
            end
        end)
    end
end

gameOverGui:GetPropertyChangedSignal("Visible"):Connect(function()
    if gameOverGui.Visible then
        if replay then
            task.wait(2)
            firstskip()
        else
            task.wait(3)
            TeleportService:Teleport(game.PlaceId, player)
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if autoskip then
            pcall(function()
                remoteFunction:InvokeServer("Voting", "Skip")
            end)
        end
    end
end)

task.spawn(function()
    local success, vim = pcall(function()
        return game:GetService("VirtualInputManager")
    end)
    while task.wait(10) do
        if autoCommander and success and vim and vim.SendKeyEvent then
            pcall(function()
                vim:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                task.wait(0.00001)
                vim:SendKeyEvent(false, Enum.KeyCode.F, false, game)
            end)
        end
    end
end)
