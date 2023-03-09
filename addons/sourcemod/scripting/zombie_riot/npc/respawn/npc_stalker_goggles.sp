#pragma semicolon 1
#pragma newdecls required

static float fl_AlreadyStrippedMusic[MAXTF2PLAYERS];
static int i_PlayMusicSound;

void StalkerGoggles_OnMapStart()
{
	PrecacheModel("models/bots/sniper/bot_sniper.mdl");
	PrecacheSound("weapons/sniper_railgun_charged_shot_01.wav");
	PrecacheSound("weapons/sniper_railgun_charged_shot_02.wav");
}

methodmap StalkerGoggles < StalkerShared
{
	public void PlayMeleeHitSound()
	{
		static const char RandomSound[][] =
		{
			"weapons/blade_slice_2.wav",
			"weapons/blade_slice_3.wav",
			"weapons/blade_slice_4.wav"
		};

		EmitSoundToAll(RandomSound[GetURandomInt() % sizeof(RandomSound)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRangedSound()
	{
		static const char RandomSound[][] =
		{
			"weapons/sniper_railgun_charged_shot_01.wav",
			"weapons/sniper_railgun_charged_shot_02.wav"
		};

		EmitSoundToAll(RandomSound[GetURandomInt() % sizeof(RandomSound)], this.index, SNDCHAN_AUTO, SNDLEVEL_ROCKET, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public StalkerGoggles(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		StalkerGoggles npc = view_as<StalkerGoggles>(CClotBody(vecPos, vecAng, "models/bots/sniper/bot_sniper.mdl", "1.0", "46664666", ally));
		
		i_NpcInternalId[npc.index] = STALKER_GOGGLES;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);
		
		int iActivity = npc.LookupActivity("ACT_MP_STAND_ITEM2");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_ROBOT;
		
		SDKHook(npc.index, SDKHook_OnTakeDamage, StalkerGoggles_ClotDamaged);
		SDKHook(npc.index, SDKHook_Think, StalkerGoggles_ClotThink);
		
		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		npc.m_bStaticNPC = true;

		Zero(fl_AlreadyStrippedMusic);

		npc.m_iState = -1;
		npc.m_flSpeed = 100.0;

		npc.m_iChaseAnger = 0;
		npc.m_bChaseAnger = false;
		npc.m_iChaseVisable = 0;
		npc.m_iSurrender = 0;
		npc.m_bPlayingSniper = false;
		i_PlayMusicSound = 0;
		
		int entity = CreateEntityByName("light_dynamic");
		if(entity != -1)
		{
			vecPos[2] += 40.0;
			TeleportEntity(entity, vecPos, vecAng, NULL_VECTOR);
			
			DispatchKeyValue(entity, "brightness", "7");
			DispatchKeyValue(entity, "spotlight_radius", "180");
			DispatchKeyValue(entity, "distance", "180");
			DispatchKeyValue(entity, "_light", "255 0 0 255");
			//DispatchKeyValue(entity, "_cone", "-1");
			DispatchSpawn(entity);
			ActivateEntity(entity);
			SetVariantString("!activator");
			AcceptEntityInput(entity, "SetParent", npc.index);
			AcceptEntityInput(entity, "LightOn");
		}
		
		i_Wearable[npc.index][0] = entity;
		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/all_class/pyrovision_goggles_sniper.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/weapons/c_models/c_dex_sniperrifle/c_dex_sniperrifle.mdl");
		return npc;
	}
	property bool m_bPlayingSniper	// Since these wave files correctly loop themselves
	{
		public get()		{ return this.m_bReloaded; }
		public set(bool value) 	{ this.m_bReloaded = value; }
	}
	property int m_iSurrender	// Totally not Fusion Warrior copy
	{
		public get()		{ return i_OverlordComboAttack[this.index]; }
		public set(int value) 	{ i_OverlordComboAttack[this.index] = value; }
	}
}

public void StalkerGoggles_ClotThink(int iNPC)
{
	StalkerGoggles npc = view_as<StalkerGoggles>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	if(Waves_InSetup())
	{
		for(int i; i < 9; i++)
		{
			StopSound(npc.index, SNDCHAN_STATIC, "#bluerange.wav");
			StopSound(npc.index, SNDCHAN_STATIC, "#bluemelee.wav");
		}

		i_PlayMusicSound = 0;
		npc.m_bPlayingSniper = false;
		FreezeNpcInTime(npc.index, DEFAULT_UPDATE_DELAY_FLOAT);
		return;
	}

	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		//npc.PlayHurtSound();
	}

	static float vecMe[3], vecAng[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", vecMe); 
	GetEntPropVector(npc.index, Prop_Data, "m_angRotation", vecAng);

	// TODO: Test if needed, cause parenting
	//int light = i_Wearable[npc.index][0];
	//if(IsValidEntity(light))
	//{
	//	vecMe[2] += 40.0;
	//	TeleportEntity(light, vecMe, vecAng, NULL_VECTOR);
	//	vecMe[2] -= 40.0;
	//}
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_iTarget > 0 && !IsValidEnemy(npc.index, npc.m_iTarget, true))
	{
		npc.m_iTarget = 0;
		npc.m_flGetClosestTargetTime = 0.0;
	}

	if(npc.m_iSurrender)
	{
		if(!Waves_InSetup())
		{
			npc.m_flNextThinkTime = gameTime + 2.75;

			switch(npc.m_iSurrender++)
			{
				case 1:	// 0.0
				{
					CPrintToChatAll("{darkblue}Blue Goggles{default}: What are you waiting for...");
				}
				case 3:	// 5.5
				{
					CPrintToChatAll("{darkblue}Blue Goggles{default}: ...");
				}
				case 5:	// 11.0
				{
					CPrintToChatAll("{darkblue}Blue Goggles{default}: This is already the end for me...");
				}
				case 6:	// 13.75
				{
					CPrintToChatAll("{darkblue}Blue Goggles{default}: The world is dying...");
				}
				case 7:	// 16.5
				{
					CPrintToChatAll("{darkblue}Blue Goggles{default}: This is the far future.");
				}
				case 8:	// 19.25
				{
					CPrintToChatAll("{darkblue}Blue Goggles{default}: Just promise me one thing.");
				}
				case 10:	// 22.0
				{
					CPrintToChatAll("{darkblue}Blue Goggles{default}: Take care of {gold}Silvester{default}.");
				}
				case 11:	// 24.75
				{
					npc.m_bDissapearOnDeath = true;
					RequestFrame(KillNpc, EntIndexToEntRef(npc.index));

					TE_Particle("asplode_hoodoo", vecMe, NULL_VECTOR, NULL_VECTOR, npc.index, _, _, _, _, _, _, _, _, _, 0.0);
				}
			}
		}
		return;
	}

	bool sniper = view_as<bool>(Waves_GetRound() % 2);

	static float LastKnownPos[3];
	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index, _, sniper ? FAR_FUTURE : 500.0, true, _, _, _, true, sniper ? FAR_FUTURE : 200.0);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}

	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;

			if(npc.m_iTarget > 0)
			{
				Handle swingTrace;
				npc.FaceTowards(WorldSpaceCenter(npc.m_iTarget), 15000.0);
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, _))
				{
					int target = TR_GetEntityIndex(swingTrace);	
					if(target > 0)
					{
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);

						float damage = 250.0;

						if(ShouldNpcDealBonusDamage(npc.m_iTarget))
							damage *= 4.0;
						
						npc.PlayMeleeHitSound();
						SDKHooks_TakeDamage(npc.m_iTarget, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);
					}
				}
				delete swingTrace;
			}
		}
	}
	
	if(npc.CanSeeEnemy())
	{
		if(npc.m_iChaseAnger < 14)
		{
			npc.m_iChaseAnger += sniper ? (1 + (GetURandomInt() % 2)) : 2;
			if(!npc.m_bChaseAnger && npc.m_iChaseAnger > 13)
				npc.m_bChaseAnger = true;
		}

		if(npc.m_bChaseAnger)
		{
			LastKnownPos = WorldSpaceCenter(npc.m_iTarget);
			float distance = GetVectorDistance(LastKnownPos, vecMe, true);

			int state;
			if(npc.m_flDoingAnimation > gameTime)
			{
				state = -1;
			}
			else if(sniper && npc.m_flNextMeleeAttack < gameTime)
			{
				state = 2;
			}
			else if(!sniper && distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT * NORMAL_ENEMY_MELEE_RANGE_FLOAT) && npc.m_flNextMeleeAttack < gameTime)
			{
				state = 1;
			}

			switch(state)
			{
				case -1:
				{
					npc.StopPathing();
				}
				case 0, 1, 2:
				{
					if(sniper)
					{
						npc.m_bisWalking = false;
						npc.StopPathing();
						
						if(npc.m_iChanged_WalkCycle != 7)
						{
							npc.m_iChanged_WalkCycle = 7;
							npc.SetActivity("ACT_MP_DEPLOYED_IDLE");
						}

						if(state)
						{
							npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");

							float vecTarget[3]; vecTarget = PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, 3500.0);
							npc.FaceTowards(vecTarget, 30000.0);
							
							npc.PlayRangedSound();
							npc.FireArrow(vecTarget, 1500.0, 3500.0);
							
							npc.m_flNextMeleeAttack = gameTime + 2.2;
						}
					}
					else
					{
						npc.m_bisWalking = true;
						npc.m_flSpeed = 300.0;

						if(npc.m_iChanged_WalkCycle != 4)
						{
							npc.m_iChanged_WalkCycle = 4;
							npc.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
							// TODO: ACT_MP_RUN_MELEE is special and uses move_scale
						}

						npc.StartPathing();
						if(distance < npc.GetLeadRadius()) 
						{
							LastKnownPos = PredictSubjectPosition(npc, npc.m_iTarget);
							PF_SetGoalVector(npc.index, LastKnownPos);
						}
						else
						{
							PF_SetGoalEntity(npc.index, npc.m_iTarget);
						}

						if(state)
						{
							npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
							npc.m_flAttackHappens = gameTime + 0.35;
							npc.m_flNextMeleeAttack = gameTime + 0.6;
						}
					}
				}
			}
		}
		else
		{
			// Stare at the target, confirm their real before chasing after
			npc.FaceTowards(WorldSpaceCenter(npc.m_iTarget), 1000.0);
		}
	}
	else
	{
		if(npc.m_iChaseAnger > 0)
		{
			npc.m_iChaseAnger--;
			if(npc.m_bChaseAnger && npc.m_iChaseAnger == 0)
				npc.m_bChaseAnger = false;
		}

		int state;
		float distance = GetVectorDistance(LastKnownPos, WorldSpaceCenter(npc.index), true);
		if(npc.m_flDoingAnimation > gameTime)
		{
			state = -1;
		}
		else if(sniper || distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT * NORMAL_ENEMY_MELEE_RANGE_FLOAT))
		{
			state = 1;
		}

		switch(state)
		{
			case -1:
			{
				npc.StopPathing();
				return;
			}
			case 0:
			{
				npc.m_bisWalking = true;
				npc.m_flSpeed = npc.m_bChaseAnger ? 300.0 : 100.0;

				if(npc.m_iChanged_WalkCycle != 4)
				{
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
					// TODO: ACT_MP_RUN_MELEE is special and uses move_scale
				}

				if(!npc.m_bChaseAnger && !(GetURandomInt() % 499))
					npc.PickRandomPos(LastKnownPos);

				npc.StartPathing();
				PF_SetGoalVector(npc.index, LastKnownPos);
			}
			case 1:
			{
				npc.m_bisWalking = false;
				npc.StopPathing();

				if(sniper)
				{
					if(npc.m_iChanged_WalkCycle != 7)
					{
						npc.m_iChanged_WalkCycle = 7;
						npc.SetActivity("ACT_MP_DEPLOYED_IDLE");
					}
				}
				else if(npc.m_iChanged_WalkCycle != 6)
				{
					npc.m_iChanged_WalkCycle = 6;
					npc.SetActivity("ACT_MP_STAND_MELEE");
				}

				if(!sniper && !npc.m_bChaseAnger && !(GetURandomInt() % 49))
					npc.PickRandomPos(LastKnownPos);
			}
		}
	}

	float engineTime = GetEngineTime();

	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			GetClientAbsOrigin(client, vecAng);
			if(GetVectorDistance(vecMe, vecAng, true) < (sniper ? 3000000.0 : 2000000.0))
			{
				if(fl_AlreadyStrippedMusic[client] < engineTime)
					Music_Stop_All(client);
				
				SetMusicTimer(client, GetTime() + 5);
				fl_AlreadyStrippedMusic[client] = engineTime + 5.0;
			}
		}
	}

	if(sniper)
	{
		if(!npc.m_bPlayingSniper)
		{
			for(int i; i < 9; i++)
			{
				StopSound(npc.index, SNDCHAN_STATIC, "#bluemelee.wav");
			}

			npc.m_bPlayingSniper = true;
			i_PlayMusicSound = 0;

			// This does loop
			EmitSoundToAll("#bluerange.wav", npc.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
			EmitSoundToAll("#bluerange.wav", npc.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		}
	}
	else
	{
		if(npc.m_bPlayingSniper)
		{
			for(int i; i < 9; i++)
			{
				StopSound(npc.index, SNDCHAN_STATIC, "#bluerange.wav");
			}

			npc.m_bPlayingSniper = false;
		}

		int time = GetTime();
		if(i_PlayMusicSound < time)
		{
			// This doesn't loop
			EmitSoundToAll("#bluemelee.wav", npc.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
			EmitSoundToAll("#bluemelee.wav", npc.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);

			i_PlayMusicSound = GetTime() + 18;
		}
	}
}

public Action StalkerGoggles_ClotDamaged(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(damagetype & DMG_DROWN)
	{
		damage *= 10000.0;
		return Plugin_Changed;
	}

	if(attacker < 1 || damage > 999999.9)
		return Plugin_Continue;

	StalkerGoggles npc = view_as<StalkerGoggles>(victim);

	if(npc.m_iSurrender)
	{
		if(f_NpcImmuneToBleed[npc.index] > GetGameTime())
		{
			damage = 0.0;
		}
		else if(f_NpcImmuneToBleed[npc.index] + 1.0 > GetGameTime()) //for 3 seconds he will take next to no damage.
		{
			damage *= 0.1;
		}
		return Plugin_Changed;
	}

	if(GetEntProp(victim, Prop_Data, "m_iHealth") < 110000 && Waves_GetRound() < 59)
	{
		npc.m_bChaseAnger = false;
		npc.m_iSurrender = 1;
		npc.m_bisWalking = false;
		npc.StopPathing();

		npc.AddGesture("ACT_MP_STUN_BEGIN");
		npc.SetActivity("ACT_MP_STUN_MIDDLE");

		f_NpcImmuneToBleed[npc.index] = GetGameTime() + 2.0;

		if(IsValidEntity(npc.m_iWearable1))
			RemoveEntity(npc.m_iWearable1);
		
		if(IsValidEntity(npc.m_iWearable3))
			RemoveEntity(npc.m_iWearable3);
		
		CPrintToChatAll("{darkblue}Blue Goggles{default}: End it...");

		for(int i; i < 9; i++)
		{
			StopSound(npc.index, SNDCHAN_STATIC, "#bluerange.wav");
			StopSound(npc.index, SNDCHAN_STATIC, "#bluemelee.wav");
		}

		damage = 0.0;
		return Plugin_Handled;
	}

	// Angry when injured
	npc.m_bChaseAnger = true;
	npc.m_iChaseAnger = 14;

	if(!Waves_InSetup())
		return Plugin_Changed;
	
	damage = 0.0;
	return Plugin_Handled;
}

void StalkerGoggles_NPCDeath(int entity)
{
	StalkerGoggles npc = view_as<StalkerGoggles>(entity);
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamage, StalkerGoggles_ClotDamaged);
	SDKUnhook(npc.index, SDKHook_Think, StalkerGoggles_ClotThink);

	for(int i; i < 9; i++)
	{
		StopSound(npc.index, SNDCHAN_STATIC, "#bluerange.wav");
		StopSound(npc.index, SNDCHAN_STATIC, "#bluemelee.wav");
	}
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}