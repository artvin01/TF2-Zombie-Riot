#pragma semicolon 1
#pragma newdecls required

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
	float value = 2000000.0;	// 20000 RGB
	value *= 0.5;
	
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
	
	return RoundFloat(value);
}

void Bad_MapStart()
{
	for(int i; i<sizeof(SoundZomgPop); i++)
	{
		PrecacheSoundCustom(SoundZomgPop[i]);
	}
	
	PrecacheModel("models/zombie_riot/btd/bad.mdl");
}

methodmap Bad < CClotBody
{
	property bool m_bFortified
	{
		public get()
		{
			return this.m_bLostHalfHealth;
		}
		public set(bool value)
		{
			this.m_bLostHalfHealth = value;
		}
	}
	public void PlayHitSound()
	{
		int sound = GetRandomInt(0, sizeof(SoundMoabHit) - 1);
		EmitCustomToAll(SoundMoabHit[sound], this.index, SNDCHAN_VOICE, 80, _, 2.0);
	}
	public void PlayDeathSound()
	{
		int sound = GetRandomInt(0, sizeof(SoundZomgPop) - 1);
		EmitCustomToAll(SoundZomgPop[sound], this.index, SNDCHAN_AUTO, 80, _, 2.0);
	}
	public int UpdateBloonOnDamage()
	{
		int type = 4 - (GetEntProp(this.index, Prop_Data, "m_iHealth") * 5 / GetEntProp(this.index, Prop_Data, "m_iMaxHealth"));
		if(type == -1)
			type = 0;
		
		SetEntProp(this.index, Prop_Send, "m_nSkin", type);
	}
	public Bad(int client, float vecPos[3], float vecAng[3], bool ally, const char[] data)
	{
		bool fortified = StrContains(data, "f") != -1;
		
		char buffer[16];
		IntToString(MoabHealth(fortified), buffer, sizeof(buffer));
		
		Bad npc = view_as<Bad>(CClotBody(vecPos, vecAng, "models/zombie_riot/btd/bad.mdl", "1.0", buffer, ally, false, true));
		
		i_NpcInternalId[npc.index] = BTD_BAD;
		i_NpcWeight[npc.index] = 5;
		KillFeed_SetKillIcon(npc.index, "vehicle");
		
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
		
		
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, Bad_ClotDamagedPost);
		SDKHook(npc.index, SDKHook_Think, Bad_ClotThink);
		
		npc.StartPathing();
		
		
		return npc;
	}
	
	
}

//TODO 
//Rewrite
public void Bad_ClotThink(int iNPC)
{
	Bad npc = view_as<Bad>(iNPC);
	
	if(npc.m_bFortified)
	{
		SetVariantInt(1);
		AcceptEntityInput(iNPC, "SetBodyGroup");
	}
	
	float gameTime = GetGameTime(npc.index);
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
			
			NPC_SetGoalVector(npc.index, PredictSubjectPosition(npc, PrimaryThreatIndex));
		}
		else
		{
			NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
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
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);
						
						if(npc.m_bFortified)
						{
							if(!ShouldNpcDealBonusDamage(target))
							{
								SDKHooks_TakeDamage(target, npc.index, npc.index, 150.0, DMG_CLUB, -1, _, vecHit);
							}
							else
							{
								SDKHooks_TakeDamage(target, npc.index, npc.index, 7000.0, DMG_CLUB, -1, _, vecHit);
							}
						}
						else
						{
							if(!ShouldNpcDealBonusDamage(target))
							{
								SDKHooks_TakeDamage(target, npc.index, npc.index, 100.0, DMG_CLUB, -1, _, vecHit);
							}
							else
							{
								SDKHooks_TakeDamage(target, npc.index, npc.index, 5000.0, DMG_CLUB, -1, _, vecHit);
							}
						}
					}
					
					delete swingTrace;
				}
			}
		}
		
		npc.StartPathing();
		
	}
	else
	{
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
}

public Action Bad_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
	
	Bad npc = view_as<Bad>(victim);
	npc.PlayHitSound();
	return Plugin_Changed;
}

public void Bad_ClotDamagedPost(int victim, int attacker, int inflictor, float damage, int damagetype, int weapon, const float damageForce[3], const float damagePosition[3], int damagecustom)
{
	Bad npc = view_as<Bad>(victim);
	npc.UpdateBloonOnDamage();
}

public void Bad_NPCDeath(int entity)
{
	Bad npc = view_as<Bad>(entity);
	npc.PlayDeathSound();
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamagePost, Bad_ClotDamagedPost);
	
	SDKUnhook(npc.index, SDKHook_Think, Bad_ClotThink);
	
	int team = GetEntProp(npc.index, Prop_Send, "m_iTeamNum");
	
	float pos[3], angles[3];
	GetEntPropVector(npc.index, Prop_Data, "m_angRotation", angles);
	GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", pos);
	for(int i; i<3; i++)
	{
		int spawn_index = Npc_Create(BTD_DDT, -1, pos, angles, team == 2, npc.m_bFortified ? "f" : "");
		if(spawn_index > MaxClients)
			Zombies_Currently_Still_Ongoing++;
	}
	
	int entity_death = CreateEntityByName("prop_dynamic_override");
	if(IsValidEntity(entity_death))
	{
		TeleportEntity(entity_death, pos, angles, NULL_VECTOR);
		
//		GetEntPropString(client, Prop_Data, "m_ModelName", model, sizeof(model));
		DispatchKeyValue(entity_death, "model", "models/zombie_riot/btd/bad.mdl");
		DispatchKeyValue(entity_death, "skin", "4");
		if(npc.m_bFortified)
			DispatchKeyValue(entity_death, "body", "1");
		
		DispatchSpawn(entity_death);
		
		SetEntPropFloat(entity_death, Prop_Send, "m_flModelScale", 1.0); 
		SetEntityCollisionGroup(entity_death, 2);
		SetVariantString("death");
		AcceptEntityInput(entity_death, "SetAnimation");
		SetEntProp(entity_death, Prop_Send, "m_iTeamNum", team);
		
		pos[2] += 20.0;
		
		HookSingleEntityOutput(entity_death, "OnAnimationDone", npc.m_bFortified ? Bad_PostFortifiedDeath : Bad_PostDeath, true);
	}
}

public void Bad_PostDeath(const char[] output, int caller, int activator, float delay)
{
	float pos[3], angles[3];
	GetEntPropVector(caller, Prop_Data, "m_angRotation", angles);
	GetEntPropVector(caller, Prop_Send, "m_vecOrigin", pos);
	RemoveEntity(caller);
	
	TE_Particle("asplode_hoodoo", pos, NULL_VECTOR, NULL_VECTOR, caller, _, _, _, _, _, _, _, _, _, 0.0);
	
	for(int i; i<2; i++)
	{
		int spawn_index = Npc_Create(BTD_ZOMG, -1, pos, angles, GetEntProp(caller, Prop_Send, "m_iTeamNum") == 2);
		if(spawn_index > MaxClients)
			Zombies_Currently_Still_Ongoing++;
	}
}

public void Bad_PostFortifiedDeath(const char[] output, int caller, int activator, float delay)
{
	float pos[3], angles[3];
	GetEntPropVector(caller, Prop_Data, "m_angRotation", angles);
	GetEntPropVector(caller, Prop_Send, "m_vecOrigin", pos);
	RemoveEntity(caller);
	
	TE_Particle("asplode_hoodoo", pos, NULL_VECTOR, NULL_VECTOR, caller, _, _, _, _, _, _, _, _, _, 0.0);
	
	for(int i; i<2; i++)
	{
		int spawn_index = Npc_Create(BTD_ZOMG, -1, pos, angles, GetEntProp(caller, Prop_Send, "m_iTeamNum") == 2, "f");
		if(spawn_index > MaxClients)
			Zombies_Currently_Still_Ongoing++;
	}
}