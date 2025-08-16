#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/mvm/norm/scout_mvm_paincrticialdeath01.mp3",
	"vo/mvm/norm/scout_mvm_paincrticialdeath02.mp3",
	"vo/mvm/norm/scout_mvm_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/mvm/norm/scout_mvm_painsharp01.mp3",
	"vo/mvm/norm/scout_mvm_painsharp02.mp3",
	"vo/mvm/norm/scout_mvm_painsharp03.mp3",
	"vo/mvm/norm/scout_mvm_painsharp04.mp3",
	"vo/mvm/norm/scout_mvm_painsharp05.mp3",
	"vo/mvm/norm/scout_mvm_painsharp06.mp3",
	"vo/mvm/norm/scout_mvm_painsharp07.mp3",
	"vo/mvm/norm/scout_mvm_painsharp08.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/mvm/norm/scout_mvm_battlecry01.mp3",
	"vo/mvm/norm/scout_mvm_battlecry02.mp3",
	"vo/mvm/norm/scout_mvm_battlecry03.mp3",
	"vo/mvm/norm/scout_mvm_battlecry04.mp3",
	"vo/mvm/norm/scout_mvm_battlecry05.mp3",
};

static const char g_OrbBarrageAlertSounds[][] = {
	"vo/mvm/norm/taunts/scout_mvm_taunts13.mp3",
	"vo/mvm/norm/taunts/scout_mvm_taunts15.mp3",
	"vo/mvm/norm/scout_mvm_dominationpyr01.mp3",
	"vo/mvm/norm/scout_mvm_dominationsol05.mp3",
	"vo/mvm/norm/scout_mvm_stunballhit15.mp3",
};

static const char g_OrbBarrageDizzySounds[][] = {
	"vo/mvm/norm/scout_mvm_invinciblenotready06.mp3",
	"vo/mvm/norm/scout_mvm_invinciblenotready07.mp3",
	"vo/mvm/norm/scout_mvm_autodejectedtie04.mp3",
	"vo/mvm/norm/scout_mvm_negativevocalization01.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/machete_swing.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/bat_hit.wav",
};

static const char g_MeleeHardHitSounds[][] = {
	"mvm/melee_impacts/bat_baseball_hit_robo01.wav",
};

static const char g_RangedAttackSounds[][] = {
	"weapons/capper_shoot.wav",
};

static const char g_BoomSounds[][] = {
	"weapons/sentry_damage1.wav",
	"weapons/sentry_damage2.wav",
	"weapons/sentry_damage3.wav",
	"weapons/sentry_damage4.wav",
};

static const char g_StunCat[][] = {
	"mvm/mvm_tank_deploy.wav",
};
static const char g_StunCatEnd[][] = {
	"mvm/mvm_tele_activate.wav",
};

static const char g_PassiveSound[][] = {
	"mvm/giant_scout/giant_scout_loop.wav",
};

#define CAT_DEFAULT_SPEED 300.0

#define CAT_ORB_SPAM_ABILITY_DURATION 3.0
#define CAT_ORB_SPAM_ABILITY_AMOUNT 40
#define CAT_ORB_SPAM_ABILITY_COLLISION_MODEL "models/weapons/w_models/w_cannonball.mdl"

#define CAT_SELF_DEGRADATION_ABILITY_DURATION 15.0
#define CAT_SELF_DEGRADATION_ABILITY_EFFECT "burningplayer_rainbow_stars02"

enum
{
	CAT_ORB_SPAM_ABILITY_STATE_NONE,
	CAT_ORB_SPAM_ABILITY_STATE_READYING_UP,
	CAT_ORB_SPAM_ABILITY_STATE_FIRING,
	CAT_ORB_SPAM_ABILITY_STATE_COOLING_OFF
}

enum
{
	CAT_SELF_DEGRADATION_ABILITY_STATE_NONE,
	CAT_SELF_DEGRADATION_ABILITY_STATE_ACTIVATING,
	CAT_SELF_DEGRADATION_ABILITY_STATE_ACTIVE,
}

static float NextOrbDamage[MAXENTITIES];

void CAT_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "C.A.T.");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_cat");
	strcopy(data.Icon, sizeof(data.Icon), "cat");
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
	for (int i = 0; i < (sizeof(g_OrbBarrageAlertSounds)); i++) { PrecacheSound(g_OrbBarrageAlertSounds[i]); }
	for (int i = 0; i < (sizeof(g_OrbBarrageDizzySounds)); i++) { PrecacheSound(g_OrbBarrageDizzySounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHardHitSounds)); i++) { PrecacheSound(g_MeleeHardHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds)); i++) { PrecacheSound(g_RangedAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_BoomSounds));   i++) { PrecacheSound(g_BoomSounds[i]);   }
	for (int i = 0; i < (sizeof(g_StunCat));   i++) { PrecacheSound(g_StunCat[i]);   }
	for (int i = 0; i < (sizeof(g_StunCatEnd));   i++) { PrecacheSound(g_StunCatEnd[i]);   }
	for (int i = 0; i < (sizeof(g_PassiveSound));   i++) { PrecacheSound(g_PassiveSound[i]);   }
	
	PrecacheSoundCustom("#zombiesurvival/aperture/cat.mp3");
	PrecacheSound("mvm/mvm_tank_end.wav");
	PrecacheModel("models/bots/scout/bot_scout.mdl");
	PrecacheModel(CAT_ORB_SPAM_ABILITY_COLLISION_MODEL);
	
	PrecacheParticleSystem(CAT_SELF_DEGRADATION_ABILITY_EFFECT);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return CAT(vecPos, vecAng, ally, data);
}
methodmap CAT < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, 90, BOSS_ZOMBIE_VOLUME, 80);
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
	public void PlayOrbBarrageAlertSound()
	{
		EmitSoundToAll(g_OrbBarrageAlertSounds[GetRandomInt(0, sizeof(g_OrbBarrageAlertSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, 90, BOSS_ZOMBIE_VOLUME, 80);
	}
	public void PlayOrbBarrageDizzySound()
	{
		EmitSoundToAll(g_OrbBarrageDizzySounds[GetRandomInt(0, sizeof(g_OrbBarrageDizzySounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, 90, BOSS_ZOMBIE_VOLUME, 80);
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHardHitSound() 
	{
		EmitSoundToAll(g_MeleeHardHitSounds[GetRandomInt(0, sizeof(g_MeleeHardHitSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRangedSound()
	{
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, 100, _, BOSS_ZOMBIE_VOLUME, 110);
	}
	public void PlayBoomSound() 
	{
		EmitSoundToAll(g_BoomSounds[GetRandomInt(0, sizeof(g_BoomSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRevivalStart()
	{
		EmitSoundToAll(g_StunCat[GetRandomInt(0, sizeof(g_StunCat) - 1)], this.index, SNDCHAN_STATIC, 100, _, 1.0, 100);
	}
	public void PlayRevivalEnd()
	{
		EmitSoundToAll(g_StunCatEnd[GetRandomInt(0, sizeof(g_StunCatEnd) - 1)], this.index, SNDCHAN_STATIC, 100, _, 1.0, 100);
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
	
	property float m_flNextOrbAbilityTime
	{
		public get()							{ return fl_NextRangedSpecialAttackHappens[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextRangedSpecialAttackHappens[this.index] = TempValueForProperty; }
	}
	
	property float m_flNextSelfDegradationAbilityTime
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	
	property int m_iOrbAbilityState
	{
		public get()							{ return i_AttacksTillReload[this.index]; }
		public set(int TempValueForProperty) 	{ i_AttacksTillReload[this.index] = TempValueForProperty; }
	}
	
	property float m_flNextOrbAbilityState
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	
	property int m_iSelfDegradationAbilityState
	{
		public get()							{ return i_AttacksTillMegahit[this.index]; }
		public set(int TempValueForProperty) 	{ i_AttacksTillMegahit[this.index] = TempValueForProperty; }
	}
	
	property float m_flNextSelfDegradationAbilityState
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flLifeReversal
	{
		public get()							{ return fl_AbilityOrAttack[this.index][4]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][4] = TempValueForProperty; }
	}

	public CAT(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		CAT npc = view_as<CAT>(CClotBody(vecPos, vecAng, "models/bots/scout/bot_scout.mdl", "1.45", "5000", ally, false, true, true, true));
		
		i_NpcWeight[npc.index] = 4;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = false;

		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);

		func_NPCDeath[npc.index] = CAT_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = CAT_OnTakeDamage;
		func_NPCThink[npc.index] = CAT_ClotThink;

		EmitSoundToAll("mvm/mvm_tank_end.wav", _, _, _, _, 1.0, 100);	
		EmitSoundToAll("mvm/mvm_tank_end.wav", _, _, _, _, 1.0, 100);	

		npc.PlayPassiveSound();
		
		RaidModeTime = GetGameTime(npc.index) + 160.0;
		b_thisNpcIsARaid[npc.index] = true;
		b_ThisNpcIsImmuneToNuke[npc.index] = true;

		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "item_armor", 1, "%s", "C.A.T. has been engaged");
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
		RaidModeScaling *= 0.75;
		RaidModeScaling *= 1.19;
		//scaling old
		//scaling old
			
		RaidModeScaling *= amount_of_people;
		RaidModeScaling *= 1.3;

		
		MusicEnum music;
		strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/aperture/cat.mp3");
		music.Time = 137;
		music.Volume = 1.1;
		music.Custom = true;
		strcopy(music.Name, sizeof(music.Name), "You Will Be Perfect");
		strcopy(music.Artist, sizeof(music.Artist), "Mike Morasky");
		Music_SetRaidMusic(music);
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextOrbAbilityTime = GetGameTime(npc.index) + 15.0;
		npc.m_flNextSelfDegradationAbilityTime = GetGameTime(npc.index) + 25.0;
		
		npc.m_iOrbAbilityState = CAT_ORB_SPAM_ABILITY_STATE_NONE;
		npc.m_flNextOrbAbilityState = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_PANZER;

		//IDLE
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		
		npc.m_flSpeed = CAT_DEFAULT_SPEED;
		npc.m_flMeleeArmor = 1.25;
				
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_bat.mdl");
		SetVariantString("1.10");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);

		Citizen_MiniBossSpawn();
		npc.StartPathing();

		switch(GetRandomInt(0,2))
		{
			case 0:
				CPrintToChatAll("{rare}C.A.T.{default}: CONTROL AGAINST TRESPASSERS, NOW ONLINE");
			case 1:
				CPrintToChatAll("{rare}C.A.T.{default}: C.A.T. HAS BEEN ENGAGED");
			case 2:
				CPrintToChatAll("{rare}C.A.T.{default}: SYSTEM POWER-UP COMPLETE");
		}

		return npc;
	}
}

public void CAT_ClotThink(int iNPC)
{
	CAT npc = view_as<CAT>(iNPC);
	float gameTime = GetGameTime(iNPC);
	
	if(CAT_timeBased(iNPC))
		return;
	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}

	if(RaidModeTime >= GetGameTime() + 170.0)
	{
		RaidModeTime = GetGameTime() + 160.0;
	}

	if(i_RaidGrantExtra[npc.index] == RAIDITEM_INDEX_WIN_COND)
	{
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		
		CPrintToChatAll("{rare}C.A.T.{default}: BY THE WORDS OF THE ONE AND ONLY GLORIOUS RACE; THERE CAN BE ONLY ONE");
		return;
	}

	//idk it never was in a bracket
	if(IsValidEntity(RaidBossActive) && RaidModeTime < GetGameTime())
	{
		ForcePlayerLoss();
		RaidBossActive = INVALID_ENT_REFERENCE;
		CPrintToChatAll("{rare}C.A.T.{default}: SURRENDER YOUR WEAPONS AND COME WITH ME");
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		return;
	}

	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	int closest = npc.m_iTarget;
	
	// RANGED ABILITY: Orbs - Boss spins while firing homing orbs in a spiral pattern indiscriminately. The orbs deal contact damage and work as a projectile shield
	if (npc.m_flNextOrbAbilityTime && npc.m_flNextOrbAbilityTime < gameTime && npc.m_iSelfDegradationAbilityState == CAT_SELF_DEGRADATION_ABILITY_STATE_NONE)
	{
		switch (npc.m_iOrbAbilityState)
		{
			case CAT_ORB_SPAM_ABILITY_STATE_NONE:
			{
				// We can only do this attack if we can see at least 33% of all living players, rounding down
				// If we can't, try again in 5-7 seconds
				int livingPlayerCount = CountPlayersOnRed(2); // 2 = excludes teutons and downed players
				int visiblePlayerCount;
				
				for (int client = 1; client <= MaxClients; client++)
				{
					if (IsValidEnemy(npc.index, client) && Can_I_See_Enemy(npc.index, client))
						visiblePlayerCount++;
				}
				
				if (visiblePlayerCount >= RoundToFloor(livingPlayerCount * 0.33))
				{
					OrbSpam_Ability_ReadyUp(npc);
					return;
				}	
				else
				{
					npc.m_flNextOrbAbilityTime = gameTime + GetRandomFloat(5.0, 7.0);
				}
			}
			
			case CAT_ORB_SPAM_ABILITY_STATE_READYING_UP:
			{
				// We don't really do anything until we're ready. When we're done, start firing
				if (npc.m_flNextOrbAbilityState < gameTime)
					OrbSpam_Ability_Start(npc);
				
				return;
			}
			
			case CAT_ORB_SPAM_ABILITY_STATE_FIRING:
			{
				// Fire until we're done
				if (npc.m_flNextOrbAbilityState < gameTime)
					OrbSpam_Ability_CoolOff(npc);
				else
					OrbSpam_Ability_Fire(npc);
				
				return;
			}
			
			case CAT_ORB_SPAM_ABILITY_STATE_COOLING_OFF:
			{
				// We're done cooling off. Resume killing people as normal
				if (npc.m_flNextOrbAbilityState < gameTime)
					OrbSpam_Ability_End(npc);
				
				return;
			}
		}
	}
	
	// ABILITY 0: Self Degradation - Boss hurts itself, increasing vulnerabilities and damage dealt for a period of time
	if (npc.m_flNextSelfDegradationAbilityTime && npc.m_flNextSelfDegradationAbilityTime < gameTime && npc.m_iOrbAbilityState == CAT_ORB_SPAM_ABILITY_STATE_NONE)
	{
		switch (npc.m_iSelfDegradationAbilityState)
		{
			case CAT_SELF_DEGRADATION_ABILITY_STATE_NONE:
			{
				SelfDegradation_Ability_Start(npc);
				return;
			}
			
			case CAT_SELF_DEGRADATION_ABILITY_STATE_ACTIVATING:
			{
				if (npc.m_flNextSelfDegradationAbilityState < gameTime)
					SelfDegradation_Ability_Activate(npc);
				
				return;
			}
			
			case CAT_SELF_DEGRADATION_ABILITY_STATE_ACTIVE:
			{
				if (npc.m_flNextSelfDegradationAbilityState < gameTime)
					SelfDegradation_Ability_Deactivate(npc);
			}
		}
	}
	
	if(IsValidEnemy(npc.index, closest))
	{
		float vecTarget[3]; WorldSpaceCenter(closest, vecTarget);
			
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; PredictSubjectPosition(npc, closest, _, _, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else
		{
			npc.SetGoalEntity(closest);
		}
		
		CATS_SelfDefense(npc, gameTime, npc.m_iTarget, flDistanceToTarget);
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

static void CATS_SelfDefense(CAT npc, float gameTime, int target, float distance)
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
			float damage = 35.0;
			damage *= RaidModeScaling;
			bool silenced = NpcStats_IsEnemySilenced(npc.index);
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
				npc.m_iSelfDegradationAbilityState == CAT_SELF_DEGRADATION_ABILITY_STATE_ACTIVE ? npc.PlayMeleeHardHitSound() : npc.PlayMeleeHitSound();
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
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");//He will SMACK you
				npc.m_flAttackHappens = gameTime + 0.2;
				float attack = 0.75;
				npc.m_flNextMeleeAttack = gameTime + attack;
				return;
			}
		}
	}
}

static void OrbSpam_Ability_ReadyUp(CAT npc)
{
	float gameTime = GetGameTime(npc.index);
	
	npc.m_bisWalking = false;
	
	npc.m_flSpeed = 0.0;
	npc.StopPathing();
	
	npc.AddActivityViaSequence("dieviolent");
	npc.SetCycle(0.01);
	npc.SetPlaybackRate(0.4);
	
	npc.m_flAttackHappens = gameTime + 999.0;
	
	npc.PlayBoomSound();
	npc.PlayOrbBarrageAlertSound();
	
	if (IsValidEntity(npc.m_iWearable1))
		SetEntityRenderMode(npc.m_iWearable1, RENDER_NONE);
	
	float vecPos[3];
	GetAbsOrigin(npc.index, vecPos);
	vecPos[2] += 20.0;
	spawnRing_Vectors(vecPos, 250 * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 104, 207, 255, 255, 1, 1.5, 5.0, 0.0, 1, 0.0);
	
	npc.m_iOrbAbilityState = CAT_ORB_SPAM_ABILITY_STATE_READYING_UP;
	npc.m_flNextOrbAbilityState = gameTime + 1.5;

	switch(GetRandomInt(0,2))
	{
		case 0:
		{
			CPrintToChatAll("{rare}C.A.T.{default}: PARTICLE RADIATOR IS {unique}READY");
		}
		case 1:
		{
			CPrintToChatAll("{rare}C.A.T.{default}: PREPARING FOR PARTICLE {crimson}DISPERSAL");
		}
		case 2:
		{
			CPrintToChatAll("{rare}C.A.T.{default}: PARTICLES ARE DONE {crimson}WARMING UP");
		}
	}
}

static void OrbSpam_Ability_Start(CAT npc)
{
	float gameTime = GetGameTime(npc.index);
	
	npc.m_iOrbAbilityState = CAT_ORB_SPAM_ABILITY_STATE_FIRING;
	npc.m_flNextOrbAbilityState = gameTime + CAT_ORB_SPAM_ABILITY_DURATION;
}

static void OrbSpam_Ability_CoolOff(CAT npc)
{
	float gameTime = GetGameTime(npc.index);
	
	npc.m_bisWalking = true;
	
	npc.SetActivity("ACT_MP_STUN_MIDDLE");
	npc.AddGesture("ACT_MP_STUN_BEGIN");
	npc.SetPlaybackRate(1.0);
	
	npc.m_flAttackHappens = gameTime + 999.0;
	
	npc.PlayOrbBarrageDizzySound();
	
	npc.m_iOrbAbilityState = CAT_ORB_SPAM_ABILITY_STATE_COOLING_OFF;
	npc.m_flNextOrbAbilityState = gameTime + 2.0;
}

static void OrbSpam_Ability_End(CAT npc)
{
	float gameTime = GetGameTime(npc.index);
	
	npc.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
	npc.AddGesture("ACT_MP_STUN_END");
	
	npc.m_flSpeed = CAT_DEFAULT_SPEED;
	npc.StartPathing();
	
	npc.m_flAttackHappens = gameTime + 0.5;
	npc.m_flNextOrbAbilityTime = gameTime + 20.0;
	
	if (IsValidEntity(npc.m_iWearable1))
		SetEntityRenderMode(npc.m_iWearable1, RENDER_NORMAL);
	
	npc.m_iOrbAbilityState = CAT_ORB_SPAM_ABILITY_STATE_NONE;
	npc.m_flNextOrbAbilityState = 0.0;
	
	// If other attacks are ready, delay them a bit so they don't immediately activate
	npc.m_flNextSelfDegradationAbilityTime = fmax(npc.m_flNextSelfDegradationAbilityTime, gameTime + GetRandomFloat(5.0, 10.0));

	switch(GetRandomInt(0,2))
	{
		case 0:
		{
			CPrintToChatAll("{rare}C.A.T.{default}: PARTICLE RADIATOR IS {azure}COOLING-OFF");
		}
		case 1:
		{
			CPrintToChatAll("{rare}C.A.T.{default}: PARTICLE DISPERSAL {azure}ACCOMPLISHED");
		}
		case 2:
		{
			CPrintToChatAll("{rare}C.A.T.{default}: PARTICLES ARE {crimson}GONE{default}... {azure}FOR NOW");
		}
	}
}

static void OrbSpam_Ability_Fire(CAT npc)
{
	float gameTime = GetGameTime(npc.index);
	
	npc.m_flAttackHappens = gameTime + (CAT_ORB_SPAM_ABILITY_DURATION / CAT_ORB_SPAM_ABILITY_AMOUNT);
	
	static float vecOrbAngles[3];
	float vecOrbPos[3], vecForward[3];
	
	int nextAng = (RoundToNearest(vecOrbAngles[1]) + GetRandomInt(20, 55)) % 360;
	vecOrbAngles[1] = float(nextAng);
	
	GetAbsOrigin(npc.index, vecOrbPos);
	
	GetAngleVectors(vecOrbAngles, vecForward, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(vecForward, vecForward);
	ScaleVector(vecForward, 12.0);
	AddVectors(vecOrbPos, vecForward, vecOrbPos);
	vecOrbPos[2] += 54.0;
	
	npc.PlayRangedSound();
	npc.FaceTowards(vecOrbPos, 2300.0);
	
	int projectile = npc.FireParticleRocket(vecOrbPos, 10.0, GetRandomFloat(100.0, 400.0), 150.0, "dxhr_lightningball_parent_blue", true);
	
	SDKUnhook(projectile, SDKHook_StartTouch, Rocket_Particle_StartTouch);
	SDKHook(projectile, SDKHook_Touch, Cat_Rocket_Particle_Touch);
	SDKHook(projectile, SDKHook_ThinkPost, Cat_Rocket_Particle_Think);
	
	NextOrbDamage[projectile] = 0.0;
	
	// Make its collision box bigger, so it's prettier
	SetEntityModel(projectile, CAT_ORB_SPAM_ABILITY_COLLISION_MODEL);
	SetVariantString("6.0");
	AcceptEntityInput(projectile, "SetModelScale");
	SetEntProp(projectile, Prop_Data, "m_nSolidType", 6); // refreshes collision
	
	SetEntityCollisionGroup(projectile, TFCOLLISION_GROUP_ROCKET_BUT_NOT_WITH_OTHER_ROCKETS);
	CreateTimer(15.0, Timer_RemoveEntity, EntIndexToEntRef(projectile), TIMER_FLAG_NO_MAPCHANGE);
}

bool CAT_timeBased(int iNPC)
{
	CAT npc = view_as<CAT>(iNPC);
	if(npc.m_flLifeReversal)
	{
		if(npc.m_flLifeReversal < GetGameTime())
		{
			b_NpcIsInvulnerable[npc.index] = false;
			npc.PlayRevivalEnd();
			fl_TotalArmor[npc.index] = 1.0;
			npc.StartPathing();
			npc.m_bisWalking = true;
			npc.SetActivity("ACT_MP_RUN_MELEE");
			AcceptEntityInput(npc.m_iWearable1, "Enable");
			npc.m_flLifeReversal = 0.0;
		}
		return true;
	}
	return false;
}

static void Cat_Rocket_Particle_Touch(int entity, int target)
{
	float gameTime = GetGameTime();
	if (NextOrbDamage[entity] > gameTime)
		return;
	
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if (!IsValidEntity(owner))
		owner = 0;
	
	if (!owner)
	{
		RemoveEntity(entity);
		return;
	}
	
	if (!IsValidEnemy(owner, target))
		return;
	
	int inflictor = h_ArrowInflictorRef[entity];
	if(inflictor != -1)
		inflictor = EntRefToEntIndex(h_ArrowInflictorRef[entity]);
	
	if(inflictor == -1)
		inflictor = owner;
	
	float ProjectileLoc[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
	
	float damage = 40.0 * RaidModeScaling;
	Explode_Logic_Custom(damage, inflictor , owner , -1 , ProjectileLoc , 60.0 , _ , _ , b_rocket_particle_from_blue_npc[entity]);
	NextOrbDamage[entity] = gameTime + 0.25;
}

void Cat_Rocket_Particle_Think(int entity)
{
	float gameTime = GetGameTime();
	
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if (!IsValidEntity(owner))
		owner = 0;
	
	if (!owner)
	{
		RemoveEntity(entity);
		return;
	}
	
	float vecPos[3];
	GetAbsOrigin(entity, vecPos);
	
	TR_EnumerateEntitiesSphere(vecPos, 100.0, PARTITION_NON_STATIC_EDICTS, TraceEntityEnumerator_CAT_FindProjectiles, entity);
	
	float vecVelocity[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsVelocity", vecVelocity);
	
	float speed = getLinearVelocity(vecVelocity);
	if (speed > 40.0)
	{
		ScaleVector(vecVelocity, 0.95);
		TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vecVelocity);
		SetEntPropVector(entity, Prop_Send, "m_vInitialVelocity", vecVelocity);
	}
	
	CBaseCombatCharacter(entity).SetNextThink(gameTime + 0.1);
}

static void SelfDegradation_Ability_Start(CAT npc)
{
	float gameTime = GetGameTime(npc.index);
	
	npc.m_bisWalking = false;
	
	npc.AddActivityViaSequence("taunt03");
	npc.SetPlaybackRate(0.75);
	npc.SetCycle(0.01);
	
	npc.m_flSpeed = 0.0;
	npc.StopPathing();
	
	npc.m_iSelfDegradationAbilityState = CAT_SELF_DEGRADATION_ABILITY_STATE_ACTIVATING;
	npc.m_flNextSelfDegradationAbilityState = gameTime + 1.5;
	switch(GetRandomInt(0,2))
	{
		case 0:
		{
			CPrintToChatAll("{rare}C.A.T.{default}: INITIATING SELF-DEGRADATION");
		}
		case 1:
		{
			CPrintToChatAll("{rare}C.A.T.{default}: SELF-DEGRADATION IN PROCESS...");
		}
		case 2:
		{
			CPrintToChatAll("{rare}C.A.T.{default}: SWITCHING TO SELF-DEGRADATION MODE");
		}
	}
}

static void SelfDegradation_Ability_Activate(CAT npc)
{
	float gameTime = GetGameTime(npc.index);
	
	npc.m_bisWalking = true;
	
	npc.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
	npc.SetPlaybackRate(1.0);
	
	npc.m_flSpeed = CAT_DEFAULT_SPEED;
	npc.StartPathing();
	
	npc.PlayBoomSound();
	npc.PlayMeleeHardHitSound();
	
	// Add an effect to the weapon
	if (IsValidEntity(npc.m_iWearable1))
	{
		if (IsValidEntity(npc.m_iWearable2))
			RemoveEntity(npc.m_iWearable2);
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/weapons/c_models/c_bat.mdl");
		SetVariantString("1.1");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		SetEntityRenderMode(npc.m_iWearable2, RENDER_NONE);
		
		TE_SetupParticleEffect(CAT_SELF_DEGRADATION_ABILITY_EFFECT, PATTACH_ABSORIGIN_FOLLOW, npc.m_iWearable2);
		TE_WriteNum("m_bControlPoint1", npc.m_iWearable2);
		TE_SendToAll();
	}
	
	npc.m_iSelfDegradationAbilityState = CAT_SELF_DEGRADATION_ABILITY_STATE_ACTIVE;
	npc.m_flNextSelfDegradationAbilityState = gameTime + CAT_SELF_DEGRADATION_ABILITY_DURATION;
	
	ApplyStatusEffect(npc.index, npc.index, "Self-Degradation", CAT_SELF_DEGRADATION_ABILITY_DURATION);
	ApplyStatusEffect(npc.index, npc.index, "Self-Degradation (Debuff)", CAT_SELF_DEGRADATION_ABILITY_DURATION);

	switch(GetRandomInt(0,2))
	{
		case 0:
		{
			CPrintToChatAll("{rare}C.A.T.{default}: SELF-DEGRADATION MODE IS {unique}ONLINE");
		}
		case 1:
		{
			CPrintToChatAll("{rare}C.A.T.{default}: SELF-DEGRADATION: {unique}ACTIVATED");
		}
		case 2:
		{
			CPrintToChatAll("{rare}C.A.T.{default}: SELF-DEGRADATION POWER UP, {unique}COMPLETE");
		}
	}
}

static void SelfDegradation_Ability_Deactivate(CAT npc)
{
	float gameTime = GetGameTime(npc.index);
	
	npc.m_flNextSelfDegradationAbilityTime = gameTime + 18.0;
	
	npc.m_iSelfDegradationAbilityState = CAT_SELF_DEGRADATION_ABILITY_STATE_NONE;
	npc.m_flNextSelfDegradationAbilityState = 0.0;
	
	// Remove the effect from the weapon
	if (IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	
	// If other attacks are ready, delay them a bit so they don't immediately activate
	npc.m_flNextOrbAbilityTime = fmax(npc.m_flNextOrbAbilityTime, gameTime + GetRandomFloat(3.0, 5.0));

	switch(GetRandomInt(0,2))
	{
		case 0:
		{
			CPrintToChatAll("{rare}C.A.T.{default}: SELF-DEGRADATION MODE IS {crimson}OFFLINE");
		}
		case 1:
		{
			CPrintToChatAll("{rare}C.A.T.{default}: SELF-DEGRADATION: {crimson}DEACTIVATED");
		}
		case 2:
		{
			CPrintToChatAll("{rare}C.A.T.{default}: SELF-DEGRADATION IS {crimson}SHUTTING DOWN");
		}
	}
}

public Action CAT_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	CAT npc = view_as<CAT>(victim);
	
	if (damage >= GetEntProp(npc.index, Prop_Data, "m_iHealth") && Aperture_ShouldDoLastStand())
	{
		npc.StopPassiveSound();
		npc.m_iState = APERTURE_BOSS_CAT; // This will store the boss's "type"
		Aperture_Shared_LastStandSequence_Starting(view_as<CClotBody>(npc));
		
		damage = 0.0;
		return Plugin_Handled;
	}

	if(!npc.Anger)
	{
		if((ReturnEntityMaxHealth(npc.index) / 2) >= (GetEntProp(npc.index, Prop_Data, "m_iHealth")))
		{
			npc.PlayRevivalStart();
			CPrintToChatAll("{rare}C.A.T.{default}: INITIATING {unique}LIFE REVERSAL");
			float VecSelfNpcabs[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", VecSelfNpcabs);
			TE_Particle("teleported_mvm_bot_rings2", VecSelfNpcabs, _, _, npc.index, 1, 0);
			npc.Anger = true;
			npc.m_flLifeReversal = GetGameTime(npc.index) + 10.0;
			AcceptEntityInput(npc.m_iWearable1, "Disable");
			npc.StopPathing();
			npc.m_bisWalking = false;
			npc.AddGesture("ACT_MP_STUN_BEGIN");
			npc.SetActivity("ACT_MP_STUN_MIDDLE");
			b_NpcIsInvulnerable[npc.index] = true;
			HealEntityGlobal(npc.index, npc.index, ReturnEntityMaxHealth(npc.index) * 2.0, _, 10.0, HEAL_ABSOLUTE);
			RaidModeTime += (170.0 + DEFAULT_UPDATE_DELAY_FLOAT);
		}
	}
		
	if(attacker <= 0)
		return Plugin_Continue;
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	CAT_Weapon_Lines(npc, attacker);
	i_SaidLineAlready[npc.index] = 0;
	
	return Plugin_Changed;
}

static void CAT_Weapon_Lines(CAT npc, int client)
{
	if(client > MaxClients)
		return;

	if(b_said_player_weaponline[client])	//only 1 line per player.
		return;

	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

	if(!IsValidEntity(weapon))	//invalid weapon, go back and get a valid one you <...>
		return;

	float GameTime = GetGameTime();	//no need to throttle this.

	if(fl_said_player_weaponline_time[npc.index] > GameTime)	//no spamming in chat please!
		return;

	bool valid = true;
	char Text_Lines[255];

	Text_Lines = "";

	switch(i_CustomWeaponEquipLogic[weapon])
	{
		
		case WEAPON_SENSAL_SCYTHE,WEAPON_SENSAL_SCYTHE_PAP_1,WEAPON_SENSAL_SCYTHE_PAP_2,WEAPON_SENSAL_SCYTHE_PAP_3:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "ANALYZING WEAPON... ... ... INSUFFICIENT DATA",client);
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "IT APPEARS YOU HAVE STOLEN THIS WEAPON FROM SOMEONE, HAND IT OVER OR FACE CONSEQUENCES");
			}
		}
		case WEAPON_FUSION,WEAPON_FUSION_PAP1,WEAPON_FUSION_PAP2:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "WEAPON'S ORIGIN CAN NOT BE DETERMINED",client);
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "TECHNOLOGY APPEARS TO HAVE ADVANCED FORWARD, WITH THE LABS LEFT BEHIND, EVEN IF IT APPEARS TO BE A POORLY DESIGNED WEAPON");
			}
		}
		case WEAPON_KIT_BLITZKRIEG_CORE:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "ANALYZING MODEL ... OLD PROTOTYPE DISCOVERED, GIVEN ITS POOR STATISTICS, DISREGARD");
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "ESTIMATING OPPONENT'S THREAT LEVEL... UNDERWHELMING",client);
			}
		}
		case WEAPON_KIT_PROTOTYPE, WEAPON_KIT_PROTOTYPE_MELEE:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "FIRST PROTOTYPE'S WEAPONRIES DETECTED",client);
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "THE ANCESTORS OF THE GLORIOUS RACE WOULD'VE LOVED TO SEE YOU USING THESE FIREARMS...AND ALSO HATED YOU");
			}
		}

		default:
		{
			valid = false;
		}
	}

	if(valid)
	{
		CPrintToChatAll("{rare}C.A.T.{default}: %s", Text_Lines);
		fl_said_player_weaponline_time[npc.index] = GameTime + GetRandomFloat(15.0, 22.0);
		b_said_player_weaponline[client] = true;
	}
}

public void CAT_NPCDeath(int entity)
{
	CAT npc = view_as<CAT>(entity);
	
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
		
	npc.StopPassiveSound();
}

static bool TraceEntityEnumerator_CAT_FindProjectiles(int entity, int self)
{
	if (entity <= 0 || entity > MAXENTITIES)
		return true;
	
	if (!b_IsAProjectile[entity])
		return true;
	
	// Entity has just been initialized, skip this for now
	if (GetTeam(entity) == 0)
		return true;
	
	if (GetTeam(entity) == GetTeam(self))
		return true;
	
	float vecPos[3], vecTargetPos[3], vecAng[3];
	WorldSpaceCenter(self, vecPos);
	WorldSpaceCenter(entity, vecTargetPos);
	
	GetVectorAnglesTwoPoints(vecTargetPos, vecPos, vecAng);
	int particle = ParticleEffectAtWithRotation(vecTargetPos, vecAng, "dxhr_lightningball_hit_zap_blue", 0.3);
	
	// Array netprop, but we only need element 0 anyway
	SetEntPropEnt(particle, Prop_Send, "m_hControlPointEnts", self, 0);
	SetEntProp(particle, Prop_Send, "m_iControlPointParents", self, _, 0);
	
	RemoveEntity(entity);
	return true;
}
