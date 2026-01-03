if not game:IsLoaded() then game.Loaded:Wait() end

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- Настройки
local ESP_SETTINGS = { Enabled = false, Boxes = true, Names = true, Distance = true, MaxDistance = 1500, Color = Color3.fromRGB(0, 255, 100) }
local HITBOX_SETTINGS = { Enabled = false, Size = 8, Transparency = 0.7, Color = Color3.fromRGB(0, 255, 100) }
local VISUALS_SETTINGS = { FOV = 70, SkyColor = Color3.fromRGB(135, 206, 235), FullBright = false }

local Camera = workspace.CurrentCamera
local LocalPlayer = game:GetService("Players").LocalPlayer
local Lighting = game:GetService("Lighting")

local Window = Fluent:CreateWindow({
    Title = "Trident Survival",
    SubTitle = "Mobile Edition",
    TabWidth = 160,
    Size = UDim2.fromOffset(450, 360),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Кнопка открытия для телефонов
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local OpenBtn = Instance.new("TextButton", ScreenGui)
local UICorner = Instance.new("UICorner", OpenBtn)
OpenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
OpenBtn.Position = UDim2.new(0.1, 0, 0.15, 0)
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Text = "MENU"
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.Draggable = true
OpenBtn.Active = true
UICorner.CornerRadius = UDim.new(1, 0)
OpenBtn.MouseButton1Click:Connect(function() Window:Minimize() end)

local Tabs = {
    Combat = Window:AddTab({ Title = "Combat", Icon = "crosshair" }),
    ESP = Window:AddTab({ Title = "ESP", Icon = "eye" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "monitor" })
}

-- [COMBAT]
Tabs.Combat:AddToggle("HitboxToggle", {Title = "Hitbox", Default = false}):OnChanged(function(Value)
    HITBOX_SETTINGS.Enabled = Value
end)

Tabs.Combat:AddSlider("HitboxSize", {Title = "Size", Default = 8, Min = 1, Max = 20, Rounding = 1, Callback = function(Value)
    HITBOX_SETTINGS.Size = Value
end})

Tabs.Combat:AddColorpicker("HitboxColor", {Title = "Color", Default = Color3.fromRGB(0, 255, 100), Callback = function(Value)
    HITBOX_SETTINGS.Color = Value
end})

-- [VISUALS]
Tabs.Visuals:AddToggle("FullBright", {Title = "FullBright", Default = false}):OnChanged(function(Value)
    VISUALS_SETTINGS.FullBright = Value
end)

Tabs.Visuals:AddSlider("FOV", {Title = "FOV", Default = 70, Min = 70, Max = 120, Rounding = 0, Callback = function(Value)
    VISUALS_SETTINGS.FOV = Value
end})

Tabs.Visuals:AddColorpicker("SkyColor", {Title = "Sky Color", Default = Color3.fromRGB(135, 206, 235), Callback = function(Value)
    VISUALS_SETTINGS.SkyColor = Value
end})

-- [ESP]
Tabs.ESP:AddToggle("EspMaster", {Title = "Enable ESP", Default = false}):OnChanged(function(Value)
    ESP_SETTINGS.Enabled = Value
end)

Tabs.ESP:AddColorpicker("EspColor", {Title = "Color", Default = Color3.fromRGB(0, 255, 100), Callback = function(Value)
    ESP_SETTINGS.Color = Value
end})

Tabs.ESP:AddToggle("ShowBox", {Title = "Box", Default = true}):OnChanged(function(Value)
    ESP_SETTINGS.Boxes = Value
end)

Tabs.ESP:AddToggle("ShowNames", {Title = "Names", Default = true}):OnChanged(function(Value)
    ESP_SETTINGS.Names = Value
end)

Tabs.ESP:AddToggle("ShowDist", {Title = "Distance", Default = true}):OnChanged(function(Value)
    ESP_SETTINGS.Distance = Value
end)

-- [LOGIC: RENDERING & VISUALS]
game:GetService("RunService").RenderStepped:Connect(function()
    Camera.FieldOfView = VISUALS_SETTINGS.FOV
    
    -- FullBright & Sky Logic
    if VISUALS_SETTINGS.FullBright then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)

else
        Lighting.GlobalShadows = true
        Lighting.OutdoorAmbient = VISUALS_SETTINGS.SkyColor
    end
    Lighting.FogColor = VISUALS_SETTINGS.SkyColor
    
    -- Hitbox Logic
    if HITBOX_SETTINGS.Enabled then
        for _, obj in pairs(workspace:GetChildren()) do
            if obj:IsA("Model") and obj.Name ~= LocalPlayer.Name then
                local head = obj:FindFirstChild("Head")
                if head and head:IsA("BasePart") then
                    head.Size = Vector3.new(HITBOX_SETTINGS.Size, HITBOX_SETTINGS.Size, HITBOX_SETTINGS.Size)
                    head.Transparency = HITBOX_SETTINGS.Transparency
                    head.Color = HITBOX_SETTINGS.Color
                    head.CanCollide = false
                end
            end
        end
    end
end)

-- [LOGIC: ESP]
task.spawn(function()
    while task.wait(0.05) do
        for _, obj in pairs(workspace:GetChildren()) do
            if obj:IsA("Model") and obj.Name ~= LocalPlayer.Name then
                local root = obj:FindFirstChild("UpperTorso") or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
                if ESP_SETTINGS.Enabled and root then
                    local dist = math.floor((Camera.CFrame.Position - root.Position).Magnitude)
                    local _, onScreen = Camera:WorldToViewportPoint(root.Position)
                    
                    if onScreen and dist <= ESP_SETTINGS.MaxDistance then
                        local main = obj:FindFirstChild("TridentVisuals") or Instance.new("Model", obj)
                        main.Name = "TridentVisuals"
                        
                        -- Box GUI
                        local boxGui = main:FindFirstChild("BoxGui") or Instance.new("BillboardGui", main)
                        if not main:FindFirstChild("BoxGui") then
                            boxGui.Name = "BoxGui"; boxGui.AlwaysOnTop = true; boxGui.Size = UDim2.new(4, 0, 5.5, 0); boxGui.Adornee = root
                            local f = Instance.new("Frame", boxGui); f.Size = UDim2.new(1, 0, 1, 0); f.BackgroundTransparency = 1
                            local s = Instance.new("UIStroke", f); s.Thickness = 1.5; s.Name = "Stroke"
                        end
                        boxGui.Enabled = ESP_SETTINGS.Boxes
                        if boxGui:FindFirstChild("Frame") then boxGui.Frame.Stroke.Color = ESP_SETTINGS.Color end

                        -- Text GUI
                        local textGui = main:FindFirstChild("TextGui") or Instance.new("BillboardGui", main)
                        if not main:FindFirstChild("TextGui") then
                            textGui.Name = "TextGui"; textGui.AlwaysOnTop = true; textGui.Size = UDim2.new(0, 150, 0, 30); textGui.Adornee = root
                            textGui.StudsOffset = Vector3.new(0, 3.5, 0)
                            local l = Instance.new("TextLabel", textGui); l.Name = "InfoLabel"; l.BackgroundTransparency = 1; l.Size = UDim2.new(1, 0, 1, 0); l.TextSize = 11; l.Font = Enum.Font.SourceSansBold
                        end
                        textGui.Enabled = (ESP_SETTINGS.Names or ESP_SETTINGS.Distance)
                        local label = textGui:FindFirstChild("InfoLabel")
                        if label then
                            label.TextColor3 = ESP_SETTINGS.Color
                            label.Text = (ESP_SETTINGS.Names and obj.Name or "") .. (ESP_SETTINGS.Distance and "\n[" .. dist .. "m]" or "")
                        end
                    else
                        if obj:FindFirstChild("TridentVisuals") then obj.TridentVisuals:Destroy() end
                    end
                else
                    if obj:FindFirstChild("TridentVisuals") then obj.TridentVisuals:Destroy() end
                end
            end
        end
    end
end)

Window:SelectTab(1)
