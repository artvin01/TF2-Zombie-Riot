#pragma semicolon 1
#pragma newdecls required

// this should vary from npc to npc as some are in a really small area.

static char g_DeathSounds[][] = {
	"vo/heavy_paincrticialdeath01.mp3",
	"vo/heavy_paincrticialdeath02.mp3",
	"vo/heavy_paincrticialdeath03.mp3",
};

static char g_HurtSound[][] = {
	")vo/heavy_painsharp01.mp3",
	")vo/heavy_painsharp02.mp3",
	")vo/heavy_painsharp03.mp3",
	")vo/heavy_painsharp04.mp3",
	")vo/heavy_painsharp05.mp3",
};

static char g_IdleSound[][] = {
	")vo/heavy_jeers03.mp3",	
	")vo/heavy_jeers04.mp3",	
	")vo/heavy_jeers06.mp3",
	")vo/heavy_jeers09.mp3",	
};

static char g_IdleAlertedSounds[][] = {
	")vo/taunts/heavy_taunts16.mp3",
	")vo/taunts/heavy_taunts18.mp3",
	")vo/taunts/heavy_taunts19.mp3",
};

static char g_MeleeHitSounds[][] = {
	")weapons/boxing_gloves_hit1.wav",
	")weapons/boxing_gloves_hit2.wav",
	")weapons/boxing_gloves_hit3.wav",
	")weapons/boxing_gloves_hit4.wav",
};
static char g_MeleeAttackSounds[][] = {
	")weapons/boxing_gloves_swing1.wav",
	")weapons/boxing_gloves_swing2.wav",
	")weapons/boxing_gloves_swing4.wav",
};

int i_OwnerToGoTo[MAXENTITIES];

public void HeavyBearBoss_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_IdleSound));	i++) { PrecacheSound(g_IdleSound[i]);	}
	for (int i = 0; i < (sizeof(g_HurtSound));	i++) { PrecacheSound(g_HurtSound[i]);	}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds));	i++) { PrecacheSound(g_IdleAlertedSounds[i]);	}
	PrecacheModel("models/player/scout.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Mama Bear");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_heavy_bear_boss");
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return HeavyBearBoss(vecPos, vecAng, team);
}

methodmap HeavyBearBoss < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;

		EmitSoundToAll(g_IdleSound[GetRandomInt(0, sizeof(g_IdleSound) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);

		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	
	public void PlayHurtSound()
	{
		
		EmitSoundToAll(g_HurtSound[GetRandomInt(0, sizeof(g_HurtSound) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);
	}
	public void PlayKilledEnemySound() 
	{
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(5.0, 10.0);
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);	
	}
	
	
	public HeavyBearBoss(float vecPos[3], float vecAng[3], int ally)
	{
		HeavyBearBoss npc = view_as<HeavyBearBoss>(CClotBody(vecPos, vecAng, "models/player/heavy.mdl", "1.5", "1000", ally, false, true));

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		KillFeed_SetKillIcon(npc.index, "warrior_spirit");

		int iActivity = npc.LookupActivity("ACT_MP_STAND_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);

		npc.m_bisWalking = false;

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_bDissapearOnDeath = false;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		npc.g_TimesSummoned = 0;

		f3_SpawnPosition[npc.index][0] = vecPos[0];
		f3_SpawnPosition[npc.index][1] = vecPos[1];
		f3_SpawnPosition[npc.index][2] = vecPos[2];

		npc.m_iAttacksTillMegahit = 0;
		
		func_NPCDeath[npc.index] = HeavyBearBoss_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = HeavyBearBoss_OnTakeDamage;
		func_NPCThink[npc.index] = HeavyBearBoss_ClotThink;

		SDKHook(npc.index, SDKHook_OnTakeDamagePost, HeavyBearBoss_OnTakeDamagePost);
		
		int skin = GetRandomInt(0, 1);
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
	
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/heavy/jul13_bear_necessitys/jul13_bear_necessitys.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_bear_claw/c_bear_claw.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/heavy/sbox2014_heavy_gunshow/sbox2014_heavy_gunshow.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		
		npc.StopPathing();
			
		
		return npc;
	}
	
}


public void HeavyBearBoss_ClotThink(int iNPC)
{
	HeavyBearBoss npc = view_as<HeavyBearBoss>(iNPC);

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
	Npc_Base_Thinking(iNPC, 400.0, "ACT_MP_RUN_MELEE", "ACT_MP_STAND_MELEE", 200.0, gameTime);
	
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
					float damage = 200.0;

					
					if(target > 0) 
					{
						npc.PlayMeleeHitSound();
						if(npc.m_iAttacksTillMegahit > 3)
						{
							npc.m_iAttacksTillMegahit = 0;
							SDKHooks_TakeDamage(target, npc.index, npc.index, damage * 1.3, DMG_CLUB);
							Custom_Knockback(npc.index, target, 500.0);
						}
						else
						{
							SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB);
							Custom_Knockback(npc.index, target, 350.0);
						}

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
					npc.SetActivity("ACT_MP_RUN_MELEE");
				}
			}
			case 1:
			{			
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				//Can i see This enemy, is something in the way of us?
				//Dont even check if its the same enemy, just engage in killing, and also set our new target to this just in case.
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iAttacksTillMegahit += 1;
					npc.m_iTarget = Enemy_I_See;

					if(npc.m_iAttacksTillMegahit > 3)
					{
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_SECONDARY");
					}
					else
					{
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
					}

					npc.PlayMeleeSound();
					
					npc.m_flAttackHappens = gameTime + 0.3;

				//	npc.m_flDoingAnimation = gameTime + 0.6;
					npc.m_flNextMeleeAttack = gameTime + 1.5;
					npc.m_bisWalking = true;
				}
			}
		}
	}
	npc.PlayIdleSound();
}


public Action HeavyBearBoss_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	HeavyBearBoss npc = view_as<HeavyBearBoss>(victim);

	float gameTime = GetGameTime(npc.index);

	if (npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}

	return Plugin_Changed;
}

public void HeavyBearBoss_OnTakeDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype) 
{
	HeavyBearBoss npc = view_as<HeavyBearBoss>(victim);
	int maxhealth = ReturnEntityMaxHealth(npc.index);
	
	float ratio = float(GetEntProp(npc.index, Prop_Data, "m_iHealth")) / float(maxhealth);
	if(0.9-(npc.g_TimesSummoned*0.2) > ratio)
	{
		npc.g_TimesSummoned++;
		maxhealth /= 10;
		for(int i; i<1; i++)
		{
			float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
			float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
			
			int spawn_index = NPC_CreateByName("npc_heavy_bear_minion", -1, pos, ang, GetTeam(npc.index));
			if(spawn_index > MaxClients)
			{
				NpcStats_CopyStats(npc.index, spawn_index);
				Level[spawn_index] = Level[victim];
				i_OwnerToGoTo[spawn_index] = EntIndexToEntRef(victim);
				Apply_Text_Above_Npc(spawn_index,0, maxhealth);
				CreateTimer(0.1, TimerHeavyBearBossInitiateStuff, EntIndexToEntRef(spawn_index), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
				SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
			}
		}
	}
}
public Action TimerHeavyBearBossInitiateStuff(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
		int owner = EntRefToEntIndex(i_OwnerToGoTo[entity]);
		if(IsValidEntity(owner))
		{
			if(!b_NpcHasDied[owner])
			{
				GetEntPropVector(owner, Prop_Data, "m_vecAbsOrigin", f3_SpawnPosition[entity]);
			}
			else
			{
				NPC_Despawn(entity); //despawn em. Dont kill.
				return Plugin_Stop;				
			}
			//Get the bosses location, and set it as their spawn, so they move there.
		}
		else
		{
			NPC_Despawn(entity); //despawn em. Dont kill.
			return Plugin_Stop;
		}
	}
	else
	{
		//not valid.
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public void HeavyBearBoss_NPCDeath(int entity)
{
	HeavyBearBoss npc = view_as<HeavyBearBoss>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();
	}
	SDKUnhook(entity, SDKHook_OnTakeDamagePost, HeavyBearBoss_OnTakeDamagePost);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}


