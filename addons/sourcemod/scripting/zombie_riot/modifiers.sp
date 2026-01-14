#pragma semicolon 1
#pragma newdecls required

static bool MaxMiniBoss;
static int CurrentModifActive = 0;

#define CHAOS_INTRUSION 1
#define SECONDARY_MERCS 2
#define OLD_TIMES 3
#define TURBOLENCES 4
#define PARANORMAL_ACTIVITY 5

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

public void Modifier_Collect_ChaosIntrusion_LvL3_Const2()
{
	Modifier_Collect_ChaosIntrusion();
//	int color[4] = { 220, 100, 12, 115 };
//	SetCustomFog(FogType_Difficulty, color, color, 75.0, 350.0, 0.3,_,true);
}

public void Modifier_Remove_ChaosIntrusion_LvL3_Const2()
{
	Modifier_Remove_ChaosIntrusion();
	ClearCustomFog(FogType_Difficulty);
}

public void Modifier_Remove_ChaosIntrusion()
{
	CurrentModifActive = 0;
}

public void Modifier_Collect_SecondaryMercs()
{
	CurrentModifActive = SECONDARY_MERCS;
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

public void ZRModifs_ParanormalActivityNPC(int iNpc)
{
	CClotBody ZNPC = view_as<CClotBody>(iNpc);

	if(IsValidEntity(ZNPC.m_iWearable1) && !b_EntityCantBeColoured[ZNPC.m_iWearable1])
	{
		SetEntityRenderMode(ZNPC.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(ZNPC.m_iWearable1, 0, 0, 0, 150);
		SetEntPropFloat(ZNPC.m_iWearable1, Prop_Send, "m_fadeMinDist", 600.0);
		SetEntPropFloat(ZNPC.m_iWearable1, Prop_Send, "m_fadeMaxDist", 700.0);
	}
	if(IsValidEntity(ZNPC.m_iWearable2) && !b_EntityCantBeColoured[ZNPC.m_iWearable2])
	{
		SetEntityRenderMode(ZNPC.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(ZNPC.m_iWearable2, 0, 0, 0, 150);
		SetEntPropFloat(ZNPC.m_iWearable2, Prop_Send, "m_fadeMinDist", 600.0);
		SetEntPropFloat(ZNPC.m_iWearable2, Prop_Send, "m_fadeMaxDist", 700.0);
	}
	if(IsValidEntity(ZNPC.m_iWearable3) && !b_EntityCantBeColoured[ZNPC.m_iWearable3])
	{
		SetEntityRenderMode(ZNPC.m_iWearable3, RENDER_TRANSCOLOR);
		SetEntityRenderColor(ZNPC.m_iWearable3, 0, 0, 0, 150);
		SetEntPropFloat(ZNPC.m_iWearable3, Prop_Send, "m_fadeMinDist", 600.0);
		SetEntPropFloat(ZNPC.m_iWearable3, Prop_Send, "m_fadeMaxDist", 700.0);
	}
	if(IsValidEntity(ZNPC.m_iWearable4) && !b_EntityCantBeColoured[ZNPC.m_iWearable4])
	{
		SetEntityRenderMode(ZNPC.m_iWearable4, RENDER_TRANSCOLOR);
		SetEntityRenderColor(ZNPC.m_iWearable4, 0, 0, 0, 150);
		SetEntPropFloat(ZNPC.m_iWearable4, Prop_Send, "m_fadeMinDist", 600.0);
		SetEntPropFloat(ZNPC.m_iWearable4, Prop_Send, "m_fadeMaxDist", 700.0);
	}
	if(IsValidEntity(ZNPC.m_iWearable5) && !b_EntityCantBeColoured[ZNPC.m_iWearable5])
	{
		SetEntityRenderMode(ZNPC.m_iWearable5, RENDER_TRANSCOLOR);
		SetEntityRenderColor(ZNPC.m_iWearable5, 0, 0, 0, 150);
		SetEntPropFloat(ZNPC.m_iWearable5, Prop_Send, "m_fadeMinDist", 600.0);
		SetEntPropFloat(ZNPC.m_iWearable5, Prop_Send, "m_fadeMaxDist", 700.0);
	}
	if(IsValidEntity(ZNPC.m_iWearable6) && !b_EntityCantBeColoured[ZNPC.m_iWearable6])
	{
		SetEntityRenderMode(ZNPC.m_iWearable6, RENDER_TRANSCOLOR);
		SetEntityRenderColor(ZNPC.m_iWearable6, 0, 0, 0, 150);
		SetEntPropFloat(ZNPC.m_iWearable6, Prop_Send, "m_fadeMinDist", 600.0);
		SetEntPropFloat(ZNPC.m_iWearable6, Prop_Send, "m_fadeMaxDist", 700.0);
	}
	if(IsValidEntity(ZNPC.m_iWearable7) && !b_EntityCantBeColoured[ZNPC.m_iWearable7])
	{
		SetEntityRenderMode(ZNPC.m_iWearable7, RENDER_TRANSCOLOR);
		SetEntityRenderColor(ZNPC.m_iWearable7, 0, 0, 0, 150);
		SetEntPropFloat(ZNPC.m_iWearable7, Prop_Send, "m_fadeMinDist", 600.0);
		SetEntPropFloat(ZNPC.m_iWearable7, Prop_Send, "m_fadeMaxDist", 700.0);
	}
	if(IsValidEntity(ZNPC.m_iWearable8) && !b_EntityCantBeColoured[ZNPC.m_iWearable8])
	{
		SetEntityRenderMode(ZNPC.m_iWearable8, RENDER_TRANSCOLOR);
		SetEntityRenderColor(ZNPC.m_iWearable8, 0, 0, 0, 150);
		SetEntPropFloat(ZNPC.m_iWearable8, Prop_Send, "m_fadeMinDist", 600.0);
		SetEntPropFloat(ZNPC.m_iWearable8, Prop_Send, "m_fadeMaxDist", 700.0);
	}
	if(IsEntityAlive(ZNPC.m_iWearable1) && !b_EntityCantBeColoured[ZNPC.m_iWearable1])
	{
		SetEntityRenderMode(ZNPC.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(ZNPC.m_iWearable1, 0, 0, 0, 150);
		SetEntPropFloat(ZNPC.m_iWearable1, Prop_Send, "m_fadeMinDist", 600.0);
		SetEntPropFloat(ZNPC.m_iWearable1, Prop_Send, "m_fadeMaxDist", 700.0);
	}
	if(IsEntityAlive(ZNPC.m_iWearable2) && !b_EntityCantBeColoured[ZNPC.m_iWearable2])
	{
		SetEntityRenderMode(ZNPC.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(ZNPC.m_iWearable2, 0, 0, 0, 150);
		SetEntPropFloat(ZNPC.m_iWearable2, Prop_Send, "m_fadeMinDist", 600.0);
		SetEntPropFloat(ZNPC.m_iWearable2, Prop_Send, "m_fadeMaxDist", 700.0);
	}
	if(IsEntityAlive(ZNPC.m_iWearable3) && !b_EntityCantBeColoured[ZNPC.m_iWearable3])
	{
		SetEntityRenderMode(ZNPC.m_iWearable3, RENDER_TRANSCOLOR);
		SetEntityRenderColor(ZNPC.m_iWearable3, 0, 0, 0, 150);
		SetEntPropFloat(ZNPC.m_iWearable3, Prop_Send, "m_fadeMinDist", 600.0);
		SetEntPropFloat(ZNPC.m_iWearable3, Prop_Send, "m_fadeMaxDist", 700.0);
	}
	if(IsEntityAlive(ZNPC.m_iWearable4) && !b_EntityCantBeColoured[ZNPC.m_iWearable4])
	{
		SetEntityRenderMode(ZNPC.m_iWearable4, RENDER_TRANSCOLOR);
		SetEntityRenderColor(ZNPC.m_iWearable4, 0, 0, 0, 150);
		SetEntPropFloat(ZNPC.m_iWearable4, Prop_Send, "m_fadeMinDist", 600.0);
		SetEntPropFloat(ZNPC.m_iWearable4, Prop_Send, "m_fadeMaxDist", 700.0);
	}
	if(IsEntityAlive(ZNPC.m_iWearable5) && !b_EntityCantBeColoured[ZNPC.m_iWearable5])
	{
		SetEntityRenderMode(ZNPC.m_iWearable5, RENDER_TRANSCOLOR);
		SetEntityRenderColor(ZNPC.m_iWearable5, 0, 0, 0, 150);
		SetEntPropFloat(ZNPC.m_iWearable5, Prop_Send, "m_fadeMinDist", 600.0);
		SetEntPropFloat(ZNPC.m_iWearable5, Prop_Send, "m_fadeMaxDist", 700.0);
	}
	if(IsEntityAlive(ZNPC.m_iWearable6) && !b_EntityCantBeColoured[ZNPC.m_iWearable6])
	{
		SetEntityRenderMode(ZNPC.m_iWearable6, RENDER_TRANSCOLOR);
		SetEntityRenderColor(ZNPC.m_iWearable6, 0, 0, 0, 150);
		SetEntPropFloat(ZNPC.m_iWearable6, Prop_Send, "m_fadeMinDist", 600.0);
		SetEntPropFloat(ZNPC.m_iWearable6, Prop_Send, "m_fadeMaxDist", 700.0);
	}
	if(IsEntityAlive(ZNPC.m_iWearable7) && !b_EntityCantBeColoured[ZNPC.m_iWearable7])
	{
		SetEntityRenderMode(ZNPC.m_iWearable7, RENDER_TRANSCOLOR);
		SetEntityRenderColor(ZNPC.m_iWearable7, 0, 0, 0, 150);
		SetEntPropFloat(ZNPC.m_iWearable7, Prop_Send, "m_fadeMinDist", 600.0);
		SetEntPropFloat(ZNPC.m_iWearable7, Prop_Send, "m_fadeMaxDist", 700.0);
	}
	if(IsEntityAlive(ZNPC.m_iWearable8) && !b_EntityCantBeColoured[ZNPC.m_iWearable8])
	{
		SetEntityRenderMode(ZNPC.m_iWearable8, RENDER_TRANSCOLOR);
		SetEntityRenderColor(ZNPC.m_iWearable8, 0, 0, 0, 150);
		SetEntPropFloat(ZNPC.m_iWearable8, Prop_Send, "m_fadeMinDist", 600.0);
		SetEntPropFloat(ZNPC.m_iWearable8, Prop_Send, "m_fadeMaxDist", 700.0);
	}

	fl_Extra_Damage[iNpc] *= 1.05;
	SetEntityRenderMode(iNpc, RENDER_TRANSCOLOR);
	SetEntityRenderColor(iNpc, 0, 0, 0, 150);
	SetEntPropFloat(iNpc, Prop_Send, "m_fadeMinDist", 600.0);
	SetEntPropFloat(iNpc, Prop_Send, "m_fadeMaxDist", 700.0);
	b_NoHealthbar[iNpc] = 1;
	GiveNpcOutLineLastOrBoss(iNpc, false);
	b_thisNpcHasAnOutline[iNpc] = true;

	/*
	float SelfPosParanormal[3];
	float AllyPosParanormal[3];
	float flDistanceToTargetParanormal = GetVectorDistance(SelfPosParanormal, AllyPosParanormal, true);
	if(flDistanceToTargetParanormal < (100.0 * 100.0))
	{
		fl_Extra_Speed[iNpc] *= 2.0;
	}
	if(flDistanceToTargetParanormal > (100.0 * 100.0))
	{
		fl_Extra_Speed[iNpc] *= 0.5;
	}
	*/

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
			FormatEx(data, 6, "C");
		}
		case SECONDARY_MERCS:
		{
			FormatEx(data, 6, "S");
		}
		case OLD_TIMES:
		{
			FormatEx(data, 6, "O");
		}
		case PARANORMAL_ACTIVITY:
		{
			FormatEx(data, 6, "P");
		}
	}
}

int CurrentModifOn()
{
	return CurrentModifActive;
}
