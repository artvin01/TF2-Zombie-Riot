#pragma semicolon 1
#pragma newdecls required

void RefragmentedBase_Init(int entity)
{
	CClotBody npc = view_as<CClotBody>(entity);
	npc.m_flMeleeArmor = 0.10;
	npc.m_flRangedArmor = 0.10;
	
	RefragmentedBase_SetEffect(npc.index, false);
	
	//MUST be set to render_glow, otherwise aforementioned unusual effect will overlap with the npc's transparent-ness and it'll look shit
	SetEntityRenderMode(npc.index, RENDER_GLOW);
	SetEntityRenderColor(npc.index, 0, 0, 125, 200);
}

void RefragmentedBase_OnMapStart()
{
	PrecacheParticleSystem("utaunt_demigodery_teamcolor_red");
	PrecacheParticleSystem("utaunt_signalinterference_parent");
}


void RefragmentedBase_OnThink(int entity, float damagePerTick)
{
	// We'll borrow the headcrab zombie methodmap just for the sake of naming something, it'll still work the same for other refragmented NPCs
	// (as long as they don't use m_bFUCKYOU from CClotBody)
	RefragmentedHeadcrabZombie npc = view_as<RefragmentedHeadcrabZombie>(entity);
	
	int closest = npc.m_iTarget;

	//Shitty poopy code but it works, if you're close enough and if you're not a building, the npc will take true damage-damage
	bool enemyIsClose = false;
	float vecTarget2[3]; WorldSpaceCenter(closest, vecTarget2);
	float VecSelfNpc2[3]; WorldSpaceCenter(npc.index, VecSelfNpc2);
	float distance = GetVectorDistance(vecTarget2, VecSelfNpc2, true);
	float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
	if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 0.25) && !i_IsABuilding[closest])
	{
		enemyIsClose = true;
		
		SDKHooks_TakeDamage(npc.index, closest, closest, damagePerTick, DMG_TRUEDAMAGE, -1, _, vecMe);
		//Explode_Logic_Custom(10.0, npc.index, npc.index, -1, vecMe, 15.0, _, _, false, 1, false);
	}
	
	if (enemyIsClose && !npc.m_bEnemyIsClose)
	{
		// An enemy just got close to us
		npc.m_bEnemyIsClose = true;
		RefragmentedBase_SetEffect(npc.index, true);
	}
	else if (!enemyIsClose && npc.m_bEnemyIsClose)
	{
		// An enemy just stopped being close to us
		npc.m_bEnemyIsClose = false;
		RefragmentedBase_SetEffect(npc.index, false);
	}
}

void RefragmentedBase_SetEffect(int entity, bool hurt)
{
	char model[PLATFORM_MAX_PATH];
	int modelIndex = GetEntProp(entity, Prop_Send, "m_nModelIndex");
	ModelIndexToString(modelIndex, model, PLATFORM_MAX_PATH);
	
	if (model[0] == '\0')
	{
		// Not valid somehow?
		return;
	}
	
	// IMPORTANT! We will always use m_iWearable9 for the particle effects, make sure your refragmented NPC doesn't use it
	CClotBody npc = view_as<CClotBody>(entity);
	
	if (!IsValidEntity(npc.m_iWearable9))
	{
		npc.m_iWearable9 = TF2_CreateGlow_White(model, entity, 1.15);
		
		SetEntProp(npc.m_iWearable9, Prop_Send, "m_bGlowEnabled", false);
		SetEntityRenderMode(npc.m_iWearable9, RENDER_ENVIRONMENTAL);
		
		// These should always transmit! Particles will be messed up if they don't
		SetEdictFlags(npc.m_iWearable9, GetEdictFlags(npc.m_iWearable9) | FL_EDICT_ALWAYS);
	
	}
	else
	{
		SetVariantString("ParticleEffectStop");
		AcceptEntityInput(npc.m_iWearable9, "DispatchEffect");
	}
	
	TE_SetupParticleEffect(hurt ? "utaunt_demigodery_teamcolor_red" : "utaunt_signalinterference_parent", PATTACH_ABSORIGIN_FOLLOW, npc.m_iWearable9);
	TE_WriteNum("m_bControlPoint1", npc.m_iWearable9);	
	TE_SendToAll();
}

void RefragmentedBase_OnDeath(int entity)
{
	CClotBody npc = view_as<CClotBody>(entity);
	
	if (IsValidEntity(npc.m_iWearable9))
		RemoveEntity(npc.m_iWearable9);
}