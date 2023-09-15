#pragma semicolon 1
#pragma newdecls required

static char g_DeathSounds[][] =
{
	"vo/sniper_paincrticialdeath01.mp3",
	"vo/sniper_paincrticialdeath02.mp3",
	"vo/sniper_paincrticialdeath03.mp3"
};

static char g_HurtSounds[][] =
{
	"vo/sniper_painsharp01.mp3",
	"vo/sniper_painsharp02.mp3",
	"vo/sniper_painsharp03.mp3",
	"vo/sniper_painsharp04.mp3"
};

static char g_MeleeHitSounds[][] =
{
	"weapons/cbar_hitbod1.wav",
	"weapons/cbar_hitbod2.wav",
	"weapons/cbar_hitbod3.wav"
};

static char g_MeleeAttackSounds[][] =
{
	"weapons/machete_swing.wav"
};

static char g_RangedAttackSounds[][] =
{
	"weapons/bow_shoot.wav"
};

static char g_RangedSpecialAttackSounds[][] =
{
	"mvm/sentrybuster/mvm_sentrybuster_spin.wav"
};

static char g_BoomSounds[][] =
{
	"mvm/mvm_tank_explode.wav"
};

static char g_BuffSounds[][] =
{
	"player/invuln_off_vaccinator.wav"
};

static char g_AngerSounds[][] =
{
	"vo/taunts/sniper_taunts05.mp3",
	"vo/taunts/sniper_taunts06.mp3",
	"vo/taunts/sniper_taunts08.mp3",
	"vo/taunts/sniper_taunts11.mp3",
	"vo/taunts/sniper_taunts12.mp3",
	"vo/taunts/sniper_taunts14.mp3"
};

static char g_HappySounds[][] =
{
	"vo/taunts/sniper/sniper_taunt_admire_02.mp3",
	"vo/compmode/cm_sniper_pregamefirst_6s_05.mp3",
	"vo/compmode/cm_sniper_matchwon_02.mp3",
	"vo/compmode/cm_sniper_matchwon_07.mp3",
	"vo/compmode/cm_sniper_matchwon_10.mp3",
	"vo/compmode/cm_sniper_matchwon_11.mp3",
	"vo/compmode/cm_sniper_matchwon_14.mp3"
};

static bool b_angered_twice[MAXENTITIES];
static int i_LaserEntityIndex[MAXENTITIES]={-1, ...};
static int i_RaidDuoAllyIndex = INVALID_ENT_REFERENCE;
static float f_HurtRecentlyAndRedirected[MAXENTITIES]={-1.0, ...};

void SeaBlueGoggles_OnMapStart()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_RangedAttackSounds);
	PrecacheSoundArray(g_RangedSpecialAttackSounds);
	PrecacheSoundArray(g_BoomSounds);
	PrecacheSoundArray(g_BuffSounds);
	PrecacheSoundArray(g_AngerSounds);
	PrecacheSoundArray(g_HappySounds);
}

methodmap SeaBlueGoggles < CClotBody
{
	public void PlayHurtSound()
	{
		int sound = GetRandomInt(0, sizeof(g_HurtSounds) - 1);

		EmitSoundToAll(g_HurtSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextHurtSound = GetGameTime(this.index) + GetRandomFloat(0.6, 1.6);
	}
	public void PlayDeathSound()
	{
		int sound = GetRandomInt(0, sizeof(g_DeathSounds) - 1);
		
		EmitSoundToAll(g_DeathSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRangedSound()
	{
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRangedSpecialSound()
	{
		EmitSoundToAll(g_RangedSpecialAttackSounds[GetRandomInt(0, sizeof(g_RangedSpecialAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayBoomSound()
	{
		EmitSoundToAll(g_BoomSounds[GetRandomInt(0, sizeof(g_BoomSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayAngerSound()
	{
		int sound = GetRandomInt(0, sizeof(g_AngerSounds) - 1);
		EmitSoundToAll(g_AngerSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRevengeSound()
	{
		char buffer[64];
		FormatEx(buffer, sizeof(buffer), "vo/sniper_revenge%02d.mp3", (GetURandomInt() % 25) + 1);
		EmitSoundToAll(buffer);
	}
	public void PlayHappySound()
	{
		EmitSoundToAll(g_HappySounds[GetRandomInt(0, sizeof(g_HappySounds) - 1)]);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayBuffSound()
	{
		EmitSoundToAll(g_BuffSounds[GetRandomInt(0, sizeof(g_BuffSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}

	property int m_iGunType	// 0 = Melee, 1 = Huntsman
	{
		public get()		{	return this.m_iOverlordComboAttack;	}
		public set(int value) 	{	this.m_iOverlordComboAttack = value;	}
	}
	property float m_flSwitchCooldown	// Delay between switching weapons
	{
		public get()			{	return this.m_flGrappleCooldown;	}
		public set(float value) 	{	this.m_flGrappleCooldown = value;	}
	}
	property float m_flBuffCooldown	// Stage 2: Delay between buffing Silvester
	{
		public get()			{	return this.m_flCharge_delay;	}
		public set(float value) 	{	this.m_flCharge_delay = value;	}
	}

	public SeaBlueGoggles(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		SeaBlueGoggles npc = view_as<SeaBlueGoggles>(CClotBody(vecPos, vecAng, "models/player/sniper.mdl", "1.35", "25000", ally, false, true, true,true)); //giant!
		
		i_NpcInternalId[npc.index] = SEA_RAIDBOSS_GOGGLES;
		i_NpcWeight[npc.index] = 4;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);

		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);
		
		SDKHook(npc.index, SDKHook_Think, SeaBlueGoggles_ClotThink);
		b_angered_twice[npc.index] = false;
		

		/*
			Cosmetics
		*/

		float flPos[3]; // original
		float flAng[3]; // original
		npc.GetAttachment("head", flPos, flAng);
		npc.m_iWearable6 = ParticleEffectAt_Parent(flPos, "unusual_symbols_parent_ice", npc.index, "head", {0.0,0.0,0.0});
		
		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
			
		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		SetVariantColor(view_as<int>({255, 255, 255, 200}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/all_class/spr18_antarctic_eyewear/spr18_antarctic_eyewear_scout.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_croc_knife/c_croc_knife.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/sniper/sum19_wagga_wagga_wear/sum19_wagga_wagga_wear.mdl");
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/sniper/short2014_sniper_cargo_pants/short2014_sniper_cargo_pants.mdl");

		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);
	//	SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
	//	SetEntityRenderColor(npc.m_iWearable4, 65, 65, 255, 255);
		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable2, 65, 65, 255, 255);

		SetVariantInt(3);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		/*
			Variables
		*/

		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPSOUND_NORMAL;
		npc.m_bThisNpcIsABoss = true;
		npc.Anger = false;
		npc.m_flSpeed = 290.0;
		npc.m_iTarget = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		b_thisNpcIsARaid[npc.index] = true;

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		npc.m_iGunType = 0;
		npc.m_flSwitchCooldown = GetGameTime(npc.index) + 10.0;
		npc.m_flBuffCooldown = GetGameTime(npc.index) + GetRandomFloat(10.0, 12.5);
		npc.m_flMeleeArmor = 1.25;

		npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + GetRandomFloat(45.0, 60.0);
		npc.m_flNextRangedSpecialAttackHappens = 0.0;

		f_HurtRecentlyAndRedirected[npc.index] = 0.0;
		
		Citizen_MiniBossSpawn();
		Building_RaidSpawned(npc.index);
		npc.StartPathing();

		//Spawn in the duo raid inside him, i didnt code for duo raids, so if one dies, it will give the timer to the other and vise versa.
		return npc;
	}
}

public void SeaBlueGoggles_ClotThink(int iNPC)
{
	SeaBlueGoggles npc = view_as<SeaBlueGoggles>(iNPC);
	
	float gameTime = GetGameTime(npc.index);

	//Raidmode timer runs out, they lost.
	if(npc.m_flNextThinkTime != FAR_FUTURE && RaidModeTime < GetGameTime())
	{
		if(IsEntityAlive(EntRefToEntIndex(i_RaidDuoAllyIndex)))
		{
			npc.PlayHappySound();
		}
		else
		{
			npc.PlayRevengeSound();
		}

		if(RaidBossActive != INVALID_ENT_REFERENCE)
		{
			int entity = CreateEntityByName("game_round_win"); 
			DispatchKeyValue(entity, "force_map_reset", "1");
			SetEntProp(entity, Prop_Data, "m_iTeamNum", TFTeam_Blue);
			DispatchSpawn(entity);
			AcceptEntityInput(entity, "RoundWin");
			Music_RoundEnd(entity);
			RaidBossActive = INVALID_ENT_REFERENCE;
		}

		//SDKUnhook(npc.index, SDKHook_Think, SeaBlueGoggles_ClotThink);

		if(IsValidEntity(npc.m_iWearable3))
			RemoveEntity(npc.m_iWearable3);
		
		// Play funny animation intro
		NPC_StopPathing(npc.index);
		npc.m_flNextThinkTime = FAR_FUTURE;
		npc.AddGesture("ACT_MP_CYOA_PDA_INTRO");

		// Give time to blend our current anim and intro then swap to this idle
		npc.m_flNextDelayTime = gameTime + 0.4;
	}

	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	if(npc.m_flNextThinkTime == FAR_FUTURE)
		npc.SetActivity("ACT_MP_CYOA_PDA_IDLE");

	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	

	//Think throttling
	if(npc.m_flNextThinkTime > gameTime)
		return;

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.05;

	//Set raid to this one incase the previous one has died or somehow vanished
	if(IsEntityAlive(EntRefToEntIndex(RaidBossActive)) && RaidBossActive != EntIndexToEntRef(npc.index))
	{
		for(int EnemyLoop; EnemyLoop <= MaxClients; EnemyLoop ++)
		{
			if(IsValidClient(EnemyLoop)) //Add to hud as a duo raid.
			{
				Calculate_And_Display_hp(EnemyLoop, npc.index, 0.0, false);	
			}	
		}
	}
	else if(EntRefToEntIndex(RaidBossActive) != npc.index && !IsEntityAlive(EntRefToEntIndex(RaidBossActive)))
	{
		RaidBossActive = EntIndexToEntRef(npc.index);
	}

	if(npc.m_flGetClosestTargetTime < gameTime || !IsEntityAlive(npc.m_iTarget))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}

	int ally = EntRefToEntIndex(i_RaidDuoAllyIndex);
	bool alone = !IsEntityAlive(ally);

	if(alone && !npc.Anger)
	{
		CPrintToChatAll("{darkblue}Blue Goggles{default}: No...");
		npc.Anger = true;
		npc.PlayAngerSound();
	}

	if(npc.Anger)
	{
		npc.m_flRangedArmor = 0.05;
		npc.m_flMeleeArmor = 0.0625;

		int health = GetEntProp(npc.index, Prop_Data, "m_iHealth") - 99;
		if(health > 0)
			SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
	}
	else
	{
		npc.m_flRangedArmor = 1.0;
		npc.m_flMeleeArmor = 1.25;
	}

	if(npc.m_iTarget > 0)
	{
		float vecMe[3]; vecMe = WorldSpaceCenter(npc.index);
		float vecAlly[3];
		float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);
		float distance = GetVectorDistance(vecTarget, vecMe, true);
		if(distance < npc.GetLeadRadius()) 
		{
			vecTarget = PredictSubjectPosition(npc, npc.m_iTarget);
			NPC_SetGoalVector(npc.index, vecTarget);
		}
		else
		{
			NPC_SetGoalEntity(npc.index, npc.m_iTarget);
		}

		if(npc.m_flSwitchCooldown < gameTime)
		{
			if(distance > 100000)	// 300 HU
			{
				if(npc.m_iGunType == 1)
				{
					npc.m_flSwitchCooldown = gameTime + 0.75;
				}
				else
				{
					npc.m_flSwitchCooldown = gameTime + 5.0;
					npc.m_flNextMeleeAttack = gameTime + 1.25;
					npc.m_iGunType = 1;

					if(IsValidEntity(npc.m_iWearable3))
						RemoveEntity(npc.m_iWearable3);
					
					npc.m_iWearable3 = npc.EquipItem("head", "models/weapons/c_models/c_bow/c_bow_thief.mdl");
					SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
				}
			}
			else if(npc.m_iGunType == 0)
			{
				npc.m_flSwitchCooldown = gameTime + 0.75;
			}
			else
			{
				npc.m_flSwitchCooldown = gameTime + 5.0;
				npc.m_flNextMeleeAttack = gameTime + 1.25;
				npc.m_iGunType = 0;

				if(IsValidEntity(npc.m_iWearable3))
					RemoveEntity(npc.m_iWearable3);
				
				npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_croc_knife/c_croc_knife.mdl");
				SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
			}
		}

		if(!alone && tier > 0 && npc.m_flBuffCooldown < gameTime && !NpcStats_IsEnemySilenced(npc.index))
		{
			vecAlly = WorldSpaceCenter(ally);
			if(GetVectorDistance(vecAlly, vecMe, true) < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 5.0) && Can_I_See_Enemy_Only(npc.index, ally))
			{
				// Buff Silver
				npc.m_flBuffCooldown = gameTime + GetRandomFloat(14.0, 19.0);

				spawnBeam(0.8, 50, 50, 255, 50, "materials/sprites/laserbeam.vmt", 4.0, 6.2, _, 2.0, vecAlly, vecMe);	
				spawnBeam(0.8, 50, 50, 255, 50, "materials/sprites/lgtning.vmt", 4.0, 5.2, _, 2.0, vecAlly, vecMe);	
				spawnBeam(0.8, 50, 50, 255, 50, "materials/sprites/lgtning.vmt", 3.0, 4.2, _, 2.0, vecAlly, vecMe);

				GetEntPropVector(ally, Prop_Data, "m_vecAbsOrigin", vecAlly);
				
				spawnRing_Vectors(vecAlly, 0.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 50, 255, 50, 255, 2, 1.0, 5.0, 12.0, 1, 150.0);
				spawnRing_Vectors(vecAlly, 0.0, 0.0, 0.0, 20.0, "materials/sprites/laserbeam.vmt", 50, 255, 50, 255, 2, 1.0, 5.0, 12.0, 1, 150.0);
				spawnRing_Vectors(vecAlly, 0.0, 0.0, 0.0, 40.0, "materials/sprites/laserbeam.vmt", 50, 255, 50, 255, 2, 1.0, 5.0, 12.0, 1, 150.0);
				spawnRing_Vectors(vecAlly, 0.0, 0.0, 0.0, 60.0, "materials/sprites/laserbeam.vmt", 50, 255, 50, 255, 2, 1.0, 5.0, 12.0, 1, 150.0);
				spawnRing_Vectors(vecAlly, 0.0, 0.0, 0.0, 80.0, "materials/sprites/laserbeam.vmt", 50, 255, 50, 255, 2, 1.0, 5.0, 12.0, 1, 150.0);

				NPCStats_RemoveAllDebuffs(ally);
				f_NpcImmuneToBleed[ally] = GetGameTime(ally) + 5.0;
				f_HussarBuff[ally] = GetGameTime(ally) + 10.0;

				npc.PlayBuffSound();
			}
			else
			{
				npc.m_flBuffCooldown = gameTime + 2.0;
			}
		}
		
		if(npc.m_flNextRangedSpecialAttackHappens < gameTime)
		{
			switch(npc.m_iGunType)
			{
				case 0:	// Melee
				{
					if(npc.m_flAttackHappens)
					{
						if(npc.m_flAttackHappens < gameTime)
						{
							npc.m_flAttackHappens = 0.0;
							
							Handle swingTrace;
							npc.FaceTowards(vecTarget, 15000.0);
							if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 1)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
							{	
								int target = TR_GetEntityIndex(swingTrace);
								if(target == npc.m_iTarget) 
								{
									KillFeed_SetKillIcon(npc.index, "club");

									float vecHit[3];
									TR_GetEndPosition(vecHit, swingTrace);
									if(npc.Anger)
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, 30.0 * RaidModeScaling, DMG_CLUB, -1, _, vecHit);
									}
									else
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, 20.0 * RaidModeScaling, DMG_CLUB, -1, _, vecHit);	
									}
									
									npc.PlayMeleeHitSound();
									
									bool Knocked = false;
									
									if(IsValidClient(target))
									{
										if (IsInvuln(target))
										{
											Knocked = true;
											Custom_Knockback(npc.index, target, 750.0, true);
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
										Custom_Knockback(npc.index, target, 550.0); 

									npc.m_flSwitchCooldown = 0.0;
								} 
							}
							delete swingTrace;
						}
					}
					else if(npc.m_flNextMeleeAttack < gameTime && distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED)
					{
						if(Can_I_See_Enemy(npc.index, npc.m_iTarget) == npc.m_iTarget)
						{
							if(npc.m_flNextRangedSpecialAttack < gameTime)
							{
								// C4 Boom
								npc.PlayRangedSpecialSound();
								npc.AddGesture("ACT_MP_CYOA_PDA_INTRO");

								npc.m_flNextRangedSpecialAttack = gameTime + 45.0;
								npc.m_flSwitchCooldown = gameTime + 3.0;

								npc.m_flNextMeleeAttack = gameTime + 0.5;	// When to set new activity
								npc.m_flAttackHappens = gameTime + 1.95;	// When to go boom
								npc.m_iGunType = 3;

								if(IsValidEntity(npc.m_iWearable3))
									RemoveEntity(npc.m_iWearable3);
								
								//npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_croc_knife/c_croc_knife.mdl");
								//SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);

								spawnRing_Vectors(vecMe, 900.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 0, 0, 212, 255, 1, 1.95, 5.0, 0.0, 1);
								spawnRing_Vectors(vecMe, 0.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 0, 0, 212, 255, 1, 1.95, 5.0, 0.0, 1, 900.0);
							}
							else
							{
								// Melee attack
								npc.PlayMeleeSound();
								npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");

								npc.m_flAttackHappens = gameTime + 0.25;
								npc.m_flSwitchCooldown = gameTime + 1.0;
								npc.m_flNextMeleeAttack = gameTime + 1.0;
							}
						}
					}
				}
				case 1:	// Huntsman
				{
					if(npc.m_flNextMeleeAttack < gameTime)
					{
						if(Can_I_See_Enemy(npc.index, npc.m_iTarget) == npc.m_iTarget)
						{
							KillFeed_SetKillIcon(npc.index, "huntsman");
							
							npc.m_flAttackHappens = gameTime + 0.001;
							npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM2");

							if(distance < 1000000.0 && !NpcStats_IsEnemySilenced(npc.index))	// 1000 HU
								vecTarget = PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, 1500.0);
							
							npc.FaceTowards(vecTarget, 30000.0);
							
							npc.PlayRangedSound();
							npc.FireArrow(vecTarget, (npc.Anger ? 30.0 : 60.0) * RaidModeScaling, 1500.0);
							
							npc.m_flNextMeleeAttack = gameTime + (npc.Anger ? 0.5 : 1.5);
						}
						/*else
						{
							npc.m_flNextMeleeAttack = gameTime + 1.0;
						}*/
					}
					else if(!alone)
					{
						npc.FaceTowards(vecTarget, 2000.0);
					}
				}
				case 3:	// C4
				{
					if(npc.m_flNextMeleeAttack && npc.m_flNextMeleeAttack < gameTime)
					{
						npc.SetActivity("ACT_MP_CYOA_PDA_IDLE");
						npc.m_flNextMeleeAttack = 0.0;
					}
					else if(npc.m_flAttackHappens && npc.m_flAttackHappens < gameTime)
					{
						KillFeed_SetKillIcon(npc.index, "pumpkindeath");
						
						vecMe[2] += 45;
						
						b_ThisNpcIsSawrunner[npc.index] = true;
						i_ExplosiveProjectileHexArray[npc.index] = EP_DEALS_DROWN_DAMAGE;
						Explode_Logic_Custom(3000.0 * zr_smallmapbalancemulti.FloatValue, 0, npc.index, -1, vecMe, 450.0 * zr_smallmapbalancemulti.FloatValue, 1.0, _, true, 20);
						b_ThisNpcIsSawrunner[npc.index] = false;
						
						npc.PlayBoomSound();
						TE_Particle("asplode_hoodoo", vecMe, NULL_VECTOR, NULL_VECTOR, npc.index, _, _, _, _, _, _, _, _, _, 0.0);

						npc.m_flAttackHappens = 0.0;
						npc.m_flSwitchCooldown = 0.0;
						npc.m_flNextRangedSpecialAttackHappens = gameTime + 1.9;

						npc.AddGesture("ACT_MP_CYOA_PDA_OUTRO");
					}
				}
			}
		}

		switch(npc.m_iGunType)
		{
			case 0:	// Melee
			{
				npc.SetActivity("ACT_MP_RUN_MELEE");
				if(npc.m_flNextRangedSpecialAttackHappens < gameTime)
					npc.StartPathing();
			}
			case 1:	// Sniper Rifle
			{
				if(npc.m_flNextMeleeAttack < gameTime)
				{
					npc.SetActivity("ACT_MP_DEPLOYED_ITEM2");
					if(npc.m_flNextRangedSpecialAttackHappens < gameTime)
						npc.StartPathing();
				}
				else
				{
					npc.SetActivity("ACT_MP_RUN_ITEM2");
					if(npc.m_flNextRangedSpecialAttackHappens < gameTime)
						npc.StartPathing();
				}
			}
			case 3:	// C4
			{
				npc.StopPathing();
			}
		}
	}
	else
	{
		npc.StopPathing();
		npc.SetActivity("ACT_MP_COMPETITIVE_LOSERSTATE");
	}
}
	
public Action SeaBlueGoggles_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker < 1)
		return Plugin_Continue;
		
	SeaBlueGoggles npc = view_as<SeaBlueGoggles>(victim);

	if(npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}

	//redirect damage and reduce it if in range.
	int AllyEntity = EntRefToEntIndex(i_RaidDuoAllyIndex);
	if(IsEntityAlive(AllyEntity) && !b_NpcIsInvulnerable[AllyEntity] && !IsPartnerGivingUpGoggles(AllyEntity))
	{
		static float victimPos[3];
		static float partnerPos[3];
		GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", partnerPos);
		GetEntPropVector(AllyEntity, Prop_Data, "m_vecAbsOrigin", victimPos); 
		float Distance = GetVectorDistance(victimPos, partnerPos, true);
		if(Distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.0 * zr_smallmapbalancemulti.FloatValue) && Can_I_See_Enemy_Only(npc.index, AllyEntity))
		{	
			damage *= 0.65;
			SDKHooks_TakeDamage(AllyEntity, attacker, inflictor, damage * 0.75, damagetype, weapon, damageForce, damagePosition, false, ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED);
			damage *= 0.25;
			f_HurtRecentlyAndRedirected[npc.index] = GetGameTime() + 0.15;
		}
	}

	return Plugin_Changed;
}

public void SeaBlueGoggles_NPCDeath(int entity)
{
	SeaBlueGoggles npc = view_as<SeaBlueGoggles>(entity);
	if(!npc.m_bDissapearOnDeath)
	{
		npc.PlayDeathSound();
	}
	SDKUnhook(npc.index, SDKHook_Think, SeaBlueGoggles_ClotThink);
	
	
	RaidModeTime += 2.0; //cant afford to delete it, since duo.
	//add 2 seconds so if its close, they dont lose to timer.

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
	for(int EnemyLoop; EnemyLoop < MAXENTITIES; EnemyLoop ++)
	{
		if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
		{
			RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
		}	
		if(IsValidClient(EnemyLoop)) //Add to hud as a duo raid.
		{
			RemoveHudCooldown(EnemyLoop);
			Calculate_And_Display_hp(EnemyLoop, npc.index, 0.0, false);	
		}						
	}
	Citizen_MiniBossDeath(entity);
}

bool SeaBlueGoggles_TookDamageRecently(int entity)
{
	if(f_HurtRecentlyAndRedirected[entity] > GetGameTime())
	{
		return true;
	}
	return false;
}

void SeaBlueGoggles_SetRaidPartner(int partner)
{
	i_RaidDuoAllyIndex = EntIndexToEntRef(partner);
}

static void spawnBeam(float beamTiming, int r, int g, int b, int a, char sprite[PLATFORM_MAX_PATH], float width=2.0, float endwidth=2.0, int fadelength=1, float amp=15.0, float startLoc[3] = {0.0, 0.0, 0.0}, float endLoc[3] = {0.0, 0.0, 0.0})
{
	int color[4];
	color[0] = r;
	color[1] = g;
	color[2] = b;
	color[3] = a;
		
	int SPRITE_INT = PrecacheModel(sprite, false);

	TE_SetupBeamPoints(startLoc, endLoc, SPRITE_INT, 0, 0, 0, beamTiming, width, endwidth, fadelength, amp, color, 0);
	
	TE_SendToAll();
}