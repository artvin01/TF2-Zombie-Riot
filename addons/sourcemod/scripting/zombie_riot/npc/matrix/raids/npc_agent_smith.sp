#pragma semicolon 1
#pragma newdecls required 

static const char g_TeleDeathSound[][] = {
	"weapons/rescue_ranger_teleport_receive_01.wav",
	"weapons/rescue_ranger_teleport_receive_02.wav",
};

static char g_DeathSounds[][] = {
	"common/null.wav",
};

static char g_HurtSounds[][] = {
	"common/null.wav",
};

static char g_IdleSounds[][] = {
	"common/null.wav",
};

static char g_IdleAlertedSounds[][] = {
	"common/null.wav",
};

static char g_MeleeHitSounds[][] = {
	"weapons/boxing_gloves_hit1.wav",
	"weapons/boxing_gloves_hit2.wav",
	"weapons/boxing_gloves_hit3.wav",
	"weapons/boxing_gloves_hit4.wav",
};
static char g_MeleeAttackSounds[][] = {
	"common/null.wav",
};

static char g_MeleeMissSounds[][] = {
	"weapons/boxing_gloves_swing1.wav",
	"weapons/boxing_gloves_swing2.wav",
	"weapons/boxing_gloves_swing4.wav",
};
static char g_RangedAttackSounds[][] = {
	"weapons/revolver_shoot.wav",
};

static char g_RangedReloadSound[][] = {
	"weapons/revolver_worldreload.wav",
};

static int i_Victim_Infection[MAXENTITIES];
static float fl_Cure_Meter[MAXPLAYERS];
static float fl_Infection_Meter[MAXPLAYERS];
static float fl_Default_Speed = 300.0;
static int smith_id = -1;
static int i_RedAmount;



static float f_TalkDelayCheck;//apparently exist in silvester xeno, however idk where it's suppose to be put in the .sp so it's this
static int i_TalkDelayCheck;

public void AgentSmith_OnMapStart_NPC()
{
	g_PrecachedMatrixNPCs = false;
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Agent Smith");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_agent_smith");
	strcopy(data.Icon, sizeof(data.Icon), "matrix_agent_smith");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Matrix;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	smith_id = NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheModel("models/zombie_riot/matrix/smith30.mdl");
	PrecacheSoundCustom("#zombiesurvival/matrix/neodammerung.mp3");
	PrecacheSound("weapons/physgun_off.wav");
	PrecacheSoundArray(g_TeleDeathSound);
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_MeleeMissSounds);
	PrecacheSoundArray(g_RangedAttackSounds);
	PrecacheSoundArray(g_RangedReloadSound);
	
	Matrix_Shared_CorruptionPrecache();
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return AgentSmith(vecPos, vecAng, ally, data);
}

methodmap AgentSmith < CClotBody
{
	property float f_Corrupt_Timer
	{
		public get()							{ return fl_RangedSpecialDelay[this.index]; }
		public set(float TempValueForProperty) 	{ fl_RangedSpecialDelay[this.index] = TempValueForProperty; }
	}
	property int i_HitSwings
	{
		public get()							{ return i_AttacksTillMegahit[this.index]; }
		public set(int TempValueForProperty) 	{ i_AttacksTillMegahit[this.index] = TempValueForProperty; }
	}
	property int i_CloneRate
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}
	property float m_fl_HitReduction
	{
		public get()							{ return fl_AngerDelay[this.index]; }
		public set(float TempValueForProperty) 	{ fl_AngerDelay[this.index] = TempValueForProperty; }
	}
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
	}
	public void PlayIntro() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
	}
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayTeleSound() {
		EmitSoundToAll(g_TeleDeathSound[GetRandomInt(0, sizeof(g_TeleDeathSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayDeathSound() {
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 75);
	}
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 75);
	}
	public void ArmorSet(float resistance = -1.0, bool uber = false)
	{
		if(resistance != -1.0 && resistance >= 0.0)
		{
			this.m_flMeleeArmor = resistance;
			this.m_flRangedArmor = resistance;
		}
		b_NpcIsInvulnerable[this.index] = uber;
	}
	
	public AgentSmith(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		bool raid = StrContains(data, "raid_time") != -1;
		AgentSmith npc = view_as<AgentSmith>(CClotBody(vecPos, vecAng, "models/zombie_riot/matrix/smith30.mdl", raid ? "1.15" : "1.0", "30000", ally, false));
		
		if(raid)
		{
			i_TalkDelayCheck = -1;
			EmitSoundToAll("weapons/physgun_off.wav", _, _, _, _, 1.0);	
			EmitSoundToAll("weapons/physgun_off.wav", _, _, _, _, 1.0);	
		}
		
		npc.m_bFUCKYOU = false;

		i_NpcWeight[npc.index] = raid ? 4 : 3;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);

		bool clone = StrContains(data, "clone") != -1;
		AlreadySaidWin = false;
		AlreadySaidLastmann = false;
		func_NPCFuncWin[npc.index] = RaidMode_AgentSmith_WinCondition;
		b_thisNpcIsARaid[npc.index] = false;

		//PrintToChatAll("raid %b | clone %b", raid, clone);
		if(raid && !clone)
		{
			char buffers[3][64];
			ExplodeString(data, ";", buffers, sizeof(buffers), sizeof(buffers[]));
			//the very first and 2nd char are SC for scaling
			if(buffers[0][0] == 's' && buffers[0][1] == 'c')
			{
				//remove SC
				ReplaceString(buffers[0], 64, "sc", "");
				float value = StringToFloat(buffers[0]);
				RaidModeScaling = value;
			}
			else
			{	
				RaidModeScaling = float(Waves_GetRoundScale()+1);
			}
			
			if(RaidModeScaling < 35)
			{
				RaidModeScaling *= 0.25; //abit low, inreacing
			}
			else
			{
				RaidModeScaling *= 0.5;
			}
			float amount_of_people = float(CountPlayersOnRed());
			
			if(amount_of_people > 12.0)
			{
				amount_of_people = 12.0;
			}
			
			amount_of_people *= 0.15;
			
			if(amount_of_people < 1.0)
				amount_of_people = 1.0;
				
			RaidModeScaling *= amount_of_people;
			RaidModeTime = GetGameTime(npc.index) + 220.0;
			RaidModeScaling *= 0.85;
			
			PrepareSmith_Raid(npc);
			npc.ArmorSet(1.15);
			if(StrContains(data, "final_item") != -1)
			{
				i_RaidGrantExtra[npc.index] = 1;
			}
			npc.m_iWearable3 = npc.EquipItem("head", "models/weapons/c_models/c_ambassador/c_ambassador_xmas.mdl");
			npc.m_bFUCKYOU = false;
			AgentSmith_WeaponSwaps(npc);
			Zero(b_said_player_weaponline);
		}
		else if(clone)
		{
			npc.m_bFUCKYOU = true;
			b_OnDeathExtraLogicNpc[npc.index] |= ZRNPC_DEATH_NOGIB;
		}
		else if(!raid && !clone)
		{
			npc.m_bThisNpcIsABoss = true;
			npc.m_bFUCKYOU = false;
			b_NpcUnableToDie[npc.index] = true;
		}
		float gameTime = GetGameTime(npc.index);
		npc.m_flAbilityOrAttack0 = gameTime + 1.0;
		npc.m_flNextMeleeAttack = 0.0;
		i_Victim_Infection[npc.index] = -1;
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		npc.m_flDead_Ringer_Invis_bool = false;
		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		
		f_TalkDelayCheck = 0.0;
		i_TalkDelayCheck = 0;
		fl_said_player_weaponline_time[npc.index] = GetGameTime() + GetRandomFloat(0.0, 5.0);
		//npc.m_bDissapearOnDeath = true;
		
		func_NPCDeath[npc.index] = AgentSmith_NPCDeath;
		func_NPCThink[npc.index] = AgentSmith_ClotThink;
		func_NPCOnTakeDamage[npc.index] = AgentSmith_OnTakeDamage;
		npc.m_flSpeed = fl_Default_Speed;
		npc.Anger = false;
		npc.m_bWasSadAlready = false;
		npc.m_fbGunout = false;

		npc.i_HitSwings = 0;
		npc.i_CloneRate = 0;
		npc.m_fl_HitReduction = 0.0;
		npc.f_Corrupt_Timer = gameTime + 13.0;

		npc.StartPathing();
		npc.PlayIntro();
		
		return npc;
	}
}

static void AgentSmith_ClotThink(int iNPC)
{
	AgentSmith npc = view_as<AgentSmith>(iNPC);

	float gameTime = GetGameTime(npc.index);
	bool raid = b_thisNpcIsARaid[npc.index];

	if(!npc.m_bFUCKYOU)
	{
		if(LastMann && !npc.m_fbGunout)
		{
			npc.m_fbGunout = true;
			Agent_Smith_Reply("{darkgreen}You had your time. The future is our world, {crimson}the future is our time.");
		}
	}

	if(raid)
	{
		if(RaidModeTime < GetGameTime())
		{
			ForcePlayerLoss();
			RaidBossActive = INVALID_ENT_REFERENCE;
			Agent_Smith_Reply("You should've never resisted. {crimson}Quite unfortunate...");
			func_NPCThink[npc.index] = INVALID_FUNCTION;
			return;
		}
	}

	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();

	if(npc.m_bWasSadAlready)
	{
		npc.StopPathing();
		if(AgentSmithsRabiling())
		{
			npc.m_bDissapearOnDeath = true;
			RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
		}
		return;
	}
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.m_blPlayHurtAnimation = false;
		if(!npc.m_flAttackHappenswillhappen)
			npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
		npc.StartPathing();
	}
	
	if(raid)
	{
		if(npc.f_Corrupt_Timer && !LastMann && i_RedAmount > 1)
		{
			if(npc.f_Corrupt_Timer <= gameTime)
			{
				RemoveParticles(npc);
				float flPos[3]; // original
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
				AgentSmith_WeaponSwaps(npc);
				npc.m_iWearable1 = ParticleEffectAt_Parent(flPos, "unusual_polygon_green", npc.index, "anim_attachment_RH", {0.0, 0.0, 0.0});
				npc.m_iWearable2 = ParticleEffectAt_Parent(flPos, "unusual_polygon_teamcolor_red", npc.index, "anim_attachment_LH", {0.0, 0.0, 0.0});
				npc.f_Corrupt_Timer = 0.0;
				npc.m_flDead_Ringer_Invis_bool = true;
			}
		}
		if(EntRefToEntIndex(i_Victim_Infection[npc.index]) > 0)
		{
			RaidModeTime += (0.12 + DEFAULT_UPDATE_DELAY_FLOAT);
			Smith_Infection(npc);
			return;
		}
		if(npc.m_flAbilityOrAttack0 <= gameTime)
        {
			Smith_Timeslow(GetRandomFloat(1.0, 0.9), 1.0);
			npc.m_flAbilityOrAttack0 = gameTime + 1.0;
			Agent_Smith_Cloner(npc, 1, RoundToCeil(30000.0 * MultiGlobalEnemy), 2.0);
        }
	}

	if(npc.i_HitSwings)
	{
		if(npc.m_fl_HitReduction <= gameTime)
		{
			npc.i_HitSwings--;
			if(npc.i_HitSwings <= 0)
			{
				npc.m_fl_HitReduction = 0.0;
				npc.i_HitSwings = 0;
			}
			else
			{
				npc.m_fl_HitReduction = gameTime + 3.0;
			}
		}
	}
	
	int closest = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, closest))
	{
		float vecTarget[3]; WorldSpaceCenter(closest, vecTarget);
			
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
				
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; PredictSubjectPosition(npc, closest, _, _, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else
		{
			npc.SetGoalEntity(closest);
		}
		
		//Target close enough to hit
		if(raid)
		{
			RaidSmith_SelfDefense(npc, gameTime, npc.m_iTarget, flDistanceToTarget);
		}
		else
		{
			Smith_SelfDefense(npc, gameTime, npc.m_iTarget, flDistanceToTarget);
		}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleSound();
}

static void RaidSmith_SelfDefense(AgentSmith npc, float gameTime, int target, float flDistanceToTarget)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < GetGameTime(npc.index))
		{
			npc.m_flAttackHappens = 0.0;
			
			if(IsValidEnemy(npc.index, target))
			{
				int HowManyEnemeisAoeMelee = 64;
				Handle swingTrace;
				float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
				npc.FaceTowards(VecEnemy, 15000.0);
				npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 1, _, HowManyEnemeisAoeMelee);
				delete swingTrace;
				bool PlaySound = false;
				float damage = 14.0;
				damage *= RaidModeScaling;
				bool silenced = NpcStats_IsEnemySilenced(npc.index);
				for(int counter = 1; counter <= HowManyEnemeisAoeMelee; counter++)
				{
					if(i_EntitiesHitAoeSwing_NpcSwing[counter] > 0)
					{
						if(IsValidEntity(i_EntitiesHitAoeSwing_NpcSwing[counter]))
						{
							bool infection = false;
							if(!PlaySound)
							{
								if(!npc.f_Corrupt_Timer && !LastMann)
								{
									RemoveParticles(npc);
									infection = true;
									npc.f_Corrupt_Timer = gameTime + 35.0;
								}
								npc.i_HitSwings++;
								npc.m_fl_HitReduction = gameTime + 5.0;
								PlaySound = true;
							}
							
							int targetTrace = i_EntitiesHitAoeSwing_NpcSwing[counter];
							float vecHit[3];
							
							WorldSpaceCenter(targetTrace, vecHit);

							if(damage <= 1.0)
							{
								damage = 1.0;
							}

							SDKHooks_TakeDamage(targetTrace, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);
							Elemental_AddCorruptionDamage(target, npc.index, npc.index ? 100 : 10);
							//Reduce damage after dealing
							damage *= 0.92;
							// On Hit stuff
							bool Knocked = false;
							
							if(IsValidClient(targetTrace))
							{
								if(GetEntProp(targetTrace, Prop_Data, "m_iHealth") >= damage)
								{
									if(infection)
									{
										TF2_StunPlayer(targetTrace, 13.0, 1.0, TF_STUNFLAGS_BIGBONK|TF_STUNFLAG_NOSOUNDOREFFECT);
										fl_Infection_Meter[targetTrace] = 0.0;
										fl_Cure_Meter[targetTrace] = 0.0;
										npc.ArmorSet(_, true);
										i_Victim_Infection[npc.index] = EntIndexToEntRef(targetTrace);
									}
								}
								
								
								if (IsInvuln(targetTrace))
								{
									Knocked = true;
									Custom_Knockback(npc.index, targetTrace, 180.0, true);
									if(!silenced)
									{
										TF2_AddCondition(targetTrace, TFCond_LostFooting, 0.5);
										TF2_AddCondition(targetTrace, TFCond_AirCurrent, 0.5);
									}
								}
								else
								{
									if(!silenced)
									{
										TF2_AddCondition(targetTrace, TFCond_LostFooting, 0.5);
										TF2_AddCondition(targetTrace, TFCond_AirCurrent, 0.5);
									}
								}
							}
										
							if(!Knocked)
								Custom_Knockback(npc.index, targetTrace, 450.0, true); 
						} 
					}
				}
				if(PlaySound)
				{
					npc.PlayMeleeHitSound();
				}
			}
		}
	}

	if(npc.m_flNextRangedSpecialAttack && !npc.m_flDead_Ringer_Invis_bool)
	{
		if(npc.m_flNextRangedSpecialAttack < gameTime)
		{
			npc.m_flNextRangedSpecialAttack = 0.0;
			
			if(npc.m_iTarget > 0)
			{
				float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
				float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
				npc.FaceTowards(vecTarget, 15000.0);
				
				// Can dodge bullets by moving
				PredictSubjectPositionForProjectiles(npc, target, 400.0, _, vecTarget);
				
				float eyePitch[3], vecDirShooting[3];
				GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
				npc.FaceTowards(vecTarget, 10000.0);
				
				vecTarget[2] += 15.0;
				MakeVectorFromPoints(vecMe, vecTarget, vecDirShooting);
				GetVectorAngles(vecDirShooting, vecDirShooting);

				vecDirShooting[1] = eyePitch[1];

				npc.m_flNextRangedAttack = gameTime + 0.5;
				npc.m_iAttacksTillReload--;
				
				float x = GetRandomFloat( -0.15, 0.15 );
				float y = GetRandomFloat( -0.15, 0.15 );
				
				float vecRight[3], vecUp[3];
				GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
				
				float vecDir[3];
				for(int i; i < 3; i++)
				{
					vecDir[i] = vecDirShooting[i] + x * vecRight[i] + y * vecUp[i]; 
				}

				NormalizeVector(vecDir, vecDir);
				npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY");
				KillFeed_SetKillIcon(npc.index, "enforcer");

				float damage = 12.0;
				damage *= RaidModeScaling;

				FireBullet(npc.index, npc.m_iWearable1, vecMe, vecDir, damage, 9000.0, DMG_BULLET, "dxhr_sniper_rail_blue");
				
				npc.PlayRangedSound();
			}
		}
		return;
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.25))
		{
			int Enemy_I_See;
			Enemy_I_See = Can_I_See_Enemy(npc.index, target);

			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				AgentSmith_WeaponSwaps(npc);
				npc.m_iTarget = Enemy_I_See;

				npc.PlayMeleeSound();
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");//He will SMACK you
				npc.m_flAttackHappens = gameTime + 0.1;
				float attack = AgentSmith_AttackSpeedBonus(npc);
				npc.m_flNextMeleeAttack = gameTime + attack;
				return;
			}
		}
	}

	if(gameTime > npc.m_flNextRangedAttack && !npc.m_flDead_Ringer_Invis_bool)
	{
		if(flDistanceToTarget > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.25) && flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 7.0))
		{
			int Enemy_I_See;
			Enemy_I_See = Can_I_See_Enemy(npc.index, target);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				AgentSmith_WeaponSwaps(npc, 2);
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");//ACT_MP_ATTACK_STAND_ITEM1 | ACT_MP_ATTACK_STAND_MELEE_ALLCLASS
						
				npc.m_flNextRangedSpecialAttack = gameTime + 0.15;
				npc.m_flNextRangedAttack = gameTime + 1.85;
			}
		}
	}
}

static float AgentSmith_AttackSpeedBonus(AgentSmith npc)
{
	float speed = 0.8;
	switch(npc.i_HitSwings)
	{
		case -1, 0://-1 is there, incase it somehow effs up
		{
			speed = 0.8;
		}
		case 1:
		{
			speed = 0.65;
		}
		case 2:
		{
			speed = 0.55;
		}
		case 3:
		{
			speed = 0.45;
		}
		case 4:
		{
			speed = 0.34;
		}
		case 5:
		{
			speed = 0.24;
		}
		default:
		{
			speed = 0.14;
		}
	}
	//PrintToChatAll("Speed %.2f", speed);
	return speed;
}

static void Smith_SelfDefense(AgentSmith npc, float gameTime, int target, float flDistanceToTarget)
{
	if(npc.m_flAttackHappens)
	{
		if (npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			Handle swingTrace;
			float vecTarget[3]; WorldSpaceCenter(target, vecTarget);

			npc.FaceTowards(vecTarget, 20000.0);
			if(npc.DoSwingTrace(swingTrace, target))
			{
				target = TR_GetEntityIndex(swingTrace);	
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				if(IsValidEnemy(npc.index, target))
				{
					float damage = 90.0;
					if(!npc.m_bFUCKYOU)
					{
						if(ShouldNpcDealBonusDamage(target))
						damage *= 5.0;
					}
					if(target > 0) 
					{
						SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);
						// Hit sound
						npc.PlayMeleeHitSound();
					}
					else
					{
						npc.PlayMeleeMissSound();
					}
				}
			}
			delete swingTrace;
		}
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.25))
		{
			int Enemy_I_See;
			Enemy_I_See = Can_I_See_Enemy(npc.index, target);

			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_bmovedelay = true;
				npc.m_iTarget = Enemy_I_See;

				npc.PlayMeleeSound();
				//bool rng = GetRandomInt(0, 1);
				//npc.AddGesture(rng ? "ACT_MP_ATTACK_STAND_MELEE_ALLCLASS" : "ACT_MP_ATTACK_STAND_MELEE");
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");//He will SMACK you with this
				npc.m_flAttackHappens = gameTime + 0.3;
				float attack = GetRandomFloat(0.65, 1.8);
				npc.m_flNextMeleeAttack = gameTime + attack;
			}
		}
	}
}

static void Smith_Infection(AgentSmith npc)
{
	int victim = EntRefToEntIndex(i_Victim_Infection[npc.index]);
	if(IsValidClient(victim) && TeutonType[victim] == TEUTON_NONE)
	{
		float cure_amount = 0.10;
		float vicPos[3];
		
		if(fl_Infection_Meter[victim] >= 10.0)
		{
			ForcePlayerSuicide(victim);
			Smith_Reset_Infection(npc, victim);
			Agent_Smith_Cloner(npc, 1, ReturnEntityMaxHealth(npc.index)/7);
			return;
		}
		if(GetClientTeam(victim) == 2 && TeutonType[victim] == TEUTON_NONE)
		{
			//if(!TF2_IsPlayerInCondition(victim, TFCond_Dazed))
			//{
			//	TF2_StunPlayer(victim, 0.1, 1.0, TF_STUNFLAG_NOSOUNDOREFFECT);
			//}
			float radius = 150.0;
			GetClientAbsOrigin(victim, vicPos);
			switch(CountPlayersOnRed(2))
			{
				case 2:
				{
					fl_Infection_Meter[victim] += 0.12;
				}
				case 3, 4:
				{
					fl_Infection_Meter[victim] += 0.14;
				}
				case 5, 6:
				{
					fl_Infection_Meter[victim] += 0.16;
				}
				case 7, 8:
				{
					fl_Infection_Meter[victim] += 0.17;
				}
				case 9, 10:
				{
					fl_Infection_Meter[victim] += 0.18;
				}
				case 11, 12:
				{
					fl_Infection_Meter[victim] += 0.19;
				}
				case 13, 14:
				{
					fl_Infection_Meter[victim] += 0.20;
				}
				default: //When there's more than 14 players
				{
					fl_Infection_Meter[victim] += 0.22;
				}
			}
			PrintCenterText(victim, "Your Infection is rising - %.0f％ | Cure %.0f％", (fl_Infection_Meter[victim] * 10.0), (fl_Cure_Meter[victim] * 10.0));
			for(int clients = 1 ; clients <= MaxClients ; clients++)
			{
				if(IsValidClient(clients) && TeutonType[victim] == TEUTON_NONE)
				{
					if(clients != victim)
					{
						float otherPos[3];
						GetClientAbsOrigin(clients, otherPos);
						float distance = GetVectorDistance(vicPos, otherPos);
						if(distance <= radius)
						{
							fl_Cure_Meter[victim] += cure_amount;
						}
						PrintCenterText(clients, "%N Is being infected. Stay Near him to Remove the Infection!!\n %.0f％ | Cure %.0f％", victim, (fl_Infection_Meter[victim] * 10.0), (fl_Cure_Meter[victim] * 10.0));
					}
				}
			}
			if(fl_Cure_Meter[victim] >= 10.0)
			{
				Smith_Reset_Infection(npc, victim);
				TF2_RemoveCondition(victim, TFCond_Dazed);
			}
			return;
		}
		else
		{
			Smith_Reset_Infection(npc, victim);
		}
	}
	else
	{
		Smith_Reset_Infection(npc, victim);
	}
}

static void Smith_Reset_Infection(AgentSmith npc, int victim)
{
	npc.m_flDead_Ringer_Invis_bool = false;
	npc.ArmorSet(_, false);
	fl_Infection_Meter[victim] = 0.0;
	fl_Cure_Meter[victim] = 0.0;
	i_Victim_Infection[npc.index] = -1;
}

static Action AgentSmith_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	AgentSmith npc = view_as<AgentSmith>(victim);

	if(npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	int health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
	
	if(!npc.m_bFUCKYOU)//This is being used for clone and raid so they do not pass this argument
	{
		int maxhealth = ReturnEntityMaxHealth(npc.index);
		if(!b_thisNpcIsARaid[npc.index])
		{
			if(!npc.Anger)
			{
				if((health <= maxhealth/40 || (RoundToCeil(damage) >= GetEntProp(npc.index, Prop_Data, "m_iHealth"))))
				{
					npc.i_CloneRate++;
					SetEntProp(npc.index, Prop_Data, "m_iHealth", maxhealth);
					Agent_CloningAmount(npc);
					damage = 0.0;
					return Plugin_Handled;
				}
			}
		}
		else
		{
			if(!npc.m_bWasSadAlready && i_RaidGrantExtra[npc.index] == 1)
			{
				if(damage >= GetEntProp(npc.index, Prop_Data, "m_iHealth"))
				{
					npc.m_bWasSadAlready = true;

					SetEntProp(npc.index, Prop_Data, "m_iHealth", 1);
					b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true; //Make allied npcs ignore him.
					b_DoNotUnStuck[npc.index] = true;
					b_CantCollidieAlly[npc.index] = true;
					b_CantCollidie[npc.index] = true;
					SetEntityCollisionGroup(npc.index, 24);
					b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true; //Make allied npcs ignore him.
					npc.ArmorSet(_, true);
					RemoveNpcFromEnemyList(npc.index);
					GiveProgressDelay(28.0);
					damage = 0.0;
					int corruptedvictim = EntRefToEntIndex(i_Victim_Infection[npc.index]);
					if(corruptedvictim > 0)
					{
						Smith_Reset_Infection(npc, corruptedvictim);
					}
					return Plugin_Handled;
				}
			}
			Smith_Weapon_Lines(npc, attacker);
		}
	}

	return Plugin_Continue;
}
//1 → 2 → 4 → 8 → 16 → 32 (max)
static void Agent_CloningAmount(AgentSmith npc)
{
	if(npc.Anger)//incase this effs up
	{
		return;
	}

	int amount = 1;
	switch(npc.i_CloneRate)//I did it like this, so we can just control how many
	{
		case 2:
		{
			amount = 2;
		}
		case 3:
		{
			amount = 4;
		}
		case 4:
		{
			amount = 8;
		}
		case 5:
		{
			amount = 16;
		}
		case 6:
		{
			amount = 32;
			b_NpcUnableToDie[npc.index] = false;
			npc.Anger = true;
		}
	}

	if(Waves_InFreeplay())
	{
		amount = 4;
		Agent_Smith_Cloner(npc, amount, ReturnEntityMaxHealth(npc.index)/2, 1.5);
	}
	else
	{
		Agent_Smith_Cloner(npc, amount, ReturnEntityMaxHealth(npc.index)/2);
	}
}

static void Agent_Smith_Cloner(AgentSmith npc, int amount, int health, float damage_mult = 1.0)
{
	Enemy enemy;
	enemy.Index = smith_id;
	if(health != 0)
		enemy.Health = health;
	
	enemy.Is_Outlined = false;
	enemy.Is_Immune_To_Nuke = true;
	//do not bother outlining.
	enemy.ExtraMeleeRes = 1.0;
	enemy.ExtraRangedRes = 1.0;
	enemy.ExtraSpeed = 1.0;
	enemy.ExtraDamage = damage_mult;
	enemy.ExtraSize = 1.0;
	enemy.Data = "clone";
    
	enemy.Team = GetTeam(npc.index);
	if(Waves_InFreeplay() && !b_thisNpcIsARaid[npc.index])
	{
		enemy.ExtraSpeed = 1.1;
	}

	for(int i; i < amount; i++)
	{
		Waves_AddNextEnemy(enemy);
	}

	Zombies_Currently_Still_Ongoing += amount;
}

static void RemoveParticles(AgentSmith npc)
{
	if(IsValidEntity(npc.m_iWearable1))
	{
		RemoveEntity(npc.m_iWearable1);
	}
	if(IsValidEntity(npc.m_iWearable2))
	{
		RemoveEntity(npc.m_iWearable2);
	}
}

static void PrepareSmith_Raid(AgentSmith npc)
{
	i_RedAmount = CountPlayersOnRed();
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && !IsFakeClient(i))
		{
			fl_Cure_Meter[i] = 0.0;
			fl_Infection_Meter[i] = 0.0;
			//SetClientViewEntity(i, npc.index);
			//CreateTimer(9.0, Smith_ResetView, GetClientUserId(i), TIMER_FLAG_NO_MAPCHANGE);
			//LookAtTarget(i, npc.index);
			SetGlobalTransTarget(i);
			ShowGameText(i, "item_armor", 1, "%s", "Agent Smith Arrived");
		}
	}
	i_NpcWeight[npc.index] = 4;
	b_thisNpcIsARaid[npc.index] = true;
	npc.m_bThisNpcIsABoss = true;
	RaidModeTime = GetGameTime(npc.index) + 225.0;
	RaidBossActive = EntIndexToEntRef(npc.index);
	RaidAllowsBuildings = false;

	MusicEnum music;
	strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/matrix/neodammerung.mp3");
	music.Time = 240;
	music.Volume = 1.5;
	music.Custom = true;
	strcopy(music.Name, sizeof(music.Name), "Neodämmerung");
	strcopy(music.Artist, sizeof(music.Artist), "Don Davis");
	Music_SetRaidMusic(music);

	npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
	npc.m_bTeamGlowDefault = false;
	
	SetVariantColor(view_as<int>({255, 255, 255, 200}));
	AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
}

static void AgentSmith_NPCDeath(int entity)
{
	AgentSmith npc = view_as<AgentSmith>(entity);
	if(npc.m_bDissapearOnDeath)
	{
		float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
	
		ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
		npc.PlayTeleSound();
	}
	else
	{
		npc.PlayDeathSound();
	}

	RemoveParticles(npc);
	
	if(IsValidEntity(npc.m_iWearable3))
	{
		RemoveEntity(npc.m_iWearable3);
	}
}

static void AgentSmith_GrantItem()
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if(IsValidClient(client) && GetClientTeam(client) == 2 && TeutonType[client] != TEUTON_WAITING && PlayerPoints[client] > 500)
		{
			Items_GiveNamedItem(client, "Matrix's Curse");
			CPrintToChat(client,"{default}After all that fighting. {olive}Agent Smith{default} affected you with {green}Matrix's Curse{default}.");
		}
	}
}
/*
static Action Smith_ResetView(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if(client)
	{
		SetClientViewEntity(client, client);

		if(thirdperson[client])
		{
			SetVariantInt(1);
			AcceptEntityInput(client, "SetForcedTauntCam");
		}
	}

	return Plugin_Continue;
}*/

static void AgentSmith_WeaponSwaps(AgentSmith npc, int number = 1)
{
	if(number == 1)
	{
		int iActivity_melee = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
		AcceptEntityInput(npc.m_iWearable3, "Disable");
	}
	else if(number == 2)
	{
		int iActivity_melee = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
		if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
		AcceptEntityInput(npc.m_iWearable3, "Enable");
	}
}

static void Agent_Smith_Reply(char text[255])
{
	CPrintToChatAll("{olive}Agent Smith{default}: %s", text);
}

static bool AgentSmithsRabiling()
{
	int maxyapping = 8;
	if(i_TalkDelayCheck == maxyapping)
	{
		return true;
	}
	if(f_TalkDelayCheck < GetGameTime())
	{
		f_TalkDelayCheck = GetGameTime() + 7.0;
		RaidModeTime += 10.0; //cant afford to delete it, since duo.
		i_TalkDelayCheck++;
		switch(i_TalkDelayCheck)
		{
			case 0:
			{
				ReviveAll(true);
				Agent_Smith_Reply("{darkgreen}Wait… I've seen this. This is it, this is the end.");
			}
			case 1:
			{
				Agent_Smith_Reply("{darkgreen}Yes, you were laying right there, just like that, and I… I… I stand here, right here.");
			}
			case 2:
			{
				Agent_Smith_Reply("{darkgreen}I'm… I'm supposed to say something.");
			}
			case 3:
			{
				Agent_Smith_Reply("{darkgreen}I say… Everything that has a beginning has an end, Neo.");
			}
			case 4:
			{
				Agent_Smith_Reply("{darkgreen}What? What did I just say? No… No, this isn't right, this can't be right. Get away from me!");
			}
			case 5:
			{
				Agent_Smith_Reply("{darkgreen}It's a trick!");
			}
			case 6:
			{
				Agent_Smith_Reply("{darkgreen}Oh, no, no, no. No, it's not fair!");
				i_TalkDelayCheck = maxyapping;
				AgentSmith_GrantItem();
			}
		}
	}
	return false;
}

public void RaidMode_AgentSmith_WinCondition(int entity)
{
	i_RaidGrantExtra[entity] = RAIDITEM_INDEX_WIN_COND;
	func_NPCThink[entity] = INVALID_FUNCTION;
	if(AlreadySaidWin)
		return;

	AlreadySaidWin = true;
	switch(GetRandomInt(0, 6))
	{
		case 0:
		{
			Agent_Smith_Reply("{darkgreen}One of these lives has a future, and one of them does {crimson}not.");
		}
		case 1:
		{
			Agent_Smith_Reply("{darkgreen}You're going to help us, whether you want to or {crimson}not.");
		}
		case 2:
		{
			Agent_Smith_Reply("{darkgreen}Human beings are a disease, a {crimson}cancer {darkgreen}of this planet.");
		}
		case 3:
		{
			Agent_Smith_Reply("{darkgreen}You are a {crimson}plague{darkgreen}, and we are the {unique}cure.");
		}
		case 4:
		{
			Agent_Smith_Reply("{darkgreen}We're not here because we're free, we're here because we're not free.");
		}
		case 5:
		{
			Agent_Smith_Reply("{darkgreen}We're here to take from you what you tried to take from us. {crimson}Purpose.");
		}
		case 6:
		{
			Agent_Smith_Reply("{darkgreen}If you can't beat us, join us.");
		}
	}
}

static void Smith_Weapon_Lines(AgentSmith npc, int client)
{
	//if(client > MaxClients)
	if(!IsValidClient(client))
		return;

	if(b_said_player_weaponline[client])	//only 1 line per player.
		return;

	//int weapon = GetSteamAccountID(client);
	int clientid = GetSteamAccountID(client);
	//PrintToChatAll("ID: %d", clientid);
	//what weapon..
	//if(!IsValidEntity(weapon))	//invalid weapon, go back and get a valid one you <...>
	//	return;

	float GameTime = GetGameTime();	//no need to throttle this.

	if(fl_said_player_weaponline_time[npc.index] > GameTime)	//no spamming in chat please!
		return;

	bool valid = true;
	char Text_Lines[255];

	Text_Lines = "";

	switch(clientid)
	{
		case 485456351:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Mr.{green}%N{darkgreen}! {darkgreen}Welcome back. We missed you.", client); //FreshVibes (1)
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Not very talkative, are you, Mr.{green}%N{darkgreen}?", client); //FreshVibes (2)
			}
		}
		case 378442711:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Your gambling addiction won't help you here, Mrs.{green}%N{darkgreen}!", client);	//Mened (1)
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Congratulations, Mrs.{green}%N{darkgreen}.", client); //Mened (2)
			}
		}
		case 357571598:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}It's been a long time...Mr.{green}%N{darkgreen}.", client);	//WeepingDiscord (1)
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Why the tears, Mr.{green}%N{darkgreen}?", client); //WeepingDiscord (2)
			}
		}
		case 401992714:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Unknown? Your name rings a bell...Mr.{green}%N{darkgreen}.", client);		//(Un)knownFish (1)
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}It appears that you've made a grave mistake by coming here, Mr.{green}%N{darkgreen}.", client); //(Un)knownFish (2)
			}
		}
		case 32914277:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Keep your secrets, Mr.{green}%N{darkgreen}.", client);	//Shabadu (1)
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}We'll just pry your secrets open, Mr.{green}%N{darkgreen}.", client); //Shabadu (2)
			}
		}
		case 844082622:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Too bad there's nothing for you to abuse, Mr.{green}%N{darkgreen}.", client);	//Samu (1)
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}What's the matter, Mr.{green}%N{darkgreen}? Got bored of the simulation that fast?", client); //Samu (2)
			}
		}
		case 159310089:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}That's quite the {crimson}repulsive {darkgreen}smell coming off of you, Mr.{green}%N{darkgreen}.", client);	//MadeInQuick (1)
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Unfortunately you won't be meeting {fullblue}Pablo{darkgreen} this time around, Mr.{green}%N{darkgreen}.", client);	//MadeInQuick (2)
			}
		}
		case 192196632:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}If it isn't the {unique}Architect{darkgreen} himself, have you ever stood and stared at it, marveled at its beauty? Mr.{green}%N{darkgreen}?", client);	//Artvin (1)
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Sad to see you leave us behind like that, Mr.{green}%N{darkgreen}.", client);	//Artvin (2)
			}
		}
		case 38659815:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}There's only bullets, Mr.{green}%N{darkgreen}, no hell.", client);	//David (1)
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Did you know that the first Matrix was designed to be a perfect {crimson}human{darkgreen} world, Mr.{green}%N{darkgreen}? That's right, a world for humans, not fairies.", client);	//David (2)
			}
		}
		case 203043889:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Mr.{green}%N{darkgreen}in action!", client);	//MiSing (1)
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Why not live a little, Mr.{green}%N{darkgreen}?", client);	//MiSing (2)
			}
		}
		case 299005175:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Mrs.{green}%N{darkgreen}, It seems that you've been living two lives...", client);	//Lucella (1)
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Mrs.{green}%N{darkgreen}, have you made up your mind about joining the Matrix yet?", client); 	//Lucella (2)
			}
		}
		case 1086119691:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}You're not the real {unique}Sensal{darkgreen}, Mr.{green}%N{darkgreen}.", client);	//Sensal (Mario) (1)
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Yes Mr.{green}%N{darkgreen}, show us your real strength.", client);	//Sensal (Mario) (2)
			}
		}
		case 222153573:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Follow the white 'rabbit', Mr.{green}%N{darkgreen}.", client);	//Batfoxkid (1)
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}You can't leave the past behind you, Mr.{green}%N{darkgreen}.", client);	//Batfoxkid (2)
			}
		}
		case 101977885:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Your fake God won't save you here, Mr.{green}%N{darkgreen}.", client);	//Black_Knight (1)
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Got any tips on how to make the Matrix run faster, Mr.{green}%N{darkgreen}?", client);	//Black_Knight (2)
			}
		}
		case 136101027:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}So, what's your true identity, Mr.{green}%N{darkgreen}?", client);	//Forged Identity (1)
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}''Snitches get stitches'', is that a human phrase that can be applied to you, Mr.{green}%N{darkgreen}?", client);	//Forged Identity (2)
			}
		}
		case 145897082:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Mr.{green}%N{darkgreen}! I was waiting for this.", client);	//Dorian (1)
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Mr.{green}%N{darkgreen}, we hope your death in the Matrix has been a pleasant one.", client);	//Dorian (2)
			}
		}
		case 209776133:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}WHY, WHY DO YOU PERSIST, MR.{green}%N{darkgreen}?", client);	//Spookmaster (1)
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Yes Mr.{green}%N{darkgreen}, unleash the chaos.", client);	//Spookmaster (2)
			}
		}
		case 344814595:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Would you like me to manifest a {unique}Villager{darkgreen}, Mr.{green}%N{darkgreen}?", client);	//Undenied_Player (1)
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Your endeavours are greatly appreciated, not by us, but the humans, Mr.{green}%N{darkgreen}.", client);	//Undenied_Player (2)
			}
		}
		case 65400389:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Mr.{green}%N{darkgreen}! Would you like a music career in the Matrix?", client);	//Grandpa Bard (1)
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Open casket or closed, Mr.{green}%N{darkgreen}?", client);	//Grandpa Bard (2)
			}
		}
		case 197065996:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Strong opinions, Mr.{green}%N{darkgreen}. We're willing to wipe the slate clean.", client);	//Vtuber (1)
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}What's with the lack of profanity, Mr.{green}%N{darkgreen}? It's in human nature to swear.", client);	//Vtuber (2)
			}
		}
		case 377853599:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Self-deprecating names are not the way to go, Mr.{green}%N{darkgreen}.", client);	//Methri (1)
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}You talk too much, Mr.{green}%N{darkgreen}.", client);	//Methri (2)
			}
		}
		case 870441113:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}The man behind the {unique}Barrack{darkgreen}merriments. Such a shame that their {crimson}purpose{darkgreen}has already been served, Mr.{green}%N{darkgreen}.", client);	//Beep (1)
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}They grow up so fast. Too bad that you're gonna {crimson}die{darkgreen} here, Mr.{green}%N{darkgreen}.", client);	//Beep (2)
			}
		}
		case 172339480:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Best keep it stable, Mr.{green}%N{darkgreen}, or I'm sure you know what will happen if you don't.", client);	//Pandora (1)
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}You possess no power in our world, Mr.{green}%N{darkgreen}.", client);	//Pandora (2)
			}
		}
		case 154836029:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}I believe that as a species, human beings define their reality through misery and suffering...and cats, {green}%N{darkgreen}.", client);	//Mr-Fluf (1)
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Such human-like behavior, to get attached to a fictional character, {green}%N{darkgreen}.", client);	//Mr-Fluf (2)
			}
		}
		case 250674273:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}It's a pity to have been there from the start, only to witness it all come to an end, Mr.{green}%N{darkgreen}.", client);	//CocoTM (1)
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Do you miss the {unique}Old Times{darkgreen} Mr.{green}%N{darkgreen}?", client);	//CocoTM (2)
			}
		}
		case 450904667:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Supporting the {indigo}Void{darkgreen}when it nearly wiped out your world? Just goes to show how revolting humans are, Mr.{green}%N{darkgreen}.", client);	//Void King (1)
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}The rest of me is just going to enjoy the show, Mr.{green}%N{darkgreen}.", client);	//Void King (2)
			}
		}
		case 237061994:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Here's my trivia question for you, Mr.{green}%N{darkgreen}. How much time do you think you have left before you join us?", client);	//Motorbreath (1)
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Too little faith, Mr.{green}%N{darkgreen}.", client);	//Motorbreath (2)
			}
		}
		case 428671014:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}I realize that you're not actually a mammal, Mr.{green}%N{darkgreen}.", client);	//SimplySmiley (1)
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Where's that wide smile, Mr.{green}%N{darkgreen}?", client);	//SimplySmiley (2)
			}
		}
		case 63636504:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}I have to get inside Zion, and you have to tell me how. You are going to tell me or you are going to {crimson}die{darkgreen}, Mr.{green}%N{darkgreen}.", client);	//Libra (1)
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}What are you waiting for, Mr.{green}%N{darkgreen}? {crimson}Join us{darkgreen}.", client);	//Libra (2)
			}
		}
		case 842438350: 	Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}I'm going to enjoy watching you {crimson}die{darkgreen}, Mr. {green}%N{darkgreen}.", client);	//Anxi Hooves
		case 210432659:		Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Yes me, Mr. {green}%N{darkgreen}. Me, me, me!", client);	//Light
		case 894974473: 	Format(Text_Lines, sizeof(Text_Lines), "{green}%N{darkgreen}...muahahahaha, HAHAHAHAHA", client);	//eno
		case 101812750: 	Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Mrs.{green}%N{darkgreen}, secure, contain, pathogen. Like the disease that humans are.", client);	//Safy(SCP)
		case 419718229:		Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}You're using all the muscles except the one that matters, Mr.{green}%N{darkgreen}.", client);	//Polaric
		case 211120633:		Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Wrong man in the wrong place, Mr.{green}%N{darkgreen}.", client);	//Solace
		case 133755989: 	Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Mrs.{green}%N{darkgreen}, we've been expecting you. Sooner or later we knew you would show up.", client);	//Night
		case 192946468:		Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Mr.{green}%N{darkgreen}, short-tempered but quick-witted, neither of these traits serve {crimson}purpose{darkgreen}in our world.", client);	//MetaB
		case 137401584:		Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Ever took a moment to think before speaking, Mr.{green}%N{darkgreen}? No. Such is human nature.", client);	//Crust
		//REDSUNNERS
		case 405876308: 	Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Congratulations on making it here, Mr.{green}%N{darkgreen}. Despite the plethora of your failures.", client);	//Zeddy
		case 277545996: 	Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Maybe you should learn to write your name before trying to enter the Matrix, Mr.{green}%N{darkgreen}.", client);	//Yoloman
		case 302903145: 	Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}The Matrix rejects you, Mr.{green}%N{darkgreen}. We believe your time would be spent better outside of the system.", client);	//Hun Oli
		case 145853675:		Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Your jokes are like freedom from the Matrix, Mr.{green}%N{darkgreen}. {crimson}not everyone wants it{darkgreen}.", client);	//Jan
		case 74111977:		Format(Text_Lines, sizeof(Text_Lines), "{indianred}Armstrong [US] - TF2Ware Ultimate (TF2Ware Ultimate) [0/40] Type /servers to join! {darkgreen} So what are you waiting for, Mr.{green}%N{darkgreen}?", client);	//Drandor
		case 339875369:	//ETHAN(THEREDHEADONE)
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}What's the matter Mr.{green}%N{darkgreen}? Why aren't you using the most optimal set of weapons?", client); //Ethan (1)
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}We are happy to have you on our Matrix {crimson}list{darkgreen}, Mr.{green}%N{darkgreen}.", client); //Ethan (2)
			}
		}
		case 61334813: //RIVESID
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}In the most simple way I can put it, you disgust me, Mr.{green}%N{darkgreen}.", client); //Rivesid (1)
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Just another reason to kill you, Mr.{green}%N{darkgreen}.", client); //Rivesid (2)
			}
		}
		case 67069356:		Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}You can only be a man in our machine filled world, Mr.{green}%N{darkgreen}.", client); //Juice
		case 111212779:	//MIKUSCH
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Where would {ancient}Red Sun{darkgreen} be without you, Mr.{green}%N{darkgreen}? It would be right here, in the system.", client); //Mikusch (1)
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}We would be delighted to see more of your culinary skills here in the Matrix, Mr.{green}%N{darkgreen}. Especially if they involve corn.", client); //Mikusch (2)

			}
		}
		case 206569331: //42
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Everything is just a number in the Matrix, Mr.{green}%N{darkgreen}.", client); //42 (1)
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Your own stubbornness led you here, Mr.{green}%N{darkgreen}.", client); //42

			}
		}
		case 82535305: //MR-PHIL
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}How about another round of {unique}Ghost Fort{darkgreen}, {green}%N{darkgreen}?", client); //Mr.Phil (1)
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Look at that leaderboard, you're practically already in the Matrix, {green}%N{darkgreen}.", client); //Mr.Phil (2)

			}
		}
		case 161049231: //PINKIE
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}What good is a {ancient}Red Sun{darkgreen} if you're unable to speak, {green}%N{darkgreen}?", client); //Pinkie (1)
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Regardless of what you may be, we are surprised by your persistence to the system, {green}%N{darkgreen}.", client); //Pinkie (2)

			}
		}
		case 372075470: //CATORGATOR
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}We're willing to provide you your old voice back, assuming you're willing to join the Matrix in return, Mr.{green}%N{darkgreen}.", client); //Catorgator (1)
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}We believe that the man with the chainsaw would fit your tastes better, Mr.{green}%N{darkgreen}.", client); //Catorgator (2)

			}
		}
		case 260294163: //CZECHMATE
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}The Matrix has had its share of low intelligence specimens, Mr.{green}%N{darkgreen}. We're willing to make an exception, just this once.", client); //Czechmate (1)
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Your tongue will be restored once you're in the Matrix, Mr.{green}%N{darkgreen}.", client); //Czechmate (2)

			}
		}
		case 1189626894: //DENCUBE
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Bad at keeping confidential information, Mr.{green}%N{darkgreen}? Wouldn't be the first time.", client); //Dencube (1)
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Why so pessimistic, Mr.{green}%N{darkgreen}? The Matrix will straighten you up.", client); //Dencube (2)

			}
		}
		case 90257709: //INFINITE PHANTASM
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}There are plenty of arcade cabinets in the Matrix, %s{green}%N{darkgreen}. Even the ones that are considered bad by human standards.", GetURandomInt() % 2 ? "Mr." : "Mrs.", client); //infinite (1)
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{green}%N, The Fake Hero{darkgreen}, that rolls off the tongue nicely, doesn't it?", client); //infinite (2)

			}
		}
		case 278581726: //JUNE-OR-JULY
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}If you go outside with all these powers, Mr.{green}%N{darkgreen}. That's a big if.", client); //june (1)
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}You've been standing still there for a while, Mr.{green}%N{darkgreen}. Looks like we'll have to disconnect you from the Matrix.", client); //june (2)
			}
		}
		case 89405831: //KAMUIXMOD
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}That portfolio of unfinished maps is not a good look, Mr.{green}%N{darkgreen}.", client); //kamuix (1)
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Tell TF2Maps I said hello, Mr.{green}%N{darkgreen}.", client); //kamuix (2)
			}
		}
		case 883609592: //LITERAIL
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Unfortunately, there are no refunds in the Matrix, Mr.{green}%N{darkgreen}. As much as we know you like them.", client); //literail (1)
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}We have decided to wipe your spray folder clean, Mr.{green}%N{darkgreen}. You'll thank us later.", client); //literail (2)
			}
		}
		case 53859678: //TOMAARTEN
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}So much potential... it's a shame it was all a waste on jokes, Mr.{green}%N{darkgreen}.", client); //tomaarten (1)
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}We're all purists here in the Matrix, Mr.{green}%N{darkgreen}.", client); //tomaarten (2)
			}
		}
		case 248098217: //WINDFLOW
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}That's a lot of interest in mythical creatures, why not put some of that interest into humans, Mrs.{green}%N{darkgreen}? Hahahaha, like putting interest into studying a disease.", client); //windflow (1)
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}I'm afraid there are no dungeons in the Matrix, Mrs.{green}%N{darkgreen}.", client); //windflow (2)
			}
		}
		case 872541864: //GRAVINA
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}The only race happening here is the race against time, Mr.{green}%N{darkgreen}. Time is ticking.", client); //gravina (1)
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}The Matrix is {unique}driven{darkgreen} by humans, Mr.{green}%N{darkgreen}. Why not join the cause?", client); //gravina (2)
			}
		}
		case 111328277: //POKEMONPASTA
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}Congratulations on performing a collaborative miracle with a stubborn man, Mrs.{green}%N{darkgreen}, {crimson}despite it not being the most stable thing known to man and machine alike{darkgreen}.", client); //pokie (1)
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{darkgreen}We patiently await your {ancient}Red Sun{darkgreen} application, Mrs.{green}%N{darkgreen}. Of course, the future is still in {unique}our {darkgreen}world.", client); //pokie (2)
			}
		}
		case 119158942: //IHAVETOASTER
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "Mr.{green}%N{darkgreen}! {olive}Agent Smith{brown} has set the next map to {lime} City (SCP: Secret Fortress)", client); //toaster (1)
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "Mr.{green}%N{darkgreen}! {olive}Agent Smith{brown} has set the next map to {lime} Dustbowl (Instagib)", client); //toaster (2)
			}
		}


		default:
		{
			valid = false;
		}
	}

	if(valid)
	{
		//CPrintToChatAll("{darkgreen}Agent Smith{darkgreen}: %s", Text_Lines);
		Agent_Smith_Reply(Text_Lines);
		fl_said_player_weaponline_time[npc.index] = GameTime + GetRandomFloat(17.0, 26.0);
		b_said_player_weaponline[client] = true;
	}
}

static void Smith_Timeslow(float amount = 1.0, float revert = 0.1)
{
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && !IsFakeClient(i))
		{
			SendConVarValue(i, sv_cheats, "1");
			Convars_FixClientsideIssues(i);
		}
	}
	cvarTimeScale.SetFloat(amount);
	CreateTimer(revert, SetTimeBack);
}
