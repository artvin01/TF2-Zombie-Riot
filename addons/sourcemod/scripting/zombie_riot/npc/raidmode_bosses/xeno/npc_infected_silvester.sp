#pragma semicolon 1
#pragma newdecls required


static char g_DeathSounds[][] = {
	"vo/medic_paincrticialdeath01.mp3",
	"vo/medic_paincrticialdeath02.mp3",
	"vo/medic_paincrticialdeath03.mp3",
};

static char g_HurtSounds[][] = {
	")vo/medic_painsharp01.mp3",
	")vo/medic_painsharp02.mp3",
	")vo/medic_painsharp03.mp3",
	")vo/medic_painsharp04.mp3",
	")vo/medic_painsharp05.mp3",
	")vo/medic_painsharp06.mp3",
	")vo/medic_painsharp07.mp3",
	")vo/medic_painsharp08.mp3",
};

static char g_IdleSounds[][] = {
	")vo/null.mp3",
};

static char g_IdleAlertedSounds[][] = {
	")vo/medic_battlecry01.mp3",
	")vo/medic_battlecry02.mp3",
	")vo/medic_battlecry03.mp3",
	")vo/medic_battlecry04.mp3",
};

static char g_MeleeHitSounds[][] = {
	"weapons/breadmonster/throwable/bm_throwable_smash.wav",
};

static char g_MeleeAttackSounds[][] = {
	")weapons/knife_swing.wav",
};

static char g_RangedAttackSounds[][] = {
	"weapons/breadmonster/throwable/bm_throwable_throw.wav",
};
static char g_TeleportSounds[][] = {
	"misc/halloween/spell_teleport.wav",
};

static char g_MeleeMissSounds[][] = {
	")weapons/cbar_miss1.wav",
};

static char g_AngerSounds[][] = {
	")vo/medic_hat_taunts04.mp3",
};

static char g_PullSounds[][] = {
	"weapons/physcannon/energy_sing_explosion2.wav"
};

#define LASERBEAM "sprites/laserbeam.vmt"

public void RaidbossSilvester_OnMapStart()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));       i++) { PrecacheSound(g_DeathSounds[i]);       }
	for (int i = 0; i < (sizeof(g_HurtSounds));        i++) { PrecacheSound(g_HurtSounds[i]);        }
	for (int i = 0; i < (sizeof(g_IdleSounds));        i++) { PrecacheSound(g_IdleSounds[i]);        }
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));    i++) { PrecacheSound(g_MeleeHitSounds[i]);    }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));    i++) { PrecacheSound(g_MeleeAttackSounds[i]);    }
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_TeleportSounds));   i++) { PrecacheSound(g_TeleportSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++) { PrecacheSound(g_RangedAttackSounds[i]);   }
	for (int i = 0; i < (sizeof(g_AngerSounds));   i++) { PrecacheSound(g_AngerSounds[i]);   }
	for (int i = 0; i < (sizeof(g_PullSounds));   i++) { PrecacheSound(g_PullSounds[i]);   }
	
	
	PrecacheSound("weapons/physcannon/superphys_launch1.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch2.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch3.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch4.wav", true);
	PrecacheSound("weapons/physcannon/energy_sing_loop4.wav", true);
	PrecacheSound("weapons/physcannon/physcannon_drop.wav", true);
	
	PrecacheSound("player/flow.wav");
}

#define EMPOWER_SOUND "items/powerup_pickup_king.wav"
#define EMPOWER_MATERIAL "materials/sprites/laserbeam.vmt"
#define EMPOWER_WIDTH 5.0
#define EMPOWER_HIGHT_OFFSET 20.0

static int i_TargetToWalkTo[MAXENTITIES];
static float f_TargetToWalkToDelay[MAXENTITIES];
static int i_LaserEntityIndex[MAXENTITIES]={-1, ...};

methodmap RaidbossSilvester < CClotBody
{
	public void PlayIdleSound(bool repeat = false) {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		int sound = GetRandomInt(0, sizeof(g_IdleSounds) - 1);
		
		EmitSoundToAll(g_IdleSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		
		DataPack pack;
		CreateDataTimer(0.1, Fusion_RepeatSound_Doublevoice, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteString(g_IdleSounds[sound]);
		pack.WriteCell(EntIndexToEntRef(this.index));
	
	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
			
		int sound = GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1);
		
		EmitSoundToAll(g_IdleAlertedSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		DataPack pack;
		CreateDataTimer(0.1, Fusion_RepeatSound_Doublevoice, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteString(g_IdleAlertedSounds[sound]);
		pack.WriteCell(EntIndexToEntRef(this.index));
	}
	
	public void PlayHurtSound() {
		
		int sound = GetRandomInt(0, sizeof(g_HurtSounds) - 1);

		EmitSoundToAll(g_HurtSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextHurtSound = GetGameTime(this.index) + GetRandomFloat(0.6, 1.6);
		
		DataPack pack;
		CreateDataTimer(0.1, Fusion_RepeatSound_Doublevoice, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteString(g_HurtSounds[sound]);
		pack.WriteCell(EntIndexToEntRef(this.index));
	}
	
	public void PlayDeathSound() {
		
		int sound = GetRandomInt(0, sizeof(g_DeathSounds) - 1);
		
		EmitSoundToAll(g_DeathSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		DataPack pack;
		CreateDataTimer(0.1, Fusion_RepeatSound_Doublevoice, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteString(g_DeathSounds[sound]);
		pack.WriteCell(EntIndexToEntRef(this.index));
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	
	public void PlayAngerSound() {
	
		int sound = GetRandomInt(0, sizeof(g_AngerSounds) - 1);
		EmitSoundToAll(g_AngerSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		DataPack pack;
		CreateDataTimer(0.1, Fusion_RepeatSound_Doublevoice, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteString(g_AngerSounds[sound]);
		pack.WriteCell(EntIndexToEntRef(this.index));
	}
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayRangedSound()");
		#endif
	}
	
	public void PlayPullSound() {
		EmitSoundToAll(g_PullSounds[GetRandomInt(0, sizeof(g_PullSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayPullSound()");
		#endif
	}
	
	
	public void PlayTeleportSound() {
		EmitSoundToAll(g_TeleportSounds[GetRandomInt(0, sizeof(g_TeleportSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayTeleportSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayMeleeMissSound()");
		#endif
	}
	public RaidbossSilvester(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		RaidbossSilvester npc = view_as<RaidbossSilvester>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.35", "25000", ally, false, true, true,true)); //giant!
		
		i_NpcInternalId[npc.index] = XENO_RAIDBOSS_SILVESTER;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		RaidBossActive = EntIndexToEntRef(npc.index);
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "item_armor", 1, "%t", "True Fusion Warrior Spawn");
			}
		}
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPSOUND_NORMAL;		
		
		npc.m_bThisNpcIsABoss = true;
		
		RaidModeTime = GetGameTime(npc.index) + 200.0;
		
		RaidModeScaling = float(ZR_GetWaveCount()+1);
		
		if(RaidModeScaling < 55)
		{
			RaidModeScaling *= 0.19; //abit low, inreacing
		}
		else
		{
			RaidModeScaling *= 0.38;
		}
		
		float amount_of_people = float(CountPlayersOnRed());
		
		amount_of_people *= 0.12;
		
		if(amount_of_people < 1.0)
			amount_of_people = 1.0;
			
		RaidModeScaling *= amount_of_people; //More then 9 and he raidboss gets some troubles, bufffffffff
		
		Raidboss_Clean_Everyone();
		
		SDKHook(npc.index, SDKHook_Think, RaidbossSilvester_ClotThink);
		SDKHook(npc.index, SDKHook_OnTakeDamage, RaidbossSilvester_ClotDamaged);
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/all_class/bak_buttler/bak_buttler_medic.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/medic/hwn_medic_hat.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/dec17_coldfront_carapace/dec17_coldfront_carapace.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/medic/sbxo2014_medic_wintergarb_coat/sbxo2014_medic_wintergarb_coat.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable5 = npc.EquipItem("head","models/workshop/player/items/medic/sf14_medic_kriegsmaschine_9000/sf14_medic_kriegsmaschine_9000.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", 1);


		npc.m_iWearable7 = npc.EquipItem("head","models/workshop/player/items/medic/cardiologists_camo/cardiologists_camo.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable7, "SetModelScale");
		SetEntProp(npc.m_iWearable7, Prop_Send, "m_nSkin", 1);

		
		float flPos[3]; // original
		float flAng[3]; // original
		npc.GetAttachment("head", flPos, flAng);
		npc.m_iWearable6 = ParticleEffectAt_Parent(flPos, "unusual_symbols_parent_lightning", npc.index, "head", {0.0,0.0,0.0});
		
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, 192, 192, 192, 255);
		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable2, 192, 192, 192, 255);
		SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable3, 192, 192, 192, 255);
		SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable4, 192, 192, 192, 255);
		SetEntityRenderMode(npc.m_iWearable5, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable5, 150, 150, 150, 255);
		
		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
			
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		SetVariantColor(view_as<int>({255, 255, 255, 200}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");

		Music_SetRaidMusic("#zombiesurvival/fusion_raid/fusion_bgm.mp3", 178, true);
		
		npc.Anger = false;
		//IDLE
		npc.m_flSpeed = 330.0;


		npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 5.0;
		npc.m_flNextRangedSpecialAttackHappens = 0.0;
		
		Citizen_MiniBossSpawn(npc.index);
		npc.StartPathing();
		
		return npc;
	}
}

//TODO 
//Rewrite
public void RaidbossSilvester_ClotThink(int iNPC)
{
	RaidbossSilvester npc = view_as<RaidbossSilvester>(iNPC);
	
	//Raidmode timer runs out, they lost.
	if(RaidModeTime < GetGameTime())
	{
		int entity = CreateEntityByName("game_round_win"); 
		DispatchKeyValue(entity, "force_map_reset", "1");
		SetEntProp(entity, Prop_Data, "m_iTeamNum", TFTeam_Blue);
		DispatchSpawn(entity);
		AcceptEntityInput(entity, "RoundWin");
		Music_RoundEnd(entity);
		RaidBossActive = INVALID_ENT_REFERENCE;
		SDKUnhook(npc.index, SDKHook_Think, RaidbossSilvester_ClotThink);
	}

	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;

	npc.Update();

	//Think throttling
	if(npc.m_flNextThinkTime > GetGameTime(npc.index)) 
	{
		return;
	}

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}
	
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.10;
	if(f_TargetToWalkToDelay[npc.index] < GetGameTime(npc.index))
	{
		i_TargetToWalkTo[npc.index] = GetClosestTarget(npc.index);
		f_TargetToWalkToDelay[npc.index] = GetGameTime(npc.index) + 1.0;
	}

	if(npc.m_flNextRangedSpecialAttackHappens)
	{
		spawnRing(npc.index, NORMAL_ENEMY_MELEE_RANGE_FLOAT * 3.0 * 2.0, 0.0, 0.0, EMPOWER_HIGHT_OFFSET, EMPOWER_MATERIAL, 231, 181, 59, 125, 10, 0.11, EMPOWER_WIDTH, 6.0, 10);
		
		for(int EnemyLoop; EnemyLoop < MaxClients; EnemyLoop ++)
		{
			if(IsValidEnemy(npc.index, EnemyLoop))
			{
				if(IsValidClient(EnemyLoop) && Can_I_See_Enemy_Only(npc.index, EnemyLoop))
				{
					if(!IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
					{
						int red = 212;
						int green = 155;
						int blue = 0;
						if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
						{
							RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
						}

						int laser;
						
						laser = ConnectWithBeam(npc.index, EnemyLoop, red, green, blue, 3.0, 3.0, 2.35, LASERBEAM);
			
						i_LaserEntityIndex[EnemyLoop] = EntIndexToEntRef(laser);
						//Im seeing a new target, relocate laser particle.
					}
				}
				else
				{
					if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
					{
						RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
					}
				}
			}
			else
			{
				if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
				{
					RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
				}						
			}
		}
		

		if(npc.m_flNextRangedSpecialAttackHappens < GetGameTime(npc.index))
		{
			npc.AddGesture("ACT_MP_GESTURE_VC_FISTPUMP_MELEE");
			npc.PlayPullSound();
			npc.DispatchParticleEffect(npc.index, "hammer_bell_ring_shockwave2", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("effect_hand_r"), PATTACH_POINT_FOLLOW, true);
			npc.m_flNextRangedSpecialAttackHappens = 0.0;
			static float victimPos[3];
			static float partnerPos[3];
			GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", partnerPos);
			for(int EnemyLoop; EnemyLoop < MaxClients; EnemyLoop ++)
			{
				if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
				{
					RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
				}	

				if(IsValidEnemy(npc.index, EnemyLoop))
				{
					if(IsValidClient(EnemyLoop) && Can_I_See_Enemy_Only(npc.index, EnemyLoop))
					{
						GetEntPropVector(EnemyLoop, Prop_Data, "m_vecAbsOrigin", victimPos); 
						float Distance = GetVectorDistance(victimPos, partnerPos);
						if(Distance > NORMAL_ENEMY_MELEE_RANGE_FLOAT * 3.0) //they are further away, pull them.
						{				
							static float angles[3];
							GetVectorAnglesTwoPoints(victimPos, partnerPos, angles);

							if (GetEntityFlags(EnemyLoop) & FL_ONGROUND)
								angles[0] = 0.0; // toss out pitch if on ground

							static float velocity[3];
							GetAngleVectors(angles, velocity, NULL_VECTOR, NULL_VECTOR);
							float attraction_intencity = 1.5;
							ScaleVector(velocity, Distance * attraction_intencity);
											
											
							// min Z if on ground
							if (GetEntityFlags(EnemyLoop) & FL_ONGROUND)
								velocity[2] = fmax(325.0, velocity[2]);
										
							// apply velocity
							TeleportEntity(EnemyLoop, NULL_VECTOR, NULL_VECTOR, velocity);       
						}
						else //they are too close, push them.
						{
							static float angles[3];
							GetVectorAnglesTwoPoints(victimPos, partnerPos, angles);

							if (GetEntityFlags(EnemyLoop) & FL_ONGROUND)
								angles[0] = 0.0; // toss out pitch if on ground

							static float velocity[3];
							GetAngleVectors(angles, velocity, NULL_VECTOR, NULL_VECTOR);
							float attraction_intencity = 1000.0;
							ScaleVector(velocity, attraction_intencity);
											
											
							// min Z if on ground
							if (GetEntityFlags(EnemyLoop) & FL_ONGROUND)
								velocity[2] = fmax(325.0, velocity[2]);
										
							// apply velocity
							velocity[0] *= -1.0;
							velocity[1] *= -1.0;
						//	velocity[2] *= -1.0;
							TeleportEntity(EnemyLoop, NULL_VECTOR, NULL_VECTOR, velocity);    
							RequestFrame(ApplySdkHookSilvesterThrow, EntIndexToEntRef(EnemyLoop));   					
						}
					}
				}
			}
		}
	}

	if(IsEntityAlive(i_TargetToWalkTo[npc.index]))
	{
		int ActionToTake = -1;

		//Predict their pos.
		float vecTarget[3]; vecTarget = WorldSpaceCenter(i_TargetToWalkTo[npc.index]);
		float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
		float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, i_TargetToWalkTo[npc.index]);
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			PF_SetGoalVector(npc.index, vPredictedPos);
		}
		else
		{
			PF_SetGoalEntity(npc.index, i_TargetToWalkTo[npc.index]);
		}

		if(npc.m_flDoingAnimation > GetGameTime(npc.index)) //I am doing an animation or doing something else, default to doing nothing!
		{
			ActionToTake= -1;
		}
		else if(IsValidEnemy(npc.index, i_TargetToWalkTo[npc.index]))
		{
			//Do i look at an enemy right now? or wish to target an enemy?
			if(flDistanceToTarget < Pow(1000.0, 2.0) && npc.m_flNextRangedSpecialAttack < GetGameTime(npc.index))
			{
				npc.AddGesture("ACT_MP_GESTURE_VC_FINGERPOINT_MELEE");
				float flPos[3]; // original
				float flAng[3]; // original
				GetAttachment(npc.index, "effect_hand_l", flPos, flAng);
				int particler = ParticleEffectAt(flPos, "raygun_projectile_blue_crit", 0.25);
				SetParent(npc.index, particler, "effect_hand_l");
				npc.m_flNextRangedSpecialAttackHappens = GetGameTime(npc.index) + 5.0;
				npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 10.0;
				//pull or push the target away!
				ActionToTake = 1;
			}
		}
		else
		{
			ActionToTake = 0;
		}




		switch(ActionToTake)
		{
			case 1:
			{
			//	return; //do nothing for now.
			}
			default:
			{
	//			return;
			}
		}
	}
	else
	{
		i_TargetToWalkTo[npc.index] = GetClosestTarget(npc.index);
		f_TargetToWalkToDelay[npc.index] = GetGameTime(npc.index) + 1.0;
	}
	//This is for self defense, incase an enemy is too close, This exists beacuse
	//Silvester's main walking target might not be the closest target he has.
	RaidbossSilvesterSelfDefense(npc,GetGameTime(npc.index)); 
}

	
public Action RaidbossSilvester_ClotDamaged(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	RaidbossSilvester npc = view_as<RaidbossSilvester>(victim);

	return Plugin_Changed;
}

public void RaidbossSilvester_NPCDeath(int entity)
{
	RaidbossSilvester npc = view_as<RaidbossSilvester>(entity);
	if(!npc.m_bDissapearOnDeath)
	{
		npc.PlayDeathSound();
	}
	SDKUnhook(npc.index, SDKHook_Think, RaidbossSilvester_ClotThink);
	SDKUnhook(npc.index, SDKHook_OnTakeDamage, RaidbossSilvester_ClotDamaged);
	
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
		
//	AcceptEntityInput(npc.index, "KillHierarchy");
//	npc.Anger = false;
	for(int EnemyLoop; EnemyLoop < MAXENTITIES; EnemyLoop ++)
	{
		if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
		{
			RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
		}						
	}
	Citizen_MiniBossDeath(entity);
}

void RaidbossSilvesterSelfDefense(RaidbossSilvester npc, float gameTime)
{
	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 1.0;
	}
	
	//This code is only here so they defend themselves incase any enemy is too close to them. otherwise it is completly disconnected from any other logic.

	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < GetGameTime(npc.index))
		{
			npc.m_flAttackHappens = 0.0;
			
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				Handle swingTrace;
				npc.FaceTowards(WorldSpaceCenter(npc.m_iTarget), 15000.0);
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 1)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
				{
								
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					
					if(target > 0) 
					{
						float damage = 24.0;
						float damage_rage = 28.0;
						if(ZR_GetWaveCount()+1 > 40 && ZR_GetWaveCount()+1 < 55)
						{
							damage = 20.0; //nerf
							damage_rage = 21.0; //nerf
						}
						else if(ZR_GetWaveCount()+1 > 55)
						{
							damage = 19.0; //nerf
							damage_rage = 20.0; //nerf
						}

						if(!npc.Anger)
							SDKHooks_TakeDamage(target, npc.index, npc.index, damage * RaidModeScaling, DMG_CLUB, -1, _, vecHit);
								
						if(npc.Anger)
							SDKHooks_TakeDamage(target, npc.index, npc.index, damage_rage * RaidModeScaling, DMG_CLUB, -1, _, vecHit);									
							
						
						// Hit particle
						
						
						// Hit sound
						npc.PlayMeleeHitSound();
						
						if(IsValidClient(target))
						{
							if (IsInvuln(target))
							{
								Custom_Knockback(npc.index, target, 900.0, true);
								TF2_AddCondition(target, TFCond_LostFooting, 0.5);
								TF2_AddCondition(target, TFCond_AirCurrent, 0.5);
							}
							else
							{
								Custom_Knockback(npc.index, target, 650.0); 
								TF2_AddCondition(target, TFCond_LostFooting, 0.5);
								TF2_AddCondition(target, TFCond_AirCurrent, 0.5);
							}
						}
					} 
				}
				delete swingTrace;
			}
		}
	}

	if(GetGameTime(npc.index) > npc.m_flNextMeleeAttack)
	{
		if(IsValidEnemy(npc.index, npc.m_iTarget)) 
		{
			float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);

			float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);

			if(flDistanceToTarget < Pow(NORMAL_ENEMY_MELEE_RANGE_FLOAT * 1.25, 2.0))
			{
				int Enemy_I_See;
									
				Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
						
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;

					npc.PlayMeleeSound();

					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
							
					npc.m_flAttackHappens = gameTime + 0.25;

					npc.m_flDoingAnimation = gameTime + 0.6;
					npc.m_flNextMeleeAttack = gameTime + 1.2;
				}
			}
		}
		else
		{
			npc.m_flGetClosestTargetTime = 0.0;
			npc.m_iTarget = GetClosestTarget(npc.index);
		}	
	}
}


static bool b_AlreadyHitTankThrow[MAXENTITIES][MAXENTITIES];
static float fl_ThrowDelay[MAXENTITIES];
public Action contact_throw_Silvester_entity(int client)
{
	CClotBody npc = view_as<CClotBody>(client);
	float targPos[3];
	float chargerPos[3];
	float flVel[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", flVel);
	if (npc.IsOnGround() && fl_ThrowDelay[client] < GetGameTime(npc.index))
	{
		for(int entity=1; entity <= MAXENTITIES; entity++)
		{
			b_AlreadyHitTankThrow[client][entity] = false;
		}

		SDKUnhook(client, SDKHook_Think, contact_throw_Silvester_entity);	
		return Plugin_Continue;
	}
	else
	{
		char classname[60];
		chargerPos = WorldSpaceCenter(client);
		for(int entity=1; entity <= MAXENTITIES; entity++)
		{
			if (IsValidEntity(entity) && !b_ThisEntityIgnored[entity])
			{
				GetEntityClassname(entity, classname, sizeof(classname));
				if (!StrContains(classname, "base_boss", true) || !StrContains(classname, "player", true) || !StrContains(classname, "obj_dispenser", true) || !StrContains(classname, "obj_sentrygun", true))
				{
					targPos = WorldSpaceCenter(entity);
					if (GetVectorDistance(chargerPos, targPos, true) <= Pow(125.0, 2.0) && GetEntProp(entity, Prop_Send, "m_iTeamNum")!=GetEntProp(client, Prop_Send, "m_iTeamNum"))
					{
						if (!b_AlreadyHitTankThrow[client][entity] && entity != client)
						{		
							int damage = GetEntProp(client, Prop_Data, "m_iMaxHealth") / 3;
							
							if(damage > 2000)
							{
								damage = 2000;
							}
							
							if(!ShouldNpcDealBonusDamage(entity))
							{
								damage *= 4;
							}
							
							SDKHooks_TakeDamage(entity, 0, 0, float(damage), DMG_GENERIC, -1, NULL_VECTOR, targPos);
							EmitSoundToAll("weapons/physcannon/energy_disintegrate5.wav", entity, SNDCHAN_STATIC, 80, _, 0.8);
							b_AlreadyHitTankThrow[client][entity] = true;
							if(entity <= MaxClients)
							{
								float newVel[3];
								
								newVel[0] = GetEntPropFloat(entity, Prop_Send, "m_vecVelocity[0]") * 2.0;
								newVel[1] = GetEntPropFloat(entity, Prop_Send, "m_vecVelocity[1]") * 2.0;
								newVel[2] = 500.0;
												
								for (int i = 0; i < 3; i++)
								{
									flVel[i] += newVel[i];
								}				
								TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, flVel); 
							}
						}
					}
				}
			}
		}
	}
	return Plugin_Continue;
}


void ApplySdkHookSilvesterThrow(int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
		fl_ThrowDelay[entity] = GetGameTime(entity) + 0.1;
		SDKHook(entity, SDKHook_Think, contact_throw_Silvester_entity);		
	}
}
