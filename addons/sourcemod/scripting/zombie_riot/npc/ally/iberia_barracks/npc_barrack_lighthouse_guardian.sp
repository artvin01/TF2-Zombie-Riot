#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"vo/demoman_paincrticialdeath01.mp3",
	"vo/demoman_paincrticialdeath02.mp3",
	"vo/demoman_paincrticialdeath03.mp3",
	"vo/demoman_paincrticialdeath04.mp3",
	"vo/demoman_paincrticialdeath05.mp3",
};

static const char g_IdleSounds[][] =
{
	"vo/medic_specialcompleted11.mp3",
	"vo/medic_specialcompleted12.mp3",
	"vo/medic_specialcompleted08.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/neon_sign_hit_01.wav",
	"weapons/neon_sign_hit_02.wav",
	"weapons/neon_sign_hit_03.wav",
	"weapons/neon_sign_hit_04.wav"
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/knife_swing.wav",
};

static const char g_RangedAttackSounds[][] =
{
	"weapons/doom_scout_shotgun.wav"
};

static const char g_RangedAttackSoundsSecondary[][] = {
	"items/powerup_pickup_resistance.wav",
};

static const char g_RangedAttackSRocket[][] = {
	"items/powerup_pickup_resistance.wav",
};

static const char g_IdleAlertedSounds[][] =
{
	"vo/medic_hat_taunts01.mp3",
	"vo/medic_hat_taunts04.mp3",
	"vo/medic_item_secop_round_start05.mp3",
	"vo/medic_item_secop_round_start07.mp3",
	"vo/medic_item_secop_kill_assist01.mp3",
};

void Barracks_Iberia_Lighthouse_Guardian_Precache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_RangedAttackSounds);
	PrecacheModel("models/player/demo.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Barracks Iberian Lighthouse Guardian");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_barrack_lighthouse_guardian");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return Barracks_Iberia_Lighthouse_Guardian(client, vecPos, vecAng, ally);
}

methodmap  Barracks_Iberia_Lighthouse_Guardian < BarrackBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleSound()");
		#endif
	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleAlertSound()");
		#endif
	}
	
	public void PlayNPCDeath() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayDeathSound()");
		#endif
	}

	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}

	public void PlayRangedAttackSecondarySound() {
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayRangedSound()");
		#endif
	}

	public void PlayRangedAttackRocket() {
		EmitSoundToAll(g_RangedAttackSRocket[GetRandomInt(0, sizeof(g_RangedAttackSRocket) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayRangedSound()");
		#endif
	}

	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}

	public Barracks_Iberia_Lighthouse_Guardian(int client, float vecPos[3], float vecAng[3], int ally)
	{
		Barracks_Iberia_Lighthouse_Guardian npc = view_as<Barracks_Iberia_Lighthouse_Guardian>(BarrackBody(client, vecPos, vecAng, "1200", "models/player/demo.mdl", STEPTYPE_COMBINE,"0.75",_,"models/pickups/pickup_powerup_resistance.mdl"));
		
		i_NpcWeight[npc.index] = 1;
		
		func_NPCOnTakeDamage[npc.index] = BarrackBody_OnTakeDamage;
		func_NPCDeath[npc.index] = Barracks_Iberia_Lighthouse_Guardian_NPCDeath;
		func_NPCThink[npc.index] = Barracks_Iberia_Lighthouse_Guardian_ClotThink;
		func_NPCOnTakeDamage[npc.index] = Barrack_Iberia_Guards_OnTakeDamage;
		npc.m_flSpeed = 180.0;
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_flAttackHappens_bullshit = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.Anger = false;
		npc.m_fbRangedSpecialOn = false;

		KillFeed_SetKillIcon(npc.index, "bat");

		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable9 = npc.EquipItem("head", "models/player/medic.mdl", "", skin);
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_bat.mdl");
		SetVariantString("1.3");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/weapons/c_models/c_persian_shield/c_persian_shield.mdl");
		SetVariantString("1.5");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/jul13_heavy_defender/jul13_heavy_defender.mdl", "", skin);
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/sniper/fall2013_kyoto_rider/fall2013_kyoto_rider.mdl", "", skin);
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/soldier/xms2013_soldier_marshal_hat/xms2013_soldier_marshal_hat.mdl", "", skin);
		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/medic/sbxo2014_medic_wintergarb_coat/sbxo2014_medic_wintergarb_coat.mdl", "" , skin);
		npc.m_iWearable7 = npc.EquipItem("head", "models/workshop/player/items/medic/cardiologists_camo/cardiologists_camo.mdl", "" , skin);
		npc.m_iWearable8 = npc.EquipItem("head", "models/workshop/player/items/all_class/bak_teufort_knight/bak_teufort_knight_medic.mdl", "" , skin);

		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 0, 0, 0, 0);
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, 75, 255, 255, 255);
		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable2, 100, 100, 100, 255);
		SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable3, 100, 100, 100, 255);
		SetEntityRenderMode(npc.m_iWearable8, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable8, 100, 100, 100, 255);
		return npc;
	}
}

public void Barracks_Iberia_Lighthouse_Guardian_ClotThink(int iNPC)
{
	Barracks_Iberia_Lighthouse_Guardian npc = view_as<Barracks_Iberia_Lighthouse_Guardian>(iNPC);
	float GameTime = GetGameTime(iNPC);

	GrantEntityArmor(iNPC, true, 2.5, 0.1, 0);

	if(BarrackBody_ThinkStart(npc.index, GameTime))
	{
		int client = BarrackBody_ThinkTarget(npc.index, true, GameTime);

		if(npc.m_iTarget > 0)
		{
			npc.PlayIdleAlertSound();
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);

			//Target close enough to hit
			if(!npc.Anger)
			{
				if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
				{
				
					if(npc.m_flNextMeleeAttack < GameTime || npc.m_flAttackHappenswillhappen)
					{
						if(!npc.m_flAttackHappenswillhappen)
						{
							npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM1");
							npc.PlayMeleeSound();
							npc.m_flAttackHappens = GameTime + 0.3;
							npc.m_flAttackHappens_bullshit = GameTime + 0.44;
							npc.m_flNextMeleeAttack = GameTime + (1.5 * npc.BonusFireRate);
							npc.m_flAttackHappenswillhappen = true;
						}
						if(npc.m_flAttackHappens < GameTime && npc.m_flAttackHappens_bullshit >= GameTime && npc.m_flAttackHappenswillhappen)
						{
							Handle swingTrace;
							npc.FaceTowards(vecTarget, 20000.0);
							if(npc.DoSwingTrace(swingTrace, npc.m_iTarget))
							{
								int target = TR_GetEntityIndex(swingTrace);	
								
								float vecHit[3];
								TR_GetEndPosition(vecHit, swingTrace);

								if(target > 0) 
								{
									SDKHooks_TakeDamage(target, npc.index, client, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId),8500.0, 0), DMG_CLUB, -1, _, vecHit);
									npc.PlayMeleeHitSound();
									ExpidonsaGroupHeal(npc.index, 150.0, 4, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId),20.0, 0), 1.0, true);
								} 
							}
							delete swingTrace;
							npc.m_flAttackHappenswillhappen = false;
						}
						else if(npc.m_flAttackHappens_bullshit < GameTime && npc.m_flAttackHappenswillhappen)
						{
							npc.m_flAttackHappenswillhappen = false;
						}
					}
				}
				if(npc.m_flNextRangedSpecialAttack < GetGameTime(npc.index))
				{
					ExpidonsaGroupHeal(npc.index, 100.0, 5, 50.0, 0.0, false,Expidonsa_DontHealSameIndex);
					VausMagicaGiveShield(victim, 5);
					npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 10.0;
					npc.PlayRangedAttackSecondarySound();
				}
			}
			if(npc.Anger)
			{
				if(flDistanceToTarget < 250000.0)
				{
					int Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
					//Target close enough to hit
					if(IsValidEnemy(npc.index, Enemy_I_See))
					{
						if(npc.m_flNextRangedAttack < GameTime)
						{
							if(!npc.m_fbRangedSpecialOn)
							{
								float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex,_,_, vPredictedPos);
								npc.FireRocket(vPredictedPos, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId), 850.0, 1), 450.0, "models/weapons/c_models/c_leechgun/c_leech_proj.mdl",1.75);
								npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 9.0;
								npc.PlayRangedAttackRocket();
								npc.m_fbRangedSpecialOn = true;
								npc.m_flRangedSpecialDelay = GetGameTime(npc.index) + 10.0;
							}
							npc.AddGesture("ACT_GESTURE_RANGE_ATTACK_AR2", false);
							npc.m_iTarget = Enemy_I_See;
							npc.PlayRangedSound();
							npc.FaceTowards(vecTarget, 300000.0);
							Handle swingTrace;
							if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex, { 9999.0, 9999.0, 9999.0 }))
							{
								int target = TR_GetEntityIndex(swingTrace);	
									
								float vecHit[3];
								TR_GetEndPosition(vecHit, swingTrace);
								float origin[3], angles[3];
								view_as<CClotBody>(npc.m_iWearable1).GetAttachment("muzzle", origin, angles);
								ShootLaser(npc.m_iWearable1, "bullet_tracer02_red", origin, vecHit, false );
								
								npc.m_flNextRangedAttack = GameTime + (0.1 * npc.BonusFireRate);
								
								SDKHooks_TakeDamage(target, npc.index, client, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId), 400.0, 1), DMG_BULLET, -1, _, vecHit);
							} 		
							delete swingTrace;			
						}
					}
				}
				if(npc.m_flRangedSpecialDelay < GetGameTime(npc.index))
				{
					npc.m_fbRangedSpecialOn = false;
				}
			}
		}
		else
		{
			npc.PlayIdleSound();
		}
		if(!npc.Anger)
		{
			BarrackBody_ThinkMove(npc.index, 180.0, "ACT_MP_COMPETITIVE_WINNERSTATE", "ACT_MP_RUN_ITEM1");
		}
		if(npc.Anger)
		{
			BarrackBody_ThinkMove(npc.index, 220.0, "ACT_MP_COMPETITIVE_WINNERSTATE", "ACT_MP_RUN_SECONDARY", 10000.0,_, true);
		}
	}
}

public Action Barrack_Iberia_Guards_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	Barracks_Iberia_Lighthouse_Guardian npc = view_as<Barracks_Iberia_Lighthouse_Guardian>(victim);
	
	if(percentageArmorLeft <= 0.0)
		{
			if(IsValidEntity(npc.m_iWearable2))
				RemoveEntity(npc.m_iWearable2);
			if(IsValidEntity(npc.m_iWearable1))
				RemoveEntity(npc.m_iWearable1);
				npc.Anger = true;
			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_dex_shotgun/c_dex_shotgun.mdl");
			SetVariantString("1.5");
			AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
			SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.m_iWearable1, 0, 200, 200, 255);
		}

	
	/*
	if(attacker > MaxClients && !IsValidEnemy(npc.index, attacker))
		return Plugin_Continue;
	*/
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	
	return Plugin_Changed;
}

void Barracks_Iberia_Lighthouse_Guardian_NPCDeath(int entity)
{
	Barracks_Iberia_Lighthouse_Guardian npc = view_as<Barracks_Iberia_Lighthouse_Guardian>(entity);
	BarrackBody_NPCDeath(npc.index);
	ExpidonsaGroupHeal(npc.index, 300.0, 4, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId),50.0, 0), 1.0, true);
	npc.PlayNPCDeath();
}