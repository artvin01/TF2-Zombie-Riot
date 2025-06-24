#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"cof/stranger/stranger_death.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"cof/stranger/stranger_voiceloop.mp3",
};

static float fl_DefaultSpeed_Stranger = 50.0;
static float fl_DefaultSpeed_Stranger_Nightmare = 75.0;
static bool b_IsNightmare[MAXENTITIES];

void Stranger_OnMapStart_NPC()
{
	PrecacheModel("models/zombie_riot/cof/stranger/stranger.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Stranger");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_stranger");
	strcopy(data.Icon, sizeof(data.Icon), "stranger");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_COF;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSoundCustom(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSoundCustom(g_IdleAlertedSounds[i]); }
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Stranger(vecPos, vecAng, team, data);
}
methodmap Stranger < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitCustomToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
    
	}
	
	public void PlayDeathSound() 
	{
		EmitCustomToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);

	}

	property bool b_Nightmare
	{
		public get()		{ return b_IsNightmare[this.index]; }
		public set(bool value) 	{ b_IsNightmare[this.index] = value; }
	}
	
	
	public Stranger(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Stranger npc = view_as<Stranger>(CClotBody(vecPos, vecAng, "models/zombie_riot/cof/stranger/stranger.mdl", "1.10", "300", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_WALK");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(Stranger_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Stranger_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Stranger_ClotThink);
		npc.b_Nightmare = false;

		bool nightmare = StrContains(data, "nightmare") != -1;
		if(nightmare)
		{
			npc.b_Nightmare = true;
			npc.m_flSpeed = fl_DefaultSpeed_Stranger_Nightmare;
		}
		else
		{
			npc.m_flSpeed = fl_DefaultSpeed_Stranger;
		}
		
		
		
		npc.StartPathing();
		npc.m_flSpeed = 50.0;

		npc.m_bDissapearOnDeath = true;
		
		return npc;
	}
}

public void Stranger_ClotThink(int iNPC)
{
	Stranger npc = view_as<Stranger>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		//npc.AddGesture("ACT_BIG_FLINCH", false);
		npc.m_blPlayHurtAnimation = false;
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
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
	
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
		StrangerSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
	
}

public Action Stranger_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Stranger npc = view_as<Stranger>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void Stranger_NPCDeath(int entity)
{
	Stranger npc = view_as<Stranger>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
	
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

	int entity_death = CreateEntityByName("prop_dynamic_override");
	if(IsValidEntity(entity_death))
	{
		float pos[3];
		float Angles[3];
		GetEntPropVector(entity, Prop_Data, "m_angRotation", Angles);

		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
		TeleportEntity(entity_death, pos, Angles, NULL_VECTOR);
		
//		GetEntPropString(client, Prop_Data, "m_ModelName", model, sizeof(model));
		DispatchKeyValue(entity_death, "model", "models/zombie_riot/cof/stranger/stranger.mdl");

		DispatchSpawn(entity_death);
		
		SetEntPropFloat(entity_death, Prop_Send, "m_flModelScale", 1.10); 
		SetEntityCollisionGroup(entity_death, 2);
		SetVariantString("diesimple");
		AcceptEntityInput(entity_death, "SetAnimation");
		
		pos[2] += 20.0;
		
		CreateTimer(1.0, Timer_RemoveEntityStranger, EntIndexToEntRef(entity_death), TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action Timer_RemoveEntityStranger(Handle timer, any entid)
{
	int entity = EntRefToEntIndex(entid);
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		float pos[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
//		TeleportEntity(entity, OFF_THE_MAP, NULL_VECTOR, NULL_VECTOR); // send it away first in case it feels like dying dramatically
		RemoveEntity(entity);
	}
	return Plugin_Handled;
}

void StrangerSelfDefense(Stranger npc, float gameTime, int target, float distance)
{
	int PrimaryThreatIndex = npc.m_iTarget;
	float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
	if(npc.m_flNextRangedAttack < GetGameTime(npc.index) && flDistanceToTarget > 1)
	{
		int Enemy_I_See;
	
		Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
		
		if(!IsValidEnemy(npc.index, Enemy_I_See))
		{

		}
		else
		{
			npc.m_fbGunout = true;
			
			npc.m_bmovedelay = false;
			
			npc.FaceTowards(vecTarget, 25000.0);
			npc.m_flNextRangedAttack = GetGameTime(npc.index) + 0.01;
			npc.m_iAttacksTillReload -= 1;
			
			float vecSpread = 0.1;
		
			float eyePitch[3];
			GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
			
			
			float x, y;
			x = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
			y = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
			
			float vecDirShooting[3], vecRight[3], vecUp[3];
			
			vecTarget[2] += 15.0;
			float SelfVecPos[3]; WorldSpaceCenter(npc.index, SelfVecPos);
			MakeVectorFromPoints(SelfVecPos, vecTarget, vecDirShooting);
			GetVectorAngles(vecDirShooting, vecDirShooting);
			vecDirShooting[1] = eyePitch[1];
			GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
			
			float vecDir[3];
			vecDir[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
			vecDir[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
			vecDir[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
			NormalizeVector(vecDir, vecDir);
			float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
			
			FireBullet(npc.index, npc.m_iWearable1, WorldSpaceVec, vecDir, 1.0, 9000.0, DMG_BULLET, "bullet_tracer01_red");
		}
	}
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			static float MaxVec[3] = {5000.0, 5000.0, 5000.0};
			static float MinVec[3] = {-5000.0, -5000.0, -5000.0};

			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, MaxVec, MinVec)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
			{
				target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 2.0;
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 25.0;

					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);

					// Hit sound
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
						
				npc.m_flAttackHappens = gameTime + 0.05;
				npc.m_flDoingAnimation = gameTime + 0.25;
				npc.m_flNextMeleeAttack = gameTime + 0.01;
			}
		}
	}
}