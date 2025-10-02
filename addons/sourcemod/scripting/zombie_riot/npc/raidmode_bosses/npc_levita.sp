#pragma semicolon 1
#pragma newdecls required



static const char g_IdleSound[][] = {
	"vo/medic_standonthepoint01.mp3",
	"vo/medic_standonthepoint02.mp3",
	"vo/medic_standonthepoint03.mp3",
	"vo/medic_standonthepoint04.mp3",
	"vo/medic_standonthepoint05.mp3"
};

static const char g_IdleAlertedSounds[][] = {
	"vo/medic_battlecry01.mp3",
	"vo/medic_battlecry02.mp3",
	"vo/medic_battlecry03.mp3",
	"vo/medic_battlecry04.mp3",
	"vo/medic_battlecry05.mp3",
	"vo/medic_item_secop_domination01.mp3",
	"vo/medic_item_secop_idle03.mp3",
	"vo/medic_item_secop_idle01.mp3",
	"vo/medic_item_secop_idle02.mp3"
};

static const char g_MeleeHitSounds[][] = {
	"weapons/batsaber_hit_flesh1.wav",
	"weapons/batsaber_hit_flesh2.wav",
	"weapons/batsaber_hit_world1.wav",
	"weapons/batsaber_hit_world2.wav"
};
static const char g_MeleeAttackSounds[][] = {
	"weapons/batsaber_swing1.wav",
	"weapons/batsaber_swing2.wav",
	"weapons/batsaber_swing3.wav"
};

static const char g_RangeAttackSound[][] = {
	"ui/hitsound_vortex1.wav",
	"ui/hitsound_vortex2.wav",
	"ui/hitsound_vortex3.wav",
	"ui/hitsound_vortex4.wav",
	"ui/hitsound_vortex5.wav"
};
static char g_TeleportSounds[][] = {
	"weapons/bison_main_shot.wav"
};

static const char g_RangedAttackSoundsSecondary[][] = {
	"weapons/physcannon/energy_sing_explosion2.wav",
};

#if !defined ZR

#define RUINA_BACKWARDS_MOVEMENT_SPEED_PENALTY		0.7		//for npc's that walk backwards, how much slower should be walk
#define RUINA_FACETOWARDS_BASE_TURNSPEED			475.0	//for npc's that constantly face towards a target, how fast can they turn
#define RUINA_LASER_LOOP_SOUND						"zombiesurvival/seaborn/loop_laser.mp3"

#endif

static float fl_npc_basespeed;

/*
	TODO:

	Make Levita Crystals.
	Make Crystal manipulation.

	and all the other stuff

*/

public void Levita_OnMapStart_NPC()
{	
#if !defined ZR
	PrecacheSoundCustom(RUINA_LASER_LOOP_SOUND);
#endif
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Levita");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_levita");
	data.Func = ClotSummon;
	//data.Precache = ClotPrecache;
	ClotPrecache();
	NPC_Add(data);
}
static void ClotPrecache()
{
	PrecacheModel("models/player/medic.mdl");
	PrecacheSoundArray(g_DefaultMedic_DeathSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_IdleSound);
	PrecacheSoundArray(g_HurtSound);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_RangedAttackSoundsSecondary);
	PrecacheSoundArray(g_TeleportSounds);
	PrecacheSoundArray(g_RangeAttackSound);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return Levita(client, vecPos, vecAng, ally, data);
}
#define LEVITA_MAX_CRYSTALS 6
static int i_crstal_ID[MAXENTITIES][LEVITA_MAX_CRYSTALS];

methodmap Levita < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;

		EmitSoundToAll(g_IdleSound[GetRandomInt(0, sizeof(g_IdleSound) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);

		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	public void PlayTeleportSound() {
		EmitSoundToAll(g_TeleportSounds[GetRandomInt(0, sizeof(g_TeleportSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME);
		

	}
	
	public void PlayHurtSound()
	{
		
		EmitSoundToAll(g_DefaultMedic_HurtSounds[GetRandomInt(0, sizeof(g_DefaultMedic_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DefaultMedic_DeathSounds[GetRandomInt(0, sizeof(g_DefaultMedic_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);
	}
	public void PlayKilledEnemySound() 
	{
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(5.0, 10.0);
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);
	}
	public void PlayRangedSound()
 	{
		EmitSoundToAll(g_RangeAttackSound[GetRandomInt(0, sizeof(g_RangeAttackSound) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);	
	}
	public void PlayRangedAttackSecondarySound() 
	{
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}

	property float m_flTimeUntillMark
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flNemalSlicerCD
	{
		public get()							{ return fl_RangedSpecialDelay[this.index]; }
		public set(float TempValueForProperty) 	{ fl_RangedSpecialDelay[this.index] = TempValueForProperty; }
	}
	property float m_flNemalSlicerHappening
	{
		public get()							{ return fl_AttackHappens_2[this.index]; }
		public set(float TempValueForProperty) 	{ fl_AttackHappens_2[this.index] = TempValueForProperty; }
	}
	property float m_flNemalSniperShotsHappening
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flNemalSniperShotsHappeningCD
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flNemalSniperShotsLaserThrottle
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	property float m_flNemalAirbornAttack
	{
		public get()							{ return fl_AbilityOrAttack[this.index][4]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][4] = TempValueForProperty; }
	}

	property float m_flNemalPlaceAirMines
	{
		public get()							{ return fl_AbilityOrAttack[this.index][5]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][5] = TempValueForProperty; }
	}
	property float m_flNemalPlaceAirMinesCD
	{
		public get()							{ return fl_AbilityOrAttack[this.index][6]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][6] = TempValueForProperty; }
	}
	property float m_flNemalSuperRes
	{
		public get()							{ return fl_AbilityOrAttack[this.index][7]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][7] = TempValueForProperty; }
	}	
	property float m_flNemalSummonSilvesterCD
	{
		public get()							{ return fl_AbilityOrAttack[this.index][8]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][8] = TempValueForProperty; }
	}
	property float m_flNemalSummonSilvesterHappening
	{
		public get()							{ return fl_AbilityOrAttack[this.index][9]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][9] = TempValueForProperty; }
	}

	public void AdjustWalkCycle()
	{
		if(this.IsOnGround())
		{
			if(this.m_iChanged_WalkCycle == 0)
			{
				this.m_bisWalking = true;
				this.SetActivity("ACT_MP_RUN_MELEE");
				this.m_iChanged_WalkCycle = 1;
			}
		}
		else
		{
			if(this.m_iChanged_WalkCycle == 1)
			{
				this.m_bisWalking = true;
				this.SetActivity("ACT_MP_JUMP_FLOAT_MELEE");
				this.m_iChanged_WalkCycle = 0;
			}
		}
	}
	public int IsCrystalValid(int ID)
	{
		int Crystal = EntRefToEntIndex(i_crstal_ID[this.index][ID]);
		if(!IsValidEntity(Crystal))
			return false;

		return Crystal;
	}
	public int CrystalLoopsAmt()
	{
		int amt = LEVITA_MAX_CRYSTALS;

		for(int i=0 ; i < LEVITA_MAX_CRYSTALS ; i++)
		{
			if(!this.IsCrystalValid(i))
				amt--;
		}

		return amt;
	}
	public void Manipulate_Crystals()
	{
		int Loop_For = LEVITA_MAX_CRYSTALS;

		float Center_Loc[3];
		
		float 	Distance = 150.0,
				Height = 15.0;

		for(int i=0 ; i < Loop_For ; i++)
		{
			int Crystal = this.IsCrystalValid(i);
			if(!Crystal)
				continue;

			

		}
	}
	public void Crystal_Maintenance()
	{
		this.Manipulate_Crystals();
	}
	public int Create_Crystal(float Loc[3], int ID)
	{
		int spawn_index = NPC_CreateByName("npc_levita_crystal", this.index, Loc, {0.0,0.0,0.0}, GetTeam(this.index));
		float Health = 10000.0;
		if(spawn_index > MaxClients)
		{
#if defined RPG
			Level[spawn_index] = Level[this.index];
			i_OwnerToGoTo[spawn_index] = EntIndexToEntRef(this.index);
#endif
			NpcStats_CopyStats(this.index, spawn_index);
			i_crstal_ID[this.index][ID] = EntIndexToEntRef(spawn_index);
			SetEntProp(spawn_index, Prop_Data, "m_iHealth", RoundToCeil(Health));
			SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", RoundToCeil(Health));
		}

		return spawn_index;
	}
	public Levita(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Levita npc = view_as<Levita>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "1000", ally, false));

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		//KillFeed_SetKillIcon(npc.index, "warrior_spirit");

		int iActivity = npc.LookupActivity("ACT_MP_STAND_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);

		npc.m_bisWalking = false;

		fl_npc_basespeed = 330.0;

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_bDissapearOnDeath = false;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		npc.g_TimesSummoned = 0;
		npc.Anger = false;

		f3_SpawnPosition[npc.index][0] = vecPos[0];
		f3_SpawnPosition[npc.index][1] = vecPos[1];
		f3_SpawnPosition[npc.index][2] = vecPos[2];
		RemoveAllDamageAddition();

		npc.m_iAttacksTillMegahit = 0;
		
		func_NPCDeath[npc.index] = NPC_Death;
		func_NPCOnTakeDamage[npc.index] = OnTakeDamage;
		func_NPCThink[npc.index] = NPC_ClotThink;

		//temp.
		int skin = 1;	//1=blue, 0=red
		SetVariantInt(1);	
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		npc.m_iWearable1 = npc.EquipItem("head", RUINA_CUSTOM_MODELS_3);
		npc.m_iWearable2 = npc.EquipItem("head", RUINA_CUSTOM_MODELS_3);
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/dec23_puffed_practitioner/dec23_puffed_practitioner.mdl", _, skin);
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/all_class/witchhat/witchhat_medic.mdl", _, skin);
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/all_class/jogon/jogon_medic.mdl", _, skin);
		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/medic/medic_wintercoat_s02/medic_wintercoat_s02.mdl", _, skin);
		npc.m_iWearable7 = npc.EquipItem("head", "models/workshop_partner/player/items/all_class/tomb_readers/tomb_readers_medic.mdl", _, skin);
		float flPos[3], flAng[3];
		npc.GetAttachment("head", flPos, flAng);	
		npc.m_iWearable8 = ParticleEffectAt_Parent(flPos, "unusual_invasion_boogaloop_2", npc.index, "head", {0.0,0.0,0.0});

		SetVariantInt(RUINA_UNUSED_2);
		AcceptEntityInput(npc.m_iWearable2, "SetBodyGroup");
		SetVariantInt(RUINA_TWIRL_CREST_4);
		AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");

#if !defined RPG
		Ruina_Set_Heirarchy(npc.index, RUINA_GLOBAL_NPC);
		Ruina_Set_Master_Heirarchy(npc.index, RUINA_GLOBAL_NPC, true, 999, 999);	
#endif
	
		
		npc.StopPathing();
			
		
		return npc;
	}
	
}

//TODO 
//Rewrite
public void NPC_ClotThink(int iNPC)
{
	Levita npc = view_as<Levita>(iNPC);

	float GameTime = GetGameTime(npc.index);

	//some npcs deservere full update time!
	if(npc.m_flNextDelayTime > GameTime)
	{
		return;
	}

	npc.m_flNextDelayTime = GameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	

	if(npc.m_blPlayHurtAnimation && npc.m_flDoingAnimation < GameTime) //Dont play dodge anim if we are in an animation.
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST");
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}

	if(npc.m_flNextThinkTime > GameTime)
	{
		return;
	}
	if(!npc.Anger)
	{
		npc.Anger = true;

	}
	npc.m_flNextThinkTime = GameTime + 0.1;
#if defined RPG
//rpg
	if(!b_NpcIsInADungeon[npc.index])
	{
		if(!npc.m_iAttacksTillMegahit)
		{
			return;
		}
	}
	RPGNpc_UpdateHpHud(npc.index);

	// npc.m_iTarget comes from here, This only handles out of battle instancnes, for inbattle, code it yourself. It also makes NPCS jump if youre too high up.
	Npc_Base_Thinking(iNPC, 1500.0, "ACT_MP_RUN_MELEE", "ACT_MP_STAND_MELEE", 300.0, GameTime);
	int PrimaryThreatIndex = npc.m_iTarget;
#else	
//for zr
	if(npc.m_flGetClosestTargetTime < GameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	int PrimaryThreatIndex = npc.m_iTarget;
	Ruina_Ai_Override_Core(npc.index, PrimaryThreatIndex, GameTime);	//handles movement, also handles targeting
#endif
	
	npc.AdjustWalkCycle();

	//enemy is invalid, find a new enemy gamer.
	if(!IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		npc.PlayIdleSound();
		npc.m_flGetClosestTargetTime = 0.0;
		return;
	}

	float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		
	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);

	if(flDistanceToTarget < GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 5.0)
	{
		npc.m_bAllowBackWalking = true;
		npc.FaceTowards(vecTarget, RUINA_FACETOWARDS_BASE_TURNSPEED*2.0);
	}

	int iPitch = npc.LookupPoseParameter("body_pitch");
	if(iPitch < 0)
		return;		

	//Body pitch
	float v[3], ang[3];
	SubtractVectors(VecSelfNpc, vecTarget, v); 
	NormalizeVector(v, v);
	GetVectorAngles(v, ang); 
							
	float flPitch = npc.GetPoseParameter(iPitch);
							
	npc.SetPoseParameter(iPitch, ApproachAngle(ang[0], flPitch, 10.0));

	npc.StartPathing();

	Self_Defense(npc, flDistanceToTarget, PrimaryThreatIndex, vecTarget);

	bool backing_up = KeepDistance(npc, flDistanceToTarget, PrimaryThreatIndex, GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 7.5);

	if(npc.m_bAllowBackWalking && backing_up)
	{
		npc.m_flSpeed = fl_npc_basespeed*RUINA_BACKWARDS_MOVEMENT_SPEED_PENALTY;	
		npc.FaceTowards(vecTarget, RUINA_FACETOWARDS_BASE_TURNSPEED*2.0);
	}
	else
	{
		npc.m_flSpeed = fl_npc_basespeed;
	}
	
}
static bool KeepDistance(Levita npc, float flDistanceToTarget, int PrimaryThreatIndex, float Distance)
{
	bool backing_up = false;
	if(flDistanceToTarget < Distance  && npc.m_fbGunout)
	{
		int Enemy_I_See;
			
		Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
		//Target close enough to hit
		if(IsValidEnemy(npc.index, Enemy_I_See)) //Check if i can even see.
		{
			if(flDistanceToTarget < (Distance*0.9))
			{
				Ruina_Runaway_Logic(npc.index, PrimaryThreatIndex);
				npc.m_bAllowBackWalking=true;
				backing_up = true;
			}
			else
			{
				npc.StopPathing();
				
				npc.m_bAllowBackWalking=false;
			}
		}
		else
		{
			npc.StartPathing();
			
			npc.m_bAllowBackWalking=false;
		}		
	}
	else
	{
		npc.StartPathing();
		
		npc.m_bAllowBackWalking=false;
	}

	return backing_up;
}
static void Self_Defense(Levita npc, float flDistanceToTarget, int PrimaryThreatIndex, float vecTarget[3])
{
	float GameTime = GetGameTime(npc.index);


}


public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	Levita npc = view_as<Levita>(victim);

	float GameTime = GetGameTime(npc.index);

	if (npc.m_flHeadshotCooldown < GameTime)
	{
		npc.m_flHeadshotCooldown = GameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}
public void NPC_Death(int entity)
{
	Levita npc = view_as<Levita>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();
	}
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


