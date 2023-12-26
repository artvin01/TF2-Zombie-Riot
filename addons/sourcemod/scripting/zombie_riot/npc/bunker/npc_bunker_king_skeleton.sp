#pragma semicolon 1
#pragma newdecls required

static char g_DeathSounds[][] = {
	")misc/halloween/skeleton_break.wav",
};

static char g_HurtSounds[][] = {
	"npc/fast_zombie/wake1.wav",
};

static char g_IdleSounds[][] = {
	")misc/halloween/skeletons/skelly_giant_01.wav",
};

static char g_IdleAlertedSounds[][] = {
	")misc/halloween/skeletons/skelly_giant_02.wav",
};

static char g_MeleeHitSounds[][] = {
	")misc/halloween/skeletons/skelly_giant_03.wav",
};
static char g_MeleeAttackSounds[][] = {
	"weapons/3rd_degree_hit_01.wav",
	"weapons/axe_hit_flesh1.wav",
	"weapons/slap_hit1.wav",
};

static char g_MeleeMissSounds[][] = {
	"weapons/cbar_miss1.wav",
};

static char g_HeIsAwake[][] = {
	")misc/halloween/spell_skeleton_horde_rise.wav",
};

static char g_ISummonedThem[][] = {
	")misc/halloween/spell_skeleton_horde_cast.wav",
};
static float SummonYourMinions[MAXENTITIES];
static bool WakeTheFUCKUp[MAXENTITIES];
static bool YourMinionHasBeenSummoned[MAXENTITIES];

public void BunkerSkeletonKing_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_HeIsAwake));   i++) { PrecacheSound(g_HeIsAwake[i]);   }
	for (int i = 0; i < (sizeof(g_ISummonedThem));   i++) { PrecacheSound(g_ISummonedThem[i]);   }
	PrecacheModel("models/bots/skeleton_sniper_boss/skeleton_sniper_boss.mdl");
}

methodmap BunkerSkeletonKing < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBunkerSkeleton::PlayIdleSound()");
		#endif
	}
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBunkerSkeleton::PlayIdleAlertSound()");
		#endif
	}
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBunkerSkeleton::PlayHurtSound()");
		#endif
	}
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBunkerSkeleton::PlayDeathSound()");
		#endif
	}
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBunkerSkeleton::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBunkerSkeleton::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBunkerSkeleton::PlayMeleeMissSound()");
		#endif
	}
	public void PlayHeIsAwake() {
		EmitSoundToAll(g_HeIsAwake[GetRandomInt(0, sizeof(g_HeIsAwake) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBunkerSkeleton::PlayHeIsAwakeSound()");
		#endif
	}
	public void PlayISummonedThem() {
		EmitSoundToAll(g_HeIsAwake[GetRandomInt(0, sizeof(g_HeIsAwake) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBunkerSkeleton::PlayHeIsAwakeSound()");
		#endif
	}
	
	public BunkerSkeletonKing(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		BunkerSkeletonKing npc = view_as<BunkerSkeletonKing>(CClotBody(vecPos, vecAng, "models/bots/skeleton_sniper_boss/skeleton_sniper_boss.mdl", "1.7", "30000", ally, false));
		
		i_NpcInternalId[npc.index] = BUNKER_KING_SKELETON;
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_bDoSpawnGesture = true;
		
		WakeTheFUCKUp[npc.index] = false;
		YourMinionHasBeenSummoned[npc.index] = false;
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		npc.Anger = false;
		SummonYourMinions[npc.index] = GetGameTime(npc.index) + 10.0;
		npc.m_flDoSpawnGesture = GetGameTime(npc.index) + 2.0;
		//IDLE
		npc.m_flSpeed = 250.0;
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/player/items/demo/crown.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		//SetEntityRenderMode(npc.m_iWearable5, RENDER_TRANSCOLOR);
		//SetEntityRenderColor(npc.m_iWearable5, 255, 255, 255, 255);
		
		
		SDKHook(npc.index, SDKHook_Think, BunkerSkeletonKing_ClotThink);
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, BunkerSkeletonKing_ClotDamaged_Post);
		
		npc.StartPathing();
		
		return npc;
	}
}

//TODO 
//Rewrite
public void BunkerSkeletonKing_ClotThink(int iNPC)
{
	BunkerSkeletonKing npc = view_as<BunkerSkeletonKing>(iNPC);
	
//	PrintToChatAll("%.f",GetEntPropFloat(view_as<int>(iNPC), Prop_Data, "m_speed"));
	npc.Update();
	
	if(npc.m_bDoSpawnGesture)
	{
		npc.AddGesture("ACT_TRANSITION");
		npc.m_bDoSpawnGesture = false;
		npc.PlayHeIsAwake();
//		WakeTheFUCKUp[npc.index] = true && GetGameTime(npc.index) + 4.0;
	}
	
	if(npc.m_flDoSpawnGesture > GetGameTime(npc.index))
	{
		npc.m_flSpeed = 0.0;
		return;
	}
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	if(WakeTheFUCKUp[npc.index])
	{
		WakeTheFUCKUp[npc.index] = false;
		npc.m_flSpeed = 300.0;
	}
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.m_blPlayHurtAnimation = false;
		if(!npc.m_flAttackHappenswillhappen)
			npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	
	if(SummonYourMinions[npc.index] <= GetGameTime(npc.index) && !YourMinionHasBeenSummoned[npc.index])
	{
		SummonYourMinions[npc.index] = GetGameTime(npc.index) + 10.0;
		npc.AddGesture("ACT_SPECIAL_ATTACK");
		npc.PlayISummonedThem();
		switch(GetRandomInt(1, 2)) //can add more minions if needed
		{
			case 1:
			{
				int maxhealth = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");
				float startPosition[3];
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", startPosition);
				maxhealth /= 4;
				for(int i; i<1; i++)
				{
					float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
					float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
		
					int spawn_index = Npc_Create(BUNKER_SKELETON, -1, pos, ang, GetEntProp(npc.index, Prop_Send, "m_iTeamNum") == 2);
					if(spawn_index > MaxClients)
					{
						Zombies_Currently_Still_Ongoing += 1;
						SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
						SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
					}
				}
			}
			case 2:
			{
				int maxhealth = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");
				float startPosition[3];
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", startPosition);
				maxhealth /= 6;
				for(int i; i<1; i++)
				{
					float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
					float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
		
					int spawn_index = Npc_Create(BUNKER_SMALL_SKELETON, -1, pos, ang, GetEntProp(npc.index, Prop_Send, "m_iTeamNum") == 2);
					if(spawn_index > MaxClients)
					{
						Zombies_Currently_Still_Ongoing += 1;
						SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
						SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
					}
				}
			}
		}
	//	YourMinionHasBeenSummoned[npc.index] = false && GetGameTime(npc.index) + 9.0;
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
					npc.m_flAttackHappens = GetGameTime(npc.index)+0.53;
					npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.83;
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
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 1.2;
					npc.m_flAttackHappenswillhappen = false;
				}
				else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					npc.m_flAttackHappenswillhappen = false;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 1.2;
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

public Action Set_BunkerSkeletonKing_HP(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(entity>MaxClients && IsValidEntity(entity))
	{
		SetEntProp(entity, Prop_Data, "m_iHealth", (GetEntProp(entity, Prop_Data, "m_iMaxHealth") / 2));
	}
	return Plugin_Stop;
}

public void BunkerSkeletonKing_ClotDamaged_Post(int iNPC, int attacker, int inflictor, float damage, int damagetype)
{
	BunkerSkeletonKing npc = view_as<BunkerSkeletonKing>(iNPC);
	if((GetEntProp(npc.index, Prop_Data, "m_iMaxHealth") / 2 )>= GetEntProp(npc.index, Prop_Data, "m_iHealth") && !npc.Anger) //npc.Anger after half hp/400 hp
	{
		npc.Anger = true; //	>:( your mother
		int skin = 3;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		npc.m_flSpeed = 310.0;
		//for(int client = 1; client <= MaxClients; client++)
		//{
		//	if(IsValidClient(client))
		//	{
		//		ClientCommand(client, "r_screenoverlay freak_fortress_2/corruptedspy/corruptedspy_rageoverlay1");
		//		SetVariantString("HalloweenLongFall");
		//		AcceptEntityInput(client, "SpeakResponseConcept");
		//	}
	}
}

public Action BunkerSkeletonKing_OnTakeDamage(int iNPC, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	BunkerSkeleton npc = view_as<BunkerSkeleton>(iNPC);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
//	
	return Plugin_Changed;
}

public void BunkerSkeletonKing_NPCDeath(int entity)
{
	BunkerSkeletonKing npc = view_as<BunkerSkeletonKing>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	SDKHooks_TakeDamage(entity, 0, 0, 999999999.0, DMG_GENERIC);
	SDKUnhook(entity, SDKHook_OnTakeDamagePost, BunkerSkeletonKing_ClotDamaged_Post);
	SDKUnhook(entity, SDKHook_Think, BunkerSkeletonKing_ClotThink);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
//	AcceptEntityInput(npc.index, "KillHierarchy");
}


