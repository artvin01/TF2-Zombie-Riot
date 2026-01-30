#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"npc/zombie_poison/pz_die1.wav",
	"npc/zombie_poison/pz_die2.wav",
};

static const char g_HurtSounds[][] = {
	"npc/zombie_poison/pz_pain1.wav",
	"npc/zombie_poison/pz_pain2.wav",
	"npc/zombie_poison/pz_pain3.wav",
};

static const char g_IdleAlertedSounds[][] = {
	"npc/zombie_poison/pz_idle2.wav",
	"npc/zombie_poison/pz_idle3.wav",
	"npc/zombie_poison/pz_idle4.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/knife_swing.wav",
};

static const char g_ZapAttackSounds[][] = {
	"npc/assassin/ball_zap1.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/blade_hit1.wav",
	"weapons/blade_hit2.wav",
	"weapons/blade_hit3.wav",
	"weapons/blade_hit4.wav",
};

static const char g_MeleeAttackBackstabSounds[][] = {
	"player/spy_shield_break.wav",
};


void ZsSpy_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_ZapAttackSounds)); i++) { PrecacheSound(g_ZapAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackBackstabSounds)); i++) { PrecacheSound(g_MeleeAttackBackstabSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	PrecacheModel("models/player/spy.mdl");
	LastSpawnDiversio = 0.0;
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Infected Spy");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_zs_zombie_spy");
	strcopy(data.Icon, sizeof(data.Icon), "Diversionistico");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_SUPPORT;
	data.Category = Type_GmodZS; 
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return ZsSpy(vecPos, vecAng, team, data);
}
methodmap ZsSpy < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayZapSound()
	{
		EmitSoundToAll(g_ZapAttackSounds[GetRandomInt(0, sizeof(g_ZapAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeBackstabSound(int target)
	{
		EmitSoundToAll(g_MeleeAttackBackstabSounds[GetRandomInt(0, sizeof(g_MeleeAttackBackstabSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		if(target <= MaxClients)
		{
			EmitSoundToClient(target, g_MeleeAttackBackstabSounds[GetRandomInt(0, sizeof(g_MeleeAttackBackstabSounds) - 1)], target, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		}
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}

	public ZsSpy(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		ZsSpy npc = view_as<ZsSpy>(CClotBody(vecPos, vecAng, "models/player/spy.mdl", "1.0", "5000", ally, false, false, true));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);
		func_NPCDeath[npc.index] = ZsSpy_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = ZsSpy_OnTakeDamage;
		func_NPCThink[npc.index] = ZsSpy_ClotThink;
		
		
		npc.StartPathing();
		npc.m_flSpeed = 280.0;
		b_TryToAvoidTraverse[npc.index] = true;
		DiversionSpawnNpcReset(npc.index);
		
		bool final = StrContains(data, "spy_duel") != -1;
		
		if(final)
		{
			i_RaidGrantExtra[npc.index] = 1;
		}
		
		int skin = 23;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_eternal_reward/c_eternal_reward.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/spy/spy_zombie.mdl");

		SetEntPropFloat(npc.index, Prop_Send, "m_fadeMinDist", 500.0);
		SetEntPropFloat(npc.index, Prop_Send, "m_fadeMaxDist", 750.0);

		SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_fadeMinDist", 500.0);
		SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_fadeMaxDist", 750.0);

		SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMinDist", 500.0);
		SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMaxDist", 750.0);

		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);

		if(ally != TFTeam_Red)
		{
			if(LastSpawnDiversio < GetGameTime())
			{
				EmitSoundToAll("player/spy_uncloak_feigndeath.wav", _, _, _, _, 1.0, 70);	
				EmitSoundToAll("player/spy_uncloak_feigndeath.wav", _, _, _, _, 1.0, 70);	
				for(int client_check=1; client_check<=MaxClients; client_check++)
				{
					if(IsClientInGame(client_check) && !IsFakeClient(client_check))
					{
						SetGlobalTransTarget(client_check);
						ShowGameText(client_check, "voice_player", 1, "%t", "Infected Spy Spawn");
					}
				}
			}
			LastSpawnDiversio = GetGameTime() + 20.0;
			TeleportDiversioToRandLocation(npc.index,_,_,750.0);
		}
		return npc;
	}
}

public void ZsSpy_ClotThink(int iNPC)
{
	ZsSpy npc = view_as<ZsSpy>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index, true);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		int AntiCheeseReply = 0;

		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3];
			b_TryToAvoidTraverse[npc.index] = false;
			PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
			vPredictedPos = GetBehindTarget(npc.m_iTarget, 40.0 ,vPredictedPos);
			AntiCheeseReply = DiversionAntiCheese(npc.m_iTarget, npc.index, vPredictedPos);
			b_TryToAvoidTraverse[npc.index] = true;
			if(AntiCheeseReply == 0)
			{
				if(!npc.m_bPathing)
					npc.StartPathing();

				npc.SetGoalVector(vPredictedPos, true);
			}
			else if(AntiCheeseReply == 1)
			{
				if(npc.m_bPathing)
					npc.StopPathing();
			}
		}
		else 
		{
			DiversionCalmDownCheese(npc.index);
			if(!npc.m_bPathing)
				npc.StartPathing();

			npc.SetGoalEntity(npc.m_iTarget);
		}
		switch(AntiCheeseReply)
		{
			case 0:
			{
				ZsSpySelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
			}
			case 1:
			{
				npc.m_flAttackHappens = 0.0;
				ZsSpySelfDefenseRanged(npc,GetGameTime(npc.index), npc.m_iTarget); 
			}
		}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index, true);
	}
	npc.PlayIdleAlertSound();
}

public Action ZsSpy_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	ZsSpy npc = view_as<ZsSpy>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;

	if(i_RaidGrantExtra[victim])
	{
		if(!i_HasBeenBackstabbed[victim])
		{
			damage = 0.0;
			return Plugin_Changed;
		}
	}

	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}

	
	return Plugin_Changed;
}

public void ZsSpy_NPCDeath(int entity)
{
	ZsSpy npc = view_as<ZsSpy>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

}
void ZsSpySelfDefenseRanged(ZsSpy npc, float gameTime, int target)
{
	float WorldSpaceVec[3]; WorldSpaceCenter(target, WorldSpaceVec);
	npc.FaceTowards(WorldSpaceVec, 15000.0);
	if(gameTime > npc.m_flNextRangedAttack)
	{
		npc.PlayZapSound();
		npc.AddGesture("ACT_MP_THROW");
		npc.m_flDoingAnimation = gameTime + 0.25;
		npc.m_flNextRangedAttack = gameTime + 1.2;
		float damageDealt = 85.0;
		SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, WorldSpaceVec);
		if(IsValidEntity(npc.m_iWearable2))
			RemoveEntity(npc.m_iWearable2);

		npc.m_iWearable5 = ConnectWithBeam(npc.m_iWearable1, target, 100, 100, 250, 3.0, 3.0, 1.35, LASERBEAM);
		CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(npc.m_iWearable5), TIMER_FLAG_NO_MAPCHANGE);
	}
}
void ZsSpySelfDefense(ZsSpy npc, float gameTime, int target, float distance)
{
	bool BackstabDone = false;
	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
		{
			int Enemy_I_See;					
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
			
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.PlayMeleeSound();
				if(i_RaidGrantExtra[npc.index])
				{
					if(Enemy_I_See <= MaxClients && b_FaceStabber[Enemy_I_See])
					{
						BackstabDone = true;
					}
				}
				if(BackstabDone || IsBehindAndFacingTarget(npc.index, npc.m_iTarget) && !NpcStats_IsEnemySilenced(npc.index))
				{
					BackstabDone = true;
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_SECONDARY");	
				}
				else
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
				}
				npc.m_flAttackHappens = 1.0;
				npc.m_flDoingAnimation = gameTime + 0.25;
				npc.m_flNextMeleeAttack = gameTime + 1.2;
			}
		}
	}
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget,_,_, _, _, 1)) //Ignore barricades
			{
				target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 75.0;

					if(BackstabDone)
					{
						if(i_RaidGrantExtra[npc.index])
						{
							if(target <= MaxClients && b_FaceStabber[target])
							{
								damageDealt *= 0.5;
							}
						}
						npc.PlayMeleeBackstabSound(target);
						damageDealt *= 3.0;
					}
					else if(i_RaidGrantExtra[npc.index])
					{
						damageDealt *= 0.5;
					}

					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);
					Elemental_AddPheromoneDamage(target, npc.index, npc.index ? 50 : 10);

					// Hit sound
					npc.PlayMeleeHitSound();
				} 
			}
			delete swingTrace;
		}
	}
}