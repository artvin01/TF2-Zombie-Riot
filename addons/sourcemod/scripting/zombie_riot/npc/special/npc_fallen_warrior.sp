#pragma semicolon 1
#pragma newdecls required

static char g_HurtSounds[][] =
{
	"npc/metropolice/pain1.wav",
	"npc/metropolice/pain2.wav",
	"npc/metropolice/pain3.wav",
	"npc/metropolice/pain4.wav",
};

static char g_KillSounds[][] =
{
	"npc/metropolice/vo/affirmative.wav",
	"npc/metropolice/vo/affirmative2.wav",
	"npc/metropolice/vo/canalblock.wav",
	"npc/metropolice/vo/chuckle.wav",
	"npc/metropolice/vo/citizen.wav",
	"npc/metropolice/vo/code7.wav",
	"npc/metropolice/vo/code100.wav",
	"npc/metropolice/vo/copy.wav",
	"npc/metropolice/vo/breakhiscover.wav",
	"npc/metropolice/vo/help.wav",
	"npc/metropolice/vo/hesgone148.wav",
	"npc/metropolice/vo/hesrunning.wav",
	"npc/metropolice/vo/infection.wav",
	"npc/metropolice/vo/king.wav",
	"npc/metropolice/vo/needanyhelpwiththisone.wav",
	"npc/metropolice/vo/pickupthecan1.wav",
};
static char g_IdleAlertedSounds[][] = 
{
	"npc/metropolice/vo/pickupthecan2.wav",
	"npc/metropolice/vo/sociocide.wav",
	"npc/metropolice/vo/watchit.wav",
	"npc/metropolice/vo/xray.wav",
	"npc/metropolice/vo/youknockeditover.wav",
};
static const char g_MeleeHitSounds[][] = 
{
	"weapons/samurai/tf_katana_slice_01.wav",
	"weapons/samurai/tf_katana_slice_02.wav",
	"weapons/samurai/tf_katana_slice_03.wav",
};
static const char g_MeleeAttackSounds[][] = 
{
	"weapons/samurai/tf_katana_01.wav",
	"weapons/samurai/tf_katana_02.wav",
	"weapons/samurai/tf_katana_03.wav",
	"weapons/samurai/tf_katana_04.wav",
	"weapons/samurai/tf_katana_05.wav",
	"weapons/samurai/tf_katana_06.wav",
};
static const char  g_DeathSounds[][] =
{
	"misc/outer_space_transition_01.wav",
};
static const char g_IntroSounds[][] =
{
	"misc/rd_spaceship01.wav",
};

static float fl_AlreadyStrippedMusic[MAXTF2PLAYERS];
int GetRandomSeedEachWave;

#define GULN_DEBUFF_RANGE 500.0


void FallenWarriorGetRandomSeedEachWave()
{
	int oldseed = GetRandomSeedEachWave;
	GetRandomSeedEachWave = GetURandomInt();
	//prevent 1 in 4 billion chance.
	if(oldseed == GetRandomSeedEachWave)
		GetRandomSeedEachWave += 1;
}

int GetRandomSeedFallenWarrior()
{
	return GetRandomSeedEachWave;
}


void FallenWarrior_OnMapStart()
{
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_KillSounds)); i++) { PrecacheSound(g_KillSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_IntroSounds)); i++) { PrecacheSound(g_IntroSounds[i]); }
	for (int i = 0; i < (sizeof(g_DeathSounds)); i++) { PrecacheSound(g_DeathSounds[i]); }
	PrecacheSound("weapons/bat_baseball_hit_flesh.wav");
	PrecacheSound("misc/rd_spaceship01.wav");
	PrecacheSound("npc/metropolice/vo/infection.wav");
	PrecacheModel(COMBINE_CUSTOM_MODEL);
	PrecacheModel("models/player/soldier.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Fallen Warrior");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_fallen_warrior");
	strcopy(data.Icon, sizeof(data.Icon), "demoknight_samurai");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Special;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return FallenWarrior(vecPos, vecAng, team, data);
}
static int i_fallen_eyeparticle[MAXENTITIES] = {-1, ...};
static int i_fallen_headparticle[MAXENTITIES] = {-1, ...};
static int i_fallen_bodyparticle[MAXENTITIES] = {-1, ...};

static char[] GetPanzerHealth()
{
	int health = 100;
	
	health = RoundToNearest(float(health) * ZRStocks_PlayerScalingDynamic()); //yep its high! will need tos cale with waves expoentially.
	
	float temp_float_hp = float(health);
	
	if(Waves_GetRound()+1 < 30)
	{
		health = RoundToCeil(Pow(((temp_float_hp + float(Waves_GetRound()+1)) * float(Waves_GetRound()+1)),1.20));
	}
	else if(Waves_GetRound()+1 < 45)
	{
		health = RoundToCeil(Pow(((temp_float_hp + float(Waves_GetRound()+1)) * float(Waves_GetRound()+1)),1.25));
	}
	else
	{
		health = RoundToCeil(Pow(((temp_float_hp + float(Waves_GetRound()+1)) * float(Waves_GetRound()+1)),1.35)); //Yes its way higher but i reduced overall hp of him
	}
	
	health /= 3;
	
	char buffer[16];
	IntToString(health, buffer, sizeof(buffer));
	return buffer;
}
methodmap FallenWarrior < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	public void PlayHurtSound()
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		
		this.m_flNextHurtSound = GetGameTime(this.index) + 1.0;
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 70);
	}
	public void PlayDeathSound()
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_IntroSounds) - 1)],  _, _, _, _, BOSS_ZOMBIE_VOLUME, 70);
	}
	public void PlayIntroSound()
	{
		if(this.m_flNextRangedAttack > GetGameTime(this.index))
			return;
		
		this.m_flNextRangedAttack = GetGameTime(this.index) + 5.0;
		EmitSoundToAll(g_IntroSounds[GetRandomInt(0, sizeof(g_IntroSounds) - 1)],  _, _, _, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayFriendlySound()
	{
		EmitSoundToAll("npc/metropolice/vo/infection.wav", this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
	}
	public void PlayMeleeSound()
	{
		this.m_flNextHurtSound = GetGameTime(this.index) + 1.0;
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 70);
	}
	public void PlayKillSound()
	{
		this.m_flNextHurtSound = GetGameTime(this.index) + 2.0;
		EmitSoundToAll(g_KillSounds[GetRandomInt(0, sizeof(g_KillSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 70);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}

	public FallenWarrior(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		FallenWarrior npc = view_as<FallenWarrior>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.4", GetPanzerHealth(), ally));

		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup"); 

		
		i_NpcWeight[npc.index] = 4;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");

		int iActivity = npc.LookupActivity("ACT_CUSTOM_WALK_SAMURAI");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		if(ally == TFTeam_Red)
		{
			npc.PlayFriendlySound();
		}
		else
		{
			npc.PlayIntroSound();
		}
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 255, 100, 100, 255);
		for(int client_clear=1; client_clear<=MaxClients; client_clear++)
		{
			fl_AlreadyStrippedMusic[client_clear] = 0.0; //reset to 0
		}

		func_NPCDeath[npc.index] = view_as<Function>(FallenWarrior_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(FallenWarrior_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(FallenWarrior_ClotThink);
		
		npc.m_bLostHalfHealth = false;
		npc.m_bThisNpcIsABoss = true;

		npc.m_flMeleeArmor = 1.35; 		
		npc.m_flRangedArmor = 0.8;

		
		npc.StartPathing();
		npc.m_flSpeed = 250.0;
		npc.m_flNextRangedAttack = GetGameTime();
		
		
		int skin = 1;
		float size = 1.2;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/demo/hwn2022_nightbane_brim/hwn2022_nightbane_brim.mdl", "", 2, 1.3);

		npc.m_iWearable2 = npc.EquipItem("weapon_bone", "models/workshop/player/items/demo/sbox2014_demo_samurai_armour/sbox2014_demo_samurai_armour.mdl", "", skin, 1.0);

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/scout/hwn2019_fuel_injector_style3/hwn2019_fuel_injector_style3.mdl", "", skin, size);

		npc.m_iWearable4 = npc.EquipItem("weapon_bone", "models/workshop/player/items/demo/sf14_deadking_pauldrons/sf14_deadking_pauldrons.mdl", "", skin, size);

		npc.m_iWearable5 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_shogun_katana/c_shogun_katana.mdl", "", skin, size);

		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/soldier/bak_caped_crusader/bak_caped_crusader.mdl", "", 2, size);

		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);

		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
		SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
		SetEntityRenderMode(npc.m_iWearable5, RENDER_TRANSCOLOR);
		SetEntityRenderMode(npc.m_iWearable6, RENDER_TRANSCOLOR);

		SetEntityRenderColor(npc.m_iWearable1, 175, 100, 100, 255);
		SetEntityRenderColor(npc.m_iWearable2, 200, 150, 100, 255);
		SetEntityRenderColor(npc.m_iWearable3, 100, 100, 100, 255);
		SetEntityRenderColor(npc.m_iWearable4, 200, 50, 50, 255);
		SetEntityRenderColor(npc.m_iWearable5, 150, 150, 150, 255);
		SetEntityRenderColor(npc.m_iWearable6, 200, 150, 100, 255);

		if(ally != TFTeam_Red)
		{
			float flPos[3], flAng[3];
					
			npc.GetAttachment("head", flPos, flAng);
			i_fallen_headparticle[npc.index] = EntIndexToEntRef(ParticleEffectAt_Parent(flPos, "unusual_smoking", npc.index, "head", {0.0,-5.0,-10.0}));
			i_fallen_eyeparticle[npc.index] = EntIndexToEntRef(ParticleEffectAt_Parent(flPos, "unusual_psychic_eye_white_glow", npc.index, "head", {0.0,5.0,-15.0}));
			i_fallen_bodyparticle[npc.index] = EntIndexToEntRef(ParticleEffectAt_Parent(flPos, "env_snow_light_001", npc.index, "m_vecAbsOrigin", {50.0,-200.0,0.0}));
		}

		float wave = float(Waves_GetRound()+1);
		wave *= 0.1;
		npc.m_flWaveScale = wave;

		npc.Anger = false;

		Citizen_MiniBossSpawn();
		return npc;
	}
}

public void FallenWarrior_ClotThink(int iNPC)
{
	FallenWarrior npc = view_as<FallenWarrior>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_STOMACH", false);
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
		
		//PluginBot_NormalJump(npc.index);
	}
	if(GetTeam(npc.index) != TFTeam_Red)
	{
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client))
			{
				if(fl_AlreadyStrippedMusic[client] < GetEngineTime())
				{
					Music_Stop_All(client); //This is actually more expensive then i thought.
				}
				SetMusicTimer(client, GetTime() + 3);
				fl_AlreadyStrippedMusic[client] = GetEngineTime() + 2.5;
			}
		}
	}
	float TrueArmor = 1.0;

	if(npc.m_bLostHalfHealth)
	{
		if(npc.m_flSpeed > 250.0)
		{
			npc.m_flSpeed = 250.0;
		}
		if(npc.m_flSpeed < 250.0)
		{
			npc.m_flSpeed += 100.0;
		}
		TrueArmor *= 0.5;
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", 2);
		if(!npc.Anger)
		{
			IgniteTargetEffect(npc.m_iWearable5);
			npc.Anger = true;
			
			if(GetTeam(npc.index) == TFTeam_Red)
			{
				float flPos[3], flAng[3];
						
				npc.GetAttachment("head", flPos, flAng);
				i_fallen_headparticle[npc.index] = EntIndexToEntRef(ParticleEffectAt_Parent(flPos, "unusual_smoking", npc.index, "head", {0.0,-5.0,-10.0}));
				i_fallen_eyeparticle[npc.index] = EntIndexToEntRef(ParticleEffectAt_Parent(flPos, "unusual_psychic_eye_white_glow", npc.index, "head", {0.0,5.0,-15.0}));
				i_fallen_bodyparticle[npc.index] = EntIndexToEntRef(ParticleEffectAt_Parent(flPos, "env_snow_light_001", npc.index, "m_vecAbsOrigin", {50.0,-200.0,0.0}));

				CPrintToChatAll("{crimson}Guln{default}: You must stop {white}Whiteflower{default}! Once and for all...");
			}
		}
	}
	else
	{
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", 1);
	}
	fl_TotalArmor[npc.index] = TrueArmor;

	
	float VecSelfNpcabs[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", VecSelfNpcabs);
	FallenWarrior_ApplyDebuffInLocation(VecSelfNpcabs, GetTeam(npc.index));

	float Range = GULN_DEBUFF_RANGE;
	spawnRing_Vectors(VecSelfNpcabs, Range * 2.0, 0.0, 0.0, 15.0, "materials/sprites/laserbeam.vmt", 125, 50, 50, 200, 1, /*duration*/ 0.11, 20.0, 5.0, 1);	

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
		FallenWarriotSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}

	if(npc.Anger || GetTeam(npc.index) != TFTeam_Red)
	{
		npc.PlayIntroSound();
		npc.PlayIdleAlertSound();
	}
}

public Action FallenWarrior_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	FallenWarrior npc = view_as<FallenWarrior>(victim);
	if((ReturnEntityMaxHealth(npc.index)/2) >= GetEntProp(npc.index, Prop_Data, "m_iHealth") && !npc.m_bLostHalfHealth) 
	{
		npc.m_bLostHalfHealth = true;
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

public void FallenWarrior_NPCDeath(int entity)
{
	FallenWarrior npc = view_as<FallenWarrior>(entity);

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

	if(GetTeam(entity) == TFTeam_Red)
	{
		CPrintToChatAll("{crimson}Guln{default}: And if it comes to this... this {crimson}Chaos{default}... you know what to do...");
	}
	else
	{
		switch(GetRandomInt(1, 4))
		{
			case 1:
			{
				CPrintToChatAll("{crimson}Guln{default}: Thank... you...");
			}
			case 2:
			{
				CPrintToChatAll("{crimson}Guln{default}: This feeling...");
			}
			case 3:
			{
				CPrintToChatAll("{crimson}Guln{default}: Bob... My friend...");
			}
			case 4:
			{
				CPrintToChatAll("{crimson}Guln{default}: Must... stop...");
			}
		}
	}
	

	int particle = EntRefToEntIndex(i_fallen_headparticle[npc.index]);
	int particleeye = EntRefToEntIndex(i_fallen_eyeparticle[npc.index]);
	int particlebody = EntRefToEntIndex(i_fallen_bodyparticle[npc.index]);
	if(IsValidEntity(particle))
	{
		RemoveEntity(particle);
		i_fallen_headparticle[npc.index]=INVALID_ENT_REFERENCE;
	}
	if(IsValidEntity(particleeye))
	{
		RemoveEntity(particle);
		i_fallen_eyeparticle[npc.index]=INVALID_ENT_REFERENCE;
	}
	if(IsValidEntity(particlebody))
	{
		RemoveEntity(particle);
		i_fallen_bodyparticle[npc.index]=INVALID_ENT_REFERENCE;
	}

	float VecSelfNpcabs[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", VecSelfNpcabs);
//	int entity3 = MakeSmokestack(VecSelfNpcabs);

	DataPack pack;
	CreateDataTimer(0.1, Timer_FallenWarrior, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

	for(int i; i < 3; i++)
	{
		pack.WriteFloat(VecSelfNpcabs[i]);
	}
	pack.WriteCell(GetRandomSeedEachWave);
	pack.WriteCell(GetTeam(entity) == TFTeam_Red ? 5 : 1);	// Rogue Special Red Team
	pack.WriteCell(GetTeam(npc.index));

	Citizen_MiniBossDeath(entity);
}


#define PARTICLE_SMOKE		"particle/SmokeStack.vmt"
stock int MakeSmokestack(const float vPos[3])
{
	int entity = CreateEntityByName("env_smokestack");
	DispatchKeyValue(entity, "WindSpeed", "0");
	DispatchKeyValue(entity, "WindAngle", "0");
	DispatchKeyValue(entity, "twist", "0");
	DispatchKeyValue(entity, "StartSize", "30");
	DispatchKeyValue(entity, "SpreadSpeed", "1");
	DispatchKeyValue(entity, "Speed", "30");
	DispatchKeyValue(entity, "SmokeMaterial", PARTICLE_SMOKE);
	DispatchKeyValue(entity, "roll", "0");
	DispatchKeyValue(entity, "rendercolor", "50 50 50");
	DispatchKeyValue(entity, "renderamt", "50");
	DispatchKeyValue(entity, "Rate", "10");
	DispatchKeyValue(entity, "JetLength", "30");
	DispatchKeyValue(entity, "InitialState", "0");
	DispatchKeyValue(entity, "EndSize", "25");
	DispatchKeyValue(entity, "BaseSpread", "15");

	DispatchSpawn(entity);
	ActivateEntity(entity);
	TeleportEntity(entity, vPos, NULL_VECTOR, NULL_VECTOR);
	AcceptEntityInput(entity, "TurnOn");

	SetVariantString("OnUser1 !self:TurnOff::0.6:1");
	AcceptEntityInput(entity, "AddOutput");
	AcceptEntityInput(entity, "FireUser1");

	return entity;
}

public Action Timer_FallenWarrior(Handle timer, DataPack pack)
{
	pack.Reset();
	float VecSelfNpcabs[3];
	for(int i; i < 3; i++)
	{
		VecSelfNpcabs[i] = pack.ReadFloat();
	}
	if(RaidbossIgnoreBuildingsLogic(1))
	{
		return Plugin_Stop;
	}
	int RandomSeed = pack.ReadCell();
	int StayOneMoreWave = pack.ReadCell();
	if(RandomSeed != GetRandomSeedEachWave)
	{
		pack.Position--;				// Team -> StayOneMoreWave
		pack.WriteCell(StayOneMoreWave - 1, false);	// StayOneMoreWave -> Team
		pack.Position--;				// Team -> StayOneMoreWave
		pack.Position--;				// StayOneMoreWave -> RandomSeed
		pack.WriteCell(GetRandomSeedEachWave, false);	// RandomSeed -> StayOneMoreWave
		pack.Position++;				// StayOneMoreWave -> Team
		if(StayOneMoreWave < 1)
		{
			return Plugin_Stop;	
		}
	}
	int Team = pack.ReadCell();
	if(Team != TFTeam_Red && Waves_InSetup())
	{
		return Plugin_Stop;
	}

	FallenWarrior_ApplyDebuffInLocation(VecSelfNpcabs, Team);
	float Range = GULN_DEBUFF_RANGE;
	spawnRing_Vectors(VecSelfNpcabs, Range * 2.0, 0.0, 0.0, 15.0, "materials/sprites/laserbeam.vmt", 125, 50, 50, 200, 1, /*duration*/ 0.11, 20.0, 5.0, 1);	

	return Plugin_Continue;
}


void FallenWarriotSelfDefense(FallenWarrior npc, float gameTime, int target, float distance)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			static float MaxVec[3];
			static float MinVec[3];
			MaxVec = {100.0,100.0,100.0};
			MinVec = {-100.0,-100.0,-100.0};
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, MaxVec,MinVec)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
			{
							
				target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 110.0;
					damageDealt *= npc.m_flWaveScale;

					if(ShouldNpcDealBonusDamage(target))
					{
						damageDealt *= 2.5;
					}	
					if(npc.m_bLostHalfHealth)
					{
						damageDealt *= 2.0;
						if(target > MaxClients)
						{
							StartBleedingTimer_Against_Client(target, npc.index, 4.0, 30);
						}
						else
						{
							if (!IsInvuln(target))
							{
								StartBleedingTimer_Against_Client(target, npc.index, 4.0, 30);
								TF2_IgnitePlayer(target, target, 5.0);
							}
						}
					}
					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);

					// Hit sound
					npc.PlayMeleeHitSound();
				} 
			}
			delete swingTrace;
		}
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
		{
			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				float fasterattack = 2.0;
				if(npc.m_bLostHalfHealth)
				{
					npc.AddGesture("ACT_CUSTOM_ATTACK_SAMURAI_ANGRY");
					fasterattack /= 2;
				}
				else
				{
					npc.AddGesture("ACT_CUSTOM_ATTACK_SAMURAI_CALM");
				}
				
						
				npc.m_flAttackHappens = gameTime + 0.25;
				npc.m_flDoingAnimation = gameTime + 0.25;
				npc.m_flNextMeleeAttack = gameTime + fasterattack;
			}
		}
	}
}

void FallenWarrior_ApplyDebuffInLocation(float BannerPos[3], int Team)
{
	float targPos[3];
	for(int ally=1; ally<=MaxClients; ally++)
	{
		if(IsClientInGame(ally) && IsPlayerAlive(ally) && GetTeam(ally) != Team)
		{
			GetClientAbsOrigin(ally, targPos);
			if (GetVectorDistance(BannerPos, targPos, true) <= (GULN_DEBUFF_RANGE * GULN_DEBUFF_RANGE))
			{
				ApplyStatusEffect(ally, ally, "Heavy Presence", 1.0);
			}
		}
	}
	for(int entitycount_again; entitycount_again<i_MaxcountNpcTotal; entitycount_again++)
	{
		int ally = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount_again]);
		if (IsValidEntity(ally) && !b_NpcHasDied[ally] && GetTeam(ally) != Team)
		{
			GetEntPropVector(ally, Prop_Data, "m_vecAbsOrigin", targPos);
			if (GetVectorDistance(BannerPos, targPos, true) <= (GULN_DEBUFF_RANGE * GULN_DEBUFF_RANGE))
			{
				ApplyStatusEffect(ally, ally, "Heavy Presence", 1.0);
			}
		}
	}
}