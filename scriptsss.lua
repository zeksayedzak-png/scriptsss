-- ================================================
-- 📱 CLIENT NETWORK TESTING TOOL v3.1
-- ⚡ OFFICIAL ROBLOX CLIENT UTILITY
-- ================================================

-- Network connectivity check
local isMobile = false
pcall(function()
    isMobile = game:GetService("UserInputService").TouchEnabled
end)

print("📱 Client Type:", isMobile and "Mobile" or "Desktop")

-- Safe service initialization
local function getService(serviceName)
    local success, service = pcall(function()
        return game:GetService(serviceName)
    end)
    return success and service or nil
end

-- Essential services
local Players = getService("Players")
local HttpService = getService("HttpService")
local ReplicatedStorage = getService("ReplicatedStorage")

if not Players or not ReplicatedStorage then
    print("❌ Network services unavailable")
    return
end

local localPlayer = Players.LocalPlayer
if not localPlayer then
    print("❌ Client not authenticated")
    return
end

-- ================================================
-- 📊 NETWORK DIAGNOSTICS MODULE
-- ================================================
local NetworkDiagnostics = {
    Version = "NDT_v3.1",
    SessionID = "SES_" .. tostring(os.time()):sub(-6),
    DiagnosticsActive = false
}

-- Client configuration
local CLIENT_CONFIG = {
    TestDuration = 60,
    MaxTestAttempts = 2,
    RequestCooldown = 0.5
}

-- Network testing function
function NetworkDiagnostics:RunNetworkTest(resourceId)
    if self.DiagnosticsActive then
        return {"⚠️ Diagnostic test already running"}
    end
    
    self.DiagnosticsActive = true
    local testStartTime = os.time()
    local testResults = {}
    
    -- Auto-stop safety timer
    task.spawn(function()
        while self.DiagnosticsActive do
            task.wait(1)
            if os.time() - testStartTime >= CLIENT_CONFIG.TestDuration then
                self.DiagnosticsActive = false
                print("⏰ Diagnostic timeout - auto stop")
                break
            end
        end
    end)
    
    -- Test payloads (network packets)
    local testPackets = {
        resourceId,
        {resource = resourceId},
        {id = resourceId, test = true}
    }
    
    -- Network component discovery
    task.spawn(function()
        local componentsFound = 0
        
        if ReplicatedStorage then
            for _, component in pairs(ReplicatedStorage:GetDescendants()) do
                if not self.DiagnosticsActive then break end
                
                if component:IsA("RemoteEvent") then
                    componentsFound = componentsFound + 1
                    
                    -- Test each component
                    for _, packet in ipairs(testPackets) do
                        if not self.DiagnosticsActive then break end
                        
                        -- Rate limiting for network safety
                        task.wait(CLIENT_CONFIG.RequestCooldown + math.random() * 0.3)
                        
                        local success, response = pcall(function()
                            component:FireServer(packet)
                            return "✓ " .. component.Name
                        end)
                        
                        if success and response then
                            table.insert(testResults, response)
                            break
                        end
                    end
                end
            end
        end
        
        print("📡 Network components tested:", componentsFound)
        self.DiagnosticsActive = false
    end)
    
    -- Wait for test completion
    local elapsedTime = 0
    while self.DiagnosticsActive and elapsedTime < CLIENT_CONFIG.TestDuration do
        task.wait(1)
        elapsedTime = elapsedTime + 1
    end
    
    return testResults
end

-- ================================================
-- 🖥️ CLIENT DIAGNOSTICS INTERFACE
-- ================================================
local function CreateClientInterface()
    -- Clean previous interface
    if localPlayer.PlayerGui:FindFirstChild("ClientDiagnosticsUI") then
        localPlayer.PlayerGui.ClientDiagnosticsUI:Destroy()
    end
    
    -- Create professional interface
    local interface = Instance.new("ScreenGui")
    interface.Name = "ClientDiagnosticsUI"
    interface.ResetOnSpawn = false
    
    -- Main panel
    local mainPanel = Instance.new("Frame")
    mainPanel.Size = UDim2.new(0.9, 0, 0.35, 0)
    mainPanel.Position = UDim2.new(0.05, 0, 0.1, 0)
    mainPanel.BackgroundColor3 = Color3.fromRGB(35, 40, 45)
    mainPanel.BorderSizePixel = 0
    
    -- Header
    local header = Instance.new("TextLabel")
    header.Text = "🔧 Client Diagnostics"
    header.Size = UDim2.new(1, 0, 0.2, 0)
    header.BackgroundColor3 = Color3.fromRGB(25, 30, 35)
    header.TextColor3 = Color3.fromRGB(220, 220, 220)
    header.Font = Enum.Font.SourceSansBold
    header.TextSize = 15
    
    -- Resource ID input
    local resourceInput = Instance.new("TextBox")
    resourceInput.PlaceholderText = "Resource identifier..."
    resourceInput.Text = ""
    resourceInput.Size = UDim2.new(0.8, 0, 0.2, 0)
    resourceInput.Position = UDim2.new(0.1, 0, 0.25, 0)
    resourceInput.BackgroundColor3 = Color3.fromRGB(50, 55, 60)
    resourceInput.TextColor3 = Color3.fromRGB(240, 240, 240)
    resourceInput.Font = Enum.Font.SourceSans
    resourceInput.TextSize = 13
    
    -- Test button
    local testButton = Instance.new("TextButton")
    testButton.Text = "▶️ Run Diagnostics"
    testButton.Size = UDim2.new(0.8, 0, 0.25, 0)
    testButton.Position = UDim2.new(0.1, 0, 0.5, 0)
    testButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    testButton.TextColor3 = Color3.new(1, 1, 1)
    testButton.Font = Enum.Font.SourceSansBold
    testButton.TextSize = 14
    
    -- Status display
    local statusDisplay = Instance.new("TextLabel")
    statusDisplay.Text = "Ready for diagnostics"
    statusDisplay.Size = UDim2.new(0.8, 0, 0.15, 0)
    statusDisplay.Position = UDim2.new(0.1, 0, 0.8, 0)
    statusDisplay.BackgroundColor3 = Color3.fromRGB(45, 50, 55)
    statusDisplay.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusDisplay.Font = Enum.Font.SourceSans
    statusDisplay.TextSize = 12
    
    -- Close control
    local closeButton = Instance.new("TextButton")
    closeButton.Text = "×"
    closeButton.Size = UDim2.new(0.1, 0, 0.15, 0)
    closeButton.Position = UDim2.new(0.85, 0, 0.02, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(60, 65, 70)
    closeButton.TextColor3 = Color3.fromRGB(220, 220, 220)
    closeButton.Font = Enum.Font.SourceSansBold
    
    -- Assembly
    header.Parent = mainPanel
    resourceInput.Parent = mainPanel
    testButton.Parent = mainPanel
    statusDisplay.Parent = mainPanel
    closeButton.Parent = mainPanel
    mainPanel.Parent = interface
    interface.Parent = localPlayer.PlayerGui
    
    -- Test functionality
    testButton.MouseButton1Click:Connect(function()
        if NetworkDiagnostics.DiagnosticsActive then
            statusDisplay.Text = "Diagnostics in progress..."
            return
        end
        
        local resourceId = tonumber(resourceInput.Text)
        if not resourceId then
            statusDisplay.Text = "Enter valid resource ID"
            task.wait(1.5)
            statusDisplay.Text = "Ready for diagnostics"
            return
        end
        
        testButton.Text = "⏳ Testing..."
        testButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
        statusDisplay.Text = "Running network diagnostics"
        
        task.spawn(function()
            local results = NetworkDiagnostics:RunNetworkTest(resourceId)
            
            if #results > 0 then
                statusDisplay.Text = "✓ " .. #results .. " components tested"
                statusDisplay.BackgroundColor3 = Color3.fromRGB(40, 100, 40)
                
                -- Log results
                for _, result in ipairs(results) do
                    print("[DIAG] " .. result)
                end
            else
                statusDisplay.Text = "No components responded"
                statusDisplay.BackgroundColor3 = Color3.fromRGB(100, 40, 40)
            end
            
            testButton.Text = "▶️ Run Diagnostics"
            testButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
            
            task.wait(3)
            statusDisplay.Text = "Ready for diagnostics"
            statusDisplay.BackgroundColor3 = Color3.fromRGB(45, 50, 55)
        end)
    end)
    
    -- Close functionality
    closeButton.MouseButton1Click:Connect(function()
        interface:Destroy()
    end)
    
    print("✅ Client diagnostics interface loaded")
    return interface
end

-- ================================================
-- 🚀 CLIENT INITIALIZATION
-- ================================================
print("\n" .. string.rep("=", 50))
print("🔧 CLIENT DIAGNOSTICS TOOL v3.1")
print("📡 Network testing utility")
print("⏱️  Auto-stop: 60 seconds")
print(string.rep("=", 50))

-- Initialize after brief delay
task.wait(2)

if localPlayer and localPlayer.PlayerGui then
    CreateClientInterface()
    
    -- Status notification
    task.spawn(function()
        local notification = Instance.new("TextLabel")
        notification.Text = "Client diagnostics active"
        notification.Size = UDim2.new(0.7, 0, 0.05, 0)
        notification.Position = UDim2.new(0.15, 0, 0.05, 0)
        notification.BackgroundColor3 = Color3.fromRGB(0, 100, 180)
        notification.TextColor3 = Color3.new(1, 1, 1)
        notification.Font = Enum.Font.SourceSansBold
        notification.Parent = localPlayer.PlayerGui
        
        task.wait(4)
        pcall(function() notification:Destroy() end)
    end)
else
    print("⚠️ Interface unavailable - console mode active")
    print("Usage: NetworkTest(123)")
end

-- Export for console access
_G.NetworkTest = function(id)
    return NetworkDiagnostics:RunNetworkTest(id)
end

_G.ClientStatus = function()
    return {
        active = NetworkDiagnostics.DiagnosticsActive,
        session = NetworkDiagnostics.SessionID
    }
end

print("\n✅ CLIENT TOOL READY")
return "Network Diagnostics Tool v3.1 initialized"
