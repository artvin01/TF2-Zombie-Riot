#pragma semicolon 1
#pragma newdecls required

// this should vary from npc to npc as some are in a really small area.

static float DamageDealt[MAXPLAYERS];
static float DamageTime[MAXPLAYERS];
static float DamageExpire[MAXPLAYERS];
static bool DamageUpdate[MAXPLAYERS];

static const char g_IdleSound[][] = {
	"npc/combine_soldier/vo/alert1.wav",
	"npc/combine_soldier/vo/bouncerbouncer.wav",
	"npc/combine_soldier/vo/boomer.wav",
};

void BobTheTargetDummy_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_IdleSound));	i++) { PrecacheSound(g_IdleSound[i]);	}
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Bob The First");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_bob_the_first_targetdummy");
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return BobTheTargetDummy(vecPos, vecAng, team);
}

methodmap BobTheTargetDummy < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;

		EmitSoundToAll(g_IdleSound[GetRandomInt(0, sizeof(g_IdleSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,100);

		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	
	public BobTheTargetDummy(float vecPos[3], float vecAng[3], int ally)
	{
		BobTheTargetDummy npc = view_as<BobTheTargetDummy>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "300", ally, false,_,_,_,_));
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("ACT_IDLE");

		npc.m_bisWalking = false;

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_bDissapearOnDeath = false;
		
		npc.m_iBleedType = 0; //No bleed.
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;

		f3_SpawnPosition[npc.index][0] = vecPos[0];
		f3_SpawnPosition[npc.index][1] = vecPos[1];
		f3_SpawnPosition[npc.index][2] = vecPos[2];
		
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, BobTheTargetDummy_OnTakeDamagePost);

		func_NPCDeath[npc.index] = BobTheTargetDummy_NPCDeath;
	//	func_NPCOnTakeDamage[npc.index] = BobTheTargetDummy_OnTakeDamage;
		func_NPCThink[npc.index] = BobTheTargetDummy_ClotThink;

		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_claymore/c_claymore.mdl");
		SetVariantString("0.7");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 2);
		
		npc.m_iWearable3 = npc.EquipItem("partyhat", "models/player/items/demo/crown.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		

		SetEntityRenderColor(npc.m_iWearable1, 200, 255, 200, 255);

		SetEntityRenderColor(npc.m_iWearable3, 200, 255, 200, 255);

		npc.StopPathing();
			
		b_NoKnockbackFromSources[npc.index] = true;
		
		return npc;
	}
	
}


public void BobTheTargetDummy_ClotThink(int iNPC)
{
	BobTheTargetDummy npc = view_as<BobTheTargetDummy>(iNPC);

//	SetVariantInt(1);
//	AcceptEntityInput(iNPC, "SetBodyGroup");

	float gameTime = GetGameTime();

	//some npcs deservere full update time!
	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();

	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	for(int client=1; client<=MaxClients; client++)
	{
		if(DamageDealt[client])
		{
			if(!IsClientInGame(client))
			{
				DamageDealt[client] = 0.0;
			}
			else if(DamageExpire[client] < gameTime)
			{
				PrintCenterText(client, "");
				DamageDealt[client] = 0.0;
			}
			else if(DamageUpdate[client])
			{
				float time = gameTime - DamageTime[client];
				if(time < 1.0)
					time = 1.0;
				
				PrintCenterText(client, "DPS: %.0f | Total: %.0f", DamageDealt[client] / time, DamageDealt[client]);
				DamageUpdate[client] = false;
			}
		}
	}	

	if(IsValidEntity(npc.m_iTextEntity1))
		DispatchKeyValue(npc.m_iTextEntity1, "rainbow", "1");
	if(IsValidEntity(npc.m_iTextEntity2))
		DispatchKeyValue(npc.m_iTextEntity2, "rainbow", "1");
	if(IsValidEntity(npc.m_iTextEntity3))
		DispatchKeyValue(npc.m_iTextEntity3, "rainbow", "1");

	npc.PlayIdleSound();
}

public void BobTheTargetDummy_OnTakeDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype) 
{
	BobTheTargetDummy npc = view_as<BobTheTargetDummy>(victim);

	if(attacker > 0 && attacker <= MaxClients)
	{
		DamageExpire[attacker] = GetGameTime();

		if(!DamageDealt[attacker])
			DamageTime[attacker] = DamageExpire[attacker];

		DamageExpire[attacker] += 4.0;	
		DamageDealt[attacker] += damage;
		DamageUpdate[attacker] = true;
	}

	SetEntProp(npc.index, Prop_Data, "m_iHealth", ReturnEntityMaxHealth(npc.index));
}

public void BobTheTargetDummy_NPCDeath(int entity)
{
	BobTheTargetDummy npc = view_as<BobTheTargetDummy>(entity);
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamagePost, BobTheTargetDummy_OnTakeDamagePost);

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}


