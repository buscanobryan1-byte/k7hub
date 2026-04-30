-- ============================================================
--  swift-1 — optimized
-- ============================================================

-- Services (local for fastest lookup)
local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local UserInputService= game:GetService("UserInputService")
local TweenService    = game:GetService("TweenService")
local HttpService     = game:GetService("HttpService")
local Stats           = game:GetService("Stats")

local player  = Players.LocalPlayer
local camera  = workspace.CurrentCamera

-- Frequently-used stdlib cached as locals (avoids global table lookups in hot paths)
local v3new    = Vector3.new
local udim2new = UDim2.new
local cfLookAt = CFrame.lookAt
local mclamp   = math.clamp
local mfloor   = math.floor
local mhuge    = math.huge
local mmax     = math.max
local mmin     = math.min
local mround   = math.round
local tickFn   = tick
local tinsert  = table.insert
local tremove  = table.remove
local pairs    = pairs
local ipairs   = ipairs
local tostring = tostring
local tonumber = tonumber
local pcall    = pcall

-- ── THEME ────────────────────────────────────────────────────
local ACCENT    = Color3.fromRGB(255, 80, 160)
local WHITE     = Color3.fromRGB(255, 255, 255)
local BG        = Color3.fromRGB(255, 255, 255)
local CARD      = Color3.fromRGB(255, 240, 248)
local OFF_CLR   = Color3.fromRGB(220, 180, 210)
local MOB_ON    = Color3.fromRGB(255, 80, 160)
local MOB_OFF   = Color3.fromRGB(200, 150, 190)  -- kept for completeness
local PINK_TEXT = Color3.fromRGB(220, 50, 130)

-- ── GLOBALS ──────────────────────────────────────────────────
NORMAL_SPEED = 60; SLOW_SPEED = 29; AP_DELAY = 0

WP_L_SPD = {10,60,60,29,29,29}
WP_R_SPD = {10,60,60,29,29,29}
WP_L_DLY = {0,0,0,0,0}
WP_R_DLY = {0,0,0,0,0}

POS_L1 = v3new(-476.48,-6.28, 92.73); POS_L2 = v3new(-476.48,-6.28, 92.73)
POS_L3 = v3new(-482.85,-5.03, 93.13); POS_L4 = v3new(-475.68,-6.89, 92.76)
POS_L5 = v3new(-476.50,-6.46, 27.58); POS_L6 = v3new(-482.42,-5.03, 27.84)

POS_R1 = v3new(-476.16,-6.52, 25.62); POS_R2 = v3new(-476.16,-6.52, 25.62)
POS_R3 = v3new(-483.06,-5.03, 27.51); POS_R4 = v3new(-476.21,-6.63, 27.46)
POS_R5 = v3new(-476.66,-6.39, 92.44); POS_R6 = v3new(-481.94,-5.03, 92.42)

AP_LeftOn  = false; AP_RightOn = false

autoStealEnabled = false; isStealing = false; stealStartTime = nil
autoStealConn    = nil;   STEAL_RADIUS = 20;  STEAL_DURATION = 0.35

antiRagdollEnabled = false
unwalkEnabled = false; unwalkConn = nil
batAimbotEnabled  = false; BAT_ENGAGE_RANGE = 5

AIMBOT_SPEED = 60; MELEE_OFFSET = 3
aimbotConnection = nil; lockedTarget = nil
DEFAULT_GRAVITY  = 196.2

espEnabled    = false; espConns = {}; wpEspEnabled = false; wpEspFolder = nil
speedCustomizerActive = false
infJumpEnabled = false; INF_JUMP_FORCE = 54; CLAMP_FALL = 80

gChar = nil; gHum = nil; gHrp = nil; speedBB = nil

ProgressBarFill  = nil; ProgressLabel   = nil; ProgressPctLabel = nil
RadiusInput      = nil; stealBarLocked  = false; mobBtnsLocked    = false

mobBtnPositions = {}; StealBarRef   = nil
SavedPBCPos     = nil; StealRadiusBox = nil

animalCache   = {}; promptCache   = {}
myBasePlotName = nil; lastBaseScan = 0; BASE_SCAN_INTERVAL = 2
lastStealTarget = nil; lastStealPrompt = nil

toggleStates = {}; mobileButtons = {}; mobBtnRefs = {}

AntiRagdollConns = {}
CONFIG_KEY       = "BloomHub_Config"
changingKeybind  = nil
SavedToggleStates = {}

Keybinds = {
    AutoSteal  = Enum.KeyCode.V,
    BatAimbot  = Enum.KeyCode.Z,
    AntiRagdoll= Enum.KeyCode.X,
    Unwalk     = Enum.KeyCode.N,
    Drop       = Enum.KeyCode.F3,
    TPDown     = Enum.KeyCode.G,
}
KeybindButtons = {}

-- ── AIMBOT HIGHLIGHT ─────────────────────────────────────────
local aimbotHighlight = Instance.new("Highlight")
aimbotHighlight.Name              = "BloomAimbotESP"
aimbotHighlight.FillColor         = Color3.fromRGB(255,80,160)
aimbotHighlight.OutlineColor      = WHITE
aimbotHighlight.FillTransparency  = 0.5
aimbotHighlight.OutlineTransparency = 0
pcall(function() aimbotHighlight.Parent = player:WaitForChild("PlayerGui") end)

-- ── CONFIG SAVE / LOAD ───────────────────────────────────────
local function saveConfig()
    pcall(function()
        if not writefile then return end
        local data = {
            NORMAL_SPEED      = NORMAL_SPEED,  SLOW_SPEED       = SLOW_SPEED,
            STEAL_RADIUS      = STEAL_RADIUS,  STEAL_DURATION   = STEAL_DURATION,
            AIMBOT_SPEED      = AIMBOT_SPEED,  BAT_ENGAGE_RANGE = BAT_ENGAGE_RANGE,
            AP_PRE_ROUND_SPD  = AP_PRE_ROUND_SPD,
        }
        for k,v in pairs(toggleStates) do data["TOGGLE_"..k] = v.state end
        for k,v in pairs(Keybinds)      do data["KEY_"..k]    = v.Name  end

        local function sv(v) return {v.X, v.Y, v.Z} end
        local posKeys = {"L1","L2","L3","L4","L5","L6","R1","R2","R3","R4","R5","R6"}
        for _,k in ipairs(posKeys) do data["POS_"..k] = sv(_G["POS_"..k]) end

        data.WP_L_SPD = WP_L_SPD; data.WP_R_SPD = WP_R_SPD
        data.WP_L_DLY = WP_L_DLY; data.WP_R_DLY = WP_R_DLY

        for k,v in pairs(mobBtnPositions) do data["BTN_"..k] = v end
        if StealBarRef then
            local p = StealBarRef.Position
            data.PBC_POS = {p.X.Scale, p.X.Offset, p.Y.Scale, p.Y.Offset}
        end
        writefile(CONFIG_KEY..".json", HttpService:JSONEncode(data))
    end)
end

local function loadConfig()
    pcall(function()
        if not (readfile and isfile and isfile(CONFIG_KEY..".json")) then return end
        local ok, data = pcall(function()
            return HttpService:JSONDecode(readfile(CONFIG_KEY..".json"))
        end)
        if not ok or not data then return end

        -- Simple numeric/bool fields
        local fields = {
            "NORMAL_SPEED","SLOW_SPEED","STEAL_RADIUS","STEAL_DURATION",
            "AIMBOT_SPEED","BAT_ENGAGE_RANGE","AP_PRE_ROUND_SPD"
        }
        for _,k in ipairs(fields) do if data[k] ~= nil then _G[k] = data[k] end end

        -- Keybinds
        for k in pairs(Keybinds) do
            if data["KEY_"..k] then
                pcall(function() Keybinds[k] = Enum.KeyCode[data["KEY_"..k]] end)
            end
        end

        -- Toggle + button states
        SavedToggleStates = {}; mobBtnPositions = {}
        for k,v in pairs(data) do
            if     k:sub(1,7) == "TOGGLE_" then SavedToggleStates[k:sub(8)] = v
            elseif k:sub(1,4) == "BTN_"    then mobBtnPositions[k:sub(5)]   = v
            end
        end

        if data.PBC_POS then SavedPBCPos = data.PBC_POS end

        -- Vector3 positions
        local function lv(k)
            local t = data[k]
            return t and v3new(t[1],t[2],t[3]) or nil
        end
        for _,k in ipairs({"L1","L2","L3","L4","L5","L6","R1","R2","R3","R4","R5","R6"}) do
            local key = "POS_"..k
            _G[key] = lv(key) or _G[key]
        end

        -- WP speed/delay arrays
        local wp = {{"WP_L_SPD",6},{"WP_R_SPD",6},{"WP_L_DLY",5},{"WP_R_DLY",5}}
        for _,pair in ipairs(wp) do
            local name, len = pair[1], pair[2]
            if data[name] then
                for i=1,len do
                    if data[name][i] ~= nil then _G[name][i] = data[name][i] end
                end
            end
        end
    end)
end
loadConfig()

-- ── HELPERS ──────────────────────────────────────────────────
local function getHRP() local c=player.Character return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum() local c=player.Character return c and c:FindFirstChildOfClass("Humanoid") end

-- ── TP DOWN ──────────────────────────────────────────────────
local function doTPDown()
    task.spawn(function()
        pcall(function()
            local c = player.Character if not c then return end
            local hrp = c:FindFirstChild("HumanoidRootPart") if not hrp then return end
            local hum = c:FindFirstChildOfClass("Humanoid") if not hum then return end
            local rp  = RaycastParams.new()
            rp.FilterDescendantsInstances = {c}
            rp.FilterType = Enum.RaycastFilterType.Exclude
            local hit = workspace:Raycast(hrp.Position, v3new(0,-500,0), rp)
            if hit then
                hrp.AssemblyLinearVelocity  = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
                local hh = hum.HipHeight or 2
                local hy = hrp.Size.Y / 2
                hrp.CFrame = CFrame.new(hit.Position.X, hit.Position.Y+hh+hy+0.1, hit.Position.Z)
                hrp.AssemblyLinearVelocity = Vector3.zero
            end
        end)
    end)
end

-- ── INF JUMP ─────────────────────────────────────────────────
UserInputService.JumpRequest:Connect(function()
    if not infJumpEnabled then return end
    local h = getHRP() if not h then return end
    h.AssemblyLinearVelocity = v3new(h.AssemblyLinearVelocity.X, INF_JUMP_FORCE, h.AssemblyLinearVelocity.Z)
end)

RunService.Heartbeat:Connect(function()
    if not infJumpEnabled then return end
    local h = getHRP() if not h then return end
    local vel = h.AssemblyLinearVelocity
    if vel.Y < -CLAMP_FALL then
        h.AssemblyLinearVelocity = v3new(vel.X, -CLAMP_FALL, vel.Z)
    end
end)

-- ── DROP (walk-fling) ─────────────────────────────────────────
local _wfConns = {}; local _wfActive = false

local function startWalkFling()
    _wfActive = true
    tinsert(_wfConns, RunService.Stepped:Connect(function()
        if not _wfActive then return end
        for _,p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                for _,part in ipairs(p.Character:GetChildren()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end
    end))
    local co = coroutine.create(function()
        while _wfActive do
            RunService.Heartbeat:Wait()
            local c    = player.Character
            local root = c and c:FindFirstChild("HumanoidRootPart")
            if not root then RunService.Heartbeat:Wait() continue end
            local vel = root.Velocity
            root.Velocity = vel*10000 + v3new(0,10000,0)
            RunService.RenderStepped:Wait()
            if root and root.Parent then root.Velocity = vel end
            RunService.Stepped:Wait()
            if root and root.Parent then root.Velocity = vel + v3new(0,0.1,0) end
        end
    end)
    coroutine.resume(co)
    tinsert(_wfConns, co)
end

local function stopWalkFling()
    _wfActive = false
    for _,c in ipairs(_wfConns) do
        if typeof(c)=="RBXScriptConnection" then c:Disconnect()
        elseif typeof(c)=="thread" then pcall(task.cancel,c) end
    end
    _wfConns = {}
end

local function doDrop() startWalkFling(); task.delay(0.4, stopWalkFling) end

-- ── SPEED BILLBOARD ──────────────────────────────────────────
local function makeSpeedBB()
    local c = player.Character if not c then return end
    local head = c:FindFirstChild("Head") if not head then return end
    if speedBB then pcall(function() speedBB:Destroy() end) end
    speedBB = Instance.new("BillboardGui")
    speedBB.Name = "BloomSpeedBB"; speedBB.Adornee = head
    speedBB.Size = udim2new(0,100,0,22); speedBB.StudsOffset = v3new(0,3.2,0)
    speedBB.AlwaysOnTop = true; speedBB.Parent = head
    local lbl = Instance.new("TextLabel")
    lbl.Name               = "SpeedLbl"
    lbl.Size               = udim2new(1,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3         = ACCENT
    lbl.TextStrokeColor3   = Color3.fromRGB(200,80,140)
    lbl.TextStrokeTransparency = 0.4
    lbl.Font               = Enum.Font.GothamBold
    lbl.TextScaled         = true
    lbl.Text               = "Speed: 0"
    lbl.Parent             = speedBB
end

local _spdBBTick = 0
RunService.RenderStepped:Connect(function()
    _spdBBTick = _spdBBTick + 1
    if _spdBBTick < 5 then return end
    _spdBBTick = 0
    if not speedBB or not speedBB.Parent then return end
    local h = getHRP() if not h then return end
    local lbl = speedBB:FindFirstChild("SpeedLbl") if not lbl then return end
    local v = h.AssemblyLinearVelocity
    lbl.Text = "Speed: "..mfloor(v3new(v.X,0,v.Z).Magnitude*10)/10
end)

-- ── ANTI RAGDOLL ─────────────────────────────────────────────
local function startAntiRagdoll()
    if #AntiRagdollConns > 0 then return end
    local c        = player.Character or player.CharacterAdded:Wait()
    local humanoid = c:WaitForChild("Humanoid")
    local root     = c:WaitForChild("HumanoidRootPart")
    local animator = humanoid:WaitForChild("Animator")
    local maxVelocity = 40; local clampVelocity = 25; local maxClamp = 15
    local lastVelocity = v3new(0,0,0)

    local RAGDOLL_STATES = {
        [Enum.HumanoidStateType.Physics]     = true,
        [Enum.HumanoidStateType.Ragdoll]     = true,
        [Enum.HumanoidStateType.FallingDown] = true,
        [Enum.HumanoidStateType.GettingUp]   = true,
    }
    local function IsRagdollState() return RAGDOLL_STATES[humanoid:GetState()] end

    local function CleanRagdollEffects()
        for _,obj in pairs(c:GetDescendants()) do
            if obj:IsA("BallSocketConstraint") or obj:IsA("NoCollisionConstraint")
               or obj:IsA("HingeConstraint")
               or (obj:IsA("Attachment") and (obj.Name=="A" or obj.Name=="B")) then
                obj:Destroy()
            elseif obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyGyro") then
                obj:Destroy()
            elseif obj:IsA("Motor6D") then
                obj.Enabled = true
            end
        end
        for _,track in pairs(animator:GetPlayingAnimationTracks()) do
            local name = track.Animation and track.Animation.Name:lower() or ""
            if name:find("rag") or name:find("fall") or name:find("hurt") or name:find("down") then
                track:Stop(0)
            end
        end
    end

    local function ReEnableControls()
        pcall(function()
            require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetControls():Enable()
        end)
    end

    tinsert(AntiRagdollConns, humanoid.StateChanged:Connect(function()
        if IsRagdollState() then
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
            CleanRagdollEffects()
            workspace.CurrentCamera.CameraSubject = humanoid
            ReEnableControls()
        end
    end))

    tinsert(AntiRagdollConns, RunService.Heartbeat:Connect(function()
        if not antiRagdollEnabled or not IsRagdollState() then return end
        CleanRagdollEffects()
        local vel = root.AssemblyLinearVelocity
        if (vel-lastVelocity).Magnitude > maxVelocity and vel.Magnitude > clampVelocity then
            root.AssemblyLinearVelocity = vel.Unit * mmin(vel.Magnitude, maxClamp)
        end
        lastVelocity = vel
    end))

    tinsert(AntiRagdollConns, c.DescendantAdded:Connect(function()
        if IsRagdollState() then CleanRagdollEffects() end
    end))

    tinsert(AntiRagdollConns, player.CharacterAdded:Connect(function(newChar)
        c        = newChar
        humanoid = newChar:WaitForChild("Humanoid")
        root     = newChar:WaitForChild("HumanoidRootPart")
        animator = humanoid:WaitForChild("Animator")
        lastVelocity = v3new(0,0,0)
        ReEnableControls(); CleanRagdollEffects()
    end))

    ReEnableControls(); CleanRagdollEffects()
end

local function stopAntiRagdoll()
    for _,conn in pairs(AntiRagdollConns) do conn:Disconnect() end
    AntiRagdollConns = {}
end

-- ── UNWALK ───────────────────────────────────────────────────
local function startUnwalk()
    if not gChar then return end
    local h2   = gChar:FindFirstChildOfClass("Humanoid") if not h2 then return end
    local anim = h2:FindFirstChildOfClass("Animator")   if not anim then return end
    for _,t in ipairs(anim:GetPlayingAnimationTracks()) do t:Stop(0) end
    if unwalkConn then unwalkConn:Disconnect() end
    unwalkConn = RunService.Heartbeat:Connect(function()
        if not unwalkEnabled then unwalkConn:Disconnect(); unwalkConn=nil; return end
        local c  = player.Character if not c then return end
        local hh = c:FindFirstChildOfClass("Humanoid") if not hh then return end
        local an = hh:FindFirstChildOfClass("Animator") if not an then return end
        for _,t in ipairs(an:GetPlayingAnimationTracks()) do t:Stop(0) end
    end)
end
local function stopUnwalk()
    if unwalkConn then unwalkConn:Disconnect(); unwalkConn=nil end
end

-- ── ESP ──────────────────────────────────────────────────────
local function createESP(plr)
    if plr==player or not plr.Character then return end
    local c    = plr.Character
    local root = c:FindFirstChild("HumanoidRootPart") if not root then return end
    local head = c:FindFirstChild("Head")             if not head then return end
    if c:FindFirstChild("BloomESP") then return end

    local box = Instance.new("BoxHandleAdornment")
    box.Name="BloomESP"; box.Adornee=root; box.Size=v3new(4,6,2)
    box.Color3=ACCENT; box.Transparency=0.45; box.ZIndex=10; box.AlwaysOnTop=true; box.Parent=c

    local bb  = Instance.new("BillboardGui")
    bb.Name="BloomESP_Name"; bb.Adornee=head
    bb.Size=udim2new(0,200,0,45); bb.StudsOffset=v3new(0,3,0); bb.AlwaysOnTop=true; bb.Parent=c

    local lbl = Instance.new("TextLabel")
    lbl.Size=udim2new(1,0,1,0); lbl.BackgroundTransparency=1; lbl.Text=plr.DisplayName
    lbl.TextColor3=WHITE; lbl.Font=Enum.Font.GothamBold; lbl.TextScaled=true
    lbl.TextStrokeTransparency=0.5; lbl.TextStrokeColor3=ACCENT; lbl.Parent=bb
end

local function removeESP(plr)
    if not plr.Character then return end
    local b = plr.Character:FindFirstChild("BloomESP")
    local n = plr.Character:FindFirstChild("BloomESP_Name")
    if b then b:Destroy() end
    if n then n:Destroy() end
end

local function enableESP()
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            if plr.Character then pcall(createESP, plr) end
            tinsert(espConns, plr.CharacterAdded:Connect(function()
                task.wait(0.1); if espEnabled then pcall(createESP, plr) end
            end))
        end
    end
    tinsert(espConns, Players.PlayerAdded:Connect(function(plr)
        if plr==player then return end
        tinsert(espConns, plr.CharacterAdded:Connect(function()
            task.wait(0.1); if espEnabled then pcall(createESP, plr) end
        end))
    end))
end

local function disableESP()
    for _,plr in ipairs(Players:GetPlayers()) do pcall(removeESP, plr) end
    for _,c in ipairs(espConns) do if c and c.Connected then c:Disconnect() end end
    espConns = {}
end

-- ── WAYPOINT ESP ─────────────────────────────────────────────
local wpEspParts = {}

local function buildWPEspInstances()
    if wpEspFolder then wpEspFolder:Destroy() end
    wpEspFolder = Instance.new("Folder"); wpEspFolder.Name="BloomWPEsp"; wpEspFolder.Parent=workspace
    wpEspParts  = {}
    for _,name in ipairs({"L1","L2","L3","L4","L5","R1","R2","R3","R4","R5"}) do
        local p = Instance.new("Part")
        p.Name="WPEsp_"..name; p.Anchored=true; p.CanCollide=false; p.CastShadow=false
        p.Shape=Enum.PartType.Block; p.Size=v3new(1,1.8,1); p.Material=Enum.Material.Neon; p.Parent=wpEspFolder
        local bb  = Instance.new("BillboardGui",p)
        bb.Size=udim2new(0,70,0,22); bb.StudsOffset=v3new(0,2,0); bb.AlwaysOnTop=true
        local lbl = Instance.new("TextLabel",bb)
        lbl.Size=udim2new(1,0,1,0); lbl.BackgroundTransparency=1; lbl.Text=name
        lbl.TextColor3=WHITE; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=11
        lbl.TextStrokeTransparency=0.3
        wpEspParts[name] = {part=p, lbl=lbl}
    end
end

local function refreshWPEsp()
    if not wpEspEnabled then return end
    if not wpEspFolder or not wpEspFolder.Parent then buildWPEspInstances() end
    local wpData = {
        L1={POS_L1,ACCENT}, L2={POS_L2,ACCENT}, L3={POS_L3,ACCENT}, L4={POS_L4,ACCENT}, L5={POS_L5,ACCENT},
        R1={POS_R1,WHITE},  R2={POS_R2,WHITE},  R3={POS_R3,WHITE},  R4={POS_R4,WHITE},  R5={POS_R5,WHITE},
    }
    for name,d in pairs(wpData) do
        local e = wpEspParts[name]
        if e then
            e.part.Position          = d[1]
            e.part.Color             = d[2]
            e.lbl.TextStrokeColor3   = d[2]
        end
    end
end

local function enableWPEsp()
    if not wpEspFolder or not wpEspFolder.Parent then buildWPEspInstances() end
    refreshWPEsp()
end
local function disableWPEsp()
    if wpEspFolder then wpEspFolder:Destroy(); wpEspFolder=nil end
    wpEspParts = {}
end

-- ── BAT AIMBOT ───────────────────────────────────────────────
local function isTargetValid(targetChar)
    if not targetChar then return false end
    local hum = targetChar:FindFirstChildOfClass("Humanoid")
    local hrp = targetChar:FindFirstChild("HumanoidRootPart")
    return hum and hrp and hum.Health > 0 and not targetChar:FindFirstChildOfClass("ForceField")
end

local function getBestTarget(myHRP)
    if lockedTarget and isTargetValid(lockedTarget) then
        return lockedTarget:FindFirstChild("HumanoidRootPart"), lockedTarget
    end
    local shortestDist = mhuge
    local bestChar, bestHRP = nil, nil
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= player and isTargetValid(p.Character) then
            local hrp  = p.Character:FindFirstChild("HumanoidRootPart")
            local dist = (hrp.Position - myHRP.Position).Magnitude
            if dist < shortestDist then
                shortestDist = dist; bestHRP = hrp; bestChar = p.Character
            end
        end
    end
    lockedTarget = bestChar
    return bestHRP, bestChar
end

local function startBatAimbot()
    if aimbotConnection then return end
    if AP_LeftOn or AP_RightOn then
        AP_LeftOn=false; AP_RightOn=false
        AP_StopLeft(); AP_StopRight()
        if AP_SetVisual then AP_SetVisual(false) end
    end
    local c   = player.Character if not c then return end
    local h   = c:FindFirstChild("HumanoidRootPart")
    local hum = c:FindFirstChildOfClass("Humanoid")
    if not h or not hum then return end
    hum.AutoRotate = false

    local attachment = h:FindFirstChild("AimbotAttachment") or Instance.new("Attachment",h)
    attachment.Name  = "AimbotAttachment"
    local align = h:FindFirstChild("AimbotAlign") or Instance.new("AlignOrientation",h)
    align.Name         = "AimbotAlign"
    align.Mode         = Enum.OrientationAlignmentMode.OneAttachment
    align.Attachment0  = attachment
    align.MaxTorque    = mhuge
    align.Responsiveness = 500

    local prevVelocity = v3new(0,0,0)
    local prevTick     = tickFn()
    batAimbotEnabled   = true

    aimbotConnection = RunService.Heartbeat:Connect(function()
        if not batAimbotEnabled then return end
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local currentHRP = char.HumanoidRootPart
        local targetHRP, targetChar = getBestTarget(currentHRP)
        if targetHRP and targetChar then
            aimbotHighlight.Adornee = targetChar
            local targetVel = targetHRP.AssemblyLinearVelocity
            local now       = tickFn()
            local elapsed   = mmax(now - prevTick, 0.001)
            local accel     = (targetVel - prevVelocity) / elapsed
            prevVelocity = targetVel; prevTick = now

            local dist        = (targetHRP.Position - currentHRP.Position).Magnitude
            local predictTime = mclamp(dist / mmax(AIMBOT_SPEED,1), 0.03, 0.35)
            local predictedPos = targetHRP.Position
                + (targetVel * predictTime)
                + (accel * (0.5 * predictTime * predictTime))

            local dirToTarget = predictedPos - currentHRP.Position
            local dist3D      = dirToTarget.Magnitude
            local standPos    = dist3D > 0 and (predictedPos - dirToTarget.Unit * MELEE_OFFSET) or predictedPos

            local faceLookAt = v3new(predictedPos.X, currentHRP.Position.Y, predictedPos.Z)
            align.CFrame = cfLookAt(currentHRP.Position, faceLookAt)

            local moveDir  = standPos - currentHRP.Position
            local moveDist = moveDir.Magnitude
            if moveDist > 0.5 then
                local moveUnit = moveDir.Unit
                local yDelta   = standPos.Y - currentHRP.Position.Y
                local yVel     = mclamp(yDelta*12, -80, 80)
                local xzDist   = v3new(moveDir.X,0,moveDir.Z).Magnitude
                local xzSpeed  = AIMBOT_SPEED * mclamp(xzDist/3, 0.15, 1)
                local flatUnit = v3new(moveUnit.X, 0, moveUnit.Z)
                if flatUnit.Magnitude > 0 then flatUnit = flatUnit.Unit end
                currentHRP.AssemblyLinearVelocity = v3new(flatUnit.X*xzSpeed, yVel, flatUnit.Z*xzSpeed)
            else
                currentHRP.AssemblyLinearVelocity = targetVel
            end
        else
            prevVelocity = v3new(0,0,0); prevTick = tickFn()
            lockedTarget = nil
            currentHRP.AssemblyLinearVelocity = Vector3.zero
            aimbotHighlight.Adornee = nil
        end
    end)
end

local function stopBatAimbot()
    batAimbotEnabled = false
    if aimbotConnection then aimbotConnection:Disconnect(); aimbotConnection=nil end
    local c   = player.Character
    local h   = c and c:FindFirstChild("HumanoidRootPart")
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    if h then
        local att = h:FindFirstChild("AimbotAttachment") if att then att:Destroy() end
        local al  = h:FindFirstChild("AimbotAlign")      if al  then al:Destroy()  end
        h.AssemblyLinearVelocity = Vector3.zero
    end
    if hum then hum.AutoRotate = true end
    lockedTarget = nil; aimbotHighlight.Adornee = nil
end

-- ── MEDUSA COUNTER ───────────────────────────────────────────
local MEDUSA_COOLDOWN      = 25
local medusaLastUsed       = 0
local medusaDebounce       = false
local medusaCounterEnabled = false
local medusaAnchorConns    = {}

local function findMedusa()
    local c = player.Character if not c then return nil end
    local function check(tool)
        local tn = tool.Name:lower()
        return tn:find("medusa") or tn:find("head") or tn:find("stone")
    end
    for _,tool in ipairs(c:GetChildren()) do
        if tool:IsA("Tool") and check(tool) then return tool end
    end
    local bp = player:FindFirstChild("Backpack")
    if bp then
        for _,tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") and check(tool) then return tool end
        end
    end
    return nil
end

local function useMedusa()
    if medusaDebounce or tickFn()-medusaLastUsed < MEDUSA_COOLDOWN then return end
    local c = player.Character if not c then return end
    medusaDebounce = true
    local med = findMedusa()
    if not med then medusaDebounce=false; return end
    local hum2 = c:FindFirstChildOfClass("Humanoid")
    if med.Parent~=c and hum2 then pcall(function() hum2:EquipTool(med) end) end
    pcall(function() med:Activate() end)
    medusaLastUsed = tickFn(); medusaDebounce = false
end

local function stopMedusaCounter()
    for _,c in pairs(medusaAnchorConns) do pcall(function() c:Disconnect() end) end
    medusaAnchorConns = {}
end

local function setupMedusaCounter(c)
    stopMedusaCounter(); if not c then return end
    local function onAnchorChanged(part)
        return part:GetPropertyChangedSignal("Anchored"):Connect(function()
            if medusaCounterEnabled and part.Anchored and part.Transparency==1 then useMedusa() end
        end)
    end
    for _,part in ipairs(c:GetDescendants()) do
        if part:IsA("BasePart") then tinsert(medusaAnchorConns, onAnchorChanged(part)) end
    end
    tinsert(medusaAnchorConns, c.DescendantAdded:Connect(function(part)
        if part:IsA("BasePart") then tinsert(medusaAnchorConns, onAnchorChanged(part)) end
    end))
end

-- ── BAT COUNTER ──────────────────────────────────────────────
local batCounterEnabled       = false
local batCounterActive        = false
local batCounterStopTask      = nil
local batCounterStartedAimbot = false
local batCounterRagConn       = nil
local batCounterDmgConn       = nil
local batCounterVelConn       = nil
local batCounterPrevVel       = v3new(0,0,0)
local batCounterPrevHP        = 100
local batCounterSpawnTime     = 0

local function findBatTool()
    local c = player.Character; if not c then return nil end
    local bp = player:FindFirstChildOfClass("Backpack")
    local SlapList = {"Bat","Slap","Iron Slap","Gold Slap","Diamond Slap","Emerald Slap","Ruby Slap","Dark Matter Slap","Flame Slap","Nuclear Slap","Galaxy Slap","Glitched Slap"}
    for _,ch in ipairs(c:GetChildren()) do
        if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end
    end
    if bp then
        for _,ch in ipairs(bp:GetChildren()) do
            if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end
        end
    end
    for _,name in ipairs(SlapList) do
        local t = c:FindFirstChild(name) or (bp and bp:FindFirstChild(name))
        if t then return t end
    end
    return nil
end

local function triggerBatCounter()
    if batCounterActive then return end
    batCounterActive = true
    batCounterStartedAimbot = false

    local char = player.Character; if not char then batCounterActive=false; return end
    local myHRP = char:FindFirstChild("HumanoidRootPart"); if not myHRP then batCounterActive=false; return end

    -- Find closest enemy within 100 studs
    local closestPlayer, closestDist = nil, mhuge
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local dist = (hrp.Position - myHRP.Position).Magnitude
                if dist < closestDist then closestDist = dist; closestPlayer = p end
            end
        end
    end
    if not closestPlayer or closestDist > 100 then batCounterActive=false; return end

    -- Equip bat immediately
    local bat = findBatTool()
    if bat and bat.Parent ~= char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function() hum:EquipTool(bat) end) end
    end

    -- Start aimbot if not already running
    if not batAimbotEnabled then
        startBatAimbot()
        batCounterStartedAimbot = true
    end

    -- Cancel any existing stop task
    if batCounterStopTask then pcall(task.cancel, batCounterStopTask) end

    -- Auto-stop after 3 seconds
    batCounterStopTask = task.delay(3, function()
        if not batCounterActive then return end
        if batCounterStartedAimbot then
            stopBatAimbot()
            batCounterStartedAimbot = false
        end
        batCounterActive = false
    end)
end

local function stopBatCounter()
    batCounterEnabled = false
    batCounterActive  = false
    if batCounterStopTask then pcall(task.cancel, batCounterStopTask); batCounterStopTask=nil end
    if batCounterRagConn then batCounterRagConn:Disconnect(); batCounterRagConn=nil end
    if batCounterDmgConn then batCounterDmgConn:Disconnect(); batCounterDmgConn=nil end
    if batCounterVelConn then batCounterVelConn:Disconnect(); batCounterVelConn=nil end
    if batCounterStartedAimbot then stopBatAimbot(); batCounterStartedAimbot=false end
end

local function startBatCounter()
    -- Reset cleanly
    stopBatCounter()
    task.wait()

    batCounterEnabled = true
    local char = player.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    batCounterPrevVel  = hrp and hrp.AssemblyLinearVelocity or v3new(0,0,0)
    batCounterPrevHP   = hum and hum.Health or 100
    batCounterSpawnTime = tickFn()

    -- PRIMARY: horizontal velocity-spike detection (X,Z only — ignores gravity/jumps)
    batCounterVelConn = RunService.Stepped:Connect(function()
        local c = player.Character
        local h = c and c:FindFirstChild("HumanoidRootPart")
        if not batCounterEnabled or not h or batCounterActive then
            if h then batCounterPrevVel = h.AssemblyLinearVelocity end
            return
        end
        if tickFn()-batCounterSpawnTime < 2 then
            batCounterPrevVel = h.AssemblyLinearVelocity; return
        end
        local cv = h.AssemblyLinearVelocity
        local horizChange = v3new(cv.X-batCounterPrevVel.X, 0, cv.Z-batCounterPrevVel.Z).Magnitude
        batCounterPrevVel = cv
        -- Threshold tuned for bat / stick / log knockback
        if horizChange > 12 then task.defer(triggerBatCounter) end
    end)

    -- BACKUP: ragdoll / stun child added to character
    local function onChildAdded(child)
        if not batCounterEnabled then return end
        local n = child.Name:lower()
        if n=="ragdoll" or n=="isragdoll" or n:find("hit") or n:find("stun")
           or n:find("impact") or n:find("knock") or n:find("flinch") or n:find("bat") then
            task.defer(triggerBatCounter)
        end
    end
    if char then batCounterRagConn = char.ChildAdded:Connect(onChildAdded) end

    -- BACKUP: HP drop detection
    batCounterDmgConn = RunService.Heartbeat:Connect(function()
        local c2 = player.Character
        local h2 = c2 and c2:FindFirstChildOfClass("Humanoid")
        if not batCounterEnabled or not h2 or batCounterActive then
            if h2 then batCounterPrevHP = h2.Health end
            return
        end
        local hp = h2.Health
        if hp < batCounterPrevHP then task.defer(triggerBatCounter) end
        batCounterPrevHP = hp
    end)
end

-- Restart bat counter when character respawns so connections rebind
player.CharacterAdded:Connect(function()
    if batCounterEnabled then
        task.wait(0.5)
        startBatCounter()
    end
end)

-- ── AUTO PLAY (6-waypoint) ────────────────────────────────────
local AP_LeftConn  = nil; local AP_RightConn = nil
local AP_LeftPhase = 1;   local AP_RightPhase = 1
local AP_SetVisual = nil; local AP_LockVisual = nil
local AP_REACH     = 0.5
local AP_LeftArrived  = 0; local AP_RightArrived  = 0
local AP_LeftDelayUntil  = 0; local AP_RightDelayUntil = 0
AP_PRE_ROUND_SPD = AP_PRE_ROUND_SPD or 9
local AP_RoundStarted  = false

local function AP_DetectRoundStart()
    AP_RoundStarted = false
    local function onRoundStart() if AP_RoundStarted then return end AP_RoundStarted=true  end
    local function onRoundEnd()                                       AP_RoundStarted=false end

    local wsConn
    local function watchWalkSpeed()
        local c   = player.Character or player.CharacterAdded:Wait()
        local hum = c:WaitForChild("Humanoid",5) if not hum then return end
        if wsConn then wsConn:Disconnect() end
        if hum.WalkSpeed > 12 then onRoundStart() end
        wsConn = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if hum.WalkSpeed > 12 then onRoundStart()
            elseif hum.WalkSpeed <= 1 then onRoundEnd() end
        end)
    end
    watchWalkSpeed()
    player.CharacterAdded:Connect(function() task.wait(0.5); watchWalkSpeed() end)

    local function watchValue(val)
        local function check()
            local v = tostring(val.Value):lower()
            if v=="intermission" or v=="waiting" or v=="lobby" or v=="0" or v=="" then onRoundEnd()
            else onRoundStart() end
        end
        check(); val.Changed:Connect(check)
    end
    local STATUS_NAMES = {status=true,gamestatus=true,roundstatus=true,gamestate=true,state=true,phase=true}
    local function scanForStatusValues(parent)
        for _,v in ipairs(parent:GetChildren()) do
            if STATUS_NAMES[v.Name:lower()] then
                if v:IsA("StringValue") or v:IsA("IntValue") or v:IsA("BoolValue") then
                    watchValue(v)
                end
            end
        end
    end
    pcall(function() scanForStatusValues(game:GetService("ReplicatedStorage")) end)
    pcall(function() scanForStatusValues(workspace) end)

    task.spawn(function()
        local pg = player:WaitForChild("PlayerGui",10) if not pg then return end
        local function watchGui(gui)
            local n = gui.Name:lower()
            if n:find("intermission") or n:find("countdown") or n:find("waiting") then
                onRoundEnd()
                gui.AncestryChanged:Connect(function()
                    if not gui.Parent then onRoundStart() end
                end)
            end
        end
        for _,gui in ipairs(pg:GetChildren()) do watchGui(gui) end
        pg.ChildAdded:Connect(watchGui)
    end)
end
task.spawn(AP_DetectRoundStart)

-- Waypoint arrays (refreshed each access so edited globals take effect)
local AP_LEFT_WPS  = {POS_L1,POS_L2,POS_L3,POS_L4,POS_L5}
local AP_RIGHT_WPS = {POS_R1,POS_R2,POS_R3,POS_R4,POS_R5}

local function AP_GetLeftWP()
    AP_LEFT_WPS[1]=POS_L1; AP_LEFT_WPS[2]=POS_L2; AP_LEFT_WPS[3]=POS_L3
    AP_LEFT_WPS[4]=POS_L4; AP_LEFT_WPS[5]=POS_L5
    return AP_LEFT_WPS
end
local function AP_GetRightWP()
    AP_RIGHT_WPS[1]=POS_R1; AP_RIGHT_WPS[2]=POS_R2; AP_RIGHT_WPS[3]=POS_R3
    AP_RIGHT_WPS[4]=POS_R4; AP_RIGHT_WPS[5]=POS_R5
    return AP_RIGHT_WPS
end

local function AP_StopLeft()
    if AP_LeftConn then AP_LeftConn:Disconnect(); AP_LeftConn=nil end
    AP_LeftPhase = 1
    local c = player.Character
    if c then local h = c:FindFirstChildOfClass("Humanoid"); if h then h:Move(Vector3.zero,false) end end
end
local function AP_StopRight()
    if AP_RightConn then AP_RightConn:Disconnect(); AP_RightConn=nil end
    AP_RightPhase = 1
    local c = player.Character
    if c then local h = c:FindFirstChildOfClass("Humanoid"); if h then h:Move(Vector3.zero,false) end end
end

-- Generic auto-play runner — replaces the duplicated Left/Right functions
local function AP_StartSide(
    getOnFlag, setOnFlag,
    getConn,   setConn,
    getPhase,  setPhase,
    getArrived,setArrived,
    getDelayUntil, setDelayUntil,
    getWPs,  getSPD,  getDLY,
    stopFn
)
    stopFn()
    setOnFlag(true); setPhase(1); setArrived(0); setDelayUntil(0)
    local cachedC, cachedRp, cachedHum = nil, nil, nil
    local pulseTick = 0
    setConn(RunService.Heartbeat:Connect(function()
        if not getOnFlag() then return end
        local c = player.Character; if not c then cachedC=nil; return end
        if c ~= cachedC then
            cachedC   = c
            cachedRp  = c:FindFirstChild("HumanoidRootPart")
            cachedHum = c:FindFirstChildOfClass("Humanoid")
        end
        local rp = cachedRp; local hum = cachedHum
        if not rp or not hum then return end
        local wps = getWPs()
        local ph  = getPhase()
        if ph > #wps then
            hum:Move(Vector3.zero,false); rp.AssemblyLinearVelocity=Vector3.zero
            setOnFlag(false); stopFn()
            if AP_SetVisual then AP_SetVisual(false) end
            return
        end
        local tgt = wps[ph]
        local spd = AP_RoundStarted and getSPD()[ph] or AP_PRE_ROUND_SPD
        local pos = rp.Position
        local flat = v3new(tgt.X, pos.Y, tgt.Z)
        local dist = (flat-pos).Magnitude
        if dist < AP_REACH then
            hum:Move(Vector3.zero,false); rp.AssemblyLinearVelocity=Vector3.zero
            local dly = getDLY()[ph] or 0
            if dly > 0 then
                if getDelayUntil()==0 then setDelayUntil(tickFn()+dly) end
                if tickFn() < getDelayUntil() then return end
            end
            setPhase(ph+1); setArrived(0); setDelayUntil(0)
            return
        end
        setArrived(0); setDelayUntil(0)
        local d  = flat - pos
        local mv = d.Unit
        -- Velocity pulsing: keep WalkSpeed at a server-safe value and
        -- pulse the boosted velocity every other frame so the server's
        -- kinematic check averages out and stops lag-backing the player.
        hum.WalkSpeed = 16
        hum:Move(mv, false)
        pulseTick = pulseTick + 1
        if pulseTick % 2 == 0 then
            local vy = rp.AssemblyLinearVelocity.Y
            rp.AssemblyLinearVelocity = v3new(mv.X*spd, vy, mv.Z*spd)
        end
    end))
end

local function AP_StartLeft()
    AP_StartSide(
        function() return AP_LeftOn  end, function(v) AP_LeftOn=v end,
        function() return AP_LeftConn end, function(v) AP_LeftConn=v end,
        function() return AP_LeftPhase end, function(v) AP_LeftPhase=v end,
        function() return AP_LeftArrived end, function(v) AP_LeftArrived=v end,
        function() return AP_LeftDelayUntil end, function(v) AP_LeftDelayUntil=v end,
        AP_GetLeftWP, function() return WP_L_SPD end, function() return WP_L_DLY end,
        AP_StopLeft
    )
end
local function AP_StartRight()
    AP_StartSide(
        function() return AP_RightOn  end, function(v) AP_RightOn=v end,
        function() return AP_RightConn end, function(v) AP_RightConn=v end,
        function() return AP_RightPhase end, function(v) AP_RightPhase=v end,
        function() return AP_RightArrived end, function(v) AP_RightArrived=v end,
        function() return AP_RightDelayUntil end, function(v) AP_RightDelayUntil=v end,
        AP_GetRightWP, function() return WP_R_SPD end, function() return WP_R_DLY end,
        AP_StopRight
    )
end

local function AP_DetectSide()
    local plots = workspace:FindFirstChild("Plots"); if not plots then return nil end
    for _,plot in ipairs(plots:GetChildren()) do
        if plot:IsA("Model") then
            local sign = plot:FindFirstChild("PlotSign"); if not sign then continue end
            local yb   = sign:FindFirstChild("YourBase",true)
            if yb and yb:IsA("BillboardGui") and yb.Enabled then
                return plot:GetPivot().Position.Z >= 60 and "left" or "right"
            end
        end
    end
    return nil
end

local function AP_Toggle()
    if AP_LeftOn or AP_RightOn then
        AP_LeftOn=false; AP_RightOn=false
        AP_StopLeft(); AP_StopRight()
        if AP_SetVisual then AP_SetVisual(false) end
    else
        if batAimbotEnabled then
            stopBatAimbot()
            if updateToggle then updateToggle("Lock",false) end
        end
        local side  = AP_DetectSide()
        local route = side=="left" and "right" or "left"
        if route=="left" then AP_StartLeft() else AP_StartRight() end
        if AP_SetVisual then AP_SetVisual(true) end
    end
end

-- ── AUTO STEAL ───────────────────────────────────────────────
local function getMyBasePlotName()
    local now = tickFn()
    if myBasePlotName~=nil and (now-lastBaseScan)<BASE_SCAN_INTERVAL then return myBasePlotName end
    lastBaseScan = now
    local plots = workspace:FindFirstChild("Plots")
    if not plots then myBasePlotName=false; return false end
    for _,plot in ipairs(plots:GetChildren()) do
        if plot:IsA("Model") then
            local sign = plot:FindFirstChild("PlotSign",true)
            if sign then
                local yb = sign:FindFirstChild("YourBase",true)
                if yb and yb:IsA("BillboardGui") and yb.Enabled then
                    myBasePlotName = plot.Name; return plot.Name
                end
            end
        end
    end
    myBasePlotName = false; return false
end

local function scanPlot(plot)
    if not plot or not plot:IsA("Model") then return end
    local plotName = plot.Name
    for i=#animalCache,1,-1 do
        if animalCache[i].plot==plotName then tremove(animalCache,i) end
    end
    if plotName==getMyBasePlotName() then return end
    local podiums = plot:FindFirstChild("AnimalPodiums") if not podiums then return end
    for _,pod in ipairs(podiums:GetChildren()) do
        if pod:IsA("Model") and pod:FindFirstChild("Base") then
            local uid = plotName.."_"..pod.Name
            tinsert(animalCache, {plot=plotName, slot=pod.Name, pod=pod,
                worldPosition=pod:GetPivot().Position, uid=uid})
        end
    end
end

local function findPromptForAnimal(ad)
    if not ad then return nil end
    local cp = promptCache[ad.uid]; if cp and cp.Parent then return cp end
    local pod = ad.pod
    if not pod or not pod.Parent then
        local plots = workspace:FindFirstChild("Plots") if not plots then return nil end
        local plot  = plots:FindFirstChild(ad.plot)    if not plot  then return nil end
        local pods  = plot:FindFirstChild("AnimalPodiums") if not pods then return nil end
        pod = pods:FindFirstChild(ad.slot) if not pod then return nil end
        ad.pod = pod
    end
    local base = pod:FindFirstChild("Base")            if not base then return nil end
    local sp   = base:FindFirstChild("Spawn")          if not sp   then return nil end
    local att  = sp:FindFirstChild("PromptAttachment") if not att  then return nil end
    for _,p in ipairs(att:GetChildren()) do
        if p:IsA("ProximityPrompt") then promptCache[ad.uid]=p; return p end
    end
end

local function getPromptConnections(prompt)
    local out = {hold={},holdEnded={},trigger={},triggered={}}
    pcall(function()
        if not getconnections then return end
        for _,c in ipairs(getconnections(prompt.PromptButtonHoldBegan))  do if type(c.Function)=="function" then tinsert(out.hold,     c.Function) end end
        for _,c in ipairs(getconnections(prompt.PromptButtonHoldEnded))  do if type(c.Function)=="function" then tinsert(out.holdEnded,c.Function) end end
        for _,c in ipairs(getconnections(prompt.Triggered))              do if type(c.Function)=="function" then tinsert(out.triggered,c.Function) end end
        pcall(function()
            for _,c in ipairs(getconnections(prompt.TriggerEnded)) do if type(c.Function)=="function" then tinsert(out.trigger,c.Function) end end
        end)
    end)
    return out
end

local function fireHoldBegin(prompt,conns)
    pcall(function() if prompt.Parent then prompt:InputHoldBegin() end end)
    pcall(function() if prompt.Parent then prompt:TriggerPrompt() end end)
    for _,f in ipairs(conns.hold) do task.spawn(pcall,f) end
end

local function fireHoldEnd(prompt,conns)
    pcall(function() if prompt.Parent then prompt:InputHoldEnd() end end)
    for _,f in ipairs(conns.holdEnded)  do task.spawn(pcall,f) end
    for _,f in ipairs(conns.triggered)  do task.spawn(pcall,f) end
    for _,f in ipairs(conns.trigger)    do task.spawn(pcall,f) end
end

local function podHasAnimal(prompt)
    return prompt and prompt.Parent and prompt.Enabled
end

local function execSteal(prompt)
    if isStealing then return false end
    if not podHasAnimal(prompt) then return false end
    isStealing = true

    local function setBar(prog)
        if ProgressBarFill then ProgressBarFill.Size = udim2new(mclamp(prog,0,1), 0, 1, 0) end
    end

    task.spawn(function()
        local MAX_RETRIES = 4; local attempt = 0
        while attempt < MAX_RETRIES do
            if not podHasAnimal(prompt) then break end
            attempt = attempt + 1

            local conns   = getPromptConnections(prompt)
            local dur     = STEAL_DURATION
            local elapsed = 0

            -- Reset bar at the start of each attempt
            setBar(0)
            fireHoldBegin(prompt, conns)

            while elapsed < dur do
                if not podHasAnimal(prompt) then break end
                local dt = RunService.Heartbeat:Wait()
                elapsed  = elapsed + dt
                -- Update bar based on this attempt's elapsed time
                setBar(elapsed / dur)
                for _,f in ipairs(conns.hold) do task.spawn(pcall, f) end
                pcall(function() if prompt.Parent then prompt:InputHoldBegin() end end)
            end

            if not podHasAnimal(prompt) then break end
            setBar(1)
            fireHoldEnd(prompt, conns)

            task.wait(0.08)
            if not podHasAnimal(prompt) then break end
            task.wait(0.1)

            -- Reset bar before next retry
            setBar(0)
        end

        -- Fully reset bar and state when done
        setBar(0)
        isStealing = false; lastStealTarget = nil; lastStealPrompt = nil
        if prompt then
            for uid,p in pairs(promptCache) do
                if p==prompt then promptCache[uid]=nil; break end
            end
        end
    end)
    return true
end

local function nearestAnimal()
    local h = getHRP() if not h then return nil end
    local myBase = getMyBasePlotName()
    local best, bestD = nil, mhuge
    local pos = h.Position
    for _,ad in ipairs(animalCache) do
        if ad.plot ~= myBase then
            if ad.pod and ad.pod.Parent then
                ad.worldPosition = ad.pod:GetPivot().Position
            end
            local wp = ad.worldPosition
            if wp then
                local d = (pos-wp).Magnitude
                if d < bestD then bestD=d; best=ad end
            end
        end
    end
    return best, bestD
end

local function startAutoSteal()
    if autoStealConn then return end
    lastStealTarget=nil; lastStealPrompt=nil
    autoStealConn = RunService.Heartbeat:Connect(function()
        if not autoStealEnabled or isStealing then return end
        local target, dist = nearestAnimal()
        if not target or dist > STEAL_RADIUS then
            lastStealTarget=nil; lastStealPrompt=nil; return
        end
        local prompt
        if target==lastStealTarget and lastStealPrompt and lastStealPrompt.Parent then
            prompt = lastStealPrompt
        else
            prompt = findPromptForAnimal(target)
            if not prompt then return end
            lastStealTarget=target; lastStealPrompt=prompt
        end
        if not podHasAnimal(prompt) then
            promptCache[target.uid]=nil; lastStealTarget=nil; lastStealPrompt=nil; return
        end
        execSteal(prompt)
    end)
end

local function stopAutoSteal()
    if autoStealConn then autoStealConn:Disconnect(); autoStealConn=nil end
    isStealing=false; lastStealTarget=nil; lastStealPrompt=nil
    if ProgressBarFill then ProgressBarFill.Size=udim2new(0,0,1,0) end
end

-- Initial plot scan
task.spawn(function()
    task.wait(2)
    local plots = workspace:WaitForChild("Plots",10) if not plots then return end
    for _,plot in ipairs(plots:GetChildren()) do if plot:IsA("Model") then scanPlot(plot) end end
    plots.ChildAdded:Connect(function(plot)
        if plot:IsA("Model") then task.wait(0.5); scanPlot(plot) end
    end)
    task.spawn(function()
        while task.wait(5) do
            local myBase = getMyBasePlotName()
            for _,plot in ipairs(plots:GetChildren()) do
                if plot:IsA("Model") and plot.Name~=myBase then scanPlot(plot) end
            end
        end
    end)
end)

-- ── IS HOLDING BRAINROT ──────────────────────────────────────
local function isHoldingBrainrot()
    local c = player.Character if not c then return false end

    local brainrotKeywords = {"brainrot","skibidi","rizz","sigma","gyatt","mewing","ohio","sussy",
        "amogus","cap","npc","sus","yap","delulu","slay","opium","fanum","tax","grimace","bibble",
        "chill","guy","tralalero","tralala","bombardiro","crocodilo","lirili","larila","tung",
        "sahur","brr","patapim","chimpanzini","bananini","cappuccino","assassino","ballerina",
        "cappuccina","trippi","troppi","frigo","camelo","elefanto","odin","din","dun","spioniro",
        "golubiro","matteo","la vacca","saturno","hotspot","garama","madundung"}
    local carryKeywords = {"carry","carrying","carried","holding","held","stolen","steal",
        "stealing","grab","grabbed","animal","creature","brainrot"}
    local IGNORE = {
        HumanoidRootPart=true,Head=true,Torso=true,UpperTorso=true,LowerTorso=true,
        LeftArm=true,RightArm=true,LeftLeg=true,RightLeg=true,LeftHand=true,RightHand=true,
        LeftFoot=true,RightFoot=true,LeftLowerArm=true,RightLowerArm=true,LeftUpperArm=true,
        RightUpperArm=true,LeftLowerLeg=true,RightLowerLeg=true,LeftUpperLeg=true,
        RightUpperLeg=true,Animate=true,BloomSpeedBB=true,
    }

    local function txt(v)
        if typeof(v)=="string"   then return v:lower() end
        if typeof(v)=="Instance" then return v.Name:lower() end
        return tostring(v):lower()
    end
    local function hasKW(s, list)
        s = txt(s)
        for _,kw in ipairs(list) do if s:find(kw,1,true) then return true end end
        return false
    end
    local function attrSaysHolding(obj)
        local CARRY_ATTRS = {"Carrying","Carry","Holding","Held","Stolen","Stealing",
            "HasAnimal","Animal","Brainrot","HeldBrainrot","StolenAnimal","CarriedAnimal"}
        for _,attr in ipairs(CARRY_ATTRS) do
            local v = obj:GetAttribute(attr)
            if v==true then return true end
            if v~=nil and v~=false and tostring(v)~="" and tostring(v)~="0" then
                if hasKW(attr,carryKeywords) or hasKW(v,brainrotKeywords) or hasKW(v,carryKeywords) then return true end
            end
        end
        for name,value in pairs(obj:GetAttributes()) do
            if value==true and hasKW(name,carryKeywords) then return true end
            if value~=nil and value~=false and tostring(value)~="" and tostring(value)~="0" then
                if hasKW(name,carryKeywords) and (value==true or hasKW(value,brainrotKeywords) or hasKW(value,carryKeywords)) then return true end
            end
        end
        return false
    end

    -- Shared check function used for both direct children and descendants
    local function checkObj(obj, isDirectChild)
        if IGNORE[obj.Name] then return false end
        if not isDirectChild and obj.Parent==c then return false end -- skip direct children in descendant pass
        if attrSaysHolding(obj) then return true end
        if obj:IsA("Tool") or obj:IsA("Model") or obj:IsA("Folder") or obj:IsA("Accessory") or obj:IsA("Hat") then
            if hasKW(obj.Name,brainrotKeywords) or hasKW(obj.Name,carryKeywords) then return true end
        elseif obj:IsA("BoolValue") and obj.Value==true and hasKW(obj.Name,carryKeywords) then
            return true
        elseif obj:IsA("StringValue") and (hasKW(obj.Name,carryKeywords) or hasKW(obj.Value,brainrotKeywords) or hasKW(obj.Value,carryKeywords)) then
            return true
        elseif obj:IsA("ObjectValue") and obj.Value and (hasKW(obj.Name,carryKeywords) or hasKW(obj.Value.Name,brainrotKeywords) or hasKW(obj.Value.Name,carryKeywords)) then
            return true
        end
        return false
    end

    if attrSaysHolding(player) or attrSaysHolding(c) then return true end
    local hum = c:FindFirstChildOfClass("Humanoid")
    if hum and attrSaysHolding(hum) then return true end
    local tool = c:FindFirstChildOfClass("Tool")
    if tool and (hasKW(tool.Name,brainrotKeywords) or hasKW(tool.Name,carryKeywords) or attrSaysHolding(tool)) then return true end

    for _,obj in ipairs(c:GetChildren()) do
        if not IGNORE[obj.Name] and checkObj(obj, true) then return true end
    end
    for _,obj in ipairs(c:GetDescendants()) do
        if not IGNORE[obj.Name] and obj.Parent~=c and attrSaysHolding(obj) then return true end
        if not IGNORE[obj.Name] and obj.Parent~=c then
            if (obj:IsA("Model") or obj:IsA("Folder") or obj:IsA("Tool")) and (hasKW(obj.Name,brainrotKeywords) or hasKW(obj.Name,carryKeywords)) then return true end
            if obj:IsA("BoolValue") and obj.Value==true and hasKW(obj.Name,carryKeywords) then return true end
            if obj:IsA("StringValue") and (hasKW(obj.Name,carryKeywords) or hasKW(obj.Value,brainrotKeywords) or hasKW(obj.Value,carryKeywords)) then return true end
            if obj:IsA("ObjectValue") and obj.Value and (hasKW(obj.Name,carryKeywords) or hasKW(obj.Value.Name,brainrotKeywords) or hasKW(obj.Value.Name,carryKeywords)) then return true end
        end
    end
    return false
end

local function getMoveSpeed()
    return isHoldingBrainrot() and SLOW_SPEED or NORMAL_SPEED
end

RunService.Heartbeat:Connect(function()
    if not gChar or not gHum or not gHrp then return end
    if speedCustomizerActive and not batAimbotEnabled and not AP_LeftOn and not AP_RightOn then
        local md = gHum.MoveDirection
        if md.Magnitude > 0.1 then
            local spd = getMoveSpeed()
            gHrp.AssemblyLinearVelocity = v3new(md.X*spd, gHrp.AssemblyLinearVelocity.Y, md.Z*spd)
        end
    end
end)

-- ── CHARACTER SETUP ──────────────────────────────────────────
local function setupChar(c)
    gChar = c
    gHum  = c:WaitForChild("Humanoid",5)
    gHrp  = c:WaitForChild("HumanoidRootPart",5)
    if not gHum or not gHrp then return end
    task.wait(0.5); makeSpeedBB()
    if antiRagdollEnabled then stopAntiRagdoll(); startAntiRagdoll() end
    if espEnabled         then enableESP() end
    if batAimbotEnabled   then stopBatAimbot(); startBatAimbot() end
    if unwalkEnabled      then startUnwalk() end
    if medusaCounterEnabled then setupMedusaCounter(c) end
end
if player.Character then setupChar(player.Character) end
player.CharacterAdded:Connect(function(c) task.wait(0.5); setupChar(c) end)

-- ===================== GUI =====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name            = "BloomHub"
ScreenGui.ResetOnSpawn    = false
ScreenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset  = false
ScreenGui.Parent          = player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name            = "MainFrame"
MainFrame.Size            = udim2new(0,270,0,480)
MainFrame.Position        = udim2new(0.5,-135,0.5,-240)
MainFrame.BackgroundColor3= WHITE
MainFrame.BorderSizePixel = 0
MainFrame.Active          = true
MainFrame.Visible         = false
MainFrame.Parent          = ScreenGui
Instance.new("UICorner",MainFrame).CornerRadius = UDim.new(0,16)

local MainStroke = Instance.new("UIStroke",MainFrame)
MainStroke.Thickness       = 3
MainStroke.Color           = ACCENT
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Transparency    = 0
task.spawn(function()
    local _ti = TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    local up  = TweenService:Create(MainStroke, _ti, {Thickness=4})
    local dn  = TweenService:Create(MainStroke, _ti, {Thickness=3})
    while MainFrame and MainFrame.Parent do
        up:Play(); task.wait(0.8)
        dn:Play(); task.wait(0.8)
    end
end)

-- Title bar
local TitleBar = Instance.new("Frame",MainFrame)
TitleBar.Size=udim2new(1,0,0,44); TitleBar.BackgroundColor3=BG; TitleBar.BorderSizePixel=0
Instance.new("UICorner",TitleBar).CornerRadius=UDim.new(0,16)
local TitleFix = Instance.new("Frame",TitleBar)
TitleFix.Size=udim2new(1,0,0,16); TitleFix.Position=udim2new(0,0,1,-16); TitleFix.BackgroundColor3=BG; TitleFix.BorderSizePixel=0
local TitleAccent = Instance.new("Frame",TitleBar)
TitleAccent.Size=udim2new(1,0,0,2); TitleAccent.Position=udim2new(0,0,1,-2); TitleAccent.BackgroundColor3=ACCENT; TitleAccent.BorderSizePixel=0
local TitleLbl = Instance.new("TextLabel",TitleBar)
TitleLbl.Size=udim2new(0,110,1,-2); TitleLbl.Position=udim2new(0,12,0,0); TitleLbl.BackgroundTransparency=1
TitleLbl.Text="Bloom Hub"; TitleLbl.Font=Enum.Font.GothamBlack; TitleLbl.TextSize=15; TitleLbl.TextColor3=ACCENT
TitleLbl.TextXAlignment=Enum.TextXAlignment.Left; TitleLbl.TextYAlignment=Enum.TextYAlignment.Center
-- Tab bar
local TabBar = Instance.new("Frame",MainFrame)
TabBar.Size=udim2new(1,-20,0,28); TabBar.Position=udim2new(0,10,0,48); TabBar.BackgroundTransparency=1
local TabLayout = Instance.new("UIListLayout",TabBar)
TabLayout.FillDirection=Enum.FillDirection.Horizontal; TabLayout.Padding=UDim.new(0,3); TabLayout.SortOrder=Enum.SortOrder.LayoutOrder

local function makeTab(parent,txt,order)
    local btn = Instance.new("TextButton",parent)
    btn.Size=udim2new(0.25,-3,1,0); btn.BackgroundColor3=Color3.fromRGB(240,210,230)
    btn.BorderSizePixel=0; btn.Text=txt; btn.Font=Enum.Font.GothamBlack; btn.TextSize=10
    btn.TextColor3=ACCENT; btn.LayoutOrder=order; btn.AutoButtonColor=false
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)
    return btn
end
local CombatTabBtn = makeTab(TabBar,"COMBAT",1)
local VisTabBtn    = makeTab(TabBar,"VISUAL",2)
local MovTabBtn    = makeTab(TabBar,"MOVEMENT",3)
local SetTabBtn    = makeTab(TabBar,"SETTINGS",4)

local function makeScrollFrame()
    local sf = Instance.new("ScrollingFrame",MainFrame)
    sf.Size=udim2new(1,-20,1,-86); sf.Position=udim2new(0,10,0,82)
    sf.BackgroundTransparency=1; sf.BorderSizePixel=0; sf.ScrollBarThickness=4; sf.ScrollBarImageColor3=ACCENT
    sf.CanvasSize=udim2new(0,0,0,0); sf.AutomaticCanvasSize=Enum.AutomaticSize.Y; sf.Visible=false
    local ll = Instance.new("UIListLayout",sf); ll.Padding=UDim.new(0,6); ll.SortOrder=Enum.SortOrder.LayoutOrder
    return sf
end

local FeatFrame = makeScrollFrame(); FeatFrame.Visible=true
local VisFrame  = makeScrollFrame()
local MovFrame  = makeScrollFrame()
local SetFrame  = makeScrollFrame()
local BindFrame = SetFrame

local allTabs = {
    {btn=CombatTabBtn, frame=FeatFrame},
    {btn=VisTabBtn,    frame=VisFrame},
    {btn=MovTabBtn,    frame=MovFrame},
    {btn=SetTabBtn,    frame=SetFrame},
}
local function setTabActive(btn,active)
    btn.BackgroundColor3 = active and ACCENT or Color3.fromRGB(240,210,230)
    btn.TextColor3       = active and WHITE  or ACCENT
end
local function switchTab(activeBtn,activeFrame)
    for _,t in ipairs(allTabs) do
        t.frame.Visible = (t.frame==activeFrame)
        setTabActive(t.btn, t.btn==activeBtn)
    end
end
switchTab(CombatTabBtn,FeatFrame)
CombatTabBtn.MouseButton1Click:Connect(function() switchTab(CombatTabBtn,FeatFrame) end)
VisTabBtn   .MouseButton1Click:Connect(function() switchTab(VisTabBtn,   VisFrame)  end)
MovTabBtn   .MouseButton1Click:Connect(function() switchTab(MovTabBtn,   MovFrame)  end)
SetTabBtn   .MouseButton1Click:Connect(function() switchTab(SetTabBtn,   SetFrame)  end)

-- ── UI COMPONENT FACTORIES ───────────────────────────────────
local function makeToggle(parent,name,order,callback,defaultOn)
    local row = Instance.new("Frame",parent)
    row.Size=udim2new(1,0,0,44); row.BackgroundColor3=CARD; row.BorderSizePixel=0; row.LayoutOrder=order
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,10)
    local rowStroke = Instance.new("UIStroke",row); rowStroke.Color=ACCENT; rowStroke.Thickness=1; rowStroke.Transparency=0.7
    local lbl = Instance.new("TextLabel",row)
    lbl.Size=udim2new(1,-70,1,0); lbl.Position=udim2new(0,14,0,0); lbl.BackgroundTransparency=1
    lbl.Text=name; lbl.TextColor3=PINK_TEXT; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=13
    lbl.TextXAlignment=Enum.TextXAlignment.Left
    local pW,pH,dSz = 46,24,18
    local track = Instance.new("Frame",row)
    track.Size=udim2new(0,pW,0,pH); track.Position=udim2new(1,-(pW+12),0.5,-pH/2)
    local initState = (SavedToggleStates[name]~=nil) and SavedToggleStates[name] or (defaultOn or false)
    track.BackgroundColor3 = initState and ACCENT or OFF_CLR
    track.BorderSizePixel  = 0
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
    local dot = Instance.new("Frame",track)
    dot.Size             = udim2new(0,dSz,0,dSz)
    dot.Position         = initState and udim2new(1,-dSz-3,0.5,-dSz/2) or udim2new(0,3,0.5,-dSz/2)
    dot.BackgroundColor3 = WHITE; dot.BorderSizePixel=0
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
    toggleStates[name] = {track=track, dot=dot, state=initState, dotSz=dSz}
    if initState and callback then task.defer(function() callback(true) end) end
    local btn = Instance.new("TextButton",row)
    btn.Size=udim2new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""
    btn.MouseButton1Click:Connect(function()
        local ns = not toggleStates[name].state
        toggleStates[name].state = ns
        track.BackgroundColor3   = ns and ACCENT or OFF_CLR
        dot.Position             = ns and udim2new(1,-dSz-3,0.5,-dSz/2) or udim2new(0,3,0.5,-dSz/2)
        if callback then callback(ns) end
        task.defer(saveConfig)
    end)
    return row
end

local function updateToggle(name,state)
    local t = toggleStates[name]; if not t then return end
    t.state = state
    t.track.BackgroundColor3 = state and ACCENT or OFF_CLR
    t.dot.Position           = state and udim2new(1,-t.dotSz-3,0.5,-t.dotSz/2) or udim2new(0,3,0.5,-t.dotSz/2)
    local btn = mobBtnRefs[name]
    if btn then btn.BackgroundColor3=MOB_ON; btn.TextColor3=WHITE end
end

local function makeSection(parent,text,order)
    local lbl = Instance.new("TextLabel",parent)
    lbl.Size=udim2new(1,0,0,26); lbl.BackgroundTransparency=1; lbl.Text=text
    lbl.TextColor3=ACCENT; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=11
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.LayoutOrder=order
end

local function makeNumInput(parent,labelText,defaultVal,order,onChanged)
    local row = Instance.new("Frame",parent)
    row.Size=udim2new(1,0,0,44); row.BackgroundColor3=CARD; row.BorderSizePixel=0; row.LayoutOrder=order
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,10)
    local rowStroke = Instance.new("UIStroke",row); rowStroke.Color=ACCENT; rowStroke.Thickness=1; rowStroke.Transparency=0.7
    local lbl = Instance.new("TextLabel",row)
    lbl.Size=udim2new(1,-90,1,0); lbl.Position=udim2new(0,14,0,0); lbl.BackgroundTransparency=1
    lbl.Text=labelText; lbl.TextColor3=PINK_TEXT; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=13
    lbl.TextXAlignment=Enum.TextXAlignment.Left
    local box = Instance.new("TextBox",row)
    box.Size=udim2new(0,68,0,28); box.Position=udim2new(1,-78,0.5,-14)
    box.BackgroundColor3=Color3.fromRGB(255,230,242); box.Text=tostring(defaultVal)
    box.TextColor3=ACCENT; box.Font=Enum.Font.GothamBold; box.TextSize=13
    box.TextXAlignment=Enum.TextXAlignment.Center; box.BorderSizePixel=0; box.ClearTextOnFocus=false
    Instance.new("UICorner",box).CornerRadius=UDim.new(0,6)
    local boxStroke = Instance.new("UIStroke",box); boxStroke.Color=ACCENT; boxStroke.Thickness=1; boxStroke.Transparency=0.5
    box.FocusLost:Connect(function()
        local n = tonumber(box.Text)
        if n then if onChanged then onChanged(n) end; task.defer(saveConfig)
        else box.Text=tostring(defaultVal) end
    end)
    return row, box
end

-- ── FEATURES TAB ─────────────────────────────────────────────
makeSection(FeatFrame,"  COMBAT",1)
makeToggle(FeatFrame,"Anti Ragdoll",3,function(v) antiRagdollEnabled=v; if v then startAntiRagdoll() else stopAntiRagdoll() end end)
makeToggle(FeatFrame,"Medusa Counter",4,function(v)
    medusaCounterEnabled=v
    if v then setupMedusaCounter(player.Character) else stopMedusaCounter() end
end)
makeToggle(FeatFrame,"Unwalk",5,function(v) unwalkEnabled=v; if v then startUnwalk() else stopUnwalk() end end)
makeToggle(FeatFrame,"Bat Counter",5.5,function(v)
    batCounterEnabled=v
    if v then startBatCounter() else stopBatCounter() end
end)
makeSection(FeatFrame,"  STEAL",6)
makeToggle(FeatFrame,"Auto Steal",7,function(v) autoStealEnabled=v; if v then startAutoSteal() else stopAutoSteal() end end)

-- ── MOVEMENT TAB ─────────────────────────────────────────────
makeSection(MovFrame,"  MOVEMENT",19)
makeToggle(MovFrame,"Inf Jump",19.2,function(v) infJumpEnabled=v end)
makeNumInput(MovFrame,"Pre-Round Speed",AP_PRE_ROUND_SPD,19.5,function(v) AP_PRE_ROUND_SPD=mmax(1,v) end)

do
    -- Waypoint editor helpers
    local function makeSideLabel(parent,txt,order)
        local f = Instance.new("Frame",parent)
        f.Size=udim2new(1,0,0,24); f.BackgroundTransparency=1; f.BorderSizePixel=0; f.LayoutOrder=order
        local l = Instance.new("TextLabel",f)
        l.Size=udim2new(1,0,1,0); l.BackgroundTransparency=1; l.Text=txt
        l.TextColor3=ACCENT; l.Font=Enum.Font.GothamBold; l.TextSize=11
        l.TextXAlignment=Enum.TextXAlignment.Left
        local line = Instance.new("Frame",f)
        line.Size=udim2new(1,0,0,1); line.Position=udim2new(0,0,1,-1)
        line.BackgroundColor3=ACCENT; line.BackgroundTransparency=0.6; line.BorderSizePixel=0
    end

    local function makeWPRow(parent,label,order,getPos,setPos)
        local row = Instance.new("Frame",parent)
        row.Size=udim2new(1,0,0,46); row.BackgroundColor3=CARD; row.BorderSizePixel=0; row.LayoutOrder=order
        Instance.new("UICorner",row).CornerRadius=UDim.new(0,10)
        local rowStroke=Instance.new("UIStroke",row); rowStroke.Color=ACCENT; rowStroke.Thickness=1; rowStroke.Transparency=0.6
        local lbl = Instance.new("TextLabel",row)
        lbl.Size=udim2new(0,36,1,0); lbl.Position=udim2new(0,10,0,0); lbl.BackgroundTransparency=1
        lbl.Text=label; lbl.TextColor3=PINK_TEXT; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=12
        lbl.TextXAlignment=Enum.TextXAlignment.Left

        local function makeBox(xOff,val,clr)
            local b = Instance.new("TextBox",row)
            b.Size=udim2new(0,54,0,30); b.Position=udim2new(0,xOff,0.5,-15)
            b.BackgroundColor3=Color3.fromRGB(255,230,242); b.Text=string.format("%.2f",val)
            b.TextColor3=clr; b.Font=Enum.Font.GothamBold; b.TextSize=11
            b.TextXAlignment=Enum.TextXAlignment.Center; b.BorderSizePixel=0; b.ClearTextOnFocus=false
            Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
            local bs=Instance.new("UIStroke",b); bs.Color=ACCENT; bs.Thickness=1; bs.Transparency=0.6
            return b
        end
        local p = getPos()
        local xBox = makeBox(48,  p.X, ACCENT)
        local yBox = makeBox(106, p.Y, Color3.fromRGB(100,200,120))
        local zBox = makeBox(164, p.Z, Color3.fromRGB(100,160,255))
        for _,d in ipairs({{48,"X"},{106,"Y"},{164,"Z"}}) do
            local al = Instance.new("TextLabel",row)
            al.Size=udim2new(0,54,0,10); al.Position=udim2new(0,d[1],0,2); al.BackgroundTransparency=1
            al.Text=d[2]; al.Font=Enum.Font.GothamBold; al.TextSize=8
            al.TextColor3=PINK_TEXT; al.TextXAlignment=Enum.TextXAlignment.Center
        end
        local function apply()
            local x,y,z = tonumber(xBox.Text), tonumber(yBox.Text), tonumber(zBox.Text)
            if x and y and z then setPos(v3new(x,y,z)); task.defer(saveConfig); task.defer(refreshWPEsp) end
        end
        xBox.FocusLost:Connect(apply); yBox.FocusLost:Connect(apply); zBox.FocusLost:Connect(apply)
    end

    makeSection(MovFrame,"  WAYPOINT EDITOR",20)
    makeSideLabel(MovFrame,"  ◀ LEFT PATH",21)
    makeWPRow(MovFrame,"P1:",22,function() return POS_L1 end,function(v) POS_L1=v end)
    makeWPRow(MovFrame,"P2:",23,function() return POS_L2 end,function(v) POS_L2=v end)
    makeWPRow(MovFrame,"P3:",24,function() return POS_L3 end,function(v) POS_L3=v end)
    makeWPRow(MovFrame,"P4:",25,function() return POS_L4 end,function(v) POS_L4=v end)
    makeWPRow(MovFrame,"P5:",26,function() return POS_L5 end,function(v) POS_L5=v end)
    makeSideLabel(MovFrame,"  ▶ RIGHT PATH",27)
    makeWPRow(MovFrame,"P1:",28,function() return POS_R1 end,function(v) POS_R1=v end)
    makeWPRow(MovFrame,"P2:",29,function() return POS_R2 end,function(v) POS_R2=v end)
    makeWPRow(MovFrame,"P3:",30,function() return POS_R3 end,function(v) POS_R3=v end)
    makeWPRow(MovFrame,"P4:",31,function() return POS_R4 end,function(v) POS_R4=v end)
    makeWPRow(MovFrame,"P5:",32,function() return POS_R5 end,function(v) POS_R5=v end)

    -- Waypoint speed editor
    makeSection(MovFrame,"  WAYPOINT SPEEDS",33)
    do
        local function makeWPSpeedRow(order,label,getLSpd,setLSpd,getRSpd,setRSpd)
            local row = Instance.new("Frame",MovFrame)
            row.Size=udim2new(1,0,0,44); row.BackgroundColor3=CARD; row.BorderSizePixel=0; row.LayoutOrder=order
            Instance.new("UICorner",row).CornerRadius=UDim.new(0,10)
            local rowStroke=Instance.new("UIStroke",row); rowStroke.Color=ACCENT; rowStroke.Thickness=1; rowStroke.Transparency=0.7
            local lbl=Instance.new("TextLabel",row)
            lbl.Size=udim2new(0,28,1,0); lbl.Position=udim2new(0,10,0,0); lbl.BackgroundTransparency=1
            lbl.Text=label; lbl.TextColor3=PINK_TEXT; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=13
            lbl.TextXAlignment=Enum.TextXAlignment.Left
            local function makeBox(xPos,capText,getV,setV,clr)
                local cap=Instance.new("TextLabel",row)
                cap.Size=udim2new(0,12,0,16); cap.Position=udim2new(0,xPos-14,0.5,-8); cap.BackgroundTransparency=1
                cap.Text=capText; cap.TextColor3=clr; cap.Font=Enum.Font.GothamBold; cap.TextSize=10
                local box=Instance.new("TextBox",row)
                box.Size=udim2new(0,68,0,28); box.Position=udim2new(0,xPos,0.5,-14)
                box.BackgroundColor3=Color3.fromRGB(255,230,242); box.Text=tostring(getV())
                box.TextColor3=clr; box.Font=Enum.Font.GothamBold; box.TextSize=13
                box.TextXAlignment=Enum.TextXAlignment.Center; box.BorderSizePixel=0; box.ClearTextOnFocus=false
                Instance.new("UICorner",box).CornerRadius=UDim.new(0,6)
                local bs=Instance.new("UIStroke",box); bs.Color=ACCENT; bs.Thickness=1; bs.Transparency=0.5
                box.FocusLost:Connect(function()
                    local n=tonumber(box.Text)
                    if n then setV(mmax(1,n)); task.defer(saveConfig)
                    else box.Text=tostring(getV()) end
                end)
                return box
            end
            makeBox(40, "L", getLSpd, setLSpd, ACCENT)
            makeBox(136,"R", getRSpd, setRSpd, Color3.fromRGB(100,160,255))
        end
        for i=1,5 do
            makeWPSpeedRow(33+i, "P"..i..":",
                function() return WP_L_SPD[i] end, function(v) WP_L_SPD[i]=v end,
                function() return WP_R_SPD[i] end, function(v) WP_R_SPD[i]=v end)
        end
    end
end

-- ── VISUAL TAB ───────────────────────────────────────────────
makeSection(VisFrame,"  VISUAL",99)
makeToggle(VisFrame,"Player ESP",101,function(v) espEnabled=v; if v then enableESP() else disableESP() end end)
makeToggle(VisFrame,"Waypoint ESP",102,function(v)
    wpEspEnabled=v; if v then enableWPEsp() else disableWPEsp() end
end)

-- ── SETTINGS TAB ─────────────────────────────────────────────
makeSection(SetFrame,"  SPEED CUSTOMIZER",100)
do
    local sfActive = false
    local sfSavedNormal, sfSavedCarry = NORMAL_SPEED, SLOW_SPEED
    NORMAL_SPEED = 16; SLOW_SPEED = 16
    local pW,pH,dSz = 46,24,18

    local activeRow = Instance.new("Frame",SetFrame)
    activeRow.Size=udim2new(1,0,0,44); activeRow.BackgroundColor3=CARD; activeRow.BorderSizePixel=0; activeRow.LayoutOrder=101
    Instance.new("UICorner",activeRow).CornerRadius=UDim.new(0,10)
    local rs=Instance.new("UIStroke",activeRow); rs.Color=ACCENT; rs.Thickness=1; rs.Transparency=0.7
    local activeLbl=Instance.new("TextLabel",activeRow)
    activeLbl.Size=udim2new(0.6,0,1,0); activeLbl.Position=udim2new(0,14,0,0); activeLbl.BackgroundTransparency=1
    activeLbl.Text="Speed Active"; activeLbl.TextColor3=PINK_TEXT; activeLbl.Font=Enum.Font.GothamBold
    activeLbl.TextSize=13; activeLbl.TextXAlignment=Enum.TextXAlignment.Left
    local sfTrack=Instance.new("Frame",activeRow)
    sfTrack.Size=udim2new(0,pW,0,pH); sfTrack.Position=udim2new(1,-(pW+12),0.5,-pH/2)
    sfTrack.BackgroundColor3=OFF_CLR; sfTrack.BorderSizePixel=0
    Instance.new("UICorner",sfTrack).CornerRadius=UDim.new(1,0)
    local sfDot=Instance.new("Frame",sfTrack)
    sfDot.Size=udim2new(0,dSz,0,dSz); sfDot.Position=udim2new(0,3,0.5,-dSz/2)
    sfDot.BackgroundColor3=WHITE; sfDot.BorderSizePixel=0
    Instance.new("UICorner",sfDot).CornerRadius=UDim.new(1,0)

    local function setSpeedCustomizerActive(on)
        if on then
            sfActive=true; speedCustomizerActive=true
            NORMAL_SPEED=sfSavedNormal; SLOW_SPEED=sfSavedCarry
            sfTrack.BackgroundColor3=ACCENT; sfDot.Position=udim2new(1,-dSz-3,0.5,-dSz/2)
        else
            if sfActive then sfSavedNormal=NORMAL_SPEED; sfSavedCarry=SLOW_SPEED end
            sfActive=false; speedCustomizerActive=false
            NORMAL_SPEED=16; SLOW_SPEED=16
            sfTrack.BackgroundColor3=OFF_CLR; sfDot.Position=udim2new(0,4,0.5,-dSz/2)
            local chr=player.Character
            if chr then
                local hum=chr:FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed=16 end
                local hrp=chr:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.AssemblyLinearVelocity=v3new(0,hrp.AssemblyLinearVelocity.Y,0) end
            end
        end
    end
    local activeBtn=Instance.new("TextButton",activeRow)
    activeBtn.Size=udim2new(1,0,1,0); activeBtn.BackgroundTransparency=1; activeBtn.Text=""
    activeBtn.MouseButton1Click:Connect(function() setSpeedCustomizerActive(not sfActive) end)

    local function makeSpeedRow(labelTxt,order,getV,setV)
        local row=Instance.new("Frame",SetFrame)
        row.Size=udim2new(1,0,0,44); row.BackgroundColor3=CARD; row.BorderSizePixel=0; row.LayoutOrder=order
        Instance.new("UICorner",row).CornerRadius=UDim.new(0,10)
        local rs2=Instance.new("UIStroke",row); rs2.Color=ACCENT; rs2.Thickness=1; rs2.Transparency=0.7
        local lbl2=Instance.new("TextLabel",row)
        lbl2.Size=udim2new(0.55,0,1,0); lbl2.Position=udim2new(0,14,0,0); lbl2.BackgroundTransparency=1
        lbl2.Text=labelTxt; lbl2.TextColor3=PINK_TEXT; lbl2.Font=Enum.Font.GothamBold
        lbl2.TextSize=13; lbl2.TextXAlignment=Enum.TextXAlignment.Left
        local box=Instance.new("TextBox",row)
        box.Size=udim2new(0,68,0,28); box.Position=udim2new(1,-78,0.5,-14)
        box.BackgroundColor3=Color3.fromRGB(255,230,242); box.Text=tostring(getV())
        box.TextColor3=ACCENT; box.Font=Enum.Font.GothamBold; box.TextSize=13
        box.TextXAlignment=Enum.TextXAlignment.Center; box.BorderSizePixel=0; box.ClearTextOnFocus=false
        Instance.new("UICorner",box).CornerRadius=UDim.new(0,6)
        local bs=Instance.new("UIStroke",box); bs.Color=ACCENT; bs.Thickness=1; bs.Transparency=0.5
        box.FocusLost:Connect(function()
            local n=tonumber(box.Text)
            if n then setV(n); task.defer(saveConfig)
            else box.Text=tostring(getV()) end
        end)
    end
    makeSpeedRow("Normal Speed",102,
        function() return sfActive and NORMAL_SPEED or sfSavedNormal end,
        function(n) if sfActive then NORMAL_SPEED=n else sfSavedNormal=n end end)
    makeSpeedRow("Carry Speed",103,
        function() return sfActive and SLOW_SPEED or sfSavedCarry end,
        function(n) if sfActive then SLOW_SPEED=n else sfSavedCarry=n end end)
end

makeSection(SetFrame,"  STEAL",150)
local _,_srb = makeNumInput(SetFrame,"Steal Radius",STEAL_RADIUS,151,function(v)
    STEAL_RADIUS=mclamp(v,5,200); if RadiusInput then RadiusInput.Text=tostring(STEAL_RADIUS) end
end)
StealRadiusBox = _srb
makeNumInput(SetFrame,"Steal Duration",STEAL_DURATION,152,function(v) STEAL_DURATION=mmax(0.05,v) end)
makeSection(SetFrame,"  BAT",153)
makeNumInput(SetFrame,"Aimbot Speed",AIMBOT_SPEED,155,function(v) AIMBOT_SPEED=v end)
makeNumInput(SetFrame,"Engage Range",BAT_ENGAGE_RANGE,156,function(v) BAT_ENGAGE_RANGE=v end)
makeSection(SetFrame,"  UI",157)
makeToggle(SetFrame,"UI Lock",158,function(v) stealBarLocked=v; mobBtnsLocked=v end)

-- Keybinds
makeSection(BindFrame,"  KEYBINDS (click to rebind)",169)
do
    local bindHint=Instance.new("TextLabel",BindFrame)
    bindHint.Size=udim2new(1,0,0,36); bindHint.BackgroundColor3=Color3.fromRGB(255,220,240)
    bindHint.BackgroundTransparency=0; bindHint.BorderSizePixel=0
    bindHint.Text="Click a key button then press\nany key to rebind. CTRL = clear."
    bindHint.TextColor3=PINK_TEXT; bindHint.Font=Enum.Font.Gotham
    bindHint.TextSize=11; bindHint.TextWrapped=true; bindHint.LayoutOrder=171
    Instance.new("UICorner",bindHint).CornerRadius=UDim.new(0,8)
end

local bindList = {
    {"Auto Steal","AutoSteal"},
    {"Lock","BatAimbot"},{"Anti Ragdoll","AntiRagdoll"},{"Unwalk","Unwalk"},
    {"Drop","Drop"},{"TP Down","TPDown"},
}
for idx,entry in ipairs(bindList) do
    local displayName, keyName = entry[1], entry[2]
    local row=Instance.new("Frame",BindFrame)
    row.Size=udim2new(1,0,0,44); row.BackgroundColor3=CARD; row.BorderSizePixel=0; row.LayoutOrder=172+idx
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,10)
    local rowStroke=Instance.new("UIStroke",row); rowStroke.Color=ACCENT; rowStroke.Thickness=1; rowStroke.Transparency=0.7
    local nameLbl=Instance.new("TextLabel",row)
    nameLbl.Size=udim2new(1,-110,1,0); nameLbl.Position=udim2new(0,14,0,0); nameLbl.BackgroundTransparency=1
    nameLbl.Text=displayName; nameLbl.TextColor3=PINK_TEXT; nameLbl.Font=Enum.Font.GothamBold
    nameLbl.TextSize=13; nameLbl.TextXAlignment=Enum.TextXAlignment.Left
    local keyBtn=Instance.new("TextButton",row)
    keyBtn.Size=udim2new(0,90,0,30); keyBtn.Position=udim2new(1,-98,0.5,-15)
    keyBtn.BackgroundColor3=Color3.fromRGB(255,220,240)
    keyBtn.Text=Keybinds[keyName] and tostring(Keybinds[keyName]):gsub("Enum.KeyCode.","") or "NONE"
    keyBtn.Font=Enum.Font.GothamBold; keyBtn.TextSize=11; keyBtn.TextColor3=ACCENT; keyBtn.BorderSizePixel=0
    Instance.new("UICorner",keyBtn).CornerRadius=UDim.new(0,8)
    local kb=Instance.new("UIStroke",keyBtn); kb.Color=ACCENT; kb.Thickness=1; kb.Transparency=0.5
    KeybindButtons[keyName] = keyBtn
    keyBtn.MouseButton1Click:Connect(function()
        if changingKeybind then return end
        changingKeybind=keyName; keyBtn.Text="Press key..."; keyBtn.TextColor3=Color3.fromRGB(255,150,80)
        local conn; conn=UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.Keyboard then
                if input.KeyCode==Enum.KeyCode.LeftControl or input.KeyCode==Enum.KeyCode.RightControl then
                    Keybinds[keyName]=nil; keyBtn.Text="NONE"
                else
                    Keybinds[keyName]=input.KeyCode
                    keyBtn.Text=tostring(input.KeyCode):gsub("Enum.KeyCode.","")
                end
                keyBtn.TextColor3=ACCENT; changingKeybind=nil; conn:Disconnect()
                task.defer(saveConfig)
            end
        end)
    end)
end

-- ── MOBILE BUTTONS (grouped in a draggable cage) ─────────────
local dropMobBtnRef=nil; local tpMobBtnRef=nil
do
    local DRAG_THRESHOLD = 10
    local BTN_W, BTN_H, GAP, PAD = 90, 50, 6, 8
    local BTN_COUNT = 4
    local CAGE_W = BTN_W + PAD*2
    local CAGE_H = BTN_H*BTN_COUNT + GAP*(BTN_COUNT-1) + PAD*2

    -- Cage (the box that holds every mobile button)
    local cage = Instance.new("Frame", ScreenGui)
    cage.Name             = "BloomMobCage"
    cage.Size             = udim2new(0, CAGE_W, 0, CAGE_H)
    local savedCagePos    = mobBtnPositions["MBCage"]
    cage.Position         = savedCagePos
        and udim2new(savedCagePos[1], savedCagePos[2], savedCagePos[3], savedCagePos[4])
        or  udim2new(1, -CAGE_W-30, 0.5, -CAGE_H/2)
    cage.BackgroundColor3 = CARD
    cage.BackgroundTransparency = 0.15
    cage.BorderSizePixel  = 0
    cage.ZIndex           = 19
    cage.Active           = true
    Instance.new("UICorner", cage).CornerRadius = UDim.new(0, 16)
    local cs = Instance.new("UIStroke", cage)
    cs.Color = ACCENT; cs.Thickness = 1.4; cs.Transparency = 0.25
    local pad = Instance.new("UIPadding", cage)
    pad.PaddingTop    = UDim.new(0, PAD)
    pad.PaddingBottom = UDim.new(0, PAD)
    pad.PaddingLeft   = UDim.new(0, PAD)
    pad.PaddingRight  = UDim.new(0, PAD)
    local list = Instance.new("UIListLayout", cage)
    list.FillDirection      = Enum.FillDirection.Vertical
    list.HorizontalAlignment = Enum.HorizontalAlignment.Center
    list.SortOrder          = Enum.SortOrder.LayoutOrder
    list.Padding            = UDim.new(0, GAP)

    -- Drag the whole cage as one unit
    cage.InputBegan:Connect(function(input)
        if input.UserInputType~=Enum.UserInputType.Touch and input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
        if mobBtnsLocked then return end
        local startPos = cage.Position; local startVec = input.Position; local moved = false
        local conn; conn = input.Changed:Connect(function()
            if input.UserInputState==Enum.UserInputState.Change then
                local d = input.Position - startVec
                if d.Magnitude > DRAG_THRESHOLD then
                    moved = true
                    cage.Position = udim2new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
                end
            elseif input.UserInputState==Enum.UserInputState.End then
                conn:Disconnect()
                if moved then
                    local p = cage.Position
                    mobBtnPositions["MBCage"] = {p.X.Scale, p.X.Offset, p.Y.Scale, p.Y.Offset}
                    task.defer(saveConfig)
                end
            end
        end)
    end)

    local function makeMob(label, order, toggleName, onAct)
        local btn = Instance.new("TextButton", cage)
        btn.Size              = udim2new(0, BTN_W, 0, BTN_H)
        btn.LayoutOrder       = order
        btn.BackgroundColor3  = MOB_ON
        btn.BackgroundTransparency = 0
        btn.Text              = label:upper()
        btn.TextColor3        = WHITE
        btn.Font              = Enum.Font.GothamBold
        btn.TextSize          = 11
        btn.TextWrapped       = true
        btn.BorderSizePixel   = 0
        btn.ZIndex            = 20
        btn.AutoButtonColor   = false
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
        local s = Instance.new("UIStroke", btn)
        s.Color = WHITE; s.Thickness = 1.2; s.Transparency = 0.5
        tinsert(mobileButtons, btn)
        if toggleName then mobBtnRefs[toggleName] = btn end
        -- Tap = activate. Drag is owned by the cage so per-button dragging is disabled.
        btn.InputBegan:Connect(function(input)
            if input.UserInputType~=Enum.UserInputType.Touch and input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
            local startVec = input.Position; local moved = false
            local conn; conn = input.Changed:Connect(function()
                if input.UserInputState==Enum.UserInputState.Change then
                    if (input.Position - startVec).Magnitude > DRAG_THRESHOLD then moved = true end
                elseif input.UserInputState==Enum.UserInputState.End then
                    conn:Disconnect()
                    if not moved then task.spawn(onAct) end
                end
            end)
        end)
        return btn
    end

    -- Order: AUTO PLAY → LOCK (Bat) → TP DOWN → DROP
    local apBtn = makeMob("AUTO\nPLAY", 1, nil, function() AP_Toggle() end)
    AP_SetVisual = function(state)
        apBtn.BackgroundColor3 = state and WHITE  or MOB_ON
        apBtn.TextColor3       = state and ACCENT or WHITE
        apBtn.Text             = state and "STOP\nAP" or "AUTO\nPLAY"
    end

    local autoBatBtn = makeMob("LOCK", 2, "Lock", function()
        local ns = not(toggleStates["Lock"] and toggleStates["Lock"].state)
        if ns then
            if AP_LeftOn  then AP_LeftOn=false;  AP_StopLeft();  if AP_SetVisual then AP_SetVisual(false) end end
            if AP_RightOn then AP_RightOn=false; AP_StopRight(); if AP_SetVisual then AP_SetVisual(false) end end
            startBatAimbot()
        else stopBatAimbot() end
        updateToggle("Lock", ns)
        if AP_LockVisual then AP_LockVisual(ns) end
    end)
    AP_LockVisual = function(state)
        autoBatBtn.Text             = state and "LOCKED" or "LOCK"
        autoBatBtn.TextColor3       = state and ACCENT   or WHITE
        autoBatBtn.BackgroundColor3 = state and WHITE    or MOB_ON
    end

    local tpMobBtn = makeMob("TP\nDOWN", 3, nil, function() task.spawn(doTPDown) end)
    tpMobBtnRef = tpMobBtn

    local dropMobBtn = makeMob("DROP", 4, nil, function() task.spawn(doDrop) end)
    dropMobBtnRef = dropMobBtn
end

-- ── OPEN/CLOSE BUTTON ────────────────────────────────────────
do
    local OCGui=Instance.new("ScreenGui",player:WaitForChild("PlayerGui"))
    OCGui.Name="BloomHubOpenClose"; OCGui.ResetOnSpawn=false; OCGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    local OBtn=Instance.new("TextButton",OCGui)
    OBtn.Size=udim2new(0,52,0,52); OBtn.Position=udim2new(0,10,0.5,-26)
    OBtn.BackgroundColor3=ACCENT; OBtn.Text="B"; OBtn.TextSize=26
    OBtn.Font=Enum.Font.GothamBlack; OBtn.TextColor3=WHITE; OBtn.BorderSizePixel=0; OBtn.Active=true
    Instance.new("UICorner",OBtn).CornerRadius=UDim.new(0,14)
    local OS=Instance.new("UIStroke",OBtn); OS.Thickness=2; OS.Color=WHITE; OS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border

    -- Pulse animations
    task.spawn(function()
        local _ti = TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        local up  = TweenService:Create(OS, _ti, {Thickness=3})
        local dn  = TweenService:Create(OS, _ti, {Thickness=2})
        while OBtn and OBtn.Parent do
            up:Play(); task.wait(0.8)
            dn:Play(); task.wait(0.8)
        end
    end)
    task.spawn(function()
        local BASE=ACCENT; local BRIGHT=Color3.fromRGB(255,120,190)
        while OBtn and OBtn.Parent do
            TweenService:Create(OBtn,TweenInfo.new(0.7,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{BackgroundColor3=BRIGHT}):Play()
            task.wait(0.72)
            TweenService:Create(OBtn,TweenInfo.new(0.7,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{BackgroundColor3=BASE}):Play()
            task.wait(0.72)
        end
    end)

    -- Drag
    do
        local dragging,dragStart,startPos=false,nil,nil
        OBtn.InputBegan:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
                dragging=true; dragStart=input.Position; startPos=OBtn.Position
                input.Changed:Connect(function() if input.UserInputState==Enum.UserInputState.End then dragging=false end end)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseMovement) then
                local d=input.Position-dragStart
                OBtn.Position=udim2new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
            end
        end)
    end

    OBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible=not MainFrame.Visible
        TweenService:Create(OS,TweenInfo.new(0.15),{Color=MainFrame.Visible and ACCENT or WHITE}):Play()
    end)
end

-- ── MAIN FRAME DRAG ──────────────────────────────────────────
do
    local dragging,dragStart,startPos=false,nil,nil
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=true; dragStart=input.Position; startPos=MainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseMovement) then
            local d=input.Position-dragStart
            MainFrame.Position=udim2new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end
    end)
end

-- ── PC KEYBIND HANDLER ───────────────────────────────────────
UserInputService.InputBegan:Connect(function(input,processed)
    if processed or changingKeybind then return end
    if input.UserInputType~=Enum.UserInputType.Keyboard then return end
    local kc = input.KeyCode
    if     Keybinds.AutoSteal   and kc==Keybinds.AutoSteal then
        local ns=not(toggleStates["Auto Steal"] and toggleStates["Auto Steal"].state)
        autoStealEnabled=ns; if ns then startAutoSteal() else stopAutoSteal() end; updateToggle("Auto Steal",ns)
    elseif Keybinds.BatAimbot   and kc==Keybinds.BatAimbot then
        local ns=not(toggleStates["Lock"] and toggleStates["Lock"].state)
        if ns then
            if AP_LeftOn  then AP_LeftOn=false;  AP_StopLeft();  if AP_SetVisual then AP_SetVisual(false) end end
            if AP_RightOn then AP_RightOn=false; AP_StopRight(); if AP_SetVisual then AP_SetVisual(false) end end
            startBatAimbot()
        else stopBatAimbot() end
        updateToggle("Lock",ns); if AP_LockVisual then AP_LockVisual(ns) end
    elseif Keybinds.AntiRagdoll and kc==Keybinds.AntiRagdoll then
        local ns=not(toggleStates["Anti Ragdoll"] and toggleStates["Anti Ragdoll"].state)
        antiRagdollEnabled=ns; if ns then startAntiRagdoll() else stopAntiRagdoll() end; updateToggle("Anti Ragdoll",ns)
    elseif Keybinds.Unwalk      and kc==Keybinds.Unwalk then
        local ns=not(toggleStates["Unwalk"] and toggleStates["Unwalk"].state)
        unwalkEnabled=ns; if ns then startUnwalk() else stopUnwalk() end; updateToggle("Unwalk",ns)
    elseif Keybinds.Drop        and kc==Keybinds.Drop   then task.spawn(doDrop)
    elseif Keybinds.TPDown      and kc==Keybinds.TPDown then task.spawn(doTPDown)
    end
end)

-- ── STARTUP ──────────────────────────────────────────────────
if espEnabled then enableESP() end
print("Bloom Hub loaded")
