-- ============================================================
--  ChoiceSpellClassClient.lua
--  TrinityCore 3.3.5 (Universe) — Eluna + AIO
--
--  Les 9 classes secondaires sont alignees sur UNE SEULE rangee en
--  haut de la fenetre, groupees par 3 selon les 2 barres verticales
--  natives du fond legionfall (Cavalier/Dompteur/Evocateur, puis
--  Necromancien/Empoisonneur/Pyromancien, puis
--  Chronomancien/Geomancien/Ravageur du Chaos). Sous chaque icone de
--  classe, les sorts sont listes A LA VERTICALE (pile d'icones) avec
--  une fleche de pagination cyclique (pointant vers le bas) au pied
--  de la pile. On choisit librement les aptitudes de son build, en
--  cliquant directement sur l'icone d'une case, dans N'IMPORTE
--  QUELLE colonne (melange libre). Respec libre et gratuit : cliquer
--  sur une aptitude deja apprise (icone grisee) la desapprend.
--  Bouton "Reinitialiser tous les sorts" pour tout retirer d'un coup.
--
--  Habillage 100% custom (aucun asset Blizzard de base) :
--    - fond de la fenetre : Interface\legionfall\legionfall
--      (seule la partie HAUTE du parchemin est utilisee — la
--      bande du bas avec les vignettes/boutons est exclue via
--      recadrage TexCoord)
--    - icone de classe (a la place d'une etiquette texte) :
--      Interface\Glues\CHARACTERCREATE\UI-CHARACTERCREATE-CLASSES
--    - anneau d'icone de classe + fleche de pagination + plaque bouton :
--      Interface\Journeys\JourneysFrame2x (meme atlas que Rebirth)
--    - contour des cases de sort : meme bordure que les onglets
--      Jouets/Heritage du systeme de Collection (Interface\Collections\Collections)
--    - bouton fermer : plaque + croix (meme atlas que le reste de l'UI)
--    - tooltip natif sur l'icone de classe (nom) et sur chaque case
--      de sort (nom + description, via GameTooltip:SetHyperlink)
--
--  Ouverture : commande /sortschoix (ou /ssc), ou bouton sur la
--  fenetre de personnage (visible seulement pour les 9 classes
--  secondaires).
-- ============================================================

local AIO = AIO or require("AIO")

if AIO.AddAddon() then
    return
end

local ChoiceSpellClassHandlers = AIO.AddHandlers("ChoiceSpellClassHandler", {})

-- ------------------------------------------------------------
--  Bilingue frFR/enUS : contrairement au reste du serveur (qui
--  passe par account.locale cote auth DB pour les messages de
--  chat), ce script tourne reellement dans le client -> on utilise
--  directement l'API native GetLocale() du jeu, plus simple et
--  plus fiable qu'un aller-retour serveur pour l'habillage de l'UI.
-- ------------------------------------------------------------
local CLIENT_LOCALE = (GetLocale() == "frFR") and "frFR" or "enUS"

local UI_STRINGS = {
    enUS = {
        title            = "Secondary Class Abilities",
        slots            = "Levels: %d / %d",
        resetButton      = "Reset All Spells",
        cfTooltipTitle   = "Secondary Class Abilities",
        cfTooltipLine    = "Click to open (or /ssc)",
    },
    frFR = {
        title            = "Aptitudes de Classe Secondaire",
        slots            = "Niveaux : %d / %d",
        resetButton      = "Réinitialiser tous les sorts",
        cfTooltipTitle   = "Aptitudes de classe secondaire",
        cfTooltipLine    = "Clic pour ouvrir (ou /ssc)",
    },
}
local STR = UI_STRINGS[CLIENT_LOCALE]

local CLIENT_CATALOG = {
    Cavalier = {
        { key = "attaque_sournoise", id = 53 },
        { key = "attaque_pernicieuse", id = 1752 },
        { key = "evisceration", id = 2098 },
        { key = "garrot", id = 703 },
        { key = "coup_de_pied", id = 1766 },
        { key = "debiter", id = 5171 },
        { key = "coup_bas", id = 1833 },
        { key = "camouflage", id = 1785 },
        { key = "feinte", id = 1966 },
        { key = "vol_a_la_tire", id = 921 },
        { key = "distraction", id = 1725 },
        { key = "embuscade", id = 8676 },
        { key = "aiguillon_perfide", id = 408 },
        { key = "exposer_armure", id = 8647 },
        { key = "rupture", id = 1943 },
        { key = "hemorragie", id = 16511 },
        { key = "demantelement", id = 51722 },
        { key = "cape_d_ombre", id = 31224 },
        { key = "premeditation", id = 14183 },
        { key = "danse_de_l_ombre", id = 51713 },
        { key = "eventail_de_couteaux", id = 51723 },
        { key = "frappe_fantome", id = 33925 },
    },
    Chronomancer = {
        { key = "eclair_de_givre", id = 116 },
        { key = "cone_de_froid", id = 120 },
        { key = "blizzard", id = 10 },
        { key = "barriere_de_glace", id = 11426 },
        { key = "metamorphose", id = 118 },
        { key = "nova_de_givre", id = 122 },
        { key = "contresort", id = 2139 },
        { key = "javelot_de_glace", id = 30455 },
        { key = "ralentissement", id = 10855 },
        { key = "armure_de_givre", id = 168 },
        { key = "bloc_de_glace", id = 45438 },
        { key = "veines_glaciales", id = 12472 },
    },
    Dompteur = {
        { key = "attaque_du_raptor", id = 2973 },
        { key = "morsure_de_serpent", id = 1978 },
        { key = "tir_des_arcanes", id = 3044 },
        { key = "fleches_multiples", id = 2643 },
        { key = "marque_du_chasseur", id = 1130 },
        { key = "guerison_du_familier", id = 136 },
        { key = "aspect_du_faucon", id = 13165 },
        { key = "visee", id = 19434 },
        { key = "piege_explosif", id = 13813 },
        { key = "piege_givrant", id = 1499 },
        { key = "tir_tranquillisant", id = 19801 },
        { key = "tir_assure", id = 56641 },
        { key = "trait_de_choc", id = 5116 },
        { key = "desengagement", id = 781 },
        { key = "fleche_de_dispersion", id = 19503 },
        { key = "fleche_noire", id = 3674 },
        { key = "aspect_de_la_vipere", id = 34074 },
        { key = "dissuasion", id = 19263 },
        { key = "piqure_de_scorpide", id = 3043 },
        { key = "aspect_de_la_meute", id = 13159 },
        { key = "effrayer_une_bete", id = 1513 },
    },
    Evoker = {
        { key = "eclair", id = 403 },
        { key = "chaine_d_eclairs", id = 421 },
        { key = "projectiles_des_arcanes", id = 5143 },
        { key = "explosion_des_arcanes", id = 1449 },
        { key = "bouclier_de_mana", id = 1463 },
        { key = "deflagration_des_arcanes", id = 30451 },
        { key = "pouvoir_des_arcanes", id = 12042 },
        { key = "presence_spirituelle", id = 12043 },
        { key = "intelligence_des_arcanes", id = 1459 },
        { key = "lenteur", id = 31589 },
        { key = "transfert", id = 1953 },
        { key = "delivrance_malediction", id = 475 },
    },
    Geomancer = {
        { key = "horion_de_terre", id = 8042 },
        { key = "arme_croque_roc", id = 8017 },
        { key = "epines", id = 467 },
        { key = "sarments", id = 26989 },
        { key = "totem_de_force_de_la_terre", id = 8075 },
        { key = "totem_de_magma", id = 8187 },
        { key = "totem_de_peau_de_pierre", id = 8071 },
        { key = "purification", id = 17550 },
        { key = "seisme", id = 61882 },
        { key = "horion_de_givre", id = 8056 },
        { key = "horion_de_flammes", id = 8050 },
        { key = "salve_de_guerison", id = 1064 },
    },
    Necromancer = {
        { key = "trait_de_l_ombre", id = 686 },
        { key = "mot_de_l_ombre_douleur", id = 589 },
        { key = "drain_d_ame", id = 1120 },
        { key = "drain_de_vie", id = 689 },
        { key = "malediction_d_agonie", id = 980 },
        { key = "armure_demoniaque", id = 706 },
        { key = "voile_mortel", id = 6789 },
        { key = "fouet_mental", id = 15407 },
        { key = "peste_devorante", id = 2944 },
        { key = "toucher_vampirique", id = 34914 },
        { key = "mot_de_l_ombre_mort", id = 32379 },
        { key = "pacte_noir", id = 18220 },
        { key = "malediction_de_faiblesse", id = 702 },
        { key = "peur", id = 5782 },
        { key = "malediction_des_elements", id = 1490 },
        { key = "malediction_funeste", id = 603 },
        { key = "hurlement_de_terreur", id = 5484 },
        { key = "controle_mental", id = 605 },
        { key = "furie_de_l_ombre", id = 30283 },
        { key = "lien_spirituel", id = 19028 },
        { key = "carapace_anti_magie", id = 48707 },
        { key = "bouclier_d_os", id = 49222 },
        { key = "froid_devorant", id = 49203 },
        { key = "poigne_de_la_mort", id = 49576 },
        { key = "changeliche", id = 49039 },
        { key = "chancre_impie", id = 49194 },
        { key = "sang_vampirique", id = 55233 },
        { key = "zone_anti_magie", id = 51052 },
        { key = "armee_des_morts", id = 42650 },
        { key = "invocation_d_une_gargouille", id = 49206 },
        { key = "frappe_du_fleau", id = 55090 },
        { key = "frappe_de_peste", id = 45462 },
        { key = "toucher_de_glace", id = 45477 },
        { key = "mort_et_decomposition", id = 43265 },
    },
    Pyromancer = {
        { key = "boule_de_feu", id = 133 },
        { key = "trait_de_feu", id = 2136 },
        { key = "brulure", id = 2948 },
        { key = "choc_de_flammes", id = 2120 },
        { key = "explosion_pyrotechnique", id = 11366 },
        { key = "bombe_vivante", id = 44457 },
        { key = "souffle_du_dragon", id = 31661 },
        { key = "combustion", id = 11129 },
        { key = "immolation", id = 348 },
        { key = "vague_explosive", id = 11113 },
        { key = "gardien_de_feu", id = 543 },
        { key = "armure_fournaise", id = 30482 },
    },
    RavageurChaos = {
        { key = "frappe_heroique", id = 78 },
        { key = "coup_de_tonnerre", id = 6343 },
        { key = "fracasser_armure", id = 7386 },
        { key = "vengeance", id = 6572 },
        { key = "execution", id = 5308 },
        { key = "cri_de_guerre", id = 2048 },
        { key = "tourbillon", id = 1680 },
        { key = "represailles", id = 20240 },
        { key = "charge", id = 100 },
        { key = "onde_de_choc", id = 46968 },
        { key = "provocation", id = 26281 },
        { key = "balayage", id = 31279 },
    },
    Venomancer = {
        { key = "evisceration", id = 2098 },
        { key = "garrot", id = 703 },
        { key = "coup_de_pied", id = 1766 },
        { key = "poison_mortel", id = 2818 },
        { key = "poison_instantane", id = 8679 },
        { key = "poison_douloureux", id = 13218 },
        { key = "poison_affaiblissant", id = 3408 },
        { key = "poison_de_distraction_mentale", id = 5761 },
        { key = "assommer", id = 6770 },
        { key = "attaque_pernicieuse", id = 1752 },
        { key = "evasion", id = 5277 },
        { key = "sprint", id = 2983 },
        { key = "disparition", id = 1856 },
        { key = "cecite", id = 2094 },
        { key = "rupture", id = 1943 },
        { key = "hemorragie", id = 16511 },
        { key = "demantelement", id = 51722 },
        { key = "cape_d_ombre", id = 31224 },
        { key = "premeditation", id = 14183 },
        { key = "danse_de_l_ombre", id = 51713 },
        { key = "eventail_de_couteaux", id = 51723 },
        { key = "frappe_fantome", id = 33925 },
    },
}

local CLASS_LABELS_EN = {
    Cavalier = "Cavalier",
    Chronomancer = "Chronomancer",
    Dompteur = "Tamer",
    Evoker = "Evoker",
    Geomancer = "Geomancer",
    Necromancer = "Necromancer",
    Pyromancer = "Pyromancer",
    RavageurChaos = "Chaos Ravager",
    Venomancer = "Venomancer",
}
local CLASS_LABELS_FR = {
    Cavalier = "Cavalier",
    Chronomancer = "Chronomancien",
    Dompteur = "Dompteur",
    Evoker = "Evocateur",
    Geomancer = "Geomancien",
    Necromancer = "Necromancien",
    Pyromancer = "Pyromancien",
    RavageurChaos = "Ravageur du Chaos",
    Venomancer = "Empoisonneur",
}
local CLASS_LABELS = (CLIENT_LOCALE == "frFR") and CLASS_LABELS_FR or CLASS_LABELS_EN

-- Les 9 classes sont affichees sur UNE SEULE rangee, en tete de
-- fenetre, groupees par 3 selon les 2 barres verticales du fond
-- legionfall :
--   Groupe 1 (avant la 1ere barre)  : Cavalier, Dompteur, Evocateur
--   Groupe 2 (entre les 2 barres)   : Necromancien, Empoisonneur, Pyromancien
--   Groupe 3 (apres la 2eme barre)  : Chronomancien, Geomancien, Ravageur du Chaos
-- Chaque sort de la classe se deroule EN COLONNE sous son icone.
-- x = position horizontale (pixels) du centre de la colonne, mesuree
-- proportionnellement sur le fond legionfall puis mise a l'echelle
-- de FRAME_W (voir Configuration visuelle plus bas).
local CLASS_ORDER = { "Cavalier", "Dompteur", "Evoker", "Necromancer", "Venomancer", "Pyromancer", "Chronomancer", "Geomancer", "RavageurChaos" }
local COL_X_FRACTION = {
    Cavalier      = 0.0924,
    Dompteur      = 0.1871,
    Evoker        = 0.2864,
    Necromancer   = 0.4134,
    Venomancer    = 0.5058,
    Pyromancer    = 0.5935,
    Chronomancer  = 0.7286,
    Geomancer     = 0.8222,
    RavageurChaos = 0.9284,
}
-- Ajustement fin en pixels (apres mise a l'echelle par FRAME_W) :
-- la colonne Ravageur du Chaos a ete demandee 10px plus a gauche.
local COL_X_OFFSET = {
    RavageurChaos = -10,
}

-- Correspondance classID numerique (WoW) -> notre classKey, utilisee
-- uniquement pour savoir si le joueur local est une classe secondaire
-- (afficher ou non le bouton sur la fenetre de personnage).
local CLASS_ID_TO_KEY = {
    [12] = "Cavalier",
    [15] = "Dompteur",
    [17] = "Evoker",
    [18] = "Necromancer",
    [19] = "Venomancer",
    [20] = "Pyromancer",
    [21] = "Chronomancer",
    [22] = "Geomancer",
    [23] = "RavageurChaos",
}

-- Coordonnees fournies (table CLASS_ICON_TCOORDS), sur l'atlas
-- UI-CHARACTERCREATE-CLASSES (8x8 cases). Mapping vers nos 9 classes :
--   Cavalier       -> KNIGHT        (icone cheval, pas d'entree "CAVALIER" dans ta table)
--   Dompteur       -> TAMER         (Tamer = Dompteur)
--   Evoker         -> EVOKER        (correspondance directe)
--   RavageurChaos  -> CHAOSRAVAGER  (correspondance directe)
--   Chronomancer / Geomancer / Necromancer / Pyromancer / Venomancer :
--     ces 5 entrees pointent TOUTES vers les memes coordonnees
--     {0.125,0.25,0.25,0.375} dans la table que tu as partagee ->
--     c'est normal / attendu (confirme par toi), elles partagent la
--     meme icone tant qu'il n'y en a pas de dediees.
local CLASS_ICON_COORDS = {
    Cavalier      = { 0.625, 0.75, 0, 0.125 },       -- KNIGHT
    Chronomancer  = { 0.125, 0.25, 0.25, 0.375 },
    Dompteur      = { 0.5, 0.625, 0, 0.125 },        -- TAMER
    Evoker        = { 0, 0.125, 0.125, 0.25 },
    Geomancer     = { 0.125, 0.25, 0.25, 0.375 },
    Necromancer   = { 0.125, 0.25, 0.25, 0.375 },
    Pyromancer    = { 0.125, 0.25, 0.25, 0.375 },
    RavageurChaos = { 0, 0.125, 0.5, 0.625 },        -- CHAOSRAVAGER
    Venomancer    = { 0.125, 0.25, 0.25, 0.375 },
}

-- ------------------------------------------------------------
--  Configuration visuelle
-- ------------------------------------------------------------
-- Fenetre 820x820 : les 9 classes sont sur UNE SEULE rangee en haut,
-- chacune avec sa pile verticale de sorts en dessous. COL_X_FRACTION
-- (ci-dessus) donne la position horizontale de chaque colonne en
-- fraction de la largeur du parchemin (mesuree pour tomber pile
-- entre/sur les 2 barres verticales du fond legionfall) ; on la
-- multiplie par FRAME_W. HEADER_H encore augmente (+20px, 4e retour
-- joueur) pour redescendre les 9 colonnes sous le titre + hauteur de
-- fenetre augmentee en consequence pour que la pile de 12 sorts/page
-- tienne toujours confortablement.
local FRAME_W, FRAME_H = 1200, 790
local CLASS_ICON_SIZE = 60
local ICON_SIZE = 44
local ICON_GAP = 4
local ICONS_PER_COL = 12
local ICON_PITCH = ICON_SIZE + ICON_GAP
local HEADER_H = 88     -- titre + compteur d'emplacements (+20px : colonnes redescendues)
local FOOTER_H = 34      -- bouton reinitialiser

-- Assets 100% custom :
--   Interface\legionfall\legionfall                            : fond (partie haute uniquement)
--   Interface\Glues\CHARACTERCREATE\UI-CHARACTERCREATE-CLASSES : icone de classe
--   Interface\Journeys\JourneysFrame2x                        : anneau de case d'icone,
--     fleche de pagination et plaque du bouton "Reinitialiser"
--     (meme atlas que le systeme Rebirth). Coordonnees mesurees sur
--     les textures source :
--       RING_COORD   : anneau d'icone (journeysframe2x, atlas 2048x2048, box pixel 688,208-806,326)
--       ARROW_NEXT   : fleche pleine  (journeysframe2x, box pixel 5,5-46,76)
--       PLATE_NORMAL : plaque bouton  (journeysframe2x, box pixel 54,210-686,419)
--       BG_COORD     : legionfall.blp (atlas 1024x1024) — box pixel (3,4)-(871,576), le
--         "parchemin" du haut uniquement. La bande du bas (vignettes de zone /
--         boutons, pixel y>578) est explicitement exclue, comme demande.
local BG_TEXTURE         = "Interface\\legionfall\\legionfall"
local ATLAS_TEXTURE      = "Interface\\Journeys\\JourneysFrame2x"
local CLASS_ICON_TEXTURE = "Interface\\Glues\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES"
local RING_COORD    = { 0.335938, 0.393555, 0.101563, 0.159180 }
-- Contour des CASES DE SORT (uniquement) : meme bordure carree que les
-- onglets Jouets/Heritage du systeme de Collection ("collections-itemborder-
-- collected", 56x56, deja presente cote client Universe -> aucun fichier a
-- livrer). L'icone de classe garde son propre anneau (RING_COORD ci-dessus).
local ITEM_BORDER_TEXTURE = "Interface\\Collections\\Collections"
local ITEM_BORDER_COORD   = { 0.246094, 0.355469, 0.013672, 0.123047 }
local ARROW_NEXT     = { 0.002441, 0.022461, 0.002441, 0.037109 }
-- Meme morceau d'atlas que ARROW_NEXT, mais tourne de 90 degres
-- (forme 8 valeurs de SetTexCoord : HG, BG, HD, BD) pour pointer
-- vers le bas — la pile de sorts est verticale, la fleche de
-- pagination doit donc pointer "vers le bas de la pile" plutot que
-- vers la droite.
local ARROW_NEXT_DOWN = {
    ARROW_NEXT[1], ARROW_NEXT[4],   -- haut-gauche  = (L, B)
    ARROW_NEXT[2], ARROW_NEXT[4],   -- bas-gauche   = (R, B)
    ARROW_NEXT[1], ARROW_NEXT[3],   -- haut-droite  = (L, T)
    ARROW_NEXT[2], ARROW_NEXT[3],   -- bas-droite   = (R, T)
}
local PLATE_NORMAL   = { 0.026367, 0.334961, 0.102539, 0.204590 }
local BG_COORD = { 3 / 1024, 871 / 1024, 4 / 1024, 576 / 1024 }

-- ------------------------------------------------------------
--  Etat local
-- ------------------------------------------------------------
local myChoices = {}   -- ["classKey|abilityKey"] = true
local maxSlots  = 0
local usedSlots = 0

local function ChoiceId(classKey, abilityKey)
    return classKey .. "|" .. abilityKey
end

-- ------------------------------------------------------------
--  Frame principale
-- ------------------------------------------------------------
local MainFrame = nil
local SlotText = nil
local RowByClass = {}   -- [classKey] = { frame, icons={}, arrow, pageText, page }

local RefreshRow
local RefreshAllRows

-- ------------------------------------------------------------
--  Construit une colonne "classe" : icone de classe en haut (toutes
--  les classes sont alignees sur la MEME ligne horizontale), puis
--  une PILE VERTICALE d'icones de sort en dessous, avec une fleche
--  de pagination cyclique (pointant vers le bas) au pied de la pile.
-- ------------------------------------------------------------
local function CreateClassRow(classKey, centerX)
    local blockTop = -HEADER_H

    local row = CreateFrame("Frame", nil, MainFrame)
    row:SetSize(60, FRAME_H - HEADER_H - FOOTER_H)
    row:SetPoint("TOP", MainFrame, "TOPLEFT", centerX, blockTop)

    -- Icone de classe (remplace l'etiquette texte), centree en haut du bloc
    local classIcon = CreateFrame("Button", nil, row)
    classIcon:SetSize(CLASS_ICON_SIZE, CLASS_ICON_SIZE)
    classIcon:SetPoint("TOP", row, "TOP", 0, 0)

    local classIconTex = classIcon:CreateTexture(nil, "ARTWORK")
    classIconTex:SetAllPoints(classIcon)
    classIconTex:SetTexture(CLASS_ICON_TEXTURE)
    classIconTex:SetTexCoord(unpack(CLASS_ICON_COORDS[classKey] or { 0, 0.125, 0, 0.125 }))

    local classIconRing = classIcon:CreateTexture(nil, "OVERLAY")
    classIconRing:SetAllPoints(classIcon)
    classIconRing:SetTexture(ATLAS_TEXTURE)
    classIconRing:SetTexCoord(unpack(RING_COORD))

    classIcon:EnableMouse(true)
    classIcon:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(CLASS_LABELS[classKey] or classKey)
        GameTooltip:Show()
    end)
    classIcon:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- Pile verticale d'icones de sort, sous l'icone de classe
    local icons = {}
    for i = 1, ICONS_PER_COL do
        local slot = CreateFrame("Button", nil, row)
        slot:SetSize(ICON_SIZE, ICON_SIZE)
        slot:SetPoint("TOP", classIcon, "BOTTOM", 0, -6 - (i - 1) * ICON_PITCH)

        local icon = slot:CreateTexture(nil, "ARTWORK")
        icon:SetPoint("CENTER")
        icon:SetSize(ICON_SIZE - 4, ICON_SIZE - 4)
        slot.icon = icon

        local ring = slot:CreateTexture(nil, "OVERLAY")
        ring:SetAllPoints(slot)
        ring:SetTexture(ITEM_BORDER_TEXTURE)
        ring:SetTexCoord(unpack(ITEM_BORDER_COORD))
        slot.ring = ring

        slot:EnableMouse(true)
        slot:SetScript("OnEnter", function(self)
            if self.spellId then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                -- NOTE : SetSpellByID n'existe pas sur le client 3.3.5 (ajoute
                -- dans des clients plus recents) ; sur WotLK il faut passer
                -- par un hyperlien "spell:<id>" pour obtenir nom+description.
                GameTooltip:SetHyperlink("spell:" .. self.spellId)
                GameTooltip:Show()
                self.ring:SetVertexColor(1, 1, 0.55)
            end
        end)
        slot:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
            if self.hasAbility then
                if self.chosen then
                    self.ring:SetVertexColor(0.55, 0.55, 0.55)
                else
                    self.ring:SetVertexColor(1, 1, 1)
                end
            end
        end)
        slot:SetScript("OnClick", function(self)
            if not self.hasAbility then return end
            if self.chosen then
                AIO.Handle("ChoiceSpellClassHandler", "RemoveAbility", self.classKey, self.abilityKey)
            else
                AIO.Handle("ChoiceSpellClassHandler", "ChooseAbility", self.classKey, self.abilityKey)
            end
        end)

        icons[i] = slot
    end

    -- Fleche de pagination cyclique (pointe vers le bas) + compteur "X/Y",
    -- sous la pile de sorts.
    local arrow = CreateFrame("Button", nil, row)
    arrow:SetSize(20, 20)
    arrow:SetPoint("TOP", icons[ICONS_PER_COL], "BOTTOM", 0, -6)

    local arrowTex = arrow:CreateTexture(nil, "ARTWORK")
    arrowTex:SetAllPoints(arrow)
    arrowTex:SetTexture(ATLAS_TEXTURE)
    arrowTex:SetTexCoord(unpack(ARROW_NEXT_DOWN))
    arrow.tex = arrowTex

    arrow:SetScript("OnEnter", function(self) self.tex:SetVertexColor(1, 1, 0.6) end)
    arrow:SetScript("OnLeave", function(self) self.tex:SetVertexColor(1, 1, 1) end)

    local pageText = row:CreateFontString(nil, "OVERLAY")
    pageText:SetFont("Fonts\\FRIZQT__.TTF", 9, "")
    pageText:SetPoint("TOP", arrow, "BOTTOM", 0, -2)
    pageText:SetTextColor(1, 1, 1)

    local rowData = {
        frame = row,
        icons = icons,
        arrow = arrow,
        pageText = pageText,
        page = 1,
        classKey = classKey,
    }

    arrow:SetScript("OnClick", function()
        local abilities = CLIENT_CATALOG[classKey] or {}
        local maxPage = math.max(1, math.ceil(#abilities / ICONS_PER_COL))
        if maxPage <= 1 then return end
        rowData.page = rowData.page + 1
        if rowData.page > maxPage then rowData.page = 1 end
        RefreshRow(rowData)
    end)

    RowByClass[classKey] = rowData
    return rowData
end

local function EnsureMainFrame()
    if MainFrame then return end

    MainFrame = CreateFrame("Frame", "ChoiceSpellClassFrame", UIParent)
    MainFrame:SetSize(FRAME_W, FRAME_H)
    MainFrame:SetPoint("CENTER")
    -- Strata la plus haute possible (au-dessus de toutes les autres UI,
    -- y compris les autres fenetres custom) + niveau eleve dans cette strata.
    MainFrame:SetFrameStrata("FULLSCREEN_DIALOG")
    MainFrame:SetFrameLevel(200)
    MainFrame:SetToplevel(true)
    MainFrame:SetMovable(true)
    MainFrame:EnableMouse(true)
    MainFrame:RegisterForDrag("LeftButton")
    MainFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    MainFrame:SetScript("OnDragStop",  function(self) self:StopMovingOrSizing() end)

    -- Fond plein 100% custom (aucun backdrop Blizzard) : uniquement la
    -- partie haute du parchemin legionfall (cf BG_COORD), la bande du
    -- bas avec les vignettes/boutons n'est jamais affichee.
    local bg = MainFrame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(MainFrame)
    bg:SetTexture(BG_TEXTURE)
    bg:SetTexCoord(unpack(BG_COORD))
    MainFrame.bg = bg

    -- Titre : police "parchemin/titre" MORPHEUS (meme famille que les
    -- titres de quete/hauts faits Blizzard) plutot que la police d'UI
    -- generique FRIZQT__, en dore, pour se detacher du fond legionfall.
    local title = MainFrame:CreateFontString(nil, "OVERLAY")
    title:SetFont("Fonts\\MORPHEUS.TTF", 20, "OUTLINE")
    title:SetPoint("TOP", MainFrame, "TOP", 0, -14)
    title:SetTextColor(255, 255, 255)
    title:SetText(STR.title)

    SlotText = MainFrame:CreateFontString(nil, "OVERLAY")
    SlotText:SetFont("Fonts\\FRIZQT__.TTF", 11, "")
    SlotText:SetPoint("TOP", title, "BOTTOM", -480, -20)
    SlotText:SetTextColor(255, 255, 255)
    SlotText:SetText(string.format(STR.slots, 0, 0))

    -- Bouton fermer : plaque ronde (meme atlas que l'anneau d'icone de
    -- classe, Interface\Journeys\JourneysFrame2x) + croix "X" par-dessus,
    -- au lieu d'un texte flottant sans fond.
    local closeBtn = CreateFrame("Button", nil, MainFrame)
    closeBtn:SetSize(26, 26)
    closeBtn:SetPoint("TOPRIGHT", MainFrame, "TOPRIGHT", -30, -30)

    local closeBg = closeBtn:CreateTexture(nil, "BACKGROUND")
    closeBg:SetAllPoints(closeBtn)
    closeBg:SetTexture(ATLAS_TEXTURE)
    closeBg:SetTexCoord(unpack(RING_COORD))
    closeBg:SetVertexColor(0.55, 0.12, 0.08)
    closeBtn.bg = closeBg

    local closeLabel = closeBtn:CreateFontString(nil, "OVERLAY")
    closeLabel:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
    closeLabel:SetPoint("CENTER", 0, 0)
    closeLabel:SetText("X")
    closeLabel:SetTextColor(1, 0.92, 0.8)
    closeBtn.label = closeLabel

    closeBtn:SetScript("OnClick", function() MainFrame:Hide() end)
    closeBtn:SetScript("OnEnter", function(self)
        self.bg:SetVertexColor(0.85, 0.18, 0.12)
        self.label:SetTextColor(1, 1, 1)
    end)
    closeBtn:SetScript("OnLeave", function(self)
        self.bg:SetVertexColor(0.55, 0.12, 0.08)
        self.label:SetTextColor(1, 0.92, 0.8)
    end)

    tinsert(UISpecialFrames, "ChoiceSpellClassFrame")

    -- ── 9 classes sur une seule rangee (groupees 3/3/3 par les
    --    2 barres verticales du fond legionfall) ─────────────
    for _, classKey in ipairs(CLASS_ORDER) do
        local centerX = FRAME_W * (COL_X_FRACTION[classKey] or 0.5) + (COL_X_OFFSET[classKey] or 0)
        CreateClassRow(classKey, centerX)
    end

    -- ── Bouton "Reinitialiser tous les sorts" ───────────────
    local resetBtn = CreateFrame("Button", nil, MainFrame)
    resetBtn:SetSize(200, 26)
    resetBtn:SetPoint("BOTTOM", MainFrame, "BOTTOM", 400, 730)

    local resetBg = resetBtn:CreateTexture(nil, "BACKGROUND")
    resetBg:SetAllPoints(resetBtn)
    resetBg:SetTexture(ATLAS_TEXTURE)
    resetBg:SetTexCoord(unpack(PLATE_NORMAL))
    resetBtn.bg = resetBg

    local resetLabel = resetBtn:CreateFontString(nil, "OVERLAY")
    resetLabel:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    resetLabel:SetPoint("CENTER")
    resetLabel:SetText(STR.resetButton)
    resetLabel:SetTextColor(255, 255, 255)

    resetBtn:SetScript("OnEnter", function(self) self.bg:SetVertexColor(1, 0.7, 0.7) end)
    resetBtn:SetScript("OnLeave", function(self) self.bg:SetVertexColor(1, 1, 1) end)
    resetBtn:SetScript("OnClick", function()
        AIO.Handle("ChoiceSpellClassHandler", "ResetAll")
    end)

    MainFrame:Hide()
end

-- ------------------------------------------------------------
--  Met a jour le texte du compteur d'emplacements
-- ------------------------------------------------------------
local function RefreshSlotText()
    if not SlotText then return end
    SlotText:SetText(string.format(STR.slots, usedSlots, maxSlots))
    if usedSlots >= maxSlots then
        SlotText:SetTextColor(255, 255, 255)
    else
        SlotText:SetTextColor(255, 255, 255)
    end
end

-- ------------------------------------------------------------
--  Reconstruit la page courante d'un bloc (classe)
-- ------------------------------------------------------------
RefreshRow = function(rowData)
    local abilities = CLIENT_CATALOG[rowData.classKey] or {}
    local total = #abilities
    local maxPage = math.max(1, math.ceil(total / ICONS_PER_COL))
    if rowData.page > maxPage then rowData.page = maxPage end

    local startIndex = (rowData.page - 1) * ICONS_PER_COL

    for i = 1, ICONS_PER_COL do
        local slot = rowData.icons[i]
        local ability = abilities[startIndex + i]

        if ability then
            slot:Show()
            slot.classKey = rowData.classKey
            slot.abilityKey = ability.key
            slot.spellId = ability.id
            slot.hasAbility = true

            local name, _, icon = GetSpellInfo(ability.id)
            slot.icon:SetTexture(icon or "Interface\\Icons\\INV_Misc_QuestionMark")
            slot.icon:Show()

            local chosen = myChoices[ChoiceId(rowData.classKey, ability.key)] == true
            slot.chosen = chosen
            -- Une aptitude apprise se grise (icone desaturee) ; recliquer
            -- sur une icone grisee la desapprend (deja gere par OnClick).
            slot.icon:SetDesaturated(chosen)
            if chosen then
                slot.ring:SetVertexColor(0.55, 0.55, 0.55)
            else
                slot.ring:SetVertexColor(1, 1, 1)
            end
        else
            -- FIX : plutot que d'afficher un cadre vide (ce qui donnait
            -- l'impression d'un "emplacement manquant" a chaque nouveau
            -- retour joueur, quelle que soit la taille du catalogue), on
            -- masque entierement la case des qu'il n'y a plus d'aptitude
            -- a afficher sur cette page. Plus aucune case vide visible,
            -- quel que soit le nombre total d'aptitudes de la classe.
            slot.hasAbility = false
            slot.spellId = nil
            slot.chosen = false
            slot:Hide()
        end
    end

    if maxPage > 1 then
        rowData.pageText:SetText(rowData.page .. "/" .. maxPage)
        rowData.pageText:Show()
        rowData.arrow:Show()
    else
        rowData.pageText:Hide()
        rowData.arrow:Hide()
    end
end

-- ------------------------------------------------------------
--  Reconstruit tous les blocs (les 9 classes)
-- ------------------------------------------------------------
RefreshAllRows = function()
    for _, classKey in ipairs(CLASS_ORDER) do
        local rowData = RowByClass[classKey]
        if rowData then
            RefreshRow(rowData)
        end
    end
end

-- ------------------------------------------------------------
--  Handler AIO : reception de l'etat depuis le serveur
--  (maxSlots, usedSlots, "classKey|abilityKey", "classKey|abilityKey", ...)
-- ------------------------------------------------------------
function ChoiceSpellClassHandlers.SyncState(player, newMax, newUsed, ...)
    maxSlots  = tonumber(newMax) or 0
    usedSlots = tonumber(newUsed) or 0

    wipe(myChoices)
    local flat = { ... }
    for _, id in ipairs(flat) do
        myChoices[id] = true
    end

    RefreshSlotText()
    if MainFrame and MainFrame:IsShown() then
        RefreshAllRows()
    end
end

-- ------------------------------------------------------------
--  Ouverture / fermeture de l'interface
-- ------------------------------------------------------------
local function ToggleChoiceSpellClassFrame()
    EnsureMainFrame()
    if MainFrame:IsShown() then
        MainFrame:Hide()
        return
    end
    -- Revient toujours a la page 1 (la plus remplie) a l'ouverture, pour
    -- eviter de rester bloque sur une page de fin partiellement vide dont
    -- on se souvenait d'une session precedente.
    for _, classKey in ipairs(CLASS_ORDER) do
        local rowData = RowByClass[classKey]
        if rowData then rowData.page = 1 end
    end
    RefreshAllRows()
    MainFrame:Show()
    AIO.Handle("ChoiceSpellClassHandler", "RequestState")
end

SLASH_SORTSCHOIX1 = "/sortschoix"
SLASH_SORTSCHOIX2 = "/ssc"
SlashCmdList["SORTSCHOIX"] = ToggleChoiceSpellClassFrame

-- ------------------------------------------------------------
--  Bouton sur la fenetre de personnage (CharacterFrame), visible
--  uniquement si le joueur local est une des 9 classes secondaires.
--  Evite d'avoir a taper /ssc.
-- ------------------------------------------------------------
local function CreateCharacterFrameButton()
    if not CharacterFrame then return end

    local _, _, classId = UnitClass("player")
    local classKey = CLASS_ID_TO_KEY[classId]
    if not classKey then return end -- pas une classe secondaire : pas de bouton

    -- FIX v2 : les 2 tentatives precedentes (ancrage a gauche puis a droite,
    -- toutes deux EN DEHORS des bords de CharacterFrame) restaient invisibles.
    -- CharacterFrame sur ce serveur est un cadre entierement reskinne (voir
    -- SyphrenaPanel.lua fourni par le joueur : son bouton "Grimoire d'identite"
    -- est un CreateFrame("Button", ..., CharacterFrame) ancre A L'INTERIEUR du
    -- cadre, en TOPRIGHT-TOPRIGHT avec un petit decalage negatif, et IL EST
    -- BIEN VISIBLE en jeu) -> tout ce qui depasse le rectangle logique de
    -- CharacterFrame est probablement rogne par le skin. On reproduit
    -- exactement ce pattern : ancrage interieur, juste sous le bouton
    -- Grimoire (qui occupe -10,-30 sur 28x28), et on lie la visibilite a
    -- PaperDollFrame comme le fait SyphrenaPanel.lua.
    local btn = CreateFrame("Button", "ChoiceSpellClassCFButton", CharacterFrame)
    btn:SetSize(30, 30)
    btn:SetFrameStrata("HIGH")
    btn:SetPoint("TOPRIGHT", CharacterFrame, "TOPRIGHT", -458, -30)

    local tex = btn:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints(btn)
    tex:SetTexture(CLASS_ICON_TEXTURE)
    tex:SetTexCoord(unpack(CLASS_ICON_COORDS[classKey] or { 0, 0.125, 0, 0.125 }))

    local ring = btn:CreateTexture(nil, "OVERLAY")
    ring:SetAllPoints(btn)
    ring:SetTexture(ATLAS_TEXTURE)
    ring:SetTexCoord(unpack(RING_COORD))

    btn:EnableMouse(true)
    btn:SetScript("OnClick", ToggleChoiceSpellClassFrame)
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText(STR.cfTooltipTitle)
        GameTooltip:AddLine(STR.cfTooltipLine, 0.8, 0.8, 0.8)
        GameTooltip:Show()
        ring:SetVertexColor(1, 1, 0.6)
    end)
    btn:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
        ring:SetVertexColor(1, 1, 1)
    end)

    -- Meme comportement que le bouton Grimoire d'identite : visible
    -- uniquement sur l'onglet "Personnage" (PaperDollFrame).
    btn:Hide()
    if PaperDollFrame then
        PaperDollFrame:HookScript("OnShow", function() btn:Show() end)
        PaperDollFrame:HookScript("OnHide", function() btn:Hide() end)
        if PaperDollFrame:IsShown() then btn:Show() end
    else
        btn:Show()
    end
end

-- FIX v3 : garde + declencheurs multiples. Sur ce serveur, UnitClass("player")
-- peut ne pas encore renvoyer le bon classId (classes custom) au moment de
-- PLAYER_LOGIN, et/ou CharacterFrame peut etre recree plus tard par le skin
-- custom (SyphrenaPanel ou equivalent) -> une seule tentative a un seul
-- moment ne suffit pas forcement. On reessaie a plusieurs moments distincts
-- jusqu'a ce que ca reussisse (le garde evite de creer le bouton 2 fois).
local buttonCreated = false
local function TryCreateCharacterFrameButton()
    if buttonCreated then return end
    if not CharacterFrame then return end
    local _, _, classId = UnitClass("player")
    if not CLASS_ID_TO_KEY[classId] then return end -- pas encore pret / pas une classe secondaire
    CreateCharacterFrameButton()
    buttonCreated = true
end

local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
initFrame:SetScript("OnEvent", function()
    TryCreateCharacterFrameButton()
end)

-- Filet de securite final : si CharacterFrame existe deja, on retente aussi
-- a chaque ouverture de la fenetre de personnage (sans cout si deja cree).
if CharacterFrame then
    CharacterFrame:HookScript("OnShow", TryCreateCharacterFrameButton)
end
