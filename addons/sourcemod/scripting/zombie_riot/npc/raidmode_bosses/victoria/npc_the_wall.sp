#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"weapons/rescue_ranger_teleport_receive_01.wav",
	"weapons/rescue_ranger_teleport_receive_02.wav"
};
static const char g_MeleeAttackSounds[][] = {
	"weapons/boxing_gloves_swing1.wav",
	"weapons/boxing_gloves_swing2.wav",
	"weapons/boxing_gloves_swing4.wav",
	"weapons/fist_swing_crit.wav"
};
static const char g_MeleeHitSounds[][] = {
	"weapons/fist_hit_world1.wav",
	"weapons/fist_hit_world2.wav"
};
static const char g_EnergyshieldSounds[][] = {
	"weapons/fx/rics/ric1.wav",
	"weapons/fx/rics/ric2.wav",
	"weapons/fx/rics/ric3.wav",
	"weapons/fx/rics/ric4.wav",
	"weapons/fx/rics/ric5.wav"
};


static float FTL[MAXENTITIES];
static float Delay_Attribute[MAXENTITIES];

static int I_cant_do_this_all_day[MAXENTITIES];
static int i_Huscarls_eye_particle[MAXENTITIES];
static bool YaWeFxxked[MAXENTITIES];
static bool ParticleSpawned[MAXENTITIES];
static bool SUPERHIT[MAXENTITIES];

static float DMGTypeArmorDuration[MAXENTITIES];
static float GetArmor[MAXENTITIES];
static float BlastDMG[MAXENTITIES];
static float MagicDMG[MAXENTITIES];
static float BulletDMG[MAXENTITIES];
static bool BlastArmor[MAXENTITIES];
static bool MagicArmor[MAXENTITIES];
static bool BulletArmor[MAXENTITIES];

static float DynamicCharger[MAXENTITIES];
static float ExtraMovement[MAXENTITIES];
static bool Frozen_Player[MAXTF2PLAYERS];

void Huscarls_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Huscarls");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_the_wall");
	strcopy(data.Icon, sizeof(data.Icon), "sensal_raid");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Raid;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_EnergyshieldSounds)); i++) { PrecacheSound(g_EnergyshieldSounds[i]); }
	PrecacheModel("models/player/heavy.mdl");
	PrecacheSoundCustom("#zombiesurvival/expidonsa_waves/raid_sensal_2.mp3");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return Huscarls(client, vecPos, vecAng, ally, data);
}

methodmap Huscarls < CClotBody
{
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		//EmitSoundToAll(g_MeleeHitSounds, this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	property int i_GunMode
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}
	property float m_flHuscarlsRushCoolDown
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flHuscarlsRushDuration
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flHuscarlsAdaptiveArmorCoolDown
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flHuscarlsAdaptiveArmorDuration
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	property float m_flHuscarlsDeployEnergyShieldCoolDown
	{
		public get()							{ return fl_AbilityOrAttack[this.index][4]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][4] = TempValueForProperty; }
	}
	property float m_flHuscarlsDeployEnergyShieldDuration
	{
		public get()							{ return fl_AbilityOrAttack[this.index][5]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][5] = TempValueForProperty; }
	}
	
	public Huscarls(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Huscarls npc = view_as<Huscarls>(CClotBody(vecPos, vecAng, "models/player/heavy.mdl", "1.35", "40000", ally, false, true, true,true)); //giant!
		i_NpcWeight[npc.index] = 4;

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(3);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		npc.m_bDissapearOnDeath = true;
		npc.m_flMeleeArmor = 1.25;	
		
		func_NPCDeath[npc.index] = view_as<Function>(Internal_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Internal_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Internal_ClotThink);

		//IDLE
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 300.0;
		Delay_Attribute[npc.index] = 0.0;
		YaWeFxxked[npc.index] = false;
		ParticleSpawned[npc.index] = false;
		SUPERHIT[npc.index] = false;
		I_cant_do_this_all_day[npc.index] = 0;
		DMGTypeArmorDuration[npc.index] = 0.0;
		GetArmor[npc.index] = 0.0;
		BlastDMG[npc.index] = 0.0;
		MagicDMG[npc.index] = 0.0;
		BulletDMG[npc.index] = 0.0;
		BlastArmor[npc.index] = false;
		MagicArmor[npc.index] = false;
		BulletArmor[npc.index] = false;
		DynamicCharger[npc.index] = 0.0;
		ExtraMovement[npc.index] = 0.0;
		npc.i_GunMode = 0;
		float gametime = GetGameTime();
		npc.m_flHuscarlsRushCoolDown = gametime + 15.0;
		npc.m_flHuscarlsRushDuration = 0.0;
		npc.m_flHuscarlsAdaptiveArmorCoolDown = gametime + 30.0;
		npc.m_flHuscarlsAdaptiveArmorDuration = 0.0;
		npc.m_flHuscarlsDeployEnergyShieldCoolDown = gametime + 5.0;
		npc.m_flHuscarlsDeployEnergyShieldDuration = 0.0;
		
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		b_thisNpcIsARaid[npc.index] = true;
		b_angered_twice[npc.index] = false;
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "item_armor", 1, "%t", "Sensal Arrived");
				Frozen_Player[client_check]=false;
			}
		}
		FTL[npc.index] = 200.0;
		RaidModeTime = GetGameTime(npc.index) + FTL[npc.index];
		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = false;
		
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

		RaidModeScaling *= amount_of_people; //More then 9 and he raidboss gets some troubles, bufffffffff
		
		if(ZR_GetWaveCount()+1 > 40 && ZR_GetWaveCount()+1 < 55)
		{
			RaidModeScaling *= 0.85;
		}
		else if(ZR_GetWaveCount()+1 > 55)
		{
			FTL[npc.index] = 220.0;
			RaidModeTime = GetGameTime(npc.index) + FTL[npc.index];
			RaidModeScaling *= 0.65;
		}
		MusicEnum music;
		strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/expidonsa_waves/raid_sensal_2.mp3");
		music.Time = 218;
		music.Volume = 2.0;
		music.Custom = true;
		strcopy(music.Name, sizeof(music.Name), "Goukisan - Betrayal of Fear (TeslaX VIP remix)");
		strcopy(music.Artist, sizeof(music.Artist), "Talurre/TeslaX11");
		Music_SetRaidMusic(music);
		npc.m_iChanged_WalkCycle = -1;

		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		npc.m_fbGunout = false;


		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/heavy/sf14_heavy_robo_chest/sf14_heavy_robo_chest.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

	//	Weapon
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_sr3_punch/c_sr3_punch.mdl");
		SetVariantString("1.1");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/heavy/sbox2014_heavy_camopants/sbox2014_heavy_camopants.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/heavy/sept2014_unshaved_bear/sept2014_unshaved_bear.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/all_class/fall17_nuke/fall17_nuke_heavy.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");

		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/heavy/spr18_tsar_platinum/spr18_tsar_platinum.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");

		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", skin);

		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
		npc.m_bTeamGlowDefault = false;
		SetVariantColor(view_as<int>({100, 150, 255, 200}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
		
		CPrintToChatAll("{lightblue}Huscarls{default}: Intruders in sight, I won't let the get out alive!");
		
		return npc;
	}
}

static void Internal_ClotThink(int iNPC)
{
	Huscarls npc = view_as<Huscarls>(iNPC);
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	GrantEntityArmor(iNPC, true, 0.05, 0.5, 0);

	if(NpcStats_VictorianCallToArms(npc.index) && !ParticleSpawned[npc.index])
	{
		float flPos[3], flAng[3];
				
		npc.GetAttachment("eyeglow_L", flPos, flAng);
		i_Huscarls_eye_particle[npc.index] = EntIndexToEntRef(ParticleEffectAt_Parent(flPos, "raygun_projectile_blue_crit", npc.index, "eyeglow_L", {0.0,0.0,0.0}));
		npc.GetAttachment("", flPos, flAng);
		ParticleSpawned[npc.index] = true;
	}	

	if(LastMann)
	{
		if(!npc.m_fbGunout)
		{
			npc.m_fbGunout = true;
			switch(GetRandomInt(0,2))
			{
				case 0:
				{
					CPrintToChatAll("{blue}Huscarls{default}: Ready to die?");
				}
				case 1:
				{
					CPrintToChatAll("{blue}Huscarls{default}: You can't run forever.");
				}
				case 2:
				{
					CPrintToChatAll("{blue}Huscarls{default}: All of your comrades are fallen.");
				}
			}
		}
	}
	if(RaidModeTime < GetGameTime() && !YaWeFxxked[npc.index])
	{
		npc.m_flMeleeArmor = 0.33;
		npc.m_flRangedArmor = 0.33;
		int MaxHealth = RoundToCeil(GetEntProp(npc.index, Prop_Data, "m_iMaxHealth")*1.25);
		SetEntProp(npc.index, Prop_Data, "m_iHealth", MaxHealth);
		SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", MaxHealth);
		switch(GetRandomInt(1, 4))
		{
			case 1:CPrintToChatAll("{lightblue}Huscarls{default}: Ok. Enough. {crimson}Time to Finish.{default}");
			case 2:CPrintToChatAll("{lightblue}Huscarls{default}: The troops have arrived and will begin destroying the intruders!");
			case 3:CPrintToChatAll("{lightblue}Huscarls{default}: Backup team has arrived. Catch those damn bastards!");
			case 4:CPrintToChatAll("{lightblue}Huscarls{default}: After this, Im heading to Rusted Bolt Pub. {unique}I need beer.{default}");
		}
		BlockLoseSay = true;
		YaWeFxxked[npc.index] = true;
	}
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		//npc.PlayHurtSound();
	}

	if(npc.m_flNextThinkTime > gameTime)
		return;
	npc.m_flNextThinkTime = gameTime + 0.1;
	
	if(npc.m_flArmorCount > 0.0)
	{
		float percentageArmorLeft = npc.m_flArmorCount / npc.m_flArmorCountMax;

		if(percentageArmorLeft <= 0.0)
		{
			if(IsValidEntity(npc.m_iWearable1))
				RemoveEntity(npc.m_iWearable1);
		}
		if(percentageArmorLeft > 0.0)
		{
			if(!IsValidEntity(npc.m_iWearable1))
				npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/heavy/sf14_heavy_robo_chest/sf14_heavy_robo_chest.mdl");
		}
	}
	else
	{
		if(IsValidEntity(npc.m_iWearable1))
			RemoveEntity(npc.m_iWearable1);
	}
	
	npc.m_flSpeed = 300.0+ExtraMovement[npc.index];

	if(!IsValidEntity(RaidBossActive))
		RaidBossActive = EntIndexToEntRef(npc.index);

	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		switch(HuscarlsSelfDefense(npc, gameTime, npc.m_iTarget, flDistanceToTarget))
		{
			case 0:
			{
				npc.StartPathing();
				npc.m_bPathing = true;
				npc.m_bisWalking = true;
				npc.m_bAllowBackWalking = false;
				//Get the normal prediction code.
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
			}
			case 1:
			{
				npc.StartPathing();
				npc.m_bPathing = true;
				npc.m_bisWalking = true;
				npc.m_bAllowBackWalking = true;
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget,_,vBackoffPos);
				NPC_SetGoalVector(npc.index, vBackoffPos, true); //update more often, we need it
			}
			case 2:
			{
				npc.StopPathing();
				npc.m_bPathing = false;
				npc.m_bisWalking = false;
			}
			case 3:
			{
				npc.StartPathing();
				npc.m_bPathing = true;
				npc.m_bisWalking = true;
				npc.m_bAllowBackWalking = false;
				static float vOrigin[3], vAngles[3];
				GetEntPropVector(npc.index, Prop_Data, "m_angRotation", vAngles);
				vAngles[0]=5.0;
				EntityLookPoint(npc.index, vAngles, VecSelfNpc, vOrigin);
				NPC_SetGoalVector(npc.index, vOrigin);
			}
		}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}

	if(npc.m_flDoingAnimation < gameTime)
		HuscarlsAnimationChange(npc);
}

static Action Internal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Huscarls npc = view_as<Huscarls>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
	float gameTime = GetGameTime(npc.index);

	if(npc.m_flArmorCount <= 0.0)
	{
		if(IsValidEntity(npc.m_iWearable1))
			RemoveEntity(npc.m_iWearable1);
		if(npc.m_flHeadshotCooldown < gameTime)
		{
			npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
			npc.m_blPlayHurtAnimation = true;
		}		
	}
	
	bool hot;
	bool magic;
	bool pierce;

	if((damagetype & DMG_SLASH))
	{
		pierce = true;
	}
	else
	{
		if((damagetype & DMG_BLAST) && f_IsThisExplosiveHitscan[attacker] != gameTime)
		{
			hot = true;
			pierce = true;
		}
		
		if(damagetype & DMG_PLASMA)
		{
			magic = true;
			pierce = true;
		}
		else if((damagetype & DMG_SHOCK) || (i_HexCustomDamageTypes[npc.index] & ZR_DAMAGE_LASER_NO_BLAST))
		{
			magic = true;
		}
	}
	int maxhealth = ReturnEntityMaxHealth(npc.index);
	if(GetArmor[npc.index]>=float(maxhealth)*0.25)
	{
		BlastArmor[npc.index] = false;
		MagicArmor[npc.index] = false;
		BulletArmor[npc.index] = false;
		switch(Huscarls_Get_HighDMGType(npc.index))
		{
			case 0: BlastArmor[npc.index]=true;
			case 1:	MagicArmor[npc.index]=true;
			default:BulletArmor[npc.index]=true;
		}
		GrantEntityArmor(npc.index, false, 0.075, 0.5, 0);
		DMGTypeArmorDuration[npc.index] = gameTime + 30.0;
		GetArmor[npc.index] = 0.0;
		BlastDMG[npc.index] = 0.0;
		MagicDMG[npc.index] = 0.0;
		BulletDMG[npc.index] = 0.0;
	}
	else
	{
		if(DMGTypeArmorDuration[npc.index] < gameTime)
		{
			BlastArmor[npc.index] = false;
			MagicArmor[npc.index] = false;
			BulletArmor[npc.index] = false;
		}
		if(hot)
		{
			if(BlastArmor[npc.index])
			{
				damage *= 0.75;
				damagePosition[2] += 65.0;
				npc.DispatchParticleEffect(npc.index, "medic_resist_match_blast_blue", damagePosition, NULL_VECTOR, NULL_VECTOR);
				damagePosition[2] -= 65.0;
			}
			BlastDMG[npc.index] += damage;
		}
		if(magic)
		{
			if(MagicArmor[npc.index])
			{
				damage *= 0.75;
				damagePosition[2] += 65.0;
				npc.DispatchParticleEffect(npc.index, "medic_resist_match_fire_blue", damagePosition, NULL_VECTOR, NULL_VECTOR);
				damagePosition[2] -= 65.0;
			}
			MagicDMG[npc.index] += damage;
		}
		if(!pierce)
		{
			if(BulletArmor[npc.index])
			{
				damage *= 0.75;
				damagePosition[2] += 65.0;
				npc.DispatchParticleEffect(npc.index, "medic_resist_match_bullet_blue", damagePosition, NULL_VECTOR, NULL_VECTOR);
				damagePosition[2] -= 65.0;
			}
			BulletDMG[npc.index] += damage;
		}
		GetArmor[npc.index] += damage;
	}
	
	if(npc.m_flHuscarlsAdaptiveArmorDuration > gameTime)
	{
		DynamicCharger[npc.index] += damage;
		if(!IsFakeClient(attacker) && IsValidClient(attacker))
			EmitSoundToClient(attacker, g_EnergyshieldSounds[GetRandomInt(0, sizeof(g_EnergyshieldSounds) - 1)], _, _, _, _, 0.7, _, _, _, _, false);
		if(IsValidEntity(npc.m_iWearable2))
		{
			ExtinguishTarget(npc.m_iWearable2);
			IgniteTargetEffect(npc.m_iWearable2);
		}
	}
	
	return Plugin_Changed;
}

static void Internal_NPCDeath(int entity)
{
	Huscarls npc = view_as<Huscarls>(entity);
	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
	
	ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);

	RaidBossActive = INVALID_ENT_REFERENCE;
	
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

	int particle = EntRefToEntIndex(i_Huscarls_eye_particle[npc.index]);
	if(IsValidEntity(particle))
	{
		RemoveEntity(particle);
		i_Huscarls_eye_particle[npc.index]=INVALID_ENT_REFERENCE;
	}

	if(BlockLoseSay)
		return;
	switch(GetRandomInt(0,2))
	{
		case 0:CPrintToChatAll("{lightblue}Huscarls{default}: Ugh, I need backup");
		case 1:CPrintToChatAll("{lightblue}Huscarls{default}: I will never let you trample over the glory of {gold}Victoria{default} Again!");
		case 2:CPrintToChatAll("{lightblue}Huscarls{default}: You intruders will soon face the {crimson}Real Deal.{default}");
	}
	npc.PlayDeathSound();	
}

void HuscarlsAnimationChange(Huscarls npc)
{
	
	if(npc.m_iChanged_WalkCycle == 0)
	{
		npc.m_iChanged_WalkCycle = -1;
	}
	switch(npc.i_GunMode)
	{
		case 1: //primary
		{
			if (npc.IsOnGround())
			{
				if(npc.m_iChanged_WalkCycle != 1)
				{
				// ResetHuscarlsWeapon(npc, 1);
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
				//	ResetHuscarlsWeapon(npc, 1);
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
				//	ResetHuscarlsWeapon(npc, 0);
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
				//	ResetHuscarlsWeapon(npc, 0);
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_MP_JUMP_FLOAT_MELEE");
					npc.StartPathing();
				}	
			}
		}
	}
}

int HuscarlsSelfDefense(Huscarls npc, float gameTime, int target, float distance)
{
	bool SpecialAttack;
	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	if(npc.m_flHuscarlsAdaptiveArmorCoolDown < gameTime)
	{
		switch(I_cant_do_this_all_day[npc.index])
		{
			case 0:
			{
				NPC_StopPathing(npc.index);
				npc.m_bPathing = false;
				npc.m_bisWalking = false;
				npc.AddActivityViaSequence("layer_taunt_unleashed_rage_heavy");
				npc.m_flAttackHappens = 0.0;
				npc.SetCycle(0.5);
				npc.SetPlaybackRate(1.0);
				npc.m_iChanged_WalkCycle = 0;
				npc.m_flDoingAnimation = gameTime + 3.4;
				Delay_Attribute[npc.index] = gameTime + 1.0;
				I_cant_do_this_all_day[npc.index] = 1;
			}
			case 1:
			{
				if(Delay_Attribute[npc.index] < gameTime)
				{
					DynamicCharger[npc.index] = 0.0;
					npc.m_flHuscarlsAdaptiveArmorDuration = gameTime + 3.0;
					I_cant_do_this_all_day[npc.index] = 2;
				}
			}
			case 2:
			{
				if(npc.m_flHuscarlsAdaptiveArmorDuration < gameTime)
				{
					int maxhealth = ReturnEntityMaxHealth(npc.index);
					float MAXCharger = (DynamicCharger[npc.index]/(float(maxhealth)*0.05))*0.05;
					if(MAXCharger > 0.05)MAXCharger = 0.05;
					GrantEntityArmor(npc.index, false, MAXCharger, 0.5, 0);
					I_cant_do_this_all_day[npc.index] = 3;
				}
				else
				{
					npc.m_flHuscarlsRushCoolDown = gameTime + 3.0;
					npc.m_flHuscarlsAdaptiveArmorCoolDown = gameTime + 15.0;
					npc.m_flHuscarlsDeployEnergyShieldCoolDown = gameTime + 3.0;	
					I_cant_do_this_all_day[npc.index] = 0;
				}
			}
			case 3:
			{
				npc.m_flHuscarlsRushCoolDown = gameTime + 3.0;
				npc.m_flHuscarlsAdaptiveArmorCoolDown = gameTime + 30.0;
				npc.m_flHuscarlsDeployEnergyShieldCoolDown = gameTime + 3.0;
				I_cant_do_this_all_day[npc.index] = 0;
			}
		}
		SpecialAttack=true;
	}
	else if(npc.m_flHuscarlsRushCoolDown < gameTime)
	{
		switch(I_cant_do_this_all_day[npc.index])
		{
			case 0:
			{
				npc.m_flDoingAnimation = gameTime + 0.5;
				Delay_Attribute[npc.index] = gameTime + 0.5;
				NPC_StopPathing(npc.index);
				npc.m_bPathing = false;
				npc.m_bisWalking = false;
				npc.AddActivityViaSequence("layer_taunt_soviet_showoff");
				npc.m_flAttackHappens = 0.0;
				npc.SetCycle(0.5);
				npc.SetPlaybackRate(1.0);
				npc.m_iChanged_WalkCycle = 0;
				I_cant_do_this_all_day[npc.index] = 1;
			}
			case 1:
			{
				if(Delay_Attribute[npc.index] < gameTime)
				{
					ExtraMovement[npc.index] = 300.0;
					npc.m_flHuscarlsRushDuration = gameTime + 5.0;
					I_cant_do_this_all_day[npc.index] = 2;
				}
			}
			case 2:
			{
				static float vOrigin[3], vAngles[3], tOrigin[3];
				WorldSpaceCenter(npc.index, vOrigin);
				GetEntPropVector(npc.index, Prop_Data, "m_angRotation", vAngles);
				EntityLookPoint(npc.index, vAngles, vOrigin, tOrigin);
				float Tdistance = GetVectorDistance(vOrigin, tOrigin);
				if(Tdistance<125.0)
				{
					Explode_Logic_Custom(0.0, npc.index, npc.index, -1, VecSelfNpc, 125.0, _, _, true, _, false, _, Compressor);
					for(int client_check=1; client_check<=MaxClients; client_check++)
					{
						if(IsValidClient(client_check) && Frozen_Player[client_check])
						{
							TF2_AddCondition(client_check, TFCond_LostFooting, 1.0);
							TF2_AddCondition(client_check, TFCond_AirCurrent, 1.0);
							SetEntityCollisionGroup(client_check, 5);
							Frozen_Player[client_check]=false;
						}
					}
					Delay_Attribute[npc.index] = gameTime + 1.0;
					I_cant_do_this_all_day[npc.index] = 5;
					CreateEarthquake(vOrigin, 0.5, 350.0, 16.0, 255.0);
				}
				else if(npc.m_flHuscarlsRushDuration < gameTime)
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
						NPC_StopPathing(npc.index);
						npc.m_bPathing = false;
						npc.m_bisWalking = false;
						npc.AddActivityViaSequence("layer_taunt_bare_knuckle_beatdown_outro");
						npc.m_flAttackHappens = 0.0;
						npc.SetCycle(0.01);
						npc.SetPlaybackRate(1.0);
						npc.m_flDoingAnimation = gameTime + 1.0;
						npc.m_iChanged_WalkCycle = 0;
						
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
						
						static float flMyPos_2[3];
						flMyPos[2] += 800.0;
						WorldSpaceCenter(target, flMyPos_2);

						flMyPos[0] = flMyPos_2[0];
						flMyPos[1] = flMyPos_2[1];
						PluginBot_Jump(npc.index, flMyPos);
						Explode_Logic_Custom(0.0, npc.index, npc.index, -1, VecSelfNpc, 125.0, _, _, true, _, false, _, ToTheMoon);
						SetEntityCollisionGroup(npc.index, 1);
						I_cant_do_this_all_day[npc.index] = 3;
					}
					else
					{
						Explode_Logic_Custom(0.0, npc.index, npc.index, -1, VecSelfNpc, 125.0, _, _, true, _, false, _, Compressor);
						for(int client_check=1; client_check<=MaxClients; client_check++)
						{
							if(IsValidClient(client_check) && Frozen_Player[client_check])
							{
								TF2_AddCondition(client_check, TFCond_LostFooting, 1.0);
								TF2_AddCondition(client_check, TFCond_AirCurrent, 1.0);
								SetEntityCollisionGroup(client_check, 5);
								Frozen_Player[client_check]=false;
							}
						}
						Delay_Attribute[npc.index] = gameTime + 1.0;
						I_cant_do_this_all_day[npc.index] = 5;
						CreateEarthquake(vOrigin, 0.5, 350.0, 16.0, 255.0);
					}
				}
				else
				{
					Explode_Logic_Custom(0.0, npc.index, npc.index, -1, VecSelfNpc, 125.0, _, _, true, _, false, _, Got_it_fucking_shit);
					//npc.AddActivityViaSequence("layer_PASSTIME_throw_end");
					//npc.AddActivityViaSequence("PASSTIME_throw_end");
					npc.SetActivity("PASSTIME_throw_end", true);
					npc.m_flAttackHappens = 0.0;
					npc.SetCycle(0.4);
					npc.SetPlaybackRate(0.0);
					npc.AddGesture("ACT_MP_RUN_MELEE");
					//npc.SetActivity("ACT_MP_RUN_MELEE");
					npc.m_flDoingAnimation = gameTime + 4.9;
					return 3;
				}
			}
			case 3:
			{
				if(Delay_Attribute[npc.index] < gameTime)
				{
					npc.AddActivityViaSequence("layer_taunt_bare_knuckle_beatdown_outro");	
					npc.SetCycle(0.85);
					npc.SetPlaybackRate(1.0);
					npc.m_flDoingAnimation = gameTime + 0.25;
					Delay_Attribute[npc.index] = gameTime + 0.75;
					npc.m_iChanged_WalkCycle = 0;
					I_cant_do_this_all_day[npc.index] = 4;
				}
			}
			case 4:
			{
				if(Delay_Attribute[npc.index] < gameTime)
				{
					Explode_Logic_Custom(0.0, npc.index, npc.index, -1, VecSelfNpc, 400.0, _, _, true, _, false, _, Ground_pound);
					npc.SetVelocity({0.0,0.0,-1500.0});
					Delay_Attribute[npc.index] = gameTime + 1.0;
					I_cant_do_this_all_day[npc.index] = 5;
					static float vOrigin[3], vAngles[3], tOrigin[3];
					WorldSpaceCenter(npc.index, vOrigin);
					vAngles[0]=90.0;
					EntityLookPoint(npc.index, vAngles, vOrigin, tOrigin);
					CreateEarthquake(tOrigin, 0.5, 350.0, 16.0, 255.0);
				}
			}
			case 5:
			{
				SetEntityCollisionGroup(npc.index, 5);
				npc.SetPlaybackRate(1.0);
				for(int client_check=1; client_check<=MaxClients; client_check++)
				{
					if(IsValidClient(client_check) && Frozen_Player[client_check])
					{
						TF2_AddCondition(client_check, TFCond_LostFooting, 1.0);
						TF2_AddCondition(client_check, TFCond_AirCurrent, 1.0);
						SetEntityCollisionGroup(client_check, 5);
						Frozen_Player[client_check]=false;
					}
				}
				if(Delay_Attribute[npc.index] < gameTime)
					I_cant_do_this_all_day[npc.index] = 6;
			}
			case 6:
			{
				npc.m_flHuscarlsRushCoolDown = gameTime + 20.0;
				npc.m_flHuscarlsAdaptiveArmorCoolDown = gameTime + 6.0;
				npc.m_flHuscarlsDeployEnergyShieldCoolDown = gameTime + 6.0;
				I_cant_do_this_all_day[npc.index] = 0;
				ExtraMovement[npc.index] = 0.0;
			}
		}
		SpecialAttack=true;
	}
	if(SpecialAttack)
	{
		npc.m_flDoingAnimation = gameTime + 0.5;
		return 2;
	}
	else if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
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
				bool PlaySound = false, PlayPOWERSound = false;
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
							float damagebasic = 50.0;
							damagebasic *= 1.15;
							float damage = damagebasic;
							if(DynamicCharger[npc.index]>0.0 && npc.m_flHuscarlsAdaptiveArmorDuration < gameTime)
							{
								damage+=DynamicCharger[npc.index];
								if(damage>damagebasic*5.0)damage=damagebasic*5.0;
								DynamicCharger[npc.index]=0.0;
								ExtinguishTarget(npc.m_iWearable2);
								CreateEarthquake(VecEnemy, 0.5, 350.0, 16.0, 255.0);
								PlayPOWERSound = true;
							}

							SDKHooks_TakeDamage(targetTrace, npc.index, npc.index, damage * RaidModeScaling, DMG_CLUB, -1, _, vecHit);
							bool Knocked = false;
										
							if(IsValidClient(targetTrace))
							{
								if(IsInvuln(targetTrace))
								{
									Knocked = true;
									Custom_Knockback(npc.index, targetTrace, 300.0, true);
									if(!NpcStats_IsEnemySilenced(npc.index))
									{
										TF2_AddCondition(targetTrace, TFCond_LostFooting, 0.25);
										TF2_AddCondition(targetTrace, TFCond_AirCurrent, 0.25);
									}
								}
								else
								{
									if(!NpcStats_IsEnemySilenced(npc.index))
									{
										TF2_AddCondition(targetTrace, TFCond_LostFooting, 0.25);
										TF2_AddCondition(targetTrace, TFCond_AirCurrent, 0.25);
									}
								}
							}
							if(!Knocked)
								Custom_Knockback(npc.index, targetTrace, 150.0, true); 
						} 
					}
				}
				if(PlaySound)
					npc.PlayMeleeHitSound();
				if(PlayPOWERSound)
				{
					ParticleEffectAt(VecEnemy, "rd_robot_explosion", 1.0);
					npc.PlayMeleeHitSound();
				}
			}
		}
	}
	else if(gameTime > npc.m_flNextMeleeAttack)
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
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
							
					npc.m_flAttackHappens = gameTime + 0.25;
					npc.m_flNextMeleeAttack = gameTime + 1.5;
					npc.m_flDoingAnimation = gameTime + 0.25;
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

static void Got_it_fucking_shit(int entity, int victim, float damage, int weapon)
{
	Huscarls npc = view_as<Huscarls>(entity);
	float vecHit[3]; WorldSpaceCenter(victim, vecHit);
	if(IsValidEntity(npc.index) && GetTeam(npc.index) != GetTeam(victim) && Can_I_See_Enemy(npc.index, victim))
	{
		char classname[60];
		GetEntityClassname(victim, classname, sizeof(classname));
		if(!StrContains(classname, "zr_base_npc", true) || !StrContains(classname, "player", true) || !StrContains(classname, "obj_dispenser", true) || !StrContains(classname, "obj_sentrygun", true))
		{
			if(victim <= MaxClients)
			{
				if(IsValidClient(victim))
				{
					//AcceptEntityInput(victim, "ClearParent");
					float flPos[3]; // original
					float flAng[3]; // original
			
					npc.GetAttachment("RightHand", flPos, flAng);
				
					TeleportEntity(victim, flPos, NULL_VECTOR, {0.0,0.0,0.0});
					TF2_AddCondition(victim, TFCond_HalloweenKartNoTurn, 1.0, 0);
					TF2_AddCondition(victim, TFCond_CompetitiveLoser, 1.0, 0);
					SetEntityCollisionGroup(victim, 1);
					/*SetParent(npc.index, victim, "RightHand");
					TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, {0.0,0.0,0.0});*/
					Frozen_Player[victim]=true;
				}
				else
				{
					SDKHooks_TakeDamage(victim, npc.index, npc.index, 1000.0, DMG_CLUB, -1, _, vecHit);
					Custom_Knockback(npc.index, victim, 1500.0, true);
				}
			}
		}
	}
}

static void Compressor(int entity, int victim, float damage, int weapon)
{
	Huscarls npc = view_as<Huscarls>(entity);
	float vecHit[3]; WorldSpaceCenter(victim, vecHit);
	if(IsValidEntity(npc.index) && GetTeam(npc.index) != GetTeam(victim))
	{
		char classname[60];
		GetEntityClassname(victim, classname, sizeof(classname));
		if(!StrContains(classname, "zr_base_npc", true) || !StrContains(classname, "player", true) || !StrContains(classname, "obj_dispenser", true) || !StrContains(classname, "obj_sentrygun", true))
		{
			if(victim <= MaxClients)
			{
				damage = 40.0 * RaidModeScaling;
				damage += ReturnEntityMaxHealth(victim)*0.1;
				SDKHooks_TakeDamage(victim, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);
				if(IsValidClient(victim))
				{
					TF2_AddCondition(victim, TFCond_HalloweenKartNoTurn, 1.0, 0);
					TF2_AddCondition(victim, TFCond_CompetitiveLoser, 1.0, 0);
				}
				else FreezeNpcInTime(victim, 1.0, true);
				Custom_Knockback(npc.index, victim, 1500.0, true);
			}
		}
	}
}

static void ToTheMoon(int entity, int victim, float damage, int weapon)
{
	Huscarls npc = view_as<Huscarls>(entity);
	if(IsValidEntity(npc.index) && GetTeam(npc.index) != GetTeam(victim))
	{
		char classname[60];
		GetEntityClassname(victim, classname, sizeof(classname));
		if(!StrContains(classname, "zr_base_npc", true) || !StrContains(classname, "player", true) || !StrContains(classname, "obj_dispenser", true) || !StrContains(classname, "obj_sentrygun", true))
		{
			if(victim <= MaxClients)
			{
				float fVelocity[3];
				fVelocity[2] = 1000.0;
				if(IsValidClient(victim))
				{
					TF2_AddCondition(victim, TFCond_HalloweenKartNoTurn, 2.0, 0);
					TF2_AddCondition(victim, TFCond_CompetitiveLoser, 2.0, 0);
					TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, fVelocity);
				}
				else
				{
					PluginBot_Jump(victim, fVelocity);
					FreezeNpcInTime(victim, 1.0, true);
				}
				
			}
		}
	}
}

static void Ground_pound(int entity, int victim, float damage, int weapon)
{
	Huscarls npc = view_as<Huscarls>(entity);
	float vecHit[3]; WorldSpaceCenter(victim, vecHit);
	if(IsValidEntity(npc.index) && GetTeam(npc.index) != GetTeam(victim))
	{
		char classname[60];
		GetEntityClassname(npc.index, classname, sizeof(classname));
		if(!StrContains(classname, "zr_base_npc", true) || !StrContains(classname, "player", true) || !StrContains(classname, "obj_dispenser", true) || !StrContains(classname, "obj_sentrygun", true))
		{
			if(victim <= MaxClients)
			{
				damage = 40.0 * RaidModeScaling;
				damage += ReturnEntityMaxHealth(victim)*0.05;
				SDKHooks_TakeDamage(victim, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);
				float fVelocity[3];
				fVelocity[2] = -2000.0;
				if(IsValidClient(victim))
				{
					TF2_AddCondition(victim, TFCond_HalloweenKartNoTurn, 1.0, 0);
					TF2_AddCondition(victim, TFCond_CompetitiveLoser, 1.0, 0);
				}
				else FreezeNpcInTime(victim, 1.0, true);
				TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, fVelocity);
				
			}
		}
	}
}

static int Huscarls_Get_HighDMGType(int entity)
{
	Huscarls npc = view_as<Huscarls>(entity);
	int DMGType;
	float HighDMG;
	float LowDMG;
	for(int i = 0; i <= 2; i++)
	{
		switch(i)
		{
			case 0:	LowDMG=BlastDMG[npc.index];
			case 1:	LowDMG=MagicDMG[npc.index];
			default: LowDMG=BulletDMG[npc.index];
		}
		if(HighDMG)
		{
			if(LowDMG > HighDMG)
			{
				DMGType = i;
				HighDMG = LowDMG;			
			}
		}
		else
		{
			DMGType = i;
			HighDMG = LowDMG;
		}
	}
	return DMGType;
}