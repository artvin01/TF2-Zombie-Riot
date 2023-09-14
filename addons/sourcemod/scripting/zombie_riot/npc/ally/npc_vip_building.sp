#pragma semicolon 1
#pragma newdecls required

static const char g_HurtSounds[][] =
{
	")physics/metal/metal_box_impact_bullet1.wav",
	")physics/metal/metal_box_impact_bullet2.wav",
	")physics/metal/metal_box_impact_bullet3.wav",
};

static bool IsActive;

void VIPBuilding_MapStart()
{
	IsActive = false;
}

methodmap VIPBuilding < BarrackBody
{
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		
	}
	public VIPBuilding(int client, float vecPos[3], float vecAng[3], const char[] data)
	{
		if(data[0])
			ExplodeStringFloat(data, " ", vecPos, sizeof(vecPos));
		
		VIPBuilding npc = view_as<VIPBuilding>(BarrackBody(client, vecPos, vecAng, "10000", TOWER_MODEL, _, TOWER_SIZE_BARRACKS, 80.0, "models/pickups/pickup_powerup_resistance.mdl"));
		
		npc.m_iWearable1 = npc.EquipItemSeperate("partyhat", "models/props_manor/clocktower_01.mdl");
		SetVariantString("0.1");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		i_NpcInternalId[npc.index] = VIP_BUILDING;
		i_NpcWeight[npc.index] = 999;
		i_NpcIsABuilding[npc.index] = true;
		b_NoKnockbackFromSources[npc.index] = true;
		npc.m_bDissapearOnDeath = true;
		npc.m_flHeadshotCooldown = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;
		
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, VIPBuilding_OnTakeDamagePost);
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 0, 0, 0, 0);
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 255);

		npc.m_flSpeed = 0.0;

		IsActive = true;
		return npc;
	}
}

void VIPBuilding_NPCDeath(int entity)
{
	VIPBuilding npc = view_as<VIPBuilding>(entity);

	IsActive = false;

	float pos[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	makeexplosion(-1, -1, pos, "", 0, 0);
	BarrackBody_NPCDeath(npc.index);
	SDKUnhook(npc.index, SDKHook_OnTakeDamagePost, VIPBuilding_OnTakeDamagePost);

	if(Waves_Started())
	{
		int endround = CreateEntityByName("game_round_win"); 
		DispatchKeyValue(endround, "force_map_reset", "1");
		SetEntProp(endround, Prop_Data, "m_iTeamNum", TFTeam_Blue);
		DispatchSpawn(endround);
		AcceptEntityInput(endround, "RoundWin");
		Music_RoundEnd(endround);
	}
}

void VIPBuilding_OnTakeDamagePost(int victim, int attacker) 
{
	//Valid attackers only.
	if(attacker < 1)
		return;

	VIPBuilding npc = view_as<VIPBuilding>(victim);
	if(npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		for (int client = 1; client <= MaxClients; client++)
		{
			f_DelayLookingAtHud[client] = GetGameTime() + 0.5;
		}
		PrintCenterTextAll("VIP BUILDING IS UNDER ATTACK");

		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.PlayHurtSound();
	}
}

bool VIPBuilding_Active()
{
	return IsActive;
}