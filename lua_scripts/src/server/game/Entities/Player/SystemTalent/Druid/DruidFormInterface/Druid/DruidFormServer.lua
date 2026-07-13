local AIO = AIO or require("AIO")
local DruidHandlers = AIO.AddHandlers("FormDruidspell", {})
local FormDruidPointsLeft = {}
local FormDruidPointsSpend = {}

local BearFormConfig = {
    ["formbear1"] = { displayID = 51122, requiredSpellId = 9634 },
    ["formbear2"] = { displayID = 51123, requiredSpellId = 9634 },
    ["formbear3"] = { displayID = 51124, requiredSpellId = 9634 },
    ["formbear4"] = { displayID = 51125, requiredSpellId = 9634 },
    ["formbear5"] = { displayID = 51126, requiredSpellId = 9634 },
    ["formbear6"] = { displayID = 51127, requiredSpellId = 9634 },
    ["formbear7"] = { displayID = 51128, requiredSpellId = 9634 },
    ["formbear8"] = { displayID = 51130, requiredSpellId = 9634 },
    ["formbear9"] = { displayID = 51131, requiredSpellId = 9634 },
    ["formbear10"] = { displayID = 51132, requiredSpellId = 9634 },
    ["formbear11"] = { displayID = 51134, requiredSpellId = 9634 },
    ["formbear12"] = { displayID = 51135, requiredSpellId = 9634 },
    ["formbear13"] = { displayID = 51136, requiredSpellId = 9634 },
    ["formbear14"] = { displayID = 51129, requiredSpellId = 9634 },
    ["formbear15"] = { displayID = 51133, requiredSpellId = 9634 },
    ["formbear16"] = { displayID = 51137, requiredSpellId = 9634 },
    ["formbear17"] = { displayID = 51138, requiredSpellId = 9634 },
    ["formbear18"] = { displayID = 51139, requiredSpellId = 9634 },
    ["formbear19"] = { displayID = 51140, requiredSpellId = 9634 },
    ["formbear20"] = { displayID = 51141, requiredSpellId = 9634 },
    ["formbear21"] = { displayID = 51142, requiredSpellId = 9634 },
    ["formbear22"] = { displayID = 51143, requiredSpellId = 9634 },
    ["formbear23"] = { displayID = 51144, requiredSpellId = 9634 },
    ["formbear24"] = { displayID = 51145, requiredSpellId = 9634 },
    ["formbear25"] = { displayID = 51146, requiredSpellId = 9634 },
    ["formbear26"] = { displayID = 51147, requiredSpellId = 9634 },
    ["formbear27"] = { displayID = 51148, requiredSpellId = 9634 },
    ["formbear28"] = { displayID = 51149, requiredSpellId = 9634 },
    ["formbear29"] = { displayID = 51121, requiredSpellId = 9634 },
    ["formbear30"] = { displayID = 51151, requiredSpellId = 9634 },
    ["formbear31"] = { displayID = 51152, requiredSpellId = 9634 },
    ["formbear32"] = { displayID = 51153, requiredSpellId = 9634 }
}

local CatFormConfig = {
    ["formcat1"] = { displayID = 51154, requiredSpellId = 768 },
    ["formcat2"] = { displayID = 51155, requiredSpellId = 768 },
    ["formcat3"] = { displayID = 51156, requiredSpellId = 768 },
    ["formcat4"] = { displayID = 51157, requiredSpellId = 768 },
    ["formcat5"] = { displayID = 51158, requiredSpellId = 768 },
    ["formcat6"] = { displayID = 51159, requiredSpellId = 768 },
    ["formcat7"] = { displayID = 51160, requiredSpellId = 768 },
    ["formcat8"] = { displayID = 51161, requiredSpellId = 768 },
    ["formcat9"] = { displayID = 51162, requiredSpellId = 768 },
    ["formcat10"] = { displayID = 51163, requiredSpellId = 768 },
    ["formcat11"] = { displayID = 51164, requiredSpellId = 768 },
    ["formcat12"] = { displayID = 51165, requiredSpellId = 768 },
    ["formcat13"] = { displayID = 51166, requiredSpellId = 768 },
    ["formcat14"] = { displayID = 51167, requiredSpellId = 768 },
    ["formcat15"] = { displayID = 51168, requiredSpellId = 768 },
    ["formcat16"] = { displayID = 51169, requiredSpellId = 783 },
    ["formcat17"] = { displayID = 51170, requiredSpellId = 783 },
    ["formcat18"] = { displayID = 51171, requiredSpellId = 783 },
    ["formcat19"] = { displayID = 51172, requiredSpellId = 783 },
    ["formcat20"] = { displayID = 51173, requiredSpellId = 783 },
    ["formcat21"] = { displayID = 51174, requiredSpellId = 783 },
    ["formcat22"] = { displayID = 51175, requiredSpellId = 783 },
    ["formcat23"] = { displayID = 51176, requiredSpellId = 783 },
    ["formcat24"] = { displayID = 51177, requiredSpellId = 783 },
    ["formcat25"] = { displayID = 51178, requiredSpellId = 783 },
    ["formcat26"] = { displayID = 51179, requiredSpellId = 783 },
    ["formcat27"] = { displayID = 51180, requiredSpellId = 783 },
    ["formcat28"] = { displayID = 51181, requiredSpellId = 783 },
    ["formcat29"] = { displayID = 51182, requiredSpellId = 783 }
}

local forms = {
    ["formbear1"] = BearFormConfig["formbear1"],
    ["formbear2"] = BearFormConfig["formbear2"],
    ["formbear3"] = BearFormConfig["formbear3"],
    ["formbear4"] = BearFormConfig["formbear4"],
    ["formbear5"] = BearFormConfig["formbear5"],
    ["formbear6"] = BearFormConfig["formbear6"],
    ["formbear7"] = BearFormConfig["formbear7"],
    ["formbear8"] = BearFormConfig["formbear8"],
    ["formbear9"] = BearFormConfig["formbear9"],
    ["formbear10"] = BearFormConfig["formbear10"],
    ["formbear11"] = BearFormConfig["formbear11"],
    ["formbear12"] = BearFormConfig["formbear12"],
    ["formbear13"] = BearFormConfig["formbear13"],
    ["formbear14"] = BearFormConfig["formbear14"],
    ["formbear15"] = BearFormConfig["formbear15"],
    ["formbear16"] = BearFormConfig["formbear16"],
    ["formbear17"] = BearFormConfig["formbear17"],
    ["formbear18"] = BearFormConfig["formbear18"],
    ["formbear19"] = BearFormConfig["formbear19"],
    ["formbear20"] = BearFormConfig["formbear20"],
    ["formbear21"] = BearFormConfig["formbear21"],
    ["formbear22"] = BearFormConfig["formbear22"],
    ["formbear23"] = BearFormConfig["formbear23"],
    ["formbear24"] = BearFormConfig["formbear24"],
    ["formbear25"] = BearFormConfig["formbear25"],
    ["formbear26"] = BearFormConfig["formbear26"],
    ["formbear27"] = BearFormConfig["formbear27"],
    ["formbear28"] = BearFormConfig["formbear28"],
    ["formbear29"] = BearFormConfig["formbear29"],
    ["formbear30"] = BearFormConfig["formbear30"],
    ["formbear31"] = BearFormConfig["formbear31"],
    ["formbear32"] = BearFormConfig["formbear32"],

    ["formcat1"] = CatFormConfig["formcat1"],
    ["formcat2"] = CatFormConfig["formcat2"],
    ["formcat3"] = CatFormConfig["formcat3"],
    ["formcat4"] = CatFormConfig["formcat4"],
    ["formcat5"] = CatFormConfig["formcat5"],
    ["formcat6"] = CatFormConfig["formcat6"],
    ["formcat7"] = CatFormConfig["formcat7"],
    ["formcat8"] = CatFormConfig["formcat8"],
    ["formcat9"] = CatFormConfig["formcat9"],
    ["formcat10"] = CatFormConfig["formcat10"],
    ["formcat11"] = CatFormConfig["formcat11"],
    ["formcat12"] = CatFormConfig["formcat12"],
    ["formcat13"] = CatFormConfig["formcat13"],
    ["formcat14"] = CatFormConfig["formcat14"],
    ["formcat15"] = CatFormConfig["formcat15"],
    ["formcat16"] = CatFormConfig["formcat16"],
    ["formcat17"] = CatFormConfig["formcat17"],
    ["formcat18"] = CatFormConfig["formcat18"],
    ["formcat19"] = CatFormConfig["formcat19"],
    ["formcat20"] = CatFormConfig["formcat20"],
    ["formcat21"] = CatFormConfig["formcat21"],
    ["formcat22"] = CatFormConfig["formcat22"],
    ["formcat23"] = CatFormConfig["formcat23"],
    ["formcat24"] = CatFormConfig["formcat24"],
    ["formcat25"] = CatFormConfig["formcat25"],
    ["formcat26"] = CatFormConfig["formcat26"],
    ["formcat27"] = CatFormConfig["formcat27"],
    ["formcat28"] = CatFormConfig["formcat28"],
    ["formcat29"] = CatFormConfig["formcat29"]
}

local function MorphForm(player, form)
    local displayID = form.displayID
    local requiredSpellId = form.requiredSpellId
	
	if not player:HasSpell(requiredSpellId) then
        player:SendAreaTriggerMessage("Vous devez avoir le sort requis pour vous morpher !")
        return
    end

    if player:IsInCombat() then
        player:SendAreaTriggerMessage("Vous ne pouvez pas faire cela en combattant !")
        return
    end

    -- Vérifier si le joueur a déjà le displayID requis (éviter de morpher inutilement)
    if player:GetDisplayId() ~= displayID then
        -- Lancer le sort requis pour entrer dans la forme de druide normale
        player:CastSpell(player, requiredSpellId, true)
        -- Changer le displayID du joueur
        player:SetDisplayId(displayID)
    end
end

for formName, formData in pairs(forms) do
    DruidHandlers[formName] = function(player)
        MorphForm(player, formData)
    end
end

local function FormDruidOnCommand(event, player, command)
    if command == "FormDruid" then
        AIO.Handle(player, "FormDruidspell", "ShowFormDruid")
        return false
    end
end
RegisterPlayerEvent(42, FormDruidOnCommand)