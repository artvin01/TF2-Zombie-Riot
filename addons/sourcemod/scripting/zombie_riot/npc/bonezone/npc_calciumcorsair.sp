#pragma semicolon 1
#pragma newdecls required

#define BONES_PIRATE_HP			"2000"
#define BONES_PIRATE_HP_BUFFED	"4000"

#define BONES_PIRATE_SKIN		"2"
#define BONES_PIRATE_SKIN_BUFFED	"0"

#define BONES_PIRATE_SCALE		 "1.0"
#define BONES_PIRATE_SCALE_BUFFED "1.2"

#define BONES_PIRATE_RAMPAGEPARTICLE	"utaunt_glitter_teamcolor_red"

static float BONES_PIRATE_SPEED = 220.0;
static float BONES_PIRATE_SPEED_BUFFED = 260.0;
static float BONES_PIRATE_SPEED_BUFFED_RAMPAGE = 400.0;
static float PIRATE_NATURAL_BUFF_CHANCE = 0.1;	//Percentage chance for non-buffed skeletons of this type to be naturally buffed instead.
static float PIRATE_NATURAL_BUFF_LEVEL_MODIFIER = 0.1;	//Max percentage increase for natural buff chance based on the average level of all players in the lobby, relative to natural_buff_level.
static float PIRATE_NATURAL_BUFF_LEVEL = 100.0;	//The average level at which level_modifier reaches its max.

static float BONES_PIRATE_PLAYERDAMAGE = 60.0;
static float BONES_PIRATE_PLAYERDAMAGE_BUFFED = 90.0;
static float BONES_PIRATE_PLAYERDAMAGE_BUFFED_RAMPAGE = 90.0;

static float BONES_PIRATE_BUILDINGDAMAGE = 120.0;
static float BONES_PIRATE_BUILDINGDAMAGE_BUFFED = 200.0;
static float BONES_PIRATE_BUILDINGDAMAGE_BUFFED_RAMPAGE = 300.0;

static float BONES_PIRATE_ATTACKINTERVAL = 1.2;
static float BONES_PIRATE_ATTACKINTERVAL_BUFFED = 0.8;
static float BONES_PIRATE_ATTACKINTERVAL_BUFFED_RAMPAGE = 0.25;

static float BONES_PIRATE_RAMPAGE_THRESHOLD = 0.4;		//HP threshold at which the buffed variant enters a rampage state.

static char g_DeathSounds[][] = {
	")misc/halloween/skeleton_break.wav",
};

static char g_HurtSounds[][] = {
	")zombie_riot/the_bone_zone/skeleton_hurt.mp3",
};

static char g_IdleSounds[][] = {
	")misc/halloween/skeletons/skelly_medium_01.wav",
	")misc/halloween/skeletons/skelly_medium_02.wav",
	")misc/halloween/skeletons/skelly_medium_03.wav",
	")misc/halloween/skeletons/skelly_medium_04.wav",
};

static char g_IdleAlertedSounds[][] = {
	")misc/halloween/skeletons/skelly_medium_05.wav",
};

static char g_MeleeHitSounds[][] = {
	")weapons/grappling_hook_impact_flesh.wav",
};

static char g_MeleeAttackSounds[][] = {
	"player/cyoa_pda_fly_swoosh.wav",
};

static char g_MeleeMissSounds[][] = {
	"misc/blank.wav",
};

static char g_HeIsAwake[][] = {
	"physics/concrete/concrete_break2.wav",
	"physics/concrete/concrete_break3.wav",
};

static char g_GibSounds[][] = {
	"items/pumpkin_explode1.wav",
	"items/pumpkin_explode2.wav",
	"items/pumpkin_explode3.wav",
};

static char g_RampageStart[][] = {
	")vo/halloween_boss/knight_pain01.mp3",
	")vo/halloween_boss/knight_pain02.mp3",
	")vo/halloween_boss/knight_pain03.mp3"
};

static char g_RampageEnd[][] = {
	")vo/halloween_boss/knight_alert01.mp3",
	")vo/halloween_boss/knight_alert02.mp3"
};

static bool b_LastAttackWasLeftHand[2049] = { false, ... };
static bool b_PirateRampage[2049] = { false, ... };

public void PirateBones_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_GibSounds));   i++) { PrecacheSound(g_GibSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RampageStart));   i++) { PrecacheSound(g_RampageStart[i]);   }
	for (int i = 0; i < (sizeof(g_RampageEnd));   i++) { PrecacheSound(g_RampageEnd[i]);   }

//	g_iPathLaserModelIndex = PrecacheModel("materials/sprites/laserbeam.vmt");

	PrecacheSound("player/flow.wav");
	PrecacheModel("models/zombie/classic.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Buccaneer Bones");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_calciumcorsair");
	strcopy(data.Icon, sizeof(data.Icon), "pyro");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Common;
	data.Func = Summon_Normal;
	NPC_Add(data);

	NPCData data_buffed;
	strcopy(data_buffed.Name, sizeof(data_buffed.Name), "Calcium Corsair");
	strcopy(data_buffed.Plugin, sizeof(data_buffed.Plugin), "npc_calciumcorsair_buffed");
	strcopy(data_buffed.Icon, sizeof(data_buffed.Icon), "pyro");
	data_buffed.IconCustom = false;
	data_buffed.Flags = 0;
	data_buffed.Category = Type_Common;
	data_buffed.Func = Summon_Buffed;
	NPC_Add(data_buffed);
}

static any Summon_Normal(int client, float vecPos[3], float vecAng[3], int ally)
{
	return PirateBones(client, vecPos, vecAng, ally, false);
}

static any Summon_Buffed(int client, float vecPos[3], float vecAng[3], int ally)
{
	return PirateBones(client, vecPos, vecAng, ally, true);
}

methodmap PirateBones < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CPirateBones::PlayIdleSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, GetRandomInt(80, 110));
		
		#if defined DEBUG_SOUND
		PrintToServer("CPirateBones::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CPirateBones::PlayDeathSound()");
		#endif
	}
	
	public void PlayGibSound() {
	
		EmitSoundToAll(g_GibSounds[GetRandomInt(0, sizeof(g_GibSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CPirateBones::PlayGibSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CPirateBones::PlayMeleeHitSound()");
		#endif
	}

	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CPirateBones::PlayMeleeHitSound()");
		#endif
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayHeIsAwake() {
		EmitSoundToAll(g_HeIsAwake[GetRandomInt(0, sizeof(g_HeIsAwake) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CPirateBones::PlayHeIsAwakeSound()");
		#endif
	}
	
	public void PlayRampageStart() {
		int rand = GetRandomInt(0, sizeof(g_RampageStart) - 1);
		EmitSoundToAll(g_RampageStart[rand], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL);
		EmitSoundToAll(g_RampageStart[rand], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL);
		
		#if defined DEBUG_SOUND
		PrintToServer("CPirateBones::PlayHeIsAwakeSound()");
		#endif
	}

	public void PlayRampageEnd() {
		int rand = GetRandomInt(0, sizeof(g_RampageEnd) - 1);
		EmitSoundToAll(g_RampageEnd[rand], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL);
		EmitSoundToAll(g_RampageEnd[rand], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL);
		
		#if defined DEBUG_SOUND
		PrintToServer("CPirateBones::PlayHeIsAwakeSound()");
		#endif
	}
	
	public PirateBones(int client, float vecPos[3], float vecAng[3], int ally, bool buffed)
	{
		if (!buffed)
		{
			float chance = PIRATE_NATURAL_BUFF_CHANCE;
			if (PIRATE_NATURAL_BUFF_LEVEL_MODIFIER > 0.0)
			{
				float total;
				float players;
				for (int i = 1; i <= MaxClients; i++)
				{
					if (IsClientInGame(i))
					{
						total += float(Level[i]);
						players += 1.0;
					}
				}
				
				float average = total / players;
				float mult = average / PIRATE_NATURAL_BUFF_LEVEL;
				if (mult > 1.0)
					mult = 1.0;
					
				chance += (mult * PIRATE_NATURAL_BUFF_LEVEL_MODIFIER);
			}
			
			buffed = (GetRandomFloat() <= chance);
		}
			
		PirateBones npc = view_as<PirateBones>(CClotBody(vecPos, vecAng, buffed ? "models/zombie_riot/the_bone_zone/basic_bones.mdl" : "models/player/demo.mdl", buffed ? BONES_PIRATE_SCALE_BUFFED : BONES_PIRATE_SCALE, buffed ? BONES_PIRATE_HP_BUFFED : BONES_PIRATE_HP, ally, false));
		
		b_BonesBuffed[npc.index] = buffed;
		b_IsSkeleton[npc.index] = true;
		npc.m_bBoneZoneNaturallyBuffed = buffed;
		g_BoneZoneBuffFunction[npc.index] = view_as<Function>(PirateBones_SetBuffed);

		func_NPCDeath[npc.index] = view_as<Function>(PirateBones_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(PirateBones_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(PirateBones_ClotThink);

		b_PirateRampage[npc.index] = false;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		Pirate_GiveCosmetics(npc, buffed);
		if (b_BonesBuffed[npc.index])
		{
			int iActivity = npc.LookupActivity("ACT_PIRATE_RUN");
			if(iActivity > 0) npc.StartActivity(iActivity);
		}
		
		DispatchKeyValue(npc.index, "skin", buffed ? BONES_PIRATE_SKIN_BUFFED : BONES_PIRATE_SKIN);

		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_SKELETON;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		//IDLE
		npc.m_flSpeed = (buffed ? BONES_PIRATE_SPEED_BUFFED : BONES_PIRATE_SPEED);
		
		SDKHook(npc.index, SDKHook_Think, PirateBones_ClotThink);
		
		npc.m_flDoSpawnGesture = GetGameTime(npc.index) + 2.0;
		
		npc.StartPathing();
		
		return npc;
	}
}

stock void Pirate_GiveCosmetics(CClotBody npc, bool buffed)
{
	npc.RemoveAllWearables();
	
	if (buffed)
	{
		npc.m_iWearable1 = npc.EquipItem("hat", "models/player/items/demo/drinking_hat.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("hat", "models/player/items/sniper/summer_shades.mdl");
		
		float pos[3];
		GetEntPropVector(npc.m_iWearable2, Prop_Data, "m_vecAbsOrigin", pos);
		pos[2] += 10.0;
		TeleportEntity(npc.m_iWearable2, pos);
		
		SetEntPropFloat(npc.index, Prop_Send, "m_fadeMinDist", 9999.0);
		SetEntPropFloat(npc.index, Prop_Send, "m_fadeMaxDist", 9999.0);
		
		DispatchKeyValue(npc.index, "model", "models/zombie_riot/the_bone_zone/basic_bones.mdl");
		view_as<CBaseCombatCharacter>(npc).SetModel("models/zombie_riot/the_bone_zone/basic_bones.mdl");
		
		int iActivity = npc.LookupActivity("ACT_PIRATE_RUN");
		if(iActivity > 0) npc.StartActivity(iActivity);
	}
	else
	{
		DispatchKeyValue(npc.index, "model", "models/player/demo.mdl");
		view_as<CBaseCombatCharacter>(npc).SetModel("models/player/demo.mdl");
		SetEntPropFloat(npc.index, Prop_Send, "m_fadeMinDist", 0.0);
		SetEntPropFloat(npc.index, Prop_Send, "m_fadeMaxDist", 1.0);
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_iWearable1 = npc.EquipItem("hat", "models/player/items/demo/drinking_hat.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		DispatchKeyValue(npc.m_iWearable1, "skin", "1");

		npc.m_iWearable2 = npc.EquipItem("pelvis", "models/weapons/c_models/c_demo_sultan_sword/c_demo_sultan_sword.mdl");

		npc.m_iWearable3 = npc.EquipItem("pelvis", "models/zombie_riot/the_bone_zone/basic_bones.mdl");
		DispatchKeyValue(npc.m_iWearable3, "skin", BONES_PIRATE_SKIN);
	}

	//RequestFrame(PirateBones_FixAnims, npc);
}

public void PirateBones_FixAnims(CClotBody npc)
{
	if (IsValidEntity(npc.index))
	{
		if (b_BonesBuffed[npc.index])
		{
			npc.SetActivity("ACT_PIRATE_RUN");
			//int iActivity = npc.LookupActivity("ACT_PIRATE_RUN");
			//if(iActivity > 0) npc.StartActivity(iActivity);
		}
		else
		{
			npc.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
			//int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
			//if(iActivity > 0) npc.StartActivity(iActivity);
		}
	}
}

public void PirateBones_SetBuffed(int index, bool buffed)
{
	CClotBody npc = view_as<CClotBody>(index);

	if (!b_BonesBuffed[index] && buffed)
	{
		//Tell the game the skeleton is buffed:
		b_BonesBuffed[index] = true;
		
		//Apply buffed stats:
		DispatchKeyValue(index,	"modelscale", BONES_PIRATE_SCALE_BUFFED);
		int HP = StringToInt(BONES_PIRATE_HP_BUFFED);
		SetEntProp(index, Prop_Data, "m_iMaxHealth", HP);
		npc.m_flSpeed = BONES_PIRATE_SPEED_BUFFED;

		Pirate_GiveCosmetics(npc, true);
		DispatchKeyValue(index, "skin", BONES_PIRATE_SKIN_BUFFED);
	}
	else if (b_BonesBuffed[index] && !buffed)
	{
		//Tell the game the skeleton is no longer buffed:
		b_BonesBuffed[index] = false;
		
		//Remove buffed stats:
		DispatchKeyValue(index,	"modelscale", BONES_PIRATE_SCALE);
		int HP = StringToInt(BONES_PIRATE_HP);
		SetEntProp(index, Prop_Data, "m_iMaxHealth", HP);
		npc.m_flSpeed = BONES_PIRATE_SPEED;

		Pirate_GiveCosmetics(npc, false);
		DispatchKeyValue(index, "skin", BONES_PIRATE_SKIN);
		
		//Remove buffed particle:
		PirateBones_RemoveRampageParticle(index);

		if (b_PirateRampage[index])
		{
			b_PirateRampage[index] = false;
			view_as<PirateBones>(index).PlayRampageEnd();
		}
	}
}

public void PirateBones_ApplyRampageParticle(int index)
{
	TE_SetupParticleEffect(BONES_PIRATE_RAMPAGEPARTICLE, PATTACH_ABSORIGIN_FOLLOW, index);
	TE_WriteNum("m_bControlPoint1", index);	
	TE_SendToAll();
}

public void PirateBones_RemoveRampageParticle(int index)
{
	TE_Start("EffectDispatch");
	TE_WriteNum("entindex", index);
	TE_WriteNum("m_nHitBox", GetParticleEffectIndex(BONES_PIRATE_RAMPAGEPARTICLE));
	TE_WriteNum("m_iEffectName", GetEffectIndex("ParticleEffectStop"));
	TE_SendToAll();
}

//TODO 
//Rewrite
public void PirateBones_ClotThink(int iNPC)
{
	PirateBones npc = view_as<PirateBones>(iNPC);
	
//	PrintToChatAll("%.f",GetEntPropFloat(view_as<int>(iNPC), Prop_Data, "m_speed"));
	
	if (b_BonesBuffed[npc.index])
	{
		float maxHealth = float(GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"));
		float current = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));
		float percentage = current / maxHealth;

		if (b_PirateRampage[npc.index] && percentage > BONES_PIRATE_RAMPAGE_THRESHOLD)
		{
			PirateBones_RemoveRampageParticle(npc.index);
			npc.m_flSpeed = BONES_PIRATE_SPEED_BUFFED;
			b_PirateRampage[npc.index] = false;
			npc.PlayRampageEnd();
		}
		else if (!b_PirateRampage[npc.index] && percentage <= BONES_PIRATE_RAMPAGE_THRESHOLD)
		{
			PirateBones_ApplyRampageParticle(npc.index);
			npc.m_flSpeed = BONES_PIRATE_SPEED_BUFFED_RAMPAGE;
			b_PirateRampage[npc.index] = true;
			npc.PlayRampageStart();
		}
	}

	npc.Update();
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
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
	
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 1.0;
		npc.StartPathing();
		//PluginBot_NormalJump(npc.index);
	}
	
	int closest = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, closest))
	{
		float vecTarget[3], vecother[3]; 
		WorldSpaceCenter(closest, vecTarget);
		WorldSpaceCenter(npc.index, vecother);
			
		float flDistanceToTarget = GetVectorDistance(vecTarget, vecother, true);
				
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; 
			PredictSubjectPosition(npc, closest, _, _, vPredictedPos);
	//		PrintToChatAll("cutoff");
			NPC_SetGoalVector(npc.index, vPredictedPos);
		}
		else
		{
			NPC_SetGoalEntity(npc.index, closest);
		}
		
		//Target close enough to hit
		
		if(flDistanceToTarget < 10000 || npc.m_flAttackHappenswillhappen)
		{
			//Look at target so we hit.
		//	npc.FaceTowards(vecTarget, 20000.0);
			
			if(npc.m_flNextMeleeAttack < GetGameTime(npc.index))
			{
				//Play attack ani
				if (!npc.m_flAttackHappenswillhappen)
				{
					if (b_BonesBuffed[npc.index])
					{
						if (b_LastAttackWasLeftHand[npc.index])
						{
							npc.RemoveGesture("ACT_PIRATE_ATTACK_RIGHT");
							npc.AddGesture("ACT_PIRATE_ATTACK_RIGHT");
						}
						else
						{
							npc.RemoveGesture("ACT_PIRATE_ATTACK_LEFT");
							npc.AddGesture("ACT_PIRATE_ATTACK_LEFT");
						}

						b_LastAttackWasLeftHand[npc.index] = !b_LastAttackWasLeftHand[npc.index];
					}
					else
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");

					npc.PlayMeleeSound();
					npc.m_flAttackHappens = GetGameTime(npc.index)+0.7;
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
							if(target <= MaxClients)
								SDKHooks_TakeDamage(target, npc.index, npc.index, b_BonesBuffed[npc.index] ? (b_PirateRampage[npc.index] ? BONES_PIRATE_PLAYERDAMAGE_BUFFED_RAMPAGE : BONES_PIRATE_PLAYERDAMAGE_BUFFED) : BONES_PIRATE_PLAYERDAMAGE, DMG_CLUB, -1, _, vecHit);
							else
								SDKHooks_TakeDamage(target, npc.index, npc.index, b_BonesBuffed[npc.index] ? (b_PirateRampage[npc.index] ? BONES_PIRATE_BUILDINGDAMAGE_BUFFED_RAMPAGE : BONES_PIRATE_BUILDINGDAMAGE_BUFFED) : BONES_PIRATE_BUILDINGDAMAGE, DMG_CLUB, -1, _, vecHit);					

							// Hit sound
							npc.PlayMeleeHitSound();
						}
						else
						{
							npc.PlayMeleeMissSound();
						}
					}
					delete swingTrace;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + (b_BonesBuffed[npc.index] ? (b_PirateRampage[npc.index] ? BONES_PIRATE_ATTACKINTERVAL_BUFFED_RAMPAGE : BONES_PIRATE_ATTACKINTERVAL_BUFFED) : BONES_PIRATE_ATTACKINTERVAL);
					npc.m_flAttackHappenswillhappen = false;
				}
				else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					npc.m_flAttackHappenswillhappen = false;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + (b_BonesBuffed[npc.index] ? (b_PirateRampage[npc.index] ? BONES_PIRATE_ATTACKINTERVAL_BUFFED_RAMPAGE : BONES_PIRATE_ATTACKINTERVAL_BUFFED) : BONES_PIRATE_ATTACKINTERVAL);
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


public Action PirateBones_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	PirateBones npc = view_as<PirateBones>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
//	
	return Plugin_Changed;
}

public void PirateBones_NPCDeath(int entity)
{
	PirateBones npc = view_as<PirateBones>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	SDKUnhook(entity, SDKHook_Think, PirateBones_ClotThink);
	
	npc.RemoveAllWearables();
	
	DispatchKeyValue(npc.index, "model", "models/bots/skeleton_sniper/skeleton_sniper.mdl");
	view_as<CBaseCombatCharacter>(npc).SetModel("models/bots/skeleton_sniper/skeleton_sniper.mdl");
//	AcceptEntityInput(npc.index, "KillHierarchy");
}


