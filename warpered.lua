
--// 🔥 CLEAN REBUILD (OPTIMIZED)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

--// =========================
-- AUTOPLAY
-- =========================
AutoPlay = {
    Enabled = false,
    Active = false,
    Waypoints = {},
    Index = 1,
    lastUpdate = 0,
    UPDATE_RATE = 0.03
}

local function moveTo(hrp, target, speed)
    local dir = target - hrp.Position
    local dist = dir.Magnitude

    if dist > 0 then
        local vel = dir.Unit * speed
        hrp.AssemblyLinearVelocity = Vector3.new(vel.X, hrp.AssemblyLinearVelocity.Y, vel.Z)
    end

    return dist
end

RunService.RenderStepped:Connect(function(dt)
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

    local target = hrp.Position + Vector3.new(wp.x,0,wp.z)
    local dist = moveTo(hrp, target, 60)

    if dist < 4 then
        AutoPlay.Index += 1
        if AutoPlay.Index > #AutoPlay.Waypoints then
            AutoPlay.Index = 1
        end
    end
end)

function enableAutoPlay()
    AutoPlay.Enabled = true
end

function disableAutoPlay()
    AutoPlay.Enabled = false
    AutoPlay.Active = false
end

--// =========================
-- WAYPOINT VISUAL
-- =========================
WaypointVisual = {Enabled=false, Objects={}}

local function clearWaypoints()
    for _,v in ipairs(WaypointVisual.Objects) do
        pcall(function() v:Destroy() end)
    end
    WaypointVisual.Objects = {}
end

function drawWaypoints()
    clearWaypoints()
    if not WaypointVisual.Enabled then return end

    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local last
    for i,wp in ipairs(AutoPlay.Waypoints) do
        local pos = hrp.Position + Vector3.new(wp.x,0,wp.z)

        local p = Instance.new("Part")
        p.Shape = Enum.PartType.Ball
        p.Size = Vector3.new(1,1,1)
        p.Anchored = true
        p.CanCollide = false
        p.Position = pos
        p.Parent = workspace

        local gui = Instance.new("BillboardGui", p)
        gui.Size = UDim2.new(0,50,0,20)
        gui.AlwaysOnTop = true

        local txt = Instance.new("TextLabel", gui)
        txt.Size = UDim2.new(1,0,1,0)
        txt.BackgroundTransparency = 1
        txt.Text = "P"..i
        txt.TextColor3 = Color3.new(1,1,1)

        table.insert(WaypointVisual.Objects, p)

        if last then
            local a0 = Instance.new("Attachment", workspace.Terrain)
            local a1 = Instance.new("Attachment", workspace.Terrain)
            a0.WorldPosition = last
            a1.WorldPosition = pos

            local beam = Instance.new("Beam", workspace.Terrain)
            beam.Attachment0 = a0
            beam.Attachment1 = a1

            table.insert(WaypointVisual.Objects, a0)
            table.insert(WaypointVisual.Objects, a1)
            table.insert(WaypointVisual.Objects, beam)
        end

        last = pos
    end
end

--// =========================
-- DEFAULT WAYPOINTS
-- =========================
AutoPlay.Waypoints = {
    {x=0,z=60},
    {x=10,z=40},
    {x=-10,z=20},
    {x=0,z=-40},
    {x=0,z=-60},
}


--// =========================
-- WAYPOINT MENU (SETTINGS)
-- =========================
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "WaypointMenu"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,120,0,150)
frame.Position = UDim2.new(0,20,0.3,0)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)



--// 🔽 COLLAPSIBLE TOGGLE

local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.new(1,0,0,20)
toggleBtn.Position = UDim2.new(0,0,0,0)
toggleBtn.Text = "-"

local collapsed = false

toggleBtn.MouseButton1Click:Connect(function()
    collapsed = not collapsed
    if collapsed then
        for _,v in ipairs(frame:GetChildren()) do
            if v ~= toggleBtn and v ~= title then
                v.Visible = false
            end
        end
        frame.Size = UDim2.new(0,120,0,25)
        toggleBtn.Text = "+"
    else
        for _,v in ipairs(frame:GetChildren()) do
            v.Visible = true
        end
        frame.Size = UDim2.new(0,120,0,150)
        toggleBtn.Text = "-"
    end
end)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,20)
title.Text = "Waypoint Settings"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1

local inputs = {}

local function createRow(i, y)
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.3,0,0,18)
    label.Position = UDim2.new(0,5,0,y)
    label.Text = "P"..i
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1

    local x = Instance.new("TextBox", frame)
    x.Size = UDim2.new(0.3,0,0,18)
    x.Position = UDim2.new(0.35,0,0,y)
    x.Text = "0"

    local z = Instance.new("TextBox", frame)
    z.Size = UDim2.new(0.3,0,0,18)
    z.Position = UDim2.new(0.7,0,0,y)
    z.Text = "0"

    inputs[i] = {x=x,z=z}
end

for i=1,5 do
    createRow(i, 20 + i*22)
end

local apply = Instance.new("TextButton", frame)
apply.Size = UDim2.new(1,-10,0,20)
apply.Position = UDim2.new(0,5,1,-35)
apply.Text = "Apply"

apply.MouseButton1Click:Connect(function()
    AutoPlay.Waypoints = {}
    for i=1,5 do
        table.insert(AutoPlay.Waypoints,{
            x = tonumber(inputs[i].x.Text) or 0,
            z = tonumber(inputs[i].z.Text) or 0
        })
    end
    drawWaypoints()
end)

--// =========================
-- FIX LABEL STYLE
-- =========================
-- (overwrite label creation inside drawWaypoints)
local oldDraw = drawWaypoints
function drawWaypoints()
    clearWaypoints()
    if not WaypointVisual.Enabled then return end

    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local last
    for i,wp in ipairs(AutoPlay.Waypoints) do
        local pos = hrp.Position + Vector3.new(wp.x,0,wp.z)

        local p = Instance.new("Part")
        p.Shape = Enum.PartType.Ball
        p.Size = Vector3.new(1.2,1.2,1.2)
        p.Material = Enum.Material.Neon
        p.Color = Color3.fromRGB(255,200,0)
        p.Anchored = true
        p.CanCollide = false
        p.Position = pos
        p.Parent = workspace

        local gui = Instance.new("BillboardGui", p)
        gui.Size = UDim2.new(0,60,0,25)
        gui.AlwaysOnTop = true

        local txt = Instance.new("TextLabel", gui)
        txt.Size = UDim2.new(1,0,1,0)
        txt.BackgroundTransparency = 1
        txt.Text = "P"..i
        txt.TextColor3 = Color3.fromRGB(255,255,0)
        txt.TextStrokeTransparency = 0
        txt.Font = Enum.Font.GothamBold
        txt.TextScaled = true

        table.insert(WaypointVisual.Objects, p)

        if last then
            local a0 = Instance.new("Attachment", workspace.Terrain)
            local a1 = Instance.new("Attachment", workspace.Terrain)
            a0.WorldPosition = last
            a1.WorldPosition = pos

            local beam = Instance.new("Beam", workspace.Terrain)
            beam.Attachment0 = a0
            beam.Attachment1 = a1
            beam.Width0 = 0.2
            beam.Width1 = 0.2

            table.insert(WaypointVisual.Objects, a0)
            table.insert(WaypointVisual.Objects, a1)
            table.insert(WaypointVisual.Objects, beam)
        end

        last = pos
    end
end


--// 🖱️ DRAGGABLE FRAME

local dragging = false
local dragInput, dragStart, startPos

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

