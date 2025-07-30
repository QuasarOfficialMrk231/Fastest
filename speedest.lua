local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local ToggleButton = Instance.new("TextButton")
local MainFrame = Instance.new("Frame")
local UIScale = Instance.new("UIScale")

local function createColorCycleText(button)
    coroutine.wrap(function()
        local colors = {
            Color3.fromRGB(100, 200, 255),
            Color3.fromRGB(0, 100, 255),
            Color3.fromRGB(0, 255, 255)
        }
        local index = 1
        while true do
            button.TextColor3 = colors[index]
            index = index % #colors + 1
            wait(0.5)
        end
    end)()
end

ToggleButton.Text = "≡"
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0.05, 0, 0.1, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Draggable = true
ToggleButton.Active = true
ToggleButton.Parent = ScreenGui

MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

UIScale.Scale = 1
UIScale.Parent = MainFrame

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local function createButton(name, posY)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.9, 0, 0, 40)
    button.Position = UDim2.new(0.05, 0, 0, posY)
    button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    button.BorderColor3 = Color3.fromRGB(0, 255, 200)
    button.Text = name
    button.TextSize = 14
    button.Parent = MainFrame
    createColorCycleText(button)
    return button
end

local function createInput(posY, placeholder, color)
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0.9, 0, 0, 30)
    input.Position = UDim2.new(0.05, 0, 0, posY)
    input.PlaceholderText = placeholder
    input.BackgroundColor3 = color
    input.Text = ""
    input.Parent = MainFrame
    return input
end

local SpeedInput = createInput(10, "Введите скорость", Color3.fromRGB(200, 100, 200))
local SetSpeedButton = createButton("Установить скорость", 50)

local StartCloneButton = createButton("Start Clone", 100)

local RadiusInput = createInput(150, "Радиус круга", Color3.fromRGB(255, 150, 200))
local CircleSpeedInput = createInput(190, "Скорость круга", Color3.fromRGB(100, 150, 255))
local GitOvalButton = createButton("GitOval", 230)

local RunOnWayButton = createButton("RunOnWay", 280)

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local hrp = lp.Character:WaitForChild("HumanoidRootPart")
local runningClone = false
local runningCircle = false

SetSpeedButton.MouseButton1Click:Connect(function()
    local speed = tonumber(SpeedInput.Text)
    if speed then
        lp.Character.Humanoid.WalkSpeed = speed
    end
end)

StartCloneButton.MouseButton1Click:Connect(function()
    if runningClone then return end
    runningClone = true
    coroutine.wrap(function()
        while runningClone do
            local offset = Vector3.new(5, 0, 5)
            hrp.CFrame = hrp.CFrame * CFrame.new(offset)
            wait(0.05)
            hrp.CFrame = hrp.CFrame * CFrame.new(-offset)
            wait(0.05)
        end
    end)()
end)

GitOvalButton.MouseButton1Click:Connect(function()
    if runningCircle then
        runningCircle = false
        return
    end
    local radius = tonumber(RadiusInput.Text) or 15
    local speed = tonumber(CircleSpeedInput.Text) or 10
    runningCircle = true
    coroutine.wrap(function()
        local angle = 0
        while runningCircle do
            angle = angle + math.rad(speed)
            local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
            hrp.CFrame = CFrame.new(hrp.Position + offset) * CFrame.Angles(0, angle, 0)
            wait(0.03)
        end
    end)()
end)

RunOnWayButton.MouseButton1Click:Connect(function()
    local humanoid = lp.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://180426354"
        local track = humanoid:LoadAnimation(anim)
        track:Play()
        track:AdjustSpeed(5)
    end
end)
