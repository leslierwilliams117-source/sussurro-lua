local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Configuração
local SERVER_URL = "https://chat-lua.onrender.com"
local USERNAME = LocalPlayer.Name
local lastTimestamp = 0

-- GUI
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local TopBar = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local StatusIndicator = Instance.new("Frame")
local MinimizeButton = Instance.new("TextButton")
local CloseButton = Instance.new("TextButton")
local ChatBox = Instance.new("ScrollingFrame")
local InputBox = Instance.new("TextBox")
local SendButton = Instance.new("TextButton")
local ResizeHandle = Instance.new("TextButton")

ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
Frame.Position = UDim2.new(0.5, -175, 0.5, -225)
Frame.Size = UDim2.new(0, 350, 0, 450)
Frame.BorderSizePixel = 0
local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 8)
frameCorner.Parent = Frame

TopBar.Parent = Frame
TopBar.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.Active = true
TopBar.Selectable = true
TopBar.BorderSizePixel = 0
local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 8)
topCorner.Parent = TopBar

Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -70, 1, 0)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Text = "Sussurro"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Position = UDim2.new(0, 12, 0, 0)

StatusIndicator.Parent = TopBar
StatusIndicator.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
StatusIndicator.Position = UDim2.new(0, 95, 0, 12)
StatusIndicator.Size = UDim2.new(0, 11, 0, 11)
StatusIndicator.BorderSizePixel = 0
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = StatusIndicator

MinimizeButton.Parent = TopBar
MinimizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
MinimizeButton.Position = UDim2.new(1, -65, 0, 7)
MinimizeButton.Size = UDim2.new(0, 25, 0, 21)
MinimizeButton.Text = "_"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Font = Enum.Font.GothamBold
local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 4)
minCorner.Parent = MinimizeButton

CloseButton.Parent = TopBar
CloseButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
CloseButton.Position = UDim2.new(1, -35, 0, 7)
CloseButton.Size = UDim2.new(0, 25, 0, 21)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.BorderSizePixel = 0
CloseButton.Font = Enum.Font.GothamBold
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 4)
closeCorner.Parent = CloseButton

ChatBox.Parent = Frame
ChatBox.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
ChatBox.Position = UDim2.new(0, 10, 0, 45)
ChatBox.Size = UDim2.new(1, -20, 1, -95)
ChatBox.CanvasSize = UDim2.new(0, 0, 0, 0)
ChatBox.BorderSizePixel = 0
ChatBox.ScrollBarThickness = 4
local chatCorner = Instance.new("UICorner")
chatCorner.CornerRadius = UDim.new(0, 6)
chatCorner.Parent = ChatBox

InputBox.Parent = Frame
InputBox.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
InputBox.Position = UDim2.new(0, 10, 1, -40)
InputBox.Size = UDim2.new(1, -90, 0, 32)
InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
InputBox.PlaceholderText = "Digite sua mensagem..."
InputBox.Text = ""
InputBox.BorderSizePixel = 0
InputBox.Font = Enum.Font.Gotham
InputBox.TextSize = 14
InputBox.TextXAlignment = Enum.TextXAlignment.Left
InputBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
local inputPadding = Instance.new("UIPadding")
inputPadding.PaddingLeft = UDim.new(0, 10)
inputPadding.Parent = InputBox
local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 6)
inputCorner.Parent = InputBox

SendButton.Parent = Frame
SendButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
SendButton.Position = UDim2.new(1, -72, 1, -40)
SendButton.Size = UDim2.new(0, 62, 0, 32)
SendButton.Text = "Enviar"
SendButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SendButton.Active = true
SendButton.BorderSizePixel = 0
SendButton.Font = Enum.Font.GothamBold
SendButton.TextSize = 14
local sendCorner = Instance.new("UICorner")
sendCorner.CornerRadius = UDim.new(0, 6)
sendCorner.Parent = SendButton

ResizeHandle.Parent = Frame
ResizeHandle.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
ResizeHandle.Position = UDim2.new(1, -15, 1, -15)
ResizeHandle.Size = UDim2.new(0, 15, 0, 15)
ResizeHandle.Text = ""
ResizeHandle.BorderSizePixel = 0
ResizeHandle.ZIndex = 5

-- Funções
local function showNotification(user, text)
    local notif = Instance.new("Frame")
    notif.Parent = ScreenGui
    notif.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    notif.Position = UDim2.new(1, 10, 0, 10)
    notif.Size = UDim2.new(0, 300, 0, 50)
    notif.BorderSizePixel = 0
    notif.ZIndex = 10
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 8)
    notifCorner.Parent = notif
    
    local notifTitle = Instance.new("TextLabel")
    notifTitle.Parent = notif
    notifTitle.BackgroundTransparency = 1
    notifTitle.Size = UDim2.new(1, -10, 0, 18)
    notifTitle.Position = UDim2.new(0, 10, 0, 5)
    notifTitle.TextColor3 = Color3.fromRGB(88, 101, 242)
    notifTitle.Text = user
    notifTitle.Font = Enum.Font.GothamBold
    notifTitle.TextSize = 14
    notifTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local notifText = Instance.new("TextLabel")
    notifText.Parent = notif
    notifText.BackgroundTransparency = 1
    notifText.Size = UDim2.new(1, -10, 0, 20)
    notifText.Position = UDim2.new(0, 10, 0, 23)
    notifText.TextColor3 = Color3.fromRGB(200, 200, 200)
    notifText.Text = text
    notifText.Font = Enum.Font.Gotham
    notifText.TextSize = 12
    notifText.TextXAlignment = Enum.TextXAlignment.Left
    notifText.TextTruncate = Enum.TextTruncate.AtEnd
    
    notif:TweenPosition(UDim2.new(1, -310, 0, 10), "Out", "Quad", 0.3, true)
    
    wait(3)
    notif:TweenPosition(UDim2.new(1, 10, 0, 10), "In", "Quad", 0.3, true)
    wait(0.3)
    notif:Destroy()
end

local function addMessage(user, text)
    local isMe = (user == USERNAME)
    
    local msgContainer = Instance.new("Frame")
    msgContainer.Parent = ChatBox
    msgContainer.BackgroundTransparency = 1
    msgContainer.Size = UDim2.new(1, -10, 0, 0)
    msgContainer.AutomaticSize = Enum.AutomaticSize.Y
    
    local msg = Instance.new("TextLabel")
    msg.Parent = msgContainer
    msg.BackgroundColor3 = isMe and Color3.fromRGB(88, 101, 242) or Color3.fromRGB(45, 45, 50)
    msg.Size = UDim2.new(0.7, 0, 0, 0)
    msg.AutomaticSize = Enum.AutomaticSize.Y
    msg.Position = isMe and UDim2.new(0.3, 0, 0, 0) or UDim2.new(0, 0, 0, 0)
    msg.TextColor3 = Color3.fromRGB(255, 255, 255)
    msg.TextXAlignment = isMe and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
    msg.Font = Enum.Font.Gotham
    msg.TextSize = 13
    msg.Text = user .. ": " .. text
    msg.TextWrapped = true
    msg.BorderSizePixel = 0
    
    local msgCorner = Instance.new("UICorner")
    msgCorner.CornerRadius = UDim.new(0, 8)
    msgCorner.Parent = msg
    
    local msgPadding = Instance.new("UIPadding")
    msgPadding.PaddingLeft = UDim.new(0, 8)
    msgPadding.PaddingRight = UDim.new(0, 8)
    msgPadding.PaddingTop = UDim.new(0, 5)
    msgPadding.PaddingBottom = UDim.new(0, 5)
    msgPadding.Parent = msg
    
    local layout = Instance.new("UIListLayout")
    layout.Parent = ChatBox
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)
    
    ChatBox.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ChatBox.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
        ChatBox.CanvasPosition = Vector2.new(0, ChatBox.CanvasSize.Y.Offset)
    end)
end

local function sendMessage(text)
    local data = HttpService:JSONEncode({user = USERNAME, text = text})
    
    local success, response = pcall(function()
        return request({
            Url = SERVER_URL .. "/send",
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = data
        })
    end)
    
    if success then
        InputBox.Text = ""
    end
end

local function fetchMessages()
    local success, response = pcall(function()
        return request({
            Url = SERVER_URL .. "/messages?since=" .. lastTimestamp,
            Method = "GET"
        })
    end)
    
    if success and response.Success then
        StatusIndicator.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        local messages = HttpService:JSONDecode(response.Body)
        
        if lastTimestamp == 0 and #messages > 0 then
            lastTimestamp = messages[#messages].timestamp
            return
        end
        
        for _, msg in ipairs(messages) do
            if msg.user ~= USERNAME then
                spawn(function()
                    showNotification(msg.user, msg.text)
                end)
            end
            addMessage(msg.user, msg.text)
            lastTimestamp = math.max(lastTimestamp, msg.timestamp)
        end
    else
        StatusIndicator.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    end
end

-- Eventos
local isMinimized = false
local dragging = false
local dragStart
local startPos

local resizing = false
local resizeStart
local startSize

local UserInputService = game:GetService("UserInputService")

-- Drag
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
    
    if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - resizeStart
        local newWidth = math.max(250, startSize.X.Offset + delta.X)
        local newHeight = math.max(200, startSize.Y.Offset + delta.Y)
        Frame.Size = UDim2.new(0, newWidth, 0, newHeight)
    end
end)

-- Resize
ResizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        resizing = true
        resizeStart = input.Position
        startSize = Frame.Size
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                resizing = false
            end
        end)
    end
end)

MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        Frame.Size = UDim2.new(0, Frame.AbsoluteSize.X, 0, 35)
        ChatBox.Visible = false
        InputBox.Visible = false
        SendButton.Visible = false
        ResizeHandle.Visible = false
    else
        Frame.Size = UDim2.new(0, Frame.AbsoluteSize.X, 0, 450)
        ChatBox.Visible = true
        InputBox.Visible = true
        SendButton.Visible = true
        ResizeHandle.Visible = true
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

SendButton.Activated:Connect(function()
    if InputBox.Text ~= "" then
        sendMessage(InputBox.Text)
    end
end)

InputBox.FocusLost:Connect(function(enterPressed)
    if enterPressed and InputBox.Text ~= "" then
        sendMessage(InputBox.Text)
    end
end)

-- Loop de atualização
spawn(function()
    while wait(1) do
        fetchMessages()
    end
end)

print("Chat carregado!")
