#pragma semicolon 1
#pragma newdecls required


static const char g_DeathSounds[][] = {
	"weapons/rescue_ranger_teleport_receive_01.wav",
	"weapons/rescue_ranger_teleport_receive_02.wav",
};

static char g_HurtSounds[][] = {
	")vo/medic_painsharp01.mp3",
	")vo/medic_painsharp02.mp3",
	")vo/medic_painsharp03.mp3",
	")vo/medic_painsharp04.mp3",
	")vo/medic_painsharp05.mp3",
	")vo/medic_painsharp06.mp3",
	")vo/medic_painsharp07.mp3",
	")vo/medic_painsharp08.mp3",
};

static char g_IdleSounds[][] = {
	")vo/null.mp3",
};

static char g_IdleAlertedSounds[][] = {
	")vo/medic_battlecry01.mp3",
	")vo/medic_battlecry02.mp3",
	")vo/medic_battlecry03.mp3",
	")vo/medic_battlecry04.mp3",
};

static char g_MeleeHitSounds[][] = {
	"weapons/breadmonster/throwable/bm_throwable_smash.wav",
};

static char g_MeleeAttackSounds[][] = {
	")weapons/knife_swing.wav",
};

static char g_RangedAttackSounds[][] = {
	"weapons/breadmonster/throwable/bm_throwable_throw.wav",
};
static char g_TeleportSounds[][] = {
	"misc/halloween/spell_teleport.wav",
};

static char g_MeleeMissSounds[][] = {
	")weapons/cbar_miss1.wav",
};

static char g_AngerSounds[][] = {
	")vo/medic_hat_taunts04.mp3",
};

static char g_PullSounds[][] = {
	"weapons/physcannon/energy_sing_explosion2.wav"
};

static int gExplosive1;

public void TrueFusionWarrior_OnMapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Infected Silvester");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_true_fusion_warrior");
	strcopy(data.Icon, sizeof(data.Icon), "fusion_warrior");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Raid;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);

	
}

static void ClotPrecache()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));       i++) { PrecacheSound(g_DeathSounds[i]);       }
	for (int i = 0; i < (sizeof(g_HurtSounds));        i++) { PrecacheSound(g_HurtSounds[i]);        }
	for (int i = 0; i < (sizeof(g_IdleSounds));        i++) { PrecacheSound(g_IdleSounds[i]);        }
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));    i++) { PrecacheSound(g_MeleeHitSounds[i]);    }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));    i++) { PrecacheSound(g_MeleeAttackSounds[i]);    }
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_TeleportSounds));   i++) { PrecacheSound(g_TeleportSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++) { PrecacheSound(g_RangedAttackSounds[i]);   }
	for (int i = 0; i < (sizeof(g_AngerSounds));   i++) { PrecacheSound(g_AngerSounds[i]);   }
	for (int i = 0; i < (sizeof(g_PullSounds));   i++) { PrecacheSound(g_PullSounds[i]);   }
	
	PrecacheSound("weapons/physcannon/energy_sing_loop4.wav", true);
	PrecacheSound("weapons/physcannon/physcannon_drop.wav", true);

	PrecacheSoundArray(g_DefaultLaserLaunchSound);
	gExplosive1 = PrecacheModel("materials/sprites/sprite_fire01.vmt");
	
	PrecacheSound("player/flow.wav");

	PrecacheSoundCustom("#zombiesurvival/fusion_raid/infected_silvester_ostr.mp3");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return TrueFusionWarrior(vecPos, vecAng, team, data);
}

methodmap TrueFusionWarrior < CClotBody
{
	property int m_iAmountProjectiles
	{
		public get()							{ return i_AmountProjectiles[this.index]; }
		public set(int TempValueForProperty) 	{ i_AmountProjectiles[this.index] = TempValueForProperty; }
	}
	property float m_flTimebeforekamehameha
	{
		public get()							{ return fl_BEAM_RechargeTime[this.index]; }
		public set(float TempValueForProperty) 	{ fl_BEAM_RechargeTime[this.index] = TempValueForProperty; }
	}
	property bool m_bInKame
	{
		public get()							{ return b_InKame[this.index]; }
		public set(bool TempValueForProperty) 	{ b_InKame[this.index] = TempValueForProperty; }
	}
	property float m_flNextPull
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flTimeSinceHasBeenHurt
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}

	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;

		int sound = GetRandomInt(0, sizeof(g_IdleSounds) - 1);
		
		EmitSoundToAll(g_IdleSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		
	
	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
			
		int sound = GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1);
		
		EmitSoundToAll(g_IdleAlertedSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);

	}
	
	public void PlayHurtSound() {
		
		int sound = GetRandomInt(0, sizeof(g_HurtSounds) - 1);

		EmitSoundToAll(g_HurtSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextHurtSound = GetGameTime(this.index) + GetRandomFloat(0.6, 1.6);
		
	}
	
	public void PlayDeathSound() {
		
		int sound = GetRandomInt(0, sizeof(g_DeathSounds) - 1);
		
		EmitSoundToAll(g_DeathSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		
	}
	
	public void PlayAngerSound() {
	
		int sound = GetRandomInt(0, sizeof(g_AngerSounds) - 1);
		EmitSoundToAll(g_AngerSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
	}
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		

	}
	
	public void PlayPullSound() {
		EmitSoundToAll(g_PullSounds[GetRandomInt(0, sizeof(g_PullSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
	}
	
	
	public void PlayTeleportSound() {
		EmitSoundToAll(g_TeleportSounds[GetRandomInt(0, sizeof(g_TeleportSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		

	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		
	}
	public void PlayLaserLaunchSound() {
		int chose = GetRandomInt(0, sizeof(g_DefaultLaserLaunchSound)-1);
		EmitSoundToAll(g_DefaultLaserLaunchSound[chose], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_DefaultLaserLaunchSound[chose], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public TrueFusionWarrior(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		TrueFusionWarrior npc = view_as<TrueFusionWarrior>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.35", "25000", ally, false, true, true,true)); //giant!
		
		i_NpcWeight[npc.index] = 4;
		func_NPCFuncWin[npc.index] = view_as<Function>(Raidmode_Fusion_Warrior_Win);
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = false;
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "item_armor", 1, "%t", "Silvester? Spawn");
			}
		}
		
		i_RaidGrantExtra[npc.index] = 1;
		if(StrContains(data, "wave_10") != -1)
		{
			i_RaidGrantExtra[npc.index] = 2;
		}
		else if(StrContains(data, "wave_20") != -1)
		{
			i_RaidGrantExtra[npc.index] = 3;
		}
		else if(StrContains(data, "wave_30") != -1)
		{
			i_RaidGrantExtra[npc.index] = 4;
		}
		else if(StrContains(data, "wave_40") != -1)
		{
			i_RaidGrantExtra[npc.index] = 5;
		}

		bool final = StrContains(data, "final_item") != -1;
		if(final)
		{
			i_RaidGrantExtra[npc.index] = 6;
			b_NpcUnableToDie[npc.index] = true;
		}
		
		b_thisNpcIsARaid[npc.index] = true;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPSOUND_NORMAL;		
		
		npc.m_bThisNpcIsABoss = true;
		
		RaidModeTime = GetGameTime(npc.index) + 200.0;
		
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
		
		/*
			wave 15 is 15 power here.
			we need to make sure that with
			CurrentCash
			Its the same balance roughly.
			first is 4100 that should go to power 15, 273.0
			17800 is wave 30, In theroy it should go down by 593.0 times.
			42550 wave 45, 945 times.
			92800 wave 60, 1.546 times.
			//it is roughly always double.
		*/
		if(RaidModeScaling < 35)
		{
			RaidModeScaling *= 0.25; //abit low, inreacing
		}
		else
		{
			RaidModeScaling *= 0.5;
		}
		RemoveAllDamageAddition();
		
		float amount_of_people = ZRStocks_PlayerScalingDynamic();
		
		if(amount_of_people > 12.0)
		{
			amount_of_people = 12.0;
		}
		
		amount_of_people *= 0.12;
		
		if(amount_of_people < 1.0)
			amount_of_people = 1.0;
			
		RaidModeScaling *= amount_of_people; //More then 9 and he raidboss gets some troubles, bufffffffff
		
		func_NPCDeath[npc.index] = TrueFusionWarrior_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = TrueFusionWarrior_OnTakeDamage;
		func_NPCThink[npc.index] = TrueFusionWarrior_ClotThink;
		
		
		
		for(int client_clear=1; client_clear<=MaxClients; client_clear++)
		{
			fl_AlreadyStrippedMusic[client_clear] = 0.0; //reset to 0
		}
		
		int skin = 5;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/player/items/medic/medic_zombie.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/medic/hwn_medic_hat.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/medic/sbxo2014_medic_wintergarb_coat/sbxo2014_medic_wintergarb_coat.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable5 = npc.EquipItem("head","models/workshop/player/items/medic/sf14_medic_kriegsmaschine_9000/sf14_medic_kriegsmaschine_9000.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", 1);
		
		float flPos[3]; // original
		float flAng[3]; // original
	
	
		npc.GetAttachment("head", flPos, flAng);
		
		npc.m_iWearable6 = ParticleEffectAt_Parent(flPos, "unusual_symbols_parent_lightning", npc.index, "head", {0.0,0.0,0.0});
		
		
		SetEntityRenderColor(npc.m_iWearable1, 192, 192, 192, 255);
		SetEntityRenderColor(npc.m_iWearable2, 192, 192, 192, 255);
		SetEntityRenderColor(npc.m_iWearable4, 192, 192, 192, 255);
		SetEntityRenderColor(npc.m_iWearable5, 150, 150, 150, 255);
		npc.m_bDissapearOnDeath = true;
		
		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
		npc.m_bTeamGlowDefault = false;
			
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		SetVariantColor(view_as<int>({255, 255, 255, 200}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");

		MusicEnum music;
		strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/fusion_raid/infected_silvester_ostr.mp3");
		music.Time = 167;
		music.Volume = 1.6;
		music.Custom = true;
		strcopy(music.Name, sizeof(music.Name), "Investigation Goes Awry");
		strcopy(music.Artist, sizeof(music.Artist), "Grandpa Bard");
		Music_SetRaidMusic(music);
		
		npc.Anger = false;
		b_angered_twice[npc.index] = false;
		npc.m_flTimeSinceHasBeenHurt = 0.0;
		//IDLE
		npc.m_flSpeed = 330.0;
		
		npc.m_flTimebeforekamehameha = GetGameTime(npc.index) + 10.0;
		npc.m_flNextPull = GetGameTime(npc.index) + 5.0;
		npc.m_bInKame = false;
		
		Citizen_MiniBossSpawn();
		npc.m_iWearable7 = npc.EquipItem("head", WEAPON_CUSTOM_WEAPONRY_1);
		SetEntityRenderColor(npc.m_iWearable7, 255, 255, 255, 2);
		SetVariantInt(2048);
		AcceptEntityInput(npc.m_iWearable7, "SetBodyGroup");	
		
		SilvesterEarsApply(npc.index);
	//	FusionApplyEffects(npc.index, 0);
		return npc;
	}
}


public void TrueFusionWarrior_ClotThink(int iNPC)
{
	TrueFusionWarrior npc = view_as<TrueFusionWarrior>(iNPC);
	
	if(LastMann)
	{
		if(!npc.m_fbGunout)
		{
			npc.m_fbGunout = true;
			switch(GetRandomInt(0,2))
			{
				case 0:
				{
					CPrintToChatAll("{gold}Silvester?{default}: Run... Away...");
				}
				case 1:
				{
					CPrintToChatAll("{gold}Silvester?{default}: Help...");
				}
				case 3:
				{
					CPrintToChatAll("{gold}Silvester?{crimson}: AGHHRRR!!!");
				}
			}
		}
	}
	if(i_RaidGrantExtra[npc.index] == RAIDITEM_INDEX_WIN_COND)
	{
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		
		CPrintToChatAll("{gold}Silvester?{default}: New... victims to infect...");
		return;
	}
	if(RaidModeTime < GetGameTime())
	{
		ForcePlayerLoss();
		RaidBossActive = INVALID_ENT_REFERENCE;
		CPrintToChatAll("{gold}Silvester?{default}: {green}Xeno{default} virus too strong... to resist.. {crimson}join...{default}");
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		return;
	}

	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();

	
	if(b_angered_twice[npc.index])
	{
		npc.m_flNextThinkTime = 0.0;
		int enemyGet = GetClosestAllyPlayer(npc.index);
		if(IsValidEntity(enemyGet))
		{
			float WorldSpaceVec[3]; WorldSpaceCenter(enemyGet, WorldSpaceVec);
			npc.FaceTowards(WorldSpaceVec, 100.0);
		}
			
		npc.StopPathing();
		
		npc.SetActivity("ACT_MP_STAND_LOSERSTATE");
		npc.m_bInKame = false;
		npc.m_bisWalking = false;
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client))
			{
				if(fl_AlreadyStrippedMusic[client] < GetEngineTime())
				{
					Music_Stop_All(client); //This is actually more expensive then i thought.
				}
				SetMusicTimer(client, GetTime() + 6);
				fl_AlreadyStrippedMusic[client] = GetEngineTime() + 5.0;
			}
		}
		if(GetGameTime() > npc.m_flTimeSinceHasBeenHurt)
		{
			CPrintToChatAll("{gold}Silvester{default}: You will get soon in touch with a friend of mine, I thank you, though beware of the rogue machine... {red}Blitzkrieg.");
			npc.m_bDissapearOnDeath = true;
			RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
			for (int client = 1; client <= MaxClients; client++)
			{
				if(IsValidClient(client) && GetClientTeam(client) == 2 && TeutonType[client] != TEUTON_WAITING && PlayerPoints[client] > 500)
				{
					Items_GiveNamedItem(client, "Cured Silvester");
					CPrintToChat(client,"{default}You gained his favor, you obtained: {yellow}''Cured Silvester''{default}!");
				}
			}
		}
		else if(GetGameTime() + 5.0 > npc.m_flTimeSinceHasBeenHurt && i_SaidLineAlready[npc.index] < 4)
		{
			i_SaidLineAlready[npc.index] = 4;
			CPrintToChatAll("{gold}Silvester{default}: Help the world, retain the chaos!");
		}
		else if(GetGameTime() + 10.0 > npc.m_flTimeSinceHasBeenHurt && i_SaidLineAlready[npc.index] < 3)
		{
			i_SaidLineAlready[npc.index] = 3;
			CPrintToChatAll("{gold}Silvester{default}: I thank you, but i will need help from you later, and I will warn you of dangers.");
		}
		else if(GetGameTime() + 13.0 > npc.m_flTimeSinceHasBeenHurt && i_SaidLineAlready[npc.index] < 2)
		{
			i_SaidLineAlready[npc.index] = 2;
			CPrintToChatAll("{gold}Silvester{default}: A huge chaos is breaking out, you were able to knock some sense into me..!");
		}
		else if(GetGameTime() + 16.5 > npc.m_flTimeSinceHasBeenHurt && i_SaidLineAlready[npc.index] < 1)
		{
			i_SaidLineAlready[npc.index] = 1;
			CPrintToChatAll("{gold}Silvester{default}: Listen to me, please!");
		}
		return; //He is trying to help.
	}
	
	//Think throttling
	if(npc.m_flNextThinkTime > GetGameTime(npc.index)) {
		return;
	}
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}
	
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.10;

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		if(npc.m_bInKame)
		{
			npc.m_iTarget = GetClosestTarget(npc.index,_,_,_,_,_,_,true);
			if(npc.m_iTarget < 1)
			{
				npc.m_iTarget = GetClosestTarget(npc.index);
			}
		}
		else
		{
			npc.m_iTarget = GetClosestTarget(npc.index);
		}
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	int closest = npc.m_iTarget;
	
	if(npc.m_bInKame)
	{
		if(b_angered_twice[npc.index])
		{
			npc.m_flRangedArmor = 1.0;
			npc.m_flMeleeArmor = 1.25;
		}
		else if(npc.Anger)
		{
			npc.m_flRangedArmor = 0.6;
			npc.m_flMeleeArmor = 0.75;
		}	
		else
		{
			npc.m_flRangedArmor = 0.7;
			npc.m_flMeleeArmor = 0.875;			
		}
	}
	else
	{
		if(b_angered_twice[npc.index])
		{
			npc.m_flRangedArmor = 1.0;
			npc.m_flMeleeArmor = 1.25;
		}
		else if(npc.Anger)
		{
			npc.m_flRangedArmor = 0.85;
			npc.m_flMeleeArmor = 1.0625;
		}	
		else
		{
			npc.m_flRangedArmor = 1.0;
			npc.m_flMeleeArmor = 1.25;			
		}	
	}
	
	if(IsValidEnemy(npc.index, closest, true))
	{
			float vecTarget[3]; WorldSpaceCenter(closest, vecTarget);
		
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			
			float vPredictedPos[3]; PredictSubjectPosition(npc, closest,_,_, vPredictedPos);
		
			//Body pitch
	//		if(flDistanceToTarget < Pow(110.0,2.0))
			{
				int iPitch = npc.LookupPoseParameter("body_pitch");
				if(iPitch < 0)
					return;		
			
				//Body pitch
				float v[3], ang[3];
				float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
				float WorldSpaceVec2[3]; WorldSpaceCenter(closest, WorldSpaceVec2);
				SubtractVectors(WorldSpaceVec, WorldSpaceVec2, v); 
				NormalizeVector(v, v);
				GetVectorAngles(v, ang); 
				
				float flPitch = npc.GetPoseParameter(iPitch);
				
			//	ang[0] = clamp(ang[0], -44.0, 89.0);
				npc.SetPoseParameter(iPitch, ApproachAngle(ang[0], flPitch, 10.0));
			}
			if(flDistanceToTarget < npc.GetLeadRadius()) {
				
			/*	int color[4];
				color[0] = 255;
				color[1] = 255;
				color[2] = 0;
				color[3] = 255;
			
				int xd = PrecacheModel("materials/sprites/laserbeam.vmt");
			
				TE_SetupBeamPoints(vPredictedPos, vecTarget, xd, xd, 0, 0, 0.25, 0.5, 0.5, 5, 5.0, color, 30);
				TE_SendToAllInRange(vecTarget, RangeType_Visibility);*/
				
				npc.SetGoalVector(vPredictedPos);
			} else {
				npc.SetGoalEntity(closest);
			}
			
			
			if(i_RaidGrantExtra[npc.index] >= 3)
			{
				if(npc.m_flTimebeforekamehameha < GetGameTime(npc.index))
				{
					npc.m_flTimebeforekamehameha = GetGameTime(npc.index) + (npc.Anger ? 35.0 : 35.0);
					npc.m_bInKame = true;
					Invoke_TrueFusionWarrior_Kameha(npc);
				}
			}
			if(npc.m_bInKame)
			{
				npc.FaceTowards(vecTarget, 650.0);
				npc.StopPathing();
				
				npc.m_flSpeed = 0.0;
			}
			else
			{
				if (!npc.Anger)
				{
					npc.m_flSpeed = 330.0;
				}
				else
				{
					npc.m_flSpeed = 350.0;
				}
			}
			
			if (npc.m_flNextRangedAttack < GetGameTime(npc.index) && flDistanceToTarget < (500.0 * 500.0) || (npc.m_bInKame && npc.m_flNextRangedAttack < GetGameTime(npc.index)))
			{
				if (!npc.Anger)
				{
					npc.FaceTowards(vecTarget, 500.0);
					npc.FireRocket(vPredictedPos, 8.0 * RaidModeScaling, 800.0, "models/effects/combineball.mdl", 1.0);	
					npc.m_flNextRangedAttack = GetGameTime(npc.index) + 4.0;
					npc.PlayRangedSound();
					npc.AddGesture("ACT_MP_THROW");
				}
				else if (npc.Anger)
				{
					npc.FaceTowards(vecTarget, 500.0);
					npc.FireRocket(vPredictedPos, 8.0 * RaidModeScaling, 800.0, "models/effects/combineball.mdl", 1.0);	
					npc.m_flNextRangedAttack = GetGameTime(npc.index) + 3.0;
					npc.PlayRangedSound();
					npc.AddGesture("ACT_MP_THROW");
				}
			}
			if(!NpcStats_IsEnemySilenced(npc.index))
			{
				if(npc.m_flNextPull < GetGameTime(npc.index) && !npc.m_bInKame)
				{
					if (!npc.Anger)
					{
						npc.FaceTowards(vecTarget);
						
						for(int client = 1; client <= MaxClients; client++)
						{
							if (IsClientInGame(client) && IsPlayerAlive(client) && dieingstate[client] == 0 && TeutonType[client] == 0 && GetTeam(client) == TFTeam_Red)
							{
								float vAngles[3], vDirection[3];
								
								float entity_angles[3];
										
								GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", vAngles); 
								
								GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", entity_angles); 
								
								float Distance = GetVectorDistance(vAngles, entity_angles);
								if(Distance < 1250)
								{				
									if(vAngles[0] > -45.0)
									{
										vAngles[0] = -45.0;
									}
														
									TF2_AddCondition(client, TFCond_LostFooting, 0.5);
									TF2_AddCondition(client, TFCond_AirCurrent, 0.5);
									f_ImmuneToFalldamage[client] = GetGameTime() + 5.0;
															
									GetAngleVectors(vAngles, vDirection, NULL_VECTOR, NULL_VECTOR);
														
									ScaleVector(vDirection, -1250.0);
									
									if(vDirection[2] > 0.0)
									{
										vDirection[2] *= -1.0;
									}
																			
									TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vDirection);
								}
							}
						}
						
						
						npc.DispatchParticleEffect(npc.index, "hammer_bell_ring_shockwave2", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("effect_hand_r"), PATTACH_POINT_FOLLOW, true);
						
						
						npc.m_flNextPull = GetGameTime(npc.index) + 15.0;
						npc.PlayPullSound();
						npc.AddGesture("ACT_MP_GESTURE_VC_FISTPUMP_MELEE");
					}
					else if (npc.Anger)
					{
						npc.FaceTowards(vecTarget);
						for(int client = 1; client <= MaxClients; client++)
						{
							if (IsClientInGame(client) && IsPlayerAlive(client) && dieingstate[client] == 0 && TeutonType[client] == 0 && GetTeam(client) == TFTeam_Red)
							{
								float vAngles[3], vDirection[3];
								
								float entity_angles[3];
										
								GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", vAngles); 
								
								GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", entity_angles); 
								
								float Distance = GetVectorDistance(vAngles, entity_angles);
								if(Distance < 1250)
								{				
									if(vAngles[0] > -45.0)
									{
											vAngles[0] = -45.0;
									}
														
									TF2_AddCondition(client, TFCond_LostFooting, 0.5);
									TF2_AddCondition(client, TFCond_AirCurrent, 0.5);
									
									f_ImmuneToFalldamage[client] = GetGameTime() + 5.0;
															
									GetAngleVectors(vAngles, vDirection, NULL_VECTOR, NULL_VECTOR);
											
									if(vDirection[2] > 0.0)
									{
										vDirection[2] *= -1.0;
									}
									
									ScaleVector(vDirection, -1250.0);
																			
									TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vDirection);
								}
							}
						}
						
						
						npc.DispatchParticleEffect(npc.index, "hammer_bell_ring_shockwave2", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("effect_hand_r"), PATTACH_POINT_FOLLOW, true);
		
						npc.m_flNextPull = GetGameTime(npc.index) + 13.0;
						npc.PlayPullSound();
						npc.AddGesture("ACT_MP_GESTURE_VC_FISTPUMP_MELEE");
					}
				} 
			}
									
									
			if(npc.m_flNextRangedBarrage_Spam < GetGameTime(npc.index) && npc.m_flNextRangedBarrage_Singular < GetGameTime(npc.index) && flDistanceToTarget < (500.0 * 500.0) || (npc.m_bInKame && npc.m_flNextRangedAttack < GetGameTime(npc.index)))
			{
				if (!npc.Anger)
				{
					npc.FaceTowards(vecTarget, 500.0);
					npc.FireRocket(vPredictedPos, 3.0 * RaidModeScaling, 700.0, "models/effects/combineball.mdl", 1.0);	
					npc.m_iAmountProjectiles += 1;
					npc.PlayRangedSound();
					npc.AddGesture("ACT_MP_THROW");
					npc.m_flNextRangedBarrage_Singular = GetGameTime(npc.index) + 0.15;
					
					if(i_RaidGrantExtra[npc.index] >= 5)
						TrueFusionwarrior_IOC_Invoke(EntIndexToEntRef(npc.index), closest);
						
					if (npc.m_iAmountProjectiles >= 8)
					{
						npc.m_iAmountProjectiles = 0;
						npc.m_flNextRangedBarrage_Spam = GetGameTime(npc.index) + 13.0;
					}
				}
				else if (npc.Anger)
				{
					
					npc.FaceTowards(vecTarget, 500.0);
					npc.FireRocket(vPredictedPos, 3.0 * RaidModeScaling, 700.0, "models/effects/combineball.mdl", 1.0);
					npc.m_iAmountProjectiles += 1;
					npc.PlayRangedSound();
					npc.AddGesture("ACT_MP_THROW");
					
					if(i_RaidGrantExtra[npc.index] >= 5)
						TrueFusionwarrior_IOC_Invoke(EntIndexToEntRef(npc.index), closest);
						
					npc.m_flNextRangedBarrage_Singular = GetGameTime(npc.index) + 0.15;
					if (npc.m_iAmountProjectiles >= 12)
					{
						npc.m_iAmountProjectiles = 0;
						npc.m_flNextRangedBarrage_Spam = GetGameTime(npc.index) + 11.0;
					}
				}
			}
			if(npc.m_flNextTeleport < GetGameTime(npc.index) && flDistanceToTarget > (125.0* 125.0) && flDistanceToTarget < (500.0 * 500.0) && !npc.m_bInKame && i_RaidGrantExtra[npc.index] >= 4)
			{
				static float flVel[3];
				GetEntPropVector(closest, Prop_Data, "m_vecVelocity", flVel);
				if (!npc.Anger)
				{
					if (flVel[0] >= 190.0)
					{
						npc.FaceTowards(vecTarget, 500.0);
						npc.m_flNextTeleport = GetGameTime(npc.index) + 6.0;
						float Tele_Check = GetVectorDistance(vPredictedPos, vecTarget);
						
						if(Tele_Check > 120.0)
						{
							bool Succeed = NPC_Teleport(npc.index, vPredictedPos);
							if(Succeed)
							{
								npc.PlayTeleportSound();
							}
							else
							{
								npc.m_flNextTeleport = GetGameTime(npc.index) + 1.0;
							}
						}
					}
				}
				else if (npc.Anger)
				{
					if (flVel[0] >= 170.0)
					{
						npc.FaceTowards(vecTarget, 500.0);
						npc.m_flNextTeleport = GetGameTime(npc.index) + 5.0;
						float Tele_Check = GetVectorDistance(vPredictedPos, vecTarget);
						if(Tele_Check > 120.0)
						{
							bool Succeed = NPC_Teleport(npc.index, vPredictedPos);
							if(Succeed)
							{
								npc.PlayTeleportSound();
							}
							else
							{
								npc.m_flNextTeleport = GetGameTime(npc.index) + 1.0;
							}
						}
					}
				}
			}
			//Target close enough to hit
			TrueFusionSelfDefense(npc, GetGameTime(npc.index));
		}
		else
		{
			npc.m_flGetClosestTargetTime = 0.0;
			npc.m_iTarget = GetClosestTarget(npc.index);
		}	
	if  (!npc.m_bInKame)
	{
		npc.StartPathing();
	}
	npc.PlayIdleAlertSound();
}
	
public Action TrueFusionWarrior_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	TrueFusionWarrior npc = view_as<TrueFusionWarrior>(victim);
	
	if(b_angered_twice[npc.index]) //Ignore teutons during this. they might ruin it.
	{
		damage = 0.0;
		return Plugin_Handled;
	}

	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}

	npc.m_flTimeSinceHasBeenHurt = GetGameTime() + 20.0;

	if((ReturnEntityMaxHealth(npc.index)/2) >= GetEntProp(npc.index, Prop_Data, "m_iHealth") && !npc.Anger) //npc.Anger after half hp/400 hp
	{
		npc.Anger = true; //	>:(
		npc.PlayAngerSound();
		npc.DispatchParticleEffect(npc.index, "hightower_explosion", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("head"), PATTACH_POINT_FOLLOW, true);
		/*
		SetEntityModel(npc.index, "models/freak_fortress_2/super_medic/medic_26_super.mdl");
		npc.m_flSpeed = 400.0;
		float minbounds[3] = {-20.0, -20.0, 0.0};
		float maxbounds[3] = {20.0, 20.0, 80.0};
		SetEntPropVector(npc.index, Prop_Send, "m_vecMins", minbounds);
		SetEntPropVector(npc.index, Prop_Send, "m_vecMaxs", maxbounds);
		*/
		if(IsValidEntity(npc.m_iWearable7))
			SetEntityRenderColor(npc.m_iWearable7, 255, 255, 255, 3);

		//FusionApplyEffects(npc.index, 1);
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
			
		SetVariantColor(view_as<int>({255, 255, 0, 200}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
	}
	if(!b_angered_twice[npc.index] && i_RaidGrantExtra[npc.index] == 6)
	{
		if(((ReturnEntityMaxHealth(npc.index)/20) >= GetEntProp(npc.index, Prop_Data, "m_iHealth")) || (RoundToCeil(damage) >= GetEntProp(npc.index, Prop_Data, "m_iHealth"))) //npc.Anger after half hp/400 hp
		{
			b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true; //Make allied npcs ignore him.

			ReviveAll(true);

			b_angered_twice[npc.index] = true; //	>:(
			RaidModeTime += 60.0;

			NPCStats_RemoveAllDebuffs(npc.index, 1.0);
			b_NpcIsInvulnerable[npc.index] = true;
			GiveProgressDelay(20.0);
			RemoveNpcFromEnemyList(npc.index);

			StopSound(npc.index,SNDCHAN_STATIC,"weapons/physcannon/energy_sing_loop4.wav");
			StopSound(npc.index, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
			StopSound(npc.index, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
			StopSound(npc.index, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");

			SDKUnhook(npc.index, SDKHook_Think, TrueFusionWarrior_TBB_Tick);

			CPrintToChatAll("{gold}Silvester{default}: Stop, stop please I beg you, I was infected!");
			int i = MaxClients + 1;
			while((i = FindEntityByClassname(i, "obj_sentrygun")) != -1)
			{
				RemoveEntity(i);
			}
			int skin = 1;
			SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

			if(IsValidEntity(npc.m_iWearable1))
			{
				RemoveEntity(npc.m_iWearable1);
			}
			if(IsValidEntity(npc.m_iWearable7))
			{
				RemoveEntity(npc.m_iWearable7);
			}


			SetVariantColor(view_as<int>({150, 150, 0, 150}));
			AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
			damage = 0.0; //So he doesnt get oneshot somehow, atleast once.
			return Plugin_Handled;
		}
	}
	return Plugin_Changed;
}

public void TrueFusionWarrior_NPCDeath(int entity)
{
	TrueFusionWarrior npc = view_as<TrueFusionWarrior>(entity);
	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
	
	ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
	npc.PlayDeathSound();
	StopSound(entity,SNDCHAN_STATIC,"weapons/physcannon/energy_sing_loop4.wav");
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	ExpidonsaRemoveEffects(entity);
	
	RaidBossActive = INVALID_ENT_REFERENCE;
	
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
		
//	AcceptEntityInput(npc.index, "KillHierarchy");
//	npc.Anger = false;

	Citizen_MiniBossDeath(entity);
}

// Ent_Create style position from Doomsday Nuke

void Invoke_TrueFusionWarrior_Kameha(TrueFusionWarrior npc)
{
	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
	ParticleEffectAt(WorldSpaceVec, "eyeboss_death_vortex", 2.0);
	float GameTime = GetGameTime(npc.index);
	fl_BEAM_ChargeUpTime[npc.index] = GameTime + 3.0;
	fl_BEAM_DurationTime[npc.index] = GameTime + (npc.Anger ? 6.0 : 5.0);

	EmitSoundToAll("weapons/physcannon/energy_sing_loop4.wav", npc.index, SNDCHAN_STATIC, 120, _, 1.0, 75);
	EmitSoundToAll("weapons/physcannon/energy_sing_loop4.wav", npc.index, SNDCHAN_STATIC, 120, _, 1.0, 75);
	EmitSoundToAll("weapons/physcannon/energy_sing_loop4.wav", npc.index, SNDCHAN_STATIC, 120, _, 1.0, 75);
	
	npc.PlayLaserLaunchSound();
	
	SDKUnhook(npc.index, SDKHook_Think, TrueFusionWarrior_TBB_Tick);
	SDKHook(npc.index, SDKHook_Think, TrueFusionWarrior_TBB_Tick);
}


static Action TrueFusionWarrior_TBB_Tick(int client)
{
	TrueFusionWarrior npc = view_as<TrueFusionWarrior>(client);
	float GameTime = GetGameTime(npc.index);
	if(!IsValidEntity(client) || fl_BEAM_DurationTime[npc.index] < GameTime)
	{
		StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
		StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
		StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
		EmitSoundToAll("weapons/physcannon/physcannon_drop.wav", client, SNDCHAN_STATIC, 80, _, 1.0);

		SDKUnhook(client, SDKHook_Think, TrueFusionWarrior_TBB_Tick);
		npc.m_bInKame = false;
		return Plugin_Stop;
	}

	if(fl_BEAM_ChargeUpTime[npc.index] > GameTime)
		return Plugin_Continue;

	Basic_NPC_Laser Data;
	Data.npc = npc;
	Data.Radius = 45.0;
	Data.Range = 2000.0;
	//divided by 6 since its every tick, and by TickrateModify
	Data.Close_Dps = RaidModeScaling * (npc.Anger ? 20.0 : 15.0) / 6.0 / TickrateModify/ ReturnEntityAttackspeed(npc.index);
	Data.Long_Dps = RaidModeScaling * (npc.Anger ? 18.5 : 12.0) / 6.0 / TickrateModify/ ReturnEntityAttackspeed(npc.index);
	Data.Color = (npc.Anger ? {238, 221, 68, 60} : {255, 255, 255, 30});
	Data.DoEffects = true;
	Basic_NPC_Laser_Logic(Data);

	return Plugin_Continue;
}


public void TrueFusionwarrior_IOC_Invoke(int ref, int enemy)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
		static float distance=87.0; // /29 for duartion till boom
		static float IOCDist=250.0;
		static float IOCdamage;
		IOCdamage= (150.0 * RaidModeScaling);
		
		float vecTarget[3];
		GetEntPropVector(enemy, Prop_Data, "m_vecAbsOrigin", vecTarget);
		
		Handle data = CreateDataPack();
		WritePackFloat(data, vecTarget[0]);
		WritePackFloat(data, vecTarget[1]);
		WritePackFloat(data, vecTarget[2]);
		WritePackCell(data, distance); // Distance
		WritePackFloat(data, 0.0); // nphi
		WritePackFloat(data, IOCDist); // Range
		WritePackFloat(data, IOCdamage); // Damge
		WritePackCell(data, ref);
		ResetPack(data);
		TrueFusionwarrior_IonAttack(data);
	}
}

public Action TrueFusionwarrior_DrawIon(Handle Timer, any data)
{
	TrueFusionwarrior_IonAttack(data);
		
	return (Plugin_Stop);
}
	
public void TrueFusionwarrior_DrawIonBeam(float startPosition[3], const int color[4])
{
	float position[3];
	position[0] = startPosition[0];
	position[1] = startPosition[1];
	position[2] = startPosition[2] + 3000.0;	
	
	TE_SetupBeamPoints(startPosition, position, g_Ruina_BEAM_Laser, 0, 0, 0, 0.15, 25.0, 25.0, 0, 1.0, color, 3 );
	TE_SendToAll();
	position[2] -= 1490.0;
	TE_SetupGlowSprite(startPosition, g_Ruina_Glow_Blue, 1.0, 1.0, 255);
	TE_SendToAll();
}

	public void TrueFusionwarrior_IonAttack(Handle &data)
	{
		float startPosition[3];
		float position[3];
		startPosition[0] = ReadPackFloat(data);
		startPosition[1] = ReadPackFloat(data);
		startPosition[2] = ReadPackFloat(data);
		float Iondistance = ReadPackCell(data);
		float nphi = ReadPackFloat(data);
		float Ionrange = ReadPackFloat(data);
		float Iondamage = ReadPackFloat(data);
		int client = EntRefToEntIndex(ReadPackCell(data));
		
		if(!IsValidEntity(client) || b_NpcHasDied[client])
		{
			delete data;
			return;
		}
		spawnRing_Vectors(startPosition, Ionrange * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 212, 175, 55, 255, 1, 0.2, 12.0, 4.0, 3);	
		
		if (Iondistance > 0)
		{
			EmitSoundToAll("ambient/energy/weld1.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, startPosition);
			
			// Stage 1
			float s=Sine(nphi/360*6.28)*Iondistance;
			float c=Cosine(nphi/360*6.28)*Iondistance;
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[2] = startPosition[2];
			
			position[0] += s;
			position[1] += c;
		//	TrueFusionwarrior_DrawIonBeam(position, {212, 175, 55, 255});
	
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] -= s;
			position[1] -= c;
			TrueFusionwarrior_DrawIonBeam(position, {212, 175, 55, 255});
			
			// Stage 2
			s=Sine((nphi+45.0)/360*6.28)*Iondistance;
			c=Cosine((nphi+45.0)/360*6.28)*Iondistance;
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] += s;
			position[1] += c;
			TrueFusionwarrior_DrawIonBeam(position, {212, 175, 55, 255});
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] -= s;
			position[1] -= c;
		//	TrueFusionwarrior_DrawIonBeam(position, {212, 175, 55, 255});
			
			// Stage 3
			s=Sine((nphi+90.0)/360*6.28)*Iondistance;
			c=Cosine((nphi+90.0)/360*6.28)*Iondistance;
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] += s;
			position[1] += c;
		//	TrueFusionwarrior_DrawIonBeam(position, {212, 175, 55, 255});
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] -= s;
			position[1] -= c;
			TrueFusionwarrior_DrawIonBeam(position, {212, 175, 55, 255});
			
			// Stage 3
			s=Sine((nphi+135.0)/360*6.28)*Iondistance;
			c=Cosine((nphi+135.0)/360*6.28)*Iondistance;
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] += s;
			position[1] += c;
			TrueFusionwarrior_DrawIonBeam(position, {212, 175, 55, 255});
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] -= s;
			position[1] -= c;
		//	TrueFusionwarrior_DrawIonBeam(position, {212, 175, 55, 255});
	
			if (nphi >= 360)
				nphi = 0.0;
			else
				nphi += 5.0;
		}
		Iondistance -= 10;

		delete data;
		
		Handle nData = CreateDataPack();
		WritePackFloat(nData, startPosition[0]);
		WritePackFloat(nData, startPosition[1]);
		WritePackFloat(nData, startPosition[2]);
		WritePackCell(nData, Iondistance);
		WritePackFloat(nData, nphi);
		WritePackFloat(nData, Ionrange);
		WritePackFloat(nData, Iondamage);
		WritePackCell(nData, EntIndexToEntRef(client));
		ResetPack(nData);
		
		if (Iondistance > -30)
		CreateTimer(0.1, TrueFusionwarrior_DrawIon, nData, TIMER_FLAG_NO_MAPCHANGE);
		else
		{
			startPosition[2] += 25.0;
			if(!b_Anger[client])
				makeexplosion(client, startPosition, RoundToCeil(Iondamage), 100);
				
			else if(b_Anger[client])
				makeexplosion(client, startPosition, RoundToCeil(Iondamage * 1.25), 120);
				
			startPosition[2] -= 25.0;
			TE_SetupExplosion(startPosition, gExplosive1, 10.0, 1, 0, 0, 0);
			TE_SendToAll();
			spawnRing_Vectors(startPosition, 0.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 212, 175, 55, 255, 1, 0.5, 20.0, 10.0, 3, Ionrange * 2.0);	
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[2] += startPosition[2] + 900.0;
			startPosition[2] += -200;
			TE_SetupBeamPoints(startPosition, position, g_Ruina_BEAM_Laser, 0, 0, 0, 2.0, 30.0, 30.0, 0, 1.0, {212, 175, 55, 255}, 3);
			TE_SendToAll();
			TE_SetupBeamPoints(startPosition, position, g_Ruina_BEAM_Laser, 0, 0, 0, 2.0, 50.0, 50.0, 0, 1.0, {212, 175, 55, 200}, 3);
			TE_SendToAll();
		//	TE_SetupBeamPoints(startPosition, position, g_Ruina_BEAM_Laser, 0, 0, 0, 2.0, 80.0, 80.0, 0, 1.0, {212, 175, 55, 120}, 3);
		//	TE_SendToAll();
			TE_SetupBeamPoints(startPosition, position, g_Ruina_BEAM_Laser, 0, 0, 0, 2.0, 100.0, 100.0, 0, 1.0, {212, 175, 55, 75}, 3);
			TE_SendToAll();
	
			position[2] = startPosition[2] + 50.0;
			//new Float:fDirection[3] = {-90.0,0.0,0.0};
			//env_shooter(fDirection, 25.0, 0.1, fDirection, 800.0, 120.0, 120.0, position, "models/props_wasteland/rockgranite03b.mdl");
	
			//env_shake(startPosition, 120.0, 10000.0, 15.0, 250.0);
			
			// Sound
			EmitSoundToAll("ambient/explosions/explode_9.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, startPosition);
	
			// Blend
			//sendfademsg(0, 10, 200, FFADE_OUT, 255, 255, 255, 150);
			
			// Knockback
	/*		float vReturn[3];
			float vClientPosition[3];
			float dist;
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsClientConnected(i) && IsClientInGame(i) && IsPlayerAlive(i))
				{	
					GetClientEyePosition(i, vClientPosition);
	
					dist = GetVectorDistance(vClientPosition, position, false);
					if (dist < Ionrange)
					{
						MakeVectorFromPoints(position, vClientPosition, vReturn);
						NormalizeVector(vReturn, vReturn);
						ScaleVector(vReturn, 10000.0 - dist*10);
	
						TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, vReturn);
					}
				}
			}
*/
		}
}


void TrueFusionSelfDefense(TrueFusionWarrior npc, float gameTime)
{
	if(npc.m_bInKame)
		return;

	//This code is only here so they defend themselves incase any enemy is too close to them. otherwise it is completly disconnected from any other logic.
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < GetGameTime(npc.index))
		{
			npc.m_flAttackHappens = 0.0;
			
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				int HowManyEnemeisAoeMelee = 64;
				Handle swingTrace;
				float WorldSpaceVec[3]; WorldSpaceCenter(npc.m_iTarget, WorldSpaceVec);
				npc.FaceTowards(WorldSpaceVec, 20000.0);
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
							int target = i_EntitiesHitAoeSwing_NpcSwing[counter];
							float vecHit[3];
							WorldSpaceCenter(target, vecHit);

							float damage = 24.0;
							float damage_rage = 28.0;
							
							if(!npc.Anger)
								SDKHooks_TakeDamage(target, npc.index, npc.index, damage * RaidModeScaling * 0.85, DMG_CLUB, -1, _, vecHit);
									
							if(npc.Anger)
								SDKHooks_TakeDamage(target, npc.index, npc.index, damage_rage * RaidModeScaling * 0.85, DMG_CLUB, -1, _, vecHit);									
								
							
							// Hit particle
							
							
							// Hit sound
							bool Knocked = false;
							
							if(IsValidClient(target))
							{
								if (IsInvuln(target))
								{
									Knocked = true;
									Custom_Knockback(npc.index, target, 900.0, true);
									TF2_AddCondition(target, TFCond_LostFooting, 0.5);
									TF2_AddCondition(target, TFCond_AirCurrent, 0.5);
								}
								else
								{
									TF2_AddCondition(target, TFCond_LostFooting, 0.5);
									TF2_AddCondition(target, TFCond_AirCurrent, 0.5);
								}
							}
							
							if(!Knocked)
								Custom_Knockback(npc.index, target, 450.0, true); 
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

	if(GetGameTime(npc.index) > npc.m_flNextMeleeAttack)
	{
		if(IsValidEnemy(npc.index, npc.m_iTarget)) 
		{
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );

			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);

			if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.5))
			{
				int Enemy_I_See;
									
				Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
						
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;

					npc.PlayMeleeSound();

					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
							
					npc.m_flAttackHappens = gameTime + 0.3;

					npc.m_flNextMeleeAttack = gameTime + 1.2;
				}
			}
		}
	}
}

public void Raidmode_Fusion_Warrior_Win(int entity)
{
	i_RaidGrantExtra[entity] = RAIDITEM_INDEX_WIN_COND;
}