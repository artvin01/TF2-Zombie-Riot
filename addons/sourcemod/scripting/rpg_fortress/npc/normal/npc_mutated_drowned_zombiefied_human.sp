#pragma semicolon 1
#pragma newdecls required

// this should vary from npc to npc as some are in a really small area.

static const char g_DeathSounds[][] = {
	"vo/npc/male01/no01.wav",
	"vo/npc/male01/no02.wav",
};

static const char g_HurtSound[][] = {
	"vo/npc/male01/pain01.wav",
	"vo/npc/male01/pain02.wav",
	"vo/npc/male01/pain03.wav",
	"vo/npc/male01/pain05.wav",
	"vo/npc/male01/pain06.wav",
	"vo/npc/male01/pain07.wav",
	"vo/npc/male01/pain08.wav",
	"vo/npc/male01/pain09.wav",
};


static const char g_IdleAlertedSounds[][] = {
	"vo/npc/male01/ohno.wav",
	"vo/npc/male01/overthere01.wav",
	"vo/npc/male01/overthere02.wav",
};

static const char g_IdleSound[][] = {
	"vo/npc/male01/ohno.wav",
	"vo/npc/male01/overthere01.wav",
	"vo/npc/male01/overthere02.wav",
};

static const char g_MeleeHitSounds[][] = {
	
	"weapons/blade_slice_2.wav",
	"weapons/blade_slice_3.wav",
	"weapons/blade_slice_4.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav",
};


static const char g_RangedAttackSounds[][] = {
	"weapons/ar2/fire1.wav",
};

static const char g_RangedAttackSoundsSecondary[][] = {
	"weapons/physcannon/energy_sing_explosion2.wav",
};

static const char g_RangedSpecialAttackSoundsSecondary[][] = {
	"weapons/cow_mangler_over_charge_shot.wav",
};

public void MutatedDrowedZombieHuman_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_IdleSound));	i++) { PrecacheSound(g_IdleSound[i]);	}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds));	i++) { PrecacheSound(g_IdleAlertedSounds[i]);	}
	for (int i = 0; i < (sizeof(g_HurtSound));	i++) { PrecacheSound(g_HurtSound[i]);	}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds));	i++) { PrecacheSound(g_IdleAlertedSounds[i]);	}
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));	i++) { PrecacheSound(g_RangedAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_RangedAttackSoundsSecondary));	i++) { PrecacheSound(g_RangedAttackSoundsSecondary[i]);	}
	for (int i = 0; i < (sizeof(g_RangedSpecialAttackSoundsSecondary));	i++) { PrecacheSound(g_RangedSpecialAttackSoundsSecondary[i]);	}

	PrecacheModel("models/props_mvm/mvm_player_shield.mdl");

	PrecacheModel("models/zombie/classic.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Mutated Drowned Atlantean");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_mutated_drowned_zombie_human");
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return MutatedDrowedZombieHuman(vecPos, vecAng, team);
}

methodmap MutatedDrowedZombieHuman < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;

		EmitSoundToAll(g_IdleSound[GetRandomInt(0, sizeof(g_IdleSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,70);

		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	
	public void PlayHurtSound()
	{
		
		EmitSoundToAll(g_HurtSound[GetRandomInt(0, sizeof(g_HurtSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,70);
	}

	public void PlayRangedSound()
	{
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,70);
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,70);
	}
	public void PlayKilledEnemySound() 
	{
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,70);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(5.0, 10.0);
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,70);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,70);	
	}
	
	public void PlayRangedAttackSecondarySound() {
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlayRangedSpecialAttackSecondarySound()
	{
		EmitSoundToAll(g_RangedSpecialAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedSpecialAttackSoundsSecondary) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public MutatedDrowedZombieHuman(float vecPos[3], float vecAng[3], int ally)
	{
		MutatedDrowedZombieHuman npc = view_as<MutatedDrowedZombieHuman>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.85", "300", ally, false, true));
		
		SetVariantInt(4);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("ACT_IDLE");

		npc.m_bisWalking = false;

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_bDissapearOnDeath = false;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;

		f3_SpawnPosition[npc.index][0] = vecPos[0];
		f3_SpawnPosition[npc.index][1] = vecPos[1];
		f3_SpawnPosition[npc.index][2] = vecPos[2];
		func_NPCDeath[npc.index] = MutatedDrowedZombieHuman_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = MutatedDrowedZombieHuman_OnTakeDamage;
		func_NPCThink[npc.index] = MutatedDrowedZombieHuman_ClotThink;

		SetEntityRenderColor(npc.index, 200, 255, 200, 255);

		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_claymore/c_claymore.mdl");
		SetVariantString("0.7");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("partyhat", "models/player/items/engineer/mad_eye.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("partyhat", "models/player/items/engineer/fwk_engineer_cranial.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable4 = npc.EquipItem("partyhat", "models/workshop/player/items/medic/medic_gasmask/medic_gasmask.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");

		SetEntityRenderColor(npc.m_iWearable1, 200, 255, 200, 255);

		SetEntityRenderColor(npc.m_iWearable2, 200, 255, 200, 255);	
		npc.StopPathing();
			
		
		return npc;
	}
	
}


public void MutatedDrowedZombieHuman_ClotThink(int iNPC)
{
	MutatedDrowedZombieHuman npc = view_as<MutatedDrowedZombieHuman>(iNPC);

/*
	SetVariantInt(1);
	AcceptEntityInput(iNPC, "SetBodyGroup");

	if(IsValidEntity(npc.m_iWearable5))
	{
		float Rotation[3];
		float Pos[3];
		npc.GetPositionInfront(64.0, Pos,Rotation);
		TeleportEntity(npc.m_iWearable5, Pos,Rotation,NULLVECTOR, true);
	}
*/
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
		npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}

	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	// npc.m_iTarget comes from here, This only handles out of battle instancnes, for inbattle, code it yourself. It also makes NPCS jump if youre too high up.
	if(npc.m_flDoingSpecial)
	{
		Npc_Base_Thinking(iNPC, 250.0, "ACT_RUN", "ACT_IDLE", 300.0, gameTime);
		fl_TotalArmor[npc.index] = 0.75;

	}
	else
	{
		Npc_Base_Thinking(iNPC, 250.0, "ACT_RUN", "ACT_IDLE", 290.0, gameTime);
		fl_TotalArmor[npc.index] = 1.0;
	}

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
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 1)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					float damage = 85000.0;
					if(npc.m_flDoingSpecial)
						damage = 90000.0;

					
					if(target > 0) 
					{
						npc.PlayMeleeHitSound();
						KillFeed_SetKillIcon(npc.index, "sword");
						SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB);

						int Health = GetEntProp(target, Prop_Data, "m_iHealth");
						
						if(Health <= 0)
						{
							npc.PlayKilledEnemySound();
						}
					}
				}
				delete swingTrace;
			}
		}
	}

	if(npc.m_flNextRangedSpecialAttackHappens)
	{
		if(IsValidEnemy(npc.index, npc.m_iTarget))
		{
			float vecTarget[3];
			WorldSpaceCenter(npc.m_iTarget, vecTarget);
			npc.FaceTowards(vecTarget, 30000.0);
			if(npc.m_flNextRangedSpecialAttackHappens < gameTime)
			{
				npc.m_flNextRangedSpecialAttackHappens = 0.0;
				npc.PlayRangedSpecialAttackSecondarySound();
				npc.m_flDoingSpecial = GetGameTime(npc.index) + 3.0;
				float flPos[3]; // original
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
				npc.m_iWearable6 = ParticleEffectAt_Parent(flPos, "outerspace_belt_blue", npc.index, "head", {0.0,0.0,0.0});
			}
		}
	}
	if(npc.m_flDoingSpecial)
	{
		if(npc.m_flDoingSpecial < gameTime)
		{
			npc.m_flDoingSpecial = 0.0;
			if(IsValidEntity(npc.m_iWearable6))
				RemoveEntity(npc.m_iWearable6);
		}	
	}

	if(npc.m_flNextRangedAttackHappening)
	{
		if(IsValidEnemy(npc.index, npc.m_iTarget))
		{
			float vecTarget[3];
			WorldSpaceCenter(npc.m_iTarget, vecTarget);
			npc.FaceTowards(vecTarget, 30000.0);
			if(npc.m_flNextRangedAttackHappening < gameTime)
			{
				if(IsValidEntity(npc.m_iWearable5))
					RemoveEntity(npc.m_iWearable5);

				npc.PlayRangedAttackSecondarySound();

				npc.m_flNextRangedAttackHappening = 0.0;
				float vecSpread = 0.1;
					
				npc.FaceTowards(vecTarget, 20000.0);
					
				float eyePitch[3];
				GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
						
				//
				//
					
					
				float x, y;
				x = GetRandomFloat( -0.0, 0.0 ) + GetRandomFloat( -0.0, 0.0 );
				y = GetRandomFloat( -0.0, 0.0 ) + GetRandomFloat( -0.0, 0.0 );
					
				float vecDirShooting[3], vecRight[3], vecUp[3];
				//GetAngleVectors(eyePitch, vecDirShooting, vecRight, vecUp);
					
				vecTarget[2] += 15.0;
				float vecTarget2[3];
				WorldSpaceCenter(npc.index, vecTarget2);
				MakeVectorFromPoints(vecTarget2, vecTarget, vecDirShooting);
				GetVectorAngles(vecDirShooting, vecDirShooting);
				vecDirShooting[1] = eyePitch[1];
				GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
					
				//add the spray
				float vecDir[3];
				vecDir[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
				vecDir[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
				vecDir[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
				NormalizeVector(vecDir, vecDir);

				KillFeed_SetKillIcon(npc.index, "taunt_pyro");
				npc.DispatchParticleEffect(npc.index, "mvm_soldier_shockwave", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("anim_attachment_LH"), PATTACH_POINT_FOLLOW, true);
				float Damage1 = 85000.0;
				if(npc.m_flDoingSpecial)
					Damage1 = 90000.0;

				FireBullet(npc.index, npc.index, vecTarget2, vecDir, Damage1, 1000.0, DMG_BULLET, "bullet_tracer02_blue", _,_,"anim_attachment_LH");
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
			npc.m_iState = 2; //Throw a Shield.
		}
		else if(flDistanceToTarget < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 8.5) && npc.m_flNextRangedAttack < gameTime)
		{
			npc.m_iState = 3; //Engage in Close Range Destruction.
		}
		else if(flDistanceToTarget < GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED && npc.m_flNextMeleeAttack < gameTime)
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
					npc.SetActivity("ACT_RUN");
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

					npc.AddGesture("ACT_MELEE_ATTACK_SWING_GESTURE");

					npc.PlayMeleeSound();
					
					npc.m_flAttackHappens = gameTime + 0.4;

					npc.m_flDoingAnimation = gameTime + 0.4;
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
					npc.m_iTarget = Enemy_I_See;

					npc.AddGesture("ACT_METROPOLICE_DEPLOY_MANHACK");

				//	npc.PlayMeleeSound();
					
					npc.m_flNextRangedSpecialAttackHappens = gameTime + 0.8;

					npc.m_flDoingAnimation = gameTime + 1.2;
					npc.m_flNextRangedSpecialAttack = gameTime + 10.5;
					npc.m_bisWalking = false;
					npc.StopPathing();
					
				}
				else
				{
					npc.m_flNextRangedSpecialAttack = gameTime + 0.4; //Recheck later.
				}
			}
			case 3:
			{			
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				//Can i see This enemy, is something in the way of us?
				//Dont even check if its the same enemy, just engage in killing, and also set our new target to this just in case.
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;

					npc.AddGesture("ACT_PUSH_PLAYER",_,_,_,0.5);

					npc.m_flNextRangedAttackHappening = gameTime + 0.8;

					npc.m_flDoingAnimation = gameTime + 1.2;
					npc.m_flNextRangedAttack = gameTime + 7.5;

					npc.m_bisWalking = false;
					npc.StopPathing();
					
					float flPos[3]; // original
					GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
					npc.m_iWearable5 = ParticleEffectAt_Parent(flPos, "flaregun_energyfield_red", npc.index, "anim_attachment_LH", {0.0,0.0,0.0});
				}
			}
		}
	}
	npc.PlayIdleSound();
}


public Action MutatedDrowedZombieHuman_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	MutatedDrowedZombieHuman npc = view_as<MutatedDrowedZombieHuman>(victim);

	float gameTime = GetGameTime(npc.index);

	if (npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

public void MutatedDrowedZombieHuman_NPCDeath(int entity)
{
	MutatedDrowedZombieHuman npc = view_as<MutatedDrowedZombieHuman>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();
	}

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


