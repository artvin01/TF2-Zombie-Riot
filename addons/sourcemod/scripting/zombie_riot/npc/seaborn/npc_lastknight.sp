#pragma semicolon 1
#pragma newdecls required
 
static const char g_DeathSounds[][] =
{
	"npc/combine_soldier/die1.wav",
	"npc/combine_soldier/die2.wav",
	"npc/combine_soldier/die3.wav"
};

static const char g_HurtSounds[][] =
{
	")physics/metal/metal_box_impact_bullet1.wav",
	")physics/metal/metal_box_impact_bullet2.wav",
	")physics/metal/metal_box_impact_bullet3.wav"
};

static const char g_IdleAlertedSounds[][] =
{
	"npc/combine_soldier/vo/alert1.wav",
	"npc/combine_soldier/vo/bouncerbouncer.wav",
	"npc/combine_soldier/vo/boomer.wav",
	"npc/combine_soldier/vo/contactconfim.wav"
};

static const char g_MeleeHitSounds[][] =
{
	"weapons/halloween_boss/knight_axe_hit.wav"
};

static const char g_MeleeAttackSounds[][] =
{
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav"
};

static int PeaceKnight;

void LastKnight_Precache()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "The Last Knight");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_lastknight");
	strcopy(data.Icon, sizeof(data.Icon), "ds_lastknight");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_NORMAL|MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Seaborn;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return LastKnight(vecPos, vecAng, team, data);
}

methodmap LastKnight < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound() 
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public LastKnight(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		if(data[0] == 'N')
		{
			// Normal
			PeaceKnight = -1;
		}
		else if(data[0] == 'F')
		{
			// Freeplay
			PeaceKnight = 0;
		}
		else if(PeaceKnight > 0)
		{
			return view_as<LastKnight>(-1);
		}
		
		LastKnight npc = view_as<LastKnight>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.35", "125000", ally, false));
		// 125000 x 1.0

		SetVariantInt(3);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		i_NpcWeight[npc.index] = 5;
		npc.SetActivity("ACT_LAST_KNIGHT_WALK");
		KillFeed_SetKillIcon(npc.index, "spy_cicle");
		
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;
		
		func_NPCDeath[npc.index] = LastKnight_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = LastKnight_OnTakeDamage;
		func_NPCThink[npc.index] = LastKnight_ClotThink;
		
		npc.m_flSpeed = 150.0;	// 0.6 x 250
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		npc.m_iPhase = 0;
		b_NpcIsTeamkiller[npc.index] = true;

		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/workshop/weapons/c_models/c_xms_cold_shoulder/c_xms_cold_shoulder.mdl");
		SetVariantString("5.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("partyhat", "models/workshop/player/items/all_class/sbox2014_knight_helmet/sbox2014_knight_helmet_demo.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("partyhat", "models/workshop/player/items/demo/sf14_deadking_pauldrons/sf14_deadking_pauldrons.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable4 = npc.EquipItem("partyhat", "models/workshop/player/items/demo/sbox2014_demo_samurai_armour/sbox2014_demo_samurai_armour.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");

		float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
		vecMe[2] += 100.0;

		npc.m_iWearable5 = ParticleEffectAt(vecMe, "powerup_icon_reflect", -1.0);
		SetParent(npc.index, npc.m_iWearable5);

		if(data[1] && ally != TFTeam_Red && !IsValidEntity(RaidBossActive))
		{
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidModeTime = GetGameTime() + 9000.0;
			RaidModeScaling = MultiGlobalHealth;
			if(RaidModeScaling == 1.0) //Dont show scaling if theres none.
				RaidModeScaling = 0.0;
			else
				RaidModeScaling *= 1.5;
			RaidAllowsBuildings = true;
		}
		
		return npc;
	}
	property int m_iPhase
	{
		public get()
		{
			return this.m_iMedkitAnnoyance;
		}
		public set(int value)
		{
			this.m_iMedkitAnnoyance = value;
		}
	}
}

public void LastKnight_ClotThink(int iNPC)
{
	LastKnight npc = view_as<LastKnight>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	if(b_NpcIsInvulnerable[npc.index])
	{
		b_NpcIsInvulnerable[npc.index] = false;
		npc.SetActivity("ACT_RIDER_RUN");
		npc.m_bisWalking = false; //Animation it uses has no groundspeed, this is needed.
		KillFeed_SetKillIcon(npc.index, "vehicle");
		npc.m_flNextThinkTime = gameTime + 0.4;
		b_NpcIgnoresbuildings[npc.index] = true;
		npc.m_iTarget = 0;
		
		if(!IsValidEntity(npc.m_iWearable6))
		{
			npc.m_iWearable6 = npc.EquipItem("partyhat", "models/workshop/player/items/engineer/hwn2022_pony_express/hwn2022_pony_express.mdl");
			SetVariantString("1.1");
			AcceptEntityInput(npc.m_iWearable6, "SetModelScale");

			SetEntityRenderColor(npc.m_iWearable6, 55, 55, 55, 255);
		}
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_iTarget && !IsValidAlly(npc.index, npc.m_iTarget) && !IsValidEnemy(npc.index, npc.m_iTarget))
		npc.m_iTarget = 0;

	bool aggressive = (PeaceKnight == 0 || (PeaceKnight == -1 && CitizenRunner_WasKilled()));

	if(!npc.m_iTarget || npc.m_flGetClosestTargetTime < gameTime)
	{
		if(!aggressive)
		{
			bool found;

			for(int i; i < i_MaxcountNpcTotal; i++)
			{
				int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
				if(entity != INVALID_ENT_REFERENCE && entity != npc.index && !view_as<CClotBody>(entity).m_bThisEntityIgnored && !b_ThisEntityIgnoredByOtherNpcsAggro[entity] && IsEntityAlive(entity) && GetTeam(entity) != TFTeam_Red)
				{
					found = true;
					break;
				}
			}

			if(!found)
			{
				PeaceKnight = 1;
				CPrintToChatAll("{gray}The Last Knight{default}: You have proven yourself, you're against the ocean, and you're not my enemy.");

				int owner;
				for(int client = 1; client <= MaxClients; client++)
				{
					if(IsClientInGame(client) && GetClientTeam(client) == 2)
					{
						int entity = EntRefToEntIndex(i_PlayerToCustomBuilding[client]);
						if(entity != INVALID_ENT_REFERENCE/* && i_WhatBuilding[entity] == BuildingSummoner*/)
						{
							owner = client;
							break;
						}
					}
				}

				float pos[3], ang[3];
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
				GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);

				int ally = NPC_CreateByName("npc_barrack_lastknight", owner, pos, ang, TFTeam_Red);
				view_as<BarrackBody>(ally).BonusDamageBonus = 1.0;
				view_as<BarrackBody>(ally).BonusFireRate = 1.0;
				view_as<BarrackBody>(ally).m_iSupplyCount = 0;

				npc.m_bDissapearOnDeath = true;
				npc.m_flNextDelayTime = FAR_FUTURE;
				SDKHooks_TakeDamage(npc.index, 0, 0, 999999999.0, DMG_GENERIC);
				return;
			}
		}

		npc.m_iTarget = GetClosestTarget(npc.index, npc.m_iPhase == 2, 500.0, false, _, _, _, _, 125.0);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;

		if(npc.m_iTarget < 1)
		{
			// No nearby targets, kill the ocean
			npc.m_iTarget = GetClosestAlly(npc.index, 10000.0);
		}

		// Won't attack runners, find players
		if(npc.m_iTarget < 1)
			npc.m_iTarget = GetClosestTarget(npc.index, npc.m_iPhase == 2);
	}

	if(aggressive)
	{
		npc.m_flRangedArmor = 0.4;
	}
	
	if(npc.m_iTarget > 0)
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float distance = GetVectorDistance(vecTarget, VecSelfNpc, true);	
		
		if(npc.m_flAttackHappens)
		{
			npc.FaceTowards(vecTarget, 15000.0);
			
			if(npc.m_flAttackHappens < gameTime)
			{
				npc.m_flAttackHappens = 0.0;
				
				int team = GetTeam(npc.index);

				Handle swingTrace;
				bool result = npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, _);

				if(result)
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);

					if(target > 0)
					{
						float damage = 1000.0;
						// 2000 x 0.5
						
						if(target > MaxClients)
						{
							if(i_NpcInternalId[target] == CitizenRunner_Id())
							{
								damage *= 20.0;
								view_as<CClotBody>(target).m_bNoKillFeed = true;
							}

							if(ShouldNpcDealBonusDamage(target))
								damage *= 20.0;
							
							if(team == GetTeam(target))
								damage *= 10.0;

							if(f_TimeFrozenStill[target] > gameTime)
								damage *= 1.75;
						}
						else if(TF2_IsPlayerInCondition(target, TFCond_Dazed))
						{
							damage *= 1.75;
						}
						
						float DamageDoExtra = MultiGlobalHealth;
						if(DamageDoExtra != 1.0)
						{
							DamageDoExtra *= 1.5;
						}
						damage *= DamageDoExtra; //Incase too many enemies, boost damage.

						SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB);

						npc.PlayMeleeHitSound();
					}
				}

				delete swingTrace;
			}
		}

		if(npc.m_flNextMeleeAttack < gameTime)
		{
			if(npc.m_iPhase == 2)
			{
				if(distance < 10000.0)
				{
					int target = Can_I_See_Enemy_Only(npc.index, npc.m_iTarget);
					if(IsValidEntity(target))
					{
						npc.m_iTarget = target;
						npc.m_flNextMeleeAttack = gameTime;
						npc.m_flAttackHappens = gameTime;
					}
				}
			}
			else if(distance < 10000.0)
			{
				//int target = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				//if(IsValidEnemy(npc.index, target, true))
				{
					//npc.m_iTarget = target;
					npc.m_flNextMeleeAttack = gameTime + 1.75;
					npc.PlayMeleeSound();

					npc.AddGesture("ACT_LAST_KNIGHT_ATTACK_1");
					npc.m_flAttackHappens = gameTime + 0.25;
					npc.m_flDoingAnimation = gameTime + 0.75;
				}
			}
		}
		
		if(npc.m_flDoingAnimation > gameTime)
		{
			npc.StopPathing();
		}
		else
		{
			if(distance < npc.GetLeadRadius())
			{
				float vPredictedPos[3]; PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
				npc.SetGoalVector(vPredictedPos, true);
			}
			else 
			{
				npc.SetGoalEntity(npc.m_iTarget);
			}

			npc.StartPathing();
		}
	}
	else
	{
		npc.StopPathing();
	}

	npc.PlayIdleSound();
}

void LastKnight_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	LastKnight npc = view_as<LastKnight>(victim);

	if(attacker < 1)
		return;

	if(b_NpcIsInvulnerable[npc.index])
	{
		damage = 0.0;
		return;
	}

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}

	int ratio = GetEntProp(npc.index, Prop_Data, "m_iHealth") * 5 / ReturnEntityMaxHealth(npc.index);
	switch(npc.m_iPhase)
	{
		case 0:
		{
			if(ratio < 3)
			{
				npc.m_iPhase = 1;
			}
		}
		case 1:
		{
			if(ratio < 1)
			{
				npc.m_iPhase = 2;
				npc.m_flSpeed = 300.0;
				b_NpcIsInvulnerable[npc.index] = true;
				npc.m_bisWalking = false; //Animation it uses has no groundspeed, this is needed.
				npc.AddGesture("ACT_LAST_KNIGHT_REVIVE");
				npc.m_flNextThinkTime = gameTime + 8.3;
				npc.StopPathing();
			}
		}
	}

	if((i_HexCustomDamageTypes[victim] & ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED))
		return;
	gameTime = GetGameTime();
	if(!NpcStats_IsEnemyFrozen(attacker, 1) && !NpcStats_IsEnemyFrozen(attacker, 2) && !NpcStats_IsEnemyFrozen(attacker, 3))
	{
		ApplyStatusEffect(npc.index, attacker, "Freeze", (npc.m_iPhase ? 2.0 : 1.0));

		if(IsValidEntity(weapon))
		{
			char buffer[36];
			if(GetEntityClassname(weapon, buffer, sizeof(buffer)) && !StrContains(buffer, "tf_weap"))
				ApplyTempAttrib(weapon, 6, 1.2, npc.m_iPhase ? 2.0 : 1.0);
		}
	}
	else if(!NpcStats_IsEnemyFrozen(attacker, 2) && !NpcStats_IsEnemyFrozen(attacker, 3))
	{
		ApplyStatusEffect(npc.index, attacker, "Cryo", (npc.m_iPhase ? 2.0 : 1.0));

		if(IsValidEntity(weapon))
		{
			char buffer[36];
			if(GetEntityClassname(weapon, buffer, sizeof(buffer)) && !StrContains(buffer, "tf_weap"))
				ApplyTempAttrib(weapon, 6, 1.2, npc.m_iPhase ? 2.0 : 1.0);
		}
	}
	else if(!NpcStats_IsEnemyFrozen(attacker, 3))
	{
		if(IsValidEntity(weapon))
		{
			char buffer[36];
			if(GetEntityClassname(weapon, buffer, sizeof(buffer)) && !StrContains(buffer, "tf_weap"))
				ApplyTempAttrib(weapon, 6, 1.2, npc.m_iPhase ? 2.0 : 1.0);
		}
		else if(attacker > MaxClients)
		{
			if(!b_NpcHasDied[attacker] && f_TimeFrozenStill[attacker] < gameTime)
				Cryo_FreezeZombie(npc.index, attacker, npc.m_iPhase ? 1 : 0);
		}
	}
	else if(attacker > MaxClients)
	{
		if(!b_NpcHasDied[attacker] && f_TimeFrozenStill[attacker] < gameTime)
			Cryo_FreezeZombie(npc.index, attacker, npc.m_iPhase ? 1 : 0);
	}
	else if(!TF2_IsPlayerInCondition(attacker, TFCond_Dazed))
	{
		if(!HasSpecificBuff(attacker, "Fluid Movement"))
			TF2_StunPlayer(attacker, 3.0, 0.8, TF_STUNFLAG_SLOWDOWN);

		if(IsValidEntity(weapon))
		{
			char buffer[36];
			if(GetEntityClassname(weapon, buffer, sizeof(buffer)) && !StrContains(buffer, "tf_weap"))
				ApplyTempAttrib(weapon, 6, 1.4, 3.0);
		}
	}
}

void LastKnight_NPCDeath(int entity)
{
	LastKnight npc = view_as<LastKnight>(entity);
	if(!npc.m_bGib && !npc.m_bDissapearOnDeath)
		npc.PlayDeathSound();
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);

	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);

	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);

	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);

	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
}
