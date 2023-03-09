#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"npc/metropolice/die1.wav",
	"npc/metropolice/die2.wav",
	"npc/metropolice/die3.wav",
	"npc/metropolice/die4.wav",
};

static const char g_HurtSounds[][] =
{
	"npc/metropolice/pain1.wav",
	"npc/metropolice/pain2.wav",
	"npc/metropolice/pain3.wav",
	"npc/metropolice/pain4.wav",
};

static const char g_IdleSounds[][] =
{
	"npc/metropolice/vo/affirmative.wav",
	"npc/metropolice/vo/affirmative2.wav",
	"npc/metropolice/vo/canalblock.wav",
	"npc/metropolice/vo/chuckle.wav",
	"npc/metropolice/vo/citizen.wav",
	"npc/metropolice/vo/code7.wav",
	"npc/metropolice/vo/code100.wav",
	"npc/metropolice/vo/copy.wav",
	"npc/metropolice/vo/breakhiscover.wav",
	"npc/metropolice/vo/help.wav",
	"npc/metropolice/vo/hesgone148.wav",
	"npc/metropolice/vo/hesrunning.wav",
	"npc/metropolice/vo/infection.wav",
	"npc/metropolice/vo/king.wav",
	"npc/metropolice/vo/needanyhelpwiththisone.wav",

	"npc/metropolice/vo/pickupthatcan2.wav",
	"npc/metropolice/vo/sociocide.wav",
	"npc/metropolice/vo/watchit.wav",
	"npc/metropolice/vo/xray.wav",
	"npc/metropolice/vo/youknockeditover.wav",
};

static const char g_IdleAlertedSounds[][] =
{
	"npc/metropolice/vo/affirmative.wav",
	"npc/metropolice/vo/affirmative2.wav",
	"npc/metropolice/vo/canalblock.wav",
	"npc/metropolice/vo/chuckle.wav",
	"npc/metropolice/vo/citizen.wav",
	"npc/metropolice/vo/code7.wav",
	"npc/metropolice/vo/code100.wav",
	"npc/metropolice/vo/copy.wav",
	"npc/metropolice/vo/breakhiscover.wav",
	"npc/metropolice/vo/help.wav",
	"npc/metropolice/vo/hesgone148.wav",
	"npc/metropolice/vo/hesrunning.wav",
	"npc/metropolice/vo/infection.wav",
	"npc/metropolice/vo/king.wav",
	"npc/metropolice/vo/needanyhelpwiththisone.wav",
	"npc/metropolice/vo/pickupthecan1.wav",
	"npc/metropolice/vo/pickupthecan2.wav",
	"npc/metropolice/vo/pickupthecan3.wav",
	"npc/metropolice/vo/sociocide.wav",
	"npc/metropolice/vo/watchit.wav",
	"npc/metropolice/vo/xray.wav",
	"npc/metropolice/vo/youknockeditover.wav",
	"npc/metropolice/takedown.wav",
};

static const char g_MeleeHitSounds[][] =
{
	"mvm/melee_impacts/bottle_hit_robo01.wav",
	"mvm/melee_impacts/bottle_hit_robo02.wav",
	"mvm/melee_impacts/bottle_hit_robo03.wav",
};

static const char g_MeleeAttackSounds[][] =
{
	"weapons/shovel_swing.wav",
};

static const char g_MeleeMissSounds[][] =
{
	"weapons/cbar_miss1.wav",
};

static const char g_RangedAttackSounds[][] =
{
	"weapons/bow_shoot.wav",
};

static const char g_SwordHitSounds[][] =
{
	"weapons/cleaver_hit_02.wav",
	"weapons/cleaver_hit_03.wav",
	"weapons/cleaver_hit_05.wav",
	"weapons/cleaver_hit_06.wav",
	"weapons/cleaver_hit_07.wav",
};

static const char g_SwordAttackSounds[][] =
{
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav",
};

static const char g_SpawnSounds[][] = {
	"weapons/draw_sword.wav",
};

enum
{
	Command_Default = -1,
	Command_Defensive = 0,
	Command_Aggressive,
	Command_Retreat,
	Command_DefensivePlayer,
	Command_RetreatPlayer,
	Command_HoldPos,
	Command_MAX
}

static int BarrackOwner[MAXENTITIES];
static float FireRateBonus[MAXENTITIES];
static float DamageBonus[MAXENTITIES];
static int CommandOverride[MAXENTITIES];

methodmap BarrackBody < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	public void PlayIdleAlertSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound()
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlayDeathSound()
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlayMeleeMissSound()
	{
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlayRangedSound()
	{
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlaySwordSound()
	{
		EmitSoundToAll(g_SwordAttackSounds[GetRandomInt(0, sizeof(g_SwordAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlaySwordHitSound()
	{
		EmitSoundToAll(g_SwordHitSounds[GetRandomInt(0, sizeof(g_SwordHitSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlaySpawnSound()
	{
		EmitSoundToAll(g_SpawnSounds[GetRandomInt(0, sizeof(g_SpawnSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		EmitSoundToAll(g_SpawnSounds[GetRandomInt(0, sizeof(g_SpawnSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}

	property float BonusFireRate
	{
		public get()
		{
			return FireRateBonus[view_as<int>(this)];
		}
		public set(float value)
		{
			FireRateBonus[view_as<int>(this)] = value;
		}
	}
	property float BonusDamageBonus
	{
		public get()
		{
			return DamageBonus[view_as<int>(this)];
		}
		public set(float value)
		{
			DamageBonus[view_as<int>(this)] = value;
		}
	}
	property int CmdOverride
	{
		public get()
		{
			return CommandOverride[view_as<int>(this)];
		}
		public set(int value)
		{
			CommandOverride[view_as<int>(this)] = value;
		}
	}
	property int m_iTargetRally
	{
		public get()
		{
			return i_OverlordComboAttack[this.index];
		}
		public set(int value)
		{
			i_OverlordComboAttack[this.index] = value;
		}
	}
	property int OwnerUserId
	{
		public get()
		{
			return BarrackOwner[view_as<int>(this)];
		}
	}
	
	public BarrackBody(int client, float vecPos[3], float vecAng[3], const char[] health)
	{
		BarrackBody npc = view_as<BarrackBody>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "0.575", health, true, .Ally_Collideeachother = true));
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");

		BarrackOwner[npc.index] = client ? GetClientUserId(client) : 0;
		FireRateBonus[npc.index] = 1.0;
		DamageBonus[npc.index] = 1.0;
		CommandOverride[npc.index] = -1;
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE_METRO;

		npc.m_iState = 0;
		npc.m_iChanged_WalkCycle = 0;
		npc.m_flComeToMe = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_fbRangedSpecialOn = false;
		
		npc.m_flMeleeArmor = 1.0;
		npc.m_flRangedArmor = 1.0;

		SDKHook(npc.index, SDKHook_OnTakeDamage, BarrackBody_ClotDamaged);
		
		int particle = CreateEntityByName("info_particle_system");
		if(particle != -1)
		{
			float vecPos2[3];
			vecPos2 = vecPos;
			vecPos2[2] += 50.0;
			TeleportEntity(particle, vecPos2, NULL_VECTOR, NULL_VECTOR);
			DispatchKeyValue(particle, "targetname", "tf2particle");
			DispatchKeyValue(particle, "effect_name", "powerup_icon_strength_red");
			DispatchSpawn(particle);

			SetParent(npc.index, particle);

			ActivateEntity(particle);

			AcceptEntityInput(particle, "start");

			BarrackOwner[particle] = client;

			SetEdictFlags(particle, GetEdictFlags(particle) &~ FL_EDICT_ALWAYS);
			SDKHook(particle, SDKHook_SetTransmit, BarrackBody_Transmit);
			
			npc.m_iWearable6 = particle;
		}
		
		npc.StartPathing();
		return npc;
	}
}

public Action BarrackBody_Transmit(int entity, int client)
{
	if(client == BarrackOwner[entity])
		return Plugin_Continue;
	
	return Plugin_Handled;
}

bool BarrackBody_ThinkStart(int iNPC, float GameTime)
{
	BarrackBody npc = view_as<BarrackBody>(iNPC);
	if(npc.m_flNextDelayTime > GameTime)
		return false;
	
	npc.m_flNextDelayTime = GameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GameTime)
		return false;
	
	npc.m_flNextThinkTime = GameTime + 0.1;
	return true;
}

int BarrackBody_ThinkTarget(int iNPC, bool camo, float GameTime)
{
	BarrackBody npc = view_as<BarrackBody>(iNPC);

	int client = GetClientOfUserId(npc.OwnerUserId);
	bool newTarget = npc.m_flGetClosestTargetTime < GameTime;

	if(!newTarget)
		newTarget = !IsValidEnemy(npc.index, npc.m_iTarget);

	if(!newTarget)
		newTarget = !IsValidEnemy(npc.index, npc.m_iTargetRally);

	if(newTarget)
	{
		int command = Command_Aggressive;

		if(client)
		{
			command = npc.CmdOverride == Command_Default ? Building_GetFollowerCommand(client) : npc.CmdOverride;
			if(command == Command_HoldPos)
			{
				npc.m_iTargetAlly = npc.index;
			}
			else if(command == Command_DefensivePlayer || command == Command_RetreatPlayer)
			{
				npc.m_iTargetAlly = client;
			}
			else
			{
				npc.m_iTargetAlly = Building_GetFollowerEntity(client);
			}
		}
		else
		{
			npc.m_iTargetAlly = 0;
		}
		
		npc.m_iTarget = GetClosestTarget(npc.index, _, command == Command_Aggressive ? FAR_FUTURE : 900.0, camo);
		
		if(npc.m_iTargetAlly > 0)
		{
			float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTargetAlly);
			npc.m_iTargetRally = GetClosestTarget(npc.index, _, command == Command_Aggressive ? FAR_FUTURE : 900.0, camo, _, _, vecTarget, command != Command_Aggressive);
		}
		else
		{
			npc.m_iTargetRally = 0;

			int entity = MaxClients + 1;
			while((entity = FindEntityByClassname(entity, "base_boss")) != -1)
			{
				if(BarrackOwner[entity] == BarrackOwner[npc.index] && GetEntProp(entity, Prop_Send, "m_iTeamNum") == 2)
				{
					BarrackBody ally = view_as<BarrackBody>(entity);
					if(ally.m_iTargetRally > 0 && IsValidEnemy(npc.index, ally.m_iTargetRally))
					{
						npc.m_iTargetRally = ally.m_iTargetRally;
					}
				}
			}

			if(npc.m_iTargetRally < 1)
				npc.m_iTargetRally = npc.m_iTarget;
		}

		npc.m_flGetClosestTargetTime = GameTime + 1.0;
	}
	return client;
}

void BarrackBody_ThinkMove(int iNPC, float speed, const char[] idleAnim = "", const char[] moveAnim = "", float canRetreat = 0.0, bool move = true)
{
	BarrackBody npc = view_as<BarrackBody>(iNPC);

	bool pathed;
	float gameTime = GetGameTime(npc.index);
	if(move && npc.m_flReloadDelay < gameTime)
	{
		int client = GetClientOfUserId(npc.OwnerUserId);
		int command = client ? (npc.CmdOverride == Command_Default ? Building_GetFollowerCommand(client) : npc.CmdOverride) : Command_Aggressive;

		float myPos[3];
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", myPos);
		
		bool retreating = (command == Command_Retreat || command == Command_RetreatPlayer);

		if(npc.m_iTarget > 0 && canRetreat > 0.0 && command != Command_HoldPos && !retreating)
		{
			float vecTarget[3];
			GetEntPropVector(npc.m_iTarget, Prop_Data, "m_vecAbsOrigin", vecTarget);
			float flDistanceToTarget = GetVectorDistance(vecTarget, myPos, true);
			if(flDistanceToTarget < canRetreat)
			{
				vecTarget = BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget);
				PF_SetGoalVector(npc.index, vecTarget);
				
				npc.StartPathing();
				pathed = true;
			}
		}

		if(!pathed && npc.m_iTargetRally > 0 && command != Command_HoldPos && !retreating)
		{
			float vecTarget[3];
			GetEntPropVector(npc.m_iTargetRally, Prop_Data, "m_vecAbsOrigin", vecTarget);

			float flDistanceToTarget = GetVectorDistance(vecTarget, myPos, true);
			if(flDistanceToTarget < npc.GetLeadRadius())
			{
				//Predict their pos.
				vecTarget = PredictSubjectPosition(npc, npc.m_iTargetRally);
				PF_SetGoalVector(npc.index, vecTarget);

				npc.StartPathing();
				pathed = true;
			}
			else
			{
				PF_SetGoalEntity(npc.index, npc.m_iTargetRally);

				npc.StartPathing();
				pathed = true;
			}
		}
		
		if(!pathed && npc.m_iTargetAlly > 0 && command != Command_Aggressive)
		{
			if(command != Command_HoldPos)
			{
				float vecTarget[3];
				if(npc.m_iTargetAlly <= MaxClients && f3_SpawnPosition[npc.index][0] && npc.m_flComeToMe >= (gameTime + 0.6))
				{
					GetEntPropVector(npc.m_iTargetAlly, Prop_Data, "m_vecAbsOrigin", vecTarget);
					if(GetVectorDistance(myPos, vecTarget, true) > (100.0 * 100.0))
					{
						// Too far away from the mounter
						npc.m_flComeToMe = gameTime + 0.5;
					}
				}

				if(npc.m_flComeToMe < gameTime)
				{
					npc.m_flComeToMe = gameTime + 0.5;

					float originalVec[3];
					GetEntPropVector(npc.m_iTargetAlly, Prop_Data, "m_vecAbsOrigin", originalVec);
					vecTarget = originalVec;

					if(npc.m_iTargetAlly <= MaxClients)
					{
						vecTarget[0] += GetRandomFloat(-50.0, 50.0);
						vecTarget[1] += GetRandomFloat(-50.0, 50.0);
					}
					else
					{
						vecTarget[0] += GetRandomFloat(-300.0, 300.0);
						vecTarget[1] += GetRandomFloat(-300.0, 300.0);
					}
					vecTarget[2] += 50.0;
					if(PF_IsPathToVectorPossible(iNPC, vecTarget))
					{
						Handle trace = TR_TraceRayFilterEx(vecTarget, view_as<float>({90.0, 0.0, 0.0}), npc.GetSolidMask(), RayType_Infinite, BulletAndMeleeTrace, npc.index);
						TR_GetEndPosition(vecTarget, trace);
						delete trace;

						if(PF_IsPathToVectorPossible(iNPC, vecTarget))
						{
							vecTarget[2] += 18.0;
							static float hullcheckmaxs[3];
							static float hullcheckmins[3];
							
							hullcheckmaxs = view_as<float>( { 24.0, 24.0, 82.0 } );
							hullcheckmins = view_as<float>( { -24.0, -24.0, 0.0 } );	
							if(!IsSpaceOccupiedRTSBuilding(vecTarget, hullcheckmins, hullcheckmaxs, npc.index))
							{
								if(!IsPointHazard(vecTarget))
								{
									if(GetVectorDistance(originalVec, vecTarget, true) <= (npc.m_iTargetAlly <= MaxClients ? (100.0 * 100.0) : (350.0 * 350.0)) && GetVectorDistance(originalVec, vecTarget, true) > (30.0 * 30.0))
									{
										npc.m_flComeToMe = gameTime + 10.0;
										f3_SpawnPosition[npc.index] = vecTarget;
									}
								}
							}
						}
					}
				}
			}
			
			if(f3_SpawnPosition[npc.index][0])
			{
				if(GetVectorDistance(f3_SpawnPosition[npc.index], myPos, true) > (25.0 * 25.0))
				{
					PF_SetGoalVector(npc.index, f3_SpawnPosition[npc.index]);
					npc.StartPathing();
					pathed = true;
				}
			}
		}
	}
	
	if(pathed)
	{
		if(npc.m_iChanged_WalkCycle != 5)
		{
			npc.m_iChanged_WalkCycle = 5;
			npc.m_bisWalking = true;
			npc.m_flSpeed = speed;
			
			if(moveAnim[0])
				npc.SetActivity(moveAnim);
		}
	}
	else
	{
		if(npc.m_iChanged_WalkCycle != 4)
		{
			npc.m_iChanged_WalkCycle = 4;
			npc.m_bisWalking = false;
			npc.m_flSpeed = 0.0;

			if(idleAnim[0])
				npc.SetActivity(idleAnim);
			
			PF_StopPathing(npc.index);
			npc.m_bPathing = false;
		}
	}

	if(npc.m_iTarget > 0)
	{
		npc.PlayIdleAlertSound();
	}
	else
	{
		npc.PlayIdleSound();
	}
}

public Action BarrackBody_ClotDamaged(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker < 1)
		return Plugin_Continue;
	
	if(!IsValidEntity(EntRefToEntIndex(RaidBossActive)))
	{
		damage *= 0.5;
	}
	else if(damagetype & (DMG_CLUB)) //They take no knockback
	{
		if(CurrentPlayers == 1)
		{
			damage *= 0.85;
		}
		else if(CurrentPlayers <= 4)
		{
			damage *= 1.25;
		}
		else
		{
			damage *= 1.65;
		}
	}

	BarrackBody npc = view_as<BarrackBody>(victim);
	if(npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

bool BarrackBody_Interact(int client, int entity)
{
	BarrackBody npc = view_as<BarrackBody>(entity);
	if(npc.OwnerUserId && npc.OwnerUserId == GetClientUserId(client))
	{
		ShowMenu(client, entity);
		return true;
	}
	return false;
}

static void ShowMenu(int client, int entity)
{
	BarrackBody npc = view_as<BarrackBody>(entity);

	Menu menu = new Menu(BarrackBody_MenuH);
	menu.SetTitle("%t\n \n%t\n ", "TF2: Zombie Riot", NPC_Names[i_NpcInternalId[entity]]);

	char num[16];
	IntToString(EntIndexToEntRef(entity), num, sizeof(num));
	menu.AddItem(num, "Barrack Default", npc.CmdOverride == Command_Default ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	menu.AddItem(num, "Aggressive", npc.CmdOverride == Command_Aggressive ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	menu.AddItem(num, "Defend Barrack", npc.CmdOverride == Command_Defensive ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	menu.AddItem(num, "Defend Me", npc.CmdOverride == Command_DefensivePlayer ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	menu.AddItem(num, "Retreat to Barrack", npc.CmdOverride == Command_Retreat ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	menu.AddItem(num, "Retreat to Me", npc.CmdOverride == Command_RetreatPlayer ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	menu.AddItem(num, "Hold Position\n ", npc.CmdOverride == Command_HoldPos ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	menu.AddItem(num, "Sacrifice");

	menu.Pagination = 0;
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int BarrackBody_MenuH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Select:
		{
			char num[16];
			menu.GetItem(choice, num, sizeof(num));

			int entity = EntRefToEntIndex(StringToInt(num));
			if(entity != INVALID_ENT_REFERENCE)
			{
				BarrackBody npc = view_as<BarrackBody>(entity);

				switch(choice)
				{
					case 0:
					{
						npc.CmdOverride = Command_Default;
					}
					case 1:
					{
						npc.CmdOverride = Command_Aggressive;
					}
					case 2:
					{
						npc.CmdOverride = Command_Defensive;
					}
					case 3:
					{
						npc.CmdOverride = Command_DefensivePlayer;
					}
					case 4:
					{
						npc.CmdOverride = Command_Retreat;
					}
					case 5:
					{
						npc.CmdOverride = Command_RetreatPlayer;
					}
					case 6:
					{
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", f3_SpawnPosition[npc.index]);
						npc.CmdOverride = Command_HoldPos;
					}
					case 7:
					{
						SDKHooks_TakeDamage(npc.index, 0, 0, 9999999.9);
						return 0;
					}
				}

				ShowMenu(client, entity);
			}
		}
	}
	return 0;
}

void BarrackBody_NPCDeath(int entity)
{
	BarrackOwner[entity] = 0;

	BarrackBody npc = view_as<BarrackBody>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamage, BarrackBody_ClotDamaged);
	
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