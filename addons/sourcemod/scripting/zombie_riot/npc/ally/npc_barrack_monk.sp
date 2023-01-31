#pragma semicolon 1
#pragma newdecls required

methodmap BarrackMonk < BarrackBody
{
	public void PlayMeleeWarCry()
	{
		EmitSoundToAll("ambient/rottenburg/tunneldoor_open.wav", this.index, _, 90, _, 0.4, 60);
	}
	public BarrackMonk(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		BarrackMonk npc = view_as<BarrackMonk>(BarrackBody(client, vecPos, vecAng, "400"));
		
		i_NpcInternalId[npc.index] = BARRACK_MONK;
		
		SDKHook(npc.index, SDKHook_Think, BarrackMonk_ClotThink);

		npc.m_flSpeed = 175.0;

		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/workshop_partner/weapons/c_models/c_tw_eagle/c_tw_eagle.mdl");
		SetVariantString("1.15");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		return npc;
	}
}

public void BarrackMonk_ClotThink(int iNPC)
{
	BarrackMonk npc = view_as<BarrackMonk>(iNPC);
	if(BarrackBody_ThinkStart(npc.index))
	{
		BarrackBody_ThinkTarget(npc.index, true);

		float gameTime = GetGameTime(npc.index);
		if(npc.m_flAttackHappens)
		{
			npc.AddGesture("ACT_MONK_ATTACK", false);
			if(npc.m_flAttackHappens < gameTime)
			{
				float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.index);
				
				npc.m_flAttackHappens = 0.0;
				spawnRing_Vectors(vecTarget, MONK_MAXRANGE * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 125, 125, 255, 255, 1, 3.0, 5.0, 3.1, 1, _);		
				
				DataPack pack;
				CreateDataTimer(0.1, MonkHealDamageZone, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				pack.WriteFloat(GetGameTime() + 3.0);
				pack.WriteFloat(vecTarget[0]);
				pack.WriteFloat(vecTarget[1]);
				pack.WriteFloat(vecTarget[2]);
				pack.WriteCell(true);
				pack.WriteCell(EntIndexToEntRef(npc.index));
			}
		}

		if(gameTime > npc.m_flNextMeleeAttack)
		{
			npc.PlayMeleeWarCry();
			npc.AddGesture("ACT_MONK_ATTACK");
			
			npc.m_flAttackHappens = gameTime + 1.3;
			npc.m_flDoingAnimation = gameTime + 1.3;
			npc.m_flReloadDelay = gameTime + 1.3;
			npc.m_flNextMeleeAttack = gameTime + 9.3;
		}

		BarrackBody_ThinkMove(npc.index, 175.0, "ACT_MONK_IDLE", "ACT_MONK_WALK", 90000.0);
	}
}

void BarrackMonk_NPCDeath(int entity)
{
	BarrackMonk npc = view_as<BarrackMonk>(entity);
	BarrackBody_NPCDeath(npc.index);
	SDKUnhook(npc.index, SDKHook_Think, BarrackMonk_ClotThink);
}