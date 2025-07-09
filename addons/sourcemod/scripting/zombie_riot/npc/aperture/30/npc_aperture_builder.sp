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

static const char g_IdleAlertedSounds[][] = {
	"vo/engineer_battlecry01.mp3",
	"vo/engineer_battlecry02.mp3",
	"vo/engineer_battlecry03.mp3",
	"vo/engineer_battlecry04.mp3",
	"vo/engineer_battlecry05.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/machete_swing.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/cbar_hitbod1.wav",
	"weapons/cbar_hitbod2.wav",
	"weapons/cbar_hitbod3.wav",
};

static bool b_WantTobuild[MAXENTITIES];
static bool b_AlreadyReparing[MAXENTITIES];
static float f_RandomTolerance[MAXENTITIES];
static int i_BuildingRef[MAXENTITIES];

void ApertureBuilder_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	PrecacheModel("models/player/scout.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Aperture Builder");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_aperture_builder");
	strcopy(data.Icon, sizeof(data.Icon), "engineer");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Aperture;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return ApertureBuilder(vecPos, vecAng, ally);
}
methodmap ApertureBuilder < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);

	}
	
	
	public ApertureBuilder(float vecPos[3], float vecAng[3], int ally)
	{
		ApertureBuilder npc = view_as<ApertureBuilder>(CClotBody(vecPos, vecAng, "models/player/engineer.mdl", "1.0", "700", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(ApertureBuilder_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(ApertureBuilder_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(ApertureBuilder_ClotThink);

		i_ClosestAllyCD[npc.index] = 0.0;
		
		
		//IDLE
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 300.0;

		b_WantTobuild[npc.index] = true;
		b_AlreadyReparing[npc.index] = false;
		f_RandomTolerance[npc.index] = GetRandomFloat(0.25, 0.75);
		Is_a_Medic[npc.index] = true;
		i_BuildingRef[npc.index] = -1;
				
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_wrench/c_wrench.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
	
		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/engineer/hardhat.mdl");
		

		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		
		return npc;
	}
}

public void ApertureBuilder_ClotThink(int iNPC)
{
	ApertureBuilder npc = view_as<ApertureBuilder>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
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
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}

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
						npc.SetActivity("ACT_MP_STAND_MELEE");
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
						npc.m_flSpeed = 200.0;
						npc.m_iChanged_WalkCycle = 4;
						npc.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
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
						npc.m_flSpeed = 200.0;
						npc.m_iChanged_WalkCycle = 4;
						npc.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
					}
				}
				else
				{
					if(npc.m_iChanged_WalkCycle != 5) 	
					{
						npc.m_bisWalking = false;
						npc.m_flSpeed = 0.0;
						npc.m_iChanged_WalkCycle = 5;
						npc.SetActivity("ACT_MP_STAND_MELEE");
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
					npc.SetActivity("ACT_MP_STAND_MELEE");
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
							npc.SetActivity("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS");
							view_as<CClotBody>(iNPC).StopPathing();
							npc.m_bisWalking = false;
							npc.m_flSpeed = 0.0;
						}
						i_AttacksTillMegahit[buildingentity] += 1;
						npc.FaceTowards(WorldSpaceVec, 15000.0);
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
							npc.m_flSpeed = 200.0;
							npc.m_iChanged_WalkCycle = 4;
							npc.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
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
				
				if(IsValidEnemy(npc.index,npc.m_iTarget))
				{
					npc.SetGoalEntity(npc.m_iTarget);
					view_as<CClotBody>(iNPC).StartPathing();
					if(npc.m_iChanged_WalkCycle != 4) 	
					{
						npc.m_bisWalking = true;
						npc.m_flSpeed = 200.0;
						npc.m_iChanged_WalkCycle = 4;
						npc.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
					}
				}
				else
				{
					if(npc.m_iChanged_WalkCycle != 5) 	
					{
						npc.m_bisWalking = false;
						npc.m_flSpeed = 0.0;
						npc.m_iChanged_WalkCycle = 5;
						npc.SetActivity("ACT_MP_STAND_MELEE");
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
				int spawn_index = NPC_CreateByName("npc_aperture_sentry", -1, AproxRandomSpaceToWalkTo, {0.0,0.0,0.0}, GetTeam(npc.index));
				NPC_CreateByName("npc_aperture_sentry", -1, AproxRandomSpaceToWalkTo, {0.0,0.0,0.0}, GetTeam(npc.index));
				if(spawn_index > MaxClients)
				{
					//NpcStats_CopyStats(npc.index, spawn_index);
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
					npc.SetActivity("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS");
					view_as<CClotBody>(iNPC).StopPathing();
					npc.m_bisWalking = false;
					npc.m_flSpeed = 0.0;
				}

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
					npc.m_flSpeed = 200.0;
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
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
					npc.m_flSpeed = 200.0;
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
				}
			}
			else
			{
				if(npc.m_iChanged_WalkCycle != 5) 	
				{
					npc.m_bisWalking = false;
					npc.m_flSpeed = 0.0;
					npc.m_iChanged_WalkCycle = 5;
					npc.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
					view_as<CClotBody>(iNPC).StopPathing();
				}
			}
		}
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3];
			PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}
		ApertureBuilderSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action ApertureBuilder_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	ApertureBuilder npc = view_as<ApertureBuilder>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void ApertureBuilder_NPCDeath(int entity)
{
	ApertureBuilder npc = view_as<ApertureBuilder>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
	
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

}

void ApertureBuilderSelfDefense(ApertureBuilder npc, float gameTime, int target, float distance)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
			{
							
				target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 25.0;
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 1.5;

					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);

					// Hit sound
					npc.PlayMeleeHitSound();
				} 
			}
			delete swingTrace;
		}
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
		{
			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS");
						
				npc.m_flAttackHappens = gameTime + 0.25;
				npc.m_flDoingAnimation = gameTime + 0.25;
				npc.m_flNextMeleeAttack = gameTime + 1.2;
			}
		}
	}
}