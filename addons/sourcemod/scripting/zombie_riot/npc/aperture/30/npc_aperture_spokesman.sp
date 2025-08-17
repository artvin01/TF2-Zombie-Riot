#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/spy_paincrticialdeath01.mp3",
	"vo/spy_paincrticialdeath02.mp3",
	"vo/spy_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/spy_painsharp01.mp3",
	"vo/spy_painsharp02.mp3",
	"vo/spy_painsharp03.mp3",
	"vo/spy_painsharp04.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/spy_laughshort01.mp3",
	"vo/spy_laughshort02.mp3",
	"vo/spy_laughshort03.mp3",
	"vo/spy_laughshort04.mp3",
	"vo/spy_laughshort05.mp3",
	"vo/spy_laughshort06.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/knife_swing.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/blade_hit1.wav",
	"weapons/blade_hit2.wav",
	"weapons/blade_hit3.wav",
	"weapons/blade_hit4.wav",
};

void ApertureSpokesman_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	PrecacheModel("models/player/spy.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Aperture Spokesman");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_aperture_spokesman");
	strcopy(data.Icon, sizeof(data.Icon), "spy");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Aperture;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return ApertureSpokesman(vecPos, vecAng, ally);
}
methodmap ApertureSpokesman < CClotBody
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
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);

	}
	property float m_flRecheckIfAlliesDead
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	
	
	public ApertureSpokesman(float vecPos[3], float vecAng[3], int ally)
	{
		ApertureSpokesman npc = view_as<ApertureSpokesman>(CClotBody(vecPos, vecAng, "models/player/spy.mdl", "1.0", "700", ally));
		
		i_NpcWeight[npc.index] = 2;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(ApertureSpokesman_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(ApertureSpokesman_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(ApertureSpokesman_ClotThink);
		
		
		//IDLE
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 300.0;
				
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_ava_roseknife/c_ava_roseknife.mdl");
	
		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/spy/hardhat.mdl");

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/spy/spr18_assassins_attire/spr18_assassins_attire.mdl");

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		
		return npc;
	}
}

public void ApertureSpokesman_ClotThink(int iNPC)
{
	float gameTime = GetGameTime();
	ApertureSpokesman npc = view_as<ApertureSpokesman>(iNPC);

	//Check if every npc except myself is dead, if yes, get insane buffs like lost knight
	if(npc.m_flRecheckIfAlliesDead < GetGameTime())
	{
		if(!IsValidAlly(npc.index, GetClosestAlly(npc.index)))
		{
			npc.m_flSpeed = 400.0;
			float DurationGive = 9999.0;
			npc.m_flMeleeArmor = 0.50;
			npc.m_flRangedArmor = 0.50;
			ApplyStatusEffect(npc.index, npc.index, "Combine Command", DurationGive);
			ApplyStatusEffect(npc.index, npc.index, "War Cry", DurationGive);
			ApplyStatusEffect(npc.index, npc.index, "Defensive Backup", DurationGive);
			ApplyStatusEffect(npc.index, npc.index, "Godly Motivation", DurationGive);
			ApplyStatusEffect(npc.index, npc.index, "False Therapy", DurationGive);
			ApplyStatusEffect(npc.index, npc.index, "Hussar's Warscream", DurationGive);
		}
	}

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

	//Apply buffs *only* to bosses, not normal enemies
	if(npc.m_flNextRangedSpecialAttack < gameTime)
	{
		npc.m_flNextRangedSpecialAttack = gameTime + 0.10;
		
		int target = GetClosestAlly(npc.index, (500.0 * 500.0), _);
		if(target && b_thisNpcIsABoss[target])
		{
			if(!HasSpecificBuff(target, "Dimensional Turbulence"))
			{
				ApplyStatusEffect(npc.index, target, "Dimensional Turbulence", 30.0);
				npc.AddGesture("ACT_MP_GESTURE_VC_FINGERPOINT_SECONDARY",_,_,_,3.0);
			}
		}
		if(target && !b_thisNpcIsABoss[target])
		{
			if(!HasSpecificBuff(target, "Very Defensive Backup"))
			{
				ApplyStatusEffect(npc.index, target, "Very Defensive Backup", 15.0);
				npc.AddGesture("ACT_MP_GESTURE_VC_FINGERPOINT_SECONDARY",_,_,_,3.0);
			}
		}
	}
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;
	
	//Code to have this man follow other NPCs
	if(npc.m_iTargetAlly && !IsValidAlly(npc.index, npc.m_iTargetAlly))
		npc.m_iTargetAlly = 0;
	
	if(!npc.m_iTargetAlly || npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTargetAlly = GetClosestAlly(npc.index);
		if(npc.m_iTargetAlly < 1)
		{
			npc.m_iTargetAlly = GetClosestTarget(npc.index);
		}
		
		if(npc.m_iTargetAlly > 0)
		{
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTargetAlly, vecTarget );
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			
			if(flDistanceToTarget > (25.0*25.0))
			{
				npc.StartPathing();
				if(flDistanceToTarget < npc.GetLeadRadius()) 
				{
					float vPredictedPos[3]; PredictSubjectPosition(npc, npc.m_iTargetAlly,_,_,vPredictedPos );
					npc.SetGoalVector(vPredictedPos);
				}
				else 
				{
					npc.SetGoalEntity(npc.m_iTargetAlly);
				}
			}
			else
			{
				npc.StopPathing();
			}
		}
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 0.5;
	}
	//Following ends here

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
		ApertureSpokesmanSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action ApertureSpokesman_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	ApertureSpokesman npc = view_as<ApertureSpokesman>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void ApertureSpokesman_NPCDeath(int entity)
{
	ApertureSpokesman npc = view_as<ApertureSpokesman>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
	
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

}

void ApertureSpokesmanSelfDefense(ApertureSpokesman npc, float gameTime, int target, float distance)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
			{
							
				target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 200.0;
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 7.5;

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
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
						
				npc.m_flAttackHappens = gameTime + 0.25;
				npc.m_flDoingAnimation = gameTime + 0.25;
				npc.m_flNextMeleeAttack = gameTime + 0.5;
			}
		}
	}
}