#pragma semicolon 1
#pragma newdecls required
 
static const char g_DeathSounds[][] =
{
	"npc/zombie/zombie_die1.wav",
	"npc/zombie/zombie_die2.wav",
	"npc/zombie/zombie_die3.wav"
};

static const char g_IdleAlertedSounds[][] =
{
	"vo/npc/vortigaunt/giveover.wav",
	"vo/npc/vortigaunt/livetoserve.wav",
	"vo/npc/vortigaunt/opaque.wav",
	"vo/npc/vortigaunt/ourplacehere.wav",
	"vo/npc/vortigaunt/persevere.wav",
	"vo/npc/vortigaunt/prevail.wav",
	"vo/npc/vortigaunt/returntoall.wav",
	"vo/npc/vortigaunt/surge.wav",
	"vo/npc/vortigaunt/undeserving.wav",
	"vo/npc/vortigaunt/weclaimyou.wav"
};

static const char g_AngerSounds[][] =
{
	"npc/roller/mine/rmine_taunt2.wav"
};

static const char g_MeleeAttackSounds[][] =
{
	"weapons/bow_shoot.wav",
};

static int HitEnemies[16];

void UnderTides_MapStart()
{
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_AngerSounds);
}

methodmap UnderTides < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitCustomToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayDeathSound() 
	{
		EmitCustomToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);
	}
	public void PlayAngerSound()
 	{
		EmitCustomToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);
	}
	public void PlayMeleeSound()
 	{
		EmitCustomToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);
	}
	
	public UnderTides(int client, float vecPos[3], float vecAng[3], bool ally, const char[] data)
	{
		UnderTides npc = view_as<UnderTides>(CClotBody(vecPos, vecAng, "models/props_urban/urban_skybuilding005a.mdl", "1.0", "15000", ally, false));
		// 100,000 x 0.15

		i_NpcInternalId[npc.index] = UNDERTIDES;
		
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_SEABORN;
		
		SDKHook(npc.index, SDKHook_OnTakeDamage, UnderTides_TakeDamage);
		SDKHook(npc.index, SDKHook_Think, UnderTides_ClotThink);
		
		i_NpcIsABuilding[npc.index] = true;
		b_ThisNpcIsImmuneToNuke[npc.index] = true;

		npc.m_flSpeed = 1.0;
		npc.m_flMeleeArmor = 2.0;

		npc.m_flNextMeleeAttack = GetGameTime() + 5.0;
		npc.m_flNextRangedSpecialAttack = npc.m_flNextMeleeAttack + 50.0;
		npc.m_flNextRangedAttack = npc.m_flNextMeleeAttack + 30.0;

		SetEntProp(npc.index, Prop_Send, "m_bGlowEnabled", true);
		
		npc.m_iWearable1 = npc.EquipItemSeperate("partyhat", "models/props_manor/clocktower_01.mdl");
		SetVariantString("0.25");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, 50, 50, 255, 255);

		if(data[0])	// Species Outbreak
		{
			npc.m_bThisNpcIsABoss = true;

			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidModeTime = npc.m_flNextMeleeAttack + 290.0;
			RaidModeScaling = 100.0;
		}

		npc.StopPathing();
		return npc;
	}
}

public void UnderTides_ClotThink(int iNPC)
{
	UnderTides npc = view_as<UnderTides>(iNPC);

	float gameTime = GetGameTime();
	/*if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;*/

	if(npc.m_flNextMeleeAttack < gameTime)
	{
		float vecTarget[3];

		if(npc.m_flNextRangedSpecialAttack < gameTime)	// Great Tide
		{
			int enemy[16];
			GetHighDefTargets(npc, enemy, sizeof(enemy));

			for(int i; i < sizeof(enemy); i++)
			{
				if(enemy[i])
				{
					vecTarget = WorldSpaceCenter(enemy[i]);

					SDKHooks_TakeDamage(enemy[i], npc.index, npc.index, 57.0, DMG_BULLET);
					// 380 * 0.15

					SeaSlider_AddNeuralDamage(enemy[i], npc.index, 57);
					// 380 * 0.15
				}
			}

			npc.PlaySpecialSound();
			npc.m_flNextRangedSpecialAttack = gameTime + 60.0;
			npc.m_flNextMeleeAttack = gameTime + 6.0;

			npc.DispatchParticleEffect(npc.index, "hammer_bell_ring_shockwave2", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, _, _, true);
		}
		else if(npc.m_flNextRangedAttack < gameTime)	// Collapse
		{
			int enemy[8];
			GetHighDefTargets(npc, enemy, sizeof(enemy));

			for(int i; i < sizeof(enemy); i++)
			{
				if(enemy[i])
				{
					vecTarget = WorldSpaceCenter(enemy[i]);

					npc.FireArrow(vecTarget, 57.0, 1300.0);
					// 380 * 0.15

					SeaSlider_AddNeuralDamage(enemy[i], npc.index, 12);
					// 380 * 0.2 * 0.15
				}
			}

			if(vecTarget[0])
			{
				npc.PlayRangedSound();
				npc.m_flNextRangedAttack = gameTime + 25.0;
				npc.m_flNextMeleeAttack = gameTime + 6.0;
			}
			else
			{
				npc.m_flNextMeleeAttack = gameTime + 0.5;
			}
		}
		else
		{
			int enemy[2];
			GetHighDefTargets(npc, enemy, sizeof(enemy));

			for(int i; i < sizeof(enemy); i++)
			{
				if(enemy[i])
				{
					vecTarget = WorldSpaceCenter(enemy[i]);

					npc.FireArrow(vecTarget, 57.0, 1200.0);
					// 380 * 0.15

					SeaSlider_AddNeuralDamage(enemy[i], npc.index, 12);
					// 380 * 0.2 * 0.15
				}
			}

			if(vecTarget[0])
			{
				npc.PlayMeleeSound();
				npc.m_flNextMeleeAttack = gameTime + 3.5;
			}
			else
			{
				npc.m_flNextMeleeAttack = gameTime + 0.5;
			}
		}
	}
}

static void GetHighDefTargets(UnderTides npc, int[] enemy, int count)
{
	// Prio:
	// 1. Highest Defense Stat
	// 2. Highest NPC Entity Index
	// 3. Random Player

	int team = GetEntProp(npc.index, Prop_Send, "m_iTeamNum");
	int[] def = new int[count];
	float gameTime = GetGameTime();

	for(int client = 1; client <= MaxClients; client++)
	{
		if(!view_as<CClotBody>(client).m_bThisEntityIgnored && IsClientInGame(client) && GetClientTeam(client) != team && IsEntityAlive(client) && Can_I_See_Enemy_Only(npc.index, client))
		{
			for(int i; i < count; i++)
			{
				int defense = Armour_Level_Current[client];
				if(i_HealthBeforeSuit[client])
				{
					defense = i_HealthBeforeSuit[client];
				}
				else
				{
					if(Armor_Charge[client] > 0)
						defense += 10;
					
					if(f_EmpowerStateOther[client] > gameTime)
						defense++;
					
					if(f_EmpowerStateSelf[client] > gameTime)
						defense++;
					
					if(f_HussarBuff[client] > gameTime)
						defense++;
					
					if(i_CurrentEquippedPerk[client] == 2)
						defense += 2;
					
					if(Resistance_Overall_Low[client] > gameTime)
						defense += 2;
					
					if(TF2_IsPlayerInCondition(client, TFCond_DefenseBuffed))
						defense += 4;
				}

				if(enemy[i])
				{
					if(def[i] == defense)
					{
						if(GetURandomInt() % 2)
							continue;
					}
					else if(def[i] < defense)
					{
						continue;
					}
				}

				AddToList(client, i, enemy, count);
				AddToList(defense, i, def, count);
				break;
			}
		}
	}

	if(team != 3)
	{
		for(int i; i < i_MaxcountNpc; i++)
		{
			int entity = EntRefToEntIndex(i_ObjectsNpcs[i]);
			if(entity != INVALID_ENT_REFERENCE && entity != npc.index)
			{
				if(!view_as<CClotBody>(entity).m_bThisEntityIgnored && !b_NpcIsInvulnerable[entity] && !b_ThisEntityIgnoredByOtherNpcsAggro[entity] && IsEntityAlive(entity) && Can_I_See_Enemy_Only(npc.index, entity))
				{
					for(int i; i < count; i++)
					{
						int defense = b_npcspawnprotection[entity] ? 8 : 0;
						
						if(fl_RangedArmor[entity] < 1.0)
							defense += 10 - RoundToFloor(fl_RangedArmor[entity] * 10.0);

						if(Resistance_Overall_Low[entity] > gameTime)
							defense += 2;
						
						if(f_BattilonsNpcBuff[entity] > gameTime)
							defense += 4;

						if(enemy[i] && def[i] < defense)
							continue;

						AddToList(entity, i, enemy, count);
						AddToList(defense, i, def, count);
						break;
					}
				}
			}
		}
	}

	if(team != 2)
	{
		for(int i; i < i_MaxcountNpc_Allied; i++)
		{
			int entity = EntRefToEntIndex(i_ObjectsNpcs_Allied[i]);
			if(entity != INVALID_ENT_REFERENCE && entity != npc.index)
			{
				if(!view_as<CClotBody>(entity).m_bThisEntityIgnored && !b_NpcIsInvulnerable[entity] && !b_ThisEntityIgnoredByOtherNpcsAggro[entity] && IsEntityAlive(entity) && Can_I_See_Enemy_Only(npc.index, entity))
				{
					for(int i; i < count; i++)
					{
						int defense = b_npcspawnprotection[entity] ? 8 : 0;
						
						if(fl_RangedArmor[entity] < 1.0)
							defense += 10 - RoundToFloor(fl_RangedArmor[entity] * 10.0);

						if(Resistance_Overall_Low[entity] > gameTime)
							defense += 2;
						
						if(f_BattilonsNpcBuff[entity] > gameTime)
							defense += 4;
						
						if(i_NpcInternalId[entity] == CITIZEN)
						{
							Citizen cit = view_as<Citizen>(entity);
							
							if(cit.m_iGunValue > 10000)
							{
								defense += 4;
							}
							else if(cit.m_iGunValue > 7500)
							{
								defense += 3;
							}
							else if(cit.m_iGunValue > 5000)
							{
								defense += 2;
							}
							else if(cit.m_iGunValue > 2500)
							{
								defense++;
							}

							if(cit.m_iGunType == Cit_Melee)
								defense += 2;

							if(cit.m_iHasPerk == Cit_Melee)
								defense++;
						}

						if(enemy[i] && def[i] < defense)
							continue;

						AddToList(entity, i, enemy, count);
						AddToList(defense, i, def, count);
						break;
					}
				}
			}
		}
	}
}

static void AddToList(int data, int pos, int[] list, int count)
{
	for(int i = count - 1; i > pos; i--)
	{
		list[i] = list[i - 1];
	}

	list[pos] = data;
}

public Action UnderTides_Timer(Handle timer, DataPack pack)
{
	pack.Reset();
	UnderTides npc = view_as<UnderTides>(EntRefToEntIndex(pack.ReadCell()));
	if(npc.index != INVALID_ENT_REFERENCE)
	{
		float vecPos[3];
		vecPos[0] = pack.ReadFloat();
		vecPos[1] = pack.ReadFloat();
		vecPos[2] = pack.ReadFloat();

		spawnRing_Vectors(vecPos, 10.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 50, 50, 200, 1, 0.4, 6.0, 0.1, 1, 650.0);

		Zero(HitEnemies);
		TR_EnumerateEntitiesSphere(vecPos, 325.0, PARTITION_NON_STATIC_EDICTS, UnderTides_EnumerateEntitiesInRange, npc.index);

		// Hits the target with the highest armor within range

		int victim;
		int armor = -9999999;
		for(int i; i < sizeof(HitEnemies); i++)
		{
			if(!HitEnemies[i])
				break;
			
			int myArmor = 1;
			if(HitEnemies[i] <= MaxClients)
				myArmor = Armor_Charge[HitEnemies[i]];
			
			if(myArmor > armor)
			{
				victim = HitEnemies[i];
				armor = myArmor;
			}
		}

		if(victim)
		{
			SDKHooks_TakeDamage(victim, npc.index, npc.index, 90.0, DMG_BULLET);
			// 600 x 0.15
			
			SeaSlider_AddNeuralDamage(victim, npc.index, 36);
			// 600 x 0.4 x 0.15
		}
	}
	return Plugin_Stop;
}

public bool UnderTides_EnumerateEntitiesInRange(int victim, int attacker)
{
	if(IsValidEnemy(attacker, victim, true, true))
	{
		for(int i; i < sizeof(HitEnemies); i++)
		{
			if(!HitEnemies[i])
			{
				HitEnemies[i] = victim;
				return true;
			}
		}

		return false;
	}

	return true;
}

public Action UnderTides_TakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker < 1)
		return Plugin_Continue;
	
	UnderTides npc = view_as<UnderTides>(victim);
	if(b_NpcIsInvulnerable[npc.index])
		damage = 0.0;
	
	return Plugin_Changed;
}

void UnderTides_NPCDeath(int entity)
{
	UnderTides npc = view_as<UnderTides>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamage, UnderTides_TakeDamage);
	SDKUnhook(npc.index, SDKHook_Think, UnderTides_ClotThink);

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}