#pragma semicolon 1
#pragma newdecls required

static int i_LastStandBossRef;

enum
{
	APERTURE_BOSS_NONE = 0,
	APERTURE_BOSS_CAT = (1 << 0),
	APERTURE_BOSS_ARIS = (1 << 1),
	APERTURE_BOSS_CHIMERA = (1 << 2),
	APERTURE_BOSS_VINCENT = (1 << 3),
}

enum
{
	APERTURE_LAST_STAND_STATE_STARTING,
	APERTURE_LAST_STAND_STATE_ALMOST_HAPPENING,
	APERTURE_LAST_STAND_STATE_HAPPENING,
	APERTURE_LAST_STAND_STATE_SPARED,
	APERTURE_LAST_STAND_STATE_KILLED,
}

int i_ApertureBossesDead = APERTURE_BOSS_NONE;
static float fl_PlayerDamage[MAXPLAYERS];
static float fl_MaxDamagePerPlayer;

#define APERTURE_LAST_STAND_TIMER_TOTAL 20.0
#define APERTURE_LAST_STAND_TIMER_INVULN 5.0
#define APERTURE_LAST_STAND_TIMER_BEFORE_INVULN 2.5

#define APERTURE_LAST_STAND_HEALTH_MULT 0.05

#define APERTURE_LAST_STAND_EXPLOSION_PARTICLE "fluidSmokeExpl_ring"

static const char g_ApertureSharedStunStartSound[] = "ui/mm_door_open.wav";
static const char g_ApertureSharedStunMainSound[] = "mvm/mvm_robo_stun.wav";
static const char g_ApertureSharedStunTeleportSound[] = "weapons/teleporter_send.wav";
static const char g_ApertureSharedStunExplosionSound[] = "mvm/mvm_tank_explode.wav";

void Aperture_Shared_OnMapStart()
{
	PrecacheSound(g_ApertureSharedStunStartSound);
	PrecacheSound(g_ApertureSharedStunMainSound);
	PrecacheSound(g_ApertureSharedStunTeleportSound);
	PrecacheSound(g_ApertureSharedStunExplosionSound);
	
	PrecacheParticleSystem(APERTURE_LAST_STAND_EXPLOSION_PARTICLE);
	
	i_ApertureBossesDead = APERTURE_BOSS_NONE;
	i_LastStandBossRef = INVALID_ENT_REFERENCE;
}

void Aperture_Shared_LastStandSequence_Starting(CClotBody npc)
{
	float gameTime = GetGameTime();
	
	SetEntProp(npc.index, Prop_Data, "m_iHealth", 1);
	
	ApplyStatusEffect(npc.index, npc.index, "Last Stand", FAR_FUTURE);
	ApplyStatusEffect(npc.index, npc.index, "Solid Stance", FAR_FUTURE);
	
	ReviveAll(true);
	
	if (npc.m_iState == APERTURE_BOSS_CHIMERA)
	{
		npc.SetActivity("ACT_MP_STAND_LOSERSTATE");
		
		if(IsValidEntity(npc.m_iWearable5))
			RemoveEntity(npc.m_iWearable5);
	}
	else
	{
		npc.SetActivity("ACT_MP_STUN_MIDDLE");
		npc.AddGesture("ACT_MP_STUN_BEGIN");
		
		if(IsValidEntity(npc.m_iWearable2))
			RemoveEntity(npc.m_iWearable2);
		
		if(IsValidEntity(npc.m_iWearable1))
			RemoveEntity(npc.m_iWearable1);
	}
	
	npc.SetPlaybackRate(0.0);
	
	b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true; //Make allied npcs ignore him.
	b_NpcIsInvulnerable[npc.index] = true;
	
	npc.m_bDissapearOnDeath = true;
	npc.m_flSpeed = 0.0;
	npc.m_bisWalking = false;
	npc.StopPathing();
	
	npc.m_flArmorCount = 0.0;
	
	RaidModeScaling = 0.0;
	RaidModeTime = gameTime + APERTURE_LAST_STAND_TIMER_TOTAL;
	if(CurrentModifOn() == 1)
	{
		RaidModeTime = FAR_FUTURE;
	}
	EmitSoundToAll(g_ApertureSharedStunStartSound, npc.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, 90, BOSS_ZOMBIE_VOLUME, 85);
	
	npc.m_flNextThinkTime = gameTime + APERTURE_LAST_STAND_TIMER_BEFORE_INVULN;
	
	func_NPCDeath[npc.index] = Aperture_Shared_LastStandSequence_NPCDeath;
	func_NPCOnTakeDamage[npc.index] = Aperture_Shared_LastStandSequence_OnTakeDamage;
	func_NPCThink[npc.index] = Aperture_Shared_LastStandSequence_ClotThink;
	
	npc.m_iAnimationState = APERTURE_LAST_STAND_STATE_STARTING;
	
	i_LastStandBossRef = EntIndexToEntRef(npc.index);
}

static void Aperture_Shared_LastStandSequence_AlmostHappening(CClotBody npc)
{
	int healthToSet = RoundToNearest(ReturnEntityMaxHealth(npc.index) * APERTURE_LAST_STAND_HEALTH_MULT);
	SetEntProp(npc.index, Prop_Data, "m_iHealth", healthToSet);
	
	fl_MaxDamagePerPlayer = (healthToSet * 2.0) / CountPlayersOnRed();
	for (int i = 0; i < sizeof(fl_PlayerDamage); i++)
		fl_PlayerDamage[i] = 0.0;
	
	EmitSoundToAll(g_ApertureSharedStunMainSound, npc.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, 90, BOSS_ZOMBIE_VOLUME, 85);
	
	float vecPos[3];
	GetAbsOrigin(npc.index, vecPos);
	vecPos[2] += 160.0; // hardcoded lollium!
	
	for (int client = 1; client <= MaxClients; client++)
	{
		if (!IsClientInGame(client) || IsFakeClient(client))
			continue;
		
		bool chaos = CurrentModifOn() == 1;
		
		Event event = CreateEvent("show_annotation");
		if (event)
		{
			char message[255], prefix[255], name[64];
			StatusEffects_PrefixName(npc.index, client, prefix, sizeof(prefix));
			
			FormatEx(name, sizeof(name), "%T", c_NpcName[npc.index], client);
			
			if (!chaos)
				FormatEx(message, sizeof(message), "Choose to spare or kill %s%s!\nYou DO NOT have to kill it to proceed!", prefix, name);
			else
				FormatEx(message, sizeof(message), "Kill %s%s.", prefix, name);
			
			event.SetInt("visibilityBitfield", (1 << client));
			event.SetFloat("worldPosX", vecPos[0]);
			event.SetFloat("worldPosY", vecPos[1]);
			event.SetFloat("worldPosZ", vecPos[2]);
			event.SetFloat("lifetime", APERTURE_LAST_STAND_TIMER_TOTAL);
			event.SetString("text", message);
			event.SetString("play_sound", "vo/null.mp3");
			event.SetInt("id", npc.index); //What to enter inside? Need a way to identify annotations by entindex!
			event.FireToClient(client);
			event.Cancel();
		}
	}
	
	RemoveAllBuffs(npc.index, true, false);
	NPCStats_RemoveAllDebuffs(npc.index);
	
	npc.m_iAnimationState = APERTURE_LAST_STAND_STATE_ALMOST_HAPPENING;
}

static void Aperture_Shared_LastStandSequence_Happening(CClotBody npc)
{
	b_NpcIsInvulnerable[npc.index] = false; // NPCs should still not target this boss
	npc.m_iAnimationState = APERTURE_LAST_STAND_STATE_HAPPENING;
}

// Shared NPC functions

public void Aperture_Shared_LastStandSequence_ClotThink(int entity)
{
	CClotBody npc = view_as<CClotBody>(entity);
	float gameTime = GetGameTime();
	
	if (IsValidEntity(RaidBossActive) && RaidModeTime < gameTime)
	{
		// Boss was spared!
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		npc.m_iAnimationState = APERTURE_LAST_STAND_STATE_SPARED;
		RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
		
		return;
	}
	
	npc.Update();
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	if (npc.m_iAnimationState == APERTURE_LAST_STAND_STATE_STARTING)
	{
		Aperture_Shared_LastStandSequence_AlmostHappening(npc);
		npc.m_flNextThinkTime = gameTime + APERTURE_LAST_STAND_TIMER_INVULN - APERTURE_LAST_STAND_TIMER_BEFORE_INVULN;
		return;
	}
	
	if (npc.m_iAnimationState == APERTURE_LAST_STAND_STATE_ALMOST_HAPPENING)
	{
		Aperture_Shared_LastStandSequence_Happening(npc);
		npc.m_flNextThinkTime = gameTime + 1.0;
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 1.0;
}

public Action Aperture_Shared_LastStandSequence_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	// Don't bother on Chaos Intrusion
	if (CurrentModifOn() == 1)
		return Plugin_Continue;
	
	// We're massively reducing damage if players dealt too much damage to bosses in the spare/kill sequence
	const float damageReduction = 0.025;
	
	if (attacker <= 0 || attacker > MaxClients)
	{
		// If somehow, something that isn't a player attacked the boss, lower the damage at all times
		damage *= damageReduction;
		return Plugin_Changed;
	}
	
	// They just reached the threshold, account for the remainder
	if (fl_PlayerDamage[attacker] < fl_MaxDamagePerPlayer && fl_PlayerDamage[attacker] + damage > fl_MaxDamagePerPlayer)
	{
		float fullDamage = fl_MaxDamagePerPlayer - fl_PlayerDamage[attacker];
		float remainder = (damage - fullDamage) * damageReduction;
		damage = fullDamage + remainder;
	}
	else if (fl_PlayerDamage[attacker] >= fl_MaxDamagePerPlayer)
	{
		damage *= damageReduction;
	}
	
	fl_PlayerDamage[attacker] += damage;
	return Plugin_Changed;
}

public void Aperture_Shared_LastStandSequence_NPCDeath(int entity)
{
	CClotBody npc = view_as<CClotBody>(entity);
	
	float vecPos[3];
	WorldSpaceCenter(npc.index, vecPos);
	if (npc.m_iAnimationState != APERTURE_LAST_STAND_STATE_SPARED)
	{
		// Boss was killed!
		EmitSoundToAll(g_ApertureSharedStunExplosionSound, npc.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, 90, BOSS_ZOMBIE_VOLUME, 85);
		ParticleEffectAt(vecPos, APERTURE_LAST_STAND_EXPLOSION_PARTICLE, 0.5);
		
		i_ApertureBossesDead |= npc.m_iState;
		npc.m_iAnimationState = APERTURE_LAST_STAND_STATE_KILLED;
	}
	else
	{
		EmitSoundToAll(g_ApertureSharedStunTeleportSound, npc.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, 90, BOSS_ZOMBIE_VOLUME, 85);
		ParticleEffectAt(vecPos, "teleported_blue", 0.5);
	}
	
	Event event = CreateEvent("hide_annotation");
	if (event)
	{
		event.SetInt("id", npc.index);
		event.Fire();
	}
	
	StopSound(npc.index, SNDCHAN_AUTO, g_ApertureSharedStunMainSound);
	i_LastStandBossRef = INVALID_ENT_REFERENCE;
	
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
	if(IsValidEntity(npc.m_iWearable8))
		RemoveEntity(npc.m_iWearable8);
}

bool Aperture_ShouldDoLastStand()
{
	return StrContains(WhatDifficultySetting_Internal, "Laboratories") == 0;
}

int Aperture_GetLastStandBoss()
{
	return i_LastStandBossRef;
}

bool Aperture_IsBossDead(int type)
{
	return (i_ApertureBossesDead & type) != 0;
}