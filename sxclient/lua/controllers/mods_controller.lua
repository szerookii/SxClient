local function registerMinimapToggle(controller, name, toggleName, bindingName)
    controller:registerToggleChangeEventHandler(toggleName, function(propertyBag, value, radioValue)
        toolbox.mods.callFunction("minimap", "setConfigValue", name, value)
    end)

    controller:bindBool(bindingName, function()
        return toolbox.mods.callFunction("minimap", "getConfigValue", name)
    end)
end

---@param controller screencontroller
local function init(controller)

    -- xray
    controller:registerToggleChangeEventHandler("toggle.xray_enable", function(propertyBag, value, radioValue)
        toolbox.mods.callFunction("xray", "setXRayEnabled", value)
        toolbox.analytics.logEvent("mods_xray", "value", value)
    end)

    controller:bindBool("#xray_enable", function()
        return toolbox.mods.callFunction("xray", "isXRayEnabled")
    end)

    -- treecapitator
    controller:registerToggleChangeEventHandler("toggle.treecapitator_enable", function(propertyBag, value, radioValue)
        toolbox.mods.callFunction("treecapitator", "setTreecapitatorEnabled", value)
        toolbox.analytics.logEvent("mods_treecapitator", "value", value)
    end)

    controller:bindBool("#treecapitator_enable", function()
        return toolbox.mods.callFunction("treecapitator", "isTreecapitatorEnabled")
    end)

    -- armor hud
    controller:registerToggleChangeEventHandler("toggle.armorhud_enable", function(propertyBag, value, radioValue)
        toolbox.mods.callFunction("armor_hud", "setArmorHudEnabled", value)
        toolbox.analytics.logEvent("mods_armor_hud", "value", value)
    end)

    controller:bindBool("#armorhud_enable", function()
        return toolbox.mods.callFunction("armor_hud", "isArmorHudEnabled")
    end)
    
    -- Disable enabled mods
    toolbox.mods.callFunction("minimap", "setConfigValue", "enableMinimap", false)
    toolbox.mods.callFunction("minimap", "setConfigValue", "renderWaypoints", false)
    toolbox.mods.callFunction("minimap", "setConfigValue", "drawCoords", false)
    toolbox.mods.callFunction("armor_hud", "setArmorHudEnabled", false)
    toolbox.mods.callFunction("treecapitator", "setTreecapitatorEnabled", false)
    toolbox.mods.callFunction("xray", "setXRayEnabled", false)

    -- minimap
    registerMinimapToggle(controller, "enableMinimap", "toggle.minimap_enable", "#minimap_enable")
    registerMinimapToggle(controller, "renderPlayers", "toggle.minimap_enable_players", "#minimap_enable_players")
    registerMinimapToggle(controller, "renderMobs", "toggle.minimap_enable_mobs", "#minimap_enable_mobs")
    registerMinimapToggle(controller, "renderWaypoints", "toggle.minimap_enable_waypoints", "#minimap_enable_waypoints")
    registerMinimapToggle(controller, "drawCoords", "toggle.minimap_enable_coords", "#minimap_enable_coords")
    registerMinimapToggle(controller, "enableWaypoints", "toggle.waypoints_enable", "#waypoints_enable")

    controller:registerSliderChangedEventHandler("slider.minimap_radius", function(val)
        local radius = math.floor(val + 3) * 20
        toolbox.mods.callFunction("minimap", "setConfigValue", "radius", radius)
    end)

    controller:bindFloat("#minimap_radius", function()
        return toolbox.mods.callFunction("minimap", "getConfigValue", "radius") / 20 - 3;
    end)

    controller:bindString("#text_box_minimap_radius", function()
        return tostring(toolbox.mods.callFunction("minimap", "getConfigValue", "radius"));
    end)

    -- damage indicators
    controller:registerToggleChangeEventHandler("toggle.damageindicators_enable", function(propertyBag, value, radioValue)
        toolbox.mods.callFunction("damage_indicators", "setDamageIndicatorsEnabled", value)
        toolbox.analytics.logEvent("mods_damage_indicators", "value", value)
    end)

    controller:bindBool("#damageindicators_enable", function()
        return toolbox.mods.callFunction("damage_indicators", "isDamageIndicatorsEnabled")
    end)

end

return {
    init = init
}