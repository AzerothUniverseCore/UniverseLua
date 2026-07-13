--[[##
##
## ███╗   ██╗███████╗██╗  ██╗██╗   ██╗██████╗ ███████╗███╗   ██╗
## ████╗  ██║██╔════╝██║  ██║╚██╗ ██╔╝██╔══██╗██╔════╝████╗  ██║
## ██╔██╗ ██║█████╗  ███████║ ╚████╔╝ ██████╔╝█████╗  ██╔██╗ ██║
## ██║╚██╗██║██╔══╝  ██╔══██║  ╚██╔╝  ██╔══██╗██╔══╝  ██║╚██╗██║
## ██║ ╚████║███████╗██║  ██║   ██║   ██║  ██║███████╗██║ ╚████║
## ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝
##
## -| Author     	   |- Nehyren
## -| Support EdenCore |- https://github.com/SyphrenaCore/EdenCore
## -| Website EdenCore |- http://dream-eden.eu
## -| Discord     	   |- https://discord.com/invite/THwU2e6ZbX
##
##]]--



--[[ Verification Modules Active ]]--
require('modules_active');
if (Script.Mod_AdminCreateModule == 1) then

	--[[

		DEBUT DU SCRIPT

	]]--

		--[[

		 Flags pour les modes

		]]--
			local creation_mod = 0;
			local modification_mod = 1;
			local suppression_mod = 2;

		--[[

			Stockage du mode en cours dans un Tableau

		]]--
			local player_mode = {};

		--[[

			Stockage des données utilisés

		]]--
			local cData = {};
			local cStatsData = {};
			local gData = {};
			local iData = {};
			local qData = {};

		--[[

			Génération des données
				cData || cStatsData

			Suppresion des données
				cData ||

			Scripts Divers

			Insertion des données
				cData || cStatsData

		]]--

			--[[

				Generation des cStatsData's

			]]--
				local function cStatsDataGeneration(player, pGuid, cEntry, cLevel)

					local cStatsQuery = WorldDBQuery("SELECT HealthModifier, ManaModifier, DamageModifier, BaseAttackTime, RangeAttackTime, ArmorModifier, minlevel, maxlevel, speed_walk, speed_run FROM creature_template WHERE entry = "..cEntry..";");

					cStatsData[pGuid] = {
						entry = cEntry,
						HealthModifier = cStatsQuery:GetFloat(0) or 1, ManaModifier = cStatsQuery:GetFloat(1) or 1,
						DamageModifier = cStatsQuery:GetFloat(2) or 1, BaseAttackTime = cStatsQuery:GetUInt32(3) or 2000, RangeAttackTime = cStatsQuery:GetUInt32(4) or 2000,
						ArmorModifier = cStatsQuery:GetFloat(5) or 1,
						minlevel = cStatsQuery:GetUInt32(6) or 80, maxlevel = cStatsQuery:GetUInt32(7) or 80,
						speed_walk = cStatsQuery:GetFloat(8) or 0.95, speed_run = cStatsQuery:GetFloat(9) or 0.95,
						current_level = cLevel;
					};
				end

			--[[

				Generation des cData's

			]]--
				local function cDataGeneration(player, pGuid, cEntry)
					local cDataQuery = WorldDBQuery("SELECT modelid1, modelid2, modelid3, modelid4, faction, gossip_menu_id, npcflag, rank, minlevel, maxlevel, scale, unit_class, family, type, AIName FROM creature_template WHERE entry = "..cEntry..";");
					local cDataQueryName = WorldDBQuery("SELECT NAME, title FROM `creature_template_locale` WHERE locale = 'frFR' AND entry = "..cEntry..";");
					cData[pGuid] = {
						entry = cEntry,
						modelid1 = cDataQuery:GetUInt32(0) or 0, modelid2 = cDataQuery:GetUInt32(1) or 0, modelid3 = cDataQuery:GetUInt32(2) or 0, modelid4 = cDataQuery:GetUInt32(3) or 0,
						name = cDataQueryName:GetString(0) or '', subname = cDataQueryName:GetString(1) or '',
						faction = cDataQuery:GetUInt32(4) or 35, gossip = cDataQuery:GetUInt32(5) or 0, npcflag = cDataQuery:GetUInt32(6) or 0, rank = cDataQuery:GetUInt32(7) or 0,
						minlvl = cDataQuery:GetUInt32(8) or 0, maxlvl = cDataQuery:GetUInt32(9) or 0,
						scale = cDataQuery:GetUInt32(10) or 1, unitclass = cDataQuery:GetUInt32(11) or 1, family = cDataQuery:GetUInt32(12) or 7, type = cDataQuery:GetUInt32(13) or 0,
						ainame = cDataQuery:GetString(14) or 'SmartAI';
					};
					return true;
				end

			--[[

				Suppression des cData's

			]]--
				local function DeleteCreatureData(pGuid, force)

					-- Remise à 0 des données stockés dans le tableau
					if (not(cData[pGuid]) or force == true) then
						cData[pGuid] = {
							entry = -1,
							modelid1 = 0, modelid2 = 0, modelid3 = 0, modelid4 = 0,
							name = 'Nouvelle Créature', subname = '',
							faction = 35, gossip = 0, npcflag = 0, rank = 0,
							minlvl = 1, maxlvl = 1,
							scale = 1, unitclass = 1, family = 7, type = 0,
							ainame = 'SmartAI';
						};
					end
				end

			--[[

				Scripts Divers

			]]--

				--[[

					Conversion des models <-> DressNPC

				]]--
					local function modelDressNpcConvert(negativeModelID, pGuid)
						if (negativeModelID.modelid1) then
							cData[pGuid].modelid1 = -cData[pGuid].modelid1;
						end
						if (negativeModelID.modelid2) then
							cData[pGuid].modelid2 = -cData[pGuid].modelid2;
						end
						if (negativeModelID.modelid3) then
							cData[pGuid].modelid3 = -cData[pGuid].modelid3;
						end
						if (negativeModelID.modelid4) then
							cData[pGuid].modelid4 = -cData[pGuid].modelid4;
						end
					end

				--[[

					Scripts de recherche de validités des models

				]]--
					local function CheckModel(modelid, negative, pGuid)
						if (negative == true) then
							local modelid = (-modelid);
							local getDressModel = WorldDBQuery('SELECT entry FROM creature_template_outfits WHERE entry = '..modelid..';');
							if (getDressModel) then
								return true;
							else
								return false;
							end
						elseif (negative == false) then
							local getModel = WorldDBQuery('SELECT displayid FROM creature_model_info WHERE displayid = '..modelid..';');
							if (getModel) then
								return true;
							else
								return false;
							end
						end
					end

				--[[

					Vérification des droits

				]]--
					local function ifAuthorized(player)
						local pRank = player:GetGMRank();
						-- Seul les comptes de niveau 3
						if (pRank == 3) then
							return true;
						end

						-- Sinon on vérifie si le joueur à un accés special
						local pAccId = player:GetAccountId();
						local getAuthorization = AuthDBQuery('SELECT acm FROM auc_eluna.mod_account_ranks WHERE account_id = '..pAccId..';');
						if (getAuthorization ~= nil) then
							return true;
						end
					end

			--[[

				Insertion des cData's

			]]--
				local function creationCreature(player, pGuid)

					-- Gestion des modèles négatif, on les stocks et on les restaure après notre requête SQL
					local negativeModelID = {
						modelid1 = cData[pGuid].modelid1 < 0,
						modelid2 = cData[pGuid].modelid2 < 0,
						modelid3 = cData[pGuid].modelid3 < 0,
						modelid4 = cData[pGuid].modelid4 < 0;};

					local selectCreature = 0;
					if (cData[pGuid].entry < 0 or player_mode[pGuid].active_mode == creation_mod) then
						selectCreature = WorldDBQuery('SELECT MAX(entry)+1 FROM creature_template;'):GetUInt32(0);
					else
						selectCreature = cData[pGuid].entry;
					end

					modelDressNpcConvert(negativeModelID, pGuid);

					WorldDBQuery([[
						REPLACE INTO creature_template
						(entry,
						modelid1,
						modelid2,
						modelid3,
						modelid4,
						name,
						subname,
						faction,
						gossip_menu_id,
						minlevel,
						maxlevel,
						scale,
						npcflag,
						rank,
						unit_class,
						family,
						type,
						AIName)
						VALUES
						("]]..selectCreature..[[",
						"]]..cData[pGuid].modelid1..[[",
						"]]..cData[pGuid].modelid2..[[",
						"]]..cData[pGuid].modelid3..[[",
						"]]..cData[pGuid].modelid4..[[",
						"]]..cData[pGuid].name..[[",
						"]]..cData[pGuid].subname..[[",
						"]]..cData[pGuid].faction..[[",
						"]]..cData[pGuid].gossip..[[",
						"]]..cData[pGuid].minlvl..[[",
						"]]..cData[pGuid].maxlvl..[[",
						"]]..cData[pGuid].scale..[[",
						"]]..cData[pGuid].npcflag..[[",
						"]]..cData[pGuid].rank..[[",
						"]]..cData[pGuid].unitclass..[[",
						"]]..cData[pGuid].family..[[",
						"]]..cData[pGuid].type..[[",
						"]]..cData[pGuid].ainame..[[");]]);

					WorldDBQuery([[REPLACE INTO creature_template_locale (entry, locale, name, title) VALUES ("]]..selectCreature..[[", "frFR", "]]..cData[pGuid].name..[[", "]]..cData[pGuid].subname..[[");]]);
					modelDressNpcConvert(negativeModelID, pGuid);

					if (player_mode[pGuid].active_mode == creation_mod) then
						player:SendBroadcastMessage("Vous venez de créer une créature nommée \""..cData[pGuid].name.."\" avec pour entry #"..selectCreature..".");
						DeleteCreatureData(pGuid, true);
					elseif (player_mode[pGuid].active_mode == modification_mod)then
						player:SendBroadcastMessage("Vous venez de modifier la créature nommée \""..cData[pGuid].name.."\" avec pour entry #"..selectCreature..".")
						DeleteCreatureData(pGuid, true);
					end
				end

			--[[

				Insertion des cStatsData's

			]]--
				local function updateCreature(player, pGuid)
					WorldDBQuery([[
			     UPDATE creature_template SET
			     HealthModifier = "]]..cStatsData[pGuid].HealthModifier..[[",
			     ManaModifier = "]]..cStatsData[pGuid].ManaModifier..[[",
			     DamageModifier = "]]..cStatsData[pGuid].DamageModifier..[[",
			     BaseAttackTime = "]]..cStatsData[pGuid].BaseAttackTime..[[",
			     RangeAttackTime = "]]..cStatsData[pGuid].RangeAttackTime..[[",
			     ArmorModifier = "]]..cStatsData[pGuid].ArmorModifier..[[",
			     minlevel = "]]..cStatsData[pGuid].minlevel..[[",
			     maxlevel = "]]..cStatsData[pGuid].maxlevel..[[",
			     speed_walk = "]]..cStatsData[pGuid].speed_walk..[[",
			     speed_run = "]]..cStatsData[pGuid].speed_run..[[" WHERE entry = ]]..cStatsData[pGuid].entry..[[;]]);

					 local cName = WorldDBQuery("SELECT NAME, title FROM `creature_template_locale` WHERE locale = 'frFR' AND entry = "..cStatsData[pGuid].entry..";"):GetString(0);

					player:SendBroadcastMessage("Vous venez d'équilibrer la creature nommée \""..cName.."\" avec pour entry #"..cStatsData[pGuid].entry..".")
				end

		--[[

			DEBUT || Menu des Créations

		]]--
			local function creationMenu(event, player, object)
				player:GossipClearMenu();
				player:GossipSetText("Panel de création\n");

				player:GossipMenuAddItem(2, "Créer un NPC", 1, 150);
				player:GossipMenuAddItem(2, "Créer un GameObject", 1, 200);
				player:GossipMenuAddItem(2, "Créer un Item", 1, 250);
				player:GossipMenuAddItem(2, "Créer une Quête", 1, 300);
				player:GossipMenuAddItem(9, "-------------------", 1, 100);
				player:GossipMenuAddItem(2, "<- retour <-", 1, 99);

				player:GossipSendMenu(0x7FFFFFFF, object, 111);
			end

			--[[

				Menu de Création -> Creature

			]]--
				local function creationMenuCreature(event, player, object)
					local pGuid = player:GetGUIDLow();
					DeleteCreatureData(pGuid);

					player:GossipClearMenu();

					if (player_mode[pGuid].active_mode == creation_mod) then
						player:GossipSetText('Création -> Creature\n');
						buttonText = 'Créer ma créature';
					elseif (player_mode[pGuid].active_mode == modification_mod) then
						player:GossipSetText('Création -> Creature\nEntry: '..cData[pGuid].entry);
						buttonText = 'Modifier ma créature';
					end

						player:GossipMenuAddItem(4, "Name : "..cData[pGuid].name.."", 1, 151, true);
						player:GossipMenuAddItem(4, "Subname : "..cData[pGuid].subname.."", 1, 152, true);
						player:GossipMenuAddItem(4, "ModelID1 : "..cData[pGuid].modelid1.."", 1, 153, true);
						player:GossipMenuAddItem(4, "ModelID2 : "..cData[pGuid].modelid2.."", 1, 154, true);
						player:GossipMenuAddItem(4, "ModelID3 : "..cData[pGuid].modelid3.."", 1, 155, true);
						player:GossipMenuAddItem(4, "ModelID4 : "..cData[pGuid].modelid4.."", 1, 156, true);
						player:GossipMenuAddItem(4, "Faction : "..cData[pGuid].faction.."", 1, 157, true);
						player:GossipMenuAddItem(4, "GossipMenuId : "..cData[pGuid].gossip.."", 1, 158, true);
						player:GossipMenuAddItem(4, "MinLevel : "..cData[pGuid].minlvl.."", 1, 159, true);
						player:GossipMenuAddItem(4, "MaxLevel : "..cData[pGuid].maxlvl.."", 1, 160, true);
						player:GossipMenuAddItem(4, "Scale : "..cData[pGuid].scale.."", 1, 161, true);
						player:GossipMenuAddItem(4, "NpcFlag : "..cData[pGuid].npcflag.."", 1, 162, true);
						player:GossipMenuAddItem(4, "Rank : "..cData[pGuid].rank.."", 1, 163, true);
						player:GossipMenuAddItem(4, "Unit_Class : "..cData[pGuid].unitclass.."", 1, 164, true);
						player:GossipMenuAddItem(4, "Family : "..cData[pGuid].family.."", 1, 165, true);
						player:GossipMenuAddItem(4, "Type : "..cData[pGuid].type.."", 1, 166, true);
						player:GossipMenuAddItem(4, "AiName : "..cData[pGuid].ainame.."", 1, 167, true);
						player:GossipMenuAddItem(9, "-------------------", 1, 150);
						player:GossipMenuAddItem(6, ""..buttonText.."", 1, 180, false, "Êtes vous sûr ?");
						player:GossipMenuAddItem(9, "-------------------", 1, 150);
				  	player:GossipMenuAddItem(2, "<- retour <-", 1, 110);
				  	player:GossipSendMenu(0x7FFFFFFF, object, 111);
			  end

				local function creationTableCreature(event, player, object, sender, intid, code, menuid)

					local checkCodeNumber = tonumber(code);

					if (intid >= 153 and intid <= 166)then
						if (checkCodeNumber == nil) then
							player:SendBroadcastMessage('Nombre entré invalide!');
							creationMenuCreature(event, player, object);
							return nil;
						end
					end

					local pGuid = player:GetGUIDLow();

					if (intid == 151) then -- Name
						cData[pGuid].name = code;
					elseif (intid == 152) then --Subname
						cData[pGuid].subname = code;
					elseif (intid == 153) then --ModelID1
						if (checkCodeNumber <= 0 )then
							player:DeMorph();
							if (CheckModel(checkCodeNumber, true) == true) then
								cData[pGuid].modelid1 = checkCodeNumber;
							else
								player:SendBroadcastMessage("Le model entré n'existe pas");
							end
						else
							if (CheckModel(checkCodeNumber, false) == true) then
								cData[pGuid].modelid1 = checkCodeNumber;
								player:SetDisplayId(checkCodeNumber);
							else
								player:SendBroadcastMessage("Le model entré n'existe pas");
							end
						end
					elseif (intid == 154) then --ModelID2
						if (checkCodeNumber <= 0 )then
							player:DeMorph();
							if (CheckModel(checkCodeNumber, true) == true) then
								cData[pGuid].modelid2 = checkCodeNumber;
							else
								player:SendBroadcastMessage("Le model entré n'existe pas");
							end
						else
							if (CheckModel(checkCodeNumber, false) == true) then
								cData[pGuid].modelid2 = checkCodeNumber;
								player:SetDisplayId(checkCodeNumber);
							else
								player:SendBroadcastMessage("Le model entré n'existe pas");
							end
						end
					elseif (intid == 155) then --ModelID3
						if (checkCodeNumber <= 0 )then
							player:DeMorph();
							if (CheckModel(checkCodeNumber, true) == true) then
								cData[pGuid].modelid3 = checkCodeNumber;
							else
								player:SendBroadcastMessage("Le model entré n'existe pas");
							end
						else
							if (CheckModel(checkCodeNumber, false) == true) then
								cData[pGuid].modelid3 = checkCodeNumber;
								player:SetDisplayId(checkCodeNumber);
							else
								player:SendBroadcastMessage("Le model entré n'existe pas");
							end
						end
					elseif (intid == 156) then --ModelID4
						if (checkCodeNumber <= 0 )then
							player:DeMorph();
							if (CheckModel(checkCodeNumber, true) == true) then
								cData[pGuid].modelid4 = checkCodeNumber;
							else
								player:SendBroadcastMessage("Le model entré n'existe pas");
							end
						else
							if (CheckModel(checkCodeNumber, false) == true) then
								cData[pGuid].modelid4 = checkCodeNumber;
								player:SetDisplayId(checkCodeNumber);
							else
								player:SendBroadcastMessage("Le model entré n'existe pas");
							end
						end
					elseif (intid == 157) then --Faction
						cData[pGuid].faction = checkCodeNumber;
					elseif (intid == 158) then --GossipMenuId
						cData[pGuid].gossip = checkCodeNumber;
					elseif (intid == 159) then --MinLevel
						cData[pGuid].minlvl = checkCodeNumber;
					elseif (intid == 160) then --MaxLevel
						cData[pGuid].maxlvl = checkCodeNumber;
					elseif (intid == 161) then --Scale
						cData[pGuid].scale = checkCodeNumber;
						player:SetScale(checkCodeNumber);
					elseif (intid == 162) then --MaxLevel
						cData[pGuid].npcflag = checkCodeNumber;
					elseif (intid == 163) then --Rank
						cData[pGuid].rank = checkCodeNumber;
					elseif (intid == 164) then --Unit_Class
						cData[pGuid].unitclass = checkCodeNumber;
					elseif (intid == 165) then --Family
						cData[pGuid].family = checkCodeNumber;
					elseif (intid == 166) then --Type
						cData[pGuid].type = checkCodeNumber;
					elseif (intid == 167) then --AiName
						cData[pGuid].ainame = checkCodeNumber;
					elseif (intid == 180) then -- Creation de la Créature
						creationCreature(player, pGuid);
						player:SetScale(1);
						player:DeMorph();
					end
					creationMenuCreature(event, player, object)
				end

			--[[

				Menu de Création -> GameObject

			]]--
				local function creationMenuGameObject(event, player, object)
					-- ToDo
				end

				local function creationTableGameObject(event, player, object)
					-- ToDo
				end

			--[[

				Menu de Création -> Item

			]]--
				local function creationMenuItem(event, player, object)
					-- ToDo
				end

				local function creationTableItem(event, player, object)
					-- ToDo
				end

			--[[

				Menu de Création -> Quête

			]]--
				local function creationMenuQuest(event, player, object)
					-- ToDo
				end

				local function creationTableQuest(event, player, object)
					-- ToDo
				end

		--[[

			DEBUT || Menu des Modifications

		]]--

			--[[

				Menu des modifications

			]]--
				local function modificationMenu(event, player, object)
					player:GossipClearMenu()
					player:GossipSetText("Panel de modification\n")

					player:GossipMenuAddItem(2, "Modifier un NPC", 1, 500, true)
					player:GossipMenuAddItem(2, "Modifier un GameObject", 1, 501, true)
					player:GossipMenuAddItem(2, "Modifier un Item", 1, 502)
					player:GossipMenuAddItem(2, "Modifier une Quête", 1, 503)
					player:GossipMenuAddItem(9, "-------------------", 1, 101)
					player:GossipMenuAddItem(2, "Modifier le NPC sélectionné", 1, 505)
					player:GossipMenuAddItem(2, "Equilibrer le NPC sélectionné", 1, 550)
					player:GossipMenuAddItem(9, "-------------------", 1, 101)
					player:GossipMenuAddItem(2, "<- retour <-", 1, 99)
					player:GossipSendMenu(0x7FFFFFFF, object, 111)
				end

		--[[

			DEBUT || Menu des Modifications

		]]--

			--[[

				Menu des Stats

			]]--
				local function statsMenu(event, player, object)

					local pGuid = player:GetGUIDLow();

					local getCreatureInfo = WorldDBQuery("SELECT unit_class, exp FROM creature_template WHERE entry ="..cStatsData[pGuid].entry..";");
					local creatureClass = getCreatureInfo:GetUInt32(0);
					local creature_exp = getCreatureInfo:GetUInt32(1);

					local getCreatureBase = WorldDBQuery("SELECT basehp0, basehp1, basehp2, basemana FROM creature_classlevelstats WHERE class ="..creatureClass.." AND level = "..cStatsData[pGuid].current_level..";");

					local creatureHealth = cStatsData[pGuid].HealthModifier;
					local creatureMana = cStatsData[pGuid].ManaModifier;
					if (getCreatureBase ~= nil)then
						creatureHealth = cStatsData[pGuid].HealthModifier * getCreatureBase:GetUInt32(creature_exp);
						creatureMana = cStatsData[pGuid].ManaModifier * getCreatureBase:GetUInt32(3);
					end

					local creatureHealthLabel = '';
					local creatureManaLabel = '';

					if (creatureHealth < 100000) then
				    creatureHealthLabel = ""..creatureHealth;
				  elseif (creatureHealth >= 100000 and creatureHealth < 100000000) then
				    creatureHealth = creatureHealth / 1000;
				    creatureHealthLabel = creatureHealth.."k";
				  else
				    creatureHealth = creatureHealth / 1000000;
				    creatureHealthLabel = creatureHealth.."m";
				  end

				  if (creatureMana < 100000) then
				    creatureManaLabel = ""..creatureMana;
				  elseif (creatureMana >= 100000 and creatureMana < 100000000) then
				    creatureMana = creatureMana / 1000;
				    creatureManaLabel = creatureMana.."k";
				  else
				    creatureMana = creatureMana / 1000000;
				    creatureManaLabel = creatureMana.."m";
				  end

					player:GossipClearMenu()

					local cName = WorldDBQuery("SELECT NAME, title FROM `creature_template_locale` WHERE locale = 'frFR' AND entry = "..cStatsData[pGuid].entry..";"):GetString(0);
					player:GossipSetText("Modification => Equilibrage NPC\nName: "..cName.."\nEntry: "..cStatsData[pGuid].entry);

					player:GossipMenuAddItem(4, "Health Modifier: "..cStatsData[pGuid].HealthModifier.." ("..creatureHealthLabel..")", 1, 551, true);
				  player:GossipMenuAddItem(4, "Mana Modifier: "..cStatsData[pGuid].ManaModifier.." ("..creatureManaLabel..")", 1, 552, true);
				  player:GossipMenuAddItem(4, "Damage Modifier : "..cStatsData[pGuid].DamageModifier.."", 1, 553, true);
				  player:GossipMenuAddItem(4, "Base Attack Time : "..cStatsData[pGuid].BaseAttackTime.."", 1, 554, true);
				  player:GossipMenuAddItem(4, "Range Attack Time : "..cStatsData[pGuid].RangeAttackTime.."", 1, 555, true);
				  player:GossipMenuAddItem(4, "Armor Modifier : "..cStatsData[pGuid].ArmorModifier.."", 1, 556, true);
				  player:GossipMenuAddItem(4, "Min Level : "..cStatsData[pGuid].minlevel.."", 1, 557, true);
				  player:GossipMenuAddItem(4, "Max Level : "..cStatsData[pGuid].maxlevel.."", 1, 558, true);
				  player:GossipMenuAddItem(4, "Speed Walk : "..cStatsData[pGuid].speed_walk.."", 1, 559, true);
				  player:GossipMenuAddItem(4, "Speed Run : "..cStatsData[pGuid].speed_run.."", 1, 560, true);
				  player:GossipMenuAddItem(9, "-------------------", 1, 550);
				  player:GossipMenuAddItem(6, "Equilibrer créature", 1, 599);
				  player:GossipMenuAddItem(9, "-------------------", 1, 550);
				  player:GossipMenuAddItem(2, "Selectionner une autre créature", 1, 598);
				  player:GossipMenuAddItem(9, "-------------------", 1, 550);
				  player:GossipMenuAddItem(2, "<- retour <-", 1, 101);

				  player:GossipSendMenu(0x7FFFFFFF, object, 111);
				end

				local function statsTableCreature(event, player, object, sender, intid, code, menuid)

					local checkCodeNumber = tonumber(code);

					if (intid < 598 and checkCodeNumber == nil) then
						player:SendBroadcastMessage("Nombre invalide entré");
		     		OpenNPCBalancePanel(event, player, object);
						return false;
					end

					local pGuid = player:GetGUIDLow();
					local getSelection = player:GetSelection();

					if (intid == 551) then
				    cStatsData[pGuid].HealthModifier = checkCodeNumber;
				  elseif (intid == 552) then
				    cStatsData[pGuid].ManaModifier = checkCodeNumber;
				  elseif (intid == 553) then
				    cStatsData[pGuid].DamageModifier = checkCodeNumber;
				  elseif (intid == 554) then
				    cStatsData[pGuid].BaseAttackTime = checkCodeNumber;
				  elseif (intid == 555) then
				    cStatsData[pGuid].RangeAttackTime = checkCodeNumber;
				  elseif (intid == 556) then
				    cStatsData[pGuid].ArmorModifier = checkCodeNumber;
				  elseif (intid == 557) then
				    cStatsData[pGuid].minlevel = checkCodeNumber;
				  elseif (intid == 558) then
				    cStatsData[pGuid].maxlevel = checkCodeNumber;
				  elseif (intid == 559) then
				    cStatsData[pGuid].speed_walk = checkCodeNumber;
				  elseif (intid == 560) then
				    cStatsData[pGuid].speed_run = checkCodeNumber;
				  elseif (intid == 598) then
						if (getSelection == nil or getSelection:GetEntry() == 0) then
				      player:SendBroadcastMessage("Veuillez sélectionner un NPC");
				      statsMenu(event, player, object);
				      return false;
				    end
						cStatsDataGeneration(player, pGuid, player:GetSelection():GetEntry(), player:GetSelection():GetLevel());
					elseif (intid == 599) then
						updateCreature(player, pGuid);
					end
					statsMenu(event, player, object)
				end

		--[[

			Menu Principal

		]]--
			local function mainMenu(event, player, object)
				player:GossipClearMenu();
				player:GossipSetText("Bienvenue sur l'Admin Create Module.")

				player:GossipMenuAddItem(2, "Panel de création", 1, 100);
				player:GossipMenuAddItem(2, "Panel de modification", 1, 101);
				player:GossipMenuAddItem(2, "Panel de suppression", 1, 102);

				player:GossipSendMenu(0x7FFFFFFF, object, 111);
			end

			local function mainMenuSelect(event, player, object, sender, intid, code, menuid)

				local checkCodeNumber = tonumber(code);

				if (intid >= 500 and intid <= 503) then
					if (checkCodeNumber == nil)then
						player:SendBroadcastMessage("Entry invalide entrée");
						modificationMenu(event, player, object);
						return false;
					end
				end

				local pGuid = player:GetGUIDLow();
				local getSelection = player:GetSelection();

				if not (player_mode[pGuid])then
					player_mode[pGuid] = {
						active_mode = -1;
					};
				end

				if (intid == 99) then -- Retour au Menu Principal
					mainMenu(event, player, object);
				elseif (intid == 100) then -- Menu des Créations
					player_mode[pGuid].active_mode = creation_mod;
					creationMenu(event, player, object);
				elseif (intid == 101) then -- Menu des Modifications
					player_mode[pGuid].active_mode = modification_mod;
					modificationMenu(event, player, object);
				elseif (intid == 102) then -- Menu des Suppressions
					player_mode[pGuid].active_mode = suppression_mod;
					suppressionMenu(event, player, object);
				elseif (intid == 110) then -- Bouton retour
					if (player_mode[pGuid].active_mode == creation_mod) then
						mainMenuSelect(event, player, object, sender, 100, code, menuid)
					elseif (player_mode[pGuid].active_mode == modification_mod) then
						mainMenuSelect(event, player, object, sender, 101, code, menuid)
					elseif (player_mode[pGuid].active_mode == suppression_mod) then
						mainMenuSelect(event, player, object, sender, 102, code, menuid)
					end

				-- Creation --
					-- Creature --
					elseif (intid == 150) then
						creationMenuCreature(event, player, object);
					elseif (intid > 150 and intid <= 199) then
						creationTableCreature(event, player, object, sender, intid, code, menuid);

					-- GameObject --
					elseif (intid == 200) then
						creationMenuGameObject(event, player, object);
					elseif (intid > 200 and intid <= 299) then
						creationTableGameObject(event, player, object, sender, intid, code, menuid);

					-- Item --
					elseif (intid == 300) then
						creationMenuItem(event, player, object);
					elseif (intid > 300 and intid <= 399) then
						creationTableItem(event, player, object, sender, intid, code, menuid);

					-- Quête --
					elseif (intid == 400) then
						creationMenuQuest(event, player, object);
					elseif (intid > 400 and intid <= 499) then
						creationTableQuest(event, player, object, sender, intid, code, menuid);

				-- Modification --
				elseif (intid == 500) then
					if (cDataGeneration(player, pGuid, checkCodeNumber) == false)then
						modificationMenu(event, player, object);
						return false;
					end
					creationMenuCreature(event, player, object);

				elseif (intid == 505) then
					if (getSelection == nil or getSelection:GetEntry() == false) then
						player:SendBroadcastMessage('Veuillez sélectionner un NPC');
						modificationMenu(event, player, object);
						return false;
					end
						cDataGeneration(player, pGuid, getSelection:GetEntry());
						creationMenuCreature(event, player, object);

				-- Equilibrage --
				elseif (intid == 550) then
					if (getSelection == nil or getSelection:GetEntry() == false)then
						player:SendBroadcastMessage('Veuillez sélectionner un NPC');
						modificationMenu(event, player, object);
						return false;
					end

					cStatsDataGeneration(player, pGuid, getSelection:GetEntry(), getSelection:GetLevel());
					statsMenu(event, player, object);
				elseif (intid > 550 and intid <= 599) then
					statsTableCreature(event, player, object, sender, intid, code, menuid);

				-- Suppression --
				elseif (intid == 600) then

				end
			end

		--[[

			Commande ACM

		]]--
			local function onCommand(event, player, command)
				if (string.upper(command) == 'ACM') then
					local isAuthorized = ifAuthorized(player);

					if (isAuthorized) then
						mainMenu(event, player, player);
						return false;
					end
				end
			end

		--[[

			RegisterEvent

		]]--
			RegisterPlayerEvent(42, onCommand);
			RegisterPlayerGossipEvent(111, 2, mainMenuSelect);

	--[[

		FIN DU SCRIPT

	]]--
end
