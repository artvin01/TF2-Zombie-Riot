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

methodmap SeaFounder < CClotBody
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
	
	public SeaFounder(int client, float vecPos[3], float vecAng[3], bool ally, const char[] data)
	{
		bool carrier = data[0] == 'R';
		bool elite = !carrier && data[0];

		SeaFounder npc = view_as<SeaFounder>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", elite ? "2700" : "2100", ally, false));
		// 7000 x 0.3
		// 9000 x 0.3

		SetVariantInt(4);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		i_NpcInternalId[npc.index] = carrier ? SEAFOUNDER_CARRIER : (elite ? SEAFOUNDER_ALT : SEAFOUNDER);
		npc.SetActivity("ACT_SEABORN_WALK_FIRST_1");
		
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_SEABORN;
		
		SDKHook(npc.index, SDKHook_OnTakeDamage, SeaFounder_TakeDamage);
		SDKHook(npc.index, SDKHook_Think, SeaFounder_ClotThink);
		
		npc.m_flSpeed = 250.0;	// 1.0 x 250
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		npc.m_flRangedArmor = 0.4;
		
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 155, 155, 255, 255);

		if(carrier)
		{
			float vecMe[3]; vecMe = WorldSpaceCenter(npc.index);
			vecMe[2] += 100.0;

			npc.m_iWearable1 = ParticleEffectAt(vecMe, "powerup_icon_resist", -1.0);
			SetParent(npc.index, npc.m_iWearable1);
		}

		npc.m_iWearable2 = npc.EquipItem("partyhat", "models/player/items/pyro/pyro_pyromancers_mask.mdl");
		SetVariantString("1.1");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
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
		float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);
		float distance = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);		
		
		if(distance < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, npc.m_iTarget);
			PF_SetGoalVector(npc.index, vPredictedPos);
		}
		else 
		{
			PF_SetGoalEntity(npc.index, npc.m_iTarget);
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
						npc.PlayMeleeHitSound();
						SDKHooks_TakeDamage(target, npc.index, npc.index, i_NpcInternalId[npc.index] == SEAFOUNDER_ALT ? 90.0 : 67.5, DMG_CLUB);
						// 450 x 0.15
						// 600 x 0.15

						SeaSlider_AddNeuralDamage(target, npc.index, i_NpcInternalId[npc.index] == SEAFOUNDER_CARRIER ? 14 : (i_NpcInternalId[npc.index] == SEAFOUNDER_ALT ? 9 : 7));
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

public Action SeaFounder_TakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
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

	if(i_NpcInternalId[npc.index] == SEAFOUNDER_CARRIER)
		Remains_SpawnDrop(pos, Buff_Founder);
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamage, SeaFounder_TakeDamage);
	SDKUnhook(npc.index, SDKHook_Think, SeaFounder_ClotThink);

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
static int SpreadTicks;

bool SeaFounder_TouchingNethersea(int entity)
{
	return NervousTouching[entity] > GetGameTime();
}

void SeaFounder_SpawnNethersea(const float pos[3])
{
	if(!NavList)
		NavList = new ArrayList();
	
	if(!DamageTimer)
		DamageTimer = CreateTimer(0.2, SeaFounder_DamageTimer, _, TIMER_REPEAT);
	
	if(!RenderTimer)
		RenderTimer = CreateTimer(4.0, SeaFounder_RenderTimer, _, TIMER_REPEAT);

	NavArea nav = TheNavMesh.GetNavArea_Vec(pos, 30.0);
	if(nav != NavArea_Null)
	{
		if(NavList.FindValue(nav) == -1)
			NavList.Push(nav);
	}
}

public Action SeaFounder_RenderTimer(Handle timer, DataPack pack)
{
	if(!NavList || Waves_InSetup())
	{
		delete NavList;
		RenderTimer = null;
		SpreadTicks = 0;
		return Plugin_Stop;
	}

	if(++SpreadTicks > 2)
	{
		SpreadTicks = 0;

		int length = NavList.Length;
		for(int a; a < length; a++)	// Spread creap to all tiles it touches
		{
			NavArea nav1 = NavList.Get(a);

			for(NavDirType b; b < NUM_DIRECTIONS; b++)
			{
				int count = nav1.GetAdjacentCount(b);
				for(int c; c < count; c++)
				{
					NavArea nav2 = nav1.GetAdjacentArea(b, c);
					if(nav2 != NavArea_Null)
						NavList.Push(nav2);
				}
			}
		}
	}

	float lines1[6], lines2[6];
	float line1[3], line2[3];

	ArrayList list = new ArrayList(6);

	int length1 = NavList.Length;
	for(int a; a < length1; a++)	// Go through infected tiles
	{
		NavArea nav = NavList.Get(a);

		for(NavCornerType b; b < NUM_CORNERS; b++)	// Go through each side of the tile
		{
			// Get the two positions for a line of the side
			nav.GetCorner(line1, b);
			nav.GetCorner(line2, b == SOUTH_WEST ? NORTH_WEST : b);

			// Sort by highest first to filter out dupe lines
			if(line1[0] > line2[0])
			{
				lines1[0] = line1[0];
				lines1[1] = line1[1];
				lines1[2] = line1[2];
				lines1[3] = line2[0];
				lines1[4] = line2[1];
				lines1[5] = line2[2];
			}
			else
			{
				lines1[0] = line2[0];
				lines1[1] = line2[1];
				lines1[2] = line2[2];
				lines1[3] = line1[0];
				lines1[4] = line1[1];
				lines1[5] = line1[2];
			}

			bool dupe;
			int length2 = list.Length;
			for(int c; c < length2; c++)	// Find dupe lines from touching tiles
			{
				list.GetArray(c, lines2);

				dupe = true;
				for(int d; d < sizeof(lines1); d++)
				{
					if(fabs(lines1[d] - lines2[d]) < 3.0)
					{
						dupe = false;
						break;
					}
				}

				if(dupe)
				{
					list.Erase(c--);
					length2--;
					break;
				}
			}

			if(!dupe)	// Add to line list
				list.PushArray(lines1);
		}
	}

	int sprite = PrecacheModel("materials/sprites/lgtning.vmt");
	length1 = list.Length;
	for(int a; a < length1; a++)
	{
		list.GetArray(a, lines1);

		line1[0] = lines1[0];
		line1[1] = lines1[0];
		line1[2] = lines1[0];
		line2[0] = lines1[0];
		line2[1] = lines1[0];
		line2[2] = lines1[0];

		TE_SetupBeamPoints(line1, line2, sprite, 0, 0, 0, 4.0, 1.0, 1.0, 1, 0.0, {255, 0, 255, 255}, 0);
		TE_SendToAll();
	}

	delete list;
	return Plugin_Continue;
}

public Action SeaFounder_DamageTimer(Handle timer, DataPack pack)
{
	if(!NavList || Waves_InSetup())
	{
		Zero(NervousTouching);
		delete NavList;
		DamageTimer = null;
		return Plugin_Stop;
	}

	NervousTouching[0] = GetGameTime() + 1.0;
	
	float pos[3];

	for(int client = 1; client <= MaxClients; client++)
	{
		if(!view_as<CClotBody>(client).m_bThisEntityIgnored && IsClientInGame(client) && GetClientTeam(client) != 3 && IsEntityAlive(client))
		{
			pos = WorldSpaceCenter(client);

			// Find entities touching infected tiles
			NavArea nav = TheNavMesh.GetNavArea_Vec(pos, 25.0);
			if(nav != NavArea_Null && NavList.FindValue(nav) != -1)
			{
				SDKHooks_TakeDamage(client, 0, 0, 6.0, DMG_BULLET);
				// 120 x 0.25 x 0.2

				SeaSlider_AddNeuralDamage(client, 0, 1);
				// 20 x 0.25 x 0.2

				NervousTouching[client] = NervousTouching[0];
			}
		}
	}
	
	for(int a; a < i_MaxcountNpc; a++)
	{
		int entity = EntRefToEntIndex(i_ObjectsNpcs[a]);
		if(entity != INVALID_ENT_REFERENCE && !view_as<CClotBody>(entity).m_bThisEntityIgnored && !b_NpcIsInvulnerable[entity] && !b_ThisEntityIgnoredByOtherNpcsAggro[entity] && IsEntityAlive(entity))
		{
			pos = WorldSpaceCenter(entity);

			// Find entities touching infected tiles
			NavArea nav = TheNavMesh.GetNavArea_Vec(pos, 25.0);
			if(nav != NavArea_Null && NavList.FindValue(nav) != -1)
				NervousTouching[entity] = NervousTouching[0];
		}
	}
	
	for(int a; a < i_MaxcountNpc_Allied; a++)
	{
		int entity = EntRefToEntIndex(i_ObjectsNpcs_Allied[a]);
		if(entity != INVALID_ENT_REFERENCE && !view_as<CClotBody>(entity).m_bThisEntityIgnored && !b_NpcIsInvulnerable[entity] && !b_ThisEntityIgnoredByOtherNpcsAggro[entity] && IsEntityAlive(entity))
		{
			pos = WorldSpaceCenter(entity);

			// Find entities touching infected tiles
			NavArea nav = TheNavMesh.GetNavArea_Vec(pos, 25.0);
			if(nav != NavArea_Null && NavList.FindValue(nav) != -1)
			{
				SDKHooks_TakeDamage(entity, 0, 0, 6.0, DMG_BULLET);
				// 120 x 0.25 x 0.2

				SeaSlider_AddNeuralDamage(entity, 0, 1);
				// 20 x 0.25 x 0.2

				NervousTouching[entity] = NervousTouching[0];
			}
		}
	}
	return Plugin_Continue;
}
