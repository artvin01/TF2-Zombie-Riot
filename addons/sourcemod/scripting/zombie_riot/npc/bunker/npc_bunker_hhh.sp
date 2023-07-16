#pragma semicolon 1
#pragma newdecls required

static char g_DeathScream[][] = {
	"vo/halloween_boss/knight_dying.mp3",
};

static char g_DeathSounds[][] = {
	"vo/halloween_boss/knight_death01.mp3",
	"vo/halloween_boss/knight_death02.mp3",
};

static char g_HurtSounds[][] = {
	"vo/halloween_boss/knight_pain01.mp3",
	"vo/halloween_boss/knight_pain02.mp3",
	"vo/halloween_boss/knight_pain03.mp3",
};

static char g_SpookEm[][] = {
	"vo/halloween_boss/knight_alert.mp3",
};

static char g_IdleSounds[][] = {
	"vo/halloween_boss/knight_alert01.mp3",
	"vo/halloween_boss/knight_alert02.mp3",
};

static char g_IdleAlertedSounds[][] = {
	"vo/halloween_boss/knight_laugh01.mp3",
	"vo/halloween_boss/knight_laugh02.mp3",
	"vo/halloween_boss/knight_laugh03.mp3",
};

static char g_MeleeHitSounds[][] = {
	"vo/halloween_boss/knight_attack01.mp3",
	"vo/halloween_boss/knight_attack02.mp3",
	"vo/halloween_boss/knight_attack03.mp3",
	"vo/halloween_boss/knight_attack04.mp3",
};

static char g_MeleeAttackSounds[][] = {
	"weapons/slap_hit1.wav",
};

static char g_MeleeMissSounds[][] = {
	"weapons/cbar_miss1.wav",
};

static char g_HeIsAwake[][] = {
	"vo/halloween_boss/knight_spawn.mp3",
};

static bool WakeTheFUCKUp[MAXENTITIES];
static bool TimeToScare[MAXENTITIES];
static float IllScareYouToDeath[MAXENTITIES];
static float Resetspeed[MAXENTITIES];

public void BunkerHeadlessHorse_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathScream));	   i++) { PrecacheSound(g_DeathScream[i]);	   }
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_SpookEm));   i++) { PrecacheSound(g_SpookEm[i]);   }
	for (int i = 0; i < (sizeof(g_HeIsAwake));   i++) { PrecacheSound(g_HeIsAwake[i]);   }
	PrecacheModel("models/bots/headless_hatman.mdl");
	PrecacheSound("ui/halloween_boss_defeated.wav");
	PrecacheSound("ui/halloween_boss_chosen_it.wav");
}

methodmap BunkerHeadlessHorse < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBunkerHeadlessHorse::PlayIdleSound()");
		#endif
	}
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBunkerHeadlessHorse::PlayIdleAlertSound()");
		#endif
	}
	public void PlaySpookEm() {
		
		EmitSoundToAll(g_SpookEm[GetRandomInt(0, sizeof(g_SpookEm) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBunkerHeadlessHorse::PlaySpookEm()");
		#endif
	}
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBunkerHeadlessHorse::PlayHurtSound()");
		#endif
	}
	public void PlayDeathScream() {
	
		EmitSoundToAll(g_DeathScream[GetRandomInt(0, sizeof(g_DeathScream) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBunkerHeadlessHorse::PlayDeathSound()");
		#endif
	}
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBunkerHeadlessHorse::PlayDeathSound()");
		#endif
	}
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBunkerHeadlessHorse::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBunkerHeadlessHorse::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBunkerHeadlessHorse::PlayMeleeMissSound()");
		#endif
	}
	public void PlayHeIsAwake() {
		EmitSoundToAll(g_HeIsAwake[GetRandomInt(0, sizeof(g_HeIsAwake) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBunkerHeadlessHorse::PlayHeIsAwakeSound()");
		#endif
	}
	
	public BunkerHeadlessHorse(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		BunkerHeadlessHorse npc = view_as<BunkerHeadlessHorse>(CClotBody(vecPos, vecAng, "models/bots/headless_hatman.mdl", "1.0", "3000", ally, false));
		
		i_NpcInternalId[npc.index] = BUNKER_HEADLESSHORSE;
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);

		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		npc.m_bDoSpawnGesture = true;
		WakeTheFUCKUp[npc.index] = false;
		TimeToScare[npc.index] = false;
		
		IllScareYouToDeath[npc.index] = 25.0 + GetGameTime(npc.index);
		Resetspeed[npc.index] = 999.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flSpeed = 300.0;
		npc.m_flDoSpawnGesture = GetGameTime(npc.index) + 2.0;
		
		
		SDKHook(npc.index, SDKHook_Think, BunkerHeadlessHorse_ClotThink);
		
		npc.StartPathing();
		
		return npc;
	}
}

//TODO 
//Rewrite
public void BunkerHeadlessHorse_ClotThink(int iNPC)
{
	BunkerHeadlessHorse npc = view_as<BunkerHeadlessHorse>(iNPC);
	
//	PrintToChatAll("%.f",GetEntPropFloat(view_as<int>(iNPC), Prop_Data, "m_speed"));
	npc.Update();
	
	if(npc.m_bDoSpawnGesture)
	{
		npc.AddGesture("ACT_TRANSITION");
		npc.m_bDoSpawnGesture = false;
		npc.PlayHeIsAwake();
//		WakeTheFUCKUp[npc.index] = true && GetGameTime(npc.index) + 6.0;
		npc.m_flRangedArmor = 0.0;
		npc.m_flMeleeArmor = 0.0;
	}
	
	if(npc.m_flDoSpawnGesture > GetGameTime(npc.index))
	{
		npc.DispatchParticleEffect(npc.index, "utaunt_portalswirl_purple_parent", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("head"), PATTACH_POINT_FOLLOW, true);
		npc.DispatchParticleEffect(npc.index, "utaunt_lightning_bolt", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("head"), PATTACH_POINT_FOLLOW, true);
		npc.DispatchParticleEffect(npc.index, "utaunt_lightning_bolt", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("head"), PATTACH_POINT_FOLLOW, true);
		npc.m_flSpeed = 0.0;
		return;
	}
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	if(WakeTheFUCKUp[npc.index])//this is only there so he can actually move
	{
		WakeTheFUCKUp[npc.index] = false;
		npc.m_flSpeed = 300.0;
		npc.m_flRangedArmor = 1.0;
		npc.m_flMeleeArmor = 1.0;
	}
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.m_blPlayHurtAnimation = false;
		npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	
	if(IllScareYouToDeath[npc.index] <= GetGameTime(npc.index) && !TimeToScare[npc.index])
	{
		npc.AddGesture("ACT_MP_GESTURE_VC_HANDMOUTH_ITEM1");
		npc.m_flSpeed = 0.0;
		IllScareYouToDeath[npc.index] = GetGameTime(npc.index) + 25.0;
		TimeToScare[npc.index] = true;
		Resetspeed[npc.index] = GetGameTime(npc.index) + 1.2;
		npc.PlaySpookEm();
		for(int client = 1; client <= MaxClients; client++)
		{
			if(IsValidClient(client))
			{
				TF2_StunPlayer(client, 3.5, _, TF_STUNFLAGS_GHOSTSCARE, 0);
			}
		}
	}
	
	if(Resetspeed[npc.index] <= GetGameTime(npc.index) && TimeToScare[npc.index])
	{
		npc.m_flSpeed = 300.0;
		TimeToScare[npc.index] = false;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
		npc.StartPathing();
		//PluginBot_NormalJump(npc.index);
	}
	
	int closest = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, closest))
	{
		float vecTarget[3]; vecTarget = WorldSpaceCenter(closest);
		
		float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
		
		//EmitSoundToAll("ui/halloween_boss_chosen_it.wav", closest)
		
		if(flDistanceToTarget < npc.GetLeadRadius()) //Predict their pos.
		{
			float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, closest);
			NPC_SetGoalVector(npc.index, vPredictedPos);
		}
		else
		{
			NPC_SetGoalEntity(npc.index, closest);
		}
		if(flDistanceToTarget < 10000 || npc.m_flAttackHappenswillhappen) //Target close enough to hit
		{
			//Look at target so we hit.
			//npc.FaceTowards(vecTarget, 20000.0);
			if(npc.m_flNextMeleeAttack < GetGameTime(npc.index))
			{
				if (!npc.m_flAttackHappenswillhappen)//Play attack anims
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
					//npc.PlayMeleeSound();
					npc.m_flAttackHappens = GetGameTime(npc.index)+0.30;
					npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.75;
					npc.m_flAttackHappenswillhappen = true;
				}
				//Can we attack right now?
				if (npc.m_flAttackHappens < GetGameTime(npc.index) && npc.m_flAttackHappens_bullshit >= GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					Handle swingTrace;
					npc.FaceTowards(vecTarget, 20000.0);
					if(npc.DoSwingTrace(swingTrace, closest))
					{
						int target = TR_GetEntityIndex(swingTrace);	
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);
						if(target > 0) 
						{
							if(EscapeModeForNpc)
							{
								if(target <= MaxClients)
									SDKHooks_TakeDamage(target, npc.index, npc.index, 65.0, DMG_CLUB, -1, _, vecHit);
								else
									SDKHooks_TakeDamage(target, npc.index, npc.index, 85.0, DMG_CLUB, -1, _, vecHit);
							}
							else
							{
								if(target <= MaxClients)
									SDKHooks_TakeDamage(target, npc.index, npc.index, 50.0, DMG_CLUB, -1, _, vecHit);
								else
									SDKHooks_TakeDamage(target, npc.index, npc.index, 80.0, DMG_CLUB, -1, _, vecHit);					
							}
							npc.PlayMeleeSound();
							npc.PlayMeleeHitSound();
						}
						else
						{
							npc.PlayMeleeMissSound();
						}
					}
					delete swingTrace;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.75;
					npc.m_flAttackHappenswillhappen = false;
				}
				else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					npc.m_flAttackHappenswillhappen = false;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.75;
				}
			}
		}
	}
	else
	{
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleSound();
}

public Action BunkerHeadlessHorse_OnTakeDamage(int iNPC, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	BunkerHeadlessHorse npc = view_as<BunkerHeadlessHorse>(iNPC);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
//	
	return Plugin_Changed;
}

public void BunkerHeadlessHorse_NPCDeath(int entity)
{
	BunkerHeadlessHorse npc = view_as<BunkerHeadlessHorse>(entity);
	SDKHooks_TakeDamage(entity, 0, 0, 999999999.0, DMG_GENERIC);
	npc.PlayDeathScream();
	SDKUnhook(entity, SDKHook_Think, BunkerHeadlessHorse_ClotThink);
	
	int entity_death = CreateEntityByName("prop_dynamic_override");
	if(IsValidEntity(entity_death))
	{
		float pos[3];
		float Angles[3];
		GetEntPropVector(entity, Prop_Data, "m_angRotation", Angles);

		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
		TeleportEntity(entity_death, pos, Angles, NULL_VECTOR);
		
//		GetEntPropString(client, Prop_Data, "m_ModelName", model, sizeof(model));
		DispatchKeyValue(entity_death, "model", "models/bots/headless_hatman.mdl");

		DispatchSpawn(entity_death);
		
		SetEntPropFloat(entity_death, Prop_Send, "m_flModelScale", 1.0); 
		SetEntityCollisionGroup(entity_death, 2);
		SetVariantString("shake");//ACT_DIESIMPLE
		AcceptEntityInput(entity_death, "SetAnimation");
		
		pos[2] += 20.0;
		
		CreateTimer(2.0, Timer_RemoveEntityHeadless, EntIndexToEntRef(entity_death), TIMER_FLAG_NO_MAPCHANGE);
	}
//	AcceptEntityInput(npc.index, "KillHierarchy");
}

public Action Timer_RemoveEntityHeadless(Handle timer, any entid)
{
	int entity = EntRefToEntIndex(entid);
	BunkerHeadlessHorse npc = view_as<BunkerHeadlessHorse>(entity);
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		float pos[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
		TE_Particle("skull_island_explosion", pos, NULL_VECTOR, NULL_VECTOR, entity, _, _, _, _, _, _, _, _, _, 0.0);
		EmitSoundToAll("ui/halloween_boss_defeated.wav");
//		TeleportEntity(entity, OFF_THE_MAP, NULL_VECTOR, NULL_VECTOR); // send it away first in case it feels like dying dramatically
		npc.PlayDeathSound();
		RemoveEntity(entity);
	}
	return Plugin_Handled;
}