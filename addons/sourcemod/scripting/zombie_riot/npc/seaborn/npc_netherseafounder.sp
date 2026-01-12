#pragma semicolon 1
#pragma newdecls required
 
static const char g_DeathSounds[][] =
{
	"vo/npc/male01/no01.wav",
	"vo/npc/male01/no02.wav",
};

static const char g_HurtSounds[][] =
{
	"vo/npc/male01/pain01.wav",
	"vo/npc/male01/pain02.wav",
	"vo/npc/male01/pain03.wav",
	"vo/npc/male01/pain05.wav",
	"vo/npc/male01/pain06.wav",
	"vo/npc/male01/pain07.wav",
	"vo/npc/male01/pain08.wav",
	"vo/npc/male01/pain09.wav",
};

static const char g_IdleAlertedSounds[][] =
{
	"vo/npc/male01/ohno.wav",
	"vo/npc/male01/overthere01.wav",
	"vo/npc/male01/overthere02.wav",
};

static const char g_MeleeHitSounds[][] =
{
	"npc/fast_zombie/claw_strike1.wav",
	"npc/fast_zombie/claw_strike2.wav",
	"npc/fast_zombie/claw_strike3.wav"
};

void SeaFounder_Precache()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Nethersea Founder");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_netherseafounder");
	strcopy(data.Icon, sizeof(data.Icon), "ds_founder");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Seaborn;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return SeaFounder(vecPos, vecAng, team, data);
}

methodmap SeaFounder < CSeaBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);	
	}
	
	public SeaFounder(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		bool carrier = data[0] == 'R';
		bool elite = !carrier && data[0];

		SeaFounder npc = view_as<SeaFounder>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", elite ? "2700" : "2100", ally, false));
		// 7000 x 0.3
		// 9000 x 0.3

		SetVariantInt(4);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.SetElite(elite, carrier);
		i_NpcWeight[npc.index] = 2;
		npc.SetActivity("ACT_SEABORN_WALK_TOOL_2");
		KillFeed_SetKillIcon(npc.index, "fists");
		
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_SEABORN;
		
		func_NPCDeath[npc.index] = SeaFounder_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = SeaFounder_OnTakeDamage;
		func_NPCThink[npc.index] = SeaFounder_ClotThink;
		
		npc.m_flSpeed = 250.0;	// 1.0 x 250
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		npc.m_flRangedArmor = 0.4;
		
		SetEntityRenderColor(npc.index, 155, 155, 255, 255);

		if(carrier)
		{
			float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
			vecMe[2] += 100.0;

			npc.m_iWearable1 = ParticleEffectAt(vecMe, "powerup_icon_resist", -1.0);
			SetParent(npc.index, npc.m_iWearable1);
		}

		npc.m_iWearable2 = npc.EquipItem("partyhat", "models/player/items/pyro/pyro_pyromancers_mask.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		SetEntityRenderColor(npc.m_iWearable2, 200, elite ? 0 : 255, elite ? 0 : 155, 255);

		npc.m_iWearable3 = npc.EquipItem("weapon_targe", "models/workshop/weapons/c_models/c_persian_shield/c_persian_shield_all.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		return npc;
	}
}

public void SeaFounder_ClotThink(int iNPC)
{
	SeaFounder npc = view_as<SeaFounder>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}
	
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
						float attack = npc.m_bElite ? 90.0 : 67.5;
						// 450 x 0.15
						// 600 x 0.15
						
						if(ShouldNpcDealBonusDamage(target))
							attack *= 2.5;

						npc.PlayMeleeHitSound();
						SDKHooks_TakeDamage(target, npc.index, npc.index, attack, DMG_CLUB);

						Elemental_AddNervousDamage(target, npc.index, RoundToCeil(attack * (npc.m_bCarrier ? 0.2 : 0.1)));
						// 450 x 0.1 x 0.15
						// 600 x 0.1 x 0.15
						// 450 x 0.2 x 0.15
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
				npc.m_flNextMeleeAttack = gameTime + 1.5;

				npc.AddGesture("ACT_SEABORN_FIRST_ATTACK_1");	// TODO: Set anim
				npc.m_flAttackHappens = gameTime + 0.45;
				//npc.m_flDoingAnimation = gameTime + 1.2;
				npc.m_flHeadshotCooldown = gameTime + 1.0;
			}
		}
	}
	else
	{
		npc.StopPathing();
	}

	npc.PlayIdleSound();
}

public Action SeaFounder_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker < 1)
		return Plugin_Continue;
	
	SeaFounder npc = view_as<SeaFounder>(victim);
	if(npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

void SeaFounder_NPCDeath(int entity)
{
	SeaFounder npc = view_as<SeaFounder>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	
	float pos[3];
	GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", pos);

	if(!NpcStats_IsEnemySilenced(npc.index))
		SeaFounder_SpawnNethersea(pos);

	if(npc.m_bCarrier)
		Remains_SpawnDrop(pos, Buff_Founder);
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);

	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}

static ArrayList NavList;
static Handle RenderTimer;
static Handle DamageTimer;
static float NervousTouching[MAXENTITIES + 1];
static CNavArea NervousLastTouch[MAXENTITIES + 1];
static int SpreadTicks;

bool SeaFounder_TouchingNethersea(int entity)
{
	return NervousTouching[entity] > GetGameTime();
}

void SeaFounder_ClearnNethersea()
{
	delete NavList;
}

void SeaFounder_SpawnNethersea(const float pos[3])
{
	if(!NavList)
		NavList = new ArrayList();
	
	if(!DamageTimer)
		DamageTimer = CreateTimer(0.2, SeaFounder_DamageTimer, _, TIMER_REPEAT);
	
	if(!RenderTimer)
		RenderTimer = CreateTimer(4.0, SeaFounder_RenderTimer, _, TIMER_REPEAT);

	CNavArea nav = TheNavMesh.GetNavArea(pos, 30.0);
	if(nav != NULL_AREA)
	{
		if(NavList.FindValue(nav) == -1)
		{
			if(!nav.HasAttributes(NAV_MESH_NO_HOSTAGES))
			{
				NavList.Push(nav);
				TriggerTimer(RenderTimer, true);
			}
		}
	}
}

static bool Similar(float val1, float val2)
{
	return fabs(val1 - val2) < 2.0;
}

static bool SimilarMore(float val1, float val2)
{
	return (val1 > val2) && !Similar(val1, val2);
}

static bool SimilarLess(float val1, float val2)
{
	return (val1 < val2) && !Similar(val1, val2);
}

static bool Overlapping(const float[] pos1, const float[] pos2, int index1, int index2)
{
	return !((SimilarMore(pos1[index1], pos2[index1]) && SimilarMore(pos1[index2], pos2[index2]) && SimilarMore(pos1[index1], pos2[index2]) && SimilarMore(pos1[index2], pos2[index1])) ||
			(SimilarLess(pos1[index1], pos2[index1]) && SimilarLess(pos1[index2], pos2[index2]) && SimilarLess(pos1[index1], pos2[index2]) && SimilarLess(pos1[index2], pos2[index1])));
}

public Action SeaFounder_RenderTimer(Handle timer, DataPack pack)
{
	if(!NavList || (Waves_InSetup() && !CvarNoRoundStart.BoolValue))
	{
		delete NavList;
		RenderTimer = null;
		SpreadTicks = 0;
		return Plugin_Stop;
	}

	if(++SpreadTicks > (CurrentRound >= 39 ? 24 : 8))
	{
		SpreadTicks = (GetURandomInt() % 3) - 1;

		ArrayList list = new ArrayList();

		float gameTime = GetGameTime();
		for(int entity = 1; entity < sizeof(NervousTouching); entity++)	// Prevent spreading if an entity is on it currently
		{
			if(NervousTouching[entity] > gameTime)
			{
				list.Push(NervousLastTouch[entity]);
			}
		}

		//If Only allow 25 navs to spread at once
		int AllowMaxSpread = 0;
		int length = NavList.Length;
		for(int a; a < length; a++)	// Spread creap to all tiles it touches
		{
			CNavArea nav1 = NavList.Get(a);

			if(list.FindValue(nav1) == -1)
			{
				for(NavDirType b; b < NUM_DIRECTIONS; b++)
				{
					int count = nav1.GetAdjacentCount(b);
					for(int c; c < count; c++)
					{
						if(AllowMaxSpread >= 25)
						{
							break;
						}
						CNavArea nav2 = nav1.GetAdjacentArea(b, c);
						if(nav2 != NULL_AREA && !nav2.HasAttributes(NAV_MESH_NO_HOSTAGES) && NavList.FindValue(nav2) == -1)
						{
							AllowMaxSpread++;
							NavList.Push(nav2);
						}
					}
				}
			}
		}

		delete list;
	}

	float lines1[6];//, lines2[6];
	//float line1[3], line2[3];

	ArrayList list = new ArrayList(sizeof(lines1));

	int length1 = NavList.Length;
	float corner[NUM_CORNERS][3];
	for(int a; a < length1; a++)	// Go through infected tiles
	{
		CNavArea nav = NavList.Get(a);

		for(NavCornerType b = NORTH_WEST; b < NUM_CORNERS; b++)	// Go through each side of the tile
		{
			nav.GetCorner(b, corner[b]);
		}

		for(NavCornerType b = NORTH_WEST; b < NUM_CORNERS; b++)
		{
			// Get the two positions for a line of the side
			NavCornerType c = (b + view_as<NavCornerType>(1));
			if(c == NUM_CORNERS)
				c = NORTH_WEST;

			// Sort by highest first to filter out dupe lines
			if(corner[b][0] > corner[c][0])
			{
				lines1[0] = corner[b][0];
				lines1[1] = corner[b][1];
				lines1[2] = corner[b][2];
				lines1[3] = corner[c][0];
				lines1[4] = corner[c][1];
				lines1[5] = corner[c][2];
			}
			else
			{
				lines1[0] = corner[c][0];
				lines1[1] = corner[c][1];
				lines1[2] = corner[c][2];
				lines1[3] = corner[b][0];
				lines1[4] = corner[b][1];
				lines1[5] = corner[b][2];
			}

			AddLineToListTest(0, list, lines1);
		}
	}

	length1 = list.Length;
	for(int a; a < length1; a++)
	{
		list.GetArray(a, lines1);

		//if(!lines1[6])
		{
			/*line1[0] = lines1[0];
			line1[1] = lines1[1];
			line1[2] = lines1[2] + 3.0;
			line2[0] = lines1[3];
			line2[1] = lines1[4];
			line2[2] = lines1[5] + 3.0;*/

			DataPack pack2 = new DataPack();
			RequestFrames(SeaFounder_RenderFrame, 2 + (a / 16), pack2);
			pack2.WriteFloat(lines1[0]);
			pack2.WriteFloat(lines1[1]);
			pack2.WriteFloat(lines1[2] + 8.0);
			pack2.WriteFloat(lines1[3]);
			pack2.WriteFloat(lines1[4]);
			pack2.WriteFloat(lines1[5] + 8.0);
		}
	}

	delete list;
	return Plugin_Continue;
}

static void AddLineToListTest(int start, ArrayList list, const float lines1[6])
{
	float sort[4][2], lines2[6];

	int length2 = list.Length;
	for(int d = start; d < length2; d++)	// Find dupe lines from touching tiles
	{
		list.GetArray(d, lines2);

		if(Similar(lines1[0], lines1[3]) && Similar(lines1[0], lines2[0]) && Similar(lines1[3], lines2[3]) &&	// Same x-axis
			Overlapping(lines1, lines2, 1, 4))	// Overlapping y-axis
		{
			sort[0][0] = lines1[1];
			sort[0][1] = lines1[2];
			sort[1][0] = lines2[1];
			sort[1][1] = lines2[2];
			sort[2][0] = lines1[4];
			sort[2][1] = lines1[5];
			sort[3][0] = lines2[4];
			sort[3][1] = lines2[5];

			SortCustom2D(sort, sizeof(sort), SeaFounder_Sorting);

			list.Erase(d);

			for(int e; e < 3; e += 2)	// Compare 1st and 2nd, 3rd and 4th
			{
				if(!Similar(sort[e][0], sort[e + 1][0]))
				{
					lines2[1] = sort[e][0];
					lines2[2] = sort[e][1];
					lines2[4] = sort[e + 1][0];
					lines2[5] = sort[e + 1][1];

					AddLineToListTest(d + 1, list, lines2);
				}
			}

			return;
		}
		
		if(Similar(lines1[1], lines1[4]) && Similar(lines1[1], lines2[1]) && Similar(lines1[4], lines2[4]) &&	// Same y-axis
			Overlapping(lines1, lines2, 0, 3))	// Overlapping x-axis
		{
			sort[0][0] = lines1[0];
			sort[0][1] = lines1[2];
			sort[1][0] = lines2[0];
			sort[1][1] = lines2[2];
			sort[2][0] = lines1[3];
			sort[2][1] = lines1[5];
			sort[3][0] = lines2[3];
			sort[3][1] = lines2[5];

			SortCustom2D(sort, sizeof(sort), SeaFounder_Sorting);

			list.Erase(d);

			for(int e; e < 3; e += 2)
			{
				if(!Similar(sort[e][0], sort[e + 1][0]))
				{
					lines2[0] = sort[e][0];
					lines2[2] = sort[e][1];
					lines2[3] = sort[e + 1][0];
					lines2[5] = sort[e + 1][1];

					AddLineToListTest(d + 1, list, lines2);
				}
			}

			return;
		}
	}

	list.PushArray(lines1);	// Add to line list
}

public int SeaFounder_Sorting(int[] elem1, int[] elem2, const int[][] array, Handle hndl)
{
	float value1 = view_as<float>(elem1[0]);
	float value2 = view_as<float>(elem2[0]);

	if(value1 > value2)
		return -1;
	
	if(value1 < value2)
		return 1;
	
	return 0;
}

public void SeaFounder_RenderFrame(DataPack pack)
{
	pack.Reset();
	float pos1[3], pos2[3];
	pos1[0] = pack.ReadFloat();
	pos1[1] = pack.ReadFloat();
	pos1[2] = pack.ReadFloat();
	pos2[0] = pack.ReadFloat();
	pos2[1] = pack.ReadFloat();
	pos2[2] = pack.ReadFloat();

	delete pack;

	TE_SetupBeamPoints(pos1, pos2, Silvester_BEAM_Laser_1, Silvester_BEAM_Laser_1, 0, 0, 4.0, 5.0/*Width*/, 5.0/*end Width*/, 0, 0.0, {35, 35, 255, 125}, 0);
	TE_SendToAll();
}

public Action SeaFounder_DamageTimer(Handle timer, DataPack pack)
{
	if(!NavList || (Waves_InSetup() && !CvarNoRoundStart.BoolValue))
	{
		Zero(NervousTouching);
		delete NavList;
		DamageTimer = null;
		return Plugin_Stop;
	}

	NervousTouching[0] = GetGameTime() + 0.5;
	
	float pos[3];

	for(int client = 1; client <= MaxClients; client++)
	{
		if(!view_as<CClotBody>(client).m_bThisEntityIgnored && IsClientInGame(client) && GetClientTeam(client) != 3 && IsEntityAlive(client))
		{
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);

			// Find entities touching infected tiles
			NervousLastTouch[client] = TheNavMesh.GetNavArea(pos, 70.0);
			if(NervousLastTouch[client] != NULL_AREA && NavList.FindValue(NervousLastTouch[client]) != -1)
			{
				bool resist = false;
				if(HasSpecificBuff(client, "Nethersea Antidote"))
					resist = true;
					
				bool ignore = false;
				bool Benifit = (SeaMelee_IsSeaborn(client));
				int Active_weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
				if(Active_weapon > 1)
				{
					switch(i_CustomWeaponEquipLogic[Active_weapon])
					{
						case WEAPON_SEABORNMELEE, WEAPON_SEABORN_MISC, WEAPON_OCEAN, WEAPON_OCEAN_PAP:
						{
							Benifit = true;
						}
						case WEAPON_SPECTER, WEAPON_GLADIIA, WEAPON_ULPIANUS, WEAPON_SKADI:
						{
							ignore = true;
						}
					}
				}
				if(ignore)
				{
					int entity = EntRefToEntIndex(i_DyingParticleIndication[client][0]);
					if(IsValidEntity(entity))
					{
						RemoveEntity(entity);
					}
					continue;
				}

				//when fighing bob, you are technically a sea creature...
				if(!StrContains(WhatDifficultySetting, "You."))
					Benifit = true;
				
				if(Benifit)
				{
					ApplyStatusEffect(client, client, "Sea Strength", 1.0);
				}
				else
				{
					ApplyStatusEffect(client, client, "Sea Presence", 1.0);
					float MaxHealth = float(SDKCall_GetMaxHealth(client));

					float damageDeal;
					
					damageDeal = MaxHealth * 0.0025;

					if(resist)
						damageDeal *= 0.2;
					
					damageDeal *= Attributes_GetOnPlayer(client, Attrib_TerrianRes);

					if(damageDeal < 2.0) //whatever is higher.
					{
						damageDeal = 2.0;
					}

					SDKHooks_TakeDamage(client, 0, 0, damageDeal, DMG_BULLET|DMG_PREVENT_PHYSICS_FORCE, _, _, pos);
					// 120 x 0.25 x 0.2

					if(!resist)
						Elemental_AddNervousDamage(client, 0, RoundToCeil(damageDeal / 6.0), false);
						// 20 x 0.25 x 0.2
				}
				int entity = EntRefToEntIndex(i_DyingParticleIndication[client][0]);
				if(!IsValidEntity(entity))
				{
					float flPos[3];
					GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);		
					int particle_Sing = ParticleEffectAt(flPos, "utaunt_hands_teamcolor_blue", -1.0);
					SetParent(client, particle_Sing);
					i_DyingParticleIndication[client][0] = EntIndexToEntRef(particle_Sing);
				}
				NervousTouching[client] = NervousTouching[0];
			}
			else
			{
				int entity = EntRefToEntIndex(i_DyingParticleIndication[client][0]);
				if(IsValidEntity(entity))
				{
					RemoveEntity(entity);
				}
			}
		}
	}
	
	for(int a; a < i_MaxcountNpcTotal; a++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[a]);
		if(entity != INVALID_ENT_REFERENCE && !view_as<CClotBody>(entity).m_bThisEntityIgnored && !b_NpcIsInvulnerable[entity] && !b_ThisEntityIgnoredByOtherNpcsAggro[entity] && IsEntityAlive(entity))
		{
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);

			// Find entities touching infected tiles
			if(view_as<CClotBody>(entity).m_iBleedType == BLEEDTYPE_SEABORN)
			{
				CNavArea nav = TheNavMesh.GetNavArea(pos, 5.0);
				if(nav != NULL_AREA && NavList.FindValue(nav) != -1)
				{
					NervousTouching[entity] = NervousTouching[0];
					NervousLastTouch[entity] = NULL_AREA;
					ApplyStatusEffect(entity, entity, "Sea Presence", 1.0);
				}
			}
			else
			{
				NervousLastTouch[entity] = TheNavMesh.GetNavArea(pos, 5.0);
				if(NervousLastTouch[entity] != NULL_AREA && NavList.FindValue(NervousLastTouch[entity]) != -1)
				{
					/*
					SDKHooks_TakeDamage(entity, 0, 0, 6.0, DMG_BULLET|DMG_PREVENT_PHYSICS_FORCE, _, _, pos);
					// 120 x 0.25 x 0.2

					Elemental_AddNervousDamage(entity, 0, 1, false);
					// 20 x 0.25 x 0.2
					*/
					ApplyStatusEffect(entity, entity, "Sea Presence", 1.0);
					ApplyStatusEffect(entity, entity, "Teslar Shock", 1.0);

					NervousTouching[entity] = NervousTouching[0];
				}
			}
		}
	}

	for(int a; a < i_MaxcountBuilding; a++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsBuilding[a]);
		if(entity != INVALID_ENT_REFERENCE)
		{
			if(!b_ThisEntityIgnored[entity] && !b_ThisEntityIgnoredByOtherNpcsAggro[entity])
			{
				GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);

				// Find entities touching infected tiles
				NervousLastTouch[entity] = TheNavMesh.GetNavArea(pos, 5.0);
				if(NervousLastTouch[entity] != NULL_AREA && NavList.FindValue(NervousLastTouch[entity]) != -1)
				{
					SDKHooks_TakeDamage(entity, 0, 0, 6.0, DMG_BULLET, _, _, pos);
					// 120 x 0.25 x 0.2

					Elemental_AddNervousDamage(entity, 0, 1, false);
					// 20 x 0.25 x 0.2

					NervousTouching[entity] = NervousTouching[0];

					int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
					if(owner > 0 && owner <= MaxClients)
					{
						if(Attributes_GetOnPlayer(owner, Attrib_ObjTerrianAbsorb, false) > (GetURandomInt() % 100))
						{
							int id = NavList.FindValue(NervousLastTouch[entity]);
							if(id != -1)
								NavList.Erase(id);
						}
					}
				}
			}
		}
	}
	return Plugin_Continue;
}
