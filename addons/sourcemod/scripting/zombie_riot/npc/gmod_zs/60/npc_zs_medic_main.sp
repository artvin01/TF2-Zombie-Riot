#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/medic_negativevocalization01.mp3",
	"vo/medic_negativevocalization02.mp3",
	"vo/medic_negativevocalization03.mp3",
	"vo/medic_negativevocalization04.mp3"
};

static const char g_HurtSounds[][] = {
	")vo/medic_painsharp01.mp3",
	")vo/medic_painsharp02.mp3",
	")vo/medic_painsharp03.mp3",
	")vo/medic_painsharp04.mp3"
};

static const char g_IdleAlertedSounds[][] = {
	")vo/medic_specialcompleted01.mp3",
	")vo/medic_specialcompleted02.mp3",
	")vo/medic_specialcompleted03.mp3",
	")vo/medic_specialcompleted04.mp3",
	")vo/medic_specialcompleted05.mp3",
	")vo/medic_specialcompleted06.mp3",
	")vo/medic_specialcompleted07.mp3",
	")vo/medic_specialcompleted08.mp3",
	")vo/medic_specialcompleted09.mp3",
	")vo/medic_specialcompleted10.mp3",
	")vo/medic_specialcompleted11.mp3",
	")vo/medic_specialcompleted12.mp3"
};

static const char g_MeleeHitSounds[][] = {
	")weapons/ubersaw_hit1.wav",
	")weapons/ubersaw_hit2.wav",
	")weapons/ubersaw_hit3.wav",
	")weapons/ubersaw_hit4.wav"
};

static const char g_MeleeAttackSounds[] = "weapons/knife_swing.wav";

static const char g_FuckyouSounds[][] = {
	"vo/taunts/medic_taunts05.mp3",
	"vo/taunts/medic_taunts06.mp3",
	"vo/taunts/medic_taunts12.mp3",
	"vo/taunts/medic_taunts14.mp3",
	"vo/taunts/medic_taunts15.mp3"
};


void InfectedBattleMedic_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Infected Battle Medic");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_zs_medic_main");
	strcopy(data.Icon, sizeof(data.Icon), "medic_main");
	data.IconCustom = true;
	data.Flags = 0;
	data.Precache = ClotPrecache;
	data.Category = Type_Common;
	data.Func = ClotSummon;
	NPC_Add(data);
}
static void ClotPrecache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_FuckyouSounds);
	PrecacheSound(g_MeleeAttackSounds);
	PrecacheModel("models/player/medic.mdl");
	PrecacheSound("player/flow.wav");
	PrecacheModel(LASERBEAM);
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return InfectedBattleMedic(vecPos, vecAng, team);
}

methodmap InfectedBattleMedic < CClotBody
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
		EmitSoundToAll(g_MeleeAttackSounds, this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeMissSound()
	{
		EmitSoundToAll(g_DefaultMeleeMissSounds[GetRandomInt(0, sizeof(g_DefaultMeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayFuckyouSound()
	{
		if(this.m_flFuckDelaySound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_FuckyouSounds[GetRandomInt(0, sizeof(g_FuckyouSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flFuckDelaySound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	
	property float m_flFuckDelaySound
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	
	
	
	public InfectedBattleMedic(float vecPos[3], float vecAng[3], int ally)
	{
		InfectedBattleMedic npc = view_as<InfectedBattleMedic>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "25000", ally));
		
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = InfectedBattleMedic_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = InfectedBattleMedic_OnTakeDamage;
		func_NPCThink[npc.index] = InfectedBattleMedic_ClotThink;
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_flSpeed = 300.0;
		npc.m_iWearable5 = INVALID_ENT_REFERENCE;
		Is_a_Medic[npc.index] = true;
		npc.m_bFUCKYOU = false;
		npc.m_bFUCKYOU_move_anim = false;
		npc.m_flFuckDelaySound = 0.0;
		
		npc.m_bnew_target = false;
		npc.StartPathing();
		//IDLE
		
		int skin = 5;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/player/items/medic/medic_zombie.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/medic/dec15_berlin_brain_bowl/dec15_berlin_brain_bowl.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/weapons/c_models/c_medigun/c_medigun.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/medic/cc_summer2015_the_vascular_vestment/cc_summer2015_the_vascular_vestment.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/medic/cardiologists_camo/cardiologists_camo.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", 1);
		npc.StartPathing();
		
		return npc;
	}
	public void StartHealing()
	{
		if(IsValidEntity(this.m_iWearable4))
			this.Healing = true;
	}	
	public void StopHealing()
	{
		int iBeam = this.m_iWearable4;
		if(IsValidEntity(iBeam))
		{
			AcceptEntityInput(iBeam, "ClearParent");
			RemoveEntity(iBeam);
			
			EmitSoundToAll("weapons/medigun_no_target.wav", this.index, SNDCHAN_WEAPON);
			
			this.Healing = false;
		}
	}
	
	
}

static void InfectedBattleMedic_ClotThink(int iNPC)
{
	InfectedBattleMedic npc = view_as<InfectedBattleMedic>(iNPC);
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
		return;
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
		return;
	
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;
	
	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = (npc.m_bFUCKYOU ? GetClosestTarget(npc.index) : GetClosestAlly(npc.index));
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + (npc.m_bFUCKYOU ? GetRandomRetargetTime() : 5000.0);
	}
	if(IsValidAlly(npc.index, npc.m_iTarget) && Is_a_Medic[npc.m_iTarget])
	{
		npc.StopHealing();
		npc.Healing = false;
		npc.m_bnew_target = false;
		npc.m_flGetClosestTargetTime = 5000.0;
		npc.m_iTarget = GetClosestAlly(npc.index);
	}
	
	bool GotoWork;
	if(!npc.m_bFUCKYOU&&IsValidAlly(npc.index, npc.m_iTarget))
		GotoWork=true;
	else if(npc.m_bFUCKYOU&&IsValidAlly(npc.index, GetClosestAlly(npc.index)))
	{
		if(IsValidEntity(npc.m_iWearable3))
			RemoveEntity(npc.m_iWearable3);
			
		npc.m_iWearable3 = npc.EquipItem("head", "models/weapons/c_models/c_medigun/c_medigun.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
			
		npc.StopHealing();
		npc.Healing = false;
		npc.m_bnew_target = false;
		npc.m_bFUCKYOU = false;
		npc.m_flGetClosestTargetTime = 5000.0;
		npc.m_iTarget = GetClosestAlly(npc.index);
	}
	else if(!npc.m_bFUCKYOU)
	{
		if(IsValidEntity(npc.m_iWearable3))
			RemoveEntity(npc.m_iWearable3);
			
		npc.m_iWearable3 = npc.EquipItem("head", "models/weapons/c_models/c_ubersaw/c_ubersaw.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		SetEntityRenderColor(npc.m_iWearable3, 255, 0, 0, 255);
			
		npc.StopHealing();
		npc.Healing = false;
		npc.m_bnew_target = false;
		npc.m_bFUCKYOU = true;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.PlayFuckyouSound();
	}
	
	float vecTarget[3];
	if(GotoWork||(npc.m_bFUCKYOU&&IsValidEnemy(npc.index, npc.m_iTarget)))
	{
		WorldSpaceCenter(npc.m_iTarget, vecTarget);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		
		switch(InfectedBattleMedic_Work(npc, GetGameTime(npc.index), flDistanceToTarget))
		{
			case 0:
			{
				if(npc.m_iChanged_WalkCycle != 0)
				{
					npc.StartPathing();
					npc.m_bisWalking = true;
					npc.SetActivity("ACT_MP_RUN_SECONDARY");
					npc.m_flSpeed = 300.0;
					npc.m_iChanged_WalkCycle = 0;
				}
				if(flDistanceToTarget < npc.GetLeadRadius())
				{
					float vPredictedPos[3]; PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
					npc.SetGoalVector(vPredictedPos);
				}
				else
					npc.SetGoalEntity(npc.m_iTarget);
			}
			case 1:
			{
				if(npc.m_iChanged_WalkCycle != 1)
				{
					npc.StopPathing();
					npc.m_bisWalking = false;
					npc.SetActivity("ACT_MP_STAND_SECONDARY");
					npc.m_flSpeed = 0.0;
					npc.m_iChanged_WalkCycle = 1;
				}
			}
			case 2:
			{
				if(npc.m_iChanged_WalkCycle != 2)
				{
					npc.StartPathing();
					npc.m_bisWalking = true;
					npc.SetActivity("ACT_MP_RUN_MELEE");
					npc.m_flSpeed = 450.0;
					npc.m_iChanged_WalkCycle = 2;
				}
				if(flDistanceToTarget < npc.GetLeadRadius())
				{
					float vPredictedPos[3]; PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
					npc.SetGoalVector(vPredictedPos);
				}
				else
					npc.SetGoalEntity(npc.m_iTarget);
			}
			case 3:
			{
				if(npc.m_iChanged_WalkCycle != 3)
				{
					npc.StopPathing();
					npc.m_bisWalking = false;
					npc.SetActivity("ACT_MP_STAND_MELEE");
					npc.m_flSpeed = 0.0;
					npc.m_iChanged_WalkCycle = 3;
				}
			}
		}
	}
	else
		npc.m_flGetClosestTargetTime=0.0;
	npc.PlayIdleAlertSound();
}

static Action InfectedBattleMedic_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &m_iWearable3, float damageForce[3], float damagePosition[3], int damagecustom)
{
	InfectedBattleMedic npc = view_as<InfectedBattleMedic>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void InfectedBattleMedic_NPCDeath(int entity)
{
	InfectedBattleMedic npc = view_as<InfectedBattleMedic>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	Is_a_Medic[npc.index] = false;
	npc.StopHealing();
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

static int InfectedBattleMedic_Work(InfectedBattleMedic npc, float gameTime, float distance)
{
	if(npc.m_bFUCKYOU)
	{
		if(npc.m_flNextRangedAttack < gameTime)
		{
			ExpidonsaGroupHeal(npc.index, 200.0, 5, 2500.0, 0.0, false,Expidonsa_DontHealSameIndex);
			DesertYadeamDoHealEffect(npc.index, 200.0);
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			for(int entitycount; entitycount<MAXENTITIES; entitycount++) //Check for npcs
			{
				if(IsValidEntity(entitycount) && entitycount != npc.index && (!b_NpcHasDied[entitycount])) //Cannot buff self like this.
				{
					if(GetTeam(entitycount) == GetTeam(npc.index) && IsEntityAlive(entitycount))
					{
						static float vecTarget[3]; WorldSpaceCenter(entitycount, vecTarget);
						if(GetVectorDistance(VecSelfNpc, vecTarget, true) < (200.0 * 200.0))
						{
							ApplyStatusEffect(npc.index, entitycount, "Oceanic Scream", 1.1);
							if(NpcStats_VictorianCallToArms(npc.index))
								ApplyStatusEffect(npc.index, entitycount, "War Cry", 1.1);
						}
					}
				}
			}
			npc.m_flNextRangedAttack = gameTime + 2.5;
		}
	
		if(distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
		{
			if(npc.m_flNextMeleeAttack < gameTime)
			{
				if(!npc.m_flAttackHappenswillhappen)
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
					npc.PlayMeleeSound();
					npc.m_flAttackHappens = gameTime+0.4;
					npc.m_flAttackHappens_bullshit = gameTime+0.54;
					npc.m_flAttackHappenswillhappen = true;
				}
				if(npc.m_flAttackHappens < gameTime && npc.m_flAttackHappens_bullshit >= gameTime && npc.m_flAttackHappenswillhappen)
				{
					Handle swingTrace;
					float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
					npc.FaceTowards(vecTarget, 20000.0);
					if(npc.DoSwingTrace(swingTrace, npc.m_iTarget))
					{
						int target = TR_GetEntityIndex(swingTrace);	
						
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);
						
						if(IsValidEnemy(npc.index, target))
						{
							float damageDealt = 100.0;
							if(ShouldNpcDealBonusDamage(target))
								damageDealt*=3.0;
							SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);
							npc.PlayMeleeHitSound();
							if(!IsValidEnemy(npc.index, target))
							{
								npc.m_flGetClosestTargetTime=0.0;
								npc.m_flNextMeleeAttack = gameTime + 0.6;
								npc.m_flAttackHappenswillhappen = false;
								return 3;
							}
						} 
					}
					delete swingTrace;
					npc.m_flNextMeleeAttack = gameTime + 0.6;
					npc.m_flAttackHappenswillhappen = false;
				}
				else if(npc.m_flAttackHappens_bullshit < gameTime && npc.m_flAttackHappenswillhappen)
				{
					npc.m_flAttackHappenswillhappen = false;
					npc.m_flNextMeleeAttack = gameTime + 0.6;
				}
			}
		}
		return 2;
	}
	else
	{
		if(IsValidAlly(npc.index, npc.m_iTarget))
		{
			if(distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*14.8 && Can_I_See_Ally(npc.index, npc.m_iTarget))
			{
				if(!npc.m_bnew_target)
				{
					npc.StartHealing();
					npc.m_iWearable4 = ConnectWithBeam(npc.m_iWearable3, npc.m_iTarget, 0, 0, 255, 3.0, 3.0, 0.0, LASERBEAM);
					npc.Healing = true;
					npc.m_bnew_target = true;
				}
				int MaxHealth = ReturnEntityMaxHealth(npc.m_iTarget);
				if(b_thisNpcIsABoss[npc.m_iTarget])
					MaxHealth = RoundToCeil(float(MaxHealth) * 0.05);

				HealEntityGlobal(npc.index, npc.m_iTarget, float(MaxHealth / 80), 1.0);
				ApplyStatusEffect(npc.index, npc.m_iTarget, "Oceanic Scream", 1.1);
				if(NpcStats_VictorianCallToArms(npc.index))
					ApplyStatusEffect(npc.index, npc.m_iTarget, "War Cry", 1.1);
				
				float WorldSpaceVec[3]; WorldSpaceCenter(npc.m_iTarget, WorldSpaceVec);
				
				npc.FaceTowards(WorldSpaceVec, 2000.0);
			}
			else
			{
				npc.StopHealing();
				npc.m_bnew_target = false;					
			}
		}
		else
		{
			return 3;
		}
		return ((!Can_I_See_Ally(npc.index, npc.m_iTarget) || distance > NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*3.7) ? 0 : 1);
	}
}

