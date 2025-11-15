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
    print("✅ Đã join game multiplayer")
    return -- DỪNG LẠI, không chạy phần còn lại
end

-- Nếu KHÔNG có Elevator = đã vào game/lobby map, chạy toàn bộ core
print("🎮 Bắt đầu core game logic...")
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

-- Anti-AFK
local vu = game:GetService("VirtualUser")
player.Idled:Connect(function()
    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- Cash functions
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

-- Tower functions
function place(x, y, z, name, cost)
    print("🔨 Đặt", name, "tại", string.format("(%.1f, %.1f, %.1f)", x, y, z), "- Giá:", cost)
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
    print("⬆️ Upgrade tower tại", string.format("(%.1f, %.1f, %.1f)", x, y, z), "- Giá:", cost)
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
    print("💰 Sell tower tại", string.format("(%.1f, %.1f, %.1f)", x, y, z))
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
    print("🗑️ Đang sell tất cả towers...")
    for _, t in ipairs(towerFolder:GetChildren()) do
        pcall(function()
            rf:InvokeServer("Troops", "Se\108\108", {Troop = t})
        end)
        task.wait(0.1)
    end
    print("✅ Đã sell hết towers")
end

-- Skip wave functions
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
    print("⏩ Auto skip đã bật")
end

local function firstskip()
    skipVotingFlag = true
    skipVoting()
    task.spawn(function()
        task.wait(5)
        skipVotingFlag = false
    end)
end

-- Wave detection
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

-- MACRO EXECUTOR - Chạy từng dòng
local function setupfarm()
    if not url or url == "" then
        warn("❌ Không có URL macro!")
        return
    end
    
    local rawUrl = url
    print("🔄 Đang load macro từ:", rawUrl)
    
    local content
    local success, err = pcall(function()
        content = game:HttpGet(rawUrl)
    end)
    
    if not success or not content then
        warn("❌ Không thể load file macro:", err)
        return
    end
    
    print("✅ Macro loaded thành công!")
    
    -- Chạy từng dòng trong coroutine riêng
    task.spawn(function()
        task.wait(3) -- Đợi game ổn định
        
        local lines = {}
        -- Parse tất cả dòng
        for line in content:gmatch("[^\r\n]+") do
            local trimmed = line:match("^%s*(.-)%s*$")
            if trimmed ~= "" and not trimmed:match("^%-%-") then
                table.insert(lines, trimmed)
            end
        end
        
        print("📋 Tổng số lệnh:", #lines)
        print("▶️ Bắt đầu execute macro...")
        
        -- Execute từng dòng
        for i, line in ipairs(lines) do
            print(string.format("📝 [%d/%d] %s", i, #lines, line))
            
            local func, loadErr = loadstring(line)
            if func then
                local ok, result = pcall(func)
                if not ok then
                    warn("❌ Lỗi khi chạy:", result)
                end
            else
                warn("❌ Không compile được:", loadErr)
            end
            
            -- Delay khác nhau cho place và upgrade
            if line:match("^place%(") then
                task.wait(0.5) -- Place delay lâu hơn
            elseif line:match("^upgrade%(") then
                task.wait(0.3) -- Upgrade nhanh hơn
            elseif line:match("^sell%(") then
                task.wait(0.2)
            else
                task.wait(0.1)
            end
        end
        
        print("🎉 Macro đã chạy xong tất cả lệnh!")
    end)
end

-- Wave change detection
for _, lbl in ipairs(waveContainer:GetDescendants()) do
    if lbl:IsA("TextLabel") then
        lbl:GetPropertyChangedSignal("Text"):Connect(function()
            local w = getWave()
            if w then
                print("🌊 Wave", w)
                
                if w == 1 then
                    print("🚀 Wave 1 - Bắt đầu farm!")
                    setupfarm()
                end
                
                if w == AtWave and SellAllTower then
                    print("⚠️ Đến wave", AtWave, "- Sell all towers!")
                    sellAllTowers()
                end
            end
        end)
    end
end

-- Auto Commander (spam F key)
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
    print("👔 Auto Commander đã bật")
end

-- Game over detection
gameOverGui:GetPropertyChangedSignal("Visible"):Connect(function()
    if gameOverGui.Visible then
        print("🏁 Game Over!")
        if replay then
            print("🔄 Replay mode - Khởi động lại...")
            task.wait(2)
            firstskip()
        else
            print("🚪 Teleport về lobby...")
            TeleportService:Teleport(3260590327)
        end
    end
end)

print("✅ Script đã khởi động hoàn tất!")
