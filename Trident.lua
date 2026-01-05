task.wait(1)

if not game:IsLoaded() then game.Loaded:Wait() end

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local ESP_SETTINGS = { Enabled = false, Boxes = true, Names = true, Distance = true, MaxDistance = 1500, Color = Color3.fromRGB(0, 255, 100) }
local HITBOX_SETTINGS = { Enabled = false, Size = 8, Transparency = 0.7, Color = Color3.fromRGB(0, 255, 100) }
local VISUALS_SETTINGS = { FOV = 70, SkyColor = Color3.fromRGB(135, 206, 235), FullBright = false, Crosshair = false, CrossColor = Color3.fromRGB(0, 255, 0), Rotate = false }

local Camera = workspace.CurrentCamera
local LocalPlayer = game:GetService("Players").LocalPlayer
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local Window = Fluent:CreateWindow({
    Title = "GoodHub",
    SubTitle = "Optimized Edition",
    TabWidth = 160,
    Size = UDim2.fromOffset(450, 360),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

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

local CrosshairGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local CrosshairMain = Instance.new("Frame", CrosshairGui)
CrosshairMain.Size = UDim2.new(0, 40, 0, 40)
CrosshairMain.AnchorPoint = Vector2.new(0.5, 0.5)
CrosshairMain.BackgroundTransparency = 1
CrosshairGui.Enabled = false

local function CreateLine(pos, size)
    local f = Instance.new("Frame", CrosshairMain)
    f.Position = pos
    f.Size = size
    f.BorderSizePixel = 0
    f.BackgroundColor3 = VISUALS_SETTINGS.CrossColor
    return f
end

-- Зазор как ты просил (маленький)
local t = CreateLine(UDim2.new(0.5, -0.5, 0.5, -7), UDim2.new(0, 1, 0, 5))
local b = CreateLine(UDim2.new(0.5, -0.5, 0.5, 2), UDim2.new(0, 1, 0, 5))
local l = CreateLine(UDim2.new(0.5, -7, 0.5, -0.5), UDim2.new(0, 5, 0, 1))
local r = CreateLine(UDim2.new(0.5, 2, 0.5, -0.5), UDim2.new(0, 5, 0, 1))

local Tabs = {
    Combat = Window:AddTab({ Title = "Combat", Icon = "crosshair" }),
    ESP = Window:AddTab({ Title = "ESP", Icon = "eye" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "monitor" })
}

Tabs.Combat:AddToggle("HitboxToggle", {Title = "Hitbox", Default = false}):OnChanged(function(Value) HITBOX_SETTINGS.Enabled = Value end)
Tabs.Combat:AddSlider("HitboxSize", {Title = "Size", Default = 8, Min = 1, Max = 20, Rounding = 1, Callback = function(Value) HITBOX_SETTINGS.Size = Value end})
Tabs.Combat:AddColorpicker("HitboxColor", {Title = "Color", Default = Color3.fromRGB(0, 255, 100), Callback = function(Value) HITBOX_SETTINGS.Color = Value end})

Tabs.Visuals:AddToggle("FullBright", {Title = "FullBright", Default = false}):OnChanged(function(Value) VISUALS_SETTINGS.FullBright = Value end)
Tabs.Visuals:AddToggle("Crosshair", {Title = "Mouse Crosshair", Default = false}):OnChanged(function(Value) VISUALS_SETTINGS.Crosshair = Value CrosshairGui.Enabled = Value end)
Tabs.Visuals:AddToggle("RotateCross", {Title = "Rotate Crosshair", Default = false}):OnChanged(function(Value) VISUALS_SETTINGS.Rotate = Value end)
Tabs.Visuals:AddColorpicker("CrossColor", {Title = "Crosshair Color", Default = Color3.fromRGB(0, 255, 0), Callback = function(Value)

VISUALS_SETTINGS.CrossColor = Value
    t.BackgroundColor3 = Value b.BackgroundColor3 = Value l.BackgroundColor3 = Value r.BackgroundColor3 = Value
end})
Tabs.Visuals:AddSlider("FOV", {Title = "FOV", Default = 70, Min = 70, Max = 120, Rounding = 0, Callback = function(Value) VISUALS_SETTINGS.FOV = Value end})
Tabs.Visuals:AddColorpicker("SkyColor", {Title = "Sky Color", Default = Color3.fromRGB(135, 206, 235), Callback = function(Value) VISUALS_SETTINGS.SkyColor = Value end})

Tabs.ESP:AddToggle("EspMaster", {Title = "Enable ESP", Default = false}):OnChanged(function(Value) ESP_SETTINGS.Enabled = Value end)
Tabs.ESP:AddColorpicker("EspColor", {Title = "Color", Default = Color3.fromRGB(0, 255, 100), Callback = function(Value) ESP_SETTINGS.Color = Value end})
Tabs.ESP:AddToggle("ShowBox", {Title = "Box", Default = true}):OnChanged(function(Value) ESP_SETTINGS.Boxes = Value end)
Tabs.ESP:AddToggle("ShowNames", {Title = "Names", Default = true}):OnChanged(function(Value) ESP_SETTINGS.Names = Value end)
Tabs.ESP:AddToggle("ShowDist", {Title = "Distance", Default = true}):OnChanged(function(Value) ESP_SETTINGS.Distance = Value end)

local function ClearVisuals(obj)
    local v = obj:FindFirstChild("TridentVisuals")
    if v then v:Destroy() end
end

local lastFOV = VISUALS_SETTINGS.FOV
local rotAngle = 0

RunService.RenderStepped:Connect(function()
    local currentCameraFOV = Camera.FieldOfView
    if currentCameraFOV > 60 or lastFOV ~= VISUALS_SETTINGS.FOV then
        Camera.FieldOfView = VISUALS_SETTINGS.FOV
        lastFOV = VISUALS_SETTINGS.FOV
    end
    
    if VISUALS_SETTINGS.Crosshair then
        local mousePos = UserInputService:GetMouseLocation()
        -- Корректировка высоты (GuiInset), чтобы прицел был точно на кончике курсора
        local inset = GuiService:GetGuiInset()
        CrosshairMain.Position = UDim2.fromOffset(mousePos.X, mousePos.Y - inset.Y)

        if VISUALS_SETTINGS.Rotate then
            rotAngle = rotAngle + 2 -- Вернул прежнюю скорость вращения
            CrosshairMain.Rotation = rotAngle
        else
            CrosshairMain.Rotation = 0
        end
    end

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
end)

task.spawn(function()
    while task.wait(0.1) do
        for _, obj in pairs(workspace:GetChildren()) do
            if obj:IsA("Model") and obj ~= LocalPlayer.Character and obj:FindFirstChild("Head") then
                local head = obj.Head
                local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("UpperTorso") or head

                if HITBOX_SETTINGS.Enabled then
                    head.Size = Vector3.new(HITBOX_SETTINGS.Size, HITBOX_SETTINGS.Size, HITBOX_SETTINGS.Size)
                    head.Transparency = HITBOX_SETTINGS.Transparency
                    head.Color = HITBOX_SETTINGS.Color
                    head.CanCollide = false
                else
                    if head.Size.Y ~= 1.2 then 
                        head.Size = Vector3.new(1.2, 1.2, 1.2)
                        head.Transparency = 0
                    end
                end

                if ESP_SETTINGS.Enabled then
                    local camPos = Camera.CFrame.Position
                    local dist = math.floor((camPos - root.Position).Magnitude)
                    local _, onScreen = Camera:WorldToViewportPoint(root.Position)

                    if onScreen and dist <= ESP_SETTINGS.MaxDistance then
                        local main = obj:FindFirstChild("TridentVisuals") or Instance.new("Folder", obj)
                        main.Name = "TridentVisuals"

                        local boxGui = main:FindFirstChild("BoxGui") or Instance.new("BillboardGui", main)
                        if not boxGui:FindFirstChild("Frame") then
                            boxGui.Name = "BoxGui"; boxGui.AlwaysOnTop = true; boxGui.Size = UDim2.new(4, 0, 5.5, 0); boxGui.Adornee = root
                            local f = Instance.new("Frame", boxGui); f.Size = UDim2.new(1, 0, 1, 0); f.BackgroundTransparency = 1
                            local s = Instance.new("UIStroke", f); s.Thickness = 1.5; s.Name = "Stroke"
                        end
                        boxGui.Enabled = ESP_SETTINGS.Boxes
                        boxGui.Frame.Stroke.Color = ESP_SETTINGS.Color

                        local textGui = main:FindFirstChild("TextGui") or Instance.new("BillboardGui", main)
                        if not textGui:FindFirstChild("Label") then
                            textGui.Name = "TextGui"; textGui.AlwaysOnTop = true; textGui.Size = UDim2.new(0, 150, 0, 30); textGui.Adornee = root
                            textGui.StudsOffset = Vector3.new(0, 3.5, 0)
                            local l = Instance.new("TextLabel", textGui); l.Name = "Label"; l.BackgroundTransparency = 1; l.Size = UDim2.new(1, 0, 1, 0); l.TextSize = 11; l.Font = Enum.Font.SourceSansBold
                        end
                        textGui.Enabled = (ESP_SETTINGS.Names or ESP_SETTINGS.Distance)
                        textGui.Label.TextColor3 = ESP_SETTINGS.Color
                        textGui.Label.Text = (ESP_SETTINGS.Names and obj.Name or "") .. (ESP_SETTINGS.Distance and "\n[" .. dist .. "m]" or "")
                    else
                        ClearVisuals(obj)
                    end
                else
                    ClearVisuals(obj)
                end
            end
        end
    end
end)

Window:SelectTab(1)
