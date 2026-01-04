#pragma semicolon 1
#pragma newdecls required

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

static const char g_IdleAlertedSounds[][] = {
	"npc/attack_helicopter/aheli_rotor_loop1.wav",
};


void Goliath_Aircraft_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds));		i++) { PrecacheSound(g_IdleAlertedSounds[i]);		}
	PrecacheModel("models/combine_helicopter.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Goliath Aircraft");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_goliath_aircraft");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
}

int PlayerToAircraft[MAXPLAYERS];
static any ClotSummon(int client, float vecPos[3], float vecAng[3],int ally)
{
	return Goliath_Aircraft(client ,vecPos, vecAng, ally);
}

methodmap Goliath_Aircraft < CClotBody
{
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);

	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
	}

	public void PlayIdleSound() 
	{
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_AUTO, 70, _, 0.45, 110);
		
	}
	public void StopIdleSound() 
	{
		StopSound(this.index, SNDCHAN_AUTO, g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)]);
		
	}
	
	public Goliath_Aircraft(int client, float vecPos[3], float vecAng[3], int ally)
	{
		Goliath_Aircraft npc = view_as<Goliath_Aircraft>(CClotBody(vecPos, vecAng, "models/combine_helicopter.mdl", "0.1", "100", ally));
		
		i_NpcWeight[npc.index] = 3;
		
		b_ThisNpcIsImmuneToNuke[npc.index] = true;

		
		b_DoNotUnStuck[npc.index] = true;
		b_NoGravity[npc.index] = true;
		b_ThisNpcIsImmuneToNuke[npc.index] = true;

		func_NPCDeath[npc.index] = Goliath_Aircraft_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Goliath_Aircraft_OnTakeDamage;
		func_NPCThink[npc.index] = Goliath_Aircraft_ClotThink;
		

		if(IsValidClient(client))
		{
			SetEntPropEnt(npc.index,   Prop_Send, "m_hOwnerEntity", client);
			SetVariantInt(0);
			AcceptEntityInput(client, "SetForcedTauntCam");
			PlayerToAircraft[client] = EntIndexToEntRef(npc.index);
			npc.m_iWearable1 = npc.EquipItemSeperate("models/empty.mdl");
			Custom_SDKCall_SetLocalOrigin(npc.m_iWearable1, {-55.0,0.0,15.0});	
			SetEntPropVector(npc.m_iWearable1, Prop_Data, "m_angRotation", {20.0,0.0,0.0}); 
			SetClientViewEntity(client, npc.m_iWearable1);
		}
		npc.PlayIdleSound();
		npc.m_flSpeed = 100.0;

		return npc;
	}
}

public void Goliath_Aircraft_ClotThink(int iNPC)
{
	Goliath_Aircraft npc = view_as<Goliath_Aircraft>(iNPC);

	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
		return;
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;

	if(npc.m_blPlayHurtAnimation)
	{
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}

	int Owner = GetEntPropEnt(npc.index, Prop_Send, "m_hOwnerEntity");
	if(!IsValidEntity(Owner))
	{
		return;
	}
	//constnatly override onplayergetinfo
	EntityFuncPlayerRunCmd[Owner] = Goliath_Aircraft_OnPlayerRunCmd;


}

public void Goliath_Aircraft_OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	int Ship = EntRefToEntIndex(PlayerToAircraft[client]);
	if(!IsValidEntity(Ship))
	{
		EntityFuncPlayerRunCmd[Ship] = INVALID_FUNCTION;
		return;
	}
	Goliath_Aircraft npc = view_as<Goliath_Aircraft>(Ship);
	float fVel[3];

	if(npc.m_flSpeed <= 0.0)
		return;

	float anglesrocket[3];
	GetEntPropVector(Ship, Prop_Data, "m_angRotation", anglesrocket);
	anglesrocket[0] += float(mouse[1]) * 0.1;
	anglesrocket[1] -= float(mouse[0]) * 0.1;

	float fBuf[3];
	GetAngleVectors(anglesrocket, fBuf, NULL_VECTOR, NULL_VECTOR);
	fVel[0] = fBuf[0]*npc.m_flSpeed;
	fVel[1] = fBuf[1]*npc.m_flSpeed;
	fVel[2] = fBuf[2]*npc.m_flSpeed;
	Custom_SetAbsVelocity(Ship, fVel);	
	npc.SetVelocity(fVel);	
	SetEntPropVector(Ship, Prop_Data, "m_angRotation", anglesrocket);
}
public Action Goliath_Aircraft_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	Goliath_Aircraft npc = view_as<Goliath_Aircraft>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

public void Goliath_Aircraft_NPCDeath(int entity)
{
	Goliath_Aircraft npc = view_as<Goliath_Aircraft>(entity);
	npc.PlayDeathSound();	
	float pos[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	makeexplosion(-1, pos, 0, 0);
	npc.StopIdleSound();

	int Owner = GetEntPropEnt(npc.index, Prop_Send, "m_hOwnerEntity");
	if(IsValidEntity(Owner))
	{
		SetClientViewEntity(Owner, Owner);
		EntityFuncPlayerRunCmd[Owner] = INVALID_FUNCTION;
	}
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
	
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);

	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);
}