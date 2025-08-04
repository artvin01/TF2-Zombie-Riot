#pragma semicolon 1
#pragma newdecls required

static const char g_IdleSound[][] = {
	"vo/heavy_cheers01.mp3",
	"vo/heavy_cheers02.mp3",
	"vo/heavy_cheers04.mp3",
	"vo/heavy_cheers07.mp3",
	"vo/heavy_cheers08.mp3",
};



public void FarmCow_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_IdleSound));	i++) { PrecacheSound(g_IdleSound[i]);	}
	PrecacheModel("models/player/heavy.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Farm Cow");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_heavy_cow_farm");
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return FarmCow(vecPos, vecAng, TFTeam_Red);
}

methodmap FarmCow < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;

		EmitSoundToAll(g_IdleSound[GetRandomInt(0, sizeof(g_IdleSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,GetRandomInt(125, 135));

		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	
	public FarmCow(float vecPos[3], float vecAng[3], int ally)
	{
		//Hardcode them being allies, it would make no sense if they were enemies.
		FarmCow npc = view_as<FarmCow>(CClotBody(vecPos, vecAng, "models/player/heavy.mdl", "1.0", "300", ally, false,_,_,_));
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		SetVariantInt(3);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		int iActivity = npc.LookupActivity("ACT_MP_STAND_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);

		f3_SpawnPosition[npc.index][0] = vecPos[0];
		f3_SpawnPosition[npc.index][1] = vecPos[1];
		f3_SpawnPosition[npc.index][2] = vecPos[2];

		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		//IDLE
		npc.m_bDissapearOnDeath = true;
		npc.m_flSpeed = 120.0;

		npc.m_bisWalking = false;

		func_NPCDeath[npc.index] = FarmCow_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = FarmCow_OnTakeDamage;
		func_NPCThink[npc.index] = FarmCow_ClotThink;
		func_NPCInteract[npc.index] = HeavyCow_Interact;
		
		int skin = GetRandomInt(0, 1);
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/heavy/sf14_halloween_minsk_beef/sf14_halloween_minsk_beef.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
	/*
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/heavy/sf14_fowl_fists/sf14_fowl_fists.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/heavy/sf14_talon_trotters/sf14_talon_trotters.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
*/
		npc.StartPathing();
		
		return npc;
	}
	
}


public void FarmCow_ClotThink(int iNPC)
{
	FarmCow npc = view_as<FarmCow>(iNPC);
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
	
	npc.PlayIdleSound();
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}

	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if(!npc.m_bisWalking) //Dont move, or path. so that he doesnt rotate randomly, also happens when they stop follwing.
	{
		npc.m_flSpeed = 0.0;

		if(npc.m_bPathing)
		{
			npc.StopPathing();
				
		}
	}
	else
	{
		npc.m_flSpeed = 120.0;

		if(!npc.m_bPathing)
			npc.StartPathing();
	}

	float vecTarget[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", vecTarget);

	float fl_DistanceToOriginalSpawn = GetVectorDistance(vecTarget, f3_PositionArrival[npc.index], true);
	if(fl_DistanceToOriginalSpawn < (80.0 * 80.0)) //We are too far away from our home! return!
	{
		npc.m_bisWalking = false;
		npc.SetActivity("ACT_MP_STAND_MELEE");
	}
	
		
	//Roam while idle
		
	//Is it time to pick a new place to go?
	if(npc.m_flNextMeleeAttack < GetGameTime(npc.index))
	{
		//Pick a random goal area
	//	CNavArea RandomArea = PickRandomArea();	
			
	//	if(RandomArea == NULL_AREA) 
	//		return;

		float AproxRandomSpaceToWalkTo[3];

		AproxRandomSpaceToWalkTo[0] = f3_SpawnPosition[npc.index][0];
		AproxRandomSpaceToWalkTo[1] = f3_SpawnPosition[npc.index][1];
		AproxRandomSpaceToWalkTo[2] = f3_SpawnPosition[npc.index][2];

		AproxRandomSpaceToWalkTo[2] += 20.0;

		AproxRandomSpaceToWalkTo[0] = GetRandomFloat((AproxRandomSpaceToWalkTo[0] - 400.0),(AproxRandomSpaceToWalkTo[0] + 400.0));
		AproxRandomSpaceToWalkTo[1] = GetRandomFloat((AproxRandomSpaceToWalkTo[1] - 400.0),(AproxRandomSpaceToWalkTo[1] + 400.0));
		
//		if(!PF_IsPathToVectorPossible(iNPC, AproxRandomSpaceToWalkTo))
//			return;
			

		Handle ToGroundTrace = TR_TraceRayFilterEx(AproxRandomSpaceToWalkTo, view_as<float>( { 90.0, 0.0, 0.0 } ), GetSolidMask(npc.index), RayType_Infinite, BulletAndMeleeTrace, npc.index);
		
		TR_GetEndPosition(AproxRandomSpaceToWalkTo, ToGroundTrace);
		delete ToGroundTrace;

		npc.m_bisWalking = true;

		npc.SetActivity("ACT_MP_RUN_MELEE");

		view_as<CClotBody>(iNPC).StartPathing();
		view_as<CClotBody>(iNPC).SetGoalVector(AproxRandomSpaceToWalkTo);

		f3_PositionArrival[iNPC][0] = AproxRandomSpaceToWalkTo[0];
		f3_PositionArrival[iNPC][1] = AproxRandomSpaceToWalkTo[1];
		f3_PositionArrival[iNPC][2] = AproxRandomSpaceToWalkTo[2];
			
		//Timeout
		npc.m_flNextMeleeAttack = GetGameTime(npc.index) + GetRandomFloat(10.0, 20.0);
	}
}

public Action FarmCow_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	return Plugin_Handled; //IMMORTALITY!!!!!
}

public void FarmCow_NPCDeath(int entity)
{
	FarmCow npc = view_as<FarmCow>(entity);

	//how did you kill it?????????

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}

bool HeavyCow_Interact(int client, int weapon)
{
	bool result;
	int store_entity_number = Store_GetStoreOfEntity(weapon);
	KeyValues kv = TextStore_GetItemKv(store_entity_number);
	if(kv)
	{
		if(kv.GetNum("farm_interact", 0) == 1) //This item can be used to interact with farm animals., it also specificies the type, cow is 1.
		{
			result = true;
			float Farm_Animal_Efficiency = 	kv.GetFloat("farm_efficiency", 0.0);
			//How good it is, 1.0 means it instantly satisfies the animal
				
			int Farm_Animal_Food_Type =	 kv.GetNum("farm_type", 0);

			Farm_Animal_Food_Type -= 1;

			//What type of rewards do we want to give?
			int amount;
			//How much do they have?
			TextStore_GetInv(client, store_entity_number, amount);
			if(amount > 0)
			{
				ClientCommand(client, "playgamesound vo/sandwicheat09.mp3");
				TextStore_SetInv(client, store_entity_number, amount - 1, amount < 2 ? 0 : -1);
				if(amount < 1)
				{
					TF2_RemoveItem(client, weapon);
					SetPlayerActiveWeapon(client, GetPlayerWeaponSlot(client, TFWeaponSlot_Melee));
				}

				switch(Farm_Animal_Food_Type)
				{
					//[0] is cow.
					case 0:
					{
						Animal_Happy[client][0][Farm_Animal_Food_Type] += Farm_Animal_Efficiency;

						while(Animal_Happy[client][0][Farm_Animal_Food_Type] >= 1.0)
						{
							float vecTarget[3];
							GetClientEyePosition(client, vecTarget);
							TextStore_DropNamedItem(client, "Milk", vecTarget, 1); //Drops 1 milk.
							TextStore_DropNamedItem(client, "Seed Bag I", vecTarget, 1); //Drops 1 milk.
							Animal_Happy[client][0][Farm_Animal_Food_Type] -= 1.0;
							switch(GetRandomInt(1,3))
							{
								case 1:
								{
									ClientCommand(client, "playgamesound vo/heavy_thanks01.mp3");
								}
								case 2:
								{
									ClientCommand(client, "playgamesound vo/heavy_thanks02.mp3");
								}
								case 3:
								{
									ClientCommand(client, "playgamesound vo/heavy_thanks03.mp3");
								}
							}
						}
					}
				}
			}
			else
			{
				TF2_RemoveItem(client, weapon);
				SetPlayerActiveWeapon(client, GetPlayerWeaponSlot(client, TFWeaponSlot_Melee));
			}
		}
		else
		{
			result = false;
			switch(GetRandomInt(1,2))
			{
				case 1:
				{
					ClientCommand(client, "playgamesound vo/heavy_no01.mp3");
				}
				case 2:
				{
					ClientCommand(client, "playgamesound vo/heavy_no02.mp3");
				}
			}

		}
	}
	return result;
}