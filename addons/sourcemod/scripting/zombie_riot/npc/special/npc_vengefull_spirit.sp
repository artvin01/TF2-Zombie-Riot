#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"npc/zombie/zombie_die1.wav",
	"npc/zombie/zombie_die2.wav",
	"npc/zombie/zombie_die3.wav",
};

static const char g_SpookSound[][] = {
	"npc/stalker/go_alert2a.wav",
};

void VengefullSpirit_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_SpookSound));		i++) { PrecacheSound(g_SpookSound[i]);		}
	PrecacheModel("models/stalker.mdl");
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Vengeful Spirit");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_vengefull_spirit");
	strcopy(data.Icon, sizeof(data.Icon), "mb_spiritangry"); 				//leaderboard_class_(insert the name)
	data.IconCustom = true;													//download needed?
	data.Flags = 0;																//example: MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;, forces these flags.	
	data.Category = Type_Special;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return VengefullSpirit(vecPos, vecAng, team);
}

methodmap VengefullSpirit < CClotBody
{
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlaySpookSound(int entity) 
	{
		EmitSoundToAll(g_SpookSound[GetRandomInt(0, sizeof(g_SpookSound) - 1)], entity, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, 0.6);
	}
	
	public VengefullSpirit(float vecPos[3], float vecAng[3], int ally)
	{
		VengefullSpirit npc = view_as<VengefullSpirit>(CClotBody(vecPos, vecAng, "models/stalker.mdl", "1.15", MinibossHealthScaling(45.0, true), ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_WALK");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedAttackHappening = 0.0;
		
		npc.m_iBleedType = STEPTYPE_NONE;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(Internal_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Internal_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Internal_ClotThink);
		
		float wave = float(Waves_GetRoundScale()+1);
		wave *= 0.133333;
		npc.m_flWaveScale = wave;
		npc.m_flWaveScale *= MinibossScalingReturn();
		
		//IDLE
		npc.m_iState = 4;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 340.0;
		npc.m_bCamo = true;

		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 125, 0, 0, 125);

		int Decicion = TeleportDiversioToRandLocation(npc.index,_,1250.0, 500.0);

		if(Decicion == 2)
			Decicion = TeleportDiversioToRandLocation(npc.index, _, 1250.0, 250.0);

		if(Decicion == 2)
			Decicion = TeleportDiversioToRandLocation(npc.index, _, 1250.0, 0.0);

		b_NoHealthbar[npc.index] = 1; //Makes it so they never have an outline
		GiveNpcOutLineLastOrBoss(npc.index, false);
		b_thisNpcHasAnOutline[npc.index] = true; 
		
		return npc;
	}
}

static void Internal_ClotThink(int iNPC)
{
	VengefullSpirit npc = view_as<VengefullSpirit>(iNPC);
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
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3];
			PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}
		VengefullSpiritSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
}

static void Internal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VengefullSpirit npc = view_as<VengefullSpirit>(victim);
		
	if(attacker <= 0)
		return;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
}

static void Internal_NPCDeath(int entity)
{
	VengefullSpirit npc = view_as<VengefullSpirit>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
}

void VengefullSpiritSelfDefense(VengefullSpirit npc, float gameTime, int target, float distance)
{
	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
		{
			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.m_flAttackHappens = 1.0;
				npc.m_flNextMeleeAttack = 1.0;
			}
		}
	}
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget))
			{
							
				target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 65.0;
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 5.0;

					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt * npc.m_flWaveScale, DMG_CLUB, -1, _, vecHit);

					// Hit sound
					npc.PlaySpookSound(target);
					npc.m_flNextMeleeAttack = gameTime + 1.0;
					
					if(target <= MaxClients)
					{
						Client_Shake(target, 0, 100.0, 100.0, 0.5, false);
						UTIL_ScreenFade(target, 66, 1, FFADE_OUT, 0, 0, 0, 255);
					}
				} 
			}
			delete swingTrace;
		}
	}

}
