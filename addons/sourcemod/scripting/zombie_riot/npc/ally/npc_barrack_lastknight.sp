#pragma semicolon 1
#pragma newdecls required

static int LastKnightSpecialCommand[MAXENTITIES];
int Revive[MAXENTITIES];

enum
{
	LastKnight_Command_Default = 0,
	LastKnight_Command_Heal = 1,
	LastKnight_Command_Charge = 2,
	LastKnight_Command_TideLance = 3,
	LastKnight_Command_TideHunt = 4,
	LastKnight_Command_KO = 5,
	LastKnight_Command_Rampage = 6,
}

static const char g_FreezeSounds[][] =
{
	"weapons/icicle_freeze_victim_01.wav",
};
static const char g_MeleeHitSounds[][] = {
	"weapons/cleaver_hit_02.wav",
	"weapons/cleaver_hit_03.wav",
	"weapons/cleaver_hit_05.wav",
	"weapons/cleaver_hit_06.wav",
	"weapons/cleaver_hit_07.wav",
};
static const char g_Kick[][] =
{
	"mvm/mvm_tank_explode.wav",
};

static const char g_TideHunt[][] = {
	"zombiesurvival/medieval_raid/special_mutation/arkantos_scream_buff.mp3",
};
static const char PullRandomEnemyAttack[][] =
{
	"weapons/physcannon/energy_sing_explosion2.wav"
};
public void BarrackLastKnightOnMapStart()
{
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_FreezeSounds);
	PrecacheSoundArray(PullRandomEnemyAttack);
	PrecacheSoundArray(g_Kick);
	PrecacheSoundArray(g_TideHunt);
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Tide-Hunt Knight");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_barrack_lastknight");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return BarrackLastKnight(client, vecPos, vecAng);
}

methodmap BarrackLastKnight < BarrackBody
{
	property int i_LastKnightSpecialCommand	// To give an extra menu for Last Knight skills
	{
		public get()
		{
			return LastKnightSpecialCommand[view_as<int>(this)];
		}
		public set(int value)
		{
			LastKnightSpecialCommand[view_as<int>(this)] = value;
		}
	}
	property int m_iPhase
	{
		public get()
		{
			return this.m_iMedkitAnnoyance;
		}
		public set(int value)
		{
			this.m_iMedkitAnnoyance = value;
		}
	}
	property float m_flSelfHeal
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flCharge
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flTideLance
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flTideHunt
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	property float m_flKillDoor
	{
		public get()							{ return fl_AbilityOrAttack[this.index][4]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][4] = TempValueForProperty; }
	}
	property float m_flSelfRevive
	{
		public get()							{ return fl_AbilityOrAttack[this.index][5]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][5] = TempValueForProperty; }
	}
	property float m_flDowned
	{
		public get()							{ return fl_AbilityOrAttack[this.index][6]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][6] = TempValueForProperty; }
	}
	
	public void PlayFreezeSound() {
		EmitSoundToAll(g_FreezeSounds[GetRandomInt(0, sizeof(g_FreezeSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlaySpearSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlayRandomEnemyPullSound() {
		EmitSoundToAll(PullRandomEnemyAttack[GetRandomInt(0, sizeof(PullRandomEnemyAttack) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlayKickSound() {
		EmitSoundToAll(g_Kick[GetRandomInt(0, sizeof(g_Kick) - 1)], _, _, _, _, _, 100);
	}
	public void PlayTideHuntSound() {
		EmitSoundToAll(g_TideHunt[GetRandomInt(0, sizeof(g_TideHunt) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	
	public BarrackLastKnight(int client, float vecPos[3], float vecAng[3])
	{	
		BarrackLastKnight npc = view_as<BarrackLastKnight>(BarrackBody(client, vecPos, vecAng, "3000", _, _, "0.75",_,"models/pickups/pickup_powerup_regen.mdl"));
		
		i_NpcWeight[npc.index] = 2;
		KillFeed_SetKillIcon(npc.index, "spy_cicle");
		
		npc.m_bSelectableByAll = true;
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		
		npc.m_flSpeed = 150.0;
		npc.m_bisWalking = true;
		
		npc.i_LastKnightSpecialCommand = LastKnight_Command_Default;
		npc.b_NpcSpecialCommand = true;
		
		npc.m_fbRangedSpecialOn = false; // Used to check whether the Last Knight has his charge active or not
		npc.Anger = false; // Variable to control whether the Last Knight is allowed to revive himself instantly once on last man standing
		npc.m_iPhase = 0; // Variable to control whether the Last Knight is about to use "SLAY THE OCEAN"
		npc.m_flDowned = 0.0; // Variable to control whether the Last Knight is downed or not (used for revive) - 0 -> Alive, 1 -> Downed
		npc.m_iState = 0; // Hehehe (It's a kill-switch for Dorian, 1 time use only, i'm not THAT sadist)
		
		func_NPCOnTakeDamage[npc.index] = BarrackLastKnight_OnTakeDamage;
		func_NPCDeath[npc.index] = BarrackLastKnight_NPCDeath;
		func_NPCThink[npc.index] = BarrackLastKnight_ClotThink;
		
		npc.m_flDoingAnimation = 0.0; // Used to handle when to give him the horse during the first transformation in a round
		
		// Cooldowns 15 Seconds -> Charge, 60 seconds -> Heal, 25 seconds Tide-Lance, TideHunt -> 60, Slay the ocean -> 120

		npc.m_flSelfHeal = 0.0; // Heal
		npc.m_flCharge = 0.0;	// Charge
		npc.m_flTideLance = 0.0;	// Tide-Lance
		npc.m_flTideHunt = 0.0;	// Tide-Hunt
		npc.m_flKillDoor = 10.0;	// For the memes
		npc.m_flSelfRevive = 0.0;	// Self revival condition 2
		npc.m_flNextRangedSpecialAttack = 0.0; // SLAY THE OCEAN
		npc.m_flNextRangedAttack = 0.0; // To decide when he should move
		
		Revive[npc.index] = Waves_GetRoundScale(); // Variable used to allow the Last Knight to instantly revive after a wave is over
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/workshop/weapons/c_models/c_xms_cold_shoulder/c_xms_cold_shoulder.mdl");
		SetVariantString("2.5");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("partyhat", "models/workshop/player/items/all_class/sbox2014_knight_helmet/sbox2014_knight_helmet_demo.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("partyhat", "models/workshop/player/items/demo/sf14_deadking_pauldrons/sf14_deadking_pauldrons.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable4 = npc.EquipItem("partyhat", "models/workshop/player/items/demo/sbox2014_demo_samurai_armour/sbox2014_demo_samurai_armour.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		
		return npc;
	}
}

public void BarrackLastKnight_ClotThink(int iNPC)
{
	BarrackLastKnight npc = view_as<BarrackLastKnight>(iNPC);
	float GameTime = GetGameTime(iNPC);
	
	if(BarrackBody_ThinkStart(npc.index, GameTime))
	{
		int client = BarrackBody_ThinkTarget(npc.index, true, GameTime);
		BarrackBody_ThinkTarget(npc.index, true, GameTime);
		int PrimaryThreatIndex = npc.m_iTarget;
		
		if(npc.i_LastKnightSpecialCommand == 5) // KO state AND revive state
		{	
			if(Revive[npc.index] < Waves_GetRoundScale()) // If the waves changed revive him
			{
				Revive[npc.index] = Waves_GetRoundScale();
				SetDownedState_LastKnight(iNPC, false);
				DesertYadeamDoHealEffect(iNPC, 200.0);
				
				CPrintToChatAll("{green}The Last Knight returns to battle, his mission isn't done yet");
				
				npc.i_LastKnightSpecialCommand = LastKnight_Command_Default;
			}
			if(npc.m_flSelfRevive && npc.m_flSelfRevive < GetGameTime())
			{
				DesertYadeamDoHealEffect(iNPC, 200.0);
				
				SetDownedState_LastKnight(iNPC, false);
				
				if(!LastMann)
				{
					CPrintToChatAll("{green}Enough time has passed and the Last Knight's seaborn blood closed his wounds, he returns to the fight");
					npc.i_LastKnightSpecialCommand = LastKnight_Command_Default;
				}
				else
				{
					CPrintToChatAll("{green}His rage won't fade in this moment of desperation...the Last Knight returns yet again");
					npc.i_LastKnightSpecialCommand = LastKnight_Command_Rampage;
				}
			}
		}
		// --------------
		if(Revive[npc.index] < Waves_GetRoundScale() && npc.i_LastKnightSpecialCommand != 5) // If the wave changes update the variable so he doesn't randomly revive, if he's enraged make him chill out and steal the horse
		{
			HealEntityGlobal(npc.index, npc.index, ReturnEntityMaxHealth(npc.index) * 1.5, _, 5.0, HEAL_ABSOLUTE);
			Revive[npc.index] = Waves_GetRoundScale();
			npc.Anger = false;
			
			if(Waves_GetRoundScale() == 39)
			{
				CPrintToChatAll("{green}The Last Knight channels his rage preparing for the decisive battle(the Last Knight got stronger)");
				SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", 5000);
			}
			if(npc.i_LastKnightSpecialCommand == 6)
			{
				HorseMode(npc, 0);
				// if (IsValidEntity(npc.m_iWearable6))
				// RemoveEntity(npc.m_iWearable6);
				
				npc.SetActivity("ACT_IDLE");
				npc.i_LastKnightSpecialCommand = LastKnight_Command_Default;
			}
		}
		// --------------
		if(LastMann && !npc.Anger)	// Condition for his Rampage to activate, he gets a stronger buff on wave 40 specifically (A bit for lore reason since he hates Ishar'mla so it kinda makes sense he's kinda pissed off when he sees her)
		{
			npc.Anger = true;
			SetDownedState_LastKnight(iNPC, false);
			npc.CmdOverride = Command_Aggressive; // Force Last Knight to go aggressive because well, he has to help the LMS
			
			if(Waves_GetRoundScale() == 39) // Wave 40
			{
				CPrintToChatAll("{red}Precisely because he is always fighting, fate continues to favor him, constantly throwing him into misery and calamity, and eagerly awaiting his undoing");
				b_NpcIsInvulnerable[npc.index] = true;
				b_ThisEntityIgnored[npc.index] = true;
				
				npc.AddGesture("ACT_LAST_KNIGHT_HORSETIME");
				
				npc.StopPathing();
				npc.m_bisWalking = false;
				
				npc.m_flNextRangedAttack = GameTime + 8.6;
				npc.m_flNextRangedSpecialAttack = GameTime + 8.6;
				npc.m_flNextMeleeAttack = GameTime + 8.6;
				npc.m_flDoingAnimation = GameTime + 5.75; // Darn you Door and your weird timers
				
				npc.i_LastKnightSpecialCommand = LastKnight_Command_Rampage;
			}
			else
			{
				CPrintToChatAll("{red}The Last Knight mounts his steed and refusing to acknowledge defeat against the sea he charges into the fray");
				b_NpcIsInvulnerable[npc.index] = true;
				b_ThisEntityIgnored[npc.index] = true;
				
				npc.AddGesture("ACT_LAST_KNIGHT_HORSETIME");
				
				npc.StopPathing();
				npc.m_bisWalking = false;
				
				npc.m_flNextRangedAttack = GameTime + 8.6;
				npc.m_flNextMeleeAttack = GameTime + 8.6;
				npc.m_flNextRangedSpecialAttack = GameTime + 8.6;
				npc.m_flDoingAnimation = GameTime + 5.75; // Darn you Door and your weird timers
				
				npc.i_LastKnightSpecialCommand = LastKnight_Command_Rampage;
			}
		}
		// --------------
		if(npc.i_LastKnightSpecialCommand == 6 && !IsValidEntity(npc.m_iWearable5)) // Remove invincibility during the transformation and equip le horse if the timer has passed
		{
			if(npc.m_flDoingAnimation < GameTime)
			{
				HorseMode(npc, 1);
				npc.SetActivity("ACT_RIDER_IDLE");
			}
		}
		// --------------
		if(npc.m_flKillDoor < GameTime) // Easter egg
		{
			if(npc.m_iState == 0)
			{
				if(client != 0) // This is a failsafe, cause otherwise it throws exceptions in some cases if the lsat player crashes/leaves and last knight is there
				{
					if(!LastMann)	// Yeah uh, don't want to ruin a game either let's be honest
					{
						if(GetSteamAccountID(client) == 145897082) // What i'm about to do though... is quite stupid lol
						{
							float pos[3]; GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", pos);
							float ang[3];
							ang[1] = GetRandomFloat(-179.0, 179.0);

							TeleportEntity(npc.index, pos);
							npc.m_bisWalking = false;
							npc.SetActivity("ACT_PUSH_PLAYER");
							
							npc.DispatchParticleEffect(npc.index, "mvm_soldier_shockwave", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("anim_attachment_LH"), PATTACH_POINT_FOLLOW, true);
							npc.PlayRandomEnemyPullSound();
							
							ForcePlayerSuicide(client);
							CPrintToChatAll("{red}The Last Knight brutalizes Dorian");
							CPrintToChatAll("{green}Last Knight:{pink}She{default}... asked me.... to.");
							npc.m_iState = 1;
						}
					}
				}
			}
			else
			{
				npc.m_flKillDoor = FAR_FUTURE;
			}
		}
		// --------------
		if(npc.i_LastKnightSpecialCommand == 1)
		{
			if(npc.m_flSelfHeal < GameTime)
			{
				npc.m_flSelfHeal = GameTime + 60.0;
				npc.m_flTideHunt = GameTime + 5.0;	// To avoid people using BOTH heal and tidehunt at the same time
				npc.m_flNextRangedAttack = GameTime + 5.5;
				npc.m_flNextMeleeAttack = GameTime + 5.5;
				
				npc.StopPathing();
				npc.m_bisWalking = false;
				
				npc.AddGesture("ACT_LAST_KNIGHT_HEAL",_,5.5);
				ApplyStatusEffect(npc.index, npc.index, "Very Defensive Backup", 5.5);
				HealEntityGlobal(npc.index, npc.index, ReturnEntityMaxHealth(npc.index) * 1.5, _, 5.0, HEAL_ABSOLUTE);
			}
			else
			{
				npc.i_LastKnightSpecialCommand = LastKnight_Command_Default;
			}
		}
		if(PrimaryThreatIndex > 0)
		{
			float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget );
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			
			switch(npc.i_LastKnightSpecialCommand)
			{
				case LastKnight_Command_Default:	// Default state for Last Knight, an attack with high delay that hits somewhat hard, deals more dmg to Seaborn
				{
					if(flDistanceToTarget < GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
					{
						if(npc.m_flNextMeleeAttack < GameTime || npc.m_flAttackHappenswillhappen)
						{
							bool Success;
							if(GetRandomInt(1, 2000) > 1999) // 1 out of 2k chance of something funny happening, for those that care about the percentage it's 0.05%
							{
								Success = true;
							}
							
							if(!Success)
							{
								if(!npc.m_flAttackHappenswillhappen)
								{
									npc.AddGesture(npc.m_fbRangedSpecialOn ? "ACT_LAST_KNIGHT_ATTACK_2" : "ACT_LAST_KNIGHT_ATTACK_1");
									npc.PlaySpearSound();
									npc.m_flAttackHappens = GameTime + 0.3;
									npc.m_flAttackHappens_bullshit = GameTime + 0.44;
									npc.m_flNextMeleeAttack = GameTime + (2.0 * npc.BonusFireRate);
									npc.m_flAttackHappenswillhappen = true;
								}
							}
							else
							{
								if(!npc.m_flAttackHappenswillhappen)
								{
									npc.AddGesture("ACT_WHITEFLOWER_KICK_GROUND");
									npc.PlaySpearSound();
									npc.m_flAttackHappens = GameTime + 0.3;
									npc.m_flAttackHappens_bullshit = GameTime + 0.44;
									npc.m_flNextMeleeAttack = GameTime + (2.0 * npc.BonusFireRate);
									npc.m_flAttackHappenswillhappen = true;
								}
							}
							if(npc.m_flAttackHappens < GameTime && npc.m_flAttackHappens_bullshit >= GameTime && npc.m_flAttackHappenswillhappen)
							{
								Handle swingTrace;
								npc.FaceTowards(vecTarget, 20000.0);
								if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex))
								{
									int target = TR_GetEntityIndex(swingTrace);
									
									float vecHit[3];
									TR_GetEndPosition(vecHit, swingTrace);

									if(target > 0) 
									{
										if(!Success)
										{
											if(npc.m_fbRangedSpecialOn) // If charge is active he hits a second time and has extra effects
											{
												SDKHooks_TakeDamage(target, npc.index, client, i_BleedType[target] == BLEEDTYPE_SEABORN ? 80000.0 : 50000.0, DMG_CLUB, -1, _, vecHit);
												npc.m_flCharge = GameTime + 15.0;
												npc.m_fbRangedSpecialOn = false;
												
												if(i_BleedType[target] == BLEEDTYPE_SEABORN)
												{
													Custom_Knockback(npc.index, target, 1200.0, true);  // Seaborn Yeeter 9000
													FreezeNpcInTime(target, 3.0);
												}
												else // Much less knockback and very brief stun on human enemies (raids and Saint CARmen)
												{
													Custom_Knockback(npc.index, target, 750.0, true);
													FreezeNpcInTime(target, 1.0);
												}
											}
											SDKHooks_TakeDamage(target, npc.index, client, i_BleedType[target] == BLEEDTYPE_SEABORN ? 40000.0 : 25000.0, DMG_CLUB, -1, _, vecHit);
											npc.PlayMeleeHitSound();
										}
										else
										// If that 0.05% triggers.....
										{
											// He deals a huuuge dmg and sends the target to Narnia.
											SDKHooks_TakeDamage(target, npc.index, client, 1000000.0, DMG_CLUB, -1, _, vecHit);
											npc.PlayKickSound();
											TE_Particle("asplode_hoodoo", VecSelfNpc, NULL_VECTOR, NULL_VECTOR, npc.index, _, _, _, _, _, _, _, _, _, 0.0);
											FreezeNpcInTime(target, 5.0);
											Custom_Knockback(npc.index, target, 3000.0, true);
											Success = false;
										}
									}
								}
								delete swingTrace;
								npc.m_flAttackHappenswillhappen = false;
							}
							else if(npc.m_flAttackHappens_bullshit < GameTime && npc.m_flAttackHappenswillhappen)
							{
								npc.m_flAttackHappenswillhappen = false;
							}
						}
					}
				}
				case LastKnight_Command_Charge:
				{
					if(npc.m_flCharge < GameTime)
					{
						npc.m_fbRangedSpecialOn = true;
					}
					npc.i_LastKnightSpecialCommand = LastKnight_Command_Default;
				}
				case LastKnight_Command_TideLance:	// Gives increased attack range and faster attack speed for 5 attacks, the last one Freezes the target
				{
					if(npc.m_flTideLance < GameTime)
					{
						npc.m_flTideLance = GameTime + 25.0;
					}
					if(flDistanceToTarget < GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
					{
						if(npc.m_flNextMeleeAttack < GameTime || npc.m_flAttackHappenswillhappen)
						{
							static int AttackCount;
							
							if(!npc.m_flAttackHappenswillhappen)
							{
								AttackCount ++;
								
								npc.AddGesture(AttackCount > 4 ? "ACT_LAST_KNIGHT_ATTACK_2" : "ACT_LAST_KNIGHT_ATTACK_1");
								npc.PlaySpearSound();
								npc.m_flAttackHappens = GameTime + (AttackCount > 4 ? 0.35 : 0.25);
								npc.m_flAttackHappens_bullshit = GameTime + 0.44;
								npc.m_flNextMeleeAttack = GameTime + (AttackCount > 4 ? 1.5 : 1.0);
								npc.m_flAttackHappenswillhappen = true;
							}
							if(npc.m_flAttackHappens < GameTime && npc.m_flAttackHappens_bullshit >= GameTime && npc.m_flAttackHappenswillhappen)
							{
								Handle swingTrace;
								npc.FaceTowards(vecTarget, 20000.0);
								if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex))
								{
									int target = TR_GetEntityIndex(swingTrace);
									
									float vecHit[3];
									TR_GetEndPosition(vecHit, swingTrace);

									if(target > 0) 
									{
										
										if(AttackCount > 4)
										{
											SDKHooks_TakeDamage(target, npc.index, client, i_BleedType[target] == BLEEDTYPE_SEABORN ? 30000.0 : 20000.0, DMG_CLUB, -1, _, vecHit);
											npc.PlayFreezeSound();
											AttackCount = 0;
											
											Custom_Knockback(npc.index, target, 300.0, true);
											ApplyStatusEffect(npc.index, target, "Near Zero", 2.0);
											ApplyStatusEffect(npc.index, target, "Teslar Mule", 6.0);
											FreezeNpcInTime(target, 2.0);
											
											npc.i_LastKnightSpecialCommand = LastKnight_Command_Default;
										}
										else
										{
											SDKHooks_TakeDamage(target, npc.index, client, i_BleedType[target] == BLEEDTYPE_SEABORN ? 30000.0 : 20000.0, DMG_CLUB, -1, _, vecHit);
										}
										npc.PlayMeleeHitSound(); 
									}
								}
								delete swingTrace;
								npc.m_flAttackHappenswillhappen = false;
							}
							else if(npc.m_flAttackHappens_bullshit < GameTime && npc.m_flAttackHappenswillhappen)
							{
								npc.m_flAttackHappenswillhappen = false;
							}
						}
					}
				}
				case LastKnight_Command_TideHunt:	// Makes the Last Knight Channel for 5 seconds, slowly creating a shockwave similar to Waldch, gains 50% DR during it, once it fully charges deals hefty dmg to everyone in the area
				{
					if(flDistanceToTarget < GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED)
					{
						if(npc.m_flTideHunt < GameTime)
						{
							// All the preparations -> Giving time for 50% dr, locking him in place and making him prepare his big boom
							npc.AddGesture("ACT_LAST_KNIGHT_TIDEHUNT",_,8.0);
							npc.m_flNextRangedAttack = GameTime + 8.0;
							npc.m_flNextMeleeAttack = GameTime + 8.0;
							npc.m_flAttackHappens = GameTime + 5.0;
							ApplyStatusEffect(npc.index, npc.index, "Very Defensive Backup", 8.0);
							
							npc.StopPathing();
							npc.m_bisWalking = false;
							
							spawnRing_Vectors(VecSelfNpc, 450.0 * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 0, 255, 0, 255, 1, 1.95, 5.0, 0.0, 1);
							spawnRing_Vectors(VecSelfNpc, 0.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 0, 255, 0, 255, 1, 4.0, 5.0, 0.0, 1, 450.0 * 2.0);
							
							npc.m_flTideHunt = GameTime + 60.0;
							npc.m_flSelfHeal = GameTime + 8.0;
						}
						if(npc.m_flAttackHappens < GameTime)
						{
							Explode_Logic_Custom(30000.0, GetClientOfUserId(npc.OwnerUserId), npc.index, -1, VecSelfNpc , 450.0 * 2.0, 1.0, _, true, .FunctionToCallBeforeHit = TideHunt_Effect);
							ParticleEffectAt(VecSelfNpc, "xms_snowburst", 3.0);
							ParticleEffectAt(VecSelfNpc, "xms_snowburst_child01", 3.0);
							ParticleEffectAt(VecSelfNpc, "xms_snowburst_child02", 3.0);
							npc.PlayTideHuntSound();
							
							npc.i_LastKnightSpecialCommand = LastKnight_Command_Default;
						}
					}
				}
				case LastKnight_Command_Rampage:	// Happens ONLY when it's last man standing, he gets significant buffs but becomes uncontrollable and has a special attack that uses off cooldown, he won't get out of this state unless either he dies or round ends
				{	
					if(b_NpcIsInvulnerable[npc.index])	// Make him move + remove invincibility AFTER he transformed fully
					{
						if(npc.m_flNextRangedAttack < GameTime)
						{
							npc.m_flSpeed = 250.0;
							npc.StartPathing();
							npc.m_bisWalking = true;
							b_NpcIsInvulnerable[npc.index] = false;
							b_ThisEntityIgnored[npc.index] = false;
						}
					}
					if(npc.m_flNextRangedAttack < GameTime)
					{
						npc.StartPathing();
						npc.m_bisWalking = true;
						b_NpcIsInvulnerable[npc.index] = false;
						b_ThisEntityIgnored[npc.index] = false;
						BarrackBody_ThinkMove(npc.index, 250.0, "ACT_RIDER_IDLE", "ACT_RIDER_RUN");
					}
					if(npc.m_flNextRangedSpecialAttack < GameTime) // He's pissed so he's going to use "SLAY THE OCEAN", big aoe and damage
					{
						if(npc.m_iPhase == 0) // Special effect to show he has his "SLAY THE OCEAN"" skill ready, it's a prepare phase
						{
							npc.StopPathing();
							npc.m_bisWalking = false;
							
							npc.AddGesture("ACT_LAST_KNIGHT_SLAY_PREPARE");
							npc.m_flNextRangedAttack = GameTime + 1.0;
							npc.m_flNextMeleeAttack = GameTime + 1.0;
							NpcSpeechBubble(npc.index, "Will...NEVER...BOW", 7, {255,9,9,255}, {0.0,0.0,120.0}, "");
							npc.m_iPhase = 1;
						}
						// Big attack
						if(flDistanceToTarget < GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
						{
							if(npc.m_flNextMeleeAttack < GameTime || npc.m_flAttackHappenswillhappen)
							{
								static int AttackCount2;
								
								if(!npc.m_flAttackHappenswillhappen)
								{
									AttackCount2 ++;
									
									npc.AddGesture(AttackCount2 > 2 ? "ACT_LAST_KNIGHT_SLAY2" : "ACT_LAST_KNIGHT_SLAY1");
									npc.PlaySpearSound();
									npc.m_flAttackHappens = GameTime + (AttackCount2 > 2 ? 0.35 : 0.25);
									npc.m_flAttackHappens_bullshit = GameTime + 0.44;
									npc.m_flNextMeleeAttack = GameTime + (AttackCount2 > 2 ? 3.0 : 2.0);
									npc.m_flAttackHappenswillhappen = true;
								}
								if(npc.m_flAttackHappens < GameTime && npc.m_flAttackHappens_bullshit >= GameTime && npc.m_flAttackHappenswillhappen)
								{
									Handle swingTrace;
									npc.FaceTowards(vecTarget, 20000.0);
									if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex))
									{
										int target = TR_GetEntityIndex(swingTrace);
										
										float vecHit[3];
										TR_GetEndPosition(vecHit, swingTrace);

										if(target > 0) 
										{	
											if(AttackCount2 > 2)
											{
												Explode_Logic_Custom(30000.0, GetClientOfUserId(npc.OwnerUserId), npc.index, -1, VecSelfNpc , 200.0, 1.0, _, true, .FunctionToCallBeforeHit = TideHunt_Effect);
												AttackCount2 = 0;
												ApplyStatusEffect(npc.index, target, "Near Zero", 8.0);
												FreezeNpcInTime(target, 3.0);
												
												// We add a cooldown + reset the prepare phase and he doesn't glow up anymore, no more showtime for a while
												npc.m_flNextRangedSpecialAttack = GameTime + 120.0;
												
												// if (IsValidEntity(npc.m_iWearable6))
												// RemoveEntity(npc.m_iWearable6);
												npc.m_iPhase = 0;
											}
											else
											{
												// He teleports behind the enemy he's attacking, basically dashes 2 times in a row, i cleaaaarly didn't borrow Agent Thomson's code, thanks Eno (and most likely fishy fish) >w<
												static float hullcheckmaxs[3];
												static float hullcheckmins[3];
												hullcheckmaxs = view_as<float>( { 24.0, 24.0, 82.0 } );
												hullcheckmins = view_as<float>( { -24.0, -24.0, 0.0 } );
												
												WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
												float vPredictedPos[3];
												PredictSubjectPosition(npc, target,_,_, vPredictedPos);
												vPredictedPos = GetBehindTarget(PrimaryThreatIndex, 30.0 ,vPredictedPos);
												
												float PreviousPos[3];
												WorldSpaceCenter(npc.index, PreviousPos);
												float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
												
												Npc_Teleport_Safe(npc.index, vPredictedPos, hullcheckmins, hullcheckmaxs, true);
											
												Explode_Logic_Custom(10000.0, GetClientOfUserId(npc.OwnerUserId), npc.index, -1, VecSelfNpc , 200.0, 1.0, _, true, .FunctionToCallBeforeHit = Slay_Effect1);
											}
											npc.PlayMeleeHitSound();
										}
									}
									delete swingTrace;
									npc.m_flAttackHappenswillhappen = false;
								}
								else if(npc.m_flAttackHappens_bullshit < GameTime && npc.m_flAttackHappenswillhappen)
								{
									npc.m_flAttackHappenswillhappen = false;
								}
							}
						}
					}
					else // Meanwhile if he's not pissed he debuffs briefly each attack, he still hates seaborns and deals more damage against them, he's racist yes.
					{
						if(flDistanceToTarget < GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
						{
							if(npc.m_flNextMeleeAttack < GameTime || npc.m_flAttackHappenswillhappen)
							{	
								if(!npc.m_flAttackHappenswillhappen)
								{
									npc.AddGesture("ACT_RIDER_ATTACK");
									npc.PlaySpearSound();
									npc.m_flAttackHappens = GameTime + 0.4;
									npc.m_flNextMeleeAttack = GameTime + (1.5 * npc.BonusFireRate);
									npc.m_flAttackHappenswillhappen = true;
								}
									
								if(npc.m_flAttackHappens < GameTime && npc.m_flNextRangedSpecialAttack >= GameTime && npc.m_flAttackHappenswillhappen)
								{
									Handle swingTrace;
									npc.FaceTowards(vecTarget, 20000.0);
									if(npc.DoSwingTrace(swingTrace, npc.m_iTarget))
									{
										int target = TR_GetEntityIndex(swingTrace);	
										
										float vecHit[3];
										TR_GetEndPosition(vecHit, swingTrace);
										
										if(target > 0)
										{
											SDKHooks_TakeDamage(target, npc.index, client, i_BleedType[target] == BLEEDTYPE_SEABORN ? 40000.0 : 25000.0, DMG_CLUB, -1, _, vecHit);
											ApplyStatusEffect(npc.index, target, "Near Zero", 1.5);
											ApplyStatusEffect(npc.index, target, "Teslar Shock", 1.5);
											npc.PlaySpearSound();
										} 
									}
									delete swingTrace;
									npc.m_flAttackHappenswillhappen = false;
								}
								else if(npc.m_flNextRangedSpecialAttack < GameTime && npc.m_flAttackHappenswillhappen)
								{
									npc.m_flAttackHappenswillhappen = false;
								}
							}
						}
					}
				}
			}
		}
		if(npc.i_LastKnightSpecialCommand < 5) // In short, if he's not K.O/Enraged or if he's not using Heal/Tidehunt he's free to move
		{
			if(npc.m_flNextRangedAttack < GameTime)
			{
				BarrackBody_ThinkMove(npc.index, npc.m_fbRangedSpecialOn ? 300.0 : 150.0, "ACT_IDLE", "ACT_LAST_KNIGHT_WALK");
				if(!npc.m_bisWalking)
				{
					npc.StartPathing();
					npc.m_bisWalking = true;
				}
				if(npc.m_flSpeed > 150.0)
				{
					npc.m_flSpeed = 150.0;
				}
			}
		}
	}
}

void LastKnight_MenuSpecial(int client, int entity)
{
	SetGlobalTransTarget(client);
	BarrackLastKnight npc = view_as<BarrackLastKnight>(entity);

	Menu menu = new Menu(BarrackLastKnight_MenuH);
	menu.SetTitle("%t\n \n%t\n ", "TF2: Zombie Riot", c_NpcName[entity]);
	char num[16];
	IntToString(EntIndexToEntRef(entity), num, sizeof(num));
	menu.AddItem(num, "Default Engagement", npc.i_LastKnightSpecialCommand == LastKnight_Command_Default ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	menu.AddItem(num, "Seaborn Regeneration", npc.i_LastKnightSpecialCommand == LastKnight_Command_Heal ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	menu.AddItem(num, "Charge", npc.i_LastKnightSpecialCommand == LastKnight_Command_Charge ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	menu.AddItem(num, "Tide Lance", npc.i_LastKnightSpecialCommand == LastKnight_Command_TideLance ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	menu.AddItem(num, "Tide Hunt", npc.i_LastKnightSpecialCommand == LastKnight_Command_TideHunt ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

	menu.Pagination = 0;
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);	
}
public int BarrackLastKnight_MenuH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Select:
		{
			char num[16];
			menu.GetItem(choice, num, sizeof(num));

			int entity = EntRefToEntIndex(StringToInt(num));
			if(entity != INVALID_ENT_REFERENCE)
			{
				BarrackLastKnight npc = view_as<BarrackLastKnight>(entity);
				float GameTime = GetGameTime(entity);

				if(npc.i_LastKnightSpecialCommand <= 4)
				{
					switch(choice)
					{
						case 0:
						{
							npc.i_LastKnightSpecialCommand = LastKnight_Command_Default;
						}
						case 1:
						{
							if(npc.m_flSelfHeal < GameTime)
							{
								npc.i_LastKnightSpecialCommand = LastKnight_Command_Heal;
							}
							else
							{
								switch(GetRandomInt(1,2))
								{
									case 1:
									{
										CPrintToChat(client, "{green}Last Knight{default}: Not....yet. [%.1f]",npc.m_flSelfHeal - GameTime);
									}
									case 2:
									{
										CPrintToChat(client, "{green}Last Knight{default}: Can....not. [%.1f]",npc.m_flSelfHeal - GameTime);
									}
								}
							}
						}
						case 2:
						{
							if(npc.CmdOverride < 4)
							{
								if(npc.m_flCharge < GameTime)
								{
									npc.i_LastKnightSpecialCommand = LastKnight_Command_Charge;
								}
								else
								{
									switch(GetRandomInt(1,2))
									{
										case 1:
										{
											CPrintToChat(client, "{green}Last Knight{default}: Reco....vering. [%.1f]",npc.m_flCharge - GameTime);
										}
										case 2:
										{
											CPrintToChat(client, "{green}Last Knight{default}: Need....time [%.1f]",npc.m_flCharge - GameTime);
										}
									}
								}
							}
							else
							{
								CPrintToChat(client, "{green}The Last Knight is unable to properly prepare a charge while retreating/holding position");
							}
						}
						case 3:
						{
							if(npc.m_flTideLance < GameTime)
							{
								npc.i_LastKnightSpecialCommand = LastKnight_Command_TideLance;
							}
							else
							{
								switch(GetRandomInt(1,2))
								{
									case 1:
									{
										CPrintToChat(client, "{green}Last Knight{default}: Not....ready. [%.1f]",npc.m_flTideLance - GameTime);
									}
									case 2:
									{
										CPrintToChat(client, "{green}Last Knight{default}: Need....time [%.1f]",npc.m_flTideLance - GameTime);
									}
								}
							}
						}
						case 4:
						{
							if(npc.m_flTideHunt < GameTime)
							{
								npc.i_LastKnightSpecialCommand = LastKnight_Command_TideHunt;
							}
							else
							{
								switch(GetRandomInt(1,2))
								{
									case 1:
									{
										CPrintToChat(client, "{green}Last Knight{default}: Ugh.... [%.1f]",npc.m_flTideHunt - GameTime);
									}
									case 2:
									{
										CPrintToChat(client, "{green}Last Knight{default}: Need....time [%.1f]",npc.m_flTideHunt - GameTime);
									}
								}
							}
						}
					}
					LastKnight_MenuSpecial(client, npc.index);
				}
				else
				{
					CPrintToChat(client, "{green}Last Knight is not listening to your orders.{default}");
				}
			}
		}
	}
	return 0;
}

void BarrackLastKnight_NPCDeath(int entity)
{
	BarrackLastKnight npc = view_as<BarrackLastKnight>(entity);
	BarrackBody_NPCDeath(npc.index);
}

public Action BarrackLastKnight_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	BarrackLastKnight npc = view_as<BarrackLastKnight>(victim);
	int health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
	f_ArmorCurrosionImmunity[npc.index][Element_Nervous] = GetGameTime() + 5.0;	// Immunity to nervous impairment (Sea debuff)
	
	if((ReturnEntityMaxHealth(npc.index)/2) <= damage) // Anti 1 shot, he takes at most 50% max health dmg
	{
		damage = (ReturnEntityMaxHealth(npc.index) + 0.0)/2;
	}
	if(damage >= health)
	{
		if(npc.i_LastKnightSpecialCommand == 6) // If he's enraged remove le horse
		{
			HorseMode(npc, 0);
		}
		
		CPrintToChatAll("{red}The Last Knight falls but refuses to give up until the seaborns are no more.");
		damage = 0.0;
		SetDownedState_LastKnight(victim, true);
		
		b_NpcIsInvulnerable[npc.index] = true;
		b_ThisEntityIgnored[npc.index] = true;
		npc.i_LastKnightSpecialCommand = LastKnight_Command_KO;
	}
	return Plugin_Changed;
}
void HorseMode(BarrackLastKnight npc, int Type)
{
	switch(Type)
	{
		case 0: // Remove
		{
			if(IsValidEntity(npc.m_iWearable5))
			{
				RemoveEntity(npc.m_iWearable5);
			}
		}
		case 1:	// Equip
		{
			npc.m_iWearable5 = npc.EquipItem("partyhat", "models/workshop/player/items/engineer/hwn2022_pony_express/hwn2022_pony_express.mdl");
			SetVariantString("1.1");
			AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		}
	}
}
void TideHunt_Effect(int attacker, int victim)
{
	ApplyStatusEffect(attacker, victim, "Terrified", 5.0);
	Custom_Knockback(attacker, victim, 1000.0, true);
}
void Slay_Effect1(int attacker, int victim)
{
	ApplyStatusEffect(attacker, victim, "Teslar Shock", 2.0);
	ApplyStatusEffect(attacker, victim, "Near Zero", 2.0);
	FreezeNpcInTime(victim, 2.0);
}
void SetDownedState_LastKnight(int iNpc, bool StateDo) // Cleeeearly didn't borrow part of your code Artvin either (danke)
{
	BarrackLastKnight npc = view_as<BarrackLastKnight>(iNpc);
	if(StateDo) //downed
	{
		npc.m_flSelfRevive = GetGameTime() + 120.0;
		b_ThisEntityIgnored[iNpc] = true;
		b_NpcIsInvulnerable[iNpc] = true;
		SetEntProp(iNpc, Prop_Data, "m_iHealth", 1);
		if(!npc.m_flDowned)
		{
			npc.m_flDowned = 1.0;
			npc.StopPathing();
			npc.m_bisWalking = false;
			npc.AddGesture("ACT_LAST_KNIGHT_KO");
			npc.SetActivity("ACT_LAST_KNIGHT_DOWNED");
		}
	}
	else
	{
		if(npc.m_flDowned)
		{
			npc.m_flDowned = 0.0;
			npc.AddGesture("ACT_LAST_KNIGHT_GETUP");
			npc.SetActivity("ACT_IDLE");
		}
		npc.m_flSelfRevive = 0.0;
		npc.StartPathing();
		npc.m_bisWalking = true;
		b_ThisEntityIgnored[iNpc] = false;
		b_NpcIsInvulnerable[iNpc] = false;
		SetEntProp(iNpc, Prop_Data, "m_iHealth", ReturnEntityMaxHealth(iNpc));
	}
	
}