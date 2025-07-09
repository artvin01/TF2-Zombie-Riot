#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"vo/spy_paincrticialdeath01.mp3",
	"vo/spy_paincrticialdeath02.mp3",
	"vo/spy_paincrticialdeath03.mp3"
};

static const char g_HurtSounds[][] =
{
	"vo/spy_painsharp01.mp3",
	"vo/spy_painsharp02.mp3",
	"vo/spy_painsharp03.mp3",
	"vo/spy_painsharp04.mp3"
};

static const char g_RangedAttackSounds[][] =
{
	"weapons/diamond_back_01.wav",
	"weapons/diamond_back_02.wav",
	"weapons/diamond_back_03.wav"
};

static const char g_RangedReloadSounds[][] =
{
	"weapons/revolver_worldreload.wav"
};

void Huirgrajo_Precache()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Huirgrajo");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_huirgrajo");
	strcopy(data.Icon, sizeof(data.Icon), "guardian");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_IberiaExpiAlliance;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Huirgrajo(client, vecPos, vecAng, team);
}

methodmap Huirgrajo < CClotBody
{
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSounds[GetURandomInt() % sizeof(g_HurtSounds)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetURandomInt() % sizeof(g_DeathSounds)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayPistolFire()
 	{
		EmitSoundToAll(g_RangedAttackSounds[GetURandomInt() % sizeof(g_RangedAttackSounds)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayPistolReload()
 	{
		EmitSoundToAll(g_RangedReloadSounds[GetURandomInt() % sizeof(g_RangedReloadSounds)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public Huirgrajo(int client, float vecPos[3], float vecAng[3], int ally)
	{
		Huirgrajo npc = view_as<Huirgrajo>(CClotBody(vecPos, vecAng, "models/player/spy.mdl", "0.9", "1000", ally));
		
		i_NpcWeight[npc.index] = 1;
		npc.SetActivity("ACT_MP_RUN_SECONDARY");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		float gameTime = GetGameTime(npc.index);
		npc.m_flNextMeleeAttack = gameTime + 9.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flCharge_delay = gameTime + 3.0;
		npc.Anger = false;
		npc.m_iTargetAlly = client;

		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = ClotThink;
		
		npc.m_flSpeed = 300.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flWaveScale = (Waves_GetRoundScale() + 1) * 0.133333;
		npc.m_flExtraDamage *= npc.m_flWaveScale;
		npc.m_flExtraDamage *= 2.0;
		
		ApplyStatusEffect(npc.index, npc.index, "Clear Head", 999999.0);	
		ApplyStatusEffect(npc.index, npc.index, "Solid Stance", 999999.0);	
		ApplyStatusEffect(npc.index, npc.index, "Fluid Movement", 999999.0);	
		
		static const int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
	
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_snub_nose/c_snub_nose.mdl", _, skin);
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/spy/hwn2019_avian_amante/hwn2019_avian_amante.mdl", _, skin);
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/all_class/hwn_spy_priest/hwn_spy_priest_spy.mdl", _, skin);
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/spy/sept2014_lady_killer/sept2014_lady_killer.mdl", _, skin);
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/spy/short2014_invisible_ishikawa/short2014_invisible_ishikawa.mdl", _, skin);
		
		return npc;
	}
}

static void ClotThink(int iNPC)
{
	Huirgrajo npc = view_as<Huirgrajo>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		if(npc.m_flDoingAnimation < gameTime)
			npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST");
		
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_flReloadDelay > gameTime)
	{
		// Reloading
		npc.m_flSpeed = 0.0;
	}
	else
	{
		// Moving
		npc.m_flSpeed = npc.Anger ? 160.0 : 260.0;
	}

	int target = npc.m_iTarget;
	if(i_Target[npc.index] != -1 && !IsValidEnemy(npc.index, target))
		i_Target[npc.index] = -1;
	
	if(i_Target[npc.index] == -1 || npc.m_flGetClosestTargetTime < gameTime)
	{
		// Find closest target near ourself
		float vecTarget[3]; WorldSpaceCenter(npc.index, vecTarget);
		target = GetClosestTarget(npc.index);
		npc.m_iTarget = target;
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}

	int ally = npc.m_iTargetAlly;

	int walk = npc.m_iTarget;
	if(i_TargetToWalkTo[npc.index] != -1 && !IsValidEnemy(npc.index, walk))
		i_TargetToWalkTo[npc.index] = -1;
	
	if(IsValidAlly(npc.index, ally))
	{
		if(i_TargetToWalkTo[npc.index] == -1 || npc.m_flGetClosestTargetTime < gameTime)
		{
			// Find closest target near ally
			float vecTarget[3]; WorldSpaceCenter(ally, vecTarget);
			walk = GetClosestTarget(npc.index, .EntityLocation = vecTarget);
			npc.m_iTarget = walk;
			npc.m_flGetClosestTargetTime = gameTime + 1.0;
		}
	}
	else
	{
		if(i_TargetAlly[npc.index] != -1)
		{
			// Ally died, buff up stats
			i_TargetAlly[npc.index] = -1;
			npc.m_flExtraDamage *= 1.5;
			npc.m_flWaveScale *= 1.5;
		}

		// No ally, target is our walkto
		ally = -1;
		walk = target;
		i_TargetToWalkTo[npc.index] = i_Target[npc.index];
	}

	// Walk backwards if our target isn't who walking to
	npc.m_bAllowBackWalking = target != walk;

	if(!npc.Anger)
	{
		// Allies died or at 1/3 HP
		if(ally == -1 || (GetEntProp(npc.index, Prop_Data, "m_iHealth") < (ReturnEntityMaxHealth(npc.index) / 3)))
		{
			npc.Anger = true;
	
			if(IsValidEntity(npc.m_iWearable3))
				RemoveEntity(npc.m_iWearable3);
			
			if(IsValidEntity(npc.m_iWearable6))
				RemoveEntity(npc.m_iWearable6);
			
			float pos[3];
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);

			int particle = ParticleEffectAt(pos, "unusual_sapper_teamcolor_blue", 0.0);
			SetParent(npc.index, particle, "head", {0.0, 0.0, -1.0});
			npc.m_iWearable3 = particle;

			pos[2] += 70.0;
			particle = ParticleEffectAt(pos, "scout_dodge_blue", 0.0);
			SetParent(npc.index, particle);
			npc.m_iWearable6 = particle;
		}
	}

	if(walk > 0)
	{
		float vecTarget[3]; WorldSpaceCenter(walk, vecTarget);
		float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
		float distance = GetVectorDistance(vecTarget, vecMe, true);	
		
		if(npc.m_flReloadDelay > gameTime)
		{
			npc.StopPathing();
			npc.SetActivity("ACT_MP_CROUCH_SECONDARY");
		}
		else if(distance < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3]; 
			PredictSubjectPosition(npc, walk, _, _, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);

			npc.StartPathing();
			npc.SetActivity("ACT_MP_RUN_SECONDARY");
		}
		else
		{
			npc.SetGoalEntity(walk);
			
			npc.StartPathing();
			npc.SetActivity("ACT_MP_RUN_SECONDARY");
		}

		npc.StartPathing();
	}
	else
	{
		npc.StopPathing();
	}

	if(target > 0)
	{
		float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
		float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);

		// Laser conditions:
		// 
		// 1a. Allied died
		// 1b. Our target is marked
		// 
		// 2a. Past Wave 31
		// 2b. Past Wave 21 and ally died
		if(npc.m_flNextMeleeAttack < gameTime && npc.m_flWaveScale > 3.1 && (ally == -1 || NpcStats_IberiaIsEnemyMarked(target)))
		{
			npc.m_flNextMeleeAttack = gameTime + ((GetURandomInt() % (npc.Anger ? 3 : 2)) ? 1.0 : 8.0);
			FatherGrigori_IOC_Invoke(EntIndexToEntRef(npc.index), target);
			
			if(npc.m_bAllowBackWalking)
				npc.FaceTowards(vecTarget, 1500.0);
		}
		else if(npc.m_flNextRangedAttack < gameTime)
		{
			if(npc.m_iAttacksTillReload < 1)
			{
				npc.AddGesture("ACT_MP_RELOAD_CROUCH_SECONDARY");
				npc.m_flNextRangedAttack = gameTime + 1.35;
				npc.m_flReloadDelay = gameTime + 1.35;
				npc.m_iAttacksTillReload = 6;
				npc.PlayPistolReload();
			}
			else
			{
				target = Can_I_See_Enemy(npc.index, target);
				if(IsValidEnemy(npc.index, target))
				{
					// Can dodge bullets by moving
					PredictSubjectPositionForProjectiles(npc, target, -400.0, _, vecTarget);
					
					npc.m_bAllowBackWalking = true;
					npc.FaceTowards(vecTarget, 1500.0);
					
					float eyePitch[3], vecDirShooting[3];
					GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
					
					vecTarget[2] += 15.0;
					MakeVectorFromPoints(vecMe, vecTarget, vecDirShooting);
					GetVectorAngles(vecDirShooting, vecDirShooting);

					float sub = fabs(fixAngle(eyePitch[1])) - fabs(fixAngle(vecDirShooting[1]));
					if(sub > -12.5 && sub < 12.5)
					{
						vecDirShooting[1] = eyePitch[1];

						npc.m_flNextRangedAttack = gameTime + 0.85;
						npc.m_iAttacksTillReload--;
						
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
						
						KillFeed_SetKillIcon(npc.index, "enforcer");
						FireBullet(npc.index, npc.m_iWearable1, vecMe, vecDir, 50.0, 9000.0, DMG_BULLET, "bullet_tracer01_red");

						npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY");
						npc.PlayPistolFire();
					}
				}
			}
		}
		else if(npc.m_flCharge_delay < gameTime && npc.m_flWaveScale > 1.6)
		{
			target = Can_I_See_Enemy(npc.index, target);
			if(IsValidEnemy(npc.index, target))
			{
				PredictSubjectPositionForProjectiles(npc, target, GetRandomFloat(-1000.0, 1000.0), _, vecTarget);

				npc.m_bAllowBackWalking = true;
				npc.FaceTowards(vecTarget, 15000.0);

				npc.m_flCharge_delay = gameTime + (npc.Anger ? 3.0 : 6.0);
				PluginBot_Jump(npc.index, vecTarget);
			}
		}
		else
		{
			target = Can_I_See_Enemy(npc.index, target);
			if(IsValidEnemy(npc.index, target))
			{
				// Can dodge bullets by moving
				PredictSubjectPositionForProjectiles(npc, target, -400.0, _, vecTarget);
				
				npc.m_bAllowBackWalking = true;
				npc.FaceTowards(vecTarget, 1500.0);
			}
		}
	}
}

static void ClotDeath(int entity)
{
	Huirgrajo npc = view_as<Huirgrajo>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	
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
}