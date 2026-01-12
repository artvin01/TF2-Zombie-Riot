#pragma semicolon 1
#pragma newdecls required


#define FFADE_IN            0x0001        // Just here so we don't pass 0 into the function
#define FFADE_OUT           0x0002        // Fade out (not in)
#define FFADE_MODULATE      0x0004        // Modulate (don't blend)
#define FFADE_STAYOUT       0x0008        // ignores the duration, stays faded out until new ScreenFade message received
#define FFADE_PURGE         0x0010        // Purges all other fades, replacing them with this one

static const char g_DeathSounds[][] = {
	"npc/zombie/zombie_die1.wav",
	"npc/zombie/zombie_die2.wav",
	"npc/zombie/zombie_die3.wav",
};

static const char g_SpookSound[][] = {
	"npc/stalker/go_alert2a.wav",
};

void WanderingSpirit_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_SpookSound));		i++) { PrecacheSound(g_SpookSound[i]);		}
	PrecacheModel("models/stalker.mdl");
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Wandering Spirit");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_wandering_spirit");
	strcopy(data.Icon, sizeof(data.Icon), "mb_spirit"); 	//leaderboard_class_(insert the name)
	data.IconCustom = true;								//download needed?
	data.Flags = 0;											//example: MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;, forces these flags.	
	data.Category = Type_Special;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return WanderingSpirit(vecPos, vecAng, team, data);
}

methodmap WanderingSpirit < CClotBody
{
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlaySpookSound(int entity) 
	{
		EmitSoundToAll(g_SpookSound[GetRandomInt(0, sizeof(g_SpookSound) - 1)], entity, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public WanderingSpirit(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		WanderingSpirit npc = view_as<WanderingSpirit>(CClotBody(vecPos, vecAng, "models/stalker.mdl", "1.15", MinibossHealthScaling(50.0), ally));
		
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
		npc.m_flSpeed = 100.0;
		npc.m_bCamo = true;

		npc.m_flMeleeArmor = 2.0; 	//Takes much more melee dmg
		npc.m_flRangedArmor = 0.5; 	//Takes much less ranged damage

		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 0, 0, 0, 150);

		SetEntPropFloat(npc.index, Prop_Send, "m_fadeMinDist", 600.0);
		SetEntPropFloat(npc.index, Prop_Send, "m_fadeMaxDist", 700.0);
		TeleportDiversioToRandLocation(npc.index);

		//counts as a static npc, means it wont count towards NPC limit.
		if(StrContains(data, "ghostbusters") == -1)
			AddNpcToAliveList(npc.index, 1);

		if(GetRandomInt(1,10) == 1)
			strcopy(c_NpcName[npc.index], sizeof(c_NpcName[]), "Wandering Spitit");

		b_NoHealthbar[npc.index] = 1; //Makes it so they never have an outline
		GiveNpcOutLineLastOrBoss(npc.index, false);
		b_thisNpcHasAnOutline[npc.index] = true; 
		
		return npc;
	}
}

static void Internal_ClotThink(int iNPC)
{
	WanderingSpirit npc = view_as<WanderingSpirit>(iNPC);
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
	WanderingSpiritIsEnemyClose(iNPC);
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
		WanderingSpiritSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
}

static void Internal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	WanderingSpirit npc = view_as<WanderingSpirit>(victim);
		
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
	WanderingSpirit npc = view_as<WanderingSpirit>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	if(npc.m_iState != 0)
	{
		CPrintToChatAll("{blue}The spirit is able to move on onto the afterlife...");
	}
}

void WanderingSpiritSelfDefense(WanderingSpirit npc, float gameTime, int target, float distance)
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
				
				int maxhealth;
				maxhealth = ReturnEntityMaxHealth(npc.index);
				if(IsValidEnemy(npc.index, target))
				{
					SetEntProp(npc.index, Prop_Data, "m_iHealth", maxhealth);
					npc.m_iState -= 1;
					float damageDealt = 400.0;
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 25.0;

					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt * npc.m_flWaveScale, DMG_CLUB, -1, _, vecHit);


					// Hit sound
					npc.PlaySpookSound(target);
					if(target <= MaxClients)
					{
						Client_Shake(target, 0, 100.0, 100.0, 0.5, false);
						if(!HasSpecificBuff(target, "Fluid Movement"))
							TF2_StunPlayer(target, 0.5, 0.9, TF_STUNFLAG_SLOWDOWN);
							
						UTIL_ScreenFade(target, 66, 1, FFADE_OUT, 0, 0, 0, 255);
						maxhealth /= 5;
					}
					int Decicion = TeleportDiversioToRandLocation(npc.index,_,1250.0, 500.0);

					if(Decicion == 2)
						Decicion = TeleportDiversioToRandLocation(npc.index, _, 1250.0, 250.0);

					if(Decicion == 2)
						Decicion = TeleportDiversioToRandLocation(npc.index, _, 1250.0, 0.0);
				} 
					
				if(npc.m_iState <= 0)
				{
					npc.m_iState = 0;
					SmiteNpcToDeath(npc.index);
					CPrintToChatAll("{crimson}%t is unable to move on and splits apart...",c_NpcName[npc.index]);
					float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
					float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
					for(int loop=1; loop<=CountPlayersOnRed(); loop++)
					{
						int spawn_index = NPC_CreateByName("npc_vengefull_spirit", -1, pos, ang, GetTeam(npc.index));
						if(spawn_index > MaxClients)
						{
							NpcStats_CopyStats(npc.index, spawn_index);
							if(StrEqual(c_NpcName[npc.index], "Wandering Spitit"))
								strcopy(c_NpcName[spawn_index], sizeof(c_NpcName[]), "Vengeful Spitit");
							NpcAddedToZombiesLeftCurrently(spawn_index, true);
						//	SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
						//	SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
						}
					}
				}
			}
			delete swingTrace;
		}
	}

}



void WanderingSpiritIsEnemyClose(int iNPC)
{
	float SelfPos[3];
	float AllyPos[3];
	bool FoundCloseEnemy = false;
	GetEntPropVector(iNPC, Prop_Data, "m_vecAbsOrigin", SelfPos);
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsValidEnemy(iNPC, client))
		{
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", AllyPos);
			float flDistanceToTarget = GetVectorDistance(SelfPos, AllyPos, true);
			if(flDistanceToTarget < (700.0 * 700.0))
			{
				FoundCloseEnemy = true;
				break;
			}
		}
	}
	if(!FoundCloseEnemy)
	{
		for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++) //RED npcs.
		{
			int entity_close = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
			if(IsValidEntity(entity_close))
			{
				if(IsValidEnemy(iNPC, entity_close))
				{
					GetEntPropVector(entity_close, Prop_Data, "m_vecAbsOrigin", AllyPos);
					float flDistanceToTarget = GetVectorDistance(SelfPos, AllyPos, true);
					if(flDistanceToTarget < (700.0 * 700.0))
					{
						FoundCloseEnemy = true;
						break;
					}
				}
			}
		}
	}

	WanderingSpirit npc = view_as<WanderingSpirit>(iNPC);
	if(FoundCloseEnemy)
	{
		npc.m_flSpeed = 200.0;
	}
	else
	{
		npc.m_flSpeed = 100.0;
	}
}


void UTIL_ScreenFade(int client,int duration,int time,int flags,int r,int g,int b,int a)
{
	int clients[1];
	Handle bf;
	clients[0] = client;

	bf = StartMessage("Fade", clients, 1);
	BfWriteShort(bf, duration);
	BfWriteShort(bf, time);
	BfWriteShort(bf, flags);
	BfWriteByte(bf, r);
	BfWriteByte(bf, g);
	BfWriteByte(bf, b);
	BfWriteByte(bf, a);
	EndMessage();
}
