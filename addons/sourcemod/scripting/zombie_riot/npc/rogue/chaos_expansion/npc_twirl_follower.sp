#pragma semicolon 1
#pragma newdecls required

static const char g_RangeAttackSounds[][] = {
	"ui/hitsound_vortex1.wav",
	"ui/hitsound_vortex2.wav",
	"ui/hitsound_vortex3.wav",
	"ui/hitsound_vortex4.wav",
	"ui/hitsound_vortex5.wav"
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
static const char g_LaserLoop[][] = {
	"zombiesurvival/seaborn/loop_laser.mp3"
};

static int NPCId;

#define TWIRL_FOLLOWER_ATTACK_RANGE GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 6.5
void TwirlFollower_Setup()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Twirl");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_twirl_follower");
	strcopy(data.Icon, sizeof(data.Icon), "");

	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_RangeAttackSounds);
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);
}

stock int TwirlFollower_ID()
{
	return NPCId;
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return TwirlFollower(vecPos, vecAng, team);
}

static Action TwirlFollower_SpeechTimer(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	if(entity != -1)
	{
		char speechtext[128], endingtextscroll[10];
		pack.ReadString(speechtext, sizeof(speechtext));
		pack.ReadString(endingtextscroll, sizeof(endingtextscroll));
		view_as<TwirlFollower>(entity).Speech(speechtext, endingtextscroll);
	}
	return Plugin_Stop;
}
static float fl_npc_basespeed;
methodmap TwirlFollower < CClotBody
{
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayDeathSound() 
	{
	//	EmitSoundToAll("npc/strider/striderx_die1.wav", this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
	}
	public void PlayRangeAttackSound() {
		EmitSoundToAll(g_RangeAttackSounds[GetRandomInt(0, sizeof(g_RangeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
	}
	public void SpeechTalk()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		if(GetEntityFlags(this.index) & FL_FROZEN)
			return;

		switch(GetURandomInt() % 11)
		{
			case 0:
			{
				this.Speech("Here's something that might of interest", "...");
				this.SpeechDelay(7.0, "The Ruina night sky is filled with numerous stars");
				this.SpeechDelay(14.0, "Real stars, and ones created by mana that sit on the barrier that surround our islands");
			}
			case 1:
			{
				this.Speech("Ruinian candy is the most delicous candy in the world!");
				this.SpeechDelay(5.0, ".. If you can survive the extreme sweetness of it", "...");
			}
			case 2:
			{
				//you see mr rogers, I LOVE GOOOOOOOOOOOOOOOOOOLLLDDD
				this.Speech("I LOVE GOLD");
			}
			case 3:
			{
				this.Speech("So, have you ever spent several days and nights straight trying to perfect a spell?");
				this.SpeechDelay(10.0, ".. No? Guess thats just me", "...");
			}
			case 4:
			{
				this.Speech("MASTER SPARK", "...");
				this.SpeechDelay(5.0,"Nah, on second thought, not gonna use that yet");
			}
			case 5:
			{
				this.Speech("Don't you dare call me an old hag", "...");
				this.SpeechDelay(5.0,"I'll have you know I always rank number one in all beaty competitions, hah");
				//yeah right <...>
			}
			case 6:
			{
				this.Speech("You want to cast spells like mine?");
				this.SpeechDelay(5.0,"HAH, not in a million years");
			}
			case 7:
			{
				this.Speech("Wanna hear a joke?");
				switch(GetURandomInt() % 2)
				{
					case 0:
					{
						this.SpeechDelay(5.0,"How do you think holy water is made", "...");
						this.SpeechDelay(10.0,"By boiling the HELL out of it ", "hahahaha");
					}
					case 1:
					{
						this.SpeechDelay(10.0,"So, to the Optimist the glass is half full, to the Pesimist its half empty", "...");
						this.SpeechDelay(17.0,"But to the engineer the glass is twice as big as it needs to be.");
					}
				}
			}
			case 8:
			{
				this.Speech("Sometimes I wonder, what would life be if I wasn't a mage", "...");
				this.SpeechDelay(7.0,"Probably hell");
			}
			case 9:
			{
				this.Speech("So, did you know that most \"Complex\" Magic Weapons/Wands you might have seen or even used were created by us?");
			}
			case 10:
			{
				this.Speech("I can use every single Spell/Wand/Staff that exists in this world, there are no exceptions. Heh~");
			}
		}
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(36.0, 48.0);
	}
	public void SpeechDelay(float time, const char[] speechtext, const char[] endingtextscroll = "")
	{
		DataPack pack;
		CreateDataTimer(time, TwirlFollower_SpeechTimer, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(EntIndexToEntRef(this.index));
		pack.WriteString(speechtext);
		pack.WriteString(endingtextscroll);
	}
	public void Speech(const char[] speechtext, const char[] endingtextscroll = "")
	{
		NpcSpeechBubble(this.index, speechtext, 5, {255, 255, 255, 255}, {0.0,0.0,90.0}, endingtextscroll);
	}
	public void PlayMagiaOverflowSound() {
		if(fl_AbilityOrAttack[this.index][4] > GetGameTime())
			return;
		EmitCustomToAll(g_LaserLoop[GetRandomInt(0, sizeof(g_LaserLoop) - 1)], this.index, SNDCHAN_STATIC, 75, _, 0.85);
		fl_AbilityOrAttack[this.index][4] = GetGameTime() + 2.25;
	}
	property float m_flLaserRecharge
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flLaserDuration
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flLaserAngle
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flLaserThrottle
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	property float m_flRetreatTimer
	{
		public get()							{ return fl_AbilityOrAttack[this.index][5]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][5] = TempValueForProperty; }
	}
	property float m_flMultiAttackDelay
	{
		public get()							{ return fl_AbilityOrAttack[this.index][6]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][6] = TempValueForProperty; }
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
	public int i_weapon_type()
	{
		int wave = Waves_GetRoundScale()+1;

		if(this.m_fbGunout)	//ranged
		{
			if(wave<=15)	
			{
				return RUINA_TWIRL_CREST_1;
			}
			else if(wave <=30)	
			{
				return RUINA_TWIRL_CREST_2;
			}
			else if(wave <= 45)	
			{
				return RUINA_TWIRL_CREST_3;
			}
			else
			{
				return RUINA_TWIRL_CREST_4;
			}
		}
		else				//melee
		{
			if(wave<=15)	
			{
				return RUINA_TWIRL_MELEE_1;
			}
			else if(wave <=30)	
			{
				return RUINA_TWIRL_MELEE_2;
			}
			else if(wave <= 45)	
			{
				return RUINA_TWIRL_MELEE_3;
			}
			else
			{
				return RUINA_TWIRL_MELEE_4;
			}
		}
	}
	public void Handle_Weapon()
	{
		switch(this.i_stance_status())
		{
			case -1:
			{
				return;
			}
			case 0:	//melee
			{
				if(this.m_fbGunout)
				{
					this.m_fbGunout = false;

					SetVariantInt(this.i_weapon_type());
					AcceptEntityInput(this.m_iWearable1, "SetBodyGroup");
				}
				
			}
			default:	//ranged/undecided
			{
				if(!this.m_fbGunout)
				{
					this.m_iState = 0;

					this.m_fbGunout = true;
					SetVariantInt(this.i_weapon_type());
					AcceptEntityInput(this.m_iWearable1, "SetBodyGroup");
				}
				
			}

		}
	}
	public int i_stance_status()
	{
		float GameTime = GetGameTime(this.index);
		if(this.m_flReloadIn > (GameTime + 1.0))
			return 0;	//melee
		else
			return 1;	//ranged
	}
	
	public TwirlFollower(float vecPos[3], float vecAng[3],int ally)
	{
		TwirlFollower npc = view_as<TwirlFollower>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "50000", ally, true, true));
		
		npc.m_iChanged_WalkCycle = 1;
		i_NpcWeight[npc.index] = 4;
		npc.SetActivity("ACT_MP_RUN_MELEE");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		npc.m_bDissapearOnDeath = true;

		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCThink[npc.index] = ClotThink;
		b_NpcIsInvulnerable[npc.index] = true; //Special huds for invul targets
		f_NpcTurnPenalty[npc.index] = 1.0;

		npc.m_flLaserRecharge = GetGameTime(npc.index) + GetRandomFloat(5.0, 30.0);	//
		
		fl_npc_basespeed = 310.0;
		npc.m_flSpeed = fl_npc_basespeed;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		npc.Anger = false;
		npc.m_bScalesWithWaves = true;
		npc.m_bisWalking = true;

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
		
		npc.m_fbGunout = true;
		SetVariantInt(RUINA_WINGS_4);
		AcceptEntityInput(npc.m_iWearable2, "SetBodyGroup");
		SetVariantInt(npc.i_weapon_type());
		AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");
		TwirlEarsApply(npc.index,_,0.75);

		npc.m_flNextIdleSound = GetGameTime(npc.index) + 60.0;

		Ruina_Set_Heirarchy(npc.index, RUINA_GLOBAL_NPC);
		Ruina_Set_Master_Heirarchy(npc.index, RUINA_GLOBAL_NPC, false, 0, 0);	//need this to get certain fuctions to work/behave properly!

		//BEGONE UGLY MEDIC BACKPACK!
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		//weird bug: on first spawn, she doesn't move, but after an enemy appers everything acts as expected.
		//oh also she doesn't die apparently when I try to sm_perish her
		//but sm_remove_npc does work

		if(Rogue_Mode())
		{
			// Cutscene Here
			if(Rogue_Theme() == BlueParadox)
			{
				npc.Speech("Thanks bob, ill need your help for this!");
				npc.SpeechDelay(5.0, "This might actually be serious for once","...");
				Rogue_SetProgressTime(10.0, false);
			}
			else
			{
				npc.Speech("i'll acompany you for the rifts.");
				npc.SpeechDelay(5.0, "I won't stay for long.","...");
			}
		/*
			for(int i; i < i_MaxcountNpcTotal; i++)
			{
				int other = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
				if(other != -1 && i_NpcInternalId[other] == BobTheFirstFollower_ID() && IsEntityAlive(other))
				{
					view_as<CClotBody>(other).m_bDissapearOnDeath = true;
					SmiteNpcToDeath(other);
					break;
				}
			}
		*/
		}
		return npc;
	}
}

static void ClotThink(int iNPC)
{
	TwirlFollower npc = view_as<TwirlFollower>(iNPC);

	float GameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > GameTime)
	{
		return;
	}
	npc.m_flNextDelayTime = GameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_flNextThinkTime > GameTime)
	{
		return;
	}
	npc.m_flNextThinkTime = GameTime + 0.1;

	if(npc.m_flLaserDuration > GameTime)
	{
		if(npc.m_flGetClosestTargetTime < GameTime)
		{
			npc.m_iTarget = GetClosestTarget(npc.index,_,_,_,_,_,_,true);
			if(npc.m_iTarget < 1)
			{
				npc.m_iTarget = GetClosestTarget(npc.index);
			}
			npc.m_flGetClosestTargetTime = GameTime + GetRandomRetargetTime();
		}
		if(IsValidEnemy(npc.index, npc.m_iTarget))
		{
			float vecTarget[3]; GetAbsOrigin(npc.m_iTarget, vecTarget);

			float Turn_Speed = 300.0;
			npc.FaceTowards(vecTarget, Turn_Speed);

			float VecSelfNpc[3]; GetAbsOrigin(npc.index, VecSelfNpc);

			Body_Pitch(npc, VecSelfNpc, vecTarget);
		}
		else
		{
			npc.m_flGetClosestTargetTime = 0.0;
		}
	}

	if(npc.m_flDoingAnimation > GameTime)
		return;

	if(npc.m_bAllowBackWalking && npc.m_iTargetWalkTo == -1)
	{
		npc.m_flSpeed = fl_npc_basespeed*RUINA_BACKWARDS_MOVEMENT_SPEED_PENALTY;
		if(IsValidEnemy(npc.index, npc.m_iTarget))
		{
			float WorldSpaceVec[3]; WorldSpaceCenter(npc.m_iTarget, WorldSpaceVec);
			npc.FaceTowards(WorldSpaceVec, 150.0);
		}
	}
	else
		npc.m_flSpeed = fl_npc_basespeed;

	if(npc.m_flGetClosestTargetTime < GameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GameTime + GetRandomRetargetTime();
	}

	npc.Handle_Weapon();
	npc.AdjustWalkCycle();
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		//Target close enough to hit
		if(IsValidEnemy(npc.index, Can_I_See_Enemy(npc.index, npc.m_iTarget))) //Check if i can even see.
			if(Laser_Initiate(npc))
				return;
				

		int PrimaryThreatIndex = npc.m_iTarget;

		float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex, _,_,vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(PrimaryThreatIndex);
		}
			
		npc.m_iTargetWalkTo = -1;
		npc.StartPathing();

		bool backing_up = KeepDistance(npc, flDistanceToTarget, PrimaryThreatIndex, TWIRL_FOLLOWER_ATTACK_RANGE * 1.75);

		if(flDistanceToTarget < TWIRL_FOLLOWER_ATTACK_RANGE * 5.0)
		{
			npc.m_bAllowBackWalking = true;
			npc.FaceTowards(vecTarget, RUINA_FACETOWARDS_BASE_TURNSPEED*2.0);
		}

		Self_Defense(npc, flDistanceToTarget, PrimaryThreatIndex, vecTarget);

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
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
		int ally = npc.m_iTargetWalkTo;
		if(IsValidAlly(npc.index,ally))
		{
			float vecTarget[3]; WorldSpaceCenter(ally, vecTarget );
		
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			if(flDistanceToTarget > 25000.0)
			{
				if(Can_I_See_Enemy_Only(npc.index, ally))
				{
					npc.m_bAllowBackWalking = true;
					npc.FaceTowards(vecTarget, 99999.0);
				}
				else
				{
					npc.m_bAllowBackWalking = false;
				}
				npc.SetGoalEntity(ally);
				return;
			}
			npc.m_bAllowBackWalking = false;
		}
		else
		{
			ally = GetClosestAllyPlayer(npc.index);
			npc.m_iTargetWalkTo = ally;
		}
	}
	npc.SpeechTalk();
}
static void Self_Defense(TwirlFollower npc, float flDistanceToTarget, int PrimaryThreatIndex, float vecTarget[3])
{
	float GameTime = GetGameTime(npc.index);

	if(npc.m_fbGunout)
	{
		//enemy is too far
		if(flDistanceToTarget > (TWIRL_FOLLOWER_ATTACK_RANGE * 2.5))	
		{
			if(npc.m_flReloadIn < GameTime)	//might as well check if we are done reloading so our "clip" is refreshed
				npc.m_iState = 0;

			return;
		}
			
		//we are "reloading", so keep distance.
		if(npc.m_flReloadIn > GameTime)
		{
			KeepDistance(npc, flDistanceToTarget, PrimaryThreatIndex, TWIRL_FOLLOWER_ATTACK_RANGE * 1.75);
			npc.m_flSpeed = fl_npc_basespeed*RUINA_BACKWARDS_MOVEMENT_SPEED_PENALTY;	
			npc.FaceTowards(vecTarget, RUINA_FACETOWARDS_BASE_TURNSPEED*2.0);
			return;
		}

		int Enemy_I_See;	
		Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
		//I cannot see the target.
		if(!IsValidEnemy(npc.index, Enemy_I_See))
			return;
		//our special multi attack is still recharging
		if(npc.m_flMultiAttackDelay > GameTime)
			return;

		float	Multi_Delay = 0.3,
				Reload_Delay = 3.0;
		
		if(npc.m_iState >= 15)	//"ammo"
		{
			npc.m_iState = 0;
			npc.m_flReloadIn = GameTime + Reload_Delay;	//"reload" time
		}
		else
		{
			npc.m_iState++;
		}
				
		npc.m_flMultiAttackDelay = GameTime + Multi_Delay;

		npc.FaceTowards(vecTarget, 100000.0);
		npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
		npc.PlayRangeAttackSound();

		float flPos[3];
			
		GetAttachment(npc.index, "effect_hand_r", flPos, NULL_VECTOR);
		
		float 	projectile_speed = 1100.0,
				target_vec[3];

		PredictSubjectPositionForProjectiles(npc, PrimaryThreatIndex, projectile_speed, _,target_vec);

		float Dmg = 19.0;
		char Particle[50];
		if(npc.m_iState % 2)
			Particle = "raygun_projectile_blue";
		else
			Particle = "raygun_projectile_red";

		npc.FireParticleRocket(target_vec, Dmg , projectile_speed , 0.0 , Particle, false, false, true, flPos, .inflictor = npc.index);
	}
	else
	{
		float Swing_Speed = 2.0;
		float Swing_Delay = 0.15;

		if(npc.m_flAttackHappens)
		{
			if(npc.m_flAttackHappens < GameTime)
			{
				npc.m_flAttackHappens = 0.0;

				npc.m_flRetreatTimer = GameTime+(Swing_Speed*0.35);

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
			
						SDKHooks_TakeDamage(target, npc.index, npc.index, 50.0, DMG_CLUB, -1, _, vecHit);
						float Kb = 450.0;

						Custom_Knockback(npc.index, target, Kb, true);
						if(target <= MaxClients)
						{
							TF2_AddCondition(target, TFCond_LostFooting, 0.5);
							TF2_AddCondition(target, TFCond_AirCurrent, 0.5);
						}
					}
					npc.PlayMeleeHitSound();
					
				}
				delete swingTrace;
			}
		}
		else
		{
			if(npc.m_flRetreatTimer > GameTime || (flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*2.0 && npc.m_flNextMeleeAttack > GameTime))
			{
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, PrimaryThreatIndex,_,vBackoffPos);
				npc.SetGoalVector(vBackoffPos, true);
				npc.FaceTowards(vecTarget, 20000.0);
				npc.m_flSpeed =  fl_npc_basespeed*RUINA_BACKWARDS_MOVEMENT_SPEED_PENALTY;
			}
		}

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
				npc.m_flNextMeleeAttack = GameTime + Swing_Speed;
			}
		}
	}
}
static bool KeepDistance(TwirlFollower npc, float flDistanceToTarget, int PrimaryThreatIndex, float Distance)
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
static float[] GetNPCAngles(TwirlFollower npc)
{
	float Angles[3];
	GetEntPropVector(npc.index, Prop_Data, "m_angRotation", Angles);
	int iPitch = npc.LookupPoseParameter("body_pitch");
	if(iPitch < 0)
		return Angles;
			
	float flPitch = npc.GetPoseParameter(iPitch);
	
	flPitch *= -1.0;
	Angles[0] = flPitch;

	return Angles;
}
static void Body_Pitch(TwirlFollower npc, float VecSelfNpc[3], float vecTarget[3])
{
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
}
#define TWIRL_FOLLOWER_LASER_DURATION 10.0
#define TWIRL_FOLLOWER_TE_DURATION 0.1
static bool b_animation_set[MAXENTITIES];
static bool Laser_Initiate(TwirlFollower npc)
{
	float GameTime = GetGameTime(npc.index);
	if(npc.m_flLaserRecharge > GameTime)
		return false;

	npc.AddActivityViaSequence("taunt_the_scaredycat_medic");
	npc.SetPlaybackRate(1.0);	
	npc.SetCycle(0.01);

	SetEntityRenderMode(npc.m_iWearable1, RENDER_NONE);
	SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 1);

	npc.m_flLaserDuration = GameTime + TWIRL_FOLLOWER_LASER_DURATION + 0.75;
	npc.m_flDoingAnimation = npc.m_flLaserDuration;
	npc.m_flLaserThrottle = GameTime + 0.7;
	npc.m_flLaserRecharge = GameTime + 60.0;

	b_animation_set[npc.index] = false;
	npc.m_flLaserAngle = GetRandomFloat(0.0, 360.0);

	npc.StopPathing();
	
	npc.m_flSpeed = 0.0;

	npc.m_bisWalking = false;

	SDKUnhook(npc.index, SDKHook_Think, Magia_Overflow_Tick_Follower);
	SDKHook(npc.index, SDKHook_Think, Magia_Overflow_Tick_Follower);

	return true;
}
static Action Magia_Overflow_Tick_Follower(int iNPC)
{
	TwirlFollower npc = view_as<TwirlFollower>(iNPC);
	float GameTime = GetGameTime(npc.index);

	if(npc.m_flLaserDuration < GameTime)
	{
		SDKUnhook(npc.index, SDKHook_Think, Magia_Overflow_Tick_Follower);

		npc.m_bisWalking = true;
		npc.m_flSpeed = fl_npc_basespeed;
		npc.StartPathing();

		StopCustomSound(npc.index, SNDCHAN_STATIC, g_LaserLoop[GetRandomInt(0, sizeof(g_LaserLoop) - 1)]);

		SetEntityRenderMode(npc.m_iWearable1, RENDER_NORMAL);
		SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 255);

		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		npc.m_iChanged_WalkCycle = 1;
		if(iActivity > 0) npc.StartActivity(iActivity);

		return Plugin_Stop;
	}
	ApplyStatusEffect(npc.index, npc.index, "Hardened Aura", 0.25);
	ApplyStatusEffect(npc.index, npc.index, "Solid Stance", 0.25);

	npc.m_flSpeed = 0.0;	//DON'T MOVE

	bool update = false;
	if(npc.m_flLaserThrottle < GameTime)
	{
		update = true;
		npc.m_flLaserThrottle = GameTime + 0.1;
	}

	if(!b_animation_set[npc.index] && update)
	{
		b_animation_set[npc.index] = true;
		npc.SetPlaybackRate(0.0);	
		//npc.SetCycle(0.4);
	}
	if(!b_animation_set[npc.index])
		return Plugin_Continue;

	npc.PlayMagiaOverflowSound();
	
	float Radius = 30.0;
	float diameter = Radius*2.0;
	Ruina_Laser_Logic Laser;
	Laser.client = npc.index;
	float flPos[3];
	float Angles[3];
	Angles = GetNPCAngles(npc);
	GetAttachment(npc.index, "effect_hand_r", flPos, NULL_VECTOR);
	//flPos[2]+=37.0;
	Get_Fake_Forward_Vec(15.0, Angles, flPos, flPos);

	Laser.DoForwardTrace_Custom(Angles, flPos, -1.0);

	if(update)
	{
		float Dps = 10.0;
		Laser.Damage = Dps;
		Laser.Radius = Radius;
		Laser.Bonus_Damage = Dps;
		Laser.damagetype = DMG_PLASMA;
		Laser.Deal_Damage();
	}	

	float TE_Duration = TWIRL_FOLLOWER_TE_DURATION;
	float EndLoc[3]; EndLoc = Laser.End_Point;

	int color[4];
	color[0] = 0;
	color[1] = 250;
	color[2] = 237;	
	color[3] = 255;

	float Offset_Loc[3];
	Get_Fake_Forward_Vec(100.0, Angles, Offset_Loc, flPos);

	int colorLayer4[4];
	SetColorRGBA(colorLayer4, color[0], color[1], color[2], color[1]);
	int colorLayer3[4];
	SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, color[3]);
	int colorLayer2[4];
	SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, color[3]);
	int colorLayer1[4];
	SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 7255 / 8, colorLayer4[1] * 5 + 7255 / 8, colorLayer4[2] * 5 + 7255 / 8, color[3]);

	float 	Rng_Start = GetRandomFloat(diameter*0.5, diameter*0.7);

	float 	Start_Diameter1 = ClampBeamWidth(Rng_Start*0.7),
			Start_Diameter2 = ClampBeamWidth(Rng_Start*0.9),
			Start_Diameter3 = ClampBeamWidth(Rng_Start);
		
	float 	End_Diameter1 = ClampBeamWidth(diameter*0.7),
			End_Diameter2 = ClampBeamWidth(diameter*0.9),
			End_Diameter3 = ClampBeamWidth(diameter);

	int Beam_Index = g_Ruina_BEAM_Combine_Blue;

	TE_SetupBeamPoints(flPos, Offset_Loc, Beam_Index, 	0, 0, 66, TE_Duration, 0.0, Start_Diameter1, 0, 10.0, colorLayer2, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(flPos, Offset_Loc, Beam_Index, 	0, 0, 66, TE_Duration, 0.0, Start_Diameter2, 0, 10.0, colorLayer3, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(flPos, Offset_Loc, Beam_Index,	0, 0, 66, TE_Duration, 0.0, Start_Diameter3, 0, 10.0, colorLayer4, 3);
	TE_SendToAll(0.0);

	TE_SetupBeamPoints(Offset_Loc, EndLoc, Beam_Index, 	0, 0, 66, TE_Duration, Start_Diameter1*0.9, End_Diameter1, 0, 0.1, colorLayer2, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(Offset_Loc, EndLoc, Beam_Index, 	0, 0, 66, TE_Duration, Start_Diameter2*0.9, End_Diameter2, 0, 0.1, colorLayer3, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(Offset_Loc, EndLoc, Beam_Index, 	0, 0, 66, TE_Duration, Start_Diameter3*0.9, End_Diameter3, 0, 0.1, colorLayer4, 3);
	TE_SendToAll(0.0);

	if(npc.m_flLaserAngle>360.0)
		npc.m_flLaserAngle -=360.0;
	
	npc.m_flLaserAngle+=2.5/TickrateModify;

	Twirl_Magia_Rings(npc, Offset_Loc, Angles, 3, true, 50.0, 1.0, TE_Duration, color, EndLoc);

	return Plugin_Continue;

}
static void Twirl_Magia_Rings(TwirlFollower npc, float Origin[3], float Angles[3], int loop_for, bool Type=true, float distance_stuff, float ang_multi, float TE_Duration, int color[4], float drill_loc[3])
{
	float buffer_vec[3][3];
		
	for(int i=0 ; i<loop_for ; i++)
	{	
		float tempAngles[3], Direction[3], endLoc[3];
		tempAngles[0] = Angles[0];
		tempAngles[1] = Angles[1];	//has to the same as the beam
		tempAngles[2] = (npc.m_flLaserAngle+((360.0/loop_for)*float(i)))*ang_multi;	//we use the roll angle vector to make it speeen
		/*
			Using this method we can actuall keep proper pitch/yaw angles on the turning, unlike say fantasy blade or mlynar newspaper's special swing thingy.
		*/
		
		if(tempAngles[2]>360.0)
			tempAngles[2] -= 360.0;
	
					
		GetAngleVectors(tempAngles, Direction, NULL_VECTOR, Direction);
		ScaleVector(Direction, distance_stuff);
		AddVectors(Origin, Direction, endLoc);
		
		buffer_vec[i] = endLoc;
		
		if(Type)
		{
			int r=175, g=175, b=175, a=175;
			float diameter = 15.0;
			int colorLayer4[4];
			SetColorRGBA(colorLayer4, r, g, b, a);
			int colorLayer1[4];
			SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, a);
										
			TE_SetupBeamPoints(endLoc, drill_loc, g_Ruina_BEAM_Combine_Blue, 0, 0, 0, TE_Duration, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 0.25, colorLayer1, 3);
										
			TE_SendToAll();
		}
		
	}
	
	TE_SetupBeamPoints(buffer_vec[0], buffer_vec[loop_for-1], g_Ruina_BEAM_Combine_Blue, 0, 0, 0, TE_Duration, 5.0, 5.0, 0, 0.01, color, 3);	
	TE_SendToAll(0.0);
	for(int i=0 ; i<(loop_for-1) ; i++)
	{
		TE_SetupBeamPoints(buffer_vec[i], buffer_vec[i+1], g_Ruina_BEAM_Combine_Blue, 0, 0, 0, TE_Duration, 5.0, 5.0, 0, 0.01, color, 3);	
		TE_SendToAll(0.0);
	}
	
}
static void Get_Fake_Forward_Vec(float Range, float vecAngles[3], float Vec_Target[3], float Pos[3])
{
	float Direction[3];
	
	GetAngleVectors(vecAngles, Direction, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(Direction, Range);
	AddVectors(Pos, Direction, Vec_Target);
}

/*
//the movement this provided to the follower twirl dissasisfied me, so I completely rewrote how follower twirl moves to be more visually apeasing for me.
int TwirlFollowerSelfDefense(TwirlFollower npc, float gameTime, int target, float distance)
{
	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.5))
		{
			int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				float target_vec[3];
				npc.m_flNextMeleeAttack = gameTime + 1.0;
				float DamageProject = 30.0;
				float projectile_speed = 900.0;
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
				npc.PlayRangeAttackSound();

				PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, projectile_speed, _,target_vec);
				npc.FaceTowards(target_vec, 100000.0);
				char Particle[50];
				if(npc.m_iState)
					Particle = "raygun_projectile_blue";
				else
					Particle = "raygun_projectile_red";

				if(npc.m_iState)
					npc.m_iState = 0;
				else
					npc.m_iState = 1;

				float flPos[3];
			
				GetAttachment(npc.index, "effect_hand_r", flPos, NULL_VECTOR);
				npc.FireParticleRocket(target_vec, DamageProject, projectile_speed , 0.0 , Particle, false, _, true, flPos);
			}
			if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.5))
			{
				//target is too far, try to close in
				return 0;
			}
			else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 2.5))
			{
				if(Can_I_See_Enemy_Only(npc.index, target))
				{
					//target is too close, try to keep distance
					return 1;
				}
			}
			return 0;
		}
		else
		{
			if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.5))
			{
				//target is too far, try to close in
				return 0;
			}
			else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 2.5))
			{
				if(Can_I_See_Enemy_Only(npc.index, target))
				{
					//target is too close, try to keep distance
					return 1;
				}
			}
		}
	}
	else
	{
		if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.5))
		{
			//target is too far, try to close in
			return 0;
		}
		else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 2.5))
		{
			if(Can_I_See_Enemy_Only(npc.index, target))
			{
				//target is too close, try to keep distance
				return 1;
			}
		}
	}
	return 0;
}*/


static void ClotDeath(int entity)
{
	TwirlFollower npc = view_as<TwirlFollower>(entity);

	npc.PlayDeathSound();
	
	ExpidonsaRemoveEffects(entity);

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
