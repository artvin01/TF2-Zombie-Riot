#pragma semicolon 1
#pragma newdecls required


#define IBERIA_BEACON "models/props_combine/combinethumper001a.mdl"

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
	"physics/metal/metal_box_strain1.wav",
};

void Iberia_Beacon_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_GiveArmor));		i++) { PrecacheSound(g_GiveArmor[i]);		}
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Iberia Beacon");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_iberia_beacon");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.Flags = -1;
	data.Category = Type_IberiaExpiAlliance;
	data.Func = ClotSummon;
	NPC_Add(data);
	PrecacheModel(IBERIA_BEACON);
	GlobalCooldownWarCry = 0.0;
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return IberiaBeacon(vecPos, vecAng, team);
}
methodmap IberiaBeacon < CClotBody
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

	public IberiaBeacon(float vecPos[3], float vecAng[3], int ally)
	{
		IberiaBeacon npc = view_as<IberiaBeacon>(CClotBody(vecPos, vecAng, IBERIA_BEACON, "0.15", MinibossHealthScaling(50.0, true), ally, .NpcTypeLogic = 1));
		
		i_NpcWeight[npc.index] = 999;
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_flMeleeArmor = 2.5;
		npc.m_flRangedArmor = 1.0;

		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;
		npc.m_bDissapearOnDeath = true;
		npc.SetPlaybackRate(1.435);	
		Is_a_Medic[npc.index] = true;
		f_ExtraOffsetNpcHudAbove[npc.index] = 500.0;
		i_NpcIsABuilding[npc.index] = true;


		npc.m_flArmorToGive = 25.0;
		SetMoraleDoIberia(npc.index, 5.0);
		//these are default settings! please redefine these when spawning!

		func_NPCDeath[npc.index] = view_as<Function>(IberiaBeacon_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(IberiaBeacon_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(IberiaBeacon_ClotThink);
		
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

public void IberiaBeacon_ClotThink(int iNPC)
{
	IberiaBeacon npc = view_as<IberiaBeacon>(iNPC);
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
	//Need to check this often sadly.
	if(!IsValidAlly(npc.index, GetClosestAlly(npc.index)))
	{
		//there is no more valid ally, suicide.
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
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 2.0;

	
	ExpidonsaGroupHeal(npc.index, 200.0, 10, 0.0, 1.0, false,IberiaBeaconGiveArmor);
	IberiaArmorEffect(npc.index, 200.0);
	npc.m_flNextRangedSpecialAttack = 0.0;
	IberiaMoraleGivingDo(npc.index, GetGameTime(npc.index), false, 200.0);
}

void IberiaArmorEffect(int entity, float range)
{
	float ProjectileLoc[3];
	IberiaBeacon npc1 = view_as<IberiaBeacon>(entity);
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
	spawnRing_Vectors(ProjectileLoc, 1.0, 0.0, 0.0, 10.0, "materials/sprites/laserbeam.vmt", 125, 125, 0, 200, 1, 0.5, 5.0, 8.0, 3, range * 2.0);	
	npc1.PlayArmorSound();
}

void IberiaBeaconGiveArmor(int entity, int victim, float &healingammount)
{
	if(i_NpcIsABuilding[victim])
		return;

	IberiaBeacon npc1 = view_as<IberiaBeacon>(entity);
	GrantEntityArmor(victim, false, 2.0, 0.33, 0,
	npc1.m_flArmorToGive * 0.5);
}

public Action IberiaBeacon_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	IberiaBeacon npc = view_as<IberiaBeacon>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void IberiaBeacon_NPCDeath(int entity)
{
	IberiaBeacon npc = view_as<IberiaBeacon>(entity);
	npc.PlayDeathSound();	
	float pos[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	makeexplosion(-1, pos, 0, 0);
}