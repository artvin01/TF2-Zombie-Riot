#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[] = "mvm/giant_soldier/giant_soldier_explode.wav";
static const char g_MeleeAttackSounds[] = "player/taunt_tank_shoot.wav";
static const char g_MeleeHitSounds[][] = {
	"mvm/melee_impacts/bottle_hit_robo01.wav",
	"mvm/melee_impacts/bottle_hit_robo02.wav",
	"mvm/melee_impacts/bottle_hit_robo03.wav"
};

void VictoriaTank_MapStart()
{
	PrecacheModel("models/player/items/taunts/tank/tank.mdl");
	PrecacheSound(g_DeathSounds);
	PrecacheSound(g_MeleeAttackSounds);
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Victoria Tank");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_victorian_tank");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_tank");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Victoria;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return VictoriaTank(vecPos, vecAng, ally);
}

methodmap VictoriaTank < CClotBody
{
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds, this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds, this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	
	public VictoriaTank(float vecPos[3], float vecAng[3], int ally)
	{
		VictoriaTank npc = view_as<VictoriaTank>(CClotBody(vecPos, vecAng, "models/player/items/taunts/tank/tank.mdl", "2.5", "300000", ally, _, true));
		
		i_NpcWeight[npc.index] = 999;
		KillFeed_SetKillIcon(npc.index, "tf_projectile_rocket");
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = 0;
		npc.m_iNpcStepVariation = 0;
		npc.m_bDissapearOnDeath = true;
		
	//	SetVariantInt(1);
	//	AcceptEntityInput(npc.index, "SetBodyGroup");

		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);

		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = ClotThink;
		
		f_NpcTurnPenalty[npc.index] = 0.5;
		npc.m_flSpeed = 90.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttack = 0.0;

		npc.m_flMeleeArmor = 2.0;
		npc.m_flRangedArmor = 0.7;

		ApplyStatusEffect(npc.index, npc.index, "Clear Head", 999999.0);	
		ApplyStatusEffect(npc.index, npc.index, "Solid Stance", 999999.0);	
		ApplyStatusEffect(npc.index, npc.index, "Fluid Movement", 999999.0);	

		return npc;
	}
}

static void ClotThink(int iNPC)
{
	VictoriaTank npc = view_as<VictoriaTank>(iNPC);

	ResolvePlayerCollisions_Npc(iNPC, /*damage crush*/ 20.0);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_flNextThinkTime > gameTime)
		return;

	npc.m_flNextThinkTime = gameTime + 0.1;

	int target = npc.m_iTarget;
	if(i_Target[npc.index] != -1 && !IsValidEnemy(npc.index, target))
	{
		i_Target[npc.index] = -1;
		npc.m_flAttackHappens = 0.0;
	}
	
	if(i_Target[npc.index] == -1 || npc.m_flGetClosestTargetTime < gameTime)
	{
		target = GetClosestTarget(npc.index);
		npc.m_iTarget = target;
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}

	if(target > 0)
	{
		float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float distance = GetVectorDistance(vecTarget, VecSelfNpc, true);	
		
		if(distance < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; PredictSubjectPosition(npc, target,_,_, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(target);
		}

		npc.StartPathing();
		
		if(npc.m_flNextRangedAttack < gameTime)
		{

			float damageDeal = 600.0;
			float ProjectileSpeed = 1400.0;

			if(NpcStats_VictorianCallToArms(npc.index))
				ProjectileSpeed *= 1.25;


			npc.PlayMeleeSound();

			int entity = npc.FireRocket(vecTarget, damageDeal, ProjectileSpeed,_,_,_,45.0);
			if(entity != -1)
			{
				//max duration of 4 seconds beacuse of simply how fast they fire
				CreateTimer(4.0, Timer_RemoveEntity, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
			}
			npc.m_flNextRangedAttack = gameTime + 3.00;
		}
	}
	else
	{
		npc.StopPathing();
	}

	if(IsValidEnemy(npc.index, target))
	{
		float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius()) {
			
			float vPredictedPos[3]; PredictSubjectPosition(npc, target,_,_, vPredictedPos);
			
			npc.SetGoalVector(vPredictedPos);
		} else {
			npc.SetGoalEntity(target);
		}

		//Target close enough to hit
		if((flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && npc.m_flReloadDelay < GetGameTime(npc.index)) || npc.m_flAttackHappenswillhappen)
		{
		//	npc.FaceTowards(vecTarget, 1000.0);
			
			if(npc.m_flNextMeleeAttack < GetGameTime(npc.index) || npc.m_flAttackHappenswillhappen)
			{
				if (!npc.m_flAttackHappenswillhappen)
				{
					npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 2.0;
					npc.m_flAttackHappens = GetGameTime(npc.index)+0.4;
					npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.54;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 1.0;
					npc.m_flAttackHappenswillhappen = true;
				}
					
				if (npc.m_flAttackHappens < GetGameTime(npc.index) && npc.m_flAttackHappens_bullshit >= GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					Handle swingTrace;
					npc.FaceTowards(vecTarget, 20000.0);
					if(npc.DoSwingTrace(swingTrace, target, _, _, _, 1))
					{
						target = TR_GetEntityIndex(swingTrace);	
						
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);
						
						if(target > 0) 
						{
							if(!ShouldNpcDealBonusDamage(target))
								SDKHooks_TakeDamage(target, npc.index, npc.index, 100.0, DMG_CLUB, -1, _, vecHit);
							else
								SDKHooks_TakeDamage(target, npc.index, npc.index, 1000.0, DMG_CLUB, -1, _, vecHit);
							
							// Hit particle
							
							
							// Hit sound
							ParticleEffectAt(vecHit, "drg_cow_explosion_sparkles_blue", 1.5);
							npc.PlayMeleeHitSound();
						} 
					}
					delete swingTrace;
					npc.m_flAttackHappenswillhappen = false;
				}
				else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					npc.m_flAttackHappenswillhappen = false;
				}
			}
		}
		if (npc.m_flReloadDelay < GetGameTime(npc.index))
			npc.StartPathing();
	}
	else
	{
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
}

static void ClotDeath(int entity)
{
	VictoriaTank npc = view_as<VictoriaTank>(entity);

	float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);

	npc.PlayDeathSound();

	TE_Particle("asplode_hoodoo", vecMe, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
	int team = GetTeam(npc.index);

	int health = RoundToCeil(ReturnEntityMaxHealth(npc.index) / 7.5);
	float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
	float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
	
	for(int i; i < 3; i++)
	{
		int other = NPC_CreateByName("npc_welder", -1, pos, ang, team);
		if(other > MaxClients)
		{
			if(team != TFTeam_Red)
				Zombies_Currently_Still_Ongoing++;
			
			SetEntProp(other, Prop_Data, "m_iHealth", health);
			SetEntProp(other, Prop_Data, "m_iMaxHealth", health);
			
			fl_Extra_MeleeArmor[other] = fl_Extra_MeleeArmor[npc.index];
			fl_Extra_RangedArmor[other] = fl_Extra_RangedArmor[npc.index] * 1.43;
			fl_Extra_Speed[other] = fl_Extra_Speed[npc.index];
			fl_Extra_Damage[other] = fl_Extra_Damage[npc.index];
			b_thisNpcIsABoss[other] = b_thisNpcIsABoss[npc.index];
			b_StaticNPC[other] = b_StaticNPC[npc.index];
			if(b_StaticNPC[other])
				AddNpcToAliveList(other, 1);
		}
	}
	for(int i; i < 2; i++)
	{
		int other = NPC_CreateByName("npc_pulverizer", -1, pos, ang, team);
		if(other > MaxClients)
		{
			if(team != TFTeam_Red)
				Zombies_Currently_Still_Ongoing++;
			
			SetEntProp(other, Prop_Data, "m_iHealth", health);
			SetEntProp(other, Prop_Data, "m_iMaxHealth", health);
			
			fl_Extra_MeleeArmor[other] = fl_Extra_MeleeArmor[npc.index];
			fl_Extra_RangedArmor[other] = fl_Extra_RangedArmor[npc.index] * 1.43;
			fl_Extra_Speed[other] = fl_Extra_Speed[npc.index];
			fl_Extra_Damage[other] = fl_Extra_Damage[npc.index];
			b_thisNpcIsABoss[other] = b_thisNpcIsABoss[npc.index];
			b_StaticNPC[other] = b_StaticNPC[npc.index];
			if(b_StaticNPC[other])
				AddNpcToAliveList(other, 1);
		}
	}
}

