#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"freak_fortress_2/cloaker_payday_2/lost1.mp3",
	"freak_fortress_2/cloaker_payday_2/lost2.mp3",
};

static const char g_HurtSounds[][] = {
	")vo/null.mp3",
};

static const char g_IdleSounds[][] = {
	")vo/null.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	")vo/null.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/boxing_gloves_hit1.wav",
	"weapons/boxing_gloves_hit2.wav",
	"weapons/boxing_gloves_hit3.wav",
	"weapons/boxing_gloves_hit4.wav",
};
static const char g_MeleeAttackSounds[][] = {
	"weapons/boxing_gloves_swing1.wav",
	"weapons/boxing_gloves_swing2.wav",
	"weapons/boxing_gloves_swing4.wav",
};

static const char g_MeleeMissSounds[][] = {
	"weapons/bat_draw_swoosh1.wav",
	"weapons/bat_draw_swoosh2.wav",
};

static const char g_CloakerMainTheme[][] = {
	"#freak_fortress_2/cloaker_payday_2/bgm1.mp3"
};

#define CLOAKERMODEL "models/freak_fortress_2/cloaker_payday_2/cloaker_16.mdl"
#define CLOAKERTHEME "freak_fortress_2/cloaker_payday_2/bgm1.mp3"
#define CLOAKERINTRO "freak_fortress_2/cloaker_payday_2/intro2.mp3"
#define CLOAKERDLC "freak_fortress_2/cloaker_payday_2/acrobatics1.mp3"
#define CLOAKERFORUMS "freak_fortress_2/cloaker_payday_2/won2.mp3"
#define CLOAKERWON "freak_fortress_2/cloaker_payday_2/won1.mp3"
#define CLOAKERHEAL "freak_fortress_2/cloaker_payday_2/heal1.mp3"
#define CLOAKERVRRRRRRRRR "freak_fortress_2/cloaker_payday_2/kick1.mp3"

void Payday_Cloaker_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_CloakerMainTheme));   i++) { PrecacheSound(g_CloakerMainTheme[i]);   }
	PrecacheModel(CLOAKERMODEL, true);
	PrecacheSound(CLOAKERTHEME, true);
	PrecacheSound(CLOAKERINTRO, true);
	PrecacheSound(CLOAKERDLC, true);
	PrecacheSound(CLOAKERFORUMS, true);
	PrecacheSound(CLOAKERWON, true);
	PrecacheSound(CLOAKERHEAL, true);
	PrecacheSound(CLOAKERVRRRRRRRRR, true);
}

static float fl_AlreadyStrippedMusic[MAXTF2PLAYERS];
static float fl_CloakerTheme = 0.0;//manual thingy cause fuck yeah 
static int i_AmountOfHits[MAXENTITIES];//combo hits
static float CloakerMainMeleeDamage[MAXENTITIES] = {125.0, ...};//His main dps
static float CloakerBonusAmount[MAXENTITIES] = {0.0, ...};
static int i_AmountOfTimesICanHeal[MAXENTITIES];
static int i_MaxAmountOfTimesICanHeal = 5;//How many times he can heal himself, remember it's always +1, so rn x+1

methodmap Payday_Cloaker < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleSound()");
		#endif
	}
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleAlertSound()");
		#endif
	}
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayHurtSound()");
		#endif
	}
	public void PlayDeathSound() {
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayDeathSound()");
		#endif
	}
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayMeleeMissSound()");
		#endif
	}
	public void PlayCloakerMainTheme() {
	
		EmitSoundToAll(g_CloakerMainTheme[GetRandomInt(0, sizeof(g_CloakerMainTheme) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayPootisMainTheme()");
		#endif
	}
	
	public Payday_Cloaker(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		Payday_Cloaker npc = view_as<Payday_Cloaker>(CClotBody(vecPos, vecAng, CLOAKERMODEL, "1.0", "150000", ally, false, true));
		
		i_NpcInternalId[npc.index] = PAYDAYCLOAKER;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		if(!b_IsAlliedNpc[npc.index])
		{
			RaidBossActive = EntIndexToEntRef(npc.index);
			fl_CloakerTheme = GetGameTime(npc.index) + 5.0;
			EmitSoundToAll(CLOAKERINTRO, _, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1);
			Music_Stop_Beat_Ten4(client);
			RaidModeTime = GetGameTime(npc.index) + 300.0;
			for(int client_clear=1; client_clear<=MaxClients; client_clear++)
			{
				fl_AlreadyStrippedMusic[client_clear] = 0.0; //reset to 0
			}
			GiveNpcOutLineLastOrBoss(npc.index, true);
		}
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPSOUND_NORMAL;
		
		
		SDKHook(npc.index, SDKHook_Think, Payday_Cloaker_ClotThink);
		
		//IDLE
		npc.m_flSpeed = 330.0;
		npc.m_iState = 0;
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		//Reset abilities
		i_AmountOfHits[npc.index] = 0;
		i_AmountOfTimesICanHeal[npc.index] = 0;
		CloakerBonusAmount[npc.index] = 0.0;
		
		int skin = 0;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		return npc;
	}
}

public void Payday_Cloaker_ClotThink(int iNPC)
{
	Payday_Cloaker npc = view_as<Payday_Cloaker>(iNPC);
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	if(!b_IsAlliedNpc[npc.index])//Mainly if art/bat wants to use them as a body guard
	{
		if(fl_CloakerTheme <= GetGameTime(npc.index))
		{
			fl_CloakerTheme = GetGameTime(npc.index) + 199.0;
			npc.PlayCloakerMainTheme();
			CPrintToChatAll("{lime}[Zombie Riot]{default} Now Playing: {Yellow}PAYDAY {default}· {Yellow}Alesso");
			//https://youtu.be/TUbZ76WRrZ8
		}
		if(RaidModeTime < GetGameTime())
		{
			Music_Stop_Main_Theme4(iNPC);
			int entity = CreateEntityByName("game_round_win"); //You loose.
			DispatchKeyValue(entity, "force_map_reset", "1");
			SetEntProp(entity, Prop_Data, "m_iTeamNum", TFTeam_Blue);
			DispatchSpawn(entity);
			AcceptEntityInput(entity, "RoundWin");
			Music_RoundEnd(entity);
			RaidBossActive = INVALID_ENT_REFERENCE;
			SDKUnhook(npc.index, SDKHook_Think, Payday_Cloaker_ClotThink);
		}
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client))
			{
				if(fl_AlreadyStrippedMusic[client] < GetEngineTime())
				{
					Music_Stop_All(client);
				}
				SetMusicTimer(client, GetTime() + 5);
				fl_AlreadyStrippedMusic[client] = GetEngineTime() + 5.0;
			}
		}
	}
	//float DamageMultiplier = float(ZR_GetWaveCount()+1);
	float DamageMultiplier = 2.5;
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	
	//Round Win sound failed to work with like 9 attemps... i'm too retarded triggering it anyway
	/*if(CurrentPlayers == 0)//Idk i tried so many methods non of them work.. i give up
	{
		EmitSoundToAll(CLOAKERWON, _, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1);
	}*/
	
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	
	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	//Self Heal
	if(i_AmountOfTimesICanHeal[npc.index] <= i_MaxAmountOfTimesICanHeal && CloakerBonusAmount[npc.index] >= 10999.0)
	{
		int MaxHealth = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");
		SetEntProp(npc.index, Prop_Data, "m_iHealth", GetEntProp(npc.index, Prop_Data, "m_iHealth") + MaxHealth / 4);
		//SetEntProp(npc.index, Prop_Data, "m_iHealth", GetEntProp(npc.index, Prop_Data, "m_iHealth") + 75500);
		i_AmountOfTimesICanHeal[npc.index]++;
		CloakerBonusAmount[npc.index] = 0.0;
		EmitSoundToAll(CLOAKERHEAL, _, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1);
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
		
		float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
		
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, PrimaryThreatIndex);
			
			/*int color[4];
			color[0] = 255;
			color[1] = 255;
			color[2] = 0;
			color[3] = 255;
			int xd = PrecacheModel("materials/sprites/laserbeam.vmt");
			TE_SetupBeamPoints(vPredictedPos, vecTarget, xd, xd, 0, 0, 0.25, 0.5, 0.5, 5, 5.0, color, 30);
			TE_SendToAllInRange(vecTarget, RangeType_Visibility);*/
			
			NPC_SetGoalVector(npc.index, vPredictedPos);
		}
		else
		{
			NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
		}
		//Target close enough to hit
		if(flDistanceToTarget < 22500 || npc.m_flAttackHappenswillhappen)
		{
			//Look at target so we hit.
			//npc.FaceTowards(vecTarget, 1000.0);
			//Can we attack right now?
			if(npc.m_flNextMeleeAttack < GetGameTime(npc.index))
			{
				//Play attack ani
				if(!npc.m_flAttackHappenswillhappen)
				{
					npc.PlayMeleeSound();
					//npc.m_flAttackHappens = GetGameTime(npc.index)+0.4;
					//npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.55;
					npc.m_flAttackHappenswillhappen = true;
					//CPrintToChatAll("Hits: %i", i_AmountOfHits[npc.index]);
					if(i_AmountOfHits[npc.index] == 2)
					{
						//npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS"); //Uppercut
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS"); //Uppercut
						npc.m_flAttackHappens = GetGameTime(npc.index)+0.04;
						npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.14;
						npc.m_flAttackHappenswillhappen = true;
					}
					else if(i_AmountOfHits[npc.index] == 3)
					{
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");	//Kick in the balls
						npc.m_flAttackHappens = GetGameTime(npc.index)+0.04;
						npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.14;
						npc.m_flAttackHappenswillhappen = true;
					}
					else
					{
						npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM2");
						npc.m_flAttackHappens = GetGameTime(npc.index)+0.04;
						npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.55;
						npc.m_flAttackHappenswillhappen = true;
					}
				}	
				if(npc.m_flAttackHappens < GetGameTime(npc.index) && npc.m_flAttackHappens_bullshit >= GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					Handle swingTrace;
					npc.FaceTowards(vecTarget, 20000.0);
					if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex, _, _, _, 1))
					{
						int target = TR_GetEntityIndex(swingTrace);	
						
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);
						
						if(target > 0) 
						{
							if(target <= MaxClients)
							{
								SDKHooks_TakeDamage(target, npc.index, npc.index, CloakerMainMeleeDamage[npc.index] * DamageMultiplier, DMG_CLUB, -1, _, vecHit);
								i_AmountOfHits[npc.index]++;
								if(i_AmountOfHits[npc.index] == 3)
								{
									if(IsValidClient(target))
									{
										if(IsInvuln(target))//uber?
										{
											Custom_Knockback(npc.index, target, 1800.0, true);
										}
										else//no?
										{
											Custom_Knockback(npc.index, target, 700.0, true);
										}
										EmitSoundToAll(CLOAKERVRRRRRRRRR, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1);
									}
								}
								else if(i_AmountOfHits[npc.index] == 4)
								{
									if(IsValidClient(target))
									{
										switch(GetRandomInt(1, 9))
										{
											case 1:
											{
												EmitSoundToAll(CLOAKERFORUMS, target, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1);
											}
											default:
											{
												EmitSoundToAll(CLOAKERDLC, target, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1);
											}
										}
										if(IsInvuln(target))
										{
											TF2_StunPlayer(target, 0.3, _, TF_STUNFLAG_BONKSTUCK, 0);
											Custom_Knockback(npc.index, target, 4400.0, true);
										}
										else if(!IsInvuln(target))
										{
											TF2_StunPlayer(target, 3.0, _, TF_STUNFLAG_BONKSTUCK, 0);
											Custom_Knockback(npc.index, target, 1200.0, true);
										}
										else//this shit somehow refused to work correctly YES IM SORRY THAT I AM CALLING IT 2 TIMES BUT IDK WHY IT REFUSED WITH BOTH EACH
										{
											TF2_StunPlayer(target, 3.0, _, TF_STUNFLAG_BONKSTUCK, 0);
											Custom_Knockback(npc.index, target, 1200.0, true);
										}
										i_AmountOfHits[npc.index] = -1;
									}
								}
								float DamageDealer = CloakerMainMeleeDamage[npc.index] * DamageMultiplier;
								if(i_AmountOfTimesICanHeal[npc.index] <= i_MaxAmountOfTimesICanHeal)
								{
									CloakerBonusAmount[npc.index] += DamageDealer;
								}
								//CPrintToChatAll("{red}Damage{default}: %.0f", DamageDealer);
								//CPrintToChatAll("{yellow}Bonus Amount{default}: %.0f", CloakerBonusAmount[npc.index]);
							}
							else
							{
								float NpcBuildingDamage = 12000.0;
								SDKHooks_TakeDamage(target, npc.index, npc.index, NpcBuildingDamage, DMG_CLUB, -1, _, vecHit);
								if(i_AmountOfTimesICanHeal[npc.index] <= i_MaxAmountOfTimesICanHeal)
								{
									CloakerBonusAmount[npc.index] += NpcBuildingDamage;
								}
							}
							//Hit sound
							npc.PlayMeleeHitSound();	
						} 
					}
					delete swingTrace;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.3;
					npc.m_flAttackHappenswillhappen = false;
					if(i_AmountOfHits[npc.index] == 2)
					{
						npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.3;
						npc.m_flAttackHappenswillhappen = false;
					}
					else if(i_AmountOfHits[npc.index] == 3)
					{
						npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.3;
						npc.m_flAttackHappenswillhappen = false;
					}
					else
					{
						npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.3;
						npc.m_flAttackHappenswillhappen = false;
					}
				}
				else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					npc.m_flAttackHappenswillhappen = false;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.4;
				}
			}
		}
		else
		{
			npc.StartPathing();
		}
	}
	else
	{
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action Payday_Cloaker_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Payday_Cloaker npc = view_as<Payday_Cloaker>(victim);
	
	if(attacker <= 0)
		return Plugin_Continue;
	
	if(npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void Payday_Cloaker_NPCDeath(int entity)
{
	Payday_Cloaker npc = view_as<Payday_Cloaker>(entity);
	npc.PlayDeathSound();	

	if(!b_IsAlliedNpc[npc.index])
	{
		Music_Stop_Main_Theme4(entity);
		RaidBossActive = INVALID_ENT_REFERENCE;
	}
	
	
	SDKUnhook(npc.index, SDKHook_Think, Payday_Cloaker_ClotThink);
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}
//Using my old method Stopping all sounds. cspy had it but never came anyway so i reuse it
void Music_Stop_Main_Theme4(int entity)
{
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/cloaker_payday_2/bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/cloaker_payday_2/bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/cloaker_payday_2/bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/cloaker_payday_2/bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/cloaker_payday_2/bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/cloaker_payday_2/bgm1.mp3");
}

void Music_Stop_Beat_Ten4(int entity)
{
	StopSound(entity, SNDCHAN_AUTO, "#zombiesurvival/beats/defaultzombiev2/10.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#zombiesurvival/beats/defaultzombiev2/10.mp3");
}