#pragma semicolon 1
#pragma newdecls required

static bool CitizenHasDied;
static int NPCId;

bool CitizenRunner_WasKilled()
{
	return CitizenHasDied;
}

void CitizenRunner_Precache()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Citizen");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_citizen_runner");
	strcopy(data.Icon, sizeof(data.Icon), "sea_citizen");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_SUPPORT;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
}

int CitizenRunner_Id()
{
	return NPCId;
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return CitizenRunner(vecPos, vecAng, data);
}

methodmap CitizenRunner < CClotBody
{
	public CitizenRunner(float vecPos[3], float vecAng[3], const char[] data)
	{
		if(data[0])
			CitizenHasDied = false;
		
		char buffer[PLATFORM_MAX_PATH];

		int seed = GetURandomInt();
		Citizen_GenerateModel(seed, view_as<bool>(seed % 2), Cit_Unarmed, buffer, sizeof(buffer));
		CitizenRunner npc = view_as<CitizenRunner>(CClotBody(vecPos, vecAng, buffer, "1.15", "500", TFTeam_Red, false));
		
		i_NpcWeight[npc.index] = 1;
		npc.SetActivity("ACT_RUN_PROTECTED");
		
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_SEABORN;

		npc.m_bDissapearOnDeath = true;

		func_NPCDeath[npc.index] = CitizenRunner_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = CitizenRunner_OnTakeDamage;
		func_NPCThink[npc.index] = CitizenRunner_ClotThink;
		
		npc.m_flSpeed = 241.5;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flFlamerActive = GetGameTime() + 3.0;

		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
		npc.m_bTeamGlowDefault = false;
		SetVariantColor(view_as<int>({255, 200, 0, 200}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");

		return npc;
	}
}

public void CitizenRunner_ClotThink(int iNPC)
{
	CitizenRunner npc = view_as<CitizenRunner>(iNPC);

	float gameTime = GetGameTime();
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(!npc.Anger)
	{
		b_IgnorePlayerCollisionNPC[npc.index] = true;
		npc.Anger = true;
	}
	
	if(Waves_InSetup() || (GetWaveSetupCooldown() > (gameTime + 20.0)))
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
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float npc_vec[3]; WorldSpaceCenter(npc.index, npc_vec );
		float distance = GetVectorDistance(vecTarget, npc_vec, true);

		if(distance < 10000.0)
		{
			npc.StopPathing();

			npc.SetActivity("ACT_COVER_LOW");
		}
		else
		{
			npc.SetGoalEntity(npc.m_iTarget);
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
	
	if(!Waves_InSetup() && !npc.m_bNoKillFeed)
	{
		CitizenHasDied = true;

		float pos[3], angles[3];
		GetEntPropVector(npc.index, Prop_Data, "m_angRotation", angles);
		GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", pos);

		SeaFounder_SpawnNethersea(pos);

		int entity = NPC_CreateByName("npc_netherseafounder", -1, pos, angles, TFTeam_Blue);
		if(entity > MaxClients)
		{
			Zombies_Currently_Still_Ongoing++;
			
			int health = ReturnEntityMaxHealth(npc.index) * 30;
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


public Action CitizenRunner_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	CitizenRunner npc = view_as<CitizenRunner>(victim);
	
	if(npc.m_flFlamerActive > GetGameTime())
		damage *= 0.25;
	
	return Plugin_Changed;
}