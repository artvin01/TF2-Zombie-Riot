#pragma semicolon 1
#pragma newdecls required


static const char g_IdleAlertedSounds[][] = {
	"zombie_riot/miniboss/kamikaze/become_enraged56.wav",
};

static const char g_Spawn[][] = {
	"zombie_riot/miniboss/kamikaze/spawn.wav",
};

static float fl_AlreadyStrippedMusic[MAXTF2PLAYERS];
static float fl_KamikazeSpawnDelay;
void BeheadedKamiKaze_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_Spawn));	   i++) { PrecacheSoundCustom(g_Spawn[i]);	   }
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSoundCustom(g_IdleAlertedSounds[i]); }
	PrecacheModel("models/zombie_riot/serious/kamikaze_3.mdl");
	fl_KamikazeSpawnDelay = 0.0;
}


static char[] GetBeheadedKamiKazeHealth()
{
	int health = 3;
	
	health *= CountPlayersOnRed(); //yep its high! will need tos cale with waves expoentially.
	
	float temp_float_hp = float(health);
	
	if(CurrentRound+1 < 30)
	{
		health = RoundToCeil(Pow(((temp_float_hp + float(CurrentRound+1)) * float(CurrentRound+1)),1.20));
	}
	else if(CurrentRound+1 < 45)
	{
		health = RoundToCeil(Pow(((temp_float_hp + float(CurrentRound+1)) * float(CurrentRound+1)),1.25));
	}
	else
	{
		health = RoundToCeil(Pow(((temp_float_hp + float(CurrentRound+1)) * float(CurrentRound+1)),1.35)); //Yes its way higher but i reduced overall hp of him
	}
	
	health = health * 3 / 8;
	
	char buffer[16];
	IntToString(health, buffer, sizeof(buffer));
	return buffer;
}

methodmap BeheadedKamiKaze < CClotBody
{
	
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetEngineTime())
			return;
		

		EmitCustomToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, 65, _, BOSS_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetEngineTime() + 0.85;
		
	}
	
	public void PlaySpawnSound() {
		
		EmitCustomToAll(g_Spawn[GetRandomInt(0, sizeof(g_Spawn) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		
	}
	
	public BeheadedKamiKaze(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		BeheadedKamiKaze npc = view_as<BeheadedKamiKaze>(CClotBody(vecPos, vecAng, "models/zombie_riot/serious/kamikaze_3.mdl", "1.10", GetBeheadedKamiKazeHealth(), ally));
		
		i_NpcInternalId[npc.index] = MINI_BEHEADED_KAMI;
		i_NpcWeight[npc.index] = 2;
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN");
		if(iActivity > 0) npc.StartActivity(iActivity);
		KillFeed_SetKillIcon(npc.index, "bomb");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPSOUND_NORMAL;		
		npc.m_flSpeed = 450.0;
		
		SDKHook(npc.index, SDKHook_Think, BeheadedKamiKaze_ClotThink);
		
		npc.m_bDoSpawnGesture = true;
		
		for(int client_clear=1; client_clear<=MaxClients; client_clear++)
		{
			fl_AlreadyStrippedMusic[client_clear] = 0.0; //reset to 0
		}

		npc.m_iState = 0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_fbRangedSpecialOn = false;
		
		float wave = float(ZR_GetWaveCount()+1); //Wave scaling
		
		wave *= 0.1;

		npc.m_flWaveScale = wave;

		if(fl_KamikazeSpawnDelay < GetGameTime() + 10.0)
		{
			//This is a kamikaze that was newly initiated!
			//add new kamikazies whenever possible.
			/*
			Handle pack;
			CreateDataTimer(0.1, Kamikaze_Spawn_New, pack, TIMER_FLAG_NO_MAPCHANGE);
			WritePackCell(pack, EntIndexToEntRef(cam));
			WritePackCell(pack, EntIndexToEntRef(ent));
			*/
		}

		fl_KamikazeSpawnDelay = GetGameTime();

		npc.m_bDissapearOnDeath = true;
		TeleportDiversioToRandLocation(npc.index,_,1750.0, 1250.0);
		npc.PlaySpawnSound();
		float pos[3]; pos = WorldSpaceCenter(npc.index);
		pos[2] -= 10.0;
		TE_Particle("teleported_blue", pos, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
		
		npc.StartPathing();
		
		return npc;
	}
	
	
}

//TODO 
//Rewrite
public void BeheadedKamiKaze_ClotThink(int iNPC)
{
	BeheadedKamiKaze npc = view_as<BeheadedKamiKaze>(iNPC);
	npc.PlayIdleAlertSound();
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	
			
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client))
			{
				if(fl_AlreadyStrippedMusic[client] < GetEngineTime())
				{
					Music_Stop_All(client); //This is actually more expensive then i thought.
				}
				SetMusicTimer(client, GetTime() + 10);
				fl_AlreadyStrippedMusic[client] = GetEngineTime() + 10.0;
			}
		}
		npc.m_iTarget = GetClosestTarget(npc.index, true);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		npc.StartPathing();
		float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
		
	
		float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
		
		NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
		
		//Target close enough to hit
		if(flDistanceToTarget < 9025.0 && !npc.m_flAttackHappenswillhappen)
		{
			Kamikaze_DeathExplosion(npc.index);
		}
	}
	else
	{
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
}

public Action BeheadedKamiKaze_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
		
		
	BeheadedKamiKaze npc = view_as<BeheadedKamiKaze>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void BeheadedKamiKaze_NPCDeath(int entity)
{
	BeheadedKamiKaze npc = view_as<BeheadedKamiKaze>(entity);
	
	SDKUnhook(npc.index, SDKHook_Think, BeheadedKamiKaze_ClotThink);
	StopSound(npc.index, SNDCHAN_VOICE, "zombie_riot/miniboss/kamikaze/become_enraged56.wav");
	Kamikaze_DeathExplosion(entity);
}


void Kamikaze_DeathExplosion(int entity)
{
	BeheadedKamiKaze npc = view_as<BeheadedKamiKaze>(entity);
	if(npc.m_flAttackHappenswillhappen)
	{
		return;
	}
	npc.m_flAttackHappenswillhappen = true;
	//change team to one that isnt existant.
	float startPosition[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", startPosition); 
	startPosition[2] += 45.0;
	DataPack pack_boom = new DataPack();
	pack_boom.WriteFloat(startPosition[0]);
	pack_boom.WriteFloat(startPosition[1]);
	pack_boom.WriteFloat(startPosition[2]);
	pack_boom.WriteCell(1);
	RequestFrame(MakeExplosionFrameLater, pack_boom);

	int TeamNum = GetEntProp(npc.index, Prop_Send, "m_iTeamNum");
	SetEntProp(npc.index, Prop_Send, "m_iTeamNum", 4);
	Explode_Logic_Custom(60.0 * npc.m_flWaveScale,
	npc.index,
	npc.index,
	-1,
	_,
	150.0,
	_,
	_,
	false,
	99,
	false,
	_,
	_,
	BeheadedKamiBoomInternal);
	SetEntProp(npc.index, Prop_Send, "m_iTeamNum", TeamNum);
	SmiteNpcToDeath(entity);
}

float BeheadedKamiBoomInternal(int entity, int victim, float damage, int weapon)
{
	if(entity == victim)
		return 0.0;

	//instakill any be_headeads.
	if(i_NpcInternalId[victim] == MINI_BEHEADED_KAMI)
	{
		return 1000000000.0;
	}
}

public Action Kamikaze_Spawn_New(Handle final, any pack)
{
	ResetPack(pack);
	int cam = EntRefToEntIndex(ReadPackCell(pack));
	int ent = EntRefToEntIndex(ReadPackCell(pack));
	
	if (IsValidEntity(cam) && IsValidEntity(ent))
	{
		DispatchKeyValue(cam, "targetname", "cam"); 
		DispatchSpawn(cam);
		ActivateEntity(cam);
		AcceptEntityInput(cam, "Start");
	}
	return Plugin_Continue;
}