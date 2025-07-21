#pragma semicolon 1
#pragma newdecls required

static int LaserSprite;

void CombineTurtle_MapStart()
{
	LaserSprite = PrecacheModel("materials/sprites/laserbeam.vmt");
	PrecacheModel("models/turtle_attack/hatturtle.mdl");
	PrecacheModel("models/weapons/w_models/w_grenade_grenadelauncher.mdl");
	PrecacheSound("weapons/capper_shoot.wav");
}

methodmap CombineTurtle < CClotBody
{
	public void PlayAttack()
	{
		EmitSoundToAll("weapons/capper_shoot.wav", this.index, _, BOSS_ZOMBIE_SOUNDLEVEL);
	}
	public CombineTurtle(float vecPos[3], float vecAng[3], int ally)
	{
		CombineTurtle npc = view_as<CombineTurtle>(CClotBody(vecPos, vecAng, "models/turtle_attack/hatturtle.mdl", "1.0", "1000", ally, false));
		
		i_NpcInternalId[npc.index] = COMBINE_TURTLE;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		KillFeed_SetKillIcon(npc.index, "the_capper");

		npc.SetActivity("idle", true);
		SetEntProp(npc.index, Prop_Data, "m_bSequenceLoops", true);
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		npc.m_bDissapearOnDeath = true;
		npc.m_bAllowBackWalking = true;

		// Grenade spin
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;

		// Laser attack
		npc.m_flNextRangedAttack = 0.0;
		
		SDKHook(npc.index, SDKHook_Think, CombineTurtle_ClotThink);

		npc.m_iWearable1 = npc.EquipItem("", "models/buildables/gibs/sentry2_gib2.mdl");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_fEffects", 0);

		// Offset refernce: SZF Turtle Attack
		// Turtle: 13840 -13072 -10413
		// Gun: 13840 -13078 -10427
		// Angle: 90
		TeleportEntity(npc.m_iWearable1, {0.0, -5.0, -14.0}, {-12.9525, 210.867, -7.63075}, NULL_VECTOR);

		return npc;
	}
}

public void CombineTurtle_ClotThink(int iNPC)
{
	CombineTurtle npc = view_as<CombineTurtle>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;

	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	Npc_Base_Thinking(npc.index, 400.0, "walk", "idle", 80.0, gameTime, true, true);

	float vecMe[3]; vecMe = WorldSpaceCenterOld(npc.index);

	if(npc.m_flAttackHappens)
	{
		float angles[3];

		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;

			GetEntPropVector(npc.index, Prop_Data, "m_angRotation", angles);
			angles[0] = 0.0;
			angles[2] = 0.0;
			TeleportEntity(npc.index, _, angles);

			float vecDirShooting[3];
			vecDirShooting[0] = vecMe[0] + angles[0] * 175.0;
			vecDirShooting[1] = vecMe[1] + angles[1] * 175.0;
			vecDirShooting[2] = vecMe[2] + angles[2] * 175.0;

			npc.FireGrenade(vecDirShooting, 175.0, 200.0, "models/weapons/w_models/w_grenade_grenadelauncher.mdl");
		}
		else
		{
			angles[0] = GetURandomFloat() * 360.0;
			angles[1] = GetURandomFloat() * 360.0;
			angles[2] = GetURandomFloat() * 360.0;
			
			if(FloatFraction(gameTime) < 0.12)
			{
				float vecDirShooting[3];
				vecDirShooting[0] = vecMe[0] + angles[0] * 175.0;
				vecDirShooting[1] = vecMe[1] + angles[1] * 175.0;
				vecDirShooting[2] = vecMe[2] + angles[2] * 175.0;

				npc.FireGrenade(vecDirShooting, 175.0, 200.0, "models/weapons/w_models/w_grenade_grenadelauncher.mdl");
			}
		}

		TeleportEntity(npc.index, _, angles);
	}

	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; vecTarget = WorldSpaceCenterOld(npc.m_iTarget);
		float flDistanceToTarget = GetVectorDistance(vecTarget, vecMe, true);
			
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3]; vPredictedPos = PredictSubjectPositionOld(npc, npc.m_iTarget);
			npc.SetGoalVector(vPredictedPos);
		}
		else
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}
		//Get position for just travel here.

		if(npc.m_flNextMeleeAttack < gameTime)
		{
			npc.m_flNextMeleeAttack = gameTime + 14.95;
			npc.m_flAttackHappens = gameTime + 2.95;

			npc.FireGrenade(vecTarget, 175.0, 200.0, "models/weapons/w_models/w_grenade_grenadelauncher.mdl");
		}

		if(npc.m_flNextRangedAttack < gameTime)
		{
			vecMe[2] -= 16.0;

			float eyePitch[3], vecDirShooting[3];
			GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
			
			MakeVectorFromPoints(vecMe, vecTarget, vecDirShooting);
			GetVectorAngles(vecDirShooting, vecDirShooting);

			vecDirShooting[1] = eyePitch[1] - 180.0;

			float x = GetRandomFloat( -0.03, 0.03 );
			float y = GetRandomFloat( -0.03, 0.03 );
			
			float vecRight[3], vecUp[3];
			GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
			
			float vecDir[3];
			for(int i; i < 3; i++)
			{
				vecDir[i] = vecDirShooting[i] + x * vecRight[i] + y * vecUp[i]; 
			}

			NormalizeVector(vecDir, vecDir);

			FireBullet(npc.index, npc.m_iWearable1, vecMe, vecDir, 40.0, 1000.0, DMG_BULLET, "");
			npc.PlayAttack();

			npc.m_flNextRangedAttack = gameTime + 0.55;

			// Artvin will kill me when he finds me using TE

			vecDir[0] = vecMe[0] + vecDir[0] * 1000.0;
			vecDir[1] = vecMe[1] + vecDir[1] * 1000.0;
			vecDir[2] = vecMe[2] + vecDir[2] * 1000.0;

			Handle trace = TR_TraceRayFilterEx(vecMe, vecDir, (MASK_SOLID | CONTENTS_SOLID), RayType_EndPoint, BulletAndMeleeTrace, npc.index);
			TR_GetEndPosition(vecDir, trace);
			delete trace;

			TE_SetupBeamPoints(vecMe, vecDir, LaserSprite, 0, 0, 0, 0.2, 2.0, 2.2, 1, 0.0, {255, 255, 255, 255}, 0);
			TE_SendToAll();
		}
		
		vecTarget[0] += (vecMe[0] - vecTarget[0]) * 2.0;
		vecTarget[1] += (vecMe[1] - vecTarget[1]) * 2.0;
		vecTarget[2] += (vecMe[2] - vecTarget[2]) * 2.0;
		npc.FaceTowards(vecTarget, 600.0);
	}
	else
	{
		npc.m_flNextMeleeAttack = gameTime + 8.0;
	}
	
	npc.SetActivity(npc.m_bPathing ? "walk" : "idle", true);
	SetEntProp(npc.index, Prop_Data, "m_bSequenceLoops", true);
}

void CombineTurtle_NPCDeath(int entity)
{
	CombineTurtle npc = view_as<CombineTurtle>(entity);
	
	SDKUnhook(npc.index, SDKHook_Think, CombineTurtle_ClotThink);

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	float pos[3]; pos = WorldSpaceCenterOld(npc.index);
	pos[2] -= 10.0;

	TE_Particle("teleported_blue", pos, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
	TE_Particle("player_sparkles_blue", pos, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
}