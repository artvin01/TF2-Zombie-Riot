#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/npc/male01/no01.wav",
	"vo/npc/male01/no02.wav",
};

static const char g_HurtSounds[][] = {
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

static const char g_MeleeAttackSounds[][] = {
	"weapons/bow_shoot.wav",
};

void KazimierzKnightArcher_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	PrecacheSound("physics/metal/metal_box_impact_bullet1.wav");
	PrecacheModel(COMBINE_CUSTOM_MODEL);

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Roar Knightclub Trainee");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_seaborn_kazimersch_archer");
	strcopy(data.Icon, sizeof(data.Icon), "ds_archer");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Seaborn;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return KazimierzKnightArcher(vecPos, vecAng, team, data);
}

methodmap KazimierzKnightArcher < CClotBody
{
	
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayMeleeSound() 
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	
	public KazimierzKnightArcher(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		KazimierzKnightArcher npc = view_as<KazimierzKnightArcher>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "8000", ally));
		
		SetVariantInt(4);
		AcceptEntityInput(npc.index, "SetBodyGroup");


		if(data[0])
		{
			npc.m_iOverlordComboAttack = StringToInt(data);
		}
		else
		{
			npc.m_iOverlordComboAttack = 1000;
		}

		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_SEABORN_WALK_RANGED");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		npc.m_flNextMeleeAttack = 0.0;
		
		
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_SEABORN;
		
		func_NPCDeath[npc.index] = KazimierzKnightArcher_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = KazimierzKnightArcher_OnTakeDamage;
		func_NPCThink[npc.index] = KazimierzKnightArcher_ClotThink;
		func_NPCAnimEvent[npc.index] = HandleAnimEventMedival_KazimierzArcher;

		npc.m_iState = 0;
		npc.m_flSpeed = 210.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_fbRangedSpecialOn = false;
		npc.m_flNextRangedSpecialAttack = GetGameTime() + 10.0;
 
		SetEntityRenderColor(npc.index, 155, 155, 255, 255);		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/workshop/weapons/c_models/c_crusaders_crossbow/c_crusaders_crossbow.mdl");
		SetVariantString("0.8");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("partyhat", "models/workshop/player/items/demo/sum19_backbreakers_skullcracker/sum19_backbreakers_skullcracker.mdl");
		SetVariantString("1.35");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		SetEntityRenderColor(npc.m_iWearable2, 155, 155, 255, 255);
		SetEntityRenderColor(npc.m_iWearable1, 155, 155, 255, 255);

		npc.m_iWearable3 = npc.EquipItem("", "models/effects/resist_shield/resist_shield.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		npc.StartPathing();
		
		
		return npc;
	}
	
	
}


public void KazimierzKnightArcher_ClotThink(int iNPC)
{
	KazimierzKnightArcher npc = view_as<KazimierzKnightArcher>(iNPC);
	if(npc.m_flNextRangedSpecialAttack)
	{
		if(npc.m_flNextRangedSpecialAttack < GetGameTime())
		{
			npc.m_flNextRangedSpecialAttack = 0.0;
			npc.m_iOverlordComboAttack = 0;
			if(IsValidEntity(npc.m_iWearable3))
			{
				RemoveEntity(npc.m_iWearable3);
			}
		}
	}

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3]; PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
			
			npc.SetGoalVector(vPredictedPos);
		}
		else
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}
		//Get position for just travel here.
		if(npc.m_flJumpStartTime < GetGameTime(npc.index))
		{
			npc.m_flSpeed = 210.0;
			npc.StartPathing();
		}

		if(npc.m_flDoingAnimation > gameTime) //I am doing an animation or doing something else, default to doing nothing!
		{
			npc.m_iState = -1;
		}
		else if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 5.0) && npc.m_flNextMeleeAttack < gameTime)
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
					npc.SetActivity("ACT_SEABORN_WALK_RANGED");
				}
			}
			case 1:
			{		
				//Walk to target
				if(!npc.m_bPathing)
					npc.StartPathing();
					
				npc.m_bisWalking = true;
				if(npc.m_iChanged_WalkCycle != 4) 	
				{
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_SEABORN_WALK_RANGED");
				}	

				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				//Can i see This enemy, is something in the way of us?
				//Dont even check if its the same enemy, just engage in killing, and also set our new target to this just in case.
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;

					npc.m_flSpeed = 0.0;
					npc.AddGesture("ACT_SEABORN_ATTACK_RANGED_1");


					npc.m_flAttackHappens = gameTime + 0.35;
					npc.m_flDoingAnimation = gameTime + 0.35;
					npc.m_flNextMeleeAttack = gameTime + 1.5;
					npc.m_flJumpStartTime = GetGameTime(npc.index) + 0.7; //Reuse this!
					
					npc.m_bisWalking = true;
					
					npc.StopPathing();
					
				}
			}
		}
	}
	else
	{
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}

	npc.PlayIdleAlertSound();
}

public Action KazimierzKnightArcher_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	KazimierzKnightArcher npc = view_as<KazimierzKnightArcher>(victim);
	
	/*
	if(attacker > MaxClients && !IsValidEnemy(npc.index, attacker))
		return Plugin_Continue;
	*/
	if(npc.m_iOverlordComboAttack && npc.m_flNextRangedSpecialAttack > GetGameTime())
	{
		damage -= float(npc.m_iOverlordComboAttack);
		EmitSoundToAll("physics/metal/metal_box_impact_bullet1.wav", victim, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		if(damage < 0.0)
		{
			damage = 0.0;
		}
	}

	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index) && damage > 0)
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	
	return Plugin_Changed;
}

public void KazimierzKnightArcher_NPCDeath(int entity)
{
	KazimierzKnightArcher npc = view_as<KazimierzKnightArcher>(entity);
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
}


public void HandleAnimEventMedival_KazimierzArcher(int entity, int event)
{
	if(event == 1001)
	{
		KazimierzKnightArcher npc = view_as<KazimierzKnightArcher>(entity);
		
		int PrimaryThreatIndex = npc.m_iTarget;
	
		if(IsValidEnemy(npc.index, PrimaryThreatIndex))
		{
			float vecTarget[3];
				
			float projectile_speed = 1200.0;
			
			PredictSubjectPositionForProjectiles(npc, PrimaryThreatIndex, projectile_speed,_,vecTarget);
				
			npc.FaceTowards(vecTarget, 30000.0);
						
			npc.PlayMeleeSound();
			
			float damage = 40.0;
			npc.FireArrow(vecTarget, damage, projectile_speed);
		}
	}
	
}
