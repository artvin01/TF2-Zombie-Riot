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
	
	public SeabornMedic(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		SeabornMedic npc = view_as<SeabornMedic>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "6000", ally));
		
		i_NpcInternalId[npc.index] = SEABORN_MEDIC;
		i_NpcWeight[npc.index] = 1;
		npc.SetActivity("ACT_MP_SWIM_LOSERSTATE");
		
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_SEABORN;
		
		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);

		SDKHook(npc.index, SDKHook_Think, SeabornMedic_ClotThink);
		
		Is_a_Medic[npc.index] = true;
		npc.m_flSpeed = 256.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 100, 100, 255, 255);

		npc.m_iWearable1 = npc.EquipItem("head", "models/player/items/medic/hwn_medic_hat.mdl");
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
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
			SDKHooks_TakeDamage(npc.index, 0, 0, 9999999.0, DMG_CLUB);
			return;
		}
		
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
		if(!NpcStats_IsEnemySilenced(npc.index))
			f_EmpowerStateOther[npc.m_iTargetAlly] = GetGameTime() + 1.5;
	}

	gameTime = GetGameTime() + 0.5;

	if(!NpcStats_IsEnemySilenced(npc.index))
	{
		if(GetEntProp(npc.index, Prop_Send, "m_iTeamNum") == 2)
		{
			for(int client = 1; client <= MaxClients; client++)
			{
				if(IsClientInGame(client) && GetClientTeam(client) != 3 && IsEntityAlive(client))
				{
					f_HussarBuff[client] = gameTime;
				}
			}

			for(int i; i < i_MaxcountNpc_Allied; i++)
			{
				int entity = EntRefToEntIndex(i_ObjectsNpcs[i]);
				if(entity != npc.index && entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity))
				{
					f_HussarBuff[entity] = gameTime;
				}
			}
		}
		else
		{
			for(int i; i < i_MaxcountNpc; i++)
			{
				int entity = EntRefToEntIndex(i_ObjectsNpcs[i]);
				if(entity != npc.index && entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity))
				{
					f_HussarBuff[entity] = gameTime;
				}
			}
		}
	}
	
	NPC_SetGoalEntity(npc.index, npc.m_iTargetAlly);

	npc.PlayIdleSound();
}

void SeabornMedic_NPCDeath(int entity)
{
	SeabornMedic npc = view_as<SeabornMedic>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	SDKUnhook(npc.index, SDKHook_Think, SeabornMedic_ClotThink);
}