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
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.Flags = -1;
	data.Category = Type_Aperture;
	data.Func = ClotSummon;
	NPC_Add(data);
	PrecacheModel("models/buildables/dispenser_lvl3.mdl");
	GlobalCooldownWarCry = 0.0;
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
		ApertureDispenser npc = view_as<ApertureDispenser>(CClotBody(vecPos, vecAng, "models/buildables/dispenser_lvl3.mdl", "1.0", MinibossHealthScaling(4.5, true), ally, .NpcTypeLogic = 1));
		
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
		AddNpcToAliveList(npc.index, 1);

		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_flArmorToGive = 25.0;
		//these are default settings! please redefine these when spawning!

		func_NPCDeath[npc.index] = view_as<Function>(ApertureDispenser_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(ApertureDispenser_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(ApertureDispenser_ClotThink);
		
		//IDLE
		npc.m_iState = 0;
		npc.m_flSpeed = 0.0;

		//counts as a static npc, means it wont count towards NPC limit.
		AddNpcToAliveList(npc.index, 1);
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 255, 255, 255, 150);

		return npc;
	}
}

public void ApertureDispenser_ClotThink(int iNPC)
{
	ApertureDispenser npc = view_as<ApertureDispenser>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	if(npc.m_iState == 0)
	{
		npc.m_iState = 1;
		SetEntityRenderMode(npc.index, RENDER_NORMAL);
		SetEntityRenderColor(npc.index, 255, 255, 255, 255);
	}
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.5;

	ExpidonsaGroupHeal(npc.index, 500.0, 5000, 500.0, 1.0, false,ApertureDispenserGiveArmor);
	ApertureArmorEffect(npc.index, 250.0);
	npc.m_flNextRangedSpecialAttack = 0.0;
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