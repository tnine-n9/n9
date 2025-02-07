local Main = {
    tpwalkslow = 0,
    tpwalkmobile = 0,
    tpwalkquick = 0,
    tpwalkslowenable = false,
    tpwalkmobileenable = false,
    tpwalkquickenable = false,
    spinspeed = 0,
    HitboxStatue = false,
    HitboxSize = 0,
    HitboxTransparency = 1,
    HitboxBrickColor = "Really red"
}

local ui = loadstring(game:HttpGet("https://raw.githubusercontent.com/LENG8123/UI/refs/heads/main/ohio%20library.txt"))()         
local win = ui:new("tnine脚本")
--
local UITab1 = win:Tab("『信息』",'16060333448')

local about = UITab1:section("『作者信息』",N9)

about:Label("tnine")
about:Label("作者QQ：3562501187")
about:Label("作者：N9")
about:Label("脚本测试中")
about:Label("欢迎使用")
--
local UITab355 = win:Tab("『人物』",'16060333448')

local about = UITab355:section("『LENG script』",true)
    
about:Textbox("快速跑步", "tpwalking", "输入", function(king)
local tspeed = king
local hb = game:GetService("RunService").Heartbeat
local tpwalking = true
local player = game:GetService("Players")
local lplr = player.LocalPlayer
local chr = lplr.Character
local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
while tpwalking and hb:Wait() and chr and hum and hum.Parent do
  if hum.MoveDirection.Magnitude > 0 then
    if tspeed then
      chr:TranslateBy(hum.MoveDirection * tonumber(tspeed))
    else
      chr:TranslateBy(hum.MoveDirection)
    end
  end
end
end)

local bin = {
    fovsize = 20,
    fovlookAt = false,
    fovcolor = Color3.fromRGB(255, 255, 255),
    fovthickness = 3,
    Visible = false,
    distance = 100,
    ViewportSize = 3,
    Transparency = 0.8,
    Position = "Head",
    teamCheck = false,
    wallCheck = false,
    aliveCheck = false,
    prejudgingselfsighting = false,
    prejudgingselfsightingdistance = 0
}

local colorMap = {
    ["红色"] = Color3.fromRGB(255, 0, 0),
    ["蓝色"] = Color3.fromRGB(0, 0, 255),
    ["黄色"] = Color3.fromRGB(255, 255, 0),
    ["绿色"] = Color3.fromRGB(0, 255, 0),
    ["青色"] = Color3.fromRGB(0, 255, 255),
    ["橙色"] = Color3.fromRGB(255, 165, 0),
    ["紫色"] = Color3.fromRGB(128, 0, 128),
    ["白色"] = Color3.fromRGB(255, 255, 255),
    ["黑色"] = Color3.fromRGB(0, 0, 0)
}

local function isSameTeam(player)
    return player.Team ~= LocalPlayer.Team
end

local function isLookingAtWall(player, trg_part)
    if not wallCheck then
        return true
    end

    local localPlayerCharacter = Players.LocalPlayer.Character
    if not localPlayerCharacter then
        return false
    end

    local part = player.Character and player.Character:FindFirstChild(trg_part)
    if not part then
        return false
    end

    local ray = Ray.new(Cam.CFrame.Position, part.Position - Cam.CFrame.Position)
    local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, {localPlayerCharacter})

    return hit and hit:IsDescendantOf(player.Character)
end

local function createFOV(fov, color, thickness, transparency)
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local Cam = game.Workspace.CurrentCamera

    if FOVring then
        FOVring:Remove()
    end

    FOVring = Drawing.new("Circle")
    FOVring.Visible = true
    FOVring.Thickness = thickness
    FOVring.Color = color
    FOVring.Filled = false
    FOVring.Radius = fov
    FOVring.Position = Cam.ViewportSize / 2
    FOVring.Transparency = transparency
    local function updateDrawings()
        local camViewportSize = Cam.ViewportSize
        FOVring.Position = camViewportSize / 2
    end

    local function updatePlayerPositions(player)
        if player == game.Players.LocalPlayer then return end
        local character = player.Character
        if character then
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local position = humanoidRootPart.Position
                if not playerPositions[player] then
                    playerPositions[player] = {}
                end
                while #playerPositions[player] > bin.prejudgingselfsightingdistance do
                    table.remove(playerPositions[player], 1)
                end
                table.insert(playerPositions[player], position)
            end
        end
    end
    
    local function onKeyDown(input)
        if input.KeyCode == Enum.KeyCode.Delete then
            RunService:UnbindFromRenderStep("FOVUpdate")
            FOVring:Remove()
        end
    end

    UserInputService.InputBegan:Connect(onKeyDown)

    local function lookAt(target)
        local lookVector = (target - Cam.CFrame.Position).unit
        local newCFrame = CFrame.new(Cam.CFrame.Position, Cam.CFrame.Position + lookVector)
        Cam.CFrame = newCFrame
    end

    local function isPlayerAlive(player)
        return player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0
    end

local function getClosestPlayerInFOV(trg_part)
    local nearest = nil
    local last = math.huge
    local playerMousePos = Cam.ViewportSize / 2
    local maxDistance = bin.distance
    for _, player in ipairs(Players:GetPlayers()) do
        if (not bin.aliveCheck or isPlayerAlive(player)) and player ~= Players.LocalPlayer then
            local part = player.Character and player.Character:FindFirstChild(trg_part)
            if part then
                local ePos, isVisible = Cam:WorldToViewportPoint(part.Position)
                if ePos and isVisible then
                    local distance = (Vector2.new(ePos.x, ePos.y) - playerMousePos).Magnitude
                    if distance < last and distance <= bin.fovsize and distance <= maxDistance then
                        if not bin.teamCheck or (bin.teamCheck and isSameTeam(player)) then
                            if not bin.wallCheck or (bin.wallCheck and isLookingAtWall(player, maxDistance)) then
                                last = distance
                                nearest = player
                            end
                        end
                    end
                end
            end
        end
    end
    return nearest
end
    RunService.RenderStepped:Connect(function()
        updateDrawings()
        if bin.fovlookAt then
            local closest = getClosestPlayerInFOV(bin.Position)
            if closest and closest.Character:FindFirstChild(bin.Position) then
                local targetPosition = closest.Character[bin.Position].Position
                if not bin.teamCheck or not isSameTeam(closest) then
                    if not bin.wallCheck or not isLookingAtWall(closest, bin.distance) then
                        lookAt(targetPosition)
                    end
                end
            end
        end
    end)
end

local function destroyFOV()
    if FOVring then
        local RunService = game:GetService("RunService")
        RunService:UnbindFromRenderStep("FOVUpdate")
        FOVring:Remove()
        FOVring = nil
    end
end

local function updateFOV()
    if FOVring then
        FOVring.Thickness = bin.fovthickness
        FOVring.Radius = bin.fovsize
        FOVring.Color = bin.fovcolor
        FOVring.Transparency = bin.Transparency / 10
    end
end

local about = UITab355:section("『自瞄』",true)

about:Label("无")
about:Label("无")
about:Toggle("显示FOV", "open/close", false, function(state)
    if state then
        createFOV(bin.fovsize, bin.fovcolor, bin.fovthickness, bin.Transparency)
    else
        destroyFOV()
    end
end)
about:Toggle("启动/禁用自瞄", "open/close", false, function(state)
    bin.fovlookAt = state
end)
about:Slider("FOV厚度", "thickness", 3, 2, 10, false, function(value)
    bin.fovthickness = value
    updateFOV()
end)
about:Slider("FOV大小", "Size", 20, 30, 100, false, function(value)
    bin.fovsize = value
    updateFOV()
end)
about:Slider("FOV透明度", "Transparency", 1, 0.8, 10, false, function(value)
    bin.Transparency = value
    updateFOV()
end)
about:Slider("FOV距离", "distance", 40, 10, 500, false, function(value)
    bin.distance = value
end)
about:Dropdown('FOV颜色', 'Dropdown', {"红色","蓝色","黄色","绿色","青色","橙色","紫色","白色","黑色"}, function(value)
    bin.fovcolor = colorMap[value]
    updateFOV()
end)
about:Dropdown('选择部位', 'Dropdown', {"Head", "HumanoidRootPart", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "LeftHand", "RightHand", "LeftLowerArm", "RightLowerArm", "LeftUpperArm", "RightUpperArm", "LeftFoot", "LeftLowerLeg", "UpperTorso", "LeftUpperLeg", "RightFoot", "RightLowerLeg", "LowerTorso", "RightUpperLeg"}, function(Value)
    bin.Position = Value
    updateFOV()
end)
about:Toggle("队伍检测", "Enable/Disable Team Check", false, function(state)
    bin.teamCheck = state
end)
about:Toggle("活体检测","Alive Check",false,function(state)
    bin.aliveCheck = state
end)
about:Toggle("墙壁检测", "Enable/Disable Wall Check", false, function(state)
    bin.wallCheck = state
end)
about:Toggle("预判自瞄", "prejudging self-sighting", false, function(state)
    bin.prejudgingselfsighting = state
end)
about:Slider("预判距离", "distance", 40, 10, 500, false, function(value)
    bin.prejudgingselfsightingdistance = value
end)
about:Toggle("开启Kill Aura(需要拿起武器)", "Toggle", false, function(state)
    if state then
        local connections = getgenv().configs and getgenv().configs.connections
        if connections then
            local Disable = getgenv().configs.Disable
            for _, v in pairs(connections) do
                v:Disconnect()
            end
            Disable:Fire()
            Disable:Destroy()
            table.clear(getgenv().configs)
        end

        local Disable = Instance.new("BindableEvent")
        getgenv().configs = {
            connections = {},
            Disable = Disable,
            Size = Vector3.new(10, 10, 10),
            DeathCheck = true
        }

        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local lp = Players.LocalPlayer
        local Run = true
        local Ignorelist = OverlapParams.new()
        Ignorelist.FilterType = Enum.RaycastFilterType.Include

        local function getchar(plr)
            plr = plr or lp
            return plr.Character
        end

        local function gethumanoid(plr)
            local char = plr:IsA("Model") and plr or getchar(plr)
            if char then
                return char:FindFirstChildWhichIsA("Humanoid")
            end
        end

        local function IsAlive(Humanoid)
            return Humanoid and Humanoid.Health > 0
        end

        local function GetTouchInterest(Tool)
            return Tool and Tool:FindFirstChildWhichIsA("TouchTransmitter", true)
        end

        local function GetCharacters(LocalPlayerChar)
            local Characters = {}
            for _, v in pairs(Players:GetPlayers()) do
                table.insert(Characters, getchar(v))
            end
            for i, char in pairs(Characters) do
                if char == LocalPlayerChar then
                    table.remove(Characters, i)
                    break
                end
            end
            return Characters
        end

        local function Attack(Tool, TouchPart, ToTouch)
            if Tool:IsDescendantOf(workspace) then
                Tool:Activate()
                firetouchinterest(TouchPart, ToTouch, 1)
                firetouchinterest(TouchPart, ToTouch, 0)
            end
        end

        table.insert(getgenv().configs.connections, Disable.Event:Connect(function()
            Run = false
        end))

        while Run do
            local char = getchar()
            if IsAlive(gethumanoid(char)) then
                local Tool = char and char:FindFirstChildWhichIsA("Tool")
                local TouchInterest = Tool and GetTouchInterest(Tool)

                if TouchInterest then
                    local TouchPart = TouchInterest.Parent
                    local Characters = GetCharacters(char)
                    Ignorelist.FilterDescendantsInstances = Characters
                    local InstancesInBox = workspace:GetPartBoundsInBox(TouchPart.CFrame, TouchPart.Size + getgenv().configs.Size, Ignorelist)

                    for _, v in pairs(InstancesInBox) do
                        local Character = v:FindFirstAncestorWhichIsA("Model")
                        if table.find(Characters, Character) then
                            if getgenv().configs.DeathCheck and IsAlive(gethumanoid(Character)) then
                                Attack(Tool, TouchPart, v)
                            elseif not getgenv().configs.DeathCheck then
                                Attack(Tool, TouchPart, v)
                            end
                        end
                    end
                end
            end
            RunService.Heartbeat:Wait()
        end
    else
        local Disable = getgenv().configs.Disable
        if Disable then
            Disable:Fire()
            Disable:Destroy()
        end

        for _, connection in pairs(getgenv().configs.connections) do
            connection:Disconnect()
        end
        table.clear(getgenv().configs.connections)
        Run = false
    end
end)

local about = UITab355:section("人机功能",true)

about:Toggle("残血自动走","Toggle",false,function(Value)
paolu1 = Value
        if paolu1 then
            paolu2()
        end
end)
paolu2 = function()
    while paolu1 do
    wait(0.1)
    if game:GetService('Players').LocalPlayer.Character.Humanoid.Health <= 35 then
        local og1 = CFrame.new(175.191, 13.937, -132.69)
        local og3 = game:GetService('Players').LocalPlayer.Character.HumanoidRootPart
        og3.CFrame = og1
        wait(20)
    end
    end
end

about:Toggle("一拳", "", false, function(state)
        spawn(function(...)
            while task.wait() do
                if not state then
                    break
                end
                for i, v in pairs(game:GetService("Players"):GetPlayers()) do
                    if v ~= game:GetService('Players').LocalPlayer and v.Character and
                        v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") then
                        pcall(function()
                            if game:GetService('Players').LocalPlayer:DistanceFromCharacter(v.Character.HumanoidRootPart
                                                                                                .Position) < 100 then -- 距离这个数字
                                local Hit = {
                                    ["meleeType"] = "meleemegapunch",
                                    ["hitPlayerId"] = v.UserId
                                }
                                Remotes["meleeItemHit"]:FireServer("player", Hit)
                            end
                        end)

                    end
                end
            end
        end)

    end)
    
about:Button("一拳", function()
getgenv().lishichuan="1001390385" loadstring(game:HttpGet("https://pastebin.com/raw/iZuasZCc"))()
end)

about:Toggle("互动", "Auto Interact", false, function(state)
        if state then
            autoInteract = true
            while autoInteract do
                for _, descendant in pairs(workspace:GetDescendants()) do
                    if descendant:IsA("ProximityPrompt") then
                        fireproximityprompt(descendant)
                    end
                end
                task.wait(0.25) -- Adjust the wait time as needed
            end
        else
            autoInteract = false
        end
    end)
local UITab66 = win:Tab("『perspective』",'16060333448')

local about = UITab66:section("『LENG script』",true)

about:Button("显示所有人聊天框", function()
ChatSee()
end)
ChatSee = function()
    game:GetService('Players').LocalPlayer.PlayerGui.Chat.Frame.ChatChannelParentFrame.Visible = true
    game:GetService('Players').LocalPlayer.PlayerGui.Chat.Frame.ChatChannelParentFrame.Position = UDim2.new(0, 0, 0, 40)
end

about:Slider('Fov【正常为70】', 'Sliderflag', 70, 0.1, 250, false, function(v)
game.Workspace.CurrentCamera.FieldOfView = v
end)

about:Button("物品透视(没啥用)",function()  
        while true do
            for i,l in pairs(game:GetService('Workspace').Game.Entities.ItemPickup:GetChildren()) do
                for i,v in pairs(l:GetChildren()) do
                    if v.ClassName == 'MeshPart' or 'Part' then
                        for i,e in pairs(v:GetChildren()) do
                            if e.ClassName == 'ProximityPrompt' then
                                if e.ObjectText == 'Military Armory Keycard' or e.ObjectText == 'Sawn Off' or e.ObjectText == 'Scar L' or e.ObjectText == 'Military Vest' or e.ObjectText == 'Raygun' or e.ObjectText == 'UPS 45' or e.ObjectText == 'Medium Vest' or e.ObjectText == 'Deagle' or e.ObjectText == 'Glock 18' or e.ObjectText == 'Heavy Vest' or e.ObjectText == 'Diamond Ring' or e.ObjectText == 'AS Val' or e.ObjectText == 'Money Printer' or e.ObjectText == 'Aug' or e.ObjectText == 'M4A1' or e.ObjectText == 'C4' or e.ObjectText == 'Stagecoach' or e.ObjectText == 'Diamond' or e.ObjectText == 'Void Gem' or e.ObjectText == 'Dark Matter Gem' or e.ObjectText == 'Gold AK-47' or e.ObjectText == 'Barrett M107' or e.ObjectText == 'Gold Deagle' or e.ObjectText == 'Double Barrel' or e.ObjectText == 'Dragunov' or e.ObjectText == 'RPK'  or e.ObjectText == 'M249 SAW' or e.ObjectText == 'Flamethrower' or e.ObjectText == 'Police Armory Keycard' or e.ObjectText == 'RPG' or e.ObjectText == 'Saiga 12' or e.ObjectText == 'Ammo Box' then
                                    xd = Instance.new('BillboardGui')
                                    xd.Parent = v
                                    xd.AlwaysOnTop = true
                                    xd.Size = UDim2.new(0, 100, 0, 25)
                                    Frame = Instance.new('Frame')
                                    Frame.Parent = xd
                                    Frame.BackgroundColor3 = Color3.new(1, 1, 1)
                                    Frame.Size = UDim2.new(1, 0, 1, 0)
                                    Frame.BackgroundTransparency = 1
                                    text = Instance.new('TextLabel')
                                    text.TextScaled = true
                                    text.BackgroundColor3 = Color3.new(255, 0, 0)
                                    text.Parent = Frame
                                    text.Text = e.ObjectText
                                    text.Size = UDim2.new(1, 0, 1, 0)
                                    text.BackgroundTransparency = 1
                                    text.TextColor3 = Color3.new(1, 1, 1)
                                else

                                end
                            end
        
                        end
        
                    end
        
        
                end
            end
            wait()
            for i,v in pairs (game:GetService('Workspace').Game.Entities.ItemPickup:GetChildren()) do
                for i,k in pairs(v:GetChildren()) do
                    for i,l in pairs(k:GetChildren()) do
                        if l.ClassName == 'BillboardGui' then
                            l:Remove()
                        end
                    end
                end
            end
        
        end
end)
about:Button("零件", function()
        while true do
            for i,l in pairs(game:GetService('Workspace').Game.Entities.ItemPickup:GetChildren()) do
                for i,v in pairs(l:GetChildren()) do
                    if v.ClassName == 'MeshPart' or 'Part' then
                        for i,e in pairs(v:GetChildren()) do
                            if e.ClassName == 'ProximityPrompt' then
                                if e.ObjectText == 'Medical Supplies' or e.ObjectText == 'Weapon components' or e.ObjectText == 'Explosives' or e.ObjectText == 'Weapon Parts' or e.ObjectText == 'Scrap' then
                                    xd = Instance.new('BillboardGui')
                                    xd.Parent = v
                                    xd.AlwaysOnTop = true
                                    xd.Size = UDim2.new(0, 100, 0, 25)
                                    Frame = Instance.new('Frame')
                                    Frame.Parent = xd
                                    Frame.BackgroundColor3 = Color3.new(1, 1, 1)
                                    Frame.Size = UDim2.new(1, 0, 1, 0)
                                    Frame.BackgroundTransparency = 1
                                    text = Instance.new('TextLabel')
                                    text.TextScaled = true
                                    text.BackgroundColor3 = Color3.new(255, 0, 0)
                                    text.Parent = Frame
                                    text.Text = e.ObjectText
                                    text.Size = UDim2.new(1, 0, 1, 0)
                                    text.BackgroundTransparency = 1
                                    text.TextColor3 = Color3.new(1, 1, 1)
                                else

                                end
                            end
        
                        end
        
                    end
        
        
                end
            end
            wait()
            for i,v in pairs (game:GetService('Workspace').Game.Entities.ItemPickup:GetChildren()) do
                for i,k in pairs(v:GetChildren()) do
                    for i,l in pairs(k:GetChildren()) do
                        if l.ClassName == 'BillboardGui' then
                            l:Remove()
                        end
                    end
                end
            end
        
        end
end)

about:Toggle("Circle ESP", "ESP", false, function(state)
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer then
                if state then
                    local highlight = Instance.new("Highlight")
                    highlight.Parent = player.Character
                    highlight.Adornee = player.Character

                    local billboard = Instance.new("BillboardGui")
                    billboard.Parent = player.Character
                    billboard.Adornee = player.Character
                    billboard.Size = UDim2.new(0, 100, 0, 100)
                    billboard.StudsOffset = Vector3.new(0, 3, 0)
                    billboard.AlwaysOnTop = true

                    local nameLabel = Instance.new("TextLabel")
                    nameLabel.Parent = billboard
                    nameLabel.Size = UDim2.new(1, 0, 1, 0)
                    nameLabel.BackgroundTransparency = 1
                    nameLabel.Text = player.Name
                    nameLabel.TextColor3 = Color3.new(1, 1, 1)
                    nameLabel.TextStrokeTransparency = 0.5
                    nameLabel.TextScaled = true

                    local circle = Instance.new("ImageLabel")
                    circle.Parent = billboard
                    circle.Size = UDim2.new(0, 50, 0, 50)
                    circle.Position = UDim2.new(0.5, 0, 0.5, 0) -- Center the circle
                    circle.AnchorPoint = Vector2.new(0.5, 0.5) -- Set the anchor point to the center
                    circle.BackgroundTransparency = 1
                    circle.Image = "rbxassetid://2200552246" -- Replace with your circle image asset ID
                else
                    if player.Character:FindFirstChildOfClass("Highlight") then
                        player.Character:FindFirstChildOfClass("Highlight"):Destroy()
                    end
                    if player.Character:FindFirstChildOfClass("BillboardGui") then
                        player.Character:FindFirstChildOfClass("BillboardGui"):Destroy()
                    end
                end
            end
        end
    end)

about:Button("人物ESP",function()  
    _G.FriendColor = Color3.fromRGB(0, 0, 255)
        local function ApplyESP(v)
       if v.Character and v.Character:FindFirstChildOfClass'Humanoid' then
           v.Character.Humanoid.NameDisplayDistance = 9e9
           v.Character.Humanoid.NameOcclusion = "NoOcclusion"
           v.Character.Humanoid.HealthDisplayDistance = 9e9
           v.Character.Humanoid.HealthDisplayType = "AlwaysOn"
           v.Character.Humanoid.Health = v.Character.Humanoid.Health -- triggers changed
       end
    end
    for i,v in pairs(game.Players:GetPlayers()) do
       ApplyESP(v)
       v.CharacterAdded:Connect(function()
           task.wait(0.33)
           ApplyESP(v)
       end)
    end
    
    game.Players.PlayerAdded:Connect(function(v)
       ApplyESP(v)
       v.CharacterAdded:Connect(function()
           task.wait(0.33)
           ApplyESP(v)
       end)
    end)
    
        local Players = game:GetService("Players"):GetChildren()
    local RunService = game:GetService("RunService")
    local highlight = Instance.new("Highlight")
    highlight.Name = "Highlight"
    
    for i, v in pairs(Players) do
        repeat wait() until v.Character
        if not v.Character:FindFirstChild("HumanoidRootPart"):FindFirstChild("Highlight") then
            local highlightClone = highlight:Clone()
            highlightClone.Adornee = v.Character
            highlightClone.Parent = v.Character:FindFirstChild("HumanoidRootPart")
            highlightClone.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlightClone.Name = "Highlight"
        end
    end
    
    game.Players.PlayerAdded:Connect(function(player)
        repeat wait() until player.Character
        if not player.Character:FindFirstChild("HumanoidRootPart"):FindFirstChild("Highlight") then
            local highlightClone = highlight:Clone()
            highlightClone.Adornee = player.Character
            highlightClone.Parent = player.Character:FindFirstChild("HumanoidRootPart")
            highlightClone.Name = "Highlight"
        end
    end)
    
    game.Players.PlayerRemoving:Connect(function(playerRemoved)
        playerRemoved.Character:FindFirstChild("HumanoidRootPart").Highlight:Destroy()
    end)
    
    RunService.Heartbeat:Connect(function()
        for i, v in pairs(Players) do
            repeat wait() until v.Character
            if not v.Character:FindFirstChild("HumanoidRootPart"):FindFirstChild("Highlight") then
                local highlightClone = highlight:Clone()
                highlightClone.Adornee = v.Character
                highlightClone.Parent = v.Character:FindFirstChild("HumanoidRootPart")
                highlightClone.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlightClone.Name = "Highlight"
                task.wait()
            end
    end
    end)
    end)
about:Toggle("夜视","Toggle",false,function(Value)
if Value then

		    game.Lighting.Ambient = Color3.new(1, 1, 1)

		else

		    game.Lighting.Ambient = Color3.new(0, 0, 0)

		end
end)

local UITab3565 = win:Tab("『通知』",'16060333448')

local about = UITab3565:section("『LENG script』",true)

about:Toggle("通知银行刷新","Toggle",false,function(Value)
Bank1 = Value
        if Bank1 then
            Bank2()
        end
end)
Bank2 = function()
    while Bank1 do
    wait(0.1)
    local Bank = game:GetService('Workspace').BankRobbery.BankCash.Cash:FindFirstChild('Bundle')
        if Bank then
game:GetService("StarterGui"):SetCore("SendNotification",{ Title = "『tnine』"; Text ="银行已刷新"; Duration = 5; })
            wait(30)
        end
    end
end

about:Toggle("通知珠宝店刷新","Toggle",false,function(Value)
Gem1 = Value
        if Gem1 then
            Gem2()
        end
end)
Gem2 = function()
    while Gem1 do
    wait(0.1)
    local Ge = game:GetService('Workspace').GemRobbery:FindFirstChild('Rubble')
        if Ge then
game:GetService("StarterGui"):SetCore("SendNotification",{ Title = "『tnine』"; Text ="珠宝店已刷新"; Duration = 5; })
            wait(30)
        end
    end
end

local UITab9955 = win:Tab("『自动』",'16060333448')

local about = UITab9955:section("『LENG script』",true)

about:Toggle("自动抢劫银行","Toggle",false,function(Value)
AutoBank1 = Value
        if AutoBank1 then
            AutoBank2()
        end
end)
AutoBank2 = function()
    while AutoBank1 do
        wait()
        local BankDoor = game:GetService("Workspace").BankRobbery.VaultDoor
        local BankCashs = game:GetService("Workspace").BankRobbery.BankCash
        local epoh2 = game:GetService('Players')
        local epoh3 = epoh2.LocalPlayer.Character.HumanoidRootPart
        if BankDoor.Door.Attachment.ProximityPrompt.Enabled == true then
            BankDoor.Door.Attachment.ProximityPrompt.HoldDuration = 0
            BankDoor.Door.Attachment.ProximityPrompt.MaxActivationDistance = 16
            local epoh1 = CFrame.new(1071.955810546875, 9, -343.80816650390625)
            epoh3.CFrame = epoh1
           wait(1)
            BankDoor.Door.Attachment.ProximityPrompt:InputHoldBegin()
            BankDoor.Door.Attachment.ProximityPrompt:InputHoldEnd()
            BankDoor.Door.Attachment.ProximityPrompt.Enabled = false
        end
        if BankCashs.Cash.Bundle then
            local epoh1 = CFrame.new(1055.872802734375, 10, -344.6944580078125)
            epoh3.CFrame = epoh1
            BankCashs.Main.Attachment.ProximityPrompt.MaxActivationDistance = 16
            if BankCashs.Cash.Bundle then
            BankCashs.Main.Attachment.ProximityPrompt:InputHoldBegin()
            wait(45)
            BankCashs.Main.Attachment.ProximityPrompt:InputHoldEnd()
            local epoh1 = CFrame.new(240.52850341796875, -120, -620)
            epoh3.CFrame = epoh1
            end
        end   
        if not BankCashs.Cash.Bundle then
            local epoh1 = CFrame.new(240.52850341796875, -120, -620)
            epoh3.CFrame = epoh1
        end
    end
end
about:Toggle("自动开启金保险","Toggle",false,function(Value)
AutoSafe1 = Value
        if AutoSafe1 then
            AutoSafe2()
        end
end)
AutoSafe2 = function()
    while AutoSafe1 do
        wait()
        local BankDoor = game:GetService("Workspace").BankRobbery.VaultDoor
        local epoh2 = game:GetService('Players')
        local epoh3 = epoh2.LocalPlayer.Character.HumanoidRootPart
        if BankDoor.Door.Attachment.ProximityPrompt.Enabled == true then
            BankDoor.Door.Attachment.ProximityPrompt.HoldDuration = 0
            BankDoor.Door.Attachment.ProximityPrompt.MaxActivationDistance = 16
            local epoh1 = CFrame.new(1071.955810546875, 9, -343.80816650390625)
            epoh3.CFrame = epoh1
            wait(1)
            BankDoor.Door.Attachment.ProximityPrompt:InputHoldBegin()
            BankDoor.Door.Attachment.ProximityPrompt:InputHoldEnd()
            BankDoor.Door.Attachment.ProximityPrompt.Enabled = false
        end
        local GoldJewelSafes = game:GetService("Workspace").Game.Entities.GoldJewelSafe
        local foundModel = false
        for _, model in pairs(GoldJewelSafes:GetChildren()) do
            if model.ClassName == 'Model' then
                foundModel = true
                local epoh1 = model.WorldPivot
                epoh3.CFrame = epoh1
                wait(1)
                model.Door["Meshes/LargeSafe_Cube.002_Cube.003_None (1)"].Attachment.ProximityPrompt.HoldDuration = 0
                model.Door["Meshes/LargeSafe_Cube.002_Cube.003_None (1)"].Attachment.ProximityPrompt.MaxActivationDistance = 16
                if model.Door["Meshes/LargeSafe_Cube.002_Cube.003_None (1)"].Attachment.ProximityPrompt.Enabled == true then
                    model.Door["Meshes/LargeSafe_Cube.002_Cube.003_None (1)"].Attachment.ProximityPrompt:InputHoldBegin()
                    model.Door["Meshes/LargeSafe_Cube.002_Cube.003_None (1)"].Attachment.ProximityPrompt:InputHoldEnd()
                    wait(5)
                    model:Destroy()
                    break
                end
            end
        end
        if not foundModel then
game:GetService("StarterGui"):SetCore("SendNotification",{ Title = "『冷』"; Text ="金保险未刷新"; Duration = 5; })
            wait(30)
        end
    end
end

about:Toggle("自动开启黑保险","Toggle",false,function(Value)
AutoSafe3 = Value
        if AutoSafe3 then
            AutoSafe4()
        end
end)
AutoSafe4 = function()
    while AutoSafe3 do
        wait()
        local BankDoor = game:GetService("Workspace").BankRobbery.VaultDoor
        local epoh2 = game:GetService('Players')
        local epoh3 = epoh2.LocalPlayer.Character.HumanoidRootPart
        if BankDoor.Door.Attachment.ProximityPrompt.Enabled == true then
            BankDoor.Door.Attachment.ProximityPrompt.HoldDuration = 0
            BankDoor.Door.Attachment.ProximityPrompt.MaxActivationDistance = 16
            local epoh1 = CFrame.new(1071.955810546875, 9, -343.80816650390625)
            epoh3.CFrame = epoh1
            wait(1)
            BankDoor.Door.Attachment.ProximityPrompt:InputHoldBegin()
            BankDoor.Door.Attachment.ProximityPrompt:InputHoldEnd()
            BankDoor.Door.Attachment.ProximityPrompt.Enabled = false
        end
        local JewelSafes = game:GetService("Workspace").Game.Entities.JewelSafe
        local foundModel = false
        for _, model in pairs(JewelSafes:GetChildren()) do
            if model.ClassName == 'Model' then
                foundModel = true
                local epoh1 = model.WorldPivot
                epoh3.CFrame = epoh1
                wait(1)
                model.Door["Meshes/LargeSafe_Cube.002_Cube.003_None (1)"].Attachment.ProximityPrompt.HoldDuration = 0
                model.Door["Meshes/LargeSafe_Cube.002_Cube.003_None (1)"].Attachment.ProximityPrompt.MaxActivationDistance = 16
                if model.Door["Meshes/LargeSafe_Cube.002_Cube.003_None (1)"].Attachment.ProximityPrompt.Enabled == true then
                    model.Door["Meshes/LargeSafe_Cube.002_Cube.003_None (1)"].Attachment.ProximityPrompt:InputHoldBegin()
                    model.Door["Meshes/LargeSafe_Cube.002_Cube.003_None (1)"].Attachment.ProximityPrompt:InputHoldEnd()
                    wait(5)
                    model:Destroy()
                end
            end
        end
        if not foundModel then
game:GetService("StarterGui"):SetCore("SendNotification",{ Title = "『tnine』"; Text ="黑保险未刷新"; Duration = 5; })
            wait(30)
        end
    end
end

about:Toggle("自动开启小宝箱","Toggle",false,function(Value)
SmallChest1 = Value
        if SmallChest1 then
            SmallChest2()
        end
end)
SmallChest2 = function()
    while SmallChest1 do
    wait()
    local SmallChes = game:GetService('Workspace').Game.Entities.SmallChest
        local foundModel = false
        for _, model in pairs(SmallChes:GetChildren()) do
            if model.ClassName == 'Model' then
                foundModel = true
                local epoh1 = model.WorldPivot
                local epoh2 = game:GetService('Players')
                local epoh3 = epoh2.LocalPlayer.Character.HumanoidRootPart
                epoh3.CFrame = epoh1
                wait(0.3)
                model.Lock["Meshes/untitled_chest.002_Material.009 (4)"].Attachment.ProximityPrompt:InputHoldBegin()
                model.Lock["Meshes/untitled_chest.002_Material.009 (4)"].Attachment.ProximityPrompt:InputHoldEnd()
                wait(0.3)
                local epoh1 = CFrame.new(240.52850341796875, -120, -620)
                epoh3.CFrame = epoh1
                break
            end
        end
        if not foundModel then
game:GetService("StarterGui"):SetCore("SendNotification",{ Title = "『tnine』"; Text ="小宝箱未刷新"; Duration = 5; })
            wait(30)
        end
    end
end

about:Toggle("自动开启大宝箱","Toggle",false,function(Value)
LargeChest1 = Value
        if LargeChest1 then
            LargeChest2()
        end
end)
LargeChest2 = function()
    while LargeChest1 do
    wait()
    local LargeChes = game:GetService('Workspace').Game.Entities.LargeChest
        local foundModel = false
        for _, model in pairs(LargeChes:GetChildren()) do
            if model.ClassName == 'Model' then
                foundModel = true
                local epoh1 = model.WorldPivot
                local epoh2 = game:GetService('Players')
                local epoh3 = epoh2.LocalPlayer.Character.HumanoidRootPart
                epoh3.CFrame = epoh1
                wait(0.3)
                model.Door["Meshes/LargeSafe1_Cube.002_Cube.003_None (3)"].Attachment.ProximityPrompt:InputHoldBegin()
                model.Door["Meshes/LargeSafe1_Cube.002_Cube.003_None (3)"].Attachment.ProximityPrompt:InputHoldEnd()
                wait(0.3)
                local epoh1 = CFrame.new(240.52850341796875, -120, -620)
                epoh3.CFrame = epoh1
                break
            end
        end
        if not foundModel then
game:GetService("StarterGui"):SetCore("SendNotification",{ Title = "『tnine』"; Text ="大宝箱未刷新"; Duration = 5; })
            wait(30)
        end
    end
end

local UITab4555 = win:Tab("『秒』",'16060333448')

local about = UITab4555:section("『LENG script』",true)

about:Button("瞬移宝藏+秒挖", function()
Debris1 = Value
        if Debris1 then
            Debris2()
        end
end)
Debris2 = function()
    local Debri = game:GetService('Workspace').Game.Local.Debris
    if Debri.TreasureMarker then
    Debri.TreasureMarker.ProximityPrompt.HoldDuration = 0
    Debri.TreasureMarker.ProximityPrompt.MaxActivationDistance = 40
    local epoh1 = Debri.TreasureMarker.CFrame
    local epoh2 = game:GetService('Players')
    local epoh3 = epoh2.LocalPlayer.Character.HumanoidRootPart
    epoh3.CFrame = epoh1
    else
game:GetService("StarterGui"):SetCore("SendNotification",{ Title = "『tnine』"; Text ="暂时未刷新宝藏"; Duration = 5; })
    end
end

about:Toggle("瞬移小保险+秒开","Toggle",false,function(Value)
SmallSafe1 = Value
        if SmallSafe1 then
            SmallSafe2()
        end
end)
SmallSafe2 = function()
    while SmallSafe1 do
    wait(0.1)
    local SmallSaf = game:GetService('Workspace').Game.Entities.SmallSafe
        local foundModel = false
        for _, model in pairs(SmallSaf:GetChildren()) do
            if model.ClassName == 'Model' then
                foundModel = true 
                local epoh1 = model.WorldPivot
                local epoh2 = game:GetService('Players')
                local epoh3 = epoh2.LocalPlayer.Character.HumanoidRootPart
                SmallSaf.SmallSafe.Door['Meshes/Safe1_Cube.002_Cube.003_None (1)'].Attachment.ProximityPrompt.HoldDuration = 0
                epoh3.CFrame = epoh1
                break
            end
        end
        if not foundModel then
game:GetService("StarterGui"):SetCore("SendNotification",{ Title = "『tnine』"; Text ="小保险未刷新"; Duration = 5; })
            wait(35)
        end
    end
end
about:Button("秒拿珠宝店", function()
local rocks = game:GetService('Workspace').GemRobbery.JewelryCases.HighYieldSpawns
    for _, obj in pairs(rocks:GetChildren()) do
        if obj.ClassName == 'Model' then
            for _, innerObj in pairs(obj:GetChildren()) do
                if innerObj.ClassName == 'Model' then
                    if innerObj.Name == 'Case' then
                    elseif innerObj.Name == 'Emerald' then
                        if innerObj:FindFirstChild('Handle') and innerObj.Handle:FindFirstChild('ProximityPrompt') then
                            innerObj.Handle.ProximityPrompt.HoldDuration = 0
                        end
                    elseif innerObj.Name == 'Sapphire' then
                        if innerObj:FindFirstChild('Handle') and innerObj.Handle:FindFirstChild('ProximityPrompt') then
                            innerObj.Handle.ProximityPrompt.HoldDuration = 0
                        end
                    elseif innerObj.Name == 'Amethyst' then
                        if innerObj:FindFirstChild('Handle') and innerObj.Handle:FindFirstChild('ProximityPrompt') then
                            innerObj.Handle.ProximityPrompt.HoldDuration = 0
                        end
                    elseif innerObj.Name == 'Topaz' then
                        if innerObj:FindFirstChild('Handle') and innerObj.Handle:FindFirstChild('ProximityPrompt') then
                            innerObj.Handle.ProximityPrompt.HoldDuration = 0
                        end                     
                    elseif innerObj.Name == 'Diamond' then
                        if innerObj:FindFirstChild('Handle') and innerObj.Handle:FindFirstChild('ProximityPrompt') then
                            innerObj.Handle.ProximityPrompt.HoldDuration = 0
                        end
                    elseif innerObj.Name == 'Gold Bar' then
                        if innerObj:FindFirstChild('Handle') and innerObj.Handle:FindFirstChild('ProximityPrompt') then
                            innerObj.Handle.ProximityPrompt.HoldDuration = 0
                        end
                    elseif innerObj.Name == 'Ruby' then
                        if innerObj:FindFirstChild('Handle') and innerObj.Handle:FindFirstChild('ProximityPrompt') then
                            innerObj.Handle.ProximityPrompt.HoldDuration = 0
                        end
                    else
                        if innerObj:FindFirstChild('Box') and innerObj.Box:FindFirstChild('ProximityPrompt') then
                            innerObj.Box.ProximityPrompt.HoldDuration = 0
                        end
                    end
                end
            end
        end
    end
    local rocks2 = game:GetService('Workspace').GemRobbery.JewelryCases.LowYieldSpawns
    for _, obj in pairs(rocks2:GetChildren()) do
        if obj.ClassName == 'Model' then
            for _, innerObj in pairs(obj:GetChildren()) do
                if innerObj.ClassName == 'Model' then
                    if innerObj.Name == 'Case' then
                    elseif innerObj.Name == 'Emerald' then
                        if innerObj:FindFirstChild('Handle') and innerObj.Handle:FindFirstChild('ProximityPrompt') then
                            innerObj.Handle.ProximityPrompt.HoldDuration = 0
                        end
                    elseif innerObj.Name == 'Sapphire' then
                        if innerObj:FindFirstChild('Handle') and innerObj.Handle:FindFirstChild('ProximityPrompt') then
                            innerObj.Handle.ProximityPrompt.HoldDuration = 0
                        end
                    elseif innerObj.Name == 'Amethyst' then
                        if innerObj:FindFirstChild('Handle') and innerObj.Handle:FindFirstChild('ProximityPrompt') then
                            innerObj.Handle.ProximityPrompt.HoldDuration = 0
                        end
                    elseif innerObj.Name == 'Topaz' then
                        if innerObj:FindFirstChild('Handle') and innerObj.Handle:FindFirstChild('ProximityPrompt') then
                            innerObj.Handle.ProximityPrompt.HoldDuration = 0
                        end
                    elseif innerObj.Name == 'Diamond' then
                        if innerObj:FindFirstChild('Handle') and innerObj.Handle:FindFirstChild('ProximityPrompt') then
                            innerObj.Handle.ProximityPrompt.HoldDuration = 0
                        end
                    elseif innerObj.Name == 'Gold Bar' then
                        if innerObj:FindFirstChild('Handle') and innerObj.Handle:FindFirstChild('ProximityPrompt') then
                            innerObj.Handle.ProximityPrompt.HoldDuration = 0
                        end
                    elseif innerObj.Name == 'Ruby' then
                        if innerObj:FindFirstChild('Handle') and innerObj.Handle:FindFirstChild('ProximityPrompt') then
                            innerObj.Handle.ProximityPrompt.HoldDuration = 0
                        end
                    else
                        if innerObj:FindFirstChild('Box') and innerObj.Box:FindFirstChild('ProximityPrompt') then
                            innerObj.Box.ProximityPrompt.HoldDuration = 0
                        end
                    end
                end
            end
        end
    end
end)

about:Button("秒空投", function()
wait(0.1)
        game:GetService('Workspace').Game.Airdrops.Airdrop.Airdrop.ProximityPrompt.HoldDuration = 0
end)

about:Button("秒开银行", function()
    game:GetService('Workspace').BankRobbery.VaultDoor.Door.Attachment.ProximityPrompt.HoldDuration = 0
    game:GetService('Workspace').BankRobbery.VaultDoor.Door.Attachment.ProximityPrompt.MaxActivationDistance = 16
    game:GetService('Workspasce').BankRobbery.BankCash.Main.Attachment.ProximityPrompt.MaxActivationDistance = 16
end)

about:Button("秒开金保险", function()
while true do
        wait(0.1)
        local safe = game:GetService('Workspace').Game.Entities.GoldJewelSafe.GoldJewelSafe
        safe.Door['Meshes/LargeSafe_Cube.002_Cube.003_None (1)'].Attachment.ProximityPrompt.HoldDuration = 0
        safe.Name = 'safeopen'
    end
end)
about:Button("秒开黑保险", function()
while true do
        wait(0.1)
        local safe2 = game:GetService('Workspace').Game.Entities.JewelSafe.JewelSafe
        safe2.Door['Meshes/LargeSafe_Cube.002_Cube.003_None (1)'].Attachment.ProximityPrompt.HoldDuration = 0
        safe2.Name = 'safeopen' 
    end
end)

about:Button("秒填弹药箱", function()
for i = 1 , 50 do
    local ammobx = game:GetService('Workspace').Game.Local.droppables['Ammo Box']
    ammobx.Handle.ProximityPrompt.HoldDuration = 0
    ammobx.Name = 'ammoopen'
    end
end)

local UITab352565 = win:Tab("『remote』",'16060333448')

local about = UITab352565:section("『LENG script』",true)

about:Toggle("远程黑市","Toggle",false,function(Value)
Dealer1 = Value
        if Dealer1 then
            Dealer2()
        end
end)
Dealer2 = function()
    while Dealer1 do
    wait(0.1)
    game:GetService('Workspace').BlackMarket.Dealer.Dealer.ProximityPrompt.MaxActivationDistance = 100000
    end
    while not Dealer1 do
    wait(0.1)
    game:GetService('Workspace').BlackMarket.Dealer.Dealer.ProximityPrompt.MaxActivationDistance = 16
    end
end

local UITab35665 = win:Tab("『印钞机』",'16060333448')

local about = UITab35665:section("『LENG script』",true)

about:Button("rb制作脚本",function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/rbxluau/Roblox/main/ScriptHub.lua"))()
YOURSCRIPTCRACKBYCHINESE/PUSCRIPTS/refs/heads/main/MONEY-PRINTER-YAY/LOVE-FROM-CN.crack"))()
end)

about:Button("冷印钞机（自动更换服务器）",function()
for a=1,1 do
game:GetService("StarterGui"):SetCore("SendNotification",{ Title = "『刷新中 冷』"; Text ="请等待 冷"; Duration = 2; })
loadstring(game:HttpGet("https://raw.githubusercontent.com/PUSCRIPTS/MONEY-PRINTER-YAY/main/MONEY"))()

Players = game:GetService("Players")
LocalPlayer = Players.LocalPlayer
HRP = "HumanoidRootPart"
for i, v in pairs(workspace.Game.Entities.ItemPickup:GetChildren()) do
    Prompt = v.PrimaryPart:FindFirstChildOfClass("ProximityPrompt")
    if Prompt.ObjectText == "Money Printer" then
        LocalPlayer.Character[HRP].CFrame = v.PrimaryPart.CFrame
        wait(1)
        fireproximityprompt(Prompt)
    end
end
end
if true then
game:GetService("StarterGui"):SetCore("SendNotification",{ Title = "『此服务器没有脚本』"; Text ="已为您跳转服务器"; Duration = 2; })

game:GetService("StarterGui"):SetCore("SendNotification",{ Title = "『已更换服务器』"; Text ="已更换"; Duration = 2; })
end
end)

about:Button("冷印钞机2（不能跳服务器）", function()
for a=1,30 do
game:GetService("StarterGui"):SetCore("SendNotification",{ Title = "『刷新中 冷』"; Text ="请等待 冷"; Duration = 2; })
Players = game:GetService("Players")
LocalPlayer = Players.LocalPlayer
HRP = "HumanoidRootPart"
for i, v in pairs(workspace.Game.Entities.ItemPickup:GetChildren()) do
    Prompt = v.PrimaryPart:FindFirstChildOfClass("ProximityPrompt")
    if Prompt.ObjectText == "Money Printer" then
        LocalPlayer.Character[HRP].CFrame = v.PrimaryPart.CFrame
        wait(1)
        fireproximityprompt(Prompt)
    end
end
end
if true then
game:GetService("StarterGui"):SetCore("SendNotification",{ Title = "『该服务器并没有检测到印钞机』"; Text ="没有"; Duration = 2; })

game:GetService("StarterGui"):SetCore("SendNotification",{ Title = "『请您手动更换服务器』"; Text ="请手动更换"; Duration = 2; })
end
end)

about:Toggle("打开后持续检测印钞机","Toggle",false,function(Value)
MoneyPrint1 = Value
        if MoneyPrint1 then
            MoneyPrint2()
        end
end)
MoneyPrint2 = function()
    while MoneyPrint1 do
    wait(0.1)
    while true do
            for i,l in pairs(game:GetService('Workspace').Game.Entities.ItemPickup:GetChildren()) do
                for i,v in pairs(l:GetChildren()) do
                    if v.ClassName == 'MeshPart' or 'Part' then
                        for i,e in pairs(v:GetChildren()) do
                            if e.ClassName == 'ProximityPrompt' then
                                if e.ObjectText == 'Money Printer' then
                                    local epoh1 = v.CFrame
                                    local epoh2 = game:GetService('Players')
                                    local epoh3 = epoh2.LocalPlayer.Character.HumanoidRootPart
                                    epoh3.CFrame = epoh1
                                else

                                end
                            end
        
                        end
        
                    end
        
        
                end
            end
        
            wait (0.1)
            for i,v in pairs (game:GetService('Workspace').Game.Entities.ItemPickup:GetChildren()) do
                for i,k in pairs(v:GetChildren()) do
                    for i,l in pairs(k:GetChildren()) do
                        if l.ClassName == 'BillboardGui' then
                            l:Remove()
                        end
                    end
                end
            end
        
        end
end
end
local UITab35785 = win:Tab("『传送』",'16060333448')

local about = UITab35785:section("『LENG script』",true)

about:Dropdown("传送位置","Dropdown",{'银行','珠宝店','沙滩','武器店（撬锁）','武士刀','射线枪','加特林','美国短喷','沙漠之鹰','警察局（购买M4）','AUG','军甲'},function(Value)
    local epoh2 = game:GetService('Players')
    local epoh3 = epoh2.LocalPlayer.Character.HumanoidRootPart
    if Value == '银行' then
        local epoh1 = CFrame.new(1055.94153, 15.11950874, -344.58374)
        epoh3.CFrame = epoh1
    elseif Value == '珠宝店' then
        local epoh1 = CFrame.new(1719.02637, 14.2831011, -714.293091)
        epoh3.CFrame = epoh1
    elseif Value == '沙滩' then
        local epoh1 = CFrame.new(998.4656372070312, 15, 395.9789733886719)
        epoh3.CFrame = epoh1
    elseif Value == '武器店（撬锁）' then
        local epoh1 = CFrame.new(660.5284423828125, 6.4081127643585205, -716.489990234375)
        epoh3.CFrame = epoh1
    elseif Value == '武士刀' then
        local epoh1 = CFrame.new(175.191, 13.937, -132.69)
        epoh3.CFrame = epoh1
    elseif Value == '射线枪' then
        local epoh1 = CFrame.new(148.685471, -90, -529.280945)
        epoh3.CFrame = epoh1
    elseif Value == '加特林' then
        local epoh1 = CFrame.new(364.97076416015625, 0.764974117279053, -1447.3302001953125)
        epoh3.CFrame = epoh1
    elseif Value == '美国短喷' then
        local epoh1 = CFrame.new(1179.98523,40,-436.812683)
        epoh3.CFrame = epoh1
    elseif Value == '沙漠之鹰' then
        local epoh1 = CFrame.new(363.341461, 26.0798492, -259.681396)
        epoh3.CFrame = epoh1
    elseif Value == '警察局（M4A1）' then
        local epoh1 = CFrame.new(603.4676513671875,25.662811279296875,-922.0442504882812)
        epoh3.CFrame = epoh1
    elseif Value == 'AUG' then
        local epoh1 = CFrame.new(1170.500244140625,48.37138366699219,-772.55859375)
        epoh3.CFrame = epoh1
    elseif Value == '军甲' then
        local epoh1 = CFrame.new(563.4422607421875,28.502071380615234,-1472.780517578125)
        epoh3.CFrame = epoh1
    end
end)