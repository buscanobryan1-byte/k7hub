-- OPTIMIZED IRISH HUB (patched version)
-- NOTE: Heavy loops replaced to reduce lag

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local lp = Players.LocalPlayer
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "IrishHub_Official"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local COLORS = {
    MainBG = Color3.fromRGB(11, 14, 20),
    TabBG = Color3.fromRGB(15, 20, 28),
    Border = Color3.fromRGB(0, 170, 0),
    TextActive = Color3.fromRGB(0, 170, 0),
    TextInactive = Color3.fromRGB(140, 140, 140),
    RowBG = Color3.fromRGB(18, 24, 35)
}

local function create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do 
        if k ~= "Parent" then 
            obj[k] = v 
        end 
    end
    obj.Parent = props.Parent
    return obj
end

local configFile = "Irish_Hub_Duels_config.json"
local Config = {}
local ToggleStates = {}
local ToggleCallbacks = {}
local LockUIMove = false

local ToggleIcon, MainFrame, AntiRagdoll, SpeedCustomizer, XrayBase, NoAnim, PlayerESP, InfiniteJump, AutoPlay, AutoTp, BatAimbot, AutoSteal

local function saveConfig()
    local saveData = {
        Toggles = {},
        Positions = {},
        Speeds = {},
        Other = {}
    }
    
    for k, v in pairs(ToggleStates) do
        saveData.Toggles[k] = v
    end
    
    if ToggleIcon then
        saveData.Positions.ToggleIcon = {ToggleIcon.Position.X.Scale, ToggleIcon.Position.X.Offset, ToggleIcon.Position.Y.Scale, ToggleIcon.Position.Y.Offset}
    end
    
    if MainFrame then
        saveData.Positions.MainFrame = {MainFrame.Position.X.Scale, MainFrame.Position.X.Offset, MainFrame.Position.Y.Scale, MainFrame.Position.Y.Offset}
    end
    
    if BatAimbot and BatAimbot.btn then
        saveData.Positions.BatAimbotBtn = {BatAimbot.btn.Position.X.Scale, BatAimbot.btn.Position.X.Offset, BatAimbot.btn.Position.Y.Scale, BatAimbot.btn.Position.Y.Offset}
    end
    
    if AutoPlay and AutoPlay.btn then
        saveData.Positions.AutoPlayBtn = {AutoPlay.btn.Position.X.Scale, AutoPlay.btn.Position.X.Offset, AutoPlay.btn.Position.Y.Scale, AutoPlay.btn.Position.Y.Offset}
    end
    
    if SpeedCustomizer and SpeedCustomizer.SpeedUI and SpeedCustomizer.SpeedUI.MainFrame then
        saveData.Positions.SpeedFrame = {SpeedCustomizer.SpeedUI.MainFrame.Position.X.Scale, SpeedCustomizer.SpeedUI.MainFrame.Position.X.Offset, SpeedCustomizer.SpeedUI.MainFrame.Position.Y.Scale, SpeedCustomizer.SpeedUI.MainFrame.Position.Y.Offset}
    end
    
    if SpeedCustomizer then
        saveData.Speeds = {
            Speed = SpeedCustomizer.SpeedValue or 58,
            Steal = SpeedCustomizer.StealValue or 29
        }
    end
    
    if AntiRagdoll then
        saveData.Other.RagdollEnabled = AntiRagdoll.Enabled or false
    end
    
    if InfiniteJump then
        saveData.Other.JumpPower = InfiniteJump.JUMP_POWER or 50
        saveData.Other.JumpCooldown = InfiniteJump.COOLDOWN or 0.15
    end
    
    if SpeedCustomizer then
        saveData.Other.SpeedEnabled = SpeedCustomizer.Enabled or false
    end
    
    if AutoPlay then
        saveData.Other.AutoPlayEnabled = AutoPlay.Enabled or false
        saveData.Other.AutoPlayActive = AutoPlay.Active or false
    end
    
    if AutoTp then
        saveData.Other.AutoTpEnabled = AutoTp.Enabled or false
    end
    
    if BatAimbot then
        saveData.Other.BatAimbotEnabled = BatAimbot.Enabled or false
        saveData.Other.BatAimbotActive = BatAimbot.Active or false
    end
    
    if AutoSteal then
        saveData.Other.AutoStealEnabled = AutoSteal.Enabled or false
    end
    
    local data = HttpService:JSONEncode(saveData)
    writefile(configFile, data)
end

local function loadConfig()
    if isfile(configFile) then
        local data = readfile(configFile)
        Config = HttpService:JSONDecode(data)
        
        if Config.Toggles then
            for k, v in pairs(Config.Toggles) do
                ToggleStates[k] = v
            end
        end
    end
end

loadConfig()

ToggleIcon = create("TextButton", {
    Size = UDim2.new(0, 45, 0, 45), Position = UDim2.new(0.05, 0, 0.2, 0),
    BackgroundColor3 = COLORS.MainBG, Text = "☘️", TextColor3 = COLORS.Border,
    Font = "GothamBold", TextSize = 20, Parent = ScreenGui
})
create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = ToggleIcon})
create("UIStroke", {Color = COLORS.Border, Thickness = 1.5, Parent = ToggleIcon})

if Config.Positions and Config.Positions.ToggleIcon then
    ToggleIcon.Position = UDim2.new(unpack(Config.Positions.ToggleIcon))
end

MainFrame = create("Frame", {
    Size = UDim2.new(0, 340, 0, 380), Position = UDim2.new(0.5, -170, 0.5, -190),
    BackgroundColor3 = COLORS.MainBG, BackgroundTransparency = 0.2, Visible = false, Parent = ScreenGui
})
create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = MainFrame})
create("UIStroke", {Color = COLORS.Border, Thickness = 2, Parent = MainFrame})

if Config.Positions and Config.Positions.MainFrame then
    MainFrame.Position = UDim2.new(unpack(Config.Positions.MainFrame))
end

local Header = create("Frame", {Size = UDim2.new(1, 0, 0, 45), BackgroundTransparency = 1, Parent = MainFrame})
create("TextLabel", {
    Text = "Irish Hub", TextColor3 = COLORS.Border, Font = "GothamBold", TextSize = 18,
    Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0.05, 0, 0, 0),
    BackgroundTransparency = 1, TextXAlignment = "Left", Parent = Header
})

local TabContainer = create("Frame", {
    Size = UDim2.new(0.92, 0, 0, 30), Position = UDim2.new(0.04, 0, 0.13, 0),
    BackgroundColor3 = COLORS.TabBG, Parent = MainFrame
})
create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = TabContainer})
local TabList = create("UIListLayout", {FillDirection = "Horizontal", HorizontalAlignment = "Center", Parent = TabContainer})

local PageContainer = create("Frame", {
    Size = UDim2.new(1, 0, 0.75, 0), Position = UDim2.new(0, 0, 0.22, 0),
    BackgroundTransparency = 1, Parent = MainFrame
})

local Pages = {}
local TabButtons = {}

local function CreatePage(name)
    local Page = create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false,
        ScrollBarThickness = 0, AutomaticCanvasSize = "Y", Parent = PageContainer
    })
    create("UIListLayout", {HorizontalAlignment = "Center", Padding = UDim.new(0, 8), Parent = Page})
    Pages[name] = Page
    
    local TabBtn = create("TextButton", {
        Size = UDim2.new(0.25, 0, 1, 0), BackgroundTransparency = 1,
        Text = name, TextColor3 = COLORS.TextInactive, Font = "GothamBold", TextSize = 10,
        Parent = TabContainer
    })
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        for _, b in pairs(TabButtons) do b.TextColor3 = COLORS.TextInactive end
        Page.Visible = true
        TabBtn.TextColor3 = COLORS.TextActive
    end)
    TabButtons[name] = TabBtn
end

local function AddToggle(pageName, labelText, default, callback)
    default = (Config.Toggles and Config.Toggles[labelText] ~= nil) and Config.Toggles[labelText] or default
    ToggleStates[labelText] = default
    
    local Row = create("Frame", {
        Size = UDim2.new(0.92, 0, 0, 50), BackgroundColor3 = COLORS.RowBG,
        BackgroundTransparency = 0.5, Parent = Pages[pageName]
    })
    create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Row})
    create("UIStroke", {Color = COLORS.Border, Thickness = 1, Transparency = 0.8, Parent = Row})

    create("TextLabel", {
        Text = labelText, Size = UDim2.new(0.6, 0, 1, 0), Position = UDim2.new(0.05, 0, 0, 0),
        TextColor3 = Color3.new(1,1,1), Font = "GothamBold", TextSize = 13,
        BackgroundTransparency = 1, TextXAlignment = "Left", Parent = Row
    })

    local TglBg = create("Frame", {
        Size = UDim2.new(0, 42, 0, 20), Position = UDim2.new(0.95, -42, 0.5, -10),
        BackgroundColor3 = ToggleStates[labelText] and COLORS.Border or Color3.fromRGB(40, 45, 55), Parent = Row
    })
    create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = TglBg})
    
    local Circle = create("Frame", {
        Size = UDim2.new(0, 16, 0, 16), Position = ToggleStates[labelText] and UDim2.new(0.55, 0, 0.1, 0) or UDim2.new(0.1, 0, 0.1, 0),
        BackgroundColor3 = Color3.new(1, 1, 1), Parent = TglBg
    })
    create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Circle})

    local StatusLabel = create("TextLabel", {
        Size = UDim2.new(0, 30, 0, 20), Position = UDim2.new(0.85, -35, 0.5, -10),
        BackgroundTransparency = 1,
        Text = ToggleStates[labelText] and "ON" or "OFF",
        TextColor3 = COLORS.Border,
        Font = "GothamBold", TextSize = 12,
        TextXAlignment = "Right",
        Parent = Row
    })

    local Btn = create("TextButton", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = "", Parent = Row})
    Btn.MouseButton1Click:Connect(function()
        ToggleStates[labelText] = not ToggleStates[labelText]
        local active = ToggleStates[labelText]
        TweenService:Create(TglBg, TweenInfo.new(0.2), {BackgroundColor3 = active and COLORS.Border or Color3.fromRGB(40, 45, 55)}):Play()
        TweenService:Create(Circle, TweenInfo.new(0.2), {Position = active and UDim2.new(0.55, 0, 0.1, 0) or UDim2.new(0.1, 0, 0.1, 0)}):Play()
        StatusLabel.Text = active and "ON" or "OFF"
        callback(active)
    end)
    
    callback(default)
end

local function AddButton(pageName, labelText, callback)
    local Row = create("Frame", {
        Size = UDim2.new(0.92, 0, 0, 50), BackgroundColor3 = COLORS.RowBG,
        BackgroundTransparency = 0.5, Parent = Pages[pageName]
    })
    create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Row})
    create("UIStroke", {Color = COLORS.Border, Thickness = 1, Transparency = 0.8, Parent = Row})

    create("TextLabel", {
        Text = labelText, Size = UDim2.new(0.6, 0, 1, 0), Position = UDim2.new(0.05, 0, 0, 0),
        TextColor3 = Color3.new(1,1,1), Font = "GothamBold", TextSize = 13,
        BackgroundTransparency = 1, TextXAlignment = "Left", Parent = Row
    })

    local Btn = create("TextButton", {
        Size = UDim2.new(0, 100, 0, 30), Position = UDim2.new(0.95, -110, 0.5, -15),
        BackgroundColor3 = COLORS.Border, Text = "Save", TextColor3 = Color3.new(1,1,1),
        Font = "GothamBold", TextSize = 13, Parent = Row
    })
    create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Btn})
    
    Btn.MouseButton1Click:Connect(function()
        callback()
        Btn.Text = "Saved"
        task.wait(1)
        Btn.Text = "Save"
    end)
end

for _, tab in ipairs({"Combat", "Protect", "Visual", "Settings"}) do CreatePage(tab) end
TabButtons["Combat"].TextColor3 = COLORS.TextActive
Pages["Combat"].Visible = true

AntiRagdoll = {
    Enabled = false,
    heartbeatConn = nil
}

local function enableAntiRagdoll()
    if AntiRagdoll.Enabled then return end
    
    AntiRagdoll.Enabled = true
    
    AntiRagdoll.heartbeatConn = RunService.Heartbeat:Connect(function()
        local char = lp.Character
        if not char then return end
        
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        
        if hum then
            local humState = hum:GetState()
            if humState == Enum.HumanoidStateType.Physics or humState == Enum.HumanoidStateType.Ragdoll or humState == Enum.HumanoidStateType.FallingDown then
                hum:ChangeState(Enum.HumanoidStateType.Running)
                workspace.CurrentCamera.CameraSubject = hum
                pcall(function()
                    if lp.Character then
                        local PlayerModule = lp.PlayerScripts:FindFirstChild("PlayerModule")
                        if PlayerModule then
                            local ControlModule = PlayerModule:FindFirstChild("ControlModule")
                            if ControlModule then
                                local Controls = require(ControlModule)
                                if Controls and Controls.Enable then
                                    Controls:Enable()
                                end
                            end
                        end
                    end
                end)
                if root then
                    root.Velocity = Vector3.new(0, 0, 0)
                    root.RotVelocity = Vector3.new(0, 0, 0)
                end
            end
        end
        
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("Motor6D") and obj.Enabled == false then
                obj.Enabled = true
            end
        end
    end)
end

local function disableAntiRagdoll()
    if not AntiRagdoll.Enabled then return end
    
    AntiRagdoll.Enabled = false
    
    if AntiRagdoll.heartbeatConn then
        AntiRagdoll.heartbeatConn:Disconnect()
        AntiRagdoll.heartbeatConn = nil
    end
end

BatAimbot = {
    Enabled = false,
    Active = false,
    FLY_SPEED = 55,
    heartbeatConn = nil,
    equipLoop = nil,
    gui = nil,
    btn = nil
}

local function createBatAimbotUI()
    BatAimbot.gui = Instance.new("ScreenGui")
    BatAimbot.gui.Name = "BatAimbotUI"
    BatAimbot.gui.ResetOnSpawn = false
    BatAimbot.gui.Enabled = false
    BatAimbot.gui.Parent = CoreGui

    BatAimbot.btn = Instance.new("TextButton")
    BatAimbot.btn.Size = UDim2.new(0, 120, 0, 40)
    BatAimbot.btn.Position = UDim2.new(0.5, -60, 0.8, 0)
    BatAimbot.btn.Text = "AimBot: OFF"
    BatAimbot.btn.Font = Enum.Font.GothamBold
    BatAimbot.btn.TextSize = 14
    BatAimbot.btn.TextColor3 = Color3.new(1, 1, 1)
    BatAimbot.btn.BackgroundColor3 = Color3.fromRGB(0, 160, 0)
    BatAimbot.btn.AutoButtonColor = true
    BatAimbot.btn.Parent = BatAimbot.gui

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 8)
    uiCorner.Parent = BatAimbot.btn

    if Config.Positions and Config.Positions.BatAimbotBtn then
        BatAimbot.btn.Position = UDim2.new(unpack(Config.Positions.BatAimbotBtn))
    end

    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        BatAimbot.btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    BatAimbot.btn.InputBegan:Connect(function(input)
        if LockUIMove then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = BatAimbot.btn.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    BatAimbot.btn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    BatAimbot.btn.MouseButton1Click:Connect(function()
        BatAimbot.Active = not BatAimbot.Active
        BatAimbot.btn.Text = BatAimbot.Active and "AimBot: ON" or "AimBot: OFF"
        
        if not BatAimbot.Active then
            local character = lp.Character
            if character then
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    humanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                end
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.PlatformStand = false
                end
            end
        end
    end)
end

local function getNearestPlayerForBat()
    local character = lp.Character
    if not character then return nil end
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return nil end

    local nearestPlayer = nil
    local nearestDistance = math.huge
    local myPos = humanoidRootPart.Position

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (p.Character.HumanoidRootPart.Position - myPos).Magnitude
            if distance < nearestDistance then
                nearestDistance = distance
                nearestPlayer = p
            end
        end
    end

    return nearestPlayer
end

local function enableBatAimbot()
    if BatAimbot.Enabled then 
        return 
    end
    
    BatAimbot.Enabled = true
    
    if not BatAimbot.gui then
        createBatAimbotUI()
    end
    
    BatAimbot.gui.Enabled = true
    
    if Config.Other and Config.Other.BatAimbotActive ~= nil then
        BatAimbot.Active = Config.Other.BatAimbotActive
    else
        BatAimbot.Active = false
    end
    
    if BatAimbot.btn then
        BatAimbot.btn.Text = BatAimbot.Active and "AimBot: ON" or "AimBot: OFF"
        BatAimbot.btn.BackgroundColor3 = Color3.fromRGB(0, 160, 0)
    end
    
    BatAimbot.heartbeatConn = RunService.Heartbeat:Connect(function()
        if not BatAimbot.Enabled or not BatAimbot.Active then 
            return 
        end
        
        local character = lp.Character
        if not character then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not humanoidRootPart then return end

        local nearestPlayer = getNearestPlayerForBat()
        if nearestPlayer and nearestPlayer.Character and nearestPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = nearestPlayer.Character.HumanoidRootPart.Position
            local direction = (targetPos - humanoidRootPart.Position).Unit
            humanoidRootPart.AssemblyLinearVelocity = direction * BatAimbot.FLY_SPEED
            humanoid.PlatformStand = true
        end
    end)
    
    BatAimbot.equipLoop = task.spawn(function()
        while BatAimbot.Enabled do
            if BatAimbot.Active then
                local character = lp.Character
                if character then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        local bat = character:FindFirstChild("Bat") or lp.Backpack:FindFirstChild("Bat")
                        if bat then
                            if bat.Parent == lp.Backpack then
                                humanoid:EquipTool(bat)
                                task.wait(0.1)
                            end
                            local equippedBat = character:FindFirstChild("Bat")
                            if equippedBat then
                                equippedBat:Activate()
                            end
                        end
                    end
                end
            end
            task.wait(0.15)
        end
    end)
end

local function disableBatAimbot()
    if not BatAimbot.Enabled then return end
    
    BatAimbot.Enabled = false
    BatAimbot.Active = false
    
    if BatAimbot.gui then
        BatAimbot.gui.Enabled = false
    end
    
    if BatAimbot.heartbeatConn then
        BatAimbot.heartbeatConn:Disconnect()
        BatAimbot.heartbeatConn = nil
    end
    
    if BatAimbot.equipLoop then
        task.cancel(BatAimbot.equipLoop)
        BatAimbot.equipLoop = nil
    end
    
    local character = lp.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
    end
end

AutoPlay = {
    Enabled = false,
    Active = false,
    currentWaypointIndex = 1,
    currentWaypoints = nil,
    renderConn = nil,
    gui = nil,
    btn = nil,
    plotPositions = {
        [3] = Vector3.new(-476.7524719238281, 10.464664459228516, 7.107429504394531),
        [7] = Vector3.new(-476.7524719238281, 10.464664459228516, 114.10742950439453)
    },
    waypoints = {
        [3] = {
            {position = Vector3.new(-475, -7, 90), speed = 58.5},
            {position = Vector3.new(-475, -7, 90), speed = 58.5},
            {position = Vector3.new(-479, -5, 95), speed = 58.5},
            {position = Vector3.new(-479, -5, 95), speed = 58.5},
            {position = Vector3.new(-486, -5, 97), speed = 58.5},
            {position = Vector3.new(-486, -5, 97), speed = 58.5},
            {position = Vector3.new(-474, -7, 92), speed = 29},
            {position = Vector3.new(-474, -7, 92), speed = 29},
            {position = Vector3.new(-474, -7, -1), speed = 29}
        },
        [7] = {
            {position = Vector3.new(-474, -7, 29), speed = 58.5},
            {position = Vector3.new(-473, -7, 29), speed = 58.5},
            {position = Vector3.new(-478, -6, 25), speed = 58.5},
            {position = Vector3.new(-488, -5, 23), speed = 58.5},
            {position = Vector3.new(-488, -5, 23), speed = 58.5},
            {position = Vector3.new(-474, -7, 29), speed = 29},
            {position = Vector3.new(-474, -7, 29), speed = 29},
            {position = Vector3.new(-475, -7, 118), speed = 29},
            {position = Vector3.new(-475, -7, 118), speed = 29}
        }
    }
}

local function createAutoPlayUI()
    AutoPlay.gui = Instance.new("ScreenGui")
    AutoPlay.gui.Name = "AutoPlayUI"
    AutoPlay.gui.ResetOnSpawn = false
    AutoPlay.gui.Enabled = false
    AutoPlay.gui.Parent = CoreGui

    AutoPlay.btn = Instance.new("TextButton")
    AutoPlay.btn.Size = UDim2.new(0, 140, 0, 40)
    AutoPlay.btn.Position = UDim2.new(0.5, -70, 0.7, 0)
    AutoPlay.btn.Text = "AutoPlay: OFF"
    AutoPlay.btn.Font = Enum.Font.GothamBold
    AutoPlay.btn.TextSize = 14
    AutoPlay.btn.TextColor3 = Color3.new(1, 1, 1)
    AutoPlay.btn.BackgroundColor3 = Color3.fromRGB(0, 160, 0)
    AutoPlay.btn.AutoButtonColor = true
    AutoPlay.btn.Parent = AutoPlay.gui

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 8)
    uiCorner.Parent = AutoPlay.btn

    if Config.Positions and Config.Positions.AutoPlayBtn then
        AutoPlay.btn.Position = UDim2.new(unpack(Config.Positions.AutoPlayBtn))
    end

    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        AutoPlay.btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    AutoPlay.btn.InputBegan:Connect(function(input)
        if LockUIMove then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = AutoPlay.btn.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    AutoPlay.btn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    AutoPlay.btn.MouseButton1Click:Connect(function()
        if not AutoPlay.Enabled then return end
        
        AutoPlay.Active = not AutoPlay.Active
        AutoPlay.btn.Text = AutoPlay.Active and "AutoPlay: ON" or "AutoPlay: OFF"
        
        if not AutoPlay.Active then
            AutoPlay.currentWaypoints = nil
            AutoPlay.currentWaypointIndex = 1
            local character = lp.Character
            if character then
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                end
            end
        end
    end)
end

local function getPlotOwner(plotPart)
    if not plotPart then return "Unknown" end
    for _, child in ipairs(plotPart:GetDescendants()) do
        if child:IsA("SurfaceGui") then
            for _, label in ipairs(child:GetDescendants()) do
                if label:IsA("TextLabel") and label.Text ~= "" then
                    return label.Text
                end
            end
        end
    end
    return "Unknown"
end

local function checkMyPlot()
    for plotNum, position in pairs(AutoPlay.plotPositions) do
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name == "PlotSign" then
                local dist = (obj.Position - position).Magnitude
                if dist < 1 then
                    local owner = getPlotOwner(obj)
                    if string.find(owner, lp.Name) or string.find(owner, lp.DisplayName) then
                        return plotNum
                    end
                end
            end
        end
    end
    return nil
end

local function enableAutoPlay()
    if AutoPlay.Enabled then 
        return 
    end
    
    AutoPlay.Enabled = true
    AutoPlay.Active = false
    AutoPlay.currentWaypoints = nil
    AutoPlay.currentWaypointIndex = 1
    
    if not AutoPlay.gui then
        createAutoPlayUI()
    end
    
    AutoPlay.gui.Enabled = true
    
    if AutoPlay.btn then
        AutoPlay.btn.Text = "AutoPlay: OFF"
    end
    
    AutoPlay.renderConn = RunService.RenderStepped:Connect(function()
        if not AutoPlay.Enabled or not AutoPlay.Active then 
            return 
        end
        
        local character = lp.Character
        if not character then return end
        
        local hrp = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        
        if not hrp or not humanoid then return end
        
        if not AutoPlay.currentWaypoints then
            local plotNum = checkMyPlot()
            if plotNum and AutoPlay.waypoints[plotNum] then
                AutoPlay.currentWaypoints = AutoPlay.waypoints[plotNum]
                AutoPlay.currentWaypointIndex = 1
            else
                return
            end
        end
        
        local currentWaypoint = AutoPlay.currentWaypoints[AutoPlay.currentWaypointIndex]
        local targetPos = currentWaypoint.position
        local targetSpeed = currentWaypoint.speed
        
        local distance = (hrp.Position - targetPos).Magnitude
        
        if distance < 5 then
            if AutoPlay.currentWaypointIndex < #AutoPlay.currentWaypoints then
                AutoPlay.currentWaypointIndex = AutoPlay.currentWaypointIndex + 1
            else
                AutoPlay.Active = false
                AutoPlay.currentWaypoints = nil
                AutoPlay.currentWaypointIndex = 1
                if AutoPlay.btn then
                    AutoPlay.btn.Text = "AutoPlay: OFF"
                end
                if hrp then
                    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                end
                return
            end
        else
            local moveDir = (targetPos - hrp.Position).Unit
            local moveVector = Vector3.new(moveDir.X, 0, moveDir.Z)
            
            if moveVector.Magnitude > 0 then
                hrp.AssemblyLinearVelocity = Vector3.new(
                    moveVector.X * targetSpeed,
                    hrp.AssemblyLinearVelocity.Y,
                    moveVector.Z * targetSpeed
                )
            end
        end
    end)
end

local function disableAutoPlay()
    if not AutoPlay.Enabled then return end
    
    AutoPlay.Enabled = false
    AutoPlay.Active = false
    AutoPlay.currentWaypoints = nil
    AutoPlay.currentWaypointIndex = 1
    
    if AutoPlay.gui then
        AutoPlay.gui.Enabled = false
    end
    
    if AutoPlay.renderConn then
        AutoPlay.renderConn:Disconnect()
        AutoPlay.renderConn = nil
    end
    
    local character = lp.Character
    if character then
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
    end
end

AutoSteal = {
    Enabled = false,
    STEAL_RADIUS = 8,
    STEAL_DURATION = 0.2,
    isStealing = false,
    StealData = {},
    screenGui = nil,
    barContainer = nil,
    progressBar = nil,
    statusLabel = nil,
    heartbeatConn = nil
}

local function createStealUI()
    AutoSteal.screenGui = Instance.new("ScreenGui")
    AutoSteal.screenGui.Name = "StealProgress"
    AutoSteal.screenGui.ResetOnSpawn = false
    AutoSteal.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    AutoSteal.screenGui.Parent = lp:WaitForChild("PlayerGui")

    AutoSteal.barContainer = Instance.new("Frame")
    AutoSteal.barContainer.Size = UDim2.new(0, 200, 0, 28)
    AutoSteal.barContainer.Position = UDim2.new(0.5, -100, 0.05, 0)
    AutoSteal.barContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    AutoSteal.barContainer.BackgroundTransparency = 0.2
    AutoSteal.barContainer.BorderSizePixel = 0
    AutoSteal.barContainer.Parent = AutoSteal.screenGui

    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 14)
    containerCorner.Parent = AutoSteal.barContainer

    local containerStroke = Instance.new("UIStroke")
    containerStroke.Color = Color3.fromRGB(0, 255, 0)
    containerStroke.Thickness = 1.5
    containerStroke.Transparency = 0.7
    containerStroke.Parent = AutoSteal.barContainer

    local barBackground = Instance.new("Frame")
    barBackground.Size = UDim2.new(1, -8, 1, -8)
    barBackground.Position = UDim2.new(0, 4, 0, 4)
    barBackground.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    barBackground.BackgroundTransparency = 0.3
    barBackground.BorderSizePixel = 0
    barBackground.Parent = AutoSteal.barContainer

    local barBgCorner = Instance.new("UICorner")
    barBgCorner.CornerRadius = UDim.new(0, 10)
    barBgCorner.Parent = barBackground

    AutoSteal.progressBar = Instance.new("Frame")
    AutoSteal.progressBar.Size = UDim2.new(0, 0, 1, 0)
    AutoSteal.progressBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    AutoSteal.progressBar.BorderSizePixel = 0
    AutoSteal.progressBar.Parent = barBackground

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 10)
    barCorner.Parent = AutoSteal.progressBar

    AutoSteal.statusLabel = Instance.new("TextLabel")
    AutoSteal.statusLabel.Size = UDim2.new(1, -16, 1, 0)
    AutoSteal.statusLabel.Position = UDim2.new(0, 8, 0, 0)
    AutoSteal.statusLabel.BackgroundTransparency = 1
    AutoSteal.statusLabel.Text = "READY"
    AutoSteal.statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    AutoSteal.statusLabel.TextSize = 13
    AutoSteal.statusLabel.Font = Enum.Font.GothamSemibold
    AutoSteal.statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    AutoSteal.statusLabel.Parent = AutoSteal.barContainer
end

local function getHRP()
    local c = lp.Character
    if c then
        return c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso")
    end
    return nil
end

local function updateProgress(duration)
    local startTime = tick()
    AutoSteal.statusLabel.Text = "STEALING"
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        local elapsed = tick() - startTime
        local progress = math.min(elapsed / duration, 1)
        
        AutoSteal.progressBar.Size = UDim2.new(progress, 0, 1, 0)
        
        if progress >= 1 then
            connection:Disconnect()
            AutoSteal.progressBar.Size = UDim2.new(0, 0, 1, 0)
            AutoSteal.statusLabel.Text = "READY"
        end
    end)
end

local function isMyPlotByName(pn)
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return false end
    local plot = plots:FindFirstChild(pn)
    if not plot then return false end
    local sign = plot:FindFirstChild("PlotSign")
    if sign then
        local yb = sign:FindFirstChild("YourBase")
        if yb and yb:IsA("BillboardGui") then
            return yb.Enabled == true
        end
    end
    return false
end

local function findNearestPrompt()
    local hrp = getHRP()
    if not hrp then return nil end
    
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil end
    
    local nearest, dist = nil, math.huge
    
    for _, plot in ipairs(plots:GetChildren()) do
        if isMyPlotByName(plot.Name) then
            continue
        end
        
        local pods = plot:FindFirstChild("AnimalPodiums")
        if not pods then continue end
        
        for _, pod in ipairs(pods:GetChildren()) do
            local base = pod:FindFirstChild("Base")
            if not base then continue end
            
            local spawn = base:FindFirstChild("Spawn")
            if not spawn then continue end
            
            local d = (spawn.Position - hrp.Position).Magnitude
            if d <= AutoSteal.STEAL_RADIUS and d < dist then
                local att = spawn:FindFirstChild("PromptAttachment")
                if att then
                    for _, p in ipairs(att:GetChildren()) do
                        if p:IsA("ProximityPrompt") and p.ActionText and p.ActionText:find("Steal") then
                            nearest, dist = p, d
                        end
                    end
                end
            end
        end
    end
    
    return nearest
end

local function executeSteal(prompt)
    if AutoSteal.isStealing then return end
    
    if not AutoSteal.StealData[prompt] then
        AutoSteal.StealData[prompt] = {hold = {}, trigger = {}, ready = true}
        
        if getconnections then
            for _, c in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do
                if c.Function then 
                    table.insert(AutoSteal.StealData[prompt].hold, c.Function) 
                end
            end
            for _, c in ipairs(getconnections(prompt.Triggered)) do
                if c.Function then 
                    table.insert(AutoSteal.StealData[prompt].trigger, c.Function) 
                end
            end
        end
    end
    
    local data = AutoSteal.StealData[prompt]
    if not data.ready then return end
    
    data.ready = false
    AutoSteal.isStealing = true
    
    updateProgress(AutoSteal.STEAL_DURATION)
    
    task.spawn(function()
        for _, f in ipairs(data.hold) do 
            local success, err = pcall(function() f() end)
        end
        
        task.wait(AutoSteal.STEAL_DURATION)
        
        for _, f in ipairs(data.trigger) do 
            local success, err = pcall(function() f() end)
        end
        
        data.ready = true
        AutoSteal.isStealing = false
    end)
end

local function enableAutoSteal()
    if AutoSteal.Enabled then return end
    
    AutoSteal.Enabled = true
    
    if not AutoSteal.screenGui then
        createStealUI()
    end
    
    AutoSteal.screenGui.Enabled = true
    
    lp.CharacterAdded:Connect(function()
        AutoSteal.isStealing = false
    end)
    
    AutoSteal.heartbeatConn = RunService.Heartbeat:Connect(function()
        if not AutoSteal.Enabled then return end
        if AutoSteal.isStealing then return end
        
        local success, prompt = pcall(findNearestPrompt)
        if success and prompt then
            local execSuccess, execResult = pcall(executeSteal, prompt)
        end
    end)
end

local function disableAutoSteal()
    if not AutoSteal.Enabled then return end
    
    AutoSteal.Enabled = false
    
    if AutoSteal.screenGui then
        AutoSteal.screenGui.Enabled = false
    end
    
    if AutoSteal.heartbeatConn then
        AutoSteal.heartbeatConn:Disconnect()
        AutoSteal.heartbeatConn = nil
    end
end

AutoTp = {
    Enabled = false,
    PlotPositions = {
        [3] = Vector3.new(-476.7524719238281, 10.464664459228516, 7.107429504394531),
        [7] = Vector3.new(-476.7524719238281, 10.464664459228516, 114.10742950439453)
    },
    finalPos1 = Vector3.new(-483.59, -5.04, 104.24),
    finalPos2 = Vector3.new(-483.51, -5.10, 18.89),
    checkpointA = Vector3.new(-472.60, -7.00, 57.52),
    checkpointB1 = Vector3.new(-472.65, -7.00, 95.69),
    checkpointB2 = Vector3.new(-471.76, -7.00, 26.22),
    connection = nil,
    currentPlot = nil,
    mainLoop = nil
}

local function moveTp(pos)
    local char = lp.Character
    if char then
        char:PivotTo(CFrame.new(pos))
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
        end
    end
end

local function setupTpPlot3()
    if AutoTp.connection then 
        AutoTp.connection:Disconnect() 
    end
    local humanoid = lp.Character and lp.Character:FindFirstChild("Humanoid")
    if humanoid then
        AutoTp.connection = humanoid.StateChanged:Connect(function(_, newState)
            if newState == Enum.HumanoidStateType.Physics or newState == Enum.HumanoidStateType.Ragdoll or newState == Enum.HumanoidStateType.FallingDown then
                moveTp(AutoTp.checkpointA)
                task.wait(0.1)
                moveTp(AutoTp.checkpointB1)
                task.wait(0.1)
                moveTp(AutoTp.finalPos1)
            end
        end)
    end
end

local function setupTpPlot7()
    if AutoTp.connection then 
        AutoTp.connection:Disconnect() 
    end
    local humanoid = lp.Character and lp.Character:FindFirstChild("Humanoid")
    if humanoid then
        AutoTp.connection = humanoid.StateChanged:Connect(function(_, newState)
            if newState == Enum.HumanoidStateType.Physics or newState == Enum.HumanoidStateType.Ragdoll or newState == Enum.HumanoidStateType.FallingDown then
                moveTp(AutoTp.checkpointA)
                task.wait(0.1)
                moveTp(AutoTp.checkpointB2)
                task.wait(0.1)
                moveTp(AutoTp.finalPos2)
            end
        end)
    end
end

local function enableAutoTp()
    if AutoTp.Enabled then return end
    
    AutoTp.Enabled = true
    
    AutoTp.mainLoop = RunService.Heartbeat:Connect(function()
        if not AutoTp.Enabled then return end
        
        local plotNum = checkMyPlot()
        
        if plotNum == 3 and AutoTp.currentPlot ~= 3 then
            setupTpPlot3()
        elseif plotNum == 7 and AutoTp.currentPlot ~= 7 then
            setupTpPlot7()
        elseif not plotNum and AutoTp.connection then
            AutoTp.connection:Disconnect()
            AutoTp.connection = nil
        end
        
        AutoTp.currentPlot = plotNum
    end)
end

local function disableAutoTp()
    if not AutoTp.Enabled then return end
    
    AutoTp.Enabled = false
    
    if AutoTp.connection then
        AutoTp.connection:Disconnect()
        AutoTp.connection = nil
    end
    
    if AutoTp.mainLoop then
        AutoTp.mainLoop:Disconnect()
        AutoTp.mainLoop = nil
    end
    
    AutoTp.currentPlot = nil
end

XrayBase = {
    Enabled = false,
    OriginalTransparency = {},
    Connections = {},
    BaseKeywords = {"base", "claim"}
}

local function isPlayerBase(obj)
    if not (obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("UnionOperation")) then
        return false
    end
    local n = obj.Name:lower()
    local p = obj.Parent and obj.Parent.Name:lower() or ""
    for _, keyword in ipairs(XrayBase.BaseKeywords) do
        if n:find(keyword) or p:find(keyword) then
            return true
        end
    end
    return false
end

local function applyTransparency(obj)
    if isPlayerBase(obj) then
        if not XrayBase.OriginalTransparency[obj] then
            XrayBase.OriginalTransparency[obj] = obj.LocalTransparencyModifier
        end
        obj.LocalTransparencyModifier = 0.8
    end
end

local function restoreTransparency(obj)
    if XrayBase.OriginalTransparency[obj] then
        obj.LocalTransparencyModifier = XrayBase.OriginalTransparency[obj]
        XrayBase.OriginalTransparency[obj] = nil
    end
end

local function enableXrayBase()
    if XrayBase.Enabled then return end
    XrayBase.Enabled = true
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        applyTransparency(obj)
    end
    
    XrayBase.Connections.descendantAdded = Workspace.DescendantAdded:Connect(function(obj)
        applyTransparency(obj)
    end)
    
    XrayBase.Connections.characterAdded = lp.CharacterAdded:Connect(function()
        task.wait(0.5)
        for _, obj in ipairs(Workspace:GetDescendants()) do
            applyTransparency(obj)
        end
    end)
end

local function disableXrayBase()
    if not XrayBase.Enabled then return end
    XrayBase.Enabled = false
    
    for _, conn in pairs(XrayBase.Connections) do
        conn:Disconnect()
    end
    XrayBase.Connections = {}
    
    for obj, original in pairs(XrayBase.OriginalTransparency) do
        obj.LocalTransparencyModifier = original
    end
    XrayBase.OriginalTransparency = {}
end

NoAnim = {
    Enabled = false,
    CharacterConnections = {}
}

local function disableAnims(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
        track:Stop()
    end

    if NoAnim.CharacterConnections[character] then
        NoAnim.CharacterConnections[character]:Disconnect()
    end
    
    NoAnim.CharacterConnections[character] = humanoid.AnimationPlayed:Connect(function(track)
        track:Stop()
    end)
end

local function enableNoAnim()
    if NoAnim.Enabled then return end
    NoAnim.Enabled = true
    
    if lp.Character then
        disableAnims(lp.Character)
    end
    
    NoAnim.CharacterConnections.characterAdded = lp.CharacterAdded:Connect(function(char)
        disableAnims(char)
    end)
end

local function disableNoAnim()
    if not NoAnim.Enabled then return end
    NoAnim.Enabled = false
    
    if NoAnim.CharacterConnections.characterAdded then
        NoAnim.CharacterConnections.characterAdded:Disconnect()
        NoAnim.CharacterConnections.characterAdded = nil
    end
    
    for character, conn in pairs(NoAnim.CharacterConnections) do
        if character ~= "characterAdded" then
            conn:Disconnect()
            NoAnim.CharacterConnections[character] = nil
        end
    end
    
    if lp.Character then
        local humanoid = lp.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if NoAnim.CharacterConnections[lp.Character] then
                NoAnim.CharacterConnections[lp.Character]:Disconnect()
                NoAnim.CharacterConnections[lp.Character] = nil
            end
        end
    end
end

PlayerESP = {
    Enabled = false,
    ESP_COLOR = Color3.fromRGB(85, 255, 85),
    Highlights = {},
    Billboards = {},
    Connections = {}
}

local function createHighlight(character)
    local h = Instance.new("Highlight")
    h.Name = "Irish_PlayerESP_Highlight"
    h.Adornee = character
    h.FillColor = PlayerESP.ESP_COLOR
    h.FillTransparency = 0.25
    h.OutlineColor = PlayerESP.ESP_COLOR
    h.OutlineTransparency = 0
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = CoreGui
    return h
end

local function createBillboard(character, player)
    local hrp = character:WaitForChild("HumanoidRootPart", 5)
    if not hrp then return nil end

    local bb = Instance.new("BillboardGui")
    bb.Name = "Irish_PlayerESP_Name"
    bb.Adornee = hrp
    bb.AlwaysOnTop = true
    bb.Size = UDim2.new(0, 100, 0, 20)
    bb.StudsOffsetWorldSpace = Vector3.new(0, 3, 0)
    bb.MaxDistance = 600
    bb.Parent = CoreGui

    local bg = Instance.new("Frame", bb)
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bg.BackgroundTransparency = 0.4
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 6)

    local txt = Instance.new("TextLabel", bg)
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.Font = Enum.Font.GothamSemibold
    txt.TextSize = 13
    txt.TextColor3 = Color3.new(1, 1, 1)
    txt.TextStrokeTransparency = 0.2
    txt.Text = player.DisplayName

    return bb
end

local function attachESP(player)
    if player == lp then return end

    local function apply(character)
        if PlayerESP.Highlights[player] then 
            pcall(function() PlayerESP.Highlights[player]:Destroy() end) 
        end
        if PlayerESP.Billboards[player] then 
            pcall(function() PlayerESP.Billboards[player]:Destroy() end) 
        end

        PlayerESP.Highlights[player] = createHighlight(character)
        PlayerESP.Billboards[player] = createBillboard(character, player)
    end

    if player.Character then
        apply(player.Character)
    end

    local conn = player.CharacterAdded:Connect(apply)
    table.insert(PlayerESP.Connections, conn)
end

local function removeESP(player)
    if PlayerESP.Highlights[player] then 
        pcall(function() PlayerESP.Highlights[player]:Destroy() end) 
        PlayerESP.Highlights[player] = nil
    end
    if PlayerESP.Billboards[player] then 
        pcall(function() PlayerESP.Billboards[player]:Destroy() end) 
        PlayerESP.Billboards[player] = nil
    end
end

local function enableESP()
    if PlayerESP.Enabled then return end
    PlayerESP.Enabled = true
    
    for _, p in ipairs(Players:GetPlayers()) do
        attachESP(p)
    end
    
    table.insert(PlayerESP.Connections, Players.PlayerAdded:Connect(function(p)
        attachESP(p)
    end))
    
    table.insert(PlayerESP.Connections, Players.PlayerRemoving:Connect(function(p)
        removeESP(p)
    end))
end

local function disableESP()
    if not PlayerESP.Enabled then return end
    PlayerESP.Enabled = false
    
    for _, h in pairs(PlayerESP.Highlights) do 
        pcall(function() h:Destroy() end) 
    end
    for _, b in pairs(PlayerESP.Billboards) do 
        pcall(function() b:Destroy() end) 
    end
    
    for _, c in ipairs(PlayerESP.Connections) do 
        pcall(function() c:Disconnect() end) 
    end
    
    PlayerESP.Highlights = {}
    PlayerESP.Billboards = {}
    PlayerESP.Connections = {}
end

SpeedCustomizer = {
    Enabled = false,
    SpeedUI = nil,
    SpeedValue = 58,
    StealValue = 29,
    HeartbeatConn = nil,
    character = nil,
    hrp = nil,
    hum = nil
}

local function setupSpeedCharacter(char)
    SpeedCustomizer.character = char
    SpeedCustomizer.hrp = char:WaitForChild("HumanoidRootPart")
    SpeedCustomizer.hum = char:WaitForChild("Humanoid")
end

local function createSpeedUI()
    local SpeedScreenGui = create("ScreenGui", {
        Name = "Irish_SpeedUI",
        ResetOnSpawn = false,
        Parent = CoreGui
    })

    local MainFrame = create("Frame", {
        Name = "SpeedMainFrame",
        Size = UDim2.new(0, 280, 0, 200),
        Position = UDim2.new(0.5, -140, 0.4, 0),
        BackgroundColor3 = Color3.fromRGB(20, 25, 30),
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Active = true,
        Draggable = true,
        Parent = SpeedScreenGui
    })

    if Config.Positions and Config.Positions.SpeedFrame then
        MainFrame.Position = UDim2.new(unpack(Config.Positions.SpeedFrame))
    end

    create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = MainFrame})
    create("UIStroke", {Color = Color3.fromRGB(0, 150, 0), Thickness = 2, Parent = MainFrame})

    local Title = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 35),
        Position = UDim2.new(0, 15, 0, 10),
        BackgroundTransparency = 1,
        Text = "Irish Speed Customizer",
        TextColor3 = Color3.fromRGB(0, 180, 0),
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        Parent = MainFrame
    })

    local Header = create("Frame", {
        Size = UDim2.new(1, -20, 0, 45),
        Position = UDim2.new(0, 10, 0, 55),
        BackgroundColor3 = Color3.fromRGB(0, 120, 0),
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Header})

    local ToggleBtn = create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = SpeedCustomizer.Enabled and "ON" or "OFF",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        Parent = Header
    })

    local function createInputRow(labelText, defaultValue, pos)
        local label = create("TextLabel", {
            Size = UDim2.new(0.6, 0, 0, 35),
            Position = UDim2.new(0, 15, 0, pos),
            BackgroundTransparency = 1,
            Text = labelText,
            TextColor3 = Color3.fromRGB(200, 200, 200),
            TextSize = 15,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.Gotham,
            Parent = MainFrame
        })
        
        local box = create("TextBox", {
            Size = UDim2.new(0, 90, 0, 35),
            Position = UDim2.new(1, -105, 0, pos),
            BackgroundColor3 = Color3.fromRGB(30, 35, 40),
            Text = tostring(defaultValue),
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.GothamBold,
            TextSize = 15,
            ClearTextOnFocus = false,
            Parent = MainFrame
        })
        create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = box})
        return box
    end

    local SpeedInput = createInputRow("Speed", SpeedCustomizer.SpeedValue, 110)
    local StealInput = createInputRow("Steal Spd", SpeedCustomizer.StealValue, 155)

    ToggleBtn.MouseButton1Click:Connect(function()
        SpeedCustomizer.Enabled = not SpeedCustomizer.Enabled
        ToggleBtn.Text = SpeedCustomizer.Enabled and "ON" or "OFF"
        Header.BackgroundColor3 = SpeedCustomizer.Enabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(150, 30, 30)
    end)

    local function validateInput(box, min, max)
        box.FocusLost:Connect(function()
            local num = tonumber(box.Text)
            if num then
                num = math.clamp(num, min, max)
                box.Text = tostring(num)
                
                if box == SpeedInput then
                    SpeedCustomizer.SpeedValue = num
                elseif box == StealInput then
                    SpeedCustomizer.StealValue = num
                end
            else
                if box == SpeedInput then
                    box.Text = tostring(SpeedCustomizer.SpeedValue)
                elseif box == StealInput then
                    box.Text = tostring(SpeedCustomizer.StealValue)
                end
            end
        end)
    end

    validateInput(SpeedInput, 1, 200)
    validateInput(StealInput, 1, 200)

    local dragSpeed = false
    local startPos
    local startMousePos
    
    MainFrame.InputBegan:Connect(function(input)
        if LockUIMove then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragSpeed = true
            startPos = MainFrame.Position
            startMousePos = input.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragSpeed = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragSpeed and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - startMousePos
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    SpeedCustomizer.SpeedUI = {
        ScreenGui = SpeedScreenGui,
        ToggleBtn = ToggleBtn,
        SpeedInput = SpeedInput,
        StealInput = StealInput,
        MainFrame = MainFrame,
        Header = Header
    }
end

local function enableSpeedCustomizer()
    if SpeedCustomizer.Enabled then return end
    
    if not SpeedCustomizer.SpeedUI then
        createSpeedUI()
    else
        SpeedCustomizer.SpeedUI.ScreenGui.Enabled = true
    end
    
    SpeedCustomizer.Enabled = true
    SpeedCustomizer.SpeedUI.ToggleBtn.Text = "ON"
    SpeedCustomizer.SpeedUI.Header.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
    
    if lp.Character then
        setupSpeedCharacter(lp.Character)
    end
    
    lp.CharacterAdded:Connect(setupSpeedCharacter)
    
    SpeedCustomizer.HeartbeatConn = RunService.Heartbeat:Connect(function()
        if not SpeedCustomizer.Enabled then 
            return 
        end
        
        if not lp.Character then 
            return 
        end
        
        local character = lp.Character
        local hrp = character:FindFirstChild("HumanoidRootPart")
        local hum = character:FindFirstChildOfClass("Humanoid")
        
        if not hrp or not hum then 
            return 
        end
        
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            local isSteal = hum.WalkSpeed < 25
            local targetSpeed = isSteal and SpeedCustomizer.StealValue or SpeedCustomizer.SpeedValue
            
            if targetSpeed then
                hrp.AssemblyLinearVelocity = Vector3.new(
                    moveDir.X * targetSpeed, 
                    hrp.AssemblyLinearVelocity.Y, 
                    moveDir.Z * targetSpeed
                )
            end
        end
    end)
end

local function disableSpeedCustomizer()
    if not SpeedCustomizer.Enabled then return end
    
    SpeedCustomizer.Enabled = false
    
    if SpeedCustomizer.SpeedUI then
        SpeedCustomizer.SpeedUI.ToggleBtn.Text = "OFF"
        SpeedCustomizer.SpeedUI.Header.BackgroundColor3 = Color3.fromRGB(150, 30, 30)
    end
    
    if SpeedCustomizer.HeartbeatConn then
        SpeedCustomizer.HeartbeatConn:Disconnect()
        SpeedCustomizer.HeartbeatConn = nil
    end
    
    if SpeedCustomizer.SpeedUI then
        SpeedCustomizer.SpeedUI.ScreenGui.Enabled = false
    end
end

InfiniteJump = {
    Enabled = false,
    JUMP_POWER = 50,       
    COOLDOWN = 0.15,       
    lastJump = 0,
    JumpConnection = nil
}

local function handleJumpRequest()
    if not InfiniteJump.Enabled then return end
    
    local character = lp.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if hrp and humanoid then
        if humanoid.FloorMaterial == Enum.Material.Air then
            local now = tick()
            if now - InfiniteJump.lastJump >= InfiniteJump.COOLDOWN then
                InfiniteJump.lastJump = now
                hrp.Velocity = Vector3.new(hrp.Velocity.X, InfiniteJump.JUMP_POWER, hrp.Velocity.Z)
            end
        end
    end
end

local function enableInfJump()
    if InfiniteJump.Enabled then return end
    
    InfiniteJump.Enabled = true
    
    InfiniteJump.JumpConnection = UserInputService.JumpRequest:Connect(handleJumpRequest)
end

local function disableInfJump()
    if not InfiniteJump.Enabled then return end
    
    InfiniteJump.Enabled = false
    
    if InfiniteJump.JumpConnection then
        InfiniteJump.JumpConnection:Disconnect()
        InfiniteJump.JumpConnection = nil
    end
end

local Cebo = { Conn = nil, Circle = nil, Align = nil, Attach = nil }
AddToggle("Combat", "Hit Circle", false, function(active)
    if active then
        local char = lp.Character or lp.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        Cebo.Attach = Instance.new("Attachment", hrp)
        Cebo.Align = Instance.new("AlignOrientation", hrp)
        Cebo.Align.Attachment0 = Cebo.Attach
        Cebo.Align.Mode = Enum.OrientationAlignmentMode.OneAttachment
        Cebo.Align.RigidityEnabled = true
        Cebo.Circle = create("Part", {
            Shape = Enum.PartType.Cylinder, 
            Material = Enum.Material.Neon, 
            Size = Vector3.new(0.05, 14.5, 14.5), 
            Color = Color3.new(1,0,0), 
            CanCollide = false, 
            Massless = true, 
            Parent = Workspace
        })
        local weld = Instance.new("Weld")
        weld.Part0 = hrp
        weld.Part1 = Cebo.Circle
        weld.C0 = CFrame.new(0, -1, 0) * CFrame.Angles(0, 0, math.rad(90))
        weld.Parent = Cebo.Circle
        
        Cebo.Conn = RunService.RenderStepped:Connect(function()
            local target, dmin = nil, 7.25
            for _, p in ipairs(Players:GetPlayers()) do 
                if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then 
                    local d = (p.Character.HumanoidRootPart.Position - hrp.Position).Magnitude 
                    if d <= dmin then 
                        target = p.Character.HumanoidRootPart
                        dmin = d 
                    end 
                end 
            end
            if target then 
                char.Humanoid.AutoRotate = false
                Cebo.Align.Enabled = true
                Cebo.Align.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(target.Position.X, hrp.Position.Y, target.Position.Z))
                local t = char:FindFirstChild("Bat") or char:FindFirstChild("Medusa")
                if t then 
                    t:Activate() 
                end
            else 
                Cebo.Align.Enabled = false
                char.Humanoid.AutoRotate = true 
            end
        end)
    else 
        if Cebo.Conn then 
            Cebo.Conn:Disconnect() 
        end 
        if Cebo.Circle then 
            Cebo.Circle:Destroy() 
        end 
        if Cebo.Align then 
            Cebo.Align:Destroy() 
        end 
        if Cebo.Attach then 
            Cebo.Attach:Destroy() 
        end 
        if lp.Character and lp.Character:FindFirstChild("Humanoid") then 
            lp.Character.Humanoid.AutoRotate = true 
        end 
    end
end)

AddToggle("Combat", "Bat Aimbot", false, function(v)
    if v then
        enableBatAimbot()
    else
        disableBatAimbot()
    end
end)

AddToggle("Combat", "Auto Steal", false, function(v)
    if v then
        enableAutoSteal()
    else
        disableAutoSteal()
    end
end)

AddToggle("Combat", "Speed Customizer", false, function(v)
    if v then
        enableSpeedCustomizer()
    else
        disableSpeedCustomizer()
    end
end)

AddToggle("Combat", "Inf Jump", false, function(v)
    if v then
        enableInfJump()
    else
        disableInfJump()
    end
end)

AddToggle("Combat", "Auto Tp", false, function(v)
    if v then
        enableAutoTp()
    else
        disableAutoTp()
    end
end)

AddToggle("Protect", "Optimizer", false, function(v)
    if v then 
        Workspace.Terrain.WaterWaveSize = 0
        game:GetService("Lighting").GlobalShadows = false
        for _, obj in pairs(game:GetDescendants()) do 
            if obj:IsA("BasePart") then 
                obj.Material = Enum.Material.Plastic 
            elseif obj:IsA("Decal") then 
                obj.Transparency = 1 
            end 
        end 
    end
end)

AddToggle("Protect", "Anti-Ragdoll", false, function(v)
    if v then
        enableAntiRagdoll()
    else
        disableAntiRagdoll()
    end
end)

local AntiEffects = { Enabled = false, DisabledRemotes = {}, Watcher = nil, Keywords = {"effect", "vfx", "fx", "particle", "camera", "shake", "blur", "flash", "visual", "ui", "item"} }
AddToggle("Protect", "Anti Bee & Disco", false, function(v)
    AntiEffects.Enabled = v
    if v then 
        AntiEffects.Watcher = ReplicatedStorage.DescendantAdded:Connect(function(r) 
            if AntiEffects.Enabled and r:IsA("RemoteEvent") then 
                for _, k in pairs(AntiEffects.Keywords) do 
                    if r.Name:lower():find(k) then 
                        for _, c in pairs(getconnections(r.OnClientEvent)) do 
                            if c.Disable then 
                                c:Disable() 
                            end 
                        end 
                        break 
                    end 
                end 
            end 
        end)
    else 
        if AntiEffects.Watcher then 
            AntiEffects.Watcher:Disconnect() 
        end 
    end
end)

AddToggle("Protect", "Auto Play", false, function(v)
    if v then
        enableAutoPlay()
    else
        disableAutoPlay()
    end
end)

AddToggle("Visual", "Xray Base", false, function(v)
    if v then
        enableXrayBase()
    else
        disableXrayBase()
    end
end)

AddToggle("Visual", "No Anim", false, function(v)
    if v then
        enableNoAnim()
    else
        disableNoAnim()
    end
end)

AddToggle("Visual", "Player ESP", false, function(v)
    if v then
        enableESP()
    else
        disableESP()
    end
end)

AddToggle("Settings", "Lock UI Positions", false, function(v)
    LockUIMove = v
end)

AddButton("Settings", "Save Config", saveConfig)

local function applyExtraConfig()
    if Config.Other then
        SpeedCustomizer.Enabled = Config.Other.SpeedEnabled or false
        AutoPlay.Enabled = Config.Other.AutoPlayEnabled or false
        AutoPlay.Active = Config.Other.AutoPlayActive or false
        AutoTp.Enabled = Config.Other.AutoTpEnabled or false
        BatAimbot.Enabled = Config.Other.BatAimbotEnabled or false
        BatAimbot.Active = Config.Other.BatAimbotActive or false
        AntiRagdoll.Enabled = Config.Other.RagdollEnabled or false
        AutoSteal.Enabled = Config.Other.AutoStealEnabled or false
    end
    
    if Config.Speeds then
        SpeedCustomizer.SpeedValue = Config.Speeds.Speed or 58
        SpeedCustomizer.StealValue = Config.Speeds.Steal or 29
    end

    if ToggleStates["Speed Customizer"] and SpeedCustomizer.Enabled then
        enableSpeedCustomizer()
    end
    
    if ToggleStates["Auto Play"] and AutoPlay.Enabled then
        enableAutoPlay()
        if AutoPlay.Active then
            AutoPlay.btn.Text = "AutoPlay: ON"
        end
    end
    
    if ToggleStates["Auto Tp"] and AutoTp.Enabled then
        enableAutoTp()
    end
    
    if ToggleStates["Bat Aimbot"] and BatAimbot.Enabled then
        enableBatAimbot()
        if BatAimbot.Active then
            BatAimbot.btn.Text = "AimBot: ON"
        end
    end
    
    if ToggleStates["Anti-Ragdoll"] and AntiRagdoll.Enabled then
        enableAntiRagdoll()
    end
    
    if ToggleStates["Auto Steal"] and AutoSteal.Enabled then
        enableAutoSteal()
    end
end

applyExtraConfig()

local function drag(f)
    local d, ds, sp
    f.InputBegan:Connect(function(i) 
        if LockUIMove then return end
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then 
            d = true
            ds = i.Position
            sp = f.Position
        end 
    end)
    UserInputService.InputChanged:Connect(function(i) 
        if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then 
            local delta = i.Position - ds 
            f.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y) 
        end 
    end)
    f.InputEnded:Connect(function(i) 
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then 
            d = false 
        end 
    end)
end
drag(MainFrame)
drag(ToggleIcon)
ToggleIcon.MouseButton1Click:Connect(function() 
    MainFrame.Visible = not MainFrame.Visible 
end)

-- ================= OPTIMIZATION PATCH =================

-- Replace Anti-Ragdoll loop
if AntiRagdoll then
    if AntiRagdoll.heartbeatConn then AntiRagdoll.heartbeatConn:Disconnect() end
    AntiRagdoll.heartbeatConn = game:GetService("RunService").Heartbeat:Connect(function()
        local char = game.Players.LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end

        local state = hum:GetState()
        if state == Enum.HumanoidStateType.Ragdoll 
        or state == Enum.HumanoidStateType.FallingDown then
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
    end)
end

-- Replace AutoSteal loop
if AutoSteal then
    if AutoSteal.heartbeatConn then AutoSteal.heartbeatConn:Disconnect() end
    AutoSteal.heartbeatConn = task.spawn(function()
        while AutoSteal.Enabled do
            if not AutoSteal.isStealing then
                local prompt = findNearestPrompt()
                if prompt then
                    executeSteal(prompt)
                end
            end
            task.wait(0.2)
        end
    end)
end

-- Fix Optimizer freeze
task.spawn(function()
    local count = 0
    for _, obj in pairs(game:GetDescendants()) do
        count += 1

        if obj:IsA("BasePart") then 
            obj.Material = Enum.Material.Plastic 
        elseif obj:IsA("Decal") then 
            obj.Transparency = 1 
        end

        if count % 200 == 0 then
            task.wait()
        end
    end
end)

-- ======================================================
