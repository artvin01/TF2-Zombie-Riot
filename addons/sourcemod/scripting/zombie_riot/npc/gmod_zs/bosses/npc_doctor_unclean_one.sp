#pragma semicolon 1
#pragma newdecls required
bool g_dasnaggenvatcher_died;
float g_dasnaggenvatcher_die;
static int NPCId;
static char g_HurtSounds[][] =
{
	"cof/purnell/hurt1.mp3",
	"cof/purnell/hurt2.mp3",
	"cof/purnell/hurt3.mp3",
	"cof/purnell/hurt4.mp3"
};

static char g_KillSounds[][] =
{
	"cof/purnell/kill1.mp3",
	"cof/purnell/kill2.mp3",
	"cof/purnell/kill3.mp3",
	"cof/purnell/kill4.mp3"
};
static char g_SummonSounds[][] = {
	"weapons/buff_banner_horn_blue.wav",
	"weapons/buff_banner_horn_red.wav",
};


void DasNaggenvatcher_OnMapStart()
{
	
	for (int i = 0; i < (sizeof(g_HurtSounds));	   i++) { PrecacheSoundCustom(g_HurtSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_KillSounds));	   i++) { PrecacheSoundCustom(g_KillSounds[i]);	   }
	PrecacheSoundCustom("cof/purnell/death.mp3");
	PrecacheSoundCustom("cof/purnell/intro.mp3");
	PrecacheSoundCustom("cof/purnell/converted.mp3");
	PrecacheSoundCustom("cof/purnell/reload.mp3");
	PrecacheSoundCustom("cof/purnell/shoot.mp3");
	PrecacheSoundCustom("cof/purnell/shove.mp3");
	PrecacheSoundCustom("cof/purnell/meleehit.mp3");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Das Naggenvatcher Doctor");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_doctor_unclean_one");
	strcopy(data.Icon, sizeof(data.Icon), "expidonsan_doctor");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Raid;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return DasNaggenvatcher(vecPos, vecAng, team, data);
}

methodmap DasNaggenvatcher < CClotBody
{
	property float m_flMaxDeath
	{
		public get()							{ return fl_AbilityOrAttack[this.index][9]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][9] = TempValueForProperty; }
	}
	property float m_flReviveDasNaggenvatcherTime
	{
		public get()							{ return fl_GrappleCooldown[this.index]; }
		public set(float TempValueForProperty) 	{ fl_GrappleCooldown[this.index] = TempValueForProperty; }
	}
	public void PlayHurtSound()
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		
		this.m_flNextHurtSound = GetGameTime(this.index) + 1.0;
		EmitCustomToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, 3.0);
	}
	public void PlayDeathSound()
	{
		EmitCustomToAll("cof/purnell/death.mp3", _, _, _, _, 2.0);
	}
	public void PlayIntroSound()
	{
		EmitCustomToAll("cof/purnell/intro.mp3", _, _, _, _, 3.0);
	}
	public void PlayFriendlySound()
	{
		EmitCustomToAll("cof/purnell/converted.mp3", this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, 2.0);
	}
	public void PlayReloadSound()
	{
		EmitCustomToAll("cof/purnell/reload.mp3", this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, 1.75);
	}
	public void PlayShootSound()
	{
		EmitCustomToAll("cof/purnell/shoot.mp3", this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, 2.7);
	}
	public void PlayMeleeSound()
	{
		this.m_flNextHurtSound = GetGameTime(this.index) + 1.0;
		EmitCustomToAll("cof/purnell/shove.mp3", this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, 3.0);
	}
	public void PlayHitSound()
	{
		EmitCustomToAll("cof/purnell/meleehit.mp3", this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, 3.0);
	}
	public void PlayKillSound()
	{
		this.m_flNextHurtSound = GetGameTime(this.index) + 2.0;
		EmitCustomToAll(g_KillSounds[GetRandomInt(0, sizeof(g_KillSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, 3.0);
	}
	public void PlaySummonSound() 
	{
		EmitSoundToAll(g_SummonSounds[GetRandomInt(0, sizeof(g_SummonSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		int r = 200;
		int g = 200;
		int b = 255;
		int a = 200;
		
		spawnRing(this.index, 75.0 * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 1.0, 6.0, 6.1, 1);
		spawnRing(this.index, 75.0 * 2.0, 0.0, 0.0, 15.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.9, 6.0, 6.1, 1);
		spawnRing(this.index, 75.0 * 2.0, 0.0, 0.0, 25.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.8, 6.0, 6.1, 1);
		spawnRing(this.index, 75.0 * 2.0, 0.0, 0.0, 35.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.7, 6.0, 6.1, 1);
		spawnRing(this.index, 75.0 * 2.0, 0.0, 0.0, 45.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.6, 6.0, 6.1, 1);
		spawnRing(this.index, 75.0 * 2.0, 0.0, 0.0, 55.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.5, 6.0, 6.1, 1);
		spawnRing(this.index, 75.0 * 2.0, 0.0, 0.0, 65.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.4, 6.0, 6.1, 1);
		spawnRing(this.index, 75.0 * 2.0, 0.0, 0.0, 75.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.3, 6.0, 6.1, 1);
		spawnRing(this.index, 75.0 * 2.0, 0.0, 0.0, 85.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.2, 6.0, 6.1, 1);
	}
	public DasNaggenvatcher(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		int WaveSetting = 1;
		char SizeChar[5];
		SizeChar = "1.35";
		if(StrContains(data, "first") != -1)
		{
			WaveSetting = 1;
			SizeChar = "1.0";
		}
		else if(StrContains(data, "second") != -1)
		{
			WaveSetting = 2;
			SizeChar = "1.0";
		}
		else if(StrContains(data, "third") != -1)
		{
			WaveSetting = 3;
			SizeChar = "1.0";
		}
		else if(StrContains(data, "forth") != -1)
		{
			//outside of wave stuff.
			WaveSetting = 4;
			SizeChar = "1.0";
		}
		else if(StrContains(data, "shadowbattle") != -1)
		{
			//outside of wave stuff.
			WaveSetting = 6;
			SizeChar = "1.0";
		}
		else if(StrContains(data, "shadowcutscene") != -1)
		{
			//outside of wave stuff.z
			WaveSetting = 7;
			SizeChar = "1.0";
		}
		else if(StrContains(data, "final_item") != -1)
		{
			WaveSetting = 5;
			SizeChar = "1.0";
		}
		DasNaggenvatcher npc = view_as<DasNaggenvatcher>(CClotBody(vecPos, vecAng, "models/player/spy.mdl", SizeChar, "7000000", ally, false, true));
		i_NpcWeight[npc.index] = 3;
		
		SetEntityRenderMode(npc.index, RENDER_NONE);

		npc.m_iState = -1;
		npc.SetActivity("ACT_MP_RUN_SECONDARY");
		
		if(ally == TFTeam_Red)
		{
			npc.PlayFriendlySound();
		}
		else
		{
			npc.PlayIntroSound();
		}
		
		npc.g_TimesSummoned = 0;
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/player/medic.mdl");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/medic/jul13_bro_plate/jul13_bro_plate.mdl");

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/sbxo2014_medic_wintergarb_coat/sbxo2014_medic_wintergarb_coat.mdl");

		npc.m_iWearable4 = npc.EquipItem("head", "models/player/items/medic/medic_clipboard.mdl");

		npc.m_iWearable5 = npc.EquipItem("head", "models/weapons/c_models/c_ambassador/c_ambassador.mdl");
		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", 1);
		
		i_RaidGrantExtra[npc.index] = WaveSetting;
		if(WaveSetting == 6 || WaveSetting == 7)
		{
			npc.m_bDissapearOnDeath = true;
		}
		if(WaveSetting == 5 || WaveSetting == 7)
		{
			//lazy identifier lol
			if(WaveSetting == 7)
			{
				b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true;
			}
			b_NpcUnableToDie[npc.index] = true;
		}

		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, DasNaggenvatcher_OnTakeDamagePost);
		func_NPCOnTakeDamage[npc.index] = DasNaggenvatcher_OnTakeDamage;
		npc.m_iInjuredLevel = 0;
		npc.m_bThisNpcIsABoss = true;
		npc.m_iTarget = -1;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_bDissapearOnDeath = false;
		i_ClosestAllyCDTarget[npc.index] = 0.0;
		g_dasnaggenvatcher_died=false;
		g_dasnaggenvatcher_die=0.0;
		
		RaidModeTime = GetGameTime(npc.index) + 300.0;
		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = true;
		npc.Anger = false;
		
		char buffers[3][64];
		ExplodeString(data, ";", buffers, sizeof(buffers), sizeof(buffers[]));
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
			
		RaidModeScaling *= amount_of_people; //More then 9 and he raidboss gets some troubles, bufffffffff
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		
		npc.m_flNextRangedAttack = 0.0;
		npc.m_iAttacksTillReload = 5;
		npc.m_flReloadDelay = GetGameTime(npc.index) + 0.8;

		float wave = float(Waves_GetRoundScale()+1);
		wave *= 0.133333;
		npc.m_flWaveScale = wave;
		npc.m_flWaveScale *= MinibossScalingReturn();
		
		npc.m_flNextRangedSpecialAttack = 0.0;

		func_NPCDeath[npc.index] = view_as<Function>(DasNaggenvatcher_NPCDeath);
		func_NPCThink[npc.index] = view_as<Function>(DasNaggenvatcher_ClotThink);
		
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "voice_player", 1, "%t", "DasNaggenvatcher Spawned");
				UTIL_ScreenFade(client_check, 180, 1, FFADE_OUT, 0, 0, 0, 255);
			}
		}

		return npc;
	}
	
	public void SetActivity(const char[] animation)
	{
		int activity = this.LookupActivity(animation);
		if(activity > 0 && activity != this.m_iState)
		{
			this.m_iState = activity;
			//this.m_bisWalking = false;
			this.StartActivity(activity);
		}
	}
	property int m_iInjuredLevel
	{
		public get()		{ return this.m_iMedkitAnnoyance; }
		public set(int value) 	{ this.m_iMedkitAnnoyance = value; }
	}
}

public void DasNaggenvatcher_ClotThink(int iNPC)
{
	DasNaggenvatcher npc = view_as<DasNaggenvatcher>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.04;
	npc.Update();
	
	if(npc.m_flNextRangedSpecialAttack < gameTime)
	{
		npc.m_flNextRangedSpecialAttack = gameTime + 0.25;
		
		int target = GetClosestAlly(npc.index, (250.0 * 250.0), _,DasNaggenvatcherBuffAlly);
		if(target)
		{
			if(!HasSpecificBuff(target, "False Therapy"))
			{
				ApplyStatusEffect(npc.index, target, "False Therapy", 30.0);
				npc.AddGesture("ACT_MP_GESTURE_VC_FISTPUMP_SECONDARY",_,_,_,3.0);
			}
		}
	}
	
	if(npc.m_iTarget > 0 && !IsValidEnemy(npc.index, npc.m_iTarget))
	{
		if(npc.m_iTarget <= MaxClients)
			npc.PlayKillSound();
		
		npc.m_iTarget = 0;
		npc.m_flGetClosestTargetTime = 0.0;
	}

	if(!IsValidAlly(npc.index, npc.m_iTargetAlly))
	{
		if(i_ClosestAllyCDTarget[npc.index] < GetGameTime(npc.index))
		{
			npc.m_iTargetAlly = GetClosestAlly(npc.index, _, _,DasNaggenvatcherBuffAlly);
			i_ClosestAllyCDTarget[npc.index] = GetGameTime(npc.index) + 1.0;
		}
	}
	else
	{
		i_ClosestAllyCDTarget[npc.index] = GetGameTime(npc.index) + 0.0;
	}

	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_flGetClosestTargetTime = gameTime + 0.5;
		npc.m_iTarget = GetClosestTarget(npc.index, true);
	}
	if(IsValidAlly(npc.index, npc.m_iTargetAlly) && IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTargetally[3]; WorldSpaceCenter(npc.m_iTargetAlly, vecTargetally);
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float vecPos[3]; WorldSpaceCenter(npc.index, vecPos );
		
		float distanceToAlly = GetVectorDistance(vecTargetally, vecPos, true);
		float distanceToEnemy = GetVectorDistance(vecTarget, vecTargetally, true);
		if(distanceToAlly > (140.0 * 140.0) && npc.m_iTargetWalkTo < (50.0 * 50.0)) //get close to ally but not too close
		{
			npc.m_iTargetWalkTo = npc.m_iTargetAlly;
		}
		else
		{
			if(distanceToEnemy < (200.0 * 200.0)) //enemy is too close to friend, follow enemy
			{
				npc.m_iTargetWalkTo = npc.m_iTargetAlly;
			}
		}
	}
	else
	{
		npc.m_iTargetWalkTo = npc.m_iTarget;
	}
	
	int behavior = -1;
	
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			npc.m_iAttacksTillReload++;
			
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				Handle swingTrace;
				float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
				npc.FaceTowards(VecEnemy, 15000.0);
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget))
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					
					if(target > 0) 
					{
						float damage = 50.0;
											
											
						if(!ShouldNpcDealBonusDamage(target))
							SDKHooks_TakeDamage(target, npc.index, npc.index, damage * npc.m_flWaveScale, DMG_CLUB, -1, _, vecHit);
						else
							SDKHooks_TakeDamage(target, npc.index, npc.index, damage * 3.0 * npc.m_flWaveScale, DMG_CLUB, -1, _, vecHit);

						Custom_Knockback(npc.index, target, 500.0);
						npc.m_iAttacksTillReload++;
						npc.PlayHitSound();
					}
				}
				delete swingTrace;
			}
		}
		
		behavior = 0;
	}
	
	if(behavior == -1)
	{
		if(npc.m_iTarget > 0 && npc.m_iTargetWalkTo > 0)	// We have a target
		{
			float vecPos[3]; WorldSpaceCenter(npc.index, vecPos );
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
			
			float distance = GetVectorDistance(vecTarget, vecPos, true);
			if(distance < 10000.0 && npc.m_flNextMeleeAttack < gameTime)	// Close at any time: Melee
			{
				npc.FaceTowards(vecTarget, 15000.0);
				
				npc.AddGesture("ACT_MP_THROW");
				npc.PlayMeleeSound();
				
				npc.m_flAttackHappens = gameTime + 0.3;
				npc.m_flReloadDelay = gameTime + 0.6;
				npc.m_flNextMeleeAttack = gameTime + 1.0;
				
				behavior = 0;
			}
			else if(npc.m_flReloadDelay > gameTime)	// Reloading
			{
				behavior = 0;
			}
			else if(distance < 80000.0)	// In shooting range
			{
				if(npc.m_flNextRangedAttack < gameTime)	// Not in attack cooldown
				{
					if(npc.m_iAttacksTillReload > 0)	// Has ammo
					{
						int Enemy_I_See;
				
						Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
						//Target close enough to hit
						if(IsValidEnemy(npc.index, npc.m_iTarget) && npc.m_iTarget == Enemy_I_See)
						{
							behavior = 0;
							npc.SetActivity("ACT_MP_STAND_SECONDARY");
							
							npc.FaceTowards(vecTarget, 15000.0);
							
							npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY");
							
							npc.m_flNextRangedAttack = gameTime + 1.0;
							npc.m_iAttacksTillReload--;
							
							PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, 700.0, _,vecTarget);
							float damage = 50.0;

							npc.FireRocket(vecTarget, damage * 0.9 * npc.m_flWaveScale, 700.0, "models/weapons/w_bullet.mdl", 2.0);
							
							npc.PlayShootSound();
						}
						else	// Something in the way, move closer
						{
							behavior = 1;
						}
					}
					else	// No ammo, retreat
					{
						behavior = 3;
					}
				}
				else	// In attack cooldown
				{
					behavior = 0;
					npc.SetActivity("ACT_MP_STAND_SECONDARY");
				}
			}
			else if(npc.m_iAttacksTillReload < 0)	// Take the time to reload
			{
				//Only if low ammo, otherwise it can be abused.
				behavior = 4;
			}
			else	// Sprint Time
			{
				behavior = 2;
			}
		}
		else if(npc.m_flReloadDelay > gameTime)	// Reloading...
		{
			behavior = 0;
		}
		else if(npc.m_iAttacksTillReload < 5)	// Nobody here..?
		{
			behavior = 4;
		}
		else	// What do I do...
		{
			behavior = 0;
		}
	}
	
	// Reload anyways if we can't run
	if(npc.m_flRangedSpecialDelay && behavior == 3 && npc.m_flRangedSpecialDelay > gameTime)
		behavior = 4;
	
	switch(behavior)
	{
		case 0:	// Stand
		{
			// Activity handled above
			npc.m_flSpeed = 0.0;
			
			if(npc.m_bPathing)
			{
				npc.StopPathing();
				
			}
		}
		case 1:	// Move After the Player
		{
			npc.SetActivity("ACT_MP_RUN_SECONDARY");
			npc.m_flSpeed = 200.0;
			npc.m_flRangedSpecialDelay = 0.0;
			
			npc.SetGoalEntity(npc.m_iTargetWalkTo);
			if(!npc.m_bPathing)
				npc.StartPathing();
		}
		case 2:	// Sprint After the Player
		{
			npc.SetActivity("ACT_MP_RUN_SECONDARY");
			npc.m_flSpeed = 250.0;
			npc.m_flRangedSpecialDelay = 0.0;
			
			npc.SetGoalEntity(npc.m_iTargetWalkTo);
			if(!npc.m_bPathing)
				npc.StartPathing();
		}
		case 3:	// Retreat
		{
			npc.m_flSpeed = 500.0;
			
			if(!npc.m_flRangedSpecialDelay)	// Reload anyways timer
				npc.m_flRangedSpecialDelay = gameTime + 4.0;
			
			float vBackoffPos[3]; BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTargetWalkTo,_,vBackoffPos);
			npc.SetGoalVector(vBackoffPos);
			
			if(!npc.m_bPathing)
				npc.StartPathing();
		}
		case 4:	// Reload
		{
			npc.AddGesture("ACT_MP_RELOAD_STAND_SECONDARY",_,_,_,0.25);
			npc.m_flSpeed = 0.0;
			npc.m_flRangedSpecialDelay = 0.0;
			npc.m_flReloadDelay = gameTime + 4.25;
			npc.m_iAttacksTillReload = 5;
			
			if(npc.m_bPathing)
			{
				npc.StopPathing();
				
			}
			
			npc.PlayReloadSound();
		}
	}
	if(GetTeam(npc.index) != TFTeam_Red && LastMann)
	{
		if(!npc.m_fbGunout)
		{
			npc.m_fbGunout = true;
			RaidModeTime = GetGameTime() + 10.0;
			switch(GetRandomInt(0,3))
			{
				case 0:
				{
					CPrintToChatAll("{crimson}다스 고르통보호기 메딕{default}: 너 혼자서는 아무것도 하지 못 한다!");
				}
				case 1:
				{
					CPrintToChatAll("{crimson}다스 고르통보호기 메딕{default}: 영광스러운 합일에 동참하라.");
				}
				case 2:
				{
					CPrintToChatAll("{crimson}다스 고르통보호기 메딕{default}: 지금 항복할텐가?!");
				}
				case 3:
				{
					CPrintToChatAll("{crimson}다스 고르통보호기 메딕{default}: 너가 그래도 니 동료들보단 나은것 같군");
				}
			}
		}
	}
	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}
	if(npc.m_flDoingSpecial < gameTime)
	{
		npc.m_flRangedArmor = 1.0;
		npc.m_flMeleeArmor = 1.25;
	}
	else
	{
		npc.m_flRangedArmor = 0.5;
		npc.m_flMeleeArmor = 0.65;
	}
	if(npc.g_TimesSummoned == 4)
	{
		bool allyAlive = false;
		for(int targ; targ<i_MaxcountNpcTotal; targ++)
		{
			int baseboss_index = EntRefToEntIndexFast(i_ObjectsNpcsTotal[targ]);
			if (IsValidEntity(baseboss_index) && !b_NpcHasDied[baseboss_index] && i_NpcInternalId[baseboss_index] != NPCId && GetTeam(npc.index) == GetTeam(baseboss_index))
			{
				allyAlive = true;
			}
		}
		if(!Waves_IsEmpty())
			allyAlive = true;

		if(GetTeam(npc.index) == TFTeam_Red)
			allyAlive = false;

		if(allyAlive)
		{
			b_NpcIsInvulnerable[npc.index] = true;
		}
		else
		{
			if(!npc.Anger)
			{
				DasNaggenvatcherSayWordsAngry(npc.index);
				npc.Anger = true;
				b_NpcIsInvulnerable[npc.index] = false;
			}
		}
	}
	if(!npc.m_flMaxDeath && RaidModeTime < GetGameTime())
	{
		npc.m_flMaxDeath = 1.0;
		ForcePlayerLoss();
		RaidBossActive = INVALID_ENT_REFERENCE;
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		switch(GetRandomInt(0,3))
		{
			case 0:
			{
				CPrintToChatAll("{crimson}다스 고르통보호기 메딕{crimson}: 정말 한심하기 짝이없군 고작 이따위 결과를 보려고 우리가 온것이 아닌데");
			}
			case 1:
			{
				CPrintToChatAll("{crimson}다스 고르통보호기 메딕{crimson}: 너네 그냥 집에 가라. 너희 같은 것들은 우리와 함께 할 수 없다.");
			}
			case 2:
			{
				CPrintToChatAll("{crimson}다스 고르통보호기 메딕{crimson}: 고작 이따위 것들을 상대하려고 우리가 시간낭비를 했단 말인가?");
			}
			case 3:
			{
				CPrintToChatAll("{crimson}다스 고르통보호기 메딕{crimson}: 우리가 이딴 약골들에게 쩔쩔맸단 말인가...");
			}
		}
		
		return;
	}
	if(g_dasnaggenvatcher_died)
	{
		npc.m_flNextThinkTime = 0.0;
		npc.StopPathing();
		
		npc.m_bisWalking = false;
		npc.SetActivity("ACT_MP_CROUCH_MELEE");
		npc.m_bisWalking = false;
		if(gameTime > g_dasnaggenvatcher_die)
		{
			RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
			npc.m_bDissapearOnDeath = true;
			SpawnMoney(npc.index, true);
			npc.PlayDeathSound();
		}
		else if(gameTime + 4.0 > g_dasnaggenvatcher_die && i_SaidLineAlready[npc.index] < 9)
		{
			i_SaidLineAlready[npc.index] = 9;
			CPrintToChatAll("{crimson}불결한 존재{default}: 증명할 시간이다!!!!");
		}
		else if(gameTime + 8.0 > g_dasnaggenvatcher_die && i_SaidLineAlready[npc.index] < 8)
		{
			i_SaidLineAlready[npc.index] = 8;
			CPrintToChatAll("{crimson}불결한 존재{default}: 이제 너희의 존재를...");
		}
		else if(gameTime + 12.0 > g_dasnaggenvatcher_die && i_SaidLineAlready[npc.index] < 7)
		{
			i_SaidLineAlready[npc.index] = 7;
			CPrintToChatAll("{crimson}불결한 존재{default}: 아주 오랜 시간 동안... 지금이 오기만을 기다려왔다.");
		}
		else if(gameTime + 16.0 > g_dasnaggenvatcher_die && i_SaidLineAlready[npc.index] < 6)
		{
			i_SaidLineAlready[npc.index] = 6;
			CPrintToChatAll("{crimson}다스 고르통보호기 메딕?{default}: 다만, 아직 마지막 테스트가 필요하다.{crimson} 이 테스트가 끝나면 너희도 우리와 하나가 되리라.");
		}
		else if(gameTime + 20.0 > g_dasnaggenvatcher_die && i_SaidLineAlready[npc.index] < 5)
		{
			i_SaidLineAlready[npc.index] = 5;
			CPrintToChatAll("{crimson}다스 고르통보호기 메딕{default}: 우리의 결속은 자라나고 우리는 영생을 누리리라.");
		}
		else if(gameTime + 24.0 > g_dasnaggenvatcher_die && i_SaidLineAlready[npc.index] < 4)
		{
			i_SaidLineAlready[npc.index] = 4;
			CPrintToChatAll("{crimson}다스 고르통보호기 메딕{default}: 우리가 집어삼킨 세계마다 새로운 형제가 일어나 하나가 되리라.");
		}
		else if(gameTime + 28.0 > g_dasnaggenvatcher_die && i_SaidLineAlready[npc.index] < 3)
		{
			i_SaidLineAlready[npc.index] = 3;
			CPrintToChatAll("{crimson}다스 고르통보호기 메딕{default}: 역시 너희도 우리와 하나가 되어야만 한다.");
		}
		else if(gameTime + 32.0 > g_dasnaggenvatcher_die && i_SaidLineAlready[npc.index] < 2)
		{
			i_SaidLineAlready[npc.index] = 2;
			CPrintToChatAll("{crimson}다스 고르통보호기 메딕{default}: 그리고 너희는 우리의 기대에 정확히 부합했다.");
		}
		else if(gameTime + 36.0 > g_dasnaggenvatcher_die && i_SaidLineAlready[npc.index] < 1)
		{
			i_SaidLineAlready[npc.index] = 1;
			CPrintToChatAll("{crimson}다스 고르통보호기 메딕{default}: 너희를 오랜 시간 동안 지켜보고 있었다.");
		}
	}
}

public Action DasNaggenvatcher_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	DasNaggenvatcher npc = view_as<DasNaggenvatcher>(victim);
	if(npc.m_flReviveDasNaggenvatcherTime > GetGameTime(npc.index))
	{
		damage = 0.0;
		return Plugin_Handled;
	}
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	if(!npc.Anger)
	{
		int health = GetEntProp(victim, Prop_Data, "m_iHealth") - RoundToCeil(damage);
		if(health < 1)
		{
			SetEntProp(victim, Prop_Data, "m_iHealth", 1);
			damage = 0.0;
			return Plugin_Handled;
		}
	}
	if(npc.Anger && RoundToCeil(damage) >= GetEntProp(npc.index, Prop_Data, "m_iHealth"))
	{
		if(!g_dasnaggenvatcher_died)
		{
			b_NpcIsInvulnerable[npc.index] = true;
			b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true;
			g_dasnaggenvatcher_died=true;
			npc.m_bThisNpcIsABoss = false;
			RemoveNpcFromEnemyList(npc.index);
			if(EntRefToEntIndex(RaidBossActive)==npc.index)
				RaidBossActive = INVALID_ENT_REFERENCE;
			g_dasnaggenvatcher_die = GetGameTime(npc.index) + 40.0;
			
			SetEntProp(npc.index, Prop_Data, "m_iHealth", 1);
			damage = 0.0;
		}
	}
	return Plugin_Changed;
}
public void DasNaggenvatcher_OnTakeDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype) 
{
	DasNaggenvatcher npc = view_as<DasNaggenvatcher>(victim);
	float maxhealth = float(ReturnEntityMaxHealth(npc.index));
	float health = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));
	float Ratio = health / maxhealth;
	if(Ratio <= 0.85 && npc.g_TimesSummoned < 1)
	{
		npc.g_TimesSummoned = 1;
		npc.PlaySummonSound();
		npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
			
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_zombie_soldier_pickaxe",22000, RoundToCeil(6.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_zombie_soldier",20000, RoundToCeil(6.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_zombie_demoknight",17500, RoundToCeil(6.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_zombie_heavy",15000, RoundToCeil(4.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_zombie_engineer",12500, RoundToCeil(4.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_kamikaze_demo",3000, RoundToCeil(6.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_random_zombie", RoundToCeil(300000.0 * MultiGlobalHighHealthBoss), 1);
	}
	else if(Ratio <= 0.55 && npc.g_TimesSummoned < 2)
	{
		npc.g_TimesSummoned = 2;
		npc.PlaySummonSound();
		npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
				
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_eradicator",30000, RoundToCeil(6.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_vile_poisonheadcrab_zombie",60000, RoundToCeil(6.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_fastheadcrab_zombie",30000, RoundToCeil(6.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_vile_bloated_zombie",30000, RoundToCeil(6.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_random_zombie", RoundToCeil(300000.0 * MultiGlobalHighHealthBoss), 1);
	}
	else if(Ratio <= 0.35 && npc.g_TimesSummoned < 3)
	{
		npc.g_TimesSummoned = 3;
		npc.PlaySummonSound();
		npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
			
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_ihbc",25000, RoundToCeil(5.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_firefighter",50000, RoundToCeil(5.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_zombie_breadmonster",30000, RoundToCeil(5.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_zombie_fatscout",30000, RoundToCeil(5.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_zombie_fatspy",30000, RoundToCeil(2.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_sniper",20000, RoundToCeil(2.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_cleaner",40000, RoundToCeil(2.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_ninja_zombie_spy",25, RoundToCeil(2.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_malfunctioning_heavy", RoundToCeil(300000.0 * MultiGlobalHighHealthBoss), 1);
	}
	else if(Ratio <= 0.20 && npc.g_TimesSummoned < 4)
	{
		SetEntProp(npc.index, Prop_Data, "m_iHealth", ReturnEntityMaxHealth(npc.index) / 4);
		DasNaggenvatcherSayWords(npc.index);
		npc.g_TimesSummoned = 4;
		npc.PlaySummonSound();
		
		npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_sniper",20000, RoundToCeil(2.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_mlsm",40000, RoundToCeil(3.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_sam",40000, RoundToCeil(3.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_medic_main",25000, RoundToCeil(6.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_major_vulture",RoundToCeil(300000.0 * MultiGlobalHighHealthBoss), 1);
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_soldier_barrager", RoundToCeil(300000.0 * MultiGlobalHighHealthBoss), 1, true);
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_flesh_creeper", RoundToCeil(300000.0 * MultiGlobalHighHealthBoss), 1, true);
	}			
}

void DasNaggenvatcherSpawnEnemy(int dasnaggenvatcher, char[] plugin_name, int health = 0, int count, bool is_a_boss = false)
{
	if(GetTeam(dasnaggenvatcher) == TFTeam_Red)
	{
		count /= 2;
		if(count < 1)
		{
			count = 1;
		}
		for(int Spawns; Spawns <= count; Spawns++)
		{
			float pos[3]; GetEntPropVector(dasnaggenvatcher, Prop_Data, "m_vecAbsOrigin", pos);
			float ang[3]; GetEntPropVector(dasnaggenvatcher, Prop_Data, "m_angRotation", ang);
			
			int summon = NPC_CreateByName(plugin_name, -1, pos, ang, GetTeam(dasnaggenvatcher));
			if(summon > MaxClients)
			{
				fl_Extra_Damage[summon] = 10.0;
				if(!health)
				{
					health = GetEntProp(summon, Prop_Data, "m_iMaxHealth");
				}
				SetEntProp(summon, Prop_Data, "m_iHealth", health / 10);
				SetEntProp(summon, Prop_Data, "m_iMaxHealth", health / 10);
			}
		}
		return;
	}
		
	Enemy enemy;
	enemy.Index = NPC_GetByPlugin(plugin_name);
	if(health != 0)
	{
		enemy.Health = health;
	}
	enemy.Is_Boss = view_as<int>(is_a_boss);
	enemy.Is_Immune_To_Nuke = true;
	//do not bother outlining.
	enemy.ExtraMeleeRes = 1.0;
	enemy.ExtraRangedRes = 1.0;
	enemy.ExtraSpeed = 1.0;
	enemy.ExtraDamage = 1.0;
	enemy.ExtraSize = 1.0;		
	enemy.Team = GetTeam(dasnaggenvatcher);
	
	if(!Waves_InFreeplay())
	{
		for(int i; i<count; i++)
		{
			Waves_AddNextEnemy(enemy);
		}
	}
	else
	{
		int postWaves = CurrentRound - Waves_GetMaxRound();
		char npc_classname[60];
		NPC_GetPluginById(i_NpcInternalId[enemy.Index], npc_classname, sizeof(npc_classname));

		Freeplay_AddEnemy(postWaves, enemy, count, true);
		if(count > 0)
		{
			for(int a; a < count; a++)
			{
				Waves_AddNextEnemy(enemy);
			}
		}
	}

	Zombies_Currently_Still_Ongoing += count;
}

void DasNaggenvatcherSayWords(int entity)
{
	if(i_RaidGrantExtra[entity] >= 1)
	{
		switch(GetRandomInt(0,3))
		{
			case 0:
			{
				CPrintToChatAll("{crimson}다스 고르통보호기 메딕{default}: 우리에게서 결코 도망치지 못할 것이다.");
			}
			case 1:
			{
				CPrintToChatAll("{crimson}다스 고르통보호기 메딕{default}: 좋아, 친구들. 우리가 가진 모든걸 쏟아부어라! 우리는 여기서 더이상 낭비할 시간이 없다!");
			}
			case 2:
			{
				CPrintToChatAll("{crimson}다스 고르통보호기 메딕{default}: 우리는 하나가 되어 결코 패배하지 않을 것이다!");
			}
			case 3:
			{
				CPrintToChatAll("{crimson}다스 고르통보호기 메딕{default}: 너희도 우리와 하나가 될것이다.");
			}
		}
	}
}
void DasNaggenvatcherSayWordsAngry(int entity)
{
	if(i_RaidGrantExtra[entity] >= 1)
	{
		switch(GetRandomInt(0,3))
		{
			case 0:
			{
				CPrintToChatAll("{crimson}다스 고르통보호기 메딕{default}: {default}영광스러운 합일에 동참하라.");
			}
			case 1:
			{
				CPrintToChatAll("{crimson}다스 고르통보호기 메딕{default}: {default}내 기대를 실망시키지 않는군, 역시 너희는 우리와 함께할 자격이 있다.");
			}
			case 2:
			{
				CPrintToChatAll("{crimson}다스 고르통보호기 메딕{default}: {default}너희도 우리와 하나가 될것이다.");
			}
			case 3:
			{
				CPrintToChatAll("{crimson}다스 고르통보호기 메딕{default}: {default}우리의 약한 친구들은 도태 되었지만 강한 친구들은 아직 살아있다. 그것이 바로 너희가 될것이다.");
			}
		}
	}
}

public void DasNaggenvatcher_NPCDeath(int entity)
{
	DasNaggenvatcher npc = view_as<DasNaggenvatcher>(entity);

	npc.SetModel("models/player/medic.mdl");
	SetEntityRenderColor(npc.index, 255, 255, 255, 255);

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
	
	npc.PlayDeathSound();
}


public bool DasNaggenvatcherBuffAlly(int provider, int entity)
{
	if(HasSpecificBuff(entity, "False Therapy"))
		return false;

	return true;
}