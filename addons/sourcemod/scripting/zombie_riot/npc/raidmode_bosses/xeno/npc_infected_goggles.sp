#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"weapons/rescue_ranger_teleport_receive_01.wav",
	"weapons/rescue_ranger_teleport_receive_02.wav",
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
	"weapons/sniper_railgun_single_01.wav",
	"weapons/sniper_railgun_single_02.wav"
};

static char g_RangedSpecialAttackSounds[][] =
{
	"mvm/sentrybuster/mvm_sentrybuster_spin.wav"
};

static char g_BoomSounds[][] =
{
	"mvm/mvm_tank_explode.wav"
};

static char g_SMGAttackSounds[][] =
{
	"weapons/doom_sniper_smg.wav"
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


static int i_LaserEntityIndex[MAXENTITIES]={-1, ...};
static int i_RaidDuoAllyIndex = INVALID_ENT_REFERENCE;
static float f_HurtRecentlyAndRedirected[MAXENTITIES]={-1.0, ...};
static float f_GogglesHurtTeleport[MAXENTITIES];
static int i_GogglesHurtTalkMessage[MAXENTITIES];

void RaidbossBlueGoggles_OnMapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Waldch");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_infected_goggles");
	strcopy(data.Icon, sizeof(data.Icon), "goggles");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Raid;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_RangedAttackSounds);
	PrecacheSoundArray(g_RangedSpecialAttackSounds);
	PrecacheSoundArray(g_BoomSounds);
	PrecacheSoundArray(g_SMGAttackSounds);
	PrecacheSoundArray(g_BuffSounds);
	PrecacheSoundArray(g_AngerSounds);
	PrecacheSoundArray(g_HappySounds);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return RaidbossBlueGoggles(vecPos, vecAng, team);
}
methodmap RaidbossBlueGoggles < CClotBody
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
	public void PlaySMGSound()
	{
		EmitSoundToAll(g_SMGAttackSounds[GetRandomInt(0, sizeof(g_SMGAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
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
		EmitSoundToAll(g_AngerSounds[sound]);
		EmitSoundToAll(g_AngerSounds[sound]);
	}
	public void PlayRevengeSound()
	{
		char buffer[64];
		FormatEx(buffer, sizeof(buffer), "vo/sniper_revenge%02d.mp3", (GetURandomInt() % 25) + 1);
		EmitSoundToAll(buffer);
		EmitSoundToAll(buffer);
	}
	public void PlayHappySound()
	{
		int sound = GetRandomInt(0, sizeof(g_HappySounds) - 1);
		EmitSoundToAll(g_HappySounds[sound]);
		EmitSoundToAll(g_HappySounds[sound]);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayBuffSound()
	{
		EmitSoundToAll(g_BuffSounds[GetRandomInt(0, sizeof(g_BuffSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}

	property int m_iGunType	// 0 = Melee, 1 = Sniper, 2 = SMG
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
	property float m_flPiggyCooldown	// Stage 3: Delay between piggybacking Silvester
	{
		public get()			{	return this.m_flNextTeleport;	}
		public set(float value) 	{	this.m_flNextTeleport = value;	}
	}
	property float m_flPiggyFor	// Stage 3: Time until piggybacking ends
	{
		public get()			{	return this.m_flJumpCooldown;	}
		public set(float value) 	{	this.m_flJumpCooldown = value;	}
	}

	public RaidbossBlueGoggles(float vecPos[3], float vecAng[3], int ally)
	{
		RaidbossBlueGoggles npc = view_as<RaidbossBlueGoggles>(CClotBody(vecPos, vecAng, "models/player/sniper.mdl", "1.35", "25000", ally, false, true, true,true)); //giant!
		
		i_NpcWeight[npc.index] = 4;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);

		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);
		
		b_angered_twice[npc.index] = false;
		

		func_NPCDeath[npc.index] = RaidbossBlueGoggles_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = RaidbossBlueGoggles_OnTakeDamage;
		func_NPCThink[npc.index] = RaidbossBlueGoggles_ClotThink;
		/*
			Cosmetics
		*/

		float flPos[3]; // original
		float flAng[3]; // original
		npc.GetAttachment("head", flPos, flAng);
		npc.m_iWearable6 = ParticleEffectAt_Parent(flPos, "unusual_symbols_parent_ice", npc.index, "head", {0.0,0.0,0.0});
		
		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
		npc.m_bTeamGlowDefault = false;
			
		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		SetVariantColor(view_as<int>({255, 255, 255, 200}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
		npc.m_bDissapearOnDeath = true;

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/all_class/spr18_antarctic_eyewear/spr18_antarctic_eyewear_scout.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_croc_knife/c_croc_knife.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/sniper/sum19_wagga_wagga_wear/sum19_wagga_wagga_wear.mdl");
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/sniper/short2014_sniper_cargo_pants/short2014_sniper_cargo_pants.mdl");

		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);
		SetEntityRenderColor(npc.m_iWearable2, 65, 65, 255, 255);
		f_GogglesHurtTeleport[npc.index] = 0.0;
		i_GogglesHurtTalkMessage[npc.index] = 0;
		WaldchEarsApply(npc.index);

		SetVariantInt(3);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		/*
			Variables
		*/
		f_ExplodeDamageVulnerabilityNpc[npc.index] = 0.7;

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
		npc.m_flPiggyCooldown = GetGameTime(npc.index) + GetRandomFloat(30.0, 50.0); // FAR_FUTURE;
		npc.m_flPiggyFor = 0.0;
		npc.m_flMeleeArmor = 1.25;

		npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + GetRandomFloat(45.0, 60.0);
		npc.m_flNextRangedSpecialAttackHappens = 0.0;

		f_HurtRecentlyAndRedirected[npc.index] = 0.0;
		
		Citizen_MiniBossSpawn();
		npc.StartPathing();

		//Spawn in the duo raid inside him, i didnt code for duo raids, so if one dies, it will give the timer to the other and vise versa.
		return npc;
	}
}

public void RaidbossBlueGoggles_ClotThink(int iNPC)
{
	RaidbossBlueGoggles npc = view_as<RaidbossBlueGoggles>(iNPC);
	
	float gameTime = GetGameTime(npc.index);

	//Raidmode timer runs out, they lost.
	if(npc.m_flPiggyFor)
	{
		SDKCall_SetLocalOrigin(npc.index, {0.0,0.0,85.0}); //keep teleporting just incase.
	}
	if(LastMann && !AlreadySaidLastmann)
	{
		if(!npc.m_fbGunout)
		{
			AlreadySaidLastmann = true;
			npc.m_fbGunout = true;
			if(!XenoExtraLogic())
			{
				CPrintToChatAll("{darkblue}Waldch{default}: Here or not, infections are no joke.");
			}
			else
			{
				CPrintToChatAll("{darkblue}Waldch{default}: Giving up saves your life.");		
			}
		}
	}
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

		if(IsValidEntity(RaidBossActive))
		{
			ForcePlayerLoss();
			SharedTimeLossSilvesterDuo(npc.index);
			RaidBossActive = INVALID_ENT_REFERENCE;
		}
		

		if(IsValidEntity(npc.m_iWearable3))
			RemoveEntity(npc.m_iWearable3);
		
		// Play funny animation intro
		npc.StopPathing();
		npc.m_flNextThinkTime = FAR_FUTURE;
		npc.AddGesture("ACT_MP_CYOA_PDA_INTRO");

		// Give time to blend our current anim and intro then swap to this idle
		npc.m_flNextDelayTime = gameTime + 0.4;
	}
	int AllyEntity = EntRefToEntIndex(i_RaidDuoAllyIndex);
	bool alonecheck = !IsEntityAlive(AllyEntity);
	if(!alonecheck)
	{
		float MaxHealthCalc = float(ReturnEntityMaxHealth(npc.index));
		switch(i_GogglesHurtTalkMessage[npc.index])
		{
			case 0:
			{
				if(f_GogglesHurtTeleport[npc.index] > MaxHealthCalc * 0.20)
				{
					i_GogglesHurtTalkMessage[npc.index] = 1;
					//got hurt by 20% hp.
					switch(GetRandomInt(1,3))
					{
						case 1:
						{
							CPrintToChatAll("{gold}Silvester{default}: Stop seperating yourself from me {darkblue}Waldch{default}!!");
						}
						case 2:
						{
							CPrintToChatAll("{gold}Silvester{default}: {darkblue}Waldch{default} get back to me now!");
						}
						case 3:
						{
							CPrintToChatAll("{gold}Silvester{default}: {darkblue}Waldch{default} get here or ill teleport you here!");
						}
					}
				}
			}
			case 1:
			{
				if(f_GogglesHurtTeleport[npc.index] > MaxHealthCalc * 0.25)
				{
					i_GogglesHurtTalkMessage[npc.index] = 2;
					//got hurt by 20% hp.
					switch(GetRandomInt(1,3))
					{
						case 1:
						{
							CPrintToChatAll("{gold}Silvester{default}: God dammit {darkblue}Waldch{default}!");
						}
						case 2:
						{
							CPrintToChatAll("{gold}Silvester{default}: {darkblue}Waldch{default}... NOW!");
						}
						case 3:
						{
							CPrintToChatAll("{gold}Silvester{default}: {darkblue}Waldch{default} here, now STAY NEAR ME!");
						}
					}
					float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
					float WorldSpaceVec2[3]; WorldSpaceCenter(AllyEntity, WorldSpaceVec2);

					ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
					EmitSoundToAll("misc/halloween/spell_teleport.wav", npc.index, SNDCHAN_STATIC, 90, _, 0.8);
					float victimPos1[3];
					GetEntPropVector(AllyEntity, Prop_Data, "m_vecAbsOrigin", victimPos1); 
					ParticleEffectAt(WorldSpaceVec2, "teleported_blue", 0.5);
					TeleportEntity(npc.index, victimPos1, NULL_VECTOR, NULL_VECTOR);
					npc.m_iTarget = -1;
					i_GogglesHurtTalkMessage[npc.index] = 0;
					f_GogglesHurtTeleport[npc.index] = 0.0;
				}
			}
		}
	}

	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	if(npc.m_flNextThinkTime == FAR_FUTURE)
	{
		npc.m_bisWalking = false;
		npc.SetActivity("ACT_MP_CYOA_PDA_IDLE");
	}

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
	else if(EntRefToEntIndex(RaidBossActive) != npc.index && !IsEntityAlive(EntRefToEntIndex(RaidBossActive)) || IsPartnerGivingUpSilvester(EntRefToEntIndex(RaidBossActive)))
	{	
		RaidBossActive = EntIndexToEntRef(npc.index);
	}
	
	if(b_angered_twice[npc.index])
	{
		int closestTarget = GetClosestAllyPlayer(npc.index);
		if(IsValidEntity(closestTarget))
		{
			float WorldSpaceVec[3]; WorldSpaceCenter(closestTarget, WorldSpaceVec);
			npc.FaceTowards(WorldSpaceVec, 100.0);
		}
		if(IsValidEntity(npc.m_iWearable3))
			RemoveEntity(npc.m_iWearable3);
			
		if(npc.m_flPiggyFor)
		{
			SDKCall_SetLocalOrigin(npc.index, {0.0,0.0,85.0}); //keep teleporting just incase.
			// Disable Piggyback Stuff
			npc.m_flPiggyFor = 0.0;
			npc.m_flSpeed = 290.0;
			SDKCall_SetLocalOrigin(npc.index, {0.0,0.0,85.0});
			AcceptEntityInput(npc.index, "ClearParent");
			float flPos[3]; // original
				
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
			flPos[2] -= 70.0;
			SDKCall_SetLocalOrigin(npc.index, flPos);
			npc.SetVelocity({0.0,0.0,0.0});
			TeleportEntity(npc.index, flPos, NULL_VECTOR, _);
		}
		npc.m_bisWalking = false;
		npc.SetActivity("ACT_MP_STAND_LOSERSTATE");
		npc.StopPathing();
		int ally = EntRefToEntIndex(i_RaidDuoAllyIndex);
		if(SharedGiveupSilvester(ally,npc.index))
		{
			npc.m_bDissapearOnDeath = true;
			RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
		}
		return;
	}

	if(npc.m_flGetClosestTargetTime < gameTime || !IsValidEnemy(npc.index, npc.m_iTarget))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}

	int ally = EntRefToEntIndex(i_RaidDuoAllyIndex);
	bool alone = !IsEntityAlive(ally);

	if(IsPartnerGivingUpSilvester(ally))
	{
		alone = true;
	}

	if(alone && !npc.Anger)
	{
		if(XenoExtraLogic())
		{
			switch(GetURandomInt() % 3)
			{
				case 0:
				{
					CPrintToChatAll("{darkblue}Waldch{default}: Not here, not with him!");
				}
				case 1:
				{
					CPrintToChatAll("{darkblue}Waldch{default}: You fight like you want to kill him!");
				}
				case 2:
				{
					CPrintToChatAll("{darkblue}Waldch{default}: Just you and me!");
				}
			}
		}
		else
		{
			switch(RoundToFloor(GetURandomFloat() * 4.0))
			{
				case 0:
				{
					CPrintToChatAll("{darkblue}Waldch{default}: You really shouldn't have done that!");
				}
				case 1:
				{
					CPrintToChatAll("{darkblue}Waldch{default}: You'll pay for picking on him!");
				}
				case 2:
				{
					CPrintToChatAll("{darkblue}Waldch{default}: Quit this right now!");
				}
				case 3:
				{
					CPrintToChatAll("{darkblue}Waldch{default}: You little ****!");
				}
			}
		}

		npc.Anger = true;
		npc.PlayAngerSound();
	}
	if(npc.Anger)
	{
		npc.m_flRangedArmor = 0.25;
		npc.m_flMeleeArmor = 0.3;
	}
	else
	{
		b_NpcIsInvulnerable[npc.index] = false;
		switch(IsSilvesterTransforming(ally))
		{
			case 0:
			{
				npc.m_flRangedArmor = 0.25;
				npc.m_flMeleeArmor = 0.3;
			}
			case 1:
			{
				b_NpcIsInvulnerable[npc.index] = true;
			}
			case 2:
			{
				npc.m_flRangedArmor = 0.7;
				npc.m_flMeleeArmor = 0.75;
			}
			case 3:
			{
				npc.m_flRangedArmor = 1.0;
				npc.m_flMeleeArmor = 1.25;
			}
		}
	}

	if(npc.m_flPiggyFor)
	{
		SDKCall_SetLocalOrigin(npc.index, {0.0,0.0,85.0}); //keep teleporting just incase.
		if(npc.m_flPiggyFor < gameTime || alone || b_NpcIsInvulnerable[ally])
		{
			// Disable Piggyback Stuff
			npc.m_flPiggyFor = 0.0;
			npc.m_flSpeed = 290.0;
			SDKCall_SetLocalOrigin(npc.index, {0.0,0.0,85.0});
			AcceptEntityInput(npc.index, "ClearParent");
			RemoveSpecificBuff(npc.index, "Solid Stance");
			b_NoGravity[npc.index] = false;
			float flPos[3]; // original
			b_DoNotUnStuck[npc.index] = false;

			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
			flPos[2] -= 70.0;
			SDKCall_SetLocalOrigin(npc.index, flPos);
			npc.SetVelocity({0.0,0.0,0.0});
			TeleportEntity(npc.index, flPos, NULL_VECTOR, _);
		}
	}

	if(npc.m_iTarget > 0)
	{
		float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
		float vecAlly[3];
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float distance = GetVectorDistance(vecTarget, vecMe, true);
		if(distance < npc.GetLeadRadius()) 
		{
			PredictSubjectPosition(npc, npc.m_iTarget,_,_, vecTarget);
			npc.SetGoalVector(vecTarget);
		}
		else
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}

		int tier = (Waves_GetRoundScale() / 10);
		if(alone)
			tier++;

		if(npc.m_flSwitchCooldown < gameTime)
		{
			if(distance > 500000 || !(GetURandomInt() % ((tier * 2) + 6)))	// 700 HU
			{
				if(npc.m_iGunType == 1)
				{
					npc.m_flSwitchCooldown = gameTime + 1.0;
				}
				else
				{
					npc.m_flSwitchCooldown = gameTime + 8.0;
					npc.m_flNextMeleeAttack = gameTime + 2.0;
					npc.m_iGunType = 1;

					if(IsValidEntity(npc.m_iWearable3))
						RemoveEntity(npc.m_iWearable3);
					
					npc.m_iWearable3 = npc.EquipItem("head", "models/weapons/c_models/c_dex_sniperrifle/c_dex_sniperrifle.mdl");
					SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
				}
			}
			else if(distance > 100000 || !(GetURandomInt() % ((tier * 2) + 8)))	// 300 HU
			{
				if(npc.m_iGunType == 2)
				{
					npc.m_flSwitchCooldown = gameTime + 1.0;
				}
				else
				{
					npc.m_flSwitchCooldown = gameTime + 8.0;
					npc.m_flNextMeleeAttack = gameTime + 0.5;
					npc.m_iGunType = 2;

					if(IsValidEntity(npc.m_iWearable3))
						RemoveEntity(npc.m_iWearable3);
					
					npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_pro_smg/c_pro_smg.mdl");
					SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
				}
			}
			else if(npc.m_iGunType == 0)
			{
				npc.m_flSwitchCooldown = gameTime + 1.0;
			}
			else
			{
				npc.m_flSwitchCooldown = gameTime + 5.0;
				npc.m_flNextMeleeAttack = gameTime + 0.5;
				npc.m_iGunType = 0;

				if(IsValidEntity(npc.m_iWearable3))
					RemoveEntity(npc.m_iWearable3);
				
				npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_croc_knife/c_croc_knife.mdl");
				SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
			}
		}

		if(!alone && tier > 0 && npc.m_flBuffCooldown < gameTime && !NpcStats_IsEnemySilenced(npc.index))
		{
			WorldSpaceCenter(ally, vecAlly);
			if(GetVectorDistance(vecAlly, vecMe, true) < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 5.0) && Can_I_See_Enemy_Only(npc.index, ally))
			{
				// Buff Silver
				npc.m_flBuffCooldown = gameTime + GetRandomFloat(24.0 - (float(tier) * 4.0), 29.0 - (float(tier) * 4.0));

				spawnBeam(0.8, 50, 50, 255, 50, "materials/sprites/laserbeam.vmt", 4.0, 6.2, _, 2.0, vecAlly, vecMe);	
				spawnBeam(0.8, 50, 50, 255, 50, "materials/sprites/lgtning.vmt", 4.0, 5.2, _, 2.0, vecAlly, vecMe);	
				spawnBeam(0.8, 50, 50, 255, 50, "materials/sprites/lgtning.vmt", 3.0, 4.2, _, 2.0, vecAlly, vecMe);

				GetEntPropVector(ally, Prop_Data, "m_vecAbsOrigin", vecAlly);
				
				spawnRing_Vectors(vecAlly, 0.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 50, 255, 50, 255, 2, 1.0, 5.0, 12.0, 1, 150.0);
				spawnRing_Vectors(vecAlly, 0.0, 0.0, 0.0, 20.0, "materials/sprites/laserbeam.vmt", 50, 255, 50, 255, 2, 1.0, 5.0, 12.0, 1, 150.0);
				spawnRing_Vectors(vecAlly, 0.0, 0.0, 0.0, 40.0, "materials/sprites/laserbeam.vmt", 50, 255, 50, 255, 2, 1.0, 5.0, 12.0, 1, 150.0);
				spawnRing_Vectors(vecAlly, 0.0, 0.0, 0.0, 60.0, "materials/sprites/laserbeam.vmt", 50, 255, 50, 255, 2, 1.0, 5.0, 12.0, 1, 150.0);
				spawnRing_Vectors(vecAlly, 0.0, 0.0, 0.0, 80.0, "materials/sprites/laserbeam.vmt", 50, 255, 50, 255, 2, 1.0, 5.0, 12.0, 1, 150.0);

				NPCStats_RemoveAllDebuffs(ally, 5.0);
				ApplyStatusEffect(npc.index, ally, "Hussar's Warscream", 10.0);

				npc.PlayBuffSound();
			}
			else
			{
				npc.m_flBuffCooldown = gameTime + 2.0;
			}
		}
		else if(!alone && tier > 1 && (npc.m_iGunType == 1 || npc.m_iGunType == 2) && npc.m_flPiggyCooldown < gameTime)
		{
			WorldSpaceCenter(ally, vecAlly);
			if(GetVectorDistance(vecAlly, vecMe, true) < 20000.0)	// 140 HU
			{
				// Enable piggyback
				npc.m_flSpeed = 0.0;
				npc.m_flPiggyCooldown = tier > 2 ? (gameTime + 30.0) : FAR_FUTURE;
				npc.m_flPiggyFor = gameTime + 8.0;
				npc.m_flSwitchCooldown = gameTime + 10.0;
				RaidbossSilvester npcally = view_as<RaidbossSilvester>(ally);
				
				float flPos[3]; // original
				
				GetEntPropVector(npcally.index, Prop_Data, "m_vecAbsOrigin", flPos);

				flPos[2] += 85.0;
				SDKCall_SetLocalOrigin(npc.index, flPos);
				npc.SetVelocity({0.0,0.0,0.0});
				float eyePitch[3];
				GetEntPropVector(npcally.index, Prop_Data, "m_angRotation", eyePitch);
				SetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
				SDKCall_SetLocalOrigin(npc.index, {0.0,0.0,0.0});
				SetParent(npcally.index, npc.index, "");
				b_NoGravity[npc.index] = true;
				b_DoNotUnStuck[npc.index] = true;
				ApplyStatusEffect(npc.index, npc.index, "Solid Stance", 999999.0);		
				SDKCall_SetLocalOrigin(npc.index, {0.0,0.0,85.0});
				npc.SetVelocity({0.0,0.0,0.0});
				GetEntPropVector(npcally.index, Prop_Data, "m_angRotation", eyePitch);
				SetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
			}
			else
			{
				npc.m_flPiggyCooldown = gameTime + 1.0;
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
							int HowManyEnemeisAoeMelee = 64;
							Handle swingTrace;
							npc.FaceTowards(vecTarget, 20000.0);
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

										KillFeed_SetKillIcon(npc.index, "club");

										if(npc.Anger)
										{
											SDKHooks_TakeDamage(target, npc.index, npc.index, (14.5 + (float(tier) * 2.0)) * 1.65 * RaidModeScaling * 1.25, DMG_CLUB, -1, _, vecHit);
										}
										else
										{
											SDKHooks_TakeDamage(target, npc.index, npc.index, (14.5 + (float(tier) * 2.0)) * RaidModeScaling * 1.25, DMG_CLUB, -1, _, vecHit);	
										}
										
										
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
											Custom_Knockback(npc.index, target, 450.0, true);  

										npc.m_flSwitchCooldown = 0.0;
									}
								} 
							}
							if(PlaySound)
							{
								npc.PlayMeleeHitSound();
							}
						}
					}
					else if(npc.m_flNextMeleeAttack < gameTime && distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED)
					{
						if(Can_I_See_Enemy(npc.index, npc.m_iTarget) == npc.m_iTarget)
						{
							if(tier > 1 && npc.m_flNextRangedSpecialAttack < gameTime)
							{
								// C4 Boom
								npc.PlayRangedSpecialSound();
								npc.AddGesture("ACT_MP_CYOA_PDA_INTRO");

								npc.m_flNextRangedSpecialAttack = gameTime + 25.0;
								npc.m_flSwitchCooldown = gameTime + 3.0;

								npc.m_flNextMeleeAttack = gameTime + 0.5;	// When to set new activity
								npc.m_flAttackHappens = gameTime + 1.95;	// When to go boom
								npc.m_iGunType = 3;

								if(IsValidEntity(npc.m_iWearable3))
									RemoveEntity(npc.m_iWearable3);
								
								//npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_croc_knife/c_croc_knife.mdl");
								//SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);

								spawnRing_Vectors(vecMe, 450.0 * zr_smallmapbalancemulti.FloatValue * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 0, 0, 212, 255, 1, 1.95, 5.0, 0.0, 1);
								spawnRing_Vectors(vecMe, 0.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 0, 0, 212, 255, 1, 1.95, 5.0, 0.0, 1, 450.0 * zr_smallmapbalancemulti.FloatValue * 2.0);
							}
							else
							{
								// Melee attack
								npc.PlayMeleeSound();
								npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");

								npc.m_flAttackHappens = gameTime + 0.25;
								npc.m_flSwitchCooldown = gameTime + 1.0;
								npc.m_flNextMeleeAttack = gameTime + 1.0;
								if(i_RaidGrantExtra[npc.index] >= 5)
								{
									npc.m_flNextMeleeAttack = gameTime + 0.55;
								}
							}
						}
					}
				}
				case 1:	// Sniper Rifle
				{
					if(npc.m_flNextMeleeAttack < gameTime)
					{
						if(Can_I_See_Enemy(npc.index, npc.m_iTarget) == npc.m_iTarget)
						{
							KillFeed_SetKillIcon(npc.index, "huntsman");
							
							npc.m_flAttackHappens = gameTime + 0.001;
							npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");

							if(distance < 1000000.0 && !NpcStats_IsEnemySilenced(npc.index))	// 1000 HU
								PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, 1500.0, _,vecTarget);
							
							npc.FaceTowards(vecTarget, 30000.0);
							
							npc.PlayRangedSound();
							int BulletHere = npc.FireParticleRocket(vecTarget, (65.0 + (float(tier) * 4.0)) * RaidModeScaling, 1500.0, 0.0, "raygun_projectile_blue_crit", false);
			
							float position[3];
							GetEntPropVector(BulletHere, Prop_Data, "m_vecAbsOrigin", position); 
							TE_Particle("mvm_soldier_shockwave", position, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
							CreateTimer(0.1, WaldchCoolEffectOnProjectile, EntIndexToEntRef(BulletHere), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
							npc.m_flNextMeleeAttack = gameTime + 1.5;
							if(i_RaidGrantExtra[npc.index] >= 5)
							{
								npc.m_flNextMeleeAttack = gameTime + 1.0;
							}
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
				case 2:	// SMG
				{
					// Happens pretty much every think update (0.1 sec)
					if(Can_I_See_Enemy(npc.index, npc.m_iTarget) == npc.m_iTarget)
					{
						KillFeed_SetKillIcon(npc.index, "pro_smg");
						
						npc.FaceTowards(vecTarget, 400.0);

						npc.PlaySMGSound();
						npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY");

						float eyePitch[3];
						GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
						
						float x = GetRandomFloat( -0.01, 0.01 ) + GetRandomFloat( -0.01, 0.01 );
						float y = GetRandomFloat( -0.01, 0.01 ) + GetRandomFloat( -0.01, 0.01 );
						
						float vecDirShooting[3], vecRight[3], vecUp[3];
						
						vecTarget[2] += 15.0;
						MakeVectorFromPoints(vecMe, vecTarget, vecDirShooting);
						GetVectorAngles(vecDirShooting, vecDirShooting);
						vecDirShooting[1] = eyePitch[1];
						GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
						
						float vecDir[3];
						vecDir[0] = vecDirShooting[0] + x * vecRight[0] + y * vecUp[0]; 
						vecDir[1] = vecDirShooting[1] + x * vecRight[1] + y * vecUp[1]; 
						vecDir[2] = vecDirShooting[2] + x * vecRight[2] + y * vecUp[2]; 
						NormalizeVector(vecDir, vecDir);
						
						float damage = (5.0 + float(tier)) * 0.1 * RaidModeScaling;
						if(distance > 100000.0)	// 316 HU
							damage *= 100000.0 / distance;	// Lower damage based on distance
						
						damage *= 3.5;
						if(npc.Anger)
						{
							damage *= 2.5;
						}
						if(i_RaidGrantExtra[npc.index] >= 5)
						{
							damage *= 1.15;
						}
						FireBullet(npc.index, npc.m_iWearable3, vecMe, vecDir, damage, 3000.0, DMG_BULLET, "bullet_tracer01_red");
					}
				}
				case 3:	// C4
				{
					if(npc.m_flNextMeleeAttack && npc.m_flNextMeleeAttack < gameTime)
					{
						npc.m_bisWalking = false;
						npc.SetActivity("ACT_MP_CYOA_PDA_IDLE");
						npc.m_flNextMeleeAttack = 0.0;
					}
					else if(npc.m_flAttackHappens && npc.m_flAttackHappens < gameTime)
					{
						KillFeed_SetKillIcon(npc.index, "pumpkindeath");
						
						vecMe[2] += 45;
						
						i_ExplosiveProjectileHexArray[npc.index] = EP_DEALS_TRUE_DAMAGE;
						Explode_Logic_Custom(3000.0 * zr_smallmapbalancemulti.FloatValue, 0, npc.index, -1, vecMe, 450.0 * zr_smallmapbalancemulti.FloatValue, 1.0, _, true, 20);
					
						
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
				npc.m_bisWalking = true;
				npc.SetActivity("ACT_MP_RUN_MELEE");
				if(npc.m_flNextRangedSpecialAttackHappens < gameTime)
					npc.StartPathing();
			}
			case 1:	// Sniper Rifle
			{
				if(npc.m_flPiggyFor)
				{
					npc.m_bisWalking = false;
					npc.SetActivity("ACT_MP_CROUCH_DEPLOYED_IDLE");
					npc.StopPathing();
				}
				else if(alone)
				{
					npc.m_bisWalking = true;
					npc.SetActivity("ACT_MP_RUN_PRIMARY");
					if(npc.m_flNextRangedSpecialAttackHappens < gameTime)
						npc.StartPathing();
				}
				else if(npc.m_flNextMeleeAttack < gameTime)
				{
					npc.m_bisWalking = true;
					npc.SetActivity("ACT_MP_DEPLOYED_PRIMARY");
					if(npc.m_flNextRangedSpecialAttackHappens < gameTime)
						npc.StartPathing();
				}
				else
				{
					npc.m_bisWalking = false;
					npc.SetActivity("ACT_MP_DEPLOYED_IDLE");
					npc.StopPathing();
				}
			}
			case 2:	// SMG
			{
				if(npc.m_flPiggyFor)
				{
					npc.m_bisWalking = false;
					npc.SetActivity("ACT_MP_CROUCH_SECONDARY");
					npc.StopPathing();
				}
				else
				{
					npc.m_bisWalking = true;
					npc.SetActivity("ACT_MP_RUN_SECONDARY");
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
		npc.m_bisWalking = false;
		npc.StopPathing();
		npc.SetActivity("ACT_MP_COMPETITIVE_LOSERSTATE");
	}
}

	
public Action RaidbossBlueGoggles_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker < 1)
		return Plugin_Continue;
		
	RaidbossBlueGoggles npc = view_as<RaidbossBlueGoggles>(victim);
	
	if(!b_angered_twice[npc.index] && i_RaidGrantExtra[npc.index] == 6)
	{
		if(damage >= GetEntProp(npc.index, Prop_Data, "m_iHealth"))
		{
			SetEntProp(npc.index, Prop_Data, "m_iHealth", 1);
			b_angered_twice[npc.index] = true;
			b_DoNotUnStuck[npc.index] = true;
			b_CantCollidieAlly[npc.index] = true;
			b_CantCollidie[npc.index] = true;
			SetEntityCollisionGroup(npc.index, 24);
			b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true; //Make allied npcs ignore him.
			b_NpcIsInvulnerable[npc.index] = true;
			RemoveNpcFromEnemyList(npc.index);
			GiveProgressDelay(28.0);
			damage = 0.0;
			CPrintToChatAll("{darkblue}Waldch{default}: You win, I won't stop you no more...");
			return Plugin_Handled;
		}

	}

	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
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
		if(Distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 20.0 * zr_smallmapbalancemulti.FloatValue) && Can_I_See_Enemy_Only(npc.index, AllyEntity))
		{	
			damage *= 0.65;
			SDKHooks_TakeDamage(AllyEntity, attacker, inflictor, damage * 0.75, damagetype, weapon, damageForce, damagePosition, false, ZR_DAMAGE_NOAPPLYBUFFS_OR_DEBUFFS);
			damage *= 0.25;
			f_HurtRecentlyAndRedirected[npc.index] = GetGameTime() + 0.15;
		}
		else
		{
			f_GogglesHurtTeleport[npc.index] += damage;
		}
	}

	return Plugin_Changed;
}

public void RaidbossBlueGoggles_NPCDeath(int entity)
{
	RaidbossBlueGoggles npc = view_as<RaidbossBlueGoggles>(entity);
	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
	
	ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
	npc.PlayDeathSound();
	ExpidonsaRemoveEffects(entity);
	
	
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


bool Goggles_TookDamageRecently(int entity)
{
	if(f_HurtRecentlyAndRedirected[entity] > GetGameTime())
	{
		return true;
	}
	return false;
}

void Goggles_SetRaidPartner(int partner)
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

bool IsPartnerGivingUpGoggles(int entity)
{
	if(!IsValidEntity(entity))
		return true;

	return b_angered_twice[entity];
}


void WaldchEarsApply(int iNpc, char[] attachment = "head", float size = 1.0)
{
	int red = 255;
	int green = 25;
	int blue = 25;
	float flPos[3];
	float flAng[3];
	int particle_ears1 = InfoTargetParentAt({0.0,0.0,0.0}, "", 0.0); //This is the root bone basically
	
	//fist ear
	float DoApply[3];
	DoApply = {0.0,-2.5,-5.0};
	DoApply[0] *= size;
	DoApply[1] *= size;
	DoApply[2] *= size;
	int particle_ears2 = InfoTargetParentAt(DoApply, "", 0.0); //First offset we go by
	DoApply = {0.0,-6.0,-10.0};
	DoApply[0] *= size;
	DoApply[1] *= size;
	DoApply[2] *= size;
	int particle_ears3 = InfoTargetParentAt(DoApply, "", 0.0); //First offset we go by
	DoApply = {0.0,-8.0,3.0};
	DoApply[0] *= size;
	DoApply[1] *= size;
	DoApply[2] *= size;
	int particle_ears4 = InfoTargetParentAt(DoApply, "", 0.0); //First offset we go by
	
	//fist ear
	DoApply = {0.0,2.5,-5.0};
	DoApply[0] *= size;
	DoApply[1] *= size;
	DoApply[2] *= size;
	int particle_ears2_r = InfoTargetParentAt(DoApply, "", 0.0); //First offset we go by
	DoApply = {0.0,6.0,-10.0};
	DoApply[0] *= size;
	DoApply[1] *= size;
	DoApply[2] *= size;
	int particle_ears3_r = InfoTargetParentAt(DoApply, "", 0.0); //First offset we go by
	DoApply = {0.0,8.0,3.0};
	DoApply[0] *= size;
	DoApply[1] *= size;
	DoApply[2] *= size;
	int particle_ears4_r = InfoTargetParentAt(DoApply, "", 0.0); //First offset we go by

	SetParent(particle_ears1, particle_ears2, "",_, true);
	SetParent(particle_ears1, particle_ears3, "",_, true);
	SetParent(particle_ears1, particle_ears4, "",_, true);
	SetParent(particle_ears1, particle_ears2_r, "",_, true);
	SetParent(particle_ears1, particle_ears3_r, "",_, true);
	SetParent(particle_ears1, particle_ears4_r, "",_, true);
	Custom_SDKCall_SetLocalOrigin(particle_ears1, flPos);
	SetEntPropVector(particle_ears1, Prop_Data, "m_angRotation", flAng); 
	SetParent(iNpc, particle_ears1, attachment,_);


	int Laser_ears_1 = ConnectWithBeamClient(particle_ears4, particle_ears2, red, green, blue, 1.0 * size, 1.0 * size, 1.0, LASERBEAM);
	int Laser_ears_2 = ConnectWithBeamClient(particle_ears4, particle_ears3, red, green, blue, 1.0 * size, 1.0 * size, 1.0, LASERBEAM);

	int Laser_ears_1_r = ConnectWithBeamClient(particle_ears4_r, particle_ears2_r, red, green, blue, 1.0 * size, 1.0 * size, 1.0, LASERBEAM);
	int Laser_ears_2_r = ConnectWithBeamClient(particle_ears4_r, particle_ears3_r, red, green, blue, 1.0 * size, 1.0 * size, 1.0, LASERBEAM);
	

	i_ExpidonsaEnergyEffect[iNpc][0] = EntIndexToEntRef(particle_ears1);
	i_ExpidonsaEnergyEffect[iNpc][1] = EntIndexToEntRef(particle_ears2);
	i_ExpidonsaEnergyEffect[iNpc][2] = EntIndexToEntRef(particle_ears3);
	i_ExpidonsaEnergyEffect[iNpc][3] = EntIndexToEntRef(particle_ears4);
	i_ExpidonsaEnergyEffect[iNpc][4] = EntIndexToEntRef(Laser_ears_1);
	i_ExpidonsaEnergyEffect[iNpc][5] = EntIndexToEntRef(Laser_ears_2);
	i_ExpidonsaEnergyEffect[iNpc][6] = EntIndexToEntRef(particle_ears2_r);
	i_ExpidonsaEnergyEffect[iNpc][7] = EntIndexToEntRef(particle_ears3_r);
	i_ExpidonsaEnergyEffect[iNpc][8] = EntIndexToEntRef(particle_ears4_r);
	i_ExpidonsaEnergyEffect[iNpc][9] = EntIndexToEntRef(Laser_ears_1_r);
	i_ExpidonsaEnergyEffect[iNpc][10] = EntIndexToEntRef(Laser_ears_2_r);
}


public Action WaldchCoolEffectOnProjectile(Handle timer, any entid)
{
	int Projectile = EntRefToEntIndex(entid);
	if(IsValidEntity(Projectile))
	{
		float position[3];
		GetEntPropVector(Projectile, Prop_Data, "m_vecAbsOrigin", position); 
		TE_Particle("mvm_soldier_shockwave", position, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
					
	}
	return Plugin_Handled;
}