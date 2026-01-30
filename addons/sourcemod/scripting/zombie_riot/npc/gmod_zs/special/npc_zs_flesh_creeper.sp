#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"npc/barnacle/barnacle_die1.wav",
	"npc/barnacle/barnacle_die2.wav",
};

static const char g_HurtSounds[][] = {
	"npc/barnacle/barnacle_pull1.wav",
	"npc/barnacle/barnacle_pull2.wav",
	"npc/barnacle/barnacle_pull3.wav",
	"npc/barnacle/barnacle_pull4.wav",
};

static const char g_IdleSounds[][] = {
	"npc/barnacle/barnacle_pull1.wav",
	"npc/barnacle/barnacle_pull2.wav",
	"npc/barnacle/barnacle_pull3.wav",
	"npc/barnacle/barnacle_pull4.wav",
};

static const char g_IdleAlertedSounds[][] = {
	"npc/barnacle/barnacle_pull1.wav",
	"npc/barnacle/barnacle_pull2.wav",
	"npc/barnacle/barnacle_pull3.wav",
	"npc/barnacle/barnacle_pull4.wav",
};

static const char g_MeleeHitSounds[][] = {
	"physics/body/body_medium_impact_hard1.wav",
	"physics/body/body_medium_impact_hard2.wav",
	"physics/body/body_medium_impact_hard3.wav",
	"physics/body/body_medium_impact_hard4.wav",
	"physics/body/body_medium_impact_hard5.wav",
	"physics/body/body_medium_impact_hard6.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"npc/zombie/claw_miss1.wav",
	"npc/zombie/claw_miss2.wav",
};

static const char g_MeleeMissSounds[][] = {
	"npc/zombie/claw_miss1.wav",
	"npc/zombie/claw_miss2.wav",
};

#define FleshCreeper_SPAWN_SOUND	"ambient/creatures/town_zombie_call1.wav"

static int NPCId;

void FleshCreeper_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));	i++) { PrecacheSound(g_MeleeMissSounds[i]);	}
	for (int i = 0; i < (sizeof(g_DefaultMeleeMissSounds));   i++) { PrecacheSound(g_DefaultMeleeMissSounds[i]);   }

	PrecacheModel("models/zombie_riot/gmod_zs/flesh_creeper/flesh_creeper.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Flesh Creeper");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_zs_flesh_creeper");
	strcopy(data.Icon, sizeof(data.Icon), "gmod_zs_flesh_creeper");
	data.IconCustom = false;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_GmodZS;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);
	PrecacheSound(FleshCreeper_SPAWN_SOUND);
}

int FleshCreeper_ID()
{
	return NPCId;
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return FleshCreeper(vecPos, vecAng, team);
}

// #define MAXTRIESVILLAGER 25

static bool b_WantTobuild[MAXENTITIES];
static bool b_AlreadyReparing[MAXENTITIES];
static float f_RandomTolerance[MAXENTITIES];
static int i_BuildingRef[MAXENTITIES];


methodmap FleshCreeper < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 85);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 85);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, GetRandomInt(110, 120));
		
		
		
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		
		
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, GetRandomInt(90, 100));
		

	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		

	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_DefaultMeleeMissSounds[GetRandomInt(0, sizeof(g_DefaultMeleeMissSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, GetRandomInt(90, 100));	
	}
	
	public FleshCreeper(float vecPos[3], float vecAng[3], int ally)
	{
		FleshCreeper npc = view_as<FleshCreeper>(CClotBody(vecPos, vecAng, "models/zombie_riot/gmod_zs/flesh_creeper/flesh_creeper.mdl", "1.6", "1750", ally));
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_WALK");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_iChanged_WalkCycle = 0;

		if(npc.m_iChanged_WalkCycle != 4) 	
		{
			npc.m_iChanged_WalkCycle = 4;
			npc.SetActivity("ACT_WALK");
		}
		npc.m_flNextMeleeAttack = 0.0;
		
		func_NPCDeath[npc.index] = FleshCreeper_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = FleshCreeper_OnTakeDamage;
		func_NPCThink[npc.index] = FleshCreeper_ClotThink;
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPSOUND_NORMAL;		
		
		
		i_ClosestAllyCD[npc.index] = 0.0;

		npc.m_iState = 0;
		npc.m_flSpeed = 210.0;
		b_WantTobuild[npc.index] = true;
		b_AlreadyReparing[npc.index] = false;
		f_RandomTolerance[npc.index] = GetRandomFloat(0.25, 0.75);
		Is_a_Medic[npc.index] = true;
		
		AddNpcToAliveList(npc.index, 1);
		npc.m_flMeleeArmor = 1.0;
		npc.m_flRangedArmor = 0.9;
		i_BuildingRef[npc.index] = -1;
		
		npc.m_flAttackHappens = 0.0;
		npc.m_flNextMeleeAttack = 0.0;

		float wave = float(Waves_GetRoundScale()+1);
		
		wave *= 0.133333;
	
		npc.m_flWaveScale = wave;

		if(ally != TFTeam_Red)
		{	
			EmitSoundToAll(FleshCreeper_SPAWN_SOUND, _, _, _, _, 1.0);	
			EmitSoundToAll(FleshCreeper_SPAWN_SOUND, _, _, _, _, 1.0);	
			for(int client_check=1; client_check<=MaxClients; client_check++)
			{
				if(IsClientInGame(client_check) && !IsFakeClient(client_check))
				{
					SetGlobalTransTarget(client_check);
					ShowGameText(client_check, "voice_player", 1, "%t", "Flesh Creeper Spawn");	
				}
			}
		}

		npc.StopPathing();

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

				int NavAttribs = RandomArea.GetAttributes();
				if(NavAttribs & NAV_MESH_AVOID)
				{
					continue;
				}

				float vecGoal[3]; RandomArea.GetCenter(vecGoal);
				vecGoal[2] += 1.0;

				if(IsPointHazard(vecGoal)) //Retry.
					continue;

				static float hullcheckmaxs_Player_Again[3];
				static float hullcheckmins_Player_Again[3];

				hullcheckmaxs_Player_Again = view_as<float>( { 24.0, 24.0, 82.0 } );
				hullcheckmins_Player_Again = view_as<float>( { -24.0, -24.0, 0.0 } );	
				
				if(IsPointHazard(vecGoal)) //Retry.
					continue;
				
				vecGoal[2] += 18.0;
				if(IsPointHazard(vecGoal)) //Retry.
					continue;
				
				vecGoal[2] -= 18.0;
				vecGoal[2] -= 18.0;
				vecGoal[2] -= 18.0;
				if(IsPointHazard(vecGoal)) //Retry.
					continue;
				vecGoal[2] += 18.0;
				vecGoal[2] += 18.0;
				if(IsSpaceOccupiedIgnorePlayers(vecGoal, hullcheckmins_Player_Again, hullcheckmaxs_Player_Again, npc.index) || IsSpaceOccupiedOnlyPlayers(vecGoal, hullcheckmins_Player_Again, hullcheckmaxs_Player_Again, npc.index))
				{
					continue;
				}
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

						if(ally == TFTeam_Red)
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
		return npc;
	}
}

public void FleshCreeper_ClotThink(int iNPC)
{
	FleshCreeper npc = view_as<FleshCreeper>(iNPC);
	

	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();	
	
	if(npc.m_blPlayHurtAnimation)
	{
		// npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
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
				if(!HasSpecificBuff(buildingentity, "Growth Blocker"))
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
				float WorldSpaceVec[3]; WorldSpaceCenter(i_ClosestAlly[npc.index], WorldSpaceVec);
				float WorldSpaceVec2[3]; WorldSpaceCenter(npc.index, WorldSpaceVec2);
				float flDistanceToTarget = GetVectorDistance(WorldSpaceVec, WorldSpaceVec2, true);
				if(flDistanceToTarget < (125.0* 125.0))
				{
					if(npc.m_iChanged_WalkCycle != 5) 	
					{
						npc.m_bisWalking = false;
						npc.m_flSpeed = 0.0;
						npc.m_iChanged_WalkCycle = 5;
						npc.SetActivity("ACT_IDLE");
						view_as<CClotBody>(iNPC).StopPathing();
					}
				}
				else
				{
					float AproxRandomSpaceToWalkTo[3];
					GetEntPropVector(i_ClosestAlly[npc.index], Prop_Data, "m_vecAbsOrigin", AproxRandomSpaceToWalkTo);
					view_as<CClotBody>(iNPC).SetGoalVector(AproxRandomSpaceToWalkTo);
					view_as<CClotBody>(iNPC).StartPathing();
					if(npc.m_iChanged_WalkCycle != 4) 	
					{
						npc.m_bisWalking = true;
						npc.m_flSpeed = 210.0;
						npc.m_iChanged_WalkCycle = 4;
						npc.SetActivity("ACT_WALK");
					}		
				}
			}
			else if(IsValidEntity(buildingentity)) //We already have 1
			{
				float WorldSpaceVec[3]; WorldSpaceCenter(buildingentity, WorldSpaceVec);
				float WorldSpaceVec2[3]; WorldSpaceCenter(npc.index, WorldSpaceVec2);
				float flDistanceToTarget = GetVectorDistance(WorldSpaceVec, WorldSpaceVec2, true);
				
				npc.SetGoalEntity(buildingentity);
				view_as<CClotBody>(iNPC).StartPathing();
				//Walk to building.
				if(flDistanceToTarget < (125.0* 125.0) && IsValidAlly(npc.index, buildingentity))
				{
					if(npc.m_iChanged_WalkCycle != 4) 	
					{
						npc.m_bisWalking = true;
						npc.m_flSpeed = 210.0;
						npc.m_iChanged_WalkCycle = 4;
						npc.SetActivity("ACT_WALK");
					}
				}
				else
				{
					if(npc.m_iChanged_WalkCycle != 5) 	
					{
						npc.m_bisWalking = false;
						npc.m_flSpeed = 0.0;
						npc.m_iChanged_WalkCycle = 5;
						npc.SetActivity("ACT_IDLE");
						view_as<CClotBody>(iNPC).StopPathing();
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
					npc.SetActivity("ACT_IDLE");
					view_as<CClotBody>(iNPC).StopPathing();
				}
			}
		}
		case 1:
		{
			//Search and find a building.
			if(IsValidEntity(buildingentity)) //We already have 1
			{
				float WorldSpaceVec[3]; WorldSpaceCenter(buildingentity, WorldSpaceVec);
				float WorldSpaceVec2[3]; WorldSpaceCenter(npc.index, WorldSpaceVec2);
				float flDistanceToTarget = GetVectorDistance(WorldSpaceVec, WorldSpaceVec2, true);

				int Entity_I_See;
			
				Entity_I_See = Can_I_See_Ally(npc.index, buildingentity);
				if(i_AttacksTillMegahit[buildingentity] < 255)
				{
					if(flDistanceToTarget < (125.0* 125.0) && IsValidAlly(npc.index, Entity_I_See))
					{
						if(npc.m_iChanged_WalkCycle != 3) 	
						{
							npc.m_iChanged_WalkCycle = 3;
							view_as<CClotBody>(iNPC).StopPathing();
							npc.m_bisWalking = false;
							npc.m_flSpeed = 0.0;
						}
						i_AttacksTillMegahit[buildingentity] += 1;
						npc.FaceTowards(WorldSpaceVec, 15000.0);
						npc.SetActivity("ACT_ANTLION_JUMP_START");
					}
					else
					{
						float AproxRandomSpaceToWalkTo[3];
						GetEntPropVector(buildingentity, Prop_Data, "m_vecAbsOrigin", AproxRandomSpaceToWalkTo);
						view_as<CClotBody>(iNPC).SetGoalVector(AproxRandomSpaceToWalkTo);
						view_as<CClotBody>(iNPC).StartPathing();
						//Walk to building.
						if(npc.m_iChanged_WalkCycle != 4) 	
						{
							npc.m_bisWalking = true;
							npc.m_flSpeed = 210.0;
							npc.m_iChanged_WalkCycle = 4;
							npc.SetActivity("ACT_IDLE");
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

				FleshCreeperSelfDefense(npc,GetGameTime(npc.index)); //This is for self defense, incase an enemy is too close. This isnt the FleshCreepers main thing.
				
				if(IsValidEnemy(npc.index,npc.m_iTarget))
				{
					npc.SetGoalEntity(npc.m_iTarget);
					view_as<CClotBody>(iNPC).StartPathing();
					if(npc.m_iChanged_WalkCycle != 4) 	
					{
						npc.m_bisWalking = true;
						npc.m_flSpeed = 210.0;
						npc.m_iChanged_WalkCycle = 4;
						npc.SetActivity("ACT_WALK");
					}
				}
				else
				{
					if(npc.m_iChanged_WalkCycle != 5) 	
					{
						npc.m_bisWalking = false;
						npc.m_flSpeed = 0.0;
						npc.m_iChanged_WalkCycle = 5;
						npc.SetActivity("ACT_IDLE");
						view_as<CClotBody>(iNPC).StopPathing();
					}
				}

				// make a building.
				//For now only one building exists.
				float AproxRandomSpaceToWalkTo[3];

				GetEntPropVector(iNPC, Prop_Data, "m_vecAbsOrigin", AproxRandomSpaceToWalkTo);

				AproxRandomSpaceToWalkTo[2] += 50.0;

				AproxRandomSpaceToWalkTo[0] = GetRandomFloat((AproxRandomSpaceToWalkTo[0] - 800.0),(AproxRandomSpaceToWalkTo[0] + 800.0));
				AproxRandomSpaceToWalkTo[1] = GetRandomFloat((AproxRandomSpaceToWalkTo[1] - 800.0),(AproxRandomSpaceToWalkTo[1] + 800.0));

				Handle ToGroundTrace = TR_TraceRayFilterEx(AproxRandomSpaceToWalkTo, view_as<float>( { 90.0, 0.0, 0.0 } ), GetSolidMask(npc.index), RayType_Infinite, BulletAndMeleeTrace, npc.index);
				
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
				float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);

				float flDistanceToBuild = GetVectorDistance(AproxRandomSpaceToWalkTo, WorldSpaceVec, true);
				
				if(flDistanceToBuild < (500.0 * 500.0))
				{
					return; //The building is too close, we want to retry! it is unfair otherwise.
				}
				//Retry.

				//Timeout
				npc.m_flNextMeleeAttack = GetGameTime(npc.index) + GetRandomFloat(10.0, 20.0);

				int spawn_index = NPC_CreateByName("npc_zs_nest", -1, AproxRandomSpaceToWalkTo, {0.0,0.0,0.0}, GetTeam(npc.index));
				if(spawn_index > MaxClients)
				{
					NpcStats_CopyStats(npc.index, spawn_index);
					b_StaticNPC[spawn_index] = b_StaticNPC[iNPC];
					if(b_StaticNPC[spawn_index])
						AddNpcToAliveList(spawn_index, 1);
					
					i_BuildingRef[iNPC] = EntIndexToEntRef(spawn_index);
					if(GetTeam(iNPC) != TFTeam_Red)
					{
						if(!b_StaticNPC[spawn_index])
							NpcAddedToZombiesLeftCurrently(spawn_index, true);
					}
					i_AttacksTillMegahit[spawn_index] = 10;
					SetEntityRenderMode(spawn_index, RENDER_TRANSCOLOR);
					SetEntityRenderColor(spawn_index, 255, 255, 255, 0);
				}
			}
		}
		case 2:
		{
			float WorldSpaceVec[3]; WorldSpaceCenter(buildingentity, WorldSpaceVec);
			float WorldSpaceVec2[3]; WorldSpaceCenter(npc.index, WorldSpaceVec2);
			float flDistanceToTarget = GetVectorDistance(WorldSpaceVec, WorldSpaceVec2, true);

			int Entity_I_See;
			
			Entity_I_See = Can_I_See_Ally(npc.index, buildingentity);
			if(flDistanceToTarget < (125.0* 125.0) && IsValidAlly(npc.index, Entity_I_See))
			{
				if(npc.m_iChanged_WalkCycle != 3) 	
				{
					npc.m_iChanged_WalkCycle = 3;
					view_as<CClotBody>(iNPC).StopPathing();
					npc.m_bisWalking = false;
					npc.m_flSpeed = 0.0;
				}
				npc.SetActivity("ACT_ANTLION_JUMP_START");

				if(!HasSpecificBuff(buildingentity, "Growth Blocker"))
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
					npc.FaceTowards(WorldSpaceVec, 15000.0);
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
				view_as<CClotBody>(iNPC).SetGoalVector(AproxRandomSpaceToWalkTo);
				view_as<CClotBody>(iNPC).StartPathing();
				//Walk to building.
				if(npc.m_iChanged_WalkCycle != 4) 	
				{
					npc.m_bisWalking = true;
					npc.m_flSpeed = 210.0;
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_WALK");
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
				float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );

				float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
				float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
				
				//Predict their pos.
				if(flDistanceToTarget < npc.GetLeadRadius()) 
				{
					float vPredictedPos[3]; PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);

					npc.SetGoalVector(vPredictedPos);
				}
				else
				{
					npc.SetGoalEntity(npc.m_iTarget);
				}
				view_as<CClotBody>(iNPC).StartPathing();
				//Walk to building.
				if(npc.m_iChanged_WalkCycle != 4) 	
				{
					npc.m_bisWalking = true;
					npc.m_flSpeed = 210.0;
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_WALK");
				}
			}
			else
			{
				if(npc.m_iChanged_WalkCycle != 5) 	
				{
					npc.m_bisWalking = false;
					npc.m_flSpeed = 0.0;
					npc.m_iChanged_WalkCycle = 5;
					npc.SetActivity("ACT_IDLE");
					view_as<CClotBody>(iNPC).StopPathing();
				}
			}
		}
	}

	FleshCreeperSelfDefense(npc,GetGameTime(npc.index)); //This is for self defense, incase an enemy is too close. This isnt the FleshCreepers main thing.

	npc.PlayIdleAlertSound();
}


void FleshCreeperSelfDefense(FleshCreeper npc, float gameTime)
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
				float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
				npc.FaceTowards(VecEnemy, 15000.0);
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 0)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					
					if(target > 0) 
					{
						npc.PlayMeleeHitSound();
						if(!ShouldNpcDealBonusDamage(target))
						{
							SDKHooks_TakeDamage(target, npc.index, npc.index, 15 * npc.m_flWaveScale, DMG_CLUB);
						}
						else
						{
							SDKHooks_TakeDamage(target, npc.index, npc.index, 15 * 4.0 * npc.m_flWaveScale, DMG_CLUB);	
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
			float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);

			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);

			if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED)
			{
				int Enemy_I_See;
									
				Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
						
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;

					npc.PlayMeleeSound();

					npc.AddGesture("ACT_MELEE_ATTACK1");
							
					npc.m_flAttackHappens = gameTime + 0.5;

					npc.m_flDoingAnimation = gameTime + 0.75;
					npc.m_flNextMeleeAttack = gameTime + 0.75;
				}
			}
		}
		else
		{
			
			npc.m_flGetClosestTargetTime = 0.0;
			npc.m_iTarget = GetClosestTarget(npc.index);
		}	
	}
}

public Action FleshCreeper_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	FleshCreeper npc = view_as<FleshCreeper>(victim);
	
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	
	return Plugin_Changed;
}

public void FleshCreeper_NPCDeath(int entity)
{
	FleshCreeper npc = view_as<FleshCreeper>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
}