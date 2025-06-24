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

static float f_TimeBefore[MAXENTITIES];

void AnnoyingSpirit_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_SpookSound));		i++) { PrecacheSound(g_SpookSound[i]);		}
	PrecacheModel("models/stalker.mdl");
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Annoying Spirit");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_annoying_spirit");
	strcopy(data.Icon, sizeof(data.Icon), ""); 				//leaderboard_class_(insert the name)
	data.IconCustom = false;													//download needed?
	data.Flags = 0;																//example: MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;, forces these flags.	
	data.Category = Type_Mutation;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return AnnoyingSpirit(vecPos, vecAng, team);
}

methodmap AnnoyingSpirit < CClotBody
{
	property float m_fTimeBefore
	{
		public get()							{ return f_TimeBefore[this.index]; }
		public set(float TempValueForProperty) 	{ f_TimeBefore[this.index] = TempValueForProperty; }
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlaySpookSound(int entity) 
	{
		EmitSoundToAll(g_SpookSound[GetRandomInt(0, sizeof(g_SpookSound) - 1)], entity, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, GetRandomInt(60, 140));
	}
	
	public AnnoyingSpirit(float vecPos[3], float vecAng[3], int ally)
	{
		AnnoyingSpirit npc = view_as<AnnoyingSpirit>(CClotBody(vecPos, vecAng, "models/stalker.mdl", "1.0", "1000000", ally));
		
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
		
		npc.m_iState = 4;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 275.0;
		npc.m_bCamo = true;
		Is_a_Medic[npc.index] = true;

		npc.m_fTimeBefore = GetGameTime(npc.index) + 240.0;

		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 50, 50, 50, 30);

		int Decicion = TeleportDiversioToRandLocation(npc.index,_,1250.0, 500.0);

		if(Decicion == 2)
			Decicion = TeleportDiversioToRandLocation(npc.index, _, 1250.0, 250.0);

		if(Decicion == 2)
			Decicion = TeleportDiversioToRandLocation(npc.index, _, 1250.0, 0.0);

		npc.m_bStaticNPC = true;
		AddNpcToAliveList(npc.index, 1);
		b_NoHealthbar[npc.index] = true; //Makes it so they never have an outline
		GiveNpcOutLineLastOrBoss(npc.index, false);
		b_thisNpcHasAnOutline[npc.index] = true;

		fl_TotalArmor[npc.index] = 0.1;
		return npc;
	}
}

static void Internal_ClotThink(int iNPC)
{
	AnnoyingSpirit npc = view_as<AnnoyingSpirit>(iNPC);
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
		npc.m_iTarget = GetClosestTarget(npc.index, _, _, _, true);
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
		AnnoyingSpiritWega(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index, _, _, _, true);
	}

	if(npc.m_fTimeBefore < GetGameTime(npc.index) && !npc.Anger)
	{
		npc.Anger = true;
		fl_TotalArmor[npc.index] = 1.0;
	}
}

static Action Internal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	AnnoyingSpirit npc = view_as<AnnoyingSpirit>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	// have it heal the damage it takes
	if(!npc.Anger)
	{
		if(damage >= float(GetEntProp(npc.index, Prop_Data, "m_iHealth")))	
		{
			damage = 0.0;
			HealEntityGlobal(npc.index, npc.index, float(GetEntProp(npc.index, Prop_Data, "m_iMaxHealth")), 1.0, 0.0, HEAL_ABSOLUTE);
			return Plugin_Handled;
		}	
	}

	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}

	return Plugin_Continue;
}

static void Internal_NPCDeath(int entity)
{
	AnnoyingSpirit npc = view_as<AnnoyingSpirit>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
}

void AnnoyingSpiritWega(AnnoyingSpirit npc, float gameTime, int target, float distance)
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
				npc.m_flAttackHappens = 20.0;
				npc.m_flNextMeleeAttack = 20.0;
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
					if(IsValidClient(target) && !b_IsPlayerABot[target])
					{
						SetHudTextParams(-1.0, -1.0, 2.0, 255, 75, 75, 255);
						ShowHudText(target, -1, "WAAAAAAAAAHHHHHHH");
					}

					// WAAAAAAHHHHG
					npc.PlaySpookSound(target);
					npc.m_flNextMeleeAttack = gameTime + 20.0;
					
					if(target <= MaxClients)
					{
						Client_Shake(target, 0, 100.0, 100.0, 0.5, false);
						UTIL_ScreenFade(target, 66, 1, FFADE_OUT, 0, 0, 0, 255);
					}

					int Decicion = TeleportDiversioToRandLocation(npc.index,_,1250.0, 500.0);

					if(Decicion == 2)
						Decicion = TeleportDiversioToRandLocation(npc.index, _, 1250.0, 250.0);

					if(Decicion == 2)
						Decicion = TeleportDiversioToRandLocation(npc.index, _, 1250.0, 0.0);
				} 
			}
			delete swingTrace;
		}
	}
}
