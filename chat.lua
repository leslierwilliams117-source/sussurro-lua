-- Roblox Chat Client para Delta Executor
-- Conecta com backend Rust

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Configuracao
local SERVER_URL = "https://chat-lua.onrender.com"
local USERNAME = LocalPlayer and LocalPlayer.Name or "Usuario"
local WINDOW_SIZE = UDim2.new(0, 420, 0, 530)
local HEADER_HEIGHT = 62
local MIN_WIDTH = 320
local MIN_HEIGHT = 280

local lastTimestamp = 0
local isRunning = true
local isMinimized = false
local messageCount = 0
local notificationStack = {}

local COLORS = {
    window = Color3.fromRGB(15, 21, 30),
    windowAccent = Color3.fromRGB(24, 35, 48),
    headerA = Color3.fromRGB(25, 57, 80),
    headerB = Color3.fromRGB(17, 29, 43),
    panel = Color3.fromRGB(20, 28, 38),
    panelSoft = Color3.fromRGB(26, 36, 47),
    border = Color3.fromRGB(48, 67, 86),
    text = Color3.fromRGB(239, 244, 249),
    subtext = Color3.fromRGB(155, 171, 188),
    muted = Color3.fromRGB(108, 123, 138),
    accent = Color3.fromRGB(33, 191, 160),
    accentDark = Color3.fromRGB(22, 138, 115),
    accentSoft = Color3.fromRGB(20, 45, 43),
    online = Color3.fromRGB(62, 217, 123),
    syncing = Color3.fromRGB(244, 184, 76),
    offline = Color3.fromRGB(244, 96, 96),
    bubbleMine = Color3.fromRGB(26, 116, 102),
    bubbleOther = Color3.fromRGB(31, 43, 57),
    bubbleMineStroke = Color3.fromRGB(57, 168, 149),
    bubbleOtherStroke = Color3.fromRGB(57, 76, 98),
    shadow = Color3.fromRGB(0, 0, 0),
}

local function addCorner(target, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = target
    return corner
end

local function addStroke(target, color, transparency, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Transparency = transparency or 0
    stroke.Thickness = thickness or 1
    stroke.Parent = target
    return stroke
end

local function trim(text)
    return text:match("^%s*(.-)%s*$")
end

local existingGui = game.CoreGui:FindFirstChild("SussurroChat")
if existingGui then
    existingGui:Destroy()
end

-- GUI
local ScreenGui = Instance.new("ScreenGui")
local Shadow = Instance.new("Frame")
local Frame = Instance.new("Frame")
local TopBar = Instance.new("Frame")
local HeaderGlow = Instance.new("Frame")
local Divider = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local Subtitle = Instance.new("TextLabel")
local StatusPill = Instance.new("Frame")
local StatusIndicator = Instance.new("Frame")
local StatusText = Instance.new("TextLabel")
local MinimizeButton = Instance.new("TextButton")
local CloseButton = Instance.new("TextButton")
local ChatBox = Instance.new("ScrollingFrame")
local ChatPadding = Instance.new("UIPadding")
local ChatLayout = Instance.new("UIListLayout")
local EmptyState = Instance.new("TextLabel")
local Composer = Instance.new("Frame")
local InputShell = Instance.new("Frame")
local InputBox = Instance.new("TextBox")
local InputPadding = Instance.new("UIPadding")
local ComposerHint = Instance.new("TextLabel")
local SendButton = Instance.new("TextButton")
local ResizeHandle = Instance.new("TextButton")

ScreenGui.Name = "SussurroChat"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game.CoreGui

Shadow.Name = "Shadow"
Shadow.Parent = ScreenGui
Shadow.BackgroundColor3 = COLORS.shadow
Shadow.BackgroundTransparency = 0.72
Shadow.Position = UDim2.new(0.5, -210, 0.5, -245)
Shadow.Size = WINDOW_SIZE
Shadow.BorderSizePixel = 0
Shadow.ZIndex = 1
addCorner(Shadow, 24)

Frame.Name = "Window"
Frame.Parent = ScreenGui
Frame.BackgroundColor3 = COLORS.window
Frame.Position = UDim2.new(0.5, -210, 0.5, -265)
Frame.Size = WINDOW_SIZE
Frame.BorderSizePixel = 0
Frame.ClipsDescendants = true
Frame.ZIndex = 2
addCorner(Frame, 22)
addStroke(Frame, COLORS.border, 0.2, 1)

local frameGradient = Instance.new("UIGradient")
frameGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, COLORS.windowAccent),
    ColorSequenceKeypoint.new(0.12, COLORS.window),
    ColorSequenceKeypoint.new(1, COLORS.window),
})
frameGradient.Rotation = 90
frameGradient.Parent = Frame

TopBar.Name = "TopBar"
TopBar.Parent = Frame
TopBar.BackgroundTransparency = 1
TopBar.Size = UDim2.new(1, 0, 0, HEADER_HEIGHT)
TopBar.Active = true
TopBar.Selectable = true
TopBar.ZIndex = 3

HeaderGlow.Name = "HeaderGlow"
HeaderGlow.Parent = TopBar
HeaderGlow.BackgroundColor3 = COLORS.headerA
HeaderGlow.Size = UDim2.new(1, 0, 1, 0)
HeaderGlow.BorderSizePixel = 0
HeaderGlow.ZIndex = 3
addCorner(HeaderGlow, 22)

local headerGradient = Instance.new("UIGradient")
headerGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, COLORS.headerA),
    ColorSequenceKeypoint.new(1, COLORS.headerB),
})
headerGradient.Rotation = 0
headerGradient.Parent = HeaderGlow

Divider.Parent = Frame
Divider.BackgroundColor3 = COLORS.border
Divider.BackgroundTransparency = 0.55
Divider.Position = UDim2.new(0, 0, 0, HEADER_HEIGHT)
Divider.Size = UDim2.new(1, 0, 0, 1)
Divider.BorderSizePixel = 0
Divider.ZIndex = 3

Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 18, 0, 9)
Title.Size = UDim2.new(1, -220, 0, 22)
Title.Text = "Sussurro"
Title.TextColor3 = COLORS.text
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 4

Subtitle.Parent = TopBar
Subtitle.BackgroundTransparency = 1
Subtitle.Position = UDim2.new(0, 18, 0, 32)
Subtitle.Size = UDim2.new(1, -220, 0, 16)
Subtitle.Text = "Chat em tempo real"
Subtitle.TextColor3 = COLORS.subtext
Subtitle.Font = Enum.Font.GothamMedium
Subtitle.TextSize = 12
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.ZIndex = 4

StatusPill.Parent = TopBar
StatusPill.BackgroundColor3 = COLORS.panel
StatusPill.Position = UDim2.new(1, -212, 0, 16)
StatusPill.Size = UDim2.new(0, 118, 0, 30)
StatusPill.BorderSizePixel = 0
StatusPill.ZIndex = 4
addCorner(StatusPill, 15)
addStroke(StatusPill, COLORS.border, 0.25, 1)

StatusIndicator.Parent = StatusPill
StatusIndicator.BackgroundColor3 = COLORS.syncing
StatusIndicator.Position = UDim2.new(0, 10, 0.5, -4)
StatusIndicator.Size = UDim2.new(0, 8, 0, 8)
StatusIndicator.BorderSizePixel = 0
StatusIndicator.ZIndex = 5
addCorner(StatusIndicator, 8)

StatusText.Parent = StatusPill
StatusText.BackgroundTransparency = 1
StatusText.Position = UDim2.new(0, 24, 0, 0)
StatusText.Size = UDim2.new(1, -30, 1, 0)
StatusText.Text = "Conectando"
StatusText.TextColor3 = COLORS.text
StatusText.Font = Enum.Font.GothamMedium
StatusText.TextSize = 12
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.ZIndex = 5

MinimizeButton.Parent = TopBar
MinimizeButton.BackgroundColor3 = COLORS.panel
MinimizeButton.Position = UDim2.new(1, -84, 0, 16)
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = COLORS.text
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextSize = 18
MinimizeButton.ZIndex = 4
addCorner(MinimizeButton, 15)
addStroke(MinimizeButton, COLORS.border, 0.2, 1)

CloseButton.Parent = TopBar
CloseButton.BackgroundColor3 = Color3.fromRGB(99, 38, 43)
CloseButton.Position = UDim2.new(1, -46, 0, 16)
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Text = "X"
CloseButton.TextColor3 = COLORS.text
CloseButton.BorderSizePixel = 0
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 14
CloseButton.ZIndex = 4
addCorner(CloseButton, 15)
addStroke(CloseButton, Color3.fromRGB(180, 84, 93), 0.2, 1)

ChatBox.Parent = Frame
ChatBox.BackgroundColor3 = COLORS.panel
ChatBox.Position = UDim2.new(0, 12, 0, HEADER_HEIGHT + 12)
ChatBox.Size = UDim2.new(1, -24, 1, -166)
ChatBox.CanvasSize = UDim2.new(0, 0, 0, 0)
ChatBox.ScrollBarThickness = 5
ChatBox.ScrollBarImageColor3 = COLORS.accent
ChatBox.BorderSizePixel = 0
ChatBox.ScrollingDirection = Enum.ScrollingDirection.Y
ChatBox.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
ChatBox.ZIndex = 2
addCorner(ChatBox, 18)
addStroke(ChatBox, COLORS.border, 0.35, 1)

ChatPadding.Parent = ChatBox
ChatPadding.PaddingTop = UDim.new(0, 12)
ChatPadding.PaddingBottom = UDim.new(0, 12)
ChatPadding.PaddingLeft = UDim.new(0, 12)
ChatPadding.PaddingRight = UDim.new(0, 12)

ChatLayout.Parent = ChatBox
ChatLayout.SortOrder = Enum.SortOrder.LayoutOrder
ChatLayout.Padding = UDim.new(0, 10)
ChatLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

EmptyState.Parent = Frame
EmptyState.BackgroundTransparency = 1
EmptyState.Position = ChatBox.Position
EmptyState.Size = ChatBox.Size
EmptyState.Text = "Sem mensagens por enquanto\nEnvie algo para iniciar a conversa."
EmptyState.TextColor3 = COLORS.muted
EmptyState.Font = Enum.Font.GothamMedium
EmptyState.TextSize = 15
EmptyState.TextWrapped = true
EmptyState.Visible = true
EmptyState.ZIndex = 3

Composer.Parent = Frame
Composer.BackgroundColor3 = COLORS.panel
Composer.Position = UDim2.new(0, 12, 1, -92)
Composer.Size = UDim2.new(1, -24, 0, 72)
Composer.BorderSizePixel = 0
Composer.ZIndex = 3
addCorner(Composer, 18)
addStroke(Composer, COLORS.border, 0.35, 1)

InputShell.Parent = Composer
InputShell.BackgroundColor3 = COLORS.panelSoft
InputShell.Position = UDim2.new(0, 10, 0, 10)
InputShell.Size = UDim2.new(1, -112, 0, 38)
InputShell.BorderSizePixel = 0
InputShell.ZIndex = 4
addCorner(InputShell, 14)
addStroke(InputShell, COLORS.border, 0.25, 1)

InputBox.Parent = InputShell
InputBox.BackgroundTransparency = 1
InputBox.Position = UDim2.new(0, 0, 0, 0)
InputBox.Size = UDim2.new(1, 0, 1, 0)
InputBox.Text = ""
InputBox.PlaceholderText = "Digite uma mensagem"
InputBox.PlaceholderColor3 = COLORS.muted
InputBox.TextColor3 = COLORS.text
InputBox.ClearTextOnFocus = false
InputBox.BorderSizePixel = 0
InputBox.Font = Enum.Font.Gotham
InputBox.TextSize = 14
InputBox.TextXAlignment = Enum.TextXAlignment.Left
InputBox.MultiLine = false
InputBox.ZIndex = 5

InputPadding.Parent = InputBox
InputPadding.PaddingLeft = UDim.new(0, 12)
InputPadding.PaddingRight = UDim.new(0, 12)

ComposerHint.Parent = Composer
ComposerHint.BackgroundTransparency = 1
ComposerHint.Position = UDim2.new(0, 12, 1, -21)
ComposerHint.Size = UDim2.new(1, -24, 0, 14)
ComposerHint.Text = "Enter para enviar"
ComposerHint.TextColor3 = COLORS.muted
ComposerHint.Font = Enum.Font.GothamMedium
ComposerHint.TextSize = 11
ComposerHint.TextXAlignment = Enum.TextXAlignment.Left
ComposerHint.ZIndex = 4

SendButton.Parent = Composer
SendButton.BackgroundColor3 = COLORS.accent
SendButton.Position = UDim2.new(1, -92, 0, 10)
SendButton.Size = UDim2.new(0, 82, 0, 38)
SendButton.Text = "Enviar"
SendButton.TextColor3 = COLORS.text
SendButton.BorderSizePixel = 0
SendButton.Font = Enum.Font.GothamBold
SendButton.TextSize = 14
SendButton.ZIndex = 4
addCorner(SendButton, 14)
addStroke(SendButton, COLORS.accentDark, 0.15, 1)

local sendGradient = Instance.new("UIGradient")
sendGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, COLORS.accent),
    ColorSequenceKeypoint.new(1, COLORS.accentDark),
})
sendGradient.Rotation = 90
sendGradient.Parent = SendButton

ResizeHandle.Parent = Frame
ResizeHandle.BackgroundTransparency = 1
ResizeHandle.Position = UDim2.new(1, -24, 1, -24)
ResizeHandle.Size = UDim2.new(0, 18, 0, 18)
ResizeHandle.Text = "//"
ResizeHandle.TextColor3 = COLORS.muted
ResizeHandle.TextSize = 11
ResizeHandle.Font = Enum.Font.Code
ResizeHandle.BorderSizePixel = 0
ResizeHandle.ZIndex = 4

local expandedSize = Frame.Size
local dragging = false
local dragStart
local startPos
local resizing = false
local resizeStart
local startSize

local function syncShadow()
    local framePos = Frame.Position
    local frameSize = Frame.Size
    Shadow.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset, framePos.Y.Scale, framePos.Y.Offset + 14)
    Shadow.Size = UDim2.new(frameSize.X.Scale, frameSize.X.Offset, frameSize.Y.Scale, frameSize.Y.Offset)
end

local function updateChatCanvas()
    local paddingSize = ChatPadding.PaddingTop.Offset + ChatPadding.PaddingBottom.Offset
    local contentHeight = ChatLayout.AbsoluteContentSize.Y + paddingSize
    local maxScroll = math.max(0, contentHeight - ChatBox.AbsoluteWindowSize.Y)
    ChatBox.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
    ChatBox.CanvasPosition = Vector2.new(0, maxScroll)
end

local function updateEmptyState()
    EmptyState.Visible = (messageCount == 0) and not isMinimized
end

local function setConnectionState(state, label)
    if state == "online" then
        StatusIndicator.BackgroundColor3 = COLORS.online
        StatusText.Text = label or "Conectado"
    elseif state == "offline" then
        StatusIndicator.BackgroundColor3 = COLORS.offline
        StatusText.Text = label or "Sem conexao"
    else
        StatusIndicator.BackgroundColor3 = COLORS.syncing
        StatusText.Text = label or "Sincronizando"
    end
end

local function updateSendButton()
    local hasText = trim(InputBox.Text) ~= ""

    SendButton.Active = hasText
    SendButton.AutoButtonColor = hasText

    if hasText then
        SendButton.BackgroundColor3 = COLORS.accent
        SendButton.TextColor3 = COLORS.text
        sendGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, COLORS.accent),
            ColorSequenceKeypoint.new(1, COLORS.accentDark),
        })
    else
        SendButton.BackgroundColor3 = COLORS.panelSoft
        SendButton.TextColor3 = COLORS.muted
        sendGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, COLORS.panelSoft),
            ColorSequenceKeypoint.new(1, COLORS.panelSoft),
        })
    end
end

local function setMinimizedState(value)
    isMinimized = value
    MinimizeButton.Text = isMinimized and "+" or "-"

    ChatBox.Visible = not isMinimized
    Composer.Visible = not isMinimized
    ResizeHandle.Visible = not isMinimized

    if isMinimized then
        EmptyState.Visible = false
        Frame.Size = UDim2.new(0, expandedSize.X.Offset, 0, HEADER_HEIGHT)
    else
        Frame.Size = expandedSize
        updateEmptyState()
        updateChatCanvas()
    end

    syncShadow()
end

local function formatTimestamp(timestamp)
    if type(timestamp) ~= "number" then
        return ""
    end

    local normalized = timestamp
    if normalized > 1000000000000 then
        normalized = math.floor(normalized / 1000)
    end

    local ok, formatted = pcall(function()
        return os.date("%H:%M", normalized)
    end)

    if ok then
        return formatted
    end

    return ""
end

local function relayoutNotifications()
    for index, notif in ipairs(notificationStack) do
        local targetPosition = UDim2.new(1, -300, 0, 18 + ((index - 1) * 74))
        TweenService:Create(notif, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = targetPosition
        }):Play()
    end
end

local function dismissNotification(notif)
    for index, activeNotif in ipairs(notificationStack) do
        if activeNotif == notif then
            table.remove(notificationStack, index)
            break
        end
    end

    if notif.Parent then
        TweenService:Create(notif, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 24, notif.Position.Y.Scale, notif.Position.Y.Offset)
        }):Play()

        task.delay(0.2, function()
            if notif.Parent then
                notif:Destroy()
            end
        end)
    end

    relayoutNotifications()
end

local function showNotification(user, text)
    if not isRunning or not ScreenGui.Parent then
        return
    end

    local notif = Instance.new("Frame")
    notif.Parent = ScreenGui
    notif.BackgroundColor3 = COLORS.panel
    notif.Position = UDim2.new(1, 24, 0, 18)
    notif.Size = UDim2.new(0, 282, 0, 64)
    notif.BorderSizePixel = 0
    notif.ZIndex = 10
    addCorner(notif, 16)
    addStroke(notif, COLORS.border, 0.25, 1)

    local accentBar = Instance.new("Frame")
    accentBar.Parent = notif
    accentBar.BackgroundColor3 = COLORS.accent
    accentBar.Size = UDim2.new(0, 4, 1, -16)
    accentBar.Position = UDim2.new(0, 8, 0, 8)
    accentBar.BorderSizePixel = 0
    accentBar.ZIndex = 11
    addCorner(accentBar, 8)

    local notifTitle = Instance.new("TextLabel")
    notifTitle.Parent = notif
    notifTitle.BackgroundTransparency = 1
    notifTitle.Position = UDim2.new(0, 22, 0, 10)
    notifTitle.Size = UDim2.new(1, -32, 0, 18)
    notifTitle.Text = user
    notifTitle.TextColor3 = COLORS.text
    notifTitle.Font = Enum.Font.GothamBold
    notifTitle.TextSize = 14
    notifTitle.TextXAlignment = Enum.TextXAlignment.Left
    notifTitle.ZIndex = 11

    local notifText = Instance.new("TextLabel")
    notifText.Parent = notif
    notifText.BackgroundTransparency = 1
    notifText.Position = UDim2.new(0, 22, 0, 30)
    notifText.Size = UDim2.new(1, -32, 0, 22)
    notifText.Text = text
    notifText.TextColor3 = COLORS.subtext
    notifText.Font = Enum.Font.Gotham
    notifText.TextSize = 12
    notifText.TextWrapped = true
    notifText.TextXAlignment = Enum.TextXAlignment.Left
    notifText.TextYAlignment = Enum.TextYAlignment.Top
    notifText.TextTruncate = Enum.TextTruncate.AtEnd
    notifText.ZIndex = 11

    table.insert(notificationStack, notif)
    relayoutNotifications()

    task.delay(3, function()
        dismissNotification(notif)
    end)
end

local function addMessage(user, text, timestamp)
    messageCount = messageCount + 1
    updateEmptyState()

    local isMe = user == USERNAME
    local timeText = formatTimestamp(timestamp)
    local metaText = user

    if timeText ~= "" then
        metaText = metaText .. "  " .. timeText
    end

    local row = Instance.new("Frame")
    row.Name = "MessageRow"
    row.Parent = ChatBox
    row.BackgroundTransparency = 1
    row.Size = UDim2.new(1, 0, 0, 0)
    row.AutomaticSize = Enum.AutomaticSize.Y
    row.LayoutOrder = messageCount
    row.ZIndex = 3

    local bubble = Instance.new("Frame")
    bubble.Parent = row
    bubble.BackgroundColor3 = isMe and COLORS.bubbleMine or COLORS.bubbleOther
    bubble.Size = UDim2.new(0.78, 0, 0, 0)
    bubble.AutomaticSize = Enum.AutomaticSize.Y
    bubble.BorderSizePixel = 0
    bubble.AnchorPoint = isMe and Vector2.new(1, 0) or Vector2.new(0, 0)
    bubble.Position = isMe and UDim2.new(1, 0, 0, 0) or UDim2.new(0, 0, 0, 0)
    bubble.ZIndex = 4
    addCorner(bubble, 16)
    addStroke(bubble, isMe and COLORS.bubbleMineStroke or COLORS.bubbleOtherStroke, 0.15, 1)

    local bubblePadding = Instance.new("UIPadding")
    bubblePadding.Parent = bubble
    bubblePadding.PaddingTop = UDim.new(0, 10)
    bubblePadding.PaddingBottom = UDim.new(0, 10)
    bubblePadding.PaddingLeft = UDim.new(0, 12)
    bubblePadding.PaddingRight = UDim.new(0, 12)

    local bubbleLayout = Instance.new("UIListLayout")
    bubbleLayout.Parent = bubble
    bubbleLayout.SortOrder = Enum.SortOrder.LayoutOrder
    bubbleLayout.Padding = UDim.new(0, 6)

    local metaLabel = Instance.new("TextLabel")
    metaLabel.Parent = bubble
    metaLabel.BackgroundTransparency = 1
    metaLabel.Size = UDim2.new(1, 0, 0, 14)
    metaLabel.Text = metaText
    metaLabel.TextColor3 = isMe and Color3.fromRGB(201, 255, 242) or COLORS.subtext
    metaLabel.Font = Enum.Font.GothamMedium
    metaLabel.TextSize = 11
    metaLabel.TextXAlignment = isMe and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
    metaLabel.LayoutOrder = 1
    metaLabel.ZIndex = 5

    local bodyLabel = Instance.new("TextLabel")
    bodyLabel.Parent = bubble
    bodyLabel.BackgroundTransparency = 1
    bodyLabel.Size = UDim2.new(1, 0, 0, 0)
    bodyLabel.AutomaticSize = Enum.AutomaticSize.Y
    bodyLabel.Text = text
    bodyLabel.TextColor3 = COLORS.text
    bodyLabel.Font = Enum.Font.Gotham
    bodyLabel.TextSize = 14
    bodyLabel.TextWrapped = true
    bodyLabel.TextXAlignment = isMe and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
    bodyLabel.TextYAlignment = Enum.TextYAlignment.Top
    bodyLabel.LayoutOrder = 2
    bodyLabel.ZIndex = 5

    updateChatCanvas()
end

local function sendMessage(text)
    local content = trim(text)
    if content == "" then
        return
    end

    setConnectionState("syncing", "Enviando")

    local payload = HttpService:JSONEncode({
        user = USERNAME,
        text = content,
    })

    local success, response = pcall(function()
        return request({
            Url = SERVER_URL .. "/send",
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = payload
        })
    end)

    local statusCode = response and tonumber(response.StatusCode)
    local requestSucceeded = success
        and response
        and response.Success
        and (not statusCode or (statusCode >= 200 and statusCode < 300))

    if requestSucceeded then
        InputBox.Text = ""
        updateSendButton()
        setConnectionState("online", "Conectado")
    else
        setConnectionState("offline", "Falha no envio")
    end
end

local function fetchMessages()
    if not isRunning then
        return
    end

    local success, response = pcall(function()
        return request({
            Url = SERVER_URL .. "/messages?since=" .. lastTimestamp,
            Method = "GET"
        })
    end)

    if not isRunning or not ScreenGui.Parent then
        return
    end

    if success and response and response.Success then
        local decodeOk, messages = pcall(function()
            return HttpService:JSONDecode(response.Body)
        end)

        if not decodeOk or type(messages) ~= "table" then
            setConnectionState("offline", "Resposta invalida")
            return
        end

        setConnectionState("online", "Conectado")

        if lastTimestamp == 0 and #messages > 0 then
            lastTimestamp = messages[#messages].timestamp
            return
        end

        for _, msg in ipairs(messages) do
            local user = tostring(msg.user or "Usuario")
            local text = tostring(msg.text or "")

            if user ~= USERNAME and (isMinimized or not InputBox:IsFocused()) then
                task.spawn(function()
                    showNotification(user, text)
                end)
            end

            addMessage(user, text, msg.timestamp)
            if type(msg.timestamp) == "number" then
                lastTimestamp = math.max(lastTimestamp, msg.timestamp)
            end
        end
    else
        setConnectionState("offline", "Servidor indisponivel")
    end
end

ChatLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateChatCanvas)
ChatBox:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(updateChatCanvas)
InputBox:GetPropertyChangedSignal("Text"):Connect(updateSendButton)
Frame:GetPropertyChangedSignal("Position"):Connect(syncShadow)
Frame:GetPropertyChangedSignal("Size"):Connect(function()
    if not isMinimized then
        expandedSize = Frame.Size
    end
    updateChatCanvas()
    syncShadow()
end)

-- Eventos
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
        local newWidth = math.max(MIN_WIDTH, startSize.X.Offset + delta.X)
        local newHeight = math.max(MIN_HEIGHT, startSize.Y.Offset + delta.Y)
        Frame.Size = UDim2.new(0, newWidth, 0, newHeight)
        expandedSize = Frame.Size
    end
end)

MinimizeButton.MouseButton1Click:Connect(function()
    setMinimizedState(not isMinimized)
end)

CloseButton.MouseButton1Click:Connect(function()
    isRunning = false

    for _, notif in ipairs(notificationStack) do
        if notif.Parent then
            notif:Destroy()
        end
    end

    ScreenGui:Destroy()
end)

SendButton.Activated:Connect(function()
    sendMessage(InputBox.Text)
end)

InputBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        sendMessage(InputBox.Text)
    end
end)

updateSendButton()
setConnectionState("syncing", "Conectando")
syncShadow()
updateEmptyState()
updateChatCanvas()

-- Loop de atualizacao
task.spawn(function()
    while isRunning do
        task.wait(1)

        if not isRunning then
            break
        end

        fetchMessages()
    end
end)

print("Chat carregado!")
