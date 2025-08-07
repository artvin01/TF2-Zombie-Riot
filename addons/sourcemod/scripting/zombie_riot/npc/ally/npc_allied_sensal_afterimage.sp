#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"weapons/physcannon/energy_sing_explosion2.wav",
};
static const char g_ChargeSounds[][] = {
	"weapons/physcannon/physcannon_charge.wav",
};


void AlliedSensalAbility_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_ChargeSounds));	   i++) { PrecacheSound(g_ChargeSounds[i]);	   }
	PrecacheModel("models/weapons/c_models/c_claymore/c_claymore.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Allied Sensal Afterimage");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_allied_sensal_afterimage");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return AlliedSensalAbility(client, vecPos, vecAng);
}
methodmap AlliedSensalAbility < CClotBody
{
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_AUTO, 80, _, 0.9, 100);
	}
	public void PlayChargeSound() 
	{
		EmitSoundToAll(g_ChargeSounds[GetRandomInt(0, sizeof(g_ChargeSounds) - 1)], this.index, SNDCHAN_AUTO, 80, _, 0.9, 100);
	}

	
	public AlliedSensalAbility(int client, float vecPos[3], float vecAng[3])
	{
		AlliedSensalAbility npc = view_as<AlliedSensalAbility>(CClotBody(vecPos, vecAng, "models/player/soldier.mdl", "1.0", "100", TFTeam_Red, true));
		
		i_NpcWeight[npc.index] = 999;
		SetEntPropEnt(npc.index,   Prop_Send, "m_hOwnerEntity", client);
		
		int ModelIndex;
		char ModelPath[255];
		int entity, i;
			
		if((i_CustomModelOverrideIndex[client] < BARNEY || !b_HideCosmeticsPlayer[client]))
		{
			SetEntityRenderMode(npc.index, RENDER_TRANSALPHA);
			SetEntityRenderColor(npc.index, 0, 0, 0, 0);
		}
		else
		{
			SetEntityRenderMode(npc.index, RENDER_TRANSALPHA);
			SetEntityRenderColor(npc.index, 255, 255, 255, 125);
		}


		SetVariantInt(GetEntProp(client, Prop_Send, "m_nBody"));
		AcceptEntityInput(npc.index, "SetBodyGroup");

		while(TF2U_GetWearable(client, entity, i, "tf_wearable"))
		{

			if(entity == EntRefToEntIndex(Armor_Wearable[client]) || i_WeaponVMTExtraSetting[entity] != -1)
				continue;
				
			if(EntRefToEntIndex(i_Viewmodel_PlayerModel[client]) != entity || (i_CustomModelOverrideIndex[client] < BARNEY || !b_HideCosmeticsPlayer[client]))
			{
				ModelIndex = GetEntProp(entity, Prop_Data, "m_nModelIndex");
				if(ModelIndex < 0)
				{
					GetEntPropString(entity, Prop_Data, "m_ModelName", ModelPath, sizeof(ModelPath));
				}
				else
				{
					ModelIndexToString(ModelIndex, ModelPath, sizeof(ModelPath));
				}
			}
			if(!ModelPath[0])
				continue;

			for(int Repeat=0; Repeat<7; Repeat++)
			{
				int WearableIndex = i_Wearable[npc.index][Repeat];
				if(!IsValidEntity(WearableIndex))
				{	
					int WearablePostIndex = npc.EquipItem("head", ModelPath);
					if(IsValidEntity(WearablePostIndex))
					{	
						if(entity == EntRefToEntIndex(i_Viewmodel_PlayerModel[client]))
						{
							SetVariantInt(GetEntProp(client, Prop_Send, "m_nBody"));
							AcceptEntityInput(WearablePostIndex, "SetBodyGroup");
						}
						SetEntityRenderMode(WearablePostIndex, RENDER_TRANSCOLOR); //Make it half invis.
						SetEntityRenderColor(WearablePostIndex, 255, 255, 255, 125);
						i_Wearable[npc.index][Repeat] = EntIndexToEntRef(WearablePostIndex);
					}
					break;
				}
			}
		}
		npc.m_bisWalking = false;
	
		npc.AddActivityViaSequence("taunt_the_fist_bump_fistbump");
		npc.SetPlaybackRate(2.0);	
		npc.PlayChargeSound();
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_bDissapearOnDeath = true;
		b_NoKnockbackFromSources[npc.index] = true;
		npc.m_bNoKillFeed = true;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;

		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		b_NpcIsInvulnerable[npc.index] = true;
		ApplyStatusEffect(npc.index, npc.index, "Clear Head", 999999.0);	
		func_NPCDeath[npc.index] = AlliedSensalAbility_NPCDeath;
		func_NPCThink[npc.index] = AlliedSensalAbility_ClotThink;

		npc.m_iState = 0;
		npc.m_flSpeed = 0.0;
		npc.m_flAttackHappens_2 = GetGameTime() + 0.75;
		npc.m_flRangedSpecialDelay = GetGameTime() + 1.5;
		
		npc.m_flMeleeArmor = 1.0;
		npc.m_flRangedArmor = 1.0;

		npc.StopPathing();
		b_DoNotUnStuck[npc.index] = true;
		b_NoGravity[npc.index] = true;
		SetEntityCollisionGroup(npc.index, 1); //Dont Touch Anything.
		SetEntProp(npc.index, Prop_Send, "m_usSolidFlags", 12); 
		SetEntProp(npc.index, Prop_Data, "m_nSolidType", 6); 
		if(IsValidEntity(npc.m_iTeamGlow))
			RemoveEntity(npc.m_iTeamGlow);

		return npc;
	}
}

public void AlliedSensalAbility_ClotThink(int iNPC)
{
	AlliedSensalAbility npc = view_as<AlliedSensalAbility>(iNPC);

	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
		return;
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	if(npc.m_flAttackHappens_2)
	{
		if(npc.m_flAttackHappens_2 < GetGameTime())
		{
			npc.m_flAttackHappens_2 = 0.0;
			if(IsValidEnemy(npc.index, npc.m_iTarget, true, true))
			{
				float EnemyVecPos[3]; WorldSpaceCenter(npc.m_iTarget, EnemyVecPos);
				npc.FaceTowards(EnemyVecPos, 30000.0);
				AlliedSensalFireLaser(npc.m_iTarget, npc);
			}
			else
			{
				int GetClosestEnemyToAttack;
				GetClosestEnemyToAttack = GetClosestTarget(npc.index,_,_,_,_,_,_,true,_,_,true);
				npc.m_iTarget = GetClosestEnemyToAttack;
				if(npc.m_iTarget > 0)
				{
					float EnemyVecPos[3]; WorldSpaceCenter(npc.m_iTarget, EnemyVecPos);
					npc.FaceTowards(EnemyVecPos, 30000.0);
					AlliedSensalFireLaser(npc.m_iTarget, npc);
				}
			}
		}
		return;
	}
	if(npc.m_flRangedSpecialDelay)
	{
		if(npc.m_flRangedSpecialDelay < GetGameTime())
		{
			RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
		}
	}
}

public void AlliedSensalAbility_NPCDeath(int entity)
{
	AlliedSensalAbility npc = view_as<AlliedSensalAbility>(entity);

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

#define SENSAL_MAX_TARGETS_HIT 10

static int SensalAllied_BEAM_BuildingHit[SENSAL_MAX_TARGETS_HIT];

void Allied_Sensal_InitiateLaserAttack(int owner, int entity, float VectorTarget[3], float VectorStart[3], AlliedSensalAbility npc)
{

	float vecForward[3], vecRight[3], Angles[3];

	MakeVectorFromPoints(VectorStart, VectorTarget, vecForward);
	GetVectorAngles(vecForward, Angles);
	GetAngleVectors(vecForward, vecForward, vecRight, VectorTarget);

	Handle trace = TR_TraceRayFilterEx(VectorStart, Angles, 11, RayType_Infinite, AlliedSensal_TraceWallsOnly);
	if (TR_DidHit(trace))
	{
		TR_GetEndPosition(VectorTarget, trace);
		
		float lineReduce = 10.0 * 2.0 / 3.0;
		float curDist = GetVectorDistance(VectorStart, VectorTarget, false);
		if (curDist > lineReduce)
		{
			ConformLineDistance(VectorTarget, VectorStart, VectorTarget, curDist - lineReduce);
		}
	}
	delete trace;


	int red = 65;
	int green = 65;
	int blue = 255;
	float diameter = float(40);
	//we set colours of the differnet laser effects to give it more of an effect
	
	float flPos[3];
	float flAng[3];
	GetAttachment(entity, "effect_hand_r", flPos, flAng);

	int colorLayer4[4];
	SetColorRGBA(colorLayer4, red, green, blue, 60);
	int colorLayer3[4];
	SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, 60);
	int colorLayer2[4];
	SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, 60);
	int colorLayer1[4];
	SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, 60);

	TE_SetupBeamPoints(flPos, VectorTarget, Shared_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 1.0, colorLayer1, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(flPos, VectorTarget, Shared_BEAM_Laser, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 0.5 * 1.28), ClampBeamWidth(diameter * 0.5 * 1.28), 0, 1.0, colorLayer2, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(flPos, VectorTarget, Shared_BEAM_Laser, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 0.8 * 1.28), ClampBeamWidth(diameter * 0.8 * 1.28), 0, 1.0, colorLayer3, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(flPos, VectorTarget, Shared_BEAM_Laser, 0, 0, 0, 0.33, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 1.0, colorLayer4, 3);
	TE_SendToAll(0.0);

	float hullMin[3];
	float hullMax[3];
	hullMin[0] = -float(40);
	hullMin[1] = hullMin[0];
	hullMin[2] = hullMin[0];
	hullMax[0] = -hullMin[0];
	hullMax[1] = -hullMin[1];
	hullMax[2] = -hullMin[2];
	npc.PlayDeathSound();
	npc.DispatchParticleEffect(npc.index, "mvm_soldier_shockwave", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("effect_hand_r"), PATTACH_POINT_FOLLOW, true);
	
	for (int building = 0; building < SENSAL_MAX_TARGETS_HIT; building++)
	{
		SensalAllied_BEAM_BuildingHit[building] = 0;
	}
	trace = TR_TraceHullFilterEx(VectorStart, VectorTarget, hullMin, hullMax, 1073741824, BEAM_TraceUsers, entity);	// 1073741824 is CONTENTS_LADDER?
	delete trace;

	int Weapon = EntRefToEntIndex(i_Changed_WalkCycle[npc.index]);
	float DamageFallOff = 1.0;
	int EnemiesHit = 0;
	for (int building = 0; building < SENSAL_MAX_TARGETS_HIT; building++)
	{
		if (SensalAllied_BEAM_BuildingHit[building] > 0)
		{
			if(IsValidEntity(SensalAllied_BEAM_BuildingHit[building]))
			{
				float damage = fl_heal_cooldown[entity];

				SensalCauseKnockback(npc.index, SensalAllied_BEAM_BuildingHit[building]);
				float EnemyVecPos[3]; WorldSpaceCenter(SensalAllied_BEAM_BuildingHit[building], EnemyVecPos);
				SDKHooks_TakeDamage(SensalAllied_BEAM_BuildingHit[building], owner, owner, damage * DamageFallOff, DMG_CLUB, Weapon, NULL_VECTOR, EnemyVecPos, _ , ZR_DAMAGE_REFLECT_LOGIC);	// 2048 is DMG_NOGIB?
				DamageFallOff *= LASER_AOE_DAMAGE_FALLOFF;	
				EnemiesHit += 1;
				if(EnemiesHit >= 5)
				{
					break;
				}
			}
		}
	}
}

static bool BEAM_TraceUsers(int entity, int contentsMask, int iExclude)
{
	if (IsValidEntity(entity))
	{
		if(IsValidEnemy(iExclude, entity, true, true))
		{
			for(int i=0; i < (SENSAL_MAX_TARGETS_HIT); i++)
			{
				if(!SensalAllied_BEAM_BuildingHit[i])
				{
					SensalAllied_BEAM_BuildingHit[i] = entity;
					break;
				}
			}
		}
	}
	return false;
}
void AlliedSensalFireLaser(int target, AlliedSensalAbility npc)
{
	int owner = GetEntPropEnt(npc.index, Prop_Data, "m_hOwnerEntity");
	float SelfVecPos[3]; WorldSpaceCenter(npc.index, SelfVecPos);
	float TargetVecPos[3]; WorldSpaceCenter(target, TargetVecPos);
	Allied_Sensal_InitiateLaserAttack(owner, npc.index, TargetVecPos, SelfVecPos, npc);
}

public bool AlliedSensal_TraceWallsOnly(int entity, int contentsMask)
{
	return !entity;
}



#define SENSAL_KNOCKBACK		750.0	// Knockback when push level and enemy weight is the same
#define SENSAL_STUN_RATIO		0.00075	// Knockback when push level and enemy weight is the same

void SensalCauseKnockback(int attacker, int victim, float RatioExtra = 1.0, bool dostun = true)
{
	int weight = i_NpcWeight[victim];
	if(weight > 5)
		return;
		
	if(HasSpecificBuff(victim, "Solid Stance"))
		return;

	if(weight < 0)
		weight = 1;
	
	float knockback = SENSAL_KNOCKBACK;
	switch(weight)
	{
		case 0:
		{
			knockback *= 0.75;
		}
		case 2:
		{
			knockback *= 0.65;
		}
		case 3:
		{
			knockback *= 0.55;
		}
		case 4:
		{
			knockback *= 0.35;
		}
		case 5:
		{
			knockback *= 0.25;
		}
	}

	knockback *= 2.0; //here we do math depending on how much extra pushforce they got.
	knockback *= RatioExtra;
	if(b_thisNpcIsABoss[victim])
	{
		knockback *= 0.65; //They take half knockback
	}
	if(LastMann)
		knockback *= 2.0;

	if(knockback < (SENSAL_KNOCKBACK * 2.0 * 0.25))
	{
		knockback = (SENSAL_KNOCKBACK * 2.0 * 0.25);
	}
	
	if(dostun)
		FreezeNpcInTime(victim, knockback * SENSAL_STUN_RATIO);
		
	Custom_Knockback(attacker, victim, knockback, true, true, true);
}