#pragma semicolon 1
#pragma newdecls required

methodmap SeaAllyGoggles < BarrackBody
{
	public SeaAllyGoggles(float vecPos[3], float vecAng[3])
	{
		SeaAllyGoggles npc = view_as<SeaAllyGoggles>(BarrackBody(0, vecPos, vecAng, "1000000", "models/player/sniper.mdl", STEPTYPE_SEABORN, "0.75", _, "models/pickups/pickup_powerup_regen.mdl", true));
		
		i_NpcInternalId[npc.index] = SEA_ALLY_GOGGLES;
		i_NpcWeight[npc.index] = 1;
		KillFeed_SetKillIcon(npc.index, "huntsman");

		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);
		
		npc.m_bSelectableByAll = true;
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		
		SDKHook(npc.index, SDKHook_Think, SeaAllyGoggles_ClotThink);

		npc.m_flSpeed = 300.0;
		
		float flPos[3]; // original
		float flAng[3]; // original
		npc.GetAttachment("head", flPos, flAng);
		npc.m_iWearable6 = ParticleEffectAt_Parent(flPos, "unusual_symbols_parent_ice", npc.index, "head", {0.0,0.0,0.0});
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/all_class/spr18_antarctic_eyewear/spr18_antarctic_eyewear_scout.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/weapons/c_models/c_bow/c_bow_thief.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/sniper/sum19_wagga_wagga_wear/sum19_wagga_wagga_wear.mdl");
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/sniper/short2014_sniper_cargo_pants/short2014_sniper_cargo_pants.mdl");

		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);

		SetVariantInt(3);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 155, 155, 255, 255);
		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable2, 65, 65, 255, 255);
		SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable4, 155, 155, 255, 255);
		SetEntityRenderMode(npc.m_iWearable5, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable5, 155, 155, 255, 255);
		
		for(int client = 1; client <= MaxClients; client++)
		{
			if(IsClientInGame(client) && GetClientTeam(client) > 1)
				Items_GiveNPCKill(client, SEA_ALLY_GOGGLES);
		}

		return npc;
	}
}

public void SeaAllyGoggles_ClotThink(int iNPC)
{
	SeaAllyGoggles npc = view_as<SeaAllyGoggles>(iNPC);
	float GameTime = GetGameTime(iNPC);
	if(BarrackBody_ThinkStart(npc.index, GameTime))
	{
		BarrackBody_ThinkTarget(npc.index, true, GameTime);

		float vecMe[3]; vecMe = WorldSpaceCenter(npc.index);

		if(npc.m_iTarget > 0)
		{
			float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);
			float flDistanceToTarget = GetVectorDistance(vecTarget, vecMe, true);

			if(flDistanceToTarget < 320000.0)
			{
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				//Target close enough to hit
				if(IsValidEnemy(npc.index, Enemy_I_See))
				{
					//Can we attack right now?
					if(npc.m_flNextMeleeAttack < GameTime)
					{
						npc.m_flSpeed = 0.0;
						npc.FaceTowards(vecTarget, 30000.0);
						npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM2");
						
						npc.PlayRangedSound();
						npc.FireArrow(vecTarget, Waves_GetRound() * 500.0, 1200.0);
						// Wave 31 = 15000
						// Wave 45 = 20000
						// Wave 60 = 29500

						npc.m_flNextMeleeAttack = GameTime + (4.0 * npc.BonusFireRate);
					}
				}
			}
		}

		float pos[3];
		for(int client = 1; client <= MaxClients; client++)
		{
			if(IsClientInGame(client) && IsPlayerAlive(client))
			{
				GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", pos);
				if(GetVectorDistance(vecMe, pos, true) < 100000.0)	// 300 HU
				{
					int maxarmor = MaxArmorCalculation(Armor_Level[client], client, 0.5);
					if(Armor_Charge[client] < maxarmor)
					{
						f_ClientArmorRegen[client] = GetGameTime() + 0.3;
						Armor_Charge[client] += 3;
					}
				}
			}
		}

		BarrackBody_ThinkMove(npc.index, 300.0, "ACT_MP_IDLE_ITEM2", "ACT_MP_RUN_ITEM2", 250000.0, _, false);
	}
}

void SeaAllyGoggles_NPCDeath(int entity)
{
	SeaAllyGoggles npc = view_as<SeaAllyGoggles>(entity);
	BarrackBody_NPCDeath(npc.index);
	SDKUnhook(npc.index, SDKHook_Think, SeaAllyGoggles_ClotThink);
}