#pragma semicolon 1

static const char SoundMoabHit[][] =
{
	"zombie_riot/btd/hitmoab01.wav",
	"zombie_riot/btd/hitmoab02.wav",
	"zombie_riot/btd/hitmoab03.wav",
	"zombie_riot/btd/hitmoab04.wav"
};

static const char SoundZomgPop[][] =
{
	"zombie_riot/btd/zomgdestroyed01.wav",
	"zombie_riot/btd/zomgdestroyed02.wav"
};

static float MoabSpeed()
{
	if(CurrentRound < 80)
		return 150.0;
	
	if(CurrentRound < 100)
		return 150.0 * (1.0 + (CurrentRound - 79) * 0.02);
	
	return 150.0 * (1.0 + (CurrentRound - 70) * 0.02);
}

static int MoabHealth(bool fortified)
{
	float value = 790000.0;	// 200x3x3 + 700x3 + 4000 RGB
	if(fortified)
		value *= 2.0;
	
	if(CurrentRound > 123)
	{
		value *= 1.05 + (CurrentRound - 106) * 0.15;
	}
	else if(CurrentRound > 99)
	{
		value *= 1.0 + (CurrentRound - 71) * 0.05;
	}
	else if(CurrentRound > 79)
	{
		value *= 1.0 + (CurrentRound - 79) * 0.02;
	}
	
	return RoundFloat(value) + (Bloon_Health(fortified, Bloon_Ceramic) * 27);	// 104x3x3x3 RGB
}

void Zomg_MapStart()
{
	#if defined FORCE_BLOON_ENABLED
	char buffer[256];
	for(int i; i<sizeof(SoundZomgPop); i++)
	{
		PrecacheSound(SoundZomgPop[i]);
		FormatEx(buffer, sizeof(buffer), "sound/%s", SoundZomgPop[i]);
		AddFileToDownloadsTable(buffer);
	}
	
	PrecacheModel("models/zombie_riot/btd/zomg.mdl");
	AddFileToDownloadsTable("models/zombie_riot/btd/zomg.dx80.vtx");
	AddFileToDownloadsTable("models/zombie_riot/btd/zomg.dx90.vtx");
	AddFileToDownloadsTable("models/zombie_riot/btd/zomg.mdl");
	AddFileToDownloadsTable("models/zombie_riot/btd/zomg.vvd");
	AddFileToDownloadsTable("material/models/zombie_riot/btd/zomg/zomgdamage1diffuse.vmt");
	AddFileToDownloadsTable("material/models/zombie_riot/btd/zomg/zomgdamage1diffuse.vtf");
	AddFileToDownloadsTable("material/models/zombie_riot/btd/zomg/zomgdamage2diffuse.vmt");
	AddFileToDownloadsTable("material/models/zombie_riot/btd/zomg/zomgdamage2diffuse.vtf");
	AddFileToDownloadsTable("material/models/zombie_riot/btd/zomg/zomgdamage3diffuse.vmt");
	AddFileToDownloadsTable("material/models/zombie_riot/btd/zomg/zomgdamage3diffuse.vtf");
	AddFileToDownloadsTable("material/models/zombie_riot/btd/zomg/zomgdamage4diffuse.vmt");
	AddFileToDownloadsTable("material/models/zombie_riot/btd/zomg/zomgdamage4diffuse.vtf");
	AddFileToDownloadsTable("material/models/zombie_riot/btd/zomg/zomgstandarddiffuse.vmt");
	AddFileToDownloadsTable("material/models/zombie_riot/btd/zomg/zomgstandarddiffuse.vtf");
	#endif
}

static bool Fortified[MAXENTITIES];

methodmap Zomg < CClotBody
{
	property bool m_bFortified
	{
		public get()
		{
			return Fortified[this.index];
		}
		public set(bool value)
		{
			Fortified[this.index] = value;
		}
	}
	public void PlayHitSound()
	{
		int sound = GetRandomInt(0, sizeof(SoundMoabHit) - 1);
		EmitSoundToAll(SoundMoabHit[sound], this.index, SNDCHAN_VOICE, 80, _, 1.0);
	}
	public void PlayDeathSound()
	{
		int sound = GetRandomInt(0, sizeof(SoundZomgPop) - 1);
		EmitSoundToAll(SoundZomgPop[sound], this.index, SNDCHAN_AUTO, 80, _, 1.0);
	}
	public int UpdateBloonOnDamage()
	{
		int type = 4 - (GetEntProp(this.index, Prop_Data, "m_iHealth") * 5 / GetEntProp(this.index, Prop_Data, "m_iMaxHealth"));
		if(type == -1)
			type = 0;
		
		SetEntProp(this.index, Prop_Send, "m_nSkin", type);
	}
	public Zomg(int client, float vecPos[3], float vecAng[3], const char[] data)
	{
		bool fortified = StrContains(data, "f") != -1;
		
		char buffer[16];
		IntToString(MoabHealth(fortified), buffer, sizeof(buffer));
		
		Zomg npc = view_as<Zomg>(CClotBody(vecPos, vecAng, "models/zombie_riot/btd/zomg.mdl", "1.0", buffer, false, false, true));
		
		i_NpcInternalId[npc.index] = BTD_ZOMG;
		
		int iActivity = npc.LookupActivity("ACT_FLOAT");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_iBleedType = BLEEDTYPE_RUBBER;
		npc.m_iStepNoiseType = NOTHING;	
		npc.m_iNpcStepVariation = NOTHING;	
		npc.m_bDissapearOnDeath = true;
		npc.m_bisWalking = false;
		
		npc.m_flSpeed = MoabSpeed();
		npc.m_bFortified = fortified;
		
		npc.m_iStepNoiseType = 0;	
		npc.m_iState = 0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_fbRangedSpecialOn = false;
		
		SDKHook(npc.index, SDKHook_OnTakeDamage, Zomg_ClotDamaged);
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, Zomg_ClotDamagedPost);
		SDKHook(npc.index, SDKHook_Think, Zomg_ClotThink);
		
		PF_StartPathing(npc.index);
		npc.m_bPathing = true;
		
		return npc;
	}
	
	
}

//TODO 
//Rewrite
public void Zomg_ClotThink(int iNPC)
{
	Zomg npc = view_as<Zomg>(iNPC);
	
	if(npc.m_bFortified)
	{
		SetVariantInt(1);
		AcceptEntityInput(iNPC, "SetBodyGroup");
	}
	
	float gameTime = GetGameTime();
	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextDelayTime = gameTime + 0.04;
	
	npc.Update();	
	
	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
													
		float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
		
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius())
		{
			//float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, PrimaryThreatIndex);
			
			PF_SetGoalVector(npc.index, PredictSubjectPosition(npc, PrimaryThreatIndex));
		}
		else
		{
			PF_SetGoalEntity(npc.index, PrimaryThreatIndex);
		}
		
		//Target close enough to hit
		if(flDistanceToTarget < 20000)
		{
		//	npc.FaceTowards(vecTarget, 1000.0);
			
			if(npc.m_flNextMeleeAttack < gameTime)
			{
				npc.m_flNextMeleeAttack = gameTime + 0.35;
				
				Handle swingTrace;
				if(npc.DoAimbotTrace(swingTrace, PrimaryThreatIndex))
				{
					int target = TR_GetEntityIndex(swingTrace);
					if(target > 0)
					{
						if(npc.m_bFortified)
						{
							if(target <= MaxClients)
							{
								SDKHooks_TakeDamage(target, npc.index, npc.index, 40.0, DMG_SLASH|DMG_CLUB);
							}
							else
							{
								SDKHooks_TakeDamage(target, npc.index, npc.index, 150.0, DMG_SLASH|DMG_CLUB);
							}
						}
						else
						{
							if(target <= MaxClients)
							{
								
								SDKHooks_TakeDamage(target, npc.index, npc.index, 25.0, DMG_SLASH|DMG_CLUB);
							}
							else
							{
								SDKHooks_TakeDamage(target, npc.index, npc.index, 100.0, DMG_SLASH|DMG_CLUB);
							}							
						}
					}
					
					delete swingTrace;
				}
			}
		}
		
		PF_StartPathing(npc.index);
		npc.m_bPathing = true;
	}
	else
	{
		PF_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
}

public Action Zomg_ClotDamaged(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
	
	Zomg npc = view_as<Zomg>(victim);
	npc.PlayHitSound();
	return Plugin_Changed;
}

public void Zomg_ClotDamagedPost(int victim, int attacker, int inflictor, float damage, int damagetype, int weapon, const float damageForce[3], const float damagePosition[3], int damagecustom)
{
	Zomg npc = view_as<Zomg>(victim);
	npc.UpdateBloonOnDamage();
}

public void Zomg_NPCDeath(int entity)
{
	Zomg npc = view_as<Zomg>(entity);
	npc.PlayDeathSound();
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamagePost, Zomg_ClotDamagedPost);
	SDKUnhook(npc.index, SDKHook_OnTakeDamage, Zomg_ClotDamaged);
	SDKUnhook(npc.index, SDKHook_Think, Zomg_ClotThink);
	
	float pos[3], angles[3];
	GetEntPropVector(entity, Prop_Data, "m_angRotation", angles);
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	
	int spawn_index = Npc_Create(BTD_BFB, -1, pos, angles, npc.m_bFortified ? "f" : "");
	if(spawn_index > MaxClients)
		Zombies_Currently_Still_Ongoing += 1;
}