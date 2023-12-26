#pragma semicolon 1
#pragma newdecls required

methodmap SeaAllySilvester < BarrackBody
{
	public SeaAllySilvester(float vecPos[3], float vecAng[3])
	{
		SeaAllySilvester npc = view_as<SeaAllySilvester>(BarrackBody(0, vecPos, vecAng, "1000000", "models/player/medic.mdl", STEPTYPE_SEABORN, "0.75", _, "models/pickups/pickup_powerup_regen.mdl", true));
		
		i_NpcInternalId[npc.index] = SEA_ALLY_SILVESTER;
		i_NpcWeight[npc.index] = 2;
		KillFeed_SetKillIcon(npc.index, "fists");

		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);
		
		npc.m_bSelectableByAll = true;
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		npc.m_iOverlordComboAttack = 0;
		
		SDKHook(npc.index, SDKHook_Think, SeaAllySilvester_ClotThink);

		npc.m_flSpeed = 320.0;
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/all_class/bak_buttler/bak_buttler_medic.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/medic/hwn_medic_hat.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/dec17_coldfront_carapace/dec17_coldfront_carapace.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/medic/sbxo2014_medic_wintergarb_coat/sbxo2014_medic_wintergarb_coat.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable5 = npc.EquipItem("head","models/workshop/player/items/medic/sf14_medic_kriegsmaschine_9000/sf14_medic_kriegsmaschine_9000.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", 1);

		npc.m_iWearable7 = npc.EquipItem("head","models/workshop/player/items/medic/cardiologists_camo/cardiologists_camo.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable7, "SetModelScale");
		SetEntProp(npc.m_iWearable7, Prop_Send, "m_nSkin", 1);

		float flPos[3]; // original
		float flAng[3]; // original
		npc.GetAttachment("head", flPos, flAng);
		npc.m_iWearable6 = ParticleEffectAt_Parent(flPos, "unusual_symbols_parent_lightning", npc.index, "head", {0.0,0.0,0.0});
		
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 150, 150, 255, 255);
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, 128, 128, 192, 255);
		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable2, 128, 128, 192, 255);
		SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable3, 128, 128, 192, 255);
		SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable4, 128, 128, 192, 255);
		SetEntityRenderMode(npc.m_iWearable5, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable5, 75, 75, 150, 255);
		SetEntityRenderMode(npc.m_iWearable7, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable7, 150, 150, 255, 255);

		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		for(int client = 1; client <= MaxClients; client++)
		{
			if(IsClientInGame(client) && GetClientTeam(client) > 1)
				Items_GiveNPCKill(client, SEA_ALLY_SILVESTER);
		}

		return npc;
	}
}

public void SeaAllySilvester_ClotThink(int iNPC)
{
	SeaAllySilvester npc = view_as<SeaAllySilvester>(iNPC);
	float GameTime = GetGameTime(iNPC);
	if(BarrackBody_ThinkStart(npc.index, GameTime))
	{
		BarrackBody_ThinkTarget(npc.index, true, GameTime);

		if(npc.m_iTarget > 0)
		{
			float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);
			float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);

			//Target close enough to hit
			if(flDistanceToTarget < 10000 || npc.m_flAttackHappenswillhappen)
			{
				if(npc.m_flNextMeleeAttack < GameTime || npc.m_flAttackHappenswillhappen)
				{
					if(!npc.m_flAttackHappenswillhappen)
					{
						npc.m_flNextRangedSpecialAttack = GameTime + 2.0;
						npc.AddGesture(npc.m_iOverlordComboAttack > 3 ? "ACT_MP_GESTURE_VC_FINGERPOINT_MELEE" : "ACT_MP_ATTACK_STAND_MELEE");
						npc.PlayMeleeSound();
						npc.m_flAttackHappens = GameTime + 0.15;
						npc.m_flAttackHappens_bullshit = GameTime + 0.3;
						npc.m_flNextMeleeAttack = GameTime + (1.2 * npc.BonusFireRate);
						npc.m_flAttackHappenswillhappen = true;
					}
						
					if(npc.m_flAttackHappens < GameTime && npc.m_flAttackHappens_bullshit >= GameTime && npc.m_flAttackHappenswillhappen)
					{
						Handle swingTrace;
						npc.FaceTowards(vecTarget, 20000.0);
						if(npc.DoSwingTrace(swingTrace, npc.m_iTarget))
						{
							int target = TR_GetEntityIndex(swingTrace);	
							
							float vecHit[3];
							TR_GetEndPosition(vecHit, swingTrace);
							
							if(target > 0) 
							{
								if(npc.m_iOverlordComboAttack > 3)
								{
									float flPos[3]; // original
									float flAng[3]; // original
									GetAttachment(npc.index, "effect_hand_l", flPos, flAng);
									int particler = ParticleEffectAt(flPos, "raygun_projectile_blue_crit", 0.25);
									SetParent(npc.index, particler, "effect_hand_l");
									
									npc.m_iOverlordComboAttack = 0;
									SDKHooks_TakeDamage(target, npc.index, npc.index, Waves_GetRound() * 500.0, DMG_CLUB, -1, _, vecHit);
									// Wave 31 = 15000
									// Wave 45 = 20000
									// Wave 60 = 29500

									if(target > MaxClients && !b_thisNpcIsARaid[target] && !b_NpcHasDied[target] && f_TimeFrozenStill[target] < GetGameTime())
									{
										Cryo_FreezeZombie(target);
									}
									else
									{
										npc.PlayMeleeHitSound();
									}
								}
								else
								{
									SDKHooks_TakeDamage(target, npc.index, npc.index, Waves_GetRound() * 250.0, DMG_CLUB, -1, _, vecHit);
									npc.PlayMeleeHitSound();
									npc.m_iOverlordComboAttack++;
								}
							} 
						}

						delete swingTrace;
						npc.m_flAttackHappenswillhappen = false;
					}
					else if(npc.m_flAttackHappens_bullshit < GameTime && npc.m_flAttackHappenswillhappen)
					{
						npc.m_flAttackHappenswillhappen = false;
					}
				}
			}
		}

		BarrackBody_ThinkMove(npc.index, 320.0, "ACT_MP_IDLE_MELEE", "ACT_MP_RUN_MELEE", _, _, false);
	}
}

void SeaAllySilvester_NPCDeath(int entity)
{
	SeaAllySilvester npc = view_as<SeaAllySilvester>(entity);
	BarrackBody_NPCDeath(npc.index);
	SDKUnhook(npc.index, SDKHook_Think, SeaAllySilvester_ClotThink);
}