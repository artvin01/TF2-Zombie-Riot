#pragma semicolon 1
#pragma newdecls required

methodmap SeaAllyDonnerkrieg < BarrackBody
{
	public void PlayRangedSound()
	{
		EmitSoundToAll("weapons/capper_shoot.wav", this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public SeaAllyDonnerkrieg(float vecPos[3], float vecAng[3])
	{
		SeaAllyDonnerkrieg npc = view_as<SeaAllyDonnerkrieg>(BarrackBody(0, vecPos, vecAng, "1000000", "models/player/medic.mdl", STEPTYPE_SEABORN, "0.75", _, "models/pickups/pickup_powerup_regen.mdl", true));
		
		i_NpcInternalId[npc.index] = SEA_ALLY_DONNERKRIEG;
		i_NpcWeight[npc.index] = 2;
		KillFeed_SetKillIcon(npc.index, "merasmus_zap");

		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);
		
		npc.m_bSelectableByAll = true;
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		npc.m_iOverlordComboAttack = 0;
		
		SDKHook(npc.index, SDKHook_Think, SeaAllyDonnerkrieg_ClotThink);

		npc.m_flSpeed = 300.0;
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/medic/Sbox2014_Medic_Colonel_Coat/Sbox2014_Medic_Colonel_Coat.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/xms2013_medic_hood/xms2013_medic_hood.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		float flPos[3]; // original
		float flAng[3]; // original
					
		npc.GetAttachment("effect_hand_l", flPos, flAng);
		npc.m_iWearable1 = ParticleEffectAt_Parent(flPos, "raygun_projectile_blue_crit", npc.index, "effect_hand_l", {0.0,0.0,0.0});
		
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 150, 150, 255, 255);
		SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable3, 150, 150, 255, 255);
		SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable4, 150, 150, 255, 255);
		
		for(int client = 1; client <= MaxClients; client++)
		{
			if(IsClientInGame(client) && GetClientTeam(client) > 1)
				Items_GiveNPCKill(client, SEA_ALLY_DONNERKRIEG);
		}

		return npc;
	}
}

public void SeaAllyDonnerkrieg_ClotThink(int iNPC)
{
	SeaAllyDonnerkrieg npc = view_as<SeaAllyDonnerkrieg>(iNPC);
	float GameTime = GetGameTime(iNPC);
	if(BarrackBody_ThinkStart(npc.index, GameTime))
	{
		BarrackBody_ThinkTarget(npc.index, true, GameTime);

		if(npc.m_iTarget > 0)
		{
			NpcStats_SilenceEnemy(npc.m_iTarget, 6.0);
			
			float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);
			float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);

			if(flDistanceToTarget < 170000.0)
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
						npc.AddGesture("ACT_MP_THROW");
						
						npc.PlayRangedSound();

						float flPos[3]; // original
						float flAng[3]; // original
						GetAttachment(npc.index, "effect_hand_r", flPos, flAng);
						
						npc.FireParticleRocket(vecTarget, Waves_GetRound() * 300.0, 400.0, 100.0, 850.0 , 100.0 , "raygun_projectile_blue_crit", _, false, true, flPos);
						// Wave 16 = 4500
						// Wave 30 = 8750
						// Wave 45 = 13200
						// Wave 60 = 17700

						npc.m_flNextMeleeAttack = GameTime + (2.5 * npc.BonusFireRate);
						npc.m_flReloadDelay = GameTime + (1.0 * npc.BonusFireRate);
					}
				}
			}
		}

		BarrackBody_ThinkMove(npc.index, 300.0, "ACT_MP_IDLE_MELEE", "ACT_MP_RUN_MELEE", 170000.0, _, false);
	}
}

void SeaAllyDonnerkrieg_NPCDeath(int entity)
{
	SeaAllyDonnerkrieg npc = view_as<SeaAllyDonnerkrieg>(entity);
	BarrackBody_NPCDeath(npc.index);
	SDKUnhook(npc.index, SDKHook_Think, SeaAllyDonnerkrieg_ClotThink);
}