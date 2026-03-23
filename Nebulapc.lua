-- N5 DUELS v2 - Vertical GUI + Drop Brainrots + Mobile Panel
print("PD: Script started")
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Player = LocalPlayer

local NORMAL_SPEED = 60
local CARRY_SPEED = 30
local speedToggled = false
local autoBatToggled = false
local hittingCooldown = false
local autoBatKey = Enum.KeyCode.ButtonR2
local speedToggleKey = Enum.KeyCode.ButtonL2

local AutoLeftEnabled = false
local AutoRightEnabled = false
local AutoLeftPlayEnabled = false
local AutoRightPlayEnabled = false
local autoLeftKey = Enum.KeyCode.ButtonX
local autoRightKey = Enum.KeyCode.ButtonB
local autoLeftPlayKey = Enum.KeyCode.ButtonY
local autoRightPlayKey = Enum.KeyCode.ButtonA
local autoLeftConnection = nil
local autoRightConnection = nil
local autoLeftPlayConnection = nil
local autoRightPlayConnection = nil
local autoLeftPhase = 1
local autoRightPhase = 1
local autoLeftPlayPhase = 1
local autoRightPlayPhase = 1

local guiToggleKey = Enum.KeyCode.ButtonSelect
local galaxyKey = Enum.KeyCode.ButtonR3
local tpDownKey = Enum.KeyCode.Unknown
local guiVisible = true

local POSITION_L1 = Vector3.new(-476.48, -6.28, 92.73)
local POSITION_L2 = Vector3.new(-483.12, -4.95, 94.80)
local POSITION_R1 = Vector3.new(-476.16, -6.52, 25.62)
local POSITION_R2 = Vector3.new(-483.04, -5.09, 23.14)

local ALP_P1 = Vector3.new(-476.2, -6.5, 94.8)
local ALP_P2 = Vector3.new(-484.1, -4.7, 94.7)
local ALP_P3 = Vector3.new(-476.5, -6.1, 7.5)

local ARP_P1 = Vector3.new(-476.2, -6.1, 25.8)
local ARP_P2 = Vector3.new(-484.1, -4.7, 25.9)
local ARP_P3 = Vector3.new(-476.2, -6.2, 113.5)

local isStealing = false
local stealStartTime = nil
local Values = {
    STEAL_RADIUS = 8,
    STEAL_DURATION = 0.2,
    DEFAULT_GRAVITY = 196.2,
    GalaxyGravityPercent = 70,
    HOP_POWER = 35,
    HOP_COOLDOWN = 0.08,
    GalaxyJumpOverride = false,  -- if true, use GalaxyJumpPower instead of auto-calc
    GalaxyJumpPower = 60,        -- custom jump power when override is on
}

local Enabled = {
    AntiRagdoll = false,
    AutoSteal = false,
    Galaxy = false,
    Optimizer = false,
    Unwalk = false,
    AutoLeftEnabled = false,
    AutoRightEnabled = false,
    AutoLeftPlayEnabled = false,
    AutoRightPlayEnabled = false,
    AimbotEnabled = false,
    BatAimbot = false,
    FloatEnabled = false,
    NoClip = false,
    InfJump = false,
    AutoTP = false,
    DarkMode = false,
    CounterMedusa = false,
}

local Connections = {}
local StealData = {}
local lastBatSwing = 0
local BAT_SWING_COOLDOWN = 0.12

local galaxyVectorForce = nil
local galaxyAttachment = nil
local galaxyEnabled = false
local hopsEnabled = false
local lastHopTime = 0
local spaceHeld = false
local originalJumpPower = 50
local infJumpEnabled = false
local forceJump = false
local INF_JUMP_POWER = 35

local originalTransparency = {}
local xrayEnabled = false
local savedAnimations = {}

local floatEnabled = false
local floatKey = Enum.KeyCode.ButtonL3
local FLOAT_HEIGHT = 10
local floatConnection = nil
local currentTransparency = 0
local uiScaleValue = 1.0
local isMobile = UserInputService.TouchEnabled
local isController = UserInputService.GamepadEnabled
local savedBtnPositions = {}  -- loaded from config, applied after buttons are built
local uiLocked = false        -- declared early so saveConfig can safely reference it before GUI builds

local h, hrp, speedLbl

local ProgressBarFill = nil
local ProgressPercentLabel = nil
local ProgressBarContainer = nil
local mbRefs = {}  -- declared early so saveConfig can reference it safely
local RadiusInputRef = nil

local phantomLetterLabels = {}
local modeLabel = nil
local barPctLabel = nil
local barRadiusLabel = nil

local TP_PRE_STEP = Vector3.new(-452.5, -6.6, 57.7)
local TP_STEPS = {
    Left = { Vector3.new(-475.0, -6.6, 94.7), Vector3.new(-482.6, -4.7, 94.6) },
    Right = { Vector3.new(-475.2, -6.6, 23.5), Vector3.new(-482.2, -4.7, 23.4) },
}
local TP_PRE_STEP_DELAY = 0.10
local TP_STEP_DELAY = 0.10
local TP_COOLDOWN_SEC = 1.2
local tpSelectedSide = nil
local tpWasRagdolled = false
local tpCooldown = false
local tpStatusLabel = nil

local MEDUSA_OBJECT_NAMES = {
    ["Petrified"]=true,["Petrify"]=true,["Stone"]=true,["MedusaStone"]=true,
    ["MedusaEffect"]=true,["Stoned"]=true,["MedusaHead"]=true,["Frozen"]=true,
    ["Statue"]=true,["PetrifyEffect"]=true,
}

local function isCharacterPetrified(char)
    if not char then return false end
    for _, obj in ipairs(char:GetChildren()) do
        if MEDUSA_OBJECT_NAMES[obj.Name] then return true end
        if (obj:IsA("BoolValue") or obj:IsA("IntValue")) then
            local low = obj.Name:lower()
            if low:find("medusa") or low:find("petri") or low:find("stone") or low:find("statue") then return true end
        end
    end
    local ok, CS = pcall(function() return game:GetService("CollectionService") end)
    if ok and CS then
        for _, tag in ipairs(CS:GetTags(char)) do
            local low = tag:lower()
            if low:find("medusa") or low:find("petri") or low:find("stone") or low:find("statue") then return true end
        end
    end
    return false
end

local function getHRP()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function isMyPlotByName(pn)
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return false end
    local plot = plots:FindFirstChild(pn)
    if not plot then return false end
    local sign = plot:FindFirstChild("PlotSign")
    if sign then
        local yb = sign:FindFirstChild("YourBase")
        if yb and yb:IsA("BillboardGui") then return yb.Enabled == true end
    end
    return false
end

local function findNearestPrompt()
    local myHrp = getHRP()
    if not myHrp then return nil end
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil end
    local np, nd, nn = nil, math.huge, nil
    for _, plot in ipairs(plots:GetChildren()) do
        if isMyPlotByName(plot.Name) then continue end
        local podiums = plot:FindFirstChild("AnimalPodiums")
        if not podiums then continue end
        for _, pod in ipairs(podiums:GetChildren()) do
            pcall(function()
                local base = pod:FindFirstChild("Base")
                local spawn = base and base:FindFirstChild("Spawn")
                if spawn then
                    local dist = (spawn.Position - myHrp.Position).Magnitude
                    if dist < nd and dist <= Values.STEAL_RADIUS then
                        local att = spawn:FindFirstChild("PromptAttachment")
                        if att then
                            for _, ch in ipairs(att:GetChildren()) do
                                if ch:IsA("ProximityPrompt") then np, nd, nn = ch, dist, pod.Name break end
                            end
                        end
                    end
                end
            end)
        end
    end
    return np, nd, nn
end

local function tpMoveTo(pos)
    local r = getHRP()
    if not r then return false end
    r.CFrame = CFrame.new(pos)
    r.AssemblyLinearVelocity = Vector3.zero
    return true
end

local function setTpStatus(txt, color)
    if tpStatusLabel then
        tpStatusLabel.Text = txt
        tpStatusLabel.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    end
end

local function teleportToBase()
    if not tpSelectedSide then return end
    if tpCooldown then return end
    if isCharacterPetrified(LocalPlayer.Character) then
        setTpStatus("Medusa detected – TP blocked", Color3.fromRGB(255, 120, 60))
        tpWasRagdolled = false
        return
    end
    tpCooldown = true
    local side = tpSelectedSide
    local steps = TP_STEPS[side]
    setTpStatus("Pre-step -> neutral...", Color3.fromRGB(255, 200, 80))
    tpMoveTo(TP_PRE_STEP)
    task.delay(TP_PRE_STEP_DELAY, function()
        setTpStatus("Step 1 -> " .. side .. "...", Color3.fromRGB(255, 220, 100))
        tpMoveTo(steps[1])
        task.delay(TP_STEP_DELAY, function()
            tpMoveTo(steps[2])
            task.wait(0.05)
            tpMoveTo(steps[2])
            setTpStatus("Teleported to " .. side .. " !", Color3.fromRGB(255, 255, 255))
            task.delay(TP_COOLDOWN_SEC, function() tpCooldown = false end)
        end)
    end)
end

local TP_RAGDOLL_STATES = {
    [Enum.HumanoidStateType.Physics]=true,
    [Enum.HumanoidStateType.FallingDown]=true,
    [Enum.HumanoidStateType.Ragdoll]=true,
}

local tpStateConn, tpChildConn, tpChildRemConn = nil, nil, nil

local function hookTPCharacter(char)
    if tpStateConn then tpStateConn:Disconnect() tpStateConn = nil end
    if tpChildConn then tpChildConn:Disconnect() tpChildConn = nil end
    if tpChildRemConn then tpChildRemConn:Disconnect() tpChildRemConn = nil end
    local hum = char:WaitForChild("Humanoid")
    tpStateConn = hum.StateChanged:Connect(function(_, newState)
        if not Enabled.AutoTP then return end
        if TP_RAGDOLL_STATES[newState] then
            if isCharacterPetrified(char) then setTpStatus("Medusa detected – TP blocked", Color3.fromRGB(255,120,60)) return end
            if not tpWasRagdolled then tpWasRagdolled = true task.defer(teleportToBase) end
        else tpWasRagdolled = false end
    end)
    tpChildConn = char.ChildAdded:Connect(function(child)
        if not Enabled.AutoTP then return end
        if MEDUSA_OBJECT_NAMES[child.Name] then tpWasRagdolled = false setTpStatus("Medusa detected – TP blocked", Color3.fromRGB(255,120,60)) return end
        if (child:IsA("BoolValue") or child:IsA("IntValue")) then
            local low = child.Name:lower()
            if low:find("medusa") or low:find("petri") or low:find("stone") or low:find("statue") then
                tpWasRagdolled = false setTpStatus("Medusa detected – TP blocked", Color3.fromRGB(255,120,60)) return
            end
        end
        if (child.Name == "Ragdoll" or child.Name == "IsRagdoll") and tpSelectedSide then
            if not tpWasRagdolled then tpWasRagdolled = true task.defer(teleportToBase) end
        end
    end)
    tpChildRemConn = char.ChildRemoved:Connect(function(child)
        if child.Name == "Ragdoll" or child.Name == "IsRagdoll" then tpWasRagdolled = false end
        if MEDUSA_OBJECT_NAMES[child.Name] then
            setTpStatus(tpSelectedSide and (tpSelectedSide.." base selected") or "Select a base", Color3.fromRGB(255, 255, 255))
        end
    end)
end

local function startAutoTP()
    tpWasRagdolled = false tpCooldown = false
    local char = LocalPlayer.Character
    if char then hookTPCharacter(char) end
end

local function stopAutoTP()
    if tpStateConn then tpStateConn:Disconnect() tpStateConn = nil end
    if tpChildConn then tpChildConn:Disconnect() tpChildConn = nil end
    if tpChildRemConn then tpChildRemConn:Disconnect() tpChildRemConn = nil end
    tpWasRagdolled = false
end

local function doTPDown()
    local r = getHRP()
    if r then r.CFrame = r.CFrame * CFrame.new(0, -20, 0) end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    tpWasRagdolled = false tpCooldown = false
    if Enabled.AutoTP then hookTPCharacter(char) end
end)

local progressConnection = nil

local function ResetProgressBar()
    for _, lbl in ipairs(phantomLetterLabels) do lbl.TextTransparency = 1 end
    if barPctLabel then barPctLabel.Text = "0%" end
    if barRadiusLabel then barRadiusLabel.Text = "Radius: "..tostring(Values.STEAL_RADIUS) end
end

local function UpdatePhantomLetters(prog)
    local numLetters = 7
    local lettersToShow = math.clamp(math.floor(prog * numLetters + 0.999), 0, numLetters)
    for i, lbl in ipairs(phantomLetterLabels) do lbl.TextTransparency = i <= lettersToShow and 0 or 1 end
    if barPctLabel then barPctLabel.Text = math.floor(prog*100).."%" end
    if barRadiusLabel then barRadiusLabel.Text = "Radius: "..tostring(Values.STEAL_RADIUS) end
end

local function cachePromptData(prompt)
    if StealData[prompt] then return StealData[prompt] end
    local data = {hold={},trigger={},ready=true}
    pcall(function()
        if getconnections then
            for _, c in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do if c.Function then table.insert(data.hold, c.Function) end end
            for _, c in ipairs(getconnections(prompt.Triggered)) do if c.Function then table.insert(data.trigger, c.Function) end end
        end
    end)
    StealData[prompt] = data
    return data
end

local function executeSteal(prompt, name)
    if isStealing then return end
    local data = cachePromptData(prompt)
    if not data.ready then return end
    data.ready = false isStealing = true stealStartTime = tick()
    if progressConnection then progressConnection:Disconnect() end
    progressConnection = RunService.Heartbeat:Connect(function()
        if not isStealing then if progressConnection then progressConnection:Disconnect() progressConnection = nil end return end
        local prog = math.clamp((tick()-stealStartTime)/Values.STEAL_DURATION, 0, 1)
        if ProgressBarFill then ProgressBarFill.Size = UDim2.new(prog,0,1,0) end
        UpdatePhantomLetters(prog)
    end)
    task.spawn(function()
        for _, f in ipairs(data.hold) do task.spawn(pcall,f) end
        task.wait(Values.STEAL_DURATION)
        for _, f in ipairs(data.trigger) do task.spawn(pcall,f) end
        if progressConnection then progressConnection:Disconnect() progressConnection = nil end
        ResetProgressBar()
        if ProgressBarFill then ProgressBarFill.Size = UDim2.new(0,0,1,0) end
        data.ready = true isStealing = false
    end)
end

local lastStealScan = 0
local function startAutoSteal()
    if Connections.autoSteal then return end
    Connections.autoSteal = RunService.Heartbeat:Connect(function()
        if not Enabled.AutoSteal or isStealing then return end
        local now = tick()
        if now - lastStealScan < 0.05 then return end
        lastStealScan = now
        local p, _, n = findNearestPrompt()
        if p then executeSteal(p, n) end
    end)
end

local function stopAutoSteal()
    if Connections.autoSteal then Connections.autoSteal:Disconnect() Connections.autoSteal = nil end
    isStealing = false
    if progressConnection then progressConnection:Disconnect() progressConnection = nil end
    ResetProgressBar()
    if ProgressBarFill then ProgressBarFill.Size = UDim2.new(0,0,1,0) end
end

local function startAntiRagdoll()
    if Connections.antiRagdoll then return end
    Connections.antiRagdoll = RunService.Heartbeat:Connect(function()
        if not Enabled.AntiRagdoll then return end
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            local humState = hum:GetState()
            if humState == Enum.HumanoidStateType.Physics or humState == Enum.HumanoidStateType.Ragdoll or humState == Enum.HumanoidStateType.FallingDown then
                hum:ChangeState(Enum.HumanoidStateType.Running)
                workspace.CurrentCamera.CameraSubject = hum
                pcall(function()
                    if LocalPlayer.Character then
                        local PM = LocalPlayer.PlayerScripts:FindFirstChild("PlayerModule")
                        if PM then require(PM:FindFirstChild("ControlModule")):Enable() end
                    end
                end)
                if root then root.Velocity = Vector3.new(0,0,0) root.RotVelocity = Vector3.new(0,0,0) end
            end
        end
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("Motor6D") and obj.Enabled == false then obj.Enabled = true end
        end
    end)
end

local function stopAntiRagdoll()
    if Connections.antiRagdoll then Connections.antiRagdoll:Disconnect() Connections.antiRagdoll = nil end
end

-- ══════════════════════════════════════════
-- COUNTER MEDUSA
-- ══════════════════════════════════════════
local medusaNames = { ["medusa's head"] = true, ["medusa"] = true }
local medusaCounterConn = nil
local medusaToolConns   = {}
local medusaPlayerConns = {}
local lastMedusaUse     = 0
local lastBoogieUse     = 0

local function isMedusaToolName(name)
    if not name then return false end
    local lower = name:lower()
    return medusaNames[lower] or lower:find("medusa") ~= nil
end

local function isBoogieName(name)
    if not name then return false end
    return name:lower():find("boogie") ~= nil
end

local function safeDiscMedusa(conn)
    if conn and typeof(conn) == "RBXScriptConnection" then
        pcall(function() conn:Disconnect() end)
    end
end

local function getMedusaTool()
    local char = LocalPlayer.Character
    if char then
        for _, i in ipairs(char:GetChildren()) do
            if i:IsA("Tool") and isMedusaToolName(i.Name) then return i end
        end
    end
    local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
    if bp then
        for _, i in ipairs(bp:GetChildren()) do
            if i:IsA("Tool") and isMedusaToolName(i.Name) then return i end
        end
    end
end

local function getBoogieTool()
    local char = LocalPlayer.Character
    if char then
        for _, i in ipairs(char:GetChildren()) do
            if i:IsA("Tool") and isBoogieName(i.Name) then return i end
        end
    end
    local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
    if bp then
        for _, i in ipairs(bp:GetChildren()) do
            if i:IsA("Tool") and isBoogieName(i.Name) then return i end
        end
    end
end

local function enemyHasMedusa(character)
    if not character then return false end
    for _, i in ipairs(character:GetChildren()) do
        if i:IsA("Tool") and isMedusaToolName(i.Name) then return true end
    end
    return false
end

local function activateMedusaTool(tool, lastRef, setLast)
    if not tool then return end
    local now = workspace:GetServerTimeNow()
    if now - lastRef <= 0.3 then return end
    setLast(now)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if tool.Parent ~= LocalPlayer.Character then
        pcall(function() hum:EquipTool(tool) end)
    end
    pcall(function() if type(tool.Activate) == "function" then tool:Activate() end end)
    task.delay(0.1, function()
        local h2 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h2 then pcall(function() h2:UnequipTools() end) end
    end)
end

local function useCounterMedusa()
    local now = workspace:GetServerTimeNow()
    if now - lastMedusaUse > 0.3 then
        local t = getMedusaTool()
        if t then activateMedusaTool(t, lastMedusaUse, function(v) lastMedusaUse = v end); return true end
    end
    if now - lastBoogieUse > 0.3 then
        local t = getBoogieTool()
        if t then activateMedusaTool(t, lastBoogieUse, function(v) lastBoogieUse = v end); return true end
    end
    return false
end

local function unbindMedusaTool(tool)
    if medusaToolConns[tool] then
        safeDiscMedusa(medusaToolConns[tool])
        medusaToolConns[tool] = nil
    end
end

local function bindMedusaTool(tool)
    if not tool or not tool:IsA("Tool") or medusaToolConns[tool] then return end
    if not isMedusaToolName(tool.Name) then return end
    local conn
    conn = tool.Activated:Connect(function()
        if not Enabled.CounterMedusa then return end
        local aRoot = tool.Parent and tool.Parent:FindFirstChild("HumanoidRootPart")
        local myHRP = getHRP()
        if not (aRoot and myHRP) then return end
        if (aRoot.Position - myHRP.Position).Magnitude <= 20 then
            useCounterMedusa()
        end
    end)
    medusaToolConns[tool] = conn
    tool.Destroying:Connect(function() unbindMedusaTool(tool) end)
end

local function unbindPlayerMedusa(plr)
    local list = medusaPlayerConns[plr]
    if list then
        for _, c in ipairs(list) do safeDiscMedusa(c) end
        medusaPlayerConns[plr] = nil
    end
end

local function bindPlayerMedusa(plr)
    if not plr or plr == LocalPlayer then return end
    unbindPlayerMedusa(plr)
    local conns = {}
    local function scan(char)
        if not char then return end
        for _, child in ipairs(char:GetChildren()) do
            if child:IsA("Tool") then bindMedusaTool(child) end
        end
        table.insert(conns, char.ChildAdded:Connect(function(obj)
            if obj:IsA("Tool") then bindMedusaTool(obj) end
        end))
    end
    local ok, char = pcall(function()
        return plr.Character or plr.CharacterAdded:Wait()
    end)
    if ok and char then scan(char) end
    table.insert(conns, plr.CharacterAdded:Connect(function(c) scan(c) end))
    medusaPlayerConns[plr] = conns
end

local function startCounterMedusa()
    if medusaCounterConn then return end
    Enabled.CounterMedusa = true
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then bindPlayerMedusa(plr) end
    end
    medusaPlayerConns["_added"] = Players.PlayerAdded:Connect(bindPlayerMedusa)
    medusaCounterConn = RunService.Heartbeat:Connect(function()
        if not Enabled.CounterMedusa then return end
        local myHRP = getHRP(); if not myHRP then return end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local ch  = plr.Character
                local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
                if hrp and enemyHasMedusa(ch) then
                    if (hrp.Position - myHRP.Position).Magnitude <= 5 then
                        useCounterMedusa(); break
                    end
                end
            end
        end
    end)
end

local function stopCounterMedusa()
    Enabled.CounterMedusa = false
    if medusaCounterConn then safeDiscMedusa(medusaCounterConn); medusaCounterConn = nil end
    if medusaPlayerConns["_added"] then safeDiscMedusa(medusaPlayerConns["_added"]); medusaPlayerConns["_added"] = nil end
    for tool, _ in pairs(medusaToolConns) do unbindMedusaTool(tool) end
    for plr, _ in pairs(medusaPlayerConns) do
        if plr ~= "_added" then unbindPlayerMedusa(plr) end
    end
end

local function captureJumpPower()
    local c = LocalPlayer.Character
    if c then local hum = c:FindFirstChildOfClass("Humanoid") if hum and hum.JumpPower > 0 then originalJumpPower = hum.JumpPower end end
end
task.spawn(function() task.wait(0.1) captureJumpPower() end)
LocalPlayer.CharacterAdded:Connect(function() task.wait(0.1) captureJumpPower() end)

local function setupGalaxyForce()
    pcall(function()
        local c = LocalPlayer.Character if not c then return end
        local h = c:FindFirstChild("HumanoidRootPart") if not h then return end
        if galaxyVectorForce then galaxyVectorForce:Destroy() end
        if galaxyAttachment then galaxyAttachment:Destroy() end
        galaxyAttachment = Instance.new("Attachment") galaxyAttachment.Parent = h
        galaxyVectorForce = Instance.new("VectorForce")
        galaxyVectorForce.Attachment0 = galaxyAttachment
        galaxyVectorForce.ApplyAtCenterOfMass = true
        galaxyVectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
        galaxyVectorForce.Force = Vector3.new(0,0,0)
        galaxyVectorForce.Parent = h
    end)
end

local function updateGalaxyForce()
    if not galaxyEnabled or not galaxyVectorForce then return end
    local c = LocalPlayer.Character if not c then return end
    local mass = 0
    for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then mass = mass + p:GetMass() end end
    local tg = Values.DEFAULT_GRAVITY * (Values.GalaxyGravityPercent/100)
    galaxyVectorForce.Force = Vector3.new(0, mass*(Values.DEFAULT_GRAVITY-tg)*0.95, 0)
end

local function adjustGalaxyJump()
    pcall(function()
        local c = LocalPlayer.Character if not c then return end
        local hum = c:FindFirstChildOfClass("Humanoid") if not hum then return end
        if not galaxyEnabled then hum.JumpPower = originalJumpPower return end
        if Values.GalaxyJumpOverride then
            hum.JumpPower = Values.GalaxyJumpPower
        else
            local ratio = math.sqrt((Values.DEFAULT_GRAVITY*(Values.GalaxyGravityPercent/100))/Values.DEFAULT_GRAVITY)
            hum.JumpPower = originalJumpPower * ratio
        end
    end)
end

local function doMiniHop()
    if not hopsEnabled then return end
    pcall(function()
        local c = LocalPlayer.Character if not c then return end
        local h = c:FindFirstChild("HumanoidRootPart")
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not h or not hum then return end
        if tick() - lastHopTime < Values.HOP_COOLDOWN then return end
        lastHopTime = tick()
        if hum.FloorMaterial == Enum.Material.Air then
            h.AssemblyLinearVelocity = Vector3.new(h.AssemblyLinearVelocity.X, Values.HOP_POWER, h.AssemblyLinearVelocity.Z)
        end
    end)
end

local function startGalaxy() galaxyEnabled=true hopsEnabled=true setupGalaxyForce() adjustGalaxyJump() end
local function stopGalaxy()
    galaxyEnabled=false hopsEnabled=false
    if galaxyVectorForce then galaxyVectorForce:Destroy() galaxyVectorForce=nil end
    if galaxyAttachment then galaxyAttachment:Destroy() galaxyAttachment=nil end
    adjustGalaxyJump()
end

local function startInfJump()
    infJumpEnabled = true
    -- save original jump power if we have a character
    local c = LocalPlayer.Character
    if c then
        local hum2 = c:FindFirstChildOfClass("Humanoid")
        if hum2 and hum2.JumpPower > 0 then originalJumpPower = hum2.JumpPower end
    end
end

local function stopInfJump()
    infJumpEnabled = false
    forceJump = false
    spaceHeld = false
end

RunService.Heartbeat:Connect(function()
    if hopsEnabled and spaceHeld then doMiniHop() end
    if galaxyEnabled then updateGalaxyForce() end
    -- Inf Jump: apply upward velocity when airborne and space held
    if infJumpEnabled and spaceHeld then
        local c = LocalPlayer.Character
        if c then
            local hum2 = c:FindFirstChildOfClass("Humanoid")
            local hrp2 = c:FindFirstChild("HumanoidRootPart")
            if hum2 and hrp2 and hum2.FloorMaterial == Enum.Material.Air then
                if tick() - lastHopTime < 0.08 then return end
                lastHopTime = tick()
                hrp2.AssemblyLinearVelocity = Vector3.new(hrp2.AssemblyLinearVelocity.X, INF_JUMP_POWER, hrp2.AssemblyLinearVelocity.Z)
            end
        end
    end
end)

local function startUnwalk()
    local c = LocalPlayer.Character if not c then return end
    local hum = c:FindFirstChildOfClass("Humanoid")
    if hum then for _, t in ipairs(hum:GetPlayingAnimationTracks()) do t:Stop() end end
    local anim = c:FindFirstChild("Animate")
    if anim then savedAnimations.Animate = anim:Clone() anim:Destroy() end
end

local function stopUnwalk()
    local c = LocalPlayer.Character
    if c and savedAnimations.Animate then savedAnimations.Animate:Clone().Parent = c savedAnimations.Animate = nil end
end

local noClipTracked = {}
local function startNoClip()
    if Connections.noClip then return end
    Connections.noClip = RunService.Stepped:Connect(function()
        if not Enabled.NoClip then return end
        local playerParts = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                for _, part in ipairs(plr.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        playerParts[part] = true
                        if part.CanCollide then part.CanCollide = false noClipTracked[part] = true end
                    end
                end
            end
        end
        for part, _ in pairs(noClipTracked) do
            if not playerParts[part] then pcall(function() part.CanCollide = true end) noClipTracked[part] = nil end
        end
    end)
end

local function stopNoClip()
    if Connections.noClip then Connections.noClip:Disconnect() Connections.noClip = nil end
    for part, _ in pairs(noClipTracked) do pcall(function() part.CanCollide = true end) end
    noClipTracked = {}
end

local function enableOptimizer()
    if getgenv and getgenv().OPTIMIZER_ACTIVE then return end
    if getgenv then getgenv().OPTIMIZER_ACTIVE = true end
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        Lighting.GlobalShadows = false Lighting.Brightness = 2 Lighting.FogEnd = 9e9 Lighting.FogStart = 9e9
        for _, fx in ipairs(Lighting:GetChildren()) do if fx:IsA("PostEffect") then fx.Enabled = false end end
    end)
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            pcall(function()
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                    obj.Enabled = false obj:Destroy()
                elseif obj:IsA("BasePart") then
                    obj.CastShadow = false obj.Material = Enum.Material.Plastic
                    for _, child in ipairs(obj:GetChildren()) do
                        if child:IsA("Decal") or child:IsA("Texture") or child:IsA("SurfaceAppearance") then child:Destroy() end
                    end
                elseif obj:IsA("Sky") then obj:Destroy() end
            end)
        end
    end)
    xrayEnabled = true
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Anchored and (obj.Name:lower():find("base") or (obj.Parent and obj.Parent.Name:lower():find("base"))) then
                originalTransparency[obj] = obj.LocalTransparencyModifier
                obj.LocalTransparencyModifier = 0.88
            end
        end
    end)
end

local function disableOptimizer()
    if getgenv then getgenv().OPTIMIZER_ACTIVE = false end
    if xrayEnabled then
        for part, value in pairs(originalTransparency) do if part then part.LocalTransparencyModifier = value end end
        originalTransparency = {} xrayEnabled = false
    end
end

local floatTargetY = nil
local floatBaseY = nil  -- the fixed hover height, never changed by jumps

local function startFloat()
    local c = LocalPlayer.Character if not c then return end
    local root = c:FindFirstChild("HumanoidRootPart") if not root then return end
    floatBaseY = root.Position.Y + FLOAT_HEIGHT
    floatTargetY = floatBaseY
    floatEnabled = true
    if floatConnection then floatConnection:Disconnect() end
    floatConnection = RunService.Heartbeat:Connect(function()
        if not floatEnabled then floatConnection:Disconnect() floatConnection = nil return end
        local char = LocalPlayer.Character if not char then return end
        local r = char:FindFirstChild("HumanoidRootPart") if not r then return end
        local diff = floatBaseY - r.Position.Y
        -- If player is above the base, let them fall naturally (don't pull up or lock)
        if r.Position.Y > floatBaseY + 0.5 then
            -- Just let gravity bring them down, only prevent going below base
            return
        end
        -- At or below base: hold them at floatBaseY
        if math.abs(diff) > 0.3 then
            local clampedY = math.clamp(diff * 10, -80, 80)
            r.AssemblyLinearVelocity = Vector3.new(r.AssemblyLinearVelocity.X, clampedY, r.AssemblyLinearVelocity.Z)
        else
            if r.AssemblyLinearVelocity.Y < 0 then
                r.AssemblyLinearVelocity = Vector3.new(r.AssemblyLinearVelocity.X, 0, r.AssemblyLinearVelocity.Z)
            end
        end
    end)
end

local function stopFloat()
    floatEnabled = false floatTargetY = nil floatBaseY = nil
    local c = LocalPlayer.Character
    if c then local r = c:FindFirstChild("HumanoidRootPart") if r then r.AssemblyLinearVelocity = Vector3.new(r.AssemblyLinearVelocity.X,-150,r.AssemblyLinearVelocity.Z) end end
end

local function updateFloatHeight()
    if not floatEnabled then return end
    local c = LocalPlayer.Character if not c then return end
    local root = c:FindFirstChild("HumanoidRootPart") if not root then return end
    floatBaseY = root.Position.Y + FLOAT_HEIGHT
    floatTargetY = floatBaseY
end

local function faceSouth()
    local c = LocalPlayer.Character if not c then return end
    local h = c:FindFirstChild("HumanoidRootPart") if not h then return end
    h.CFrame = CFrame.new(h.Position) * CFrame.Angles(0,0,0)
end

local function faceNorth()
    local c = LocalPlayer.Character if not c then return end
    local h = c:FindFirstChild("HumanoidRootPart") if not h then return end
    h.CFrame = CFrame.new(h.Position) * CFrame.Angles(0,math.rad(180),0)
end

-- ============================================================
-- // DROP BRAINROTS (from Python Hub) //
-- ============================================================
local function doDropBrainrots()
    local char = LocalPlayer.Character
    local hrpDB = char and char:FindFirstChild("HumanoidRootPart")
    if hrpDB then
        hrpDB.AssemblyLinearVelocity = Vector3.new(0, 125, 0)
        task.wait(0.4)
        hrpDB.AssemblyLinearVelocity = Vector3.new(0, -600, 0)
    end
end

local function startAutoLeft()
    if autoLeftConnection then autoLeftConnection:Disconnect() end
    autoLeftPhase = 1
    autoLeftConnection = RunService.Heartbeat:Connect(function()
        if not AutoLeftEnabled then return end
        local c = LocalPlayer.Character if not c then return end
        local h = c:FindFirstChild("HumanoidRootPart")
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not h or not hum then return end
        local currentSpeed = NORMAL_SPEED
        if autoLeftPhase == 1 then
            local dist = (Vector3.new(POSITION_L1.X, h.Position.Y, POSITION_L1.Z) - h.Position).Magnitude
            if dist < 1 then autoLeftPhase = 2 return end
            local dir = Vector3.new((POSITION_L1-h.Position).X,0,(POSITION_L1-h.Position).Z).Unit
            hum:Move(dir,false) h.AssemblyLinearVelocity = Vector3.new(dir.X*currentSpeed,h.AssemblyLinearVelocity.Y,dir.Z*currentSpeed)
        elseif autoLeftPhase == 2 then
            local dist = (Vector3.new(POSITION_L2.X, h.Position.Y, POSITION_L2.Z) - h.Position).Magnitude
            if dist < 1 then
                hum:Move(Vector3.zero,false) h.AssemblyLinearVelocity = Vector3.new(0,0,0)
                AutoLeftEnabled=false Enabled.AutoLeftEnabled=false
                if autoLeftConnection then autoLeftConnection:Disconnect() autoLeftConnection=nil end
                autoLeftPhase=1
                if _G.AutoLeftToggleBg and _G.AutoLeftToggleCircle then
                    _G.AutoLeftToggleBg.BackgroundColor3=Color3.fromRGB(150, 95, 200)
                    _G.AutoLeftToggleCircle.Position=UDim2.new(0,2,0.5,-6)
                end
                if VisualSetters.AutoLeftEnabled then VisualSetters.AutoLeftEnabled(false,true) end
                syncMobileBtn("M_AutoLeft", false)
                faceSouth() return
            end
            local dir = Vector3.new((POSITION_L2-h.Position).X,0,(POSITION_L2-h.Position).Z).Unit
            hum:Move(dir,false) h.AssemblyLinearVelocity = Vector3.new(dir.X*currentSpeed,h.AssemblyLinearVelocity.Y,dir.Z*currentSpeed)
        end
    end)
end

local function stopAutoLeft()
    if autoLeftConnection then autoLeftConnection:Disconnect() autoLeftConnection=nil end
    autoLeftPhase=1
    local c = LocalPlayer.Character
    if c then local hum = c:FindFirstChildOfClass("Humanoid") if hum then hum:Move(Vector3.zero,false) end end
end

local function startAutoRight()
    if autoRightConnection then autoRightConnection:Disconnect() end
    autoRightPhase=1
    local arLastPos, arStuckTimer = nil, 0
    autoRightConnection = RunService.Heartbeat:Connect(function(dt)
        if not AutoRightEnabled then return end
        local c = LocalPlayer.Character if not c then return end
        local h = c:FindFirstChild("HumanoidRootPart")
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not h or not hum then return end
        local currentSpeed = NORMAL_SPEED
        local currentPos = h.Position
        if arLastPos then
            if (currentPos-arLastPos).Magnitude < 0.05 then arStuckTimer=arStuckTimer+dt else arStuckTimer=0 end
        end
        arLastPos = currentPos
        if autoRightPhase == 1 then
            local dist = (Vector3.new(POSITION_R1.X,h.Position.Y,POSITION_R1.Z)-h.Position).Magnitude
            if dist < 1 then autoRightPhase=2 arStuckTimer=0 return end
            if arStuckTimer > 0.4 then
                arStuckTimer=0
                local sd=(POSITION_R1-h.Position)
                local ss=Vector3.new(sd.X,0,sd.Z).Unit*math.min(4,sd.Magnitude)
                h.CFrame=CFrame.new(h.Position+ss) h.AssemblyLinearVelocity=Vector3.zero return
            end
            local dir=Vector3.new((POSITION_R1-h.Position).X,0,(POSITION_R1-h.Position).Z).Unit
            hum:Move(dir,false) h.AssemblyLinearVelocity=Vector3.new(dir.X*currentSpeed,h.AssemblyLinearVelocity.Y,dir.Z*currentSpeed)
        elseif autoRightPhase == 2 then
            local dist=(Vector3.new(POSITION_R2.X,h.Position.Y,POSITION_R2.Z)-h.Position).Magnitude
            if dist < 1 then
                hum:Move(Vector3.zero,false) h.AssemblyLinearVelocity=Vector3.new(0,0,0)
                AutoRightEnabled=false Enabled.AutoRightEnabled=false
                if autoRightConnection then autoRightConnection:Disconnect() autoRightConnection=nil end
                autoRightPhase=1
                if _G.AutoRightToggleBg and _G.AutoRightToggleCircle then
                    _G.AutoRightToggleBg.BackgroundColor3=Color3.fromRGB(150, 95, 200)
                    _G.AutoRightToggleCircle.Position=UDim2.new(0,2,0.5,-6)
                end
                if VisualSetters.AutoRightEnabled then VisualSetters.AutoRightEnabled(false,true) end
                syncMobileBtn("M_AutoRight", false)
                faceNorth() return
            end
            if arStuckTimer > 0.4 then
                arStuckTimer=0
                local sd=(POSITION_R2-h.Position)
                local ss=Vector3.new(sd.X,0,sd.Z).Unit*math.min(4,sd.Magnitude)
                h.CFrame=CFrame.new(h.Position+ss) h.AssemblyLinearVelocity=Vector3.zero return
            end
            local dir=Vector3.new((POSITION_R2-h.Position).X,0,(POSITION_R2-h.Position).Z).Unit
            hum:Move(dir,false) h.AssemblyLinearVelocity=Vector3.new(dir.X*currentSpeed,h.AssemblyLinearVelocity.Y,dir.Z*currentSpeed)
        end
    end)
end

local function stopAutoRight()
    if autoRightConnection then autoRightConnection:Disconnect() autoRightConnection=nil end
    autoRightPhase=1
    local c=LocalPlayer.Character
    if c then local hum=c:FindFirstChildOfClass("Humanoid") if hum then hum:Move(Vector3.zero,false) end end
end

local function startAutoLeftPlay()
    if autoLeftPlayConnection then autoLeftPlayConnection:Disconnect() end
    autoLeftPlayPhase=1
    autoLeftPlayConnection=RunService.Heartbeat:Connect(function()
        if not AutoLeftPlayEnabled then return end
        local c=LocalPlayer.Character if not c then return end
        local h=c:FindFirstChild("HumanoidRootPart")
        local hum=c:FindFirstChildOfClass("Humanoid")
        if not h or not hum then return end
        if autoLeftPlayPhase==1 then
            local dist=(Vector3.new(ALP_P1.X,h.Position.Y,ALP_P1.Z)-h.Position).Magnitude
            if dist<1.5 then speedToggled=true autoLeftPlayPhase=2 if modeLabel then modeLabel.Text="Mode: Carry" end syncMobileBtn("M_Speed",true) return end
            local dir=Vector3.new((ALP_P1-h.Position).X,0,(ALP_P1-h.Position).Z).Unit
            hum:Move(dir,false) h.AssemblyLinearVelocity=Vector3.new(dir.X*NORMAL_SPEED,h.AssemblyLinearVelocity.Y,dir.Z*NORMAL_SPEED)
        elseif autoLeftPlayPhase==2 then
            local dist=(Vector3.new(ALP_P2.X,h.Position.Y,ALP_P2.Z)-h.Position).Magnitude
            if dist<1.5 then autoLeftPlayPhase=3 return end
            local dir=Vector3.new((ALP_P2-h.Position).X,0,(ALP_P2-h.Position).Z).Unit
            hum:Move(dir,false) h.AssemblyLinearVelocity=Vector3.new(dir.X*CARRY_SPEED,h.AssemblyLinearVelocity.Y,dir.Z*CARRY_SPEED)
        elseif autoLeftPlayPhase==3 then
            local dist=(Vector3.new(ALP_P1.X,h.Position.Y,ALP_P1.Z)-h.Position).Magnitude
            if dist<1.5 then autoLeftPlayPhase=4 return end
            local dir=Vector3.new((ALP_P1-h.Position).X,0,(ALP_P1-h.Position).Z).Unit
            hum:Move(dir,false) h.AssemblyLinearVelocity=Vector3.new(dir.X*CARRY_SPEED,h.AssemblyLinearVelocity.Y,dir.Z*CARRY_SPEED)
        elseif autoLeftPlayPhase==4 then
            local dist=(Vector3.new(ALP_P3.X,h.Position.Y,ALP_P3.Z)-h.Position).Magnitude
            if dist<1.5 then
                hum:Move(Vector3.zero,false) h.AssemblyLinearVelocity=Vector3.new(0,0,0)
                AutoLeftPlayEnabled=false Enabled.AutoLeftPlayEnabled=false
                if autoLeftPlayConnection then autoLeftPlayConnection:Disconnect() autoLeftPlayConnection=nil end
                autoLeftPlayPhase=1 speedToggled=true
                if modeLabel then modeLabel.Text="Mode: Carry" end
                if _G.AutoLeftPlayToggleBg and _G.AutoLeftPlayToggleCircle then
                    _G.AutoLeftPlayToggleBg.BackgroundColor3=Color3.fromRGB(150, 95, 200)
                    _G.AutoLeftPlayToggleCircle.Position=UDim2.new(0,2,0.5,-6)
                end
                if VisualSetters.AutoLeftPlayEnabled then VisualSetters.AutoLeftPlayEnabled(false,true) end
                syncMobileBtn("M_AutoLeftPlay", false)
                return
            end
            local dir=Vector3.new((ALP_P3-h.Position).X,0,(ALP_P3-h.Position).Z).Unit
            hum:Move(dir,false) h.AssemblyLinearVelocity=Vector3.new(dir.X*CARRY_SPEED,h.AssemblyLinearVelocity.Y,dir.Z*CARRY_SPEED)
        end
    end)
end

local function stopAutoLeftPlay()
    if autoLeftPlayConnection then autoLeftPlayConnection:Disconnect() autoLeftPlayConnection=nil end
    autoLeftPlayPhase=1 speedToggled=true
    if modeLabel then modeLabel.Text="Mode: Carry" end
    local c=LocalPlayer.Character
    if c then local hum=c:FindFirstChildOfClass("Humanoid") if hum then hum:Move(Vector3.zero,false) end end
end

local function startAutoRightPlay()
    if autoRightPlayConnection then autoRightPlayConnection:Disconnect() end
    autoRightPlayPhase=1
    autoRightPlayConnection=RunService.Heartbeat:Connect(function()
        if not AutoRightPlayEnabled then return end
        local c=LocalPlayer.Character if not c then return end
        local h=c:FindFirstChild("HumanoidRootPart")
        local hum=c:FindFirstChildOfClass("Humanoid")
        if not h or not hum then return end
        if autoRightPlayPhase==1 then
            local dist=(Vector3.new(ARP_P1.X,h.Position.Y,ARP_P1.Z)-h.Position).Magnitude
            if dist<1.5 then speedToggled=true autoRightPlayPhase=2 if modeLabel then modeLabel.Text="Mode: Carry" end syncMobileBtn("M_Speed",true) return end
            local dir=Vector3.new((ARP_P1-h.Position).X,0,(ARP_P1-h.Position).Z).Unit
            hum:Move(dir,false) h.AssemblyLinearVelocity=Vector3.new(dir.X*NORMAL_SPEED,h.AssemblyLinearVelocity.Y,dir.Z*NORMAL_SPEED)
        elseif autoRightPlayPhase==2 then
            local dist=(Vector3.new(ARP_P2.X,h.Position.Y,ARP_P2.Z)-h.Position).Magnitude
            if dist<1.5 then autoRightPlayPhase=3 return end
            local dir=Vector3.new((ARP_P2-h.Position).X,0,(ARP_P2-h.Position).Z).Unit
            hum:Move(dir,false) h.AssemblyLinearVelocity=Vector3.new(dir.X*CARRY_SPEED,h.AssemblyLinearVelocity.Y,dir.Z*CARRY_SPEED)
        elseif autoRightPlayPhase==3 then
            local dist=(Vector3.new(ARP_P1.X,h.Position.Y,ARP_P1.Z)-h.Position).Magnitude
            if dist<1.5 then autoRightPlayPhase=4 return end
            local dir=Vector3.new((ARP_P1-h.Position).X,0,(ARP_P1-h.Position).Z).Unit
            hum:Move(dir,false) h.AssemblyLinearVelocity=Vector3.new(dir.X*CARRY_SPEED,h.AssemblyLinearVelocity.Y,dir.Z*CARRY_SPEED)
        elseif autoRightPlayPhase==4 then
            local dist=(Vector3.new(ARP_P3.X,h.Position.Y,ARP_P3.Z)-h.Position).Magnitude
            if dist<1.5 then
                hum:Move(Vector3.zero,false) h.AssemblyLinearVelocity=Vector3.new(0,0,0)
                AutoRightPlayEnabled=false Enabled.AutoRightPlayEnabled=false
                if autoRightPlayConnection then autoRightPlayConnection:Disconnect() autoRightPlayConnection=nil end
                autoRightPlayPhase=1 speedToggled=true
                if modeLabel then modeLabel.Text="Mode: Carry" end
                if _G.AutoRightPlayToggleBg and _G.AutoRightPlayToggleCircle then
                    _G.AutoRightPlayToggleBg.BackgroundColor3=Color3.fromRGB(150, 95, 200)
                    _G.AutoRightPlayToggleCircle.Position=UDim2.new(0,2,0.5,-6)
                end
                if VisualSetters.AutoRightPlayEnabled then VisualSetters.AutoRightPlayEnabled(false,true) end
                syncMobileBtn("M_AutoRightPlay", false)
                return
            end
            local dir=Vector3.new((ARP_P3-h.Position).X,0,(ARP_P3-h.Position).Z).Unit
            hum:Move(dir,false) h.AssemblyLinearVelocity=Vector3.new(dir.X*CARRY_SPEED,h.AssemblyLinearVelocity.Y,dir.Z*CARRY_SPEED)
        end
    end)
end

local function stopAutoRightPlay()
    if autoRightPlayConnection then autoRightPlayConnection:Disconnect() autoRightPlayConnection=nil end
    autoRightPlayPhase=1 speedToggled=true
    if modeLabel then modeLabel.Text="Mode: Carry" end
    local c=LocalPlayer.Character
    if c then local hum=c:FindFirstChildOfClass("Humanoid") if hum then hum:Move(Vector3.zero,false) end end
end

local function getBat()
    local char=LocalPlayer.Character if not char then return nil end
    local tool=char:FindFirstChildWhichIsA("Tool")
    if tool and tool.Name=="Bat" then return tool end
    local bp=LocalPlayer:FindFirstChild("Backpack")
    if bp then local bpTool=bp:FindFirstChild("Bat") if bpTool then return bpTool end end
    return nil
end

local function findBat() return getBat() end

local aimbotTarget = nil

local function findNearestEnemy(myHRP)
    local nearest,nearestDist,nearestTorso=nil,math.huge,nil
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Player and p.Character then
            local eh=p.Character:FindFirstChild("HumanoidRootPart")
            local torso=p.Character:FindFirstChild("UpperTorso") or p.Character:FindFirstChild("Torso")
            local hum=p.Character:FindFirstChildOfClass("Humanoid")
            if eh and hum and hum.Health > 0 then
                local d=(eh.Position-myHRP.Position).Magnitude
                if d < nearestDist then nearestDist=d nearest=eh nearestTorso=torso or eh end
            end
        end
    end
    return nearest,nearestDist,nearestTorso
end

local meleeGyro = nil
local meleeAimbotTorso = nil

local function startBatAimbot()
    if Connections.batAimbot then return end

    Connections.batAimbot = RunService.Heartbeat:Connect(function(dt)
        if not Enabled.BatAimbot then return end
        local c=Player.Character if not c then return end
        local h=c:FindFirstChild("HumanoidRootPart")
        local hum=c:FindFirstChildOfClass("Humanoid")
        if not h or not hum then return end

        local target,dist,torso=findNearestEnemy(h)
        aimbotTarget=torso or target
        meleeAimbotTorso=torso or target
        if not target or not torso then return end

        local targetVel=torso.AssemblyLinearVelocity
        local dir=torso.Position-h.Position
        local flatDir=Vector3.new(dir.X,0,dir.Z)
        local flatDist=flatDir.Magnitude
        local timeToReach=flatDist/NORMAL_SPEED
        local predictedPos=torso.Position+targetVel*timeToReach

        -- Step 1: set velocity first
        if flatDist > 1 then
            local moveDir=Vector3.new(predictedPos.X-h.Position.X,0,predictedPos.Z-h.Position.Z).Unit
            local yDiff=torso.Position.Y-h.Position.Y
            local ySpeed=math.abs(yDiff)>0.5 and math.clamp(yDiff*8,-100,100) or targetVel.Y
            h.AssemblyLinearVelocity=Vector3.new(moveDir.X*NORMAL_SPEED,ySpeed,moveDir.Z*NORMAL_SPEED)
        else
            h.AssemblyLinearVelocity=Vector3.new(targetVel.X,targetVel.Y,targetVel.Z)
        end

        -- Step 2: set rotation AFTER velocity in the same Heartbeat tick
        -- This order matters — CFrame set last in the frame wins over physics
        if flatDist > 0.1 then
            local angle=math.atan2(flatDir.X,flatDir.Z)
            local curVel=h.AssemblyLinearVelocity
            h.CFrame=CFrame.new(h.Position)*CFrame.fromEulerAnglesYXZ(0,angle,0)
            h.AssemblyLinearVelocity=curVel
        end
    end)
end

local function stopBatAimbot()
    if Connections.batAimbot then Connections.batAimbot:Disconnect() Connections.batAimbot=nil end
    if Connections.meleeAimbot then Connections.meleeAimbot:Disconnect() Connections.meleeAimbot=nil end
    if meleeGyro then meleeGyro:Destroy() meleeGyro=nil end
    meleeAimbotTorso=nil
    aimbotTarget=nil
end

local syncMobileBtn  -- forward declaration; defined later after buttons are built

local autoSaveLabel
local COLOR_SUCCESS=Color3.fromRGB(34,197,94)
local COLOR_DANGER=Color3.fromRGB(239,68,68)

-- Resolve file API across mobile executors (Delta, Arceus X, Fluxus, etc.)
local _writefile = (typeof(writefile)=="function" and writefile) or (getgenv and typeof(getgenv().writefile)=="function" and getgenv().writefile) or nil
local _readfile  = (typeof(readfile) =="function" and readfile)  or (getgenv and typeof(getgenv().readfile) =="function" and getgenv().readfile)  or nil
local _isfile    = (typeof(isfile)   =="function" and isfile)    or (getgenv and typeof(getgenv().isfile)   =="function" and getgenv().isfile)    or nil
local CONFIG_FILE = "N5DuelsConfig.json"

local function saveConfig()
    -- Collect current button positions
    local btnPos = {}
    for name, ref in pairs(mbRefs) do
        if ref and ref.btn and ref.btn.Parent then
            local abs = ref.btn.AbsolutePosition
            btnPos[name] = {x = math.floor(abs.X), y = math.floor(abs.Y)}
        end
    end
    if ProgressBarContainer and ProgressBarContainer.Parent then
        local abs = ProgressBarContainer.AbsolutePosition
        btnPos["StealBar"] = {x = math.floor(abs.X), y = math.floor(abs.Y)}
    end

    local config = {
        normalSpeed        = NORMAL_SPEED,
        carrySpeed         = CARRY_SPEED,
        speedToggled       = speedToggled,
        autoBatKey         = autoBatKey.Name,
        speedToggleKey     = speedToggleKey.Name,
        floatKey           = floatKey.Name,
        guiToggleKey       = guiToggleKey.Name,
        galaxyKey          = galaxyKey.Name,
        antiRagdoll        = Enabled.AntiRagdoll,
        autoStealEnabled   = Enabled.AutoSteal,
        galaxy             = Enabled.Galaxy,
        optimizer          = Enabled.Optimizer,
        unwalk             = Enabled.Unwalk,
        noClip             = Enabled.NoClip,
        batAimbot          = Enabled.BatAimbot,
        infJump            = Enabled.InfJump,
        autoTP             = Enabled.AutoTP,
        darkMode           = Enabled.DarkMode,
        floatEnabled       = Enabled.FloatEnabled,
        grabRadius         = Values.STEAL_RADIUS,
        stealDuration      = Values.STEAL_DURATION,
        galaxyGravity      = Values.GalaxyGravityPercent,
        hopPower           = Values.HOP_POWER,
        hopCooldown        = Values.HOP_COOLDOWN,
        galaxyJumpOverride = Values.GalaxyJumpOverride,
        galaxyJumpPower    = Values.GalaxyJumpPower,
        infJumpPower       = INF_JUMP_POWER,
        tpSelectedSide     = tpSelectedSide,
        uiTransparency     = currentTransparency,
        floatHeight        = FLOAT_HEIGHT,
        uiScale            = uiScaleValue,
        uiLocked           = uiLocked,
        btnPositions       = btnPos,
    }

    local encOk, json = pcall(HttpService.JSONEncode, HttpService, config)
    if not encOk then
        warn("[N5] saveConfig encode failed: "..tostring(json))
        return false
    end

    local success = false

    -- 1. writefile — persistent across sessions (some mobile executors support this)
    if _writefile then
        local ok = pcall(_writefile, CONFIG_FILE, json)
        if ok then success = true end
    end

    -- 2. getgenv memory — survives re-runs in the same executor session
    if getgenv then
        pcall(function() getgenv().__N5DuelsConfig = json end)
        success = true
    end

    -- 3. PlayerGui StringValue — survives script re-inject in same game session
    pcall(function()
        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if not pg then return end
        local sv = pg:FindFirstChild("__N5Config")
        if not sv then
            sv = Instance.new("StringValue")
            sv.Name = "__N5Config"
            sv.Parent = pg
        end
        sv.Value = json
        success = true
    end)

    return success
end

local function loadConfig()
    local raw = nil

    -- 1. Try persistent file
    if _isfile and _readfile then
        pcall(function()
            if _isfile(CONFIG_FILE) then
                local result = _readfile(CONFIG_FILE)
                if type(result) == "string" and #result > 2 then raw = result end
            end
        end)
    end

    -- 2. Try PlayerGui StringValue
    if not raw then
        pcall(function()
            local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
            if not pg then return end
            local sv = pg:FindFirstChild("__N5Config")
            if sv and type(sv.Value) == "string" and #sv.Value > 2 then
                raw = sv.Value
            end
        end)
    end

    -- 3. Try getgenv memory
    if not raw and getgenv then
        pcall(function()
            local v = getgenv().__N5DuelsConfig
            if type(v) == "string" and #v > 2 then raw = v end
        end)
    end

    if not raw then return end

    local ok, config = pcall(HttpService.JSONDecode, HttpService, raw)
    if not ok or type(config) ~= "table" then return end

    -- Speed
    if config.normalSpeed then NORMAL_SPEED = config.normalSpeed end
    if config.carrySpeed  then CARRY_SPEED  = config.carrySpeed  end
    if config.speedToggled ~= nil then speedToggled = config.speedToggled end

    -- Controller binds
    if config.autoBatKey     and Enum.KeyCode[config.autoBatKey]     then autoBatKey     = Enum.KeyCode[config.autoBatKey]     end
    if config.speedToggleKey and Enum.KeyCode[config.speedToggleKey] then speedToggleKey = Enum.KeyCode[config.speedToggleKey] end
    if config.floatKey       and Enum.KeyCode[config.floatKey]       then floatKey       = Enum.KeyCode[config.floatKey]       end
    if config.guiToggleKey   and Enum.KeyCode[config.guiToggleKey]   then guiToggleKey   = Enum.KeyCode[config.guiToggleKey]   end
    if config.galaxyKey      and Enum.KeyCode[config.galaxyKey]      then galaxyKey      = Enum.KeyCode[config.galaxyKey]      end

    -- Feature toggles
    if config.antiRagdoll      ~= nil then Enabled.AntiRagdoll    = config.antiRagdoll      end
    if config.autoStealEnabled ~= nil then Enabled.AutoSteal      = config.autoStealEnabled  end
    if config.galaxy           ~= nil then Enabled.Galaxy         = config.galaxy            end
    if config.optimizer        ~= nil then Enabled.Optimizer      = config.optimizer         end
    if config.unwalk           ~= nil then Enabled.Unwalk         = config.unwalk            end
    if config.noClip           ~= nil then Enabled.NoClip         = config.noClip            end
    if config.batAimbot        ~= nil then Enabled.BatAimbot      = config.batAimbot         end
    if config.infJump          ~= nil then Enabled.InfJump        = config.infJump           end
    if config.autoTP           ~= nil then Enabled.AutoTP         = config.autoTP            end
    if config.darkMode         ~= nil then Enabled.DarkMode       = config.darkMode          end
    if config.floatEnabled     ~= nil then Enabled.FloatEnabled   = config.floatEnabled      end

    -- Feature values
    if config.grabRadius         then Values.STEAL_RADIUS         = math.clamp(math.floor(config.grabRadius), 5, 200) end
    if config.stealDuration      then Values.STEAL_DURATION       = math.max(0.01, config.stealDuration)              end
    if config.galaxyGravity      then Values.GalaxyGravityPercent = config.galaxyGravity                              end
    if config.hopPower           then Values.HOP_POWER            = config.hopPower                                   end
    if config.hopCooldown        then Values.HOP_COOLDOWN         = math.max(0.01, config.hopCooldown)                end
    if config.galaxyJumpOverride ~= nil then Values.GalaxyJumpOverride = config.galaxyJumpOverride end
    if config.galaxyJumpPower    then Values.GalaxyJumpPower      = math.max(1, config.galaxyJumpPower) end
    if config.infJumpPower       then INF_JUMP_POWER              = math.max(1, config.infJumpPower)    end

    -- TP
    if config.tpSelectedSide then tpSelectedSide = config.tpSelectedSide end

    -- UI
    if config.uiTransparency then currentTransparency = math.clamp(config.uiTransparency, 0, 1)   end
    if config.floatHeight    then FLOAT_HEIGHT         = math.clamp(config.floatHeight, 1, 20)     end
    if config.uiScale        then uiScaleValue         = math.clamp(config.uiScale, 0.5, 3.0)      end
    if config.uiLocked ~= nil then uiLocked = config.uiLocked end

    -- Button positions
    if type(config.btnPositions) == "table" then
        savedBtnPositions = config.btnPositions
    end
end

loadConfig()

-- =====================================================
-- ===== CONTROLLER INPUT HELPERS
-- =====================================================
local function isSelectInput(inputType)
    return inputType == Enum.UserInputType.Touch
        or inputType == Enum.UserInputType.Gamepad1
end
local function isMoveInput(inputType)
    return inputType == Enum.UserInputType.Touch
        or inputType == Enum.UserInputType.Gamepad1
end
-- Hook a UI button to respond to touch/tap AND controller ButtonA
local function hookBtn(btn, fn)
    btn.Activated:Connect(fn)  -- fires on mobile tap, touch, and mouse click reliably
    btn.InputBegan:Connect(function(i)
        if i.KeyCode == Enum.KeyCode.ButtonA then fn() end
    end)
end
-- Thumbstick slider registry: active slider is driven by left thumbstick X
local thumbstickSliders = {}
local thumbstickX = 0
UserInputService.InputChanged:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Gamepad1
    and i.KeyCode == Enum.KeyCode.Thumbstick1 then
        thumbstickX = i.Position.X
    end
end)
RunService.Heartbeat:Connect(function(dt)
    if math.abs(thumbstickX) > 0.15 then
        for _, s in ipairs(thumbstickSliders) do
            if s.active then
                local curPct = s.getPct()
                local newPct = math.clamp(curPct + thumbstickX * dt * 1.5, 0, 1)
                local fakeX = s.track.AbsolutePosition.X + newPct * s.track.AbsoluteSize.X
                s.update(fakeX)
            end
        end
    end
end)
local function registerSlider(track, updateFn, getPctFn, hitbox)
    local entry = {track=track, update=updateFn, getPct=getPctFn, active=false}
    table.insert(thumbstickSliders, entry)
    -- Tap/click the hitbox or press ButtonA on it to activate thumbstick control
    hitbox.InputBegan:Connect(function(i)
        if i.KeyCode == Enum.KeyCode.ButtonA then
            -- deactivate all others
            for _, s in ipairs(thumbstickSliders) do s.active = false end
            entry.active = true
        end
    end)
    return entry
end

local darkColorCorrection=nil
local darkOriginalBrightness=nil

local function enableDarkMode()
    if darkColorCorrection and darkColorCorrection.Parent then return end
    darkOriginalBrightness=Lighting.Brightness
    darkColorCorrection=Instance.new("ColorCorrectionEffect")
    darkColorCorrection.Name="N5DuelsDarkMode"
    darkColorCorrection.Brightness=-0.25
    darkColorCorrection.Contrast=0.1
    darkColorCorrection.Saturation=-0.1
    darkColorCorrection.Enabled=true
    darkColorCorrection.Parent=Lighting
end

local function disableDarkMode()
    if darkColorCorrection then darkColorCorrection:Destroy() darkColorCorrection=nil end
    if darkOriginalBrightness~=nil then Lighting.Brightness=darkOriginalBrightness darkOriginalBrightness=nil end
end

-- =====================================================
-- ===== THEME: BLACK BG, PURPLE TEXT
-- =====================================================

local C = {
    bg          = Color3.fromRGB(8, 8, 8),
    panel       = Color3.fromRGB(18, 18, 18),
    rowAlt      = Color3.fromRGB(14, 14, 14),
    border      = Color3.fromRGB(160, 80, 220),
    accent      = Color3.fromRGB(180, 100, 255),
    accentDim   = Color3.fromRGB(140, 70, 200),
    text        = Color3.fromRGB(255, 255, 255),
    textDim     = Color3.fromRGB(220, 220, 220),
    textMid     = Color3.fromRGB(200, 200, 200),
    toggleOn    = Color3.fromRGB(160, 80, 220),
    toggleOff   = Color3.fromRGB(35, 35, 35),
    circleOn    = Color3.fromRGB(255, 255, 255),
    circleOff   = Color3.fromRGB(80, 80, 80),
    headerBg    = Color3.fromRGB(5, 5, 5),
    btnBg       = Color3.fromRGB(22, 22, 22),
    success     = Color3.fromRGB(34, 197, 94),
    danger      = Color3.fromRGB(239, 68, 68),
}

local GUI_W=280
local GUI_H=320

local gui=Instance.new("ScreenGui")
gui.Name="N5DuelsGUI"
gui.ResetOnSpawn=false
gui.Parent=LocalPlayer:WaitForChild("PlayerGui")

local main=Instance.new("Frame")
main.Name="Main"
main.Size=UDim2.new(0,GUI_W,0,GUI_H)
main.Position=UDim2.new(0,16,0.5,-(GUI_H/2))
main.BackgroundColor3=C.bg
main.BackgroundTransparency=currentTransparency
main.BorderSizePixel=0
main.Active=true
main.Draggable=true
main.ClipsDescendants=true
main.Parent=gui
-- Sharp box: no UICorner

local mainStroke=Instance.new("UIStroke")
mainStroke.Color=Color3.fromRGB(160,80,220)
mainStroke.Thickness=2
mainStroke.Parent=main

local header=Instance.new("Frame")
header.Size=UDim2.new(1,0,0,34)
header.Position=UDim2.new(0,0,0,0)
header.BackgroundColor3=C.headerBg
header.BackgroundTransparency=0
header.BorderSizePixel=0
header.ZIndex=6
header.Parent=main
-- No UICorner - sharp box

local headerFill=Instance.new("Frame")
headerFill.Size=UDim2.new(1,0,0,8)
headerFill.Position=UDim2.new(0,0,1,-8)
headerFill.BackgroundColor3=C.headerBg
headerFill.BackgroundTransparency=0
headerFill.BorderSizePixel=0
headerFill.ZIndex=6
headerFill.Parent=header

local title=Instance.new("TextLabel")
title.Size=UDim2.new(1,0,0,34)
title.Position=UDim2.new(0,0,0,0)
title.BackgroundTransparency=1
title.Text="N5 DUELS"
title.TextColor3=C.text
title.Font=Enum.Font.GothamBold
title.TextSize=11
title.TextXAlignment=Enum.TextXAlignment.Center
title.TextYAlignment=Enum.TextYAlignment.Center
title.ZIndex=7
title.Parent=header

local headerDiv=Instance.new("Frame")
headerDiv.Size=UDim2.new(1,0,0,1)
headerDiv.Position=UDim2.new(0,0,0,34)
headerDiv.BackgroundColor3=Color3.fromRGB(160,80,220)
headerDiv.BorderSizePixel=0
headerDiv.ZIndex=6
headerDiv.Parent=main

local content=Instance.new("ScrollingFrame")
content.Size=UDim2.new(1,0,1,-36)
content.Position=UDim2.new(0,0,0,36)
content.BackgroundTransparency=1
content.BorderSizePixel=0
content.ScrollBarThickness=3
content.ScrollBarImageColor3=Color3.fromRGB(160, 80, 220)
content.CanvasSize=UDim2.new(0,0,0,0)
content.ZIndex=5
content.Parent=main

local yPos=8
local VisualSetters={}
local waitingForKeybind=nil
local waitingForKeybindType=nil

-- Stop every auto move and bat aimbot unconditionally, updating all visuals.
-- Pass exceptKey to skip stopping one specific feature (the one being turned ON).
local function stopAllAutoMoves(exceptKey)
    if exceptKey ~= "AutoLeftEnabled" then
        AutoLeftEnabled=false Enabled.AutoLeftEnabled=false
        stopAutoLeft()
        if VisualSetters.AutoLeftEnabled then VisualSetters.AutoLeftEnabled(false,true) end
        if syncMobileBtn then syncMobileBtn("M_AutoLeft", false) end
    end
    if exceptKey ~= "AutoRightEnabled" then
        AutoRightEnabled=false Enabled.AutoRightEnabled=false
        stopAutoRight()
        if VisualSetters.AutoRightEnabled then VisualSetters.AutoRightEnabled(false,true) end
        if syncMobileBtn then syncMobileBtn("M_AutoRight", false) end
    end
    if exceptKey ~= "AutoLeftPlayEnabled" then
        AutoLeftPlayEnabled=false Enabled.AutoLeftPlayEnabled=false
        stopAutoLeftPlay()
        if VisualSetters.AutoLeftPlayEnabled then VisualSetters.AutoLeftPlayEnabled(false,true) end
        if syncMobileBtn then syncMobileBtn("M_AutoLeftPlay", false) end
    end
    if exceptKey ~= "AutoRightPlayEnabled" then
        AutoRightPlayEnabled=false Enabled.AutoRightPlayEnabled=false
        stopAutoRightPlay()
        if VisualSetters.AutoRightPlayEnabled then VisualSetters.AutoRightPlayEnabled(false,true) end
        if syncMobileBtn then syncMobileBtn("M_AutoRightPlay", false) end
    end
    if exceptKey ~= "BatAimbot" then
        Enabled.BatAimbot=false autoBatToggled=false
        stopBatAimbot()
        if VisualSetters.BatAimbot then VisualSetters.BatAimbot(false,true) end
        if syncMobileBtn then syncMobileBtn("M_Aimbot", false) end
    end
end

local function addDivider()
    local d=Instance.new("Frame")
    d.Size=UDim2.new(1,-24,0,1)
    d.Position=UDim2.new(0,12,0,yPos)
    d.BackgroundColor3=Color3.fromRGB(160,80,220)
    d.BackgroundTransparency=0.7
    d.BorderSizePixel=0
    d.ZIndex=5
    d.Parent=content
    yPos=yPos+9
end

local function createCategoryHeader(txt)
    local hdr=Instance.new("TextLabel")
    hdr.Size=UDim2.new(1,-24,0,16)
    hdr.Position=UDim2.new(0,12,0,yPos)
    hdr.BackgroundTransparency=1
    hdr.Text=txt
    hdr.TextColor3=Color3.fromRGB(255,255,255)
    hdr.Font=Enum.Font.GothamBlack
    hdr.TextSize=8
    hdr.TextXAlignment=Enum.TextXAlignment.Left
    hdr.ZIndex=5
    hdr.Parent=content
    yPos=yPos+20
end

local function createToggle(labelText,enabledKey,callback,hasKeybind,keybindKey,rightClickCallback)
    local ROW_H=26
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,-24,0,ROW_H)
    row.Position=UDim2.new(0,12,0,yPos)
    row.BackgroundTransparency=1
    row.ZIndex=5
    row.Parent=content

    local xOffset=0
    local keybindBtn=nil

    if hasKeybind and keybindKey then
        keybindBtn=Instance.new("TextButton")
        keybindBtn.Size=UDim2.new(0,26,0,16)
        keybindBtn.Position=UDim2.new(0,0,0.5,-8)
        keybindBtn.BackgroundColor3=C.btnBg
        keybindBtn.Text=keybindKey.Name
        keybindBtn.TextColor3=C.textMid
        keybindBtn.Font=Enum.Font.GothamBold
        keybindBtn.TextSize=7
        keybindBtn.ZIndex=5
        keybindBtn.Parent=row
        Instance.new("UICorner",keybindBtn).CornerRadius=UDim.new(0,5)
        local kStroke=Instance.new("UIStroke")
        kStroke.Color=Color3.fromRGB(160,80,220)
        kStroke.Thickness=1
        kStroke.Parent=keybindBtn
        if enabledKey=="AutoLeftEnabled" then _G.AutoLeftKeybindBtn=keybindBtn
        elseif enabledKey=="AutoRightEnabled" then _G.AutoRightKeybindBtn=keybindBtn
        elseif enabledKey=="AutoLeftPlayEnabled" then _G.AutoLeftPlayKeybindBtn=keybindBtn
        elseif enabledKey=="AutoRightPlayEnabled" then _G.AutoRightPlayKeybindBtn=keybindBtn
        elseif enabledKey=="AimbotEnabled" then _G.AimbotKeybindBtn=keybindBtn end
        xOffset=30
    end

    local label=Instance.new("TextLabel")
    label.Size=UDim2.new(1,-(xOffset+58),1,0)
    label.Position=UDim2.new(0,xOffset,0,0)
    label.BackgroundTransparency=1
    label.Text=labelText
    label.TextColor3=C.text
    label.Font=Enum.Font.GothamSemibold
    label.TextSize=9
    label.TextXAlignment=Enum.TextXAlignment.Left
    label.ZIndex=5
    label.Parent=row

    local defaultOn=Enabled[enabledKey] or false

    local toggleBg=Instance.new("Frame")
    toggleBg.Size=UDim2.new(0,32,0,16)
    toggleBg.Position=UDim2.new(1,-32,0.5,-8)
    toggleBg.BackgroundColor3=defaultOn and C.toggleOn or C.toggleOff
    toggleBg.ZIndex=5
    toggleBg.Parent=row
    Instance.new("UICorner",toggleBg).CornerRadius=UDim.new(1,0)
    local tStroke=Instance.new("UIStroke")
    tStroke.Color=Color3.fromRGB(160,80,220)
    tStroke.Thickness=1
    tStroke.Parent=toggleBg

    local toggleCircle=Instance.new("Frame")
    toggleCircle.Size=UDim2.new(0,12,0,12)
    toggleCircle.Position=defaultOn and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,2,0.5,-6)
    toggleCircle.BackgroundColor3=defaultOn and C.circleOn or C.circleOff
    toggleCircle.ZIndex=6
    toggleCircle.Parent=toggleBg
    Instance.new("UICorner",toggleCircle).CornerRadius=UDim.new(1,0)

    if enabledKey=="AutoLeftEnabled" then _G.AutoLeftToggleBg=toggleBg _G.AutoLeftToggleCircle=toggleCircle
    elseif enabledKey=="AutoRightEnabled" then _G.AutoRightToggleBg=toggleBg _G.AutoRightToggleCircle=toggleCircle
    elseif enabledKey=="AutoLeftPlayEnabled" then _G.AutoLeftPlayToggleBg=toggleBg _G.AutoLeftPlayToggleCircle=toggleCircle
    elseif enabledKey=="AutoRightPlayEnabled" then _G.AutoRightPlayToggleBg=toggleBg _G.AutoRightPlayToggleCircle=toggleCircle
    elseif enabledKey=="AimbotEnabled" then _G.AimbotToggleBg=toggleBg _G.AimbotToggleCircle=toggleCircle end

    local clickBtn=Instance.new("TextButton")
    clickBtn.Size=UDim2.new(1,0,1,0)
    clickBtn.BackgroundTransparency=1
    clickBtn.Text=""
    clickBtn.ZIndex=7
    clickBtn.Parent=row

    local isOn=defaultOn

    local function setVisual(state,skipCallback)
        isOn=state
        TweenService:Create(toggleBg,TweenInfo.new(0.2),{BackgroundColor3=isOn and C.toggleOn or C.toggleOff}):Play()
        TweenService:Create(toggleCircle,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{
            Position=isOn and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,2,0.5,-6),
            BackgroundColor3=isOn and C.circleOn or C.circleOff
        }):Play()
        if not skipCallback and callback then callback(isOn) end
    end

    VisualSetters[enabledKey]=setVisual

    hookBtn(clickBtn, function()
        isOn=not isOn
        setVisual(isOn)
    end)

    if rightClickCallback then
        -- Controller: hold ButtonB on this row opens sub-panel
        clickBtn.InputBegan:Connect(function(i)
            if i.KeyCode==Enum.KeyCode.ButtonB then rightClickCallback() end
        end)
    end

    yPos=yPos+ROW_H+2
    return row,keybindBtn
end

local function createInputRow(labelTxt,defaultVal)
    local ROW_H=26
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,-24,0,ROW_H)
    row.Position=UDim2.new(0,12,0,yPos)
    row.BackgroundTransparency=1
    row.ZIndex=5
    row.Parent=content

    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(0.6,0,1,0)
    lbl.BackgroundTransparency=1
    lbl.Text=labelTxt
    lbl.TextColor3=C.textMid
    lbl.Font=Enum.Font.GothamSemibold
    lbl.TextSize=9
    lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.ZIndex=5
    lbl.Parent=row

    local box=Instance.new("TextBox")
    box.Size=UDim2.new(0,58,0,18)
    box.Position=UDim2.new(1,-58,0.5,-9)
    box.BackgroundColor3=C.btnBg
    box.BorderSizePixel=0
    box.Text=tostring(defaultVal)
    box.TextColor3=C.text
    box.Font=Enum.Font.GothamBold
    box.TextSize=9
    box.ClearTextOnFocus=false
    box.ZIndex=5
    box.Parent=row
    Instance.new("UICorner",box).CornerRadius=UDim.new(0,5)
    local bStroke=Instance.new("UIStroke")
    bStroke.Color=Color3.fromRGB(160,80,220)
    bStroke.Thickness=1
    bStroke.Parent=box

    yPos=yPos+ROW_H+2
    return box
end

local function createTextInput(labelTxt, defaultVal, minVal, maxVal, onChange, rowH, clampVal)
    rowH = rowH or 36
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,-24,0,rowH)
    row.Position = UDim2.new(0,12,0,yPos)
    row.BackgroundTransparency = 1
    row.ZIndex = 5
    row.Parent = content

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.6,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelTxt
    lbl.TextColor3 = C.textMid
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 5
    lbl.Parent = row

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0,80,0,26)
    box.Position = UDim2.new(1,-80,0.5,-13)
    box.BackgroundColor3 = C.btnBg
    box.BorderSizePixel = 0
    box.Text = tostring(defaultVal)
    box.TextColor3 = C.text
    box.Font = Enum.Font.GothamBold
    box.TextSize = 12
    box.ClearTextOnFocus = false
    box.ZIndex = 5
    box.Parent = row
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,5)
    local bStroke = Instance.new("UIStroke")
    bStroke.Color = Color3.fromRGB(160,80,220)
    bStroke.Thickness = 1
    bStroke.Parent = box

    box:GetPropertyChangedSignal("Text"):Connect(function()
        local v = tonumber(box.Text)
        if v then
            if clampVal then v = math.clamp(v, minVal, maxVal) end
            if onChange then onChange(v) end
        end
    end)

    yPos = yPos + rowH + 2
    return box
end

-- ============================================================
-- // ACTION BUTTON (for Drop Brainrots in the main GUI list) //
-- ============================================================
local function createActionButton(labelTxt, btnTxt, onPress)
    local ROW_H = 26
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,-24,0,ROW_H)
    row.Position = UDim2.new(0,12,0,yPos)
    row.BackgroundTransparency = 1
    row.ZIndex = 5
    row.Parent = content

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.55,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelTxt
    lbl.TextColor3 = C.text
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 5
    lbl.Parent = row

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,80,0,28)
    btn.Position = UDim2.new(1,-80,0.5,-14)
    btn.BackgroundColor3 = C.btnBg
    btn.Text = btnTxt
    btn.TextColor3 = C.text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    btn.ZIndex = 6
    btn.Parent = row
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)
    local bS=Instance.new("UIStroke") bS.Color=Color3.fromRGB(160,80,220) bS.Thickness=1 bS.Parent=btn

    hookBtn(btn, onPress)

    yPos = yPos + ROW_H + 2
    return btn
end

local function makeKeyRow(labelTxt,defaultKeyName)
    local ROW_H=34
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,-24,0,ROW_H)
    row.Position=UDim2.new(0,12,0,yPos)
    row.BackgroundTransparency=1
    row.ZIndex=5
    row.Parent=content

    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(0.55,0,1,0)
    lbl.BackgroundTransparency=1
    lbl.Text=labelTxt
    lbl.TextColor3=C.textMid
    lbl.Font=Enum.Font.GothamSemibold
    lbl.TextSize=12
    lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.ZIndex=5
    lbl.Parent=row

    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(0,80,0,26)
    btn.Position=UDim2.new(1,-80,0.5,-13)
    btn.BackgroundColor3=C.btnBg
    btn.Text=defaultKeyName
    btn.TextColor3=C.text
    btn.Font=Enum.Font.GothamBold
    btn.TextSize=11
    btn.ZIndex=5
    btn.Parent=row
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,5)
    local bkStroke=Instance.new("UIStroke")
    bkStroke.Color=Color3.fromRGB(160,80,220)
    bkStroke.Thickness=1
    bkStroke.Parent=btn

    yPos=yPos+ROW_H+2
    return btn
end

local function createSubPanel(height,buildFn)
    local panelY=yPos
    local panel=Instance.new("Frame")
    panel.Size=UDim2.new(1,-24,0,height)
    panel.Position=UDim2.new(0,12,0,panelY)
    panel.BackgroundColor3=C.panel
    panel.BackgroundTransparency=0
    panel.BorderSizePixel=0
    panel.Visible=false
    panel.ZIndex=5
    panel.Parent=content
    Instance.new("UICorner",panel).CornerRadius=UDim.new(0,6)
    local pStroke=Instance.new("UIStroke")
    pStroke.Color=Color3.fromRGB(160,80,220)
    pStroke.Thickness=1
    pStroke.Parent=panel
    buildFn(panel)
    local elementsAfter={}
    local isVisible=false
    local function gatherElementsAfter()
        local found=false
        for _,child in ipairs(content:GetChildren()) do
            if child==panel then found=true elseif found then table.insert(elementsAfter,child) end
        end
    end
    local function togglePanel()
        if #elementsAfter==0 then gatherElementsAfter() end
        isVisible=not isVisible
        panel.Visible=isVisible
        local delta=isVisible and height or -height
        for _,el in ipairs(elementsAfter) do
            if el and el.Parent then
                el.Position=UDim2.new(el.Position.X.Scale,el.Position.X.Offset,el.Position.Y.Scale,el.Position.Y.Offset+delta)
            end
        end
        content.CanvasSize=UDim2.new(0,0,0,content.CanvasSize.Y.Offset+delta)
    end
    return panel,togglePanel
end

-- ===== TP FLOATING WINDOW =====
local tpWindow=Instance.new("Frame")
tpWindow.Name="N5DuelsTPWindow"
tpWindow.Size=UDim2.new(0,200,0,160)
tpWindow.Position=UDim2.new(0,330,0,20)
tpWindow.BackgroundColor3=C.bg
tpWindow.BackgroundTransparency=currentTransparency
tpWindow.BorderSizePixel=0
tpWindow.Active=true
tpWindow.Draggable=true
tpWindow.Visible=false
tpWindow.ZIndex=20
tpWindow.Parent=gui
Instance.new("UICorner",tpWindow).CornerRadius=UDim.new(0,8)
local tpStroke=Instance.new("UIStroke")
tpStroke.Color=Color3.fromRGB(160,80,220)
tpStroke.Thickness=2
tpStroke.Parent=tpWindow

local tpWinTitle=Instance.new("TextLabel")
tpWinTitle.Size=UDim2.new(1,0,0,36)
tpWinTitle.BackgroundTransparency=1
tpWinTitle.Text="AUTO TP"
tpWinTitle.TextColor3=C.text
tpWinTitle.Font=Enum.Font.GothamBold
tpWinTitle.TextSize=13
tpWinTitle.TextXAlignment=Enum.TextXAlignment.Center
tpWinTitle.ZIndex=21
tpWinTitle.Parent=tpWindow

local tpDiv=Instance.new("Frame")
tpDiv.Size=UDim2.new(0.85,0,0,1)
tpDiv.Position=UDim2.new(0.075,0,0,36)
tpDiv.BackgroundColor3=Color3.fromRGB(160,80,220)
tpDiv.BackgroundTransparency=0.5
tpDiv.BorderSizePixel=0
tpDiv.ZIndex=21
tpDiv.Parent=tpWindow

local tpWinStatus=Instance.new("TextLabel")
tpWinStatus.Size=UDim2.new(1,-20,0,16)
tpWinStatus.Position=UDim2.new(0,10,0,42)
tpWinStatus.BackgroundTransparency=1
tpWinStatus.Text="Select a base"
tpWinStatus.TextColor3=C.textDim
tpWinStatus.Font=Enum.Font.Gotham
tpWinStatus.TextSize=10
tpWinStatus.ZIndex=21
tpWinStatus.Parent=tpWindow
tpStatusLabel=tpWinStatus

local tpBtnFrame=Instance.new("Frame")
tpBtnFrame.Size=UDim2.new(1,-20,0,32)
tpBtnFrame.Position=UDim2.new(0,10,0,64)
tpBtnFrame.BackgroundTransparency=1
tpBtnFrame.ZIndex=21
tpBtnFrame.Parent=tpWindow

local tpLayout=Instance.new("UIListLayout")
tpLayout.FillDirection=Enum.FillDirection.Horizontal
tpLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center
tpLayout.VerticalAlignment=Enum.VerticalAlignment.Center
tpLayout.Padding=UDim.new(0,8)
tpLayout.Parent=tpBtnFrame

local function makeTpBtn(txt,side)
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(0,80,0,32)
    btn.BackgroundColor3=C.btnBg
    btn.Text=txt
    btn.TextColor3=C.text
    btn.Font=Enum.Font.GothamBold
    btn.TextSize=11
    btn.BorderSizePixel=0
    btn.ZIndex=22
    btn.Parent=tpBtnFrame
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,5)
    local s=Instance.new("UIStroke") s.Color=Color3.fromRGB(160,80,220) s.Thickness=1 s.Parent=btn
    hookBtn(btn, function()
        tpSelectedSide=side
        tpWinStatus.Text=side.." base selected"
        tpWinStatus.TextColor3=C.text
    end)
end
makeTpBtn("Left","Left")
makeTpBtn("Right","Right")

local tpDisableBtn=Instance.new("TextButton")
tpDisableBtn.Size=UDim2.new(1,-20,0,32)
tpDisableBtn.Position=UDim2.new(0,10,0,104)
tpDisableBtn.BackgroundColor3=C.btnBg
tpDisableBtn.Text="Disable TP"
tpDisableBtn.TextColor3=C.textMid
tpDisableBtn.Font=Enum.Font.GothamBold
tpDisableBtn.TextSize=11
tpDisableBtn.BorderSizePixel=0
tpDisableBtn.ZIndex=22
tpDisableBtn.Parent=tpWindow
Instance.new("UICorner",tpDisableBtn).CornerRadius=UDim.new(0,5)
local dStroke=Instance.new("UIStroke") dStroke.Color=Color3.fromRGB(160,80,220) dStroke.Thickness=1 dStroke.Parent=tpDisableBtn
hookBtn(tpDisableBtn, function()
    tpSelectedSide=nil stopAutoTP() setTpStatus("Disabled — select a base",C.textDim)
end)

-- ===== BUILD CONTENT =====

createCategoryHeader("FEATURES")

createToggle("X-Ray + Optimizer","Optimizer",function(state)
    if state then enableOptimizer() else disableOptimizer() end
end)
createToggle("Disable Animation","Unwalk",function(state)
    if state then startUnwalk() else stopUnwalk() end
end)
createToggle("No Clip","NoClip",function(state)
    if state then startNoClip() else stopNoClip() end
end)
createToggle("Inf Jump","InfJump",function(state)
    infJumpEnabled = state
    if state then startInfJump() else stopInfJump() end
end)
createToggle("Dark Mode","DarkMode",function(state)
    if state then enableDarkMode() else disableDarkMode() end
end)

local stealPanelToggle
createToggle("Auto Steal","AutoSteal",function(state)
    if state then startAutoSteal() else stopAutoSteal() end
end,false,nil,function()
    if stealPanelToggle then stealPanelToggle() end
end)

local _,stealPanelToggleFinal=createSubPanel(90,function(panel)
    local hint=Instance.new("TextLabel")
    hint.Size=UDim2.new(1,-16,0,12) hint.Position=UDim2.new(0,8,0,6)
    hint.BackgroundTransparency=1 hint.Text="Right-click Auto Steal to close"
    hint.TextColor3=Color3.fromRGB(220, 220, 220) hint.Font=Enum.Font.GothamBold hint.TextSize=9
    hint.TextXAlignment=Enum.TextXAlignment.Left hint.ZIndex=6 hint.Parent=panel

    local dLbl=Instance.new("TextLabel")
    dLbl.Size=UDim2.new(0,110,0,24) dLbl.Position=UDim2.new(0,8,0,22)
    dLbl.BackgroundTransparency=1 dLbl.Text="Steal Duration" dLbl.TextColor3=C.textMid
    dLbl.Font=Enum.Font.GothamSemibold dLbl.TextSize=11 dLbl.TextXAlignment=Enum.TextXAlignment.Left dLbl.ZIndex=6 dLbl.Parent=panel
    local dBox=Instance.new("TextBox")
    dBox.Size=UDim2.new(0,70,0,24) dBox.Position=UDim2.new(1,-80,0,22)
    dBox.BackgroundColor3=C.bg dBox.BorderSizePixel=0 dBox.Text=tostring(Values.STEAL_DURATION)
    dBox.TextColor3=C.text dBox.Font=Enum.Font.GothamBold dBox.TextSize=11 dBox.ClearTextOnFocus=false dBox.ZIndex=6 dBox.Parent=panel
    Instance.new("UICorner",dBox).CornerRadius=UDim.new(0,4)
    local dS=Instance.new("UIStroke") dS.Color=Color3.fromRGB(160,80,220) dS.Thickness=1 dS.Parent=dBox
    dBox:GetPropertyChangedSignal("Text"):Connect(function()
        local v=tonumber(dBox.Text) if v then Values.STEAL_DURATION=math.max(0.01,v) end
    end)

    local rLbl=Instance.new("TextLabel")
    rLbl.Size=UDim2.new(0,110,0,24) rLbl.Position=UDim2.new(0,8,0,54)
    rLbl.BackgroundTransparency=1 rLbl.Text="Radius" rLbl.TextColor3=C.textMid
    rLbl.Font=Enum.Font.GothamSemibold rLbl.TextSize=11 rLbl.TextXAlignment=Enum.TextXAlignment.Left rLbl.ZIndex=6 rLbl.Parent=panel
    RadiusInputRef=Instance.new("TextBox")
    RadiusInputRef.Size=UDim2.new(0,70,0,24) RadiusInputRef.Position=UDim2.new(1,-80,0,54)
    RadiusInputRef.BackgroundColor3=C.bg RadiusInputRef.BorderSizePixel=0 RadiusInputRef.Text=tostring(Values.STEAL_RADIUS)
    RadiusInputRef.TextColor3=C.text RadiusInputRef.Font=Enum.Font.GothamBold RadiusInputRef.TextSize=11
    RadiusInputRef.ClearTextOnFocus=false RadiusInputRef.ZIndex=6 RadiusInputRef.Parent=panel
    Instance.new("UICorner",RadiusInputRef).CornerRadius=UDim.new(0,4)
    local rS=Instance.new("UIStroke") rS.Color=Color3.fromRGB(160,80,220) rS.Thickness=1 rS.Parent=RadiusInputRef
    RadiusInputRef.FocusLost:Connect(function()
        local n=tonumber(RadiusInputRef.Text)
        if n then Values.STEAL_RADIUS=math.clamp(math.floor(n),5,200) RadiusInputRef.Text=tostring(Values.STEAL_RADIUS)
        else RadiusInputRef.Text=tostring(Values.STEAL_RADIUS) end
    end)
end)
stealPanelToggle=stealPanelToggleFinal

createToggle("Anti Ragdoll","AntiRagdoll",function(state)
    if state then startAntiRagdoll() else stopAntiRagdoll() end
end)
createToggle("Counter Medusa","CounterMedusa",function(state)
    if state then startCounterMedusa() else stopCounterMedusa() end
end)
createToggle("Auto TP","AutoTP",function(state)
    if state then startAutoTP() tpWindow.Visible=true else stopAutoTP() tpWindow.Visible=false end
end)

if Enabled.AutoTP then task.defer(function() tpWindow.Visible=true end) end

-- ============================================================
-- // DROP BRAINROTS BUTTON in main GUI //
-- ============================================================
createActionButton("Drop Brainrots", "DROP", function()
    task.spawn(doDropBrainrots)
end)


addDivider()
createCategoryHeader("MOVEMENT")

createToggle("Auto Left","AutoLeftEnabled",function(state)
    if state then
        stopAllAutoMoves("AutoLeftEnabled")
        AutoLeftEnabled=true Enabled.AutoLeftEnabled=true
        if VisualSetters.AutoLeftEnabled then VisualSetters.AutoLeftEnabled(true,true) end
        startAutoLeft()
        if syncMobileBtn then syncMobileBtn("M_AutoLeft", true) end
    else
        AutoLeftEnabled=false Enabled.AutoLeftEnabled=false
        stopAutoLeft()
        if syncMobileBtn then syncMobileBtn("M_AutoLeft", false) end
    end
end,true,autoLeftKey)

createToggle("Auto Right","AutoRightEnabled",function(state)
    if state then
        stopAllAutoMoves("AutoRightEnabled")
        AutoRightEnabled=true Enabled.AutoRightEnabled=true
        if VisualSetters.AutoRightEnabled then VisualSetters.AutoRightEnabled(true,true) end
        startAutoRight()
        if syncMobileBtn then syncMobileBtn("M_AutoRight", true) end
    else
        AutoRightEnabled=false Enabled.AutoRightEnabled=false
        stopAutoRight()
        if syncMobileBtn then syncMobileBtn("M_AutoRight", false) end
    end
end,true,autoRightKey)

createToggle("Auto Right Play","AutoRightPlayEnabled",function(state)
    if state then
        stopAllAutoMoves("AutoRightPlayEnabled")
        AutoRightPlayEnabled=true Enabled.AutoRightPlayEnabled=true
        if VisualSetters.AutoRightPlayEnabled then VisualSetters.AutoRightPlayEnabled(true,true) end
        startAutoRightPlay()
        if syncMobileBtn then syncMobileBtn("M_AutoRightPlay", true) end
    else
        AutoRightPlayEnabled=false Enabled.AutoRightPlayEnabled=false
        stopAutoRightPlay()
        if syncMobileBtn then syncMobileBtn("M_AutoRightPlay", false) end
    end
end,true,autoRightPlayKey)

createToggle("Auto Left Play","AutoLeftPlayEnabled",function(state)
    if state then
        stopAllAutoMoves("AutoLeftPlayEnabled")
        AutoLeftPlayEnabled=true Enabled.AutoLeftPlayEnabled=true
        if VisualSetters.AutoLeftPlayEnabled then VisualSetters.AutoLeftPlayEnabled(true,true) end
        startAutoLeftPlay()
        if syncMobileBtn then syncMobileBtn("M_AutoLeftPlay", true) end
    else
        AutoLeftPlayEnabled=false Enabled.AutoLeftPlayEnabled=false
        stopAutoLeftPlay()
        if syncMobileBtn then syncMobileBtn("M_AutoLeftPlay", false) end
    end
end,true,autoLeftPlayKey)

createToggle("Aimbot (Bat)","BatAimbot",function(state)
    if state then
        stopAllAutoMoves("BatAimbot")
        Enabled.BatAimbot=true autoBatToggled=true
        if VisualSetters.BatAimbot then VisualSetters.BatAimbot(true,true) end
        startBatAimbot()
        if syncMobileBtn then syncMobileBtn("M_Aimbot", true) end
    else
        Enabled.BatAimbot=false autoBatToggled=false
        stopBatAimbot()
        if syncMobileBtn then syncMobileBtn("M_Aimbot", false) end
    end
end,true,autoBatKey)
if _G.AimbotKeybindBtn then
    hookBtn(_G.AimbotKeybindBtn, function()
        waitingForKeybind=_G.AimbotKeybindBtn waitingForKeybindType="AutoBat" _G.AimbotKeybindBtn.Text="..."
    end)
end

local galaxyPanelToggle
createToggle("Galaxy Mode","Galaxy",function(state)
    if state then startGalaxy() else stopGalaxy() end
end,true,galaxyKey,function()
    if galaxyPanelToggle then galaxyPanelToggle() end
end)

local _,galaxyPanelToggleFinal=createSubPanel(210,function(panel)
    local hint=Instance.new("TextLabel")
    hint.Size=UDim2.new(1,-16,0,12) hint.Position=UDim2.new(0,8,0,4)
    hint.BackgroundTransparency=1 hint.Text="Controller B to close"
    hint.TextColor3=Color3.fromRGB(180, 180, 180) hint.Font=Enum.Font.GothamBold hint.TextSize=8
    hint.TextXAlignment=Enum.TextXAlignment.Left hint.ZIndex=6 hint.Parent=panel

    local function makeRow(labelTxt, yOffset, defaultVal, minVal, maxVal, onChange)
        local lbl=Instance.new("TextLabel")
        lbl.Size=UDim2.new(0,130,0,22) lbl.Position=UDim2.new(0,8,0,yOffset)
        lbl.BackgroundTransparency=1 lbl.Text=labelTxt lbl.TextColor3=C.textMid
        lbl.Font=Enum.Font.GothamSemibold lbl.TextSize=10 lbl.TextXAlignment=Enum.TextXAlignment.Left
        lbl.ZIndex=6 lbl.Parent=panel
        local box=Instance.new("TextBox")
        box.Size=UDim2.new(0,68,0,22) box.Position=UDim2.new(1,-78,0,yOffset)
        box.BackgroundColor3=C.bg box.BorderSizePixel=0 box.Text=tostring(defaultVal)
        box.TextColor3=C.text box.Font=Enum.Font.GothamBold box.TextSize=10
        box.ClearTextOnFocus=false box.ZIndex=6 box.Parent=panel
        Instance.new("UICorner",box).CornerRadius=UDim.new(0,4)
        local s=Instance.new("UIStroke") s.Color=Color3.fromRGB(160,80,220) s.Thickness=1 s.Parent=box
        box:GetPropertyChangedSignal("Text"):Connect(function()
            local v=tonumber(box.Text)
            if v then
                if minVal then v=math.max(minVal,v) end
                if maxVal then v=math.min(maxVal,v) end
                onChange(v)
            end
        end)
        return box
    end

    -- Gravity %
    makeRow("Gravity %  (1-200)", 20, Values.GalaxyGravityPercent, 1, 200, function(v)
        Values.GalaxyGravityPercent=v
        if galaxyEnabled then updateGalaxyForce() adjustGalaxyJump() end
    end)

    -- Hop Power
    makeRow("Hop Power", 50, Values.HOP_POWER, 1, 500, function(v)
        Values.HOP_POWER=v
    end)

    -- Hop Cooldown
    makeRow("Hop Cooldown (s)", 80, Values.HOP_COOLDOWN, 0.01, 2, function(v)
        Values.HOP_COOLDOWN=v
    end)

    -- Jump Override toggle
    local jOvrLbl=Instance.new("TextLabel")
    jOvrLbl.Size=UDim2.new(0,130,0,22) jOvrLbl.Position=UDim2.new(0,8,0,110)
    jOvrLbl.BackgroundTransparency=1 jOvrLbl.Text="Custom Jump Power"
    jOvrLbl.TextColor3=C.textMid jOvrLbl.Font=Enum.Font.GothamSemibold jOvrLbl.TextSize=10
    jOvrLbl.TextXAlignment=Enum.TextXAlignment.Left jOvrLbl.ZIndex=6 jOvrLbl.Parent=panel

    local jOvrBg=Instance.new("Frame")
    jOvrBg.Size=UDim2.new(0,32,0,16) jOvrBg.Position=UDim2.new(1,-78,0,113)
    jOvrBg.BackgroundColor3=Values.GalaxyJumpOverride and C.toggleOn or C.toggleOff
    jOvrBg.BorderSizePixel=0 jOvrBg.ZIndex=6 jOvrBg.Parent=panel
    Instance.new("UICorner",jOvrBg).CornerRadius=UDim.new(1,0)
    local jOvrStroke=Instance.new("UIStroke") jOvrStroke.Color=Color3.fromRGB(160,80,220) jOvrStroke.Thickness=1 jOvrStroke.Parent=jOvrBg

    local jOvrCirc=Instance.new("Frame")
    jOvrCirc.Size=UDim2.new(0,12,0,12)
    jOvrCirc.Position=Values.GalaxyJumpOverride and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,2,0.5,-6)
    jOvrCirc.BackgroundColor3=Values.GalaxyJumpOverride and C.circleOn or C.circleOff
    jOvrCirc.BorderSizePixel=0 jOvrCirc.ZIndex=7 jOvrCirc.Parent=jOvrBg
    Instance.new("UICorner",jOvrCirc).CornerRadius=UDim.new(1,0)

    local jOvrBtn=Instance.new("TextButton")
    jOvrBtn.Size=UDim2.new(1,0,1,0) jOvrBtn.BackgroundTransparency=1 jOvrBtn.Text="" jOvrBtn.ZIndex=8 jOvrBtn.Parent=jOvrBg

    hookBtn(jOvrBtn, function()
        Values.GalaxyJumpOverride=not Values.GalaxyJumpOverride
        TweenService:Create(jOvrBg,TweenInfo.new(0.2),{BackgroundColor3=Values.GalaxyJumpOverride and C.toggleOn or C.toggleOff}):Play()
        TweenService:Create(jOvrCirc,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{
            Position=Values.GalaxyJumpOverride and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,2,0.5,-6),
            BackgroundColor3=Values.GalaxyJumpOverride and C.circleOn or C.circleOff
        }):Play()
        if galaxyEnabled then adjustGalaxyJump() end
    end)

    -- Jump Power value (only meaningful when override is on)
    makeRow("Jump Power Value", 140, Values.GalaxyJumpPower, 1, 500, function(v)
        Values.GalaxyJumpPower=v
        if galaxyEnabled and Values.GalaxyJumpOverride then adjustGalaxyJump() end
    end)

    -- Gravity strength label (live display)
    local gravInfoLbl=Instance.new("TextLabel")
    gravInfoLbl.Size=UDim2.new(1,-16,0,20) gravInfoLbl.Position=UDim2.new(0,8,0,172)
    gravInfoLbl.BackgroundTransparency=1
    gravInfoLbl.Text=string.format("Effective gravity: %.1f studs/s²", Values.DEFAULT_GRAVITY*(Values.GalaxyGravityPercent/100))
    gravInfoLbl.TextColor3=Color3.fromRGB(160,80,220) gravInfoLbl.Font=Enum.Font.GothamBold gravInfoLbl.TextSize=8
    gravInfoLbl.TextXAlignment=Enum.TextXAlignment.Left gravInfoLbl.ZIndex=6 gravInfoLbl.Parent=panel

    -- Update live label whenever gravity changes
    RunService.Heartbeat:Connect(function()
        if panel.Visible then
            gravInfoLbl.Text=string.format("Effective gravity: %.1f studs/s²", Values.DEFAULT_GRAVITY*(Values.GalaxyGravityPercent/100))
        end
    end)
end)
galaxyPanelToggle=galaxyPanelToggleFinal

createToggle("Float","FloatEnabled",function(state)
    if state then startFloat() else stopFloat() end
end)

do
    local lRow=Instance.new("Frame")
    lRow.Size=UDim2.new(1,-24,0,20) lRow.Position=UDim2.new(0,12,0,yPos)
    lRow.BackgroundTransparency=1 lRow.ZIndex=5 lRow.Parent=content

    local slLbl=Instance.new("TextLabel")
    slLbl.Size=UDim2.new(0.6,0,1,0) slLbl.BackgroundTransparency=1 slLbl.Text="Float Height"
    slLbl.TextColor3=C.textDim slLbl.Font=Enum.Font.GothamSemibold slLbl.TextSize=11
    slLbl.TextXAlignment=Enum.TextXAlignment.Left slLbl.ZIndex=5 slLbl.Parent=lRow

    local slVal=Instance.new("TextLabel")
    slVal.Size=UDim2.new(0.4,0,1,0) slVal.Position=UDim2.new(0.6,0,0,0) slVal.BackgroundTransparency=1
    slVal.Text=tostring(FLOAT_HEIGHT).." st" slVal.TextColor3=C.textDim slVal.Font=Enum.Font.GothamBold
    slVal.TextSize=11 slVal.TextXAlignment=Enum.TextXAlignment.Right slVal.ZIndex=5 slVal.Parent=lRow
    yPos=yPos+22

    local track=Instance.new("Frame")
    track.Size=UDim2.new(1,-24,0,6) track.Position=UDim2.new(0,12,0,yPos)
    track.BackgroundColor3=Color3.fromRGB(150, 95, 200) track.BorderSizePixel=0 track.ZIndex=5 track.Parent=content
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)

    local fill=Instance.new("Frame")
    fill.Size=UDim2.new(math.clamp((FLOAT_HEIGHT-1)/19,0,1),0,1,0)
    fill.BackgroundColor3=C.accent fill.BorderSizePixel=0 fill.ZIndex=5 fill.Parent=track
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)

    local knob=Instance.new("Frame")
    knob.Size=UDim2.new(0,14,0,14)
    knob.Position=UDim2.new(math.clamp((FLOAT_HEIGHT-1)/19,0,1),-7,0.5,-7)
    knob.BackgroundColor3=Color3.fromRGB(160,80,220) knob.BorderSizePixel=0 knob.ZIndex=6 knob.Parent=track
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)

    local hitbox=Instance.new("TextButton")
    hitbox.Size=UDim2.new(1,14,1,14) hitbox.Position=UDim2.new(0,-7,0,-7)
    hitbox.BackgroundTransparency=1 hitbox.Text="" hitbox.ZIndex=7 hitbox.Parent=track

    local isDragging=false
    local floatPct = math.clamp((FLOAT_HEIGHT-1)/19,0,1)
    local function updateSlider(ix)
        local ap=track.AbsolutePosition.X
        local as=track.AbsoluteSize.X
        local pct=math.clamp((ix-ap)/as,0,1)
        floatPct=pct
        FLOAT_HEIGHT=math.floor(1+pct*19)
        fill.Size=UDim2.new(pct,0,1,0) knob.Position=UDim2.new(pct,-7,0.5,-7)
        slVal.Text=tostring(FLOAT_HEIGHT).." st" updateFloatHeight()
    end
    hitbox.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then isDragging=true end end)
    hitbox.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch then isDragging=true updateSlider(i.Position.X) end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if isDragging and i.UserInputType==Enum.UserInputType.Touch then updateSlider(i.Position.X) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch then isDragging=false end
    end)
    registerSlider(track, updateSlider, function() return floatPct end, hitbox)
    yPos=yPos+14
end

addDivider()
createCategoryHeader("SPEED")

do
    local ROW_H=26
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,-24,0,ROW_H) row.Position=UDim2.new(0,12,0,yPos)
    row.BackgroundTransparency=1 row.ZIndex=5 row.Parent=content

    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(0.55,0,1,0) lbl.BackgroundTransparency=1 lbl.Text="Speed Mode"
    lbl.TextColor3=C.textMid lbl.Font=Enum.Font.GothamSemibold lbl.TextSize=9
    lbl.TextXAlignment=Enum.TextXAlignment.Left lbl.ZIndex=5 lbl.Parent=row

    local speedBtn=Instance.new("TextButton")
    speedBtn.Size=UDim2.new(0,72,0,20) speedBtn.Position=UDim2.new(1,-72,0.5,-10)
    speedBtn.BackgroundColor3=C.btnBg speedBtn.BorderSizePixel=0
    speedBtn.Text="Normal" speedBtn.TextColor3=C.text
    speedBtn.Font=Enum.Font.GothamBold speedBtn.TextSize=9
    speedBtn.ZIndex=6 speedBtn.Parent=row
    Instance.new("UICorner",speedBtn).CornerRadius=UDim.new(0,5)
    local sBtnStroke=Instance.new("UIStroke")
    sBtnStroke.Color=Color3.fromRGB(160,80,220) sBtnStroke.Thickness=1 sBtnStroke.Parent=speedBtn

    modeLabel=Instance.new("TextLabel")  -- keep modeLabel for compat
    modeLabel.Size=UDim2.new(0,0,0,0) modeLabel.BackgroundTransparency=1
    modeLabel.Text="Mode: Normal" modeLabel.ZIndex=1 modeLabel.Parent=row  -- hidden, zero size

    local function updateSpeedBtn()
        if speedToggled then
            speedBtn.Text="Carry"
            speedBtn.BackgroundColor3=Color3.fromRGB(35,15,55)
            sBtnStroke.Color=Color3.fromRGB(200,120,255)
        else
            speedBtn.Text="Normal"
            speedBtn.BackgroundColor3=C.btnBg
            sBtnStroke.Color=Color3.fromRGB(160,80,220)
        end
        syncMobileBtn("M_Speed", speedToggled)
    end

    speedBtn.Activated:Connect(function()
        speedToggled=not speedToggled
        modeLabel.Text=speedToggled and "Mode: Carry" or "Mode: Normal"
        updateSpeedBtn()
    end)
    speedBtn.InputBegan:Connect(function(i)
        if i.KeyCode==Enum.KeyCode.ButtonA then
            speedToggled=not speedToggled
            modeLabel.Text=speedToggled and "Mode: Carry" or "Mode: Normal"
            updateSpeedBtn()
        end
    end)

    yPos=yPos+ROW_H+4
end

local normalBox=createInputRow("Normal Speed",NORMAL_SPEED)
local carryBox=createInputRow("Carry Speed",CARRY_SPEED)

addDivider()
createCategoryHeader("CONTROLLER CONFIG")

local keyBtnAutoLeft=makeKeyRow("Auto Left",autoLeftKey.Name)
local keyBtnAutoRight=makeKeyRow("Auto Right",autoRightKey.Name)
local keyBtnAutoLeftPlay=makeKeyRow("Auto Left Play",autoLeftPlayKey.Name)
local keyBtnAutoRightPlay=makeKeyRow("Auto Right Play",autoRightPlayKey.Name)
local keyBtnAimbot=makeKeyRow("Aimbot",autoBatKey.Name)
local keyBtnSpeed=makeKeyRow("Speed Toggle",speedToggleKey.Name)
local keyBtnGUI=makeKeyRow("GUI Toggle",guiToggleKey.Name)
local keyBtnFloat=makeKeyRow("Float",floatKey.Name)
local keyBtnGalaxy=makeKeyRow("Galaxy",galaxyKey.Name)
local keyBtnTPDown=makeKeyRow("TP Down",tpDownKey.Name)

local function hookKeybindBtn(btn, keybindType)
    local function activate()
        btn.Text="..." waitingForKeybind=btn waitingForKeybindType=keybindType
    end
    btn.Activated:Connect(activate)
    btn.InputBegan:Connect(function(i)
        if i.KeyCode==Enum.KeyCode.ButtonA then activate() end
    end)
end

hookKeybindBtn(keyBtnAutoLeft,    "AutoLeft")
hookKeybindBtn(keyBtnAutoRight,   "AutoRight")
hookKeybindBtn(keyBtnAutoLeftPlay,"AutoLeftPlay")
hookKeybindBtn(keyBtnAutoRightPlay,"AutoRightPlay")
hookKeybindBtn(keyBtnAimbot,      "AutoBat")
hookKeybindBtn(keyBtnSpeed,       "SpeedToggle")
hookKeybindBtn(keyBtnGUI,         "GUIToggle")
hookKeybindBtn(keyBtnFloat,       "Float")
hookKeybindBtn(keyBtnGalaxy,      "Galaxy")
hookKeybindBtn(keyBtnTPDown,      "TPDown")

addDivider()

do
    local lRow=Instance.new("Frame")
    lRow.Size=UDim2.new(1,-24,0,20) lRow.Position=UDim2.new(0,12,0,yPos)
    lRow.BackgroundTransparency=1 lRow.ZIndex=5 lRow.Parent=content

    local tlLbl=Instance.new("TextLabel")
    tlLbl.Size=UDim2.new(0.6,0,1,0) tlLbl.BackgroundTransparency=1 tlLbl.Text="UI Transparency"
    tlLbl.TextColor3=C.textDim tlLbl.Font=Enum.Font.GothamSemibold tlLbl.TextSize=11
    tlLbl.TextXAlignment=Enum.TextXAlignment.Left tlLbl.ZIndex=5 tlLbl.Parent=lRow

    local tlVal=Instance.new("TextLabel")
    tlVal.Size=UDim2.new(0.4,0,1,0) tlVal.Position=UDim2.new(0.6,0,0,0) tlVal.BackgroundTransparency=1
    tlVal.Text="0%" tlVal.TextColor3=C.textDim tlVal.Font=Enum.Font.GothamBold
    tlVal.TextSize=11 tlVal.TextXAlignment=Enum.TextXAlignment.Right tlVal.ZIndex=5 tlVal.Parent=lRow
    yPos=yPos+22

    local tTrack=Instance.new("Frame")
    tTrack.Size=UDim2.new(1,-24,0,6) tTrack.Position=UDim2.new(0,12,0,yPos)
    tTrack.BackgroundColor3=Color3.fromRGB(150, 95, 200) tTrack.BorderSizePixel=0 tTrack.ZIndex=5 tTrack.Parent=content
    Instance.new("UICorner",tTrack).CornerRadius=UDim.new(1,0)

    local tFill=Instance.new("Frame")
    tFill.Size=UDim2.new(0,0,1,0) tFill.BackgroundColor3=C.accent tFill.BorderSizePixel=0 tFill.ZIndex=5 tFill.Parent=tTrack
    Instance.new("UICorner",tFill).CornerRadius=UDim.new(1,0)

    local tKnob=Instance.new("Frame")
    tKnob.Size=UDim2.new(0,14,0,14) tKnob.Position=UDim2.new(0,-7,0.5,-7)
    tKnob.BackgroundColor3=Color3.fromRGB(160,80,220) tKnob.BorderSizePixel=0 tKnob.ZIndex=6 tKnob.Parent=tTrack
    Instance.new("UICorner",tKnob).CornerRadius=UDim.new(1,0)

    local tHitbox=Instance.new("TextButton")
    tHitbox.Size=UDim2.new(1,14,1,14) tHitbox.Position=UDim2.new(0,-7,0,-7)
    tHitbox.BackgroundTransparency=1 tHitbox.Text="" tHitbox.ZIndex=7 tHitbox.Parent=tTrack

    local isTDragging=false
    local transPct = 0
    local function updateTrans(ix)
        local ap=tTrack.AbsolutePosition.X
        local as=tTrack.AbsoluteSize.X
        local pct=math.clamp((ix-ap)/as,0,1)
        transPct=pct
        currentTransparency=pct
        tFill.Size=UDim2.new(pct,0,1,0) tKnob.Position=UDim2.new(pct,-7,0.5,-7)
        main.BackgroundTransparency=pct tpWindow.BackgroundTransparency=pct
        tlVal.Text=math.floor(pct*100).."%"
    end
    tHitbox.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then isTDragging=true end end)
    tHitbox.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch then isTDragging=true updateTrans(i.Position.X) end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if isTDragging and i.UserInputType==Enum.UserInputType.Touch then updateTrans(i.Position.X) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch then isTDragging=false end
    end)
    registerSlider(tTrack, updateTrans, function() return transPct end, tHitbox)
    yPos=yPos+14

    if currentTransparency > 0 then
        tFill.Size=UDim2.new(currentTransparency,0,1,0)
        tKnob.Position=UDim2.new(currentTransparency,-7,0.5,-7)
        main.BackgroundTransparency=currentTransparency
        tpWindow.BackgroundTransparency=currentTransparency
        tlVal.Text=math.floor(currentTransparency*100).."%"
    end
end

yPos=yPos+8

do
    local ROW_H=26
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,-24,0,ROW_H) row.Position=UDim2.new(0,12,0,yPos)
    row.BackgroundTransparency=1 row.ZIndex=5 row.Parent=content

    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(0.6,0,1,0) lbl.BackgroundTransparency=1 lbl.Text="UI Scale"
    lbl.TextColor3=C.textMid lbl.Font=Enum.Font.GothamSemibold lbl.TextSize=9
    lbl.TextXAlignment=Enum.TextXAlignment.Left lbl.ZIndex=5 lbl.Parent=row

    local box=Instance.new("TextBox")
    box.Size=UDim2.new(0,58,0,18) box.Position=UDim2.new(1,-58,0.5,-9)
    box.BackgroundColor3=C.btnBg box.BorderSizePixel=0
    box.Text=tostring(uiScaleValue) box.TextColor3=C.text
    box.Font=Enum.Font.GothamBold box.TextSize=9
    box.ClearTextOnFocus=false box.ZIndex=5 box.Parent=row
    Instance.new("UICorner",box).CornerRadius=UDim.new(0,5)
    local bStroke=Instance.new("UIStroke")
    bStroke.Color=Color3.fromRGB(160,80,220) bStroke.Thickness=1 bStroke.Parent=box

    box.FocusLost:Connect(function()
        local v=tonumber(box.Text)
        if v then
            v=math.clamp(v, 0.5, 2.0)
            uiScaleValue=v
            box.Text=string.format("%.2f",v)
            local uiScale=gui:FindFirstChildOfClass("UIScale")
            if not uiScale then uiScale=Instance.new("UIScale",gui) end
            uiScale.Scale=v
        else
            box.Text=tostring(uiScaleValue)
        end
    end)

    yPos=yPos+ROW_H+2
end

yPos=yPos+8

addDivider()
createCategoryHeader("MOBILE")

-- Hide/Show mobile buttons
local mobileButtonsVisible = true
createActionButton("Mobile Buttons", "Hide", function()
    mobileButtonsVisible = not mobileButtonsVisible
    -- Update the button label via the ref stored by createActionButton
    for _, ref in pairs(mbRefs) do
        if ref and ref.btn then ref.btn.Visible = mobileButtonsVisible end
    end
    if ProgressBarContainer then ProgressBarContainer.Visible = mobileButtonsVisible end
end)

-- Reset mobile button positions
createActionButton("Reset Positions", "Reset", function()
    local _RB_W=90 local _RB_H=30 local _BTN_GAP=6 local _NUM_BTNS=11
    local _totalH = _NUM_BTNS * _RB_H + (_NUM_BTNS - 1) * _BTN_GAP
    local order = {"M_Aimbot","M_Float","M_AutoRight","M_AutoLeft","M_AutoRightPlay","M_AutoLeftPlay","M_DropBrainrots","M_AutoSteal","M_Speed","M_TPDown","M_CounterMedusa"}
    for name, ref in pairs(mbRefs) do
        if ref and ref.btn and ref.btn.Parent then
            local idx = 0
            for i, n in ipairs(order) do if n == name then idx = i break end end
            if idx > 0 then
                local defaultYOffset = -math.floor(_totalH / 2) + (idx - 1) * (_RB_H + _BTN_GAP)
                ref.btn.Position = UDim2.new(1, -(_RB_W + 8), 0.5, defaultYOffset)
            end
        end
    end
    if ProgressBarContainer and ProgressBarContainer.Parent then
        ProgressBarContainer.Position = UDim2.new(0.5, -110, 1, -50)
    end
    savedBtnPositions = {}
end)

local saveBtn=Instance.new("TextButton")
saveBtn.Size=UDim2.new(1,-24,0,32) saveBtn.Position=UDim2.new(0,12,0,yPos)
saveBtn.BackgroundColor3=Color3.fromRGB(60,40,90) saveBtn.BorderSizePixel=0
saveBtn.Text="Save Config" saveBtn.TextColor3=C.text
saveBtn.Font=Enum.Font.GothamBold saveBtn.TextSize=13
saveBtn.ZIndex=5 saveBtn.Parent=content
Instance.new("UICorner",saveBtn).CornerRadius=UDim.new(0,6)
autoSaveLabel=Instance.new("TextLabel")
autoSaveLabel.Size=UDim2.new(1,-24,0,18) autoSaveLabel.Position=UDim2.new(0,12,0,yPos+34)
autoSaveLabel.BackgroundTransparency=1 autoSaveLabel.Text=""
autoSaveLabel.TextColor3=Color3.fromRGB(180,180,180)
autoSaveLabel.Font=Enum.Font.GothamBold autoSaveLabel.TextSize=10
autoSaveLabel.TextXAlignment=Enum.TextXAlignment.Center autoSaveLabel.ZIndex=5 autoSaveLabel.Parent=content
hookBtn(saveBtn, function()
    local ok=saveConfig()
    if ok then
        autoSaveLabel.Text="Saved!" autoSaveLabel.TextColor3=C.success
        saveBtn.BackgroundColor3=Color3.fromRGB(30,80,40)
    else
        autoSaveLabel.Text="Save failed" autoSaveLabel.TextColor3=C.danger
        saveBtn.BackgroundColor3=Color3.fromRGB(90,20,20)
    end
    task.delay(2,function()
        if autoSaveLabel and autoSaveLabel.Parent then
            autoSaveLabel.Text="" autoSaveLabel.TextColor3=Color3.fromRGB(180,180,180)
        end
        if saveBtn and saveBtn.Parent then
            saveBtn.BackgroundColor3=Color3.fromRGB(60,40,90)
        end
    end)
end)
yPos=yPos+56

content.CanvasSize=UDim2.new(0,0,0,yPos)

-- uiLocked controls whether all draggable UI elements can be moved
-- (declared early at top of script so saveConfig can reference it safely)

-- ===== STEAL PROGRESS BAR =====
local BAR_W=220
local BAR_H=24

ProgressBarContainer=Instance.new("Frame")
ProgressBarContainer.Name="N5DuelsStealBar"
ProgressBarContainer.Size=UDim2.new(0,BAR_W,0,BAR_H)
ProgressBarContainer.Position=UDim2.new(0.5,-BAR_W/2,1,-50)
ProgressBarContainer.BackgroundColor3=C.bg
ProgressBarContainer.BackgroundTransparency=0
ProgressBarContainer.BorderSizePixel=0
ProgressBarContainer.ClipsDescendants=false
ProgressBarContainer.Active=true
ProgressBarContainer.Draggable=false
ProgressBarContainer.ZIndex=10
ProgressBarContainer.Parent=gui
Instance.new("UICorner",ProgressBarContainer).CornerRadius=UDim.new(0,5)

local pbStroke=Instance.new("UIStroke")
pbStroke.Color=Color3.fromRGB(160,80,220)
pbStroke.Thickness=1.5
pbStroke.Parent=ProgressBarContainer

barPctLabel=Instance.new("TextLabel")
barPctLabel.Name="PctLabel"
barPctLabel.Size=UDim2.new(0.5,0,0,14) barPctLabel.Position=UDim2.new(0,6,0,0)
barPctLabel.BackgroundTransparency=1 barPctLabel.Text="0%"
barPctLabel.TextColor3=C.text barPctLabel.Font=Enum.Font.GothamBold barPctLabel.TextSize=8
barPctLabel.TextXAlignment=Enum.TextXAlignment.Left barPctLabel.TextYAlignment=Enum.TextYAlignment.Center
barPctLabel.ZIndex=13 barPctLabel.Parent=ProgressBarContainer

barRadiusLabel=Instance.new("TextLabel")
barRadiusLabel.Name="RadiusLabel"
barRadiusLabel.Size=UDim2.new(0.5,-6,0,14) barRadiusLabel.Position=UDim2.new(0.5,0,0,0)
barRadiusLabel.BackgroundTransparency=1 barRadiusLabel.Text="Radius: "..tostring(Values.STEAL_RADIUS)
barRadiusLabel.TextColor3=C.textDim barRadiusLabel.Font=Enum.Font.GothamBold barRadiusLabel.TextSize=8
barRadiusLabel.TextXAlignment=Enum.TextXAlignment.Right barRadiusLabel.TextYAlignment=Enum.TextYAlignment.Center
barRadiusLabel.ZIndex=13 barRadiusLabel.Parent=ProgressBarContainer

local barTrack=Instance.new("Frame")
barTrack.Name="Track" barTrack.Size=UDim2.new(1,-12,0,8) barTrack.Position=UDim2.new(0,6,0,14)
barTrack.BackgroundColor3=Color3.fromRGB(150, 95, 200) barTrack.BorderSizePixel=0 barTrack.ClipsDescendants=true
barTrack.ZIndex=11 barTrack.Parent=ProgressBarContainer
Instance.new("UICorner",barTrack).CornerRadius=UDim.new(0,4)

ProgressBarFill=Instance.new("Frame")
ProgressBarFill.Name="Fill" ProgressBarFill.Size=UDim2.new(0,0,1,0) ProgressBarFill.Position=UDim2.new(0,0,0,0)
ProgressBarFill.BackgroundColor3=C.accent ProgressBarFill.BorderSizePixel=0 ProgressBarFill.ZIndex=12 ProgressBarFill.Parent=barTrack
Instance.new("UICorner",ProgressBarFill).CornerRadius=UDim.new(0,4)

-- Manual drag for steal bar (respects uiLocked)
do
    local barDragging = false
    local barDragStart = nil
    local barStartPos = nil
    ProgressBarContainer.InputBegan:Connect(function(inp)
        if uiLocked then return end
        if inp.UserInputType == Enum.UserInputType.Touch then
            barDragging = true
            barDragStart = inp.Position
            barStartPos = ProgressBarContainer.AbsolutePosition
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if barDragging and inp.UserInputType == Enum.UserInputType.Touch then
            local delta = inp.Position - barDragStart
            ProgressBarContainer.Position = UDim2.new(0, math.floor(barStartPos.X + delta.X), 0, math.floor(barStartPos.Y + delta.Y))
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch then
            barDragging = false
        end
    end)
end

-- ============================================================
-- // INDIVIDUAL DRAGGABLE RECTANGLE BUTTONS (right side)
-- ============================================================

-- Stop all auto-move features and sync their UI
-- mbRefs declared early at top of script

-- Button dimensions
local RB_W = 90
local RB_H = 30

-- Colors
local RB_BG_OFF   = Color3.fromRGB(8, 8, 8)
local RB_BG_ON    = Color3.fromRGB(25, 0, 45)
local RB_STROKE   = Color3.fromRGB(160, 80, 220)
local RB_TEXT_ON  = Color3.fromRGB(255, 255, 255)
local RB_TEXT_OFF = Color3.fromRGB(200, 200, 200)
local RB_DOT_ON   = Color3.fromRGB(180, 100, 255)
local RB_DOT_OFF  = Color3.fromRGB(40, 40, 40)

-- Place buttons stacked vertically on the far right, centered vertically
local NUM_BTNS = 11  -- 8 feature buttons + 1 speed toggle + 1 TPDown + 1 CounterMedusa
local BTN_GAP  = 6
local totalH   = NUM_BTNS * RB_H + (NUM_BTNS - 1) * BTN_GAP
local startY   = math.floor((1 - 0) / 2 * 0)  -- computed per-button below

local function makeDragBtn(name, label, index, isToggleBtn, onPress)
    -- Default position: right side, stacked vertically centered
    local defaultX = 1  -- scale 1 = right edge
    local defaultXOffset = -(RB_W + 8)
    local defaultY = 0.5
    local defaultYOffset = -math.floor(totalH / 2) + (index - 1) * (RB_H + BTN_GAP)

    local btn = Instance.new("TextButton", gui)
    btn.Name = name
    btn.Size = UDim2.new(0, RB_W, 0, RB_H)
    btn.Position = UDim2.new(defaultX, defaultXOffset, defaultY, defaultYOffset)
    btn.BackgroundColor3 = RB_BG_OFF
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.ZIndex = 20
    btn.Active = true
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local st = Instance.new("UIStroke", btn)
    st.Color = RB_STROKE
    st.Thickness = 1.2

    -- Label
    local lbl = Instance.new("TextLabel", btn)
    lbl.Size = UDim2.new(1, -14, 1, 0)
    lbl.Position = UDim2.new(0, 7, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = RB_TEXT_OFF
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Center
    lbl.ZIndex = 21

    -- Status dot (right side)
    local dot = Instance.new("Frame", btn)
    dot.Size = UDim2.new(0, 7, 0, 7)
    dot.Position = UDim2.new(1, -13, 0.5, -3)
    dot.BackgroundColor3 = RB_DOT_OFF
    dot.BorderSizePixel = 0
    dot.ZIndex = 21
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    -- Lock indicator strip on left edge (visible when locked)
    local lockBar = Instance.new("Frame", btn)
    lockBar.Size = UDim2.new(0, 3, 1, -6)
    lockBar.Position = UDim2.new(0, 3, 0, 3)
    lockBar.BackgroundColor3 = Color3.fromRGB(160, 80, 220)
    lockBar.BorderSizePixel = 0
    lockBar.BackgroundTransparency = 1  -- hidden by default
    lockBar.ZIndex = 21
    Instance.new("UICorner", lockBar).CornerRadius = UDim.new(1, 0)

    mbRefs[name] = {btn = btn, dot = dot, lbl = lbl, stroke = st, lockBar = lockBar, isOn = false}

    -- Dragging logic
    local dragging = false
    local dragStartInput = nil
    local dragStartPos = nil

    -- Activated fires reliably on tap for non-dragged touches — primary action trigger
    btn.Activated:Connect(function()
        if not dragging then
            if onPress then onPress() end
        end
    end)

    btn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            if not uiLocked then
                dragStartInput = inp.Position
                local abs = btn.AbsolutePosition
                dragStartPos = Vector2.new(abs.X, abs.Y)
            end
        elseif inp.KeyCode == Enum.KeyCode.ButtonA then
            if onPress then onPress() end
        end
    end)

    UserInputService.InputChanged:Connect(function(inp)
        if not uiLocked and dragStartInput and inp.UserInputType == Enum.UserInputType.Touch then
            local delta = inp.Position - dragStartInput
            if delta.Magnitude > 16 then
                dragging = true
                btn.Position = UDim2.new(0, math.floor(dragStartPos.X + delta.X), 0, math.floor(dragStartPos.Y + delta.Y))
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            dragStartInput = nil
        end
    end)

    return btn
end

syncMobileBtn = function(name, state)
    local ref = mbRefs[name]
    if not ref then return end
    ref.isOn = state
    ref.dot.BackgroundColor3 = state and RB_DOT_ON or RB_DOT_OFF
    ref.btn.BackgroundColor3 = state and RB_BG_ON or RB_BG_OFF
    ref.lbl.TextColor3 = state and RB_TEXT_ON or RB_TEXT_OFF
    -- Speed button gets a label swap instead of just color
    if name == "M_Speed" then
        ref.lbl.Text = state and "Carry" or "Normal"
        ref.btn.BackgroundColor3 = state and Color3.fromRGB(35,15,55) or RB_BG_OFF
    end
    TweenService:Create(ref.stroke, TweenInfo.new(0.15), {
        Color = state and Color3.fromRGB(200, 120, 255) or RB_STROKE
    }):Play()
end

local function setAllLockBars(locked)
    for _, ref in pairs(mbRefs) do
        ref.lockBar.BackgroundTransparency = locked and 0 or 1
    end
end

-- N5 show/hide toggle button (top left)
local snakeBtn = Instance.new("TextButton", gui)
snakeBtn.Name = "N5SnakeToggle"
snakeBtn.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
snakeBtn.BorderSizePixel = 0
snakeBtn.Position = UDim2.new(0, 10, 0, 10)
snakeBtn.Size = UDim2.new(0, 70, 0, 44)
snakeBtn.Font = Enum.Font.GothamBlack
snakeBtn.Text = "N5"
snakeBtn.TextColor3 = Color3.fromRGB(180, 100, 255)
snakeBtn.TextSize = 20
snakeBtn.ZIndex = 25
Instance.new("UICorner", snakeBtn).CornerRadius = UDim.new(0, 6)
local snakeStroke = Instance.new("UIStroke", snakeBtn)
snakeStroke.Color = Color3.fromRGB(160, 80, 220)
snakeStroke.Thickness = 2
snakeBtn.Activated:Connect(function()
    main.Visible = not main.Visible
    guiVisible = main.Visible
end)

-- Reset button moved into main GUI under MOBILE category

-- Build all 8 feature buttons
makeDragBtn("M_Aimbot",       "Bat Aimbot",   1, true, function()
    local s = not Enabled.BatAimbot
    if s then
        stopAllAutoMoves("BatAimbot")
        Enabled.BatAimbot=true autoBatToggled=true
        if VisualSetters.BatAimbot then VisualSetters.BatAimbot(true,true) end
        startBatAimbot()
        syncMobileBtn("M_Aimbot", true)
    else
        Enabled.BatAimbot=false autoBatToggled=false
        if VisualSetters.BatAimbot then VisualSetters.BatAimbot(false,true) end
        stopBatAimbot()
        syncMobileBtn("M_Aimbot", false)
    end
end)

makeDragBtn("M_Float",        "Float",        2, true, function()
    floatEnabled = not floatEnabled
    Enabled.FloatEnabled = floatEnabled
    if VisualSetters.FloatEnabled then VisualSetters.FloatEnabled(floatEnabled) end
    if floatEnabled then startFloat() else stopFloat() end
    syncMobileBtn("M_Float", floatEnabled)
end)

makeDragBtn("M_AutoRight",    "Auto Right",   3, true, function()
    local s = not AutoRightEnabled
    if s then
        stopAllAutoMoves("AutoRightEnabled")
        AutoRightEnabled=true Enabled.AutoRightEnabled=true
        if VisualSetters.AutoRightEnabled then VisualSetters.AutoRightEnabled(true,true) end
        startAutoRight()
        syncMobileBtn("M_AutoRight", true)
    else
        AutoRightEnabled=false Enabled.AutoRightEnabled=false
        if VisualSetters.AutoRightEnabled then VisualSetters.AutoRightEnabled(false,true) end
        stopAutoRight()
        syncMobileBtn("M_AutoRight", false)
    end
end)

makeDragBtn("M_AutoLeft",     "Auto Left",    4, true, function()
    local s = not AutoLeftEnabled
    if s then
        stopAllAutoMoves("AutoLeftEnabled")
        AutoLeftEnabled=true Enabled.AutoLeftEnabled=true
        if VisualSetters.AutoLeftEnabled then VisualSetters.AutoLeftEnabled(true,true) end
        startAutoLeft()
        syncMobileBtn("M_AutoLeft", true)
    else
        AutoLeftEnabled=false Enabled.AutoLeftEnabled=false
        if VisualSetters.AutoLeftEnabled then VisualSetters.AutoLeftEnabled(false,true) end
        stopAutoLeft()
        syncMobileBtn("M_AutoLeft", false)
    end
end)

makeDragBtn("M_AutoRightPlay","Auto R.Play",  5, true, function()
    local s = not AutoRightPlayEnabled
    if s then
        stopAllAutoMoves("AutoRightPlayEnabled")
        AutoRightPlayEnabled=true Enabled.AutoRightPlayEnabled=true
        if VisualSetters.AutoRightPlayEnabled then VisualSetters.AutoRightPlayEnabled(true,true) end
        startAutoRightPlay()
        syncMobileBtn("M_AutoRightPlay", true)
    else
        AutoRightPlayEnabled=false Enabled.AutoRightPlayEnabled=false
        if VisualSetters.AutoRightPlayEnabled then VisualSetters.AutoRightPlayEnabled(false,true) end
        stopAutoRightPlay()
        syncMobileBtn("M_AutoRightPlay", false)
    end
end)

makeDragBtn("M_AutoLeftPlay", "Auto L.Play",  6, true, function()
    local s = not AutoLeftPlayEnabled
    if s then
        stopAllAutoMoves("AutoLeftPlayEnabled")
        AutoLeftPlayEnabled=true Enabled.AutoLeftPlayEnabled=true
        if VisualSetters.AutoLeftPlayEnabled then VisualSetters.AutoLeftPlayEnabled(true,true) end
        startAutoLeftPlay()
        syncMobileBtn("M_AutoLeftPlay", true)
    else
        AutoLeftPlayEnabled=false Enabled.AutoLeftPlayEnabled=false
        if VisualSetters.AutoLeftPlayEnabled then VisualSetters.AutoLeftPlayEnabled(false,true) end
        stopAutoLeftPlay()
        syncMobileBtn("M_AutoLeftPlay", false)
    end
end)

makeDragBtn("M_DropBrainrots","Drop Brnrts",  7, false, function()
    task.spawn(doDropBrainrots)
end)

makeDragBtn("M_AutoSteal",    "Auto Steal",   8, true, function()
    local s = not Enabled.AutoSteal
    Enabled.AutoSteal = s
    if VisualSetters.AutoSteal then VisualSetters.AutoSteal(s) end
    if s then startAutoSteal() else stopAutoSteal() end
    syncMobileBtn("M_AutoSteal", s)
end)

makeDragBtn("M_Speed", "Normal", 9, true, function()
    speedToggled = not speedToggled
    modeLabel.Text = speedToggled and "Mode: Carry" or "Mode: Normal"
    local ref = mbRefs["M_Speed"]
    if ref then
        ref.lbl.Text = speedToggled and "Carry" or "Normal"
        ref.btn.BackgroundColor3 = speedToggled and Color3.fromRGB(35,15,55) or RB_BG_OFF
        ref.dot.BackgroundColor3 = speedToggled and RB_DOT_ON or RB_DOT_OFF
    end
end)

-- TP Down button (index 10)
makeDragBtn("M_TPDown", "TP Down", 10, false, function()
    task.spawn(doTPDown)
end)

-- Counter Medusa button (index 11)
makeDragBtn("M_CounterMedusa", "Ctr Medusa", 11, true, function()
    local s = not Enabled.CounterMedusa
    if s then startCounterMedusa() else stopCounterMedusa() end
    syncMobileBtn("M_CounterMedusa", s)
end)

-- Lock/Unlock fixed button directly under the N5 button (not draggable)
local lockFixedBtn = Instance.new("TextButton", gui)
lockFixedBtn.Name = "N5LockBtn"
lockFixedBtn.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
lockFixedBtn.BorderSizePixel = 0
lockFixedBtn.Position = UDim2.new(0, 10, 0, 60)
lockFixedBtn.Size = UDim2.new(0, 70, 0, 28)
lockFixedBtn.Font = Enum.Font.GothamBold
lockFixedBtn.Text = "🔓 Unlock"
lockFixedBtn.TextColor3 = Color3.fromRGB(180, 100, 255)
lockFixedBtn.TextSize = 10
lockFixedBtn.ZIndex = 25
Instance.new("UICorner", lockFixedBtn).CornerRadius = UDim.new(0, 6)
local lockFixedStroke = Instance.new("UIStroke", lockFixedBtn)
lockFixedStroke.Color = Color3.fromRGB(160, 80, 220)
lockFixedStroke.Thickness = 2
lockFixedBtn.Activated:Connect(function()
    uiLocked = not uiLocked
    lockFixedBtn.Text = uiLocked and "🔒 Locked" or "🔓 Unlock"
    lockFixedBtn.BackgroundColor3 = uiLocked and Color3.fromRGB(30, 0, 0) or Color3.fromRGB(8, 8, 8)
    setAllLockBars(uiLocked)
end)


local function setupChar(char)
    h=char:WaitForChild("Humanoid")
    hrp=char:WaitForChild("HumanoidRootPart")
    task.spawn(function()
        pcall(function()
            for _,part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then pcall(part.SetNetworkOwner,part,LocalPlayer) end
            end
            pcall(hrp.SetNetworkOwner,hrp,LocalPlayer)
        end)
    end)
    local head=char:FindFirstChild("Head")
    if head then
        local bb=Instance.new("BillboardGui",head)
        bb.Size=UDim2.new(0,120,0,20) bb.StudsOffset=Vector3.new(0,3,0) bb.AlwaysOnTop=true
        speedLbl=Instance.new("TextLabel",bb)
        speedLbl.Size=UDim2.new(1,0,1,0) speedLbl.BackgroundTransparency=1
        speedLbl.TextColor3=Color3.fromRGB(255, 255, 255) speedLbl.Font=Enum.Font.GothamBold
        speedLbl.TextScaled=true speedLbl.TextStrokeTransparency=0.4
        speedLbl.TextStrokeColor3=Color3.fromRGB(110, 60, 160)
    end
    -- Inf Jump: save jump power and wire forceJump reset
    task.spawn(function()
        task.wait(0.1)
        if h and h.JumpPower > 0 then originalJumpPower = h.JumpPower end
    end)
    if h then
        h:GetPropertyChangedSignal("Jump"):Connect(function()
            if forceJump and not h.Jump then spaceHeld = false forceJump = false end
        end)
    end
end

LocalPlayer.CharacterAdded:Connect(setupChar)
if LocalPlayer.Character then setupChar(LocalPlayer.Character) end

normalBox:GetPropertyChangedSignal("Text"):Connect(function()
    local val=tonumber(normalBox.Text)
    if val then NORMAL_SPEED=val end
end)
carryBox:GetPropertyChangedSignal("Text"):Connect(function()
    local val=tonumber(carryBox.Text)
    if val then CARRY_SPEED=val end
end)

local function refreshAllBadges()
    if _G.AutoLeftKeybindBtn then _G.AutoLeftKeybindBtn.Text=autoLeftKey.Name end
    if _G.AutoRightKeybindBtn then _G.AutoRightKeybindBtn.Text=autoRightKey.Name end
    if _G.AutoLeftPlayKeybindBtn then _G.AutoLeftPlayKeybindBtn.Text=autoLeftPlayKey.Name end
    if _G.AutoRightPlayKeybindBtn then _G.AutoRightPlayKeybindBtn.Text=autoRightPlayKey.Name end
    if _G.AimbotKeybindBtn then _G.AimbotKeybindBtn.Text=autoBatKey.Name end
    if keyBtnAutoLeft then keyBtnAutoLeft.Text=autoLeftKey.Name keyBtnAutoLeft.TextColor3=C.text end
    if keyBtnAutoRight then keyBtnAutoRight.Text=autoRightKey.Name keyBtnAutoRight.TextColor3=C.text end
    if keyBtnAutoLeftPlay then keyBtnAutoLeftPlay.Text=autoLeftPlayKey.Name keyBtnAutoLeftPlay.TextColor3=C.text end
    if keyBtnAutoRightPlay then keyBtnAutoRightPlay.Text=autoRightPlayKey.Name keyBtnAutoRightPlay.TextColor3=C.text end
    if keyBtnAimbot then keyBtnAimbot.Text=autoBatKey.Name keyBtnAimbot.TextColor3=C.text end
    if keyBtnSpeed then keyBtnSpeed.Text=speedToggleKey.Name keyBtnSpeed.TextColor3=C.text end
    if keyBtnGUI then keyBtnGUI.Text=guiToggleKey.Name keyBtnGUI.TextColor3=C.text end
    if keyBtnFloat then keyBtnFloat.Text=floatKey.Name keyBtnFloat.TextColor3=C.text end
    if keyBtnGalaxy then keyBtnGalaxy.Text=galaxyKey.Name keyBtnGalaxy.TextColor3=C.text end
    if keyBtnTPDown then keyBtnTPDown.Text=tpDownKey.Name keyBtnTPDown.TextColor3=C.text end
end

UserInputService.InputBegan:Connect(function(input,gpe)
    if gpe then return end
    if waitingForKeybind and input.KeyCode~=Enum.KeyCode.Unknown then
        local k=input.KeyCode
        if waitingForKeybindType=="AutoLeft" then autoLeftKey=k
        elseif waitingForKeybindType=="AutoRight" then autoRightKey=k
        elseif waitingForKeybindType=="AutoLeftPlay" then autoLeftPlayKey=k
        elseif waitingForKeybindType=="AutoRightPlay" then autoRightPlayKey=k
        elseif waitingForKeybindType=="AutoBat" then autoBatKey=k
        elseif waitingForKeybindType=="SpeedToggle" then speedToggleKey=k
        elseif waitingForKeybindType=="GUIToggle" then guiToggleKey=k
        elseif waitingForKeybindType=="Float" then floatKey=k
        elseif waitingForKeybindType=="Galaxy" then galaxyKey=k
        elseif waitingForKeybindType=="TPDown" then tpDownKey=k end
        waitingForKeybind.TextColor3=C.text
        waitingForKeybind=nil waitingForKeybindType=nil
        refreshAllBadges()
        return
    end
    if input.KeyCode==speedToggleKey then
        speedToggled=not speedToggled
        modeLabel.Text=speedToggled and "Mode: Carry" or "Mode: Normal"
        syncMobileBtn("M_Speed", speedToggled)
    end
    if input.KeyCode==autoBatKey then
        local newState=not Enabled.BatAimbot
        if newState then
            stopAllAutoMoves("BatAimbot")
            Enabled.BatAimbot=true autoBatToggled=true
            if VisualSetters.BatAimbot then VisualSetters.BatAimbot(true,true) end
            startBatAimbot()
            syncMobileBtn("M_Aimbot", true)
        else
            Enabled.BatAimbot=false autoBatToggled=false
            if VisualSetters.BatAimbot then VisualSetters.BatAimbot(false,true) end
            stopBatAimbot()
            syncMobileBtn("M_Aimbot", false)
        end
    end
    if input.KeyCode==autoLeftKey then
        local s=not AutoLeftEnabled
        if s then
            stopAllAutoMoves("AutoLeftEnabled")
            AutoLeftEnabled=true Enabled.AutoLeftEnabled=true
            if VisualSetters.AutoLeftEnabled then VisualSetters.AutoLeftEnabled(true,true) end
            startAutoLeft()
            syncMobileBtn("M_AutoLeft", true)
        else
            AutoLeftEnabled=false Enabled.AutoLeftEnabled=false
            if VisualSetters.AutoLeftEnabled then VisualSetters.AutoLeftEnabled(false,true) end
            stopAutoLeft()
            syncMobileBtn("M_AutoLeft", false)
        end
    end
    if input.KeyCode==autoRightKey then
        local s=not AutoRightEnabled
        if s then
            stopAllAutoMoves("AutoRightEnabled")
            AutoRightEnabled=true Enabled.AutoRightEnabled=true
            if VisualSetters.AutoRightEnabled then VisualSetters.AutoRightEnabled(true,true) end
            startAutoRight()
            syncMobileBtn("M_AutoRight", true)
        else
            AutoRightEnabled=false Enabled.AutoRightEnabled=false
            if VisualSetters.AutoRightEnabled then VisualSetters.AutoRightEnabled(false,true) end
            stopAutoRight()
            syncMobileBtn("M_AutoRight", false)
        end
    end
    if input.KeyCode==autoLeftPlayKey then
        local s=not AutoLeftPlayEnabled
        if s then
            stopAllAutoMoves("AutoLeftPlayEnabled")
            AutoLeftPlayEnabled=true Enabled.AutoLeftPlayEnabled=true
            if VisualSetters.AutoLeftPlayEnabled then VisualSetters.AutoLeftPlayEnabled(true,true) end
            startAutoLeftPlay()
            syncMobileBtn("M_AutoLeftPlay", true)
        else
            AutoLeftPlayEnabled=false Enabled.AutoLeftPlayEnabled=false
            if VisualSetters.AutoLeftPlayEnabled then VisualSetters.AutoLeftPlayEnabled(false,true) end
            stopAutoLeftPlay()
            syncMobileBtn("M_AutoLeftPlay", false)
        end
    end
    if input.KeyCode==autoRightPlayKey then
        local s=not AutoRightPlayEnabled
        if s then
            stopAllAutoMoves("AutoRightPlayEnabled")
            AutoRightPlayEnabled=true Enabled.AutoRightPlayEnabled=true
            if VisualSetters.AutoRightPlayEnabled then VisualSetters.AutoRightPlayEnabled(true,true) end
            startAutoRightPlay()
            syncMobileBtn("M_AutoRightPlay", true)
        else
            AutoRightPlayEnabled=false Enabled.AutoRightPlayEnabled=false
            if VisualSetters.AutoRightPlayEnabled then VisualSetters.AutoRightPlayEnabled(false,true) end
            stopAutoRightPlay()
            syncMobileBtn("M_AutoRightPlay", false)
        end
    end
    if input.KeyCode==guiToggleKey then guiVisible=not guiVisible main.Visible=guiVisible end
    if input.KeyCode==floatKey then
        floatEnabled=not floatEnabled Enabled.FloatEnabled=floatEnabled
        if VisualSetters.FloatEnabled then VisualSetters.FloatEnabled(floatEnabled) end
        if floatEnabled then startFloat() else stopFloat() end
        syncMobileBtn("M_Float", floatEnabled)
    end
    if input.KeyCode==galaxyKey then
        Enabled.Galaxy=not Enabled.Galaxy
        if VisualSetters.Galaxy then VisualSetters.Galaxy(Enabled.Galaxy) end
        if Enabled.Galaxy then startGalaxy() else stopGalaxy() end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    -- spaceHeld handled by JumpRequest only
end)

-- Inf Jump: catch mobile/controller jump requests
UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled and not spaceHeld then
        forceJump = true
        spaceHeld = true
    end
    -- Float jump: give an upward velocity burst; floatBaseY stays fixed so they fall back down
    if floatEnabled then
        local c = LocalPlayer.Character
        if c then
            local r = c:FindFirstChild("HumanoidRootPart")
            if r then
                r.AssemblyLinearVelocity = Vector3.new(r.AssemblyLinearVelocity.X, INF_JUMP_POWER, r.AssemblyLinearVelocity.Z)
            end
        end
    end
end)

local lastCollisionUpdate=0
RunService.Heartbeat:Connect(function()
    if not (h and hrp) then return end
    if not (AutoLeftEnabled or AutoRightEnabled or AutoLeftPlayEnabled or AutoRightPlayEnabled) then
        local md=h.MoveDirection
        local speed=speedToggled and CARRY_SPEED or NORMAL_SPEED
        if md.Magnitude > 0.1 then
            hrp.AssemblyLinearVelocity=Vector3.new(md.X*speed,hrp.AssemblyLinearVelocity.Y,md.Z*speed)
        end
    end
    if speedLbl then
        local displaySpeed=Vector3.new(hrp.AssemblyLinearVelocity.X,0,hrp.AssemblyLinearVelocity.Z).Magnitude
        speedLbl.Text="Speed: "..string.format("%.1f",displaySpeed)
    end
    local now=tick()
    if now-lastCollisionUpdate >= 0.1 then
        lastCollisionUpdate=now
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=LocalPlayer and plr.Character then
                for _,part in ipairs(plr.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then part.CanCollide=false end
                end
            end
        end
    end
end)


task.spawn(function()
    task.wait()  -- single frame — just lets the GUI parent to PlayerGui before we touch it
    for key,setter in pairs(VisualSetters) do
        if Enabled[key]~=nil then setter(Enabled[key],true) end
    end
    if Enabled.AutoSteal    then task.spawn(startAutoSteal) end
    if Enabled.AntiRagdoll  then task.spawn(startAntiRagdoll) end
    if Enabled.Galaxy       then task.spawn(startGalaxy) end
    if Enabled.Unwalk       then task.spawn(startUnwalk) end
    if Enabled.Optimizer    then task.spawn(enableOptimizer) end
    if Enabled.FloatEnabled then floatEnabled=true task.spawn(startFloat) end
    if Enabled.NoClip       then task.spawn(startNoClip) end
    if Enabled.InfJump      then infJumpEnabled=true task.spawn(startInfJump) end
    if Enabled.AutoTP       then task.spawn(startAutoTP) tpWindow.Visible=true end
    if Enabled.DarkMode     then task.spawn(enableDarkMode) end
    if Enabled.BatAimbot    then autoBatToggled=true task.spawn(startBatAimbot) end

    -- Restore speed toggle visual
    if speedToggled and modeLabel then
        modeLabel.Text="Mode: Carry"
        syncMobileBtn("M_Speed", true)
    end

    -- Restore TP side selection
    if tpSelectedSide and tpStatusLabel then
        tpStatusLabel.Text = tpSelectedSide.." base selected"
    end

    -- Restore lock state
    if uiLocked then
        if lockFixedBtn then
            lockFixedBtn.Text = "🔒 Locked"
            lockFixedBtn.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
        end
        -- show lock bars on all buttons
        for _, ref in pairs(mbRefs) do
            ref.lockBar.BackgroundTransparency = 0
        end
    end

    -- Restore UI scale
    local uiScale = gui:FindFirstChildOfClass("UIScale")
    if uiScaleValue == 1.0 then
        if uiScale then uiScale:Destroy() end
    else
        if not uiScale then uiScale = Instance.new("UIScale", gui) end
        uiScale.Scale = uiScaleValue
    end

    -- Restore transparency
    if currentTransparency > 0 then
        main.BackgroundTransparency = currentTransparency
        tpWindow.BackgroundTransparency = currentTransparency
    end

    refreshAllBadges()
    if RadiusInputRef then RadiusInputRef.Text=tostring(Values.STEAL_RADIUS) end

    -- Sync all mobile buttons
    syncMobileBtn("M_Aimbot",       Enabled.BatAimbot)
    syncMobileBtn("M_Float",        floatEnabled)
    syncMobileBtn("M_AutoRight",    AutoRightEnabled)
    syncMobileBtn("M_AutoLeft",     AutoLeftEnabled)
    syncMobileBtn("M_AutoRightPlay",AutoRightPlayEnabled)
    syncMobileBtn("M_AutoLeftPlay", AutoLeftPlayEnabled)
    syncMobileBtn("M_AutoSteal",    Enabled.AutoSteal)
    syncMobileBtn("M_Speed",        speedToggled)

    -- Restore saved button positions
    for name, pos in pairs(savedBtnPositions) do
        if name == "StealBar" then
            if ProgressBarContainer and ProgressBarContainer.Parent then
                ProgressBarContainer.Position = UDim2.new(0, pos.x, 0, pos.y)
            end
        else
            local ref = mbRefs[name]
            if ref and ref.btn and ref.btn.Parent then
                ref.btn.Position = UDim2.new(0, pos.x, 0, pos.y)
            end
        end
    end
end)

print("=== N5 DUELS LOADED (PURPLE THEME + DROP BRAINROTS + MOBILE PANEL) ===")
print("N5 DUELS loaded — touch/controller only")