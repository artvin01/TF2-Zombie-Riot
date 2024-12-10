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

void LiberiOnMapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Liberi");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_liberi");
	strcopy(data.Icon, sizeof(data.Icon), "medic_uber");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Interitus;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Liberi(vecPos, vecAng, team);
}
static float LiberiBuff[MAXENTITIES];

methodmap Liberi < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public Liberi(float vecPos[3], float vecAng[3], int ally)
	{
		Liberi npc = view_as<Liberi>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "35000", ally));
		
		i_NpcWeight[npc.index] = 1;
		npc.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);

		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = ClotThink;
		
		Is_a_Medic[npc.index] = true;
		npc.m_flSpeed = Rogue_Paradox_RedMoon() ? 500.0 : 300.0;
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_picket/c_picket.mdl");

		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/medic/medic_blighted_beak.mdl");

		npc.m_iWearable3 = npc.EquipItem("head", "models/player/items/medic/archimedes.mdl");
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/medic/sf14_purity_wings/sf14_purity_wings.mdl");
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/medic/sum23_medical_emergency/sum23_medical_emergency.mdl");
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", 1);

		return npc;
	}
}

static void ClotThink(int iNPC)
{
	Liberi npc = view_as<Liberi>(iNPC);

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
	
	if(npc.m_flNextRangedAttackHappening < GetGameTime())
	{
		npc.m_flNextRangedAttackHappening = GetGameTime() + 2.5;
		DesertYadeamDoHealEffect(npc.index, 200.0);
	}
	if(npc.m_flNextRangedAttack < GetGameTime(npc.index))
	{
		npc.m_flNextRangedAttack = GetGameTime(npc.index) + 0.25;
		ExpidonsaGroupHeal(npc.index, 200.0, 99, 2000.0, 1.0, false,Expidonsa_DontHealSameIndex);
	}

	int target = npc.m_iTargetAlly;
	if(!IsValidAlly(npc.index, target))
	{
		target = GetClosestAlly(npc.index);
		if(target <= MaxClients)
		{
			LastHitRef[npc.index] = -1;
			SmiteNpcToDeath(npc.index);
			return;
		}

		npc.m_iTargetAlly = target;
	}

	if(target > 0)
	{
		float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float distance = GetVectorDistance(vecTarget, VecSelfNpc, true);	
		
		if(distance < 40000.0)
		{
			npc.StopPathing();

			LiberiBuff[target] = GetGameTime() + (Rogue_Paradox_RedMoon() ? 3.0 : 0.2);

			if(Rogue_Paradox_RedMoon() || !NpcStats_IsEnemySilenced(npc.index))
			{
				b_NpcIsInvulnerable[target] = true;
				SDKUnhook(target, SDKHook_ThinkPost, LiberiBuffThink);
				SDKHook(target, SDKHook_ThinkPost, LiberiBuffThink);
			}
		}
		else
		{
			npc.StartPathing();
			NPC_SetGoalEntity(npc.index, target);
		}
	}
	else
	{
		npc.StopPathing();
	}

	npc.PlayIdleSound();
}

static void LiberiBuffThink(int entity)
{
	if(GetGameTime() > LiberiBuff[entity])
	{
		b_NpcIsInvulnerable[entity] = false;
		SDKUnhook(entity, SDKHook_ThinkPost, LiberiBuffThink);
	}
}

static void ClotDeath(int entity)
{
	Liberi npc = view_as<Liberi>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	
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
}