#pragma semicolon 1
#pragma newdecls required

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
	")vo/medic_specialcompleted12.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/ubersaw_hit1.wav",
	"weapons/ubersaw_hit2.wav",
	"weapons/ubersaw_hit3.wav",
	"weapons/ubersaw_hit4.wav",
};

static const char g_FuckyouSounds[][] = {
	"vo/taunts/medic_taunts05.mp3",
	"vo/taunts/medic_taunts06.mp3",
	"vo/taunts/medic_taunts12.mp3",
	"vo/taunts/medic_taunts14.mp3",
	"vo/taunts/medic_taunts15.mp3"
};

static const char g_MeleeAttackSounds[] = "weapons/knife_swing.wav";

void VictorianHardener_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Hardender");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_hardener");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_hardener");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Victoria;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_DefaultMedic_DeathSounds);
	PrecacheSoundArray(g_DefaultMedic_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_DefaultMeleeMissSounds);
	PrecacheSoundArray(g_FuckyouSounds);
	PrecacheSound(g_MeleeAttackSounds);
	PrecacheModel("models/player/medic.mdl");
	PrecacheSound("player/flow.wav");
	PrecacheModel(LASERBEAM);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return VictorianHardener(vecPos, vecAng, ally, data);
}

methodmap VictorianHardener < CClotBody
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
		
		EmitSoundToAll(g_DefaultMedic_HurtSounds[GetRandomInt(0, sizeof(g_DefaultMedic_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayDeathSound()
	{
		EmitSoundToAll(g_DefaultMedic_DeathSounds[GetRandomInt(0, sizeof(g_DefaultMedic_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
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
	
	property float m_flMaxArmorGive
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flArmorResist
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flArmorToGive
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}

	public VictorianHardener(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		VictorianHardener npc = view_as<VictorianHardener>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "1500", ally));
		
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		func_NPCDeath[npc.index] = VictorianHardener_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = VictorianHardener_OnTakeDamage;
		func_NPCThink[npc.index] = VictorianHardener_ClotThink;
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPSOUND_NORMAL;
		
		//IDLE
		KillFeed_SetKillIcon(npc.index, "bonesaw");
		npc.m_flSpeed = 300.0;
		npc.m_iWearable5 = INVALID_ENT_REFERENCE;
		Is_a_Medic[npc.index] = true;
		npc.m_bFUCKYOU = false;
		npc.m_bFUCKYOU_move_anim = false;
		npc.m_flArmorResist=0.75;
		npc.m_flMaxArmorGive=1.0;
		npc.m_flArmorToGive=1.0;
		
		npc.m_bnew_target = false;
		npc.StartPathing();
		
		//Maybe used for special waves
		static char countext[20][1024];
		int count = ExplodeString(data, ";", countext, sizeof(countext), sizeof(countext[]));
		for(int i = 0; i < count; i++)
		{
			if(i>=count)break;
			else if(StrContains(countext[i], "maxarmor") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "maxarmor", "");
				npc.m_flMaxArmorGive = StringToFloat(countext[i]);
			}
			else if(StrContains(countext[i], "armor") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "armor", "");
				npc.m_flArmorToGive = StringToFloat(countext[i]);
			}
			else if(StrContains(countext[i], "resist") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "resist", "");
				npc.m_flArmorResist = StringToFloat(countext[i]);
			}
		}
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/medic/surgical_stare/surgical_stare.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		SetEntityRenderColor(npc.m_iWearable1, 150, 150, 200, 255);
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/weapons/c_models/c_medigun/c_medigun.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		npc.m_iWearable2	= npc.EquipItem("head", "models/workshop/player/items/spy/dec22_frostbite_bonnet/dec22_frostbite_bonnet.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable6	= npc.EquipItem("head", "models/workshop/player/items/medic/sum24_hazardous_vest/sum24_hazardous_vest.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");
		SetEntityRenderColor(npc.m_iWearable6, 150, 150, 150, 255);

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/engineer/spr18_cold_case/spr18_cold_case.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		SetEntityRenderColor(npc.m_iWearable5, 125, 125, 125, 255);

		npc.m_iWearable7 = npc.EquipItem("head", "models/workshop/player/items/medic/dec22_wooly_pulli_style3/dec22_wooly_pulli_style3.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable7, "SetModelScale");
		SetEntityRenderColor(npc.m_iWearable7, 125, 125, 125, 255);
		
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 8);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable7, Prop_Send, "m_nSkin", 1);
		npc.StartPathing();
		
		return npc;
	}
	public void StartHealing()
	{
		int im_iWearable3 = this.m_iWearable3;
		if(im_iWearable3 != INVALID_ENT_REFERENCE)
			this.Healing = true;
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
			
			this.Healing = false;
		}
	}
}

static void VictorianHardener_ClotThink(int iNPC)
{
	VictorianHardener npc = view_as<VictorianHardener>(iNPC);
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	GrantEntityArmor(iNPC, true, 0.2, 0.75, 0);
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
			
		npc.m_iWearable3 = npc.EquipItem("head", "models/weapons/c_models/c_medigun/c_medigun.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
	
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
			
		npc.m_iWearable3 = npc.EquipItem("head", "models/weapons/w_models/w_bonesaw.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		SetEntityRenderColor(npc.m_iWearable3, 255, 215, 0, 255);
	
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
		
		switch(VictorianHardener_Work(npc, GetGameTime(npc.index), flDistanceToTarget))
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

static Action VictorianHardener_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &m_iWearable3, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VictorianHardener npc = view_as<VictorianHardener>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void VictorianHardener_NPCDeath(int entity)
{
	VictorianHardener npc = view_as<VictorianHardener>(entity);
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

static int VictorianHardener_Work(VictorianHardener npc, float gameTime, float distance)
{
	if(npc.m_bFUCKYOU)
	{
		if(npc.m_flNextRangedAttack < gameTime)
		{
			ExpidonsaGroupHeal(npc.index, 200.0, 5, 2500.0, 0.0, false,Expidonsa_DontHealSameIndex);
			IberiaArmorEffect(npc.index, 200.0);
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			int MAXEffect;
			for(int entitycount; entitycount<MAXENTITIES; entitycount++)
			{
				if(MAXEffect>=3)
					break;
				if(IsValidEntity(entitycount) && entitycount != npc.index && !b_NpcHasDied[entitycount])
				{
					if(GetTeam(entitycount) == GetTeam(npc.index) && IsEntityAlive(entitycount))
					{
						static float vecTarget[3]; WorldSpaceCenter(entitycount, vecTarget);
						if(GetVectorDistance(VecSelfNpc, vecTarget, true) < (200.0 * 200.0))
						{
							int MaxHealth = ReturnEntityMaxHealth(entitycount);
							if(b_thisNpcIsABoss[entitycount])
								MaxHealth = RoundToCeil(float(MaxHealth) * 0.05);
								
							if(NpcStats_VictorianCallToArms(npc.index))
							{
								MaxHealth *= 2.0;
								ApplyStatusEffect(npc.index, entitycount, "Defensive Backup", 3.0);
							}
							GrantEntityArmor(entitycount, false, npc.m_flMaxArmorGive, npc.m_flArmorResist, 0, (float(MaxHealth / 400)*npc.m_flArmorToGive));
							MAXEffect++;
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
							float damageDealt = 50.0;
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
			if(distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*14.8 && Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
			{
				if(!npc.m_bnew_target)
				{
					npc.StartHealing();
					npc.m_iWearable4 = ConnectWithBeam(npc.m_iWearable3, npc.m_iTarget, 255, 255, 0, 3.0, 3.0, 1.35, LASERBEAM);
					npc.Healing = true;
					npc.m_bnew_target = true;
				}
				int MaxHealth = ReturnEntityMaxHealth(npc.m_iTarget);
				if(b_thisNpcIsABoss[npc.m_iTarget])
					MaxHealth = RoundToCeil(float(MaxHealth) * 0.05);
					
				if(NpcStats_VictorianCallToArms(npc.index))
				{
					MaxHealth *= 2.0;
					ApplyStatusEffect(npc.index, npc.m_iTarget, "Defensive Backup", 3.0);
				}

				HealEntityGlobal(npc.index, npc.m_iTarget, float(MaxHealth / 80), 1.0);
				GrantEntityArmor(npc.m_iTarget, false, npc.m_flMaxArmorGive, npc.m_flArmorResist, 0, (float(MaxHealth / 400)*npc.m_flArmorToGive));
				
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