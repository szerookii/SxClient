local config = {}
config.isAutoWalkEnabled = false
config.isAutoSprintEnabled = false
config.isHighJumpEnabled = false
config.isImmortalityEnabled = false
config.isInstakillEnabled = false
config.isTapTeleportEnabled = false
config.isTwerkEnabled = false
config.isKillauraEnabled = false
config.isJetpackEnabled = false
config.isGlideEnabled = false
config.isAirjumpEnabled = false
config.isJetpackBEnabled = false

settings = {}
settings.isMobKillaura = true
settings.killauraDistance = 10

local MTN = {}
MTN.isAutoWalkEnabled = "AutoWalk"
MTN.isAutoSprintEnabled = "ToggleSprint"
MTN.isHighJumpEnabled = "HighJump"
MTN.isImmortalityEnabled = "Immortality"
MTN.isInstakillEnabled = "InstaKill"
MTN.isTapTeleportEnabled = "TapTP"
MTN.isTwerkEnabled = "Twerk"
MTN.isKillauraEnabled = "KillAura"
MTN.isJetpackEnabled = "JetPack"
MTN.isGlideEnabled = "Glide"
MTN.isAirjumpEnabled = "AirJump"
MTN.isJetpackBEnabled = "JetPack (Bypass)"

local presets = { 3, 4, 5, 6, 7, 8, 9, 10 }
local tickJet = 0
local tickNum = 0
local tickNumMob = 0

function drawName(context)
    local font = context:getFont()
    
    -- Params
    local text = "SxClient"
    local x = 0
    local y = 5
    local spacing = 0.5
    local scale = 1
    local textVerticalSpacing = 1
    local textScale = 1.5
    
    -- Writting
    font:drawTransformed(context:getScreenContext(), text, x + 16 * scale + spacing * scale, y + textVerticalSpacing * scale, 1, 1, 1, 1, 0, font:getLineLength(text, 1, false), false, textScale)
    
    -- Set variables for 2nd text
    text = "Private Client"
    textScale = 1
    y = 18
    
    -- Write the text
    font:drawTransformed(context:getScreenContext(), text, x + 16 * scale + spacing * scale, y + textVerticalSpacing * scale, 1, 1, 1, 1, 0, font:getLineLength(text, 1, false), false, textScale)
    
    if minecraft.clientinstance:isShowingMenu() then
        return
    end
    
    -- Write module list lol
    text = ""
    x = 550
    y = 0
    
    for i, v in pairs(config) do
        if config[i] ~= false then
            text = MTN[i]
            y = y + 15
            font:drawTransformed(context:getScreenContext(), text, x + 16 * scale + spacing * scale, y + textVerticalSpacing * scale, 1, 1, 1, 1, 0, font:getLineLength(text, 1, false), false, textScale)
        end
    end
end

local function disableAllCheats()
    for i, v in pairs(config) do
        config[i] = false
    end
    ---@param event playeruseitemonevent
    local function cheatsUseItemOnHook(event)
        if config.isTapTeleportEnabled then
            local x, y, z = event:getPos()
            event:getPlayer():teleportTo(x, y + 0.5, z)
        end
    end
end

---@param event moveinputhandlertickevent
local function cheatsMoveHook(event)
    if config.isAirjumpEnabled and event:getInputHandler():getJump() then
        local player = minecraft.clientinstance:getLocalPlayer()
        local vX, vY, vZ = player:getVelocity()
        player:setVelocity(vX, 0.42, vZ)
    end
    if config.isTwerkEnabled then
        event:getInputHandler():setToggleSneak(true)
        event:getInputHandler():setToggleSneak(false)
    end
    if config.isAutoSprintEnabled then
        event:getInputHandler():setSprint(true)
    end
    if config.isAutoWalkEnabled then
        event:getInputHandler():setUp(true)
    end
end

---@param event mobjumpevent
local function cheatsJumpHook(event)
    if config.isHighJumpEnabled and event:getMob():getUniqueID() == minecraft.clientinstance:getLocalPlayer():getUniqueID() then
        event:setJumpPower(event:getJumpPower() * 1.41)
    end
end

---@param event playeruseitemonevent
local function cheatsUseItemOnHook(event)
    if config.isTapTeleportEnabled then
        local x, y, z = event:getPos()
        event:getPlayer():teleportTo(x, y + 1, z)
    end
end

local function cheatsKillauraHook()
    if config.isKillauraEnabled then
        tickNum = tickNum + 1
        if tickNum == 2 then
            tickNum = 0
            local player = minecraft.clientinstance:getLocalPlayer()
            local level = player:getLevel()
            local hitResultOld = level:getHitResult()
            local pX, pY, pZ = player:getPos()
            
            level:forEachPlayer(function(p)
                local x, y, z = p:getPos()
                if p ~= player and math.abs(x - pX) + math.abs(y - pY) + math.abs(z - pZ) <= settings.killauraDistance then
                    level:setHitResult(minecraft.hitresult.newFromActor(0, 0, 0, 0, 0, 0, p))
                    minecraft.clientinputcallbacks:handleBuildOrAttackButtonPress()
                end
            end)
            level:setHitResult(hitResultOld)
        end
    end
end

local function cheatsMobKillauraHook()
    if config.isKillauraEnabled then
        tickNumMob = tickNumMob + 1
        if tickNumMob == 2 then
            tickNumMob = 0
            local player = minecraft.clientinstance:getLocalPlayer()
            local level = player:getLevel()
            local hitResultOld = level:getHitResult()
            local pX, pY, pZ = player:getPos()
            
            if settings.isMobKillaura then
                player:getDimension():forEachMob(function(mob)
                    local x, y, z = mob:getPos()
                        if mob:isMob() and math.abs(x - pX) + math.abs(y - pY) + math.abs(z - pZ) <= settings.killauraDistance then
                        level:setHitResult(minecraft.hitresult.newFromActor(0, 0, 0, 0, 0, 0, mob))
                        minecraft.clientinputcallbacks:handleBuildOrAttackButtonPress()
                    end
                end)
                level:setHitResult(hitResultOld)
            end
        end
    end
end

local function jetpack()
    if not config.isJetpackEnabled or minecraft.clientinstance:isShowingMenu() then
        return
    end
    
    local player = minecraft.clientinstance:getLocalPlayer()
    local x, y, z = player:getPos()
    local pitch, yaw = player:getRotation()
    local one = yaw + 90
    local two = pitch - 180
    local pX = math.cos(one * (math.pi/180))
    local pY = math.sin(two * (math.pi/180))
    local pZ = math.sin(one * (math.pi/180))
    
    player:setVelocity(pX, pY, pZ)
end

local function jetpackBypass()
    if not config.isJetpackBEnabled or minecraft.clientinstance:isShowingMenu() then
        return
    end
    
    local player = minecraft.clientinstance:getLocalPlayer()
    local pitch, yaw = player:getRotation()
    local one = yaw + 90
    local two = pitch - 180
    local vX = math.cos(one * (math.pi/180))
    local vZ = math.sin(one * (math.pi/180))
    
    tickJet = tickJet + 1
    
    if tickJet >= 5 then
        local vY = 0.465
        player:setVelocity(vX/3, vY, vZ/3)
        
        local tpX = math.cos(calcYaw) * math.cos(calcPitch) * 0.00000005
        local tpZ = math.sin(calcYaw) * math.cos(calcPitch) * 0.00000005
        
        local x, y, z = player:getPos()
        --player:teleportTo(x + tpX, y - 0.15, z + tpZ)
        
        local pX, pY, pZ = player:getVelocity()
        player:setVelocity(pX, 0.15, pZ)
		tickJet = 0
    end
end

local function glide()
    if not config.isGlideEnabled then
        return
    end
    
    local player = minecraft.clientinstance:getLocalPlayer()
    local vX, vY, vZ = player:getVelocity()
    local y = -0.02
    player:setVelocity(vX, y, vZ)
end

local function aimAt(posX, posY, posZ)
    local player = minecraft.clientinstance:getLocalPlayer()
    local pX, pY, pZ = player:getPos()
    local x = posX - pX
    local y = posY - pY
    local z = posZ - pZ
    local a = 0.5 + posX
    local b = y
    local c = 0.5 + z
    local len = math.sqrt(x * x + y * y + z * z)
    y = y / len
    local pitch = math.asin(y)
    pitch = pitch * 180.0 / math.pi
    pitch = -pitch
    local yaw = -math.atan2(a - (pX + 0.5), c - (pZ + 0.5)) * ( 180 / math.pi)
    if pitch < 89 and pitch > -89 then
        -- Aim
        player:setRotation(pitch, yaw)
    end
end


---@param nid networkidentifier
---@param data string
function minecraft.packet.immortalityStateChanged(nid, data)
    config.isImmortalityEnabled = (data == "enabled")
end

---@param nid networkidentifier
---@param data string
function minecraft.packet.instakillStateChanged(nid, data)
    config.isInstakillEnabled = (data == "enabled")
end

---@param controller screencontroller
local function registerCheat(controller, name, toggleName, toggleBindingName)
    controller:registerToggleChangeEventHandler(toggleName, function(propertyBag, value, radioValue)
        config[name] = value
        toolbox.analytics.logEvent("cheats_" .. name, "value", value)
    end)
    controller:bindBool(toggleBindingName, function()
        return config[name]
    end)
end

---@param controller screencontroller
local function registerSettings(controller, name, toggleName, toggleBindingName)
    controller:registerToggleChangeEventHandler(toggleName, function(propertyBag, value, radioValue)
        settings[name] = value
        toolbox.analytics.logEvent("cheats_" .. name, "value", value)
    end)
    controller:bindBool(toggleBindingName, function()
        return settings[name]
    end)
end

---@param controller screencontroller
local function registerServerCheat(controller, name, toggleName, toggleBindingName, packetName)
    controller:registerToggleChangeEventHandler(toggleName, function(propertyBag, value, radioValue)
        config[name] = value
        local packetSender = minecraft.clientinstance:getPacketSender()
        if value then
            packetSender:sendToServer(packetName, "enabled")
        else
            packetSender:sendToServer(packetName, "disabled")
        end
    end)
    controller:bindBool(toggleBindingName, function()
        return config[name]
    end)
end

local function registerSlider(controller, name, sliderName, bindingName, bindingBox)
    controller:registerSliderChangedEventHandler(sliderName, function(val)
        settings[name] = presets[math.floor(val) + 1]
    end)
    controller:bindInt(bindingName, function()
        for i, v in ipairs(presets) do
            if v == settings[name] then
                return i
            end
        end
        return 3
    end)
    controller:bindString(bindingBox, function()
        return tostring(settings[name])
    end)
end

local function renderTradeHook(ev)
    context = ev:getContext()
    context = minecraft.baseactorrendercontext.new(context:getScreenContext())
    
    drawName(context)
end

---@param controller screencontroller
local function init(controller)
    --Player
    registerCheat(controller, "isAutoWalkEnabled", "toggle.autowalk", "#autowalk_enabled")
    registerCheat(controller, "isHighJumpEnabled", "toggle.high_jump", "#high_jump_enabled")
    registerServerCheat(controller, "isImmortalityEnabled", "toggle.immortality", "#immortality_enabled", "immortality")
    registerCheat(controller, "isTapTeleportEnabled", "toggle.tap_teleport", "#tap_teleport_enabled")
    registerCheat(controller, "isAutoSprintEnabled", "toggle.auto_sprint", "#auto_sprint_enabled")
    registerCheat(controller, "isTwerkEnabled", "toggle.twerk", "#twerk_enabled")
    registerCheat(controller, "isJetpackEnabled", "toggle.jetpack", "#jetpack_enabled")
    registerCheat(controller, "isGlideEnabled", "toggle.glide", "#glide_enabled")
    registerCheat(controller, "isAirjumpEnabled", "toggle.airjump", "#airjump_enabled")
    registerCheat(controller, "isJetpackBEnabled", "toggle.jetpackb", "#jetpackb_enabled")

    --Combat
    registerServerCheat(controller, "isInstakillEnabled", "toggle.instakill", "#instakill_enabled", "instakill");
    registerCheat(controller, "isKillauraEnabled", "toggle.killaura", "#killaura_enabled")
    registerSettings(controller, "isMobKillaura", "toggle.mob_killaura", "#mob_killaura_enabled")
    registerSlider(controller, "killauraDistance", "slider.killaura", "#kaDistance", "#text_box_killaura")
end

hooks.addHook("MoveInputHandler.tick", cheatsMoveHook)
hooks.addHook("Mob.jump", cheatsJumpHook)
hooks.addHook("Player.useItemOn", cheatsUseItemOnHook)
hooks.addHook("ClientInstance.tickInput", cheatsKillauraHook)
hooks.addHook("ClientInstance.tickInput", cheatsMobKillauraHook)
hooks.addHook("ClientInstance.renderGui", renderTradeHook)
hooks.addHook("ClientInstance.tickInput", jetpack)
hooks.addHook("ClientInstance.tickInput", glide)
hooks.addHook("ClientInstance.tickInput", jetpackBypass)

return {
    init = init
}