#pragma semicolon 1
#pragma newdecls required

static const char g_IdleAlertedSounds[][] = {
	"vo/taunts/medic_taunts16.mp3",
	"vo/taunts/medic_taunts12.mp3",
	"vo/taunts/medic_taunts10.mp3",
	"vo/taunts/medic_taunts04.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"player/taunt_yeti_standee_demo_swing.wav",
	"player/taunt_yeti_standee_engineer_kick.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/cbar_hitbod1.wav",
	"weapons/cbar_hitbod2.wav",
	"weapons/cbar_hitbod3.wav",
};

static char g_RangedAttackSounds[][] = {
	"weapons/shotgun_shoot.wav",
};

static char g_RangedReloadSound[][] = {
	"weapons/shotgun_reload.wav",
};

void GiantRegeneration_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DefaultMedic_DeathSounds));	   i++) { PrecacheSound(g_DefaultMedic_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_DefaultMedic_HurtSounds));		i++) { PrecacheSound(g_DefaultMedic_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++) { PrecacheSound(g_RangedAttackSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedReloadSound));   i++) { PrecacheSound(g_RangedReloadSound[i]);   }
	PrecacheModel("models/player/medic.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Hijacked Red Pill");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_giant_regeneration");
	strcopy(data.Icon, sizeof(data.Icon), "matrix_medic_regeneration");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Matrix;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return GiantRegeneration(vecPos, vecAng, ally, data);
}

static float fl_Cooldown[MAXENTITIES];
static float fl_Timer[MAXENTITIES];

methodmap GiantRegeneration < CClotBody
{

	property float f_Timer
	{
		public get()							{ return fl_Timer[this.index]; }
		public set(float TempValueForProperty) 	{ fl_Timer[this.index] = TempValueForProperty; }
	}

	property float f_Cooldown
	{
		public get()							{ return fl_Cooldown[this.index]; }
		public set(float TempValueForProperty) 	{ fl_Cooldown[this.index] = TempValueForProperty; }
	}
	property int i_WaveType
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}

	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_DefaultMedic_HurtSounds[GetRandomInt(0, sizeof(g_DefaultMedic_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DefaultMedic_DeathSounds[GetRandomInt(0, sizeof(g_DefaultMedic_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);

	}
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 95);
		
	}
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 95);
		
	}
	
	
	public GiantRegeneration(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		GiantRegeneration npc = view_as<GiantRegeneration>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.3", "5000", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iAttacksTillReload = 3;
		npc.i_WaveType = 0;

		npc.m_fbGunout = false;

		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(GiantRegeneration_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(GiantRegeneration_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(GiantRegeneration_ClotThink);
		npc.f_Timer = 0.0;
		npc.f_Cooldown = 0.0;
		
		char buffers[3][64];
		ExplodeString(data, ";", buffers, sizeof(buffers), sizeof(buffers[]));
		//the very first and 2nd char are SC for scaling
		if(buffers[0][0] == 'w' && buffers[0][1] == 's')
		{
			//remove ws
			ReplaceString(buffers[0], 64, "ws", "");
			int value = StringToInt(buffers[0]);
			npc.i_WaveType = value;
		}
		else
		{	
			npc.i_WaveType = (Waves_GetRoundScale()+1);
		}
		//IDLE
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 225.0;
				
		int skin = 0;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		return npc;
	}
}

public void GiantRegeneration_ClotThink(int iNPC)
{
	GiantRegeneration npc = view_as<GiantRegeneration>(iNPC);
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}

	float gameTime = GetGameTime(npc.index);
	int target2 = npc.m_iTarget;
	float vecTarget2[3]; WorldSpaceCenter(target2, vecTarget2);
	float VecSelfNpc2[3]; WorldSpaceCenter(npc.index, VecSelfNpc2);
	float distance = GetVectorDistance(vecTarget2, VecSelfNpc2, true);
	float ProjLoc[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", ProjLoc);
	float ProjLocBase[3];
	ProjLocBase = ProjLoc;
	ProjLocBase[2] += 5.0;
	ProjLoc[2] += 70.0;

	//Is this even needed, this is only applies if they are close
	if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 0.1) && distance < 7500.0)
	{
		if(npc.i_WaveType < 20 && npc.i_WaveType >= 10)
		{
			vecTarget2[2] += 300.0;
			ApplyStatusEffect(npc.index, npc.index, "Hussar's Warscream", 10.0);
			ApplyStatusEffect(npc.index, npc.index, "Ally Empowerment", 10.0);
			npc.m_flRangedArmor = 0.80;
			npc.m_flMeleeArmor = 0.80;
			npc.f_Cooldown = gameTime + 10.0;//Does not get applied.
		}
		else if(npc.i_WaveType < 30 && npc.i_WaveType >= 20)
		{
			vecTarget2[2] += 300.0;
			ApplyStatusEffect(npc.index, npc.index, "Hussar's Warscream", 10.0);
			ApplyStatusEffect(npc.index, npc.index, "Ally Empowerment", 10.0);
			ApplyStatusEffect(npc.index, npc.index, "Combine Command", 10.0);
			ApplyStatusEffect(npc.index, npc.index, "Defensive Backup", 10.0);
			npc.m_flRangedArmor = 0.65;
			npc.m_flMeleeArmor = 0.65;
			npc.f_Cooldown = gameTime + 10.0;
		}
		else if(npc.i_WaveType < 40 && npc.i_WaveType >= 30)
		{
			vecTarget2[2] += 300.0;
			ApplyStatusEffect(npc.index, npc.index, "Hussar's Warscream", 10.0);
			ApplyStatusEffect(npc.index, npc.index, "Ally Empowerment", 10.0);
			ApplyStatusEffect(npc.index, npc.index, "Combine Command", 10.0);
			ApplyStatusEffect(npc.index, npc.index, "Defensive Backup", 10.0);
			ApplyStatusEffect(npc.index, npc.index, "Oceanic Scream", 10.0);
			ApplyStatusEffect(npc.index, npc.index, "War Cry", 10.0);
			npc.m_flRangedArmor = 0.50;
			npc.m_flMeleeArmor = 0.50;
			npc.f_Cooldown = gameTime + 10.0;
		}
		else if(npc.i_WaveType >= 39)
		{
			vecTarget2[2] += 300.0;
			ApplyStatusEffect(npc.index, npc.index, "Hussar's Warscream", 10.0);
			ApplyStatusEffect(npc.index, npc.index, "Ally Empowerment", 10.0);
			ApplyStatusEffect(npc.index, npc.index, "Combine Command", 10.0);
			ApplyStatusEffect(npc.index, npc.index, "Defensive Backup", 10.0);
			ApplyStatusEffect(npc.index, npc.index, "False Therapy", 10.0);
			npc.m_flRangedArmor = 0.40;
			npc.m_flMeleeArmor = 0.40;
			npc.f_Cooldown = gameTime + 10.0;
		}
	}
	if(npc.f_Cooldown >= gameTime)
	{
		if(npc.f_Timer <= gameTime)
		{
			npc.f_Timer = gameTime + 1.0;
			spawnRing_Vectors(ProjLocBase, 750 * 0.25, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 20, 210, 60, 200, 1, 0.3, 5.0, 8.0, 3);
		}
	}
	
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
	
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
			float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
			if (npc.m_fbGunout == false && npc.m_flReloadDelay < GetGameTime(npc.index))
			{
				if (!npc.m_bmovedelay)
				{
					int iActivity_melee = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
					if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
					npc.m_bmovedelay = true;

				}
				
			}
			
		
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			
			//Predict their pos.
			if(flDistanceToTarget < npc.GetLeadRadius()) {
				
				float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex,_,_, vPredictedPos);
				
			/*	int color[4];
				color[0] = 255;
				color[1] = 255;
				color[2] = 0;
				color[3] = 255;
			
				int xd = PrecacheModel("materials/sprites/laserbeam.vmt");
			
				TE_SetupBeamPoints(vPredictedPos, vecTarget, xd, xd, 0, 0, 0.25, 0.5, 0.5, 5, 5.0, color, 30);
				TE_SendToAllInRange(vecTarget, RangeType_Visibility);*/
				
				npc.SetGoalVector(vPredictedPos);
			} else 
			{
				npc.SetGoalEntity(PrimaryThreatIndex);
			}
			if(npc.m_flNextRangedAttack < GetGameTime(npc.index) && flDistanceToTarget > 62500 && flDistanceToTarget < 122500 && npc.m_flReloadDelay < GetGameTime(npc.index))
			{
				int Enemy_I_See;
			
				Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
				
				if(!IsValidEnemy(npc.index, Enemy_I_See))
				{
					if (!npc.m_bmovedelay)
					{
						int iActivity_melee = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
						if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
						npc.m_bmovedelay = true;
					}
	
					npc.StartPathing();
					
					npc.m_fbGunout = false;
				}
			}
			if((flDistanceToTarget < 62500 || flDistanceToTarget > 122500) && npc.m_flReloadDelay < GetGameTime(npc.index))
			{
				npc.StartPathing();
				
				npc.m_fbGunout = false;
				//Look at target so we hit.
			//	npc.FaceTowards(vecTarget, 500.0);
				
				if((npc.m_flNextMeleeAttack < GetGameTime(npc.index) && flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED) || npc.m_flAttackHappenswillhappen)
				{
					if (!npc.m_flAttackHappenswillhappen)
					{
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS");
						npc.PlayMeleeSound();
						npc.m_flAttackHappens = GetGameTime(npc.index)+0.4;
						npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.54;
						npc.m_flAttackHappenswillhappen = true;
					}
						
					if (npc.m_flAttackHappens < GetGameTime(npc.index) && npc.m_flAttackHappens_bullshit >= GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
					{
						npc.FaceTowards(vecTarget, 20000.0);
						Handle swingTrace;
						if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex))
							{
								
								int target = TR_GetEntityIndex(swingTrace);	
								
								float vecHit[3];
								TR_GetEndPosition(vecHit, swingTrace);
								
								if(target > 0) 
								{
									float damage = 45.0;

									SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);

									Elemental_AddCorruptionDamage(target, npc.index, npc.index ? 15 : 15);
									
									// Hit sound
									npc.PlayMeleeHitSound();
								} 
							}
						delete swingTrace;
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 1.0;
						npc.m_flAttackHappenswillhappen = false;
					}
					else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
					{
						npc.m_flAttackHappenswillhappen = false;
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 1.0;
					}
				}
			}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action GiantRegeneration_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	GiantRegeneration npc = view_as<GiantRegeneration>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void GiantRegeneration_NPCDeath(int entity)
{
	GiantRegeneration npc = view_as<GiantRegeneration>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
}