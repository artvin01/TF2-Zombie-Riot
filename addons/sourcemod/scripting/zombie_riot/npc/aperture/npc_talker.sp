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
#define APERTURE_LAST_STAND_DAMAGE_MULT 0.2

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
	strcopy(data.Name, sizeof(data.Name), "");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_talker");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = true;
	data.Flags = -1;
	data.Category = Type_Aperture; 
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Talker(vecPos, vecAng, team, data);
}
methodmap Talker < CClotBody
{
	public Talker(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Talker npc = view_as<Talker>(CClotBody(vecPos, vecAng, "models/buildables/teleporter.mdl", "1.0", "100000000", ally, .NpcTypeLogic = 1));

		i_NpcWeight[npc.index] = 999;

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_iOverlordComboAttack = 0;
		npc.m_iBleedType = 0;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;
		npc.m_bDissapearOnDeath = true;
		f_ExtraOffsetNpcHudAbove[npc.index] = 500.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flAbilityOrAttack0 = GetGameTime(npc.index) + 2.0;
		GiveNpcOutLineLastOrBoss(npc.index, false);
		b_thisNpcHasAnOutline[npc.index] = true;
		i_TalkDelayCheck = 0;

		SetEntityRenderMode(npc.index, RENDER_NONE);

		char buffers[3][64];
		ExplodeString(data, ";", buffers, sizeof(buffers), sizeof(buffers[]));
		for (int i = 0; i < 64; i++)
		{
			if (buffers[i][0] == '\0')
				break;
			
			if (StrEqual(buffers[i], "reset"))
				i_ApertureBossesDead = APERTURE_BOSS_NONE;
		}
		
		func_NPCThink[npc.index] = view_as<Function>(Talker_ClotThink);
		
		return npc;
	}
}

public void Talker_ClotThink(Talker npc, int iNPC)
{
	//float gameTime = GetGameTime(npc.index);
	int wave = (Waves_GetRoundScale() + 1);
	//Wave 1-5
	if(wave >= 1 && wave <= 5)
	{
		int maxyapping = 6;
		if(i_TalkDelayCheck == maxyapping)
		{
			SmiteNpcToDeath(npc.index);
		}
		if(f_TalkDelayCheck < GetGameTime())
		{
			f_TalkDelayCheck = GetGameTime() + 5.0;
			i_TalkDelayCheck++;
			switch(GetRandomInt(0,2))
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
							i_TalkDelayCheck = maxyapping;
							SmiteNpcToDeath(npc.index);
						}
					}
				}
				case 1:
				{
					switch(i_TalkDelayCheck)
					{
						case 1:
						{
							CPrintToChatAll("{rare}???{default}: Finally, its been years since we last saw-");
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
							i_TalkDelayCheck = maxyapping;
							SmiteNpcToDeath(npc.index);
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
							i_TalkDelayCheck = maxyapping;
							SmiteNpcToDeath(npc.index);
						}
					}
				}
			}
		}
		//return false;
	}
	//Wave 5-10
	if(wave >= 5 && wave <= 10)
	{
		int maxyapping2 = 6;
		if(i_TalkDelayCheck == maxyapping2)
		{
			SmiteNpcToDeath(npc.index);
		}
		if(f_TalkDelayCheck < GetGameTime())
		{
			f_TalkDelayCheck = GetGameTime() + 5.0;
			i_TalkDelayCheck++;
			switch(GetRandomInt(0,1))
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
							i_TalkDelayCheck = maxyapping2;
							SmiteNpcToDeath(npc.index);
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
							i_TalkDelayCheck = maxyapping2;
							SmiteNpcToDeath(npc.index);
						}
					}
				}
			}
		}
		//return false;
	}
	//Wave 10
	if(wave >= 9 && wave <= 11)
	{
		int maxyapping = 6;
		if(i_TalkDelayCheck == maxyapping)
		{
			SmiteNpcToDeath(npc.index);
		}
		if(f_TalkDelayCheck < GetGameTime())
		{
			f_TalkDelayCheck = GetGameTime() + 5.0;
			i_TalkDelayCheck++;
			switch(GetRandomInt(0,1))
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
							i_TalkDelayCheck = maxyapping;
							SmiteNpcToDeath(npc.index);
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
							CPrintToChatAll("{rare}???{default}: It's safe to say that you might be facing off against one of the robots sometime soon.");
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
							i_TalkDelayCheck = maxyapping;
							SmiteNpcToDeath(npc.index);
						}
					}
				}
			}
		}
		//return false;
	}
	//Wave 11 - Spared CAT
	if(wave >= 10 && wave <= 12)
	{
		int maxyapping = 6;
		if(i_TalkDelayCheck == maxyapping)
		{
			SmiteNpcToDeath(npc.index);
		}
		if(f_TalkDelayCheck < GetGameTime())
		{
			f_TalkDelayCheck = GetGameTime() + 5.0;
			i_TalkDelayCheck++;
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
					i_TalkDelayCheck = maxyapping;
					SmiteNpcToDeath(npc.index);
				}
			}
		}
	}
	//Wave 11 - Killed CAT
/*	if(wave >= 10 && wave <= 12)
	{
		int maxyapping = 6;
		if(i_TalkDelayCheck == maxyapping)
		{
			SmiteNpcToDeath(npc.index);
		}
		if(f_TalkDelayCheck < GetGameTime())
		{
			f_TalkDelayCheck = GetGameTime() + 5.0;
			i_TalkDelayCheck++;
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
					CPrintToChatAll("{rare}???{default}: I know that he tried to kill you, but he was defenseless.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: And yet...you took advantage of that and you disassembled him, part-by-part.");
				}
				case 5:
				{
					CPrintToChatAll("{rare}???{default}: I'll be keeping an open eye on you from now on.");
					i_TalkDelayCheck = maxyapping;
					SmiteNpcToDeath(npc.index);
				}
			}
		}
	}
	*/
}

//
// SHARED RAID BOSS FUNCTIONS
//

void Aperture_Shared_LastStandSequence_Starting(CClotBody npc)
{
	float gameTime = GetGameTime();
	
	SetEntProp(npc.index, Prop_Data, "m_iHealth", 1);
	
	RemoveAllBuffs(npc.index, true, true);
	ReviveAll(true);
	
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true; //Make allied npcs ignore him.
	b_NpcIsInvulnerable[npc.index] = true;
	
	npc.m_bDissapearOnDeath = true;
	npc.m_flSpeed = 0.0;
	npc.m_bisWalking = false;
	npc.StopPathing();
	
	npc.SetActivity("ACT_MP_STUN_MIDDLE");
	npc.AddGesture("ACT_MP_STUN_BEGIN");
	npc.SetPlaybackRate(0.0);
	
	RaidModeScaling = 0.0;
	RaidModeTime = gameTime + APERTURE_LAST_STAND_TIMER_TOTAL;
	EmitSoundToAll(g_ApertureSharedStunStartSound, npc.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, 90, BOSS_ZOMBIE_VOLUME, 85);
	
	npc.m_flNextThinkTime = gameTime + APERTURE_LAST_STAND_TIMER_BEFORE_INVULN;
	
	func_NPCDeath[npc.index] = Aperture_Shared_LastStandSequence_NPCDeath;
	func_NPCOnTakeDamage[npc.index] = Aperture_Shared_LastStandSequence_OnTakeDamage;
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
		
		Format(message, 128, "Choose to spare or kill %s!\nYou DO NOT have to kill it to proceed!", message);
		
		event.SetFloat("worldPosX", vecPos[0]);
		event.SetFloat("worldPosY", vecPos[1]);
		event.SetFloat("worldPosZ", vecPos[2]);
	//	event.SetInt("follow_entindex", 0);
		event.SetFloat("lifetime", APERTURE_LAST_STAND_TIMER_TOTAL);
	//	event.SetInt("visibilityBitfield", (1<<client));
		//event.SetBool("show_effect", effect);
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
	damage *= APERTURE_LAST_STAND_DAMAGE_MULT;
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
	return StrContains(WhatDifficultySetting_Internal, "Vincent") == 0;
}

bool Aperture_IsBossDead(int type)
{
	return (i_ApertureBossesDead & type) != 0;
}