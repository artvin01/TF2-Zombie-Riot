#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/mvm/norm/heavy_mvm_paincrticialdeath01.mp3",
	"vo/mvm/norm/heavy_mvm_paincrticialdeath02.mp3",
	"vo/mvm/norm/heavy_mvm_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/mvm/norm/heavy_mvm_painsharp01.mp3",
	"vo/mvm/norm/heavy_mvm_painsharp02.mp3",
	"vo/mvm/norm/heavy_mvm_painsharp03.mp3",
	"vo/mvm/norm/heavy_mvm_painsharp04.mp3",
	"vo/mvm/norm/heavy_mvm_painsharp05.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/mvm/norm/heavy_mvm_standonthepoint01.mp3",
	"vo/mvm/norm/heavy_mvm_standonthepoint02.mp3",
	"vo/mvm/norm/heavy_mvm_standonthepoint03.mp3",
	"vo/mvm/norm/heavy_mvm_standonthepoint04.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"ui/item_robot_arm_drop.wav",
};

static const char g_MeleeHitSounds[][] = {
	"player/taunt_tank_drop.wav",
};

static const char g_VincentMeleeCharge_Hit[][] =
{
	"misc/halloween/spell_mirv_explode_secondary.wav",
};
static const char g_VincentSlamSound[][] =
{
	"weapons/crossbow/bolt_fly4.wav",
};
static const char g_VincentJumpSound[][] =
{
	"npc/env_headcrabcanister/launch.wav",
};
static const char g_PassiveSound[][] = {
	"mvm/giant_heavy/giant_heavy_loop.wav",
};
static const char g_PrepareSlamThrow[][] =
{
	"vo/mvm/mght/heavy_mvm_m_incoming01.mp3",
	"vo/mvm/mght/heavy_mvm_m_incoming02.mp3",
	"vo/mvm/mght/heavy_mvm_m_incoming03.mp3",
};
static const char g_VincentFireIgniteSound[][] =
{
	")misc/flame_engulf.wav",
};

static const char g_SuicideSound[][] = {
	"ambient/explosions/citadel_end_explosion1.wav",
};

static const char g_OilModel[] = "models/props_farm/haypile001.mdl";

#define VINCENT_OIL_MODEL_DEFAULT_RADIUS 140.0
#define VINCENT_OIL_MODEL_SCALE 1.5

#define VINCENT_OIL_MODEL_OFFSET_Z -4.0
int HitEntitiesSphereMlynar[MAXENTITIES];

void Vincent_OnMapStart_NPC()
{
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Vincent");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_vincent");
	strcopy(data.Icon, sizeof(data.Icon), "vincent_1");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Aperture;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_PassiveSound));   i++) { PrecacheSound(g_PassiveSound[i]);   }
	for (int i = 0; i < (sizeof(g_SuicideSound));   i++) { PrecacheSound(g_SuicideSound[i]);   }
	PrecacheSoundArray(g_VincentMeleeCharge_Hit);
	PrecacheSoundArray(g_PrepareSlamThrow);
	PrecacheSoundArray(g_VincentSlamSound);
	PrecacheSoundArray(g_VincentJumpSound);
	PrecacheSoundArray(g_VincentFireIgniteSound);
	
	PrecacheSound("mvm/giant_heavy/giant_heavy_entrance.wav");
	
	PrecacheModel("models/bots/heavy/bot_heavy.mdl");
	PrecacheModel(g_OilModel);
	
	PrecacheParticleSystem("gas_can_impact_blue");
	//you cant do this lol
	PrecacheSoundCustom("#zombiesurvival/aperture/vincent_loop.mp3");
	PrecacheSoundCustom("#zombiesurvival/aperture/vincent_intro.mp3");
	PrecacheSoundCustom("#zombiesurvival/aperture/vincent_angry.mp3");
	
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return Vincent(vecPos, vecAng, ally, data);
}

methodmap Vincent < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, 90, BOSS_ZOMBIE_VOLUME, 80);
	}

	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, 90, BOSS_ZOMBIE_VOLUME, 80);
	}
	public void PlayPrepareSlamSound() 
	{
		int Sound = GetRandomInt(0, sizeof(g_PrepareSlamThrow) - 1);
		EmitSoundToAll("mvm/mvm_tank_horn.wav",_, SNDCHAN_STATIC, 80, _, 0.65, 90);
		EmitSoundToAll(g_PrepareSlamThrow[Sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, 90, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_PrepareSlamThrow[Sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, 90, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 90);
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 90);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 90);
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 90);
	}
	public void PlayVincentMeleeSuper()
	{
		int pitch = GetRandomInt(70,80);
		EmitSoundToAll(g_VincentMeleeCharge_Hit[GetRandomInt(0, sizeof(g_VincentMeleeCharge_Hit) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, 0.7, pitch);
		EmitSoundToAll(g_VincentMeleeCharge_Hit[GetRandomInt(0, sizeof(g_VincentMeleeCharge_Hit) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, 0.7, pitch);
	}
	public void PlayVincentSlamSound()
	{
		int pitch = GetRandomInt(70,80);
		EmitSoundToAll(g_VincentSlamSound[GetRandomInt(0, sizeof(g_VincentSlamSound) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, 0.7, pitch);
		EmitSoundToAll(g_VincentSlamSound[GetRandomInt(0, sizeof(g_VincentSlamSound) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, 0.7, pitch);
	}
	public void PlayVincentJumpSound()
	{
		int pitch = GetRandomInt(70,80);
		EmitSoundToAll(g_VincentJumpSound[GetRandomInt(0, sizeof(g_VincentJumpSound) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, 0.7, pitch);
		EmitSoundToAll(g_VincentJumpSound[GetRandomInt(0, sizeof(g_VincentJumpSound) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, 0.7, pitch);
		EmitSoundToAll(g_VincentJumpSound[GetRandomInt(0, sizeof(g_VincentJumpSound) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, 0.7, pitch);
	}
	public void PlayIgniteSound()
	{
		EmitSoundToAll(g_VincentFireIgniteSound[GetRandomInt(0, sizeof(g_VincentFireIgniteSound) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, 0.7);
	}
	public void PlaySuicideSound() 
	{
		EmitSoundToAll(g_SuicideSound[GetRandomInt(0, sizeof(g_SuicideSound) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 90);
		EmitSoundToAll(g_SuicideSound[GetRandomInt(0, sizeof(g_SuicideSound) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 90);
	}

	property float m_flNextOilPouring
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	
	property bool m_bDoingOilPouring
	{
		public get()							{ return b_FlamerToggled[this.index]; }
		public set(bool TempValueForProperty) 	{ b_FlamerToggled[this.index] = TempValueForProperty; }
	}
	
	property float m_flLeakingOilUntil
	{
		public get()							{ return fl_AbilityOrAttack[this.index][5]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][5] = TempValueForProperty; }
	}
	
	property float m_flNextOilLeak
	{
		public get()							{ return fl_AbilityOrAttack[this.index][6]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][6] = TempValueForProperty; }
	}
	property float m_flLazyJumpFix
	{
		public get()							{ return fl_AbilityOrAttack[this.index][7]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][7] = TempValueForProperty; }
	}
	
	property float m_flOverrideMusicNow
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flThrow_Cooldown
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flThrow_Happening
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	property float m_flRegainNormalWalk
	{
		public get()							{ return fl_AbilityOrAttack[this.index][4]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][4] = TempValueForProperty; }
	}
	property float m_flTalkRepeat
	{
		public get()							{ return fl_AbilityOrAttack[this.index][8]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][8] = TempValueForProperty; }
	}
	property int m_iTalkState
	{
		public get()							{ return i_OverlordComboAttack[this.index]; }
		public set(int TempValueForProperty) 	{ i_OverlordComboAttack[this.index] = TempValueForProperty; }
	}
	property float m_flMegaEnrage
	{
		public get()							{ return fl_AbilityOrAttack[this.index][9]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][9] = TempValueForProperty; }
	}
	public void PlayPassiveSound()
	{
		EmitSoundToAll(g_PassiveSound[GetRandomInt(0, sizeof(g_PassiveSound) - 1)], this.index, SNDCHAN_STATIC, 90, _, 1.0, 100);
	}
	public void StopPassiveSound()
	{
		StopSound(this.index, SNDCHAN_STATIC, g_PassiveSound[GetRandomInt(0, sizeof(g_PassiveSound) - 1)]);
		StopSound(this.index, SNDCHAN_STATIC, g_PassiveSound[GetRandomInt(0, sizeof(g_PassiveSound) - 1)]);
	}
	public Vincent(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Vincent npc = view_as<Vincent>(CClotBody(vecPos, vecAng, "models/player/heavy.mdl" /*"models/bots/heavy/bot_heavy.mdl"*/, "1.45", "700", ally, false, true, true, true));
		
		i_NpcWeight[npc.index] = 4;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = false;
		npc.m_flTalkRepeat = 0.0;
		npc.SetActivity("ACT_MP_RUN_MELEE");

		func_NPCDeath[npc.index] = Vincent_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Vincent_OnTakeDamage;
		func_NPCThink[npc.index] = Vincent_ClotThink;
		func_NPCFuncWin[npc.index] = view_as<Function>(Raidmode_Expidonsa_Sensal_Win);

		RaidModeTime = GetGameTime() + 200.0;
		b_thisNpcIsARaid[npc.index] = true;
		b_ThisNpcIsImmuneToNuke[npc.index] = true;

		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "item_armor", 1, "%s", "Vincent sets foot");
			}
		}
		
		char buffers[3][64];
		ExplodeString(data, ";", buffers, sizeof(buffers), sizeof(buffers[]));
		//the very first and 2nd char are SC for scaling
		if(buffers[0][0] == 's' && buffers[0][1] == 'c')
		{
			//remove SC
			ReplaceString(buffers[0], 64, "sc", "");
			float value = StringToFloat(buffers[0]);
			RaidModeScaling = value;
		}
		else
		{	
			RaidModeScaling = float(Waves_GetRoundScale()+1);
		}

		if(RaidModeScaling < 35)
		{
			RaidModeScaling *= 0.25; //abit low, inreacing
		}
		else
		{
			RaidModeScaling *= 0.5;
		}
		
		float amount_of_people = ZRStocks_PlayerScalingDynamic();
		if(amount_of_people > 12.0)
		{
			amount_of_people = 12.0;
		}
		amount_of_people *= 0.12;
		
		if(amount_of_people < 1.0)
			amount_of_people = 1.0;
			
		RaidModeScaling *= amount_of_people;
		//scaling old
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.PlayPassiveSound();
		npc.Anger = false;
		if(StrContains(data, "forceangry") != -1)
		{
			npc.Anger = true;
			//force angry
		}
		if(Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.Anger = true;
		}
		if(Aperture_IsBossDead(APERTURE_BOSS_CAT)  || Aperture_IsBossDead(APERTURE_BOSS_ARIS) || StrContains(data, "forcesad") != -1)
		{
			npc.m_flRangedArmor *= 0.9;
			npc.m_flMeleeArmor *= 0.9;	
			npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/heavy/tw_heavybot_helmet/tw_heavybot_helmet.mdl", _, skin);
		}
		VincentSpawnBeacons(npc.index);

		npc.m_flMeleeArmor = 1.25;	
		npc.m_flOverrideMusicNow = GetGameTime() + 5.0;
		npc.m_flSpeed = 320.0;
		if(npc.Anger)
		{
			npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/heavy/tw_heavybot_armor/tw_heavybot_armor.mdl", _, skin);
			RaidModeScaling *= 1.1;
			Format(c_NpcName[npc.index], sizeof(c_NpcName[]), "V.I.N.C.E.N.T.");
			EmitSoundToAll("mvm/mvm_tank_horn.wav",_, SNDCHAN_STATIC, 80, _, 0.7, 80);
			EmitSoundToAll("mvm/giant_heavy/giant_heavy_entrance.wav", _, _, _, _, 1.0, 100);	
			CPrintToChatAll("{rare}%t{default}: You want a death robot? {crimson}I'LL GIVE YOU ONE.", c_NpcName[npc.index]);
			CPrintToChatAll("{fullred}Initating extermination of infection based organisms.");
			npc.m_flRangedArmor *= 0.95;
			npc.m_flMeleeArmor *= 0.95;	
			npc.m_flOverrideMusicNow = 0.0;
			MusicEnum music;
			strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/aperture/vincent_angry.mp3");
			music.Time = 112;
			music.Volume = 1.0;
			music.Custom = true;
			strcopy(music.Name, sizeof(music.Name), "CREATION OF HATRED");
			strcopy(music.Artist, sizeof(music.Artist), "Exedious");
			Music_SetRaidMusic(music);
		}
		else
		{
			Format(c_NpcName[npc.index], sizeof(c_NpcName[]), "Vincent");
			EmitSoundToAll("mvm/giant_heavy/giant_heavy_entrance.wav", _, _, _, _, 1.0, 100);	
			EmitSoundToAll("mvm/giant_heavy/giant_heavy_entrance.wav", _, _, _, _, 1.0, 100);	
			CPrintToChatAll("{rare}%t{default}: Not gonna leave? I'll make you leave myself.", c_NpcName[npc.index]);
			MusicEnum music;
			strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/aperture/vincent_intro.mp3");
			music.Time = 51;
			music.Volume = 1.2;
			music.Custom = true;
			strcopy(music.Name, sizeof(music.Name), "System Corruption (Intro)");
			strcopy(music.Artist, sizeof(music.Artist), "Harry Callaghan");
			Music_SetRaidMusic(music);
		}
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flThrow_Cooldown = GetGameTime() + 7.0;
		
		npc.m_flNextOilPouring = GetGameTime() + 15.0;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_PANZER;

		Citizen_MiniBossSpawn();
		npc.StartPathing();
		
		// Make him invisible so we can use human heavy anims
		SetEntityRenderColor(npc.index, .a = 0);
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		npc.m_iWearable1 = npc.EquipItem("head", "models/bots/heavy/bot_heavy.mdl", _, skin);

		if(IsValidEntity(npc.m_iWearable1))
		{
			TE_SetupParticleEffect("utaunt_iconicoutline_orange_glow", PATTACH_ABSORIGIN_FOLLOW, npc.m_iWearable1);
			TE_WriteNum("m_bControlPoint1", npc.m_iWearable1);	
			TE_SendToAll();
		}

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/heavy/sf14_heavy_robo_chest/sf14_heavy_robo_chest.mdl", _, skin);
		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
		npc.m_bTeamGlowDefault = false;
		
		SetVariantColor(view_as<int>({200, 200, 50, 200}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");

		Vincent_SpawnFog(npc.index);

		return npc;
	}
}

public void Vincent_ClotThink(int iNPC)
{
	Vincent npc = view_as<Vincent>(iNPC);
	float gameTime = GetGameTime(npc.index);
	
	if(npc.m_flMegaEnrage)
	{
		for(int entitycount; entitycount<MAXENTITIES; entitycount++) //Check for npcs
		{
			if(IsValidEnemy(npc.index, entitycount))
				ApplyStatusEffect(npc.index, entitycount, "Nightmare Terror", 2.0);
		}
	}
	Vincent_AdjustGrabbedTarget(iNPC);
	if(Vincent_LoseConditions(iNPC))
		return;

	if(npc.m_flNextDelayTime > gameTime)
		return;

	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
		
	npc.m_flNextThinkTime = gameTime + 0.1;

	if (npc.m_flRegainNormalWalk)
	{
		if (npc.m_flRegainNormalWalk < gameTime)
		{
			npc.m_flRegainNormalWalk = 0.0;
			if(npc.m_iChanged_WalkCycle != 1)
			{
				npc.m_iChanged_WalkCycle = 1;
				npc.m_bisWalking = true;
				npc.StartPathing();
				npc.m_flSpeed = 320.0;
				npc.SetActivity("ACT_MP_RUN_MELEE");
				npc.SetPoseParameter_Easy("body_pitch", 0.0);
				npc.RemoveGesture("ACT_MP_ATTACK_STAND_POSTFIRE");
				if(HasSpecificBuff(npc.index, "Intangible"))
				{
					RemoveSpecificBuff(npc.index, "Intangible");
					f_CheckIfStuckPlayerDelay[npc.index] = 0.0;
					b_ThisEntityIgnoredBeingCarried[npc.index] = false; 

				}
			}
				
		}
	}
	if (npc.m_flLeakingOilUntil >= gameTime && npc.m_flNextOilLeak < gameTime)
	{
		npc.m_flNextOilLeak += 0.5;
		
		float vecPos[3];
		GetAbsOrigin(npc.index, vecPos);
		
		Vincent_PourOil(npc, vecPos, VINCENT_OIL_MODEL_DEFAULT_RADIUS * VINCENT_OIL_MODEL_SCALE, 5.0, 0.0, false);
	}
	if (npc.m_bDoingOilPouring)
	{
		if (npc.m_flNextOilPouring < gameTime)
		{
			npc.m_bDoingOilPouring = false;
			npc.m_flNextOilPouring = gameTime + 15.0;
			npc.m_flRegainNormalWalk = 1.0;
			return;
		}
		else
		{
			return;
		}
	}
	
	if (npc.m_flNextOilPouring < gameTime && npc.m_flDoingAnimation < gameTime && !npc.m_flThrow_Happening)
	{
		npc.m_flSpeed = 0.0;
		npc.m_bisWalking = false;
		npc.m_iChanged_WalkCycle = 3;
		npc.AddActivityViaSequence("taunt_soviet_strongarm_end");
		npc.SetCycle(0.05);
		npc.SetPlaybackRate(0.5);
		npc.StopPathing();
		
		float delay = 2.0;
		if (npc.m_flMegaEnrage)
			delay *= 0.5;
		
		Vincent_PourOilAbility(npc, 30.0, delay);
		if(!Aperture_IsBossDead(APERTURE_BOSS_CAT) && !Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			switch(GetRandomInt(0,2))
			{
				case 0:
					CPrintToChatAll("{rare}%t{default}: Someone turn the heat up.", c_NpcName[npc.index]);
				case 1:
					CPrintToChatAll("{rare}%t{default}: Is it just me or are you engulfed in flames?", c_NpcName[npc.index]);
				case 2:
					CPrintToChatAll("{rare}%t{default}: Spreading the inferno.", c_NpcName[npc.index]);
			}
		}
	}
	
	if (npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	int target = npc.m_iTarget;
	if (IsValidEnemy(npc.index, target))
	{
		float vecPos[3], vecTargetPos[3];
		WorldSpaceCenter(npc.index, vecPos);
		WorldSpaceCenter(target, vecTargetPos);
		
		float distance = GetVectorDistance(vecPos, vecTargetPos, true);
		
		//we have a target we wanna walk to, override normal walking, but keep old distance checks.
		int WalkTo = target;
		if(IsValidEntity(npc.m_iTargetWalkTo))
		{
			WalkTo = npc.m_iTargetWalkTo;
		}
		WorldSpaceCenter(WalkTo, vecTargetPos);
		float distanceWalk = GetVectorDistance(vecPos, vecTargetPos, true);
		// Predict their pos when not loading our gun
		if (distanceWalk < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; PredictSubjectPosition(npc, WalkTo, _, _, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else
		{
			npc.SetGoalEntity(WalkTo);
		}
		
		if(Vincent_SlamThrow(iNPC, target))
			return;
		Vincent_SelfDefense(npc, gameTime, target, distance);
	}
	else
	{
		//no valid target, do stuff.
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	
	npc.PlayIdleAlertSound();
}

static void Vincent_SelfDefense(Vincent npc, float gameTime, int target, float distance)
{
	if (npc.m_flAttackHappens && npc.m_flAttackHappens < GetGameTime(npc.index))
	{
		npc.m_flAttackHappens = 0.0;
		
		if(IsValidEnemy(npc.index, target))
		{
			int HowManyEnemeisAoeMelee = 64;
			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 1, _, HowManyEnemeisAoeMelee);
			delete swingTrace;
			bool PlaySound = false;
			float damage = 45.0;
			damage *= RaidModeScaling;
			bool silenced = NpcStats_IsEnemySilenced(npc.index);
			
			KillFeed_SetKillIcon(npc.index, npc.Anger ? "hale_megapunch" : "hale_punch");
			
			for(int counter = 1; counter <= HowManyEnemeisAoeMelee; counter++)
			{
				if(i_EntitiesHitAoeSwing_NpcSwing[counter] <= 0)
					continue;
				if(!IsValidEntity(i_EntitiesHitAoeSwing_NpcSwing[counter]))
					continue;

				int targetTrace = i_EntitiesHitAoeSwing_NpcSwing[counter];
				float vecHit[3];
				
				WorldSpaceCenter(targetTrace, vecHit);

				SDKHooks_TakeDamage(targetTrace, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);
				Vincent_SuperAttackBehindTarget(npc.index, targetTrace, damage, DMG_CLUB, 500.0, 40.0);

				bool Knocked = false;
				if(!PlaySound)
				{
					PlaySound = true;
				}
				
				if(IsValidClient(targetTrace))
				{
					if (IsInvuln(targetTrace))
					{
						Knocked = true;
						Custom_Knockback(npc.index, targetTrace, 180.0, true);
						if(!silenced)
						{
							TF2_AddCondition(targetTrace, TFCond_LostFooting, 0.5);
							TF2_AddCondition(targetTrace, TFCond_AirCurrent, 0.5);
						}
					}
					else
					{
						if(!silenced)
						{
							TF2_AddCondition(targetTrace, TFCond_LostFooting, 0.5);
							TF2_AddCondition(targetTrace, TFCond_AirCurrent, 0.5);
						}
					}
				}			
				if(!Knocked)
					Custom_Knockback(npc.index, targetTrace, 450.0, true); 
			}
			if(PlaySound)
			{
				npc.PlayMeleeHitSound();
			}
		}
	}

	if (gameTime > npc.m_flNextMeleeAttack)
	{
		if (distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.25))
		{
			int Enemy_I_See;
			Enemy_I_See = Can_I_See_Enemy(npc.index, target);

			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;

				npc.PlayMeleeSound();
				npc.m_flAttackHappens = gameTime + 0.2;
				npc.m_flDoingAnimation = gameTime + 0.2;
				float attack = 1.0;
				if(npc.Anger)
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE", .SetGestureSpeed = (1.0 / 0.75));
					attack *= 0.75;
				}
				else
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
				}
				npc.m_flNextMeleeAttack = gameTime + attack;
				return;
			}
		}
	}
}

public Action Vincent_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Vincent npc = view_as<Vincent>(victim);
	
	if (!npc.m_bLostHalfHealth && (ReturnEntityMaxHealth(npc.index) / 2) >= GetEntProp(npc.index, Prop_Data, "m_iHealth"))
	{
		npc.m_bLostHalfHealth = true;
	}
	
	int maxhealth = ReturnEntityMaxHealth(npc.index);
	
	if(!npc.Anger || (npc.m_flMegaEnrage && npc.m_flMegaEnrage < GetGameTime()))
	{
		if((RoundToCeil(damage) >= GetEntProp(npc.index, Prop_Data, "m_iHealth")) && Aperture_ShouldDoLastStand())
		{
			if(!npc.m_flTalkRepeat)
			{
				ApplyStatusEffect(victim, victim, "Infinite Will", 99999.0);
				npc.m_flTalkRepeat = 1.0;
				damage = 0.0;
				return Plugin_Continue;
			}
		}
	}
	else if(npc.Anger)
	{
		if((RoundToCeil(damage) >= GetEntProp(npc.index, Prop_Data, "m_iHealth")))
		{
			if(!npc.m_flMegaEnrage)
			{
				ApplyStatusEffect(victim, victim, "Infinite Will", 30.0);
				npc.m_flMegaEnrage = GetGameTime() + 30.0;
				damage = 0.0;
				CPrintToChatAll("{rare}%t:{crimson} ...IF YOU THINK I'LL GO DOWN WITHOUT A FIGHT...", c_NpcName[npc.index]);
				EmitSoundToAll("mvm/mvm_tank_horn.wav",_, SNDCHAN_STATIC, 80, _, 0.65, 90);
				EmitSoundToAll("mvm/mvm_tank_horn.wav",_, SNDCHAN_STATIC, 80, _, 0.65, 90);
				ApplyStatusEffect(npc.index, npc.index, "Dimensional Turbulence", 30.0);
				RaidModeTime += 35.0;
				return Plugin_Continue;
			}
		}
	}
	if(!npc.m_flTalkRepeat)
	{
		float ratio = float(GetEntProp(npc.index, Prop_Data, "m_iHealth")) / float(maxhealth);
		if(0.9-(npc.g_TimesSummoned*0.25) > ratio)
		{
			npc.g_TimesSummoned++;
			float DurationHave = 3.0;
			if(npc.Anger)
				DurationHave = 5.0;

			RaidModeTime += DurationHave;

			float pos[3];
			float ang[3];
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);

			ApplyStatusEffect(npc.index, npc.index, "Very Defensive Backup", DurationHave);
			ApplyStatusEffect(npc.index, npc.index, "Expidonsan War Cry", DurationHave);
			
			if(npc.Anger)
				ApplyStatusEffect(npc.index, npc.index, "Extreme Anxiety", DurationHave);


			int NpcSpawn = NPC_CreateByName("npc_vincent_beacon", -1, pos, ang, GetTeam(npc.index));

			Vincent npcBeacon = view_as<Vincent>(NpcSpawn);
			npcBeacon.Anger = npc.Anger;
			npcBeacon.m_iWearable1 = npcBeacon.EquipItemSeperate("models/buildables/sentry_shield.mdl",_,1,_,-65.0, true);
			SetVariantString("2.0");
			AcceptEntityInput(npcBeacon.m_iWearable1, "SetModelScale");
			
			CPrintToChatAll("{rare}%t's armor hardens and fists strengthen, aided by the laboratory.", c_NpcName[npc.index]);
		}	
	}
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void Vincent_NPCDeath(int entity)
{
	Vincent npc = view_as<Vincent>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
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
	npc.StopPassiveSound();
	if(FogEntity != INVALID_ENT_REFERENCE)
	{
		int entity1 = EntRefToEntIndex(FogEntity);
		if(entity1 > MaxClients)
			RemoveEntity(entity1);
		
		FogEntity = INVALID_ENT_REFERENCE;
	}

}

static void Vincent_GrantItem(int entity)
{
	Vincent npc = view_as<Vincent>(entity);
	for (int client = 1; client <= MaxClients; client++)
	{
		if(IsValidClient(client) && GetClientTeam(client) == 2 && TeutonType[client] != TEUTON_WAITING && PlayerPoints[client] > 500)
		{
			if(!npc.Anger)
			{
				Items_GiveNamedItem(client, "Expidonsan Research Card");
				CPrintToChat(client,"{default}Vincent permitted you to access the laboratories. You have obtained: {unique}Expidonsan Research Card.");
			}
			if(npc.Anger)
			{
				Items_GiveNamedItem(client, "Expidonsan Research Card");
				CPrintToChat(client,"{default}Vincent is gone...all that's left is this keycard on the floor. You have obtained: {crimson}Expidonsan Research Card.");
			}
		}
	}
}

static bool Vincent_LoseConditions(int iNPC)
{
	Vincent npc = view_as<Vincent>(iNPC);
	
	if(npc.m_flTalkRepeat)
	{
		if(npc.m_flTalkRepeat > GetGameTime())
			return true;
			
		if(npc.m_iChanged_WalkCycle != 10)
		{
			npc.m_iChanged_WalkCycle = 10;
			npc.SetPoseParameter_Easy("body_pitch", 0.0);
			npc.RemoveGesture("ACT_MP_ATTACK_STAND_POSTFIRE");
			npc.m_flSpeed = 0.0;
			npc.StopPathing();
			if(HasSpecificBuff(npc.index, "Intangible"))
			{
				RemoveSpecificBuff(npc.index, "Intangible");
				f_CheckIfStuckPlayerDelay[npc.index] = 0.0;
				b_ThisEntityIgnoredBeingCarried[npc.index] = false; 
			}
			npc.AddActivityViaSequence("layer_tauntrussian_rubdown");
			int AnimLayer = npc.AddGestureViaSequence("armslayer_throw_fire");
			npc.SetLayerPlaybackRate(AnimLayer, (0.01));
			npc.SetLayerCycle(AnimLayer, (0.0));
			npc.SetCycle(0.5);
			npc.SetPlaybackRate(0.0);
		}
		if(npc.Anger)
		{
			//Angry blah
			switch(npc.m_iTalkState)
			{
				case 0:
				{
					//yapping
					npc.m_flTalkRepeat = GetGameTime() + 3.0;
					CPrintToChatAll("{rare}%t{crimson}: No...", c_NpcName[npc.index]);
				}
				case 1:
				{
					//yapping
					npc.m_flTalkRepeat = GetGameTime() + 3.0;
					CPrintToChatAll("{rare}%t{crimson}: I can't let you get away with this.", c_NpcName[npc.index]);
				}
				case 2:
				{
					//yapping
					npc.m_flTalkRepeat = GetGameTime() + 3.0;
					CPrintToChatAll("{rare}%t{crimson}: I WON'T let you get away with this!", c_NpcName[npc.index]);
				}
				case 3:
				{
					//yapping
					npc.m_flTalkRepeat = GetGameTime() + 1.5;
					float Loc[3];
					GetAbsOrigin(npc.index, Loc);
					spawnRing_Vectors(Loc, 0.1, 0.0, 0.0, 1.0, "materials/sprites/laserbeam.vmt", 255, 0, 20, 255, 1, 1.5, 8.0, 1.5, 1, 150.0*2.0);
					spawnRing_Vectors(Loc, 0.1, 0.0, 0.0, 25.0, "materials/sprites/laserbeam.vmt", 255, 0, 20, 255, 1, 1.5, 8.0, 1.5, 1, 150.0*2.0);
					spawnRing_Vectors(Loc, 0.1, 0.0, 0.0, 45.0, "materials/sprites/laserbeam.vmt", 255, 0, 20, 255, 1, 1.5, 8.0, 1.5, 1, 150.0*2.0);
					spawnRing_Vectors(Loc, 0.1, 0.0, 0.0, 65.0, "materials/sprites/laserbeam.vmt", 255, 0, 20, 255, 1, 1.5, 8.0, 1.5, 1, 150.0*2.0);
					CPrintToChatAll("{rare}%t{crimson}: I'M GONNA DELETE YOU!", c_NpcName[npc.index]);
					Format(c_NpcName[npc.index], sizeof(c_NpcName[]), "Old forgotten expidonsan robot");
				}
				case 4:
				{
					//yapping
					float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
					npc.m_flTalkRepeat = GetGameTime() + 0.0;
					for(int client_check=1; client_check<=MaxClients; client_check++)
					{
						if(IsClientInGame(client_check) && !IsFakeClient(client_check))
						{
							UTIL_ScreenFade(client_check, 66, 99999, FFADE_OUT | FFADE_STAYOUT, 255, 255, 255, 255); //make the fade target everyone
						}
					}
					
					CreateTimer(6.0, Timer_Vincent_FadeBackIn, TIMER_FLAG_NO_MAPCHANGE);
					KillFeed_SetKillIcon(npc.index, "megaton");
					Explode_Logic_Custom(10000.0, -1, npc.index, -1, vecMe, 250.0, _, _, false, 1, false);
					npc.PlaySuicideSound();
				}
				case 5:
				{
					//ending
					Vincent_GrantItem(npc.index);
					RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
				}
			}
		}
		else
		{
			//not angry blah
			switch(npc.m_iTalkState)
			{
				case 0:
				{
					npc.m_flTalkRepeat = GetGameTime() + 3.0;
					CPrintToChatAll("{rare}%t{default}: Ah.", c_NpcName[npc.index]);
				}
				case 1:
				{
					npc.m_flTalkRepeat = GetGameTime() + 3.0;
					CPrintToChatAll("{rare}%t{default}: It appears that I'm not strong enough to take you down.", c_NpcName[npc.index]);
				}
				case 2:
				{
					npc.m_flTalkRepeat = GetGameTime() + 3.0;
					CPrintToChatAll("{rare}%t{default}: I was hoping to keep the outside world safe with what was left behind here.", c_NpcName[npc.index]);
				}
				case 3:
				{
					npc.m_flTalkRepeat = GetGameTime() + 3.0;
					CPrintToChatAll("{rare}%t{default}: But if you're so persistent on taking this gear...", c_NpcName[npc.index]);
				}
				case 4:
				{
					npc.m_flTalkRepeat = GetGameTime() + 3.0;
					CPrintToChatAll("{rare}%t{default}: I won't try to stop you anymore, knowing that my attempts will be futile.", c_NpcName[npc.index]);
				}
				case 5:
				{
					npc.m_flTalkRepeat = GetGameTime() + 3.0;
					CPrintToChatAll("{rare}%t{default}: Take this with you, and don't let it fall into the wrong hands, alright?", c_NpcName[npc.index]);
				}
				case 6:
				{
					//ending
					npc.m_bDissapearOnDeath = true;
					Vincent_GrantItem(npc.index);
					RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
				}
			}
		}
		npc.m_iTalkState++;
		npc.Update();
		return true;
	}
	//reuse for music.
	if(npc.m_flOverrideMusicNow)
	{
		if(npc.m_flOverrideMusicNow < GetGameTime())
		{
			npc.m_flOverrideMusicNow = 0.0;
			MusicEnum music;
			strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/aperture/vincent_loop.mp3");
			music.Time = 77;
			music.Volume = 1.2;
			music.Custom = true;
			strcopy(music.Name, sizeof(music.Name), "System Corruption");
			strcopy(music.Artist, sizeof(music.Artist), "Harry Callaghan");
			Music_SetRaidMusic(music, false);
		}
	}	
	if(IsValidEntity(RaidBossActive) && i_RaidGrantExtra[npc.index] == RAIDITEM_INDEX_WIN_COND)
	{
		RaidBossActive = INVALID_ENT_REFERENCE;
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		//won normally
		if(!Aperture_IsBossDead(APERTURE_BOSS_CAT) && !Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			CPrintToChatAll("{rare}%t{default}: It's over, please don't come back.", c_NpcName[npc.index]);
		}
		else if(Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			CPrintToChatAll("{rare}%t{crimson}: Look at what you made me do. {default} At least I avenged {rare}them{default}.", c_NpcName[npc.index]);
		}
		else if(Aperture_IsBossDead(APERTURE_BOSS_CAT) || Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			CPrintToChatAll("{rare}%t{default}: Your reign of chaos ends here.", c_NpcName[npc.index]);
		}
		return true;
	}
	else if(IsValidEntity(RaidBossActive) && RaidModeTime < GetGameTime())
	{
		ForcePlayerLoss();
		RaidBossActive = INVALID_ENT_REFERENCE;
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		//won timer
		if(!Aperture_IsBossDead(APERTURE_BOSS_CAT) && !Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			CPrintToChatAll("{rare}%t{default}: I'm sorry it had to end this way, you shouldn't have taken that job...", c_NpcName[npc.index]);
		}
		else if(Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			CPrintToChatAll("{rare}%t{crimson}: You're done.", c_NpcName[npc.index]);
		}
		else if(Aperture_IsBossDead(APERTURE_BOSS_CAT) || Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			CPrintToChatAll("{rare}%t{default}: You can't keep running away forever.", c_NpcName[npc.index]);
		}
		return true;
	}
	
	return false;
}

static bool TraceEntityFilter_Vincent_OnlyWorld(int entity, int mask)
{
	return entity == 0 || entity > MAXENTITIES;
}

static void Timer_Vincent_IgniteOil(Handle timer, DataPack pack)
{
	pack.Reset();
	int refEnt = pack.ReadCell();
	int entity = EntRefToEntIndex(refEnt);
	if (entity == INVALID_ENT_REFERENCE)
		return;
	
	int refOwner = pack.ReadCell();
	int owner = EntRefToEntIndex(refOwner);
	if (owner == INVALID_ENT_REFERENCE)
		return;
	
	float radius = pack.ReadFloat();
	bool fromAbility = pack.ReadCell();
	
	if (radius > 0.0)
	{
		float vecPos[3];
		GetAbsOrigin(entity, vecPos);
		
		spawnRing_Vectors(vecPos, 0.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 204, 85, 0, 255, 1, 0.6 /*duration */, 1.0, 0.1, 1, radius);
		
		DataPack pack2;
		CreateDataTimer(0.3, Timer_Vincent_OilBurning, pack2, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		pack2.WriteCell(refEnt);
		pack2.WriteCell(refOwner);
		pack2.WriteFloat(radius);
		pack2.WriteCell(fromAbility);
	}
	
	Vincent npc = view_as<Vincent>(owner);
	npc.PlayIgniteSound();
	
	SetEntityRenderMode(entity, RENDER_NONE);
	IgniteTargetEffect(entity);
}

static Action Timer_Vincent_OilBurning(Handle timer, DataPack pack)
{
	pack.Reset();
	int refEnt = pack.ReadCell();
	int entity = EntRefToEntIndex(refEnt);
	if (entity == INVALID_ENT_REFERENCE)
		return Plugin_Stop;
	
	int refOwner = pack.ReadCell();
	int owner = EntRefToEntIndex(refOwner);
	if (owner == INVALID_ENT_REFERENCE)
	{
		RemoveEntity(entity);
		return Plugin_Stop;
	}
	
	float radius = pack.ReadFloat();
	bool fromAbility = pack.ReadCell();
	
	float vecPos[3];
	GetAbsOrigin(entity, vecPos);
	
	spawnRing_Vectors(vecPos, 0.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 204, 85, 0, 255, 1, 0.6 /*duration */, 1.0, 0.1, 1, radius);
	
	Vincent npc = view_as<Vincent>(owner);
	
	// Make fire harmless if Vincent is yapping
	if (npc.m_flTalkRepeat)
		return Plugin_Continue;
	
	for(int i=0; i < MAXENTITIES; i++)
	{
		HitEntitiesSphereMlynar[i] = false;
	}
	//cannot do logic inside, only detect.
	TR_EnumerateEntitiesSphere(vecPos, VINCENT_OIL_MODEL_DEFAULT_RADIUS, PARTITION_NON_STATIC_EDICTS, TraceEntityEnumerator_Vincent_Oil);
	
	bool hit = false;
	
	for (int entity_traced = 0; entity_traced < MAXENTITIES; entity_traced++)
	{
		if (HitEntitiesSphereMlynar[entity_traced] > 0)
		{
			int entity_hit = HitEntitiesSphereMlynar[entity_traced];
			
			if (fromAbility && entity_hit == owner && npc.m_bLostHalfHealth)
			{
				npc.m_flLeakingOilUntil = GetGameTime(npc.index) + 7.5;
				npc.m_flNextOilLeak = GetGameTime(npc.index) + 0.5;
				continue;
			}
			
			if (!IsValidEnemy(entity_hit, owner))
				continue;
			
			float vecTargetPos[3];
			GetAbsOrigin(entity_hit, vecTargetPos);
			
			float difference = fabs(vecPos[2] - vecTargetPos[2]);
			if (difference > 90.0)
				continue;
			
			if (entity_hit > 0 && entity_hit <= MaxClients && !HasSpecificBuff(entity_hit, "Burn"))
				EmitSoundToClient(entity_hit, g_VincentFireIgniteSound[GetRandomInt(0, sizeof(g_VincentFireIgniteSound) - 1)], entity_hit, SNDCHAN_AUTO);
			
			if (!hit)
			{
				hit = true;
				KillFeed_SetKillIcon(npc.index, "firedeath");
			}
			
			float Proj_Damage = 1.0 * RaidModeScaling;
			SDKHooks_TakeDamage(entity_hit, owner, owner, Proj_Damage, DMG_PLASMA, -1);
			NPC_Ignite(entity_hit, owner, 5.0, -1, Proj_Damage);
		}
	}
	
	return Plugin_Continue;
}

static Action Timer_Vincent_LaunchFireDownwards(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if (entity == INVALID_ENT_REFERENCE)
		return Plugin_Continue;
	
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if (owner == INVALID_ENT_REFERENCE)
		return Plugin_Continue;
	
	Vincent npc = view_as<Vincent>(owner);
	float vecPos[3], vecTargetPos[3];
	GetAbsOrigin(entity, vecPos);
	vecTargetPos = vecPos;
	vecTargetPos[2] -= 999.0;
	
	int newRocket = npc.FireParticleRocket(vecTargetPos, 0.0, 200.0, 0.0, "spell_fireball_small_trail_red", false, _, true, vecPos);
	RemoveEntity(entity);
	
	CreateTimer(0.25, Timer_RemoveEntity, EntIndexToEntRef(newRocket), TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Continue;
}

static bool TraceEntityEnumerator_Vincent_Oil(int entity)
{
	if (entity <= 0 || entity > MAXENTITIES)
		return true;
	
	if (entity > MaxClients && !b_ThisWasAnNpc[entity])
		return true;
	
	if (GetTeam(entity) == 0)
		return true;
	
	//This will automatically take care of all the checks, very handy. force it to also target invul enemies.
	for(int i=0; i < MAXENTITIES; i++)
	{
		if(!HitEntitiesSphereMlynar[i])
		{
			HitEntitiesSphereMlynar[i] = entity;
			break;
		}
	}
	return true;
}
		
//Vincent_SuperAttackBehindTarget(npc.index, targetTrace, damage, DMG_CLUB);

void Vincent_SuperAttackBehindTarget(int iNPC, int victim, float damage, int damagetype, float DamageRange, float BoxSize)
{
	float vAnglePunch[3];
	float vecForward[3];
	float vecPos[3], vecTargetPos[3];
	GetAbsOrigin(iNPC, vecPos);
	GetAbsOrigin(victim, vecTargetPos);
	vecPos[2] += 45.0;
	vecTargetPos[2] += 45.0;
	GetVectorAnglesTwoPoints(vecPos, vecTargetPos, vAnglePunch);
	GetAngleVectors(vAnglePunch, vecForward, NULL_VECTOR, NULL_VECTOR);


	float VectorTarget_2[3];
	float VectorForward = DamageRange;
	
	VectorTarget_2[0] = vecTargetPos[0] + vecForward[0] * VectorForward;
	VectorTarget_2[1] = vecTargetPos[1] + vecForward[1] * VectorForward;
	VectorTarget_2[2] = vecTargetPos[2] + vecForward[2] * VectorForward;

	int red = 255;
	int green = 255;
	int blue = 50;
	int Alpha = 222;
	int colorLayer4[4];
	int colorLayer1[4];
	Vincent npc = view_as<Vincent>(iNPC);
	npc.PlayVincentMeleeSuper();

	float diameter = BoxSize * 4.0;
	SetColorRGBA(colorLayer4, red, green, blue, Alpha);
	//we set colours of the differnet laser effects to give it more of an effect
	SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, Alpha);
	TE_SetupBeamPoints(vecTargetPos, VectorTarget_2, Shared_BEAM_Laser, 0, 0, 0, 0.2, ClampBeamWidth(diameter * 0.4), ClampBeamWidth(diameter * 0.6), 0, 5.0, colorLayer1, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(vecTargetPos, VectorTarget_2, Shared_BEAM_Laser, 0, 0, 0, 0.3, ClampBeamWidth(diameter * 0.2), ClampBeamWidth(diameter * 0.4), 0, 5.0, colorLayer4, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(vecTargetPos, VectorTarget_2, Shared_BEAM_Laser, 0, 0, 0, 0.5, ClampBeamWidth(diameter * 0.2), ClampBeamWidth(diameter * 0.4), 0, 5.0, colorLayer4, 3);
	TE_SendToAll(0.0);


	Zero(LaserVarious_HitDetection);

	float hullMin[3];
	float hullMax[3];
	hullMin[0] = -float(BOB_MELEE_SIZE);
	hullMin[1] = hullMin[0];
	hullMin[2] = hullMin[0];
	hullMax[0] = -hullMin[0];
	hullMax[1] = -hullMin[1];
	hullMax[2] = -hullMin[2];

	Handle trace;
	trace = TR_TraceHullFilterEx(vecTargetPos, VectorTarget_2, hullMin, hullMax, 1073741824, Sensal_BEAM_TraceUsers_2, iNPC);	// 1073741824 is CONTENTS_LADDER?
	delete trace;
	
	KillFeed_SetKillIcon(iNPC, npc.Anger ? "hale_megapunch_collateral" : "hale_punch_collateral");
	
	float playerPos[3];
	for (int victim1 = 1; victim1 < MAXENTITIES; victim1++)
	{
		if (victim != victim1 && LaserVarious_HitDetection[victim1] && GetTeam(iNPC) != GetTeam(victim1))
		{
			GetEntPropVector(victim1, Prop_Send, "m_vecOrigin", playerPos, 0);

			if(victim1 > MaxClients) //make sure barracks units arent bad
				damage *= 0.35;

			SDKHooks_TakeDamage(victim1, iNPC, iNPC, damage, damagetype, -1);
			

			Custom_Knockback(iNPC, victim1, 250.0, true);
		}
	}
}

#define VINCENT_PREPARESLAM_TIME 1.5
#define VINCENT_THROW_AOE_RANGE 200.0
bool Vincent_SlamThrow(int iNPC, int target)
{

	Vincent npc = view_as<Vincent>(iNPC);
	static float ThrowPos[3]; 
	if(npc.m_iChanged_WalkCycle == 4)
	{
		float damage = 15.0;
		damage *= RaidModeScaling;
		ResolvePlayerCollisions_Npc(npc.index, /*damage crush*/ damage, true);
	}
	if(npc.m_flThrow_Happening)
	{
		if(!IsValidEnemy(iNPC, npc.m_iTargetWalkTo))
		{
			npc.m_iTargetWalkTo = target;
			if(IsValidEntity(npc.m_iWearable4))
				RemoveEntity(npc.m_iWearable4);
			if(npc.m_iChanged_WalkCycle != 4)
				npc.m_iWearable4 = ConnectWithBeam(npc.index, npc.m_iTargetWalkTo, 255, 0, 0, 5.0, 1.0, 0.0, LASERBEAM, .attachment1 = "effect_hand_l");
			else
				npc.m_iWearable4 = ConnectWithBeam(npc.index, npc.m_iTargetWalkTo, 255, 0, 0, 5.0, 5.0, 0.0, LASERBEAM);
		}
		float vecPos[3], vecTargetPos[3];
		WorldSpaceCenter(iNPC, vecPos);
		WorldSpaceCenter(npc.m_iTargetWalkTo, vecTargetPos);
		float distance = GetVectorDistance(vecPos, vecTargetPos, true);
		
		if (distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.25))
		{
			//relatively close!
			if(Can_I_See_Enemy_Only(npc.index, npc.m_iTargetWalkTo))
			{
				//grabbed!
				if(npc.m_iChanged_WalkCycle == 4 && npc.m_iChanged_WalkCycle != 5)
				{
					ApplyStatusEffect(npc.index, npc.index, "Intangible", 999999.0);
					b_ThisEntityIgnoredBeingCarried[npc.index] = true; //cant be targeted AND wont do npc collsiions
					f_CheckIfStuckPlayerDelay[npc.index] = FAR_FUTURE, //She CANT stuck you, so dont make players not unstuck in cant bve stuck ? what ?

					npc.m_iChanged_WalkCycle = 5;
					npc.SetPoseParameter_Easy("body_pitch", 0.0);
					npc.RemoveGesture("ACT_MP_ATTACK_STAND_POSTFIRE");
					npc.SetActivity("ACT_MP_JUMP_FLOAT_MELEE");
					npc.AddGesture("ACT_MP_PASSTIME_THROW_MIDDLE");
					npc.m_flSpeed = 0.0;
					npc.StopPathing();
					static float flPos_1[3]; 
					GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos_1);
					flPos_1[2] += 400.0;
					npc.SetVelocity({0.0,0.0,0.0});
					PluginBot_Jump(npc.index, flPos_1);
					npc.PlayVincentJumpSound();

					npc.m_flThrow_Happening = GetGameTime(npc.index) + 1.5;
					npc.m_flDoingAnimation = GetGameTime(npc.index) + 1.5;
					i_GrabbedThis[npc.index] = EntIndexToEntRef(npc.m_iTargetWalkTo);
					GetEntPropVector(iNPC, Prop_Data, "m_vecAbsOrigin", ThrowPos); //emergency save pos
					return true;
				}
			}
		}
		if(npc.m_iChanged_WalkCycle == 5)
		{
			int closestTarget = GetClosestTarget(npc.index, .ingore_client = EntRefToEntIndex(i_GrabbedThis[npc.index]), .CanSee = true, .UseVectorDistance = true);
			if(IsValidEntity(closestTarget))
			{
				static float enemypos[3]; 
				GetEntPropVector(closestTarget, Prop_Data, "m_vecAbsOrigin", enemypos);

				enemypos[2] += 45.0;
				if(npc.m_flThrow_Happening > GetGameTime(npc.index) + 0.75)
				{
					ThrowPos = enemypos;
					npc.m_flLazyJumpFix = 1.0;
				}
				else
				{
					if(npc.m_flLazyJumpFix)
					{
						npc.SetVelocity({0.0,0.0,0.0});
						PluginBot_Jump(npc.index, ThrowPos);
						npc.m_flLazyJumpFix = 0.0;
					}
				}
				npc.FaceTowards(ThrowPos, 15000.0);
				static float selfpos[3]; 
				float flAng[3]; // original
			
				int r = 200;
				int g = 200;
				int b = 255;
				float diameter = 25.0;
				
				int colorLayer4[4];
				SetColorRGBA(colorLayer4, r, g, b, 200);
				int colorLayer2[4];
				SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, 200);

				npc.GetAttachment("effect_hand_r", selfpos, flAng);
				TE_SetupBeamPoints(selfpos, ThrowPos, g_Ruina_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.5 * 1.28), ClampBeamWidth(diameter * 0.5 * 1.28), 0, 1.0, colorLayer2, 3);
				TE_SendToAll(0.0);
				spawnRing_Vectors(ThrowPos, VINCENT_THROW_AOE_RANGE * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 220, 220, 50, 200, 1, /*duration*/ 0.15, 5.0, 0.0, 1);	
			}
		}
		if(npc.m_flThrow_Happening < GetGameTime(npc.index))
		{
			if(npc.m_iChanged_WalkCycle != 4 && npc.m_iChanged_WalkCycle != 5)
			{
				npc.m_iChanged_WalkCycle = 4;
				npc.SetActivity("ACT_MP_RUN_PRIMARY");
				int AnimLayer = npc.AddGesture("ACT_MP_ATTACK_STAND_POSTFIRE");
				npc.SetPoseParameter_Easy("body_pitch", -45.0);
				npc.SetLayerPlaybackRate(AnimLayer, (0.01));
				npc.SetLayerCycle(AnimLayer, (0.0));
				npc.m_flSpeed = 900.0;
				npc.StartPathing();
				if(IsValidEntity(npc.m_iWearable4))
					RemoveEntity(npc.m_iWearable4);

				npc.m_iWearable4 = ConnectWithBeam(npc.index, npc.m_iTargetWalkTo, 255, 0, 0, 5.0, 5.0, 0.0, LASERBEAM);

				npc.m_flThrow_Happening = GetGameTime(npc.index) + 2.5;
				npc.m_flDoingAnimation = GetGameTime(npc.index) + 2.5;
				return true;
			}
			if(npc.m_iChanged_WalkCycle == 5 && IsValidEntity(i_GrabbedThis[npc.index]))
			{ 
				static float hullcheckmaxs[3];
				static float hullcheckmins[3];
				hullcheckmaxs = view_as<float>( { 24.0, 24.0, 82.0 } );
				hullcheckmins = view_as<float>( { -24.0, -24.0, 0.0 } );
				int EntityGrabbed = EntRefToEntIndex(i_GrabbedThis[npc.index]);

				b_ThisEntityIsAProjectileForUpdateContraints[EntityGrabbed] = true;
				if(!IsValidClient(EntityGrabbed))
					Npc_Teleport_Safe(EntityGrabbed, ThrowPos, hullcheckmins, hullcheckmaxs);
				else
					Player_Teleport_Safe(EntityGrabbed, ThrowPos);

					//setting this so it goes through entities in the safe tele.
				b_ThisEntityIsAProjectileForUpdateContraints[EntityGrabbed] = false;


				static float selfpos[3]; 
				float flAng[3]; // original
				npc.GetAttachment("effect_hand_r", selfpos, flAng);

				int red = 255;
				int green = 255;
				int blue = 50;
				int Alpha = 222;
				int colorLayer4[4];
				int colorLayer1[4];
				npc.PlayVincentMeleeSuper();

				float diameter = 20.0;
				SetColorRGBA(colorLayer4, red, green, blue, Alpha);
				//we set colours of the differnet laser effects to give it more of an effect
				SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, Alpha);
				TE_SetupBeamPoints(selfpos, ThrowPos, Shared_BEAM_Laser, 0, 0, 0, 0.2, ClampBeamWidth(diameter * 0.4), ClampBeamWidth(diameter * 0.6), 0, 5.0, colorLayer1, 3);
				TE_SendToAll(0.0);
				TE_SetupBeamPoints(selfpos, ThrowPos, Shared_BEAM_Laser, 0, 0, 0, 0.3, ClampBeamWidth(diameter * 0.2), ClampBeamWidth(diameter * 0.4), 0, 5.0, colorLayer4, 3);
				TE_SendToAll(0.0);
				TE_SetupBeamPoints(selfpos, ThrowPos, Shared_BEAM_Laser, 0, 0, 0, 0.5, ClampBeamWidth(diameter * 0.2), ClampBeamWidth(diameter * 0.4), 0, 5.0, colorLayer4, 3);
				TE_SendToAll(0.0);
				
				KillFeed_SetKillIcon(npc.index, "pumpkindeath");
				
				float damage = 170.0;
				damage *= RaidModeScaling;
				Explode_Logic_Custom(damage, 0, npc.index, -1, ThrowPos,VINCENT_THROW_AOE_RANGE, 1.0, _, true, 20);
				TE_Particle("asplode_hoodoo", ThrowPos, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
				EmitSoundToAll(SOUND_WAND_LIGHTNING_ABILITY_PAP_SMITE, 0, SNDCHAN_AUTO, 100, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, ThrowPos);
				EmitSoundToAll(SOUND_WAND_LIGHTNING_ABILITY_PAP_SMITE, 0, SNDCHAN_AUTO, 100, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, ThrowPos);
				npc.SetVelocity({0.0,0.0,-1000.0});
				npc.PlayVincentSlamSound();
				i_GrabbedThis[npc.index] = -1;
			}
			if(IsValidEntity(npc.m_iWearable4))
				RemoveEntity(npc.m_iWearable4);
			//end ability?
			npc.m_flThrow_Happening = 0.0;
			npc.m_flDoingAnimation = GetGameTime(npc.index) + 0.3;
			npc.m_flRegainNormalWalk = GetGameTime(npc.index) + 0.3;
			npc.m_iTargetWalkTo = 0;
		}
		return true;
	}
	if(npc.m_flThrow_Cooldown > GetGameTime(npc.index))
		return false;
		
	if(npc.m_iChanged_WalkCycle != 2)
	{
		npc.m_iTargetWalkTo = target;
		npc.m_iChanged_WalkCycle = 2;
		npc.m_bisWalking = false;
		npc.StopPathing();
		npc.PlayPrepareSlamSound();
		npc.AddActivityViaSequence("layer_taunt_commending_clap_heavy");
		npc.m_flSpeed = 0.0;
		float Timeslam = VINCENT_PREPARESLAM_TIME;
		npc.SetCycle(0.75);
		if(!npc.Anger)
		{
			npc.SetPlaybackRate(0.4);
			npc.m_flThrow_Cooldown = GetGameTime(npc.index) + 40.0;
		}
		else
		{
			npc.SetPlaybackRate(0.4 * (1.0 / 0.75));
			Timeslam *= 0.75;
			npc.m_flThrow_Cooldown = GetGameTime(npc.index) + 35.0;
		}
		if(!Aperture_IsBossDead(APERTURE_BOSS_CAT) && !Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			switch(GetRandomInt(0,2))
			{
				case 0:
					CPrintToChatAll("{rare}%t{default}: I'm gonna get you.", c_NpcName[npc.index]);
				case 1:
					CPrintToChatAll("{rare}%t{default}: Here I come!", c_NpcName[npc.index]);
				case 2:
					CPrintToChatAll("{rare}%t{default}: You better run!", c_NpcName[npc.index]);
			}
		}
		if(IsValidEntity(npc.m_iWearable4))
			RemoveEntity(npc.m_iWearable4);
			
		npc.m_iWearable4 = ConnectWithBeam(npc.index, target, 255, 0, 0, 5.0, 1.0, 0.0, LASERBEAM, .attachment1 = "effect_hand_l");
		npc.m_flThrow_Happening = GetGameTime(npc.index) + Timeslam;
		npc.m_flDoingAnimation = GetGameTime(npc.index) + Timeslam;
		static float radius = 200.0;
		float vecPos[3];
		GetAbsOrigin(npc.index, vecPos);
		spawnRing_Vectors(vecPos, radius, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 200, 200, 50, 255, 3, Timeslam, 10.0, 2.0, 1, 0.0);
		spawnRing_Vectors(vecPos, radius, 0.0, 0.0, 40.0, "materials/sprites/laserbeam.vmt", 200, 200, 50, 255, 3, Timeslam, 10.0, 2.0, 1, 0.0);
	}	
	return false;
}




void Vincent_AdjustGrabbedTarget(int iNPC)
{
	Vincent npc = view_as<Vincent>(iNPC);
	if(!IsValidEntity(i_GrabbedThis[npc.index]))
		return;
	int EnemyGrab = EntRefToEntIndex(i_GrabbedThis[npc.index]);
	float flPos[3]; // original
	float flAng[3]; // original#
	

	npc.GetAttachment("effect_hand_r", flPos, flAng);

	flPos[2] -= 30.0;
	
	TeleportEntity(EnemyGrab, flPos, NULL_VECTOR, {0.0,0.0,0.0});
}

#define VINCENT_MINIMUM_RANGE_BEACONS 600.0
#define VINCENT_MAXTRIES 100
void VincentSpawnBeacons(int iNPC)
{
	Vincent npc = view_as<Vincent>(iNPC);
	int a, entity;
	//slay previous bacons
	while((entity = FindEntityByNPC(a)) != -1)
	{
		if(IsValidEntity(entity) && i_NpcInternalId[entity] == VincentBeaconID())
		{
			b_DissapearOnDeath[entity] = true;
			b_DoGibThisNpc[entity] = true;
			SmiteNpcToDeath(entity);
		}
	}
	int MaxBeacons = 0;
	float distancelimit = VINCENT_MINIMUM_RANGE_BEACONS;
	if(npc.Anger)
	{
		distancelimit *= 0.75;
	}
	float pos[3];
	float ang[3];
	GetEntPropVector(iNPC, Prop_Data, "m_vecAbsOrigin", pos);
	int HadCapTry = 2000;
	int NpcSpawn = 0;
	for(int counter = 1; counter <= HadCapTry; counter++)
	{
		if(MaxBeacons >= VINCENT_MAXTRIES)
		{
			if(NpcSpawn != 0)
				SmiteNpcToDeath(NpcSpawn);
			break;
		}
		if(counter >= HadCapTry)
		{
			if(NpcSpawn != 0)
				SmiteNpcToDeath(NpcSpawn);
			break;
		}
		
		float VectorSave[3];
		VectorSave[1] = 1.0;
		if(NpcSpawn == 0)
			NpcSpawn = NPC_CreateByName("npc_vincent_beacon", -1, pos, ang, GetTeam(iNPC));
		TeleportDiversioToRandLocation(NpcSpawn, true, 10000.0, 1.0,_,_,VectorSave);
		//lazy code but i dont wanna.
		int gottenTarget = Vincent_GetClosestBeacon(NpcSpawn, VectorSave, distancelimit * distancelimit);
		if(IsValidEntity(gottenTarget))
		{
			continue;
		}
		TeleportEntity(NpcSpawn, VectorSave);
		MaxBeacons++;
		Vincent npcBeacon = view_as<Vincent>(NpcSpawn);
		npcBeacon.Anger = npc.Anger;
		npcBeacon.m_iWearable1 = npcBeacon.EquipItemSeperate("models/buildables/sentry_shield.mdl",_,1,_,-65.0, true);
		SetVariantString("2.0");
		AcceptEntityInput(npcBeacon.m_iWearable1, "SetModelScale");
		NpcSpawn = 0;
	}
}


stock int Vincent_GetClosestBeacon(int entity, float EntityLocation[3], float limitsquared = 99999999.9)
{
	float TargetDistance = 0.0; 
	int ClosestTarget = 0; 
	int a, entityloop;
	//slay previous bacons
	while((entityloop = FindEntityByNPC(a)) != -1)
	{
		if(IsValidEntity(entityloop) && i_NpcInternalId[entityloop] == VincentBeaconID())
		{
			if(entityloop != entity && GetTeam(entity) == GetTeam(entityloop) && IsEntityAlive(entityloop, true))
			{
				float TargetLocation[3]; 
				GetEntPropVector( entityloop, Prop_Data, "m_vecAbsOrigin", TargetLocation ); 
				
				float distance = GetVectorDistance( EntityLocation, TargetLocation, true ); 
				if( distance < limitsquared )
				{
					if( TargetDistance ) 
					{
						if( distance < TargetDistance ) 
						{
							ClosestTarget = entityloop; 
							TargetDistance = distance;		  
						}
					} 
					else 
					{
						ClosestTarget = entityloop; 
						TargetDistance = distance;
					}			
				}
			}
		}
	}
	return ClosestTarget; 
}


void Vincent_SpawnFog(int iNPC)
{
	Vincent npc = view_as<Vincent>(iNPC);
	if(FogEntity != INVALID_ENT_REFERENCE)
	{
		int entity = EntRefToEntIndex(FogEntity);
		if(entity > MaxClients)
			RemoveEntity(entity);
		
		FogEntity = INVALID_ENT_REFERENCE;
	}
	
	int entity = CreateEntityByName("env_fog_controller");
	if(entity != -1)
	{
		DispatchKeyValue(entity, "fogblend", "2");
		if(npc.Anger)
		{
			DispatchKeyValue(entity, "fogcolor", "255 100 100 50");
			DispatchKeyValue(entity, "fogcolor2", "255 100 100 50");
			DispatchKeyValueFloat(entity, "fogmaxdensity", 0.5);
		}
		else
		{
			DispatchKeyValue(entity, "fogcolor", "75 75 255 25");
			DispatchKeyValue(entity, "fogcolor2", "75 75 255 25");
			DispatchKeyValueFloat(entity, "fogmaxdensity", 0.35);
		}
		DispatchKeyValueFloat(entity, "fogstart", 400.0);
		DispatchKeyValueFloat(entity, "fogend", 1000.0);

		DispatchKeyValue(entity, "targetname", "rpg_fortress_envfog");
		DispatchKeyValue(entity, "fogenable", "1");
		DispatchKeyValue(entity, "spawnflags", "1");
		DispatchSpawn(entity);
		AcceptEntityInput(entity, "TurnOn");

		FogEntity = EntIndexToEntRef(entity);

		for(int client1 = 1; client1 <= MaxClients; client1++)
		{
			if(IsClientInGame(client1))
			{
				SetVariantString("rpg_fortress_envfog");
				AcceptEntityInput(client1, "SetFogController");
			}
		}
	}
}

static void Vincent_PourOilAbility(Vincent npc, float duration, float delayToIgnite)
{
	// This does the ability that spawns many puddles
	npc.m_bDoingOilPouring = true;
	npc.m_flNextOilPouring = GetGameTime(npc.index) + delayToIgnite + 0.5;
	
	float vecPos[3], vecTargetPos[3], vecAng[3], vecForward[3], vecUseless[3];
	GetAbsOrigin(npc.index, vecPos);
	
	float radius = VINCENT_OIL_MODEL_DEFAULT_RADIUS * VINCENT_OIL_MODEL_SCALE * 1.5;
	
	Vincent_PourOil(npc, vecPos, radius, duration, delayToIgnite, true);
	
	vecPos[2] += 80.0;
	
	ParticleEffectAt(vecPos, "gas_can_impact_blue");
	
	int rocketL = npc.FireParticleRocket(vecUseless, 0.0, 0.0, 0.0, "spell_fireball_small_trail_red", false, _, true, vecUseless);
	int rocketR = npc.FireParticleRocket(vecUseless, 0.0, 0.0, 0.0, "spell_fireball_small_trail_red", false, _, true, vecUseless);
	
	SetParent(npc.index, rocketL, "effect_hand_L");
	SetParent(npc.index, rocketR, "effect_hand_R");
	
	SetEntityCollisionGroup(rocketL, COLLISION_GROUP_DEBRIS);
	SetEntityCollisionGroup(rocketR, COLLISION_GROUP_DEBRIS);
	
	float delay = 1.75;
	if (npc.m_flMegaEnrage)
		delay *= 0.5;
	
	CreateTimer(delay, Timer_Vincent_LaunchFireDownwards, EntIndexToEntRef(rocketL), TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(delay, Timer_Vincent_LaunchFireDownwards, EntIndexToEntRef(rocketR), TIMER_FLAG_NO_MAPCHANGE);
	
	for (int i = 0; i < 8; i++)
	{
		vecAng[1] = i * (360.0 / 8.0);
		GetAngleVectors(vecAng, vecForward, NULL_VECTOR, NULL_VECTOR);
		NormalizeVector(vecForward, vecForward);
		ScaleVector(vecForward, VINCENT_OIL_MODEL_DEFAULT_RADIUS * VINCENT_OIL_MODEL_SCALE);
		AddVectors(vecPos, vecForward, vecTargetPos);
		
		Handle trace = TR_TraceRayFilterEx(vecPos, vecTargetPos, MASK_SOLID, RayType_EndPoint, TraceEntityFilter_Vincent_OnlyWorld);
		if (!TR_DidHit(trace))
		{
			Handle trace2 = TR_TraceRayFilterEx(vecTargetPos, view_as<float>({90.0, 0.0, 0.0}), MASK_SOLID, RayType_Infinite, TraceEntityFilter_Vincent_OnlyWorld);
			TR_GetEndPosition(vecTargetPos, trace);
			delete trace2;
		}
		
		delete trace;
		
		vecTargetPos[2] -= 16.0;
		Vincent_PourOil(npc, vecTargetPos, radius, duration, delayToIgnite, true);
	}
}

static void Vincent_PourOil(Vincent npc, float vecPos[3], float radius, float duration, float delayToIgnite, bool fromAbility)
{
	// This spawns each individual oil puddle
	int prop = CreateEntityByName("prop_dynamic_override");
	if (!IsValidEntity(prop))
		return;
	
	Handle trace = TR_TraceRayFilterEx(vecPos, view_as<float>({90.0, 0.0, 0.0}), MASK_SOLID, RayType_Infinite, TraceEntityFilter_Vincent_OnlyWorld);
	TR_GetEndPosition(vecPos, trace);
	delete trace;
	
	TeleportEntity(prop, vecPos, NULL_VECTOR, NULL_VECTOR);
	DispatchKeyValue(prop, "model", g_OilModel);
	DispatchKeyValue(prop, "disablereceiveshadows", "1");
	DispatchKeyValue(prop, "disableshadows", "1");
	DispatchSpawn(prop);
	
	SetEntPropEnt(prop, Prop_Send, "m_hOwnerEntity", npc.index);
	SetTeam(prop, GetTeam(npc.index));
	SetEntPropFloat(prop, Prop_Send, "m_flModelScale", VINCENT_OIL_MODEL_SCALE);
	
	SetEntityCollisionGroup(prop, COLLISION_GROUP_DEBRIS);
	
	if (delayToIgnite <= 0.1)
		SetEntityRenderMode(prop, RENDER_NONE);
	else
		SetEntityRenderColor(prop, 0, 40, 0, 255);
	
	DataPack pack;
	CreateDataTimer(delayToIgnite, Timer_Vincent_IgniteOil, pack, TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(EntIndexToEntRef(prop));
	pack.WriteCell(EntIndexToEntRef(npc.index));
	pack.WriteFloat(radius);
	pack.WriteCell(fromAbility);
	
	CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(prop), TIMER_FLAG_NO_MAPCHANGE);
}

static void Timer_Vincent_FadeBackIn(Handle timer)
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client) && !IsFakeClient(client))
		{
			UTIL_ScreenFade(client, 333, 1, FFADE_IN | FFADE_PURGE, 255, 255, 255, 255); //make the fade target everyone
		}
	}
}