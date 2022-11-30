#pragma semicolon 1
#pragma newdecls required

// this should vary from npc to npc as some are in a really small area.

public void MadChicken_OnMapStart_NPC()
{
	PrecacheModel("models/player/scout.mdl");
}

methodmap MadChicken < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;

		char buffer[PLATFORM_MAX_PATH];
		Format(buffer, sizeof(buffer), "vo/taunts/scout_taunts%d.mp3", GetRandomInt(19, 22));
		EmitSoundToAll(buffer, this.index, SNDCHAN_VOICE, 75, _, 1.0, GetRandomInt(125, 135));

		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		char buffer[PLATFORM_MAX_PATH];
		Format(buffer, sizeof(buffer), "vo/scout_painsharp0%d.mp3", GetRandomInt(1, 8));
		EmitSoundToAll(buffer, this.index, SNDCHAN_VOICE, 75, _, 1.0, GetRandomInt(125, 135));

		this.m_flNextHurtSound = GetGameTime() + GetRandomFloat(0.6, 1.6);
		
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}
	
	
	public MadChicken(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		MadChicken npc = view_as<MadChicken>(CClotBody(vecPos, vecAng, "models/player/scout.mdl", "0.5", "300", ally, false,_,_,_,{8.0,8.0,16.0}));
		
		i_NpcInternalId[npc.index] = MAD_CHICKEN;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);

		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		f3_SpawnPosition[0] = vecPos[0];
		f3_SpawnPosition[1] = vecPos[1];
		f3_SpawnPosition[2] = vecPos[2];
		
		SDKHook(npc.index, SDKHook_OnTakeDamage, MadChicken_OnTakeDamage);
		SDKHook(npc.index, SDKHook_Think, MadChicken_ClotThink);
		
		int skin = GetRandomInt(0, 1);
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/scout/sf14_nugget_noggin/sf14_nugget_noggin.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/scout/sf14_fowl_fists/sf14_fowl_fists.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/scout/sf14_talon_trotters/sf14_talon_trotters.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		
		PF_StopPathing(npc.index);
		npc.m_bPathing = false;	
		
		return npc;
	}
	
}

//TODO 
//Rewrite
public void MadChicken_ClotThink(int iNPC)
{
	CClotBody npc = view_as<CClotBody>(iNPC);

	float gameTime = GetGameTime(npc.index);

	static int NoNewEnemy;
	//some npcs deservere full update time!
	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}
	

	npc.m_flNextDelayTime = gameTime;// + DEFAULT_UPDATE_DELAY_FLOAT;
	
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

	// npc.m_iTarget comes from here.
	Npc_Base_Thinking(iNPC, 200.0, "ACT_MP_RUN_MELEE", "ACT_MP_STAND_MELEE", 150.0, gameTime);
	
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				Handle swingTrace;
				npc.FaceTowards(WorldSpaceCenter(npc.m_iTarget), 15000.0); //Snap to the enemy. make backstabbing hard to do.
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, _)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					float damage = 1.0;

					npc.PlayMeleeHitSound();
					if(target > 0) 
					{
						SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB);
					}
				}
				delete swingTrace;
			}
		}
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		NoNewEnemy = 0; //We were able to find an enemy, set it to 0.
		float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);
		float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
			
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, npc.m_iTarget);
			
			PF_SetGoalVector(npc.index, vPredictedPos);
		}
		else
		{
			PF_SetGoalEntity(npc.index, npc.m_iTarget);
		}
		//Get position for just travel here.

		if(npc.m_flDoingAnimation > gameTime) //I am doing an animation or doing something else, default to doing nothing!
		{
			npc.m_iState = -1;
		}
		else if(flDistanceToTarget < Pow(100.0, 2.0) && npc.m_flNextMeleeAttack < gameTime)
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
					npc.SetActivity("ACT_MP_RUN_MELEE");
				}
			}
			case 1:
			{			
				int Enemy_I_See;
							
				Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				
				//Can i see This enemy, is something in the way of us?
				//Dont even check if its the same enemy, just engage in rape, and also set our new target to this just in case.
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;

					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");

					npc.PlayMeleeSound();
					
					npc.m_flAttackHappens = gameTime + 0.2;

				//	npc.m_flDoingAnimation = gameTime + 0.6;
					npc.m_flNextMeleeAttack = gameTime + 1.0;
					npc.m_bisWalking = true;
				}
			}
		}
	}
	npc.PlayIdleAlertSound();
}


public Action MadChicken_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	MadChicken npc = view_as<MadChicken>(victim);

	float gameTime = GetGameTime(npc.index);

	if (npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}

	npc.m_flGetClosestTargetNoResetTime = gameTime + 5.0; //make them angry for 5 seconds if they are too far away.

	if(npc.m_iTarget == -1) //Only set it if they actaully have no target.
	{
		npc.m_iTarget = attacker;
	}
	return Plugin_Changed;
}

public void MadChicken_NPCDeath(int entity)
{
	MadChicken npc = view_as<MadChicken>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	SDKUnhook(entity, SDKHook_OnTakeDamage, MadChicken_OnTakeDamage);
	SDKUnhook(entity, SDKHook_Think, MadChicken_ClotThink);

		if(IsValidEntity(npc.m_iWearable1))
			RemoveEntity(npc.m_iWearable1);
		if(IsValidEntity(npc.m_iWearable2))
			RemoveEntity(npc.m_iWearable2);
		if(IsValidEntity(npc.m_iWearable3))
			RemoveEntity(npc.m_iWearable3);
}


