#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	")vo/soldier_negativevocalization01.mp3",
	")vo/soldier_negativevocalization02.mp3",
	")vo/soldier_negativevocalization03.mp3",
	")vo/soldier_negativevocalization04.mp3",
	")vo/soldier_negativevocalization05.mp3",
	")vo/soldier_negativevocalization06.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/soldier_painsharp01.mp3",
	"vo/soldier_painsharp02.mp3",
	"vo/soldier_painsharp03.mp3",
	"vo/soldier_painsharp04.mp3",
	"vo/soldier_painsharp05.mp3",
	"vo/soldier_painsharp06.mp3",
	"vo/soldier_painsharp07.mp3",
	"vo/soldier_painsharp08.mp3"
};


static const char g_IdleAlertedSounds[][] = {
	"vo/compmode/cm_soldier_pregamefirst_02.mp3",
	"vo/compmode/cm_soldier_pregamefirst_01.mp3",
	"vo/compmode/cm_soldier_pregamefirst_04.mp3",
	"vo/compmode/cm_soldier_pregamefirst_05.mp3",
	"vo/compmode/cm_soldier_pregamefirst_07.mp3",
};

static const char g_hornsound[][] = {
	"weapons/battalions_backup_blue.wav",
	"weapons/buff_banner_horn_blue.wav",
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
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlayHornSound() 
	{
		EmitSoundToAll(g_hornsound[GetRandomInt(0, sizeof(g_hornsound) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL , _, 0.5, GetRandomInt(80,110));
	}
	
	public VictorianSignaller(int client, float vecPos[3], float vecAng[3], int ally)
	{
		VictorianSignaller npc = view_as<VictorianSignaller>(CClotBody(vecPos, vecAng, "models/player/soldier.mdl", "1.0", "6000", ally));
		
		i_NpcWeight[npc.index] = 1;
		npc.SetActivity("ACT_MP_RUN_MELEE");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		SetVariantInt(2);
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

		if(Waves_InFreeplay())
		{
			CPrintToChatAll("{blue}Sigmaller{white}: {blue}I FEEL SO SIGMA!!");
			for(int entitycount; entitycount<MAXENTITIES; entitycount++) //Check for npcs
			{
				if(IsValidEntity(entitycount) && entitycount != npc.index && (!b_NpcHasDied[entitycount])) //Cannot buff self like this.
				{
					if(GetTeam(entitycount) == GetTeam(npc.index) && IsEntityAlive(entitycount))
					{
						HealEntityGlobal(npc.index, entitycount, float(GetEntProp(entitycount, Prop_Data, "m_iHealth")), 1.0, 0.0, HEAL_ABSOLUTE);
						ApplyStatusEffect(npc.index, entitycount, "Combine Command", 2.5);
						ApplyStatusEffect(npc.index, entitycount, "Buff Banner", 2.5);
						ApplyStatusEffect(npc.index, entitycount, "Battilons Backup", 2.5);
						ApplyStatusEffect(npc.index, entitycount, "Healing Strength", 2.5);
						ApplyStatusEffect(npc.index, entitycount, "Healing Resolve", 2.5);
					}
				}
			}
		}
		
		float flPos[3], flAng[3];
				
		npc.GetAttachment("m_vecAbsOrigin", flPos, flAng);
		i_signaller_particle[npc.index] = EntIndexToEntRef(ParticleEffectAt_Parent(flPos, "utaunt_aestheticlogo_teamcolor_blue", npc.index, "m_vecAbsOrigin", {0.0,0.0,0.0}));
		npc.GetAttachment("", flPos, flAng);

		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_battalion_bugle/c_battalion_bugle.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		npc.m_iWearable2 = npc.EquipItem("head", "models/weapons/c_models/c_buffpack/c_buffpack.mdl");
		SetVariantString("1.75");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		npc.m_iWearable3 = npc.EquipItem("head", "models/weapons/c_models/c_battalion_buffbanner/c_batt_buffbanner.mdl");
		SetVariantString("1.75");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		npc.m_iWearable4 = npc.EquipItem("head", "models/player/items/soldier/hardhat_tower.mdl");
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/soldier/dec23_trench_warefarer/dec23_trench_warefarer.mdl");
		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/all_class/hwn2021_goalkeeper_style2/hwn2021_goalkeeper_style2_soldier.mdl");
		
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable4, 0, 0, 0, 255);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		SetEntityRenderMode(npc.m_iWearable5, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable5, 100, 100, 100, 255);
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", skin);
		SetEntityRenderMode(npc.m_iWearable6, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable6, 0, 0, 0, 255);

		npc.StartPathing();
		return npc;
	}
}

public void VictorianSignaller_ClotThink(int iNPC)
{
	VictorianSignaller npc = view_as<VictorianSignaller>(iNPC);
	bool freeplay_sigmalone = false;
	bool isfreeplay = Waves_InFreeplay();
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
			if(!isfreeplay)
			{
				LastHitRef[npc.index] = -1;
				SmiteNpcToDeath(npc.index);
				return;
			}
			else
			{
				freeplay_sigmalone = true;
			}
			
		}
		
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
		if(!NpcStats_IsEnemySilenced(npc.index))
		{
			if(isfreeplay)
				ApplyStatusEffect(npc.index, npc.m_iTargetAlly, "Ally Empowerment", 60.0);
			else
				ApplyStatusEffect(npc.index, npc.m_iTargetAlly, "Ally Empowerment", 1.5);
		}
			
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM2");
		npc.PlayHornSound();

		if(Waves_InFreeplay())
		{
			for(int client = 1; client <= MaxClients; client++)
			{
				if(IsClientInGame(client) && IsEntityAlive(client))
				{
					if(freeplay_sigmalone)
					{
						SDKHooks_TakeDamage(client, npc.index, npc.index, 600.0, DMG_CLUB, -1);
						ApplyStatusEffect(npc.index, npc.index, "Hardened Aura", 8.0);
					}
				}
			}
	
			for(int i; i < i_MaxcountNpcTotal; i++)
			{
				int entity = EntRefToEntIndex(i_ObjectsNpcsTotal[i]);
				if(entity != npc.index && entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity))
				{
					if(GetTeam(entity) == GetTeam(npc.index))
					{
						ApplyStatusEffect(npc.index, entity, "Call To Victoria", 10.0);
						fl_Extra_Speed[entity] *= 1.1;
						fl_Extra_MeleeArmor[entity] *= 0.9;
						fl_Extra_RangedArmor[entity] *= 0.9;
						HealEntityGlobal(npc.index, entity, (float(GetEntProp(entity, Prop_Data, "m_iHealth")) * 0.25), 1.0, 0.0, HEAL_ABSOLUTE);
					}
					else
					{
						if(freeplay_sigmalone)
						{
							SDKHooks_TakeDamage(entity, npc.index, npc.index, 750.0, DMG_CLUB, -1);
							ApplyStatusEffect(npc.index, npc.index, "Hardened Aura", 5.0);
						}
					}
				}
			}

			npc.m_flNextMeleeAttack = gameTime + 4.25;
		}
		else
		{
			npc.m_flNextMeleeAttack = gameTime + 7.50;
		}
	}

	gameTime = GetGameTime() + 0.5;

	if(!NpcStats_IsEnemySilenced(npc.index))
	{
		int team = GetTeam(npc.index);
		if(team == 2)
		{
			for(int client = 1; client <= MaxClients; client++)
			{
				if(IsClientInGame(client) && IsEntityAlive(client))
				{
					ApplyStatusEffect(npc.index, client, "Call To Victoria", 0.5);
				}
			}
		}

		for(int i; i < i_MaxcountNpcTotal; i++)
		{
			int entity = EntRefToEntIndex(i_ObjectsNpcsTotal[i]);
			if(entity != npc.index && entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity))
			{
				if(GetTeam(entity) == team)
				{
					ApplyStatusEffect(npc.index, entity, "Call To Victoria", 0.5);
				}
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
