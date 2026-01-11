--====================================================
-- ZUKAFU HUB v4 | BLOX FRUITS
-- FULL VERSION | OMG HUB STYLE UI + SMART FARM + AUTO RACE V2/V3 + DISCORD LINK
--====================================================

--================ SERVICES & PLAYER SETUP ================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")

local LP = Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()
local Humanoid, HRP = nil, nil

-- Refresh character function
local function RefreshChar()
    Char = LP.Character or LP.CharacterAdded:Wait()
    Humanoid = Char:WaitForChild("Humanoid")
    HRP = Char:WaitForChild("HumanoidRootPart")
end
RefreshChar()

LP.CharacterAdded:Connect(function()
    task.wait(1)
    RefreshChar()
end)

-- Anti-AFK
LP.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

--================ GLOBAL SETTINGS =======================
getgenv().Zukafu = {
    AutoAttack = false,
    FastHit = false,
    MobPull = false,
    SkillSpam = false,
    KillAura = false,
    AutoFarm = false,
    AutoCollect = false,
    AutoLevel = false,
    AutoStats = false,
    AutoBossFarm = false,
    Race = "V2",
    AttackRange = 25,
    HitDelay = 0.15,
    PullDistance = 2
}

--================ HELPER FUNCTIONS =======================
-- Equip best weapon
local function EquipBest()
    local bestTool, maxDamage = nil, 0
    for _, tool in pairs(LP.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool:FindFirstChild("Damage") then
            local dmg = tool.Damage.Value or 0
            if dmg > maxDamage then
                maxDamage = dmg
                bestTool = tool
            end
        end
    end
    if bestTool then
        Humanoid:EquipTool(bestTool)
    end
end

-- Get all enemies
local function GetEnemies()
    local enemies = {}
    if workspace:FindFirstChild("Enemies") then
        for _, enemy in pairs(workspace.Enemies:GetChildren()) do
            if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 and enemy:FindFirstChild("HumanoidRootPart") then
                table.insert(enemies, enemy)
            end
        end
    end
    return enemies
end

-- Get the strongest boss
local function GetStrongestBoss()
    local bosses = {}
    for _, model in pairs(workspace:GetDescendants()) do
        if model:IsA("Model") and model.Name:match("Boss") and model:FindFirstChild("Humanoid") and model.Humanoid.Health > 0 and model:FindFirstChild("HumanoidRootPart") then
            table.insert(bosses, model)
        end
    end
    table.sort(bosses, function(a, b)
        return (a.Humanoid.Health.Value or 0) > (b.Humanoid.Health.Value or 0)
    end)
    return bosses[1]
end

-- Use all skills
local function UseSkills()
    for _, key in pairs({"Z", "X", "C", "V"}) do
        pcall(function()
            ReplicatedStorage.Remotes.CommE:FireServer(key)
        end)
    end
end

--================ AUTO COMBAT ============================
task.spawn(function()
    while task.wait(getgenv().Zukafu.HitDelay) do
        EquipBest()
        local boss = GetStrongestBoss()
        if getgenv().Zukafu.AutoBossFarm and boss then
            HRP.CFrame = boss.HumanoidRootPart.CFrame * CFrame.new(0,0,2)
            pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("Attack", boss) end)
            if getgenv().Zukafu.SkillSpam then UseSkills() end
        elseif getgenv().Zukafu.AutoAttack then
            for _, enemy in pairs(GetEnemies()) do
                if (enemy.HumanoidRootPart.Position - HRP.Position).Magnitude <= getgenv().Zukafu.AttackRange then
                    HRP.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0,0,2)
                    pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("Attack", enemy) end)
                    if getgenv().Zukafu.SkillSpam then UseSkills() end
                end
            end
        end
    end
end)

--================ AUTO FARM / COLLECT / LEVEL / STATS =====
task.spawn(function()
    while task.wait(0.5) do
        -- Auto collect drops
        if getgenv().Zukafu.AutoCollect then
            for _, d in pairs(workspace:GetDescendants()) do
                if d.Name == "Drop" and d:IsA("Part") then
                    HRP.CFrame = d.CFrame
                end
            end
        end
        -- Auto level up
        if getgenv().Zukafu.AutoLevel then
            pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("LevelUp") end)
        end
        -- Auto add stats
        if getgenv().Zukafu.AutoStats then
            for _, stat in pairs({"Melee","Sword","Defense"}) do
                pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("AddStats", stat) end)
            end
        end
        -- Auto race selector
        if ReplicatedStorage:FindFirstChild("CommF_") and getgenv().Zukafu.Race then
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("SetRace", getgenv().Zukafu.Race)
            end)
        end
    end
end)

--================ UI CREATION (OMG HUB STYLE) =============
local G = Instance.new("ScreenGui", game.CoreGui)
G.Name = "ZukafuHub"

local MainFrame = Instance.new("Frame", G)
MainFrame.Size = UDim2.new(0, 520, 0, 400)
MainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Active = true
MainFrame.Draggable = true

-- Logo
local Logo = Instance.new("ImageLabel", MainFrame)
Logo.Size = UDim2.new(0, 60, 0, 60)
Logo.Position = UDim2.new(0.01, 0, 0.01, 0)
Logo.BackgroundTransparency = 1
Logo.Image = "rbxassetid://95446124220593"
Logo.ScaleType = Enum.ScaleType.Fit

-- Title
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -70, 0, 40)
Title.Position = UDim2.new(0, 70, 0, 10)
Title.Text = "ZUKAFU HUB v4 | BLOX FRUITS"
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(0, 255, 140)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16

-- Discord Button
local DiscordBtn = Instance.new("TextButton", MainFrame)
DiscordBtn.Size = UDim2.new(0, 150, 0, 30)
DiscordBtn.Position = UDim2.new(1, -160, 0, 10)
DiscordBtn.Text = "Join Discord"
DiscordBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
DiscordBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
DiscordBtn.Font = Enum.Font.GothamBold
DiscordBtn.TextSize = 14
DiscordBtn.MouseButton1Click:Connect(function()
    setclipboard("https://discord.gg/TmYWHdk6W")
end)
DiscordBtn.MouseEnter:Connect(function() DiscordBtn.TextColor3 = Color3.fromRGB(0, 200, 255) end)
DiscordBtn.MouseLeave:Connect(function() DiscordBtn.TextColor3 = Color3.fromRGB(0, 255, 255) end)

--================ TABS & PAGES ===========================
local TabsFrame = Instance.new("Frame", MainFrame)
TabsFrame.Size = UDim2.new(0, 120, 1, -60)
TabsFrame.Position = UDim2.new(0, 0, 0, 60)
TabsFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)

local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Size = UDim2.new(1, -120, 1, -60)
ContentFrame.Position = UDim2.new(0, 120, 0, 60)
ContentFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

local Pages = {}

local function CreatePage(name)
    local Page = Instance.new("Frame", ContentFrame)
    Page.Size = UDim2.new(1,0,1,0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Pages[name] = Page
    return Page
end

local function CreateTab(name, y, page)
    local Btn = Instance.new("TextButton", TabsFrame)
    Btn.Size = UDim2.new(1,0,0,40)
    Btn.Position = UDim2.new(0,0,0,y)
    Btn.Text = name
    Btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
    Btn.TextColor3 = Color3.new(1,1,1)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 14
    Btn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        page.Visible = true
    end)
end

--================ CREATE PAGES & TOGGLES =================
local CombatPage = CreatePage("Combat")
local FarmPage = CreatePage("Farm")
local TeleportPage = CreatePage("Teleport")
local MiscPage = CreatePage("Misc")
CombatPage.Visible = true

local function CreateToggle(parent, text, y, callback)
    local Btn = Instance.new("TextButton", parent)
    Btn.Size = UDim2.new(0, 300, 0, 35)
    Btn.Position = UDim2.new(0, 20, 0, y)
    Btn.Text = text.." : OFF"
    Btn.BackgroundColor3 = Color3.fromRGB(35,35,35)
    Btn.TextColor3 = Color3.new(1,1,1)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 14
    local on = false
    Btn.MouseButton1Click:Connect(function()
        on = not on
        Btn.Text = text.." : "..(on and "ON" or "OFF")
        callback(on)
    end)
end

-- Combat toggles
CreateToggle(CombatPage,"Auto Attack",20,function(v)getgenv().Zukafu.AutoAttack=v end)
CreateToggle(CombatPage,"Fast Hit",65,function(v)getgenv().Zukafu.FastHit=v getgenv().Zukafu.HitDelay=v and 0.08 or 0.15 end)
CreateToggle(CombatPage,"Mob Pull",110,function(v)getgenv().Zukafu.MobPull=v end)
CreateToggle(CombatPage,"Skill Spam",155,function(v)getgenv().Zukafu.SkillSpam=v end)
CreateToggle(CombatPage,"Kill Aura",200,function(v)getgenv().Zukafu.KillAura=v end)
CreateToggle(CombatPage,"Auto Boss Farm",245,function(v)getgenv().Zukafu.AutoBossFarm=v end)

-- Farm toggles
CreateToggle(FarmPage,"Auto Farm",20,function(v)getgenv().Zukafu.AutoFarm=v end)
CreateToggle(FarmPage,"Auto Collect",65,function(v)getgenv().Zukafu.AutoCollect=v end)
CreateToggle(FarmPage,"Auto Level",110,function(v)getgenv().Zukafu.AutoLevel=v end)
CreateToggle(FarmPage,"Auto Stats",155,function(v)getgenv().Zukafu.AutoStats=v end)
CreateToggle(FarmPage,"Auto Race V2",200,function(v) if v then getgenv().Zukafu.Race="V2" end end)
CreateToggle(FarmPage,"Auto Race V3",245,function(v) if v then getgenv().Zukafu.Race="V3" end end)

-- Tabs
CreateTab("Combat",0,CombatPage)
CreateTab("Farm",40,FarmPage)
CreateTab("Teleport",80,TeleportPage)
CreateTab("Misc",120,MiscPage)

print("ZUKAFU HUB v4 LOADED | OMG HUB UI + SMART FARM + AUTO RACE V2/V3 + DISCORD")
