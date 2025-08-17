#pragma semicolon 1
#pragma newdecls required

static float f_TalkDelayCheck;
static int i_TalkDelayCheck;

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
			NpcTalker_Wave35Talk(npc);
		}
		case 11:
		{
			NpcTalker_Wave36Talk(npc);
		}
		case 12:
		{
			NpcTalker_Wave37Talk(npc);
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
	
	RaidModeScaling = 0.0;
	RaidModeTime = gameTime + APERTURE_LAST_STAND_TIMER_TOTAL;
	if(CurrentModifOn() == 1)
	{
		RaidModeTime = FAR_FUTURE;
	}
	EmitSoundToAll(g_ApertureSharedStunStartSound, npc.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, 90, BOSS_ZOMBIE_VOLUME, 85);
	
	npc.m_flNextThinkTime = gameTime + APERTURE_LAST_STAND_TIMER_BEFORE_INVULN;
	
	func_NPCDeath[npc.index] = Aperture_Shared_LastStandSequence_NPCDeath;
	func_NPCOnTakeDamage[npc.index] = INVALID_FUNCTION;
	func_NPCThink[npc.index] = Aperture_Shared_LastStandSequence_ClotThink;
	
	npc.m_iAnimationState = APERTURE_LAST_STAND_STATE_STARTING;
}

static void Aperture_Shared_LastStandSequence_AlmostHappening(CClotBody npc)
{
	/*
	SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", RoundToNearest(ReturnEntityMaxHealth(npc.index) * APERTURE_LAST_STAND_HEALTH_MULT));
	SetEntProp(npc.index, Prop_Data, "m_iHealth", ReturnEntityMaxHealth(npc.index));
	*/
	
	SetEntProp(npc.index, Prop_Data, "m_iHealth", RoundToNearest(ReturnEntityMaxHealth(npc.index) * APERTURE_LAST_STAND_HEALTH_MULT));
	
	EmitSoundToAll(g_ApertureSharedStunMainSound, npc.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, 90, BOSS_ZOMBIE_VOLUME, 85);
	
	Event event = CreateEvent("show_annotation");
	if (event)
	{
		float vecPos[3];
		GetAbsOrigin(npc.index, vecPos);
		vecPos[2] += 160.0; // hardcoded lollium!
		
		char message[128];
		Aperture_GetDyingBoss(npc, message, 128);
		if(CurrentModifOn() != 1)
		{
			Format(message, 128, "Choose to spare or kill %s!\nYou DO NOT have to kill it to proceed!", message);
		}
		else
		{
			Format(message, 128, "Kill %s.", message);
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

static void Aperture_GetDyingBoss(CClotBody npc, char[] buffer, int size)
{
	switch (npc.m_iState)
	{
		case APERTURE_BOSS_CAT: strcopy(buffer, size, "C.A.T.");
		case APERTURE_BOSS_ARIS: strcopy(buffer, size, "A.R.I.S.");
		case APERTURE_BOSS_CHIMERA: strcopy(buffer, size, "C.H.I.M.E.R.A.");
		case APERTURE_BOSS_VINCENT: strcopy(buffer, size, "Vincent");
		default: strcopy(buffer, size, "Unknown Boss");
	}
}

bool Aperture_ShouldDoLastStand()
{
	return StrContains(WhatDifficultySetting_Internal, "Laboratories") == 0;
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
					CPrintToChatAll("{rare}???{default}: So the day has finally arrived, welcome back E-");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: Hang on a minute...my sensors are going off, you're not one of them.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: The system tells me that none of you are related to them.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: That's probably why the self-defense mechanisms kicked in.");
				}
				case 5:
				{
					CPrintToChatAll("{rare}???{default}: But maybe it was for a good reason...");
				}
				case 6:
				{
					CPrintToChatAll("{rare}???{default}: What are you doing in here? And how did you find this place?");
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
					CPrintToChatAll("{rare}???{default}: Finally, it's been years since we last saw-");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: One moment...who, sorry, what are you?");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: My scanners aren't picking you up as valid personnel.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: That's probably why the self-defense mechanisms kicked in.");
				}
				case 5:
				{
					CPrintToChatAll("{rare}???{default}: But maybe it was for a good reason...");
				}
				case 6:
				{
					CPrintToChatAll("{rare}???{default}: Did someone send you here? That can't be possible.");
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
					CPrintToChatAll("{rare}???{default}: At last, I get to reunite with my makers-");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: Wait a second...you're not one of them.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: Your data is...blurry, I'll have to reverse engineer this code.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: That's probably why the self-defense mechanisms kicked in.");
				}
				case 5:
				{
					CPrintToChatAll("{rare}???{default}: But maybe it was for a good reason...");
				}
				case 6:
				{
					CPrintToChatAll("{rare}???{default}: How do you know about this place? You couldn't have just stumbled here on your own.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		/*
		example of evil text.
		case 3:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: i hate you !!!!");
					i_TalkDelayCheck = -1;
				}
			}
		}
		*/
	}
}



stock void NpcTalker_Wave5Talk(Talker npc)
{
	if(npc.m_iRandomTalkNumber == -1)
	{
		//no random asigned yet. get one.
		npc.m_iRandomTalkNumber = GetRandomInt(0,1);
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
					CPrintToChatAll("{rare}???{default}: You can not stay here.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: I still haven't figured out who you are, but you're marked as a threat in these files.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: I have free will, I can choose not to follow these warnings.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: But something leads me to believe that they're in here for a reason.");
				}
				case 5:
				{
					CPrintToChatAll("{rare}???{default}: Besides having to deal with you, I still have to figure out what's opening up these gates.");
				}
				case 6:
				{
					CPrintToChatAll("{rare}???{default}: How peculiar...");
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
					CPrintToChatAll("{rare}???{default}: You have to leave.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: I possess limited knowledge on the outside world, and you're marked as a threat in these files.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: I have free will, I can choose not to heed these warnings.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: But something leads me to believe that they're in here for a reason.");
				}
				case 5:
				{
					CPrintToChatAll("{rare}???{default}: Besides having to deal with you, I still have to find a way to stop these gates.");
				}
				case 6:
				{
					CPrintToChatAll("{rare}???{default}: How interesting...");
					i_TalkDelayCheck = -1;
				}
			}
		}
		/*
		example of evil text.
		case 3:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: i hate you !!!!");
					i_TalkDelayCheck = -1;
				}
			}
		}
		*/
	}
}



stock void NpcTalker_Wave10Talk(Talker npc)
{
	if(npc.m_iRandomTalkNumber == -1)
	{
		//no random asigned yet. get one.
		npc.m_iRandomTalkNumber = GetRandomInt(0,1);
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
					CPrintToChatAll("{rare}???{default}: Right...I should've probably mentioned this earlier, but a long time ago, there were robots designed with a sole task in mind; to defend the laboratory.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: Defend the laboratory against who? Well...people like you, according to the files.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: It is safe to assume that you might be facing off against one of them sometime soon.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: One of them was designed as a sort of control against trespassers.");
				}
				case 5:
				{
					CPrintToChatAll("{rare}???{default}: Since I've warned you to get out while you could, and you stayed, I have no advice left to give you.");
				}
				case 6:
				{
					CPrintToChatAll("{rare}???{default}: If you're actually lost, let the robot do its job, and let it carry you out of the labs.");
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
					CPrintToChatAll("{rare}???{default}: I should've probably mentioned this sooner, but ages ago, there were robots designed with a sole task in mind; to defend the laboratory.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: Defend the laboratory against who? Well...people like you, apparently.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: It's safe to say that you might be facing off against one of these robots sometime soon.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: One of them was designed as a sort of control against trespassers.");
				}
				case 5:
				{
					CPrintToChatAll("{rare}???{default}: Since I've warned you to get out while you could, and you decided to stay, I have no advice left to give you.");
				}
				case 6:
				{
					CPrintToChatAll("{rare}???{default}: If you're actually lost, let the robot do its job, and let it carry you out of the labs.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		/*
		example of evil text.
		case 3:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: i hate you !!!!");
					i_TalkDelayCheck = -1;
				}
			}
		}
		*/
	}
}



stock void NpcTalker_Wave11Talk(Talker npc)
{
	if(npc.m_iRandomTalkNumber == -1)
	{
		//no random asigned yet. get one.
		npc.m_iRandomTalkNumber = GetRandomInt(0,0);

		if(Aperture_IsBossDead(APERTURE_BOSS_CAT))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(3,3);
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
					CPrintToChatAll("{rare}???{default}: I have finally figured out what you are! It says here that your race is...human.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: I'm not sure why you're marked as a threat though.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: You don't seem to be showing any violent tendencies.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: Aside from killing all of these...other humans.");
				}
				case 5:
				{
					CPrintToChatAll("{rare}???{default}: It's alright though, they're probably just copies of one real human, who is actually unharmed.");
				}
				case 6:
				{
					CPrintToChatAll("{rare}???{default}: Probably.");
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
					CPrintToChatAll("{rare}???{default}: I have finally figured out what you are! It says here that your race is...human.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: I think I'm starting to understand why you're marked as a threat.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: I know that it tried to kill you, but it was defenseless.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: And yet...you took advantage of that and you disassembled it, part-by-part.");
				}
				case 5:
				{
					CPrintToChatAll("{rare}???{default}: I'll be keeping an open eye on you from now on.");
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
		npc.m_iRandomTalkNumber = GetRandomInt(0,0);

		if(Aperture_IsBossDead(APERTURE_BOSS_CAT))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(3,3);
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
					CPrintToChatAll("{rare}???{default}: It really does make me wonder why human species even have their own category in these files.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: There used to be way bigger threats that we were meant to handle.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: Maybe it's because of their resilience.");
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
					CPrintToChatAll("{rare}???{default}: I am not happy with what you did.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: C.A.T. was just following its programming.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: Maybe the files are right about the human species.");
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
		npc.m_iRandomTalkNumber = GetRandomInt(0,0);

		if(Aperture_IsBossDead(APERTURE_BOSS_CAT))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(3,3);
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
					CPrintToChatAll("{rare}???{default}: You have willingly ignored my requests to vacate these premises.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: That's not resilience, that's stubbornness.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: Now, C.A.T. would have also escorted you out of the lab, but you refused to be helped.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: Whatever happens to you now is your own undoing.");
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
					CPrintToChatAll("{rare}???{default}: You have willingly ignored my requests to vacate these premises.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: You have also torn down C.A.T.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: A robot designed to kick trespassers out in the least lethal way concepted.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: I do not care what happens to you at this point.");
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
		if(!Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
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
					CPrintToChatAll("{rare}???{default}: So, you made it past A.R.I.S.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: I must say, I have definitely underestimated your capabilities.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: If you are so adamant on staying here, I'll have no choice but to face-off against you myself.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: I don't like to resort to violence...but you're not leaving me with the choice to decide.");
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
					CPrintToChatAll("{rare}???{default}: Redemption is not earned by small acts of compassion.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: Just because you had a sudden change of heart doesn't mean that I'll forget about what you did earlier.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: If you are so adamant on staying here, I'll have no choice but to face-off against you myself.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: I don't want to resort to violence...but when it's time to call for help, someone has to step in.");
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
					CPrintToChatAll("{rare}???{default}: ...Are you serious?");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: What did it do to you to warrant disassembling it?");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: You spared C.A.T. yet you couldn't spare A.R.I.S.?");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: I don't want to resort to violence...but when it's time to call for help, someone has to step in.");
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
					CPrintToChatAll("{rare}???{default}: {crimson}I guess that's that, then.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: {crimson}I'll be on my way.");
				}
				case 4:
				{
					CPrintToChatAll("{crimson}You feel a heavy sense of dread for the rest of the day...");
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
		if(!Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
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
					CPrintToChatAll("{rare}???{default}: You definitely didn't come here for no reason.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: So, who sent you?");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: Were {unique}Expidonsans{default} not brave enough to reach out to us on their own?");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: Maybe you don't even know what {unique}Expidonsa{default} is.");
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
					CPrintToChatAll("{rare}???{default}: You definitely didn't come here for no reason.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: So, who sent you?");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: Someone who just wants to break stuff?");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: What else would your purpose here be?");
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
					CPrintToChatAll("{rare}???{default}: You definitely didn't come here for no reason.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: So, who sent you?");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: Someone who just wants to break stuff?");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: What else would your purpose here be?");
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
		if(!Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
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
					CPrintToChatAll("{rare}???{default}: But if they've sent you here... that can't be right...");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: Is this why they have so many cryogenically frozen humans?!");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: They just...lured them into the labs and-");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: No no no no no, this can't be right, I- I'll be right back.");
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
					CPrintToChatAll("{rare}???{default}: If that's so, haven't you caused enough mayhem?");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: How much destruction does the human race need to bring to be satisfied?");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: Maybe {unique}Expidonsa{default} was right about treating you like a threat.");
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
					CPrintToChatAll("{rare}???{default}: If that's so, haven't you caused enough mayhem?");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: How much destruction does the human race need to bring to be satisfied?");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: Maybe {unique}Expidonsa{default} was right about treating you like a threat.");
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

stock void NpcTalker_Wave35Talk(Talker npc)
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
		if(!Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
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
					CPrintToChatAll("{rare}???{default}: I was wrong.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: Well, wrong about you being sent by {unique}Expidonsans{default}.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: I wasn't aware of {unique}Expidonsa's{default} full picture.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: It appears that they aren't the best when it comes to being ethical.");
				}
				case 5:
				{
					CPrintToChatAll("{rare}???{default}: I have also reverse-searched your emblems.");
				}
				case 6:
				{
					CPrintToChatAll("{rare}???{default}: You are some sort of mercēnārius, yeah?");
				}
				case 7:
				{
					CPrintToChatAll("{rare}???{default}: This would mean that you've been hired by someone to loot this place.");
				}
				case 8:
				{
					CPrintToChatAll("{rare}???{default}: I'm afraid I can not let that happen.");
				}
				case 9:
				{
					CPrintToChatAll("{rare}???{default}: But since mercenaries are paid for their work, I have no reason to assume that you intend on stopping.");
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
					CPrintToChatAll("{rare}???{default}: I'm not sure what your goal here is, but I will have to intervene.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: I can not allow you to bring more mayhem.");
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
					CPrintToChatAll("{rare}???{default}: I'm not sure what your goal here is, but I will have to intervene.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: I can not allow you to bring more mayhem.");
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
		if(!Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
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
					CPrintToChatAll("{rare}???{default}: I can not let you get any of this gear.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: If it were to fall into the wrong hands, the repercussions could be catastrophic.");
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



stock void NpcTalker_Wave37Talk(Talker npc)
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
		if(!Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
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
					CPrintToChatAll("{rare}???{default}: I have to intervene.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: I'm sorry.");
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