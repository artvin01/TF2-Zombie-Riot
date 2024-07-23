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
	data.Category = Type_Hidden; //Replace me with void!
	data.Func = ClotSummon;
	NPC_Add(data);
	PrecacheSound("npc/combine_gunship/see_enemy.wav");
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

		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = 0;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;
		npc.m_bDissapearOnDeath = true;

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
	SmiteNpcToDeath(iNPC);
}

public void VoidPortal_NPCDeath(int entity)
{
	VoidPortal npc = view_as<VoidPortal>(entity);
	float VecSelfNpcabs[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", VecSelfNpcabs);
	//a spawnpoint that only lasts for 1 spawn
	Void_PlaceZRSpawnpoint(VecSelfNpcabs, 2, 2000000000, "utaunt_portalswirl_purple_parent", -15, true);
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
		event.SetInt("id", 6000); //What to enter inside? Need a way to identify annotations by entindex!
		event.Fire();
	}
}