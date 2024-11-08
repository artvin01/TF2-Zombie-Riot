#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/sniper_paincrticialdeath01.mp3",
	"vo/sniper_paincrticialdeath02.mp3",
	"vo/sniper_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/sniper_painsharp01.mp3",
	"vo/sniper_painsharp02.mp3",
	"vo/sniper_painsharp03.mp3",
	"vo/sniper_painsharp04.mp3",
};


static const char g_IdleAlertedSounds[][] = {
	"vo/sniper_mvm_mannhattan_gate_atk01.mp3",
	"vo/sniper_mvm_mannhattan_gate_atk02.mp3",
};

static int i_signaller_particle[MAXENTITIES];

void VictorianSignaller_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Signaller");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_signaller");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_signaller");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_SUPPORT;
	data.Category = Type_Victoria;
	data.Func = ClotSummon;
	NPC_Add(data);  
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return VictorianSignaller(client, vecPos, vecAng, ally);
}

methodmap VictorianSignaller < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public VictorianSignaller(int client, float vecPos[3], float vecAng[3], int ally)
	{
		VictorianSignaller npc = view_as<VictorianSignaller>(CClotBody(vecPos, vecAng, "models/player/sniper.mdl", "1.0", "6000", ally));
		
		i_NpcWeight[npc.index] = 1;
		npc.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		SetVariantInt(3);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");

		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		func_NPCDeath[npc.index] = VictorianSignaller_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = VictorianSignaller_ClotThink;
		
		Is_a_Medic[npc.index] = true;
		npc.m_flSpeed = 200.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		
		float flPos[3], flAng[3];
				
		npc.GetAttachment("m_vecAbsOrigin", flPos, flAng);
		i_signaller_particle[npc.index] = EntIndexToEntRef(ParticleEffectAt_Parent(flPos, "utaunt_aestheticlogo_teamcolor_blue", npc.index, "m_vecAbsOrigin", {0.0,0.0,0.0}));
		npc.GetAttachment("", flPos, flAng);


		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_spikewrench/c_spikewrench.mdl");
		SetVariantString("0.9");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		npc.m_iWearable2 = npc.EquipItem("head", "models/weapons/c_models/c_battalion_buffpack/c_batt_buffpack.mdl");
		SetVariantString("1.75");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		npc.m_iWearable3 = npc.EquipItem("head", "models/weapons/c_models/c_battalion_buffbanner/c_batt_buffbanner.mdl");
		SetVariantString("1.75");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/sniper/dec2014_hunter_ushanka/dec2014_hunter_ushanka.mdl");
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/sniper/invasion_final_frontiersman/invasion_final_frontiersman.mdl");
		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/sniper/spr17_down_under_duster/spr17_down_under_duster.mdl");
		
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", skin);

		npc.StartPathing();
		return npc;
	}
}

public void VictorianSignaller_ClotThink(int iNPC)
{
	VictorianSignaller npc = view_as<VictorianSignaller>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}
	
	if(npc.m_flNextThinkTime > gameTime)
		return;

	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_iTargetAlly && !IsValidAlly(npc.index, npc.m_iTargetAlly))
		npc.m_iTargetAlly = 0;
	
	if(!npc.m_iTargetAlly || npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTargetAlly = GetClosestAlly(npc.index);
		if(npc.m_iTargetAlly < 1)
		{
			LastHitRef[npc.index] = -1;
			SmiteNpcToDeath(npc.index);
			return;
		}
		
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
		if(!NpcStats_IsEnemySilenced(npc.index))
			f_EmpowerStateOther[npc.m_iTargetAlly] = GetGameTime() + 1.5;
	}

	gameTime = GetGameTime() + 0.5;

	if(!NpcStats_IsEnemySilenced(npc.index))
	{
		int team = GetTeam(npc.index);
		if(team == 2)
		{
			for(int client = 1; client <= MaxClients; client++)
			{
				if(IsClientInGame(client) && GetClientTeam(client) != 3 && IsEntityAlive(client))
				{
					f_VictorianCallToArms[client] = gameTime;
				}
			}
		}

		for(int i; i < i_MaxcountNpcTotal; i++)
		{
			int entity = EntRefToEntIndex(i_ObjectsNpcsTotal[i]);
			if(entity != npc.index && entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity) && GetTeam(entity) == team)
			{
				f_VictorianCallToArms[entity] = gameTime;
			}
		}
	}
	if(npc.m_iTargetAlly > 0)
	{
		NPC_SetGoalEntity(npc.index, npc.m_iTargetAlly);
	}

	npc.PlayIdleSound();
}

void VictorianSignaller_NPCDeath(int entity)
{
	VictorianSignaller npc = view_as<VictorianSignaller>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

	int particle = EntRefToEntIndex(i_signaller_particle[npc.index]);
	if(IsValidEntity(particle))
	{
		RemoveEntity(particle);
		i_signaller_particle[npc.index]=INVALID_ENT_REFERENCE;
	}
}