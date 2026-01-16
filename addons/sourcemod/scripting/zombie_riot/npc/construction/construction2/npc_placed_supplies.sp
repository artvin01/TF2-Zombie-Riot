#pragma semicolon 1
#pragma newdecls required


#define SUPPLIES_MODEL "models/props_halloween/pumpkin_loot.mdl"

static const char g_DeathSounds[][] = {
	")physics/metal/metal_canister_impact_hard1.wav",
	")physics/metal/metal_canister_impact_hard2.wav",
	")physics/metal/metal_canister_impact_hard3.wav",
};

static const char g_HurtSounds[][] = {
	")physics/metal/metal_box_impact_bullet1.wav",
	")physics/metal/metal_box_impact_bullet2.wav",
	")physics/metal/metal_box_impact_bullet3.wav",
};

static const char g_GiveArmor[][] = {
	"items/smallmedkit1.wav",
};

void PlacedSupplies_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_GiveArmor));		i++) { PrecacheSound(g_GiveArmor[i]);		}
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Placed Supplies");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_placed_supplies");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.Flags = -1;
	data.Category = Type_IberiaExpiAlliance;
	data.Func = ClotSummon;
	NPC_Add(data);
	PrecacheModel(SUPPLIES_MODEL);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return PlacedSupplies(vecPos, vecAng, team);
}
methodmap PlacedSupplies < CClotBody
{
	property float m_flSuicideTimer
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
		EmitSoundToAll(g_GiveArmor[GetRandomInt(0, sizeof(g_GiveArmor) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME - 0.1, 70);
	}

	public PlacedSupplies(float vecPos[3], float vecAng[3], int ally)
	{
		PlacedSupplies npc = view_as<PlacedSupplies>(CClotBody(vecPos, vecAng, SUPPLIES_MODEL, "1.0", "1000", ally, .NpcTypeLogic = 1));
		
		i_NpcWeight[npc.index] = 999;
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_flMeleeArmor = 2.5;
		npc.m_flRangedArmor = 1.0;

		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;
		npc.m_bDissapearOnDeath = true;
		
		Is_a_Medic[npc.index] = true;
		i_NpcIsABuilding[npc.index] = true;
		MakeObjectIntangeable(npc.index);
		b_DoNotUnStuck[npc.index] = true;
		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		b_NoKnockbackFromSources[npc.index] = true;
		b_ThisEntityIgnored[npc.index] = true;
		b_NoKillFeed[npc.index] = true;
		b_CantCollidie[npc.index] = true; 
		b_CantCollidieAlly[npc.index] = true; 
		b_ThisEntityIgnoredBeingCarried[npc.index] = true; //cant be targeted AND wont do npc collsiions
		npc.m_bDissapearOnDeath = true;
		b_HideHealth[npc.index] = true;
		b_NoHealthbar[npc.index] = 1;



		//these are default settings! please redefine these when spawning!

		func_NPCDeath[npc.index] = view_as<Function>(PlacedSupplies_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(PlacedSupplies_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(PlacedSupplies_ClotThink);
		
		//IDLE
		npc.m_iState = 0;
		npc.m_flSpeed = 0.0;

		npc.m_flSuicideTimer = GetGameTime() + 40.0;
		//counts as a static npc, means it wont count towards NPC limit.
		AddNpcToAliveList(npc.index, 1);
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 255, 255, 255, 150);

		return npc;
	}
}

public void PlacedSupplies_ClotThink(int iNPC)
{
	PlacedSupplies npc = view_as<PlacedSupplies>(iNPC);
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
	//We only give a time untill we are killed.
	if(npc.m_flSuicideTimer < GetGameTime())
	{
		SmiteNpcToDeath(npc.index);
		return;
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

	
	ExpidonsaGroupHeal(npc.index,
	 200.0,
	  99,
	   0.0,
	   1.0,
	    false,
		 PlacedSuppliesGiveBuffs ,
  		  _,
   		  true);
	PlacedSuppliesEffect(npc.index, 200.0);
}

void PlacedSuppliesEffect(int entity, float range)
{
	float ProjectileLoc[3];
	PlacedSupplies npc1 = view_as<PlacedSupplies>(entity);
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
	spawnRing_Vectors(ProjectileLoc, range * 2.0, 0.0, 0.0, 10.0, "materials/sprites/laserbeam.vmt", 65, 255, 65, 200, 1, 0.6, 5.0, 0.1, 3);	
	npc1.PlayArmorSound();
}

void PlacedSuppliesGiveBuffs(int entity, int victim, float &healingammount)
{
	if(i_NpcIsABuilding[victim])
		return;

	float HealBy = 0.15;
	if(b_thisNpcIsABoss[victim])	
		HealBy *= 0.1;
	if(GetTeam(entity) != GetTeam(victim))
	{
		//nerf by alot alot
		HealBy *= 0.05;
		ApplyStatusEffect(entity, victim, "Defensive Backup", 1.0);
		if(HasSpecificBuff(victim, "Recently Healed Supplies"))
		{
			//prevent heal stacking for enemies
			HealBy = 0.0;
			ApplyStatusEffect(entity, victim, "Recently Healed Supplies", 0.4);
		}
	}
	else
	{
		ApplyStatusEffect(entity, victim, "Ancient Melodies", 2.0);
		ApplyStatusEffect(entity, victim, "Very Defensive Backup", 2.0);
	}
	if(HealBy <= 0.0)
		return;
	int health = ReturnEntityMaxHealth(victim);
	HealEntityGlobal(entity, victim, float(health) * HealBy, 1.0);
	
}

public Action PlacedSupplies_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PlacedSupplies npc = view_as<PlacedSupplies>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void PlacedSupplies_NPCDeath(int entity)
{
	PlacedSupplies npc = view_as<PlacedSupplies>(entity);
	npc.PlayDeathSound();	
}