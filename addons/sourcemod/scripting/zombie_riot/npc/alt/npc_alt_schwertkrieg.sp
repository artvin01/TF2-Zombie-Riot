#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/medic_paincrticialdeath01.mp3",
	"vo/medic_paincrticialdeath02.mp3",
	"vo/medic_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/medic_painsharp01.mp3",
	"vo/medic_painsharp02.mp3",
	"vo/medic_painsharp03.mp3",
	"vo/medic_painsharp04.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/medic_battlecry01.mp3",
	"vo/medic_battlecry02.mp3",
	"vo/medic_battlecry03.mp3",
	"vo/medic_battlecry04.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/ubersaw_hit1.wav",
	"weapons/ubersaw_hit2.wav",
	"weapons/ubersaw_hit3.wav",
	"weapons/ubersaw_hit4.wav",
};
static const char g_MeleeAttackSounds[][] = {
	"weapons/knife_swing.wav",
};

static const char g_MeleeMissSounds[][] = {
	"weapons/cbar_miss1.wav",
};

static float fl_teleport_timer[MAXENTITIES];
static bool b_teleport_recharging[MAXENTITIES];
static bool b_schwert_is_ally[MAXENTITIES];


static float TELEPORT_STRIKE_Smite_BaseDMG = 1500.0; //Base damage of the effect
static float TELEPORT_STRIKE_Smite_Radius = 500.0;//Radius of the effect
static float TELEPORT_STRIKE_Smite_ChargeTime = 1.33;
static float TELEPORT_STRIKE_Smite_ChargeSpan = 0.66;
static float TELEPORT_STRIKE_Timer = 1.0; //How long it takes to teleport
static float TELEPORT_STRIKE_Reuseable = 30.0; //How long it should be reuseable again


static float Schwertkrieg_Speed = 330.0;

#define TELEPORT_STRIKE_ACTIVATE		"misc/halloween/gotohell.wav"
#define TELEPORT_STRIKE_TELEPORT		"weapons/bison_main_shot.wav"
#define TELEPORT_STRIKE_EXPLOSION		"weapons/vaccinator_charge_tier_03.wav"
#define TELEPORT_STRIKE_HIT				"vo/taunts/medic/medic_taunt_kill_22.mp3"
#define TELEPORT_STRIKE_MISS			"vo/medic_negativevocalization04.mp3"

void Schwertkrieg_OnMapStart_NPC()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_MeleeMissSounds);
	
	
	PrecacheSound(TELEPORT_STRIKE_ACTIVATE, true);
	PrecacheSound(TELEPORT_STRIKE_TELEPORT, true);
	PrecacheSound(TELEPORT_STRIKE_HIT, true);
	PrecacheSound(TELEPORT_STRIKE_EXPLOSION, true);
	PrecacheSound(TELEPORT_STRIKE_MISS, true);
	
	PrecacheSound("mvm/mvm_tele_deliver.wav");
	PrecacheSound("passtime/tv2.wav");
	PrecacheSound("misc/halloween/spell_mirv_explode_primary.wav");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Schwertkrieg");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_schwertkrieg");
	data.Category = Type_Alt;
	data.Func = ClotSummon;
	strcopy(data.Icon, sizeof(data.Icon), "schwert"); 		//leaderboard_class_(insert the name)
	data.IconCustom = true;													//download needed?
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;										//example: MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;, forces these flags.	
	NPC_Add(data);

}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return Schwertkrieg(client, vecPos, vecAng, ally, data);
}

methodmap Schwertkrieg < CClotBody
{
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleAlertSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayDeathSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayMeleeMissSound()");
		#endif
	}
	
	
	
	public Schwertkrieg(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Schwertkrieg npc = view_as<Schwertkrieg>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "25000", ally));

		i_NpcWeight[npc.index] = 3;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		if(ally != TFTeam_Red)
		{
			g_b_schwert_died=false;	

			g_b_angered=false;
			b_schwert_is_ally[npc.index] = false;	//if schwert is blue do normal stuff
		}
		else
		{
			b_schwert_is_ally[npc.index] = true;	//if schwert is red, block all the raidboss angered logic!
		}
		
		

		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(Internal_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Internal_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Internal_ClotThink);
		
		//IDLE
		npc.m_flSpeed = Schwertkrieg_Speed;
		
		int skin = 5;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		bool final = StrContains(data, "raid_ally") != -1;
		
		if(final)
		{
			i_RaidGrantExtra[npc.index] = 1;
		}
		else
		{
			if(!IsValidEntity(RaidBossActive) && ally != TFTeam_Red)
			{
				RaidBossActive = EntIndexToEntRef(npc.index);
				RaidModeTime = GetGameTime(npc.index) + 9000.0;
				RaidModeScaling = 10.0;
				RaidAllowsBuildings = true;
			}
		}
		
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/player/items/medic/medic_zombie.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/weapons/c_models/c_claidheamohmor/c_claidheamohmor.mdl");	//claidemor
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		float flPos[3]; // original
		float flAng[3]; // original
		
		npc.GetAttachment("eyeglow_L", flPos, flAng);
		npc.m_iWearable2 = ParticleEffectAt_Parent(flPos, "raygun_projectile_blue_crit", npc.index, "eyeglow_L", {0.0,0.0,0.0});
		npc.GetAttachment("root", flPos, flAng);
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/medic/hw2013_das_blutliebhaber/hw2013_das_blutliebhaber.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/all_class/hw2013_the_dark_helm/hw2013_the_dark_helm_medic.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		
		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/medic/sf14_medic_herzensbrecher/sf14_medic_herzensbrecher.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");
		
		npc.StartPathing();

		
		npc.m_flMeleeArmor = 1.5;

		npc.m_bThisNpcIsABoss = true;
		
		EmitSoundToAll("mvm/mvm_tele_deliver.wav");

		fl_teleport_timer[npc.index]=GetGameTime(npc.index)+5.0;
		b_teleport_recharging[npc.index]=true;
		
		TELEPORT_STRIKE_Smite_ChargeTime = 1.33;
		TELEPORT_STRIKE_Smite_ChargeSpan = 0.66;
		TELEPORT_STRIKE_Timer = 2.0; //How long it takes to teleport
		TELEPORT_STRIKE_Reuseable = 30.0; //How long it should be reuseable again

		return npc;
	}
	
	
}

//TODO 
//Rewrite
static void Internal_ClotThink(int iNPC)
{
	Schwertkrieg npc = view_as<Schwertkrieg>(iNPC);

	float GameTime = GetGameTime(npc.index);
	
	if(ZR_GetWaveCount()+1 >=60 && EntRefToEntIndex(RaidBossActive)==npc.index && i_RaidGrantExtra[npc.index] == 1)	//schwertkrieg handles the timer if its the same index
	{
		if(RaidModeTime < GameTime)
		{
			ForcePlayerLoss();
			RaidBossActive = INVALID_ENT_REFERENCE;
			func_NPCThink[npc.index]=INVALID_FUNCTION;
		}
	}

	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	if(!IsValidEntity(RaidBossActive) && !g_b_schwert_died && ZR_GetWaveCount()+1 >=60 && i_RaidGrantExtra[npc.index] == 1)
	{
		RaidBossActive=EntIndexToEntRef(npc.index);
	}
	else
	{
		if(ZR_GetWaveCount()+1 >=60 && EntRefToEntIndex(RaidBossActive)==npc.index && g_b_schwert_died && i_RaidGrantExtra[npc.index] == 1)
		{
			RaidBossActive = INVALID_ENT_REFERENCE;
		}
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

	if(npc.m_flGetClosestTargetTime < GameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GameTime + GetRandomRetargetTime();
	}
	if(g_b_schwert_died && g_b_item_allowed  && i_RaidGrantExtra[npc.index] == 1)	//Schwertkrieg is mute,
	{
		npc.m_flNextThinkTime = 0.0;
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.SetActivity("ACT_MP_CROUCH_MELEE");
		npc.m_bisWalking = false;
		if(g_b_donner_died && !IsValidEntity(RaidBossActive))
		{
			if(GetGameTime() > g_f_blitz_dialogue_timesincehasbeenhurt)
			{
				npc.m_bDissapearOnDeath = true;	
				RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
			}
		}			
		return; //He is trying to help.
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
			float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		
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
				
				NPC_SetGoalVector(npc.index, vPredictedPos);
			} else {
				NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
			}

			Schwertkrieg_Teleport_Logic(npc.index, PrimaryThreatIndex, GameTime);

			//Target close enough to hit
			
			npc.StartPathing();
			if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
			{
				//Look at target so we hit.
			//	npc.FaceTowards(vecTarget, 1000.0);
				
				//Can we attack right now?
				if(npc.m_flNextMeleeAttack < GameTime)
				{
					//Play attack ani
					if (!npc.m_flAttackHappenswillhappen)
					{
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS");
						npc.PlayMeleeSound();
						npc.m_flAttackHappens = GameTime+0.2;
						npc.m_flAttackHappens_bullshit = GameTime+0.35;
						npc.m_flAttackHappenswillhappen = true;
					}
						
					if (npc.m_flAttackHappens < GameTime && npc.m_flAttackHappens_bullshit >= GameTime && npc.m_flAttackHappenswillhappen)
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
								float meleedmg= 175.0;
								if(g_b_angered && !b_schwert_is_ally[npc.index])
								{
									meleedmg = 325.0;
								}	
									
								if(!ShouldNpcDealBonusDamage(target))
								{
									if(target <= MaxClients)
									{
										float Bonus_damage = 1.0;
										int weapon = GetEntPropEnt(target, Prop_Send, "m_hActiveWeapon");
		
										if(IsValidEntity(weapon))
										{
											char classname[32];
											GetEntityClassname(weapon, classname, 32);
										
											int weapon_slot = TF2_GetClassnameSlot(classname);
										
											if(weapon_slot != 2 || i_IsWandWeapon[weapon])
											{
												Bonus_damage = 1.5;
											}
											meleedmg *= Bonus_damage;
											SDKHooks_TakeDamage(target, npc.index, npc.index, meleedmg, DMG_CLUB, -1, _, vecHit);
										}
										else
										{
											SDKHooks_TakeDamage(target, npc.index, npc.index, meleedmg, DMG_CLUB, -1, _, vecHit);
										}	
									}
									else
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, meleedmg, DMG_CLUB, -1, _, vecHit);
									}
									
								}
								else
								{
									SDKHooks_TakeDamage(target, npc.index, npc.index, meleedmg * 7.5, DMG_CLUB, -1, _, vecHit);
								}
								
								npc.PlayMeleeHitSound();	
							
							} 
						}
						delete swingTrace;
						npc.m_flNextMeleeAttack = GameTime + 0.3;
						npc.m_flAttackHappenswillhappen = false;
					}
					else if (npc.m_flAttackHappens_bullshit < GameTime && npc.m_flAttackHappenswillhappen)
					{
						npc.m_flAttackHappenswillhappen = false;
						npc.m_flNextMeleeAttack = GameTime + 0.3;
					}
				}
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
static void Schwertkrieg_Teleport_Logic(int iNPC, int PrimaryThreatIndex, float GameTime)
{
	Schwertkrieg npc = view_as<Schwertkrieg>(iNPC);

	if(fl_teleport_timer[npc.index]<=GameTime)
	{
		int enemy = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
		if(IsValidEnemy(npc.index, enemy))
		{
			npc.m_flDoingAnimation = GameTime+TELEPORT_STRIKE_Timer;
			fl_teleport_timer[npc.index]= GameTime+9999.0;

			npc.SetPlaybackRate(0.75);	
			npc.SetCycle(0.0);
							
			b_teleport_recharging[npc.index]=false;
			npc.AddActivityViaSequence("taunt_neck_snap_medic");

			float npc_Loc[3]; GetAbsOrigin(npc.index, npc_Loc);

			EmitSoundToAll(TELEPORT_STRIKE_ACTIVATE, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, npc_Loc);
			EmitSoundToAll(TELEPORT_STRIKE_ACTIVATE, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, npc_Loc);

			npc.m_flMeleeArmor = 0.5;
			npc.m_flRangedArmor = 0.5;

			npc_Loc[2]+=10.0;
			int r, g, b, a;
			r=145;
			g=47;
			b=47;
			a=255;
			TELEPORT_STRIKE_spawnRing_Vectors(npc_Loc, 250.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, TELEPORT_STRIKE_Timer, 12.0, 2.0, 1, 1.0);

			if(IsValidEntity(npc.m_iWearable3))
				RemoveEntity(npc.m_iWearable3);
		}
	}
	if(npc.m_flDoingAnimation < GameTime && fl_teleport_timer[npc.index] > GameTime && !b_teleport_recharging[npc.index])
	{
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		if(iActivity > 0) npc.StartActivity(iActivity);

		npc.m_iWearable3 = npc.EquipItem("head", "models/weapons/c_models/c_claidheamohmor/c_claidheamohmor.mdl");	//claidemor
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		b_teleport_recharging[npc.index]=true;
		float VecForward[3];
		float vecRight[3];
		float vecUp[3];
		float vecPos[3];
				
		GetVectors(PrimaryThreatIndex, VecForward, vecRight, vecUp);
		GetAbsOrigin(PrimaryThreatIndex, vecPos);
		vecPos[2] += 5.0;
				
		float vecSwingEnd[3];
		vecSwingEnd[0] = vecPos[0] - VecForward[0] * (100);
		vecSwingEnd[1] = vecPos[1] - VecForward[1] * (100);
		vecSwingEnd[2] = vecPos[2];/*+ VecForward[2] * (100);*/

		npc.m_flRangedArmor = 1.0;
		int enemy = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
		if(IsValidEnemy(npc.index, enemy))
		{
			npc.FaceTowards(vecSwingEnd);
			npc.FaceTowards(vecSwingEnd);

			float start_offset[3], end_offset[3];
			WorldSpaceCenter(npc.index, start_offset);
			bool Succeed = NPC_Teleport(npc.index, vecSwingEnd);
			if(Succeed)
			{
				
				
				if(g_b_angered && !b_schwert_is_ally[npc.index])
				{
					npc.m_flMeleeArmor = 1.0;
					fl_teleport_timer[npc.index]= GameTime+(TELEPORT_STRIKE_Reuseable*0.5);
				}
				else
				{
					npc.m_flMeleeArmor = 1.5;
					fl_teleport_timer[npc.index]= GameTime+TELEPORT_STRIKE_Reuseable;
				}
					
				
				Schwertkrieg_Teleport_Boom(npc.index, vecSwingEnd, start_offset);
				float effect_duration = 0.25;
			
				end_offset = vecSwingEnd;
								
				//start_offset[2]+= 45;
				//end_offset[2] += 45.0;
								
				for(int help=1 ; help<=8 ; help++)
				{	
					Schwert_Teleport_Effect("drg_manmelter_trail_red", effect_duration, start_offset, end_offset);
									
					start_offset[2] += 12.5;
					end_offset[2] += 12.5;
				}
			}
			else
			{
				vecSwingEnd[0] = vecPos[0] - VecForward[0] * (-100);
				vecSwingEnd[1] = vecPos[1] - VecForward[1] * (-100);
				vecSwingEnd[2] = vecPos[2];/*+ VecForward[2] * (100);*/

				Succeed = NPC_Teleport(npc.index, vecSwingEnd);
				if(Succeed)
				{
				
					if(g_b_angered && !b_schwert_is_ally[npc.index])
					{
						npc.m_flMeleeArmor = 1.0;
						fl_teleport_timer[npc.index]= GameTime+(TELEPORT_STRIKE_Reuseable*0.5);
					}
					else
					{
						npc.m_flMeleeArmor = 1.5;
						fl_teleport_timer[npc.index]= GameTime+TELEPORT_STRIKE_Reuseable;
					}
						
					
					Schwertkrieg_Teleport_Boom(npc.index, vecSwingEnd, start_offset);
					float effect_duration = 0.25;
				
					end_offset = vecSwingEnd;
									
					//start_offset[2]+= 45;
					//end_offset[2] += 45.0;
									
					for(int help=1 ; help<=8 ; help++)
					{	
						Schwert_Teleport_Effect("drg_manmelter_trail_red", effect_duration, start_offset, end_offset);
										
						start_offset[2] += 12.5;
						end_offset[2] += 12.5;
					}
				}
				else
				{
					fl_teleport_timer[npc.index]= GameTime+5.0;	//retry in 5 seconds
					if(g_b_angered && !b_schwert_is_ally[npc.index])
					{
						npc.m_flMeleeArmor = 1.0;
					}
					else
					{
						npc.m_flMeleeArmor = 1.5;
					}
				}
			}
		}
		else
		{
			fl_teleport_timer[npc.index]= GameTime+1.0;	//retry in 1 second
			if(g_b_angered && !b_schwert_is_ally[npc.index])
			{
				npc.m_flMeleeArmor = 1.0;
			}
			else
			{
				npc.m_flMeleeArmor = 1.5;
			}
		}
	}
	if(npc.m_flDoingAnimation > GameTime)
	{
		npc.m_flSpeed = 0.0;
	}
	else
	{
		if(g_b_angered && !b_schwert_is_ally[npc.index])
			npc.m_flSpeed = Schwertkrieg_Speed*1.35;
		else
			npc.m_flSpeed = Schwertkrieg_Speed;
	}
}
static void Schwertkrieg_Teleport_Boom(int iNPC, float vecTarget[3], float pos[3])
{

	Schwertkrieg npc = view_as<Schwertkrieg>(iNPC);
	int color[4];
	color[0] = 145;
	color[1] = 47;
	color[2] = 47;
	color[3] = 255;
			
	int SPRITE_INT = PrecacheModel("materials/sprites/laserbeam.vmt", false);
	int SPRITE_INT_2 = PrecacheModel("materials/sprites/lgtning.vmt", false);

	pos[2]+=45.0;
	vecTarget[2]+=45.0;
	TE_SetupBeamPoints(vecTarget, pos, SPRITE_INT, 0, 0, 0, 0.8, 14.0, 10.2, 1, 1.0, color, 0);
	TE_SendToAll();
	TE_SetupBeamPoints(vecTarget, pos, SPRITE_INT_2, 0, 0, 0, 0.8, 22.0, 10.2, 1, 8.0, color, 0);
	TE_SendToAll();
	TE_SetupBeamPoints(vecTarget, pos, SPRITE_INT_2, 0, 0, 0, 0.8, 22.0, 10.2, 1, 8.0, color, 0);

	EmitSoundToAll(TELEPORT_STRIKE_TELEPORT, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vecTarget);
	EmitSoundToAll(TELEPORT_STRIKE_TELEPORT, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);

	vecTarget[2]-=45.0;
	Handle pack;
	CreateDataTimer(TELEPORT_STRIKE_Smite_ChargeSpan, TELEPORT_STRIKE_Smite_Timer, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	WritePackCell(pack, EntRefToEntIndex(npc.index));
	WritePackFloat(pack, 0.0);
	WritePackFloat(pack, vecTarget[0]);
	WritePackFloat(pack, vecTarget[1]);
	WritePackFloat(pack, vecTarget[2]);
	WritePackFloat(pack, TELEPORT_STRIKE_Smite_BaseDMG);
				
	TELEPORT_STRIKE_spawnBeam(0.8, 145, 47, 47, 255, "materials/sprites/lgtning.vmt", 8.0, 8.2, _, 5.0, pos, vecTarget);
	//TELEPORT_STRIKE_spawnBeam(320.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 0, 255, 120, 255, 1, TELEPORT_STRIKE_Smite_ChargeTime, 4.0, 0.1, 1, 1.0);
	float radius = TELEPORT_STRIKE_Smite_Radius;
	if(g_b_angered && !b_schwert_is_ally[npc.index])
	{
		radius *= 1.25;
	}
	TELEPORT_STRIKE_spawnRing_Vectors(vecTarget, radius * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 145, 47, 47, 255, 1, TELEPORT_STRIKE_Smite_ChargeTime, 6.0, 0.1, 1, 1.0);
					
}
static Action Internal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Schwertkrieg npc = view_as<Schwertkrieg>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	int Health = GetEntProp(npc.index, Prop_Data, "m_iHealth");	//npc becomes imortal when at 1 hp and when its a valid wave	//warp_item
	if(RoundToCeil(damage)>=Health && ZR_GetWaveCount()+1>=60.0 && i_RaidGrantExtra[npc.index] == 1)
	{
		if(g_b_item_allowed)
		{
			b_DoNotUnStuck[npc.index] = true;
			b_CantCollidieAlly[npc.index] = true;
			b_CantCollidie[npc.index] = true;
			SetEntityCollisionGroup(npc.index, 24);
			b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true; //Make allied npcs ignore him
			b_NpcIsInvulnerable[npc.index] = true;
			RemoveNpcFromEnemyList(npc.index);
			GiveProgressDelay(20.0);
			SetEntProp(npc.index, Prop_Data, "m_iHealth", 1);
			damage = 0.0;
		}
		if(!g_b_schwert_died)
		{
			g_b_angered=true;
			g_b_schwert_died=true;
			if(EntRefToEntIndex(RaidBossActive)==npc.index)
				RaidBossActive = INVALID_ENT_REFERENCE;
			RaidModeTime += 22.5;
			npc.m_bThisNpcIsABoss = false;
			g_f_blitz_dialogue_timesincehasbeenhurt = GetGameTime(npc.index)+20.0;
		}
		return Plugin_Handled;
	}
	
	return Plugin_Changed;
}

static void Internal_NPCDeath(int entity)
{
	Schwertkrieg npc = view_as<Schwertkrieg>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = false;
	b_NpcIsInvulnerable[npc.index] = false;
			
	npc.m_bThisNpcIsABoss = false;

	if(EntRefToEntIndex(RaidBossActive)==npc.index)
	{
		RaidBossActive = INVALID_ENT_REFERENCE;
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
}

public Action TELEPORT_STRIKE_Smite_Timer(Handle Smite_Logic, DataPack pack)
{
	//int iNPC;
	//DoktorMedick npc = view_as<DoktorMedick>(iNPC);
	ResetPack(pack);
	int entity = EntRefToEntIndex(ReadPackCell(pack));
	
	if(!IsValidEntity(entity))
	{
		return Plugin_Stop;
	}
	
	float NumLoops = ReadPackFloat(pack);
	float spawnLoc[3];
	for(int GetVector = 0; GetVector < 3; GetVector++)
	{
		spawnLoc[GetVector] = ReadPackFloat(pack);
	}
	
	float damage = ReadPackFloat(pack);
	
	if(NumLoops >= TELEPORT_STRIKE_Smite_ChargeTime)
	{
		float secondLoc[3];
		for (int replace = 0; replace < 3; replace++)
		{
			secondLoc[replace] = spawnLoc[replace];
		}
		
		for (int sequential = 1; sequential <= 5; sequential++)
		{
			TELEPORT_STRIKE_spawnRing_Vectors(secondLoc, 1.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 145, 47, 47, 255, 1, 0.33, 6.0, 0.4, 1, (TELEPORT_STRIKE_Smite_Radius * 5.0)/float(sequential));
			secondLoc[2] += 150.0 + (float(sequential) * 20.0);
		}
		
		//secondLoc[2] = 9999.0;
		secondLoc[2] = 1500.0;
		
		TELEPORT_STRIKE_spawnBeam(0.8, 145, 47, 47, 255, "materials/sprites/laserbeam.vmt", 16.0, 16.2, _, 5.0, secondLoc, spawnLoc);	
		TELEPORT_STRIKE_spawnBeam(0.8, 145, 47, 47, 255, "materials/sprites/lgtning.vmt", 10.0, 10.2, _, 5.0, secondLoc, spawnLoc);	
		TELEPORT_STRIKE_spawnBeam(0.8, 145, 47, 47, 255, "materials/sprites/lgtning.vmt", 10.0, 10.2, _, 5.0, secondLoc, spawnLoc);
		EmitAmbientSound(TELEPORT_STRIKE_HIT, spawnLoc, _, 240);
		EmitAmbientSound(TELEPORT_STRIKE_HIT, spawnLoc, _, 240);
		
		EmitAmbientSound("misc/halloween/spell_mirv_explode_primary.wav", spawnLoc, _, 120);
		
		
		//int target = TR_GetEntityIndex(npc.m_iTarget);	
		//if(target > 0) 
		//{
		//	if(target <= MaxClients)
		//	{
		//		EmitAmbientSound(TELEPORT_STRIKE_HIT, spawnLoc, _, 120);
		//		EmitAmbientSound(TELEPORT_STRIKE_HIT, spawnLoc, _, 120);
		//	}
		//} 
		//else
		//{
		//	EmitAmbientSound(TELEPORT_STRIKE_MISS, spawnLoc, _, 120);
		//	EmitAmbientSound(TELEPORT_STRIKE_MISS, spawnLoc, _, 120);
		//}
		
		DataPack pack_boom = new DataPack();
		pack_boom.WriteFloat(spawnLoc[0]);
		pack_boom.WriteFloat(spawnLoc[1]);
		pack_boom.WriteFloat(spawnLoc[2]);
		pack_boom.WriteCell(0);
		RequestFrame(MakeExplosionFrameLater, pack_boom);
		
		float radius = TELEPORT_STRIKE_Smite_Radius;
		if(g_b_angered)
		{
			damage *= 1.35;
			radius *= 1.25;
		}
		Explode_Logic_Custom(damage, entity, entity, -1, spawnLoc, radius,_,0.8, true);
		
		return Plugin_Stop;
	}
	else
	{
		
		float radius = TELEPORT_STRIKE_Smite_Radius;
		if(g_b_angered)
		{
			radius *= 1.25;
		}
		
		TELEPORT_STRIKE_spawnRing_Vectors(spawnLoc, radius * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 145, 47, 47, 255, 1, 0.33, 6.0, 0.1, 1, 1.0);
		EmitAmbientSound(TELEPORT_STRIKE_EXPLOSION, spawnLoc, _, 120, _, _, GetRandomInt(80, 110));
		EmitAmbientSound(TELEPORT_STRIKE_EXPLOSION, spawnLoc, _, 120, _, _, GetRandomInt(80, 110));
		
		ResetPack(pack);
		WritePackCell(pack, EntIndexToEntRef(entity));
		WritePackFloat(pack, NumLoops + TELEPORT_STRIKE_Smite_ChargeSpan);
		WritePackFloat(pack, spawnLoc[0]);
		WritePackFloat(pack, spawnLoc[1]);
		WritePackFloat(pack, spawnLoc[2]);
		WritePackFloat(pack, damage);
	}
	
	return Plugin_Continue;
}

static void TELEPORT_STRIKE_spawnBeam(float beamTiming, int r, int g, int b, int a, char sprite[PLATFORM_MAX_PATH], float width=2.0, float endwidth=2.0, int fadelength=1, float amp=15.0, float startLoc[3] = {0.0, 0.0, 0.0}, float endLoc[3] = {0.0, 0.0, 0.0})
{
	int color[4];
	color[0] = r;
	color[1] = g;
	color[2] = b;
	color[3] = a;
	
	int SPRITE_INT = PrecacheModel(sprite, false);

	TE_SetupBeamPoints(startLoc, endLoc, SPRITE_INT, 0, 0, 0, beamTiming, width, endwidth, fadelength, amp, color, 0);
	
	TE_SendToAll();
}

static void TELEPORT_STRIKE_spawnRing_Vectors(float center[3], float range, float modif_X, float modif_Y, float modif_Z, char sprite[255], int r, int g, int b, int alpha, int fps, float life, float width, float amp, int speed, float endRange = -69.0) //Spawns a TE beam ring at a client's/entity's location
{
	center[0] += modif_X;
	center[1] += modif_Y;
	center[2] += modif_Z;
	
	int ICE_INT = PrecacheModel(sprite);
	
	int color[4];
	color[0] = r;
	color[1] = g;
	color[2] = b;
	color[3] = alpha;
	
	if (endRange == -69.0)
	{
		endRange = range + 0.5;
	}
	
	TE_SetupBeamRingPoint(center, range, endRange, ICE_INT, ICE_INT, 0, fps, life, width, amp, color, speed, 0);
	TE_SendToAll();
}
static void Schwert_Teleport_Effect(char type[255], float duration = 0.0, float start_point[3], float end_point[3])
{
	int part1 = CreateEntityByName("info_particle_system");
	if(IsValidEdict(part1))
	{
		TeleportEntity(part1, start_point, NULL_VECTOR, NULL_VECTOR);
		DispatchKeyValue(part1, "effect_name", type);
		SetVariantString("!activator");
		DispatchSpawn(part1);
		ActivateEntity(part1);
		AcceptEntityInput(part1, "Start");
		
		DataPack pack;
		CreateDataTimer(0.1, Schwert_Timer_Move_Particle, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(EntIndexToEntRef(part1));
		pack.WriteCell(end_point[0]);
		pack.WriteCell(end_point[1]);
		pack.WriteCell(end_point[2]);
		pack.WriteCell(duration);
	}
}
static Action Schwert_Timer_Move_Particle(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	float end_point[3];
	end_point[0] = pack.ReadCell();
	end_point[1] = pack.ReadCell();
	end_point[2] = pack.ReadCell();
	float duration = pack.ReadCell();
	
	if(IsValidEntity(entity) && entity > MaxClients)
	{
		TeleportEntity(entity, end_point, NULL_VECTOR, NULL_VECTOR);
		if (duration > 0.0)
		{
			CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	return Plugin_Continue;
}