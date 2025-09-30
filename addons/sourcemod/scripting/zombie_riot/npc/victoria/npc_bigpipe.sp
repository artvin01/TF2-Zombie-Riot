#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/demoman_sf13_magic_reac03.mp3",
	"vo/demoman_sf13_magic_reac05.mp3"
};

static const char g_HurtSounds[][] = {
	"vo/demoman_painsharp01.mp3",
	"vo/demoman_painsharp02.mp3",
	"vo/demoman_painsharp03.mp3",
	"vo/demoman_painsharp04.mp3",
	"vo/demoman_painsharp05.mp3",
	"vo/demoman_painsharp06.mp3",
	"vo/demoman_painsharp07.mp3"
};

static const char g_IdleAlertedSounds[][] = {
	"vo/demoman_sf13_midnight02.mp3",
	"vo/demoman_sf13_midnight04.mp3",
	"vo/demoman_sf13_midnight05.mp3",
	"vo/demoman_sf13_midnight06.mp3"
};

static const char g_ExplosionSounds[][]= {
	"weapons/explode1.wav",
	"weapons/explode2.wav",
	"weapons/explode3.wav"
};

static const char g_IntimidatingFireSounds[][]= {
	"weapons/fx/nearmiss/bulletltor08.wav",
	"weapons/fx/nearmiss/bulletltor09.wav",
	"weapons/fx/nearmiss/bulletltor10.wav",
	"weapons/fx/nearmiss/bulletltor13.wav",
	"weapons/fx/nearmiss/bulletltor14.wav"
};

static const char g_RangeAttackSounds[] = "mvm/giant_demoman/giant_demoman_grenade_shoot.wav";

static const char g_ReloadSound[] = "weapons/ar2/npc_ar2_reload.wav";

static bool b_TheGoons;

void VictoriaBigpipe_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Bigpipe");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_bigpipe");
	strcopy(data.Icon, sizeof(data.Icon), "big_pipe");
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
	PrecacheSoundArray(g_ExplosionSounds);
	PrecacheSoundArray(g_IntimidatingFireSounds);
	PrecacheSound(g_RangeAttackSounds);
	PrecacheSound(g_ReloadSound);
	PrecacheSound("weapons/ar2/fire1.wav");
	PrecacheModel("models/player/demo.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return VictoriaBigpipe(vecPos, vecAng, ally, data);
}

methodmap VictoriaBigpipe < CClotBody
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
	public void PlayReloadSound() 
	{
		EmitSoundToAll(g_ReloadSound, this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayARSound()
	{
		EmitSoundToAll("weapons/ar2/fire1.wav", this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayGrenadeSound()
	{
		EmitSoundToAll(g_RangeAttackSounds, this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME - 0.2);
	}
	public void PlayIntimidatingFireSound(int Target)
	{
		EmitSoundToAll(g_IntimidatingFireSounds[GetRandomInt(0, sizeof(g_IntimidatingFireSounds) - 1)], Target, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMorphineShotSound()
	{
		EmitSoundToAll("items/medshot4.wav", this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		EmitSoundToAll("items/medshot4.wav", this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	property float m_flWeaponSwitchCooldown
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	public void SetWeaponModel(const char[] model, float Scale = 1.0)		//dynamic weapon model change, don't touch
	{
		if(IsValidEntity(this.m_iWearable1))
			RemoveEntity(this.m_iWearable1);
		
		if(model[0])
		{
			this.m_iWearable1 = this.EquipItem("head", model);
			if(Scale != 1.0)
			{
				char buffer[32];
				FormatEx(buffer, sizeof(buffer), "%.2f", Scale);
				SetVariantString(buffer);
				AcceptEntityInput(this.m_iWearable1, "SetModelScale");
			}
		}
	}
	
	property int m_iBirdEye
	{
		public get()							{ return i_AmountProjectiles[this.index]; }
		public set(int TempValueForProperty) 	{ i_AmountProjectiles[this.index] = TempValueForProperty; }
	}
	property int m_iHarbringer
	{
		public get()							{ return i_State[this.index]; }
		public set(int TempValueForProperty) 	{ i_State[this.index] = TempValueForProperty; }
	}
	property int m_iSaveClip
	{
		public get()							{ return i_AttacksTillMegahit[this.index]; }
		public set(int TempValueForProperty) 	{ i_AttacksTillMegahit[this.index] = TempValueForProperty; }
	}
	property int m_iIntimidatingFire
	{
		public get()							{ return i_ArmorSetting[this.index][1]; }
		public set(int TempValueForProperty) 	{ i_ArmorSetting[this.index][1] = TempValueForProperty; }
	}
	property float m_flSpeedModify
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flModifyTime
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	
	public VictoriaBigpipe(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		VictoriaBigpipe npc = view_as<VictoriaBigpipe>(CClotBody(vecPos, vecAng, "models/player/demo.mdl", "1.0", "1250", ally,false));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("ACT_MP_RUN_SECONDARY");
			
		SetVariantInt(4);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		b_TheGoons=false;
		if(StrContains(data, "icononly") != -1)
		{
			func_NPCDeath[npc.index] = INVALID_FUNCTION;
			func_NPCOnTakeDamage[npc.index] = INVALID_FUNCTION;
			func_NPCThink[npc.index] = INVALID_FUNCTION;
			
			b_NpcForcepowerupspawn[npc.index] = 0;
			i_RaidGrantExtra[npc.index] = 0;
			b_DissapearOnDeath[npc.index] = true;
			b_DoGibThisNpc[npc.index] = true;
			SmiteNpcToDeath(npc.index);
			return npc;
		}

		if(StrContains(data, "the_goons") != -1)
			b_TheGoons=true;
		else if(StrContains(data, "birdeye"))
		{
			npc.m_iBirdEye=-1;
			npc.m_iHarbringer=-1;
			//The NPC name will be displayed normally only after 1 frame.
			switch(GetRandomInt(0, 4))
			{
				case 0:NPCPritToChat(npc.index, "{forestgreen}", "bigpipe_Talk_01-1", false, true);
				case 1:NPCPritToChat(npc.index, "{forestgreen}", "bigpipe_Talk_01-2", false, true);
				case 2:NPCPritToChat(npc.index, "{forestgreen}", "bigpipe_Talk_01-3", false, true);
				case 3:NPCPritToChat(npc.index, "{forestgreen}", "bigpipe_Talk_01-4", false, true);
				case 4:NPCPritToChat(npc.index, "{forestgreen}", "bigpipe_Talk_01-5", false, true);
			}
		}

		func_NPCDeath[npc.index] = view_as<Function>(VictoriaBigpipe_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(VictoriaBigpipe_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(VictoriaBigpipe_ClotThink);
		
		//IDLE
		npc.m_iChanged_WalkCycle=1;
		npc.m_flGetClosestTargetTime=0.0;
		npc.StartPathing();
		npc.m_flSpeed=180.0;
		npc.m_iOverlordComboAttack=6;
		npc.m_iSaveClip=31;
		npc.g_TimesSummoned=0;
		npc.m_iIntimidatingFire=0;
		npc.m_bReloaded=false;
		npc.Anger=true;
		npc.m_flSpeedModify=1.0;
		npc.m_flModifyTime=0.0;
		
		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		GiveNpcOutLineLastOrBoss(npc.index, true);
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.SetWeaponModel("models/weapons/c_models/c_grenadelauncher/c_grenadelauncher.mdl", 1.25);

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/soldier/sum19_dancing_doe/sum19_dancing_doe.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/demo/demo_beardpipe_s2/demo_beardpipe_s2.mdl");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/all_class/sum19_staplers_specs/sum19_staplers_specs_demo.mdl");
		SetVariantString("1.1");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/demo/hwn2023_mad_lad/hwn2023_mad_lad.mdl");

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 3);
		SetEntityRenderColor(npc.m_iWearable1, 50, 150, 255, 255);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.m_iWearable2, 0, 0, 0, 255);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);

		return npc;
	}
}

static void VictoriaBigpipe_ClotThink(int iNPC)
{
	VictoriaBigpipe npc = view_as<VictoriaBigpipe>(iNPC);
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
	
	if(npc.m_flModifyTime && npc.m_flModifyTime < GetGameTime(npc.index))
	{
		npc.m_flSpeedModify=1.0;
		npc.m_flModifyTime=0.0;
	}
	
	npc.m_iTargetWalkTo=npc.m_iTarget;
	if(!IsEntityAlive(npc.m_iHarbringer)&&npc.m_iHarbringer!=-1)
	{
		switch(GetRandomInt(0, 2))
		{
			case 0:NPCPritToChat(npc.index, "{forestgreen}", "bigpipe_Talk_03-1", false, false);
			case 1:NPCPritToChat(npc.index, "{forestgreen}", "bigpipe_Talk_03-2", false, false);
			case 2:NPCPritToChat(npc.index, "{forestgreen}", "bigpipe_Talk_03-3", false, false);
		}
		npc.m_iHarbringer=-1;
	}
	else if(IsEntityAlive(npc.m_iHarbringer)&&npc.m_iHarbringer!=-1)
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iHarbringer, vecTarget);
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		if(flDistanceToTarget>NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*29.6)
			npc.m_iTargetWalkTo=npc.m_iHarbringer;
	}
	
	if(!IsEntityAlive(npc.m_iBirdEye)&&npc.m_iBirdEye!=-1)
	{
		switch(GetRandomInt(0, 2))
		{
			case 0:NPCPritToChat(npc.index, "{forestgreen}", "bigpipe_Talk_02-1", false, false);
			case 1:NPCPritToChat(npc.index, "{forestgreen}", "bigpipe_Talk_02-2", false, false);
			case 2:NPCPritToChat(npc.index, "{forestgreen}", "bigpipe_Talk_02-3", false, false);
		}
		npc.m_iBirdEye=-1;
	}
	else if(IsEntityAlive(npc.m_iBirdEye)&&!IsEntityAlive(npc.m_iHarbringer)&&npc.g_TimesSummoned!=195)
		npc.m_iTargetWalkTo=npc.m_iBirdEye;

	if(b_TheGoons&&npc.g_TimesSummoned!=195&&!IsEntityAlive(npc.m_iBirdEye)&&!IsEntityAlive(npc.m_iHarbringer))
	{
		npc.PlayMorphineShotSound();
		npc.m_flSpeedModify=1.375;
		npc.m_flModifyTime=GetGameTime(npc.index) + 30.0;
		
		int MaxHealth = ReturnEntityMaxHealth(npc.index);
		HealEntityGlobal(npc.index, npc.index, float(MaxHealth)*0.15, 0.5, 3.0);
		ApplyStatusEffect(npc.index, npc.index, "Intangible", 30.0);
		ApplyStatusEffect(npc.index, npc.index, "Fluid Movement", 30.0);
		ApplyStatusEffect(npc.index, npc.index, "Solid Stance", 30.0);
		ApplyStatusEffect(npc.index, npc.index, "Shook Head", 30.0);
		IncreaseEntityDamageTakenBy(npc.index, 0.9, 30.0);
		npc.g_TimesSummoned=195;
	}
	
	//Enemy in visual, 3 Intimidating Fire
	if(npc.m_iIntimidatingFire<3&&Can_I_See_Enemy(npc.index, npc.m_iTarget))
	{
		if(npc.m_iChanged_WalkCycle != 2)
		{
			int LaterUpdate=npc.m_iSaveClip;
			npc.m_iSaveClip=npc.m_iOverlordComboAttack;
			npc.m_iOverlordComboAttack=LaterUpdate;
			KillFeed_SetKillIcon(npc.index, "the_classic");
			npc.SetWeaponModel("models/weapons/c_models/c_tfc_sniperrifle/c_tfc_sniperrifle.mdl", 1.25);
			npc.m_iChanged_WalkCycle=2;
		}
		if(GetGameTime(npc.index) > npc.m_flNextMeleeAttack)
		{
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
			vecTarget[0] += GetRandomFloat(-50.0, 50.0);
			vecTarget[1] += GetRandomFloat(-50.0, 50.0);
			float origin[3], angles[3];
			view_as<CClotBody>(npc.index).GetAttachment("effect_hand_r", origin, angles);
			ShootLaser(npc.index, "bullet_tracer01_red", origin, vecTarget, false);
			npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY",_,_,_,1.5);
			npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.1;
			npc.PlayARSound();
			npc.PlayIntimidatingFireSound(npc.m_iTarget);
			npc.m_iIntimidatingFire++;
			npc.m_iOverlordComboAttack--;
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			if(GetVectorDistance(vecTarget, VecSelfNpc, true) < npc.GetLeadRadius()) 
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
		npc.m_flSpeed = 10.0*npc.m_flSpeedModify;
		return;
	}
	else if(npc.m_flWeaponSwitchCooldown < GetGameTime(npc.index))
	{
		//Swtich modes depending on area.
		npc.m_flWeaponSwitchCooldown = GetGameTime(npc.index) + 5.0;
		static float flMyPos[3];
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flMyPos);
		static float hullcheckmaxs[3];
		static float hullcheckmins[3];

		//Defaults:
		//hullcheckmaxs = view_as<float>( { 24.0, 24.0, 72.0 } );
		//hullcheckmins = view_as<float>( { -24.0, -24.0, 0.0 } );

		hullcheckmaxs = view_as<float>( { 35.0, 35.0, 500.0 } ); //check if above is free
		hullcheckmins = view_as<float>( { -35.0, -35.0, 17.0 } );

		if(!IsSpaceOccupiedWorldOnly(flMyPos, hullcheckmins, hullcheckmaxs, npc.index)&&npc.Anger)
		{
			if(npc.m_iChanged_WalkCycle != 1)
			{
				int LaterUpdate=npc.m_iSaveClip;
				npc.m_iSaveClip=npc.m_iOverlordComboAttack;
				npc.m_iOverlordComboAttack=LaterUpdate;
				
				KillFeed_SetKillIcon(npc.index, "tf_projectile_pipe");
				npc.SetWeaponModel("models/weapons/c_models/c_grenadelauncher/c_grenadelauncher.mdl", 1.25);
				SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 3);
				SetEntityRenderColor(npc.m_iWearable1, 50, 150, 255, 255);
				npc.m_iChanged_WalkCycle=1;
			}
		}
		else
		{
			if(npc.m_iChanged_WalkCycle != 2)
			{
				int LaterUpdate=npc.m_iSaveClip;
				npc.m_iSaveClip=npc.m_iOverlordComboAttack;
				npc.m_iOverlordComboAttack=LaterUpdate;
				KillFeed_SetKillIcon(npc.index, "the_classic");
				npc.SetWeaponModel("models/weapons/c_models/c_tfc_sniperrifle/c_tfc_sniperrifle.mdl", 1.25);
				npc.m_iChanged_WalkCycle=2;
			}
		}
	}
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		switch(VictoriaBigpipeSelfDefense(npc, GetGameTime(npc.index), flDistanceToTarget))
		{
			case 0:
			{
				npc.StartPathing();
				//We run at them.
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
				npc.m_bAllowBackWalking = false;
				npc.m_flSpeed = 200.0*npc.m_flSpeedModify;
			}
			case 1:
			{
				if(npc.m_bReloaded)
				{
					if(npc.m_flNextMeleeAttack > GetGameTime(npc.index))
					{
						npc.StartPathing();
						npc.m_flSpeed = 350.0*npc.m_flSpeedModify;
						npc.m_bAllowBackWalking = true;
						float vBackoffPos[3];
						BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTargetWalkTo,_,vBackoffPos);
						npc.SetGoalVector(vBackoffPos, true);
					}
					else
					{
						npc.m_bAllowBackWalking = false;
						npc.m_bReloaded = false;
					}
				}
				else
				{
					//Stand still.
					npc.StopPathing();
					npc.m_flSpeed = 0.0;
					npc.m_bAllowBackWalking = false;
				}
			}
			case 2:
			{
				npc.StartPathing();
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
				npc.m_bAllowBackWalking = false;
				npc.m_flSpeed = 300.0*npc.m_flSpeedModify;
			}
			case 3:
			{
				npc.StartPathing();
				if(flDistanceToTarget < npc.GetLeadRadius()) 
				{
					float vPredictedPos[3];
					PredictSubjectPosition(npc, npc.m_iTargetWalkTo,_,_, vPredictedPos);
					npc.SetGoalVector(vPredictedPos);
				}
				else 
				{
					npc.SetGoalEntity(npc.m_iTargetWalkTo);
				}
				npc.m_bAllowBackWalking = false;
				npc.m_flSpeed = 345.0*npc.m_flSpeedModify;
			}
			case 4:
			{
				npc.StartPathing();
				npc.m_flSpeed = 280.0*npc.m_flSpeedModify;
				npc.m_bAllowBackWalking = true;
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTargetWalkTo,_,vBackoffPos);
				npc.SetGoalVector(vBackoffPos, true); //update more often, we need it
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

static Action VictoriaBigpipe_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VictoriaBigpipe npc = view_as<VictoriaBigpipe>(victim);
		
	if(attacker<=0||!IsValidEntity(attacker))
		return Plugin_Continue;
		
	if(npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	if(npc.m_iTargetWalkTo==npc.m_iBirdEye&&npc.g_TimesSummoned>1&&npc.g_TimesSummoned<30&&npc.g_TimesSummoned!=195)
	{
		if(!IsValidClient(attacker)&&IsValidEnemy(npc.index, attacker))
			npc.g_TimesSummoned=30;
		else if(!IsPlayerAlive(attacker) || TeutonType[attacker] != TEUTON_NONE || dieingstate[attacker] != 0)
		{
			//none
		}
		else
			npc.g_TimesSummoned=30;
	}
	
	return Plugin_Changed;
}

static void VictoriaBigpipe_NPCDeath(int entity)
{
	VictoriaBigpipe npc = view_as<VictoriaBigpipe>(entity);
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

static int VictoriaBigpipeSelfDefense(VictoriaBigpipe npc, float gameTime, float distance)
{
	if(npc.m_iTargetWalkTo!=npc.m_iTarget)
	{
		if(npc.m_iTargetWalkTo==npc.m_iBirdEye&&npc.g_TimesSummoned!=195)
		{
			switch(npc.g_TimesSummoned)
			{
				case 0:
				{
					float vecTarget[3]; WorldSpaceCenter(npc.m_iTargetWalkTo, vecTarget);
				
					float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
					float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
					if(flDistanceToTarget>NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*5.0)
						return 3;
					else
						npc.g_TimesSummoned=1;
				}
				case 1:
				{
					if(GetEntProp(npc.index, Prop_Data, "m_iHealth")>=ReturnEntityMaxHealth(npc.index))
					{
						npc.g_TimesSummoned=195;
						return 1;
					}
					switch(GetRandomInt(0, 1))
					{
						case 0:NPCPritToChat(npc.index, "{forestgreen}", "bigpipe_Talk_04-1", false, false);
						case 1:NPCPritToChat(npc.index, "{forestgreen}", "bigpipe_Talk_04-2", false, false);
					}
					npc.m_flWeaponSwitchCooldown = gameTime + 1.0;
					npc.SetActivity("ACT_MP_CROUCH_SECONDARY");
					if(IsValidEntity(npc.m_iWearable1))
						RemoveEntity(npc.m_iWearable1);
					/*I gave up because I couldn't place it where I wanted.
					npc.m_iWearable1 = npc.EquipItemSeperate("models/zombie_riot/weapons/custom_weaponry_1_51.mdl",_,1,1.001,_,true);
					SetVariantString("1.25");
					AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
					SetEntProp(npc.m_iWearable1, Prop_Send, "m_nBody", 128);
					float origin[3], angles[3];
					GetAbsOrigin(npc.m_iWearable1, origin);
					GetEntPropVector(npc.index, Prop_Data, "m_angRotation", angles);
					origin[0] += 12.0;
					origin[1] += 8.0;
					origin[2] -= 20.0;
					angles[0] -= 90.0;
					angles[1] -= 80.0;
					TeleportEntity(npc.m_iWearable1, origin, angles, NULL_VECTOR);
					SetVariantString("!activator");
					AcceptEntityInput(npc.m_iWearable1, "SetParent", npc.index);
					SetVariantString("head");
					AcceptEntityInput(npc.m_iWearable1, "SetParentAttachmentMaintainOffset"); 
					SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 0);
					MakeObjectIntangeable(npc.m_iWearable1);*/
					npc.SetWeaponModel("models/zombie_riot/weapons/custom_weaponry_1_51.mdl", 1.25);
					SetEntProp(npc.m_iWearable1, Prop_Send, "m_nBody", 128);
					
					npc.g_TimesSummoned=2;
					return 1;
				}
				default:
				{
					if(npc.g_TimesSummoned>1&&npc.g_TimesSummoned<30)
					{
						int MaxHealth = ReturnEntityMaxHealth(npc.index);
						npc.m_flWeaponSwitchCooldown = gameTime + 1.0;
						IncreaseEntityDamageTakenBy(npc.index, 0.8, 0.3);
						HealEntityGlobal(npc.index, npc.index, float(MaxHealth)*0.01, 1.0);
						if(GetEntProp(npc.index, Prop_Data, "m_iHealth")>=MaxHealth)
							npc.g_TimesSummoned=30;
						else
							npc.g_TimesSummoned++;
					}
					else
					{
						if(b_TheGoons)
						{
							npc.PlayMorphineShotSound();
							npc.m_flSpeedModify=1.375;
							npc.m_flModifyTime=gameTime + 30.0;
							
							int MaxHealth = ReturnEntityMaxHealth(npc.index);
							HealEntityGlobal(npc.index, npc.index, float(MaxHealth)*0.15, 0.5, 3.0);
							ApplyStatusEffect(npc.index, npc.index, "Intangible", 30.0);
							ApplyStatusEffect(npc.index, npc.index, "Fluid Movement", 30.0);
							ApplyStatusEffect(npc.index, npc.index, "Solid Stance", 30.0);
							ApplyStatusEffect(npc.index, npc.index, "Shook Head", 30.0);
							IncreaseEntityDamageTakenBy(npc.index, 0.9, 30.0);
						}
					
						npc.SetActivity("ACT_MP_RUN_SECONDARY");
						if(npc.m_iChanged_WalkCycle==1)
						{
							KillFeed_SetKillIcon(npc.index, "tf_projectile_pipe");
							npc.SetWeaponModel("models/weapons/c_models/c_grenadelauncher/c_grenadelauncher.mdl", 1.25);
							SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 3);
							SetEntityRenderColor(npc.m_iWearable1, 50, 150, 255, 255);
						}
						else if(npc.m_iChanged_WalkCycle==2)
						{
							KillFeed_SetKillIcon(npc.index, "the_classic");
							npc.SetWeaponModel("models/weapons/c_models/c_tfc_sniperrifle/c_tfc_sniperrifle.mdl", 1.25);
						}
						npc.g_TimesSummoned=195;
					}
					return 1;
				}
			}
		}
		return 3;
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(npc.m_iOverlordComboAttack < 1)
		{
			if(b_TheGoons)
			{
				npc.m_flWeaponSwitchCooldown = gameTime + 0.2;
				npc.m_flNextMeleeAttack = gameTime + 1.5;
				if(npc.m_iChanged_WalkCycle==1)
				{
					npc.m_iOverlordComboAttack = 6;
					npc.Anger=false;
				}
				else if(npc.m_iChanged_WalkCycle==2)
				{
					npc.m_iOverlordComboAttack = 31;
					npc.Anger=true;
				}
				if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 15.0))
				{
					//target is too far, try to close in
					return 2;
				}
				else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 14.0))
				{
					if(Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
					{
						//target is too close, try to keep distance
						return 4;
					}
				}
			}
			else
			{
				if(npc.m_iChanged_WalkCycle==1)
				{
					npc.m_flNextMeleeAttack = gameTime + 2.5;
					npc.m_flWeaponSwitchCooldown = gameTime + 2.5;
					npc.AddGesture("ACT_MP_RELOAD_STAND_SECONDARY", true,_,_,0.37);
					npc.PlayReloadSound();
					npc.m_iOverlordComboAttack = 6;
				}
				else if(npc.m_iChanged_WalkCycle==2)
				{
					npc.m_bReloaded=true;
					npc.m_flNextMeleeAttack = gameTime + 1.5;
					npc.m_flWeaponSwitchCooldown = gameTime + 1.5;
					npc.AddGesture("ACT_MP_RELOAD_STAND_PRIMARY", true,_,_,0.5);
					npc.PlayReloadSound();
					npc.m_iOverlordComboAttack = 31;
				}
				return 1;
			}
		}
		if(npc.m_bReloaded)
		{
			npc.m_bAllowBackWalking = false;
			npc.m_bReloaded = false;
		}
		
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 20.0))
		{
			float VecAim[3]; WorldSpaceCenter(npc.m_iTarget, VecAim );
			npc.FaceTowards(VecAim, 20000.0);
			int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				float RocketSpeed = 1500.0;
				float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
				float VecStart[3]; WorldSpaceCenter(npc.index, VecStart );
				float vecDest[3];
				vecDest = vecTarget;
				vecDest[0] += GetRandomFloat(-50.0, 50.0);
				vecDest[1] += GetRandomFloat(-50.0, 50.0);
				if(npc.m_iChanged_WalkCycle==1)
				{
					float SpeedReturn[3];
					npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY");
					int RocketGet = npc.FireRocket(vecDest, 0.0, RocketSpeed, "models/weapons/w_models/w_grenade_grenadelauncher.mdl", 1.2);
					SDKHook(RocketGet, SDKHook_StartTouch, HEGrenade_StartTouch);
					SetEntProp(RocketGet, Prop_Send, "m_nSkin", 1);
					//Reducing gravity, reduces speed, lol.
					//SetEntityGravity(RocketGet, 1.0); 	
					//I dont care if its not too accurate, ig they suck with the weapon idk lol, lore.
					ArcToLocationViaSpeedProjectile(VecStart, vecDest, SpeedReturn, 1.75, 1.0);
					//SetEntityMoveType(RocketGet, MOVETYPE_FLYGRAVITY);
					TeleportEntity(RocketGet, NULL_VECTOR, NULL_VECTOR, SpeedReturn);
					Better_Gravity_Rocket(RocketGet, 55.0);

					//This will return vecTarget as the speed we need.
					npc.m_iOverlordComboAttack--;
					npc.m_flNextMeleeAttack = gameTime + 0.25;
					npc.PlayGrenadeSound();
				}
				else
				{
					int target = npc.m_iTarget;
					npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY",_,_,_,1.5);
					Handle swingTrace;
					if(npc.DoSwingTrace(swingTrace, target, { 9999.0, 9999.0, 9999.0 }))
					{
						target = TR_GetEntityIndex(swingTrace);	
							
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);
						float origin[3], angles[3];
						view_as<CClotBody>(npc.index).GetAttachment("effect_hand_r", origin, angles);
						ShootLaser(npc.index, "bullet_tracer01_red", origin, vecHit, false);
						if(IsValidEnemy(npc.index, target))
						{
							float damageDealt = 30.0;

							if(ShouldNpcDealBonusDamage(target))
								damageDealt *= 3.0;

							SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, vecHit);
						}
						npc.PlayARSound();
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.1;
						npc.m_iOverlordComboAttack--;
					}
					delete swingTrace;
					if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 15.0))
					{
						//target is too far, try to close in
						return 2;
					}
					else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 14.0))
					{
						if(Can_I_See_Enemy_Only(npc.index, target))
						{
							//target is too close, try to keep distance
							return 4;
						}
					}
				}
				if(!IsValidEnemy(npc.index, npc.m_iTarget))
				{
					switch(GetRandomInt(0, 2))
					{
						case 0:NPCPritToChat(npc.index, "{forestgreen}", "bigpipe_Talk_05-1", false, false);
						case 1:NPCPritToChat(npc.index, "{forestgreen}", "bigpipe_Talk_05-2", false, false);
						case 2:NPCPritToChat(npc.index, "{forestgreen}", "bigpipe_Talk_05-3", false, false);
					}
				}
			}
		}
	}
	if(npc.m_flNextMeleeAttack > gameTime)
		return b_TheGoons ? 4 : 1;
	//No can shooty.
	//Enemy is close enough.
	if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 15.0))
	{
		if(Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
		{
			float VecAim[3]; WorldSpaceCenter(npc.m_iTarget, VecAim );
			npc.FaceTowards(VecAim, 20000.0);
			//stand
			return b_TheGoons ? 4 : 1;
		}
		//cant see enemy somewhy.
		return 0;
	}
	else //enemy is too far away.
	{
		return 0;
	}
}

static Action HEGrenade_StartTouch(int entity, int target)
{
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if(!IsValidEntity(owner))
		owner = 0;
	int inflictor = h_ArrowInflictorRef[entity];
	if(inflictor != -1)
		inflictor = EntRefToEntIndex(h_ArrowInflictorRef[entity]);

	if(inflictor == -1)
		inflictor = owner;
		
	float ProjectileLoc[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
	Explode_Logic_Custom(0.0, owner, inflictor, -1, ProjectileLoc, 146.0, _, _, true, _, false, _, HEGrenade);
	ParticleEffectAt(ProjectileLoc, "ExplosionCore_MidAir", 1.0);
	EmitSoundToAll(g_ExplosionSounds[GetRandomInt(0, sizeof(g_ExplosionSounds) - 1)], 0, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _, -1, ProjectileLoc);
	RemoveEntity(entity);
	return Plugin_Handled;
}

static void HEGrenade(int entity, int victim, float damage, int weapon)
{
	float vecHit[3]; WorldSpaceCenter(victim, vecHit);
	if(GetTeam(entity) != GetTeam(victim))
	{
		int inflictor = h_ArrowInflictorRef[entity];
		if(inflictor != -1)
			inflictor = EntRefToEntIndex(h_ArrowInflictorRef[entity]);

		if(inflictor == -1)
			inflictor = entity;
		damage = 450.0;
		if(ShouldNpcDealBonusDamage(victim))
			damage *= 3.0;
		SDKHooks_TakeDamage(victim, entity, inflictor, damage, DMG_BLAST, -1, _, vecHit);
		if(NpcStats_VictorianCallToArms(entity))
		{
			damage*=0.01;
			NPC_Ignite(victim, entity, 7.5, -1, damage);
		}
	}
}

public void Better_Gravity_Rocket(int entity, float gravity)
{
	DataPack GravityProjectile = new DataPack();
	GravityProjectile.WriteCell(EntIndexToEntRef(entity));
	GravityProjectile.WriteFloat(gravity);
	RequestFrame(GravityProjectileThink, GravityProjectile);
}
static void GravityProjectileThink(DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	float gravity = pack.ReadFloat();
	if(!IsValidEntity(entity))
		return;
	float vel[3],ang[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsVelocity", vel);
	vel[2] -= gravity;
	GetVectorAngles(vel, ang);
	SetEntPropVector(entity, Prop_Data, "m_vecAbsVelocity", vel);
	SetEntPropVector(entity, Prop_Data, "m_angRotation", ang);
	delete pack;
	DataPack pack2 = new DataPack();
	pack2.WriteCell(EntIndexToEntRef(entity));
	pack2.WriteFloat(gravity);
	float Throttle = 0.04;	//0.025
	int frames_offset = RoundToCeil(66.0*Throttle);	//no need to call this every frame if avoidable
	if(frames_offset < 0)
		frames_offset = 1;
	RequestFrames(GravityProjectileThink, frames_offset, pack2);
}