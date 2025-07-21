#pragma semicolon 1
#pragma newdecls required

public void BarrackMonkOnMapStart()
{

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Monk");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_barrack_monk");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
	
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return BarrackMonk(client, vecPos, vecAng);
}


methodmap BarrackMonk < BarrackBody
{
	public void PlayMeleeWarCry()
	{
		return;
	//	EmitSoundToAll("ambient/rottenburg/tunneldoor_open.wav", this.index, _, 60, _, 0.4, 60);
	}
	public BarrackMonk(int client, float vecPos[3], float vecAng[3])
	{
		BarrackMonk npc = view_as<BarrackMonk>(BarrackBody(client, vecPos, vecAng, "750",_,_,_,_,"models/pickups/pickup_powerup_precision.mdl"));
		
		i_NpcWeight[npc.index] = 1;
		KillFeed_SetKillIcon(npc.index, "armageddon");
		

		func_NPCOnTakeDamage[npc.index] = BarrackBody_OnTakeDamage;
		func_NPCDeath[npc.index] = BarrackMonk_NPCDeath;
		func_NPCThink[npc.index] = BarrackMonk_ClotThink;
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
	float GameTime = GetGameTime(npc.index);
	if(BarrackBody_ThinkStart(npc.index,GameTime))
	{
		BarrackBody_ThinkTarget(npc.index, true,GameTime);


		if(npc.m_flAttackHappens)
		{
			npc.AddGesture("ACT_MONK_ATTACK", false);
			if(npc.m_flAttackHappens < GameTime)
			{
				float vecTarget[3]; WorldSpaceCenter(npc.index, vecTarget);
				
				npc.m_flAttackHappens = 0.0;
				spawnRing_Vectors(vecTarget, MONK_MAXRANGE_ALLY * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 255, 125, 125, 255, 1, 3.0, 5.0, 3.1, 1, _);		
				
				DataPack pack;
				CreateDataTimer(0.25, MonkHealDamageZone, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				pack.WriteFloat(GameTime + 3.0);
				pack.WriteFloat(vecTarget[0]);
				pack.WriteFloat(vecTarget[1]);
				pack.WriteFloat(vecTarget[2]);
				pack.WriteCell(true);
				pack.WriteCell(EntIndexToEntRef(npc.index));
			}
		}

		if(GameTime > npc.m_flNextMeleeAttack)
		{
			npc.PlayMeleeWarCry();
			npc.AddGesture("ACT_MONK_ATTACK");
			
			npc.m_flAttackHappens = GameTime + 1.3;
			npc.m_flDoingAnimation = GameTime + 1.3;
			npc.m_flReloadDelay = GameTime + 1.3;
			npc.m_flNextMeleeAttack = GameTime + 8.3;
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