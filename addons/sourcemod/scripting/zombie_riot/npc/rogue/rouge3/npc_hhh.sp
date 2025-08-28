#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/halloween_boss/knight_death01.mp3",
	"vo/halloween_boss/knight_death02.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/halloween_boss/knight_alert01.mp3",
	"vo/halloween_boss/knight_alert02.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/halloween_boss/knight_laugh01.mp3",
	"vo/halloween_boss/knight_laugh02.mp3",
	"vo/halloween_boss/knight_laugh03.mp3",
	"vo/halloween_boss/knight_laugh04.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"vo/halloween_boss/knight_attack01.mp3",
	"vo/halloween_boss/knight_attack02.mp3",
	"vo/halloween_boss/knight_attack03.mp3",
	"vo/halloween_boss/knight_attack03.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/halloween_boss/knight_axe_hit.wav",
};

static const char g_TeleSound[][] = {
	"misc/halloween/spell_teleport.wav",
};

static const char g_PreTeleSound[][] = {
	"ui/halloween_boss_chosen_it.wav",
};

static const char g_SpawnSounds[][] = {
	"ui/halloween_boss_summoned_fx.wav",
};

static const char g_GhostSounds[][] = {
	"ambient_mp3/halloween/male_scream_18.mp3",
	"ambient_mp3/halloween/male_scream_19.mp3",
	"ambient_mp3/halloween/male_scream_20.mp3",
	"ambient_mp3/halloween/male_scream_21.mp3",
	"ambient_mp3/halloween/male_scream_22.mp3",
	"ambient_mp3/halloween/male_scream_23.mp3",
};

static int i_LaserEntityIndex[MAXENTITIES]={-1, ...};

void HHH_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_TeleSound)); i++) { PrecacheSound(g_TeleSound[i]); }
	for (int i = 0; i < (sizeof(g_PreTeleSound)); i++) { PrecacheSound(g_PreTeleSound[i]); }
	for (int i = 0; i < (sizeof(g_SpawnSounds)); i++) { PrecacheSound(g_SpawnSounds[i]); }
	for (int i = 0; i < (sizeof(g_GhostSounds)); i++) { PrecacheSound(g_GhostSounds[i]); }
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Horseless Headless Horsemann");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_hhh");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Mutation;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheModel("models/bots/headless_hatman.mdl");
	PrecacheModel("models/props_halloween/ghost_no_hat.mdl");
	PrecacheSound("ui/holiday/gamestartup_halloween.mp3");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return HHH(vecPos, vecAng, team);
}
methodmap HHH < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);

	}
	public void PlayTeleSound() 
	{
		EmitSoundToAll(g_TeleSound[GetRandomInt(0, sizeof(g_TeleSound) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);

	}
	
	
	public HHH(float vecPos[3], float vecAng[3], int ally)
	{
		HHH npc = view_as<HHH>(CClotBody(vecPos, vecAng, "models/bots/headless_hatman.mdl", "1.0", "5000", ally));
		
		i_NpcWeight[npc.index] = 4;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_ITEM1");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_TANK;

		if(!IsValidEntity(RaidBossActive))
		{
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidModeTime = GetGameTime(npc.index) + 9000.0;
			RaidAllowsBuildings = true;
			RaidModeScaling = 0.0;
		}
		func_NPCDeath[npc.index] = view_as<Function>(HHH_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(HHH_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(HHH_ClotThink);

		//HHH Music (STRAIGHT-..eh, well I wouldn't say bangin but the song is good.)
		MusicEnum music;
		strcopy(music.Path, sizeof(music.Path), "#ui/holiday/gamestartup_halloween.mp3");
		music.Time = 81; //no loop usually 43 loop tho
		music.Volume = 1.25;
		music.Custom = false;
		strcopy(music.Name, sizeof(music.Name), "{redsunsecond}Haunted Fortress 2");
		strcopy(music.Artist, sizeof(music.Artist), "{redsunsecond}Mike Morasky");
		Music_SetRaidMusic(music);
		
		npc.m_flAbilityOrAttack0 = GetGameTime(npc.index) + 15.0; //Teleport Prepare
		npc.m_flAbilityOrAttack1 = GetGameTime(npc.index) + 17.0; //Teleport
		npc.m_flAbilityOrAttack2 = GetGameTime(npc.index) + 35.0; //Ghost Form
		npc.m_flAbilityOrAttack3 = GetGameTime(npc.index) + 55.0; //Normal Form

		npc.m_flAbilityOrAttack9 = GetGameTime(npc.index) + 999.0; //Animation refresh

		npc.StartPathing();
		npc.m_flSpeed = 300.0;
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
	

		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_headtaker/c_headtaker.mdl");
		SetVariantString("2.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		if(FogEntity != INVALID_ENT_REFERENCE)
		{
			int entity = EntRefToEntIndex(FogEntity);
			if(entity > MaxClients)
				RemoveEntity(entity);
			FogEntity = INVALID_ENT_REFERENCE;
		}

		//Ourple Fog
		int entity = CreateEntityByName("env_fog_controller");
		if(entity != -1)
		{
			DispatchKeyValue(entity, "fogblend", "2");
			DispatchKeyValue(entity, "fogcolor", "155 0 155 50");
			DispatchKeyValue(entity, "fogcolor2", "155 0 155 50");
			DispatchKeyValueFloat(entity, "fogstart", 400.0);
			DispatchKeyValueFloat(entity, "fogend", 1000.0);
			DispatchKeyValueFloat(entity, "fogmaxdensity", 0.90);

			DispatchKeyValue(entity, "targetname", "rpg_fortress_envfog");
			DispatchKeyValue(entity, "fogenable", "1");
			DispatchKeyValue(entity, "spawnflags", "1");
			DispatchSpawn(entity);
			AcceptEntityInput(entity, "TurnOn");

			FogEntity = EntIndexToEntRef(entity);

			for(int client1 = 1; client1 <= MaxClients; client1++)
			{
				if(IsClientInGame(client1))
				{
					SetVariantString("rpg_fortress_envfog");
					AcceptEntityInput(client1, "SetFogController");
				}
			}
		}
		
		return npc;
	}
}

public void HHH_ClotThink(int iNPC)
{
	HHH npc = view_as<HHH>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
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

	//Prepare for Teleport
	if(npc.m_flAbilityOrAttack0)
	{
		if(npc.m_flAbilityOrAttack0 < GetGameTime(npc.index))
		{
			npc.m_flAbilityOrAttack0 = GetGameTime(npc.index) + 15.0;
			EmitSoundToAll("ui/halloween_boss_chosen_it.wav", _, _, _, _, 1.0, 100);
			npc.StopPathing();
			npc.SetActivity("ACT_MP_CROUCH_ITEM1");
		}
	}

	//Teleport Everyone
	if(npc.m_flAbilityOrAttack1)
	{
		if(npc.m_flAbilityOrAttack1 < GetGameTime(npc.index))
		{
			npc.StartPathing();
			npc.SetActivity("ACT_MP_RUN_ITEM1");
			for(int entitycount; entitycount<MAXENTITIES; entitycount++) //Check for npcs
			{
				if(IsValidEnemy(npc.index, entitycount)) //Check for players
				{
					npc.m_flAbilityOrAttack0 = GetGameTime(npc.index) + 15.0;	//Has to be in both enemy and ally to properly reset the cooldowns
					npc.m_flAbilityOrAttack1 = GetGameTime(npc.index) + 17.0;
					TeleportDiversioToRandLocation(entitycount,_,1750.0, 1250.0);
					npc.PlayTeleSound();
				}
				if(IsValidAlly(npc.index, entitycount)) //Check for NPCs
				{
					npc.m_flAbilityOrAttack0 = GetGameTime(npc.index) + 15.0;
					npc.m_flAbilityOrAttack1 = GetGameTime(npc.index) + 17.0;
					TeleportDiversioToRandLocation(entitycount,_,1750.0, 1250.0);
					npc.PlayTeleSound();
				}
			}
		}
	}

	//Ghost Form
	if(npc.m_flAbilityOrAttack2)
	{
		if(npc.m_flAbilityOrAttack2 <= GetGameTime(npc.index))
		{
			b_NpcUnableToDie[npc.index] = true; //You can't kill a ghost
			SetEntityCollisionGroup(npc.index, 1); //Makes projectiles (and bullets?) go through him
			npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 999.0; //Never attacks with "axe"
			AcceptEntityInput(npc.m_iWearable1, "Disable"); //Disables Axe
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
			float VecSelfNpc[3]; WorldSpaceCenter(iNPC, VecSelfNpc);
			float VecSelfNpcabs[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", VecSelfNpcabs);
			spawnRing_Vectors(VecSelfNpcabs, 300.0 * 2.0, 0.0, 0.0, 15.0, "materials/sprites/laserbeam.vmt", 200, 0, 255, 200, 1, /*duration*/ 0.11, 5.0, 0.0, 1); //Purple ring
			SetEntityModel(npc.index, "models/props_halloween/ghost_no_hat.mdl"); //Sets model to ghost
			for(int EnemyLoop; EnemyLoop < MAXENTITIES; EnemyLoop ++)
			{
				if(IsValidEnemy(npc.index, EnemyLoop))
				{
					GetEntPropVector(EnemyLoop, Prop_Send, "m_vecOrigin", vecTarget);
					float Distance = GetVectorDistance(VecSelfNpc, vecTarget, true);
					if(Distance <= (300.0 * 300.0))
					{
						SDKHooks_TakeDamage(EnemyLoop, npc.index, npc.index, 250.0, DMG_TRUEDAMAGE, -1, _, vecTarget); //How much HHH deals with his succ
						HealEntityGlobal(npc.index, npc.index, 1000.0, 1.50, 0.0, HEAL_SELFHEAL); ///How much HHH heals
						//Apply laser if someone is near
						if(IsValidClient(EnemyLoop) && Can_I_See_Enemy_Only(npc.index, EnemyLoop) && IsEntityAlive(EnemyLoop))
						{
							int red = 200;
							int green = 0;
							int blue = 255;
							if(!IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
							{
								if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
								{
									RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
								}

								int laser;

								laser = ConnectWithBeam(npc.index, EnemyLoop, red, green, blue, 3.0, 3.0, 2.35, LASERBEAM);

								i_LaserEntityIndex[EnemyLoop] = EntIndexToEntRef(laser);
								//New target, relocate laser
							}
							else
							{
								int laser = EntRefToEntIndex(i_LaserEntityIndex[EnemyLoop]);
								SetEntityRenderColor(laser, red, green, blue, 255);
							}
						}
						else
						{
							if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
							{
								RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
							}
						}
					}
					else
					{
						if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
						{
							RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
						}
					}
				}
				else
				{
					if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
					{
						RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
					}						
				}
			}
		}
	}

	//Normal Form
	if(npc.m_flAbilityOrAttack3)
	{
		if(npc.m_flAbilityOrAttack3 <= GetGameTime(npc.index))
		{
			for(int EnemyLoop; EnemyLoop < MAXENTITIES; EnemyLoop ++) //Emergency laser removal
			{
				if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
				{
					RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
				}				
			}
			b_NpcUnableToDie[npc.index] = false; //You can kill a pumpkin though
			SetEntityCollisionGroup(npc.index, 0); //Set collision back to normal
			npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 1.0; //Restore attack cooldown to normal
			AcceptEntityInput(npc.m_iWearable1, "Enable"); //Enables Axe
			SetEntityModel(npc.index, "models/bots/headless_hatman.mdl"); //Set model back to pumpkin man
			npc.m_flAbilityOrAttack2 = GetGameTime(npc.index) + 35.0;	//Reset cooldowns - Ghost Form
			npc.m_flAbilityOrAttack3 = GetGameTime(npc.index) + 55.0;	//Reset cooldowns - Normal Form
			npc.m_flAbilityOrAttack0 = GetGameTime(npc.index) + 0.1; 	//Teleport Prepare (Animation fix after setting entity model)
			npc.m_flAbilityOrAttack1 = GetGameTime(npc.index) + 1.0; 	//Teleport (Animation fix after setting entity model)
			
		}
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
		HHHSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action HHH_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	HHH npc = view_as<HHH>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void HHH_NPCDeath(int entity)
{
	HHH npc = view_as<HHH>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}

	//Remove fog on death
	if(FogEntity != INVALID_ENT_REFERENCE)
	{
		int fogentity = EntRefToEntIndex(FogEntity);
		if(fogentity > MaxClients)
			RemoveEntity(fogentity);

		FogEntity = INVALID_ENT_REFERENCE;
	}

	//Remove laser on death
	for(int EnemyLoop; EnemyLoop < MAXENTITIES; EnemyLoop ++)
	{
		if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
		{
			RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
		}				
	}
		
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

}

void HHHSelfDefense(HHH npc, float gameTime, int target, float distance)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;

			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			//Extra Range
			static float MaxVec[3] = {256.0, 256.0, 256.0};
			static float MinVec[3] = {-256.0, -256.0, -256.0};
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, MaxVec, MinVec))
			{
				target = TR_GetEntityIndex(swingTrace);	

				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);

				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 2500.0;
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 5.0;	
					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);	
					// Hit sound
					npc.PlayMeleeHitSound();
				} 
			}
			delete swingTrace;
		}
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 2.0))
		{
			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM2");
						
				npc.m_flAttackHappens = gameTime + 0.25;
				npc.m_flDoingAnimation = gameTime + 0.25;
				npc.m_flNextMeleeAttack = gameTime + 1.0;
			}
		}
	}
}