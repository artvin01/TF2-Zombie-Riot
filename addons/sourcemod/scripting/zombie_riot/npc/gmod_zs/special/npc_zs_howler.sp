#pragma semicolon 1
#pragma newdecls required
 
static const char g_DeathSounds[][] = {
	"npc/zombie/zombie_die1.wav",
	"npc/zombie/zombie_die2.wav",
	"npc/zombie/zombie_die3.wav",
};

static const char g_HurtSounds[][] = {
	"npc/zombie/zombie_pain1.wav",
	"npc/zombie/zombie_pain2.wav",
	"npc/zombie/zombie_pain3.wav",
	"npc/zombie/zombie_pain4.wav",
	"npc/zombie/zombie_pain5.wav",
	"npc/zombie/zombie_pain6.wav",
};

static const char g_IdleSounds[][] = {
	"npc/zombie/zombie_voice_idle1.wav",
	"npc/zombie/zombie_voice_idle2.wav",
	"npc/zombie/zombie_voice_idle3.wav",
	"npc/zombie/zombie_voice_idle4.wav",
	"npc/zombie/zombie_voice_idle5.wav",
	"npc/zombie/zombie_voice_idle6.wav",
	"npc/zombie/zombie_voice_idle7.wav",
	"npc/zombie/zombie_voice_idle8.wav",
	"npc/zombie/zombie_voice_idle9.wav",
	"npc/zombie/zombie_voice_idle10.wav",
	"npc/zombie/zombie_voice_idle11.wav",
	"npc/zombie/zombie_voice_idle12.wav",
	"npc/zombie/zombie_voice_idle13.wav",
	"npc/zombie/zombie_voice_idle14.wav",
};

static const char g_MeleeHitSounds[][] = {
	"npc/fast_zombie/claw_strike1.wav",
	"npc/fast_zombie/claw_strike2.wav",
	"npc/fast_zombie/claw_strike3.wav",
};
static const char g_MeleeAttackSounds[][] = {
	"npc/zombie/zo_attack1.wav",
	"npc/zombie/zo_attack2.wav",
};

static const char g_MeleeMissSounds[][] = {
	"npc/fast_zombie/claw_miss1.wav",
	"npc/fast_zombie/claw_miss2.wav",
};

static const char g_PlayHowlerWarCry[][] = {
	"zombiesurvival/medieval_raid/special_mutation/arkantos_scream_buff.mp3",
};

public void ZSHowler_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_PlayHowlerWarCry));		i++) { PrecacheSound(g_PlayHowlerWarCry[i]);		}
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }

	PrecacheSound("player/flow.wav");
	PrecacheModel("models/zombie_riot/gmod_zs/zs_zombie_models_1_1.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "ZS Howler");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_zs_howler");
	strcopy(data.Icon, sizeof(data.Icon), "gmod_zs_howler");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_GmodZS;
	data.Func = ClotSummon;
	NPC_Add(data);
}
#define ZSHOWLER_BUFF_MAXRANGE 500.0

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return ZSHowler(vecPos, vecAng, team);
}

methodmap ZSHowler < CClotBody
{
	property float m_flZSHowlerBuffEffect
	{
		public get()							{ return fl_AttackHappensMaximum[this.index]; }
		public set(float TempValueForProperty) 	{ fl_AttackHappensMaximum[this.index] = TempValueForProperty; }
	}
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
	}
	public void PlayHowlerWarCry() 
	{
		EmitSoundToAll(g_PlayHowlerWarCry[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public ZSHowler(float vecPos[3], float vecAng[3], int ally)
	{
		ZSHowler npc = view_as<ZSHowler>(CClotBody(vecPos, vecAng, "models/zombie_riot/gmod_zs/zs_zombie_models_1_1.mdl", "1.75", "15000", ally, false));
		
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_HL2MP_RUN_ZOMBIE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/zombie_riot/gmod_zs/zs_zombie_models_1_1.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		npc.m_flRangedArmor = 0.6;
		
		
		npc.m_flZSHowlerBuffEffect = GetGameTime() + 7.0;
		npc.m_flSpeed = 320.0;
		func_NPCDeath[npc.index] = ZSHowler_NPCDeath;
		func_NPCThink[npc.index] = ZSHowler_ClotThink;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;

		npc.StartPathing();
		
		return npc;
	}
}

public void ZSHowler_ClotThink(int iNPC)
{
    ZSHowler npc = view_as<ZSHowler>(iNPC);
    
    SetEntProp(npc.index, Prop_Send, "m_nBody", GetEntProp(npc.index, Prop_Send, "m_nBody"));
    SetVariantInt(32); 
    AcceptEntityInput(iNPC, "SetBodyGroup");

    if(IsValidEntity(npc.m_iWearable1))
    {
        SetEntProp(npc.m_iWearable1, Prop_Send, "m_nBody", 64);
    }
    
    float gameTime = GetGameTime(iNPC);

	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.1;


	if(i_ClosestAllyCD[npc.index] < GetGameTime())
	{
		i_ClosestAllyCD[npc.index] = GetGameTime() + 1.0;
		i_ClosestAlly[npc.index] = GetClosestAlly(npc.index);			
	}


	int Behavior = -1;
	if(IsValidAlly(npc.index, i_ClosestAlly[npc.index]))
	{
		Behavior = 1; //We go to the closest ally, and support them in battle!
	}
	else //Current ally died, find a new one to help.
	{
		i_ClosestAlly[npc.index] = GetClosestAlly(npc.index);	
		
		if(IsValidAlly(npc.index, i_ClosestAlly[npc.index]))
		{
			Behavior = 1; //We go to the closest ally, and support them in battle!
		}
		else
		{
			Behavior = 0; //No ally left, attack!
		}
	}

	switch(Behavior)
	{
		case 0:
		{
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
				
				float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
				float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
					
				//Predict their pos.
				if(flDistanceToTarget < npc.GetLeadRadius()) 
				{
					float vPredictedPos[3]; PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
					npc.SetGoalVector(vPredictedPos);
				}
				else 
				{
					npc.SetGoalEntity(npc.m_iTarget);
				}
				if(npc.m_iChanged_WalkCycle != 4) 	
				{
					npc.m_flSpeed = 350.0;
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_HL2MP_RUN_ZOMBIE");
				}
				npc.StartPathing(); //Charge at them!
			}
			else
			{
				view_as<CClotBody>(iNPC).StopPathing();
				npc.m_iTarget = GetClosestTarget(npc.index); //Find new target instantly.
			}
		}
		case 1:
		{
			float flDistanceToTarget;
			if(i_ClosestAllyCDTarget[npc.index] < GetGameTime(npc.index))
			{
				i_ClosestAllyTarget[npc.index] = GetClosestTarget(i_ClosestAlly[npc.index], true, 200.0);
				i_ClosestAllyCDTarget[npc.index] = GetGameTime(npc.index) + 1.0;
			}
			if(IsValidEnemy(npc.index, i_ClosestAllyTarget[npc.index]))
			{
				float vecTarget[3]; WorldSpaceCenter(i_ClosestAllyTarget[npc.index], vecTarget );
				
				float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
				flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
					
				//Predict their pos.
				if(flDistanceToTarget < npc.GetLeadRadius()) 
				{
					float vPredictedPos[3];  PredictSubjectPosition(npc, i_ClosestAllyTarget[npc.index],_,_,vPredictedPos);
					npc.SetGoalVector(vPredictedPos);
				}
				else 
				{
					npc.SetGoalEntity(i_ClosestAllyTarget[npc.index]);
				}
				if(npc.m_iChanged_WalkCycle != 4) 	
				{
					npc.m_flSpeed = 350.0;
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_HL2MP_RUN_ZOMBIE");
				}
				npc.StartPathing(); //Charge at them!
			}
			else
			{
				float WorldSpaceVec[3]; WorldSpaceCenter(i_ClosestAlly[npc.index], WorldSpaceVec);
				float WorldSpaceVec2[3]; WorldSpaceCenter(npc.index, WorldSpaceVec2);
				flDistanceToTarget = GetVectorDistance(WorldSpaceVec, WorldSpaceVec2, true);
				if(flDistanceToTarget < (125.0* 125.0) && Can_I_See_Ally(npc.index, i_ClosestAlly[npc.index])) //make sure we can also see them for no unfair bs
				{
					if(npc.m_iChanged_WalkCycle != 5)
					{
						npc.m_flSpeed = 0.0;
						npc.m_iChanged_WalkCycle = 5;
						npc.SetActivity("ACT_HL2MP_RUN_ZOMBIE");
						view_as<CClotBody>(iNPC).StopPathing();
					}
				}
				else
				{
					float AproxRandomSpaceToWalkTo[3];
					GetEntPropVector(i_ClosestAlly[npc.index], Prop_Data, "m_vecAbsOrigin", AproxRandomSpaceToWalkTo);
					view_as<CClotBody>(iNPC).SetGoalVector(AproxRandomSpaceToWalkTo);
					view_as<CClotBody>(iNPC).StartPathing();
					if(npc.m_iChanged_WalkCycle != 4) 	
					{
						npc.m_flSpeed = 350.0;
						npc.m_iChanged_WalkCycle = 4;
						npc.SetActivity("ACT_HL2MP_RUN_ZOMBIE");
					}		
				}
			}
		}
	}

	ZSHowlerSelfDefense(npc,GetGameTime(npc.index));
	ZSHowlerAOEBuff(npc,GetGameTime(npc.index));

	npc.PlayIdleSound();
}
void ZSHowlerAOEBuff(ZSHowler npc, float gameTime, bool mute = false)
{
	float pos1[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos1);
	if(npc.m_flZSHowlerBuffEffect < gameTime)
	{
		bool buffed_anyone;
		bool buffedAlly = false;
		for(int entitycount; entitycount<MAXENTITIES; entitycount++) //Check for npcs
		{
			if(IsValidEntity(entitycount) && entitycount != npc.index && (entitycount <= MaxClients || !b_NpcHasDied[entitycount])) //Cannot buff self like this.
			{
				if(GetEntProp(entitycount, Prop_Data, "m_iTeamNum") == GetEntProp(npc.index, Prop_Data, "m_iTeamNum") && IsEntityAlive(entitycount))
				{
					static float pos2[3];
					GetEntPropVector(entitycount, Prop_Data, "m_vecAbsOrigin", pos2);
					if(GetVectorDistance(pos1, pos2, true) < (ZSHOWLER_BUFF_MAXRANGE * ZSHOWLER_BUFF_MAXRANGE))
					{
						ApplyStatusEffect(npc.index, entitycount, "War Cry", 10.0);
						//Buff this entity.
						buffed_anyone = true;	
						if(entitycount != npc.index)
						{
							buffedAlly = true;
						}
					}
				}
			}
		}
		if(npc.Anger)
			buffed_anyone = true;

		if(buffed_anyone)
		{
			if(buffedAlly)

			npc.m_flZSHowlerBuffEffect = gameTime + 10.0;
			if(!NpcStats_IsEnemySilenced(npc.index))
			{
				ApplyStatusEffect(npc.index, npc.index, "War Cry", 5.0);
			}
			else
			{
				ApplyStatusEffect(npc.index, npc.index, "War Cry", 3.0);
			}
			static int r;
			static int g;
			static int b ;
			static int a = 255;
			if(GetTeam(npc.index) != TFTeam_Red)
			{
				r = 220;
				g = 220;
				b = 255;
			}
			else
			{
				r = 255;
				g = 125;
				b = 125;
			}
			static float UserLoc[3];
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", UserLoc);
			spawnRing(npc.index, ALAXIOS_BUFF_MAXRANGE * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 1.0, 6.0, 6.1, 1);
			spawnRing_Vectors(UserLoc, 0.0, 0.0, 5.0, 0.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.75, 12.0, 6.1, 1, ALAXIOS_BUFF_MAXRANGE * 2.0);		
			npc.AddGestureViaSequence("g_wave");
			if(!mute)
			{
				spawnRing(npc.index, ZSHOWLER_BUFF_MAXRANGE * 2.0, 0.0, 0.0, 25.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.8, 6.0, 6.1, 1);
				spawnRing(npc.index, ZSHOWLER_BUFF_MAXRANGE * 2.0, 0.0, 0.0, 35.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.7, 6.0, 6.1, 1);
				npc.PlayHowlerWarCry();
			}
		}
		else
		{
			npc.m_flZSHowlerBuffEffect = gameTime + 1.0; //Try again in a second.
		}
	}
}
void ZSHowlerSelfDefense(ZSHowler npc, float gameTime)
{
	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;

	//This code is only here so they defend themselves incase any enemy is too close to them. otherwise it is completly disconnected from any other logic.

	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < GetGameTime(npc.index))
		{
			npc.m_flAttackHappens = 0.0;
			
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				Handle swingTrace;
				float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
				npc.FaceTowards(VecEnemy, 15000.0);
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 0)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					float damage = 120.0;


					if(target > MaxClients)
					{
						damage *= 5.0;
					}

					npc.PlayMeleeHitSound();

					if(target > 0) 
					{
						SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);
					}
				}
				delete swingTrace;
			}
		}
	}

	if(GetGameTime(npc.index) > npc.m_flNextMeleeAttack)
	{
		if(IsValidEnemy(npc.index, PrimaryThreatIndex)) 
		{
			float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);

			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);

			if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED)
			{
				int Enemy_I_See;
									
				Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
						
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;

					npc.PlayMeleeSound();

					npc.AddGesture("ACT_GMOD_GESTURE_RANGE_ZOMBIE");
							
					npc.m_flAttackHappens = gameTime + 0.4;

					npc.m_flDoingAnimation = gameTime + 0.6;
					npc.m_flNextMeleeAttack = gameTime + 1.2;
				}
			}
		}
		else
		{
			
			npc.m_flGetClosestTargetTime = 0.0;
			npc.m_iTarget = GetClosestTarget(npc.index);
		}	
	}
}
public void ZSHowler_NPCDeath(int entity)
{
	ZSHowler npc = view_as<ZSHowler>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}