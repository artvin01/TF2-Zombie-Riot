#pragma semicolon 1
#pragma newdecls required

static int NPCId;

static float BuffTimerLimited;
void BaseBuilding_MapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "VIP Building, The Objective");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_base_building");
	strcopy(data.Icon, sizeof(data.Icon), "test_filename");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);
}

int BaseBuilding_ID()
{
	return NPCId;
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3],int ally,  const char[] data)
{
	return BaseBuilding(client, vecPos, vecAng, data);
}
methodmap BaseBuilding < BarrackBody
{
	public BaseBuilding(int client, float vecPos[3], float vecAng[3], const char[] data)
	{
		if(data[0])
			ExplodeStringFloat(data, " ", vecPos, sizeof(vecPos));
		
		BaseBuilding npc = view_as<BaseBuilding>(BarrackBody(client, vecPos, vecAng, "10000", TOWER_MODEL, _, TOWER_SIZE_BARRACKS, 80.0, "models/pickups/pickup_powerup_resistance.mdl"));
		
		npc.m_iWearable1 = npc.EquipItemSeperate("models/props_manor/clocktower_01.mdl");
		SetVariantString("0.2");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		i_NpcWeight[npc.index] = 999;
		i_NpcIsABuilding[npc.index] = true;
		b_NoKnockbackFromSources[npc.index] = true;
		npc.m_bDissapearOnDeath = true;
		npc.m_flHeadshotCooldown = 0.0;
		BuffTimerLimited = GetGameTime() + 90.0;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;
		
		SetEntityRenderMode(npc.index, RENDER_NONE);
		SetEntityRenderColor(npc.index, 0, 0, 0, 0);
		SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 255);
		func_NPCDeath[npc.index] = BaseBuilding_NPCDeath;
		func_NPCThink[npc.index] = BaseBuilding_ClotThink;
		func_NPCOnTakeDamage[npc.index] = BaseBuilding_ClotTakeDamage;
		CPrintToChatAll("{crimson}%t", "Explain Construction 0");
		CPrintToChatAll("{green}%t", "Explain Construction 1");
		CPrintToChatAll("{green}%t", "Explain Construction 3");
		CPrintToChatAll("{green}%t", "Explain Construction 4");

		npc.m_flSpeed = 0.0;
		return npc;
	}
}

public void BaseBuilding_ClotThink(int iNPC)
{
	BaseBuilding npc = view_as<BaseBuilding>(iNPC);
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	if(BuffTimerLimited)
		StartingBaseBuffGiveBuff(npc.index);
	
	npc.m_flNextDelayTime = gameTime + 0.1;
	BarrackBody npc1 = view_as<BarrackBody>(iNPC);
	BarrackBody_HealthHud(npc1 ,0.0);
	
	if(npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		if(GetClosestTarget(npc.index, _, 100.0, true, .UseVectorDistance = true) > 0)
		{
			for (int client = 1; client <= MaxClients; client++)
			{
				f_DelayLookingAtHud[client] = GetGameTime() + 0.5;
			}
			PrintCenterTextAll("VIP BUILDING IS UNDER ATTACK");
			EmitSoundToAll("mvm/mvm_cpoint_klaxon.wav", npc.index, SNDCHAN_STATIC, 120, _, 1.0);
			EmitSoundToAll("mvm/mvm_cpoint_klaxon.wav", npc.index, SNDCHAN_STATIC, 120, _, 1.0);

			npc.m_flHeadshotCooldown = GetGameTime(npc.index) + 0.5;
			npc.PlayHurtSound();

			int health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
			int maxhealth = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");
			health -= maxhealth / 50;

			if(health > 0)
			{
				SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
			}
			else if(Waves_Started())
			{
				SDKHooks_TakeDamage(npc.index, 0, 0, 199999999.0, DMG_BLAST, -1, _, _, _, ZR_SLAY_DAMAGE);
			}
		}
		else
		{
			int maxhealth = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");
			float health = float(maxhealth) / 500.0;

			HealEntityGlobal(npc.index, npc.index, health, _, _, _, _);
		}
	}
}

void BaseBuilding_NPCDeath(int entity)
{
	BaseBuilding npc = view_as<BaseBuilding>(entity);

	float pos[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	makeexplosion(-1, pos, 0, 0);
	BarrackBody_NPCDeath(npc.index);
	if(Waves_Started())
	{
		ForcePlayerLoss();

		CreateTimer(1.0, Timer_EverythingExplodes, _, TIMER_FLAG_NO_MAPCHANGE);
	}
}

static Action Timer_EverythingExplodes(Handle timer)
{
	int entity = -1;
	while((entity=FindEntityByClassname(entity, "obj_building")) != -1)
	{
		float pos[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
		makeexplosion(-1, pos, 0, 0);
		SDKHooks_TakeDamage(entity, 0, 0, 199999999.0, DMG_BLAST, -1, _, _, _, ZR_SLAY_DAMAGE);

		CreateTimer(0.2, Timer_EverythingExplodes, _, TIMER_FLAG_NO_MAPCHANGE);
		break;
	}

	return Plugin_Continue;
}

void BaseBuilding_ClotTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker > 0 && damage < 999999.9)
		damage = 0.0;
}

static void StartingBaseBuffGiveBuff(int iNpc)
{

	b_NpcIsTeamkiller[iNpc] = true;
	float spawnLoc[3]; 	
	WorldSpaceCenter(iNpc, spawnLoc);
	Explode_Logic_Custom(0.0,
	iNpc,
	iNpc,
	-1,
	spawnLoc,
	9999.9,
	_,
	_,
	false,
	99,
	false,
	_,
	StartingBaseBuffGiveBuffInternal);
	b_NpcIsTeamkiller[iNpc] = false;
}

static void StartingBaseBuffGiveBuffInternal(int entity, int victim, float damage, int weapon)
{
	if(entity == victim)
		return;

	if (GetTeam(victim) == GetTeam(entity) && !i_IsABuilding[victim] && (!b_NpcHasDied[victim] || victim <= MaxClients))
	{
		float GiveBuffDuration = BuffTimerLimited - GetGameTime();
		if(GiveBuffDuration <= 0.0)
		{
			BuffTimerLimited = 0.0;
			return;
		}
		ApplyStatusEffect(entity, victim, "Starting Grace", GiveBuffDuration);
	}
}
