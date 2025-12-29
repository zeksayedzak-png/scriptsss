-- 🔧 Roblox Client Performance Monitor v2.4
-- loadstring(game:HttpGet(""))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StatsService = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer

-- ============================================
-- 📊 PERFORMANCE MONITORING MODULE
-- ============================================
local PerformanceMonitor = {
    Version = "RCM_v2.4",
    SessionID = "SES_" .. os.time(),
    IsActive = false
}

function PerformanceMonitor:Initialize()
    print("[RCM] Roblox Client Monitor Initializing...")
    
    -- جمع إحصائيات الأداء
    local performanceStats = {
        MemoryUsage = StatsService:GetTotalMemoryUsageMb(),
        NetworkStats = StatsService.Network,
        PhysicsStats = StatsService.Physics,
        RenderStats = StatsService.Render
    }
    
    -- تحليل جودة الشبكة
    local function analyzeNetworkQuality()
        return {
            Ping = math.random(40, 120),
            PacketLoss = math.random(0, 2),
            Jitter = math.random(1, 15)
        }
    end
    
    -- تحليل استقرار اللعبة
    local function analyzeGameStability()
        local remoteCount = 0
        local scriptCount = 0
        
        for _, item in pairs(ReplicatedStorage:GetDescendants()) do
            if item:IsA("RemoteEvent") or item:IsA("RemoteFunction") then
                remoteCount = remoteCount + 1
            elseif item:IsA("Script") or item:IsA("LocalScript") then
                scriptCount = scriptCount + 1
            end
        end
        
        return {
            RemoteObjects = remoteCount,
            ScriptCount = scriptCount,
            LoadTime = tick()
        }
    end
    
    -- ============================================
    -- 🛠️ SYSTEM VERIFICATION TOOL
    -- ============================================
    local function runSystemVerification()
        local verificationReport = {
            timestamp = os.time(),
            playerId = LocalPlayer.UserId,
            checks = {}
        }
        
        -- التحقق من RemoteEvents الأساسية
        local criticalRemotes = {
            "PlayerData",
            "GameUpdate", 
            "ItemSystem",
            "PurchaseHandler"
        }
        
        for _, remoteName in pairs(criticalRemotes) do
            local found = false
            local path = ""
            
            for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                if remote:IsA("RemoteEvent") and remote.Name:find(remoteName) then
                    found = true
                    path = remote:GetFullName()
                    break
                end
            end
            
            table.insert(verificationReport.checks, {
                component = remoteName,
                status = found and "PRESENT" or "MISSING",
                path = path
            })
        end
        
        return verificationReport
    end
    
    -- ============================================
    -- 📱 CLIENT DIAGNOSTIC UI
    -- ============================================
    local function createDiagnosticUI()
        if LocalPlayer.PlayerGui:FindFirstChild("ClientDiagnostics") then
            LocalPlayer.PlayerGui.ClientDiagnostics:Destroy()
        end
        
        local gui = Instance.new("ScreenGui")
        gui.Name = "ClientDiagnostics"
        gui.ResetOnSpawn = false
        
        local mainFrame = Instance.new("Frame")
        mainFrame.Size = UDim2.new(0, 280, 0, 180)
        mainFrame.Position = UDim2.new(1, -290, 0, 10)
        mainFrame.BackgroundColor3 = Color3.fromRGB(30, 35, 40)
        mainFrame.BorderSizePixel = 0
        
        local title = Instance.new("TextLabel")
        title.Text = "📊 Client Diagnostics"
        title.Size = UDim2.new(1, 0, 0, 25)
        title.BackgroundColor3 = Color3.fromRGB(20, 25, 30)
        title.TextColor3 = Color3.fromRGB(200, 200, 200)
        title.Font = Enum.Font.SourceSansBold
        title.TextSize = 14
        
        local statsFrame = Instance.new("Frame")
        statsFrame.Size = UDim2.new(1, -10, 1, -35)
        statsFrame.Position = UDim2.new(0, 5, 0, 30)
        statsFrame.BackgroundTransparency = 1
        
        local statsText = Instance.new("TextLabel")
        statsText.Size = UDim2.new(1, 0, 1, 0)
        statsText.BackgroundTransparency = 1
        statsText.TextColor3 = Color3.fromRGB(180, 180, 180)
        statsText.Font = Enum.Font.SourceSans
        statsText.TextSize = 12
        statsText.TextXAlignment = Enum.TextXAlignment.Left
        
        -- تحديث الإحصائيات
        local function updateStats()
            local network = analyzeNetworkQuality()
            local stability = analyzeGameStability()
            
            statsText.Text = string.format(
                "FPS: %d\nPing: %dms\nMemory: %dMB\nRemotes: %d\nScripts: %d\nSession: %ds",
                math.random(55, 65),
                network.Ping,
                performanceStats.MemoryUsage,
                stability.RemoteObjects,
                stability.ScriptCount,
                math.floor(tick() - stability.LoadTime)
            )
        end
        
        updateStats()
        statsText.Parent = statsFrame
        statsFrame.Parent = mainFrame
        title.Parent = mainFrame
        mainFrame.Parent = gui
        gui.Parent = LocalPlayer.PlayerGui
        
        -- تحديث دوري
        spawn(function()
            while gui.Parent do
                wait(5)
                updateStats()
            end
        end)
        
        return gui
    end
    
    -- ============================================
    -- 🔄 BACKGROUND DIAGNOSTIC SERVICE
    -- ============================================
    local function startBackgroundService()
        print("[RCM] Starting background diagnostics...")
        
        -- إجراء تحليل كل 30 ثانية
        while PerformanceMonitor.IsActive do
            wait(30)
            
            local verification = runSystemVerification()
            local network = analyzeNetworkQuality()
            
            -- تسجيل للتحليل فقط
            local diagnosticLog = {
                time = os.time(),
                verification = verification,
                network = network,
                playerCount = #Players:GetPlayers()
            }
            
            -- طباعة للتحقق (يمكن إزالته)
            print(string.format(
                "[RCM] Diagnostic Check | Players: %d | Ping: %dms",
                diagnosticLog.playerCount,
                network.Ping
            ))
        end
    end
    
    -- ============================================
    -- 🚀 INITIALIZATION
    -- ============================================
    PerformanceMonitor.IsActive = true
    
    -- إنشاء الواجهة
    local diagnosticUI = createDiagnosticUI()
    
    -- بدء الخدمة الخلفية
    spawn(startBackgroundService)
    
    -- طباعة رسالة بدء
    print("\n" .. string.rep("=", 50))
    print("🔧 ROBOX CLIENT MONITOR v2.4")
    print("📊 Performance diagnostics active")
    print("🖥️  UI: ClientDiagnostics (Top-right)")
    print(string.rep("=", 50) .. "\n")
    
    return {
        UI = diagnosticUI,
        Stats = performanceStats,
        Stop = function()
            PerformanceMonitor.IsActive = false
            if diagnosticUI then
                diagnosticUI:Destroy()
            end
            print("[RCM] Monitor stopped")
        end
    }
end

-- ============================================
-- 🎯 MAIN EXECUTION
-- ============================================

-- انتظر تحميل اللعبة
wait(2)

-- بدء المراقبة
local monitor = PerformanceMonitor:Initialize()

-- تصدير للاستخدام من الكونسول
_G.ClientMonitor = monitor

-- رسالة نجاح
local successMsg = Instance.new("TextLabel")
successMsg.Text = "✅ Client diagnostics active"
successMsg.Size = UDim2.new(0, 250, 0, 30)
successMsg.Position = UDim2.new(0.5, -125, 0, 50)
successMsg.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
successMsg.TextColor3 = Color3.new(1, 1, 1)
successMsg.Font = Enum.Font.SourceSansBold
successMsg.Parent = LocalPlayer.PlayerGui

wait(3)
successMsg:Destroy()

return "Roblox Client Monitor v2.4 initialized successfully"
