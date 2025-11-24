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

static const char g_FuckyouSounds[][] = {
	"vo/taunts/medic_taunts05.mp3",
	"vo/taunts/medic_taunts06.mp3",
	"vo/taunts/medic_taunts12.mp3",
	"vo/taunts/medic_taunts14.mp3",
	"vo/taunts/medic_taunts15.mp3"
};

static const char g_TeleportSounds[][] = {
	"weapons/rescue_ranger_teleport_receive_01.wav",
	"weapons/rescue_ranger_teleport_receive_02.wav"
};

static const char g_MeleeAttackSounds[] = "weapons/knife_swing.wav";

void VictoriaRepair_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Radio Repair");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_radio_repair");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_radiorepair");
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
	PrecacheSoundArray(g_FuckyouSounds);
	PrecacheSoundArray(g_TeleportSounds);
	PrecacheSound(g_MeleeAttackSounds);
	PrecacheModel("models/player/medic.mdl");
	PrecacheSound("player/flow.wav");
	PrecacheModel(LASERBEAM);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return VictoriaRepair(vecPos, vecAng, ally, data);
}
methodmap VictoriaRepair < CClotBody
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
	public void PlayFuckyouSound()
	{
		EmitSoundToAll(g_FuckyouSounds[GetRandomInt(0, sizeof(g_FuckyouSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayTeleportSound()
	{
		EmitSoundToAll(g_TeleportSounds[GetRandomInt(0, sizeof(g_TeleportSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, 0.8);
	}
	
	property int m_iMainTarget
	{
		public get()							{ return this.m_iState; }
		public set(int TempValueForProperty) 	{ this.m_iState = TempValueForProperty; }
	}
	property float m_flChangeMovement
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_fXPosSave
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_fZPosSave
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_fYPosSave
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	
	public void SaveTreePos(float VecTarget[3])
	{
		this.m_fXPosSave=VecTarget[0];
		this.m_fZPosSave=VecTarget[1];
		this.m_fYPosSave=VecTarget[2];
	}
	public void LoadTreePos(float VecTarget[3])
	{
		VecTarget[0]=this.m_fXPosSave;
		VecTarget[1]=this.m_fZPosSave;
		VecTarget[2]=this.m_fYPosSave;
	}

	public VictoriaRepair(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		VictoriaRepair npc = view_as<VictoriaRepair>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "5500", ally));
		
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		func_NPCDeath[npc.index] = VictoriaRepair_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = VictoriaRepair_OnTakeDamage;
		func_NPCThink[npc.index] = VictoriaRepair_ClotThink;
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPSOUND_NORMAL;
		
		//IDLE
		npc.m_flSpeed = 300.0;
		npc.m_iWearable5 = INVALID_ENT_REFERENCE;
		Is_a_Medic[npc.index] = true;
		npc.m_bFUCKYOU = false;
		npc.Anger = false;
		npc.m_bFUCKYOU_move_anim = false;
		npc.m_bnew_target = false;
		npc.m_iMainTarget = -1;
		npc.m_flChangeMovement = 0.0;
		npc.m_fXPosSave = 0.0;
		npc.m_fZPosSave = 0.0;
		npc.m_fYPosSave = 0.0;
		npc.StartPathing();
		
		if(StrContains(data, "target") != -1)
		{
			char buffers[3][64];
			ExplodeString(data, ";", buffers, sizeof(buffers), sizeof(buffers[]));
			ReplaceString(buffers[0], 64, "target", "");
			int targetdata = StringToInt(buffers[0]);
			if(IsValidAlly(npc.index, targetdata))
			{
				npc.m_iMainTarget = targetdata;
				npc.m_flGetClosestTargetTime=GetGameTime(npc.index)+5000.0;
			}
		}
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/player/items/medic/hardhat_tower.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		SetEntityRenderColor(npc.m_iWearable1, 0, 0, 0, 255);
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/weapons/c_models/c_medigun_defense/c_medigun_defense.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		npc.m_iWearable2	= npc.EquipItem("head", "models/player/items/medic/shootmanyrobots_medic.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable6	= npc.EquipItem("head", "models/workshop/player/items/medic/robo_medic_physician_mask/robo_medic_physician_mask.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");
		SetEntityRenderColor(npc.m_iWearable6, 0, 0, 0, 255);

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/medic/sum20_flatliner/sum20_flatliner.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		SetEntityRenderColor(npc.m_iWearable5, 80, 50, 50, 255);

		npc.m_iWearable7 = npc.EquipItem("head", "models/workshop/player/items/medic/sum23_uber_wear/sum23_uber_wear.mdl");

		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable7, Prop_Send, "m_nSkin", 1);
		npc.StartPathing();
		
		TeleportDiversioToRandLocation(npc.index);
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

static void VictoriaRepair_ClotThink(int iNPC)
{
	VictoriaRepair npc = view_as<VictoriaRepair>(iNPC);
	
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
	
	//there is no more valid ally Building, suicide.
	if(!IsValidAlly(npc.index, GetClosestBuilding(npc.index)))
	{
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		ParticleEffectAt(VecSelfNpc, "teleported_blue", 0.5);
		b_NpcForcepowerupspawn[npc.index] = 0;
		i_RaidGrantExtra[npc.index] = 0;
		b_DissapearOnDeath[npc.index] = true;
		b_DoGibThisNpc[npc.index] = true;
		npc.PlayTeleportSound();
		SmiteNpcToDeath(npc.index);
		return;
	}

	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;
	
	if(IsValidAlly(npc.index, npc.m_iMainTarget))
		npc.m_iTarget=npc.m_iMainTarget;
	else if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = (npc.m_bFUCKYOU ? GetClosestTarget(npc.index) : GetClosestBuilding(npc.index));
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + (npc.m_bFUCKYOU ? GetRandomRetargetTime() : 5000.0);
	}
	
	bool GotoWork;
	if(!npc.m_bFUCKYOU&&IsValidAlly(npc.index, npc.m_iTarget))
		GotoWork=true;
	else if(!npc.m_bFUCKYOU)
	{
		if(IsValidEntity(npc.m_iWearable3))
			RemoveEntity(npc.m_iWearable3);
		
		KillFeed_SetKillIcon(npc.index, "battleneedle");
		npc.m_iWearable3 = npc.EquipItem("head", "models/weapons/c_models/c_uberneedle/c_uberneedle.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
	
		if(IsValidEntity(npc.m_iWearable4))
			RemoveEntity(npc.m_iWearable4);
			
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
		
		switch(VictoriaRepair_Work(npc, GetGameTime(npc.index), flDistanceToTarget))
		{
			case 0:
			{
				if(npc.m_iChanged_WalkCycle != 0)
				{
					npc.StartPathing();
					npc.m_bisWalking = true;
					npc.m_bAllowBackWalking = false;
					npc.SetActivity("ACT_MP_RUN_SECONDARY");
					npc.m_flSpeed = 300.0;
					npc.m_iChanged_WalkCycle = 0;
					Is_a_Medic[npc.index] = true;
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
					npc.m_bAllowBackWalking = false;
					npc.SetActivity("ACT_MP_STAND_SECONDARY");
					npc.m_flSpeed = 0.0;
					npc.m_iChanged_WalkCycle = 1;
					Is_a_Medic[npc.index] = true;
				}
			}
			case 2:
			{
				if(npc.m_iChanged_WalkCycle != 2)
				{
					npc.StartPathing();
					npc.m_bisWalking = true;
					npc.m_bAllowBackWalking = false;
					npc.SetActivity("ACT_MP_RUN_MELEE");
					npc.m_flSpeed = 450.0;
					npc.m_iChanged_WalkCycle = 2;
					Is_a_Medic[npc.index] = false;
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
					npc.m_bAllowBackWalking = false;
					npc.SetActivity("ACT_MP_STAND_MELEE");
					npc.m_flSpeed = 0.0;
					npc.m_iChanged_WalkCycle = 3;
					Is_a_Medic[npc.index] = false;
				}
			}
			case 4:
			{
				if(npc.m_iChanged_WalkCycle != 4)
				{
					npc.StartPathing();
					npc.m_bisWalking = true;
					npc.m_bAllowBackWalking = true;
					npc.SetActivity("ACT_MP_RUN_SECONDARY");
					npc.m_flSpeed = 300.0;
					npc.m_iChanged_WalkCycle = 4;
					Is_a_Medic[npc.index] = true;
				}
				if(flDistanceToTarget < npc.GetLeadRadius())
				{
					float vPredictedPos[3];
					npc.LoadTreePos(vPredictedPos);
					npc.SetGoalVector(vPredictedPos);
				}
				else
					npc.SetGoalEntity(npc.m_iTarget);
			}
			case 5:
			{
				if(npc.m_iChanged_WalkCycle != 5)
				{
					npc.StartPathing();
					npc.m_bisWalking = true;
					npc.m_bAllowBackWalking = true;
					npc.SetActivity("ACT_MP_RUN_SECONDARY");
					npc.m_flSpeed = 300.0;
					npc.m_iChanged_WalkCycle = 5;
					Is_a_Medic[npc.index] = true;
				}
			}
		}
	}
	else
		npc.m_flGetClosestTargetTime=0.0;
	npc.PlayIdleAlertSound();
}

static int VictoriaRepair_Work(VictoriaRepair npc, float gameTime, float distance)
{
	if(npc.m_bFUCKYOU)
	{
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
							float damageDealt = 50.0;
							if(ShouldNpcDealBonusDamage(target))
								damageDealt*=3.0;
							SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);
							npc.PlayMeleeHitSound();
							if(!IsValidEnemy(npc.index, target))
							{
								npc.m_flGetClosestTargetTime=0.0;
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
					npc.m_iWearable4 = ConnectWithBeam(npc.m_iWearable3, npc.m_iTarget, 255, 255, 255, 3.0, 3.0, 1.35, LASERBEAM);
					npc.Healing = true;
					npc.m_bnew_target = true;
				}
				
				HealEntityGlobal(npc.index, npc.m_iTarget, 3000.0, 1.0);
				ApplyStatusEffect(npc.index, npc.m_iTarget, "Defensive Backup", 1.1);
				
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
		if(distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*3.7)
		{
			if(gameTime > npc.m_flChangeMovement)
			{
				npc.m_flChangeMovement=gameTime+GetRandomFloat(4.0, 6.0);
				float RNGPos[3];
				VictoriaRepair_Move(npc, 800.0, 1024.0, RNGPos);
				npc.SaveTreePos(RNGPos);
			}
			return (gameTime > npc.m_flChangeMovement-2.0) ? 1 : 4;
		}
		return 0;
	}
}

static Action VictoriaRepair_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &m_iWearable3, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VictoriaRepair npc = view_as<VictoriaRepair>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void VictoriaRepair_NPCDeath(int entity)
{
	VictoriaRepair npc = view_as<VictoriaRepair>(entity);
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

static void VictoriaRepair_Move(VictoriaRepair npc, float min, float max, float output[3])
{
	float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
	for(int loop = 1; loop <= 500; loop++)
	{
		CNavArea RandomArea = GetRandomNearbyArea(vecTarget, max);
		if(RandomArea == NULL_AREA)
			break;
		int NavAttribs = RandomArea.GetAttributes();
		if(NavAttribs & NAV_MESH_AVOID)
			continue;
		float vPredictedPos[3]; RandomArea.GetCenter(vPredictedPos);
		vPredictedPos[2] += 1.0;
		
        if(GetVectorDistance(vPredictedPos, vecTarget, true) < (min * min))
			continue;
		
		if(IsPointHazard(vPredictedPos))
			continue;
		if(IsPointHazard(vPredictedPos))
			continue;
			
		static float hullcheckmaxs_Player_Again[3];
		static float hullcheckmins_Player_Again[3];
		
		hullcheckmaxs_Player_Again = view_as<float>( { 24.0, 24.0, 82.0 } );
		hullcheckmins_Player_Again = view_as<float>( { -24.0, -24.0, 0.0 } );	
		
		if(IsPointHazard(vPredictedPos))
			continue;
		
		vPredictedPos[2] += 18.0;
		if(IsPointHazard(vPredictedPos))
			continue;
		
		vPredictedPos[2] -= 18.0;
		vPredictedPos[2] -= 18.0;
		vPredictedPos[2] -= 18.0;
		if(IsPointHazard(vPredictedPos))
			continue;
		vPredictedPos[2] += 18.0;
		vPredictedPos[2] += 18.0;
		
		if(IsSpaceOccupiedIgnorePlayers(vPredictedPos, hullcheckmins_Player_Again, hullcheckmaxs_Player_Again, npc.index) || IsSpaceOccupiedOnlyPlayers(vPredictedPos, hullcheckmins_Player_Again, hullcheckmaxs_Player_Again, npc.index))
			continue;
		
		if(vPredictedPos[0])
		{
			output=vPredictedPos;
			break;
		}
	}
}