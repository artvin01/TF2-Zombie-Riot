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
	")vo/engineer_negativevocalization12.mp3"
};
static const char g_HurtSounds[][] = {
	"vo/engineer_painsharp01.mp3",
	"vo/engineer_painsharp02.mp3",
	"vo/engineer_painsharp03.mp3",
	"vo/engineer_painsharp04.mp3",
	"vo/engineer_painsharp05.mp3",
	"vo/engineer_painsharp06.mp3",
	"vo/engineer_painsharp07.mp3",
	"vo/engineer_painsharp08.mp3"
};
static const char g_IdleAlertedSounds[][] = {
	"vo/engineer_standonthepoint01.mp3",
	"vo/engineer_standonthepoint02.mp3"
};
static const char g_MeleeHitSounds[][] = {
	"weapons/wrench_hit_build_success1.wav",
	"weapons/wrench_hit_build_success2.wav"
};

static const char g_MeleeAttackSounds[] = "weapons/machete_swing.wav";

static int NPCId;

static bool b_JobFinish[MAXENTITIES];
static bool b_AdvansedConstruction[MAXENTITIES];

void VictorianMechanist_as_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Mechanist");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_mechanist");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_mechanist");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Victoria;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSound(g_MeleeAttackSounds);
	PrecacheSound("mvm/mvm_tele_deliver.wav");
	PrecacheModel("models/player/engineer.mdl");
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
	public void PlayIdleAlertSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound()
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
	}
	public void PlayDeathSound()
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlayTeleportSound()
	{
		EmitSoundToAll("mvm/mvm_tele_deliver.wav", this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds, this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	property int m_iAvangardRef
	{
		public get()							{ return this.m_iState; }
		public set(int TempValueForProperty) 	{ this.m_iState = TempValueForProperty; }
	}
	property int m_iWorkCycle
	{
		public get()							{ return i_AmountProjectiles[this.index]; }
		public set(int TempValueForProperty) 	{ i_AmountProjectiles[this.index] = TempValueForProperty; }
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
		func_NPCDeath[npc.index] = VictorianMechanist_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = VictorianMechanist_OnTakeDamage;
		func_NPCThink[npc.index] = VictorianMechanist_ClotThink;
		
		//IDLE
		KillFeed_SetKillIcon(npc.index, "wrench");
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flSpeed = 250.0;
		npc.m_flAttackHappens = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_iAvangardRef = -1;
		npc.m_iWorkCycle = 1;
		npc.m_flMeleeArmor = 1.0;
		npc.m_flRangedArmor = 1.0;
		Is_a_Medic[npc.index] = true;
		b_JobFinish[npc.index] = false;
		b_AdvansedConstruction[npc.index] = false;
		npc.m_bFUCKYOU = false;

		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		bool TeleportNow=true;
		if(StrContains(data, "no_tele") != -1)
		{
			TeleportNow=false;
		}
		
		if(StrContains(data, "fuckyou") != -1)
		{
			npc.m_bFUCKYOU = true;
		}
		
		if(StrContains(data, "advansed_construction") != -1)
		{
			b_AdvansedConstruction[npc.index] = true;
			npc.m_iWorkCycle = 0;
		}
		
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
		
		if(ally != TFTeam_Red && TeleportNow)
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

static void VictorianMechanist_ClotThink(int iNPC)
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

	if(npc.m_bFUCKYOU)
	{
		if(npc.m_flGetClosestTargetTime < GameTime)
		{
			npc.m_iTarget = GetClosestTarget(npc.index);
			npc.m_flGetClosestTargetTime = GameTime + GetRandomRetargetTime();
		}

		if(IsValidEnemy(npc.index, npc.m_iTarget))
		{
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			VictorianMechanist_SelfDefense(npc, GameTime, flDistanceToTarget);
			if(npc.m_iChanged_WalkCycle != 2) 	
			{
				Is_a_Medic[npc.index]=false;
				npc.m_iChanged_WalkCycle = 2;
				npc.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
				npc.m_bisWalking = true;
				npc.m_flSpeed = 275.0;
				npc.StartPathing();
			}
			if(flDistanceToTarget < npc.GetLeadRadius())
			{
				float vPredictedPos[3]; PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
				npc.SetGoalVector(vPredictedPos);
			}
			else
				npc.SetGoalEntity(npc.m_iTarget);
		}
	}
	else
	{
		int iAvangardEnt = EntRefToEntIndex(npc.m_iAvangardRef);
		float flDistanceToTarget=0.0;
		if(IsValidAlly(npc.index, iAvangardEnt))
		{
			float vecTarget[3]; WorldSpaceCenter(iAvangardEnt, vecTarget);
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		}
		
		switch(VictorianMechanist_Work(npc, GameTime, flDistanceToTarget))
		{
			case 0:
			{
				if(npc.m_iChanged_WalkCycle != 0) 	
				{
					npc.m_iChanged_WalkCycle = 0;
					npc.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
					npc.m_bisWalking = true;
					npc.m_flSpeed = 200.0;
					npc.StartPathing();
				}
				if(flDistanceToTarget < npc.GetLeadRadius())
				{
					float vPredictedPos[3]; PredictSubjectPosition(npc, iAvangardEnt,_,_, vPredictedPos);
					npc.SetGoalVector(vPredictedPos);
				}
				else
					npc.SetGoalEntity(iAvangardEnt);
			}
			case 1:
			{
				if(npc.m_iChanged_WalkCycle != 1) 	
				{
					npc.m_iChanged_WalkCycle = 1;
					npc.SetActivity("ACT_MP_STAND_MELEE_ALLCLASS");
					npc.m_bisWalking = false;
					npc.m_flSpeed = 0.0;
					npc.StopPathing();
				}
			}
		}
	}
	npc.PlayIdleAlertSound();
}

static int VictorianMechanist_Work(VictorianMechanist_as npc, float gameTime, float distance)
{
	if(npc.m_iWorkCycle)
	{
		int iAvangardEnt = EntRefToEntIndex(npc.m_iAvangardRef);
		switch(npc.m_iWorkCycle)
		{
			case 1:
			{
				iAvangardEnt = VictorianMechanist_Teleport_Avangard(npc);
				if(IsValidAvangard(iAvangardEnt) && GetTeam(iAvangardEnt) == GetTeam(npc.index))
				{
					npc.m_iAvangardRef=EntIndexToEntRef(iAvangardEnt);
					npc.m_iWorkCycle=2;
				}
			}
			case 2:
			{
				if(IsValidAvangard(iAvangardEnt) && GetTeam(iAvangardEnt) == GetTeam(npc.index))
				{
					if(distance > NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED)
					{
						if(npc.m_flGetClosestTargetTime < gameTime)
						{
							npc.m_iTarget = GetClosestTarget(npc.index);
							npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
						}
						float VecSelfNpc[3], vecTarget[3];
						WorldSpaceCenter(npc.index, VecSelfNpc);
						WorldSpaceCenter(npc.m_iTarget, vecTarget);
						float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
						VictorianMechanist_SelfDefense(npc, gameTime, flDistanceToTarget);
					}
					else
					{
						if(i_AttacksTillMegahit[iAvangardEnt] < 255)
						{
							if(distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
							{
								if(npc.m_flNextMeleeAttack < gameTime)
								{
									if(!npc.m_flAttackHappenswillhappen)
									{
										npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
										npc.PlayMeleeSound();
										npc.m_flAttackHappens = gameTime+0.4;
										npc.m_flDoingAnimation = gameTime + 0.4;
										npc.m_flAttackHappens_bullshit = gameTime+0.54;
										npc.m_flAttackHappenswillhappen = true;
									}
									if(npc.m_flAttackHappens < gameTime && npc.m_flAttackHappens_bullshit >= gameTime && npc.m_flAttackHappenswillhappen)
									{
										float vecTarget[3]; WorldSpaceCenter(iAvangardEnt, vecTarget);
										npc.FaceTowards(vecTarget, 15000.0);
										//8 : 13 hit to Avangard Activation
										i_AttacksTillMegahit[iAvangardEnt] += (NpcStats_VictorianCallToArms(npc.index) ? 35 : 20);
										if(!HasSpecificBuff(iAvangardEnt, "Growth Blocker"))
										{
											int MaxHealth = ReturnEntityMaxHealth(iAvangardEnt);
											HealEntityGlobal(npc.index, iAvangardEnt, float(MaxHealth)*(NpcStats_VictorianCallToArms(npc.index) ? 0.15 : 0.1), 1.0);
										}
										npc.PlayMeleeHitSound();
										npc.m_flNextMeleeAttack = gameTime + 0.8;
										npc.m_flAttackHappenswillhappen = false;
									}
									else if(npc.m_flAttackHappens_bullshit < gameTime && npc.m_flAttackHappenswillhappen)
									{
										npc.m_flAttackHappenswillhappen = false;
										npc.m_flNextMeleeAttack = gameTime + 0.8;
									}
								}
								return 1;
							}
						}
						else
						{
							npc.m_iWorkCycle=3;
							b_JobFinish[npc.index]=true;
						}
					}
					return 0;
				}
				else
				{
					npc.m_iWorkCycle=0;
				}
			}
			case 3:
			{
				if(IsValidAvangard(iAvangardEnt) && GetTeam(iAvangardEnt) == GetTeam(npc.index))
				{
					if(distance > NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*1.25)
					{
						if(npc.m_flGetClosestTargetTime < gameTime)
						{
							npc.m_iTarget = GetClosestTarget(npc.index);
							npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
						}
						float VecSelfNpc[3], vecTarget[3];
						WorldSpaceCenter(npc.index, VecSelfNpc);
						WorldSpaceCenter(npc.m_iTarget, vecTarget);
						float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
						VictorianMechanist_SelfDefense(npc, gameTime, flDistanceToTarget);
					}
					else if(!HasSpecificBuff(iAvangardEnt, "Growth Blocker"))
					{
						int MaxHealth = ReturnEntityMaxHealth(iAvangardEnt);
						int Health = GetEntProp(iAvangardEnt, Prop_Data, "m_iHealth");
						if(distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*1.25
						&& (Health<MaxHealth || NpcStats_VictorianCallToArms(npc.index)))
						{
							if(npc.m_flNextMeleeAttack < gameTime)
							{
								if(!npc.m_flAttackHappenswillhappen)
								{
									npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
									npc.PlayMeleeSound();
									npc.m_flAttackHappens = gameTime+0.4;
									npc.m_flDoingAnimation = gameTime + 0.4;
									npc.m_flAttackHappens_bullshit = gameTime+0.54;
									npc.m_flAttackHappenswillhappen = true;
								}
								if(npc.m_flAttackHappens < gameTime && npc.m_flAttackHappens_bullshit >= gameTime && npc.m_flAttackHappenswillhappen)
								{
									float vecTarget[3]; WorldSpaceCenter(iAvangardEnt, vecTarget);
									npc.FaceTowards(vecTarget, 15000.0);
									if(Health<MaxHealth)
										HealEntityGlobal(npc.index, iAvangardEnt, float(MaxHealth)*(NpcStats_VictorianCallToArms(npc.index) ? 0.15 : 0.1), 1.0);
									else if(NpcStats_VictorianCallToArms(npc.index))
										GrantEntityArmor(iAvangardEnt, false, 1.5, 0.5, 0, float(MaxHealth / 400));
									npc.PlayMeleeHitSound();
									npc.m_flNextMeleeAttack = gameTime + 0.8;
									npc.m_flAttackHappenswillhappen = false;
								}
								else if(npc.m_flAttackHappens_bullshit < gameTime && npc.m_flAttackHappenswillhappen)
								{
									npc.m_flAttackHappenswillhappen = false;
									npc.m_flNextMeleeAttack = gameTime + 0.8;
								}
							}
						}
						return (distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED ? 1 : 0);
					}
					return 0;
				}
				else
				{
					npc.m_iWorkCycle=0;
				}
			}
		}
	}
	else
	{
		if(b_JobFinish[npc.index] || b_AdvansedConstruction[npc.index])
		{
			bool IsValidRobot;
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
			for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
			{
				int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
				if(IsValidAvangard(entity) && GetTeam(entity) == GetTeam(npc.index))
				{
					float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
					float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
					if(flDistanceToTarget<(5000.0*5000.0) || b_AdvansedConstruction[npc.index])
					{
						npc.m_iAvangardRef = EntIndexToEntRef(entity);
						IsValidRobot=true;
						break;
					}
				}
			}
			if(IsValidRobot)
				npc.m_iWorkCycle=2;
			else
				npc.m_bFUCKYOU=true;
		}
		else
			npc.m_iWorkCycle=1;
	}
	return 1;
}

static void VictorianMechanist_SelfDefense(VictorianMechanist_as npc, float gameTime, float distance)
{
	if(distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
	{
		if(npc.m_flNextMeleeAttack < gameTime)
		{
			if(!npc.m_flAttackHappenswillhappen)
			{
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
				npc.PlayMeleeSound();
				npc.m_flAttackHappens = gameTime+0.4;
				npc.m_flDoingAnimation = gameTime + 0.4;
				npc.m_flAttackHappens_bullshit = gameTime+0.54;
				npc.m_flAttackHappenswillhappen = true;
			}
			if(npc.m_flAttackHappens < gameTime && npc.m_flAttackHappens_bullshit >= gameTime && npc.m_flAttackHappenswillhappen)
			{
				Handle swingTrace;
				float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
				npc.FaceTowards(vecTarget, 15000.0);
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget))
				{
					int target = TR_GetEntityIndex(swingTrace);
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					if(IsValidEnemy(npc.index, target))
					{
						float damageDealt = 65.0;
						if(ShouldNpcDealBonusDamage(target))
							damageDealt*=5.0;
						SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);
						npc.PlayMeleeHitSound();
						
						if(!IsValidEnemy(npc.index, target))
						{
							npc.m_flGetClosestTargetTime=0.0;
						}
					}
				}
				delete swingTrace;
				npc.m_flNextMeleeAttack = gameTime + 0.8;
				npc.m_flAttackHappenswillhappen = false;
			}
			else if(npc.m_flAttackHappens_bullshit < gameTime && npc.m_flAttackHappenswillhappen)
			{
				npc.m_flAttackHappenswillhappen = false;
				npc.m_flNextMeleeAttack = gameTime + 0.8;
			}
		}
	}
}

static Action VictorianMechanist_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
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

static void VictorianMechanist_NPCDeath(int entity)
{
	VictorianMechanist_as npc = view_as<VictorianMechanist_as>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	
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

static int VictorianMechanist_Teleport_Avangard(VictorianMechanist_as npc)
{
	float AproxRandomSpaceToWalkTo[3];

	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", AproxRandomSpaceToWalkTo);

	AproxRandomSpaceToWalkTo[2] += 50.0;

	AproxRandomSpaceToWalkTo[0] = GetRandomFloat((AproxRandomSpaceToWalkTo[0] - 800.0),(AproxRandomSpaceToWalkTo[0] + 800.0));
	AproxRandomSpaceToWalkTo[1] = GetRandomFloat((AproxRandomSpaceToWalkTo[1] - 800.0),(AproxRandomSpaceToWalkTo[1] + 800.0));

	Handle ToGroundTrace = TR_TraceRayFilterEx(AproxRandomSpaceToWalkTo, view_as<float>( { 90.0, 0.0, 0.0 } ), GetSolidMask(npc.index), RayType_Infinite, BulletAndMeleeTrace, npc.index);
	
	TR_GetEndPosition(AproxRandomSpaceToWalkTo, ToGroundTrace);
	delete ToGroundTrace;

	CNavArea area = TheNavMesh.GetNearestNavArea(AproxRandomSpaceToWalkTo, true);
	if(area == NULL_AREA)
		return -1;

	int NavAttribs = area.GetAttributes();
	if(NavAttribs & NAV_MESH_AVOID)
		return -1;

	area.GetCenter(AproxRandomSpaceToWalkTo);

	AproxRandomSpaceToWalkTo[2] += 18.0;
	
	static float hullcheckmaxs_Player_Again[3];
	static float hullcheckmins_Player_Again[3];

	hullcheckmaxs_Player_Again = view_as<float>( { 30.0, 30.0, 82.0 } ); //Fat
	hullcheckmins_Player_Again = view_as<float>( { -30.0, -30.0, 0.0 } );	

	if(IsSpaceOccupiedIgnorePlayers(AproxRandomSpaceToWalkTo, hullcheckmins_Player_Again, hullcheckmaxs_Player_Again, npc.index) || IsSpaceOccupiedOnlyPlayers(AproxRandomSpaceToWalkTo, hullcheckmins_Player_Again, hullcheckmaxs_Player_Again, npc.index))
		return -1;

	if(IsPointHazard(AproxRandomSpaceToWalkTo)) //Retry.
		return -1;
	
	AproxRandomSpaceToWalkTo[2] += 18.0;
	if(IsPointHazard(AproxRandomSpaceToWalkTo)) //Retry.
		return -1;
	
	AproxRandomSpaceToWalkTo[2] -= 18.0;
	AproxRandomSpaceToWalkTo[2] -= 18.0;
	AproxRandomSpaceToWalkTo[2] -= 18.0;

	if(IsPointHazard(AproxRandomSpaceToWalkTo)) //Retry.
		return -1;
	
	AproxRandomSpaceToWalkTo[2] += 18.0;
	AproxRandomSpaceToWalkTo[2] += 18.0;
	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);

	float flDistanceToBuild = GetVectorDistance(AproxRandomSpaceToWalkTo, WorldSpaceVec, true);
	
	if(flDistanceToBuild < (500.0 * 500.0))
		return -1; //The building is too close, we want to retry! it is unfair otherwise.
	//Retry.

	//Timeout
	int spawn_index = NPC_CreateByName("npc_avangard", -1, AproxRandomSpaceToWalkTo, {0.0,0.0,0.0}, GetTeam(npc.index));
	if(spawn_index > MaxClients)
	{
		NpcStats_CopyStats(npc.index, spawn_index);
		int health = ReturnEntityMaxHealth(npc.index) * 5;
		fl_Extra_MeleeArmor[spawn_index] = fl_Extra_MeleeArmor[npc.index];
		fl_Extra_RangedArmor[spawn_index] = fl_Extra_RangedArmor[npc.index];
		fl_Extra_Speed[spawn_index] = fl_Extra_Speed[npc.index];
		fl_Extra_Damage[spawn_index] = fl_Extra_Damage[npc.index];
		if(GetTeam(npc.index) != TFTeam_Red)
			NpcAddedToZombiesLeftCurrently(spawn_index, true);
		i_AttacksTillMegahit[spawn_index] = 10;
		SetEntProp(spawn_index, Prop_Data, "m_iHealth", health);
		SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", health);
		
		return spawn_index;
	}
	return -1;
}

static bool IsValidAvangard(int entity)
{
	return (IsValidEntity(entity) && i_NpcInternalId[entity] == VictorianAvangard_ID() && !b_NpcHasDied[entity]);
}