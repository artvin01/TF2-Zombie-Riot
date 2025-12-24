#pragma semicolon 1
#pragma newdecls required

void DungeonLoot_MapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "nothing");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_dungeon_loot");
	strcopy(data.Icon, sizeof(data.Icon), "unknown");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_SUPPORT;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheModel("models/props_2fort/miningcrate002.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return DungeonLoot(vecPos, vecAng, data);
}

methodmap DungeonLoot < CClotBody
{
	public void SetLootData(const char[] name, const int color[4])
	{
		if(color[2])
		{
			if(color[2] != 255)
				SetEntityRenderMode(this.index, RENDER_TRANSCOLOR);
			
			SetEntityRenderColor(this.index, color[0], color[1], color[2], color[3]);
		}

		strcopy(c_NpcName[this.index], sizeof(c_NpcName[]), name);
	}

	public DungeonLoot(float vecPos[3], float vecAng[3], const char[] data)
	{
		DungeonLoot npc = view_as<DungeonLoot>(CClotBody(vecPos, vecAng, "models/props_2fort/miningcrate002.mdl", "1.0", "10", 3, .NpcTypeLogic = STATIONARY_NPC));
		
		i_NpcWeight[npc.index] = 999;
		i_NpcIsABuilding[npc.index] = true;
		b_NoKnockbackFromSources[npc.index] = true;
		b_StaticNPC[npc.index] = true;
		AddNpcToAliveList(npc.index, 1);
		npc.m_bDissapearOnDeath = true;
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;

		SetEntPropString(npc.index, Prop_Data, "m_iName", "resource");
		ApplyStatusEffect(npc.index, npc.index, "Clear Head", 999999.0);
		b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true;

		npc.m_flRangedArmor = 0.0;
		npc.m_bCamo = true;	// For AI attacking resources
		
		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCOnTakeDamage[npc.index] = ClotTakeDamage;
		b_NpcUnableToDie[npc.index] = true;
		b_NoHealthbar[npc.index] = 1;

		if(data[0])
			strcopy(c_NpcName[npc.index], sizeof(c_NpcName[]), data);

		return npc;
	}
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

					if(Dungeon_LootExists(c_NpcName[victim]))
					{
						CPrintToChatAll("%t", "Found Dungeon Loot", c_NpcName[victim]);
						Dungeon_RollNamedLoot(c_NpcName[victim]);
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
