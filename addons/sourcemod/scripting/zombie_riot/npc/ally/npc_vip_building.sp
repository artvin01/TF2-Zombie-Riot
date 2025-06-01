#pragma semicolon 1
#pragma newdecls required

static bool IsActive;
static int NPCId;

void VIPBuilding_MapStart()
{
	IsActive = false;
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "VIP Building, The Objective");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_vip_building");
	strcopy(data.Icon, sizeof(data.Icon), "test_filename");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);
}

int VIPBuilding_ID()
{
	return NPCId;
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3],int ally,  const char[] data)
{
	return VIPBuilding(client, vecPos, vecAng, data);
}
methodmap VIPBuilding < BarrackBody
{
	public VIPBuilding(int client, float vecPos[3], float vecAng[3], const char[] data)
	{
		if(data[0])
			ExplodeStringFloat(data, " ", vecPos, sizeof(vecPos));
		
		VIPBuilding npc = view_as<VIPBuilding>(BarrackBody(client, vecPos, vecAng, "10000", TOWER_MODEL, _, TOWER_SIZE_BARRACKS, 80.0, "models/pickups/pickup_powerup_resistance.mdl"));
		
		npc.m_iWearable1 = npc.EquipItemSeperate("models/props_manor/clocktower_01.mdl");
		SetVariantString("0.1");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		i_NpcWeight[npc.index] = 999;
		i_NpcIsABuilding[npc.index] = true;
		b_NoKnockbackFromSources[npc.index] = true;
		npc.m_bDissapearOnDeath = true;
		npc.m_flHeadshotCooldown = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;
		
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 0, 0, 0, 0);
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 255);
		func_NPCDeath[npc.index] = VIPBuilding_NPCDeath;
		func_NPCThink[npc.index] = VIPBuilding_ClotThink;
		func_NPCOnTakeDamage[npc.index] = VIPBuilding_ClotTakeDamage;

		npc.m_flSpeed = 0.0;

		IsActive = true;
		return npc;
	}
}

public void VIPBuilding_ClotThink(int iNPC)
{
	VIPBuilding npc = view_as<VIPBuilding>(iNPC);
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
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
				ForcePlayerLoss();
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

void VIPBuilding_NPCDeath(int entity)
{
	VIPBuilding npc = view_as<VIPBuilding>(entity);

	IsActive = false;

	float pos[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	makeexplosion(-1, pos, 0, 0);
	BarrackBody_NPCDeath(npc.index);
	if(Waves_Started())
	{
		ForcePlayerLoss();
	}
}

void VIPBuilding_ClotTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker > 0 && damage < 999999.9)
		damage = 0.0;
}

bool VIPBuilding_Active()
{
	return IsActive;
}