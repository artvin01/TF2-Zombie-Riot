#pragma semicolon 1
#pragma newdecls required

#define UMBRAL_AUTOMATON_STEPRANGE 190.0
static const char g_DeathSounds[][] = {
	"ui/killsound_squasher.wav",
};

static const char g_HurtSounds[][] = {
	"physics/concrete/rock_impact_hard1.wav",
	"physics/concrete/rock_impact_hard2.wav",
	"physics/concrete/rock_impact_hard3.wav",
	"physics/concrete/rock_impact_hard4.wav",
	"physics/concrete/rock_impact_hard5.wav",
	"physics/concrete/rock_impact_hard6.wav",
};


static const char g_MeleeAttackSounds[][] = {
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/halloween_boss/knight_axe_miss.wav",
};


static int NPCId;

int Umbral_Automaton_ID()
{
	return NPCId;
}

void Umbral_Automaton_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	PrecacheModel("models/player/heavy.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Umbral Automaton");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_umbral_automaton");
	strcopy(data.Icon, sizeof(data.Icon), "heavy");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Mutation;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);
}



static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Umbral_Automaton(vecPos, vecAng, team);
}
methodmap Umbral_Automaton < CClotBody
{
	
	public void PlayHurtSound() 
	{
		int RandInt = GetRandomInt(0, sizeof(g_HurtSounds) - 1);
		EmitSoundToAll(g_HurtSounds[RandInt], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, 1.0, 80);
		EmitSoundToAll(g_HurtSounds[RandInt], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, 1.0, 80);
		EmitSoundToAll(g_HurtSounds[RandInt], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, 1.0, 80);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 50);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 50);
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 50);
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 50);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 60);
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 60);
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 60);
	}
	property float m_flEnemyDead
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flEnemyStandStill
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	
	public Umbral_Automaton(float vecPos[3], float vecAng[3], int ally)
	{
		Umbral_Automaton npc = view_as<Umbral_Automaton>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "4.0", "22500", ally,.isGiant = true, .CustomThreeDimensions = {55.0, 55.0, 300.0}));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("ACT_COLOSUS_WALK");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		SetVariantInt(3);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		npc.m_iBleedType = BLEEDTYPE_UMBRAL;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;

		func_NPCDeath[npc.index] = view_as<Function>(Umbral_Automaton_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Umbral_Automaton_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Umbral_Automaton_ClotThink);
		func_NPCAnimEvent[npc.index] = view_as<Function>(Umbral_Automaton_AnimEvent);
		f_NpcTurnPenalty[npc.index] = 0.35;
		npc.StartPathing();

		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true;
		Is_a_Medic[npc.index] = true;
		npc.m_bStaticNPC = true;
		AddNpcToAliveList(npc.index, 1);
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_bDissapearOnDeath = true;
		//dont allow self making
		
		i_ExplosiveProjectileHexArray[npc.index] |= EP_DEALS_CLUB_DAMAGE;
		npc.m_flSpeed = 120.0;

		SetEntityRenderColor(npc.index, 105, 82, 117, 255);

		npc.m_iWearable1 = npc.EquipItem("partyhat", "models/player/items/soldier/soldier_spartan.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		SetEntityRenderColor(npc.m_iWearable1, 105, 82, 117, 255);

		npc.m_iWearable2 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_claymore/c_claymore.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		SetEntityRenderColor(npc.m_iWearable2, 105, 82, 117, 255);
		
		if(ally != TFTeam_Red && Rogue_Mode())
		{
			if(Rogue_GetUmbralLevel() == 0)
			{
				//when friendly and they still spawn as enemies, nerf.
				fl_Extra_Damage[npc.index] *= 0.5;
				fl_Extra_Speed[npc.index] *= 0.5;
			}
			else if(Rogue_GetUmbralLevel() == 4)
			{
				
				//if completly hated.
				//no need to adjust HP scaling, so it can be done here.
				fl_Extra_Damage[npc.index] *= 1.5;
				fl_Extra_Speed[npc.index] *= 1.1;
				fl_Extra_MeleeArmor[npc.index] *= 0.85;
				fl_Extra_RangedArmor[npc.index] *= 0.85;
			}
		}
		
		return npc;
	}
}

stock bool Umbral_AutomatonHealAlly(int entity, int victim, float &healingammount)
{
	if(i_NpcInternalId[entity] == i_NpcInternalId[victim])
		return true;

	ApplyStatusEffect(entity, victim, "Very Defensive Backup", 2.0);
	ApplyStatusEffect(entity, victim, "War Cry", 2.0);
	return false;
}
public void Umbral_Automaton_ClotThink(int iNPC)
{
	Umbral_Automaton npc = view_as<Umbral_Automaton>(iNPC);
	if(npc.m_flEnemyDead)
	{
		if(npc.m_flNextThinkTime > GetGameTime(npc.index))
		{
			return;
		}
		npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.3;
		float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
		float Range = 400.0;
		spawnRing_Vectors(pos, Range * 2.0, 0.0, 0.0, 15.0, "materials/sprites/laserbeam.vmt", 255, 255, 255, 200, 1, /*duration*/ 0.35, 10.0, 1.0, 1);	
		ExpidonsaGroupHeal(npc.index, Range, 99, 0.0, 1.0, false, Umbral_AutomatonHealAlly);
		return;
	}
	float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
	Explode_Logic_Custom(0.0, 0, npc.index, -1, pos ,UMBRAL_AUTOMATON_STEPRANGE * 1.5, 1.0, _, true, .FunctionToCallBeforeHit = UmbralAutomaton_VisionBlurr);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_flEnemyStandStill)
	{
		npc.m_flSpeed = 0.0;
		if(npc.m_flEnemyStandStill < GetGameTime(npc.index))
		{
			npc.StartPathing();
			npc.m_flEnemyStandStill = 0.0;
			npc.m_flSpeed = 120.0;
		}
	}
	if(npc.m_blPlayHurtAnimation)
	{
	//	npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;
	
	Explode_Logic_Custom(0.0, 0, npc.index, -1, pos ,UMBRAL_AUTOMATON_STEPRANGE, 1.0, _, true, .FunctionToCallBeforeHit = UmbralAutomaton_Terrified);
	spawnRing_Vectors(pos, UMBRAL_AUTOMATON_STEPRANGE * 2.0, 0.0, 0.0, 15.0, "materials/sprites/laserbeam.vmt", 200, 0, 0, 200, 1, /*duration*/ 0.11, 15.0, 3.0, 1);	
	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3];
			PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}
		Umbral_AutomatonSelfDefense(npc,GetGameTime(npc.index), flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
}

public Action Umbral_Automaton_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Umbral_Automaton npc = view_as<Umbral_Automaton>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + (DEFAULT_HURTDELAY * 0.5);
		npc.m_blPlayHurtAnimation = true;
	}
	if(RoundToCeil(damage) >= GetEntProp(npc.index, Prop_Data, "m_iHealth"))
	{
		npc.m_iBleedType = 0;
		npc.m_flEnemyDead = 1.0;
		npc.SetPlaybackRate(0.0);
		SetEntProp(npc.index, Prop_Data, "m_iHealth", 1);
		SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", 1);
		damage = 0.0;
		return Plugin_Changed;
	}
	
	return Plugin_Changed;
}

public void Umbral_Automaton_NPCDeath(int entity)
{
	Umbral_Automaton npc = view_as<Umbral_Automaton>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
		
	TE_Particle("pyro_blast", WorldSpaceVec, NULL_VECTOR, 		{90.0,0.0,0.0}, -1, _, _, _, _, _, _, _, _, _, 0.0);
	TE_Particle("pyro_blast_warp", WorldSpaceVec, NULL_VECTOR, 	{90.0,0.0,0.0}, -1, _, _, _, _, _, _, _, _, _, 0.0);
	TE_Particle("pyro_blast_flash", WorldSpaceVec, NULL_VECTOR, {90.0,0.0,0.0}, -1, _, _, _, _, _, _, _, _, _, 0.0);

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

}

void Umbral_AutomatonSelfDefense(Umbral_Automaton npc, float gameTime, float distance)
{
	if(npc.m_flAttackHappens)
	{
		
		float vecSwingStart[3];

		GetAbsOrigin(npc.index, vecSwingStart);
		vecSwingStart[2] += 5.0;
		float vecForward[3], vecRight[3], vecTarget[3];
		GetEntPropVector(npc.index, Prop_Data, "m_angRotation", vecForward); 	
		GetAngleVectors(vecForward, vecForward, vecRight, vecTarget);
			
		float vecSwingEnd[3];
		vecSwingEnd[0] = vecSwingStart[0] + vecForward[0] * 150.0;
		vecSwingEnd[1] = vecSwingStart[1] + vecForward[1] * 150.0;
		vecSwingEnd[2] = vecSwingStart[2] + vecForward[2] * 150.0;
		float Range = 250.0;
		spawnRing_Vectors(vecSwingEnd, Range * 2.0, 0.0, 0.0, 15.0, "materials/sprites/combineball_trail_black_1.vmt", 255, 255, 255, 200, 1, /*duration*/ 0.11, 20.0, 1.0, 1);	
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			TE_Particle("Explosion_ShockWave_01", vecSwingEnd, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
			TE_Particle("grenade_smoke_cycle", vecSwingEnd, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
			TE_Particle("hammer_bell_ring_shockwave", vecSwingEnd, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
			npc.PlayMeleeHitSound();
			CreateEarthquake(vecSwingEnd, 2.0, Range * 2.2, 35.0, 255.0);
			Explode_Logic_Custom(15000.0, 0, npc.index, -1, vecSwingEnd ,Range, 1.0, _, true);
		}
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 5.0))
		{
			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.StopPathing();
				npc.m_flSpeed = 0.0;
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_MELEE_ATTACK_SWING_GESTURE",_,_,_,0.25);
				npc.m_flAttackHappens = gameTime + 1.5;
				npc.m_flDoingAnimation = gameTime + 1.5;
				npc.m_flNextMeleeAttack = gameTime + 10.5;
				npc.m_flEnemyStandStill = gameTime + 3.5;
				float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
				npc.FaceTowards(VecEnemy, 15000.0);
			}
		}
	}
}

void Umbral_Automaton_AnimEvent(int entity, int event)
{
	if(IsWalkEvent(event))
	{	
		Umbral_Automaton npc = view_as<Umbral_Automaton>(entity);
		float pos[3]; GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
		TE_Particle("Explosion_ShockWave_01", pos, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
		TE_Particle("grenade_smoke_cycle", pos, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
		npc.PlayStepSound(g_TankStepSound[GetRandomInt(0, sizeof(g_TankStepSound) - 1)], 1.0, STEPSOUND_GIANT, true);
		npc.PlayStepSound(g_TankStepSound[GetRandomInt(0, sizeof(g_TankStepSound) - 1)], 1.0, STEPSOUND_GIANT, true);
		npc.PlayStepSound(g_TankStepSound[GetRandomInt(0, sizeof(g_TankStepSound) - 1)], 1.0, STEPSOUND_GIANT, true);
		npc.PlayStepSound(g_TankStepSound[GetRandomInt(0, sizeof(g_TankStepSound) - 1)], 1.0, STEPSOUND_GIANT, true);
		CreateEarthquake(pos, 1.0, UMBRAL_AUTOMATON_STEPRANGE * 2.2, 16.0, 255.0);
		Explode_Logic_Custom(1500.0, 0, npc.index, -1, pos ,UMBRAL_AUTOMATON_STEPRANGE, 1.0, _, true, .FunctionToCallOnHit = UmbralAutomaton_KnockbackDo);
	}
}
/*

stock void Custom_Knockback(int attacker,
 int enemy,
  float knockback,
   bool ignore_attribute = false,
	bool override = false,
	 bool work_on_entity = false,
	 float PullDuration = 0.0,
	 bool RecieveInfo = false,
	 float RecievePullInfo[3] = {0.0,0.0,0.0},
	 float OverrideLookAng[3] ={0.0,0.0,0.0})
*/
void UmbralAutomaton_KnockbackDo(int entity, int victim, float damage, int weapon)
{
	float VecMe[3]; WorldSpaceCenter(entity, VecMe);
	float VecEnemy[3]; WorldSpaceCenter(victim, VecEnemy);

	float AngleVec[3];
	MakeVectorFromPoints(VecMe, VecEnemy, AngleVec);
	GetVectorAngles(AngleVec, AngleVec);

	AngleVec[0] = -45.0;
	Custom_Knockback(entity, victim, 500.0, true, true, true, .OverrideLookAng = AngleVec);
}
float UmbralAutomaton_VisionBlurr(int attacker, int victim, float &damage, int weapon)
{
	if(victim > MaxClients)
		return 0.0;
	
	float vecTarget[3]; GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", vecTarget);

	float VecSelfNpc[3]; GetEntPropVector(attacker, Prop_Data, "m_vecAbsOrigin", VecSelfNpc);
	float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc);
	flDistanceToTarget = (flDistanceToTarget / UMBRAL_AUTOMATON_STEPRANGE * 2.0);
	flDistanceToTarget *= 1.3;
	if(flDistanceToTarget <= 0.0)
		flDistanceToTarget = 0.0;
	if(flDistanceToTarget >= 1.0)
		flDistanceToTarget = 1.0;
	flDistanceToTarget *= 200.0;
	UTIL_ScreenFade(victim, 600, 0, 0x0001, 0, 0, 0, RoundToNearest(flDistanceToTarget));
	return 0.0;
}
float UmbralAutomaton_Terrified(int attacker, int victim, float &damage, int weapon)
{
	ApplyStatusEffect(attacker, victim, "Terrified", 1.0);

	return 0.0;
}