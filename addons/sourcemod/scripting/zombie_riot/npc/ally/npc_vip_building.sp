#pragma semicolon 1
#pragma newdecls required

static const char g_HurtSounds[][] =
{
	")physics/metal/metal_box_impact_bullet1.wav",
	")physics/metal/metal_box_impact_bullet2.wav",
	")physics/metal/metal_box_impact_bullet3.wav",
};

methodmap VIPBuilding < BarrackBody
{
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		
	}
	public VIPBuilding(int client, float vecPos[3], float vecAng[3])
	{
		VIPBuilding npc = view_as<VIPBuilding>(BarrackBody(client, vecPos, vecAng, "10000", TOWER_MODEL, _, TOWER_SIZE_BARRACKS, 80.0, "models/pickups/pickup_powerup_resistance.mdl"));
		
		npc.m_iWearable1 = npc.EquipItemSeperate("partyhat", "models/props_manor/clocktower_01.mdl");
		SetVariantString("0.1");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		i_NpcInternalId[npc.index] = VIP_BUILDING;
		i_NpcWeight[npc.index] = 999;
		i_NpcIsABuilding[npc.index] = true;
		b_NoKnockbackFromSources[npc.index] = true;
		npc.m_bDissapearOnDeath = true;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;
		
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, VIPBuilding_OnTakeDamagePost);

		npc.m_flSpeed = 0.0;
		
		return npc;
	}
}

void VIPBuilding_NPCDeath(int entity)
{
	VIPBuilding npc = view_as<VIPBuilding>(entity);

	float pos[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	makeexplosion(-1, -1, pos, "", 0, 0);
	BarrackBody_NPCDeath(npc.index);
	SDKUnhook(npc.index, SDKHook_OnTakeDamagePost, VIPBuilding_OnTakeDamagePost);

	if(Waves_Started())
	{
		int entity = CreateEntityByName("game_round_win"); 
		DispatchKeyValue(entity, "force_map_reset", "1");
		SetEntProp(entity, Prop_Data, "m_iTeamNum", TFTeam_Blue);
		DispatchSpawn(entity);
		AcceptEntityInput(entity, "RoundWin");
		Music_RoundEnd(entity);
	}
}

void VIPBuilding_OnTakeDamagePost(int attacker) 
{
	//Valid attackers only.
	if(attacker < 1)
		return;

	VIPBuilding npc = view_as<VIPBuilding>(victim);
	if(npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		PrintCenterTextAll("VIP BUILDING IS UNDER ATTACK");

		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.PlayHurtSound();
	}
}