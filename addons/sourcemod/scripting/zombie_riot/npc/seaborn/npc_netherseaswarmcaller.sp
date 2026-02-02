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

void SeaSwarmcaller_Precache()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Nethersea Swarmcaller");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_netherseaswarmcaller");
	strcopy(data.Icon, sizeof(data.Icon), "ds_swarmcaller");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Seaborn;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return SeaSwarmcaller(vecPos, vecAng, team, data);
}

methodmap SeaSwarmcaller < CSeaBody
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
	
	public SeaSwarmcaller(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		bool carrier = data[0] == 'R';
		bool elite = !carrier && data[0];

		SeaSwarmcaller npc = view_as<SeaSwarmcaller>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", elite ? "4200" : "3000", ally, false));
		// 10000 x 0.3
		// 14000 x 0.3

		SetVariantInt(4);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.SetElite(elite, carrier);
		i_NpcWeight[npc.index] = 3;
		npc.SetActivity("ACT_SEABORN_WALK_TOOL_3");
		KillFeed_SetKillIcon(npc.index, "saw_kill");
		
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_SEABORN;
		
		func_NPCDeath[npc.index] = SeaSwarmcaller_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = SeaSwarmcaller_OnTakeDamage;
		func_NPCThink[npc.index] = SeaSwarmcaller_ClotThink;
		
		npc.m_flSpeed = 200.0;	// 0.8 x 250
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		ApplyStatusEffect(npc.index, npc.index, "Fluid Movement", FAR_FUTURE);	
		npc.m_bThisNpcIsABoss = true;
		b_thisNpcHasAnOutline[npc.index] = true;
		
		SetEntityRenderColor(npc.index, 155, 155, 255, 255);

		if(carrier)
		{
			float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
			vecMe[2] += 100.0;

			npc.m_iWearable1 = ParticleEffectAt(vecMe, "powerup_icon_agility", -1.0);
			SetParent(npc.index, npc.m_iWearable1);
		}

		npc.m_iWearable2 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_rift_fire_mace/c_rift_fire_mace.mdl");
		SetVariantString("1.15");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("partyhat", "models/player/items/pyro/bio_fireman.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		if(elite)
		{
			SetEntityRenderColor(npc.m_iWearable3, 200, 0, 0, 255);
		}

		return npc;
	}
}

public void SeaSwarmcaller_ClotThink(int iNPC)
{
	SeaSwarmcaller npc = view_as<SeaSwarmcaller>(iNPC);

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
		float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float distance = GetVectorDistance(vecTarget, vecMe, true);		
		
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

		if(npc.m_flNextMeleeAttack < gameTime)
		{
			npc.m_flNextMeleeAttack = gameTime + 0.5;

			spawnRing_Vectors(vecMe, 100.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 50, 50, 200, 1, 0.4, 6.0, 0.1, 1, 640.0);
			// 200 x 1.6
			
			Explode_Logic_Custom(npc.m_bElite ? 24.0 : 21.0, -1, npc.index, -1, vecMe, 320.0, _, _, true, _, false, _, SeaSwarmcaller_ExplodePost);
			// 140 x 0.15
			// 160 x 0.15
		}
	}
	else
	{
		npc.StopPathing();
	}

	npc.PlayIdleSound();
}

public void SeaSwarmcaller_ExplodePost(int attacker, int victim, float damage, int weapon)
{
	Elemental_AddNervousDamage(victim, attacker, view_as<SeaSwarmcaller>(attacker).m_bCarrier ? 3 : 2);
	// 140 x 0.05 x 0.15
	// 160 x 0.05 x 0.15
	// 140 x 0.1 x 0.15
}

public Action SeaSwarmcaller_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker < 1)
		return Plugin_Continue;
	
	SeaSwarmcaller npc = view_as<SeaSwarmcaller>(victim);
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

void SeaSwarmcaller_NPCDeath(int entity)
{
	SeaSwarmcaller npc = view_as<SeaSwarmcaller>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	
	if(npc.m_bCarrier)
	{
		float pos[3];
		GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", pos);
		Remains_SpawnDrop(pos, Buff_Swarmcaller);
	}
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);

	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}
