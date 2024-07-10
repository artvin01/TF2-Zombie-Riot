
static int CurrentModifActive = 0;

#define CHAOS_INTRUSION = 1

void ZRModifs_ChaosIntrusionNPC(int iNpc)
{
	fl_Extra_Damage[iNpc] *= 1.2;
	int Health = GetEntProp(iNpc, Prop_Data, "m_iMaxHealth");
	SetEntProp(iNpc, Prop_Data, "m_iHealth", RoundToCeil(float(Health) * 1.30));
	fl_GibVulnerablity[iNpc] *= 1.30;
	fl_Extra_Speed[iNpc] *= 1.05;
}

float ZRModifs_MaxSpawnsAlive()
{
	switch(CurrentModifActive)
	{
		case CHAOS_INTRUSION:
		{
			return 1.10;
		}
	}
	return 1.0;
}

float ZRModifs_SpawnSpeedModif()
{
	switch(CurrentModifActive)
	{
		case CHAOS_INTRUSION:
		{
			return 0.85;
		}
	}
	return 1.0;
}

float ZRModifs_MaxSpawnWaveModif()
{
	switch(CurrentModifActive)
	{
		case CHAOS_INTRUSION:
		{
			return 1.35;
		}
	}
	return 1.0;
}
