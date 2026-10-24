pcall(function()
    if not game:IsLoaded() then
        local t0 = tick()
        while not game:IsLoaded() and (tick() - t0) < 3 do
            task.wait(0.1)
        end
    end
end)

-- Notificaciones iniciales silenciadas por completo

pcall(function()
    local cg = game:GetService("CoreGui")
    if cg then
        for _, child in ipairs(cg:GetChildren()) do
            if child.Name == "VIP_BackWarning_Gui" or child.Name == "Kavo UI" then
                pcall(function() child:Destroy() end)
            end
        end
    end
end)

-- --------------------------------------------------------------------
-- 🛡️ 1. AUTO-LIMPIEZA DE SESIONES ANTERIORES
-- --------------------------------------------------------------------
if getgenv and pcall(function() return getgenv().AlitasDePollo_Cleanup end) and getgenv().AlitasDePollo_Cleanup then
    pcall(getgenv().AlitasDePollo_Cleanup)
end

local Cleanups = {}
if getgenv then
    pcall(function()
        getgenv().AlitasDePollo_Cleanup = function()
            for _, c in ipairs(Cleanups) do
                pcall(function()
                    if typeof(c) == "RBXScriptConnection" then c:Disconnect()
                    elseif type(c) == "function" then c()
                    end
                end)
            end
        end
    end)
end

-- --------------------------------------------------------------------
-- 📦 SERVICIOS DE ROBLOX
-- --------------------------------------------------------------------
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
-- MarketplaceService removido para rendimiento
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    local t0 = tick()
    while not LocalPlayer and (tick() - t0) < 5 do
        task.wait(0.05)
        LocalPlayer = Players.LocalPlayer
    end
end
if not LocalPlayer then LocalPlayer = Players.LocalPlayer end
local Camera = Workspace.CurrentCamera

local CONFIG_FILE = "BlockSpin_Config_v8.json"
local AUTH_FILE = "BlockSpin_Authorized_Users.json"

local WeaponCache = {}
-- MarketCache removido
local NotifiedWeapons = {}
local FormattedWeaponCache = {}

local WeaponKeywords = {
    -- Míticos / Explosivos / Armas Especiales
    "rpg","rocket","launcher","bazooka","laser","raygun","void","nuclear","ruby","mitic","mítico","dragon","excalibur","dev","celestial","secret","secreto","plasma","railgun",
    -- Legendarios / Snipers pesados / Oro
    "barrett","sniper","awp","dragunov","anaconda","minigun","gold","dorad","diamond","diamante","draco","ultimate","legend","legendario","flamethrower","lanzallamas","m82","cheytac",
    -- Épicos / Rifles de asalto / SMGs pesadas
    "ak47","ak-47","ak","m4a1","m4","scar","m16","famas","aug","m249","vector","p90","g36","galil","m24","rifle","lmg","hk416","tar21","groza","fal",
    -- Raros / Escopetas / SMGs
    "mp5","shotgun","escopeta","smg","uzi","mac10","mac-10","spas","spas12","mossberg","hunting","sawnoff","recortada","crossbow","ballesta","tommy","thompson","grenade","granada","dynamite","dinamita","molotov",
    -- Poco Comunes / Pistolas
    "revolver","glock","pistol","pistola","deagle","desert","beretta","colt","magnum","taser","luger","1911","usp","p250","cz75","makarov",
    -- Melee / Armas cuerpo a cuerpo
    "katana","machete","sword","espada","knife","cuchillo","bat","bate","axe","hacha","crowbar","palanca","hammer","martillo","scythe","guadaña","karambit","kunai","fishing","rod","caña","pan","sarten","gloves","boxeo"
}

-- --------------------------------------------------------------------
-- 🔑 2. SISTEMA DE WHITELIST ONLINE & EXPIRACIÓN EN LA NUBE
local WHITELIST_URL = "https://pastefy.app/wsQK1QwO/raw"
local LocalUser = LocalPlayer.Name:lower()

-- Base de datos local garantizada (doble protección antibloqueo)
local BuiltInWhitelist = {
	  ["Dayeslabs1824"] 		   = {role = "owner", expire = "perma"},
    ["EBZPXSUFEOSA6554"] 		   = {role = "owner", expire = "perma"},
}


local function PlayEpicIntro(role, expire)
    pcall(function()
        local parentGui = nil
        pcall(function() parentGui = game:GetService("CoreGui") end)
        if not parentGui or not pcall(function() return parentGui.Name end) then
            parentGui = LocalPlayer:WaitForChild("PlayerGui", 5)
        end
        if not parentGui then return end

        pcall(function()
            local old = parentGui:FindFirstChild("Alitas_Epic_Intro")
            if old then old:Destroy() end
        end)

        local introGui = Instance.new("ScreenGui")
        introGui.Name = "Alitas_Epic_Intro"
        introGui.ResetOnSpawn = false
        introGui.DisplayOrder = 99999
        introGui.IgnoreGuiInset = true

        local card = Instance.new("Frame")
        card.Name = "VIP_Card"
        card.Size = UDim2.new(0, 480, 0, 240)
        card.AnchorPoint = Vector2.new(0.5, 0.5)
        card.Position = UDim2.new(0.5, 0, 0.54, 0)
        card.BackgroundColor3 = Color3.fromRGB(15, 17, 24)
        card.BackgroundTransparency = 1
        card.BorderSizePixel = 0
        card.ClipsDescendants = true
        card.Parent = introGui

        local cardCorner = Instance.new("UICorner")
        cardCorner.CornerRadius = UDim.new(0, 16)
        cardCorner.Parent = card

        local cardStroke = Instance.new("UIStroke")
        cardStroke.Thickness = 2.5
        cardStroke.Color = Color3.fromRGB(255, 180, 30)
        cardStroke.Transparency = 1
        cardStroke.Parent = card

        local strokeGradient = Instance.new("UIGradient")
        strokeGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 170, 0)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 60, 120)),
            ColorSequenceKeypoint.new(0.66, Color3.fromRGB(160, 60, 255)),
            ColorSequenceKeypoint.new(1.0, Color3.fromRGB(255, 170, 0))
        })
        strokeGradient.Parent = cardStroke

        local glowFrame = Instance.new("Frame")
        glowFrame.Size = UDim2.new(1, 0, 1, 0)
        glowFrame.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
        glowFrame.BackgroundTransparency = 0.94
        glowFrame.BorderSizePixel = 0
        glowFrame.Parent = card
        local glowCorner = Instance.new("UICorner")
        glowCorner.CornerRadius = UDim.new(0, 16)
        glowCorner.Parent = glowFrame

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -30, 0, 26)
        titleLabel.Position = UDim2.new(0, 15, 0, 14)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.Text = "🍗 HERMANOS ALITAS DE POLLO VIP"
        titleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
        titleLabel.TextSize = 17
        titleLabel.TextXAlignment = Enum.TextXAlignment.Center
        titleLabel.TextTransparency = 1
        titleLabel.Parent = card

        local subTitleLabel = Instance.new("TextLabel")
        subTitleLabel.Size = UDim2.new(1, -30, 0, 16)
        subTitleLabel.Position = UDim2.new(0, 15, 0, 38)
        subTitleLabel.BackgroundTransparency = 1
        subTitleLabel.Font = Enum.Font.GothamMedium
        subTitleLabel.Text = "👑 BLOCKSPIN PRIVATE EDITION • v12.3"
        subTitleLabel.TextColor3 = Color3.fromRGB(180, 185, 205)
        subTitleLabel.TextSize = 11
        subTitleLabel.TextXAlignment = Enum.TextXAlignment.Center
        subTitleLabel.TextTransparency = 1
        subTitleLabel.Parent = card

        local div = Instance.new("Frame")
        div.Size = UDim2.new(1, -40, 0, 1)
        div.Position = UDim2.new(0, 20, 0, 58)
        div.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
        div.BackgroundTransparency = 1
        div.BorderSizePixel = 0
        div.Parent = card

        local avatarFrame = Instance.new("Frame")
        avatarFrame.Size = UDim2.new(0, 64, 0, 64)
        avatarFrame.Position = UDim2.new(0, 22, 0, 68)
        avatarFrame.BackgroundColor3 = Color3.fromRGB(25, 28, 40)
        avatarFrame.BackgroundTransparency = 1
        avatarFrame.BorderSizePixel = 0
        avatarFrame.Parent = card

        local avCorner = Instance.new("UICorner")
        avCorner.CornerRadius = UDim.new(1, 0)
        avCorner.Parent = avatarFrame

        local avStroke = Instance.new("UIStroke")
        avStroke.Thickness = 2
        avStroke.Color = Color3.fromRGB(255, 215, 0)
        avStroke.Transparency = 1
        avStroke.Parent = avatarFrame

        local avatarImg = Instance.new("ImageLabel")
        avatarImg.Size = UDim2.new(1, 0, 1, 0)
        avatarImg.BackgroundTransparency = 1
        avatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LocalPlayer.UserId) .. "&w=150&h=150"
        avatarImg.ImageTransparency = 1
        avatarImg.Parent = avatarFrame
        local imgCorner = Instance.new("UICorner")
        imgCorner.CornerRadius = UDim.new(1, 0)
        imgCorner.Parent = avatarImg

        local welcomeUser = Instance.new("TextLabel")
        welcomeUser.Size = UDim2.new(0, 360, 0, 20)
        welcomeUser.Position = UDim2.new(0, 98, 0, 68)
        welcomeUser.BackgroundTransparency = 1
        welcomeUser.Font = Enum.Font.GothamBold
        welcomeUser.Text = "¡Bienvenido, " .. LocalPlayer.DisplayName .. " (@" .. LocalPlayer.Name .. ")!"
        welcomeUser.TextColor3 = Color3.fromRGB(255, 255, 255)
        welcomeUser.TextSize = 14
        welcomeUser.TextXAlignment = Enum.TextXAlignment.Left
        welcomeUser.TextTransparency = 1
        welcomeUser.Parent = card

        local isOwner = (tostring(role):lower() == "owner")
        local roleBadge = Instance.new("Frame")
        roleBadge.Size = UDim2.new(0, isOwner and 175 or 210, 0, 20)
        roleBadge.Position = UDim2.new(0, 98, 0, 91)
        roleBadge.BackgroundColor3 = isOwner and Color3.fromRGB(240, 150, 0) or Color3.fromRGB(15, 130, 240)
        roleBadge.BackgroundTransparency = 1
        roleBadge.BorderSizePixel = 0
        roleBadge.Parent = card
        local rbCorner = Instance.new("UICorner")
        rbCorner.CornerRadius = UDim.new(0, 6)
        rbCorner.Parent = roleBadge

        local roleLabel = Instance.new("TextLabel")
        roleLabel.Size = UDim2.new(1, 0, 1, 0)
        roleLabel.BackgroundTransparency = 1
        roleLabel.Font = Enum.Font.GothamBold
        roleLabel.Text = isOwner and "👑 RANGO: OWNER SUPREMO" or "💎 RANGO: MIEMBRO VIP AUTORIZADO"
        roleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        roleLabel.TextSize = 10
        roleLabel.TextTransparency = 1
        roleLabel.Parent = roleBadge

        local statusLabel = Instance.new("TextLabel")
        statusLabel.Size = UDim2.new(0, 360, 0, 18)
        statusLabel.Position = UDim2.new(0, 98, 0, 114)
        statusLabel.BackgroundTransparency = 1
        statusLabel.Font = Enum.Font.GothamMedium
        statusLabel.Text = "🟢 ESTADO: ACCESO VIP PERMANENTE Y VÁLIDO"
        statusLabel.TextColor3 = Color3.fromRGB(60, 240, 130)
        statusLabel.TextSize = 11
        statusLabel.TextXAlignment = Enum.TextXAlignment.Left
        statusLabel.TextTransparency = 1
        statusLabel.Parent = card

        local featuresFrame = Instance.new("Frame")
        featuresFrame.Size = UDim2.new(1, -40, 0, 22)
        featuresFrame.Position = UDim2.new(0, 20, 0, 142)
        featuresFrame.BackgroundTransparency = 1
        featuresFrame.Parent = card

        local pills = {"🎯 Aimbot Imán 100%", "👁️ ESP Nombres/Armas", "⚡ 0 Recoil", "🛡️ Anti-Cheat Safe"}
        local pWidth = 105
        for i, text in ipairs(pills) do
            local pill = Instance.new("Frame")
            pill.Size = UDim2.new(0, pWidth, 0, 20)
            pill.Position = UDim2.new(0, (i - 1) * (pWidth + 6), 0, 0)
            pill.BackgroundColor3 = Color3.fromRGB(30, 33, 46)
            pill.BackgroundTransparency = 1
            pill.BorderSizePixel = 0
            pill.Parent = featuresFrame
            local pCorner = Instance.new("UICorner")
            pCorner.CornerRadius = UDim.new(0, 4)
            pCorner.Parent = pill

            local pText = Instance.new("TextLabel")
            pText.Size = UDim2.new(1, 0, 1, 0)
            pText.BackgroundTransparency = 1
            pText.Font = Enum.Font.GothamBold
            pText.Text = text
            pText.TextColor3 = Color3.fromRGB(220, 225, 240)
            pText.TextSize = 9
            pText.TextTransparency = 1
            pText.Parent = pill
        end

        local barBg = Instance.new("Frame")
        barBg.Size = UDim2.new(1, -40, 0, 6)
        barBg.Position = UDim2.new(0, 20, 0, 178)
        barBg.BackgroundColor3 = Color3.fromRGB(28, 30, 42)
        barBg.BackgroundTransparency = 1
        barBg.BorderSizePixel = 0
        barBg.ClipsDescendants = true
        barBg.Parent = card
        local bCorner = Instance.new("UICorner")
        bCorner.CornerRadius = UDim.new(1, 0)
        bCorner.Parent = barBg

        local barFill = Instance.new("Frame")
        barFill.Size = UDim2.new(0, 0, 1, 0)
        barFill.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
        barFill.BorderSizePixel = 0
        barFill.Parent = barBg
        local bfCorner = Instance.new("UICorner")
        bfCorner.CornerRadius = UDim.new(1, 0)
        bfCorner.Parent = barFill

        local fillGradient = Instance.new("UIGradient")
        fillGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 170, 0)),
            ColorSequenceKeypoint.new(1.0, Color3.fromRGB(255, 60, 120))
        })
        fillGradient.Parent = barFill

        local bottomMsg = Instance.new("TextLabel")
        bottomMsg.Size = UDim2.new(1, -40, 0, 16)
        bottomMsg.Position = UDim2.new(0, 20, 0, 192)
        bottomMsg.BackgroundTransparency = 1
        bottomMsg.Font = Enum.Font.Gotham
        bottomMsg.Text = "⚡ Inyectando módulos de combate optimizados... ¡Listo para arrasar!"
        bottomMsg.TextColor3 = Color3.fromRGB(140, 145, 165)
        bottomMsg.TextSize = 10
        bottomMsg.TextXAlignment = Enum.TextXAlignment.Center
        bottomMsg.TextTransparency = 1
        bottomMsg.Parent = card

        introGui.Parent = parentGui

        pcall(function()
            local snd = Instance.new("Sound")
            snd.SoundId = "rbxassetid://4590662766"
            snd.Volume = 0.5
            snd.Parent = Workspace
            snd:Play()
            task.delay(2, function() pcall(function() snd:Destroy() end) end)
        end)

        local rotConn
        rotConn = RunService.RenderStepped:Connect(function()
            if strokeGradient and strokeGradient.Parent then
                strokeGradient.Rotation = (strokeGradient.Rotation + 3) % 360
            else
                if rotConn then rotConn:Disconnect() end
            end
        end)

        local tweenInfoIn = TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        TweenService:Create(card, tweenInfoIn, {
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundTransparency = 0.05
        }):Play()
        TweenService:Create(cardStroke, tweenInfoIn, {Transparency = 0}):Play()
        TweenService:Create(titleLabel, tweenInfoIn, {TextTransparency = 0}):Play()
        TweenService:Create(subTitleLabel, tweenInfoIn, {TextTransparency = 0}):Play()
        TweenService:Create(div, tweenInfoIn, {BackgroundTransparency = 0.6}):Play()
        TweenService:Create(avatarFrame, tweenInfoIn, {BackgroundTransparency = 0}):Play()
        TweenService:Create(avStroke, tweenInfoIn, {Transparency = 0}):Play()
        TweenService:Create(avatarImg, tweenInfoIn, {ImageTransparency = 0}):Play()
        TweenService:Create(welcomeUser, tweenInfoIn, {TextTransparency = 0}):Play()
        TweenService:Create(roleBadge, tweenInfoIn, {BackgroundTransparency = 0}):Play()
        TweenService:Create(roleLabel, tweenInfoIn, {TextTransparency = 0}):Play()
        TweenService:Create(statusLabel, tweenInfoIn, {TextTransparency = 0}):Play()
        TweenService:Create(barBg, tweenInfoIn, {BackgroundTransparency = 0}):Play()
        TweenService:Create(bottomMsg, tweenInfoIn, {TextTransparency = 0}):Play()

        for _, pill in ipairs(featuresFrame:GetChildren()) do
            if pill:IsA("Frame") then
                TweenService:Create(pill, tweenInfoIn, {BackgroundTransparency = 0}):Play()
                local t = pill:FindFirstChildOfClass("TextLabel")
                if t then TweenService:Create(t, tweenInfoIn, {TextTransparency = 0}):Play() end
            end
        end

        local barTween = TweenService:Create(barFill, TweenInfo.new(2.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 1, 0)
        })
        barTween:Play()

        task.delay(3.4, function()
            local tweenInfoOut = TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            TweenService:Create(card, tweenInfoOut, {
                Position = UDim2.new(0.5, 0, 0.42, 0),
                BackgroundTransparency = 1
            }):Play()
            TweenService:Create(cardStroke, tweenInfoOut, {Transparency = 1}):Play()
            TweenService:Create(titleLabel, tweenInfoOut, {TextTransparency = 1}):Play()
            TweenService:Create(subTitleLabel, tweenInfoOut, {TextTransparency = 1}):Play()
            TweenService:Create(avatarImg, tweenInfoOut, {ImageTransparency = 1}):Play()
            TweenService:Create(welcomeUser, tweenInfoOut, {TextTransparency = 1}):Play()
            TweenService:Create(roleLabel, tweenInfoOut, {TextTransparency = 1}):Play()
            TweenService:Create(statusLabel, tweenInfoOut, {TextTransparency = 1}):Play()
            TweenService:Create(bottomMsg, tweenInfoOut, {TextTransparency = 1}):Play()

            task.delay(0.5, function()
                pcall(function() if rotConn then rotConn:Disconnect() end end)
                pcall(function() introGui:Destroy() end)
            end)
        end)
    end)
end

local function VerifyAccess()
    -- Acceso VIP Owner permanente instantáneo (cero peticiones bloqueantes)
    return true, "owner", "perma"
end

local isAuthed, userRole, expireInfo = VerifyAccess()
if not isAuthed then
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "🍗 Hermanos Alitas VIP",
            Text  = expireInfo or "Sin acceso.",
            Duration = 6
        })
    end)
    task.wait(1.5)
    -- (Kick removed: never close game))
    return
end

-- 🌟 PRESENTACIÓN ÉPICA VIP AUTOMÁTICA
task.spawn(function()
    PlayEpicIntro(userRole, expireInfo)
end)

local OWNER_NAME = "hermanos_alaspollito"
local AccessControl = {
    MasterScriptEnabled = true,
    AuthorizedUsers = {
        ["hermanos_alaspollito"]   = true,
        ["hermanos_alitasdepollo"] = true,
        ["hermanos_alitas"]        = true,
        ["krugdiyan204"]           = true,
        ["zytc48meeh40"]           = true,
        ["galembwm60932"]          = true,
        ["ohernwenc747"]           = true,
        ["benjaxfordd"]            = true,
        ["harerxinyi8681"]          = true,
        [LocalUser]                = true
    }
}


-- --------------------------------------------------------------------
-- ⚙️ ESTADO GLOBAL DE CONFIGURACIÓN
-- --------------------------------------------------------------------
local State = {
    Aimbot = true,
    AimbotKey = "V",
    MenuKey = "M",
    EspKey = "P",
    WatermarkKey = "K",
    EspShowDistance = true,
    AimbotFOV = 250,
    AimbotSmoothness = 1.0,
    AutoLockAlways = false,
    POVSmoothness = 0.28,      -- Sensibilidad POV: imán suave que permite salirse y cambiar de objetivo fácilmente    -- Modo POV / Imán Automático sin pulsar botón    -- 1.0 = Pegado 100% Imán (cero separación al trackear)
    TargetPart = "Head",
    TogglePartKey = "B",       -- Tecla para alternar Cabeza / Pecho
    AutoSwitchPart = false,    -- Alternar automáticamente cada 1 segundo (Cabeza <-> Pecho)

    AntiCheatSafety = false,   -- Auto-cambia a Pecho a corta distancia (< 35 studs) para evitar Anti-Cheat
    ShowFOV = true,
    ShowTargetDot = true,
    FOVColor = Color3.fromRGB(160, 60, 255),
    TargetDotColor = Color3.fromRGB(255, 45, 85),
    TeamCheck = false,
    IgnoreFriends = true,
    IgnoredPlayers = {},
    LockedTarget = nil,
    IsLocked = false,
    DeviceMode = "PC",   -- "PC" o "Mobile"

    -- 🗺️ Mini-Radar Táctico 2D
    RadarEnabled = true,
    RadarRange = 120,

    -- 🎯 Mira Personalizada Táctica (Custom Crosshair)
    CrosshairEnabled = true,
    CrosshairColor = "Cian Neón",
    CrosshairStyle = "Cruz Táctica",
    CrosshairSize = 8,
    CrosshairGap = 4,

    -- 🔊 Hitsounds & Kill-Sounds VIP
    HitsoundsEnabled = true,
    HitsoundChoice = "Rust",

    -- 🕶️ FullBright / Visión Nocturna Táctica
    FullBrightEnabled = false,

    -- 🚀 Modo Turbo FPS / Potato Boost
    PotatoBoost = false,
    FlatTextures = false,

    ZeroRecoil = false,
    ZeroPingSpread = true,    -- Modo 0 Ping: Concentra perdigones de escopeta / recortada sin dispersión
    FastBullets = false,
    BulletMultiplier = 5,

    ESP = true,
    EspGlow = true,            -- Siluetas / Glow en jugadores (Chams)
    EspShowWeapons   = true,   -- mostrar armas en ESP
    WeaponDisplayMode = "Images", -- "Images" (iconos/imágenes de armas), "Text" (texto), "Both" (ambos)
    EspShowNames     = true,   -- mostrar nombres en ESP
    EspShowHealth    = true,   -- mostrar barra de vida en ESP
    EspTracers       = true,   -- Líneas / Tracers directos a cada enemigo a cualquier distancia
    TracerOrigin     = "Bottom", -- "Bottom", "Center", "Mouse"
    TracerThickness  = 1.5,
    EnemyGlowColor = Color3.fromRGB(255, 40, 40),
    AllyGlowColor = Color3.fromRGB(46, 204, 113),
    GlowTransparency = 0.6,

    -- 🎮 Control / Gamepad
    GamepadAimEnabled = true,
    GamepadAimButton = "ButtonR1",  -- R1 por defecto

    -- ⚠️ Alertas de Peligro & Armas
    WarnAllWeapons = true,        -- Notificar armas equipadas (RPG, Barrett, AK-47, MP5, etc.)
    BackWarningEnabled = true,   -- Alerta en pantalla de enemigo a la espalda
    BackWarningDistance = 65,    -- Distancia máxima de alerta a la espalda (studs)

    -- 🌾 Farm / Dibu System
    AutoFarm = false,
    FarmUnderground = false,
    FarmAntiClip = false,      -- Zona Secreta Anti-Clip (Imposible de clipear)
    AutoFarmDistance = 8,
    AutoFishing = false,       -- Auto-Pesca Nivel 70
    AutoCollectDrops = false,
    Noclip = false,
    FarmSpeed = 16,

    -- 🛡️ Protección Dibu
    AutoRespawn = true,
    AutoPunch = false,
    AntiDerribo = true,
    AntiMuerte = true,
    OcultarNombre = false,
    AutoDeposit = false,
    DepositLimit = 2000,

    -- 🎬 Modo Creador / Spoof Nombre
    SpoofNameEnabled = false,
    SpoofedName = "Alitas_Official_Owner"
}

-- --------------------------------------------------------------------
-- --------------------------------------------------------------------
-- 💾 NOTIFICACIONES & PERSISTENCIA ULTRA-CONFIABLE
-- --------------------------------------------------------------------
local function PlayAlertSound()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://4590662766"
        sound.Volume = 0.4
        sound.Parent = Workspace
        sound:Play()
        task.delay(1.5, function() pcall(function() sound:Destroy() end) end)
    end)
end

local function ShowNotification(title, text, soundAlert)
    -- Modo 100% Silencioso: todas las notificaciones en pantalla han sido eliminadas a petición
end

-- ⚠️ GUI DE ALERTA DE ENEMIGO A LAS ESPALDAS
local BackWarningGui = nil
local BackWarningLabel = nil

pcall(function()
    local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 3)
    if pg then
        local sg = Instance.new("ScreenGui")
        sg.Name = "VIP_BackWarning_Gui"
        sg.ResetOnSpawn = false
        sg.DisplayOrder = 999
        sg.Parent = pg

        local lbl = Instance.new("TextLabel")
        lbl.Name = "WarningLabel"
        lbl.Parent = sg
        lbl.Size = UDim2.new(0, 380, 0, 36)
        lbl.Position = UDim2.new(0.5, -190, 0.14, 0)
        lbl.BackgroundColor3 = Color3.fromRGB(220, 30, 60)
        lbl.BackgroundTransparency = 0.2
        lbl.BorderSizePixel = 2
        lbl.BorderColor3 = Color3.fromRGB(255, 255, 255)
        lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        lbl.TextSize = 13
        lbl.Font = Enum.Font.GothamBold
        lbl.Text = "⚠️ ALERTA: ENEMIGO DETRÁS DE TI"
        lbl.Visible = false

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = lbl

        BackWarningGui = sg
        BackWarningLabel = lbl

        table.insert(Cleanups, function() pcall(function() sg:Destroy() end) end)
    end
end)

local UI_Toggles = {}

local function SaveConfig(silent)
    local ok, err = pcall(function()
        local data = {
            Aimbot           = State.Aimbot,
            AimbotKey        = State.AimbotKey,
            MenuKey          = State.MenuKey,
            EspKey           = State.EspKey,
            AimbotFOV        = State.AimbotFOV,
            AimbotSmoothness = State.AimbotSmoothness,
            TargetPart       = State.TargetPart,
            AutoLockAlways   = State.AutoLockAlways,
            ShowFOV          = State.ShowFOV,
            ShowTargetDot    = State.ShowTargetDot,
            TeamCheck        = State.TeamCheck,
            IgnoreFriends    = State.IgnoreFriends,
            IgnoredPlayers   = State.IgnoredPlayers,
            ZeroRecoil       = State.ZeroRecoil,
            FastBullets      = State.FastBullets,
            BulletMultiplier = State.BulletMultiplier,
            ESP              = State.ESP,
            EspGlow          = State.EspGlow,
            EspShowWeapons   = State.EspShowWeapons,
            WeaponDisplayMode = State.WeaponDisplayMode,
            EspShowNames     = State.EspShowNames,
            EspShowHealth    = State.EspShowHealth,
            EspTracers       = State.EspTracers,
            TracerOrigin     = State.TracerOrigin,
            GamepadAimEnabled = State.GamepadAimEnabled,
            GamepadAimButton  = State.GamepadAimButton,
            WarnAllWeapons    = State.WarnAllWeapons,
            BackWarningEnabled = State.BackWarningEnabled,
            TogglePartKey     = State.TogglePartKey,
            AutoSwitchPart    = State.AutoSwitchPart,
            DeviceMode        = State.DeviceMode,
            SpoofNameEnabled  = State.SpoofNameEnabled,
            SpoofedName       = State.SpoofedName,
            RadarEnabled      = State.RadarEnabled,
            RadarRange        = State.RadarRange,
            CrosshairEnabled  = State.CrosshairEnabled,
            CrosshairColor    = State.CrosshairColor,
            CrosshairStyle    = State.CrosshairStyle,
            CrosshairSize     = State.CrosshairSize,
            CrosshairGap      = State.CrosshairGap,
            HitsoundsEnabled  = State.HitsoundsEnabled,
            HitsoundChoice    = State.HitsoundChoice,
            FullBrightEnabled = State.FullBrightEnabled,
            PotatoBoost       = State.PotatoBoost
        }
        local json = HttpService:JSONEncode(data)
        if writefile then
            pcall(function() writefile(CONFIG_FILE, json) end)
            pcall(function() writefile("AlitasDePollo_Config.json", json) end)
        end
        if getgenv then
            getgenv().AlitasDePollo_SavedConfig = data
        end
    end)
    if not silent then
        if ok then
            ShowNotification("🍗 Ajustes", "✅ Configuración guardada correctamente.")
        else
            ShowNotification("🍗 Ajustes", "❌ Error al guardar.")
        end
    end
end

local function LoadConfig(silent)
    local loaded = false
    pcall(function()
        local raw = nil
        if isfile and readfile then
            if isfile(CONFIG_FILE) then
                pcall(function() raw = readfile(CONFIG_FILE) end)
            elseif isfile("AlitasDePollo_Config.json") then
                pcall(function() raw = readfile("AlitasDePollo_Config.json") end)
            end
        end
        
        if raw and #raw > 2 then
            local decoded = HttpService:JSONDecode(raw)
            if decoded and type(decoded) == "table" then
                for k, v in pairs(decoded) do
                    if State[k] ~= nil then State[k] = v end
                end
                loaded = true
            end
        elseif getgenv and getgenv().AlitasDePollo_SavedConfig then
            for k, v in pairs(getgenv().AlitasDePollo_SavedConfig) do
                if State[k] ~= nil then State[k] = v end
            end
            loaded = true
        end
    end)
    if not silent then
        ShowNotification("🍗 Ajustes", loaded and "✅ Configuración cargada." or "ℹ️ Configuración predeterminada.")
    end
    return loaded
end
local _configLoadedOnStart = LoadConfig(true)


-- --------------------------------------------------------------------
-- 🎨 2. KAVO UI - HERMANOS ALITAS DE POLLO
-- --------------------------------------------------------------------
local Library = nil
local kavoSources = {
    "https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua",
    "https://pastefy.app/O5Zuixv6/raw"
}

for _, url in ipairs(kavoSources) do
    local ok, content = pcall(function() return game:HttpGet(url, true) end)
    if not ok or not content or #content < 100 then
        ok, content = pcall(function() return game:HttpGet(url) end)
    end
    if ok and content and #content > 100 then
        local fnOk, fn = pcall(function() return loadstring(content) end)
        if fnOk and type(fn) == "function" then
            local libOk, lib = pcall(fn)
            if libOk and type(lib) == "table" and lib.CreateLib then
                Library = lib
                break
            end
        end
    end
end

if not Library then
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "🍗 Hermanos Alitas",
            Text  = "❌ Error al cargar la UI. Revisa tu conexión.",
            Duration = 5
        })
    end)
    return
end

-- --------------------------------------------------------------------
-- 🎮 SELECTOR DE DISPOSITIVO (se muestra ANTES del menú)
-- --------------------------------------------------------------------
local _deviceChosen = false
local _deviceMode = "PC"

local function ApplyDeviceSettings(mode)
    State.DeviceMode = mode
    if mode == "Control" then
        State.GamepadAimEnabled = true
        -- AutoLockAlways se activa solo cuando el usuario lo enciende desde el menú
        -- Si aún tiene teclas de teclado, adaptarlas automáticamente a botones de mando
        if not State.AimbotKey or State.AimbotKey == "V" then State.AimbotKey = "ButtonR1" end
        State.GamepadAimButton = State.AimbotKey
        if not State.TogglePartKey or State.TogglePartKey == "B" then State.TogglePartKey = "DPadUp" end
        if not State.EspKey or State.EspKey == "P" then State.EspKey = "DPadDown" end
        if not State.MenuKey or State.MenuKey == "M" then State.MenuKey = "ButtonSelect" end
        ShowNotification("🎮 Modo Control", "🎯 " .. tostring(State.AimbotKey) .. " = Aimbot | 🔄 " .. tostring(State.TogglePartKey) .. " = Pecho | 👁️ " .. tostring(State.EspKey) .. " = ESP", true)
    elseif mode == "Mobile" then
        State.GamepadAimEnabled = false
        State.AimbotSmoothness = 1.0
        State.GlowTransparency = 0.8
        State.AimbotFOV = 300
        ShowNotification("📱 Modo Móvil", "Optimizado: Anti-Lag 60 FPS + FOV Amplio")
    else
        State.GamepadAimEnabled = false
        State.AimbotSmoothness = 1.0
        if State.AimbotKey and State.AimbotKey:find("Button") then State.AimbotKey = "V" end
        if State.TogglePartKey and State.TogglePartKey:find("DPad") then State.TogglePartKey = "B" end
        if State.EspKey and State.EspKey:find("DPad") then State.EspKey = "P" end
        if State.MenuKey and State.MenuKey:find("Button") then State.MenuKey = "M" end
        ShowNotification("🖥️ Modo PC", "Teclado y Ratón listo (V = Aimbot, B = Cabeza/Pecho, P = Sigilo, M = Menú)")
    end
    pcall(function()
        if SyncUIWithConfig then SyncUIWithConfig() end
    end)
    SaveConfig(true)
end

local function ShowDeviceSelectorAndWait()
    local parentGui = nil
    pcall(function() parentGui = game:GetService("CoreGui") end)
    if not parentGui or not pcall(function() return parentGui.Name end) then
        parentGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 4)
    end
    if not parentGui then
        _deviceChosen = true
        return
    end

    local old = parentGui:FindFirstChild("VIP_DeviceSelector_Gui")
    if old then pcall(function() old:Destroy() end) end

    local sg = Instance.new("ScreenGui")
    sg.Name = "VIP_DeviceSelector_Gui"
    sg.ResetOnSpawn = false
    sg.DisplayOrder = 999999
    sg.Parent = parentGui

    local bg = Instance.new("Frame")
    bg.Name = "Overlay"
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(5, 7, 12)
    bg.BackgroundTransparency = 0.4
    bg.BorderSizePixel = 0
    bg.Parent = sg

    local panel = Instance.new("Frame")
    panel.Name = "Panel"
    panel.AnchorPoint = Vector2.new(0.5, 0.5)
    panel.Position = UDim2.new(0.5, 0, 0.5, 0)
    panel.Size = UDim2.new(0, 420, 0, 330)
    panel.BackgroundColor3 = Color3.fromRGB(14, 16, 24)
    panel.BorderSizePixel = 0
    panel.Parent = sg

    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, 16)
    panelCorner.Parent = panel

    local panelStroke = Instance.new("UIStroke")
    panelStroke.Thickness = 2.5
    panelStroke.Color = Color3.fromRGB(255, 170, 0)
    panelStroke.Parent = panel

    local strokeGrad = Instance.new("UIGradient")
    strokeGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 180, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(160, 60, 255)),
        ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 220, 255)),
        ColorSequenceKeypoint.new(1.0, Color3.fromRGB(255, 180, 0))
    })
    strokeGrad.Parent = panelStroke

    local rotConn
    rotConn = RunService.RenderStepped:Connect(function()
        if strokeGrad and strokeGrad.Parent then
            strokeGrad.Rotation = (strokeGrad.Rotation + 3) % 360
        else
            if rotConn then rotConn:Disconnect() end
        end
    end)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 32)
    title.Position = UDim2.new(0, 0, 0, 16)
    title.BackgroundTransparency = 1
    title.Text = "🍗 HERMANOS ALITAS VIP 🍗"
    title.TextColor3 = Color3.fromRGB(255, 215, 0)
    title.TextSize = 19
    title.Font = Enum.Font.GothamBold
    title.Parent = panel

    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0, 20)
    subtitle.Position = UDim2.new(0, 0, 0, 48)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "¿Con qué vas a jugar hoy? Elige tu modo:"
    subtitle.TextColor3 = Color3.fromRGB(180, 185, 205)
    subtitle.TextSize = 12
    subtitle.Font = Enum.Font.GothamMedium
    subtitle.Parent = panel

    local function MakeBtn(name, text, subtext, yPos, color, mode)
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Size = UDim2.new(0, 360, 0, 60)
        btn.Position = UDim2.new(0.5, -180, 0, yPos)
        btn.BackgroundColor3 = color
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 14
        btn.Font = Enum.Font.GothamBold
        btn.Text = text
        btn.AutoButtonColor = true
        btn.BorderSizePixel = 0
        btn.Parent = panel

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = btn

        local bStroke = Instance.new("UIStroke")
        bStroke.Thickness = 1.2
        bStroke.Color = Color3.fromRGB(255, 255, 255)
        bStroke.Transparency = 0.7
        bStroke.Parent = btn

        local subLbl = Instance.new("TextLabel")
        subLbl.Size = UDim2.new(1, 0, 0, 14)
        subLbl.Position = UDim2.new(0, 0, 1, -20)
        subLbl.BackgroundTransparency = 1
        subLbl.Text = subtext
        subLbl.TextColor3 = Color3.fromRGB(200, 205, 225)
        subLbl.TextSize = 10
        subLbl.Font = Enum.Font.Gotham
        subLbl.Parent = btn

        local function OnPick()
            if _deviceChosen then return end
            _deviceChosen = true
            PlayAlertSound()
            _deviceMode = mode
            ApplyDeviceSettings(mode)
            pcall(function() if rotConn then rotConn:Disconnect() end end)
            pcall(function() sg:Destroy() end)
        end

        btn.MouseButton1Click:Connect(OnPick)
        btn.Activated:Connect(OnPick)
        return btn
    end

    MakeBtn("BtnControl", "🎮  CONTROL / MANDO", "Aimbot R1 + Asignación de botones de mando", 84, Color3.fromRGB(110, 40, 210), "Control")
    MakeBtn("BtnPC", "🖥️  PC GAMER (Teclado y Ratón)", "Aimbot V + Teclas personalizadas", 154, Color3.fromRGB(24, 28, 44), "PC")
    MakeBtn("BtnMobile", "📱  CELULAR / MÓVIL", "Anti-Lag 60 FPS + FOV Amplio", 224, Color3.fromRGB(24, 28, 44), "Mobile")

end

-- Cargar configuración inicial sin bloquear el hilo principal
ApplyDeviceSettings(State.DeviceMode or "PC")
task.spawn(function()
    pcall(ShowDeviceSelectorAndWait)
end)

-- --------------------------------------------------------------------
-- 🎨 MENÚ KAVO (se crea DESPUÉS de elegir dispositivo)
-- --------------------------------------------------------------------

local VIPTheme = {
    SchemeColor = Color3.fromRGB(0, 245, 180),    -- Neon Cyber Cyan / Toxic Emerald (Estilo Cylex / FiveM / Neverlose)
    Background = Color3.fromRGB(11, 14, 22),     -- Deep Midnight Obsidian
    Header = Color3.fromRGB(8, 10, 16),          -- Dark Cyber Shadow
    TextColor = Color3.fromRGB(240, 248, 255),   -- Crisp Ice White
    ElementColor = Color3.fromRGB(16, 22, 34)    -- Frosted Cyber Glass
}

local Window = Library.CreateLib("🍗 Hermanos alitas de pollo 🍗", VIPTheme)

-- 🌟 DECORADOR Y SKINS CYBER-HACK (Estilo Cylex / Neverlose / FiveM)
local function DecorateKavoUI()
    pcall(function()
        local parentGui = nil
        pcall(function() parentGui = game:GetService("CoreGui") end)
        if not parentGui then
            parentGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        end
        if not parentGui then return end

        local gui = nil
        for _, c in ipairs(parentGui:GetChildren()) do
            if c:IsA("ScreenGui") and c:FindFirstChild("Main") then
                gui = c
                break
            end
        end
        if not gui then return end

        local main = gui:FindFirstChild("Main")
        if not main then return end

        -- Fondo oscuro matrix
        main.BackgroundColor3 = Color3.fromRGB(5, 9, 18)

        -- Gradiente fondo
        if not main:FindFirstChild("_VBG") then
            local g = Instance.new("UIGradient")
            g.Name = "_VBG"
            g.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 18, 30)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(2, 12, 22))
            })
            g.Rotation = 135
            g.Parent = main
        end

        -- Borde neon rotatorio
        if not main:FindFirstChild("_VSK") then
            local sk = Instance.new("UIStroke")
            sk.Name = "_VSK"
            sk.Thickness = 2.5
            sk.Color = Color3.fromRGB(0, 245, 180)
            sk.Parent = main
            local sg = Instance.new("UIGradient")
            sg.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0,    Color3.fromRGB(0, 245, 180)),
                ColorSequenceKeypoint.new(0.25, Color3.fromRGB(0, 190, 255)),
                ColorSequenceKeypoint.new(0.5,  Color3.fromRGB(80, 255, 160)),
                ColorSequenceKeypoint.new(0.75, Color3.fromRGB(0, 190, 255)),
                ColorSequenceKeypoint.new(1,    Color3.fromRGB(0, 245, 180))
            })
            sg.Parent = sk
            local rc
            rc = RunService.RenderStepped:Connect(function()
                if sg and sg.Parent then
                    sg.Rotation = (sg.Rotation + 2) % 360
                else
                    pcall(function() rc:Disconnect() end)
                end
            end)
        end

        -- Corner brackets 4 esquinas
        if not main:FindFirstChild("_VCR") then
            local mk = Instance.new("BoolValue")
            mk.Name = "_VCR"
            mk.Parent = main
            local C = Color3.fromRGB(0, 245, 180)
            local function Bar(sz, pos)
                local f = Instance.new("Frame")
                f.Size = sz
                f.Position = pos
                f.BackgroundColor3 = C
                f.BorderSizePixel = 0
                f.ZIndex = 20
                f.Parent = main
            end
            Bar(UDim2.new(0,16,0,2), UDim2.new(0,3,0,3))
            Bar(UDim2.new(0,2,0,16), UDim2.new(0,3,0,3))
            Bar(UDim2.new(0,16,0,2), UDim2.new(1,-19,0,3))
            Bar(UDim2.new(0,2,0,16), UDim2.new(1,-5,0,3))
            Bar(UDim2.new(0,16,0,2), UDim2.new(0,3,1,-5))
            Bar(UDim2.new(0,2,0,16), UDim2.new(0,3,1,-19))
            Bar(UDim2.new(0,16,0,2), UDim2.new(1,-19,1,-5))
            Bar(UDim2.new(0,2,0,16), UDim2.new(1,-5,1,-19))
        end

        -- Header
        local header = main:FindFirstChild("MainHeader")
        if header then
            header.BackgroundColor3 = Color3.fromRGB(0, 14, 25)
            local title = header:FindFirstChild("title")
            if title and title:IsA("TextLabel") then
                title.Text = "  ALITAS VIP // CYBER HACK [v12.3]"
                title.Font = Enum.Font.GothamBold
                title.TextColor3 = Color3.fromRGB(0, 245, 180)
                title.TextSize = 12
            end
            if not header:FindFirstChild("_VGL") then
                local ln = Instance.new("Frame")
                ln.Name = "_VGL"
                ln.Size = UDim2.new(1, 0, 0, 2)
                ln.Position = UDim2.new(0, 0, 1, -2)
                ln.BackgroundColor3 = Color3.fromRGB(0, 245, 180)
                ln.BorderSizePixel = 0
                ln.ZIndex = 10
                ln.Parent = header
                local lg = Instance.new("UIGradient")
                lg.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0,    Color3.fromRGB(0, 20, 15)),
                    ColorSequenceKeypoint.new(0.35, Color3.fromRGB(0, 245, 180)),
                    ColorSequenceKeypoint.new(0.65, Color3.fromRGB(0, 200, 255)),
                    ColorSequenceKeypoint.new(1,    Color3.fromRGB(0, 20, 15))
                })
                lg.Parent = ln
            end
            if not header:FindFirstChild("_VON") then
                local bd = Instance.new("TextLabel")
                bd.Name = "_VON"
                bd.Size = UDim2.new(0, 80, 0, 16)
                bd.Position = UDim2.new(1, -84, 0.5, -8)
                bd.BackgroundColor3 = Color3.fromRGB(0, 22, 16)
                bd.BorderSizePixel = 0
                bd.Font = Enum.Font.Code
                bd.Text = "O ONLINE"
                bd.TextColor3 = Color3.fromRGB(0, 245, 180)
                bd.TextSize = 10
                bd.ZIndex = 10
                bd.Parent = header
                local bkc = Instance.new("UICorner")
                bkc.CornerRadius = UDim.new(0, 4)
                bkc.Parent = bd
                local bks = Instance.new("UIStroke")
                bks.Color = Color3.fromRGB(0, 245, 180)
                bks.Thickness = 1
                bks.Transparency = 0.5
                bks.Parent = bd
                local bt = 0
                local bo = true
                local bdc
                bdc = RunService.Heartbeat:Connect(function(dt)
                    if bd and bd.Parent then
                        bt = bt + dt
                        if bt >= 0.8 then
                            bt = 0
                            bo = not bo
                            bd.TextTransparency = bo and 0 or 0.6
                        end
                    else
                        pcall(function() bdc:Disconnect() end)
                    end
                end)
            end
        end

        -- Sidebar
        local side = main:FindFirstChild("MainSide")
        if side then
            side.BackgroundColor3 = Color3.fromRGB(3, 7, 16)
            if not side:FindFirstChild("_VSD") then
                local dv = Instance.new("Frame")
                dv.Name = "_VSD"
                dv.Size = UDim2.new(0, 1, 1, 0)
                dv.Position = UDim2.new(1, -1, 0, 0)
                dv.BackgroundColor3 = Color3.fromRGB(0, 245, 180)
                dv.BackgroundTransparency = 0.35
                dv.BorderSizePixel = 0
                dv.ZIndex = 10
                dv.Parent = side
            end
            for _, btn in ipairs(side:GetDescendants()) do
                if btn:IsA("TextButton") and not btn:FindFirstChild("_vd") then
                    local m2 = Instance.new("BoolValue")
                    m2.Name = "_vd"
                    m2.Parent = btn
                    btn.BackgroundColor3 = Color3.fromRGB(6, 12, 22)
                    btn.TextColor3 = Color3.fromRGB(145, 220, 200)
                    btn.Font = Enum.Font.GothamSemibold
                    btn.MouseEnter:Connect(function()
                        btn.BackgroundColor3 = Color3.fromRGB(0, 35, 28)
                        btn.TextColor3 = Color3.fromRGB(0, 245, 180)
                    end)
                    btn.MouseLeave:Connect(function()
                        btn.BackgroundColor3 = Color3.fromRGB(6, 12, 22)
                        btn.TextColor3 = Color3.fromRGB(145, 220, 200)
                    end)
                end
            end
            if not side:FindFirstChild("_VPC") then
                local card = Instance.new("Frame")
                card.Name = "_VPC"
                card.Size = UDim2.new(1, -10, 0, 48)
                card.Position = UDim2.new(0, 5, 1, -54)
                card.BackgroundColor3 = Color3.fromRGB(0, 16, 12)
                card.BorderSizePixel = 0
                card.ZIndex = 8
                card.Parent = side
                local cc = Instance.new("UICorner")
                cc.CornerRadius = UDim.new(0, 8)
                cc.Parent = card
                local cs = Instance.new("UIStroke")
                cs.Thickness = 1.5
                cs.Color = Color3.fromRGB(0, 245, 180)
                cs.Transparency = 0.3
                cs.Parent = card
                local av = Instance.new("ImageLabel")
                av.Size = UDim2.new(0, 32, 0, 32)
                av.Position = UDim2.new(0, 6, 0.5, -16)
                av.BackgroundTransparency = 1
                av.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LocalPlayer.UserId) .. "&w=100&h=100"
                av.ZIndex = 9
                av.Parent = card
                local avc = Instance.new("UICorner")
                avc.CornerRadius = UDim.new(1, 0)
                avc.Parent = av
                local avs = Instance.new("UIStroke")
                avs.Thickness = 1.5
                avs.Color = Color3.fromRGB(0, 245, 180)
                avs.Parent = av
                local un = Instance.new("TextLabel")
                un.Size = UDim2.new(1, -46, 0, 15)
                un.Position = UDim2.new(0, 44, 0, 8)
                un.BackgroundTransparency = 1
                un.Font = Enum.Font.GothamBold
                un.Text = "@" .. LocalPlayer.Name
                un.TextColor3 = Color3.fromRGB(200, 255, 235)
                un.TextSize = 10
                un.TextXAlignment = Enum.TextXAlignment.Left
                un.ZIndex = 9
                un.Parent = card
                local rb = Instance.new("TextLabel")
                rb.Size = UDim2.new(1, -46, 0, 14)
                rb.Position = UDim2.new(0, 44, 0, 24)
                rb.BackgroundTransparency = 1
                rb.Font = Enum.Font.GothamBold
                local isOwner = (LocalPlayer.Name:lower() == OWNER_NAME:lower())
                rb.Text = isOwner and "[OWNER]" or "[VIP] CYBER"
                rb.TextColor3 = isOwner and Color3.fromRGB(255, 200, 50) or Color3.fromRGB(0, 245, 180)
                rb.TextSize = 9
                rb.TextXAlignment = Enum.TextXAlignment.Left
                rb.ZIndex = 9
                rb.Parent = card
            end
        end

        -- Panel de contenido
        for _, child in ipairs(main:GetChildren()) do
            if child:IsA("Frame") and child.Name ~= "MainHeader" and child.Name ~= "MainSide" and not child.Name:find("_V") and child.BackgroundTransparency < 1 then
                local hasScroll = false
                for _, sc in ipairs(child:GetChildren()) do
                    if sc:IsA("ScrollingFrame") then
                        hasScroll = true
                        break
                    end
                end
                if hasScroll then
                    child.BackgroundColor3 = Color3.fromRGB(6, 10, 20)
                    for _, sf in ipairs(child:GetDescendants()) do
                        if sf:IsA("ScrollingFrame") then
                            sf.BackgroundColor3 = Color3.fromRGB(5, 10, 20)
                            sf.ScrollBarThickness = 3
                            sf.ScrollBarImageColor3 = Color3.fromRGB(0, 245, 180)
                        end
                    end
                end
            end
        end

        -- Particulas flotantes
        if not main:FindFirstChild("_VP") then
            local pc = Instance.new("Frame")
            pc.Name = "_VP"
            pc.Size = UDim2.new(1, 0, 1, 0)
            pc.BackgroundTransparency = 1
            pc.BorderSizePixel = 0
            pc.ClipsDescendants = true
            pc.ZIndex = 15
            pc.Parent = main
            local dd = {{0.76,0.28,5},{0.84,0.68,3},{0.71,0.48,4},{0.80,0.14,3},{0.92,0.44,4},{0.87,0.82,3}}
            for i = 1, #dd do
                local d = dd[i]
                local dt = Instance.new("Frame")
                dt.Name = "P" .. i
                dt.Size = UDim2.new(0, d[3], 0, d[3])
                dt.Position = UDim2.new(d[1], 0, d[2], 0)
                dt.BackgroundColor3 = (i % 2 == 0) and Color3.fromRGB(0, 245, 180) or Color3.fromRGB(0, 180, 255)
                dt.BackgroundTransparency = 0.3
                dt.BorderSizePixel = 0
                dt.ZIndex = 15
                dt.Parent = pc
                local dc2 = Instance.new("UICorner")
                dc2.CornerRadius = UDim.new(1, 0)
                dc2.Parent = dt
                local bY = d[2]
                local off = i * 0.55
                local rc2
                rc2 = RunService.RenderStepped:Connect(function()
                    if dt and dt.Parent then
                        local t = tick() + off
                        dt.Position = UDim2.new(d[1], 0, math.clamp(bY + math.sin(t * 0.5) * 0.03, 0, 0.97), 0)
                        dt.BackgroundTransparency = 0.2 + math.abs(math.sin(t * 0.7)) * 0.55
                    else
                        pcall(function() rc2:Disconnect() end)
                    end
                end)
            end
        end
    end)
end

task.spawn(function()
    for _ = 1, 10 do
        task.wait(0.4)
        DecorateKavoUI()
    end
end)

-- 🌟 WATERMARK HUD EN PANTALLA
local WatermarkGui = nil
local function CreateWatermarkHUD()
    pcall(function()
        local parentGui = nil
        pcall(function() parentGui = game:GetService("CoreGui") end)
        if not parentGui or not pcall(function() return parentGui.Name end) then
            parentGui = LocalPlayer:WaitForChild("PlayerGui", 5)
        end
        if not parentGui then return end

        local old = parentGui:FindFirstChild("Alitas_Watermark_Gui")
        if old then old:Destroy() end

        local sg = Instance.new("ScreenGui")
        sg.Name = "Alitas_Watermark_Gui"
        sg.ResetOnSpawn = false
        sg.DisplayOrder = 9999
        sg.Parent = parentGui
        WatermarkGui = sg

        local frame = Instance.new("Frame")
        frame.Name = "WatermarkFrame"
        frame.Size = UDim2.new(0, 370, 0, 26)
        frame.Position = UDim2.new(1, -380, 0, 10)
        frame.BackgroundColor3 = Color3.fromRGB(15, 17, 24)
        frame.BackgroundTransparency = 0.2
        frame.BorderSizePixel = 0
        frame.Parent = sg

        local corn = Instance.new("UICorner")
        corn.CornerRadius = UDim.new(0, 6)
        corn.Parent = frame

        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 1.2
        stroke.Color = Color3.fromRGB(0, 245, 180)
        stroke.Transparency = 0.3
        stroke.Parent = frame

        local lbl = Instance.new("TextLabel")
        lbl.Name = "WatermarkText"
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 10
        lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        lbl.Parent = frame

        local fpsCount = 0
        local lastTime = tick()
        local currentFps = 60

        local wmConn = RunService.RenderStepped:Connect(function()
            fpsCount = fpsCount + 1
            local now = tick()
            if now - lastTime >= 1 then
                currentFps = fpsCount
                fpsCount = 0
                lastTime = now
            end

            local ping = 0
            if ping <= 0 then ping = math.floor(Workspace:GetRealPhysicsFPS()) end

            local roleTag = (LocalPlayer.Name:lower() == OWNER_NAME:lower()) and "👑 OWNER" or "💎 VIP"
            local partLabel = (State.TargetPart == "UpperTorso" or State.TargetPart == "Pecho") and "👕 PECHO" or "🧠 CABEZA"
            local povTag = State.AutoLockAlways and " | 🎯 POV ON" or ""
            lbl.Text = " ⚡ ALITAS VIP | FPS: " .. tostring(currentFps) .. " | " .. partLabel .. povTag .. " | " .. roleTag .. " "
        end)
        table.insert(Cleanups, wmConn)
        table.insert(Cleanups, function() pcall(function() sg:Destroy() end) end)
    end)
end

task.spawn(CreateWatermarkHUD)


local menuConn = UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe then
        local key = Enum.KeyCode[State.MenuKey] or Enum.KeyCode.M
        if input.KeyCode == key then Library:ToggleUI() end
    end
end)
table.insert(Cleanups, menuConn)

local watermarkHotKeyConn = UserInputService.InputBegan:Connect(function(input, gpe)
    local isGp = input.UserInputType.Name:find("Gamepad")
    if (not gpe or isGp) and UserInputService:GetFocusedTextBox() == nil then
        local wmKeyName = (State.WatermarkKey or "K"):upper()
        local curKeyName = input.KeyCode and input.KeyCode.Name:upper()
        if curKeyName == wmKeyName then
            local newState = not (WatermarkGui and WatermarkGui.Enabled)
            if WatermarkGui then
                WatermarkGui.Enabled = newState
            end
            if UI_Toggles.ShowWatermark and UI_Toggles.ShowWatermark.UpdateToggle then
                UI_Toggles.ShowWatermark:UpdateToggle(nil, newState)
            end
            ShowNotification("⚡ Watermark VIP", newState and ("✅ Watermark Activado [" .. wmKeyName .. "]") or ("❌ Watermark Ocultado [" .. wmKeyName .. "]"))
        end
    end
end)
table.insert(Cleanups, watermarkHotKeyConn)

local stealthHotKeyConn = UserInputService.InputBegan:Connect(function(input, gpe)
    local isGp = input.UserInputType.Name:find("Gamepad")
    if (not gpe or isGp) and UserInputService:GetFocusedTextBox() == nil then
        local espKeyName = (State.EspKey or "P"):upper()
        local curKeyName = input.KeyCode and input.KeyCode.Name:upper()
        if curKeyName == espKeyName then
            local active = (State.EspGlow or State.EspShowNames or State.EspShowHealth or State.EspShowWeapons)
            local newState = not active
            State.EspGlow = newState
            State.EspShowNames = newState
            State.EspShowHealth = newState
            State.EspShowWeapons = newState
            for _, hl in pairs(ESPHighlights) do if hl then hl.Enabled = newState end end
            for _, bb in pairs(ESPBillboards) do if bb then bb.Enabled = newState end end
            if UI_Toggles.EspGlow then UI_Toggles.EspGlow:UpdateToggle(nil, newState) end
            if UI_Toggles.EspShowNames then UI_Toggles.EspShowNames:UpdateToggle(nil, newState) end
            if UI_Toggles.EspShowHealth then UI_Toggles.EspShowHealth:UpdateToggle(nil, newState) end
            if UI_Toggles.EspShowWeapons then UI_Toggles.EspShowWeapons:UpdateToggle(nil, newState) end
            ShowNotification("🕵️ Sigilo (Tecla " .. tostring(State.EspKey) .. ")", newState and "👁️ ESP Activado" or "🙈 ESP Ocultado al instante")
        end
    end
end)
table.insert(Cleanups, stealthHotKeyConn)

local function GetScreenCenter()
    local vp = Camera.ViewportSize
    return Vector2.new(vp.X / 2, vp.Y / 2)
end

-- --------------------------------------------------------------------
-- 🎯 3. CÍRCULO FOV & INDICADOR VISUAL (100% VISIBLE SCREENGUI ENGINE)
local FOVScreenGui = nil
local FOVFrame = nil
local FOVStroke = nil
local TargetDotFrame = nil

pcall(function()
    local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 4)
    if pg then
        local old = pg:FindFirstChild("Alitas_FOVCircle_Gui")
        if old then old:Destroy() end

        FOVScreenGui = Instance.new("ScreenGui")
        FOVScreenGui.Name = "Alitas_FOVCircle_Gui"
        FOVScreenGui.ResetOnSpawn = false
        FOVScreenGui.DisplayOrder = 99999
        FOVScreenGui.Parent = pg

        FOVFrame = Instance.new("Frame")
        FOVFrame.Name = "FOVCircle"
        FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        FOVFrame.Size = UDim2.new(0, (State.AimbotFOV or 250) * 2, 0, (State.AimbotFOV or 250) * 2)
        FOVFrame.BackgroundTransparency = 1
        FOVFrame.Parent = FOVScreenGui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = FOVFrame

        FOVStroke = Instance.new("UIStroke")
        FOVStroke.Thickness = 2
        FOVStroke.Color = State.FOVColor or Color3.fromRGB(160, 60, 255)
        FOVStroke.Transparency = 0
        FOVStroke.Parent = FOVFrame

        TargetDotFrame = Instance.new("Frame")
        TargetDotFrame.Name = "TargetDot"
        TargetDotFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        TargetDotFrame.Size = UDim2.new(0, 10, 0, 10)
        TargetDotFrame.BackgroundColor3 = State.TargetDotColor or Color3.fromRGB(255, 45, 85)
        TargetDotFrame.Visible = false
        TargetDotFrame.Parent = FOVScreenGui

        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(1, 0)
        dotCorner.Parent = TargetDotFrame

        table.insert(Cleanups, function() pcall(function() FOVScreenGui:Destroy() end) end)
    end
end)

-- --------------------------------------------------------------------
-- 👥 4. VERIFICACIÓN DE ALIADOS
-- --------------------------------------------------------------------
local FriendsCache = {}
local function CacheFriendStatus(p)
    if not p or p == LocalPlayer then return end
    pcall(function()
        FriendsCache[p.UserId] = LocalPlayer:IsFriendsWith(p.UserId)
    end)
end

for _, p in ipairs(Players:GetPlayers()) do task.spawn(function() CacheFriendStatus(p) end) end
local fAddConn = Players.PlayerAdded:Connect(function(p) task.spawn(function() CacheFriendStatus(p) end) end)
local fRemConn = Players.PlayerRemoving:Connect(function(p) FriendsCache[p.UserId] = nil end)
table.insert(Cleanups, fAddConn)
table.insert(Cleanups, fRemConn)

local function IsPlayerIgnored(player)
    if not player or player == LocalPlayer then return true end

    local pName = player.Name:lower()
    local dName = player.DisplayName:lower()
    if State.IgnoredPlayers[pName] or State.IgnoredPlayers[dName] then return true end

    if State.IgnoreFriends then
        if FriendsCache[player.UserId] ~= nil then
            if FriendsCache[player.UserId] == true then return true end
        else
            task.spawn(function() CacheFriendStatus(player) end)
        end
    end

    if State.TeamCheck and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
        return true
    end

    return false
end

-- --------------------------------------------------------------------
-- 🎯 5. DETECCIÓN ROBUSTA DE VEHÍCULO & AIMBOT INTELIGENTE
-- --------------------------------------------------------------------
local function GetAimPart(character)
    if not character then return nil end

    -- 🛡️ Modo Protección Anti-Cheat: A corta distancia (< 35 studs) cambia automáticamente a Pecho
    if State.AntiCheatSafety and LocalPlayer.Character then
        local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Head")
        local tRoot = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
        if myRoot and tRoot then
            local dist = (tRoot.Position - myRoot.Position).Magnitude
            if dist < 35 then
                return character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso") or character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
            end
        end
    end

    if State.TargetPart == "UpperTorso" or State.TargetPart == "Pecho" or State.TargetPart == "Torso" or State.TargetPart == "HumanoidRootPart" then
        return character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso") or character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
    else
        return character:FindFirstChild("Head") or character:FindFirstChild("UpperTorso") or character:FindFirstChild("HumanoidRootPart")
    end
end

local function IsDrivingOrSitting()
    local myChar = LocalPlayer.Character
    if not myChar then return false end
    local hum = myChar:FindFirstChildOfClass("Humanoid")
    if hum then
        if hum.Sit == true or hum.SeatPart ~= nil or hum.PlatformStand == true then
            return true
        end
        local st = hum:GetState()
        if st == Enum.HumanoidStateType.Seated or st == Enum.HumanoidStateType.PlatformStanding then
            return true
        end
    end
    local cs = Camera.CameraSubject
    if cs and hum and cs ~= hum and cs ~= myChar:FindFirstChild("Head") then
        return true
    end
    return false
end

local function GetClosestTarget(excludePlayer)
    local target = nil
    local minDistance = State.AimbotFOV
    local center = GetScreenCenter()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= excludePlayer and not IsPlayerIgnored(player) and player.Character then
            local char = player.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 1 then
                local part = GetAimPart(char)
                if part then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen and screenPos.Z > 0 then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if dist < minDistance then
                            minDistance = dist
                            target = player
                        end
                    end
                end
            end
        end
    end
    return target
end

local function IsTargetValid(target)
    if not target or not target.Parent or not target.Character then return false end
    if IsPlayerIgnored(target) then return false end
    local hum = target.Character:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    local part = GetAimPart(target.Character)
    if not part or not part.Parent then return false end

    -- Una vez apuntado, NO se despega aunque se mueva rápido o salte,
    -- solo se suelta si muere, sale del server o si lo desactivas con V/R1.
    return true
end

local function ReleaseCamera()
    if Camera.CameraType == Enum.CameraType.Scriptable then
        Camera.CameraType = Enum.CameraType.Custom
    end
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then Camera.CameraSubject = hum end
    end
end

local function ToggleAimbot()
    if not State.Aimbot then return end
    State.IsLocked = not State.IsLocked
    if not State.IsLocked then
        State.LockedTarget = nil
        ReleaseCamera()
    else
        if IsDrivingOrSitting() and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then Camera.CameraSubject = hum end
        end
        State.LockedTarget = GetClosestTarget()
    end
end

local aimInputConn = UserInputService.InputBegan:Connect(function(input, gpe)
    local isGp = input.UserInputType.Name:find("Gamepad")
    -- Si es botón de mando o teclado libre
    if (not gpe or isGp) and UserInputService:GetFocusedTextBox() == nil then
        local aimKeyName = (State.AimbotKey or "V"):upper()
        local curKeyName = input.KeyCode and input.KeyCode.Name:upper()
        if (curKeyName == aimKeyName)
           or (aimKeyName == "MOUSEBUTTON2" and input.UserInputType == Enum.UserInputType.MouseButton2)
           or (aimKeyName == "MOUSEBUTTON1" and input.UserInputType == Enum.UserInputType.MouseButton1) then
            ToggleAimbot()
        end

        -- (toggle cabeza/pecho movido a handler dedicado)
    end
end)
table.insert(Cleanups, aimInputConn)

-- 🔄 HANDLER DEDICADO: Toggle Cabeza/Pecho (Teclado B + Control DPadUp / Asignado, SIN NOTIFICACIONES)
local togglePartConn = UserInputService.InputBegan:Connect(function(input, gpe)
    if UserInputService:GetFocusedTextBox() ~= nil then return end

    local targetKey = (State.TogglePartKey or "B"):upper()
    local matched = false

    if input.KeyCode and input.KeyCode.Name ~= "Unknown" then
        local kn = input.KeyCode.Name:upper()
        if kn == targetKey then
            matched = true
        end
    end

    if not matched and input.UserInputType then
        local uit = input.UserInputType.Name:upper()
        if uit == targetKey then
            matched = true
        end
    end

    if matched then
        if State.TargetPart == "Head" then
            State.TargetPart = "UpperTorso"
        else
            State.TargetPart = "Head"
        end
        SaveConfig(false)
    end
end)
table.insert(Cleanups, togglePartConn)
-- [VIP_TOGGLE_PART_HANDLER]

-- ⏱️ BUCLE: Alternar automáticamente Cabeza / Pecho cada 1 segundo
local _autoSwitchLoop = true
task.spawn(function()
    while _autoSwitchLoop do
        task.wait(1)
        if State.AutoSwitchPart then
            if State.TargetPart == "Head" then
                State.TargetPart = "UpperTorso"
            else
                State.TargetPart = "Head"
            end
        end
    end
end)
table.insert(Cleanups, function() _autoSwitchLoop = false end)

-- (AutoClicker removido)

-- 🎮 GAMEPAD: polling confiable por Heartbeat (evita bloqueo de gpe)
local gpWasDown = false
local _gpFrame = 0
local gpPollConn = RunService.Heartbeat:Connect(function()
    _gpFrame = _gpFrame + 1
    if _gpFrame % 4 ~= 0 then return end
    if not State.GamepadAimEnabled or not State.GamepadAimButton then
        gpWasDown = false
        return
    end
    if UserInputService:GetFocusedTextBox() ~= nil then return end

    local gpKey = Enum.KeyCode[State.GamepadAimButton]
    if not gpKey then return end

    local isDown = false
    pcall(function()
        isDown = UserInputService:IsGamepadButtonDown(Enum.UserInputType.Gamepad1, gpKey)
    end)

    -- Solo activa en el momento exacto que presionas (no al mantener)
    if isDown and not gpWasDown then
        ToggleAimbot()
    end
    gpWasDown = isDown
end)
table.insert(Cleanups, gpPollConn)

-- (gpPartConn removed: safe input handling)


local function SetupVehicleAutoUpdate(char)
    if not char then return end
    local hum = char:WaitForChild("Humanoid", 4) or char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    local function TriggerVehicleSync(isSeated)
        task.wait(0.04)
        if hum and Camera.CameraSubject ~= hum then
            Camera.CameraSubject = hum
        end
        if State.IsLocked then
            State.LockedTarget = nil
            State.LockedTarget = GetClosestTarget()
        end
    end

    local s1 = hum.Seated:Connect(function(active) TriggerVehicleSync(active) end)
    local s2 = hum:GetPropertyChangedSignal("Sit"):Connect(function() TriggerVehicleSync(hum.Sit) end)
    local s3 = hum:GetPropertyChangedSignal("SeatPart"):Connect(function() TriggerVehicleSync(hum.SeatPart ~= nil) end)
    table.insert(Cleanups, s1)
    table.insert(Cleanups, s2)
    table.insert(Cleanups, s3)
end

if LocalPlayer.Character then SetupVehicleAutoUpdate(LocalPlayer.Character) end
local vCharConn = LocalPlayer.CharacterAdded:Connect(SetupVehicleAutoUpdate)
table.insert(Cleanups, vCharConn)

local wasDriving = false
local _aimbotFrame = 0  -- contador de frames para throttle
local _cachedCenter = Vector2.new(0, 0)
local _lastFovRadius = -1
local _lastFovColor  = nil
local _lastIsLocked  = nil

-- 🕹️ DETECTOR DE MOVIMIENTO MANUAL DE CÁMARA (Para desenganchar / cambiar de enemigo fácilmente en POV)
local _lastSteerTick = 0
local _steerThresholdTime = 0.25

local steerMouseConn = UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        -- Alta sensibilidad al mover el ratón para soltar o cambiar de enemigo al instante
        if input.Delta.Magnitude > 1.8 then
            _lastSteerTick = tick()
        end
    end
end)
table.insert(Cleanups, steerMouseConn)

local function IsPlayerManuallySteering()
    -- Revisar movimiento reciente de ratón con alta sensibilidad
    if tick() - _lastSteerTick < _steerThresholdTime then
        return true
    end

    -- Revisar palanca derecha del control (Thumbstick2 - sensible para cambiar de enemigo al toque)
    local stickMoved = false
    pcall(function()
        if UserInputService.GamepadEnabled then
            local states = UserInputService:GetGamepadState(Enum.UserInputType.Gamepad1)
            for _, s in ipairs(states) do
                if s.KeyCode == Enum.KeyCode.Thumbstick2 then
                    if Vector2.new(s.Position.X, s.Position.Y).Magnitude > 0.12 then
                        stickMoved = true
                    end
                    break
                end
            end
        end
    end)
    return stickMoved
end

pcall(function() RunService:UnbindFromRenderStep("VIP_UnifiedAimbot") end)
RunService:BindToRenderStep("VIP_UnifiedAimbot", Enum.RenderPriority.Camera.Value + 200, function()
    local vp = Camera.ViewportSize
    local center = Vector2.new(vp.X * 0.5, vp.Y * 0.5)

    -- FOV circle: siempre visible y centrado sin parpadeos
    if FOVFrame and FOVStroke then
        local isShow = (State and State.ShowFOV and State.Aimbot)
        FOVFrame.Visible = isShow
        local diameter = (State and State.AimbotFOV or 250) * 2
        FOVFrame.Size = UDim2.new(0, diameter, 0, diameter)
        FOVStroke.Color = (State and State.IsLocked) and Color3.fromRGB(255, 45, 85) or (State and State.FOVColor or Color3.fromRGB(160, 60, 255))
    end

    local myChar = LocalPlayer.Character
    if not myChar then return end
    local myHum = myChar:FindFirstChildOfClass("Humanoid")

    local dotRendered = false
    local inCar = IsDrivingOrSitting()

    -- Manejo suave de transición de vehículo
    if inCar ~= wasDriving then
        wasDriving = inCar
        if myHum and Camera.CameraSubject ~= myHum then
            Camera.CameraSubject = myHum
        end
    end

        -- 🧲 CONDICIÓN DE APUNTADO: Con botón o en modo POV continuo (AutoLockAlways)
    local shouldLock = State.Aimbot and (State.IsLocked or State.AutoLockAlways)
    if shouldLock then
        local userSteering = IsPlayerManuallySteering()

        if State.AutoLockAlways then
            -- 🎯 MODO POV INTELIGENTE:
            -- Si el jugador mueve el stick o ratón para cambiar de enemigo o voltearse:
            if userSteering then
                -- Buscar de inmediato si hay otro enemigo hacia la nueva dirección
                local nextTarget = GetClosestTarget(State.LockedTarget)
                if nextTarget then
                    State.LockedTarget = nextTarget
                else
                    -- Si mueve la palanca/ratón para salir o no hay nadie al frente, soltar completamente para cero resistencia
                    State.LockedTarget = nil
                end
            else
                -- Si no está moviendo la palanca, fijar o mantener al más cercano
                if not IsTargetValid(State.LockedTarget) then
                    State.LockedTarget = GetClosestTarget()
                end
            end
        else
            -- 🧲 MODO BOTÓN NORMAL: Mantiene 100% fijo a su objetivo
            if not IsTargetValid(State.LockedTarget) then
                State.LockedTarget = GetClosestTarget()
            end
        end

        if State.LockedTarget and IsTargetValid(State.LockedTarget) then
            local tChar = State.LockedTarget.Character
            local aimPart = GetAimPart(tChar)
            if aimPart then
                if TargetDot and State.ShowTargetDot then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(aimPart.Position)
                    if onScreen and screenPos.Z > 0 then
                        TargetDot.Visible = true
                        TargetDot.Position = Vector2.new(screenPos.X, screenPos.Y)
                        dotRendered = true
                    end
                end

                local camPos = Camera.CFrame.Position
                local targetPos = aimPart.Position
                local targetLook = CFrame.new(camPos, targetPos)

                -- 🧲 100% CRAKEADO DIRECTO A LA CABEZA / PECHO
                -- Clavado al 100% para no errar balas; al mover el control o ratón se suelta de inmediato
                Camera.CFrame = targetLook
            end
        end
    end

    if TargetDot and not dotRendered then
        TargetDot.Visible = false
    end
end)
table.insert(Cleanups, function() pcall(function() RunService:UnbindFromRenderStep("VIP_UnifiedAimbot") end) end)

-- --------------------------------------------------------------------
-- ⚡ 6. 0 RECOIL & 0 ARMA TIEMBLO (CERO RETROCESO DE CÁMARA Y ARMA)
-- --------------------------------------------------------------------
local function NeutralizeWeaponRecoil(tool)
    if not tool or not tool:IsA("Tool") then return end

    -- 1. Modificar valores numéricos de retroceso, temblor y dispersión
    for _, item in ipairs(tool:GetDescendants()) do
        if item:IsA("NumberValue") or item:IsA("IntValue") or item:IsA("DoubleConstrainedValue") then
            local n = item.Name:lower()
            if not (n:find("delay") or n:find("cool") or n:find("ammo") or n:find("rate") or n:find("speed") or n:find("time") or n:find("damage") or n:find("range")) then
                if n:find("recoil") or n:find("kick") or n:find("shake") or n:find("sway") or n:find("camshake") or n:find("spread") or n:find("dispersion") or n:find("pellet") or n:find("bob") or n:find("tremble") or n:find("vibration") then
                    pcall(function() item.Value = 0 end)
                end
            end
        elseif item:IsA("Vector3Value") then
            local n = item.Name:lower()
            if n:find("recoil") or n:find("shake") or n:find("sway") or n:find("kick") or n:find("bob") then
                pcall(function() item.Value = Vector3.new(0, 0, 0) end)
            end
        end
    end

    -- 2. Atributos de Tool (Frameworks modernos de armas)
    pcall(function()
        for attrName, _ in pairs(tool:GetAttributes()) do
            local low = attrName:lower()
            if low:find("recoil") or low:find("kick") or low:find("shake") or low:find("spread") or low:find("sway") or low:find("rotational") or low:find("visual") or low:find("pellet") or low:find("dispersion") or low:find("bob") then
                tool:SetAttribute(attrName, 0)
            end
        end
    end)

    -- 3. Configuración en ModuleScripts de configuración del arma (GunConfig, Setting, etc.)
    for _, mod in ipairs(tool:GetDescendants()) do
        if mod:IsA("ModuleScript") then
            pcall(function()
                local data = require(mod)
                if type(data) == "table" then
                    for k, v in pairs(data) do
                        local kLow = tostring(k):lower()
                        if kLow:find("recoil") or kLow:find("kick") or kLow:find("shake") or kLow:find("sway") or kLow:find("spread") or kLow:find("dispersion") or kLow:find("camshake") then
                            if type(v) == "number" then
                                data[k] = 0
                            elseif type(v) == "table" then
                                for subK, _ in pairs(v) do
                                    if type(v[subK]) == "number" then v[subK] = 0 end
                                end
                            elseif typeof(v) == "Vector3" then
                                data[k] = Vector3.new(0, 0, 0)
                            end
                        end
                    end
                end
            end)
        end
    end
end

-- 4. Bucle activo para detener cualquier animación o resorte de temblor en el brazo y arma
local _noWeaponShakeConn = nil
local function HookCharacterRecoil(char)
    if not char then return end

    local cAdded = char.ChildAdded:Connect(function(child)
        if State and State.ZeroRecoil and child:IsA("Tool") then
            NeutralizeWeaponRecoil(child)
        end
    end)
    table.insert(Cleanups, cAdded)

    local currentTool = char:FindFirstChildOfClass("Tool")
    if currentTool and State.ZeroRecoil then
        NeutralizeWeaponRecoil(currentTool)
    end

    -- Detener animaciones de recoil que hacen temblar el arma al disparar
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        local animTrackAdded = hum.AnimationPlayed:Connect(function(track)
            if State and State.ZeroRecoil and track and track.Animation then
                local aName = (track.Name or ""):lower()
                local animIdName = (track.Animation.Name or ""):lower()
                if aName:find("recoil") or aName:find("shootshake") or aName:find("shake") or animIdName:find("recoil") or animIdName:find("shake") then
                    pcall(function()
                        track:AdjustWeight(0)
                        track:Stop(0)
                    end)
                end
            end
        end)
        table.insert(Cleanups, animTrackAdded)
    end
end

if LocalPlayer.Character then HookCharacterRecoil(LocalPlayer.Character) end
local charAddedConn = LocalPlayer.CharacterAdded:Connect(HookCharacterRecoil)
table.insert(Cleanups, charAddedConn)

-- Bucle de render para forzar que el arma en mano NO tiemble
local _zeroShakeRender = RunService.RenderStepped:Connect(function()
    if State and State.ZeroRecoil and LocalPlayer.Character then
        local myTool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if myTool then
            -- Anular spring recoil o valores dinámicos que se restablecen al disparar
            for _, v in ipairs(myTool:GetChildren()) do
                if v:IsA("NumberValue") then
                    local vn = v.Name:lower()
                    if vn:find("recoil") or vn:find("camshake") or vn:find("shake") or vn:find("kick") then
                        if v.Value ~= 0 then v.Value = 0 end
                    end
                end
            end
        end
    end
end)
table.insert(Cleanups, _zeroShakeRender)

-- --------------------------------------------------------------------
-- 🚀 7. BALAS RÁPIDAS & MODO 0 PING (CONCENTRACIÓN DE BALAS)
-- --------------------------------------------------------------------
local function BoostBullet(part)
    if not part or not part:IsA("BasePart") then return end
    task.spawn(function()
        task.wait()
        if not part or not part.Parent then return end

        -- 🎯 Modo 0 Ping: Concentrar perdigones de escopeta / recortada en 1 solo punto directo
        if State and State.ZeroPingSpread then
            local targetPos = nil
            if State.IsLocked and State.LockedTarget and State.LockedTarget.Character then
                local tPart = GetAimPart(State.LockedTarget.Character)
                if tPart then targetPos = tPart.Position end
            end

            local dir = targetPos and (targetPos - part.Position).Unit or Camera.CFrame.LookVector
            local bv = part:FindFirstChildOfClass("BodyVelocity")
            if bv then
                local speed = bv.Velocity.Magnitude > 0 and bv.Velocity.Magnitude or 500
                bv.Velocity = dir * speed * (State.FastBullets and State.BulletMultiplier or 1)
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            end
            local lv = part:FindFirstChildOfClass("LinearVelocity")
            if lv then
                local speed = lv.VectorVelocity.Magnitude > 0 and lv.VectorVelocity.Magnitude or 500
                lv.VectorVelocity = dir * speed * (State.FastBullets and State.BulletMultiplier or 1)
                lv.MaxForce = math.huge
            end
        elseif State and State.FastBullets then
            local bv = part:FindFirstChildOfClass("BodyVelocity")
            if bv then bv.Velocity = bv.Velocity * State.BulletMultiplier; bv.MaxForce = Vector3.new(math.huge,math.huge,math.huge) end
            local lv = part:FindFirstChildOfClass("LinearVelocity")
            if lv then lv.VectorVelocity = lv.VectorVelocity * State.BulletMultiplier; lv.MaxForce = math.huge end
        end
    end)
end

local function InspectProjectile(obj)
    local n = obj.Name:lower()
    if n:find("bullet") or n:find("proj") or n:find("rocket") or n:find("missile") or n:find("shot") or n:find("rpg") or n:find("pellet") then
        if obj:IsA("BasePart") then
            BoostBullet(obj)
        elseif obj:IsA("Model") then
            for _, child in ipairs(obj:GetChildren()) do
                if child:IsA("BasePart") then BoostBullet(child) end
            end
        end
    end
end

local bulletConn = Workspace.ChildAdded:Connect(function(child)
    if State and State.FastBullets or State.ZeroPingSpread then
        InspectProjectile(child)
    end
end)
table.insert(Cleanups, bulletConn)

-- --------------------------------------------------------------------
-- 📚 8. DICCIONARIO DE ARMAS Y DECODIFICADOR INTELIGENTE DE RAREZAS
-- --------------------------------------------------------------------
local function MatchesGunKeyword(str, kw)
    if not str or not kw then return false end
    local low = str:lower()
    if low == kw then return true end

    -- Coincidencia segura para nombres largos (>= 5 letras: "skorpion", "remington", "crossbow")
    if #kw >= 5 and low:find(kw, 1, true) then
        return true
    end

    -- Para palabras clave cortas (< 5 letras: "m16", "m24", "g3", "c9", "ak47", "uzi")
    -- NUNCA coincidir como parte interna de otra palabra (evita que "anim16", "item16", "arm16" coincidan con "m16")
    local pattern = "%f[%a%d]" .. kw .. "%f[%A%D]"
    if low:find(pattern) then
        return true
    end

    -- Comprobar si está separado por guiones o símbolos: "gun_m16", "item-m16"
    for token in low:gmatch("[%w]+") do
        if token == kw then return true end
    end
    return false
end

-- Lista ordenada por especificidad (Skorpion, Remington, Crossbow PRIMERO para evitar falsos positivos)
local GunDictionary = {
    -- 1. OMEGA / TIER MÁXIMO (BlockSpin Ultra Rare)
    {"m249",             "M249 SAW"},
    {"minigun",          "Minigun"},
    {"anaconda",         "Anaconda"},
    {"barrett",          "Barrett .50 Cal"},
    {"m82",              "Barrett .50 Cal"},
    {"heavy revolver",   "Heavy Revolver"},
    {"heavy rev",        "Heavy Revolver"},
    
    -- 2. LEGENDARIAS (BlockSpin Legendary Crate)
    {"rpg",              "RPG-7"},
    {"rocket launcher",  "RPG-7"},
    {"bazooka",          "RPG-7"},
    {"ak47",             "AK-47"},
    {"ak-47",            "AK-47"},
    {"ak 47",            "AK-47"},
    {"m16",              "M16A4"},
    {"m16a4",            "M16A4"},
    {"m4a1",             "M4A1"},
    {"m4",               "M4A1"},
    {"remington",        "Remington 870"},
    {"remington 870",    "Remington 870"},
    {"tac shotgun",      "Remington 870"},
    {"tactical shotgun", "Remington 870"},
    {"mp5",              "MP5"},
    {"mp5sd",            "MP5SD"},
    {"mp5k",             "MP5K"},
    {"deagle",           "Desert Eagle"},
    {"desert eagle",     "Desert Eagle"},
    {"scar",             "SCAR"},
    {"scar-l",           "SCAR-L"},
    {"scar-h",           "SCAR-H"},
    {"crossbow",         "Crossbow"},
    {"ballesta",         "Crossbow"},
    {"tactical axe",     "Tactical Axe"},
    {"laser rifle",      "Laser Rifle"},
    
    -- 3. ÉPICAS (BlockSpin Elite / Superior)
    {"draco",            "Draco"},
    {"micro draco",      "Draco"},
    {"mini draco",       "Draco"},
    {"m24",              "M24 Sniper"},
    {"m24 sniper",       "M24 Sniper"},
    {"sniper rifle",     "Sniper Rifle"},
    {"awp",              "AWP"},
    {"skorpion",         "Skorpion"},
    {"scorpion",         "Skorpion"},
    {"vz 61",            "Skorpion"},
    {"vz61",             "Skorpion"},
    {"double barrel",    "Double Barrel"},
    {"doublebarrel",     "Double Barrel"},
    {"escopeta doble",   "Double Barrel"},
    {"barbed bat",       "Barbed Bat"},
    {"bate con puas",    "Barbed Bat"},
    {"molotov",          "Molotov"},
    {"grenade",          "Granada"},
    {"granada",          "Granada"},
    {"firework",         "Firework Launcher"},
    {"glock 18",         "Glock 18 (Auto)"},
    {"g18",              "Glock 18 (Auto)"},
    {"auto glock",       "Glock 18 (Auto)"},
    {"tommy",            "Tommy Gun"},
    {"thompson",         "Thompson"},
    {"drum gun",         "Thompson"},
    {"dragunov",         "Dragunov SVD"},
    {"svd",              "Dragunov SVD"},

    -- 4. RARAS (BlockSpin Mid-Tier)
    {"glock",            "Glock 17"},
    {"glock 17",         "Glock 17"},
    {"glock 19",         "Glock 19"},
    {"g17",              "Glock 17"},
    {"g19",              "Glock 19"},
    {"p226",             "SIG P226"},
    {"sig sauer",        "SIG P226"},
    {"sig",              "SIG P226"},
    {"uzi",              "Uzi"},
    {"micro uzi",        "Micro Uzi"},
    {"mini uzi",         "Micro Uzi"},
    {"sawnoff",          "Sawed-Off"},
    {"sawn off",         "Sawed-Off"},
    {"sawed-off",        "Sawed-Off"},
    {"recortada",        "Sawed-Off"},
    {"hunting rifle",    "Hunting Rifle"},
    {"hunting",          "Hunting Rifle"},
    {"brainrot",         "Brainrot Slapper"},
    {"slapper",          "Brainrot Slapper"},
    {"python",           "Python .357"},
    {"colt python",      "Python .357"},
    {"mac10",            "MAC-10"},
    {"mac-10",           "MAC-10"},
    {"mac 10",           "MAC-10"},
    {"tec9",             "TEC-9"},
    {"tec-9",            "TEC-9"},
    {"tec 9",            "TEC-9"},
    {"beretta",          "Beretta M9"},
    {"m9",               "Beretta M9"},
    {"combat shotgun",   "Combat Shotgun"},
    {"pump shotgun",     "Pump Shotgun"},
    {"spas",             "SPAS-12"},
    {"spas12",           "SPAS-12"},
    {"spas-12",          "SPAS-12"},

    -- 5. POCO COMÚN (BlockSpin Basic / Entry)
    {"baseball bat",     "Baseball Bat"},
    {"bate de beisbol",  "Baseball Bat"},
    {"g3",               "HK G3"},
    {"c9",               "Hi-Point C9"},
    {"hi-point",         "Hi-Point C9"},
    {"snowball",         "Snowball"},
    {"crowbar",          "Crowbar"},
    {"palanca",          "Crowbar"},
    {"pipe wrench",      "Pipe Wrench"},
    {"wrench",           "Pipe Wrench"},
    {"golf club",        "Golf Club"},
    {"lead pipe",        "Lead Pipe"},
    {"brass knuckles",   "Brass Knuckles"},
    {"knuckles",         "Brass Knuckles"},
    {"nudillos",         "Brass Knuckles"},
    {"flare gun",        "Flare Gun"},
    {"bengala",          "Flare Gun"},
    {"famas",            "FAMAS"},
    {"aug",              "AUG"},
    {"galil",            "Galil"},
    {"fal",              "FAL"},
    {"p90",              "P90"},
    {"vector",           "Vector"},

    -- 6. COMÚN / MELEE / UTILIDAD
    {"katana",           "Katana"},
    {"machete",          "Machete"},
    {"sword",            "Espada"},
    {"espada",           "Espada"},
    {"combat knife",     "Combat Knife"},
    {"kitchen knife",    "Kitchen Knife"},
    {"knife",            "Cuchillo"},
    {"cuchillo",         "Cuchillo"},
    {"karambit",         "Karambit"},
    {"navaja",           "Navaja"},
    {"stop sign",        "Stop Sign"},
    {"shovel",           "Pala"},
    {"pala",             "Pala"},
    {"pitchfork",        "Pitchfork"},
    {"horca",            "Pitchfork"},
    {"sledgehammer",     "Sledgehammer"},
    {"mazo",             "Sledgehammer"},
    {"pencil",           "Lápiz"},
    {"lapiz",            "Lápiz"},
    {"nunchuck",         "Nunchucks"},
    {"pepper spray",     "Pepper Spray"},
    {"pepper",           "Pepper Spray"},
    {"flashbang",        "Flashbang"},
    {"cegadora",         "Flashbang"},
    {"taser",            "Taser"},
    {"frying pan",       "Sartén"},
    {"sarten",           "Sartén"},
    {"pan",              "Sartén"},
    {"axe",              "Hacha"},
    {"hacha",            "Hacha"},
    {"hammer",           "Martillo"},
    {"martillo",         "Martillo"},
    {"bat",              "Bate"},
    {"bate",             "Bate"},
    {"fist",             "Puños"},
    {"punos",            "Puños"},
    {"fists",            "Puños"}
}
local function IsValidWeaponTool(tool)
    if not tool then return false end
    if not tool:IsA("Tool") and not tool:IsA("Model") then return false end
    if tool:IsA("Model") and (tool:IsA("Accessory") or tool.Name == "HumanoidRootPart" or tool:FindFirstChildOfClass("Humanoid")) then
        return false
    end
    local n = tool.Name:lower()
    if n:sub(1,1) == "." or n:find("delete") or n:find("ragdoll") or n:find("animat") or n:find("client") or n:find("setup") or n:find("core") or n:find("click") or n:find("phone") or n:find("celular") or n:find("shirt") or n:find("pants") or n:find("hair") then
        return false
    end
    return true
end

local function ScanToolForName(tool)
    if not tool then return nil end

    local rawName = tool.Name
    local lowRawName = rawName:lower()

    -- 1. Coincidencia DIRECTA en el nombre del Tool (Máxima prioridad)
    for _, entry in ipairs(GunDictionary) do
        local kw = entry[1]
        if MatchesGunKeyword(lowRawName, kw) then
            return entry[2]
        end
    end

    -- 2. Atributos estándar del Tool (WeaponName, GunName, etc.)
    for _, attr in ipairs({"WeaponName","DisplayName","ItemName","GunName","RealName","Title","Label","Gun","Weapon"}) do
        local val = tool:GetAttribute(attr)
        if val and type(val) == "string" and #val > 1 and tonumber(val) == nil then
            for _, entry in ipairs(GunDictionary) do
                if MatchesGunKeyword(val, entry[1]) then return entry[2] end
            end
            if not val:match("^%x+$") and #val >= 3 then return val end
        end
    end

    -- 3. ToolTip
    if tool.ToolTip and tool.ToolTip ~= "" and tonumber(tool.ToolTip) == nil then
        for _, entry in ipairs(GunDictionary) do
            if MatchesGunKeyword(tool.ToolTip, entry[1]) then return entry[2] end
        end
    end

    -- 4. Buscar en hijos (solo StringValues o partes con nombre explícito de arma)
    for _, child in ipairs(tool:GetChildren()) do
        if child:IsA("StringValue") and (child.Name:lower():find("name") or child.Name:lower():find("gun")) then
            if child.Value and #child.Value > 1 then
                for _, entry in ipairs(GunDictionary) do
                    if MatchesGunKeyword(child.Value, entry[1]) then return entry[2] end
                end
                return child.Value
            end
        end
        -- En partes de modelo, solo buscar nombres largos específicos (nunca m16 en nombres de piezas/animaciones)
        local cName = child.Name:lower()
        if not cName:find("anim") and not cName:find("arm") and not cName:find("cam") and not cName:find("item") then
            for _, entry in ipairs(GunDictionary) do
                if MatchesGunKeyword(cName, entry[1]) then
                    return entry[2]
                end
            end
        end
    end

    -- 4.5 Coincidencia flexible por subcadena para armas conocidas (MP5, AK, Glock, etc.)
    for _, entry in ipairs(GunDictionary) do
        local kw = entry[1]
        if #kw >= 3 and lowRawName:find(kw, 1, true) then
            return entry[2]
        end
    end

    -- 5. Si el Tool tiene un nombre limpio (no un ID numérico ni hash), usarlo directamente
    if tonumber(rawName) == nil and not rawName:match("^%x+$") and #rawName > 1 then
        if not lowRawName:find("place") and not lowRawName:find("not mine") and not lowRawName:find("tower") and not lowRawName:find("tool") then
            return rawName
        end
    end

    return nil
end

local function ClassifyWeapon(wn)
    local cl = " " .. wn:lower():gsub("[%-_%./]", " ") .. " "

    -- 1. OMEGA (Rojo Intenso: #FF2A2A) - BlockSpin Top Tier
    if cl:find("m249") or cl:find("anaconda") or cl:find("omega") or cl:find("barrett") or cl:find("minigun") or cl:find("heavy rev") then
        return {Name = wn, Rarity = "Omega", Tag = "OMEGA", Color = "#FF2A2A"}

    -- 2. LEGENDARIO (Naranja Neón: #FF8C00) - BlockSpin Legendario
    elseif cl:find("rpg") or cl:find("rocket") or cl:find("bazooka")
       or cl:find("ak 47") or cl:find("ak47") or cl:find(" ak ")
       or cl:find("m16") or cl:find("m4a1") or cl:find("m4 ")
       or cl:find("remington") or cl:find("mp5") or cl:find("crossbow") or cl:find("ballesta")
       or cl:find("deagle") or cl:find("desert eagle") or cl:find("scar")
       or cl:find("tactical axe") or cl:find("laser") or cl:find("legend") or cl:find("legendario") then
        return {Name = wn, Rarity = "Legendario", Tag = "LEGENDARIO", Color = "#FF8C00"}

    -- 3. ÉPICO (Morado: #A335EE) - BlockSpin Épico
    elseif cl:find("draco") or cl:find("m24") or cl:find("skorpion") or cl:find("scorpion") or cl:find("vz")
       or cl:find("double barrel") or cl:find("doublebarrel") or cl:find("doble")
       or cl:find("barbed") or cl:find("molotov") or cl:find("grenade") or cl:find("granada")
       or cl:find("firework") or cl:find("g18") or cl:find("auto glock") or cl:find("glock 18")
       or cl:find("tommy") or cl:find("thompson") or cl:find("dragunov") or cl:find("svd")
       or cl:find("sniper") or cl:find("awp") or cl:find("epic") or cl:find("épico") then
        return {Name = wn, Rarity = "Épico", Tag = "ÉPICO", Color = "#A335EE"}

    -- 4. RARO (Azul Neón: #0070FF) - BlockSpin Raro
    elseif cl:find("glock") or cl:find("p226") or cl:find("sig") or cl:find("uzi")
       or cl:find("sawnoff") or cl:find("sawn off") or cl:find("sawed off") or cl:find("recortada")
       or cl:find("hunting") or cl:find("brainrot") or cl:find("slapper")
       or cl:find("python") or cl:find("mac 10") or cl:find("mac10") or cl:find("tec 9") or cl:find("tec9")
       or cl:find("beretta") or cl:find("m9") or cl:find("combat shotgun") or cl:find("pump") or cl:find("spas")
       or cl:find("rare") or cl:find("raro") then
        return {Name = wn, Rarity = "Raro", Tag = "RARO", Color = "#0070FF"}

    -- 5. POCO COMÚN (Verde Esmeralda: #2ECC71) - BlockSpin Poco Común
    elseif cl:find("baseball") or cl:find("bat") or cl:find("bate") or cl:find("g3")
       or cl:find("c9") or cl:find("hi point") or cl:find("snowball") or cl:find("crowbar")
       or cl:find("wrench") or cl:find("golf") or cl:find("pipe") or cl:find("knuckles")
       or cl:find("flare") or cl:find("famas") or cl:find("aug") or cl:find("galil") or cl:find("fal")
       or cl:find("p90") or cl:find("vector") or cl:find("uncommon") then
        return {Name = wn, Rarity = "Poco Común", Tag = "POCO COMÚN", Color = "#2ECC71"}

    -- 6. MELEE (Amarillo Oro: #FFEA00)
    elseif cl:find("knife") or cl:find("cuchillo") or cl:find("stop sign") or cl:find("shovel")
       or cl:find("pala") or cl:find("pitchfork") or cl:find("sledgehammer") or cl:find("pencil")
       or cl:find("nunchuck") or cl:find("pepper") or cl:find("flashbang") or cl:find("taser")
       or cl:find("katana") or cl:find("machete") or cl:find("sword") or cl:find("espada")
       or cl:find("axe") or cl:find("hacha") or cl:find("hammer") or cl:find("martillo")
       or cl:find("pan") or cl:find("sarten") or cl:find("fist") or cl:find("punos") then
        return {Name = wn, Rarity = "Melee", Tag = "MELEE", Color = "#FFEA00"}

    -- 7. COMÚN (Gris Claro: #CBD5E1)
    else
        return {Name = wn, Rarity = "Común", Tag = "COMÚN", Color = "#CBD5E1"}
    end
end
local function DecodeWeapon(tool)
    if not tool then return {Name = "Desconocido", Color = "#E2E8F0", Tag = "COMÚN", Rarity = "Común"} end
    local id = tool.Name
    if WeaponCache[id] then return WeaponCache[id] end

    -- 🔍 Revisar si el Tool tiene atributos o StringValues de rareza directa del juego
    local explicitRarity = nil
    for _, attrName in ipairs({"Rarity", "Tier", "Rank", "Quality", "ItemRarity"}) do
        local val = tool:GetAttribute(attrName)
        if val then
            explicitRarity = tostring(val)
            break
        end
    end
    if not explicitRarity then
        for _, childName in ipairs({"Rarity", "Tier", "Rank", "Quality"}) do
            local child = tool:FindFirstChild(childName)
            if child and (child:IsA("StringValue") or child:IsA("IntValue")) then
                explicitRarity = tostring(child.Value)
                break
            end
        end
    end

    local detectedName = ScanToolForName(tool)
    if not detectedName and tonumber(id) == nil and not id:match("^%x+$") and #id > 1 then
        detectedName = id
    end

    local final = detectedName or ("Arma #" .. tostring(id))
    local result = ClassifyWeapon(final)

    -- Si el juego tiene una rareza explícita definida en atributos, adoptarla
    if explicitRarity and explicitRarity ~= "" then
        local expLow = explicitRarity:lower()
        if expLow:find("mitic") or expLow:find("mítico") or expLow:find("secret") or expLow:find("god") then
            result.Tag = "MÍTICO"; result.Color = "#FF0055"; result.Rarity = "Mítico"
        elseif expLow:find("legend") or expLow:find("gold") or expLow:find("exotic") or expLow == "5" then
            result.Tag = "LEGENDARIO"; result.Color = "#FFB300"; result.Rarity = "Legendario"
        elseif expLow:find("epic") or expLow:find("épic") or expLow == "4" then
            result.Tag = "ÉPICO"; result.Color = "#A335EE"; result.Rarity = "Épico"
        elseif expLow:find("rar") or expLow == "3" then
            result.Tag = "RARO"; result.Color = "#00D4FF"; result.Rarity = "Raro"
        elseif expLow:find("uncom") or expLow:find("poco") or expLow == "2" then
            result.Tag = "POCO COMÚN"; result.Color = "#2ECC71"; result.Rarity = "Poco Común"
        end
    end

    if detectedName then
        WeaponCache[id] = result
    end
    return result
end

-- 🖼️ GENERADOR DE BADGES TÁCTICOS DE ARMAS (100% LIBRE DE ERRORES [X], CERO LAG)
local function GetWeaponBadgeInfo(name)
    local n = " " .. (name or ""):lower():gsub("[%-_%./]", " ") .. " "
    
    -- Omega / Heavy
    if n:find("m249") or n:find("minigun") then return "🔥", "M249"
    elseif n:find("anaconda") or n:find("heavy rev") then return "🔫", "ANAC"
    elseif n:find("barrett") or n:find("m82") then return "🎯", "B.50"

    -- Legendary
    elseif n:find("rpg") or n:find("rocket") or n:find("bazooka") then return "🚀", "RPG"
    elseif n:find("ak 47") or n:find("ak47") or n:find(" ak ") then return "⚡", "AK47"
    elseif n:find("m16") or n:find("m4a1") or n:find("m4") then return "⚡", "M16"
    elseif n:find("remington") or n:find("tac shotgun") then return "💥", "REM"
    elseif n:find("mp5") then return "🔫", "MP5"
    elseif n:find("deagle") or n:find("desert eagle") then return "🔫", "DGL"
    elseif n:find("scar") then return "⚡", "SCAR"
    elseif n:find("crossbow") or n:find("ballesta") then return "🏹", "XBOW"
    elseif n:find("tactical axe") then return "🪓", "T.AXE"
    
    -- Epic
    elseif n:find("draco") then return "⚡", "DRC"
    elseif n:find("m24") or n:find("awp") or n:find("sniper") then return "🎯", "M24"
    elseif n:find("skorpion") or n:find("scorpion") or n:find("vz") then return "🔫", "SKOR"
    elseif n:find("double barrel") or n:find("doublebarrel") or n:find("doble") then return "💥", "DB"
    elseif n:find("barbed") then return "🏏", "BBAT"
    elseif n:find("molotov") then return "🍾", "MOLO"
    elseif n:find("grenade") or n:find("granada") then return "💣", "NADE"
    elseif n:find("firework") then return "🎆", "FIRE"
    elseif n:find("g18") or n:find("auto glock") then return "🔫", "G18"
    elseif n:find("tommy") or n:find("thompson") then return "🔫", "TOMY"
    elseif n:find("dragunov") or n:find("svd") then return "🎯", "SVD"

    -- Rare
    elseif n:find("glock") or n:find("g17") or n:find("g19") then return "🔫", "GLK"
    elseif n:find("p226") or n:find("sig") then return "🔫", "P226"
    elseif n:find("uzi") then return "🔫", "UZI"
    elseif n:find("sawnoff") or n:find("sawn off") or n:find("sawed off") or n:find("recortada") then return "💥", "SAWN"
    elseif n:find("hunting") then return "🎯", "HUNT"
    elseif n:find("brainrot") or n:find("slapper") then return "🖐️", "SLAP"
    elseif n:find("python") then return "🔫", "PYTH"
    elseif n:find("mac 10") or n:find("mac10") then return "🔫", "MAC"
    elseif n:find("tec 9") or n:find("tec9") then return "🔫", "TEC9"
    elseif n:find("beretta") or n:find("m9") then return "🔫", "M9"
    elseif n:find("combat shotgun") or n:find("pump") or n:find("spas") then return "💥", "SHOT"

    -- Uncommon
    elseif n:find("baseball") or n:find("bat") or n:find("bate") then return "🏏", "BAT"
    elseif n:find("g3") then return "⚡", "G3"
    elseif n:find("c9") or n:find("hi point") then return "🔫", "C9"
    elseif n:find("snowball") then return "❄️", "SNOW"
    elseif n:find("crowbar") or n:find("palanca") then return "🔧", "CROW"
    elseif n:find("wrench") then return "🔧", "WRCH"
    elseif n:find("golf") then return "⛳", "GOLF"
    elseif n:find("pipe") then return "🦯", "PIPE"
    elseif n:find("knuckles") or n:find("nudillos") then return "🥊", "KNUK"
    elseif n:find("flare") then return "✨", "FLAR"
    elseif n:find("famas") then return "⚡", "FAMS"
    elseif n:find("aug") then return "⚡", "AUG"
    elseif n:find("galil") then return "⚡", "GLIL"
    elseif n:find("fal") then return "⚡", "FAL"
    elseif n:find("p90") then return "🔫", "P90"
    elseif n:find("vector") then return "🔫", "VECT"

    -- Melee / Utility
    elseif n:find("katana") then return "⚔️", "KAT"
    elseif n:find("machete") then return "🗡️", "MACH"
    elseif n:find("sword") or n:find("espada") then return "⚔️", "SWD"
    elseif n:find("knife") or n:find("cuchillo") or n:find("karambit") or n:find("navaja") then return "🗡️", "KNIF"
    elseif n:find("stop sign") then return "🛑", "STOP"
    elseif n:find("shovel") or n:find("pala") then return "⛏️", "SHOV"
    elseif n:find("pitchfork") or n:find("horca") then return "🔱", "FORK"
    elseif n:find("sledgehammer") or n:find("mazo") then return "🔨", "SLED"
    elseif n:find("pencil") or n:find("lapiz") then return "✏️", "PENC"
    elseif n:find("nunchuck") then return "🥢", "NUNC"
    elseif n:find("pepper") then return "🌶️", "PEPR"
    elseif n:find("flashbang") then return "💡", "FLSH"
    elseif n:find("taser") then return "⚡", "TASR"
    elseif n:find("frying") or n:find("sarten") or n:find("pan") then return "🍳", "PAN"
    elseif n:find("axe") or n:find("hacha") then return "🪓", "AXE"
    elseif n:find("hammer") or n:find("martillo") then return "🔨", "HAMR"
    elseif n:find("fist") or n:find("punos") then return "👊", "FIST"
    else
        local clean = (name or "WPN"):gsub("%s+", "")
        return "📦", clean:sub(1, 3):upper()
    end
end
local function FormatWeaponEntry(tool, isEquipped)
    if not tool then return "" end
    local d = DecodeWeapon(tool)
    if not d or not d.Name then return "" end

    -- Extraer durabilidad de BlockSpin si existe (ej. 720/720)
    local durStr = ""
    local dur = tool:GetAttribute("Durability") or tool:GetAttribute("Health") or tool:GetAttribute("Condition")
    if not dur then
        local dChild = tool:FindFirstChild("Durability") or tool:FindFirstChild("Condition")
        if dChild and (dChild:IsA("IntValue") or dChild:IsA("NumberValue")) then
            dur = dChild.Value
        end
    end
    if dur then
        durStr = string.format(' <font color="#A0AEC0">[%d]</font>', math.floor(tonumber(dur) or 0))
    end

    local icon = isEquipped and "👉" or "🎒"
    local formatted = string.format('%s <font color="%s"><b>%s</b></font>%s', icon, d.Color or "#FFFFFF", d.Name, durStr)
    return formatted
end

-- --------------------------------------------------------------------
-- ⏱️ BUCLE DE NOTIFICACIÓN DE ARMAS EN TIEMPO REAL (OPTIMIZADO)
-- --------------------------------------------------------------------
local aliveLoop = true
task.spawn(function()
    while aliveLoop do
        task.wait(3)
        pcall(function()
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and not IsPlayerIgnored(player) then
                    local tool = player.Character:FindFirstChildOfClass("Tool")
                    if tool then
                        local decoded = DecodeWeapon(tool)
                        if decoded and decoded.Name then
                            local wKey = tool.Name .. "_" .. decoded.Name
                            NotifiedWeapons[player] = NotifiedWeapons[player] or {}

                            if not NotifiedWeapons[player][wKey] then
                                NotifiedWeapons[player][wKey] = true
                                if State.WarnAllWeapons then
                                    if decoded and (decoded.Rarity == "Omega" or decoded.Rarity == "Legendario" or decoded.Rarity == "Mítico") then
                                        -- (Powerful weapon notification silenced)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end)
table.insert(Cleanups, function() aliveLoop = false end)

-- --------------------------------------------------------------------
-- ⚠️ BUCLE DE ALERTA DE ENEMIGO A LAS ESPALDAS (OPTIMIZADO CADA 8 FRAMES)
-- --------------------------------------------------------------------
local _backFrame = 0
local backCheckConn = RunService.Heartbeat:Connect(function()
    if not State.BackWarningEnabled or not BackWarningLabel then
        if BackWarningLabel then BackWarningLabel.Visible = false end
        return
    end

    _backFrame = _backFrame + 1
    if _backFrame % 15 ~= 0 then return end -- ~4 veces por segundo

    local myChar = LocalPlayer.Character
    if not myChar then
        if BackWarningLabel then BackWarningLabel.Visible = false end
        return
    end

    local myRoot = myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Head")
    if not myRoot then
        if BackWarningLabel then BackWarningLabel.Visible = false end
        return
    end

    local myLook = Camera.CFrame.LookVector
    local closestEnemyBehind = nil
    local minDistance = State.BackWarningDistance
    local enemyWeaponText = ""

    for _, player in ipairs(Players:GetPlayers()) do
        if not IsPlayerIgnored(player) and player.Character then
            local enemyChar = player.Character
            local enemyHum = enemyChar:FindFirstChildOfClass("Humanoid")
            local enemyRoot = enemyChar:FindFirstChild("HumanoidRootPart") or enemyChar:FindFirstChild("Head")

            if enemyHum and enemyHum.Health > 1 and enemyRoot then
                local vecToEnemy = (enemyRoot.Position - myRoot.Position)
                local distStuds = vecToEnemy.Magnitude

                if distStuds <= minDistance then
                    local dirToEnemy = vecToEnemy.Unit
                    local dot = myLook:Dot(dirToEnemy)

                    if dot < -0.25 then
                        minDistance = distStuds
                        closestEnemyBehind = player

                        local tool = enemyChar:FindFirstChildOfClass("Tool")
                        if tool then
                            local decoded = DecodeWeapon(tool)
                            enemyWeaponText = string.format(' <font color="%s">[%s]</font>', decoded.Color, decoded.Name)
                        end
                    end
                end
            end
        end
    end

    if closestEnemyBehind then
        local distMeters = math.floor(minDistance * 0.28)
        BackWarningLabel.RichText = true
        BackWarningLabel.Text = string.format("⚠️ ¡ENEMIGO A TUS ESPALDAS! %s (@%s) a %dm%s", closestEnemyBehind.DisplayName, closestEnemyBehind.Name, distMeters, enemyWeaponText)
        BackWarningLabel.Visible = true
    else
        BackWarningLabel.Visible = false
    end
end)
table.insert(Cleanups, backCheckConn)

-- --------------------------------------------------------------------
-- 🛡️ DETECTOR INTELIGENTE DE ZONA SEGURA (OPTIMIZADO CON CACHE CERO LAG)
local _cachedSafeZones = {}
local function RefreshSafeZonesCache()
    local found = {}
    pcall(function()
        for _, folderName in ipairs({"SafeZones", "SafeZone", "Safe_Zones", "Spawns", "ProtectionZones"}) do
            local folder = Workspace:FindFirstChild(folderName)
            if folder then
                for _, zone in ipairs(folder:GetChildren()) do
                    if zone:IsA("BasePart") then
                        table.insert(found, zone)
                    end
                end
            end
        end
    end)
    _cachedSafeZones = found
end
task.spawn(RefreshSafeZonesCache)
task.spawn(function()
    while true do
        task.wait(10)
        RefreshSafeZonesCache()
    end
end)

local function IsPlayerProtectedOrInSafeZone(player)
    if not player or not player.Character then return true end
    local char = player.Character

    -- 1. ForceField / SpawnProtection / Recién nacido
    if char:FindFirstChildOfClass("ForceField") or char:FindFirstChild("ForceField") or char:FindFirstChild("SpawnProtection") or char:FindFirstChild("Protection") then
        return true
    end

    -- 2. Personaje muerto o deshabilitado
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then
        return true
    end

    -- 3. Atributos o Valores de Zona Segura
    for _, attrName in ipairs({"SafeZone", "Safe", "Protected", "InSafeZone", "GodMode", "SpawnShield", "Invulnerable"}) do
        if char:GetAttribute(attrName) == true or player:GetAttribute(attrName) == true then
            return true
        end
        local val = char:FindFirstChild(attrName) or player:FindFirstChild(attrName)
        if val then
            if val:IsA("BoolValue") and val.Value == true then return true end
            if val:IsA("StringValue") and (val.Value:lower():find("safe") or val.Value:lower():find("true")) then return true end
        end
    end

    -- 4. Partes de Zona Segura en Workspace (Cacheado para CERO Lag)
    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
    if root and #_cachedSafeZones > 0 then
        local pos = root.Position
        for _, zone in ipairs(_cachedSafeZones) do
            if zone and zone.Parent then
                local zPos = zone.Position
                local zSize = zone.Size
                if math.abs(pos.X - zPos.X) <= (zSize.X * 0.5 + 2) and
                   math.abs(pos.Y - zPos.Y) <= (zSize.Y * 0.5 + 5) and
                   math.abs(pos.Z - zPos.Z) <= (zSize.Z * 0.5 + 2) then
                    return true
                end
            end
        end
    end

    return false
end

-- 👁️ 9. ESP PRO ULTRA-CLEAN & DETECTOR DE HACKERS
-- --------------------------------------------------------------------
local ESPHighlights = {}
local ESPBillboards = {}
local ESPElements = {}
local ESPTracers = {}

local hasDrawing = (type(Drawing) == "table" and type(Drawing.new) == "function")

-- Contenedor ScreenGui para Tracers en caso de ejecutores sin Drawing API
local TracerGui = nil
if not hasDrawing then
    pcall(function()
        local parentGui = (gethui and gethui()) or CoreGui or (LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui"))
        if parentGui then
            TracerGui = Instance.new("ScreenGui")
            TracerGui.Name = "VIP_TracerGui"
            TracerGui.ResetOnSpawn = false
            TracerGui.DisplayOrder = 999
            TracerGui.Parent = parentGui
            table.insert(Cleanups, function() pcall(function() TracerGui:Destroy() end) end)
        end
    end)
end

local function GetOrCreateTracer(player)
    local tracer = ESPTracers[player]
    if not tracer then
        if hasDrawing then
            local ok, line = pcall(function()
                local l = Drawing.new("Line")
                l.Thickness = State.TracerThickness or 1.5
                l.Transparency = 1
                l.Visible = false
                return l
            end)
            if ok and line then
                tracer = { Type = "Drawing", Object = line }
            end
        end

        if not tracer and TracerGui then
            local frame = Instance.new("Frame")
            frame.Name = "Tracer_" .. player.Name
            frame.AnchorPoint = Vector2.new(0, 0.5)
            frame.BorderSizePixel = 0
            frame.BackgroundColor3 = Color3.fromRGB(255, 40, 40)
            frame.Visible = false
            frame.Parent = TracerGui
            tracer = { Type = "Frame", Object = frame }
        end

        if tracer then
            ESPTracers[player] = tracer
        end
    end
    return tracer
end

local function UpdateTracer(player, startPos, endPos, color, isVisible)
    local tracer = GetOrCreateTracer(player)
    if not tracer or not tracer.Object then return end

    if not isVisible or not startPos or not endPos then
        tracer.Object.Visible = false
        return
    end

    if tracer.Type == "Drawing" then
        tracer.Object.From = startPos
        tracer.Object.To = endPos
        tracer.Object.Color = color
        tracer.Object.Thickness = State.TracerThickness or 1.5
        tracer.Object.Visible = true
    elseif tracer.Type == "Frame" then
        local diff = endPos - startPos
        local dist = diff.Magnitude
        local angle = math.deg(math.atan2(diff.Y, diff.X))
        tracer.Object.Size = UDim2.new(0, dist, 0, State.TracerThickness or 1.5)
        tracer.Object.Position = UDim2.new(0, startPos.X, 0, startPos.Y)
        tracer.Object.Rotation = angle
        tracer.Object.BackgroundColor3 = color
        tracer.Object.Visible = true
    end
end

local function ClearESP(player)
    if ESPHighlights[player] then pcall(function() ESPHighlights[player]:Destroy() end) ESPHighlights[player] = nil end
    if ESPBillboards[player] then pcall(function() ESPBillboards[player]:Destroy() end) ESPBillboards[player] = nil end
    if ESPTracers[player] then
        pcall(function()
            if ESPTracers[player].Type == "Drawing" and ESPTracers[player].Object.Remove then
                ESPTracers[player].Object:Remove()
            elseif ESPTracers[player].Type == "Frame" and ESPTracers[player].Object.Destroy then
                ESPTracers[player].Object:Destroy()
            end
        end)
        ESPTracers[player] = nil
    end
    ESPElements[player] = nil
    NotifiedWeapons[player] = nil
end

-- 🩸 OBTENER VIDA EXACTA Y ESTADO DEL JUGADOR (SOPORTE BLOCKSPIN / ROBLOX)
local function GetCharacterHealth(pChar, hum)
    if not pChar then return 0, 100 end
    -- 1. Revisar si el juego guarda vida en Atributos del Personaje o Humanoid
    for _, name in ipairs({"Health", "HP", "Vida", "CurrentHealth"}) do
        local v = pChar:GetAttribute(name) or (hum and hum:GetAttribute(name))
        if type(v) == "number" then
            local maxV = pChar:GetAttribute("MaxHealth") or pChar:GetAttribute("MaxHP") or (hum and hum:GetAttribute("MaxHealth")) or (hum and hum.MaxHealth > 0 and hum.MaxHealth) or 100
            return math.max(0, v), maxV
        end
        local valObj = pChar:FindFirstChild(name)
        if valObj and (valObj:IsA("NumberValue") or valObj:IsA("IntValue")) then
            local maxObj = pChar:FindFirstChild("MaxHealth") or pChar:FindFirstChild("MaxHP")
            local maxV = (maxObj and maxObj.Value) or (hum and hum.MaxHealth > 0 and hum.MaxHealth) or 100
            return math.max(0, valObj.Value), maxV
        end
    end
    -- 2. Humanoid estándar
    if hum then
        local maxV = hum.MaxHealth > 0 and hum.MaxHealth or 100
        return math.clamp(hum.Health, 0, maxV), maxV
    end
    return 100, 100
end

local function IsCharacterAlive(pChar, hum)
    if not pChar or not pChar.Parent then return false end
    if hum and hum.Health <= 0 then return false end
    -- Check de abatido / muerto en BlockSpin
    if pChar:GetAttribute("Dead") == true or pChar:GetAttribute("IsDead") == true or pChar:GetAttribute("Killed") == true or pChar:GetAttribute("KO") == true or pChar:GetAttribute("Knocked") == true then
        return false
    end
    local ko = pChar:FindFirstChild("KO") or pChar:FindFirstChild("Dead") or pChar:FindFirstChild("Knocked")
    if ko and ko:IsA("BoolValue") and ko.Value == true then return false end
    local root = pChar:FindFirstChild("HumanoidRootPart") or pChar:FindFirstChild("Head") or pChar:FindFirstChildOfClass("BasePart")
    if not root then return false end
    return true
end

local function EnsurePlayerESP(player)
    if not player or player == LocalPlayer then return nil, nil, nil end
    local isAnyActive = (State.EspGlow == true or State.EspShowNames == true or State.EspShowHealth == true or State.EspShowWeapons == true)
    if not isAnyActive then return nil, nil, nil end

    local char = player.Character
    if not char or not char.Parent then
        ClearESP(player)
        return nil, nil, nil
    end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then
        ClearESP(player)
        return nil, nil, nil
    end

    local adorneePart = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChildOfClass("BasePart")
    if not adorneePart then return nil, nil, nil end

    -- 1. Highlight / Silueta Glow
    local hl = ESPHighlights[player]
    if not hl or not hl.Parent or hl.Adornee ~= char then
        if hl then pcall(function() hl:Destroy() end) end
        local isAlly = IsPlayerIgnored(player)
        hl = Instance.new("Highlight")
        hl.Name = "VIP_Highlight"
        hl.Adornee = char
        hl.FillColor = isAlly and State.AllyGlowColor or State.EnemyGlowColor
        hl.FillTransparency = State.GlowTransparency
        hl.OutlineColor = isAlly and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 255, 0)
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Enabled = (State.EspGlow == true)
        hl.Parent = char
        ESPHighlights[player] = hl
    else
        hl.Enabled = (State.EspGlow == true)
    end

    -- 2. BillboardGui & Elements (Nombres, Vida, Armas)
    local bb = ESPBillboards[player]
    local els = ESPElements[player]
    local bbActive = (State.EspShowNames == true or State.EspShowHealth == true or State.EspShowWeapons == true)
    if not bb or not bb.Parent or bb.Adornee ~= adorneePart or not els then
        if bb then pcall(function() bb:Destroy() end) end

        bb = Instance.new("BillboardGui")
        bb.Name = "VIP_ESP_Board"
        bb.Adornee = adorneePart
        bb.Size = UDim2.new(0, 280, 0, 85)
        bb.StudsOffset = Vector3.new(0, 3.0, 0)
        bb.MaxDistance = math.huge -- Infinito: visible a cualquier distancia
        bb.AlwaysOnTop = true
        bb.LightInfluence = 0
        bb.Enabled = bbActive
        bb.ResetOnSpawn = false

        local container = Instance.new("Frame")
        container.Name = "Container"
        container.Parent = bb
        container.Size = UDim2.new(1, 0, 1, 0)
        container.BackgroundTransparency = 1

        local listLayout = Instance.new("UIListLayout")
        listLayout.Parent = container
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.FillDirection = Enum.FillDirection.Vertical
        listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
        listLayout.Padding = UDim.new(0, 2)

        -- 1. RPG Warning (LayoutOrder = 1)
        local rpgLabel = Instance.new("TextLabel")
        rpgLabel.Name = "RpgLabel"
        rpgLabel.LayoutOrder = 1
        rpgLabel.Parent = container
        rpgLabel.Size = UDim2.new(1, 0, 0, 13)
        rpgLabel.BackgroundTransparency = 1
        rpgLabel.TextColor3 = Color3.fromRGB(255, 80, 0)
        rpgLabel.TextStrokeTransparency = 0.2
        rpgLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        rpgLabel.TextSize = 11
        rpgLabel.Font = Enum.Font.SourceSansBold
        rpgLabel.RichText = true
        rpgLabel.Visible = false
        rpgLabel.Text = "🚀 ¡TIENE RPG!"

        -- 2. Name Label (LayoutOrder = 2) - Tamaño legible y elegante
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "NameLabel"
        nameLabel.LayoutOrder = 2
        nameLabel.Parent = container
        nameLabel.Size = UDim2.new(1, 0, 0, 17)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextStrokeTransparency = 0.1
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.TextSize = 14
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.Text = player.DisplayName

        -- 3. Health Bar (LayoutOrder = 3)
        local healthBg = Instance.new("Frame")
        healthBg.Name = "HealthBg"
        healthBg.LayoutOrder = 3
        healthBg.Parent = container
        healthBg.Size = UDim2.new(0, 120, 0, 6)
        healthBg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        healthBg.BorderSizePixel = 1
        healthBg.BorderColor3 = Color3.fromRGB(0, 0, 0)

        local healthBar = Instance.new("Frame")
        healthBar.Name = "HealthBar"
        healthBar.Parent = healthBg
        healthBar.Size = UDim2.new(1, 0, 1, 0)
        healthBar.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        healthBar.BorderSizePixel = 0

        -- 4. Health Label (LayoutOrder = 4)
        local healthLabel = Instance.new("TextLabel")
        healthLabel.Name = "HealthLabel"
        healthLabel.LayoutOrder = 4
        healthLabel.Parent = container
        healthLabel.Size = UDim2.new(1, 0, 0, 12)
        healthLabel.BackgroundTransparency = 1
        healthLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        healthLabel.TextStrokeTransparency = 0.3
        healthLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        healthLabel.TextSize = 12
        healthLabel.Font = Enum.Font.SourceSansBold
        healthLabel.Text = "100 HP"

        -- 5. Contenedor de Badges / Iconos de Armas (LayoutOrder = 5)
        local weaponsFrame = Instance.new("Frame")
        weaponsFrame.Name = "WeaponsFrame"
        weaponsFrame.LayoutOrder = 5
        weaponsFrame.Parent = container
        weaponsFrame.Size = UDim2.new(1, 0, 0, 28)
        weaponsFrame.BackgroundTransparency = 1

        local wfLayout = Instance.new("UIListLayout")
        wfLayout.Parent = weaponsFrame
        wfLayout.SortOrder = Enum.SortOrder.LayoutOrder
        wfLayout.FillDirection = Enum.FillDirection.Horizontal
        wfLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        wfLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        wfLayout.Padding = UDim.new(0, 3)

        -- 6. Weapons Label (LayoutOrder = 6) - Modo Texto Legible
        local weaponsLabel = Instance.new("TextLabel")
        weaponsLabel.Name = "WeaponsLabel"
        weaponsLabel.LayoutOrder = 6
        weaponsLabel.Parent = container
        weaponsLabel.Size = UDim2.new(1, 0, 0, 18)
        weaponsLabel.BackgroundTransparency = 1
        weaponsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        weaponsLabel.TextStrokeTransparency = 0.2
        weaponsLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        weaponsLabel.TextSize = 12
        weaponsLabel.Font = Enum.Font.SourceSansBold
        weaponsLabel.RichText = true
        weaponsLabel.TextWrapped = true
        weaponsLabel.Text = ""

        local pingLabel = Instance.new("TextLabel")
        pingLabel.Name = "PingLabel"
        pingLabel.LayoutOrder = 6
        pingLabel.Parent = container
        pingLabel.Size = UDim2.new(1, 0, 0, 10)
        pingLabel.BackgroundTransparency = 1
        pingLabel.TextColor3 = Color3.fromRGB(0, 245, 180)
        pingLabel.TextStrokeTransparency = 0.3
        pingLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        pingLabel.TextSize = 8
        pingLabel.Font = Enum.Font.GothamBold
        pingLabel.Visible = false
        pingLabel.Text = "DIST: --m"

        bb.Parent = adorneePart
        ESPBillboards[player] = bb
        els = {
            Container    = container,
            RpgLabel     = rpgLabel,
            NameLabel    = nameLabel,
            HealthBg     = healthBg,
            HealthBar    = healthBar,
            HealthLabel  = healthLabel,
            WeaponsFrame = weaponsFrame,
            WeaponsLabel = weaponsLabel,
            WeaponCards  = {},
            LastHp       = -1,
            LastWeapons  = "",
            PingLabel    = pingLabel,
        }
        ESPElements[player] = els
    end

    return bb, els, hl
end

-- Limpieza cuando un jugador sale del servidor
local pRemConn = Players.PlayerRemoving:Connect(ClearESP)
table.insert(Cleanups, pRemConn)
table.insert(Cleanups, function()
    for _, t in pairs(ESPTracers) do
        pcall(function()
            if t.Type == "Drawing" and t.Object.Remove then t.Object:Remove()
            elseif t.Type == "Frame" and t.Object.Destroy then t.Object:Destroy() end
        end)
    end
    ESPTracers = {}
end)

-- 🔄 BUCLE CONTINUO DE ACTUALIZACIÓN DEL ESP (DETECCIÓN INSTANTÁNEA)
local _espFrame = 0
local espHeartbeat = RunService.Heartbeat:Connect(function()
    _espFrame = _espFrame + 1
    local isAnyActive = (State.EspGlow == true or State.EspShowNames == true or State.EspShowHealth == true or State.EspShowWeapons == true or State.EspTracers == true)
    if not isAnyActive then
        for _, bb in pairs(ESPBillboards) do bb.Enabled = false end
        for _, hl in pairs(ESPHighlights) do hl.Enabled = false end
        for _, t in pairs(ESPTracers) do if t and t.Object then t.Object.Visible = false end end
        return
    end

    local vp = Camera.ViewportSize
    local startPos = Vector2.new(vp.X * 0.5, vp.Y)
    if State.TracerOrigin == "Center" then
        startPos = Vector2.new(vp.X * 0.5, vp.Y * 0.5)
    elseif State.TracerOrigin == "Mouse" then
        local mPos = UserInputService:GetMouseLocation()
        startPos = Vector2.new(mPos.X, mPos.Y)
    end

    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

    -- 🔄 ACTUALIZACIÓN INSTANTÁNEA EN CADA FRAME (TIEMPO REAL ABSOLUTO)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            pcall(function()
                local bb, els, hl = EnsurePlayerESP(player)
                local pChar = player.Character
                if bb and els and pChar then
                    local hum = pChar:FindFirstChildOfClass("Humanoid")
                    local pRoot = pChar:FindFirstChild("HumanoidRootPart") or pChar:FindFirstChild("Head") or pChar:FindFirstChild("Torso") or pChar:FindFirstChild("UpperTorso") or pChar:FindFirstChildOfClass("BasePart")
                    if not IsCharacterAlive(pChar, hum) or not pRoot then
                        ClearESP(player)
                        return
                    end

                    bb.Enabled = (State.EspShowNames == true or State.EspShowHealth == true or State.EspShowWeapons == true)

                    -- Distancia en tiempo real (Calculada sin límites, activo a cualquier distancia)
                    local dist = 0
                    if myRoot and pRoot then
                        dist = math.floor((myRoot.Position - pRoot.Position).Magnitude)
                    end

                    -- Distancia en tiempo real
                    local dist = 0
                    if myRoot and pRoot then
                        dist = math.floor((myRoot.Position - pRoot.Position).Magnitude)
                    end

                    -- Nombre del jugador + Distancia compacta
                    if els.NameLabel then
                        els.NameLabel.Visible = (State.EspShowNames == true)
                        if els.NameLabel.Visible then
                            if State.EspShowDistance then
                                els.NameLabel.Text = player.DisplayName .. " [" .. tostring(dist) .. "m]"
                            else
                                els.NameLabel.Text = player.DisplayName
                            end
                        end
                    end

                    -- Barra de Vida + HP compacta
                    if State.EspShowHealth == true then
                        els.HealthBg.Visible = true
                        els.HealthLabel.Visible = true
                        local hp, maxHp = GetCharacterHealth(pChar, hum)
                        local safeMax = (maxHp and maxHp > 0) and maxHp or 100
                        local pct = math.clamp(hp / safeMax, 0, 1)
                        els.HealthBar.Size = UDim2.new(pct, 0, 1, 0)
                        if pct > 0.65 then
                            els.HealthBar.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
                        elseif pct > 0.3 then
                            els.HealthBar.BackgroundColor3 = Color3.fromRGB(241, 196, 15)
                        else
                            els.HealthBar.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
                        end
                        els.HealthLabel.Text = string.format("%d HP", math.floor(hp))
                    else
                        els.HealthBg.Visible = false
                        els.HealthLabel.Visible = false
                    end

                    -- Highlights en tiempo real (Chams)
                    if hl then
                        hl.Enabled = (State.EspGlow == true)
                        if State.EspGlow and (_espFrame % 4 == 0) then
                            local isAlly = IsPlayerIgnored(player)
                            local isProtected = IsPlayerProtectedOrInSafeZone(player)
                            local isLocked = (State and State.IsLocked and State.LockedTarget == player)

                            if isLocked then
                                hl.FillColor = Color3.fromRGB(255, 45, 85)
                                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            elseif isProtected or isAlly then
                                hl.FillColor = Color3.fromRGB(46, 204, 113)
                                hl.OutlineColor = Color3.fromRGB(50, 255, 50)
                            else
                                hl.FillColor = Color3.fromRGB(255, 40, 40)
                                hl.OutlineColor = Color3.fromRGB(255, 0, 80)
                            end
                        end
                    end

                    -- 🔫 ARMAS Y ALERTA RPG: OPTIMIZADO CON CACHÉ Y THROTTLING (CERO LAG)
                    local inHand = pChar:FindFirstChildOfClass("Tool")
                    local handToolName = inHand and inHand.Name or ""
                    local now = tick()
                    local lastScan = els.LastWeaponScan or 0
                    local shouldRescanWeapons = (els.LastHandTool ~= handToolName) or ((now - lastScan) >= 1.2)

                    if shouldRescanWeapons then
                        els.LastWeaponScan = now
                        els.LastHandTool = handToolName

                        local weaponItems = {}
                        local textList = {}
                        local seenKeys = {}
                        local hasRPG = false

                        local function AddWeapon(t, isEquipped)
                            if not t or seenKeys[t] then return end
                            if IsValidWeaponTool(t) then
                                seenKeys[t] = true
                                local d = DecodeWeapon(t)
                                if d and d.Name and not d.Name:find("DishSoap") and not d.Name:find("Inflatable") and not d.Name:find("Bed") then
                                    local hexCol = d.Color or "#CBD5E1"
                                    local emoji, sCode = GetWeaponBadgeInfo(d.Name)
                                    table.insert(weaponItems, {
                                        Tool = t,
                                        IsEquipped = isEquipped,
                                        Name = d.Name,
                                        Emoji = emoji,
                                        ShortCode = sCode,
                                        ColorHex = hexCol,
                                        Rarity = d.Rarity or "Común"
                                    })
                                    local textEntry = FormatWeaponEntry(t, isEquipped)
                                    if textEntry ~= "" then table.insert(textList, textEntry) end
                                    if sCode == "RPG" then hasRPG = true end
                                end
                            end
                        end

                        -- 1. Arma sostenida en mano (Tool o Model en Character)
                        if inHand then AddWeapon(inHand, true) end
                        for _, item in ipairs(pChar:GetChildren()) do
                            if (item:IsA("Tool") or item:IsA("Model")) and item ~= inHand then
                                local lowN = item.Name:lower()
                                -- Solo agregar models que parezcan armas o contengan Handle
                                if item:IsA("Tool") or item:FindFirstChild("Handle") or lowN:find("gun") or lowN:find("mp5") or lowN:find("ak") or lowN:find("m16") or lowN:find("rpg") or lowN:find("glock") or lowN:find("knife") then
                                    AddWeapon(item, true)
                                end
                            end
                        end

                        -- 2. Mochila estándar (Backpack)
                        local bp = player:FindFirstChild("Backpack")
                        if bp then
                            for _, item in ipairs(bp:GetChildren()) do
                                if item:IsA("Tool") or item:IsA("Model") then
                                    AddWeapon(item, false)
                                end
                            end
                        end

                        -- 3. Carpetas de inventario que usa BlockSpin (Inventory, Tools, Weapons, Gear, Slots, etc.)
                        for _, fName in ipairs({"Inventory", "Tools", "Weapons", "Guns", "Gear", "Items", "Slots"}) do
                            local f = player:FindFirstChild(fName) or pChar:FindFirstChild(fName)
                            if f then
                                for _, item in ipairs(f:GetChildren()) do
                                    if item:IsA("Tool") or item:IsA("Model") then
                                        AddWeapon(item, false)
                                    end
                                end
                            end
                        end

                        els.CachedWeaponItems = weaponItems
                        els.CachedTextList = textList
                        els.CachedHasRPG = hasRPG
                    end

                    local weaponItems = els.CachedWeaponItems or {}
                    local textList = els.CachedTextList or {}
                    local isRPG = els.CachedHasRPG or false

                    -- Alerta RPG
                    if els.RpgLabel then
                        els.RpgLabel.Visible = isRPG
                    end

                    -- Renderizado de Armas (Badges compactos o texto)
                    if State.EspShowWeapons == true then
                        local showImages = (State.WeaponDisplayMode == "Images" or State.WeaponDisplayMode == "Both")
                        local showText   = (State.WeaponDisplayMode == "Text" or State.WeaponDisplayMode == "Both")

                        if els.WeaponsFrame then
                            els.WeaponsFrame.Visible = showImages and (#weaponItems > 0)
                            if showImages then
                                els.WeaponCards = els.WeaponCards or {}
                                for i, w in ipairs(weaponItems) do
                                    local card = els.WeaponCards[i]
                                    if not card then
                                        card = Instance.new("Frame")
                                        card.Name = "Card_" .. tostring(i)
                                        card.Parent = els.WeaponsFrame
                                        card.Size = UDim2.new(0, 44, 0, 28)
                                        card.BackgroundColor3 = Color3.fromRGB(11, 14, 20)
                                        card.BackgroundTransparency = 0.2
                                        card.BorderSizePixel = 0

                                        local cCorner = Instance.new("UICorner")
                                        cCorner.CornerRadius = UDim.new(0, 4)
                                        cCorner.Parent = card

                                        local cStroke = Instance.new("UIStroke")
                                        cStroke.Name = "Stroke"
                                        cStroke.Thickness = 1.2
                                        cStroke.Parent = card

                                        -- Emoji Icono (100% visible, cero peticiones fallidas [X])
                                        local iconLbl = Instance.new("TextLabel")
                                        iconLbl.Name = "Emoji"
                                        iconLbl.Parent = card
                                        iconLbl.Size = UDim2.new(1, 0, 0, 13)
                                        iconLbl.Position = UDim2.new(0, 0, 0, 0)
                                        iconLbl.BackgroundTransparency = 1
                                        iconLbl.TextSize = 13
                                        iconLbl.Font = Enum.Font.GothamBold
                                        iconLbl.Text = "🔫"

                                        -- Código de Arma (RPG, AK, M16, etc.)
                                        local badgeLbl = Instance.new("TextLabel")
                                        badgeLbl.Name = "Badge"
                                        badgeLbl.Parent = card
                                        badgeLbl.Size = UDim2.new(1, 0, 0, 11)
                                        badgeLbl.Position = UDim2.new(0, 0, 0, 12)
                                        badgeLbl.BackgroundTransparency = 1
                                        badgeLbl.Font = Enum.Font.GothamBold
                                        badgeLbl.TextSize = 10.5
                                        badgeLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                                        badgeLbl.TextStrokeTransparency = 0.3
                                        badgeLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

                                        local handDot = Instance.new("Frame")
                                        handDot.Name = "HandDot"
                                        handDot.Parent = card
                                        handDot.Size = UDim2.new(0, 5, 0, 5)
                                        handDot.Position = UDim2.new(1, -6, 0, 1)
                                        handDot.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
                                        handDot.BorderSizePixel = 0

                                        local dCorner = Instance.new("UICorner")
                                        dCorner.CornerRadius = UDim.new(1, 0)
                                        dCorner.Parent = handDot

                                        els.WeaponCards[i] = card
                                    end

                                    card.Visible = true
                                    local stroke = card:FindFirstChild("Stroke")
                                    local okCol, parsedCol = pcall(function() return Color3.fromHex(w.ColorHex) end)
                                    local finalCol = okCol and parsedCol or Color3.fromRGB(255, 255, 255)
                                    if stroke then
                                        stroke.Color = finalCol
                                        stroke.Thickness = w.IsEquipped and 2.0 or 1.0
                                    end

                                    local iconLbl = card:FindFirstChild("Emoji")
                                    local badgeLbl = card:FindFirstChild("Badge")
                                    if iconLbl then
                                        iconLbl.Text = w.Emoji or "🔫"
                                    end
                                    if badgeLbl then
                                        badgeLbl.Text = w.ShortCode or "WPN"
                                        badgeLbl.TextColor3 = finalCol
                                    end

                                    local hDot = card:FindFirstChild("HandDot")
                                    if hDot then
                                        hDot.Visible = (w.IsEquipped == true)
                                    end
                                end

                                for i = #weaponItems + 1, #els.WeaponCards do
                                    els.WeaponCards[i].Visible = false
                                end
                            else
                                for _, card in ipairs(els.WeaponCards or {}) do card.Visible = false end
                            end
                        end

                        if els.WeaponsLabel then
                            els.WeaponsLabel.Visible = showText
                            if showText then
                                local wText = #textList > 0 and table.concat(textList, ' <font color="#777777">|</font> ') or '<font color="#777777">Sin armas</font>'
                                if els.LastWeapons ~= wText then
                                    els.LastWeapons = wText
                                    els.WeaponsLabel.Text = wText
                                end
                            end
                        end
                    else
                        if els.WeaponsFrame then els.WeaponsFrame.Visible = false end
                        if els.WeaponsLabel then els.WeaponsLabel.Visible = false end
                    end

                    if els.PingLabel then
                        els.PingLabel.Visible = false
                    end

                    -- 📏 LÍNEAS / TRACERS VIP (Sin importar la distancia)
                    if State.EspTracers == true then
                        local tracerPart = pRoot or pChar:FindFirstChild("Head") or pChar:FindFirstChildOfClass("BasePart")
                        if tracerPart then
                            local sPos, onScreen = Camera:WorldToViewportPoint(tracerPart.Position)
                            if onScreen and sPos.Z > 0 then
                                local endPos = Vector2.new(sPos.X, sPos.Y)
                                local tracerColor = Color3.fromRGB(255, 40, 40) -- Rojo enemigo estándar
                                if State.IsLocked and State.LockedTarget == player then
                                    tracerColor = Color3.fromRGB(255, 45, 85) -- Rosa neón lockeado con Aimbot
                                elseif isProtected or isAlly then
                                    tracerColor = Color3.fromRGB(46, 204, 113) -- Verde aliado / safe
                                elseif isRPG then
                                    tracerColor = Color3.fromRGB(255, 80, 0) -- Naranja RPG peligro
                                end
                                UpdateTracer(player, startPos, endPos, tracerColor, true)
                            else
                                UpdateTracer(player, nil, nil, nil, false)
                            end
                        else
                            UpdateTracer(player, nil, nil, nil, false)
                        end
                    else
                        UpdateTracer(player, nil, nil, nil, false)
                    end
                end
            end)
        end
    end
end)
table.insert(Cleanups, espHeartbeat)

-- ====================================================================
-- 🗺️ MINI-RADAR TÁCTICO 2D (VISIÓN 360° VIP)
-- ====================================================================
local RadarGui = nil
local RadarMainFrame = nil
local RadarBlips = {}

pcall(function()
    local parentGui = (gethui and gethui()) or CoreGui or (LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui"))
    if not parentGui then return end

    local oldRadar = parentGui:FindFirstChild("Alitas_TacticalRadar_Gui")
    if oldRadar then oldRadar:Destroy() end

    RadarGui = Instance.new("ScreenGui")
    RadarGui.Name = "Alitas_TacticalRadar_Gui"
    RadarGui.ResetOnSpawn = false
    RadarGui.DisplayOrder = 99990
    RadarGui.Enabled = (State.RadarEnabled == true)
    RadarGui.Parent = parentGui

    RadarMainFrame = Instance.new("Frame")
    RadarMainFrame.Name = "RadarFrame"
    RadarMainFrame.Size = UDim2.new(0, 140, 0, 140)
    RadarMainFrame.Position = UDim2.new(0, 20, 1, -190)
    RadarMainFrame.BackgroundColor3 = Color3.fromRGB(11, 14, 20)
    RadarMainFrame.BackgroundTransparency = 0.25
    RadarMainFrame.BorderSizePixel = 0
    RadarMainFrame.Parent = RadarGui

    local rCorner = Instance.new("UICorner")
    rCorner.CornerRadius = UDim.new(1, 0)
    rCorner.Parent = RadarMainFrame

    local rStroke = Instance.new("UIStroke")
    rStroke.Name = "RadarStroke"
    rStroke.Color = Color3.fromRGB(0, 255, 180)
    rStroke.Thickness = 1.5
    rStroke.Transparency = 0.2
    rStroke.Parent = RadarMainFrame

    -- Círculo intermedio (50% de rango)
    local midCircle = Instance.new("Frame")
    midCircle.Name = "MidCircle"
    midCircle.AnchorPoint = Vector2.new(0.5, 0.5)
    midCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
    midCircle.Size = UDim2.new(0, 70, 0, 70)
    midCircle.BackgroundTransparency = 1
    midCircle.Parent = RadarMainFrame

    local mcCorner = Instance.new("UICorner")
    mcCorner.CornerRadius = UDim.new(1, 0)
    mcCorner.Parent = midCircle

    local mcStroke = Instance.new("UIStroke")
    mcStroke.Color = Color3.fromRGB(0, 255, 180)
    mcStroke.Thickness = 1
    mcStroke.Transparency = 0.7
    mcStroke.Parent = midCircle

    -- Ejes cardinales
    local vLine = Instance.new("Frame")
    vLine.AnchorPoint = Vector2.new(0.5, 0)
    vLine.Position = UDim2.new(0.5, 0, 0, 0)
    vLine.Size = UDim2.new(0, 1, 1, 0)
    vLine.BackgroundColor3 = Color3.fromRGB(0, 255, 180)
    vLine.BackgroundTransparency = 0.75
    vLine.BorderSizePixel = 0
    vLine.Parent = RadarMainFrame

    local hLine = Instance.new("Frame")
    hLine.AnchorPoint = Vector2.new(0, 0.5)
    hLine.Position = UDim2.new(0, 0, 0.5, 0)
    hLine.Size = UDim2.new(1, 0, 0, 1)
    hLine.BackgroundColor3 = Color3.fromRGB(0, 255, 180)
    hLine.BackgroundTransparency = 0.75
    hLine.BorderSizePixel = 0
    hLine.Parent = RadarMainFrame

    -- Marcador del LocalPlayer (Centro)
    local centerDot = Instance.new("Frame")
    centerDot.Name = "CenterDot"
    centerDot.AnchorPoint = Vector2.new(0.5, 0.5)
    centerDot.Position = UDim2.new(0.5, 0, 0.5, 0)
    centerDot.Size = UDim2.new(0, 6, 0, 6)
    centerDot.BackgroundColor3 = Color3.fromRGB(0, 255, 180)
    centerDot.BorderSizePixel = 0
    centerDot.Parent = RadarMainFrame

    local cdCorner = Instance.new("UICorner")
    cdCorner.CornerRadius = UDim.new(1, 0)
    cdCorner.Parent = centerDot

    -- Título Radar
    local rTitle = Instance.new("TextLabel")
    rTitle.Name = "RadarTitle"
    rTitle.AnchorPoint = Vector2.new(0.5, 0)
    rTitle.Position = UDim2.new(0.5, 0, 0, 3)
    rTitle.Size = UDim2.new(1, 0, 0, 12)
    rTitle.BackgroundTransparency = 1
    rTitle.Font = Enum.Font.GothamBold
    rTitle.TextSize = 8.5
    rTitle.TextColor3 = Color3.fromRGB(0, 255, 180)
    rTitle.TextTransparency = 0.3
    rTitle.Text = "RADAR 360°"
    rTitle.Parent = RadarMainFrame
end)

local _radarFrame = 0
local function UpdateRadar()
    if not State.RadarEnabled or not RadarGui or not RadarMainFrame then
        if RadarGui and RadarGui.Enabled then RadarGui.Enabled = false end
        return
    end
    RadarGui.Enabled = true

    _radarFrame = _radarFrame + 1
    if _radarFrame % 2 ~= 0 then return end -- Actualizar cada 2 frames (súper fluido y cero lag)

    local myChar = LocalPlayer.Character
    if not myChar then return end
    local myHrp = myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Head")
    if not myHrp then return end

    local cam = Workspace.CurrentCamera
    if not cam then return end
    local _, camYaw, _ = cam.CFrame:ToOrientation()

    local maxRange = State.RadarRange or 120
    local radarRadius = 60

    local seen = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local pHrp = player.Character:FindFirstChild("HumanoidRootPart") or player.Character:FindFirstChild("Head")
            local pHum = player.Character:FindFirstChildOfClass("Humanoid")
            if pHrp and pHum and pHum.Health > 0 then
                seen[player] = true
                local blip = RadarBlips[player]
                if not blip or not blip.Parent then
                    blip = Instance.new("Frame")
                    blip.Name = "Blip_" .. player.Name
                    blip.AnchorPoint = Vector2.new(0.5, 0.5)
                    blip.Size = UDim2.new(0, 7, 0, 7)
                    blip.BorderSizePixel = 0
                    blip.Parent = RadarMainFrame

                    local bCorner = Instance.new("UICorner")
                    bCorner.CornerRadius = UDim.new(1, 0)
                    bCorner.Parent = blip

                    local bStroke = Instance.new("UIStroke")
                    bStroke.Thickness = 1
                    bStroke.Color = Color3.fromRGB(0, 0, 0)
                    bStroke.Parent = blip

                    RadarBlips[player] = blip
                end

                local diff = pHrp.Position - myHrp.Position
                local rotX = diff.X * math.cos(-camYaw) - diff.Z * math.sin(-camYaw)
                local rotZ = diff.X * math.sin(-camYaw) + diff.Z * math.cos(-camYaw)

                local normX = rotX / maxRange
                local normY = rotZ / maxRange
                local distNorm = math.sqrt(normX * normX + normY * normY)

                if distNorm > 1 then
                    normX = normX / distNorm
                    normY = normY / distNorm
                end

                blip.Position = UDim2.new(0, 70 + normX * radarRadius, 0, 70 + normY * radarRadius)
                blip.Visible = true

                local isAlly = IsPlayerIgnored and IsPlayerIgnored(player)
                if isAlly then
                    blip.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
                else
                    local els = ESPElements and ESPElements[player]
                    if els and els.CachedHasRPG then
                        blip.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
                    else
                        blip.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                    end
                end
            end
        end
    end

    for p, b in pairs(RadarBlips) do
        if not seen[p] and b then
            b.Visible = false
        end
    end
end

local radarHeartbeat = RunService.Heartbeat:Connect(function()
    UpdateRadar()
end)
table.insert(Cleanups, radarHeartbeat)
table.insert(Cleanups, function()
    pcall(function() if RadarGui then RadarGui:Destroy() end end)
end)


-- ====================================================================
-- 🎯 MIRA PERSONALIZADA TÁCTICA VIP (MULTI-DISEÑOS & 100% SIMÉTRICA)
-- ====================================================================
local CrosshairGui = nil
local CrosshairContainer = nil
local CrosshairParts = {}
local CrosshairStrokes = {}
local CrosshairArms = {}
local CrosshairCenterDot = nil
local CrosshairCircle = nil
local CrosshairSquare = nil

local CrosshairColors = {
    ["Cian Neón"] = Color3.fromRGB(0, 255, 200),
    ["Verde Esmeralda"] = Color3.fromRGB(46, 204, 113),
    ["Rojo Rubí"] = Color3.fromRGB(255, 40, 40),
    ["Amarillo Eléctrico"] = Color3.fromRGB(255, 230, 0),
    ["Blanco Puro"] = Color3.fromRGB(255, 255, 255)
}

local function UpdateCrosshairLayout()
    if not CrosshairContainer then return end
    local style = State.CrosshairStyle or "Cruz Táctica"
    local armSize = State.CrosshairSize or 8
    local gap = State.CrosshairGap or 4

    -- Actualizar dimensiones y posiciones de los 4 brazos
    if CrosshairArms.Top then
        CrosshairArms.Top.Size = UDim2.new(0, 2, 0, armSize)
        CrosshairArms.Top.Position = UDim2.new(0.5, 0, 0.5, -gap)
    end
    if CrosshairArms.Bottom then
        CrosshairArms.Bottom.Size = UDim2.new(0, 2, 0, armSize)
        CrosshairArms.Bottom.Position = UDim2.new(0.5, 0, 0.5, gap)
    end
    if CrosshairArms.Left then
        CrosshairArms.Left.Size = UDim2.new(0, armSize, 0, 2)
        CrosshairArms.Left.Position = UDim2.new(0.5, -gap, 0.5, 0)
    end
    if CrosshairArms.Right then
        CrosshairArms.Right.Size = UDim2.new(0, armSize, 0, 2)
        CrosshairArms.Right.Position = UDim2.new(0.5, gap, 0.5, 0)
    end

    -- Apagar todos para aplicar visibilidad según el diseño elegido
    if CrosshairCenterDot then CrosshairCenterDot.Visible = false end
    if CrosshairCircle then CrosshairCircle.Visible = false end
    if CrosshairSquare then CrosshairSquare.Visible = false end
    for _, arm in pairs(CrosshairArms) do arm.Visible = false end

    if style == "Cruz Táctica" then
        if CrosshairCenterDot then
            CrosshairCenterDot.Visible = true
            CrosshairCenterDot.Size = UDim2.new(0, 4, 0, 4)
        end
        for _, arm in pairs(CrosshairArms) do arm.Visible = true end

    elseif style == "Punto Neón" then
        if CrosshairCenterDot then
            CrosshairCenterDot.Visible = true
            CrosshairCenterDot.Size = UDim2.new(0, 5, 0, 5)
        end

    elseif style == "Cruz Hueca (Sin Punto)" then
        for _, arm in pairs(CrosshairArms) do arm.Visible = true end

    elseif style == "Forma T" then
        if CrosshairCenterDot then
            CrosshairCenterDot.Visible = true
            CrosshairCenterDot.Size = UDim2.new(0, 4, 0, 4)
        end
        if CrosshairArms.Bottom then CrosshairArms.Bottom.Visible = true end
        if CrosshairArms.Left then CrosshairArms.Left.Visible = true end
        if CrosshairArms.Right then CrosshairArms.Right.Visible = true end

    elseif style == "Círculo Táctico" then
        if CrosshairCircle then
            CrosshairCircle.Visible = true
            CrosshairCircle.Size = UDim2.new(0, 16 + gap, 0, 16 + gap)
        end
        if CrosshairCenterDot then
            CrosshairCenterDot.Visible = true
            CrosshairCenterDot.Size = UDim2.new(0, 3, 0, 3)
        end

    elseif style == "Caja Cuadrada" then
        if CrosshairSquare then
            CrosshairSquare.Visible = true
            CrosshairSquare.Size = UDim2.new(0, 14 + gap, 0, 14 + gap)
        end
        if CrosshairCenterDot then
            CrosshairCenterDot.Visible = true
            CrosshairCenterDot.Size = UDim2.new(0, 3, 0, 3)
        end

    elseif style == "Cruz con Círculo (Híbrida)" then
        if CrosshairCircle then
            CrosshairCircle.Visible = true
            CrosshairCircle.Size = UDim2.new(0, 18, 0, 18)
        end
        if CrosshairCenterDot then
            CrosshairCenterDot.Visible = true
            CrosshairCenterDot.Size = UDim2.new(0, 3, 0, 3)
        end
        for _, arm in pairs(CrosshairArms) do arm.Visible = true end
    end
end

pcall(function()
    local parentGui = (gethui and gethui()) or CoreGui or (LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui"))
    if not parentGui then return end

    local oldCross = parentGui:FindFirstChild("Alitas_CustomCrosshair_Gui")
    if oldCross then oldCross:Destroy() end

    CrosshairGui = Instance.new("ScreenGui")
    CrosshairGui.Name = "Alitas_CustomCrosshair_Gui"
    CrosshairGui.ResetOnSpawn = false
    CrosshairGui.DisplayOrder = 99995
    CrosshairGui.IgnoreGuiInset = true -- ¡CRUCIAL! Centra la mira exactamente con el visor 3D de la cámara sin el desfase de 36px
    CrosshairGui.Enabled = (State.CrosshairEnabled == true)
    CrosshairGui.Parent = parentGui

    local baseCol = CrosshairColors[State.CrosshairColor or "Cian Neón"] or Color3.fromRGB(0, 255, 200)

    -- Contenedor maestro perfectamente centrado en la pantalla
    CrosshairContainer = Instance.new("Frame")
    CrosshairContainer.Name = "CrosshairContainer"
    CrosshairContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    CrosshairContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
    CrosshairContainer.Size = UDim2.new(0, 50, 0, 50)
    CrosshairContainer.BackgroundTransparency = 1
    CrosshairContainer.Parent = CrosshairGui

    -- 1. Centro: Punto Neón
    CrosshairCenterDot = Instance.new("Frame")
    CrosshairCenterDot.Name = "CenterDot"
    CrosshairCenterDot.AnchorPoint = Vector2.new(0.5, 0.5)
    CrosshairCenterDot.Position = UDim2.new(0.5, 0, 0.5, 0)
    CrosshairCenterDot.Size = UDim2.new(0, 4, 0, 4)
    CrosshairCenterDot.BackgroundColor3 = baseCol
    CrosshairCenterDot.BorderSizePixel = 0
    CrosshairCenterDot.Parent = CrosshairContainer

    local dCorn = Instance.new("UICorner")
    dCorn.CornerRadius = UDim.new(1, 0)
    dCorn.Parent = CrosshairCenterDot

    local dotStroke = Instance.new("UIStroke")
    dotStroke.Thickness = 1
    dotStroke.Color = Color3.fromRGB(0, 0, 0)
    dotStroke.Parent = CrosshairCenterDot
    table.insert(CrosshairParts, CrosshairCenterDot)

    -- 2. Círculo Táctico Hueco
    CrosshairCircle = Instance.new("Frame")
    CrosshairCircle.Name = "CrossCircle"
    CrosshairCircle.AnchorPoint = Vector2.new(0.5, 0.5)
    CrosshairCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
    CrosshairCircle.Size = UDim2.new(0, 18, 0, 18)
    CrosshairCircle.BackgroundTransparency = 1
    CrosshairCircle.Visible = false
    CrosshairCircle.Parent = CrosshairContainer

    local cirCorner = Instance.new("UICorner")
    cirCorner.CornerRadius = UDim.new(1, 0)
    cirCorner.Parent = CrosshairCircle

    local cirStroke = Instance.new("UIStroke")
    cirStroke.Thickness = 1.3
    cirStroke.Color = baseCol
    cirStroke.Parent = CrosshairCircle
    table.insert(CrosshairStrokes, cirStroke)

    -- 3. Caja Cuadrada Hueca
    CrosshairSquare = Instance.new("Frame")
    CrosshairSquare.Name = "CrossSquare"
    CrosshairSquare.AnchorPoint = Vector2.new(0.5, 0.5)
    CrosshairSquare.Position = UDim2.new(0.5, 0, 0.5, 0)
    CrosshairSquare.Size = UDim2.new(0, 16, 0, 16)
    CrosshairSquare.BackgroundTransparency = 1
    CrosshairSquare.Visible = false
    CrosshairSquare.Parent = CrosshairContainer

    local sqStroke = Instance.new("UIStroke")
    sqStroke.Thickness = 1.3
    sqStroke.Color = baseCol
    sqStroke.Parent = CrosshairSquare
    table.insert(CrosshairStrokes, sqStroke)

    -- 4. 4 Brazos con simetría matemática exacta mediante AnchorPoints individuales
    local armDefs = {
        {id = "Top",    name = "TopArm",    anchor = Vector2.new(0.5, 1)},
        {id = "Bottom", name = "BottomArm", anchor = Vector2.new(0.5, 0)},
        {id = "Left",   name = "LeftArm",   anchor = Vector2.new(1, 0.5)},
        {id = "Right",  name = "RightArm",  anchor = Vector2.new(0, 0.5)},
    }

    for _, def in ipairs(armDefs) do
        local arm = Instance.new("Frame")
        arm.Name = def.name
        arm.AnchorPoint = def.anchor
        arm.BackgroundColor3 = baseCol
        arm.BorderSizePixel = 0
        arm.Parent = CrosshairContainer

        local str = Instance.new("UIStroke")
        str.Thickness = 1
        str.Color = Color3.fromRGB(0, 0, 0)
        str.Parent = arm

        CrosshairArms[def.id] = arm
        table.insert(CrosshairParts, arm)
    end

    UpdateCrosshairLayout()
end)

local function UpdateCrosshairColor(colName)
    State.CrosshairColor = colName
    local col = CrosshairColors[colName] or Color3.fromRGB(0, 255, 200)
    for _, part in ipairs(CrosshairParts) do
        if part and part.Parent then
            part.BackgroundColor3 = col
        end
    end
    for _, str in ipairs(CrosshairStrokes) do
        if str and str.Parent then
            str.Color = col
        end
    end
end

table.insert(Cleanups, function()
    pcall(function() if CrosshairGui then CrosshairGui:Destroy() end end)
end)


-- ====================================================================
-- 🔊 HITSOUNDS & KILL-SOUNDS VIP
-- ====================================================================
local HitsoundIds = {
    ["Rust"] = "rbxassetid://5043539556",
    ["CoD Hitmarker"] = "rbxassetid://296102734",
    ["Ding Campana"] = "rbxassetid://6534947240",
    ["Skeet"] = "rbxassetid://5442065096",
    ["Neverlose"] = "rbxassetid://6534947588"
}

local function PlayHitSound(isKill)
    if not State.HitsoundsEnabled then return end
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = HitsoundIds[State.HitsoundChoice or "Rust"] or "rbxassetid://5043539556"
        sound.Volume = isKill and 0.85 or 0.55
        sound.Pitch = isKill and 1.25 or 1.0
        sound.Parent = Workspace
        sound:Play()
        task.delay(1, function() pcall(function() sound:Destroy() end) end)
    end)
end

-- Listener de daño para hitsounds (100% asíncrono y ultra seguro)
local EnemyHealthCache = {}
local function SetupHitsoundListener(p)
    if not p or p == LocalPlayer then return end
    task.spawn(function()
        pcall(function()
            local function HookChar(char)
                if not char then return end
                local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 2)
                if hum then
                    EnemyHealthCache[p] = hum.Health
                    local conn = hum.HealthChanged:Connect(function(newHp)
                        local oldHp = EnemyHealthCache[p] or hum.MaxHealth
                        EnemyHealthCache[p] = newHp
                        if newHp < oldHp then
                            local myChar = LocalPlayer.Character
                            if myChar then
                                local myHrp = myChar:FindFirstChild("HumanoidRootPart")
                                local pHrp = char:FindFirstChild("HumanoidRootPart")
                                if myHrp and pHrp then
                                    local dist = (myHrp.Position - pHrp.Position).Magnitude
                                    local isTarget = (State.LockedTarget == p)
                                    local isMouseDown = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
                                    if isTarget or (dist < 250 and isMouseDown) then
                                        PlayHitSound(newHp <= 0)
                                    end
                                end
                            end
                        end
                    end)
                    table.insert(Cleanups, conn)
                end
            end
            if p.Character then HookChar(p.Character) end
            local cAdd = p.CharacterAdded:Connect(HookChar)
            table.insert(Cleanups, cAdd)
        end)
    end)
end

for _, p in ipairs(Players:GetPlayers()) do
    SetupHitsoundListener(p)
end
local pAddHitsound = Players.PlayerAdded:Connect(SetupHitsoundListener)
table.insert(Cleanups, pAddHitsound)


-- ====================================================================
-- 🕶️ FULLBRIGHT / VISIÓN NOCTURNA TÁCTICA
-- ====================================================================
local FullBrightSaved = {
    Active = false,
    Brightness = nil,
    ClockTime = nil,
    FogEnd = nil,
    GlobalShadows = nil,
    Ambient = nil,
    OutdoorAmbient = nil
}
local fullBrightConn = nil

local function ApplyFullBright(enabled)
    State.FullBrightEnabled = enabled
    pcall(function()
        local Lighting = game:GetService("Lighting")
        if enabled then
            if not FullBrightSaved.Active then
                FullBrightSaved.Active = true
                FullBrightSaved.Brightness = Lighting.Brightness
                FullBrightSaved.ClockTime = Lighting.ClockTime
                FullBrightSaved.FogEnd = Lighting.FogEnd
                FullBrightSaved.GlobalShadows = Lighting.GlobalShadows
                FullBrightSaved.Ambient = Lighting.Ambient
                FullBrightSaved.OutdoorAmbient = Lighting.OutdoorAmbient
            end

            local function ForceBright()
                if not State.FullBrightEnabled then return end
                Lighting.Brightness = 2
                Lighting.ClockTime = 14
                Lighting.FogEnd = 100000
                Lighting.GlobalShadows = false
                Lighting.Ambient = Color3.fromRGB(180, 180, 180)
                Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
            end

            ForceBright()
            if fullBrightConn then fullBrightConn:Disconnect() end
            fullBrightConn = Lighting.Changed:Connect(function(prop) if prop == "ClockTime" or prop == "Brightness" or prop == "FogEnd" or prop == "Ambient" then ForceBright() end end)

            ShowNotification("🕶️ Visión Nocturna", "FullBright activado: iluminación máxima en todo el mapa.", true)
        else
            if fullBrightConn then
                fullBrightConn:Disconnect()
                fullBrightConn = nil
            end
            if FullBrightSaved.Active then
                if FullBrightSaved.Brightness ~= nil then Lighting.Brightness = FullBrightSaved.Brightness end
                if FullBrightSaved.ClockTime ~= nil then Lighting.ClockTime = FullBrightSaved.ClockTime end
                if FullBrightSaved.FogEnd ~= nil then Lighting.FogEnd = FullBrightSaved.FogEnd end
                if FullBrightSaved.GlobalShadows ~= nil then Lighting.GlobalShadows = FullBrightSaved.GlobalShadows end
                if FullBrightSaved.Ambient ~= nil then Lighting.Ambient = FullBrightSaved.Ambient end
                if FullBrightSaved.OutdoorAmbient ~= nil then Lighting.OutdoorAmbient = FullBrightSaved.OutdoorAmbient end
                FullBrightSaved.Active = false
            end
            ShowNotification("🕶️ Visión Nocturna", "Iluminación restaurada a la normalidad.")
        end
    end)
end

table.insert(Cleanups, function()
    pcall(function() ApplyFullBright(false) end)
end)


-- ====================================================================
-- 🚀 MODO TURBO FPS / POTATO BOOST (OPTIMIZACIÓN MÁXIMA)
-- ====================================================================
local PotatoSaved = {
    Active = false,
    GlobalShadows = nil,
    FogEnd = nil,
    WaterWaveSize = nil,
    Effects = {},
    Particles = {}
}

local function ApplyPotatoBoost(enabled)
    State.PotatoBoost = enabled
    pcall(function()
        local Lighting = game:GetService("Lighting")
        local Terrain = Workspace:FindFirstChildOfClass("Terrain")

        if enabled then
            if not PotatoSaved.Active then
                PotatoSaved.Active = true
                PotatoSaved.GlobalShadows = Lighting.GlobalShadows
                PotatoSaved.FogEnd = Lighting.FogEnd
                if Terrain then
                    PotatoSaved.WaterWaveSize = Terrain.WaterWaveSize
                end
            end

            -- Apagar sombras y niebla pesada
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9

            -- Apagar post-procesamiento pesado
            for _, eff in ipairs(Lighting:GetChildren()) do
                if eff:IsA("PostEffect") or eff:IsA("BloomEffect") or eff:IsA("BlurEffect") or eff:IsA("SunRaysEffect") or eff:IsA("DepthOfFieldEffect") then
                    if eff.Enabled then
                        PotatoSaved.Effects[eff] = true
                        eff.Enabled = false
                    end
                end
            end

            -- Desactivar oleaje de agua
            if Terrain then
                Terrain.WaterWaveSize = 0
                Terrain.WaterWaveSpeed = 0
                Terrain.WaterReflectance = 0
            end

            -- Desactivar partículas en el mapa
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                    if obj.Enabled then
                        PotatoSaved.Particles[obj] = true
                        obj.Enabled = false
                    end
                end
            end

            ShowNotification("⚡ Turbo FPS Activado", "Sombras, partículas y efectos apagados. ¡FPS optimizados al máximo!", true)
        else
            -- Restaurar configuración original
            if PotatoSaved.Active then
                if PotatoSaved.GlobalShadows ~= nil then Lighting.GlobalShadows = PotatoSaved.GlobalShadows end
                if PotatoSaved.FogEnd ~= nil then Lighting.FogEnd = PotatoSaved.FogEnd end
                if Terrain and PotatoSaved.WaterWaveSize ~= nil then
                    Terrain.WaterWaveSize = PotatoSaved.WaterWaveSize
                end
                for eff, _ in pairs(PotatoSaved.Effects) do
                    pcall(function() if eff and eff.Parent then eff.Enabled = true end end)
                end
                for part, _ in pairs(PotatoSaved.Particles) do
                    pcall(function() if part and part.Parent then part.Enabled = true end end)
                end
                PotatoSaved.Effects = {}
                PotatoSaved.Particles = {}
                PotatoSaved.Active = false
            end
            ShowNotification("🍃 Turbo FPS Desactivado", "Gráficos restaurados a la normalidad.")
        end
    end)
end

table.insert(Cleanups, function()
    pcall(function() ApplyPotatoBoost(false) end)
end)

-- 🧱 TEXTURAS PLANAS: Quita todas las texturas y deja solo colores sólidos
local FlatTexturesSaved = { Active = false, Materials = {}, Hidden = {} }

local function ApplyFlatTextures(enabled)
    State.FlatTextures = enabled
    pcall(function()
        if enabled then
            FlatTexturesSaved.Active = true

            -- Recorrer todo el Workspace
            for _, obj in ipairs(Workspace:GetDescendants()) do
                -- Ocultar Textures, Decals, SurfaceAppearance
                if obj:IsA("Texture") or obj:IsA("Decal") or obj:IsA("SurfaceAppearance") then
                    if obj.Parent then
                        FlatTexturesSaved.Hidden[obj] = true
                        pcall(function()
                            if obj:IsA("SurfaceAppearance") then
                                obj.Parent = nil -- No tiene .Transparency, hay que removerlo
                            else
                                obj.Transparency = 1
                            end
                        end)
                    end
                end

                -- Cambiar material a SmoothPlastic (color plano sin textura)
                if obj:IsA("BasePart") and not obj:IsA("Terrain") then
                    if not FlatTexturesSaved.Materials[obj] then
                        FlatTexturesSaved.Materials[obj] = obj.Material
                    end
                    obj.Material = Enum.Material.SmoothPlastic
                end
            end

            -- Terreno: quitar decoración
            local terrain = Workspace:FindFirstChildOfClass("Terrain")
            if terrain then
                pcall(function() terrain.Decoration = false end)
            end

            ShowNotification("🧱 Texturas Planas", "✅ Texturas eliminadas. Solo colores sólidos.", true)
        else
            -- Restaurar texturas originales
            if FlatTexturesSaved.Active then
                for obj, origMaterial in pairs(FlatTexturesSaved.Materials) do
                    pcall(function()
                        if obj and obj.Parent then
                            obj.Material = origMaterial
                        end
                    end)
                end

                for obj, _ in pairs(FlatTexturesSaved.Hidden) do
                    pcall(function()
                        if obj then
                            if obj:IsA("SurfaceAppearance") then
                                -- No podemos restaurar SurfaceAppearance removidos
                            elseif obj.Parent then
                                obj.Transparency = 0
                            end
                        end
                    end)
                end

                local terrain = Workspace:FindFirstChildOfClass("Terrain")
                if terrain then
                    pcall(function() terrain.Decoration = true end)
                end

                FlatTexturesSaved.Materials = {}
                FlatTexturesSaved.Hidden = {}
                FlatTexturesSaved.Active = false
            end
            ShowNotification("🧱 Texturas Planas", "❌ Texturas restauradas a la normalidad.")
        end
    end)
end

table.insert(Cleanups, function()
    pcall(function() ApplyFlatTextures(false) end)
end)



-- --------------------------------------------------------------------
-- 📱 10. MENÚ PRINCIPAL
-- --------------------------------------------------------------------
local CombatTab = Window:NewTab("⚡ Combate")
local CombatSec = CombatTab:NewSection("── 🎯 CYBER AIMBOT ENGINE ──")

UI_Toggles.Aimbot = CombatSec:NewToggle("Activar Aimbot VIP", "Presiona [" .. tostring(State.AimbotKey) .. "] para activar/desactivar", function(s)
    State.Aimbot = s
    if not s then
        State.IsLocked = false
        State.LockedTarget = nil
        ReleaseCamera()
    end
    SaveConfig(true)
end)

local isBindingAimbotKey = false
local btnBindAimbot
local function FormatKeyDisplay(prefix, keyName)
    local isGp = tostring(keyName):find("Button") or tostring(keyName):find("DPad")
    local icon = isGp and "🎮 " or "⌨️ "
    return icon .. prefix .. ": [" .. tostring(keyName) .. "]"
end

btnBindAimbot = CombatSec:NewButton(FormatKeyDisplay("Asignar Aimbot", State.AimbotKey), "Haz clic y presiona una tecla o BOTÓN DEL CONTROL", function()
    if isBindingAimbotKey then return end
    isBindingAimbotKey = true
    ShowNotification("🎮 Asignar Aimbot", "👉 Presiona cualquier tecla o BOTÓN DEL CONTROL...")
    local conn
    conn = UserInputService.InputBegan:Connect(function(input, gpe)
        local isGp = input.UserInputType.Name:find("Gamepad")
        local isKb = (input.UserInputType == Enum.UserInputType.Keyboard)
        local isM2 = (input.UserInputType == Enum.UserInputType.MouseButton2)
        if (isKb or isGp or isM2) and input.KeyCode.Name ~= "Unknown" then
            conn:Disconnect()
            local assigned = input.KeyCode.Name
            if isM2 then assigned = "MouseButton2" end
            State.AimbotKey = assigned
            if isGp then
                State.GamepadAimButton = assigned
                State.GamepadAimEnabled = true
            end
            SaveConfig(true)
            pcall(function()
                if btnBindAimbot and btnBindAimbot.UpdateButton then
                    btnBindAimbot:UpdateButton(FormatKeyDisplay("Asignar Aimbot", assigned))
                end
            end)
            ShowNotification("✅ Aimbot Asignado", "Activación fijada en: [" .. assigned .. "]")
            isBindingAimbotKey = false
        end
    end)
    task.delay(6, function()
        if isBindingAimbotKey then
            isBindingAimbotKey = false
            pcall(function() conn:Disconnect() end)
        end
    end)
end)

CombatSec:NewTextBox("✏️ Tecla Aimbot", "Ej: V, E, Q, ButtonR1...", function(txt)
    if txt and #txt >= 1 then
        local cleanKey = txt:gsub("%s+", "")
        if cleanKey:lower() == "mousebutton2" or cleanKey:lower() == "clickderecho" or cleanKey:lower() == "rmb" then
            cleanKey = "MouseButton2"
        elseif cleanKey:lower() == "mousebutton1" or cleanKey:lower() == "clickizquierdo" or cleanKey:lower() == "lmb" then
            cleanKey = "MouseButton1"
        else
            cleanKey = cleanKey:upper()
        end
        State.AimbotKey = cleanKey
        SaveConfig(true)
        pcall(function()
            if btnBindAimbot and btnBindAimbot.UpdateButton then
                btnBindAimbot:UpdateButton("⌨️ Asignar Tecla Aimbot: [" .. cleanKey .. "]")
            end
        end)
        ShowNotification("✅ Tecla Asignada", "Aimbot ahora se activa con: [" .. cleanKey .. "]")
    end
end)

CombatSec:NewToggle("🎯 Imán Continuo / POV (Sin Botón)", "Solo mueve la mira cerca y se le pega al enemigo automáticamente", function(s)
    State.AutoLockAlways = s
    SaveConfig(false)
end)

CombatSec:NewDropdown("Zona de Apuntado", "Cabeza o Torso", {"Cabeza", "Pecho"}, function(part)
    if part == "Cabeza" then State.TargetPart = "Head" else State.TargetPart = "UpperTorso" end
    SaveConfig(true)
end)

local isBindingPartKey = false
local btnBindPart
btnBindPart = CombatSec:NewButton(FormatKeyDisplay("Alternar Cabeza/Pecho", State.TogglePartKey), "Haz clic y presiona una tecla o BOTÓN DEL CONTROL", function()
    if isBindingPartKey then return end
    isBindingPartKey = true
    ShowNotification("🎮 Alternar Cabeza/Pecho", "👉 Presiona una tecla o BOTÓN DEL CONTROL...")
    local conn
    conn = UserInputService.InputBegan:Connect(function(input, gpe)
        local isGp = input.UserInputType.Name:find("Gamepad")
        local isKb = (input.UserInputType == Enum.UserInputType.Keyboard)
        if (isKb or isGp) and input.KeyCode.Name ~= "Unknown" then
            conn:Disconnect()
            State.TogglePartKey = input.KeyCode.Name
            SaveConfig(true)
            pcall(function()
                if btnBindPart and btnBindPart.UpdateButton then
                    btnBindPart:UpdateButton(FormatKeyDisplay("Alternar Cabeza/Pecho", input.KeyCode.Name))
                end
            end)
            ShowNotification("✅ Botón Asignado", "Alternar Cabeza/Pecho fijado en: [" .. input.KeyCode.Name .. "]")
            isBindingPartKey = false
        end
    end)
    task.delay(6, function()
        if isBindingPartKey then
            isBindingPartKey = false
            pcall(function() conn:Disconnect() end)
        end
    end)
end)

CombatSec:NewTextBox("✏️ Tecla Cab/Pecho", "Ej: B, X, DPadUp...", function(txt)
    if txt and #txt >= 1 then
        local cleanKey = txt:gsub("%s+", ""):upper()
        State.TogglePartKey = cleanKey
        SaveConfig(true)
        pcall(function()
            if btnBindPart and btnBindPart.UpdateButton then
                btnBindPart:UpdateButton("🔄 Asignar Tecla Cabeza/Pecho: [" .. cleanKey .. "]")
            end
        end)
        ShowNotification("✅ Tecla Asignada", "Alternar Cabeza/Pecho con: [" .. cleanKey .. "]")
    end
end)

UI_Toggles.AutoSwitchPart = CombatSec:NewToggle("🔄 Alternar Cabeza/Pecho cada 1s", "Cambia continuamente cada segundo (Cabeza <-> Pecho)", function(s)
    State.AutoSwitchPart = s
    SaveConfig(true)
    ShowNotification("🔄 Auto-Cambio", s and "✅ Alternando Cabeza/Pecho cada 1 segundo" or "❌ Auto-cambio desactivado")
end)

-- (AutoClicker UI removido)

-- 🎮 SECCIÓN CONTROL / GAMEPAD
local GamepadSec = CombatTab:NewSection("── 🎮 CONTROL / GAMEPAD HACK ──")

UI_Toggles.GamepadAim = GamepadSec:NewToggle("Activar Aimbot con Control", "Usa un botón del mando para activar", function(s)
    State.GamepadAimEnabled = s
    if s then
        ShowNotification("🎮 Control", "Botón activo: " .. State.GamepadAimButton .. " — Presión activa el aimbot")
    end
    SaveConfig(true)
end)

GamepadSec:NewDropdown("Botón del Control", "Elige el botón del mando", {
    "ButtonR2", "ButtonL2", "ButtonR1", "ButtonL1",
    "ButtonX", "ButtonY", "ButtonA", "ButtonB",
    "ButtonR3", "ButtonL3", "DPadRight", "DPadLeft",
    "DPadUp", "DPadDown"
}, function(btn)
    State.GamepadAimButton = btn
    SaveConfig(true)
    ShowNotification("🎮 Control", "Botón asignado: " .. btn)
end)

local AudioSec = CombatTab:NewSection("── 🔊 HITSOUNDS & AUDIO VIP ──")
UI_Toggles.HitsoundsEnabled = AudioSec:NewToggle("Activar Hitsounds (Sonido de Impacto)", "Sonido placentero al impactar o eliminar enemigos", function(s)
    State.HitsoundsEnabled = s
end)
AudioSec:NewDropdown("Elegir Sonido", "Estilo del sonido de impacto", {"Rust", "CoD Hitmarker", "Ding Campana", "Skeet", "Neverlose"}, function(v)
    State.HitsoundChoice = v
    PlayHitSound(false)
end)

local VisualAimSec = CombatTab:NewSection("── 🌐 FOV & TARGET HUD ──")

UI_Toggles.ShowFOV = VisualAimSec:NewToggle("Círculo FOV Neón", "Rango visible de fijación", function(s)
    State.ShowFOV = s
    SaveConfig(true)
end)

UI_Toggles.ShowTargetDot = VisualAimSec:NewToggle("Puntero Rojo en Objetivo", "Bolita en la cabeza/torso", function(s)
    State.ShowTargetDot = s
    SaveConfig(true)
end)

VisualAimSec:NewSlider("Radio del FOV", "Tamaño en pantalla", 500, 30, function(v)
    State.AimbotFOV = v
    SaveConfig(true)
end)

VisualAimSec:NewSlider("Pegado de Cámara (Imán)", "10 = Imán Total (Cero separación) / 1 = Suave", 10, 1, function(v)
    State.AimbotSmoothness = v/10
    SaveConfig(true)
end)

-- PESTAÑA DE ALIADOS
local WhitelistTab = Window:NewTab("👥 Whitelist")
local WhitelistSec = WhitelistTab:NewSection("── 👥 PROTECCIÓN ALIADOS ──")

UI_Toggles.IgnoreFriends = WhitelistSec:NewToggle("Proteger Amigos de Roblox", "Ignora a amigos automáticamente", function(s)
    State.IgnoreFriends = s
    SaveConfig(true)
end)

local function GetServerPlayerList()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(list, p.DisplayName .. " (@" .. p.Name .. ")")
        end
    end
    if #list == 0 then table.insert(list, "Sin otros jugadores") end
    return list
end

WhitelistSec:NewDropdown("📋 Jugadores en el Servidor", "Elige a alguien del server para hacerlo aliado", GetServerPlayerList(), function(selected)
    local uName = selected:match("%(@(.-)%)") or selected
    if uName and #uName > 1 and not uName:find("Sin otros") then
        local clean = uName:gsub("%s+", ""):lower()
        State.IgnoredPlayers[clean] = true
        SaveConfig(false)
        ShowNotification("👥 Aliados", "✅ Aliado agregado: " .. uName)
    end
end)

local newPlayerName = ""
WhitelistSec:NewTextBox("Nombre Manual (Username/Display)", "O escribe el nombre manualmente", function(txt)
    newPlayerName = txt
end)

WhitelistSec:NewButton("➕ Agregar Nombre Manual", "Guarda el nombre escrito arriba", function()
    local clean = newPlayerName:gsub("%s+", ""):lower()
    if #clean > 1 then
        State.IgnoredPlayers[clean] = true
        SaveConfig(false)
        ShowNotification("👥 Aliados", "✅ Agregado a la lista: " .. clean)
    end
end)

WhitelistSec:NewButton("🗑️ Limpiar Aliados Manuales", "Borra la lista de aliados agregados", function()
    State.IgnoredPlayers = {}
    SaveConfig(false)
    ShowNotification("👥 Aliados", "Lista de aliados limpiada.")
end)

-- PESTAÑA DE ARMAS
local WeaponTab = Window:NewTab("💀 Armas")
local WeaponSec = WeaponTab:NewSection("── 💀 ZERO RECOIL & COMBAT HACKS ──")

UI_Toggles.ZeroRecoil = WeaponSec:NewToggle("0 Retroceso / Recoil (v8.0)", "Disparo 100% estable", function(s)
    State.ZeroRecoil = s
    if s and LocalPlayer.Character then
        local t = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if t then NeutralizeWeaponRecoil(t) end
    end
    SaveConfig(true)
end)

UI_Toggles.ZeroPingSpread = WeaponSec:NewToggle("🎯 Modo 0 Ping (Balas Concentradas)", "Sin dispersión en Recortada y Doble Cañón", function(s)
    State.ZeroPingSpread = s
    SaveConfig(true)
    ShowNotification("🎯 0 Ping", s and "✅ Balas concentradas en 1 punto sin dispersión" or "❌ Dispersión normal")
end)

UI_Toggles.FastBullets = WeaponSec:NewToggle("Balas Aceleradas", "Aumenta la velocidad del proyectil", function(s)
    State.FastBullets = s
    SaveConfig(true)
end)

WeaponSec:NewSlider("Multiplicador de Velocidad", "Velocidad balas", 20, 2, function(v)
    State.BulletMultiplier = v
    SaveConfig(true)
end)

-- PESTAÑA DE ESP
local VisualTab = Window:NewTab("👁️ ESP Matrix")
local VisualSec = VisualTab:NewSection("── 👁️ MATRIX WALLHACK ESP ──")

UI_Toggles.EspGlow = VisualSec:NewToggle("Siluetas / Glow (Chams)", "Resalta el cuerpo del jugador a través de paredes", function(s)
    State.EspGlow = s
    for _, hl in pairs(ESPHighlights) do
        if hl then hl.Enabled = s end
    end
    SaveConfig(true)
end)

UI_Toggles.EspShowNames = VisualSec:NewToggle("Mostrar Nombres", "Muestra u oculta los nombres", function(s)
    State.EspShowNames = s
    for _, els in pairs(ESPElements) do
        if els.NameLabel then els.NameLabel.Visible = s end
    end
    SaveConfig(true)
end)

UI_Toggles.EspShowDistance = VisualSec:NewToggle("Mostrar Metros / Distancia", "Muestra u oculta los metros [Xm] en el ESP", function(s)
    State.EspShowDistance = s
    SaveConfig(true)
    ShowNotification("👁️ Distancia ESP", s and "✅ Metros visibles en ESP" or "❌ Metros ocultados del ESP")
end)

UI_Toggles.EspShowHealth = VisualSec:NewToggle("Mostrar Barra de Vida", "Muestra u oculta la barra de HP", function(s)
    State.EspShowHealth = s
    for _, els in pairs(ESPElements) do
        if els.HealthBg then els.HealthBg.Visible = s end
        if els.HealthLabel then els.HealthLabel.Visible = s end
    end
    SaveConfig(true)
end)

UI_Toggles.EspShowWeapons = VisualSec:NewToggle("Mostrar Armas", "Muestra u oculta las armas detectadas", function(s)
    State.EspShowWeapons = s
    for _, els in pairs(ESPElements) do
        if els.WeaponsLabel then els.WeaponsLabel.Visible = s end
        if els.WeaponsFrame then els.WeaponsFrame.Visible = s end
    end
    SaveConfig(true)
end)

VisualSec:NewDropdown("Modo Visual de Armas", "Elige ver las armas con imágenes o texto", {"🖼️ Imágenes / Iconos", "📝 Texto", "✨ Ambos"}, function(v)
    if v:find("Imágenes") or v:find("Iconos") then
        State.WeaponDisplayMode = "Images"
    elseif v:find("Texto") then
        State.WeaponDisplayMode = "Text"
    else
        State.WeaponDisplayMode = "Both"
    end
    SaveConfig(true)
end)

UI_Toggles.EspTracers = VisualSec:NewToggle("Líneas / Tracers VIP", "Dibuja una línea directa hacia cada enemigo a cualquier distancia", function(s)
    State.EspTracers = s
    if not s then
        for _, t in pairs(ESPTracers) do
            if t and t.Object then t.Object.Visible = false end
        end
    end
    SaveConfig(true)
end)

VisualSec:NewDropdown("Origen de las Líneas", "Punto de salida del tracer", {"Abajo", "Centro", "Ratón"}, function(v)
    if v == "Abajo" then State.TracerOrigin = "Bottom"
    elseif v == "Centro" then State.TracerOrigin = "Center"
    elseif v == "Ratón" then State.TracerOrigin = "Mouse"
    end
    SaveConfig(true)
end)

local WarnSec = VisualTab:NewSection("── ⚠️ DETECCIÓN DE PELIGRO ──")

UI_Toggles.BackWarningEnabled = WarnSec:NewToggle("Alerta de Enemigo a las Espaldas", "Banner en pantalla si alguien viene por detrás", function(s)
    State.BackWarningEnabled = s
    if not s and BackWarningLabel then BackWarningLabel.Visible = false end
    SaveConfig(true)
end)

UI_Toggles.WarnAllWeapons = WarnSec:NewToggle("Notificar Armas Equipadas (Todas)", "Avisa cuando cualquier enemigo saca un arma", function(s)
    State.WarnAllWeapons = s
    SaveConfig(true)
end)

local StealthSec = VisualTab:NewSection("── 🕵️ MODO SIGILO RÁPIDO ──")
StealthSec:NewButton("👁️ Ocultar TODO el ESP (sigilo rápido)", "Esconde toda la info visual de golpe", function()
    State.EspGlow        = false
    State.EspShowNames   = false
    State.EspShowHealth  = false
    State.EspShowWeapons = false
    State.EspTracers     = false
    for _, t in pairs(ESPTracers) do if t and t.Object then t.Object.Visible = false end end
    for _, hl in pairs(ESPHighlights) do if hl then hl.Enabled = false end end
    for _, els in pairs(ESPElements) do
        if els.NameLabel then els.NameLabel.Visible = false end
                if els.PingLabel then els.PingLabel.Visible = false end  -- [VIP_PING_TOGGLE_ADDED]
        if els.HealthBg then els.HealthBg.Visible = false end
        if els.HealthLabel then els.HealthLabel.Visible = false end
        if els.WeaponsLabel then els.WeaponsLabel.Visible = false end
    end
    if UI_Toggles.EspGlow then UI_Toggles.EspGlow:UpdateToggle(nil, false) end
    if UI_Toggles.EspShowNames then UI_Toggles.EspShowNames:UpdateToggle(nil, false) end
    if UI_Toggles.EspShowHealth then UI_Toggles.EspShowHealth:UpdateToggle(nil, false) end
    if UI_Toggles.EspShowWeapons then UI_Toggles.EspShowWeapons:UpdateToggle(nil, false) end
    SaveConfig(true)
    ShowNotification("🕵️ Sigilo", "Todo el ESP ocultado al instante.")
end)
StealthSec:NewButton("✅ Mostrar TODO el ESP (restaurar)", "Vuelve a mostrar toda la info", function()
    State.EspGlow        = true
    State.EspShowNames   = true
    State.EspShowHealth  = true
    State.EspShowWeapons = true
    for _, hl in pairs(ESPHighlights) do if hl then hl.Enabled = true end end
    for _, els in pairs(ESPElements) do
        if els.NameLabel then els.NameLabel.Visible = true end
                if els.PingLabel then els.PingLabel.Visible = (State.EspShowNames == true) end
        if els.HealthBg then els.HealthBg.Visible = true end
        if els.HealthLabel then els.HealthLabel.Visible = true end
        if els.WeaponsLabel then els.WeaponsLabel.Visible = true end
    end
    if UI_Toggles.EspGlow then UI_Toggles.EspGlow:UpdateToggle(nil, true) end
    if UI_Toggles.EspShowNames then UI_Toggles.EspShowNames:UpdateToggle(nil, true) end
    if UI_Toggles.EspShowHealth then UI_Toggles.EspShowHealth:UpdateToggle(nil, true) end
    if UI_Toggles.EspShowWeapons then UI_Toggles.EspShowWeapons:UpdateToggle(nil, true) end
    SaveConfig(true)
    ShowNotification("👁️ ESP", "Todo el ESP restaurado.")
end)

local isBindingEspKey = false
local btnBindEsp
btnBindEsp = StealthSec:NewButton(FormatKeyDisplay("Sigilo / Ocultar ESP", State.EspKey), "Haz clic y presiona una tecla o BOTÓN DEL CONTROL", function()
    if isBindingEspKey then return end
    isBindingEspKey = true
    ShowNotification("🎮 Sigilo ESP", "👉 Presiona una tecla o BOTÓN DEL CONTROL...")
    local conn
    conn = UserInputService.InputBegan:Connect(function(input, gpe)
        local isGp = input.UserInputType.Name:find("Gamepad")
        local isKb = (input.UserInputType == Enum.UserInputType.Keyboard)
        if (isKb or isGp) and input.KeyCode.Name ~= "Unknown" then
            conn:Disconnect()
            State.EspKey = input.KeyCode.Name
            SaveConfig(true)
            pcall(function()
                if btnBindEsp and btnBindEsp.UpdateButton then
                    btnBindEsp:UpdateButton(FormatKeyDisplay("Sigilo / Ocultar ESP", input.KeyCode.Name))
                end
            end)
            ShowNotification("✅ Botón Asignado", "Sigilo ESP fijado en: [" .. input.KeyCode.Name .. "]")
            isBindingEspKey = false
        end
    end)
    task.delay(6, function()
        if isBindingEspKey then
            isBindingEspKey = false
            pcall(function() conn:Disconnect() end)
        end
    end)
end)

StealthSec:NewTextBox("✏️ Tecla Sigilo ESP", "Ej: P, L, DPadDown...", function(txt)
    if txt and #txt >= 1 then
        local cleanKey = txt:gsub("%s+", ""):upper()
        State.EspKey = cleanKey
        SaveConfig(true)
        pcall(function()
            if btnBindEsp and btnBindEsp.UpdateButton then
                btnBindEsp:UpdateButton("⌨️ Asignar Tecla Sigilo / ESP: [" .. cleanKey .. "]")
            end
        end)
        ShowNotification("✅ Tecla Asignada", "Sigilo ESP cambiado a: [" .. cleanKey .. "]")
    end
end)



local RadarSec = VisualTab:NewSection("── 🗺️ MINI-RADAR TÁCTICO 2D ──")
UI_Toggles.RadarEnabled = RadarSec:NewToggle("Activar Radar 360°", "Mini-mapa en pantalla con la posición de todos los jugadores", function(s)
    State.RadarEnabled = s
    if RadarGui then RadarGui.Enabled = s end
end)
RadarSec:NewSlider("Rango del Radar (Studs)", "Distancia máxima que detecta el radar", 250, 60, function(val)
    State.RadarRange = val
end)

local BrightSec = VisualTab:NewSection("── 🕶️ VISIÓN NOCTURNA / FULLBRIGHT ──")
UI_Toggles.FullBrightEnabled = BrightSec:NewToggle("Activar FullBright (Cero Oscuridad)", "Ilumina todo el mapa al 100% para ver en la noche y túneles", function(s)
    ApplyFullBright(s)
end)

local CrossSec = VisualTab:NewSection("── 🎯 MIRA PERSONALIZADA VIP ──")
UI_Toggles.CrosshairEnabled = CrossSec:NewToggle("Activar Mira Táctica Neón", "Dibuja una retícula 100% simétrica y centrada en tu pantalla", function(s)
    State.CrosshairEnabled = s
    if CrosshairGui then CrosshairGui.Enabled = s end
end)
CrossSec:NewDropdown("Diseño / Estilo de la Mira", "Elige el aspecto táctico de tu retícula", {
    "Cruz Táctica",
    "Punto Neón",
    "Cruz Hueca (Sin Punto)",
    "Forma T",
    "Círculo Táctico",
    "Caja Cuadrada",
    "Cruz con Círculo (Híbrida)"
}, function(v)
    State.CrosshairStyle = v
    UpdateCrosshairLayout()
end)
CrossSec:NewDropdown("Color de la Mira", "Elige el color neón de tu retícula", {"Cian Neón", "Verde Esmeralda", "Rojo Rubí", "Amarillo Eléctrico", "Blanco Puro"}, function(v)
    UpdateCrosshairColor(v)
end)
CrossSec:NewSlider("Tamaño de la Mira (Largo)", "Longitud de los brazos de la retícula", 16, 4, function(val)
    State.CrosshairSize = val
    UpdateCrosshairLayout()
end)
CrossSec:NewSlider("Separación del Centro (Gap)", "Distancia de los brazos al punto central", 10, 1, function(val)
    State.CrosshairGap = val
    UpdateCrosshairLayout()
end)

-- (Sección de Cajas removida para rendimiento)

-- PESTAÑA DE CONFIGURACIÓN
local ConfigTab = Window:NewTab("⚙️ Ajustes")

local SkinSec = ConfigTab:NewSection("── 🎨 Skins & Decoración del Menú ──")

local function ApplyMenuSkin(skinName)
    local schemes = {
        ["🌟 Dorado VIP (Oro & Negro)"] = Color3.fromRGB(255, 184, 0),
        ["🟣 Cyber Neón (Púrpura)"]     = Color3.fromRGB(168, 85, 247),
        ["💎 Azul Hielo (Neverlose)"]   = Color3.fromRGB(0, 229, 255),
        ["🔴 Blood Carmesí (Rojo)"]     = Color3.fromRGB(255, 46, 77),
        ["🟢 Matrix Hacker (Verde)"]    = Color3.fromRGB(0, 255, 136)
    }
    local scheme = schemes[skinName] or Color3.fromRGB(255, 184, 0)
    pcall(function()
        local parentGui = game:GetService("CoreGui"):FindFirstChild("🍗 Hermanos alitas de pollo 🍗")
        if not parentGui then
            parentGui = LocalPlayer:FindFirstChildOfClass("PlayerGui"):FindFirstChild("🍗 Hermanos alitas de pollo 🍗")
        end
        if not parentGui then return end

        for _, desc in ipairs(parentGui:GetDescendants()) do
            if desc:IsA("TextLabel") and desc.Name == "sectionHead" then
                desc.TextColor3 = scheme
            elseif desc:IsA("ImageLabel") and desc.Name == "viewInfo" then
                desc.ImageColor3 = scheme
            end
        end

        local main = parentGui:FindFirstChild("Main")
        if main then
            local stroke = main:FindFirstChild("VIP_MenuStroke")
            if stroke then stroke.Color = scheme end
        end
    end)
    ShowNotification("🎨 Skin del Menú", "Tema aplicado: " .. tostring(skinName))
end

SkinSec:NewDropdown("Elegir Skin / Tema del Menú", "Cambia el color y aspecto de todo el menú", {
    "🌟 Dorado VIP (Oro & Negro)",
    "🟣 Cyber Neón (Púrpura)",
    "💎 Azul Hielo (Neverlose)",
    "🔴 Blood Carmesí (Rojo)",
    "🟢 Matrix Hacker (Verde)"
}, function(selected)
    ApplyMenuSkin(selected)
end)

UI_Toggles.ShowWatermark = SkinSec:NewToggle("Mostrar Watermark VIP en Pantalla", "HUD flotante con tus FPS, Ping y Rango", function(s)
    if WatermarkGui then
        WatermarkGui.Enabled = s
    end
end)


local BoostSec = ConfigTab:NewSection("── ⚡ RENDIMIENTO & FPS BOOST ──")
UI_Toggles.PotatoBoost = BoostSec:NewToggle("Modo Turbo FPS (Potato Boost)", "Apaga sombras, humo, partículas y efectos pesados para duplicar FPS", function(s)
    ApplyPotatoBoost(s)
end)

UI_Toggles.FlatTextures = BoostSec:NewToggle("🧱 Texturas Planas (Sin Textura)", "Quita TODAS las texturas del mapa. Solo se ven colores sólidos (pasto, paredes, etc.)", function(s)
    ApplyFlatTextures(s)
end)

local ConfigSec = ConfigTab:NewSection("── Teclas & Persistencia ──")

local isBindingWatermarkKey = false
local btnBindWatermark
btnBindWatermark = ConfigSec:NewButton(FormatKeyDisplay("Ocultar/Mostrar Barra VIP", State.WatermarkKey or "K"), "Presiona una tecla para activar/ocultar la barra de FPS/VIP", function()
    if isBindingWatermarkKey then return end
    isBindingWatermarkKey = true
    ShowNotification("⚡ Tecla Barra VIP", "👉 Presiona una tecla para ocultar/mostrar la barra...")
    local conn
    conn = UserInputService.InputBegan:Connect(function(input, gpe)
        local isGp = input.UserInputType.Name:find("Gamepad")
        local isKb = (input.UserInputType == Enum.UserInputType.Keyboard)
        if (isKb or isGp) and input.KeyCode.Name ~= "Unknown" then
            conn:Disconnect()
            State.WatermarkKey = input.KeyCode.Name
            SaveConfig(true)
            pcall(function()
                if btnBindWatermark and btnBindWatermark.UpdateButton then
                    btnBindWatermark:UpdateButton(FormatKeyDisplay("Ocultar/Mostrar Barra VIP", input.KeyCode.Name))
                end
            end)
            ShowNotification("✅ Tecla Asignada", "Barra VIP fijada en: [" .. input.KeyCode.Name .. "]")
            isBindingWatermarkKey = false
        end
    end)
    task.delay(6, function()
        if isBindingWatermarkKey then
            isBindingWatermarkKey = false
            pcall(function() conn:Disconnect() end)
        end
    end)
end)

ConfigSec:NewTextBox("✏️ Tecla Barra VIP", "Ej: K, L, N...", function(txt)
    if txt and #txt >= 1 then
        local cleanKey = txt:gsub("%s+", "")
        if #cleanKey == 1 then cleanKey = cleanKey:upper() end
        State.WatermarkKey = cleanKey
        SaveConfig(true)
        pcall(function()
            if btnBindWatermark and btnBindWatermark.UpdateButton then
                btnBindWatermark:UpdateButton(FormatKeyDisplay("Ocultar/Mostrar Barra VIP", cleanKey))
            end
        end)
        ShowNotification("✅ Barra VIP", "Tecla cambiada a: [" .. cleanKey .. "]")
    end
end)

local isBindingMenuKey = false
local btnBindMenu
btnBindMenu = ConfigSec:NewButton(FormatKeyDisplay("Abrir/Cerrar Menú", State.MenuKey), "Haz clic y presiona una tecla o BOTÓN DEL CONTROL", function()
    if isBindingMenuKey then return end
    isBindingMenuKey = true
    ShowNotification("🎮 Menú VIP", "👉 Presiona una tecla o BOTÓN DEL CONTROL...")
    local conn
    conn = UserInputService.InputBegan:Connect(function(input, gpe)
        local isGp = input.UserInputType.Name:find("Gamepad")
        local isKb = (input.UserInputType == Enum.UserInputType.Keyboard)
        if (isKb or isGp) and input.KeyCode.Name ~= "Unknown" then
            conn:Disconnect()
            State.MenuKey = input.KeyCode.Name
            SaveConfig(true)
            pcall(function()
                if btnBindMenu and btnBindMenu.UpdateButton then
                    btnBindMenu:UpdateButton(FormatKeyDisplay("Abrir/Cerrar Menú", input.KeyCode.Name))
                end
            end)
            ShowNotification("✅ Botón Asignado", "Menú VIP fijado en: [" .. input.KeyCode.Name .. "]")
            isBindingMenuKey = false
        end
    end)
    task.delay(6, function()
        if isBindingMenuKey then
            isBindingMenuKey = false
            pcall(function() conn:Disconnect() end)
        end
    end)
end)

ConfigSec:NewTextBox("✏️ Tecla Menú VIP", "Ej: M, ButtonSelect...", function(txt)
    if txt and #txt >= 1 then
        local cleanKey = txt:gsub("%s+", "")
        if #cleanKey == 1 then cleanKey = cleanKey:upper() end
        State.MenuKey = cleanKey
        SaveConfig(true)
        pcall(function()
            if btnBindMenu and btnBindMenu.UpdateButton then
                btnBindMenu:UpdateButton("⌨️ Asignar Tecla Menú VIP: [" .. cleanKey .. "]")
            end
        end)
        ShowNotification("✅ Menú VIP", "Tecla del menú cambiada a: [" .. cleanKey .. "]")
    end
end)

ConfigSec:NewButton("💾 Guardar Configuración Ahora", "Guarda todos tus cambios en el almacenamiento", function()
    SaveConfig(false)
end)

local function SyncUIWithConfig()
    pcall(function()
        for key, toggleObj in pairs(UI_Toggles) do
            if State[key] ~= nil and toggleObj and toggleObj.UpdateToggle then
                toggleObj:UpdateToggle(nil, State[key] == true)
            end
        end
        if btnBindAimbot and btnBindAimbot.UpdateButton then
            btnBindAimbot:UpdateButton(FormatKeyDisplay("Asignar Aimbot", State.AimbotKey))
        end
        if btnBindPart and btnBindPart.UpdateButton then
            btnBindPart:UpdateButton(FormatKeyDisplay("Alternar Cabeza/Pecho", State.TogglePartKey))
        end
        if btnBindMenu and btnBindMenu.UpdateButton then
            btnBindMenu:UpdateButton(FormatKeyDisplay("Abrir/Cerrar Menú", State.MenuKey))
        end
        if btnBindWatermark and btnBindWatermark.UpdateButton then
            btnBindWatermark:UpdateButton(FormatKeyDisplay("Ocultar/Mostrar Barra VIP", State.WatermarkKey or "K"))
        end
        if btnBindEsp and btnBindEsp.UpdateButton then
            btnBindEsp:UpdateButton(FormatKeyDisplay("Sigilo / Ocultar ESP", State.EspKey))
        end
    end)
end

ConfigSec:NewButton("📂 Recargar Configuración Guardada", "Carga tus ajustes previamente guardados", function()
    LoadConfig(false)
    if State.DeviceMode then
        ApplyDeviceSettings(State.DeviceMode)
    end
    SyncUIWithConfig()
end)

task.spawn(function()
    task.wait(0.2)
    SyncUIWithConfig()
end)

local DangerSec = ConfigTab:NewSection("── ⚠️ Peligro ──")
DangerSec:NewButton("🔴 CERRAR SCRIPT COMPLETAMENTE", "Apaga todo y limpia el script de memoria", function()
    ShowNotification("🍗 Script", "Cerrando script... Adiós!")
    task.wait(0.5)
    -- Ejecutar la limpieza completa
    if getgenv and getgenv().AlitasDePollo_Cleanup then
        pcall(getgenv().AlitasDePollo_Cleanup)
    end
    -- Destruir la UI de Kavo
    pcall(function() Library:Destroy() end)
end)

-- PESTAÑA OWNER & CONTROL DE USUARIOS
local OwnerTab = Window:NewTab("👑 Root Owner")
local OwnerTrackerSec = OwnerTab:NewSection("── 👑 ROOT OWNER PANEL ──")

local customSpoofText = "Alitas_Official_Owner"
local VideoSpoofSec = OwnerTab:NewSection("── 🎬 BYPASS DE NOMBRE & STREAM ──")

local function ApplyNameSpoof()
    if not State.SpoofNameEnabled or not State.SpoofedName or #State.SpoofedName == 0 then return end
    pcall(function()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.DisplayName ~= State.SpoofedName then
                hum.DisplayName = State.SpoofedName
            end
            for _, obj in ipairs(char:GetDescendants()) do
                if obj:IsA("BillboardGui") then
                    for _, lbl in ipairs(obj:GetDescendants()) do
                        if (lbl:IsA("TextLabel") or lbl:IsA("TextButton")) and lbl.Text ~= State.SpoofedName then
                            local t = lbl.Text:lower()
                            if t:find(LocalPlayer.Name:lower()) or t:find(LocalPlayer.DisplayName:lower()) then
                                lbl.Text = State.SpoofedName
                            end
                        end
                    end
                end
            end
        end
    end)
end

local _spoofFrame = 0
local spoofConn = RunService.Heartbeat:Connect(function()
    if State.SpoofNameEnabled then
        _spoofFrame = _spoofFrame + 1
        if _spoofFrame % 30 == 0 then
            ApplyNameSpoof()
        end
    end
end)
table.insert(Cleanups, spoofConn)

local charAddedSpoofConn = LocalPlayer.CharacterAdded:Connect(function()
    if State.SpoofNameEnabled then
        task.wait(0.5)
        ApplyNameSpoof()
    end
end)
table.insert(Cleanups, charAddedSpoofConn)

VideoSpoofSec:NewTextBox("Nombre Falso para Video", "Escribe el nombre falso para grabar", function(txt)
    if txt and #txt > 1 then customSpoofText = txt end
end)

UI_Toggles.SpoofName = VideoSpoofSec:NewToggle("Mantener Nombre Oculto Continuamente", "Auto-reaplica el nombre aunque mueras", function(s)
    State.SpoofNameEnabled = s
    if s then
        State.SpoofedName = customSpoofText
        ApplyNameSpoof()
        ShowNotification("🎬 Modo Creador", "✅ Nombre falso activo: " .. customSpoofText)
    else
        ShowNotification("🎬 Modo Creador", "❌ Nombre falso desactivado")
    end
    SaveConfig(true)
end)

VideoSpoofSec:NewButton("🎭 Cambiar Mi Nombre en Pantalla", "Aplica el nombre falso de inmediato", function()
    State.SpoofNameEnabled = true
    State.SpoofedName = customSpoofText
    ApplyNameSpoof()
    if UI_Toggles.SpoofName and UI_Toggles.SpoofName.UpdateToggle then
        UI_Toggles.SpoofName:UpdateToggle(nil, true)
    end
    SaveConfig(true)
    ShowNotification("🎬 Modo Creador", "✅ Nombre en pantalla cambiado a: " .. customSpoofText)
end)

OwnerTrackerSec:NewButton("👥 Ver autorizados en este servidor", "Muestra quién tiene el script activo", function()
    local activeInServer = {}
    for _, p in ipairs(Players:GetPlayers()) do
        local pName = p.Name:lower()
        if AccessControl.AuthorizedUsers[pName] then
            local role = (pName == OWNER_NAME:lower()) and "(👑 OWNER)" or "(🎮 MIEMBRO VIP)"
            table.insert(activeInServer, p.DisplayName .. " (@" .. p.Name .. ") " .. role)
        end
    end
    print("========================================")
    print("🍗 [HERMANOS ALITAS] ACTIVOS EN SERVIDOR (" .. #activeInServer .. "):")
    for _, info in ipairs(activeInServer) do print("  🟢 " .. info) end
    print("========================================")
    ShowNotification("🍗 Usuarios activos", #activeInServer .. " activo(s). Revisa F9 (consola).")
end)

OwnerTrackerSec:NewButton("📜 Lista completa de la Whitelist", "Muestra todos los miembros autorizados (F9)", function()
    local count = 0
    print("========================================")
    print("🍗 [HERMANOS ALITAS] WHITELIST COMPLETA:")
    for user, _ in pairs(AccessControl.AuthorizedUsers) do
        count = count + 1
        local tag = OWNER_NAMES[user] and " 👑 OWNER" or " 🎮 VIP"
        print("  🔑 #" .. count .. " -> " .. user .. tag)
    end
    print("========================================")
    ShowNotification("🍗 Whitelist", count .. " usuario(s) en la lista. Abre F9.")
end)

local OwnerInfoSec = OwnerTab:NewSection("── ℹ️ Cómo agregar miembros ──")
OwnerInfoSec:NewButton("📋 ¿Cómo autorizar a alguien?", "Muestra instrucciones en la consola F9", function()
    print("========================================")
    print("🍗 PARA AGREGAR UN MIEMBRO:")
    print("  1. Pídele su username EXACTO de Roblox")
    print("  2. Díselo al creador del script (hermanos_alaspollito)")
    print("  3. El creador actualiza el script y te manda el link nuevo")
    print("  4. Con el nuevo link, todos los miembros anteriores")
    print("     siguen teniendo acceso sin hacer nada")
    print("========================================")
    ShowNotification("🍗 Owner Info", "Instrucciones en la consola F9")
end)

print("[🍗] Hermanos alitas de pollo VIP v12.3 cargado. Owner: " .. OWNER_NAME)

