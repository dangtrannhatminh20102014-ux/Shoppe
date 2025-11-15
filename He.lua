repeat task.wait() until game:IsLoaded()

local EggHub = getgenv().EggHub or {}
local autoskip = EggHub.autoskip
local SellAllTower = EggHub.SellAllTower
local AtWave = EggHub.AtWave
local autoCommander = EggHub.autoCommander
local url = EggHub.MarcoUrl
local difficulty = EggHub.Difficulty
local map = EggHub.Map
local replay = EggHub.Replay

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local rf = ReplicatedStorage:WaitForChild("RemoteFunction")
local re = ReplicatedStorage:WaitForChild("RemoteEvent")
local pg = player.PlayerGui

-- Nếu có Elevator = đang ở lobby chính, chỉ join game
if workspace:FindFirstChild("Elevators") then
    local args = {
        [1] = "Multiplayer",
        [2] = "v2:start",
        [3] = {
            ["count"] = 1,
            ["mode"] = "survival",
            ["difficulty"] = "Easy"
        }
    }
    rf:InvokeServer(unpack(args))
    return -- DỪNG LẠI, không chạy phần còn lại
end

-- Nếu KHÔNG có Elevator = đã vào game/lobby map, chạy toàn bộ core
task.wait(10)
rf:InvokeServer("LobbyVoting", "Override", map)
re:FireServer("LobbyVoting", "Vote", map, Vector3.new(14.947, 9.6, 55.556))
re:FireServer("LobbyVoting", "Ready")
task.wait(7)
rf:InvokeServer("Voting", "Skip")
task.wait(1)

local towerFolder = workspace:WaitForChild("Towers")
local cashLabel = pg:WaitForChild("ReactUniversalHotbar").Frame.values.cash.amount
local waveContainer = pg:WaitForChild("ReactGameTopGameDisplay").Frame.wave.container
local gameOverGui = pg:WaitForChild("ReactGameNewRewards").Frame.gameOver

local vu = game:GetService("VirtualUser")
player.Idled:Connect(function()
    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

local function getCash()
    return tonumber((cashLabel.Text or ""):gsub("[^%d%-]", "")) or 0
end

local function waitForCash(min)
    while getCash() < min do
        task.wait(1)
    end
end

local function safeInvoke(args, cost)
    waitForCash(cost)
    pcall(function()
        rf:InvokeServer(unpack(args))
    end)
    task.wait(1)
end

local function isSamePos(a, b, eps)
    eps = eps or 0.05
    return math.abs(a.X - b.X) <= eps and 
           math.abs(a.Y - b.Y) <= eps and 
           math.abs(a.Z - b.Z) <= eps
end

function place(x, y, z, name, cost)
    safeInvoke({
        "Troops",
        "Pl\208\176ce",
        {
            Rotation = CFrame.new(),
            Position = Vector3.new(x, y, z)
        },
        name
    }, cost)
end

function upgrade(x, y, z, cost)
    local pos = Vector3.new(x, y, z)
    for _, t in ipairs(towerFolder:GetChildren()) do
        local tPos = (t.PrimaryPart and t.PrimaryPart.Position) or t.Position
        if isSamePos(tPos, pos) then
            safeInvoke({
                "Troops",
                "Upgrade",
                "Set",
                {Troop = t}
            }, cost)
            break
        end
    end
end

function sell(x, y, z)
    local pos = Vector3.new(x, y, z)
    for _, t in ipairs(towerFolder:GetChildren()) do
        local tPos = (t.PrimaryPart and t.PrimaryPart.Position) or t.Position
        if isSamePos(tPos, pos) then
            pcall(function()
                rf:InvokeServer("Troops", "Se\108\108", {Troop = t})
            end)
            break
        end
    end
end

function sellAllTowers()
    for _, t in ipairs(towerFolder:GetChildren()) do
        pcall(function()
            rf:InvokeServer("Troops", "Se\108\108", {Troop = t})
        end)
        task.wait(0.1)
    end
end

local skipVotingFlag = false

local function skipVoting()
    task.spawn(function()
        while skipVotingFlag do
            pcall(function()
                rf:InvokeServer("Voting", "Skip")
            end)
            task.wait(1)
        end
    end)
end

local function skipwave()
    task.spawn(function()
        while true do
            pcall(function()
                rf:InvokeServer("Voting", "Skip")
            end)
            task.wait(1)
        end
    end)
end

if autoskip then
    skipwave()
end

local function firstskip()
    skipVotingFlag = true
    skipVoting()
    task.spawn(function()
        task.wait(5)
        skipVotingFlag = false
    end)
end

local function getWave()
    for _, lbl in ipairs(waveContainer:GetDescendants()) do
        if lbl:IsA("TextLabel") then
            local w = tonumber(lbl.Text:match("^(%d+)"))
            if w then
                return w
            end
        end
    end
end

local function setupfarm()
    local rawUrl = url
    local content
    local success, err = pcall(function()
        content = game:HttpGet(rawUrl)
    end)
    if not success or not content then
        warn("Không thể load file raw:", err)
        return
    end
    pcall(function()
        local f = loadstring(content)
        if f then f() end
    end)
end

for _, lbl in ipairs(waveContainer:GetDescendants()) do
    if lbl:IsA("TextLabel") then
        lbl:GetPropertyChangedSignal("Text"):Connect(function()
            local w = getWave()
            if w == 1 then
                setupfarm()
            end
            if w == AtWave and SellAllTower then
                sellAllTowers()
            end
        end)
    end
end

local interval = 10
local vim_ok, vim = pcall(function()
    return game:GetService("VirtualInputManager")
end)

local function autoCTA()
    if vim_ok and vim and vim.SendKeyEvent then
        pcall(function()
            vim:SendKeyEvent(true, Enum.KeyCode.F, false, game)
            task.wait()
            vim:SendKeyEvent(false, Enum.KeyCode.F, false, game)
        end)
    end
end

if autoCommander then
    task.spawn(function()
        while task.wait(interval) do
            autoCTA()
        end
    end)
end

gameOverGui:GetPropertyChangedSignal("Visible"):Connect(function()
    if gameOverGui.Visible then
        if replay then
            task.wait(2)
            firstskip()
        else
            TeleportService:Teleport(3260590327)
        end
    end
end)
