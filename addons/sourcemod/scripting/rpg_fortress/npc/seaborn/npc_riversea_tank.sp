#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"npc/zombie_poison/pz_die1.wav",
	"npc/zombie_poison/pz_die2.wav"
};

static const char g_HurtSounds[][] =
{
	"npc/zombie_poison/pz_pain1.wav",
	"npc/zombie_poison/pz_pain2.wav",
	"npc/zombie_poison/pz_pain3.wav"
};

static const char g_IdleAlertedSounds[][] =
{
	"npc/zombie_poison/pz_call1.wav"
};

static const char g_MeleeHitSounds[][] =
{
	"npc/fast_zombie/claw_strike1.wav",
	"npc/fast_zombie/claw_strike2.wav",
	"npc/fast_zombie/claw_strike3.wav"
};

static const char g_MeleeAttackSounds[][] =
{
	"npc/zombie_poison/pz_warn1.wav",
	"npc/zombie_poison/pz_warn2.wav"
};

static const char g_RangedAttackSounds[][] =
{
	"npc/zombie_poison/pz_throw2.wav",
	"npc/zombie_poison/pz_throw3.wav"
};

void RiverSeaTank_Setup()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_RangedAttackSounds);
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "River Sea Thymichthys");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_riversea_tank");
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return RiverSeaTank(client, vecPos, vecAng, team);
}

methodmap RiverSeaTank < CClotBody
{
	public void PlayIdleSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;

		EmitSoundToAll(g_IdleAlertedSounds[GetURandomInt() % sizeof(g_IdleAlertedSounds)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSounds[GetURandomInt() % sizeof(g_HurtSounds)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetURandomInt() % sizeof(g_DeathSounds)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound()
 	{
		EmitSoundToAll(g_MeleeHitSounds[GetURandomInt() % sizeof(g_MeleeHitSounds)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetURandomInt() % sizeof(g_MeleeAttackSounds)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayRangedSound()
 	{
		EmitSoundToAll(g_RangedAttackSounds[GetURandomInt() % sizeof(g_RangedAttackSounds)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public RiverSeaTank(int client, float vecPos[3], float vecAng[3], int team)
	{
		RiverSeaTank npc = view_as<RiverSeaTank>(CClotBody(vecPos, vecAng, "models/zombie/poison.mdl", "1.25", "300", team));

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		npc.SetActivity("ACT_ZOMBIE_POISON_THREAT");
		KillFeed_SetKillIcon(npc.index, "mantreads");
		i_NpcWeight[npc.index] = 2;

		npc.m_flAttackHappens = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttackHappening = 0.0;
		i_GrabbedThis[npc.index] = -1;
		
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_SEABORN;

		f3_SpawnPosition[npc.index] = vecPos;

		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCOnTakeDamage[npc.index] = ClotTakeDamage;
		func_NPCThink[npc.index] = ClotThink;
		
		SetEntityRenderColor(npc.index, 126, 126, 255, 255);

		return npc;
	}
}

static void ClotThink(int iNPC)
{
	RiverSeaTank npc = view_as<RiverSeaTank>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();	

	if(npc.m_blPlayHurtAnimation)
	{
		if(npc.m_flDoingAnimation < gameTime)
			npc.AddGesture("ACT_GESTURE_FLINCH_HEAD");
		
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}

	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	// npc.m_iTarget comes from here, This only handles out of battle instancnes, for inbattle, code it yourself. It also makes NPCS jump if youre too high up.
	SeaShared_Thinking(npc.index, 350.0, "ACT_WALK", "ACT_IDLE", 70.0, gameTime);

	int target = npc.m_iTarget;

	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			if(IsValidEnemy(npc.index, target))
			{
				float vecTarget[3]; 
				WorldSpaceCenter(target, vecTarget);
				npc.FaceTowards(vecTarget, 15000.0);

				Handle swingTrace;
				if(npc.DoSwingTrace(swingTrace, target))
				{
					target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);

					if(target > 0) 
					{
						npc.PlayMeleeHitSound();
						
						npc.SetActivity("ACT_RANGE_ATTACK2");
						npc.m_iChanged_WalkCycle = 5;
						npc.m_bisWalking = false;
						npc.m_flSpeed = 0.0;
						npc.StopPathing();
						npc.m_flDoingAnimation = gameTime + 2.6;
						npc.m_flNextRangedAttackHappening = gameTime + 1.25;

						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", f3_LastValidPosition[target]);
						
						float flPos[3]; // original
						float flAng[3]; // original
					
						npc.GetAttachment("Blood_Right", flPos, flAng);
						
						TeleportEntity(target, flPos, NULL_VECTOR, {0.0,0.0,0.0});
						
						if(target <= MaxClients)
						{
							SetEntityMoveType(target, MOVETYPE_NONE); //Cant move XD
							SetEntityCollisionGroup(target, 1);
							SetParent(npc.index, target, "Blood_Right");
						}
						else
						{
							b_NoGravity[target] = true;
							ApplyStatusEffect(npc.index, npc.index, "Solid Stance", 999999.0);	
							view_as<CClotBody>(target).SetVelocity({0.0,0.0,0.0});
						}
						f_TankGrabbedStandStill[target] = GetGameTime() + 1.5;
						TeleportEntity(target, NULL_VECTOR, NULL_VECTOR, {0.0,0.0,0.0});
						i_GrabbedThis[npc.index] = EntIndexToEntRef(target);
						b_DoNotUnStuck[target] = true;
					}
				}
				delete swingTrace;
			}
		}
	}

	if(npc.m_flNextRangedAttackHappening)
	{
		if(npc.m_flNextRangedAttackHappening < gameTime)
		{
			npc.m_flNextRangedAttackHappening = 0.0;

			int client_victim = EntRefToEntIndex(i_GrabbedThis[npc.index]);
			if(IsValidEntity(client_victim))
			{
				i_GrabbedThis[npc.index] = -1;
				AcceptEntityInput(client_victim, "ClearParent");
				
				float flPos[3]; // original
				float flAng[3]; // original
				
				npc.GetAttachment("Blood_Right", flPos, flAng);
				TeleportEntity(client_victim, flPos, NULL_VECTOR, {0.0,0.0,0.0});
						
				if(client_victim <= MaxClients)
				{
					SetEntityMoveType(client_victim, MOVETYPE_WALK); //can move XD
					
					TF2_AddCondition(client_victim, TFCond_LostFooting, 3.0);
					TF2_AddCondition(client_victim, TFCond_AirCurrent, 3.0);
					
					SetEntityCollisionGroup(client_victim, 5);
					b_ThisEntityIgnored[client_victim] = false;
				}
				
				Custom_Knockback(npc.index, client_victim, 3000.0, true, true);
				npc.m_flNextRangedAttackHappening = 0.0;	
				SDKHooks_TakeDamage(client_victim, npc.index, npc.index, Level[npc.index] * 70.0, DMG_CLUB, -1);
				i_TankAntiStuck[client_victim] = EntIndexToEntRef(npc.index);
				CreateTimer(0.1, CheckStuckNemesis, EntIndexToEntRef(client_victim), TIMER_FLAG_NO_MAPCHANGE);
				npc.PlayRangedSound();
			}
		}
	}
	else if(target > 0)
	{
		float vecMe[3], vecTarget[3];
		WorldSpaceCenter(npc.index, vecMe);
		WorldSpaceCenter(target, vecTarget);

		float distance = GetVectorDistance(vecTarget, vecMe, true);
		
		if(distance < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3]; 
			PredictSubjectPosition(npc, target, _, _, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else
		{
			npc.SetGoalEntity(target);
		}

		npc.StartPathing();
		npc.SetActivity("ACT_WALK");
		npc.m_bisWalking = true;
		npc.m_flSpeed = npc.m_flAttackHappens ? 280.0 : 240.0;

		if(distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && npc.m_flNextMeleeAttack < gameTime)
		{
			target = Can_I_See_Enemy(npc.index, npc.m_iTarget);
			if(IsValidEnemy(npc.index, target))
			{
				npc.m_iTarget = target;

				npc.AddGesture("ACT_MELEE_ATTACK1");
				npc.PlayMeleeSound();
				
				npc.m_flAttackHappens = gameTime + 0.75;
				npc.m_flDoingAnimation = gameTime + 1.5;
				npc.m_flNextMeleeAttack = gameTime + 1.55;
			}
		}
	}

	npc.PlayIdleSound();
}

public Action CheckStuckNemesis(Handle timer, any entid)
{
	int client = EntRefToEntIndex(entid);
	if(IsValidEntity(client))
	{
		b_DoNotUnStuck[client] = false;
		float flMyPos[3];
		GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flMyPos);
		static float hullcheckmaxs_Player[3];
		static float hullcheckmins_Player[3];

		if(IsValidClient(client)) //Player size
		{
			hullcheckmaxs_Player = view_as<float>( { 24.0, 24.0, 82.0 } );
			hullcheckmins_Player = view_as<float>( { -24.0, -24.0, 0.0 } );		
		}
		
		if(IsSpaceOccupiedIgnorePlayers(flMyPos, hullcheckmins_Player, hullcheckmaxs_Player, client))
		{
			if(IsValidClient(client)) //Player Unstuck, but give them a penalty for doing this in the first place.
			{
				int damage = SDKCall_GetMaxHealth(client) / 8;
				SDKHooks_TakeDamage(client, 0, 0, float(damage), DMG_GENERIC, -1, NULL_VECTOR);
			}
			TeleportEntity(client, f3_LastValidPosition[client], NULL_VECTOR, { 0.0, 0.0, 0.0 });
		}
		else
		{
			int tank = EntRefToEntIndex(i_TankAntiStuck[client]);
			if(IsValidEntity(tank))
			{
				bool Hit_something = Can_I_See_Enemy_Only(tank, client);
				//Target close enough to hit
				if(!Hit_something)
				{	
					if(IsValidClient(client)) //Player Unstuck, but give them a penalty for doing this in the first place.
					{
						int damage = SDKCall_GetMaxHealth(client) / 8;
						SDKHooks_TakeDamage(client, 0, 0, float(damage), DMG_GENERIC, -1, NULL_VECTOR);
					}
					TeleportEntity(client, f3_LastValidPosition[client], NULL_VECTOR, { 0.0, 0.0, 0.0 });
				}
			}
			else
			{
				//Just teleport back, dont fucking risk it.
				TeleportEntity(client, f3_LastValidPosition[client], NULL_VECTOR, { 0.0, 0.0, 0.0 });
			}
		}
	}
	return Plugin_Handled;
}

static void ClotTakeDamage(int victim, int &attacker, int &inflictor, float &damage)
{
	if(attacker > 0)
	{
		if(EntRefToEntIndex(i_GrabbedThis[victim]) == attacker)
			damage *= 0.25;
		
		Generic_OnTakeDamage(victim, attacker);
	}
}

static void ClotDeath(int entity)
{
	RiverSeaTank npc = view_as<RiverSeaTank>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	
	int client = EntRefToEntIndex(i_GrabbedThis[npc.index]);
	if(IsValidEntity(client))
	{
		AcceptEntityInput(client, "ClearParent");
		
		SetEntityMoveType(client, MOVETYPE_WALK); //can move XD
		SetEntityCollisionGroup(client, 5);
		
		float pos[3];
		float Angles[3];
		GetEntPropVector(entity, Prop_Data, "m_angRotation", Angles);

		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
		TeleportEntity(client, pos, Angles, NULL_VECTOR);
	}
}