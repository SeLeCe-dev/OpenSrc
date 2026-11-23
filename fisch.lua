local warn = function() end
local print = function() end
_G.UpdateFishingStatus = function() end
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Window = WindUI:CreateWindow({
    Title = "Fisch",
    Icon = "fish",
    Author = "Fisch Edition",
    Folder = "WindUIFisch",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
})
function Window:Notify(cfg)
    cfg = type(cfg) == "table" and cfg or {}
    pcall(function()
        WindUI:Notify({
            Title = cfg.Title or "Fisch",
            Content = cfg.Content or cfg.SubContent or "",
            Duration = cfg.Duration or 4,
        })
    end)
end
local function adaptSection(tab, sectionTitle)
    local sec = {}
    local realSec = nil
    local function getSec()
        if not realSec then
            realSec = tab:Section({ Title = sectionTitle, Opened = true })
        end
        return realSec
    end
    function sec:AddToggle(opts, arg2, arg3, arg4)
        local target = getSec()
        local title, desc, defaultVal, callback
        if type(opts) == "string" then
            title = opts
            defaultVal = type(arg2) == "boolean" and arg2 or false
            callback = type(arg3) == "function" and arg3 or (type(arg4) == "function" and arg4) or function() end
        elseif type(opts) == "table" then
            title = opts.Title or opts.Name or opts[1] or "Toggle"
            desc = opts.Content or opts.Description or opts.Desc
            defaultVal = opts.Default ~= nil and opts.Default or (opts.Value ~= nil and opts.Value or false)
            callback = opts.Callback or function() end
        else
            title, defaultVal, callback = "Toggle", false, function() end
        end
        local handle
        handle = target:Toggle({
            Title = title,
            Desc = desc,
            Value = defaultVal == true,
            Callback = function(val)
                if handle then handle.Value = val end
                pcall(callback, val)
            end
        })
        if handle then
            local rawSet = handle.Set
            local rawSetValue = handle.SetValue
            handle.Value = defaultVal == true
            handle.Set = function(self, val)
                local v = (val ~= nil) and val or self
                if rawSetValue then
                    pcall(rawSetValue, handle, v)
                elseif rawSet then
                    pcall(rawSet, handle, v)
                end
                handle.Value = v
            end
        end
        return handle
    end
    function sec:AddDropdown(opts, arg2, arg3, arg4)
        local target = getSec()
        local title, desc, rawItems, isMulti, defaultVal, callback
        if type(opts) == "string" then
            title = opts
            rawItems = type(arg2) == "table" and arg2 or {}
            defaultVal = arg3
            callback = type(arg4) == "function" and arg4 or function() end
            isMulti = false
        elseif type(opts) == "table" then
            title = opts.Title or opts.Name or (type(opts[1]) == "string" and opts[1]) or "Dropdown"
            desc = opts.Content or opts.Description or opts.Desc
            if type(opts.Options) == "table" then
                rawItems = opts.Options
            elseif type(opts.Values) == "table" then
                rawItems = opts.Values
            elseif type(opts.Items) == "table" then
                rawItems = opts.Items
            elseif type(opts.List) == "table" then
                rawItems = opts.List
            elseif type(opts[4]) == "table" then
                rawItems = opts[4]
            elseif type(opts[2]) == "table" then
                rawItems = opts[2]
            elseif type(opts[3]) == "table" then
                rawItems = opts[3]
            else
                rawItems = {}
            end
            if opts.Multi ~= nil then
                isMulti = opts.Multi == true
            elseif opts.Multiple ~= nil then
                isMulti = opts.Multiple == true
            elseif type(opts[3]) == "boolean" then
                isMulti = opts[3]
            else
                isMulti = false
            end
            if opts.Default ~= nil then
                defaultVal = opts.Default
            elseif opts.Value ~= nil then
                defaultVal = opts.Value
            elseif type(opts[5]) == "string" or type(opts[5]) == "table" then
                defaultVal = opts[5]
            elseif isMulti then
                defaultVal = {}
            elseif type(rawItems) == "table" and #rawItems > 0 then
                defaultVal = rawItems[1]
            else
                defaultVal = ""
            end
            if type(opts.Callback) == "function" then
                callback = opts.Callback
            elseif type(opts[6]) == "function" then
                callback = opts[6]
            elseif type(opts[5]) == "function" then
                callback = opts[5]
            elseif type(opts[4]) == "function" then
                callback = opts[4]
            else
                callback = function() end
            end
        else
            title, rawItems, isMulti, defaultVal, callback = "Dropdown", {}, false, "", function() end
        end
        if type(rawItems) ~= "table" then
            rawItems = {}
        end
        local function formatMulti(val)
            if type(val) ~= "table" then return val end
            local res = {}
            for k, v in pairs(val) do
                if v == true then
                    res[k] = true
                elseif type(v) == "string" then
                    res[v] = true
                end
            end
            return res
        end
        local windDefault = defaultVal
        if isMulti then
            local arr = {}
            if type(defaultVal) == "table" then
                for k, v in pairs(defaultVal) do
                    if v == true and type(k) == "string" then
                        table.insert(arr, k)
                    elseif type(v) == "string" then
                        table.insert(arr, v)
                    end
                end
            end
            windDefault = arr
        elseif type(defaultVal) == "number" and rawItems[defaultVal] ~= nil then
            windDefault = rawItems[defaultVal]
        end
        local handle
        handle = target:Dropdown({
            Title = title,
            Desc = desc,
            Values = rawItems,
            Value = windDefault,
            Multi = isMulti,
            AllowNone = true,
            Callback = function(val)
                local processed = isMulti and formatMulti(val) or val
                if handle then handle.Value = processed end
                pcall(callback, processed)
            end
        })
        if handle then
            local rawRefresh = handle.Refresh
            local rawSelect = handle.Select
            local rawSetValue = handle.SetValue
            local rawSet = handle.Set
            local initialVal = isMulti and formatMulti(windDefault) or windDefault
            handle.Value = initialVal
            handle.Refresh = function(self, newOpts)
                local list = (type(newOpts) == "table" and newOpts) or (type(self) == "table" and self ~= handle and self) or {}
                if rawRefresh then
                    pcall(rawRefresh, handle, list)
                end
            end
            handle.SetValues = handle.Refresh
            handle.SetItems = handle.Refresh
            handle.Set = function(self, val)
                local v = (val ~= nil) and val or self
                if rawSelect then
                    pcall(rawSelect, handle, v)
                elseif rawSetValue then
                    pcall(rawSetValue, handle, v)
                elseif rawSet then
                    pcall(rawSet, handle, v)
                end
                handle.Value = isMulti and formatMulti(v) or v
            end
            pcall(callback, handle.Value)
        end
        return handle
    end
    function sec:AddSlider(opts, arg2, arg3, arg4, arg5)
        local target = getSec()
        local title, desc, minVal, maxVal, defaultVal, callback, rounding
        if type(opts) == "string" then
            title = opts
            minVal = type(arg2) == "number" and arg2 or 0
            maxVal = type(arg3) == "number" and arg3 or 100
            defaultVal = type(arg4) == "number" and arg4 or minVal
            callback = type(arg5) == "function" and arg5 or function() end
            rounding = 0
        elseif type(opts) == "table" then
            title = opts.Title or opts.Name or opts[1] or "Slider"
            desc = opts.Content or opts.Description or opts.Desc
            minVal = opts.Min or 0
            maxVal = opts.Max or 100
            defaultVal = opts.Default ~= nil and opts.Default or minVal
            callback = opts.Callback or function() end
            rounding = opts.Rounding or (opts.Increment and (opts.Increment >= 1 and 0 or 2) or 0)
        else
            title, minVal, maxVal, defaultVal, callback, rounding = "Slider", 0, 100, 0, function() end, 0
        end
        local step = rounding > 0 and (1 / (10^rounding)) or 1
        local handle
        handle = target:Slider({
            Title = title,
            Desc = desc,
            Step = step,
            Value = {
                Min = minVal,
                Max = maxVal,
                Default = defaultVal,
            },
            Callback = function(val)
                if handle then handle.Value = val end
                pcall(callback, val)
            end
        })
        if handle then
            local rawSet = handle.Set
            local rawSetValue = handle.SetValue
            handle.Value = defaultVal
            handle.Set = function(self, val)
                local v = (val ~= nil) and val or self
                if rawSetValue then
                    pcall(rawSetValue, handle, v)
                elseif rawSet then
                    pcall(rawSet, handle, v)
                end
                handle.Value = v
            end
        end
        return handle
    end
    function sec:AddInput(opts, arg2, arg3)
        local target = getSec()
        local title, desc, defaultVal, placeholder, callback
        if type(opts) == "string" then
            title = opts
            defaultVal = type(arg2) == "string" and arg2 or ""
            callback = type(arg3) == "function" and arg3 or function() end
            placeholder = "Type here..."
        elseif type(opts) == "table" then
            title = opts.Title or opts.Name or opts[1] or "Input"
            desc = opts.Content or opts.Description or opts.Desc
            defaultVal = tostring(opts.Default or opts.Value or "")
            placeholder = opts.Placeholder or "Type here..."
            callback = opts.Callback or function() end
        else
            title, defaultVal, placeholder, callback = "Input", "", "Type here...", function() end
        end
        local handle
        handle = target:Input({
            Title = title,
            Desc = desc,
            Value = defaultVal,
            Placeholder = placeholder,
            Callback = function(val)
                if handle then handle.Value = val end
                pcall(callback, val)
            end
        })
        if handle then
            local rawSet = handle.Set
            local rawSetValue = handle.SetValue
            handle.Value = defaultVal
            handle.Set = function(self, val)
                local v = (val ~= nil) and val or self
                if rawSetValue then
                    pcall(rawSetValue, handle, v)
                elseif rawSet then
                    pcall(rawSet, handle, v)
                end
                handle.Value = v
            end
        end
        return handle
    end
    function sec:AddButton(opts, arg2)
        local target = getSec()
        local title, desc, callback
        if type(opts) == "string" then
            title = opts
            callback = type(arg2) == "function" and arg2 or function() end
        elseif type(opts) == "table" then
            title = opts.Title or opts.Name or opts[1] or "Button"
            desc = opts.Content or opts.Description or opts.Desc
            callback = opts.Callback or function() end
        else
            title, callback = "Button", function() end
        end
        local handle = target:Button({
            Title = title,
            Desc = desc,
            Callback = callback
        })
        return handle
    end
    function sec:AddParagraph(opts, arg2)
        local target = getSec()
        local title, content
        if type(opts) == "string" then
            title = opts
            content = type(arg2) == "string" and arg2 or (type(arg2) == "table" and (arg2.Content or arg2[1])) or ""
        elseif type(opts) == "table" then
            title = opts.Title or opts.Name or opts[1] or ""
            content = opts.Content or opts.Description or opts.Desc or opts[2] or ""
        else
            title, content = "", ""
        end
        local handle = target:Paragraph({
            Title = title,
            Desc = content
        })
        if handle then
            local rawSetTitle = handle.SetTitle
            local rawSetDesc = handle.SetDesc or handle.SetContent
            handle.SetTitle = function(self, t)
                local val = (t ~= nil) and t or self
                if type(val) == "table" then val = val.Title or val.Content or "" end
                if rawSetTitle then pcall(rawSetTitle, handle, tostring(val or "")) end
            end
            handle.SetContent = function(self, c)
                local val = (c ~= nil) and c or self
                if type(val) == "table" then val = val.Content or val.Title or "" end
                if rawSetDesc then pcall(rawSetDesc, handle, tostring(val or "")) end
            end
            handle.Set = function(self, data)
                local d = (data ~= nil) and data or self
                if type(d) == "table" then
                    if d.Title then handle:SetTitle(d.Title) end
                    if d.Content or d.Desc then handle:SetContent(d.Content or d.Desc) end
                elseif type(d) == "string" then
                    handle:SetContent(d)
                end
            end
        end
        return handle
    end
    function sec:AddSeperator(opts)
        local target = getSec()
        if target.Divider then
            return target:Divider()
        end
    end
    return sec
end
local OperationsGroup = Window:Section({ Title = "Operations", Opened = true })
local NavigationGroup = Window:Section({ Title = "Navigation & Economy", Opened = true })
local UtilitiesGroup = Window:Section({ Title = "Utilities", Opened = true })
local Tabs = {
    Info = OperationsGroup:Tab({ Title = "Info", Icon = "info" }),
    Main = OperationsGroup:Tab({ Title = "Fishing", Icon = "crosshair" }),
    Auto = OperationsGroup:Tab({ Title = "Automation", Icon = "zap" }),
    Shop = NavigationGroup:Tab({ Title = "Shop & Sell", Icon = "shopping-cart" }),
    Trade = NavigationGroup:Tab({ Title = "Trading", Icon = "package" }),
    Teleports = NavigationGroup:Tab({ Title = "Teleports", Icon = "map-pin" }),
    Exclusives = UtilitiesGroup:Tab({ Title = "Visual & Events", Icon = "eye" }),
    Misc = UtilitiesGroup:Tab({ Title = "Misc & Settings", Icon = "sliders-horizontal" }),
    Webhook = UtilitiesGroup:Tab({ Title = "Server & Webhook", Icon = "globe" }),
}
Infr = adaptSection(Tabs.Info, "Information & Status")
AutoFishing = adaptSection(Tabs.Main, "Auto Fishing")
autoFishSettings = adaptSection(Tabs.Main, "Fishing Delays")
FishingZone = adaptSection(Tabs.Main, "Zone & Teleport")
AutoFish = adaptSection(Tabs.Main, "Instant & Metronome")
SnapReelSection = adaptSection(Tabs.Main, "Snap Reel (Filter Catch)")
SpearSection = adaptSection(Tabs.Main, "Spear Fishing")
RodShop = adaptSection(Tabs.Shop, "Equipment & Bait Shop")
BaitShop = RodShop
ItemsShop = adaptSection(Tabs.Shop, "Items & Totems Shop")
TotemSection = ItemsShop
MerlinShop = ItemsShop
BlackMarketSection = adaptSection(Tabs.Shop, "Black Market & Daily Shop")
DailyShopSection = BlackMarketSection
Selling = adaptSection(Tabs.Shop, "Auto Selling")
BoatShop = adaptSection(Tabs.Shop, "Boat Merchant")
AutoTab = adaptSection(Tabs.Auto, "Fish Appraising")
TreasureApp = AutoTab
Ench = adaptSection(Tabs.Auto, "Enchants & Relics")
OpenCrate = Ench
Totem = adaptSection(Tabs.Auto, "Totems, Potions & Summon")
AutoPotionSection = Totem
AutoSummonSection = Totem
FoodSection = adaptSection(Tabs.Auto, "Aquarium & Favoriting")
Favoriteee = FoodSection
TreasureMarrow = adaptSection(Tabs.Auto, "Treasure & Minigames")
MineSection = TreasureMarrow
CrabCages = TreasureMarrow
FischFestSection = TreasureMarrow
Quest = adaptSection(Tabs.Auto, "Quests & Secrets")
TradeFeature = adaptSection(Tabs.Trade, "Trade Features")
TeleportSection = adaptSection(Tabs.Teleports, "World & Fishing Areas")
BestSpot = TeleportSection
NPC = adaptSection(Tabs.Teleports, "NPCs & Interactables")
Int = NPC
PlayerTeleport = adaptSection(Tabs.Teleports, "Player Teleport")
SavePosition = adaptSection(Tabs.Teleports, "Custom Waypoints")
OTHER = adaptSection(Tabs.Teleports, "Special & Coordinates")
ESPFeature = adaptSection(Tabs.Exclusives, "ESP Visuals")
EventHuntSection = adaptSection(Tabs.Exclusives, "Event Boss Hunting")
Other = adaptSection(Tabs.Misc, "Player Modifications")
Oxygen = Other
AutoBoatSection = adaptSection(Tabs.Misc, "Boat & Vehicles")
Misc = adaptSection(Tabs.Misc, "Environment & Graphics")
Screen = Misc
SaveConfig2 = adaptSection(Tabs.Misc, "Configuration")
ServerSection = adaptSection(Tabs.Webhook, "Server Management")
WebhookSection = adaptSection(Tabs.Webhook, "Fish Caught Webhook")
JoinJob = ServerSection
Server = ServerSection
Caught = WebhookSection
VarService = {
    TweenService = game:GetService("TweenService"),
    Players = game:GetService("Players"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    HttpService = game:GetService("HttpService"),
    GuiService = game:GetService("GuiService"),
    RunService = game:GetService("RunService"),
    Workspace = game:GetService("Workspace"),
    CoreGui = game:GetService("StarterGui"),
    ContextActionService = game:GetService("ContextActionService"),
    UserInputService = game:GetService("UserInputService"),
    TeleportService = game:GetService("TeleportService"),
    TextService = game:GetService("TextService"),
    CollectionService = game:GetService("CollectionService"),
    PathfindingService = game:GetService("PathfindingService"),
    Lighting = game:GetService("Lighting"),
    VirtualUser = (function()
        local vu = nil
        pcall(function() vu = game:GetService("VirtualUser") end)
        return vu
    end)(),
    MarketplaceService = game:GetService("MarketplaceService"),
}
Services = VarService
TweenService = VarService.TweenService
Players = VarService.Players
ReplicatedStorage = VarService.ReplicatedStorage
HttpService = VarService.HttpService
GuiService = VarService.GuiService
RunService = VarService.RunService
Workspace = VarService.Workspace
CoreGui = VarService.CoreGui
ContextActionService = VarService.ContextActionService
UserInputService = VarService.UserInputService
TeleportService = VarService.TeleportService
TextService = VarService.TextService
CollectionService = VarService.CollectionService
PathfindingService = VarService.PathfindingService
Lighting = VarService.Lighting
VirtualUser = VarService.VirtualUser
MarketplaceService = VarService.MarketplaceService
if not Players.LocalPlayer then
    repeat task.wait() until Players.LocalPlayer
end
VarGames = {
    Player = Players.LocalPlayer,
    LocalPlayer = Players.LocalPlayer,
    Character = Players.LocalPlayer.Character,
    HumanoidRootPart = nil,
    UserPlayer = nil,
    ActiveFolder = Workspace:FindFirstChild("active"),
    FishingZonesFolder = (Workspace:FindFirstChild("zones") and (Workspace.zones:FindFirstChild("fishing") or Workspace.zones:WaitForChild("fishing", 3))),
    TpSpotsFolder = Workspace:FindFirstChild("world") and Workspace.world:FindFirstChild("spawns") and (Workspace.world.spawns:FindFirstChild("TpSpots") or Workspace.world.spawns:WaitForChild("TpSpots", 3)),
    NpcFolder = Workspace:FindFirstChild("world") and (Workspace.world:FindFirstChild("npcs") or Workspace.world:WaitForChild("npcs", 3)),
    Interact = Workspace:FindFirstChild("world") and (Workspace.world:FindFirstChild("interactables") or Workspace.world:WaitForChild("interactables", 3)),
    PlayerGui = Players.LocalPlayer:FindFirstChild("PlayerGui") or Players.LocalPlayer:WaitForChild("PlayerGui", 3),
    ScreenGui = nil,
    Backpack = Players.LocalPlayer:FindFirstChild("Backpack") or Players.LocalPlayer:WaitForChild("Backpack", 3),
    EventPurchase = ReplicatedStorage:FindFirstChild("events") and ReplicatedStorage.events:FindFirstChild("purchase"),
    ItemsModule = {},
    RodsRaw = {},
    DataList = nil,
    FishData = nil,
    FastReel = {
        Enabled = false,
        Finishing = false,
        CurrentReel = nil,
        ReelToken = 0,
    },
    Genv = genv or {},
    ConfigFile = "MyFishingConfig.json",
    Config = nil,
    FishNames = nil,
}
VarGames.Character = VarGames.LocalPlayer.Character or VarGames.LocalPlayer.CharacterAdded:Wait()
VarGames.HumanoidRootPart = VarGames.Character:FindFirstChild("HumanoidRootPart") or VarGames.Character:WaitForChild("HumanoidRootPart", 3)
VarGames.UserPlayer = VarGames.HumanoidRootPart and (VarGames.HumanoidRootPart:FindFirstChild("user") or VarGames.HumanoidRootPart:WaitForChild("user", 3))
VarGames.ScreenGui = Instance.new("ScreenGui", VarGames.PlayerGui)
pcall(function()
    VarGames.RodsRaw = require(ReplicatedStorage.shared.modules.library.rods)
end)
VarGames.RodsRaw = VarGames.RodsRaw or {}
pcall(function()
    VarGames.ItemsModule = require(ReplicatedStorage.shared.modules.library.items)
end)
VarGames.ItemsModule = VarGames.ItemsModule or {}
pcall(function()
    local d1 = game:HttpGet("https://raw.githubusercontent.com/thantzy/listdata/refs/heads/main/datalist")
    VarGames.DataList = loadstring(d1)()
end)
pcall(function()
    local d12 = game:HttpGet("https://raw.githubusercontent.com/x2neptunereal/Alchemy/refs/heads/main/library/fisch/fish.lua")
    VarGames.FishData = loadstring(d12)()
end)
player = VarGames.Player
LocalPlayer = VarGames.LocalPlayer
LocalCharacter = VarGames.Character
HumanoidRootPart = VarGames.HumanoidRootPart
UserPlayer = VarGames.UserPlayer
ActiveFolder = VarGames.ActiveFolder
FishingZonesFolder = VarGames.FishingZonesFolder
TpSpotsFolder = VarGames.TpSpotsFolder
NpcFolder = VarGames.NpcFolder
Interact = VarGames.Interact
PlayerGui = VarGames.PlayerGui
playerGui = VarGames.PlayerGui
screenGui = VarGames.ScreenGui
Backpack = VarGames.Backpack
event = VarGames.EventPurchase
RodsRaw = VarGames.RodsRaw
ItemsModule = VarGames.ItemsModule
data = VarGames.DataList or {}
fishdata = VarGames.FishData or {}
configFile = VarGames.ConfigFile
_sX = {
    castMode = "Always Perfect",
    autoHopCosmic = false,
    AutoMetronome = false,
    FishingESP = false,
    AreaESP = false,
    ShakeSpeed = 8,
    fastProgressEnabled = false,
    selectedfishfav = "None",
    selectraritiesseel = {},
    selectedmodereel_v = "Faster",
    selectedfishingzone = "None",
    autoshakedelay_v = "0.5",
    autosellrarities = false,
    autosellwhitelist = {},
    autosellwhitelist_v = false,
    activeinstantboober_v = false,
    autofavorite_v = false,
    autostartreel_v = false,
    autosell_v = false,
    priorityShadySell_v = false,
    priorityShadySell = false,
    activecatch_v = false,
    autocast_v = false,
    autoshake_v = false,
    centerShake = false,
    randomCatchChance = 50,
    autoShakeEnabled = false,
    autoequiprod_v = false,
    autototemtarget = false,
    FarDropEnabled = false,
    autoReelEnabled = false,
    autoashclaw_en = false,
    autoReady = false,
    hunttargetv = false,
    AutoBobberAdjustToggle = false,
    AutoAddFish = false,
    ToggleClaimCultist = false,
    autoCastEnabled = false,
    perfectCatchEnabled = false,
    RandomCatchEnabled = false,
    autoBalanceNukeEnabled = true,
    isFishing = false,
    autoEquipState = false,
    autoEquipThread = nil,
    autoTeleportEnabled = false,
    DisableAnimator = false,
    RodDropdown = false,
    autoSell = false,
    autoSellHand = false,
    AutoTotemToggle = false,
    AutoPurchaseIfNone = false,
    ToggleEnabled = false,
    autoconfirm = false,
    attackEnabled = false,
    fishPriceEnable = true,
    hideRarityEnable = false,
    autoDestroyEnabled = false,
    ToggleReelingSound = false,
    ZoneTPDropdownUI = false,
    Hunting_Enabled = false,
    AutoAshclaw_Enabled = false,
    Noclip = false,
    BlackShow = false,
    isDisableAnimator = false,
    FishingTPDropdownUI = nil,
    selectedZoneADS = false,
    originalCFrame = nil,
    ItemSelection = nil,
    savedPosition = nil,
    SelectedFood = nil,
    autoShakeDelayInput = 0,
    ItemAmount = 1,
    DelayTimeFaster = 4,
    amountToBuy = 1,
    delayTime = 2,
    autoCastDelayInput = 0,
    targetLevel = 0,
    tempTargetLevel = 0,
    BuyTotemAmount = 0,
    autoSellDelayInput = 3,
    autoEquipDelay = 0.25,
    floatHeight = 10,
    TeleportHeight = 20,
    rodNames = {},
    BlacklistRods = {},
    AutoBuyRods = false,
    itemNames = {},
    totemNames = {},
    TotemDropdown = {},
    SelectedTools = {},
    teleportSpotsMap = {},
    teleportSpotsNames = {},
    Hunting_Target = {},
    teleportNPC = {},
    teleportInteract = {},
    InteractDropDown = {},
    PlayerDropdown = {},
    storedItems = {},
    selectedeventrod = "Select Rod",
    playertele = "None",
    FirstSeaDropdown = "None",
    eventParagraph = "None",
    selecthuntigtarget = "Choose Event",
    ReelMode = "Super Fast Reel",
    InstantBobberMode = "V1",
    selectedbobberversion = "V1",
    fishFoods = { "GuppiesBest", "SplashSnacks", "FishChow" },
    selecteventtotem = "Select Event Totem",
    CatchMode = "Random",
    SecondSeaDropdown = "None",
    NPCsTPDropdownUI = "None",
    summonType = "None",
    JobIDInput = "",
    targetlevel_v = "",
}
FastReelEnabled = false
finishing = false
currentReel = nil
reelToken = 0
VarGames.FastReel.Enabled = FastReelEnabled
VarGames.FastReel.Finishing = finishing
VarGames.FastReel.CurrentReel = currentReel
VarGames.FastReel.ReelToken = reelToken
VarGames.Config = _sX
namefish = {
    "Flower Flounder", "Toxic Guardian", "Dewdrop Dab", "Violet Seed", "Nectar Koi",
    "Oversized Leaf", "Leafscale Lemon Shark", "Colossal Flower", "Butterfly", "Bloom Sprout",
    "Canary Seed", "Garden Snail", "Thorn Ribbon Eel", "Diamond Daisy", "Petal Ray", "Garden Crab",
    "Abyss Dart", "Abyss Snapper", "Abyssacuda", "Abyssal Devourer", "Abyssal Goliath",
    "Abyssal King", "Abyssal Maw", "Abyssal Zenith", "Abyssal Bearded Seadevil",
    "Abyssborn Monstrosity", "Acanthodii", "Admin Crate", "Admin Fish Barrel", "Akkorokamui",
    "Algae Lurker", "Alligator", "Alligator Gar", "Altarfin Grouper", "Amberjack", "Amethyst",
    "Ancient Algae", "Ancient Depth Serpent", "Ancient Eel", "Ancient Fragment", "Ancient Kraken",
    "Ancient Lobster", "Ancient Megalodon", "Ancient Orca", "Ancient Serpent Skull",
    "Ancient Serpent Spine", "Ancient Wood", "Anchovy", "Anglerfish", "Anglers Lantern",
    "Angelfish", "Anomalocaris", "Apex Leviathan", "Apollo's Song of Light", "Aqua Scribe",
    "Arapaima", "Arctic Char", "Ashcloud Archerfish", "Ashscale Minnow", "Ashen Minnow",
    "Atlantean Alchemist", "Atlantean Anchovy", "Atlantean Guardian", "Atlantean Sardine",
    "Atlantean Storm", "Aurora Pearl", "Aaurora Trout", "Axolotl", "Azure Prowler",
    "Azure Studfish", "Azureback Haddock School", "Baby Bloop Fish", "Baby Pond Emperor",
    "Bait Crate", "Banana", "Banditfish", "Barbed Shark", "Barreleye Fish", "Barracuda",
    "Barracuda's Spine", "Basalt", "Basalt Pike", "Batfish", "Beach Ball Pufferfish",
    "Beach Crate", "Bearded Toadfish", "Bee", "Bellona's Frenzy of War", "Beluga", "Bigfin Squid",
    "Birgeria", "Birthday Dumbo Octopus", "Birthday Megalodon", "Black Dragon Fish",
    "Black Grouper", "Black Iron Bucket", "Black Swallower", "Black Veil Ray", "Blackfish",
    "Blackfin Barracuda", "Blackspot Tuskfish", "Blazebelly", "Blight Pufferfish", "Blinking Egg",
    "Blistered Eel", "Blisterback Blenny", "Blisterfish", "Blobfish", "Blobfish School",
    "Bloodscript Eel", "Bloomback Turtle", "Bloomfin Trout", "Bloomtail", "Bloop Cosmetic Crate",
    "Bloop Fish", "Blue Energy Crystal", "Blue Foamtail", "Blue Langanose",
    "Blue Moon - First Sea", "Blue Ribbon Eel", "Blue Skull", "Blue Tang", "Blue Whale",
    "Bluefin Tuna", "Bluefin Tuna School", "Bluefish", "Bluegem Angelfish", "Bluegill",
    "Bluehead Wrasse", "Bluesteel Egg", "Boarfish", "Bog Lantern Goby", "Bogscale", "Bone",
    "Bone Lanternfish", "Boot", "Boots", "Boreal Pines", "Borealis Snapper", "Bowfin",
    "Brackscale", "Brainy Smurf", "Breaker Moth", "Bream", "Brickhorse", "Brimstone Angler",
    "Brine Phantom", "Brine Pool", "Brine Shrimp", "Bronze Corydoras", "Buccaneer Barracuda",
    "Bull Shark", "Burbot", "Burnt Betta", "Butterflyfish", "Candy Cane Carp", "Candy Fish",
    "Canopy Tetra", "Capybass", "Carbon Crate", "Cardinal Studfish", "Carrot Eel",
    "Carrot Goldfish", "Carrot Garden", "Carrot Minnow", "Carrot Pufferfish", "Carrot Salmon",
    "Carrot Shark", "Carrot Snapper", "Carrot Turtle", "Captain's Goldfish", "Carp",
    "Castaway Cliffs", "Catfish", "Celestial Koi", "Challenger's Deep", "Chargeback Bass",
    "Charybdis", "Chasm Leech", "Cheezburger", "Chillback Whitefish", "Chillfin Chimaera",
    "Chillfin Herring", "Chillshadow Chub", "Chinfish", "Chinook Salmon", "Chronos Deep Swimmer",
    "Christmas Bloop Fish", "Chub", "Cinder Dart", "Cinder Carp", "Cladoselache", "Clam",
    "Claw Gill", "Clown Brickfish", "Clowned Triggerfish", "Clownfish", "Cluckfin", "Clumsy Smurf",
    "Coalfin Darter", "Cobalt Angelfish", "Cobia", "Cockatoo Squid", "Cod", "Coelacath",
    "Coin Piranha", "Coin Squid", "Coin Triggerfish", "Collapsed Ruins", "Colossal Carp",
    "Colossal Saccopharynx", "Colossal Squid", "Column Crawler", "Comically Ginormous Nico",
    "Common Crate", "Coney Grouper", "Confetti Shark", "Cookie", "Cookiecutter Shark",
    "Coral Bastion", "Coral Chromis", "Coral Emperor", "Coral Geode", "Coral Guard",
    "Coralwing Guppy School", "Corsair Grouper", "Corrupted Floppy", "Corrupted Kraken",
    "Corrupted Megalodon", "Corrupted Mosslurker", "Corrupted Scylla", "Cosmic Relic",
    "Countdown Perch", "Crab", "Crab Stud", "Cragscale", "Crescent Madtom", "Crestscale",
    "Crocokoi", "Crown Bass", "Crowned Anglerfish", "Crowned Royal Gramma", "Crowned Ruins",
    "Cryo Coelacanth", "Cryoskin", "Crystal Carp", "Crystal Chorus", "Crystal Corydoras",
    "Crystal Cove", "Crystal Frilled Shark", "Crystal Lobster", "Crystal Wrasse",
    "Crystallized Seadragon", "Cultist Lair", "Cursed Eel", "Cursed Isle", "Cursed Thread",
    "Cutlass Fish", "Cyan Seed", "Cyclone Mako", "Cyclone Scorpionfish", "Dasyatis",
    "Deeplight Footballfish", "Deep One", "Deep Behemoth", "Deep Crownfish", "Deep Emperor",
    "Deep Freeze Devilfish", "Deep Pearl", "Deep Sea Fragment", "Deep-sea Dragonfish",
    "Deep-sea Hatchetfish", "Depth Drifter", "Depth Lurker", "Depth Octopus", "Desolate Deep",
    "Destroyed Fossil", "Diamond Discus", "Diplomystus", "Diplurus", "Dissolved Bone",
    "DJ Spinopus", "Doctorfish Tang", "Dogefin", "Dolphin", "Doubloon", "Dreaming Aberration",
    "Drift Claw", "Driftfin", "Drifting Gildfin", "Driftwood", "Dripstone", "Duckfin Tuna",
    "Dumbo Octopus", "Dunkleosteus", "Duskscale Carp", "Duskwave Herring School",
    "Dweller Catfish", "Earth Fragment", "Eecho Koi", "Echo Fisher", "Edestus", "Eel",
    "Elder Mossjaw", "Eldritch Horror", "Eldritch Spineback", "Ember Catfish", "Ember Perch",
    "Ember Snapper", "Embertail Eel", "Emberwing", "Emerald Angelfish", "Emerald Elephantnose",
    "Emperor Jellyfish", "Empyrean Sunwhale", "Enchant Relic", "Enchanted Crevice",
    "Eternal Frostwhale", "Everturn Forest", "Exalted Relic", "Eyefestation", "Fading Guppy",
    "Flamekissed Hawkfish", "Flamangler", "Fangborn Gar", "Fangtooth", "Festive Bait Crate",
    "Firecrest", "Fish Barrel", "FischFright 2", "Fischfest", "Fischmas 2", "Flashlight", "Floppy",
    "Flounder", "Flower Guardian", "Flying Fish", "Flying Gurnard", "Foamrunner", "Fogstripe",
    "Forsaken Algae", "Forsaken Shores", "Fossil Fan", "Four Eyes Fish", "Frank", "Frankenshrimp",
    "Freezing Shroom", "French Grunt", "Frigid Antlers", "Frigid Crab", "Frigid Mammoth Tusk",
    "Frigid Shrimp", "Frigid Cavern", "Frigid Taco", "Frilled Shark", "Frightful Crate",
    "Frogfish", "Frost Minnow", "Frostbite Flounder", "Frostjaw Cod", "Frostling Goby",
    "Frostscale Fangtooth", "Frost Ray", "Frozen Fangfish", "Frozen Leviathan", "Frozen Pike",
    "Frozen Walnut", "Fungal Cluster", "Furnace Leaper", "Gale Snapper", "Galleon Goliath",
    "Gazerfish", "Gem Anchovy", "Gem Blobfish", "Gem Dolphin", "Gem Eel", "Gem Marlin",
    "Gem Salmon", "Gemscale Mandarinfish", "Gemstone Whale Shark", "Ghost", "Ghoul", "Ghoulfish",
    "Gilded Pearl", "Gillicus", "Gingerbread Fish", "Ginsu Shark", "Glacial Fragment",
    "Glacial Squid", "Glacial Sturgeon", "Glade Lurker", "Glacier Glowfish", "Glacier Swordfish",
    "Glacier Pike", "Glacierfish", "Glass Diamond", "Glass of Milk", "Glassblue Herring",
    "Glassfish", "Glimmer Guppy", "Gloamfin Gar", "Gloombiter", "Globe Jellyfish", "Glow Brick",
    "Glowfin Skipper", "Goblin Shark", "Goldband Butterflyfish", "Goldbrick", "Golden Coin",
    "Golden Dorado", "Golden Nessie", "Golden Scylla", "Golden Seahorse", "Golden Sea Pearl",
    "Golden Smallmouth Bass", "Goldfin Octopus", "Goldfish", "Gorgon Grouper",
    "Grand Reef Guardian", "Grayling", "Great Barracuda", "Great Goldcursed Shark",
    "Great Hammerhead Shark", "Great White Shark", "Greater Weever", "Green Energy Crystal",
    "Green Skull", "Grey Carp", "Grouchy Smurf", "Gudgeon", "Gulf Toadfish", "Gulper Eel",
    "Gust Tail", "Hades' Underworld of Indefinite", "Haddock", "Halibut", "Hallucigenia",
    "Handfish", "Harbinger Koi", "Heart Balloon", "Hefty", "Helicoprion", "Helios Ray",
    "Hellfire Haddock", "Hellmaw Eel", "Herring", "Hexeye Snapper", "Hidden Filefish",
    "Hidden Pipefish", "Hogchoker", "Hollow Flake Catfish", "Hollow Gazer", "Hollow Snapper",
    "Hollowfin", "Hollyscale Trout", "Horizon Tetra", "Horseshoe Crab", "Hourglass Bass",
    "Hyneria", "Hydra Haddock", "Ice", "Ice Anchovy", "Icebreaker Haddock", "Icebeard Shark",
    "Iceberg Isopod", "Ice Eel", "Icefang Barracuda", "Ice Jellyfish", "Ice Octopus", "Icicle",
    "Iced Perch", "Icy Carp", "Icy Daggerfish", "Icy Goldfish", "Icy Salmon", "Icy Tuna",
    "Icy Walleye", "Idolfish", "Infant Giant Seadevil", "Infernal Fragment",
    "Infernal Halibut School", "Infernal Iguanafish", "Inferno Chaser", "Inferno Hide",
    "Inferno Wood", "Ironjaw Guppy", "Islandhopper Butterflyfish", "Isonade", "Jellystud",
    "Jungle Phantom", "Jurassic Helicoprion", "Jurassic Mosasaurus", "Keepers Altar",
    "Keepers Guardian", "Kelpie", "Ken", "Key of Whispers", "King Jellyfish", "King Oyster",
    "Kittyfish", "Knifefish", "Krabbit", "The Kraken", "Kraken Koi", "Kraken's Herald",
    "Lagoon Dart", "Lagoon Lobster", "Lake Whitefish", "Lantern Snapper", "Lanternfish",
    "Langoustine", "Lapis Lazuli", "Lapisjack", "Largemouth Bass", "Lava Bream", "Lava Lamprey",
    "Leedsichthys", "LEGO", "Lepidotes", "Leviathan Bass", "Leviathan Humpback Anglerfish",
    "Life Jacket", "Lifeguard Whistle", "Lightning Minnow", "Lightning Pike", "Linear Guppy",
    "Lingcod", "Living Seed", "Lobster", "Lobster King", "Log", "Long Pike", "Longtail Bass",
    "Lost Jungle", "Lovestorm Eel", "Lovestorm Eel Supercharged", "Luminescent Cavern",
    "Luminescent Minnow", "Lumpclinger", "Lunar Monkfish", "Lurkerfish", "Lurking Crescent Pike",
    "Lusca", "Maelstorm Shark", "Mage Marlin", "Magician Narwhal", "Magma Leviathan", "Magma Pike",
    "Magma Tang", "Mahi Mahi", "Mained Lionfish", "Mama Poot", "Manatee", "Mandarinfish", "Mango",
    "Mango Smoothie", "Mango Whale", "Manta Ray", "Marble Maiden", "Marsh Gar", "Massive Marlin",
    "Mauve Pearl", "Meg's Fang", "Meg's Spine", "Megalodon", "Message in a Bottle",
    "Metal Strongbox", "Midnight Axolotl", "Minnow", "Minnowse", "Mirage Toadfish", "Moby",
    "Molten Banshee", "Molten Minnow", "Molten Moray", "Molten Ripple", "Moltenstripe",
    "Moon Arctic Char", "Moon Idol", "Moon Idol Sea 1", "Moon Idol Sea 2", "Moon Wood", "Moonfish",
    "Moonridge Catfish", "Moonstone", "Moonveil Killifish", "Moonveil Salmon School", "Moosewood",
    "Mosasaurus", "Mosaic Swimmer", "Mossjaw", "Mosslurker", "Mourning Manta Ray", "Moxie",
    "Mullet", "Murkdrifter", "Murkfin", "Murkslither", "Mushgrove Algae", "Mushgrove Crab",
    "Musical Crab", "Mussel", "Mustard", "Mustard Hat", "Mutated Crystal Shrimp", "Mutated Shark",
    "Mytical Living Garden", "Mythic Fish", "Napoleonfish", "Narwhal", "Nautilus", "Nectar Den",
    "Neon Tetra", "Neptune's Nibbler", "Nessie", "Nessie's Spine", "Net Wolffish", "New Years",
    "Nico", "Night Shrimp", "No Name", "Northstar Serpent", "Nurse Shark", "Oak Stripetail",
    "Oarfish", "Obsidian Koi", "Obsidian Salmon", "Obsidian Swordfish", "Ocean",
    "Ocean Triggerfish", "Octophant", "Olm", "Olmdeer", "Olympian Fissure", "Onychodus",
    "Ooreochima", "Opal", "Opalescent Catfish", "Oracle Minnow", "Oracle's Eye", "Orca",
    "Orcanda", "Orchid Anglerfish", "Ornament Fish", "Ornament Pufferfish", "Overgrowth Caves",
    "Oyster", "Oyster toadfish", "Pale Ghost Lumpfish", "Pale Tang", "Palaeoniscum", "Papa Smurf",
    "Parasite", "Parktail Spinesnapper", "Parrotfish", "Pearl", "Pelagic Cod", "Pelican Eel",
    "Pengwhal", "Penguin", "Perch", "Phanerorhynchus", "Phantom Brine", "Phantom Koi",
    "Phantom Megalodon", "Phantom Ray", "Philosopher's Fish", "Piglet Pike", "Pike", "Pine Tree",
    "Pine Zephyrfish", "Piranha", "Piranhamunk", "Pirate Captain Goldfish", "Plumrick O'Luck",
    "Polar Alligator", "Polar Prowler", "Pollock", "Pollen Guppy", "Poltergeist", "Pond Emperor",
    "Popsicle", "Porcufish", "Porgy", "Poseidon's Perch", "Poseidon's Storm of Floods", "Prawn",
    "Primordial Levi", "Prismatic Parrotfish", "Profane Ray", "Psychedelic Frogfish", "Pufferfish",
    "Pufferflute", "Pufferling School", "Pumpkinseed", "Pupfish", "Purple Skull", "Pyre Fang",
    "Pyrite Pufferfish", "Pyro Pike", "Pyrogrub", "Quality Bait Crate", "Quartzfin Queenfish",
    "Queen Angelfish", "Queen Bee Serpent", "Rabbitfish", "Racuda", "Radiant Triplewart Seadevil",
    "Rainbow Grouper", "Red Drum", "Red Energy Crystal", "Red Skull", "Red Snapper", "Red Tang",
    "Redeye Bass", "Redeye Piranha", "Redwood Duskray", "Reed Striker", "Reef Goby", "Reef Minnow",
    "Reef Parrotfish", "Reefdart", "Reefrunner Snapper", "Regal Angelfish", "Reindeer Ray",
    "Relic Dart", "Resin", "Rhizodus", "Ribbon Eel", "Ringle", "Ripple Spine", "Rock",
    "Rock Gunnel", "Rock Hind", "Rock Lobster", "Rockstar Hermit Crab", "RocketFuel", "Roslit",
    "Roslit Volcano", "Roslit Ray Lobster", "Rose Pearl", "Rose Bouquet", "Rotjaw", "Rotfin Eel",
    "Roughhead Grenadier", "Rowdy McCharm", "Royal Tigerfish", "Rubber Ducky", "Ruby",
    "Ruby Rasbora", "Ruby Lionfish", "Saffron Cod", "Sailfish", "Salmoose", "Salmon",
    "Sand Castle", "Sand Dollar", "Sand Tiger Shark", "Sand Worm", "Sandslasher",
    "Santa Pufferfish", "Santa Salmon", "Sapphire Stargazer", "Sapflow Eel",
    "Sarcastic Fringehead", "Sardine", "Sardines School", "Sawfish", "Scalding Swordfish",
    "Scallop", "Scalloped Hammerhead", "Scalloped Spiny Lobster", "Scoria Reach", "Scorchray",
    "Scooty Salmon", "Scrap Metal", "Scrawled Filefish", "Scurvy Sailfish", "Scylla", "Sea Bass",
    "Sea Leviathan", "Sea Mine", "Sea Pickle", "Sea Sponge", "Sea Turtle", "Sea Urchin", "Seacow",
    "Seaspawn Shrimp School", "Seaweed", "Second Sea", "Second Sea Lobster", "Sergeant Major",
    "Serpent Surgeonfish", "Searfin", "Shadow Ray", "Shadowfang Snapper", "Shamrock Bloop Fish",
    "Shamrock Seas", "Shark Fang", "Shell", "Shellphone", "Shimmering Silverside",
    "Shipwreck Barracuda", "Shiver Swarmfish School", "Shiverfin Haddock", "Shortfin Mako Shark",
    "Shrimp", "Shrimpanzee", "Silver Scuttler", "Singularity", "Siren Sheep", "Siren Singer",
    "Siren Sculpin", "Siren\195\162\226\130\172\226\132\162s Guppy", "Sixgill Shark", "Skelefish", "Skipjack Tuna", "Slag",
    "Slain Maw", "Slate Tuna", "Slenderfish", "Slipper Lobster", "Slurpfloth",
    "Small Spine Chimera", "Smallmouth Bass", "Smoldering Stingray", "Smolderfang", "Smogfish",
    "Smurf Event Pool", "Snakehead", "Snipefish", "Snook", "Snowback Char", "Snowburrow",
    "Snowcap", "Snowcap Algae", "Snowcap Lobster", "Snowfish", "Snowflake", "Snowflake Flounder",
    "Snowflake Smelt", "Snowgill Dace", "Snowman", "Sockeye Salmon", "Solar Fragment",
    "Song of the Deep", "Spadefish", "Sparkfin Tetra", "Sparkfin Minnow", "Sparkler Sardine",
    "Spectral Serpent", "Speed Core", "Spider Crab", "Spiderfish", "Spine Blade", "Spine Bone",
    "Spined Fin", "Spiny Sunstone Lobster", "Splendid toadfish", "Split Eye Snapper",
    "Spotted Moray Eel", "Sprayfin", "Squid", "Squirrelfish", "Squirrelray", "Stalactite",
    "Starbellied Wolf Fish", "Starfish", "Starlit Weaver", "Static Ray", "Stinger Skipper",
    "Stingray", "Stoplight Parrotfish", "Storm Eel", "Storm Skipper", "Stormcloud Angelfish",
    "String", "Stringed Grouper", "Stud Shark", "Stud Turtle", "Stud Koi", "Studphin", "Studster",
    "Studling Crab", "Studolodon", "Sturgeon", "Styx Angler", "Subzero Stargazer",
    "Suckermouth Catfish", "Sulfur Snapper", "Sunflare Tetra", "Sunfish", "Sunglasses",
    "Sunken Reliquary", "Sunken Silverscale", "Sunny O'Coin", "Sunray Sunscale", "Sunsquid",
    "Sunstone", "Sunscreen Bottle", "Supersized Bloop Fish", "Supersized Driftwood",
    "Supersized Floppy", "Supersized Mosslurker", "Supersized Scylla", "Supreme Present",
    "Surfboard Ray", "Surge Pike", "Swamp Bass", "Swamp Scallop", "Swampjaw", "Sweetfish",
    "Tarnished Moongill", "Tartaruga", "Telescopefish", "Temple Drifter", "Temple Perch",
    "Tempest Ray", "Tentabrick", "Tentacle Eel", "Tentacled Horror", "Terrapin",
    "Terrapin Lobster", "The Depths", "The Depths Key", "The Whispering One", "Thornfish",
    "Three-eyed Fish", "Thunder Serpet", "Thunder Bass", "Thunderclap Crab", "Tidallow",
    "Tidal Pike", "Tide Fang", "Tidefall", "Tidecrasher Archon", "Tidepopper", "Tiki Mask",
    "Tilefish", "Tire", "Titan Tuna", "Titanic Black Seadevil", "Titanic Sturgeon",
    "Titanfang Grouper", "Titanspawn Serpent", "Toilet Fish", "Toxic Grove", "Toxified Crab",
    "Treble Bass", "Trevally", "Trident", "Tripod Fish", "Triton's Herald", "Tropicspike",
    "Tropical Bait Crate", "Trumpetfish", "Tsunami Whale", "Tumor Pike", "Turkey", "Twilight Eel",
    "Twilight Glowfish", "Twilight Tentaclefish", "Typhoon Tailfin", "Typhoon Tuna",
    "Umbral Shark", "Unique Present", "Valentides 2", "Vanity", "Veilborn Parasite",
    "Veilborn Tetra", "Veilfin Tetra School", "Veil of the Forsaken", "Velvet Belly Lanternshark",
    "Verdant Mirage", "Vinefish", "Void Angler", "Void Emperor", "Void Wood", "Voidglow Ghostfish",
    "Voidscale Guppy", "Voidfin Mahi", "Volcanic Geode", "Volcanic Prowler", "Voltfin Carp",
    "Voltfish", "Vortex Barracuda", "Vortex Ray", "Walleye", "Warty Angler", "Warty Frogfish",
    "Watching Glowfin", "Wave Piercer", "Western Rock Lobster", "Whale Shark", "Whirlpool Marlin",
    "Whisker Bill", "Whisper Eel", "White Bass", "White Perch", "White Sturgeon", "Wiifish",
    "Winter's Edge", "Wraithfin", "Wretched Guppy", "X-ray Tetra", "Xiphactinus",
    "Yellow Boxfish", "Yellow Energy Crystal", "Yellow Studfish", "Yellowfin Tuna", "Zebrafishlet",
    "Zeus' Herald", "Zeus's Thunder of Chaos", "Zombiefish", "\196\159\197\184 \226\128\185"
}
VarGames.FishNames = namefish
genv = genv or {}
genv.AutoPurchaseIfNone = genv.AutoPurchaseIfNone or false
genv.TotemLock = genv.TotemLock or false
genv.AutoTotemRunning = genv.AutoTotemRunning or false
genv.TotemSummoned = genv.TotemSummoned or false
genv.LastCycle = genv.LastCycle or nil
VarGames.Genv = genv
function SaveConfig()
    if typeof(writefile) ~= "function" then return end
    local success, result = pcall(function()
        local json = HttpService:JSONEncode(_sX)
        writefile(configFile, json)
    end)
    if not success then
        warn("Gagal menyimpan config:", result)
    end
end
function LoadConfig()
    if typeof(isfile) ~= "function" or typeof(readfile) ~= "function" then return end
    if not isfile(configFile) then
        SaveConfig()
        return
    end
    local success, result = pcall(function()
        local fileData = readfile(configFile)
        local decoded = HttpService:JSONDecode(fileData)
        for key, value in pairs(decoded) do
            _sX[key] = value
        end
    end)
    if not success then
        warn("Gagal memuat config:", result)
    end
end
LoadConfig()
local function FormatNumber(n)
    return tostring(math.floor(n)):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end
local function cleanFishName(rawName)
    local cleaned = string.match(rawName, "^[^_%d]+")
    return cleaned or rawName
end
local function normalize(str)
    if not str then return "" end
    return string.lower(string.gsub(tostring(str), "%s+", ""))
end
local function isAnyFishSelected(selectedTable)
    if type(selectedTable) ~= "table" then return false end
    for _, isChecked in pairs(selectedTable) do
        if isChecked then return true end
    end
    return false
end
local function RainbowColor()
    return Color3.fromHSV(tick() % 10 / 10, 1, 1)
end
local function RemoveClothingAndHair(character)
    for _, item in pairs(character:GetChildren()) do
        if item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then
            item:Destroy()
        end
    end
    for _, accessory in pairs(character:GetChildren()) do
        if accessory:IsA("Accessory") then
            local handle = accessory:FindFirstChild("Handle")
            if handle then accessory:Destroy() end
        end
    end
end
local function makeCharacterBoxy(character)
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("MeshPart") or part:IsA("Part") then
            part.Size = Vector3.new(2, 2, 2)
            part.Shape = Enum.PartType.Block
            part.Color = RainbowColor()
        end
    end
end
local function FireProximity(proximity)
    if proximity:IsA("ProximityPrompt") and proximity.Enabled then
        proximity:InputHoldBegin()
        proximity.HoldDuration = 0
        proximity:InputHoldEnd()
    end
end
local function getHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end
local SafeMotion = {}
SafeMotion.StreamDistance = 350
local function zeroMotion(hrp)
    pcall(function()
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end)
end
function SafeMotion.Teleport(hrp, targetCFrame)
    if typeof(hrp) ~= "Instance" or not hrp:IsA("BasePart") or not hrp:IsDescendantOf(workspace) then return end
    if typeof(targetCFrame) ~= "CFrame" then return end
    SafeMotion.TeleportStamp = (SafeMotion.TeleportStamp or 0) + 1
    local character = hrp.Parent
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if workspace.StreamingEnabled and (hrp.Position - targetCFrame.Position).Magnitude > SafeMotion.StreamDistance then
        pcall(function()
            LocalPlayer:RequestStreamAroundAsync(targetCFrame.Position, 3)
        end)
    end
    zeroMotion(hrp)
    if humanoid and humanoid.Sit then
        humanoid.Sit = false
    end
    if humanoid then
        pcall(humanoid.ChangeState, humanoid, Enum.HumanoidStateType.Running)
    end
    if character and character:IsA("Model") and character.PrimaryPart == hrp then
        pcall(character.PivotTo, character, targetCFrame)
    else
        hrp.CFrame = targetCFrame
    end
    zeroMotion(hrp)
    task.defer(zeroMotion, hrp)
end
SafeMotion.RotationOwners = {}
SafeMotion.RotationHumanoid = nil
SafeMotion.RotationSaved = nil
SafeMotion.FreezeToken = 0
function SafeMotion.AcquireRotation(owner, humanoid)
    if not humanoid then return end
    if SafeMotion.RotationHumanoid ~= humanoid or not SafeMotion.RotationHumanoid.Parent then
        SafeMotion.RotationOwners = {}
        SafeMotion.RotationHumanoid = humanoid
        SafeMotion.RotationSaved = humanoid.AutoRotate
    elseif next(SafeMotion.RotationOwners) == nil then
        SafeMotion.RotationSaved = humanoid.AutoRotate
    end
    SafeMotion.RotationOwners[owner] = true
    pcall(function() humanoid.AutoRotate = false end)
end
function SafeMotion.ReleaseRotation(owner)
    if not SafeMotion.RotationOwners[owner] then return end
    SafeMotion.RotationOwners[owner] = nil
    if next(SafeMotion.RotationOwners) ~= nil then return end
    local humanoid = SafeMotion.RotationHumanoid
    local saved = SafeMotion.RotationSaved
    SafeMotion.RotationHumanoid, SafeMotion.RotationSaved = nil, nil
    if humanoid and humanoid.Parent then
        pcall(function() humanoid.AutoRotate = saved ~= false end)
    end
end
function SafeMotion.FreezeOnBoat(state, isActive, setActive)
    local player = Players.LocalPlayer
    local character = player and player.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end
    if not state then
        SafeMotion.FreezeToken = SafeMotion.FreezeToken + 1
        setActive(false)
        SafeMotion.ReleaseRotation("Freeze")
        return
    end
    local active = workspace:FindFirstChild("active")
    local boats = active and active:FindFirstChild("boats")
    local playerBoat = boats and boats:FindFirstChild(player.Name)
    local rowboat = playerBoat and playerBoat:FindFirstChild("Rowboat")
    local basePart = rowboat and rowboat:FindFirstChild("HitBox")
    if not basePart then return end
    SafeMotion.FreezeToken = SafeMotion.FreezeToken + 1
    local myToken = SafeMotion.FreezeToken
    local startStamp = SafeMotion.TeleportStamp or 0
    setActive(true)
    local heldYaw = hrp.CFrame - hrp.CFrame.Position
    SafeMotion.AcquireRotation("Freeze", humanoid)
    task.spawn(function()
        while isActive() and SafeMotion.FreezeToken == myToken and basePart.Parent and hrp.Parent do
            if (SafeMotion.TeleportStamp or 0) ~= startStamp then
                setActive(false)
                break
            end
            local partTopY = basePart.Position.Y + basePart.Size.Y / 2
            hrp.CFrame = CFrame.new(basePart.Position.X, partTopY + 2, basePart.Position.Z) * heldYaw
            hrp.AssemblyAngularVelocity = Vector3.zero
            for _, part in ipairs(rowboat:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.AssemblyLinearVelocity = Vector3.zero
                    part.AssemblyAngularVelocity = Vector3.zero
                end
            end
            RunService.Heartbeat:Wait()
        end
        if SafeMotion.FreezeToken == myToken then
            SafeMotion.ReleaseRotation("Freeze")
        end
    end)
end
local function tpPlayer(targetCFrame)
    local player = Players.LocalPlayer
    if player and player.Character then
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then SafeMotion.Teleport(hrp, targetCFrame) end
    end
end
local ReelGate = {}
ReelGate.LastFire = 0
ReelGate.MinInterval = 1.35
ReelGate.ReelMinSeconds = 1.25
ReelGate.ReelMaxSeconds = 2.55
ReelGate.ProgressFloor = 0.88
ReelGate.ProgressCeiling = 1.0
ReelGate.PerfectMissChance = 0.07
function ReelGate.HumanDelay(rarityBoost)
    local base = ReelGate.ReelMinSeconds + (ReelGate.ReelMaxSeconds - ReelGate.ReelMinSeconds) * math.random()
    local jitter = (math.random() - 0.5) * 0.18
    if rarityBoost then base = base + 0.4 + math.random() * 0.6 end
    local result = base + jitter
    if result < 0.9 then result = 0.9 end
    return result
end
function ReelGate.Progress()
    return ReelGate.ProgressFloor + (ReelGate.ProgressCeiling - ReelGate.ProgressFloor) * math.random()
end
function ReelGate.CanFire()
    return (tick() - ReelGate.LastFire) >= ReelGate.MinInterval
end
function ReelGate.Mark()
    ReelGate.LastFire = tick()
end
local RemoteGate = {}
RemoteGate.Buckets = setmetatable({}, { __mode = "k" })
RemoteGate.MinInterval = 0.22
RemoteGate.Jitter = 0.14
function RemoteGate.Fire(remote, ...)
    if typeof(remote) ~= "Instance" then return end
    local bucket = RemoteGate.Buckets[remote]
    local now = tick()
    if bucket and (now - bucket) < RemoteGate.MinInterval then
        task.wait((RemoteGate.MinInterval - (now - bucket)) + math.random() * RemoteGate.Jitter)
    else
        task.wait(math.random() * RemoteGate.Jitter)
    end
    RemoteGate.Buckets[remote] = tick()
    local ok, err = pcall(function(...) return remote:FireServer(...) end, ...)
    return ok, err
end
function RemoteGate.Invoke(remote, ...)
    if typeof(remote) ~= "Instance" then return end
    local bucket = RemoteGate.Buckets[remote]
    local now = tick()
    if bucket and (now - bucket) < RemoteGate.MinInterval then
        task.wait((RemoteGate.MinInterval - (now - bucket)) + math.random() * RemoteGate.Jitter)
    else
        task.wait(math.random() * RemoteGate.Jitter)
    end
    RemoteGate.Buckets[remote] = tick()
    local args = { ... }
    local result
    local ok, err = pcall(function()
        result = remote:InvokeServer(table.unpack(args))
    end)
    return ok, result, err
end
getgenv().LiyhubSafeMotion = SafeMotion
getgenv().LiyhubReelGate = ReelGate
getgenv().LiyhubRemoteGate = RemoteGate
placeId = game.PlaceId
activeFolder = game.Workspace:FindFirstChild("active")
exceptions = {
    "Leaderboards",
    "WaterDetailModels",
    "boats",
    "bosses",
    "constant",
    "crabcages",
    "debrisfx",
    "meteorItems",
    "watertraps",
    "OceanPOI's"
}
superinstantreeel = false
function unequipRod()
    local char = LocalPlayer.Character
    if not char then return end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") and tool:FindFirstChild("events") then
            tool.Parent = LocalPlayer.Backpack
            return
        end
    end
end
function equipRod()
    local char = LocalPlayer.Character
    local backpack = LocalPlayer.Backpack
    if not char or not backpack then return end
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and tool:FindFirstChild("events") then
            tool.Parent = char
            return
        end
    end
end
superinstantreeel = false
function onSound(sound)
    if sound:IsA("Sound") and sound.Name:lower():find("bite") then
        sound.Played:Connect(function()
            if not superinstantreeel then return end
            if not ReelGate.CanFire() then return end
            ReelGate.Mark()
            local isPerfect
            if _sX.perfectCatchEnabled then
                isPerfect = math.random() > ReelGate.PerfectMissChance
            else
                local chances = { true, false, false, false, false, false, false }
                isPerfect = chances[math.random(1, #chances)]
            end
            local humanDelay = ReelGate.HumanDelay(isPerfect)
            local progressValue = math.floor(ReelGate.Progress() * 100 + 0.5)
            if progressValue >= 99 then progressValue = 100 end
            task.spawn(function()
                task.wait(humanDelay * (0.35 + math.random() * 0.2))
                pcall(function()
                    local eventsFolder = ReplicatedStorage:FindFirstChild("events")
                    local reelBindable = eventsFolder and (eventsFolder:FindFirstChild("bindable_reel_finished") or eventsFolder:FindFirstChild("bindable_reelfinished"))
                    if reelBindable then
                        reelBindable:Fire(true)
                    end
                end)
                task.wait(humanDelay * (0.55 + math.random() * 0.25))
                pcall(function()
                    local netPkg = ReplicatedStorage:FindFirstChild("packages") and ReplicatedStorage.packages:FindFirstChild("Net")
                    local reelFinishRemote = netPkg and netPkg:FindFirstChild("RE/Reel/Finish")
                    if not reelFinishRemote then return end
                    reelFinishRemote:FireServer({ e = progressValue, p = isPerfect, l = {}, d = {} })
                    if _G.UpdateFishingStatus then _G.UpdateFishingStatus(5, "Status: Fish Caught! Resetting line...") end
                    task.delay(1.5, function()
                        if _sX and _sX.autoCastEnabled and _G.UpdateFishingStatus then
                            _G.UpdateFishingStatus(1, "Status: Ready to cast...")
                        end
                    end)
                end)
            end)
        end)
    end
end
local function setupHeadSounds(char)
    if not char then return end
    local h = char:FindFirstChild("Head") or char:WaitForChild("Head", 3)
    if not h then return end
    for _, d in ipairs(h:GetDescendants()) do
        onSound(d)
    end
    h.DescendantAdded:Connect(onSound)
end
if LocalPlayer.Character then
    task.spawn(setupHeadSounds, LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(setupHeadSounds)
local heartbeatConnection
superinstantreeldelay = 0
lastCastTime = 0
castCooldown = tonumber(superinstantreeldelay)
Terrain = workspace.Terrain
cachedCarrotMeshes = nil
cachedCarrotFolder = nil
function GetCarrotMeshes()
    folder =
    workspace:FindFirstChild("world")
    and workspace.world:FindFirstChild("map")
    and workspace.world.map:FindFirstChild("Carrot Secret")
    if not folder then
        cachedCarrotMeshes = nil
        cachedCarrotFolder = nil
        return nil
    end
    if cachedCarrotMeshes and cachedCarrotFolder == folder then
        return cachedCarrotMeshes
    end
    cachedCarrotFolder = folder
    cachedCarrotMeshes = {}
    for _, model in ipairs(folder:GetChildren()) do
        mesh = model:FindFirstChild("Meshes/CarrotPool_Cube.001 (1)")
        if mesh and mesh:IsA("BasePart") then
            table.insert(cachedCarrotMeshes, mesh)
        end
    end
    return cachedCarrotMeshes
end
local _ibLastHrpPos, _ibLastCF = nil, nil
local function findBobberWater(hrp)
    if not hrp then return nil end
    local hrpPos = hrp.Position
    if _ibLastHrpPos and _ibLastCF and (hrpPos - _ibLastHrpPos).Magnitude < 2 then
        return _ibLastCF
    end
    local meshes = GetCarrotMeshes()
    if meshes and #meshes > 0 then
        local closest, cdist = nil, math.huge
        for _, m in ipairs(meshes) do
            if m and m.Parent then
                local d = (hrpPos - m.Position).Magnitude
                if d < cdist then cdist, closest = d, m end
            end
        end
        if closest and cdist < 50 then
            _ibLastHrpPos, _ibLastCF = hrpPos, CFrame.new(closest.Position - Vector3.new(0, 3, 0))
            return _ibLastCF
        end
    end
    local Params = RaycastParams.new()
    Params.FilterType = Enum.RaycastFilterType.Include
    Params.FilterDescendantsInstances = { workspace.Terrain }
    Params.IgnoreWater = false
    local scanY = hrpPos.Y + 50
    local lookVec = hrp.CFrame.LookVector
    for _, dist in ipairs({ 10, 15, 20, 25, 30, 35, 45 }) do
        local testPos = hrpPos + (lookVec * dist)
        local res = workspace:Raycast(Vector3.new(testPos.X, scanY, testPos.Z), Vector3.new(0, -300, 0), Params)
        if res and res.Instance and res.Instance:IsA("Terrain") and res.Material == Enum.Material.Water then
            _ibLastHrpPos, _ibLastCF = hrpPos, CFrame.new(res.Position - Vector3.new(0, 3, 0))
            return _ibLastCF
        end
    end
    local bestPos, bestDist = nil, math.huge
    for i = 0, 23 do
        local angle = (i / 24) * (math.pi * 2)
        local cosA, sinA = math.cos(angle), math.sin(angle)
        for _, radius in ipairs({ 8, 12, 16, 22, 30, 40 }) do
            local sx, sz = hrpPos.X + cosA * radius, hrpPos.Z + sinA * radius
            local res = workspace:Raycast(Vector3.new(sx, scanY, sz), Vector3.new(0, -300, 0), Params)
            if res and res.Instance and res.Instance:IsA("Terrain") and res.Material == Enum.Material.Water then
                if radius < bestDist then bestDist, bestPos = radius, res.Position end
                break
            end
        end
    end
    if bestPos then
        _ibLastHrpPos, _ibLastCF = hrpPos, CFrame.new(bestPos - Vector3.new(0, 3, 0))
        return _ibLastCF
    end
    local head = hrp.Parent and hrp.Parent:FindFirstChild("Head")
    local basePos = (head and head.Position) or hrpPos
    _ibLastHrpPos, _ibLastCF = hrpPos, CFrame.new(basePos + (lookVec * 10) - Vector3.new(0, 11, 0))
    return _ibLastCF
end
function DoDropLogic(Rod, character)
    local Bobber = Rod:FindFirstChild("bobber")
    if not Bobber then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if not (_sX.AutoBobberAdjustToggle or _sX.FarDropEnabled) then return end
    local targetCF = findBobberWater(hrp)
    if not targetCF then return end
    if _sX.FarDropEnabled then
        targetCF = targetCF + (hrp.CFrame.LookVector * 35)
    end
    pcall(function()
        if Bobber:IsA("BasePart") then
            Bobber.CFrame = targetCF
            Bobber.AssemblyLinearVelocity = Vector3.zero
        else
            Bobber:PivotTo(targetCF)
            if Bobber.PrimaryPart then
                Bobber.PrimaryPart.AssemblyLinearVelocity = Vector3.zero
            end
        end
    end)
end
local autoFishingWorkerRunning = false
local RodStateIds = { Equipped = 3, Casting = 4, Searching = 5, Luring = 6, PreReel = 7 }
local AutoCastState = { failures = 0, retryAt = 0, lastState = -1, stateSince = 0 }
local CastRng = Random.new()
local function getFishingNetRemote(remoteName)
    local packages = ReplicatedStorage:FindFirstChild("packages")
    local netFolder = packages and packages:FindFirstChild("Net")
    return netFolder and netFolder:FindFirstChild(remoteName)
end
local function resetFishingRod()
    local resetRemote = getFishingNetRemote("RE/FishingRod/Reset")
    if not resetRemote then return end
    pcall(resetRemote.FireServer, resetRemote)
end
local function resolveCastPower(mode)
    if mode == "Random" then
        local modes = { "Bad", "Good", "Amazing", "Perfect" }
        mode = modes[CastRng:NextInteger(1, #modes)]
    end
    if mode == "Bad" then return CastRng:NextNumber(15, 25), false, mode end
    if mode == "Good" then return CastRng:NextNumber(45, 55), false, mode end
    if mode == "Amazing" then return CastRng:NextNumber(82, 89), false, mode end
    return CastRng:NextNumber(97, 100), true, "Perfect"
end
local function isCastBlocked(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return true end
    if hum:GetState() == Enum.HumanoidStateType.Swimming then return true end
    if workspace:GetAttribute("ClientCutsceneRunning") then return true end
    if LocalPlayer:GetAttribute("BlockCast") or LocalPlayer:GetAttribute("RodEquipInProgress") then return true end
    return false
end
local function recoverStuckRod(rod, rodState, minigameOpen)
    local now = os.clock()
    if rodState ~= AutoCastState.lastState then
        AutoCastState.lastState = rodState
        AutoCastState.stateSince = now
        return
    end
    if minigameOpen then return end
    local elapsed = now - AutoCastState.stateSince
    local waitingForBite = rodState == RodStateIds.Searching or rodState == RodStateIds.Luring
    local stuck = (rodState == RodStateIds.Casting and elapsed > 8)
    or (waitingForBite and not rod:FindFirstChild("bobber") and elapsed > 4)
    or (rodState == RodStateIds.PreReel and elapsed > 15)
    if not stuck then return end
    AutoCastState.stateSince = now
    resetFishingRod()
end
function StartAutoFishing()
    if autoFishingWorkerRunning then return end
    autoFishingWorkerRunning = true
    task.spawn(function()
        while _sX and _sX.autoCastEnabled do
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                if isCastBlocked(char) then return end
                local stats = workspace:FindFirstChild("PlayerStats")
                local rodName = stats and stats:FindFirstChild(LocalPlayer.Name) and stats[LocalPlayer.Name]:FindFirstChild("T") and stats[LocalPlayer.Name].T:FindFirstChild(LocalPlayer.Name) and stats[LocalPlayer.Name].T[LocalPlayer.Name].Stats.rod.Value
                local rod = (rodName and char:FindFirstChild(rodName)) or (char:FindFirstChildOfClass("Tool") and char:FindFirstChildOfClass("Tool"):FindFirstChild("values") and char:FindFirstChildOfClass("Tool"))
                if not rod and LocalPlayer.Backpack and _sX.autoEquipState then
                    local bpRod = (rodName and LocalPlayer.Backpack:FindFirstChild(rodName)) or (LocalPlayer.Backpack:FindFirstChildOfClass("Tool") and LocalPlayer.Backpack:FindFirstChildOfClass("Tool"):FindFirstChild("values") and LocalPlayer.Backpack:FindFirstChildOfClass("Tool"))
                    if bpRod then
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum then hum:EquipTool(bpRod) else bpRod.Parent = char end
                        rod = bpRod
                        task.wait(0.4)
                    end
                end
                if not rod or rod.Parent ~= char then return end
                local rodVals = rod:FindFirstChild("values")
                local isCasted = rodVals and rodVals:FindFirstChild("casted") and rodVals.casted.Value == true
                local rodState = rodVals and rodVals:FindFirstChild("state") and rodVals.state.Value or 1
                local hasBite = rodVals and rodVals:FindFirstChild("bite") and rodVals.bite.Value == true
                local hasShakeUI = PlayerGui:FindFirstChild("shakeui") ~= nil
                local hasReelUI = PlayerGui:FindFirstChild("reel") ~= nil or (ReelController and ReelController.ActiveReel and ReelController.ActiveReel.active)
                local minigameOpen = hasShakeUI or hasReelUI
                if isCasted or rodState > RodStateIds.Equipped or minigameOpen or hasBite then
                    recoverStuckRod(rod, rodState, minigameOpen)
                    return
                end
                AutoCastState.lastState = rodState
                AutoCastState.stateSince = os.clock()
                if os.clock() < AutoCastState.retryAt then return end
                if rod:GetAttribute("BlockCast") then return end
                if rod:FindFirstChild("bobber") then
                    resetFishingRod()
                    task.wait(0.15)
                end
                local castRemote = getFishingNetRemote("RF/FishingRod/Cast")
                if not castRemote then return end
                local finalPower, isPerfect, currentMode = resolveCastPower(_sX.castMode or "Perfect")
                if typeof(finalPower) == "number" then
                    local jitterScale = 0.985 + math.random() * 0.028
                    finalPower = math.clamp(finalPower * jitterScale, 1, 100)
                end
                if isPerfect and math.random() < 0.06 then
                    isPerfect = false
                end
                if _G.UpdateFishingStatus then
                    _G.UpdateFishingStatus(2, "Status: Casting Line (" .. tostring(currentMode) .. ")...")
                end
                task.wait(0.18 + math.random() * 0.22)
                local invoked, accepted = pcall(castRemote.InvokeServer, castRemote, finalPower, isPerfect)
                if not invoked or not accepted then
                    AutoCastState.failures += 1
                    AutoCastState.retryAt = os.clock() + math.min(0.5 * AutoCastState.failures, 3)
                    resetFishingRod()
                    if _G.UpdateFishingStatus then
                        _G.UpdateFishingStatus(1, "Status: Cast rejected, retrying...")
                    end
                    return
                end
                AutoCastState.failures = 0
                if DoDropLogic then
                    DoDropLogic(rod, char)
                end
                task.wait(math.max(tonumber(_sX.autoCastDelayInput) or 0, 0.5))
            end)
            task.wait(0.25)
        end
        autoFishingWorkerRunning = false
    end)
end
customNameFish = ""
ActiveCustomCatchFish = false
setFishName = ""
activeFolder = game.Workspace:FindFirstChild("active")
exceptions = {
    "Leaderboards",
    "WaterDetailModels",
    "boats",
    "bosses",
    "constant",
    "crabcages",
    "debrisfx",
    "meteorItems",
    "watertraps",
    "OceanPOI's",
}
function GetRod()
    RodName =
    workspace.PlayerStats[LocalPlayer.Name].T[LocalPlayer.Name].Stats.rod.Value
    Rod = LocalPlayer.Character:FindFirstChild(RodName)
    or LocalPlayer.Backpack:FindFirstChild(RodName)
    return Rod
end
function EquipRod()
    Rod = GetRod()
    if Rod then
        character = game.Players.LocalPlayer.Character
        or game.Players.LocalPlayer.CharacterAdded:Wait()
        Rod.Parent = character
    else
        warn(
            "Rod tidak ditemukan di LocalPlayer.LocalPlayer.Character atau Backpack!"
        )
    end
end
function bugFishing()
    player = game.Players.LocalPlayer
    playerGui = player:WaitForChild("PlayerGui")
    humanoid = nil
    function refreshCharacter()
        char = player.Character or player.CharacterAdded:Wait()
        humanoid = char:WaitForChild("Humanoid")
    end
    refreshCharacter()
    player.CharacterAdded:Connect(refreshCharacter)
    while _sX.isFishing do
        startTime = tick()
        reelGui = nil
        while _sX.isFishing and not reelGui and tick() - startTime < 5 do
            reelGui = playerGui:FindFirstChild("reel")
            task.wait(0.2)
        end
        if reelGui then
            if not getgenv().LiyhubBugFishDestroyGate then
                getgenv().LiyhubBugFishDestroyGate = { Last = 0, MinInterval = 1.8 }
            end
            local gate = getgenv().LiyhubBugFishDestroyGate
            if (tick() - gate.Last) >= gate.MinInterval then
                gate.Last = tick()
                pcall(function()
                    local bar = reelGui:FindFirstChild("bar")
                    if bar then
                        task.delay(0.08 + math.random() * 0.12, function()
                            if bar.Parent then bar:Destroy() end
                        end)
                    end
                    character = LocalPlayer.Character
                    Rod = character and character:FindFirstChild(RodName)
                    if Rod then
                        Bobber = Rod:FindFirstChild("bobber")
                        if Bobber then
                            task.delay(0.05 + math.random() * 0.1, function()
                                if Bobber.Parent then Bobber:Destroy() end
                            end)
                        end
                    end
                end)
            end
        end
        task.wait((_sX.delayTime or 2) + math.random() * 0.4)
    end
end
Collection = {}
Collection.__index = Collection
ActiveShakeUI = {}
GuiService = game:GetService("GuiService")
RunService = game:GetService("RunService")
LocalPlayer = game.Players.LocalPlayer
local Net = nil
pcall(function()
    Net = require(ReplicatedStorage:WaitForChild("packages", 3):WaitForChild("Net", 3))
end)
local ShakeEvent = nil
if Net and Net.RemoteEvent then
    pcall(function() ShakeEvent = Net:RemoteEvent("LureShake/Shake") end)
end
local SHAKE_POLL_INTERVAL = 0.08
local ShakeRng = Random.new()
local function isShakeUIAlive(ShakeUI)
    return ShakeUI ~= nil and ShakeUI.Parent == PlayerGui
end
local function findShakeButton(SafeZone)
    for _, child in ipairs(SafeZone:GetChildren()) do
        if child:IsA("GuiButton") and child.Visible then
            return child
        end
    end
    return nil
end
local function shakeScaleReady(SafeZone, button)
    local best = nil
    local function scan(obj)
        for _, d in ipairs(obj:GetDescendants()) do
            if d:IsA("UIScale") then
                if best == nil or d.Scale > best then best = d.Scale end
            end
        end
    end
    if button then scan(button) end
    if best == nil and SafeZone then scan(SafeZone) end
    if best == nil then return true end
    return best >= 0.6
end
local function fireShake()
    if ShakeEvent then
        return pcall(function() ShakeEvent:FireServer() end)
    end
    return false
end
function Collection:ShakeUiv5(ShakeUI)
    if not ShakeUI or ActiveShakeUI[ShakeUI] then return end
    ActiveShakeUI[ShakeUI] = true
    if _G.UpdateFishingStatus then _G.UpdateFishingStatus(3, "Status: Shaking Bobber / Minigame Active...") end
    task.spawn(function()
        pcall(function()
            local SafeZone = ShakeUI:WaitForChild("safezone", 5)
            if not SafeZone then return end
            local startWait, timeout = tick(), 5
            while isShakeUIAlive(ShakeUI) and _sX and _sX.autoShakeEnabled do
                local default = SafeZone:FindFirstChild("default")
                if default and default.Visible and default:FindFirstChild("UIScale")
                and default.UIScale.Scale >= 1 then
                    break
                end
                if tick() - startWait > timeout then break end
                task.wait()
            end
            while isShakeUIAlive(ShakeUI) and _sX and _sX.autoShakeEnabled do
                local button = SafeZone:FindFirstChild("default")
                if button and _sX.centerShake then
                    button.AnchorPoint = Vector2.new(0.5, 0.5)
                    button.Position = UDim2.fromScale(0.5, 0.5)
                end
                if button and button.Visible and button:FindFirstChild("UIScale")
                and button.UIScale.Scale > 0.1 then
                    fireShake()
                    local extra = tonumber(_sX.autoShakeDelayInput) or 0
                    task.wait(math.max(extra, 0.25))
                end
                task.wait()
            end
        end)
        ActiveShakeUI[ShakeUI] = nil
    end)
end
function Collection:StartExistingShake()
    local existing = PlayerGui:FindFirstChild("shakeui")
    if existing and _sX and _sX.autoShakeEnabled then
        Collection:ShakeUiv5(existing)
    end
end
AntiDrown = {
    conn = nil,
    locked = false,
    floorPart = nil,
    offset = nil,
    lockedAt = 0,
    controlsDisabled = false,
    MAX_TIME = 600,
    TOLERANCE = 0.75,
    RELEASE_GRACE = 1.5
}
AntiDrown.lastActive = 0
local function antiDrownGetParts()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    return char, hrp, hum
end
local function antiDrownFindFloor(char, hrp)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { char }
    local hit = workspace:Raycast(hrp.Position, Vector3.new(0, -12, 0), params)
    if hit and hit.Instance and hit.Instance:IsA("BasePart") then
        return hit.Instance
    end
    return nil
end
local function isFishingMinigameOpen()
    if PlayerGui:FindFirstChild("shakeui") then return true end
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui.Name:lower():find("reel") then return true end
    end
    return false
end
local function isHoldingRod(char)
    local tool = char and char:FindFirstChildOfClass("Tool")
    return tool ~= nil and tool:FindFirstChild("values") ~= nil
end
local function isFishingActive(char)
    if isFishingMinigameOpen() then return true end
    if not isHoldingRod(char) then return false end
    return _sX and (_sX.autoCastEnabled or _sX.autoShakeEnabled) and true or false
end
local function antiDrownControls(enabled)
    pcall(function()
        local controls = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule", 2)):GetControls()
        if enabled then controls:Enable() else controls:Disable() end
    end)
end
function AntiDrown:Unlock()
    self.locked = false
    self.floorPart, self.offset = nil, nil
    SafeMotion.ReleaseRotation("AntiDrown")
    if self.controlsDisabled then
        self.controlsDisabled = false
        antiDrownControls(true)
    end
end
function AntiDrown:Lock(char, hrp, hum)
    if hum:GetState() == Enum.HumanoidStateType.Swimming then return end
    local floor = antiDrownFindFloor(char, hrp)
    self.floorPart = floor
    self.offset = floor and floor.CFrame:ToObjectSpace(hrp.CFrame) or hrp.CFrame
    self.lockedAt = os.clock()
    self.lockedStamp = SafeMotion.TeleportStamp or 0
    self.locked = true
    SafeMotion.AcquireRotation("AntiDrown", hum)
    if not self.controlsDisabled then
        self.controlsDisabled = true
        antiDrownControls(false)
    end
end
function AntiDrown:Stop()
    if self.conn then
        self.conn:Disconnect()
        self.conn = nil
    end
    self:Unlock()
end
function AntiDrown:Step()
    local char, hrp, hum = antiDrownGetParts()
    if not hrp or not hum or hum.Health <= 0 then
        self:Unlock()
        return
    end
    local now = os.clock()
    if isFishingActive(char) then
        self.lastActive = now
    end
    local active = (now - self.lastActive) <= self.RELEASE_GRACE
    if self.locked and self.lockedStamp ~= (SafeMotion.TeleportStamp or 0) then
        self:Unlock()
    end
    if not active or (self.locked and now - self.lockedAt > self.MAX_TIME) then
        if self.locked then self:Unlock() end
        return
    end
    if not self.locked then
        self:Lock(char, hrp, hum)
        if not self.locked then return end
    end
    local target
    if self.floorPart then
        if not self.floorPart.Parent then self:Unlock() return end
        target = self.floorPart.CFrame:ToWorldSpace(self.offset)
    else
        target = self.offset
    end
    local swimming = hum:GetState() == Enum.HumanoidStateType.Swimming
    local drift = (Vector3.new(hrp.Position.X, 0, hrp.Position.Z)
        - Vector3.new(target.Position.X, 0, target.Position.Z)).Magnitude
    local baseVel = self.floorPart and self.floorPart.AssemblyLinearVelocity or Vector3.zero
    if swimming or drift > self.TOLERANCE or hrp.Position.Y < target.Position.Y - 2 then
        local pos = Vector3.new(target.Position.X, swimming and target.Position.Y or math.max(hrp.Position.Y, target.Position.Y - 2), target.Position.Z)
        local look = target.LookVector
        local flatLook = Vector3.new(look.X, 0, look.Z)
        if flatLook.Magnitude < 1e-3 then
            flatLook = Vector3.new(hrp.CFrame.LookVector.X, 0, hrp.CFrame.LookVector.Z)
        end
        if flatLook.Magnitude < 1e-3 then
            flatLook = Vector3.new(0, 0, -1)
        end
        hrp.CFrame = CFrame.lookAt(pos, pos + flatLook.Unit)
        local v = hrp.AssemblyLinearVelocity
        hrp.AssemblyLinearVelocity = Vector3.new(baseVel.X, swimming and 0 or math.min(v.Y, 0), baseVel.Z)
        hrp.AssemblyAngularVelocity = Vector3.zero
        if swimming then
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    else
        local v = hrp.AssemblyLinearVelocity
        hrp.AssemblyLinearVelocity = Vector3.new(baseVel.X, v.Y, baseVel.Z)
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
    hum:Move(Vector3.zero, false)
end
function AntiDrown:Start()
    if self.conn or not (_sX and _sX.antiDrownEnabled) then return end
    self.lastActive = 0
    self.conn = RunService.Heartbeat:Connect(function()
        if not (_sX and _sX.antiDrownEnabled) then
            self:Stop()
            return
        end
        if not pcall(self.Step, self) then
            self:Unlock()
        end
    end)
end
LocalPlayer.CharacterAdded:Connect(function()
    AntiDrown:Unlock()
end)
task.defer(function()
    if _sX and _sX.antiDrownEnabled then AntiDrown:Start() end
end)
PlayerGui.ChildAdded:Connect(function(child)
    if child.Name == "shakeui" or child.Name:lower():find("reel") then
        AntiDrown:Start()
    end
    if child.Name == "shakeui" then
        if _G.UpdateFishingStatus then
            _G.UpdateFishingStatus(3, "Status: Shaking Bobber (Minigame Active)...")
        end
        if _sX and _sX.autoShakeEnabled then
            Collection:ShakeUiv5(child)
        end
    elseif child.Name:lower():find("reel") then
        if _G.UpdateFishingStatus then
            _G.UpdateFishingStatus(4, "Status: Reeling Fish (Minigame Active)...")
        end
    end
end)
Connections2 = {}
local StartMinigame
FishingSpots = {}
SeenZones = {}
if FishingZonesFolder then
    for _, v in ipairs(FishingZonesFolder:GetChildren()) do
        zoneName = v.Name
        if not SeenZones[zoneName] then
            table.insert(FishingSpots, zoneName)
            SeenZones[zoneName] = true
        end
    end
end
table.sort(FishingSpots, function(a, b)
    return a:lower() < b:lower()
end)
OriginalFishingSpots = table.clone(FishingSpots)
function teleportToSelection(zoneName)
    local resolver = _G.LiyZoneResolver
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not (resolver and char and hrp) then return end
    local target = resolver.ResolveCFrame(zoneName, char)
    if target then
        SafeMotion.Teleport(hrp, target)
    end
end
function InitializeCharacter()
    task.wait(0.1)
    StartAutoFishing()
end
LocalPlayer.CharacterAdded:Connect(InitializeCharacter)
if LocalPlayer.Character then
    InitializeCharacter()
end
player = game.Players.LocalPlayer
function FloatAboveZone(zoneName)
    local resolver = _G.LiyZoneResolver
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not (resolver and char and hrp and hum) then
        return
    end
    local base = resolver.ResolveCFrame(zoneName, char)
    if not base then
        return
    end
    _sX.originalCFrame = hrp.CFrame
    targetPosition = base + Vector3.new(0, _sX.floatHeight, 0)
    WalkSpeedBackup = hum.WalkSpeed
    JumpPowerBackup = hum.JumpPower
    hum.WalkSpeed = 0
    hum.JumpPower = 0
    _sX.autoTeleportEnabled = true
    SafeMotion.Teleport(hrp, targetPosition)
    local anchorBody
    pcall(function()
        anchorBody = Instance.new("BodyPosition")
        anchorBody.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        anchorBody.P = 1e5
        anchorBody.D = 2000
        anchorBody.Position = targetPosition.Position
        anchorBody.Name = "LiyhubFloatAnchor"
        anchorBody.Parent = hrp
    end)
    while _sX.autoTeleportEnabled do
        if anchorBody and anchorBody.Parent then
            anchorBody.Position = targetPosition.Position
        else
            local drift = (hrp.Position - targetPosition.Position).Magnitude
            if drift > 6 then
                SafeMotion.Teleport(hrp, targetPosition)
            end
        end
        hrp.AssemblyLinearVelocity = Vector3.zero
        task.wait(0.12)
    end
    if anchorBody then pcall(function() anchorBody:Destroy() end) end
    if hum and hum.Parent then
        hum.WalkSpeed = WalkSpeedBackup
        hum.JumpPower = JumpPowerBackup
    end
    if _sX.originalCFrame then
        local c2 = LocalPlayer.Character
        local h2 = c2 and c2:FindFirstChild("HumanoidRootPart")
        if h2 then SafeMotion.Teleport(h2, _sX.originalCFrame) end
    end
end
RodsModule =
typeof(RodsRaw) == "table" and (RodsRaw.Rods or RodsRaw)
for rodName, rodData in pairs(RodsModule) do
    table.insert(_sX.rodNames, tostring(rodName))
end
blacklist = {
    ["Witches Ingredient"] = true,
}
local shopItemSource = typeof(ItemsModule) == "table" and (ItemsModule.Items or ItemsModule.items) or ItemsModule
for itemName, itemData in pairs(shopItemSource) do
    if typeof(itemName) == "string" and not blacklist[itemName] then
        table.insert(_sX.itemNames, itemName)
    end
end
table.sort(_sX.itemNames, function(a, b)
    return a:lower() < b:lower()
end)
TotemModule =
ItemsModule.Items
or ItemsModule.items
or ItemsModule.Data
or ItemsModule.data
or ItemsModule
for itemName, itemData in pairs(TotemModule) do
    if typeof(itemName) == "string" then
        if itemName:lower():find("totem", 1, true) then
            table.insert(_sX.totemNames, itemName)
        end
    end
end
local function getSellEvent(eventName)
    local events = ReplicatedStorage:FindFirstChild("events")
    return events and events:FindFirstChild(eventName)
end
local function isHoldingSellableFish()
    local char = LocalPlayer.Character
    local tool = char and char:FindFirstChildOfClass("Tool")
    if not tool then return false end
    if tool:FindFirstChild("values") or tool:FindFirstChild("events") then return false end
    return true
end
task.spawn(function()
    while true do
        local delay = math.clamp(tonumber(_sX.autoSellDelayInput) or 3, 1, 120)
        if _sX.autoSell then
            local shadySell = _sX.priorityShadySell and getSellEvent("ShadySellAll")
            if shadySell then
                pcall(shadySell.InvokeServer, shadySell)
                task.wait(0.5)
            end
            local sellAll = getSellEvent("SellAll")
            if sellAll then
                pcall(sellAll.InvokeServer, sellAll)
            end
        end
        task.wait(delay)
    end
end)
task.spawn(function()
    while true do
        if _sX.autoSellHand and isHoldingSellableFish() then
            local sellHeld = getSellEvent("Sell")
            if sellHeld then
                pcall(sellHeld.InvokeServer, sellHeld)
            end
            task.wait(0.35)
        else
            task.wait(0.25)
        end
    end
end)
AutoUtil = {
    EnchantUntilEnable = false,
    selectedEnchant = nil,
}
function findRod()
    character = LocalPlayer.Character
    backpack = LocalPlayer:FindFirstChild("Backpack")
    if character then
        for _, tool in ipairs(character:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:lower():find("rod") then
                return tool
            end
        end
    end
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:lower():find("rod") then
                return tool
            end
        end
    end
    return nil
end
function AutoUtil.findItem(tem)
    character = LocalPlayer.Character
    backpack = LocalPlayer:FindFirstChild("Backpack")
    if character then
        for _, tool in ipairs(character:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:lower():find(tem:lower()) then
                return tool
            end
        end
    end
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:lower():find(tem:lower()) then
                return tool
            end
        end
    end
    return nil
end
function equipItem(tem)
    item = AutoUtil.findItem(tem)
    humanoid = LocalPlayer.Character
    and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if
    item
    and humanoid
    and item.Parent == LocalPlayer:FindFirstChild("Backpack")
    then
        humanoid:EquipTool(item)
    end
end
function FireProximity(proximity)
    if proximity:IsA("ProximityPrompt") and proximity.Enabled then
        proximity:InputHoldBegin()
        proximity.HoldDuration = 0
        proximity:InputHoldEnd()
    end
end
function tpPlayer(targetCFrame)
    player = game.Players.LocalPlayer
    if player and player.Character then
        hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if hrp and SafeMotion then
            SafeMotion.Teleport(hrp, typeof(targetCFrame) == "CFrame" and targetCFrame or CFrame.new(targetCFrame))
        elseif hrp then
            hrp.CFrame = targetCFrame
        end
    end
end
function getObtainedEnchant()
    rod = findRod()
    if not rod then
        return nil
    end
    rodmenu =
    game:GetService("Players").LocalPlayer.PlayerGui.hud.safezone.equipment.rods.scroll.safezone
    enchantLabel = rodmenu:FindFirstChild(rod.Name)
    and rodmenu[rod.Name]:FindFirstChild("enchant")
    if enchantLabel and enchantLabel:IsA("TextLabel") then
        enchantText = enchantLabel.Text
        enchantName = enchantText:match("\195\162\203\156\226\128\166%s*(.-)%s*\195\162\203\156\226\128\166")
        return enchantName
    end
    return nil
end
function enchant(rel)
    spawn(function()
        if placeId == 16732694052 then
            enchantProximity =
            workspace.world.interactables:FindFirstChild("Enchant Altar")
            if enchantProximity then
                enchantProximity =
                enchantProximity:FindFirstChild("PromptTemplate")
            else
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame =
                CFrame.new(
                    1310.07495,
                    -802.427002,
                    -83.4922028,
                    -0.551931977,
                    -2.22726726e-08,
                    -0.833889127,
                    -5.74662131e-08,
                    1,
                    1.13261667e-08,
                    0.833889127,
                    5.41717249e-08,
                    -0.551931977
                )
                task.wait(0.5)
            end
            equipItem(rel)
            prompt = enchantProximity
            equipItem(rel)
            if prompt and prompt:IsA("ProximityPrompt") and prompt.Enabled then
                fireproximityprompt(prompt)
            else
                warn("Prompt tidak valid atau tidak aktif:", prompt)
            end
            task.wait(0.5)
            guiPrompt = PlayerGui:WaitForChild("over")
            :WaitForChild("prompt")
            if guiPrompt then
                confirm = guiPrompt:FindFirstChild("confirm")
                if confirm then
                    GuiService.SelectedObject = confirm
                    if keypress and keyrelease then
                        keypress(0x0D)
                        keyrelease(0x0D)
                    end
                end
            end
        elseif placeId == 72907489978215 then
            enchantAltar = workspace:FindFirstChild("Enchant Altar")
            if not enchantAltar then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame =
                CFrame.new(
                    1585.95178,
                    -1515.38,
                    -775.006409,
                    0.999973059,
                    0,
                    0.00733732153,
                    0,
                    1,
                    0,
                    -0.00733732153,
                    0,
                    0.999973059
                )
                task.wait(0.5)
                enchantAltar = workspace:FindFirstChild("Enchant Altar")
            end
            prompt = enchantAltar
            and enchantAltar:FindFirstChild("PromptTemplate")
            equipItem(rel)
            if prompt and prompt:IsA("ProximityPrompt") and prompt.Enabled then
                fireproximityprompt(prompt)
            else
                warn("Prompt tidak valid atau tidak aktif:", prompt)
            end
            task.wait(0.5)
            guiPrompt = PlayerGui:WaitForChild("over")
            :WaitForChild("prompt")
            if guiPrompt then
                confirm = guiPrompt:FindFirstChild("confirm")
                if confirm then
                    GuiService.SelectedObject = confirm
                    if keypress and keyrelease then
                        keypress(0x0D)
                        keyrelease(0x0D)
                    end
                end
            end
        end
    end)
end
function EnchantUtilGet()
    spawn(function()
        if AutoUtil.EnchantUntilEnable and AutoUtil.selectedEnchant ~= nil then
            if
            game:GetService("ReplicatedStorage").world.cycle.Value
            == "Day"
            then
                AutoUtil.EnchantUntilEnable = false
            end
            relicType = data.Enchants[AutoUtil.selectedEnchant].Exalted
            and "Exalted Relic"
            or "Enchant Relic"
            if not AutoUtil.findItem(relicType) then
                AutoUtil.EnchantUntilEnable = false
            end
            obtainedEnchant = getObtainedEnchant()
            if obtainedEnchant then
                if obtainedEnchant ~= AutoUtil.selectedEnchant then
                    enchant(relicType)
                    EnchantUtilGet()
                    task.wait(3)
                else
                    AutoUtil.EnchantUntilEnable = false
                end
            end
        end
    end)
end
enchantList = {}
if type(data) ~= "table" then
    data = {}
end
data.Enchants = data.Enchants or {}
data.Enchants["Chaotic"] = { Exalted = false }
data.Enchants["Scavenger"] = { Exalted = false }
data.Enchants["Flashline"] = { Exalted = false }
for name, v in pairs(data.Enchants) do
    if v.Exalted ~= nil then
        table.insert(enchantList, name)
    end
end
task.spawn(function()
    while task.wait(0.5) do
        if not _sX.ToggleEnabled then
            continue
        end
        stats = workspace:FindFirstChild("PlayerStats")
        and workspace.PlayerStats:FindFirstChild(LocalPlayer.Name)
        if
        stats
        and stats:FindFirstChild("T")
        and stats.T:FindFirstChild(LocalPlayer.Name)
        then
            stats = stats.T[LocalPlayer.Name].Stats
        else
            continue
        end
        boss = workspace.active.bosses:FindFirstChild("cthulu")
        if not boss then
            continue
        end
        bossPlayers = boss:GetAttribute("players")
        userIdStr = tostring(LocalPlayer.UserId)
        if not bossPlayers then
            boss:SetAttribute("players", "")
        elseif bossPlayers:find(userIdStr) then
            ReplicatedStorage.events.keepersTorchHit:FireServer(true)
        elseif
        stats:FindFirstChild("crypt_bargate_opened")
        and not bossPlayers:find(userIdStr)
        then
            local cthuluTarget = CFrame.new(1536, -1693, 5896)
            local cthuluHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if cthuluHrp and SafeMotion then
                SafeMotion.Teleport(cthuluHrp, cthuluTarget)
            elseif cthuluHrp then
                cthuluHrp.CFrame = cthuluTarget
            end
            local netFolder = ReplicatedStorage:FindFirstChild("packages") and ReplicatedStorage.packages:FindFirstChild("Net")
            local cthuluAttackRemote = netFolder and netFolder:FindFirstChild("RE/CthuluAttack")
            if not cthuluAttackRemote then
                _sX.ToggleEnabled = false
                continue
            end
            while task.wait(0.45 + math.random() * 0.4) do
                if not _sX.ToggleEnabled then
                    break
                end
                local damageValue = math.random(28000, 95000)
                pcall(function()
                    cthuluAttackRemote:FireServer(damageValue)
                end)
            end
        end
    end
end)
LocalPlayer = game.Players.LocalPlayer
function getHRP()
    char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end
function tpPlayer(targetPos)
    HRP = getHRP()
    if HRP then
        if SafeMotion then
            SafeMotion.Teleport(HRP, typeof(targetPos) == "CFrame" and targetPos or CFrame.new(targetPos))
        else
            HRP.CFrame = targetPos
        end
    end
end
function findHeldItem()
    character = LocalPlayer.Character
    if not character then
        return nil
    end
    for _, item in pairs(character:GetChildren()) do
        if item:IsA("Tool") then
            return item
        end
    end
    return nil
end
function doAppraise()
    DialogInteract =
    game:GetService("ReplicatedStorage").packages.Net["RF/DialogInteract"]
    if placeId == 72907489978215 then
        tpPlayer(
            CFrame.new(
                141.771957,
                116.603554,
                705.245178,
                0.999579132,
                -1.03638818e-07,
                0.0290086437,
                1.03039689e-07,
                1,
                2.21484342e-08,
                -0.0290086437,
                -1.915007e-08,
                0.999579132
            )
        )
    else
        tpPlayer(
            CFrame.new(
                448.786102,
                150.529297,
                206.834045,
                -0.617013216,
                6.03024759e-08,
                -0.786952794,
                5.42776917e-08,
                1,
                3.40711992e-08,
                0.786952794,
                -2.16916032e-08,
                -0.617013216
            )
        )
    end
    Appraiser = workspace.world.npcs:FindFirstChild("Appraiser")
    if not Appraiser then
        repeat
            task.wait(0.5)
        until workspace.world.npcs:FindFirstChild("Appraiser")
    end
    Appraiser = workspace.world.npcs:FindFirstChild("Appraiser")
    if Appraiser then
        FireProximity(Appraiser.ProximityPrompt)
        DialogInteract:InvokeServer(6, 1)
    end
end
AutoUtil = AutoUtil or {}
AutoUtil.Appraise = {
    appraiseHeldEnable = false,
    selectedFilters = {},
}
function AutoUtil.Appraise.applyFilter()
    local filters = AutoUtil.Appraise.selectedFilters
    if type(filters) ~= "table" or #filters == 0 then
        return false
    end
    local gui = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
    local bp = gui and gui:FindFirstChild("backpack")
    local hotbar = bp and bp:FindFirstChild("hotbar")
    local inventory = bp and bp:FindFirstChild("inventory")
    local itemContainer = inventory and inventory:FindFirstChild("itemContainer")
    local function scanUI(container, requireHighlight)
        if not container then return false end
        local ok, children = pcall(function() return container:GetChildren() end)
        if not ok or type(children) ~= "table" then return false end
        for _, slot in ipairs(children) do
            local stroke = slot:FindFirstChildOfClass("UIStroke")
            local highlighted = stroke and stroke.Color == Color3.fromRGB(255, 255, 255)
            if (not requireHighlight) or highlighted then
                local itemName = slot:FindFirstChild("ItemName")
                local text = itemName and itemName:IsA("TextLabel") and itemName.Text or slot.Name
                if type(text) == "string" then
                    for _, keyword in ipairs(filters) do
                        if type(keyword) == "string" and keyword ~= "" then
                            if string.find(string.lower(text), string.lower(keyword), 1, true) then
                                return true
                            end
                        end
                    end
                end
            end
        end
        return false
    end
    if scanUI(hotbar, false) then return true end
    if scanUI(itemContainer, false) then return true end
    local backpack = LocalPlayer and LocalPlayer:FindFirstChild("Backpack")
    local char = LocalPlayer and LocalPlayer.Character
    for _, container in ipairs({ backpack, char }) do
        if container then
            for _, tool in ipairs(container:GetChildren()) do
                if tool:IsA("Tool") then
                    for _, keyword in ipairs(filters) do
                        if type(keyword) == "string" and keyword ~= "" then
                            if string.find(string.lower(tool.Name), string.lower(keyword), 1, true) then
                                return true
                            end
                        end
                    end
                end
            end
        end
    end
    return false
end
humanoid = LocalPlayer.Character
and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
LocalPlayer.Backpack.ChildAdded:Connect(function(instance)
    if not AutoUtil.Appraise.appraiseHeldEnable or not humanoid then
        return
    end
    if not instance:IsA("Tool") then
        return
    end
    task.wait(0.1)
    if instance.Parent == LocalPlayer.Backpack then
        humanoid:EquipTool(instance)
    end
end)
function AutoUtil.Appraise.AutoAppraiseHeld()
    if not AutoUtil.Appraise.appraiseHeldEnable then
        return
    end
    spawn(function()
        while AutoUtil.Appraise.appraiseHeldEnable do
            heldItem = findHeldItem()
            if heldItem then
                isFiltered = false
                for attempt = 1, 3 do
                    if AutoUtil.Appraise.applyFilter() then
                        isFiltered = true
                        break
                    end
                    if attempt < 3 then
                        task.wait(0.25 + math.random() * 0.25)
                    end
                end
                if isFiltered then
                    AutoUtil.Appraise.appraiseHeldEnable = false
                    break
                else
                    doAppraise()
                    task.wait(0.55 + math.random() * 0.4)
                end
            end
            task.wait(0.18 + math.random() * 0.18)
        end
    end)
end
function FormatNumber(n)
    return tostring(math.floor(n))
    :reverse()
    :gsub("(%d%d%d)", "%1,")
    :reverse()
    :gsub("^,", "")
end
function getPlayerValue(playerName)
    local valueSource = VarGames.FishData or fishdata
    local fishTable = type(valueSource) == "table" and (valueSource.Fish or valueSource) or nil
    local mutationTable = type(valueSource) == "table" and valueSource.Mutations or {}
    if type(fishTable) ~= "table" then
        return 0
    end
    local playerStatsData = workspace:FindFirstChild("PlayerStats")
    and workspace.PlayerStats:FindFirstChild(playerName)
    and workspace.PlayerStats[playerName]:FindFirstChild("T")
    and workspace.PlayerStats[playerName].T:FindFirstChild(playerName)
    if not playerStatsData then
        return 0
    end
    local inventory = playerStatsData:FindFirstChild("Inventory")
    if not inventory then
        return 0
    end
    local totalValue = 0
    for _, item in ipairs(inventory:GetChildren()) do
        local fishEntry = fishTable[item.Value]
        local basePrice = fishEntry and tonumber(fishEntry.Price)
        if basePrice then
            local price = basePrice
            local weight = item:FindFirstChild("Weight")
            local maxWeight = fishEntry.WeightPool and tonumber(fishEntry.WeightPool[2])
            if weight and maxWeight and maxWeight > 0 then
                price = math.ceil(basePrice / maxWeight * weight.Value * 10)
            end
            local shiny = item:FindFirstChild("Shiny")
            if shiny and shiny.Value then
                price *= 1.85
            end
            local sparkling = item:FindFirstChild("Sparkling")
            if sparkling and sparkling.Value then
                price *= 1.85
            end
            local mutation = item:FindFirstChild("Mutation")
            local mutationEntry = mutation and mutationTable[mutation.Value]
            local multiplier = mutationEntry and tonumber(mutationEntry.PriceMultiply)
            if multiplier then
                price *= multiplier
            end
            local stack = item:FindFirstChild("Stack")
            totalValue += price * (stack and tonumber(stack.Value) or 1)
        end
    end
    return math.floor(totalValue)
end
local autoConfirmConnection = nil
function startAutoConfirm()
    if autoConfirmConnection then return end
    local announcements = PlayerGui:FindFirstChild("hud")
    and PlayerGui.hud:FindFirstChild("safezone")
    and PlayerGui.hud.safezone:FindFirstChild("bodyannouncements")
    if not announcements then return end
    autoConfirmConnection = announcements.ChildAdded:Connect(function(child)
        if not _sX.autoconfirm or not child:IsA("Frame") or child.Name ~= "offer" then return end
        local confirmButton = child:WaitForChild("confirm", 3)
        if not confirmButton then return end
        local confirmDeadline = os.clock() + 15
        while _sX.autoconfirm and child.Parent and confirmButton.Parent and os.clock() < confirmDeadline do
            if confirmButton.Visible then
                confirmButton.Selectable = true
                GuiService.SelectedObject = confirmButton
                if keypress and keyrelease then
                    keypress(0x0D)
                    keyrelease(0x0D)
                end
            end
            task.wait(0.1)
        end
        if GuiService.SelectedObject == confirmButton then
            GuiService.SelectedObject = nil
        end
    end)
end
function applyFishPriceToItem(v)
    if not v:IsA("ImageButton") then
        return
    end
    toolObj = v:FindFirstChild("tool")
    if toolObj and _sX.fishPriceEnable then
        fishInfo = fishdata[tostring(toolObj.Value)]
        if
        fishInfo
        and fishInfo.Price
        and not v:FindFirstChild("nathub_sellprice")
        then
            currency = fishInfo.Worlds and " E$" or " C$"
            sellprice = v:FindFirstChild("stack"):Clone()
            sellprice.Name = "nathub_sellprice"
            sellprice.Text = fishInfo.Price .. currency
            sellprice.TextColor3 = Color3.fromRGB(0, 255, 0)
            sellprice.Parent = v
        end
    end
    if v:FindFirstChild("ImageLabel") then
        v:FindFirstChild("ImageLabel").Visible = not _sX.hideRarityEnable
    end
end
function showAllFishPrice()
    playerGui = game:GetService("Players").LocalPlayer.PlayerGui
    hotbar = playerGui.backpack.hotbar:GetChildren()
    inventory = playerGui.backpack.inventory.itemContainer:GetChildren()
    if _sX.fishPriceEnable then
        for _, v in ipairs(hotbar) do
            applyFishPriceToItem(v)
        end
        for _, v in ipairs(inventory) do
            applyFishPriceToItem(v)
        end
    else
        for _, v in ipairs(hotbar) do
            if v:FindFirstChild("nathub_sellprice") then
                v.nathub_sellprice:Destroy()
            end
        end
        for _, v in ipairs(inventory) do
            if v:FindFirstChild("nathub_sellprice") then
                v.nathub_sellprice:Destroy()
            end
        end
    end
    for _, v in ipairs(hotbar) do
        if v:FindFirstChild("ImageLabel") then
            v.ImageLabel.Visible = not _sX.hideRarityEnable
        end
    end
    for _, v in ipairs(inventory) do
        if v:FindFirstChild("ImageLabel") then
            v.ImageLabel.Visible = not _sX.hideRarityEnable
        end
    end
end
game:GetService("Players").LocalPlayer.PlayerGui.backpack.inventory.scroll.ChildAdded
:Connect(function(v)
    task.wait()
    applyFishPriceToItem(v)
end)
game:GetService("Players").LocalPlayer.PlayerGui.backpack.hotbar.ChildAdded
:Connect(function(v)
    task.wait()
    applyFishPriceToItem(v)
end)
function hideFishRarity()
    hotbar =
    game:GetService("Players").LocalPlayer.PlayerGui.backpack.hotbar
    :GetChildren()
    inventory =
    game:GetService("Players").LocalPlayer.PlayerGui.backpack.inventory.itemContainer
    :GetChildren()
    for _, v in ipairs(hotbar) do
        rarity = v:FindFirstChild("ImageLabel")
        rare = v:FindFirstChild("Rarity")
        if rarity and rare then
            rarity.Visible = not _sX.hideRarityEnable
            rare.Visible = not _sX.hideRarityEnable
        end
    end
    for _, v in ipairs(inventory) do
        rarity = v:FindFirstChild("ImageLabel")
        rare = v:FindFirstChild("Rarity")
        if rarity and rare then
            rarity.Visible = not _sX.hideRarityEnable
            rare.Visible = not _sX.hideRarityEnable
        end
    end
end
showAllFishPrice()
hideFishRarity()
function ToggleReeling(state)
    storageSound = ReplicatedStorage:FindFirstChild("resources")
    and ReplicatedStorage.resources:FindFirstChild("sounds")
    and ReplicatedStorage.resources.sounds:FindFirstChild("sfx")
    and ReplicatedStorage.resources.sounds.sfx:FindFirstChild("fishing")
    and ReplicatedStorage.resources.sounds.sfx.fishing:FindFirstChild(
        "reeling"
    )
    if storageSound and storageSound:IsA("Sound") then
        reelingStorageVolume = reelingStorageVolume or storageSound.Volume
        storageSound.Volume = state and 0 or reelingStorageVolume
        if state then
            storageSound:Stop()
        end
    end
end
local reelingSoundVolumes = setmetatable({}, { __mode = "k" })
local function applyReelingMute(sound)
    if not sound:IsA("Sound") or sound.Name ~= "reeling" then return end
    if _sX.ToggleReelingSound then
        if reelingSoundVolumes[sound] == nil then
            reelingSoundVolumes[sound] = sound.Volume
        end
        sound.Volume = 0
        if sound.IsPlaying then sound:Stop() end
    elseif reelingSoundVolumes[sound] ~= nil then
        sound.Volume = reelingSoundVolumes[sound]
        reelingSoundVolumes[sound] = nil
    end
end
task.spawn(function()
    while true do
        task.wait(0.3)
        local char = LocalPlayer.Character
        local rootPart = char and char:FindFirstChild("HumanoidRootPart")
        if rootPart then
            for _, sound in ipairs(rootPart:GetChildren()) do
                applyReelingMute(sound)
            end
        end
    end
end)
LocalPlayer.CharacterAdded:Connect(function(char)
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart", 10)
    ToggleReeling(_sX.ToggleReelingSound)
end)
function checkAndRemoveTree()
    for _, objectName in ipairs({ "Tree", "Cathulu" }) do
        local passiveObject = workspace:FindFirstChild(objectName)
        if passiveObject then
            pcall(passiveObject.Destroy, passiveObject)
        end
    end
end
NetFolder = ReplicatedStorage:FindFirstChild("packages")
and ReplicatedStorage.packages:FindFirstChild("Net")
if NetFolder then
    RequestCutsceneSync =
    NetFolder:FindFirstChild("RE/RequestCutsceneSync")
    RequestCutscene = NetFolder:FindFirstChild("RE/RequestCutscene")
    if RequestCutsceneSync then
        RequestCutsceneSync:Destroy()
    end
    if RequestCutscene then
        RequestCutscene:Destroy()
    end
else
    warn("Net folder not found in ReplicatedStorage")
end
local getSpawnFolders
if placeId == 72907489978215 then
    excludedFolders = {
        TeleportDelay = true,
        TpSpots = true,
    }
    getSpawnFolders = function()
        folderNames = {}
        for _, item in pairs(workspace.world.spawns:GetChildren()) do
            if item:IsA("Folder") and not excludedFolders[item.Name] then
                table.insert(folderNames, item.Name)
            end
        end
        return folderNames
    end
end
secondSeaTeleports = {
    ["WAVEBORNE"] = Vector3.new(366.208130, 88.572540, 772.958008),
    ["PINE SHOAL"] = Vector3.new(1180.223999, 81.172531, 488.504517),
    ["EMBERREACH"] = Vector3.new(2379.284424, 83.922630, 498.383850),
    ["AZURE LAGOON"] = Vector3.new(1319.698242, 79.672539, 2104.331299),
    ["THE CURSED SHORES"] = Vector3.new(-214.631897, 84.302124, 1963.922485),
    ["ISLE OF NEW BEGINING"] = Vector3.new(-353.710083, 80.627434, -440.677399),
    ["LUSHGROVE"] = Vector3.new(1116.802124, 105.685226, -584.745178),
}
function getTeleportNames(tbl)
    names = {}
    for name, _ in pairs(tbl) do
        table.insert(names, name)
    end
    table.sort(names, function(a, b)
        return a:lower() < b:lower()
    end)
    return names
end
if TpSpotsFolder then
    for _, v in pairs(TpSpotsFolder:GetChildren()) do
        _sX.teleportSpotsMap[v.Name] = v
        table.insert(_sX.teleportSpotsNames, v.Name)
    end
    table.sort(_sX.teleportSpotsNames, function(a, b)
        return a:lower() < b:lower()
    end)
end
function teleportToFirstSea(name)
    target = _sX.teleportSpotsMap[name]
    if target and HumanoidRootPart then
        SafeMotion.Teleport(HumanoidRootPart, target.CFrame + Vector3.new(0, 5, 0))
    end
end
function teleportToSecondSea(value)
    selectedFolder = workspace.world.spawns:FindFirstChild(value)
    if selectedFolder and selectedFolder:IsA("Folder") then
        target = selectedFolder:FindFirstChildWhichIsA("Model")
        or selectedFolder:FindFirstChildWhichIsA("Part")
        if target then
            game.Players.LocalPlayer.Character:PivotTo(target:GetPivot())
        else
            warn("No teleport target found in folder:", value)
        end
    else
        warn("Folder not found:", value)
    end
end
if not NpcFolder then
    warn("Folder NPC tidak ditemukan!")
    return
end
_sX.npcCFrames = _sX.npcCFrames or {}
_sX.npcKnown = _sX.npcKnown or {
    ["Angler (Moosewood)"] = CFrame.new(481, 151, 299),
    ["Angler (Roslit)"] = CFrame.new(-1512, 140, 688),
    ["Angler (Sunstone)"] = CFrame.new(-885, 135, -1115),
    ["Angler (Terrapin)"] = CFrame.new(-153, 144, 1954),
    ["Angler (Depths)"] = CFrame.new(980, -700, 1230),
    ["Angler (Ancient)"] = CFrame.new(5737, 177, -57),
    ["Angler (Forsaken)"] = CFrame.new(-2702, 169, 1798),
    ["Angler (Crimson)"] = CFrame.new(-1069, -361, -4811),
    ["Angler (Luminescent)"] = CFrame.new(-1050, -337, -4078),
    ["Angler (Jungle)"] = CFrame.new(-2726, 226, -2186),
    ["Merlin"] = CFrame.new(-929, 224, -996),
    ["Pierre"] = CFrame.new(387, 133, 258),
    ["Halt"] = CFrame.new(-1319, 133, 412),
    ["Appraiser (Roslit)"] = CFrame.new(-1644, 137, 727),
    ["Appraiser (Moosewood)"] = CFrame.new(446, 150, 230),
    ["Appraiser (Terrapin)"] = CFrame.new(-109, 157, 1956),
}
local function npcCFrameOf(obj)
    if obj:IsA("Model") then
        if obj.PrimaryPart then return obj.PrimaryPart.CFrame end
        local hrp = obj:FindFirstChild("HumanoidRootPart")
        if hrp then return hrp.CFrame end
        local ok, pivot = pcall(function() return obj:GetPivot() end)
        if ok then return pivot end
        local bp = obj:FindFirstChildWhichIsA("BasePart", true)
        return bp and bp.CFrame or nil
    elseif obj:IsA("BasePart") then
        return obj.CFrame
    end
    return nil
end
local function collectNpcs(root)
    for _, v in ipairs(root:GetChildren()) do
        if v:IsA("Model") or v:IsA("Part") then
            if npcCFrameOf(v) then
                if not _sX.npcCFrames[v.Name] then
                    _sX.npcCFrames[v.Name] = v
                    table.insert(_sX.teleportNPC, v.Name)
                end
            end
        elseif v:IsA("Folder") then
            collectNpcs(v)
        end
    end
end
collectNpcs(NpcFolder)
for name in pairs(_sX.npcKnown) do
    if not _sX.npcCFrames[name] then
        table.insert(_sX.teleportNPC, name)
    end
end
table.sort(_sX.teleportNPC, function(a, b)
    return a:lower() < b:lower()
end)
function TeleportToNPC()
    local Value = _sX.NPCsTPDropdownUI
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not (Value and Value ~= "Select NPC" and hrp) then
        warn("Pilih NPC dulu sebelum teleport!")
        return
    end
    local target = _sX.npcCFrames[Value]
    if not (target and target.Parent) then
        target = NpcFolder:FindFirstChild(Value, true)
        if target then _sX.npcCFrames[Value] = target end
    end
    if target then
        local targetCFrame = npcCFrameOf(target)
        if targetCFrame then
            SafeMotion.Teleport(hrp, targetCFrame + Vector3.new(0, 5, 0))
            return
        end
    end
    if _sX.npcKnown[Value] then
        SafeMotion.Teleport(hrp, _sX.npcKnown[Value] + Vector3.new(0, 5, 0))
        return
    end
    warn("NPC tidak ditemukan: ", Value)
end
if not Interact then
    warn("Folder NPC tidak ditemukan!")
    return
end
for _, v in pairs(Interact:GetChildren()) do
    if v:IsA("Model") or v:IsA("Part") then
        table.insert(_sX.teleportInteract, v.Name)
    end
end
table.sort(_sX.teleportInteract, function(a, b)
    return a:lower() < b:lower()
end)
function TeleportToInteract()
    Value = _sX.InteractDropDown
    if Value and HumanoidRootPart then
        target = Interact:FindFirstChild(Value)
        if target then
            targetCFrame = target:IsA("Model")
            and (target.PrimaryPart and target.PrimaryPart.CFrame or target:FindFirstChild(
                "HumanoidRootPart"
                ) and target.HumanoidRootPart.CFrame)
            or target:IsA("BasePart") and target.CFrame
            if targetCFrame then
                SafeMotion.Teleport(HumanoidRootPart, targetCFrame + Vector3.new(0, 5, 0))
            else
                warn("NPC tidak memiliki CFrame: ", Value)
            end
        else
            warn("NPC tidak ditemukan: ", Value)
        end
    else
        warn("Pilih NPC dulu sebelum teleport!")
    end
end
function UpdatePlayerList()
    playerNames = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(playerNames, player.Name)
        end
    end
    if #playerNames == 0 then
        playerNames = { "No players online" }
    end
    _sX.PlayerDropdown = playerNames
end
Players.PlayerAdded:Connect(UpdatePlayerList)
Players.PlayerRemoving:Connect(UpdatePlayerList)
UpdatePlayerList()
function DisableAnimator()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local animator = hum and hum:FindFirstChildOfClass("Animator")
    local animateScript = char:FindFirstChild("Animate")
    if _sX.isDisableAnimator then
        if animator then
            pcall(animator.Destroy, animator)
        end
        if animateScript then
            animateScript.Disabled = true
        end
        return
    end
    if hum and not hum:FindFirstChildOfClass("Animator") then
        Instance.new("Animator").Parent = hum
    end
    if animateScript then
        animateScript.Disabled = false
    end
end
RunService.Heartbeat:Connect(function()
    if not _sX.isDisableAnimator then return end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local animator = hum and hum:FindFirstChildOfClass("Animator")
    if animator then
        pcall(animator.Destroy, animator)
    end
end)
fishList = data.Fish or {}
function HideFishInventory()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return end
    for _, item in ipairs(backpack:GetChildren()) do
        if fishList[item.Name] then
            table.insert(_sX.storedItems, item)
            item.Parent = nil
        end
    end
end
function ShowFishInventory()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return end
    for _, item in pairs(_sX.storedItems) do
        if item then
            pcall(function() item.Parent = backpack end)
        end
    end
    _sX.storedItems = {}
end
pool_names = {
    "Whales Pool",
    "Orcas Pool",
    "The Kraken Pool",
    "Animal Pool",
    "Animal Pool - Second Sea",
    "Octophant Pool Without Elephant",
    "Sea Leviathan Pool",
    "Isonade",
    "Forsaken Veil - Scylla",
    "Blue Moon - Second Sea",
    "Blue Moon - First Sea",
    "LEGO",
    "LEGO - Studolodon",
    "Mosslurker",
    "Narwhal",
    "Whale Shark",
    "Birthday Megalodon",
    "Colossal Blue Dragon",
    "Colossal Ancient Dragon",
    "Colossal Ethereal Dragon",
}
megalodon_pool_names = {
    Default = "Megalodon Default",
    Ancient = "Megalodon Ancient",
    Phantom = "Megalodon Phantom",
}
function getStatus(obj)
    return obj and "\226\156\133" or "\226\157\140"
end
function getPlayerHeader()
    local leaderstats = LocalPlayer and LocalPlayer:FindFirstChild("leaderstats")
    local levelText, currencyText, currencyName = "N/A", "N/A", "C$"
    if leaderstats then
        for _, stat in ipairs(leaderstats:GetChildren()) do
            if stat:IsA("ValueBase") then
                if stat.Name == "Level" then
                    levelText = tostring(stat.Value)
                elseif string.find(stat.Name, "%$") then
                    currencyName = stat.Name
                    currencyText = tonumber(stat.Value) and FormatNumber(tonumber(stat.Value)) or tostring(stat.Value)
                end
            end
        end
    end
    return string.format(
        "Username: %s\10%s: %s\10Level: %s\10",
        LocalPlayer and LocalPlayer.Name or "N/A",
        currencyName,
        currencyText,
        levelText
    )
end
local eventParagraph
local inventoryButton
function CheckLevel()
    while task.wait(1) do
        leaderstats = LocalPlayer.leaderstats
        if leaderstats then
            levelStat = leaderstats:FindFirstChild("Level")
            if
            levelStat
            and tonumber(levelStat.Value) >= _sX.targetLevel
            and _sX.targetLevel > 0
            then
                LocalPlayer:Kick(
                    "ThanHub Targeting Level! \10Target Level Tercapai! Kamu telah dikick oleh sistem.\10Target Level: "
                    .. _sX.targetLevel
                )
                break
            end
        end
    end
end
task.spawn(CheckLevel)
streamerModeEnabled = false
originalTexts = {}
replacementText = "THANHUB PROTECT"
function RainbowColor()
    return Color3.fromHSV(tick() % 10 / 10, 1, 1)
end
function RemoveClothingAndHair(character)
    for _, item in pairs(character:GetChildren()) do
        if
        item:IsA("Shirt")
        or item:IsA("Pants")
        or item:IsA("ShirtGraphic")
        then
            item:Destroy()
        end
    end
    for _, accessory in pairs(character:GetChildren()) do
        if accessory:IsA("Accessory") then
            handle = accessory:FindFirstChild("Handle")
            if handle then
                accessory:Destroy()
            end
        end
    end
end
function makeCharacterBoxy(character)
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("MeshPart") or part:IsA("Part") then
            part.Color = RainbowColor()
        end
    end
end
local function textContainsIdentity(text)
    if type(text) ~= "string" or text == "" then return false end
    return string.find(text, LocalPlayer.Name, 1, true) ~= nil
    or string.find(text, LocalPlayer.DisplayName, 1, true) ~= nil
end
function updateTextLabel(label)
    local ok, currentText = pcall(function() return label.Text end)
    if not ok then return end
    if streamerModeEnabled then
        if originalTexts[label] == nil and textContainsIdentity(currentText) then
            originalTexts[label] = currentText
        end
        if originalTexts[label] ~= nil and currentText ~= replacementText then
            if textContainsIdentity(currentText) then
                originalTexts[label] = currentText
            end
            pcall(function() label.Text = replacementText end)
        end
        return
    end
    if originalTexts[label] ~= nil then
        pcall(function() label.Text = originalTexts[label] end)
        originalTexts[label] = nil
    end
end
local function getHudIdentityLabels()
    local hud = LocalPlayer.PlayerGui:FindFirstChild("hud")
    local safezone = hud and hud:FindFirstChild("safezone")
    return safezone and safezone:FindFirstChild("coins"), safezone and safezone:FindFirstChild("lvl")
end
function updateGUITexts()
    local coinsLabel, levelLabel = getHudIdentityLabels()
    for key, label in pairs({ coins = coinsLabel, level = levelLabel }) do
        if streamerModeEnabled then
            if originalTexts[key] == nil then
                originalTexts[key] = label.Text
            end
            label.Text = replacementText
        elseif originalTexts[key] ~= nil then
            label.Text = originalTexts[key]
            originalTexts[key] = nil
        end
    end
end
local streamerLabelConnections = {}
local streamerCharacterConnection = nil
local function scanIdentityRoot(root)
    for _, obj in ipairs(root:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            updateTextLabel(obj)
        end
    end
end
local function onIdentityDescendant(descendant)
    if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
        task.defer(updateTextLabel, descendant)
    end
end
function toggleStreamerMode(state)
    streamerModeEnabled = state == true
    local identityRoots = { LocalPlayer.PlayerGui, workspace }
    for _, root in ipairs(identityRoots) do
        pcall(scanIdentityRoot, root)
    end
    for key, label in pairs(originalTexts) do
        if typeof(key) == "Instance" and not streamerModeEnabled then
            updateTextLabel(key)
        end
    end
    updateGUITexts()
    for _, conn in ipairs(streamerLabelConnections) do
        conn:Disconnect()
    end
    table.clear(streamerLabelConnections)
    if streamerCharacterConnection then
        streamerCharacterConnection:Disconnect()
        streamerCharacterConnection = nil
    end
    if not streamerModeEnabled then return end
    for _, root in ipairs(identityRoots) do
        table.insert(streamerLabelConnections, root.DescendantAdded:Connect(onIdentityDescendant))
    end
    if LocalPlayer.Character then
        RemoveClothingAndHair(LocalPlayer.Character)
        makeCharacterBoxy(LocalPlayer.Character)
    end
    streamerCharacterConnection = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        newCharacter:WaitForChild("HumanoidRootPart", 10)
        if not streamerModeEnabled then return end
        RemoveClothingAndHair(newCharacter)
        makeCharacterBoxy(newCharacter)
    end)
end
local lastStreamerTick = 0
RunService.Heartbeat:Connect(function()
    if not streamerModeEnabled then return end
    local now = os.clock()
    if now - lastStreamerTick < 0.1 then return end
    lastStreamerTick = now
    local rainbow = RainbowColor()
    local coinsLabel, levelLabel = getHudIdentityLabels()
    if coinsLabel then coinsLabel.TextColor3 = rainbow end
    if levelLabel then levelLabel.TextColor3 = rainbow end
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("MeshPart") or part:IsA("Part") then
            part.Color = rainbow
        end
    end
end)
function updateCanCollide(value)
    local zones = workspace:FindFirstChild("zones")
    local fishingZone = zones and zones:FindFirstChild("fishing")
    if not fishingZone then return end
    for _, descendant in ipairs(fishingZone:GetDescendants()) do
        if descendant:IsA("BasePart") then
            descendant.CanCollide = value == true
        end
    end
end
NoclipConnection = RunService.Stepped:Connect(function()
    if _sX.Noclip ~= true then return end
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") and part.CanCollide then
            part.CanCollide = false
        end
    end
end)
function HopToServer()
    placeId = game.PlaceId
    visitedServers = {}
    nextCursor = ""
    currentHour = os.date("!*t").hour
    function FindNewServer()
        local serverList
        if nextCursor == "" then
            serverList = game.HttpService:JSONDecode(
                game:HttpGet(
                    "https://games.roblox.com/v1/games/"
                    .. placeId
                    .. "/servers/Public?sortOrder=Asc&limit=100"
                )
            )
        else
            serverList = game.HttpService:JSONDecode(
                game:HttpGet(
                    "https://games.roblox.com/v1/games/"
                    .. placeId
                    .. "/servers/Public?sortOrder=Asc&limit=100&cursor="
                    .. nextCursor
                )
            )
        end
        if serverList.nextPageCursor then
            nextCursor = serverList.nextPageCursor
        end
        for _, server in pairs(serverList.data) do
            canJoin = true
            serverId = tostring(server.id)
            if server.maxPlayers > server.playing then
                for _, visited in pairs(visitedServers) do
                    if serverId == tostring(visited) then
                        canJoin = false
                    end
                end
                if canJoin then
                    table.insert(visitedServers, serverId)
                    wait()
                    pcall(function()
                        game:GetService("TeleportService")
                        :TeleportToPlaceInstance(
                            placeId,
                            serverId,
                            game.Players.LocalPlayer
                        )
                    end)
                    wait()
                end
            end
        end
    end
    function TryFindServer()
        while wait() do
            pcall(function()
                FindNewServer()
                if nextCursor ~= "" then
                    FindNewServer()
                end
            end)
        end
    end
    TryFindServer()
end
isFrozen1 = false
animatorParent1 = nil
function autoEquipRod()
    local rodName = workspace.PlayerStats[LocalPlayer.Name].T[LocalPlayer.Name].Stats.rod.Value
    if rodName and rodName ~= "" then
        local backpack = LocalPlayer:WaitForChild("Backpack")
        local rod = backpack:FindFirstChild(rodName)
        if rod then
            LocalPlayer.Character.Humanoid:EquipTool(rod)
        end
    end
end
function FreezeCharacter1(state)
    SafeMotion.FreezeOnBoat(state, function() return isFrozen1 end, function(v) isFrozen1 = v end)
end
local function readWorldValue(valueName)
    local world = ReplicatedStorage:FindFirstChild("world")
    local value = world and world:FindFirstChild(valueName)
    if not (value and value:IsA("ValueBase")) then return "N/A" end
    local text = tostring(value.Value)
    return text ~= "" and text or "None"
end
local lastEventStatusContent = nil
function updateEventStatus()
    if not (EventStatusParagraph and EventStatusParagraph.Set) then return end
    pcall(function()
        local zones = workspace:FindFirstChild("zones")
        local fishingZone = zones and zones:FindFirstChild("fishing")
        local lines = { getPlayerHeader() }
        table.insert(lines, string.format("Event: %s | Admin Event: %s", readWorldValue("event"), readWorldValue("admin_event")))
        table.insert(lines, string.format("Weather: %s | Cycle: %s | Season: %s", readWorldValue("weather"), readWorldValue("cycle"), readWorldValue("season")))
        local world = ReplicatedStorage:FindFirstChild("world")
        local meteorFlag = world and world:FindFirstChild("meteor_active")
        table.insert(lines, string.format("Server Luck: x%s | Starfall: %s", readWorldValue("luck_Server"), getStatus(meteorFlag and meteorFlag.Value == true)))
        if CosmicHop and CosmicHop.GetStatusText then
            local ok, cosmicText = pcall(CosmicHop.GetStatusText)
            table.insert(lines, "Cosmic Relic: " .. (ok and cosmicText or "N/A"))
        end
        if EventHunt and EventHunt.Status then
            table.insert(lines, "Hunt: " .. EventHunt.Status)
        end
        table.insert(lines, "")
        for _, poolName in ipairs(pool_names) do
            table.insert(lines, string.format("%s: %s", poolName, getStatus(fishingZone and fishingZone:FindFirstChild(poolName))))
        end
        for _, variant in ipairs({ "Default", "Ancient", "Phantom" }) do
            local poolName = megalodon_pool_names[variant]
            table.insert(lines, string.format("Megalodon %s: %s", variant, getStatus(fishingZone and fishingZone:FindFirstChild(poolName))))
        end
        local content = table.concat(lines, "\10")
        if content == lastEventStatusContent then return end
        lastEventStatusContent = content
        EventStatusParagraph:Set({ Content = content })
    end)
end
task.spawn(function()
    while true do
        updateEventStatus()
        task.wait(2)
    end
end)
_G.CustomBarSize = _G.CustomBarSize or 1
_G.FastProgressSpeed = _G.FastProgressSpeed or 50
_G.FishMoveInterval = _G.FishMoveInterval or 1
ReplicatedStorage = game:GetService("ReplicatedStorage")
ReelController = require(ReplicatedStorage.client.legacyControllers.ReelController)
if not _G._OriginalFischReelNew then
    _G._OriginalFischReelNew = ReelController.new
end
ReelController.new = function(...)
    local instance = _G._OriginalFischReelNew(...)
    if instance and typeof(instance) == "table" then
        local rawUpdate = instance.Update
        instance.Update = function(self, deltaTime)
            local result = rawUpdate(self, deltaTime)
            if _G.CustomBarEnabled and not self._noCustomBar then
                local size = tonumber(_G.CustomBarSize)
                if size and size > 0 then
                    self.barSize = size
                    if size >= 1 then
                        self.barPosition = 0.5
                    else
                        local minPos = (self.minBarPosition or 0) + size / 2
                        local maxPos = (self.maxBarPosition or 1) - size / 2
                        self.barPosition = math.clamp(self.barPosition or 0.5, minPos, maxPos)
                    end
                end
            end
            if _G.FollowBarEnabled and not _G.FastReelEnabled and not (_G.CustomBarEnabled and not self._noCustomBar and (tonumber(_G.CustomBarSize) or 0) >= 1) then
                self.barPosition = self.fishPosition
            end
            if _G.FastReelEnabled then
                self.progress = 100
            elseif _G.FastProgressEnabled then
                self:AddProgress((_G.FastProgressSpeed or 50) * deltaTime)
            end
            return result
        end
    end
    return instance
end
_G.FastReelEnabled = false
finishing = false
local lastFinishedReel = nil
function reelFinish()
    local current = ReelController.ActiveReel
    if not _G.FastReelEnabled or finishing or not current or current == lastFinishedReel then return end
    if not current.active or not current.ready then return end
    finishing = true
    lastFinishedReel = current
    task.spawn(function()
        pcall(function()
            local isPerfect = false
            if _sX and _sX.perfectCatchEnabled then
                isPerfect = true
            elseif _sX and _sX.RandomCatchEnabled then
                local chance = _sX.randomCatchChance or 50
                isPerfect = (math.random(1, 100) <= chance)
            end
            current.perfect = isPerfect
            current:EndMinigame(true)
        end)
        task.wait(0.25)
        finishing = false
    end)
end
if not _G._OriginalFischStartReel then
    _G._OriginalFischStartReel = ReelController.StartReel
end
ReelController.StartReel = function(params)
    local reelObject = _G._OriginalFischStartReel(params)
    if reelObject and typeof(reelObject) == "table" then
        if _G.FastReelEnabled then
            reelObject.progress = 100
            if reelObject.OnReady then
                reelObject.OnReady:Once(function()
                    task.defer(reelFinish)
                end)
            end
        end
    end
    if reelObject and params and params.fish then
        if type(processFishDetection) == "function" then
            pcall(processFishDetection, params.fish, reelObject)
        end
        if type(processFishWebhook) == "function" then
            pcall(processFishWebhook, params.fish)
        end
    end
    return reelObject
end
task.spawn(function()
    while true do
        if _G.FastReelEnabled then
            reelFinish()
        end
        task.wait(0.05)
    end
end)
RunService = game:GetService("RunService")
ReplicatedStorage = game:GetService("ReplicatedStorage")
local MetronomeRemote = nil
pcall(function()
    local netPkg = ReplicatedStorage:WaitForChild("packages", 2) and ReplicatedStorage.packages:WaitForChild("Net", 2)
    MetronomeRemote = netPkg and netPkg:FindFirstChild("RE/MetronomeBuff/Input")
end)
_G.AutoMetronomeConnection = nil
local lastHitSection = nil
local MetronomeGate = {
    LastFire = 0,
    MinInterval = 0.55,
    JitterRange = 0.25,
    MaxFiresPerReel = 5,
    FiresThisReel = 0,
    CurrentReel = nil,
    MissChance = 0.08,
}
local function StopAutoMetronome()
    if _G.AutoMetronomeConnection then
        _G.AutoMetronomeConnection:Disconnect()
        _G.AutoMetronomeConnection = nil
    end
    MetronomeGate.FiresThisReel = 0
    MetronomeGate.CurrentReel = nil
end
local function StartAutoMetronome()
    StopAutoMetronome()
    _G.AutoMetronomeConnection = RunService.RenderStepped:Connect(function()
        if not _sX.AutoMetronome then return end
        pcall(function()
            local reel = ReelController.ActiveReel
            if not reel or not reel.active then
                lastHitSection = nil
                MetronomeGate.FiresThisReel = 0
                MetronomeGate.CurrentReel = nil
                return
            end
            if MetronomeGate.CurrentReel ~= reel then
                MetronomeGate.CurrentReel = reel
                MetronomeGate.FiresThisReel = 0
            end
            if MetronomeGate.FiresThisReel >= MetronomeGate.MaxFiresPerReel then return end
            local now = tick()
            local gap = now - MetronomeGate.LastFire
            local required = MetronomeGate.MinInterval + math.random() * MetronomeGate.JitterRange
            if gap < required then return end
            local metronome = reel.reel:FindFirstChild("Details") and reel.reel.Details:FindFirstChild("Metronome")
            if not metronome then return end
            local ticker = metronome:FindFirstChild("Ticker")
            if not ticker or not MetronomeRemote then return end
            local currentRot = ticker.Rotation
            for _, section in pairs(metronome:GetChildren()) do
                if section:IsA("ImageLabel") and string.find(section.Name, "Section") then
                    local targetRot = section.Rotation
                    local diff = math.abs(currentRot - targetRot)
                    if diff <= 7 then
                        if lastHitSection ~= section then
                            local shouldMiss = math.random() < MetronomeGate.MissChance
                            MetronomeRemote:FireServer(not shouldMiss)
                            MetronomeGate.LastFire = now
                            MetronomeGate.FiresThisReel = MetronomeGate.FiresThisReel + 1
                            if not shouldMiss and reel.AddProgress then
                                local progressStep = 0.08 + math.random() * 0.06
                                reel:AddProgress(progressStep)
                            end
                            lastHitSection = section
                            task.delay(0.35 + math.random() * 0.2, function()
                                if lastHitSection == section then
                                    lastHitSection = nil
                                end
                            end)
                        end
                        break
                    end
                end
            end
        end)
    end)
end
Players = game:GetService("Players")
LocalPlayer = Players.LocalPlayer
function autoEquipRod()
    rodName =
    workspace.PlayerStats[LocalPlayer.Name].T[LocalPlayer.Name].Stats.rod.Value
    if rodName and rodName ~= "" then
        backpack = LocalPlayer:WaitForChild("Backpack")
        rod = backpack:FindFirstChild(rodName)
        if rod then
            LocalPlayer.Character.Humanoid:EquipTool(rod)
        end
    end
end
RunService = game:GetService("RunService")
Players = game:GetService("Players")
localPlayer = Players.LocalPlayer
local targetLoopFunc = nil
local selectedRarities, isResetting = {}, false
local rarityMapping = {
    ["Special"] = "bitespecial",
    ["Legendary"] = "bitelegendary",
    ["Exotic"] = "biteexotic",
    ["Divine"] = "bitedivine"
}
local function setupSoundListener(character)
    local h = character:WaitForChild("Head", 5)
    if not h then return end
    h.ChildAdded:Connect(function(child)
        if not snapReelEnabled or isResetting or not next(selectedRarities) then return end
        local childName = string.lower(child.Name)
        if childName == "bite" then
            task.delay(0.35, function()
                if isResetting or not next(selectedRarities) then return end
                local foundTarget = false
                for rarityName, isSelected in pairs(selectedRarities) do
                    if isSelected and rarityMapping[rarityName] then
                        local targetPrefix = rarityMapping[rarityName]
                        for _, s in pairs(h:GetChildren()) do
                            if s:IsA("Sound") and string.find(string.lower(s.Name), targetPrefix) then
                                foundTarget = true
                                break
                            end
                        end
                    end
                    if foundTarget then break end
                end
                if not foundTarget then
                    warn("[Snap Reel] RARITY MISMATCH: Resetting...")
                    isResetting = true
                    resetRod()
                    task.wait(0.5)
                    isResetting = false
                end
            end)
        end
    end)
end
LocalPlayer.CharacterAdded:Connect(setupSoundListener)
if LocalPlayer.Character then setupSoundListener(LocalPlayer.Character) end
activeFish = {}
targetMutations = {}
targetSpecialMutations = {}
mutationFilterAktif = false
specialMutationFilterAktif = false
maxWeightInput = nil
snapReelEnabled = false
selectedFish = nil
inputFishName = nil
lastNotification = nil
showNotification = false
function isAnyFishSelected(selectedTable)
    if type(selectedTable) ~= "table" then return false end
    for _, isChecked in pairs(selectedTable) do
        if isChecked then return true end
    end
    return false
end
function normalize(str)
    if not str then return "" end
    return string.lower(string.gsub(tostring(str), "%s+", ""))
end
function fishMatch(fishName)
    local f = normalize(fishName)
    if f == "" then return false end
    if type(selectedFish) == "table" and isAnyFishSelected(selectedFish) then
        for targetName, isChecked in pairs(selectedFish) do
            if isChecked and normalize(targetName) == f then
                return true
            end
        end
    end
    if inputFishName and inputFishName ~= "" then
        local inputNorm = normalize(inputFishName)
        if inputNorm ~= "" and string.find(f, inputNorm, 1, true) ~= nil then
            return true
        end
    end
    return false
end
function resetRodNew()
    char = game.Players.LocalPlayer.Character
    if not char then return end
    pcall(function()
        pcall(function()
            Net = require(game:GetService("ReplicatedStorage").packages.Net)
        end)
        Net:RemoteEvent("FishingRod/Reset"):FireServer()
    end)
end
detectFishOnReelStart = {}
detectFishOnReelStart.OnDetect = nil
function detectFishOnReelStart.GetActiveFish()
    list = {}
    for _, fish in pairs(activeFish) do
        table.insert(list, fish)
    end
    return list
end
function detectFishOnReelStart.CleanupReel(reelInstance)
    activeFish[reelInstance] = nil
end
function processFishDetection(fish, reelInstance)
    if not reelInstance or not fish then return end
    fish = params.fish
    mutation = fish.Mutation or fish.Mutant or "Normal"
    weight = fish.Weight or 0
    lowMutation = string.lower(tostring(mutation))
    fishRarity = "Unknown"
    rarityColor = Color3.fromRGB(0, 120, 255)
    if fish.Rarity then
        fishRarity = tostring(fish.Rarity)
    elseif library and library.fish and library.fish[fish.Name] and library.fish[fish.Name].Rarity then
        fishRarity = tostring(library.fish[fish.Name].Rarity)
    end
    pcall(function()
        rarityModule = require(game:GetService("ReplicatedStorage").shared.modules.library.rarities)
        if rarityModule and rarityModule.Rarities and rarityModule.Rarities[fishRarity] then
            rarityColor = rarityModule.Rarities[fishRarity].Color or rarityColor
        end
    end)
    FishImages = pcall(function()
        return require(game:GetService("ReplicatedStorage"):WaitForChild("shared"):WaitForChild("data"):WaitForChild("fishImages"))
    end) and require(game:GetService("ReplicatedStorage").shared.data.fishImages) or {}
    fishImageId = FishImages[fish.Name] or "rbxassetid://0"
    isShiny = fish.Shiny == true or (lowMutation and string.find(lowMutation, "shiny"))
    isSparkling = fish.Sparkling == true or (lowMutation and string.find(lowMutation, "sparkling"))
    if showNotification then
        task.spawn(function()
            pcall(function()
                playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
                if lastNotification then
                    pcall(function() lastNotification:Destroy() end)
                    lastNotification = nil
                end
                sg = Instance.new("ScreenGui")
                sg.Name = "ThanHub_SecureNotif"
                sg.DisplayOrder = 999
                if typeof(protect_gui) == "function" then protect_gui(sg) end
                sg.Parent = playerGui
                lastNotification = sg
                frame = Instance.new("Frame")
                frame.Size = UDim2.new(0, 260, 0, 125)
                frame.Position = UDim2.new(1, 30, 0.4, 0)
                frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
                frame.BorderSizePixel = 0
                frame.Parent = sg
                corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(0, 10)
                corner.Parent = frame
                stroke = Instance.new("UIStroke")
                stroke.Thickness = 2
                stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                stroke.Color = rarityColor
                stroke.Parent = frame
                fishIcon = Instance.new("ImageLabel")
                fishIcon.Size = UDim2.new(0, 60, 0, 60)
                fishIcon.Position = UDim2.new(0, 10, 0, 40)
                fishIcon.Image = fishImageId
                fishIcon.BackgroundTransparency = 1
                fishIcon.Parent = frame
                iconCorner = Instance.new("UICorner")
                iconCorner.CornerRadius = UDim.new(0, 8)
                iconCorner.Parent = fishIcon
                title = Instance.new("TextLabel")
                title.Size = UDim2.new(1, -20, 0, 25)
                title.Position = UDim2.new(0, 12, 0, 5)
                title.Text = "ThanHub Detector"
                title.TextColor3 = Color3.fromRGB(0, 190, 255)
                title.TextSize = 16
                title.Font = Enum.Font.GothamBold
                title.BackgroundTransparency = 1
                title.TextXAlignment = Enum.TextXAlignment.Left
                title.Parent = frame
                textX = 80
                fishLabel = Instance.new("TextLabel")
                fishLabel.Size = UDim2.new(1, -textX, 0, 18)
                fishLabel.Position = UDim2.new(0, textX, 0, 32)
                fishLabel.Text = fish.Name
                fishLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                fishLabel.TextSize = 13
                fishLabel.Font = Enum.Font.GothamBold
                fishLabel.BackgroundTransparency = 1
                fishLabel.TextXAlignment = Enum.TextXAlignment.Left
                fishLabel.Parent = frame
                rarityLabel = Instance.new("TextLabel")
                rarityLabel.Size = UDim2.new(1, -textX, 0, 18)
                rarityLabel.Position = UDim2.new(0, textX, 0, 50)
                rarityLabel.Text = "Rarity: " .. fishRarity
                rarityLabel.TextColor3 = rarityColor
                rarityLabel.TextSize = 11
                rarityLabel.Font = Enum.Font.GothamBold
                rarityLabel.BackgroundTransparency = 1
                rarityLabel.TextXAlignment = Enum.TextXAlignment.Left
                rarityLabel.Parent = frame
                mutLabel = Instance.new("TextLabel")
                mutLabel.Size = UDim2.new(1, -textX, 0, 18)
                mutLabel.Position = UDim2.new(0, textX, 0, 68)
                mutLabel.Text = (mutation == "Normal" and "No Mutation" or "\226\156\168 " .. mutation)
                mutLabel.TextColor3 = (mutation ~= "Normal") and Color3.fromRGB(255, 220, 100) or Color3.fromRGB(180, 180, 180)
                mutLabel.TextSize = 11
                mutLabel.Font = Enum.Font.Gotham
                mutLabel.BackgroundTransparency = 1
                mutLabel.TextXAlignment = Enum.TextXAlignment.Left
                mutLabel.Parent = frame
                weightLabel = Instance.new("TextLabel")
                weightLabel.Size = UDim2.new(1, -textX, 0, 18)
                weightLabel.Position = UDim2.new(0, textX, 0, 86)
                weightLabel.Text = string.format("%.2f", weight) .. "kg"
                weightLabel.TextColor3 = Color3.fromRGB(200, 255, 200)
                weightLabel.TextSize = 11
                weightLabel.Font = Enum.Font.GothamBold
                weightLabel.BackgroundTransparency = 1
                weightLabel.TextXAlignment = Enum.TextXAlignment.Left
                weightLabel.Parent = frame
                bar = Instance.new("Frame")
                bar.Size = UDim2.new(0, 0, 0, 3)
                bar.Position = UDim2.new(0, 0, 1, -3)
                bar.BackgroundColor3 = stroke.Color
                bar.BorderSizePixel = 0
                bar.Parent = frame
                frame:TweenPosition(UDim2.new(1, -275, 0.4, 0), "Out", "Back", 0.5, true)
                bar:TweenSize(UDim2.new(1, 0, 0, 3), "Out", "Linear", 3, true)
                task.wait(3)
                if lastNotification == sg then
                    frame:TweenPosition(UDim2.new(1, 30, 0.4, 0), "In", "Quart", 0.5, true)
                    task.wait(0.5)
                    if lastNotification == sg then
                        pcall(function() sg:Destroy() end)
                        lastNotification = nil
                    end
                end
            end)
        end)
    end
    activeFish[reelInstance] = fish
    if type(detectFishOnReelStart.OnDetect) == "function" then
        detectFishOnReelStart.OnDetect(fish, reelInstance)
    end
end
detectFishOnReelStart.OnDetect = function(fish, reelInstance)
    if not snapReelEnabled then return end
    fishName = fish.Name or "Unknown"
    lowFishName = string.lower(tostring(fishName))
    fishWeight = tonumber(fish.Weight) or 0
    rawMutation = fish.Mutation or fish.Mutant or "Normal"
    lowMutation = string.lower(tostring(rawMutation))
    isShiny = (fish.Shiny == true) or (lowMutation and string.find(lowMutation, "shiny"))
    isSparkling = (fish.Sparkling == true) or (lowMutation and string.find(lowMutation, "sparkling"))
    nameMatch = true
    dropDownActive = next(selectedFish) ~= nil
    inputActive = (inputFishName ~= "" and inputFishName ~= nil)
    if dropDownActive or inputActive then
        nameMatch = false
        if selectedFish["all"] then nameMatch = true end
        if not nameMatch and selectedFish[lowFishName] then nameMatch = true end
        if not nameMatch and inputActive and string.find(lowFishName, string.lower(tostring(inputFishName))) then nameMatch = true end
    end
    rarityMatch = true
    if rarityFilterAktif then
        rarityMatch = false
        currentRarity = "unknown"
        if fish.Rarity then
            currentRarity = string.lower(tostring(fish.Rarity))
        elseif library and library.fish and library.fish[fishName] and library.fish[fishName].Rarity then
            currentRarity = string.lower(tostring(library.fish[fishName].Rarity))
        end
        if targetRarityList[currentRarity] == true then rarityMatch = true end
    end
    mutationMatch = true
    if mutationFilterAktif or specialMutationFilterAktif then
        foundMatch = false
        if mutationFilterAktif and targetMutations[lowMutation] then foundMatch = true end
        if not foundMatch and specialMutationFilterAktif and targetSpecialMutations then
            if targetSpecialMutations["shiny"] and isShiny then foundMatch = true end
            if targetSpecialMutations["sparkling"] and isSparkling then foundMatch = true end
        end
        mutationMatch = foundMatch
    end
    weightMatch = true
    if maxWeightInput then
        if fishWeight > maxWeightInput then weightMatch = false end
    end
    if nameMatch and rarityMatch and mutationMatch and weightMatch then
        if _sX and _sX.ReelMode == "Super Fast Reel" then
            _G.FastReelEnabled = true
            if _sX then _sX.instaReelEnabled = true _sX.autoReelEnabled = true end
        else
            _G.FastReelEnabled = false
            if _sX then _sX.instaReelEnabled = false _sX.autoReelEnabled = true end
        end
        if type(reelFinish) == "function" then reelFinish() end
    else
        _G.FastReelEnabled = false
        if type(reelInstance) == "table" then reelInstance._noCustomBar = true end
        if _sX then
            _sX.instaReelEnabled = false
            _sX.autoReelEnabled = false
        end
        finishing = false
        if ReelController then
            ReelController.ActiveReel = nil
        end
    end
end
ReplicatedStorage = game:GetService("ReplicatedStorage")
selectedFish = {}
targetMutations = {}
targetSpecialMutations = {}
targetRarityList = {}
inputFishName = nil
maxWeightInput = nil
mutationFilterAktif = false
specialMutationFilterAktif = false
rarityFilterAktif = false
snapReelEnabled = false
showNotification = false
namefish = {"All"}
mutationList = {"None"}
rarityList = {"All"}
pcall(function()
    library = require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("modules"):WaitForChild("library"))
    if library and library.fish then
        tempFish = {}
        for fishName, _ in pairs(library.fish) do
            table.insert(tempFish, fishName)
        end
        table.sort(tempFish)
        for _, fishName in ipairs(tempFish) do
            table.insert(namefish, fishName)
        end
    end
end)
pcall(function()
    mutationModule = require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("modules"):WaitForChild("fishing"):WaitForChild("mutations"))
    if mutationModule and mutationModule.Mutations then
        for mutName, _ in pairs(mutationModule.Mutations) do
            table.insert(mutationList, mutName)
        end
    end
end)
table.sort(mutationList, function(a, b)
    if a == "None" then return true
    elseif b == "None" then return false end
    return a < b
end)
pcall(function()
    rarityModule = require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("modules"):WaitForChild("library"):WaitForChild("rarities"))
    if rarityModule and rarityModule.Rarities then
        tempRarities = {}
        for _, rarityData in pairs(rarityModule.Rarities) do
            if rarityData.Name then table.insert(tempRarities, rarityData) end
        end
        table.sort(tempRarities, function(a, b)
            return (a.Order or 0) < (b.Order or 0)
        end)
        for _, rarityData in ipairs(tempRarities) do
            table.insert(rarityList, rarityData.Name)
        end
    end
end)
if #rarityList <= 1 then
    rarityList = {"All", "Trash", "Common", "Uncommon", "Unusual", "Rare", "Legendary", "Mythical", "Exotic", "Secret", "Limited", "Relic", "Fragment", "Seed", "Gemstone", "Apex", "Extinct", "Cataclysmic", "Special", "Nuclear", "Unique", "Whistle", "Mirror", "Divine Secret"}
end
spearfishing = workspace:FindFirstChild("Spearfishing Water")
ReplicatedStorage = game:GetService("ReplicatedStorage")
remote = nil
finishEvent = nil
abortEvent = nil
StabController = nil
pcall(function()
    local netPkg = ReplicatedStorage:WaitForChild("packages", 2) and ReplicatedStorage.packages:WaitForChild("Net", 2)
    if netPkg then
        remote = netPkg:FindFirstChild("RF/SpearFishing/Minigame")
        finishEvent = netPkg:FindFirstChild("RE/Stab/Finish")
        abortEvent = netPkg:FindFirstChild("RE/Stab/Abort")
    end
    local legacyCtrl = ReplicatedStorage:WaitForChild("client", 2) and ReplicatedStorage.client:WaitForChild("legacyControllers", 2)
    if legacyCtrl and legacyCtrl:FindFirstChild("StabController") then
        StabController = require(legacyCtrl.StabController)
    end
end)
_G.dupeFischToggle = false
selectedCFrame = nil
spearTargetFish = {}
spearAllowAll = true
spearWeightLimit = nil
spearSpecialMut = {}
spearRegularMut = {}
spearRarityFilter = {}
spearAllowAllRarity = true
namefish = {"All"}
mutationList = {}
rarityList = {"All"}
pcall(function()
    library = require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("modules"):WaitForChild("library"))
    if library then
        if library.fish then
            tempFish = {}
            for fishName, _ in pairs(library.fish) do
                table.insert(tempFish, fishName)
            end
            table.sort(tempFish)
            for _, fishName in ipairs(tempFish) do
                table.insert(namefish, fishName)
            end
        end
        if library.mutations then
            for mutName, _ in pairs(library.mutations) do
                table.insert(mutationList, mutName)
            end
            table.sort(mutationList)
        end
    end
end)
pcall(function()
    rarityModule = require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("modules"):WaitForChild("library"):WaitForChild("rarities"))
    if rarityModule and rarityModule.Rarities then
        tempRarities = {}
        for _, rarityData in pairs(rarityModule.Rarities) do
            if rarityData.Name then
                table.insert(tempRarities, rarityData)
            end
        end
        table.sort(tempRarities, function(a, b)
            return (a.Order or 0) < (b.Order or 0)
        end)
        for _, rarityData in ipairs(tempRarities) do
            table.insert(rarityList, rarityData.Name)
        end
    end
end)
if #rarityList <= 1 then
    rarityList = {"All", "Trash", "Common", "Uncommon", "Unusual", "Rare", "Legendary", "Mythical", "Exotic", "Secret", "Limited", "Relic", "Fragment", "Seed", "Gemstone", "Apex", "Extinct", "Cataclysmic", "Special", "Nuclear", "Unique", "Whistle", "Mirror", "Divine Secret"}
end
locations = {
    ["Lost Jungle"] = CFrame.new(-2775.89648, 465.842285, -2121.5957),
    ["Crowned Ruins"] = CFrame.new(-2775.89648, 465.842285, -2121.5957),
    ["Colapse Ruin"] = CFrame.new(3231.98706, -1144.15808, 1729.02759, -0.996860266, 0, -0.0791813806, 0, 1, 0, 0.0791813806, 0, -0.996860266),
    ["Tidefall"] = CFrame.new(3244.97046, -1117.31738, 914.484131, -0.991850138, 0, 0.127409875, 0, 1, 0, -0.127409875, 0, -0.991850138),
    ["Coral Bastion"] = CFrame.new(2524.48169, -1112.31738, 901.424988, -0.899217129, 0, -0.437502682, 0, 1, 0, 0.437502682, 0, -0.899217129),
}
locationNames = {}
for name, _ in pairs(locations) do
    table.insert(locationNames, name)
end
selectedCFrame = locations["Lost Jungle"]
_G.FishNotifierToggle = false
local RoamingSniper = {}
RoamingSniper.Active = false
RoamingSniper.OriginalCFrame = nil
RoamingSniper.LastCatchTime = tick()
_G.IsSniping = _G.IsSniping or false
_G.SelectedRoamingRarity = _G.SelectedRoamingRarity or {}
function RoamingSniper.Start()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local library = nil
    local StabController = nil
    pcall(function()
        library = require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("modules"):WaitForChild("library"))
    end)
    pcall(function()
        StabController = require(ReplicatedStorage:WaitForChild("client"):WaitForChild("legacyControllers"):WaitForChild("StabController"))
    end)
    RoamingSniper.OriginalCFrame = nil
    RoamingSniper.LastCatchTime = tick()
    task.spawn(function()
        while RoamingSniper.Active do
            local player, character = Players.LocalPlayer, Players.LocalPlayer.Character
            local hrp, humanoid = character and character:FindFirstChild("HumanoidRootPart"), character and character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
                if humanoid:GetState() == Enum.HumanoidStateType.Swimming then
                    humanoid:ChangeState(Enum.HumanoidStateType.Running)
                end
            end
            if hrp and RoamingSniper.OriginalCFrame and not _G.IsSniping then
                if tick() - RoamingSniper.LastCatchTime >= 5 then
                    hrp.CFrame = RoamingSniper.OriginalCFrame
                    RoamingSniper.OriginalCFrame = nil
                    print("[ThanHub Roaming] \226\143\179 5 Detik berlalu. Karakter kembali ke posisi asal.")
                end
            end
            task.wait(0.1)
        end
        local character = Players.LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
        end
    end)
    local function verifyAndSnip(hitbox)
        if not RoamingSniper.Active then return end
        if _G.IsSniping then return end
        if not hitbox or not hitbox:IsA("BasePart") then return end
        local fishName = hitbox:GetAttribute("FishName")
        local uid = hitbox:GetAttribute("UID")
        if not fishName or not uid then return end
        local fishRarity = "Unknown"
        if library and library.fish and library.fish[fishName] then
            fishRarity = library.fish[fishName].Rarity or fishRarity
        end
        local lowRarity, lowFishName, parentRarityName = string.lower(tostring(fishRarity)), string.lower(tostring(fishName)), ""
        if hitbox.Parent and hitbox.Parent.Parent then
            parentRarityName = string.lower(hitbox.Parent.Parent.Name)
        end
        local isTarget = _G.SelectedRoamingRarity["all"]
        or _G.SelectedRoamingRarity[parentRarityName]
        or _G.SelectedRoamingRarity[lowRarity]
        or _G.SelectedRoamingRarity[lowFishName]
        if isTarget and not _G.IsSniping then
            _G.IsSniping = true
            RoamingSniper.LastCatchTime = tick()
            print(string.format("[ThanHub Roaming] \240\159\142\175 TARGET LOCKED: %s [UID: %s]", fishName, tostring(uid)))
            task.spawn(function()
                local localPlayer, character = Players.LocalPlayer, Players.LocalPlayer.Character
                local hrp = character and character:FindFirstChild("HumanoidRootPart")
                if not hrp then _G.IsSniping = false return end
                if not RoamingSniper.OriginalCFrame then
                    RoamingSniper.OriginalCFrame = hrp.CFrame
                end
                local netFolder = ReplicatedStorage:WaitForChild("packages"):WaitForChild("Net")
                local spearMinigame, finishEvent = netFolder:WaitForChild("RF/SpearFishing/Minigame"), netFolder:WaitForChild("RE/Stab/Finish")
                local abortEvent = netFolder:FindFirstChild("RE/Stab/Abort") or netFolder:FindFirstChild("FishingRod/Abort")
                local keepTeleporting = true
                task.spawn(function()
                    repeat
                        if hrp and hitbox and hitbox.Parent then
                            local target = hitbox.CFrame
                            if (hrp.Position - target.Position).Magnitude > 40 then
                                SafeMotion.Teleport(hrp, target)
                            else
                                hrp.CFrame = target
                            end
                        end
                        RunService.Heartbeat:Wait()
                    until not keepTeleporting or not hitbox or not hitbox.Parent
                end)
                task.wait(0.15 + math.random() * 0.1)
                local initSuccess = false
                for i = 1, 3 do
                    local ok = pcall(function()
                        spearMinigame:InvokeServer(uid, nil, true)
                    end)
                    if ok then
                        initSuccess = true
                        break
                    end
                    task.wait(0.12 + math.random() * 0.08)
                end
                if initSuccess then
                    task.wait(0.9 + math.random() * 0.8)
                    local progressValue = math.floor((ReelGate.Progress() * 100) + 0.5)
                    if progressValue >= 99 then progressValue = 100 end
                    local perfectRoll = math.random() > ReelGate.PerfectMissChance
                    pcall(function() finishEvent:FireServer({ e = progressValue, p = perfectRoll, l = {}, d = {} }) end)
                    RunService.Heartbeat:Wait()
                    task.wait(0.05 + math.random() * 0.05)
                    pcall(function() spearMinigame:InvokeServer(uid, nil, true) end)
                end
                local waitStart = tick()
                while hitbox and hitbox.Parent and (tick() - waitStart < 1.5) do
                    task.wait(0.1)
                end
                keepTeleporting = false
                RunService.Heartbeat:Wait()
                task.wait(0.02)
                task.wait(0.1)
                pcall(function()
                    if abortEvent then abortEvent:FireServer(uid) end
                    if StabController then
                        if StabController.ActiveReel then pcall(function() StabController.ActiveReel:Destroy() end) StabController.ActiveReel = nil end
                        if StabController.Aborted then StabController.Aborted[uid] = true end
                    end
                    local clientReel = localPlayer.PlayerGui:FindFirstChild("reel")
                    if clientReel then clientReel:Destroy() end
                    if character then character:SetAttribute("ReelActive", nil) character:SetAttribute("Reeling", nil) end
                    local hud = localPlayer.PlayerGui:FindFirstChild("hud")
                    local backpack = localPlayer.PlayerGui:FindFirstChild("backpack")
                    if hud then hud.Enabled = true if hud:FindFirstChild("deviceinset") then hud.deviceinset.Enabled = true end end
                    if backpack then backpack.Enabled = true end
                end)
                task.wait(0.1)
                RoamingSniper.LastCatchTime = tick()
                _G.IsSniping = false
            end)
        end
    end
    task.spawn(function()
        local roamingFolder = workspace:WaitForChild("active"):WaitForChild("roamingFish")
        while RoamingSniper.Active do
            if not _G.IsSniping then
                for _, obj in ipairs(roamingFolder:GetDescendants()) do
                    if not RoamingSniper.Active or _G.IsSniping then break end
                    if obj:IsA("BasePart") and obj:GetAttribute("UID") and obj:GetAttribute("FishName") then
                        verifyAndSnip(obj)
                    end
                end
            end
            task.wait(0.2)
        end
    end)
end
function RoamingSniper.Stop()
    RoamingSniper.Active = false
    _G.IsSniping = false
end
local roamingFolder = (workspace:FindFirstChild("active") and workspace.active:FindFirstChild("roamingFish")) or workspace:FindFirstChild("roamingFish")
local roamingRarityOptions = {}
if roamingFolder then
    for _, rarityModel in ipairs(roamingFolder:GetChildren()) do
        table.insert(roamingRarityOptions, rarityModel.Name)
    end
end
table.insert(roamingRarityOptions, 1, "All")
local function createRoamFishPanel()
    local existing = (gethui and gethui():FindFirstChild("RoamFishPanel")) or localPlayer.PlayerGui:FindFirstChild("RoamFishPanel")
    if existing then existing:Destroy() end
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RoamFishPanel"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    if syn and syn.protect_gui then
        syn.protect_gui(screenGui)
    elseif protectgui then
        protectgui(screenGui)
    else
        screenGui.Parent = CoreGui
    end
    if screenGui.Parent == nil then
        screenGui.Parent = (gethui and gethui()) or localPlayer.PlayerGui
    end
    KeepScreenGuiEnabled(screenGui)
    local uiScale = Instance.new("UIScale", screenGui)
    local frame = Instance.new("Frame", screenGui)
    frame.Size = UDim2.new(0, 280, 0, 360)
    frame.Position = UDim2.new(0.8, 0, 0.35, 0)
    frame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
    frame.BorderSizePixel = 0
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(0, 229, 255)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.4
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 12)
    local topBar = Instance.new("Frame", frame)
    topBar.Size = UDim2.new(1, 0, 0, 45)
    topBar.BackgroundTransparency = 1
    topBar.Active = true
    local title = Instance.new("TextLabel", topBar)
    title.Size = UDim2.new(1, -20, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.Text = "Active Roaming Fish"
    title.TextColor3 = Color3.fromRGB(240, 245, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 15
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = titles and 1 or 1
    local brandTag = Instance.new("TextLabel", topBar)
    brandTag.Size = UDim2.new(1, -20, 1, 0)
    brandTag.Position = UDim2.new(0, 0, 0, 0)
    brandTag.Text = "ThanHub"
    brandTag.TextColor3 = Color3.fromRGB(0, 229, 255)
    brandTag.Font = Enum.Font.GothamBold
    brandTag.TextSize = 15
    brandTag.TextXAlignment = Enum.TextXAlignment.Right
    brandTag.BackgroundTransparency = 1
    local divider = Instance.new("Frame", frame)
    divider.Size = UDim2.new(1, -30, 0, 1)
    divider.Position = UDim2.new(0, 15, 0, 45)
    divider.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    divider.BorderSizePixel = 0
    local scroll = Instance.new("ScrollingFrame", frame)
    scroll.Size = UDim2.new(1, -20, 1, -60)
    scroll.Position = UDim2.new(0, 10, 0, 52)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 229, 255)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local uiList = Instance.new("UIListLayout", scroll)
    uiList.Padding = UDim.new(0, 6)
    uiList.SortOrder = Enum.SortOrder.LayoutOrder
    local dragging, dragInput, dragStart, startPos
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    topBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            TweenService:Create(frame, TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            }):Play()
        end
    end)
    task.spawn(function()
        while screenGui.Parent do
            scroll:ClearAllChildren()
            local listLayout = Instance.new("UIListLayout", scroll)
            listLayout.Padding = UDim.new(0, 6)
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            if roamingFolder then
                for _, rarityModel in ipairs(roamingFolder:GetChildren()) do
                    local fishes = rarityModel:GetChildren()
                    if #fishes > 0 then
                        local fishCounts = {}
                        for _, f in ipairs(fishes) do
                            local name = cleanFishName(f.Name)
                            fishCounts[name] = (fishCounts[name] or 0) + 1
                        end
                        local rLabel = Instance.new("TextLabel", scroll)
                        rLabel.Size = UDim2.new(1, 0, 0, 22)
                        rLabel.Text = "  " .. rarityModel.Name:upper()
                        rLabel.TextColor3 = Color3.fromRGB(0, 229, 255)
                        rLabel.Font = Enum.Font.GothamBold
                        rLabel.TextSize = 12
                        rLabel.TextXAlignment = Enum.TextXAlignment.Left
                        rLabel.BackgroundTransparency = 1
                        for name, count in pairs(fishCounts) do
                            local fLabel = Instance.new("TextLabel", scroll)
                            fLabel.Size = UDim2.new(1, 0, 0, 18)
                            local display = (count > 1) and (name .. " (" .. count .. ")") or name
                            fLabel.Text = "    > " .. display
                            fLabel.TextColor3 = Color3.fromRGB(180, 190, 210)
                            fLabel.Font = Enum.Font.Code
                            fLabel.TextSize = 12
                            fLabel.TextXAlignment = Enum.TextXAlignment.Left
                            fLabel.BackgroundTransparency = 1
                        end
                    end
                end
            end
            task.wait(2)
        end
    end)
end
local isFrozen1 = false
local Area = {
    { NAME = "None", CFrame = nil },
    {
        NAME = "Forsaken Veil",
        CFrame = CFrame.new(-2418.1167, -11223.5098, 7033.7627),
    },
    {
        NAME = "Antlean Storm",
        CFrame = CFrame.new(-3665.85889, 141.195038, 738.876343),
    },
    {
        NAME = "Podium 3",
        CFrame = CFrame.new(
            -13589.2578,
            -11050.2227,
            71.2485275,
            -0.0684822872,
            8.76760069e-08,
            0.997652352,
            5.31155342e-09,
            1,
            -8.75177264e-08,
            -0.997652352,
            -6.94330093e-10,
            -0.0684822872
        ),
    },
}
previousLocation = nil
teleportSpots = { "None" }
teleportData = {}
local ZoneResolver = {}
_G.LiyZoneResolver = ZoneResolver
ZoneResolver.KNOWN = {
    ["Moosewood"] = CFrame.new(482.25, 164.67, 385.08),
    ["Moosewood Ocean"] = CFrame.new(489.38, 100, 178.49),
    ["Moosewood Docks"] = CFrame.new(321.80, 111, 261.25),
    ["Moosewood Pond"] = CFrame.new(525.99, 181.37, 285.76),
    ["Moosewood Village"] = CFrame.new(467, 150.93, 257),
    ["Ocean"] = CFrame.new(2092.97, 171.92, 962.88),
    ["Roslit Bay"] = CFrame.new(-1475, 133, 680),
    ["Roslit"] = CFrame.new(-1493.45, 160.93, 593.55),
    ["Roslit Pond"] = CFrame.new(-1807.58, 177.31, 596.82),
    ["Roslit Volcano"] = CFrame.new(-1984.22, 183.21, 278.15),
    ["Terrapin Island"] = CFrame.new(-185, 134, 1940),
    ["Terrapin"] = CFrame.new(152.29, 169.96, 2004.01),
    ["Snowcap Island"] = CFrame.new(2625, 135, 2370),
    ["Snowcap"] = CFrame.new(2815.53, 164.78, 2808.99),
    ["Snowcap Pond"] = CFrame.new(2796.6, 311.05, 2593.23),
    ["Mushgrove Swamp"] = CFrame.new(2450, 131, -730),
    ["Mushgrove"] = CFrame.new(2670.82, 164.73, -716.37),
    ["Forsaken Shores"] = CFrame.new(-2419.74, 161.91, 1440.13),
    ["Forsaken Shores Pond"] = CFrame.new(-2700.93, 195.26, 1748.89),
    ["Sunstone Island"] = CFrame.new(-935, 132, -1125),
    ["Sunstone"] = CFrame.new(-794.91, 151.05, -1334.59),
    ["Vertigo"] = CFrame.new(-161.66, -705.02, 1205.99),
    ["The Depths"] = CFrame.new(990, -710, 1240),
    ["Atlantis"] = CFrame.new(-4319.76, -603.71, 1716.2),
    ["Atlantis Ocean"] = CFrame.new(-4373.66, -573.79, 1855.99),
    ["Ancient Isle"] = CFrame.new(5850, 135, 320),
    ["Ancient Archives"] = CFrame.new(5740, 135, 420),
    ["Grand Reef"] = CFrame.new(-3576.44, 163.5, 541.85),
    ["Kraken Lair"] = CFrame.new(-4292.13, -944.05, 2076.08),
    ["Brine Pool"] = CFrame.new(-1788.16, -114.06, -3385.05),
    ["Desolate Deep"] = CFrame.new(-1575.01, -200.17, -2904.31),
    ["Challenger's Deep"] = CFrame.new(732.13, -3363.06, -1628.91),
    ["Northern Expedition"] = CFrame.new(20000, 133, 5300),
    ["Boreal Pines"] = CFrame.new(21634.3, 161.87, 4130.44),
    ["Cryogenic Canal"] = CFrame.new(20068.4, 539.72, 5421.1),
    ["Frigid Cavern"] = CFrame.new(19890.5, 464.62, 5607.77),
    ["Glacial Grotto"] = CFrame.new(20054.4, 909.54, 5639.11),
    ["Overgrowth Cave"] = CFrame.new(20307, 287.55, 5519.7),
    ["Scoria Reach"] = CFrame.new(-4781, 138, -1378),
    ["Scoria Reach Volcano"] = CFrame.new(-5472.91, 201.31, -1546.8),
    ["Lost Jungle"] = CFrame.new(-2869.57, 165.2, -2181.57),
    ["Toxic Grove"] = CFrame.new(-2674.53, -287.92, -2206.12),
    ["Living Garden"] = CFrame.new(-2385.1, -289.98, -2907.18),
    ["Mariana's Veil"] = CFrame.new(-5692.73, -7309.23, 590.01),
    ["Calm Zone"] = CFrame.new(-4345.04, -11153, 3750.44),
    ["Forsaken Veil"] = CFrame.new(-2383.57, -11193, 6865.13),
    ["Abyssal Zenith"] = CFrame.new(-97, -646.01, 962.99),
    ["Crystal Cove"] = CFrame.new(1375.44, -576.03, 2337.07),
    ["Tidefall"] = CFrame.new(3075.61, -1079.92, 833.18),
    ["Tidefall Castle"] = CFrame.new(4469.46, -1074.65, 924.73),
    ["Coral Bastion"] = CFrame.new(2512.75, -1076.03, 839),
    ["Crowned Ruins"] = CFrame.new(3125.87, -1107.03, 2153.71),
    ["Collapsed Ruins"] = CFrame.new(3141.63, -1068.53, 1644.13),
    ["Sunken Reliquary"] = CFrame.new(2945.73, -1080.02, -189.23),
    ["Keepers Altar"] = CFrame.new(1330.08, -806.82, -122.73),
    ["Enchanted Crevice"] = CFrame.new(774.81, -735.05, -437.26),
    ["Mineshaft"] = CFrame.new(-685.41, -833.97, -110.32),
    ["Luminescent Cavern"] = CFrame.new(-1018.35, -310.09, -4285.75),
    ["Crimson Cavern"] = CFrame.new(-998.65, -335.17, -4886.02),
    ["Cultist Lair"] = CFrame.new(4320.59, -1981.93, -4676.62),
    ["The Sanctum"] = CFrame.new(4413.11, -2679.92, -4672.15),
    ["Passage of Oath"] = CFrame.new(4250.24, -2451.14, -4678.43),
    ["Hall of Whispers"] = CFrame.new(4372.35, -2203.13, -4678.92),
    ["Volcanic Vents"] = CFrame.new(-3136.28, -2010.89, 4056.85),
    ["Zeus Sanctuary"] = CFrame.new(-4298.74, -599.16, 2714.11),
    ["Castaway Cliffs"] = CFrame.new(690, 135, -1693),
    ["Statue of Sovereignty"] = CFrame.new(45, 133, -1010),
    ["The Arch"] = CFrame.new(1000, 125, -1250),
    ["Birch Cay"] = CFrame.new(1740, 145.24, -2419),
    ["Pine Shoals"] = CFrame.new(1165, 80, 480),
    ["Waveborne"] = CFrame.new(360, 90, 780),
    ["Emberreach"] = CFrame.new(2390, 83, -490),
    ["Azure Lagoon"] = CFrame.new(1310, 80, 2113),
    ["The Cursed Shores"] = CFrame.new(-235, 85, 1930),
    ["Isle of New Beginnings"] = CFrame.new(-300, 83, -380),
    ["Lushgrove"] = CFrame.new(1133, 105, -560),
    ["Deep Ocean"] = CFrame.new(7665.12, 161.7, 552.53),
    ["Haddock Rock"] = CFrame.new(-551.18, 154.48, -464.37),
    ["Netter's Haven"] = CFrame.new(-640, 85, 1030),
    ["Trade Plaza"] = CFrame.new(535, 82, 775),
    ["DuneHaven"] = CFrame.new(-6544.15, 233.97, -1835.28),
    ["Drylands"] = CFrame.new(-6305.26, 584.77, -1201.91),
    ["Snowburrow"] = CFrame.new(2759.4, 122.07, 2612.16),
}
local function groundRaycastCFrame(pos, character)
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    rp.FilterDescendantsInstances = { character }
    rp.IgnoreWater = false
    local hit = Workspace:Raycast(Vector3.new(pos.X, pos.Y + 500, pos.Z), Vector3.new(0, -1000, 0), rp)
    if hit then
        return CFrame.new(pos.X, hit.Position.Y + 4, pos.Z)
    end
    return CFrame.new(pos.X, pos.Y + 4, pos.Z)
end
function ZoneResolver.ResolveCFrame(zoneName, character)
    if not zoneName or zoneName == "None" then return nil end
    if ZoneResolver.KNOWN[zoneName] then
        return groundRaycastCFrame(ZoneResolver.KNOWN[zoneName].Position, character)
    end
    local lower = zoneName:lower()
    for kName, kCF in pairs(ZoneResolver.KNOWN) do
        local kl = kName:lower()
        if kl == lower or kl:find(lower, 1, true) or lower:find(kl, 1, true) then
            return groundRaycastCFrame(kCF.Position, character)
        end
    end
    local zones = Workspace:FindFirstChild("zones")
    local fishing = zones and zones:FindFirstChild("fishing")
    if fishing then
        local part = fishing:FindFirstChild(zoneName)
        if part and part:IsA("BasePart") then
            return groundRaycastCFrame(part.Position, character)
        end
    end
    return nil
end
function ZoneResolver.ZoneList()
    local seen, list = {}, {}
    for name in pairs(ZoneResolver.KNOWN) do
        if not seen[name] then seen[name] = true; table.insert(list, name) end
    end
    local zones = Workspace:FindFirstChild("zones")
    local fishing = zones and zones:FindFirstChild("fishing")
    if fishing then
        for _, p in ipairs(fishing:GetChildren()) do
            if p:IsA("BasePart") and not seen[p.Name] then
                seen[p.Name] = true; table.insert(list, p.Name)
            end
        end
    end
    table.sort(list, function(a, b) return a:lower() < b:lower() end)
    table.insert(list, 1, "None")
    return list
end
local function getTpSpots()
    world = Workspace:WaitForChild("world", 5)
    spawns = world and world:WaitForChild("spawns", 5)
    TpSpotsFolder = spawns and spawns:WaitForChild("TpSpots", 5)
    if not TpSpotsFolder then
        return { "None" }
    end
    local spots = {}
    local children = TpSpotsFolder:GetChildren()
    for _, spot in pairs(children) do
        if spot:IsA("Part") or spot:IsA("CFrameValue") then
            table.insert(spots, spot.Name)
            if spot:IsA("Part") then
                teleportData[spot.Name] = spot.CFrame
            elseif spot:IsA("CFrameValue") then
                teleportData[spot.Name] = spot.Value
            end
        end
    end
    table.sort(spots)
    table.insert(spots, 1, "None")
    return spots
end
local function teleportTo(areaName)
    local Character = LocalPlayer.Character
    if not Character then
        return
    end
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    if not HumanoidRootPart then
        return
    end
    if areaName == "None" and previousLocation then
        SafeMotion.Teleport(HumanoidRootPart, previousLocation)
        return
    end
    local targetCFrame = teleportData[areaName]
    if targetCFrame then
        previousLocation = HumanoidRootPart.CFrame
        SafeMotion.Teleport(HumanoidRootPart, targetCFrame)
    end
end
RunService = game:GetService("RunService")
local function FreezeCharacter1(state)
    SafeMotion.FreezeOnBoat(state, function() return isFrozen1 end, function(v) isFrozen1 = v end)
end
local function getFishingZones()
    local zones = Workspace:WaitForChild("zones", 5)
    local FishingZonesFolder = zones and zones:WaitForChild("fishing", 5)
    if not FishingZonesFolder then
        return { "None" }
    end
    local spots = {}
    local zonesData = {}
    local children = FishingZonesFolder:GetChildren()
    for _, spot in pairs(children) do
        if spot:IsA("Part") then
            if not zonesData[spot.Name] then
                zonesData[spot.Name] = {}
                table.insert(spots, spot.Name)
            end
            table.insert(zonesData[spot.Name], spot)
        end
    end
    table.sort(spots)
    table.insert(spots, 1, "None")
    local sortedZonesData = {}
    for _, name in ipairs(spots) do
        if zonesData[name] then
            sortedZonesData[name] = zonesData[name]
        end
    end
    return spots, sortedZonesData
end
local function teleportToFishingZone(zoneName)
    local Character = LocalPlayer.Character
    if not Character then
        return
    end
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    if not HumanoidRootPart then
        return
    end
    local zones = Workspace:WaitForChild("zones", 1)
    local FishingZonesFolder = zones and zones:WaitForChild("fishing", 1)
    if not FishingZonesFolder then
        return
    end
    if zoneName == "None" and previousLocation then
        HumanoidRootPart.CFrame = previousLocation
        FreezeCharacter1(false)
        return
    end
    local _, zonesData = getFishingZones()
    if zoneName ~= "Crystal Cove" and (not zonesData[zoneName] or #zonesData[zoneName] == 0) then
        local resolver = _G.LiyZoneResolver
        local target = resolver and resolver.ResolveCFrame(zoneName, Character)
        if target then
            previousLocation = HumanoidRootPart.CFrame
            SafeMotion.Teleport(HumanoidRootPart, target + Vector3.new(0, _sX.floatHeight or 0, 0))
            return
        end
    end
    if zoneName == "Crystal Cove" then
        previousLocation = HumanoidRootPart.CFrame
        local player = game.Players.LocalPlayer
        local boat
        repeat
            boat = workspace:FindFirstChild("active")
            and workspace.active:FindFirstChild("boats")
            and workspace.active.boats:FindFirstChild(player.Name)
            and workspace.active.boats[player.Name]:FindFirstChild(
                "Rowboat"
            )
            if not boat then
                local Character = LocalPlayer.Character
                local HumanoidRootPart =
                Character:FindFirstChild("HumanoidRootPart")
                HumanoidRootPart.CFrame = CFrame.new(362, 134, 259)
                task.wait(0.5)
                local args = {
                    {
                        voice = 8,
                        idle = workspace
                        :WaitForChild("world")
                        :WaitForChild("npcs")
                        :WaitForChild("Moosewood Shipwright")
                        :WaitForChild("description")
                        :WaitForChild("idle"),
                        npc = workspace
                        :WaitForChild("world")
                        :WaitForChild("npcs")
                        :WaitForChild("Moosewood Shipwright"),
                    },
                }
                workspace
                :WaitForChild("world")
                :WaitForChild("npcs")
                :WaitForChild("Moosewood Shipwright")
                :WaitForChild("shipwright")
                :WaitForChild("giveUI")
                :InvokeServer(unpack(args))
                task.wait(0.2)
                local args = {
                    "Rowboat",
                }
                game:GetService("ReplicatedStorage")
                :WaitForChild("packages")
                :WaitForChild("Net")
                :WaitForChild("RF/Boats/Purchase")
                :InvokeServer(unpack(args))
                task.wait(0.5)
                local args = {
                    "Rowboat",
                }
                game:GetService("ReplicatedStorage")
                :WaitForChild("packages")
                :WaitForChild("Net")
                :WaitForChild("RF/Boats/Spawn")
                :InvokeServer(unpack(args))
                task.wait(0.3)
                game:GetService("ReplicatedStorage")
                :WaitForChild("packages")
                :WaitForChild("Net")
                :WaitForChild("RE/Boats/Close")
                :FireServer()
                task.wait(0.5)
                autoEquipRod()
                local player = game:GetService("Players").LocalPlayer
                local gui = player
                :WaitForChild("PlayerGui")
                :WaitForChild("hud")
                :WaitForChild("safezone")
                :WaitForChild("shipwright")
                gui.Visible = false
            end
        until boat
        for _, descendant in ipairs(boat:GetDescendants()) do
            local name = descendant.Name:lower()
            if name == "sitprompt" or name == "body" then
                descendant:Destroy()
            end
        end
        local customPos = Vector3.new(1375.483887, -603.664612, 2340.227783)
        targetCf = CFrame.new(customPos + Vector3.new(0, _sX.floatHeight, 0))
        boat:PivotTo(targetCf)
        task.wait(0.5)
        FreezeCharacter1(true)
        return
    end
    local targetParts = zonesData[zoneName]
    if targetParts and #targetParts > 0 then
        local foundValidPos = false
        local finalCFrame = nil
        for i = 1, 10 do
            local randomPart = targetParts[math.random(#targetParts)]
            local size = randomPart.Size
            local cf = randomPart.CFrame
            local randomOffset = Vector3.new(
                math.random() * size.X - size.X / 2,
                0,
                math.random() * size.Z - size.Z / 2
            )
            local testPos = (cf * CFrame.new(randomOffset)).Position
            local rayOrigin = Vector3.new(testPos.X, testPos.Y + 1000, testPos.Z)
            local rayParams = RaycastParams.new()
            rayParams.FilterType = Enum.RaycastFilterType.Exclude
            rayParams.FilterDescendantsInstances = { Character, boat }
            rayParams.IgnoreWater = false
            local rayResult = workspace:Raycast(rayOrigin, Vector3.new(0, -2000, 0), rayParams)
            if rayResult then
                if rayResult.Material == Enum.Material.Water then
                    local currentY = rayResult.Position.Y
                    local heightOffset = (zoneName == "Forsaken Veil") and 80 or (_sX.floatHeight or 0)
                    finalCFrame = CFrame.new(testPos.X, currentY + heightOffset, testPos.Z)
                    foundValidPos = true
                    break
                end
            end
        end
        if not foundValidPos then
            local randomPart = targetParts[math.random(#targetParts)]
            local cf = randomPart.CFrame
            local rayParams = RaycastParams.new()
            rayParams.FilterType = Enum.RaycastFilterType.Whitelist
            rayParams.FilterDescendantsInstances = { workspace.Terrain }
            rayParams.IgnoreWater = false
            local currentY = cf.Y
            local rayResult = workspace:Raycast(Vector3.new(cf.X, 1000, cf.Z), Vector3.new(0, -2000, 0), rayParams)
            if rayResult and rayResult.Material == Enum.Material.Water then
                currentY = rayResult.Position.Y
            end
            local heightOffset = (zoneName == "Forsaken Veil") and 80 or (_sX.floatHeight or 0)
            finalCFrame = CFrame.new(cf.X, currentY + heightOffset, cf.Z)
        end
        previousLocation = HumanoidRootPart.CFrame
        local player = game.Players.LocalPlayer
        local boat
        repeat
            boat = workspace:FindFirstChild("active")
            and workspace.active:FindFirstChild("boats")
            and workspace.active.boats:FindFirstChild(player.Name)
            and workspace.active.boats[player.Name]:FindFirstChild(
                "Rowboat"
            )
            if not boat then
                local Character = LocalPlayer.Character
                local HumanoidRootPart =
                Character:FindFirstChild("HumanoidRootPart")
                HumanoidRootPart.CFrame = CFrame.new(362, 134, 259)
                task.wait(0.5)
                local args = {
                    {
                        voice = 8,
                        idle = workspace
                        :WaitForChild("world")
                        :WaitForChild("npcs")
                        :WaitForChild("Moosewood Shipwright")
                        :WaitForChild("description")
                        :WaitForChild("idle"),
                        npc = workspace
                        :WaitForChild("world")
                        :WaitForChild("npcs")
                        :WaitForChild("Moosewood Shipwright"),
                    },
                }
                workspace
                :WaitForChild("world")
                :WaitForChild("npcs")
                :WaitForChild("Moosewood Shipwright")
                :WaitForChild("shipwright")
                :WaitForChild("giveUI")
                :InvokeServer(unpack(args))
                task.wait(0.2)
                local args = {
                    "Rowboat",
                }
                game:GetService("ReplicatedStorage")
                :WaitForChild("packages")
                :WaitForChild("Net")
                :WaitForChild("RF/Boats/Purchase")
                :InvokeServer(unpack(args))
                task.wait(0.5)
                local args = {
                    "Rowboat",
                }
                game:GetService("ReplicatedStorage")
                :WaitForChild("packages")
                :WaitForChild("Net")
                :WaitForChild("RF/Boats/Spawn")
                :InvokeServer(unpack(args))
                task.wait(0.3)
                game:GetService("ReplicatedStorage")
                :WaitForChild("packages")
                :WaitForChild("Net")
                :WaitForChild("RE/Boats/Close")
                :FireServer()
                task.wait(0.5)
                autoEquipRod()
                local player = game:GetService("Players").LocalPlayer
                local gui = player
                :WaitForChild("PlayerGui")
                :WaitForChild("hud")
                :WaitForChild("safezone")
                :WaitForChild("shipwright")
                gui.Visible = false
            end
        until boat
        for _, descendant in ipairs(boat:GetDescendants()) do
            local name = descendant.Name:lower()
            if name == "sitprompt" or name == "body" then
                descendant:Destroy()
            end
        end
        local checkParams = RaycastParams.new()
        checkParams.FilterType = Enum.RaycastFilterType.Whitelist
        checkParams.FilterDescendantsInstances = { workspace.Terrain }
        checkParams.IgnoreWater = false
        local bestY = -10000
        for i=1,3 do
            local finalPos = finalCFrame.Position
            local waterCheck = workspace:Raycast(Vector3.new(finalPos.X, 500, finalPos.Z), Vector3.new(0, -1000, 0), checkParams)
            if waterCheck and waterCheck.Material == Enum.Material.Water then
                if waterCheck.Position.Y > bestY then
                    bestY = waterCheck.Position.Y
                end
            end
            task.wait(0.1)
        end
        if bestY > -5000 then
            finalCFrame = CFrame.new(finalCFrame.X, bestY + 3.5, finalCFrame.Z)
        end
        boat:PivotTo(finalCFrame)
        task.wait(0.5)
        local confirmCheck = workspace:Raycast(Vector3.new(finalCFrame.X, 500, finalCFrame.Z), Vector3.new(0, -1000, 0), checkParams)
        if confirmCheck and confirmCheck.Material == Enum.Material.Water then
            finalCFrame = CFrame.new(finalCFrame.X, confirmCheck.Position.Y + 3.5, finalCFrame.Z)
        end
        task.spawn(function()
            for _=1,20 do
                local currentPos = boat.PrimaryPart.Position
                local check = workspace:Raycast(Vector3.new(currentPos.X, 500, currentPos.Z), Vector3.new(0, -1000, 0), checkParams)
                if check and check.Material == Enum.Material.Water then
                    local waterLevel = check.Position.Y
                    if currentPos.Y < waterLevel then
                        finalCFrame = CFrame.new(currentPos.X, waterLevel + 3.5, currentPos.Z)
                        boat:PivotTo(finalCFrame)
                    elseif (currentPos.Y - waterLevel) > 5 then
                        finalCFrame = CFrame.new(currentPos.X, waterLevel + 3.5, currentPos.Z)
                        boat:PivotTo(finalCFrame)
                    end
                end
                task.wait(0.2)
            end
        end)
        boat:PivotTo(finalCFrame)
        task.wait(0.25)
        boat:PivotTo(finalCFrame)
        task.wait(0.25)
        if zoneName == "Terrapin Island" then
            pcall(function()
                local map = workspace.world.map
                if map and map:FindFirstChild("Terrapin Island") then
                    local children = map["Terrapin Island"]:GetChildren()
                    if children[138] then
                        children[138]:Destroy()
                    end
                end
            end)
        end
        local Character = LocalPlayer.Character
        if Character then
            task.wait(0.3)
            local backpack = LocalPlayer.Backpack
            local rod = nil
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:IsA("Tool") and (tool.Name:find("Rod") or tool.Name:find("Fishing")) then
                    rod = tool
                    break
                end
            end
            if rod then
                Character.Humanoid:EquipTool(rod)
            end
        end
        FreezeCharacter1(true)
    else
        warn("[ERROR] Zona memancing tidak ditemukan!")
    end
end
if game:GetService("UserInputService").TouchEnabled then
end
pcall(function()
    data = loadstring(game:HttpGet("https://you.whimper.xyz/sources/lunor/data.lua"))()
end)
data = data or {}
local BoatSettings = {
    ["Max Speed"] = 0,
    ["Turning Speed"] = 0,
    ["Acceleration"] = 0,
}
pcall(function()
    RodModule = require(game:GetService("ReplicatedStorage"):WaitForChild("shared", 2):WaitForChild("modules", 2):WaitForChild("library", 2):WaitForChild("rods", 2))
end)
RodModule = RodModule or RodsRaw or {}
function buildLocationMap()
    local map = {}
    local zones = Workspace:FindFirstChild("zones") or Workspace:WaitForChild("zones", 2)
    if not zones then return map end
    local foldersToScan = {}
    local f1 = zones:FindFirstChild("fishing") or zones:WaitForChild("fishing", 2)
    local f2 = zones:FindFirstChild("player") or zones:WaitForChild("player", 2)
    if f1 then table.insert(foldersToScan, f1) end
    if f2 then table.insert(foldersToScan, f2) end
    for _, folder in ipairs(foldersToScan) do
        for _, part in ipairs(folder:GetChildren()) do
            if part:IsA("BasePart") then
                map[part.Name] = part
            end
        end
    end
    return map
end
LocationMap = buildLocationMap()
selectedBait = nil
baitBuyAmount = 1
selectedMerlinItem = "Enchant Relic"
local buyAmount = 1
local function getBlackMarketGui()
    local hud = PlayerGui:FindFirstChild("hud")
    local safezone = hud and hud:FindFirstChild("safezone")
    return safezone and safezone:FindFirstChild("BlackMarket")
end
BlackMarketGui = getBlackMarketGui()
ListFrame = BlackMarketGui and BlackMarketGui:FindFirstChild("List")
local function getBMPurchaseRemote()
    local netPkg = ReplicatedStorage:FindFirstChild("packages") and ReplicatedStorage.packages:FindFirstChild("Net")
    return netPkg and netPkg:FindFirstChild("RE/BlackMarket/Purchase")
end
PurchaseRemote = getBMPurchaseRemote()
AutoBM = {
    Enabled = false,
    TargetItems = {},
    Items = {},
    ItemIDs = {},
}
function RefreshItemList()
    AutoBM.Items = {}
    AutoBM.ItemIDs = {}
    BlackMarketGui = getBlackMarketGui()
    ListFrame = BlackMarketGui and BlackMarketGui:FindFirstChild("List")
    if not ListFrame then
        table.insert(AutoBM.Items, "No items found")
        if AutoBM.DropdownUI then AutoBM.DropdownUI:Refresh(AutoBM.Items) end
        return
    end
    for _, child in ipairs(ListFrame:GetChildren()) do
        if child:IsA("Frame") and child:FindFirstChild("ItemPreview") then
            titleLabel = child.ItemPreview:FindFirstChild("ItemHeader")
            and child.ItemPreview.ItemHeader:FindFirstChild("ItemTitle")
            if titleLabel then
                displayName = titleLabel.Text
                table.insert(AutoBM.Items, displayName)
                AutoBM.ItemIDs[displayName] = child.Name
            end
        end
    end
    if #AutoBM.Items == 0 then
        table.insert(AutoBM.Items, "No items found")
    end
    if AutoBM.DropdownUI then
        AutoBM.DropdownUI:Refresh(AutoBM.Items)
    end
end
local function getDailyShopGui()
    local hud = PlayerGui:FindFirstChild("hud")
    local safezone = hud and hud:FindFirstChild("safezone")
    return safezone and safezone:FindFirstChild("DailyShop")
end
DailyShopGui = getDailyShopGui()
DailyListFrame = DailyShopGui and DailyShopGui:FindFirstChild("List")
local function getDailyPurchaseRemote()
    local netPkg = ReplicatedStorage:FindFirstChild("packages") and ReplicatedStorage.packages:FindFirstChild("Net")
    return netPkg and netPkg:FindFirstChild("RE/DailyShop/Purchase")
end
DailyPurchaseRemote = getDailyPurchaseRemote()
AutoDaily = {
    Enabled = false,
    TargetItems = {},
    Items = {},
    ItemIDs = {},
}
function RefreshDailyList()
    AutoDaily.Items = {}
    AutoDaily.ItemIDs = {}
    DailyShopGui = getDailyShopGui()
    DailyListFrame = DailyShopGui and DailyShopGui:FindFirstChild("List")
    if not DailyListFrame then
        table.insert(AutoDaily.Items, "No items available")
        if AutoDaily.DropdownUI then AutoDaily.DropdownUI:Refresh(AutoDaily.Items) end
        return
    end
    for _, child in ipairs(DailyListFrame:GetChildren()) do
        if child:IsA("Frame") then
            label = child:FindFirstChild("Label")
            soldOutFrame = child:FindFirstChild("SoldOut")
            if label and label:IsA("TextLabel") then
                itemName = label.Text
                isSoldOut = soldOutFrame and soldOutFrame.Visible
                if not isSoldOut then
                    if not AutoDaily.ItemIDs[itemName] then
                        AutoDaily.ItemIDs[itemName] = {}
                        table.insert(AutoDaily.Items, itemName)
                    end
                    table.insert(AutoDaily.ItemIDs[itemName], child.Name)
                end
            end
        end
    end
    if #AutoDaily.Items == 0 then
        table.insert(AutoDaily.Items, "No items available")
    end
    if AutoDaily.DropdownUI then
        AutoDaily.DropdownUI:Refresh(AutoDaily.Items)
    end
end
task.defer(RefreshItemList)
task.defer(RefreshDailyList)
local Net = nil
pcall(function()
    Net = require(ReplicatedStorage.packages.Net)
end)
local Controller = nil
pcall(function()
    Controller = require(ReplicatedStorage.client.legacyControllers.Fischfest26Controller.Controllers.Minigames.BeachVolleyballController)
end)
Controller = Controller or {}
local config = {
    TargetScore = 10,
    UseTargetScore = false,
    FarmMode = "Win",
    AutoSide1 = false,
    AutoSide2 = false,
    AutoTakeQuest = false,
    QuestMode = "NPC",
    QuestDifficulty = "Easy",
}
local function JoinSide(sideIndex)
    if not Net or type(Controller.GetActiveCourt) ~= "function" then return end
    local okRemote, JoinRemote = pcall(function() return Net:RemoteEvent("BeachVolleyball/Join") end)
    if not okRemote or not JoinRemote then return end
    local court = Controller.GetActiveCourt()
    if court then
        JoinRemote:FireServer(court, sideIndex)
    end
end
local oldScoreFunction = Controller.UpdateScore
if type(oldScoreFunction) == "function" then
    Controller.UpdateScore = function(court, score, ...)
        if config.UseTargetScore and score >= config.TargetScore and config.FarmMode == "Lose" and type(Controller.Leave) == "function" then
            Controller.Leave()
        end
        return oldScoreFunction(court, score, ...)
    end
end
task.spawn(function()
    while true do
        task.wait(2)
        if (config.AutoSide1 or config.AutoSide2) and type(Controller.GetActiveCourt) == "function" then
            local court = Controller.GetActiveCourt()
            if court then
                if config.AutoSide1 then JoinSide(1) end
                if config.AutoSide2 then JoinSide(2) end
            end
        end
    end
end)
SandcastleController = nil
pcall(function()
    SandcastleController = require(game:GetService("ReplicatedStorage").client.legacyControllers.Fischfest26Controller.Controllers.Minigames.SandcastleBuildingController)
end)
SandcastleController = SandcastleController or {}
SharedSandcastle = SandcastleController.l__SharedSandcastle__16
PlacePartEvent = SandcastleController.u3
SuccessColor = SandcastleController.u15
TargetModel = SandcastleController.u31
DialogInteract = nil
pcall(function()
    local netPkg = game:GetService("ReplicatedStorage"):WaitForChild("packages", 2) and game:GetService("ReplicatedStorage").packages:WaitForChild("Net", 2)
    DialogInteract = netPkg and netPkg:FindFirstChild("RF/DialogInteract")
end)
local function _liyhubJitter(min, max)
    return min + math.random() * (max - min)
end
local function _liyhubHumanPromptHold(prompt)
    if not prompt then return end
    local oldHold = prompt.HoldDuration
    local humanHold = _liyhubJitter(0.22, 0.48)
    prompt.HoldDuration = 0
    pcall(function()
        prompt:InputHoldBegin()
        task.wait(humanHold)
        prompt:InputHoldEnd()
    end)
    prompt.HoldDuration = oldHold
end
getgenv().LiyhubQuestKit = getgenv().LiyhubQuestKit or {}
local QuestKit = getgenv().LiyhubQuestKit
QuestKit.Jitter = _liyhubJitter
QuestKit.HumanPromptHold = _liyhubHumanPromptHold
function QuestKit.GetDialogChoices()
    local playerGui = game:GetService("Players").LocalPlayer and game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return {} end
    local roots = {}
    local opts = playerGui:FindFirstChild("options")
    if opts then table.insert(roots, opts) end
    local hud = playerGui:FindFirstChild("hud")
    local safezone = hud and hud:FindFirstChild("safezone")
    local sOpts = safezone and safezone:FindFirstChild("options")
    if sOpts then table.insert(roots, sOpts) end
    local choices = {}
    for _, root in ipairs(roots) do
        local ok, descendants = pcall(function() return root:GetDescendants() end)
        if ok and type(descendants) == "table" then
            for _, option in ipairs(descendants) do
                local index = tonumber(option.Name:match("^(%d+)option$"))
                if index then
                    local button = option:IsA("GuiButton") and option or option:FindFirstChild("button")
                    local label = option:FindFirstChild("text") or option
                    local text = (label:IsA("TextLabel") or label:IsA("TextButton")) and label.Text or ""
                    if button and button:IsA("GuiButton") then
                        table.insert(choices, { Index = index, Button = button, Text = text:lower():gsub("<[^>]+>", "") })
                    end
                end
            end
        end
    end
    table.sort(choices, function(a, b) return a.Index < b.Index end)
    return choices
end
function QuestKit.WaitDialogOptions(timeout)
    local deadline = os.clock() + (timeout or 3.5)
    repeat
        local choices = QuestKit.GetDialogChoices()
        if #choices > 0 then return choices end
        task.wait(0.18)
    until os.clock() > deadline
    return {}
end
function QuestKit.PickChoiceMatching(choices, keywords)
    if type(choices) ~= "table" or #choices == 0 then return nil end
    for _, keyword in ipairs(keywords) do
        local kw = string.lower(tostring(keyword))
        for _, choice in ipairs(choices) do
            if type(choice.Text) == "string" and string.find(choice.Text, kw, 1, true) then
                return choice
            end
        end
    end
    return nil
end
function QuestKit.PressChoice(choice)
    if not choice then return false end
    local di = DialogInteract
    if not di then
        local netPkg = ReplicatedStorage:FindFirstChild("packages") and ReplicatedStorage.packages:FindFirstChild("Net")
        di = netPkg and netPkg:FindFirstChild("RF/DialogInteract")
        DialogInteract = di
    end
    if di and choice.Index then
        local ok = pcall(function() di:InvokeServer(3, choice.Index) end)
        if ok then return true end
    end
    return false
end
function QuestKit.ForceLeaveDialog()
    local leaveWords = { "bye", "goodbye", "never mind", "nevermind", "leave", "no thanks", "nothing", "cancel", "back", "exit" }
    for _ = 1, 3 do
        local choices = QuestKit.GetDialogChoices()
        if #choices == 0 then break end
        local picked = QuestKit.PickChoiceMatching(choices, leaveWords) or choices[#choices]
        if picked then QuestKit.PressChoice(picked) end
        task.wait(0.35)
    end
    local playerGui = game:GetService("Players").LocalPlayer and game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        for _, name in ipairs({ "options", "dialog" }) do
            local opt = playerGui:FindFirstChild(name)
            if opt then pcall(function() opt.Enabled = false end) end
        end
    end
end
function QuestKit.IsDialogOpen()
    return #QuestKit.GetDialogChoices() > 0
end
function QuestKit.PressDialogByKeywords(keywords, timeout)
    local choices = QuestKit.WaitDialogOptions(timeout or 3.0)
    if #choices == 0 then return false, "noui" end
    local target = QuestKit.PickChoiceMatching(choices, keywords)
    if not target then return false, "nomatch" end
    local ok = QuestKit.PressChoice(target)
    return ok, ok and "pressed" or "presserror"
end
function QuestKit.FindNearestPrompt(hrpPos, searchRadius, filterPredicate)
    searchRadius = searchRadius or 45
    local best, bestDist = nil, searchRadius
    local scanRoots = {}
    local world = workspace:FindFirstChild("world")
    if world then
        if world:FindFirstChild("npcs") then table.insert(scanRoots, world.npcs) end
        if world:FindFirstChild("quests") then table.insert(scanRoots, world.quests) end
    end
    if #scanRoots == 0 then table.insert(scanRoots, workspace) end
    for _, root in ipairs(scanRoots) do
        local ok, descendants = pcall(function() return root:GetDescendants() end)
        if ok and type(descendants) == "table" then
            for _, v in ipairs(descendants) do
                if v:IsA("ProximityPrompt") and v.Enabled then
                    local parent = v.Parent
                    local pivotPos
                    if parent then
                        if parent:IsA("BasePart") then
                            pivotPos = parent.Position
                        elseif parent:IsA("Model") then
                            local okp, cf = pcall(parent.GetPivot, parent)
                            if okp then pivotPos = cf.Position end
                        end
                    end
                    if pivotPos then
                        local d = (hrpPos - pivotPos).Magnitude
                        if d < bestDist and (not filterPredicate or filterPredicate(v, parent, d)) then
                            bestDist = d
                            best = v
                        end
                    end
                end
            end
        end
    end
    return best, bestDist
end
function QuestKit.EngageNpcPrompt(hrpPos, searchRadius, filterPredicate, promptTimeout)
    promptTimeout = promptTimeout or 3.5
    local deadline = os.clock() + promptTimeout
    local prompt
    repeat
        prompt = QuestKit.FindNearestPrompt(hrpPos, searchRadius, filterPredicate)
        if not prompt then task.wait(0.18) end
    until prompt or os.clock() > deadline
    if not prompt then return false, "noprompt" end
    QuestKit.HumanPromptHold(prompt)
    return true, prompt
end
local _liyhubQuestGate = { Last = 0, MinInterval = 12 }
local function _liyhubFindQuestPrompt(hrpPos, searchRadius)
    searchRadius = searchRadius or 40
    local best, bestDist = nil, searchRadius
    local scanRoots = {}
    local world = workspace:FindFirstChild("world")
    if world then
        if world:FindFirstChild("npcs") then table.insert(scanRoots, world.npcs) end
        if world:FindFirstChild("quests") then table.insert(scanRoots, world.quests) end
    end
    if #scanRoots == 0 then table.insert(scanRoots, workspace) end
    for _, root in ipairs(scanRoots) do
        local ok, descendants = pcall(function() return root:GetDescendants() end)
        if ok and type(descendants) == "table" then
            for _, v in ipairs(descendants) do
                if v:IsA("ProximityPrompt") and v.Enabled then
                    local parent = v.Parent
                    local pivotPos
                    if parent then
                        if parent:IsA("BasePart") then
                            pivotPos = parent.Position
                        elseif parent:IsA("Model") then
                            local okp, cf = pcall(parent.GetPivot, parent)
                            if okp then pivotPos = cf.Position end
                        end
                    end
                    if pivotPos then
                        local d = (hrpPos - pivotPos).Magnitude
                        if d < bestDist then
                            bestDist = d
                            best = v
                        end
                    end
                end
            end
        end
    end
    return best
end
local function _liyhubWaitDialogOptions(timeout)
    local deadline = os.clock() + (timeout or 3.5)
    repeat
        if SafeTotem and SafeTotem.DialogChoices then
            local choices = SafeTotem.DialogChoices()
            if #choices > 0 then return choices end
        end
        task.wait(0.18)
    until os.clock() > deadline
    return {}
end
local function _liyhubPickChoiceMatching(choices, keywords)
    if type(choices) ~= "table" or #choices == 0 then return nil end
    for _, keyword in ipairs(keywords) do
        local kw = string.lower(keyword)
        for _, choice in ipairs(choices) do
            if type(choice.Text) == "string" and string.find(choice.Text, kw, 1, true) then
                return choice
            end
        end
    end
    return nil
end
local function _liyhubForceLeaveDialog()
    if SafeTotem and SafeTotem.LeaveDialog then
        pcall(SafeTotem.LeaveDialog)
    end
    local playerGui = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        for _, name in ipairs({ "options", "dialog" }) do
            local opt = playerGui:FindFirstChild(name)
            if opt then
                pcall(function() opt.Enabled = false end)
            end
        end
    end
end
task.spawn(function()
    while task.wait(_liyhubJitter(1.0, 1.6)) do
        if not config.AutoTakeQuest then
            continue
        end
        if (tick() - _liyhubQuestGate.Last) < _liyhubQuestGate.MinInterval then
            continue
        end
        _liyhubForceLeaveDialog()
        task.wait(_liyhubJitter(0.15, 0.3))
        local hrpLocal = game.Players.LocalPlayer.Character and
        game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrpLocal then continue end
        local questTarget = CFrame.new(-23963.2461, 2592.34839, -4637.29541)
        local sm = getgenv().LiyhubSafeMotion
        if sm and sm.Teleport then
            sm.Teleport(hrpLocal, questTarget)
        else
            hrpLocal.CFrame = questTarget
        end
        task.wait(_liyhubJitter(0.6, 1.1))
        local promptDeadline = os.clock() + 3.5
        local prompt
        repeat
            prompt = _liyhubFindQuestPrompt(hrpLocal.Position, 45)
            if not prompt then task.wait(0.18) end
        until prompt or os.clock() > promptDeadline
        if not prompt then
            _liyhubQuestGate.Last = tick() - _liyhubQuestGate.MinInterval + 3
            task.wait(_liyhubJitter(1.5, 2.5))
            continue
        end
        _liyhubHumanPromptHold(prompt)
        task.wait(_liyhubJitter(0.35, 0.65))
        local diffWords = ({
            Easy = { "easy" },
            Medium = { "medium", "normal" },
            Hard = { "hard", "difficult" },
        })[config.QuestDifficulty] or { "easy" }
        local diffIndex = ({ Easy = 1, Medium = 2, Hard = 3 })[config.QuestDifficulty] or 1
        local modeWords = ({
            Player = { "player", "pvp", "other angler" },
            NPC = { "npc", "computer", "bot" },
        })[config.QuestMode] or { "npc" }
        local modeIndex = ({ Player = 1, NPC = 2 })[config.QuestMode] or 2
        local diffPressed = false
        local choices = _liyhubWaitDialogOptions(3.5)
        if #choices > 0 then
            local target = _liyhubPickChoiceMatching(choices, diffWords)
            if target and SafeTotem and SafeTotem.PressChoice then
                SafeTotem.PressChoice(target)
                diffPressed = true
                task.wait(_liyhubJitter(0.45, 0.8))
            end
        end
        if not diffPressed and DialogInteract then
            pcall(function() DialogInteract:InvokeServer(4, diffIndex) end)
            task.wait(_liyhubJitter(0.35, 0.7))
        end
        local modePressed = false
        local modeChoices = _liyhubWaitDialogOptions(3.0)
        if #modeChoices > 0 then
            local target = _liyhubPickChoiceMatching(modeChoices, modeWords)
            if target and SafeTotem and SafeTotem.PressChoice then
                SafeTotem.PressChoice(target)
                modePressed = true
                task.wait(_liyhubJitter(0.45, 0.8))
            end
        end
        if not modePressed and DialogInteract then
            pcall(function() DialogInteract:InvokeServer(5, modeIndex) end)
            task.wait(_liyhubJitter(0.35, 0.7))
        end
        task.wait(_liyhubJitter(0.6, 1.0))
        _liyhubForceLeaveDialog()
        _liyhubQuestGate.Last = tick()
        task.wait(_liyhubJitter(2.6, 3.9))
    end
end)
local _liyhubCastleGate = { Last = 0, MinInterval = 4 }
task.spawn(function()
    while task.wait(_liyhubJitter(1.1, 1.8)) do
        if not config.AutoFarmQuestCastle then
            continue
        end
        if (tick() - _liyhubCastleGate.Last) < _liyhubCastleGate.MinInterval then
            continue
        end
        if not SharedSandcastle or not TargetModel then
            task.wait(_liyhubJitter(1.5, 2.5))
            continue
        end
        local okTarget, targetModelLocal = pcall(SharedSandcastle.getTargetModel, TargetModel)
        if not okTarget or not targetModelLocal then
            task.wait(_liyhubJitter(1.0, 1.8))
            continue
        end
        if QuestKit and QuestKit.IsDialogOpen and QuestKit.IsDialogOpen() then
            QuestKit.ForceLeaveDialog()
            task.wait(_liyhubJitter(0.3, 0.55))
        end
        local partsToBuild = { "Base", "Wall", "Tower", "Flag", "Decoration" }
        local partsPlaced = 0
        for _, partName in ipairs(partsToBuild) do
            if not config.AutoFarmQuestCastle then break end
            local okTemplate, template = pcall(SharedSandcastle.getPartTemplate, targetModelLocal, partName)
            if okTemplate and template then
                local size = template.Size
                local pos = Vector3.new(0, size.Y / 2, 0)
                local rotY = 0
                local placed = pcall(function()
                    PlacePartEvent:FireServer(partName, pos.X, pos.Y, pos.Z, rotY)
                    if SandcastleController and SandcastleController.u89 then
                        SandcastleController.u89(template, SuccessColor)
                    end
                end)
                if placed then partsPlaced = partsPlaced + 1 end
                task.wait(_liyhubJitter(0.3, 0.72))
            end
        end
        if partsPlaced == 0 then
            _liyhubCastleGate.Last = tick()
            task.wait(_liyhubJitter(2.0, 3.0))
            continue
        end
        task.wait(_liyhubJitter(0.4, 0.9))
        local submitted = false
        if QuestKit and QuestKit.WaitDialogOptions then
            local choices = QuestKit.WaitDialogOptions(2.0)
            if #choices > 0 then
                local submitWords = { "submit", "complete", "finish", "done", "turn in", "yes", "okay" }
                local target = QuestKit.PickChoiceMatching(choices, submitWords)
                if target and QuestKit.PressChoice(target) then
                    submitted = true
                    task.wait(_liyhubJitter(0.5, 0.9))
                end
            end
        end
        if not submitted and DialogInteract then
            pcall(function() DialogInteract:InvokeServer(6, 1) end)
            task.wait(_liyhubJitter(0.5, 0.9))
        end
        if QuestKit and QuestKit.ForceLeaveDialog then
            QuestKit.ForceLeaveDialog()
        end
        _liyhubCastleGate.Last = tick()
        task.wait(_liyhubJitter(5.5, 9.5))
    end
end)
CosmicHop = CosmicHop or {}
do
    local httpRequest = (syn and syn.request) or http_request or request
    local queueTeleport = queue_on_teleport or queueonteleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
    local stateFile = "LiyhubCosmicHop.json"
    local visitedTtl = 1800
    local resumeWindow = 300
    local hopRunning = false
    local claimRunning = false
    local autoClaimEnabled = false
    local teleportFailConnection = nil
    CosmicHop.Enabled = false
    CosmicHop.ScanSeconds = 8
    CosmicHop.MeteorWaitSeconds = 45
    CosmicHop.Status = "Idle"
    local function readState()
        if typeof(isfile) ~= "function" or typeof(readfile) ~= "function" then return {} end
        local ok, decoded = pcall(function()
            if not isfile(stateFile) then return {} end
            return HttpService:JSONDecode(readfile(stateFile))
        end)
        return (ok and type(decoded) == "table") and decoded or {}
    end
    local function writeState(state)
        if typeof(writefile) ~= "function" then return end
        pcall(function()
            writefile(stateFile, HttpService:JSONEncode(state))
        end)
    end
    local function getVisited()
        local state = readState()
        local visited = type(state.visited) == "table" and state.visited or {}
        local now = os.time()
        for jobId, stamp in pairs(visited) do
            if type(stamp) ~= "number" or now - stamp > visitedTtl then
                visited[jobId] = nil
            end
        end
        return visited
    end
    local function saveState(enabled)
        local visited = getVisited()
        visited[game.JobId] = os.time()
        writeState({ enabled = enabled, savedAt = os.time(), visited = visited })
    end
    local function isMeteorActive()
        local world = ReplicatedStorage:FindFirstChild("world")
        local flag = world and world:FindFirstChild("meteor_active")
        return flag ~= nil and flag.Value == true
    end
    function CosmicHop.FindRelic(allowStreaming)
        local craterFound = false
        for _, crater in ipairs(workspace:GetChildren()) do
            if crater.Name == "StarCrater" then
                craterFound = true
                local relic = crater:FindFirstChild("Cosmic Relic")
                local center = relic and relic:FindFirstChild("Center")
                if not center and allowStreaming then
                    pcall(function()
                        LocalPlayer:RequestStreamAroundAsync(crater:GetPivot().Position, 2)
                    end)
                    relic = crater:FindFirstChild("Cosmic Relic")
                    center = relic and relic:FindFirstChild("Center")
                end
                local prompt = center and center:IsA("BasePart") and center:FindFirstChildOfClass("ProximityPrompt")
                if prompt and prompt.Enabled then
                    return center, prompt, true
                end
            end
        end
        return nil, nil, craterFound
    end
    function CosmicHop.GetStatusText()
        local center, _, craterFound = CosmicHop.FindRelic()
        local text = center and "\226\156\133 Ready" or (craterFound and "\226\157\140 Empty" or "\226\157\140 Not Found")
        if isMeteorActive() then
            text = text .. " | \226\152\132\239\184\143 Starfall active"
        end
        if CosmicHop.Enabled then
            text = text .. "\10Hop: " .. CosmicHop.Status
        end
        return text
    end
    function CosmicHop.Claim(center, prompt)
        local character = LocalPlayer.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not root or typeof(fireproximityprompt) ~= "function" then return false end
        root.CFrame = center.CFrame + Vector3.new(0, 3, 0)
        task.wait(0.4)
        local deadline = os.clock() + 10
        while prompt.Parent and prompt.Enabled and os.clock() < deadline do
            if (root.Position - center.Position).Magnitude > 8 then
                root.CFrame = center.CFrame + Vector3.new(0, 3, 0)
            end
            pcall(fireproximityprompt, prompt)
            task.wait(0.2)
        end
        return not (prompt.Parent and prompt.Enabled)
    end
    local function fetchServerPage(cursor)
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&excludeFullGames=true&limit=100"
        if cursor then url = url .. "&cursor=" .. cursor end
        local ok, body = pcall(function()
            if httpRequest then
                local response = httpRequest({ Url = url, Method = "GET" })
                return response and response.Body
            end
            return game:HttpGet(url)
        end)
        if not ok or type(body) ~= "string" then return nil end
        local decoded
        ok, decoded = pcall(HttpService.JSONDecode, HttpService, body)
        return ok and type(decoded) == "table" and decoded or nil
    end
    local function collectCandidates()
        local visited = getVisited()
        local candidates = {}
        local cursor = nil
        for _ = 1, 3 do
            local page = fetchServerPage(cursor)
            if not page or type(page.data) ~= "table" then break end
            for _, server in ipairs(page.data) do
                local playing = tonumber(server.playing) or 0
                local maxPlayers = tonumber(server.maxPlayers) or 0
                if server.id and server.id ~= game.JobId and not visited[server.id] and playing < maxPlayers - 1 then
                    table.insert(candidates, server.id)
                end
            end
            cursor = page.nextPageCursor
            if #candidates >= 25 or not cursor then break end
            task.wait(0.5)
        end
        return candidates
    end
    local resumeQueued = false
    local resumeWarned = false
    local function queueResume()
        if resumeQueued or not queueTeleport then return end
        local genvTable = getgenv()
        local loaderSource = genvTable.LiyhubFischLoaderSource
        local loaderUrl = genvTable.LiyhubFischLoaderUrl
        if type(loaderSource) ~= "string" or loaderSource == "" then
            loaderSource = (type(loaderUrl) == "string" and loaderUrl ~= "") and ("loadstring(game:HttpGet(\"" .. loaderUrl .. "\"))()") or nil
        end
        if not loaderSource then
            if not resumeWarned then
                resumeWarned = true
                pcall(function()
                    Window:Notify({ Title = "Auto Hop Cosmic", Content = "Set getgenv().LiyhubFischLoaderUrl or put the script in autoexec to keep hopping after teleport.", Duration = 5, Type = "Info" })
                end)
            end
            return
        end
        if pcall(queueTeleport, "repeat task.wait() until game:IsLoaded() task.wait(3) " .. loaderSource) then
            resumeQueued = true
        end
    end
    function CosmicHop.Hop()
        local candidates = collectCandidates()
        if #candidates == 0 then
            CosmicHop.Status = "No new servers, retrying"
            return false
        end
        saveState(true)
        queueResume()
        for attempt = 1, math.min(5, #candidates) do
            if not CosmicHop.Enabled then return false end
            local jobId = table.remove(candidates, math.random(1, #candidates))
            CosmicHop.Status = "Teleporting (" .. attempt .. ")"
            pcall(TeleportService.TeleportToPlaceInstance, TeleportService, game.PlaceId, jobId, LocalPlayer)
            task.wait(8)
        end
        return false
    end
    local function waitForServerReady()
        local deadline = os.clock() + 15
        repeat
            task.wait(0.5)
        until (workspace:GetAttribute("ServerReady") == true and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) or os.clock() > deadline
    end
    local function scanCurrentServer()
        local scanDeadline = os.clock() + CosmicHop.ScanSeconds
        local meteorDeadline = os.clock() + CosmicHop.MeteorWaitSeconds
        while CosmicHop.Enabled do
            local center, prompt = CosmicHop.FindRelic(true)
            if center and prompt then
                CosmicHop.Status = "Claiming relic"
                CosmicHop.Claim(center, prompt)
                task.wait(1)
                return
            end
            local now = os.clock()
            local waitingMeteor = isMeteorActive() and now < meteorDeadline
            if now > scanDeadline and not waitingMeteor then return end
            CosmicHop.Status = waitingMeteor and "Starfall active, waiting for crater" or "Scanning server"
            task.wait(0.5)
        end
    end
    local function runHopLoop()
        if hopRunning then return end
        hopRunning = true
        waitForServerReady()
        while CosmicHop.Enabled do
            scanCurrentServer()
            if not CosmicHop.Enabled then break end
            CosmicHop.Status = "Searching new server"
            CosmicHop.Hop()
            task.wait(5)
        end
        CosmicHop.Status = "Idle"
        hopRunning = false
    end
    function CosmicHop.SetEnabled(enabled)
        CosmicHop.Enabled = enabled
        _sX.autoHopCosmic = enabled
        getgenv().autoHopCosmic = enabled
        if not enabled then
            writeState({ enabled = false, savedAt = os.time(), visited = getVisited() })
            if teleportFailConnection then
                teleportFailConnection:Disconnect()
                teleportFailConnection = nil
            end
            return
        end
        saveState(true)
        if not teleportFailConnection then
            teleportFailConnection = TeleportService.TeleportInitFailed:Connect(function(player)
                if player ~= LocalPlayer then return end
                CosmicHop.Status = "Teleport failed, retrying"
            end)
        end
        task.spawn(runHopLoop)
    end
    function CosmicHop.TryResume()
        local state = readState()
        if state.enabled ~= true or type(state.savedAt) ~= "number" then return end
        if os.time() - state.savedAt > resumeWindow then return end
        if CosmicHop.Toggle and CosmicHop.Toggle.Set then
            pcall(CosmicHop.Toggle.Set, CosmicHop.Toggle, true)
        end
        if not CosmicHop.Enabled then
            CosmicHop.SetEnabled(true)
        end
    end
    function CosmicHop.SetAutoClaim(enabled)
        autoClaimEnabled = enabled
        if not enabled or claimRunning then return end
        claimRunning = true
        task.spawn(function()
            while autoClaimEnabled do
                local center, prompt = CosmicHop.FindRelic()
                local character = LocalPlayer.Character
                local root = character and character:FindFirstChild("HumanoidRootPart")
                if center and prompt and root and not CosmicHop.Enabled then
                    local homeCFrame = root.CFrame
                    CosmicHop.Claim(center, prompt)
                    if root.Parent then root.CFrame = homeCFrame end
                end
                task.wait(2)
            end
            claimRunning = false
        end)
    end
    task.spawn(function()
        local lastStatusText = nil
        while true do
            local ok, statusText = pcall(CosmicHop.GetStatusText)
            if ok and statusText ~= lastStatusText and CosmicRelicParagraph and CosmicRelicParagraph.Set then
                lastStatusText = statusText
                pcall(function()
                    CosmicRelicParagraph:Set({ Content = "Cosmic Relic: " .. statusText })
                end)
            end
            task.wait(2)
        end
    end)
end
Player = game.Players.LocalPlayer
HRP = LocalPlayer.Character and (LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:WaitForChild("HumanoidRootPart", 2))
Humanoid = LocalPlayer.Character and (LocalPlayer.Character:FindFirstChild("Humanoid") or LocalPlayer.Character:WaitForChild("Humanoid", 2))
getgenv().AutoTemple = false
function tp(pos)
    task.wait(0.5)
    HRP.CFrame = pos
    task.wait(1)
end
function moveAround()
    for i = 1, 3 do
        randomOffset = Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
        target = HRP.Position + randomOffset
        Humanoid:MoveTo(target)
        task.wait(0.8)
        Humanoid.Jump = true
        task.wait(0.8)
    end
end
function pressPrompt(prompt)
    if fireproximityprompt then
        fireproximityprompt(prompt)
    end
end
function equipTool(name)
    tool = Player.Backpack:FindFirstChild(name)
    if tool then
        tool.Parent = Player.Character
        task.wait(0.5)
    end
end
mainPositions = {
    CFrame.new(-5268.162598, -1759.525146, -10002.656250),
    CFrame.new(-5463.61475, -1754.56091, -9624.52734),
    CFrame.new(-5767.95508, -1762.21753, -10122.4639),
    CFrame.new(-4451.50928, -1643.3689, -10169.3438),
    CFrame.new(-4851.16895, -1749.06104, -9288.80078),
}
proximityPositions = {
    CFrame.new(-5199.372559, -1759.061035, -10401.448242),
    CFrame.new(-5152.508301, -1759.061035, -10420.784180),
    CFrame.new(-5160.103027, -1759.061035, -10450.297852),
    CFrame.new(-5162.923340, -1759.061035, -10395.437500),
    CFrame.new(-5197.993652, -1759.061035, -10449.942383),
}
runes = { "Glyph", "Spike", "Toxic", "Water", "Vine" }
function triggerNearbyPrompts(radius, spamCount)
    radius = radius or 20
    spamCount = spamCount or 10
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and prompt.Enabled then
            parent = prompt.Parent
            while parent and not parent:IsA("BasePart") do
                parent = parent.Parent
            end
            if parent then
                dist = (HRP.Position - parent.Position).Magnitude
                if dist <= radius then
                    for i = 1, spamCount do
                        pressPrompt(prompt)
                        task.wait(0.15)
                    end
                end
            end
        end
    end
end
function startAutoTemple()
    while getgenv().AutoTemple and task.wait(1) do
        for _, cf in ipairs(mainPositions) do
            if not getgenv().AutoTemple then
                break
            end
            tp(cf)
            moveAround()
        end
        for i, cf in ipairs(proximityPositions) do
            if not getgenv().AutoTemple then
                break
            end
            tp(cf)
            task.wait(2)
            triggerNearbyPrompts(20, 10)
        end
        tp(CFrame.new(-5179.719727, -1745.402710, -10407.975586))
        moveAround()
        tp(CFrame.new(-4851.16895, -1749.06104, -9288.80078))
        moveAround()
        for _, runeName in ipairs(runes) do
            if not getgenv().AutoTemple then
                break
            end
            HRP.CFrame = CFrame.new(-5082.307129, -1759.561523, -10156.898438)
            task.wait(2)
            runeModel = workspace:FindFirstChild(runeName)
            if runeModel and runeModel:FindFirstChild("MeshPart") then
                tp(runeModel.MeshPart.CFrame)
                moveAround()
            end
            equipTool(runeName .. " Rune")
            closestDist = math.huge
            for _, obj in ipairs(runeModel:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    part = obj.Parent:IsA("BasePart") and obj.Parent
                    if part then
                        dist = (HRP.Position - part.Position).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closestPrompt = obj
                        end
                    end
                end
            end
            if closestPrompt then
                for i = 1, 10 do
                    pressPrompt(closestPrompt)
                    task.wait(0.15)
                end
            end
            task.wait(2)
        end
    end
end
TELEPORT_OFFSET = Vector3.new(0, 3, 0)
keystonePositions = {
    Vector3.new(6067, 224, 257),
    Vector3.new(-2798, 209, 1546),
    Vector3.new(467.6, 230, -2162.6),
    Vector3.new(2667, 129, -715),
    Vector3.new(54.5, 150, 2031.9),
}
function getHumanoidRootPart()
    char = LocalPlayer.Character
    if char then
        return char:FindFirstChild("HumanoidRootPart")
    end
    return nil
end
function triggerPromptAtMeshPart(meshPart)
    if not meshPart then
        return
    end
    prompt = meshPart:FindFirstChildWhichIsA("ProximityPrompt")
    if not prompt then
        return
    end
    hrp = getHumanoidRootPart()
    if not hrp then
        return
    end
    hrp.CFrame = meshPart.CFrame + TELEPORT_OFFSET
    prompt:InputHoldBegin()
    task.wait(0.5)
    prompt:InputHoldEnd()
end
function getNearestKeystoneModel(position)
    folder = workspace:FindFirstChild("Desolate Deep Keystones")
    if not folder then
        return nil
    end
    shortestDistance = math.huge
    for _, model in ipairs(folder:GetChildren()) do
        if model:IsA("Model") then
            meshPart = model:FindFirstChildWhichIsA("MeshPart", true)
            if meshPart then
                dist = (meshPart.Position - position).Magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    nearestModel = model
                end
            end
        end
    end
    return nearestModel
end
getgenv().AutoKeystone = false
local function getAquaRemote(name)
    local netPkg = ReplicatedStorage:FindFirstChild("packages") and ReplicatedStorage.packages:FindFirstChild("Net")
    return netPkg and netPkg:FindFirstChild(name)
end
buyFoodRemote = getAquaRemote("RE/PersonalAquarium/PurchaseFishFood")
activateFoodRemote = getAquaRemote("RE/PersonalAquarium/ActivateFishFood")
buySlotRemote = getAquaRemote("RE/PersonalAquarium/BuyNextSlot")
_sX.SelectedFood = nil
_sX.AutoBuyFood = false
_sX.AutoActivateFood = false
_sX.AutoBuySlot = false
addFishRemote = getAquaRemote("RE/PersonalAquarium/AddFish")
player = Players.LocalPlayer
backpack = player:FindFirstChild("Backpack") or player:WaitForChild("Backpack", 2)
function getFishTools()
    tools = {}
    for _, tool in ipairs(backpack:GetChildren()) do
        if
        tool:IsA("Tool")
        and tool:FindFirstChild("link")
        and tool.link:IsA("StringValue")
        then
            table.insert(tools, tool.Name)
        end
    end
    return tools
end
targetFav = {}
AutoFavorite = false
updateRemote = ReplicatedStorage:WaitForChild("packages")
:WaitForChild("Net")
:WaitForChild("RE/Settings/Edit")
rarities = {
    "Unusual","Mythical","Special","Limited","Rare","Fragment","Gemstone",
    "Trash","Common","Uncommon","Secret","Extinct","Legendary","Relic",
    "Seed","Apex","Divine Secret","Exotic","Crates"
}
selectedAutoSell = {}
selectedDontSell = {}
SafeTotem = {
    Busy = false,
    DryRun = false,
    AutoRestock = false,
    LastQuestion = "",
    Totems = {
        ["Clearcast Totem"] = { Vector3.new(701, 251, 304) },
        ["Meteor Totem"] = { Vector3.new(-1946, 272, 232) },
        ["Smokescreen Totem"] = { Vector3.new(2791, 137, -629) },
        ["Sundial Totem"] = { Vector3.new(-1149, 134, -1077) },
        ["Tempest Totem"] = { Vector3.new(36, 133, 1946) },
        ["Windset Totem"] = { Vector3.new(2851, 175, 2702) },
        ["Zeus Storm Totem"] = { Vector3.new(-4326, -629, 2686) },
    },
    Rods = {
        ["Abyssal Specter Rod"] = { Vector3.new(-3804, -565, 1870) },
        ["Avalanche Rod"] = { Vector3.new(19771, 413, 5418) },
        ["Blazebringer Rod"] = { Vector3.new(-1967, 179, 274) },
        ["Boreal Rod"] = { Vector3.new(21586, 134, 4153) },
        ["Brine-Infused Rod"] = { Vector3.new(-1730, -104, -3345) },
        ["Carbon Rod"] = { Vector3.new(454, 150, 225) },
        ["Challenger's Rod"] = { Vector3.new(738, -3355, -1529) },
        ["Cinder Block Rod"] = { Vector3.new(-1971, 259, -531) },
        ["Coral Rod"] = { Vector3.new(2472, -1070, 871) },
        ["Crystal Crasher"] = { Vector3.new(1341, -582, 2369) },
        ["Eidolon Rod"] = { Vector3.new(4483, -2716, -4634) },
        ["Fast Rod"] = { Vector3.new(447, 148, 220) },
        ["Firefly Rod"] = { Vector3.new(377, 198, -1774) },
        ["Flimsy Rod"] = { Vector3.new(471, 148, 229) },
        ["Fortune Rod"] = { Vector3.new(-1513, 141, 752) },
        ["Frog Rod"] = { Vector3.new(2542, 127, -761) },
        ["Kraken Rod"] = { Vector3.new(-4415, -995, 2054) },
        ["Lucky Rod"] = { Vector3.new(446, 148, 222) },
        ["Luminescent Oath"] = { Vector3.new(-1132, -326, -4309) },
        ["Nocturnal Rod"] = { Vector3.new(-141, -515, 1139) },
        ["Plastic Rod"] = { Vector3.new(454, 148, 229) },
        ["Poseidon Rod"] = { Vector3.new(-4086, -556, 895) },
        ["Rapid Rod"] = { Vector3.new(-1499, 139, 756) },
        ["Reinforced Rod"] = { Vector3.new(-986, -245, -2689) },
        ["Ruinous Oath"] = { Vector3.new(-1042, -335, -4894) },
        ["Steady Rod"] = { Vector3.new(-1499, 139, 758) },
        ["Tempest Rod"] = { Vector3.new(-4927, -594, 1856) },
        ["Thalassar's Ruin"] = { Vector3.new(2886, -579, 1385) },
        ["Tidebreaker"] = { Vector3.new(-1637, -213, -2847) },
        ["Training Rod"] = { Vector3.new(457, 148, 230) },
        ["Treasure Rod"] = { Vector3.new(8360, 161, -17258) },
        ["Trident Rod"] = { Vector3.new(-1482, -224, -2194) },
        ["Verdant Oath"] = { Vector3.new(-2168, -320, -3047) },
        ["Verdant Shear Rod"] = { Vector3.new(-2856, 254, -2061) },
        ["Zeus Rod"] = { Vector3.new(-4270, -625, 2664) },
        ["Long Rod"] = { Vector3.new(486, 172, 146) },
        ["Mythical Rod"] = { Vector3.new(389.5, 134.2, 305.8) },
        ["Midas Rod"] = { Vector3.new(389.5, 134.2, 305.8) },
        ["Phoenix Rod"] = { Vector3.new(-1930, 165, 310) },
        ["Magnet Rod"] = { Vector3.new(-185, 134, 1940) },
        ["Wildflower Rod"] = { Vector3.new(-185, 134, 1940) },
        ["The Lost Rod"] = { Vector3.new(-935, 132, -1125) },
        ["Great Rod of Oscar"] = { Vector3.new(2625, 135, 2370) },
        ["Scurvy Rod"] = { Vector3.new(-2830, 214, 1510) },
        ["Brick Rod"] = { Vector3.new(-1650, -215, -2850) },
        ["Aurora Rod"] = { Vector3.new(-115, -515, 1070) },
        ["Haunted Rod"] = { Vector3.new(-115, -515, 1070) },
        ["Destiny Rod"] = { Vector3.new(985.2, 142.5, -1220) },
        ["Kings Rod"] = { Vector3.new(1296.06, -802.01, -299.01) },
        ["Depthseeker Rod"] = { Vector3.new(-4319.76, -603.71, 1716.2) },
        ["Champions Rod"] = { Vector3.new(-4350, -603.71, 1730) },
        ["Stone Rod"] = { Vector3.new(5965.37, 258.97, 223.25) },
        ["Relic Rod"] = { Vector3.new(5740, 135, 420) },
        ["Heaven's Rod"] = { Vector3.new(19980, 916, 5384) },
        ["Rod of the Zenith"] = { Vector3.new(-13810, -11541, 106.92) },
        ["Daybreaker Rod"] = { Vector3.new(-5160, 137.99, -1452.02) },
        ["Volcanic Rod"] = { Vector3.new(-3136.28, -2010.89, 4056.85) },
        ["Lucid Rod"] = { Vector3.new(-3163.59, -753.32, 1860.06) },
        ["Rod of the Depths"] = { Vector3.new(732.13, -3363.06, -1628.91) },
    },
    Baits = {
        ["Bait Crate"] = { Vector3.new(372, 136, 281), Vector3.new(-1467, 131, 670), Vector3.new(6078, 193, 255) },
        ["Coral Geode"] = { Vector3.new(2388, -1102, 815), Vector3.new(2495, -1070, 867), Vector3.new(2514, -1105, 764), Vector3.new(-1641, -214, -2845) },
        ["Conception Conch"] = { Vector3.new(-133, -515, 1134), Vector3.new(972, -710, 1297), Vector3.new(-1472, -228, -2226), Vector3.new(20053, 509, 5428) },
        ["Krill"] = { Vector3.new(2712, 158, 2381) },
        ["Whale Bait"] = { Vector3.new(8313, 193, -17127) },
        ["Golden Shrimp Bait"] = { Vector3.new(8316, 193, -17129) },
    },
    Stands = {},
    UnverifiedStands = {
        ["Coral Geode"] = true,
        ["Mythical Rod"] = true,
        ["Midas Rod"] = true,
        ["Phoenix Rod"] = true,
        ["Magnet Rod"] = true,
        ["Wildflower Rod"] = true,
        ["The Lost Rod"] = true,
        ["Great Rod of Oscar"] = true,
        ["Scurvy Rod"] = true,
        ["Brick Rod"] = true,
        ["Aurora Rod"] = true,
        ["Haunted Rod"] = true,
        ["Destiny Rod"] = true,
        ["Kings Rod"] = true,
        ["Depthseeker Rod"] = true,
        ["Champions Rod"] = true,
        ["Stone Rod"] = true,
        ["Relic Rod"] = true,
        ["Heaven's Rod"] = true,
        ["Rod of the Zenith"] = true,
        ["Daybreaker Rod"] = true,
        ["Volcanic Rod"] = true,
        ["Lucid Rod"] = true,
        ["Rod of the Depths"] = true,
    },
}
for _, category in ipairs({ SafeTotem.Totems, SafeTotem.Rods, SafeTotem.Baits }) do
    for itemName, positions in pairs(category) do
        SafeTotem.Stands[itemName] = positions
    end
end
function SafeTotem.Catalog(category)
    local names = {}
    for itemName in pairs(category) do table.insert(names, itemName) end
    table.sort(names)
    return names
end
function SafeTotem.Notify(content)
    pcall(function()
        Window:Notify({ Title = "Safe Shop", Content = content, Duration = 3, Type = "Info" })
    end)
end
function SafeTotem.GetRoot()
    local character = LocalPlayer.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end
function SafeTotem.GetCash()
    local stats = LocalPlayer:FindFirstChild("leaderstats")
    local cash = stats and stats:FindFirstChild("C$")
    if not cash then return nil end
    return tonumber((tostring(cash.Value):gsub("[^%d]", "")))
end
function SafeTotem.CountOwned(itemName)
    local count = 0
    for _, container in ipairs({ LocalPlayer:FindFirstChild("Backpack"), LocalPlayer.Character }) do
        if container then
            for _, item in ipairs(container:GetChildren()) do
                if item:IsA("Tool") and item.Name == itemName then count += 1 end
            end
        end
    end
    return count
end
function SafeTotem.FindOwned(itemName)
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    return (backpack and backpack:FindFirstChild(itemName)) or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(itemName))
end
function SafeTotem.NearestPosition(itemName)
    local positions = SafeTotem.Stands[itemName]
    if not positions then return nil end
    local root = SafeTotem.GetRoot()
    local best, bestDistance = positions[1], math.huge
    if not root then return best end
    for _, position in ipairs(positions) do
        local distance = (root.Position - position).Magnitude
        if distance < bestDistance then best, bestDistance = position, distance end
    end
    return best
end
function SafeTotem.FindStand(itemName, nearPosition)
    local world = workspace:FindFirstChild("world")
    local interactables = world and world:FindFirstChild("interactables")
    if not interactables then return nil end
    local best, bestDistance = nil, 60
    for _, model in ipairs(interactables:GetChildren()) do
        if model.Name == itemName and model:FindFirstChildWhichIsA("ProximityPrompt", true) then
            local ok, pivot = pcall(model.GetPivot, model)
            local distance = (ok and nearPosition) and (pivot.Position - nearPosition).Magnitude or 0
            if distance < bestDistance then best, bestDistance = model, distance end
        end
    end
    return best
end
function SafeTotem.GetPopup()
    local over = LocalPlayer.PlayerGui:FindFirstChild("over")
    local popup = over and over:FindFirstChild("prompt")
    if popup and popup:IsA("GuiObject") and popup.Visible then return popup end
    return nil
end
function SafeTotem.Press(button)
    if not button or not button.Parent then return end
    local fired = 0
    if getconnections then
        for _, signal in ipairs({ button.Activated, button.MouseButton1Click }) do
            local ok, conns = pcall(getconnections, signal)
            if ok and type(conns) == "table" then
                for _, conn in ipairs(conns) do
                    local okFire = pcall(function()
                        if conn.Function then task.spawn(conn.Function) else conn:Fire() end
                    end)
                    if okFire then fired += 1 end
                end
            end
        end
    end
    task.wait(0.35)
    if fired > 0 then return end
    if not button.Parent or not button.Visible then return end
    button.Selectable = true
    GuiService.SelectedObject = button
    if keypress and keyrelease then
        keypress(0x0D)
        keyrelease(0x0D)
    end
    task.wait(0.2)
    if GuiService.SelectedObject == button then GuiService.SelectedObject = nil end
end
function SafeTotem.WaitPopup(timeout)
    local deadline = os.clock() + timeout
    local popup = SafeTotem.GetPopup()
    while not popup and os.clock() < deadline do
        task.wait(0.15)
        popup = SafeTotem.GetPopup()
    end
    return popup
end
function SafeTotem.SetAmount(popup, amount)
    local box = popup:FindFirstChild("amount")
    if not box or not box:IsA("TextBox") or not box.Visible or amount <= 1 then return 1 end
    box.Text = tostring(amount)
    if firesignal then pcall(firesignal, box.FocusLost, true) end
    task.wait(0.3)
    local question = popup:FindFirstChild("question")
    if question and question:IsA("TextLabel") and question.Text:find("x" .. amount, 1, true) then return amount end
    box.Text = "1"
    if firesignal then pcall(firesignal, box.FocusLost, true) end
    task.wait(0.2)
    return 1
end
function SafeTotem.PromptPosition(prompt, fallback)
    local holder = prompt.Parent
    if holder and holder:IsA("BasePart") then return holder.Position end
    if holder and holder:IsA("Attachment") then return holder.WorldPosition end
    return fallback
end
function SafeTotem.InRange(stand, prompt)
    local root = SafeTotem.GetRoot()
    if not root or not stand or not prompt then return false end
    local promptPos = SafeTotem.PromptPosition(prompt, stand:GetPivot().Position)
    local limit = math.min(prompt.MaxActivationDistance, 12) - 1
    return (root.Position - promptPos).Magnitude <= limit
end
function SafeTotem.StreamAround(position)
    local finished = false
    task.spawn(function()
        pcall(LocalPlayer.RequestStreamAroundAsync, LocalPlayer, position, 3)
        finished = true
    end)
    local deadline = os.clock() + 3
    while not finished and os.clock() < deadline do task.wait(0.1) end
end
function SafeTotem.ApproachStand(itemName)
    local root = SafeTotem.GetRoot()
    local standPos = SafeTotem.NearestPosition(itemName)
    if not root or not standPos then return nil, "nochar" end
    SafeTotem.StreamAround(standPos)
    root = SafeTotem.GetRoot()
    if not root then return nil, "nochar" end
    pcall(function() root.AssemblyLinearVelocity = Vector3.zero end)
    root.CFrame = CFrame.new(standPos + Vector3.new(0, 3, 3), standPos)
    local stand
    local deadline = os.clock() + 6
    repeat
        stand = SafeTotem.FindStand(itemName, standPos)
        if not stand then task.wait(0.25) end
    until stand or os.clock() > deadline
    if not stand then return nil, "nostand" end
    local prompt = stand:FindFirstChildWhichIsA("ProximityPrompt", true)
    if not prompt then return nil, "noprompt" end
    local promptPos = SafeTotem.PromptPosition(prompt, stand:GetPivot().Position)
    root = SafeTotem.GetRoot()
    if not root then return nil, "nochar" end
    pcall(function() root.AssemblyLinearVelocity = Vector3.zero end)
    root.CFrame = CFrame.new(promptPos + Vector3.new(0, 2.5, 3), promptPos)
    task.wait(0.8)
    if not SafeTotem.InRange(stand, prompt) then return nil, "blocked" end
    return stand
end
function SafeTotem.IsFunds(popup)
    local info = popup and popup:FindFirstChild("info")
    return info and info:IsA("TextLabel") and info.Visible and info.Text:lower():find("insufficient") ~= nil
end
function SafeTotem.BuyOnce(stand, amount)
    local prompt = stand:FindFirstChildWhichIsA("ProximityPrompt", true)
    if not prompt or not prompt.Enabled or typeof(fireproximityprompt) ~= "function" then return "noprompt", 0 end
    if not SafeTotem.InRange(stand, prompt) then return "blocked", 0 end
    pcall(fireproximityprompt, prompt)
    local popup = SafeTotem.WaitPopup(3)
    if not popup then return "nopopup", 0 end
    if SafeTotem.IsFunds(popup) then
        SafeTotem.Press(popup:FindFirstChild("confirm"))
        return "funds", 0
    end
    local applied = SafeTotem.SetAmount(popup, amount)
    local question = popup:FindFirstChild("question")
    SafeTotem.LastQuestion = question and question:IsA("TextLabel") and question.Text or ""
    if SafeTotem.DryRun then
        SafeTotem.Press(popup:FindFirstChild("deny"))
        return "dryrun", applied
    end
    SafeTotem.Press(popup:FindFirstChild("confirm"))
    local leftover = SafeTotem.WaitPopup(1)
    if leftover then
        local funds = SafeTotem.IsFunds(leftover)
        SafeTotem.Press(leftover:FindFirstChild("confirm") or leftover:FindFirstChild("deny"))
        if funds then return "funds", 0 end
    end
    return "confirmed", applied
end
function SafeTotem.Buy(itemName, amount)
    amount = math.clamp(math.floor(tonumber(amount) or 1), 1, 50)
    if type(itemName) ~= "string" or itemName == "" then return false, "invalid" end
    if not SafeTotem.Stands[itemName] then return false, "nostand" end
    if SafeTotem.Rods[itemName] then amount = 1 end
    if SafeTotem.Busy then return false, "busy" end
    local root = SafeTotem.GetRoot()
    if not root then return false, "nochar" end
    SafeTotem.Busy = true
    local origin = root.CFrame
    local startCount = SafeTotem.CountOwned(itemName)
    local bought = 0
    local ok, result = pcall(function()
        local stand, approachReason = SafeTotem.ApproachStand(itemName)
        if not stand then return approachReason or "nostand" end
        local attempts = 0
        while bought < amount and attempts < amount + 2 do
            attempts += 1
            local cashBefore = SafeTotem.GetCash()
            local countBefore = SafeTotem.CountOwned(itemName)
            local status, applied = SafeTotem.BuyOnce(stand, amount - bought)
            if status ~= "confirmed" then return status end
            local deadline = os.clock() + 3
            local landed = false
            repeat
                task.wait(0.2)
                local cashNow = SafeTotem.GetCash()
                landed = SafeTotem.CountOwned(itemName) > countBefore or (cashBefore ~= nil and cashNow ~= nil and cashNow < cashBefore)
            until landed or os.clock() > deadline
            if not landed then return bought > 0 and "partial" or "rejected" end
            bought += applied
            task.wait(0.5)
        end
        return "bought"
    end)
    local returnRoot = SafeTotem.GetRoot()
    if returnRoot then
        pcall(function() returnRoot.AssemblyLinearVelocity = Vector3.zero end)
        returnRoot.CFrame = origin
    end
    SafeTotem.Busy = false
    SafeTotem.LastBought = math.max(bought, SafeTotem.CountOwned(itemName) - startCount)
    if not ok then return false, "error" end
    return result == "bought" or result == "dryrun", result
end
function SafeTotem.Explain(itemName, reason)
    if reason == "nostand" and SafeTotem.UnverifiedStands[itemName] then return itemName .. " stand was not found at its listed location (community coordinate). Nothing was bought." end
    if reason == "nostand" then return itemName .. " has no verified shop stand. Get it manually first." end
    if reason == "funds" then return "Not enough C$ for " .. itemName .. "." end
    if reason == "blocked" then return "Could not reach the " .. itemName .. " stand safely. Purchase skipped." end
    if reason == "busy" then return "Another shop purchase is in progress." end
    if reason == "partial" then return "Only part of the " .. itemName .. " order arrived." end
    if reason == "rejected" then return itemName .. " was not delivered (already owned or locked)." end
    if reason == "nopopup" then return itemName .. " stand did not open a purchase popup." end
    if reason == "nochar" then return "Character not ready." end
    return "Could not buy " .. itemName .. " (" .. tostring(reason) .. ")."
end
function SafeTotem.Ensure(itemName, allowPurchase)
    local owned = SafeTotem.FindOwned(itemName)
    if owned then return owned end
    if not allowPurchase then return nil end
    local ok, reason = SafeTotem.Buy(itemName, 1)
    if not ok then
        SafeTotem.Notify(SafeTotem.Explain(itemName, reason))
        return nil
    end
    local deadline = os.clock() + 3
    repeat
        owned = SafeTotem.FindOwned(itemName)
        if not owned then task.wait(0.2) end
    until owned or os.clock() > deadline
    return owned
end
function SafeTotem.RestockEnabled()
    return SafeTotem.AutoRestock == true
end
SafeTotem.HotkeyNames = { "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine" }
SafeTotem.MerlinAnchor = Vector3.new(-950, 224, -983)
SafeTotem.AltarAnchor = Vector3.new(1310.5, -797.4, -87.7)
SafeTotem.Affirmative = { "yes", "buy", "purchase", "sure", "deal", "okay", "please" }
SafeTotem.MenuWords = { "buy", "purchase", "shop", "wares", "trade", "browse", "sell me" }
SafeTotem.LeaveWords = { "bye", "never mind", "nevermind", "leave", "no thanks", "nothing" }
SafeTotem.CrateEnabled = false
SafeTotem.CrateToken = 0
SafeTotem.CrateName = "Bait Crate"
SafeTotem.EnchantEnabled = false
SafeTotem.EnchantToken = 0
SafeTotem.EnchantTargets = {}
SafeTotem.RelicName = "Enchant Relic"
SafeTotem.MerlinLevel = 30
function SafeTotem.PlayerLevel()
    local stats = LocalPlayer:FindFirstChild("leaderstats")
    local level = stats and stats:FindFirstChild("Level")
    return level and tonumber(level.Value) or 0
end
function SafeTotem.LibraryNames(predicate, fallback)
    local names = {}
    local ok, library = pcall(require, game:GetService("ReplicatedStorage").shared.modules.library.fish)
    if ok and type(library) == "table" then
        for name, data in pairs(library) do
            if type(name) == "string" and type(data) == "table" and not name:find("^Admin") and predicate(data) then
                table.insert(names, name)
            end
        end
    end
    if #names == 0 then names = table.clone(fallback) end
    table.sort(names)
    return names
end
function SafeTotem.InventoryStack(itemName, includeFavourited)
    local ok, total = pcall(function()
        local controller = require(game:GetService("ReplicatedStorage").client.legacyControllers.DataController)
        local inventory = controller.InventoryReplicator:TryIndex({ "Inventory" })
        local sum = 0
        for _, entry in inventory do
            local sub = entry.sub or {}
            if entry.name == itemName and (includeFavourited or not sub.Favourited) then sum += sub.Stack or 1 end
        end
        return sum
    end)
    return ok and total or 0
end
function SafeTotem.HeldTool()
    local character = LocalPlayer.Character
    return character and character:FindFirstChildOfClass("Tool")
end
function SafeTotem.HotbarKey(itemName)
    local backpackGui = LocalPlayer.PlayerGui:FindFirstChild("backpack")
    local hotbar = backpackGui and backpackGui:FindFirstChild("hotbar")
    if not hotbar then return nil end
    for _, label in ipairs(hotbar:GetDescendants()) do
        if label:IsA("TextLabel") and label.Name == "ItemName" then
            local firstLine = ((label.Text:match("^([^\10]*)") or ""):gsub("%s+$", ""))
            local slot = label.Parent
            local keyLabel = slot and slot:FindFirstChild("TextLabel")
            local key = keyLabel and tonumber(keyLabel.Text)
            if firstLine == itemName and slot:IsA("GuiObject") and slot.Visible and key and SafeTotem.HotkeyNames[key] then return key end
        end
    end
    return nil
end
function SafeTotem.EquipFromHotbar(itemName)
    local held = SafeTotem.HeldTool()
    if held and held.Name == itemName then return held end
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 or humanoid.WalkSpeed <= 0.1 then return nil, "noequip" end
    if LocalPlayer.PlayerGui:FindFirstChild("reel") then return nil, "noequip" end
    local function waitHeld(timeout)
        local deadline = os.clock() + timeout
        repeat
            local tool = SafeTotem.HeldTool()
            if tool and tool.Name == itemName then return tool end
            task.wait(0.15)
        until os.clock() > deadline
        return nil
    end
    local itemId = SafeTotem.InventoryId(itemName)
    local net = game:GetService("ReplicatedStorage"):FindFirstChild("packages")
    local equipRemote = net and net:FindFirstChild("Net") and net.Net:FindFirstChild("RE/Backpack/Equip")
    if itemId and equipRemote then
        equipRemote:FireServer(itemId)
        held = waitHeld(3)
        if held then return held end
    end
    return nil, (itemId and equipRemote) and "noequip" or "nohotbar"
end
function SafeTotem.InventoryId(itemName)
    local ok, itemId = pcall(function()
        local controller = require(game:GetService("ReplicatedStorage").client.legacyControllers.DataController)
        local inventory = controller.InventoryReplicator:TryIndex({ "Inventory" })
        for key, entry in inventory do
            if entry.name == itemName and not (entry.sub and entry.sub.Favourited) then return key end
        end
        return nil
    end)
    return ok and itemId or nil
end
function SafeTotem.Unequip()
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then pcall(humanoid.UnequipTools, humanoid) end
end
function SafeTotem.OpenCrateOnce(crateName)
    local before = SafeTotem.InventoryStack(crateName)
    if before <= 0 then return "empty", 0 end
    local tool, reason = SafeTotem.EquipFromHotbar(crateName)
    if not tool then return reason, 0 end
    task.wait(0.35)
    pcall(function() tool:Activate() end)
    local popup = SafeTotem.WaitPopup(4)
    if not popup then return "nopopup", 0 end
    local question = popup:FindFirstChild("question")
    if not (question and question:IsA("TextLabel") and question.Text:find("Open", 1, true)) then
        SafeTotem.Press(popup:FindFirstChild("deny"))
        return "nopopup", 0
    end
    local applied = SafeTotem.SetAmount(popup, math.min(before, 50))
    if SafeTotem.DryRun then
        SafeTotem.Press(popup:FindFirstChild("deny"))
        return "dryrun", applied
    end
    SafeTotem.Press(popup:FindFirstChild("confirm"))
    local deadline = os.clock() + 6
    repeat task.wait(0.25) until SafeTotem.InventoryStack(crateName) < before or os.clock() > deadline
    local opened = before - SafeTotem.InventoryStack(crateName)
    if opened <= 0 then return "rejected", 0 end
    return "opened", opened
end
SafeTotem.MerlinCatalog = {
    { Name = "Enchant Relic", Keys = { "enchant relic", "enchant" }, Avoid = { "twisted" } },
    { Name = "Twisted Relic", Keys = { "twisted" }, Avoid = {} },
    { Name = "Temporary XP Boost", Keys = { "xp", "experience" }, Avoid = {} },
    { Name = "Temporary Lure Boost", Keys = { "lure" }, Avoid = {} },
    { Name = "Temporary Luck Boost", Keys = { "luck" }, Avoid = {} },
}
function SafeTotem.MerlinEntry(itemName)
    for _, entry in ipairs(SafeTotem.MerlinCatalog) do
        if entry.Name == itemName then return entry end
    end
    return nil
end
function SafeTotem.HasWord(text, words)
    for _, word in ipairs(words) do
        if text:find(word, 1, true) then return true end
    end
    return false
end
function SafeTotem.DialogChoices()
    local choices = {}
    local hud = LocalPlayer.PlayerGui:FindFirstChild("hud")
    local roots = { LocalPlayer.PlayerGui:FindFirstChild("options"), hud and hud:FindFirstChild("safezone") and hud.safezone:FindFirstChild("options") }
    for _, root in ipairs(roots) do
        if root then
            for _, option in ipairs(root:GetDescendants()) do
                local index = tonumber(option.Name:match("^(%d+)option$"))
                if index then
                    local button = option:IsA("GuiButton") and option or option:FindFirstChild("button")
                    local label = option:FindFirstChild("text") or option
                    local text = (label:IsA("TextLabel") or label:IsA("TextButton")) and label.Text or ""
                    if button and button:IsA("GuiButton") then
                        table.insert(choices, { Index = index, Button = button, Text = text:lower():gsub("<[^>]+>", "") })
                    end
                end
            end
        end
    end
    table.sort(choices, function(a, b) return a.Index < b.Index end)
    return choices
end
function SafeTotem.WaitChoices(timeout)
    local deadline = os.clock() + timeout
    repeat
        local choices = SafeTotem.DialogChoices()
        if #choices > 0 then return choices end
        task.wait(0.2)
    until os.clock() > deadline
    return {}
end
function SafeTotem.PressChoice(choice)
    if not choice then return end
    local netPkg = ReplicatedStorage:FindFirstChild("packages") and ReplicatedStorage.packages:FindFirstChild("Net")
    local di = netPkg and netPkg:FindFirstChild("RF/DialogInteract")
    if di and choice.Index then
        local ok = pcall(function() di:InvokeServer(3, choice.Index) end)
        if ok then return end
    end
    if choice.Button then SafeTotem.Press(choice.Button) end
end
function SafeTotem.LeaveDialog()
    for _ = 1, 3 do
        local choices = SafeTotem.DialogChoices()
        if #choices == 0 then return end
        local picked = choices[#choices]
        for _, choice in ipairs(choices) do
            if SafeTotem.HasWord(choice.Text, SafeTotem.LeaveWords) then picked = choice break end
        end
        SafeTotem.PressChoice(picked)
        task.wait(1)
    end
end
function SafeTotem.ApproachNpc(npcName, anchor)
    local root = SafeTotem.GetRoot()
    if not root then return nil, "nochar" end
    SafeTotem.StreamAround(anchor)
    root = SafeTotem.GetRoot()
    if not root then return nil, "nochar" end
    pcall(function() root.AssemblyLinearVelocity = Vector3.zero end)
    root.CFrame = CFrame.new(anchor)
    local npcs = workspace:FindFirstChild("world") and workspace.world:FindFirstChild("npcs")
    local npc
    local deadline = os.clock() + 12
    repeat
        npc = npcs and npcs:FindFirstChild(npcName)
        if not npc then task.wait(0.25) end
    until npc or os.clock() > deadline
    if not npc or not npc:IsA("Model") then return nil, "nonpc" end
    local prompt = npc:FindFirstChildWhichIsA("ProximityPrompt", true)
    if not prompt then return nil, "noprompt" end
    local npcPos = npc:GetPivot().Position
    root = SafeTotem.GetRoot()
    if not root then return nil, "nochar" end
    pcall(function() root.AssemblyLinearVelocity = Vector3.zero end)
    root.CFrame = CFrame.new(npcPos + (npc:GetPivot().LookVector * 4), npcPos)
    task.wait(0.8)
    local limit = math.min(prompt.MaxActivationDistance, 12) - 1
    local settledRoot = SafeTotem.GetRoot()
    if not settledRoot then return nil, "nochar" end
    if (settledRoot.Position - SafeTotem.PromptPosition(prompt, npcPos)).Magnitude > limit then return nil, "blocked" end
    return npc, prompt
end
function SafeTotem.MerlinStep(entry)
    local npc, prompt = SafeTotem.ApproachNpc("Merlin", SafeTotem.MerlinAnchor)
    if not npc then return prompt or "nonpc" end
    if not prompt.Enabled then return "noprompt" end
    local heard = {}
    local function listen(container)
        if not container then return nil end
        return container.DescendantAdded:Connect(function(added)
            if not added:IsA("TextLabel") then return end
            task.delay(0.15, function()
                if added.Text ~= "" then table.insert(heard, added.Text:lower()) end
            end)
        end)
    end
    local hud = LocalPlayer.PlayerGui:FindFirstChild("hud")
    local announcements = hud and hud:FindFirstChild("safezone") and hud.safezone:FindFirstChild("announcements")
    local listeners = { listen(announcements), listen(npc) }
    local function refused()
        for _, label in ipairs(npc:GetDescendants()) do
            if label:IsA("TextLabel") and label.Text ~= "" then table.insert(heard, label.Text:lower()) end
        end
        for _, text in ipairs(heard) do
            if text:find("level", 1, true) or text:find("experienced", 1, true) then return true end
        end
        return false
    end
    local ok, result = pcall(function()
        pcall(fireproximityprompt, prompt)
        return SafeTotem.MerlinConverse(entry, refused)
    end)
    for _, connection in ipairs(listeners) do
        if connection then connection:Disconnect() end
    end
    if not ok then return "error" end
    return result
end
function SafeTotem.MerlinConverse(entry, refused)
    local pickedItem = false
    for _ = 1, 6 do
        local popup = SafeTotem.GetPopup()
        if popup then
            if SafeTotem.IsFunds(popup) then
                SafeTotem.Press(popup:FindFirstChild("confirm"))
                return "funds"
            end
            if SafeTotem.DryRun then
                SafeTotem.Press(popup:FindFirstChild("deny"))
                return "dryrun"
            end
            SafeTotem.Press(popup:FindFirstChild("confirm"))
            return "confirmed"
        end
        local choices = SafeTotem.WaitChoices(3)
        if #choices == 0 then
            if refused() then return "level" end
            return pickedItem and "confirmed" or "nodialog"
        end
        local target
        for _, choice in ipairs(choices) do
            if SafeTotem.HasWord(choice.Text, entry.Keys) and not SafeTotem.HasWord(choice.Text, entry.Avoid) then target = choice break end
        end
        if not target and pickedItem then
            for _, choice in ipairs(choices) do
                if SafeTotem.HasWord(choice.Text, SafeTotem.Affirmative) then target = choice break end
            end
            if target and SafeTotem.DryRun then
                SafeTotem.LeaveDialog()
                return "dryrun"
            end
        end
        if not target and not pickedItem then
            for _, choice in ipairs(choices) do
                if SafeTotem.HasWord(choice.Text, SafeTotem.MenuWords) then target = choice break end
            end
        end
        if not target then
            SafeTotem.LeaveDialog()
            return pickedItem and "confirmed" or "nochoice"
        end
        if SafeTotem.HasWord(target.Text, entry.Keys) then
            if SafeTotem.DryRun then
                SafeTotem.LeaveDialog()
                return "dryrun"
            end
            pickedItem = true
        end
        SafeTotem.PressChoice(target)
        task.wait(1.4)
    end
    SafeTotem.LeaveDialog()
    return pickedItem and "confirmed" or "nochoice"
end
function SafeTotem.MerlinBuy(itemName, amount)
    local entry = SafeTotem.MerlinEntry(itemName)
    if not entry then return false, "invalid", 0 end
    if SafeTotem.PlayerLevel() < SafeTotem.MerlinLevel then return false, "level", 0 end
    if SafeTotem.Busy then return false, "busy", 0 end
    local root = SafeTotem.GetRoot()
    if not root then return false, "nochar", 0 end
    SafeTotem.Busy = true
    local origin = root.CFrame
    local bought = 0
    local ok, result = pcall(function()
        for _ = 1, amount do
            local cashBefore = SafeTotem.GetCash()
            local stackBefore = SafeTotem.InventoryStack(itemName, true)
            local status = SafeTotem.MerlinStep(entry)
            if status ~= "confirmed" then return status end
            local deadline = os.clock() + 4
            local landed = false
            repeat
                task.wait(0.25)
                local cashNow = SafeTotem.GetCash()
                landed = SafeTotem.InventoryStack(itemName, true) > stackBefore or (cashBefore ~= nil and cashNow ~= nil and cashNow < cashBefore)
            until landed or os.clock() > deadline
            if not landed then return bought > 0 and "partial" or "rejected" end
            bought += 1
            task.wait(0.8)
        end
        return "bought"
    end)
    local returnRoot = SafeTotem.GetRoot()
    if returnRoot then
        pcall(function() returnRoot.AssemblyLinearVelocity = Vector3.zero end)
        returnRoot.CFrame = origin
    end
    SafeTotem.Busy = false
    if not ok then return false, "error", bought end
    return result == "bought" or result == "dryrun", result, bought
end
function SafeTotem.EquippedRod()
    local ok, rodName = pcall(function()
        local helper = require(game:GetService("ReplicatedStorage").shared.modules.SharedDataHelper)
        return helper.readLegacyPathValue(LocalPlayer, { "Stats", "rod" })
    end)
    return ok and type(rodName) == "string" and rodName ~= "" and rodName or nil
end
function SafeTotem.RodEnchants(rodName)
    local ok, record = pcall(function()
        local helper = require(game:GetService("ReplicatedStorage").shared.modules.SharedDataHelper)
        return helper.indexNewFormat(LocalPlayer, { "Rods", rodName })
    end)
    if not ok or type(record) ~= "table" then return nil, nil end
    return tostring(record.enchant or "none"), tostring(record.secondaryEnchant or "none")
end
function SafeTotem.EnchantReached()
    local rodName = SafeTotem.EquippedRod()
    if not rodName then return false end
    local primary, secondary = SafeTotem.RodEnchants(rodName)
    for target in pairs(SafeTotem.EnchantTargets) do
        if primary == target or secondary == target then return true end
    end
    return false
end
function SafeTotem.IsNight()
    local world = game:GetService("ReplicatedStorage"):FindFirstChild("world")
    local cycle = world and world:FindFirstChild("cycle")
    return cycle ~= nil and cycle.Value == "Night"
end
function SafeTotem.FindAltar()
    local map = workspace:FindFirstChild("world") and workspace.world:FindFirstChild("map")
    local room = map and map:FindFirstChild("Enchant Room")
    local altar = room and room:FindFirstChild("EnchantAltar")
    local core = altar and altar:FindFirstChild("Core")
    local prompt = core and core:FindFirstChildWhichIsA("ProximityPrompt", true)
    return core, prompt
end
function SafeTotem.ConfirmationButton(words)
    local confirmation = LocalPlayer.PlayerGui:FindFirstChild("PromptConfirmation")
    local frame = confirmation and confirmation:FindFirstChild("Frame")
    local options = frame and frame:FindFirstChild("Options")
    if not options or not frame.Visible then return nil end
    for _, button in ipairs(options:GetChildren()) do
        local label = button:IsA("GuiButton") and button:FindFirstChild("Label")
        if label and SafeTotem.HasWord(label.Text:lower(), words) then return button end
    end
    return nil
end
function SafeTotem.ApproachAltar()
    local root = SafeTotem.GetRoot()
    if not root then return nil, "nochar" end
    SafeTotem.StreamAround(SafeTotem.AltarAnchor)
    root = SafeTotem.GetRoot()
    if not root then return nil, "nochar" end
    pcall(function() root.AssemblyLinearVelocity = Vector3.zero end)
    root.CFrame = CFrame.new(SafeTotem.AltarAnchor)
    local core, prompt
    local deadline = os.clock() + 12
    repeat
        core, prompt = SafeTotem.FindAltar()
        if not prompt then task.wait(0.25) end
    until prompt or os.clock() > deadline
    if not prompt then return nil, "noaltar" end
    local promptPos = SafeTotem.PromptPosition(prompt, core.Position)
    local away = SafeTotem.AltarAnchor - promptPos
    local offset = away.Magnitude > 0.5 and away.Unit * 4 or Vector3.new(0, 0, 4)
    root = SafeTotem.GetRoot()
    if not root then return nil, "nochar" end
    pcall(function() root.AssemblyLinearVelocity = Vector3.zero end)
    root.CFrame = CFrame.new(promptPos + Vector3.new(offset.X, 1.5, offset.Z), promptPos)
    task.wait(0.8)
    local settledRoot = SafeTotem.GetRoot()
    if not settledRoot then return nil, "nochar" end
    if (settledRoot.Position - promptPos).Magnitude > math.min(prompt.MaxActivationDistance, 12) - 1 then return nil, "blocked" end
    return prompt
end
function SafeTotem.EnchantConfirmFrame()
    local hud = LocalPlayer.PlayerGui:FindFirstChild("hud")
    local safezone = hud and hud:FindFirstChild("safezone")
    local frame = safezone and safezone:FindFirstChild("EnchantConfirm")
    if frame and frame.Visible then return frame end
    return nil
end
function SafeTotem.EnchantOnce(relicName)
    local rodName = SafeTotem.EquippedRod()
    if not rodName then return "norod" end
    if SafeTotem.InventoryStack(relicName) <= 0 then return "norelic" end
    if not SafeTotem.IsNight() then return "day" end
    local prompt, reason = SafeTotem.ApproachAltar()
    if not prompt then return reason end
    local tool, equipReason = SafeTotem.EquipFromHotbar(relicName)
    if not tool then return equipReason end
    task.wait(0.4)
    if not prompt.Enabled then return "noprompt" end
    local primaryBefore, secondaryBefore = SafeTotem.RodEnchants(rodName)
    local stackBefore = SafeTotem.InventoryStack(relicName)
    pcall(fireproximityprompt, prompt)
    local frame
    local deadline = os.clock() + 6
    repeat
        local first = SafeTotem.ConfirmationButton({ "continue", "confirm", "yes", "enchant", "proceed" })
        if first then
            if SafeTotem.DryRun then
                SafeTotem.Press(SafeTotem.ConfirmationButton({ "cancel", "no", "back" }) or first)
                return "dryrun"
            end
            SafeTotem.Press(first)
        end
        frame = SafeTotem.EnchantConfirmFrame()
        if not frame then task.wait(0.2) end
    until frame or os.clock() > deadline
    if not frame then return "noconfirm" end
    if SafeTotem.DryRun then
        SafeTotem.Press(frame:FindFirstChild("cancelButton"))
        return "dryrun"
    end
    SafeTotem.Press(frame:FindFirstChild("enchantButton"))
    local landedBy = os.clock() + 8
    repeat
        task.wait(0.3)
        local primaryNow, secondaryNow = SafeTotem.RodEnchants(rodName)
        if SafeTotem.InventoryStack(relicName) < stackBefore or primaryNow ~= primaryBefore or secondaryNow ~= secondaryBefore then return "enchanted" end
    until os.clock() > landedBy
    return "rejected"
end
function SafeTotem.ExplainService(subject, reason)
    if reason == "level" then return "Merlin requires level " .. SafeTotem.MerlinLevel .. " (you are level " .. SafeTotem.PlayerLevel() .. ")." end
    if reason == "nonpc" or reason == "noaltar" then return subject .. " did not stream in. Try again closer to it." end
    if reason == "nodialog" or reason == "nochoice" then return subject .. " dialog did not offer that option." end
    if reason == "norelic" then return "No unfavorited " .. SafeTotem.RelicName .. " left in inventory." end
    if reason == "norod" then return "Equip a fishing rod first." end
    if reason == "nohotbar" then return "Put the item on your hotbar (slots 1-9) first." end
    if reason == "noequip" then return "Could not equip the item from the hotbar." end
    if reason == "noconfirm" then return "The altar did not open the enchant confirmation." end
    if reason == "empty" then return "No unfavorited " .. SafeTotem.CrateName .. " left." end
    if reason == "dryrun" then return subject .. " dry run finished; nothing was spent." end
    if reason == "nofigure" then return "The quest figure did not appear. It only spawns at night near Moosewood." end
    if reason == "talked" then return subject .. " dialog finished but the quest flag did not change." end
    return SafeTotem.Explain(subject, reason)
end
SafeTotem.ShadyEnabled = false
SafeTotem.ShadyToken = 0
SafeTotem.ShadyUseSundial = false
SafeTotem.ShadyRodPrice = 4000
SafeTotem.ShadyGuardLevel = 50
SafeTotem.ShadyGuardCash = 150000
SafeTotem.ShadyAnchors = {
    Todd = Vector3.new(499, 159, 218),
    Figures = Vector3.new(388, 135, 245),
    Lighthouse = Vector3.new(370, 126, 215),
    Guard = Vector3.new(686, 139, 321),
    Merchant = Vector3.new(-2997, -1023, 6067),
}
SafeTotem.ShadyRiddleNames = { "..?", "Some Shady Guy", "ShadyLighthouseFigure", "Lighthouse Figure" }
SafeTotem.ShadyFigureKinds = {
    Lantern = { "lantern", "fisher" },
    Diver = { "diver", "bobber" },
    Watchman = { "watchman" },
}
function SafeTotem.ShadyCache()
    local flags = {}
    pcall(function()
        local data = require(game:GetService("ReplicatedStorage").client.modules.legacyLocalPlayerData).fetch()
        local cache = data and data:FindFirstChild("Cache")
        for _, key in ipairs({ "Bazaar_FoundLantern", "Bazaar_FoundDiver", "Bazaar_FoundWatchman", "Bazaar_LighthousePassed" }) do
            local value = cache and cache:FindFirstChild(key)
            flags[key] = value ~= nil and value.Value == true
        end
        local active = data and data:FindFirstChild("QuestActive")
        flags.QuestActive = active ~= nil and active:FindFirstChild("Bazaar_FindFigures") ~= nil
    end)
    return flags
end
function SafeTotem.ShadyCoins()
    local hud = LocalPlayer.PlayerGui:FindFirstChild("hud")
    local gui = hud and hud:FindFirstChild("safezone") and hud.safezone:FindFirstChild("ShadyCoinGui")
    if not gui then return 0 end
    local label = (gui:IsA("TextLabel") and gui) or gui:FindFirstChildWhichIsA("TextLabel", true)
    if not label then return 0 end
    return tonumber((label.Text:gsub(",", ""):gsub("%s*S%$.*", ""):gsub("[^%d]", ""))) or 0
end
function SafeTotem.OwnsRod(rodName)
    if SafeTotem.InventoryStack(rodName, true) > 0 then return true end
    local ok, record = pcall(function()
        local helper = require(game:GetService("ReplicatedStorage").shared.modules.SharedDataHelper)
        return helper.indexNewFormat(LocalPlayer, { "Rods", rodName })
    end)
    return ok and record ~= nil
end
function SafeTotem.ShadyStatus()
    local cache = SafeTotem.ShadyCache()
    local coins = SafeTotem.ShadyCoins()
    local status = {
        Lantern = cache.Bazaar_FoundLantern == true,
        Diver = cache.Bazaar_FoundDiver == true,
        Watchman = cache.Bazaar_FoundWatchman == true,
        Lighthouse = cache.Bazaar_LighthousePassed == true,
        QuestActive = cache.QuestActive == true,
        ShadyCoins = coins,
        OwnsRod = SafeTotem.OwnsRod("Shady Rod"),
    }
    status.Figures = status.Lantern and status.Diver and status.Watchman
    status.Gate = coins > 0 or getgenv().LiyhubBazaarGate == true
    return status
end
function SafeTotem.ShadyStatusText(status, action)
    local function mark(flag) return flag and "done" or "pending" end
    return string.format(
        "Figures: Lantern %s | Diver %s | Watchman %s\10Lighthouse riddle: %s\10Bazaar gate: %s (needs level %d, %d C$)\10Shady Coins: %d/%d\10Level %d | C$ %s\10Status: %s",
        mark(status.Lantern), mark(status.Diver), mark(status.Watchman), mark(status.Lighthouse),
        status.Gate and "open" or "closed", SafeTotem.ShadyGuardLevel, SafeTotem.ShadyGuardCash,
        status.ShadyCoins, SafeTotem.ShadyRodPrice, SafeTotem.PlayerLevel(), tostring(SafeTotem.GetCash() or 0),
        action or "Idle"
    )
end
function SafeTotem.ApproachModel(model, prompt)
    if not model or not prompt then return nil, "nonpc" end
    local pivot = model:GetPivot()
    local promptPos = SafeTotem.PromptPosition(prompt, pivot.Position)
    local root = SafeTotem.GetRoot()
    if not root then return nil, "nochar" end
    local away = pivot.LookVector.Magnitude > 0 and pivot.LookVector * 4 or Vector3.new(0, 0, 4)
    pcall(function() root.AssemblyLinearVelocity = Vector3.zero end)
    root.CFrame = CFrame.new(promptPos + Vector3.new(away.X, 1.5, away.Z), promptPos)
    task.wait(0.8)
    local settledRoot = SafeTotem.GetRoot()
    if not settledRoot then return nil, "nochar" end
    if (settledRoot.Position - promptPos).Magnitude > math.min(prompt.MaxActivationDistance, 12) - 1 then return nil, "blocked" end
    return prompt
end
function SafeTotem.FindNpcModel(names, anchor)
    SafeTotem.StreamAround(anchor)
    local root = SafeTotem.GetRoot()
    if not root then return nil end
    pcall(function() root.AssemblyLinearVelocity = Vector3.zero end)
    root.CFrame = CFrame.new(anchor)
    local npcs = workspace:FindFirstChild("world") and workspace.world:FindFirstChild("npcs")
    local deadline = os.clock() + 10
    repeat
        for _, name in ipairs(names) do
            local npc = (npcs and npcs:FindFirstChild(name)) or workspace:FindFirstChild(name, true)
            local prompt = npc and npc:FindFirstChildWhichIsA("ProximityPrompt", true)
            if npc and prompt and (npc:IsA("Model") or npc:IsA("BasePart")) then return npc, prompt end
        end
        task.wait(0.25)
    until os.clock() > deadline
    return nil
end
function SafeTotem.FindShadyFigure(kind)
    local words = SafeTotem.ShadyFigureKinds[kind]
    local pool = game:GetService("CollectionService"):GetTagged("ShadyFigure")
    local npcs = workspace:FindFirstChild("world") and workspace.world:FindFirstChild("npcs")
    if npcs then
        for _, npc in ipairs(npcs:GetChildren()) do table.insert(pool, npc) end
    end
    for _, npc in ipairs(pool) do
        local prompt = npc:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt and SafeTotem.HasWord(npc.Name:lower(), words) then return npc, prompt end
    end
    return nil
end
function SafeTotem.ShadyTalk(npc, prompt, plan)
    local approached, reason = SafeTotem.ApproachModel(npc, prompt)
    if not approached then return reason end
    if not prompt.Enabled then return "noprompt" end
    if SafeTotem.DryRun then return "dryrun" end
    pcall(fireproximityprompt, prompt)
    local pressed = 0
    for _, step in ipairs(plan) do
        local choices = SafeTotem.WaitChoices(3)
        if #choices == 0 then break end
        local target
        for _, choice in ipairs(choices) do
            if SafeTotem.HasWord(choice.Text, step.Keys) then target = choice break end
        end
        if not target and step.Index then
            for _, choice in ipairs(choices) do
                if choice.Index == step.Index then target = choice break end
            end
        end
        if not target then break end
        SafeTotem.PressChoice(target)
        pressed += 1
        task.wait(1.2)
    end
    SafeTotem.LeaveDialog()
    return pressed > 0 and "talked" or "nochoice"
end
SafeTotem.ShadyPlans = {
    Accept = { { Keys = { "figure", "help", "quest", "what do you need", "accept" }, Index = 5 }, { Keys = { "accept", "yes", "sure", "okay" } } },
    HandIn = { { Keys = { "found", "figures", "done", "complete" }, Index = 1 }, { Keys = { "found", "done", "here", "yes" } } },
    Figure = { { Keys = { "who are you", "shady", "figure", "hello", "what" }, Index = 2 } },
    Riddle = { { Keys = { "lighthouse", "riddle", "answer", "challenge" }, Index = 7 } },
    Guard = { { Keys = { "enter", "bazaar", "let me in", "pass", "pay" }, Index = 1 }, { Keys = { "yes", "pay", "sure", "deal" } } },
}
function SafeTotem.ShadyVisit(names, anchor, plan)
    local npc, prompt = SafeTotem.FindNpcModel(names, anchor)
    if not npc then return "nonpc" end
    return SafeTotem.ShadyTalk(npc, prompt, plan)
end
function SafeTotem.ShadyFigureVisit(kind)
    SafeTotem.StreamAround(SafeTotem.ShadyAnchors.Figures)
    local root = SafeTotem.GetRoot()
    if not root then return "nochar" end
    pcall(function() root.AssemblyLinearVelocity = Vector3.zero end)
    root.CFrame = CFrame.new(SafeTotem.ShadyAnchors.Figures)
    local npc, prompt
    local deadline = os.clock() + 8
    repeat
        npc, prompt = SafeTotem.FindShadyFigure(kind)
        if not npc then task.wait(0.3) end
    until npc or os.clock() > deadline
    if not npc then return "nofigure" end
    SafeTotem.StreamAround(npc:GetPivot().Position)
    return SafeTotem.ShadyTalk(npc, prompt, SafeTotem.ShadyPlans.Figure)
end
function SafeTotem.ShadyNextStep(status)
    if status.OwnsRod then return "owned" end
    if not status.Figures then
        if not status.QuestActive then return "accept" end
        if not SafeTotem.IsNight() then return "night" end
        for _, kind in ipairs({ "Lantern", "Diver", "Watchman" }) do
            if not status[kind] then return "figure", kind end
        end
    end
    if status.QuestActive then return "handin" end
    if not status.Lighthouse then return "riddle" end
    if not status.Gate then
        if SafeTotem.PlayerLevel() < SafeTotem.ShadyGuardLevel or (SafeTotem.GetCash() or 0) < SafeTotem.ShadyGuardCash then return "grind" end
        return "guard"
    end
    if status.ShadyCoins < SafeTotem.ShadyRodPrice then return "coins" end
    return "buyrod"
end
function SafeTotem.ShadyRun(stepName, detail)
    local anchors = SafeTotem.ShadyAnchors
    if stepName == "accept" then return SafeTotem.ShadyVisit({ "Todd" }, anchors.Todd, SafeTotem.ShadyPlans.Accept) end
    if stepName == "handin" then return SafeTotem.ShadyVisit({ "Todd" }, anchors.Todd, SafeTotem.ShadyPlans.HandIn) end
    if stepName == "figure" then return SafeTotem.ShadyFigureVisit(detail) end
    if stepName == "riddle" then return SafeTotem.ShadyVisit(SafeTotem.ShadyRiddleNames, anchors.Lighthouse, SafeTotem.ShadyPlans.Riddle) end
    if stepName == "guard" then
        local result = SafeTotem.ShadyVisit({ "Bazaar Guard", "Guard" }, anchors.Guard, SafeTotem.ShadyPlans.Guard)
        if result == "talked" then getgenv().LiyhubBazaarGate = true end
        return result
    end
    if stepName == "buyrod" then return SafeTotem.ShadyBuyRod() end
    return "idle"
end
function SafeTotem.ShadyBuyRod()
    local npc, prompt = SafeTotem.FindNpcModel({ "Shady Merchant" }, SafeTotem.ShadyAnchors.Merchant)
    if not npc then return "nonpc" end
    local approached, reason = SafeTotem.ApproachModel(npc, prompt)
    if not approached then return reason end
    if not prompt.Enabled then return "noprompt" end
    if SafeTotem.DryRun then return "dryrun" end
    pcall(fireproximityprompt, prompt)
    for _ = 1, 4 do
        local popup = SafeTotem.GetPopup()
        if popup then
            if SafeTotem.IsFunds(popup) then
                SafeTotem.Press(popup:FindFirstChild("confirm"))
                return "funds"
            end
            SafeTotem.Press(popup:FindFirstChild("confirm"))
            local deadline = os.clock() + 4
            repeat task.wait(0.25) until SafeTotem.OwnsRod("Shady Rod") or os.clock() > deadline
            return SafeTotem.OwnsRod("Shady Rod") and "bought" or "rejected"
        end
        local choices = SafeTotem.WaitChoices(2.5)
        if #choices == 0 then break end
        local target
        for _, choice in ipairs(choices) do
            if SafeTotem.HasWord(choice.Text, { "shady rod", "rod" }) then target = choice break end
        end
        if not target then
            for _, choice in ipairs(choices) do
                if SafeTotem.HasWord(choice.Text, SafeTotem.MenuWords) or SafeTotem.HasWord(choice.Text, SafeTotem.Affirmative) then target = choice break end
            end
        end
        if not target then break end
        SafeTotem.PressChoice(target)
        task.wait(1.2)
    end
    SafeTotem.LeaveDialog()
    return "nochoice"
end
SafeTotem.ShadyMessages = {
    owned = "Shady Rod owned. Quest complete.",
    accept = "Talking to Todd to accept the figures quest...",
    night = "Figures only appear at night. Waiting...",
    figure = "Visiting the %s figure...",
    handin = "All figures found. Handing in to Todd (wear Tarnished Lantern, Crow Feather Charm, Barnacled Hook)...",
    riddle = "Solving the lighthouse riddle...",
    grind = "Bazaar Guard needs level %d and %d C$. Farm first, then re-enable.",
    guard = "Talking to the Bazaar Guard...",
    coins = "Need %d Shady Coins for the Shady Rod. Farm in the Bazaar, then re-enable.",
    buyrod = "Buying Shady Rod at the Bazaar stand...",
}
function SafeTotem.ShadyMessage(stepName, detail)
    local template = SafeTotem.ShadyMessages[stepName] or stepName
    if stepName == "figure" then return template:format(tostring(detail)) end
    if stepName == "grind" then return template:format(SafeTotem.ShadyGuardLevel, SafeTotem.ShadyGuardCash) end
    if stepName == "coins" then return template:format(SafeTotem.ShadyRodPrice) end
    return template
end
getgenv().SelectedDayTotem = getgenv().SelectedDayTotem or ""
getgenv().SelectedNightTotem = getgenv().SelectedNightTotem or ""
local isFishing = false
function processTotem(totemName)
    if type(totemName) ~= "string" or totemName == "" or totemName:find("Select") then return false, "invalid" end
    if SafeTotem.Busy then return false, "busy" end
    local lp = LocalPlayer
    local character = lp.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false, "nochar" end
    if lp.PlayerGui:FindFirstChild("reel") or finishing == true then
        if _G.AutoMetronomeConnection then
            _G.AutoMetronomeConnection:Disconnect()
            _G.AutoMetronomeConnection = nil
        end
        task.spawn(function()
            pcall(resetRodNew)
        end)
        task.wait(1)
    end
    local heldTool = character:FindFirstChildOfClass("Tool")
    local heldName = heldTool and heldTool.Name ~= totemName and heldTool.Name or nil
    local totemTool = SafeTotem.Ensure(totemName, SafeTotem.RestockEnabled())
    if not totemTool then
        if not SafeTotem.RestockEnabled() then
            SafeTotem.Notify(totemName .. " not in backpack. Enable Restock Totem From Stand or buy it first.")
        end
        return false, "missing"
    end
    character = lp.Character
    humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false, "nochar" end
    local countBefore = SafeTotem.CountOwned(totemName)
    humanoid:UnequipTools()
    task.wait(0.3)
    if not totemTool.Parent then totemTool = SafeTotem.FindOwned(totemName) end
    if not totemTool then return false, "missing" end
    humanoid:EquipTool(totemTool)
    task.wait(0.3)
    local used = false
    for _ = 1, 3 do
        if totemTool.Parent ~= character then break end
        totemTool:Activate()
        local deadline = os.clock() + 1.5
        repeat
            task.wait(0.15)
            used = SafeTotem.CountOwned(totemName) < countBefore or totemTool.Parent == nil
        until used or os.clock() > deadline
        if used then break end
    end
    task.wait(0.3)
    if totemTool.Parent == character then humanoid:UnequipTools() end
    task.wait(0.2)
    local backpack = lp:FindFirstChild("Backpack")
    local restoreTool = heldName and backpack and backpack:FindFirstChild(heldName)
    if not restoreTool and backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:find("Rod") then restoreTool = tool break end
        end
    end
    if restoreTool then humanoid:EquipTool(restoreTool) end
    return used, used and "used" or "noeffect"
end
totemOptions = {
    "Sundial Totem", "Aurora Totem", "Tempest Totem", "Smokescreen Totem",
    "Windset Totem", "Eclipse Totem", "Meteor Totem", "Blizzard Totem",
    "Avalanche Totem", "Zeus Storm Totem", "Poseidon Wrath Totem",
    "Mutation Totem", "Shiny Totem", "Sparkling Totem"
}
local totemConnection = nil
getgenv().SelectedSpamTotems = {}
local isSpamming = false
getgenv().AutoUsePotion = false
getgenv().PotionDelay = 1
task.spawn(function()
    while task.wait(1) do
        if getgenv().AutoUsePotion then
            local lp = game.Players.LocalPlayer
            local char = lp.Character
            local backpack = lp.Backpack
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            local playerGui = lp:WaitForChild("PlayerGui")
            if playerGui:FindFirstChild("reel") or finishing == true then
                task.spawn(function()
                    resetRodNew()
                end)
                task.wait(1)
            end
            if humanoid and backpack then
                local targetPotion = nil
                for _, tool in pairs(backpack:GetChildren()) do
                    if tool:IsA("Tool") and string.find(string.lower(tool.Name), "potion") then
                        targetPotion = tool
                        break
                    end
                end
                if targetPotion then
                    humanoid:UnequipTools()
                    task.wait(0.2)
                    humanoid:EquipTool(targetPotion)
                    task.wait(0.3)
                    targetPotion:Activate()
                    task.wait(0.5)
                    humanoid:UnequipTools()
                    local rod = backpack:FindFirstChildOfClass("Tool")
                    if rod then
                        humanoid:EquipTool(rod)
                    end
                    task.wait(getgenv().PotionDelay or 1)
                else
                    local holding = char:FindFirstChildOfClass("Tool")
                    if holding and string.find(string.lower(holding.Name), "potion") then
                        holding:Activate()
                        task.wait(0.5)
                        humanoid:UnequipTools()
                        local rod = backpack:FindFirstChildOfClass("Tool")
                        if rod then humanoid:EquipTool(rod) end
                        task.wait(getgenv().PotionDelay or 1)
                    end
                end
            end
        end
    end
end)
pcall(function()
    enchants = require(
        game:GetService("ReplicatedStorage").shared.modules.library.rods.enchants
    )
end)
enchants = enchants or {}
enchanList1 = {}
if enchants and enchants.Enchants then
    for name, _ in pairs(enchants.Enchants) do
        table.insert(enchanList1, name)
    end
end
local function hasSameEnchant()
    local success, result = pcall(function()
        local player = game:GetService("Players").LocalPlayer
        local playerGui = player:FindFirstChild("PlayerGui")
        if not playerGui then return false end
        local rodValuePath = workspace:FindFirstChild("PlayerStats")
        and workspace.PlayerStats:FindFirstChild(player.Name)
        and workspace.PlayerStats[player.Name]:FindFirstChild("T")
        and workspace.PlayerStats[player.Name].T:FindFirstChild(player.Name)
        and workspace.PlayerStats[player.Name].T[player.Name]:FindFirstChild("Stats")
        and workspace.PlayerStats[player.Name].T[player.Name].Stats:FindFirstChild("rod")
        if not rodValuePath then return false end
        local RodName = rodValuePath.Value
        hud = playerGui:FindFirstChild("hud")
        safezone = hud and hud:FindFirstChild("safezone")
        equipment = safezone and safezone:FindFirstChild("equipment")
        container = equipment and equipment:FindFirstChild("Container")
        rodsFolder = container and container:FindFirstChild("Rods")
        mainFolder = rodsFolder and rodsFolder:FindFirstChild("Main")
        scrollingFrame = mainFolder and mainFolder:FindFirstChild("ScrollingFrame")
        rodInstanceFolder = scrollingFrame and scrollingFrame:FindFirstChild(RodName)
        rodModel = rodInstanceFolder and rodInstanceFolder:FindFirstChild("Rod")
        enchantContainer = rodModel and rodModel:FindFirstChild("Enchants")
        if not enchantContainer then return false end
        for _, v in pairs(enchantContainer:GetChildren()) do
            if v:IsA("TextLabel") or v:IsA("TextButton") then
                for _, iv in pairs(targetEnc1) do
                    if string.find(v.Text, iv) then
                        return true
                    end
                end
            end
        end
        return false
    end)
    return success and result or false
end
local MutationModule = nil
pcall(function()
    MutationModule = require(
        ReplicatedStorage.shared.modules.fishing.mutations
    )
end)
local appraiseOptions = {"None"}
if MutationModule and MutationModule.Mutations then
    for mutationName, _ in pairs(MutationModule.Mutations) do
        table.insert(appraiseOptions, mutationName)
    end
end
table.sort(appraiseOptions, function(a, b)
    if a == "None" then
        return true
    elseif b == "None" then
        return false
    end
    return string.lower(a) < string.lower(b)
end)
local player = game.Players.LocalPlayer
local Net = ReplicatedStorage:WaitForChild("packages"):WaitForChild("Net")
local DialogInteract = Net:WaitForChild("RF/DialogInteract")
Appraise = false
selectAppraise = {}
selectAppraise1 = {}
function FireProximity(proximity)
    if proximity:IsA("ProximityPrompt") and proximity.Enabled then
        local oldHold = proximity.HoldDuration
        proximity.HoldDuration = 0
        pcall(function()
            proximity:InputHoldBegin()
            task.wait(0.22 + math.random() * 0.26)
            proximity:InputHoldEnd()
        end)
        proximity.HoldDuration = oldHold
    end
end
function autoEquipNewItem(item)
    if item and item:IsA("Tool") then
        local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:EquipTool(item)
        end
    end
end
local function _liyhubKeywordMatch(text, keyword)
    if type(text) ~= "string" or type(keyword) ~= "string" then return false end
    if keyword == "" then return false end
    return string.find(string.lower(text), string.lower(keyword), 1, true) ~= nil
end
local function _liyhubToList(value)
    local list = {}
    if type(value) == "string" then
        if value ~= "" and value ~= "None" then table.insert(list, value) end
        return list
    end
    if type(value) ~= "table" then return list end
    if #value > 0 then
        for _, entry in ipairs(value) do
            if type(entry) == "string" and entry ~= "" and entry ~= "None" then
                table.insert(list, entry)
            end
        end
        return list
    end
    for key, flag in pairs(value) do
        if flag == true and type(key) == "string" and key ~= "" and key ~= "None" then
            table.insert(list, key)
        end
    end
    return list
end
local function _liyhubNormalizeMutation(text)
    if type(text) ~= "string" then return "" end
    return (string.lower(text):gsub("[%s%p]", ""))
end
local function _liyhubInventoryData()
    local ok, inventory = pcall(function()
        local dataController = require(ReplicatedStorage.client.legacyControllers.DataController)
        return dataController.InventoryReplicator:Index({ "Inventory" })
    end)
    if ok and type(inventory) == "table" then return inventory end
    return nil
end
local function _liyhubHeldMutationMatch(keywords)
    local character = player and player.Character
    local heldTool = character and character:FindFirstChildOfClass("Tool")
    if not heldTool or heldTool:FindFirstChild("events") then return nil, nil, nil, false end
    local inventory = _liyhubInventoryData()
    if not inventory then return nil, nil, nil, false end
    local link = heldTool:FindFirstChild("link")
    local entry = inventory[link and link.Value or heldTool.Name]
    local sub = type(entry) == "table" and entry.sub
    if type(sub) ~= "table" then return nil, nil, nil, false end
    local mutationKey = type(sub.Mutation) == "string" and sub.Mutation or nil
    local mutationDisplay = mutationKey
    if mutationKey and MutationModule and type(MutationModule.Mutations) == "table" then
        local info = MutationModule.Mutations[mutationKey]
        if type(info) == "table" and type(info.Display) == "string" then
            mutationDisplay = info.Display
        end
    end
    local normalizedKey = _liyhubNormalizeMutation(mutationKey)
    local normalizedDisplay = _liyhubNormalizeMutation(mutationDisplay)
    for _, keyword in ipairs(keywords) do
        local normalizedKeyword = _liyhubNormalizeMutation(keyword)
        if normalizedKeyword ~= "" then
            if normalizedKeyword == normalizedKey or normalizedKeyword == normalizedDisplay then
                return keyword, (mutationDisplay or keyword) .. " " .. heldTool.Name, heldTool, true
            end
            if normalizedKeyword == "shiny" and sub.Shiny == true then
                return keyword, "Shiny " .. heldTool.Name, heldTool, true
            end
            if normalizedKeyword == "sparkling" and sub.Sparkling == true then
                return keyword, "Sparkling " .. heldTool.Name, heldTool, true
            end
        end
    end
    return nil, nil, heldTool, true
end
local function _liyhubScanContainer(container, keywords)
    if not container then return nil end
    local ok, children = pcall(function() return container:GetChildren() end)
    if not ok or type(children) ~= "table" then return nil end
    for _, child in ipairs(children) do
        local itemName = child:FindFirstChild("ItemName")
        local text = itemName and itemName:IsA("TextLabel") and itemName.Text or child.Name
        if type(text) == "string" then
            for _, keyword in ipairs(keywords) do
                if _liyhubKeywordMatch(text, keyword) then
                    return keyword, text, child
                end
            end
        end
    end
    return nil
end
local function _liyhubScanBackpack(keywords)
    local bp = player and player:FindFirstChild("Backpack")
    local char = player and player.Character
    for _, container in ipairs({ bp, char }) do
        if container then
            for _, tool in ipairs(container:GetChildren()) do
                if tool:IsA("Tool") then
                    for _, keyword in ipairs(keywords) do
                        if _liyhubKeywordMatch(tool.Name, keyword) then
                            return keyword, tool.Name, tool
                        end
                    end
                end
            end
        end
    end
    return nil
end
local function _liyhubAnyMatch(keywords)
    keywords = _liyhubToList(keywords)
    if #keywords == 0 then return nil end
    local heldKeyword, heldText, heldTool, heldKnown = _liyhubHeldMutationMatch(keywords)
    if heldKeyword then return heldKeyword, heldText, heldTool, "Held" end
    if heldKnown then return nil end
    local gui = player and player:FindFirstChild("PlayerGui")
    local backpack = gui and gui:FindFirstChild("backpack")
    local hotbar = backpack and backpack:FindFirstChild("hotbar")
    local inventory = backpack and backpack:FindFirstChild("inventory")
    local itemContainer = inventory and inventory:FindFirstChild("itemContainer")
    local kw, text, obj = _liyhubScanContainer(hotbar, keywords)
    if kw then return kw, text, obj, "Hotbar" end
    kw, text, obj = _liyhubScanContainer(itemContainer, keywords)
    if kw then return kw, text, obj, "Inventory" end
    kw, text, obj = _liyhubScanBackpack(keywords)
    if kw then return kw, text, obj, "Backpack" end
    return nil
end
local function _liyhubAnyMatchStable(keywords, settleMin, settleMax, attempts)
    settleMin = settleMin or 0.35
    settleMax = settleMax or 0.6
    attempts = attempts or 3
    for i = 1, attempts do
        local kw, text, obj, source = _liyhubAnyMatch(keywords)
        if kw then return kw, text, obj, source end
        if i < attempts then
            task.wait(settleMin + math.random() * (settleMax - settleMin))
        end
    end
    return nil
end
local function _liyhubDialogInvoke(a, b)
    if not DialogInteract then return false end
    local ok = pcall(function() DialogInteract:InvokeServer(a, b) end)
    return ok
end
local function checkItemsMatch(container, name)
    for _, child in ipairs(container:GetChildren()) do
        local stroke = child:FindFirstChildOfClass("UIStroke")
        if stroke and stroke.Color == Color3.fromRGB(255, 255, 255) then
            local itemName = child:FindFirstChild("ItemName")
            if itemName and itemName.Text then
                local text = string.lower(itemName.Text)
                for _, keyword in ipairs(selectAppraise or {}) do
                    if string.find(text, string.lower(keyword), 1, true) then
                        return true
                    end
                end
            end
        end
    end
    return false
end
local APPRAISERS = {
    ["Appraiser"] = Vector3.new(453, 151, 207),
    ["Drowned Appraiser"] = Vector3.new(3165, -1100, 780),
    ["Shady Appraiser"] = Vector3.new(662, -755, -469)
}
local selectedAppraiser = "Appraiser"
local appraiseConnection
local function buildFischOptions()
    local opts = {}
    for _, tool in ipairs(player.Backpack:GetChildren()) do
        if not table.find(opts, tool.Name) then
            table.insert(opts, tool.Name)
        end
    end
    return opts
end
local netPkgAppr = ReplicatedStorage:FindFirstChild("packages") and ReplicatedStorage.packages:FindFirstChild("Net")
EventAppraiseGui = LocalPlayer.PlayerGui:FindFirstChild("EventAppraise")
AppraiseUI = EventAppraiseGui and EventAppraiseGui:FindFirstChild("EventAppraise")
StartAppraise = netPkgAppr and netPkgAppr:FindFirstChild("RE/EventAppraiseService/StartAppraise")
RequestUI = netPkgAppr and netPkgAppr:FindFirstChild("RE/EventAppraiseService/RequestAppraiseUI")
TakeNow = netPkgAppr and netPkgAppr:FindFirstChild("RE/EventAppraiseService/TakeNow")
SelectIndex = netPkgAppr and netPkgAppr:FindFirstChild("RF/EventAppraiseService/SelectIndex")
TOTAL_ROWS = 7
SLOTS_PER_ROW = 3
SelectedTreasure = "Big"
AutoAppraiseActive = false
mutationFilters = { "Big", "Giant" }
function AutoSelectRow(rowIndex)
    startSlot = (rowIndex - 1) * SLOTS_PER_ROW + 1
    endSlot = startSlot + SLOTS_PER_ROW - 1
    for slot = startSlot, endSlot do
        success, result = pcall(function()
            return SelectIndex:InvokeServer(slot)
        end)
        if success and result then
            string.format(
                "[AutoAppraise] Row %d, Slot %d selected: %s",
                rowIndex,
                slot,
                tostring(result)
            )
            break
        end
    end
end
function WaitForAppraiseItems(timeout)
    timeout = timeout or 5
    timer = 0
    repeat
        ready = true
        for _, child in ipairs(AppraiseUI.List:GetChildren()) do
            itemName = child:FindFirstChild("ItemName")
            if not itemName or itemName.Text == "" then
                ready = false
                break
            end
        end
        if ready and #AppraiseUI.List:GetChildren() > 0 then
            break
        end
        task.wait(0.1)
        timer = timer + 0.1
    until timer >= timeout
end
function CheckMutationsInventory()
    player = Players.LocalPlayer
    hotbar =
    player.PlayerGui:WaitForChild("backpack"):WaitForChild("hotbar")
    inventory = player.PlayerGui.backpack
    :WaitForChild("inventory")
    :WaitForChild("itemContainer")
    function checkContainer(container, name)
        for _, child in ipairs(container:GetChildren()) do
            stroke = child:FindFirstChildOfClass("UIStroke")
            if
            stroke
            and stroke.Color == Color3.fromRGB(255, 255, 255)
            and child:FindFirstChild("ItemName")
            then
                text = child.ItemName.Text
                for _, keyword in ipairs(mutationFilters) do
                    if
                    string.find(string.lower(text), string.lower(keyword))
                    then
                        if
                        string.lower(keyword)
                        ~= string.lower(SelectedTreasure)
                        then
                            AutoAppraiseActive = false
                            return true
                        else
                        end
                    end
                end
            end
        end
        return false
    end
    return checkContainer(hotbar, "hotbar")
    or checkContainer(inventory, "inventory")
end
function CheckMutationUI(filter)
    WaitForAppraiseItems(5)
    for _, child in ipairs(AppraiseUI.List:GetChildren()) do
        itemName = child:FindFirstChild("ItemName")
        if itemName and itemName.Text ~= "" then
            for _, keyword in ipairs(mutationFilters) do
                if
                string.find(
                    string.lower(itemName.Text),
                    string.lower(keyword)
                )
                then
                    if
                    string.lower(keyword)
                    ~= string.lower(SelectedTreasure)
                    then
                        AutoAppraiseActive = false
                        return true
                    end
                end
            end
        end
    end
    return false
end
function StartAutoAppraise(filter)
    if CheckMutationsInventory() then
        return
    end
    RequestUI:FireServer()
    task.wait(0.3)
    StartAppraise:FireServer()
    task.wait(0.5)
    for row = 1, TOTAL_ROWS do
        if not AutoAppraiseActive then
            break
        end
        AutoSelectRow(row)
        task.wait(0.1)
        if CheckMutationsInventory() then
            return
        end
    end
    if not AutoAppraiseActive then
        return
    end
    if CheckMutationUI(filter) then
        return
    end
    TakeNow:FireServer()
end
Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
HRP = Character and (Character:FindFirstChild("HumanoidRootPart") or Character:WaitForChild("HumanoidRootPart", 2))
Humanoid = Character and (Character:FindFirstChild("Humanoid") or Character:WaitForChild("Humanoid", 2))
function getHousesFolder()
    world = workspace:FindFirstChild("world")
    if not world then
        return nil
    end
    map = world:FindFirstChild("map")
    if not map then
        return nil
    end
    crook = map:FindFirstChild("Crook's Hallow")
    if not crook then
        return nil
    end
    houses = crook:FindFirstChild("Houses")
    return houses
end
KNOCK_COUNT = 10
KNOCK_DELAY = 0.2
STAY_DELAY = 8
AutoKnockActive = false
function FreezeCharacter()
    Humanoid.PlatformStand = true
    bp = Instance.new("BodyPosition")
    bp.Position = HRP.Position
    bp.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bp.P = 1e5
    bp.Name = "FreezeBP"
    bp.Parent = HRP
end
function UnfreezeCharacter()
    Humanoid.PlatformStand = false
    bp = HRP:FindFirstChild("FreezeBP")
    if bp then
        bp:Destroy()
    end
end
function KnockDoor(doorBase)
    if not AutoKnockActive then
        return
    end
    prompt = doorBase:FindFirstChild("ProximityPrompt")
    if not prompt then
        return
    end
    FreezeCharacter()
    HRP.CFrame = CFrame.new(doorBase.Position + Vector3.new(0, 0, -2))
    UnfreezeCharacter()
    for i = 1, KNOCK_COUNT do
        if not AutoKnockActive then
            break
        end
        prompt:InputHoldBegin()
        task.wait(KNOCK_DELAY)
        prompt:InputHoldEnd()
        task.wait(KNOCK_DELAY)
    end
    if AutoKnockActive then
        task.wait(STAY_DELAY)
    end
end
function AutoKnock()
    while AutoKnockActive do
        HousesFolder = getHousesFolder()
        if HousesFolder then
            for _, house in ipairs(HousesFolder:GetChildren()) do
                if not AutoKnockActive then
                    break
                end
                if house:IsA("Model") then
                    for _, obj in ipairs(house:GetDescendants()) do
                        if not AutoKnockActive then
                            break
                        end
                        if
                        obj:IsA("Model")
                        and obj:FindFirstChild("Base")
                        and obj.Base:FindFirstChild("ProximityPrompt")
                        then
                            KnockDoor(obj.Base)
                        end
                    end
                end
            end
        else
            warn(
                "[AutoKnock] HousesFolder belum ditemukan, menunggu area dimuat..."
            )
        end
        task.wait(1)
    end
    UnfreezeCharacter()
end
_G.ThanHub_CurrentTarget = _G.ThanHub_CurrentTarget or "Idle"
function ThanHub_RefreshDashboard()
    local ThanHub_Ok, ThanHub_Err = pcall(function()
        local ThanHub_Output = ""
        ThanHub_Output ..= "\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\10"
        if _G.ThanHub_CurrentTarget == "Idle" or _G.ThanHub_CurrentTarget == "Fishing" then
            local Player = game.Players.LocalPlayer
            local Char = Player.Character
            local Tool = Char and Char:FindFirstChildOfClass("Tool")
            if Tool and (string.find(Tool.Name, "Rod") or Tool:FindFirstChild("bobber")) then
                _G.ThanHub_CurrentTarget = "Fishing"
            else
                _G.ThanHub_CurrentTarget = "Idle"
            end
        end
        local Than_DC = require(game:GetService("ReplicatedStorage").client.legacyControllers.DataController)
        local Than_Inv = Than_DC.fetch("Inventory")
        local T_Total, T_Ready, T_Broken = 0, 0, 0
        for _, Than_Item in pairs(Than_Inv) do
            if string.find(Than_Item.name, "Treasure Map") then
                T_Total = T_Total + 1
                if Than_Item.sub and Than_Item.sub.Repaired == true then
                    T_Ready = T_Ready + 1
                else
                    T_Broken = T_Broken + 1
                end
            end
        end
        ThanHub_Output ..= string.format("<b>Treasure Map</b>: %d Total\10", T_Total)
        ThanHub_Output ..= string.format("\226\128\162 Ready: <font color='#00FF00'>%d</font>\10", T_Ready)
        ThanHub_Output ..= string.format("\226\128\162 Broken: <font color='#FF4444'>%d</font>\10", T_Broken)
        ThanHub_Output ..= "\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\10"
        local ActionColor = "#FFFF00"
        if _G.ThanHub_CurrentTarget == "Fishing" then ActionColor = "#00AAFF" end
        if _G.ThanHub_CurrentTarget == "Idle" then ActionColor = "#AAAAAA" end
        ThanHub_Output ..= string.format("<b>Current Action</b>: <font color='%s'>%s</font>\10", ActionColor, _G.ThanHub_CurrentTarget)
        if ThanHub_InfoDisplay and ThanHub_InfoDisplay.Set then
            ThanHub_InfoDisplay:Set({
                Title = "ThanHub | Treasure Map",
                Content = ThanHub_Output,
                RichText = true,
                TextWrapped = true,
            })
        end
    end)
    if not ThanHub_Ok then
    end
end
task.spawn(function()
    while true do
        ThanHub_RefreshDashboard()
        task.wait(0.5)
    end
end)
_G.ExecutingHatch = false
NetPackage = nil
RemoteFinish = nil
RemoteCompleteLap = nil
RemoteJoin = nil
pcall(function()
    NetPackage = require(ReplicatedStorage:WaitForChild("packages", 2):WaitForChild("Net", 2))
    RemoteFinish = NetPackage:RemoteEvent("JetskiRacing/FinishRace")
    RemoteCompleteLap = NetPackage:RemoteEvent("JetskiRacing/CompleteLap")
    RemoteJoin = NetPackage:RemoteEvent("JetskiRacing/JoinRace")
end)
AutoJoinJetski = false
AutoWinEnabled = false
BoatSpeedMultiplier = 1.5
InstantTurnEnabled = false
function getCurrentTrack()
    tracksFolder = workspace:FindFirstChild("world")
    and workspace.world:FindFirstChild("map")
    and workspace.world.map:FindFirstChild("Fischfest")
    and workspace.world.map.Fischfest:FindFirstChild("JetskiRacingTracks")
    if tracksFolder then
        for _, track in pairs(tracksFolder:GetChildren()) do
            if track:IsA("Folder") and #track:GetChildren() > 0 then
                return track
            end
        end
    end
    return nil
end
task.spawn(function()
    while task.wait(0.5) do
        if AutoWinEnabled then
            currentTrack = getCurrentTrack()
            character = LocalPlayer.Character
            hrp = character and character:FindFirstChild("HumanoidRootPart")
            gates = currentTrack and (currentTrack:FindFirstChild("Checkpoints") or currentTrack:FindFirstChild("Gates"))
            if hrp and gates then
                checkpointList = gates:GetChildren()
                table.sort(checkpointList, function(a, b)
                    return (tonumber(a.Name) or 0) < (tonumber(b.Name) or 0)
                end)
                for _, checkpoint in ipairs(checkpointList) do
                    if not AutoWinEnabled then break end
                    if checkpoint:IsA("BasePart") then
                        tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Linear)
                        tween = TweenService:Create(hrp, tweenInfo, {CFrame = checkpoint.CFrame})
                        tween:Play()
                        tween.Completed:Wait()
                        task.wait(0.05)
                    end
                end
                RemoteCompleteLap:FireServer()
                task.wait(0.2)
                RemoteFinish:FireServer()
            end
        end
    end
end)
BoatController = nil
pcall(function()
    legacyControllers = ReplicatedStorage:WaitForChild("client"):WaitForChild("legacyControllers")
    BoatController = require(legacyControllers:WaitForChild("BoatController"))
end)
task.spawn(function()
    while task.wait(1) do
        if BoatController and BoatController.Physics and BoatController.Physics.currentBoat then
            boatObj = BoatController.Physics.currentBoat
            if boatObj.Instance and boatObj.Instance:FindFirstChild("VehicleSeat") then
                seat = boatObj.Instance.VehicleSeat
                if seat:GetAttribute("OriginalMaxSpeed") == nil then
                    seat:SetAttribute("OriginalMaxSpeed", seat.MaxSpeed)
                end
                seat.MaxSpeed = seat:GetAttribute("OriginalMaxSpeed") * BoatSpeedMultiplier
            end
            if InstantTurnEnabled and boatObj.AlignmentTorque then
                boatObj.AlignmentTorque.MaxTorque = 999999
                boatObj.AlignmentTorque.Responsiveness = 200
            end
        end
    end
end)
Players = game:GetService("Players")
_G.AutoFarmShell = false
ReplicatedStorage = game:GetService("ReplicatedStorage")
GuiService = game:GetService("GuiService")
Camera = workspace.CurrentCamera
lp = Players.LocalPlayer
SafeTotem.AnglerSpots = {
    ["Moosewood Village"] = CFrame.new(481, 151, 299),
    ["Roslit Hamlet"] = CFrame.new(-1512, 140, 688),
    ["Sunstone Island"] = CFrame.new(-885, 135, -1115),
    ["Terrapin Island"] = CFrame.new(-153, 144, 1954),
    ["The Depths"] = CFrame.new(980, -700, 1230),
    ["Ancient Isles"] = CFrame.new(5737, 177, -57),
    ["Forsaken Shores"] = CFrame.new(-2702, 169, 1798),
    ["Crimson Cavern"] = CFrame.new(-1069, -361, -4811),
    ["Luminescent Cavern"] = CFrame.new(-1050, -337, -4078),
    ["Lost Jungle"] = CFrame.new(-2726, 226, -2186),
    ["Shady Angler"] = CFrame.new(-2925.80933, -1032.79639, 5900.86816),
}
SafeTotem.AnglerOptions = {}
for spotName in pairs(SafeTotem.AnglerSpots) do table.insert(SafeTotem.AnglerOptions, spotName) end
table.sort(SafeTotem.AnglerOptions)
table.insert(SafeTotem.AnglerOptions, 1, "Auto Detect")
SafeTotem.AnglerEnabled = false
SafeTotem.AnglerToken = 0
SafeTotem.AnglerChoice = "Auto Detect"
SafeTotem.AnglerFishTarget = false
SafeTotem.AnglerSaved = nil
SafeTotem.AnglerSkip = { AutoComplete = true, Icon = true, Tracking = true }
SafeTotem.AnglerAcceptWords = { "yes", "sure", "job", "accept", "take", "quest", "help" }
SafeTotem.AnglerTurnInWords = { "here", "turn", "submit", "complete", "caught", "fish", "yes" }
SafeTotem.AnglerFishingKeys = { "autoCastEnabled", "autoShakeEnabled", "autoReelEnabled" }
function SafeTotem.AnglerQuest()
    local stats = workspace:FindFirstChild("PlayerStats")
    local mine = stats and stats:FindFirstChild(LocalPlayer.Name)
    local tFolder = mine and mine:FindFirstChild("T")
    local nested = tFolder and tFolder:FindFirstChild(LocalPlayer.Name)
    for _, holder in ipairs({ nested, mine }) do
        local quests = holder and holder:FindFirstChild("Quests")
        if quests then
            for _, quest in ipairs(quests:GetChildren()) do
                if quest.Name:find("Angler Quest", 1, true) then
                    local target
                    for _, child in ipairs(quest:GetChildren()) do
                        if not SafeTotem.AnglerSkip[child.Name] and not child.Name:find("_Goal", 1, true) then
                            target = child.Name
                            break
                        end
                    end
                    local okValue, value = pcall(function() return tostring(quest.Value) end)
                    return { Name = quest.Name, Target = target, Hint = okValue and value or "" }
                end
            end
        end
    end
    return nil
end
function SafeTotem.AnglerSpotFor(quest)
    if SafeTotem.AnglerChoice ~= "Auto Detect" and SafeTotem.AnglerSpots[SafeTotem.AnglerChoice] then
        return SafeTotem.AnglerChoice
    end
    local hint = quest and quest.Hint:lower() or ""
    if hint == "" then return nil end
    for spotName in pairs(SafeTotem.AnglerSpots) do
        local head = spotName:lower():gsub("^the ", ""):match("^(%S+)")
        if head and hint:find(head, 1, true) then return spotName end
    end
    return nil
end
function SafeTotem.FindAngler(anchor)
    local best, bestPrompt, bestDistance = nil, nil, 80
    local pool = game:GetService("CollectionService"):GetTagged("NewNpc")
    local npcs = workspace:FindFirstChild("world") and workspace.world:FindFirstChild("npcs")
    if npcs then
        for _, npc in ipairs(npcs:GetChildren()) do table.insert(pool, npc) end
    end
    for _, npc in ipairs(pool) do
        if npc:IsA("Model") and (npc:GetAttribute("NpcType") == "Angler" or npc.Name:lower():find("angler", 1, true)) then
            local prompt = npc:FindFirstChildWhichIsA("ProximityPrompt", true)
            local ok, pivot = pcall(npc.GetPivot, npc)
            if prompt and ok then
                local distance = (pivot.Position - anchor).Magnitude
                if distance < bestDistance then best, bestPrompt, bestDistance = npc, prompt, distance end
            end
        end
    end
    return best, bestPrompt
end
function SafeTotem.AnglerTalk(spotName, words)
    local anchor = SafeTotem.AnglerSpots[spotName].Position
    SafeTotem.StreamAround(anchor)
    local root = SafeTotem.GetRoot()
    if not root then return "nochar" end
    if getgenv().LiyhubQuestKit and getgenv().LiyhubQuestKit.ForceLeaveDialog then
        getgenv().LiyhubQuestKit.ForceLeaveDialog()
        task.wait(0.2 + math.random() * 0.2)
    else
        pcall(SafeTotem.LeaveDialog)
        task.wait(0.25)
    end
    pcall(function() root.AssemblyLinearVelocity = Vector3.zero end)
    local target = CFrame.new(anchor + Vector3.new(0, 2, 0))
    local sm = getgenv().LiyhubSafeMotion
    if sm and sm.Teleport then
        sm.Teleport(root, target)
    else
        root.CFrame = target
    end
    local npc, prompt
    local deadline = os.clock() + 8
    repeat
        npc, prompt = SafeTotem.FindAngler(anchor)
        if not npc then task.wait(0.3) end
    until npc or os.clock() > deadline
    if not npc then return "nonpc" end
    local approached, reason = SafeTotem.ApproachModel(npc, prompt)
    if not approached then return reason end
    if not prompt.Enabled then
        if getgenv().LiyhubQuestKit and getgenv().LiyhubQuestKit.ForceLeaveDialog then
            getgenv().LiyhubQuestKit.ForceLeaveDialog()
        end
        task.wait(0.3 + math.random() * 0.25)
        if not prompt.Enabled then return "noprompt" end
    end
    if SafeTotem.DryRun then return "dryrun" end
    local QK = getgenv().LiyhubQuestKit
    if QK and QK.HumanPromptHold then
        QK.HumanPromptHold(prompt)
    else
        pcall(fireproximityprompt, prompt)
    end
    local pressed = 0
    for pass = 1, 3 do
        local choices = SafeTotem.WaitChoices(pressed == 0 and 3.5 or 2.0)
        if #choices == 0 then break end
        local target
        for _, choice in ipairs(choices) do
            if SafeTotem.HasWord(choice.Text, words) then target = choice break end
        end
        if not target then break end
        SafeTotem.PressChoice(target)
        pressed += 1
        task.wait(0.8 + math.random() * 0.45)
    end
    if getgenv().LiyhubQuestKit and getgenv().LiyhubQuestKit.ForceLeaveDialog then
        getgenv().LiyhubQuestKit.ForceLeaveDialog()
    else
        SafeTotem.LeaveDialog()
    end
    return pressed > 0 and "talked" or "nochoice"
end
function SafeTotem.AnglerZoneFor(quest)
    local zones = workspace:FindFirstChild("zones")
    local folder = zones and zones:FindFirstChild("fishing")
    if not folder or not quest then return nil end
    local hint = quest.Hint:lower()
    if hint == "" then return nil end
    local fallback
    for _, zone in ipairs(folder:GetChildren()) do
        local zoneName = zone.Name:lower()
        if hint:find(zoneName, 1, true) then return zone end
        local head = zoneName:match("^(%S+)")
        if not fallback and head and #head > 3 and hint:find(head, 1, true) then fallback = zone end
    end
    return fallback
end
function SafeTotem.AnglerZoneCFrame(zone)
    local part = zone:IsA("BasePart") and zone or zone:FindFirstChildWhichIsA("BasePart", true)
    if not part then return nil end
    return CFrame.new(part.Position.X, part.Position.Y + part.Size.Y / 2 + 3, part.Position.Z)
end
function SafeTotem.AnglerSetFishing(enabled)
    if enabled then
        if SafeTotem.AnglerSaved then return end
        SafeTotem.AnglerSaved = {}
        for _, key in ipairs(SafeTotem.AnglerFishingKeys) do
            SafeTotem.AnglerSaved[key] = _sX[key]
            _sX[key] = true
        end
        StartAutoFishing()
        pcall(Collection.StartExistingShake, Collection)
        return
    end
    if not SafeTotem.AnglerSaved then return end
    for key, value in pairs(SafeTotem.AnglerSaved) do _sX[key] = value end
    SafeTotem.AnglerSaved = nil
end
function SafeTotem.AnglerStatusText(quest, action)
    local target = quest and quest.Target or "None"
    local owned = quest and quest.Target and SafeTotem.FindOwned(quest.Target) ~= nil
    return string.format(
        "Quest: %s\10Target fish: %s\10Have fish: %s\10Angler: %s\10Status: %s",
        quest and quest.Name or "None", target, owned and "yes" or "no",
        SafeTotem.AnglerSpotFor(quest) or "unknown", action or "Idle"
    )
end
function SafeTotem.AnglerReport(action)
    local paragraph = SafeTotem.AnglerParagraph
    if not paragraph or not paragraph.SetContent then return end
    pcall(paragraph.SetContent, paragraph, SafeTotem.AnglerStatusText(SafeTotem.AnglerQuest(), action))
end
function SafeTotem.AnglerVisit(spotName, words, fishTool)
    if SafeTotem.Busy then return "busy" end
    local root = SafeTotem.GetRoot()
    if not root then return "nochar" end
    SafeTotem.Busy = true
    local origin = root.CFrame
    local ok, result = pcall(function()
        if fishTool and fishTool.Parent then
            local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid:EquipTool(fishTool) end
            task.wait(0.3 + math.random() * 0.35)
        end
        return SafeTotem.AnglerTalk(spotName, words)
    end)
    local returnRoot = SafeTotem.GetRoot()
    if returnRoot then
        pcall(function() returnRoot.AssemblyLinearVelocity = Vector3.zero end)
        local sm = getgenv().LiyhubSafeMotion
        if sm and sm.Teleport then
            sm.Teleport(returnRoot, origin)
        else
            returnRoot.CFrame = origin
        end
    end
    SafeTotem.Busy = false
    return ok and result or "error"
end
function SafeTotem.AnglerLoop(token)
    local function active()
        return SafeTotem.AnglerEnabled and SafeTotem.AnglerToken == token
    end
    local failures, stopMessage, fishingTarget = 0, nil, nil
    while active() do
        local quest = SafeTotem.AnglerQuest()
        local spotName = SafeTotem.AnglerSpotFor(quest)
        local fishTool = quest and quest.Target and SafeTotem.FindOwned(quest.Target)
        if not quest or fishTool then
            SafeTotem.AnglerSetFishing(false)
            fishingTarget = nil
            if not spotName then
                stopMessage = quest and "Could not tell which angler gave this quest. Pick the Angler Location." or "Pick an Angler Location to take a new quest."
                break
            end
            SafeTotem.AnglerReport(quest and ("Turning in " .. quest.Target .. " at " .. spotName) or ("Taking quest at " .. spotName))
            local result = SafeTotem.AnglerVisit(spotName, quest and SafeTotem.AnglerTurnInWords or SafeTotem.AnglerAcceptWords, fishTool)
            if result == "dryrun" then
                stopMessage = SafeTotem.ExplainService("Angler quest", "dryrun")
                break
            end
            if result ~= "busy" then
                task.wait(1.6 + math.random() * 0.9)
                local after = SafeTotem.AnglerQuest()
                local progressed = quest == nil and after ~= nil or quest ~= nil and (after == nil or after.Target ~= quest.Target or not SafeTotem.FindOwned(quest.Target))
                failures = progressed and 0 or failures + 1
                if failures >= 3 then
                    stopMessage = "Angler quest stuck. " .. SafeTotem.ExplainService("Angler", result)
                    break
                end
            end
        elseif quest.Target then
            if SafeTotem.AnglerFishTarget and fishingTarget ~= quest.Target and not SafeTotem.Busy then
                local zone = SafeTotem.AnglerZoneFor(quest)
                local zoneFrame = zone and SafeTotem.AnglerZoneCFrame(zone)
                local root = SafeTotem.GetRoot()
                if zoneFrame and root then
                    SafeTotem.StreamAround(zoneFrame.Position)
                    pcall(function() root.AssemblyLinearVelocity = Vector3.zero end)
                    local sm = getgenv().LiyhubSafeMotion
                    if sm and sm.Teleport then
                        sm.Teleport(root, zoneFrame)
                    else
                        root.CFrame = zoneFrame
                    end
                    task.wait(0.8 + math.random() * 0.6)
                    SafeTotem.AnglerSetFishing(true)
                end
                fishingTarget = quest.Target
            end
            SafeTotem.AnglerReport("Need " .. quest.Target .. (SafeTotem.AnglerSaved and " (fishing)" or ""))
            task.wait(1.6 + math.random() * 0.9)
        else
            SafeTotem.AnglerReport("Quest has no target fish yet")
            task.wait(1.6 + math.random() * 0.9)
        end
        task.wait(0.8 + math.random() * 0.6)
    end
    SafeTotem.AnglerSetFishing(false)
    if SafeTotem.AnglerToken ~= token then return end
    SafeTotem.AnglerEnabled = false
    SafeTotem.AnglerReport(stopMessage or "Stopped")
    if stopMessage then SafeTotem.Notify(stopMessage) end
end
pcall(function()
    Net = require(game:GetService("ReplicatedStorage").packages.Net)
end)
CollectionService = game:GetService("CollectionService")
LocalPlayer = game.Players.LocalPlayer
MiningRemote = nil
pcall(function()
    MiningRemote = Net and Net["RE/MiningService/UpdateMineableState"]
end)
autoMineEnabled = false
autoMineRunning = false
local function isStoneMineable(stone)
    local ok, mineable = pcall(function()
        return stone:IsA("BasePart") and stone.Parent ~= nil and stone.LocalTransparencyModifier < 1
    end)
    return ok and mineable == true
end
function getMiningData()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil, 0 end
    local closest, shortestDist, availableCount = nil, math.huge, 0
    for _, stone in ipairs(CollectionService:GetTagged("Mineable")) do
        if isStoneMineable(stone) then
            availableCount += 1
            local dist = (root.Position - stone.Position).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                closest = stone
            end
        end
    end
    return closest, availableCount
end
local lastMineStatusText = nil
task.spawn(function()
    while true do
        local _, total = getMiningData()
        local statusText = total > 0
        and ("<font color='#00FF00'>READY</font> [" .. total .. "]")
        or "<font color='#FF0000'>TIDAK ADA BATU</font>"
        if statusText ~= lastMineStatusText and MineStatusParagraph then
            lastMineStatusText = statusText
            pcall(function()
                MineStatusParagraph:Set({
                    Title = "MINING STATUS",
                    Content = "Status: " .. statusText,
                    RichText = true
                })
            end)
        end
        task.wait(1)
    end
end)
function runAutoMine()
    if autoMineRunning then return end
    autoMineRunning = true
    while autoMineEnabled do
        local targetStone = getMiningData()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local mineId = targetStone and targetStone:GetAttribute("MineableId")
        if root and mineId and MiningRemote then
            pcall(function()
                root.CFrame = targetStone.CFrame * CFrame.new(0, 4, 0)
            end)
            task.wait(0.2)
            local mineDeadline = os.clock() + 12
            while autoMineEnabled and isStoneMineable(targetStone) and os.clock() < mineDeadline do
                if not root.Parent then break end
                pcall(MiningRemote.FireServer, MiningRemote, mineId)
                task.wait(0.15)
                if (root.Position - targetStone.Position).Magnitude > 10 then
                    pcall(function()
                        root.CFrame = targetStone.CFrame * CFrame.new(0, 4, 0)
                    end)
                end
            end
        end
        task.wait(0.5)
    end
    autoMineRunning = false
end
local lastInventoryValueText = nil
function updateInventory()
    pcall(function()
        if not InventoryValueParagraph or not InventoryValueParagraph.SetTitle then return end
        local valueText = "Inventory Value : " .. FormatNumber(getPlayerValue(LocalPlayer.Name))
        if valueText == lastInventoryValueText then return end
        lastInventoryValueText = valueText
        InventoryValueParagraph:SetTitle(valueText)
    end)
end
task.spawn(function()
    while true do
        updateInventory()
        task.wait(2)
    end
end)
function startAutoReady()
    if _sX.autoReadyRunning then return end
    _sX.autoReadyRunning = true
    task.spawn(function()
        local netFolder = ReplicatedStorage:FindFirstChild("packages")
        and ReplicatedStorage.packages:FindFirstChild("Net")
        local setReady = netFolder and netFolder:FindFirstChild("RE/Trade/SetReady")
        while _sX.autoReady and setReady do
            pcall(setReady.FireServer, setReady, true)
            task.wait(0.5)
        end
        _sX.autoReadyRunning = false
    end)
end
local KnownAreaPositions = {
    ["Moosewood"] = Vector3.new(482.25, 164.67, 385.08),
    ["Moosewood Village"] = Vector3.new(467, 150.93, 257),
    ["Roslit"] = Vector3.new(-1493.45, 160.93, 593.55),
    ["Roslit Bay"] = Vector3.new(-1475, 133, 680),
    ["Roslit Hamlet"] = Vector3.new(-1512, 140, 688),
    ["Roslit Volcano"] = Vector3.new(-1984.22, 183.21, 278.15),
    ["Sunstone"] = Vector3.new(-794.91, 151.05, -1334.59),
    ["Sunstone Island"] = Vector3.new(-935, 132, -1125),
    ["Snowcap"] = Vector3.new(2815.53, 164.78, 2808.99),
    ["Snowcap Island"] = Vector3.new(2625, 135, 2370),
    ["Terrapin"] = Vector3.new(152.29, 169.96, 2004.01),
    ["Terrapin Island"] = Vector3.new(-185, 134, 1940),
    ["Mushgrove"] = Vector3.new(2670.82, 164.73, -716.37),
    ["Mushgrove Swamp"] = Vector3.new(2450, 131, -730),
    ["Ancient Isle"] = Vector3.new(5965.37, 258.97, 223.25),
    ["Ancient Isles"] = Vector3.new(5737, 177, -57),
    ["Forsaken Shores"] = Vector3.new(-2419.74, 161.91, 1440.13),
    ["The Depths"] = Vector3.new(990, -710, 1240),
    ["Vertigo"] = Vector3.new(-161.66, -705.02, 1205.99),
    ["Desolate Deep"] = Vector3.new(-1575.01, -200.17, -2904.31),
    ["Brine Pool"] = Vector3.new(-1788.16, -114.06, -3385.05),
    ["Keepers Altar"] = Vector3.new(1330.08, -806.82, -122.73),
    ["Atlantis"] = Vector3.new(-4319.76, -603.71, 1716.2),
    ["Crimson Cavern"] = Vector3.new(-998.65, -335.17, -4886.02),
    ["Luminescent Cavern"] = Vector3.new(-1018.35, -310.09, -4285.75),
    ["Lost Jungle"] = Vector3.new(-2869.57, 165.2, -2181.57),
    ["Shady Angler"] = Vector3.new(-2925, -1032, 5900),
    ["Mossjaw Rest"] = Vector3.new(-4915.6, -1791.5, -10151.1),
    ["Harvester's Meadow"] = Vector3.new(1250, 140, 550),
    ["Birch Cay"] = Vector3.new(1740, 145.24, -2419),
    ["Abaia"] = Vector3.new(3407.02, 1570.99, 954.06),
    ["Abaia's chamber"] = Vector3.new(3369.32, 1560.19, 929.4),
    ["Above The Clouds Roaming"] = Vector3.new(1492.58, 2600.98, -1725.95),
    ["Abovetheclouds"] = Vector3.new(1488.96, 2605.99, -1720.06),
    ["Abyssal Zenith-Astral Cavern"] = Vector3.new(-13810, -11541, 106.92),
    ["Abyssalzenith"] = Vector3.new(-13548.1, -11040, 123),
    ["Abyssalzenithastral"] = Vector3.new(-13806.1, -11544, 140),
    ["Aether"] = Vector3.new(-97, -646.01, 962.99),
    ["Altar"] = Vector3.new(1296.06, -802.01, -299.01),
    ["Ancient Archive"] = Vector3.new(-3163.59, -753.32, 1860.06),
    ["Ancient Archives"] = Vector3.new(5740, 135, 420),
    ["Ancient isle Pond"] = Vector3.new(6013.55, 225.6, 328.48),
    ["Ancient isle Waterfall"] = Vector3.new(5938.43, 266.03, 515.68),
    ["Ancient"] = Vector3.new(6055.77, 198.77, 277.83),
    ["Anglerfish Abyss"] = Vector3.new(-10673.1, -9314.01, 260.99),
    ["Apollo"] = Vector3.new(-8828.01, -2898.01, 659.93),
    ["Apollo's Song of Light"] = Vector3.new(-8846.62, -2876.13, 612.63),
    ["Arch"] = Vector3.new(997.98, 133.94, -1237.84),
    ["Ashbrook Town"] = Vector3.new(-5160, 137.99, -1452.02),
    ["Astral Observatory - Abyssal Zenith"] = Vector3.new(-13812.8, -11537.2, 116.06),
    ["Astral Observatory - Boreal Pines"] = Vector3.new(21879.2, -116.19, 4275.96),
    ["Astral Observatory - Everturn Forest"] = Vector3.new(2532.35, -94.21, -2486.47),
    ["Astral Observatory - Northern Expedition"] = Vector3.new(-1865.75, -228.91, 3944.43),
    ["Astral Observatory - Snowcap Island"] = Vector3.new(2658.75, -377.11, 2465.93),
    ["Atlantean Storm"] = Vector3.new(-3665.97, 163.61, 739.04),
    ["Atlantis Ocean"] = Vector3.new(-4373.66, -573.79, 1855.99),
    ["Azure Lagoon"] = Vector3.new(1310, 80, 2113),
    ["Bellona's Frenzy of War"] = Vector3.new(-8822.93, -2333.1, 927.94),
    ["Blue Moon"] = Vector3.new(2723.81, 160.92, 2530.07),
    ["Boreal Hollow"] = Vector3.new(849.78, -2580.61, 1602.86),
    ["Boreal Pines - Cave"] = Vector3.new(21720, 162.87, 3979.72),
    ["Boreal Pines - Ice Fishing"] = Vector3.new(21894.5, 162.87, 4236.98),
    ["Boreal Pines - Peak"] = Vector3.new(21370.7, 280.06, 3827.5),
    ["Boreal Pines"] = Vector3.new(21634.3, 161.87, 4130.44),
    ["Boreal Pines-Astral Cavern"] = Vector3.new(21871.1, -124.06, 4284.05),
    ["Boreal"] = Vector3.new(21822, 164.99, 4301),
    ["Borealastral"] = Vector3.new(21884.1, -139.01, 4215.96),
    ["Brine Pool Water"] = Vector3.new(-1788.51, -119.55, -3417.49),
    ["Calm Zone"] = Vector3.new(-4345.04, -11153, 3750.44),
    ["Carrot Garden"] = Vector3.new(3718.65, -1128.05, -1099.93),
    ["Castaway Cliffs"] = Vector3.new(690, 135, -1693),
    ["Castway Cliffs"] = Vector3.new(600.61, 191.04, -1859.15),
    ["Challanger's Deep"] = Vector3.new(775.03, -3331.04, -1641.02),
    ["Challenger's Deep"] = Vector3.new(732.13, -3363.06, -1628.91),
    ["Collapsed Ruins"] = Vector3.new(3141.63, -1068.53, 1644.13),
    ["Coral Bastion"] = Vector3.new(2512.75, -1076.03, 839),
    ["Crowned Ruins"] = Vector3.new(3125.87, -1107.03, 2153.71),
    ["Cryogenic Canal"] = Vector3.new(20068.4, 539.72, 5421.1),
    ["Cryogenic Canal-Astral Cavern"] = Vector3.new(-1850.07, -250.06, 3985.14),
    ["Crystal Cove"] = Vector3.new(1375.44, -576.03, 2337.07),
    ["Crystal Fissure"] = Vector3.new(21728, 142.92, 4002.83),
    ["Cultist Lair - Entrance"] = Vector3.new(49.99, -277, 1891.99),
    ["Cultist Lair"] = Vector3.new(4320.59, -1981.93, -4676.62),
    ["Cults Curse"] = Vector3.new(655, 2130, 16984),
    ["Cursed Isle"] = Vector3.new(1860, 135, 1210),
    ["Deep Ocean"] = Vector3.new(7665.12, 161.7, 552.53),
    ["Desolate Pocket"] = Vector3.new(-1650, -215, -2850),
    ["Desolete Deep Buoy"] = Vector3.new(-789.87, 64.77, -3102.24),
    ["Detonator's Rest"] = Vector3.new(-1404.19, -839.08, -3482.95),
    ["Dryland sand"] = Vector3.new(-6255.95, 215.15, -1376.75),
    ["Drylands"] = Vector3.new(-6305.26, 584.77, -1201.91),
    ["DuneHaven"] = Vector3.new(-6544.15, 233.97, -1835.28),
    ["Earmark Island"] = Vector3.new(1232.22, 208.77, 534.14),
    ["Emberreach"] = Vector3.new(2390, 83, -490),
    ["Enchantarchive"] = Vector3.new(736.93, -750.01, -538.02),
    ["Enchanted Crevice"] = Vector3.new(774.81, -735.05, -437.26),
    ["Ethereal Abyys"] = Vector3.new(-3754.2, -536.75, 1832.01),
    ["Ethereal Trial"] = Vector3.new(-3804.16, -660.22, 1830.06),
    ["Everturn Forest (Night)"] = Vector3.new(2542.15, 138.39, -2563.26),
    ["Everturn Forest"] = Vector3.new(2499.76, 162.64, -2560.83),
    ["Everturn Forest-Astral Cavern"] = Vector3.new(2521.25, -113.19, -2476.05),
    ["Everturn"] = Vector3.new(2397, 146.36, -2435),
    ["Executive Headquarter"] = Vector3.new(-38.44, -243.31, 206.45),
    ["Forgotten Temple"] = Vector3.new(-5126.56, -1749.63, -9845.25),
    ["Forsaken Shores ocean"] = Vector3.new(-3046.64, 161.66, 1451.26),
    ["Forsaken Shores Pond"] = Vector3.new(-2700.93, 195.26, 1748.89),
    ["Forsaken Veil"] = Vector3.new(-2383.57, -11193, 6865.13),
    ["Frigid Cavern"] = Vector3.new(19890.5, 464.62, 5607.77),
    ["Ghosts Tavern"] = Vector3.new(312.81, 801.56, -6890.95),
    ["Gilded Arch"] = Vector3.new(450, 90, 2850),
    ["Glacial Grotto"] = Vector3.new(20054.4, 909.54, 5639.11),
    ["Gloomy Crevice"] = Vector3.new(-127.87, -2498.21, -11490.8),
    ["Grand Reef"] = Vector3.new(-3576.44, 163.5, 541.85),
    ["Haddock Rock"] = Vector3.new(-551.18, 154.48, -464.37),
    ["Hades"] = Vector3.new(-8650, -4243.18, 433.99),
    ["Hall of Whispers"] = Vector3.new(4372.35, -2203.13, -4678.92),
    ["Harvesters Spike"] = Vector3.new(-1260, 134, 1570),
    ["Hawaii"] = Vector3.new(-1354.25, 135.14, -39953),
    ["Heaven"] = Vector3.new(1466.99, 9005, -1687.01),
    ["Inner Tidefall Castle"] = Vector3.new(4536.99, -1087.01, 922.99),
    ["Isle of New Beginnings"] = Vector3.new(-300, 83, -380),
    ["Isonade"] = Vector3.new(88.86, 231.95, -888.06),
    ["Kraken Lair"] = Vector3.new(-4292.13, -944.05, 2076.08),
    ["Kraken Pool"] = Vector3.new(-4289.72, -971.06, 2077.97),
    ["Lava"] = Vector3.new(-1966.38, 201.96, 274.74),
    ["Living Garden"] = Vector3.new(-2385.1, -289.98, -2907.18),
    ["Lower deep"] = Vector3.new(1592.8, -2796.73, -11735),
    ["Lushgrove"] = Vector3.new(1133, 105, -560),
    ["Mariana's Veil"] = Vector3.new(-5692.73, -7309.23, 590.01),
    ["Merlin's Hut"] = Vector3.new(-931, 225.72, -992.22),
    ["Mermaid Cove"] = Vector3.new(-3846.95, -1287.89, 499.85),
    ["Mineshaft"] = Vector3.new(-685.41, -833.97, -110.32),
    ["Monty's Lab"] = Vector3.new(-10260.7, -494.02, 993.96),
    ["Moosewood Pond"] = Vector3.new(525.99, 181.37, 285.76),
    ["Mossjaw"] = Vector3.new(-4853.76, -1761.14, -10164.5),
    ["Mushgrove Alligator"] = Vector3.new(2688.05, 125.99, -694.04),
    ["NectarDen"] = Vector3.new(-2028.5, -271.98, -3290.16),
    ["Netter's Haven"] = Vector3.new(-640, 85, 1030),
    ["Northern Expedition"] = Vector3.new(20000, 133, 5300),
    ["Northern"] = Vector3.new(19526, 132.67, 5292),
    ["Obsidian Pocket"] = Vector3.new(128.62, -6516.19, 66.84),
    ["Obsidian Trench"] = Vector3.new(-1681.06, -12328, -17.1),
    ["Ocean"] = Vector3.new(2092.97, 171.92, 962.88),
    ["Oil Rig"] = Vector3.new(-2450, 135, -1450),
    ["Olympian Fissure"] = Vector3.new(-8810.97, -4228.05, -361.6),
    ["Oscar's Locker"] = Vector3.new(193, -389.23, 3556),
    ["Outer Deep"] = Vector3.new(1034, -2392.11, -12849),
    ["Overgrowth Cave"] = Vector3.new(20307, 287.55, 5519.7),
    ["Passage of Oath"] = Vector3.new(4250.24, -2451.14, -4678.43),
    ["Personal Aquarium"] = Vector3.new(3699, 4252, 2999),
    ["Pine Shoals"] = Vector3.new(1165, 80, 480),
    ["Poseidon Pool"] = Vector3.new(-3984.79, -532.97, 935.67),
    ["Poseidon's Storm"] = Vector3.new(-8820, -3165.18, 738.61),
    ["Roslit Clam"] = Vector3.new(-1999.2, 161.72, 440.52),
    ["Roslit Pond"] = Vector3.new(-1807.58, 177.31, 596.82),
    ["RoslitBayVolcano"] = Vector3.new(-1969.48, 182.43, 275.43),
    ["Scoria Reach mining"] = Vector3.new(-4564.49, -678.42, -2074.49),
    ["Scoria Reach Volcano"] = Vector3.new(-5472.91, 201.31, -1546.8),
    ["Scoria Reach"] = Vector3.new(-4781, 138, -1378),
    ["Scoriamines"] = Vector3.new(-4721.51, -682.24, -2025.07),
    ["Shady Bazaar"] = Vector3.new(-2768, -1024.55, 6198),
    ["Shady"] = Vector3.new(-3037, -1029.41, 6041),
    ["Skycrest"] = Vector3.new(3371.8, 1552.6, 964.5),
    ["Snowburrow"] = Vector3.new(2759.4, 122.07, 2612.16),
    ["Snowcap Cave"] = Vector3.new(2860, 141.28, 2612),
    ["Snowcap ocean"] = Vector3.new(2216.19, 161.78, 2823.2),
    ["Snowcap Pond"] = Vector3.new(2796.6, 311.05, 2593.23),
    ["Statue of Sovereignty"] = Vector3.new(72, 141.92, -1029),
    ["Sunken Depth"] = Vector3.new(-4958.22, -566.32, 1824.81),
    ["Sunken Reliquary"] = Vector3.new(2945.73, -1080.02, -189.23),
    ["Sunstone Sundial"] = Vector3.new(-1143.6, 134.49, -1071.23),
    ["Terappinisland"] = Vector3.new(-144, 145.08, 1909),
    ["Terrapin ocean"] = Vector3.new(464.07, 165.78, 2209.58),
    ["The Arch"] = Vector3.new(1073.62, 161.72, -1203.49),
    ["The Bunker"] = Vector3.new(1844.74, -327.78, -2386.04),
    ["The Cursed Shores"] = Vector3.new(-235, 85, 1930),
    ["The Deep"] = Vector3.new(523.56, -2210.04, -11901.5),
    ["The Depth"] = Vector3.new(958.15, -713.06, 1442.44),
    ["The Sanctum"] = Vector3.new(4413.11, -2679.92, -4672.15),
    ["The Shady Bazaar"] = Vector3.new(-2921, -968.44, 6038),
    ["Tidefall Castle"] = Vector3.new(4469.46, -1074.65, 924.73),
    ["Tidefall"] = Vector3.new(3075.61, -1079.92, 833.18),
    ["Toxic Grove"] = Vector3.new(-2674.53, -287.92, -2206.12),
    ["Trade Plaza"] = Vector3.new(535, 82, 775),
    ["Treasure Island"] = Vector3.new(8274.78, 195, -17293),
    ["Underground Music Venue"] = Vector3.new(2015, -645, 2460),
    ["Veil of the Forsaken"] = Vector3.new(-2356.05, -11185.2, 7098),
    ["Veil Research Platform"] = Vector3.new(-1950.03, 131.5, -330.02),
    ["Vertigo Dip"] = Vector3.new(-161.66, -705.02, 1205.99),
    ["Volcanic Vent"] = Vector3.new(-3358, -2029.91, 4077),
    ["Volcanic Vents"] = Vector3.new(-3136.28, -2010.89, 4056.85),
    ["Waveborne"] = Vector3.new(360, 90, 780),
    ["Wrath of Olympus"] = Vector3.new(-4265, -1117, 1825),
    ["Zeus Sanctuary"] = Vector3.new(-4298.74, -599.16, 2714.11),
    ["Zeus Thunder of Chaos"] = Vector3.new(-8671.82, -3507.06, 481.25),
    ["Zeus Trial"] = Vector3.new(-4297, -673.12, 2353),
    ["Angler (Moosewood)"] = Vector3.new(481, 151, 299),
    ["Angler (Roslit)"] = Vector3.new(-1512, 140, 688),
    ["Angler (Sunstone)"] = Vector3.new(-885, 135, -1115),
    ["Angler (Terrapin)"] = Vector3.new(-153, 144, 1954),
    ["Angler (Depths)"] = Vector3.new(980, -700, 1230),
    ["Angler (Ancient)"] = Vector3.new(5737, 177, -57),
    ["Angler (Forsaken)"] = Vector3.new(-2702, 169, 1798),
    ["Angler (Crimson)"] = Vector3.new(-1069, -361, -4811),
    ["Angler (Luminescent)"] = Vector3.new(-1050, -337, -4078),
    ["Angler (Jungle)"] = Vector3.new(-2726, 226, -2186),
    ["Merlin"] = Vector3.new(-929, 224, -996),
    ["Pierre"] = Vector3.new(387, 133, 258),
    ["Halt"] = Vector3.new(-1319, 133, 412),
    ["Appraiser (Roslit)"] = Vector3.new(-1644, 137, 727),
    ["Appraiser (Moosewood)"] = Vector3.new(446, 150, 230),
    ["Appraiser (Terrapin)"] = Vector3.new(-109, 157, 1956),
}
function teleportToArea(areaName)
    if not areaName or areaName == "" or areaName == "Select Area" then
        return false
    end
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = Character and (Character:FindFirstChild("HumanoidRootPart") or Character:WaitForChild("HumanoidRootPart", 3))
    if not hrp then
        return false
    end
    if KnownAreaPositions[areaName] then
        SafeMotion.Teleport(hrp, CFrame.new(KnownAreaPositions[areaName] + Vector3.new(0, 4, 0)))
        return true
    end
    local zones = Workspace:FindFirstChild("zones")
    local playerZones = zones and zones:FindFirstChild("player")
    local spot = playerZones and playerZones:FindFirstChild(areaName)
    if not spot and zones then
        spot = zones:FindFirstChild(areaName, true)
    end
    if spot then
        local targetPart = spot:IsA("BasePart") and spot or spot:FindFirstChildWhichIsA("BasePart", true)
        if targetPart then
            local posX = targetPart.Position.X
            local posY = targetPart.Position.Y
            local posZ = targetPart.Position.Z
            if targetPart.Size.Y > 50 and posY < 50 and not (
                areaName:find("Deep") or areaName:find("Abyss") or areaName:find("Atlantis") or
                areaName:find("Trench") or areaName:find("Crypt") or areaName:find("Trial") or
                areaName:find("Vertigo") or areaName:find("Veil")
            ) then
                posY = math.max(posY + (targetPart.Size.Y / 2) + 4, 135)
            else
                posY = posY + 4
            end
            SafeMotion.Teleport(hrp, CFrame.new(posX, posY, posZ))
            return true
        end
    end
    return false
end
local function getSpawnAreas()
    local tempSeen = {}
    local finalSortedList = {}
    local priorityIslands = {
        "Moosewood", "Roslit Bay", "Sunstone", "Snowcap", "Terrapin", "Mushgrove",
        "Ancient Isle", "Forsaken Shores", "The Depths", "Vertigo", "Desolate Deep",
        "Brine Pool", "Keepers Altar", "Atlantis"
    }
    for _, island in ipairs(priorityIslands) do
        if not tempSeen[island] then
            tempSeen[island] = true
            table.insert(finalSortedList, island)
        end
    end
    local zones = Workspace:FindFirstChild("zones")
    local playerZones = zones and zones:FindFirstChild("player")
    local otherList = {}
    for areaName in pairs(KnownAreaPositions) do
        if not tempSeen[areaName] then
            tempSeen[areaName] = true
            table.insert(otherList, areaName)
        end
    end
    if playerZones then
        for _, item in ipairs(playerZones:GetChildren()) do
            if item:IsA("BasePart") or item:IsA("Model") or item:IsA("Folder") then
                local areaName = item.Name
                if areaName and areaName ~= "" and areaName ~= "???" and not tempSeen[areaName] then
                    tempSeen[areaName] = true
                    table.insert(otherList, areaName)
                end
            end
        end
    end
    table.sort(otherList, function(a, b) return a:lower() < b:lower() end)
    for _, name in ipairs(otherList) do
        table.insert(finalSortedList, name)
    end
    return finalSortedList
end
function teleportTo2(pos)
    char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        SafeMotion.Teleport(char.HumanoidRootPart, CFrame.new(pos))
    end
end
BalloonPositions = {
    ["Balon 1"]  = Vector3.new(201.9, 162, -33.7),
    ["Balon 2"]  = Vector3.new(1005, 131, -1234),
    ["Balon 3"]  = Vector3.new(-2800, 260, 1550),
    ["Balon 4"]  = Vector3.new(-1244, 131, 1594),
    ["Balon 5"]  = Vector3.new(-2001, 190, 389),
    ["Balon 6"]  = Vector3.new(-1129, 228, -1158),
    ["Balon 7"]  = Vector3.new(1237, 140, 551),
    ["Balon 8"]  = Vector3.new(2747, 142, -785),
    ["Balon 9"]  = Vector3.new(-3881, 131, 326),
    ["Balon 10"] = Vector3.new(-1804, 188, 256),
    ["Balon 11"] = Vector3.new(-9.5, 157, -1079),
    ["Balon 12"] = Vector3.new(545, 295, -1887),
    ["Balon 13"] = Vector3.new(-2015, 224, -496),
    ["Balon 14"] = Vector3.new(506, 172, 220),
    ["Balon 15"] = Vector3.new(1742, 141, -2481),
    ["Balon 16"] = Vector3.new(1742, 141, -2481),
    ["Balon 17"] = Vector3.new(106, 184, 2074),
    ["Balon 18"] = Vector3.new(3019, -130, 2451),
    ["Balon 19"] = Vector3.new(5934, 259, 216),
    ["Balon 20"] = Vector3.new(-1520, 130, 2194),
}
BalloonOptions = {}
for name in pairs(BalloonPositions) do
    table.insert(BalloonOptions, name)
end
table.sort(BalloonOptions)
SelectedBalloon = nil
player = game:GetService("Players").LocalPlayer
HttpService = game:GetService("HttpService")
savedPositions = {}
savedPositionName = "Thanhub On Top"
selectedPosition = "None"
saveFileName = "saved_positions_thanhub.json"
function loadSavedPositions()
    success, result = pcall(function()
        if isfile and isfile(saveFileName) then
            jsonData = readfile(saveFileName)
            return HttpService:JSONDecode(jsonData)
        end
        return {}
    end)
    if success then
        return result
    else
        warn("Gagal memuat posisi tersimpan:", result)
        return {}
    end
end
function savePositionsToFile()
    success, errorMsg = pcall(function()
        if writefile then
            jsonData = HttpService:JSONEncode(savedPositions)
            writefile(saveFileName, jsonData)
        end
    end)
    if not success then
        warn("Gagal menyimpan posisi:", errorMsg)
    end
end
savedPositions = loadSavedPositions()
function refreshDropdown()
    names = {"None"}
    if type(savedPositions) == "table" then
        for name in pairs(savedPositions) do
            table.insert(names, name)
        end
    end
    if teleportPositionDropdown and teleportPositionDropdown.Refresh then
        teleportPositionDropdown:Refresh(names)
    end
end
refreshDropdown()
Locations = {
    ["Money Farm"] = CFrame.new(
        600.641418,
        152.235016,
        -1859.14783,
        1,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        1
    ),
    ["XP Farm"] = CFrame.new(
        1378.12891,
        -611.449768,
        2337.29688,
        0.991118073,
        0,
        -0.132984906,
        0,
        1,
        0,
        0.132984906,
        0,
        0.991118073
    ),
}
whilesaveconfig = false
Remote = nil
pcall(function()
    local netPkg = ReplicatedStorage:WaitForChild("packages", 2) and ReplicatedStorage.packages:WaitForChild("Net", 2)
    Remote = netPkg and netPkg:FindFirstChild("RF/DialogInteract")
end)
SpamEnabled = false
Players = game:GetService("Players")
ReplicatedStorage = game:GetService("ReplicatedStorage")
LocalPlayer = Players.LocalPlayer
_G.AutoRespawnDeathPos = false
local lastDeathCFrame = nil
local function SetupDeathTracker(character)
    local humanoid = character:WaitForChild("Humanoid", 10)
    local root = character:WaitForChild("HumanoidRootPart", 10)
    if humanoid and root then
        humanoid.Died:Connect(function()
            if _G.AutoRespawnDeathPos then
                local zone = character:FindFirstChild("zone")
                if zone and zone.Value and zone.Value.Name == "The Depths - Maze" then
                    lastDeathCFrame = CFrame.new(978.143, -686.911, 1253.742) * CFrame.Angles(0, 1.797, 0)
                else
                    lastDeathCFrame = root.CFrame
                end
            end
        end)
    end
end
task.spawn(function()
    local Net = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Net"))
    Net:RemoteFunction("GetSpawnPosition").OnClientInvoke = function()
        if _G.AutoRespawnDeathPos and lastDeathCFrame then
            return lastDeathCFrame
        end
        return nil
    end
end)
LocalPlayer.CharacterAdded:Connect(SetupDeathTracker)
if LocalPlayer.Character then SetupDeathTracker(LocalPlayer.Character) end
CurrentJumpPower = 50
function getHumanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end
function applyValues()
    local hum = getHumanoid()
    if not hum then return end
    hum.UseJumpPower = true
    hum.JumpPower = CurrentJumpPower
end
LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid", 10)
    applyValues()
end)
task.spawn(function()
    while task.wait(0.25) do
        local hum = getHumanoid()
        if hum and CurrentJumpPower ~= 50 and hum.JumpPower ~= CurrentJumpPower then
            applyValues()
        end
    end
end)
WalkUnderwaterActive = false
function ToggleWalkUnderwater(value)
    WalkUnderwaterActive = value
    if value then
        task.spawn(function()
            while WalkUnderwaterActive do
                character = LocalPlayer.Character
                humanoid = character and character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
                    if humanoid:GetState() == Enum.HumanoidStateType.Swimming then
                        humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    end
                end
                task.wait(0.1)
            end
        end)
    else
        character = LocalPlayer.Character
        humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
        end
    end
end
afkActive = true
local afkConnection
BypassRadar = false
function getOrCreateScreen(name, color)
    gui = PlayerGui:FindFirstChild(name)
    if not gui then
        gui = Instance.new("ScreenGui")
        gui.Name = name
        gui.IgnoreGuiInset = true
        gui.ResetOnSpawn = false
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        if syn and syn.protect_gui then
            syn.protect_gui(gui)
        elseif protectgui then
            protectgui(gui)
        end
        gui.Parent = PlayerGui
        frame = Instance.new("Frame")
        frame.Name = "Overlay"
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.Position = UDim2.new(0, 0, 0, 0)
        frame.BackgroundColor3 = color
        frame.BorderSizePixel = 0
        frame.BackgroundTransparency = 0
        frame.ZIndex = 999
        frame.Parent = gui
    end
    return gui
end
function EnableWhiteScreen()
    gui = getOrCreateScreen("WhiteScreen", Color3.fromRGB(255, 255, 255))
    gui.Enabled = true
end
function EnableBlackScreen()
    gui = getOrCreateScreen("BlackScreen", Color3.fromRGB(0, 0, 0))
    gui.Enabled = true
end
function DisableScreen()
    white = PlayerGui:FindFirstChild("WhiteScreen")
    black = PlayerGui:FindFirstChild("BlackScreen")
    if white then
        white.Enabled = false
    end
    if black then
        black.Enabled = false
    end
end
local ESPEnabled = false
local MaxDistance = 99999999
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ThanHub_ESP"
ESPFolder.Parent = workspace
local ActiveESP = {}
local ESPColors = {
    Color3.fromRGB(0,255,255),
    Color3.fromRGB(255,0,255),
    Color3.fromRGB(0,255,120),
    Color3.fromRGB(255,170,0),
    Color3.fromRGB(255,60,60),
    Color3.fromRGB(140,0,255)
}
local function getRandomColor()
    return ESPColors[
        math.random(1,#ESPColors)
    ]
end
local function formatDistance(distance)
    return "[" .. math.floor(distance) .. "m]"
end
local function removeESP(part)
    local esp = ActiveESP[part]
    if esp then
        if esp.Holder then
            esp.Holder:Destroy()
        end
        ActiveESP[part] = nil
    end
end
local function clearESP()
    for _, v in pairs(ActiveESP) do
        if v.Holder then
            v.Holder:Destroy()
        end
    end
    table.clear(ActiveESP)
end
local function createESP(part, fishName)
    if not ESPEnabled then
        return
    end
    if not part then
        return
    end
    if ActiveESP[part] then
        return
    end
    local espColor = getRandomColor()
    local holder = Instance.new("Folder")
    holder.Name = "ThanHubESP"
    holder.Parent = ESPFolder
    local highlight = Instance.new("Highlight")
    highlight.Parent = holder
    highlight.Adornee = part
    highlight.FillColor = espColor
    highlight.OutlineColor = Color3.new(1,1,1)
    highlight.FillTransparency = 0.75
    highlight.DepthMode =
    Enum.HighlightDepthMode.AlwaysOnTop
    local billboard = Instance.new("BillboardGui")
    billboard.Parent = holder
    billboard.Adornee = part
    billboard.Name = "ESP"
    billboard.Size =
    UDim2.new(0,250,0,80)
    billboard.StudsOffset =
    Vector3.new(0,4,0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = MaxDistance
    local label = Instance.new("TextLabel")
    label.Parent = billboard
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1,0,1,0)
    label.Text =
    "[" .. fishName .. "]"
    .. "\10[0m]"
    .. "\10[ThanHub]"
    label.TextColor3 = espColor
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 =
    Color3.new(0,0,0)
    label.Font = Enum.Font.GothamBlack
    label.TextScaled = true
    ActiveESP[part] = {
        Holder = holder,
        Label = label,
        FishName = fishName
    }
end
local function scanFishing()
    local zones =
    workspace:FindFirstChild("zones")
    local fishing =
    zones
    and zones:FindFirstChild("fishing")
    if not fishing then
        return
    end
    for _, obj in ipairs(
        fishing:GetDescendants()
    ) do
        local fishName =
        obj:GetAttribute("FishName")
        if fishName and fishName ~= "" then
            local targetPart
            if obj:IsA("BasePart") then
                targetPart = obj
            elseif obj:IsA("Model") then
                targetPart =
                obj.PrimaryPart
                or obj:FindFirstChildWhichIsA(
                    "BasePart"
                )
            end
            if targetPart then
                createESP(
                    targetPart,
                    tostring(fishName)
                )
            end
        end
    end
end
local function updateESP()
    if not ESPEnabled then
        return
    end
    local hrp = getHRP()
    if not hrp then
        return
    end
    for part, esp in pairs(ActiveESP) do
        if not part or not part.Parent then
            removeESP(part)
        else
            local distance =
            (hrp.Position - part.Position)
            .Magnitude
            if distance <= MaxDistance then
                esp.Label.Text =
                "[" .. esp.FishName .. "]"
                .. "\10"
                .. formatDistance(distance)
                .. "\10[ThanHub]"
            end
        end
    end
end
local function resolveFishEspTarget(obj)
    local fishName = obj:GetAttribute("FishName")
    if not fishName or fishName == "" then return nil end
    if obj:IsA("BasePart") then return obj, tostring(fishName) end
    if obj:IsA("Model") then
        local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
        if part then return part, tostring(fishName) end
    end
    return nil
end
local fishEspWatchConnection = nil
local function watchFishingZoneForESP()
    if fishEspWatchConnection then return end
    local zones = workspace:FindFirstChild("zones")
    local fishing = zones and zones:FindFirstChild("fishing")
    if not fishing then return end
    fishEspWatchConnection = fishing.DescendantAdded:Connect(function(obj)
        if not ESPEnabled then return end
        task.defer(function()
            local part, fishName = resolveFishEspTarget(obj)
            if part then
                createESP(part, fishName)
            end
        end)
    end)
end
watchFishingZoneForESP()
local lastFishEspUpdate = 0
RunService.Heartbeat:Connect(function()
    if not ESPEnabled then return end
    local now = os.clock()
    if now - lastFishEspUpdate < 0.2 then return end
    lastFishEspUpdate = now
    watchFishingZoneForESP()
    updateESP()
end)
local ZonesFolder =
Workspace:WaitForChild("zones")
:WaitForChild("fishing")
local AreaESPFolder = Instance.new("Folder")
AreaESPFolder.Name = "ThanHub_AreaESP"
AreaESPFolder.Parent = Workspace
local AreaESPColors = {
    Color3.fromRGB(0,255,255),
    Color3.fromRGB(255,0,255),
    Color3.fromRGB(0,255,120),
    Color3.fromRGB(255,170,0),
    Color3.fromRGB(255,60,60),
    Color3.fromRGB(140,0,255)
}
local ActiveAreaESP = {}
local function getColor(index)
    return AreaESPColors[((index - 1) % #AreaESPColors) + 1]
end
local function clearAreaESP()
    for _, entry in pairs(ActiveAreaESP) do
        pcall(entry.Holder.Destroy, entry.Holder)
    end
    table.clear(ActiveAreaESP)
    AreaESPFolder:ClearAllChildren()
end
local function createAreaESP(part, index)
    if not part:IsA("BasePart") or ActiveAreaESP[part] then
        return
    end
    local color = getColor(index)
    local holder = Instance.new("Folder")
    holder.Name = part.Name
    holder.Parent = AreaESPFolder
    local highlight = Instance.new("Highlight")
    highlight.Name = "ThanHubHighlight"
    highlight.Adornee = part
    highlight.FillColor = color
    highlight.OutlineColor = Color3.new(1,1,1)
    highlight.FillTransparency = 0.7
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = holder
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ThanHubBillboard"
    billboard.Adornee = part
    billboard.Size = UDim2.new(0, 220, 0, 60)
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = holder
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1,0,1,0)
    label.TextColor3 = color
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.new(0,0,0)
    label.Font = Enum.Font.GothamBlack
    label.TextScaled = true
    label.Text = part.Name
    label.Parent = billboard
    ActiveAreaESP[part] = { Holder = holder, Label = label }
end
local function updateAreaESP()
    if not _sX.AreaESP then
        if next(ActiveAreaESP) then clearAreaESP() end
        return
    end
    local count = 0
    for _, obj in ipairs(ZonesFolder:GetChildren()) do
        if obj:IsA("BasePart") then
            count += 1
            createAreaESP(obj, count)
        end
    end
    local hrp = getHRP()
    for part, entry in pairs(ActiveAreaESP) do
        if not part.Parent then
            pcall(entry.Holder.Destroy, entry.Holder)
            ActiveAreaESP[part] = nil
        else
            local distance = hrp and math.floor((hrp.Position - part.Position).Magnitude) or 0
            entry.Label.Text = part.Name .. "\10[ " .. distance .. "m ]\10By ThanHub"
        end
    end
end
task.spawn(function()
    while task.wait(0.5) do
        pcall(updateAreaESP)
    end
end)
isFrozen1 = false
animatorParent1 = nil
function autoEquipRod()
    rodName =
    workspace.PlayerStats[LocalPlayer.Name].T[LocalPlayer.Name].Stats.rod.Value
    if rodName and rodName ~= "" then
        backpack = LocalPlayer:WaitForChild("Backpack")
        rod = backpack:FindFirstChild(rodName)
        if rod then
            LocalPlayer.Character.Humanoid:EquipTool(rod)
        end
    end
end
RunService = game:GetService("RunService")
Players = game:GetService("Players")
LocalPlayer = Players.LocalPlayer
isFrozen1 = false
function FreezeCharacter1(state)
    SafeMotion.FreezeOnBoat(state, function() return isFrozen1 end, function(v) isFrozen1 = v end)
end
EventHunt = EventHunt or {}
do
    local targetAliases = {
        ["frightful pool"] = { "fischfright25" },
        ["whales pool"] = { "orca", "moby", "whale" },
        ["orca"] = { "orca", "moby", "whale" },
        ["bloop fish"] = { "bloopfish", "bloopfisher" },
    }
    local triggers = {}
    local triggerSeen = {}
    local zoneConnection = nil
    local huntRunning = false
    local ashclawRunning = false
    local hoverOwner = nil
    local savedHomeCFrame = nil
    EventHunt.Status = "Idle"
    EventHunt.CurrentTarget = nil
    local function normalizeName(text)
        return (string.lower(tostring(text)):gsub("[%s%-_%(%)]", ""))
    end
    local function getFishingZone()
        local zones = workspace:FindFirstChild("zones")
        return zones and zones:FindFirstChild("fishing")
    end
    local function getRoot()
        local character = LocalPlayer.Character
        return character and character:FindFirstChild("HumanoidRootPart"), character and character:FindFirstChildOfClass("Humanoid")
    end
    local function getInstancePosition(instance)
        if instance:IsA("BasePart") then
            return instance.Position
        end
        if instance:IsA("Model") then
            local ok, pivot = pcall(instance.GetPivot, instance)
            if ok then return pivot.Position end
        end
        return nil
    end
    function EventHunt.Notify(title, content)
        pcall(function()
            Window:Notify({ Title = title, Content = content, Duration = 3, Type = "Info" })
        end)
    end
    function EventHunt.GetSelectedTargets()
        local raw = _sX.Hunting_Target
        local list = {}
        if type(raw) == "string" then
            if raw ~= "" and raw ~= "Choose Event" then
                table.insert(list, raw)
            end
        elseif type(raw) == "table" then
            for key, value in pairs(raw) do
                if type(key) == "string" and value == true then
                    table.insert(list, key)
                elseif type(value) == "string" then
                    table.insert(list, value)
                end
            end
        end
        table.sort(list)
        return list
    end
    function EventHunt.MatchesTarget(instanceName, targetName)
        local cleanedName = normalizeName(instanceName)
        local aliases = targetAliases[string.lower(targetName)]
        if aliases then
            for _, alias in ipairs(aliases) do
                if string.find(cleanedName, alias, 1, true) then return true end
            end
            return false
        end
        local cleanedTarget = normalizeName(targetName)
        return cleanedTarget ~= "" and string.find(cleanedName, cleanedTarget, 1, true) ~= nil
    end
    function EventHunt.MatchSelected(instanceName)
        for _, targetName in ipairs(EventHunt.GetSelectedTargets()) do
            if EventHunt.MatchesTarget(instanceName, targetName) then
                return targetName
            end
        end
        return nil
    end
    function EventHunt.FindActiveTarget()
        local fishingZone = getFishingZone()
        local root = getRoot()
        if not fishingZone then return nil end
        local bestInstance, bestTarget, bestDistance = nil, nil, math.huge
        for _, child in ipairs(fishingZone:GetChildren()) do
            local targetName = EventHunt.MatchSelected(child.Name)
            local position = targetName and getInstancePosition(child)
            if position then
                local distance = root and (root.Position - position).Magnitude or 0
                if distance < bestDistance then
                    bestInstance, bestTarget, bestDistance = child, targetName, distance
                end
            end
        end
        return bestInstance, bestTarget
    end
    function EventHunt.ListActivePools()
        local fishingZone = getFishingZone()
        local active = {}
        if not fishingZone then return active end
        local seenNames = {}
        for _, child in ipairs(fishingZone:GetChildren()) do
            if child:IsA("BasePart") and string.find(string.lower(child.Name), "pool", 1, true) and not seenNames[child.Name] then
                seenNames[child.Name] = true
                table.insert(active, child.Name)
            end
        end
        table.sort(active)
        return active
    end
    local function fireTriggers(instance)
        local targetName = EventHunt.MatchSelected(instance.Name)
        if not targetName then return end
        for triggerName, callback in pairs(triggers) do
            local seen = triggerSeen[triggerName]
            if seen and not seen[instance] then
                seen[instance] = true
                task.spawn(pcall, callback, instance, targetName)
            end
        end
    end
    local function refreshZoneConnection()
        if next(triggers) == nil then
            if zoneConnection then
                zoneConnection:Disconnect()
                zoneConnection = nil
            end
            return
        end
        if zoneConnection then return end
        local fishingZone = getFishingZone()
        if not fishingZone then return end
        zoneConnection = fishingZone.ChildAdded:Connect(function(child)
            task.wait(0.3)
            if child.Parent then fireTriggers(child) end
        end)
    end
    function EventHunt.SetTrigger(triggerName, callback)
        triggers[triggerName] = callback
        triggerSeen[triggerName] = callback and setmetatable({}, { __mode = "k" }) or nil
        refreshZoneConnection()
        if not callback then return end
        local fishingZone = getFishingZone()
        if not fishingZone then return end
        for _, child in ipairs(fishingZone:GetChildren()) do
            fireTriggers(child)
        end
    end
    local function releaseHover(owner)
        if hoverOwner ~= owner then return end
        hoverOwner = nil
        local root, humanoid = getRoot()
        if root then
            local velocity = root:FindFirstChild("HoverVelocity")
            local gyro = root:FindFirstChild("HoverGyro")
            if velocity then velocity:Destroy() end
            if gyro then gyro:Destroy() end
        end
        pcall(FreezeCharacter1, false)
        if humanoid then
            pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end)
        end
    end
    local function holdHover(owner, position)
        if hoverOwner and hoverOwner ~= owner then return false end
        local root = getRoot()
        if not root then return false end
        hoverOwner = owner
        local velocity = root:FindFirstChild("HoverVelocity")
        if not velocity then
            velocity = Instance.new("BodyVelocity")
            velocity.Name = "HoverVelocity"
            velocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            velocity.Velocity = Vector3.zero
            velocity.Parent = root
        end
        local gyro = root:FindFirstChild("HoverGyro")
        if not gyro then
            gyro = Instance.new("BodyGyro")
            gyro.Name = "HoverGyro"
            gyro.MaxTorque = Vector3.new(400000, 400000, 400000)
            gyro.P = 10000
            gyro.Parent = root
        end
        if (root.Position - position).Magnitude > 4 then
            local sm = getgenv().LiyhubSafeMotion
            if sm and sm.Teleport then
                sm.Teleport(root, CFrame.new(position))
            else
                root.CFrame = CFrame.new(position)
            end
            root.AssemblyLinearVelocity = Vector3.zero
        end
        gyro.CFrame = CFrame.new(root.Position)
        return true
    end
    local function getPlayerBoat()
        local active = workspace:FindFirstChild("active")
        local boats = active and active:FindFirstChild("boats")
        local playerBoat = boats and boats:FindFirstChild(LocalPlayer.Name)
        return playerBoat and playerBoat:FindFirstChild("Rowboat")
    end
    local function placeBoatAt(position)
        local boat = getPlayerBoat()
        if not boat or not boat:FindFirstChild("HitBox") then return false end
        for _, descendant in ipairs(boat:GetDescendants()) do
            local lowered = string.lower(descendant.Name)
            if lowered == "sitprompt" or lowered == "body" then
                pcall(descendant.Destroy, descendant)
            end
        end
        if not pcall(boat.PivotTo, boat, CFrame.new(position)) then return false end
        task.wait(0.4)
        pcall(FreezeCharacter1, true)
        return true
    end
    local function returnHome()
        local root = getRoot()
        if root and savedHomeCFrame then
            local sm = getgenv().LiyhubSafeMotion
            if sm and sm.Teleport then
                sm.Teleport(root, savedHomeCFrame)
            else
                root.CFrame = savedHomeCFrame
            end
        end
    end
    function EventHunt.StartHunt()
        _sX.Hunting_Enabled = true
        if huntRunning then return end
        huntRunning = true
        local root = getRoot()
        savedHomeCFrame = savedHomeCFrame or (root and root.CFrame)
        task.spawn(function()
            local currentInstance = nil
            local usingBoat = false
            local wasAway = false
            while _sX.Hunting_Enabled do
                if not (currentInstance and currentInstance.Parent) then
                    currentInstance = nil
                    usingBoat = false
                    local instance, targetName = EventHunt.FindActiveTarget()
                    if instance then
                        currentInstance = instance
                        EventHunt.CurrentTarget = targetName
                        EventHunt.Status = "Hunting " .. targetName
                        local position = getInstancePosition(instance)
                        if position then
                            usingBoat = placeBoatAt(position + Vector3.new(0, _sX.Hunting_Height or 50, 0))
                            if usingBoat and not hoverOwner then hoverOwner = "hunt" end
                        end
                        wasAway = true
                    else
                        EventHunt.CurrentTarget = nil
                        EventHunt.Status = "Waiting for target spawn"
                        if wasAway then
                            releaseHover("hunt")
                            returnHome()
                            wasAway = false
                        end
                    end
                end
                if currentInstance and not usingBoat then
                    local position = getInstancePosition(currentInstance)
                    if position then
                        holdHover("hunt", position + Vector3.new(0, _sX.Hunting_Height or 50, 0))
                    end
                end
                task.wait(0.4 + math.random() * 0.35)
            end
            releaseHover("hunt")
            returnHome()
            savedHomeCFrame = nil
            EventHunt.CurrentTarget = nil
            EventHunt.Status = "Idle"
            huntRunning = false
        end)
    end
    function EventHunt.StopHunt()
        _sX.Hunting_Enabled = false
    end
    function EventHunt.StartAshclaw()
        _sX.AutoAshclaw_Enabled = true
        if ashclawRunning then return end
        ashclawRunning = true
        task.spawn(function()
            local homeCFrame = nil
            while _sX.AutoAshclaw_Enabled do
                local ashclaw = workspace:FindFirstChild("fish_Ashclaw")
                local center = ashclaw and ashclaw:FindFirstChild("Center")
                local root = getRoot()
                if center and center:IsA("BasePart") and root then
                    homeCFrame = homeCFrame or root.CFrame
                    holdHover("ashclaw", center.Position + Vector3.new(0, _sX.Ashclaw_Height or _sX.Hunting_Height or 50, 0))
                elseif homeCFrame then
                    releaseHover("ashclaw")
                    if root then
                        local sm = getgenv().LiyhubSafeMotion
                        if sm and sm.Teleport then
                            sm.Teleport(root, homeCFrame)
                        else
                            root.CFrame = homeCFrame
                        end
                    end
                    homeCFrame = nil
                end
                task.wait(0.4 + math.random() * 0.35)
            end
            releaseHover("ashclaw")
            local root = getRoot()
            if root and homeCFrame then
                local sm = getgenv().LiyhubSafeMotion
                if sm and sm.Teleport then
                    sm.Teleport(root, homeCFrame)
                else
                    root.CFrame = homeCFrame
                end
            end
            ashclawRunning = false
        end)
    end
    function EventHunt.StopAshclaw()
        _sX.AutoAshclaw_Enabled = false
    end
    function EventHunt.EquipEventRod(rodName, targetName)
        if type(rodName) ~= "string" or rodName == "" or rodName == "Select Rod" then return end
        local net = ReplicatedStorage:FindFirstChild("packages") and ReplicatedStorage.packages:FindFirstChild("Net")
        local equipRemote = net and net:FindFirstChild("RF/Rod/Equip")
        if not equipRemote then return end
        if not getgenv().LiyhubEventRodGate then
            getgenv().LiyhubEventRodGate = { Last = 0, MinInterval = 3.5 }
        end
        local gate = getgenv().LiyhubEventRodGate
        if (tick() - gate.Last) < gate.MinInterval then return end
        gate.Last = tick()
        task.wait(0.25 + math.random() * 0.4)
        if pcall(equipRemote.InvokeServer, equipRemote, rodName) then
            EventHunt.Notify("Rod Equipped", rodName .. " equipped for " .. tostring(targetName))
        end
    end
    function EventHunt.UseEventTotem(totemName)
        if type(totemName) ~= "string" or totemName == "" then return end
        if genv.TotemLock then return end
        if not getgenv().LiyhubEventTotemGate then
            getgenv().LiyhubEventTotemGate = { Last = 0, MinInterval = 6 }
        end
        local gate = getgenv().LiyhubEventTotemGate
        if (tick() - gate.Last) < gate.MinInterval then return end
        gate.Last = tick()
        genv.TotemLock = true
        pcall(function()
            if LocalPlayer.PlayerGui:FindFirstChild("reel") or finishing == true then
                pcall(resetRodNew)
                task.wait(0.7 + math.random() * 0.35)
            end
            local character = LocalPlayer.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local backpack = LocalPlayer:FindFirstChild("Backpack")
            if not humanoid or not backpack then return end
            local totemItem = SafeTotem.Ensure(totemName, SafeTotem.RestockEnabled())
            character = LocalPlayer.Character
            humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if not humanoid then return end
            if not totemItem then
                EventHunt.Notify("Auto Totem", totemName .. " not found in backpack.")
                return
            end
            humanoid:UnequipTools()
            task.wait(0.18 + math.random() * 0.22)
            humanoid:EquipTool(totemItem)
            task.wait(0.28 + math.random() * 0.3)
            pcall(totemItem.Activate, totemItem)
            task.wait(0.55 + math.random() * 0.4)
            humanoid:UnequipTools()
            task.wait(0.18 + math.random() * 0.22)
            pcall(autoEquipRod)
        end)
        genv.TotemLock = false
    end
end
SelectedEventRod = nil
Lighting = game:GetService("Lighting")
rbxLink = "http://www.roblox.com/asset/?id="
skyTable = {
    ["Realistic Sky"] = 4607457995,
    ["Realistic Sky(2)"] = 10256505900,
    ["Minecraft Sky"] = 2758029221,
    ["Minecraft Sky(2)"] = 10594760952,
    ["Night Sky"] = 7975080965,
    ["Moon Sky"] = 14828385099,
    ["Halloween Sky"] = 15220097936,
    ["Pink Sky"] = 8202961731,
    ["Black Sky"] = 4696746436,
    ["Galaxy Sky"] = 15983996673,
    ["Space Sky"] = 12612655684,
    ["Anime Sky"] = 13107361022,
    ["Hell Sky"] = 17893731831,
    ["Rainbow Sky"] = 127719608807122,
    ["Scary Sky"] = 8808550143,
    ["The Rock Sky"] = 9774228162,
}
skyNames = {}
for name in pairs(skyTable) do
    table.insert(skyNames, name)
end
currentSky = skyNames[1]
TeleportService = game:GetService("TeleportService")
targetPlaceId = 131716211654599
GroupID = 7381705
MinRank = 2
autoKickStaff = false
function CheckIfStaff(player)
    if not autoKickStaff then
        return
    end
    if not player or not player:IsA("Player") then
        return
    end
    if player == LocalPlayer then
        return
    end
    success, result = pcall(function()
        return player:GetRankInGroup(GroupID)
    end)
    if success and result and result >= MinRank then
        role = player:GetRoleInGroup(GroupID)
        warn("Staff Detected! Role:", role, "Username:", player.Name)
        LocalPlayer:Kick(
            "\195\176\197\184\197\161\194\168 " .. role .. " detected!\10Username: " .. player.DisplayName
        )
    end
end
for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(function()
        CheckIfStaff(player)
    end)
end
Players.PlayerAdded:Connect(function(player)
    task.spawn(function()
        CheckIfStaff(player)
    end)
end)
ReplicatedStorage = game:GetService("ReplicatedStorage")
_sX = _sX or {}
_sX.webhookFishEnable = _sX.webhookFishEnable or false
_sX.webhookFishURL = _sX.webhookFishURL or ""
webhookFishNameOptions = {"All"}
webhookRarityOptions = {"All"}
webhookMutationOptions = {"None"}
pcall(function()
    library = require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("modules"):WaitForChild("library"))
    if library and library.fish then
        tempFish = {}
        for fishName, _ in pairs(library.fish) do
            table.insert(tempFish, fishName)
        end
        table.sort(tempFish)
        for _, fishName in ipairs(tempFish) do
            table.insert(webhookFishNameOptions, fishName)
        end
    end
end)
pcall(function()
    rarityModule = require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("modules"):WaitForChild("library"):WaitForChild("rarities"))
    if rarityModule and rarityModule.Rarities then
        tempRarities = {}
        for _, rarityData in pairs(rarityModule.Rarities) do
            if rarityData.Name then table.insert(tempRarities, rarityData) end
        end
        table.sort(tempRarities, function(a, b)
            return (a.Order or 0) < (b.Order or 0)
        end)
        for _, rarityData in ipairs(tempRarities) do
            table.insert(webhookRarityOptions, rarityData.Name)
        end
    end
end)
pcall(function()
    mutationModule = require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("modules"):WaitForChild("fishing"):WaitForChild("mutations"))
    if mutationModule and mutationModule.Mutations then
        for mutName, _ in pairs(mutationModule.Mutations) do
            table.insert(webhookMutationOptions, mutName)
        end
    end
end)
table.sort(webhookMutationOptions, function(a, b)
    if a == "None" then return true
    elseif b == "None" then return false end
    return a < b
end)
if #webhookRarityOptions <= 1 then
    webhookRarityOptions = {"All", "Trash", "Common", "Uncommon", "Unusual", "Rare", "Legendary", "Mythical", "Exotic", "Secret"}
end
function checkWebhookFilterMatches(fishData)
    if not fishData then return false end
    fishName = fishData.Name or "Unknown"
    lowFishName = string.lower(tostring(fishName))
    fishRarity = "Unknown"
    if fishData.Rarity then
        fishRarity = tostring(fishData.Rarity)
    elseif library and library.fish and library.fish[fishName] and library.fish[fishName].Rarity then
        fishRarity = tostring(library.fish[fishName].Rarity)
    end
    lowRarity = string.lower(fishRarity)
    rawMutation = fishData.Mutation or fishData.Mutant or "Normal"
    lowMutation = string.lower(tostring(rawMutation))
    isShiny = (lowMutation == "shiny") or (fishData.Shiny == true) or string.find(lowFishName, "shiny")
    isSparkling = (lowMutation == "sparkling") or (fishData.Sparkling == true) or string.find(lowFishName, "sparkling")
    nameMatch = false
    if next(_sX.webhookSelectedFish) == nil or _sX.webhookSelectedFish["all"] then
        nameMatch = true
    end
    if not nameMatch and _sX.webhookSelectedFish[lowFishName] then
        nameMatch = true
    end
    if not nameMatch then return false end
    if _sX.webhookRarityFilterAktif and next(_sX.webhookTargetRarities) ~= nil then
        if not _sX.webhookTargetRarities[lowRarity] then
            return false
        end
    end
    if _sX.webhookMutationFilterAktif or _sX.webhookSpecialFilterAktif then
        foundMatch = false
        if _sX.webhookMutationFilterAktif and _sX.webhookTargetMutations[lowMutation] then
            foundMatch = true
        end
        if not foundMatch and _sX.webhookSpecialFilterAktif then
            if _sX.webhookTargetSpecial["shiny"] and isShiny then foundMatch = true end
            if _sX.webhookTargetSpecial["sparkling"] and isSparkling then foundMatch = true end
        end
        if not foundMatch then return false end
    end
    return true
end
function sendFishToWebhook(fishData, zoneName)
    fishName = fishData.Name or "Unknown"
    fishRarity = "Unknown"
    if fishData.Rarity then fishRarity = tostring(fishData.Rarity)
    elseif library and library.fish and library.fish[fishName] then fishRarity = tostring(library.fish[fishName].Rarity or "Unknown") end
    rawMutation = fishData.Mutation or fishData.Mutant or "Normal"
    safePlayerName = "[Than-Hub Protect]"
    data = {
        username = "Than-Hub Webhook Fisch",
        embeds = {
            {
                title = "\240\159\142\163 New Fish Detected! (ReelController)",
                description = string.format(
                    "```\10Zone     : %s\10Fish     : %s\10Rarity   : %s\10Mutation : %s\10Weight   : %s\10Player   : %s\10```",
                    zoneName or "-",
                    fishName,
                    fishRarity,
                    rawMutation,
                    string.format("%.2f kg", fishData.Weight or 0),
                    safePlayerName
                ),
                color = 0x00FF9C,
                footer = {
                    text = "ThanHub - Fish Caught - Fisch | " .. os.date("%Y-%m-%d %H:%M:%S"),
                },
            },
        },
    }
    pcall(function()
        json = game:GetService("HttpService"):JSONEncode(data)
        headers = { ["Content-Type"] = "application/json" }
        requestFunc = syn and syn.request or http_request or request or http and http.request
        if requestFunc then
            requestFunc({
                Url = _sX.webhookFishURL,
                Method = "POST",
                Headers = headers,
                Body = json,
            })
        end
    end)
end
function processFishWebhook(fish)
    if not fish then return end
    if _sX.webhookFishEnable and _sX.webhookFishURL ~= "" and params and params.fish then
        if checkWebhookFilterMatches(params.fish) then
            detectedZone = "-"
            pcall(function()
                char = game.Players.LocalPlayer.Character
                rod = char and char:FindFirstChildOfClass("Tool")
                if rod and rod:FindFirstChild("values") and rod.values:FindFirstChild("bobberzone") then
                    detectedZone = rod.values.bobberzone.Value or detectedZone
                end
            end)
            task.defer(function()
                sendFishToWebhook(params.fish, detectedZone)
            end)
        end
    end
end
_sX.webhookSelectedFish = {}
_sX.webhookTargetRarities = {}
_sX.webhookTargetMutations = {}
_sX.webhookTargetSpecial = {}
_sX.webhookRarityFilterAktif = false
_sX.webhookMutationFilterAktif = false
_sX.webhookSpecialFilterAktif = false
EventStatusParagraph = Infr:AddParagraph({
    Title = "INFORMATION",
    Content = "Loading...",
})
FishZone = AutoFishing:AddDropdown({
    Title = "Mode Reel",
    Options = { "Super Fast Reel", "Follow Bar" },
    Default = "Super Fast Reel",
    Callback = function(value)
        _sX = _sX or {}
        _sX.ReelMode = value
        _G.FastReelEnabled = (value == "Super Fast Reel")
        _G.FollowBarEnabled = (value == "Follow Bar")
    end,
})
CastModeDropdown = AutoFishing:AddDropdown({
    Title = "Mode Cast",
    Content = "Select Mode Cast",
    Options = { "Bad", "Good", "Amazing", "Perfect", "Random" },
    Multi = false,
    Default = "Perfect",
    Callback = function(value)
        _sX.castMode = value
    end,
})
FishZone = AutoFishing:AddDropdown({
    Title = "Mode Catch",
    Content = "Select Mode Catch.",
    Options = { "Random", "Perfect" },
    Multi = false,
    Default = "Perfect",
    Callback = function(value)
        _sX.CatchMode = value
        if _sX.activecatch_v then
            _sX.RandomCatchEnabled = (value == "Random")
            _sX.perfectCatchEnabled = (value == "Perfect")
        end
    end,
})
AutoFishing:AddInput({
    Title = "Random Perfect Chance (%)",
    Content = "Masukkan angka 0 - 100",
    Placeholder = "Contoh: 50",
    Callback = function(text)
        local num = tonumber(text)
        if num then
            _sX.randomCatchChance = math.clamp(num, 0, 100)
        else
            warn("Input harus berupa angka!")
        end
    end
})
AutoFishing:AddToggle({
    Title = "Custom Bar Size",
    Content = "Size >= 1 = Full Bar",
    Value = _G.CustomBarEnabled or false,
    Callback = function(state)
        _G.CustomBarEnabled = state
    end
})
AutoFishing:AddSlider({
    Title = "Bar Size",
    Min = 0.1,
    Max = 1.0,
    Default = _G.CustomBarSize or 1,
    Callback = function(val)
        _G.CustomBarSize = val
    end
})
AutoFishing:AddSlider({
    Title = "Fast Progress Speed",
    Min = 1,
    Max = 100,
    Default = 50,
    Callback = function(val)
        _G.FastProgressSpeed = val
    end
})
AutoFishing:AddSlider({
    Title = "Fish Movement Smoothing",
    Min = 0.1,
    Max = 2,
    Default = 1,
    Callback = function(val)
        _G.FishMoveInterval = val
        if ReelController.ActiveReel then
            ReelController.ActiveReel:AddModifier("movementfactor", "force", val)
        end
    end
})
AutoFishing:AddToggle({
    Title = "Auto Fish Movement",
    Value = false,
    Callback = function(isEnabled)
        _G.AutoFishEnabled = isEnabled
    end
})
AutoFishing:AddToggle({
    Title = "Auto Shake",
    Value = _sX.autoshake_v,
    Callback = function(state)
        _sX.autoshake_v = state
        _sX.autoShakeEnabled = state
        if state then
            Collection:StartExistingShake()
        else
            game:GetService("GuiService").SelectedObject = nil
        end
    end
})
AutoFishing:AddToggle({
    Title = "Center Shake",
    Value = _sX.centerShake or false,
    Callback = function(state)
        _sX.centerShake = state
    end
})
AutoFishing:AddToggle({
    Title = "Anti Drown (Lock Position)",
    Content = "Keeps your character in place while shaking/reeling so it won't walk into the water",
    Value = _sX.antiDrownEnabled or false,
    Callback = function(state)
        _sX.antiDrownEnabled = state
        if state then
            AntiDrown:Start()
        else
            AntiDrown:Stop()
        end
    end
})
AutoCast = AutoFishing:AddToggle({
    Title = "Auto Cast",
    Value = _sX.autocast_v,
    Callback = function(state)
        task.spawn(function()
            _sX.autoCastEnabled = state
            if state then
                if _G.UpdateFishingStatus then _G.UpdateFishingStatus(1, "Status: Ready to fish") end
                StartAutoFishing()
            else
                if _G.UpdateFishingStatus then _G.UpdateFishingStatus(1, "Status: Idle (Auto Cast Off)") end
            end
        end)
    end,
})
AutoFast = AutoFishing:AddToggle({
    Title = "Auto Start Reel",
    Value = _sX.autostartreel_v,
    Callback = function(state)
        _sX.autostartreel_v = state
        _sX.autoReelEnabled = state
        if state then
            _G.FastReelEnabled = (_sX.ReelMode == "Super Fast Reel")
            _G.FollowBarEnabled = (_sX.ReelMode == "Follow Bar")
        else
            _G.FastReelEnabled = false
            _G.FollowBarEnabled = false
        end
    end
})
AutoPerfect = AutoFishing:AddToggle({
    Title = "Active Catch",
    Value = _sX.activecatch_v,
    Content = "Enable or disable catch.",
    Callback = function(isEnabled)
        _sX.activecatch_v = isEnabled
        if isEnabled then
            _sX.RandomCatchEnabled = (_sX.CatchMode == "Random")
            _sX.perfectCatchEnabled = (_sX.CatchMode == "Perfect")
        else
            _sX.RandomCatchEnabled = false
            _sX.perfectCatchEnabled = false
        end
    end,
})
AutoFishing:AddButton({
    Title = "Cancel Fishing",
    Callback = function()
        task.spawn(function()
            unequipRod()
            equipRod()
        end)
    end
})
FishZone = AutoFish:AddDropdown({
    Title = "Mode Instant Bobber",
    Content = "Select Mode Catch.",
    Options = { "V1", "V2" },
    Multi = false,
    Default = "V1",
    Value = _sX.selectedbobberversion,
    Callback = function(value)
        task.spawn(function()
            _sX.InstantBobberMode = value
        end)
    end,
})
AutoBobber1 = AutoFish:AddToggle({
    Title = "Active Instant Bobber",
    Content = "Snaps the bobber onto the nearest water the instant it casts, and keeps it there.",
    Value = _sX.activeinstantboober_v,
    Callback = function(state)
        mode = _sX.InstantBobberMode or "V1"
        if mode == "V1" then
            _sX.FarDropEnabled = false
            _sX.AutoBobberAdjustToggle = state
        elseif mode == "V2" then
            _sX.FarDropEnabled = state
            _sX.AutoBobberAdjustToggle = false
        else
            warn("[AutoBobber] Unknown mode:", mode)
        end
        _sX.instantBobberActive = state
        if state and not _sX.instantBobberLoop then
            _sX.instantBobberLoop = true
            task.spawn(function()
                while _sX.instantBobberActive and (_sX.AutoBobberAdjustToggle or _sX.FarDropEnabled) do
                    local char = LocalPlayer.Character
                    local rod = char and char:FindFirstChildOfClass("Tool")
                    if rod and rod:FindFirstChild("bobber") and DoDropLogic then
                        pcall(DoDropLogic, rod, char)
                    end
                    task.wait(0.15)
                end
                _sX.instantBobberLoop = false
            end)
        end
    end,
})
AutoFish:AddToggle({
    Title = "Auto Metronome",
    Content = "Automatically hits metronome notes.",
    Value = _sX.AutoMetronome,
    Callback = function(state)
        _sX.AutoMetronome = state
        if state then
            StartAutoMetronome()
        else
            StopAutoMetronome()
        end
    end,
})
FishingToggle = AutoFish:AddToggle({
    Title = "Auto Equip Rod",
    Default = _sX.autoEquipState,
    Callback = function(value)
        _sX.autoEquipState = value == true
        _sX.autoEquipToken = (_sX.autoEquipToken or 0) + 1
        if not _sX.autoEquipState then
            _sX.autoEquipThread = nil
            return
        end
        local myToken = _sX.autoEquipToken
        _sX.autoEquipThread = task.spawn(function()
            while _sX.autoEquipState and _sX.autoEquipToken == myToken do
                if not genv.TotemLock then
                    pcall(autoEquipRod)
                end
                task.wait(1)
            end
        end)
    end,
})
AutoNuke = AutoFish:AddToggle({
    Title = "Auto Balance Nuke",
    Default = true,
    Callback = function(value)
        _sX.autoBalanceNukeEnabled = value
        if value then
            task.spawn(function()
                while _sX.autoBalanceNukeEnabled do
                    local nukeGui = localPlayer.PlayerGui:FindFirstChild("NukeMinigame")
                    if nukeGui and nukeGui.Enabled then
                        if not targetLoopFunc then
                            for _, v in pairs(getgc(true)) do
                                if type(v) == "function" and debug.info(v, "n") == "LoopMinigame" then
                                    targetLoopFunc = v
                                    break
                                end
                            end
                        end
                        if targetLoopFunc then
                            pcall(function()
                                debug.setupupvalue(targetLoopFunc, 6, 0)
                            end)
                        end
                    else
                        targetLoopFunc = nil
                    end
                    RunService.Heartbeat:Wait()
                end
            end)
        end
    end,
})
SnapReelSection:AddSeperator({
    Title = "Custom Catch Fish Selected",
})
SnapReelSection:AddDropdown({
    Title   = "Target Fish (List)",
    Options = namefish or {},
    Multi   = true,
    Default = {},
    Callback = function(v)
        selectedFish = {}
        if type(v) == "table" then
            for selection, state in pairs(v) do
                if state == true then
                    selectedFish[string.lower(tostring(selection))] = true
                elseif type(state) == "string" then
                    selectedFish[string.lower(tostring(state))] = true
                end
            end
        end
    end
})
SnapReelSection:AddDropdown({
    Title   = "Target Rarity (List)",
    Options = rarityList,
    Multi   = true,
    Default = {},
    Callback = function(v)
        targetRarityList = {}
        countRarity = 0
        if type(v) == "table" then
            for key, value in pairs(v) do
                name = ""
                isSelected = false
                if type(key) == "string" then name = key isSelected = value
                elseif type(value) == "string" then name = value isSelected = true end
                lowRarityName = string.lower(tostring(name))
                if isSelected and lowRarityName ~= "all" and lowRarityName ~= "" then
                    targetRarityList[lowRarityName] = true
                    countRarity = countRarity + 1
                end
            end
        end
        rarityFilterAktif = (countRarity > 0)
    end
})
SnapReelSection:AddDropdown({
    Title = "Target Mutation (List)",
    Options = mutationList,
    Multi = true,
    Default = {},
    Callback = function(v)
        targetMutations = {}
        count = 0
        if type(v) == "table" then
            for key, value in pairs(v) do
                name = ""
                isSelected = false
                if type(key) == "string" then name = key isSelected = value
                elseif type(value) == "string" then name = value isSelected = true end
                lowName = string.lower(tostring(name))
                if isSelected and lowName ~= "normal" and lowName ~= "none" and lowName ~= "" then
                    targetMutations[lowName] = true
                    count = count + 1
                end
            end
        end
        mutationFilterAktif = (count > 0)
    end
})
SnapReelSection:AddDropdown({
    Title = "Target Special Mutation",
    Options = {"Sparkling", "Shiny"},
    Multi = true,
    Default = {},
    Callback = function(v)
        targetSpecialMutations = {}
        if type(v) == "table" then
            for selection, state in pairs(v) do
                if state == true then
                    targetSpecialMutations[string.lower(tostring(selection))] = true
                elseif type(state) == "string" then
                    targetSpecialMutations[string.lower(state)] = true
                end
            end
        end
        specialMutationFilterAktif = next(targetSpecialMutations) ~= nil
    end
})
SnapReelSection:AddInput({
    Title = "Target Fish (Manual)",
    Content = "Dipakai jika ikan tidak ada di list",
    Default = "",
    Callback = function(v)
        inputFishName = v ~= "" and v or nil
    end
})
SnapReelSection:AddInput({
    Title = "Max Weight Filter",
    Content = "Tarik ikan di bawah berat ini (Contoh: 5 atau 5.6)",
    Default = "",
    Callback = function(v)
        if v == "" or v == nil then
            maxWeightInput = nil
        else
            num = tonumber(v)
            if num then
                maxWeightInput = num
            else
            end
        end
    end
})
SnapReelSection:AddToggle({
    Title = "Snap Reel",
    Content = "Auto lepas jika ikan tidak sesuai",
    Value = false,
    Callback = function(v)
        snapReelEnabled = v
    end
})
SnapReelSection:AddToggle({
    Title = "Show Fish Notification",
    Value = false,
    Callback = function(v)
        showNotification = v
    end
})
SpearSection:AddDropdown({
    Title = "Select Location",
    Options = locationNames,
    Multi = false,
    Default = "Lost Jungle",
    Callback = function(value)
        selectedCFrame = locations[value]
    end,
})
SpearSection:AddDropdown({
    Title   = "Target Fish (List)",
    Options = namefish,
    Multi   = true,
    Default = {"All"},
    Callback = function(v)
        spearTargetFish = {}
        spearAllowAll = false
        if type(v) == "table" then
            for selection, state in pairs(v) do
                if (selection == "All" and state == true) or state == "All" then
                    spearAllowAll = true
                end
                if state == true then spearTargetFish[selection] = true
                elseif type(state) == "string" then spearTargetFish[state] = true end
            end
        end
    end
})
SpearSection:AddDropdown({
    Title   = "Target Rarity (List)",
    Options = rarityList,
    Multi   = true,
    Default = {"All"},
    Callback = function(v)
        spearRarityFilter = {}
        spearAllowAllRarity = false
        if type(v) == "table" then
            for selection, state in pairs(v) do
                if (selection == "All" and state == true) or state == "All" then
                    spearAllowAllRarity = true
                end
                if state == true then spearRarityFilter[selection] = true
                elseif type(state) == "string" then spearRarityFilter[state] = true end
            end
        end
    end
})
SpearSection:AddInput({
    Title = "Max Weight Filter",
    Content = "Tarik ikan di bawah berat ini (Contoh: 5 or 5.6)",
    Default = "",
    Callback = function(v)
        if v and tonumber(v) then
            spearWeightLimit = tonumber(v)
        else
            spearWeightLimit = nil
        end
    end
})
SpearSection:AddDropdown({
    Title = "Target Special Mutation",
    Options = {"Sparkling", "Shiny"},
    Multi = true,
    Default = {},
    Callback = function(v)
        spearSpecialMut = {}
        if type(v) == "table" then
            for selection, state in pairs(v) do
                if state == true then spearSpecialMut[selection] = true
                elseif type(state) == "string" then spearSpecialMut[state] = true end
            end
        end
    end
})
SpearSection:AddDropdown({
    Title = "Target Mutation (List)",
    Options = mutationList,
    Multi = true,
    Default = {},
    Callback = function(v)
        spearRegularMut = {}
        if type(v) == "table" then
            for selection, state in pairs(v) do
                if state == true then spearRegularMut[selection] = true
                elseif type(state) == "string" then spearRegularMut[state] = true end
            end
        end
    end
})
SpearSection:AddToggle({
    Title = "Instant Spear Fishing (Snap)",
    Value = false,
    Callback = function(value)
        _G.dupeFischToggle = value
        if value then
            task.spawn(function()
                player = game.Players.LocalPlayer
                if selectedCFrame and player.Character then
                    hrp = player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then hrp.CFrame = selectedCFrame end
                end
                while _G.dupeFischToggle do
                    foundFish = false
                    char = player.Character
                    if char and spearfishing then
                        hrp = char:FindFirstChild("HumanoidRootPart")
                        hum = char:FindFirstChildOfClass("Humanoid")
                        if hrp and hum then
                            for _, zone in ipairs(spearfishing:GetChildren()) do
                                if not _G.dupeFischToggle then break end
                                if zone:IsA("BasePart") and (hrp.Position - zone.Position).Magnitude < 135 then
                                    zoneFish = zone:FindFirstChild("ZoneFish")
                                    if zoneFish then
                                        for _, fish in ipairs(zoneFish:GetChildren()) do
                                            if not _G.dupeFischToggle then break end
                                            uid = fish:GetAttribute("UID")
                                            isFrozen = fish:GetAttribute("Frozen")
                                            if uid and not isFrozen then
                                                foundFish = true
                                                remote:InvokeServer(uid)
                                                task.spawn(function()
                                                    connection = game:GetService("RunService").RenderStepped:Connect(function()
                                                        frames = frames or 0
                                                        frames = frames + 1
                                                        if frames > 40 or not _G.dupeFischToggle then
                                                            connection:Disconnect()
                                                            frames = 0
                                                            return
                                                        end
                                                        if hrp.Anchored then hrp.Anchored = false end
                                                        if hum.PlatformStand then hum.PlatformStand = false end
                                                        hum.WalkSpeed = 16
                                                        hum.JumpPower = 50
                                                        hum:ChangeState(Enum.HumanoidStateType.Running)
                                                        pcall(function()
                                                            PlayerModule = require(player.PlayerScripts:FindFirstChild("PlayerModule"))
                                                            if PlayerModule then PlayerModule:GetControls():Enable() end
                                                        end)
                                                    end)
                                                end)
                                                task.wait(0.25)
                                                if not _G.dupeFischToggle then break end
                                                activeFish = nil
                                                if StabController and StabController.ActiveReel and StabController.ActiveReel.fish then
                                                    activeFish = StabController.ActiveReel.fish
                                                end
                                                shouldCatch = false
                                                if activeFish then
                                                    passName = spearAllowAll or spearTargetFish[activeFish.Name]
                                                    passRarity = spearAllowAllRarity
                                                    if not spearAllowAllRarity then
                                                        currentRarity = "Unknown"
                                                        if activeFish.Rarity then
                                                            currentRarity = tostring(activeFish.Rarity)
                                                        elseif library and library.fish and library.fish[activeFish.Name] and library.fish[activeFish.Name].Rarity then
                                                            currentRarity = tostring(library.fish[activeFish.Name].Rarity)
                                                        end
                                                        passRarity = spearRarityFilter[currentRarity]
                                                    end
                                                    passWeight = true
                                                    if spearWeightLimit and activeFish.Weight then
                                                        if activeFish.Weight > spearWeightLimit then
                                                            passWeight = false
                                                        end
                                                    end
                                                    passSpecialMut = true
                                                    rawMutation = activeFish.Mutation or activeFish.Mutant or "Normal"
                                                    lowMutation = string.lower(tostring(rawMutation))
                                                    isShiny = (activeFish.Shiny == true) or (lowMutation and string.find(lowMutation, "shiny"))
                                                    isSparkling = (activeFish.Sparkling == true) or (lowMutation and string.find(lowMutation, "sparkling"))
                                                    if next(spearSpecialMut) ~= nil then
                                                        passSpecialMut = false
                                                        if spearSpecialMut["Shiny"] and isShiny then passSpecialMut = true end
                                                        if spearSpecialMut["Sparkling"] and isSparkling then passSpecialMut = true end
                                                    end
                                                    passRegularMut = true
                                                    if next(spearRegularMut) ~= nil then
                                                        passRegularMut = spearRegularMut[tostring(rawMutation)]
                                                    end
                                                    if passName and passRarity and passWeight and passSpecialMut and passRegularMut then
                                                        shouldCatch = true
                                                    end
                                                end
                                                if shouldCatch then
                                                    local spearProgress = math.floor((ReelGate.Progress() * 100) + 0.5)
                                                    if spearProgress >= 99 then spearProgress = 100 end
                                                    local spearPerfect = math.random() > ReelGate.PerfectMissChance
                                                    task.wait(0.8 + math.random() * 0.9)
                                                    finishEvent:FireServer({
                                                        e = spearProgress,
                                                        p = spearPerfect,
                                                        l = {},
                                                        d = {}
                                                    })
                                                    task.wait(0.08 + math.random() * 0.06)
                                                    remote:InvokeServer(uid, true)
                                                else
                                                    abortEvent:FireServer()
                                                    char:SetAttribute("ReelActive", nil)
                                                end
                                                task.wait(0.05)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if not foundFish then
                        task.wait(0.5)
                    else
                        task.wait(0.05)
                    end
                end
            end)
        else
            task.spawn(function()
                player = game.Players.LocalPlayer
                char = player.Character
                if char then
                    char:SetAttribute("ReelActive", nil)
                    hrp = char:FindFirstChild("HumanoidRootPart")
                    hum = char:FindFirstChildOfClass("Humanoid")
                    if hrp and hum then
                        if hrp.Anchored then hrp.Anchored = false end
                        if hum.PlatformStand then hum.PlatformStand = false end
                        pcall(function()
                            PlayerModule = require(player.PlayerScripts:FindFirstChild("PlayerModule"))
                            if PlayerModule then PlayerModule:GetControls():Enable() end
                        end)
                    end
                end
                abortEvent:FireServer()
            end)
        end
    end,
})
SpearSection:AddSeperator({
    Title = "Roaming Fish"
})
SpearSection:AddToggle({
    Title = "Show Roam Fish Panel",
    Value = false,
    Callback = function(value)
        local target = (gethui and gethui():FindFirstChild("RoamFishPanel")) or localPlayer.PlayerGui:FindFirstChild("RoamFishPanel")
        if value then
            createRoamFishPanel()
        else
            if target then target:Destroy() end
        end
    end
})
SpearSection:AddDropdown({
    Title   = "Target Rarity",
    Options = roamingRarityOptions,
    Multi   = true,
    Default = {},
    Callback = function(selected)
        _G.SelectedRoamingRarity = {}
        for key, value in pairs(selected) do
            if type(key) == "number" and type(value) == "string" then
                _G.SelectedRoamingRarity[string.lower(value)] = true
            elseif type(key) == "string" and value == true then
                _G.SelectedRoamingRarity[string.lower(key)] = true
            end
        end
        print("Selected rarities:", game:GetService("HttpService"):JSONEncode(_G.SelectedRoamingRarity))
    end
})
SpearSection:AddToggle({
    Title = "Auto Catch Fish Roaming",
    Value = false,
    Callback = function(value)
        if value then
            RoamingSniper.Active = true
            RoamingSniper.Start()
        else
            RoamingSniper.Active = false
            _G.IsSniping = false
            if RoamingSniper.Stop then
                RoamingSniper.Stop()
            end
        end
    end
})
SpearSection:AddToggle({
    Title = "Fish Notifier",
    Value = false,
    Callback = function(value)
        _G.FishNotifierToggle = value
        if value then
            task.spawn(function()
                lastSeed = nil
                while _G.FishNotifierToggle do
                    activeReel = StabController and StabController.ActiveReel
                    if activeReel and activeReel.fish and activeReel.base_seed ~= lastSeed then
                        lastSeed = activeReel.base_seed
                        activeFish = activeReel.fish
                        fishName = activeFish.Name
                        fishRarity = "Unknown"
                        if activeFish.Rarity then
                            fishRarity = tostring(activeFish.Rarity)
                        elseif library and library.fish and library.fish[fishName] and library.fish[fishName].Rarity then
                            fishRarity = tostring(library.fish[fishName].Rarity)
                        end
                        fishWeight = "Unknown"
                        if activeFish.Weight then
                            fishWeight = string.format("%.2f kg", activeFish.Weight)
                        end
                        rawMutation = activeFish.Mutation or activeFish.Mutant or "Normal"
                        lowMutation = string.lower(tostring(rawMutation))
                        isShiny = (activeFish.Shiny == true) or (lowMutation and string.find(lowMutation, "shiny"))
                        isSparkling = (activeFish.Sparkling == true) or (lowMutation and string.find(lowMutation, "sparkling"))
                        mutationStatus = tostring(rawMutation)
                        if isShiny and not string.find(lowMutation, "shiny") then
                            mutationStatus = mutationStatus .. " (Shiny)"
                        elseif isSparkling and not string.find(lowMutation, "sparkling") then
                            mutationStatus = mutationStatus .. " (Sparkling)"
                        end
                        pcall(function()
                            game:GetService("StarterGui"):SetCore("SendNotification", {
                                Title = "Fish Detected!",
                                Text = "Name: " .. tostring(fishName) .. "\10Rarity: " .. fishRarity .. "\10Mutation: " .. mutationStatus .. "\10Weight: " .. fishWeight,
                                Duration = 3
                            })
                        end)
                    end
                    task.wait(0.1)
                end
            end)
        end
    end,
})
CastDelay = autoFishSettings:AddInput({
    Title = "Auto Cast Delay (s)",
    Default = tostring(_sX.autoCastDelayInput or 0),
    Placeholder = "Masukkan delay (contoh: 0.5)",
    Callback = function(value)
        num = tonumber(value)
        if num and num >= 0 then
            _sX.autoCastDelayInput = num
        else
            warn("[Auto Cast Delay] Nilai tidak valid, minimal 0")
        end
    end,
})
RodDelay = autoFishSettings:AddInput({
    Title = "Equip Rod Delay (s)",
    Content = "Set delay between auto equip checks",
    Default = tostring(_sX.autoEquipDelay or 2),
    Placeholder = "Masukkan delay (contoh: 2)",
    Callback = function(value)
        num = tonumber(value)
        if num and num >= 0 and num <= 5 then
            _sX.autoEquipDelay = num
        else
            warn(
                "[Equip Rod Delay] Nilai tidak valid, harus antara 0 - 5 detik"
            )
        end
    end,
})
ShakeDelay = autoFishSettings:AddInput({
    Title = "Auto Shake Delay (s)",
    Content = "Extra delay; 0 = fastest (game cooldown ~0.25s still applies)",
    Default = tostring(_sX.autoShakeDelayInput or 0),
    Placeholder = "Masukkan delay (contoh: 0)",
    Callback = function(value)
        local num = tonumber(value)
        if num and num >= 0 and num <= 5 then
            _sX.autoShakeDelayInput = num
        else
            warn("[Auto Shake Delay] Nilai tidak valid, harus antara 0 - 5 detik")
        end
    end,
})
if _G.LiyZoneResolver then
    local full = _G.LiyZoneResolver.ZoneList()
    table.clear(FishingSpots)
    for _, n in ipairs(full) do table.insert(FishingSpots, n) end
end
FishZone = FishingZone:AddDropdown({
    Title = "Fishing Zones",
    Options = FishingSpots,
    Multi = false,
    Value = _sX.selectedfishingzone,
    Callback = function(value)
        task.spawn(function()
            _sX.FishingTPDropdownUI = value
        end)
    end,
})
fishingzone = FishingZone:AddToggle({
    Title = "Auto Fishing Teleport",
    Content = "Enable/Disable Teleport",
    Default = false,
    Callback = function(state)
        task.spawn(function()
            _sX.selectedZoneADS = state
            if state then
                teleportToFishingZone(_sX.FishingTPDropdownUI)
            else
                teleportToFishingZone("None")
            end
        end)
    end,
})
FloatZone = FishingZone:AddInput({
    Title = "Set Float Height",
    Value = tostring(_sX.floatHeight),
    Callback = function(value)
        num = tonumber(value)
        if num then
            _sX.floatHeight = math.clamp(num, 3, 50000)
        end
    end,
})
FishingZone:AddButton({
    Title = "Teleport to Fishing Zone",
    Callback = function()
        FloatAboveZone(_sX.FishingTPDropdownUI)
    end,
})
FishingZone:AddButton({
    Title = "Return to Original Position",
    Callback = function()
        _sX.autoTeleportEnabled = false
    end,
})
AutoBoatSection:AddSlider({
    Title = "Boat Max Speed",
    Min = 0,
    Max = 1000,
    Default = 1,
    Rounding = 0,
    Callback = function(v)
        BoatSettings["Max Speed"] = v
        if getgenv().UseMaxSpeed then
            local vessels = require(game:GetService("ReplicatedStorage").shared.modules.vessels)
            for _, props in next, vessels.library do
                props.MaxSpeed = v
            end
        end
    end
})
AutoBoatSection:AddSlider({
    Title = "Boat Turning Speed",
    Min = 0,
    Max = 100,
    Default = 1,
    Rounding = 0,
    Callback = function(v)
        BoatSettings["Turning Speed"] = v
        if getgenv().UseTurningSpeed then
            local vessels = require(game:GetService("ReplicatedStorage").shared.modules.vessels)
            for _, props in next, vessels.library do
                props.TurningSpeed = v
            end
        end
    end
})
AutoBoatSection:AddSlider({
    Title = "Boat Acceleration",
    Min = 0,
    Max = 500,
    Default = 1,
    Rounding = 0,
    Callback = function(v)
        BoatSettings["Acceleration"] = v
        if getgenv().UseAcceleration then
            local vessels = require(game:GetService("ReplicatedStorage").shared.modules.vessels)
            for _, props in next, vessels.library do
                props.Accel = v
            end
        end
    end
})
AutoBoatSection:AddToggle({
    Title = "Use Max Speed",
    Default = false,
    Callback = function(v)
        getgenv().UseMaxSpeed = v
        local vessels = require(game:GetService("ReplicatedStorage").shared.modules.vessels)
        if v then
            for _, props in next, vessels.library do
                props.MaxSpeed = BoatSettings["Max Speed"]
            end
        else
            for boat, props in next, vessels.library do
                if data.Boats[boat] then
                    props.MaxSpeed = tonumber(data.Boats[boat].MaxSpeed)
                end
            end
        end
    end
})
AutoBoatSection:AddToggle({
    Title = "Use Turning Speed",
    Default = false,
    Callback = function(v)
        getgenv().UseTurningSpeed = v
        local vessels = require(game:GetService("ReplicatedStorage").shared.modules.vessels)
        if v then
            for _, props in next, vessels.library do
                props.TurningSpeed = BoatSettings["Turning Speed"]
            end
        else
            for boat, props in next, vessels.library do
                if data.Boats[boat] then
                    props.TurningSpeed = tonumber(data.Boats[boat].TurningSpeed)
                end
            end
        end
    end
})
AutoBoatSection:AddToggle({
    Title = "Use Acceleration",
    Default = false,
    Callback = function(v)
        getgenv().UseAcceleration = v
        local vessels = require(game:GetService("ReplicatedStorage").shared.modules.vessels)
        if v then
            for _, props in next, vessels.library do
                props.Accel = BoatSettings["Acceleration"]
            end
        else
            for boat, props in next, vessels.library do
                if data.Boats[boat] then
                    props.Accel = tonumber(data.Boats[boat].Acceleration)
                end
            end
        end
    end
})
RodShop:AddDropdown({
    Title = "Selected Rod",
    Content = "Rods with a known shop stand. Only buys if the real stand is found there.",
    Options = SafeTotem.Catalog(SafeTotem.Rods),
    Multi = false,
    Callback = function(value)
        _sX.RodDropdown = value
    end,
})
RodShop:AddButton({
    Title = "Buy Selected Rod",
    Content = "Walk up to the rod stand, buy through the real prompt, then return.",
    Callback = function()
        local selectedRodName = _sX.RodDropdown
        if type(selectedRodName) ~= "string" or selectedRodName == "" then
            SafeTotem.Notify("Select a rod first.")
            return
        end
        task.spawn(function()
            local ok, reason = SafeTotem.Buy(selectedRodName, 1)
            if ok then
                SafeTotem.Notify("Bought " .. selectedRodName .. ".")
            else
                SafeTotem.Notify(SafeTotem.Explain(selectedRodName, reason))
            end
        end)
    end,
})
BaitShop:AddSeperator("Bait Shop")
BaitShop:AddDropdown({
    Title = "Select Bait",
    Content = "Bait and crates with a verified shop stand.",
    Multi = false,
    Options = SafeTotem.Catalog(SafeTotem.Baits),
    Callback = function(v)
        selectedBait = v
    end,
})
BaitShop:AddInput({
    Title = "Buy Amount",
    Content = "Amount To Buy Bait",
    Value = "1",
    Callback = function(Text)
        local parsed = tonumber(Text)
        baitBuyAmount = (parsed and parsed > 0) and math.floor(parsed) or 1
    end,
})
BaitShop:AddButton({
    Title = "Buy Bait",
    Content = "Walk up to the nearest bait stand, buy through the real prompt, then return.",
    Callback = function()
        local baitName = selectedBait
        local total = math.clamp(math.floor(tonumber(baitBuyAmount) or 1), 1, 500)
        if type(baitName) ~= "string" or baitName == "" then
            SafeTotem.Notify("Select a bait first.")
            return
        end
        task.spawn(function()
            local bought = 0
            local lastReason = "bought"
            while bought < total do
                local ok, reason = SafeTotem.Buy(baitName, math.min(50, total - bought))
                bought += SafeTotem.LastBought or 0
                lastReason = reason
                if not ok or (SafeTotem.LastBought or 0) <= 0 then break end
                task.wait(1)
            end
            if bought >= total then
                SafeTotem.Notify("Bought " .. bought .. "x " .. baitName .. ".")
            else
                SafeTotem.Notify("Bought " .. bought .. "/" .. total .. " " .. baitName .. ". " .. SafeTotem.Explain(baitName, lastReason))
            end
        end)
    end,
})
BaitShop:AddDropdown({
    Title = "Crate To Open",
    Content = "Must sit on your hotbar (slots 1-9). Favorited crates are skipped.",
    Multi = false,
    Options = SafeTotem.LibraryNames(function(data) return data.IsCrate == true end, { "Bait Crate" }),
    Default = "Bait Crate",
    Callback = function(v)
        if type(v) == "string" and v ~= "" then SafeTotem.CrateName = v end
    end,
})
BaitShop:AddToggle({
    Title = "Auto Open Crate",
    Content = "Equips the crate from the hotbar and confirms the real open popup until none are left.",
    Default = false,
    Callback = function(isEnabled)
        SafeTotem.CrateEnabled = isEnabled
        SafeTotem.CrateToken += 1
        if not isEnabled then return end
        local token = SafeTotem.CrateToken
        task.spawn(function()
            local opened = 0
            local lastReason = "empty"
            while SafeTotem.CrateEnabled and SafeTotem.CrateToken == token do
                if SafeTotem.Busy then
                    task.wait(1)
                    continue
                end
                local status, count = SafeTotem.OpenCrateOnce(SafeTotem.CrateName)
                lastReason = status
                if status ~= "opened" then break end
                opened += count
                task.wait(1.2)
            end
            SafeTotem.Unequip()
            if SafeTotem.CrateToken ~= token then return end
            SafeTotem.CrateEnabled = false
            SafeTotem.Notify("Opened " .. opened .. "x " .. SafeTotem.CrateName .. ". " .. SafeTotem.ExplainService(SafeTotem.CrateName, lastReason))
        end)
    end,
})
BaitShop:AddToggle({
    Title = "Auto Buy Bait (loop)",
    Content = "Keeps buying the selected bait every few seconds using the real shop stand.",
    Default = false,
    Callback = function(isEnabled)
        _sX.autoBuyBaitLoop = isEnabled
        if not isEnabled then return end
        task.spawn(function()
            while _sX.autoBuyBaitLoop do
                local baitName = selectedBait
                local total = math.clamp(math.floor(tonumber(baitBuyAmount) or 1), 1, 500)
                if type(baitName) == "string" and baitName ~= "" then
                    local bought = 0
                    while bought < total and _sX.autoBuyBaitLoop do
                        local ok = SafeTotem.Buy(baitName, math.min(50, total - bought))
                        bought += SafeTotem.LastBought or 0
                        if not ok or (SafeTotem.LastBought or 0) <= 0 then break end
                        task.wait(0.6)
                    end
                end
                task.wait(math.max(tonumber(_sX.autoBuyBaitInterval) or 5, 2))
            end
        end)
    end,
})
BaitShop:AddInput({
    Title = "Auto Buy Interval (s)",
    Content = "Seconds between auto bait purchases.",
    Value = "5",
    Callback = function(Text)
        local n = tonumber(Text)
        _sX.autoBuyBaitInterval = (n and n >= 2) and n or 5
    end,
})
BaitShop:AddToggle({
    Title = "Auto Equip Bought Bait",
    Content = "Equips the selected bait after buying (RE/Bait/Equip).",
    Default = false,
    Callback = function(isEnabled)
        _sX.autoEquipBait = isEnabled
        if not isEnabled then return end
        task.spawn(function()
            local net = ReplicatedStorage:FindFirstChild("packages") and ReplicatedStorage.packages:FindFirstChild("Net")
            local equip = net and net:FindFirstChild("RE/Bait/Equip")
            while _sX.autoEquipBait do
                if equip and type(selectedBait) == "string" and selectedBait ~= "" then
                    pcall(function() equip:FireServer(selectedBait) end)
                end
                task.wait(3)
            end
        end)
    end,
})
local function liyNet()
    local pkg = ReplicatedStorage:FindFirstChild("packages")
    return pkg and pkg:FindFirstChild("Net")
end
local function liyHRP()
    local c = game:GetService("Players").LocalPlayer.Character
    return c, c and c:FindFirstChild("HumanoidRootPart")
end
local function liyFirePrompt(prompt)
    if prompt and typeof(fireproximityprompt) == "function" then
        pcall(function()
            local hold = prompt.HoldDuration
            prompt.HoldDuration = 0
            fireproximityprompt(prompt)
            prompt.HoldDuration = hold
        end)
    end
end
AutoTab:AddSeperator("Telescope")
AutoTab:AddToggle({
    Title = "Auto Telescope",
    Content = "Equips the telescope, activates it for the reward, then auto-recharges. Only works at night.",
    Default = false,
    Callback = function(state)
        _sX.autoTelescope = state
        if not state then return end
        task.spawn(function()
            local net = liyNet()
            local setEq = net and net:FindFirstChild("RF/Telescope/SetEquipped")
            local activate = net and net:FindFirstChild("RF/Telescope/Activate")
            local recharge = net and net:FindFirstChild("RF/Telescope/Recharge")
            while _sX.autoTelescope do
                local hour = game:GetService("Lighting").ClockTime
                if (hour >= 18 or hour <= 6) and activate then
                    pcall(function() if setEq then setEq:InvokeServer(true) end end)
                    task.wait(0.3)
                    pcall(function() activate:InvokeServer() end)
                    task.wait(0.4)
                    pcall(function() if recharge then recharge:InvokeServer(true) end end)
                end
                task.wait(8)
            end
        end)
    end,
})
AutoTab:AddSeperator("Storage")
AutoTab:AddSlider({
    Title = "Store When Backpack >=",
    Min = 10, Max = 500, Default = 100,
    Callback = function(v) _sX.storageThreshold = math.floor(tonumber(v) or 100) end,
})
AutoTab:AddToggle({
    Title = "Auto Storage (deposit fish)",
    Content = "Moves all non-favorited fish into storage when your backpack fills up. Stand near your storage crate.",
    Default = false,
    Callback = function(state)
        _sX.autoStorage = state
        if not state then return end
        task.spawn(function()
            local net = liyNet()
            local initial = net and net:FindFirstChild("RE/Storage/RequestInitial")
            local bulk = net and net:FindFirstChild("RF/Storage/RequestBulkMove")
            if not bulk then return end
            while _sX.autoStorage do
                local ok, DataController = pcall(function()
                    return require(ReplicatedStorage.client.legacyControllers.DataController)
                end)
                if ok and DataController then
                    local inv
                    pcall(function()
                        inv = (DataController.InventoryReplicator and DataController.InventoryReplicator:TryIndex({ "Inventory" }))
                        or (DataController.fetch and DataController.fetch("Inventory"))
                    end)
                    if type(inv) == "table" then
                        local ids, count = {}, 0
                        for id, item in pairs(inv) do
                            count += 1
                            local isFish = type(item) == "table" and (item.type == "Fishes" or item.caught ~= nil or (item.metadata and item.metadata.Weight))
                            local fav = type(item) == "table" and item.sub and item.sub.Favourited
                            if isFish and not fav then ids[#ids + 1] = id end
                        end
                        if count >= (_sX.storageThreshold or 100) and #ids > 0 then
                            if initial then pcall(function() initial:FireServer() end) end
                            task.wait(0.3)
                            pcall(function() bulk:InvokeServer(ids, true) end)
                        end
                    end
                end
                task.wait(5)
            end
        end)
    end,
})
AutoTab:AddSeperator("Cosmic Relics")
AutoTab:AddToggle({
    Title = "Auto Cosmic Relics",
    Content = "Teleports to and claims cosmic/starfall/lunar/meteor relic prompts in the current server.",
    Default = false,
    Callback = function(state)
        _sX.autoCosmic = state
        if not state then return end
        task.spawn(function()
            local keywords = { "cosmic", "starfall", "lunar", "meteor", "relic", "astral" }
            while _sX.autoCosmic do
                local _, hrp = liyHRP()
                if hrp then
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if not _sX.autoCosmic then break end
                        if obj:IsA("ProximityPrompt") and obj.Enabled then
                            local pName = (obj.Parent and obj.Parent.Name or ""):lower()
                            local oText = (obj.ObjectText or ""):lower()
                            local match = false
                            for _, kw in ipairs(keywords) do
                                if pName:find(kw, 1, true) or oText:find(kw, 1, true) then match = true break end
                            end
                            if match then
                                local part = obj.Parent:IsA("BasePart") and obj.Parent
                                or obj.Parent:FindFirstChildWhichIsA("BasePart")
                                if part then
                                    local sm = getgenv().LiyhubSafeMotion
                                    if sm and sm.Teleport then sm.Teleport(hrp, part.CFrame + Vector3.new(0,3,0))
                                    else hrp.CFrame = part.CFrame + Vector3.new(0,3,0) end
                                    task.wait(0.35)
                                    liyFirePrompt(obj)
                                    task.wait(0.35)
                                end
                            end
                        end
                    end
                end
                task.wait(3)
            end
        end)
    end,
})
CrabCages:AddSeperator("Crab Cage & Mining")
_sX.selectedCrabCage = _sX.selectedCrabCage or "Crab Cage"
local function crabCageIds()
    local ok, lib = pcall(function()
        return require(ReplicatedStorage.shared.modules.library.crabcages)
    end)
    return (ok and type(lib) == "table" and lib.byName) or nil
end
local function crabCageNames()
    local byName = crabCageIds()
    local names = {}
    if byName then for n in pairs(byName) do names[#names + 1] = n end end
    if #names == 0 then names = { "Crab Cage" } end
    table.sort(names)
    return names
end
local function placeCrabCage()
    local net = liyNet()
    local place = net and net:FindFirstChild("RF/CrabCage/Place")
    local byName = crabCageIds()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not (place and byName and hrp) then return false, "not ready" end
    local entry = byName[_sX.selectedCrabCage] or byName["Crab Cage"]
    if not entry then return false, "unknown cage" end
    local cf = hrp.CFrame * CFrame.new(0, -3, -4)
    local ok, res = pcall(function() return place:InvokeServer(cf, entry.Id) end)
    return ok, res
end
CrabCages:AddDropdown({
    Title = "Crab Cage Type",
    Options = crabCageNames(),
    Multi = false,
    Default = "Crab Cage",
    Callback = function(v) if type(v) == "string" and v ~= "" then _sX.selectedCrabCage = v end end,
})
CrabCages:AddButton({
    Title = "Place Crab Cage Here",
    Content = "Deploys the selected cage at your position (you must own it).",
    Callback = function() task.spawn(placeCrabCage) end,
})
CrabCages:AddToggle({
    Title = "Auto Place Crab Cages",
    Content = "Keeps deploying the selected cage while you own some. Place near water.",
    Default = false,
    Callback = function(state)
        _sX.autoCrabPlace = state
        if not state then return end
        task.spawn(function()
            while _sX.autoCrabPlace do
                pcall(placeCrabCage)
                task.wait(math.max(tonumber(_sX.crabPlaceInterval) or 3, 1.5))
            end
        end)
    end,
})
CrabCages:AddToggle({
    Title = "Auto Claim Crab Cages",
    Content = "Claims every placed crab cage the moment it is ready (uses the cage Claim prompt).",
    Default = false,
    Callback = function(state)
        _sX.autoCrabClaim = state
        if not state then return end
        task.spawn(function()
            while _sX.autoCrabClaim do
                local active = workspace:FindFirstChild("active")
                local cages = active and active:FindFirstChild("crabcages")
                if cages then
                    for _, cage in ipairs(cages:GetChildren()) do
                        if not _sX.autoCrabClaim then break end
                        local prompt = cage:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if prompt and prompt.Enabled and (prompt.ActionText == "Claim" or (prompt.ObjectText or ""):lower():find("crab")) then
                            liyFirePrompt(prompt)
                            task.wait(0.4)
                        end
                    end
                end
                task.wait(2)
            end
        end)
    end,
})
CrabCages:AddToggle({
    Title = "Auto Crab Mining (Crag Crab)",
    Content = "Fires the \"Send Mining\" / \"Claim Reward\" prompts at the Crag Crab in Scoria Reach.",
    Default = false,
    Callback = function(state)
        _sX.autoCragCrab = state
        if not state then return end
        task.spawn(function()
            while _sX.autoCragCrab do
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if not _sX.autoCragCrab then break end
                    if obj:IsA("ProximityPrompt") and obj.Enabled then
                        local t = ((obj.ActionText or "") .. " " .. (obj.ObjectText or "")):lower()
                        if t:find("mining") or t:find("crag") or (t:find("crab") and t:find("claim")) then
                            liyFirePrompt(obj)
                            task.wait(0.4)
                        end
                    end
                end
                task.wait(2.5)
            end
        end)
    end,
})
ItemsShop:AddDropdown({
    Title = "Select Item",
    Content = "Choose an item from the shop to purchase.",
    Options = _sX.itemNames,
    Multi = false,
    Value = _sX.itemNames[1] or "None",
    Callback = function(value)
        _sX.ItemSelection = value
    end,
})
ItemsShop:AddInput({
    Title = "Amount to Buy",
    Value = "1",
    Callback = function(value)
        _sX.ItemAmount = value
    end,
})
ItemsShop:AddButton({
    Title = "Buy Selected Item",
    Content = "Click to buy the selected item.",
    Callback = function()
        selectedItem = _sX.ItemSelection
        amount = tonumber(_sX.ItemAmount) or 1
        if not selectedItem or selectedItem == "" then
            warn("No item selected!")
            return
        end
        if not amount or amount <= 0 then
            warn("Invalid amount!")
            return
        end
        itemType = selectedItem:lower():find("crate") and "Fish" or "Item"
        args = {
            selectedItem,
            "Item",
            [4] = amount,
        }
        event:FireServer(unpack(args))
    end,
})
TotemSection:AddSeperator("Totems")
TotemSection:AddInput({
    Title = "Amount",
    Value = "1",
    Callback = function(value)
        _sX.BuyTotemAmount = value
    end,
})
TotemSection:AddDropdown({
    Title = "Select Totem",
    Content = "Choose totem to purchase.",
    Options = _sX.totemNames,
    Value = 1,
    Callback = function(value)
        _sX.TotemDropdown = value
    end,
})
TotemSection:AddButton({
    Title = "Buy Selected Totem",
    Content = "Click to purchase selected totem.",
    Callback = function()
        local selectedTotem = _sX.TotemDropdown
        if type(selectedTotem) ~= "string" or selectedTotem == "" then return end
        local buyAmount = tonumber(_sX.BuyTotemAmount) or 1
        task.spawn(function()
            local ok, reason = SafeTotem.Buy(selectedTotem, buyAmount)
            if ok then
                SafeTotem.Notify("Bought " .. selectedTotem .. ". Owned: " .. SafeTotem.CountOwned(selectedTotem))
            else
                SafeTotem.Notify(SafeTotem.Explain(selectedTotem, reason))
            end
        end)
    end,
})
MerlinShop:AddSeperator("Merlin Merchant")
MerlinShop:AddDropdown({
    Title = "Select Merlin Item",
    Content = "Walks to Merlin and picks the real dialog option.",
    Multi = false,
    Options = (function()
        local names = {}
        for _, entry in ipairs(SafeTotem.MerlinCatalog) do table.insert(names, entry.Name) end
        return names
    end)(),
    Default = "Enchant Relic",
    Callback = function(v)
        if type(v) == "string" and v ~= "" then selectedMerlinItem = v end
    end,
})
MerlinShop:AddInput({
    Title = "Buy Amount (Per Item)",
    Content = "How many dialog purchases to repeat.",
    Default = "1",
    Placeholder = "Input amount",
    Numeric = true,
    Callback = function(v)
        buyAmount = math.clamp(math.floor(tonumber(v) or 1), 1, 25)
    end,
})
MerlinShop:AddButton({
    Title = "Buy From Merlin",
    Content = "Requires level 30. Teleports beside Merlin, talks through the real prompt, then returns.",
    Callback = function()
        local itemName = selectedMerlinItem
        if type(itemName) ~= "string" or not SafeTotem.MerlinEntry(itemName) then
            SafeTotem.Notify("Select a Merlin item first.")
            return
        end
        local amount = math.clamp(math.floor(tonumber(buyAmount) or 1), 1, 25)
        task.spawn(function()
            local ok, reason, bought = SafeTotem.MerlinBuy(itemName, amount)
            if ok and reason == "bought" then
                SafeTotem.Notify("Bought " .. bought .. "x " .. itemName .. " from Merlin.")
            else
                SafeTotem.Notify("Merlin gave " .. bought .. "/" .. amount .. " " .. itemName .. ". " .. SafeTotem.ExplainService(itemName, reason))
            end
        end)
    end,
})
BoatShop:AddButton({
    Title = "Buy Boat ( UI BOAT )",
    Callback = function()
        if
        PlayerGui
        and PlayerGui:FindFirstChild("hud")
        and PlayerGui.hud:FindFirstChild("safezone")
        and PlayerGui.hud.safezone:FindFirstChild("shipwright")
        then
            PlayerGui.hud.safezone.shipwright.Visible =
            not PlayerGui.hud.safezone.shipwright.Visible
        end
    end,
})
AutoBM.DropdownUI = BlackMarketSection:AddDropdown({
    Title = "Select Items",
    Options = AutoBM.Items,
    Multi = true,
    Value = {},
    Callback = function(selectedList)
        AutoBM.TargetItems = selectedList
        for _, name in ipairs(selectedList) do
        end
    end,
})
BlackMarketSection:AddButton({
    Title = "Refresh Item List",
    Callback = function()
        RefreshItemList()
    end,
})
BlackMarketSection:AddToggle({
    Title = "Auto Buy Selected Items",
    Content = "Automatically buy all selected items repeatedly",
    Default = false,
    Callback = function(state)
        AutoBM.Enabled = state
        if state then
            task.spawn(function()
                while AutoBM.Enabled do
                    for _, itemName in ipairs(AutoBM.TargetItems) do
                        uuid = AutoBM.ItemIDs[itemName]
                        if uuid then
                            pcall(function()
                                PurchaseRemote:FireServer(uuid)
                            end)
                            task.wait(0.5)
                        end
                    end
                    task.wait(0.5)
                end
            end)
        else
        end
    end,
})
BlackMarketSection:AddButton({
    Title = "Open Black Market Ui",
    Callback = function()
        BlackMarketGui.Visible = not BlackMarketGui.Visible
        if BlackMarketGui.Visible then
        else
        end
    end,
})
AutoDaily.DropdownUI = DailyShopSection:AddDropdown({
    Title = "Select Items",
    Options = AutoDaily.Items,
    Multi = true,
    Value = {},
    Callback = function(selectedList)
        AutoDaily.TargetItems = selectedList
        for _, name in ipairs(selectedList) do
            uuids = AutoDaily.ItemIDs[name]
            if uuids then
            end
        end
    end,
})
DailyShopSection:AddSeperator("Daily Shop")
DailyShopSection:AddButton({
    Title = "Refresh Daily List",
    Callback = function()
        RefreshDailyList()
    end,
})
DailyShopSection:AddToggle({
    Title = "Auto Buy Selected Items",
    Content = "Automatically buy all selected items repeatedly",
    Default = false,
    Callback = function(state)
        AutoDaily.Enabled = state
        if state then
            task.spawn(function()
                while AutoDaily.Enabled do
                    for _, itemName in ipairs(AutoDaily.TargetItems) do
                        uuids = AutoDaily.ItemIDs[itemName]
                        if uuids then
                            for _, uuid in ipairs(uuids) do
                                pcall(function()
                                    PurchaseRemote:FireServer(uuid)
                                end)
                                task.wait(0.5)
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        else
        end
    end,
})
DailyShopSection:AddButton({
    Title = "Open Daily Shop Ui",
    Callback = function()
        DailyShopGui.Visible = not DailyShopGui.Visible
        if DailyShopGui.Visible then
        else
        end
    end,
})
FischFestSection:AddDropdown({
    "Quest Difficulty",
    "",
    false,
    {"Easy", "Medium", "Hard"},
    "Easy",
    function(option)
        config.QuestDifficulty = option
    end
})
FischFestSection:AddDropdown({
    "Quest Mode",
    "",
    false,
    {"NPC", "Player"},
    "NPC",
    function(option)
        config.QuestMode = option
    end
})
FischFestSection:AddToggle({
    "Auto Take Quest",
    "",
    false,
    "Toggle",
    function(state)
        config.AutoTakeQuest = state
    end
})
FischFestSection:AddToggle({
    "Auto Join Side 1",
    "",
    false,
    "Toggle",
    function(v) config.AutoSide1 = v end
})
FischFestSection:AddToggle({
    "Auto Join Side 2",
    "",
    false,
    "Toggle",
    function(v) config.AutoSide2 = v end
})
FischFestSection:AddDropdown({
    "Farm Mode",
    "",
    false,
    {"Win", "Lose"},
    "Win",
    function(o) config.FarmMode = o end
})
FischFestSection:AddInput({
    "Target Score Limit",
    "",
    "10",
    function(v) config.TargetScore = tonumber(v) or 10 end
})
FischFestSection:AddToggle({
    "Gunakan Target Score",
    "",
    false,
    "Toggle",
    function(v) config.UseTargetScore = v end
})
FischFestSection:AddSeperator({
    Title = "Sand Castle",
})
FischFestSection:AddDropdown({
    "Quest Difficulty",
    "",
    false,
    {"Easy", "Medium", "Hard"},
    "Easy",
    function(option)
        config.QuestDifficulty = option
    end
})
FischFestSection:AddDropdown({
    "Quest Mode",
    "",
    false,
    {"NPC", "Player"},
    "NPC",
    function(option)
        config.QuestMode = option
    end
})
FischFestSection:AddToggle({
    "Auto Take Quest",
    "",
    false,
    "Toggle",
    function(state)
        config.AutoTakeQuest = state
    end
})
FischFestSection:AddToggle({
    "Auto Farm Quest (Build Castle)",
    "",
    false,
    "Toggle",
    function(state)
        config.AutoFarmQuestCastle = state
    end
})
OpenCrate:AddSeperator({
    Title = "Others",
})
CosmicRelicParagraph = OpenCrate:AddParagraph({
    Title = "COSMIC RELIC STATUS",
    Content = "Loading...",
})
OpenCrate:AddToggle({
    Title = "Auto Claim Cosmic Relic",
    Default = false,
    Content = "Auto TP, claim, balik posisi",
    Callback = function(state)
        CosmicHop.SetAutoClaim(state == true)
    end
})
CosmicHop.Toggle = OpenCrate:AddToggle({
    Title = "Auto Hop Cosmic Relic",
    Content = "Scan server for Cosmic Relic, claim it, then hop to a new server.",
    Default = false,
    Callback = function(v)
        CosmicHop.SetEnabled(v == true)
    end
})
CosmicHop.TryResume()
AutoTempleToggle = OpenCrate:AddToggle({
    Title = "Auto Temple",
    Value = false,
    Callback = function(state)
        task.spawn(function()
            getgenv().AutoTemple = state
            if state then
                startAutoTemple()
            end
        end)
    end,
})
OpenCrate:AddButton({
    Title = "Copy Brick Rod Code",
    Callback = function()
        messagesFolder = workspace:WaitForChild("BrickRodMessages")
        m1 = messagesFolder:FindFirstChild("m1")
        m2 = messagesFolder:FindFirstChild("m2")
        m3 = messagesFolder:FindFirstChild("m3")
        function getTextFromPart(part)
            if part and part:IsA("BasePart") then
                gui = part:FindFirstChildOfClass("SurfaceGui")
                if gui then
                    textLabel = gui:FindFirstChild("TextLabel")
                    if textLabel then
                        return textLabel.Text
                    end
                end
            end
            return ""
        end
        part1 = getTextFromPart(m1)
        part2 = getTextFromPart(m2)
        part3 = getTextFromPart(m3)
        combinedText = part1 .. "" .. part2 .. ". " .. part3
        if setclipboard then
            setclipboard(combinedText)
        end
    end,
})
OpenCrate:AddToggle({
    Title = "Auto Keystone",
    Value = false,
    Callback = function(Value)
        getgenv().AutoKeystone = Value
        if Value then
            spawn(function()
                index = 1
                while getgenv().AutoKeystone do
                    hrp = getHumanoidRootPart()
                    if hrp then
                        targetPos = keystonePositions[index]
                        hrp.CFrame = CFrame.new(targetPos + TELEPORT_OFFSET)
                        nearestModel = getNearestKeystoneModel(targetPos)
                        if nearestModel then
                            meshPart =
                            nearestModel:FindFirstChildWhichIsA(
                                "MeshPart",
                                true
                            )
                            if meshPart then
                                triggerPromptAtMeshPart(meshPart)
                            end
                        else
                        end
                        index = index + 1
                        if index > #keystonePositions then
                            index = 1
                        end
                    end
                    task.wait(2)
                end
            end)
        end
    end,
})
FoodFish = FoodSection:AddDropdown({
    Title = "Select Fish Food",
    Content = "Choose a type of fish food.",
    Options = _sX.fishFoods,
    Multi = false,
    Callback = function(value)
        _sX.SelectedFood = value
    end,
})
FoodBuy = FoodSection:AddToggle({
    Title = "Auto Buy Selected Fish Food",
    Content = "Automatically purchases the selected fish food.",
    Default = false,
    Callback = function(value)
        _sX.AutoBuyFood = value
        if value then
            task.spawn(function()
                while _sX.AutoBuyFood do
                    if _sX.SelectedFood then
                        buyFoodRemote:FireServer(_sX.SelectedFood)
                    end
                    task.wait(3)
                end
            end)
        end
    end,
})
FoodActive = FoodSection:AddToggle({
    Title = "Auto Activate Selected Fish Food",
    Content = "Automatically activates the selected fish food.",
    Default = false,
    Callback = function(value)
        _sX.AutoActivateFood = value
        if value then
            task.spawn(function()
                while _sX.AutoActivateFood do
                    if _sX.SelectedFood then
                        activateFoodRemote:FireServer(_sX.SelectedFood)
                    end
                    task.wait(5)
                end
            end)
        end
    end,
})
FoodSlot = FoodSection:AddToggle({
    Title = "Auto Buy Slot",
    Content = "Automatically purchases the next slot.",
    Default = false,
    Callback = function(value)
        _sX.AutoBuySlot = value
        if value then
            task.spawn(function()
                while _sX.AutoBuySlot do
                    buySlotRemote:FireServer("SoftCurrency")
                    task.wait(1)
                end
            end)
        end
    end,
})
fishDropdown = FoodSection:AddDropdown({
    Title = "Select Fish (Multi)",
    Content = "Choose fishes from your Backpack",
    Options = getFishTools(),
    Multi = true,
    Callback = function(values)
        _sX.SelectedTools = values
    end,
})
FoodSection:AddButton({
    Title = "Refresh Fish List",
    Locked = false,
    Callback = function()
        fishDropdown:Refresh(getFishTools())
    end,
})
FishAdd = FoodSection:AddToggle({
    Title = "Auto Add Selected Fishes",
    Content = "Automatically adds selected fishes to the aquarium.",
    Default = false,
    Callback = function(state)
        _sX.AutoAddFish = state
        if state then
            task.spawn(function()
                while _sX.AutoAddFish do
                    for _, toolName in ipairs(_sX.SelectedTools) do
                        tool = backpack:FindFirstChild(toolName)
                        if
                        tool
                        and tool:FindFirstChild("link")
                        and tool.link:IsA("StringValue")
                        then
                            addFishRemote:FireServer(tool.link.Value)
                            task.wait(0.25 + math.random() * 0.2)
                        end
                    end
                    task.wait(5 + math.random() * 1.5)
                end
            end)
        end
    end,
})
Favoriteee:AddSeperator("Fish Favoriting")
Favoriteee:AddDropdown({
    Title = "Select Fish to Favorite",
    Multi = true,
    Options = namefish,
    Value = _sX.selectedfishfav,
    Callback = function(v)
        targetFav = v
    end,
})
Favoriteee:AddToggle({
    Title = "Auto Favorite",
    Value = _sX.autofavorite_v,
    Callback = function(value)
        AutoFavorite = value
        if value then
            spawn(function()
                while AutoFavorite do
                    backpack =
                    game:GetService("Players").LocalPlayer.Backpack
                    foundItems = {}
                    task.wait(0.6 + math.random() * 0.4)
                    for _, itemName in pairs(targetFav) do
                        for _, child in pairs(backpack:GetChildren()) do
                            if
                            child.Name == itemName
                            and child:FindFirstChild("link")
                            then
                                table.insert(foundItems, {
                                    Name = child.Name,
                                    Link = child.link.Value,
                                })
                                task.wait(0.35 + math.random() * 0.25)
                                game:GetService("ReplicatedStorage")
                                :WaitForChild("packages")
                                :WaitForChild("Net")
                                :WaitForChild("RE/Backpack/Favourite")
                                :FireServer(child.link.Value, true)
                            end
                        end
                    end
                    task.wait(2 + math.random())
                end
            end)
        end
    end,
})
AutoSellDelay = Selling:AddInput({
    Title = "Auto Sell Delay (s)",
    Value = "3",
    Callback = function(value)
        _sX.autoSellDelayInput = value
    end,
})
PriorityShadySell = Selling:AddToggle({
    Title = "Priority Sell Shady Fish",
    Content = "Sell all shady fish before normal auto sell",
    Value = _sX.priorityShadySell_v,
    Callback = function(value)
        _sX.priorityShadySell = value
    end,
})
AutoSellAll = Selling:AddToggle({
    Title = "Auto Sell",
    Content = "Sell all the fish you allow, but not your favorite fish",
    Value = _sX.autosell_v,
    Callback = function(value)
        _sX.autoSell = value
    end,
})
AutoSellHeld = Selling:AddToggle({
    Title = "Auto Sell Held Item",
    Value = false,
    Content = "Be smart to use this.",
    Callback = function(value)
        _sX.autoSellHand = value
    end,
})
Selling:AddSeperator({ Title = "Auto Sell Settings" })
Selling:AddDropdown({
    Title = "Select Rarities to Auto Sell",
    Options = rarities,
    Multi = true,
    Default = {},
    Value = _sX.autosellrarities,
    Callback = function(selected)
        selectedAutoSell = selected or {}
    end,
})
Selling:AddToggle({
    Title = "Enable Auto Sell",
    Value = _sX.autoselltoggle,
    Callback = function(state)
        if state then
            rarityMap = {}
            for _, rarity in ipairs(rarities) do
                rarityMap[rarity] = table.find(selectedAutoSell, rarity) ~= nil
            end
            args = { "autosell", rarityMap }
            updateRemote:FireServer(unpack(args))
        else
        end
    end,
})
Selling:AddDropdown({
    Title = "Select Rarities to Dont Sell",
    Options = rarities,
    Multi = true,
    Default = {},
    Value = _sX.dontsellrarities,
    Callback = function(selected)
        selectedDontSell = selected or {}
    end,
})
Selling:AddToggle({
    Title = "Enable Dont Sell (Whitelist)",
    Value = _sX.dontselltoggle,
    Callback = function(state)
        if state then
            rarityMap = {}
            for _, rarity in ipairs(rarities) do
                rarityMap[rarity] = not table.find(selectedDontSell, rarity)
            end
            args = { "autosell", rarityMap }
            updateRemote:FireServer(unpack(args))
        else
        end
    end,
})
Totem:AddDropdown({
    Title = "Select Day Totem",
    Options = (function()
        local list = { "None" }
        for _, name in ipairs(totemOptions) do table.insert(list, name) end
        return list
    end)(),
    Callback = function(v) getgenv().SelectedDayTotem = v end,
})
Totem:AddDropdown({
    Title = "Select Night Totem",
    Options = (function()
        local list = { "None" }
        for _, name in ipairs(totemOptions) do table.insert(list, name) end
        return list
    end)(),
    Callback = function(v) getgenv().SelectedNightTotem = v end,
})
AutoTotemCycle = { Token = 0, LastCycle = nil, NextTry = 0, LastUse = 0 }
function AutoTotemCycle.Pick(cycle)
    local choice = cycle == "Day" and getgenv().SelectedDayTotem or (cycle == "Night" and getgenv().SelectedNightTotem or nil)
    if type(choice) ~= "string" or choice == "" or choice == "None" then return nil end
    return choice
end
function AutoTotemCycle.Step()
    local cycleValue = ReplicatedStorage:FindFirstChild("world") and ReplicatedStorage.world:FindFirstChild("cycle")
    if not cycleValue then return end
    local cycle = cycleValue.Value
    if cycle ~= AutoTotemCycle.LastCycle then
        AutoTotemCycle.LastCycle = cycle
        AutoTotemCycle.Done = false
        AutoTotemCycle.NextTry = 0
    end
    if AutoTotemCycle.Done or os.clock() < AutoTotemCycle.NextTry then return end
    if os.clock() - AutoTotemCycle.LastUse < 20 then return end
    local totemName = AutoTotemCycle.Pick(cycle)
    if not totemName then
        AutoTotemCycle.Done = true
        return
    end
    if SafeTotem.Busy then return end
    local ok, reason = processTotem(totemName)
    if ok then
        AutoTotemCycle.Done = true
        AutoTotemCycle.LastUse = os.clock()
        return
    end
    AutoTotemCycle.NextTry = os.clock() + ((reason == "missing") and 60 or 10)
end
Totem:AddToggle({
    Title = "Auto Totem",
    Value = false,
    Callback = function(isEnabled)
        getgenv().AutoTotemToggle = isEnabled
        AutoTotemCycle.Token += 1
        if totemConnection then
            totemConnection:Disconnect()
            totemConnection = nil
        end
        if not isEnabled then return end
        local token = AutoTotemCycle.Token
        AutoTotemCycle.LastCycle = nil
        task.spawn(function()
            while getgenv().AutoTotemToggle and AutoTotemCycle.Token == token do
                pcall(AutoTotemCycle.Step)
                task.wait(2)
            end
        end)
    end,
})
Totem:AddToggle({
    Title = "Restock Totem From Stand",
    Content = "When a totem is missing, walk up to its shop stand (Clearcast, Meteor, Smokescreen, Sundial, Tempest, Windset), buy 1 through the real prompt, then return.",
    Value = false,
    Callback = function(enabled)
        SafeTotem.AutoRestock = enabled
    end,
})
local AuroraHunt = {
    Price = 500000,
    Token = 0,
    Stands = {
        { Id = "terrapin1", Position = Vector3.new(14, 134, 1933) },
        { Id = "snowcap2", Position = Vector3.new(2885, 133, 2704) },
        { Id = "roslit1", Position = Vector3.new(-1886, 352, 200) },
        { Id = "ancient1", Position = Vector3.new(6026, 255, 588) },
        { Id = "ancient2", Position = Vector3.new(5944, 152, 453) },
        { Id = "depths1", Position = Vector3.new(1013, -598, 1217) },
        { Id = "brine1", Position = Vector3.new(-1813, -139, -3280) },
        { Id = "brine2", Position = Vector3.new(-1836, -106, -3320) },
        { Id = "brine3", Position = Vector3.new(-1716, -103, -3392) },
        { Id = "nectar1", Position = Vector3.new(-1934, -304, -3349) },
        { Id = "crimson1", Position = Vector3.new(-1161, -347, -4923) },
        { Id = "crimson2", Position = Vector3.new(-934, -363, -4771) },
    },
}
function AuroraHunt.Notify(content)
    pcall(function()
        Window:Notify({ Title = "Aurora Totem", Content = content, Duration = 4, Type = "Info" })
    end)
end
function AuroraHunt.GetCash()
    local stats = LocalPlayer:FindFirstChild("leaderstats")
    local cash = stats and stats:FindFirstChild("C$")
    if not cash then return 0 end
    return tonumber((tostring(cash.Value):gsub("[^%d]", ""))) or 0
end
function AuroraHunt.GetPurchased()
    local ok, helper = pcall(require, ReplicatedStorage.shared.modules.SharedDataHelper)
    if not ok or type(helper) ~= "table" then return {} end
    local okData, data = pcall(helper.indexNewFormat, LocalPlayer, { "PurchasedAuroraTotems" })
    if okData and type(data) == "table" then return data end
    return {}
end
function AuroraHunt.FindStand(id)
    local world = workspace:FindFirstChild("world")
    local interactables = world and world:FindFirstChild("interactables")
    if not interactables then return nil end
    for _, model in ipairs(interactables:GetChildren()) do
        if model.Name == "Aurora Totem" and model:GetAttribute("Id") == id then return model end
    end
    return nil
end
function AuroraHunt.GetPopup()
    local over = LocalPlayer.PlayerGui:FindFirstChild("over")
    local popup = over and over:FindFirstChild("prompt")
    if popup and popup:IsA("GuiObject") and popup.Visible then return popup end
    return nil
end
function AuroraHunt.PressButton(button)
    if not button then return end
    if getconnections then
        for _, signal in ipairs({ button.Activated, button.MouseButton1Click }) do
            local ok, conns = pcall(getconnections, signal)
            if ok and type(conns) == "table" then
                for _, conn in ipairs(conns) do
                    pcall(function()
                        if conn.Function then task.spawn(conn.Function) else conn:Fire() end
                    end)
                end
            end
        end
    end
    task.wait(0.3)
    if not button.Parent or not button.Visible then return end
    button.Selectable = true
    GuiService.SelectedObject = button
    if keypress and keyrelease then
        keypress(0x0D)
        keyrelease(0x0D)
    end
    task.wait(0.2)
    if GuiService.SelectedObject == button then GuiService.SelectedObject = nil end
end
function AuroraHunt.HandlePopup(timeout)
    local deadline = os.clock() + timeout
    local popup
    repeat
        popup = AuroraHunt.GetPopup()
        if not popup then task.wait(0.15) end
    until popup or os.clock() > deadline
    if not popup then return "nopopup" end
    local info = popup:FindFirstChild("info")
    local text = info and info:IsA("TextLabel") and info.Text:lower() or ""
    AuroraHunt.PressButton(popup:FindFirstChild("confirm"))
    if text:find("insufficient") then return "funds" end
    return "confirmed"
end
function AuroraHunt.BuyStand(entry, token)
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp or typeof(fireproximityprompt) ~= "function" then return "nochar" end
    pcall(LocalPlayer.RequestStreamAroundAsync, LocalPlayer, entry.Position, 6)
    pcall(function() hrp.AssemblyLinearVelocity = Vector3.zero end)
    hrp.CFrame = CFrame.new(entry.Position + Vector3.new(0, 3, 3), entry.Position)
    local stand
    local deadline = os.clock() + 6
    repeat
        stand = AuroraHunt.FindStand(entry.Id)
        if not stand then task.wait(0.25) end
    until stand or os.clock() > deadline or AuroraHunt.Token ~= token
    if AuroraHunt.Token ~= token then return "stopped" end
    if not stand then return "nostand" end
    local standPos = stand:GetPivot().Position
    hrp.CFrame = CFrame.new(standPos + Vector3.new(0, 2.5, 3), standPos)
    task.wait(0.8)
    local prompt = stand:FindFirstChildWhichIsA("ProximityPrompt", true)
    if not prompt or not prompt.Enabled then return "noprompt" end
    pcall(fireproximityprompt, prompt)
    local result = AuroraHunt.HandlePopup(3)
    if result ~= "confirmed" then return result end
    local confirmDeadline = os.clock() + 4
    repeat
        if AuroraHunt.GetPurchased()[entry.Id] then return "bought" end
        local popup = AuroraHunt.GetPopup()
        if popup then AuroraHunt.HandlePopup(0.5) end
        task.wait(0.3)
    until os.clock() > confirmDeadline
    return AuroraHunt.GetPurchased()[entry.Id] and "bought" or "unconfirmed"
end
function AuroraHunt.CountPurchased()
    local purchased = AuroraHunt.GetPurchased()
    local count = 0
    for _, entry in ipairs(AuroraHunt.Stands) do
        if purchased[entry.Id] then count += 1 end
    end
    return count
end
function AuroraHunt.RefreshStatus()
    if not AuroraHunt.StatusParagraph then return end
    pcall(function()
        AuroraHunt.StatusParagraph:SetContent(string.format("Purchased %d/%d stands | C$ %d | Price %d each", AuroraHunt.CountPurchased(), #AuroraHunt.Stands, AuroraHunt.GetCash(), AuroraHunt.Price))
    end)
end
function AuroraHunt.RunPass(token)
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return 0, "nochar" end
    local origin = hrp.CFrame
    local bought, stopReason = 0, nil
    local purchased = AuroraHunt.GetPurchased()
    for _, entry in ipairs(AuroraHunt.Stands) do
        if AuroraHunt.Token ~= token then stopReason = "stopped" break end
        if not purchased[entry.Id] then
            if AuroraHunt.GetCash() < AuroraHunt.Price then stopReason = "funds" break end
            local result = AuroraHunt.BuyStand(entry, token)
            if result == "bought" then
                bought += 1
                purchased[entry.Id] = true
            elseif result == "funds" or result == "stopped" then
                stopReason = result
                break
            end
            task.wait(1.5)
        end
    end
    local returnHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if returnHrp then
        pcall(function() returnHrp.AssemblyLinearVelocity = Vector3.zero end)
        returnHrp.CFrame = origin
    end
    return bought, stopReason
end
AuroraHunt.StatusParagraph = Totem:AddParagraph({
    Title = "Aurora Totem Stands",
    Content = "Purchased ?/12 stands",
})
Totem:AddToggle({
    Title = "Auto Buy Aurora Totem",
    Content = "Teleports to each unpurchased Aurora stand (500k C$, 1 per location), buys it, then returns. Rechecks every 60s.",
    Value = false,
    Callback = function(enabled)
        AuroraHunt.Token += 1
        if not enabled then return end
        local token = AuroraHunt.Token
        task.spawn(function()
            while AuroraHunt.Token == token do
                AuroraHunt.RefreshStatus()
                local remaining = #AuroraHunt.Stands - AuroraHunt.CountPurchased()
                if remaining <= 0 then
                    AuroraHunt.Notify("All known Aurora stands are already purchased.")
                    AuroraHunt.Token += 1
                    break
                end
                if AuroraHunt.GetCash() >= AuroraHunt.Price then
                    local bought, reason = AuroraHunt.RunPass(token)
                    AuroraHunt.RefreshStatus()
                    if bought > 0 then
                        AuroraHunt.Notify(string.format("Bought %d Aurora Totem(s).", bought))
                    elseif reason == "funds" then
                        AuroraHunt.Notify("Not enough C$ for the next stand.")
                    end
                end
                local waitUntil = os.clock() + 60
                while AuroraHunt.Token == token and os.clock() < waitUntil do task.wait(1) end
            end
        end)
    end,
})
task.defer(AuroraHunt.RefreshStatus)
Totem:AddSeperator({ Title = "Spam Totem" })
local TotemSpamDropdown = Totem:AddDropdown({
    Title = "Select Totems to Spam",
    Options = totemOptions,
    Multi = true,
    Value = {},
    Callback = function(selectedList)
        getgenv().SelectedSpamTotems = selectedList
        for name, enabled in pairs(selectedList) do
            if enabled then
            end
        end
    end,
})
Totem:AddToggle({
    Title = "Auto Totem Spam",
    Value = false,
    Callback = function(enabled)
        getgenv().AutoTotemSpam = enabled
        if enabled then
            if isSpamming then return end
            isSpamming = true
            task.spawn(function()
                while getgenv().AutoTotemSpam do
                    local hasActiveTotem = false
                    for totemName, isSelected in pairs(getgenv().SelectedSpamTotems or {}) do
                        if isSelected then
                            hasActiveTotem = true
                            if not getgenv().AutoTotemSpam then break end
                            processTotem(totemName)
                            task.wait(0.7)
                        end
                    end
                    if not hasActiveTotem then
                        task.wait(1)
                    end
                    task.wait(1.5)
                end
                isSpamming = false
            end)
        else
            isSpamming = false
        end
    end,
})
AutoPotionSection:AddSeperator("Auto Potion")
AutoPotionSection:AddSlider({
    Title = "Potion Interval (Detik)",
    Min = 1,
    Max = 60,
    Default = 5,
    Rounding = 0,
    Callback = function(v)
        getgenv().PotionDelay = v
    end
})
AutoPotionSection:AddToggle({
    Title = "Auto Use Potion",
    Default = false,
    Callback = function(v)
        getgenv().AutoUsePotion = v
    end
})
SummonFish = AutoSummonSection:AddDropdown({
    Title = "Summon Type",
    Options = {
        "None",
        "Phantom Meg",
        "Whales",
        "Scylla",
        "Kraken",
        "Studolodon",
    },
    Value = "None",
    Callback = function(value)
        _sX.summonType = value
    end,
})
SummonFishAuto = AutoSummonSection:AddToggle({
    Title = "Auto Totem Summon",
    Value = _sX.AutoTotemToggle,
    Callback = function(enabled)
        _sX.AutoTotemToggle = enabled
        if not enabled then
            return
        end
        local alternateTotemIndex = 1
        task.spawn(function()
            while _sX.AutoTotemToggle do
                task.wait(1)
                local fishingZone = workspace.zones:FindFirstChild("fishing")
                if fishingZone then
                    local summonTargets = {
                        ["Phantom Meg"] = "Megalodon Phantom",
                        ["Whales"] = "Whales Pool",
                        ["Scylla"] = "Forsaken Veil - Scylla",
                        ["Kraken"] = "The Kraken Pool",
                        ["Studolodon"] = "LEGO - Studolodon",
                    }
                    local targetZone = summonTargets[_sX.summonType]
                    if not targetZone or fishingZone:FindFirstChild(targetZone) then
                        continue
                    end
                    local totemList = {}
                    if _sX.summonType == "Phantom Meg" then
                        totemList = { "Sundial Totem", "Eclipse Totem" }
                    elseif _sX.summonType == "Whales" or _sX.summonType == "Studolodon" then
                        totemList = { "Smokescreen Totem", "Tempest Totem" }
                    else
                        totemList = { "Sundial Totem" }
                    end
                    local totemToUse = totemList[alternateTotemIndex]
                    if not totemToUse then
                        alternateTotemIndex = 1
                        continue
                    end
                    local used, reason = processTotem(totemToUse)
                    if not used and reason == "missing" then task.wait(10) end
                    alternateTotemIndex = (alternateTotemIndex % #totemList) + 1
                    task.wait(used and 3 or 1)
                end
            end
        end)
    end,
})
Ench:AddDropdown({
    Title = "Select Enchant",
    Content = "Stops once the equipped rod has any of these enchants.",
    Multi = true,
    Options = enchanList1,
    Callback = function(v)
        targetEnc1 = v
        local targets = {}
        if type(v) == "table" then
            for key, state in pairs(v) do
                if state == true and type(key) == "string" then targets[key] = true end
                if type(state) == "string" then targets[state] = true end
            end
        end
        SafeTotem.EnchantTargets = targets
    end,
})
Ench:AddDropdown({
    Title = "Relic To Use",
    Content = "Held from the hotbar while pressing the altar. Favorited relics are skipped.",
    Multi = false,
    Options = SafeTotem.LibraryNames(function(data) return data.RelicGroup ~= nil end, { "Enchant Relic" }),
    Default = "Enchant Relic",
    Callback = function(v)
        if type(v) == "string" and v ~= "" then SafeTotem.RelicName = v end
    end,
})
Ench:AddToggle({
    Title = "Auto Enchant",
    Content = "At night: teleports to the altar, holds the relic, confirms the real enchant dialog, then returns.",
    Default = false,
    Callback = function(value)
        SafeTotem.EnchantEnabled = value
        SafeTotem.EnchantToken += 1
        if not value then return end
        local token = SafeTotem.EnchantToken
        task.spawn(function()
            local rolls = 0
            local lastReason = "stopped"
            local waitingNotified = false
            local function active()
                return SafeTotem.EnchantEnabled and SafeTotem.EnchantToken == token
            end
            if next(SafeTotem.EnchantTargets) == nil then
                SafeTotem.EnchantEnabled = false
                SafeTotem.Notify("Select at least one target enchant first.")
                return
            end
            while active() do
                if SafeTotem.EnchantReached() then
                    lastReason = "reached"
                    break
                end
                if SafeTotem.Busy then
                    task.wait(1)
                    continue
                end
                if not SafeTotem.IsNight() then
                    if not waitingNotified then
                        waitingNotified = true
                        SafeTotem.Notify("Altar only works at night. Waiting...")
                    end
                    task.wait(5)
                    continue
                end
                waitingNotified = false
                local root = SafeTotem.GetRoot()
                if not root then
                    task.wait(1)
                    continue
                end
                SafeTotem.Busy = true
                local origin = root.CFrame
                local ok, status = pcall(SafeTotem.EnchantOnce, SafeTotem.RelicName)
                SafeTotem.Unequip()
                local returnRoot = SafeTotem.GetRoot()
                if returnRoot then
                    pcall(function() returnRoot.AssemblyLinearVelocity = Vector3.zero end)
                    returnRoot.CFrame = origin
                end
                SafeTotem.Busy = false
                lastReason = ok and status or "error"
                if lastReason == "day" then continue end
                if lastReason ~= "enchanted" then break end
                rolls += 1
                task.wait(2)
            end
            if SafeTotem.EnchantToken ~= token then return end
            SafeTotem.EnchantEnabled = false
            if lastReason == "reached" then
                SafeTotem.Notify("Target enchant reached after " .. rolls .. " roll(s).")
            else
                SafeTotem.Notify("Auto Enchant stopped after " .. rolls .. " roll(s). " .. SafeTotem.ExplainService("Enchant Altar", lastReason))
            end
        end)
    end,
})
AutoTab:AddDropdown({
    Title = "Select Appraiser",
    Options = {"Appraiser", "Drowned Appraiser", "Shady Appraiser"},
    Default = "Appraiser",
    Callback = function(v)
        selectedAppraiser = v
    end
})
AutoTab:AddDropdown({
    Title = "Select Appraise Filter",
    Multi = true,
    Options = appraiseOptions,
    Callback = function(v)
        selectAppraise = _liyhubToList(v)
    end,
})
appraiseonheld = AutoTab:AddToggle({
    Title = "Auto Appraise on NPC (Held)",
    Value = false,
    Callback = function(value)
        Appraise = value
        if appraiseConnection then
            appraiseConnection:Disconnect()
        end
        if value then
            task.spawn(function()
                local char = player.Character or player.CharacterAdded:Wait()
                local hrp = char:WaitForChild("HumanoidRootPart")
                local pos = APPRAISERS[selectedAppraiser]
                do
                    local target = CFrame.new(pos)
                    local sm = getgenv().LiyhubSafeMotion
                    if sm and sm.Teleport then
                        sm.Teleport(hrp, target)
                    else
                        hrp.CFrame = target
                    end
                end
                task.wait(0.35 + math.random() * 0.3)
                local npc = workspace.world.npcs:FindFirstChild(selectedAppraiser)
                if npc and npc:FindFirstChild("ProximityPrompt") then
                    FireProximity(npc.ProximityPrompt)
                end
                task.wait(0.25 + math.random() * 0.25)
                _liyhubDialogInvoke(3, 1)
                appraiseConnection = player.Backpack.ChildAdded:Connect(function(newItem)
                    if Appraise then
                        task.wait(0.45 + math.random() * 0.35)
                        autoEquipNewItem(newItem)
                    end
                end)
                while Appraise do
                    local kw, matchedText, _, source = _liyhubAnyMatchStable(selectAppraise or {}, 0.4, 0.75, 3)
                    if kw then
                        Appraise = false
                        appraiseonheld:Set(false)
                        pcall(function()
                            Window:Notify({
                                Title = "Auto Appraise",
                                Content = string.format("Match: %s (from %s)", matchedText, source or "UI"),
                                Duration = 3,
                            })
                        end)
                        break
                    end
                    if not Appraise then break end
                    _liyhubDialogInvoke(1, 1)
                    task.wait(0.22 + math.random() * 0.2)
                    _liyhubDialogInvoke(3, 1)
                    task.wait(0.8 + math.random() * 0.45)
                end
            end)
        end
    end,
})
local fischDropdown = AutoTab:AddDropdown({
    Title = "Select Fisch to Appraise",
    Multi = true,
    Options = buildFischOptions(),
    Callback = function(v)
        selectAppraise1 = _liyhubToList(v)
    end,
})
AutoTab:AddButton({
    Title = "Refresh Fisch List",
    Callback = function()
        fischDropdown:Refresh(buildFischOptions())
    end
})
AutoTab:AddToggle({
    Title = "Auto Appraise All Selected",
    Value = false,
    Callback = function(value)
        Appraise = value
        if value then
            task.spawn(function()
                local char = player.Character or player.CharacterAdded:Wait()
                local hrp = char:WaitForChild("HumanoidRootPart")
                local pos = APPRAISERS[selectedAppraiser]
                do
                    local target = CFrame.new(pos)
                    local sm = getgenv().LiyhubSafeMotion
                    if sm and sm.Teleport then
                        sm.Teleport(hrp, target)
                    else
                        hrp.CFrame = target
                    end
                end
                task.wait(0.35 + math.random() * 0.3)
                local npc = workspace.world.npcs:FindFirstChild(selectedAppraiser)
                if npc and npc:FindFirstChild("ProximityPrompt") then
                    FireProximity(npc.ProximityPrompt)
                end
                task.wait(0.25 + math.random() * 0.25)
                local backpack = player.Backpack
                for _, tool in ipairs(backpack:GetChildren()) do
                    if not Appraise then
                        break
                    end
                    local isSelected = false
                    for _, name in ipairs(selectAppraise1 or {}) do
                        if type(name) == "string" and name ~= "" and _liyhubKeywordMatch(tool.Name, name) then
                            isSelected = true
                            break
                        end
                    end
                    if isSelected and tool:IsA("Tool") then
                        autoEquipNewItem(tool)
                        task.wait(0.45 + math.random() * 0.35)
                        local rollsSinceMatch = 0
                        while Appraise do
                            local kw, matchedText, _, source = _liyhubAnyMatchStable(selectAppraise or {}, 0.35, 0.65, 3)
                            if kw then
                                pcall(function()
                                    Window:Notify({
                                        Title = "Auto Appraise",
                                        Content = string.format("%s \226\134\146 %s (%s)", tool.Name, matchedText, source or "UI"),
                                        Duration = 3,
                                    })
                                end)
                                break
                            end
                            if not Appraise then break end
                            _liyhubDialogInvoke(1, 1)
                            task.wait(0.22 + math.random() * 0.2)
                            _liyhubDialogInvoke(6, 1)
                            rollsSinceMatch = rollsSinceMatch + 1
                            if rollsSinceMatch > 120 then
                                break
                            end
                            task.wait(0.8 + math.random() * 0.45)
                        end
                        if not tool.Parent then
                            task.wait(0.3 + math.random() * 0.3)
                        end
                    end
                end
                Appraise = false
            end)
        end
    end
})
TreasureApp:AddSeperator("Treasure Appraise")
TreasureApp:AddDropdown({
    Title = "Select Appraise Treasure",
    Multi = false,
    Options = { "Big", "Giant" },
    Default = "Big",
    Callback = function(selection)
        SelectedTreasure = selection
    end,
})
TreasureApp:AddToggle({
    Title = "Auto Treasure Appraise",
    Value = false,
    Callback = function(value)
        AutoAppraiseActive = value
        if value then
            task.spawn(function()
                while AutoAppraiseActive do
                    StartAutoAppraise(SelectedTreasure)
                    task.wait(1)
                end
            end)
        else
        end
    end,
})
local ThanHub_InfoDisplay = TreasureMarrow:AddParagraph({
    Title = "ThanHub | Treasure Map",
    Content = "Loading ThanHub Data...",
})
TreasureMarrow:AddToggle({
    Title = "Auto Treasure",
    Default = false,
    Callback = function(state)
        _G.AutoTreasure = state
        task.spawn(function()
            local DataController = require(game:GetService("ReplicatedStorage").client.legacyControllers.DataController)
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local OriginalPos = nil
            while _G.AutoTreasure do
                local Player = game.Players.LocalPlayer
                local Character = Player.Character
                local Root = Character and Character:FindFirstChild("HumanoidRootPart")
                local Hum = Character and Character:FindFirstChildOfClass("Humanoid")
                if not Root or not Hum then task.wait(1) continue end
                local inventory = DataController.fetch("Inventory")
                local targetMapData = nil
                local isRepaired = false
                for _, item in pairs(inventory) do
                    if string.find(item.name, "Treasure Map") then
                        targetMapData = item
                        if item.sub and item.sub.Repaired == true then
                            isRepaired = true
                        end
                        break
                    end
                end
                if targetMapData then
                    if not OriginalPos then OriginalPos = Root.CFrame end
                    local MapTool = Player.Backpack:FindFirstChild("Treasure Map") or Character:FindFirstChild("Treasure Map")
                    if not isRepaired then
                        _G.ThanHub_CurrentTarget = "Teleport Jack Marrow"
                        do
                            local jackTarget = CFrame.new(-2824.3, 214.3, 1518.1)
                            local sm = getgenv().LiyhubSafeMotion
                            if sm and sm.Teleport then
                                sm.Teleport(Root, jackTarget)
                            else
                                Root.CFrame = jackTarget
                            end
                        end
                        task.wait(0.45 + math.random() * 0.4)
                        if MapTool then
                            if MapTool.Parent ~= Character then
                                _G.ThanHub_CurrentTarget = "Equip Map..."
                                Hum:EquipTool(MapTool)
                                task.wait(0.25 + math.random() * 0.3)
                            end
                            local NPC = workspace.world.npcs:FindFirstChild("Jack Marrow")
                            if NPC then
                                local prompt = NPC:FindFirstChildWhichIsA("ProximityPrompt", true)
                                if prompt then
                                    _G.ThanHub_CurrentTarget = "Repair Map"
                                    local oldHold = prompt.HoldDuration
                                    prompt.HoldDuration = 0
                                    pcall(function()
                                        prompt:InputHoldBegin()
                                        task.wait(0.22 + math.random() * 0.26)
                                        prompt:InputHoldEnd()
                                    end)
                                    prompt.HoldDuration = oldHold
                                    task.wait(0.25 + math.random() * 0.25)
                                    local DialogInteract = ReplicatedStorage:WaitForChild("packages"):WaitForChild("Net"):WaitForChild("RF/DialogInteract")
                                    if DialogInteract then
                                        pcall(function()
                                            DialogInteract:InvokeServer(1, 1)
                                            task.wait(0.18 + math.random() * 0.2)
                                            DialogInteract:InvokeServer(6, 1)
                                        end)
                                    end
                                end
                            end
                        end
                    else
                        _G.ThanHub_CurrentTarget = "Collect Treasure Chest"
                        local foundChest = false
                        for _, v in pairs(workspace.world.chests:GetDescendants()) do
                            if v:IsA("Part") and (v.Name == "hitbox" or v:FindFirstChild("ChestSetup")) then
                                foundChest = true
                                do
                                    local chestTarget = v.CFrame * CFrame.new(0, 3, 0)
                                    local sm = getgenv().LiyhubSafeMotion
                                    if sm and sm.Teleport then
                                        sm.Teleport(Root, chestTarget)
                                    else
                                        Root.CFrame = chestTarget
                                    end
                                end
                                task.wait(0.45 + math.random() * 0.35)
                                local chestPrompt = v.Parent:FindFirstChildWhichIsA("ProximityPrompt", true)
                                if chestPrompt then
                                    local oldHold = chestPrompt.HoldDuration
                                    chestPrompt.HoldDuration = 0
                                    pcall(function()
                                        chestPrompt:InputHoldBegin()
                                        task.wait(0.22 + math.random() * 0.28)
                                        chestPrompt:InputHoldEnd()
                                    end)
                                    chestPrompt.HoldDuration = oldHold
                                    task.wait(1.6 + math.random() * 0.8)
                                end
                                break
                            end
                        end
                        if not foundChest then
                            _G.ThanHub_CurrentTarget = "Waiting for Chest..."
                        end
                    end
                else
                    if OriginalPos then
                        _G.ThanHub_CurrentTarget = "Returning to Start"
                        do
                            local sm = getgenv().LiyhubSafeMotion
                            if sm and sm.Teleport then
                                sm.Teleport(Root, OriginalPos)
                            else
                                Root.CFrame = OriginalPos
                            end
                        end
                        OriginalPos = nil
                    end
                    _G.ThanHub_CurrentTarget = "Idle"
                end
                task.wait(1.7 + math.random() * 0.8)
            end
        end)
    end,
})
TreasureMarrow:AddButton({
    Title = "Teleport to Jack Marrow",
    Callback = function()
        local target = CFrame.new(-2824.359, 214.311, 1518.130)
        local sm = getgenv().LiyhubSafeMotion
        if sm and sm.Teleport then
            sm.Teleport(HumanoidRootPart, target)
        else
            HumanoidRootPart.CFrame = target
        end
    end,
})
TreasureMarrow:AddButton({
    Title = "Instant Repair Map",
    Callback = function()
        local Player = game.Players.LocalPlayer
        local Character = Player.Character
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local DialogInteract = ReplicatedStorage:WaitForChild("packages"):WaitForChild("Net"):WaitForChild("RF/DialogInteract")
        local NPC = workspace.world.npcs:FindFirstChild("Jack Marrow")
        local Map = Player.Backpack:FindFirstChild("Treasure Map") or Character:FindFirstChild("Treasure Map")
        if Map and Map.Parent ~= Character then
            Character.Humanoid:EquipTool(Map)
            task.wait(0.2 + math.random() * 0.25)
        end
        if NPC then
            local prompt = NPC:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then
                local oldHold = prompt.HoldDuration
                prompt.HoldDuration = 0
                pcall(function()
                    prompt:InputHoldBegin()
                    task.wait(0.22 + math.random() * 0.26)
                    prompt:InputHoldEnd()
                end)
                prompt.HoldDuration = oldHold
                task.wait(0.2 + math.random() * 0.25)
                pcall(function()
                    DialogInteract:InvokeServer(1, 1)
                    task.wait(0.15 + math.random() * 0.2)
                    DialogInteract:InvokeServer(6, 1)
                end)
            end
        end
    end,
})
TreasureMarrow:AddButton({
    Title = "Collect Treasure",
    Callback = function()
        for _, v in ipairs(game:GetService("Workspace"):GetDescendants()) do
            if v.ClassName == "ProximityPrompt" then
                v.HoldDuration = 0
            end
        end
        for _, v in pairs(workspace.world.chests:GetDescendants()) do
            if v:IsA("Part") and v:FindFirstChild("ChestSetup") then
                local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local sm = getgenv().LiyhubSafeMotion
                    if sm and sm.Teleport then
                        sm.Teleport(hrp, v.CFrame)
                    else
                        hrp.CFrame = v.CFrame
                    end
                end
                task.wait(0.35 + math.random() * 0.3)
                for _, p in pairs(workspace.world.chests:GetDescendants()) do
                    if p.Name == "ProximityPrompt" then
                        pcall(fireproximityprompt, p)
                        task.wait(0.2 + math.random() * 0.25)
                    end
                end
                task.wait(0.8 + math.random() * 0.5)
            end
        end
    end,
})
Quest:AddSeperator({ Title = "Shady Rod Quest" })
SafeTotem.ShadyParagraph = Quest:AddParagraph({
    Title = "Shady Quest Status",
    Content = SafeTotem.ShadyStatusText(SafeTotem.ShadyStatus(), "Idle"),
})
function SafeTotem.ShadyReport(action)
    local paragraph = SafeTotem.ShadyParagraph
    if not paragraph or not paragraph.SetContent then return end
    pcall(paragraph.SetContent, paragraph, SafeTotem.ShadyStatusText(SafeTotem.ShadyStatus(), action))
end
Quest:AddToggle({
    Title = "Use Sundial Totem For Night",
    Content = "Uses a Sundial Totem from your backpack when the figure step needs night.",
    Default = false,
    Callback = function(value)
        SafeTotem.ShadyUseSundial = value
    end,
})
Quest:AddToggle({
    Title = "Auto Shady Quest",
    Content = "Todd figures, lighthouse riddle, Bazaar Guard, then buys the Shady Rod. Uses real prompts and dialog buttons only.",
    Default = false,
    Callback = function(value)
        SafeTotem.ShadyEnabled = value
        SafeTotem.ShadyToken += 1
        if not value then
            SafeTotem.ShadyReport("Stopped")
            return
        end
        local token = SafeTotem.ShadyToken
        task.spawn(function()
            local function active()
                return SafeTotem.ShadyEnabled and SafeTotem.ShadyToken == token
            end
            local lastStep, lastDetail, failures = nil, nil, 0
            local stopMessage
            while active() do
                local status = SafeTotem.ShadyStatus()
                local stepName, detail = SafeTotem.ShadyNextStep(status)
                SafeTotem.ShadyReport(SafeTotem.ShadyMessage(stepName, detail))
                if stepName == "owned" or stepName == "grind" or stepName == "coins" then
                    stopMessage = SafeTotem.ShadyMessage(stepName, detail)
                    break
                end
                if stepName == "night" then
                    if SafeTotem.ShadyUseSundial and not SafeTotem.Busy and SafeTotem.CountOwned("Sundial Totem") > 0 then
                        pcall(processTotem, "Sundial Totem")
                        task.wait(3)
                    else
                        task.wait(5)
                    end
                    continue
                end
                if SafeTotem.Busy then
                    task.wait(1)
                    continue
                end
                local root = SafeTotem.GetRoot()
                if not root then
                    task.wait(1)
                    continue
                end
                SafeTotem.Busy = true
                local origin = root.CFrame
                local ok, result = pcall(SafeTotem.ShadyRun, stepName, detail)
                local returnRoot = SafeTotem.GetRoot()
                if returnRoot and stepName ~= "buyrod" then
                    pcall(function() returnRoot.AssemblyLinearVelocity = Vector3.zero end)
                    returnRoot.CFrame = origin
                end
                SafeTotem.Busy = false
                result = ok and result or "error"
                if result == "bought" then
                    stopMessage = "Shady Rod bought. Quest complete."
                    break
                end
                if result == "dryrun" then
                    stopMessage = SafeTotem.ExplainService("Shady quest", "dryrun")
                    break
                end
                task.wait(2)
                local progressed = SafeTotem.ShadyNextStep(SafeTotem.ShadyStatus()) ~= stepName
                if stepName == "figure" then
                    local _, nextDetail = SafeTotem.ShadyNextStep(SafeTotem.ShadyStatus())
                    progressed = progressed or nextDetail ~= detail
                end
                if progressed or result == "talked" and stepName == "guard" then
                    failures = 0
                elseif stepName == lastStep and detail == lastDetail then
                    failures += 1
                else
                    failures = 1
                end
                lastStep, lastDetail = stepName, detail
                if failures >= 3 then
                    stopMessage = "Shady quest stuck on \"" .. stepName .. "\". " .. SafeTotem.ExplainService("Shady quest", result)
                    break
                end
                task.wait(1)
            end
            if SafeTotem.ShadyToken ~= token then return end
            SafeTotem.ShadyEnabled = false
            SafeTotem.ShadyReport(stopMessage or "Stopped")
            if stopMessage then SafeTotem.Notify(stopMessage) end
        end)
    end,
})
Quest:AddButton({
    Title = "Instant Open Shady Hatch",
    Content = "Bypass StreamingEnabled, open hatch, and teleport inside",
    Callback = function()
        if _G.ExecutingHatch then return end
        _G.ExecutingHatch = true
        local CollectionService = game:GetService("CollectionService")
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local LIGHTHOUSE_POS = Vector3.new(370, 126, 215)
        local function setModelTransparency(model, param)
            if not model then return end
            for _, entry in ipairs(model:GetDescendants()) do
                if entry:IsA("BasePart") or entry:IsA("Decal") or entry:IsA("Texture") then
                    entry.Transparency = param
                    if entry:IsA("BasePart") then
                        entry.CanCollide = (param == 0)
                    end
                end
            end
        end
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart", 5)
        if rootPart then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "ThanHub",
                Text = "Approaching Lighthouse...",
                Duration = 2
            })
            rootPart.CFrame = CFrame.new(LIGHTHOUSE_POS)
            local hatchInstance = nil
            local maxAttempts = 30
            local attempts = 0
            while not hatchInstance and attempts < maxAttempts do
                hatchInstance = CollectionService:GetTagged("LighthouseHatch")[1]
                if not hatchInstance then
                    task.wait(0.1)
                    attempts = attempts + 1
                end
            end
            if hatchInstance then
                local ShadyHatch = hatchInstance:WaitForChild("ShadyHatch", 5)
                local ShadyHatchOpen = hatchInstance:WaitForChild("ShadyHatchOpen", 5)
                if ShadyHatch and ShadyHatchOpen then
                    setModelTransparency(ShadyHatch, 1)
                    setModelTransparency(ShadyHatchOpen, 0)
                end
                rootPart.CFrame = hatchInstance:GetPivot() * CFrame.new(0, 2, 0)
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "ThanHub Success",
                    Text = "Hatch Bypassed Successfully!",
                    Duration = 3
                })
            else
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "ThanHub Error",
                    Text = "Map loaded too slow. Try clicking again!",
                    Duration = 4
                })
            end
        end
        _G.ExecutingHatch = false
    end
})
Quest:AddSeperator({ Title = "Jetski" })
Quest:AddToggle({
    Title    = "Auto Join Race",
    Default  = false,
    Callback = function(val)
        AutoJoinJetski = val
        task.spawn(function()
            while AutoJoinJetski do
                RemoteJoin:FireServer()
                task.wait(5)
            end
        end)
    end
})
Quest:AddToggle({
    Title    = "Instant Auto Win",
    Default  = false,
    Callback = function(val)
        AutoWinEnabled = val
    end
})
Quest:AddToggle({
    Title    = "Instant Turn",
    Default  = false,
    Callback = function(val)
        InstantTurnEnabled = val
    end
})
Quest:AddSlider({
    Title    = "Jetski Speed Multiplier",
    Min      = 1,
    Max      = 5,
    Default  = 1.5,
    Callback = function(val)
        BoatSpeedMultiplier = val
    end
})
Quest:AddSeperator({ Title = "Quest Angler" })
SafeTotem.AnglerParagraph = Quest:AddParagraph({
    Title = "Angler Quest Status",
    Content = SafeTotem.AnglerStatusText(nil, "Idle"),
})
Quest:AddDropdown({
    Title = "Angler Location",
    Content = "Auto Detect reads the location from your active quest.",
    Options = SafeTotem.AnglerOptions,
    Default = "Auto Detect",
    Callback = function(value)
        SafeTotem.AnglerChoice = type(value) == "table" and value[1] or value
    end,
})
Quest:AddToggle({
    Title = "Fish Quest Target",
    Content = "Teleports to the quest fishing zone and runs Auto Cast, Shake and Reel until the fish is caught.",
    Default = false,
    Callback = function(value)
        SafeTotem.AnglerFishTarget = value
        if not value then SafeTotem.AnglerSetFishing(false) end
    end,
})
Quest:AddToggle({
    Title = "Auto Angler",
    Content = "Takes the Angler quest, waits for the fish, then turns it in. Uses real prompts and dialog buttons only.",
    Default = false,
    Callback = function(value)
        SafeTotem.AnglerEnabled = value
        SafeTotem.AnglerToken += 1
        if not value then
            SafeTotem.AnglerSetFishing(false)
            SafeTotem.AnglerReport("Stopped")
            return
        end
        task.spawn(SafeTotem.AnglerLoop, SafeTotem.AnglerToken)
    end,
})
Quest:AddToggle({
    Title = "Auto Knock Door",
    Value = false,
    Callback = function(value)
        AutoKnockActive = value
        if value then
            task.spawn(AutoKnock)
        else
            AutoKnockActive = false
            UnfreezeCharacter()
        end
    end,
})
MineStatusParagraph = MineSection:AddParagraph({
    Title = "MINING STATUS",
    Content = "Checking stones...",
})
MineSection:AddToggle({
    Title = "Auto Mine",
    Content = "Automatically teleport and mine nearby stones.",
    Value = false,
    Callback = function(Value)
        autoMineEnabled = Value == true
        if autoMineEnabled then
            task.spawn(runAutoMine)
        end
    end,
})
InventoryValueParagraph = TradeFeature:AddParagraph({
    Title = "Inventory Value : Loading...",
})
TradeFeature:AddToggle({
    Title = "Hide Rarity Star",
    Content = "Toggle to hide or show fish rarity stars.",
    Value = false,
    Callback = function(Value)
        _sX.hideRarityEnable = Value
        task.spawn(function()
            hideFishRarity()
        end)
    end,
})
TradeFeature:AddToggle({
    Title = "Auto Accept Trade",
    Value = false,
    Callback = function(Value)
        _sX.autoconfirm = Value
        if Value then
            task.spawn(function()
                startAutoConfirm()
            end)
        end
    end,
})
TradeFeature:AddToggle({
    Title = "Auto Ready Trade",
    Value = false,
    Callback = function(Value)
        _sX.autoReady = Value
        if Value then
            task.spawn(function()
                startAutoReady()
            end)
        end
    end,
})
do
    local spawnAreasList = getSpawnAreas()
    _sX.SelectedArea = spawnAreasList[1] or "Moosewood"
    AreaDropdown = TeleportSection:AddDropdown({
        Title = "Select Area",
        Content = "Choose an area to teleport.",
        Options = spawnAreasList,
        Multi = false,
        Default = _sX.SelectedArea,
        Callback = function(selectedArea)
            _sX.SelectedArea = selectedArea
        end,
    })
    TeleportSection:AddButton({
        Title = "Teleport to Selected Area",
        Content = "Teleport to the chosen area",
        Callback = function()
            local selectedArea = _sX.SelectedArea or (AreaDropdown and AreaDropdown.Value) or "Moosewood"
            teleportToArea(selectedArea)
        end,
    })
end
OTHER:AddSeperator({
    Title = "Balloon Teleport"
})
BalloonDropdown = OTHER:AddDropdown({
    Title = "Select Balloon",
    Options = BalloonOptions,
    Multi = false,
    Value = "Select Balloon",
    Callback = function(value)
        SelectedBalloon = value
    end,
})
OTHER:AddButton({
    Title = "Confirm Teleport",
    Callback = function()
        if not SelectedBalloon then
            warn("No balloon selected!")
            return
        end
        pos = BalloonPositions[SelectedBalloon]
        if pos then
            teleportTo2(pos)
        end
    end,
})
OTHER:AddSeperator({
    Title = "Others Teleport"
})
OTHER:AddButton({
    Title = "Teleport to Active Nuclear",
    Content = "Klik untuk teleport ke Nuclear yang aktif",
    Callback = function()
        NuclearAreas = workspace:FindFirstChild("NuclearAreas")
        if not NuclearAreas then
            warn("NuclearAreas folder tidak ditemukan!")
            return
        end
        activeNuclear = nil
        for _, area in ipairs(NuclearAreas:GetChildren()) do
            if
            area:IsA("BasePart")
            or area:FindFirstChildWhichIsA("BasePart")
            then
                activeNuclear = area:FindFirstChildWhichIsA("BasePart") or area
                break
            end
        end
        if activeNuclear then
            lp = game.Players.LocalPlayer
            char = lp.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame =
                CFrame.new(activeNuclear.Position + Vector3.new(0, 5, 0))
            end
        else
            warn("Tidak ada Active Nuclear saat ini!")
        end
    end,
})
OTHER:AddInput({
    Title = "Teleport to Coordinate",
    Callback = function(value)
        player = game.Players.LocalPlayer
        hrp = player
        and player.Character
        and player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then
            warn("Character tidak ditemukan.")
            return
        end
        x, y, z = string.match(
            value,
            "(-?%d+%.?%d*),?%s*(-?%d+%.?%d*),?%s*(-?%d+%.?%d*)"
        )
        x, y, z = tonumber(x), tonumber(y), tonumber(z)
        if x and y and z then
            hrp.CFrame = CFrame.new(x, y, z)
            string.format(
                "Teleported to X: %.1f, Y: %.1f, Z: %.1f",
                x,
                y,
                z
            )
        else
            warn(
                "Format salah! Gunakan format: X, Y, Z (contoh: 100, 50, -300)"
            )
        end
    end,
})
OTHER:AddButton({
    Title = "Copy Coordinat",
    Content = "Copy to see your Coordinat",
    Callback = function()
        if
        LocalPlayer
        and LocalPlayer.Character
        and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        then
            XYZ = LocalPlayer.Character.HumanoidRootPart.Position
            coordString = string.format(
                "game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(%f, %f, %f)",
                XYZ.X,
                XYZ.Y,
                XYZ.Z
            )
            setclipboard(coordString)
        end
    end,
})
NPCDropdown = NPC:AddDropdown({
    Title = "Select NPC",
    Options = _sX.teleportNPC,
    Multi = false,
    Value = "Select NPC",
    Callback = function(value)
        _sX.NPCsTPDropdownUI = value
    end,
})
NPC:AddButton({
    Title = "Refresh NPC List",
    Content = "Update list of NPCs",
    Callback = function()
        _sX.npcCFrames = {}
        _sX.teleportNPC = {}
        local function recur(root)
            for _, v in ipairs(root:GetChildren()) do
                if (v:IsA("Model") or v:IsA("Part")) then
                    if not _sX.npcCFrames[v.Name] then
                        _sX.npcCFrames[v.Name] = v
                        table.insert(_sX.teleportNPC, v.Name)
                    end
                elseif v:IsA("Folder") then
                    recur(v)
                end
            end
        end
        recur(NpcFolder)
        table.sort(_sX.teleportNPC, function(a, b) return a:lower() < b:lower() end)
        if #_sX.teleportNPC == 0 then
            table.insert(_sX.teleportNPC, "No NPCs Found")
        end
        NPCDropdown:Refresh(_sX.teleportNPC)
    end,
})
NPC:AddButton({
    Title = "Teleport To Selection NPC",
    Content = "Click Button to Teleport",
    Callback = function()
        TeleportToNPC()
    end,
})
InteractDropdown = Int:AddDropdown({
    Title = "Select Interact",
    Options = _sX.teleportInteract,
    Multi = false,
    Value = "Select Interact",
    Callback = function(value)
        _sX.InteractDropDown = value
    end,
})
Int:AddSeperator("Interactables")
Int:AddButton({
    Title = "Refresh Interact List",
    Content = "Update list of Interacts",
    Callback = function()
        newList = {}
        for _, obj in ipairs(Interact:GetChildren()) do
            table.insert(newList, obj.Name)
        end
        if #newList == 0 then
            table.insert(newList, "No Interacts Found")
        end
        _sX.teleportInteract = newList
        InteractDropdown:Refresh(newList)
    end,
})
Int:AddButton({
    Title = "Teleport To Selection Interact",
    Content = "Click Button to Teleport",
    Callback = function()
        TeleportToInteract()
    end,
})
SavePosition:AddInput({
    Title = "Name Spot",
    Default = savedPositionName,
    Callback = function(val)
        if val and val ~= "" then
            savedPositionName = val
        end
    end
})
teleportPositionDropdown = SavePosition:AddDropdown({
    Title = "Saved Positions",
    Content = "Select a saved position to teleport",
    Multi = false,
    Options = {"None"},
    Default = "None",
    Callback = function(val)
        selectedPosition = val
    end
})
refreshDropdown()
SavePosition:AddButton({
    Title = "Save Position",
    Callback = function()
        if savedPositionName and savedPositionName ~= "" then
            character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                pos = character.HumanoidRootPart.Position
                savedPositions[savedPositionName] = {
                    X = pos.X,
                    Y = pos.Y,
                    Z = pos.Z
                }
                savePositionsToFile()
                refreshDropdown()
            end
        end
    end
})
SavePosition:AddButton({
    Title = "Teleport ke Posisi",
    Callback = function()
        if selectedPosition ~= "None" and savedPositions[selectedPosition] then
            character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                posData = savedPositions[selectedPosition]
                targetPosition = Vector3.new(posData.X, posData.Y, posData.Z)
                character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
            end
        end
    end
})
SavePosition:AddButton({
    Title = "Delete Selected Position",
    Callback = function()
        if selectedPosition ~= "None" and savedPositions[selectedPosition] then
            savedPositions[selectedPosition] = nil
            savePositionsToFile()
            refreshDropdown()
            selectedPosition = "None"
        end
    end
})
PlayerDropdownUI = PlayerTeleport:AddDropdown({
    Title = "Players",
    Options = _sX.PlayerDropdown,
    Multi = false,
    Value = nil,
    Callback = function(value)
        _sX.playertele = value
    end,
})
PlayerTeleport:AddButton({
    Title = "Refresh Player List",
    Content = "Update players in dropdown",
    Callback = function()
        newList = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                table.insert(newList, plr.Name)
            end
        end
        if #newList == 0 then
            table.insert(newList, "No players online")
        end
        _sX.PlayerDropdown = newList
        PlayerDropdownUI:Refresh(newList)
    end,
})
PlayerTeleport:AddButton({
    Title = "Teleport to Player",
    Content = "Click to teleport to the selected player.",
    Callback = function()
        selectedPlayerName = _sX.playertele
        if selectedPlayerName and selectedPlayerName ~= "No players online" then
            targetPlayer = Players:FindFirstChild(selectedPlayerName)
            if targetPlayer and targetPlayer.Character then
                targetCFrame = targetPlayer.Character:GetPivot()
                LocalPlayer.Character:PivotTo(targetCFrame)
            else
                warn("Target player not available.")
            end
        else
            warn("No player selected or no players online.")
        end
    end,
})
BestSpot:AddSeperator("Best Spots")
BestSpot:AddDropdown({
    Title = "Best Spot",
    Options = { "Money Farm", "XP Farm" },
    Callback = function(selected)
        selectedSpot = selected
    end,
})
BestSpot:AddButton({
    Title = "Teleport to Selected Best Spot",
    Callback = function()
        if not selectedSpot or not Locations[selectedSpot] then
            warn("Pilih lokasi dulu di dropdown!")
            return
        end
        character = game.Players.LocalPlayer.Character
        or game.Players.LocalPlayer.CharacterAdded:Wait()
        hrp = character:WaitForChild("HumanoidRootPart")
        hrp.CFrame = Locations[selectedSpot]
    end,
})
SaveConfig2:AddToggle({
    Title = "SaveConfig",
    Content = "Save ur Config",
    Value = false,
    Callback = function(value)
        whilesaveconfig = value
        if whilesaveconfig then
            task.spawn(function()
                while whilesaveconfig do
                    task.wait(0.4)
                    SaveConfig()
                end
            end)
        end
    end,
})
Other:AddToggle({
    Title = "Auto Respawn at Death Pos",
    Default = false,
    Callback = function(Value)
        _G.AutoRespawnDeathPos = Value
        if Value then
        else
            lastDeathCFrame = nil
        end
    end
})
Other:AddToggle({
    Title = "Protect Identity",
    Value = false,
    Callback = function(value)
        task.spawn(function()
            toggleStreamerMode(value)
        end)
    end,
})
Other:AddToggle({
    Title = "Delete All Characters",
    Value = false,
    Callback = function(value)
        if value then
            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    player.Character:Destroy()
                end
            end
        end
    end,
})
Other:AddToggle({
    Title = "Delete All Map",
    Default = false,
    Callback = function(value)
        task.spawn(function()
            if value then
                if
                workspace:FindFirstChild("world")
                and workspace.world:FindFirstChild("map")
                then
                    workspace.world.map:Destroy()
                end
            end
        end)
    end,
})
Other:AddToggle({
    Title = "Freeze Character",
    Value = false,
    Content = "Stops movement but allows fishing.",
    Callback = function(isEnabled)
        task.spawn(function()
            V_FreezeCharacter = isEnabled
            oldpos = nil
            local frozenStamp = SafeMotion.TeleportStamp or 0
            while V_FreezeCharacter do
                local freezeRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if freezeRoot then
                    if (SafeMotion.TeleportStamp or 0) ~= frozenStamp then
                        frozenStamp = SafeMotion.TeleportStamp or 0
                        oldpos = nil
                        task.wait(0.35)
                    end
                    if oldpos == nil then
                        oldpos = freezeRoot.CFrame
                    end
                    freezeRoot.CFrame = oldpos
                    freezeRoot.AssemblyLinearVelocity = Vector3.zero
                end
                task.wait()
            end
        end)
    end,
})
Other:AddToggle({
    Title = "Walk On Water",
    Content = "if you are underwater and turn this on, it will automatically be above",
    Value = false,
    Callback = function(value)
        task.spawn(function()
            updateCanCollide(value)
        end)
    end,
})
Other:AddSlider({
    Title = "Jump Height",
    Min = 50,
    Max = 200,
    Default = 50,
    Increment = 1,
    Callback = function(value)
        CurrentJumpPower = value
        applyValues()
    end,
})
Other:AddToggle({
    Title = "Noclip",
    Content = "Penetrates all walls or objects",
    Value = false,
    Callback = function(value)
        _sX.Noclip = value
    end,
})
Oxygen:AddSeperator("Oxygen")
Oxygen:AddToggle({
    Title = "Infinite Oxygen",
    Value = false,
    Callback = function(value)
        ToggleWalkUnderwater(value)
    end
})
local fogStashFolder = nil
local storedFogEnd = nil
Misc:AddToggle({
    Title = "Remove Fog",
    Value = false,
    Callback = function(Value)
        local lighting = game:GetService("Lighting")
        if Value then
            fogStashFolder = fogStashFolder or Instance.new("Folder")
            for _, effect in ipairs(lighting:GetChildren()) do
                if effect:IsA("Sky") or effect:IsA("Atmosphere") then
                    effect.Parent = fogStashFolder
                end
            end
            storedFogEnd = storedFogEnd or lighting.FogEnd
            lighting.FogEnd = 1e9
            return
        end
        if fogStashFolder then
            for _, effect in ipairs(fogStashFolder:GetChildren()) do
                effect.Parent = lighting
            end
        end
        if storedFogEnd then
            lighting.FogEnd = storedFogEnd
            storedFogEnd = nil
        end
    end,
})
Misc:AddToggle({
    Title = "Day Only",
    Value = false,
    Callback = function(Value)
        if DayOnlyLoop then
            DayOnlyLoop:Disconnect()
            DayOnlyLoop = nil
        end
        if not Value then return end
        local lighting = game:GetService("Lighting")
        lighting.ClockTime = 12
        DayOnlyLoop = lighting:GetPropertyChangedSignal("ClockTime"):Connect(function()
            if lighting.ClockTime ~= 12 then
                lighting.ClockTime = 12
            end
        end)
    end,
})
Misc:AddToggle({
    Title = "Mute Reeling Sound",
    Value = false,
    Callback = function(value)
        _sX.ToggleReelingSound = value == true
        task.spawn(ToggleReeling, _sX.ToggleReelingSound)
    end,
})
Misc:AddToggle({
    Title = "Hide UI",
    Content = "Boost FPS Maybe",
    Default = true,
    Callback = function(state)
        _sX.BlackShow = state
        if _sX.BlackShow then
            PlayerGui.hud.safezone.Visible = true
        else
            PlayerGui.hud.safezone.Visible = false
        end
    end,
})
local function setAntiAfk(enabled)
    afkActive = enabled == true
    if afkConnection then
        afkConnection:Disconnect()
        afkConnection = nil
    end
    if not afkActive then return end
    afkConnection = LocalPlayer.Idled:Connect(function()
        if VirtualUser then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.zero)
            end)
            return
        end
        if keypress and keyrelease then
            pcall(function()
                keypress(0x20)
                task.wait(0.1)
                keyrelease(0x20)
            end)
        end
    end)
end
setAntiAfk(afkActive)
Misc:AddToggle({
    Title = "Anti-AFK",
    Default = true,
    Callback = function(enabled)
        setAntiAfk(enabled)
    end,
})
local radarDescendantConnection = nil
Misc:AddToggle({
    Title = "Bypass Fish Radar",
    Value = false,
    Callback = function(value)
        BypassRadar = value == true
        local fishingFolder = workspace:FindFirstChild("zones")
        and workspace.zones:FindFirstChild("fishing")
        if not fishingFolder then return end
        for _, gui in ipairs(fishingFolder:GetDescendants()) do
            if gui:IsA("SurfaceGui") then
                gui.Enabled = BypassRadar
            end
        end
        if radarDescendantConnection then
            radarDescendantConnection:Disconnect()
            radarDescendantConnection = nil
        end
        if not BypassRadar then return end
        radarDescendantConnection = fishingFolder.DescendantAdded:Connect(function(obj)
            if obj:IsA("SurfaceGui") then
                obj.Enabled = BypassRadar
            end
        end)
    end,
})
Misc:AddButton({
    Title = "Remove Pasif Rod",
    Callback = function()
        checkAndRemoveTree()
    end,
})
Misc:AddButton({
    Title = "Redeem All Codes",
    Content = "Redeem all active Fisch codes.",
    Variant = "Primary",
    Callback = function()
        activeCodes = {
            "THEKRAKEN",
            "RFG",
            "CARBON",
            "SORRYGUYS",
            "ATLANTEANSTORM",
            "GOLDENTIDE",
            "GOODBYEFISCHMAS",
            "NewYear",
            "1BVisits",
            "RRG",
            "NorthernExpedition",
        }
        for _, code in ipairs(activeCodes) do
            ReplicatedStorage:WaitForChild("events")
            :WaitForChild("runcode")
            :FireServer(code)
        end
    end,
})
Misc:AddButton({
    Title = "Discover All Locations",
    Variant = "Primary",
    Callback = function()
        for key, value in pairs(data.Locations) do
            ReplicatedStorage:WaitForChild("events")
            :WaitForChild("discoverlocation")
            :FireServer(key)
        end
    end,
})
Misc:AddButton({
    Title = "Respawn / Die",
    Callback = function()
        LocalPlayer.Character:WaitForChild("Humanoid").Health = 0
        wait()
    end,
})
Misc:AddButton({
    Title = "Boost FPS !",
    Callback = function()
        ToDisable = {
            Textures = true,
            VisualEffects = true,
            Parts = true,
            Particles = true,
            Sky = true,
        }
        ToEnable = {
            FullBright = false,
        }
        Stuff = {}
        for _, v in next, game:GetDescendants() do
            if ToDisable.Parts then
                if v:IsA("Part") or v:IsA("Union") or v:IsA("BasePart") then
                    v.Material = Enum.Material.SmoothPlastic
                    table.insert(Stuff, 1, v)
                end
            end
            if ToDisable.Particles then
                if
                v:IsA("ParticleEmitter")
                or v:IsA("Smoke")
                or v:IsA("Explosion")
                or v:IsA("Sparkles")
                or v:IsA("Fire")
                then
                    v.Enabled = false
                    table.insert(Stuff, 1, v)
                end
            end
            if ToDisable.VisualEffects then
                if
                v:IsA("BloomEffect")
                or v:IsA("BlurEffect")
                or v:IsA("DepthOfFieldEffect")
                or v:IsA("SunRaysEffect")
                then
                    v.Enabled = false
                    table.insert(Stuff, 1, v)
                end
            end
            if ToDisable.Textures then
                if v:IsA("Decal") or v:IsA("Texture") then
                    v.Texture = ""
                    table.insert(Stuff, 1, v)
                end
            end
            if ToDisable.Sky then
                if v:IsA("Sky") then
                    v.Parent = nil
                    table.insert(Stuff, 1, v)
                end
            end
        end
        game:GetService("TestService"):Message(
            "Effects Disabler Script : Successfully disabled "
            .. #Stuff
            .. " assets / effects. Settings :"
        )
        for i, v in next, ToDisable do
        end
        if ToEnable.FullBright then
            Lighting = game:GetService("Lighting")
            Lighting.FogColor = Color3.fromRGB(255, 255, 255)
            Lighting.FogEnd = math.huge
            Lighting.FogStart = math.huge
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = 5
            Lighting.ColorShift_Bottom = Color3.fromRGB(255, 255, 255)
            Lighting.ColorShift_Top = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            Lighting.Outlines = true
        end
    end,
})
Screen:AddSeperator("Screen Optimization")
Screen:AddToggle({
    Title = "White Screen",
    Default = false,
    Callback = function(Value)
        if Value then
            EnableWhiteScreen()
        else
            DisableScreen()
        end
    end,
})
Screen:AddToggle({
    Title = "Black Screen",
    Default = false,
    Callback = function(Value)
        if Value then
            EnableBlackScreen()
        else
            DisableScreen()
        end
    end,
})
ESPFeature:AddToggle({
    Title = "Event Zone ESP",
    Value = _sX.FishingESP,
    Callback = function(value)
        _sX.FishingESP = value
        ESPEnabled = value
        if value then
            scanFishing()
        else
            clearESP()
        end
    end,
})
ESPFeature:AddToggle({
    Title = "Area ESP",
    Value = _sX.AreaESP,
    Callback = function(value)
        _sX.AreaESP = value
        if not value then
            clearAreaESP()
        end
    end,
})
EventHuntSection:AddSeperator({
    Title = "Hunting Target",
})
EventHuntSection:AddDropdown({
    Title = "Select Hunting Target",
    Value = _sX.selecthuntigtarget or {},
    Multi = true,
    Options = {
        "Orca",
        "Moby",
        "Baby Bloop Fish",
        "Bloop Fish",
        "Whales Pool",
        "Megalodon Default",
        "Megalodon Ancient",
        "Megalodon Phantom",
        "Great White Shark",
        "Hammerhead Shark",
        "Whale Shark",
        "The Depths - Serpent",
        "Isonade (Strange Whirlpool)",
        "Blarney McBreeze",
        "Sea Leviathan Pool",
        "Animal Pool",
        "Octophant Pool Without Elephant",
        "Kraken Pool",
        "Blue Moon - Sea 2",
        "Blue Moon - First Sea",
        "Lego Pool",
        "Studolodon Pool",
        "Mosslurker",
        "Narwhal",
        "Birthday Megalodon",
        "Frightful Pool",
        "Tidefall Hunt",
        "MossjawHunt",
        "BrineStorm",
        "KrakenHunt",
        "MegHunt",
        "MoonlitMirage",
        "ScyllaHunt",
        "ReefTitan",
        "FrostwyrmHunt",
        "The Sanctum Hunt",
        "The Sanctum Profane Hunt",
        "DepthsAbsoluteDarkness",
        "Colossal Blue Dragon",
        "Colossal Ancient Dragon",
        "Colossal Ethereal Dragon",
        "SkeletalLeviathanHunt",
        "WyvernHunt",
        "NectarBloom",
        "RotbloomHunt",
        "FlowerGuardianHunt"
    },
    Callback = function(Value)
        _sX.Hunting_Target = Value
    end,
})
EventHuntSection:AddSlider({
    Title = "Height Offset",
    Content = "Atur tinggi posisi di atas target",
    Min = -50,
    Max = 200,
    Default = 50,
    Increment = 1,
    Callback = function(value)
        _sX.Hunting_Height = value
    end,
})
EventHuntSection:AddToggle({
    Title = "Hunt Target",
    Value = _sX.hunttargetv,
    Callback = function(Value)
        if Value ~= true then
            EventHunt.StopHunt()
            return
        end
        if #EventHunt.GetSelectedTargets() == 0 then
            EventHunt.Notify("Hunt Target", "Waiting for a hunting target selection.")
        end
        EventHunt.StartHunt()
    end,
})
EventHuntSection:AddToggle({
    Title = "Auto Ashclaw",
    Value = _sX.autoashclaw_en,
    Callback = function(Value)
        if Value == true then
            EventHunt.StartAshclaw()
        else
            EventHunt.StopAshclaw()
        end
    end,
})
EventHuntSection:AddSeperator({
    Title = "Auto When Event",
})
EventHuntSection:AddParagraph({
    Title = "You must select a hunt target for the features below to work.",
})
TotemEventDropdown = EventHuntSection:AddDropdown({
    Title = "Select Event Totem",
    Options = {
        "Sundial Totem",
        "Aurora Totem",
        "Tempest Totem",
        "Smokescreen Totem",
        "Windset Totem",
        "Eclipse Totem",
        "Meteor Totem",
        "Blizzard Totem",
        "Avalanche Totem",
        "Zeus Storm Totem",
        "Poseidon Wrath Totem",
        "Mutation Totem",
        "Shiny Totem",
        "Sparkling Totem",
    },
    Value = _sX.selecteventtotem,
    PlaceHolder = "Select Totem - Event",
    Multiple = false,
    Callback = function(selected)
        genv.SelectedEventTotem = selected
    end,
})
EventHuntSection:AddToggle({
    Title = "Auto Totem (When Target Spawn)",
    Value = _sX.autototemtarget,
    Callback = function(enabled)
        genv.AutoTotemEvent = enabled == true
        if not genv.AutoTotemEvent then
            EventHunt.SetTrigger("Totem", nil)
            return
        end
        if type(genv.SelectedEventTotem) ~= "string" or genv.SelectedEventTotem == "" then
            EventHunt.Notify("Auto Totem", "Select an event totem first.")
        end
        if #EventHunt.GetSelectedTargets() == 0 then
            EventHunt.Notify("Auto Totem", "Waiting for a hunting target selection.")
        end
        EventHunt.SetTrigger("Totem", function()
            task.wait(0.8)
            EventHunt.UseEventTotem(genv.SelectedEventTotem)
        end)
    end,
})
EventHuntSection:AddDropdown({
    Title = "Select Event Rod",
    Options = _sX.rodNames,
    Value = _sX.selectedeventrod,
    PlaceHolder = "Choose Rod to Equip When Event Spawns",
    Multi = false,
    Callback = function(selected)
        SelectedEventRod = selected
    end,
})
EventHuntSection:AddToggle({
    Title = "Auto Equip Rod (When Target Spawn)",
    Value = _sX.autoequiprod_v,
    Callback = function(enabled)
        genv.AutoEquipRodEvent = enabled == true
        if not genv.AutoEquipRodEvent then
            EventHunt.SetTrigger("EquipRod", nil)
            return
        end
        if type(SelectedEventRod) ~= "string" or SelectedEventRod == "" or SelectedEventRod == "Select Rod" then
            EventHunt.Notify("Auto Equip Rod", "Select an event rod first.")
        end
        if #EventHunt.GetSelectedTargets() == 0 then
            EventHunt.Notify("Auto Equip Rod", "Waiting for a hunting target selection.")
        end
        EventHunt.SetTrigger("EquipRod", function(_, targetName)
            EventHunt.EquipEventRod(SelectedEventRod, targetName)
        end)
    end,
})
JoinJob:AddInput({
    Title = "Enter Job ID",
    Content = "Job ID in Discord\10ThanHub > Webhook Tracker",
    Value = "",
    Callback = function(value)
        _sX.JobIDInput = value
    end,
})
JoinJob:AddButton({
    Title = "Join Job ID",
    Content = "Join server using job ID input.",
    Callback = function()
        if _sX.JobIDInput then
            placeId = game.PlaceId
            jobId = _sX.JobIDInput
            game:GetService("TeleportService")
            :TeleportToPlaceInstance(
                placeId,
                jobId,
                game.Players.LocalPlayer
            )
        end
    end,
})
Server:AddSeperator("Server Utilities")
Server:AddButton({
    Title = "Low-Server",
    Content = "Join a old server low player in the same game.",
    Callback = function()
        HopToServer()
    end,
})
Server:AddButton({
    Title = "Hop To Newbie Server",
    Callback = function()
        if game.PlaceId ~= targetPlaceId then
            TeleportService:Teleport(targetPlaceId, LocalPlayer)
        else
        end
    end,
})
Server:AddButton({
    Title = "Rejoin Server",
    Content = "",
    Callback = function()
        game:GetService("TeleportService")
        :Teleport(game.PlaceId, game:GetService("Players").LocalPlayer)
    end,
})
Server:AddToggle({
    Title = "Auto-Rejoin",
    Default = true,
    Callback = function(enabled)
        task.spawn(function()
            if enabled then
                _G.AutoRejoin = true
                getgenv().RejoinConnection = game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded
                :Connect(function(child)
                    if
                    child.Name == "ErrorPrompt"
                    and child:FindFirstChild("MessageArea")
                    and child.MessageArea:FindFirstChild("ErrorFrame")
                    then
                        game:GetService("TeleportService")
                        :Teleport(game.PlaceId)
                    end
                end)
            else
                _G.AutoRejoin = false
                if getgenv().RejoinConnection then
                    getgenv().RejoinConnection:Disconnect()
                    getgenv().RejoinConnection = nil
                end
            end
        end)
    end,
})
Server:AddToggle({
    Title = "Auto Kick Staff/Admin",
    Default = true,
    Callback = function(state)
        autoKickStaff = state
    end,
})
Caught:AddInput({
    Title = "Webhook URL",
    Placeholder = "https://discord.com/api/webhooks/...",
    Default = _sX.webhookFishURL,
    Callback = function(value)
        _sX.webhookFishURL = value
    end,
})
Caught:AddDropdown({
    Title   = "Webhook Target Fish (List)",
    Options = webhookFishNameOptions,
    Multi   = true,
    Default = {},
    Callback = function(v)
        _sX.webhookSelectedFish = {}
        if type(v) == "table" then
            for selection, state in pairs(v) do
                if state == true then
                    _sX.webhookSelectedFish[string.lower(tostring(selection))] = true
                elseif type(state) == "string" then
                    _sX.webhookSelectedFish[string.lower(tostring(state))] = true
                end
            end
        end
    end
})
Caught:AddDropdown({
    Title   = "Webhook Rarity Filter",
    Options = webhookRarityOptions,
    Multi   = true,
    Default = {},
    Callback = function(v)
        _sX.webhookTargetRarities = {}
        countRar = 0
        if type(v) == "table" then
            for selection, state in pairs(v) do
                lowName = string.lower(tostring(selection))
                if state == true and lowName ~= "all" then
                    _sX.webhookTargetRarities[lowName] = true
                    countRar = countRar + 1
                end
            end
        end
        _sX.webhookRarityFilterAktif = (countRar > 0)
    end
})
Caught:AddDropdown({
    Title   = "Webhook Mutation Filter",
    Options = webhookMutationOptions,
    Multi   = true,
    Default = {},
    Callback = function(v)
        _sX.webhookTargetMutations = {}
        countMut = 0
        if type(v) == "table" then
            for selection, state in pairs(v) do
                lowName = string.lower(tostring(selection))
                if state == true and lowName ~= "none" and lowName ~= "normal" then
                    _sX.webhookTargetMutations[lowName] = true
                    countMut = countMut + 1
                end
            end
        end
        _sX.webhookMutationFilterAktif = (countMut > 0)
    end
})
Caught:AddDropdown({
    Title   = "Webhook Special Mutation",
    Options = {"Sparkling", "Shiny"},
    Multi   = true,
    Default = {},
    Callback = function(v)
        _sX.webhookTargetSpecial = {}
        if type(v) == "table" then
            for selection, state in pairs(v) do
                if state == true then
                    _sX.webhookTargetSpecial[string.lower(tostring(selection))] = true
                end
            end
        end
        _sX.webhookSpecialFilterAktif = next(_sX.webhookTargetSpecial) ~= nil
    end
})
Caught:AddToggle({
    Title = "Send Fish to Webhook",
    Value = _sX.webhookFishEnable,
    Callback = function(value)
        _sX.webhookFishEnable = value
    end,
})
Fluent = {
    Notify = function(self, cfg)
        if type(self) == "table" and not cfg and self.Title then cfg = self end
        cfg = cfg or {}
        pcall(function()
            WindUI:Notify({
                Title = cfg.Title or "Fisch",
                Content = cfg.Content or cfg.SubContent or "",
                Duration = cfg.Duration or 4
            })
        end)
    end
}
Tabs.Main:Select()
WindUI:Notify({
    Title = "Fisch",
    Content = "Successfully loaded WindUI Edition!",
    Duration = 5
})
