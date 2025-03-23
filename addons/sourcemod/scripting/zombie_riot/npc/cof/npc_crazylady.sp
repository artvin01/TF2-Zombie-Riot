#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"cof/runningcrazy/crazylady_death1.mp3",
};

static const char g_HurtSounds[][] = {
	"cof/runningcrazy/crazylady_pain1.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"cof/runningcrazy/crazylady_alert1.mp3",
	"cof/runningcrazy/crazylady_alert2.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"cof/runningcrazy/crazylady_attack1.mp3",
	"cof/runningcrazy/crazylady_attack2.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"cof/runningcrazy/crazylady_hit1.mp3",
	"cof/runningcrazy/crazylady_hit2.mp3",
};

static float fl_DefaultSpeed_Crazylady = 300.0;
static float fl_DefaultSpeed_Crazylady_Nightmare = 320.0;
static bool b_IsNightmare[MAXENTITIES];

void Crazylady_OnMapStart_NPC()
{
	PrecacheModel("models/zombie_riot/cof/runningcrazy.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Crazy Lady");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_crazylady");
	strcopy(data.Icon, sizeof(data.Icon), "crazylady");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_COF;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	i++) { PrecacheSoundCustom(g_DeathSounds[i]);	}
	for (int i = 0; i < (sizeof(g_HurtSounds));	i++) { PrecacheSoundCustom(g_HurtSounds[i]);	}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSoundCustom(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSoundCustom(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSoundCustom(g_MeleeHitSounds[i]); }
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Crazylady(vecPos, vecAng, team, data);
}
methodmap Crazylady < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;

		EmitCustomToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 2.0;
		
		EmitCustomToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayDeathSound() 
	{
		EmitCustomToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound()
	{
		EmitCustomToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitCustomToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}

		property bool b_Nightmare
	{
		public get()		{ return b_IsNightmare[this.index]; }
		public set(bool value) 	{ b_IsNightmare[this.index] = value; }
	}
	
	
	public Crazylady(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Crazylady npc = view_as<Crazylady>(CClotBody(vecPos, vecAng, "models/zombie_riot/cof/runningcrazy.mdl", "1.10", "300", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_WALK");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(Crazylady_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Crazylady_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Crazylady_ClotThink);
		npc.b_Nightmare = false;

		bool nightmare = StrContains(data, "nightmare") != -1;
		if(nightmare)
		{
			npc.b_Nightmare = true;
			npc.m_flSpeed = fl_DefaultSpeed_Crazylady_Nightmare;
		}
		else
		{
			npc.m_flSpeed = fl_DefaultSpeed_Crazylady;
		}
		
		
		npc.StartPathing();
		npc.m_flSpeed = 300.0;

		npc.m_bDissapearOnDeath = true;
		
		return npc;
	}
}

public void Crazylady_ClotThink(int iNPC)
{
	Crazylady npc = view_as<Crazylady>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		//npc.AddGesture("ACT_BIG_FLINCH", false);
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
			NPC_SetGoalVector(npc.index, vPredictedPos);
		}
		else 
		{
			NPC_SetGoalEntity(npc.index, npc.m_iTarget);
		}
		CrazyladySelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action Crazylady_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Crazylady npc = view_as<Crazylady>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void Crazylady_NPCDeath(int entity)
{
	Crazylady npc = view_as<Crazylady>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

	int entity_death = CreateEntityByName("prop_dynamic_override");
	if(IsValidEntity(entity_death))
	{
		float pos[3];
		float Angles[3];
		GetEntPropVector(entity, Prop_Data, "m_angRotation", Angles);

		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
		TeleportEntity(entity_death, pos, Angles, NULL_VECTOR);
		
		//GetEntPropString(client, Prop_Data, "m_ModelName", model, sizeof(model));
		DispatchKeyValue(entity_death, "model", "models/zombie_riot/cof/runningcrazy.mdl");

		DispatchSpawn(entity_death);
		
		SetEntPropFloat(entity_death, Prop_Send, "m_flModelScale", 1.10); 
		SetEntityCollisionGroup(entity_death, 2);
		SetVariantString("diesimple");
		AcceptEntityInput(entity_death, "SetAnimation");
		
		pos[2] += 20.0;
		
		CreateTimer(1.0, Timer_RemoveEntityCrazylady, EntIndexToEntRef(entity_death), TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action Timer_RemoveEntityCrazylady(Handle timer, any entid)
{
	int entity = EntRefToEntIndex(entid);
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		float pos[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
		TE_Particle("env_sawblood", pos, NULL_VECTOR, NULL_VECTOR, entity, _, _, _, _, _, _, _, _, _, 0.0);
		//TeleportEntity(entity, OFF_THE_MAP, NULL_VECTOR, NULL_VECTOR); // send it away first in case it feels like dying dramatically
		RemoveEntity(entity);
	}
	return Plugin_Handled;
}

void CrazyladySelfDefense(Crazylady npc, float gameTime, int target, float distance)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;

			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			static float MaxVec[3] = {128.0, 128.0, 128.0};
			static float MinVec[3] = {-128.0, -128.0, -128.0};

			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, MaxVec, MinVec)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
			{
				target = TR_GetEntityIndex(swingTrace);

				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);

				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 30.0;
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 5.0;


					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);
					if(npc.b_Nightmare)
					{
						if(target <= MaxClients)
							if(!HasSpecificBuff(target, "Fluid Movement"))
								TF2_StunPlayer(target, 1.5, 0.9, Rogue_Paradox_RedMoon() ? TF_STUNFLAGS_LOSERSTATE : TF_STUNFLAG_SLOWDOWN);
					}
					else
					{
						if(target <= MaxClients)
							if(!HasSpecificBuff(target, "Fluid Movement"))
								TF2_StunPlayer(target, 0.8, 0.9, Rogue_Paradox_RedMoon() ? TF_STUNFLAGS_LOSERSTATE : TF_STUNFLAG_SLOWDOWN);
					}

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
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_MELEE_ATTACK1");
				
				npc.m_flAttackHappens = gameTime + 0.25;
				npc.m_flDoingAnimation = gameTime + 0.25;
				npc.m_flNextMeleeAttack = gameTime + 1.2;
			}
		}
	}
}