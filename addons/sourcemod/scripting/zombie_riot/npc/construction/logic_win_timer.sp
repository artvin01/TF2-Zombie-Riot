#pragma semicolon 1
#pragma newdecls required

static int TimeCheck;
static int WaveCheck;

void WinTimer_MapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Material wood");
	strcopy(data.Plugin, sizeof(data.Plugin), "logic_win_timer");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = true;
	data.Flags = -1;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	TimeCheck = CurrentGame;
	WaveCheck = CurrentRound;

	float time = StringToFloat(data);

	SpawnTimer(time);
	CreateTimer(time, WinTimerNuke, _, TIMER_FLAG_NO_MAPCHANGE);
	return -1;
}

static Action WinTimerNuke(Handle timer)
{
	if(CurrentGame == TimeCheck && WaveCheck == CurrentRound)
	{
		Waves_ClearWaveCurrentSpawningEnemies();

		ArrayList victims = new ArrayList();

		for(int i; i < i_MaxcountNpcTotal; i++)
		{
			int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
			if(entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity))
			{
				if(GetTeam(entity) != TFTeam_Red)
					victims.Push(entity);
			}
		}

		int length = victims.Length;
		if(length)
		{
			int entity = victims.Get(GetURandomInt() % length);

			if(!IsInvuln(entity))
			{
				float pos[3];
				GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);

				EmitSoundToAll(MORTAR_SHOT_INCOMMING, 0, SNDCHAN_AUTO, 90, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, pos);
				int particle = ParticleEffectAt_Parent(pos, "taunt_flip_land_ring", entity);

				CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);
				CreateTimer(1.0, WinTimerKill, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
			}
			
			CreateTimer(0.3, WinTimerNuke, _, TIMER_FLAG_NO_MAPCHANGE);
		}

		delete victims;
	}

	return Plugin_Continue;
}

static Action WinTimerKill(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(entity != -1)
	{
		float pos[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);

		EmitSoundToAll(MORTAR_BOOM, 0, SNDCHAN_AUTO, 90, SND_NOFLAGS, 0.8, SNDPITCH_NORMAL, -1, pos);
		ParticleEffectAt(pos, "rd_robot_explosion", 1.0);
		CreateEarthquake(pos, 0.5, 400.0, 16.0, 255.0);

		SDKHooks_TakeDamage(entity, 0, 0, 900000.0, DMG_BLAST, -1, {0.1,0.1,0.1});

		CreateTimer(0.2, WinTimerNuke, _, TIMER_FLAG_NO_MAPCHANGE);
	}

	return Plugin_Continue;
}
