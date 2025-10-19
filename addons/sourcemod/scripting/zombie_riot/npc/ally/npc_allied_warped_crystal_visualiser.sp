#pragma semicolon 1
#pragma newdecls required

void AlliedWarpedCrystal_Visualiser_OnMapStart_NPC()
{
	PrecacheModel("models/weapons/c_models/c_claymore/c_claymore.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "nothing");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_allied_warped_crystal_visualiser");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3],int team)
{
	return AlliedWarpedCrystal_Visualiser(client, vecPos, vecAng, team);
}
methodmap AlliedWarpedCrystal_Visualiser < CClotBody
{
	public AlliedWarpedCrystal_Visualiser(int client, float vecPos[3], float vecAng[3], int team)
	{
		AlliedWarpedCrystal_Visualiser npc = view_as<AlliedWarpedCrystal_Visualiser>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "100", team, true));
		
		i_NpcWeight[npc.index] = 999;
		SetEntPropEnt(npc.index,   Prop_Send, "m_hOwnerEntity", client);
		f_PreventMovementClient[client] = GetGameTime() + 0.35;
		Store_ApplyAttribs(client); //update.
		
		int ModelIndex;
		char ModelPath[255];
		int entity, i;
			
		if((i_CustomModelOverrideIndex[client] < BARNEY || !b_HideCosmeticsPlayer[client]))
		{
			SetEntityRenderMode(npc.index, RENDER_TRANSALPHA);
			SetEntityRenderColor(npc.index, 0, 0, 0, 0);
		}
		else
		{
			SetEntityRenderMode(npc.index, RENDER_TRANSALPHA);
			SetEntityRenderColor(npc.index, 255, 255, 255, 125);
		}
		TF2_RemoveCondition(client, TFCond_Taunting);


		SetVariantInt(GetEntProp(client, Prop_Send, "m_nBody"));
		AcceptEntityInput(npc.index, "SetBodyGroup");


		while(TF2U_GetWearable(client, entity, i, "tf_wearable"))
		{

			if(entity == EntRefToEntIndex(Armor_Wearable[client]) || i_WeaponVMTExtraSetting[entity] != -1)
				continue;
				
			if(EntRefToEntIndex(i_Viewmodel_PlayerModel[client]) != entity || (i_CustomModelOverrideIndex[client] < BARNEY || !b_HideCosmeticsPlayer[client]))
			{
				ModelIndex = GetEntProp(entity, Prop_Data, "m_nModelIndex");
				if(ModelIndex < 0)
				{
					GetEntPropString(entity, Prop_Data, "m_ModelName", ModelPath, sizeof(ModelPath));
				}
				else
				{
					ModelIndexToString(ModelIndex, ModelPath, sizeof(ModelPath));
				}
			}
			if(!ModelPath[0])
				continue;

			for(int Repeat=1; Repeat<7; Repeat++)
			{
				int WearableIndex = i_Wearable[npc.index][Repeat];
				if(!IsValidEntity(WearableIndex))
				{	
					int WearablePostIndex = npc.EquipItem("head", ModelPath);
					if(IsValidEntity(WearablePostIndex))
					{	
						if(entity == EntRefToEntIndex(i_Viewmodel_PlayerModel[client]))
						{
							SetVariantInt(GetEntProp(client, Prop_Send, "m_nBody"));
							AcceptEntityInput(WearablePostIndex, "SetBodyGroup");
						}
						SetEntityRenderColor(WearablePostIndex, 255, 255, 255, 255);
						i_Wearable[npc.index][Repeat] = EntIndexToEntRef(WearablePostIndex);
					}
					break;
				}
			}
		}
		float offsetToHeight = 40.0;
		npc.m_iWearable9 = npc.EquipItemSeperate("models/props_moonbase/moon_gravel_crystal_blue.mdl",_,_,_,offsetToHeight);
		SetVariantString("2.5");
		AcceptEntityInput(npc.m_iWearable9, "SetModelScale");
	//	SetEntityRenderMode(npc.m_iWearable9, RENDER_TRANSCOLOR);
	//	SetEntityRenderColor(npc.m_iWearable9, 25, 25, 25, 200);
		SetEntityRenderColor(npc.m_iWearable9, 25, 25, 25, 255);
		npc.m_bisWalking = false;
	
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_bDissapearOnDeath = true;
		b_NoKnockbackFromSources[npc.index] = true;
		npc.m_bNoKillFeed = true;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;

		npc.AddActivityViaSequence("dieviolent");
		npc.SetCycle(0.5);
		npc.SetPlaybackRate(0.0);

		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		b_NpcIsInvulnerable[npc.index] = true;
		ApplyStatusEffect(npc.index, npc.index, "Clear Head", 999999.0);	
		func_NPCDeath[npc.index] = AlliedWarpedCrystal_Visualiser_NPCDeath;
		func_NPCThink[npc.index] = AlliedWarpedCrystal_Visualiser_ClotThink;

		npc.m_flSpeed = 0.0;
		
		npc.m_flMeleeArmor = 1.0;
		npc.m_flRangedArmor = 1.0;

		npc.StopPathing();
		b_DoNotUnStuck[npc.index] = true;
		b_NoGravity[npc.index] = true;
		npc.m_flAttackHappens = 1.0;
		SetEntityCollisionGroup(npc.index, 1); //Dont Touch Anything.
		SetEntProp(npc.index, Prop_Send, "m_usSolidFlags", 12); 
		SetEntProp(npc.index, Prop_Data, "m_nSolidType", 6); 
		if(IsValidEntity(npc.m_iTeamGlow))
			RemoveEntity(npc.m_iTeamGlow);
			
		int Outline = EntRefToEntIndex(i_DyingParticleIndication[client][0]);
		if(IsValidEntity(Outline))
			RemoveEntity(Outline);

		return npc;
	}
}


public void AlliedWarpedCrystal_Visualiser_ClotThink(int iNPC)
{
	AlliedWarpedCrystal_Visualiser npc = view_as<AlliedWarpedCrystal_Visualiser>(iNPC);

	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
		return;
	
	int Owner = GetEntPropEnt(iNPC, Prop_Send, "m_hOwnerEntity");
	if(!IsValidEntity(Owner))
	{
		RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
		return;
	}
	if(!IsPlayerAlive(Owner))
	{
		RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
		return;
	}
	f_PreventMovementClient[Owner] = GetGameTime() + 0.35;
	float origin_owner[3];
	GetEntPropVector(Owner, Prop_Data, "m_vecAbsOrigin", origin_owner);
	SDKCall_SetLocalOrigin(iNPC, origin_owner);
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	//revived.
	if(dieingstate[Owner] == 0)
	{
		LeperReturnToNormal(Owner, -1, 0);
		RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
		f_PreventMovementClient[Owner] = 0.0;
		Store_ApplyAttribs(Owner);
		Store_GiveAll(Owner, GetClientHealth(Owner));
	}
}

public void AlliedWarpedCrystal_Visualiser_NPCDeath(int entity)
{
	AlliedWarpedCrystal_Visualiser npc = view_as<AlliedWarpedCrystal_Visualiser>(entity);

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
	
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);

	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);
}
