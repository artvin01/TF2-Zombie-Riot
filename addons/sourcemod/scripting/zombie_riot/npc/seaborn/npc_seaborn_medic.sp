#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"vo/medic_paincrticialdeath01.mp3",
	"vo/medic_paincrticialdeath02.mp3",
	"vo/medic_paincrticialdeath03.mp3"
};

static const char g_HurtSounds[][] =
{
	"vo/medic_painsharp01.mp3",
	"vo/medic_painsharp02.mp3",
	"vo/medic_painsharp03.mp3",
	"vo/medic_painsharp04.mp3"
};

static const char g_IdleAlertedSounds[][] =
{
	"vo/medic_battlecry01.mp3",
	"vo/medic_battlecry02.mp3",
	"vo/medic_battlecry03.mp3",
	"vo/medic_battlecry04.mp3"
};

void SeabornMedic_Precache()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Seaborn Medic");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_seaborn_medic");
	strcopy(data.Icon, sizeof(data.Icon), "ds_medic");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MISSION;
	data.Category = Type_Seaborn;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return SeabornMedic(vecPos, vecAng, team);
}

methodmap SeabornMedic < CClotBody
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
	
	public SeabornMedic(float vecPos[3], float vecAng[3], int ally)
	{
		SeabornMedic npc = view_as<SeabornMedic>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "6000", ally));
		
		i_NpcWeight[npc.index] = 1;
		npc.SetActivity("ACT_MP_SWIM_LOSERSTATE");
		
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_SEABORN;
		
		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);

		func_NPCDeath[npc.index] = SeabornMedic_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = SeabornMedic_ClotThink;
		
		Is_a_Medic[npc.index] = true;
		npc.m_flSpeed = 256.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		
		SetEntityRenderColor(npc.index, 100, 100, 255, 255);

		npc.m_iWearable1 = npc.EquipItem("head", "models/player/items/medic/hwn_medic_hat.mdl");
		SetEntityRenderColor(npc.m_iWearable1, 100, 100, 255, 255);

		npc.StartPathing();
		return npc;
	}
}

public void SeabornMedic_ClotThink(int iNPC)
{
	SeabornMedic npc = view_as<SeabornMedic>(iNPC);

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
			ApplyStatusEffect(npc.index, npc.m_iTargetAlly, "Ally Empowerment", 1.5);
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
					ApplyStatusEffect(npc.index, client, "Hussar's Warscream", 0.5);
				}
			}
		}

		for(int i; i < i_MaxcountNpcTotal; i++)
		{
			int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
			if(entity != npc.index && entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity) && GetTeam(entity) == team)
			{
				ApplyStatusEffect(npc.index, entity, "Hussar's Warscream", 0.5);
			}
		}
	}
	if(npc.m_iTargetAlly > 0)
	{
		npc.SetGoalEntity(npc.m_iTargetAlly);
	}

	npc.PlayIdleSound();
}

void SeabornMedic_NPCDeath(int entity)
{
	SeabornMedic npc = view_as<SeabornMedic>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}
