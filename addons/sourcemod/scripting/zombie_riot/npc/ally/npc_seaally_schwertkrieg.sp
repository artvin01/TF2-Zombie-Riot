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
		KillFeed_SetKillIcon(npc.index, "fists");

		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);
		
		npc.m_bSelectableByAll = true;
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		npc.m_iOverlordComboAttack = 0;
		
		SDKHook(npc.index, SDKHook_Think, SeaAllyDonnerkrieg_ClotThink);

		npc.m_flSpeed = 330.0;
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/weapons/c_models/c_claidheamohmor/c_claidheamohmor.mdl");	//claidemor
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		float flPos[3]; // original
		float flAng[3]; // original
		
		npc.GetAttachment("eyeglow_L", flPos, flAng);
		npc.m_iWearable2 = ParticleEffectAt_Parent(flPos, "raygun_projectile_blue_crit", npc.index, "eyeglow_L", {0.0,0.0,0.0});
		npc.GetAttachment("root", flPos, flAng);
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/medic/hw2013_das_blutliebhaber/hw2013_das_blutliebhaber.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/all_class/hw2013_the_dark_helm/hw2013_the_dark_helm_medic.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		
		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/medic/sf14_medic_herzensbrecher/sf14_medic_herzensbrecher.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");

		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 150, 150, 255, 255);
		SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable4, 150, 150, 255, 255);
		SetEntityRenderMode(npc.m_iWearable5, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable5, 150, 150, 255, 255);
		SetEntityRenderMode(npc.m_iWearable6, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable6, 150, 150, 255, 255);
		
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
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS");
						npc.PlaySwordSound();
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
								if(npc.m_iOverlordComboAttack > 2)
								{
									if(target > MaxClients && !b_NpcHasDied[target] && !b_CannotBeKnockedUp[target])
									{
										FreezeNpcInTime(target, 1.5);
										
										vecHit = WorldSpaceCenter(target);
										vecHit[2] += 75.0;
										PluginBot_Jump(target, vecHit);
										EmitSoundToAll("mvm/giant_soldier/giant_soldier_rocket_shoot.wav", target, _, 75, _, 0.60);
									}
									
									npc.m_iOverlordComboAttack = 0;
								}
								
								SDKHooks_TakeDamage(target, npc.index, npc.index, Waves_GetRound() * 250.0, DMG_CLUB, -1, _, vecHit);
								npc.PlaySwordHitSound();
								npc.m_iOverlordComboAttack++;
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

		BarrackBody_ThinkMove(npc.index, 330.0, "ACT_MP_IDLE_MELEE_ALLCLASS", "ACT_MP_RUN_MELEE_ALLCLASS", _, _, false);
	}
}

void SeaAllyDonnerkrieg_NPCDeath(int entity)
{
	SeaAllyDonnerkrieg npc = view_as<SeaAllyDonnerkrieg>(entity);
	BarrackBody_NPCDeath(npc.index);
	SDKUnhook(npc.index, SDKHook_Think, SeaAllyDonnerkrieg_ClotThink);
}