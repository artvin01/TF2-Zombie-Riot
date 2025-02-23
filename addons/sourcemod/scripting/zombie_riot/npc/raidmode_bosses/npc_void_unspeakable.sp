#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"npc/zombie/zombie_die1.wav",
	"npc/zombie/zombie_die2.wav",
	"npc/zombie/zombie_die3.wav",
};

static const char g_HurtSounds[][] = {
	"npc/zombie/zombie_pain1.wav",
	"npc/zombie/zombie_pain2.wav",
	"npc/zombie/zombie_pain3.wav",
	"npc/zombie/zombie_pain4.wav",
	"npc/zombie/zombie_pain5.wav",
	"npc/zombie/zombie_pain6.wav",
};

static const char g_IdleAlertedSounds[][] = {
	"npc/zombie/zombie_voice_idle1.wav",
	"npc/zombie/zombie_voice_idle2.wav",
	"npc/zombie/zombie_voice_idle3.wav",
	"npc/zombie/zombie_voice_idle4.wav",
	"npc/zombie/zombie_voice_idle5.wav",
	"npc/zombie/zombie_voice_idle6.wav",
	"npc/zombie/zombie_voice_idle7.wav",
	"npc/zombie/zombie_voice_idle8.wav",
	"npc/zombie/zombie_voice_idle9.wav",
	"npc/zombie/zombie_voice_idle10.wav",
	"npc/zombie/zombie_voice_idle11.wav",
	"npc/zombie/zombie_voice_idle12.wav",
	"npc/zombie/zombie_voice_idle13.wav",
	"npc/zombie/zombie_voice_idle14.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/pickaxe_swing1.wav",
	"weapons/pickaxe_swing2.wav",
	"weapons/pickaxe_swing3.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/cleaver_hit_02.wav",
	"weapons/cleaver_hit_03.wav",
	"weapons/cleaver_hit_05.wav",
	"weapons/cleaver_hit_06.wav",
	"weapons/cleaver_hit_07.wav",
};
static const char g_TeleportSound[][] = {
	"weapons/rescue_ranger_teleport_receive_01.wav",
	"weapons/rescue_ranger_teleport_receive_02.wav",
};

static int i_LaserEntityIndex[MAXENTITIES]={-1, ...};

static int NpcID;
bool BossrushLogic = false;

int VoidUnspeakableNpcID()
{
	return NpcID;
}

void VoidUnspeakable_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Unspeakable");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_void_unspeakable");
	strcopy(data.Icon, sizeof(data.Icon), "raid_unspeakable");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Raid;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NpcID = NPC_Add(data);
}

static void ClotPrecache()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_TeleportSound)); i++) { PrecacheSound(g_TeleportSound[i]); }
	PrecacheSoundCustom("#zombiesurvival/void_wave/unspeakable_raid.mp3");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return VoidUnspeakable(vecPos, vecAng, team, data);
}
methodmap VoidUnspeakable < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayTeleportSound() 
	{
		EmitSoundToAll(g_TeleportSound[GetRandomInt(0, sizeof(g_TeleportSound) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	property float m_flVoidUnspeakableQuake
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flVoidMatterAbosorbCooldown
	{
		public get()							{ return fl_AbilityOrAttack[this.index][5]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][5] = TempValueForProperty; }
	}
	property float m_flVoidMatterAbosorb
	{
		public get()							{ return fl_NextRangedAttack[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextRangedAttack[this.index] = TempValueForProperty; }
	}
	property int m_iPlayerScaledStart
	{
		public get()							{ return i_MedkitAnnoyance[this.index]; }
		public set(int TempValueForProperty) 	{ i_MedkitAnnoyance[this.index] = TempValueForProperty; }
	}
	property float m_flVoidMatterAbosorbInternalCD
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flVoidMatterAbosorbInternalCDBoom
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	
	property float m_flVoidPillarAttack
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	property float m_flVoidRapidMelee
	{
		public get()							{ return fl_AbilityOrAttack[this.index][4]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][4] = TempValueForProperty; }
	}
	property float m_flDeathAnimation
	{
		public get()							{ return fl_AbilityOrAttack[this.index][6]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][6] = TempValueForProperty; }
	}
	property float m_flDeathAnimationCD
	{
		public get()							{ return fl_AbilityOrAttack[this.index][7]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][7] = TempValueForProperty; }
	}
	property float m_flResistanceBuffs
	{
		public get()							{ return fl_AbilityOrAttack[this.index][8]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][8] = TempValueForProperty; }
	}
	property float m_flSpreadDelay
	{
		public get()							{ return fl_AbilityOrAttack[this.index][6]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][6] = TempValueForProperty; }
	}
	property float m_flMaxDeath
	{
		public get()							{ return fl_AbilityOrAttack[this.index][9]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][9] = TempValueForProperty; }
	}
	
	
	public VoidUnspeakable(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		int WaveSetting = 1;
		char SizeChar[5];
		SizeChar = "1.35";
		if(StrContains(data, "first") != -1)
		{
			WaveSetting = 1;
			SizeChar = "1.35";
		}
		else if(StrContains(data, "second") != -1)
		{
			WaveSetting = 2;
			SizeChar = "1.39";
		}
		else if(StrContains(data, "third") != -1)
		{
			WaveSetting = 3;
			SizeChar = "1.45";
		}
		else if(StrContains(data, "forth") != -1)
		{
			//outside of wave stuff.
			WaveSetting = 4;
			SizeChar = "1.5";
		}
		else if(StrContains(data, "final_item") != -1)
		{
			WaveSetting = 5;
			SizeChar = "1.5";
		}


		VoidUnspeakable npc = view_as<VoidUnspeakable>(CClotBody(vecPos, vecAng, "models/player/pyro.mdl", SizeChar, "25000", ally, false, true));
		
		i_RaidGrantExtra[npc.index] = WaveSetting;
		if(WaveSetting == 5)
		{
			b_NpcUnableToDie[npc.index] = true;
		}
		BossrushLogic = false;
		if(StrContains(data, "bossrush") != -1)
		{
			BossrushLogic = true;
		}
		RemoveAllDamageAddition();
		npc.m_flDeathAnimation = 0.0;
		i_NpcWeight[npc.index] = 4;
		npc.g_TimesSummoned = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		SetVariantInt(6);
		AcceptEntityInput(npc.index, "SetBodyGroup");	
		
		npc.m_iChanged_WalkCycle = -1;

		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_VOID;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_TANK;
		npc.m_flVoidUnspeakableQuake = 0.0;
		npc.m_flVoidMatterAbosorbCooldown = GetGameTime() + 15.0;
		npc.m_flVoidMatterAbosorb = 0.0;
		npc.m_flVoidPillarAttack =  GetGameTime() + 5.0;
		AlreadySaidWin = false;
		AlreadySaidLastmann = false;

		func_NPCDeath[npc.index] = view_as<Function>(VoidUnspeakable_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(VoidUnspeakable_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(VoidUnspeakable_ClotThink);
		func_NPCFuncWin[npc.index] = view_as<Function>(VoidUnspeakableWin);
		
		
		
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
	
		//if(!cutscene)
		{
			MusicEnum music;
			strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/void_wave/unspeakable_raid.mp3");
			music.Time = 187;
			music.Volume = 0.75;
			music.Custom = true;
			strcopy(music.Name, sizeof(music.Name), "Lilith");
			strcopy(music.Artist, sizeof(music.Artist), "Gost");
			Music_SetRaidMusic(music);
		}
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0, 80);	
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0, 80);	

		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "item_armor", 1, "%t", "Run while you can.");
			}
		}

		RaidModeTime = GetGameTime(npc.index) + 200.0;
		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = false;
		b_thisNpcIsARaid[npc.index] = true;
		npc.m_flMeleeArmor = 1.25;	

		float value;
		char buffers[3][64];
		ExplodeString(data, ";", buffers, sizeof(buffers), sizeof(buffers[]));
		//the very first and 2nd char are SC for scaling
		if(buffers[0][0] == 's' && buffers[0][1] == 'c')
		{
			//remove SC
			ReplaceString(buffers[0], 64, "sc", "");
			value = StringToFloat(buffers[0]);
			RaidModeScaling = value;
		}
		else
		{	
			RaidModeScaling = float(Waves_GetRound()+1);
			value = float(Waves_GetRound()+1);
		}

		if(RaidModeScaling < 55)
		{
			RaidModeScaling *= 0.19; //abit low, inreacing
		}
		else
		{
			RaidModeScaling *= 0.38;
		}
		
		float amount_of_people = ZRStocks_PlayerScalingDynamic();
		npc.m_iPlayerScaledStart = CountPlayersOnRed();
		if(amount_of_people > 12.0)
		{
			amount_of_people = 12.0;
		}
		amount_of_people *= 0.12;
		
		if(amount_of_people < 1.0)
			amount_of_people = 1.0;

		RaidModeScaling *= amount_of_people; //More then 9 and he raidboss gets some troubles, bufffffffff
		
		if(value > 40.0 && value < 55.0)
		{
			RaidModeScaling *= 0.85;
		}
		else if(value > 55.0)
		{
			RaidModeTime = GetGameTime(npc.index) + 220.0;
			RaidModeScaling *= 0.85;
		}

		if(!BossrushLogic)
		{
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
				DispatchKeyValue(entity, "fogcolor", "25 0 25 50");
				DispatchKeyValue(entity, "fogcolor2", "25 0 25 50");
				DispatchKeyValueFloat(entity, "fogstart", 400.0);
				DispatchKeyValueFloat(entity, "fogend", 1000.0);
				DispatchKeyValueFloat(entity, "fogmaxdensity", 0.85);

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
		skin = 5;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		switch(WaveSetting)
		{
			case 1:
			{
				npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/pyro/hw2013_beast_from_below/hw2013_beast_from_below.mdl");
				
				npc.m_iWearable2 = npc.EquipItem("head", "models/workshop_partner/player/items/scout/ai_body/ai_body.mdl");
				npc.m_iWearable3 = npc.EquipItem("head", "models/player/items/pyro/pyro_zombie.mdl");
				npc.m_iWearable4 = npc.EquipItem("head", "models/weapons/c_models/c_axtinguisher/c_axtinguisher_pyro.mdl");
				npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/pyro/hw2013_hardheaded_hardware/hw2013_hardheaded_hardware.mdl");
				npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/pyro/hw2013_tin_can/hw2013_tin_can.mdl");
				npc.m_iWearable7 = npc.EquipItem("head", "models/workshop/player/items/pyro/dec2014_armoured_appendages/dec2014_armoured_appendages.mdl");
				SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
				SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
				SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
				SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
				SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
				SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", skin);
				SetEntProp(npc.m_iWearable7, Prop_Send, "m_nSkin", skin);
				SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable1, 200, 0, 200, 255);
				SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable2, 200, 0, 200, 255);
				SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable3, 200, 0, 200, 255);
				SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable4, 200, 0, 200, 255);
				SetEntityRenderMode(npc.m_iWearable5, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable5, 200, 0, 200, 255);
				SetEntityRenderMode(npc.m_iWearable6, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable6, 200, 0, 200, 255);
				SetEntityRenderMode(npc.m_iWearable7, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable7, 200, 0, 200, 255);
			}
			case 2:
			{
				npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/pyro/hw2013_beast_from_below/hw2013_beast_from_below.mdl");
				
				npc.m_iWearable2 = npc.EquipItem("head", "models/workshop_partner/player/items/scout/ai_body/ai_body.mdl");
				npc.m_iWearable3 = npc.EquipItem("head", "models/player/items/pyro/pyro_zombie.mdl");
				npc.m_iWearable4 = npc.EquipItem("head", "models/weapons/c_models/c_axtinguisher/c_axtinguisher_pyro.mdl");
				npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/pyro/hw2013_hardheaded_hardware/hw2013_hardheaded_hardware.mdl");
				npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/heavy/sf14_halloween_bone_cut_belt/sf14_halloween_bone_cut_belt.mdl");
				npc.m_iWearable7 = npc.EquipItem("head", "models/workshop/player/items/all_class/hw2013_the_dark_helm/hw2013_the_dark_helm_pyro.mdl");
				SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
				SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
				SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
				SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
				SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
				SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", skin);
				SetEntProp(npc.m_iWearable7, Prop_Send, "m_nSkin", skin);
				SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable1, 200, 0, 200, 255);
				SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable2, 200, 0, 200, 255);
				SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable3, 200, 0, 200, 255);
				SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable4, 200, 0, 200, 255);
				SetEntityRenderMode(npc.m_iWearable5, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable5, 200, 0, 200, 255);
				SetEntityRenderMode(npc.m_iWearable6, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable6, 200, 0, 200, 255);
				SetEntityRenderMode(npc.m_iWearable7, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable7, 200, 0, 200, 255);
			}
			case 3:
			{
				npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/demo/hw2013_demo_cape/hw2013_demo_cape.mdl");
				
				npc.m_iWearable2 = npc.EquipItem("head", "models/workshop_partner/player/items/scout/ai_body/ai_body.mdl");
				npc.m_iWearable3 = npc.EquipItem("head", "models/player/items/pyro/pyro_zombie.mdl");
				npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_rift_fire_axe/c_rift_fire_axe.mdl");
				npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/pyro/hw2013_hardheaded_hardware/hw2013_hardheaded_hardware.mdl");
				npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/demo/sf14_deadking_pauldrons/sf14_deadking_pauldrons.mdl");
				npc.m_iWearable7 = npc.EquipItem("head", "models/workshop/player/items/all_class/hw2013_the_dark_helm/hw2013_the_dark_helm_pyro.mdl");
				npc.m_iWearable8 = npc.EquipItem("head", "models/workshop/player/items/pyro/hw2013_beast_from_below/hw2013_beast_from_below.mdl");
				SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
				SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
				SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
				SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
				SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
				SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", skin);
				SetEntProp(npc.m_iWearable7, Prop_Send, "m_nSkin", skin);
				SetEntProp(npc.m_iWearable8, Prop_Send, "m_nSkin", skin);
				SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable1, 200, 0, 200, 255);
				SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable2, 200, 0, 200, 255);
				SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable3, 200, 0, 200, 255);
				SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable4, 200, 0, 200, 255);
				SetEntityRenderMode(npc.m_iWearable5, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable5, 200, 0, 200, 255);
				SetEntityRenderMode(npc.m_iWearable6, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable6, 200, 0, 200, 255);
				SetEntityRenderMode(npc.m_iWearable7, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable7, 200, 0, 200, 255);
				SetEntityRenderMode(npc.m_iWearable8, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable8, 200, 0, 200, 255);
			}
			case 4,5:
			{
				npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/demo/hw2013_demo_cape/hw2013_demo_cape.mdl");
				
				npc.m_iWearable2 = npc.EquipItem("head", "models/workshop_partner/player/items/scout/ai_body/ai_body.mdl");
				npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/engineer/sf14_iron_fist/sf14_iron_fist.mdl");
				npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_rift_fire_axe/c_rift_fire_axe.mdl");
				npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/pyro/hw2013_hardheaded_hardware/hw2013_hardheaded_hardware.mdl");
				npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/demo/sf14_deadking_pauldrons/sf14_deadking_pauldrons.mdl");
				npc.m_iWearable7 = npc.EquipItem("head", "models/workshop/player/items/all_class/hw2013_the_dark_helm/hw2013_the_dark_helm_pyro.mdl");
				SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
				SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
				SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
				SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
				SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
				SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", skin);
				SetEntProp(npc.m_iWearable7, Prop_Send, "m_nSkin", skin);
				SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable1, 200, 0, 200, 255);
				SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable2, 200, 0, 200, 255);
				SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable3, 200, 0, 200, 255);
				SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable4, 200, 0, 200, 255);
				SetEntityRenderMode(npc.m_iWearable5, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable5, 200, 0, 200, 255);
				SetEntityRenderMode(npc.m_iWearable6, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable6, 200, 0, 200, 255);
				SetEntityRenderMode(npc.m_iWearable7, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable7, 200, 0, 200, 255);
				SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);
				SetEntityRenderFx(npc.index,		 RENDERFX_DISTORT);
				SetEntityRenderFx(npc.m_iWearable1, RENDERFX_DISTORT);
				SetEntityRenderFx(npc.m_iWearable2, RENDERFX_DISTORT);
				SetEntityRenderFx(npc.m_iWearable3, RENDERFX_DISTORT);
				SetEntityRenderFx(npc.m_iWearable4, RENDERFX_DISTORT);
				SetEntityRenderFx(npc.m_iWearable5, RENDERFX_DISTORT);
				SetEntityRenderFx(npc.m_iWearable6, RENDERFX_DISTORT);
				SetEntityRenderFx(npc.m_iWearable7, RENDERFX_DISTORT);
			}
		}
		
		SetEntityRenderMode(npc.index, 		RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index,		 200, 0, 200, 255);
		
		return npc;
	}
}

public void VoidUnspeakable_ClotThink(int iNPC)
{
	VoidUnspeakable npc = view_as<VoidUnspeakable>(iNPC);
	float TotalArmor = 1.0;
	if(npc.m_flResistanceBuffs > GetGameTime())
	{
		TotalArmor *= 0.25;
	}

	if(npc.Anger)
		TotalArmor *= 0.95;

	fl_TotalArmor[iNPC] = TotalArmor;

	if(npc.m_flDeathAnimation)
	{
		npc.Update();
		VoidUnspeakable_DeathAnimationKahml(npc, GetGameTime());
		return;
	}
	if(npc.m_flVoidUnspeakableQuake < GetGameTime())
	{
		npc.m_flVoidUnspeakableQuake = GetGameTime() + 1.0;
		float ProjectileLoc[3];
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
		CreateEarthquake(ProjectileLoc, 1.0, 250.0, 5.0, 5.0);
		if(npc.Anger)
		{
			//always leaves creep onto the floor if enraged
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
			ProjectileLoc[2] += 5.0;
			VoidArea_SpawnNethersea(ProjectileLoc);
		}
	}
	if(LastMann && !AlreadySaidLastmann)
	{
		AlreadySaidLastmann = true;
		CPrintToChatAll("{purple}It grins. Wide.");
	}
	if(!npc.m_flMaxDeath && RaidModeTime < GetGameTime())
	{
		npc.m_flMaxDeath = 1.0;
	//	ForcePlayerLoss();
	//	RaidBossActive = INVALID_ENT_REFERENCE;
	//	func_NPCThink[npc.index] = INVALID_FUNCTION;
		CPrintToChatAll("{purple}It laughs at your incompetence.");
		SetEntPropFloat(npc.index, Prop_Send, "m_flModelScale", 1.85);
		RaidModeScaling *= 5.0;
		fl_Extra_Speed[npc.index] *= 2.0;
		fl_Extra_MeleeArmor[npc.index] *= 0.1;
		fl_Extra_RangedArmor[npc.index] *= 0.1;
		
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
			DispatchKeyValue(entity, "fogcolor", "50 0 50 150");
			DispatchKeyValue(entity, "fogcolor2", "50 0 50 150");
			DispatchKeyValueFloat(entity, "fogstart", 200.0);
			DispatchKeyValueFloat(entity, "fogend", 500.0);
			DispatchKeyValueFloat(entity, "fogmaxdensity", 0.99);

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
		return;
	}

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

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	npc.PlayIdleAlertSound();

	if(VoidUnspeakable_MatterAbsorber(npc, GetGameTime(npc.index)))
	{
		return;
	}
	if(VoidUnspeakable_TeleToAnyAffectedOnVoid(npc))
	{
		return;
	}

	if(npc.m_flDoingAnimation < GetGameTime(npc.index))
	{
		if(npc.m_iChanged_WalkCycle != 1)
		{
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 1;
			npc.SetActivity("ACT_MP_RUN_MELEE");
			npc.StartPathing();
			npc.m_flSpeed = 310.0;
			if(IsValidEntity(npc.m_iWearable4))
			{
				AcceptEntityInput(npc.m_iWearable4, "Enable");
			}
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
			NPC_SetGoalVector(npc.index, vPredictedPos);
		}
		else 
		{
			NPC_SetGoalEntity(npc.index, npc.m_iTarget);
		}
		VoidUnspeakableSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
}

public Action VoidUnspeakable_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VoidUnspeakable npc = view_as<VoidUnspeakable>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	if((ReturnEntityMaxHealth(npc.index)/4) >= GetEntProp(npc.index, Prop_Data, "m_iHealth") && !npc.Anger) 
	{
		npc.Anger = true;
		SensalGiveShield(npc.index, CountPlayersOnRed(1) * 12);
		CPrintToChatAll("{purple}It's Angered.");
		RaidModeScaling *= 1.1;
	}
	if(npc.g_TimesSummoned < 3)
	{
		int maxhealth = ReturnEntityMaxHealth(npc.index);
		int health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
		int nextLoss = (maxhealth/ 10) * (3 - npc.g_TimesSummoned) / 3;


		if((health / 10) < nextLoss)
		{
			npc.g_TimesSummoned++;
			ApplyStatusEffect(npc.index, npc.index, "Defensive Backup", 5.0);
			npc.m_flResistanceBuffs = GetGameTime() + 2.0;
			float ProjectileLoc[3];	
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
			ProjectileLoc[2] += 5.0;
			VoidArea_SpawnNethersea(ProjectileLoc);
			switch(GetRandomInt(1,2))
			{
				case 1:
				{
					CPrintToChatAll("{purple}It recoils in pain.");
				}
				case 2:
				{
					CPrintToChatAll("{purple}It screams in agony.");
				}
			}
		}
	}

	if(b_NpcUnableToDie[npc.index] && RaidModeTime < FAR_FUTURE)
	{
		if(damage >= GetEntProp(npc.index, Prop_Data, "m_iHealth"))
		{
			RaidModeTime = FAR_FUTURE;
			//its in phase 2.
			i_RaidGrantExtra[npc.index] = 10;
			npc.m_flDeathAnimation = GetGameTime(npc.index) + 45.0;
			//emergency slay if it bricks somehow.
			RequestFrames(KillNpc,3000, EntIndexToEntRef(npc.index));
			ReviveAll(true);
		}
	}
	
	return Plugin_Changed;
}

float VoidUnspeakable_Absorber(int entity, int victim, float damage, int weapon)
{
	ApplyStatusEffect(entity, victim, "Teslar Shock", 5.0);

	float damageDealt = 10.0 * RaidModeScaling;
	Elemental_AddVoidDamage(victim, entity, RoundToNearest(damageDealt), true, true);	
	return 0.0;
}
bool VoidUnspeakable_TeleToAnyAffectedOnVoid(VoidUnspeakable npc)
{
	if(npc.m_flJumpCooldown < GetGameTime(npc.index))
	{
		static float hullcheckmaxs[3];
		static float hullcheckmins[3];
		hullcheckmaxs = view_as<float>( { 30.0, 30.0, 120.0 } );
		hullcheckmins = view_as<float>( { -30.0, -30.0, 0.0 } );
		for(int EnemyLoop; EnemyLoop < MAXENTITIES; EnemyLoop ++)
		{
			if(IsValidEnemy(npc.index, EnemyLoop, true, true) && VoidArea_TouchingNethersea(EnemyLoop))
			{
				//try to not always teleport to the same guy.
				if(GetRandomFloat(0.0,1.0) > 0.1)
				{
					continue;
				}
				float vecTarget[3]; WorldSpaceCenter(EnemyLoop, vecTarget );	
					
				float PreviousPos[3];
				WorldSpaceCenter(npc.index, PreviousPos);
				//randomly around the target.
				vecTarget[0] += (GetRandomInt(0, 1)) ? -60.0 : 60.0;
				vecTarget[1] += (GetRandomInt(0, 1)) ? -60.0 : 60.0;
				
				bool Succeed = Npc_Teleport_Safe(npc.index, vecTarget, hullcheckmins, hullcheckmaxs, true);
				if(Succeed)
				{
					npc.PlayTeleportSound();
					ParticleEffectAt(PreviousPos, "teleported_blue", 0.5); //This is a permanent particle, gotta delete it manually...
					float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
					ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5); //This is a permanent particle, gotta delete it manually...
					float VecEnemy[3]; WorldSpaceCenter(EnemyLoop, VecEnemy);
					npc.FaceTowards(VecEnemy, 15000.0);
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 1.0; //so they cant instastab you!
					npc.FaceTowards(vecTarget, 15000.0);
					npc.m_flJumpCooldown = GetGameTime(npc.index) + 20.0;
					npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+1.75;
					npc.m_flAttackHappens = 0.0;
					static float flPos[3]; 
					GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
					flPos[2] += 5.0;
					int particle = ParticleEffectAt(flPos, "utaunt_headless_glow", 1.5);
					SetParent(npc.index, particle);
					
					if(IsValidClient(EnemyLoop))
					{
						float HudY = -1.0;
						float HudX = -1.0;
						SetHudTextParams(HudX, HudY, 2.0, 200, 0, 200, 255);
						SetGlobalTransTarget(EnemyLoop);
						ShowSyncHudText(EnemyLoop,  SyncHud_Notifaction, "%t", "Unspeakable Teleport Taunt");
					}
					//Set target
					npc.m_iTarget = npc.index;
					int red = 125;
					int green = 0;
					int blue = 125;
					int Alpha = 200;
					int colorLayer4[4];
					float diameter = float(10 * 4);
					SetColorRGBA(colorLayer4, red, green, blue, Alpha);
					//we set colours of the differnet laser effects to give it more of an effect
					int colorLayer1[4];
					SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, Alpha);
					int glowColor[4];
					SetColorRGBA(glowColor, red, green, blue, Alpha);
					TE_SetupBeamPoints(PreviousPos, WorldSpaceVec, Shared_BEAM_Laser, 0, 0, 0, 0.35, ClampBeamWidth(diameter * 0.5), ClampBeamWidth(diameter * 0.8), 0, 5.0, colorLayer1, 3);
					TE_SendToAll(0.0);
					TE_SetupBeamPoints(PreviousPos, WorldSpaceVec, Shared_BEAM_Laser, 0, 0, 0, 0.35, ClampBeamWidth(diameter * 0.4), ClampBeamWidth(diameter * 0.5), 0, 5.0, colorLayer1, 3);
					TE_SendToAll(0.0);
					TE_SetupBeamPoints(PreviousPos, WorldSpaceVec, Shared_BEAM_Laser, 0, 0, 0, 0.35, ClampBeamWidth(diameter * 0.3), ClampBeamWidth(diameter * 0.3), 0, 5.0, colorLayer1, 3);
					TE_SendToAll(0.0);
					break;
				}
				else
				{
					npc.m_flJumpCooldown = GetGameTime(npc.index) + 0.25;
				}
			}
		}
	}
	return false;
}

#define VOID_MATTER_ASBORBER_RANGE 500.0

bool VoidUnspeakable_MatterAbsorber(VoidUnspeakable npc, float gameTime)
{
	if(npc.m_flVoidMatterAbosorb)
	{
		if(npc.m_flVoidMatterAbosorbInternalCD > gameTime)
		{
			return true;
		}
		npc.m_flVoidMatterAbosorbInternalCD = gameTime + 0.1;
		float flMaxhealth = float(ReturnEntityMaxHealth(npc.index));
		flMaxhealth *= 0.001;
		
		int CurrentPlayersAlive = CountPlayersOnRed(1);
		float HpScalingDecreace = float(CurrentPlayersAlive) / float(npc.m_iPlayerScaledStart);
		flMaxhealth *= HpScalingDecreace;
		if(i_RaidGrantExtra[npc.index] >= 4)
			flMaxhealth *= 1.25;

		float ProjectileLoc[3];
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
		ProjectileLoc[2] += 5.0;
		VoidArea_SpawnNethersea(ProjectileLoc);

		HealEntityGlobal(npc.index, npc.index, flMaxhealth, 1.0, 0.0, HEAL_SELFHEAL);
		float ProjLoc[3];
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", ProjLoc);
		float ProjLocBase[3];
		ProjLocBase = ProjLoc;
		ProjLocBase[2] += 5.0;
		ProjLoc[2] += 70.0;
		
		ProjLoc[0] += GetRandomFloat(-40.0, 40.0);
		ProjLoc[1] += GetRandomFloat(-40.0, 40.0);
		ProjLoc[2] += GetRandomFloat(-15.0, 15.0);
		TE_Particle("healthgained_blu", ProjLoc, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);

		float pos[3];
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
		float cpos[3];
		float velocity[3];
		float ScaleVectorDoMulti = -300.0;
		if(i_RaidGrantExtra[npc.index] >= 2)
			ScaleVectorDoMulti = -400.0;

		for(int EnemyLoop; EnemyLoop < MAXENTITIES; EnemyLoop ++)
		{
			if(IsValidEnemy(npc.index, EnemyLoop, true, true))
			{
				if(Can_I_See_Enemy_Only(npc.index, EnemyLoop) && IsEntityAlive(EnemyLoop))
				{ 	
					GetEntPropVector(EnemyLoop, Prop_Data, "m_vecAbsOrigin", cpos);
					
					MakeVectorFromPoints(pos, cpos, velocity);
					NormalizeVector(velocity, velocity);
					ScaleVector(velocity, ScaleVectorDoMulti);
					if(b_ThisWasAnNpc[EnemyLoop])
					{
						CClotBody npc1 = view_as<CClotBody>(EnemyLoop);
						npc1.SetVelocity(velocity);
					}
					else
					{	
						TeleportEntity(EnemyLoop, NULL_VECTOR, NULL_VECTOR, velocity);
					}
					if(!IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
					{
						int red = 125;
						int green = 0;
						int blue = 125;
						if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
						{
							RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
						}
						int laser;
						
						laser = ConnectWithBeam(npc.index, EnemyLoop, red, green, blue, 3.0, 3.0, 2.35, LASERBEAM);
			
						i_LaserEntityIndex[EnemyLoop] = EntIndexToEntRef(laser);
						//Im seeing a new target, relocate laser particle.
					}
				}
				else
				{
					if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
					{
						RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
					}
				}
			}
			else
			{
				if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
				{
					RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
				}						
			}
		}

		spawnRing_Vectors(ProjLocBase, VOID_MATTER_ASBORBER_RANGE * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 125, 50, 125, 200, 1, 0.3, 5.0, 8.0, 3);	
		spawnRing_Vectors(ProjLocBase, VOID_MATTER_ASBORBER_RANGE * 2.0, 0.0, 0.0, 25.0, "materials/sprites/laserbeam.vmt", 125, 50, 125, 200, 1, 0.3, 5.0, 8.0, 3);	
		if(npc.m_flVoidMatterAbosorbInternalCDBoom > gameTime)
		{
			float damageDealt = 5.0 * RaidModeScaling;
			Explode_Logic_Custom(damageDealt, 0, npc.index, -1, ProjLocBase, VOID_MATTER_ASBORBER_RANGE, 1.0, _, true, 20,_,_,_,VoidUnspeakable_Absorber);
			return true;
		}
		npc.m_flVoidMatterAbosorbInternalCDBoom = gameTime + 0.25;
		if(npc.m_flVoidMatterAbosorb < gameTime)
		{
			npc.m_flRangedArmor = 1.0;
			npc.m_flMeleeArmor = 1.25;	
			for(int EnemyLoop; EnemyLoop < MAXENTITIES; EnemyLoop ++)
			{
				if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
				{
					RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
				}				
			}
			

			npc.m_flVoidMatterAbosorb = 0.0;
		}

		return true;
	}

	if(npc.m_flVoidMatterAbosorbCooldown < gameTime)
	{
		//theres no valid enemy, dont cast.
		if(!IsValidEnemy(npc.index, npc.m_iTarget))
		{
			return false;
		}
		//cant even see one enemy
		if(!Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
		{
			return false;
		}
		//This ability is ready, lets cast it.
		if(npc.m_iChanged_WalkCycle != 4)
		{
			npc.m_bisWalking = false;
			npc.m_iChanged_WalkCycle = 4;
			npc.AddActivityViaSequence("taunt_bubbles");
			npc.SetCycle(0.62);
			npc.SetPlaybackRate(0.2);	
			NPC_StopPathing(npc.index);
			npc.m_bPathing = false;
			npc.m_flSpeed = 0.0;
			EmitSoundToAll("mvm/mvm_cpoint_klaxon.wav", _, _, _, _, 1.0, 70);	
			EmitSoundToAll("mvm/mvm_cpoint_klaxon.wav", _, _, _, _, 1.0, 70);	
			if(IsValidEntity(npc.m_iWearable4))
			{
				AcceptEntityInput(npc.m_iWearable4, "Disable");
			}
		}
		float ProjectileLoc[3];
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
		ProjectileLoc[2] += 5.0;
		VoidArea_SpawnNethersea(ProjectileLoc);
		npc.m_flRangedArmor = 0.75;
		npc.m_flMeleeArmor = 1.5;	

		npc.m_flVoidMatterAbosorb = gameTime + 4.5;
		npc.m_flDoingAnimation = gameTime + 5.0;
		npc.m_flVoidMatterAbosorbInternalCD = gameTime + 2.0;
		npc.m_flVoidMatterAbosorbCooldown = gameTime + 35.0;
		if(i_RaidGrantExtra[npc.index] >= 4)
			npc.m_flVoidMatterAbosorbCooldown = gameTime + 28.0;

		return true;
	}

	return false;
}

public void VoidUnspeakable_NPCDeath(int entity)
{
	VoidUnspeakable npc = view_as<VoidUnspeakable>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}

	if(!BossrushLogic)
	{
		if(FogEntity != INVALID_ENT_REFERENCE)
		{
			int entity1 = EntRefToEntIndex(FogEntity);
			if(entity1 > MaxClients)
				RemoveEntity(entity1);
			
			FogEntity = INVALID_ENT_REFERENCE;
		}
	}
	for(int EnemyLoop; EnemyLoop < MAXENTITIES; EnemyLoop ++)
	{
		if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
		{
			RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
		}				
	}
		
	if(IsValidEntity(npc.m_iWearable8))
		RemoveEntity(npc.m_iWearable8);
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

void VoidUnspeakableSelfDefense(VoidUnspeakable npc, float gameTime, int target, float distance)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
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
						target = i_EntitiesHitAoeSwing_NpcSwing[counter];
						float vecHit[3];
						WorldSpaceCenter(target, vecHit);
									
						float damageDealt = 30.0 * RaidModeScaling;

						SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);	
						Elemental_AddVoidDamage(target, npc.index, RoundToNearest(damageDealt * 0.15), true, true);							
						
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
						}
									
						if(!Knocked)
							Custom_Knockback(npc.index, target, 150.0, true); 
					}
				}
			}
			if(PlaySound)
			{
				npc.PlayMeleeHitSound();
			}
		}
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
		{
			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				if(npc.m_flVoidRapidMelee < gameTime)
				{
					npc.m_flAttackHappens_bullshit = GetGameTime(npc.index) + 1.0;
					static float flPos[3]; 
					GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
					flPos[2] += 5.0;
					int particle = ParticleEffectAt(flPos, "utaunt_headless_glow", 1.0);
					SetParent(npc.index, particle);
					npc.m_flVoidRapidMelee = GetGameTime(npc.index) + 7.5;
				}

				if(npc.m_flAttackHappens_bullshit > gameTime)
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE",_,_,_,2.5);
					npc.m_flAttackHappens = gameTime + 0.1;
					npc.m_flDoingAnimation = gameTime + 0.1;
					npc.m_flNextMeleeAttack = gameTime + 0.3;
				}
				else
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE",_,_,_,0.75);		
					npc.m_flAttackHappens = gameTime + 0.35;
					npc.m_flDoingAnimation = gameTime + 0.35;
					npc.m_flNextMeleeAttack = gameTime + 1.2;
				}
			}
		}
	}

	if(npc.m_flDoingAnimation < gameTime && gameTime > npc.m_flVoidPillarAttack && i_RaidGrantExtra[npc.index] >= 2)
	{
		
		int Enemy_I_See;
							
		Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				
		if(IsValidEnemy(npc.index, Enemy_I_See))
		{
			
			npc.m_flVoidPillarAttack = gameTime + 4.5;
			npc.m_flDoingAnimation = gameTime + 0.35;
			if(npc.m_flMaxDeath)
			{
				npc.AddGesture("ACT_MP_THROW", .SetGestureSpeed = 3.0);
				npc.m_flVoidPillarAttack = gameTime + 0.4;
			}
			else
			{
				npc.AddGesture("ACT_MP_THROW");
			}

			UnderTides npcGetInfo = view_as<UnderTides>(npc.index);
			int enemy[MAXENTITIES];
			GetHighDefTargets(npcGetInfo, enemy, sizeof(enemy), true, false, npc.index, (700.0 * 700.0));
			ResetTEStatusSilvester();
			SetSilvesterPillarColour({125, 0, 125, 200});
			float damageDealt = 35.0 * RaidModeScaling;
			float ang_Look[3];
			float PosLoc[3];
			GetEntPropVector(Enemy_I_See, Prop_Send, "m_angRotation", ang_Look);
			WorldSpaceCenter(npc.index, PosLoc);

			int red = 125;
			int green = 0;
			int blue = 125;
			int Alpha = 200;
			
			for(int i; i < sizeof(enemy); i++)
			{
				if(enemy[i])
				{
					float ProjectileLoc[3];
					PredictSubjectPositionForProjectiles(npcGetInfo, enemy[i], 290.0,_,ProjectileLoc);
					
					int colorLayer4[4];
					float diameter = float(10 * 4);
					SetColorRGBA(colorLayer4, red, green, blue, Alpha);
					//we set colours of the differnet laser effects to give it more of an effect
					int colorLayer1[4];
					SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, Alpha);
					int glowColor[4];
					SetColorRGBA(glowColor, red, green, blue, Alpha);
					TE_SetupBeamPoints(PosLoc, ProjectileLoc, Shared_BEAM_Laser, 0, 0, 0, 0.35, ClampBeamWidth(diameter * 0.5), ClampBeamWidth(diameter * 0.8), 0, 5.0, colorLayer1, 3);
					TE_SendToAll(0.0);
					TE_SetupBeamPoints(PosLoc, ProjectileLoc, Shared_BEAM_Laser, 0, 0, 0, 0.35, ClampBeamWidth(diameter * 0.4), ClampBeamWidth(diameter * 0.5), 0, 5.0, colorLayer1, 3);
					TE_SendToAll(0.0);
					TE_SetupBeamPoints(PosLoc, ProjectileLoc, Shared_BEAM_Laser, 0, 0, 0, 0.35, ClampBeamWidth(diameter * 0.3), ClampBeamWidth(diameter * 0.3), 0, 5.0, colorLayer1, 3);
					TE_SendToAll(0.0);

					float QuakeSize = 1.2;
					float ReactionTime = 1.1;
					if(i_RaidGrantExtra[npc.index] >= 4)
					{
						QuakeSize = 1.5;
						ReactionTime = 0.9;
					}
					Silvester_Damaging_Pillars_Ability(npc.index,
					damageDealt,				 	//damage
					0, 	//how many
					ReactionTime,									//Delay untill hit
					1.0,									//Extra delay between each
					ang_Look 								/*2 dimensional plane*/,
					ProjectileLoc,
					0.35,									//volume
					QuakeSize);									//PillarStartingSize
				}
			}
		}
	}
}


public void VoidUnspeakableWin(int entity)
{
	i_RaidGrantExtra[entity] = RAIDITEM_INDEX_WIN_COND;
	func_NPCThink[entity] = INVALID_FUNCTION;
	if(AlreadySaidWin)
		return;

	AlreadySaidWin = true;
	//b_NpcHasDied[client]
	CPrintToChatAll("{purple}After detroying everyrhing here, it leaves to plan another attack.");
	CPrintToChatAll("{crimson}At the rest of Irln.");
}


void VoidUnspeakable_DeathAnimationKahml(VoidUnspeakable npc, float gameTime)
{
	float flMaxhealth = float(ReturnEntityMaxHealth(npc.index));
	flMaxhealth *= 0.01;
	HealEntityGlobal(npc.index, npc.index, flMaxhealth, 35.9, 0.0, HEAL_SELFHEAL);
	//rapid self heal to indicate power!
	RaidModeScaling += GetRandomFloat(0.8, 2.2);
	if(npc.m_iChanged_WalkCycle != 8)
	{
		npc.m_bisWalking = false;
		npc.m_iChanged_WalkCycle = 8;
		npc.AddActivityViaSequence("taunt_bubbles");
		npc.SetCycle(0.62);
		npc.SetPlaybackRate(0.0);	
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flSpeed = 0.0;
		if(IsValidEntity(npc.m_iWearable4))
		{
			AcceptEntityInput(npc.m_iWearable4, "Disable");
		}
	}
	if(npc.m_flDeathAnimationCD < gameTime)
	{
		float ProjLoc[3];
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", ProjLoc);
		spawnRing_Vectors(ProjLoc, 1.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 125, 50, 125, 200, 1, 2.0, 5.0, 8.0, 3, VOID_MATTER_ASBORBER_RANGE * 2.0);	
		spawnRing_Vectors(ProjLoc, 1.0, 0.0, 0.0, 25.0, "materials/sprites/laserbeam.vmt", 125, 50, 125, 200, 1, 2.0, 5.0, 8.0, 3, VOID_MATTER_ASBORBER_RANGE * 2.0);	
		if(npc.m_flVoidMatterAbosorbInternalCDBoom > gameTime)
		if(IsValidEntity(npc.m_iTarget))
		{
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
			npc.FaceTowards(vecTarget, 15000.0);
		}
		npc.m_flDeathAnimationCD = gameTime + 1.5;

		switch(i_RaidGrantExtra[npc.index])
		{
			case 11:
			{
				CPrintToChatAll("{purple}FOOLISH MORTALS, YOU THINK YOU CAN STOP US");
			}
			case 12:
			{
				CPrintToChatAll("{purple}THERE'S NOTHING YOU CAN DO ANYMORE");
			}
			case 13:
			{
				CPrintToChatAll("{purple}WITNESS THE END OF ALL TIMES, RIGHT HERE AND NOW");
			}
			case 14:
			{
				CPrintToChatAll("{purple}BECOME ONE WITH THE VOID");
			}
		}
		i_RaidGrantExtra[npc.index]++;
	}
}