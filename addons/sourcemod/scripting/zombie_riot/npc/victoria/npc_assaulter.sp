#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/sniper_negativevocalization01.mp3",
	"vo/sniper_negativevocalization02.mp3",
	"vo/sniper_negativevocalization03.mp3",
	"vo/sniper_negativevocalization04.mp3",
	"vo/sniper_negativevocalization05.mp3",
	"vo/sniper_negativevocalization06.mp3",
	"vo/sniper_negativevocalization07.mp3",
	"vo/sniper_negativevocalization08.mp3",
	"vo/sniper_negativevocalization09.mp3"
};

static const char g_HurtSounds[][] = {
	"vo/sniper_painsharp01.mp3",
	"vo/sniper_painsharp02.mp3",
	"vo/sniper_painsharp03.mp3",
	"vo/sniper_painsharp04.mp3"
};

static const char g_IdleAlertedSounds[][] = {
	"vo/sniper_specialcompleted01.mp3",
	"vo/sniper_specialcompleted02.mp3",
	"vo/sniper_specialcompleted03.mp3",
	"vo/sniper_specialcompleted04.mp3",
	"vo/sniper_specialcompleted05.mp3",
	"vo/sniper_specialcompleted06.mp3",
	"vo/sniper_specialcompleted07.mp3",
	"vo/sniper_specialcompleted08.mp3",
	"vo/sniper_specialcompleted09.mp3",
	"vo/sniper_specialcompleted10.mp3",
	"vo/sniper_specialcompleted11.mp3",
	"vo/sniper_specialcompleted12.mp3",
	"vo/sniper_specialcompleted13.mp3",
	"vo/sniper_specialcompleted14.mp3",
	"vo/sniper_specialcompleted15.mp3",
	"vo/sniper_specialcompleted16.mp3",
	"vo/sniper_specialcompleted17.mp3",
	"vo/sniper_specialcompleted18.mp3",
	"vo/sniper_specialcompleted19.mp3",
	"vo/sniper_specialcompleted20.mp3",
	"vo/sniper_specialcompleted21.mp3",
	"vo/sniper_specialcompleted22.mp3",
	"vo/sniper_specialcompleted23.mp3",
	"vo/sniper_specialcompleted24.mp3",
	"vo/sniper_specialcompleted25.mp3",
	"vo/sniper_specialcompleted26.mp3",
	"vo/sniper_specialcompleted27.mp3",
	"vo/sniper_specialcompleted28.mp3",
	"vo/sniper_specialcompleted29.mp3",
	"vo/sniper_specialcompleted30.mp3",
	"vo/sniper_specialcompleted31.mp3",
	"vo/sniper_specialcompleted32.mp3",
	"vo/sniper_specialcompleted33.mp3",
	"vo/sniper_specialcompleted34.mp3",
	"vo/sniper_specialcompleted35.mp3",
	"vo/sniper_specialcompleted36.mp3",
	"vo/sniper_specialcompleted37.mp3",
	"vo/sniper_specialcompleted38.mp3",
	"vo/sniper_specialcompleted39.mp3",
	"vo/sniper_specialcompleted40.mp3",
	"vo/sniper_specialcompleted41.mp3",
	"vo/sniper_specialcompleted42.mp3",
	"vo/sniper_specialcompleted43.mp3",
	"vo/sniper_specialcompleted44.mp3",
	"vo/sniper_specialcompleted45.mp3",
	"vo/sniper_specialcompleted46.mp3"
};

static const char g_JamSounds[][] = {
	"vo/sniper_jeers03.mp3",
	"vo/sniper_jeers08.mp3"
};

void VictoriaAssaulter_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Assaulter");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_assaulter");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_assaulter");
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
	PrecacheSoundArray(g_JamSounds);
	PrecacheSound("weapons/doom_sniper_smg.wav");
	PrecacheSound("weapons/shotgun_empty.wav");
	PrecacheSound("weapons/smg_worldreload.wav");
	PrecacheModel("models/player/sniper.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return VictoriaAssaulter(vecPos, vecAng, ally, data);
}

methodmap VictoriaAssaulter < CClotBody
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
	public void PlayRangeSound()
	{
		EmitSoundToAll("weapons/doom_sniper_smg.wav", this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayJamSound()
	{
		EmitSoundToAll(g_JamSounds[GetRandomInt(0, sizeof(g_JamSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayEmptySound()
	{
		EmitSoundToAll("weapons/shotgun_empty.wav", this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayReloadSound()
	{
		EmitSoundToAll("weapons/smg_worldreload.wav", this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	property int m_iMovement
	{
		public get()							{ return i_AmountProjectiles[this.index]; }
		public set(int TempValueForProperty) 	{ i_AmountProjectiles[this.index] = TempValueForProperty; }
	}
	property int m_iJamChance
	{
		public get()							{ return this.m_iState; }
		public set(int TempValueForProperty) 	{ this.m_iState = TempValueForProperty; }
	}
	property float m_flChangeMovement
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property int m_iCountSounds
	{
		public get()							{ return i_MedkitAnnoyance[this.index]; }
		public set(int TempValueForProperty) 	{ i_MedkitAnnoyance[this.index] = TempValueForProperty; }
	}

	public VictoriaAssaulter(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		VictoriaAssaulter npc = view_as<VictoriaAssaulter>(CClotBody(vecPos, vecAng, "models/player/sniper.mdl", "1.0", "6000", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		func_NPCDeath[npc.index] = VictoriaAssaulter_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = VictoriaAssaulter_OnTakeDamage;
		func_NPCThink[npc.index] = VictoriaAssaulter_ClotThink;
		
		//IDLE
		KillFeed_SetKillIcon(npc.index, "pro_smg");
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 250.0;
		npc.m_iOverlordComboAttack = 2;
		npc.m_iMovement = 1;
		npc.m_iJamChance = (GetRandomInt(0,100)==1 ? 1 : 0);
		npc.m_iCountSounds = 0;
		npc.m_flChangeMovement = 0.0;
		npc.Anger = GetRandomInt(0,100)>50 ? false : true;
		
		if(StrContains(data, "jamchance") != -1)
		{
			char buffers[3][64];
			ExplodeString(data, ";", buffers, sizeof(buffers), sizeof(buffers[]));
			ReplaceString(buffers[0], 64, "jamchance", "");
			npc.m_iJamChance = StringToInt(buffers[0]);
		}
		
		if(StrContains(data, "block_movement") != -1)
		{
			npc.m_iMovement = 0;
		}
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_pro_smg/c_pro_smg.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/sniper/sum23_preventative_measure/sum23_preventative_measure.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/sniper/xms2013_sniper_beard/xms2013_sniper_beard.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/all_class/sum20_spectre_cles_style1/sum20_spectre_cles_style1_sniper.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/all_class/sbox2014_camo_headband/sbox2014_camo_headband_sniper.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");

		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/sniper/dec23_rugged_rags/dec23_rugged_rags.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", skin);
		return npc;
	}
}

static void VictoriaAssaulter_ClotThink(int iNPC)
{
	VictoriaAssaulter npc = view_as<VictoriaAssaulter>(iNPC);
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
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}

	if(npc.m_iMovement && GetGameTime(npc.index) > npc.m_flChangeMovement)
		npc.m_iMovement=GetRandomInt(1, 4);

	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );

		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		switch(VictoriaAssaulterSelfDefense(npc,GetGameTime(npc.index),flDistanceToTarget))
		{
			case 0:
			{
				if(npc.m_iChanged_WalkCycle != 0)
				{
					npc.m_bisWalking = true;
					npc.m_bAllowBackWalking = false;
					npc.m_iChanged_WalkCycle = 0;
					npc.SetActivity("ACT_MP_RUN_SECONDARY");
					npc.m_flSpeed = 250.0;
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
			}
			case 1:
			{
				if(npc.m_iChanged_WalkCycle != 1)
				{
					npc.m_bisWalking = false;
					npc.m_bAllowBackWalking = false;
					npc.m_iChanged_WalkCycle = 1;
					npc.SetActivity("ACT_MP_STAND_SECONDARY");
					npc.m_flSpeed = 0.0;
					npc.StopPathing();
				}	
			}
			case 2:
			{
				if(npc.m_iChanged_WalkCycle != 2)
				{
					npc.m_bisWalking = false;
					npc.m_bAllowBackWalking = false;
					npc.m_iChanged_WalkCycle = 2;
					npc.SetActivity("ACT_MP_CROUCH_SECONDARY");
					npc.m_flSpeed = 0.0;
					npc.StopPathing();
				}
			}
			case 3:
			{
				if(npc.m_iChanged_WalkCycle != 3)
				{
					npc.m_bisWalking = true;
					npc.m_bAllowBackWalking = true;
					npc.m_iChanged_WalkCycle = 3;
					npc.SetActivity("ACT_MP_RUN_SECONDARY");
					npc.m_flSpeed = 250.0;
					npc.StartPathing();
				}
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget,_,vBackoffPos);
				npc.SetGoalVector(vBackoffPos, true);
			}
			case 4:
			{
				if(npc.m_iChanged_WalkCycle != 4)
				{
					npc.m_bisWalking = true;
					npc.m_bAllowBackWalking = true;
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_MP_RUN_SECONDARY");
					npc.m_flSpeed = 250.0;
					npc.StartPathing();
				}
				if(flDistanceToTarget < npc.GetLeadRadius()) 
				{
					static float vOrigin[3], vAngles[3];
					GetEntPropVector(npc.index, Prop_Data, "m_angRotation", vAngles);
					vAngles[0]=5.0;
					vAngles[1]+=90.0;
					if(vAngles[1]>180.0)
						vAngles[1]-=360.0;
					EntityLookPoint(npc.index, vAngles, VecSelfNpc, vOrigin);
					npc.SetGoalVector(vOrigin);
				}
				else 
				{
					npc.SetGoalEntity(npc.m_iTarget);
				}
			}
			case 5:
			{
				if(npc.m_iChanged_WalkCycle != 4)
				{
					npc.m_bisWalking = true;
					npc.m_bAllowBackWalking = true;
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_MP_RUN_SECONDARY");
					npc.m_flSpeed = 250.0;
					npc.StartPathing();
				}
				if(flDistanceToTarget < npc.GetLeadRadius()) 
				{
					static float vOrigin[3], vAngles[3];
					GetEntPropVector(npc.index, Prop_Data, "m_angRotation", vAngles);
					vAngles[0]=5.0;
					vAngles[1]-=90.0;
					if(vAngles[1]<-180.0)
						vAngles[1]+=360.0;
					EntityLookPoint(npc.index, vAngles, VecSelfNpc, vOrigin);
					npc.SetGoalVector(vOrigin);
				}
				else 
				{
					npc.SetGoalEntity(npc.m_iTarget);
				}
			}
		}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

static Action VictoriaAssaulter_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VictoriaAssaulter npc = view_as<VictoriaAssaulter>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}

	return Plugin_Changed;
	}

static void VictoriaAssaulter_NPCDeath(int entity)
{
	VictoriaAssaulter npc = view_as<VictoriaAssaulter>(entity);
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

static int VictoriaAssaulterSelfDefense(VictoriaAssaulter npc, float gameTime, float distance)
{
	if(npc.m_bFUCKYOU)
	{
		switch(npc.m_iCountSounds)
		{
			case 0, 1:
			{
				if(gameTime > npc.m_flNextRangedAttack)
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY", false);
					npc.PlayEmptySound();
					npc.m_iCountSounds++;
					npc.m_flNextRangedAttack = gameTime + (npc.m_iCountSounds<=0 ? 0.2 : 0.3);
				}
			}
			case 2:
			{
				if(gameTime > npc.m_flNextRangedAttack)
				{
					npc.AddGesture("ACT_MP_RELOAD_STAND_SECONDARY", true,_,_,1.2);
					npc.PlayJamSound();
					npc.PlayReloadSound();
					npc.m_iCountSounds++;
					npc.m_flNextRangedAttack = gameTime + 1.0;
				}
			}
			case 3:
			{
				if(gameTime > npc.m_flNextRangedAttack)
				{
					npc.m_bFUCKYOU=false;
					npc.m_iCountSounds=0;
					npc.m_iOverlordComboAttack=2;
					npc.m_flNextRangedAttack=gameTime + 0.3;
				}
			}
		}
		return 1;
	}
	int target;
	//some Ranged units will behave differently.
	//not this one.
	target = npc.m_iTarget;
	if(!IsValidEnemy(npc.index,target))
		return 0;
	float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
	if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.0))
	{
		int Enemy_I_See = Can_I_See_Enemy(npc.index, target);
					
		if(IsValidEnemy(npc.index, Enemy_I_See))
		{
			npc.m_flChangeMovement=gameTime+GetRandomFloat(1.5, 2.5);
			if(gameTime > npc.m_flNextRangedAttack)
			{
				npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY", false);
				npc.PlayRangeSound();
				npc.FaceTowards(vecTarget, 20000.0);
				Handle swingTrace;
				if(npc.DoSwingTrace(swingTrace, target, { 9999.0, 9999.0, 9999.0 }))
				{
					target = TR_GetEntityIndex(swingTrace);	
						
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					float origin[3], angles[3];
					view_as<CClotBody>(npc.m_iWearable1).GetAttachment("muzzle", origin, angles);
					ShootLaser(npc.m_iWearable1, "bullet_tracer02_blue_crit", origin, vecHit, false );
					float Cooldown = 0.3;
					if(npc.m_iOverlordComboAttack <= 0)
						npc.m_iOverlordComboAttack = 2;
					else
					{
						npc.m_iOverlordComboAttack --;
						Cooldown = 0.2;
					}
					if(NpcStats_VictorianCallToArms(npc.index))
						Cooldown *= 0.5;
					npc.m_flNextRangedAttack = gameTime + Cooldown;

					if(IsValidEnemy(npc.index, target))
					{
						float damageDealt = 5.5;
						if(ShouldNpcDealBonusDamage(target))
							damageDealt *= 3.0;

						SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, vecHit);
					}
					
					if(npc.m_iJamChance&&GetRandomInt(0,100)<npc.m_iJamChance||npc.m_iJamChance==100)
					{
						npc.m_bFUCKYOU=true;
					}
				}
				delete swingTrace;
			}
			switch(npc.m_iMovement)
			{
				case 0, 1:return 1;
				case 2:return 2;
				case 3:
				{
					if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 9.0)||ShouldNpcDealBonusDamage(target))
					{
						return 0;
					}
					else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 8.0))
					{
						if(Can_I_See_Enemy_Only(npc.index, target))
						{
							return 3;
						}
					}
				}
				case 4:
				{
					if(gameTime > npc.m_flNextMeleeAttack)
					{
						npc.Anger=!npc.Anger;
						npc.m_flNextMeleeAttack = gameTime + GetRandomFloat(0.5, 1.5);
					}
					if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 9.0)||ShouldNpcDealBonusDamage(target))
					{
						return 0;
					}
					else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 8.0))
					{
						if(Can_I_See_Enemy_Only(npc.index, target))
						{
							return (npc.Anger ? 5 : 4);
						}
					}
				}
			}
		}
		return 0;
	}
	
	return 0;
}