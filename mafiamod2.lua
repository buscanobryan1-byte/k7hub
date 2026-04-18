
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local ACCENT  = Color3.fromRGB(150,150,150)
local WHITE   = Color3.fromRGB(240,240,255)
local BG      = Color3.fromRGB(8,8,12)
local CARD    = Color3.fromRGB(14,14,22)
local OFF_CLR = Color3.fromRGB(35,35,50)
local MOB_ON  = Color3.fromRGB(176,25,50)
local MOB_OFF = Color3.fromRGB(14,10,24)

NORMAL_SPEED=60 SLOW_SPEED=29 AP_DELAY=0
WP_L_SPD={60,60,29,29,29}
WP_R_SPD={60,60,29,29,29}
POS_L1=Vector3.new(-476.48,-6.28,92.73) POS_L2=Vector3.new(-482.85,-5.03,93.13)
POS_L3=Vector3.new(-475.68,-6.89,92.76) POS_L4=Vector3.new(-476.50,-6.46,27.58)
POS_L5=Vector3.new(-482.42,-5.03,27.84)
POS_R1=Vector3.new(-476.16,-6.52,25.62) POS_R2=Vector3.new(-483.06,-5.03,27.51)
POS_R3=Vector3.new(-476.21,-6.63,27.46) POS_R4=Vector3.new(-476.66,-6.39,92.44)
POS_R5=Vector3.new(-481.94,-5.03,92.42)

aplOn=false aprOn=false apWaiting=false apWaitConn=nil
autoStealEnabled=false isStealing=false stealStartTime=nil
autoStealConn=nil progressConn=nil STEAL_RADIUS=20 STEAL_DURATION=0.35
antiRagdollEnabled=false
unwalkEnabled=false unwalkConn=nil
batAimbotEnabled=false BAT_ENGAGE_RANGE=5
lastApRoute="left"
AIMBOT_SPEED=60 MELEE_OFFSET=3
aimbotConnection=nil lockedTarget=nil
DEFAULT_GRAVITY=196.2
espEnabled=true espConns={} wpEspEnabled=false wpEspFolder=nil
fovValue=70 fovConn=nil
slowDownEnabled=false dropDamagePrevention=false
speedCustomizerActive=true
tauntActive=false tauntLoop=nil
infJumpEnabled=true INF_JUMP_FORCE=54 CLAMP_FALL=80
gChar=nil gHum=nil gHrp=nil speedBB=nil
ProgressBarFill=nil ProgressLabel=nil ProgressPctLabel=nil RadiusInput=nil stealBarLocked=false mobBtnsLocked=false
mobBtnPositions={} StealBarRef=nil SavedPBCPos=nil StealRadiusBox=nil
animalCache={} promptCache={} stealCache={}
toggleStates={} mobileButtons={} mobBtnRefs={}
AutoPlayButtonRef=nil AutoPlayTitleRef=nil
AntiRagdollConns={}
SavedSFPos=nil
CONFIG_KEY="EclipseX_Duels_Config"
changingKeybind=nil
SavedToggleStates={}


Keybinds={
    AutoSteal=Enum.KeyCode.V,
    BatAimbot=Enum.KeyCode.Z,
    AntiRagdoll=Enum.KeyCode.X,
    Unwalk=Enum.KeyCode.N,
    SlowDown=Enum.KeyCode.F7,
    Drop=Enum.KeyCode.F3,
    Taunt=Enum.KeyCode.F4,
    TPDown=Enum.KeyCode.G,
}
KeybindButtons={}

local aimbotHighlight=Instance.new("Highlight")
aimbotHighlight.Name="EclipseAimbotESP"
aimbotHighlight.FillColor=Color3.fromRGB(180,0,255)
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
            data.POS_L1=sv(POS_L1) data.POS_L2=sv(POS_L2) data.POS_L3=sv(POS_L3) data.POS_L4=sv(POS_L4) data.POS_L5=sv(POS_L5)
            data.POS_R1=sv(POS_R1) data.POS_R2=sv(POS_R2) data.POS_R3=sv(POS_R3) data.POS_R4=sv(POS_R4) data.POS_R5=sv(POS_R5)
            data.WP_L_SPD=WP_L_SPD data.WP_R_SPD=WP_R_SPD
            for k,v in pairs(mobBtnPositions) do data["BTN_"..k]=v end
            if StealBarRef then local p=StealBarRef.Position data.PBC_POS={p.X.Scale,p.X.Offset,p.Y.Scale,p.Y.Offset} end
            if SavedSFPos then data.SF_POS=SavedSFPos end
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
                if data.SF_POS then SavedSFPos=data.SF_POS end
                local function lv(k) if data[k] then local t=data[k] return Vector3.new(t[1],t[2],t[3]) end end
                POS_L1=lv("POS_L1") or POS_L1 POS_L2=lv("POS_L2") or POS_L2 POS_L3=lv("POS_L3") or POS_L3 POS_L4=lv("POS_L4") or POS_L4 POS_L5=lv("POS_L5") or POS_L5
                POS_R1=lv("POS_R1") or POS_R1 POS_R2=lv("POS_R2") or POS_R2 POS_R3=lv("POS_R3") or POS_R3 POS_R4=lv("POS_R4") or POS_R4 POS_R5=lv("POS_R5") or POS_R5
                if data.WP_L_SPD then for i=1,5 do if data.WP_L_SPD[i] then WP_L_SPD[i]=data.WP_L_SPD[i] end end end
                if data.WP_R_SPD then for i=1,5 do if data.WP_R_SPD[i] then WP_R_SPD[i]=data.WP_R_SPD[i] end end end
            end
        end
    end)
end
loadConfig()
SavedToggleStates["Auto Play Left"]=nil
SavedToggleStates["Auto Play Right"]=nil

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

-- TAUNT
local function startTaunt()
    if tauntLoop then return end tauntActive=true
    tauntLoop=task.spawn(function()
        while tauntActive do
            pcall(function()
                local TCS=game:GetService("TextChatService")
                local ch=TCS.TextChannels:FindFirstChild("RBXGeneral")
                if ch then ch:SendAsync("/lol Eclipse Better 😂😂")
                else game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents",1):WaitForChild("SayMessageRequest",1):FireServer("/lol Eclipse Better 😂😂","All") end
            end)
            task.wait(0.5)
        end
    end)
end
local function stopTaunt() tauntActive=false if tauntLoop then task.cancel(tauntLoop) tauntLoop=nil end end

-- SPEED BB
local function makeSpeedBB()
    local c=player.Character if not c then return end
    local head=c:FindFirstChild("Head") if not head then return end
    if speedBB then pcall(function() speedBB:Destroy() end) end
    speedBB=Instance.new("BillboardGui") speedBB.Name="EclipseSpeedBB" speedBB.Adornee=head
    speedBB.Size=UDim2.new(0,100,0,22) speedBB.StudsOffset=Vector3.new(0,3.2,0)
    speedBB.AlwaysOnTop=true speedBB.Parent=head
    local lbl=Instance.new("TextLabel") lbl.Name="SpeedLbl" lbl.Size=UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency=1 lbl.TextColor3=Color3.fromRGB(176,25,50) lbl.TextStrokeColor3=Color3.fromRGB(80,0,15)
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

local function enableWPEsp()
    if wpEspFolder then wpEspFolder:Destroy() end
    wpEspFolder=Instance.new("Folder") wpEspFolder.Name="EclipseWPEsp" wpEspFolder.Parent=workspace
    local R_CLR=Color3.fromRGB(220,80,80)
    local wpList={
        {"L-P1",POS_L1,ACCENT},{"L-P2",POS_L2,ACCENT},{"L-P3",POS_L3,ACCENT},{"L-P4",POS_L4,ACCENT},{"L-P5",POS_L5,ACCENT},
        {"R-P1",POS_R1,R_CLR},{"R-P2",POS_R2,R_CLR},{"R-P3",POS_R3,R_CLR},{"R-P4",POS_R4,R_CLR},{"R-P5",POS_R5,R_CLR},
    }
    for _,wp in ipairs(wpList) do
        local p=Instance.new("Part")
        p.Name="WPEsp_"..wp[1] p.Anchored=true p.CanCollide=false p.CastShadow=false
        p.Shape=Enum.PartType.Ball p.Size=Vector3.new(1,1,1) p.Material=Enum.Material.Neon p.Color=wp[3] p.Position=wp[2] p.Parent=wpEspFolder
        local bb=Instance.new("BillboardGui",p)
        bb.Size=UDim2.new(0,70,0,22) bb.StudsOffset=Vector3.new(0,2,0) bb.AlwaysOnTop=true
        local lbl=Instance.new("TextLabel",bb)
        lbl.Size=UDim2.new(1,0,1,0) lbl.BackgroundTransparency=1 lbl.Text=wp[1]
        lbl.TextColor3=WHITE lbl.Font=Enum.Font.GothamBold lbl.TextSize=11
        lbl.TextStrokeTransparency=0.3 lbl.TextStrokeColor3=wp[3]
    end
end
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
    align.Attachment0=attachment align.MaxTorque=math.huge align.Responsiveness=200
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
            local dynamicPredictTime=math.clamp(speed/150,0.05,0.2)
            local predictedPos=targetHRP.Position+(targetVelocity*dynamicPredictTime)
            local dirToTarget=(predictedPos-currentHRP.Position)
            local distance3D=dirToTarget.Magnitude
            local targetStandPos=predictedPos
            if distance3D>0 then targetStandPos=predictedPos-(dirToTarget.Unit*MELEE_OFFSET) end
            align.CFrame=CFrame.lookAt(currentHRP.Position,predictedPos)
            local moveDir=(targetStandPos-currentHRP.Position)
            local distToStandPos=moveDir.Magnitude
            if distToStandPos>1 then currentHRP.AssemblyLinearVelocity=moveDir.Unit*AIMBOT_SPEED
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

-- ROUND START DETECTION
local function isRoundActive()
    local hum=getHum()
    if not hum then return false end
    local ws=hum.WalkSpeed
    if ws<=0 then return false end
    local state=hum:GetState()
    if state==Enum.HumanoidStateType.None or state==Enum.HumanoidStateType.Dead
        or state==Enum.HumanoidStateType.Seated then return false end
    local RS=game:GetService("ReplicatedStorage")
    local roundVal=RS:FindFirstChild("RoundStatus") or RS:FindFirstChild("RoundActive")
        or RS:FindFirstChild("GameStatus") or RS:FindFirstChild("Status")
        or RS:FindFirstChild("RoundState") or RS:FindFirstChild("GameState")
    if roundVal then
        local v=roundVal.Value
        if typeof(v)=="boolean" and not v then return false end
        if typeof(v)=="string" then
            local lv=v:lower()
            if lv:find("intermission") or lv:find("waiting") or lv:find("lobby") or lv:find("countdown") then return false end
        end
        if typeof(v)=="number" and v==0 then return false end
    end
    local wsVal=workspace:FindFirstChild("RoundActive") or workspace:FindFirstChild("RoundStarted")
        or workspace:FindFirstChild("GameStatus") or workspace:FindFirstChild("Status")
    if wsVal then
        local v=wsVal.Value
        if typeof(v)=="boolean" and not v then return false end
        if typeof(v)=="string" then
            local lv=v:lower()
            if lv:find("intermission") or lv:find("waiting") or lv:find("lobby") or lv:find("countdown") then return false end
        end
        if typeof(v)=="number" and v==0 then return false end
    end
    local hrp=getHRP()
    if hrp then
        local spd=Vector3.new(hrp.AssemblyLinearVelocity.X,0,hrp.AssemblyLinearVelocity.Z).Magnitude
        if spd>0.1 or state==Enum.HumanoidStateType.Running or state==Enum.HumanoidStateType.Freefall then
            return true
        end
    end
    return state==Enum.HumanoidStateType.Running or state==Enum.HumanoidStateType.RunningNoPhysics
        or state==Enum.HumanoidStateType.Jumping or state==Enum.HumanoidStateType.Freefall
end

local function cancelApWait()
    apWaiting=false
    if apWaitConn then apWaitConn:Disconnect() apWaitConn=nil end
end

local apRoundStarted=false

local function waitForRoundStart(onRoundStart)
    apRoundStarted=false
    apWaiting=true
    task.spawn(function()
        local timeout=120
        local elapsed=0
        while apWaiting and elapsed<timeout do
            task.wait(0.1)
            elapsed=elapsed+0.1
            if isRoundActive() then
                apRoundStarted=true
                apWaiting=false
                onRoundStart()
                return
            end
        end
        apWaiting=false
    end)
    apWaitConn=player.CharacterAdded:Connect(function()
        cancelApWait()
    end)
end

-- AUTO PLAY
local function setAutoPlayPanelActive(on,route)
    if AutoPlayButtonRef then
        AutoPlayButtonRef.BackgroundColor3=on and Color3.fromRGB(30,200,80) or Color3.fromRGB(30,120,220)
        AutoPlayButtonRef.Text=on and "STOP" or "PLAY"
    end
    if AutoPlayTitleRef then
        if on then AutoPlayTitleRef.Text=(route=="left" and "◄ Auto Play" or "► Auto Play")
        else AutoPlayTitleRef.Text="Auto Play" end
    end
end
local function stopAutoPlayLeft()
    aplOn=false cancelApWait() apRoundStarted=false
    local hh=getHum() if hh then hh:Move(Vector3.zero,false) end
    if not aprOn then setAutoPlayPanelActive(false) end
end
local function stopAutoPlayRight()
    aprOn=false cancelApWait() apRoundStarted=false
    local hh=getHum() if hh then hh:Move(Vector3.zero,false) end
    if not aplOn then setAutoPlayPanelActive(false) end
end

local PRE_ROUND_SPEED=10
local function apMoveTo(targetPos, wpSpeed, stopFn)
    local REACH=2.5
    local UPDATE_RATE=0.05
    while true do
        if stopFn() then return end
        local hrp=getHRP() local hum=getHum()
        if not hrp or not hum then return end
        local speed=apRoundStarted and wpSpeed or PRE_ROUND_SPEED
        hum.WalkSpeed=speed
        local myPos=Vector3.new(hrp.Position.X,0,hrp.Position.Z)
        local flat=Vector3.new(targetPos.X,0,targetPos.Z)
        local d=flat-myPos
        if d.Magnitude<REACH then break end
        hum:Move(d.Unit,false)
        task.wait(UPDATE_RATE)
    end
    local hum=getHum() if hum then hum:Move(Vector3.zero,false) end
end

local function startAutoPlayLeft()
    lastApRoute="left"
    aplOn=true
    local waypoints={
        {pos=POS_L1,spd=WP_L_SPD[1]},{pos=POS_L2,spd=WP_L_SPD[2]},
        {pos=POS_L3,spd=WP_L_SPD[3]},{pos=POS_L4,spd=WP_L_SPD[4]},{pos=POS_L5,spd=WP_L_SPD[5]},
    }
    task.spawn(function()
        for i,wp in ipairs(waypoints) do
            if not aplOn then break end
            apMoveTo(wp.pos, wp.spd, function() return not aplOn end)
            if not aplOn then break end
            if i<#waypoints and AP_DELAY>0 then
                local hh=getHum() if hh then hh:Move(Vector3.zero,false) end
                task.wait(AP_DELAY)
            end
        end
        if aplOn then stopAutoPlayLeft() end
    end)
    setAutoPlayPanelActive(true,"left")
end
local function startAutoPlayRight()
    lastApRoute="right"
    aprOn=true
    local waypoints={
        {pos=POS_R1,spd=WP_R_SPD[1]},{pos=POS_R2,spd=WP_R_SPD[2]},
        {pos=POS_R3,spd=WP_R_SPD[3]},{pos=POS_R4,spd=WP_R_SPD[4]},{pos=POS_R5,spd=WP_R_SPD[5]},
    }
    task.spawn(function()
        for i,wp in ipairs(waypoints) do
            if not aprOn then break end
            apMoveTo(wp.pos, wp.spd, function() return not aprOn end)
            if not aprOn then break end
            if i<#waypoints and AP_DELAY>0 then
                local hh=getHum() if hh then hh:Move(Vector3.zero,false) end
                task.wait(AP_DELAY)
            end
        end
        if aprOn then stopAutoPlayRight() end
    end)
    setAutoPlayPanelActive(true,"right")
end
-- AUTO STEAL
local function isMyBase(plotName)
    local plots=workspace:FindFirstChild("Plots") if not plots then return false end
    local plot=plots:FindFirstChild(plotName) if not plot then return false end
    local sign=plot:FindFirstChild("PlotSign",true) if not sign then return false end
    local yb=sign:FindFirstChild("YourBase",true) return yb and yb:IsA("BillboardGui") and yb.Enabled==true
end
local function detectPlotSide()
    local plots=workspace:FindFirstChild("Plots") if not plots then return nil end
    for _,plot in ipairs(plots:GetChildren()) do
        if plot:IsA("Model") and isMyBase(plot.Name) then
            local pos=plot:GetPivot().Position
            return pos.Z>=60 and "left" or "right"
        end
    end
    return nil
end
local function startAutoPlayAwayFromBase()
    local side=detectPlotSide()
    local route=side=="left" and "right" or (side=="right" and "left" or "right")
    -- If round already active, set flag immediately
    if isRoundActive() then apRoundStarted=true end
    -- Start moving immediately
    if route=="right" then
        startAutoPlayRight()
    else
        startAutoPlayLeft()
    end
    -- Watch for round start if not already active
    if not apRoundStarted then
        waitForRoundStart(function()
            setAutoPlayPanelActive(true, route)
        end)
    end
    setAutoPlayPanelActive(true, route)
    return route
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
local function buildCallbacks(prompt)
    if stealCache[prompt] then return end
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
    if ProgressLabel then ProgressLabel.Text="STEALING..." end
    if progressConn then progressConn:Disconnect() end
    progressConn=RunService.Heartbeat:Connect(function()
        if not isStealing then progressConn:Disconnect() return end
        local prog=math.clamp((tick()-stealStartTime)/STEAL_DURATION,0,1)
        if ProgressBarFill then ProgressBarFill.Size=UDim2.new(prog,0,1,0) end
        if ProgressPctLabel then ProgressPctLabel.Text=math.floor(prog*100).."%" end
    end)
    task.spawn(function()
        for _,f in ipairs(data.hold) do task.spawn(f) end
        task.wait(STEAL_DURATION)
        for _,f in ipairs(data.trigger) do task.spawn(f) end
        if progressConn then progressConn:Disconnect() end
        if ProgressLabel then ProgressLabel.Text="READY" end if ProgressPctLabel then ProgressPctLabel.Text="" end
        if ProgressBarFill then ProgressBarFill.Size=UDim2.new(0,0,1,0) end
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
        local prompt=promptCache[target.uid]
        if not prompt or not prompt.Parent then prompt=findPromptForAnimal(target) end
        if prompt then buildCallbacks(prompt) execSteal(prompt) end
    end)
end
local function stopAutoSteal()
    if autoStealConn then autoStealConn:Disconnect() autoStealConn=nil end isStealing=false
    if progressConn then progressConn:Disconnect() progressConn=nil end
    if ProgressBarFill then ProgressBarFill.Size=UDim2.new(0,0,1,0) end
    if ProgressLabel then ProgressLabel.Text="READY" end if ProgressPctLabel then ProgressPctLabel.Text="" end
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
    if speedCustomizerActive and not batAimbotEnabled and not aplOn and not aprOn then
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

-- GUI
local ScreenGui=Instance.new("ScreenGui")
ScreenGui.Name="EclipseXDuels" ScreenGui.ResetOnSpawn=false
ScreenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling ScreenGui.IgnoreGuiInset=false
ScreenGui.Parent=player:WaitForChild("PlayerGui")

local MainFrame=Instance.new("Frame")
MainFrame.Name="MainFrame" MainFrame.Size=UDim2.new(0,260,0,420)
MainFrame.Position=UDim2.new(0.5,-130,0.5,-210) MainFrame.BackgroundColor3=BG
MainFrame.BorderSizePixel=0 MainFrame.Active=true MainFrame.Visible=false MainFrame.Parent=ScreenGui
Instance.new("UICorner",MainFrame).CornerRadius=UDim.new(0,16)

local MainStroke=Instance.new("UIStroke",MainFrame)
MainStroke.Thickness=2 MainStroke.Color=ACCENT MainStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
task.spawn(function()
    while MainFrame and MainFrame.Parent do
        for i=0,20 do MainStroke.Thickness=2+i*0.05 task.wait(0.04) end
        for i=0,20 do MainStroke.Thickness=3-i*0.05 task.wait(0.04) end
    end
end)

local TitleBar=Instance.new("Frame",MainFrame)
TitleBar.Size=UDim2.new(1,0,0,52) TitleBar.BackgroundColor3=Color3.fromRGB(10,8,18) TitleBar.BorderSizePixel=0
Instance.new("UICorner",TitleBar).CornerRadius=UDim.new(0,16)
local TitleFix=Instance.new("Frame",TitleBar)
TitleFix.Size=UDim2.new(1,0,0,16) TitleFix.Position=UDim2.new(0,0,1,-16)
TitleFix.BackgroundColor3=Color3.fromRGB(10,8,18) TitleFix.BorderSizePixel=0
local TitleLbl=Instance.new("TextLabel",TitleBar)
TitleLbl.Size=UDim2.new(1,0,1,0) TitleLbl.Position=UDim2.new(0,0,0,0) TitleLbl.BackgroundTransparency=1 TitleLbl.Text="Mafia Hub"
TitleLbl.Font=Enum.Font.GothamBlack TitleLbl.TextSize=20 TitleLbl.TextColor3=WHITE
TitleLbl.TextXAlignment=Enum.TextXAlignment.Center
TitleLbl.TextStrokeColor3=ACCENT TitleLbl.TextStrokeTransparency=0.5



local TabContainer=Instance.new("Frame",MainFrame)
TabContainer.Size=UDim2.new(1,-20,0,34) TabContainer.Position=UDim2.new(0,10,0,60) TabContainer.BackgroundTransparency=1

local function makeTab(text,xScale,xPos)
    local t=Instance.new("TextButton",TabContainer)
    t.Size=UDim2.new(xScale,-4,1,0) t.Position=UDim2.new(xPos,2,0,0)
    t.BackgroundColor3=OFF_CLR t.Text=text t.Font=Enum.Font.GothamBold t.TextSize=11
    t.TextColor3=Color3.fromRGB(160,160,160) t.BorderSizePixel=0
    Instance.new("UICorner",t).CornerRadius=UDim.new(0,8) return t
end

local FeatTab=makeTab("FEATURES",0.2,0) local MovTab=makeTab("MOVEMENT",0.2,0.2)
local VisTab=makeTab("VISUALS",0.2,0.4) local SetTab=makeTab("SETTINGS",0.2,0.6) local BindTab=makeTab("BINDS",0.2,0.8)

local function makeScrollFrame()
    local sf=Instance.new("ScrollingFrame",MainFrame)
    sf.Size=UDim2.new(1,-20,1,-148) sf.Position=UDim2.new(0,10,0,103)
    sf.BackgroundTransparency=1 sf.BorderSizePixel=0 sf.ScrollBarThickness=4 sf.ScrollBarImageColor3=ACCENT
    sf.CanvasSize=UDim2.new(0,0,0,0) sf.AutomaticCanvasSize=Enum.AutomaticSize.Y sf.Visible=false
    local ll=Instance.new("UIListLayout",sf) ll.Padding=UDim.new(0,6) ll.SortOrder=Enum.SortOrder.LayoutOrder
    return sf
end

local FeatFrame=makeScrollFrame() local MovFrame=makeScrollFrame()
local VisFrame=makeScrollFrame() local SetFrame=makeScrollFrame() local BindFrame=makeScrollFrame()
FeatFrame.Visible=true

local frames={FeatFrame,MovFrame,VisFrame,SetFrame,BindFrame}
local tabs={FeatTab,MovTab,VisTab,SetTab,BindTab}

local function selectTab(idx)
    for i,sf in ipairs(frames) do sf.Visible=(i==idx) end
    for i,tb in ipairs(tabs) do
        tb.BackgroundColor3=(i==idx) and ACCENT or OFF_CLR
        tb.TextColor3=(i==idx) and Color3.fromRGB(255,255,255) or Color3.fromRGB(160,160,160)
    end
end
for i,tb in ipairs(tabs) do tb.MouseButton1Click:Connect(function() selectTab(i) end) end
selectTab(1)

local function makeToggle(parent,name,order,callback,defaultOn)
    local row=Instance.new("Frame",parent)
    row.Size=UDim2.new(1,0,0,44) row.BackgroundColor3=CARD row.BorderSizePixel=0 row.LayoutOrder=order
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,10)
    local lbl=Instance.new("TextLabel",row)
    lbl.Size=UDim2.new(1,-70,1,0) lbl.Position=UDim2.new(0,14,0,0) lbl.BackgroundTransparency=1
    lbl.Text=name lbl.TextColor3=WHITE lbl.Font=Enum.Font.GothamBold lbl.TextSize=13 lbl.TextXAlignment=Enum.TextXAlignment.Left
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
    if mobBtnRefs[name] then TweenService:Create(mobBtnRefs[name],TweenInfo.new(0.15),{BackgroundColor3=state and MOB_ON or MOB_OFF}):Play() end
end

local function makeSection(parent,text,order)
    local lbl=Instance.new("TextLabel",parent)
    lbl.Size=UDim2.new(1,0,0,26) lbl.BackgroundTransparency=1 lbl.Text=text
    lbl.TextColor3=ACCENT lbl.Font=Enum.Font.GothamBold lbl.TextSize=11
    lbl.TextXAlignment=Enum.TextXAlignment.Left lbl.LayoutOrder=order
end

local function makeNumInput(parent,labelText,defaultVal,order,onChanged)
    local row=Instance.new("Frame",parent)
    row.Size=UDim2.new(1,0,0,44) row.BackgroundColor3=CARD row.BorderSizePixel=0 row.LayoutOrder=order
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,10)
    local lbl=Instance.new("TextLabel",row)
    lbl.Size=UDim2.new(1,-90,1,0) lbl.Position=UDim2.new(0,14,0,0) lbl.BackgroundTransparency=1
    lbl.Text=labelText lbl.TextColor3=WHITE lbl.Font=Enum.Font.GothamBold lbl.TextSize=13 lbl.TextXAlignment=Enum.TextXAlignment.Left
    local box=Instance.new("TextBox",row)
    box.Size=UDim2.new(0,68,0,28) box.Position=UDim2.new(1,-78,0.5,-14)
    box.BackgroundColor3=Color3.fromRGB(20,18,32) box.Text=tostring(defaultVal)
    box.TextColor3=ACCENT box.Font=Enum.Font.GothamBold box.TextSize=13
    box.TextXAlignment=Enum.TextXAlignment.Center box.BorderSizePixel=0 box.ClearTextOnFocus=false
    Instance.new("UICorner",box).CornerRadius=UDim.new(0,6)
    box.FocusLost:Connect(function()
        local n=tonumber(box.Text)
        if n then if onChanged then onChanged(n) end task.defer(saveConfig)
        else box.Text=tostring(defaultVal) end
    end)
    return row,box
end

-- SPEED CUSTOMIZER FLOAT
local SpeedFloatGui=Instance.new("ScreenGui")
SpeedFloatGui.Name="EclipseSpeedFloat" SpeedFloatGui.ResetOnSpawn=false
SpeedFloatGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
SpeedFloatGui.Parent=player:WaitForChild("PlayerGui")
local SpeedFloat=Instance.new("Frame",SpeedFloatGui)
SpeedFloat.Name="SpeedFloat" SpeedFloat.Size=UDim2.new(0,220,0,142)
SpeedFloat.Position=SavedSFPos and UDim2.new(SavedSFPos[1],SavedSFPos[2],SavedSFPos[3],SavedSFPos[4]) or UDim2.new(0.5,-110,0.3,0) SpeedFloat.BackgroundColor3=BG
SpeedFloat.BorderSizePixel=0 SpeedFloat.Visible=false SpeedFloat.Active=true
local sfCorner=Instance.new("UICorner",SpeedFloat) sfCorner.CornerRadius=UDim.new(0,16)
local sfStroke=Instance.new("UIStroke",SpeedFloat) sfStroke.Color=ACCENT sfStroke.Thickness=1.5
local sfBar=Instance.new("Frame",SpeedFloat)
sfBar.Name="SFBar" sfBar.Size=UDim2.new(1,0,0,36) sfBar.BackgroundColor3=Color3.fromRGB(18,14,32) sfBar.BorderSizePixel=0
local sfBarCorner=Instance.new("UICorner",sfBar) sfBarCorner.CornerRadius=UDim.new(0,16)
local sfTitle=Instance.new("TextLabel",sfBar)
sfTitle.Size=UDim2.new(1,-40,1,0) sfTitle.Position=UDim2.new(0,12,0,0) sfTitle.BackgroundTransparency=1
sfTitle.Text="Speed Customizer" sfTitle.TextColor3=WHITE sfTitle.Font=Enum.Font.GothamBold
sfTitle.TextSize=13 sfTitle.TextXAlignment=Enum.TextXAlignment.Left
local sfArrow=Instance.new("TextButton",sfBar)
sfArrow.Size=UDim2.new(0,28,0,28) sfArrow.Position=UDim2.new(1,-34,0.5,-14)
sfArrow.BackgroundTransparency=1 sfArrow.Text="▲" sfArrow.TextColor3=ACCENT
sfArrow.Font=Enum.Font.GothamBold sfArrow.TextSize=13 sfArrow.BorderSizePixel=0
local sfBody=Instance.new("Frame",SpeedFloat)
sfBody.Size=UDim2.new(1,0,0,106) sfBody.Position=UDim2.new(0,0,0,36)
sfBody.BackgroundTransparency=1 sfBody.BorderSizePixel=0
local sfLayout=Instance.new("UIListLayout",sfBody)
sfLayout.Padding=UDim.new(0,5) sfLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center
local sfPad=Instance.new("UIPadding",sfBody)
sfPad.PaddingTop=UDim.new(0,6) sfPad.PaddingLeft=UDim.new(0,10) sfPad.PaddingRight=UDim.new(0,10)
local sfActive=true
local sfSavedNormal,sfSavedCarry=NORMAL_SPEED,SLOW_SPEED
local sfEnableRow=Instance.new("Frame",sfBody)
sfEnableRow.Size=UDim2.new(1,0,0,30) sfEnableRow.BackgroundColor3=CARD sfEnableRow.BorderSizePixel=0
Instance.new("UICorner",sfEnableRow).CornerRadius=UDim.new(0,8)
local sfEnableLbl=Instance.new("TextLabel",sfEnableRow)
sfEnableLbl.Size=UDim2.new(0.52,0,1,0) sfEnableLbl.Position=UDim2.new(0,10,0,0) sfEnableLbl.BackgroundTransparency=1
sfEnableLbl.Text="Active" sfEnableLbl.TextColor3=WHITE sfEnableLbl.Font=Enum.Font.GothamBold
sfEnableLbl.TextSize=13 sfEnableLbl.TextXAlignment=Enum.TextXAlignment.Left
local sfPill=Instance.new("TextButton",sfEnableRow)
sfPill.Size=UDim2.new(0,44,0,22) sfPill.Position=UDim2.new(1,-52,0.5,-11)
sfPill.BackgroundColor3=ACCENT sfPill.BorderSizePixel=0 sfPill.Text="" sfPill.AutoButtonColor=false
Instance.new("UICorner",sfPill).CornerRadius=UDim.new(1,0)
local sfDot=Instance.new("Frame",sfPill)
sfDot.Size=UDim2.new(0,16,0,16) sfDot.Position=UDim2.new(1,-20,0.5,-8)
sfDot.BackgroundColor3=WHITE sfDot.BorderSizePixel=0
Instance.new("UICorner",sfDot).CornerRadius=UDim.new(1,0)
local function setSpeedCustomizerActive(on)
    if on then
        sfActive=true speedCustomizerActive=true
        NORMAL_SPEED=sfSavedNormal SLOW_SPEED=sfSavedCarry
        sfPill.BackgroundColor3=ACCENT sfDot.Position=UDim2.new(1,-20,0.5,-8)
    else
        if sfActive then sfSavedNormal=NORMAL_SPEED sfSavedCarry=SLOW_SPEED end
        sfActive=false speedCustomizerActive=false
        NORMAL_SPEED=16 SLOW_SPEED=16
        sfPill.BackgroundColor3=Color3.fromRGB(50,50,60) sfDot.Position=UDim2.new(0,4,0.5,-8)
        local chr=player.Character
        if chr then
            local hum=chr:FindFirstChildOfClass("Humanoid") if hum then hum.WalkSpeed=16 end
            local hrp=chr:FindFirstChild("HumanoidRootPart") if hrp then hrp.AssemblyLinearVelocity=Vector3.new(0,hrp.AssemblyLinearVelocity.Y,0) end
        end
    end
end
sfPill.MouseButton1Click:Connect(function()
    setSpeedCustomizerActive(not sfActive)
end)
local function makeFloatRow(labelText,getValue,setValue)
    local row=Instance.new("Frame",sfBody)
    row.Size=UDim2.new(1,0,0,30) row.BackgroundColor3=CARD row.BorderSizePixel=0
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
    local lbl=Instance.new("TextLabel",row)
    lbl.Size=UDim2.new(0.52,0,1,0) lbl.Position=UDim2.new(0,10,0,0) lbl.BackgroundTransparency=1
    lbl.Text=labelText lbl.TextColor3=WHITE lbl.Font=Enum.Font.GothamBold
    lbl.TextSize=13 lbl.TextXAlignment=Enum.TextXAlignment.Left
    local box=Instance.new("TextBox",row)
    box.Size=UDim2.new(0.42,0,0.7,0) box.Position=UDim2.new(0.55,0,0.15,0)
    box.BackgroundColor3=Color3.fromRGB(20,18,32) box.Text=tostring(getValue())
    box.TextColor3=ACCENT box.Font=Enum.Font.GothamBold box.TextSize=14
    box.TextXAlignment=Enum.TextXAlignment.Center box.BorderSizePixel=0 box.ClearTextOnFocus=false
    Instance.new("UICorner",box).CornerRadius=UDim.new(0,6)
    box.FocusLost:Connect(function()
        local n=tonumber(box.Text)
        if n then setValue(n) box.Text=tostring(n) task.defer(saveConfig)
        else box.Text=tostring(getValue()) end
    end)
end
makeFloatRow("Speed",function() return sfActive and NORMAL_SPEED or sfSavedNormal end,function(n) if sfActive then NORMAL_SPEED=n else sfSavedNormal=n end end)
makeFloatRow("Carry",function() return sfActive and SLOW_SPEED or sfSavedCarry end,function(n) if sfActive then SLOW_SPEED=n else sfSavedCarry=n end end)
local sfOpen=true
sfArrow.MouseButton1Click:Connect(function()
    sfOpen=not sfOpen sfBody.Visible=sfOpen
    sfArrow.Text=sfOpen and "▲" or "▼"
    SpeedFloat.Size=sfOpen and UDim2.new(0,220,0,142) or UDim2.new(0,220,0,36)
end)
local sfDragStart,sfDragStartPos
sfBar.InputBegan:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
        sfDragStart=inp.Position sfDragStartPos=SpeedFloat.Position
    end
end)
sfBar.InputChanged:Connect(function(inp)
    if sfDragStart and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then
        local d=inp.Position-sfDragStart
        SpeedFloat.Position=UDim2.new(sfDragStartPos.X.Scale,sfDragStartPos.X.Offset+d.X,sfDragStartPos.Y.Scale,sfDragStartPos.Y.Offset+d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
        if sfDragStart then
            local p=SpeedFloat.Position SavedSFPos={p.X.Scale,p.X.Offset,p.Y.Scale,p.Y.Offset}
            task.defer(saveConfig)
        end
        sfDragStart=nil
    end
end)

local dropMobBtnRef=nil local tpMobBtnRef=nil
local autoMedusaMobRef=nil

-- FEATURES TAB
makeSection(FeatFrame,"  COMBAT",1)
makeToggle(FeatFrame,"Lock",2,function(v)
    if v then
        if aplOn then stopAutoPlayLeft() updateToggle("Auto Play Left",false) end
        if aprOn then stopAutoPlayRight() updateToggle("Auto Play Right",false) end
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
    if dropMobBtnRef then dropMobBtnRef.Visible=v end
end)
makeToggle(FeatFrame,"TP Down",13,function(v)
    if tpMobBtnRef then tpMobBtnRef.Visible=v end
end)

makeSection(FeatFrame,"  TAUNT",14)
do
    local tauntRow=Instance.new("Frame",FeatFrame)
    tauntRow.Size=UDim2.new(1,0,0,44) tauntRow.BackgroundColor3=CARD tauntRow.BorderSizePixel=0 tauntRow.LayoutOrder=15
    Instance.new("UICorner",tauntRow).CornerRadius=UDim.new(0,10)
    local tauntLbl=Instance.new("TextLabel",tauntRow)
    tauntLbl.Size=UDim2.new(1,-70,1,0) tauntLbl.Position=UDim2.new(0,14,0,0) tauntLbl.BackgroundTransparency=1
    tauntLbl.Text="Taunt Spam" tauntLbl.TextColor3=WHITE tauntLbl.Font=Enum.Font.GothamBold
    tauntLbl.TextSize=13 tauntLbl.TextXAlignment=Enum.TextXAlignment.Left
    local pW,pH,dSz=46,24,18
    local track=Instance.new("Frame",tauntRow)
    track.Size=UDim2.new(0,pW,0,pH) track.Position=UDim2.new(1,-(pW+12),0.5,-pH/2)
    track.BackgroundColor3=OFF_CLR track.BorderSizePixel=0
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
    local dot=Instance.new("Frame",track)
    dot.Size=UDim2.new(0,dSz,0,dSz) dot.Position=UDim2.new(0,3,0.5,-dSz/2)
    dot.BackgroundColor3=Color3.fromRGB(255,255,255) dot.BorderSizePixel=0
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
    local btn=Instance.new("TextButton",tauntRow)
    btn.Size=UDim2.new(1,0,1,0) btn.BackgroundTransparency=1 btn.Text=""
    btn.MouseButton1Click:Connect(function()
        if not tauntActive then startTaunt() track.BackgroundColor3=ACCENT dot.Position=UDim2.new(1,-dSz-3,0.5,-dSz/2)
        else stopTaunt() track.BackgroundColor3=OFF_CLR dot.Position=UDim2.new(0,3,0.5,-dSz/2) end
    end)
end

-- MOVEMENT TAB

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

    local function makeWPRow(parent,label,order,getPos,setPos)
        local row=Instance.new("Frame",parent)
        row.Size=UDim2.new(1,0,0,46) row.BackgroundColor3=CARD row.BorderSizePixel=0 row.LayoutOrder=order
        Instance.new("UICorner",row).CornerRadius=UDim.new(0,10)
        Instance.new("UIStroke",row).Color=Color3.fromRGB(50,40,80)
        local lbl=Instance.new("TextLabel",row)
        lbl.Size=UDim2.new(0,36,1,0) lbl.Position=UDim2.new(0,10,0,0) lbl.BackgroundTransparency=1
        lbl.Text=label lbl.TextColor3=WHITE lbl.Font=Enum.Font.GothamBold lbl.TextSize=12
        lbl.TextXAlignment=Enum.TextXAlignment.Left
        local function makeBox(xOff,val,clr)
            local b=Instance.new("TextBox",row)
            b.Size=UDim2.new(0,54,0,30) b.Position=UDim2.new(0,xOff,0.5,-15)
            b.BackgroundColor3=Color3.fromRGB(18,15,30) b.Text=string.format("%.2f",val)
            b.TextColor3=clr b.Font=Enum.Font.GothamBold b.TextSize=11
            b.TextXAlignment=Enum.TextXAlignment.Center b.BorderSizePixel=0 b.ClearTextOnFocus=false
            Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
            return b
        end
        local p=getPos()
        local xBox=makeBox(48,p.X,Color3.fromRGB(120,200,255))
        local yBox=makeBox(106,p.Y,Color3.fromRGB(150,255,150))
        local zBox=makeBox(164,p.Z,ACCENT)
        -- axis labels
        for i,data in ipairs({{48,"X"},{106,"Y"},{164,"Z"}}) do
            local al=Instance.new("TextLabel",row)
            al.Size=UDim2.new(0,54,0,10) al.Position=UDim2.new(0,data[1],0,2)
            al.BackgroundTransparency=1 al.Text=data[2] al.Font=Enum.Font.GothamBold al.TextSize=8
            al.TextColor3=Color3.fromRGB(140,120,180) al.TextXAlignment=Enum.TextXAlignment.Center
        end
        local function apply()
            local x=tonumber(xBox.Text) local y=tonumber(yBox.Text) local z=tonumber(zBox.Text)
            if x and y and z then setPos(Vector3.new(x,y,z)) task.defer(saveConfig) end
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
            local lbl=Instance.new("TextLabel",row)
            lbl.Size=UDim2.new(0,28,1,0) lbl.Position=UDim2.new(0,10,0,0) lbl.BackgroundTransparency=1
            lbl.Text=label lbl.TextColor3=WHITE lbl.Font=Enum.Font.GothamBold lbl.TextSize=13 lbl.TextXAlignment=Enum.TextXAlignment.Left
            local function makeBox(xPos, capText, getV, setV, clr)
                local cap=Instance.new("TextLabel",row)
                cap.Size=UDim2.new(0,12,0,16) cap.Position=UDim2.new(0,xPos-14,0.5,-8) cap.BackgroundTransparency=1
                cap.Text=capText cap.TextColor3=clr cap.Font=Enum.Font.GothamBold cap.TextSize=10
                local box=Instance.new("TextBox",row)
                box.Size=UDim2.new(0,68,0,28) box.Position=UDim2.new(0,xPos,0.5,-14)
                box.BackgroundColor3=Color3.fromRGB(20,18,32) box.Text=tostring(getV())
                box.TextColor3=clr box.Font=Enum.Font.GothamBold box.TextSize=13
                box.TextXAlignment=Enum.TextXAlignment.Center box.BorderSizePixel=0 box.ClearTextOnFocus=false
                Instance.new("UICorner",box).CornerRadius=UDim.new(0,6)
                box.FocusLost:Connect(function()
                    local n=tonumber(box.Text)
                    if n then setV(math.max(1,n)) task.defer(saveConfig)
                    else box.Text=tostring(getV()) end
                end)
                return box
            end
            makeBox(40, "L", getLSpd, setLSpd, Color3.fromRGB(120,200,255))
            makeBox(136, "R", getRSpd, setRSpd, ACCENT)
        end
        makeWPSpeedRow(34,"P1:", function() return WP_L_SPD[1] end, function(v) WP_L_SPD[1]=v end, function() return WP_R_SPD[1] end, function(v) WP_R_SPD[1]=v end)
        makeWPSpeedRow(35,"P2:", function() return WP_L_SPD[2] end, function(v) WP_L_SPD[2]=v end, function() return WP_R_SPD[2] end, function(v) WP_R_SPD[2]=v end)
        makeWPSpeedRow(36,"P3:", function() return WP_L_SPD[3] end, function(v) WP_L_SPD[3]=v end, function() return WP_R_SPD[3] end, function(v) WP_R_SPD[3]=v end)
        makeWPSpeedRow(37,"P4:", function() return WP_L_SPD[4] end, function(v) WP_L_SPD[4]=v end, function() return WP_R_SPD[4] end, function(v) WP_R_SPD[4]=v end)
        makeWPSpeedRow(38,"P5:", function() return WP_L_SPD[5] end, function(v) WP_L_SPD[5]=v end, function() return WP_R_SPD[5] end, function(v) WP_R_SPD[5]=v end)
    end
    -- Delay input
    makeNumInput(MovFrame,"Delay (s)",AP_DELAY,39,function(n)
        AP_DELAY=math.max(0,n)
    end)
    makeToggle(MovFrame,"Waypoint ESP",40,function(v)
        wpEspEnabled=v
        if v then enableWPEsp() else disableWPEsp() end
    end)
end

-- VISUALS TAB
makeSection(VisFrame,"  PLAYER",1)
makeToggle(VisFrame,"Player ESP",2,function(v) espEnabled=v if v then enableESP() else disableESP() end end,true)
makeSection(VisFrame,"  SPEED",3)
makeToggle(VisFrame,"Speed Customizer",4,function(v)
    SpeedFloat.Visible=v
    setSpeedCustomizerActive(v)
    if v then
        local RS=game:GetService("RunService")
        local elapsed=0
        local slowConn slowConn=RS.RenderStepped:Connect(function(dt)
            elapsed=elapsed+dt
            local t=math.clamp(elapsed/0.6,0,1)
            workspace.CurrentCamera.FieldOfView=math.lerp(fovValue*0.7,fovValue,t)
            if t>=1 then workspace.CurrentCamera.FieldOfView=fovValue slowConn:Disconnect() end
        end)
    end
end)

-- SETTINGS TAB
makeSection(SetFrame,"  STEAL",1)
local _,_srb=makeNumInput(SetFrame,"Steal Radius",STEAL_RADIUS,5,function(v) STEAL_RADIUS=math.clamp(v,5,200) if RadiusInput then RadiusInput.Text=tostring(STEAL_RADIUS) end end) StealRadiusBox=_srb
makeNumInput(SetFrame,"Steal Duration",STEAL_DURATION,6,function(v) STEAL_DURATION=math.max(0.05,v) end)
makeSection(SetFrame,"  CAMERA / BAT",11)
makeNumInput(SetFrame,"FOV",fovValue,12,function(v) fovValue=v applyFOV() end)
makeNumInput(SetFrame,"Aimbot Speed",AIMBOT_SPEED,13,function(v) AIMBOT_SPEED=v end)
makeNumInput(SetFrame,"Engage Range",BAT_ENGAGE_RANGE,14,function(v) BAT_ENGAGE_RANGE=v end)
makeSection(SetFrame,"  UI",15)
makeToggle(SetFrame,"UI Lock",16,function(v) stealBarLocked=v mobBtnsLocked=v end)
makeSection(SetFrame,"  CONFIG",17)

do
    local saveBtn=Instance.new("TextButton",SetFrame)
    saveBtn.Size=UDim2.new(1,0,0,40) saveBtn.BackgroundColor3=Color3.fromRGB(20,60,30)
    saveBtn.Text="💾  SAVE CONFIG" saveBtn.Font=Enum.Font.GothamBlack saveBtn.TextSize=13
    saveBtn.TextColor3=WHITE saveBtn.BorderSizePixel=0 saveBtn.LayoutOrder=18
    Instance.new("UICorner",saveBtn).CornerRadius=UDim.new(0,10)
    saveBtn.MouseButton1Click:Connect(function()
        saveConfig() saveBtn.Text="✔ SAVED!" task.delay(1.5,function() saveBtn.Text="💾  SAVE CONFIG" end)
    end)
end

-- BINDS TAB
makeSection(BindFrame,"  KEYBINDS (click to rebind)",1)
do
    local bindHint=Instance.new("TextLabel",BindFrame)
    bindHint.Size=UDim2.new(1,0,0,36) bindHint.BackgroundColor3=Color3.fromRGB(20,12,35)
    bindHint.BackgroundTransparency=0 bindHint.BorderSizePixel=0
    bindHint.Text="Click a key button then press\nany key to rebind. CTRL = clear."
    bindHint.TextColor3=Color3.fromRGB(180,160,220) bindHint.Font=Enum.Font.Gotham
    bindHint.TextSize=11 bindHint.TextWrapped=true bindHint.LayoutOrder=2
    Instance.new("UICorner",bindHint).CornerRadius=UDim.new(0,8)
end

local bindList={
    {"Auto Steal","AutoSteal"},
    {"Lock","BatAimbot"},{"Anti Ragdoll","AntiRagdoll"},{"Unwalk","Unwalk"},
    {"Drop","Drop"},
    {"Taunt","Taunt"},{"TP Down","TPDown"},
}
for idx,entry in ipairs(bindList) do
    local displayName,keyName=entry[1],entry[2]
    local row=Instance.new("Frame",BindFrame)
    row.Size=UDim2.new(1,0,0,44) row.BackgroundColor3=CARD row.BorderSizePixel=0 row.LayoutOrder=idx+2
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,10)
    local nameLbl=Instance.new("TextLabel",row)
    nameLbl.Size=UDim2.new(1,-110,1,0) nameLbl.Position=UDim2.new(0,14,0,0) nameLbl.BackgroundTransparency=1
    nameLbl.Text=displayName nameLbl.TextColor3=WHITE nameLbl.Font=Enum.Font.GothamBold
    nameLbl.TextSize=13 nameLbl.TextXAlignment=Enum.TextXAlignment.Left
    local keyBtn=Instance.new("TextButton",row)
    keyBtn.Size=UDim2.new(0,90,0,30) keyBtn.Position=UDim2.new(1,-98,0.5,-15)
    keyBtn.BackgroundColor3=Color3.fromRGB(30,20,50)
    keyBtn.Text=Keybinds[keyName] and tostring(Keybinds[keyName]):gsub("Enum.KeyCode.","") or "NONE"
    keyBtn.Font=Enum.Font.GothamBold keyBtn.TextSize=11 keyBtn.TextColor3=ACCENT keyBtn.BorderSizePixel=0
    Instance.new("UICorner",keyBtn).CornerRadius=UDim.new(0,8)
    KeybindButtons[keyName]=keyBtn
    keyBtn.MouseButton1Click:Connect(function()
        if changingKeybind then return end
        changingKeybind=keyName keyBtn.Text="Press key..." keyBtn.TextColor3=Color3.fromRGB(255,200,50)
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

-- PROGRESS BAR
do
    local PBC=Instance.new("Frame",ScreenGui)
    PBC.Size=UDim2.new(0,330,0,46)
    PBC.Position=SavedPBCPos and UDim2.new(SavedPBCPos[1],SavedPBCPos[2],SavedPBCPos[3],SavedPBCPos[4]) or UDim2.new(0.5,-165,1,-100)
    StealBarRef=PBC
    PBC.BackgroundColor3=Color3.fromRGB(10,8,18) PBC.BackgroundTransparency=0.08 PBC.BorderSizePixel=0
    Instance.new("UICorner",PBC).CornerRadius=UDim.new(0,12)
    local pbs=Instance.new("UIStroke",PBC) pbs.Color=ACCENT pbs.Thickness=1.2
    task.spawn(function()
        local grad=Instance.new("UIGradient",pbs)
        grad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,ACCENT),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(30,20,50)),ColorSequenceKeypoint.new(1,ACCENT)})
        local r=0 while PBC and PBC.Parent do r=(r+2)%360 grad.Rotation=r task.wait(0.02) end
    end)
    -- hub name
    local hubLbl=Instance.new("TextLabel",PBC)
    hubLbl.Size=UDim2.new(0,82,0,22) hubLbl.Position=UDim2.new(0,10,0,5)
    hubLbl.BackgroundTransparency=1 hubLbl.Text="Mafia Hub" hubLbl.TextColor3=ACCENT
    hubLbl.Font=Enum.Font.GothamBlack hubLbl.TextSize=11 hubLbl.TextXAlignment=Enum.TextXAlignment.Left hubLbl.ZIndex=3
    -- separator
    local sep=Instance.new("TextLabel",PBC)
    sep.Size=UDim2.new(0,8,0,22) sep.Position=UDim2.new(0,94,0,5)
    sep.BackgroundTransparency=1 sep.Text="|" sep.TextColor3=Color3.fromRGB(80,70,110)
    sep.Font=Enum.Font.GothamBold sep.TextSize=13 sep.ZIndex=3
    -- status (READY / STEALING)
    ProgressLabel=Instance.new("TextLabel",PBC)
    ProgressLabel.Size=UDim2.new(0,58,0,22) ProgressLabel.Position=UDim2.new(0,104,0,5)
    ProgressLabel.BackgroundTransparency=1 ProgressLabel.Text="READY" ProgressLabel.TextColor3=WHITE
    ProgressLabel.Font=Enum.Font.GothamBold ProgressLabel.TextSize=11
    ProgressLabel.TextXAlignment=Enum.TextXAlignment.Left ProgressLabel.ZIndex=3
    -- steal %
    ProgressPctLabel=Instance.new("TextLabel",PBC)
    ProgressPctLabel.Size=UDim2.new(0,28,0,22) ProgressPctLabel.Position=UDim2.new(0,162,0,5)
    ProgressPctLabel.BackgroundTransparency=1 ProgressPctLabel.Text="" ProgressPctLabel.TextColor3=ACCENT
    ProgressPctLabel.Font=Enum.Font.GothamBlack ProgressPctLabel.TextSize=11
    ProgressPctLabel.TextXAlignment=Enum.TextXAlignment.Left ProgressPctLabel.ZIndex=3
    -- FPS
    local FPSBar=Instance.new("TextLabel",PBC)
    FPSBar.Size=UDim2.new(0,56,0,22) FPSBar.Position=UDim2.new(0,192,0,5)
    FPSBar.BackgroundTransparency=1 FPSBar.Text="FPS 0" FPSBar.TextColor3=ACCENT
    FPSBar.Font=Enum.Font.GothamBold FPSBar.TextSize=11 FPSBar.TextXAlignment=Enum.TextXAlignment.Left FPSBar.ZIndex=3
    -- PING
    local PingBar=Instance.new("TextLabel",PBC)
    PingBar.Size=UDim2.new(0,62,0,22) PingBar.Position=UDim2.new(0,250,0,5)
    PingBar.BackgroundTransparency=1 PingBar.Text="PING 0ms" PingBar.TextColor3=ACCENT
    PingBar.Font=Enum.Font.GothamBold PingBar.TextSize=11 PingBar.TextXAlignment=Enum.TextXAlignment.Left PingBar.ZIndex=3
    -- Radius label + input (bottom right)
    local rl=Instance.new("TextLabel",PBC)
    rl.Size=UDim2.new(0,20,0,12) rl.Position=UDim2.new(1,-62,1,-14) rl.BackgroundTransparency=1
    rl.Text="R:" rl.TextColor3=Color3.fromRGB(160,150,190) rl.Font=Enum.Font.GothamBold rl.TextSize=9 rl.ZIndex=3
    RadiusInput=Instance.new("TextBox",PBC)
    RadiusInput.Size=UDim2.new(0,36,0,12) RadiusInput.Position=UDim2.new(1,-40,1,-14)
    RadiusInput.BackgroundTransparency=1 RadiusInput.Text=tostring(STEAL_RADIUS)
    RadiusInput.TextColor3=ACCENT RadiusInput.Font=Enum.Font.GothamBold RadiusInput.TextSize=9
    RadiusInput.ZIndex=3 RadiusInput.BorderSizePixel=0 RadiusInput.ClearTextOnFocus=false
    RadiusInput.FocusLost:Connect(function()
        local n=tonumber(RadiusInput.Text)
        if n then
            STEAL_RADIUS=math.clamp(math.floor(n),5,200)
            RadiusInput.Text=tostring(STEAL_RADIUS)
            if StealRadiusBox then StealRadiusBox.Text=tostring(STEAL_RADIUS) end
            task.defer(saveConfig)
        else RadiusInput.Text=tostring(STEAL_RADIUS) end
    end)
    -- progress bar track
    local pt=Instance.new("Frame",PBC)
    pt.Size=UDim2.new(0.88,0,0,7) pt.Position=UDim2.new(0.06,0,1,-13)
    pt.BackgroundColor3=Color3.fromRGB(25,22,38) pt.BorderSizePixel=0 pt.ZIndex=2
    Instance.new("UICorner",pt).CornerRadius=UDim.new(1,0)
    ProgressBarFill=Instance.new("Frame",pt)
    ProgressBarFill.Size=UDim2.new(0,0,1,0) ProgressBarFill.BackgroundColor3=Color3.fromRGB(200,30,30)
    ProgressBarFill.BorderSizePixel=0 ProgressBarFill.ZIndex=3
    Instance.new("UICorner",ProgressBarFill).CornerRadius=UDim.new(1,0)
    -- FPS/PING updater
    local fc,lft=0,tick()
    RunService.RenderStepped:Connect(function()
        fc=fc+1 local ct=tick()
        if ct-lft>=1 then FPSBar.Text="FPS "..fc fc=0 lft=ct end
        pcall(function() PingBar.Text="PING "..math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()).."ms" end)
    end)
    -- drag
    local pbDragging,pbDragStart,pbStartPos=false,nil,nil
    PBC.InputBegan:Connect(function(input)
        if stealBarLocked then return end
        if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
            pbDragging=true pbDragStart=input.Position pbStartPos=PBC.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if pbDragging and (input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseMovement) then
            local d=input.Position-pbDragStart
            PBC.Position=UDim2.new(pbStartPos.X.Scale,pbStartPos.X.Offset+d.X,pbStartPos.Y.Scale,pbStartPos.Y.Offset+d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            if pbDragging then
                pbDragging=false
                local p=PBC.Position SavedPBCPos={p.X.Scale,p.X.Offset,p.Y.Scale,p.Y.Offset}
                task.defer(saveConfig)
            end
        end
    end)
end

-- MOBILE BUTTONS: individually draggable
do
    local DRAG_THRESHOLD=10
    local function makeMob(label,initPos,toggleName,onAct)
        local btn=Instance.new("TextButton",ScreenGui)
        btn.Size=UDim2.new(0,58,0,58)
        local posKey=label:gsub("\n","_")
        local saved=mobBtnPositions[posKey]
        btn.Position=saved and UDim2.new(saved[1],saved[2],saved[3],saved[4]) or initPos
        btn.BackgroundColor3=MOB_OFF btn.BackgroundTransparency=0.1
        btn.Text=label btn.TextColor3=WHITE btn.Font=Enum.Font.GothamBold
        btn.TextSize=9 btn.TextWrapped=true btn.BorderSizePixel=0 btn.ZIndex=20
        Instance.new("UICorner",btn).CornerRadius=UDim.new(0,10)
        local s=Instance.new("UIStroke",btn) s.Color=ACCENT s.Thickness=1.5 s.Transparency=0.3
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
    dropMobBtn.Visible=false dropMobBtnRef=dropMobBtn dropMobBtn.Size=UDim2.new(0,90,0,50)
    local autoBatBtn=makeMob("LOCK",UDim2.new(1,-120,0.5,-170+gap),"Lock",function()
        local ns=not(toggleStates["Lock"] and toggleStates["Lock"].state)
        if ns then
            if aplOn then stopAutoPlayLeft() updateToggle("Auto Play Left",false) end
            if aprOn then stopAutoPlayRight() updateToggle("Auto Play Right",false) end
            startBatAimbot()
        else stopBatAimbot() end updateToggle("Lock",ns)
        autoBatBtn.Text=ns and "LOCKED" or "LOCK"
        autoBatBtn.BackgroundColor3=ns and Color3.fromRGB(176,25,50) or MOB_OFF
    end)
    autoBatBtn.Size=UDim2.new(0,90,0,50)

    -- AUTO PLAY panel (title + PLAY button, draggable)
    do
        local APFrame=Instance.new("Frame",ScreenGui)
        APFrame.Size=UDim2.new(0,130,0,45)
        local apPosKey="AutoPlay_Panel"
        local apSaved=mobBtnPositions[apPosKey]
        APFrame.Position=apSaved and UDim2.new(apSaved[1],apSaved[2],apSaved[3],apSaved[4]) or UDim2.new(1,-56,0.5,-170)
        APFrame.BackgroundColor3=Color3.fromRGB(12,10,22) APFrame.BackgroundTransparency=0.08 APFrame.BorderSizePixel=0 APFrame.ZIndex=20
        Instance.new("UICorner",APFrame).CornerRadius=UDim.new(0,10)
        local apStroke=Instance.new("UIStroke",APFrame) apStroke.Color=ACCENT apStroke.Thickness=1.2

        -- title bar
        local titleBar=Instance.new("Frame",APFrame)
        titleBar.Size=UDim2.new(1,0,0,16) titleBar.Position=UDim2.new(0,0,0,0)
        titleBar.BackgroundColor3=Color3.fromRGB(20,16,36) titleBar.BorderSizePixel=0 titleBar.ZIndex=21
        local titleCorner=Instance.new("UICorner",titleBar) titleCorner.CornerRadius=UDim.new(0,10)
        local titleFix=Instance.new("Frame",titleBar)
        titleFix.Size=UDim2.new(1,0,0.5,0) titleFix.Position=UDim2.new(0,0,0.5,0)
        titleFix.BackgroundColor3=Color3.fromRGB(20,16,36) titleFix.BorderSizePixel=0 titleFix.ZIndex=21

        local titleLbl=Instance.new("TextLabel",titleBar)
        titleLbl.Size=UDim2.new(1,0,1,0) titleLbl.Position=UDim2.new(0,0,0,0)
        titleLbl.BackgroundTransparency=1 titleLbl.Text="Auto Play"
        titleLbl.TextColor3=ACCENT titleLbl.Font=Enum.Font.GothamBold titleLbl.TextSize=10
        titleLbl.TextXAlignment=Enum.TextXAlignment.Center titleLbl.ZIndex=22

        -- PLAY button
        local playBtn=Instance.new("TextButton",APFrame)
        playBtn.Size=UDim2.new(1,-8,0,22) playBtn.Position=UDim2.new(0,4,0,18)
        playBtn.BackgroundColor3=Color3.fromRGB(30,120,220) playBtn.BorderSizePixel=0 playBtn.ZIndex=21
        playBtn.Text="PLAY" playBtn.TextColor3=Color3.fromRGB(255,255,255)
        playBtn.Font=Enum.Font.GothamBlack playBtn.TextSize=13
        Instance.new("UICorner",playBtn).CornerRadius=UDim.new(0,8)
        AutoPlayButtonRef=playBtn AutoPlayTitleRef=titleLbl

        -- drag logic on the whole frame (declared BEFORE click handler so apDragging is in scope)
        table.insert(mobileButtons,APFrame)
        local apDragging=false local apStart=nil local apVecStart=nil
        APFrame.InputBegan:Connect(function(input)
            if input.UserInputType~=Enum.UserInputType.Touch and input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
            apStart=APFrame.Position apVecStart=input.Position apDragging=false
            local conn conn=input.Changed:Connect(function()
                if input.UserInputState==Enum.UserInputState.Change then
                    local d=input.Position-apVecStart
                    if not mobBtnsLocked and d.Magnitude>10 then
                        apDragging=true
                        APFrame.Position=UDim2.new(apStart.X.Scale,apStart.X.Offset+d.X,apStart.Y.Scale,apStart.Y.Offset+d.Y)
                    end
                elseif input.UserInputState==Enum.UserInputState.End then
                    conn:Disconnect()
                    if apDragging then
                        local p=APFrame.Position mobBtnPositions[apPosKey]={p.X.Scale,p.X.Offset,p.Y.Scale,p.Y.Offset}
                        task.defer(saveConfig)
                    end
                end
            end)
        end)

        playBtn.MouseButton1Click:Connect(function()
            if apDragging then return end
            local playing=aplOn or aprOn or apWaiting
            if playing then
                cancelApWait()
                if aplOn then stopAutoPlayLeft() updateToggle("Auto Play Left",false) end
                if aprOn then stopAutoPlayRight() updateToggle("Auto Play Right",false) end
                setAutoPlayPanelActive(false)
            else
                if batAimbotEnabled then stopBatAimbot() updateToggle("Lock",false) end
                local route=startAutoPlayAwayFromBase()
                updateToggle("Auto Play Left",route=="left")
                updateToggle("Auto Play Right",route=="right")
            end
        end)
    end
    local tpMobBtn=makeMob("TP\nDOWN",UDim2.new(1,-120,0.5,-170+gap*2),nil,function() task.spawn(doTPDown) end)
    tpMobBtn.Visible=false tpMobBtnRef=tpMobBtn tpMobBtn.Size=UDim2.new(0,90,0,50)
    local autoMedBtn=makeMob("AUTO\nMED",UDim2.new(1,-120,0.5,-170+gap*3),nil,function()
        local ns=not autoMedusaEnabled
        autoMedusaEnabled=ns
        if ns then startAutoMedusa() else stopAutoMedusa() end
        updateToggle("Auto Medusa",ns)
    end)
    autoMedBtn.Visible=false autoMedusaMobRef=autoMedBtn autoMedBtn.Size=UDim2.new(0,90,0,50)
end

-- OPEN/CLOSE BUTTON
do
    local OCGui=Instance.new("ScreenGui",player:WaitForChild("PlayerGui"))
    OCGui.Name="EclipseXOpenClose" OCGui.ResetOnSpawn=false OCGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    local OBtn=Instance.new("TextButton",OCGui)
    OBtn.Size=UDim2.new(0,52,0,52) OBtn.Position=UDim2.new(0,10,0.5,-26)
    OBtn.BackgroundColor3=Color3.fromRGB(176,25,50) OBtn.Text="M" OBtn.TextSize=26
    OBtn.Font=Enum.Font.GothamBlack OBtn.TextColor3=Color3.fromRGB(150,150,150) OBtn.BorderSizePixel=0 OBtn.Active=true
    Instance.new("UICorner",OBtn).CornerRadius=UDim.new(0,14)
    local OS=Instance.new("UIStroke",OBtn) OS.Thickness=2 OS.Color=ACCENT OS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    task.spawn(function()
        while OBtn and OBtn.Parent do
            for i=0,20 do OS.Thickness=2+i*0.05 task.wait(0.04) end
            for i=0,20 do OS.Thickness=3-i*0.05 task.wait(0.04) end
        end
    end)
    task.spawn(function()
        local RED=Color3.fromRGB(176,25,50)
        local GREY=Color3.fromRGB(120,120,120)
        while OBtn and OBtn.Parent do
            TweenService:Create(OBtn,TweenInfo.new(0.7,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{BackgroundColor3=GREY}):Play()
            task.wait(0.72)
            TweenService:Create(OBtn,TweenInfo.new(0.7,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{BackgroundColor3=RED}):Play()
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
        TweenService:Create(OS,TweenInfo.new(0.15),{Color=MainFrame.Visible and WHITE or ACCENT}):Play()
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
            if aplOn then stopAutoPlayLeft() updateToggle("Auto Play Left",false) end
            if aprOn then stopAutoPlayRight() updateToggle("Auto Play Right",false) end
            startBatAimbot()
        else stopBatAimbot() end updateToggle("Lock",ns)
    elseif Keybinds.AntiRagdoll and input.KeyCode==Keybinds.AntiRagdoll then
        local ns=not(toggleStates["Anti Ragdoll"] and toggleStates["Anti Ragdoll"].state)
        antiRagdollEnabled=ns if ns then startAntiRagdoll() else stopAntiRagdoll() end updateToggle("Anti Ragdoll",ns)
    elseif Keybinds.Unwalk and input.KeyCode==Keybinds.Unwalk then
        local ns=not(toggleStates["Unwalk"] and toggleStates["Unwalk"].state)
        unwalkEnabled=ns if ns then startUnwalk() else stopUnwalk() end updateToggle("Unwalk",ns)
    elseif Keybinds.Drop and input.KeyCode==Keybinds.Drop then task.spawn(doDrop)
    elseif Keybinds.Taunt and input.KeyCode==Keybinds.Taunt then
        if not tauntActive then startTaunt() else stopTaunt() end
    elseif Keybinds.TPDown and input.KeyCode==Keybinds.TPDown then
        task.spawn(doTPDown)
    end
end)

if espEnabled then enableESP() end
applyFOV()
print("EclipseX Duels loaded")
