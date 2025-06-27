#pragma semicolon 1
#pragma newdecls required

static const char NPCModel[] = "models/workshop/player/items/demo/taunt_drunk_manns_cannon/taunt_drunk_manns_cannon.mdl";

#define TREBUCHET_LIGHTNING_RANGE 100.0

void MedivalTrebuchet_OnMapStart()
{

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Trebuchet");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_medival_trebuchet");
	strcopy(data.Icon, sizeof(data.Icon), "soldier_spammer");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Medieval;
	data.Func = ClotSummon;
	NPC_Add(data);

}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return MedivalTrebuchet(vecPos, vecAng, team);
}
methodmap MedivalTrebuchet < CClotBody
{
	public void PlayMeleeSound()
	{
		EmitSoundToAll("weapons/mortar/mortar_fire1.wav", this.index, _, 130, _, 1.0, 100);
	}
	
	public MedivalTrebuchet(float vecPos[3], float vecAng[3], int ally)
	{
		MedivalTrebuchet npc = view_as<MedivalTrebuchet>(CClotBody(vecPos, vecAng, NPCModel, "1.35", "5000", ally));
		i_NpcWeight[npc.index] = 5;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = 0;
		
		func_NPCDeath[npc.index] = MedivalTrebuchet_NPCDeath;
		func_NPCThink[npc.index] = MedivalTrebuchet_ClotThink;
		
		npc.m_iState = 0;
		npc.m_flSpeed = 150.0;
		npc.m_flReloadDelay = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_fbRangedSpecialOn = false;
		npc.m_bDissapearOnDeath = true;
		b_DoNotChangeTargetTouchNpc[npc.index] = 1;
		
		npc.m_flMeleeArmor = 2.0;
		npc.m_flRangedArmor = 0.01;
		SDKHook(npc.index, SDKHook_Touch, RamTouchDamageTouch);
		
		return npc;
	}
	
	
}


public void MedivalTrebuchet_ClotThink(int iNPC)
{
	ResolvePlayerCollisions_Npc(iNPC, /*damage crush*/ 10.0);
	MedivalTrebuchet npc = view_as<MedivalTrebuchet>(iNPC);
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index,_,_,_,_,_,_,_,999999.9, true);
		b_DoNotChangeTargetTouchNpc[npc.index] = 1;
		if(npc.m_iTarget < 1)
		{
			b_DoNotChangeTargetTouchNpc[npc.index] = 0;
			npc.m_iTarget = GetClosestTarget(npc.index);
		}
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
			float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
			
		
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			
			//Predict their pos.
			if(flDistanceToTarget < npc.GetLeadRadius()) {
				
				float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex,_,_, vPredictedPos);
				
			/*	int color[4];
				color[0] = 255;
				color[1] = 255;
				color[2] = 0;
				color[3] = 255;
			
				int xd = PrecacheModel("materials/sprites/laserbeam.vmt");
			
				TE_SetupBeamPoints(vPredictedPos, vecTarget, xd, xd, 0, 0, 0.25, 0.5, 0.5, 5, 5.0, color, 30);
				TE_SendToAllInRange(vecTarget, RangeType_Visibility);*/
				
				npc.SetGoalVector(vPredictedPos);
			} else {
				npc.SetGoalEntity(PrimaryThreatIndex);
			}
	
			//Target close enough to hit
			if(flDistanceToTarget < (1000*1000) && npc.m_flNextMeleeAttack < GetGameTime(npc.index) || npc.m_flAttackHappenswillhappen)
			{
			//	npc.FaceTowards(vecTarget, 1000.0);
				npc.FaceTowards(vecTarget, 20000.0);
				if(npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) || npc.m_flAttackHappenswillhappen)
				{
					if (!npc.m_flAttackHappenswillhappen)
					{
						//Target close enough to hit
						if(IsValidEnemy(npc.index, Can_I_See_Enemy(npc.index, PrimaryThreatIndex)))
						{
							npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 2.0;
							npc.m_flAttackHappens = GetGameTime(npc.index)+2.4;
							npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+2.54;
							npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 10.0;
							npc.m_flAttackHappenswillhappen = true;
							npc.StopPathing();
							
						}
					}
					float vEnd[3];
					GetAbsOrigin(npc.m_iTarget, vEnd);
					float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
					spawnBeam(0.15, 255, 255, 255, 255, "materials/sprites/laserbeam.vmt", 4.0, 6.2, _, 2.0, vEnd, WorldSpaceVec);	
						
					if (npc.m_flAttackHappens < GetGameTime(npc.index) && npc.m_flAttackHappens_bullshit >= GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
					{
						float pos_obj[3];
						GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", pos_obj);
						pos_obj[2] += 50.0;
						ParticleEffectAt(pos_obj, "skull_island_embers", 2.0);

						//high inaccucary.
						vEnd[0] += GetRandomFloat(-50.0,50.0);
						vEnd[1] += GetRandomFloat(-50.0,50.0);
						vEnd[2] += 5.0;

						Handle pack;
						CreateDataTimer(ACHILLES_CHARGE_SPAN, Smite_Timer_Trebuchet, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
						WritePackCell(pack, EntIndexToEntRef(npc.index));
						WritePackFloat(pack, 0.0);
						WritePackFloat(pack, vEnd[0]);
						WritePackFloat(pack, vEnd[1]);
						WritePackFloat(pack, vEnd[2]);
						WritePackFloat(pack, 350.0);
							
						spawnRing_Vectors(vEnd, TREBUCHET_LIGHTNING_RANGE * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 255, 255, 200, 1, ACHILLES_CHARGE_TIME, 6.0, 0.1, 1, 1.0);
						
					//	npc.FireRocket(vecTarget, 500.0, 600.0);
						npc.PlayMeleeSound();
						npc.m_flAttackHappenswillhappen = false;
					}
					else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
					{
						npc.m_flAttackHappenswillhappen = false;
					}
				}
			}
			if (npc.m_flNextMeleeAttack < GetGameTime(npc.index))
			{
				npc.StartPathing();
			}
	}
	else
	{
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index,_,_,_,_,_,_,_,999999.9, true);
		if(npc.m_iTarget < 1)
		{
			npc.m_iTarget = GetClosestTarget(npc.index);
		}
	}
}

void MedivalTrebuchet_NPCDeath(int entity)
{
	MedivalTrebuchet npc = view_as<MedivalTrebuchet>(entity);
	
		
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	float pos[3]; GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
	TE_Particle("asplode_hoodoo", pos, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
}


public Action Smite_Timer_Trebuchet(Handle Smite_Logic, DataPack pack)
{
	ResetPack(pack);
	int entity = EntRefToEntIndex(ReadPackCell(pack));
	
	if (!IsValidEntity(entity))
	{
		return Plugin_Stop;
	}
		
	float NumLoops = ReadPackFloat(pack);
	float spawnLoc[3];
	for (int GetVector = 0; GetVector < 3; GetVector++)
	{
		spawnLoc[GetVector] = ReadPackFloat(pack);
	}
	
	float damage = ReadPackFloat(pack);
	
	if (NumLoops >= ACHILLES_CHARGE_TIME)
	{
		float secondLoc[3];
		for (int replace = 0; replace < 3; replace++)
		{
			secondLoc[replace] = spawnLoc[replace];
		}
		
		for (int sequential = 1; sequential <= 5; sequential++)
		{
			spawnRing_Vectors(secondLoc, 1.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 255, 255, 120, 1, 0.33, 6.0, 0.4, 1, (TREBUCHET_LIGHTNING_RANGE * 5.0)/float(sequential));
			secondLoc[2] += 150.0 + (float(sequential) * 20.0);
		}
		
		secondLoc[2] = 1500.0;
		
		float vAngles[3];
		int prop2 = CreateEntityByName("prop_dynamic_override");
		if(IsValidEntity(prop2))
		{
			DispatchKeyValue(prop2, "model", "models/props_junk/rock001a.mdl");
			DispatchKeyValue(prop2, "modelscale", "2.00");
			DispatchKeyValue(prop2, "StartDisabled", "false");
			DispatchKeyValue(prop2, "Solid", "0");
			SetEntProp(prop2, Prop_Data, "m_nSolidType", 0);
			DispatchSpawn(prop2);
			SetEntityCollisionGroup(prop2, 1);
			AcceptEntityInput(prop2, "DisableShadow");
			AcceptEntityInput(prop2, "DisableCollision");
		//	vAngles[0] += 90.0;
			TeleportEntity(prop2, spawnLoc, vAngles, NULL_VECTOR);
			CreateTimer(5.0, Timer_RemoveEntity, EntIndexToEntRef(prop2), TIMER_FLAG_NO_MAPCHANGE);
		}

		spawnBeam(0.8, 255, 255, 255, 255, "materials/sprites/laserbeam.vmt", 4.0, 6.2, _, 2.0, secondLoc, spawnLoc);	
		spawnBeam(0.8, 255, 255, 255, 200, "materials/sprites/lgtning.vmt", 4.0, 5.2, _, 2.0, secondLoc, spawnLoc);	
		spawnBeam(0.8, 255, 255, 255, 200, "materials/sprites/lgtning.vmt", 3.0, 4.2, _, 2.0, secondLoc, spawnLoc);	
		
		DataPack pack_boom = new DataPack();
		pack_boom.WriteFloat(spawnLoc[0]);
		pack_boom.WriteFloat(spawnLoc[1]);
		pack_boom.WriteFloat(spawnLoc[2]);
		pack_boom.WriteCell(1);
		RequestFrame(MakeExplosionFrameLater, pack_boom);
		
		CreateEarthquake(spawnLoc, 1.0, TREBUCHET_LIGHTNING_RANGE * 2.5, 16.0, 255.0);
		Explode_Logic_Custom(damage, entity, entity, -1, spawnLoc, TREBUCHET_LIGHTNING_RANGE * 1.4,_,0.8, true, 15, false, 25.0);  //Explosion range increase
	
		return Plugin_Stop;
	}
	else
	{
		spawnRing_Vectors(spawnLoc, TREBUCHET_LIGHTNING_RANGE * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 255, 255, 120, 1, 0.33, 6.0, 0.1, 1, 1.0);
	//	EmitAmbientSound(SOUND_WAND_LIGHTNING_ABILITY_PAP_CHARGE, spawnLoc, _, 60, _, _, GetRandomInt(80, 110));
		
		ResetPack(pack);
		WritePackCell(pack, EntIndexToEntRef(entity));
		WritePackFloat(pack, NumLoops + ACHILLES_CHARGE_TIME);
		WritePackFloat(pack, spawnLoc[0]);
		WritePackFloat(pack, spawnLoc[1]);
		WritePackFloat(pack, spawnLoc[2]);
		WritePackFloat(pack, damage);
	}
	
	return Plugin_Continue;
}

static void spawnBeam(float beamTiming, int r, int g, int b, int a, char sprite[PLATFORM_MAX_PATH], float width=2.0, float endwidth=2.0, int fadelength=1, float amp=15.0, float startLoc[3] = {0.0, 0.0, 0.0}, float endLoc[3] = {0.0, 0.0, 0.0})
{
	int color[4];
	color[0] = r;
	color[1] = g;
	color[2] = b;
	color[3] = a;
		
	int SPRITE_INT = PrecacheModel(sprite, false);

	TE_SetupBeamPoints(startLoc, endLoc, SPRITE_INT, 0, 0, 0, beamTiming, width, endwidth, fadelength, amp, color, 0);
	
	TE_SendToAll();
}
