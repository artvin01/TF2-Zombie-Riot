#pragma semicolon 1
#pragma newdecls required

static const char g_MeleeAttackSounds[][] = {
	"misc/halloween/strongman_fast_swing_01.wav",
};
static const char g_MeleeHitSounds[][] = {
	"misc/halloween/strongman_fast_impact_01.wav",
};


void Broly_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Broly");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_broly");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Category = -1;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
	PrecacheModel("models/freak_fortress_2/bobbroly/brolynew.mdl");
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
}


static void ClotPrecache()
{

	PrecacheSoundCustom("#zombiesurvival/aprilfools/broly_theme.mp3");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Broly(vecPos, vecAng, team, data);
}

methodmap Broly < CClotBody
{
	
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public Broly(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		ally = TFTeam_Stalkers;
		Broly npc = view_as<Broly>(CClotBody(vecPos, vecAng, "models/freak_fortress_2/bobbroly/brolynew.mdl", "1.15", "500000000", ally, false, true, true,true)); //giant!
		i_NpcWeight[npc.index] = 5;

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_STAND_MELEE_ALLCLASS");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		npc.m_bDissapearOnDeath = true;
		b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true; //Make allied npcs ignore him.


		
		npc.Anger = false;
		npc.m_iState = 0;
		for(int i; i < i_MaxcountNpcTotal; i++)
		{
			int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
			if(IsValidEntity(entity))
			{
				char npc_classname[60];
				NPC_GetPluginById(i_NpcInternalId[entity], npc_classname, sizeof(npc_classname));

				if(entity != INVALID_ENT_REFERENCE && (StrEqual(npc_classname, "npc_john_the_allmighty") && IsEntityAlive(entity)))
				{
					npc.m_iTarget = entity;
					npc.Anger = true;
				}
			}
		}

		func_NPCDeath[npc.index] = view_as<Function>(Internal_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Internal_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Internal_ClotThink);

		
		npc.StartPathing();
		npc.m_flSpeed = 2000.0;

		BlockLoseSay = false;
		
		f_NpcAdjustFriction[npc.index] = 3.0;
		b_thisNpcIsARaid[npc.index] = true;

		for(int client_clear=1; client_clear<=MaxClients; client_clear++)
		{
			fl_AlreadyStrippedMusic[client_clear] = 0.0; //reset to 0
		}
		

		ApplyStatusEffect(npc.index, npc.index, "Legendary Prefix", 999999.9);

			

		func_NPCFuncWin[npc.index] = view_as<Function>(Raidmode_Expidonsa_Broly_Win);
		
		b_NoHealthbar[npc.index] = 1;
		int Decicion = TeleportDiversioToRandLocation(npc.index, true, 1500.0, 1000.0, .NeedLOSPlayer = true);
		switch(Decicion)
		{
			case 2:
			{
				Decicion = TeleportDiversioToRandLocation(npc.index, true, 1500.0, 500.0, .NeedLOSPlayer = true);
				if(Decicion == 2)
				{
					Decicion = TeleportDiversioToRandLocation(npc.index, true, 1500.0, 250.0, .NeedLOSPlayer = true);
					if(Decicion == 2)
					{
						Decicion = TeleportDiversioToRandLocation(npc.index, true, 1500.0, 0.0, .NeedLOSPlayer = true);
						if(Decicion == 2)
						{
							//damn, cant find any.... guess we'll just not care about LOS.
							Decicion = TeleportDiversioToRandLocation(npc.index, true, 1500.0, 0.0);
						}
					}
				}
			}
			case 3:
			{
				//todo code on what to do if random teleport is disabled
			}
		}

		
		return npc;
	}
}

static void Internal_ClotThink(int iNPC)
{
	Broly npc = view_as<Broly>(iNPC);
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
	if(npc.m_iState)
	{
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client))
			{
				ApplyStatusEffect(client, client, "Terrified", 2.0);
				UTIL_ScreenFade(client, 800, 0, 0x0001, 0, 0, 0, 200);
			}
		}
		RaidModeScaling *= 1.1;
	}

	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;


	if(!IsValidEntity(RaidBossActive))
	{
		RaidBossActive = EntIndexToEntRef(npc.index);
	}

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	npc.Anger = false;
	for(int i; i < i_MaxcountNpcTotal; i++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if(IsValidEntity(entity))
		{
			char npc_classname[60];
			NPC_GetPluginById(i_NpcInternalId[entity], npc_classname, sizeof(npc_classname));

			if(entity != INVALID_ENT_REFERENCE && (StrEqual(npc_classname, "npc_john_the_allmighty") && IsEntityAlive(entity)))
			{
				npc.Anger = true;
				npc.m_iTarget = entity;
			}
		}
	}

	if(!npc.Anger && !npc.m_iState)
	{
		npc.m_iState = 1;
		npc.m_iHealthBar = 99999999;

		for(int client1 = 1; client1 <= MaxClients; client1++)
		{
			if(IsClientInGame(client1))
			{
				ApplyStatusEffect(npc.index, client1, "Nightmare Terror", 35.0);
			}
		}
		
		RaidModeTime = GetGameTime() + 35.0;
		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = false;
		
		RaidModeScaling = 99999.9; //More then 9 and he raidboss gets some troubles, bufffffffff

		RemoveAllDamageAddition();
		MusicEnum music;
		strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/aprilfools/broly_theme.mp3");
		music.Time = 110;
		music.Volume = 1.5;
		music.Custom = true;
		strcopy(music.Name, sizeof(music.Name), "Dragon Ball Z: The Legendary Super Saiyan");
		strcopy(music.Artist, sizeof(music.Artist), "Pantera");
		Music_SetRaidMusic(music);
	}
	if(!BlockLoseSay && RaidModeTime < GetGameTime() && !npc.Anger)
	{
		CPrintToChatAll("{green}Broly: Insects.");
		RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
		RaidMusicSpecial1.Clear();
		BlockLoseSay = true;
		return;
	}

	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		int SetGoalVectorIndex = 0;
		SetGoalVectorIndex = BrolySelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 

		float TimeLeft = RaidModeTime - GetGameTime();
		if(TimeLeft > 10.0 && npc.m_iState)
		{
			npc.StopPathing();
			npc.m_flSpeed = 0.0;
			npc.FaceTowards(vecTarget, 15000.0);
			npc.SetActivity("ACT_MP_STAND_MELEE_ALLCLASS");
			npc.m_bisWalking = false;
		}
		else
		{
			npc.StartPathing();
			if(!npc.m_iState)
				npc.m_flSpeed = 500.0;
			else
				npc.m_flSpeed = 2000.0;
				
			npc.m_bisWalking = false;
			npc.SetActivity("ACT_MP_RUN_MELEE");
			switch(SetGoalVectorIndex)
			{
				case 0:
				{
					npc.m_bAllowBackWalking = false;
					//Get the normal prediction code.
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
				}
				case 1:
				{
					npc.m_bAllowBackWalking = true;
					float vBackoffPos[3];
					BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget,_,vBackoffPos);
					npc.SetGoalVector(vBackoffPos, true); //update more often, we need it
				}
			}
			
		}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
}

static Action Internal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Broly npc = view_as<Broly>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;

	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}		


	
	return Plugin_Changed;
}
public void Raidmode_Expidonsa_Broly_Win(int entity)
{
	i_RaidGrantExtra[entity] = RAIDITEM_INDEX_WIN_COND;
}

static void Internal_NPCDeath(int entity)
{
	Broly npc = view_as<Broly>(entity);
	/*
		Explode on death code here please

	*/
	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
	
	ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);	

	RaidBossActive = INVALID_ENT_REFERENCE;

}

int BrolySelfDefense(Broly npc, float gameTime, int target, float distance)
{
	float TimeLeft = RaidModeTime - GetGameTime();
	if(TimeLeft > 10.0 && npc.m_iState)
	{
		return 0;
	}
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < GetGameTime(npc.index))
		{
			npc.m_flAttackHappens = 0.0;
			
			if(IsValidEnemy(npc.index, target))
			{
				int HowManyEnemeisAoeMelee = 64;
				Handle swingTrace;
				float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
				npc.FaceTowards(VecEnemy, 15000.0);
				npc.DoSwingTrace(swingTrace, npc.m_iTarget,_,_,_,1,_,HowManyEnemeisAoeMelee);
				delete swingTrace;
				bool PlaySound = false;
				for (int counter = 1; counter <= HowManyEnemeisAoeMelee; counter++)
				{
					if (i_EntitiesHitAoeSwing_NpcSwing[counter] > 0)
					{
						if(IsValidEntity(i_EntitiesHitAoeSwing_NpcSwing[counter]))
						{
							PlaySound = true;
							int targetTrace = i_EntitiesHitAoeSwing_NpcSwing[counter];
							float vecHit[3];
							
							WorldSpaceCenter(targetTrace, vecHit);					
								
							
							// Hit particle
							if(!npc.m_iState)
							{
								
								char npc_classname[60];
								NPC_GetPluginById(i_NpcInternalId[targetTrace], npc_classname, sizeof(npc_classname));

								if(StrEqual(npc_classname, "npc_john_the_allmighty"))
								{
									SDKUnhook(targetTrace, SDKHook_OnTakeDamagePost, JohnTheAllmighty_OnTakeDamagePost);	
									Broly npc1 = view_as<Broly>(targetTrace);
									npc1.m_bDissapearOnDeath = false;
									RequestFrame(KillNpc, EntIndexToEntRef(targetTrace));
									CPrintToChatAll("{green}Broly: Weakling.");
									float pos[3]; GetEntPropVector(targetTrace, Prop_Data, "m_vecAbsOrigin", pos);
									pos[2] += 50.0;
									TE_Particle("Explosion_ShockWave_01", pos, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
									TE_Particle("grenade_smoke_cycle", pos, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
									TE_Particle("hammer_bell_ring_shockwave", pos, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
									CreateEarthquake(pos, 1.0, 2000.0, 16.0, 255.0);
									continue;
								}
							}
							SDKHooks_TakeDamage(targetTrace, npc.index, npc.index, GetRandomFloat(9999999.9,999999999.9), DMG_CLUB, -1, _, vecHit);			
							
						
							
							bool Knocked = false;
										
							if(IsValidClient(targetTrace))
							{
								if (IsInvuln(targetTrace))
								{
									Knocked = true;
									Custom_Knockback(npc.index, targetTrace, 900.0, true);
									if(!NpcStats_IsEnemySilenced(npc.index))
									{
										TF2_AddCondition(targetTrace, TFCond_LostFooting, 0.5);
										TF2_AddCondition(targetTrace, TFCond_AirCurrent, 0.5);
									}
								}
							}
										
							if(!Knocked)
								Custom_Knockback(npc.index, targetTrace, 250.0, true); 
						} 
					}
				}
				if(PlaySound)
				{
					npc.PlayMeleeHitSound();
				}
			}
		}
	}
	//Melee attack, last prio
	else if(GetGameTime(npc.index) > npc.m_flNextMeleeAttack)
	{
		if(IsValidEnemy(npc.index, target)) 
		{
			if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
			{
				int Enemy_I_See;
									
				Enemy_I_See = Can_I_See_Enemy(npc.index, target);
						
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					target = Enemy_I_See;

					npc.PlayMeleeSound();
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS",_,_,_,1.0);
							
					npc.m_flAttackHappens = gameTime + 0.25;
					npc.m_flNextMeleeAttack = gameTime + 0.65;
					npc.m_flDoingAnimation = gameTime + 0.25;
				}
			}
		}
		else
		{
			npc.m_flGetClosestTargetTime = 0.0;
			npc.m_iTarget = GetClosestTarget(npc.index);
		}	
	}
	return 0;
}
