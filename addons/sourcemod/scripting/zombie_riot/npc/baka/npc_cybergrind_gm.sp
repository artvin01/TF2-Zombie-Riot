#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"weapons/rescue_ranger_teleport_receive_01.wav",
	"weapons/rescue_ranger_teleport_receive_02.wav",
};

static ArrayList Voting;
static int VotedFor[MAXPLAYERS];
static float VoteEndTime;
int CyberGrind_Difficulty;
int CyberGrind_InternalDifficulty;
bool CyberVote;
static bool Grigori_Refresh=false;
static bool Grigori_RefreshTwo=false;
static int GrigoriMaxSellsItems=-1;
static bool CGBreak;

void CyberGrindGM_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Mr.V");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_cybergrind_gm");
	strcopy(data.Icon, sizeof(data.Icon), "rnd_enemy");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Special;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundCustom("#zombiesurvival/altwaves_and_blitzkrieg/music/dm_loop1.mp3");
	PrecacheSoundCustom("#zombiesurvival/expidonsa_waves/wave_30_soldine.mp3");
	PrecacheSoundCustom("#zombiesurvival/ruina/wave60.mp3");
	PrecacheSoundCustom("#zombiesurvival/ruina/wave45.mp3");
	PrecacheSoundCustom("#zombiesurvival/victoria_1/wave_20.mp3");
	PrecacheSoundCustom("#zombiesurvival/expidonsa_waves/wave_60_music_1.mp3");
	PrecacheSoundCustom("#zombiesurvival/expidonsa_waves/raid_sensal_group.mp3");
	PrecacheSoundCustom("#zombiesurvival/ruina/raid_ruina_trio.mp3");
	PrecacheSoundCustom("#zombiesurvival/victoria_1/wave_45.mp3");
	PrecacheSoundCustom(RAIDBOSS_TWIRL_THEME);
	PrecacheModel("models/items/tf_gift.mdl", true);
	PrecacheModel("models/player/spy.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return CyberGrindGM(vecPos, vecAng, ally, data);
}

void ResetCyberGrindGMLogic()
{
	CyberVote=false;
	CGBreak=true;
}

methodmap CyberGrindGM < CClotBody
{
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	property float m_flCoolDown
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flAddRiadTime
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}

	public CyberGrindGM(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		CyberGrindGM npc = view_as<CyberGrindGM>(CClotBody(vecPos, vecAng, "models/player/spy.mdl", "1.0", "12000", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.AddActivityViaSequence("selectionMenu_Idle");
		npc.SetCycle(0.01);
		
		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		b_NoKillFeed[npc.index] = true;
		if(!StrContains(data, "nextwave"))
		{
			func_NPCDeath[npc.index] = INVALID_FUNCTION;
			func_NPCOnTakeDamage[npc.index] = INVALID_FUNCTION;
			func_NPCThink[npc.index] = INVALID_FUNCTION;
			
			for(int target = 1; target <= MaxClients; target++)
			{
				if(IsValidClient(target))
					Ammo_Count_Used[target] -= (CyberGrind_InternalDifficulty>2 ? 20 : 15);
			}
			
			b_NpcForcepowerupspawn[npc.index] = 0;
			i_RaidGrantExtra[npc.index] = 0;
			b_DissapearOnDeath[npc.index] = true;
			b_DoGibThisNpc[npc.index] = true;
			SmiteNpcToDeath(npc.index);
			return npc;
		}
		else if(!StrContains(data, "go_wave_"))
		{
			char buffers[3][64];
			ExplodeString(data, ";", buffers, sizeof(buffers), sizeof(buffers[]));
			ReplaceString(buffers[0], 64, "go_wave_", "");
			func_NPCDeath[npc.index] = INVALID_FUNCTION;
			func_NPCOnTakeDamage[npc.index] = INVALID_FUNCTION;
			func_NPCThink[npc.index] = INVALID_FUNCTION;
			
			for(int target = 1; target <= MaxClients; target++)
			{
				if(IsValidClient(target))
					Ammo_Count_Used[target] -= (CyberGrind_InternalDifficulty>2 ? 20 : 15);
			}
			Waves_ClearWaves();
			CurrentRound = StringToInt(buffers[0])-1;
			CurrentWave = -1;
			Waves_Progress();
			
			b_NpcForcepowerupspawn[npc.index] = 0;
			i_RaidGrantExtra[npc.index] = 0;
			b_DissapearOnDeath[npc.index] = true;
			b_DoGibThisNpc[npc.index] = true;
			SmiteNpcToDeath(npc.index);
			return npc;
		}
		else if(!StrContains(data, "wgoto_"))
		{
			func_NPCDeath[npc.index] = INVALID_FUNCTION;
			func_NPCOnTakeDamage[npc.index] = INVALID_FUNCTION;
			func_NPCThink[npc.index] = INVALID_FUNCTION;
			
			for(int target = 1; target <= MaxClients; target++)
			{
				if(IsValidClient(target))
					Ammo_Count_Used[target] -= (CyberGrind_InternalDifficulty>2 ? 20 : 15);
			}
			
			int DifficultyGotoWave[5];
			static char countext[5][256];
			int count = ExplodeString(data, ";", countext, sizeof(countext), sizeof(countext[]));
			for(int i = 0; i < count; i++)
			{
				if(i>=count)break;
				ReplaceString(countext[i], sizeof(countext[]), "wgoto_", "");
				DifficultyGotoWave[i] = StringToInt(countext[i])-1;
				if(DifficultyGotoWave[i]<0)DifficultyGotoWave[i]=0;
			}
			
			int iNextSetWave;
			switch(CyberGrind_InternalDifficulty)
			{
				case 1:iNextSetWave=DifficultyGotoWave[0]; //CyberGrind_Normal
				case 2, 3:iNextSetWave=DifficultyGotoWave[1]; //CyberGrind_Hard, CyberGrind_Expert
				case 4:iNextSetWave=DifficultyGotoWave[2]; //CyberGrind_EX_Hard
				case 5:iNextSetWave=DifficultyGotoWave[3]; //CyberGrind_Fast
				case 6:iNextSetWave=DifficultyGotoWave[4]; //CyberGrind_EX_Fast
				default:iNextSetWave=DifficultyGotoWave[0]; //CyberGrind_Normal
			}
			Waves_ClearWaves();
			CurrentRound = iNextSetWave;
			CurrentWave = -1;
			Waves_Progress();
			
			b_NpcForcepowerupspawn[npc.index] = 0;
			i_RaidGrantExtra[npc.index] = 0;
			b_DissapearOnDeath[npc.index] = true;
			b_DoGibThisNpc[npc.index] = true;
			SmiteNpcToDeath(npc.index);
			return npc;
		}
		else if(!StrContains(data, "set_wavelimit"))
		{
			func_NPCDeath[npc.index] = INVALID_FUNCTION;
			func_NPCOnTakeDamage[npc.index] = INVALID_FUNCTION;
			func_NPCThink[npc.index] = INVALID_FUNCTION;
			
			char buffers[3][64];
			ExplodeString(data, ";", buffers, sizeof(buffers), sizeof(buffers[]));
			ReplaceString(buffers[0], 64, "set_wavelimit", "");
			
			WaveStart_SubWaveStart(GetGameTime() + StringToFloat(buffers[0]));
			
			b_NpcForcepowerupspawn[npc.index] = 0;
			i_RaidGrantExtra[npc.index] = 0;
			b_DissapearOnDeath[npc.index] = true;
			b_DoGibThisNpc[npc.index] = true;
			SmiteNpcToDeath(npc.index);
			return npc;
		}
		else if(!StrContains(data, "set_raidlimit"))
		{
			func_NPCDeath[npc.index] = INVALID_FUNCTION;
			func_NPCOnTakeDamage[npc.index] = INVALID_FUNCTION;
			func_NPCThink[npc.index] = CyberGrindGM_OverrideMusic;
			
			char buffers[3][64];
			ExplodeString(data, ";", buffers, sizeof(buffers), sizeof(buffers[]));
			ReplaceString(buffers[0], 64, "set_raidlimit", "");
			
			npc.m_flAddRiadTime = StringToFloat(buffers[0]);
			npc.m_iOverlordComboAttack = 100;
			npc.m_flCoolDown = GetGameTime() + 0.5;
			return npc;
		}
		else if(!StrContains(data, "difficulty"))
		{
			func_NPCDeath[npc.index] = INVALID_FUNCTION;
			func_NPCOnTakeDamage[npc.index] = INVALID_FUNCTION;
			func_NPCThink[npc.index] = INVALID_FUNCTION;
			
			if(CyberGrind_InternalDifficulty>2)
			{
				switch(GetRandomInt(0, 8))
				{
					case 0: NPC_SpawnNext(true, true, 0);
					case 1: NPC_SpawnNext(true, true, 1);
					case 2: NPC_SpawnNext(true, true, 2);
					case 3: NPC_SpawnNext(true, true, 4);
					case 4: NPC_SpawnNext(true, true, 5);
					case 5: NPC_SpawnNext(true, true, 6);
					case 6: NPC_SpawnNext(true, true, 7);
					case 7: NPC_SpawnNext(true, true, 9);
					case 8: NPC_SpawnNext(true, true, 10);
				}
			}
			WaveStart_SubWaveStart(GetGameTime() + 3000.0);
			b_NpcForcepowerupspawn[npc.index] = 0;
			i_RaidGrantExtra[npc.index] = 0;
			b_DissapearOnDeath[npc.index] = true;
			b_DoGibThisNpc[npc.index] = true;
			SmiteNpcToDeath(npc.index);
			return npc;
		}
		else if(!StrContains(data, "giverevive"))
		{
			func_NPCDeath[npc.index] = INVALID_FUNCTION;
			func_NPCOnTakeDamage[npc.index] = INVALID_FUNCTION;
			func_NPCThink[npc.index] = INVALID_FUNCTION;
			
			GiveOneRevive(false);
			Music_EndLastmann(true);
			LastMann = false;
			applied_lastmann_buffs_once = false;

			for(int i=0 ; i < MaxClients ; i++)
			{
				if(IsValidClient(i) && IsClientInGame(i) && IsPlayerAlive(i) && TeutonType[i] == TEUTON_NONE && dieingstate[i] == 0)
				{
					SDKHooks_UpdateMarkForDeath(i, true);
					SDKHooks_UpdateMarkForDeath(i, false);
					TF2_AddCondition(i, TFCond_SpeedBuffAlly, 2.0);
					int maxhealth = SDKCall_GetMaxHealth(i);
					if(GetClientHealth(i)<maxhealth)
						SetEntityHealth(i, maxhealth);
					GiveArmorViaPercentage(i, 0.5, 1.0);
					SetGlobalTransTarget(i);
					CPrintToChat(i, "%t", "Adrenalive rushes engage");
					GiveCompleteInvul(i, 3.5);
				}
			}
			
			b_NpcForcepowerupspawn[npc.index] = 0;
			i_RaidGrantExtra[npc.index] = 0;
			b_DissapearOnDeath[npc.index] = true;
			b_DoGibThisNpc[npc.index] = true;
			SmiteNpcToDeath(npc.index);
			return npc;
		}
		else if(!StrContains(data, "we_got_soldine"))
		{
			func_NPCDeath[npc.index] = INVALID_FUNCTION;
			func_NPCOnTakeDamage[npc.index] = INVALID_FUNCTION;
			func_NPCThink[npc.index] = INVALID_FUNCTION;
			
			for(int target = 1; target <= MaxClients; target++)
			{
				if(IsClientInGame(target) && !b_IsPlayerABot[target])
					Music_Stop_All(target);
			}
			RemoveAllCustomMusic();
			
			MusicEnum music;
			strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/expidonsa_waves/wave_30_soldine.mp3");
			music.Time = 187;
			music.Volume = 1.0;
			music.Custom = true;
			strcopy(music.Name, sizeof(music.Name), "The Game");
			strcopy(music.Artist, sizeof(music.Artist), "Disturbed");
			Music_SetRaidMusic(music);
			
			b_NpcForcepowerupspawn[npc.index] = 0;
			i_RaidGrantExtra[npc.index] = 0;
			b_DissapearOnDeath[npc.index] = true;
			b_DoGibThisNpc[npc.index] = true;
			SmiteNpcToDeath(npc.index);
			return npc;
		}
		else if(!StrContains(data, "victoria_wave_20_bgm"))
		{
			func_NPCDeath[npc.index] = INVALID_FUNCTION;
			func_NPCOnTakeDamage[npc.index] = INVALID_FUNCTION;
			func_NPCThink[npc.index] = INVALID_FUNCTION;
			
			for(int target = 1; target <= MaxClients; target++)
			{
				if(IsClientInGame(target) && !b_IsPlayerABot[target])
					Music_Stop_All(target);
			}
			RemoveAllCustomMusic();
			
			MusicEnum music;
			strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/victoria_1/wave_20.mp3");
			music.Time = 240;
			music.Volume = 1.7;
			music.Custom = true;
			strcopy(music.Name, sizeof(music.Name), "Come Catastrophes or Wakes of Vultures Battle Theme");
			strcopy(music.Artist, sizeof(music.Artist), "Monster Siren Records");
			Music_SetRaidMusic(music);
			
			b_NpcForcepowerupspawn[npc.index] = 0;
			i_RaidGrantExtra[npc.index] = 0;
			b_DissapearOnDeath[npc.index] = true;
			b_DoGibThisNpc[npc.index] = true;
			SmiteNpcToDeath(npc.index);
			return npc;
		}
		else if(!StrContains(data, "victoria_wave_30_bgm"))
		{
			func_NPCDeath[npc.index] = INVALID_FUNCTION;
			func_NPCOnTakeDamage[npc.index] = INVALID_FUNCTION;
			func_NPCThink[npc.index] = INVALID_FUNCTION;
			
			for(int target = 1; target <= MaxClients; target++)
			{
				if(IsClientInGame(target) && !b_IsPlayerABot[target])
					Music_Stop_All(target);
			}
			RemoveAllCustomMusic();
			
			MusicEnum music;
			strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/victoria_1/wave_45.mp3");
			music.Time = 185;
			music.Volume =2.0;
			music.Custom = true;
			strcopy(music.Name, sizeof(music.Name), "Operation Lucent Arrowhead Boss Battle Theme");
			strcopy(music.Artist, sizeof(music.Artist), "Monster Siren Records");
			Music_SetRaidMusic(music);
			
			b_NpcForcepowerupspawn[npc.index] = 0;
			i_RaidGrantExtra[npc.index] = 0;
			b_DissapearOnDeath[npc.index] = true;
			b_DoGibThisNpc[npc.index] = true;
			SmiteNpcToDeath(npc.index);
			return npc;
		}
		else if(!StrContains(data, "ruina_wave_45_bgm"))
		{
			func_NPCDeath[npc.index] = INVALID_FUNCTION;
			func_NPCOnTakeDamage[npc.index] = INVALID_FUNCTION;
			func_NPCThink[npc.index] = INVALID_FUNCTION;
			
			for(int target = 1; target <= MaxClients; target++)
			{
				if(IsClientInGame(target) && !b_IsPlayerABot[target])
					Music_Stop_All(target);
			}
			RemoveAllCustomMusic();
			
			MusicEnum music;
			strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/ruina/wave45.mp3");
			music.Time = 284;
			music.Volume = 1.3;
			music.Custom = true;
			strcopy(music.Name, sizeof(music.Name), "Nuclear Fusion (Electro Remix)");
			strcopy(music.Artist, sizeof(music.Artist), "JustSomeRandomMusician");
			Music_SetRaidMusic(music);
			
			b_NpcForcepowerupspawn[npc.index] = 0;
			i_RaidGrantExtra[npc.index] = 0;
			b_DissapearOnDeath[npc.index] = true;
			b_DoGibThisNpc[npc.index] = true;
			SmiteNpcToDeath(npc.index);
			return npc;
		}
		else if(!StrContains(data, "zenzal_60_bgm"))
		{
			func_NPCDeath[npc.index] = INVALID_FUNCTION;
			func_NPCOnTakeDamage[npc.index] = INVALID_FUNCTION;
			func_NPCThink[npc.index] = INVALID_FUNCTION;
			
			for(int target = 1; target <= MaxClients; target++)
			{
				if(IsClientInGame(target) && !b_IsPlayerABot[target])
					Music_Stop_All(target);
			}
			RemoveAllCustomMusic();
			
			MusicEnum music;
			strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/expidonsa_waves/wave_60_music_1.mp3");
			music.Time = 167;
			music.Volume = 1.2;
			music.Custom = true;
			strcopy(music.Name, sizeof(music.Name), "Half-Life - Hard Technology Rock [Remix]");
			strcopy(music.Artist, sizeof(music.Artist), "Vandoorea");
			Music_SetRaidMusic(music);
			
			b_NpcForcepowerupspawn[npc.index] = 0;
			i_RaidGrantExtra[npc.index] = 0;
			b_DissapearOnDeath[npc.index] = true;
			b_DoGibThisNpc[npc.index] = true;
			SmiteNpcToDeath(npc.index);
			return npc;
		}
		else if(!StrContains(data, "powerful_wait"))
		{
			func_NPCDeath[npc.index] = INVALID_FUNCTION;
			func_NPCOnTakeDamage[npc.index] = INVALID_FUNCTION;
			func_NPCThink[npc.index] = INVALID_FUNCTION;
			
			for(int target = 1; target <= MaxClients; target++)
			{
				if(IsClientInGame(target) && !b_IsPlayerABot[target])
					Music_Stop_All(target);
			}
			RemoveAllCustomMusic();
			
			MusicEnum music;
			strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/ruina/wave60.mp3");
			music.Time = 257;
			music.Volume = 1.0;
			music.Custom = true;
			strcopy(music.Name, sizeof(music.Name), "[RoseChain (Satori Maiden ~ 3rd Eye)]");
			strcopy(music.Artist, sizeof(music.Artist), "maritumix/まりつみ");
			Music_SetRaidMusic(music);
			
			b_NpcForcepowerupspawn[npc.index] = 0;
			i_RaidGrantExtra[npc.index] = 0;
			b_DissapearOnDeath[npc.index] = true;
			b_DoGibThisNpc[npc.index] = true;
			SmiteNpcToDeath(npc.index);
			return npc;
		}
		else if(!StrContains(data, "the_expidonsa_trio_bgm"))
		{
			func_NPCDeath[npc.index] = INVALID_FUNCTION;
			func_NPCOnTakeDamage[npc.index] = INVALID_FUNCTION;
			func_NPCThink[npc.index] = CyberGrindGM_OverrideMusic;
			npc.m_iOverlordComboAttack = 0;
			npc.m_flCoolDown = GetGameTime() + 0.5;
			return npc;
		}
		else if(!StrContains(data, "the_ruina_trio_bgm"))
		{
			func_NPCDeath[npc.index] = INVALID_FUNCTION;
			func_NPCOnTakeDamage[npc.index] = INVALID_FUNCTION;
			func_NPCThink[npc.index] = CyberGrindGM_OverrideMusic;
			npc.m_iOverlordComboAttack = 1;
			npc.m_flCoolDown = GetGameTime() + 0.5;
			return npc;
		}
		else if(!StrContains(data, "xeno_duo"))
		{
			func_NPCDeath[npc.index] = INVALID_FUNCTION;
			func_NPCOnTakeDamage[npc.index] = INVALID_FUNCTION;
			func_NPCThink[npc.index] = CyberGrindGM_OverrideMusic;
			npc.m_iOverlordComboAttack = 2;
			npc.m_flCoolDown = GetGameTime() + 0.5;
			return npc;
		}
		else if(!StrContains(data, "world_end"))
		{
			func_NPCDeath[npc.index] = INVALID_FUNCTION;
			func_NPCOnTakeDamage[npc.index] = INVALID_FUNCTION;
			func_NPCThink[npc.index] = CyberGrindGM_OverrideMusic;
			npc.m_iOverlordComboAttack = 3;
			npc.m_flCoolDown = GetGameTime() + 0.5;
			return npc;
		}
		else if(!StrContains(data, "is_twirl"))
		{
			func_NPCDeath[npc.index] = INVALID_FUNCTION;
			func_NPCOnTakeDamage[npc.index] = INVALID_FUNCTION;
			func_NPCThink[npc.index] = INVALID_FUNCTION;
			
			for(int target = 1; target <= MaxClients; target++)
			{
				if(IsClientInGame(target) && !b_IsPlayerABot[target])
					Music_Stop_All(target);
			}
			RemoveAllCustomMusic();
			
			MusicEnum music;
			strcopy(music.Path, sizeof(music.Path), RAIDBOSS_TWIRL_THEME);
			music.Time = 285;
			music.Volume = 2.0;
			music.Custom = true;
			strcopy(music.Name, sizeof(music.Name), "Night life in Ruina");
			strcopy(music.Artist, sizeof(music.Artist), "Grandpa Bard");
			Music_SetRaidMusic(music);
			
			b_NpcForcepowerupspawn[npc.index] = 0;
			i_RaidGrantExtra[npc.index] = 0;
			b_DissapearOnDeath[npc.index] = true;
			b_DoGibThisNpc[npc.index] = true;
			SmiteNpcToDeath(npc.index);
			return npc;
		}
		else if(!StrContains(data, "Worlds_End"))
		{
			func_NPCDeath[npc.index] = INVALID_FUNCTION;
			func_NPCOnTakeDamage[npc.index] = INVALID_FUNCTION;
			func_NPCThink[npc.index] = INVALID_FUNCTION;
			
			for(int target = 1; target <= MaxClients; target++)
			{
				if(IsClientInGame(target) && !b_IsPlayerABot[target])
					Music_Stop_All(target);
			}
			RemoveAllCustomMusic();
			
			MusicEnum music;
			strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/altwaves_and_blitzkrieg/music/dm_loop1.mp3");
			music.Time = 357;
			music.Volume = 2.2;
			music.Custom = true;
			strcopy(music.Name, sizeof(music.Name), "感情の魔天楼　～ World's End");
			strcopy(music.Artist, sizeof(music.Artist), "Demetori");
			Music_SetRaidMusic(music);
			
			b_NpcForcepowerupspawn[npc.index] = 0;
			i_RaidGrantExtra[npc.index] = 0;
			b_DissapearOnDeath[npc.index] = true;
			b_DoGibThisNpc[npc.index] = true;
			SmiteNpcToDeath(npc.index);
			return npc;
		}
		else if(!StrContains(data, "final_item"))
		{
			func_NPCDeath[npc.index] = CyberGrindGM_NPCDeath;
			func_NPCOnTakeDamage[npc.index] = CyberGrindGM_OnTakeDamage;
			func_NPCThink[npc.index] = CyberGrindGM_Final_Item;
			
			npc.m_iBleedType = BLEEDTYPE_NORMAL;
			npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
			npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
			
			//IDLE
			b_ThisNpcIsImmuneToNuke[npc.index] = true;
			npc.m_iState = 0;
			npc.m_flGetClosestTargetTime = 0.0;
			npc.StartPathing();
			npc.m_flSpeed = 0.0;
			npc.m_iOverlordComboAttack = 0;
			npc.m_flNextMeleeAttack = 0.0;
			npc.m_flNextRangedAttack = GetGameTime() + 1.0;
			CyberGrind_Difficulty = 0;
			npc.Anger = true;
			CGBreak=false;
		
			int skin = 1;
			SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

			npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/spy/spr18_assassins_attire/spr18_assassins_attire.mdl");

			npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/spy/spy_hat.mdl");

			SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
			SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
			return npc;
		}
		else if(!StrContains(data, "cybergrind_sells_mode"))
		{
			func_NPCDeath[npc.index] = CyberGrindGM_NPCDeath;
			func_NPCOnTakeDamage[npc.index] = CyberGrindGM_OnTakeDamage;
			func_NPCThink[npc.index] = CyberGrindGM_Instantkill;
			
			Grigori_Refresh=false;
			Grigori_RefreshTwo=false;
			GrigoriMaxSellsItems=-1;
			
			static char countext[20][1024];
			int count = ExplodeString(data, ";", countext, sizeof(countext), sizeof(countext[]));
			for(int i = 0; i < count; i++)
			{
				if(!StrContains(countext[i], "grigori_refresh_store"))Grigori_Refresh=true;
				else if(!StrContains(countext[i], "grigori_sells_items_max"))
				{
					ReplaceString(countext[i], 1024, "grigori_sells_items_max", "");
					int value = StringToInt(countext[i]);
					GrigoriMaxSellsItems = value;
				}
				else if(!StrContains(countext[i], "grigori_refresh_storetwo"))Grigori_RefreshTwo=true;
			}
			
			npc.m_flNextRangedAttack = GetGameTime() + 1.0;
			int skin = 1;
			SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

			npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/spy/spr18_assassins_attire/spr18_assassins_attire.mdl");

			npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/spy/spy_hat.mdl");

			SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
			SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
			return npc;
		}
		else if(!StrContains(data, "cybergrind_vote_mode"))
		{
			func_NPCDeath[npc.index] = CyberGrindGM_NPCDeath;
			func_NPCOnTakeDamage[npc.index] = CyberGrindGM_OnTakeDamage;
			func_NPCThink[npc.index] = CyberGrindGM_ClotThink;
			func_NPCFuncWin[npc.index] =  view_as<Function>(Raidmode_Expidonsa_Sensal_Win);
			
			npc.m_iBleedType = BLEEDTYPE_NORMAL;
			npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
			npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
			
			b_ThisNpcIsImmuneToNuke[npc.index] = true;
			npc.m_iState = 0;
			npc.m_flGetClosestTargetTime = 0.0;
			npc.StartPathing();
			npc.m_flSpeed = 0.0;
			npc.m_iOverlordComboAttack = 0;
			npc.m_flNextMeleeAttack = 0.0;
			npc.m_flNextRangedAttack = GetGameTime() + 1.0;
			CyberGrind_Difficulty = 0;
			npc.Anger = true;
			CGBreak = false;
			
			int skin = 1;
			SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

			npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/spy/spr18_assassins_attire/spr18_assassins_attire.mdl");

			npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/spy/spy_hat.mdl");

			SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
			return npc;
		}
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
}
static void CyberGrindGM_OverrideMusic(int iNPC)
{
	CyberGrindGM npc = view_as<CyberGrindGM>(iNPC);
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	if(npc.m_flNextThinkTime > gameTime)
		return;
	npc.m_flNextThinkTime = gameTime + 0.1;
	if(npc.m_flCoolDown < gameTime)
	{
		for(int target = 1; target <= MaxClients; target++)
		{
			if(IsClientInGame(target) && !b_IsPlayerABot[target])
				Music_Stop_All(target);
		}
		RemoveAllCustomMusic();
		switch(npc.m_iOverlordComboAttack)
		{
			case 0:
			{
				MusicEnum music;
				strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/expidonsa_waves/raid_sensal_group.mp3");
				music.Time = 172;
				music.Volume = 2.0;
				music.Custom = true;
				strcopy(music.Name, sizeof(music.Name), "Rock Orchestra 2");
				strcopy(music.Artist, sizeof(music.Artist), "Goukisan");
				Music_SetRaidMusic(music);
			}
			case 1:
			{
				MusicEnum music;
				strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/ruina/raid_ruina_trio.mp3");
				music.Time = 164;
				music.Volume = 2.0;
				music.Custom = true;
				strcopy(music.Name, sizeof(music.Name), "Cyberfantasia");
				strcopy(music.Artist, sizeof(music.Artist), "tn-shi");
				Music_SetRaidMusic(music);
			}
			case 2:
			{
				Music_SetRaidMusicSimple("#zombiesurvival/xeno_raid/mr_duo_battle.mp3", 171, true, 1.3);
			}
			case 3:
			{
				MusicEnum music;
				strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/altwaves_and_blitzkrieg/music/dm_loop1.mp3");
				music.Time = 356;
				music.Volume = 2.0;
				music.Custom = true;
				strcopy(music.Name, sizeof(music.Name), "感情の魔天楼　～ World's End");
				strcopy(music.Artist, sizeof(music.Artist), "Demetori");
				Music_SetRaidMusic(music);
			}
			case 100: RaidModeTime += npc.m_flAddRiadTime;
		}
		b_NpcForcepowerupspawn[npc.index] = 0;
		i_RaidGrantExtra[npc.index] = 0;
		b_DissapearOnDeath[npc.index] = true;
		b_DoGibThisNpc[npc.index] = true;
		SmiteNpcToDeath(npc.index);
	}
}
static void CyberGrindGM_Instantkill(int iNPC)
{
	CyberGrindGM npc = view_as<CyberGrindGM>(iNPC);
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	if(npc.m_flNextThinkTime > gameTime)
		return;
	npc.m_flNextThinkTime = gameTime + 0.1;
	if(npc.m_flNextRangedAttack < gameTime)
	{
		if(GrigoriMaxSellsItems!=-1)
			GrigoriMaxSells = GrigoriMaxSellsItems;
		if(Grigori_RefreshTwo)
			Store_RandomizeNPCStore(ZR_STORE_DEFAULT_SALE);
		if(Grigori_Refresh)
		{
			Store_RandomizeNPCStore(ZR_STORE_WAVEPASSED);
			Store_RandomizeNPCStore(ZR_STORE_DEFAULT_SALE);
		}
		
		b_NpcForcepowerupspawn[npc.index] = 0;
		i_RaidGrantExtra[npc.index] = 0;
		b_DissapearOnDeath[npc.index] = true;
		b_DoGibThisNpc[npc.index] = true;
		SmiteNpcToDeath(npc.index);
	}
}
static void CyberGrindGM_Final_Item(int iNPC)
{
	CyberGrindGM npc = view_as<CyberGrindGM>(iNPC);
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	if(npc.m_flNextThinkTime > gameTime)
		return;
	npc.m_flNextThinkTime = gameTime + 0.1;
	if(npc.m_flNextRangedAttack < gameTime && npc.Anger)
	{
		float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
		ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
		if(npc.m_flNextRangedAttack < gameTime && npc.Anger)
		{
			b_DoNotUnStuck[npc.index] = true;
			b_NoKnockbackFromSources[npc.index] = true;
			b_NpcIsInvulnerable[npc.index] = true;
			b_ThisEntityIgnored[npc.index] = true;
			MakeObjectIntangeable(npc.index);
			int Decicion = TeleportDiversioToRandLocation(npc.index, true, 300.0, 300.0);
			switch(Decicion)
			{
				case 2:
				{
					Decicion = TeleportDiversioToRandLocation(npc.index, true, 300.0, 150.0);
					if(Decicion == 2)
					{
						Decicion = TeleportDiversioToRandLocation(npc.index, true, 300.0, 50.0);
						if(Decicion == 2)
						{
							Decicion = TeleportDiversioToRandLocation(npc.index, true, 300.0, 0.0);
						}
					}
				}
				case 3:
				{
					//todo code on what to do if random teleport is disabled
				}
			}
			npc.Anger=false;
			WorldSpaceCenter(npc.index, WorldSpaceVec);
			ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
			npc.SetGoalVector(WorldSpaceVec, true);
			npc.PlayDeathSound();
		}
	}
	
	if(!npc.Anger && npc.m_flNextMeleeAttack < gameTime)
	{
		switch(npc.m_iOverlordComboAttack)
		{
			case 0:
			{
				NPCPritToChat(npc.index, "{slateblue}", "MrV Talk 05", false, false);
				npc.m_flNextMeleeAttack = gameTime + 4.0;
				npc.m_iOverlordComboAttack=1;
			}
			case 1:
			{
				NPCPritToChat(npc.index, "{slateblue}", "MrV Talk 06", false, false);
				bool bCGNormal, bCGHard, bCGExpert, bCGEX_Hard;
				if(CyberGrind_InternalDifficulty<5)
				{
					if(CyberGrind_InternalDifficulty>0)
						bCGNormal=true;
					if(CyberGrind_InternalDifficulty>1)
						bCGHard=true;
					if(CyberGrind_InternalDifficulty>2)
						bCGExpert=true;
					if(CyberGrind_InternalDifficulty>3)
						bCGEX_Hard=true;
				}
				for (int client = 0; client < MaxClients; client++)
				{
					if(IsValidClient(client) && GetClientTeam(client) == 2 && TeutonType[client] != TEUTON_WAITING && PlayerPoints[client] > 500)
					{
						SetGlobalTransTarget(client);
						CPrintToChat(client, "%t", "MrV Talk 07");
						if(bCGNormal && !(Items_HasNamedItem(client, "Widemouth Refill Port")))
						{
							Items_GiveNamedItem(client, "Widemouth Refill Port");
							CPrintToChat(client, "%t", "MrV Talk 08");
						}
						if(bCGHard && !(Items_HasNamedItem(client, "Builder's Blueprints")))
						{
							Items_GiveNamedItem(client, "Builder's Blueprints");
							CPrintToChat(client, "%t", "MrV Talk 09");
						}
						if(bCGExpert && !(Items_HasNamedItem(client, "Sardis Gold")))
						{
							Items_GiveNamedItem(client, "Sardis Gold");
							CPrintToChat(client, "%t", "MrV Talk 10");
						}
						if(bCGEX_Hard && !(Items_HasNamedItem(client, "Originium")))
						{
							Items_GiveNamedItem(client, "Originium");
							CPrintToChat(client, "%t", "MrV Talk 11");
						}
						int MultiExtra = 1;
						switch(CyberGrind_InternalDifficulty)
						{
							case 0, 1:
								MultiExtra = 10;
							case 2:
								MultiExtra = 15;
							case 3:
								MultiExtra = 20;
							case 4:
								MultiExtra = 45;
							default:
								MultiExtra = 5;
						}

						int TempCalc = Level[client];
						if(TempCalc >= 101)
							TempCalc = 101;

						TempCalc = LevelToXp(TempCalc) - LevelToXp(TempCalc - 1);
						TempCalc /= 40;

						int XpToGive = TempCalc * MultiExtra;
						XP[client] += XpToGive;
						GiveXP(client, 0);
						CPrintToChat(client, "%t", "Pickup XP Gift", XpToGive);
					}
				}
				npc.m_flNextMeleeAttack = gameTime + 8.0;
				npc.m_iOverlordComboAttack=2;
			}
			case 2:
			{
				float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
				ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
				npc.PlayDeathSound();
				b_DoNotUnStuck[npc.index] = true;
				b_NoKnockbackFromSources[npc.index] = true;
				b_NpcIsInvulnerable[npc.index] = true;
				b_ThisEntityIgnored[npc.index] = true;
				MakeObjectIntangeable(npc.index);
				b_NoHealthbar[npc.index]=true;
				if(IsValidEntity(i_InvincibleParticle[npc.index]))
				{
					int particle = EntRefToEntIndex(i_InvincibleParticle[npc.index]);
					SetEntityRenderMode(particle, RENDER_TRANSCOLOR);
					SetEntityRenderColor(particle, 255, 255, 255, 1);
					SetEntPropFloat(particle, Prop_Send, "m_fadeMinDist", 1.0);
					SetEntPropFloat(particle, Prop_Send, "m_fadeMaxDist", 1.0);
				}
				SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.index, 255, 255, 255, 1);
				SetEntPropFloat(npc.index, Prop_Send, "m_fadeMinDist", 1.0);
				SetEntPropFloat(npc.index, Prop_Send, "m_fadeMaxDist", 1.0);
				if(IsValidEntity(npc.m_iWearable1))
				{
					SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
					SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 1);
					SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_fadeMinDist", 1.0);
					SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_fadeMaxDist", 1.0);
				}
				if(IsValidEntity(npc.m_iWearable2))
				{
					SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
					SetEntityRenderColor(npc.m_iWearable2, 255, 255, 255, 1);
					SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMinDist", 1.0);
					SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMaxDist", 1.0);
				}
				if(IsValidEntity(npc.m_iTeamGlow))
					RemoveEntity(npc.m_iTeamGlow);
				npc.m_iOverlordComboAttack=3;
				npc.m_flNextMeleeAttack = gameTime + 1.5;
			}
			case 3:
			{
				ForcePlayerWin();
				SmiteNpcToDeath(npc.index);
			}
		}
	}
}

static void CyberGrindGM_ClotThink(int iNPC)
{
	CyberGrindGM npc = view_as<CyberGrindGM>(iNPC);
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	if(npc.m_flNextThinkTime > gameTime)
		return;
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(IsValidEntity(i_InvincibleParticle[npc.index]))
	{
		int particle = EntRefToEntIndex(i_InvincibleParticle[npc.index]);
		SetEntityRenderMode(particle, RENDER_TRANSCOLOR);
		SetEntityRenderColor(particle, 255, 255, 255, 1);
		SetEntPropFloat(particle, Prop_Send, "m_fadeMinDist", 1.0);
		SetEntPropFloat(particle, Prop_Send, "m_fadeMaxDist", 1.0);
	}
	if(npc.m_flNextRangedAttack < gameTime && npc.Anger)
	{
		float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
		ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
		if(npc.m_flNextRangedAttack < gameTime && npc.Anger)
		{
			b_DoNotUnStuck[npc.index] = true;
			b_NoKnockbackFromSources[npc.index] = true;
			b_NpcIsInvulnerable[npc.index] = true;
			b_ThisEntityIgnored[npc.index] = true;
			MakeObjectIntangeable(npc.index);
			int Decicion = TeleportDiversioToRandLocation(npc.index, true, 300.0, 300.0);
			switch(Decicion)
			{
				case 2:
				{
					Decicion = TeleportDiversioToRandLocation(npc.index, true, 300.0, 150.0);
					if(Decicion == 2)
					{
						Decicion = TeleportDiversioToRandLocation(npc.index, true, 300.0, 50.0);
						if(Decicion == 2)
						{
							Decicion = TeleportDiversioToRandLocation(npc.index, true, 300.0, 0.0);
						}
					}
				}
				case 3:
				{
					//none
				}
			}
			npc.Anger=false;
			ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
			npc.SetGoalVector(WorldSpaceVec, true);
			npc.PlayDeathSound();
			RaidMode_SetupVote();
		}
	}
	
	if(i_RaidGrantExtra[npc.index] == RAIDITEM_INDEX_WIN_COND)
	{
		delete Voting;
		CyberVote=false;
		CGBreak=true;
		b_NpcForcepowerupspawn[npc.index] = 0;
		i_RaidGrantExtra[npc.index] = 0;
		b_DissapearOnDeath[npc.index] = true;
		b_DoGibThisNpc[npc.index] = true;
		SmiteNpcToDeath(npc.index);
	}

	if(CyberGrind_Difficulty>0)
	{
		if(npc.m_flNextMeleeAttack < gameTime)
		{
			switch(npc.m_iOverlordComboAttack)
			{
				case 0:
				{
					if(CyberGrind_Difficulty==4)
						NPCPritToChat(npc.index, "{slateblue}", "MrV Talk 03", false, false);
					else
						NPCPritToChat(npc.index, "{slateblue}", "MrV Talk 01", false, false);
					npc.m_flNextMeleeAttack = gameTime + 1.0;
					npc.m_iOverlordComboAttack=1;
				}
				case 1:
				{
					if(CyberGrind_Difficulty==4)
						NPCPritToChat(npc.index, "{slateblue}", "MrV Talk 04", false, false);
					else
						NPCPritToChat(npc.index, "{slateblue}", "MrV Talk 02", false, false);
					CyberGrind_InternalDifficulty = CyberGrind_Difficulty;
					npc.m_flNextMeleeAttack = gameTime + 1.0;
					npc.m_iOverlordComboAttack=2;
				}
				case 2:
				{
					if(ZR_Get_Modifier()!=0)
						NPCPritToChat(npc.index, "{slateblue}", "MrV Talk 12", false, false);
					//Citizen_SpawnAtPoint("b");
					//Citizen_SpawnAtPoint();
					if(CyberGrind_Difficulty==4)
					{
						float SelfPos[3];
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", SelfPos);
						float AllyAng[3];
						GetEntPropVector(npc.index, Prop_Data, "m_angRotation", AllyAng);
						int Spawner_entity = GetRandomActiveSpawner();
						if(IsValidEntity(Spawner_entity))
						{
							GetEntPropVector(Spawner_entity, Prop_Data, "m_vecOrigin", SelfPos);
							GetEntPropVector(Spawner_entity, Prop_Data, "m_angRotation", AllyAng);
						}
						NPC_CreateByName("npc_invisible_trigger_man", -1, SelfPos, AllyAng, TFTeam_Stalkers, "cybergrind_ex_hard");
					}
					Spawn_Cured_Grigori();
					//CyberGrindGM_Talk("Rebels Arrive", true);
					/*if(CyberGrind_Difficulty!=4)
					{
						Waves_ClearWaves();
						CurrentRound = 2;
						CurrentWave = -1;
						Waves_Progress();
					}*/
					b_NpcForcepowerupspawn[npc.index] = 0;
					i_RaidGrantExtra[npc.index] = 0;
					b_DissapearOnDeath[npc.index] = true;
					b_DoGibThisNpc[npc.index] = true;
					SmiteNpcToDeath(npc.index);
				}
			}
		}
	}
}

static Action CyberGrindGM_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	CyberGrindGM npc = view_as<CyberGrindGM>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

void RaidMode_RevoteCmd(int client)
{
	if(Voting)
	{
		VotedFor[client] = 0;
		RaidMode_CallVote(client, 1);
	}
}

static void CyberGrindGM_NPCDeath(int entity)
{
	CyberGrindGM npc = view_as<CyberGrindGM>(entity);
	
	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
	ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
	npc.PlayDeathSound();	
	CGBreak=true;

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

static void RaidMode_SetupVote()
{
	delete Voting;
	Voting = new ArrayList(sizeof(Vote));
	CyberVote=true;
	Vote vote;
	
	strcopy(vote.Name, sizeof(vote.Name), "CyberGrind_Fast");
	strcopy(vote.Desc, sizeof(vote.Desc), "CyberGrind_Fast Desc");
	vote.Config[0] = 0;
	vote.Level = 100;
	Voting.PushArray(vote);
	
	strcopy(vote.Name, sizeof(vote.Name), "CyberGrind_EX_Fast");
	strcopy(vote.Desc, sizeof(vote.Desc), "CyberGrind_EX_Fast Desc");
	vote.Config[0] = 0;
	vote.Level = 250;
	Voting.PushArray(vote);
	
	strcopy(vote.Name, sizeof(vote.Name), "CyberGrind_Normal");
	strcopy(vote.Desc, sizeof(vote.Desc), "CyberGrind_Normal Desc");
	vote.Config[0] = 0;
	vote.Level = 120;
	Voting.PushArray(vote);
	
	strcopy(vote.Name, sizeof(vote.Name), "CyberGrind_Hard");
	strcopy(vote.Desc, sizeof(vote.Desc), "CyberGrind_Hard Desc");
	vote.Config[0] = 0;
	vote.Level = 150;
	Voting.PushArray(vote);
	
	strcopy(vote.Name, sizeof(vote.Name), "CyberGrind_Expert");
	strcopy(vote.Desc, sizeof(vote.Desc), "CyberGrind_Expert Desc");
	vote.Config[0] = 0;
	vote.Level = 200;
	Voting.PushArray(vote);
	
	strcopy(vote.Name, sizeof(vote.Name), "CyberGrind_EX_Hard");
	strcopy(vote.Desc, sizeof(vote.Desc), "CyberGrind_EX_Hard Desc");
	vote.Config[0] = 0;
	vote.Level = 300;
	Voting.PushArray(vote);

	CreateTimer(1.0, RaidMode_VoteDisplayTimer, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client) && GetClientTeam(client)>1)
		{
			RaidMode_RoundStart();
			VotedFor[client] = 0;
			RaidMode_CallVote(client);
		}
	}
}

bool RaidMode_CallVote(int client, int force = 0)
{
	if(Voting && (force || !VotedFor[client]))
	{
		Menu menu = new Menu(RaidMode_CallVoteH);
		
		SetGlobalTransTarget(client);
		
		menu.SetTitle("Vote for the Mode!:\n ");
		
		Vote vote;
		Format(vote.Name, sizeof(vote.Name), "%t", "No Vote");
		menu.AddItem(NULL_STRING, vote.Name);

		if(Voting)
		{
			int length = Voting.Length;
			for(int i; i < length; i++)
			{
				Voting.GetArray(i, vote);
				vote.Name[0] = CharToUpper(vote.Name[0]);
				Format(vote.Name, sizeof(vote.Name), "%s (Lv %d)", vote.Name, vote.Level);
				int MenuDo = ITEMDRAW_DISABLED;
				if(!vote.Level)
					MenuDo = ITEMDRAW_DEFAULT;
				if(Level[client] >= 1)
					MenuDo = ITEMDRAW_DEFAULT;
				menu.AddItem(vote.Config, vote.Name, MenuDo);
			}
		}
		
		menu.ExitButton = false;
		menu.DisplayAt(client, (force / 7 * 7), MENU_TIME_FOREVER);
		return true;
	}
	return false;
}

static int RaidMode_CallVoteH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Select:
		{
			ArrayList list = Voting;
			if(list)
			{
				if(!choice || VotedFor[client] != choice)
				{
					VotedFor[client] = choice;
					if(VotedFor[client] == 0)
					{
						VotedFor[client] = -1;
					}
					else if(VotedFor[client] > list.Length)
					{
						VotedFor[client] = 0;
						RaidMode_CallVote(client, choice);
						return 0;
					}
					else
					{
						Vote vote;
						list.GetArray(choice - 1, vote);

						if(vote.Desc[0] && TranslationPhraseExists(vote.Desc))
						{
							CPrintToChat(client, "%t: %t", vote.Name, vote.Desc);
						}
						else
						{
							CPrintToChat(client, "%t: %s", vote.Name, vote.Desc);
						}

						RaidMode_CallVote(client, choice);
						return 0;
					}
				}
			}
			Store_Menu(client);
		}
	}
	return 0;
}

static Action RaidMode_VoteDisplayTimer(Handle timer)
{
	if(!Voting || CGBreak)
		return Plugin_Stop;
	
	RaidMode_DisplayHintVote();
	return Plugin_Continue;
}

static void RaidMode_DisplayHintVote()
{
	ArrayList list = Voting;
	int length = list.Length;
	if(length > 1)
	{
		int count, total;
		int[] votes = new int[length + 1];
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client) && GetClientTeam(client) == 2)
			{
				total++;

				if(VotedFor[client])
				{
					count++;

 					if(VotedFor[client] > 0 && VotedFor[client] <= length)
						votes[VotedFor[client] - 1]++;
				}
			}
		}

		int top[3] = {-1, ...};
		for(int i; i < length; i++)
		{
			if(votes[i] < 1)
			{

			}
			else if(top[0] == -1 || votes[i] > votes[top[0]])
			{
				top[2] = top[1];
				top[1] = top[0];
				top[0] = i;
			}
			else if(top[1] == -1 || votes[i] > votes[top[1]])
			{
				top[2] = top[1];
				top[1] = i;
			}
			else if(top[2] == -1 || votes[i] > votes[top[2]])
			{
				top[2] = i;
			}
		}

		if(top[0] != -1)
		{
			Vote vote;
			list.GetArray(top[0], vote);
			vote.Name[0] = CharToUpper(vote.Name[0]);

			char buffer[256];
			FormatEx(buffer, sizeof(buffer), "Votes: %d/%d, %ds left\n1. %s: (%d)", count, total, RoundFloat(VoteEndTime - GetGameTime()), vote.Name, votes[top[0]]);

			for(int i = 1; i < sizeof(top); i++)
			{
				if(top[i] != -1)
				{
					list.GetArray(top[i], vote);
					vote.Name[0] = CharToUpper(vote.Name[0]);

					Format(buffer, sizeof(buffer), "%s\n%d. %s: (%d)", buffer, i + 1, vote.Name, votes[top[i]]);
				}
			}

			PrintHintTextToAll(buffer);
		}
	}
}

static void RaidMode_RoundStart()
{
	if(Voting)
	{
		VoteEndTime = GetGameTime() + 30.0;
		CreateTimer(30.0, RaidMode_EndVote, _, TIMER_FLAG_NO_MAPCHANGE);
	}
}

static Action RaidMode_EndVote(Handle timer, float time)
{
	if(CGBreak)
		return Plugin_Stop;	

	if(Voting)
	{
		int length = Voting.Length;
		if(length)
		{
			RaidMode_DisplayHintVote();

			int[] votes = new int[length];
			for(int client = 1; client <= MaxClients; client++)
			{
				if(IsClientInGame(client))
				{
					if(VotedFor[client] > 0 && GetClientTeam(client) == 2)
					{
						votes[VotedFor[client]-1]++;
					}
				}
			}
			
			int highest;
			for(int i = 1; i < length; i++)
			{
				if(votes[i] > votes[highest])
					highest = i;
			}
			
			Vote vote;
			Voting.GetArray(highest, vote);
			delete Voting;
			
			if(!StrContains(vote.Name, "CyberGrind_EX_Hard"))
			{
				CyberGrind_Difficulty = 4;
				CurrentCash = 4100;
				for(int client = 1; client <= MaxClients; client++)
				{
					if(IsValidClient(client))
						Ammo_Count_Used[client] = -25;
				}
				
			}
			else if(!StrContains(vote.Name, "CyberGrind_Expert"))
			{
				CyberGrind_Difficulty = 3;
				CurrentCash = 4500;
				for(int client = 1; client <= MaxClients; client++)
				{
					if(IsValidClient(client))
						Ammo_Count_Used[client] = -25;
				}
				
			}
			else if(!StrContains(vote.Name, "CyberGrind_Hard"))
			{
				CyberGrind_Difficulty = 2;
				CurrentCash = 4700;
				for(int client = 1; client <= MaxClients; client++)
				{
					if(IsValidClient(client))
						Ammo_Count_Used[client] = -50;
				}
			}
			else if(!StrContains(vote.Name, "CyberGrind_Fast"))
			{
				CyberGrind_Difficulty = 5;
				CurrentCash = 85000;
				for(int client = 1; client <= MaxClients; client++)
				{
					if(IsValidClient(client))
						Ammo_Count_Used[client] = -1557;
				}
			}
			else if(!StrContains(vote.Name, "CyberGrind_EX_Fast"))
			{
				CyberGrind_Difficulty = 6;
				CurrentCash = 189800;
				for(int client = 1; client <= MaxClients; client++)
				{
					if(IsValidClient(client))
						Ammo_Count_Used[client] = -220;
				}
			}
			else
			{
				CyberGrind_Difficulty = 1;
				CurrentCash = 5706;
				for(int client = 1; client <= MaxClients; client++)
				{
					if(IsValidClient(client))
						Ammo_Count_Used[client] = -100;
				}
			}
			PrintToChatAll("%t: %t","Difficulty set to", vote.Name);
			CyberVote=false;
		}
	}
	return Plugin_Continue;
}