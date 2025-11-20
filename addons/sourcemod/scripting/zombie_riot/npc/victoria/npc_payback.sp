#pragma semicolon 1
#pragma newdecls required


static const char g_DeathSounds[][] = {
	"npc/combine_soldier/die1.wav",
	"npc/combine_soldier/die2.wav",
	"npc/combine_soldier/die3.wav"
};

static const char g_HurtSounds[][] = {
	"npc/combine_soldier/pain1.wav",
	"npc/combine_soldier/pain2.wav",
	"npc/combine_soldier/pain3.wav"
};

static const char g_IdleAlertedSounds[][] = {
	"npc/combine_soldier/vo/alert1.wav",
	"npc/combine_soldier/vo/bouncerbouncer.wav",
	"npc/combine_soldier/vo/boomer.wav",
	"npc/combine_soldier/vo/contactconfim.wav"
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav"
};

static const char g_MeleeHitSounds[] = "weapons/halloween_boss/knight_axe_hit.wav";

void VictorianPayback_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Payback");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_payback");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_payback_v2");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
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
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSound(g_MeleeHitSounds);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return VictorianPayback(vecPos, vecAng, ally, data);
}

methodmap VictorianPayback < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
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
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds, this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}

	property float m_LimitedLifetime
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_PaybackAnimation
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_EditLifetime
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_EditArmorGain
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	
	public VictorianPayback(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		VictorianPayback npc = view_as<VictorianPayback>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_2_MODEL, "1.5", "8000", ally, false, true));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_TEUTON_WALK_NEW");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(6);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_LimitedLifetime = 0.0;
		npc.m_PaybackAnimation = 0.0;
		npc.m_EditLifetime = 5.0;
		npc.m_EditArmorGain = 1.25;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		func_NPCDeath[npc.index] = VictorianPayback_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = VictorianPayback_OnTakeDamage;
		func_NPCThink[npc.index] = VictorianPayback_ClotThink;
		
		//IDLE
		KillFeed_SetKillIcon(npc.index, "claidheamohmor");
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 250.0;
		npc.m_fbRangedSpecialOn = false;
		b_NpcUnableToDie[npc.index] = true;
		
		//Maybe used for special waves
		static char countext[3][512];
		int count = ExplodeString(data, ";", countext, sizeof(countext), sizeof(countext[]));
		for(int i = 0; i < count; i++)
		{
			if(i>=count)break;
			else if(StrContains(countext[i], "lifetime") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "lifetime", "");
				npc.m_EditLifetime = StringToFloat(countext[i]);
			}
			else if(StrContains(countext[i], "armor") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "armor", "");
				npc.m_EditArmorGain = StringToFloat(countext[i]);
			}
		}
		
		int skin = 1;
	//	SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/workshop/weapons/c_models/c_claidheamohmor/c_claidheamohmor.mdl");
		SetVariantString("1.1");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_claymore/c_claymore.mdl");
		SetVariantString("1.1");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/soldier/dec17_brass_bucket/dec17_brass_bucket.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/heavy/fall17_heavy_harness/fall17_heavy_harness.mdl");
		SetVariantString("0.9");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/soldier/bak_caped_crusader/bak_caped_crusader.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", 3);

		npc.m_iWearable6 = npc.EquipItem("partyhat", "models/player/items/mvm_loot/heavy/robo_ushanka.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");
		SetEntityRenderColor(npc.m_iWearable6, 175, 175, 200, 255);
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", skin);

		SetEntityRenderColor(npc.index, 125, 125, 125, 255);
		SetEntityRenderColor(npc.m_iWearable1, 125, 255, 255, 255);
		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable2, 255, 255, 255, 1);
		SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMinDist", 1.0);
		SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMaxDist", 1.0);
		SetEntityRenderColor(npc.m_iWearable3, 125, 125, 125, 255);

		return npc;
	}
}

static void VictorianPayback_ClotThink(int iNPC)
{
	VictorianPayback npc = view_as<VictorianPayback>(iNPC);
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
	
	if(npc.m_PaybackAnimation)
	{
		if(npc.m_iChanged_WalkCycle != 3)
		{
			npc.m_bisWalking = false;
			npc.m_iChanged_WalkCycle = 3;
			npc.RemoveGesture("ACT_TEUTON_ATTACK_NEW_XENO");
			npc.RemoveGesture("ACT_TEUTON_ATTACK_NEW");
			npc.RemoveGesture("ACT_TEUTON_ATTACK_CADE_NEW_XENO");
			npc.RemoveGesture("ACT_TEUTON_ATTACK_CADE_NEW");
			npc.SetActivity("ACT_VIVITHORN_CHARGE_STUN");
			npc.StopPathing();
			npc.m_flSpeed = 0.0;
		}
		if(npc.m_PaybackAnimation < GetGameTime(npc.index) && !npc.m_fbRangedSpecialOn)
		{
			npc.m_PaybackAnimation = 0.0;
			npc.m_LimitedLifetime = GetGameTime(npc.index) + npc.m_EditLifetime;
			npc.m_fbRangedSpecialOn = true;
			
			if(IsValidEntity(npc.m_iWearable2))
			{
				ExtinguishTarget(npc.m_iWearable2);
				IgniteTargetEffect(npc.m_iWearable2);
			}
			//b_HideHealth[npc.index]=true;
			GrantEntityArmor(npc.index, false, npc.m_EditArmorGain, 0.0, 0, float(ReturnEntityMaxHealth(npc.index))*npc.m_EditArmorGain);

			b_NpcIsInvulnerable[npc.index] = false;
			b_NpcUnableToDie[npc.index]=false;
		}
		return;
	}

	if(npc.m_LimitedLifetime < GetGameTime(npc.index) && npc.Anger)
	{
		b_NpcIsInvulnerable[npc.index] = false;
		SDKHooks_TakeDamage(npc.index, 0, 0, 1000000.0, DMG_BULLET);
		SmiteNpcToDeath(npc.index);
	}
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
		return;
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	if(npc.Anger)
	{
		if(npc.m_iChanged_WalkCycle != 1)
		{
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 1;
			npc.SetActivity("ACT_TEUTON_WALK_NEW_XENO");
			npc.StartPathing();
			npc.m_flSpeed = 350.0;
		}
	}
	else
	{
		if(npc.m_iChanged_WalkCycle != 2)
		{
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 2;
			npc.SetActivity("ACT_TEUTON_WALK_NEW");
			npc.StartPathing();
			npc.m_flSpeed = 250.0;
		}
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
		VictorianPaybackSelfDefense(npc,GetGameTime(npc.index), flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

static Action VictorianPayback_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VictorianPayback npc = view_as<VictorianPayback>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	if(damage >= GetEntProp(npc.index, Prop_Data, "m_iHealth") && !npc.Anger)
	{
		npc.m_PaybackAnimation = GetGameTime(npc.index) + 4.2;
		npc.Anger = true;
		b_NpcIsInvulnerable[npc.index] = true;
	}
	
	return Plugin_Changed;
}

static void VictorianPayback_NPCDeath(int entity)
{
	VictorianPayback npc = view_as<VictorianPayback>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();	
	
	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}

static void VictorianPaybackSelfDefense(VictorianPayback npc, float gameTime, float distance)
{
	if(distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
	{
		if(npc.m_flNextMeleeAttack < gameTime)
		{
			if(!npc.m_flAttackHappenswillhappen)
			{
				float AttackTime=(npc.Anger ? 1.0/0.425 : 1.0);
				if(!ShouldNpcDealBonusDamage(npc.m_iTarget))
				{
					if(npc.Anger)
						npc.AddGesture("ACT_TEUTON_ATTACK_NEW_XENO", _,_,_, AttackTime);
					else
						npc.AddGesture("ACT_TEUTON_ATTACK_NEW", _,_,_, AttackTime);
				}
				else
				{
					if(npc.Anger)
						npc.AddGesture("ACT_TEUTON_ATTACK_CADE_NEW_XENO", _,_,_, AttackTime);
					else
						npc.AddGesture("ACT_TEUTON_ATTACK_CADE_NEW", _,_,_, AttackTime);
				}
				AttackTime=(npc.Anger ? 0.17 : 0.4);
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
				npc.PlayMeleeSound();
				npc.m_flAttackHappens = gameTime+AttackTime;
				npc.m_flAttackHappens_bullshit = gameTime+AttackTime+0.14;
				npc.m_flAttackHappenswillhappen = true;
			}
			if(npc.m_flAttackHappens < gameTime && npc.m_flAttackHappens_bullshit >= gameTime && npc.m_flAttackHappenswillhappen)
			{
				if(!npc.Anger && ShouldNpcDealBonusDamage(npc.m_iTarget))
					npc.m_flNextRangedAttack=gameTime+0.45;
				Handle swingTrace;
				float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
				npc.FaceTowards(vecTarget, 20000.0);
				float Health = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));
				float MaxHealth = float(ReturnEntityMaxHealth(npc.index));		
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget))
				{
					int target = TR_GetEntityIndex(swingTrace);
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					
					if(IsValidEnemy(npc.index, target))
					{
						float damageDealt = 40.0;
						if(npc.Anger)
						{
							damageDealt *=  5.0;//Maximum damage bonus
							if(ShouldNpcDealBonusDamage(target))
								damageDealt *=  2.0;
						}
						else
							damageDealt *=  (1.0+(1-(Health/MaxHealth))*4);
						if(NpcStats_VictorianCallToArms(npc.index))
							damageDealt *= 1.25;

						SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);
						npc.PlayMeleeHitSound();	
					}
				}
				delete swingTrace;
				npc.m_flNextMeleeAttack = gameTime + (npc.Anger ? 0.51 : 1.2);
				npc.m_flAttackHappenswillhappen = false;
			}
			else if(npc.m_flAttackHappens_bullshit < gameTime && npc.m_flAttackHappenswillhappen)
			{
				npc.m_flAttackHappenswillhappen = false;
				npc.m_flNextMeleeAttack = gameTime + (npc.Anger ? 0.51 : 1.2);
			}
		}
	}
	if(npc.m_flNextRangedAttack && npc.m_flNextRangedAttack < gameTime)
	{
		Handle swingTrace;
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
		npc.FaceTowards(vecTarget, 20000.0);
		float Health = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));
		float MaxHealth = float(ReturnEntityMaxHealth(npc.index));		
		if(npc.DoSwingTrace(swingTrace, npc.m_iTarget))
		{
			int target = TR_GetEntityIndex(swingTrace);
			float vecHit[3];
			TR_GetEndPosition(vecHit, swingTrace);
			
			if(IsValidEnemy(npc.index, target))
			{
				float damageDealt = 40.0;
				damageDealt *=  (1.0+(1-(Health/MaxHealth))*4);
				if(NpcStats_VictorianCallToArms(npc.index))
					damageDealt *= 1.25;

				SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);
				npc.PlayMeleeHitSound();	
			}
		}
		delete swingTrace;
		npc.m_flNextRangedAttack = 0.0;
	}
}