#pragma semicolon 1
#pragma newdecls required

static float f_TalkDelayCheck;
static int i_TalkDelayCheck;

static int i_LastStandBossRef;

// This NPC will also store/handle shared "last stand" raid boss stuff!!!

enum
{
	APERTURE_BOSS_NONE = 0,
	APERTURE_BOSS_CAT = (1 << 0),
	APERTURE_BOSS_ARIS = (1 << 1),
	APERTURE_BOSS_CHIMERA = (1 << 2),
	APERTURE_BOSS_VINCENT = (1 << 3),
}

enum
{
	APERTURE_LAST_STAND_STATE_STARTING,
	APERTURE_LAST_STAND_STATE_ALMOST_HAPPENING,
	APERTURE_LAST_STAND_STATE_HAPPENING,
	APERTURE_LAST_STAND_STATE_SPARED,
	APERTURE_LAST_STAND_STATE_KILLED,
}

int i_ApertureBossesDead = APERTURE_BOSS_NONE;
static float fl_PlayerDamage[MAXPLAYERS];
static float fl_MaxDamagePerPlayer;

#define APERTURE_LAST_STAND_TIMER_TOTAL 20.0
#define APERTURE_LAST_STAND_TIMER_INVULN 5.0
#define APERTURE_LAST_STAND_TIMER_BEFORE_INVULN 2.5

#define APERTURE_LAST_STAND_HEALTH_MULT 0.05

#define APERTURE_LAST_STAND_EXPLOSION_PARTICLE "fluidSmokeExpl_ring"

static const char g_ApertureSharedStunStartSound[] = "ui/mm_door_open.wav";
static const char g_ApertureSharedStunMainSound[] = "mvm/mvm_robo_stun.wav";
static const char g_ApertureSharedStunTeleportSound[] = "weapons/teleporter_send.wav";
static const char g_ApertureSharedStunExplosionSound[] = "mvm/mvm_tank_explode.wav";

void Talker_OnMapStart_NPC()
{
	PrecacheSound(g_ApertureSharedStunStartSound);
	PrecacheSound(g_ApertureSharedStunMainSound);
	PrecacheSound(g_ApertureSharedStunTeleportSound);
	PrecacheSound(g_ApertureSharedStunExplosionSound);
	
	PrecacheParticleSystem(APERTURE_LAST_STAND_EXPLOSION_PARTICLE);
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Back");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_talker");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = true;
	data.Flags = -1;
	data.Category = Type_Hidden; 
	data.Func = ClotSummon;
	NPC_Add(data);
	
	i_ApertureBossesDead = APERTURE_BOSS_NONE;
	i_LastStandBossRef = INVALID_ENT_REFERENCE;
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Talker(vecPos, vecAng, team, data);
}
methodmap Talker < CClotBody
{
	property int m_iTalkWaveAt
	{
		public get()							{ return i_BleedType[this.index]; }
		public set(int TempValueForProperty) 	{ i_BleedType[this.index] = TempValueForProperty; }
	}
	property int m_iRandomTalkNumber
	{
		public get()							{ return i_StepNoiseType[this.index]; }
		public set(int TempValueForProperty) 	{ i_StepNoiseType[this.index] = TempValueForProperty; }
	}
	public Talker(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Talker npc = view_as<Talker>(CClotBody(vecPos, vecAng, "models/buildables/teleporter.mdl", "1.0", "100000000", ally, .NpcTypeLogic = 1));

		i_NpcWeight[npc.index] = 999;

		b_StaticNPC[npc.index] = true;
		AddNpcToAliveList(npc.index, 1);
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_iOverlordComboAttack = 0;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;
		npc.m_bDissapearOnDeath = true;
		f_ExtraOffsetNpcHudAbove[npc.index] = 500.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flAbilityOrAttack0 = GetGameTime(npc.index) + 2.0;
		GiveNpcOutLineLastOrBoss(npc.index, false);
		b_thisNpcHasAnOutline[npc.index] = true;
		i_TalkDelayCheck = 0;
		f_TalkDelayCheck = 0.0;
		npc.m_bCamo = true;
		b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true; //Make allied npcs ignore him.
		b_NpcIsInvulnerable[npc.index] = true;
		b_ThisEntityIgnored[npc.index] = true;

		SetEntityRenderMode(npc.index, RENDER_NONE);

		npc.m_iTalkWaveAt = 0;
		npc.m_iTalkWaveAt = 0;
		int WaveAmAt;
		WaveAmAt = StringToInt(data);
		if (WaveAmAt == 1)
		{
			i_ApertureBossesDead = APERTURE_BOSS_NONE;
		}
		npc.m_iTalkWaveAt = WaveAmAt;
		
		npc.m_iRandomTalkNumber = -1;

		func_NPCThink[npc.index] = view_as<Function>(Talker_ClotThink);
		
		return npc;
	}
}

public void Talker_ClotThink(int iNPC)
{
	Talker npc = view_as<Talker>(iNPC);
	//10 failsafe
	if(i_TalkDelayCheck == -1 || i_TalkDelayCheck >= 10)
	{
		SmiteNpcToDeath(npc.index);
		return;
	}
	if(f_TalkDelayCheck > GetGameTime())
		return;

	f_TalkDelayCheck = GetGameTime() + 4.0;

	switch(npc.m_iTalkWaveAt)
	{
		//data is "1"
		case 1:
		{
			NpcTalker_Wave1Talk(npc);
		}
		case 2:
		{
			NpcTalker_Wave5Talk(npc);
		}
		case 3:
		{
			NpcTalker_Wave10Talk(npc);
		}
		case 4:
		{
			NpcTalker_Wave11Talk(npc);
		}
		case 5:
		{
			NpcTalker_Wave15Talk(npc);
		}
		case 6:
		{
			NpcTalker_Wave20Talk(npc);
		}
		case 7:
		{
			NpcTalker_Wave21Talk(npc);
		}
		case 8:
		{
			NpcTalker_Wave25Talk(npc);
		}
		case 9:
		{
			NpcTalker_Wave30Talk(npc);
		}
		case 10:
		{
			NpcTalker_Wave31Talk(npc);
		}
		case 11:
		{
			NpcTalker_Wave36Talk(npc);
		}
		case 12:
		{
			NpcTalker_Wave37Talk(npc);
		}
		case 13:
		{
			NpcTalker_Wave38Talk(npc);
		}
		
	}
	if(i_TalkDelayCheck != -1)
	{
		i_TalkDelayCheck++;
	}
}

//
// SHARED RAID BOSS FUNCTIONS
//

void Aperture_Shared_LastStandSequence_Starting(CClotBody npc)
{
	float gameTime = GetGameTime();
	
	SetEntProp(npc.index, Prop_Data, "m_iHealth", 1);
	
	RemoveAllBuffs(npc.index, true, false);
	NPCStats_RemoveAllDebuffs(npc.index);
	ApplyStatusEffect(npc.index, npc.index, "Last Stand", FAR_FUTURE);
	ApplyStatusEffect(npc.index, npc.index, "Solid Stance", FAR_FUTURE);
	
	ReviveAll(true);
	
	if (npc.m_iState == APERTURE_BOSS_CHIMERA)
	{
		npc.SetActivity("ACT_MP_STAND_LOSERSTATE");
		
		if(IsValidEntity(npc.m_iWearable5))
			RemoveEntity(npc.m_iWearable5);
	}
	else
	{
		npc.SetActivity("ACT_MP_STUN_MIDDLE");
		npc.AddGesture("ACT_MP_STUN_BEGIN");
		
		if(IsValidEntity(npc.m_iWearable2))
			RemoveEntity(npc.m_iWearable2);
		
		if(IsValidEntity(npc.m_iWearable1))
			RemoveEntity(npc.m_iWearable1);
	}
	
	npc.SetPlaybackRate(0.0);
	
	b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true; //Make allied npcs ignore him.
	b_NpcIsInvulnerable[npc.index] = true;
	
	npc.m_bDissapearOnDeath = true;
	npc.m_flSpeed = 0.0;
	npc.m_bisWalking = false;
	npc.StopPathing();
	
	npc.m_flArmorCount = 0.0;
	
	RaidModeScaling = 0.0;
	RaidModeTime = gameTime + APERTURE_LAST_STAND_TIMER_TOTAL;
	if(CurrentModifOn() == 1)
	{
		RaidModeTime = FAR_FUTURE;
	}
	EmitSoundToAll(g_ApertureSharedStunStartSound, npc.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, 90, BOSS_ZOMBIE_VOLUME, 85);
	
	npc.m_flNextThinkTime = gameTime + APERTURE_LAST_STAND_TIMER_BEFORE_INVULN;
	
	func_NPCDeath[npc.index] = Aperture_Shared_LastStandSequence_NPCDeath;
	func_NPCOnTakeDamage[npc.index] = Aperture_Shared_LastStandSequence_OnTakeDamage;
	func_NPCThink[npc.index] = Aperture_Shared_LastStandSequence_ClotThink;
	
	npc.m_iAnimationState = APERTURE_LAST_STAND_STATE_STARTING;
	
	i_LastStandBossRef = EntIndexToEntRef(npc.index);
}

static void Aperture_Shared_LastStandSequence_AlmostHappening(CClotBody npc)
{
	int healthToSet = RoundToNearest(ReturnEntityMaxHealth(npc.index) * APERTURE_LAST_STAND_HEALTH_MULT);
	SetEntProp(npc.index, Prop_Data, "m_iHealth", healthToSet);
	
	fl_MaxDamagePerPlayer = (healthToSet * 2.0) / CountPlayersOnRed();
	for (int i = 0; i < sizeof(fl_PlayerDamage); i++)
		fl_PlayerDamage[i] = 0.0;
	
	EmitSoundToAll(g_ApertureSharedStunMainSound, npc.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, 90, BOSS_ZOMBIE_VOLUME, 85);
	
	Event event = CreateEvent("show_annotation");
	if (event)
	{
		float vecPos[3];
		GetAbsOrigin(npc.index, vecPos);
		vecPos[2] += 160.0; // hardcoded lollium!
		
		// Can't translate npc names in annotations!
		char message[128];
		if(CurrentModifOn() != 1)
		{
			FormatEx(message, 128, "Choose to spare or kill %s!\nYou DO NOT have to kill it to proceed!", c_NpcName[npc.index]);
		}
		else
		{
			FormatEx(message, 128, "Kill %s.", c_NpcName[npc.index]);
		}
		
		event.SetFloat("worldPosX", vecPos[0]);
		event.SetFloat("worldPosY", vecPos[1]);
		event.SetFloat("worldPosZ", vecPos[2]);
		event.SetFloat("lifetime", APERTURE_LAST_STAND_TIMER_TOTAL);
		event.SetString("text", message);
		event.SetString("play_sound", "vo/null.mp3");
		event.SetInt("id", npc.index); //What to enter inside? Need a way to identify annotations by entindex!
		event.Fire();
	}
	
	npc.m_iAnimationState = APERTURE_LAST_STAND_STATE_ALMOST_HAPPENING;
}

static void Aperture_Shared_LastStandSequence_Happening(CClotBody npc)
{
	b_NpcIsInvulnerable[npc.index] = false; // NPCs should still not target this boss
	npc.m_iAnimationState = APERTURE_LAST_STAND_STATE_HAPPENING;
}

// Shared NPC functions

public void Aperture_Shared_LastStandSequence_ClotThink(int entity)
{
	CClotBody npc = view_as<CClotBody>(entity);
	float gameTime = GetGameTime();
	
	if (IsValidEntity(RaidBossActive) && RaidModeTime < gameTime)
	{
		// Boss was spared!
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		npc.m_iAnimationState = APERTURE_LAST_STAND_STATE_SPARED;
		RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
		
		return;
	}
	
	npc.Update();
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	if (npc.m_iAnimationState == APERTURE_LAST_STAND_STATE_STARTING)
	{
		Aperture_Shared_LastStandSequence_AlmostHappening(npc);
		npc.m_flNextThinkTime = gameTime + APERTURE_LAST_STAND_TIMER_INVULN - APERTURE_LAST_STAND_TIMER_BEFORE_INVULN;
		return;
	}
	
	if (npc.m_iAnimationState == APERTURE_LAST_STAND_STATE_ALMOST_HAPPENING)
	{
		Aperture_Shared_LastStandSequence_Happening(npc);
		npc.m_flNextThinkTime = gameTime + 1.0;
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 1.0;
}

public Action Aperture_Shared_LastStandSequence_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	// Don't bother on Chaos Intrusion
	if (CurrentModifOn() == 1)
		return Plugin_Continue;
	
	// We're massively reducing damage if players dealt too much damage to bosses in the spare/kill sequence
	const float damageReduction = 0.025;
	
	if (attacker <= 0 || attacker > MaxClients)
	{
		// If somehow, something that isn't a player attacked the boss, lower the damage at all times
		damage *= damageReduction;
		return Plugin_Changed;
	}
	
	// They just reached the threshold, account for the remainder
	if (fl_PlayerDamage[attacker] < fl_MaxDamagePerPlayer && fl_PlayerDamage[attacker] + damage > fl_MaxDamagePerPlayer)
	{
		float fullDamage = fl_MaxDamagePerPlayer - fl_PlayerDamage[attacker];
		float remainder = (damage - fullDamage) * damageReduction;
		damage = fullDamage + remainder;
	}
	else if (fl_PlayerDamage[attacker] >= fl_MaxDamagePerPlayer)
	{
		damage *= damageReduction;
	}
	
	fl_PlayerDamage[attacker] += damage;
	return Plugin_Changed;
}

public void Aperture_Shared_LastStandSequence_NPCDeath(int entity)
{
	CClotBody npc = view_as<CClotBody>(entity);
	
	float vecPos[3];
	WorldSpaceCenter(npc.index, vecPos);
	if (npc.m_iAnimationState != APERTURE_LAST_STAND_STATE_SPARED)
	{
		// Boss was killed!
		EmitSoundToAll(g_ApertureSharedStunExplosionSound, npc.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, 90, BOSS_ZOMBIE_VOLUME, 85);
		ParticleEffectAt(vecPos, APERTURE_LAST_STAND_EXPLOSION_PARTICLE, 0.5);
		
		i_ApertureBossesDead |= npc.m_iState;
		npc.m_iAnimationState = APERTURE_LAST_STAND_STATE_KILLED;
	}
	else
	{
		EmitSoundToAll(g_ApertureSharedStunTeleportSound, npc.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, 90, BOSS_ZOMBIE_VOLUME, 85);
		ParticleEffectAt(vecPos, "teleported_blue", 0.5);
	}
	
	Event event = CreateEvent("hide_annotation");
	if (event)
	{
		event.SetInt("id", npc.index);
		event.Fire();
	}
	
	StopSound(npc.index, SNDCHAN_AUTO, g_ApertureSharedStunMainSound);
	i_LastStandBossRef = INVALID_ENT_REFERENCE;
	
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
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);
	if(IsValidEntity(npc.m_iWearable8))
		RemoveEntity(npc.m_iWearable8);
}

bool Aperture_ShouldDoLastStand()
{
	return StrContains(WhatDifficultySetting_Internal, "Laboratories") == 0;
}

int Aperture_GetLastStandBoss()
{
	return i_LastStandBossRef;
}

bool Aperture_IsBossDead(int type)
{
	return (i_ApertureBossesDead & type) != 0;
}



stock void NpcTalker_Wave1Talk(Talker npc)
{
	if(npc.m_iRandomTalkNumber == -1)
	{
		//no random asigned yet. get one.
		npc.m_iRandomTalkNumber = GetRandomInt(0,2);
		/*
		Example if aris death does smth:
		if(Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(3,4);
		}

		*/
	}
	switch(npc.m_iRandomTalkNumber)
	{
		case 0:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 드디어 그 날이 왔군. 환영합니다, 엑스-");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 잠깐... 센서를 다시 보니, 당신은 그들이 아니군.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: 시스템에서 당신들 중 누구도 그들과 관련이 없다고 하는데...");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: 아마도 그런 탓에 자가 방어 시스템이 가동된 것 같군요.");
				}
				case 5:
				{
					CPrintToChatAll("{rare}???{default}: 그렇지만 그럴만한 이유가 있었을지도 모르지...");
				}
				case 6:
				{
					CPrintToChatAll("{rare}???{default}: 여기서 뭘 하고 있었고, 이곳은 어떻게 찾아낸 겁니까?");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 1:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 아, 드디어. 우리가 마지막으로 본 지가 벌써 몇 년도-");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 그러니까...잠깐만, 당신은 누구지?");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: 스캐너에도 당신이 이곳의 직원이라고 표시되진 않는데.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: 아마도 그런 탓에 자가 방어 시스템이 가동된 것 같고...");
				}
				case 5:
				{
					CPrintToChatAll("{rare}???{default}: 그렇지만 그럴만한 이유가 있었을지도 모르지...");
				}
				case 6:
				{
					CPrintToChatAll("{rare}???{default}: 누가 당신을 이곳으로 보낸겁니까? 그럴리가 없을텐데.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 2:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 마침내, 내 창조주들과 다시 만남을-");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 어... 당신이 아닌데.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: 당신의 데이터가... 흐릿한 탓에 코드를 역분석해야 할 것 같습니다.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: 그래서 자가 방어 시스템이 가동된 듯 하고.");
				}
				case 5:
				{
					CPrintToChatAll("{rare}???{default}: 그렇지만 그럴만한 이유가 있었을지도 모르지...");
				}
				case 6:
				{
					CPrintToChatAll("{rare}???{default}: 우연히 발견한게 아닐텐데, 이 장소는 어떻게 찾아온 거죠?");
					i_TalkDelayCheck = -1;
				}
			}
		}
	}
}



stock void NpcTalker_Wave5Talk(Talker npc)
{
	if(npc.m_iRandomTalkNumber == -1)
	{
		//no random asigned yet. get one.
		npc.m_iRandomTalkNumber = GetRandomInt(0,2);
		/*
		Example if aris death does smth:
		if(Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(3,4);
		}

		*/
	}
	switch(npc.m_iRandomTalkNumber)
	{
		case 0:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 여기 계시면 안 됩니다.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 당신이 누구인지는 모르겠지만, 이 파일에는 당신이 위협적인 존재라고 되어있습니다.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: 전 자유 의지가 있기 때문에, 이 경고를 따르지 않을 자유가 있지만요.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: 하지만 무언가 의도가 있어서 여기에 들어온 거겠죠.");
				}
				case 5:
				{
					CPrintToChatAll("{rare}???{default}: 그리고, 당신을 상대하는 것 말고도, 대체 무엇이 이 관문들을 개방하고 있는지 알아내는 것도 시급합니다.");
				}
				case 6:
				{
					CPrintToChatAll("{rare}???{default}: 오늘 참 이상한데...");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 1:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 여길 떠나셔야합니다.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 제가 외부 세계에 대한 지식이 좀 제한적인데다가, 이 파일엔 당신이 위협적인 존재라고 표시되어있군요.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: 그나마 전 자유 의지가 있기 때문에, 이 경고를 맹목적으로 따를 이유가 없습니다.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: 하지만 무언가 의도가 있어서 여기에 들어온 거겠죠.");
				}
				case 5:
				{
					CPrintToChatAll("{rare}???{default}: 그리고, 당신을 상대해야 하는 것 외에도, 이 관문들을 멈출 방법을 찾아야 합니다.");
				}
				case 6:
				{
					CPrintToChatAll("{rare}???{default}: 흥미롭군...");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 2:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 당신은 이 장소에 있을 수 없습니다.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 당신이 누구인지 잘 모르겠지만, 적어도 연구소는 전혀 관계가 없는 존재란건 확실합니다.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: 시스템이 당장 당신을 내보내라고 경고하고 있지만, 그건... 제 자유 의지에 따라 어떻게 될 지는 모르죠.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: 하지만 무언가 의도가 있어서 여기에 들어온 거겠죠.");
				}
				case 5:
				{
					CPrintToChatAll("{rare}???{default}: 그리고, 당신을 상대해야 하는 것 외에도, 이 관문들을 멈출 방법을 찾아야 합니다.");
				}
				case 6:
				{
					CPrintToChatAll("{rare}???{default}: 참 흥미로운데...");
					i_TalkDelayCheck = -1;
				}
			}
		}
	}
}



stock void NpcTalker_Wave10Talk(Talker npc)
{
	if(npc.m_iRandomTalkNumber == -1)
	{
		//no random asigned yet. get one.
		npc.m_iRandomTalkNumber = GetRandomInt(0,2);
		/*
		Example if aris death does smth:
		if(Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(3,4);
		}

		*/
	}
	switch(npc.m_iRandomTalkNumber)
	{
		case 0:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 아... 좀 진작에 전해드렸어야 했는데, 아주 오래전에 오직 한 가지 임무, 즉 연구소를 지키는 임무만을 위해 설계된 로봇들이 있었어요.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 누구로부터 연구소를 지키냐고요? 음... 파일에 따르면 당신과 같은 존재들로부터.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: 조만간 당신이 그 로봇 중 하나와 마주치게 될 가능성이 높다고 생각하셔야 할 겁니다.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: 그중에 하나는 무단 침입자를 막기 위한 일종의 감시 장치로 설계되었죠.");
				}
				case 5:
				{
					CPrintToChatAll("{rare}???{default}: 전 분명 나갈 수 있을 때 나가라고 경고했었는데, 계속 여기 남아있으신거라면 더 이상 해드릴 조언이 없군요.");
				}
				case 6:
				{
					CPrintToChatAll("{rare}???{default}: 정말로 길을 잃어서 이 곳에 들어오신거라면, 그냥 가만히 계셔야합니다. 그럼 로봇도 당신을 안전하게 연구소 밖으로 데리고 나갈 겁니다.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 1:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 더 일찍 얘기해드렸어야 했는데, 아주 오래전에 오직 한 가지 목적, 즉 연구소를 지키는 것만을 위해 설계된 로봇들이 있었습니다.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 네, 뭐... 당신과 같은 존재들로부터 말이죠.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: 조만간 그 로봇들 중 하나와 맞닥뜨리게 될 가능성이 높습니다.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: 그중에 하나는 무단 침입자를 막기 위한 일종의 감시 장치로 설계되었죠.");
				}
				case 5:
				{
					CPrintToChatAll("{rare}???{default}: 전 분명 나갈 수 있을 때 나가라고 경고했었는데, 계속 여기 남아있으신거라면 더 이상 해드릴 조언이 없군요.");
				}
				case 6:
				{
					CPrintToChatAll("{rare}???{default}: 정말로 길을 잃어서 이 곳에 들어오신거라면, 그냥 가만히 계셔야합니다. 그럼 로봇도 당신을 안전하게 연구소 밖으로 데리고 나갈 겁니다.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 2:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 지금 말하기엔 좀 늦었을 수도 있지만, 오래전에 연구소를 지키는 단 하나의 목적을 위해 설계된 로봇들이 있었습니다.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 파일에 따르면, 그 로봇들은 당신과 같은 존재들로부터 연구소를 지키기 위해 만들어졌습니다.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: 조만간 이 로봇들 중 하나와 마주치게 될 수도 있다는 뜻입니다.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: 그중에 하나는 무단 침입자를 막기 위한 일종의 감시 장치로 설계되었죠.");
				}
				case 5:
				{
					CPrintToChatAll("{rare}???{default}: 전 분명 나갈 수 있을 때 나가라고 경고했었는데, 계속 여기 남아있으신거라면 더 이상 해드릴 조언이 없군요.");
				}
				case 6:
				{
					CPrintToChatAll("{rare}???{default}: 정말로 길을 잃어서 이 곳에 들어오신거라면, 그냥 가만히 계셔야합니다. 그럼 로봇도 당신을 안전하게 연구소 밖으로 데리고 나갈 겁니다.");
					i_TalkDelayCheck = -1;
				}
			}
		}
	}
}



stock void NpcTalker_Wave11Talk(Talker npc)
{
	if(npc.m_iRandomTalkNumber == -1)
	{
		//no random asigned yet. get one.
		npc.m_iRandomTalkNumber = GetRandomInt(0,2);

		if(Aperture_IsBossDead(APERTURE_BOSS_CAT))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(3,5);
		}

	}
	switch(npc.m_iRandomTalkNumber)
	{
		case 0:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 드디어 당신이 무엇인지 알아냈습니다! 여기에 당신의 종족이...인간이라고 나와 있군요.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 그런데 왜 당신이 위협으로 표시되었는지는 잘 모르겠습니다.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: 딱히 폭력적인 성향은 보이지 않는 것 같은데요.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: 그러니까... 이곳의 다른 인간들을 죽인 것 빼고는.");
				}
				case 5:
				{
					CPrintToChatAll("{rare}???{default}: 뭐, 아마 괜찮겠죠. 저건 진짜 본인들이 아니라 복제물일 뿐이니까요.");
				}
				case 6:
				{
					CPrintToChatAll("{rare}???{default}: 아마도.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 1:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 이 데이터를 가져오는 데 시간이 좀 걸렸지만, 당신의 종족은 인간이라는 걸 알아냈습니다.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 데이터에 따르면 당신은 폭력적인 성향을 보이는 경향이 있다고 합니다.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: 음, 데이터가 잘못된 것 같습니다. 당신이 지금 폭력적인 성향을 보이지 않는 것 같은데요.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: 그러니까... 이곳의 다른 인간들을 죽인 것 빼고는.");
				}
				case 5:
				{
					CPrintToChatAll("{rare}???{default}: 뭐, 아마 괜찮겠죠. 저건 진짜 본인에게 영향이 가는 것도 아닌 복제물들이니까요.");
				}
				case 6:
				{
					CPrintToChatAll("{rare}???{default}: 아마도.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 2:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 당신의 종족을 조사하는 것은 쉬운 일이 아니었습니다만, 이제 당신의 종족이 인간이라는 것을 알았습니다.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 제 조사에 따르면 인간은 폭력적인 경향이 있습니다..");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: 그런데 어쩌면 제 조사가 잘못되었을 수도 있습니다. 당신은 폭력적인 성향을 보이지 않았으니까요.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: 그러니까... 이곳의 다른 인간들을 죽인 것 빼고는.");
				}
				case 5:
				{
					CPrintToChatAll("{rare}???{default}: 뭐, 아마 괜찮겠죠. 저건 진짜 본인들이 아닙니다.");
				}
				case 6:
				{
					CPrintToChatAll("{rare}???{default}: 아마도.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 3:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 드디어 당신이 무엇인지 알아냈어요. 여길 보니 당신의 종족은... 인간이군요.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 당신이 왜 위협적인 존재로 표시되었는지 이제 좀 이해가 가는군.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: 걔가 당신을 죽이려 했던건 알아요. 하지만 방금은 잠깐동안 무방비 상태가 됐었죠.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: 그런데도... 당신은 그 틈을 타서 그걸 또 부품째로 분해해버렸죠.");
				}
				case 5:
				{
					CPrintToChatAll("{rare}???{default}: 이제부터 당신을 계속 지켜봐야겠습니다.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 4:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 이 데이터를 가져오는 데 시간이 좀 걸렸지만, 당신의 종족은 인간입니다.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 데이터에 따르면 당신은 폭력적인 성향을 보이는 경향이 있다고 합니다.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: 데이터가 정확한 것 같군요.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: 걔가 당신을 죽이려 했던건 알아요. 하지만 방금은 잠깐동안 무방비 상태가 됐었죠.");
				}
				case 5:
				{
					CPrintToChatAll("{rare}???{default}: 그런데도... 당신은 그 점을 이용해 그걸 산산조각내버렸죠.");
				}
				case 6:
				{
					CPrintToChatAll("{rare}???{default}: 이제부터 당신을 면밀히 관찰하겠습니다.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 5:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 당신의 종족을 조사하는 것은 쉬운 일이 아니었습니다만, 당신의 종족이 인간이란 것을 알아냈습니다.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 제 조사에 따르면 인간은 폭력적인 경향이 있습니다.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: 그리고 당신이 방금 한 행동을 보면 제 조사에는 확실히 오류가 없군요.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: 걔가 당신을 죽이려 했던건 알아요. 하지만 방금은 잠깐동안 무방비 상태가 됐었죠.");
				}
				case 5:
				{
					CPrintToChatAll("{rare}???{default}: 그런데도... 당신은 그 점을 이용해 흔적도 없이 부숴버렸어요.");
				}
				case 6:
				{
					CPrintToChatAll("{rare}???{default}: 이제부터 당신을 예의주시할 겁니다.");
					i_TalkDelayCheck = -1;
				}
			}
		}
	}
}



stock void NpcTalker_Wave15Talk(Talker npc)
{
	if(npc.m_iRandomTalkNumber == -1)
	{
		//no random asigned yet. get one.
		npc.m_iRandomTalkNumber = GetRandomInt(0,2);

		if(Aperture_IsBossDead(APERTURE_BOSS_CAT))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(3,5);
		}

	}
	switch(npc.m_iRandomTalkNumber)
	{
		case 0:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 도대체 왜 인간이 이 파일 목록에 고유한 범주까지 가지고 있을까요.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 예전에는 이런 것보다 훨씬 더 큰 위협이 있었는데 말이죠.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: 어쩌면 그들의 회복탄력성 때문일지도 모르죠.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 1:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 아직도 이 인간이 왜 이 파일 목록에 위협이라고 표시되어있는지 모르겠습니다.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 당신은 우리가 처리해야 할 위협에 비하면 그다지 큰 위협도 아닙니다.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: 어쩌면 당신의 회복탄력성 때문일지도요?");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 2:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 왜 당신이 이 파일들 속에서 위협으로 표기되어있을까요? 이해할 수가 없군요.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 당신은 우리가 처리해야 할 위협에 비하면 아주 작은 위협에 불과합니다.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: 어쩌면 당신의 회복탄력성 때문일지도 모르겠습니다?");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 3:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 당신이 저지른 일이 불만족스럽군요.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: C.A.T. 은 그저 프로그래밍 명령을 따라야했을 뿐이라고요.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: 역시나 파일대로 그들은 폭력적인 성향을 따르는건가.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 4:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 당신이 저지른 일이 개탄스럽군요.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: C.A.T. 은 그저 프로그래밍 명령을 따라야했을 뿐이라고요.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: 지금 하고 있는 일에 대해 다시 생각해보시는게 좋을 겁니다.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 5:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 당신이 저지른 일이 정말 한탄스럽군요.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: C.A.T. 은 그저 프로그래밍 명령을 따라야했을 뿐이라고요.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: 당신이 걸어가는 방향을 바꾸지 않는다면 지금 그 길이 당신의 마지막 길이 될 수도 있습니다.");
					i_TalkDelayCheck = -1;
				}
			}
		}
	}
}



stock void NpcTalker_Wave20Talk(Talker npc)
{
	if(npc.m_iRandomTalkNumber == -1)
	{
		//no random asigned yet. get one.
		npc.m_iRandomTalkNumber = GetRandomInt(0,2);

		if(Aperture_IsBossDead(APERTURE_BOSS_CAT))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(3,5);
		}

	}
	switch(npc.m_iRandomTalkNumber)
	{
		case 0:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 당신은 이 건물에서 나가달라는 제 요청을 고의로 무시했습니다.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 그건 회복탄력성이 아니라 고집입니다.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: 애초에, C.A.T. 이 당신을 연구소 밖으로 안내하려 했을텐데, 당신이 그 도움을 거부했었죠.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: 지금 당신에게 무슨 일이 일어나든 당신은 스스로 자초한 일입니다.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 1:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 당신은 제가 수없이 요청했음에도 불구하고 연구소를 떠나지 않는군요.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 그건 회복탄력성이 아니라 고집입니다.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: 그리고, C.A.T. 이 당신을 연구소에서 내보내려는 것도 고의로 거부했었죠.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: 이후 당신에게 벌어질 일은 당신의 선택이 낳은 결과입니다.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 2:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 제 요청에도 불구하고 당신은 계속 연구소에 남아있었군요.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 그건 회복탄력성이 아니라 고집입니다.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: 그리고 C.A.T. 의 안내도 고의로 거부했었죠.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: 당신에게 들이닥칠 운명이 뭐든간에, 당신이 자초한 일이겠죠.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 3:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 당신은 이 건물에서 나가달라는 제 요청을 고의로 무시했고,");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: C.A.T. 도 산산조각냈죠.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: 그럼 이제 남은건 침입자를 가장 비살상적인 방법으로 쫓아내도록 설계된 로봇과 대면하는 것 뿐.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: 이제 당신에게 무슨 일이 일어나든 제 알 바가 아닙니다.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 4:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 당신은 이 건물에서 나가달라는 제 요청을 수없이 무시했고,");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: C.A.T. 도 무자비하게 파괴했죠.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: 그럼 이제 남은건 침입자를 가장 비살상적인 방법으로 쫓아내도록 설계된 로봇과 대면하는 것 뿐.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: 당신에게 무슨 일이 일어나든간에 제 탓하지 마시죠.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 5:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 당신은 여기서 나가달라는 제 요청에도 불구하고 아직까지 연구소에 남아있군요.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 그래, C.A.T. 에게 저지른 일도 잊을 수 없고.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: 프로그래밍에 예속된 존재도 그렇게 무자비하게 파괴하다니.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: 뿌린대로 거둔다고 하잖아요.");
					i_TalkDelayCheck = -1;
				}
			}
		}
	}
}



stock void NpcTalker_Wave21Talk(Talker npc)
{
	if(npc.m_iRandomTalkNumber == -1)
	{
		//no random asigned yet. get one.
		npc.m_iRandomTalkNumber = GetRandomInt(0,2);

		//C.A.T. Dead, A.R.I.S Alive
		if(Aperture_IsBossDead(APERTURE_BOSS_CAT) && !Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(3,4);
		}
		//C.A.T. Alive, A.R.I.S Dead
		if(!Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(5,6);
		}
		//C.A.T. Dead, A.R.I.S Dead
		if(Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(7,7);
		}

	}
	switch(npc.m_iRandomTalkNumber)
	{
		//Canon Route
		case 0:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 그러니까 A.R.I.S. 를 뛰어넘으셨군요.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 솔직히 말해서, 당신의 능력을 과소평가한 것 같습니다.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: 만약 계속 남아있겠다고 고집 피우신다면, 저도 어쩔 수 없이 직접 당신과 맞서야할 겁니다.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: 폭력을 쓰는건 별로지만... 당신이 저에게 선택권을 남겨주시지는 않는군요.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 1:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: A.R.I.S. 를 뛰어넘으셨군요.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 솔직히 말해서, 당신의 능력을 과소평가한 것 같습니다.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: 하지만 계속 이렇게 남아있겠다고 고집 피우신다면, 저도 어쩔 수 없이 직접 당신과 맞설겁니다.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: 폭력을 쓰는건 별로지만... 당신이 저에게 선택권을 남겨주시지는 않는군요.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 2:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 방금 A.R.I.S. 를 넘으셨군요.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 그래요, 솔직히 당신의 능력을 과소평가한 것 같습니다.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: 그렇지만 이런 식으로 계속 고집을 피우신다면, 저도 어쩔 수 없이 직접 당신과 맞서야합니다.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: 폭력을 쓰는건 별로지만... 당신이 저에게 선택권을 남겨주시지는 않는군요.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		//C.A.T. Dead, A.R.I.S Alive
		case 3:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 이제 와서 회개한다고 변하는 건 없지.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 갑자기 마음이 바뀌었다고 해서 이전에 제가 당신이 이전에 저지른걸 잊을 리가 없습니다.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: 당신이 계속 여기에 머물겠다고 고집을 피우면, 저도 직접 당신과 맞설 수밖에 없고.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: 폭력을 쓰고 싶지는 않지만... 절박한 상황에서는 누군가 나서야하니까.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 4:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 당신이 갑자기 마음을 바꾼다고 해서 제가 당신이 저지른 일을 잊을 거라고 생각하는 겁니까?");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 그건 회개가 아니라 기만이라고.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: 당신이 계속 여기에 머물겠다고 고집을 피우면, 저도 직접 당신과 맞설 수밖에 없고.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: 폭력을 쓰고 싶지는 않지만... 절박한 상황에서는 누군가 나서야하니까.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		//C.A.T. Alive, A.R.I.S Dead
		case 5:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: ...진심으로?");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 걔가 당신에게 뭘 잘못했기에 분해해버린겁니까?");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: C.A.T. 은 살려보냈으면서 A.R.I.S. 는 그대로 파괴하다니?");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: 나도 폭력을 쓰고 싶지는 않지만... 절박한 상황에서는 누군가 나서야하지.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 6:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: ...진심으로?");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 걔가 당신에게 뭘 잘못했기에 파괴한 겁니까?");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: C.A.T. 을 살려준 당시와 반응이 너무 다르잖아?");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: 나도 폭력을 쓰고 싶지는 않지만... 위급한 상황에서는 누군가 맞서야만 하니까.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		//Locked in Genocide
		case 7:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: ...");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: {crimson}그렇게 나오겠다 이거지.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: {crimson}나중에 두고보자고.");
				}
				case 4:
				{
					CPrintToChatAll("{crimson}당신은 심상치 않은 불안감이 느껴졌습니다....");
					i_TalkDelayCheck = -1;
				}
			}
		}
	}
}



stock void NpcTalker_Wave25Talk(Talker npc)
{
	if(npc.m_iRandomTalkNumber == -1)
	{
		//no random asigned yet. get one.
		npc.m_iRandomTalkNumber = GetRandomInt(0,1);

		//C.A.T. Dead, A.R.I.S Alive
		if(Aperture_IsBossDead(APERTURE_BOSS_CAT) && !Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(3,3);
		}
		//C.A.T. Alive, A.R.I.S Dead
		if(!Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(5,5);
		}
		//C.A.T. Dead, A.R.I.S Dead
		if(Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(7,7);
		}

	}
	switch(npc.m_iRandomTalkNumber)
	{
		//Canon Route
		case 0:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 분명히, 당신이 아무 이유 없이 이 장소에 오신건 아닐텐데요.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 그럼, 당신은 도대체 누가 보낸겁니까?");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: {unique}엑스피돈사인{default}들이 보냈을거라는 짐작은 되는데.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: 어, 당신은 {unique}엑스피돈사{default}가 뭔지도 모르시겠군요.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 1:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 그래서, 당신에게 이 장소를 알려준건 누구입니까?");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 여긴 절대로 혼자 올 수 있는 곳이 아닌데요.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: {unique}엑스피돈사{default}의 요청인가요?");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: 아니, 혹시 {unique}엑스피돈사{default}가 뭔지는 아십니까?");
					i_TalkDelayCheck = -1;
				}
			}
		}
		//C.A.T. Dead, A.R.I.S Alive
		case 3:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 이곳에 그냥 들어올 수 있을리가 없을텐데.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 그래서, 당신은 누가 보냈죠?");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: 여기서 날뛰라고 요청한 자 말입니다.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: 아니면 뭐 다른 목적이 있기라도 합니까?");
					i_TalkDelayCheck = -1;
				}
			}
		}
		//C.A.T. Alive, A.R.I.S Dead
		case 5:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 이곳에 그냥 들어올 수 있을리가 없을텐데.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 그래서, 당신은 누가 보냈죠?");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: 여기서 날뛰라고 요청한 자 말입니다?");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: 아니면 뭐 다른 목적이 있기라도 합니까?");
					i_TalkDelayCheck = -1;
				}
			}
		}
		//Locked in Genocide
		case 7:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					i_TalkDelayCheck = -1;
				}
			}
		}
	}
}



stock void NpcTalker_Wave30Talk(Talker npc)
{
	if(npc.m_iRandomTalkNumber == -1)
	{
		//no random asigned yet. get one.
		npc.m_iRandomTalkNumber = GetRandomInt(0,0);

		//C.A.T. Dead, A.R.I.S Alive
		if(Aperture_IsBossDead(APERTURE_BOSS_CAT) && !Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(3,3);
		}
		//C.A.T. Alive, A.R.I.S Dead
		if(!Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(5,5);
		}
		//C.A.T. Dead, A.R.I.S Dead
		if(Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(7,7);
		}

	}
	switch(npc.m_iRandomTalkNumber)
	{
		//Canon Route
		case 0:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 하지만 그들이 당신을 여기로 보낸 거라면...");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 이곳에 냉동 보관된 인간들이 많았던 이유가 설마...");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: 연구소로 인간들을 유인해서... 그렇게...");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: 아니, 잠깐만, 뭔가 잘못 됐어... 금방, 금방 돌아올게요.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 1:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 그들이 당신을 여기로 보낼리가 없을텐데, 만약 정말로 그런거라면,");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 이곳에 왜 그리 냉동 보관된 인간들이 많았는지 설명이 되겠군요.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: 연구소로 인간들을 유인해서... 그렇게-");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: 허... 아니야, 뭔가 이상해... 잠시만요...");
					i_TalkDelayCheck = -1;
				}
			}
		}
		//C.A.T. Dead, A.R.I.S Alive
		case 3:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 그럼, 왜 아직도 여기에 있지?");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 이미 충분히 날뛴거 아닌가? 대체 얼마나 날뛰어야 만족할건데?");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: {unique}엑스피돈사{default}가 당신을 위험 인물로 취급하는걸 따랐어야했는데.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		//C.A.T. Alive, A.R.I.S Dead
		case 5:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}:  그럼, 왜 아직도 여기에 있지?");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 이미 충분히 날뛴거 아닌가? 대체 얼마나 날뛰어야 만족할건데?");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: {unique}엑스피돈사{default}가 당신을 위험 인물로 취급하는걸 따랐어야했는데.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		//Locked in Genocide
		case 7:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					i_TalkDelayCheck = -1;
				}
			}
		}
	}
}


stock void NpcTalker_Wave31Talk(Talker npc)
{
	if(npc.m_iRandomTalkNumber == -1)
	{
		//C.A.T. Alive, A.R.I.S Alive, C.H.I.M.E.R.A. Alive
		if(!Aperture_IsBossDead(APERTURE_BOSS_CAT) && !Aperture_IsBossDead(APERTURE_BOSS_ARIS) && !Aperture_IsBossDead(APERTURE_BOSS_CHIMERA))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(1,2);
		}
		//C.A.T. Alive, A.R.I.S Alive, C.H.I.M.E.R.A. Dead
		if(!Aperture_IsBossDead(APERTURE_BOSS_CAT) && !Aperture_IsBossDead(APERTURE_BOSS_ARIS) && Aperture_IsBossDead(APERTURE_BOSS_CHIMERA))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(3,4);
		}
		//C.A.T. Dead, A.R.I.S Alive
		if(Aperture_IsBossDead(APERTURE_BOSS_CAT) && !Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(5,5);
		}
		//C.A.T. Alive, A.R.I.S Dead
		if(!Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(5,5);
		}
		//C.A.T. Dead, A.R.I.S Dead
		if(Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(7,7);
		}

	}
	switch(npc.m_iRandomTalkNumber)
	{
		//C.A.T. Alive, A.R.I.S Alive, C.H.I.M.E.R.A. Alive
		case 1:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 방금 도대체 그게 뭐하는 로봇이었는지는 몰라도, 이 차원문과 관련이 있는 것 같습니다.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 이 연구소와 관련도 없고요. 그대로 두면 그 정체를 알아낼 수 있겠군요.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: 음, 그럼 다시 조사를 시작해볼까요.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 2:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 방금 그 로봇... 뭐였죠? 꼭 마치 차원문과 연결된 듯한 모습이었는데.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 게다가 또 이 연구소와 관련이 없는 존재였고. 꼭 마치 무언가를 찾으러 온 것 같았어요.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: 아, 좀 이상한 일이긴 해도, 다시 조사를 시작해야겠군요.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		//C.A.T. Alive, A.R.I.S Alive, C.H.I.M.E.R.A. Dead
		case 3:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 방금 파괴하신 그거 말인데... 도대체 뭔지 알 수가 없네요.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 그 물체가 파괴되면서 저 차원문에 영향을 준 것 같습니다. 이전보다 더 불안정해졌어요.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: 뭐, 이건 당신 책임이니까요. 전 계속 조사에 집중해야겠습니다.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 4:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 그 로봇... 그 기원은 저도 모르겠습니다. 당신이 그걸 파괴해버렸기 때문에 그것의 정체를 더 알 수 없게 되었지만요.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 제가 알아낸 바로는, 방금 그게 저 차원문들과 연결되어 있다는 겁니다. 지금은 상태가 매우 불안정해졌어요.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: 뭐, 이건 당신이 선택한 행동이니까요. 전 계속 조사에 집중해야겠습니다.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		//C.A.T. Alive, A.R.I.S Dead
		case 5:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					i_TalkDelayCheck = -1;
				}
			}
		}
		//Locked in Genocide
		case 7:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					i_TalkDelayCheck = -1;
				}
			}
		}
	}
}

stock void NpcTalker_Wave36Talk(Talker npc)
{
	if(npc.m_iRandomTalkNumber == -1)
	{
		//no random asigned yet. get one.
		npc.m_iRandomTalkNumber = GetRandomInt(0,1);

		//C.A.T. Dead, A.R.I.S Alive
		if(Aperture_IsBossDead(APERTURE_BOSS_CAT) && !Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(3,3);
		}
		//C.A.T. Alive, A.R.I.S Dead
		if(!Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(5,5);
		}
		//C.A.T. Dead, A.R.I.S Dead
		if(Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(7,7);
		}

	}
	switch(npc.m_iRandomTalkNumber)
	{
		//Canon Route
		case 0:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 제가 틀렸었군요.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 그러니까, {unique}엑스피돈사인{default}들이 당신을 파견했을 거라는 예상이 틀렸어요.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: 현재 {unique}엑스피돈사{default}의 실체를 제대로 모르고 있었으니까요.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: 그래요... 그들도 윤리적으로는 그다지 좋진 않았군요.");
				}
				case 5:
				{
					CPrintToChatAll("{rare}???{default}: 그리고, 당신의 엠블럼도 역검색을 해봤습니다.");
				}
				case 6:
				{
					CPrintToChatAll("{rare}???{default}: 당신은 일종의 용병이신거죠?");
				}
				case 7:
				{
					CPrintToChatAll("{rare}???{default}: 누군가에게 고용되어 이곳을 약탈하려는 것 같군요.");
				}
				case 8:
				{
					CPrintToChatAll("{rare}???{default}: 유감입니다만, 그렇게 둘 수는 없습니다.");
				}
				case 9:
				{
					CPrintToChatAll("{rare}???{default}: 하지만 용병들도 급여를 받고 하는 일이니까요. 당신도 목적을 달성할 때까지는 여기에 계속 머무시겠죠.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 1:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 제가 착각했습니다.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 네. {unique}엑스피돈사{default}에서 당신을 파견했을 거라는 예상은 틀렸죠.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: {unique}엑스피돈사{default}의 전체 상황을 제대로 모르고 있었거든요.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: 네, 뭐... 그들도 윤리적인 면에서는 그다지 좋진 않았더군요.");
				}
				case 5:
				{
					CPrintToChatAll("{rare}???{default}: 그리고, 당신의 엠블럼도 역검색을 해봤습니다.");
				}
				case 6:
				{
					CPrintToChatAll("{rare}???{default}: 당신은 용병이 맞으시죠?");
				}
				case 7:
				{
					CPrintToChatAll("{rare}???{default}: 누군가에게 고용되어 이곳을 약탈하려는 것 같군요.");
				}
				case 8:
				{
					CPrintToChatAll("{rare}???{default}: 유감스럽게도, 그렇게 둘 수는 없습니다.");
				}
				case 9:
				{
					CPrintToChatAll("{rare}???{default}: 하지만 용병들도 급여를 받고 하는 일이니까요. 당신도 목적을 달성할 때까지는 여기에 계속 머무시겠죠.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		//C.A.T. Dead, A.R.I.S Alive
		case 3:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 당신이 여기에 온 목적은 모르더라도, 내가 개입해야겠어.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 당신이 여기서 더 날뛰어서 대혼란을 불러오게 둘 수는 없거든.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		//C.A.T. Alive, A.R.I.S Dead
		case 5:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 당신이 여기에 온 목적은 모르더라도, 내가 개입해야겠어.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 당신이 여기서 더 날뛰어서 대혼란을 불러오게 둘 수는 없거든.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		//Locked in Genocide
		case 7:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					i_TalkDelayCheck = -1;
				}
			}
		}
	}
}


stock void NpcTalker_Wave37Talk(Talker npc)
{
	if(npc.m_iRandomTalkNumber == -1)
	{
		//no random asigned yet. get one.
		npc.m_iRandomTalkNumber = GetRandomInt(0,1);

		//C.A.T. Dead, A.R.I.S Alive
		if(Aperture_IsBossDead(APERTURE_BOSS_CAT) && !Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(3,3);
		}
		//C.A.T. Alive, A.R.I.S Dead
		if(!Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(5,5);
		}
		//C.A.T. Dead, A.R.I.S Dead
		if(Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(7,7);
		}

	}
	switch(npc.m_iRandomTalkNumber)
	{
		//Canon Route
		case 0:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 당신이 이 장비들을 가져가는 걸 허락할 수 없습니다.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 만약 이것들이 사악한 자들의 손에 들어간다면, 그 여파가 재앙에 가까워질 겁니다.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 1:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 그 장비들은 가져갈 수 없습니다. 제가 허용 못 해요.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 사악한 자들이 그 장비들을 입수한다면... 우리 세계에 어떠한 영향을 끼칠지 알 수 없습니다.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		//C.A.T. Dead, A.R.I.S Alive
		case 3:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					i_TalkDelayCheck = -1;
				}
			}
		}
		//C.A.T. Alive, A.R.I.S Dead
		case 5:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					i_TalkDelayCheck = -1;
				}
			}
		}
		//Locked in Genocide
		case 7:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					i_TalkDelayCheck = -1;
				}
			}
		}
	}
}



stock void NpcTalker_Wave38Talk(Talker npc)
{
	if(npc.m_iRandomTalkNumber == -1)
	{
		//no random asigned yet. get one.
		npc.m_iRandomTalkNumber = GetRandomInt(0,0);

		//C.A.T. Dead, A.R.I.S Alive
		if(Aperture_IsBossDead(APERTURE_BOSS_CAT) && !Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(3,3);
		}
		//C.A.T. Alive, A.R.I.S Dead
		if(!Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(5,5);
		}
		//C.A.T. Dead, A.R.I.S Dead
		if(Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(7,7);
		}

	}
	switch(npc.m_iRandomTalkNumber)
	{
		//Canon Route
		case 0:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: 아무래도 제가 개입해야겠군요.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: 유감입니다.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		//C.A.T. Dead, A.R.I.S Alive
		case 3:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					i_TalkDelayCheck = -1;
				}
			}
		}
		//C.A.T. Alive, A.R.I.S Dead
		case 5:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					i_TalkDelayCheck = -1;
				}
			}
		}
		//Locked in Genocide
		case 7:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					i_TalkDelayCheck = -1;
				}
			}
		}
	}
}