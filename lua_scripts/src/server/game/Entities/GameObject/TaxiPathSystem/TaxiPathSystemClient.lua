-- TaxiPathSystemClient.lua
local AIO = AIO or require("AIO")
if AIO.AddAddon() then
    return
end

local TxiPathHandlers = AIO.AddHandlers("TxiPathSystemClient", {})

-- Création de la fenêtre principale
local mainFrame = CreateFrame("Frame", "TxiPathMainFrame", UIParent)
mainFrame:SetSize(1400, 650)
mainFrame:SetPoint("CENTER", UIParent, "CENTER")
mainFrame:SetMovable(false)
mainFrame:EnableMouse(true)
mainFrame:RegisterForDrag("LeftButton")
mainFrame:SetFrameStrata("HIGH") -- Passe au-dessus du bouton XP et autres frames MEDIUM/LOW
mainFrame:SetBackdrop({
    bgFile = "Interface/TaxiPathUI/TemplateTaxiPath.blp", -- Texture personnalisée
    tile = false,
})
mainFrame:SetScript("OnDragStart", mainFrame.StartMoving)
mainFrame:SetScript("OnDragStop", mainFrame.StopMovingOrSizing)
mainFrame:Hide()

-- Fermeture avec la touche Échap
tinsert(UISpecialFrames, "TxiPathMainFrame")

-- Ajouter un titre en haut de la fenêtre principale
local title = mainFrame:CreateFontString(nil, "OVERLAY")
title:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE") -- Police personnalisée, taille 16, contour
title:SetPoint("TOP", mainFrame, "TOP", -40, -57) -- Position centrée en haut avec un léger décalage vers le bas
title:SetText("Téléporteur") -- Texte du titre
title:SetTextColor(1, 0.84, 0) -- Couleur jaune doré (RGB: 255, 215, 0 en normalisé)

-- Fonction pour ouvrir l'interface principale
function TxiPathHandlers.ShowMainFrame()
    -- Vérifier que mainFrame est bien initialisé avant de l'afficher
    if mainFrame then
        mainFrame:Show()
    else
        print("Erreur: mainFrame non initialisé")
    end
end

-- Variables de réglage pour le placement correct des boutons sur la carte
local mapXOffset = 1500  -- Ajuster le décalage X pour la carte Kalimdor
local mapYOffset = -4000 -- Ajuster le décalage Y pour la carte Kalimdor
local mapScale = 0.02    -- Facteur de mise à l'échelle pour les points

-- Bouton de fermeture
local closeButton = CreateFrame("Button", nil, mainFrame, "UIPanelCloseButton")
closeButton:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 1043, -103)
closeButton:SetSize(24, 24)
closeButton:SetScript("OnClick", function()
    mainFrame:Hide()
end)

-- Sous-cadre pour afficher uniquement la texture de la carte
local mapTextureFrame = CreateFrame("Frame", "TxiPathMapTextureFrame", mainFrame)
mapTextureFrame:SetSize(401, 382)
mapTextureFrame:SetPoint("RIGHT", mainFrame, "RIGHT", -349, 14)
mapTextureFrame:SetFrameStrata("BACKGROUND") -- La texture de carte reste DERRIÈRE la frame principale
mapTextureFrame:SetFrameLevel(1)

-- Cadre principal pour les boutons
local mapFrame = CreateFrame("Frame", "TxiPathMapFrame", mainFrame)
mapFrame:SetSize(401, 382)
mapFrame:SetPoint("RIGHT", mainFrame, "RIGHT", -349, 14)
mapFrame:SetFrameStrata("HIGH")             -- Même strata que mainFrame = boutons cliquables
mapFrame:SetFrameLevel(mainFrame:GetFrameLevel() + 1) -- Au-dessus du mainFrame

-- Fonction pour gérer la téléportation
local function ShowMap(mapTexture, mapId, teleportPoints)
    local faction = UnitFactionGroup("player")  -- Retourne "Alliance" ou "Horde"
    local playerLevel = UnitLevel("player")     -- Niveau actuel du joueur

    -- Appliquer la texture de la carte
    mapTextureFrame:SetBackdrop({
        bgFile = mapTexture,
        tile = false,
    })

    -- Effacer les boutons précédents
    for _, child in ipairs({mapFrame:GetChildren()}) do
        child:Hide()
    end

    -- Tableau des mapIds valides pour la téléportation
    local validMapIds = { 822, 811, 806, 805, 802, 801, 800, 798, 793, 792, 781, 771, 754, 571, 530, 1, 0 }  -- Ajouter autant de mapIds que nécessaire

    -- Parcourir les points de téléportation
    for _, point in ipairs(teleportPoints) do
        -- Vérifie faction et niveau requis
        if (point.faction == faction or point.faction == nil) and (not point.requiredLevel or playerLevel >= point.requiredLevel) then
            local button = CreateFrame("Button", nil, mapFrame)
            button:SetSize(21, 21)
            button:SetPoint("CENTER", mapFrame, "BOTTOMLEFT", point.buttonX, point.buttonY)
            button:SetNormalTexture(point.texture or "Interface/TaxiPathUI/FlyTPUI")

            -- Affichage des infos au survol
            button:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(point.name, 1, 1, 1)
                if point.requiredLevel and playerLevel < point.requiredLevel then
                    GameTooltip:AddLine("Requis : Niveau " .. point.requiredLevel, 1, 0, 0)
                end
                GameTooltip:Show()
            end)
            button:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            -- Logique de téléportation
            button:SetScript("OnClick", function()
                -- Vérifie le niveau requis
                if point.requiredLevel and playerLevel < point.requiredLevel then
                    print("Vous n'avez pas le niveau requis pour accéder à ce point.")
                    return
                end

                -- Si le point a un mapId spécifique, utilisez-le, sinon utilisez celui de la carte actuelle
                local targetMapId = point.mapId or mapId

                -- Vérifier si targetMapId fait partie des mapIds valides
                local isValidMap = false
                for _, validId in ipairs(validMapIds) do
                    if targetMapId == validId then
                        isValidMap = true
                        break
                    end
                end

                -- Téléportation si la carte est valide
                if isValidMap then
                    AIO.Handle("TxiPathSystemServer", "TeleportPlayer", targetMapId, point.x, point.y, point.z, point.orientation)
                else
                    print("MapId invalide pour la téléportation.")
                end

                -- Cache l'UI après la téléportation
                mainFrame:Hide()
            end)
        end
    end
end

-- Données des cartes avec points de téléportation
local maps = {
    -- Kalimdor
    { name = "Kalimdor", mapId = 1, texture = "Interface/TaxiPathUI/Kalimdor.blp", points = {
        { name = "|TInterface\\icons\\achievement_zone_durotar:35|t Orgrimmar (Capitale)", texture = "Interface/TaxiPathUI/HordePathUIEmblem", buttonX = 255, buttonY = 215, x = 1517.55, y = -4412.03, z = 21.7103, orientation = 0.243466, faction = "Horde" },
        { name = "|TInterface\\icons\\racial_orc_berserkerstrength:35|t Gouffre de Ragefeu (Donjon)", texture = "Interface/TaxiPathUI/ui-icon-dungeon", buttonX = 255, buttonY = 230, x = 1808.17, y = -4405.44, z = -18.48, orientation = 5.18, faction = "Horde" },
		{ name = "|TInterface\\icons\\achievement_zone_mulgore_01:35|t Mulgore (Capitale)", texture = "Interface/TaxiPathUI/HordePathUIEmblem", buttonX = 175, buttonY = 165, x = -1224.26, y = 51.11, z = 128.40, orientation = 2.45, faction = "Horde" },
        { name = "|TInterface\\icons\\achievement_zone_ashenvale_01:35|t Darnassus (Capitale)", texture = "Interface/TaxiPathUI/AlliancePathUIEmblem", buttonX = 145, buttonY = 340, x = 9915.03, y = 2511.81, z = 1316.94, orientation = 1.45, faction = "Alliance" },
        { name = "|TInterface\\icons\\achievement_zone_zangarmarsh:35|t Exodar (Capitale)", texture = "Interface/TaxiPathUI/AlliancePathUIEmblem", buttonX = 90, buttonY = 285, x = -3863, y = -11736, z = -106, orientation = 2, faction = "Alliance", mapId = 530 },
    }},
    -- Royaume de l'est
    { name = "Royaume de l'est", mapId = 0, texture = "Interface/TaxiPathUI/EasternKingdoms.blp", points = {
	
		-- Alliance
        { name = "|TInterface\\icons\\achievement_zone_elwynnforest:35|t Hurlevent (Capitale)", texture = "Interface/TaxiPathUI/AlliancePathUIEmblem", buttonX = 165, buttonY = 100, x = -8996.99, y = 860.68, z = 29.62, orientation = 2.25, faction = "Alliance" },
		{ name = "|TInterface\\icons\\achievement_zone_elwynnforest:35|t Forêt d'Elwynn (Village)", texture = "Interface/TaxiPathUI/FlyTPUI", buttonX = 185, buttonY = 95, x = -9473.13, y = -1340.36, z = 44.74, orientation = 1.42, faction = "Alliance" },
		{ name = "|TInterface\\icons\\inv_misc_head_gnoll_01:35|t Prison de Hurlevent (Donjon)", texture = "Interface/TaxiPathUI/ui-icon-dungeon", buttonX = 155, buttonY = 120, x = -8776.62, y = 836.76, z = 93.14, orientation = 0.66, faction = "Alliance" },
        { name = "|TInterface\\icons\\achievement_zone_lochmodan:35|t Loch Modan (Village)", texture = "Interface/TaxiPathUI/FlyTPUI", buttonX = 215, buttonY = 150, x = -5346.40, y = -2979.57, z = 324.26, orientation = 5.07, faction = "Alliance" },
		{ name = "|TInterface\\icons\\achievement_zone_westfall_01:35|t Marche de l'Ouest (Village)", texture = "Interface/TaxiPathUI/FlyTPUI", buttonX = 150, buttonY = 78, x = -10519.92, y = 1068.80, z = 54.67, orientation = 2.02, faction = "Alliance" },
		{ name = "|TInterface\\icons\\achievement_zone_dunmorogh:35|t Forgefer (Capitale)", texture = "Interface/TaxiPathUI/AlliancePathUIEmblem", buttonX = 180, buttonY = 155, x = -4629.20, y = -1315.85, z = 501.99, orientation = 2.33, faction = "Alliance" },
		{ name = "|TInterface\\icons\\achievement_zone_dunmorogh:35|t Dun Morogh (Village)", texture = "Interface/TaxiPathUI/FlyTPUI", buttonX = 160, buttonY = 145, x = -5600.29, y = -498.22, z = 399.35, orientation = 1.55, faction = "Alliance" },
		{ name = "|TInterface\\icons\\achievement_zone_redridgemountains:35|t Les Carmines (Village)", texture = "Interface/TaxiPathUI/FlyTPUI", buttonX = 210, buttonY = 95, x = -9266.36, y = -2210.69, z = 64.05, orientation = 3.11, faction = "Alliance" },
		{ name = "|TInterface\\icons\\achievement_zone_duskwood:35|t Bois de la Pénombre (Village)", texture = "Interface/TaxiPathUI/FlyTPUI", buttonX = 175, buttonY = 73, x = -10898.29, y = -364.78, z = 39.26, orientation = 3.08, faction = "Alliance" },
		{ name = "|TInterface\\icons\\achievement_zone_hillsbradfoothills:35|t Contreforts de Hautebrande (Village)", texture = "Interface/TaxiPathUI/FlyTPUI", buttonX = 175, buttonY = 220, x = -13.94, y = -334.34, z = 131.27, orientation = 4.11, faction = "Alliance" },
		{ name = "|TInterface\\icons\\achievement_zone_arathihighlands_01:35|t Hautes-terres Arathies (Village)", texture = "Interface/TaxiPathUI/FlyTPUI", buttonX = 210, buttonY = 205, x = -1266.14, y = -2496.79, z = 21.76, orientation = 5.26, faction = "Alliance" },
		
		-- Horde
        { name = "|TInterface\\icons\\achievement_zone_tirisfalglades_01:35|t Fossoyeuse (Capitale)", texture = "Interface/TaxiPathUI/HordePathUIEmblem", buttonX = 165, buttonY = 245, x = 1831, y = 238.5, z = 61.6, orientation = 0, faction = "Horde" },
        { name = "|TInterface\\icons\\achievement_zone_tirisfalglades_01:35|t Clairières de Tirisfal (Village)", texture = "Interface/TaxiPathUI/FlyTPUI", buttonX = 165, buttonY = 262, x = 2259.77, y = 294.16, z = 34.11, orientation = 1.01, faction = "Horde" },
		{ name = "|TInterface\\icons\\achievement_zone_silverpine_01:35|t Forêt des Pins-Argentés (Village)", texture = "Interface/TaxiPathUI/FlyTPUI", buttonX = 145, buttonY = 225, x = 507.48, y = 1623.43, z = 125.62, orientation = 4.79, faction = "Horde" },
		{ name = "|TInterface\\icons\\achievement_zone_hillsbradfoothills:35|t Contreforts de Hautebrande (Village)", texture = "Interface/TaxiPathUI/FlyTPUI", buttonX = 177, buttonY = 220, x = -33.89, y = -883.32, z = 56.14, orientation = 2.35, faction = "Horde" },
		{ name = "|TInterface\\icons\\achievement_zone_arathihighlands_01:35|t Hautes-terres Arathies (Village)", texture = "Interface/TaxiPathUI/FlyTPUI", buttonX = 220, buttonY = 205, x = -1020.85, y = -3550.85, z = 56.020, orientation = 0.003, faction = "Horde" },
		{ name = "|TInterface\\icons\\achievement_zone_bloodmystisle_01:35|t Lune d'Argent (Capitale)", texture = "Interface/TaxiPathUI/HordePathUIEmblem", buttonX = 240, buttonY = 320, x = 9484, y = -7294, z = 15, orientation = 0, faction = "Horde", mapId = 530 },
		{ name = "|TInterface\\icons\\achievement_zone_eversongwoods:35|t Bois des Chants éternels (Village)", texture = "Interface/TaxiPathUI/FlyTPUI", buttonX = 235, buttonY = 300, x = 9500.69, y = -6828.44, z = 16.49, orientation = 0.77, faction = "Horde", mapId = 530 },
		{ name = "|TInterface\\icons\\achievement_zone_ghostlands:35|t Les Terres Fantômes (Village)", texture = "Interface/TaxiPathUI/FlyTPUI", buttonX = 235, buttonY = 278, x = 7022.84, y = -6819.02, z = 42.23, orientation = 2.77, faction = "Horde", mapId = 530 },
		
		-- Neutre 
		
		{ name = "|TInterface\\icons\\achievement_zone_stranglethorn_01:35|t Vallée de Strangleronce (Village)", texture = "Interface/TaxiPathUI/FlyTPUI", buttonX = 160, buttonY = 38, x = -13288.69, y = 109.33, z = 23.32, orientation = 4.04 },
    }},
    -- Outreterre
    { name = "Outreterre", mapId = 530, texture = "Interface/TaxiPathUI/Outland.blp", points = {
        { name = "|TInterface\\icons\\spell_arcane_teleportshattrath:35|t Shattrath (Capitale)", texture = "Interface/TaxiPathUI/ui-icon-neutral", buttonX = 175, buttonY = 120, x = -1806.164307, y = 5323.119141, z = -12.428000, orientation = 2.1, requiredLevel = 55 },
    }},
    -- Norfendre
    { name = "Norfendre", mapId = 571, texture = "Interface/TaxiPathUI/Northrend.blp", points = {
        { name = "|TInterface\\icons\\spell_arcane_teleportdalaran:35|t Dalaran (Capitale)", texture = "Interface/TaxiPathUI/DiamondDalaranPathUI", buttonX = 210, buttonY = 235, x = 5807.794922, y = 588.387268, z = 660.937134, orientation = 1.6, requiredLevel = 68 },
    }},
    -- Pandaria
    { name = "Pandarie", mapId = 754, texture = "Interface/TaxiPathUI/Pandaria.blp", points = {
        { name = "|TInterface\\icons\\achievement_zone_valeofeternalblossoms:35|t Sanctuaire des Deux-Lunes (Capitale)", texture = "Interface/TaxiPathUI/HordePathUIEmblem", buttonX = 195, buttonY = 195, x = 1678.38, y = 931.508, z = 471.425, orientation = 0.143189, faction = "Horde", requiredLevel = 80 },
        { name = "|TInterface\\icons\\achievement_zone_valeofeternalblossoms:35|t Sanctuaire des Sept-Étoiles (Capitale)", texture = "Interface/TaxiPathUI/AlliancePathUIEmblem", buttonX = 220, buttonY = 170, x = 821.866, y = 253.792, z = 503.92, orientation = 3.73811, faction = "Alliance", requiredLevel = 80 },
    }},
	-- Draenor
    { name = "Draenor", mapId = 806, texture = "Interface/TaxiPathUI/Draenor.blp", points = {
        { name = "|TInterface\\icons\\achievement_zone_ashran:35|t A’shran (JcJ Global)", texture = "Interface/TaxiPathUI/HordePathUIEmblem", buttonX = 355, buttonY = 210, x = 5257.61, y = -4010.95, z = 14.121, orientation = 5.647, faction = "Horde", requiredLevel = 90 },
        { name = "|TInterface\\icons\\achievement_zone_ashran:35|t A’shran (JcJ Global)", texture = "Interface/TaxiPathUI/AlliancePathUIEmblem", buttonX = 355, buttonY = 230, x = 3985.79, y = -4043.07, z = 54.8132, orientation = 5.66916, faction = "Alliance", requiredLevel = 90 },
    }},
	-- BrokenIsle
    { name = "Îles Brisées", mapId = 805, texture = "Interface/TaxiPathUI/BrokenIsle.blp", points = {
        { name = "|TInterface\\icons\\achievements_zone_suramar:35|t Suramar", texture = "Interface/TaxiPathUI/FlyTPUI", buttonX = 180, buttonY = 210, x = 964.62, y = 3311.9, z = 41.6089, orientation = 0.682513, requiredLevel = 100 },
		{ name = "|TInterface\\icons\\spell_arcane_teleportdalaranbrokenisles:35|t Dalaran Légion |cff008000(Zone)|r", texture = "Interface/TaxiPathUI/FlyTPUI", buttonX = 190, buttonY = 75, x = -11908.80, y = 2961.10, z = 1857.40, orientation = 5.04, mapId = 781, requiredLevel = 70 },
    }},
	-- Azeroth Universe
    { name = "Azeroth Universe", mapId = 811, texture = "Interface/TaxiPathUI/MerBoreale.blp", points = {
        { name = "|TInterface\\icons\\ability_bossfellord_felfissure:35|t Vaisseau de la Légion |cffffff00(Aventure)|r", texture = "Interface/TaxiPathUI/FlyTPUI", buttonX = 85, buttonY = 285, x = -11800.76, y = 2974.97, z = 2745.97, orientation = 1.57, mapId = 781, requiredLevel = 5 },
		{ name = "|TInterface\\icons\\spell_holy_pureofheart:35|t Le Vindicaar |cffffffff(Cosmétique)|r", texture = "Interface/TaxiPathUI/FlyTPUI", buttonX = 165, buttonY = 245, x = -10985.1, y = 2748.45, z = 332.855, orientation = 4.68076, mapId = 781, requiredLevel = 40 },
		{ name = "|TInterface\\icons\\_HearthStoneDark_Priest:35|t Temple Halo-du-Néant |cffffffff(Cosmétique)|r", texture = "Interface/TaxiPathUI/FlyTPUI", buttonX = 155, buttonY = 280, x = 1234.33, y = 1344.18, z = 185.081, orientation = 0.00819301, mapId = 801, requiredLevel = 40 },
		{ name = "|TInterface\\icons\\spell_holy_lightsgrace:35|t Sanctum de la Lumière |cff008000(Métiers)|r", texture = "Interface/TaxiPathUI/FlyTPUI", buttonX = 207, buttonY = 195, x = -11237.9, y = 3285.19, z = 163.365, orientation = 1.56564, mapId = 781, requiredLevel = 5 },
		--{ name = "|TInterface\\icons\\achievement_boss_svalasorrowgrave:35|t Séjour céleste |cff008000(Divers)|r", texture = "Interface/TaxiPathUI/FlyTPUI", buttonX = 209, buttonY = 290, x = 1127.44, y = 7223.68, z = 101.824, orientation = 3.13896, mapId = 771, requiredLevel = 80 },
		{ name = "|TInterface\\icons\\spell_arcane_teleporthalloftheguardian:35|t Hall du Gardien |cff008000(Entraîneur)|r", texture = "Interface/TaxiPathUI/FlyTPUI", buttonX = 210, buttonY = 330, x = -816.193, y = 4692.72, z = 939.663, orientation = 3.0359, mapId = 800, requiredLevel = 5 },
		{ name = "|TInterface\\icons\\_HearthStoneDark_Shaman:35|t Le Maelström |cffffffff(Event)|r", texture = "Interface/TaxiPathUI/FlyTPUI", buttonX = 275, buttonY = 155, x = 1070.35, y = 1119.89, z = 19.6602, orientation = 4.07609, mapId = 802, requiredLevel = 120 },
		{ name = "|TInterface\\icons\\_RuneMagmaVerte:35|t Le Marteau gangrené |cffffffff(Bot)|r", texture = "Interface/TaxiPathUI/FlyTPUI", buttonX = 277, buttonY = 200, x = 1508.94, y = 1412.19, z = 243.361, orientation = 0.0534305, mapId = 798, requiredLevel = 120 },
		
		{ name = "|TInterface\\icons\\spell_arcane_teleportstormwind:35|t Chemin du Rêve d'émeraude [1]", texture = "Interface/TaxiPathUI/DungeonPathUI", buttonX = 170, buttonY = 130, x = 1658.18, y = 1573.7, z = 5.84094, orientation = 2.46316, mapId = 792, requiredLevel = 80 },
		{ name = "|TInterface\\icons\\spell_arcane_teleportstormwind:35|t Chemin du Rêve d'émeraude [2]", texture = "Interface/TaxiPathUI/RaidPathUI", buttonX = 205, buttonY = 100, x = 1658.18, y = 1573.7, z = 5.84094, orientation = 2.46316, mapId = 793, requiredLevel = 80 },
		{ name = "|TInterface\\icons\\spell_arcane_teleportstormwind:35|t Chemin du Rêve d'émeraude [3]", texture = "Interface/TaxiPathUI/DungeonPathUI", buttonX = 240, buttonY = 130, x = 1658.18, y = 1573.7, z = 5.84094, orientation = 2.46316, mapId = 822, requiredLevel = 80 },
    }},
}

-- Boutons pour sélectionner les cartes
local startY = -109  -- Déplacer les boutons plus bas (ajustez cette valeur)
for i, map in ipairs(maps) do
    -- Création d'un bouton personnalisé sans utiliser UIPanelButtonTemplate
    local button = CreateFrame("Button", nil, mainFrame)
    button:SetSize(200, 75)
    button:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 364, startY - (i - 1) * 47)

    -- Appliquer la texture normale (par défaut)
    button:SetNormalTexture("Interface/TaxiPathUI/ButtonPathUI.blp")

    -- Optionnel : Ajouter une texture pour les états survolé et cliqué
    local highlightTexture = button:CreateTexture(nil, "HIGHLIGHT")
    highlightTexture:SetTexture("Interface/TaxiPathUI/ButtonPathUI_Highlight.blp") -- Assurez-vous d'avoir une texture de survol
    highlightTexture:SetAllPoints(button)
    button:SetHighlightTexture(highlightTexture)

    local pushedTexture = button:CreateTexture(nil, "PUSHED")
    pushedTexture:SetTexture("Interface/TaxiPathUI/ButtonPathUI_Pushed.blp") -- Assurez-vous d'avoir une texture pour l'état cliqué
    pushedTexture:SetAllPoints(button)
    button:SetPushedTexture(pushedTexture)

    -- Ajouter un texte sur le bouton
    local buttonText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    buttonText:SetText(map.name)
    buttonText:SetPoint("CENTER", button, "CENTER", 0, 0)

    -- Associer le script de clic au bouton
    button:SetScript("OnClick", function()
        ShowMap(map.texture, map.mapId, map.points)  -- On passe maintenant mapId en plus des autres paramètres
    end)
end

-- Initialisation avec Kalimdor par défaut
ShowMap("Interface/TaxiPathUI/MerBoreale.blp", 1, {
})

-- Bouton externe pour ouvrir l'interface
-- local openButton = CreateFrame("Button", "TxiPathOpenButton", UIParent, "UIPanelButtonTemplate")
-- openButton:SetSize(120, 40)
-- openButton:SetPoint("CENTER", UIParent, "CENTER", 0, -300)
-- openButton:SetText("Ouvrir Taxi Path")
-- openButton:SetScript("OnClick", function()
--     if mainFrame:IsShown() then
--         mainFrame:Hide()
--     else
--         mainFrame:Show()
--     end
-- end)
