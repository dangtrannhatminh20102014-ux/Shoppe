-- Services ---------------------------------------------------------------
local Players         = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")

local player     = Players.LocalPlayer
local playerGui  = player:WaitForChild("PlayerGui")
local remoteFunc = ReplicatedStorage:WaitForChild("RemoteFunction")
local remoteEvent = ReplicatedStorage:WaitForChild("RemoteEvent") 
local towersFolder = Workspace:WaitForChild("Towers")

-- ReturnHub Config --------------------------------------------------------
local ReturnHub = {
    autoskip        = false, 
    SellAllTower  = true,
    SellAtWave    = 15,
    Map           = "put the map here",
    Difficulty    = "put the difficulty here",
    MarcoUrl      = "paste your raw github url here!",
    Replay        = false,
}

-- Tower Costs (Used for PLACE cost only) ----------------------------------
local TOWER_COSTS = {
    Scout = 150, Sniper = 300, Paintballer = 400, Demoman = 575, Hunter = 750, 
    Soldier = 350, Militant = 700, Freezer = 425, Assassin = 200, Shotgunner = 300, 
    Pyromancer = 850, ["Ace Pilot"] = 550, Medic = 500, Farm = 250, Rocketeer = 1500, 
    Trapper = 1000, ["Military Base"] = 400, ["Crook Boss"] = 600, Electroshocker = 725, 
    Commander = 850, Warden = 1000, Cowboy = 500, ["DJ Booth"] = 1200, Minigunner = 1850, 
    Ranger = 4500, Pursuit = 3000, ["Gatling Gun"] = 5250, Turret = 5000, Mortar = 900, 
    ["Mercenary Base"] = 2000, Brawler = 600, Necromancer = 1650, Accelerator = 4500, 
    Engineer = 600, Hacker = 1400,
}

-- Tower Upgrade Costs (Used for UPGRADE cost) -----------------------------
local TOWER_UPGRADE_COSTS = {
    Scout = {50, 200, 950, 2500},
    Sniper = {150, 500, 1500, 4000},
    Paintballer = {200, 675, 1000, 2250, 4000},
    Demoman = {150, 475, 1650, 6250},
    Hunter = {200, 800, 3250, 9400},
    Soldier = {100, 400, 1500, 4750},
    Militant = {200, 900, 2750, 9000},
    Freezer = {225, 650, 2000, 4500},
    Assassin = {250, 1000, 2750, 7600},
    Shotgunner = {150, 950, 2500, 6500},
    Pyromancer = {350, 950, 1500, 3800, 9000},
    ["Ace Pilot"] = {200, 350, 1850, 3200, 8000},
    Medic = {500, 750, 2700, 6000, 16000},
    Farm = {200, 550, 1000, 2500, 5000},
    Rocketeer = {250, 1750, 6500, 20000},
    Trapper = {}, -- Trapper has no upgrades
    ["Military Base"] = {200, 400, 1750, 7500, 25000},
    ["Crook Boss"] = {300, 900, 4250, 20000},
    Electroshocker = {300, 600, 2000, 5000, 15000},
    Commander = {300, 2500, 5500, 15000},
    Warden = {400, 1250, 4500, 15000},
    Cowboy = {150, 550, 1500, 3000, 5250},
    ["DJ Booth"] = {300, 1250, 3000, 8000, 20000},
    Minigunner = {400, 1500, 7000, 17500},
    Ranger = {1500, 4500, 13500, 30000},
    Pursuit = {1200, 1850, 5000},
    ["Gatling Gun"] = {3000, 7500, 15000, 32500, 50000, 100000},
    Turret = {1250, 7250, 15000, 30000, 52500},
    Mortar = {325, 1400, 3250, 12000, 25000},
    ["Mercenary Base"] = {1000, 2000, 7000, 10000, 15000, 35000},
    Brawler = {300, 850, 2000, 5000, 12500},
    Necromancer = {1150, 3950, 11320, 44000},
    Accelerator = {1000, 2500, 4750, 11250, 36000},
    Engineer = {350, 550, 2250, 4750, 13500, 35000},
    Hacker = {600, 1250, 7500, 22000},
}
local GOLDEN_TOWER_COSTS = {
    ["Golden Scout"] = 1500, ["Golden Soldier"] = 3500, ["Golden Pyromancer"] = 8500,
    ["Golden Minigunner"] = 18500, ["Golden Cowboy"] = 5000, ["Golden Crook Boss"] = 6000,
}
local SKIN_TO_TOWER = {
    Intern = "Scout", Elf = "Scout", Jester = "Scout", Radiant = "Scout",
    Agent = "Soldier", Oni = "Soldier", ["Grand Theft"] = "Soldier",
    Marksman = "Sniper", Enforcer = "Minigunner", General = "Commander",
    Officer = "Commander", Werewolf = "Commander", Ducky = "Engineer",
    Default = "DJ Booth", DJ = "DJ Booth", Flamethrower = "Pyromancer",
}

-- UI ----------------------------------------------------------------------
local AutostratsLogger = Instance.new("ScreenGui")
AutostratsLogger.Name = "Returnhub_Logger"
AutostratsLogger.ResetOnSpawn = false
AutostratsLogger.Parent = playerGui
AutostratsLogger.IgnoreGuiInset = true 

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 330, 0, 500)
frame.Position = UDim2.new(0.02, 0, 0.12, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
frame.BorderSizePixel = 0
frame.Visible = true
frame.Parent = AutostratsLogger
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
local frStroke = Instance.new("UIStroke", frame)
frStroke.Color = Color3.fromRGB(80, 80, 95)
frStroke.Thickness = 1

-- Title Bar ---------------------------------------------------------------
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 76)
titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 44)
titleBar.Parent = frame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -12, 0, 30)
titleText.Position = UDim2.new(0, 8, 0, 6)
titleText.BackgroundTransparency = 1
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 22
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Text = "Strat Recorder"
titleText.Parent = titleBar

task.spawn(function()
    local h = 0
    while titleText.Parent do
        h = (h + 0.01) % 1
        titleText.TextColor3 = Color3.fromHSV(h, 1, 1)
        task.wait(0.03)
    end
end)

-- Stats -------------------------------------------------------------------
local function createStatLabel(name, yPos)
    local lbl = Instance.new("TextLabel")
    lbl.AnchorPoint = Vector2.new(1, 0)
    lbl.Position = UDim2.new(1, -8, 0, yPos)
    lbl.Size = UDim2.new(0, 86, 0, 16)
    lbl.BackgroundColor3 = Color3.fromRGB(45, 48, 58)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 10
    lbl.TextColor3 = Color3.fromRGB(230, 230, 230)
    lbl.Parent = titleBar
    Instance.new("UICorner", lbl).CornerRadius = UDim.new(0, 6)
    return lbl
end
local coinslbl = createStatLabel("Coins: ", 6)
local levelLbl = createStatLabel("Level: ", 24)
local gemsLbl = createStatLabel("Gems: ", 42)
local function updateStats()
    coinslbl.Text = "Coins: " .. (player:FindFirstChild("Coins") and player.Coins.Value or 0)
    levelLbl.Text = "Level: " .. (player:FindFirstChild("Level") and player.Level.Value or 0)
    gemsLbl.Text = "Gems: " .. (player:FindFirstChild("Gems") and player.Gems.Value or 0)
end
updateStats()
player:WaitForChild("Coins").Changed:Connect(updateStats)
player:WaitForChild("Level").Changed:Connect(updateStats)
player:WaitForChild("Gems").Changed:Connect(updateStats)

-- Credits -----------------------------------------------------------------
local devLbl = Instance.new("TextLabel")
devLbl.Position = UDim2.new(0, 10, 0, 38)
devLbl.Size = UDim2.new(0.6, 0, 0, 18)
devLbl.BackgroundTransparency = 1
devLbl.Font = Enum.Font.GothamBold
devLbl.TextSize = 12
devLbl.TextXAlignment = Enum.TextXAlignment.Left
devLbl.Text = "discord.gg/returnhub"
devLbl.Parent = titleBar

local authorLbl = Instance.new("TextLabel")
authorLbl.Position = UDim2.new(0, 10, 0, 56)
authorLbl.Size = UDim2.new(0.6, 0, 0, 18)
authorLbl.BackgroundTransparency = 1
authorLbl.Font = Enum.Font.GothamBold
authorLbl.TextSize = 12
authorLbl.TextXAlignment = Enum.TextXAlignment.Left
authorLbl.Text = "free + keyless"
authorLbl.Parent = titleBar

task.spawn(function()
    local h = 0
    while task.wait(0.03) do
        if not devLbl.Parent then break end
        h = (h + 0.008) % 1
        devLbl.TextColor3 = Color3.fromHSV(h, 1, 1)
        authorLbl.TextColor3 = Color3.fromHSV((h + 0.5) % 1, 1, 1)
    end
end)

-- Draggable ---------------------------------------------------------------
local dragging, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                     startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Toggle UI ---------------------------------------------------------------
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        frame.Visible = not frame.Visible
        if frame.Visible then
            frame.Position = UDim2.new(0.02, -24, 0.12, -12)
            TweenService:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(0.02, 0, 0.12, 0)
            }):Play()
        end
    end
end)

-- Buttons -----------------------------------------------------------------
local function makeBtn(text, x, w, bg, textSize)
    local b = Instance.new("TextButton")
    b.Position = UDim2.new(0, x, 0, 84)
    b.Size = UDim2.new(0, w, 0, 32)
    b.Font = Enum.Font.GothamBold
    b.TextSize = textSize or 14
    b.TextColor3 = Color3.fromRGB(240, 240, 240)
    b.Text = text
    b.BackgroundColor3 = bg
    b.Parent = frame
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    return b
end

local btnWidth = 70
local gap = 10
local padding = 12
local startBtn = makeBtn("Start", 0, btnWidth, Color3.fromRGB(45, 80, 55), 12)
local resumeBtn = makeBtn("Resume", 0, btnWidth, Color3.fromRGB(255, 180, 60), 14)
local clearBtn = makeBtn("Clear", 0, btnWidth, Color3.fromRGB(180, 50, 50), 14)
local copyStratBtn = makeBtn("Copy Strat", 0, btnWidth, Color3.fromRGB(60, 100, 200), 14)
local stopLoggingBtn = makeBtn("Stop Logging", padding, 100, Color3.fromRGB(75, 55, 55), 14)
stopLoggingBtn.Visible = false

local function layoutIdleButtons()
    local totalW = 4 * btnWidth + 3 * gap
    local startX = (330 - totalW) / 2
    startBtn.Position = UDim2.new(0, startX, 0, 84)
    resumeBtn.Position = UDim2.new(0, startX + btnWidth + gap, 0, 84)
    clearBtn.Position = UDim2.new(0, startX + 2*(btnWidth + gap), 0, 84)
    copyStratBtn.Position = UDim2.new(0, startX + 3*(btnWidth + gap), 0, 84)
    startBtn.Visible = true; resumeBtn.Visible = true
    clearBtn.Visible = true; copyStratBtn.Visible = true
    stopLoggingBtn.Visible = false
end

local function layoutLoggingButtons()
    stopLoggingBtn.Position = UDim2.new(0, padding, 0, 84)
    clearBtn.Position = UDim2.new(0, padding + 110, 0, 84)
    stopLoggingBtn.Visible = true; clearBtn.Visible = true
    startBtn.Visible = false; resumeBtn.Visible = false; copyStratBtn.Visible = false
end

layoutIdleButtons()

-- Log Area ----------------------------------------------------------------
local logFrame = Instance.new("ScrollingFrame")
logFrame.Position = UDim2.new(0, 10, 0, 142)
logFrame.Size = UDim2.new(0, 310, 0, 348)
logFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
logFrame.BorderSizePixel = 0
logFrame.ScrollBarThickness = 6
logFrame.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 90)
logFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
logFrame.Parent = frame
Instance.new("UICorner", logFrame).CornerRadius = UDim.new(0, 10)
local logStroke = Instance.new("UIStroke", logFrame)
logStroke.Color = Color3.fromRGB(70, 70, 90)
logStroke.Thickness = 1

local function getLayout()
    local old = logFrame:FindFirstChildOfClass("UIListLayout")
    if old then old:Destroy() end
    local layout = Instance.new("UIListLayout", logFrame)
    layout.Padding = UDim.new(0, 3)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.FillDirection = Enum.FillDirection.Vertical
    return layout
end
local layout = getLayout()

-- Recording State ---------------------------------------------------------
local recording = false
local actions = {}
local towerInstances = {}
local towerNames = {}
local towerLevels = {}
local unitCounts = {}
local placedPositions = {}
local savedState = {}
local logTexts = {}
local placeConn, removeConn

-- Helpers -----------------------------------------------------------------
local function getOrdinal(n)
    local s = {"st","nd","rd"}
    local v = n % 100
    return n .. (s[(v-20)%10] or s[v] or s[v%10] or "th")
end
local function getTime()
    local h = tonumber(os.date("%I"))
    local m = os.date("%M")
    local ampm = os.date("%p")
    return h..":"..m..ampm:lower()
end
local function posKey(pos)
    return string.format("%.3f,%.3f,%.3f", pos.X, pos.Y, pos.Z)
end
local function getUpgradeCost(name, targetLevel)
    local costs = TOWER_UPGRADE_COSTS[name]
    if costs and targetLevel > 0 and targetLevel <= #costs then
        return costs[targetLevel]
    end
    return 0
end

-- Add Log -----------------------------------------------------------------
local function addLog(text, isMisc)
    local full = getTime().." "..text
    table.insert(logTexts, full)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -4, 0, 20)
    row.BackgroundTransparency = 1
    row.LayoutOrder = #logTexts
    row.Parent = logFrame
    local msg = Instance.new("TextLabel")
    msg.Size = UDim2.new(1, -14, 1, 0)
    msg.Position = UDim2.new(0, 10, 0, 0)
    msg.BackgroundTransparency = 1
    msg.TextXAlignment = Enum.TextXAlignment.Left
    msg.Font = Enum.Font.Gotham
    msg.TextSize = isMisc and 10 or 12
    msg.TextColor3 = isMisc and Color3.fromRGB(180,180,200) or Color3.fromRGB(220,220,230)
    msg.Text = full
    msg.TextTransparency = 1
    msg.Parent = row
    TweenService:Create(msg, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    task.spawn(function()
        task.wait()
        local h = layout.AbsoluteContentSize.Y
        logFrame.CanvasSize = UDim2.new(0,0,0,h+6)
        local v = logFrame.AbsoluteSize.Y
        logFrame.CanvasPosition = Vector2.new(0, math.max(0, h-v+20))
    end)
end

-- Tower Detection (omitted for brevity, assume this is correct) -----------
local function isGoldenTower(name)
    if string.find(string.lower(name), "golden") then return true end
    if GOLDEN_TOWER_COSTS[name] then return true end
    return false
end
local function extractBaseTowerFromGolden(name)
    local base = string.gsub(name, "^[Gg]olden ", "")
    base = string.gsub(base, " [Gg]olden$", "")
    if TOWER_COSTS[base] then return base end
    return nil
end
local function getAllDescendants(instance, depth, maxDepth)
    depth = depth or 0
    maxDepth = maxDepth or 5
    if depth > maxDepth then return {} end
    local results = {}
    for _, child in pairs(instance:GetChildren()) do
        table.insert(results, {instance = child, name = child.Name, className = child.ClassName, depth = depth})
        for _, sub in pairs(getAllDescendants(child, depth + 1, maxDepth)) do
            table.insert(results, sub)
        end
    end
    return results
end
local function searchForTowerHints(tower)
    local hints = {}
    for _, item in pairs(getAllDescendants(tower, 0, 5)) do
        local inst = item.instance
        if inst:IsA("StringValue") or inst:IsA("ObjectValue") then
            local val = tostring(inst.Value)
            if TOWER_COSTS[val] then
                table.insert(hints, {type = "StringValue", value = val, isGolden = false})
            elseif isGoldenTower(val) then
                local base = extractBaseTowerFromGolden(val)
                if base then
                    table.insert(hints, {type = "StringValue (Golden)", value = base, isGolden = true, goldenName = val})
                end
            end
        end
        for attrName, attrValue in pairs(inst:GetAttributes()) do
            if type(attrValue) == "string" then
                if TOWER_COSTS[attrValue] then
                    table.insert(hints, {type = "Attribute", value = attrValue, isGolden = false})
                elseif isGoldenTower(attrValue) then
                    local base = extractBaseTowerFromGolden(attrValue)
                    if base then
                        table.insert(hints, {type = "Attribute (Golden)", value = base, isGolden = true, goldenName = attrValue})
                    end
                end
            end
        end
    end
    return hints
end
local function detectRealTower(towerObject)
    local displayName = towerObject.Name
    local info = {
        baseTower = displayName,
        displayName = displayName,
        cost = 0,
        hasSkin = false,
        isGolden = false,
        skinName = nil,
        detectionMethod = "Unknown"
    }

    if isGoldenTower(displayName) then
        local base = extractBaseTowerFromGolden(displayName)
        if base then
            info.baseTower = base
            info.isGolden = true
            info.cost = GOLDEN_TOWER_COSTS[displayName] or (TOWER_COSTS[base] * 10)
            info.detectionMethod = "Golden Tower (Name)"
            return info
        end
    end

    if SKIN_TO_TOWER[displayName] then
        local base = SKIN_TO_TOWER[displayName]
        info.baseTower = base
        info.hasSkin = true
        info.skinName = displayName
        info.cost = TOWER_COSTS[base]
        info.detectionMethod = "Known Skin"
        return info
    end

    for attrName, attrValue in pairs(towerObject:GetAttributes()) do
        if type(attrValue) == "string" then
            if isGoldenTower(attrValue) then
                local base = extractBaseTowerFromGolden(attrValue)
                if base then
                    info.baseTower = base
                    info.isGolden = true
                    info.cost = GOLDEN_TOWER_COSTS[attrValue] or (TOWER_COSTS[base] * 10)
                    info.detectionMethod = "Attribute (Golden)"
                    return info
                end
            elseif TOWER_COSTS[attrValue] then
                info.baseTower = attrValue
                info.hasSkin = (attrValue ~= displayName)
                info.skinName = displayName
                info.cost = TOWER_COSTS[attrValue]
                info.detectionMethod = "Attribute"
                return info
            end
        end
    end

    local hints = searchForTowerHints(towerObject)
    if #hints > 0 then
        local best = hints[1]
        info.baseTower = best.value
        info.isGolden = best.isGolden or false
        info.hasSkin = (best.value ~= displayName) and not best.isGolden
        info.skinName = displayName
        if best.isGolden then
            info.cost = GOLDEN_TOWER_COSTS[best.goldenName] or (TOWER_COSTS[best.value] * 10)
        else
            info.cost = TOWER_COSTS[best.value]
        end
        info.detectionMethod = "Deep Scan"
        return info
    end

    if TOWER_COSTS[displayName] then
        info.baseTower = displayName
        info.cost = TOWER_COSTS[displayName]
        info.hasSkin = false
        info.detectionMethod = "Base Tower"
        return info
    end

    info.detectionMethod = "Failed"
    return info
end

-- Tower Index -------------------------------------------------------------
local function getTowerIndex(tower)
    for i, t in ipairs(towerInstances) do
        if t == tower then return i end
    end
    return 0
end

-- Tower Monitoring (PLACE) ------------------------------------------------
local function onTowerAdded(tower)
    if not recording then return end
    task.wait(0.5)
    local owner = tower:FindFirstChild("Owner")
    if not owner or owner.Value ~= player.UserId then return end

    local pos = tower:GetPivot().Position
    local key = posKey(pos)
    if placedPositions[key] then return end

    local towerInfo = detectRealTower(tower)
    if towerInfo.detectionMethod == "Failed" then return end

    placedPositions[key] = true
    unitCounts[towerInfo.baseTower] = (unitCounts[towerInfo.baseTower] or 0) + 1
    local ordinal = getOrdinal(unitCounts[towerInfo.baseTower])
    local index = #towerInstances + 1

    table.insert(towerInstances, tower)
    table.insert(towerNames, {name = towerInfo.baseTower, ordinal = ordinal})
    table.insert(towerLevels, 0)
    table.insert(actions, {type = "place", pos = pos, name = towerInfo.baseTower, cost = towerInfo.cost, index = index})
    addLog(string.format("Placed %s %s ($%d)", ordinal, towerInfo.baseTower, towerInfo.cost))
end

-- Tower Removal (SELL - Cleanup Hook) -------------------------------------
local function onTowerRemoved(tower)
    if not recording then return end
    local index = getTowerIndex(tower)
    if index == 0 then return end

    local name = towerNames[index]
    local pos = tower:GetPivot().Position
    local key = posKey(pos)
    
    placedPositions[key] = nil
    if name then unitCounts[name.name] = (unitCounts[name.name] or 1) - 1 end
    
    table.remove(towerInstances, index)
    table.remove(towerNames, index)
    table.remove(towerLevels, index)
end

-- 🛠️ ACTION LOGGERS --------------------------------------------------------

local function logSkipAction()
    if recording then
        table.insert(actions, {type = "skip"})
        addLog("Skipped wave (Manual)", true)
    end
end

local function logUnlockTimeScale()
    if recording then
        table.insert(actions, {type = "unlock_timescale"})
        addLog("Unlocked Time-Scale", true)
    end
end

local function logCycleTimeScale()
    if recording then
        table.insert(actions, {type = "cycle_timescale"})
        addLog("Cycled Time-Scale", true)
    end
end


-- Remote Hook (UPGRADE + SELL + TARGET + SKIP + TIMESCALE) ------------------
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    local result = oldNamecall(self, ...)

    if not recording then return result end

    -- InvokeServer Hook (Upgrade, Sell, Target, SKIP, UNLOCK TIMESCALE)
    if method == "InvokeServer" and self == remoteFunc then
    
        -- SKIP WAVE (FIXED: Hooking InvokeServer on RemoteFunction)
        if args[1] == "Voting" and args[2] == "Skip" then
            logSkipAction()
        end

        -- UNLOCK TIME-SCALE (NEW ACTION)
        if args[1] == "TicketsManager" and args[2] == "UnlockTimeScale" then
            logUnlockTimeScale()
        end
        
        -- Helper function to find the tower instance
        local function getTowerInstanceFromArgs(args)
            -- Check the standard {Troop = instance} structure (args[4])
            if typeof(args[4]) == "table" and typeof(args[4].Troop) == "Instance" and args[4].Troop.Parent == towersFolder then
                return args[4].Troop
            end
            -- Check for the tower instance directly in args[3] (common in some exploits)
            if typeof(args[3]) == "Instance" and args[3].Parent == towersFolder then
                return args[3]
            end
            return nil
        end
        
        -- UPGRADE (ROBUST TOWER FINDING)
        if args[1] == "Troops" and args[2] == "Upgrade" then
            local tower = getTowerInstanceFromArgs(args)
            
            if tower then
                local index = getTowerIndex(tower)
                if index > 0 then
                    task.spawn(function()
                        local towerName = tower.Name
                        local startTime = os.clock()
                        -- Wait a moment for the server to apply the upgrade and change the name/level property
                        while (towerName == "Default" or towerName == "Troop" or TOWER_COSTS[towerName] == nil) and (os.clock() - startTime < 0.2) do
                            task.wait(0.01)
                            towerName = tower.Name
                        end
                        local newLevel = (tower:FindFirstChild("Level") and tower.Level.Value) or (towerLevels[index] + 1)
                        local cost = getUpgradeCost(towerNames[index].name, newLevel)

                        if cost > 0 then
                            local pos = tower:GetPivot().Position
                            table.insert(actions, {type = "upgrade", index = index, cost = cost, pos = pos})
                            towerLevels[index] = newLevel
                            addLog(string.format("Upgraded %s %s to level %d ($%d)", towerNames[index].ordinal, towerNames[index].name, newLevel, cost))
                        else
                            addLog(string.format("Warning: Upgraded %s. Cost not found ($0)", towerNames[index].name), true)
                        end
                    end)
                end
            end
        end

        -- SELL (ROBUST TOWER FINDING)
        if args[1] == "Troops" and args[2] == "Sell" then
            local tower = getTowerInstanceFromArgs(args)
            
            if tower then
                local index = getTowerIndex(tower)
                if index > 0 then
                    local name = towerNames[index] and towerNames[index].name or "Unknown"
                    local ordinal = towerNames[index] and towerNames[index].ordinal or "Unknown"
                    local pos = tower:GetPivot().Position
                    
                    table.insert(actions, {type = "sell", index = index, pos = pos})
                    addLog(string.format("Sold %s %s", ordinal, name))
                end
            end
        end

        -- TARGET
        if args[1] == "Troops" and args[2] == "Target" and args[3] == "Set" and typeof(args[4]) == "table" then
            local tower = args[4].Troop
            local targetMode = tostring(args[4].Target or "Random")
            if tower and tower.Parent then
                local index = getTowerIndex(tower)
                if index > 0 then
                    local pos = tower:GetPivot().Position
                    table.insert(actions, {type = "target", index = index, pos = pos, target = targetMode})
                    addLog(string.format("Set %s %s target to %s", towerNames[index].ordinal, towerNames[index].name, targetMode))
                end
            end
        end
    end
    
    -- FireServer Hook (Cycle Time-Scale)
    if method == "FireServer" and self == remoteEvent then
        
        -- CYCLE TIME-SCALE (NEW ACTION)
        if args[1] == "TicketsManager" and args[2] == "CycleTimeScale" then
            logCycleTimeScale()
        end

    end

    return result
end)
setreadonly(mt, true)

-- Logging Controls --------------------------------------------------------
local function startLogging()
    if recording then return end
    recording = true
    actions = {}
    towerInstances = {}
    towerNames = {}
    towerLevels = {}
    unitCounts = {}
    placedPositions = {}
    logTexts = {}
    logFrame:ClearAllChildren()
    layout = getLayout()
    layoutLoggingButtons()
    addLog("Logging started, discord.gg/returnhub", true)
    placeConn = towersFolder.ChildAdded:Connect(onTowerAdded)
    removeConn = towersFolder.ChildRemoved:Connect(onTowerRemoved)
end

local function stopLogging()
    if not recording then return end
    recording = false
    savedState = {
        actions = table.clone(actions),
        towerInstances = table.clone(towerInstances),
        towerNames = table.clone(towerNames),
        towerLevels = table.clone(towerLevels),
        unitCounts = table.clone(unitCounts),
        placedPositions = table.clone(placedPositions),
        logTexts = table.clone(logTexts)
    }
    if placeConn then placeConn:Disconnect() end
    if removeConn then removeConn:Disconnect() end
    layoutIdleButtons()
    addLog("Logging stopped. "..#actions.." actions.", true)
end

local function resumeLogging()
    if recording or not savedState.actions then return end
    recording = true
    actions = table.clone(savedState.actions)
    towerInstances = table.clone(savedState.towerInstances)
    towerNames = table.clone(savedState.towerNames)
    towerLevels = table.clone(savedState.towerLevels)
    unitCounts = table.clone(savedState.unitCounts)
    placedPositions = table.clone(savedState.placedPositions)
    logTexts = table.clone(savedState.logTexts)
    logFrame:ClearAllChildren()
    layout = getLayout()
    for _, txt in ipairs(logTexts) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -4, 0, 20)
        row.BackgroundTransparency = 1
        row.LayoutOrder = #logFrame:GetChildren() + 1
        row.Parent = logFrame
        local msg = Instance.new("TextLabel")
        msg.Size = UDim2.new(1, -14, 1, 0)
        msg.Position = UDim2.new(0, 10, 0, 0)
        msg.BackgroundTransparency = 1
        msg.TextXAlignment = Enum.TextXAlignment.Left
        msg.Font = Enum.Font.Gotham
        msg.TextSize = 10
        msg.TextColor3 = Color3.fromRGB(180,180,200)
        msg.Text = txt
        msg.Parent = row
    end
    layoutLoggingButtons()
    addLog("Logging resumed.", true)
    placeConn = towersFolder.ChildAdded:Connect(onTowerAdded)
    removeConn = towersFolder.ChildRemoved:Connect(onTowerRemoved)
end

local function clearLogs()
    logFrame:ClearAllChildren()
    logTexts = {}
    layout = getLayout()
    addLog("Logs cleared.", true)
end

-- Copy ReturnHub Strat ----------------------------------------------------
local function copyStrat()
    local lines = {}

    -- Header
    table.insert(lines, "getgenv().Returnhub = {")
    table.insert(lines, string.format('    autoskip = %s,', tostring(ReturnHub.autoskip)))
    table.insert(lines, string.format('    SellAllTower = %s,', tostring(ReturnHub.SellAllTower)))
    table.insert(lines, string.format('    SellAtWave = %d,', ReturnHub.SellAtWave))
    table.insert(lines, string.format('    Map = "%s",', ReturnHub.Map))
    table.insert(lines, string.format('    Difficulty = "%s",', ReturnHub.Difficulty))
    table.insert(lines, string.format('    MarcoUrl = "%s",', ReturnHub.MarcoUrl))
    table.insert(lines, string.format('    Replay = %s', tostring(ReturnHub.Replay)))
    table.insert(lines, "}")
    table.insert(lines, 'loadstring(game:HttpGet("i will put the github link here later"))()')

    -- Actions
    for _, a in ipairs(actions) do
        local x = a.pos and string.format("%.3f", a.pos.X):gsub("%.000$", "")
        local y = a.pos and string.format("%.3f", a.pos.Y):gsub("%.000$", "")
        local z = a.pos and string.format("%.3f", a.pos.Z):gsub("%.000$", "")

        if a.type == "place" then
            table.insert(lines, string.format('place(%s, %s, %s, "%s", %d)', x, y, z, a.name, a.cost))
        elseif a.type == "upgrade" then
            local uy = a.pos and string.format("%.3f", a.pos.Y + 1.35):gsub("%.000$", "")
            table.insert(lines, string.format('upgrade(%s, %s, %s, %d)', x, uy, z, a.cost))
        elseif a.type == "sell" then
            table.insert(lines, string.format('sell(%s, %s, %s)', x, y, z))
        elseif a.type == "target" then
            table.insert(lines, string.format('SetTarget(%s, %s, %s, "%s")', x, y, z, a.target))
        elseif a.type == "skip" then
            table.insert(lines, "skip()")
        elseif a.type == "unlock_timescale" then
            table.insert(lines, "UnlockTimeScale()")
        elseif a.type == "cycle_timescale" then
            table.insert(lines, "CycleTimeScale()")
        end
    end

    local out = table.concat(lines, "\n")
    setclipboard(out)
    addLog("ReturnHub strat copied!", true)
    copyStratBtn.Text = "Copied!"
    task.wait(1.5)
    copyStratBtn.Text = "Copy Strat"
end

-- Button Connections -------------------------------------------------------
startBtn.MouseButton1Click:Connect(startLogging)
stopLoggingBtn.MouseButton1Click:Connect(stopLogging)
resumeBtn.MouseButton1Click:Connect(resumeLogging)
clearBtn.MouseButton1Click:Connect(clearLogs)
copyStratBtn.MouseButton1Click:Connect(copyStrat)

-- Show UI -----------------------------------------------------------------
addLog("Strat Recorder Loaded!", true)