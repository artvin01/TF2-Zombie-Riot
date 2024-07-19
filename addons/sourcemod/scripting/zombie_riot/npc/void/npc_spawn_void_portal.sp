#pragma semicolon 1
#pragma newdecls required

void VoidPortal_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Void Portal");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_void_portal");
	strcopy(data.Icon, sizeof(data.Icon), "militia");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Void;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return VoidPortal(client, vecPos, vecAng, ally);
}
methodmap VoidPortal < CClotBody
{
	public VoidPortal(int client, float vecPos[3], float vecAng[3], int ally)
	{
		VoidPortal npc = view_as<VoidPortal>(CClotBody(vecPos, vecAng, "models/empty.mdl", "0.8", "700", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");

		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_VOID;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(VoidPortal_NPCDeath);
		func_NPCThink[npc.index] = view_as<Function>(VoidPortal_ClotThink);
		//This is a dummy npc, it gets slain instantly.
		EmitSoundToAll("npc/combine_gunship/see_enemy.wav", _, _, _, _, 1.0);	
		EmitSoundToAll("npc/combine_gunship/see_enemy.wav", _, _, _, _, 1.0);	
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "voice_player", 1, "%t", "A Void Gate Apeared...");
			}
		}
		TeleportDiversioToRandLocation(npc.index);
		
		return npc;
	}
}

public void VoidPortal_ClotThink(int iNPC)
{
	VoidPortal npc = view_as<VoidPortal>(iNPC);
	SmiteNpcToDeath(iNPC);

}

public void VoidPortal_NPCDeath(int entity)
{
	VoidPortal npc = view_as<VoidPortal>(entity);
	float VecSelfNpcabs[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", VecSelfNpcabs);
	//a spawnpoint that only lasts for 1 spawn
	Void_PlaceZRSpawnpoint(VecSelfNpcabs, 2, 2000000000, "utaunt_portalswirl_purple_parent", 45, true);
}

void VoidPortalSelfDefense(VoidPortal npc, float gameTime, int target, float distance)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
			{
							
				target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 35.0;

					if(!NpcStats_IsEnemySilenced(npc.index))
					{
						if(target > MaxClients)
						{
							StartBleedingTimer_Against_Client(target, npc.index, 4.0, 5);
						}
						else
						{
							if (!IsInvuln(target))
							{
								StartBleedingTimer_Against_Client(target, npc.index, 4.0, 5);
							}
						}
					}
					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);

					// Hit sound
					npc.PlayMeleeHitSound();
				} 
			}
			delete swingTrace;
		}
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
		{
			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE",_,_,_,0.75);
						
				npc.m_flAttackHappens = gameTime + 0.25;
				npc.m_flDoingAnimation = gameTime + 0.25;
				npc.m_flNextMeleeAttack = gameTime + 1.2;
			}
		}
	}
}