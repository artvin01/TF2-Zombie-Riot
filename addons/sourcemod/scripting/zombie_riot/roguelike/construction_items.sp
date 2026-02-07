#pragma semicolon 1
#pragma newdecls required

static int HardMode;

float ConstructionItems_OddIncrease()
{
	return HardMode ? 1.5 : 1.0;
}

public void Construction_Stalker_Collect()
{
	/*
	float pos[3], ang[3];
	
	Spawns_GetNextPos(pos, ang, "spawn_1_3");
	NPC_CreateByName("npc_stalker_wisp", 0, pos, ang, TFTeam_Blue);
	
	Spawns_GetNextPos(pos, ang, "spawn_2_3");
	NPC_CreateByName("npc_stalker_combine", 0, pos, ang, TFTeam_Blue);

	Spawns_GetNextPos(pos, ang, "spawn_3_4");
	NPC_CreateByName("npc_stalker_goggles", 0, pos, ang, TFTeam_Blue);
	*/

	Construction_AddMaterial("wizuh", 50, true);
}

public void Construction_Stalker_Ally(int entity, StringMap map)
{
	if(!b_NpcHasDied[entity])	// NPCs
	{
		if(Citizen_IsIt(entity))	// Rebel
		{
			Citizen npc = view_as<Citizen>(entity);

			npc.m_fGunBonusReload *= 0.9;
			npc.m_fGunBonusFireRate *= 0.9;
		}
		else
		{
			BarrackBody npc = view_as<BarrackBody>(entity);
			if(npc.OwnerUserId)	// Barracks Unit
				npc.BonusFireRate /= 0.9;
		}
	}
}

public void Construction_Stalker_Weapon(int entity)
{
	RogueHelp_WeaponAPSD(entity, 1.1);
}

public void Construction_HeavyOre_Collect()
{
	Construction_AddMaterial("jalan", 50, true);
}

public void Construction_HeavyOre_Enemy(int entity)
{
	if(i_NpcIsABuilding[entity])
	{
		SetEntProp(entity, Prop_Data, "m_iHealth", RoundFloat(GetEntProp(entity, Prop_Data, "m_iHealth") * 1.15));
		SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundFloat(ReturnEntityMaxHealth(entity) * 1.15));
	}
}

public void Construction_Stalker_Enemy(int entity)
{
	fl_Extra_Damage[entity] *= 1.1;
}

public void Construction_CarStart_Collect()
{
	HardMode++;
	Construction_AddMaterial("ossunia", 50, true);
	Construction_AddMaterial("iron", 15, true);
	Construction_GiveNamedResearch("Base Level I", true);
	Construction_GiveNamedResearch("Vehicle Factory", true);
}

public void Construction_VoidStart_Collect()
{
	HardMode++;
}

public void Construction_HardMode_Remove()
{
	HardMode--;
}

// Health+
public void Construction_H_Ally(int entity, StringMap map)
{
	RogueHelp_BodyHealth(entity, map, 1.05);
}

// Health++ Speed-
public void Construction_HS_Ally(int entity, StringMap map)
{
	RogueHelp_BodyHealth(entity, map, 1.1);
	RogueHelp_BodySpeed(entity, map, 0.99);
}

// Health++ Damage-
public void Construction_HD_Ally(int entity, StringMap map)
{
	RogueHelp_BodyHealth(entity, map, 1.1);
	RogueHelp_BodyDamage(entity, map, 0.95);
}

// Health++ ASPD-
public void Construction_HA_Ally(int entity, StringMap map)
{
	RogueHelp_BodyHealth(entity, map, 1.1);
	RogueHelp_BodyAPSD(entity, map, 0.95);
}

// Health++
public void Construction_H0_Ally(int entity, StringMap map)
{
	RogueHelp_BodyHealth(entity, map, 1.1);
}

// Speed+
public void Construction_S_Ally(int entity, StringMap map)
{
	RogueHelp_BodySpeed(entity, map, 1.01);
}

public void FlagShipCalling(int entity, StringMap map)
{
	RogueHelp_BodySpeed(entity, map, 1.1);
	ApplyStatusEffect(entity, entity, "Ziberian Flagship Weaponry", 9999999.9);
}

// Speed++ Health-
public void Construction_SH_Ally(int entity, StringMap map)
{
	RogueHelp_BodySpeed(entity, map, 1.02);
	RogueHelp_BodyHealth(entity, map, 0.95);
}

// Damage+
public void Construction_D_Ally(int entity, StringMap map)
{
	RogueHelp_BodyDamage(entity, map, 1.05);
}
public void Construction_D0_Ally(int entity, StringMap map)
{
	RogueHelp_BodyDamage(entity, map, 1.1);
}
public void Construction_D_Weapon(int entity)
{
	RogueHelp_WeaponDamage(entity, 1.05);
}
public void Construction_D0_Weapon(int entity)
{
	RogueHelp_WeaponDamage(entity, 1.1);
}
public void Construction_0D_Weapon(int entity)
{
	RogueHelp_WeaponDamage(entity, 0.95);
}

// Damage++ Speed-
public void Construction_DS_Ally(int entity, StringMap map)
{
	RogueHelp_BodyDamage(entity, map, 1.1);
	RogueHelp_BodySpeed(entity, map, 0.99);
}

// APSD+
public void Construction_A_Ally(int entity, StringMap map)
{
	RogueHelp_BodyAPSD(entity, map, 1.05);
}
public void Construction_A_Weapon(int entity)
{
	RogueHelp_WeaponAPSD(entity, 1.05);
}
public void Construction_A0_Weapon(int entity)
{
	RogueHelp_WeaponAPSD(entity, 1.1);
}
public void Construction_0A_Weapon(int entity)
{
	RogueHelp_WeaponAPSD(entity, 0.95);
}

// APSD++ Health-
public void Construction_AH_Ally(int entity, StringMap map)
{
	RogueHelp_BodyAPSD(entity, map, 1.1);
	RogueHelp_BodyHealth(entity, map, 0.95);
}

public void Construction_BadExpi_Collect()
{
	if(!Construction_FinalBattle())
		CreateTimer(4.0, Timer_DialogueNewEnd, 0, TIMER_FLAG_NO_MAPCHANGE);
}

static Action Timer_DialogueNewEnd(Handle timer, int part)
{
	switch(part)
	{
		case 0:
		{
			if(Dungeon_Mode())
				CPrintToChatAll("{crimson}여긴 처음 생존 연산이 진행된 곳이지만, 지금은 단지 게임플레이를 위해 있을 뿐입니다.");
			
			CPrintToChatAll("{black}???{default}: 하. 그따위 함정에도 속아넘어가다니.");
		}
		case 1:
		{
			CPrintToChatAll("{black}???{default}: 덕분에 네놈의 위치가 어딘지 알아냈다.");
		}
		case 2:
		{
			CPrintToChatAll("{black}???{default}: 거기 가만히 있어라. 네 목을 가지러 갈테니.");
		}
		case 3:
		{
			CPrintToChatAll("{black}???{default}: 오직 엑스피돈사만이 아를린의 유일한 종족으로 남아야만한다.");
		}
		case 4:
		{
			CPrintToChatAll("{black}???{default}: 그러니까 이제 그만 죽어라. 하등한 놈들아.");
		}
		default:
		{
			Rogue_GiveNamedArtifact("System Malfunction");
			return Plugin_Continue;
		}
	}

	CreateTimer(2.0, Timer_DialogueNewEnd, part + 1, TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Continue;
}

public void Construction_Barney_Collect()
{
	Citizen_SpawnAtPoint("b");
	SpawnRebel();
}

public void Construction_Rebel_Collect()
{
	SpawnRebel();
}

public void Construction_Alyx_Collect()
{
	SpawnRebel("a");
}

public void GiveCash_Base1()
{
	CurrentCash += 500;
	GlobalExtraCash += 500;
	CPrintToChatAll("%t", "Gained Material", 500, "Cash");
}
public void GiveCash_Base2()
{
	CurrentCash += 1500;
	GlobalExtraCash += 1500;
	CPrintToChatAll("%t", "Gained Material", 1500, "Cash");
}
public void GiveCash_Base3()
{
	CurrentCash += 3000;
	GlobalExtraCash += 3000;
	CPrintToChatAll("%t", "Gained Material", 3000, "Cash");
}
public void GiveCash_Base4()
{
	CurrentCash += 5000;
	GlobalExtraCash += 5000;
	CPrintToChatAll("%t", "Gained Material", 5000, "Cash");
}
public void GiveCash_2000()
{
	CurrentCash += 2000;
	GlobalExtraCash += 2000;
	CPrintToChatAll("%t", "Gained Material", 2000, "Cash");
}
static void SpawnRebel(const char[] data = "")
{
	float pos[3], ang[3];
	for(int i; i < ZR_MAX_SPAWNERS; i++)
	{
		if(IsValidEntity(i_ObjectsSpawners[i]) && GetEntProp(i_ObjectsSpawners[i], Prop_Data, "m_iTeamNum") == TFTeam_Red && !GetEntProp(i_ObjectsSpawners[i], Prop_Data, "m_bDisabled"))
		{
			GetEntPropVector(i_ObjectsSpawners[i], Prop_Data, "m_vecOrigin", pos);
			GetEntPropVector(i_ObjectsSpawners[i], Prop_Data, "m_angRotation", ang);
			break;
		}
	}

	CNavArea goalArea = TheNavMesh.GetNavArea(pos, 1000.0);
	if(goalArea == NULL_AREA)
	{
		PrintToChatAll("ERROR: Could not find valid nav area for location (%f %f %f)", pos[0], pos[1], pos[2]);
		return;
	}
	
	for(int i; i < 50; i++)
	{
		CNavArea startArea = PickRandomArea();
		if(startArea == NULL_AREA)
			continue;
		
		if(startArea.GetAttributes() & (NAV_MESH_AVOID|NAV_MESH_DONT_HIDE))
			continue;
		
		if(!TheNavMesh.BuildPath(startArea, goalArea, pos))
			continue;
		
		startArea.GetCenter(pos);
		pos[2] += 10.0;
		ang[0] = 0.0;
		ang[1] = float(GetURandomInt() % 360);
		ang[2] = 0.0;

		NPC_CreateByName("npc_citizen", 0, pos, ang, TFTeam_Red, data);
		break;
	}
}

public void Construction_RareWeapon_Collect()
{
	char name[64];
	float discount = 0.7;

	switch(GetURandomInt() % 6)
	{
		case 0, 1:
		{
			strcopy(name, sizeof(name), "Vows of the Sea");
			discount = 0.5;
		}
	//	case 2:
	//	{
	//		strcopy(name, sizeof(name), "Infinity Blade");
	//		discount = 0.5;
	//	}
		case 2, 3:
		{
			strcopy(name, sizeof(name), "Whistle Stop");
		}
		case 4, 5:
		{
			strcopy(name, sizeof(name), "Ancestor Launcher");
		}
	}

	Store_DiscountNamedItem(name, 999, discount);
	CPrintToChatAll("{green}Recovered Items: {palegreen}%s", name);
}




public void Xeno_Resurgance_Enemy(int entity)
{
	if(i_NpcIsABuilding[entity])
		return;

	if(view_as<CClotBody>(entity).m_iBleedType != BLEEDTYPE_XENO)
		ApplyStatusEffect(entity, entity, "Xeno Infection", 9999.9);
	else
		ApplyStatusEffect(entity, entity, "Xeno Infection Buff Only", 9999.9);
}
public void Xeno_Resurgance_End()
{
	Rogue_RemoveNamedArtifact("Xeno Resurgance");
}