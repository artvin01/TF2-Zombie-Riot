#pragma semicolon 1
#pragma newdecls required

// made my first super boss, i lowkey tweaked but i pulled it off, feel free to give critiques
// ive been coding with lua for the past 6+ years so this was fun to transition to.

#define SECURITY_MODEL "models/bots/heavy/bot_heavy.mdl"
#define SECURITY_INFECTION_RANGE 300.0
#define SECURITY_ENRAGE_THRESHOLD 0.5 

static const char g_DeathSounds[][] =
{
	"mvm/giant_heavy/giant_heavy_explode.wav"
};

static const char g_HurtSounds[][] =
{
	"vo/mvm/norm/heavy_mvm_painsharp01.mp3",
	"vo/mvm/norm/heavy_mvm_painsharp02.mp3",
	"vo/mvm/norm/heavy_mvm_painsharp03.mp3",
	"vo/mvm/norm/heavy_mvm_painsharp04.mp3",
	"vo/mvm/norm/heavy_mvm_painsharp05.mp3",
};

static const char g_IdleSounds[][] =
{
	"mvm/giant_heavy/giant_heavy_entrance.wav"
};

static const char g_MeleeHitSounds[][] =
{
	"weapons/metal_gloves_hit_flesh1.wav",
	"weapons/metal_gloves_hit_flesh2.wav",
	"weapons/metal_gloves_hit_flesh3.wav",
	"weapons/metal_gloves_hit_flesh4.wav"
};

static const char g_MeleeAttackSounds[][] =
{
	"ui/item_robot_arm_drop.wav"
};

static const char g_AngerSounds[][] =
{
	"mvm/giant_heavy/giant_heavy_gunwindup.wav"
};

static const char g_SecurityAlertSounds[][] =
{
	"ambient/alarms/klaxon1.wav"
};

void XenoLabSecurity_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Xeno Lab Security");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_xeno_lab_security");
	strcopy(data.Icon, sizeof(data.Icon), "heavy_champ_vac_blast");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_NORMAL|MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Xeno;  // Xeno category for super boss
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	for (int i = 0; i < (sizeof(g_DeathSounds)); i++) { PrecacheSound(g_DeathSounds[i]); }
	for (int i = 0; i < (sizeof(g_HurtSounds)); i++) { PrecacheSound(g_HurtSounds[i]); }
	for (int i = 0; i < (sizeof(g_IdleSounds)); i++) { PrecacheSound(g_IdleSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_AngerSounds)); i++) { PrecacheSound(g_AngerSounds[i]); }
	for (int i = 0; i < (sizeof(g_SecurityAlertSounds)); i++) { PrecacheSound(g_SecurityAlertSounds[i]); }
	
	PrecacheModel(SECURITY_MODEL);
	PrecacheModel("models/workshop/player/items/heavy/robo_heavy_chief/robo_heavy_chief.mdl");
	PrecacheModel("models/workshop/player/items/heavy/spr18_tsar_platinum/spr18_tsar_platinum.mdl");
	PrecacheModel("models/workshop/player/items/heavy/spr18_starboard_crusader/spr18_starboard_crusader.mdl");
	PrecacheModel("models/workshop/player/items/heavy/sum23_hog_heels/sum23_hog_heels.mdl");
	PrecacheSound("weapons/cow_mangler_explode.wav");
	PrecacheSound("weapons/physcannon/energy_bounce1.wav");
	PrecacheSound("weapons/physcannon/energy_bounce2.wav");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return XenoLabSecurity(vecPos, vecAng, team, data);
}

methodmap XenoLabSecurity < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	
	public void PlayHurtSound()
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextHurtSound = GetGameTime(this.index) + GetRandomFloat(0.6, 1.6);
	}
	
	public void PlayDeathSound()
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayAngerSound()
	{
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlaySecurityAlertSound()
	{
		EmitSoundToAll(g_SecurityAlertSounds[GetRandomInt(0, sizeof(g_SecurityAlertSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public XenoLabSecurity(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		XenoLabSecurity npc = view_as<XenoLabSecurity>(CClotBody(vecPos, vecAng, SECURITY_MODEL, "1.75", "125000", ally, false));
		// 125000 HP - Super boss tier
		
		i_NpcWeight[npc.index] = 6; 
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		npc.m_bisWalking = true;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = STEPTYPE_ROBOT;
		
		func_NPCDeath[npc.index] = XenoLabSecurity_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = XenoLabSecurity_OnTakeDamage;
		func_NPCThink[npc.index] = XenoLabSecurity_ClotThink;
		
		npc.m_flSpeed = 220.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		npc.Anger = false;  // Not enraged yet
		
		// Check if this is a lab version
		bool isLabVersion = StrContains(data, "lab") != -1;
		npc.m_bIsLabVersion = isLabVersion;
		
		// Adaptive Combat Protocol counter
		npc.m_iOverlordComboAttack = 0;
		
		// Infection ability timer
		npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 12.0;
		
		if(!IsValidEntity(RaidBossActive))
		{
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidModeTime = GetGameTime() + 9000.0;
			RaidModeScaling = 0.0;  // Super boss safety net
			RaidAllowsBuildings = true;
		}
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/heavy/robo_heavy_chief/robo_heavy_chief.mdl");
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/heavy/spr18_tsar_platinum/spr18_tsar_platinum.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/heavy/spr18_starboard_crusader/spr18_starboard_crusader.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/heavy/sum23_hog_heels/sum23_hog_heels.mdl");
		
		SetEntityRenderMode(npc.index, RENDER_TRANSALPHA);
		SetEntityRenderColor(npc.index, 50, 200, 50, 255);
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSALPHA);
		SetEntityRenderColor(npc.m_iWearable1, 50, 200, 50, 255);
		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSALPHA);
		SetEntityRenderColor(npc.m_iWearable2, 50, 200, 50, 255);
		SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSALPHA);
		SetEntityRenderColor(npc.m_iWearable3, 50, 200, 50, 255);
		SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSALPHA);
		SetEntityRenderColor(npc.m_iWearable4, 50, 200, 50, 255);
		
		npc.m_bThisNpcIsABoss = true;
		npc.StartPathing();
		
		if(isLabVersion)
		{
			CPrintToChatAll("{red}[XENO LAB SECURITY PROTOCOL ACTIVATED]");
			CPrintToChatAll("{crimson}Xeno Lab Security{default}: INTRUDERS DETECTED. INITIATING CONTAINMENT PROCEDURES.");
		}
		else
		{
			CPrintToChatAll("{red}[XENO SECURITY UNIT DEPLOYED]");
			CPrintToChatAll("{green}Xeno Security{default}: Target acquired. Commencing elimination protocol.");
		}
		npc.PlaySecurityAlertSound();
		
		return npc;
	}
	
	property int m_iCombatProtocol
	{
		public get() { return this.m_iOverlordComboAttack; }
		public set(int value) { this.m_iOverlordComboAttack = value; }
	}
	
	property bool m_bIsLabVersion
	{
		public get() { return view_as<bool>(this.m_iMedkitAnnoyance); }
		public set(bool value) { this.m_iMedkitAnnoyance = value ? 1 : 0; }
	}
}

public void XenoLabSecurity_ClotThink(int iNPC)
{
	XenoLabSecurity npc = view_as<XenoLabSecurity>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	npc.m_iCombatProtocol++;
	
	// every 1000 ticks (10 seconds), get stronger for difficulty. seemed fun to me, if this is too much whoops...
	if(npc.m_iCombatProtocol >= 1000)
	{
		npc.m_iCombatProtocol = 0;
		
		if(npc.m_flSpeed < 350.0)
		{
			npc.m_flSpeed += 10.0;
			
			// Visual feedback
			float pos[3];
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
			spawnRing_Vectors(pos, 0.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 50, 255, 50, 200, 1, 0.5, 6.0, 8.0, 1, 200.0);
			
			EmitSoundToAll("weapons/physcannon/energy_bounce1.wav", npc.index, _, 80, _, 0.5);
		}
	}
	
	if(npc.m_flNextRangedSpecialAttack < gameTime)
	{
		Security_InfectionProtocol(npc, gameTime);
	}
	
	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		
		if(flDistanceToTarget < npc.GetLeadRadius())
		{
			float vPredictedPos[3];
			PredictSubjectPosition(npc, npc.m_iTarget, _, _, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}
		
		npc.StartPathing();
		
		Security_SelfDefense(npc, gameTime, npc.m_iTarget, flDistanceToTarget);
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	
	npc.PlayIdleSound();
}

void Security_InfectionProtocol(XenoLabSecurity npc, float gameTime)
{
	// Brief preparation sound
	npc.PlayAngerSound();
	
	float pos[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
	pos[2] += 45.0;
	
	// warning rings - bigger range if lab version and enraged (cant tell if these work....)
	float range = (npc.m_bIsLabVersion && npc.Anger) ? SECURITY_INFECTION_RANGE * 1.5 : SECURITY_INFECTION_RANGE;
	spawnRing_Vectors(pos, range * 2.0, 0.0, 0.0, 10.0, "materials/sprites/laserbeam.vmt", 50, 255, 50, 200, 1, 2.0, 6.0, 8.0, 1, 1.0);
	spawnRing_Vectors(pos, range * 2.0, 0.0, 0.0, 10.0, "materials/sprites/laserbeam.vmt", 100, 255, 100, 200, 1, 2.0, 6.0, 8.0, 1, 1.0);
	spawnRing_Vectors(pos, range * 2.0, 0.0, 0.0, 10.0, "materials/sprites/laserbeam.vmt", 150, 255, 150, 200, 1, 2.0, 6.0, 8.0, 1, 1.0);
	
	float ang[3];
	ang[0] = -90.0;
	int particle = ParticleEffectAt(pos, "green_steam_plume", 2.0);
	TeleportEntity(particle, NULL_VECTOR, ang, NULL_VECTOR);
	
	DataPack pack;
	CreateDataTimer(2.0, Timer_SecurityInfectionBlast, pack, TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(EntIndexToEntRef(npc.index));
	pack.WriteFloat(range);
	
	// Next infection time based on lab version enrage state
	float cooldown = (npc.m_bIsLabVersion && npc.Anger) ? 8.0 : 12.0;
	npc.m_flNextRangedSpecialAttack = gameTime + 2.0 + cooldown;
}

public Action Timer_SecurityInfectionBlast(Handle timer, DataPack pack)
{
	pack.Reset();
	int ref = pack.ReadCell();
	float range = pack.ReadFloat();
	
	int entity = EntRefToEntIndex(ref);
	if(!IsValidEntity(entity))
		return Plugin_Stop;
	
	XenoLabSecurity npc = view_as<XenoLabSecurity>(entity);
	
	float pos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
	pos[2] += 10.0;
	
	float damage = (npc.m_bIsLabVersion && npc.Anger) ? 500.0 : 350.0;
	Explode_Logic_Custom(damage, entity, entity, -1, pos, range, _, _, true, _, _, 1.0, Security_InfectionHit);
	
	int particle = ParticleEffectAt(pos, "green_wof_sparks", 2.0);
	float ang[3];
	ang[0] = -90.0;
	TeleportEntity(particle, NULL_VECTOR, ang, NULL_VECTOR);
	
	EmitSoundToAll("weapons/cow_mangler_explode.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);
	
	if(npc.m_bIsLabVersion)
	{
		if(npc.Anger)
		{
			CPrintToChatAll("{crimson}Xeno Lab Security{default}: ENHANCED PROTOCOLS ACTIVE. MAXIMUM CONTAINMENT.");
		}
		else
		{
			CPrintToChatAll("{crimson}Xeno Lab Security{default}: INFECTION PROTOCOL DEPLOYED.");
		}
	}
	else
	{
		if(npc.Anger)
		{
			CPrintToChatAll("{green}Xeno Security{default}: Enhanced combat mode engaged.");
		}
		else
		{
			CPrintToChatAll("{green}Xeno Security{default}: Area denial protocol active.");
		}
	}
	
	return Plugin_Stop;
}

void Security_InfectionHit(int entity, int victim, float damage, int weapon)
{
	XenoLabSecurity npc = view_as<XenoLabSecurity>(entity);
	
	if(IsValidClient(victim) && !IsInvuln(victim))
	{
		// HUD notification - different message based on version
		float HudY = -1.0;
		float HudX = -1.0;
		SetHudTextParams(HudX, HudY, 3.0, 50, 255, 50, 255);
		
		if(npc.m_bIsLabVersion)
		{
			ShowHudText(victim, -1, "XENO LAB SECURITY HAS INFECTED YOU!");
		}
		else
		{
			ShowHudText(victim, -1, "CONTAMINATED");
		}
		ClientCommand(victim, "playgamesound items/cart_explode.wav");
		
		// Stronger infection in enraged mode (lab version only)
		int tickCount = (npc.m_bIsLabVersion && npc.Anger) ? 15 : 10;
		float tickDamage = (npc.m_bIsLabVersion && npc.Anger) ? 80.0 : 60.0;
		
		// Apply infection DoT
		StartBleedingTimer(victim, entity, tickDamage, tickCount, -1, DMG_SLASH, 0, 1);
		
		// Slow effect - stronger when enraged
		float slowDuration = (npc.m_bIsLabVersion && npc.Anger) ? 3.0 : 2.0;
		TF2_StunPlayer(victim, slowDuration, 0.5, TF_STUNFLAG_SLOWDOWN);
	}
}

void Security_SelfDefense(XenoLabSecurity npc, float gameTime, int target, float distance)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget))
			{
				target = TR_GetEntityIndex(swingTrace);
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if(IsValidEnemy(npc.index, target))
				{
					// Base damage
					float damageDealt = 400.0;
					
					// Enraged mode damage boost - ONLY for lab versions
					if(npc.m_bIsLabVersion && npc.Anger)
						damageDealt *= 1.5;
					
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 5.0;
					
					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);
					npc.PlayMeleeHitSound();
					
					// Knockback in enraged mode - ONLY for lab versions
					if(npc.m_bIsLabVersion && npc.Anger)
					{
						float direction[3];
						SubtractVectors(vecHit, VecEnemy, direction);
						NormalizeVector(direction, direction);
						ScaleVector(direction, 500.0);
						
						if(IsValidClient(target))
						{
							TeleportEntity(target, NULL_VECTOR, NULL_VECTOR, direction);
						}
					}
				}
			}
			delete swingTrace;
		}
	}
	
	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
		{
			int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
			
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
				
				npc.m_flAttackHappens = gameTime + 0.4;
				
				float attackCooldown = (npc.m_bIsLabVersion && npc.Anger) ? 0.8 : 1.2;
				npc.m_flNextMeleeAttack = gameTime + attackCooldown;
			}
		}
	}
}

public Action XenoLabSecurity_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	XenoLabSecurity npc = view_as<XenoLabSecurity>(victim);
	
	if(attacker <= 0)
		return Plugin_Continue;
	
	if(npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	if(npc.m_bIsLabVersion && !npc.Anger)
	{
		int health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
		int maxhealth = ReturnEntityMaxHealth(npc.index);
		
		if(health < (maxhealth * SECURITY_ENRAGE_THRESHOLD))
		{
			npc.Anger = true;
			Security_EnterEnrageMode(npc);
		}
	}
	
	return Plugin_Changed;
}

void Security_EnterEnrageMode(XenoLabSecurity npc)
{
	SetEntityRenderColor(npc.index, 255, 0, 0, 255);
	SetEntityRenderColor(npc.m_iWearable1, 255, 0, 0, 255);
	SetEntityRenderColor(npc.m_iWearable2, 255, 0, 0, 255);
	SetEntityRenderColor(npc.m_iWearable3, 255, 0, 0, 255);
	SetEntityRenderColor(npc.m_iWearable4, 255, 0, 0, 255);
	
	npc.m_flSpeed = 280.0;
	
	float pos[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
	
	spawnRing_Vectors(pos, 0.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 0, 0, 255, 1, 1.0, 8.0, 12.0, 1, 300.0);
	spawnRing_Vectors(pos, 0.0, 0.0, 0.0, 30.0, "materials/sprites/laserbeam.vmt", 255, 0, 0, 255, 1, 1.0, 8.0, 12.0, 1, 300.0);
	spawnRing_Vectors(pos, 0.0, 0.0, 0.0, 60.0, "materials/sprites/laserbeam.vmt", 255, 0, 0, 255, 1, 1.0, 8.0, 12.0, 1, 300.0);
	
	npc.PlayAngerSound();
	
	CPrintToChatAll("{red}[CRITICAL WARNING]");
	CPrintToChatAll("{crimson}Xeno Lab Security{default}: DAMAGE THRESHOLD EXCEEDED. ACTIVATING EMERGENCY PROTOCOLS.");
	CPrintToChatAll("{crimson}Xeno Lab Security{default}: ALL SAFETY LIMITERS REMOVED.");
	
	EmitSoundToAll("weapons/physcannon/energy_bounce2.wav", npc.index, _, 90, _, 0.8);
}

public void XenoLabSecurity_NPCDeath(int entity)
{
	XenoLabSecurity npc = view_as<XenoLabSecurity>(entity);
	
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();
	}
	
	// Remove cosmetics
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	
	if(npc.m_bIsLabVersion)
	{
		CPrintToChatAll("{crimson}Xeno Lab Security{default}: CRITICAL SYSTEM FAILURE... CONTAINMENT... BREACH...");
		CPrintToChatAll("{green}[CONTAINMENT BREACH - SECURITY SYSTEMS OFFLINE]");
	}
	else
	{
		CPrintToChatAll("{green}Xeno Security{default}: Termination failed.... report.. status.. {green}relay complete.");
		CPrintToChatAll("{green}[SECURITY UNIT DESTROYED]");
	}
}
