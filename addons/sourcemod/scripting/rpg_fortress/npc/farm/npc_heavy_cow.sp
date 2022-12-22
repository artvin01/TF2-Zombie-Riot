#pragma semicolon 1
#pragma newdecls required

static const char g_IdleSound[][] = {
	"vo/taunts/heavy_taunts19.mp3",
	"vo/taunts/heavy_taunts20.mp3",
	"vo/taunts/heavy_taunts21.mp3",
	"vo/taunts/heavy_taunts22.mp3",
};

static const char g_HurtSound[][] = {
	"vo/heavy_painsharp01.mp3",
	"vo/heavy_painsharp02.mp3",
	"vo/heavy_painsharp03.mp3",
	"vo/heavy_painsharp04.mp3",
	"vo/heavy_painsharp05.mp3",
	"vo/heavy_painsharp06.mp3",
	"vo/heavy_painsharp07.mp3",
	"vo/heavy_painsharp08.mp3",
};


public void FarmCow_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_IdleSound));	i++) { PrecacheSound(g_IdleSound[i]);	}
	for (int i = 0; i < (sizeof(g_HurtSound));	i++) { PrecacheSound(g_HurtSound[i]);	}
	PrecacheModel("models/player/heavy.mdl");
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
	
	public void PlayHurtSound() {
		
		EmitSoundToAll(g_HurtSound[GetRandomInt(0, sizeof(g_HurtSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,GetRandomInt(125, 135));
		
	}
	
	
	public FarmCow(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		//Hardcode them being allies, it would make no sense if they were enemies.
		FarmCow npc = view_as<FarmCow>(CClotBody(vecPos, vecAng, "models/player/heavy.mdl", "1.0", "300", true, false,_,_,_));
		
		i_NpcInternalId[npc.index] = FARM_COW;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
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

		SDKHook(npc.index, SDKHook_OnTakeDamage, FarmCow_OnTakeDamage);
		SDKHook(npc.index, SDKHook_Think, FarmCow_ClotThink);
		
		int skin = GetRandomInt(0, 1);
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
/*
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/heavy/sf14_nugget_noggin/sf14_nugget_noggin.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);

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

//TODO 
//Rewrite
static float f3_PositionArrival[MAXENTITIES][3];
public void FarmCow_ClotThink(int iNPC)
{
	FarmCow npc = view_as<FarmCow>(iNPC);
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
		npc.m_flNextMeleeAttack = 0.0; //Run!!
	}
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
			PF_StopPathing(npc.index);
			npc.m_bPathing = false;	
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
	if(fl_DistanceToOriginalSpawn < Pow(80.0, 2.0)) //We are too far away from our home! return!
	{
		npc.m_bisWalking = false;
		npc.SetActivity("ACT_MP_STAND_MELEE");
	}
	
		
	//Roam while idle
		
	//Is it time to pick a new place to go?
	if(npc.m_flNextMeleeAttack < GetGameTime(npc.index))
	{
		//Pick a random goal area
	//	NavArea RandomArea = PickRandomArea();	
			
	//	if(RandomArea == NavArea_Null) 
	//		return;

		float AproxRandomSpaceToWalkTo[3];

		AproxRandomSpaceToWalkTo[0] = f3_SpawnPosition[npc.index][0];
		AproxRandomSpaceToWalkTo[1] = f3_SpawnPosition[npc.index][1];
		AproxRandomSpaceToWalkTo[2] = f3_SpawnPosition[npc.index][2];

		AproxRandomSpaceToWalkTo[2] += 20.0;

		AproxRandomSpaceToWalkTo[0] = GetRandomFloat((AproxRandomSpaceToWalkTo[0] - 400.0),(AproxRandomSpaceToWalkTo[0] + 400.0));
		AproxRandomSpaceToWalkTo[1] = GetRandomFloat((AproxRandomSpaceToWalkTo[1] - 400.0),(AproxRandomSpaceToWalkTo[1] + 400.0));
		
		if(!PF_IsPathToVectorPossible(iNPC, AproxRandomSpaceToWalkTo))
			return;
			

		Handle ToGroundTrace = TR_TraceRayFilterEx(AproxRandomSpaceToWalkTo, view_as<float>( { 90.0, 0.0, 0.0 } ), npc.GetSolidMask(), RayType_Infinite, BulletAndMeleeTrace, npc.index);
		
		TR_GetEndPosition(AproxRandomSpaceToWalkTo, ToGroundTrace);
		delete ToGroundTrace;

		npc.m_bisWalking = true;

		npc.SetActivity("ACT_MP_RUN_MELEE");

		PF_SetGoalVector(iNPC, AproxRandomSpaceToWalkTo);
		PF_StartPathing(iNPC);

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

	SDKUnhook(entity, SDKHook_OnTakeDamage, FarmCow_OnTakeDamage);
	SDKUnhook(entity, SDKHook_Think, FarmCow_ClotThink);

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}

void HeavyCow_Interact(int client, int entity, int weapon)
{
	int store_entity_number = Store_GetStoreOfEntity(weapon);
	KeyValues kv = TextStore_GetItemKv(store_entity_number);
	if(kv)
	{
		if(kv.GetNum("farm_interact", 0) == 1) //This item can be used to interact with farm animals., it also specificies the type, cow is 1.
		{
			float Farm_Animal_Efficiency = 	kv.GetFloat("farm_efficiency", 0.0);
			//How good it is, 1.0 means it instantly satisfies the animal
				
			int Farm_Animal_Food_Type =	 kv.GetNum("farm_type", 0);

			Farm_Animal_Food_Type -= 1;

			//What type of rewards do we want to give?
			int amount;
			//How much do they have?
			TextStore_GetInv(client, store_entity_number, amount);
			PrintToChatAll("%i",amount);
			if(amount > 0)
			{
				TextStore_SetInv(client, store_entity_number, amount - 1, amount < 2 ? 0 : -1);
				if(amount < 2)
				{
					TF2_RemoveItem(client, weapon);
					Store_SwapToItem(client, GetPlayerWeaponSlot(client, TFWeaponSlot_Melee));
				}

				switch(Farm_Animal_Food_Type)
				{
					case 0:
					{
						Animal_Happy[client][Farm_Animal_Food_Type] += Farm_Animal_Efficiency;

						while(Animal_Happy[client][Farm_Animal_Food_Type] >= 1.0)
						{
							Animal_Happy[client][Farm_Animal_Food_Type] -= 1.0;
							PrintToChatAll("Thank you!");
						}
					}
				}
			}
			else
			{
				TF2_RemoveItem(client, weapon);
				Store_SwapToItem(client, GetPlayerWeaponSlot(client, TFWeaponSlot_Melee));
				PrintToChat(client, "Your item somehow vanished!");
			}
		}
		else
		{
			PrintToChat(client,"I dont want this.");
		}
	}
}