#pragma semicolon 1
#pragma newdecls required

static const char g_HurtSounds[][] = {
	"npc/scanner/scanner_pain1.wav",
	"npc/scanner/scanner_pain2.wav"
};

static const char g_IdleSounds[][] = {
	"vo/mvm/norm/heavy_mvm_jeers03.mp3",	
	"vo/mvm/norm/heavy_mvm_jeers04.mp3",	
	"vo/mvm/norm/heavy_mvm_jeers06.mp3",
	"vo/mvm/norm/heavy_mvm_jeers09.mp3"	
};

static const char g_IdleAlertedSounds[] = "npc/scanner/scanner_alert1.wav";
static const char g_DeathSounds[] = "npc/scanner/scanner_explode_crash2.wav";
static const char g_MeleeAttackSounds[] = "ambient/materials/metal_groan.wav";
static const char g_MeleeHitSounds[] = "npc/scanner/cbot_discharge1.wav";

void VictorianIronShield_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "IronShield");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_ironshield");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_ironshield");
	data.IconCustom = true;	
	data.Flags = 0;
	data.Category = Type_Victoria;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSound(g_IdleAlertedSounds);
	PrecacheSound(g_DeathSounds);
	PrecacheSound(g_MeleeAttackSounds);
	PrecacheSound(g_MeleeHitSounds);
	PrecacheModel("models/bots/heavy_boss/bot_heavy_boss.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return VictorianIronShield(vecPos, vecAng, ally, data);
}
methodmap VictorianIronShield < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	public void PlayIdleAlertSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds, this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound()
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
	}
	public void PlayDeathSound()
	{
		EmitSoundToAll(g_DeathSounds, this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds, this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds, this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	property int m_iThirdPunch
	{
		public get()							{ return i_AttacksTillMegahit[this.index]; }
		public set(int TempValueForProperty) 	{ i_AttacksTillMegahit[this.index] = TempValueForProperty; }
	}
	
	public VictorianIronShield(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		VictorianIronShield npc = view_as<VictorianIronShield>(CClotBody(vecPos, vecAng, "models/bots/heavy_boss/bot_heavy_boss.mdl", "1.5", "65000", ally, false, true));
		
		i_NpcWeight[npc.index] = 3;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(16);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.g_TimesSummoned = 0;
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_ROBOT;
		
		func_NPCDeath[npc.index] = VictorianIronShield_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = VictorianIronShield_OnTakeDamage;
		func_NPCThink[npc.index] = VictorianIronShield_ClotThink;
		
		//IDLE
		KillFeed_SetKillIcon(npc.index, "steel_fists");
		npc.m_iState = 0;
		npc.m_flSpeed = 150.0;
		npc.m_iChanged_WalkCycle = 0;
		npc.Anger = false;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_iOverlordComboAttack = 0;
		npc.m_iThirdPunch = 1;
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		if(StrContains(data, "combo") != -1)
		{
			char buffers[3][64];
			ExplodeString(data, ";", buffers, sizeof(buffers), sizeof(buffers[]));
			ReplaceString(buffers[0], 64, "combo", "");
			npc.m_iThirdPunch = StringToInt(buffers[0]);
		}
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.index, 80, 50, 50, 255);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_fists_of_steel/c_fists_of_steel.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 1);
		SetEntityRenderColor(npc.m_iWearable1, 100, 100, 150, 255);
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/heavy/big_jaw.mdl");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/pyro/dec23_impact_impaler/dec23_impact_impaler.mdl");
		SetVariantString("0.9");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		SetEntityRenderColor(npc.m_iWearable3, 255, 255, 255, 255);

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/heavy/tw_heavybot_helmet/tw_heavybot_helmet.mdl");
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);
		SetVariantString("0.9");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		SetEntityRenderColor(npc.m_iWearable4, 150, 150, 150, 255);

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/heavy/tw_heavybot_armor/tw_heavybot_armor.mdl");
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", 1);
		SetEntityRenderColor(npc.m_iWearable5, 100, 100, 100, 255);
		
		return npc;
	}
}

static void VictorianIronShield_ClotThink(int iNPC)
{
	VictorianIronShield npc = view_as<VictorianIronShield>(iNPC);
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
		return;
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;
	
	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		VictorianIronShieldSelfdefense(npc, GetGameTime(npc.index), flDistanceToTarget);
		if(npc.m_iChanged_WalkCycle != 1)
		{
			npc.m_bisWalking = true;
			npc.m_bAllowBackWalking = false;
			npc.m_iChanged_WalkCycle = 1;
			npc.SetActivity("ACT_MP_RUN_MELEE");
			npc.m_flSpeed = 150.0;
			npc.StartPathing();
		}
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
		npc.PlayIdleAlertSound();
	}
	else
	{
		if(npc.m_iChanged_WalkCycle != 0)
		{
			npc.m_bisWalking = false;
			npc.m_bAllowBackWalking = false;
			npc.m_iChanged_WalkCycle = 0;
			npc.SetActivity("ACT_MP_STAND_MELEE");
			npc.m_flSpeed = 0.0; 
			npc.StopPathing();
		}
		npc.m_flGetClosestTargetTime = 0.0;
		npc.PlayIdleSound();
	}
	
}

static void VictorianIronShieldSelfdefense(VictorianIronShield npc, float gameTime, float distance)
{
	if(distance < GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
	{
		if(npc.m_flNextMeleeAttack < gameTime)
		{
			if(!npc.m_flAttackHappenswillhappen)
			{
				if(npc.m_iOverlordComboAttack <= npc.m_iThirdPunch)
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
					npc.m_iOverlordComboAttack+=(NpcStats_VictorianCallToArms(npc.index) ? 3 : 1);
				}
				else
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_SECONDARY");
					npc.m_iOverlordComboAttack = 0;
					npc.Anger=true;
				}
				npc.PlayMeleeSound();
				npc.m_flAttackHappens = gameTime+0.25;
				npc.m_flDoingAnimation = gameTime + 0.25;
				npc.m_flAttackHappens_bullshit = gameTime+0.39;
				npc.m_flAttackHappenswillhappen = true;
			}
			if(npc.m_flAttackHappens < gameTime && npc.m_flAttackHappens_bullshit >= gameTime && npc.m_flAttackHappenswillhappen)
			{
				Handle swingTrace;
				float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
				npc.FaceTowards(vecTarget, 15000.0);
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 1))
				{
					int target = TR_GetEntityIndex(swingTrace);
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					if(IsValidEnemy(npc.index, target))
					{
						if(npc.Anger)
						{
							float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
							Explode_Logic_Custom(0.0, npc.index, npc.index, -1, VecSelfNpc, 150.0, _, _, true, _, false, _, ThirdPunch_AoE);
						}
						else
						{
							float damageDealt = 100.0;
							if(ShouldNpcDealBonusDamage(target))
								damageDealt*=10.0;
							SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);
						}
						npc.PlayMeleeHitSound();
					}
				}
				delete swingTrace;
				npc.m_flNextMeleeAttack = gameTime + 1.2;
				npc.m_flAttackHappenswillhappen = false;
				npc.Anger = false;
			}
			else if(npc.m_flAttackHappens_bullshit < gameTime && npc.m_flAttackHappenswillhappen)
			{
				npc.m_flAttackHappenswillhappen = false;
				npc.m_flNextMeleeAttack = gameTime + 1.2;
			}
		}
	}
}

static Action VictorianIronShield_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VictorianIronShield npc = view_as<VictorianIronShield>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void VictorianIronShield_NPCDeath(int entity)
{
	VictorianIronShield npc = view_as<VictorianIronShield>(entity);
	
	float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);

	npc.PlayDeathSound();

	TE_Particle("asplode_hoodoo", vecMe, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
	int team = GetTeam(npc.index);

	int MaxHealth = RoundToCeil(float(ReturnEntityMaxHealth(npc.index))/3.0);

	float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
	float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
	
	int other = NPC_CreateByName("npc_aviator", -1, pos, ang, team);
	if(other > MaxClients)
	{
		if(team != TFTeam_Red)
			Zombies_Currently_Still_Ongoing++;
		
		SetEntProp(other, Prop_Data, "m_iHealth", MaxHealth);
		SetEntProp(other, Prop_Data, "m_iMaxHealth", MaxHealth);
		
		fl_Extra_MeleeArmor[other] = fl_Extra_MeleeArmor[npc.index];
		fl_Extra_RangedArmor[other] = fl_Extra_RangedArmor[npc.index];
		fl_Extra_Speed[other] = fl_Extra_Speed[npc.index];
		fl_Extra_Damage[other] = fl_Extra_Damage[npc.index];
		b_thisNpcIsABoss[other] = b_thisNpcIsABoss[npc.index];
		b_StaticNPC[other] = b_StaticNPC[npc.index];
		if(b_StaticNPC[other])
			AddNpcToAliveList(other, 1);
	}

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
}

static void ThirdPunch_AoE(int entity, int victim, float damage, int weapon)
{
	VictorianIronShield npc = view_as<VictorianIronShield>(entity);
	float vecHit[3]; WorldSpaceCenter(victim, vecHit);
	if(IsValidEntity(npc.index) && IsValidEntity(victim) && GetTeam(npc.index) != GetTeam(victim))
	{
		float damageDealt = 250.0;
		if(ShouldNpcDealBonusDamage(victim))
			damageDealt*=10.0;
		SDKHooks_TakeDamage(victim, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);
		if(!HasSpecificBuff(victim, "Solid Stance"))
		{
			Custom_Knockback(npc.index, victim, 450.0, true);
			if(IsValidClient(victim))
			{
				TF2_AddCondition(victim, TFCond_LostFooting, 0.5);
				TF2_AddCondition(victim, TFCond_AirCurrent, 0.5);
			}
		}
	}
}