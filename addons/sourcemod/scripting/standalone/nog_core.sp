#pragma semicolon 1
#pragma newdecls required

#define MIN_FADE_DISTANCE	9999.9
#define MAX_FADE_DISTANCE	9999.9

#define NORMAL_ENEMY_MELEE_RANGE_FLOAT	130.0
#define NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED	16900.0

#define GIANT_ENEMY_MELEE_RANGE_FLOAT	160.0
#define GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED	25600.0

#define LASERBEAM	"sprites/laserbeam.vmt"

ConVar zr_showdamagehud;

#include "standalone/convars.sp"
#include "standalone/dhooks.sp"
#include "standalone/natives.sp"
#include "standalone/npc.sp"
#include "zombie_riot/custom/homing_projectile_logic.sp"

void NOG_PluginLoad()
{
	Natives_PluginLoad();
}

void NOG_PluginStart()
{
	LoadTranslations("npcs.phrases");
}

void GetHighDefTargets(CClotBody npc, int[] enemy, int count, bool respectTrace = false, bool player_only = false, int TraceFrom = -1, float RangeLimit = 0.0)
{
	// Prio:
	// 1. Highest Defense Stat
	// 2. Highest NPC Entity Index
	// 3. Random Player
	int TraceEntity = npc.index;
	if(TraceFrom != -1)
	{
		TraceEntity = TraceFrom;
	}
	int team = GetTeam(npc.index);
	int[] def = new int[count];
	float gameTime = GetGameTime();
	float pos1[3], pos2[3];
	if(RangeLimit > 0.0)
	{
		if(b_ThisEntityIgnored_NoTeam[TraceEntity])
		{
			GetEntPropVector(TraceEntity, Prop_Data, "m_vecAbsOrigin", pos1);
		}
		else
		{
			WorldSpaceCenter(TraceEntity, pos1);
		}
	}

	for(int client = 1; client <= MaxClients; client++)
	{
		if(!view_as<CClotBody>(client).m_bThisEntityIgnored && IsClientInGame(client) && GetTeam(client) != team && IsEntityAlive(client) && Can_I_See_Enemy_Only(npc.index, client))
		{
			if(respectTrace && !Can_I_See_Enemy_Only(TraceEntity, client))
				continue;
				
			if(RangeLimit > 0.0)
			{
				WorldSpaceCenter(client, pos2);
				float flDistanceToTarget = GetVectorDistance(pos1, pos2, true);
				if(flDistanceToTarget > RangeLimit)
					continue;
			}

			for(int i; i < count; i++)
			{
				int defense = 0;
				if(HasSpecificBuff(client, "Ally Empowerment"))
					defense++;
				
				if(HasSpecificBuff(client, "Self Empowerment"))
					defense++;
				
				if(HasSpecificBuff(client, "Hussar's Warscream"))
					defense++;

				if(enemy[i])
				{
					if(def[i] == defense)
					{
						if(GetURandomInt() % 2)
							continue;
					}
					else if(def[i] < defense)
					{
						continue;
					}
				}

				AddToList(client, i, enemy, count);
				AddToList(defense, i, def, count);
				break;
			}
		}
	}

	if(!player_only)
	{
		for(int a; a < i_MaxcountNpcTotal; a++)
		{
			int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[a]);
			if(entity != INVALID_ENT_REFERENCE && entity != npc.index)
			{
				if(!view_as<CClotBody>(entity).m_bThisEntityIgnored && !b_NpcIsInvulnerable[entity] && !b_ThisEntityIgnoredByOtherNpcsAggro[entity] && GetTeam(entity) != team && IsEntityAlive(entity) && Can_I_See_Enemy_Only(npc.index, entity))
				{
					if(respectTrace && !Can_I_See_Enemy_Only(TraceEntity, entity))
						continue;

					if(RangeLimit > 0.0)
					{
						WorldSpaceCenter(entity, pos2);
						float flDistanceToTarget = GetVectorDistance(pos1, pos2, true);
						if(flDistanceToTarget > RangeLimit)
							continue;
					}

					for(int i; i < count; i++)
					{
						int defense = i_npcspawnprotection[entity] ? 8 : 0;
						
						if(fl_RangedArmor[entity] < 1.0)
							defense += 10 - RoundToFloor(fl_RangedArmor[entity] * 10.0);

						if(HasSpecificBuff(entity, "Defensive Backup"))
							defense += 4;

						if(enemy[i] && def[i] < defense)
							continue;

						AddToList(entity, i, enemy, count);
						AddToList(defense, i, def, count);
						break;
					}
				}
			}
		}
	}
}

static void AddToList(int data, int pos, int[] list, int count)
{
	for(int i = count - 1; i > pos; i--)
	{
		list[i] = list[i - 1];
	}

	list[pos] = data;
}
