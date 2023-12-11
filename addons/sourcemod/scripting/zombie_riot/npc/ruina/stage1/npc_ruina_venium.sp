#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/engineer_paincrticialdeath01.mp3",
	"vo/engineer_paincrticialdeath02.mp3",
	"vo/engineer_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/engineer_painsharp01.mp3",
	"vo/engineer_painsharp02.mp3",
	"vo/engineer_painsharp03.mp3",
	"vo/engineer_painsharp04.mp3",
	"vo/engineer_painsharp05.mp3",
	"vo/engineer_painsharp06.mp3",
	"vo/engineer_painsharp07.mp3",
	"vo/engineer_painsharp08.mp3",
};

static const char g_IdleSounds[][] = {
	"vo/engineer_standonthepoint01.mp3",
	"vo/engineer_standonthepoint02.mp3",
	"vo/engineer_standonthepoint03.mp3",
	"vo/engineer_standonthepoint04.mp3",
	"vo/engineer_standonthepoint05.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/engineer_battlecry01.mp3",
	"vo/engineer_battlecry03.mp3",
	"vo/engineer_battlecry04.mp3",
	"vo/engineer_battlecry05.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/halloween_boss/knight_axe_hit.wav",
};
static const char g_MeleeAttackSounds[][] = {
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav",
};
static const char g_MeleeMissSounds[][] = {
	"weapons/bat_draw_swoosh1.wav",
	"weapons/bat_draw_swoosh2.wav",
};
static char g_TeleportSounds[][] = {
	"misc/halloween/spell_stealth.wav",
};

static int i_anchor_id[MAXENTITIES];
static int i_failsafe[MAXENTITIES];

#define RUINA_ANCHOR_FAILSAFE_AMMOUNT 33

void Venium_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_TeleportSounds));   i++) { PrecacheSound(g_TeleportSounds[i]);  			}
	PrecacheModel("models/player/engineer.mdl");
}

methodmap Venium < CClotBody
{
	
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleSound()");
		#endif
	}
	
	public void PlayTeleportSound() {
		EmitSoundToAll(g_TeleportSounds[GetRandomInt(0, sizeof(g_TeleportSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayTeleportSound()");
		#endif
	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleAlertSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayDeathSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayMeleeMissSound()");
		#endif
	}
	
	
	public Venium(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		Venium npc = view_as<Venium>(CClotBody(vecPos, vecAng, "models/player/engineer.mdl", "1.0", "1250", ally));
		
		i_NpcInternalId[npc.index] = RUINA_VENIUM;
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);

		if(npc.m_iChanged_WalkCycle != 0) 	
		{
			npc.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
			npc.m_iChanged_WalkCycle = 0;
		}

		i_anchor_id[npc.index]=-1;
		i_failsafe[npc.index]=0;
		
		
		/*
			
		
		*/
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		
		
		SDKHook(npc.index, SDKHook_Think, Venium_ClotThink);
		
		npc.m_flSpeed = 300.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
        /*
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/medic/xms2013_medic_hood/xms2013_medic_hood.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/medic/hw2013_ramses_regalia/hw2013_ramses_regalia.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/hw2013_moon_boots/hw2013_moon_boots.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/medic/xms2013_medic_robe/xms2013_medic_robe.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		
		
		int skin = 1;	//1=blue, 0=red
		SetVariantInt(1);	
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);*/
				
				
		fl_ruina_battery[npc.index] = 0.0;
		b_ruina_battery_ability_active[npc.index] = false;
		fl_ruina_battery_timer[npc.index] = 0.0;
		
		Ruina_Set_Heirarchy(npc.index, 1);	//is a melee npc
		Ruina_Set_No_Retreat(npc.index);	//no running away to heal!

		Ruina_Set_Recall_Status(npc.index, true);
		
		
		return npc;
	}
	
	
}

//TODO 
//Rewrite
public void Venium_ClotThink(int iNPC)
{
	Venium npc = view_as<Venium>(iNPC);
	
	float GameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > GameTime)
	{
		return;
	}
	
	npc.m_flNextDelayTime = GameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
			
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = GameTime + 0.1;

	
	if(npc.m_flGetClosestTargetTime < GameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GameTime + GetRandomRetargetTime();
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	int Anchor = EntRefToEntIndex(i_anchor_id[npc.index]);

	if(IsValidEntity(Anchor))
	{
		i_failsafe[npc.index]=0;
		fl_ruina_battery_timer[npc.index] = GameTime+30.0;	//A set timeout for rebuild an anchor.
		float Anchor_Loc[3], Npc_Loc[3];

		Anchor_Loc = WorldSpaceCenter(Anchor);
		Npc_Loc = WorldSpaceCenter(npc.index);

		float dist = GetVectorDistance(Anchor_Loc, Npc_Loc, true);

		if(dist <= (500.0*500.0))	//always stay within range of the anchor
		{
			if(fl_ruina_battery[Anchor]<255)	//charging phase
			{
				if(dist <= (145.0*145.0))
				{
					Ruina_Add_Battery(Anchor, 0.5);
					NPC_StopPathing(npc.index);
					npc.m_bPathing = false;
					npc.FaceTowards(Anchor_Loc, 15000.0);
					if(npc.m_iChanged_WalkCycle != 1) 	
					{
						npc.SetActivity("ACT_MP_CYOA_PDA_IDLE");
						npc.AddGesture("ACT_MP_CYOA_PDA_INTRO");
						npc.m_iChanged_WalkCycle = 1;
					}
				}
				else
				{
					if(npc.m_iChanged_WalkCycle != 0) 	
					{
						npc.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
						npc.m_iChanged_WalkCycle = 0;
					}
					NPC_SetGoalVector(iNPC, Anchor_Loc);	//we are too far away from the anchor to charge it, go near it.
					NPC_StartPathing(iNPC);
					npc.StartPathing();
					npc.m_bPathing = true;
				}
				
			}
			else	//active phase
			{
				Venium_Post_Bult_Logic(npc, PrimaryThreatIndex, GameTime);	//anchor is built, if an enemy is too close we attack, otherwise just stay near the anchor
				if(npc.m_iChanged_WalkCycle != 0) 	
				{
					npc.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
					npc.m_iChanged_WalkCycle = 0;
				}
			}
		}
		else
		{
			NPC_SetGoalVector(iNPC, Anchor_Loc);
			NPC_StartPathing(iNPC);
			npc.StartPathing();
			npc.m_bPathing = true;
			if(npc.m_iChanged_WalkCycle != 0) 	
			{
				npc.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
				npc.m_iChanged_WalkCycle = 0;
			}
		}
		
	}
	else if(fl_ruina_battery_timer[npc.index] < GameTime && i_magia_anchors_active < 5)
	{
		Venium_Build_Anchor(npc);	//build anchor.
	}
	else if(IsValidEnemy(npc.index, PrimaryThreatIndex))	//anchor is dead, we on cooldown, runaway from anyone
	{
		
		if(npc.m_iChanged_WalkCycle != 0) 	
		{
			npc.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
			npc.m_iChanged_WalkCycle = 0;
		}
		float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
		
		float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);

		if(flDistanceToTarget < (2000.0*2000.0))
		{
			int Enemy_I_See;
				
			Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
			//Target close enough to hit
			if(IsValidEnemy(npc.index, Enemy_I_See)) //Check if i can even see.
			{
				if(flDistanceToTarget < (1250.0*1250.0))
				{
					Ruina_Runaway_Logic(npc.index, PrimaryThreatIndex);
				}
				else
				{
					NPC_StopPathing(npc.index);
					npc.m_bPathing = false;
				}
			}
			else
			{
				npc.StartPathing();
				npc.m_bPathing = true;
			}
		}
		else
		{
			npc.StartPathing();
			npc.m_bPathing = true;
		}
	}

	npc.PlayIdleAlertSound();
}
public Action Venium_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Venium npc = view_as<Venium>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	fl_ruina_battery[npc.index] += damage;	//turn damage taken into energy
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void Venium_NPCDeath(int entity)
{
	Venium npc = view_as<Venium>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	SDKUnhook(npc.index, SDKHook_Think, Venium_ClotThink);
		
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
}

static void Venium_Build_Anchor(Venium npc)
{
	float AproxRandomSpaceToWalkTo[3];

	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", AproxRandomSpaceToWalkTo);

	AproxRandomSpaceToWalkTo[2] += 50.0;

	AproxRandomSpaceToWalkTo[0] = GetRandomFloat((AproxRandomSpaceToWalkTo[0] - 800.0),(AproxRandomSpaceToWalkTo[0] + 800.0));
	AproxRandomSpaceToWalkTo[1] = GetRandomFloat((AproxRandomSpaceToWalkTo[1] - 800.0),(AproxRandomSpaceToWalkTo[1] + 800.0));

	Handle ToGroundTrace = TR_TraceRayFilterEx(AproxRandomSpaceToWalkTo, view_as<float>( { 90.0, 0.0, 0.0 } ), npc.GetSolidMask(), RayType_Infinite, BulletAndMeleeTrace, npc.index);
		
	TR_GetEndPosition(AproxRandomSpaceToWalkTo, ToGroundTrace);
	delete ToGroundTrace;

	CNavArea area = TheNavMesh.GetNearestNavArea(AproxRandomSpaceToWalkTo, true);
	if(area == NULL_AREA)
		return;

	int NavAttribs = area.GetAttributes();
	if(NavAttribs & NAV_MESH_AVOID)
	{
		return;
	}
			

	area.GetCenter(AproxRandomSpaceToWalkTo);

	AproxRandomSpaceToWalkTo[2] += 18.0;
		
	static float hullcheckmaxs_Player_Again[3];
	static float hullcheckmins_Player_Again[3];

	hullcheckmaxs_Player_Again = view_as<float>( { 45.0, 45.0, 82.0 } ); //Fat. very fett indeed
	hullcheckmins_Player_Again = view_as<float>( { -45.0, -45.0, 0.0 } );	

	if(IsSpaceOccupiedIgnorePlayers(AproxRandomSpaceToWalkTo, hullcheckmins_Player_Again, hullcheckmaxs_Player_Again, npc.index) || IsSpaceOccupiedOnlyPlayers(AproxRandomSpaceToWalkTo, hullcheckmins_Player_Again, hullcheckmaxs_Player_Again, npc.index))
	{
		return;
	}

	if(IsPointHazard(AproxRandomSpaceToWalkTo)) //Retry.
		return;

		
	AproxRandomSpaceToWalkTo[2] += 18.0;
	if(IsPointHazard(AproxRandomSpaceToWalkTo)) //Retry.
		return;

		
	AproxRandomSpaceToWalkTo[2] -= 18.0;
	AproxRandomSpaceToWalkTo[2] -= 18.0;
	AproxRandomSpaceToWalkTo[2] -= 18.0;

	if(IsPointHazard(AproxRandomSpaceToWalkTo)) //Retry.
		return;

		
	AproxRandomSpaceToWalkTo[2] += 18.0;
	AproxRandomSpaceToWalkTo[2] += 18.0;
		
	float flDistanceToBuild = GetVectorDistance(AproxRandomSpaceToWalkTo, WorldSpaceCenter(npc.index), true);
		
	if(flDistanceToBuild < (2000.0 * 2000.0) && i_failsafe[npc.index] <= RUINA_ANCHOR_FAILSAFE_AMMOUNT)
	{
		i_failsafe[npc.index]++;
		return; //The building is too close, we want to retry! it is unfair otherwise.
	}
	//Retry.


	int spawn_index = Npc_Create(RUINA_MAGIA_ANCHOR, -1, AproxRandomSpaceToWalkTo, {0.0,0.0,0.0}, GetEntProp(npc.index, Prop_Send, "m_iTeamNum") == 2);
	if(spawn_index > MaxClients)
	{
		i_anchor_id[npc.index] = EntIndexToEntRef(spawn_index);
		if(!b_IsAlliedNpc[npc.index])
		{
			Zombies_Currently_Still_Ongoing += 1;
		}
		fl_ruina_battery[spawn_index]=10.0;
		SetEntityRenderMode(spawn_index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(spawn_index, 255, 255, 255, 1);

		SetEntProp(spawn_index, Prop_Data, "m_iHealth", 50000);
		SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", 50000);
	}
}
static void Venium_Post_Bult_Logic(Venium npc, int PrimaryThreatIndex, float GameTime)
{
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
			
		float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
		
		float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
			
		if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*3.5)
		{
			Ruina_Basic_Npc_Logic(npc.index, PrimaryThreatIndex, GameTime);	//handles movement
			int status=0;
			Ruina_Generic_Melee_Self_Defense(npc.index, PrimaryThreatIndex, flDistanceToTarget, NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*1.25, 45.0, 200.0, "ACT_MP_ATTACK_STAND_MELEE", 0.6, 0.35, 20000.0, GameTime, status);
			switch(status)
			{
				case 1:	//we swung
					npc.PlayMeleeSound();
				case 2:	//we hit something
					npc.PlayMeleeHitSound();
				case 3:	//we missed
					npc.PlayMeleeMissSound();
				//0 means nothing.
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
}