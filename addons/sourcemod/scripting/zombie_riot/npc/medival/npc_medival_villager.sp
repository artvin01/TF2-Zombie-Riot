#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"npc/metropolice/die1.wav",
	"npc/metropolice/die2.wav",
	"npc/metropolice/die3.wav",
	"npc/metropolice/die4.wav",
};

static const char g_HurtSounds[][] = {
	"npc/metropolice/pain1.wav",
	"npc/metropolice/pain2.wav",
	"npc/metropolice/pain3.wav",
	"npc/metropolice/pain4.wav",
};

static const char g_IdleSounds[][] = {
	"npc/metropolice/vo/affirmative.wav",
	"npc/metropolice/vo/affirmative2.wav",
	"npc/metropolice/vo/canalblock.wav",
	"npc/metropolice/vo/chuckle.wav",
	"npc/metropolice/vo/citizen.wav",
	"npc/metropolice/vo/code7.wav",
	"npc/metropolice/vo/code100.wav",
	"npc/metropolice/vo/copy.wav",
	"npc/metropolice/vo/breakhiscover.wav",
	"npc/metropolice/vo/help.wav",
	"npc/metropolice/vo/hesgone148.wav",
	"npc/metropolice/vo/hesrunning.wav",
	"npc/metropolice/vo/infection.wav",
	"npc/metropolice/vo/king.wav",
	"npc/metropolice/vo/needanyhelpwiththisone.wav",

	"npc/metropolice/vo/pickupthecan2.wav",
	"npc/metropolice/vo/sociocide.wav",
	"npc/metropolice/vo/watchit.wav",
	"npc/metropolice/vo/xray.wav",
	"npc/metropolice/vo/youknockeditover.wav",
};

static const char g_IdleAlertedSounds[][] = {
	"npc/metropolice/vo/affirmative.wav",
	"npc/metropolice/vo/affirmative2.wav",
	"npc/metropolice/vo/canalblock.wav",
	"npc/metropolice/vo/chuckle.wav",
	"npc/metropolice/vo/citizen.wav",
	"npc/metropolice/vo/code7.wav",
	"npc/metropolice/vo/code100.wav",
	"npc/metropolice/vo/copy.wav",
	"npc/metropolice/vo/breakhiscover.wav",
	"npc/metropolice/vo/help.wav",
	"npc/metropolice/vo/hesgone148.wav",
	"npc/metropolice/vo/hesrunning.wav",
	"npc/metropolice/vo/infection.wav",
	"npc/metropolice/vo/king.wav",
	"npc/metropolice/vo/needanyhelpwiththisone.wav",
	"npc/metropolice/vo/pickupthecan1.wav",

	"npc/metropolice/vo/pickupthecan3.wav",
	"npc/metropolice/vo/sociocide.wav",
	"npc/metropolice/vo/watchit.wav",
	"npc/metropolice/vo/xray.wav",
	"npc/metropolice/vo/youknockeditover.wav",
	"npc/metropolice/takedown.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/cleaver_hit_02.wav",
	"weapons/cleaver_hit_03.wav",
	"weapons/cleaver_hit_05.wav",
	"weapons/cleaver_hit_06.wav",
	"weapons/cleaver_hit_07.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav",
};

static const char g_MeleeMissSounds[][] = {
	"weapons/cbar_miss1.wav",
};

void MedivalVillager_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	PrecacheModel(COMBINE_CUSTOM_MODEL);
}

#define MAXTRIESVILLAGER 25

static bool b_WantTobuild[MAXENTITIES];
static bool b_AlreadyReparing[MAXENTITIES];
static float f_RandomTolerance[MAXENTITIES];
static int i_BuildingRef[MAXENTITIES];
static int i_ClosestAlly[MAXENTITIES];
static float i_ClosestAllyCD[MAXENTITIES];

methodmap MedivalVillager < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleSound()");
		#endif
	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleAlertSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayDeathSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayMeleeMissSound()");
		#endif
	}
	
	public MedivalVillager(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		MedivalVillager npc = view_as<MedivalVillager>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", GetVillagerHealth(), ally));
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");				
		i_NpcInternalId[npc.index] = MEDIVAL_VILLAGER;
		i_NpcWeight[npc.index] = 3;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_VILLAGER_RUN");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_iChanged_WalkCycle = 0;

		if(npc.m_iChanged_WalkCycle != 4) 	
		{
			npc.m_iChanged_WalkCycle = 4;
			npc.SetActivity("ACT_VILLAGER_RUN");
		}
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE_METRO;
		
		
		SDKHook(npc.index, SDKHook_Think, MedivalVillager_ClotThink);
		i_ClosestAllyCD[npc.index] = 0.0;

		npc.m_iState = 0;
		npc.m_flSpeed = 200.0;
		b_WantTobuild[npc.index] = true;
		b_AlreadyReparing[npc.index] = false;
		f_RandomTolerance[npc.index] = GetRandomFloat(0.25, 0.75);
		Is_a_Medic[npc.index] = true;
		
		npc.m_flMeleeArmor = 1.0;
		npc.m_flRangedArmor = 1.0;
		i_BuildingRef[npc.index] = -1;
		
		npc.m_flAttackHappens = 0.0;
		npc.m_flNextMeleeAttack = 0.0;

		float wave = float(ZR_GetWaveCount()+1);
		
		wave *= 0.1;
	
		npc.m_flWaveScale = wave;
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/workshop/weapons/c_models/c_sledgehammer/c_sledgehammer.mdl");
		SetVariantString("0.5");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		NPC_StopPathing(npc.index);

		if(!zr_disablerandomvillagerspawn.BoolValue)
		{
			int AreasCollected = 0;
			float CurrentPoints = 0.0;
			float f3_AreasCollected[3];

			for( int loop = 1; loop <= 500; loop++ ) 
			{
				CNavArea RandomArea = PickRandomArea();	
					
				if(RandomArea == NULL_AREA) 
					break; //No nav?

				float vecGoal[3]; RandomArea.GetCenter(vecGoal);

				vecGoal[2] += 20.0;
				static float hullcheckmaxs_Player_Again[3];
				static float hullcheckmins_Player_Again[3];

				hullcheckmaxs_Player_Again = view_as<float>( { 24.0, 24.0, 82.0 } );
				hullcheckmins_Player_Again = view_as<float>( { -24.0, -24.0, 0.0 } );	
				if(IsPointHazard(vecGoal)) //Retry.
				{
					continue;
				}
				else if(IsSpaceOccupiedIgnorePlayers(vecGoal, hullcheckmins_Player_Again, hullcheckmaxs_Player_Again, npc.index) || IsSpaceOccupiedOnlyPlayers(vecGoal, hullcheckmins_Player_Again, hullcheckmaxs_Player_Again, npc.index))
				{
					continue;
				}
				else
				{
					float Accumulated_Points;
					for(int client_check=1; client_check<=MaxClients; client_check++)
					{
						if(IsClientInGame(client_check) && IsPlayerAlive(client_check) && GetClientTeam(client_check)==2 && TeutonType[client_check] == TEUTON_NONE && dieingstate[client_check] == 0)
						{		
							float f3_PositionTemp[3];
							GetEntPropVector(client_check, Prop_Data, "m_vecAbsOrigin", f3_PositionTemp);
							float distance = GetVectorDistance( f3_PositionTemp, vecGoal, true); 
							//leave it all squared for optimsation sake!
							float inverting_score_calc;

							inverting_score_calc = ( distance / 100000000.0);

							if(ally)
							{
								inverting_score_calc -= 1;

								inverting_score_calc *= -1.0;					
							}

							Accumulated_Points += inverting_score_calc;
						}
					}
					if(Accumulated_Points > CurrentPoints)
					{
						vecGoal[2] -= 20.0;
						f3_AreasCollected = vecGoal;
						CurrentPoints = Accumulated_Points;
					}
					AreasCollected += 1;
					if(AreasCollected >= MAXTRIESVILLAGER)
					{
						if(vecGoal[0])
						{
							TeleportEntity(npc.index, f3_AreasCollected, NULL_VECTOR, NULL_VECTOR);
						}
						break;
					}
				}
			}
		}
		return npc;
	}
}

public void MedivalVillager_ClotThink(int iNPC)
{
	MedivalVillager npc = view_as<MedivalVillager>(iNPC);
	

	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();	
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}

	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.05;

	//Top logic should be ignored.
	

	int Behavior = -1;

	int buildingentity = EntRefToEntIndex(i_BuildingRef[iNPC]);

	if(b_WantTobuild[npc.index])
	{
		Behavior = 1;
	}
	else if(IsValidEntity(buildingentity) && i_AttacksTillMegahit[buildingentity] >= 255) //We already have 1
	{
		int healthbuilding = GetEntProp(buildingentity, Prop_Data, "m_iHealth");
		int Maxhealthbuilding = GetEntProp(buildingentity, Prop_Data, "m_iMaxHealth");

		if(healthbuilding >= Maxhealthbuilding)
		{
			Behavior = 0;
		}
		else if(healthbuilding < RoundToCeil(float(Maxhealthbuilding) * f_RandomTolerance[npc.index]) || b_AlreadyReparing[npc.index])
		{
			//Go repair!
			if(!b_AlreadyReparing[npc.index])
			{
				bool regrow = true;
				Building_CamoOrRegrowBlocker(buildingentity, _, regrow);
				if(regrow)
				{
					b_AlreadyReparing[npc.index] = true;
					Behavior = 2;
				}
				else
				{
					Behavior = 0;
				}
			}
			else
			{
				Behavior = 2;
			}
		}
		else
		{
			Behavior = 0;
		}
	}
	else if(!IsValidEntity(buildingentity)) //I am sad!
	{
		Behavior = 3;
	}

	switch(Behavior)
	{
		case 0:
		{
			if(i_ClosestAllyCD[npc.index] < GetGameTime())
			{
				i_ClosestAllyCD[npc.index] = GetGameTime() + 1.0;
				i_ClosestAlly[npc.index] = GetClosestAlly(npc.index);
				if(IsValidEntity(buildingentity)) //We already have 1
				{
					i_ClosestAlly[npc.index] = GetClosestAlly(buildingentity, _ , npc.index);
				}				
			}
			if(IsValidAlly(npc.index, i_ClosestAlly[npc.index]))
			{
				float flDistanceToTarget = GetVectorDistance(WorldSpaceCenter(i_ClosestAlly[npc.index]), WorldSpaceCenter(npc.index), true);
				if(flDistanceToTarget < (125.0* 125.0))
				{
					if(npc.m_iChanged_WalkCycle != 5) 	
					{
						npc.m_bisWalking = false;
						npc.m_flSpeed = 0.0;
						npc.m_iChanged_WalkCycle = 5;
						npc.SetActivity("ACT_VILLAGER_IDLE");
						NPC_StopPathing(iNPC);
					}
				}
				else
				{
					float AproxRandomSpaceToWalkTo[3];
					GetEntPropVector(i_ClosestAlly[npc.index], Prop_Data, "m_vecAbsOrigin", AproxRandomSpaceToWalkTo);
					NPC_SetGoalVector(iNPC, AproxRandomSpaceToWalkTo);
					NPC_StartPathing(iNPC);
					if(npc.m_iChanged_WalkCycle != 4) 	
					{
						npc.m_bisWalking = true;
						npc.m_flSpeed = 200.0;
						npc.m_iChanged_WalkCycle = 4;
						npc.SetActivity("ACT_VILLAGER_RUN");
					}		
				}
			}
			else if(IsValidEntity(buildingentity)) //We already have 1
			{
				float flDistanceToTarget = GetVectorDistance(WorldSpaceCenter(buildingentity), WorldSpaceCenter(npc.index), true);
				
				NPC_SetGoalEntity(npc.index, buildingentity);
				NPC_StartPathing(iNPC);
				//Walk to building.
				if(flDistanceToTarget < (125.0* 125.0) && IsValidAlly(npc.index, buildingentity))
				{
					if(npc.m_iChanged_WalkCycle != 4) 	
					{
						npc.m_bisWalking = true;
						npc.m_flSpeed = 200.0;
						npc.m_iChanged_WalkCycle = 4;
						npc.SetActivity("ACT_VILLAGER_RUN");
					}
				}
				else
				{
					if(npc.m_iChanged_WalkCycle != 5) 	
					{
						npc.m_bisWalking = false;
						npc.m_flSpeed = 0.0;
						npc.m_iChanged_WalkCycle = 5;
						npc.SetActivity("ACT_VILLAGER_IDLE");
						NPC_StopPathing(iNPC);
					}
				}
			}
			else
			{
				if(npc.m_iChanged_WalkCycle != 5) 	
				{
					npc.m_bisWalking = false;
					npc.m_flSpeed = 0.0;
					npc.m_iChanged_WalkCycle = 5;
					npc.SetActivity("ACT_VILLAGER_IDLE");
					NPC_StopPathing(iNPC);
				}
			}
		}
		case 1:
		{
			//Search and find a building.
			if(IsValidEntity(buildingentity)) //We already have 1
			{
				
				float flDistanceToTarget = GetVectorDistance(WorldSpaceCenter(buildingentity), WorldSpaceCenter(npc.index), true);

				int Entity_I_See;
			
				Entity_I_See = Can_I_See_Ally(npc.index, buildingentity);
				if(i_AttacksTillMegahit[buildingentity] < 255)
				{
					if(flDistanceToTarget < (125.0* 125.0) && IsValidAlly(npc.index, Entity_I_See))
					{
						if(npc.m_iChanged_WalkCycle != 3) 	
						{
							npc.m_iChanged_WalkCycle = 3;
							npc.SetActivity("ACT_VILLAGER_BUILD_LOOP");
							NPC_StopPathing(iNPC);
							npc.m_bisWalking = false;
							npc.m_flSpeed = 0.0;
						}
						i_AttacksTillMegahit[buildingentity] += 1;
						npc.FaceTowards(WorldSpaceCenter(buildingentity), 15000.0);
					}
					else
					{
						float AproxRandomSpaceToWalkTo[3];
						GetEntPropVector(buildingentity, Prop_Data, "m_vecAbsOrigin", AproxRandomSpaceToWalkTo);
						NPC_SetGoalVector(iNPC, AproxRandomSpaceToWalkTo);
						NPC_StartPathing(iNPC);
						//Walk to building.
						if(npc.m_iChanged_WalkCycle != 4) 	
						{
							npc.m_bisWalking = true;
							npc.m_flSpeed = 200.0;
							npc.m_iChanged_WalkCycle = 4;
							npc.SetActivity("ACT_VILLAGER_RUN");
						}
					}					
				}
				else
				{	
					b_WantTobuild[npc.index] = false;
				}
			}
			else
			{

				
				npc.m_bisWalking = true;

				VillagerSelfDefense(npc,GetGameTime(npc.index)); //This is for self defense, incase an enemy is too close. This isnt the villagers main thing.
				
				if(IsValidEnemy(npc.index,npc.m_iTarget))
				{
					NPC_SetGoalEntity(npc.index, npc.m_iTarget);
					NPC_StartPathing(iNPC);
					if(npc.m_iChanged_WalkCycle != 4) 	
					{
						npc.m_bisWalking = true;
						npc.m_flSpeed = 200.0;
						npc.m_iChanged_WalkCycle = 4;
						npc.SetActivity("ACT_VILLAGER_RUN");
					}
				}
				else
				{
					if(npc.m_iChanged_WalkCycle != 5) 	
					{
						npc.m_bisWalking = false;
						npc.m_flSpeed = 0.0;
						npc.m_iChanged_WalkCycle = 5;
						npc.SetActivity("ACT_VILLAGER_IDLE");
						NPC_StopPathing(iNPC);
					}
				}

				// make a building.
				//For now only one building exists.
				float AproxRandomSpaceToWalkTo[3];

				GetEntPropVector(iNPC, Prop_Data, "m_vecAbsOrigin", AproxRandomSpaceToWalkTo);

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

				hullcheckmaxs_Player_Again = view_as<float>( { 30.0, 30.0, 82.0 } ); //Fat
				hullcheckmins_Player_Again = view_as<float>( { -30.0, -30.0, 0.0 } );	

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
				
				if(flDistanceToBuild < (500.0 * 500.0))
				{
					return; //The building is too close, we want to retry! it is unfair otherwise.
				}
				//Retry.

				//Timeout
				npc.m_flNextMeleeAttack = GetGameTime(npc.index) + GetRandomFloat(10.0, 20.0);

				int spawn_index = Npc_Create(MEDIVAL_BUILDING, -1, AproxRandomSpaceToWalkTo, {0.0,0.0,0.0}, GetEntProp(npc.index, Prop_Send, "m_iTeamNum") == 2);
				if(spawn_index > MaxClients)
				{
					i_BuildingRef[iNPC] = EntIndexToEntRef(spawn_index);
					if(!b_IsAlliedNpc[iNPC])
					{
						Zombies_Currently_Still_Ongoing += 1;
					}
					i_AttacksTillMegahit[spawn_index] = 10;
					SetEntityRenderMode(spawn_index, RENDER_TRANSCOLOR);
					SetEntityRenderColor(spawn_index, 255, 255, 255, 0);
				}
			}
		}
		case 2:
		{
			float flDistanceToTarget = GetVectorDistance(WorldSpaceCenter(buildingentity), WorldSpaceCenter(npc.index), true);

			int Entity_I_See;
			
			Entity_I_See = Can_I_See_Ally(npc.index, buildingentity);
			if(flDistanceToTarget < (125.0* 125.0) && IsValidAlly(npc.index, Entity_I_See))
			{
				if(npc.m_iChanged_WalkCycle != 3) 	
				{
					npc.m_iChanged_WalkCycle = 3;
					npc.SetActivity("ACT_VILLAGER_BUILD_LOOP");
					NPC_StopPathing(iNPC);
					npc.m_bisWalking = false;
					npc.m_flSpeed = 0.0;
				}

				bool regrow = true;
				Building_CamoOrRegrowBlocker(buildingentity, _, regrow);
				if(regrow)
				{
					int healthbuilding = GetEntProp(buildingentity, Prop_Data, "m_iHealth");
					int Maxhealthbuilding = GetEntProp(buildingentity, Prop_Data, "m_iMaxHealth");
					int AddHealth = Maxhealthbuilding / 1000;

					if(AddHealth < 1)
					{
						AddHealth = 1;
					}
					healthbuilding += AddHealth;
					if(healthbuilding > Maxhealthbuilding)
					{
						b_AlreadyReparing[npc.index] = false;
						Maxhealthbuilding = healthbuilding;
					}
					SetEntProp(buildingentity, Prop_Data, "m_iHealth",healthbuilding);
					npc.FaceTowards(WorldSpaceCenter(buildingentity), 15000.0);
				}
				else
				{
					b_AlreadyReparing[npc.index] = false;
				}
			}
			else
			{
				float AproxRandomSpaceToWalkTo[3];
				GetEntPropVector(buildingentity, Prop_Data, "m_vecAbsOrigin", AproxRandomSpaceToWalkTo);
				NPC_SetGoalVector(iNPC, AproxRandomSpaceToWalkTo);
				NPC_StartPathing(iNPC);
				//Walk to building.
				if(npc.m_iChanged_WalkCycle != 4) 	
				{
					npc.m_bisWalking = true;
					npc.m_flSpeed = 200.0;
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_VILLAGER_RUN");
				}
			}					
		}
		case 3:
		{
			if(IsValidEntity(buildingentity) && !b_NpcHasDied[buildingentity])
			{
				b_WantTobuild[npc.index] = true; //done.
				//How?? I wanna build again!
			}
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);

				float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
				
				//Predict their pos.
				if(flDistanceToTarget < npc.GetLeadRadius()) 
				{
					float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, npc.m_iTarget);

					NPC_SetGoalVector(npc.index, vPredictedPos);
				}
				else
				{
					NPC_SetGoalEntity(npc.index, npc.m_iTarget);
				}
				NPC_StartPathing(iNPC);
				//Walk to building.
				if(npc.m_iChanged_WalkCycle != 4) 	
				{
					npc.m_bisWalking = true;
					npc.m_flSpeed = 200.0;
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_VILLAGER_RUN");
				}
			}
			else
			{
				if(npc.m_iChanged_WalkCycle != 5) 	
				{
					npc.m_bisWalking = false;
					npc.m_flSpeed = 0.0;
					npc.m_iChanged_WalkCycle = 5;
					npc.SetActivity("ACT_VILLAGER_IDLE");
					NPC_StopPathing(iNPC);
				}
			}
		}
	}

	VillagerSelfDefense(npc,GetGameTime(npc.index)); //This is for self defense, incase an enemy is too close. This isnt the villagers main thing.

	npc.PlayIdleAlertSound();
}


void VillagerSelfDefense(MedivalVillager npc, float gameTime)
{
	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;

	//This code is only here so they defend themselves incase any enemy is too close to them. otherwise it is completly disconnected from any other logic.

	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < GetGameTime(npc.index))
		{
			npc.m_flAttackHappens = 0.0;
			
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				Handle swingTrace;
				npc.FaceTowards(WorldSpaceCenter(npc.m_iTarget), 15000.0);
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 0)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					float damage = 35.0;

					npc.PlayMeleeHitSound();
					if(target > 0) 
					{
						if(!ShouldNpcDealBonusDamage(target))
						{
							SDKHooks_TakeDamage(target, npc.index, npc.index, damage * npc.m_flWaveScale, DMG_CLUB);
						}
						else
						{
							SDKHooks_TakeDamage(target, npc.index, npc.index, damage * 4.0 * npc.m_flWaveScale, DMG_CLUB);	
						}
					}
				}
				delete swingTrace;
			}
		}
	}

	if(GetGameTime(npc.index) > npc.m_flNextMeleeAttack)
	{
		if(IsValidEnemy(npc.index, PrimaryThreatIndex)) 
		{
			float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);

			float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);

			if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED)
			{
				int Enemy_I_See;
									
				Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
						
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;

					npc.PlayMeleeSound();

					npc.AddGesture("ACT_VILLAGER_ATTACK");
							
					npc.m_flAttackHappens = gameTime + 0.4;

					npc.m_flDoingAnimation = gameTime + 0.6;
					npc.m_flNextMeleeAttack = gameTime + 1.2;
				}
			}
		}
		else
		{
			npc.m_bPathing = false;
			npc.m_flGetClosestTargetTime = 0.0;
			npc.m_iTarget = GetClosestTarget(npc.index);
		}	
	}
}

public Action MedivalVillager_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	MedivalVillager npc = view_as<MedivalVillager>(victim);
	
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	
	return Plugin_Changed;
}

public void MedivalVillager_NPCDeath(int entity)
{
	MedivalVillager npc = view_as<MedivalVillager>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	
	SDKUnhook(npc.index, SDKHook_Think, MedivalVillager_ClotThink);
		
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}


static char[] GetVillagerHealth()
{
	int health = 60;
	
	health *= CountPlayersOnRed(); //yep its high! will need tos cale with waves expoentially.
	
	float temp_float_hp = float(health);
	
	if(CurrentRound+1 < 30)
	{
		health = RoundToCeil(Pow(((temp_float_hp + float(CurrentRound+1)) * float(CurrentRound+1)),1.20));
	}
	else if(CurrentRound+1 < 45)
	{
		health = RoundToCeil(Pow(((temp_float_hp + float(CurrentRound+1)) * float(CurrentRound+1)),1.25));
	}
	else
	{
		health = RoundToCeil(Pow(((temp_float_hp + float(CurrentRound+1)) * float(CurrentRound+1)),1.35)); //Yes its way higher but i reduced overall hp of him
	}
	
	health /= 2;
	
	
	health = RoundToCeil(float(health) * 1.2);
	
	char buffer[16];
	IntToString(health, buffer, sizeof(buffer));
	return buffer;
}