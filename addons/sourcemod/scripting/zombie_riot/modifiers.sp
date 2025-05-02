#pragma semicolon 1
#pragma newdecls required

static bool MaxMiniBoss;
static int CurrentModifActive = 0;

#define CHAOS_INTRUSION 1
#define SECONDARY_MERCS 2
#define OLD_TIMES 3

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

public void Modifier_Remove_OldTimes()
{
	CurrentModifActive = 0;
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
	}
}

int CurrentModifOn()
{
	return CurrentModifActive;
}
