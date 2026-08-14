----------------------------------------------------------------
--  Le temps de Chromie / Chromie Time - Addon client (AIO)
--  Ce fichier est envoye automatiquement aux joueurs par AIO.
--  Ne pas placer dans Interface\AddOns : il doit rester dans
--  lua_scripts/ cote serveur, a cote de AIO.lua et de
--  PierreFoyerServer.lua.
--
--  IMPORTANT - fichiers de texture requis cote client :
--  Le cadre (bordure, coins, bandeau, parchemin, portrait de Chromie)
--  vient d'UNE SEULE image retravaillee a la main (PierreFoyerFrame,
--  2048x1024, sans zone de decoupe - le canevas est plein). Par-dessus,
--  comme avant, on repose les 9 cartes de destination (cadre + vraie
--  vignette de l'atlas ChromieTimeUI) et le bouton Retour (ruban de
--  l'atlas UIFrameNeutral), qui sont entierement dessines par ce
--  script (aucun cadre de carte ni bouton n'est incruste dans l'image
--  de fond, elle a ete nettoyee entierement a cet endroit).
--
--  AIO ne transmet que du code Lua, jamais de fichiers binaires : ces
--  3 textures .blp doivent donc etre installees manuellement dans le
--  dossier Interface\ de CHAQUE client joueur (patch client) :
--    Interface\ChromieTime\PierreFoyerFrame.blp   (fourni a part)
--    Interface\ChromieTime\ChromieTimeUI.blp       (vignettes, deja
--                                                    fourni dans
--                                                    ChromieTimeUI.zip)
--    Interface\FrameGeneral\UIFrameNeutral.blp      (cadres de carte +
--                                                    ruban du bouton,
--                                                    deja fourni dans
--                                                    ChromieTimeUI.zip)
--
--  IMPORTANT - construction unique par processus client :
--  Un changement de personnage (retour a l'ecran de selection puis
--  reconnexion) ne reinitialise pas toujours completement l'etat Lua
--  cote client : AIO peut reexecuter ce script dans le MEME
--  environnement que la session precedente. CreateFrame avec un nom
--  global deja pris renvoie la frame DEJA CREEE au lieu d'en creer une
--  nouvelle - mais sans precaution, tout le reste (textures,
--  FontStrings, cartes, hooks OnShow) serait quand meme recree et
--  empile PAR-DESSUS l'existant a chaque (re)connexion. Au bout de la
--  3e generation, cet empilement faisait echouer l'affichage de la
--  grande texture de fond (confirme : le probleme survenait
--  systematiquement a la 3e connexion dans le meme processus client,
--  quels que soient le personnage ou le fichier texture utilises, et
--  disparaissait apres un redemarrage complet du client).
--  On ne construit donc l'UI qu'une seule fois par processus client
--  (frame.PDF_Ready). Les executions suivantes du script se contentent
--  de rafraichir l'affichage (faction du personnage) et de signaler la
--  locale au serveur, sans recreer aucun objet.
----------------------------------------------------------------

-- AIO doit etre requis de cette facon (differences serveur/client)
local AIO = AIO or require("AIO")

-- Sur le serveur : enregistre ce fichier comme addon a envoyer et
-- s'arrete la (le reste du fichier ne s'execute que cote client).
if AIO.AddAddon() then
    return
end

-- CreateFrame avec un nom global existant renvoie la frame existante
-- (comportement standard de l'API) : reutilise donc automatiquement la
-- fenetre construite lors d'une precedente execution du script dans ce
-- meme processus client.
local frame = CreateFrame("Frame", "PierreFoyerFrame", UIParent)

if frame.PDF_Ready then
    -- Deja construite : on ne recree AUCUN objet (c'est precisement ce
    -- qui causait le bug), on rafraichit juste l'affichage - utile si on
    -- vient de se connecter sur un personnage d'une autre faction que la
    -- fois precedente dans ce meme processus client - et on signale la
    -- locale (le serveur associe la locale au personnage connecte, pas
    -- au processus client).
    frame.PDF_RefreshVisibility()
    AIO.Handle("PierreFoyer", "SetLocale", GetLocale())
    return
end

----------------------------------------------------------------
--  Localisation (frFR / enUS)
----------------------------------------------------------------
local LOCALES = {
    frFR = {
        buttonTooltipTitle = "Le temps de Chromie",
        buttonTooltipLine  = "Voyage vers une destination.",
        windowTitle        = "Le temps de Chromie",
        bannerText         = "Les chemins du temps et de l’espace s’ouvrent sur différentes époques.",
        panelTitle         = "Le temps de Chromie",
        panelBody          = "Voyagez instantanement vers l'un des lieux, ou revenez sur vos pas avec le bouton Retour.",
        recallLabel        = "Retour",
        recallTooltipTitle = "Retour",
        recallTooltipLine  = "Vous ramène à votre position précédente.",
        closeTooltip       = "Fermer",
        levelRequired      = "Niveau %d requis",
        lockedBadge        = "Niveau %d",
        adventureConfirm   = "Voulez-vous voyager vers %s ?",
        destinationUnlocked = "%s est maintenant accessible !",
    },
    enUS = {
        buttonTooltipTitle = "Chromie Time",
        buttonTooltipLine  = "Travel to a destination.",
        windowTitle        = "Chromie Time",
        bannerText         = "The paths of time and space open onto different eras.",
        panelTitle         = "Chromie Time",
        panelBody          = "Travel instantly to one of your locations, or retrace your steps with the Recall button.",
        recallLabel        = "Recall",
        recallTooltipTitle = "Recall",
        recallTooltipLine  = "Returns you to your previous location.",
        closeTooltip       = "Close",
        levelRequired      = "Requires level %d",
        lockedBadge        = "Level %d",
        adventureConfirm   = "Would you like to travel to %s?",
        destinationUnlocked = "%s is now available!",
    },
}
local L = LOCALES[GetLocale()] or LOCALES.enUS
local IS_FR = (GetLocale() == "frFR")

----------------------------------------------------------------
--  Les 9 destinations (affichage uniquement - le serveur possede
--  sa propre copie faisant foi et ne fait jamais confiance a des
--  coordonnees envoyees par le client)
----------------------------------------------------------------
local DESTINATIONS = {
    { "Orgrimmar",                          nameEn = "Orgrimmar",                          faction = "Horde",    requiredLevel = 1 },
    { "Sanctuaire des Deux-Lunes",          nameEn = "Shrine of Two Moons",                faction = "Horde",    requiredLevel = 80 },
    { "Hurlevent",                          nameEn = "Stormwind",                          faction = "Alliance", requiredLevel = 1 },
    { "Sanctuaire des Sept-Etoiles",        nameEn = "Shrine of Seven Stars",              faction = "Alliance", requiredLevel = 80 },
    { "Dalaran",                            nameEn = "Dalaran",                                                  requiredLevel = 80 },
    { "Dalaran (Legion)",        		    nameEn = "Dalaran (Legion)",                               			 requiredLevel = 80 },
    { "Les Ports Oubliés",       			nameEn = "The Forgotten Reach",                          	 	   	 requiredLevel = 10, adventure = true },
    { "Netheril",         					nameEn = "Netheril",                              					 requiredLevel = 80, adventure = true },
    { "Chemin du Rêve d'émeraude",      	nameEn = "Emerald Dreamway",                            		     requiredLevel = 80 },
}

-- Emplacement fixe (1-7) de chaque destination dans la grille 3x3. Les 2
-- destinations Horde et leurs 2 equivalents Alliance partagent le MEME
-- emplacement (1 et 2) : les 2 cartes correspondantes sont creees une
-- seule fois chacune (comme toutes les autres) mais superposees au meme
-- endroit, et seule celle qui correspond a la faction du personnage
-- connecte est affichee (Show/Hide via RefreshVisibility) - ainsi la
-- disposition ne bouge jamais, meme si on change de personnage (donc
-- potentiellement de faction) sans redemarrer le client.
local SLOT_FOR_DEST = {
    [1] = 1, -- Orgrimmar (Horde)
    [3] = 1, -- Hurlevent (Alliance) - meme emplacement qu'Orgrimmar
    [2] = 2, -- Sanctuaire des Deux-Lunes (Horde)
    [4] = 2, -- Sanctuaire des Sept-Etoiles (Alliance) - meme emplacement
    [5] = 3, -- Dalaran
    [6] = 4, -- (Capitale) Dalaran (Legion)
    [7] = 5, -- (Aventure) Les Ports Oublies
    [8] = 6, -- (Aventure) Netheril Camp 1
    [9] = 7, -- [1] Chemin du Reve d'emeraude
}

local function DestName(dest)
    return IS_FR and dest[1] or dest.nameEn
end

----------------------------------------------------------------
--  Textures
----------------------------------------------------------------
-- Image de fond unique, nettoyee a la main (voir en-tete). Canevas
-- plein 2048x1024, pas de zone de decoupe a appliquer.
local ATLAS_FRAME = "Interface\\ChromieTime\\PierreFoyerFrame"

-- Atlas "Chromie Time" pour les 9 vraies vignettes (inchange)
local ATLAS_THUMB = "Interface\\ChromieTime\\ChromieTimeUI" -- 2048x2048
local THUMB_X0, THUMB_X1 = 0/2048, 313/2048
local THUMBS = {
    { THUMB_X0, THUMB_X1, 873/2048,  1047/2048 },
    { THUMB_X0, THUMB_X1, 1047/2048, 1222/2048 },
    { THUMB_X0, THUMB_X1, 1222/2048, 1398/2048 },
    { THUMB_X0, THUMB_X1, 1398/2048, 1574/2048 },
    { THUMB_X0, THUMB_X1, 1574/2048, 1744/2048 },
    { THUMB_X0, THUMB_X1, 1744/2048, 1922/2048 },
}

-- Convertit un rectangle en pixels natifs de l'atlas (2048x2048) en
-- coordonnees de texture (0..1) pour SetTexCoord.
local function ThumbCoord(x, y, w, h)
    return { x / 2048, (x + w) / 2048, y / 2048, (y + h) / 2048 }
end

-- Vignettes propres a une destination precise (captures reelles collees
-- a la main dans ChromieTimeUI.blp), qui remplacent la vignette
-- generique par defaut pour ces index uniquement. Les destinations non
-- listees ici continuent d'utiliser THUMBS (cycle generique).
local THUMB_OVERRIDE = {
    [1] = ThumbCoord(718, 1291, 314, 174), -- Orgrimmar
    [3] = ThumbCoord(403, 943,  314, 174), -- Hurlevent
    [2] = ThumbCoord(717, 943,  314, 174), -- Sanctuaire des Deux-Lunes (meme image que 4)
    [4] = ThumbCoord(717, 943,  314, 174), -- Sanctuaire des Sept-Etoiles (meme image que 2)
    [5] = ThumbCoord(1031, 943, 314, 174), -- Dalaran
    [6] = ThumbCoord(404, 1117, 314, 174), -- Dalaran (Legion)
    [7] = ThumbCoord(718, 1117, 314, 174), -- (Aventure) Les Ports Oublies
    [8] = ThumbCoord(1032, 1117, 314, 174), -- (Aventure) Netheril Camp 1
    [9] = ThumbCoord(404, 1291,  314, 174), -- [1] Chemin du Reve d'emeraude
}

-- Atlas "UIFrameNeutral" pour le cadre des cartes + le ruban du bouton
-- (memes coordonnees que la version precedente, deja verifiees pixel
-- par pixel - le fichier lui-meme n'a pas change).
local ATLAS = "Interface\\FrameGeneral\\UIFrameNeutral" -- 1024x1024
local COORD_CARD   = { 775/1024, 978/1024, 153/1024, 260/1024 }
local COORD_RIBBON = { 653/1024, 926/1024, 595/1024, 672/1024 }

-- Vrai halo de survol (dore, dans l'atlas ChromieTimeUI 2048x2048 - PAS
-- le meme fichier/recadrage que le cadre COORD_CARD). Utiliser un
-- fichier/recadrage different du cadre pour le survol, plutot que de
-- reutiliser exactement le meme, semble etre ce qui empechait le calque
-- HIGHLIGHT de s'afficher correctement.
local COORD_CARD_HIGHLIGHT = ThumbCoord(1580, 775, 214, 121)

local function SetCrop(tex, c)
    tex:SetTexCoord(c[1], c[2], c[3], c[4])
end

----------------------------------------------------------------
--  Fenetre principale
----------------------------------------------------------------
-- >>> REGLAGES DE MISE EN PAGE <<<
-- Toutes les coordonnees ci-dessous sont exprimees dans l'espace
-- natif de l'image (2048x1024, mesure directement dessus) puis
-- multipliees par SCALE pour s'adapter a la taille d'affichage.
-- 2048x1024 est la resolution du FICHIER TEXTURE (comme n'importe
-- quel .blp), pas la taille a laquelle la fenetre doit s'afficher a
-- l'ecran. Le ratio 2:1 du fichier est preserve (aucun
-- decoupage/etirement, cf SetTexCoord plus bas).
local CONTENT_W, CONTENT_H = 2048, 1024
local FRAME_W = 1000
local SCALE = FRAME_W / CONTENT_W
local FRAME_H = CONTENT_H * SCALE

local function Px(v) return v * SCALE end

-- Zones "propres" de l'image (mesurees a l'oeil sur une grille de
-- reperage 100px, verifiees par crops) ou poser le contenu :
local BANNER_HOLE = { x = 95,  y = 65,  w = 1815, h = 85 }
local TITLE_HOLE  = { x = 95,  y = 515, w = 555,  h = 275 }

-- La zone de droite (grille de cartes) et le bas (bouton Retour) sont
-- entierement vierges dans cette version de l'image : mise en page
-- entierement definie ici, en gardant le ratio natif du cadre de
-- carte de l'atlas (203x107) et du ruban (273x77).
local GRID_X0, GRID_Y0 = 775, 210
local CARD_W, CARD_H   = 350, 184
local CARD_GX, CARD_GY = 35, 20

local RECALL_W, RECALL_H = 280, 79
local RECALL_X, RECALL_Y = 1195, 880

frame:SetFrameStrata("DIALOG")
frame:SetWidth(FRAME_W)
frame:SetHeight(FRAME_H)
frame:SetPoint("CENTER", UIParent, "CENTER", 0, 40)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame:SetClampedToScreen(true)
frame:Hide()

-- Permet de fermer la fenetre avec Echap, comme les fenetres Blizzard standard
UISpecialFrames = UISpecialFrames or {}
table.insert(UISpecialFrames, "PierreFoyerFrame")

----------------------------------------------------------------
--  Image de fond (cadre complet, deja propre)
----------------------------------------------------------------
-- Meme technique que TaxiPathSystemClient.lua (systeme AIO de ce serveur
-- deja eprouve en prod, sans le probleme de texture qui disparait) :
-- SetBackdrop plutot que CreateTexture+SetTexture. La difference n'est
-- pas juste stylistique - CreateTexture alloue un NOUVEL objet texture a
-- chaque appel, ce qui est precisement ce qui s'empilait generation
-- apres generation ; SetBackdrop remplace la texture de fond en place,
-- sur un seul emplacement fixe du frame, donc rien ne peut s'y accumuler
-- meme sans garde-fou. On la combine quand meme avec le garde-fou
-- PDF_Ready ci-dessus pour une double protection.
local function ApplyFrameArt()
    frame:SetBackdrop({
        bgFile = ATLAS_FRAME,
        tile = false,
    })
end
ApplyFrameArt()
-- SetBackdrop est sans risque a rappeler (pas de nouvel objet cree a
-- chaque appel) : on la reapplique aussi a chaque ouverture, en filet de
-- securite supplementaire contre un chargement asynchrone qui aurait
-- rate la premiere fois.
frame:HookScript("OnShow", ApplyFrameArt)

----------------------------------------------------------------
--  Contenu dynamique (toujours au-dessus de l'image de fond,
--  ARTWORK/OVERLAY > BACKGROUND, quel que soit l'ordre de creation)
----------------------------------------------------------------

-- Texte du bandeau
local bannerText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
bannerText:SetPoint("TOPLEFT", frame, "TOPLEFT", Px(BANNER_HOLE.x), -Px(BANNER_HOLE.y))
bannerText:SetWidth(Px(BANNER_HOLE.w))
bannerText:SetHeight(Px(BANNER_HOLE.h))
bannerText:SetJustifyH("CENTER")
bannerText:SetJustifyV("MIDDLE")
bannerText:SetTextColor(1, 0.82, 0.35)
bannerText:SetText(L.bannerText)

-- Bouton fermer (template standard Blizzard, coin haut-droit)
local closeButton = CreateFrame("Button", "PierreFoyerFrameCloseButton", frame, "UIPanelCloseButton")
closeButton:SetSize(20, 20)
closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)
closeButton:SetFrameLevel(frame:GetFrameLevel() + 5)
closeButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetText(L.closeTooltip, 1, 1, 1)
    GameTooltip:Show()
end)
closeButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- Titre + texte sur le parchemin
local panelTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
panelTitle:SetPoint("TOPLEFT", frame, "TOPLEFT", Px(TITLE_HOLE.x), -Px(TITLE_HOLE.y))
panelTitle:SetWidth(Px(TITLE_HOLE.w))
panelTitle:SetJustifyH("LEFT")
panelTitle:SetTextColor(0.35, 0.18, 0.06)
panelTitle:SetShadowOffset(1, -1)
panelTitle:SetShadowColor(0.9, 0.8, 0.6, 0.8)
panelTitle:SetText(L.panelTitle)

local panelBody = frame:CreateFontString(nil, "OVERLAY", "GameFontDarkGraySmall")
panelBody:SetPoint("TOPLEFT", panelTitle, "BOTTOMLEFT", 0, -Px(14))
panelBody:SetWidth(Px(TITLE_HOLE.w))
panelBody:SetJustifyH("LEFT")
panelBody:SetJustifyV("TOP")
panelBody:SetTextColor(0.25, 0.14, 0.05)
panelBody:SetShadowOffset(1, -1)
panelBody:SetShadowColor(0.9, 0.8, 0.6, 0.7)
panelBody:SetText(L.panelBody)

----------------------------------------------------------------
--  Grille 3x3 des destinations : cadre de carte (atlas) + vraie
--  vignette (atlas) + nom localise, entierement dessines ici (la
--  zone est vierge dans l'image de fond). Les 9 cartes sont TOUTES
--  creees ici (une seule fois), meme celles de l'autre faction : elles
--  seront simplement cachees par RefreshVisibility si besoin.
----------------------------------------------------------------
-- IMPORTANT : SetHighlightTexture a ete reessaye (calque HIGHLIGHT
-- special de Blizzard) et confirme, une 2e fois, casser la superposition
-- du cadre sur la vignette (le cadre redevient invisible/cache par la
-- vignette des qu'il est present sur le bouton, meme sans toucher au
-- cadre lui-meme) - ce build/fork particulier ne s'entend pas bien avec
-- ce calque special combine a d'autres textures ARTWORK sur le meme
-- bouton. Abandonne definitivement : le survol est gere entierement a
-- la main (eclaircissement du cadre "de base"), qui reste seul
-- responsable, en permanence, de bien recouvrir la vignette.
local CARD_NORMAL_COLOR  = { 1, 1, 1 }
local CARD_HOVER_COLOR   = { 1.3, 1.2, 0.9 }
local CARD_LOCKED_COLOR  = { 0.5, 0.5, 0.5 }
local CARD_LABEL_COLOR        = { 1, 0.82, 0 }
local CARD_LABEL_LOCKED_COLOR = { 0.6, 0.5, 0.2 }
-- Le cadre depasse de 2px de chaque cote de la carte pour bien recouvrir
-- le fond de la vignette (retractee, elle, de seulement 3px) - un debord
-- modeste comme celui-ci ne deforme pas visiblement le dessin du cadre
-- (contrairement au 4px + ancien systeme de survol Blizzard essaye
-- avant, qui lui posait probleme).
local CARD_OVERHANG = 2

-- Popup de confirmation Blizzard standard, avant teleportation vers une
-- destination "Aventure" (zone potentiellement dangereuse) - evite les
-- clics accidentels. StaticPopupDialogs est une table globale fournie
-- par l'UI Blizzard : on y ajoute simplement notre propre entree.
StaticPopupDialogs["PIERREFOYER_CONFIRM_ADVENTURE"] = {
    text = L.adventureConfirm,
    button1 = ACCEPT,
    button2 = CANCEL,
    OnAccept = function(self, data)
        AIO.Handle("PierreFoyer", "Teleport", data.destIndex)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

local cardButtons = {}
for destIndex, slot in pairs(SLOT_FOR_DEST) do
    local dest = DESTINATIONS[destIndex]
    local row = math.floor((slot - 1) / 3)
    local col = (slot - 1) % 3

    local cx = GRID_X0 + col * (CARD_W + CARD_GX)
    local cy = GRID_Y0 + row * (CARD_H + CARD_GY)

    local card = CreateFrame("Button", "PierreFoyerCard"..destIndex, frame)
    card:SetWidth(Px(CARD_W))
    card:SetHeight(Px(CARD_H))
    card:SetPoint("TOPLEFT", frame, "TOPLEFT", Px(cx), -Px(cy))

    -- Vignette (fond), purement decorative, legerement retractee pour
    -- rester sous le cadre. Calque ARTWORK, sous-niveau -1 : en dessous
    -- du cadre explicitement (voir plus bas), quel que soit l'ordre de
    -- creation ou de reapplication des textures.
    local thumb = card:CreateTexture(nil, "ARTWORK", nil, -1)
    thumb:SetPoint("TOPLEFT", card, "TOPLEFT", 3, -3)
    thumb:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -3, 3)
    thumb:SetTexture(ATLAS_THUMB)
    SetCrop(thumb, THUMB_OVERRIDE[destIndex] or THUMBS[((destIndex - 1) % 6) + 1])

    -- Cadre de carte, exactement a la taille de la carte (pas agrandi -
    -- l'agrandir distordait le dessin du cadre). Calque ARTWORK,
    -- sous-niveau +1 : garanti au-dessus de la vignette (sous-niveau -1)
    -- dans tous les cas.
    local border = card:CreateTexture(nil, "ARTWORK", nil, 1)
    border:SetPoint("TOPLEFT", card, "TOPLEFT", -CARD_OVERHANG, CARD_OVERHANG)
    border:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", CARD_OVERHANG, -CARD_OVERHANG)
    border:SetTexture(ATLAS)
    SetCrop(border, COORD_CARD)

    -- Halo de survol special Blizzard, cette fois avec un fichier/
    -- recadrage different du cadre (voir COORD_CARD_HIGHLIGHT plus haut).
    card:SetHighlightTexture(ATLAS_THUMB)
    local highlightTex = card:GetHighlightTexture()
    SetCrop(highlightTex, COORD_CARD_HIGHLIGHT)

    local label = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("CENTER", card, "CENTER", 0, 0)
    label:SetWidth(Px(CARD_W) - 14)
    label:SetJustifyH("CENTER")
    label:SetShadowOffset(1, -1)
    label:SetShadowColor(0, 0, 0, 1)
    label:SetText(DestName(dest))

    -- Badge "Niveau X", affiche en permanence (pas seulement au survol)
    -- sur les cartes verrouillees, en bas de la vignette. Le texte ne
    -- change jamais (niveau requis fixe par destination) : on le
    -- construit une seule fois ici, RefreshVisibility ne fait que
    -- Show/Hide selon l'etat verrouille/deverrouille.
    local lockBadge = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    lockBadge:SetPoint("BOTTOM", card, "BOTTOM", 0, 11)
    lockBadge:SetTextColor(1, 0.15, 0.15)
    lockBadge:SetShadowOffset(1, -1)
    lockBadge:SetShadowColor(0, 0, 0, 1)
    if dest.requiredLevel then
        lockBadge:SetText(string.format(L.lockedBadge, dest.requiredLevel))
    end
    lockBadge:Hide()

    card.label = label
    card.thumb = thumb
    card.border = border
    card.highlightTex = highlightTex
    card.lockBadge = lockBadge
    card.dest = dest

    card:SetScript("OnClick", function()
        -- Le client grise deja les destinations trop hautes pour le
        -- niveau du joueur (voir RefreshVisibility), mais le serveur
        -- refait de toute facon sa propre verification avant de
        -- teleporter - ceci n'est qu'un filtre visuel/confort.
        if dest.adventure then
            -- Destination "Aventure" potentiellement dangereuse :
            -- confirmation obligatoire avant d'envoyer la demande de
            -- teleportation au serveur.
            StaticPopup_Show("PIERREFOYER_CONFIRM_ADVENTURE", DestName(dest), nil, { destIndex = destIndex })
        else
            AIO.Handle("PierreFoyer", "Teleport", destIndex)
        end
    end)

    card:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(DestName(dest), 1, 1, 1)
        if card.locked then
            GameTooltip:AddLine(string.format(L.levelRequired, dest.requiredLevel), 1, 0.2, 0.2)
        end
        GameTooltip:Show()
        if not card.locked then
            border:SetVertexColor(unpack(CARD_HOVER_COLOR))
        end
    end)
    card:SetScript("OnLeave", function()
        GameTooltip:Hide()
        border:SetVertexColor(unpack(card.locked and CARD_LOCKED_COLOR or CARD_NORMAL_COLOR))
    end)

    cardButtons[destIndex] = card
end

-- Meme souci de chargement asynchrone que la texture de fond (voir
-- ApplyFrameArt plus haut) : SetTexture sur les cartes peut rater
-- silencieusement au premier appel. On re-applique donc toutes les
-- textures de toutes les cartes plusieurs fois avec un leger delai a
-- chaque ouverture de la fenetre, comme pour la texture de fond.
local function ApplyCardArt()
    for destIndex, card in pairs(cardButtons) do
        card.border:SetTexture(ATLAS)
        SetCrop(card.border, COORD_CARD)
        card.highlightTex:SetTexture(ATLAS_THUMB)
        SetCrop(card.highlightTex, COORD_CARD_HIGHLIGHT)
        card.thumb:SetTexture(ATLAS_THUMB)
        SetCrop(card.thumb, THUMB_OVERRIDE[destIndex] or THUMBS[((destIndex - 1) % 6) + 1])
    end
end
ApplyCardArt()

local CARD_RETRY_DELAYS = { 0.15, 0.5, 1.5 }
local cardRetryTicker = CreateFrame("Frame")
cardRetryTicker:Hide()
local cardRetryIndex, cardRetryElapsed

cardRetryTicker:SetScript("OnUpdate", function(self, elapsed)
    cardRetryElapsed = cardRetryElapsed + elapsed
    if cardRetryElapsed >= CARD_RETRY_DELAYS[cardRetryIndex] then
        ApplyCardArt()
        cardRetryIndex = cardRetryIndex + 1
        cardRetryElapsed = 0
        if cardRetryIndex > #CARD_RETRY_DELAYS then
            self:Hide()
        end
    end
end)

frame:HookScript("OnShow", function()
    ApplyCardArt()
    cardRetryIndex = 1
    cardRetryElapsed = 0
    cardRetryTicker:Show()
end)

-- Affiche uniquement les cartes correspondant a la faction du
-- personnage actuellement connecte, et grise celles dont le niveau
-- requis n'est pas encore atteint (recalcule a chaque appel, jamais mis
-- en cache) ; les 5 destinations communes restent toujours affichees.
-- Appelee une 1ere fois juste apres la construction, puis a chaque
-- ouverture de la fenetre (le joueur peut avoir gagne un niveau depuis
-- la derniere ouverture) et a chaque (re)connexion suivante dans ce
-- meme processus client (voir le garde-fou PDF_Ready en haut du
-- fichier).
local function RefreshVisibility()
    local playerFaction = UnitFactionGroup("player")
    local playerLevel = UnitLevel("player")
    for destIndex, card in pairs(cardButtons) do
        local dest = DESTINATIONS[destIndex]
        if not dest.faction or dest.faction == playerFaction then
            card:Show()

            -- Etat verrouille de l'appel precedent (nil au tout premier
            -- appel, donc jamais de fausse notification a la construction
            -- ou a la premiere connexion) : sert uniquement a detecter une
            -- transition verrouille -> deverrouille (ex: gain de niveau).
            local wasLocked = card.locked
            local locked = dest.requiredLevel and playerLevel < dest.requiredLevel
            card.locked = locked

            if wasLocked and not locked then
                UIErrorsFrame:AddMessage(string.format(L.destinationUnlocked, DestName(dest)), 1, 0.82, 0, 1, 5)
            end

            if locked then
                card.thumb:SetVertexColor(0.35, 0.35, 0.35)
                card.border:SetVertexColor(unpack(CARD_LOCKED_COLOR))
                card.label:SetTextColor(unpack(CARD_LABEL_LOCKED_COLOR))
                card.highlightTex:SetAlpha(0) -- pas de halo sur une destination verrouillee
                card.lockBadge:Show()
            else
                card.thumb:SetVertexColor(1, 1, 1)
                card.border:SetVertexColor(unpack(CARD_NORMAL_COLOR))
                card.label:SetTextColor(unpack(CARD_LABEL_COLOR))
                card.highlightTex:SetAlpha(1)
                card.lockBadge:Hide()
            end
        else
            card:Hide()
        end
    end
end
RefreshVisibility()
frame.PDF_RefreshVisibility = RefreshVisibility
frame:HookScript("OnShow", RefreshVisibility)

-- Detecte les gains de niveau meme fenetre fermee, pour la notification
-- de deverrouillage (RefreshVisibility compare l'etat verrouille avant/
-- apres et poste le message si une destination vient de se debloquer).
frame:RegisterEvent("PLAYER_LEVEL_UP")
frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LEVEL_UP" then
        RefreshVisibility()
    end
end)

----------------------------------------------------------------
--  Bouton Retour / Recall (ruban de l'atlas UIFrameNeutral)
----------------------------------------------------------------
local recallButton = CreateFrame("Button", "PierreFoyerRecallButton", frame)
recallButton:SetWidth(Px(RECALL_W))
recallButton:SetHeight(Px(RECALL_H))
recallButton:SetPoint("TOPLEFT", frame, "TOPLEFT", Px(RECALL_X), -Px(RECALL_Y))

recallButton:SetNormalTexture(ATLAS)
SetCrop(recallButton:GetNormalTexture(), COORD_RIBBON)
recallButton:SetPushedTexture(ATLAS)
SetCrop(recallButton:GetPushedTexture(), COORD_RIBBON)
recallButton:GetPushedTexture():SetVertexColor(0.8, 0.8, 0.8)

local recallLabel = recallButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
recallLabel:SetPoint("CENTER", recallButton, "CENTER", 0, 1)
recallLabel:SetTextColor(0.25, 0.14, 0.05)
recallLabel:SetShadowOffset(1, -1)
recallLabel:SetShadowColor(0.85, 0.72, 0.5, 0.8)
recallLabel:SetText(L.recallLabel)

recallButton:SetScript("OnClick", function()
    AIO.Handle("PierreFoyer", "Recall")
end)
recallButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L.recallTooltipTitle, 1, 1, 1)
    GameTooltip:AddLine(L.recallTooltipLine, 1, 0.82, 0, true)
    GameTooltip:Show()
    recallLabel:SetTextColor(0.05, 0.02, 0.01)
end)
recallButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
    recallLabel:SetTextColor(0.25, 0.14, 0.05)
end)

----------------------------------------------------------------
--  Bouton "Le temps de Chromie" dans le CharacterFrame
--  (meme schema que le bouton du Grimoire d'identite : ancre sur
--  CharacterFrame, visible uniquement sur l'onglet Personnage)
----------------------------------------------------------------
do
    -- >>> REGLAGES POSITION : ajuste ces 3 valeurs pour repositionner l'icone <<<
    local CF_ANCHOR         = "TOPLEFT"
    local CF_RELATIVE_POINT = "TOPLEFT"
    local CF_OFFSET_X       = 65
    local CF_OFFSET_Y       = -30
    --------------------------------------------------------------

    local button = CreateFrame("Button", "PierreFoyerCharacterFrameButton", CharacterFrame)
    button:SetHeight(28)
    button:SetWidth(28)
    button:SetFrameStrata("HIGH")
    button:SetPoint(CF_ANCHOR, CharacterFrame, CF_RELATIVE_POINT, CF_OFFSET_X, CF_OFFSET_Y)

    -- Icone de base du client (celle de l'objet Le temps de Chromie)
    button:SetNormalTexture("Interface\\Icons\\spell_azerite_essence08")
    button:SetPushedTexture("Interface\\Icons\\spell_azerite_essence08")
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    local pushedTex = button:GetPushedTexture()
    pushedTex:SetTexCoord(0.05, 0.95, 0.05, 0.95)

    -- Suit l'affichage/masquage de l'onglet "Personnage" uniquement
    button:Hide()
    PaperDollFrame:HookScript("OnShow", function() button:Show() end)
    PaperDollFrame:HookScript("OnHide", function() button:Hide() end)
    if PaperDollFrame:IsShown() then button:Show() end

    -- Tooltip au survol
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L.buttonTooltipTitle, 1, 1, 1)
        GameTooltip:AddLine(L.buttonTooltipLine, 1, 0.82, 0, true)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- Deplacement libre en maintenant Shift (facultatif)
    button:SetScript("OnMouseDown", function(self, mouseButton)
        if IsShiftKeyDown() then
            self:StartMoving()
        end
    end)
    button:SetScript("OnMouseUp", function(self)
        self:StopMovingOrSizing()
    end)

    -- Ouvre/ferme la fenetre Le temps de Chromie au clic
    button:SetScript("OnClick", function(self, mouseButton)
        if IsShiftKeyDown() then return end
        if frame:IsShown() then
            frame:Hide()
        else
            frame:Show()
        end
    end)
end

----------------------------------------------------------------
--  Reponses du serveur (confirmation / erreur, message localise)
----------------------------------------------------------------
AIO.AddHandlers("PierreFoyer", {
    Result = function(player, message, r, g, b)
        UIErrorsFrame:AddMessage(message, r or 1, g or 0.82, b or 0, 1, 3.5)
    end,
})

----------------------------------------------------------------
--  Marque la construction comme terminee (voir garde-fou en haut de
--  fichier) et signale la locale du client au serveur (pour les
--  messages de confirmation/erreur cote serveur).
----------------------------------------------------------------
frame.PDF_Ready = true
AIO.Handle("PierreFoyer", "SetLocale", GetLocale())
