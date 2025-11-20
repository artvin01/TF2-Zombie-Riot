#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	")vo/engineer_negativevocalization01.mp3",
	")vo/engineer_negativevocalization02.mp3",
	")vo/engineer_negativevocalization03.mp3",
	")vo/engineer_negativevocalization04.mp3",
	")vo/engineer_negativevocalization05.mp3",
	")vo/engineer_negativevocalization06.mp3",
	")vo/engineer_negativevocalization07.mp3",
	")vo/engineer_negativevocalization08.mp3",
	")vo/engineer_negativevocalization09.mp3",
	")vo/engineer_negativevocalization10.mp3",
	")vo/engineer_negativevocalization11.mp3",
	")vo/engineer_negativevocalization12.mp3"
};

static const char g_HurtSounds[][] = {
	"vo/engineer_painsharp01.mp3",
	"vo/engineer_painsharp02.mp3",
	"vo/engineer_painsharp03.mp3",
	"vo/engineer_painsharp04.mp3",
	"vo/engineer_painsharp05.mp3",
	"vo/engineer_painsharp06.mp3",
	"vo/engineer_painsharp07.mp3",
	"vo/engineer_painsharp08.mp3"
};

static const char g_IdleAlertedSounds[][] = {
	"vo/engineer_mvm_mannhattan_gate_atk01.mp3",
	"vo/engineer_mvm_mannhattan_gate_atk02.mp3",
	"vo/engineer_mvm_mannhattan_gate_atk03.mp3"
};

static const char g_SapperHitSounds[][] = {
	"weapons/rescue_ranger_charge_01.wav",
	"weapons/rescue_ranger_charge_02.wav"
};

static const char g_MeleeAttackSounds[] = "weapons/knife_swing.wav";
static const char g_MeleeHitSounds[] = "weapons/bat_baseball_hit_flesh.wav";

void VictorianWelder_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Welder");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_welder");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_welder"); 
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
	PrecacheSoundArray(g_SapperHitSounds);
	PrecacheSound(g_MeleeAttackSounds);
	PrecacheSound(g_MeleeHitSounds);
	PrecacheModel("models/player/engineer.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return VictorianWelder(vecPos, vecAng, ally, data);
}

methodmap VictorianWelder < CClotBody
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
		EmitSoundToAll(g_MeleeAttackSounds, this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds, this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlaySapperHitSound() 
	{
		EmitSoundToAll(g_SapperHitSounds[GetRandomInt(0, sizeof(g_SapperHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	property float m_flArmorToGive
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flCallToArmArmorToGive
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flExtraArmorResist
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flMaxArmor
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	
	public VictorianWelder(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		VictorianWelder npc = view_as<VictorianWelder>(CClotBody(vecPos, vecAng, "models/player/engineer.mdl", "1.15", "25000", ally,false));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_ITEM2");
		if(iActivity > 0) npc.StartActivity(iActivity);

		SetVariantInt(5);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		func_NPCDeath[npc.index] = VictorianWelder_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = VictorianWelder_OnTakeDamage;
		func_NPCThink[npc.index] = VictorianWelder_ClotThink;
		
		//IDLE
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flSpeed = 280.0;
		npc.m_flArmorToGive = 0.25;
		npc.m_flCallToArmArmorToGive = 2.0;
		npc.m_flExtraArmorResist = 0.5;
		npc.m_flMaxArmor = 1.5;
		
		npc.StartPathing();
		
		//Maybe used for special waves
		static char countext[5][256];
		int count = ExplodeString(data, ";", countext, sizeof(countext), sizeof(countext[]));
		for(int i = 0; i < count; i++)
		{
			if(i>=count)break;
			else if(StrContains(countext[i], "maxarmor") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "maxarmor", "");
				npc.m_flMaxArmor = StringToFloat(countext[i]);
			}
			else if(StrContains(countext[i], "armor") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "armor", "");
				npc.m_flArmorToGive = StringToFloat(countext[i]);
			}
			else if(StrContains(countext[i], "calltoarmor") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "calltoarmor", "");
				npc.m_flCallToArmArmorToGive = StringToFloat(countext[i]);
			}
			else if(StrContains(countext[i], "resist") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "resist", "");
				npc.m_flExtraArmorResist = StringToFloat(countext[i]);
			}
		}
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop_partner/weapons/c_models/c_dex_arm/c_dex_arm.mdl");
		SetVariantString("2.5");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.m_iWearable1, 82, 82, 81, 255);

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/engineer/dec15_winter_backup/dec15_winter_backup.mdl");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetVariantString("1.5");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		SetEntityRenderColor(npc.m_iWearable2, 100, 100, 100, 255);

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/engineer/sum22_lawnmaker/sum22_lawnmaker.mdl");

		SetEntityRenderColor(npc.m_iWearable3, 50, 50, 50, 255);
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/all_class/hwn2020_gourd_grin/hwn2020_gourd_grin_engineer.mdl");
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.m_iWearable4, 0, 0, 0, 255);

		npc.m_iWearable5= npc.EquipItem("head", "models/workshop/player/items/engineer/hwn2024_nuclear_necessity/hwn2024_nuclear_necessity.mdl");
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.m_iWearable5, 150, 150, 150, 255);

		return npc;
	}
}

static void VictorianWelder_ClotThink(int iNPC)
{
	VictorianWelder npc = view_as<VictorianWelder>(iNPC);
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
		VictorianWelderSelfDefense(npc,GetGameTime(npc.index), flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

static Action VictorianWelder_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VictorianWelder npc = view_as<VictorianWelder>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

static void VictorianWelder_NPCDeath(int entity)
{
	VictorianWelder npc = view_as<VictorianWelder>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();	

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

static void VictorianWelderSelfDefense(VictorianWelder npc, float gameTime, float distance)
{
	if(distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
	{
		if(npc.m_flNextMeleeAttack < gameTime)
		{
			if(!npc.m_flAttackHappenswillhappen)
			{
				npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM2");
				npc.PlayMeleeSound();
				npc.m_flAttackHappens = gameTime+0.25;
				npc.m_flAttackHappens_bullshit = gameTime+0.39;
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
						float damageDealt = 75.0;
						if(ShouldNpcDealBonusDamage(target))
						{
							damageDealt*=5.0;
							float fixedArmorgain = float(ReturnEntityMaxHealth(npc.index))*npc.m_flArmorToGive;
							if(NpcStats_VictorianCallToArms(npc.index))
								fixedArmorgain *= npc.m_flCallToArmArmorToGive;
							GrantEntityArmor(npc.index, false, npc.m_flMaxArmor, npc.m_flExtraArmorResist, 0, fixedArmorgain);
							npc.PlaySapperHitSound();
						}
						else
							npc.PlayMeleeHitSound();
						SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);
					} 
				}
				delete swingTrace;
				npc.m_flNextMeleeAttack = gameTime + 1.2;
				npc.m_flAttackHappenswillhappen = false;
			}
			else if(npc.m_flAttackHappens_bullshit < gameTime && npc.m_flAttackHappenswillhappen)
			{
				npc.m_flAttackHappenswillhappen = false;
				npc.m_flNextMeleeAttack = gameTime + 1.2;
			}
		}
	}
}

