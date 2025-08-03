#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	")weapons/teleporter_explode.wav",
};

static const char g_HurtSounds[][] = {
	")physics/metal/metal_box_impact_bullet1.wav",
	")physics/metal/metal_box_impact_bullet2.wav",
	")physics/metal/metal_box_impact_bullet3.wav",
};

void ApertureTeleporter_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Aperture Teleporter");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_aperture_teleporter");
	strcopy(data.Icon, sizeof(data.Icon), "teleporter");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Aperture;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return ApertureTeleporter(vecPos, vecAng, team);
}
methodmap ApertureTeleporter < CClotBody
{
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

	public ApertureTeleporter(float vecPos[3], float vecAng[3], int ally)
	{
		ApertureTeleporter npc = view_as<ApertureTeleporter>(CClotBody(vecPos, vecAng, "models/buildables/teleporter_light.mdl", "1.0", MinibossHealthScaling(4.5, true), ally, .NpcTypeLogic = 1));
		
		i_NpcWeight[npc.index] = 999;

		npc.m_flMeleeArmor = 2.0;
		npc.m_flRangedArmor = 0.5;

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_iOverlordComboAttack = 0;
		npc.m_iBleedType = 0;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;
		npc.m_bDissapearOnDeath = true;
		npc.Anger = true;
		f_ExtraOffsetNpcHudAbove[npc.index] = 500.0;
		i_NpcIsABuilding[npc.index] = true;
		npc.m_flNextRangedSpecialAttack = 0.0;
		AddNpcToAliveList(npc.index, 1);

		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		func_NPCDeath[npc.index] = view_as<Function>(ApertureTeleporter_NPCDeath);
		func_NPCThink[npc.index] = view_as<Function>(ApertureTeleporter_ClotThink);

		if(!VIPBuilding_Active())
		{
			for(int i; i < ZR_MAX_SPAWNERS; i++)
			{
				if(!i_ObjectsSpawners[i] || !IsValidEntity(i_ObjectsSpawners[i]))
				{
					Spawns_AddToArray(npc.index, true);
					i_ObjectsSpawners[i] = EntIndexToEntRef(npc.index);
					//npc.DispatchParticleEffect(npc.index, "hightower_explosion", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR);
					break;
				}
			}
		}
		
		npc.AddActivityViaSequence("running");
		npc.SetCycle(0.01);
		
		return npc;
	}
}

public void ApertureTeleporter_ClotThink(ApertureTeleporter npc, int iNPC)
{
	float gameTime = GetGameTime(npc.index);
	float vecPos[3];
	GetAbsOrigin(npc.index, vecPos);
	
	if(!IsValidEntity(npc.m_iWearable1))
		npc.m_iWearable1 = ParticleEffectAt_Parent(vecPos, "teleporter_blue_charged_level3", npc.index, .vOffsets = { 0.0, 0.0, 12.0 });

	if(npc.m_flNextRangedSpecialAttack < gameTime)
	{
		npc.m_flNextRangedSpecialAttack = gameTime + 0.1;
		
		int target = GetClosestAlly(npc.index, (250.0 * 250.0));
		if(target)
		{
			if(!HasSpecificBuff(target, "Quantum Entanglement"))
			{
				ApplyStatusEffect(npc.index, target, "Quantum Entanglement", 30.0);
			}
		}
	}
}

public Action ApertureTeleporter_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	ApertureTeleporter npc = view_as<ApertureTeleporter>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void ApertureTeleporter_NPCDeath(int entity)
{
	ApertureTeleporter npc = view_as<ApertureTeleporter>(entity);
	npc.PlayDeathSound();	
	float pos[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	makeexplosion(-1, pos, 0, 0);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}