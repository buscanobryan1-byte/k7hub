-- =======================
-- PASTE YOUR FULL SCRIPT HERE
-- =======================

--// ESP PLAYERS AZUL (INCLUYE INVISIBLES)

local Players = game:GetService("Players")
local lp = Players.LocalPlayer

local espConnections = {}
local espEnabled = false

local function createESP(plr)
        if plr == lp then return end
        if not plr.Character then return end
        if plr.Character:FindFirstChild("ESP_BLUE") then return end

        local char = plr.Character
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        if not (hrp and head) then return end

        --------------------------------------------------
        -- HIGHLIGHT AZUL
        --------------------------------------------------

        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP_BLUE"
        highlight.FillColor = Color3.fromRGB(255, 200, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 200, 0)
        highlight.FillTransparency = 0.2
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = char

        --------------------------------------------------
        -- HITBOX AZUL
        --------------------------------------------------

        local hitbox = Instance.new("BoxHandleAdornment")
        hitbox.Name = "ESP_Hitbox"
        hitbox.Adornee = hrp
        hitbox.Size = Vector3.new(4,6,2)
        hitbox.Color3 = Color3.fromRGB(255, 200, 0)
        hitbox.Transparency = 0.5
        hitbox.AlwaysOnTop = true
        hitbox.ZIndex = 10
        hitbox.Parent = char

        --------------------------------------------------
        -- NOMBRE AZUL
        --------------------------------------------------

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP_Name"
        billboard.Adornee = head
        billboard.Size = UDim2.new(0,200,0,50)
        billboard.StudsOffset = Vector3.new(0,3,0)
        billboard.AlwaysOnTop = true
        billboard.Parent = char

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1,0,1,0)
        label.BackgroundTransparency = 1
        label.Text = plr.DisplayName or plr.Name
        label.TextColor3 = Color3.fromRGB(255, 200, 0)
        label.Font = Enum.Font.GothamBold
        label.TextScaled = true
        label.TextStrokeTransparency = 0.6
        label.TextStrokeColor3 = Color3.fromRGB(0,0,0)
        label.Parent = billboard
end

local function removeESP(plr)
        if not plr.Character then return end

        local char = plr.Character

        local highlight = char:FindFirstChild("ESP_BLUE")
        if highlight then highlight:Destroy() end

        local hitbox = char:FindFirstChild("ESP_Hitbox")
        if hitbox then hitbox:Destroy() end

        local name = char:FindFirstChild("ESP_Name")
        if name then name:Destroy() end
end

function toggleESPPlayers(enable)
        espEnabled = enable

        if enable then
                for _, plr in ipairs(Players:GetPlayers()) do
                        if plr ~= lp then
                                if plr.Character then
                                        createESP(plr)
                                end

                                local conn = plr.CharacterAdded:Connect(function()
                                        task.wait(0.2)
                                        if espEnabled then
                                                createESP(plr)
                                        end
                                end)

                                table.insert(espConnections, conn)
                        end
                end

                local playerAddedConn = Players.PlayerAdded:Connect(function(plr)
                        if plr == lp then return end

                        local charAddedConn = plr.CharacterAdded:Connect(function()
                                task.wait(0.2)
                                if espEnabled then
                                        createESP(plr)
                                end
                        end)

                        table.insert(espConnections, charAddedConn)
                end)

                table.insert(espConnections, playerAddedConn)

        else
                for _, plr in ipairs(Players:GetPlayers()) do
                        removeESP(plr)
                end

                for _, conn in ipairs(espConnections) do
                        if conn and conn.Connected then
                                conn:Disconnect()
                        end
                end

                espConnections = {}
        end
end

--// SERVICES

local Players = game:GetService("Players")

local 

--// 🔥 ADVANCED AUTOPLAY (SMOOTH + WAYPOINT EDITOR SUPPORT)

AutoPlay = {
    Enabled = false,
    Active = false,
    Waypoints = {},
    Index = 1,
    renderConn = nil,
    lastUpdate = 0,
    UPDATE_RATE = 0.03
}

-- Example waypoint structure (replace with your editor values)
-- Format supports p1–p5 with X/Z offsets
AutoPlay.Waypoints = {
    {x = 0, z = 60},
    {x = 10, z = 40},
    {x = -10, z = 20},
    {x = 0, z = -40},
    {x = 0, z = -60}
}

local function getWaypointPosition(hrp, wp)
    return hrp.Position + Vector3.new(wp.x, 0, wp.z)
end

local function moveTo(hrp, target, speed)
    local dir = target - hrp.Position
    local dist = dir.Magnitude

    if dist > 0 then
        local vel = dir.Unit * speed
        hrp.AssemblyLinearVelocity = Vector3.new(
            vel.X,
            hrp.AssemblyLinearVelocity.Y,
            vel.Z
        )
    end

    return dist
end

function enableAutoPlay()
    if AutoPlay.Enabled then return end

    AutoPlay.Enabled = true
    AutoPlay.Active = false
    AutoPlay.Index = 1

    if AutoPlay.renderConn then
        AutoPlay.renderConn:Disconnect()
    end

    AutoPlay.renderConn = RunService.RenderStepped:Connect(function(dt)
    _last += dt
    if _last < _rate then return end
    _last = 0
    local _last=0
    local _rate=0.03

        if not AutoPlay.Enabled or not AutoPlay.Active then return end

        AutoPlay.lastUpdate += dt
        if AutoPlay.lastUpdate < AutoPlay.UPDATE_RATE then return end
        AutoPlay.lastUpdate = 0

        local char = player.Character
        if not char then return end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local wp = AutoPlay.Waypoints[AutoPlay.Index]
        if not wp then return end

        local target = getWaypointPosition(hrp, wp)
        local dist = moveTo(hrp, target, 60)

        if dist < 4 then
            AutoPlay.Index += 1

            if AutoPlay.Index > #AutoPlay.Waypoints then
                AutoPlay.Index = 1 -- loop instead of stop
            end
        end
    end)
end

function disableAutoPlay()
    AutoPlay.Enabled = false
    AutoPlay.Active = false
    AutoPlay.Index = 1

    if AutoPlay.renderConn then
        AutoPlay.renderConn:Disconnect()
        AutoPlay.renderConn = nil
    end

    local char = player.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.AssemblyLinearVelocity = Vector3.zero
        end
    end
end


RunService = game:GetService("RunService")

local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Hitbox Expander (controlado por toggle "Aimbot")
local hitboxExpanded = false
local originalHRPSizes = {}          -- para guardar y restaurar
local hitboxPlayerAddedConn = nil

local character, hrp, hum

--// MELEE AIMBOT (INTEGRADO AL HUB)
-- Insertar DESPUÃS de las definiciones de servicios y ANTES de setupCharacter

local MELEE_RANGE = 45
local MELEE_ONLY_ENEMIES = true  -- Puedes hacer toggle si quieres, pero por ahora fijo

local meleeEnabled = false
local meleeConnection
local meleeAlignOrientation
local meleeAttachment

local function isValidMeleeTarget(humanoid, rootPart)
    if not (humanoid and rootPart) then return false end
    if humanoid.Health <= 0 then return false end

    if MELEE_ONLY_ENEMIES then
        local targetPlayer = Players:GetPlayerFromCharacter(humanoid.Parent)
        if not targetPlayer or targetPlayer == player then
            return false
        end
    end

    return true
end

local function getClosestMeleeTarget(hrp)
    local closest
    local minDist = MELEE_RANGE

    for _, p in ipairs(Players:GetPlayers()) do
        if p == player then continue end
        local char = p.Character
        if not char then continue end

        local targetHrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")

        if isValidMeleeTarget(hum, targetHrp) then
            local dist = (targetHrp.Position - hrp.Position).Magnitude
            if dist < minDist then
                minDist = dist
                closest = targetHrp
            end
        end
    end

    return closest
end

local function createMeleeAimbot(char)
    local hrp = char:WaitForChild("HumanoidRootPart", 8)
    local humanoid = char:WaitForChild("Humanoid", 8)

    if not (hrp and humanoid) then return end

    -- Cleanup viejo
    if meleeAlignOrientation then
        pcall(function() meleeAlignOrientation:Destroy() end)
    end
    if meleeAttachment then
        pcall(function() meleeAttachment:Destroy() end)
    end

    meleeAttachment = Instance.new("Attachment")
    meleeAttachment.Parent = hrp

    meleeAlignOrientation = Instance.new("AlignOrientation")
    meleeAlignOrientation.Attachment0 = meleeAttachment
    meleeAlignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
    meleeAlignOrientation.RigidityEnabled = true
    meleeAlignOrientation.MaxTorque = 100000
    meleeAlignOrientation.Responsiveness = 200
    meleeAlignOrientation.Parent = hrp

    if meleeConnection then
        meleeConnection:Disconnect()
    end

    meleeConnection = -- removed duplicate loop
()
        if not char.Parent or not meleeEnabled then return end

        local target = getClosestMeleeTarget(hrp)

        if target then
            humanoid.AutoRotate = false
            meleeAlignOrientation.Enabled = true
            local targetPos = Vector3.new(target.Position.X, hrp.Position.Y, target.Position.Z)
            meleeAlignOrientation.CFrame = CFrame.lookAt(hrp.Position, targetPos)
        else
            meleeAlignOrientation.Enabled = false
            humanoid.AutoRotate = true
        end
    end)
end

local function disableMeleeAimbot()
    meleeEnabled = false

    if meleeConnection then
        meleeConnection:Disconnect()
        meleeConnection = nil
    end

    if meleeAlignOrientation then
        meleeAlignOrientation.Enabled = false
        pcall(function() meleeAlignOrientation:Destroy() end)
        meleeAlignOrientation = nil
    end

    if character and character:FindFirstChild("Humanoid") then
        character.Humanoid.AutoRotate = true
    end

    if meleeAttachment then
        pcall(function() meleeAttachment:Destroy() end)
        meleeAttachment = nil
    end
end

--// ð¥ NEW ADVANCED ANTI RAGDOLL

local antiRagdollMode = nil
local ragdollConnections = {}
local cachedCharData = {}

local function cacheCharacterData()
    local char = player.Character
    if not char then return false end

    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")

    if not hum or not root then return false end

    cachedCharData = {
        character = char,
        humanoid = hum,
        root = root,
        originalWalkSpeed = hum.WalkSpeed,
        originalJumpPower = hum.JumpPower,
        isFrozen = false
    }

    return true
end

local function disconnectAllRagdoll()
    for _, conn in ipairs(ragdollConnections) do
        if typeof(conn) == "RBXScriptConnection" then
            pcall(function() conn:Disconnect() end)
        end
    end
    ragdollConnections = {}
end

local function isRagdolled()
    if not cachedCharData.humanoid then return false end

    local hum = cachedCharData.humanoid
    local state = hum:GetState()

    if state == Enum.HumanoidStateType.Physics
    or state == Enum.HumanoidStateType.Ragdoll
    or state == Enum.HumanoidStateType.FallingDown then
        return true
    end

    local endTime = player:GetAttribute("RagdollEndTime")
    if endTime then
        local now = workspace:GetServerTimeNow()
        if (endTime - now) > 0 then
            return true
        end
    end

    return false
end

local function removeRagdollConstraints()
    if not cachedCharData.character then return end

    for _, descendant in ipairs(cachedCharData.character:GetDescendants()) do
        if descendant:IsA("BallSocketConstraint") or
           (descendant:IsA("Attachment") and descendant.Name:find("RagdollAttachment")) then
            pcall(function()
                descendant:Destroy()
            end)
        end
    end
end

local function forceExitRagdoll()
    if not cachedCharData.humanoid or not cachedCharData.root then return end

    local hum = cachedCharData.humanoid
    local root = cachedCharData.root

    pcall(function()
        local now = workspace:GetServerTimeNow()
        player:SetAttribute("RagdollEndTime", now)
    end)

    if hum.Health > 0 then
        hum:ChangeState(Enum.HumanoidStateType.Running)
    end

    root.Anchored = false
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
end

local function antiRagdollLoop()
    while antiRagdollMode do
        task.wait()

        if isRagdolled() then
            removeRagdollConstraints()
            forceExitRagdoll()
        end

        -- ð¥ AUTO CAMERA FIX
        local cam = workspace.CurrentCamera
        if cam and cachedCharData.humanoid then
            if cam.CameraSubject ~= cachedCharData.humanoid then
                cam.CameraSubject = cachedCharData.humanoid
            end
        end
    end
end

function toggleAntiRagdoll(enable)
    if enable then
        disconnectAllRagdoll()
        if not cacheCharacterData() then return end

        antiRagdollMode = "v1"

        local charConn = player.CharacterAdded:Connect(function()
            task.wait(0.5)
            if antiRagdollMode then
                cacheCharacterData()
            end
        end)

        table.insert(ragdollConnections, charConn)
        task.spawn(antiRagdollLoop)

    else
        antiRagdollMode = nil
        disconnectAllRagdoll()
        cachedCharData = {}
    end
end

--// SETUP CHARACTER

local function setupCharacter(char)

    character = char

    hrp = character:WaitForChild("HumanoidRootPart")

    hum = character:WaitForChild("Humanoid")

    -- ð¥ NUEVO: Recrear Melee Aimbot si estÃ¡ activado
    if meleeEnabled then
        task.spawn(function()
            task.wait(0.3)
            createMeleeAimbot(char)
        end)
    end

end

if player.Character then

    setupCharacter(player.Character)

end

player.CharacterAdded:Connect(setupCharacter)

--// GUI

local gui = Instance.new("ScreenGui")

gui.Name = "BoosterCustomizer"

gui.ResetOnSpawn = false

gui.Enabled = false -- ð IMPORTANTE (empieza oculto)

gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")

main.Size = UDim2.new(0,200,0,185)

main.Position = UDim2.new(0.5,-100,0.15,0)

main.BackgroundColor3 = Color3.fromRGB(0,0,0)

main.BackgroundTransparency = 0.35

main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0,10)

local stroke = Instance.new("UIStroke", main)

stroke.Color = Color3.fromRGB(255, 200, 0)

stroke.Thickness = 2

--// DRAG HANDLE (barra superior)

local dragHandle = Instance.new("Frame")

dragHandle.Size = UDim2.new(1,0,0,30)

dragHandle.Position = UDim2.new(0,0,0,0)

dragHandle.BackgroundTransparency = 1

dragHandle.Parent = main

--// DRAGGING LOGIC ESTABLE (PC + MOBILE)

local dragging = false

local dragInput = nil

local dragStart = Vector2.new()

local startPos = Vector2.new()

local function update(input)

    local delta = input.Position - dragStart

    main.Position = UDim2.new(

        0,

        startPos.X + delta.X,

        0,

        startPos.Y + delta.Y

    )

end

dragHandle.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1

    or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true

        dragInput = input

        dragStart = input.Position

        startPos = Vector2.new(main.AbsolutePosition.X, main.AbsolutePosition.Y)

        input.Changed:Connect(function()

            if input.UserInputState == Enum.UserInputState.End then

                dragging = false

                dragInput = nil

            end

        end)

    end

end)

dragHandle.InputChanged:Connect(function(input)

    if input == dragInput and dragging then

        update(input)

    end

end)

--// TITLE

local title = Instance.new("TextLabel")

title.Size = UDim2.new(1,0,0,30)

title.Position = UDim2.new(0,10,0,0)

title.BackgroundTransparency = 1

title.Text = "Booster Customizer"

title.Font = Enum.Font.GothamBold

title.TextSize = 15

title.TextColor3 = Color3.fromRGB(255, 200, 0)

title.TextXAlignment = Enum.TextXAlignment.Left

title.Parent = main

--// ACTIVATE BUTTON

local activate = Instance.new("TextButton")

activate.Size = UDim2.new(1,-20,0,30)

activate.Position = UDim2.new(0,10,0,35)

activate.BackgroundColor3 = Color3.fromRGB(25,25,25)

activate.TextColor3 = Color3.fromRGB(255,255,255)

activate.Text = "OFF"

activate.Font = Enum.Font.GothamBold

activate.TextSize = 14

activate.Parent = main

Instance.new("UICorner", activate).CornerRadius = UDim.new(0,8)

local activateStroke = Instance.new("UIStroke", activate)

activateStroke.Color = Color3.fromRGB(255, 200, 0)

--// CREATE ROW FUNCTION

local function createRow(text,posY,default)

    local label = Instance.new("TextLabel")

    label.Size = UDim2.new(0.55,0,0,25)

    label.Position = UDim2.new(0,10,0,posY)

    label.BackgroundTransparency = 1

    label.Text = text

    label.Font = Enum.Font.GothamBold

    label.TextSize = 13

    label.TextColor3 = Color3.fromRGB(255,255,255)

    label.TextXAlignment = Enum.TextXAlignment.Left

    label.Parent = main

    local box = Instance.new("TextBox")

    box.Size = UDim2.new(0.4,0,0,25)

    box.Position = UDim2.new(0.55,5,0,posY)

    box.BackgroundColor3 = Color3.fromRGB(20,20,20)

    box.TextColor3 = Color3.fromRGB(255,255,255)

    box.Text = tostring(default)

    box.Font = Enum.Font.GothamBold

    box.TextSize = 13

    box.ClearTextOnFocus = false

    box.Parent = main

    Instance.new("UICorner", box).CornerRadius = UDim.new(0,6)

    local s = Instance.new("UIStroke", box)

    s.Color = Color3.fromRGB(255, 200, 0)

    return box

end

--// ROWS

local speedBox = createRow("Speed",75,53)

local stealBox = createRow("Steal Speed",110,29)

local jumpBox = createRow("Jump",145,60)

--// VALUES

local active = false

local speedConnection

local speedNoStealValue = 52

local speedStealValue = 28

local jumpValue = 50

--// SANITIZE

local function applyInput(box,min,max,default)

    box.FocusLost:Connect(function()

        local text = box.Text:gsub("%D","")

        local num = tonumber(text) or default

        num = math.clamp(num,min,max)

        box.Text = tostring(num)

    end)

end

applyInput(speedBox,15,200,53)

applyInput(stealBox,15,200,29)

applyInput(jumpBox,50,200,60)

--// BUTTON LOGIC

activate.MouseButton1Click:Connect(function()

    active = not active

    if active then

        activate.Text = "ON"

        activate.BackgroundColor3 = Color3.fromRGB(255, 200, 0)

        speedConnection = RunService.Heartbeat:Connect(function()
    local _last=0
    local _rate=0.03


            if character and hrp and hum then

                speedNoStealValue = tonumber(speedBox.Text) or 53

                speedStealValue = tonumber(stealBox.Text) or 29

                jumpValue = tonumber(jumpBox.Text) or 60

                local moveDirection = hum.MoveDirection

                if moveDirection.Magnitude > 0 then

                    local isSteal = hum.WalkSpeed < 25

                    local currentSpeed = isSteal and speedStealValue or speedNoStealValue

                    hrp.AssemblyLinearVelocity = Vector3.new(

                        moveDirection.X * currentSpeed,

                        hrp.AssemblyLinearVelocity.Y,

                        moveDirection.Z * currentSpeed

                    )

                end

            end

        end)

    else

        activate.Text = "OFF"

        activate.BackgroundColor3 = Color3.fromRGB(25,25,25)

        if speedConnection then

            speedConnection:Disconnect()

            speedConnection = nil

        end

    end

end)

--// JUMP

UserInputService.JumpRequest:Connect(function()
    if not character or not hum or not hrp then return end

    local state = hum:GetState()

    -- ð¹ JUMP BOOSTER (solo en el suelo)
    if active then
        if state == Enum.HumanoidStateType.Running
        or state == Enum.HumanoidStateType.Landed then

            local jumpPower = tonumber(jumpBox.Text) or 70

            hrp.AssemblyLinearVelocity = Vector3.new(
                hrp.AssemblyLinearVelocity.X,
                jumpPower,
                hrp.AssemblyLinearVelocity.Z
            )
        end
    end

    -- ð¹ INFINITE JUMP (siempre 50 fijo)
    if infiniteJumpEnabled then
        hrp.AssemblyLinearVelocity = Vector3.new(
            hrp.AssemblyLinearVelocity.X,
            50,
            hrp.AssemblyLinearVelocity.Z
        )
    end
end)

--// Warp Duels - RADIO CUADRADO ACOTADO SUBIDO (Y = -2.5)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local lp = Players.LocalPlayer
local RunService = game:GetService("RunService")

local RunService = game:GetService("RunService")

local spinForce

local function startSpinBody()
    local char = lp.Character
    if not char then return end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if spinForce then return end

    spinForce = Instance.new("BodyAngularVelocity")
    spinForce.Name = "SpinForce"
    spinForce.AngularVelocity = Vector3.new(0, 25, 0) -- velocidad estilo 22s
    spinForce.MaxTorque = Vector3.new(0, math.huge, 0)
    spinForce.P = 1250
    spinForce.Parent = root
end

local function stopSpinBody()
    if spinForce then
        spinForce:Destroy()
        spinForce = nil
    end
end

local spinGui
local spinActive = false

local function createSpinButton()
    if spinGui then return end

    spinGui = Instance.new("ScreenGui")
    spinGui.Name = "SpinButtonGui"
    spinGui.Parent = game:GetService("CoreGui")

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0,140,0,50)
    button.Position = UDim2.new(0.5,-70,0.75,0)
    button.Text = "SPIN"
    button.Font = Enum.Font.GothamBold
    button.TextSize = 18
    button.TextColor3 = Color3.new(1,1,1)
    button.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    button.Parent = spinGui

    -- Esquinas curvas
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,16)
    corner.Parent = button

    -- Draggable
    button.Active = true
    button.Draggable = true

    button.MouseButton1Click:Connect(function()
        spinActive = not spinActive

        if spinActive then
            button.Text = "SPINNING"
            button.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
            startSpinBody()
        else
            button.Text = "SPIN"
            button.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
            stopSpinBody()
        end
    end)
end

local function removeSpinButton()
    stopSpinBody()
    spinActive = false

    if spinGui then
        spinGui:Destroy()
        spinGui = nil
    end
end

task.wait(1)

--////////////////////////////////////////////////////
-- SCREEN GUI
--////////////////////////////////////////////////////
local sg = Instance.new("ScreenGui")
sg.Name = "Warp"
sg.ResetOnSpawn = false
sg.Parent = lp:WaitForChild("PlayerGui")

-- Barra de progreso Auto Steal
local progressBarBg = Instance.new("Frame")
progressBarBg.Size = UDim2.new(0,240,0,10)
progressBarBg.Position = UDim2.new(0.5,-120,0,52)
progressBarBg.BackgroundColor3 = Color3.fromRGB(15,15,15)
progressBarBg.BackgroundTransparency = 0.25
progressBarBg.Visible = false
progressBarBg.Parent = sg
Instance.new("UICorner", progressBarBg).CornerRadius = UDim.new(0,8)

local progressFill = Instance.new("Frame")
progressFill.Size = UDim2.new(0,0,1,0)
progressFill.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
progressFill.Parent = progressBarBg
Instance.new("UICorner", progressFill).CornerRadius = UDim.new(0,8)

local percentLabel = Instance.new("TextLabel")
percentLabel.Size = UDim2.new(1,0,1,0)
percentLabel.BackgroundTransparency = 1
percentLabel.Font = Enum.Font.GothamBold
percentLabel.TextSize = 11
percentLabel.TextColor3 = Color3.fromRGB(220,220,220)
percentLabel.Text = "0%"
percentLabel.Parent = progressBarBg

-- RADIO CUADRADO ACOTADO (subido a Y = -2.5)
local stealSquarePart = nil
local circleConnection = nil

local function hideSquare()
    if stealSquarePart then
        stealSquarePart:Destroy()
        stealSquarePart = nil
    end
end

local grabRadius = 50

local function createOrUpdateSquare(radius)
    if not stealSquarePart then
        stealSquarePart = Instance.new("Part")
        stealSquarePart.Name = "StealCircle"
        stealSquarePart.Anchored = true
        stealSquarePart.CanCollide = false
        stealSquarePart.Transparency = 0.7
        stealSquarePart.Material = Enum.Material.Neon
        stealSquarePart.Color = Color3.fromRGB(255, 200, 0)

        stealSquarePart.Shape = Enum.PartType.Cylinder

        -- IMPORTANTE: el cilindro necesita rotaciÃ³n

        stealSquarePart.Size = Vector3.new(0.05, radius*2, radius*2)

        stealSquarePart.Parent = workspace
    else
        stealSquarePart.Size = Vector3.new(0.05, radius*2, radius*2)
    end
end

local function updateSquarePosition()
    if stealSquarePart and lp.Character then
        local root = lp.Character:FindFirstChild("HumanoidRootPart")
        if root then
            stealSquarePart.CFrame =
                CFrame.new(root.Position + Vector3.new(0, -2.5, 0))
                * CFrame.Angles(0, 0, math.rad(90))
        end
    end
end

--////////////////////////////////////////////////////
-- TOP BAR (FPS + PING)
--////////////////////////////////////////////////////
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(0,240,0,32)
topBar.Position = UDim2.new(0.5,-120,0,15)
topBar.BackgroundColor3 = Color3.fromRGB(15,15,15)
topBar.BackgroundTransparency = 0.15
topBar.Parent = sg
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0,10)

local strokeTop = Instance.new("UIStroke", topBar)
strokeTop.Color = Color3.fromRGB(255, 200, 0)

local topLabel = Instance.new("TextLabel")
topLabel.Size = UDim2.new(1,0,1,0)
topLabel.BackgroundTransparency = 1
topLabel.Font = Enum.Font.GothamBold
topLabel.TextSize = 14
topLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
topLabel.Parent = topBar

local fps, framesCount, last = 60, 0, tick()
RunService.Rend-- removed duplicate loop
unt += 1
    if tick() - last >= 1 then
        fps = framesCount
        framesCount = 0
        last = tick()
    end
    local ping = 0
    local network = Stats:FindFirstChild("Network")
    if network and network:FindFirstChild("ServerStatsItem") then
        local dataPing = network.ServerStatsItem:FindFirstChild("Data Ping")
        if dataPing then ping = math.floor(dataPing:GetValue()) end
    end
    topLabel.Text = "Warp | "..fps.." FPS | "..ping.." ms"
end)

-- TOGGLE BUTTON (W)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0,55,0,55)
toggleBtn.Position = UDim2.new(1,-70,0,70)
toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Text = "W"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 32
toggleBtn.TextColor3 = Color3.fromRGB(255, 200, 0)
toggleBtn.Parent = sg
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0,14)

-- HUB PANEL
local HUB_WIDTH = 260
local HUB_HEIGHT = 320
local hub = Instance.new("Frame")
hub.Size = UDim2.new(0,HUB_WIDTH,0,HUB_HEIGHT)
hub.Position = UDim2.new(0,-350,0.5,-HUB_HEIGHT/2)
hub.BackgroundColor3 = Color3.fromRGB(0,0,0)
hub.BackgroundTransparency = 0.25
hub.Parent = sg
Instance.new("UICorner", hub).CornerRadius = UDim.new(0,14)

local strokeHub = Instance.new("UIStroke", hub)
strokeHub.Color = Color3.fromRGB(255, 200, 0)
strokeHub.Thickness = 2

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.55,0,0,40)
title.Position = UDim2.new(0,12,0,8)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.fromRGB(255, 200, 0)
title.Text = "Warp"
title.Parent = hub

local discordLabel = Instance.new("TextButton")
discordLabel.Size = UDim2.new(0.4,0,0,20)
discordLabel.Position = UDim2.new(0.55,6,0,14)
discordLabel.BackgroundTransparency = 1
discordLabel.TextColor3 = Color3.fromRGB(180,180,180)
discordLabel.TextSize = 12
discordLabel.Font = Enum.Font.Gotham
discordLabel.Text = "discord.gg/w24cF33xTn"
discordLabel.Parent = hub
discordLabel.MouseButton1Click:Connect(function()
    setclipboard("discord.gg/w24cF33xTn")
end)

-- SLOW FALL
local slowFallEnabled = false
-- removed duplicate loop
()
    if not slowFallEnabled then return end
    local char = lp.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return end
    if humanoid:GetState() == Enum.HumanoidStateType.Freefall then
        local velocity = root.AssemblyLinearVelocity
        if velocity.Y < -1 then
            root.AssemblyLinearVelocity = Vector3.new(velocity.X, velocity.Y * 0.5, velocity.Z)
        end
    end
end)

-- AUTO STEAL NEAREST + Radio cuadrado ajustable
local autoStealEnabled = false

local function findNearestSteal(root)
    local nearest, dist = nil, math.huge
    for _, desc in ipairs(workspace:GetDescendants()) do
        if desc:IsA("ProximityPrompt") and desc.Enabled and desc.ActionText == "Steal" then
            local part = desc.Parent:IsA("BasePart") and desc.Parent or desc:FindFirstAncestorWhichIsA("BasePart")
            if part then
                local d = (part.Position - root.Position).Magnitude
                if d < dist and d <= grabRadius then
                    nearest = desc
                    dist = d
                end
            end
        end
    end
    return nearest
end

local function resetBar(hide)
    progressFill.Size = UDim2.new(0,0,1,0)
    percentLabel.Text = "0%"
    if hide then
        progressBarBg.Visible = false
    end
end

--// LOCK TARGET GUI SYSTEM

LOCK_RADIUS = 70
local LOCK_SPEED = 50

local lockGui
local lockHbConn
local lockLv, lockAtt, lockGyro
local lockEnabled = false

local function getNearest()
        local char = lp.Character
        if not char then return nil end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil end

        local nearest = nil
        local nearestDist = LOCK_RADIUS

        for _,plr in ipairs(Players:GetPlayers()) do
                if plr ~= lp then
                        local pc = plr.Character
                        local phrp = pc and pc:FindFirstChild("HumanoidRootPart")
                        if phrp then
                                local d = (phrp.Position - hrp.Position).Magnitude
                                if d <= nearestDist then
                                        nearest = plr
                                        nearestDist = d
                                end
                        end
                end
        end

        return nearest
end

local function getBat()
        for _,t in ipairs(lp.Backpack:GetChildren()) do
                if t:IsA("Tool") and string.find(string.lower(t.Name),"bat",1,true) then
                        return t
                end
        end

        local char = lp.Character
        if char then
                for _,t in ipairs(char:GetChildren()) do
                        if t:IsA("Tool") and string.find(string.lower(t.Name),"bat",1,true) then
                                return t
                        end
                end
        end

        return nil
end

local function startLock()
        local char = lp.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        lockAtt = Instance.new("Attachment", hrp)

        lockLv = Instance.new("LinearVelocity", hrp)
        lockLv.Attachment0 = lockAtt
        lockLv.MaxForce = 50000
        lockLv.RelativeTo = Enum.ActuatorRelativeTo.World
        lockLv.Enabled = false

        lockGyro = Instance.new("AlignOrientation", hrp)
        lockGyro.Attachment0 = lockAtt
        lockGyro.MaxTorque = 50000
        lockGyro.Responsiveness = 120
        lockGyro.Enabled = false

        lockHbConn = RunService.-- removed duplicate loop
        local targetPlayer = getNearest()
                if not targetPlayer then
                        lockLv.Enabled = false
                        lockGyro.Enabled = false
                        return
                end

                local tChar = targetPlayer.Character
                local tHrp = tChar and tChar:FindFirstChild("HumanoidRootPart")
                if not tHrp then
                        lockLv.Enabled = false
                        lockGyro.Enabled = false
                        return
                end

                lockLv.Enabled = true
                lockGyro.Enabled = true

                local frontPos = tHrp.Position + tHrp.CFrame.LookVector * 2.2
                local dir = frontPos - hrp.Position

                if dir.Magnitude > 0.5 then
                        lockLv.VectorVelocity = dir.Unit * LOCK_SPEED
                else
                        lockLv.VectorVelocity = Vector3.zero
                end

                lockGyro.CFrame = CFrame.lookAt(hrp.Position, frontPos)

                local bat = getBat()
                if bat then
                        if bat.Parent ~= char then
                                char.Humanoid:EquipTool(bat)
                        end
                        bat:Activate()
                end
        end)
end

local function stopLock()
        if lockHbConn then lockHbConn:Disconnect() lockHbConn = nil end
        if lockLv then lockLv:Destroy() lockLv = nil end
        if lockGyro then lockGyro:Destroy() lockGyro = nil end
        if lockAtt then lockAtt:Destroy() lockAtt = nil end
end

function createLockGui()
        if lockGui then return end

        lockGui = Instance.new("ScreenGui")
        lockGui.Name = "KawatanBatTarget"
        lockGui.Parent = lp.PlayerGui

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0,140,0,50)
        btn.Position = UDim2.new(0.5,-70,0.75,0)
        btn.Text = "LOCK"
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 18
        btn.TextColor3 = Color3.new(1,1,1)
        btn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
        btn.Parent = lockGui

        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,16)

        btn.Active = true
        btn.Draggable = true

        btn.MouseButton1Click:Connect(function()
                lockEnabled = not lockEnabled

                if lockEnabled then
                        btn.Text = "LOCKED"
                        btn.BackgroundColor3 = Color3.fromRGB(200,0,0)
                        startLock()
                else
                        btn.Text = "LOCK"
                        btn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
                        stopLock()
                end
        end)
end

function destroyLockGui()
        lockEnabled = false
        stopLock()
        if lockGui then
                lockGui:Destroy()
                lockGui = nil
        end
end

-- MEDUSA SYSTEM GLOBAL
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer
local MEDUSA_RADIUS = 10
local SPAM_DELAY = 0.15

local medusaPart
local lastUse = 0
local AutoMedusaEnabled = false
local MedusaInitialized = false

local function InitMedusa()

    if MedusaInitialized then return end
    MedusaInitialized = true

    local function createRadius()
        if medusaPart then medusaPart:Destroy() end

        medusaPart = Instance.new("Part")
        medusaPart.Name = "MedusaRadius"
        medusaPart.Anchored = true
        medusaPart.CanCollide = false
        medusaPart.Transparency = 1
        medusaPart.Material = Enum.Material.Neon
        medusaPart.Color = Color3.fromRGB(255, 0, 0)
        medusaPart.Shape = Enum.PartType.Cylinder
        medusaPart.Size = Vector3.new(0.05, MEDUSA_RADIUS*2, MEDUSA_RADIUS*2)
        medusaPart.Parent = workspace
    end

    local function isMedusaEquipped()
        local char = lp.Character
        if not char then return nil end

        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == "Medusa's Head" then
                return tool
            end
        end
        return nil
    end

    createRadius()

    -- VISUAL
    RunService.RenderStepped:Conne-- removed duplicate loop
nabled then
            if medusaPart then medusaPart.Transparency = 1 end
            return
        end

        medusaPart.Transparency = 0.75

        local char = lp.Character
        if not char then return end

        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        medusaPart.CFrame =
            CFrame.new(root.Position + Vector3.new(0, -2.5, 0))
            * CFrame.Angles(0, 0, math.rad(90))
    end)

    -- SPAM
    RunService.Heartbeat:C-- removed duplicate loop
oMedusaEnabled then return end

        local char = lp.Character
        if not char then return end

        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        local tool = isMedusaEquipped()
        if not tool then return end

        if tick() - lastUse < SPAM_DELAY then return end

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp then
                local pChar = plr.Character
                local pRoot = pChar and pChar:FindFirstChild("HumanoidRootPart")
                if pRoot then
                    if (pRoot.Position - root.Position).Magnitude <= MEDUSA_RADIUS then
                        tool:Activate()
                        lastUse = tick()
                        break
                    end
                end
            end
        end
    end)
end

-- SECTIONS Y TOGGLES
local sections = {"Combat","Player","Visual","Settings"}
local sectionButtons = {}
local frames = {}

local saveConfig
local loadConfig

local startX = 12
local spacing = 6
local sectionWidth = (260 - 2*startX - (spacing*(#sections-1))) / #sections
local sectionY = 55

local content = Instance.new("Frame")
content.Size = UDim2.new(1,-20,1,-110)
content.Position = UDim2.new(0,10,0,95)
content.BackgroundTransparency = 1
content.Parent = hub

for _,name in ipairs(sections) do
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1,0,1,0)
    scroll.CanvasSize = UDim2.new(0,0,0,0)
    scroll.ScrollBarThickness = 4
    scroll.BackgroundTransparency = 1
    scroll.Visible = false
    scroll.Name = name.."Frame"
    scroll.Parent = content

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0,8)
    layout.Parent = scroll
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
    end)

    frames[name] = scroll
end

local function ShowSection(sectionName)
    for _,frame in pairs(frames) do frame.Visible = false end
    frames[sectionName].Visible = true
    for _,b in pairs(sectionButtons) do b.BackgroundColor3 = Color3.fromRGB(10,10,10) end
    for _,b in pairs(sectionButtons) do
        if b.Text == sectionName then b.BackgroundColor3 = Color3.fromRGB(255, 200, 0) end
    end
end

for i,v in ipairs(sections) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, sectionWidth,0,28)
    btn.Position = UDim2.new(0,startX + (i-1)*(sectionWidth+spacing),0,sectionY)
    btn.BackgroundColor3 = Color3.fromRGB(10,10,10)
    btn.Text = v
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Parent = hub
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
    Instance.new("UIStroke", btn).Color = Color3.fromRGB(255, 200, 0)
    table.insert(sectionButtons, btn)
    btn.MouseButton1Click:Connect(function() ShowSection(v) end)
end

local waypointESPEnabled = false
local showAllWaypointBoxes
local clearAllWaypointBoxes

local function CreateToggle(sectionName,text)
    local parentFrame = frames[sectionName]

    if text == "Radio Steal Nearest" and sectionName == "Settings" then
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1,0,0,45)
        container.BackgroundColor3 = Color3.fromRGB(15,15,15)
        container.BackgroundTransparency = 0.2
        container.Parent = parentFrame
        Instance.new("UICorner", container).CornerRadius = UDim.new(0,10)
        Instance.new("UIStroke", container).Color = Color3.fromRGB(255, 200, 0)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.6,0,1,0)
        label.Position = UDim2.new(0,12,0,0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
        label.TextColor3 = Color3.fromRGB(255, 200, 0)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Text = "Radio Steal Nearest"
        label.Parent = container

        local textbox = Instance.new("TextBox")
        textbox.Size = UDim2.new(0,80,0,30)
        textbox.Position = UDim2.new(1,-90,0.5,-15)
        textbox.BackgroundColor3 = Color3.fromRGB(30,30,30)
        textbox.TextColor3 = Color3.new(1,1,1)
        textbox.Font = Enum.Font.Gotham
        textbox.TextSize = 14
        textbox.Text = tostring(grabRadius)
        textbox.ClearTextOnFocus = false
        textbox.Parent = container
        Instance.new("UICorner", textbox).CornerRadius = UDim.new(0,6)
        Instance.new("UIStroke", textbox).Color = Color3.fromRGB(255, 200, 0)

        textbox.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                local num = tonumber(textbox.Text)
                if num and num > 0 and num <= 1000 then
                    grabRadius = num
                    if stealSquarePart then
                        stealSquarePart.Size = Vector3.new(0.05,grabRadius*2, grabRadius*2)
                    end
                else
                    textbox.Text = tostring(grabRadius)
                end
            end
        end)

        return
    end

    -- Toggle normal
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1,0,0,45)
    container.BackgroundColor3 = Color3.fromRGB(15,15,15)
    container.BackgroundTransparency = 0.2
    container.Parent = parentFrame
    Instance.new("UICorner", container).CornerRadius = UDim.new(0,10)
    Instance.new("UIStroke", container).Color = Color3.fromRGB(255, 200, 0)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6,0,1,0)
    label.Position = UDim2.new(0,12,0,0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(255, 200, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = text
    label.Parent = container

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0,50,0,22)
    button.Position = UDim2.new(1,-60,0.5,-11)
    button.BackgroundColor3 = Color3.fromRGB(50,50,50)
    button.Text = ""
    button.Parent = container
    Instance.new("UICorner", button).CornerRadius = UDim.new(1,0)

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0,18,0,18)
    circle.Position = UDim2.new(0,2,0.5,-9)
    circle.BackgroundColor3 = Color3.fromRGB(220,220,220)
    circle.Parent = button
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1,0)

    local enabled = false

    button.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            TweenService:Create(button, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(255, 200, 0)}):Play()
            TweenService:Create(circle, TweenInfo.new(0.25), {Position = UDim2.new(1,-20,0.5,-9)}):Play()
        else
            TweenService:Create(button, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(50,50,50)}):Play()
            TweenService:Create(circle, TweenInfo.new(0.25), {Position = UDim2.new(0,2,0.5,-9)}):Play()
        end

        if text == "Speed Customizer" then
            local boosterGui = lp.PlayerGui:FindFirstChild("BoosterCustomizer")
            if boosterGui then
                boosterGui.Enabled = enabled
            end
        end

        if text == "Slow Fall" then
            slowFallEnabled = enabled
elseif text == "Spin Body" then
    if enabled then
        createSpinButton()
    else
        removeSpinButton()
    end

elseif text == "Anti Ragdoll" then
    toggleAntiRagdoll(enabled)
elseif text == "Auto Play" then
    if enabled then
        if enableAutoPlay then enableAutoPlay() end
    else
        if disableAutoPlay then disableAutoPlay() end
    end

elseif text == "Infinite Jump" then
    infiniteJumpEnabled = enabled
elseif text == "ESP Players" then
    toggleESPPlayers(enabled)

elseif text == "Show Waypoints" then
    waypointESPEnabled = enabled
    if enabled then
        if showAllWaypointBoxes then showAllWaypointBoxes() end
    else
        if clearAllWaypointBoxes then clearAllWaypointBoxes() end
    end

elseif text == "No Walk Animation" then
    local char = lp.Character
    if not char then return end

    local animate = char:FindFirstChild("Animate")

    if enabled then
        if animate then
            savedAnimate = animate
            animate.Disabled = true
        end

        -- detener cualquier animaciÃ³n activa
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            for _,track in ipairs(humanoid:GetPlayingAnimationTracks()) do
                track:Stop()
            end
        end

    else
        if savedAnimate then
            savedAnimate.Disabled = false
            savedAnimate = nil
        end
    end

elseif text == "Auto Bat" then
    autoBatActive = enabled

    if enabled then
        if autoBatLoop then
            autoBatActive = false
            autoBatLoop = nil
        end

        autoBatActive = true

        autoBatLoop = task.spawn(function()
            while autoBatActive do
                local char = lp.Character
                if char then
                    local tool = char:FindFirstChild("Bat")
                    if tool and tool:IsA("Tool") then
                        pcall(function()
                            tool:Activate()
                        end)
                    end
                end
                task.wait(0.4) -- velocidad del golpe
            end
        end)

    else
        autoBatActive = false
    end

elseif text == "Lock Target" then
        if enabled then
                createLockGui()
        else
                destroyLockGui()
        end

elseif text == "Auto Medusa" then
    AutoMedusaEnabled = not AutoMedusaEnabled
    InitMedusa()

elseif text == "Melee Aimbot" then
    meleeEnabled = enabled

    if enabled then
        if character then
            createMeleeAimbot(character)
        end
    else
        disableMeleeAimbot()
    end

        elseif text == "Auto Steal Nearest" then
            autoStealEnabled = enabled
            if enabled then
                createOrUpdateSquare(grabRadius)
                progressBarBg.Visible = true
                local connection = RunService.RenderStepped:Connect(updateSquarePosition)
                task.spawn(function()
                    while autoStealEnabled do
                        local char = lp.Character
                        if char then
                            local root = char:FindFirstChild("HumanoidRootPart")
                            if root then
                                local prompt = findNearestSteal(root)
                                if prompt then
                                    progressBarBg.Visible = true
                                    local start = tick()
                                    while autoStealEnabled and findNearestSteal(root) == prompt do
                                        local p = math.clamp((tick() - start) / 1.2, 0, 1)
                                        progressFill.Size = UDim2.new(p, 0, 1, 0)
                                        percentLabel.Text = math.floor(p*100).."%"
                                        if p >= 0.99 then
                                            pcall(fireproximityprompt, prompt)
                                            task.wait(0.1)
                                            pcall(fireproximityprompt, prompt)
                                            start = tick()
                                        end
                                        task.wait()
                                    end
                                end
                            end
                        end
                        resetBar()
                        task.wait(0.15)
                    end
                    resetBar(true)
                    hideSquare()
                    if connection then connection:Disconnect() end
                end)
            else
                autoStealEnabled = false
                resetBar(true)
                hideSquare()
            end
        end
    end)
end

local combatFuncs = {"Melee Aimbot","Auto Steal Nearest","Lock Target","Auto Medusa","Auto Bat","Auto Play"}
for _,f in ipairs(combatFuncs) do CreateToggle("Combat",f) end

local playerFuncs = {"Speed Customizer","No Walk Animation","Anti Ragdoll","Spin Body","Slow Fall","Infinite Jump"}
for _,f in ipairs(playerFuncs) do CreateToggle("Player",f) end

local visualFuncs = {"ESP Players","Show Waypoints"}
for _,f in ipairs(visualFuncs) do CreateToggle("Visual",f) end

-- Radio Steal Nearest en Settings
CreateToggle("Settings", "Radio Steal Nearest")

-- Radio Lock Target
do
    local parentFrame = frames["Settings"]

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1,0,0,45)
    container.BackgroundColor3 = Color3.fromRGB(15,15,15)
    container.BackgroundTransparency = 0.2
    container.Parent = parentFrame
    Instance.new("UICorner", container).CornerRadius = UDim.new(0,10)
    Instance.new("UIStroke", container).Color = Color3.fromRGB(255, 200, 0)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6,0,1,0)
    label.Position = UDim2.new(0,12,0,0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(255, 200, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = "Range Lock Target"
    label.Parent = container

    local textbox = Instance.new("TextBox")
    textbox.Size = UDim2.new(0,80,0,30)
    textbox.Position = UDim2.new(1,-90,0.5,-15)
    textbox.BackgroundColor3 = Color3.fromRGB(30,30,30)
    textbox.TextColor3 = Color3.new(1,1,1)
    textbox.Font = Enum.Font.Gotham
    textbox.TextSize = 14
    textbox.Text = tostring(LOCK_RADIUS)
    textbox.ClearTextOnFocus = false
    textbox.Parent = container
    Instance.new("UICorner", textbox).CornerRadius = UDim.new(0,6)
    Instance.new("UIStroke", textbox).Color = Color3.fromRGB(255, 200, 0)

    textbox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local num = tonumber(textbox.Text)
            if num and num > 5 and num <= 500 then
                LOCK_RADIUS = num
            else
                textbox.Text = tostring(LOCK_RADIUS)
            end
        end
    end)
end

-- Radio Auto Medusa
do
    local parentFrame = frames["Settings"]

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1,0,0,45)
    container.BackgroundColor3 = Color3.fromRGB(15,15,15)
    container.BackgroundTransparency = 0.2
    container.Parent = parentFrame
    Instance.new("UICorner", container).CornerRadius = UDim.new(0,10)
    Instance.new("UIStroke", container).Color = Color3.fromRGB(255, 200, 0)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6,0,1,0)
    label.Position = UDim2.new(0,12,0,0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(255, 200, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = "Radio Auto Medusa"
    label.Parent = container

    local textbox = Instance.new("TextBox")
    textbox.Size = UDim2.new(0,80,0,30)
    textbox.Position = UDim2.new(1,-90,0.5,-15)
    textbox.BackgroundColor3 = Color3.fromRGB(30,30,30)
    textbox.TextColor3 = Color3.new(1,1,1)
    textbox.Font = Enum.Font.Gotham
    textbox.TextSize = 14
    textbox.Text = tostring(MEDUSA_RADIUS)
    textbox.ClearTextOnFocus = false
    textbox.Parent = container
    Instance.new("UICorner", textbox).CornerRadius = UDim.new(0,6)
    Instance.new("UIStroke", textbox).Color = Color3.fromRGB(255, 200, 0)

    textbox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local num = tonumber(textbox.Text)
            if num and num > 1 and num <= 200 then
                MEDUSA_RADIUS = num

                if medusaPart then
                    medusaPart.Size = Vector3.new(0.05, MEDUSA_RADIUS*2, MEDUSA_RADIUS*2)
                end
            else
                textbox.Text = tostring(MEDUSA_RADIUS)
            end
        end
    end)
end

-- Melee Aimbot Range
do
    local parentFrame = frames["Settings"]

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1,0,0,45)
    container.BackgroundColor3 = Color3.fromRGB(15,15,15)
    container.BackgroundTransparency = 0.2
    container.Parent = parentFrame
    Instance.new("UICorner", container).CornerRadius = UDim.new(0,10)
    Instance.new("UIStroke", container).Color = Color3.fromRGB(255, 200, 0)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6,0,1,0)
    label.Position = UDim2.new(0,12,0,0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(255, 200, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = "Range Melee Aimbot"
    label.Parent = container

    local textbox = Instance.new("TextBox")
    textbox.Size = UDim2.new(0,80,0,30)
    textbox.Position = UDim2.new(1,-90,0.5,-15)
    textbox.BackgroundColor3 = Color3.fromRGB(30,30,30)
    textbox.TextColor3 = Color3.new(1,1,1)
    textbox.Font = Enum.Font.Gotham
    textbox.TextSize = 14
    textbox.Text = tostring(MELEE_RANGE)
    textbox.ClearTextOnFocus = false
    textbox.Parent = container
    Instance.new("UICorner", textbox).CornerRadius = UDim.new(0,6)
    Instance.new("UIStroke", textbox).Color = Color3.fromRGB(255, 200, 0)

    textbox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local num = tonumber(textbox.Text)
            if num and num > 1 and num <= 50 then
                MELEE_RANGE = num
            else
                textbox.Text = tostring(MELEE_RANGE)
            end
        end
    end)
end

do
    local parentFrame = frames["Settings"]

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1,0,0,45)
    container.BackgroundColor3 = Color3.fromRGB(15,15,15)
    container.BackgroundTransparency = 0.2
    container.Parent = parentFrame
    Instance.new("UICorner", container).CornerRadius = UDim.new(0,10)
    Instance.new("UIStroke", container).Color = Color3.fromRGB(255, 200, 0)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.55,0,1,0)
    label.Position = UDim2.new(0,12,0,0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(255, 200, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = "Save Config"
    label.Parent = container

    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0,70,0,28)
    saveBtn.Position = UDim2.new(1,-80,0.5,-14)
    saveBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    saveBtn.Text = "Save"
    saveBtn.TextColor3 = Color3.new(1,1,1)
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.TextSize = 13
    saveBtn.Parent = container
    Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0,6)

    saveBtn.MouseButton1Click:Connect(function()
        if saveConfig and saveConfig() then
            saveBtn.Text = "Saved"
            task.delay(1, function()
                if saveBtn and saveBtn.Parent then
                    saveBtn.Text = "Save"
                end
            end)
        else
            saveBtn.Text = "No File"
            task.delay(1, function()
                if saveBtn and saveBtn.Parent then
                    saveBtn.Text = "Save"
                end
            end)
        end
    end)
end

do
    local parentFrame = frames["Settings"]

    -- Button row in Settings
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1,0,0,45)
    container.BackgroundColor3 = Color3.fromRGB(15,15,15)
    container.BackgroundTransparency = 0.2
    container.Parent = parentFrame
    Instance.new("UICorner", container).CornerRadius = UDim.new(0,10)
    Instance.new("UIStroke", container).Color = Color3.fromRGB(255, 200, 0)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6,0,1,0)
    label.Position = UDim2.new(0,12,0,0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(255, 200, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = "Waypoints Editor"
    label.Parent = container

    local openBtn = Instance.new("TextButton")
    openBtn.Size = UDim2.new(0,60,0,28)
    openBtn.Position = UDim2.new(1,-70,0.5,-14)
    openBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    openBtn.Text = "Edit"
    openBtn.TextColor3 = Color3.new(1,1,1)
    openBtn.Font = Enum.Font.GothamBold
    openBtn.TextSize = 13
    openBtn.Parent = container
    Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0,6)

    -- Floating editor panel (parented directly to main hub ScreenGui)
    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(0,260,0,350)
    panel.Position = UDim2.new(0.5,-130,0.5,-175)
    panel.BackgroundColor3 = Color3.fromRGB(18,20,28)
    panel.BackgroundTransparency = 0.05
    panel.Active = true
    panel.Visible = false
    panel.ZIndex = 20
    panel.Parent = sg
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0,12)
    local panelStroke = Instance.new("UIStroke", panel)
    panelStroke.Color = Color3.fromRGB(255, 200, 0)
    panelStroke.Thickness = 2
    local clearBoxes
    local showBoxes

    -- Drag logic
    local _drag, _dragStart, _dragStartPos = false, nil, nil
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1,0,0,36)
    titleBar.BackgroundTransparency = 1
    titleBar.Parent = panel
    titleBar.Active = true

    titleBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            _drag = true
            _dragStart = inp.Position
            _dragStartPos = panel.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then _drag = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if _drag and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            local d = inp.Position - _dragStart
            panel.Position = UDim2.new(_dragStartPos.X.Scale, _dragStartPos.X.Offset+d.X, _dragStartPos.Y.Scale, _dragStartPos.Y.Offset+d.Y)
        end
    end)

    -- Title
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(0.7,0,0,36)
    titleLbl.Position = UDim2.new(0,12,0,0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = "Auto Play"
    titleLbl.TextColor3 = Color3.fromRGB(255, 200, 0)
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 15
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = panel

    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0,28,0,28)
    closeBtn.Position = UDim2.new(1,-36,0,4)
    closeBtn.BackgroundColor3 = Color3.fromRGB(50,50,60)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 13
    closeBtn.Parent = panel
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,6)
    closeBtn.MouseButton1Click:Connect(function()
        panel.Visible = false
        clearBoxes()
    end)

    -- Separator
    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(0.92,0,0,1)
    sep.Position = UDim2.new(0.04,0,0,38)
    sep.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    sep.BackgroundTransparency = 0.6
    sep.BorderSizePixel = 0
    sep.Parent = panel

    -- Tab buttons LEFT / RIGHT
    local tabFrame = Instance.new("Frame")
    tabFrame.Size = UDim2.new(0.92,0,0,30)
    tabFrame.Position = UDim2.new(0.04,0,0,46)
    tabFrame.BackgroundColor3 = Color3.fromRGB(12,14,20)
    tabFrame.Parent = panel
    Instance.new("UICorner", tabFrame).CornerRadius = UDim.new(0,8)

    local leftTabBtn = Instance.new("TextButton")
    leftTabBtn.Size = UDim2.new(0.5,0,1,0)
    leftTabBtn.Position = UDim2.new(0,0,0,0)
    leftTabBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    leftTabBtn.Text = "LEFT"
    leftTabBtn.TextColor3 = Color3.new(1,1,1)
    leftTabBtn.Font = Enum.Font.GothamBold
    leftTabBtn.TextSize = 13
    leftTabBtn.Parent = tabFrame
    Instance.new("UICorner", leftTabBtn).CornerRadius = UDim.new(0,8)

    local rightTabBtn = Instance.new("TextButton")
    rightTabBtn.Size = UDim2.new(0.5,0,1,0)
    rightTabBtn.Position = UDim2.new(0.5,0,0,0)
    rightTabBtn.BackgroundColor3 = Color3.fromRGB(30,32,42)
    rightTabBtn.Text = "RIGHT"
    rightTabBtn.TextColor3 = Color3.fromRGB(160,160,160)
    rightTabBtn.Font = Enum.Font.GothamBold
    rightTabBtn.TextSize = 13
    rightTabBtn.Parent = tabFrame
    Instance.new("UICorner", rightTabBtn).CornerRadius = UDim.new(0,8)

    -- Status label
    local statusLbl = Instance.new("TextLabel")
    statusLbl.Size = UDim2.new(0.92,0,0,20)
    statusLbl.Position = UDim2.new(0.04,0,0,82)
    statusLbl.BackgroundTransparency = 1
    statusLbl.Text = "Plot: Left  |  9 pts"
    statusLbl.TextColor3 = Color3.fromRGB(180,180,180)
    statusLbl.Font = Enum.Font.Gotham
    statusLbl.TextSize = 12
    statusLbl.TextXAlignment = Enum.TextXAlignment.Left
    statusLbl.Parent = panel

    -- Scroll list
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(0.92,0,0,185)
    scroll.Position = UDim2.new(0.04,0,0,106)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 200, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.CanvasSize = UDim2.new(0,0,0,0)
    scroll.Parent = panel

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0,4)
    listLayout.Parent = scroll

    local saveWaypointsBtn = Instance.new("TextButton")
    saveWaypointsBtn.Size = UDim2.new(0.92,0,0,28)
    saveWaypointsBtn.Position = UDim2.new(0.04,0,1,-38)
    saveWaypointsBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    saveWaypointsBtn.Text = "Save Config"
    saveWaypointsBtn.TextColor3 = Color3.new(1,1,1)
    saveWaypointsBtn.Font = Enum.Font.GothamBold
    saveWaypointsBtn.TextSize = 13
    saveWaypointsBtn.Parent = panel
    Instance.new("UICorner", saveWaypointsBtn).CornerRadius = UDim.new(0,8)
    saveWaypointsBtn.MouseButton1Click:Connect(function()
        if saveConfig and saveConfig() then
            saveWaypointsBtn.Text = "Saved"
        else
            saveWaypointsBtn.Text = "Save Failed"
        end
        task.delay(1, function()
            if saveWaypointsBtn and saveWaypointsBtn.Parent then
                saveWaypointsBtn.Text = "Save Config"
            end
        end)
    end)

    -- Column header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1,0,0,22)
    header.BackgroundTransparency = 1
    header.Parent = scroll

    local hP = Instance.new("TextLabel", header)
    hP.Size = UDim2.new(0.22,0,1,0); hP.Position = UDim2.new(0,0,0,0)
    hP.BackgroundTransparency = 1; hP.Text = ""
    hP.TextColor3 = Color3.fromRGB(100,100,120); hP.Font = Enum.Font.GothamBold; hP.TextSize = 11

    local hX = Instance.new("TextLabel", header)
    hX.Size = UDim2.new(0.38,0,1,0); hX.Position = UDim2.new(0.22,0,0,0)
    hX.BackgroundTransparency = 1; hX.Text = "X"
    hX.TextColor3 = Color3.fromRGB(255, 200, 0); hX.Font = Enum.Font.GothamBold; hX.TextSize = 11

    local hZ = Instance.new("TextLabel", header)
    hZ.Size = UDim2.new(0.38,0,1,0); hZ.Position = UDim2.new(0.60,0,0,0)
    hZ.BackgroundTransparency = 1; hZ.Text = "Z"
    hZ.TextColor3 = Color3.fromRGB(255, 200, 0); hZ.Font = Enum.Font.GothamBold; hZ.TextSize = 11

    -- Plot keys: 3 = left, 7 = right
    local currentPlot = 3
    local rowObjects = {}

    local function buildRows()
        -- clear existing rows
        for _, r in ipairs(rowObjects) do r:Destroy() end
        rowObjects = {}

        if not AutoPlay or not AutoPlay.waypoints or not AutoPlay.waypoints[currentPlot] then
            statusLbl.Text = "Auto Play not ready"
            return
        end

        local pts = AutoPlay.waypoints[currentPlot]
        statusLbl.Text = "Plot: " .. (currentPlot == 3 and "Left" or "Right") .. "  |  " .. #pts .. " pts"

        for i, wp in ipairs(pts) do
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1,0,0,32)
            row.BackgroundColor3 = Color3.fromRGB(22,26,36)
            row.BackgroundTransparency = 0.1
            row.Parent = scroll
            Instance.new("UICorner", row).CornerRadius = UDim.new(0,6)
            table.insert(rowObjects, row)

            local pLbl = Instance.new("TextLabel", row)
            pLbl.Size = UDim2.new(0.22,0,1,0); pLbl.Position = UDim2.new(0,6,0,0)
            pLbl.BackgroundTransparency = 1
            pLbl.Text = "P"..i
            pLbl.TextColor3 = Color3.fromRGB(255, 200, 0)
            pLbl.Font = Enum.Font.GothamBold; pLbl.TextSize = 12
            pLbl.TextXAlignment = Enum.TextXAlignment.Left

            local xBox = Instance.new("TextBox", row)
            xBox.Size = UDim2.new(0.35,0,0,24); xBox.Position = UDim2.new(0.22,0,0.5,-12)
            xBox.BackgroundColor3 = Color3.fromRGB(12,14,22)
            xBox.TextColor3 = Color3.new(1,1,1)
            xBox.Font = Enum.Font.Gotham; xBox.TextSize = 11
            xBox.Text = tostring(math.floor(wp.position.X * 100) / 100)
            xBox.ClearTextOnFocus = false
            Instance.new("UICorner", xBox).CornerRadius = UDim.new(0,4)
            Instance.new("UIStroke", xBox).Color = Color3.fromRGB(0,80,180)

            local zBox = Instance.new("TextBox", row)
            zBox.Size = UDim2.new(0.35,0,0,24); zBox.Position = UDim2.new(0.61,0,0.5,-12)
            zBox.BackgroundColor3 = Color3.fromRGB(12,14,22)
            zBox.TextColor3 = Color3.new(1,1,1)
            zBox.Font = Enum.Font.Gotham; zBox.TextSize = 11
            zBox.Text = tostring(math.floor(wp.position.Z * 100) / 100)
            zBox.ClearTextOnFocus = false
            Instance.new("UICorner", zBox).CornerRadius = UDim.new(0,4)
            Instance.new("UIStroke", zBox).Color = Color3.fromRGB(0,80,180)

            local idx = i
            xBox.FocusLost:Connect(function(enter)
                if enter then
                    local v = tonumber(xBox.Text)
                    if v then
                        local old = AutoPlay.waypoints[currentPlot][idx].position
                        AutoPlay.waypoints[currentPlot][idx].position = Vector3.new(v, old.Y, old.Z)
                        if saveConfig then saveConfig() end
                        showBoxes(); if waypointESPEnabled and showAllWaypointBoxes then showAllWaypointBoxes() end
                    else
                        xBox.Text = tostring(math.floor(AutoPlay.waypoints[currentPlot][idx].position.X * 100) / 100)
                    end
                end
            end)
            zBox.FocusLost:Connect(function(enter)
                if enter then
                    local v = tonumber(zBox.Text)
                    if v then
                        local old = AutoPlay.waypoints[currentPlot][idx].position
                        AutoPlay.waypoints[currentPlot][idx].position = Vector3.new(old.X, old.Y, v)
                        if saveConfig then saveConfig() end
                        showBoxes(); if waypointESPEnabled and showAllWaypointBoxes then showAllWaypointBoxes() end
                    else
                        zBox.Text = tostring(math.floor(AutoPlay.waypoints[currentPlot][idx].position.Z * 100) / 100)
                    end
                end
            end)
        end
    end

    -- 3D waypoint box visualizers
    local waypointBoxParts = {}

    clearBoxes = function()
        for _, p in ipairs(waypointBoxParts) do
            if p and p.Parent then p:Destroy() end
        end
        waypointBoxParts = {}
    end

    showBoxes = function()
        clearBoxes()
        if not AutoPlay or not AutoPlay.waypoints or not AutoPlay.waypoints[currentPlot] then
            return
        end
        local pts = AutoPlay.waypoints[currentPlot]
        local boxColor = currentPlot == 3
            and Color3.fromRGB(255, 200, 0)   -- blue for LEFT
            or  Color3.fromRGB(255, 60, 60)    -- red for RIGHT

        for i, wp in ipairs(pts) do
            local pos = wp.position

            -- Main box part
            local part = Instance.new("Part")
            part.Name = "WP_Box_" .. i
            part.Size = Vector3.new(2, 3, 2)
            part.CFrame = CFrame.new(pos.X, pos.Y + 1.5, pos.Z)
            part.Anchored = true
            part.CanCollide = false
            part.Transparency = 0.45
            part.Color = boxColor
            part.Material = Enum.Material.Neon
            part.CastShadow = false
            part.Parent = workspace

            local adorn = Instance.new("BoxHandleAdornment")
            adorn.Name = "WP_AlwaysOnTop_" .. i
            adorn.Adornee = part
            adorn.Size = part.Size
            adorn.Color3 = boxColor
            adorn.Transparency = 0.15
            adorn.AlwaysOnTop = true
            adorn.ZIndex = 10
            adorn.Parent = part

            -- Outline via SelectionBox
            local sel = Instance.new("SelectionBox")
            sel.Adornee = part
            sel.Color3 = boxColor
            sel.LineThickness = 0.06
            sel.SurfaceTransparency = 1
            sel.Parent = workspace

            -- Label above box
            local billboard = Instance.new("BillboardGui")
            billboard.Size = UDim2.new(0, 50, 0, 22)
            billboard.StudsOffset = Vector3.new(0, 2.5, 0)
            billboard.AlwaysOnTop = true
            billboard.Adornee = part
            billboard.Parent = workspace

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = "P" .. i
            lbl.TextColor3 = Color3.new(1, 1, 1)
            lbl.Font = Enum.Font.GothamBold
            lbl.TextScaled = true
            lbl.TextStrokeTransparency = 0.3
            lbl.TextStrokeColor3 = boxColor
            lbl.Parent = billboard

            table.insert(waypointBoxParts, part)
            table.insert(waypointBoxParts, adorn)
            table.insert(waypointBoxParts, sel)
            table.insert(waypointBoxParts, billboard)
        end
    end

    local function selectTab(plot)
        currentPlot = plot
        if plot == 3 then
            leftTabBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
            leftTabBtn.TextColor3 = Color3.new(1,1,1)
            rightTabBtn.BackgroundColor3 = Color3.fromRGB(30,32,42)
            rightTabBtn.TextColor3 = Color3.fromRGB(160,160,160)
        else
            rightTabBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
            rightTabBtn.TextColor3 = Color3.new(1,1,1)
            leftTabBtn.BackgroundColor3 = Color3.fromRGB(30,32,42)
            leftTabBtn.TextColor3 = Color3.fromRGB(160,160,160)
        end
        buildRows()
        showBoxes(); if waypointESPEnabled and showAllWaypointBoxes then showAllWaypointBoxes() end
    end

    leftTabBtn.MouseButton1Click:Connect(function() selectTab(3) end)
    rightTabBtn.MouseButton1Click:Connect(function() selectTab(7) end)

    openBtn.MouseButton1Click:Connect(function()
        panel.Visible = not panel.Visible
        if panel.Visible then
            buildRows()
            showBoxes(); if waypointESPEnabled and showAllWaypointBoxes then showAllWaypointBoxes() end
        else
            clearBoxes()
        end
    end)
end

ShowSection("Combat")

-- OPEN / CLOSE HUB
local opened = false
toggleBtn.MouseButton1Click:Connect(function()
    opened = not opened
    if opened then
        TweenService:Create(hub, TweenInfo.new(0.3), {Position = UDim2.new(0,20,0.5,-HUB_HEIGHT/2)}):Play()
    else
        TweenService:Create(hub, TweenInfo.new(0.3), {Position = UDim2.new(0,-350,0.5,-HUB_HEIGHT/2)}):Play()
    end
end)


-- =======================
-- ONLY CHANGE "Kawatan" → "Warp"
-- =======================
task.spawn(function()
    -- removed unsafe infinite loopants()) do
            if (v:IsA("TextLabel") or v:IsA("TextButton")) and v.Text then
                if string.find(string.lower(v.Text), "kawatan") then
          
                end
            end
        end
        task.wait(1)
    end
end)

-- =======================
-- DISCORD ABOVE YOUR HEAD ONLY
-- =======================

local Players = game:GetService("Players")
local lp = Players.LocalPlayer

local function addDiscord()
    local char = lp.Character or lp.CharacterAdded:Wait()
    local head = char:WaitForChild("Head")

    if head:FindFirstChild("JHub_Discord") then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "JHub_Discord"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true

    local text = Instance.new("TextLabel")
    text.Parent = billboard
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = "https://discord.gg/dvpGWtdJs"
    text.TextScaled = true
    text.Font = Enum.Font.SourceSansBold
    text.TextColor3 = Color3.fromRGB(0, 255, 255)

    billboard.Parent = head
end

lp.CharacterAdded:Connect(addDiscord)
if lp.Character then addDiscord() end
--// ===== CLEAN MERGED VERSION =====

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local lp = Players.LocalPlayer
local character = lp.Character or lp.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- UPDATE CHARACTER
lp.CharacterAdded:Connect(function(c)
    character = c
    hrp = c:WaitForChild("HumanoidRootPart")
    task.wait(1)
    addDiscord()
end)

--// ===== REMOVE OLD TEXT SPAM =====
for _,v in pairs(game:GetDescendants()) do
    if v:IsA("TextLabel") or v:IsA("TextButton") then
        if v.Text == "J Hub" or v.Text == "J hub Duels" then
            v.Text = ""
        end
    end
end

--// ===== DISCORD TAG =====
function addDiscord()
    local head = character:FindFirstChild("Head")
    if not head then return end

    if head:FindFirstChild("DiscordTag") then
        head.DiscordTag:Destroy()
    end

    local bill = Instance.new("BillboardGui", head)
    bill.Name = "DiscordTag"
    bill.Size = UDim2.new(0,200,0,40)
    bill.StudsOffset = Vector3.new(0,2.5,0)
    bill.AlwaysOnTop = true

    local txt = Instance.new("TextLabel", bill)
    txt.Size = UDim2.new(1,0,1,0)
    txt.BackgroundTransparency = 1
    txt.Text = "discord.gg/vSF2Ex8Gv"
    txt.TextColor3 = Color3.fromRGB(0,170,255)
    txt.TextScaled = true
end

addDiscord()

--// ===== AUTO PLAY =====

AutoPlay = {
    Enabled = false,
    Active = false,
    currentWaypointIndex = 1,
    currentWaypoints = nil,
    renderConn = nil,
    btn = nil,
    plotPositions = {
        [3] = Vector3.new(-476.7524719238281, 10.464664459228516, 7.107429504394531),
        [7] = Vector3.new(-476.7524719238281, 10.464664459228516, 114.10742950439453)
    },
    -- Full 9-point waypoint paths from Irish Hub
    waypoints = {
        [3] = {
            {position = Vector3.new(-475, -7, 90),  speed = 58.5},
            {position = Vector3.new(-475, -7, 90),  speed = 58.5},
            {position = Vector3.new(-479, -5, 95),  speed = 58.5},
            {position = Vector3.new(-479, -5, 95),  speed = 58.5},
            {position = Vector3.new(-486, -5, 97),  speed = 58.5},
            {position = Vector3.new(-486, -5, 97),  speed = 58.5},
            {position = Vector3.new(-474, -7, 92),  speed = 29},
            {position = Vector3.new(-474, -7, 92),  speed = 29},
            {position = Vector3.new(-474, -7, -1),  speed = 29}
        },
        [7] = {
            {position = Vector3.new(-474, -7, 29),  speed = 58.5},
            {position = Vector3.new(-473, -7, 29),  speed = 58.5},
            {position = Vector3.new(-478, -6, 25),  speed = 58.5},
            {position = Vector3.new(-488, -5, 23),  speed = 58.5},
            {position = Vector3.new(-488, -5, 23),  speed = 58.5},
            {position = Vector3.new(-474, -7, 29),  speed = 29},
            {position = Vector3.new(-474, -7, 29),  speed = 29},
            {position = Vector3.new(-475, -7, 118), speed = 29},
            {position = Vector3.new(-475, -7, 118), speed = 29}
        }
    }
}

local waypointESPFolder = nil

clearAllWaypointBoxes = function()
    if waypointESPFolder then
        waypointESPFolder:Destroy()
        waypointESPFolder = nil
    end
end

showAllWaypointBoxes = function()
    clearAllWaypointBoxes()
    if not AutoPlay or not AutoPlay.waypoints then return end

    waypointESPFolder = Instance.new("Folder")
    waypointESPFolder.Name = "WarpHubWaypointESP"
    waypointESPFolder.Parent = workspace

    local defs = {
        { plot = 3, prefix = "L", color = Color3.fromRGB(255, 200, 0) },
        { plot = 7, prefix = "R", color = Color3.fromRGB(255, 60, 60) },
    }

    for _, def in ipairs(defs) do
        local pts = AutoPlay.waypoints[def.plot]
        if pts then
            for i, wp in ipairs(pts) do
                local pos = wp.position
                local part = Instance.new("Part")
                part.Name = "WP_Box_" .. def.prefix .. i
                part.Size = Vector3.new(2, 3, 2)
                part.CFrame = CFrame.new(pos.X, pos.Y + 1.5, pos.Z)
                part.Anchored = true
                part.CanCollide = false
                part.CanQuery = false
                part.CanTouch = false
                part.Transparency = 1
                part.CastShadow = false
                part.Parent = waypointESPFolder

                local box = Instance.new("BoxHandleAdornment")
                box.Name = "WP_AlwaysOnTop_" .. def.prefix .. i
                box.Adornee = part
                box.Size = part.Size
                box.Color3 = def.color
                box.Transparency = 0.35
                box.AlwaysOnTop = true
                box.ZIndex = 10
                box.Parent = part

                local sel = Instance.new("SelectionBox")
                sel.Adornee = part
                sel.Color3 = def.color
                sel.LineThickness = 0.06
                sel.SurfaceTransparency = 1
                sel.Parent = part

                local billboard = Instance.new("BillboardGui")
                billboard.Size = UDim2.new(0, 70, 0, 24)
                billboard.StudsOffset = Vector3.new(0, 2.8, 0)
                billboard.AlwaysOnTop = true
                billboard.Adornee = part
                billboard.Parent = part

                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, 0, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.Text = def.prefix .. i
                lbl.TextColor3 = Color3.new(1, 1, 1)
                lbl.Font = Enum.Font.GothamBlack
                lbl.TextScaled = true
                lbl.TextStrokeTransparency = 0.2
                lbl.TextStrokeColor3 = def.color
                lbl.Parent = billboard
            end
        end
    end
end

local HttpService = game:GetService("HttpService")
local CONFIG_FOLDER = "WarpHub"
local CONFIG_FILE = CONFIG_FOLDER .. "/config.json"
local CONFIG_FALLBACK_FILE = "WarpHub_config.json"

local function getConfigFilePath()
    if type(isfolder) == "function" and type(makefolder) == "function" then
        pcall(function()
            if not isfolder(CONFIG_FOLDER) then
                makefolder(CONFIG_FOLDER)
            end
        end)
        return CONFIG_FILE
    end
    return CONFIG_FALLBACK_FILE
end

local function encodeWaypointList(list)
    local encoded = {}
    for i, wp in ipairs(list) do
        encoded[i] = {
            x = wp.position.X,
            y = wp.position.Y,
            z = wp.position.Z,
            speed = wp.speed
        }
    end
    return encoded
end

local function applyWaypointList(plotKey, list)
    local plotNum = tonumber(plotKey)
    if not plotNum or type(list) ~= "table" then return end

    local converted = {}
    for _, wp in ipairs(list) do
        local x = tonumber(wp.x)
        local y = tonumber(wp.y)
        local z = tonumber(wp.z)
        local speed = tonumber(wp.speed)
        if x and y and z and speed then
            table.insert(converted, {
                position = Vector3.new(x, y, z),
                speed = speed
            })
        end
    end

    if #converted > 0 then
        AutoPlay.waypoints[plotNum] = converted
    end
end

saveConfig = function()
    if type(writefile) ~= "function" then
        return false
    end

    local data = {
        grabRadius = grabRadius,
        LOCK_RADIUS = LOCK_RADIUS,
        MEDUSA_RADIUS = MEDUSA_RADIUS,
        MELEE_RANGE = MELEE_RANGE,
        waypoints = {
            ["3"] = encodeWaypointList(AutoPlay.waypoints[3]),
            ["7"] = encodeWaypointList(AutoPlay.waypoints[7])
        }
    }

    local ok, encoded = pcall(function()
        return HttpService:JSONEncode(data)
    end)
    if not ok then return false end

    local wrote = pcall(function()
        writefile(getConfigFilePath(), encoded)
    end)
    return wrote
end

loadConfig = function()
    local path = getConfigFilePath()
    if type(readfile) ~= "function" or type(isfile) ~= "function" or not isfile(path) then
        return false
    end

    local ok, decoded = pcall(function()
        return HttpService:JSONDecode(readfile(path))
    end)
    if not ok or type(decoded) ~= "table" then return false end

    if tonumber(decoded.grabRadius) then grabRadius = tonumber(decoded.grabRadius) end
    if tonumber(decoded.LOCK_RADIUS) then LOCK_RADIUS = tonumber(decoded.LOCK_RADIUS) end
    if tonumber(decoded.MEDUSA_RADIUS) then MEDUSA_RADIUS = tonumber(decoded.MEDUSA_RADIUS) end
    if tonumber(decoded.MELEE_RANGE) then MELEE_RANGE = tonumber(decoded.MELEE_RANGE) end

    if type(decoded.waypoints) == "table" then
        for plotKey, list in pairs(decoded.waypoints) do
            applyWaypointList(plotKey, list)
        end
    end

    return true
end

loadConfig()

local function createAutoPlayUI()
    AutoPlay.btn = Instance.new("TextButton")
    AutoPlay.btn.Size = UDim2.new(0, 140, 0, 40)
    AutoPlay.btn.Position = UDim2.new(0.5, -70, 0.7, 0)
    AutoPlay.btn.Text = "AutoPlay: OFF"
    AutoPlay.btn.Font = Enum.Font.GothamBold
    AutoPlay.btn.TextSize = 14
    AutoPlay.btn.TextColor3 = Color3.new(1, 1, 1)
    AutoPlay.btn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    AutoPlay.btn.AutoButtonColor = true
    AutoPlay.btn.Visible = false
    AutoPlay.btn.ZIndex = 15
    AutoPlay.btn.Parent = sg

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 8)
    uiCorner.Parent = AutoPlay.btn

    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        AutoPlay.btn.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end

    AutoPlay.btn.InputBegan:Connect(function(input)
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
                if hrp then hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0) end
            end
        end
    end)
end

-- Irish Hub plot detection (exact logic from source)
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

-- Throttled plot scan: only scans workspace every 3 seconds to avoid spike
local _lastPlotCheck = 0
local _cachedPlotNum = nil
local function checkMyPlot()
    local now = tick()
    if _cachedPlotNum then return _cachedPlotNum end
    if now - _lastPlotCheck < 3 then return nil end
    _lastPlotCheck = now
    for plotNum, position in pairs(AutoPlay.plotPositions) do
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name == "PlotSign" then
                if (obj.Position - position).Magnitude < 1 then
                    local owner = getPlotOwner(obj)
                    if string.find(owner, lp.Name) or string.find(owner, lp.DisplayName) then
                        _cachedPlotNum = plotNum
                        return plotNum
                    end
                end
            end
        end
    end
    return nil
end

enableAutoPlay = function()
    if AutoPlay.Enabled then return end
    AutoPlay.Enabled = true
    AutoPlay.Active = false
    AutoPlay.currentWaypoints = nil
    AutoPlay.currentWaypointIndex = 1
    _cachedPlotNum = nil
    _lastPlotCheck = 0

    if not AutoPlay.btn then
        createAutoPlayUI()
    end
    AutoPlay.btn.Visible = true
    AutoPlay.btn.Text = "AutoPlay: OFF"

    -- Heartbeat (off render thread) throttled to 20hz — no frame spikes
    local _lastStep = 0
    local STEP_RATE = 1/20

    AutoPlay.renderConn = RunService.Heartbeat:Connect(func-- removed duplicate loop
led or not AutoPlay.Active then return end

        _lastStep += dt
        if _lastStep < STEP_RATE then return end
        _lastStep = 0

        local character = lp.Character
        if not character then return end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        if not AutoPlay.currentWaypoints then
            local plotNum = checkMyPlot()
            if plotNum and AutoPlay.waypoints[plotNum] then
                AutoPlay.currentWaypoints = AutoPlay.waypoints[plotNum]
                AutoPlay.currentWaypointIndex = 1
            else
                return
            end
        end

        local wp = AutoPlay.currentWaypoints[AutoPlay.currentWaypointIndex]
        local targetPos = wp.position
        local distance = (hrp.Position - targetPos).Magnitude

        if distance < 5 then
            if AutoPlay.currentWaypointIndex < #AutoPlay.currentWaypoints then
                AutoPlay.currentWaypointIndex += 1
            else
                AutoPlay.Active = false
                AutoPlay.currentWaypoints = nil
                AutoPlay.currentWaypointIndex = 1
                _cachedPlotNum = nil
                if AutoPlay.btn then AutoPlay.btn.Text = "AutoPlay: OFF" end
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end
        else
            local moveDir = (targetPos - hrp.Position).Unit
            local moveVector = Vector3.new(moveDir.X, 0, moveDir.Z)
            if moveVector.Magnitude > 0 then
                hrp.AssemblyLinearVelocity = Vector3.new(
                    moveVector.X * wp.speed,
                    hrp.AssemblyLinearVelocity.Y,
                    moveVector.Z * wp.speed
                )
            end
        end
    end)
end

disableAutoPlay = function()
    if not AutoPlay.Enabled then return end
    AutoPlay.Enabled = false
    AutoPlay.Active = false
    AutoPlay.currentWaypoints = nil
    AutoPlay.currentWaypointIndex = 1
    _cachedPlotNum = nil
    if AutoPlay.btn then AutoPlay.btn.Visible = false end
    if AutoPlay.renderConn then
        AutoPlay.renderConn:Disconnect()
        AutoPlay.renderConn = nil
    end
    local character = lp.Character
    if character then
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0) end
    end
end

--// ===== PLAYER DETECTION =====
local function tagPlayer(plr)
    if not plr.Character then return end
    local head = plr.Character:FindFirstChild("Head")
    if not head then return end

    if head:FindFirstChild("ScriptTag") then return end

    local bill = Instance.new("BillboardGui", head)
    bill.Name = "ScriptTag"
    bill.Size = UDim2.new(0,120,0,30)
    bill.StudsOffset = Vector3.new(0,2.5,0)
    bill.AlwaysOnTop = true

    local txt = Instance.new("TextLabel", bill)
    txt.Size = UDim2.new(1,0,1,0)
    txt.BackgroundTransparency = 1
    txt.Text = "Possible Hub User"
    txt.TextColor3 = Color3.fromRGB(255,80,80)
    txt.TextScaled = true
end

for _,plr in pairs(Players:GetPlayers()) do
    if plr ~= lp then
        task.spawn(function()
            local lastPos

            RunService.Heartbeat:Connect(function()
    local _last=0
    local _rate=0.03

    -- removed duplicate loop
 return end
                local h = plr.Character:FindFirstChild("HumanoidRootPart")
                if not h then return end

                if lastPos then
                    local dist = (h.Position - lastPos).Magnitude
                    if dist > 5 and dist < 7 then
                        tagPlayer(plr)
                    end
                end

                lastPos = h.Position
            end)
        end)
    end
end

-- =======================
-- TP DOWN
-- =======================

local function runTPDown()
    task.spawn(function()
        pcall(function()
            local c = Players.LocalPlayer.Character
            if not c then return end
            local hrp = c:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local hum = c:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            local rp = RaycastParams.new()
            rp.FilterDescendantsInstances = {c}
            rp.FilterType = Enum.RaycastFilterType.Exclude
            local hit = workspace:Raycast(hrp.Position, Vector3.new(0, -500, 0), rp)
            if hit then
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
                local hh = hum.HipHeight or 2
                local hy = hrp.Size.Y / 2
                hrp.CFrame = CFrame.new(hit.Position.X, hit.Position.Y + hh + hy + 0.1, hit.Position.Z)
                hrp.AssemblyLinearVelocity = Vector3.zero
            end
        end)
    end)
end

-- =======================
-- DROP BRAINROT
-- =======================

local dropEnabled = false
local _wfConns = {}

local function toggleDrop(state)
    dropEnabled = state

    if dropEnabled then
        local colConn = RunService.Stepped:Connect(function()
            if not dropEnabled then return end
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= lp and p.Character then
                    for _, part in ipairs(p.Character:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end
        end)
        table.insert(_wfConns, colConn)

        task.spawn(function()
            while dropEnabled do
                RunService.Heartbeat:Wait()
                local c = lp.Character
                local root = c and c:FindFirstChild("HumanoidRootPart")

                if not root then continue end

                local vel = root.Velocity
                root.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)

                RunService.RenderStepped:Wait()
                if root and root.Parent then root.Velocity = vel end

                RunService.Stepped:Wait()
                if root and root.Parent then
                    root.Velocity = vel + Vector3.new(0, 0.1, 0)
                end
            end
        end)
    else
        for _, c in ipairs(_wfConns) do
            if typeof(c) == "RBXScriptConnection" then c:Disconnect() end
        end
        _wfConns = {}
    end
end

--// =========================
-- 🔥 WAYPOINT EDITOR + PRESETS
-- =========================

local HttpService = game:GetService("HttpService")

local waypointGui = Instance.new("ScreenGui")
waypointGui.Name = "WaypointEditor"
waypointGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,220,0,300)
frame.Position = UDim2.new(0.75,0,0.2,0)
frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
frame.BackgroundTransparency = 0.3
frame.Parent = waypointGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "Waypoint Editor"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.fromRGB(255,200,0)
title.TextSize = 14
title.Parent = frame

local inputs = {}

local function createRow(name, yPos, defaultX, defaultZ)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.3,0,0,25)
    label.Position = UDim2.new(0,5,0,yPos)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.Parent = frame

    local boxX = Instance.new("TextBox")
    boxX.Size = UDim2.new(0.3,0,0,25)
    boxX.Position = UDim2.new(0.35,0,0,yPos)
    boxX.Text = tostring(defaultX)
    boxX.Parent = frame

    local boxZ = Instance.new("TextBox")
    boxZ.Size = UDim2.new(0.3,0,0,25)
    boxZ.Position = UDim2.new(0.7,0,0,yPos)
    boxZ.Text = tostring(defaultZ)
    boxZ.Parent = frame

    inputs[name] = {x = boxX, z = boxZ}
end

createRow("P1",40,0,60)
createRow("P2",70,10,40)
createRow("P3",100,-10,20)
createRow("P4",130,0,-40)
createRow("P5",160,0,-60)

-- preset storage
local presetFile = "waypoints_preset.json"
local presets = {}

local function loadPresets()
    if isfile and isfile(presetFile) then
        local data = readfile(presetFile)
        presets = HttpService:JSONDecode(data)
    else
        presets = {}
    end
end

local function savePresets()
    if writefile then
        writefile(presetFile, HttpService:JSONEncode(presets))
    end
end

loadPresets()

-- slot box
local slotBox = Instance.new("TextBox")
slotBox.Size = UDim2.new(1,-10,0,25)
slotBox.Position = UDim2.new(0,5,0,200)
slotBox.PlaceholderText = "Preset Name"
slotBox.Parent = frame

-- apply button
local apply = Instance.new("TextButton")
apply.Size = UDim2.new(1,-10,0,25)
apply.Position = UDim2.new(0,5,0,230)
apply.Text = "APPLY"
apply.BackgroundColor3 = Color3.fromRGB(255,200,0)
apply.TextColor3 = Color3.new(0,0,0)
apply.Parent = frame

apply.MouseButton1Click:Connect(function()
    AutoPlay.Waypoints = {}
    for i = 1,5 do
        local key = "P"..i
        local x = tonumber(inputs[key].x.Text) or 0
        local z = tonumber(inputs[key].z.Text) or 0
        table.insert(AutoPlay.Waypoints, {x = x, z = z})
    end
    AutoPlay.Index = 1
    drawWaypoints()
end)

-- save button
local saveBtn = Instance.new("TextButton")
saveBtn.Size = UDim2.new(0.48,0,0,30)
saveBtn.Position = UDim2.new(0,5,0,260)
saveBtn.Text = "SAVE"
saveBtn.BackgroundColor3 = Color3.fromRGB(0,170,0)
saveBtn.Parent = frame

-- load button
local loadBtn = Instance.new("TextButton")
loadBtn.Size = UDim2.new(0.48,0,0,30)
loadBtn.Position = UDim2.new(0.52,0,0,260)
loadBtn.Text = "LOAD"
loadBtn.BackgroundColor3 = Color3.fromRGB(0,120,255)
loadBtn.Parent = frame

saveBtn.MouseButton1Click:Connect(function()
    local name = slotBox.Text
    if name == "" then return end

    presets[name] = {}

    for i = 1,5 do
        local key = "P"..i
        local x = tonumber(inputs[key].x.Text) or 0
        local z = tonumber(inputs[key].z.Text) or 0
        presets[name][i] = {x = x, z = z}
    end

    savePresets()
end)

loadBtn.MouseButton1Click:Connect(function()
    local name = slotBox.Text
    if name == "" then return end
    if not presets[name] then return end

    AutoPlay.Waypoints = {}

    for i, wp in ipairs(presets[name]) do
        local key = "P"..i
        inputs[key].x.Text = tostring(wp.x)
        inputs[key].z.Text = tostring(wp.z)
        table.insert(AutoPlay.Waypoints, {x = wp.x, z = wp.z})
    end

    AutoPlay.Index = 1
    drawWaypoints()
end)



--// 👁️ WAYPOINT VISUALIZER

WaypointVisual = {
    Enabled = false,
    Objects = {}
}

local function clearWaypoints()
    for _, obj in ipairs(WaypointVisual.Objects) do
        if obj then pcall(function() obj:Destroy() end) end
    end
    WaypointVisual.Objects = {}
end

local function drawWaypoints()
    clearWaypoints()
    if not WaypointVisual.Enabled then return end

    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local lastPos = nil

    for i, wp in ipairs(AutoPlay.Waypoints) do
        local pos = hrp.Position + Vector3.new(wp.x, 0, wp.z)

        local part = Instance.new("Part")
        part.Size = Vector3.new(1,1,1)
        part.Shape = Enum.PartType.Ball
        part.Material = Enum.Material.Neon
        part.Color = Color3.fromRGB(255,200,0)
        part.Anchored = true
        part.CanCollide = false
        part.Position = pos
        part.Parent = workspace

        table.insert(WaypointVisual.Objects, part)

        -- 🏷️ LABEL
        local billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.new(0,50,0,20)
        billboard.AlwaysOnTop = true
        billboard.Adornee = part

        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1,0,1,0)
        text.BackgroundTransparency = 1
        text.Text = "P"..i
        text.TextColor3 = Color3.fromRGB(255,255,255)
        text.TextStrokeTransparency = 0
        text.Font = Enum.Font.GothamBold
        text.TextSize = 12
        text.Parent = billboard

        billboard.Parent = part

        table.insert(WaypointVisual.Objects, billboard)

        if lastPos then
            local a0 = Instance.new("Attachment")
            local a1 = Instance.new("Attachment")

            a0.WorldPosition = lastPos
            a1.WorldPosition = pos

            local beam = Instance.new("Beam")
            beam.Attachment0 = a0
            beam.Attachment1 = a1
            beam.Width0 = 0.2
            beam.Width1 = 0.2
            beam.Color = ColorSequence.new(Color3.fromRGB(255,200,0))

            a0.Parent = workspace.Terrain
            a1.Parent = workspace.Terrain
            beam.Parent = workspace.Terrain

            table.insert(WaypointVisual.Objects, a0)
            table.insert(WaypointVisual.Objects, a1)
            table.insert(WaypointVisual.Objects, beam)
        end

        lastPos = pos
    end
end



--// 🔗 HOOK TO VISUAL MENU

-- If your UI has a Visual tab with createToggle, this will attach automatically
pcall(function()
    if createToggle then
        createToggle("Show Waypoints", false, function(state)
            WaypointVisual.Enabled = state

            if state then
                drawWaypoints()
            else
                clearWaypoints()
            end
        end)
    end
end)

