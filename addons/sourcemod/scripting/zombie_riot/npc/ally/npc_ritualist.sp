#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSound[] = "weapons/bombinomicon_explode1.wav";
static const char g_LoopSound[] = "ambient/halloween/bombinomicon_loop.wav";

void RitualistInstinct_MapStart()
{
	PrecacheSound(g_DeathSound);
	PrecacheSound(g_LoopSound);

	PrecacheModel("models/headcrabclassic.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Instinct's Summon");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_ritualist");
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return RitualistInstinct(client, vecPos, vecAng, team);
}

methodmap RitualistInstinct < CClotBody
{
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSound, this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}

	public RitualistInstinct(int client, float vecPos[3], float vecAng[3], int ally)
	{
		char buffer[16];

		if(client)
			IntToString(ReturnEntityMaxHealth(client) / 2, buffer, sizeof(buffer));
		
		RitualistInstinct npc = view_as<RitualistInstinct>(CClotBody(vecPos, vecAng, "models/headcrabclassic.mdl", "1.0", buffer, ally, false));
		
		i_NpcWeight[npc.index] = 0;
		npc.SetActivity("ACT_RUN");
		
		npc.m_iBleedType = BLEEDTYPE_VOID;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = BLEEDTYPE_VOID;
		
		func_NPCDeath[npc.index] = RitualistInstinct_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = RitualistInstinct_OnTakeDamage;
		func_NPCThink[npc.index] = RitualistInstinct_ClotThink;
		
		npc.m_flSpeed = 360.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		f_ExtraOffsetNpcHudAbove[npc.index] = -65.0;

		SetEntPropEnt(npc.index, Prop_Send, "m_hOwnerEntity", client);
		
		SetEntityRenderColor(npc.index, 0, 0, 0, 255);

		EmitSoundToAll(g_LoopSound, npc.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);	
		return npc;
	}
}

public void RitualistInstinct_ClotThink(int iNPC)
{
	RitualistInstinct npc = view_as<RitualistInstinct>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_iTarget && !IsValidEnemy(npc.index, npc.m_iTarget))
		npc.m_iTarget = 0;
	
	if(!npc.m_iTarget && npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}
	
	if(npc.m_iTarget > 0)
	{
		npc.SetGoalEntity(npc.m_iTarget);
		npc.StartPathing();
	}
	else
	{
		npc.StopPathing();
	}
}

public Action RitualistInstinct_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker < 1)
		return Plugin_Continue;
	
	if(f_ArmorCurrosionImmunity[attacker][Element_Nervous] > GetGameTime())
		damage *= 0.01;
	
	return Plugin_Changed;
}

void RitualistInstinct_NPCDeath(int entity)
{
	RitualistInstinct npc = view_as<RitualistInstinct>(entity);
	StopSound(npc.index, SNDCHAN_AUTO, g_LoopSound);
	npc.PlayDeathSound();

	float pos[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	TE_Particle("bombinomicon_burningdebris_halloween", pos, .entindex = entity);

	Ritualist_MinionExplode(GetEntPropEnt(npc.index, Prop_Send, "m_hOwnerEntity"), entity);
}


