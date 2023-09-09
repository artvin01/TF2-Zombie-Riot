#pragma semicolon 1
#pragma newdecls required

static bool CitizenHasDied;

bool CitizenRunner_WasKilled()
{
	return CitizenHasDied;
}

methodmap CitizenRunner < CClotBody
{
	public CitizenRunner(int client, float vecPos[3], float vecAng[3], const char[] data)
	{
		if(data[0])
			CitizenHasDied = false;
		
		char buffer[PLATFORM_MAX_PATH];

		int seed = GetURandomInt();
		Citizen_GenerateModel(seed, view_as<bool>(seed % 2), Cit_Unarmed, buffer, sizeof(buffer));
		CitizenRunner npc = view_as<CitizenRunner>(CClotBody(vecPos, vecAng, buffer, "1.15", "500", true, false,_,_,_,_,_,true));
		
		i_NpcInternalId[npc.index] = CITIZEN_RUNNER;
		i_NpcWeight[npc.index] = 1;
		npc.SetActivity("ACT_RUN_PROTECTED");
		
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_SEABORN;

		npc.m_bDissapearOnDeath = true;

		SDKHook(npc.index, SDKHook_Think, CitizenRunner_ClotThink);
		
		npc.m_flSpeed = 241.5;
		npc.m_flGetClosestTargetTime = 0.0;

		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
		SetVariantColor(view_as<int>({255, 200, 0, 200}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");

		return npc;
	}
}

public void CitizenRunner_ClotThink(int iNPC)
{
	CitizenRunner npc = view_as<CitizenRunner>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(!npc.Anger)
	{
		Change_Npc_Collision(npc.index, 3); //they go through enemy npcs
		npc.Anger = true;
	}
	
	if(Waves_InSetup())
	{
		npc.m_bNoKillFeed = true;
		SDKHooks_TakeDamage(npc.index, 0, 0, 999999999.0, DMG_GENERIC);
		return;
	}

	if(npc.m_iTarget && !IsValidAlly(npc.index, npc.m_iTarget))
		npc.m_iTarget = 0;
	
	if(!npc.m_iTarget || npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestAllyPlayer(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}
	
	if(npc.m_iTarget > 0)
	{
		float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);
		float distance = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);

		if(distance < 10000.0)
		{
			npc.StopPathing();

			npc.SetActivity("ACT_COVER_LOW");
		}
		else
		{
			NPC_SetGoalEntity(npc.index, npc.m_iTarget);
			npc.StartPathing();

			npc.SetActivity("ACT_RUN_PROTECTED");
		}
	}
	else
	{
		npc.StopPathing();

		npc.SetActivity("ACT_COVER_LOW");
	}
}

void CitizenRunner_NPCDeath(int entit)
{
	CitizenRunner npc = view_as<CitizenRunner>(entit);
	SDKUnhook(npc.index, SDKHook_Think, CitizenRunner_ClotThink);
	
	if(!Waves_InSetup())
	{
		CitizenHasDied = true;

		float pos[3], angles[3];
		GetEntPropVector(npc.index, Prop_Data, "m_angRotation", angles);
		GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", pos);

		SeaFounder_SpawnNethersea(pos);

		static const int RandomInfection[] = { SEAPREDATOR_ALT, SEAPREDATOR_ALT, SEAFOUNDER_ALT, SEASPEWER_ALT, SEASWARMCALLER_ALT };

		int entity = Npc_Create(RandomInfection[GetURandomInt() % sizeof(RandomInfection)], -1, pos, angles, false);
		if(entity > MaxClients)
		{
			Zombies_Currently_Still_Ongoing++;
			
			int health = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth") * 30;
			SetEntProp(entity, Prop_Data, "m_iHealth", health);
			SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
			
			fl_Extra_MeleeArmor[entity] = fl_Extra_MeleeArmor[npc.index];
			fl_Extra_RangedArmor[entity] = fl_Extra_RangedArmor[npc.index];
			fl_Extra_Speed[entity] = fl_Extra_Speed[npc.index] * 1.25;
			fl_Extra_Damage[entity] = fl_Extra_Damage[npc.index] * 2.0;
			b_thisNpcIsABoss[entity] = true;

			FreezeNpcInTime(entity, 1.5);
		}
/*
		int entity_death = CreateEntityByName("prop_dynamic_override");
		if(IsValidEntity(entity_death))
		{
			TeleportEntity(entity_death, pos, angles, NULL_VECTOR);
			
			char model[PLATFORM_MAX_PATH];
			GetEntPropString(npc.index, Prop_Data, "m_ModelName", model, sizeof(model));
			DispatchKeyValue(entity_death, "model", model);
			
			DispatchSpawn(entity_death);
			
			SetEntPropFloat(entity_death, Prop_Send, "m_flModelScale", 1.15); 
			SetEntityCollisionGroup(entity_death, 2);
			SetVariantString("hunter_cit_tackle_di");
			AcceptEntityInput(entity_death, "SetAnimation");
			
			SetVariantString("OnAnimationDone !self:Kill::0:1,0,1");
			AcceptEntityInput(entity_death, "AddOutput");
		}
*/
	}
}
/*
public void CitizenRunner_PostDeath(const char[] output, int caller, int activator, float delay)
{
	RemoveEntity(caller);
}
*/