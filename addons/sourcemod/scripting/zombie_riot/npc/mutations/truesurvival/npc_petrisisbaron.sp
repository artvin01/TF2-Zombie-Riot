#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"npc/dog/dog_scared1.wav",
};

static char g_HurtSounds[][] = {
	"npc/dog/dog_idle1.wav",
	"npc/dog/dog_idle2.wav",
	"npc/dog/dog_idle3.wav",
	"npc/dog/dog_idle4.wav",
	"npc/dog/dog_idle5.wav",
};

static const char g_IdleAlertedSounds[][] = {
	"npc/dog/dog_playfull1.wav",
	"npc/dog/dog_playfull2.wav",
	"npc/dog/dog_playfull3.wav",
	"npc/dog/dog_playfull4.wav",
	"npc/dog/dog_playfull5.wav",
};

static char g_MeleeAttackSounds[][] = {
	"npc/dog/dog_angry1.wav",
	"npc/dog/dog_angry2.wav",
};

static const char g_MeleeHitSounds[][] = {
	"npc/dog/dog_footstep_run1.wav",
	"npc/dog/dog_footstep_run2.wav",
	"npc/dog/dog_footstep_run3.wav",
	"npc/dog/dog_footstep_run4.wav",
	"npc/dog/dog_footstep_run5.wav",
	"npc/dog/dog_footstep_run6.wav",
	"npc/dog/dog_footstep_run7.wav",
	"npc/dog/dog_footstep_run8.wav",
};

static char g_MeleeMissSounds[][] = {
	"npc/scanner/scanner_nearmiss1.wav",
	"npc/scanner/scanner_nearmiss2.wav",
};

void PetrisBaron_OnMapStart_NPC()
{
	PrecacheModel("models/dog.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Petrisis' Baron");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_petrisisbaron");
	strcopy(data.Icon, sizeof(data.Icon), "tank");
	data.IconCustom = false;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Mutation;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	i++) { PrecacheSound(g_DeathSounds[i]);	}
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return PetrisBaron(vecPos, vecAng, team);
}
methodmap PetrisBaron < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(8.0, 16.0);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}

	public void PlayHurtSound() 
	{
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}

	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}

	public void PlayMeleeAttackSound() 
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}

	public void PlayMeleeMissSound() 
	{
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	
	public PetrisBaron(float vecPos[3], float vecAng[3], int ally)
	{
		PetrisBaron npc = view_as<PetrisBaron>(CClotBody(vecPos, vecAng, "models/dog.mdl", "1.0", "1000", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_WALK");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		SetEntityRenderColor(npc.index, 255, 0, 0, 255);
		func_NPCDeath[npc.index] = view_as<Function>(PetrisBaron_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(PetrisBaron_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(PetrisBaron_ClotThink);
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "voice_player", 1, "%t", "Petrisis' Baron Spawned");
				UTIL_ScreenFade(client_check, 180, 1, FFADE_OUT, 0, 0, 0, 255);
			}
		}
		
		
		
		npc.StartPathing();
		npc.m_flSpeed = 250.0;
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		

		npc.m_bDissapearOnDeath = false;
		
		return npc;
	}
}

public void PetrisBaron_ClotThink(int iNPC)
{
	PetrisBaron npc = view_as<PetrisBaron>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_BIG_FLINCH", false);
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
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3];
			PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}
		PetrisBaronSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action PetrisBaron_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PetrisBaron npc = view_as<PetrisBaron>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void PetrisBaron_NPCDeath(int entity)
{
	PetrisBaron npc = view_as<PetrisBaron>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
}

void PetrisBaronSelfDefense(PetrisBaron npc, float gameTime, int target, float distance)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;

			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			static float MaxVec[3] = {64.0 ,64.0, 128.0};
			static float MinVec[3] = {-64.0 ,-64.0, -128.0};

			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, MaxVec, MinVec)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
			{
				target = TR_GetEntityIndex(swingTrace);

				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);

				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 150.0;
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 50.0;
					if(i_IsABuilding[target])
					{
						float maxhealth = float(ReturnEntityMaxHealth(npc.index));
						maxhealth *= 1.0;
						HealEntityGlobal(npc.index, npc.index, maxhealth, 25000.0, 0.0, HEAL_SELFHEAL);
						float ProjLoc[3];
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", ProjLoc);
						ProjLoc[2] += 70.0;
						ProjLoc[0] += GetRandomFloat(-40.0, 40.0);
						ProjLoc[1] += GetRandomFloat(-40.0, 40.0);
						ProjLoc[2] += GetRandomFloat(-15.0, 15.0);
						TE_Particle("healthgained_blu", ProjLoc, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
					}

					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);

					// Hit sound
					npc.PlayMeleeHitSound();
				} 
			}
			delete swingTrace;
		}
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
		{
			int Enemy_I_See;

			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);

			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.AddGestureViaSequence("pound");

				npc.m_flAttackHappens = gameTime + 0.25;
				npc.m_flDoingAnimation = gameTime + 0.25;
				npc.m_flNextMeleeAttack = gameTime + 2.0;
			}
		}
	}
}