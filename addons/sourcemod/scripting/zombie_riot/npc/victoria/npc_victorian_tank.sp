#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[] = "mvm/giant_soldier/giant_soldier_explode.wav";
static const char g_MeleeAttackSounds[] = "player/taunt_tank_shoot.wav";

void VictoriaTank_MapStart()
{
	PrecacheModel("models/player/items/taunts/tank/tank.mdl");
	PrecacheSound(g_DeathSounds);
	PrecacheSound(g_MeleeAttackSounds);
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Tank");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_victorian_tank");
	strcopy(data.Icon, sizeof(data.Icon), "soldier_major_crits");
	data.IconCustom = false;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Victoria;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return VictoriaTank(client, vecPos, vecAng, ally, data);
}

methodmap VictoriaTank < CClotBody
{
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds, this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds, this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public VictoriaTank(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		VictoriaTank npc = view_as<VictoriaTank>(CClotBody(vecPos, vecAng, "models/player/items/taunts/tank/tank.mdl", "2.5", "20000", ally, _, true));
		
		i_NpcWeight[npc.index] = 999;
		KillFeed_SetKillIcon(npc.index, "tf_projectile_rocket");
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = 0;
		npc.m_iNpcStepVariation = 0;

		npc.g_TimesSummoned = 0;

		if(data[0])
			npc.g_TimesSummoned = StringToInt(data);
		
	//	SetVariantInt(1);
	//	AcceptEntityInput(npc.index, "SetBodyGroup");

		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);

		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = ClotThink;
		
		npc.m_flSpeed = 100.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_iOverlordComboAttack = 0;
		npc.m_flAttackHappens = 0.0;

		npc.m_flMeleeArmor = 1.0;
		npc.m_flRangedArmor = 0.7;

		b_CannotBeStunned[npc.index] = true;
		b_CannotBeKnockedUp[npc.index] = true;
		b_CannotBeSlowed[npc.index] = true;

		return npc;
	}
}

static void ClotThink(int iNPC)
{
	VictoriaTank npc = view_as<VictoriaTank>(iNPC);

    ResolvePlayerCollisions_Npc(iNPC, /*damage crush*/ 10.0);

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
			NPC_SetGoalVector(npc.index, vPredictedPos);
		}
		else 
		{
			NPC_SetGoalEntity(npc.index, target);
		}

		npc.StartPathing();
		
		if(npc.m_flAttackHappens)
		{
			if(npc.m_flAttackHappens < gameTime)
			{

				float damageDeal = 600.0;
				float ProjectileSpeed = 1200.0;

				npc.PlayMeleeSound();

				int entity = npc.FireRocket(vecTarget, damageDeal, ProjectileSpeed,_,_,_,45.0);
				if(entity != -1)
				{
					//max duration of 4 seconds beacuse of simply how fast they fire
					CreateTimer(4.0, Timer_RemoveEntity, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
				}

				npc.m_iOverlordComboAttack--;

				if(npc.m_iOverlordComboAttack < 1)
				{
					npc.m_flAttackHappens = 0.0;
				}
				else
				{
					npc.m_flAttackHappens = gameTime + 0.15;
				}
			}
		}
		else if(npc.m_flNextMeleeAttack < gameTime)
		{
			npc.m_iOverlordComboAttack += 1;
			npc.m_flNextMeleeAttack = gameTime + 0.45;
			//npc.AddGesture("ACT_MP_RELOAD_STAND_PRIMARY");

			if(npc.m_iOverlordComboAttack > 1)
			{
				target = Can_I_See_Enemy(npc.index, target);
				if(IsValidEnemy(npc.index, target))
				{
					npc.m_iTarget = target;
					npc.m_flGetClosestTargetTime = gameTime + 2.45;
					npc.m_flAttackHappens = gameTime + 3.00;
				}
			}
		}
	}
	else
	{
		npc.StopPathing();
	}
}

static void ClotDeath(int entity)
{
	VictoriaTank npc = view_as<VictoriaTank>(entity);

	float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);

	npc.PlayDeathSound();

	TE_Particle("asplode_hoodoo", vecMe, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
	int team = GetTeam(npc.index);

	int health = ReturnEntityMaxHealth(npc.index) / 5;
	float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
	float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
	
	int other = NPC_CreateByName("npc_welder", -1, pos, ang, team, "EX");
	if(other > MaxClients)
	{
		if(team != TFTeam_Red)
			Zombies_Currently_Still_Ongoing++;
		
		SetEntProp(other, Prop_Data, "m_iHealth", health);
		SetEntProp(other, Prop_Data, "m_iMaxHealth", health);
		
		fl_Extra_MeleeArmor[other] = fl_Extra_MeleeArmor[npc.index];
		fl_Extra_RangedArmor[other] = fl_Extra_RangedArmor[npc.index];
		fl_Extra_Speed[other] = fl_Extra_Speed[npc.index];
		fl_Extra_Damage[other] = fl_Extra_Damage[npc.index];
		b_thisNpcIsABoss[other] = b_thisNpcIsABoss[npc.index];
		b_StaticNPC[other] = b_StaticNPC[npc.index];
	}
}

