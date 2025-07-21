#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"vo/spy_paincrticialdeath01.mp3",
	"vo/spy_paincrticialdeath02.mp3",
	"vo/spy_paincrticialdeath03.mp3",
};

static const char g_HurtSound[][] =
{
	"vo/spy_painsharp01.mp3",
	"vo/spy_painsharp02.mp3",
	"vo/spy_painsharp03.mp3",
	"vo/spy_painsharp04.mp3",
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

void Huirgrajo_Setup()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSound);
	PrecacheSoundArray(g_RangedAttackSounds);
	PrecacheSoundArray(g_RangedReloadSounds);
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Huirgrajo The Light Keeper");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_huirgrajo");
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Huirgrajo(vecPos, vecAng, team);
}

methodmap Huirgrajo < CClotBody
{
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSound[GetURandomInt() % sizeof(g_HurtSound)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
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
	
	public Huirgrajo(float vecPos[3], float vecAng[3], int ally)
	{
		Huirgrajo npc = view_as<Huirgrajo>(CClotBody(vecPos, vecAng, "models/player/spy.mdl", "0.9", "300", ally, false));

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		npc.SetActivity("ACT_MP_STAND_SECONDARY");

		float gameTime = GetGameTime(npc.index);
		npc.m_flNextMeleeAttack = gameTime + 9.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flCharge_delay = gameTime + 3.0;
		npc.Anger = false;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		f3_SpawnPosition[npc.index] = vecPos;

		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCOnTakeDamage[npc.index] = ClotTakeDamage;
		func_NPCThink[npc.index] = ClotThink;
		
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

	float speed;
	if(npc.m_flReloadDelay > gameTime)
	{
		speed = 0.0;
	}
	else
	{
		speed = npc.Anger ? 160.0 : 260.0;
	}

	// npc.m_iTarget comes from here, This only handles out of battle instancnes, for inbattle, code it yourself. It also makes NPCS jump if youre too high up.
	Npc_Base_Thinking(npc.index, 800.0, "ACT_MP_RUN_SECONDARY", "ACT_MP_STAND_SECONDARY", speed, gameTime);
	npc.m_bAllowBackWalking = false;

	if(!npc.Anger)
	{
		if(GetEntProp(npc.index, Prop_Data, "m_iHealth") < (ReturnEntityMaxHealth(npc.index) / 3))
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

	int target = npc.m_iTarget;
	
	if(target > 0)
	{
		float vecMe[3], vecTarget[3];
		WorldSpaceCenter(npc.index, vecMe);
		WorldSpaceCenter(target, vecTarget);

		float distance = GetVectorDistance(vecTarget, vecMe, true);
		
		if(npc.m_flReloadDelay > gameTime)
		{
			npc.StopPathing();
			npc.SetActivity("ACT_MP_CROUCH_SECONDARY");
		}
		else if(distance < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3]; 
			PredictSubjectPosition(npc, target, _, _, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);

			npc.StartPathing();
			npc.SetActivity("ACT_MP_RUN_SECONDARY");
		}
		else
		{
			npc.SetGoalEntity(target);
			
			npc.StartPathing();
			npc.SetActivity("ACT_MP_RUN_SECONDARY");
		}

		if(npc.m_flNextMeleeAttack < gameTime)
		{
			npc.m_flNextMeleeAttack = gameTime + ((GetURandomInt() % (npc.Anger ? 3 : 2)) ? 1.0 : 8.0);
			FatherGrigori_IOC_Invoke(EntIndexToEntRef(npc.index), target);
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
						
						float damage = 70000.0;

						KillFeed_SetKillIcon(npc.index, "enforcer");
						FireBullet(npc.index, npc.m_iWearable1, vecMe, vecDir, damage, 9000.0, DMG_BULLET, "bullet_tracer01_red");

						npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY");
						npc.PlayPistolFire();
					}
				}
			}
		}
		else if(npc.m_flCharge_delay < gameTime)
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
	else
	{
		npc.m_flNextMeleeAttack = gameTime + 9.0;
		npc.m_flCharge_delay = gameTime + 3.0;
	}
}

static void ClotTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker > 0)
	{
		Huirgrajo npc = view_as<Huirgrajo>(victim);

		float gameTime = GetGameTime(npc.index);
		if(npc.m_flHeadshotCooldown < gameTime)
		{
			npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
			npc.m_blPlayHurtAnimation = true;
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