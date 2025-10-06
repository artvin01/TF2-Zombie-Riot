#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/engineer_paincrticialdeath01.mp3",
	"vo/engineer_paincrticialdeath02.mp3",
	"vo/engineer_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/engineer_painsharp01.mp3",
	"vo/engineer_painsharp02.mp3",
	"vo/engineer_painsharp03.mp3",
	"vo/engineer_painsharp04.mp3",
	"vo/engineer_painsharp05.mp3",
	"vo/engineer_painsharp06.mp3",
	"vo/engineer_painsharp07.mp3",
	"vo/engineer_painsharp08.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/taunts/engineer_taunts01.mp3",
	"vo/taunts/engineer_taunts03.mp3",
	"vo/taunts/engineer_taunts06.mp3",
	"vo/taunts/engineer_taunts09.mp3",
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
	"weapons/revolver_shoot.wav",
};

static char g_RangedReloadSound[][] = {
	"weapons/revolver_worldreload.wav",
};

void GiantReflector_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Hijacked Red Pill");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_giant_reflector");
	strcopy(data.Icon, sizeof(data.Icon), "matrix_engineer_reflect");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Matrix;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++) { PrecacheSound(g_RangedAttackSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedReloadSound));   i++) { PrecacheSound(g_RangedReloadSound[i]);   }
	
	Matrix_Shared_CorruptionPrecache();
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return GiantReflector(vecPos, vecAng, ally);
}

methodmap GiantReflector < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
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
	
	public GiantReflector(float vecPos[3], float vecAng[3], int ally)
	{
		GiantReflector npc = view_as<GiantReflector>(CClotBody(vecPos, vecAng, "models/player/engineer.mdl", "1.3", "5000", ally));

		i_NpcWeight[npc.index] = 3;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iAttacksTillReload = 3;

		npc.m_fbGunout = false;

		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(GiantReflector_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(GiantReflector_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(GiantReflector_ClotThink);
		
		
		//IDLE
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 225.0;
				
		int skin = 0;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		return npc;
	}
}

public void GiantReflector_ClotThink(int iNPC)
{
	GiantReflector npc = view_as<GiantReflector>(iNPC);
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
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
	if(npc.m_flDead_Ringer_Invis < GetGameTime(npc.index) && npc.m_flDead_Ringer_Invis_bool)
	{
		GiantReflector_Reflect_Disable(npc);
	}
	
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
			
			npc.SetGoalVector(vPredictedPos);
		}
		else
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
					npc.m_flAttackHappens_bullshit = GetGameTime(npc.index) + 3.00;
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

							Elemental_AddCorruptionDamage(target, npc.index, npc.index ? 25 : 25);
							
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

public Action GiantReflector_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker <= 0)
	return Plugin_Continue;

	GiantReflector npc = view_as<GiantReflector>(victim);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flDead_Ringer_Invis >= gameTime)
    {
		if(fl_MatrixReflect[attacker] <= GetGameTime())
		{
			fl_MatrixReflect[attacker] = GetGameTime() + 1.0;
			float parrydamage = GetRandomFloat(50.0, 60.0);
			parrydamage *= npc.m_flWaveScale;
			//damage *= 0.1;//how much the npc takes

			Elemental_AddCorruptionDamage(attacker, npc.index, npc.index ? 25 : 25);
			static float Entity_Position[3];
			WorldSpaceCenter(attacker, Entity_Position );
			DataPack pack = new DataPack();
			pack.WriteCell(EntIndexToEntRef(attacker));
			pack.WriteCell(EntIndexToEntRef(npc.index));
			pack.WriteCell(EntIndexToEntRef(npc.index));
			pack.WriteFloat(parrydamage);
			pack.WriteCell(DMG_CLUB);
			pack.WriteCell(-1.0);
			pack.WriteFloat(0.0);
			pack.WriteFloat(0.0);
			pack.WriteFloat(1.0);
			pack.WriteFloat(Entity_Position[0]);
			pack.WriteFloat(Entity_Position[1]);
			pack.WriteFloat(Entity_Position[2]);
			pack.WriteCell(ZR_DAMAGE_REFLECT_LOGIC);
			RequestFrame(CauseDamageLaterSDKHooks_Takedamage, pack);
		}
    }
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}

	if(npc.m_flDead_Ringer < GetGameTime(npc.index) && !npc.m_flDead_Ringer_Invis_bool)
	{
		GiantReflector_Reflect_Enable(npc);
	}
	
	return Plugin_Changed;
}
//did this for you so it's simpler to learn
static void GiantReflector_Reflect_Enable(GiantReflector npc)
{
	float wave = float(Waves_GetRoundScale()+1);
	wave *= 0.06667;
	npc.m_flWaveScale = wave;

	npc.m_flDead_Ringer_Invis = GetGameTime(npc.index) + 3.0 * npc.m_flWaveScale;
	npc.m_flDead_Ringer = GetGameTime(npc.index) + 10.0;
	SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
	SetEntityRenderColor(npc.index, 0, 255, 0, 125);
	npc.m_flDead_Ringer_Invis_bool = true;
	float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
	vecMe[2] += 90.0;
	npc.m_iWearable5 = ParticleEffectAt(vecMe, "powerup_icon_reflect", -1.0);
	npc.m_flMeleeArmor = 0.1;
	npc.m_flRangedArmor = 0.1;
	if(IsValidEntity(npc.m_iWearable5))
		SetParent(npc.index, npc.m_iWearable5);
}

static void GiantReflector_Reflect_Disable(GiantReflector npc)
{
	AcceptEntityInput(npc.m_iWearable5, "Disable");
	SetEntityRenderMode(npc.index, RENDER_NORMAL);
	SetEntityRenderColor(npc.index, 255, 255, 255, 255);
	npc.m_flDead_Ringer_Invis_bool = false;
	npc.m_flMeleeArmor = 1.0;
	npc.m_flRangedArmor = 1.0;
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
}

static void GiantReflector_NPCDeath(int entity)
{
	GiantReflector npc = view_as<GiantReflector>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
}