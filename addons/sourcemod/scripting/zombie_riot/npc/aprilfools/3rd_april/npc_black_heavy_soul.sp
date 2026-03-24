#pragma semicolon 1
#pragma newdecls required


static const char g_DeathSounds[][] = {
	"weapons/rescue_ranger_teleport_receive_01.wav",
	"weapons/rescue_ranger_teleport_receive_02.wav",
};

static const char g_HurtSounds[][] = {
	"vo/soldier_painsharp01.mp3",
	"vo/soldier_painsharp02.mp3",
	"vo/soldier_painsharp03.mp3",
	"vo/soldier_painsharp04.mp3",
	"vo/soldier_painsharp05.mp3",
	"vo/soldier_painsharp06.mp3",
	"vo/soldier_painsharp07.mp3",
	"vo/soldier_painsharp08.mp3",
};

static const char g_MissAbilitySound[][] = {
	"vo/soldier_negativevocalization01.mp3",
	"vo/soldier_negativevocalization02.mp3",
	"vo/soldier_negativevocalization03.mp3",
	"vo/soldier_negativevocalization04.mp3",
	"vo/soldier_negativevocalization05.mp3",
	"vo/soldier_negativevocalization06.mp3",
};


static const char g_IdleAlertedSounds[][] = {
	"vo/taunts/heavy_taunts18.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"zombiesurvival/aprilfools/more_men.mp3",
};
static const char g_MeleeHitSounds[][] = {
	"weapons/cbar_hitbod1.wav",
	"weapons/cbar_hitbod2.wav",
	"weapons/cbar_hitbod3.wav",
};

static char g_AngerSounds[][] = {
	"zombiesurvival/aprilfools/ssj_transform.mp3",
};
static char g_AngerSounds_short[][] = {
	"zombiesurvival/aprilfools/ssj_transform_short.mp3",
};

static char g_AngerSoundLoop[][] = {
	"zombiesurvival/aprilfools/ssj_loop.mp3",
};

static char g_PowGunShot[][] = {
	"weapons/csgo_awp_shoot.wav",
};

static char g_SyctheInitiateSound[][] = {
	"npc/env_headcrabcanister/incoming.wav",
};


static const char g_LaserGlobalAttackSound[][] = {
	"weapons/bumper_car_speed_boost_start.wav",
};

static const char g_SuperJumpSound[][] = {
	"misc/halloween/spell_blast_jump.wav",
};

int BlackHeavySoulId;
int BlackHeavySoulIDReturn()
{
	return BlackHeavySoulId;
}

void BlackHeavySoul_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Black Heavy Soul");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_black_heavy_soul");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Raid;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	BlackHeavySoulId = NPC_Add(data);
}

static void ClotPrecache()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_PowGunShot));   i++) { PrecacheSound(g_PowGunShot[i]);   }
	for (int i = 0; i < (sizeof(g_SyctheInitiateSound));   i++) { PrecacheSound(g_SyctheInitiateSound[i]);   }
	for (int i = 0; i < (sizeof(g_LaserGlobalAttackSound));   i++) { PrecacheSound(g_LaserGlobalAttackSound[i]);   }
	for (int i = 0; i < (sizeof(g_MissAbilitySound));   i++) { PrecacheSound(g_MissAbilitySound[i]);   }

	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSoundCustom(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_AngerSounds));   i++) { PrecacheSoundCustom(g_AngerSounds[i]);   }
	for (int i = 0; i < (sizeof(g_AngerSounds_short));   i++) { PrecacheSoundCustom(g_AngerSounds_short[i]);   }
	for (int i = 0; i < (sizeof(g_AngerSoundLoop));   i++) { PrecacheSoundCustom(g_AngerSoundLoop[i]);   }
	for (int i = 0; i < (sizeof(g_SuperJumpSound)); i++) { PrecacheSound(g_SuperJumpSound[i]); }
	PrecacheSoundCustom("#zombiesurvival/aprilfools/reteptheme_1.mp3");
	PrecacheSoundCustom("#zombiesurvival/aprilfools/black_heavy_2.mp3");
	PrecacheSoundCustom("#zombiesurvival/aprilfools/black_heavy_ultra.mp3");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return BlackHeavySoul(vecPos, vecAng, team, data);
}

methodmap BlackHeavySoul < CClotBody
{
	property float m_flTransformIn
	{
		public get()							{ return fl_NextChargeSpecialAttack[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextChargeSpecialAttack[this.index] = TempValueForProperty; }
	}
	property int m_iSaiyanState
	{
		public get()							{ return i_State[this.index]; }
		public set(int TempValueForProperty) 	{ i_State[this.index] = TempValueForProperty; }
	}
	property float m_flPowAbilityCD
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flCongaFastDo
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flJumpAtEnemy
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property int m_iWhatAbilityDo
	{
		public get()							{ return i_MedkitAnnoyance[this.index]; }
		public set(int TempValueForProperty) 	{ i_MedkitAnnoyance[this.index] = TempValueForProperty; }
	}
	public void PlaySytheInitSound() {
	
		int sound = GetRandomInt(0, sizeof(g_SyctheInitiateSound) - 1);
		EmitSoundToAll(g_SyctheInitiateSound[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_SyctheInitiateSound[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayAngerSound() {
	
		int sound = GetRandomInt(0, sizeof(g_AngerSounds) - 1);
		EmitCustomToAll(g_AngerSounds[sound], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitCustomToAll(g_AngerSounds[sound], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitCustomToAll(g_AngerSounds[sound], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitCustomToAll(g_AngerSounds[sound], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitCustomToAll(g_AngerSounds[sound], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitCustomToAll(g_AngerSounds[sound], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayAngerSoundShort() {
	
		int sound = GetRandomInt(0, sizeof(g_AngerSounds_short) - 1);
		EmitCustomToAll(g_AngerSounds_short[sound], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitCustomToAll(g_AngerSounds_short[sound], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitCustomToAll(g_AngerSounds_short[sound], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitCustomToAll(g_AngerSounds_short[sound], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitCustomToAll(g_AngerSounds_short[sound], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitCustomToAll(g_AngerSounds_short[sound], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime())
			return;
		
		if(!this.Anger)
		{
			CPrintToChatAll("{black}Black Heavy Soul{default}: I THINK YOU NEED MORE MEN!!");
			EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
			EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
			this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(8.0, 10.0);	
		}
		else
		{
			EmitCustomToAll(g_AngerSoundLoop[GetRandomInt(0, sizeof(g_AngerSoundLoop) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
			EmitCustomToAll(g_AngerSoundLoop[GetRandomInt(0, sizeof(g_AngerSoundLoop) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
			EmitCustomToAll(g_AngerSoundLoop[GetRandomInt(0, sizeof(g_AngerSoundLoop) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
			this.m_flNextIdleSound = GetGameTime() + 6.5;		
		}
		
	}
	public void PlaySuperJumpSound()
	{
		EmitSoundToAll(g_SuperJumpSound[GetRandomInt(0, sizeof(g_SuperJumpSound) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_SuperJumpSound[GetRandomInt(0, sizeof(g_SuperJumpSound) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}	
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
	}
	
	public void PlayMissSound() 
	{
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_MissAbilitySound[GetRandomInt(0, sizeof(g_MissAbilitySound) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_MissAbilitySound[GetRandomInt(0, sizeof(g_MissAbilitySound) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_MissAbilitySound[GetRandomInt(0, sizeof(g_MissAbilitySound) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayPowGunSound()
	{
		EmitSoundToAll(g_PowGunShot[GetRandomInt(0, sizeof(g_PowGunShot) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}

	public void PlayMeleeSound()
	{
		NpcSpeechBubble(this.index, "MEN", 15, {0,0,0,255}, {0.0,0.0,100.0}, "");
		EmitCustomToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	
	public BlackHeavySoul(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		BlackHeavySoul npc = view_as<BlackHeavySoul>(CClotBody(vecPos, vecAng, "models/player/heavy.mdl", "1.15", "40000", ally, false, true, true,true)); //giant!
		i_NpcWeight[npc.index] = 4;

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		npc.m_flMeleeArmor = 1.25;	
		
		func_NPCDeath[npc.index] = view_as<Function>(Internal_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Internal_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Internal_ClotThink);

		
		npc.StartPathing();
		npc.m_flSpeed = 320.0;

		BlockLoseSay = false;
		
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		b_thisNpcIsARaid[npc.index] = true;
		b_angered_twice[npc.index] = false;
		for(int client_clear=1; client_clear<=MaxClients; client_clear++)
		{
			fl_AlreadyStrippedMusic[client_clear] = 0.0; //reset to 0
		}
		

		bool final = StrContains(data, "final_item") != -1;
		
		if(final)
		{
			i_RaidGrantExtra[npc.index] = 6;
			b_NpcUnableToDie[npc.index] = true;
		}
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "item_armor", 1, "%t", "BlackHeavySoul Arrived");
			}
		}

		RaidModeTime = GetGameTime(npc.index) + 200.0;
		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = false;

		char buffers[3][64];
		ExplodeString(data, ";", buffers, sizeof(buffers), sizeof(buffers[]));
		//the very first and 2nd char are SC for scaling
		if(buffers[0][0] == 's' && buffers[0][1] == 'c')
		{
			//remove SC
			ReplaceString(buffers[0], 64, "sc", "");
			float value = StringToFloat(buffers[0]);
			RaidModeScaling = value;

			if(RaidModeScaling < 35)
			{
				RaidModeScaling *= 0.25; //abit low, inreacing
			}
			else
			{
				RaidModeScaling *= 0.5;
			}

			if(value > 40.0)
			{
				RaidModeScaling *= 0.85;
			}
			
		}
		else
		{	
			RaidModeScaling = float(Waves_GetRoundScale()+1);
			if(RaidModeScaling < 35)
			{
				RaidModeScaling *= 0.25; //abit low, inreacing
			}
			else
			{
				RaidModeScaling *= 0.5;
			}
				
			if(Waves_GetRoundScale()+1 > 25)
			{
				RaidModeScaling *= 0.85;
			}
		}

		
		float amount_of_people = ZRStocks_PlayerScalingDynamic();
		if(amount_of_people > 12.0)
		{
			amount_of_people = 12.0;
		}
		amount_of_people *= 0.12;
		
		if(amount_of_people < 1.0)
			amount_of_people = 1.0;
			
		npc.m_flPowAbilityCD = GetGameTime() + 5.0;
		npc.m_flCongaFastDo = GetGameTime() + 20.0;
		npc.m_flJumpAtEnemy = GetGameTime() + 10.0;

		if(StrContains(data, "jump_test") != -1)
		{
			npc.m_flPowAbilityCD = GetGameTime() + 99999.9;
			npc.m_flCongaFastDo = GetGameTime() + 9999.9;
			npc.m_flJumpAtEnemy = GetGameTime() + 2.5;	
		}

		RaidModeScaling *= amount_of_people; //More then 9 and he raidboss gets some troubles, bufffffffff

		RemoveAllDamageAddition();
		func_NPCFuncWin[npc.index] = view_as<Function>(Raidmode_Expidonsa_BlackHeavySoul_Win);
		MusicEnum music;
		strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/aprilfools/reteptheme_1.mp3");
		music.Time = 110;
		music.Volume = 2.0;
		music.Custom = true;
		strcopy(music.Name, sizeof(music.Name), "Retep theme");
		strcopy(music.Artist, sizeof(music.Artist), "terraria peter griffin mod");
		Music_SetRaidMusic(music);
		
		SetEntityRenderMode(npc.index, RENDER_NORMAL);
		SetEntityRenderColor(npc.index, 0, 0, 0, 255);
		CPrintToChatAll("{black}Black Heavy Soul{default}: You come here and threaten my world!? I will take you down!");
		CPrintToChatAll("{black}Black Heavy Soul{default}: These Heavy souls are fake and evil! They do nothing except hurt!");
		CPrintToChatAll("{black}Black Heavy Soul{default}: My own world was threatened by them, them and smith...");
		

		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		if(StrContains(data, "timeout") != -1)
		{
			RaidModeTime = GetGameTime() + 10.0;
		}

		
		return npc;
	}
}

static void Internal_ClotThink(int iNPC)
{
	BlackHeavySoul npc = view_as<BlackHeavySoul>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(LastMann)
	{
		if(!npc.m_fbGunout)
		{
			npc.m_fbGunout = true;
			CPrintToChatAll("{black}Black Heavy Soul{default}: Last Noob Left.");
		}
	}
	if(i_RaidGrantExtra[npc.index] == RAIDITEM_INDEX_WIN_COND)
	{
		npc.m_bisWalking = false;
		npc.AddActivityViaSequence("selectionMenu_Idle");
		npc.SetCycle(0.01);
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		
		CPrintToChatAll("{black}Black Heavy Soul{default}: GG EZs.");
		return;

	}	
	int target = npc.m_iTarget;
	if(i_Target[npc.index] != -1 && !IsValidEnemy(npc.index, target))
		i_Target[npc.index] = -1;
	
	if(i_Target[npc.index] == -1 || npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		target = GetClosestTarget(npc.index);
		npc.m_iTarget = target;
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	if(BlackHeavy_Transform(npc))
		return;
	if(Black_Heavy_PowDo(npc, GetGameTime(npc.index)))
	{
		return;
	}
	if(Black_Heavy_CongaVeryFastDo(npc, GetGameTime(npc.index)))
	{
		return;
	}
	if(Black_Heavy_JumpOfDeath(npc, GetGameTime(npc.index)))
	{
		return;
	}
	
	if(!BlockLoseSay && RaidModeTime < GetGameTime())
	{
		MusicEnum music;
		strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/aprilfools/black_heavy_ultra.mp3");
		music.Time = 167;
		music.Volume = 1.1;
		music.Custom = true;
		strcopy(music.Name, sizeof(music.Name), "Ultra Instinct Theme");
		strcopy(music.Artist, sizeof(music.Artist), "Dragon Ball Super");
		Music_SetRaidMusic(music);
		ApplyStatusEffect(npc.index, npc.index, "Perfected Instinct", 999999.9);
		fl_Extra_Speed[npc.index] 	*= 1.25;
		if(!npc.Anger)
		{
			fl_TotalArmor[npc.index] *= 0.5;
			f_AttackSpeedNpcIncrease[npc.index] *= 0.65;
		}
		npc.Anger = true;
		npc.m_iSaiyanState = 999;
		RaidModeTime = FAR_FUTURE;
		f_AttackSpeedNpcIncrease[npc.index] *= 0.85;
		RaidModeScaling *= 1.5;
		strcopy(c_NpcName[npc.index], sizeof(c_NpcName[]), "Black Heavy Soul");
		if(IsValidEntity(npc.m_iWearable2))
			RemoveEntity(npc.m_iWearable2);
		if(IsValidEntity(npc.m_iWearable7))
			RemoveEntity(npc.m_iWearable7);
		if(IsValidEntity(npc.m_iWearable3))
			RemoveEntity(npc.m_iWearable3);
		if(IsValidEntity(npc.m_iWearable6))
			RemoveEntity(npc.m_iWearable6);
			
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/medic/hwn2023_power_spike/hwn2023_power_spike.mdl",_,_, 1.0);
	}

	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}

/*
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}

	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;
*/
	if(!IsValidEntity(RaidBossActive))
	{
		RaidBossActive = EntIndexToEntRef(npc.index);
	}

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
		int SetGoalVectorIndex = 0;
		SetGoalVectorIndex = BlackHeavySoulSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 

		switch(SetGoalVectorIndex)
		{
			case 0:
			{
				npc.m_bAllowBackWalking = false;
				//Get the normal prediction code.
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
				npc.m_bAllowBackWalking = true;
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget,_,vBackoffPos);
				npc.SetGoalVector(vBackoffPos, true); //update more often, we need it
			}
		}
	}

	if(npc.m_flDoingAnimation < GetGameTime(npc.index))
	{
		BlackHeavySoulAnimationChange(npc);
	}
	npc.PlayIdleAlertSound();
}

static Action Internal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	BlackHeavySoul npc = view_as<BlackHeavySoul>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;

	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}		

	if(!npc.Anger)
	{
		if((ReturnEntityMaxHealth(npc.index)/2) >= GetEntProp(npc.index, Prop_Data, "m_iHealth")) //npc.Anger after half hp/400 hp
		{
			RaidModeTime += 60.0;
			npc.PlayAngerSound();
			npc.Anger = true; //	>:(
			npc.m_flNextIdleSound = 0.0;
			npc.m_flTransformIn = GetGameTime() + 5.0;
			CPrintToChatAll("{black}Black Heavy Soul{crimson}: RAHHHHHHHH!!! I WILL NOT LET YOU DESTROY MY WOORLD!!!!!!!!!!!");
			NpcSpeechBubble(npc.index, "RAHHHHHHHH!!! I WILL NOT LET YOU DESTROY MY WOORLD!!!!!!!!!!!", 35, {255,0,0,255}, {0.0,0.0,200.0}, "");
			npc.m_iWhatAbilityDo = 0;
			npc.m_flDoingAnimation = 0.0;
			npc.m_iChanged_WalkCycle = 0;
			/*
			b_RageAnimated[npc.index] = false;
			RaidModeTime += 60.0;
			npc.m_bisWalking = false;
			if(IsValidEntity(npc.m_iWearable7))
			{
				RemoveEntity(npc.m_iWearable7);
			}
			float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
			pos[2] += 5.0;
			ParticleEffectAt(pos, "utaunt_electricity_cloud1_WY", 3.0);
			*/
		}
	}
	else
	{
		if(npc.m_iSaiyanState == 1 && (ReturnEntityMaxHealth(npc.index)/4) >= GetEntProp(npc.index, Prop_Data, "m_iHealth"))
		{
			strcopy(c_NpcName[npc.index], sizeof(c_NpcName[]), "Super Saiyan 2 Black Heavy Soul");
			npc.m_iSaiyanState = 2;
			RaidModeTime += 60.0;
			fl_Extra_Speed[npc.index] *= 1.05;
			fl_TotalArmor[npc.index] *= 0.5;
			f_AttackSpeedNpcIncrease[npc.index] *= 0.85;
			npc.PlayAngerSoundShort();			
			float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
			pos[2] += 10.0;
			float flPos[3]; // original
			npc.GetAttachment("", flPos, NULL_VECTOR);
			npc.m_iWearable6 = ParticleEffectAt_Parent(flPos, "utaunt_elebound_yellow_parent", npc.index, "", {0.0,0.0,0.0});
			TE_Particle("Explosion_ShockWave_01", pos, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
			TE_Particle("grenade_smoke_cycle", pos, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
			TE_Particle("hammer_bell_ring_shockwave", pos, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
			CreateEarthquake(pos, 1.0, 2000.0, 16.0, 255.0);
			spawnRing_Vectors(pos, 0.0, 0.0, 0.0, 0.0, "materials/sprites/combineball_trail_black_1.vmt", 185, 80, 185, 255, 1, /*duration*/ 1.0, 80.0, 4.0, 1, 5000.0);	
			spawnRing_Vectors(pos, 0.0, 0.0, 0.0, 0.0, "materials/sprites/combineball_trail_black_1.vmt", 185, 80, 185, 255, 1, /*duration*/ 2.0, 80.0, 4.0, 1, 5000.0);	
			spawnRing_Vectors(pos, 0.0, 0.0, 0.0, 0.0, "materials/sprites/combineball_trail_black_1.vmt", 185, 80, 185, 255, 1, /*duration*/ 3.0, 80.0, 4.0, 1, 5000.0);	
			Explode_Logic_Custom(50.0, 0, npc.index, -1, pos ,1000.0, 1.0, _, true, .FunctionToCallOnHit = SsjBlackHeavy_KnockbackDo);
		}
		if(npc.m_iSaiyanState == 2 && (ReturnEntityMaxHealth(npc.index)/8) >= GetEntProp(npc.index, Prop_Data, "m_iHealth"))
		{
			strcopy(c_NpcName[npc.index], sizeof(c_NpcName[]), "Super Saiyan 3 Black Heavy Soul");
			npc.m_iSaiyanState = 3;
			RaidModeTime += 60.0;
			fl_Extra_Speed[npc.index] *= 1.05;
			fl_TotalArmor[npc.index] *= 0.5;			
			f_AttackSpeedNpcIncrease[npc.index] *= 0.85;
			if(IsValidEntity(npc.m_iWearable2))
				RemoveEntity(npc.m_iWearable2);
			npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/medic/hwn2023_power_spike/hwn2023_power_spike.mdl",_,_, 1.0);
			SetEntityRenderColor(npc.m_iWearable2, 255, 255, 0, 255);
			NpcColourCosmetic_ViaPaint(npc.m_iWearable2, 15185211);
			if(IsValidEntity(npc.m_iWearable3))
				RemoveEntity(npc.m_iWearable3);
			npc.m_iWearable3 = npc.EquipItemSeperate("models/workshop_partner/player/items/all_class/brutal_hair/brutal_hair_heavy.mdl",_,_, 1.75, 75.0);
			SetEntityRenderColor(npc.m_iWearable3, 255, 255, 0, 255);
			NpcColourCosmetic_ViaPaint(npc.m_iWearable3, 15185211);
			npc.PlayAngerSoundShort();			
			float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
			pos[2] += 10.0;
			TE_Particle("Explosion_ShockWave_01", pos, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
			TE_Particle("grenade_smoke_cycle", pos, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
			TE_Particle("hammer_bell_ring_shockwave", pos, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
			CreateEarthquake(pos, 1.0, 2000.0, 16.0, 255.0);
			spawnRing_Vectors(pos, 0.0, 0.0, 0.0, 0.0, "materials/sprites/combineball_trail_black_1.vmt", 185, 80, 185, 255, 1, /*duration*/ 1.0, 80.0, 4.0, 1, 5000.0);	
			spawnRing_Vectors(pos, 0.0, 0.0, 0.0, 0.0, "materials/sprites/combineball_trail_black_1.vmt", 185, 80, 185, 255, 1, /*duration*/ 2.0, 80.0, 4.0, 1, 5000.0);	
			spawnRing_Vectors(pos, 0.0, 0.0, 0.0, 0.0, "materials/sprites/combineball_trail_black_1.vmt", 185, 80, 185, 255, 1, /*duration*/ 3.0, 80.0, 4.0, 1, 5000.0);	
			Explode_Logic_Custom(50.0, 0, npc.index, -1, pos ,1000.0, 1.0, _, true, .FunctionToCallOnHit = SsjBlackHeavy_KnockbackDo);
			
			TE_SetupParticleEffect("unusual_uber_gold_outline_glow", PATTACH_ABSORIGIN_FOLLOW, npc.m_iWearable3);
			TE_WriteNum("m_bControlPoint1", npc.m_iWearable3);	
			TE_SendToAll();
		}
		
	}

	
	return Plugin_Changed;
}
public void Raidmode_Expidonsa_BlackHeavySoul_Win(int entity)
{
	i_RaidGrantExtra[entity] = RAIDITEM_INDEX_WIN_COND;
	BlockLoseSay = true;
	CPrintToChatAll("{black}Black Heavy Soul{default}: get owned.");
}

static void Internal_NPCDeath(int entity)
{
	RaidBossActive = INVALID_ENT_REFERENCE;
	if(BlockLoseSay)
		return;

	CPrintToChatAll("{black}Black Heavy Soul{default}: Nvm fuck you i made it all up.");
	CPrintToChatAll("{black}Black Heavy Soul{default}: *dies of death*");
}

void BlackHeavySoulAnimationChange(BlackHeavySoul npc)
{
	
	if(npc.m_iChanged_WalkCycle == 0)
	{
		npc.m_iChanged_WalkCycle = -1;
	}

	if (npc.IsOnGround())
	{
		if(npc.m_iChanged_WalkCycle != 3)
		{
		//	ResetBlackHeavySoulWeapon(npc, 0);
			npc.m_flSpeed = 320.0;
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 3;
			npc.SetActivity("ACT_MP_RUN_MELEE");
			npc.StartPathing();
		}	
	}
	else
	{
		if(npc.m_iChanged_WalkCycle != 4)
		{
		//	ResetBlackHeavySoulWeapon(npc, 0);
			npc.m_flSpeed = 320.0;
			npc.m_bisWalking = false;
			npc.m_iChanged_WalkCycle = 4;
			npc.SetActivity("ACT_MP_JUMP_FLOAT_MELEE");
			npc.StartPathing();
		}	
	}

}

int BlackHeavySoulSelfDefense(BlackHeavySoul npc, float gameTime, int target, float distance)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < GetGameTime(npc.index))
		{
			npc.m_flAttackHappens = 0.0;
			
			if(IsValidEnemy(npc.index, target))
			{
				int HowManyEnemeisAoeMelee = 64;
				Handle swingTrace;
				float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
				npc.FaceTowards(VecEnemy, 15000.0);
				npc.DoSwingTrace(swingTrace, npc.m_iTarget,_,_,_,1,_,HowManyEnemeisAoeMelee);
				delete swingTrace;
				bool PlaySound = false;
				for (int counter = 1; counter <= HowManyEnemeisAoeMelee; counter++)
				{
					if (i_EntitiesHitAoeSwing_NpcSwing[counter] > 0)
					{
						if(IsValidEntity(i_EntitiesHitAoeSwing_NpcSwing[counter]))
						{
							PlaySound = true;
							int targetTrace = i_EntitiesHitAoeSwing_NpcSwing[counter];
							float vecHit[3];
							
							WorldSpaceCenter(targetTrace, vecHit);

							float damage = 15.0;

							SDKHooks_TakeDamage(targetTrace, npc.index, npc.index, damage * RaidModeScaling, DMG_CLUB, -1, _, vecHit);								
								
							
							// Hit particle
							
						
							
							bool Knocked = false;
										
							if(IsValidClient(targetTrace))
							{
								if (IsInvuln(targetTrace))
								{
									Knocked = true;
									Custom_Knockback(npc.index, targetTrace, 900.0, true);
									if(!NpcStats_IsEnemySilenced(npc.index))
									{
										TF2_AddCondition(targetTrace, TFCond_LostFooting, 0.5);
										TF2_AddCondition(targetTrace, TFCond_AirCurrent, 0.5);
									}
								}
							}
										
							if(!Knocked)
								Custom_Knockback(npc.index, targetTrace, 250.0, true); 
						} 
					}
				}
				if(PlaySound)
				{
					npc.PlayMeleeHitSound();
				}
			}
		}
	}
	//Melee attack, last prio
	else if(GetGameTime(npc.index) > npc.m_flNextMeleeAttack)
	{
		if(IsValidEnemy(npc.index, target)) 
		{
			if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
			{
				int Enemy_I_See;
									
				Enemy_I_See = Can_I_See_Enemy(npc.index, target);
						
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					target = Enemy_I_See;

					npc.PlayMeleeSound();
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE",_,_,_,3.0);
							
					npc.m_flAttackHappens = gameTime + 0.1;
					npc.m_flNextMeleeAttack = gameTime + 0.15;
					npc.m_flDoingAnimation = gameTime + 0.1;
				}
			}
		}
		else
		{
			npc.m_flGetClosestTargetTime = 0.0;
			npc.m_iTarget = GetClosestTarget(npc.index);
		}	
	}
	return 0;
}


bool BlackHeavy_Transform(BlackHeavySoul npc)
{
	if(!npc.m_flTransformIn)
		return false;

	if(npc.m_flTransformIn < GetGameTime())
	{			
		b_CannotBeHeadshot[npc.index] = false;
		b_CannotBeBackstabbed[npc.index] = false;
		b_NpcIsInvulnerable[npc.index] = false; //Special huds for invul targets
		npc.m_bisWalking = true;
		npc.StartPathing();
		npc.m_flTransformIn = 0.0;
		return false;
	}
	if(npc.m_flTransformIn < GetGameTime() + 1.75)
	{
		if(npc.m_iChanged_WalkCycle != 101)
		{
			npc.m_iSaiyanState = 1;
			CPrintToChatAll("{black}Black Heavy Soul{crimson}: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
			CPrintToChatAll("{black}Black Heavy Soul{crimson}: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
			CPrintToChatAll("{black}Black Heavy Soul{crimson}: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
			CPrintToChatAll("{black}Black Heavy Soul{crimson}: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
			CPrintToChatAll("{black}Black Heavy Soul{crimson}: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
			CPrintToChatAll("{black}Black Heavy Soul{crimson}: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
			CPrintToChatAll("{black}Black Heavy Soul{crimson}: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
			CPrintToChatAll("{black}Black Heavy Soul{crimson}: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
			CPrintToChatAll("{black}Black Heavy Soul{crimson}: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
			CPrintToChatAll("{black}Black Heavy Soul{crimson}: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
			CPrintToChatAll("{black}Black Heavy Soul{crimson}: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
			CPrintToChatAll("{black}Black Heavy Soul{crimson}: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
			CPrintToChatAll("{black}Black Heavy Soul{crimson}: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
			CPrintToChatAll("{black}Black Heavy Soul{crimson}: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
			CPrintToChatAll("{black}Black Heavy Soul{crimson}: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
			CPrintToChatAll("{black}Black Heavy Soul{crimson}: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
			CPrintToChatAll("{black}Black Heavy Soul{crimson}: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
			CPrintToChatAll("{black}Black Heavy Soul{crimson}: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
			CPrintToChatAll("{black}Black Heavy Soul{crimson}: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
			CPrintToChatAll("{black}Black Heavy Soul{crimson}: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
			fl_Extra_Speed[npc.index] *= 1.05;
			strcopy(c_NpcName[npc.index], sizeof(c_NpcName[]), "Super Saiyan Black Heavy Soul");
			float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
			pos[2] += 10.0;
			TE_Particle("Explosion_ShockWave_01", pos, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
			TE_Particle("grenade_smoke_cycle", pos, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
			TE_Particle("hammer_bell_ring_shockwave", pos, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
			CreateEarthquake(pos, 1.0, 2000.0, 16.0, 255.0);
			spawnRing_Vectors(pos, 0.0, 0.0, 0.0, 0.0, "materials/sprites/combineball_trail_black_1.vmt", 185, 80, 185, 255, 1, /*duration*/ 1.0, 80.0, 4.0, 1, 5000.0);	
			spawnRing_Vectors(pos, 0.0, 0.0, 0.0, 0.0, "materials/sprites/combineball_trail_black_1.vmt", 185, 80, 185, 255, 1, /*duration*/ 2.0, 80.0, 4.0, 1, 5000.0);	
			spawnRing_Vectors(pos, 0.0, 0.0, 0.0, 0.0, "materials/sprites/combineball_trail_black_1.vmt", 185, 80, 185, 255, 1, /*duration*/ 3.0, 80.0, 4.0, 1, 5000.0);	
			if(IsValidEntity(npc.m_iWearable2))
				RemoveEntity(npc.m_iWearable2);
			npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/medic/hwn2023_power_spike/hwn2023_power_spike.mdl",_,_, 1.5);
			SetEntityRenderColor(npc.m_iWearable2, 255, 255, 0, 255);
			NpcColourCosmetic_ViaPaint(npc.m_iWearable2, 15185211);
			Explode_Logic_Custom(50.0, 0, npc.index, -1, pos ,1000.0, 1.0, _, true, .FunctionToCallOnHit = SsjBlackHeavy_KnockbackDo);
		
			float flPos[3]; // original
			npc.GetAttachment("", flPos, NULL_VECTOR);
			npc.m_iWearable7 = ParticleEffectAt_Parent(flPos, "utaunt_poweraura_yellow_parent", npc.index, "", {0.0,0.0,0.0});
			f_AttackSpeedNpcIncrease[npc.index] *= 0.65;
			fl_TotalArmor[npc.index] *= 0.5;
			npc.SetPlaybackRate(1.35);

			npc.m_iChanged_WalkCycle = 101;
		}
		return true;
	}
	if(npc.m_iChanged_WalkCycle != 100)
	{
		MusicEnum music;
		strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/aprilfools/black_heavy_2.mp3");
		music.Time = 213;
		music.Volume = 1.1;
		music.Custom = true;
		strcopy(music.Name, sizeof(music.Name), "Flow Hero Song of Hope");
		strcopy(music.Artist, sizeof(music.Artist), "Dragon Ball Z: Battle Of Gods ED");
		Music_SetRaidMusic(music);
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client))
			{
				SetMusicTimer(client, GetTime() + 5);
			}
		}

		npc.m_bisWalking = false;
		npc.m_iChanged_WalkCycle = 100;
		npc.StopPathing();
		b_NpcIsInvulnerable[npc.index] = true; //Special huds for invul targets
		b_CannotBeHeadshot[npc.index] = true;
		b_CannotBeBackstabbed[npc.index] = true;
		ApplyStatusEffect(npc.index, npc.index, "Clear Head", 999999.0);	
		ApplyStatusEffect(npc.index, npc.index, "Solid Stance", 999999.0);	
		ApplyStatusEffect(npc.index, npc.index, "Fluid Movement", 999999.0);	
		npc.AddActivityViaSequence("taunt_mourning_mercs_heavy");
		npc.SetPlaybackRate(0.8);
		npc.SetCycle(0.05);
		npc.m_flAttackHappens = 0.0;
	}	
	return true;
}
void SsjBlackHeavy_KnockbackDo(int entity, int victim, float damage, int weapon)
{
	float VecMe[3]; WorldSpaceCenter(entity, VecMe);
	float VecEnemy[3]; WorldSpaceCenter(victim, VecEnemy);

	float AngleVec[3];
	MakeVectorFromPoints(VecMe, VecEnemy, AngleVec);
	GetVectorAngles(AngleVec, AngleVec);

	AngleVec[0] = -45.0;
	Custom_Knockback(entity, victim, 800.0, true, true, true, .OverrideLookAng = AngleVec);
	if(IsValidClient(victim))
	{
		ApplyStatusEffect(entity, victim, "Ragdolled", 4.0);	
		FreezeNpcInTime(victim, 4.0);
	}
}




//Wwalk Cycle offset is 200
bool Black_Heavy_PowDo(BlackHeavySoul npc, float gameTime)
{
	if(npc.m_iWhatAbilityDo != 1 && npc.m_iWhatAbilityDo != 0)
		return false;
	if(npc.m_flDoingAnimation < gameTime)
	{

		if(npc.m_flPowAbilityCD < gameTime)
		{
			if(!IsValidEnemy(npc.index, npc.m_iTarget))
				return false;
			if(!Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
				return false;
			npc.m_flPowAbilityCD = gameTime + 25.0;
			npc.m_flDoingAnimation = gameTime + 2.0;
			npc.m_bisWalking = false;
			npc.StopPathing();
			npc.m_iChanged_WalkCycle = 200;
			npc.AddActivityViaSequence("taunt03");
			npc.SetPlaybackRate(0.65);
			npc.SetCycle(0.05);
			npc.m_iWhatAbilityDo = 1;
		}
	}
	if(npc.m_iWhatAbilityDo != 1)
		return false;
		
	int CurrentShotAt = npc.m_iChanged_WalkCycle - 200;
	if(CurrentShotAt > 20)
	{
		npc.m_iWhatAbilityDo = 0;
		npc.m_flDoingAnimation = 0.0;
		return false;
	}
	if(npc.m_flDoingAnimation < gameTime)
	{
		npc.SetPlaybackRate(2.5);
		npc.SetCycle(0.38);
		npc.m_iChanged_WalkCycle++;
		if(IsValidEnemy(npc.index, npc.m_iTarget))
		{
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float ProjectileSpeed = 1500.0;
			PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, ProjectileSpeed, _, vecTarget);

			npc.FaceTowards(vecTarget, 20000.0);
			int entity = npc.FireRocket(vecTarget, 35.0 * RaidModeScaling, ProjectileSpeed, "models/weapons/w_bullet.mdl", 5.0);	
			int trail = Trail_Attach(entity, ARROW_TRAIL_RED, 175, 0.25, 20.0, 20.0, 5);
			i_WandParticle[entity] = EntIndexToEntRef(trail);
			CreateTimer(4.0, Timer_RemoveEntity, EntIndexToEntRef(trail), TIMER_FLAG_NO_MAPCHANGE);
			SetParent(entity, trail);			
			DataPack pack1;
			CreateDataTimer(0.75, WhiteflowerTank_Rocket_Stand, pack1, TIMER_FLAG_NO_MAPCHANGE);
			pack1.WriteCell(EntIndexToEntRef(entity));
			pack1.WriteCell(EntIndexToEntRef(npc.m_iTarget));
			npc.PlayPowGunSound();
		}
		npc.m_flDoingAnimation = gameTime + 0.25;
	}
	return true;
}

//Wwalk Cycle offset is 300
bool Black_Heavy_CongaVeryFastDo(BlackHeavySoul npc, float gameTime)
{
	if(npc.m_iWhatAbilityDo != 2 && npc.m_iWhatAbilityDo != 0)
		return false;
	if(npc.m_flDoingAnimation < gameTime)
	{
		if(npc.m_flCongaFastDo < gameTime)
		{
			if(!IsValidEnemy(npc.index, npc.m_iTarget))
				return false;
			if(!Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
				return false;

			npc.m_flSpeed = 720.0;
			npc.m_flCongaFastDo = gameTime + 35.0;
			npc.m_flDoingAnimation = gameTime + 0.25;
			npc.m_bisWalking = false;
			npc.StartPathing();
			npc.m_iChanged_WalkCycle = 300;
			npc.AddActivityViaSequence("taunt_conga");
			npc.SetPlaybackRate(2.5);
			npc.SetCycle(0.05);
			npc.m_iWhatAbilityDo = 2;
			f_NpcAdjustFriction[npc.index] = 0.2;
			ApplyStatusEffect(npc.index, npc.index, "Intangible", 999999.0);
			f_CheckIfStuckPlayerDelay[npc.index] = FAR_FUTURE; //She CANT stuck you, so dont make players not unstuck in cant bve stuck ? what ?
			b_ThisEntityIgnoredBeingCarried[npc.index] = true; //cant be targeted AND wont do npc collsiions
		}
	}
	if(npc.m_iWhatAbilityDo != 2)
		return false;
		
	int CurrentShotAt = npc.m_iChanged_WalkCycle - 300;
	if(CurrentShotAt > 20)
	{
		f_NpcAdjustFriction[npc.index] = 1.0;
		RemoveSpecificBuff(npc.index, "Intangible");
		f_CheckIfStuckPlayerDelay[npc.index] = 1.0; //She CANT stuck you, so dont make players not unstuck in cant bve stuck ? what ?
		b_ThisEntityIgnoredBeingCarried[npc.index] = false; //cant be targeted AND wont do npc collsiions
		npc.m_iWhatAbilityDo = 0;
		npc.m_flDoingAnimation = 0.0;
		return false;
	}
	if(npc.m_flDoingAnimation < gameTime)
	{		
		npc.m_iChanged_WalkCycle++;
		i_ExplosiveProjectileHexArray[npc.index] |= EP_DEALS_CLUB_DAMAGE;
		float radius = 160.0, damage = 20.0 * RaidModeScaling;
		float Loc[3];
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", Loc);
		Explode_Logic_Custom(damage, npc.index, npc.index, -1, _, radius, _, _, true);
		spawnRing_Vectors(Loc, 0.1, 0.0, 0.0, 1.0, "materials/sprites/laserbeam.vmt", 255, 200, 200, 255, 1, 0.2, 8.0, 1.5, 1, radius*2.0);
		spawnRing_Vectors(Loc, 0.1, 0.0, 0.0, 25.0, "materials/sprites/laserbeam.vmt", 255, 200, 200, 255, 1, 0.2, 8.0, 1.5, 1, radius*2.0);
		spawnRing_Vectors(Loc, 0.1, 0.0, 0.0, 45.0, "materials/sprites/laserbeam.vmt", 255, 200, 200, 255, 1, 0.2, 8.0, 1.5, 1, radius*2.0);
		spawnRing_Vectors(Loc, 0.1, 0.0, 0.0, 65.0, "materials/sprites/laserbeam.vmt", 255, 200, 200, 255, 1, 0.2, 8.0, 1.5, 1, radius*2.0);

		npc.m_flDoingAnimation = gameTime + 0.25;
	}
	return false;
}


//Wwalk Cycle offset is 400
bool Black_Heavy_JumpOfDeath(BlackHeavySoul npc, float gameTime)
{
	if(npc.m_iWhatAbilityDo != 3 && npc.m_iWhatAbilityDo != 0)
		return false;
	if(npc.m_flDoingAnimation < gameTime)
	{
		if(npc.m_flJumpAtEnemy < gameTime)
		{
			if(!IsValidEnemy(npc.index, npc.m_iTarget))
				return false;
			if(!Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
				return false;

			npc.m_flJumpAtEnemy = gameTime + 35.0;
			npc.m_flDoingAnimation = gameTime + 1.0;
			npc.m_bisWalking = false;
			npc.StopPathing();
			npc.AddActivityViaSequence("taunt_table_flip_outro");
			npc.SetPlaybackRate(0.65);
			npc.SetCycle(0.01);
			npc.m_iChanged_WalkCycle = 400;
			npc.m_iWhatAbilityDo = 3;
			EmitSoundToAll("mvm/mvm_cpoint_klaxon.wav", npc.index, SNDCHAN_STATIC, 120, _, 1.0);
			EmitSoundToAll("mvm/mvm_cpoint_klaxon.wav", npc.index, SNDCHAN_STATIC, 120, _, 1.0);
		}
	}
	if(npc.m_iWhatAbilityDo != 3)
		return false;
		
	if(npc.m_iChanged_WalkCycle == 400)
	{
		if(!IsValidEnemy(npc.index, npc.m_iTarget))
			return true;
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		npc.FaceTowards(vecTarget, 15000.0);
		if(npc.m_flDoingAnimation < gameTime)
		{
			npc.SetPlaybackRate(0.0);
			npc.m_iChanged_WalkCycle = 401;
			npc.m_flDoingAnimation = gameTime + 4.0;
			npc.m_flGravityMulti = 0.65;
			PluginBot_Jump(npc.index, vecTarget, 4000.0, .timemodify = 4.0);
			npc.PlaySuperJumpSound();
			float flPos[3];
			float flAng[3];
			npc.GetAttachment("effect_hand_R", flPos, flAng);
			npc.m_iWearable5 = ParticleEffectAt_Parent(flPos, "raygun_projectile_red_crit", npc.index, "effect_hand_R", {0.0,0.0,0.0});
			

			npc.GetAttachment("effect_hand_L", flPos, flAng);
			npc.m_iWearable4 = ParticleEffectAt_Parent(flPos, "raygun_projectile_red_crit", npc.index, "effect_hand_L", {0.0,0.0,0.0});

		}
		return true;
	}
	
	if ((npc.IsOnGround() || npc.m_flDoingAnimation < gameTime) && (npc.m_iChanged_WalkCycle == 401))
	{
		float damageDealt = 600.0 * RaidModeScaling;

		npc.AddActivityViaSequence("taunt_yeti_layer");
		npc.SetPlaybackRate(1.0);
		npc.SetCycle(0.75);
		npc.m_iChanged_WalkCycle = 402;
		npc.m_flDoingAnimation = gameTime + 1.5;
		static float flMyPos[3];
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flMyPos);
		flMyPos[2] += 15.0;
		Explode_Logic_Custom(damageDealt, npc.index, npc.index, -1, flMyPos,250.0, 1.0, _, true, 20);
		TE_Particle("asplode_hoodoo", flMyPos, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
		EmitSoundToAll(SOUND_WAND_LIGHTNING_ABILITY_PAP_SMITE, 0, SNDCHAN_AUTO, 100, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, flMyPos);
		EmitSoundToAll(SOUND_WAND_LIGHTNING_ABILITY_PAP_SMITE, 0, SNDCHAN_AUTO, 100, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, flMyPos);
		npc.m_flGravityMulti = 1.0;
		if(IsValidEntity(npc.m_iWearable5))
			RemoveEntity(npc.m_iWearable5);
		if(IsValidEntity(npc.m_iWearable4))
			RemoveEntity(npc.m_iWearable4);
	}
	if (npc.m_iChanged_WalkCycle == 402 && npc.m_flDoingAnimation < gameTime)
	{
		npc.m_iChanged_WalkCycle = 0;
		npc.m_iWhatAbilityDo = 0;
	}
	return true;
}