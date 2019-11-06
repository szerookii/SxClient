local config = {}
config.isAutoWalkEnabled = false
config.isAutoSprintEnabled = false
config.isHighJumpEnabled = false
config.isImmortalityEnabled = false
config.isInstakillEnabled = false
config.isTapTeleportEnabled = false
config.isFFEnabled = false
config.isKillauraEnabled = false
config.isJetpackEnabled = false
config.isGlideEnabled = false
config.isCrasherEnabled = false
config.isEspEnabled = false
config.isBFlyEnabled = false
config.isAiEnabled = false
config.isNsEnabled = false
config.isTapRideEnabled = false
config.isKBEnabled = false

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
MTN.isFFEnabled = "ForceFly"
MTN.isKillauraEnabled = "KillAura"
MTN.isJetpackEnabled = "JetPack"
MTN.isGlideEnabled = "Glide"
MTN.isAirjumpEnabled = "AirJump"
MTN.isCrasherEnabled = "ServerCrasher"
MTN.isEspEnabled = "ESP"
MTN.isBFlyEnabled = "Bypass Glide [SNEAK]"
MTN.isAiEnabled = "AirInfinity"
MTN.isNsEnabled = "NoSlowDown"
MTN.isTapRideEnabled = "TapRide"
MTN.isKBEnabled = "NoKnockBack"

local presets = { 3, 4, 5, 6, 7, 8, 9, 10 }
local tickJet = 0
local tickNum = 0
local tickNumMob = 0
local tickGlide = 0
local playerhealth = minecraft.clientinstance:getLocalPlayer():getHealth()
local playerx, playery, playerz = minecraft.clientinstance:getLocalPlayer():getPos()

local r = 255
local g = 0
local b = 0

function drawName(context)
    local font = context:getFont()
	
	-- Ok.
    if r > 0 and b == 0 then
        r = r - 1
        g = g + 1
    end
    
    if g > 0 and r == 0 then
        g = g - 1
        b = b + 1
    end
    
    if b > 0 and g == 0 then
        r = r + 1
        b = b - 1
    end
    
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
    text = "Made by Seyz"
    textScale = 1
    y = 18
    
    -- Write the text
    font:drawTransformed(context:getScreenContext(), text, x + 16 * scale + spacing * scale, y + textVerticalSpacing * scale, 1, 1, 1, 1, 0, font:getLineLength(text, 1, false), false, textScale)
    
    if minecraft.clientinstance:isShowingMenu() then
        return
    end
    
    -- Write module list lol
    text = ""
    y = 30
    local x = 1
    
    for i, v in pairs(config) do
        if config[i] ~= false then
            text = MTN[i]
            y = y + 10
            font:drawTransformed(context:getScreenContext(), text, x, y, r, g, b, 1, 0, font:getLineLength(text, 1, false), false, textScale)
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

local function glide()
    if not config.isGlideEnabled then
        return
    end
    
    local player = minecraft.clientinstance:getLocalPlayer()
    local vX, vY, vZ = player:getVelocity()
    local y = -0.02
    player:setVelocity(vX, y, vZ)
end

local function crasher()
    if not config.isCrasherEnabled then
        return
    end
    
    local player = minecraft.clientinstance:getLocalPlayer()
    local x = math.floor(math.random(1, 10000))
    local y = math.floor(math.random(1, 10000))
    local z = math.floor(math.random(1, 10000))
    player:teleportTo(x, y, z)
end

local function bypassGlide(event)
    if config.isBFlyEnabled and event:getInputHandler():getSneak() then
        local player = minecraft.clientinstance:getLocalPlayer()
        local pitch, yaw = player:getRotation()
        local one = yaw + 90
        local vX = math.cos(one * (math.pi/180)) * 0.3
        local vZ = math.sin(one * (math.pi/180)) * 0.3
        player:setVelocity(vX, 0, vZ)
        
        tickGlide = tickGlide + 1
        if tickGlide == 15 then
            tickGlide = 0
            glideX, glideY, glideZ = event:getPlayer():getVelocity()
            player:setVelocity(glideX, glideY + 0.4, glideZ)
        end
    end
end

local function ai(event)
    if config.isAiEnabled then
        local player = minecraft.clientinstance:getLocalPlayer()
        local pitch, yaw = player:getRotation()
        local cX, cY, cZ = player:getVelocity()
        local pX, pY, pZ = player:getPos()
        
        if event:getInputHandler():getUpright() then
            yaw = yaw + 45
        elseif event:getInputHandler():getUpleft() then
            yaw = yaw - 45
        elseif event:getInputHandler():getDown() and event:getInputHandler():getRight() and not event:getInputHandler():getLeft() then
            yaw = yaw + 135
        elseif event:getInputHandler():getDown() and not event:getInputHandler():getRight() and event:getInputHandler():getLeft() then
            yaw = yaw - 135
        elseif event:getInputHandler():getDown() then
            yaw = yaw + 180
        elseif event:getInputHandler():getRight() and not event:getInputHandler():getLeft() then
            yaw = yaw + 90
        elseif not event:getInputHandler():getRight() and event:getInputHandler():getLeft() then
            yaw = yaw - 90
        end
        
        local cYaw = (yaw + 90) * (math.pi / 180)
        local cPitch = (pitch) * -(math.pi / 180)
        local vX = math.cos(cYaw) * 0.4
        local vZ = math.sin(cYaw) * 0.4
        
        if event:getInputHandler():getUp() or event:getInputHandler():getDown() or event:getInputHandler():getRight() or event:getInputHandler():getLeft() then
           player:setVelocity(vX, cY, vZ)
        end
    end
end

local function ns()
    if config.isNsEnabled then
        local player = minecraft.clientinstance:getLocalPlayer()
        local vX, vY, vZ = player:getVelocity()
        
        player:setVelocity(vX, 0, vZ)
    end
end

local function tapride(event)
    if config.isTapRideEnabled then
        local player = minecraft.clientinstance:getLocalPlayer()
        local victim = event:getActor()
        local source = event:getDamageSource()
        
        if source:isActorSource() then
            local attackerUuid = source:getDamagingActorUniqueID()
            local pUuid = player:getUniqueID()
            
            if attackerUuid == pUuid then
                if victim:canAddRider(player) then
                    victim:addRider(player)
                end
            end
        end
    end
end

local function kb()
    local player = minecraft.clientinstance:getLocalPlayer()
    if config.isKBEnabled then
        if playerhealth > player:getHealth() then
            player:setPos(playerx, playery, playerz)
        end	
    end
    playerhealth = player:getHealth()
    playerx, playery, playerz = player:getPos()
end

local function ff()
    if config.isFFEnabled then
        local player = minecraft.clientinstance:getLocalPlayer()
        local abilities = player:getAbilities()
        abilities:setAbility("flying", true)
    end
end

local function registerCommands(event)
    local reg = event:getCommandRegistry()
    reg:registerCommand("killaura", "Enable killaura", 0)
    reg:registerOverload("killaura", function(args)
        config.isFFEnabled = true
    end)
end

local function esp(event)
    if not config.isEspEnabled then
        return
    end
    
    local context = event:getContext()
    local localPlayer = minecraft.clientinstance:getLocalPlayer()

    context:glClear(0x00000100)
    local x, y, z = context:getCameraTargetPosition()
    local matrix = context:pushToViewMatrix()
    matrix:translate(-x, -y, -z)
    
    local level = minecraft.clientinstance:getLevel()
    local t = context:getTessellator()
    t:begin()
    t:color(r, g, b, 0.5);
    level:forEachPlayer(function(player)
        if player ~= localPlayer then
            local posX, posY, posZ = player:getInterpolatedPos(context:getDeltaTime())
            posY = posY - 1.64
            drawBox(t, posX, posY, posZ, 0.5, 2)
        end
    end)
    t:draw(context:getScreenContext(), minecraft.rendermaterialgroup.common:getMaterial("ui_fill_gradient"))
    matrix:release()
end

-- Others

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
    registerCheat(controller, "isFFEnabled", "toggle.ff", "#ff_enabled")
    registerCheat(controller, "isJetpackEnabled", "toggle.jetpack", "#jetpack_enabled")
    registerCheat(controller, "isGlideEnabled", "toggle.glide", "#glide_enabled")
    registerCheat(controller, "isAirjumpEnabled", "toggle.airjump", "#airjump_enabled")
    registerCheat(controller, "isCrasherEnabled", "toggle.crasher", "#crasher_enabled")
    registerServerCheat(controller, "isInstakillEnabled", "toggle.instakill", "#instakill_enabled", "instakill");
    registerCheat(controller, "isKillauraEnabled", "toggle.killaura", "#killaura_enabled")
    registerSettings(controller, "isMobKillaura", "toggle.mob_killaura", "#mob_killaura_enabled")
    registerSlider(controller, "killauraDistance", "slider.killaura", "#kaDistance", "#text_box_killaura")
    registerCheat(controller, "isEspEnabled", "toggle.esp", "#esp_enabled")
    registerCheat(controller, "isBFlyEnabled", "toggle.bfly", "#bfly_enabled")
    registerCheat(controller, "isAiEnabled", "toggle.ai", "#ai_enabled")
    registerCheat(controller, "isNsEnabled", "toggle.ns", "#ns_enabled")
    registerCheat(controller, "isTapRideEnabled", "toggle.tapride", "#tapride_enabled")
    registerCheat(controller, "isKBEnabled", "toggle.kb", "#kb_enabled")
end

hooks.addHook("MoveInputHandler.tick", cheatsMoveHook)
hooks.addHook("Mob.jump", cheatsJumpHook)
hooks.addHook("Player.useItemOn", cheatsUseItemOnHook)
hooks.addHook("ClientInstance.tickInput", cheatsKillauraHook)
hooks.addHook("ClientInstance.tickInput", cheatsMobKillauraHook)
hooks.addHook("ClientInstance.renderGui", renderTradeHook)
hooks.addHook("ClientInstance.tickInput", jetpack)
hooks.addHook("ClientInstance.tickInput", glide)
hooks.addHook("ClientInstance.tickInput", crasher)
hooks.addHook("ClientInstance.tickInput", ns)
hooks.addHook("ClientInstance.renderGame", esp)
hooks.addHook("MoveInputHandler.tick", bypassGlide)
hooks.addHook("MoveInputHandler.tick", ai)
hooks.addHook("Actor.hurt", tapride)
hooks.addHook("ClientInstance.tickInput", kb)
hooks.addHook("ClientInstance.tickInput", ff)
hooks.addHook("CommandRegistry.setupCommands", registerCommands)

-- From xray mod
function drawBox(t, x, y, z, width, height)
    t:vertex(x - width, y, z - width);
    t:vertex(x + width, y, z - width);
    t:vertex(x + width, y, z + width);
    t:vertex(x - width, y, z + width);
    t:vertex(x - width, y, z + width);
    t:vertex(x + width, y, z + width);
    t:vertex(x + width, y, z - width);
    t:vertex(x - width, y, z - width);
    t:vertex(x - width, y + height, z - width);
    t:vertex(x + width, y + height, z - width);
    t:vertex(x + width, y + height, z + width);
    t:vertex(x - width, y + height, z + width);
    t:vertex(x - width, y + height, z + width);
    t:vertex(x + width, y + height, z + width);
    t:vertex(x + width, y + height, z - width);
    t:vertex(x - width, y + height, z - width);
    t:vertex(x - width, y, z - width);
    t:vertex(x - width, y + height, z - width);
    t:vertex(x + width, y + height, z - width);
    t:vertex(x + width, y, z - width);
    t:vertex(x + width, y, z - width);
    t:vertex(x + width, y + height, z - width);
    t:vertex(x - width, y + height, z - width);
    t:vertex(x - width, y, z - width);
    t:vertex(x + width, y, z - width);
    t:vertex(x + width, y + height, z - width);
    t:vertex(x + width, y + height, z + width);
    t:vertex(x + width, y, z + width);
    t:vertex(x + width, y, z + width);
    t:vertex(x + width, y + height, z + width);
    t:vertex(x + width, y + height, z - width);
    t:vertex(x + width, y, z - width);
    t:vertex(x + width, y, z + width);
    t:vertex(x + width, y + height, z + width);
    t:vertex(x - width, y + height, z + width);
    t:vertex(x - width, y, z + width);
    t:vertex(x - width, y, z + width);
    t:vertex(x - width, y + height, z + width);
    t:vertex(x + width, y + height, z + width);
    t:vertex(x + width, y, z + width);
    t:vertex(x - width, y, z + width);
    t:vertex(x - width, y + height, z + width);
    t:vertex(x - width, y + height, z - width);
    t:vertex(x - width, y, z - width);
    t:vertex(x - width, y, z - width);
    t:vertex(x - width, y + height, z - width);
    t:vertex(x - width, y + height, z + width);
    t:vertex(x - width, y, z + width);
end

return {
    init = init
}
