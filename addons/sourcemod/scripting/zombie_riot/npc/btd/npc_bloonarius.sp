#pragma semicolon 1

static float MoabSpeed(bool elite)
{
	if(CurrentRound < (elite ? 29 : 59))
		return 12.5;
	
	return 15.0;
}

methodmap Bloonarius < CClotBody
{
	property bool m_bElite
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
	public Bloonarius(int client, float vecPos[3], float vecAng[3], bool ally, const char[] data)
	{
		bool elite = StrContains(data, "e") != -1;
		
		Bloonarius npc = view_as<Bloonarius>(CClotBody(vecPos, vecAng, "models/zombie_riot/btd/bad.mdl", "1.0", "20000", ally, false, true));
		
		i_NpcInternalId[npc.index] = BTD_BLOOONARIUS;
		
		int iActivity = npc.LookupActivity("ACT_FLOAT");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_iBleedType = BLEEDTYPE_RUBBER;
		npc.m_iStepNoiseType = NOTHING;	
		npc.m_iNpcStepVariation = NOTHING;	
		npc.m_bDissapearOnDeath = true;
		npc.m_bThisNpcIsABoss = true;
		npc.m_bisWalking = false;
		
		npc.m_flSpeed = MoabSpeed();
		npc.m_bElite = elite;
		
		npc.m_iStepNoiseType = 0;	
		npc.m_iState = 0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_fbRangedSpecialOn = false;
		
		SDKHook(npc.index, SDKHook_OnTakeDamage, Bloonarius_ClotDamaged);
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, Bloonarius_ClotDamagedPost);
		SDKHook(npc.index, SDKHook_Think, Bloonarius_ClotThink);
		
		npc.StartPathing();
		
		RaidBossActive = EntIndexToEntRef(npc.index);
		
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client) && !IsFakeClient(client))
				LookAtTarget(client, npc.index);
		}
		
		RaidModeTime = GetGameTime() + 300.0;
		RaidModeScaling = float(ZR_GetWaveCount()+1);
		
		if(RaidModeScaling < 55)
		{
			RaidModeScaling *= 0.19; //abit low, inreacing
		}
		else
		{
			RaidModeScaling *= 0.38;
		}
		
		float amount_of_people = float(CountPlayersOnRed());
		
		amount_of_people *= 0.12;
		
		if(amount_of_people < 1.0)
			amount_of_people = 1.0;
			
		RaidModeScaling *= amount_of_people; //More then 9 and he raidboss gets some troubles, bufffffffff
		
		Raidboss_Clean_Everyone();
		return npc;
	}
}

public void Bloonarius_ClotThink(int iNPC)
{
	Bloonarius npc = view_as<Bloonarius>(iNPC);
	
	if(npc.m_bElite)
	{
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
	}
	
	float gameTime = GetGameTime();
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + 0.04;
	npc.Update();
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + 5.0;
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
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
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);
						
						if(npc.m_bFortified)
						{
							if(target <= MaxClients)
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
							if(target <= MaxClients)
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
		PF_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
}

public Action Bloonarius_ClotDamaged(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
	
	Bloonarius npc = view_as<Bloonarius>(victim);
	npc.PlayHitSound();
	return Plugin_Changed;
}

public void Bloonarius_ClotDamagedPost(int victim, int attacker, int inflictor, float damage, int damagetype, int weapon, const float damageForce[3], const float damagePosition[3], int damagecustom)
{
	Bloonarius npc = view_as<Bloonarius>(victim);
	npc.UpdateBloonOnDamage();
}

public void Bloonarius_NPCDeath(int entity)
{
	Bloonarius npc = view_as<Bloonarius>(entity);
	npc.PlayDeathSound();
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamagePost, Bloonarius_ClotDamagedPost);
	SDKUnhook(npc.index, SDKHook_OnTakeDamage, Bloonarius_ClotDamaged);
	SDKUnhook(npc.index, SDKHook_Think, Bloonarius_ClotThink);
	
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
		DispatchKeyValue(entity_death, "model", "models/zombie_riot/btd/Bloonarius.mdl");
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
		
		HookSingleEntityOutput(entity_death, "OnAnimationDone", npc.m_bFortified ? Bloonarius_PostFortifiedDeath : Bloonarius_PostDeath, true);
	}
}

public void Bloonarius_PostDeath(const char[] output, int caller, int activator, float delay)
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

public void Bloonarius_PostFortifiedDeath(const char[] output, int caller, int activator, float delay)
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