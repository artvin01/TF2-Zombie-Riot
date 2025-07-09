#pragma semicolon 1
#pragma newdecls required

// this should vary from npc to npc as some are in a really small area.

static char g_DeathSounds[][] = {
	"vo/medic_paincrticialdeath01.mp3",
	"vo/medic_paincrticialdeath02.mp3",
	"vo/medic_paincrticialdeath03.mp3",
};

static char g_HurtSound[][] = {
	")vo/medic_painsharp01.mp3",
	")vo/medic_painsharp02.mp3",
	")vo/medic_painsharp03.mp3",
	")vo/medic_painsharp04.mp3",
	")vo/medic_painsharp05.mp3",
	")vo/medic_painsharp06.mp3",
	")vo/medic_painsharp07.mp3",
	")vo/medic_painsharp08.mp3",
};

static char g_IdleSound[][] = {
	")vo/null.mp3",
};

static char g_IdleAlertedSounds[][] = {
	")vo/medic_battlecry01.mp3",
	")vo/medic_battlecry02.mp3",
	")vo/medic_battlecry03.mp3",
	")vo/medic_battlecry04.mp3",
};

static char g_MeleeHitSounds[][] = {
	"weapons/halloween_boss/knight_axe_hit.wav",
};
static char g_MeleeAttackSounds[][] = {
	"weapons/cbar_miss1.wav",
};

static const char g_RangedAttackSoundsSecondary[][] = {
	"weapons/physcannon/energy_sing_explosion2.wav",
};
static const char g_RangedAttackAbilitySounds[][] = {
	"weapons/cow_mangler_over_charge_shot.wav",
};

#define SOUND_WAND_LIGHTNING_ABILITY_PAP_SMITE	"misc/halloween/spell_mirv_explode_primary.wav"

public void NemanBoss_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_IdleSound));	i++) { PrecacheSound(g_IdleSound[i]);	}
	for (int i = 0; i < (sizeof(g_HurtSound));	i++) { PrecacheSound(g_HurtSound[i]);	}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds));	i++) { PrecacheSound(g_IdleAlertedSounds[i]);	}
	PrecacheSoundArray(g_RangedAttackSoundsSecondary);
	PrecacheSoundArray(g_RangedAttackAbilitySounds);
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Neman The Expidonsan");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_neman_expi");
	data.Func = ClotSummon;
	NPC_Add(data);
	
	PrecacheSound(SOUND_WAND_LIGHTNING_ABILITY_PAP_SMITE);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return NemanBoss(vecPos, vecAng, team);
}

methodmap NemanBoss < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;

		EmitSoundToAll(g_IdleSound[GetRandomInt(0, sizeof(g_IdleSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);

		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	
	public void PlayHurtSound()
	{
		
		EmitSoundToAll(g_HurtSound[GetRandomInt(0, sizeof(g_HurtSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
	}
	public void PlayKilledEnemySound() 
	{
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(5.0, 10.0);
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);	
	}
	public void PlayRangedAttackSecondarySound() 
	{
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
	}
	public void PlayRangedAttackAbilitySound() 
	{
		EmitSoundToAll(g_RangedAttackAbilitySounds[GetRandomInt(0, sizeof(g_RangedAttackAbilitySounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	
	public NemanBoss(float vecPos[3], float vecAng[3], int ally)
	{
		NemanBoss npc = view_as<NemanBoss>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "300", ally, false,_,_,_,_));

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");

		int iActivity = npc.LookupActivity("ACT_MP_STAND_MELEE_ALLCLASS");
		if(iActivity > 0) npc.StartActivity(iActivity);

		npc.m_bisWalking = false;

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_bDissapearOnDeath = false;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		f3_SpawnPosition[npc.index][0] = vecPos[0];
		f3_SpawnPosition[npc.index][1] = vecPos[1];
		f3_SpawnPosition[npc.index][2] = vecPos[2];	

		func_NPCDeath[npc.index] = NemanBoss_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = NemanBoss_OnTakeDamage;
		func_NPCThink[npc.index] = NemanBoss_ClotThink;
		
		int skin = 0;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
	
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_claymore/c_claymore.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/medic/sf14_templar_hood/sf14_templar_hood.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		float flPos[3]; // original
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
		npc.m_iWearable6 = ParticleEffectAt_Parent(flPos, "utaunt_electric_mist_parent", npc.index, "", {0.0,0.0,0.0});


		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);

		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		
		npc.StopPathing();
			
		
		return npc;
	}
	
}


public void NemanBoss_ClotThink(int iNPC)
{
	NemanBoss npc = view_as<NemanBoss>(iNPC);

	float gameTime = GetGameTime(npc.index);

	//some npcs deservere full update time!
	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}
	

	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	

	if(npc.m_blPlayHurtAnimation && npc.m_flDoingAnimation < gameTime) //Dont play dodge anim if we are in an animation.
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST");
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}

	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	// npc.m_iTarget comes from here, This only handles out of battle instancnes, for inbattle, code it yourself. It also makes NPCS jump if youre too high up.
	float speed;
	if(npc.m_flReloadDelay > gameTime)
	{
		speed = 0.0;
	}
	else
	{
		if(b_thisNpcIsABoss[npc.index])
			speed = 190.0;
		else
			speed = 255.0;
	}
	Npc_Base_Thinking(iNPC, 500.0, "ACT_MP_RUN_MELEE_ALLCLASS", "ACT_MP_STAND_MELEE_ALLCLASS", speed, gameTime);
	
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				Handle swingTrace;
				float WorldSpaceCenterVec[3]; 
				WorldSpaceCenter(npc.m_iTarget, WorldSpaceCenterVec);
				npc.FaceTowards(WorldSpaceCenterVec, 15000.0); //Snap to the enemy. make backstabbing hard to do.
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, _)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					float damage = 700.0;

					if(b_thisNpcIsABoss[npc.index])
						damage = 4500.0;

					
					if(target > 0) 
					{
						npc.PlayMeleeHitSound();
						SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB);

						int Health = GetEntProp(target, Prop_Data, "m_iHealth");
						
						if(Health <= 0)
						{
							npc.PlayKilledEnemySound();
							if(GetRandomInt(0,0) == 0)
							{
								npc.m_bisWalking = false;
								npc.m_flNextThinkTime = gameTime + 1.0; //lol taunt, only works if there are people actually around
								npc.AddGesture("ACT_MP_CYOA_PDA_INTRO");
								//Outright taunt them.
							}
						}
					}
				}
				delete swingTrace;
			}
		}
	}
	if(npc.m_flReloadDelay)
	{
		if(npc.m_flReloadDelay < gameTime)
		{
			if(b_thisNpcIsABoss[npc.index])
			{
				if(npc.m_iOverlordComboAttack > 0)
				{
					npc.m_iOverlordComboAttack -= 1;
					npc.m_flReloadDelay = GetGameTime(npc.index) + 0.5;
				}
				else
				{
					npc.m_flReloadDelay = 0.0;
				}
			}
			else
			{
				npc.m_flReloadDelay = 0.0;
			}
			if(IsValidEntity(npc.m_iWearable5))
				RemoveEntity(npc.m_iWearable5);

			if(IsValidEntity(npc.m_iTarget) && IsValidEnemy(npc.index, npc.m_iTarget))
			{
				NemanBoss_InitiateLightning(npc.index);
			}
		}		
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3];
		WorldSpaceCenter(npc.m_iTarget, vecTarget);
		float vecSelf[3];
		WorldSpaceCenter(npc.index, vecSelf);

		float flDistanceToTarget = GetVectorDistance(vecTarget, vecSelf, true);
			
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3]; 
			PredictSubjectPosition(npc, npc.m_iTarget,_,_,vPredictedPos);
			
			npc.SetGoalVector(vPredictedPos);
		}
		else
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}
		//Get position for just travel here.

		if(npc.m_flDoingAnimation > gameTime) //I am doing an animation or doing something else, default to doing nothing!
		{
			npc.m_iState = -1;
		}
		else if(npc.m_flNextRangedSpecialAttack < gameTime)
		{
			npc.m_iState = 2; //Throw a projectile
		}
		else if(flDistanceToTarget > NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && npc.m_flDoingSpecial < gameTime)
		{
			npc.m_iState = 3; //Throw a projectile
		}
		else if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && npc.m_flNextMeleeAttack < gameTime)
		{
			npc.m_iState = 1; //Engage in Close Range Destruction.
		}
		else 
		{
			npc.m_iState = 0; //stand and look if close enough.
		}
		
		switch(npc.m_iState)
		{
			case -1:
			{
				return; //Do nothing.
			}
			case 0:
			{
				//Walk to target
				if(!npc.m_bPathing)
					npc.StartPathing();
					
				npc.m_bisWalking = true;
				if(npc.m_iChanged_WalkCycle != 4) 	
				{
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
				}
			}
			case 1:
			{			
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				//Can i see This enemy, is something in the way of us?
				//Dont even check if its the same enemy, just engage in killing, and also set our new target to this just in case.
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;

					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS");

					npc.PlayMeleeSound();
					
					npc.m_flAttackHappens = gameTime + 0.3;

					npc.m_flNextMeleeAttack = gameTime + 1.5;
					npc.m_bisWalking = true;
				}
			}
			case 2:
			{			
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				//Can i see This enemy, is something in the way of us?
				//Dont even check if its the same enemy, just engage in killing, and also set our new target to this just in case.
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 1.2;
					npc.PlayRangedAttackSecondarySound();
					npc.FaceTowards(vecTarget, 20000.0);
					float damage = 450.0;

					if(b_thisNpcIsABoss[npc.index])
					{
						npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 0.5;
						damage = 3500.0;

					}

					npc.FireParticleRocket(vecTarget, damage , 600.0 , 100.0 , "raygun_projectile_blue");
					npc.AddGesture("ACT_MP_THROW");

					npc.m_iTarget = Enemy_I_See;
				}
			}
			case 3:
			{
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				//Can i see This enemy, is something in the way of us?
				//Dont even check if its the same enemy, just engage in killing, and also set our new target to this just in case.
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					if(npc.m_iChanged_WalkCycle != 6) 	
					{
						npc.m_iChanged_WalkCycle = 6;
						npc.RemoveGesture("ACT_MP_THROW");
						npc.RemoveGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS");
						npc.AddActivityViaSequence("taunt_the_fist_bump");
					}

					
					if(b_thisNpcIsABoss[npc.index])
						npc.m_iOverlordComboAttack = 4;

					npc.StopPathing();
					npc.m_bisWalking = false;
					float flPos[3];
					float flAng[3];
					npc.GetAttachment("effect_hand_r", flPos, flAng);
					npc.m_iWearable5 = ParticleEffectAt_Parent(flPos, "flaregun_trail_blue", npc.index, "effect_hand_r", {0.0,0.0,0.0});
					npc.SetPlaybackRate(0.5);	
					npc.SetCycle(0.03);
					npc.PlayRangedAttackAbilitySound();
					npc.FaceTowards(vecTarget, 20000.0);
					npc.m_flReloadDelay = GetGameTime(npc.index) + 1.0;
					npc.m_flDoingSpecial = GetGameTime(npc.index) + 8.5;
					npc.m_flDoingAnimation = GetGameTime(npc.index) + 1.0;

					npc.m_iTarget = Enemy_I_See;
				}
			}
		}
	}
	npc.PlayIdleSound();
}


public Action NemanBoss_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	NemanBoss npc = view_as<NemanBoss>(victim);

	float gameTime = GetGameTime(npc.index);

	if (npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

public void NemanBoss_NPCDeath(int entity)
{
	NemanBoss npc = view_as<NemanBoss>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();
	}

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);

}

#define NEMAN_FIRST_LIGHTNING_RANGE 100.0

#define NEMAN_CHARGE_TIME 1.5
#define NEMAN_CHARGE_SPAN 0.5

void NemanBoss_InitiateLightning(int iNPC)
{
	float vPredictedPos[3];

	float ChargeTimeSpan = NEMAN_CHARGE_SPAN;
	float ChargeTime = NEMAN_CHARGE_TIME;
	if(b_thisNpcIsABoss[iNPC])
	{
		ChargeTimeSpan *= 0.5;
		ChargeTime *= 0.5;
	}

	NemanBoss npc = view_as<NemanBoss>(iNPC);
	float projectile_speed = 300.0;
	PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, projectile_speed, _,vPredictedPos);
	vPredictedPos[2] -= 40.0;
	//its abit too high up.
	Handle pack;
	CreateDataTimer(ChargeTimeSpan, Smite_Timer_Neman, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	WritePackCell(pack, EntIndexToEntRef(iNPC));
	WritePackFloat(pack, 0.0);
	WritePackFloat(pack, vPredictedPos[0]);
	WritePackFloat(pack, vPredictedPos[1]);
	WritePackFloat(pack, vPredictedPos[2]);
	if(b_thisNpcIsABoss[iNPC])
		WritePackFloat(pack, 4000.0);
	else
		WritePackFloat(pack, 1250.0);
		
	spawnRing_Vectors(vPredictedPos, NEMAN_FIRST_LIGHTNING_RANGE * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 125, 125, 200, 1, ChargeTime, 6.0, 0.1, 1, 1.0);
}

public Action Smite_Timer_Neman(Handle Smite_Logic, DataPack pack)
{
	ResetPack(pack);
	int entity = EntRefToEntIndex(ReadPackCell(pack));
	
	if (!IsValidEntity(entity))
	{
		return Plugin_Stop;
	}

	float ChargeTime = NEMAN_CHARGE_TIME;
	if(b_thisNpcIsABoss[entity])
	{
		ChargeTime *= 0.5;
	}

	float NumLoops = ReadPackFloat(pack);
	float spawnLoc[3];
	for (int GetVector = 0; GetVector < 3; GetVector++)
	{
		spawnLoc[GetVector] = ReadPackFloat(pack);
	}
	
	float damage = ReadPackFloat(pack);
	
	if (NumLoops >= ChargeTime)
	{
		float secondLoc[3];
		for (int replace = 0; replace < 3; replace++)
		{
			secondLoc[replace] = spawnLoc[replace];
		}
		
		for (int sequential = 1; sequential <= 5; sequential++)
		{
			spawnRing_Vectors(secondLoc, 1.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 50, 50, 120, 1, 0.33, 6.0, 0.4, 1, (NEMAN_FIRST_LIGHTNING_RANGE * 5.0)/float(sequential));
			secondLoc[2] += 150.0 + (float(sequential) * 20.0);
		}
		
		secondLoc[2] = 1500.0;
		
		spawnBeam(0.8, 255, 50, 50, 255, "materials/sprites/laserbeam.vmt", 4.0, 6.2, _, 2.0, secondLoc, spawnLoc);	
		spawnBeam(0.8, 255, 50, 50, 200, "materials/sprites/lgtning.vmt", 4.0, 5.2, _, 2.0, secondLoc, spawnLoc);	
		spawnBeam(0.8, 255, 50, 50, 200, "materials/sprites/lgtning.vmt", 3.0, 4.2, _, 2.0, secondLoc, spawnLoc);	
		
		EmitAmbientSound(SOUND_WAND_LIGHTNING_ABILITY_PAP_SMITE, spawnLoc, _, 120);
		
		DataPack pack_boom = new DataPack();
		pack_boom.WriteFloat(spawnLoc[0]);
		pack_boom.WriteFloat(spawnLoc[1]);
		pack_boom.WriteFloat(spawnLoc[2]);
		pack_boom.WriteCell(0);
		RequestFrame(MakeExplosionFrameLater, pack_boom);
		 
		CreateEarthquake(spawnLoc, 1.0, NEMAN_FIRST_LIGHTNING_RANGE * 2.5, 16.0, 255.0);
		Explode_Logic_Custom(damage, entity, entity, -1, spawnLoc, NEMAN_FIRST_LIGHTNING_RANGE * 1.4,_,0.8, true);  //Explosion range increase
	
		return Plugin_Stop;
	}
	else
	{
		spawnRing_Vectors(spawnLoc, NEMAN_FIRST_LIGHTNING_RANGE * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 50, 50, 120, 1, 0.33, 6.0, 0.1, 1, 1.0);
	//	EmitAmbientSound(SOUND_WAND_LIGHTNING_ABILITY_PAP_CHARGE, spawnLoc, _, 60, _, _, GetRandomInt(80, 110));
		
		ResetPack(pack);
		WritePackCell(pack, EntIndexToEntRef(entity));
		WritePackFloat(pack, NumLoops + ChargeTime);
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
