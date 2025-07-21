#pragma semicolon 1
#pragma newdecls required

static char g_DeathSounds[][] = {
	"npc/dog/dog_scared1.wav",
};

static char g_HurtSounds[][] = {
	")physics/metal/metal_box_impact_bullet1.wav",
	")physics/metal/metal_box_impact_bullet2.wav",
	")physics/metal/metal_box_impact_bullet3.wav",
};

static char g_IdleSounds[][] = {
	"npc/dog/dog_idle1.wav",
	"npc/dog/dog_idle2.wav",
	"npc/dog/dog_idle3.wav",
	"npc/dog/dog_idle4.wav",
	"npc/dog/dog_idle5.wav",
};

static char g_MeleeHitSounds[][] = {
	"vehicles/v8/vehicle_impact_heavy1.wav",
	"vehicles/v8/vehicle_impact_heavy2.wav",
	"vehicles/v8/vehicle_impact_heavy3.wav",
	"vehicles/v8/vehicle_impact_heavy4.wav",
};
static char g_MeleeAttackSounds[][] = {
	"npc/dog/dog_angry1.wav",
	"npc/dog/dog_angry2.wav",
	"npc/dog/dog_angry3.wav",
};


public void WFOuroborosEkas_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}

	PrecacheSound("player/flow.wav");
	PrecacheModel("models/dog.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Ouroboros Ekas");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_whiteflower_robot");
	strcopy(data.Icon, sizeof(data.Icon), "medic");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_WhiteflowerSpecial;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return WFOuroborosEkas(vecPos, vecAng, team);
}

methodmap WFOuroborosEkas < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 70);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
		

	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 70);
		
		
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 70);
		
		
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 70);
		

	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 70);
		

	}

	
	
	public WFOuroborosEkas(float vecPos[3], float vecAng[3], int ally)
	{
		WFOuroborosEkas npc = view_as<WFOuroborosEkas>(CClotBody(vecPos, vecAng, "models/dog.mdl", "1.3", "900000", ally, false, true));
		
		i_NpcWeight[npc.index] = 3;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_WALK");
		if(iActivity > 0) npc.StartActivity(iActivity);

		FormatEx(c_NpcName[npc.index], sizeof(c_NpcName[]), "W.F. Ouroboros Ekas-%i", GetRandomInt(1000, 9999));
		b_NameNoTranslation[npc.index] = true;

		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_ROBOT;
		
		npc.m_flNextMeleeAttack = 0.0;
		
		Is_a_Medic[npc.index] = true;
		
		func_NPCDeath[npc.index] = WFOuroborosEkas_NPCDeath;
		func_NPCThink[npc.index] = WFOuroborosEkas_ClotThink;
		func_NPCOnTakeDamage[npc.index] = WFOuroborosEkas_OnTakeDamage;
		
		
		//IDLE
		npc.m_flSpeed = 125.0;
		
		npc.m_flAttackHappenswillhappen = false;
		npc.StartPathing();
		
		return npc;
	}
	
}


public void WFOuroborosEkas_ClotThink(int iNPC)
{
	WFOuroborosEkas npc = view_as<WFOuroborosEkas>(iNPC);
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	

	if(npc.m_blPlayHurtAnimation)
	{
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	if(!npc.Anger)
	{
		if(npc.m_iTargetAlly && !IsValidAlly(npc.index, npc.m_iTargetAlly))
			npc.m_iTargetAlly = 0;
		
		if(!npc.m_iTargetAlly)
		{
			npc.m_iTargetAlly = GetClosestAlly(npc.index);
			if(npc.m_iTargetAlly < 1)
			{
				fl_TotalArmor[npc.index] = 0.65;
				npc.Anger = true; //	>:(
				return;
			}
		}	
	}

	if(!NpcStats_IsEnemySilenced(npc.index))
	{
		int team = GetTeam(npc.index);
		if(team == 2)
		{
			for(int client = 1; client <= MaxClients; client++)
			{
				if(IsClientInGame(client) && GetClientTeam(client) != 3 && IsEntityAlive(client) && !Is_a_Medic[client])
				{
					ApplyStatusEffect(npc.index, client, "Hussar's Warscream", 0.5);
					ApplyStatusEffect(npc.index, client, "War Cry", 0.5);
				}
			}
		}

		for(int i; i < i_MaxcountNpcTotal; i++)
		{
			int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
			if(entity != npc.index && entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity) && GetTeam(entity) == team && !Is_a_Medic[entity])
			{
				ApplyStatusEffect(npc.index, entity, "Hussar's Warscream", 0.5);
				ApplyStatusEffect(npc.index, entity, "War Cry", 0.5);
			}
		}
	}
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
	
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
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
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget,_,_,_,1))
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					float damage = 500.0;
					if(ShouldNpcDealBonusDamage(target))
						damage *= 1.5;

					
					if(target > 0) 
					{
						SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB);
						// Hit sound
						npc.PlayMeleeHitSound();
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
		else if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.25 && npc.m_flNextMeleeAttack < gameTime)
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
					
				if(!npc.Anger)
				{
					if(npc.m_iChanged_WalkCycle != 4) 	
					{
						npc.m_bisWalking = true;
						npc.m_iChanged_WalkCycle = 4;
						npc.SetActivity("ACT_WALK");
						npc.m_flSpeed = 125.0;
						view_as<CClotBody>(iNPC).StartPathing();
					}
				}
				else
				{
					if(npc.m_iChanged_WalkCycle != 5) 	
					{
						npc.m_bisWalking = true;
						npc.m_iChanged_WalkCycle = 5;
						npc.SetActivity("ACT_RUN");
						npc.m_flSpeed = 420.0;
						view_as<CClotBody>(iNPC).StartPathing();
					}
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

					npc.AddGestureViaSequence("pound");

					npc.PlayMeleeSound();
					
					npc.m_flAttackHappens = gameTime + 0.3;
					npc.m_flDoingAnimation = gameTime + 0.3;
					npc.m_flNextMeleeAttack = gameTime + 1.5;
					npc.m_bisWalking = true;
				}
			}
		}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleSound();
}


public Action WFOuroborosEkas_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	WFOuroborosEkas npc = view_as<WFOuroborosEkas>(victim);

	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void WFOuroborosEkas_NPCDeath(int entity)
{
	WFOuroborosEkas npc = view_as<WFOuroborosEkas>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}

	int maxhealth = ReturnEntityMaxHealth(npc.index);
	float startPosition[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", startPosition);
	maxhealth /= 2;
	for(int i; i<1; i++)
	{
		float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
		float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
		
		int spawn_index = NPC_CreateByName("npc_whiteflower_ekas_piloteer", -1, pos, ang, GetTeam(npc.index));
		if(spawn_index > MaxClients)
		{
			NpcStats_CopyStats(npc.index, spawn_index);
			NpcAddedToZombiesLeftCurrently(spawn_index, true);
			SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
			SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
		}
	}
}


