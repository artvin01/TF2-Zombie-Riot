#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/medic_paincrticialdeath01.mp3",
	"vo/medic_paincrticialdeath02.mp3",
	"vo/medic_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/medic_painsharp01.mp3",
	"vo/medic_painsharp02.mp3",
	"vo/medic_painsharp03.mp3",
	"vo/medic_painsharp04.mp3",
	"vo/medic_painsharp05.mp3",
	"vo/medic_painsharp06.mp3",
	"vo/medic_painsharp07.mp3",
	"vo/medic_painsharp08.mp3",
};

static const char g_IdleSounds[][] = {
	"vo/medic_standonthepoint01.mp3",
	"vo/medic_standonthepoint02.mp3",
	"vo/medic_standonthepoint03.mp3",
	"vo/medic_standonthepoint04.mp3",
	"vo/medic_standonthepoint05.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/medic_battlecry01.mp3",
	"vo/medic_battlecry02.mp3",
	"vo/medic_battlecry03.mp3",
	"vo/medic_battlecry04.mp3",
	"vo/medic_battlecry05.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/halloween_boss/knight_axe_hit.wav",
};
static const char g_MeleeAttackSounds[][] = {
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav",
};

static const char g_RangeAttackSounds[][] = {
	"weapons/dragons_fury_shoot.wav",
};
static char g_TeleportSounds[][] = {
	"misc/halloween/spell_stealth.wav",
};
static const char g_AngerSounds[][] = {
	"vo/medic_cartgoingforwardoffense01.mp3",
	"vo/medic_cartgoingforwardoffense02.mp3",
	"vo/medic_cartgoingforwardoffense03.mp3",
	"vo/medic_cartgoingforwardoffense06.mp3",
	"vo/medic_cartgoingforwardoffense07.mp3",
	"vo/medic_cartgoingforwardoffense08.mp3",
};

#define RAIDBOSS_TWIRL_THEME "#zombiesurvival/ruina/raid_theme_2.mp3"

static int i_ranged_combo[MAXENTITIES];
static int i_melee_combo[MAXENTITIES];
static int i_current_wave[MAXENTITIES];
static float fl_retreat_timer[MAXENTITIES];

static float fl_npc_basespeed;

void Twirl_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Twirl");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_ruina_twirl");
	data.Category = Type_Raid;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	strcopy(data.Icon, sizeof(data.Icon), "medic"); 						//leaderboard_class_(insert the name)
	data.IconCustom = false;												//download needed?
	data.Flags = 0;						//example: MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;, forces these flags.	
	NPC_Add(data);
}
static void ClotPrecache()
{
	Zero(fl_retreat_timer);
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_RangeAttackSounds);
	PrecacheSoundArray(g_TeleportSounds);

	PrecacheSoundCustom(RAIDBOSS_TWIRL_THEME);

	PrecacheModel("models/player/medic.mdl");
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return Twirl(client, vecPos, vecAng, ally, data);
}

static const char NameColour[] = "{purple}";
static const char TextColour[] = "{snow}";

methodmap Twirl < CClotBody
{
	
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleSound()");
		#endif
	}
	
	public void PlayTeleportSound() {
		EmitSoundToAll(g_TeleportSounds[GetRandomInt(0, sizeof(g_TeleportSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayTeleportSound()");
		#endif
	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		
		
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		
	}

	public void PlayRangeAttackSound() {
		EmitSoundToAll(g_RangeAttackSounds[GetRandomInt(0, sizeof(g_RangeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		
	}
	public void PlayAngerSound() {
	
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::Playnpc.AngerSound()");
		#endif
	}

	public bool Add_Combo(int amt)
	{
		if(this.m_fbGunout)
		{
			if(i_ranged_combo[this.index]>amt)
			{
				i_ranged_combo[this.index] = 0;
				return true;
			}
			i_ranged_combo[this.index]++;
		}
		else
		{
			if(i_melee_combo[this.index]>amt)
			{
				i_melee_combo[this.index] = 0;
				return true;
			}
			i_melee_combo[this.index]++;
		}
		return false;
	}

	public void Handle_Weapon()
	{
		switch(this.PlayerType())
		{
			case -1:
			{
				CPrintToChatAll("Invalid target");
				return;
			}
			case 0:	//melee
			{
				if(this.m_fbGunout)
				{
					this.m_fbGunout = false;
					SetVariantInt(this.i_weapon_type());
					AcceptEntityInput(this.m_iWearable1, "SetBodyGroup");
					CPrintToChatAll("Melee enemy");
				}
				
			}
			default:	//ranged/undecided
			{
				if(!this.m_fbGunout)
				{
					this.m_fbGunout = true;
					CPrintToChatAll("Ranged enemy");
					SetVariantInt(this.i_weapon_type());
					AcceptEntityInput(this.m_iWearable1, "SetBodyGroup");
				}
				
			}

		}
	}
	public int i_weapon_type()
	{
		int wave = i_current_wave[this.index];

		if(this.m_fbGunout)	//ranged
		{
			if(wave<=15)	
			{
				return RUINA_TWIRL_CREST_1;
			}
			else if(wave <=30)	
			{
				return RUINA_TWIRL_CREST_2;
			}
			else if(wave <= 45)	
			{
				return RUINA_TWIRL_CREST_3;
			}
			else
			{
				return RUINA_TWIRL_CREST_4;
			}
		}
		else				//melee
		{
			if(wave<=15)	
			{
				return RUINA_TWIRL_MELEE_1;
			}
			else if(wave <=30)	
			{
				return RUINA_TWIRL_MELEE_2;
			}
			else if(wave <= 45)	
			{
				return RUINA_TWIRL_MELEE_3;
			}
			else
			{
				return RUINA_TWIRL_MELEE_4;
			}
		}
	}

	public int PlayerType()
	{
		if(!IsValidEnemy(this.index, this.m_iTarget))
			return -1;

		if(this.m_iTarget > MaxClients)
			return 1;						//its an npc? fuck em

		if(i_BarbariansMind[this.m_iTarget])
			return 0;						//we can 100% say the target is a melee player.	
		
		int weapon = GetEntPropEnt(this.m_iTarget, Prop_Send, "m_hActiveWeapon");

		if(!IsValidEntity(weapon))
			return 1;						//someohw invalid weapon, asume its a ranged player.
		
		if(i_IsWandWeapon[weapon])
			return 1;						//the weapon they are holding a wand, so its a ranged player	

		char classname[32];
		GetEntityClassname(weapon, classname, 32);

		int weapon_slot = TF2_GetClassnameSlot(classname);

		if(weapon_slot != 2)
			return 1;		

		//now the "Easy" checks are done and now the not so easy checks are left.

		int type = 0;	//this way a ranged player can't switch to their melee to avoid attacks.
		int i, entity;
		while(TF2_GetItem(this.m_iTarget, entity, i))
		{
			if(StoreWeapon[entity] > 0)
			{
				char buffer[255];
				GetEntityClassname(entity, buffer, sizeof(buffer));
				int slot = TF2_GetClassnameSlot(buffer);

				if(slot != 2)
				{
					type = 1;
					break;
				}
			}
		}

		return type;
	}

	public char[] GetName()
	{
		char Name[255];
		Format(Name, sizeof(Name), "%s%s%s:", NameColour, c_NpcName[this.index], TextColour);
		return Name;
	}
	
	
	public Twirl(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Twirl npc = view_as<Twirl>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "1250", ally));
		
		i_ranged_combo[npc.index] = 0;
		i_melee_combo[npc.index] = 0;

		c_NpcName[npc.index] = "Twirl";

		int wave = ZR_GetWaveCount()+1;

		if(StrContains(data, "force15") != -1)
			wave = 15;
		if(StrContains(data, "force30") != -1)
			wave = 30;
		if(StrContains(data, "force45") != -1)
			wave = 45;
		if(StrContains(data, "force60") != -1)
			wave = 60;

		npc.m_fbGunout = true;
		i_current_wave[npc.index] = wave;

		i_NpcWeight[npc.index] = 15;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = false;
	
		
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "item_armor", 1, "%t", "Twirl Spawn");
			}
		}

		MusicEnum music;
		strcopy(music.Path, sizeof(music.Path), RAIDBOSS_TWIRL_THEME);
		music.Time = 285;
		music.Volume = 2.0;
		music.Custom = true;
		strcopy(music.Name, sizeof(music.Name), "Solar Sect of Mystic Wisdom ~ Nuclear Fusion");
		strcopy(music.Artist, sizeof(music.Artist), "maritumix/まりつみ");
		Music_SetRaidMusic(music);
		
		bool final = StrContains(data, "final_item") != -1;
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(NPC_Death);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(ClotThink);

		fl_npc_basespeed = 290.0;
		npc.m_flSpeed = fl_npc_basespeed;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();

		b_thisNpcIsARaid[npc.index] = true;

		npc.m_bThisNpcIsABoss = true;
		
		RaidModeTime = GetGameTime(npc.index) + 250.0;
		
		RaidModeScaling = float(ZR_GetWaveCount()+1);
		
		if(RaidModeScaling < 55)
		{
			RaidModeScaling *= 0.19; //abit low, inreacing
		}
		else
		{
			RaidModeScaling *= 0.38;
		}
		
		float amount_of_people = float(CountPlayersOnRed());
		
		if(amount_of_people > 12.0)
		{
			amount_of_people = 12.0;
		}
		
		amount_of_people *= 0.12;
		
		if(amount_of_people < 1.0)
			amount_of_people = 1.0;
			
		RaidModeScaling *= amount_of_people;
				
		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
		npc.m_bTeamGlowDefault = false;
			
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		SetVariantColor(view_as<int>({125, 0, 125, 255}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
				
		fl_ruina_battery[npc.index] = 0.0;
		b_ruina_battery_ability_active[npc.index] = false;
		fl_ruina_battery_timer[npc.index] = 0.0;
		
		Ruina_Set_Heirarchy(npc.index, RUINA_GLOBAL_NPC);

		int skin = 1;	//1=blue, 0=red
		SetVariantInt(1);	
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		npc.m_iWearable1 = npc.EquipItem("head", RUINA_CUSTOM_MODELS_3);
		/*npc.m_iWearable2 = npc.EquipItem("head", Items[1], _, skin);
		npc.m_iWearable3 = npc.EquipItem("head", Items[2], _, skin);
		npc.m_iWearable4 = npc.EquipItem("head", Items[3], _, skin);
		npc.m_iWearable5 = npc.EquipItem("head", Items[4], _, skin);
		npc.m_iWearable6 = npc.EquipItem("head", Items[5]);
		npc.m_iWearable7 = npc.EquipItem("head", Items[6]);*/

		SetVariantInt(npc.i_weapon_type());
		AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");

		npc.Anger = false;


		CPrintToChatAll("%s Stage 1, ara ara~", npc.GetName());
		
		return npc;
	}
	
	
}

//TODO 
//Rewrite
static void ClotThink(int iNPC)
{
	Twirl npc = view_as<Twirl>(iNPC);
	
	float GameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > GameTime)
	{
		return;
	}

	if(RaidModeTime < GetGameTime())
	{
		ForcePlayerLoss();
		RaidBossActive = INVALID_ENT_REFERENCE;
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		CPrintToChatAll("lost via timer");
		return;
	}
	
	npc.m_flNextDelayTime = GameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();

	if(npc.m_flGetClosestTargetTime < GameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
			
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = GameTime + 0.1;

	Ruina_Add_Battery(npc.index, 0.75);

	npc.Handle_Weapon();	//adjusts weapon model/state depending on target
	
	int PrimaryThreatIndex = npc.m_iTarget;	

	Ruina_Ai_Override_Core(npc.index, PrimaryThreatIndex, GameTime);	//handles movement, also handles targeting
	

	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
			
		float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);

		bool backing_up = false;
		if(flDistanceToTarget < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 7.5)  && npc.m_fbGunout)
		{
			int Enemy_I_See;
				
			Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
			//Target close enough to hit
			if(IsValidEnemy(npc.index, Enemy_I_See)) //Check if i can even see.
			{
				if(flDistanceToTarget < (75000))
				{
					Ruina_Runaway_Logic(npc.index, PrimaryThreatIndex);
					npc.m_bAllowBackWalking=true;
					backing_up = true;
				}
				else
				{
					NPC_StopPathing(npc.index);
					npc.m_bPathing = false;
					npc.m_bAllowBackWalking=false;
				}
			}
			else
			{
				npc.StartPathing();
				npc.m_bPathing = true;
				npc.m_bAllowBackWalking=false;
			}		
		}
		else
		{
			npc.StartPathing();
			npc.m_bPathing = true;
			npc.m_bAllowBackWalking=false;
		}

		if(flDistanceToTarget < GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 5.0)
		{
			npc.m_bAllowBackWalking = true;
			npc.FaceTowards(vecTarget, RUINA_FACETOWARDS_BASE_TURNSPEED*2.0);
		}
			

		Self_Defense(npc, flDistanceToTarget, PrimaryThreatIndex);

		if(npc.m_bAllowBackWalking && backing_up)
		{
			npc.StartPathing();
			npc.m_flSpeed = fl_npc_basespeed*RUINA_BACKWARDS_MOVEMENT_SPEED_PENATLY;	
			npc.FaceTowards(vecTarget, RUINA_FACETOWARDS_BASE_TURNSPEED*2.0);
		}
		else
		{
			npc.m_flSpeed = fl_npc_basespeed;
		}
	}
	else
	{
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

static void Self_Defense(Twirl npc, float flDistanceToTarget, int PrimaryThreatIndex)	//temp
{
	float GameTime = GetGameTime(npc.index);
	if(npc.m_fbGunout)
	{
		if(flDistanceToTarget > (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 15.0))	
			return;

		if(npc.m_flNextMeleeAttack > GameTime)
			return;

		int Enemy_I_See;
									
		Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
				
		if(!IsValidEnemy(npc.index, Enemy_I_See))
			return;

		npc.m_flNextMeleeAttack = GameTime+0.25;
		float flPos[3]; // original
		float flAng[3]; // original
			
		GetAttachment(npc.index, "effect_hand_r", flPos, flAng);

		npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");

		npc.PlayRangeAttackSound();

		float Vec_Target[3];
		WorldSpaceCenter(PrimaryThreatIndex, Vec_Target);
		npc.FaceTowards(Vec_Target, 2000.0);
			
		float projectile_speed = 1000.0;
		float target_vec[3];
		PredictSubjectPositionForProjectiles(npc, Enemy_I_See, projectile_speed, _,target_vec);

		npc.FireParticleRocket(target_vec, 50.0 , projectile_speed , 100.0 , "raygun_projectile_blue", _, _, true, flPos);
	}
	else
	{
		float Swing_Speed = (npc.Anger ? 1.0 : 2.0);
		float Swing_Delay = (npc.Anger ? 0.1 : 0.2);

		if(npc.m_flAttackHappens)
		{
			if(npc.m_flAttackHappens < GameTime)
			{
				npc.m_flAttackHappens = 0.0;

				fl_retreat_timer[npc.index] = GameTime+(Swing_Speed*0.35);

				Handle swingTrace;
				float VecEnemy[3]; WorldSpaceCenter(PrimaryThreatIndex, VecEnemy);
				npc.FaceTowards(VecEnemy, 15000.0);
				if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex, {125.0, 100.0, 150.0}, {-125.0, -125.0, -150.0}))
				{	
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);

					if(IsValidEnemy(npc.index, target))
					{
						SDKHooks_TakeDamage(target, npc.index, npc.index, Modify_Damage(npc, target, 350.0), DMG_CLUB, -1, _, vecHit);

						Ruina_Add_Battery(npc.index, 250.0);

						float Kb = (npc.Anger ? 900.0 : 450.0);

						Custom_Knockback(npc.index, target, Kb, true);
						if(target < MaxClients)
						{
							TF2_AddCondition(target, TFCond_LostFooting, 0.5);
							TF2_AddCondition(target, TFCond_AirCurrent, 0.5);
						}

						Ruina_Add_Mana_Sickness(npc.index, target, 0.25, 125);
					}
					npc.PlayMeleeHitSound();
					
				}
				delete swingTrace;
			}
		}
		else
		{
			if(fl_retreat_timer[npc.index] > GameTime || (flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*2.0 && npc.m_flNextMeleeAttack > GameTime))
			{
				float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, PrimaryThreatIndex,_,vBackoffPos);
				NPC_SetGoalVector(npc.index, vBackoffPos, true);
				npc.FaceTowards(vecTarget, 20000.0);
				npc.m_flSpeed =  fl_npc_basespeed*RUINA_BACKWARDS_MOVEMENT_SPEED_PENATLY;
			}
		}

		if(npc.m_flNextMeleeAttack < GameTime && flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*1.25))	//its a lance so bigger range
		{
			int Enemy_I_See;
									
			Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
				npc.m_flAttackHappens = GameTime + Swing_Delay;
				npc.m_flDoingAnimation = GameTime + Swing_Delay;
				npc.m_flNextMeleeAttack = GameTime + Swing_Speed;
			}
		}
	}
}

static float Modify_Damage(Twirl npc, int Target, float damage)
{
	if(ShouldNpcDealBonusDamage(Target))
		damage*=10.0;

	if(NpcStats_IsEnemySilenced(npc.index))
		damage *=0.5;

	if(npc.Anger)
		damage *=1.5;

	if(Target > MaxClients)
		return damage;

	int weapon = GetEntPropEnt(Target, Prop_Send, "m_hActiveWeapon");
						
	if(!IsValidEntity(weapon))
		return damage;

	char classname[32];
	GetEntityClassname(weapon, classname, 32);

	int weapon_slot = TF2_GetClassnameSlot(classname);

	if(weapon_slot != 2 || i_IsWandWeapon[weapon])
		damage *= 2.0;

	return damage;
}

static Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Twirl npc = view_as<Twirl>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	Ruina_NPC_OnTakeDamage_Override(npc.index, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
	//Ruina_Add_Battery(npc.index, damage);	//turn damage taken into energy

	if(!npc.Anger && (GetEntProp(npc.index, Prop_Data, "m_iMaxHealth")/2) >= GetEntProp(npc.index, Prop_Data, "m_iHealth")) //Anger after half hp
	{
		npc.Anger = true; //	>:(
		npc.PlayAngerSound();

		if(npc.m_bThisNpcIsABoss)
		{
			npc.DispatchParticleEffect(npc.index, "hightower_explosion", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("eyes"), PATTACH_POINT_FOLLOW, true);
		}
	}
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void NPC_Death(int entity)
{
	Twirl npc = view_as<Twirl>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}

	Ruina_NPCDeath_Override(npc.index);

		
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	
}