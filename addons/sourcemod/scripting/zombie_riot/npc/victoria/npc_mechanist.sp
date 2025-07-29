#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	")vo/engineer_negativevocalization01.mp3",
	")vo/engineer_negativevocalization02.mp3",
	")vo/engineer_negativevocalization03.mp3",
	")vo/engineer_negativevocalization04.mp3",
	")vo/engineer_negativevocalization05.mp3",
	")vo/engineer_negativevocalization06.mp3",
	")vo/engineer_negativevocalization07.mp3",
	")vo/engineer_negativevocalization08.mp3",
	")vo/engineer_negativevocalization09.mp3",
	")vo/engineer_negativevocalization10.mp3",
	")vo/engineer_negativevocalization11.mp3",
	")vo/engineer_negativevocalization12.mp3",
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
	"vo/engineer_standonthepoint01.mp3",
	"vo/engineer_standonthepoint02.mp3",
	"vo/engineer_standonthepoint04.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/machete_swing.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/wrench_hit_build_success1.wav",
	"weapons/wrench_hit_build_success2.wav",
};

static bool b_WantTobuild[MAXENTITIES];
static bool b_AlreadyReparing[MAXENTITIES];
static float f_RandomTolerance[MAXENTITIES];
static int i_BuildingRef[MAXENTITIES];


static int NPCId;

void VictorianMechanist_as_OnMapStart_NPC()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheModel("models/player/engineer.mdl");
	PrecacheSound("mvm/mvm_tele_deliver.wav");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Mechanist");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_mechanist");
	data.Category = Type_Victoria;
	data.Func = ClotSummon;
	strcopy(data.Icon, sizeof(data.Icon), "victoria_mechanist");
	data.IconCustom = true;
	data.Flags = 0;
	NPCId = NPC_Add(data);
}

int VictorianMechanist_ID()
{
	return NPCId;
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return VictorianMechanist_as(vecPos, vecAng, ally, data);
}

methodmap VictorianMechanist_as < CClotBody
{
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayDeathSound() {
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayTeleportSound(){
		EmitSoundToAll("mvm/mvm_tele_deliver.wav", this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	
	public VictorianMechanist_as(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		VictorianMechanist_as npc = view_as<VictorianMechanist_as>(CClotBody(vecPos, vecAng, "models/player/engineer.mdl", "1.2", "35000", ally, false));
		
		i_NpcWeight[npc.index] = 3;

		int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(3);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		func_NPCDeath[npc.index] = view_as<Function>(Internal_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Internal_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Internal_ClotThink);
		
		//IDLE
		npc.m_flSpeed = 250.0;
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_flNextMeleeAttack = 0.0;
		
		func_NPCDeath[npc.index] = view_as<Function>(Internal_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Internal_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Internal_ClotThink);
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPSOUND_NORMAL;		
		
		
		i_ClosestAllyCD[npc.index] = 0.0;

		npc.m_iState = 0;
		npc.m_flSpeed = 200.0;
		b_AlreadyReparing[npc.index] = false;
		f_RandomTolerance[npc.index] = GetRandomFloat(0.25, 0.75);
		Is_a_Medic[npc.index] = true;
		npc.m_bFUCKYOU = false;
		if(!StrContains(data, "only"))
		{
			npc.m_bFUCKYOU = true;
			b_WantTobuild[npc.index] = false;
		}
		else
		{
			npc.m_bFUCKYOU = false;
			b_WantTobuild[npc.index] = true;
		}
		
		npc.m_flMeleeArmor = 1.0;
		npc.m_flRangedArmor = 1.0;
		i_BuildingRef[npc.index] = -1;
		
		npc.m_flAttackHappens = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/engineer/sum19_brain_interface/sum19_brain_interface.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 1);
		SetEntityRenderColor(npc.m_iWearable1, 100, 100, 100, 255);
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/engineer/sum23_cranium_cooler/sum23_cranium_cooler.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);
		SetEntityRenderColor(npc.m_iWearable4, 100, 100, 100, 255);
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/engineer/dec23_sleuth_suit_style3/dec23_sleuth_suit_style3.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/engineer/hwn2024_delldozer_style3/hwn2024_delldozer_style3.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/engineer/hwn2024_contaminated_carryall/hwn2024_contaminated_carryall.mdl");
		SetVariantString("1.5");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", 1);

		npc.m_iWearable6 = npc.EquipItem("head", "models/weapons/c_models/c_wrench/c_wrench.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");
		
		if(ally != TFTeam_Red)
		{
			if(LastSpawnDiversio < GetGameTime())
			{
				EmitSoundToAll("mvm/mvm_tele_deliver.wav", _, _, _, _, 1.0);
				EmitSoundToAll("mvm/mvm_tele_deliver.wav", _, _, _, _, 1.0);
			}
			LastSpawnDiversio = GetGameTime() + 20.0;
			if(!zr_disablerandomvillagerspawn.BoolValue && !DisableRandomSpawns)
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
			float Vec[3];
			GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", Vec);
			ParticleEffectAt(Vec, "teleporter_mvm_bot_persist", 5.0);
		}
		
		return npc;
	}
	
	
}

//TODO 
//Rewrite
static void Internal_ClotThink(int iNPC)
{
	VictorianMechanist_as npc = view_as<VictorianMechanist_as>(iNPC);
	
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
		if(npc.m_bFUCKYOU)
			Behavior = 4;
		else
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
						npc.SetActivity("ACT_MP_RUN_MELEE");
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
						npc.SetActivity("ACT_MP_RUN_MELEE");
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
					if(flDistanceToTarget < (100.0* 100.0) && IsValidAlly(npc.index, Entity_I_See))
					{
						if(npc.m_iChanged_WalkCycle != 3) 	
						{
							npc.m_iChanged_WalkCycle = 3;
							npc.SetActivity("ACT_MP_RUN_MELEE");
							view_as<CClotBody>(iNPC).StopPathing();
							npc.m_bisWalking = false;
							npc.m_flSpeed = 0.0;
						}
						if(GetGameTime() > npc.m_flNextMeleeAttack)
						{
							npc.m_flNextMeleeAttack = GetGameTime() + 0.8;
							npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
							npc.PlayMeleeHitSound();
						}
						int healthbuilding = GetEntProp(buildingentity, Prop_Data, "m_iHealth");
						int Maxhealthbuilding = GetEntProp(buildingentity, Prop_Data, "m_iMaxHealth");
						if(healthbuilding<Maxhealthbuilding)
						{
							int AddHealth = Maxhealthbuilding / 1000;
							if(AddHealth < 1)
							{
								AddHealth = 1;
							}
							healthbuilding += AddHealth;
							if(healthbuilding > Maxhealthbuilding)
							{
								Maxhealthbuilding = healthbuilding;
							}
							SetEntProp(buildingentity, Prop_Data, "m_iHealth",healthbuilding);
						}
						i_AttacksTillMegahit[buildingentity] += 1;
						if(NpcStats_VictorianCallToArms(npc.index))
						{
							i_AttacksTillMegahit[buildingentity] += 1;
						}
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
							npc.SetActivity("ACT_MP_RUN_MELEE");
						}
					}					
				}
				else
				{	
					b_WantTobuild[npc.index] = false;
					npc.m_bFUCKYOU = true;
				}
			}
			else
			{
				npc.m_bisWalking = true;

				Mechanist_AS_SelfDefense(npc,GetGameTime(npc.index)); //This is for self defense, incase an enemy is too close. This isnt the villagers main thing.
				
				if(IsValidEnemy(npc.index,npc.m_iTarget))
				{
					npc.SetGoalEntity(npc.m_iTarget);
					view_as<CClotBody>(iNPC).StartPathing();
					if(npc.m_iChanged_WalkCycle != 4) 	
					{
						npc.m_bisWalking = true;
						npc.m_flSpeed = 200.0;
						npc.m_iChanged_WalkCycle = 4;
						npc.SetActivity("ACT_MP_RUN_MELEE");
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
				AproxRandomSpaceToWalkTo[2] += 18.0;
				float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);

				float flDistanceToBuild = GetVectorDistance(AproxRandomSpaceToWalkTo, WorldSpaceVec, true);
				
				if(flDistanceToBuild < (500.0 * 500.0))
				{
					return; //The building is too close, we want to retry! it is unfair otherwise.
				}
				//Retry.

				//Timeout
				//npc.m_flNextMeleeAttack = GetGameTime(npc.index) + GetRandomFloat(10.0, 20.0);
				int spawn_index = NPC_CreateByName("npc_avangard", -1, AproxRandomSpaceToWalkTo, {0.0,0.0,0.0}, GetTeam(npc.index));
				if(spawn_index > MaxClients)
				{
					NpcStats_CopyStats(npc.index, spawn_index);
					int health = ReturnEntityMaxHealth(npc.index) * 5;
					fl_Extra_MeleeArmor[spawn_index] = fl_Extra_MeleeArmor[npc.index];
					fl_Extra_RangedArmor[spawn_index] = fl_Extra_RangedArmor[npc.index];
					fl_Extra_Speed[spawn_index] = fl_Extra_Speed[npc.index];
					fl_Extra_Damage[spawn_index] = fl_Extra_Damage[npc.index];
					i_BuildingRef[iNPC] = EntIndexToEntRef(spawn_index);
					if(GetTeam(iNPC) != TFTeam_Red)
						NpcAddedToZombiesLeftCurrently(spawn_index, true);
					i_AttacksTillMegahit[spawn_index] = 10;
					SetEntProp(spawn_index, Prop_Data, "m_iHealth", health);
					SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", health);
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
			if(flDistanceToTarget < (100.0* 100.0) && IsValidAlly(npc.index, Entity_I_See))
			{
				if(npc.m_iChanged_WalkCycle != 3) 	
				{
					npc.m_iChanged_WalkCycle = 3;
					npc.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
					view_as<CClotBody>(iNPC).StopPathing();
					npc.m_bisWalking = false;
					npc.m_flSpeed = 0.0;
				}
				if(GetGameTime() > npc.m_flNextMeleeAttack)
				{
					npc.m_flNextMeleeAttack = GetGameTime() + 0.8;
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
					npc.PlayMeleeHitSound();
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
					npc.SetActivity("ACT_MP_RUN_MELEE");
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
					npc.SetActivity("ACT_MP_RUN_MELEE");
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
		case 4:
		{
			bool IsValidRobot=false;
			Mechanist_AS_SelfDefense(npc,GetGameTime(npc.index));
			float npcpos[3], entitypos[3], distance;
			GetAbsOrigin(npc.m_iWearable3, npcpos);
			for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
			{
				int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
				if(IsValidEntity(entity) && i_NpcInternalId[entity] == VictorianAvangard_ID()
				&& !b_NpcHasDied[entity] && GetTeam(entity) == GetTeam(iNPC))
				{
					GetEntPropVector(entity, Prop_Send, "m_vecOrigin", entitypos);
					distance = GetVectorDistance(npcpos, entitypos);
					if(distance<5000.0)
					{
						if(i_AttacksTillMegahit[entity] < 255)
						{
							i_BuildingRef[iNPC] = EntIndexToEntRef(entity);
							IsValidRobot=true;
							break;
						}
						else
						{
							i_BuildingRef[iNPC] = EntIndexToEntRef(entity);
							break;
						}
					}
				}
			}
			if(IsValidRobot)
			{
				b_WantTobuild[npc.index] = true;
				npc.m_bFUCKYOU = false;
			}
		}
	}
	npc.PlayIdleAlertSound();
}

void Mechanist_AS_SelfDefense(VictorianMechanist_as npc, float gameTime)
{
	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;

	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);

		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius()) {
			
			float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex,_,_, vPredictedPos);
			
		/*	int color[4];
			color[0] = 255;
			color[1] = 255;
			color[2] = 0;
			color[3] = 255;
		
			int xd = PrecacheModel("materials/sprites/laserbeam.vmt");
		
			TE_SetupBeamPoints(vPredictedPos, vecTarget, xd, xd, 0, 0, 0.25, 0.5, 0.5, 5, 5.0, color, 30);
			TE_SendToAllInRange(vecTarget, RangeType_Visibility);*/
			
			npc.SetGoalVector(vPredictedPos);
		} else {
			npc.SetGoalEntity(PrimaryThreatIndex);
		}
		if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
		{
			if(npc.m_flNextMeleeAttack < gameTime)
			{
				//Play attack ani
				if(!npc.m_flAttackHappenswillhappen)
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
					npc.PlayMeleeSound();
					npc.m_flAttackHappens = gameTime+0.4;
					npc.m_flAttackHappens_bullshit = gameTime+0.54;
					npc.m_flAttackHappenswillhappen = true;
				}
					
				if (npc.m_flAttackHappens < gameTime && npc.m_flAttackHappens_bullshit >= gameTime && npc.m_flAttackHappenswillhappen)
				{
					Handle swingTrace;
					npc.FaceTowards(vecTarget, 20000.0);
					if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex))
					{
						int target = TR_GetEntityIndex(swingTrace);	
						
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);
						
						if(target > 0) 
						{
							if(ShouldNpcDealBonusDamage(target))
								SDKHooks_TakeDamage(target, npc.index, npc.index, 325.0, DMG_CLUB, -1, _, vecHit);
							else
								SDKHooks_TakeDamage(target, npc.index, npc.index, 65.0, DMG_CLUB, -1, _, vecHit);
							// Hit sound
							npc.PlayMeleeHitSound();
						} 
					}
					delete swingTrace;
					npc.m_flNextMeleeAttack = gameTime + 0.8;
					npc.m_flAttackHappenswillhappen = false;
				}
				else if (npc.m_flAttackHappens_bullshit < gameTime && npc.m_flAttackHappenswillhappen)
				{
					npc.m_flAttackHappenswillhappen = false;
					npc.m_flNextMeleeAttack = gameTime + 0.8;
				}
			}
		}
	}
}

static Action Internal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VictorianMechanist_as npc = view_as<VictorianMechanist_as>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;

	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void Internal_NPCDeath(int entity)
{
	VictorianMechanist_as npc = view_as<VictorianMechanist_as>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
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
}