#pragma semicolon 1
#pragma newdecls required


static const char g_DeathSounds[][] = {
	"zombiesurvival/aprilfools/kranz_death_do.mp3",
};

static const char g_HurtSounds[][] = {
	")vo/soldier_painsharp01.mp3",
	")vo/soldier_painsharp02.mp3",
	")vo/soldier_painsharp03.mp3",
	")vo/soldier_painsharp04.mp3",
	")vo/soldier_painsharp05.mp3",
};


static const char g_IdleAlertedSounds[][] = {
	"vo/taunts/soldier_taunts19.mp3",
	"vo/taunts/soldier_taunts20.mp3",
	"vo/taunts/soldier_taunts21.mp3",
	"vo/taunts/soldier_taunts18.mp3"
};

static const char g_RangedAttackSounds[][] = {
	"weapons/rocket_directhit_shoot_crit.wav",
};
static const char g_MeleeAttackSounds[][] = {
	"weapons/cbar_miss1.wav",
};
static const char g_MeleeHitSounds[][] = {
	"items/cart_explode.wav",
};

static const char g_SuperJumpSound[][] = {
	"misc/halloween/spell_mirv_explode_primary.wav",
};
static const char g_PlayGunSound[][] = {
	"weapons/sniper_bazaarbargain_shoot_crit.wav",
};
static const char g_LifeLossSound[][] = {
	"vo/sniper_battlecry01.mp3",
	"vo/sniper_battlecry02.mp3",
	"vo/sniper_battlecry03.mp3",
	"vo/sniper_battlecry04.mp3",
	"vo/sniper_battlecry06.mp3",
};

static int NPCID;
void NoRandomKranz_OnMapStart_NPC()
{
	PrecacheModel("models/player/soldier.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "No Random Kranz V3");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_no_random_kranz");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Raid;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPCID = NPC_Add(data);
}

static void ClotPrecache()
{
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds)); i++) { PrecacheSound(g_RangedAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_SuperJumpSound)); i++) { PrecacheSound(g_SuperJumpSound[i]); }
	for (int i = 0; i < (sizeof(g_PlayGunSound)); i++) { PrecacheSound(g_PlayGunSound[i]); }
	for (int i = 0; i < (sizeof(g_LifeLossSound)); i++) { PrecacheSound(g_LifeLossSound[i]); }
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSoundCustom(g_DeathSounds[i]);	   }
	PrecacheSoundCustom("#zombiesurvival/aprilfools/kranz_ncrv3.mp3");


}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return NoRandomKranz(vecPos, vecAng, team, data);
}

methodmap NoRandomKranz < CClotBody
{
	property int i_GunMode
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}
	property float f_NoRandomKranzMeleeCooldown
	{
		public get()							{ return fl_NextChargeSpecialAttack[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextChargeSpecialAttack[this.index] = TempValueForProperty; }
	}
	property float f_NoRandomKranzRocketJumpCD
	{
		public get()							{ return fl_NextRangedBarrage_Singular[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextRangedBarrage_Singular[this.index] = TempValueForProperty; }
	}
	property float f_NoRandomKranzRocketJumpCD_Wearoff
	{
		public get()							{ return fl_AttackHappensMaximum[this.index]; }
		public set(float TempValueForProperty) 	{ fl_AttackHappensMaximum[this.index] = TempValueForProperty; }
	}
	property bool b_NoRandomKranzRocketJump
	{
		public get()							{ return b_NextRangedBarrage_OnGoing[this.index]; }
		public set(bool TempValueForProperty) 	{ b_NextRangedBarrage_OnGoing[this.index] = TempValueForProperty; }
	}
	property float m_TimeUntillsuicide
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_CreateClones
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_fldeathAnim
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		int sound = GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1);
		EmitSoundToAll(g_IdleAlertedSounds[sound], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		DataPack pack;

		CreateDataTimer(0.1, Fusion_RepeatSound_Doublevoice, pack, TIMER_FLAG_NO_MAPCHANGE);	//don't mind me, just reusing this...
		pack.WriteString(g_IdleAlertedSounds[sound]);
		pack.WriteCell(EntIndexToEntRef(this.index));
		
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		int sound = GetRandomInt(0, sizeof(g_HurtSounds) - 1);
		EmitSoundToAll(g_HurtSounds[sound], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		DataPack pack;
		CreateDataTimer(0.1, Fusion_RepeatSound_Doublevoice, pack, TIMER_FLAG_NO_MAPCHANGE);	//don't mind me, just reusing this...
		pack.WriteString(g_HurtSounds[sound]);
		pack.WriteCell(EntIndexToEntRef(this.index));
	}
	public void PlayRangedSound()
	{
		int sound = GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1);
		EmitSoundToAll(g_RangedAttackSounds[sound], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);		
	}
	public void PlaySuperJumpSound()
	{
		int sound = GetRandomInt(0, sizeof(g_SuperJumpSound) - 1);
		EmitSoundToAll(g_SuperJumpSound[sound], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_SuperJumpSound[sound], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound()
	{
		int sound = GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1);
		EmitSoundToAll(g_MeleeAttackSounds[sound], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayGunSound()
	{
		int sound = GetRandomInt(0, sizeof(g_PlayGunSound) - 1);
		EmitSoundToAll(g_PlayGunSound[sound], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayDupeSound()
	{
		int sound = GetRandomInt(0, sizeof(g_PlayGunSound) - 1);
		EmitSoundToAll(g_PlayGunSound[sound], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		int sound = GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1);
		EmitSoundToAll(g_MeleeHitSounds[sound], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_MeleeHitSounds[sound], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
	}
	public void PlayTeleportSound() 
	{
		EmitCustomToAll("zombiesurvival/internius/blinkarrival.wav", this.index, SNDCHAN_STATIC, 120, _, 5.0);	
	}
	public void PlayLifelossSound() 
	{
		int sound = GetRandomInt(0, sizeof(g_LifeLossSound) - 1);
		EmitSoundToAll(g_LifeLossSound[sound], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_LifeLossSound[sound], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		DataPack pack;
		CreateDataTimer(0.1, Fusion_RepeatSound_Doublevoice, pack, TIMER_FLAG_NO_MAPCHANGE);	//don't mind me, just reusing this...
		pack.WriteString(g_LifeLossSound[sound]);
		pack.WriteCell(EntIndexToEntRef(this.index));
		
		DataPack pack2;
		CreateDataTimer(0.1, Fusion_RepeatSound_Doublevoice, pack2, TIMER_FLAG_NO_MAPCHANGE);	//don't mind me, just reusing this...
		pack2.WriteString(g_LifeLossSound[sound]);
		pack2.WriteCell(EntIndexToEntRef(this.index));
	}
	
	
	public NoRandomKranz(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		NoRandomKranz npc = view_as<NoRandomKranz>(CClotBody(vecPos, vecAng, "models/player/soldier.mdl", "1.1", "40000", ally, false, false, true,true)); //giant!
		

		i_NpcWeight[npc.index] = 3;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		func_NPCDeath[npc.index] = NoRandomKranz_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = NoRandomKranz_OnTakeDamage;
		func_NPCThink[npc.index] = NoRandomKranz_ClotThink;
		
		npc.StartPathing();
		npc.m_flSpeed = 300.0;
		npc.i_GunMode = 1;
		
		npc.m_CreateClones = GetGameTime() + 10.0;
		npc.f_NoRandomKranzRocketJumpCD = GetGameTime() + 5.0;
		if(StrContains(data, "jump_minions") != -1)
		{
			npc.m_TimeUntillsuicide = GetGameTime() + 4.5;
			MakeObjectIntangeable(npc.index);
			i_RaidGrantExtra[npc.index] = 4;
			b_DoNotUnStuck[npc.index] = true;
			b_ThisNpcIsImmuneToNuke[npc.index] = true;
			b_NoKnockbackFromSources[npc.index] = true;
			b_ThisEntityIgnored[npc.index] = true;
			b_thisNpcIsARaid[npc.index] = true;
			b_NoHealthbar[npc.index] = 1;
			npc.m_flRangedSpecialDelay = 0.0;
			npc.m_bDissapearOnDeath = true;
			b_NoKillFeed[npc.index] = true;
			b_ThisEntityIgnoredBeingCarried[npc.index] = true; //cant be targeted AND wont do npc collsiions
			npc.i_GunMode = 2;
			npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_bazaar_sniper/c_bazaar_sniper.mdl");
		}
		else
		{
			func_NPCLostHealthBar[npc.index] = view_as<Function>(NpcClot_LifeLost);
			EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
			EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
			for(int client_check=1; client_check<=MaxClients; client_check++)
			{
				if(IsClientInGame(client_check) && !IsFakeClient(client_check))
				{
					LookAtTarget(client_check, npc.index);
					SetGlobalTransTarget(client_check);
				}
			}		
			RaidModeTime = GetGameTime(npc.index) + 200.0;
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidAllowsBuildings = false;
			b_thisNpcIsARaid[npc.index] = true;

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

			RaidModeScaling *= amount_of_people; //More then 9 and he raidboss gets some troubles, bufffffffff

			MusicEnum music;
			strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/aprilfools/kranz_ncrv3.mp3");
			music.Time = 62;
			music.Volume = 1.0;
			music.Custom = true;
			strcopy(music.Name, sizeof(music.Name), "AGL LR Super Saiyan Blue Goku & Vegeta Intro OST");
			strcopy(music.Artist, sizeof(music.Artist), "Dragon Ball Z Dokkan Battle");
			Music_SetRaidMusic(music);
			
			CPrintToChatAll("{darkblue}No Random Kranz V3{default}: I am not NRCV3 nor Kranz, its over mercs, i have come for you!");
			CPrintToChatAll("{darkblue}No Random Kranz V3{default}: Us bosses HAVE NO LIMITS!");
			
			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_directhit/c_directhit.mdl");
		}

		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		npc.m_iHealthBar = 6;

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/all_class/short2014_all_eyepatch/short2014_all_eyepatch_soldier.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/sniper/sum19_bare_necessities/sum19_bare_necessities.mdl");
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/soldier/coldfront_curbstompers/coldfront_curbstompers.mdl");
		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/soldier/jul13_generals_attire/jul13_generals_attire.mdl");
		npc.m_iWearable7 = npc.EquipItem("head", "models/workshop/player/items/soldier/dec15_diplomat/dec15_diplomat.mdl");


		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable7, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.m_iWearable3,	15, 15, 255, 255);
		SetEntityRenderColor(npc.m_iWearable4,	15, 15, 255, 255);
		SetEntityRenderColor(npc.m_iWearable5,	15, 15, 255, 255);
		SetEntityRenderColor(npc.m_iWearable6,	15, 15, 255, 255);
		SetEntityRenderColor(npc.m_iWearable7, 	15, 15, 255, 255);
		SetEntityRenderColor(npc.index		, 	15, 15, 255, 255);
		
		npc.m_iWearable8 = npc.EquipItem("head", "models/player/soldier.mdl", _, skin);

		if(IsValidEntity(npc.m_iWearable8))
		{
			TE_SetupParticleEffect("utaunt_glowyplayer_purple_parent", PATTACH_ABSORIGIN_FOLLOW, npc.m_iWearable8);
			TE_WriteNum("m_bControlPoint1", npc.m_iWearable8);	
			TE_SendToAll();
			SetVariantInt(2);
			AcceptEntityInput(npc.m_iWearable8, "SetBodyGroup");
		}
		SetEntityRenderColor(npc.m_iWearable8, .a = 0);
		SetEntityRenderMode(npc.m_iWearable8, RENDER_TRANSCOLOR);
		
		return npc;
	}
}

public void NoRandomKranz_ClotThink(int iNPC)
{
	NoRandomKranz npc = view_as<NoRandomKranz>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();



	if(npc.m_fldeathAnim)
	{
		npc.Jump();
		float vecJumpVel[3];
		vecJumpVel[0] = 1000.0;
		vecJumpVel[1] = 1000.0;
		vecJumpVel[2] = 1000.0;
		npc.SetVelocity(vecJumpVel);
		if(npc.m_fldeathAnim < GetGameTime())
		{
			RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
			return;
		}
		return;
	}

	if (npc.i_GunMode != 2 && npc.IsOnGround())
	{
		if(GetGameTime(npc.index) > npc.f_NoRandomKranzRocketJumpCD_Wearoff)
		{
			npc.b_NoRandomKranzRocketJump = false;
		}
	}
	if(npc.m_TimeUntillsuicide)
	{
		if(npc.m_TimeUntillsuicide < GetGameTime())
		{
			RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
			return;
		}
	}
	
	if(npc.i_GunMode != 2 && LastMann)
	{
		if(!npc.m_fbGunout)
		{
			npc.m_fbGunout = true;
			
		}
	}
	if(npc.i_GunMode != 2 && !BlockLoseSay && RaidModeTime < GetGameTime())
	{
		BlockLoseSay = true;
	}
	if(npc.i_GunMode != 2 && npc.m_CreateClones < GetGameTime(npc.index))
	{
		if(!npc.b_NoRandomKranzRocketJump && IsValidEnemy(npc.index, npc.m_iTarget) && Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
		{
			npc.PlayTeleportSound();
			float SelfPos[3];
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", SelfPos);
			SelfPos[2] += 35.0;
			float AllyAng[3];
			GetEntPropVector(npc.index, Prop_Data, "m_angRotation", AllyAng);
			npc.m_CreateClones = GetGameTime(npc.index) + 15.0;
			for(int i; i < 3; i++)
			{
				int CloneSpawn = NPC_CreateById(NPCID, -1, SelfPos, AllyAng, GetTeam(npc.index), "jump_minions"); //can only be enemy
				float JumpPos[3];
				JumpPos = SelfPos;
				JumpPos[2] += 500.0;
				
				switch(i)
				{
					case 0:
					{
						JumpPos[0] += 250.0;
					}
					case 1:
					{
						JumpPos[1] += 125.0;
						JumpPos[0] += 125.0;
					}
					case 2:
					{
						JumpPos[1] -= 125.0;
						JumpPos[0] -= 125.0;
					}
				}
				PluginBot_Jump(CloneSpawn, JumpPos);
				fl_GravityMulti[CloneSpawn] *= 0.75;
				FreezeNpcInTime(CloneSpawn, 0.5);
			}
		}
	}

	if(npc.i_GunMode != 2 && i_RaidGrantExtra[npc.index] == RAIDITEM_INDEX_WIN_COND)
	{
		npc.m_bisWalking = false;
		npc.AddActivityViaSequence("selectionMenu_Idle");
		npc.SetCycle(0.01);
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		
		CPrintToChatAll("{blue}BlackHeavySoul{default}: gg Ez.");
		return;

	}	

	if(npc.i_GunMode != 2 && npc.m_bAllowBackWalking)
	{
		if(IsValidEnemy(npc.index, npc.m_iTarget))
		{
			float WorldSpaceVec[3]; WorldSpaceCenter(npc.m_iTarget, WorldSpaceVec);
			npc.FaceTowards(WorldSpaceVec, 150.0);
		}
	}

	if(npc.i_GunMode != 2 && npc.m_blPlayHurtAnimation)
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
		int SetGoalVectorIndex = 0;
		if(npc.i_GunMode == 2)
		{
			SetGoalVectorIndex = KranzSniperSelfDefense(npc,GetGameTime(npc.index)); 
		}
		else
			SetGoalVectorIndex = NoRandomKranzSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 


		switch(SetGoalVectorIndex)
		{
			case 0:
			{
				if(IsValidEnemy(npc.index, npc.m_iTarget))
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
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}

	NoRandomKranzAnimationChange(npc);
	npc.PlayIdleAlertSound();
}

public Action NoRandomKranz_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	NoRandomKranz npc = view_as<NoRandomKranz>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;

	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}		


	int Health = GetEntProp(victim, Prop_Data, "m_iHealth");
	if(RoundToCeil(damage) > Health && npc.m_iHealthBar <= 0)
	{	
		CPrintToChatAll("{darkblue}No Random Kranz V3{default}: OH COME ON FULL DODGE BUILD AND THEN THIS???");
		
		npc.StopPathing();
		ApplyStatusEffect(victim, victim, "Infinite Will", 1.0);
		RequestFrames(KillNpc, 66 * 2, EntIndexToEntRef(npc.index));

	//	npc.m_bisWalking = false;
	//	npc.SetActivity("ACT_WHITEFLOWER_DEATH");
	//	SetEntProp(victim, Prop_Data, "m_bSequenceLoops", false);
		npc.m_fldeathAnim = GetGameTime() + 1.0;
		func_NPCOnTakeDamage[npc.index] = INVALID_FUNCTION;
		func_NPCDeathForward[npc.index] = INVALID_FUNCTION;
		npc.m_flNextThinkTime = FAR_FUTURE;
		RaidModeTime = FAR_FUTURE;
		return Plugin_Changed;
	}
	
	return Plugin_Changed;
}

public void NoRandomKranz_NPCDeath(int entity)
{
	NoRandomKranz npc = view_as<NoRandomKranz>(entity);
	/*
		Explode on death code here please

	*/
	if(IsValidEntity(npc.m_iWearable9))
		RemoveEntity(npc.m_iWearable9);
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
	if(npc.m_bDissapearOnDeath)
		return;

	for(int client1 = 1; client1 <= MaxClients; client1++)
	{
		if(!b_IsPlayerABot[client1] && IsClientInGame(client1) && !IsFakeClient(client1))
		{
			SetMusicTimer(client1, GetTime() + 10); //This is here beacuse of raid music.
			Music_Stop_All(client1);
		}
	}
	CPrintToChatAll("{darkblue}No Random Kranz V3{default}: K  O   !");
		
	static float flMyPos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", flMyPos);
	TE_Particle("ExplosionCore_MidAir", flMyPos, NULL_VECTOR, NULL_VECTOR, 
	_, _, _, _, _, _, _, _, _, _, 0.0);
	EmitAmbientSound("weapons/explode3.wav", flMyPos, _, 120, _,1.0, GetRandomInt(95, 105));
	EmitAmbientSound("weapons/explode3.wav", flMyPos, _, 120, _,1.0, GetRandomInt(95, 105));
	EmitAmbientSound("weapons/explode3.wav", flMyPos, _, 120, _,1.0, GetRandomInt(95, 105));
	int sound = GetRandomInt(0, sizeof(g_DeathSounds) - 1);
	EmitAmbientSound(g_DeathSounds[sound], flMyPos, _, 120, _,1.0);
	EmitAmbientSound(g_DeathSounds[sound], flMyPos, _, 120, _,1.0);
	EmitAmbientSound(g_DeathSounds[sound], flMyPos, _, 120, _,1.0);
	EmitAmbientSound(g_DeathSounds[sound], flMyPos, _, 120, _,1.0);
	

}
/*


*/
void NoRandomKranzAnimationChange(NoRandomKranz npc)
{
	if(npc.i_GunMode == 2)
		return;
	switch(npc.i_GunMode)
	{
		case 1: //primary
		{
			if (npc.IsOnGround())
			{
				if(npc.m_iChanged_WalkCycle != 1)
				{
					ResetNoRandomKranzWeapon(npc, 1);
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 1;
					npc.SetActivity("ACT_MP_RUN_PRIMARY");
					npc.StartPathing();
				}	
			}
			else
			{
				if(npc.m_iChanged_WalkCycle != 2)
				{
					ResetNoRandomKranzWeapon(npc, 1);
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 2;
					npc.SetActivity("ACT_MP_JUMP_FLOAT_PRIMARY");
					npc.StartPathing();
				}	
			}
		}
		case 0: //Melee
		{
			if (npc.IsOnGround())
			{
				if(npc.m_iChanged_WalkCycle != 3)
				{
					ResetNoRandomKranzWeapon(npc, 0);
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 3;
					npc.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
					npc.StartPathing();
				}	
			}
			else
			{
				if(npc.m_iChanged_WalkCycle != 4)
				{
					ResetNoRandomKranzWeapon(npc, 0);
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_MP_JUMP_FLOAT_MELEE_ALLCLASS");
					npc.StartPathing();
				}	
			}
		}
	}

}

int NoRandomKranzSelfDefense(NoRandomKranz npc, float gameTime, int target, float distance)
{
	if(!npc.b_NoRandomKranzRocketJump)
	{
		if(npc.m_flAttackHappens)
		{
			npc.i_GunMode = 0;
			if(gameTime > npc.m_flAttackHappens)
			{
				npc.m_flAttackHappens = 0.0;
				Handle swingTrace;
				float WorldSpaceVec[3]; WorldSpaceCenter(target, WorldSpaceVec);
				npc.FaceTowards(WorldSpaceVec, 15000.0);
				if(npc.DoSwingTrace(swingTrace, target, _, _, _, 1)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
				{
					int target_hit = TR_GetEntityIndex(swingTrace);	
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);

					if(target_hit > 0) 
					{
						float damageDealt = 100.0 * RaidModeScaling; //Extreme melee damage
						if(ShouldNpcDealBonusDamage(target_hit))
							damageDealt *= 20.0; //basically oneshots buildings or atleast deals heavy damage
							
							
						SDKHooks_TakeDamage(target_hit, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);									
								
					
						npc.PlayMeleeHitSound();
						npc.DispatchParticleEffect(npc.index, "hightower_explosion", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("effect_hand_l"), PATTACH_POINT_FOLLOW, true);
						
						BlackHoleRocketDoPos(npc.index, vecHit);
						BlackHoleRocketDoPos(npc.index, vecHit);
						BlackHoleRocketDoPos(npc.index, vecHit);
						BlackHoleRocketDoPos(npc.index, vecHit);

						bool Knocked = false;
									
						if(IsValidClient(target_hit))
						{
							if (IsInvuln(target_hit))
							{
								Knocked = true;
								Custom_Knockback(npc.index, target_hit, 2000.0, true);
								TF2_AddCondition(target_hit, TFCond_LostFooting, 2.5);
								TF2_AddCondition(target_hit, TFCond_AirCurrent, 2.5);
							}
							else
							{
								TF2_AddCondition(target_hit, TFCond_LostFooting, 2.5);
								TF2_AddCondition(target_hit, TFCond_AirCurrent, 2.5);
							}
						}
									
						if(!Knocked)
							Custom_Knockback(npc.index, target_hit, 1500.0); 
					} 
				}
				delete swingTrace;
			}
			//A melee attack is happening, lets just follow the target_hit
			return 0;
		}

		//This ranged unit is more of an intruder, so we will get whatever enemy its pathing
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 3.0))
		{
			//close enough to concider as a melee range attack.
			if(gameTime > npc.f_NoRandomKranzMeleeCooldown)
			{
				npc.i_GunMode = 0;
				//We can melee!
				//Are we close enough?
				if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.35))
				{
					npc.m_flAttackHappens = gameTime + 0.25;
					npc.m_flDoingAnimation = gameTime + 0.25;
					npc.f_NoRandomKranzMeleeCooldown = gameTime + 5.0;
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS");
					npc.PlayMeleeSound();
					//We are close enough to melee attack, lets melee.
				}
				//no? Chase target
				return 0;
			}
		}
	}
	npc.i_GunMode = 1;
	//isnt melee anymore
	if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 20.0) || npc.b_NoRandomKranzRocketJump)
	{
		if(gameTime > npc.f_NoRandomKranzRocketJumpCD && !NpcStats_IsEnemySilenced(npc.index))
		{
			if(Can_I_See_Enemy_Only(npc.index, target))
			{
				static float flMyPos[3];
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flMyPos);
				static float hullcheckmaxs[3];
				static float hullcheckmins[3];

				//Defaults:
				//hullcheckmaxs = view_as<float>( { 24.0, 24.0, 72.0 } );
				//hullcheckmins = view_as<float>( { -24.0, -24.0, 0.0 } );

				hullcheckmaxs = view_as<float>( { 35.0, 35.0, 500.0 } ); //check if above is free
				hullcheckmins = view_as<float>( { -35.0, -35.0, 17.0 } );
			
				if(!IsSpaceOccupiedWorldOnly(flMyPos, hullcheckmins, hullcheckmaxs, npc.index))
				{
					float flPos[3];
					float flAng[3];
					int Particle_1;
					int Particle_2;
					npc.GetAttachment("foot_L", flPos, flAng);
					Particle_1 = ParticleEffectAt_Parent(flPos, "rockettrail", npc.index, "foot_L", {0.0,0.0,0.0});
					

					npc.GetAttachment("foot_R", flPos, flAng);
					Particle_2 = ParticleEffectAt_Parent(flPos, "rockettrail", npc.index, "foot_R", {0.0,0.0,0.0});
				
					CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(Particle_1), TIMER_FLAG_NO_MAPCHANGE);
					CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(Particle_2), TIMER_FLAG_NO_MAPCHANGE);
					
					npc.PlaySuperJumpSound();
					static float flMyPos_2[3];
					flMyPos[2] += 800.0;
					WorldSpaceCenter(target, flMyPos_2);

					flMyPos[0] = flMyPos_2[0];
					flMyPos[1] = flMyPos_2[1];
					PluginBot_Jump(npc.index, flMyPos);
					npc.f_NoRandomKranzRocketJumpCD_Wearoff = gameTime + 1.0;
					npc.f_NoRandomKranzRocketJumpCD = gameTime + 15.0;
					npc.b_NoRandomKranzRocketJump = true;
					npc.m_flNextRangedAttack = gameTime + 0.25;
				}
				else
				{
					npc.f_NoRandomKranzRocketJumpCD = gameTime + 1.0;
				}
			}
			else
			{
				npc.f_NoRandomKranzRocketJumpCD = gameTime + 1.0;
			}
		}
		
		if((distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 15.0) || npc.b_NoRandomKranzRocketJump) && gameTime > npc.m_flNextRangedAttack)
		{	
			if(Can_I_See_Enemy_Only(npc.index, target))
			{
				float projectile_speed = 1200.0;
				float DamageRocket = 20.0 * RaidModeScaling;
				if(npc.b_NoRandomKranzRocketJump)
				{
					DamageRocket *= 0.5;
				}
				float vPredictedPos[3];
				PredictSubjectPositionForProjectiles(npc, target, projectile_speed, _,vPredictedPos);
				
				npc.FaceTowards(vPredictedPos, 20000.0);
				//Play attack anim
				npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
				


				npc.PlayRangedSound();
				int entity = npc.FireRocket(vPredictedPos, DamageRocket, projectile_speed);
				SetEntProp(entity, Prop_Send, "m_bCritical", true);
			//	i_ProjectileExtraFunction[Rocket] = view_as<Function>(NoRandomKranz_Rocket_Base_Explode);
				npc.m_flDoingAnimation = gameTime + 0.25;
				if(npc.b_NoRandomKranzRocketJump)
				{
					WandProjectile_ApplyFunctionToEntity(entity, BlackHoleRocketDo);
					npc.m_flNextRangedAttack = gameTime + 0.125;
				}
				else
				{
					npc.m_flNextRangedAttack = gameTime + 0.5;
				}
			}
		}
		if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.0))
		{
			//target is too far, try to close in
			return 0;
		}
		else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 5.0))
		{
			if(Can_I_See_Enemy_Only(npc.index, target))
			{
				//target is too close, try to keep distance
				return 1;
			}
		}
	}
	//Chase target
	return 0;
}

		
/*
void NoRandomKranz_Rocket_Base_Explode(int entity, int damage, const float VecPos[3])
{
	PrintToChatAll("Boom! NoRandomKranz_Rocket_Base_Explode");
}
*/

void ResetNoRandomKranzWeapon(NoRandomKranz npc, int weapon_Type)
{
	if(IsValidEntity(npc.m_iWearable1))
	{
		RemoveEntity(npc.m_iWearable1);
	}
	if(IsValidEntity(npc.m_iWearable2))
	{
		RemoveEntity(npc.m_iWearable2);
	}
	switch(weapon_Type)
	{
		case 1:
		{
			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_directhit/c_directhit.mdl");
		}
		case 0:
		{
			float flPos[3];
			float flAng[3];
			npc.GetAttachment("effect_hand_r", flPos, flAng);
			npc.m_iWearable1 = ParticleEffectAt_Parent(flPos, "raygun_projectile_blue_crit", npc.index, "effect_hand_r", {0.0,0.0,0.0});

			npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_crossing_guard/c_crossing_guard.mdl");
		}
	}
}


int KranzSniperSelfDefense(NoRandomKranz npc, float gameTime)
{
	if(!npc.m_flAttackHappens)
	{
		if(IsValidEnemy(npc.index,npc.m_iTarget))
		{
			if(!Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
			{
				npc.m_iTarget = GetClosestTarget(npc.index,_,_,_,_,_,_,true,_,_,true);
			}
		}
		else
		{
			npc.m_iTarget = GetClosestTarget(npc.index,_,_,_,_,_,_,true,_,_,true);
			if(!IsValidEnemy(npc.index,npc.m_iTarget))
			{
				return 0;
			}		
		}
		if(!IsValidEnemy(npc.index,npc.m_iTarget))
		{
			return 0;
		}
	}
	if(Rogue_Mode() && i_npcspawnprotection[npc.index] == NPC_SPAWNPROT_ON)
		return 0;

	float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
	npc.FaceTowards(VecEnemy, 15000.0);

	static float ThrowPos[MAXENTITIES][3];  
	float origin[3], angles[3];
	view_as<CClotBody>(npc.m_iWearable1).GetAttachment("muzzle", origin, angles);
	if(npc.m_flDoingAnimation > gameTime)
	{
		if(Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
		{
			WorldSpaceCenter(npc.m_iTarget, ThrowPos[npc.index]);
			float pos_npc[3];
			WorldSpaceCenter(npc.index, pos_npc);
			float AngleAim[3];
			GetVectorAnglesTwoPoints(pos_npc, ThrowPos[npc.index], AngleAim);
			Handle hTrace = TR_TraceRayFilterEx(pos_npc, AngleAim, MASK_SOLID, RayType_Infinite, BulletAndMeleeTrace, npc.index);
			if(TR_DidHit(hTrace))
			{
				TR_GetEndPosition(ThrowPos[npc.index], hTrace);
			}
			delete hTrace;	
		}
	}
	else
	{	
		if(npc.m_flAttackHappens)
		{
			float pos_npc[3];
			WorldSpaceCenter(npc.index, pos_npc);
			float AngleAim[3];
			GetVectorAnglesTwoPoints(pos_npc, ThrowPos[npc.index], AngleAim);
			Handle hTrace = TR_TraceRayFilterEx(pos_npc, AngleAim, MASK_SOLID, RayType_Infinite, BulletAndMeleeTrace, npc.index);
			if(TR_DidHit(hTrace))
			{
				TR_GetEndPosition(ThrowPos[npc.index], hTrace);
			}
			delete hTrace;
		}
	}
	if(npc.m_flAttackHappens)
	{
		TE_SetupBeamPoints(origin, ThrowPos[npc.index], Shared_BEAM_Laser, 0, 0, 0, 0.11, 5.0, 5.0, 0, 0.0, {0,0,255,255}, 3);
		TE_SendToAll(0.0);
	}
			
	npc.FaceTowards(ThrowPos[npc.index], 15000.0);
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			ShootLaser(npc.m_iWearable1, "bullet_tracer02_blue_crit", origin, ThrowPos[npc.index], false );
			float pos_npc[3];
			WorldSpaceCenter(npc.index, pos_npc);
			float AngleAim[3];
			GetVectorAnglesTwoPoints(pos_npc, ThrowPos[npc.index], AngleAim);
			Handle hTrace = TR_TraceRayFilterEx(pos_npc, AngleAim, MASK_SOLID, RayType_Infinite, BulletAndMeleeTrace, npc.index);
			int Traced_Target = TR_GetEntityIndex(hTrace);
			if(Traced_Target > 0)
			{
				WorldSpaceCenter(Traced_Target, ThrowPos[npc.index]);
			}
			else if(TR_DidHit(hTrace))
			{
				TR_GetEndPosition(ThrowPos[npc.index], hTrace);
			}
			BlackHoleRocketDoPos(npc.index, ThrowPos[npc.index]);
			delete hTrace;	
			int target = Can_I_See_Enemy(npc.index, npc.m_iTarget,_ ,ThrowPos[npc.index]);
			npc.PlayGunSound();
			npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
			if(IsValidEnemy(npc.index, target))
			{
				float damageDealt = 35.0 * RaidModeScaling;
				if(ShouldNpcDealBonusDamage(target))
					damageDealt *= 10.0;

				SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, ThrowPos[npc.index]);
			} 
		}
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		
		npc.m_flAttackHappens = gameTime + 0.55;
		npc.m_flDoingAnimation = gameTime + 0.35;
		npc.m_flNextMeleeAttack = gameTime + 0.65;
	}
	return 1;
}
static bool NpcClot_LifeLost(int iNPC, int LifeAfter)
{
	NoRandomKranz npc = view_as<NoRandomKranz>(iNPC);
	ApplyStatusEffect(iNPC, iNPC, "UBERCHARGED", 5.0);
	ApplyStatusEffect(iNPC, iNPC, "Dimensional Turbulence", 5.0);
	RaidModeTime += 10.0;
	npc.PlayLifelossSound();
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			f_DelayLookingAtHud[client] = GetGameTime() + 1.5;
			PrintCenterText(client, "%s [%i] %s", "No Random Kranz V3 Lost a live!", npc.m_iHealthBar - 1, "lives remain!");
		}
	}

	return true;
}


public void BlackHoleRocketDo(int entity)
{
	static float flMyPos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", flMyPos);
	BlackHoleRocketDoPos(entity, flMyPos);
}
public void BlackHoleRocketDoPos(int entity, float Pos[3])
{
	int Particle = ParticleEffectAt(Pos, "eyeboss_tp_vortex", 5.0);	
	SetTeam(Particle, GetTeam(entity));
	i_ExplosiveProjectileHexArray[Particle] = EP_NO_KNOCKBACK;
	DataPack pack;
	CreateDataTimer(0.25, BlackHoleRocketDo_DmgDo, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

	pack.WriteCell(EntIndexToEntRef(Particle)); 
	pack.WriteFloat(4.0 * RaidModeScaling); 
}
public Action BlackHoleRocketDo_DmgDo(Handle timer, DataPack pack)
{
	pack.Reset();
	int Particle = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidEntity(Particle))
		return Plugin_Stop;
	float DamageDeal = pack.ReadFloat();
	float SpawnPos[3];
	GetEntPropVector(Particle, Prop_Data, "m_vecAbsOrigin", SpawnPos);
	Explode_Logic_Custom(DamageDeal, Particle, Particle, -1, SpawnPos, 90.0, 1.0, _, false, 99,_,15.0);

	return Plugin_Continue;
}