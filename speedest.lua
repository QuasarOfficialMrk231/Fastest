local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.IgnoreGuiInset = true

local ToggleButton = Instance.new("TextButton")
ToggleButton.Text = "≡"
ToggleButton.Size = UDim2.new(0, 25, 0, 25)
ToggleButton.Position = UDim2.new(0.05, 0, 0.1, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Parent = ScreenGui
ToggleButton.AutoButtonColor = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 150, 0, 230)
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

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

local function makeDraggable(guiObject)
    local dragging
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        guiObject.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    guiObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

local draggingToggle = false
local dragStartToggle
local startPosToggle

ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingToggle = true
        dragStartToggle = input.Position
        startPosToggle = ToggleButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                draggingToggle = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartToggle
        ToggleButton.Position = UDim2.new(
            startPosToggle.X.Scale,
            startPosToggle.X.Offset + delta.X,
            startPosToggle.Y.Scale,
            startPosToggle.Y.Offset + delta.Y
        )
    end
end)

makeDraggable(MainFrame)

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local function createButton(name, posY)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.9, 0, 0, 20)
    button.Position = UDim2.new(0.05, 0, 0, posY)
    button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    button.BorderColor3 = Color3.fromRGB(0, 255, 200)
    button.Text = name
    button.TextSize = 10
    button.Parent = MainFrame
    createColorCycleText(button)
    button.AutoButtonColor = false
    return button
end

local function createInput(posY, placeholder, color)
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0.9, 0, 0, 15)
    input.Position = UDim2.new(0.05, 0, 0, posY)
    input.PlaceholderText = placeholder
    input.BackgroundColor3 = color
    input.Text = ""
    input.TextSize = 10
    input.ClearTextOnFocus = false
    input.Parent = MainFrame
    return input
end

local SpeedInput = createInput(5, "Скорость", Color3.fromRGB(200, 100, 200))
local SetSpeedButton = createButton("Установить скорость", 25)

local TeleportSpeedInput = createInput(50, "Скорость клона", Color3.fromRGB(255, 150, 200))
local StartCloneButton = createButton("Start Clone", 70)

local RadiusInput = createInput(95, "Радиус круга", Color3.fromRGB(255, 150, 200))
local CircleSpeedInput = createInput(115, "Скорость круга", Color3.fromRGB(100, 150, 255))
local GitOvalButton = createButton("GitOval", 135)

local RunOnWayButton = createButton("RunOnWay", 160)

local hrp = nil
local humanoid = nil
local animator = nil

local function getCharacterParts()
    local char = lp.Character or lp.CharacterAdded:Wait()
    hrp = char:WaitForChild("HumanoidRootPart")
    humanoid = char:WaitForChild("Humanoid")
    animator = humanoid:FindFirstChildOfClass("Animator")
end
getCharacterParts()
lp.CharacterAdded:Connect(getCharacterParts)

local runningClone = false
local runningCircle = false
local cloneCoroutine
local circleCoroutine
local runOnWayTrack

SetSpeedButton.MouseButton1Click:Connect(function()
    local speed = tonumber(SpeedInput.Text)
    if speed and humanoid then
        humanoid.WalkSpeed = speed
    end
end)

StartCloneButton.MouseButton1Click:Connect(function()
    if runningClone then
        runningClone = false
        if cloneCoroutine then
            coroutine.close(cloneCoroutine)
            cloneCoroutine = nil
        end
        return
    end
    local teleportDelay = tonumber(TeleportSpeedInput.Text) or 0.01
    runningClone = true
    cloneCoroutine = coroutine.create(function()
        while runningClone do
            hrp.CFrame = hrp.CFrame * CFrame.new(5, 0, 5)
            wait(teleportDelay)
            hrp.CFrame = hrp.CFrame * CFrame.new(-5, 0, -5)
            wait(teleportDelay)
        end
    end)
    coroutine.resume(cloneCoroutine)
end)

GitOvalButton.MouseButton1Click:Connect(function()
    if runningCircle then
        runningCircle = false
        if circleCoroutine then
            coroutine.close(circleCoroutine)
            circleCoroutine = nil
        end
        return
    end
    local radius = tonumber(RadiusInput.Text) or 15
    local speed = tonumber(CircleSpeedInput.Text) or 10
    runningCircle = true
    circleCoroutine = coroutine.create(function()
        local angle = 0
        while runningCircle do
            angle = angle + math.rad(speed)
            local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
            hrp.CFrame = CFrame.new(hrp.Position + offset) * CFrame.Angles(0, angle, 0)
            wait(0.03)
        end
    end)
    coroutine.resume(circleCoroutine)
end)

RunOnWayButton.MouseButton1Click:Connect(function()
    if runOnWayTrack and runOnWayTrack.IsPlaying then
        runOnWayTrack:Stop()
        runOnWayTrack = nil
        return
    end
    if animator then
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://507766388" -- R15 беговая анимация
        runOnWayTrack = animator:LoadAnimation(anim)
        runOnWayTrack.Priority = Enum.AnimationPriority.Action
        runOnWayTrack:Play()
        runOnWayTrack:AdjustSpeed(5)
    end
end)