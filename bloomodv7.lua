
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- PINK THEME: outer pink border, inner white background, pink text
local ACCENT  = Color3.fromRGB(255, 80, 160)      -- vivid pink accent
local WHITE   = Color3.fromRGB(255, 255, 255)
local BG      = Color3.fromRGB(255, 255, 255)      -- inner white background
local CARD    = Color3.fromRGB(255, 240, 248)      -- very light pink card
local OFF_CLR = Color3.fromRGB(220, 180, 210)
local MOB_ON  = Color3.fromRGB(255, 80, 160)
local MOB_OFF = Color3.fromRGB(200, 150, 190)
local PINK_TEXT = Color3.fromRGB(220, 50, 130)     -- pink for label text

NORMAL_SPEED=60 SLOW_SPEED=29 AP_DELAY=0
WP_L_SPD={10,60,60,29,29,29}
WP_R_SPD={10,60,60,29,29,29}
WP_L_DLY={0,0,0,0,0}
WP_R_DLY={0,0,0,0,0}
POS_L1=Vector3.new(-476.48,-6.28,92.73)
POS_L2=Vector3.new(-476.48,-6.28,92.73) POS_L3=Vector3.new(-482.85,-5.03,93.13)
POS_L4=Vector3.new(-475.68,-6.89,92.76) POS_L5=Vector3.new(-476.50,-6.46,27.58)
POS_L6=Vector3.new(-482.42,-5.03,27.84)
POS_R1=Vector3.new(-476.16,-6.52,25.62)
POS_R2=Vector3.new(-476.16,-6.52,25.62) POS_R3=Vector3.new(-483.06,-5.03,27.51)
POS_R4=Vector3.new(-476.21,-6.63,27.46) POS_R5=Vector3.new(-476.66,-6.39,92.44)
POS_R6=Vector3.new(-481.94,-5.03,92.42)

AP_LeftOn=false AP_RightOn=false
autoStealEnabled=false isStealing=false stealStartTime=nil
autoStealConn=nil progressConn=nil STEAL_RADIUS=20 STEAL_DURATION=0.35
antiRagdollEnabled=false
unwalkEnabled=false unwalkConn=nil
batAimbotEnabled=false BAT_ENGAGE_RANGE=5

AIMBOT_SPEED=60 MELEE_OFFSET=3
aimbotConnection=nil lockedTarget=nil
DEFAULT_GRAVITY=196.2
espEnabled=true espConns={} wpEspEnabled=false wpEspFolder=nil
fovValue=70 fovConn=nil
speedCustomizerActive=true
infJumpEnabled=true INF_JUMP_FORCE=54 CLAMP_FALL=80
gChar=nil gHum=nil gHrp=nil speedBB=nil
ProgressBarFill=nil ProgressLabel=nil ProgressPctLabel=nil RadiusInput=nil stealBarLocked=false mobBtnsLocked=false
mobBtnPositions={} StealBarRef=nil SavedPBCPos=nil StealRadiusBox=nil
animalCache={} promptCache={} stealCache={}
toggleStates={} mobileButtons={} mobBtnRefs={}

AntiRagdollConns={}
CONFIG_KEY="EclipseX_Duels_Config"
changingKeybind=nil
SavedToggleStates={}


Keybinds={
    AutoSteal=Enum.KeyCode.V,
    BatAimbot=Enum.KeyCode.Z,
    AntiRagdoll=Enum.KeyCode.X,
    Unwalk=Enum.KeyCode.N,
    Drop=Enum.KeyCode.F3,
    TPDown=Enum.KeyCode.G,
}
KeybindButtons={}

local aimbotHighlight=Instance.new("Highlight")
aimbotHighlight.Name="EclipseAimbotESP"
aimbotHighlight.FillColor=Color3.fromRGB(255,80,160)
aimbotHighlight.OutlineColor=Color3.fromRGB(255,255,255)
aimbotHighlight.FillTransparency=0.5 aimbotHighlight.OutlineTransparency=0
pcall(function() aimbotHighlight.Parent=player:WaitForChild("PlayerGui") end)

local function saveConfig()
    pcall(function()
        if writefile then
            local data={
                NORMAL_SPEED=NORMAL_SPEED,SLOW_SPEED=SLOW_SPEED,
                STEAL_RADIUS=STEAL_RADIUS,STEAL_DURATION=STEAL_DURATION,
                fovValue=fovValue,
                AIMBOT_SPEED=AIMBOT_SPEED,BAT_ENGAGE_RANGE=BAT_ENGAGE_RANGE,
            }
            for k,v in pairs(toggleStates) do data["TOGGLE_"..k]=v.state end
            for k,v in pairs(Keybinds) do data["KEY_"..k]=v.Name end
            local function sv(v) return {v.X,v.Y,v.Z} end
            data.POS_L1=sv(POS_L1) data.POS_L2=sv(POS_L2) data.POS_L3=sv(POS_L3) data.POS_L4=sv(POS_L4) data.POS_L5=sv(POS_L5) data.POS_L6=sv(POS_L6)
            data.POS_R1=sv(POS_R1) data.POS_R2=sv(POS_R2) data.POS_R3=sv(POS_R3) data.POS_R4=sv(POS_R4) data.POS_R5=sv(POS_R5) data.POS_R6=sv(POS_R6)
            data.WP_L_SPD=WP_L_SPD data.WP_R_SPD=WP_R_SPD data.WP_L_DLY=WP_L_DLY data.WP_R_DLY=WP_R_DLY
            for k,v in pairs(mobBtnPositions) do data["BTN_"..k]=v end
            if StealBarRef then local p=StealBarRef.Position data.PBC_POS={p.X.Scale,p.X.Offset,p.Y.Scale,p.Y.Offset} end
            writefile(CONFIG_KEY..".json",game:GetService("HttpService"):JSONEncode(data))
        end
    end)
end

local function loadConfig()
    pcall(function()
        if readfile and isfile and isfile(CONFIG_KEY..".json") then
            local ok,data=pcall(function() return game:GetService("HttpService"):JSONDecode(readfile(CONFIG_KEY..".json")) end)
            if ok and data then
                if data.NORMAL_SPEED then NORMAL_SPEED=data.NORMAL_SPEED end
                if data.SLOW_SPEED then SLOW_SPEED=data.SLOW_SPEED end
                if data.STEAL_RADIUS then STEAL_RADIUS=data.STEAL_RADIUS end
                if data.STEAL_DURATION then STEAL_DURATION=data.STEAL_DURATION end
                if data.fovValue then fovValue=data.fovValue end
                if data.AIMBOT_SPEED then AIMBOT_SPEED=data.AIMBOT_SPEED end
                if data.BAT_ENGAGE_RANGE then BAT_ENGAGE_RANGE=data.BAT_ENGAGE_RANGE end
                for k,_ in pairs(Keybinds) do
                    if data["KEY_"..k] then pcall(function() Keybinds[k]=Enum.KeyCode[data["KEY_"..k]] end) end
                end
                SavedToggleStates={}
                mobBtnPositions={}
                for k,v in pairs(data) do
                    if k:sub(1,7)=="TOGGLE_" then SavedToggleStates[k:sub(8)]=v
                    elseif k:sub(1,4)=="BTN_" then mobBtnPositions[k:sub(5)]=v end
                end
                if data.PBC_POS then SavedPBCPos=data.PBC_POS end
                local function lv(k) if data[k] then local t=data[k] return Vector3.new(t[1],t[2],t[3]) end end
                POS_L1=lv("POS_L1") or POS_L1 POS_L2=lv("POS_L2") or POS_L2 POS_L3=lv("POS_L3") or POS_L3 POS_L4=lv("POS_L4") or POS_L4 POS_L5=lv("POS_L5") or POS_L5 POS_L6=lv("POS_L6") or POS_L6
                POS_R1=lv("POS_R1") or POS_R1 POS_R2=lv("POS_R2") or POS_R2 POS_R3=lv("POS_R3") or POS_R3 POS_R4=lv("POS_R4") or POS_R4 POS_R5=lv("POS_R5") or POS_R5 POS_R6=lv("POS_R6") or POS_R6
                if data.WP_L_SPD then for i=1,6 do if data.WP_L_SPD[i] then WP_L_SPD[i]=data.WP_L_SPD[i] end end end
                if data.WP_R_SPD then for i=1,6 do if data.WP_R_SPD[i] then WP_R_SPD[i]=data.WP_R_SPD[i] end end end
                if data.WP_L_DLY then for i=1,5 do if data.WP_L_DLY[i] then WP_L_DLY[i]=data.WP_L_DLY[i] end end end
                if data.WP_R_DLY then for i=1,5 do if data.WP_R_DLY[i] then WP_R_DLY[i]=data.WP_R_DLY[i] end end end
            end
        end
    end)
end
loadConfig()


local function getHRP() local c=player.Character return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum() local c=player.Character return c and c:FindFirstChildOfClass("Humanoid") end

-- TP DOWN
local function doTPDown()
    task.spawn(function()
        pcall(function()
            local c=player.Character if not c then return end
            local hrp=c:FindFirstChild("HumanoidRootPart") if not hrp then return end
            local hum=c:FindFirstChildOfClass("Humanoid") if not hum then return end
            local rp=RaycastParams.new() rp.FilterDescendantsInstances={c} rp.FilterType=Enum.RaycastFilterType.Exclude
            local hit=workspace:Raycast(hrp.Position,Vector3.new(0,-500,0),rp)
            if hit then
                hrp.AssemblyLinearVelocity=Vector3.zero
                hrp.AssemblyAngularVelocity=Vector3.zero
                local hh=hum.HipHeight or 2
                local hy=hrp.Size.Y/2
                hrp.CFrame=CFrame.new(hit.Position.X,hit.Position.Y+hh+hy+0.1,hit.Position.Z)
                hrp.AssemblyLinearVelocity=Vector3.zero
            end
        end)
    end)
end

-- INF JUMP
UserInputService.JumpRequest:Connect(function()
    if not infJumpEnabled then return end
    local h=getHRP() if not h then return end
    h.AssemblyLinearVelocity=Vector3.new(h.AssemblyLinearVelocity.X,INF_JUMP_FORCE,h.AssemblyLinearVelocity.Z)
end)
RunService.Heartbeat:Connect(function()
    if not infJumpEnabled then return end
    local h=getHRP() if not h then return end
    if h.AssemblyLinearVelocity.Y<-CLAMP_FALL then
        h.AssemblyLinearVelocity=Vector3.new(h.AssemblyLinearVelocity.X,-CLAMP_FALL,h.AssemblyLinearVelocity.Z)
    end
end)

-- DROP (Nine Hub walk-fling)
local _wfConns={} local _wfActive=false
local function startWalkFling()
    _wfActive=true
    table.insert(_wfConns,RunService.Stepped:Connect(function()
        if not _wfActive then return end
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=player and p.Character then
                for _,part in ipairs(p.Character:GetChildren()) do
                    if part:IsA("BasePart") then part.CanCollide=false end
                end
            end
        end
    end))
    local co=coroutine.create(function()
        while _wfActive do
            RunService.Heartbeat:Wait()
            local c=player.Character
            local root=c and c:FindFirstChild("HumanoidRootPart")
            if not root then RunService.Heartbeat:Wait() continue end
            local vel=root.Velocity
            root.Velocity=vel*10000+Vector3.new(0,10000,0)
            RunService.RenderStepped:Wait()
            if root and root.Parent then root.Velocity=vel end
            RunService.Stepped:Wait()
            if root and root.Parent then root.Velocity=vel+Vector3.new(0,0.1,0) end
        end
    end)
    coroutine.resume(co) table.insert(_wfConns,co)
end
local function stopWalkFling()
    _wfActive=false
    for _,c in ipairs(_wfConns) do
        if typeof(c)=="RBXScriptConnection" then c:Disconnect()
        elseif typeof(c)=="thread" then pcall(task.cancel,c) end
    end
    _wfConns={}
end
local function doDrop() startWalkFling() task.delay(0.4,stopWalkFling) end


-- SPEED BB
local function makeSpeedBB()
    local c=player.Character if not c then return end
    local head=c:FindFirstChild("Head") if not head then return end
    if speedBB then pcall(function() speedBB:Destroy() end) end
    speedBB=Instance.new("BillboardGui") speedBB.Name="EclipseSpeedBB" speedBB.Adornee=head
    speedBB.Size=UDim2.new(0,100,0,22) speedBB.StudsOffset=Vector3.new(0,3.2,0)
    speedBB.AlwaysOnTop=true speedBB.Parent=head
    local lbl=Instance.new("TextLabel") lbl.Name="SpeedLbl" lbl.Size=UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency=1 lbl.TextColor3=ACCENT lbl.TextStrokeColor3=Color3.fromRGB(200,80,140)
    lbl.TextStrokeTransparency=0.4 lbl.Font=Enum.Font.GothamBold lbl.TextScaled=true
    lbl.Text="Speed: 0" lbl.Parent=speedBB
end
RunService.RenderStepped:Connect(function()
    if not speedBB or not speedBB.Parent then return end
    local h=getHRP() if not h then return end
    local lbl=speedBB:FindFirstChild("SpeedLbl") if not lbl then return end
    local v=h.AssemblyLinearVelocity
    lbl.Text="Speed: "..math.floor(Vector3.new(v.X,0,v.Z).Magnitude*10)/10
end)

-- ANTI RAGDOLL
local function startAntiRagdoll()
    if #AntiRagdollConns>0 then return end
    local c=player.Character or player.CharacterAdded:Wait()
    local humanoid=c:WaitForChild("Humanoid")
    local root=c:WaitForChild("HumanoidRootPart")
    local animator=humanoid:WaitForChild("Animator")
    local maxVelocity=40 local clampVelocity=25 local maxClamp=15
    local lastVelocity=Vector3.new(0,0,0)
    local function IsRagdollState()
        local state=humanoid:GetState()
        return state==Enum.HumanoidStateType.Physics or state==Enum.HumanoidStateType.Ragdoll
            or state==Enum.HumanoidStateType.FallingDown or state==Enum.HumanoidStateType.GettingUp
    end
    local function CleanRagdollEffects()
        for _,obj in pairs(c:GetDescendants()) do
            if obj:IsA("BallSocketConstraint") or obj:IsA("NoCollisionConstraint") or obj:IsA("HingeConstraint")
                or (obj:IsA("Attachment") and (obj.Name=="A" or obj.Name=="B")) then obj:Destroy()
            elseif obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyGyro") then obj:Destroy()
            elseif obj:IsA("Motor6D") then obj.Enabled=true end
        end
        for _,track in pairs(animator:GetPlayingAnimationTracks()) do
            local animName=track.Animation and track.Animation.Name:lower() or ""
            if animName:find("rag") or animName:find("fall") or animName:find("hurt") or animName:find("down") then track:Stop(0) end
        end
    end
    local function ReEnableControls()
        pcall(function() require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetControls():Enable() end)
    end
    table.insert(AntiRagdollConns,humanoid.StateChanged:Connect(function()
        if IsRagdollState() then humanoid:ChangeState(Enum.HumanoidStateType.Running) CleanRagdollEffects() workspace.CurrentCamera.CameraSubject=humanoid ReEnableControls() end
    end))
    table.insert(AntiRagdollConns,RunService.Heartbeat:Connect(function()
        if not antiRagdollEnabled then return end
        if IsRagdollState() then
            CleanRagdollEffects()
            local vel=root.AssemblyLinearVelocity
            if (vel-lastVelocity).Magnitude>maxVelocity and vel.Magnitude>clampVelocity then
                root.AssemblyLinearVelocity=vel.Unit*math.min(vel.Magnitude,maxClamp) end
            lastVelocity=vel
        end
    end))
    table.insert(AntiRagdollConns,c.DescendantAdded:Connect(function() if IsRagdollState() then CleanRagdollEffects() end end))
    table.insert(AntiRagdollConns,player.CharacterAdded:Connect(function(newChar)
        c=newChar humanoid=newChar:WaitForChild("Humanoid") root=newChar:WaitForChild("HumanoidRootPart")
        animator=humanoid:WaitForChild("Animator") lastVelocity=Vector3.new(0,0,0)
        ReEnableControls() CleanRagdollEffects()
    end))
    ReEnableControls() CleanRagdollEffects()
end
local function stopAntiRagdoll()
    for _,conn in pairs(AntiRagdollConns) do conn:Disconnect() end AntiRagdollConns={}
end

-- UNWALK
local function startUnwalk()
    if not gChar then return end
    local h2=gChar:FindFirstChildOfClass("Humanoid") if not h2 then return end
    local anim=h2:FindFirstChildOfClass("Animator") if not anim then return end
    for _,t in ipairs(anim:GetPlayingAnimationTracks()) do t:Stop(0) end
    if unwalkConn then unwalkConn:Disconnect() end
    unwalkConn=RunService.Heartbeat:Connect(function()
        if not unwalkEnabled then unwalkConn:Disconnect() unwalkConn=nil return end
        local c=player.Character if not c then return end
        local hh=c:FindFirstChildOfClass("Humanoid") if not hh then return end
        local an=hh:FindFirstChildOfClass("Animator") if not an then return end
        for _,t in ipairs(an:GetPlayingAnimationTracks()) do t:Stop(0) end
    end)
end
local function stopUnwalk() if unwalkConn then unwalkConn:Disconnect() unwalkConn=nil end end

-- ESP
local function createESP(plr)
    if plr==player or not plr.Character then return end
    local c=plr.Character
    local root=c:FindFirstChild("HumanoidRootPart") if not root then return end
    local head=c:FindFirstChild("Head") if not head then return end
    if c:FindFirstChild("EclipseESP") then return end
    local box=Instance.new("BoxHandleAdornment")
    box.Name="EclipseESP" box.Adornee=root box.Size=Vector3.new(4,6,2)
    box.Color3=ACCENT box.Transparency=0.45 box.ZIndex=10 box.AlwaysOnTop=true box.Parent=c
    local bb=Instance.new("BillboardGui")
    bb.Name="EclipseESP_Name" bb.Adornee=head bb.Size=UDim2.new(0,200,0,45)
    bb.StudsOffset=Vector3.new(0,3,0) bb.AlwaysOnTop=true bb.Parent=c
    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,0,1,0) lbl.BackgroundTransparency=1 lbl.Text=plr.DisplayName
    lbl.TextColor3=WHITE lbl.Font=Enum.Font.GothamBold lbl.TextScaled=true
    lbl.TextStrokeTransparency=0.5 lbl.TextStrokeColor3=ACCENT lbl.Parent=bb
end
local function removeESP(plr)
    if not plr.Character then return end
    local b=plr.Character:FindFirstChild("EclipseESP") local n=plr.Character:FindFirstChild("EclipseESP_Name")
    if b then b:Destroy() end if n then n:Destroy() end
end
local function enableESP()
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=player then
            if plr.Character then pcall(function() createESP(plr) end) end
            table.insert(espConns,plr.CharacterAdded:Connect(function()
                task.wait(0.1) if espEnabled then pcall(function() createESP(plr) end) end
            end))
        end
    end
    table.insert(espConns,Players.PlayerAdded:Connect(function(plr)
        if plr==player then return end
        table.insert(espConns,plr.CharacterAdded:Connect(function()
            task.wait(0.1) if espEnabled then pcall(function() createESP(plr) end) end
        end))
    end))
end
local function disableESP()
    for _,plr in ipairs(Players:GetPlayers()) do pcall(function() removeESP(plr) end) end
    for _,c in ipairs(espConns) do if c and c.Connected then c:Disconnect() end end espConns={}
end

-- Steal radius circle
local stealCirclePart=nil local stealCircleConn=nil
local function enableStealCircle()
    if stealCirclePart then return end
    stealCirclePart=Instance.new("Part")
    stealCirclePart.Name="BloomStealCircle" stealCirclePart.Anchored=true stealCirclePart.CanCollide=false stealCirclePart.CanTouch=false
    stealCirclePart.Shape=Enum.PartType.Cylinder stealCirclePart.Material=Enum.Material.Neon
    stealCirclePart.Color=Color3.fromRGB(255,80,160) stealCirclePart.Transparency=0.35 stealCirclePart.CastShadow=false
    stealCirclePart.Parent=workspace
    stealCircleConn=RunService.Heartbeat:Connect(function()
        local hrp=getHRP() if not hrp then return end
        local sz=STEAL_RADIUS*2
        stealCirclePart.Size=Vector3.new(0.15,sz,sz)
        stealCirclePart.CFrame=CFrame.new(hrp.Position.X,hrp.Position.Y-2.9,hrp.Position.Z)*CFrame.Angles(0,0,math.pi/2)
    end)
end
local function disableStealCircle()
    if stealCircleConn then stealCircleConn:Disconnect() stealCircleConn=nil end
    if stealCirclePart then stealCirclePart:Destroy() stealCirclePart=nil end
end

-- WP ESP: always auto-refreshes when waypoints change (no toggle needed)
local function refreshWPEsp()
    if not wpEspEnabled then return end
    if wpEspFolder then wpEspFolder:Destroy() end
    wpEspFolder=Instance.new("Folder") wpEspFolder.Name="EclipseWPEsp" wpEspFolder.Parent=workspace
    local R_CLR=WHITE
    local wpList={
        {"L1",POS_L1,ACCENT},{"L2",POS_L2,ACCENT},{"L3",POS_L3,ACCENT},{"L4",POS_L4,ACCENT},{"L5",POS_L5,ACCENT},
        {"R1",POS_R1,R_CLR},{"R2",POS_R2,R_CLR},{"R3",POS_R3,R_CLR},{"R4",POS_R4,R_CLR},{"R5",POS_R5,R_CLR},
    }
    for _,wp in ipairs(wpList) do
        local p=Instance.new("Part")
        p.Name="WPEsp_"..wp[1] p.Anchored=true p.CanCollide=false p.CastShadow=false
        p.Shape=Enum.PartType.Block p.Size=Vector3.new(1,1.8,1) p.Material=Enum.Material.Neon p.Color=wp[3] p.Position=wp[2] p.Parent=wpEspFolder
        local bb=Instance.new("BillboardGui",p)
        bb.Size=UDim2.new(0,70,0,22) bb.StudsOffset=Vector3.new(0,2,0) bb.AlwaysOnTop=true
        local lbl=Instance.new("TextLabel",bb)
        lbl.Size=UDim2.new(1,0,1,0) lbl.BackgroundTransparency=1 lbl.Text=wp[1]
        lbl.TextColor3=WHITE lbl.Font=Enum.Font.GothamBold lbl.TextSize=11
        lbl.TextStrokeTransparency=0.3 lbl.TextStrokeColor3=wp[3]
    end
end
local function enableWPEsp() refreshWPEsp() end
local function disableWPEsp()
    if wpEspFolder then wpEspFolder:Destroy() wpEspFolder=nil end
end


-- FOV
local function applyFOV()
    if fovConn then fovConn:Disconnect() end
    fovConn=RunService.RenderStepped:Connect(function() camera.FieldOfView=fovValue end)
end


-- BAT AIMBOT
local function isTargetValid(targetChar)
    if not targetChar then return false end
    local hum=targetChar:FindFirstChildOfClass("Humanoid")
    local hrp=targetChar:FindFirstChild("HumanoidRootPart")
    local ff=targetChar:FindFirstChildOfClass("ForceField")
    return hum and hrp and hum.Health>0 and not ff
end
local function getBestTarget(myHRP)
    if lockedTarget and isTargetValid(lockedTarget) then return lockedTarget:FindFirstChild("HumanoidRootPart"),lockedTarget end
    local shortestDist=math.huge local newTargetChar=nil local newTargetHRP=nil
    for _,targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer~=player and isTargetValid(targetPlayer.Character) then
            local targetHRP=targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            local distance=(targetHRP.Position-myHRP.Position).Magnitude
            if distance<shortestDist then shortestDist=distance newTargetHRP=targetHRP newTargetChar=targetPlayer.Character end
        end
    end
    lockedTarget=newTargetChar return newTargetHRP,newTargetChar
end
local function startBatAimbot()
    if aimbotConnection then return end
    local c=player.Character if not c then return end
    local h=c:FindFirstChild("HumanoidRootPart") local hum=c:FindFirstChildOfClass("Humanoid")
    if not h or not hum then return end
    hum.AutoRotate=false
    local attachment=h:FindFirstChild("AimbotAttachment") or Instance.new("Attachment",h)
    attachment.Name="AimbotAttachment"
    local align=h:FindFirstChild("AimbotAlign") or Instance.new("AlignOrientation",h)
    align.Name="AimbotAlign" align.Mode=Enum.OrientationAlignmentMode.OneAttachment
    align.Attachment0=attachment align.MaxTorque=math.huge align.Responsiveness=500
    batAimbotEnabled=true
    aimbotConnection=RunService.Heartbeat:Connect(function()
        if not batAimbotEnabled then return end
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
        local currentHRP=player.Character.HumanoidRootPart
        local currentHum=player.Character:FindFirstChildOfClass("Humanoid")
        local targetHRP,targetChar=getBestTarget(currentHRP)
        if targetHRP and targetChar then
            aimbotHighlight.Adornee=targetChar
            local targetVelocity=targetHRP.AssemblyLinearVelocity
            local speed=targetVelocity.Magnitude
            local dynamicPredictTime=math.clamp(speed/120,0.05,0.25)
            local predictedPos=targetHRP.Position+(targetVelocity*dynamicPredictTime)
            local dirToTarget=(predictedPos-currentHRP.Position)
            local distance3D=dirToTarget.Magnitude
            local targetStandPos=predictedPos
            if distance3D>0 then targetStandPos=predictedPos-(dirToTarget.Unit*MELEE_OFFSET) end
            local faceLookAt=Vector3.new(predictedPos.X,currentHRP.Position.Y,predictedPos.Z)
            align.CFrame=CFrame.lookAt(currentHRP.Position,faceLookAt)
            local moveDir=(targetStandPos-currentHRP.Position)
            local distToStandPos=moveDir.Magnitude
            if distToStandPos>0.5 then
                local flatMove=Vector3.new(moveDir.X,0,moveDir.Z)
                local ySnap=targetHRP.Position.Y-currentHRP.Position.Y
                currentHRP.AssemblyLinearVelocity=Vector3.new(flatMove.Unit.X*AIMBOT_SPEED,math.clamp(ySnap*10,-60,60),flatMove.Unit.Z*AIMBOT_SPEED)
            else currentHRP.AssemblyLinearVelocity=targetVelocity end
        else
            lockedTarget=nil currentHRP.AssemblyLinearVelocity=Vector3.new(0,0,0) aimbotHighlight.Adornee=nil
        end
    end)
end
local function stopBatAimbot()
    batAimbotEnabled=false
    if aimbotConnection then aimbotConnection:Disconnect() aimbotConnection=nil end
    local c=player.Character local h=c and c:FindFirstChild("HumanoidRootPart") local hum=c and c:FindFirstChildOfClass("Humanoid")
    if h then
        local att=h:FindFirstChild("AimbotAttachment") if att then att:Destroy() end
        local al=h:FindFirstChild("AimbotAlign") if al then al:Destroy() end
        h.AssemblyLinearVelocity=Vector3.new(0,0,0)
    end
    if hum then hum.AutoRotate=true end
    lockedTarget=nil aimbotHighlight.Adornee=nil
end

-- MEDUSA COUNTER & AUTO MEDUSA
local MEDUSA_COOLDOWN=25
local medusaLastUsed=0 local medusaDebounce=false
local medusaCounterEnabled=false local autoMedusaEnabled=false
local medusaAnchorConns={} local autoMedusaConn=nil

local function findMedusa()
    local c=player.Character if not c then return nil end
    for _,tool in ipairs(c:GetChildren()) do
        if tool:IsA("Tool") then
            local tn=tool.Name:lower()
            if tn:find("medusa") or tn:find("head") or tn:find("stone") then return tool end
        end
    end
    local bp=player:FindFirstChild("Backpack")
    if bp then
        for _,tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") then
                local tn=tool.Name:lower()
                if tn:find("medusa") or tn:find("head") or tn:find("stone") then return tool end
            end
        end
    end
    return nil
end

local function useMedusa()
    if medusaDebounce then return end
    if tick()-medusaLastUsed<MEDUSA_COOLDOWN then return end
    local c=player.Character if not c then return end
    medusaDebounce=true
    local med=findMedusa()
    if not med then medusaDebounce=false return end
    local hum2=c:FindFirstChildOfClass("Humanoid")
    if med.Parent~=c and hum2 then pcall(function() hum2:EquipTool(med) end) end
    pcall(function() med:Activate() end)
    medusaLastUsed=tick() medusaDebounce=false
end

local function stopMedusaCounter()
    for _,c in pairs(medusaAnchorConns) do pcall(function() c:Disconnect() end) end
    medusaAnchorConns={}
end
local function setupMedusaCounter(c)
    stopMedusaCounter() if not c then return end
    local function onAnchorChanged(part)
        return part:GetPropertyChangedSignal("Anchored"):Connect(function()
            if medusaCounterEnabled and part.Anchored and part.Transparency==1 then useMedusa() end
        end)
    end
    for _,part in ipairs(c:GetDescendants()) do
        if part:IsA("BasePart") then table.insert(medusaAnchorConns,onAnchorChanged(part)) end
    end
    table.insert(medusaAnchorConns,c.DescendantAdded:Connect(function(part)
        if part:IsA("BasePart") then table.insert(medusaAnchorConns,onAnchorChanged(part)) end
    end))
end

local function startAutoMedusa()
    if autoMedusaConn then return end
    autoMedusaConn=RunService.Heartbeat:Connect(function()
        if not autoMedusaEnabled then return end
        local c=player.Character if not c then return end
        local hrp=c:FindFirstChild("HumanoidRootPart") if not hrp then return end
        local bestDist=math.huge local bestHRP=nil
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=player and plr.Character then
                local eh=plr.Character:FindFirstChild("HumanoidRootPart")
                local ehum=plr.Character:FindFirstChildOfClass("Humanoid")
                if eh and ehum and ehum.Health>0 then
                    local d=(eh.Position-hrp.Position).Magnitude
                    if d<bestDist then bestDist=d bestHRP=eh end
                end
            end
        end
        if bestHRP and bestDist<=50 then useMedusa() end
    end)
end
local function stopAutoMedusa()
    autoMedusaEnabled=false
    if autoMedusaConn then autoMedusaConn:Disconnect() autoMedusaConn=nil end
end



-- NEW AUTO PLAY (6-waypoint, uses POS_L1-L6 / POS_R1-R6 and WP_L_SPD / WP_R_SPD)
local AP_LeftOn=false
local AP_RightOn=false
local AP_LeftConn=nil
local AP_RightConn=nil
local AP_LeftPhase=1
local AP_RightPhase=1
local AP_SetVisual=nil
local AP_LockVisual=nil
local AP_REACH=2.5
local AP_LeftArrived=0
local AP_RightArrived=0
local AP_ARRIVE_CD=0
local AP_LeftDelayUntil=0
local AP_RightDelayUntil=0

local AP_LEFT_WPS={POS_L1,POS_L2,POS_L3,POS_L4,POS_L5}
local AP_RIGHT_WPS={POS_R1,POS_R2,POS_R3,POS_R4,POS_R5}
local function AP_GetLeftWP() AP_LEFT_WPS[1]=POS_L1 AP_LEFT_WPS[2]=POS_L2 AP_LEFT_WPS[3]=POS_L3 AP_LEFT_WPS[4]=POS_L4 AP_LEFT_WPS[5]=POS_L5 return AP_LEFT_WPS end
local function AP_GetRightWP() AP_RIGHT_WPS[1]=POS_R1 AP_RIGHT_WPS[2]=POS_R2 AP_RIGHT_WPS[3]=POS_R3 AP_RIGHT_WPS[4]=POS_R4 AP_RIGHT_WPS[5]=POS_R5 return AP_RIGHT_WPS end

local function AP_StopLeft()
    if AP_LeftConn then AP_LeftConn:Disconnect(); AP_LeftConn=nil end
    AP_LeftPhase=1
    local c=player.Character
    if c then local hum=c:FindFirstChildOfClass("Humanoid"); if hum then hum:Move(Vector3.zero,false) end end
end
local function AP_StopRight()
    if AP_RightConn then AP_RightConn:Disconnect(); AP_RightConn=nil end
    AP_RightPhase=1
    local c=player.Character
    if c then local hum=c:FindFirstChildOfClass("Humanoid"); if hum then hum:Move(Vector3.zero,false) end end
end
local function AP_StartLeft()
    AP_StopLeft(); AP_LeftOn=true; AP_LeftPhase=1; AP_LeftArrived=0; AP_LeftDelayUntil=0
    local cachedC=nil local cachedRp=nil local cachedHum=nil
    local lastMv=Vector3.zero local lastPh=-1
    AP_LeftConn=RunService.Heartbeat:Connect(function()
        if not AP_LeftOn then return end
        local c=player.Character; if not c then cachedC=nil; return end
        if c~=cachedC then
            cachedC=c
            cachedRp=c:FindFirstChild("HumanoidRootPart")
            cachedHum=c:FindFirstChildOfClass("Humanoid")
            lastMv=Vector3.zero lastPh=-1
        end
        local rp=cachedRp; local hum=cachedHum
        if not rp or not hum then return end
        local wps=AP_GetLeftWP()
        local ph=AP_LeftPhase
        if ph>#wps then
            hum:Move(Vector3.zero,false); rp.AssemblyLinearVelocity=Vector3.zero
            AP_LeftOn=false; AP_StopLeft()
            if AP_SetVisual then AP_SetVisual(false) end; return
        end
        local tgt=wps[ph]
        local spd=WP_L_SPD[ph] or 60
        local pos=rp.Position
        local flat=Vector3.new(tgt.X,pos.Y,tgt.Z)
        if (flat-pos).Magnitude<AP_REACH then
            hum:Move(Vector3.zero,false); rp.AssemblyLinearVelocity=Vector3.zero
            local dly=WP_L_DLY[ph] or 0
            if dly>0 then
                if AP_LeftDelayUntil==0 then AP_LeftDelayUntil=tick()+dly end
                if tick()<AP_LeftDelayUntil then return end
            end
            AP_LeftPhase=ph+1; AP_LeftArrived=0; AP_LeftDelayUntil=0; lastMv=Vector3.zero; lastPh=-1
            return
        end
        AP_LeftArrived=0; AP_LeftDelayUntil=0
        local d=tgt-pos; local mv=Vector3.new(d.X,0,d.Z).Unit
        if ph~=lastPh then lastMv=mv lastPh=ph hum:Move(mv,false) end
        rp.AssemblyLinearVelocity=Vector3.new(lastMv.X*spd,rp.AssemblyLinearVelocity.Y,lastMv.Z*spd)
    end)
end
local function AP_StartRight()
    AP_StopRight(); AP_RightOn=true; AP_RightPhase=1; AP_RightArrived=0; AP_RightDelayUntil=0
    local cachedC=nil local cachedRp=nil local cachedHum=nil
    local lastMv=Vector3.zero local lastPh=-1
    AP_RightConn=RunService.Heartbeat:Connect(function()
        if not AP_RightOn then return end
        local c=player.Character; if not c then cachedC=nil; return end
        if c~=cachedC then
            cachedC=c
            cachedRp=c:FindFirstChild("HumanoidRootPart")
            cachedHum=c:FindFirstChildOfClass("Humanoid")
            lastMv=Vector3.zero lastPh=-1
        end
        local rp=cachedRp; local hum=cachedHum
        if not rp or not hum then return end
        local wps=AP_GetRightWP()
        local ph=AP_RightPhase
        if ph>#wps then
            hum:Move(Vector3.zero,false); rp.AssemblyLinearVelocity=Vector3.zero
            AP_RightOn=false; AP_StopRight()
            if AP_SetVisual then AP_SetVisual(false) end; return
        end
        local tgt=wps[ph]
        local spd=WP_R_SPD[ph] or 60
        local pos=rp.Position
        local flat=Vector3.new(tgt.X,pos.Y,tgt.Z)
        if (flat-pos).Magnitude<AP_REACH then
            hum:Move(Vector3.zero,false); rp.AssemblyLinearVelocity=Vector3.zero
            local dly=WP_R_DLY[ph] or 0
            if dly>0 then
                if AP_RightDelayUntil==0 then AP_RightDelayUntil=tick()+dly end
                if tick()<AP_RightDelayUntil then return end
            end
            AP_RightPhase=ph+1; AP_RightArrived=0; AP_RightDelayUntil=0; lastMv=Vector3.zero; lastPh=-1
            return
        end
        AP_RightArrived=0; AP_RightDelayUntil=0
        local d=tgt-pos; local mv=Vector3.new(d.X,0,d.Z).Unit
        if ph~=lastPh then lastMv=mv lastPh=ph hum:Move(mv,false) end
        rp.AssemblyLinearVelocity=Vector3.new(lastMv.X*spd,rp.AssemblyLinearVelocity.Y,lastMv.Z*spd)
    end)
end

local function AP_DetectSide()
    local plots=workspace:FindFirstChild("Plots"); if not plots then return nil end
    for _,plot in ipairs(plots:GetChildren()) do
        if plot:IsA("Model") then
            local sign=plot:FindFirstChild("PlotSign"); if not sign then continue end
            local yb=sign:FindFirstChild("YourBase",true)
            if yb and yb:IsA("BillboardGui") and yb.Enabled==true then
                local pos=plot:GetPivot().Position
                return pos.Z>=60 and "left" or "right"
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
        local side=AP_DetectSide()
        local route=side=="left" and "right" or "left"
        if route=="left" then
            AP_StartLeft()
        else
            AP_StartRight()
        end
        if AP_SetVisual then AP_SetVisual(true) end
    end
end

-- AUTO STEAL
local function isMyBase(plotName)
    local plots=workspace:FindFirstChild("Plots") if not plots then return false end
    local plot=plots:FindFirstChild(plotName) if not plot then return false end
    local sign=plot:FindFirstChild("PlotSign",true) if not sign then return false end
    local yb=sign:FindFirstChild("YourBase",true) return yb and yb:IsA("BillboardGui") and yb.Enabled==true
end

local function scanPlot(plot)
    if not plot or not plot:IsA("Model") then return end if isMyBase(plot.Name) then return end
    local podiums=plot:FindFirstChild("AnimalPodiums") if not podiums then return end
    for _,pod in ipairs(podiums:GetChildren()) do
        if pod:IsA("Model") and pod:FindFirstChild("Base") then
            table.insert(animalCache,{plot=plot.Name,slot=pod.Name,worldPosition=pod:GetPivot().Position,uid=plot.Name.."_"..pod.Name})
        end
    end
end
local function findPromptForAnimal(ad)
    if not ad then return nil end
    local cp=promptCache[ad.uid] if cp and cp.Parent then return cp end
    local plots=workspace:FindFirstChild("Plots") if not plots then return nil end
    local plot=plots:FindFirstChild(ad.plot) if not plot then return nil end
    local pods=plot:FindFirstChild("AnimalPodiums") if not pods then return nil end
    local pod=pods:FindFirstChild(ad.slot) if not pod then return nil end
    local base=pod:FindFirstChild("Base") if not base then return nil end
    local sp=base:FindFirstChild("Spawn") if not sp then return nil end
    local att=sp:FindFirstChild("PromptAttachment") if not att then return nil end
    for _,p in ipairs(att:GetChildren()) do if p:IsA("ProximityPrompt") then promptCache[ad.uid]=p return p end end
end
-- Rebuild callbacks fresh every time (never stale)
local function buildCallbacks(prompt)
    stealCache[prompt]=nil
    local data={hold={},trigger={},ready=true}
    pcall(function()
        if getconnections then
            for _,c in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do if type(c.Function)=="function" then table.insert(data.hold,c.Function) end end
            for _,c in ipairs(getconnections(prompt.Triggered)) do if type(c.Function)=="function" then table.insert(data.trigger,c.Function) end end
        end
    end)
    if #data.hold>0 or #data.trigger>0 then stealCache[prompt]=data end
end

local function execSteal(prompt)
    local data=stealCache[prompt] if not data or not data.ready then return false end
    data.ready=false isStealing=true stealStartTime=tick()
    if progressConn then progressConn:Disconnect() end
    progressConn=RunService.Heartbeat:Connect(function()
        if not isStealing then progressConn:Disconnect() return end
        local prog=math.clamp((tick()-stealStartTime)/STEAL_DURATION,0,1)
        if ProgressBarFill then
            ProgressBarFill.Size=UDim2.new(prog,0,1,0)
            ProgressBarFill.BackgroundColor3=prog>=0.5 and WHITE or ACCENT
        end
    end)
    task.spawn(function()
        -- Fire hold callbacks immediately in parallel
        for _,f in ipairs(data.hold) do task.spawn(pcall,f) end
        -- Also try ProximityPrompt native method if available
        pcall(function() if prompt and prompt.Parent then prompt:InputHoldBegin() end end)
        task.wait(STEAL_DURATION)
        -- Fire trigger callbacks all in parallel
        for _,f in ipairs(data.trigger) do task.spawn(pcall,f) end
        -- Also try native TriggerEnded
        pcall(function() if prompt and prompt.Parent then prompt:InputHoldEnd() end end)
        -- Fire PromptButtonHoldEnded connections too for full coverage
        pcall(function()
            if getconnections then
                for _,c in ipairs(getconnections(prompt.PromptButtonHoldEnded)) do if type(c.Function)=="function" then task.spawn(pcall,c.Function) end end
            end
        end)
        if progressConn then progressConn:Disconnect() end
        if ProgressBarFill then ProgressBarFill.Size=UDim2.new(0,0,1,0) ProgressBarFill.BackgroundColor3=ACCENT end
        data.ready=true isStealing=false
    end)
    return true
end

local function nearestAnimal()
    local h=getHRP() if not h then return nil end
    local best,bestD=nil,math.huge
    for _,ad in ipairs(animalCache) do
        if not isMyBase(ad.plot) and ad.worldPosition then
            local d=(h.Position-ad.worldPosition).Magnitude if d<bestD then bestD=d best=ad end
        end
    end
    return best
end

local function startAutoSteal()
    if autoStealConn then return end
    autoStealConn=RunService.Heartbeat:Connect(function()
        if not autoStealEnabled or isStealing then return end
        local target=nearestAnimal() if not target then return end
        local h=getHRP() if not h then return end
        if (h.Position-target.worldPosition).Magnitude>STEAL_RADIUS then return end
        -- Always get a fresh prompt reference
        local prompt=findPromptForAnimal(target)
        if not prompt then
            prompt=promptCache[target.uid]
            if not prompt or not prompt.Parent then return end
        end
        promptCache[target.uid]=prompt
        -- Always rebuild callbacks fresh for guaranteed execution
        buildCallbacks(prompt)
        execSteal(prompt)
    end)
end

local function stopAutoSteal()
    if autoStealConn then autoStealConn:Disconnect() autoStealConn=nil end isStealing=false
    if progressConn then progressConn:Disconnect() progressConn=nil end
    if ProgressBarFill then ProgressBarFill.Size=UDim2.new(0,0,1,0) ProgressBarFill.BackgroundColor3=ACCENT end
end

task.spawn(function()
    task.wait(2) local plots=workspace:WaitForChild("Plots",10) if not plots then return end
    for _,plot in ipairs(plots:GetChildren()) do if plot:IsA("Model") then scanPlot(plot) end end
    plots.ChildAdded:Connect(function(plot) if plot:IsA("Model") then task.wait(0.5) scanPlot(plot) end end)
    task.spawn(function() while task.wait(5) do animalCache={} for _,plot in ipairs(plots:GetChildren()) do if plot:IsA("Model") then scanPlot(plot) end end end end)
end)

local function isHoldingBrainrot()
    local c=player.Character if not c then return false end
    local brainrotKeywords={"brainrot","skibidi","rizz","sigma","gyatt","mewing","ohio","sussy","amogus","cap","npc","sus","yap","delulu","slay","opium","fanum","tax","grimace","bibble","chill","guy","tralalero","tralala","bombardiro","crocodilo","lirili","larila","tung","sahur","brr","patapim","chimpanzini","bananini","cappuccino","assassino","ballerina","cappuccina","trippi","troppi","frigo","camelo","elefanto","odin","din","dun","spioniro","golubiro","matteo","la vacca","saturno","hotspot","garama","madundung"}
    local carryKeywords={"carry","carrying","carried","holding","held","stolen","steal","stealing","grab","grabbed","animal","creature","brainrot"}
    local ignoreNames={HumanoidRootPart=true,Head=true,Torso=true,UpperTorso=true,LowerTorso=true,LeftArm=true,RightArm=true,LeftLeg=true,RightLeg=true,LeftHand=true,RightHand=true,LeftFoot=true,RightFoot=true,LeftLowerArm=true,RightLowerArm=true,LeftUpperArm=true,RightUpperArm=true,LeftLowerLeg=true,RightLowerLeg=true,LeftUpperLeg=true,RightUpperLeg=true,Animate=true,EclipseSpeedBB=true}
    local function txt(v)
        if typeof(v)=="string" then return v:lower() end
        if typeof(v)=="Instance" then return v.Name:lower() end
        return tostring(v):lower()
    end
    local function hasKeyword(s,list)
        s=txt(s)
        for _,kw in ipairs(list) do if s:find(kw,1,true) then return true end end
        return false
    end
    local function attrSaysHolding(obj)
        for _,attr in ipairs({"Carrying","Carry","Holding","Held","Stolen","Stealing","HasAnimal","Animal","Brainrot","HeldBrainrot","StolenAnimal","CarriedAnimal"}) do
            local v=obj:GetAttribute(attr)
            if v==true then return true end
            if v~=nil and v~=false and tostring(v)~="" and tostring(v)~="0" then
                if hasKeyword(attr,carryKeywords) or hasKeyword(v,brainrotKeywords) or hasKeyword(v,carryKeywords) then return true end
            end
        end
        for name,value in pairs(obj:GetAttributes()) do
            if value==true and hasKeyword(name,carryKeywords) then return true end
            if value~=nil and value~=false and tostring(value)~="" and tostring(value)~="0" then
                if hasKeyword(name,carryKeywords) and (value==true or hasKeyword(value,brainrotKeywords) or hasKeyword(value,carryKeywords)) then return true end
            end
        end
        return false
    end
    if attrSaysHolding(player) or attrSaysHolding(c) then return true end
    local hum=c:FindFirstChildOfClass("Humanoid")
    if hum and attrSaysHolding(hum) then return true end
    local tool=c:FindFirstChildOfClass("Tool")
    if tool and (hasKeyword(tool.Name,brainrotKeywords) or hasKeyword(tool.Name,carryKeywords) or attrSaysHolding(tool)) then return true end
    for _,obj in ipairs(c:GetChildren()) do
        if not ignoreNames[obj.Name] then
            if obj:IsA("Tool") or obj:IsA("Model") or obj:IsA("Folder") or obj:IsA("Accessory") or obj:IsA("Hat") then
                if hasKeyword(obj.Name,brainrotKeywords) or hasKeyword(obj.Name,carryKeywords) or attrSaysHolding(obj) then return true end
            elseif obj:IsA("BoolValue") and obj.Value==true and hasKeyword(obj.Name,carryKeywords) then
                return true
            elseif obj:IsA("StringValue") and (hasKeyword(obj.Name,carryKeywords) or hasKeyword(obj.Value,brainrotKeywords) or hasKeyword(obj.Value,carryKeywords)) then
                return true
            elseif obj:IsA("ObjectValue") and obj.Value and (hasKeyword(obj.Name,carryKeywords) or hasKeyword(obj.Value.Name,brainrotKeywords) or hasKeyword(obj.Value.Name,carryKeywords)) then
                return true
            end
        end
    end
    for _,obj in ipairs(c:GetDescendants()) do
        if not ignoreNames[obj.Name] and obj.Parent~=c then
            if attrSaysHolding(obj) then return true end
            if obj:IsA("Model") or obj:IsA("Folder") or obj:IsA("Tool") then
                if hasKeyword(obj.Name,brainrotKeywords) or hasKeyword(obj.Name,carryKeywords) then return true end
            elseif obj:IsA("BoolValue") and obj.Value==true and hasKeyword(obj.Name,carryKeywords) then
                return true
            elseif obj:IsA("StringValue") and (hasKeyword(obj.Name,carryKeywords) or hasKeyword(obj.Value,brainrotKeywords) or hasKeyword(obj.Value,carryKeywords)) then
                return true
            elseif obj:IsA("ObjectValue") and obj.Value and (hasKeyword(obj.Name,carryKeywords) or hasKeyword(obj.Value.Name,brainrotKeywords) or hasKeyword(obj.Value.Name,carryKeywords)) then
                return true
            end
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
        local md=gHum.MoveDirection
        if md.Magnitude>0.1 then
            local spd=getMoveSpeed()
            gHrp.AssemblyLinearVelocity=Vector3.new(md.X*spd,gHrp.AssemblyLinearVelocity.Y,md.Z*spd)
        end
    end
end)


local function setupChar(c)
    gChar=c gHum=c:WaitForChild("Humanoid",5) gHrp=c:WaitForChild("HumanoidRootPart",5)
    if not gHum or not gHrp then return end
    task.wait(0.5) makeSpeedBB()
    if antiRagdollEnabled then stopAntiRagdoll() startAntiRagdoll() end
    if espEnabled then enableESP() end
    if batAimbotEnabled then stopBatAimbot() startBatAimbot() end
    if unwalkEnabled then startUnwalk() end
    if medusaCounterEnabled then setupMedusaCounter(c) end
    if autoMedusaEnabled then stopAutoMedusa() startAutoMedusa() end
end
if player.Character then setupChar(player.Character) end
player.CharacterAdded:Connect(function(c) task.wait(0.5) setupChar(c) end)

-- ===================== GUI =====================
local ScreenGui=Instance.new("ScreenGui")
ScreenGui.Name="EclipseXDuels" ScreenGui.ResetOnSpawn=false
ScreenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling ScreenGui.IgnoreGuiInset=false
ScreenGui.Parent=player:WaitForChild("PlayerGui")

-- MAIN FRAME: white inner background, pink outer border
local MainFrame=Instance.new("Frame")
MainFrame.Name="MainFrame" MainFrame.Size=UDim2.new(0,270,0,480)
MainFrame.Position=UDim2.new(0.5,-135,0.5,-240) MainFrame.BackgroundColor3=WHITE
MainFrame.BorderSizePixel=0 MainFrame.Active=true MainFrame.Visible=false MainFrame.Parent=ScreenGui
Instance.new("UICorner",MainFrame).CornerRadius=UDim.new(0,16)

local MainStroke=Instance.new("UIStroke",MainFrame)
MainStroke.Thickness=3 MainStroke.Color=ACCENT MainStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border MainStroke.Transparency=0
task.spawn(function()
    while MainFrame and MainFrame.Parent do
        for i=0,20 do MainStroke.Thickness=3+i*0.05 task.wait(0.04) end
        for i=0,20 do MainStroke.Thickness=4-i*0.05 task.wait(0.04) end
    end
end)

-- Title bar: white with pink text
local TitleBar=Instance.new("Frame",MainFrame)
TitleBar.Size=UDim2.new(1,0,0,44) TitleBar.BackgroundColor3=BG TitleBar.BorderSizePixel=0
Instance.new("UICorner",TitleBar).CornerRadius=UDim.new(0,16)
local TitleFix=Instance.new("Frame",TitleBar)
TitleFix.Size=UDim2.new(1,0,0,16) TitleFix.Position=UDim2.new(0,0,1,-16)
TitleFix.BackgroundColor3=BG TitleFix.BorderSizePixel=0
-- bottom accent line
local TitleAccent=Instance.new("Frame",TitleBar)
TitleAccent.Size=UDim2.new(1,0,0,2) TitleAccent.Position=UDim2.new(0,0,1,-2)
TitleAccent.BackgroundColor3=ACCENT TitleAccent.BorderSizePixel=0
-- left: hub name
local TitleLbl=Instance.new("TextLabel",TitleBar)
TitleLbl.Size=UDim2.new(0,110,1,-2) TitleLbl.Position=UDim2.new(0,12,0,0)
TitleLbl.BackgroundTransparency=1 TitleLbl.Text="Bloom Hub"
TitleLbl.Font=Enum.Font.GothamBlack TitleLbl.TextSize=15 TitleLbl.TextColor3=ACCENT
TitleLbl.TextXAlignment=Enum.TextXAlignment.Left TitleLbl.TextYAlignment=Enum.TextYAlignment.Center

-- TAB BAR: two clickable tabs - FEATURES and SETTINGS
local TabBar=Instance.new("Frame",MainFrame)
TabBar.Size=UDim2.new(1,-20,0,28) TabBar.Position=UDim2.new(0,10,0,48) TabBar.BackgroundTransparency=1
local TabLayout=Instance.new("UIListLayout",TabBar)
TabLayout.FillDirection=Enum.FillDirection.Horizontal TabLayout.Padding=UDim.new(0,6) TabLayout.SortOrder=Enum.SortOrder.LayoutOrder

local function makeTab(parent,txt,order)
    local btn=Instance.new("TextButton",parent)
    btn.Size=UDim2.new(0.5,-3,1,0) btn.BackgroundColor3=Color3.fromRGB(240,210,230)
    btn.BorderSizePixel=0 btn.Text=txt btn.Font=Enum.Font.GothamBlack btn.TextSize=12
    btn.TextColor3=ACCENT btn.LayoutOrder=order btn.AutoButtonColor=false
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)
    return btn
end

local FeatTabBtn=makeTab(TabBar,"FEATURES",1)
local SetTabBtn=makeTab(TabBar,"SETTINGS",2)

-- Scrolling frame factory
local function makeScrollFrame()
    local sf=Instance.new("ScrollingFrame",MainFrame)
    sf.Size=UDim2.new(1,-20,1,-86) sf.Position=UDim2.new(0,10,0,82)
    sf.BackgroundTransparency=1 sf.BorderSizePixel=0 sf.ScrollBarThickness=4 sf.ScrollBarImageColor3=ACCENT
    sf.CanvasSize=UDim2.new(0,0,0,0) sf.AutomaticCanvasSize=Enum.AutomaticSize.Y sf.Visible=false
    local ll=Instance.new("UIListLayout",sf) ll.Padding=UDim.new(0,6) ll.SortOrder=Enum.SortOrder.LayoutOrder
    return sf
end

-- Features frame
local FeatFrame=makeScrollFrame()
FeatFrame.Visible=true
local MovFrame=FeatFrame
local VisFrame=FeatFrame

-- Settings frame
local SetFrame=makeScrollFrame()
SetFrame.Visible=false
local BindFrame=SetFrame

-- Tab switching
local function setTabActive(btn,active)
    btn.BackgroundColor3=active and ACCENT or Color3.fromRGB(240,210,230)
    btn.TextColor3=active and WHITE or ACCENT
end
setTabActive(FeatTabBtn,true)
setTabActive(SetTabBtn,false)

FeatTabBtn.MouseButton1Click:Connect(function()
    FeatFrame.Visible=true SetFrame.Visible=false
    setTabActive(FeatTabBtn,true) setTabActive(SetTabBtn,false)
end)
SetTabBtn.MouseButton1Click:Connect(function()
    FeatFrame.Visible=false SetFrame.Visible=true
    setTabActive(FeatTabBtn,false) setTabActive(SetTabBtn,true)
end)

-- makeToggle: pink text labels, light pink cards
local function makeToggle(parent,name,order,callback,defaultOn)
    local row=Instance.new("Frame",parent)
    row.Size=UDim2.new(1,0,0,44) row.BackgroundColor3=CARD row.BorderSizePixel=0 row.LayoutOrder=order
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,10)
    local rowStroke=Instance.new("UIStroke",row) rowStroke.Color=ACCENT rowStroke.Thickness=1 rowStroke.Transparency=0.7
    local lbl=Instance.new("TextLabel",row)
    lbl.Size=UDim2.new(1,-70,1,0) lbl.Position=UDim2.new(0,14,0,0) lbl.BackgroundTransparency=1
    lbl.Text=name lbl.TextColor3=PINK_TEXT lbl.Font=Enum.Font.GothamBold lbl.TextSize=13 lbl.TextXAlignment=Enum.TextXAlignment.Left
    local pW,pH,dSz=46,24,18
    local track=Instance.new("Frame",row)
    track.Size=UDim2.new(0,pW,0,pH) track.Position=UDim2.new(1,-(pW+12),0.5,-pH/2)
    local initState=(SavedToggleStates[name]~=nil) and SavedToggleStates[name] or (defaultOn or false)
    track.BackgroundColor3=initState and ACCENT or OFF_CLR track.BorderSizePixel=0
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
    local dot=Instance.new("Frame",track)
    dot.Size=UDim2.new(0,dSz,0,dSz)
    dot.Position=initState and UDim2.new(1,-dSz-3,0.5,-dSz/2) or UDim2.new(0,3,0.5,-dSz/2)
    dot.BackgroundColor3=Color3.fromRGB(255,255,255) dot.BorderSizePixel=0
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
    toggleStates[name]={track=track,dot=dot,state=initState,dotSz=dSz}
    if initState and callback then task.defer(function() callback(true) end) end
    local btn=Instance.new("TextButton",row)
    btn.Size=UDim2.new(1,0,1,0) btn.BackgroundTransparency=1 btn.Text=""
    btn.MouseButton1Click:Connect(function()
        local ns=not toggleStates[name].state toggleStates[name].state=ns
        track.BackgroundColor3=ns and ACCENT or OFF_CLR
        dot.Position=ns and UDim2.new(1,-dSz-3,0.5,-dSz/2) or UDim2.new(0,3,0.5,-dSz/2)
        if callback then callback(ns) end
        task.defer(saveConfig)
    end)
    return row
end

local function updateToggle(name,state)
    local t=toggleStates[name] if not t then return end
    t.state=state t.track.BackgroundColor3=state and ACCENT or OFF_CLR
    t.dot.Position=state and UDim2.new(1,-t.dotSz-3,0.5,-t.dotSz/2) or UDim2.new(0,3,0.5,-t.dotSz/2)
    if mobBtnRefs[name] then
        local btn=mobBtnRefs[name]
        btn.BackgroundColor3=MOB_ON btn.TextColor3=WHITE
    end
end

-- makeSection: pink accent text
local function makeSection(parent,text,order)
    local lbl=Instance.new("TextLabel",parent)
    lbl.Size=UDim2.new(1,0,0,26) lbl.BackgroundTransparency=1 lbl.Text=text
    lbl.TextColor3=ACCENT lbl.Font=Enum.Font.GothamBold lbl.TextSize=11
    lbl.TextXAlignment=Enum.TextXAlignment.Left lbl.LayoutOrder=order
end

-- makeNumInput: pink text, light pink box
local function makeNumInput(parent,labelText,defaultVal,order,onChanged)
    local row=Instance.new("Frame",parent)
    row.Size=UDim2.new(1,0,0,44) row.BackgroundColor3=CARD row.BorderSizePixel=0 row.LayoutOrder=order
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,10)
    local rowStroke=Instance.new("UIStroke",row) rowStroke.Color=ACCENT rowStroke.Thickness=1 rowStroke.Transparency=0.7
    local lbl=Instance.new("TextLabel",row)
    lbl.Size=UDim2.new(1,-90,1,0) lbl.Position=UDim2.new(0,14,0,0) lbl.BackgroundTransparency=1
    lbl.Text=labelText lbl.TextColor3=PINK_TEXT lbl.Font=Enum.Font.GothamBold lbl.TextSize=13 lbl.TextXAlignment=Enum.TextXAlignment.Left
    local box=Instance.new("TextBox",row)
    box.Size=UDim2.new(0,68,0,28) box.Position=UDim2.new(1,-78,0.5,-14)
    box.BackgroundColor3=Color3.fromRGB(255,230,242) box.Text=tostring(defaultVal)
    box.TextColor3=ACCENT box.Font=Enum.Font.GothamBold box.TextSize=13
    box.TextXAlignment=Enum.TextXAlignment.Center box.BorderSizePixel=0 box.ClearTextOnFocus=false
    Instance.new("UICorner",box).CornerRadius=UDim.new(0,6)
    local boxStroke=Instance.new("UIStroke",box) boxStroke.Color=ACCENT boxStroke.Thickness=1 boxStroke.Transparency=0.5
    box.FocusLost:Connect(function()
        local n=tonumber(box.Text)
        if n then if onChanged then onChanged(n) end task.defer(saveConfig)
        else box.Text=tostring(defaultVal) end
    end)
    return row,box
end

-- =========== FEATURES TAB ===========
makeSection(FeatFrame,"  COMBAT",1)
makeToggle(FeatFrame,"Lock",2,function(v)
    if v then
        if AP_LeftOn then AP_LeftOn=false AP_StopLeft() if AP_SetVisual then AP_SetVisual(false) end end
        if AP_RightOn then AP_RightOn=false AP_StopRight() if AP_SetVisual then AP_SetVisual(false) end end
        startBatAimbot()
    else stopBatAimbot() end
end)
makeToggle(FeatFrame,"Medusa Counter",6,function(v)
    medusaCounterEnabled=v
    if v then setupMedusaCounter(player.Character) else stopMedusaCounter() end
end)
makeToggle(FeatFrame,"Auto Medusa",7,function(v)
    autoMedusaEnabled=v
    if autoMedusaMobRef then autoMedusaMobRef.Visible=v end
    if v then startAutoMedusa() else stopAutoMedusa() end
end)
makeToggle(FeatFrame,"Anti Ragdoll",3,function(v) antiRagdollEnabled=v if v then startAntiRagdoll() else stopAntiRagdoll() end end)
makeToggle(FeatFrame,"Unwalk",5,function(v) unwalkEnabled=v if v then startUnwalk() else stopUnwalk() end end)
makeSection(FeatFrame,"  STEAL",6)
makeToggle(FeatFrame,"Auto Steal",7,function(v) autoStealEnabled=v if v then startAutoSteal() else stopAutoSteal() end end)
makeSection(FeatFrame,"  DROP",11)
makeToggle(FeatFrame,"Drop",12,function(v)
end)
makeToggle(FeatFrame,"TP Down",13,function(v)
end)


-- MOVEMENT SECTION
makeSection(MovFrame,"  MOVEMENT",19)

-- WAYPOINT EDITOR
do
    local function makeSideLabel(parent,txt,order)
        local f=Instance.new("Frame",parent)
        f.Size=UDim2.new(1,0,0,24) f.BackgroundTransparency=1 f.BorderSizePixel=0 f.LayoutOrder=order
        local l=Instance.new("TextLabel",f)
        l.Size=UDim2.new(1,0,1,0) l.BackgroundTransparency=1
        l.Text=txt l.TextColor3=ACCENT l.Font=Enum.Font.GothamBold l.TextSize=11
        l.TextXAlignment=Enum.TextXAlignment.Left
        local line=Instance.new("Frame",f)
        line.Size=UDim2.new(1,0,0,1) line.Position=UDim2.new(0,0,1,-1)
        line.BackgroundColor3=ACCENT line.BackgroundTransparency=0.6 line.BorderSizePixel=0
    end

    -- WP rows auto-refresh ESP on FocusLost
    local function makeWPRow(parent,label,order,getPos,setPos)
        local row=Instance.new("Frame",parent)
        row.Size=UDim2.new(1,0,0,46) row.BackgroundColor3=CARD row.BorderSizePixel=0 row.LayoutOrder=order
        Instance.new("UICorner",row).CornerRadius=UDim.new(0,10)
        local rowStroke=Instance.new("UIStroke",row) rowStroke.Color=ACCENT rowStroke.Thickness=1 rowStroke.Transparency=0.6
        local lbl=Instance.new("TextLabel",row)
        lbl.Size=UDim2.new(0,36,1,0) lbl.Position=UDim2.new(0,10,0,0) lbl.BackgroundTransparency=1
        lbl.Text=label lbl.TextColor3=PINK_TEXT lbl.Font=Enum.Font.GothamBold lbl.TextSize=12
        lbl.TextXAlignment=Enum.TextXAlignment.Left
        local function makeBox(xOff,val,clr)
            local b=Instance.new("TextBox",row)
            b.Size=UDim2.new(0,54,0,30) b.Position=UDim2.new(0,xOff,0.5,-15)
            b.BackgroundColor3=Color3.fromRGB(255,230,242) b.Text=string.format("%.2f",val)
            b.TextColor3=clr b.Font=Enum.Font.GothamBold b.TextSize=11
            b.TextXAlignment=Enum.TextXAlignment.Center b.BorderSizePixel=0 b.ClearTextOnFocus=false
            Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
            local bs=Instance.new("UIStroke",b) bs.Color=ACCENT bs.Thickness=1 bs.Transparency=0.6
            return b
        end
        local p=getPos()
        local xBox=makeBox(48,p.X,ACCENT)
        local yBox=makeBox(106,p.Y,Color3.fromRGB(100,200,120))
        local zBox=makeBox(164,p.Z,Color3.fromRGB(100,160,255))
        for i,data in ipairs({{48,"X"},{106,"Y"},{164,"Z"}}) do
            local al=Instance.new("TextLabel",row)
            al.Size=UDim2.new(0,54,0,10) al.Position=UDim2.new(0,data[1],0,2)
            al.BackgroundTransparency=1 al.Text=data[2] al.Font=Enum.Font.GothamBold al.TextSize=8
            al.TextColor3=PINK_TEXT al.TextXAlignment=Enum.TextXAlignment.Center
        end
        -- auto-apply on FocusLost AND refresh WP ESP markers immediately
        local function apply()
            local x=tonumber(xBox.Text) local y=tonumber(yBox.Text) local z=tonumber(zBox.Text)
            if x and y and z then
                setPos(Vector3.new(x,y,z))
                task.defer(saveConfig)
                task.defer(refreshWPEsp)
            end
        end
        xBox.FocusLost:Connect(apply) yBox.FocusLost:Connect(apply) zBox.FocusLost:Connect(apply)
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

    -- WAYPOINT SPEED EDITOR
    makeSection(MovFrame,"  WAYPOINT SPEEDS",33)
    do
        local function makeWPSpeedRow(order, label, getLSpd, setLSpd, getRSpd, setRSpd)
            local row=Instance.new("Frame",MovFrame)
            row.Size=UDim2.new(1,0,0,44) row.BackgroundColor3=CARD row.BorderSizePixel=0 row.LayoutOrder=order
            Instance.new("UICorner",row).CornerRadius=UDim.new(0,10)
            local rowStroke=Instance.new("UIStroke",row) rowStroke.Color=ACCENT rowStroke.Thickness=1 rowStroke.Transparency=0.7
            local lbl=Instance.new("TextLabel",row)
            lbl.Size=UDim2.new(0,28,1,0) lbl.Position=UDim2.new(0,10,0,0) lbl.BackgroundTransparency=1
            lbl.Text=label lbl.TextColor3=PINK_TEXT lbl.Font=Enum.Font.GothamBold lbl.TextSize=13 lbl.TextXAlignment=Enum.TextXAlignment.Left
            local function makeBox(xPos, capText, getV, setV, clr)
                local cap=Instance.new("TextLabel",row)
                cap.Size=UDim2.new(0,12,0,16) cap.Position=UDim2.new(0,xPos-14,0.5,-8) cap.BackgroundTransparency=1
                cap.Text=capText cap.TextColor3=clr cap.Font=Enum.Font.GothamBold cap.TextSize=10
                local box=Instance.new("TextBox",row)
                box.Size=UDim2.new(0,68,0,28) box.Position=UDim2.new(0,xPos,0.5,-14)
                box.BackgroundColor3=Color3.fromRGB(255,230,242) box.Text=tostring(getV())
                box.TextColor3=clr box.Font=Enum.Font.GothamBold box.TextSize=13
                box.TextXAlignment=Enum.TextXAlignment.Center box.BorderSizePixel=0 box.ClearTextOnFocus=false
                Instance.new("UICorner",box).CornerRadius=UDim.new(0,6)
                local bs=Instance.new("UIStroke",box) bs.Color=ACCENT bs.Thickness=1 bs.Transparency=0.5
                box.FocusLost:Connect(function()
                    local n=tonumber(box.Text)
                    if n then setV(math.max(1,n)) task.defer(saveConfig)
                    else box.Text=tostring(getV()) end
                end)
                return box
            end
            makeBox(40, "L", getLSpd, setLSpd, ACCENT)
            makeBox(136, "R", getRSpd, setRSpd, Color3.fromRGB(100,160,255))
        end
        makeWPSpeedRow(34,"P1:", function() return WP_L_SPD[1] end, function(v) WP_L_SPD[1]=v end, function() return WP_R_SPD[1] end, function(v) WP_R_SPD[1]=v end)
        makeWPSpeedRow(35,"P2:", function() return WP_L_SPD[2] end, function(v) WP_L_SPD[2]=v end, function() return WP_R_SPD[2] end, function(v) WP_R_SPD[2]=v end)
        makeWPSpeedRow(36,"P3:", function() return WP_L_SPD[3] end, function(v) WP_L_SPD[3]=v end, function() return WP_R_SPD[3] end, function(v) WP_R_SPD[3]=v end)
        makeWPSpeedRow(37,"P4:", function() return WP_L_SPD[4] end, function(v) WP_L_SPD[4]=v end, function() return WP_R_SPD[4] end, function(v) WP_R_SPD[4]=v end)
        makeWPSpeedRow(38,"P5:", function() return WP_L_SPD[5] end, function(v) WP_L_SPD[5]=v end, function() return WP_R_SPD[5] end, function(v) WP_R_SPD[5]=v end)
    end
end

-- VISUAL SECTION
makeSection(VisFrame,"  VISUAL",99)
makeToggle(VisFrame,"Player ESP",101,function(v) espEnabled=v if v then enableESP() else disableESP() end end,true)
makeToggle(VisFrame,"Waypoint ESP",102,function(v)
    wpEspEnabled=v
    if v then enableWPEsp() else disableWPEsp() end
end)
makeToggle(VisFrame,"Steal Circle",103,function(v) if v then enableStealCircle() else disableStealCircle() end end)

-- =========== SETTINGS TAB ===========
-- Speed Customizer (moved here from floating button)
makeSection(SetFrame,"  SPEED CUSTOMIZER",100)
do
    local sfActive=true
    local sfSavedNormal,sfSavedCarry=NORMAL_SPEED,SLOW_SPEED

    -- Active toggle
    local activeRow=Instance.new("Frame",SetFrame)
    activeRow.Size=UDim2.new(1,0,0,44) activeRow.BackgroundColor3=CARD activeRow.BorderSizePixel=0 activeRow.LayoutOrder=101
    Instance.new("UICorner",activeRow).CornerRadius=UDim.new(0,10)
    local rs=Instance.new("UIStroke",activeRow) rs.Color=ACCENT rs.Thickness=1 rs.Transparency=0.7
    local activeLbl=Instance.new("TextLabel",activeRow)
    activeLbl.Size=UDim2.new(0.6,0,1,0) activeLbl.Position=UDim2.new(0,14,0,0) activeLbl.BackgroundTransparency=1
    activeLbl.Text="Speed Active" activeLbl.TextColor3=PINK_TEXT activeLbl.Font=Enum.Font.GothamBold
    activeLbl.TextSize=13 activeLbl.TextXAlignment=Enum.TextXAlignment.Left
    local pW,pH,dSz=46,24,18
    local sfTrack=Instance.new("Frame",activeRow)
    sfTrack.Size=UDim2.new(0,pW,0,pH) sfTrack.Position=UDim2.new(1,-(pW+12),0.5,-pH/2)
    sfTrack.BackgroundColor3=ACCENT sfTrack.BorderSizePixel=0
    Instance.new("UICorner",sfTrack).CornerRadius=UDim.new(1,0)
    local sfDot=Instance.new("Frame",sfTrack)
    sfDot.Size=UDim2.new(0,dSz,0,dSz) sfDot.Position=UDim2.new(1,-dSz-3,0.5,-dSz/2)
    sfDot.BackgroundColor3=WHITE sfDot.BorderSizePixel=0
    Instance.new("UICorner",sfDot).CornerRadius=UDim.new(1,0)

    local function setSpeedCustomizerActive(on)
        if on then
            sfActive=true speedCustomizerActive=true
            NORMAL_SPEED=sfSavedNormal SLOW_SPEED=sfSavedCarry
            sfTrack.BackgroundColor3=ACCENT sfDot.Position=UDim2.new(1,-dSz-3,0.5,-dSz/2)
        else
            if sfActive then sfSavedNormal=NORMAL_SPEED sfSavedCarry=SLOW_SPEED end
            sfActive=false speedCustomizerActive=false
            NORMAL_SPEED=16 SLOW_SPEED=16
            sfTrack.BackgroundColor3=OFF_CLR sfDot.Position=UDim2.new(0,4,0.5,-dSz/2)
            local chr=player.Character
            if chr then
                local hum=chr:FindFirstChildOfClass("Humanoid") if hum then hum.WalkSpeed=16 end
                local hrp=chr:FindFirstChild("HumanoidRootPart") if hrp then hrp.AssemblyLinearVelocity=Vector3.new(0,hrp.AssemblyLinearVelocity.Y,0) end
            end
        end
    end
    local activeBtn=Instance.new("TextButton",activeRow)
    activeBtn.Size=UDim2.new(1,0,1,0) activeBtn.BackgroundTransparency=1 activeBtn.Text=""
    activeBtn.MouseButton1Click:Connect(function() setSpeedCustomizerActive(not sfActive) end)

    -- Normal Speed row
    local function makeSpeedRow(labelTxt,order,getV,setV)
        local row=Instance.new("Frame",SetFrame)
        row.Size=UDim2.new(1,0,0,44) row.BackgroundColor3=CARD row.BorderSizePixel=0 row.LayoutOrder=order
        Instance.new("UICorner",row).CornerRadius=UDim.new(0,10)
        local rs2=Instance.new("UIStroke",row) rs2.Color=ACCENT rs2.Thickness=1 rs2.Transparency=0.7
        local lbl2=Instance.new("TextLabel",row)
        lbl2.Size=UDim2.new(0.55,0,1,0) lbl2.Position=UDim2.new(0,14,0,0) lbl2.BackgroundTransparency=1
        lbl2.Text=labelTxt lbl2.TextColor3=PINK_TEXT lbl2.Font=Enum.Font.GothamBold
        lbl2.TextSize=13 lbl2.TextXAlignment=Enum.TextXAlignment.Left
        local box=Instance.new("TextBox",row)
        box.Size=UDim2.new(0,68,0,28) box.Position=UDim2.new(1,-78,0.5,-14)
        box.BackgroundColor3=Color3.fromRGB(255,230,242) box.Text=tostring(getV())
        box.TextColor3=ACCENT box.Font=Enum.Font.GothamBold box.TextSize=13
        box.TextXAlignment=Enum.TextXAlignment.Center box.BorderSizePixel=0 box.ClearTextOnFocus=false
        Instance.new("UICorner",box).CornerRadius=UDim.new(0,6)
        local bs=Instance.new("UIStroke",box) bs.Color=ACCENT bs.Thickness=1 bs.Transparency=0.5
        box.FocusLost:Connect(function()
            local n=tonumber(box.Text)
            if n then setV(n) task.defer(saveConfig)
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

-- Other settings
makeSection(SetFrame,"  STEAL",150)
local _,_srb=makeNumInput(SetFrame,"Steal Radius",STEAL_RADIUS,151,function(v) STEAL_RADIUS=math.clamp(v,5,200) if RadiusInput then RadiusInput.Text=tostring(STEAL_RADIUS) end end) StealRadiusBox=_srb
makeNumInput(SetFrame,"Steal Duration",STEAL_DURATION,152,function(v) STEAL_DURATION=math.max(0.05,v) end)
makeSection(SetFrame,"  CAMERA / BAT",153)
makeNumInput(SetFrame,"FOV",fovValue,154,function(v) fovValue=v applyFOV() end)
makeNumInput(SetFrame,"Aimbot Speed",AIMBOT_SPEED,155,function(v) AIMBOT_SPEED=v end)
makeNumInput(SetFrame,"Engage Range",BAT_ENGAGE_RANGE,156,function(v) BAT_ENGAGE_RANGE=v end)
makeSection(SetFrame,"  UI",157)
makeToggle(SetFrame,"UI Lock",158,function(v) stealBarLocked=v mobBtnsLocked=v end)

-- KEYBINDS (in Settings tab)
makeSection(BindFrame,"  KEYBINDS (click to rebind)",169)
do
    local bindHint=Instance.new("TextLabel",BindFrame)
    bindHint.Size=UDim2.new(1,0,0,36) bindHint.BackgroundColor3=Color3.fromRGB(255,220,240)
    bindHint.BackgroundTransparency=0 bindHint.BorderSizePixel=0
    bindHint.Text="Click a key button then press\nany key to rebind. CTRL = clear."
    bindHint.TextColor3=PINK_TEXT bindHint.Font=Enum.Font.Gotham
    bindHint.TextSize=11 bindHint.TextWrapped=true bindHint.LayoutOrder=171
    Instance.new("UICorner",bindHint).CornerRadius=UDim.new(0,8)
end

local bindList={
    {"Auto Steal","AutoSteal"},
    {"Lock","BatAimbot"},{"Anti Ragdoll","AntiRagdoll"},{"Unwalk","Unwalk"},
    {"Drop","Drop"},
    {"TP Down","TPDown"},
}
for idx,entry in ipairs(bindList) do
    local displayName,keyName=entry[1],entry[2]
    local row=Instance.new("Frame",BindFrame)
    row.Size=UDim2.new(1,0,0,44) row.BackgroundColor3=CARD row.BorderSizePixel=0 row.LayoutOrder=172+idx
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,10)
    local rowStroke=Instance.new("UIStroke",row) rowStroke.Color=ACCENT rowStroke.Thickness=1 rowStroke.Transparency=0.7
    local nameLbl=Instance.new("TextLabel",row)
    nameLbl.Size=UDim2.new(1,-110,1,0) nameLbl.Position=UDim2.new(0,14,0,0) nameLbl.BackgroundTransparency=1
    nameLbl.Text=displayName nameLbl.TextColor3=PINK_TEXT nameLbl.Font=Enum.Font.GothamBold
    nameLbl.TextSize=13 nameLbl.TextXAlignment=Enum.TextXAlignment.Left
    local keyBtn=Instance.new("TextButton",row)
    keyBtn.Size=UDim2.new(0,90,0,30) keyBtn.Position=UDim2.new(1,-98,0.5,-15)
    keyBtn.BackgroundColor3=Color3.fromRGB(255,220,240)
    keyBtn.Text=Keybinds[keyName] and tostring(Keybinds[keyName]):gsub("Enum.KeyCode.","") or "NONE"
    keyBtn.Font=Enum.Font.GothamBold keyBtn.TextSize=11 keyBtn.TextColor3=ACCENT keyBtn.BorderSizePixel=0
    Instance.new("UICorner",keyBtn).CornerRadius=UDim.new(0,8)
    local kb=Instance.new("UIStroke",keyBtn) kb.Color=ACCENT kb.Thickness=1 kb.Transparency=0.5
    KeybindButtons[keyName]=keyBtn
    keyBtn.MouseButton1Click:Connect(function()
        if changingKeybind then return end
        changingKeybind=keyName keyBtn.Text="Press key..." keyBtn.TextColor3=Color3.fromRGB(255,150,80)
        local conn conn=UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.Keyboard then
                if input.KeyCode==Enum.KeyCode.LeftControl or input.KeyCode==Enum.KeyCode.RightControl then
                    Keybinds[keyName]=nil keyBtn.Text="NONE"
                else Keybinds[keyName]=input.KeyCode keyBtn.Text=tostring(input.KeyCode):gsub("Enum.KeyCode.","") end
                keyBtn.TextColor3=ACCENT changingKeybind=nil conn:Disconnect()
                task.defer(saveConfig)
            end
        end)
    end)
end

-- =========== STATS / PROGRESS BAR (dark style like second photo) ===========
do
    local PBC=Instance.new("Frame",ScreenGui)
    PBC.Size=UDim2.new(0,320,0,32)
    PBC.Position=UDim2.new(0.5,-160,0,46)
    StealBarRef=PBC
    PBC.BackgroundColor3=ACCENT PBC.BackgroundTransparency=0 PBC.BorderSizePixel=0
    Instance.new("UICorner",PBC).CornerRadius=UDim.new(0,14)
    -- status (hidden, kept for logic)
    ProgressLabel=Instance.new("TextLabel",PBC)
    ProgressLabel.Size=UDim2.new(0,0,0,0) ProgressLabel.BackgroundTransparency=1 ProgressLabel.Text="READY"
    ProgressLabel.Visible=false ProgressLabel.ZIndex=1
    -- Progress bar track (full width, thick) — inner dark pink
    local pt=Instance.new("Frame",PBC)
    pt.Size=UDim2.new(1,-58,1,-10) pt.Position=UDim2.new(0,6,0,5)
    pt.BackgroundColor3=Color3.fromRGB(180,40,110) pt.BorderSizePixel=0 pt.ZIndex=2
    Instance.new("UICorner",pt).CornerRadius=UDim.new(0,10)
    ProgressBarFill=Instance.new("Frame",pt)
    ProgressBarFill.Size=UDim2.new(0,0,1,0) ProgressBarFill.BackgroundColor3=ACCENT
    ProgressBarFill.BorderSizePixel=0 ProgressBarFill.ZIndex=3
    Instance.new("UICorner",ProgressBarFill).CornerRadius=UDim.new(0,10)
    -- value badge (right side) — dark pink bg
    local badge=Instance.new("Frame",PBC)
    badge.Size=UDim2.new(0,46,1,-8) badge.Position=UDim2.new(1,-50,0,4)
    badge.BackgroundColor3=Color3.fromRGB(180,40,110) badge.BorderSizePixel=0 badge.ZIndex=4
    Instance.new("UICorner",badge).CornerRadius=UDim.new(0,10)
    ProgressPctLabel=Instance.new("TextLabel",badge)
    ProgressPctLabel.Size=UDim2.new(1,0,1,0) ProgressPctLabel.BackgroundTransparency=1
    ProgressPctLabel.Text="0" ProgressPctLabel.TextColor3=WHITE
    ProgressPctLabel.Font=Enum.Font.GothamBold ProgressPctLabel.TextSize=13 ProgressPctLabel.ZIndex=5
end

-- =========== STATUS BAR (fixed top-center above PBC) ===========
do
    local SB=Instance.new("Frame",ScreenGui)
    SB.Size=UDim2.new(0,320,0,36)
    SB.Position=UDim2.new(0.5,-160,0,8)
    SB.BackgroundColor3=WHITE SB.BackgroundTransparency=0 SB.BorderSizePixel=0 SB.ZIndex=10
    Instance.new("UICorner",SB).CornerRadius=UDim.new(0,14)

    -- LEFT: "Bloom Hub"
    local sbName=Instance.new("TextLabel",SB)
    sbName.Size=UDim2.new(0,110,1,0) sbName.Position=UDim2.new(0,10,0,0)
    sbName.BackgroundTransparency=1 sbName.Text="Bloom Hub"
    sbName.Font=Enum.Font.GothamBlack sbName.TextSize=13 sbName.TextColor3=ACCENT
    sbName.TextXAlignment=Enum.TextXAlignment.Left sbName.ZIndex=11

    -- MIDDLE: FPS
    local sbFps=Instance.new("TextLabel",SB)
    sbFps.Size=UDim2.new(0,100,1,0) sbFps.Position=UDim2.new(0.5,-50,0,0)
    sbFps.BackgroundTransparency=1 sbFps.Text="FPS --"
    sbFps.Font=Enum.Font.GothamBold sbFps.TextSize=13 sbFps.TextColor3=ACCENT
    sbFps.TextXAlignment=Enum.TextXAlignment.Center sbFps.ZIndex=11

    -- RIGHT: MS (ping)
    local sbMs=Instance.new("TextLabel",SB)
    sbMs.Size=UDim2.new(0,80,1,0) sbMs.Position=UDim2.new(1,-88,0,0)
    sbMs.BackgroundTransparency=1 sbMs.Text="--ms"
    sbMs.Font=Enum.Font.GothamBold sbMs.TextSize=13 sbMs.TextColor3=ACCENT
    sbMs.TextXAlignment=Enum.TextXAlignment.Right sbMs.ZIndex=11

    -- live FPS/PING
    task.spawn(function()
        local lastT=tick() local frames=0
        RunService.RenderStepped:Connect(function()
            frames=frames+1 local now=tick()
            if now-lastT>=0.5 then
                local fps=math.round(frames/(now-lastT)) frames=0 lastT=now
                local ping=0 pcall(function() ping=math.round(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
                if sbFps and sbFps.Parent then sbFps.Text="FPS "..fps end
                if sbMs and sbMs.Parent then sbMs.Text=ping.."ms" end
            end
        end)
    end)

end

-- MOBILE BUTTONS
local dropMobBtnRef=nil local tpMobBtnRef=nil
local autoMedusaMobRef=nil
do
    local DRAG_THRESHOLD=10
    local function makeMob(label,initPos,toggleName,onAct)
        local btn=Instance.new("TextButton",ScreenGui)
        btn.Size=UDim2.new(0,58,0,58)
        local posKey=label:gsub("\n","_")
        local saved=mobBtnPositions[posKey]
        btn.Position=saved and UDim2.new(saved[1],saved[2],saved[3],saved[4]) or initPos
        btn.BackgroundColor3=MOB_ON btn.BackgroundTransparency=0
        btn.Text=label:upper() btn.TextColor3=WHITE btn.Font=Enum.Font.GothamBold
        btn.TextSize=9 btn.TextWrapped=true btn.BorderSizePixel=0 btn.ZIndex=20
        Instance.new("UICorner",btn).CornerRadius=UDim.new(1,0)
        local s=Instance.new("UIStroke",btn) s.Color=WHITE s.Thickness=1.2 s.Transparency=0.5
        table.insert(mobileButtons,btn)
        if toggleName then mobBtnRefs[toggleName]=btn end
        btn.InputBegan:Connect(function(input)
            if input.UserInputType~=Enum.UserInputType.Touch and input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
            local startPos=btn.Position local startVec=input.Position local moved=false
            local conn conn=input.Changed:Connect(function()
                if input.UserInputState==Enum.UserInputState.Change then
                    local d=input.Position-startVec
                    if not mobBtnsLocked and d.Magnitude>DRAG_THRESHOLD then
                        moved=true
                        btn.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
                    end
                elseif input.UserInputState==Enum.UserInputState.End then
                    conn:Disconnect()
                    if moved then
                        local p=btn.Position mobBtnPositions[posKey]={p.X.Scale,p.X.Offset,p.Y.Scale,p.Y.Offset}
                        task.defer(saveConfig)
                    else task.spawn(onAct) end
                end
            end)
        end)
        return btn
    end

    local col1=UDim2.new(1,-120,0.5,-170)
    local gap=68
    local dropMobBtn=makeMob("DROP",col1,nil,function() task.spawn(doDrop) end)
    dropMobBtn.Visible=true dropMobBtnRef=dropMobBtn dropMobBtn.Size=UDim2.new(0,90,0,50)
    local autoBatBtn=makeMob("LOCK",UDim2.new(1,-120,0.5,-170+gap),"Lock",function()
        local ns=not(toggleStates["Lock"] and toggleStates["Lock"].state)
        if ns then
            if AP_LeftOn then AP_LeftOn=false AP_StopLeft() if AP_SetVisual then AP_SetVisual(false) end end
            if AP_RightOn then AP_RightOn=false AP_StopRight() if AP_SetVisual then AP_SetVisual(false) end end
            startBatAimbot()
        else stopBatAimbot() end updateToggle("Lock",ns)
        if AP_LockVisual then AP_LockVisual(ns) end
    end)
    autoBatBtn.Size=UDim2.new(0,90,0,50)
    AP_LockVisual=function(state)
        autoBatBtn.Text=state and "LOCKED" or "LOCK"
        autoBatBtn.TextColor3=state and ACCENT or WHITE
        autoBatBtn.BackgroundColor3=state and WHITE or MOB_ON
    end

    do
        local apPosKey="AutoPlay_Btn"
        local apBtn=makeMob("AUTO\nPLAY",UDim2.new(1,-120,0.5,-170),nil,function()
            AP_Toggle()
        end)
        apBtn.Size=UDim2.new(0,90,0,50)
        local apSaved=mobBtnPositions[apPosKey]
        if apSaved then apBtn.Position=UDim2.new(apSaved[1],apSaved[2],apSaved[3],apSaved[4]) end
        AP_SetVisual=function(state)
            apBtn.BackgroundColor3=state and WHITE or MOB_ON
            apBtn.TextColor3=state and ACCENT or WHITE
            apBtn.Text=state and "STOP\nAP" or "AUTO\nPLAY"
        end
    end
    local tpMobBtn=makeMob("TP\nDOWN",UDim2.new(1,-120,0.5,-170+gap*2),nil,function() task.spawn(doTPDown) end)
    tpMobBtnRef=tpMobBtn tpMobBtn.Size=UDim2.new(0,90,0,50)
    local autoMedBtn=makeMob("AUTO\nMED",UDim2.new(1,-120,0.5,-170+gap*3),nil,function()
        local ns=not autoMedusaEnabled
        autoMedusaEnabled=ns
        if ns then startAutoMedusa() else stopAutoMedusa() end
        updateToggle("Auto Medusa",ns)
    end)
    autoMedBtn.Visible=false autoMedusaMobRef=autoMedBtn autoMedBtn.Size=UDim2.new(0,90,0,50)
end

-- OPEN/CLOSE BUTTON (pink)
do
    local OCGui=Instance.new("ScreenGui",player:WaitForChild("PlayerGui"))
    OCGui.Name="EclipseXOpenClose" OCGui.ResetOnSpawn=false OCGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    local OBtn=Instance.new("TextButton",OCGui)
    OBtn.Size=UDim2.new(0,52,0,52) OBtn.Position=UDim2.new(0,10,0.5,-26)
    OBtn.BackgroundColor3=ACCENT OBtn.Text="B" OBtn.TextSize=26
    OBtn.Font=Enum.Font.GothamBlack OBtn.TextColor3=WHITE OBtn.BorderSizePixel=0 OBtn.Active=true
    Instance.new("UICorner",OBtn).CornerRadius=UDim.new(0,14)
    local OS=Instance.new("UIStroke",OBtn) OS.Thickness=2 OS.Color=WHITE OS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    task.spawn(function()
        while OBtn and OBtn.Parent do
            for i=0,20 do OS.Thickness=2+i*0.05 task.wait(0.04) end
            for i=0,20 do OS.Thickness=3-i*0.05 task.wait(0.04) end
        end
    end)
    task.spawn(function()
        local BASE=ACCENT
        local BRIGHT=Color3.fromRGB(255,120,190)
        while OBtn and OBtn.Parent do
            TweenService:Create(OBtn,TweenInfo.new(0.7,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{BackgroundColor3=BRIGHT}):Play()
            task.wait(0.72)
            TweenService:Create(OBtn,TweenInfo.new(0.7,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{BackgroundColor3=BASE}):Play()
            task.wait(0.72)
        end
    end)
    do
        local dragging,dragStart,startPos=false,nil,nil
        OBtn.InputBegan:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
                dragging=true dragStart=input.Position startPos=OBtn.Position
                input.Changed:Connect(function() if input.UserInputState==Enum.UserInputState.End then dragging=false end end)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseMovement) then
                local d=input.Position-dragStart
                OBtn.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
            end
        end)
    end
    OBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible=not MainFrame.Visible
        TweenService:Create(OS,TweenInfo.new(0.15),{Color=MainFrame.Visible and ACCENT or WHITE}):Play()
    end)
end

do
    local dragging,dragStart,startPos=false,nil,nil
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=true dragStart=input.Position startPos=MainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseMovement) then
            local d=input.Position-dragStart
            MainFrame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end
    end)
end

-- PC KEYBIND HANDLER
UserInputService.InputBegan:Connect(function(input,processed)
    if processed then return end if changingKeybind then return end
    if input.UserInputType~=Enum.UserInputType.Keyboard then return end
    if Keybinds.AutoSteal and input.KeyCode==Keybinds.AutoSteal then
        local ns=not(toggleStates["Auto Steal"] and toggleStates["Auto Steal"].state)
        autoStealEnabled=ns if ns then startAutoSteal() else stopAutoSteal() end updateToggle("Auto Steal",ns)
    elseif Keybinds.BatAimbot and input.KeyCode==Keybinds.BatAimbot then
        local ns=not(toggleStates["Lock"] and toggleStates["Lock"].state)
        if ns then
            if AP_LeftOn then AP_LeftOn=false AP_StopLeft() if AP_SetVisual then AP_SetVisual(false) end end
            if AP_RightOn then AP_RightOn=false AP_StopRight() if AP_SetVisual then AP_SetVisual(false) end end
            startBatAimbot()
        else stopBatAimbot() end updateToggle("Lock",ns)
        if AP_LockVisual then AP_LockVisual(ns) end
    elseif Keybinds.AntiRagdoll and input.KeyCode==Keybinds.AntiRagdoll then
        local ns=not(toggleStates["Anti Ragdoll"] and toggleStates["Anti Ragdoll"].state)
        antiRagdollEnabled=ns if ns then startAntiRagdoll() else stopAntiRagdoll() end updateToggle("Anti Ragdoll",ns)
    elseif Keybinds.Unwalk and input.KeyCode==Keybinds.Unwalk then
        local ns=not(toggleStates["Unwalk"] and toggleStates["Unwalk"].state)
        unwalkEnabled=ns if ns then startUnwalk() else stopUnwalk() end updateToggle("Unwalk",ns)
    elseif Keybinds.Drop and input.KeyCode==Keybinds.Drop then task.spawn(doDrop)
    elseif Keybinds.TPDown and input.KeyCode==Keybinds.TPDown then
        task.spawn(doTPDown)
    end
end)

if espEnabled then enableESP() end
applyFOV()
print("EclipseX Duels loaded")
