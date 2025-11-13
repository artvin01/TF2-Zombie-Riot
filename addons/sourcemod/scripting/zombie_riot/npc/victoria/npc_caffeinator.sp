#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/mvm/norm/medic_mvm_paincrticialdeath01.mp3",
	"vo/mvm/norm/medic_mvm_paincrticialdeath02.mp3",
	"vo/mvm/norm/medic_mvm_paincrticialdeath03.mp3"
};

static const char g_HurtSounds[][] = {
	"vo/mvm/norm/medic_mvm_painsharp01.mp3",
	"vo/mvm/norm/medic_mvm_painsharp02.mp3",
	"vo/mvm/norm/medic_mvm_painsharp03.mp3",
	"vo/mvm/norm/medic_mvm_painsharp04.mp3"
};

static const char g_IdleAlertedSounds[][] = {
	"vo/mvm/norm/medic_mvm_battlecry01.mp3",
	"vo/mvm/norm/medic_mvm_battlecry02.mp3",
	"vo/mvm/norm/medic_mvm_battlecry03.mp3",
	"vo/mvm/norm/medic_mvm_battlecry04.mp3"
};

static const char g_MeleeHitSounds[][] = {
	")weapons/ubersaw_hit1.wav",
	")weapons/ubersaw_hit2.wav",
	")weapons/ubersaw_hit3.wav",
	")weapons/ubersaw_hit4.wav"
};

static const char g_MeleeAttackSounds[] = "weapons/knife_swing.wav";

void VictorianCaffeinator_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Caffeinator");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_caffeinator");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_caffeinator");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Victoria;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_DefaultMeleeMissSounds);
	PrecacheSound(g_MeleeAttackSounds);
	PrecacheModel("models/bots/medic/bot_medic.mdl");
	PrecacheSound("player/flow.wav");
	PrecacheModel(LASERBEAM);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return VictorianCaffeinator(vecPos, vecAng, ally);
}
methodmap VictorianCaffeinator < CClotBody
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
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
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
	
	public VictorianCaffeinator(float vecPos[3], float vecAng[3], int ally)
	{
		VictorianCaffeinator npc = view_as<VictorianCaffeinator>(CClotBody(vecPos, vecAng, "models/bots/medic/bot_medic.mdl", "1.0", "30000", ally));
		
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		func_NPCDeath[npc.index] = VictorianCaffeinator_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = VictorianCaffeinator_OnTakeDamage;
		func_NPCThink[npc.index] = VictorianCaffeinator_ClotThink;
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		
		//IDLE
		KillFeed_SetKillIcon(npc.index, "battleneedle");
		npc.m_flSpeed = 400.0;
		npc.m_iWearable5 = INVALID_ENT_REFERENCE;
		Is_a_Medic[npc.index] = true;
		npc.m_bFUCKYOU = false;
		npc.m_bFUCKYOU_move_anim = false;
		npc.m_flNextRangedAttack = 0.0;
		
		npc.m_bnew_target = false;
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.index, 80, 50, 50, 255);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/medic/sum24_hazardous_vest/sum24_hazardous_vest.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		SetEntityRenderColor(npc.m_iWearable1, 80, 50, 50, 255);
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/weapons/c_models/c_proto_medigun/c_proto_medigun.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		SetEntityRenderColor(npc.m_iWearable3, 0, 0, 0, 255);
		
		npc.m_iWearable2	= npc.EquipItem("head", "models/workshop/player/items/medic/sf14_medic_kriegsmaschine_9000/sf14_medic_kriegsmaschine_9000.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		SetEntityRenderColor(npc.m_iWearable2, 80, 50, 50, 255);

		npc.m_iWearable6	= npc.EquipItem("head", "models/workshop/player/items/medic/dec15_berlin_brain_bowl/dec15_berlin_brain_bowl.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");
		SetEntityRenderColor(npc.m_iWearable6, 50, 50, 50, 255);

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/scout/jul13_koolboy_2/jul13_koolboy_2.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		SetEntityRenderColor(npc.m_iWearable5, 0, 0, 0, 255);

		npc.m_iWearable7 = npc.EquipItem("head", "models/workshop/player/items/medic/tw_medibot_chariot/tw_medibot_chariot.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable7, "SetModelScale");
		SetEntityRenderColor(npc.m_iWearable7, 0, 0, 0, 255);
		
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable7, Prop_Send, "m_nSkin", 1);
		
		return npc;
	}
	public void StartHealing()
	{
		int im_iWearable3 = this.m_iWearable3;
		if(im_iWearable3 != INVALID_ENT_REFERENCE)
		{
			this.Healing = true;
			
		//	EmitSoundToAll("m_iWearable3s/medigun_heal.wav", this.index, SNDCHAN_m_iWearable3);
		}
	}	
	public void StopHealing()
	{
		int iBeam = this.m_iWearable5;
		if(iBeam != INVALID_ENT_REFERENCE)
		{
			int iBeamTarget = GetEntPropEnt(iBeam, Prop_Send, "m_hOwnerEntity");
			if(IsValidEntity(iBeamTarget))
			{
				AcceptEntityInput(iBeamTarget, "ClearParent");
				RemoveEntity(iBeamTarget);
			}
			
			AcceptEntityInput(iBeam, "ClearParent");
			RemoveEntity(iBeam);
			
			EmitSoundToAll("weapons/medigun_no_target.wav", this.index, SNDCHAN_WEAPON);
			
		//	StopSound(this.index, SNDCHAN_m_iWearable3, "m_iWearable3s/medigun_heal.wav");
			
			this.Healing = false;
		}
	}
}

static void VictorianCaffeinator_ClotThink(int iNPC)
{
	VictorianCaffeinator npc = view_as<VictorianCaffeinator>(iNPC);
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
		npc.m_iTarget = (npc.m_bFUCKYOU ? GetClosestTarget(npc.index) : GetClosestAlly(npc.index));
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + (npc.m_bFUCKYOU ? GetRandomRetargetTime() : 5000.0);
	}
	if(IsValidAlly(npc.index, npc.m_iTarget) && Is_a_Medic[npc.m_iTarget])
	{
		if(IsValidEntity(npc.m_iWearable4))
			RemoveEntity(npc.m_iWearable4);
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
			
		npc.m_iWearable3 = npc.EquipItem("head", "models/weapons/c_models/c_proto_medigun/c_proto_medigun.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		SetEntityRenderColor(npc.m_iWearable3, 0, 0, 0, 255);
	
		if(IsValidEntity(npc.m_iWearable4))
			RemoveEntity(npc.m_iWearable4);
			
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
			
		npc.m_iWearable3 = npc.EquipItem("head", "models/weapons/c_models/c_uberneedle/c_uberneedle.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		SetEntityRenderColor(npc.m_iWearable3, 255, 0, 0, 255);
	
		if(IsValidEntity(npc.m_iWearable4))
			RemoveEntity(npc.m_iWearable4);
			
		npc.StopHealing();
		npc.Healing = false;
		npc.m_bnew_target = false;
		npc.m_bFUCKYOU = true;
		npc.m_flGetClosestTargetTime = 0.0;
	}
	
	float vecTarget[3];
	if(GotoWork||(npc.m_bFUCKYOU&&IsValidEnemy(npc.index, npc.m_iTarget)))
	{
		WorldSpaceCenter(npc.m_iTarget, vecTarget);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		
		switch(VictorianCaffeinator_Work(npc, GetGameTime(npc.index), flDistanceToTarget))
		{
			case 0:
			{
				if(npc.m_iChanged_WalkCycle != 0)
				{
					npc.StartPathing();
					npc.m_bisWalking = true;
					npc.SetActivity("ACT_MP_RUN_SECONDARY");
					npc.m_flSpeed = 400.0;
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
					npc.m_flSpeed = 275.0;
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

static Action VictorianCaffeinator_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &m_iWearable3, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VictorianCaffeinator npc = view_as<VictorianCaffeinator>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void VictorianCaffeinator_NPCDeath(int entity)
{
	VictorianCaffeinator npc = view_as<VictorianCaffeinator>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	Is_a_Medic[npc.index] = false;
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
	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);
	npc.StopHealing();
}

static int VictorianCaffeinator_Work(VictorianCaffeinator npc, float gameTime, float distance)
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
							ApplyStatusEffect(npc.index, entitycount, "Caffinated", 2.6);
							ApplyStatusEffect(npc.index, entitycount, "Caffinated Drain", 2.6);
							if(NpcStats_VictorianCallToArms(npc.index))
							{
								ApplyStatusEffect(npc.index, entitycount, "Taurine", 2.6);
							}
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
								damageDealt*=2.5;
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
			if(distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*14.8 && Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
			{
				if(!npc.m_bnew_target)
				{
					npc.StartHealing();
					npc.m_iWearable4 = ConnectWithBeam(npc.m_iWearable3, npc.m_iTarget, 255, 0, 0, 3.0, 3.0, 1.35, LASERBEAM);
					npc.Healing = true;
					npc.m_bnew_target = true;
				}
				int MaxHealth = ReturnEntityMaxHealth(npc.m_iTarget);
				if(b_thisNpcIsABoss[npc.m_iTarget])
					MaxHealth = RoundToCeil(float(MaxHealth) * 0.05);

				HealEntityGlobal(npc.index, npc.m_iTarget, float(MaxHealth / 80), 1.0);
				ApplyStatusEffect(npc.index, npc.m_iTarget, "Caffinated", 1.1);
				ApplyStatusEffect(npc.index, npc.m_iTarget, "Caffinated Drain", 1.1);
				if(NpcStats_VictorianCallToArms(npc.index))
					ApplyStatusEffect(npc.index, npc.m_iTarget, "Taurine", 1.1);
				
				float WorldSpaceVec[3]; WorldSpaceCenter(npc.m_iTarget, WorldSpaceVec);
				npc.FaceTowards(WorldSpaceVec, 2000.0);
			}
			else
			{
				if(IsValidEntity(npc.m_iWearable4))
					RemoveEntity(npc.m_iWearable4);
				npc.m_bnew_target = false;					
			}
		}
		else
		{
			return 3;
		}
		return (distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*3.7 ? 1 : 0);
	}
}