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

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return VictorianPayback(vecPos, vecAng, ally);
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
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
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
	
	public VictorianPayback(float vecPos[3], float vecAng[3], int ally)
	{
		VictorianPayback npc = view_as<VictorianPayback>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.5", "8000", ally, false, true));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_TEUTON_NEW_WALK");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(16);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_LimitedLifetime = 0.0;
		
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
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

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
	
	if(npc.m_PaybackAnimation && b_NpcUnableToDie[npc.index])
	{
		if(npc.m_iChanged_WalkCycle != 5)
		{
			npc.m_bisWalking = false;
			npc.m_iChanged_WalkCycle = 5;
			npc.SetActivity("ACT_MUDROCK_RAGE");
			npc.StopPathing();
			npc.m_flSpeed = 0.0;
		}
		if(npc.m_PaybackAnimation < GetGameTime(npc.index) && !npc.m_fbRangedSpecialOn)
		{
			npc.m_PaybackAnimation = 0.0;
			npc.m_LimitedLifetime = GetGameTime(npc.index) + 5.0;

			if(npc.m_iChanged_WalkCycle != 6)
			{
				npc.m_bisWalking = true;
				npc.m_iChanged_WalkCycle = 6;
				npc.SetActivity("ACT_CUSTOM_RUN_SAMURAI");
				npc.StartPathing();
				npc.m_flSpeed = 350.0;
			}
			npc.m_fbRangedSpecialOn = true;
			
			if(IsValidEntity(npc.m_iWearable2))
			{
				ExtinguishTarget(npc.m_iWearable2);
				IgniteTargetEffect(npc.m_iWearable2);
			}
			//b_HideHealth[npc.index]=true;
			GrantEntityArmor(npc.index, false, 1.25, 0.0, 0, float(ReturnEntityMaxHealth(npc.index))*1.25);

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
		VictorianPaybackSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
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
		npc.m_PaybackAnimation = GetGameTime(npc.index) + 5.0;
		npc.Anger = true;
		b_NpcIsInvulnerable[npc.index] = true;
	}
	
	return Plugin_Changed;
}

static void VictorianPayback_NPCDeath(int entity)
{
	VictorianPayback npc = view_as<VictorianPayback>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
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

static void VictorianPaybackSelfDefense(VictorianPayback npc, float gameTime, int target, float distance)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < GetGameTime(npc.index))
		{
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, .Npc_type = 1)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
			{
				float Health = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));
				float MaxHealth = float(ReturnEntityMaxHealth(npc.index));			
				target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 40.0;
					if(npc.m_LimitedLifetime)
						damageDealt *=  5.0;//Maximum damage bonus
					else
						damageDealt *=  (1.0+(1-(Health/MaxHealth))*4);
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 2.0;
					if(NpcStats_VictorianCallToArms(npc.index))
						damageDealt *= 1.25;

					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);
					npc.PlayMeleeHitSound();	
				} 
			}
			delete swingTrace;
		}
	}
	if(npc.Anger)
	{
		if(npc.m_iChanged_WalkCycle != 1)
		{
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 1;
			npc.SetActivity("ACT_CUSTOM_RUN_SAMURAI");
			npc.StartPathing();
			npc.m_flSpeed = 350.0;
		}
	}
	else
	{
		if(npc.m_iChanged_WalkCycle != 3)
		{
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 3;
			npc.SetActivity("ACT_TEUTON_NEW_WALK");
			npc.StartPathing();
			npc.m_flSpeed = 250.0;
		}
	}

	if(GetGameTime(npc.index) > npc.m_flNextMeleeAttack)
	{
		if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
		{
			int Enemy_I_See;
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
			if(npc.Anger)
			{
				if(IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;
					npc.PlayMeleeSound();
					npc.AddGesture("ACT_MELEE_BOB");
					
							
					npc.m_flAttackHappens = gameTime + 0.15;
					npc.m_flNextMeleeAttack = gameTime + 0.5;
				}
			}
			if(!npc.Anger)
			{
				if(IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;
					npc.PlayMeleeSound();
					npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM1");
					
							
					npc.m_flAttackHappens = gameTime + 0.15;
					npc.m_flNextMeleeAttack = gameTime + 1.2;
				}
			}
		}
	}
}

