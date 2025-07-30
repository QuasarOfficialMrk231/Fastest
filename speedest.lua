local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.IgnoreGuiInset = true

local ToggleButton = Instance.new("TextButton")
ToggleButton.Text = "≡"
ToggleButton.Size = UDim2.new(0, 25, 0, 25) -- уменьшено в 2 раза
ToggleButton.Position = UDim2.new(0.05, 0, 0.1, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Parent = ScreenGui
ToggleButton.AutoButtonColor = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 150, 0, 200) -- уменьшено в 2 раза
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
            math.clamp(startPos.X.Scale, 0, 1),
            math.clamp(startPos.X.Offset + delta.X, 0, workspace.CurrentCamera.ViewportSize.X - guiObject.AbsoluteSize.X),
            math.clamp(startPos.Y.Scale, 0, 1),
            math.clamp(startPos.Y.Offset + delta.Y, 0, workspace.CurrentCamera.ViewportSize.Y - guiObject.AbsoluteSize.Y)
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

makeDraggable(ToggleButton)
makeDraggable(MainFrame)

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local function createButton(name, posY)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.9, 0, 0, 20) -- уменьшена высота в 2 раза
    button.Position = UDim2.new(0.05, 0, 0, posY)
    button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    button.BorderColor3 = Color3.fromRGB(0, 255, 200)
    button.Text = name
    button.TextSize = 10 -- уменьшен размер текста
    button.Parent = MainFrame
    createColorCycleText(button)
    button.AutoButtonColor = false
    return button
end

local function createInput(posY, placeholder, color)
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0.9, 0, 0, 15) -- уменьшена высота
    input.Position = UDim2.new(0.05, 0, 0, posY)
    input.PlaceholderText = placeholder
    input.BackgroundColor3 = color
    input.Text = ""
    input.TextSize = 10 -- уменьшен размер текста
    input.ClearTextOnFocus = false
    input.Parent = MainFrame
    return input
end

local SpeedInput = createInput(5, "Введите скорость", Color3.fromRGB(200, 100, 200))
local SetSpeedButton = createButton("Установить скорость", 25)

local StartCloneButton = createButton("Start Clone", 50)

local RadiusInput = createInput(75, "Радиус круга", Color3.fromRGB(255, 150, 200))
local CircleSpeedInput = createInput(95, "Скорость круга", Color3.fromRGB(100, 150, 255))
local GitOvalButton = createButton("GitOval", 115)

local RunOnWayButton = createButton("RunOnWay", 140)

local hrp = nil
local humanoid = nil
local function getCharacterParts()
    local char = lp.Character or lp.CharacterAdded:Wait()
    hrp = char:WaitForChild("HumanoidRootPart")
    humanoid = char:WaitForChild("Humanoid")
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
    runningClone = true
    cloneCoroutine = coroutine.create(function()
        while runningClone do
            hrp.CFrame = hrp.CFrame * CFrame.new(5, 0, 5)
            wait(0.01)
            hrp.CFrame = hrp.CFrame * CFrame.new(-5, 0, -5)
            wait(0.01)
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
    if humanoid then
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://180426354"
        runOnWayTrack = humanoid:LoadAnimation(anim)
        runOnWayTrack:Play()
        runOnWayTrack:AdjustSpeed(5)
    end
end)