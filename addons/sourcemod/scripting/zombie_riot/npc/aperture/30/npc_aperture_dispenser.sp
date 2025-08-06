#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	")weapons/dispenser_explode.wav",
};

static const char g_HurtSounds[][] = {
	")physics/metal/metal_box_impact_bullet1.wav",
	")physics/metal/metal_box_impact_bullet2.wav",
	")physics/metal/metal_box_impact_bullet3.wav",
};

static const char g_GiveArmor[][] = {
	"weapons/dispenser_generate_metal.wav",
};

void ApertureDispenser_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_GiveArmor));		i++) { PrecacheSound(g_GiveArmor[i]);		}
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Aperture Dispenser");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_aperture_dispenser");
	strcopy(data.Icon, sizeof(data.Icon), "dispenser_lite");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Aperture;
	data.Func = ClotSummon;
	NPC_Add(data);
	PrecacheModel("models/buildables/dispenser.mdl");
	PrecacheModel("models/buildables/dispenser_lvl3_light.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return ApertureDispenser(vecPos, vecAng, team);
}
methodmap ApertureDispenser < CClotBody
{
	property float m_flArmorToGive
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	
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
	public void PlayArmorSound() 
	{
		EmitSoundToAll(g_GiveArmor[GetRandomInt(0, sizeof(g_GiveArmor) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}

	public ApertureDispenser(float vecPos[3], float vecAng[3], int ally)
	{
		ApertureDispenser npc = view_as<ApertureDispenser>(CClotBody(vecPos, vecAng, "models/buildables/dispenser.mdl", "1.0", MinibossHealthScaling(4.5, true), ally, .NpcTypeLogic = 1));
		
		i_NpcWeight[npc.index] = 999;
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_flMeleeArmor = 2.0;
		npc.m_flRangedArmor = 1.0;

		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;
		npc.m_bDissapearOnDeath = true;
		Is_a_Medic[npc.index] = true;
		f_ExtraOffsetNpcHudAbove[npc.index] = 500.0;
		i_NpcIsABuilding[npc.index] = true;
		
		npc.Anger = false;
		npc.m_flDoingAnimation = 0.0;

		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_flArmorToGive = 25.0;

		func_NPCDeath[npc.index] = view_as<Function>(ApertureDispenser_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(ApertureDispenser_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(ApertureDispenser_ClotThink);
		
		// Fixes weird collision
		SetEntityModel(npc.index, "models/buildables/dispenser.mdl");
		
		//IDLE
		npc.m_iState = 0;
		npc.m_flSpeed = 0.0;

		return npc;
	}
}

public void ApertureDispenser_ClotThink(int iNPC)
{
	ApertureDispenser npc = view_as<ApertureDispenser>(iNPC);
	float gameTime = GetGameTime(npc.index);
	
	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	
	switch (npc.m_iState)
	{
		case 0:
		{
			npc.m_flNextThinkTime = gameTime + 0.1;
			
			// Building
			if (!npc.m_flDoingAnimation)
			{
				npc.AddActivityViaSequence("build");
				npc.SetCycle(0.01);
				
				const float animTime = 10.4;
				float duration = npc.Anger ? 1.0 : 10.0;
				
				npc.SetPlaybackRate(animTime / duration);
				npc.m_flDoingAnimation = gameTime + duration;
			}
			else if (npc.m_flDoingAnimation < gameTime)
			{
				SetEntityModel(npc.index, "models/buildables/dispenser_lvl3_light.mdl");
				npc.m_iState = 1;
			}
			
			return;
		}
		
		case 1:
		{
			npc.m_flNextThinkTime = gameTime + 0.5;
			
			ExpidonsaGroupHeal(npc.index, 500.0, 5000, 500.0, 1.0, false, ApertureDispenserGiveArmor);
			ApertureArmorEffect(npc.index, 250.0);
		}
	}
}

void ApertureArmorEffect(int entity, float range)
{
	float ProjectileLoc[3];
	ApertureDispenser npc1 = view_as<ApertureDispenser>(entity);
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
	spawnRing_Vectors(ProjectileLoc, 1.0, 0.0, 0.0, 10.0, "materials/sprites/laserbeam.vmt", 0, 125, 0, 200, 1, 0.5, 5.0, 8.0, 3, range * 2.0);	
	npc1.PlayArmorSound();
}

void ApertureDispenserGiveArmor(int entity, int victim, float &healingammount)
{
	if(i_NpcIsABuilding[victim])
		return;

	ApertureDispenser npc1 = view_as<ApertureDispenser>(entity);
	GrantEntityArmor(victim, false, 0.50, 0.10, 0,
	npc1.m_flArmorToGive * 0.5);
}

public Action ApertureDispenser_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	ApertureDispenser npc = view_as<ApertureDispenser>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void ApertureDispenser_NPCDeath(int entity)
{
	ApertureDispenser npc = view_as<ApertureDispenser>(entity);
	npc.PlayDeathSound();	
	float pos[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	makeexplosion(-1, pos, 0, 0);
}