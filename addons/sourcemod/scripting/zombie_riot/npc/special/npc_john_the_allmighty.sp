#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/medic_paincrticialdeath01.mp3",
	"vo/medic_paincrticialdeath02.mp3",
	"vo/medic_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	")vo/medic_painsharp01.mp3",
	")vo/medic_painsharp02.mp3",
	")vo/medic_painsharp03.mp3",
	")vo/medic_painsharp04.mp3",
	")vo/medic_painsharp05.mp3",
	")vo/medic_painsharp06.mp3",
	")vo/medic_painsharp07.mp3",
	")vo/medic_painsharp08.mp3",
};


static const char g_IdleAlertedSounds[][] = {
	")vo/medic_battlecry01.mp3",
	")vo/medic_battlecry02.mp3",
	")vo/medic_battlecry03.mp3",
	")vo/medic_battlecry04.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"misc/halloween/strongman_fast_swing_01.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/halloween_boss/knight_axe_hit.wav",
};

static const char g_RangedAttackSounds[][] = {
	"weapons/capper_shoot.wav",
};

static const char g_RangedAttackPrepareSounds[][] = {
	"npc/attack_helicopter/aheli_charge_up.wav",
};

void JohnTheAllmighty_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds)); i++) { PrecacheSound(g_RangedAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_RangedAttackPrepareSounds)); i++) { PrecacheSound(g_RangedAttackPrepareSounds[i]); }
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "John The Almighty");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_john_the_allmighty");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Special;
	data.Func = ClotSummon;
	NPC_Add(data);
	PrecacheSoundCustom("#zombiesurvival/john_the_allmighty.mp3");
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return JohnTheAllmighty(vecPos, vecAng, team);
}

methodmap JohnTheAllmighty < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	
	public void PlayRangedSound()
	{
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, GetRandomInt(80,125));
	}
	public void PlayRangedPrepareSound()
	{
		EmitSoundToAll(g_RangedAttackPrepareSounds[GetRandomInt(0, sizeof(g_RangedAttackPrepareSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 110);
		EmitSoundToAll(g_RangedAttackPrepareSounds[GetRandomInt(0, sizeof(g_RangedAttackPrepareSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 110);
	}
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);

	}
	
	property int m_iActualHealth
	{
		public get()							{ return i_MedkitAnnoyance[this.index]; }
		public set(int TempValueForProperty) 	{ i_MedkitAnnoyance[this.index] = TempValueForProperty; }
	}
	property float m_flVoidUnspeakableQuake
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	
	public JohnTheAllmighty(float vecPos[3], float vecAng[3], int ally)
	{
		JohnTheAllmighty npc = view_as<JohnTheAllmighty>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.5", "2000000000", ally, false, true, true));
		
		i_NpcWeight[npc.index] = 5;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(0);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		
		npc.m_iActualHealth = StringToInt(JohnTheAllmightyHealth());

		npc.m_flNextMeleeAttack = 0.0;
		for(int client1 = 1; client1 <= MaxClients; client1++)
		{
			if(!b_IsPlayerABot[client1] && IsClientInGame(client1) && !IsFakeClient(client1))
			{
				SetMusicTimer(client1, GetTime() + 1); //This is here beacuse of raid music.
				Music_Stop_All(client1);
			}
		}
		MusicEnum music;
		strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/john_the_allmighty.mp3");
		music.Time = 43;
		music.Volume = 1.8;
		music.Custom = true;
		strcopy(music.Name, sizeof(music.Name), "Chiromaw Matriarch - The Betweenlands: Eternal Melodies");
		strcopy(music.Artist, sizeof(music.Artist), "Rotch Gwylt");
		Music_SetRaidMusic(music);

		npc.m_flNextRangedAttack = GetGameTime() + 3.5;
		npc.m_iOverlordComboAttack = 0;
		if(!IsValidEntity(RaidBossActive))
		{
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidModeTime = GetGameTime(npc.index) + 43.0;
			RaidModeScaling = 0.0;
			RaidAllowsBuildings = true;
		}
		
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
			DispatchKeyValue(entity, "fogcolor", "15 15 15 240");
			DispatchKeyValue(entity, "fogcolor2", "15 15 15 240");
			DispatchKeyValueFloat(entity, "fogstart", 125.0);
			DispatchKeyValueFloat(entity, "fogend", 300.0);
			DispatchKeyValueFloat(entity, "fogmaxdensity", 0.992);

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

		switch(GetRandomInt(1, 4))
		{
			case 1:
			{
				CPrintToChatAll("{crimson}John The Almighty{default}: I need some money donations, care to give it?");
			}
			case 2:
			{
				CPrintToChatAll("{crimson}John The Almighty{crimson}: I will sell your organs.");
			}
			case 3:
			{
				CPrintToChatAll("{crimson}John The Almighty{default}: You will fund my efforts.");
			}
			case 4:
			{
				CPrintToChatAll("{crimson}John The Almighty{default}: You look easy to rob.");
			}
		}
		npc.m_iBleedType = 0;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_TANK;
		npc.m_bDissapearOnDeath = true;
		npc.m_iHealthBar = 10;

		func_NPCDeath[npc.index] = view_as<Function>(JohnTheAllmighty_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(JohnTheAllmighty_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(JohnTheAllmighty_ClotThink);
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, JohnTheAllmighty_OnTakeDamagePost);	
		
		float wave = float(ZR_GetWaveCount()+1);
		wave *= 0.1;
		npc.m_flWaveScale = wave;
		
		
		npc.StartPathing();
		npc.m_flSpeed = 320.0;
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
	

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_uberneedle/c_uberneedle.mdl");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/all_class/wikicap_medic.mdl");

		npc.m_iWearable3 = npc.EquipItem("head", "models/player/items/medic/medic_smokingpipe.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/medic/fall2013_aichi_investigator/fall2013_aichi_investigator.mdl");
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/medic/xms2013_ruffled_beard/xms2013_ruffled_beard.mdl");
		npc.m_iWearable6 = ParticleEffectAt_Parent({0.0,0.0,0.0}, "superrare_burning1", npc.index, "head");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		
		return npc;
	}
}

public void JohnTheAllmighty_ClotThink(int iNPC)
{
	JohnTheAllmighty npc = view_as<JohnTheAllmighty>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
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

	if(RaidModeTime < GetGameTime() && i_NpcWeight[npc.index] != 999)
	{
		CPrintToChatAll("{crimson}John The Almighty Ran out of patience and leaves the battle field.");
		SDKUnhook(npc.index, SDKHook_OnTakeDamagePost, JohnTheAllmighty_OnTakeDamagePost);	
		RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
		RaidMusicSpecial1.Clear();
		return;
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
		JohnTheAllmightySelfDefense(npc,GetGameTime(npc.index), flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action JohnTheAllmighty_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker <= 0)
		return Plugin_Continue;
	
	return Plugin_Changed;
}

public void JohnTheAllmighty_NPCDeath(int entity)
{
	JohnTheAllmighty npc = view_as<JohnTheAllmighty>(entity);

	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
		
	TE_Particle("pyro_blast", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
	TE_Particle("pyro_blast_lines", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
	TE_Particle("pyro_blast_warp", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
	TE_Particle("pyro_blast_flash", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamagePost, JohnTheAllmighty_OnTakeDamagePost);	

	if(EntIndexToEntRef(entity) == RaidBossActive)
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

	if(FogEntity != INVALID_ENT_REFERENCE)
	{
		int fogentity = EntRefToEntIndex(FogEntity);
		if(fogentity > MaxClients)
			RemoveEntity(fogentity);

		FogEntity = INVALID_ENT_REFERENCE;
	}
}

void JohnTheAllmightySelfDefense(JohnTheAllmighty npc, float gameTime, float distance)
{
	if(npc.m_flNextRangedAttack < gameTime)
	{
		npc.m_flNextRangedAttack = GetGameTime() + 7.5;
		npc.m_flNextRangedAttackHappening = gameTime + 1.0;
		npc.m_iOverlordComboAttack = 10;
		npc.PlayRangedPrepareSound();
		npc.m_iWearable7 = ParticleEffectAt_Parent({0.0,0.0,0.0}, "raygun_projectile_blue_crit", npc.index, "eyeglow_L");
		npc.m_iWearable8 = ParticleEffectAt_Parent({0.0,0.0,0.0}, "raygun_projectile_red_crit", npc.index, "eyeglow_R");
	}
	if(npc.m_iOverlordComboAttack > 0 && npc.m_flNextRangedAttackHappening < gameTime)
	{
		if(IsValidEnemy(npc.index, npc.m_iTarget))
		{
			if(Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
			{
				npc.m_flNextRangedAttackHappening = gameTime + 0.05;
				npc.m_iOverlordComboAttack--;

				npc.PlayRangedSound();
				float RocketSpeed = 1500.0;
				float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
				float eyePos[3];
				float eyeAng[3];
				GetAttachment(npc.index, "eyeglow_L", eyePos, eyeAng);
				npc.FireParticleRocket(vecTarget, 25.0 * npc.m_flWaveScale, RocketSpeed, 0.0, "raygun_projectile_blue_crit", false,_, true, eyePos);
				
				PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, RocketSpeed,_,vecTarget);
				GetAttachment(npc.index, "eyeglow_R", eyePos, eyeAng);
				npc.FireParticleRocket(vecTarget, 25.0 * npc.m_flWaveScale, RocketSpeed, 0.0, "raygun_projectile_red_crit", false,_, true,eyePos);
			}	
		}
	}
	if(npc.m_iOverlordComboAttack <= 0 && npc.m_iOverlordComboAttack != -5)
	{
		npc.m_iOverlordComboAttack = -5;
		if(IsValidEntity(npc.m_iWearable8))
			RemoveEntity(npc.m_iWearable8);
		if(IsValidEntity(npc.m_iWearable7))
			RemoveEntity(npc.m_iWearable7);
	}

	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
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

							float damage = 150.0;
							damage *= npc.m_flWaveScale;
							
							SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);							

							Custom_Knockback(npc.index, target, 900.0, true);

							if(IsValidClient(target))
							{
								TF2_AddCondition(target, TFCond_LostFooting, 0.5);
								TF2_AddCondition(target, TFCond_AirCurrent, 0.5);
							}
						}
					}
				}
				if(PlaySound)
				{
					npc.PlayMeleeHitSound();
				}
				delete swingTrace;
			}
			npc.m_flNextMeleeAttack = gameTime + 0.75;
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
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE", .SetGestureSpeed = 0.8);
						
				npc.m_flAttackHappens = gameTime + 0.25;
				npc.m_flDoingAnimation = gameTime + 0.25;
				npc.m_flNextMeleeAttack = gameTime + 0.75;
				if(i_NpcWeight[npc.index] == 999)
					npc.m_flNextMeleeAttack = gameTime + 0.35;
			}
		}
	}
}

static char[] JohnTheAllmightyHealth()
{
	int health = 220;
	
	health = RoundToNearest(float(health) * ZRStocks_PlayerScalingDynamic()); //yep its high! will need tos cale with waves expoentially.
	
	float temp_float_hp = float(health);
	
	if(ZR_GetWaveCount()+1 < 30)
	{
		health = RoundToCeil(Pow(((temp_float_hp + float(ZR_GetWaveCount()+1)) * float(ZR_GetWaveCount()+1)),1.20));
	}
	else if(ZR_GetWaveCount()+1 < 45)
	{
		health = RoundToCeil(Pow(((temp_float_hp + float(ZR_GetWaveCount()+1)) * float(ZR_GetWaveCount()+1)),1.25));
	}
	else
	{
		health = RoundToCeil(Pow(((temp_float_hp + float(ZR_GetWaveCount()+1)) * float(ZR_GetWaveCount()+1)),1.35)); //Yes its way higher but i reduced overall hp of him
	}
	
	health /= 2;
	
	char buffer[16];
	IntToString(health, buffer, sizeof(buffer));
	return buffer;
}


public void JohnTheAllmighty_OnTakeDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype) 
{
	JohnTheAllmighty npc = view_as<JohnTheAllmighty>(victim);
	npc.m_iActualHealth -= RoundToNearest(damage);
	if(npc.m_iActualHealth <= 0)
	{
		SDKUnhook(npc.index, SDKHook_OnTakeDamagePost, JohnTheAllmighty_OnTakeDamagePost);	
		CPrintToChatAll("{crimson}John The Almighty {default}: OH NUTS! I left my oven on! Bye!");
		npc.m_iActualHealth = 9999999;
		for(int client = 1; client <= MaxClients; client++)
		{
			if(!b_IsPlayerABot[client] && IsClientInGame(client) && !IsFakeClient(client))
			{
				SetMusicTimer(client, GetTime() + 1); //This is here beacuse of raid music.
				Music_Stop_All(client);
			}
		}
		RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
		SpawnMoney(npc.index);
		RaidMusicSpecial1.Clear();
	}
}