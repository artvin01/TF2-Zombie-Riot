#pragma semicolon 1
#pragma newdecls required

static const char g_TeleportSounds[][] = {
	")misc/halloween/spell_teleport.wav",
};

void TemporalAnomaly_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_TeleportSounds));	   i++) { PrecacheSound(g_TeleportSounds[i]);	   }
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Temporal Anomaly");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_temporal_anomaly");
	strcopy(data.Icon, sizeof(data.Icon), "void_gate");
	PrecacheSound("weapons/teleporter_receive.wav");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Aperture; 
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return TemporalAnomaly(vecPos, vecAng, team);
}
methodmap TemporalAnomaly < CClotBody
{
	public void PlayTeleportSound() 
	{
		EmitSoundToAll(g_TeleportSounds[GetRandomInt(0, sizeof(g_TeleportSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}

	public TemporalAnomaly(float vecPos[3], float vecAng[3], int ally)
	{
		TemporalAnomaly npc = view_as<TemporalAnomaly>(CClotBody(vecPos, vecAng, "models/buildables/teleporter.mdl", "1.0", "100000000", ally, .NpcTypeLogic = 1));

		i_NpcWeight[npc.index] = 999;

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_iOverlordComboAttack = 0;
		npc.m_iBleedType = 0;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;
		npc.m_bDissapearOnDeath = true;
		f_ExtraOffsetNpcHudAbove[npc.index] = 500.0;
		i_NpcIsABuilding[npc.index] = true;
		npc.m_flNextRangedSpecialAttack = 0.0;
		AddNpcToAliveList(npc.index, 1);
		npc.m_flAbilityOrAttack0 = GetGameTime(npc.index) + 2.0;
		GiveNpcOutLineLastOrBoss(npc.index, false);
		b_thisNpcHasAnOutline[npc.index] = true; 

		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 0, 0, 0, 0);


		float flPos[3]; // original
		float flAng[3]; // original
		npc.GetAttachment("centre_attach", flPos, flAng);
		npc.m_iWearable1 = ParticleEffectAt_Parent(flPos, "eyeboss_tp_vortex", npc.index, "centre_attach", {0.0,0.0,80.0});

		if(ally != TFTeam_Red)
		{
			for(int client_check=1; client_check<=MaxClients; client_check++)
			{
				if(IsClientInGame(client_check) && !IsFakeClient(client_check))
				{
					SetGlobalTransTarget(client_check);
					ShowGameText(client_check, "voice_player", 1, "%s", "A temporal anomaly opens up...");
					EmitSoundToAll("weapons/teleporter_receive.wav", _, _, _, _, 1.0, 100);
				}
			}
			TeleportDiversioToRandLocation(npc.index,_,1750.0, 1250.0);
		}

		func_NPCDeath[npc.index] = view_as<Function>(TemporalAnomaly_NPCDeath);
		func_NPCThink[npc.index] = view_as<Function>(TemporalAnomaly_ClotThink);
		
		return npc;
	}
}

public void TemporalAnomaly_ClotThink(TemporalAnomaly npc, int iNPC)
{
	float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
	float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
	int team = GetTeam(npc.index);
	float gameTime = GetGameTime(npc.index);
	int wave = (Waves_GetRoundScale() + 1);
	if(npc.m_flNextDelayTime > gameTime)
	{
		//neccecary or stuns wont workd an alike.
		return;
	}
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	if(npc.m_flAbilityOrAttack0 > GetGameTime(npc.index))
	{
		//we are in cooldown, stop
		return;
	}
	//spawn delay!
	npc.m_flAbilityOrAttack0 = gameTime + 2.0;
	//spawn limit.
	npc.m_iOverlordComboAttack++;
	npc.PlayTeleportSound();
	//Wave 1-10
	if(wave >= 1)
	{
		switch(GetRandomInt(0,9))
		{
			case 0:
			{
				TemporalAnomalySpawn(npc.index, "npc_poisonzombie", pos, ang, team, 1000);
			}
			case 1:
			{
				TemporalAnomalySpawn(npc.index, "npc_xeno_combine_soldier_swordsman_ddt", pos, ang, team, 1000);
			}
			case 2:
			{
				TemporalAnomalySpawn(npc.index, "npc_medival_archer", pos, ang, team, 1000);
			}
			case 3:
			{
				TemporalAnomalySpawn(npc.index, "npc_selfam_ire", pos, ang, team, 1000);
			}
			case 4:
			{
				TemporalAnomalySpawn(npc.index, "npc_searunner", pos, ang, team, 1000);
			}
			case 5:
			{
				TemporalAnomalySpawn(npc.index, "npc_beacon_constructor", pos, ang, team, 1000);
			}
			case 6:
			{
				TemporalAnomalySpawn(npc.index, "npc_charger", pos, ang, team, 1000);
			}
			case 7:
			{
				TemporalAnomalySpawn(npc.index, "npc_ruina_magia", pos, ang, team, 1000);
			}
			case 8:
			{
				TemporalAnomalySpawn(npc.index, "npc_void_carrier", pos, ang, team, 1000);
			}
			case 9:
			{
				TemporalAnomalySpawn(npc.index, "npc_khazaan", pos, ang, team, 1000);
			}
		}
	}
	//Wave 10-20
	if(wave >= 10)
	{
		switch(GetRandomInt(0,9))
		{
			case 0:
			{
				TemporalAnomalySpawn(npc.index, "npc_headcrabzombie", pos, ang, team, 10000);
			}
			case 1,2,3,4,5,6,7,8,9:
			{
				TemporalAnomalySpawn(npc.index, "npc_xeno_headcrabzombie", pos, ang, team, 10000);
			}
		}
	}
	//Wave 20-30
	if(wave >= 20)
	{
		switch(GetRandomInt(0,9))
		{
			case 0:
			{
				TemporalAnomalySpawn(npc.index, "npc_headcrabzombie", pos, ang, team, 10000);
			}
			case 1,2,3,4,5,6,7,8,9:
			{
				TemporalAnomalySpawn(npc.index, "npc_xeno_headcrabzombie", pos, ang, team, 10000);
			}
		}
	}
	//Wave 30-40
	if(wave >= 30)
	{
		switch(GetRandomInt(0,9))
		{
			case 0:
			{
				TemporalAnomalySpawn(npc.index, "npc_headcrabzombie", pos, ang, team, 10000);
			}
			case 1,2,3,4,5,6,7,8,9:
			{
				TemporalAnomalySpawn(npc.index, "npc_xeno_headcrabzombie", pos, ang, team, 10000);
			}
		}
	}
	if(npc.m_iOverlordComboAttack >= 10)
	{
		SmiteNpcToDeath(npc.index);
	}

}

public void TemporalAnomaly_NPCDeath(int entity)
{
	TemporalAnomaly npc = view_as<TemporalAnomaly>(entity);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}


void TemporalAnomalySpawn(int iGatePortal, const char[] Npcplugininfo, float pos[3], float ang[3], int team, int health)
{
	int other = NPC_CreateByName(Npcplugininfo, -1, pos, ang, team);
	if(other > MaxClients)
	{
		if(team != TFTeam_Red)
			Zombies_Currently_Still_Ongoing++;

		SetEntProp(other, Prop_Data, "m_iHealth", health);
		SetEntProp(other, Prop_Data, "m_iMaxHealth", health);
		ScalingMultiplyEnemyHpGlobalScale(other); //makre sure to scale Hp extra as we SET hp values here!
		NpcStats_CopyStats(iGatePortal, other);	//copy any stats over idk
		fl_Extra_MeleeArmor[other] = fl_Extra_MeleeArmor[iGatePortal] * 0.40;
		fl_Extra_RangedArmor[other] = fl_Extra_RangedArmor[iGatePortal] * 0.40;
		fl_Extra_Speed[other] = fl_Extra_Speed[iGatePortal];
		fl_Extra_Damage[other] = fl_Extra_Damage[iGatePortal];
		b_thisNpcIsABoss[other] = b_thisNpcIsABoss[iGatePortal];
		b_StaticNPC[other] = b_StaticNPC[iGatePortal];
		if(b_StaticNPC[other])
			AddNpcToAliveList(other, 1);
		npc.m_iOverlordComboAttack++;
		npc.m_flAbilityOrAttack0 = gameTime + 2.0;
	}
}