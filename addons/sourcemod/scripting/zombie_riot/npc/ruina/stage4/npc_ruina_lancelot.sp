#pragma semicolon 1
#pragma newdecls required



static const char g_IdleSounds[][] = {
	"vo/medic_standonthepoint01.mp3",
	"vo/medic_standonthepoint02.mp3",
	"vo/medic_standonthepoint03.mp3",
	"vo/medic_standonthepoint04.mp3",
	"vo/medic_standonthepoint05.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/batsaber_hit_flesh1.wav",
	"weapons/batsaber_hit_flesh2.wav",
	"weapons/batsaber_hit_world1.wav",
	"weapons/batsaber_hit_world2.wav",
};
static const char g_MeleeAttackSounds[][] = {
	"weapons/batsaber_swing1.wav",
	"weapons/batsaber_swing2.wav",
	"weapons/batsaber_swing3.wav",
};
static const char g_TeleportSounds[][] = {
	"misc/halloween/spell_stealth.wav",
};
static const char g_IdleAlertedSounds[][] = {
	")vo/medic_battlecry01.mp3",
	")vo/medic_battlecry02.mp3",
	")vo/medic_battlecry03.mp3",
	")vo/medic_battlecry04.mp3",
};
static const char g_AngerSounds[][] = {
	"vo/medic_cartgoingforwardoffense01.mp3",
	"vo/medic_cartgoingforwardoffense02.mp3",
	"vo/medic_cartgoingforwardoffense03.mp3",
	"vo/medic_cartgoingforwardoffense06.mp3",
	"vo/medic_cartgoingforwardoffense07.mp3",
	"vo/medic_cartgoingforwardoffense08.mp3",
};
static float fl_retreat_timer[MAXENTITIES];
static bool b_leader[MAXENTITIES];
static int i_follow_Id[MAXENTITIES];

#define NPC_PARTICLE_LANCE_BOOM "ambient_mp3/halloween/thunder_04.mp3"
#define NPC_PARTICLE_LANCE_BOOM1 "weapons/air_burster_explode1.wav"
#define NPC_PARTICLE_LANCE_BOOM2 "weapons/air_burster_explode2.wav"
#define NPC_PARTICLE_LANCE_BOOM3 "weapons/air_burster_explode3.wav"

void Lancelot_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Lancelot");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_ruina_lancelot");
	data.Category = Type_Ruina;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	strcopy(data.Icon, sizeof(data.Icon), "lancelot"); 						//leaderboard_class_(insert the name)
	data.IconCustom = true;												//download needed?
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;						//example: MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;, forces these flags.	
	NPC_Add(data);
}
static void ClotPrecache()
{
	Zero(b_leader);
	Zero(fl_retreat_timer);
	Zero(i_follow_Id);
	PrecacheSoundArray(g_DefaultMedic_DeathSounds);
	PrecacheSoundArray(g_DefaultMedic_HurtSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_TeleportSounds);
	PrecacheSoundArray(g_AngerSounds);
	PrecacheModel("models/player/medic.mdl");

	PrecacheSound(NPC_PARTICLE_LANCE_BOOM);
	PrecacheSound(NPC_PARTICLE_LANCE_BOOM1);
	PrecacheSound(NPC_PARTICLE_LANCE_BOOM2);
	PrecacheSound(NPC_PARTICLE_LANCE_BOOM3);
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Lancelot(vecPos, vecAng, team);
}
static float fl_npc_basespeed;
methodmap Lancelot < CClotBody
{
	
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		

	}
	
	public void PlayTeleportSound() {
		EmitSoundToAll(g_TeleportSounds[GetRandomInt(0, sizeof(g_TeleportSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		

	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_DefaultMedic_HurtSounds[GetRandomInt(0, sizeof(g_DefaultMedic_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		
		
	}
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DefaultMedic_DeathSounds[GetRandomInt(0, sizeof(g_DefaultMedic_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		
	}
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		

	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		

	}
	public void PlayAngerSound() {
	
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
	}
	
	public void AdjustWalkCycle()
	{
		if(this.IsOnGround())
		{
			if(this.m_iChanged_WalkCycle == 0)
			{
				this.SetActivity("ACT_MP_RUN_MELEE");
				this.m_iChanged_WalkCycle = 1;
			}
		}
		else
		{
			if(this.m_iChanged_WalkCycle == 1)
			{
				this.SetActivity("ACT_MP_JUMP_FLOAT_MELEE");
				this.m_iChanged_WalkCycle = 0;
			}
		}
	}

	public Lancelot(float vecPos[3], float vecAng[3], int ally)
	{
		Lancelot npc = view_as<Lancelot>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "1250", ally));
		
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);

		npc.m_iChanged_WalkCycle = 1;
		
		
		/*
			
			baggies
			"models/workshop_partner/player/items/all_class/brutal_hair/brutal_hair_%s.mdl"
			puffed
			"models/workshop/player/items/medic/sf14_vampire_makeover/sf14_vampire_makeover.mdl"
			"models/workshop/player/items/medic/dec17_coldfront_carapace/dec17_coldfront_carapace.mdl"



			Behavioral List:
			On melee swing, retreat while preparing for a another swing.	Done.
			Designate a leader from all alive lancers, then follow the leaders target.	Done.
			If a lancer takes immense damage, they fly backwards.


		*/
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(NPC_Death);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(ClotThink);

		fl_npc_basespeed = 330.0;
		npc.m_flSpeed = fl_npc_basespeed;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		static const char Items[][] = {	//temp
			"models/workshop/player/items/all_class/jogon/jogon_medic.mdl",
			"models/workshop_partner/player/items/all_class/brutal_hair/brutal_hair_medic.mdl",
			"models/workshop/player/items/medic/dec23_puffed_practitioner/dec23_puffed_practitioner.mdl",
			"models/workshop/player/items/medic/sf14_vampire_makeover/sf14_vampire_makeover.mdl",
			"models/workshop/player/items/medic/dec17_coldfront_carapace/dec17_coldfront_carapace.mdl",
			WINGS_MODELS_1,
			RUINA_CUSTOM_MODELS_2
		};

		int skin = 1;	//1=blue, 0=red
		SetVariantInt(1);	
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		npc.m_iWearable1 = npc.EquipItem("head", Items[0], _, skin);
		npc.m_iWearable2 = npc.EquipItem("head", Items[1], _, skin);
		npc.m_iWearable3 = npc.EquipItem("head", Items[2], _, skin);
		npc.m_iWearable4 = npc.EquipItem("head", Items[3], _, skin);
		npc.m_iWearable5 = npc.EquipItem("head", Items[4], _, skin);
		npc.m_iWearable6 = npc.EquipItem("head", Items[5]);
		npc.m_iWearable7 = npc.EquipItem("head", Items[6]);

		SetVariantInt(WINGS_LANCELOT);
		AcceptEntityInput(npc.m_iWearable6, "SetBodyGroup");
		SetVariantInt(RUINA_IMPACT_LANCE_4);
		AcceptEntityInput(npc.m_iWearable7, "SetBodyGroup");	


		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");	
		
				
		npc.m_flNextTeleport = GetGameTime(npc.index) + 1.0;
				
		fl_ruina_battery_max[npc.index] = 2500.0;
		fl_ruina_battery[npc.index] = 0.0;
		b_ruina_battery_ability_active[npc.index] = false;
		fl_ruina_battery_timer[npc.index] = 0.0;
		
		npc.Anger = false;

		Ruina_Set_Heirarchy(npc.index, RUINA_MELEE_NPC);	//is a melee npc
		Ruina_Set_Master_Heirarchy(npc.index, RUINA_MELEE_NPC, true, 15, 15);

		Lancelot_Leader(npc);

		return npc;
	}
	
	
}
static void Equalize_HP(Lancelot npc, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{

	int valids[10];
	int i=0;
	for(int targ; targ<i_MaxcountNpcTotal; targ++)
	{
		if(i > 9)
			break;	//somehow more then 10 lancelot's exist, abort.
		int baseboss_index = EntRefToEntIndexFast(i_ObjectsNpcsTotal[targ]);
		if (IsValidEntity(baseboss_index) && !b_NpcHasDied[baseboss_index] && GetTeam(npc.index) == GetTeam(baseboss_index))
		{
			if(baseboss_index == npc.index)
				continue;

			char npc_classname[60];
			NPC_GetPluginById(i_NpcInternalId[baseboss_index], npc_classname, sizeof(npc_classname));
			if(StrEqual(npc_classname, "npc_ruina_lancelot"))
			{
				valids[i] = baseboss_index;
				i++;
			}
		}
	}
	
	if(i<2)
		return;

	damage /= i;

	for(int y=0 ; y < i ; y++)
	{
		SDKHooks_TakeDamage(valids[y], attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, false, (ZR_DAMAGE_NOAPPLYBUFFS_OR_DEBUFFS|ZR_DAMAGE_NPC_REFLECT));
	}
	
}
static bool Lancelot_Leader(Lancelot npc)
{
	for(int targ; targ<i_MaxcountNpcTotal; targ++)
	{
		int baseboss_index = EntRefToEntIndexFast(i_ObjectsNpcsTotal[targ]);
		if (IsValidEntity(baseboss_index) && !b_NpcHasDied[baseboss_index] && GetTeam(npc.index) == GetTeam(baseboss_index))
		{
			if(b_leader[baseboss_index])
			{
				i_follow_Id[npc.index] = EntIndexToEntRef(baseboss_index);
				return true;
			}
		}
	}

	b_leader[npc.index] = true;

	return false;

}

static void ClotThink(int iNPC)
{
	Lancelot npc = view_as<Lancelot>(iNPC);
	
	float GameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > GameTime)
	{
		return;
	}

	npc.m_flNextDelayTime = GameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
			
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = GameTime + 0.1;

	npc.AdjustWalkCycle();

	Ruina_Add_Battery(npc.index, 5.0);

	if(b_leader[npc.index])
	{
		if(npc.m_flGetClosestTargetTime < GameTime)
		{
			npc.m_flGetClosestTargetTime = GameTime + GetRandomRetargetTime();
			npc.m_iTarget = GetClosestTarget(npc.index);
		}
	}
	else
	{
		int follow = EntRefToEntIndex(i_follow_Id[npc.index]);
		if(IsValidEntity(follow))
		{
			if(npc.m_flGetClosestTargetTime < GameTime || !IsValidEnemy(npc.index, npc.m_iTarget))
			{
				Lancelot ally = view_as<Lancelot>(follow);
				npc.m_iTarget = ally.m_iTarget;
				npc.m_flGetClosestTargetTime = GameTime + GetRandomRetargetTime();
				if(!IsValidEnemy(npc.index, npc.m_iTarget))
				{
					npc.m_flGetClosestTargetTime = 0.0;
					return;
				}
			}
			
		}
		else
		{
			if(!Lancelot_Leader(npc))
			{
				npc.m_flGetClosestTargetTime = GameTime + GetRandomRetargetTime();
				npc.m_iTarget = GetClosestTarget(npc.index);
			}
			else
			{
				return;
			}
		}
		
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;

	Ruina_Ai_Override_Core(npc.index, PrimaryThreatIndex, GameTime);	//handles movement, also handles targeting
	
	if(fl_ruina_battery[npc.index]>fl_ruina_battery_max[npc.index])
	{
		if(fl_ruina_battery_timeout[npc.index] < GameTime)
		{
			if(!AtEdictLimit(EDICT_NPC))
			{
				if(!IsValidEntity(npc.m_iWearable8))
				{
					float flPos[3];
					npc.GetAttachment("effect_hand_r", flPos, NULL_VECTOR);
					npc.m_iWearable8 = ParticleEffectAt_Parent(flPos, "raygun_projectile_blue_crit", npc.index, "effect_hand_r", {0.0,0.0,0.0});
				}
				if(!IsValidEntity(npc.m_iWearable9))
				{
					float flPos[3]; // original
					npc.GetAttachment("head", flPos, NULL_VECTOR);
					npc.m_iWearable9 = ParticleEffectAt_Parent(flPos, "unusual_symbols_parent_ice", npc.index, "head", {0.0,0.0,0.0});
				}
			}
		}
	}
	else
	{
		if(IsValidEntity(npc.m_iWearable8))
			RemoveEntity(npc.m_iWearable8);
		if(IsValidEntity(npc.m_iWearable9))
			RemoveEntity(npc.m_iWearable9);
	}
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))	//a final final failsafe
	{
		float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		float Npc_Vec[3]; WorldSpaceCenter(npc.index, Npc_Vec);
		float flDistanceToTarget = GetVectorDistance(vecTarget, Npc_Vec, true);	

		int iPitch = npc.LookupPoseParameter("body_pitch");
		if(iPitch >= 0)
		{

			//Body pitch
			float v[3], ang[3];
			SubtractVectors(Npc_Vec, vecTarget, v); 
			NormalizeVector(v, v);
			GetVectorAngles(v, ang); 
									
			float flPitch = npc.GetPoseParameter(iPitch);
									
			npc.SetPoseParameter(iPitch, ApproachAngle(ang[0], flPitch, 10.0));
			
		}	

		if(fl_ruina_battery[npc.index]>fl_ruina_battery_max[npc.index] && fl_ruina_battery_timeout[npc.index] < GameTime)
			Lancelot_Particle_Accelerator(npc,flDistanceToTarget);
		

		if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*5.0)
		{
			npc.m_bAllowBackWalking = true;
			npc.FaceTowards(vecTarget, 1500.0);
		}
		else
		{
			npc.m_bAllowBackWalking = false;
		}

		Lancelot_Melee(npc, flDistanceToTarget, PrimaryThreatIndex);
	}
	else
	{
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_bAllowBackWalking = false;
	}
	npc.PlayIdleAlertSound();
}

static void Lancelot_Melee(Lancelot npc, float flDistanceToTarget, int PrimaryThreatIndex)
{
	float GameTime = GetGameTime(npc.index);
	float Swing_Speed = (npc.Anger ? 1.0 : 2.0);
	float Swing_Delay = (npc.Anger ? 0.1 : 0.2);

	bool retreat = false;

	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < GameTime)
		{
			npc.m_flAttackHappens = 0.0;

			fl_retreat_timer[npc.index] = GameTime+(Swing_Speed*0.35);

			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(PrimaryThreatIndex, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex))
			{	
				int target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);

				if(IsValidEnemy(npc.index, target))
				{
					SDKHooks_TakeDamage(target, npc.index, npc.index, Modify_Damage(npc, target, 350.0), DMG_CLUB, -1, _, vecHit);

					Ruina_Add_Battery(npc.index, 250.0);

					float Kb = (npc.Anger ? 900.0 : 450.0);

					Custom_Knockback(npc.index, target, Kb, true);
					if(target <= MaxClients)
					{
						TF2_AddCondition(target, TFCond_LostFooting, 0.5);
						TF2_AddCondition(target, TFCond_AirCurrent, 0.5);
					}

					Ruina_Add_Mana_Sickness(npc.index, target, 0.25, 125);
				}
				npc.PlayMeleeHitSound();
				
			}
			delete swingTrace;
		}
	}
	else
	{
		if(fl_retreat_timer[npc.index] > GameTime || (flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*2.0 && npc.m_flNextMeleeAttack > GameTime))
		{
			float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
			float vBackoffPos[3];
			retreat = true;
			BackoffFromOwnPositionAndAwayFromEnemy(npc, PrimaryThreatIndex,_,vBackoffPos);
			npc.SetGoalVector(vBackoffPos, true);
			npc.FaceTowards(vecTarget, 20000.0);
			npc.m_flSpeed =  fl_npc_basespeed*RUINA_BACKWARDS_MOVEMENT_SPEED_PENALTY;
		}
	}

	if(!retreat)
		npc.m_flSpeed = fl_npc_basespeed;

	if(npc.m_flNextMeleeAttack < GameTime && flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*1.25))	//its a lance so bigger range
	{
		int Enemy_I_See;
								
		Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
				
		if(IsValidEnemy(npc.index, Enemy_I_See))
		{
			npc.m_iTarget = Enemy_I_See;
			npc.PlayMeleeSound();
			npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
			npc.m_flAttackHappens = GameTime + Swing_Delay;
			npc.m_flDoingAnimation = GameTime + Swing_Delay;
			npc.m_flNextMeleeAttack = GameTime + Swing_Speed;
		}
	}
}

static void Lancelot_Particle_Accelerator(Lancelot npc, float Dist)
{
	float GameTime = GetGameTime(npc.index);
	if(Dist < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*5.0)
	{
		float Radius = 250.0;
		float Boom_Loc[3];
		if(Particle_Accelerator_Check(npc, Radius, Boom_Loc))
		{
			fl_ruina_battery[npc.index] = 0.0;
			fl_ruina_battery_timeout[npc.index] = GameTime + 10.0;

			int color[4];
			Ruina_Color(color);
			int laser;
			laser = ConnectWithBeam(npc.m_iWearable7, -1, color[0], color[1], color[2], 4.0, 4.0, 5.0, BEAM_COMBINE_BLACK, _, Boom_Loc);
			CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);	
			
			float Ang[3], Origin[3], Velocity[3];
			WorldSpaceCenter(npc.index, Origin);
			MakeVectorFromPoints(Origin, Boom_Loc, Ang);
			GetVectorAngles(Ang, Ang);
			Get_Fake_Forward_Vec(-900.0, Ang, Velocity, Velocity);
			Velocity[2] += 900.0;
			npc.Jump();
			npc.SetVelocity(Velocity);

			Explode_Logic_Custom(1500.0, npc.index, npc.index, -1, Boom_Loc, Radius, _, _, true, _, _, 10.0, Shake_dat_client);

			EmitSoundToAll(NPC_PARTICLE_LANCE_BOOM, npc.index, SNDCHAN_STATIC, 90, _, 0.6);
			EmitSoundToAll(NPC_PARTICLE_LANCE_BOOM, npc.index, SNDCHAN_STATIC, 90, _, 0.6);

			TE_Particle("asplode_hoodoo", Boom_Loc, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);

			switch(GetRandomInt(1,3))
			{
				case 1:
					EmitSoundToAll(NPC_PARTICLE_LANCE_BOOM1, npc.index, SNDCHAN_STATIC, 90, _, 1.0);
				case 2:
					EmitSoundToAll(NPC_PARTICLE_LANCE_BOOM2, npc.index, SNDCHAN_STATIC, 90, _, 1.0);
				case 3:
					EmitSoundToAll(NPC_PARTICLE_LANCE_BOOM3, npc.index, SNDCHAN_STATIC, 90, _, 1.0);
			}
		}
		else
		{
			fl_ruina_battery_timeout[npc.index] = GameTime + 1.0;
		}
	}
}
static void Get_Fake_Forward_Vec(float Range, float vecAngles[3], float Vec_Target[3], float Pos[3])
{
	float Direction[3];
	
	GetAngleVectors(vecAngles, Direction, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(Direction, Range);
	AddVectors(Pos, Direction, Vec_Target);
}
static void Shake_dat_client(int entity, int victim, float damage, int weapon)
{
	if(victim <= MaxClients)
		Client_Shake(victim, 0, 50.0, 30.0, 1.25);
}
static int i_targets_inrange;
static bool Particle_Accelerator_Check(Lancelot npc, float range, float EndLoc[3])
{
	Ruina_Laser_Logic Laser;

	Laser.client = npc.index;
	Laser.DoForwardTrace_Basic(NORMAL_ENEMY_MELEE_RANGE_FLOAT);
	i_targets_inrange = 0;
	Explode_Logic_Custom(0.0, npc.index, npc.index, -1, Laser.End_Point, range, _, _, true, 15, false, _, CountTargets);

	EndLoc = Laser.End_Point;
	//CPrintToChatAll("Targets: %i", i_targets_inrange);
	if(i_targets_inrange > 2)
	{
		return true;
	}
	return false;
}
static void CountTargets(int entity, int victim, float damage, int weapon)
{
	i_targets_inrange++;
}

static float Modify_Damage(Lancelot npc, int Target, float damage)
{
	if(ShouldNpcDealBonusDamage(Target))
		damage*=10.0;

	if(NpcStats_IsEnemySilenced(npc.index))
		damage *=0.5;

	if(npc.Anger)
		damage *=1.3;

	if(Target > MaxClients)
		return damage;

	int weapon = GetEntPropEnt(Target, Prop_Send, "m_hActiveWeapon");
						
	if(!IsValidEntity(weapon))
		return damage;

	char classname[32];
	GetEntityClassname(weapon, classname, 32);

	int weapon_slot = TF2_GetClassnameSlot(classname, weapon);
										
	if(i_OverrideWeaponSlot[weapon] != -1)
	{
		weapon_slot = i_OverrideWeaponSlot[weapon];
	}
	if(weapon_slot != 2 || i_IsWandWeapon[weapon])
		damage *= 1.7;

	return damage;
}
static Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{

	Lancelot npc = view_as<Lancelot>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	Ruina_NPC_OnTakeDamage_Override(npc.index, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

	if(!(i_HexCustomDamageTypes[victim] & ZR_DAMAGE_NPC_REFLECT))	//do not reflect a reflection!
	{
		Equalize_HP(npc, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition);
		//CPrintToChatAll("reflect");
	}
		

	if(!npc.Anger && (ReturnEntityMaxHealth(npc.index)/2) >= GetEntProp(npc.index, Prop_Data, "m_iHealth")) //Anger after half hp
	{
		npc.Anger = true; //	>:(
		npc.PlayAngerSound();


		if(npc.m_bThisNpcIsABoss)
		{
			npc.DispatchParticleEffect(npc.index, "hightower_explosion", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("eyes"), PATTACH_POINT_FOLLOW, true);
		}
	}
		
	//Ruina_Add_Battery(npc.index, damage);	//turn damage taken into energy
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void NPC_Death(int entity)
{
	Lancelot npc = view_as<Lancelot>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}

	b_leader[npc.index] = false;
	
	Ruina_NPCDeath_Override(entity);
		
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
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
	if(IsValidEntity(npc.m_iWearable9))
		RemoveEntity(npc.m_iWearable9);
}