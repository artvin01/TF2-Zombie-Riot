#pragma semicolon 1
#pragma newdecls required


#define Vincent_BEACON "models/props_combine/combinethumper001a.mdl"

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

int NPCID;
void Vincent_Beacon_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_GiveArmor));		i++) { PrecacheSound(g_GiveArmor[i]);		}
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Vincent Beacon");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_vincent_beacon");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.Flags = -1;
	data.Category = 0;
	data.Func = ClotSummon;
	NPCID = NPC_Add(data);
	PrecacheModel(Vincent_BEACON);
	GlobalCooldownWarCry = 0.0;
}

int VincentBeaconID()
{
	return NPCID;
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return VincentBeacon(vecPos, vecAng, team);
}
methodmap VincentBeacon < CClotBody
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

	public VincentBeacon(float vecPos[3], float vecAng[3], int ally)
	{
		VincentBeacon npc = view_as<VincentBeacon>(CClotBody(vecPos, vecAng, Vincent_BEACON, "0.15", MinibossHealthScaling(50.0, true), ally, .NpcTypeLogic = 1));
		
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
		b_NoHealthbar[npc.index] = true;


		//these are default settings! please redefine these when spawning!

		func_NPCDeath[npc.index] = view_as<Function>(VincentBeacon_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(VincentBeacon_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(VincentBeacon_ClotThink);
		
		//IDLE
		npc.m_iState = 0;
		npc.m_flSpeed = 0.0;

		//counts as a static npc, means it wont count towards NPC limit.
		AddNpcToAliveList(npc.index, 1);
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 255, 255, 255, 150);

		MakeObjectIntangeable(npc.index);
		b_DoNotUnStuck[npc.index] = true;
		b_NoKnockbackFromSources[npc.index] = true;
		b_ThisEntityIgnored[npc.index] = true;
		b_thisNpcIsARaid[npc.index] = true;
		b_NoKillFeed[npc.index] = true;

		return npc;
	}
}

public void VincentBeacon_ClotThink(int iNPC)
{
	VincentBeacon npc = view_as<VincentBeacon>(iNPC);
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
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.5;

	
	ExpidonsaGroupHeal(npc.index, 150.0, 10, 0.0, 1.0, false,VincentBeaconGiveArmor, .LOS = false);
}


void VincentBeaconGiveArmor(int entity, int victim, float &healingammount)
{
	if(i_NpcIsABuilding[victim])
		return;
	VincentBeacon npc = view_as<VincentBeacon>(victim);
	if(npc.Anger)
	{
		ApplyStatusEffect(entity, victim, "Expidonsan Anger", 3.0);
	}
	ApplyStatusEffect(entity, victim, "Combine Command", 3.0);
	ApplyStatusEffect(entity, victim, "Very Defensive Backup", 0.6);
}

public Action VincentBeacon_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VincentBeacon npc = view_as<VincentBeacon>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void VincentBeacon_NPCDeath(int entity)
{
	VincentBeacon npc = view_as<VincentBeacon>(entity);
	npc.PlayDeathSound();	
	float pos[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	makeexplosion(-1, pos, 0, 0);

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}