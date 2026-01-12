#pragma semicolon 1
#pragma newdecls required

static int NPCId;

void DungeonLoot_MapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "nothing");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_dungeon_loot");
	strcopy(data.Icon, sizeof(data.Icon), "unknown");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_NORMAL|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPCId = NPC_Add(data);
}

int DungeonLoot_Id()
{
	return NPCId;
}

static void ClotPrecache()
{
	PrecacheModel("models/props_2fort/miningcrate002.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return DungeonLoot(vecPos, data);
}

methodmap DungeonLoot < CClotBody
{
	public void SetLootData(const char[] name, float scale)
	{
		LootInfo loot;
		if(Dungeon_GetNamedLoot(name, loot) && loot.Color[3])
		{
			if(loot.Color[3] != 255)
				SetEntityRenderMode(this.index, RENDER_TRANSCOLOR);
			
			SetEntityRenderColor(this.index, loot.Color[0], loot.Color[1], loot.Color[2], loot.Color[3]);
		}

		strcopy(c_NpcName[this.index], sizeof(c_NpcName[]), name);
		this.m_flAttackHappens_bullshit = scale;
	}

	public DungeonLoot(float vecPos[3], const char[] data)
	{
		float pos[3];
		pos = vecPos;

		float ang[3];
		ang[0] = 0.0;
		ang[1] = float(GetURandomInt() % 360);
		ang[2] = 0.0;

		
		DungeonLoot npc = view_as<DungeonLoot>(CClotBody(pos, ang, "models/props_2fort/miningcrate002.mdl", "1.0", "10", 3, .NpcTypeLogic = STATIONARY_NPC));
		
		if(data[0] && StrContains(data, "notele", false) == -1)
		{
			if(StrContains(data, "randpos", false) == -1)
			{
				Dungeon_TeleportCratesRewards(npc.index, pos);
			}
			else
			{
				Dungeon_TeleportRandomly(pos);
			}
		}

		i_NpcWeight[npc.index] = 999;
		i_NpcIsABuilding[npc.index] = true;
		b_NoKnockbackFromSources[npc.index] = true;
		npc.m_bDissapearOnDeath = true;
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;
		//npc.m_bDoNotGiveWaveDelay = true;

		SetEntPropString(npc.index, Prop_Data, "m_iName", "resource");
		ApplyStatusEffect(npc.index, npc.index, "Clear Head", 999999.0);
		b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true;

		npc.m_flAttackHappens_bullshit = 0.0;
		npc.m_flRangedArmor = 0.0;
		npc.m_bCamo = true;	// For AI attacking resources
		
		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCOnTakeDamage[npc.index] = ClotTakeDamage;
		func_NPCThink[npc.index] = ClotThink;
		AddNpcToAliveList(npc.index, 1);
		
		b_NpcUnableToDie[npc.index] = true;
		b_NoHealthbar[npc.index] = 1;

		if(data[0])
		{
			char buffers[2][48];
			int count = ExplodeString(data, ";", buffers, sizeof(buffers), sizeof(buffers[]));
			npc.SetLootData(buffers[0], count > 1 ? StringToFloat(buffers[1]) : 0.0);
		}

		return npc;
	}
}

static void ClotThink(int entity)
{
	if(!b_StaticNPC[entity])
		f_DelayNextWaveStartAdvancingDeathNpc = GetGameTime() + 1.50;
}

static void ClotTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(!CheckInHud())
	{
		if(b_NpcUnableToDie[victim] && attacker > 0 && attacker <= MaxClients)
		{
			float pos1[3], pos2[3];
			GetEntPropVector(victim, Prop_Data, "m_vecOrigin", pos1);
			GetEntPropVector(attacker, Prop_Data, "m_vecOrigin", pos2);
			if(GetVectorDistance(pos1, pos2, true) < 30000.0)
			{
				damage = (damagetype & DMG_CLUB) ? 5.0 : 1.0;

				if(float(GetEntProp(victim, Prop_Data, "m_iHealth")) <= damage)
				{
					b_NpcUnableToDie[victim] = false;

					Dungeon_AddBattleScale(view_as<CClotBody>(victim).m_flAttackHappens_bullshit);

					if(Dungeon_LootExists(c_NpcName[victim]))
					{
						CPrintToChatAll("%t", "Found Dungeon Loot", c_NpcName[victim]);
						Dungeon_RollNamedLoot(c_NpcName[victim]);
						EmitSoundToAll("ui/itemcrate_smash_rare.wav");
					}
					else
					{
						Rogue_GiveNamedArtifact(c_NpcName[victim]);
					}
				}
			}
			else
			{
				damage = 0.0;
			}
		}
		else if(!(i_HexCustomDamageTypes[victim] & ZR_SLAY_DAMAGE))
		{
			damage = 0.0;
		}
	}
}

static void ClotDeath(int entity)
{
}
