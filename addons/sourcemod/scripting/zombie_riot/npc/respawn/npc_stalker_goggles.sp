#pragma semicolon 1
#pragma newdecls required


static char g_MeleeAttackSounds[][] = {
	"weapons/blade_slice_2.wav",
	"weapons/blade_slice_3.wav",
	"weapons/blade_slice_4.wav"
};

static char g_RangedAttackSounds[][] = {
	"weapons/sniper_railgun_charged_shot_01.wav",
	"weapons/sniper_railgun_charged_shot_02.wav"
};

bool AppearedBefore_Suicide;
static int NPCId;
void StalkerGoggles_OnMapStart()
{
	PrecacheModel("models/bots/sniper/bot_sniper.mdl");
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	   i++) { PrecacheSound(g_MeleeAttackSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));		i++) { PrecacheSound(g_RangedAttackSounds[i]);		}

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Machina Waldch");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_stalker_goggles");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Special;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPCId = NPC_Add(data);
}

int StalkerGoggles_ID()
{
	return NPCId;
}

void ResetWaldchLogic()
{
	AppearedBefore_Suicide = false;
}
static void ClotPrecache()
{
	PrecacheSoundCustom("#music/bluemelee.mp3");
	PrecacheSoundCustom("#music/bluerange.wav");
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return StalkerGoggles(vecPos, vecAng, team);
}


methodmap StalkerGoggles < StalkerShared
{
	property int i_GunMode
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRangedSound()
	{
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public StalkerGoggles(float vecPos[3], float vecAng[3], int ally)
	{
		ally = TFTeam_Stalkers;
		//Team 5 could just be stalkers
		StalkerGoggles npc = view_as<StalkerGoggles>(CClotBody(vecPos, vecAng, "models/bots/sniper/bot_sniper.mdl", "1.0", "6666666", ally, .IgnoreBuildings = true));
		
		i_NpcWeight[npc.index] = 5;
	//	fl_GetClosestTargetTimeTouch[npc.index] = 99999.9;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);
		
		int iActivity = npc.LookupActivity("ACT_MP_STAND_ITEM2");
		if(iActivity > 0) npc.StartActivity(iActivity);
		KillFeed_SetKillIcon(npc.index, "club");
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_ROBOT;

		float wave = float(Waves_GetRoundScale()+1);
		wave *= 0.133333;
		npc.m_flWaveScale = wave;
		npc.m_flWaveScale *= MinibossScalingReturn();
		
		
		func_NPCDeath[npc.index] = StalkerGoggles_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = StalkerGoggles_OnTakeDamage;
		func_NPCThink[npc.index] = StalkerGoggles_ClotThink;
		
		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true;
		Is_a_Medic[npc.index] = true;
		npc.m_bStaticNPC = true;
		AddNpcToAliveList(npc.index, 1);

		Zero(fl_AlreadyStrippedMusic);

		npc.m_iState = -1;
		npc.m_flSpeed = 100.0;

		npc.m_iChaseAnger = 0;
		npc.m_bChaseAnger = false;
		npc.m_iChaseVisable = 0;
		npc.m_iSurrender = 0;
		npc.m_bPlayingSniper = false;
		i_PlayMusicSound[npc.index] = 0;
		
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
			b_EntityCantBeColoured[entity] = true;
		}
		
		npc.m_iWearable1 = entity;
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/all_class/spr18_antarctic_eyewear/spr18_antarctic_eyewear_scout.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/sniper/sum19_wagga_wagga_wear/sum19_wagga_wagga_wear.mdl");
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/sniper/short2014_sniper_cargo_pants/short2014_sniper_cargo_pants.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/weapons/c_models/c_dex_sniperrifle/c_dex_sniperrifle.mdl");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);
		SetEntityRenderColor(npc.m_iWearable2, 65, 65, 255, 255);
		npc.i_GunMode = Waves_GetRoundScale();

		if(!Construction_Mode())
			TeleportDiversioToRandLocation(npc.index, .forceSpawn = Rogue_Mode());

		float flPos[3], flAng[3];
		npc.GetAttachment("head", flPos, flAng);
		npc.m_iWearable6 = ParticleEffectAt_Parent(flPos, "unusual_symbols_parent_ice", npc.index, "head", {0.0,0.0,0.0});
		
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

/*
	if(!npc.m_iSurrender && Waves_InSetup())
	{
		for(int i; i < 9; i++)
		{
			StopSound(npc.index, SNDCHAN_STATIC, "#music/bluerange.wav");
			StopSound(npc.index, SNDCHAN_STATIC, "#music/bluemelee.mp3");
		}

		i_PlayMusicSound = 0;
		npc.m_bPlayingSniper = false;
		b_NpcIsInvulnerable[npc.index] = true;
		FreezeNpcInTime(npc.index, 0.5);
		return;
	}
	*/
	if(npc.m_iSurrender)
	{
		GiveProgressDelay(0.5);
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
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	fl_TotalArmor[npc.index] = 15.0 / float(CountPlayersOnRed());
	fl_TotalArmor[npc.index] *= 0.25;
	npc.m_flNextThinkTime = gameTime + 0.1;

	b_NpcIsInvulnerable[npc.index] = false;

	if(npc.m_iTarget > 0 && !IsValidEnemy(npc.index, npc.m_iTarget, true))
	{
		npc.m_iTarget = 0;
		npc.m_flGetClosestTargetTime = 0.0;
	}

	if(npc.m_iSurrender)
	{
		bool Docutscene = true;
		for(int i; i < i_MaxcountNpcTotal; i++)
		{
			int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
			if(entity != INVALID_ENT_REFERENCE && IsValidEnemy(npc.index, entity) && GetTeam(entity) != TFTeam_Red)
			{
				Docutscene = false;
			}
		}
		if(Waves_InSetup() || Docutscene)
		{
			npc.m_flNextThinkTime = gameTime + 2.5;
			switch(npc.m_iSurrender++)
			{
				case 1:	// 0.0
				{
					CPrintToChatAll("{darkblue}월드치{default}: ...");
				}
				case 3:	// 5.0
				{
					CPrintToChatAll("{darkblue}월드치{default}: 그 놈들이 또 내 의식을 다시 만들어낼 거고, 난 또 이렇게 되고 말거야.");
				}
				case 5:	// 10.0
				{
					CPrintToChatAll("{darkblue}월드치{default}: 부탁한다. 혼돈을 막아줘.");
				}
				case 7:	// 15.0
				{
					CPrintToChatAll("{darkblue}월드치{default}: 그 놈들은.. 끔찍한 것들을 만들어내고 있어.");
				}
				case 9:	// 20.0
				{
					CPrintToChatAll("{darkblue}월드치{default}: 나처럼.");
				}
				case 10:	// 22.5
				{
					CPrintToChatAll("{darkblue}월드치{default}: 하나만 약속해줘.");
				}
				case 11:	// 25.0
				{
					CPrintToChatAll("{darkblue}월드치{default}: {gold}실베스터{default}... 걔 좀 잘 돌봐줘...");
				}
				case 12:	// 27.5
				{
					CPrintToChatAll("{darkblue}월드치{default}: {crimson}오류. 의식을 찾을수 없음.");
					npc.m_bDissapearOnDeath = true;
					RequestFrame(KillNpc, EntIndexToEntRef(npc.index));

					for (int client = 1; client <= MaxClients; client++)
					{
						if(IsValidClient(client) && GetClientTeam(client) == 2 && TeutonType[client] != TEUTON_WAITING)
						{
							Items_GiveNamedItem(client, "Chaos Machina Waldch Chip");
							CPrintToChat(client, "{default}이 기계가 천천히 스러져가며, 거기서 떨어져나온 것은...: {blue}''혼돈 마키나 월드치 칩''{default}!");
						}
					}
				}
			}
		}
		return;
	}
	//2 waves passed or its a raid.
	if(npc.i_GunMode <= (Waves_GetRoundScale() - 2) || RaidbossIgnoreBuildingsLogic(1) || LastMann || AppearedBefore_Suicide)
	{
		if(!Rogue_Mode() && !Construction_Mode() && npc.m_iSurrender == 0)
		{
			if(AppearedBefore_Suicide)
			{
				CPrintToChatAll("{darkblue}그 기계는 이 곳을 잠시 방황하고는 흔적도 사라졌습니다. 그에게 이 장소는 더 이상 흥미로운 장소가 아닙니다. 다른 누군가가 그 자리를 차지할 것입니다...");
				b_NpcForcepowerupspawn[npc.index] = 0;
			}
			i_RaidGrantExtra[npc.index] = 0;
			b_DissapearOnDeath[npc.index] = true;
			b_DoGibThisNpc[npc.index] = true;
			SmiteNpcToDeath(npc.index);
			if(AppearedBefore_Suicide)
				NPC_SpawnNext(true, true, -1); //This will force spawn a panzer.

			AppearedBefore_Suicide = true;
			return;
		}
	}

	bool sniper = view_as<bool>((npc.i_GunMode + 1) == Waves_GetRoundScale());
	if(Construction_Mode())
		sniper = (npc.i_GunMode + 1) == (Construction_GetRisk() / 2);

	static float LastKnownPos[3];
	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index, _, sniper ? FAR_FUTURE : 500.0, true, _, _, _, true, sniper ? 750.0 : 200.0);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomFloat(1.0, 2.0);
	}

	if(sniper)
	{
		npc.m_bisWalking = false;
		npc.StopPathing();
		
		if(npc.m_iChanged_WalkCycle != 7)
		{
			npc.m_iChanged_WalkCycle = 7;
			npc.SetActivity("ACT_MP_DEPLOYED_IDLE");
		}
		BlueGogglesSelfDefense(npc, gameTime);
	}
	else if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;

			if(npc.m_iTarget > 0)
			{
				Handle swingTrace;
				float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
				npc.FaceTowards(VecEnemy, 15000.0);
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, _, 1))
				{
					int target = TR_GetEntityIndex(swingTrace);	
					if(target > 0)
					{
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);

						if(Construction_Mode())
						{
							float wave = float(Waves_GetRoundScale()+1);
							wave *= 0.1;
							npc.m_flWaveScale = wave;
							npc.m_flWaveScale *= MinibossScalingReturn();
						}

						float damage = 150.0;
						damage *= npc.m_flWaveScale;

						if(ShouldNpcDealBonusDamage(npc.m_iTarget))
							damage *= 4.0;
						else
						{
							if(target > MAXPLAYERS)
								damage *= 10.0;
						}
						
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
			WorldSpaceCenter(npc.m_iTarget, LastKnownPos);
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
			else if(!sniper && distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && npc.m_flNextMeleeAttack < gameTime)
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
							PredictSubjectPosition(npc, npc.m_iTarget,_,_,LastKnownPos);
							npc.SetGoalVector(LastKnownPos);
						}
						else
						{
							npc.SetGoalEntity(npc.m_iTarget);
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
			float Targ_Vec[3]; WorldSpaceCenter(npc.m_iTarget, Targ_Vec);
			npc.FaceTowards(Targ_Vec, 1000.0);
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
		float npc_vec[3]; WorldSpaceCenter(npc.index, npc_vec);
		float distance = GetVectorDistance(LastKnownPos, npc_vec, true);
		if(npc.m_flDoingAnimation > gameTime)
		{
			state = -1;
		}
		else if(sniper || distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED)
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
				npc.m_flSpeed = npc.m_bChaseAnger ? 320.0 : 280.0;

				if(npc.m_iChanged_WalkCycle != 4)
				{
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
					// TODO: ACT_MP_RUN_MELEE is special and uses move_scale
				}

				if(!npc.m_bChaseAnger && !(GetURandomInt() % 499))
					npc.PickRandomPos(LastKnownPos);

				npc.StartPathing();
				npc.SetGoalVector(LastKnownPos);
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

	if(sniper)
	{
		if(!npc.m_bPlayingSniper)
		{
			KillFeed_SetKillIcon(npc.index, "huntsman_headshot");
			
			for(int i; i < 9; i++)
			{
				StopCustomSound(npc.index, SNDCHAN_STATIC, "#music/bluemelee.mp3");
			}

			npc.m_bPlayingSniper = true;
			i_PlayMusicSound[npc.index] = 0;

			// This does auto loop
			EmitCustomToAll("#music/bluerange.wav", npc.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, 2.0, 100);
		}
	}
	else
	{
		if(npc.m_bPlayingSniper)
		{
			KillFeed_SetKillIcon(npc.index, "club");
			
			for(int i; i < 9; i++)
			{
				StopCustomSound(npc.index, SNDCHAN_STATIC, "#music/bluerange.wav");
			}

			npc.m_bPlayingSniper = false;
		}

		int time = GetTime();
		if(i_PlayMusicSound[npc.index] < time)
		{
			// This doesn't auto loop
			EmitCustomToAll("#music/bluemelee.mp3", npc.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, 2.0, 100);

			i_PlayMusicSound[npc.index] = GetTime() + 18;
		}
	}
}

public Action StalkerGoggles_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker > 0 && attacker <= MaxClients && TeutonType[attacker] != TEUTON_NONE)
		return Plugin_Changed;
	
	if(damagetype & DMG_OUTOFBOUNDS)
	{
		damage *= 10000.0;
		return Plugin_Changed;
	}

	if(attacker < 1 || damage > 9999999.9)
		return Plugin_Continue;

	StalkerGoggles npc = view_as<StalkerGoggles>(victim);

	if(npc.m_iSurrender <= 0 && !Rogue_Mode() && !Construction_Mode() && GetEntProp(victim, Prop_Data, "m_iHealth") < 2600000 && Waves_GetRoundScale() < 39)
	{
		npc.m_bChaseAnger = false;
		npc.m_iSurrender = 1;
		npc.m_bisWalking = false;
		npc.StopPathing();

		npc.AddGesture("ACT_MP_STUN_BEGIN");
		npc.SetActivity("ACT_MP_STUN_MIDDLE");

		NPCStats_RemoveAllDebuffs(npc.index, 2.0);

		if(IsValidEntity(npc.m_iWearable1))
			RemoveEntity(npc.m_iWearable1);
		
		if(IsValidEntity(npc.m_iWearable3))
			RemoveEntity(npc.m_iWearable3);
		
		CPrintToChatAll("{darkblue}월드치{default}: 프로그래밍에 이상현상 발생중.");

		for(int i; i < 9; i++)
		{
			StopCustomSound(npc.index, SNDCHAN_STATIC, "#music/bluerange.wav");
			StopCustomSound(npc.index, SNDCHAN_STATIC, "#music/bluemelee.mp3");
		}

		damage = 0.0;
		return Plugin_Handled;
	}

	// Angry when injured
	npc.m_bChaseAnger = true;
	npc.m_iChaseAnger = 14;

	return Plugin_Changed;
}

void StalkerGoggles_NPCDeath(int entity)
{
	StalkerGoggles npc = view_as<StalkerGoggles>(entity);

	for(int i; i < 9; i++)
	{
		StopCustomSound(npc.index, SNDCHAN_STATIC, "#music/bluerange.wav");
		StopCustomSound(npc.index, SNDCHAN_STATIC, "#music/bluemelee.mp3");
	}
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);

	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);

	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
}


int BlueGogglesSelfDefense(StalkerGoggles npc, float gameTime)
{
	bool sniper = view_as<bool>((npc.i_GunMode + 1) == Waves_GetRoundScale());
	if(!npc.m_flAttackHappens)
	{
		if(IsValidEnemy(npc.index,npc.m_iTarget))
		{
			if(!Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
			{
				npc.m_iTarget = GetClosestTarget(npc.index, _, sniper ? FAR_FUTURE : 500.0, true, _, _, _, true, sniper ? 750.0 : 200.0);
			}
		}
		else
		{
			npc.m_iTarget = GetClosestTarget(npc.index, _, sniper ? FAR_FUTURE : 500.0, true, _, _, _, true, sniper ? 750.0 : 200.0);
			if(!IsValidEnemy(npc.index,npc.m_iTarget))
			{
				return 0;
			}		
		}
		if(!IsValidEnemy(npc.index,npc.m_iTarget))
		{
			return 0;
		}
	}
	float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
	npc.FaceTowards(VecEnemy, 15000.0);

	static float ThrowPos[MAXENTITIES][3];  
	float origin[3], angles[3];
	view_as<CClotBody>(npc.m_iWearable3).GetAttachment("muzzle", origin, angles);
	if(npc.m_flDoingAnimation > gameTime)
	{
		if(Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
		{
			WorldSpaceCenter(npc.m_iTarget, ThrowPos[npc.index]);
			float pos_npc[3];
			WorldSpaceCenter(npc.index, pos_npc);
			float AngleAim[3];
			GetVectorAnglesTwoPoints(pos_npc, ThrowPos[npc.index], AngleAim);
			Handle hTrace = TR_TraceRayFilterEx(pos_npc, AngleAim, MASK_SOLID, RayType_Infinite, BulletAndMeleeTrace, npc.index);
			if(TR_DidHit(hTrace))
			{
				TR_GetEndPosition(ThrowPos[npc.index], hTrace);
			}
		}
	}
	else
	{	
		if(npc.m_flAttackHappens)
		{
			float pos_npc[3];
			WorldSpaceCenter(npc.index, pos_npc);
			float AngleAim[3];
			GetVectorAnglesTwoPoints(pos_npc, ThrowPos[npc.index], AngleAim);
			Handle hTrace = TR_TraceRayFilterEx(pos_npc, AngleAim, MASK_SOLID, RayType_Infinite, BulletAndMeleeTrace, npc.index);
			if(TR_DidHit(hTrace))
			{
				TR_GetEndPosition(ThrowPos[npc.index], hTrace);
			}
			delete hTrace;
		}
	}
	if(npc.m_flAttackHappens)
	{
		TE_SetupBeamPoints(origin, ThrowPos[npc.index], Shared_BEAM_Laser, 0, 0, 0, 0.11, 5.0, 5.0, 0, 0.0, {255,0,0,255}, 3);
		TE_SendToAll(0.0);
	}
			
	npc.FaceTowards(ThrowPos[npc.index], 15000.0);
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			ShootLaser(npc.m_iWearable3, "bullet_tracer02_blue_crit", origin, ThrowPos[npc.index], false );
			float pos_npc[3];
			WorldSpaceCenter(npc.index, pos_npc);
			float AngleAim[3];
			GetVectorAnglesTwoPoints(pos_npc, ThrowPos[npc.index], AngleAim);
			Handle hTrace = TR_TraceRayFilterEx(pos_npc, AngleAim, MASK_SOLID, RayType_Infinite, BulletAndMeleeTrace, npc.index);
			int Traced_Target = TR_GetEntityIndex(hTrace);
			if(Traced_Target > 0)
			{
				WorldSpaceCenter(Traced_Target, ThrowPos[npc.index]);
			}
			else if(TR_DidHit(hTrace))
			{
				TR_GetEndPosition(ThrowPos[npc.index], hTrace);
			}
			delete hTrace;	
			int target = Can_I_See_Enemy(npc.index, npc.m_iTarget,_ ,ThrowPos[npc.index]);
			npc.PlayRangedSound();
			npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
			if(IsValidEnemy(npc.index, target))
			{
				if(Construction_Mode())
				{
					float wave = float(Waves_GetRoundScale()+1);
					wave *= 0.133333;
					npc.m_flWaveScale = wave;
					npc.m_flWaveScale *= MinibossScalingReturn();
				}

				float damageDealt = 150.0;
				damageDealt *= npc.m_flWaveScale;
				if(target > MAXPLAYERS)
					damageDealt *= 10.0;
				
				SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, ThrowPos[npc.index]);
			} 
		}
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		npc.m_flAttackHappens = gameTime + 1.25;
		npc.m_flDoingAnimation = gameTime + 0.95;
		npc.m_flNextMeleeAttack = gameTime + 2.5;
	}
	return 1;
}