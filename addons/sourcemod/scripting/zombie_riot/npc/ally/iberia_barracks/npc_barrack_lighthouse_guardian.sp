#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"vo/medic_paincrticialdeath01.mp3",
	"vo/medic_paincrticialdeath02.mp3",
	"vo/medic_paincrticialdeath03.mp3",
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
static const char g_RangedAttackSounds2[][] =
{
	"weapons/widow_maker_shot_01.wav",
	"weapons/widow_maker_shot_02.wav",
	"weapons/widow_maker_shot_03.wav",
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

static const char g_WarCry[][] = {
	"weapons/medi_shield_deploy.wav",
};

void Barracks_Iberia_Lighthouse_Guardian_Precache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_RangedAttackSounds);
	PrecacheSoundArray(g_RangedAttackSounds2);
	PrecacheSoundArray(g_RangedAttackSRocket);
	PrecacheSoundArray(g_WarCry);
	PrecacheModel("models/player/engineer.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Barracks Iberian Lighthouse Guardian");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_barrack_lighthouse_guardian");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return Barracks_Iberia_Lighthouse_Guardian(client, vecPos, vecAng);
}

methodmap  Barracks_Iberia_Lighthouse_Guardian < BarrackBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		

	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		

	}
	
	public void PlayNPCDeath() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		

	}

	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		

	}
	public void PlayRangedSound2() {
		EmitSoundToAll(g_RangedAttackSounds2[GetRandomInt(0, sizeof(g_RangedAttackSounds2) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		

	}

	public void PlayRangedAttackSecondarySound() {
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		

	}

	public void PlayRangedAttackRocket() {
		EmitSoundToAll(g_RangedAttackSRocket[GetRandomInt(0, sizeof(g_RangedAttackSRocket) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		

	}

	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		

	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		

	}

	public void PlayMeleeWarCry()
	{
		EmitSoundToAll(g_WarCry[GetRandomInt(0, sizeof(g_WarCry) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		

	}

	public Barracks_Iberia_Lighthouse_Guardian(int client, float vecPos[3], float vecAng[3])
	{
		Barracks_Iberia_Lighthouse_Guardian npc = view_as<Barracks_Iberia_Lighthouse_Guardian>(BarrackBody(client, vecPos, vecAng, "2100", "models/player/engineer.mdl", STEPTYPE_COMBINE,"0.7",_,"models/pickups/pickup_powerup_resistance.mdl"));
		
		i_NpcWeight[npc.index] = 1;
		
		func_NPCDeath[npc.index] = Barracks_Iberia_Lighthouse_Guardian_NPCDeath;
		func_NPCThink[npc.index] = Barracks_Iberia_Lighthouse_Guardian_ClotThink;
		func_NPCOnTakeDamage[npc.index] = Barrack_Iberia_Lighthouse_Guardian_OnTakeDamage;
		npc.m_flSpeed = 180.0;
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_iAttacksTillReload = 0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_flAttackHappens_bullshit = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.Anger = false;
		npc.m_fbRangedSpecialOn = false;

		KillFeed_SetKillIcon(npc.index, "bat");

		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		SetVariantInt(0);
		AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");

		npc.m_iWearable1 = npc.EquipItem("head", "models/player/medic.mdl", "", skin);
		
		npc.m_iWearable2 = npc.EquipItem("weapon_bone", "models/workshop/weapons/c_models/c_invasion_bat/c_invasion_bat.mdl");
		SetVariantString("1.3");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/jul13_heavy_defender/jul13_heavy_defender.mdl", "", skin);
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/soldier/xms2013_soldier_marshal_hat/xms2013_soldier_marshal_hat.mdl", "", skin);
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/all_class/bak_teufort_knight/bak_teufort_knight_medic.mdl", "" , skin);
		SetVariantString("0.9");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");

		SetEntityRenderMode(npc.index, RENDER_NONE);
		SetEntityRenderColor(npc.index, 0, 0, 0, 0);
		SetEntityRenderColor(npc.m_iWearable2, 75, 255, 255, 255);
		SetEntityRenderColor(npc.m_iWearable3, 0, 200, 200, 255);
		SetEntityRenderColor(npc.m_iWearable4, 100, 100, 100, 255);
		return npc;
	}
}

public void Barracks_Iberia_Lighthouse_Guardian_ClotThink(int iNPC)
{
	Barracks_Iberia_Lighthouse_Guardian npc = view_as<Barracks_Iberia_Lighthouse_Guardian>(iNPC);
	float GameTime = GetGameTime(iNPC);

	GrantEntityArmor(iNPC, true, 0.75, 0.66, 0);

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
							npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS");
							npc.PlayMeleeSound();
							npc.m_flAttackHappens = GameTime + 0.3;
							npc.m_flAttackHappens_bullshit = GameTime + 0.44;
							npc.m_flNextMeleeAttack = GameTime + (1.3 * npc.BonusFireRate);
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
									SDKHooks_TakeDamage(target, npc.index, client, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId),9000.0, 0), DMG_CLUB, -1, _, vecHit);
									npc.PlayMeleeHitSound();
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
					npc.m_flNextRangedSpecialAttack = GameTime + 5.0;
					ExpidonsaGroupHeal(npc.index, 150.0, 2, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId),507.0, 0), 1.0, true, IberiaBarracks_HealSelfLimitCD);
					DesertYadeamDoHealEffect(npc.index, 150.0);
					GuardianAOEBuff(npc,GetGameTime(npc.index));

					npc.PlayRangedAttackSecondarySound();
				}
			}
			if(npc.Anger)
			{
				if(npc.m_iAttacksTillReload >= 45) // After 45 attacks he returns to melee/support mode with 50% armor
				{
					NpcSpeechBubble(npc.index, "Armor repaired, i'm ready to support everyone again!", 5, {75, 255, 255, 255}, {0.0,0.0,60.0}, "");
					GrantEntityArmor(iNPC, false, 0.5, 0.66, 0);
					if(IsValidEntity(npc.m_iWearable2))
					RemoveEntity(npc.m_iWearable2);
					npc.m_iWearable2 = npc.EquipItem("weapon_bone", "models/workshop/weapons/c_models/c_invasion_bat/c_invasion_bat.mdl");
					SetVariantString("1.3");
					AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
					npc.Anger = false;
					npc.m_iAttacksTillReload = 0;
				}
				if(flDistanceToTarget < 75000.0)
				{
					int PrimaryThreatIndex = npc.m_iTarget;
					int Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
					//Target close enough to hit
					if(IsValidEnemy(npc.index, Enemy_I_See))
					{
						if(npc.m_flNextRangedAttack < GameTime)
						{
							float damage = 5000.0;
							
							if(!npc.m_fbRangedSpecialOn)
							{
								float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex,_,_, vPredictedPos);
								npc.FireRocket(vPredictedPos, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId), 5000.0, 1), 450.0, "models/weapons/c_models/c_leechgun/c_leech_proj.mdl",1.75);
								npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 6.0;
								npc.PlayRangedAttackRocket();
								npc.m_fbRangedSpecialOn = true;
							}
							npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY", false);
							npc.m_iTarget = Enemy_I_See;
							npc.PlayRangedSound();
							npc.PlayRangedSound2();
							npc.FaceTowards(vecTarget, 300000.0);
							Handle swingTrace;
							if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex, { 9999.0, 9999.0, 9999.0 }))
							{
								int target = TR_GetEntityIndex(swingTrace);	
									
								float vecHit[3];
								TR_GetEndPosition(vecHit, swingTrace);
								float origin[3], angles[3];
								view_as<CClotBody>(npc.m_iWearable2).GetAttachment("muzzle", origin, angles);
								ShootLaser(npc.m_iWearable2, "bullet_tracer02_red", origin, vecHit, false );
								
								npc.m_flNextRangedAttack = GameTime + (0.6 * npc.BonusFireRate);
								npc.m_iAttacksTillReload ++;
								if(npc.CmdOverride == Command_HoldPos)
								{
									npc.m_iAttacksTillReload --; // If it's holding a position it won't progress the armor repair
									damage *= 0.66; // Deals 33% less damage if in hold position too, so can't abuse his dps form for camping a cade
								}
								SDKHooks_TakeDamage(target, npc.index, client, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId), damage, 1), DMG_BULLET, -1, _, vecHit);

							} 		
							delete swingTrace;			
						}
					}
				}
				if(npc.m_flNextRangedSpecialAttack < GetGameTime(npc.index))
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
			BarrackBody_ThinkMove(npc.index, 250.0, "ACT_MP_RUN_MELEE_ALLCLASS", "ACT_MP_RUN_MELEE_ALLCLASS");
		}
		if(npc.Anger)
		{
			BarrackBody_ThinkMove(npc.index, 220.0, "ACT_MP_RUN_PRIMARY", "ACT_MP_RUN_PRIMARY", 50000.0,_, true);
		}
	}
}

public Action Barrack_Iberia_Lighthouse_Guardian_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	Barracks_Iberia_Lighthouse_Guardian npc = view_as<Barracks_Iberia_Lighthouse_Guardian>(victim);

	float percentageArmorLeft = npc.m_flArmorCount / npc.m_flArmorCountMax;
	if(percentageArmorLeft <= 0.0)
	{
		if(IsValidEntity(npc.m_iWearable2))
			RemoveEntity(npc.m_iWearable2);
		if(IsValidEntity(npc.m_iWearable3))
			RemoveEntity(npc.m_iWearable3);
		if(!npc.Anger)
		{
			switch(GetRandomInt(0,3))
			{
				case 0:
				{
					NpcSpeechBubble(npc.index, "For IBERIA!", 5, {75, 255, 255, 255}, {0.0,0.0,60.0}, "");
				}
				case 1:
				{
					NpcSpeechBubble(npc.index, "That's it!", 5, {255,255,255,255}, {0.0,0.0,60.0}, "");
				}
				case 2:
				{
					NpcSpeechBubble(npc.index, "Get behind me!!", 5, {200,0,0,255}, {0.0,0.0,60.0}, "");
				}
				case 3:
				{
					NpcSpeechBubble(npc.index, "Take This!", 5, {255,255,255,255}, {0.0,0.0,60.0}, "");
				}
			}
			npc.Anger = true;
		}
		npc.m_iWearable2 = npc.EquipItem("head", "models/weapons/c_models/c_dex_shotgun/c_dex_shotgun.mdl");
		SetVariantString("1.75");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		SetEntityRenderColor(npc.m_iWearable2, 0, 200, 200, 255);
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
	ExpidonsaGroupHeal(npc.index, 300.0, 4, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId),2000.0, 0), 1.0, true, IberiaBarracks_HealSelfLimitCD);
	if(IsValidEntity(npc.m_iWearable8))
		RemoveEntity(npc.m_iWearable8);
	npc.PlayNPCDeath();
}

void GuardianAOEBuff(Barracks_Iberia_Lighthouse_Guardian npc, float gameTime)
{
	float pos1[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos1);
	if(npc.m_flRangedSpecialDelay < gameTime)
	{
		for(int entitycount; entitycount<MAXENTITIES; entitycount++) //Check for npcs
		{
			if(IsValidEntity(entitycount) && entitycount != npc.index && (!b_NpcHasDied[entitycount])) //Cannot buff self like this.
			{
				if(GetTeam(entitycount) == GetTeam(npc.index) && IsEntityAlive(entitycount))
				{
					static float pos2[3];
					GetEntPropVector(entitycount, Prop_Data, "m_vecAbsOrigin", pos2);
					if(GetVectorDistance(pos1, pos2, true) < (750 * 750))
					{
						//give 200 armor at most.
						GrantEntityArmor(entitycount, false, 0.5, 0.66, 0, .custom_maxarmour = 300.0);
					}
				}
			}
		}
	}
	npc.PlayMeleeWarCry();
}