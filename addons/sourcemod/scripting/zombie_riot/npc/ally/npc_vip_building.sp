#pragma semicolon 1
#pragma newdecls required

static int IsActive;
//static int NPCId;

void VIPBuilding_PluginStart()
{
	CEntityFactory factory = new CEntityFactory("trigger_towerdefense", OnCreate, OnDestroy);
	factory.DeriveFromClass("trigger_multiple");
	factory.BeginDataMapDesc()
	.DefineIntField("m_iPathAlt")
	.DefineIntField("m_iPathNumber")
	.EndDataMapDesc();
	factory.Install();
}
static void OnCreate(int entity)
{
	HookSingleEntityOutput(entity, "OnStartTouch", Touch_TowerDefenseTrigger, false);
}

static void OnDestroy(int entity)
{
	UnhookSingleEntityOutput(entity, "OnStartTouch", Touch_TowerDefenseTrigger);
}

public Action Touch_TowerDefenseTrigger(const char[] output, int entity, int caller, float delay)
{
	if(caller > 0 && caller <= MAXENTITIES)
	{
		if(!b_ThisWasAnNpc[caller])
			return Plugin_Continue;

		if(!IsEntityTowerDefense(caller))
			return Plugin_Continue;

		//already done.
		if(GetEntProp(caller, Prop_Data, "m_iTowerdefense_CheckpointAt") == -1)
			return Plugin_Continue;
		//char name[64];
		//GetEntProp(entity, Prop_Data, "m_iPathAlt"); //blah blah if not on same alth path dont do shit.

		//See if we get a number higher then us.
		if(GetEntProp(entity, Prop_Data, "m_iPathNumber") != GetEntProp(caller, Prop_Data, "m_iTowerdefense_CheckpointAt") + 1)
			return Plugin_Continue;
		//if this isnt their next touch, dont do anything.
		
		CClotBody npc = view_as<CClotBody>(caller);
		npc.StartPathing();

		//set the checkpoint they are are currently at, set the next.

		static char CheckpointGet[32];
		//check for an even higher number once obtained.
		Format(CheckpointGet, sizeof(CheckpointGet), "zr_checkpoint_%i", GetEntProp(entity, Prop_Data, "m_iPathNumber") + 1);
		int EntityCheckpoint = FindInfoTargetInt(CheckpointGet);
		if(!IsValidEntity(EntityCheckpoint))
		{
			SetEntProp(caller, Prop_Data, "m_iTowerdefense_CheckpointAt", -1);
			npc.m_iTarget = VIPBuilding_Get();
			if(IsValidEntity(npc.m_iTarget))
			{
				static float flNextPos[3];
				GetEntPropVector(npc.m_iTarget, Prop_Data, "m_vecAbsOrigin", flNextPos);
				npc.SetGoalTowerDefense(flNextPos);
				npc.m_iCheckpointTarget = npc.m_iTarget;
			}
		}
		else
		{
			SetEntProp(caller, Prop_Data, "m_iTowerdefense_CheckpointAt", GetEntProp(entity, Prop_Data, "m_iPathNumber"));
			static float flNextPos[3];
			GetEntPropVector(EntityCheckpoint, Prop_Data, "m_vecAbsOrigin", flNextPos);
			npc.SetGoalTowerDefense(flNextPos);
			npc.m_iCheckpointTarget = EntityCheckpoint;
			//get next goal.
		}
	}
	return Plugin_Continue;
}
void VIPBuilding_MapStart()
{
	IsActive = 0;
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "VIP Building, The Objective");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_vip_building");
	strcopy(data.Icon, sizeof(data.Icon), "test_filename");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
}
/*
int VIPBuilding_ID()
{
	return NPCId;
}

*/
static any ClotSummon(int client, float vecPos[3], float vecAng[3],int ally,  const char[] data)
{
	return VIPBuilding(client, vecPos, vecAng, data);
}
methodmap VIPBuilding < BarrackBody
{
	public VIPBuilding(int client, float vecPos[3], float vecAng[3], const char[] data)
	{
		if(data[0])
			ExplodeStringFloat(data, " ", vecPos, sizeof(vecPos));
		
		int EndFound = FindInfoTargetInt("zr_checkpoint_final");
		if(IsValidEntity(EndFound))
		{
			GetEntPropVector(EndFound, Prop_Data, "m_vecAbsOrigin", vecPos);
		}
		VIPBuilding npc = view_as<VIPBuilding>(BarrackBody(client, vecPos, vecAng, "10000", TOWER_MODEL, _, TOWER_SIZE_BARRACKS, 80.0, "models/pickups/pickup_powerup_resistance.mdl"));
		
		npc.m_iWearable1 = npc.EquipItemSeperate("models/props_manor/clocktower_01.mdl");
		SetVariantString("0.1");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		i_NpcWeight[npc.index] = 999;
		i_NpcIsABuilding[npc.index] = true;
		b_NoKnockbackFromSources[npc.index] = true;
		npc.m_bDissapearOnDeath = true;
		npc.m_flHeadshotCooldown = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;
		
		SetEntityRenderMode(npc.index, RENDER_NONE);
		SetEntityRenderColor(npc.index, 0, 0, 0, 0);
		SetEntityRenderMode(npc.m_iWearable1, RENDER_NORMAL);
		SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 255);
		func_NPCDeath[npc.index] = VIPBuilding_NPCDeath;
		func_NPCThink[npc.index] = VIPBuilding_ClotThink;
		func_NPCOnTakeDamage[npc.index] = VIPBuilding_ClotTakeDamage;

		npc.m_flSpeed = 0.0;

		IsActive = EntIndexToEntRef(npc.index);
		DoTriggerTouchLogic_Towerdefense();
		return npc;
	}
}

public void VIPBuilding_ClotThink(int iNPC)
{
	VIPBuilding npc = view_as<VIPBuilding>(iNPC);
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + 0.1;
	BarrackBody npc1 = view_as<BarrackBody>(iNPC);
	BarrackBody_HealthHud(npc1 ,0.0);
	
	if(npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		if(GetClosestTarget(npc.index, _, 100.0, true, .UseVectorDistance = true) > 0)
		{
			for (int client = 1; client <= MaxClients; client++)
			{
				f_DelayLookingAtHud[client] = GetGameTime() + 0.5;
			}
			PrintCenterTextAll("VIP BUILDING IS UNDER ATTACK");
			EmitSoundToAll("mvm/mvm_cpoint_klaxon.wav", npc.index, SNDCHAN_STATIC, 120, _, 1.0);
			EmitSoundToAll("mvm/mvm_cpoint_klaxon.wav", npc.index, SNDCHAN_STATIC, 120, _, 1.0);

			npc.m_flHeadshotCooldown = GetGameTime(npc.index) + 0.5;
			npc.PlayHurtSound();

			int health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
			int maxhealth = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");
			health -= maxhealth / 25;

			if(health > 0)
			{
				SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
			}
			else
			{
				SmiteNpcToDeath(npc.index);
			}
		}
		else
		{
			int maxhealth = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");
			float health = float(maxhealth) / 5000.0;

			HealEntityGlobal(npc.index, npc.index, health, _, _, _, _);
		}
	}
}

void VIPBuilding_NPCDeath(int entity)
{
	VIPBuilding npc = view_as<VIPBuilding>(entity);

	IsActive = 0;

	float pos[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	makeexplosion(-1, pos, 0, 0);
	BarrackBody_NPCDeath(npc.index);
	if(Waves_Started())
	{
		ForcePlayerLoss();
	}
}

void VIPBuilding_ClotTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker > 0 && damage < 999999.9)
		damage = 0.0;
}

bool VIPBuilding_Active()
{
	return view_as<bool>(IsActive);
}
int VIPBuilding_Get()
{
	return EntRefToEntIndex(IsActive);
}


void DoTriggerTouchLogic_Towerdefense()
{

	int entity = -1;
	static float Pos[3];
	while((entity=FindEntityByClassname(entity, "info_target")) != -1)
	{
		static char buffer[32];
		GetEntPropString(entity, Prop_Data, "m_iName", buffer, sizeof(buffer));
		if(StrContains(buffer, "zr_checkpoint_") == -1)
			continue;
			
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", Pos);
		int trigger_entity = CreateEntityByName("trigger_towerdefense");
		if(trigger_entity != -1)
		{
			DispatchKeyValueVector(trigger_entity, "origin", Pos);
			DispatchKeyValue(trigger_entity, "spawnflags", "3");
			DispatchKeyValue(trigger_entity, "targetname", buffer);

			DispatchSpawn(trigger_entity);
			ActivateEntity(trigger_entity);    

			SetEntityModel(trigger_entity, "models/error.mdl");
			SetEntProp(trigger_entity, Prop_Send, "m_nSolidType", 2);
			SetEntityFlags(trigger_entity, FL_NPC);
			SetEntityCollisionGroup(trigger_entity, 5);
			int number = StringToInt(buffer[14]);
			SetEntProp(trigger_entity, Prop_Data, "m_iPathNumber", number);
			
			SetEntPropVector(trigger_entity, Prop_Data, "m_vecMinsPreScaled", {0.0,0.0,0.0});
			SetEntPropVector(trigger_entity, Prop_Data, "m_vecMins", {0.0,0.0,0.0});
			
			SetEntPropVector(trigger_entity, Prop_Data, "m_vecMaxsPreScaled", {5.0,5.0,5.0});
			SetEntPropVector(trigger_entity, Prop_Data, "m_vecMaxs", {5.0,5.0,5.0});

			SetEntProp(trigger_entity, Prop_Send, "m_fEffects", GetEntProp(trigger_entity, Prop_Send, "m_fEffects") | EF_NODRAW); 
			TeleportEntity(trigger_entity, Pos, NULL_VECTOR, NULL_VECTOR);
		}
	}
}