#pragma semicolon 1
#pragma newdecls required

static bool MaxMiniBoss;
static int CurrentModifActive = 0;

#define CHAOS_INTRUSION 1
#define SECONDARY_MERCS 2
#define OLD_TIMES 3
#define TURBOLENCES 4
#define PARANORMAL_ACTIVITY 5
#define PREFIX_GALORE 6
#define PREFIX_ONESTAND 7

void Modifier_MiniBossSpawn(bool &spawns)
{
	if(MaxMiniBoss)
		spawns = true;
}

public void Modifier_Collect_MaxMiniBoss()
{
	MaxMiniBoss = true;
}

public void Modifier_Remove_MaxMiniBoss()
{
	MaxMiniBoss = false;
}

public void Modifier_Collect_ChaosIntrusion()
{
	CurrentModifActive = CHAOS_INTRUSION;
}

char SkynameSave[32];
public void Modifier_Collect_ChaosIntrusion_LvL3_Const2()
{
	CvarSkyName.GetString(SkynameSave, sizeof(SkynameSave));
	Waves_SetSkyName("space_5");
	ToggleEntityByName("color_correct_entity_hard", true);
}

public void Modifier_Remove_ChaosIntrusion_LvL3_Const2()
{
	Waves_SetSkyName(SkynameSave);
	ToggleEntityByName("color_correct_entity_hard", false);
}

public void Modifier_Remove_ChaosIntrusion()
{
	CurrentModifActive = 0;
}

public void Modifier_Collect_SecondaryMercs()
{
	CurrentModifActive = SECONDARY_MERCS;
}
public void Modifier_Collect_Prefix_Galore()
{
	CurrentModifActive = PREFIX_GALORE;
}
public void Modifier_Collect_OneStand()
{
	CurrentModifActive = PREFIX_ONESTAND;
}

public void Modifier_Remove_SecondaryMercs()
{
	CurrentModifActive = 0;
}

public void Modifier_Collect_OldTimes()
{
	CurrentModifActive = OLD_TIMES;
}

public void Modifier_Collect_Turbolences()
{
	CurrentModifActive = TURBOLENCES;
}

public void Modifier_Remove_OldTimes()
{
	CurrentModifActive = 0;
}

public void Modifier_Collect_ParanormalActivity()
{
	CurrentModifActive = PARANORMAL_ACTIVITY;
}

public void Modifier_Remove_ParanormalActivity()
{
	CurrentModifActive = 0;
}

public int ZR_Get_Modifier()
{
	return CurrentModifActive;
}

public void Modifier_RecolourAlly_SecondaryMercs(int client, StringMap map)
{
	if(client > MaxClients)
		return;
	int entity, i;
	while(TF2U_GetWearable(client, entity, i))
	{
		SetTeam(entity, 3);
		SetEntProp(entity, Prop_Send, "m_nSkin", 1);
	}	
	RequestFrame(OvverideTeamcolour, GetClientUserId(client));
}

static void OvverideTeamcolour(int userid)
{
	int client = GetClientOfUserId(userid);
	if(!client)
		return;
		
	int entity, i;
	while(TF2U_GetWearable(client, entity, i))
	{
		SetTeam(entity, 3);
		SetEntProp(entity, Prop_Send, "m_nSkin", 1);
	}	
}
public void ZRModifs_ChaosIntrusionNPC(int iNpc)
{
	fl_Extra_Damage[iNpc] *= 1.12;
	int Health = GetEntProp(iNpc, Prop_Data, "m_iMaxHealth");
	SetEntProp(iNpc, Prop_Data, "m_iHealth", RoundToCeil(float(Health) * 1.30));
	SetEntProp(iNpc, Prop_Data, "m_iMaxHealth", RoundToCeil(float(Health) * 1.30));
	fl_GibVulnerablity[iNpc] *= 1.30;
	fl_Extra_Speed[iNpc] *= 1.03;
}

public void ZRModifs_SecondaryMercsNPC(int iNpc)
{
	fl_Extra_Damage[iNpc] *= 1.15;
	int Health = GetEntProp(iNpc, Prop_Data, "m_iMaxHealth");
	SetEntProp(iNpc, Prop_Data, "m_iHealth", RoundToCeil(float(Health) * 1.50));
	SetEntProp(iNpc, Prop_Data, "m_iMaxHealth", RoundToCeil(float(Health) * 1.50));
	fl_GibVulnerablity[iNpc] *= 1.50;
	fl_Extra_Speed[iNpc] *= 1.04;
}

public void ZRModifs_OldTimesNPC(int iNpc)
{
	fl_Extra_Damage[iNpc] *= 1.25;
	int Health = GetEntProp(iNpc, Prop_Data, "m_iMaxHealth");
	SetEntProp(iNpc, Prop_Data, "m_iHealth", RoundToCeil(float(Health) * 1.6));
	SetEntProp(iNpc, Prop_Data, "m_iMaxHealth", RoundToCeil(float(Health) * 1.6));
	fl_GibVulnerablity[iNpc] *= 1.6;
	fl_Extra_Speed[iNpc] *= 1.06;
	f_AttackSpeedNpcIncrease[iNpc] *= 0.75;
}

float ZRModifs_MaxSpawnsAlive()
{
	switch(CurrentModifActive)
	{
		case CHAOS_INTRUSION:
		{
			return 1.10;
		}
		case SECONDARY_MERCS, OLD_TIMES:
		{
			return 1.20;
		}
	}
	return 1.0;
}

float ZRModifs_SpawnSpeedModif()
{
	float value = Classic_Mode() ? 3.0 : 1.0;

	if(!Classic_Mode())
	{
		value *= ((float(EnemyNpcAlive - EnemyNpcAliveStatic) / float(MaxEnemiesAllowedSpawnNext())) * 2.25);
		if(!VIPBuilding_Active())
		{
			value *= 0.75;
		}
		if(Construction_Mode())
		{
			value *= 0.65;
			//spawn much faster in construction.
		}
		//just spawn much faster.
	}

	switch(CurrentModifActive)
	{
		case CHAOS_INTRUSION:
		{
			value *= 0.85;
		}
		case SECONDARY_MERCS, OLD_TIMES:
		{
			value *= 0.75;
		}
	}
	return value;
}

float ZRModifs_MaxSpawnWaveModif()
{
	switch(CurrentModifActive)
	{
		case CHAOS_INTRUSION:
		{
			return 1.25;
		}
		case SECONDARY_MERCS, OLD_TIMES:
		{
			return 1.35;
		}
	}
	return 1.0;
}

void ZRModifs_CharBuffToAdd(char[] data)
{
	switch(CurrentModifActive)
	{
		case CHAOS_INTRUSION:
		{
			FormatEx(data, 12, "C");
		}
		case SECONDARY_MERCS:
		{
			FormatEx(data, 12, "S");
		}
		case OLD_TIMES:
		{
			FormatEx(data, 12, "O");
		}
		case PARANORMAL_ACTIVITY:
		{
			FormatEx(data, 12, "P");
		}
		case PREFIX_GALORE:
		{
			FormatEx(data, 12, "G");
		}
		case PREFIX_ONESTAND:
		{
			FormatEx(data, 12, "OS");
		}
	}
}
public void ZRModifs_ModifEnemy_OneStand(int iNpc)
{
	//if alone on server, this modifier wont do anything.....

	if(b_IsAloneOnServer)
		return;
		
	if(b_thisNpcIsABoss[iNpc] || b_thisNpcIsARaid[iNpc])
	{
		SetEntProp(iNpc, Prop_Data, "m_iHealth", RoundToCeil(float(ReturnEntityMaxHealth(iNpc)) * 0.9));
		SetEntProp(iNpc, Prop_Data, "m_iMaxHealth", RoundToCeil(float(ReturnEntityMaxHealth(iNpc)) * 0.9));
		fl_Extra_Damage[iNpc] *= 0.9;
	}
}

int CurrentModifOn()
{
	return CurrentModifActive;
}
