#pragma semicolon 1
#pragma newdecls required

#define IRENE_BOSS_RANGE 400.0
#define IRENE_EXPLOSIVES 150.0
bool Irene_CurrentEnemyVictimised[MAXENTITIES];
bool Irene_TargetsFound;



static const char g_DeathSounds[][] = {
	"weapons/rescue_ranger_teleport_receive_01.wav",
	"weapons/rescue_ranger_teleport_receive_02.wav",
};

static const char g_HurtSounds[][] = {
	"vo/spy_painsharp01.mp3",
	"vo/spy_painsharp02.mp3",
	"vo/spy_painsharp03.mp3",
	"vo/spy_painsharp04.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/spy_battlecry01.mp3",
	"vo/spy_battlecry02.mp3",
	"vo/spy_battlecry03.mp3",
	"vo/spy_battlecry04.mp3",
};

static const char g_RangedAttackSounds[][] = {
	"weapons/diamond_back_01.wav",
	"weapons/diamond_back_02.wav",
	"weapons/diamond_back_03.wav"
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/knife_swing.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/blade_hit1.wav",
	"weapons/blade_hit2.wav",
	"weapons/blade_hit3.wav",
	"weapons/blade_hit4.wav",
};
void Iberia_inqusitor_irene_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds)); i++) { PrecacheSound(g_RangedAttackSounds[i]); }
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Inquisitor Irene");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_inqusitor_irene");
	strcopy(data.Icon, sizeof(data.Icon), "judgement");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_IberiaExpiAlliance;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Iberiainqusitor_irene(vecPos, vecAng, team);
}
methodmap Iberiainqusitor_irene < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 110);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 110);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 110);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	property int i_GunMode
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}
	property float m_flAirTimeAbilityCD
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flAirTimeAbilityHappening
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flAirTimeAbilityHappeningDelay
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	
	
	public Iberiainqusitor_irene(float vecPos[3], float vecAng[3], int ally)
	{
		Iberiainqusitor_irene npc = view_as<Iberiainqusitor_irene>(CClotBody(vecPos, vecAng, "models/player/spy.mdl", "1.0", "1000000", ally));
		
		i_NpcWeight[npc.index] = 4;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("ACT_MP_RUN_MELEE");
		npc.m_iChanged_WalkCycle = 2;
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(Iberiainqusitor_irene_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Iberiainqusitor_irene_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Iberiainqusitor_irene_ClotThink);
		npc.i_GunMode = 0;
		Zero(b_said_player_weaponline);
		fl_said_player_weaponline_time[npc.index] = GetGameTime() + GetRandomFloat(0.0, 5.0);
		
		
		
		npc.StartPathing();
		npc.m_flSpeed = 345.0;
		npc.m_iAttacksTillReload = 0;
		npc.m_flAirTimeAbilityCD = GetGameTime() + 15.0;
		if(!IsValidEntity(RaidBossActive) || (IsValidEntity(RaidBossActive) && LighthouseGlobaID() == i_NpcInternalId[EntRefToEntIndex(RaidBossActive)]))
		{
			RaidModeScaling = 0.0;	//just a safety net
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidModeTime = GetGameTime(npc.index) + 9000.0;
			RaidAllowsBuildings = true;
		}
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
	
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/soldier/sf14_the_supernatural_stalker/sf14_the_supernatural_stalker.mdl");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/spy/hwn2022_turncoat/hwn2022_turncoat.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_xms_cold_shoulder/c_xms_cold_shoulder.mdl");
		SetVariantString("2.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/all_class/angsty_hood/angsty_hood_spy.mdl");
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/scout/bonk_mask/bonk_mask.mdl");
		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/soldier/sf14_ghoul_gibbing_gear/sf14_ghoul_gibbing_gear.mdl");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.m_iWearable5, 125, 0, 125, 255);

		return npc;
	}
}

public void Iberiainqusitor_irene_ClotThink(int iNPC)
{
	Iberiainqusitor_irene npc = view_as<Iberiainqusitor_irene>(iNPC);
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
	if(Irene_AbilityAir(npc))
	{
		return;
	}

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
		int ActionDo = Iberiainqusitor_ireneSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
		switch(ActionDo)
		{
			case 0:
			{
				npc.StartPathing();
				//We run at them.
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
				npc.m_flSpeed = 345.0;
				npc.m_bAllowBackWalking = false;
			}
			case 1:
			{
				npc.m_bAllowBackWalking = true;
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget,_,vBackoffPos);
				npc.SetGoalVector(vBackoffPos, true); //update more often, we need it
				npc.m_flSpeed = 300.0;
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

public Action Iberiainqusitor_irene_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Iberiainqusitor_irene npc = view_as<Iberiainqusitor_irene>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	Irene_Weapon_Lines(npc, attacker);
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void Iberiainqusitor_irene_NPCDeath(int entity)
{
	Iberiainqusitor_irene npc = view_as<Iberiainqusitor_irene>(entity);
	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
	ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
	npc.PlayDeathSound();	
	npc.m_bDissapearOnDeath = true;
	CPrintToChatAll("{snow}아이린{default}: 저희가 정말 죽는것처럼 보이셨나요? 저희는 그저 그렇게 보이도록 연기하고 있을 뿐이랍니다. 걱정하지 마시길.");
		
	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
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

int Iberiainqusitor_ireneSelfDefense(Iberiainqusitor_irene npc, float gameTime, int target, float distance)
{
	if(npc.m_flAirTimeAbilityCD < gameTime)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 3.5))
		{
			if(npc.m_iChanged_WalkCycle != 9)
			{
				if(IsValidEntity(npc.m_iWearable3))
					RemoveEntity(npc.m_iWearable3);

				npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_xms_cold_shoulder/c_xms_cold_shoulder.mdl");
				npc.m_bisWalking = false;
				npc.m_iChanged_WalkCycle = 9;
				npc.SetActivity("ACT_MP_CROUCH_MELEE");
				npc.StopPathing();
				npc.m_flSpeed = 0.0;
			}	
			EmitSoundToAll("mvm/mvm_cpoint_klaxon.wav", npc.index, _, 90, _, 0.85);
			npc.m_flAirTimeAbilityCD = gameTime + 20.0;
			float DurationOfBlink = 1.5;
			npc.m_flAirTimeAbilityHappening = gameTime + DurationOfBlink;
			Irene_TargetsFound = false;
			float NewPos[3]; 
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", NewPos);
			NewPos[2] += 10.0;
			spawnRing_Vectors(NewPos, 1.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 125, 125, 125, 200, 1, DurationOfBlink, 2.0, 2.0, 2, IRENE_BOSS_RANGE * 2.0);
			spawnRing_Vectors(NewPos, IRENE_BOSS_RANGE * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 125, 125, 125, 200, 1, DurationOfBlink, 2.0, 2.0, 2);
			
			return 2;
		}
	}
	if(npc.i_GunMode == 0 && npc.m_iAttacksTillReload >= 1)
	{
		if(npc.m_iChanged_WalkCycle != 1)
		{
			if(IsValidEntity(npc.m_iWearable3))
				RemoveEntity(npc.m_iWearable3);

			npc.m_iWearable3 = npc.EquipItem("head", "models/workshop_partner/weapons/c_models/c_dex_revolver/c_dex_revolver.mdl");
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 1;
			npc.SetActivity("ACT_MP_RUN_SECONDARY");
			npc.StartPathing();
		}	
		npc.Anger = false;

		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 3.5))
		{
			if(npc.m_flNextMeleeAttack < GetGameTime(npc.index))
			{
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				
				if(IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY", false);
					npc.m_iTarget = Enemy_I_See;
					npc.PlayRangedSound();
					float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
					npc.FaceTowards(vecTarget, 20000.0);
					Handle swingTrace;
					if(npc.DoSwingTrace(swingTrace, target, { 9999.0, 9999.0, 9999.0 }))
					{
						target = TR_GetEntityIndex(swingTrace);	
							
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);
						float origin[3], angles[3];
						view_as<CClotBody>(npc.m_iWearable3).GetAttachment("muzzle", origin, angles);
						ShootLaser(npc.m_iWearable3, "bullet_tracer02_blue", origin, vecHit, false );
						npc.m_flNextMeleeAttack = gameTime + 0.75;
						npc.m_iAttacksTillReload --;
						if(NpcStats_IberiaIsEnemyMarked(target))
						{
							npc.m_flNextMeleeAttack = gameTime + 0.2;
						}

						if(IsValidEnemy(npc.index, target))
						{
							float damageDealt = 125.5;
							if(ShouldNpcDealBonusDamage(target))
								damageDealt *= 6.5;


							SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, vecHit);
						}
					}
					delete swingTrace;
				}
				else
				{
					//cant see.
					return 0;
				}
			}
		}
		else
		{
			//too far away.
			return 0;
		}
		//they have more then 1 bullet, use gunmode.
		//Do backoff code, but only on wave 16+
		return 1;
	}
	//we use our melee.
	if(npc.m_iChanged_WalkCycle != 2)
	{
		if(IsValidEntity(npc.m_iWearable3))
			RemoveEntity(npc.m_iWearable3);

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_xms_cold_shoulder/c_xms_cold_shoulder.mdl");
		npc.m_bisWalking = true;
		npc.m_iChanged_WalkCycle = 2;
		npc.SetActivity("ACT_MP_RUN_MELEE");
		npc.StartPathing();
	}	
	
	if(npc.m_flDoingAnimation < gameTime)
	{
		if(IsValidEntity(npc.m_iWearable3))
		{
			if(!npc.Anger)
			{
				IgniteTargetEffect(npc.m_iWearable3);
				npc.Anger = true;
			}
		}
	}
	else
	{
		if(IsValidEntity(npc.m_iWearable3))
		{
			if(npc.Anger)
			{
				ExtinguishTarget(npc.m_iWearable3);
				npc.Anger = false;
			}
		}
	}
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget))
			{	
				target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				npc.m_flNextMeleeAttack = gameTime + 0.5;
				
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 400.0;
					
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 10.0;

					int DamageType = DMG_CLUB;
					if(!NpcStats_IsEnemySilenced(npc.index))
						DamageType |= DMG_PREVENT_PHYSICS_FORCE;

					//prevents knockback!
					//gimic of new wavetype, but silenceable.
					
					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DamageType, -1, _, vecHit);
					npc.m_iAttacksTillReload += 3;

					bool DoEffect = false;
					if(npc.i_GunMode == 2 && npc.m_flDoingAnimation < gameTime)
					{
						if(target <= MaxClients)
						{
							vecHit[0] = 0.0;
							vecHit[1] = 0.0;
							vecHit[2] = 500.0;
							TeleportEntity(target, _, _, vecHit, true);
							EmitSoundToAll("mvm/giant_soldier/giant_soldier_rocket_shoot.wav", target, _, 75, _, 0.60);
							DoEffect = true;
						}
						else if(!b_NpcHasDied[target])
						{
							if(!HasSpecificBuff(target, "Solid Stance"))
							{
								FreezeNpcInTime(target, 2.0);
								
								WorldSpaceCenter(target, vecHit);
								vecHit[2] += 250.0; //Jump up.
								PluginBot_Jump(target, vecHit);
								EmitSoundToAll("mvm/giant_soldier/giant_soldier_rocket_shoot.wav", target, _, 75, _, 0.60);
								DoEffect = true;
							}
						}
						if(DoEffect)
						{
							npc.m_flDoingAnimation = gameTime + 10.0;
							float NewPos[3]; 
							GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", NewPos);
							spawnRing_Vectors(NewPos, 50.0 * 2.0, 0.0, 0.0, 10.0, "materials/sprites/laserbeam.vmt", 200, 200, 200, 200, 1, 0.5, 8.0, 8.0, 2);
							spawnRing_Vectors(NewPos, 50.0 * 2.0, 0.0, 0.0, 15.0, "materials/sprites/laserbeam.vmt", 200, 200, 200, 200, 1, 0.5, 8.0, 8.0, 2);
							spawnRing_Vectors(NewPos, 50.0 * 2.0, 0.0, 0.0, 20.0, "materials/sprites/laserbeam.vmt", 200, 200, 200, 200, 1, 0.5, 8.0, 8.0, 2);
							ApplyStatusEffect(npc.index, target, "Marked", 15.0);
						}
						
					}
					// Hit sound
					npc.PlayMeleeHitSound();
				} 
			}
			delete swingTrace;
			if(npc.i_GunMode == 1)
				npc.m_flNextMeleeAttack = gameTime;
			else if(npc.i_GunMode == 2)
				npc.i_GunMode = 0;
		}
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED)  || npc.i_GunMode == 1)
		{
			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				if(npc.i_GunMode == 0)
				{
					npc.i_GunMode = 1;
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE",_,_,_,2.5);
					npc.m_flAttackHappens = gameTime;
				}
				else if(npc.i_GunMode == 1)
				{
					npc.i_GunMode = 2;
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE",_,_,_,0.75);	
					npc.m_flAttackHappens = gameTime + 0.2;
				}				
				npc.m_flNextMeleeAttack = gameTime + 1.2;
			}
		}
	}
	return 0;
}

bool Irene_AbilityAir(Iberiainqusitor_irene npc)
{
	if(npc.m_flAirTimeAbilityHappening)
	{
		if(Irene_TargetsFound)
		{
			if(npc.m_flAirTimeAbilityHappeningDelay < GetGameTime(npc.index))
			{
				//we have found targets, KILL THEM!
				float origin[3], angles[3];
				view_as<CClotBody>(npc.m_iWearable3).GetAttachment("muzzle", origin, angles);
				int color[4];
				color[0] = 255;
				color[1] = 255;
				color[2] = 255;
				color[3] = 255;
				float amp = 0.3;
				float life = 0.1;	
				float damageDealBoom = 350.0;	
				for(int EnemyLoop; EnemyLoop < MAXENTITIES; EnemyLoop ++)
				{
					if(Irene_CurrentEnemyVictimised[EnemyLoop] && IsValidEnemy(npc.index, EnemyLoop))
					{
						float vecHit[3];
						WorldSpaceCenter(EnemyLoop, vecHit);
						SpawnSmallExplosion(vecHit);
						//Reuse terroriser stuff for now.
						switch(GetRandomInt(1, 2))
						{
							case 1:
							{
								EmitSoundToAll("mvm/giant_common/giant_common_explodes_01.wav", EnemyLoop, _, 85, _, 0.2);
							}
							case 2:
							{
								EmitSoundToAll("mvm/giant_common/giant_common_explodes_02.wav", EnemyLoop, _, 85, _, 0.2);
							}
						}
						TE_SetupBeamPoints(origin, vecHit, IreneReturnLaserSprite(), 0, 0, 0, life, 1.0, 1.2, 1, amp, color, 0);
						TE_SendToAll();

						spawnRing_Vectors(vecHit, 0.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 255, 255, 200, 1, 0.25, 12.0, 6.1, 1, IRENE_EXPLOSIVES);	
						Explode_Logic_Custom(damageDealBoom, 0, npc.index, -1, vecHit, IRENE_EXPLOSIVES,_,_,false);	
					}					
				}
				npc.m_flAirTimeAbilityHappeningDelay = GetGameTime(npc.index) + 0.15;
			}

			if(npc.m_flAirTimeAbilityHappening < GetGameTime(npc.index))
			{
				npc.m_flAirTimeAbilityHappening = 0.0;
			}
			return true;
		}
		if(npc.m_flAirTimeAbilityHappening < GetGameTime(npc.index))
		{
			Irene_TargetsFound = false;
			
			EmitSoundToAll("mvm/giant_soldier/giant_soldier_rocket_shoot.wav", npc.index, _, 90, _, 0.85);
			Zero(Irene_CurrentEnemyVictimised);
			float DamageDeal = 400.0;
			float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
			spawnRing_Vectors(pos, IRENE_BOSS_RANGE * 2.0, 0.0, 0.0, 10.0, "materials/sprites/laserbeam.vmt", 200, 200, 200, 200, 1, 0.5, 12.0, 10.0, 2);
			spawnRing_Vectors(pos, IRENE_BOSS_RANGE * 2.0, 0.0, 0.0, 15.0, "materials/sprites/laserbeam.vmt", 200, 200, 200, 200, 1, 0.5, 12.0, 10.0, 2);
			spawnRing_Vectors(pos, IRENE_BOSS_RANGE * 2.0, 0.0, 0.0, 20.0, "materials/sprites/laserbeam.vmt", 200, 200, 200, 200, 1, 0.5, 12.0, 10.0, 2);
			Explode_Logic_Custom(DamageDeal, 0, npc.index, -1, _, IRENE_BOSS_RANGE, 1.0, _, true, 20,_,_,_,Irene_AirExploder);
			if(!Irene_TargetsFound)
			{
				npc.m_flAirTimeAbilityHappening = 0.0;
				CPrintToChatAll("{snow}아이린{default}: ...");
			}
			else
			{
				switch(GetRandomInt(0,3))
				{
					case 0:
					{
						CPrintToChatAll("{snow}아이린{default}: 내 검이 파도를 가르리라!");
					}
					case 1:
					{
						CPrintToChatAll("{snow}아이린{default}: 내 빛이 악을 씻어내리니!");
					}
					case 2:
					{
						CPrintToChatAll("{snow}아이린{default}: 내 눈이 정의를 찾아내리라!");
					}
					case 3:
					{
						CPrintToChatAll("{snow}아이린{default}: 나의 판단은 틀리지 않으리!");
					}
				}
				npc.m_flAirTimeAbilityHappening = GetGameTime(npc.index) + 2.0;
				npc.m_flAirTimeAbilityHappeningDelay = GetGameTime(npc.index) + 0.5;
				if(npc.m_iChanged_WalkCycle != 11)
				{
					if(IsValidEntity(npc.m_iWearable3))
						RemoveEntity(npc.m_iWearable3);

					npc.m_iWearable3 = npc.EquipItem("head", "models/workshop_partner/weapons/c_models/c_dex_revolver/c_dex_revolver.mdl");
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 11;
					npc.SetActivity("ACT_MP_CROUCH_SECONDARY");
					npc.StopPathing();
					npc.m_flSpeed = 0.0;
				}	
			}
		}
		
		return true;
	}
	return false;
}

float Irene_AirExploder(int entity, int victim, float damage, int weapon)
{
	Irene_TargetsFound = true;
	//Knock target up
	if(NpcStats_IberiaIsEnemyMarked(victim))
	{
		damage *= 2.5;
	}
	if(b_ThisWasAnNpc[victim])
		PluginBot_Jump(victim, {0.0,0.0,1000.0});
	else
		TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, {0.0,0.0,1000.0});

	ApplyStatusEffect(entity, victim, "Marked", 20.0);
	Irene_CurrentEnemyVictimised[victim] = true;
	return damage;
}



static void Irene_Weapon_Lines(Iberiainqusitor_irene npc, int client)
{
	if(client > MaxClients)
		return;

	if(b_said_player_weaponline[client])	//only 1 line per player.
		return;

	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

	if(!IsValidEntity(weapon))	//invalid weapon, go back and get a valid one you <...>
		return;

	float GameTime = GetGameTime();	//no need to throttle this.

	if(fl_said_player_weaponline_time[npc.index] > GameTime)	//no spamming in chat please!
		return;

	bool valid = true;
	char Text_Lines[255];

	Text_Lines = "";

	switch(i_CustomWeaponEquipLogic[weapon])
	{
		case WEAPON_IRENE:
		{
			switch(GetRandomInt(0,3))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "똑같은 무기를 쓰는 자와의 대결이라니, 기대되는군요, {gold}%N{default}!",client);
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{crimson}리란{default}에게서 가르침을 받으셨군요, {gold}%N{default}.",client);
				case 2:
					Format(Text_Lines, sizeof(Text_Lines), "{crimson}리란{default}의 유산이 우리를 더욱 밝게 비춰줄 것입니다, {gold}%N{default}!",client);
				case 3:
					Format(Text_Lines, sizeof(Text_Lines), "{crimson}리란{default}이 못 다한 시본 청소를 우리가 해내봅시다, {gold}%N{default}!",client);
			}
		}

		default:
		{
			valid = false;
		}
	}

	if(valid)
	{
		CPrintToChatAll("{snow}Irene{default}: %s", Text_Lines);
		fl_said_player_weaponline_time[npc.index] = GameTime + GetRandomFloat(17.0, 26.0);
		b_said_player_weaponline[client] = true;
	}
}