#pragma semicolon 1
#pragma newdecls required

static const char g_IdleAlertedSounds[][] =
{
	"pl_hoodoo/alarm_clock_ticking_3.wav",
};

static const char g_MeleeHitSounds[][] = {
	"ambient/bumper_car_floor_break.wav",
};


void VictoriaBombcart_Precache()
{
	NPCData data;
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheModel("models/combine_apc_dynamic.mdl");
	strcopy(data.Name, sizeof(data.Name), "Bomb Cart");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_bombcart");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_bombcart");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Victoria;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return VictoriaBombcart(vecPos, vecAng, ally);
}

methodmap VictoriaBombcart < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(2.0, 3.0);
	}

	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80, 100));
		

	}

	
	public VictoriaBombcart(float vecPos[3], float vecAng[3], int ally)
	{
		VictoriaBombcart npc = view_as<VictoriaBombcart>(CClotBody(vecPos, vecAng, "models/combine_apc_dynamic.mdl", "0.25", "750", ally));
		
		i_NpcWeight[npc.index] = 1;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = 0;

		func_NPCDeath[npc.index] = VictoriaBombcart_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = VictoriaBombcart_ClotThink;
		
		npc.m_bDissapearOnDeath = true;
		npc.m_flSpeed = 400.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		
		SetEntityRenderColor(npc.index, 100, 100, 255, 255);
		
		npc.m_iWearable1 = npc.EquipItemSeperate("models/workshop/player/items/demo/sum22_head_banger/sum22_head_banger.mdl",_,1,1.75,-120.0);

		return npc;
	}
}

public void VictoriaBombcart_ClotThink(int iNPC)
{
	VictoriaBombcart npc = view_as<VictoriaBombcart>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_iTarget && !IsValidEnemy(npc.index, npc.m_iTarget))
		npc.m_iTarget = 0;
	
	if(!npc.m_iTarget || npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}
	
	if(npc.m_iTarget > 0)
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float distance = GetVectorDistance(vecTarget, VecSelfNpc, true);	
		if(distance < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}

		npc.StartPathing();
		
		if(npc.m_flAttackHappens)
		{
			if(npc.m_flAttackHappens < gameTime)
			{
				npc.m_flAttackHappens = 0.0;
				
				Handle swingTrace;
				npc.FaceTowards(vecTarget, 15000.0);
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, _))
				{
					int target = TR_GetEntityIndex(swingTrace);
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					
					if(target > 0) 
					{
						KillFeed_SetKillIcon(npc.index, "ullapool_caber_explosion");
						if(!ShouldNpcDealBonusDamage(target))
							SDKHooks_TakeDamage(target, npc.index, npc.index, 50.0, DMG_CLUB, -1, _, vecHit);
						else
							SDKHooks_TakeDamage(target, npc.index, npc.index, 300.0, DMG_CLUB, -1, _, vecHit);
							
						float startPosition[3];
						GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", startPosition);
						makeexplosion(-1, startPosition, 0, 0);
						
						
						
						
						// Hit sound
						npc.PlayMeleeHitSound();
						LastHitRef[npc.index] = -1;
						SmiteNpcToDeath(npc.index);
						
					} 
				}

				delete swingTrace;
			}
		}

		if(distance < 10000.0 && npc.m_flNextMeleeAttack < gameTime)
		{
			int target = Can_I_See_Enemy(npc.index, npc.m_iTarget);
			if(IsValidEnemy(npc.index, target))
			{
				npc.m_iTarget = target;
				
				npc.m_flAttackHappens = gameTime + 0.1;
				npc.m_flNextMeleeAttack = gameTime + 0.95;
			}
		}
	}
	else
	{
		npc.StopPathing();
	}

	npc.PlayIdleSound();
}

void VictoriaBombcart_NPCDeath(int entity)
{
	VictoriaBombcart npc = view_as<VictoriaBombcart>(entity);
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	float startPosition[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", startPosition); 
	startPosition[2] += 45;
	
	if(NpcStats_VictorianCallToArms(npc.index))
	{
		Explode_Logic_Custom(100.0, -1, npc.index, -1, startPosition, 150.0, _, _, true, _, false, 1.0);
		ParticleEffectAt(startPosition, "rd_robot_explosion_smoke_linger", 2.0);
		npc.PlayMeleeHitSound();
	}	
}