#pragma semicolon 1
#pragma newdecls required

static const char g_IdleSound[] = "ambient/energy/electric_loop.wav";
static float LastKnownPos[3];

void Wisp_Setup()
{
	PrecacheSound(g_IdleSound);
	PrecacheModel("models/zombie_riot/btd/bloons_hitbox.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "?????????????");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_stalker_wisp");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Wisp(vecPos, vecAng, team);
}

methodmap Wisp < StalkerShared
{
	public void StartIdleSound()
	{
		EmitSoundToAll(g_IdleSound, this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL);
	}
	public void StopIdleSound()
	{
		StopSound(this.index, SNDCHAN_AUTO, g_IdleSound);
	}
	
	public Wisp(float vecPos[3], float vecAng[3], int ally)
	{
		Wisp npc = view_as<Wisp>(CClotBody(vecPos, vecAng, "models/zombie_riot/btd/bloons_hitbox.mdl", "1.0", "35000", ally, .IgnoreBuildings = true));
		
		i_NpcWeight[npc.index] = 0;
		KillFeed_SetKillIcon(npc.index, "purgatory");
		
		npc.m_iBleedType = 0;
		npc.m_iStepNoiseType = 0;
		npc.m_bDissapearOnDeath = true;

		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCOnTakeDamage[npc.index] = ClotTakeDamage;
		func_NPCThink[npc.index] = ClotThink;

		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		Is_a_Medic[npc.index] = true;
		npc.m_bStaticNPC = true;
		AddNpcToAliveList(npc.index, 1);
		
		npc.m_flSpeed = 200.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		npc.Anger = true;
		npc.m_iChaseAnger = 1000;
		b_NpcIsInvulnerable[npc.index] = true; //Special huds for invul targets
		b_NoHealthbar[npc.index] = true; //Block outlines
		f_TextEntityDelay[npc.index] = FAR_FUTURE; //Block invuln shield model

		int entity = CreateEntityByName("light_dynamic");
		if(entity != -1)
		{
			vecPos[2] += 40.0;
			TeleportEntity(entity, vecPos, vecAng, NULL_VECTOR);
			
			DispatchKeyValue(entity, "brightness", "9");
			DispatchKeyValue(entity, "spotlight_radius", "128");
			DispatchKeyValue(entity, "distance", "128");
			DispatchKeyValue(entity, "_light", "255 128 0 1000");
			//DispatchKeyValue(entity, "_cone", "-1");
			DispatchSpawn(entity);
			ActivateEntity(entity);
			SetVariantString("!activator");
			AcceptEntityInput(entity, "SetParent", npc.index);
			//AcceptEntityInput(entity, "LightOn");
			b_EntityCantBeColoured[entity] = true;
		}
		
		npc.m_iWearable1 = entity;

		SetEntPropString(npc.index, Prop_Data, "m_iName", "resource");

		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 255, 255, 255, 0);

		npc.StartIdleSound();

		return npc;
	}
}

static void ClotThink(int iNPC)
{
	Wisp npc = view_as<Wisp>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;
	
	bool forceLeave = (Waves_InSetup() || RaidbossIgnoreBuildingsLogic(1));
	if(Construction_Mode())
		forceLeave = (!Construction_Started() || !Construction_InSetup());

	if(!npc.Anger)
	{
		if(!forceLeave)
		{
			npc.m_iChaseAnger += 1 + (GetURandomInt() % 3);
			if(npc.m_iChaseAnger > 2000)	// 2000: 200 sec average respawn
			{
				npc.Anger = true;

				int a = 1;
				float pos[3], ang[3];
				if(Spawns_GetNextPos(pos, ang, _, _, a))
				{
					TeleportEntity(npc.index, pos, ang);
				}

				if(IsValidEntity(npc.m_iWearable1))
				{
					SetVariantString("255 128 0 1000");
					AcceptEntityInput(npc.m_iWearable1, "Color");
					AcceptEntityInput(npc.m_iWearable1, "LightOn");
				}
				
				npc.StartIdleSound();
			}
		}

		return;
	}

	if(npc.m_iChaseAnger > 0)
	{
		npc.m_iChaseAnger -= 4;
	}
	else
	{
		npc.m_iChaseAnger--;
	}

	int target = npc.m_iTarget;
	if(i_Target[npc.index] != -1 && !IsValidEnemy(npc.index, target))
	{
		i_Target[npc.index] = -1;
		target = -1;
	}
	
	if(i_Target[npc.index] == -1 && !forceLeave && npc.m_flGetClosestTargetTime < gameTime)
	{
		target = GetClosestTarget(npc.index, true, 450.0, .CanSee = true, .fldistancelimitAllyNPC = 450.0, .UseVectorDistance = true);
		npc.m_iTarget = target;
		npc.m_flGetClosestTargetTime = gameTime + 2.0;
	}

	int spawn = i_TargetAlly[npc.index];
	if((!IsValidEntity(spawn)/* || GetEntProp(spawn, Prop_Data, "m_bDisabled")*/) && (forceLeave || npc.m_iChaseAnger < 1))
	{
		spawn = -1;
		float TargetLocation[3];
		float TargetDistance;
		float vecPos[3]; WorldSpaceCenter(npc.index, vecPos );
		for(int entitycount; entitycount<i_MaxcountSpawners; entitycount++) //Faster check for spawners
		{
			int entity = i_ObjectsSpawners[entitycount];
			if(IsValidEntity(entity) && entity != 0)
			{
				if(/*!GetEntProp(entity, Prop_Data, "m_bDisabled") && */GetTeam(entity) != 2)
				{
					GetEntPropVector( entity, Prop_Data, "m_vecAbsOrigin", TargetLocation ); 
					float distance = GetVectorDistance( vecPos, TargetLocation, true); 
					if (TargetDistance) 
					{
						if( distance < TargetDistance ) 
						{
							spawn = entity; 
							TargetDistance = distance;		  
						}
					} 
					else 
					{
						spawn = entity; 
						TargetDistance = distance;
					}
				}
			}
		}
		
		i_TargetAlly[npc.index] = spawn;
	}

	if(npc.m_flAttackHappens)
	{
		npc.StopPathing();

		if(npc.m_flAttackHappens < gameTime)
			npc.m_flAttackHappens = 0.0;
	}
	else if(!forceLeave && npc.CanSeeEnemy())
	{
		WorldSpaceCenter(target, LastKnownPos);
		float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
		float distance = GetVectorDistance(LastKnownPos, vecMe, true);
		
		if(distance < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; PredictSubjectPosition(npc, target,_,_, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(target);
		}

		npc.StartPathing();

		if(distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED)
		{
			if(target <= MaxClients)
			{
				LastKnownPos[2] += 50.0;
				TeleportEntity(target, LastKnownPos);

				SDKHooks_TakeDamage(target, npc.index, npc.index, 0.1);

				MakePlayerGiveResponseVoice(target, 2); //dead!
				i_CurrentEquippedPerk[target] = 0;
				Grigori_Blessing[target] = 0;

				SetEntityHealth(target, 50);
				dieingstate[target] = 250;
				
				Vehicle_Exit(target);
				SDKHooks_UpdateMarkForDeath(target, true);
				ApplyLastmanOrDyingOverlay(target);
				SetEntityCollisionGroup(target, 1);

				CClotBody player = view_as<CClotBody>(target);
				player.m_bThisEntityIgnored = true;
				SetEntityMoveType(target, MOVETYPE_NONE);

				int entity = TF2_CreateGlow(target);
				i_DyingParticleIndication[target][0] = EntIndexToEntRef(entity);
				SetVariantColor(view_as<int>({255, 0, 0, 255}));
				AcceptEntityInput(entity, "SetGlowColor");

				CreateTimer(0.1, Timer_DieingNoHelp, target, TIMER_REPEAT);
				
				int i;
				while(TF2U_GetWearable(target, entity, i))
				{
					if(entity == EntRefToEntIndex(Armor_Wearable[target]) || i_WeaponVMTExtraSetting[entity] != -1)
						continue;

					SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
					SetEntityRenderColor(entity, 255, 255, 255, 125);
				}

				SetEntityRenderMode(target, RENDER_TRANSCOLOR);
				SetEntityRenderColor(target, 255, 255, 255, 125);

				npc.m_flAttackHappens = gameTime + 6.0;
				npc.m_flGetClosestTargetTime = npc.m_flAttackHappens;
			}
			else
			{
				SDKHooks_TakeDamage(target, npc.index, npc.index, 500000.0, DMG_TRUEDAMAGE);
				
				npc.m_flAttackHappens = gameTime + 2.0;
				npc.m_flGetClosestTargetTime = npc.m_flAttackHappens;
			}
		}
	}
	else if(forceLeave || npc.m_iChaseAnger < 1)
	{
		if(spawn != -1)
		{
			float vecTarget[3]; GetEntPropVector(spawn, Prop_Data, "m_vecAbsOrigin", vecTarget); 
			float vecMe[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", vecMe); 

			float zpos = vecTarget[2];
			
			vecTarget[2] = vecMe[2];
			float distance = GetVectorDistance(vecTarget, vecMe, true);
			vecTarget[2] = zpos;

			if(distance > 5000.0)
			{
				npc.SetGoalVector(vecTarget);
				npc.StartPathing();
				return;
			}
		}

		npc.Anger = false;
		npc.StopPathing();

		if(IsValidEntity(npc.m_iWearable1))
		{
			SetVariantString("0 0 0 0");
			AcceptEntityInput(npc.m_iWearable1, "Color");
			AcceptEntityInput(npc.m_iWearable1, "LightOff");
		}
		
		npc.StopIdleSound();
	}
	else
	{
		float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
		float distance = GetVectorDistance(LastKnownPos, vecMe, true);

		if(distance < 5000.0 || !(GetURandomInt() % 199))
			npc.PickRandomPos(LastKnownPos);

		npc.StartPathing();
		npc.SetGoalVector(LastKnownPos);
	}
}

public Action Timer_DieingNoHelp(Handle timer, int client)
{
	if(IsClientInGame(client) && IsPlayerAlive(client) && dieingstate[client] > 0)
	{
		SetEntityHealth(client, GetClientHealth(client) - 1);
		SDKHooks_TakeDamage(client, client, client, 1.0, DMG_BLAST);
		return Plugin_Continue;
	}

	int particle = EntRefToEntIndex(i_DyingParticleIndication[client][0]);
	if(IsValidEntity(particle))
	{
		RemoveEntity(particle);
	}

	particle = EntRefToEntIndex(i_DyingParticleIndication[client][1]);
	if(IsValidEntity(particle))
	{
		RemoveEntity(particle);
	}

	particle = EntRefToEntIndex(i_DyingParticleIndication[client][2]);
	if(IsValidEntity(particle))
	{
		RemoveEntity(particle);
	}

	dieingstate[client] = 0;
	SDKHooks_UpdateMarkForDeath(client, true);
	CClotBody npc = view_as<CClotBody>(client);
	npc.m_bThisEntityIgnored = false;
	return Plugin_Stop;
}

static Action ClotTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker > 0)
	{
	}

	return Plugin_Changed;
}

static void ClotDeath(int entity)
{
	Wisp npc = view_as<Wisp>(entity);

	npc.StopIdleSound();
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}