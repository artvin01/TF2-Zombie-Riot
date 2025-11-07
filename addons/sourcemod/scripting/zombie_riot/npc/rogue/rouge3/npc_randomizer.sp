#pragma semicolon 1
#pragma newdecls required

static char g_RandomizerClasses[][] = {
	"", // unknown
	"scout",
	"sniper",
	"soldier",
	"demo",
	"medic",
	"heavy",
	"pyro",
	"spy",
	"engineer",
};

void Randomizer_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Randomizer!");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_randomizer");
	strcopy(data.Icon, sizeof(data.Icon), "unknown");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Mutation;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	// Precache sub-NPCs
	NPC_GetByPlugin("npc_aperture_sentry");
	NPC_GetByPlugin("npc_aperture_dispenser");
	NPC_GetByPlugin("npc_aperture_teleporter");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Randomizer(vecPos, vecAng, team, data);
}

methodmap Randomizer < CClotBody
{
	public Randomizer(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		TFClassType class = view_as<TFClassType>((GetURandomInt() % 9) + 1); // + 1 because of Unknown
		int behavior = 0;
		
		char model[64];
		FormatEx(model, sizeof(model), "models/player/%s.mdl", g_RandomizerClasses[class]);
		
		Randomizer npc = view_as<Randomizer>(CClotBody(vecPos, vecAng, model, "1.0", "5000", ally));
		
		char buffers[3][64];
		ExplodeString(data, ";", buffers, sizeof(buffers), sizeof(buffers[]));
		if (buffers[0][0])
		{
			// force behavior
			behavior = StringToInt(buffers[0]);
		}
		
		if (buffers[1][0])
		{
			// force class
			class = view_as<TFClassType>(StringToInt(buffers[1]));
		}
		
		Randomizer_AdjustClassStats(npc, class);
		Randomizer_SelectBehavior(npc, class, behavior);
		
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Randomizer_OnTakeDamage);
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		npc.StartPathing();
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		return npc;
	}
}

public Action Randomizer_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Randomizer npc = view_as<Randomizer>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void Randomizer_NPCDeath(int entity)
{
	Randomizer npc = view_as<Randomizer>(entity);
	
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}

static void Randomizer_AdjustClassStats(Randomizer npc, TFClassType class)
{
	float maxHealthMultiplier = 1.0;
	switch (class)
	{
		case TFClass_Scout:
		{
			npc.m_flSpeed = 300.0;
			maxHealthMultiplier = 0.9;
		}
		
		case TFClass_Soldier:
		{
			npc.m_flSpeed = 250.0;
			maxHealthMultiplier = 1.07;
		}
		
		case TFClass_Heavy:
		{
			npc.m_flSpeed = 230.0;
			maxHealthMultiplier = 1.15;
		}
		
		case TFClass_Engineer, TFClass_Sniper, TFClass_Spy:
		{
			npc.m_flSpeed = 280.0;
			maxHealthMultiplier = 0.95;
		}
		
		case TFClass_Pyro, TFClass_DemoMan, TFClass_Medic:
		{
			npc.m_flSpeed = 270.0;
			maxHealthMultiplier = 1.0;
		}
	}
	
	SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", RoundToNearest(ReturnEntityMaxHealth(npc.index) * maxHealthMultiplier));
}

static void Randomizer_SelectBehavior(Randomizer npc, TFClassType class, int forceBehavior = -1)
{
	int id = forceBehavior > 0 ? forceBehavior : (GetURandomInt() % 18) + 1; // +1 because 0 is used as "don't force"
	int activity;
	
	switch (id)
	{
		case 1:
		{
			// Force-A-Nature
			func_NPCThink[npc.index] = view_as<Function>(ApertureRepulsorPerfected_ClotThink);
			func_NPCDeath[npc.index] = view_as<Function>(ApertureRepulsorPerfected_NPCDeath);
			
			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_double_barrel.mdl");
			activity = npc.LookupActivity("ACT_MP_RUN_ITEM2");
		}
		case 2:
		{
			int soldierCase = GetURandomInt() % 4;
			
			if (soldierCase == 0)
			{
				// Pro Soldier
				func_NPCThink[npc.index] = view_as<Function>(SoldinusIlus_ClotThink);
				func_NPCDeath[npc.index] = view_as<Function>(SoldinusIlus_NPCDeath);
				
				npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_rocketlauncher/c_rocketlauncher.mdl");
				activity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
			}
			else
			{
				// Noob Soldier
				func_NPCThink[npc.index] = view_as<Function>(Soldier_ClotThink);
				func_NPCDeath[npc.index] = view_as<Function>(Soldier_NPCDeath);
				
				npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_rocketlauncher/c_rocketlauncher.mdl");
				activity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
			}
		}
		case 3:
		{
			// Grenade Launcher
			func_NPCThink[npc.index] = view_as<Function>(ApertureDevastatorPerfected_ClotThink);
			func_NPCDeath[npc.index] = view_as<Function>(ApertureDevastatorPerfected_NPCDeath);
			
			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_grenadelauncher/c_grenadelauncher.mdl");
			activity = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
		}
		
		case 4:
		{
			// Sticky Launcher
			func_NPCThink[npc.index] = view_as<Function>(IberiaSeaXploder_ClotThink);
			func_NPCDeath[npc.index] = view_as<Function>(IberiaSeaXploder_NPCDeath);
			
			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_stickybomb_launcher/c_stickybomb_launcher.mdl");
			activity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
		}
		case 5:
		{
			// Demoknight
			func_NPCThink[npc.index] = view_as<Function>(DemoMain_ClotThink);
			func_NPCDeath[npc.index] = view_as<Function>(DemoMain_NPCDeath);
			
			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_targe/c_targe.mdl");
			npc.m_iWearable3 = npc.EquipItem("head", "models/weapons/c_models/c_claymore/c_claymore.mdl");
			
			activity = npc.LookupActivity("ACT_MP_RUN_ITEM1");
		}
		case 6:
		{
			// Miniguns will have different behaviors
			int minigunCase = GetURandomInt() % 4;
			switch (minigunCase)
			{
				case 0:
				{
					// Minigun
					func_NPCThink[npc.index] = view_as<Function>(MinigunAssisa_ClotThink);
					func_NPCDeath[npc.index] = view_as<Function>(MinigunAssisa_NPCDeath);
					
					npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_minigun/c_minigun.mdl");
					npc.m_flSpeed *= 0.57;
				}
				case 1:
				{
					// Natascha
					func_NPCThink[npc.index] = view_as<Function>(ApertureMinigunner_ClotThink);
					func_NPCDeath[npc.index] = view_as<Function>(ApertureMinigunner_NPCDeath);
					
					npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_minigun/c_minigun_natascha.mdl");
					npc.m_flSpeed *= 0.5;
				}
				case 2:
				{
					// Tomislav
					func_NPCThink[npc.index] = view_as<Function>(ApertureMinigunnerV2_ClotThink);
					func_NPCDeath[npc.index] = view_as<Function>(ApertureMinigunnerV2_NPCDeath);
					
					npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_minigun/c_minigun_natascha.mdl");
					npc.m_flSpeed *= 0.57;
				}
				case 3:
				{
					// Brass Beast
					func_NPCThink[npc.index] = view_as<Function>(ApertureMinigunnerPerfected_ClotThink);
					func_NPCDeath[npc.index] = view_as<Function>(ApertureMinigunnerPerfected_NPCDeath);
					
					npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_gatling_gun/c_gatling_gun.mdl");
					npc.m_flSpeed *= 0.4;
				}
			}
			
			activity = npc.LookupActivity("ACT_MP_DEPLOYED_PRIMARY");
		}
		
		case 7:
		{
			// Heavy Shotgun
			func_NPCThink[npc.index] = view_as<Function>(WinterSnoweyGunner_ClotThink);
			func_NPCDeath[npc.index] = view_as<Function>(WinterSnoweyGunner_NPCDeath);
			
			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_shotgun/c_shotgun.mdl");
			activity = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
		}
		
		case 8:
		{
			// Heavy Fists
			func_NPCThink[npc.index] = view_as<Function>(Heavy_ClotThink);
			func_NPCDeath[npc.index] = view_as<Function>(Heavy_NPCDeath);
			
			activity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		}
		case 9:
		{
			// Base Medic
			func_NPCThink[npc.index] = view_as<Function>(HiaRejuvinator_ClotThink);
			func_NPCDeath[npc.index] = view_as<Function>(HiaRejuvinator_NPCDeath);
			
			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_proto_backpack/c_proto_backpack.mdl");
			npc.m_iWearable3 = npc.EquipItem("head", "models/weapons/c_models/c_proto_medigun/c_proto_medigun.mdl");
			
			SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 1);
			SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
				
			activity = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
			
			if (class == TFClass_Medic)
			{
				SetVariantInt(1);
				AcceptEntityInput(npc.index, "SetBodyGroup");
			}
			
			Is_a_Medic[npc.index] = true;
		}
		case 10:
		{
			// Sniper Rifle
			func_NPCThink[npc.index] = view_as<Function>(ApertureSniperPerfected_ClotThink);
			func_NPCDeath[npc.index] = view_as<Function>(ApertureSniperPerfected_NPCDeath);
			
			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_sniperrifle/c_sniperrifle.mdl");
			activity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
		}
		case 11:
		{
			// SMG
			SetEntPropFloat(npc.index, Prop_Data, "m_flElementRes", 0.0, Element_Chaos);
			
			func_NPCThink[npc.index] = view_as<Function>(RifalManu_ClotThink);
			func_NPCDeath[npc.index] = view_as<Function>(RifalManu_NPCDeath);
			
			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_smg/c_smg.mdl");
			activity = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
		}
		case 12:
		{
			// Spy will have different behaviors
			int spyCase = GetURandomInt() % 3;
			switch (spyCase)
			{
				// Facestabber fuck
				case 0:
				{
					func_NPCThink[npc.index] = view_as<Function>(SpyTrickstabber_ClotThink);
					func_NPCDeath[npc.index] = view_as<Function>(SpyTrickstabber_NPCDeath);
					
					npc.m_iWearable2 = npc.EquipItem("head", "models/weapons/c_models/c_knife/c_knife.mdl");
					activity = npc.LookupActivity("ACT_MP_RUN_MELEE");
				}
				
				// CAN use revolver
				case 1:
				{
					func_NPCThink[npc.index] = view_as<Function>(SpyCloaked_ClotThink);
					func_NPCDeath[npc.index] = view_as<Function>(SpyCloaked_NPCDeath);
					
					npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_ambassador/c_ambassador.mdl");
					npc.m_iWearable2 = npc.EquipItem("head", "models/weapons/c_models/c_knife/c_knife.mdl");
					
					SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 1);
					
					activity = npc.LookupActivity("ACT_MP_RUN_MELEE");
				}
				
				// melee -> Revolver combo
				case 2:
				{
					func_NPCThink[npc.index] = view_as<Function>(IberiaKumbai_ClotThink);
					func_NPCDeath[npc.index] = view_as<Function>(IberiaKumbai_NPCDeath);
					
					npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_switchblade/c_switchblade.mdl");
					activity = npc.LookupActivity("ACT_MP_RUN_ITEM1");
				}
			}
		}
		case 13:
		{
			// Flamethrower
			func_NPCThink[npc.index] = view_as<Function>(RandomizerBaseFlamethrower_ClotThink);
			func_NPCDeath[npc.index] = view_as<Function>(RandomizerBaseFlamethrower_NPCDeath);
			
			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_flamethrower/c_flamethrower.mdl");
			
			SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 1);
			
			activity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
		}
		case 14:
		{
			// Huntsman
			func_NPCThink[npc.index] = view_as<Function>(RandomizerBaseHuntsman_ClotThink);
			func_NPCDeath[npc.index] = view_as<Function>(RandomizerBaseHuntsman_NPCDeath);
			
			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_bow/c_bow.mdl");
			activity = npc.LookupActivity("ACT_MP_RUN_ITEM2");
		}
		case 15:
		{
			// Southern Hospitality
			func_NPCThink[npc.index] = view_as<Function>(RandomizerBaseSouthernHospitality_ClotThink);
			func_NPCDeath[npc.index] = view_as<Function>(RandomizerBaseSouthernHospitality_NPCDeath);
			
			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_spikewrench/c_spikewrench.mdl");
			activity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		}
		case 16:
		{
			// Market Gardener
			func_NPCThink[npc.index] = view_as<Function>(WinterAirbornExplorer_ClotThink);
			func_NPCDeath[npc.index] = view_as<Function>(WinterAirbornExplorer_NPCDeath);
			
			npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_market_gardener/c_market_gardener.mdl");
			activity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		}
		case 17:
		{
			// Short Circuit
			func_NPCThink[npc.index] = view_as<Function>(Vulpo_ClotThink);
			func_NPCDeath[npc.index] = view_as<Function>(Vulpo_NPCDeath);
			fl_Extra_Damage[npc.index] *= 0.5;
			npc.m_iWearable1 = npc.EquipItem("head", "models/workshop_partner/weapons/c_models/c_dex_arm/c_dex_arm.mdl");
			activity = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
		}
		case 18:
		{
			// Builder
			func_NPCThink[npc.index] = view_as<Function>(ApertureBuilder_ClotThink);
			func_NPCDeath[npc.index] = view_as<Function>(ApertureBuilder_NPCDeath);
			
			activity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
			
			Is_a_Medic[npc.index] = true;
		}
	}
	
	if (activity > 0)
		npc.StartActivity(activity);
}