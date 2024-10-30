#pragma semicolon 1
#pragma newdecls required

#define VictoriaRadiomast_MODEL_1 "models/props_spytech/radio_tower001.mdl"
#define VictoriaRadiomast_MODEL_2 "models/props_powerhouse/powerhouse_turbine.mdl"
#define VictoriaRadiomast_MODEL_3 "models/props_urban/urban_skytower006.mdl"

static const char g_DeathSounds[][] = {
	"ambient/explosions/explode_3.wav",
	"ambient/explosions/explode_4.wav",
	"ambient/explosions/explode_9.wav",
};

static const char g_HurtSounds[][] = {
	")physics/metal/metal_box_impact_bullet1.wav",
	")physics/metal/metal_box_impact_bullet2.wav",
	")physics/metal/metal_box_impact_bullet3.wav",
};
//int LighthouseID;
/*
int LighthouseGlobaID()
{
	return LighthouseID;
}
*/
void VictoriaRadiomast_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Victoria Radiomast");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_victoria_radiomast");
	strcopy(data.Icon, sizeof(data.Icon), "lighthouse");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Victoria;
	data.Func = ClotSummon;
	//LighthouseID = NPC_Add(data);
	PrecacheModel(VictoriaRadiomast_MODEL_1);
	PrecacheModel(VictoriaRadiomast_MODEL_2);
	PrecacheModel(VictoriaRadiomast_MODEL_3);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return VictoriaRadiomast(client, vecPos, vecAng, ally);
}
methodmap VictoriaRadiomast < CClotBody
{
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, 0.3);
	}
	
	public VictoriaRadiomast(int client, float vecPos[3], float vecAng[3], int ally)
	{
		VictoriaRadiomast npc = view_as<VictoriaRadiomast>(CClotBody(vecPos, vecAng, TOWER_MODEL, TOWER_SIZE,"1000000", ally, false,true,_,_,{30.0,30.0,200.0}));
		
		SetEntityRenderMode(npc.index, RENDER_NONE);
		i_NpcWeight[npc.index] = 999;
		b_NpcUnableToDie[npc.index] = true;
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 0, 0, 0, 0);
		npc.m_iWearable1 = npc.EquipItemSeperate("partyhat", VictoriaRadiomast_MODEL_1,_,1);
		SetVariantString("0.5");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		npc.m_iWearable2 = npc.EquipItemSeperate("partyhat", VictoriaRadiomast_MODEL_2,_,_,_,70.0);
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		npc.m_iWearable3 = npc.EquipItemSeperate("partyhat", VictoriaRadiomast_MODEL_3,_,1);
		SetVariantString("0.95");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_flMeleeArmor = 2.5;
		npc.m_flRangedArmor = 1.0;

		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;
		npc.m_bDissapearOnDeath = true;

		Is_a_Medic[npc.index] = true;
		f_ExtraOffsetNpcHudAbove[npc.index] = 200.0;
		i_NpcIsABuilding[npc.index] = true;
		fl_GetClosestTargetTimeTouch[npc.index] = FAR_FUTURE;
		b_thisNpcIsABoss[npc.index] = true;
		if(!IsValidEntity(RaidBossActive))
		{
			RaidModeScaling = 10.0;	//just a safety net
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidModeTime = GetGameTime(npc.index) + 9000.0;
			RaidAllowsBuildings = true;
		}


		func_NPCDeath[npc.index] = view_as<Function>(VictoriaRadiomast_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(VictoriaRadiomast_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(VictoriaRadiomast_ClotThink);
		
		//IDLE
		npc.m_iState = 0;
		npc.m_flSpeed = 0.0;
		NPC_StopPathing(npc.index);

		int Decicion = TeleportDiversioToRandLocation(npc.index, true, 1500.0, 1000.0);
		switch(Decicion)
		{
			case 2:
			{
				Decicion = TeleportDiversioToRandLocation(npc.index, true, 1500.0, 500.0);
				if(Decicion == 2)
				{
					Decicion = TeleportDiversioToRandLocation(npc.index, true, 1500.0, 250.0);
					if(Decicion == 2)
					{
						Decicion = TeleportDiversioToRandLocation(npc.index, true, 1500.0, 0.0);
					}
				}
			}
			case 3:
			{
				//todo code on what to do if random teleport is disabled
			}
		}
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "voice_player", 1, "%t", "Victorian Lighthouse Teleported in!");
			}
		}
		EmitSoundToAll("weapons/rescue_ranger_teleport_receive_01.wav", npc.index, SNDCHAN_STATIC, 120, _, RAIDBOSSBOSS_ZOMBIE_VOLUME);
		EmitSoundToAll("weapons/rescue_ranger_teleport_receive_01.wav", npc.index, SNDCHAN_STATIC, 120, _, RAIDBOSSBOSS_ZOMBIE_VOLUME);
		float VecSelfNpcabs[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", VecSelfNpcabs);
		VecSelfNpcabs[2] += 200.0;
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
			event.SetString("text", "Radio Tower!");
			event.SetString("play_sound", "vo/null.mp3");
			IdRef++;
			event.SetInt("id", IdRef); //What to enter inside? Need a way to identify annotations by entindex!
			event.Fire();
		}
		return npc;
	}
}

public void VictoriaRadiomast_ClotThink(int iNPC)
{
	VictoriaRadiomast npc = view_as<VictoriaRadiomast>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;

	if(npc.m_blPlayHurtAnimation)
	{
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.05;
	//global range.
	npc.m_flNextRangedSpecialAttack = 0.0;
}

public Action VictoriaRadiomast_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VictoriaRadiomast npc = view_as<VictoriaRadiomast>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void VictoriaRadiomast_NPCDeath(int entity)
{
	VictoriaRadiomast npc = view_as<VictoriaRadiomast>(entity);
	npc.PlayDeathSound();	

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}

