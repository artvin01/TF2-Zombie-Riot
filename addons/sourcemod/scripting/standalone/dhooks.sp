#pragma semicolon 1
#pragma newdecls required

static DynamicHook g_DhookUpdateTransmitState; 

void DHook_Setup()
{
	GameData gamedata = new GameData("zombie_riot");

	g_DhookUpdateTransmitState = DHook_CreateVirtual(gamedata, "CBaseEntity::UpdateTransmitState()");
	g_DHookRocketExplode = DHook_CreateVirtual(gamedata, "CTFBaseRocket::Explode");
	
	delete gamedata;

	gamedata = LoadGameConfigFile("lagcompensation");

	DHook_CreateDetour(gamedata, "CLagCompensationManager::StartLagCompensation", StartLagCompensationPre);
	DHook_CreateDetour(gamedata, "CLagCompensationManager::FinishLagCompensation", FinishLagCompensation, _);
	DHook_CreateDetour(gamedata, "CLagCompensationManager::FrameUpdatePostEntityThink_SIGNATURE", _, LagCompensationThink);
	
	delete gamedata;
}

static DynamicHook DHook_CreateVirtual(GameData gamedata, const char[] name)
{
	DynamicHook hook = DynamicHook.FromConf(gamedata, name);
	if (!hook)
		LogError("Failed to create virtual: %s", name);
	
	return hook;
}

void StartLagCompResetValues()
{
	b_LagCompNPC_No_Layers = false;	
	b_LagCompNPC_ExtendBoundingBox = true;
	b_LagCompNPC_OnlyAllies = false;
}

void Hook_DHook_UpdateTransmitState(int entity)
{
	g_DhookUpdateTransmitState.HookEntity(Hook_Pre, entity, DHook_UpdateTransmitState);
}

public MRESReturn StartLagCompensationPre(Address manager, DHookParam param)
{
	int Compensator = param.Get(1);
	if(IsFakeClient(Compensator))
		return MRES_Ignored;
	
	StartLagCompResetValues();
	StartLagCompensation_Base_Boss(Compensator);
	return MRES_Ignored;
}

public MRESReturn LagCompensationThink(Address manager)
{
	LagCompensationThink_Forward();
	return MRES_Ignored;
}

public MRESReturn FinishLagCompensation(Address manager, DHookParam param) //This code does not need to be touched. mostly.
{
	int Compensator = param.Get(1);
	if(IsFakeClient(Compensator))
		return MRES_Ignored;
	
	FinishLagCompensation_Base_boss();
	StartLagCompResetValues();
	return MRES_Ignored;
}

public MRESReturn DHook_UpdateTransmitState(int entity, DHookReturn returnHook) //BLOCK!!
{
	if(b_IsEntityNeverTranmitted[entity])
	{
		returnHook.Value = SetEntityTransmitState(entity, FL_EDICT_DONTSEND);
	}
	else if(b_IsEntityAlwaysTranmitted[entity] || b_thisNpcIsABoss[entity])
	{
		returnHook.Value = SetEntityTransmitState(entity, FL_EDICT_ALWAYS);
	}
	else
	{
		returnHook.Value = SetEntityTransmitState(entity, FL_EDICT_PVSCHECK);
	}
	return MRES_Supercede;
}

int SetEntityTransmitState(int entity, int newFlags)
{
	if (!IsValidEdict(entity))
	{
		return 0;
	}

	int flags = GetEdictFlags(entity);
	flags &= ~(FL_EDICT_ALWAYS | FL_EDICT_PVSCHECK | FL_EDICT_DONTSEND);
	flags |= newFlags;
//	SetEdictFlags(entity, flags);

	return flags;
}

static float Velocity_Rocket[MAXENTITIES][3];

public void ApplyExplosionDhook_Rocket(int entity)
{
//	SetEntProp(entity, Prop_Send, "m_flDestroyableTime", GetGameTime());
	if(!b_EntityIsArrow[entity] && !b_EntityIsWandProjectile[entity]) //No!
	{
		h_NpcSolidHookType[entity] = g_DHookRocketExplode.HookEntity(Hook_Pre, entity, DHook_RocketExplodePre);
	}
	CreateTimer(1.0, FixVelocityStandStillRocket, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
//Heavily increase thedelay, this rarely ever happens, and if it does, then it should check every 2 seconds at the most!
}

public Action FixVelocityStandStillRocket(Handle Timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if (IsValidEntity(entity))
	{
		float Velocity_Temp[3];
		GetEntPropVector(entity, Prop_Data, "m_vecVelocity", Velocity_Temp); 
		if(Velocity_Temp[0] == 0.0 && Velocity_Temp[1] == 0.0 && Velocity_Temp[2] == 0.0)
		{
			TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, Velocity_Rocket[entity]);
		}
		else
		{
			Velocity_Rocket[entity][0] = Velocity_Temp[0];
			Velocity_Rocket[entity][1] = Velocity_Temp[1];
			Velocity_Rocket[entity][2] = Velocity_Temp[2];
		}
		
		return Plugin_Continue;
	}
	else
	{
		return Plugin_Stop;
	}
}

public MRESReturn DHook_RocketExplodePre(int entity)
{
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if (0 < owner  && owner <= MaxClients)
	{
		float original_damage = GetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4);
		SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 0.0, true);
		int weapon = GetEntPropEnt(entity, Prop_Send, "m_hOriginalLauncher");
		int inflictor = EntRefToEntIndex(h_ArrowInflictorRef[entity]);
		if(!IsValidEntity(inflictor))
		{
			inflictor = 0;
		}
		Explode_Logic_Custom(original_damage, owner, entity, weapon,_,_,_,_,_,_,_,_,_,_,inflictor);
	}
	else if(owner > MaxClients)
	{
		float original_damage = GetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4);
		SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 0.0, true);
	//	int weapon = GetEntPropEnt(entity, Prop_Send, "m_hOriginalLauncher");
	//Important, make them not act as an ai if its on red, or else they are BUSTED AS FUCK.
		int inflictor = EntRefToEntIndex(h_ArrowInflictorRef[entity]);
		if(!IsValidEntity(inflictor))
		{
			inflictor = 0;
		}
		if(GetTeam(entity) != view_as<int>(TFTeam_Red))
		{
			Explode_Logic_Custom(original_damage, owner, entity, -1,_,_,_,_,true,_,_,_,_,_,inflictor);	
		}
		else
		{
			Explode_Logic_Custom(original_damage, owner, entity, -1,_,_,_,_,false,_,_,_,_,_,inflictor);	
		}
	}
	return MRES_Ignored;
}

public Action CH_PassFilter(int ent1, int ent2, bool &result)
{
	if(ent1 >= 0 && ent1 <= MAXENTITIES && ent2 >= 0 && ent2 <= MAXENTITIES)
	{
		result = PassfilterGlobal(ent1, ent2, true);
		if(result)
		{
			return Plugin_Continue;
		}
		else
		{
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

public bool PassfilterGlobal(int ent1, int ent2, bool result)
{
	if(b_IsInUpdateGroundConstraintLogic)
	{
		if(b_ThisEntityIsAProjectileForUpdateContraints[ent1] || (ent1 > 0 && ent1 <= MaxClients) || i_IsABuilding[ent1])
		{
			return false;
		}
		else if(b_ThisEntityIsAProjectileForUpdateContraints[ent2] || (ent2 > 0 && ent2 <= MaxClients) || i_IsABuilding[ent2])
		{
			return false;
		}
		//We do not want this entity to step on anything aside from the actual world or entities that are treated as the world
	}
	if(b_ThisEntityIgnoredEntirelyFromAllCollisions[ent1] || b_ThisEntityIgnoredEntirelyFromAllCollisions[ent2])
	{
		return false;
	}	
	
	for( int ent = 1; ent <= 2; ent++ ) 
	{
		static int entity1;
		static int entity2; 	
		if(ent == 1)
		{
			entity1 = ent1;
			entity2 = ent2;
		}
		else
		{
			entity1 = ent2;
			entity2 = ent1;			
		}

		if(!b_NpcHasDied[entity1])
		{
			if(b_ThisEntityIgnored[entity2] && !DoingLagCompensation) //Only Ignore when not shooting/compensating, which is shooting only.
			{
				return false;
			}
			else if(!b_NpcHasDied[entity2] && GetTeam(entity2) != GetTeam(entity1))
			{
				return false;
			}
			else if (b_DoNotUnStuck[entity2])
			{
				return false;
			}
			else if(entity2 <= MaxClients && entity2 > 0)
			{
				if(GetTeam(entity2) == GetTeam(entity1) || f_AntiStuckPhaseThrough[entity2] > GetGameTime())
				{
					//if a player needs to get unstuck.
					return false;
				}
			}
		}
	}
	return result;	
}
