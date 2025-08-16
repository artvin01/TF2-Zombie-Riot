#pragma semicolon 1
#pragma newdecls required


void VoidPortal_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Void Portal");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_void_portal");
	strcopy(data.Icon, sizeof(data.Icon), "void_gate");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Void; 
	data.Func = ClotSummon;
	NPC_Add(data);

	
	NPCData data2;
	strcopy(data2.Name, sizeof(data2.Name), "Void Creep");
	strcopy(data2.Plugin, sizeof(data2.Plugin), "npc_donotuseever_1");
	strcopy(data2.Icon, sizeof(data2.Icon), "");
	data2.IconCustom = false;
	data2.Flags = 0;
	data2.Category = Type_Void; 
	data2.Func = ClotSummon;
	NPC_Add(data2);
	PrecacheSound("npc/combine_gunship/see_enemy.wav");
	SpawnedOneAlready = 0.0;
	IdRef = 0;
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return VoidPortal(vecPos, vecAng, team);
}
methodmap VoidPortal < CClotBody
{
	public VoidPortal(float vecPos[3], float vecAng[3], int ally)
	{
		VoidPortal npc = view_as<VoidPortal>(CClotBody(vecPos, vecAng, "models/empty.mdl", "0.8", "700", ally));
		
		i_NpcWeight[npc.index] = 1;

		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = 0;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;
		npc.m_bDissapearOnDeath = true;

		func_NPCDeath[npc.index] = view_as<Function>(VoidPortal_NPCDeath);
		func_NPCThink[npc.index] = view_as<Function>(VoidPortal_ClotThink);
		//This is a dummy npc, it gets slain instantly.
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "voice_player", 1, "%t", "A Void Gate Apeared...");
			}
		}
		if(TeleportDiversioToRandLocation(npc.index,true,1000.0, 700.0, Rogue_Mode(), Rogue_Mode()) == 2)
		{
			TeleportDiversioToRandLocation(npc.index, true);
		}
		
		return npc;
	}
}

public void VoidPortal_ClotThink(int iNPC)
{
	SmiteNpcToDeath(iNPC);
}

public void VoidPortal_NPCDeath(int entity)
{
	VoidPortal npc = view_as<VoidPortal>(entity);
	float VecSelfNpcabs[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", VecSelfNpcabs);
	//a spawnpoint that only lasts for 1 spawn
	Void_PlaceZRSpawnpoint(VecSelfNpcabs, 2, 2000000000, "utaunt_portalswirl_purple_parent", 2, true, 2);
	if(SpawnedOneAlready > GetGameTime())
	{
		Event event = CreateEvent("show_annotation");
		if(event)
		{
			event.SetFloat("worldPosX", VecSelfNpcabs[0]);
			event.SetFloat("worldPosY", VecSelfNpcabs[1]);
			event.SetFloat("worldPosZ", VecSelfNpcabs[2]);
		//	event.SetInt("follow_entindex", 0);
			event.SetFloat("lifetime", 7.0);
		//	event.SetInt("visibilityBitfield", (1<<client));
			//event.SetBool("show_effect", effect);
			event.SetString("text", "Multiple Void Gates!");
			event.SetString("play_sound", "vo/null.mp3");
			IdRef++;
			event.SetInt("id", IdRef); //What to enter inside? Need a way to identify annotations by entindex!
			event.Fire();
		}
	}
	else
	{
		EmitSoundToAll("npc/combine_gunship/see_enemy.wav", _, _, _, _, 1.0);	
		Event event = CreateEvent("show_annotation");
		if(event)
		{
			event.SetFloat("worldPosX", VecSelfNpcabs[0]);
			event.SetFloat("worldPosY", VecSelfNpcabs[1]);
			event.SetFloat("worldPosZ", VecSelfNpcabs[2]);
		//	event.SetInt("follow_entindex", 0);
			event.SetFloat("lifetime", 7.0);
		//	event.SetInt("visibilityBitfield", (1<<client));
			//event.SetBool("show_effect", effect);
			event.SetString("text", "Void Gate");
			event.SetString("play_sound", "vo/null.mp3");
			IdRef++;
			event.SetInt("id", IdRef); //What to enter inside? Need a way to identify annotations by entindex!
			event.Fire();
		}
	}
	SpawnedOneAlready = GetGameTime() + 5.0;
}