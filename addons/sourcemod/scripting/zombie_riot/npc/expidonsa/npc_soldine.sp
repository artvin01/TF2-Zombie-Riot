#pragma semicolon 1
#pragma newdecls required



#define SOLDINE_NORMAL_MOVESPEED 330.0

static const char g_DeathSounds[][] = {
	"vo/mvm/norm/soldier_mvm_paincrticialdeath01.mp3",
	"vo/mvm/norm/soldier_mvm_paincrticialdeath02.mp3",
	"vo/mvm/norm/soldier_mvm_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/mvm/norm/soldier_mvm_painsevere01.mp3",
	"vo/mvm/norm/soldier_mvm_painsevere02.mp3",
	"vo/mvm/norm/soldier_mvm_painsevere03.mp3",
	"vo/mvm/norm/soldier_mvm_painsevere04.mp3",
	"vo/mvm/norm/soldier_mvm_painsevere05.mp3",
	"vo/mvm/norm/soldier_mvm_painsevere06.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp01.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp02.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp03.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp04.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp05.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp06.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp07.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp08.mp3",
};


static const char g_IdleAlertedSounds[][] = {
	"vo/mvm/norm/taunts/soldier_mvm_taunts18.mp3",
	"vo/mvm/norm/taunts/soldier_mvm_taunts19.mp3",
	"vo/mvm/norm/taunts/soldier_mvm_taunts20.mp3",
	"vo/mvm/norm/taunts/soldier_mvm_taunts21.mp3",
};

static const char g_RangedAttackSounds[][] = {
	"weapons/airstrike_fire_01.wav",
	"weapons/airstrike_fire_02.wav",
	"weapons/airstrike_fire_03.wav",
};
static const char g_MeleeAttackSounds[][] = {
	"weapons/cbar_miss1.wav",
};
static const char g_MeleeHitSounds[][] = {
	"items/cart_explode.wav",
};

static const char g_HurtArmorSounds[][] = {
	")physics/metal/metal_box_impact_bullet1.wav",
	")physics/metal/metal_box_impact_bullet2.wav",
	")physics/metal/metal_box_impact_bullet3.wav",
};
static const char g_SuperJumpSound[][] = {
	"misc/halloween/spell_mirv_explode_primary.wav",
};

void Soldine_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds)); i++) { PrecacheSound(g_RangedAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_HurtArmorSounds)); i++) { PrecacheSound(g_HurtArmorSounds[i]); }
	for (int i = 0; i < (sizeof(g_SuperJumpSound)); i++) { PrecacheSound(g_SuperJumpSound[i]); }
	PrecacheModel("models/player/soldier.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Soldine");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_soldine");
	strcopy(data.Icon, sizeof(data.Icon), "soldine");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Expidonsa;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Soldine(vecPos, vecAng, team);
}

methodmap Soldine < CClotBody
{
	property int i_GunMode
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}
	property float f_SoldineMeleeCooldown
	{
		public get()							{ return fl_NextChargeSpecialAttack[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextChargeSpecialAttack[this.index] = TempValueForProperty; }
	}
	property float f_SoldineRocketJumpCD
	{
		public get()							{ return fl_NextRangedBarrage_Singular[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextRangedBarrage_Singular[this.index] = TempValueForProperty; }
	}
	property float f_SoldineRocketJumpCD_Wearoff
	{
		public get()							{ return fl_AttackHappensMaximum[this.index]; }
		public set(float TempValueForProperty) 	{ fl_AttackHappensMaximum[this.index] = TempValueForProperty; }
	}
	property bool b_SoldineRocketJump
	{
		public get()							{ return b_NextRangedBarrage_OnGoing[this.index]; }
		public set(bool TempValueForProperty) 	{ b_NextRangedBarrage_OnGoing[this.index] = TempValueForProperty; }
	}
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayRangedSound()
	{
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlaySuperJumpSound()
	{
		EmitSoundToAll(g_SuperJumpSound[GetRandomInt(0, sizeof(g_SuperJumpSound) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_SuperJumpSound[GetRandomInt(0, sizeof(g_SuperJumpSound) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayHurtArmorSound() 
	{
		EmitSoundToAll(g_HurtArmorSounds[GetRandomInt(0, sizeof(g_HurtArmorSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);

	}
	
	
	public Soldine(float vecPos[3], float vecAng[3], int ally)
	{
		Soldine npc = view_as<Soldine>(CClotBody(vecPos, vecAng, "models/player/soldier.mdl", "1.1", "40000", ally));
		

		i_NpcWeight[npc.index] = 3;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_ROBOT;
		
		func_NPCDeath[npc.index] = Soldine_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Soldine_OnTakeDamage;
		func_NPCThink[npc.index] = Soldine_ClotThink;
		
		npc.StartPathing();
		npc.m_flSpeed = 280.0;
		npc.i_GunMode = 1;
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

	//	Weapon
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_rocketlauncher/c_rocketlauncher.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/soldier/coldfront_curbstompers/coldfront_curbstompers.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("head", "models/player/items/soldier/grfs_soldier.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/pyro/hw2013_maniacs_manacles/hw2013_maniacs_manacles.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/soldier/eotl_winter_coat/eotl_winter_coat.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");

		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		
		return npc;
	}
}

public void Soldine_ClotThink(int iNPC)
{
	Soldine npc = view_as<Soldine>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if (npc.IsOnGround())
	{
		if(GetGameTime(npc.index) > npc.f_SoldineRocketJumpCD_Wearoff)
		{
			npc.b_SoldineRocketJump = false;
		}
	}
	
	if(npc.m_bAllowBackWalking)
	{
		if(IsValidEnemy(npc.index, npc.m_iTarget))
		{
			float WorldSpaceVec[3]; WorldSpaceCenter(npc.m_iTarget, WorldSpaceVec);
			npc.FaceTowards(WorldSpaceVec, 150.0);
		}
	}

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
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		int SetGoalVectorIndex = 0;
		SetGoalVectorIndex = SoldineSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 

		switch(SetGoalVectorIndex)
		{
			case 0:
			{
				npc.m_bAllowBackWalking = false;
				//Get the normal prediction code.
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
			}
			case 1:
			{
				npc.m_bAllowBackWalking = true;
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget,_,vBackoffPos);
				npc.SetGoalVector(vBackoffPos, true); //update more often, we need it
			}
		}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}

	SoldineAnimationChange(npc);
	npc.PlayIdleAlertSound();
}

public Action Soldine_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Soldine npc = view_as<Soldine>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;

	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}		


	
	return Plugin_Changed;
}

public void Soldine_NPCDeath(int entity)
{
	Soldine npc = view_as<Soldine>(entity);
	/*
		Explode on death code here please

	*/
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
	
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
/*


*/
void SoldineAnimationChange(Soldine npc)
{
	switch(npc.i_GunMode)
	{
		case 1: //primary
		{
			if (npc.IsOnGround())
			{
				if(npc.m_iChanged_WalkCycle != 1)
				{
					ResetSoldineWeapon(npc, 1);
					SetVariantInt(1);
					AcceptEntityInput(npc.index, "SetBodyGroup");
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 1;
					npc.SetActivity("ACT_MP_RUN_PRIMARY");
					npc.StartPathing();
				}	
			}
			else
			{
				if(npc.m_iChanged_WalkCycle != 2)
				{
					ResetSoldineWeapon(npc, 1);
					SetVariantInt(1);
					AcceptEntityInput(npc.index, "SetBodyGroup");
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 2;
					npc.SetActivity("ACT_MP_JUMP_FLOAT_PRIMARY");
					npc.StartPathing();
				}	
			}
		}
		case 0: //Melee
		{
			if (npc.IsOnGround())
			{
				if(npc.m_iChanged_WalkCycle != 3)
				{
					ResetSoldineWeapon(npc, 0);
					SetVariantInt(0);
					AcceptEntityInput(npc.index, "SetBodyGroup");
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 3;
					npc.SetActivity("ACT_MP_RUN_MELEE");
					npc.StartPathing();
				}	
			}
			else
			{
				if(npc.m_iChanged_WalkCycle != 4)
				{
					ResetSoldineWeapon(npc, 0);
					SetVariantInt(0);
					AcceptEntityInput(npc.index, "SetBodyGroup");
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_MP_JUMP_FLOAT_MELEE");
					npc.StartPathing();
				}	
			}
		}
	}

}

int SoldineSelfDefense(Soldine npc, float gameTime, int target, float distance)
{
	if(!npc.b_SoldineRocketJump)
	{
		if(npc.m_flAttackHappens)
		{
			npc.i_GunMode = 0;
			if(gameTime > npc.m_flAttackHappens)
			{
				npc.m_flAttackHappens = 0.0;
				Handle swingTrace;
				float WorldSpaceVec[3]; WorldSpaceCenter(target, WorldSpaceVec);
				npc.FaceTowards(WorldSpaceVec, 15000.0);
				if(npc.DoSwingTrace(swingTrace, target, _, _, _, 1)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
				{
					int target_hit = TR_GetEntityIndex(swingTrace);	
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);

					if(target_hit > 0) 
					{
						float damageDealt = 400.0; //Extreme melee damage
						if(ShouldNpcDealBonusDamage(target_hit))
							damageDealt *= 20.0; //basically oneshots buildings or atleast deals heavy damage
							
						SDKHooks_TakeDamage(target_hit, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);									
								
					
						npc.PlayMeleeHitSound();
						npc.DispatchParticleEffect(npc.index, "hightower_explosion", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("effect_hand_l"), PATTACH_POINT_FOLLOW, true);
			
						bool Knocked = false;
									
						if(IsValidClient(target_hit))
						{
							if (IsInvuln(target_hit))
							{
								Knocked = true;
								Custom_Knockback(npc.index, target_hit, 2000.0, true);
								TF2_AddCondition(target_hit, TFCond_LostFooting, 2.5);
								TF2_AddCondition(target_hit, TFCond_AirCurrent, 2.5);
							}
							else
							{
								TF2_AddCondition(target_hit, TFCond_LostFooting, 2.5);
								TF2_AddCondition(target_hit, TFCond_AirCurrent, 2.5);
							}
						}
									
						if(!Knocked)
							Custom_Knockback(npc.index, target_hit, 1500.0); 
					} 
				}
				delete swingTrace;
			}
			//A melee attack is happening, lets just follow the target_hit
			return 0;
		}

		//This ranged unit is more of an intruder, so we will get whatever enemy its pathing
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 3.0))
		{
			//close enough to concider as a melee range attack.
			if(gameTime > npc.f_SoldineMeleeCooldown)
			{
				npc.i_GunMode = 0;
				//We can melee!
				//Are we close enough?
				if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.35))
				{
					npc.m_flAttackHappens = gameTime + 0.25;
					npc.m_flDoingAnimation = gameTime + 0.25;
					npc.f_SoldineMeleeCooldown = gameTime + 15.0;
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
					npc.PlayMeleeSound();
					//We are close enough to melee attack, lets melee.
				}
				//no? Chase target
				return 0;
			}
		}
	}
	npc.i_GunMode = 1;
	//isnt melee anymore
	if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 20.0) || npc.b_SoldineRocketJump)
	{
		if(gameTime > npc.f_SoldineRocketJumpCD && !NpcStats_IsEnemySilenced(npc.index))
		{
			if(Can_I_See_Enemy_Only(npc.index, target))
			{
				static float flMyPos[3];
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flMyPos);
				static float hullcheckmaxs[3];
				static float hullcheckmins[3];

				//Defaults:
				//hullcheckmaxs = view_as<float>( { 24.0, 24.0, 72.0 } );
				//hullcheckmins = view_as<float>( { -24.0, -24.0, 0.0 } );

				hullcheckmaxs = view_as<float>( { 35.0, 35.0, 500.0 } ); //check if above is free
				hullcheckmins = view_as<float>( { -35.0, -35.0, 17.0 } );
			
				if(!IsSpaceOccupiedWorldOnly(flMyPos, hullcheckmins, hullcheckmaxs, npc.index))
				{
					float flPos[3];
					float flAng[3];
					int Particle_1;
					int Particle_2;
					npc.GetAttachment("foot_L", flPos, flAng);
					Particle_1 = ParticleEffectAt_Parent(flPos, "rockettrail", npc.index, "foot_L", {0.0,0.0,0.0});
					

					npc.GetAttachment("foot_R", flPos, flAng);
					Particle_2 = ParticleEffectAt_Parent(flPos, "rockettrail", npc.index, "foot_R", {0.0,0.0,0.0});
				
					CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(Particle_1), TIMER_FLAG_NO_MAPCHANGE);
					CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(Particle_2), TIMER_FLAG_NO_MAPCHANGE);
					
					npc.PlaySuperJumpSound();
					static float flMyPos_2[3];
					flMyPos[2] += 800.0;
					WorldSpaceCenter(target, flMyPos_2);

					flMyPos[0] = flMyPos_2[0];
					flMyPos[1] = flMyPos_2[1];
					PluginBot_Jump(npc.index, flMyPos);
					npc.f_SoldineRocketJumpCD_Wearoff = gameTime + 1.0;
					npc.f_SoldineRocketJumpCD = gameTime + 15.0;
					npc.b_SoldineRocketJump = true;
					npc.m_flNextRangedAttack = gameTime + 0.25;
				}
				else
				{
					npc.f_SoldineRocketJumpCD = gameTime + 1.0;
				}
			}
			else
			{
				npc.f_SoldineRocketJumpCD = gameTime + 1.0;
			}
		}
		
		if((distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.0) || npc.b_SoldineRocketJump) && gameTime > npc.m_flNextRangedAttack)
		{	
			if(Can_I_See_Enemy_Only(npc.index, target))
			{
				float projectile_speed = 900.0;
				float DamageRocket = 70.0;
				if(npc.b_SoldineRocketJump)
				{
					DamageRocket *= 0.5;
				}
				float vPredictedPos[3];
				PredictSubjectPositionForProjectiles(npc, target, projectile_speed, _,vPredictedPos);
				
				npc.FaceTowards(vPredictedPos, 20000.0);
				//Play attack anim
				npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
				


				npc.PlayRangedSound();
				npc.FireRocket(vPredictedPos, DamageRocket, projectile_speed);
			//	i_ProjectileExtraFunction[Rocket] = view_as<Function>(Soldine_Rocket_Base_Explode);
				npc.m_flDoingAnimation = gameTime + 0.25;
				if(npc.b_SoldineRocketJump)
				{
					npc.m_flNextRangedAttack = gameTime + 0.25;
				}
				else
				{
					npc.m_flNextRangedAttack = gameTime + 1.0;
				}
			}
		}
		if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 7.0))
		{
			//target is too far, try to close in
			return 0;
		}
		else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 4.0))
		{
			if(Can_I_See_Enemy_Only(npc.index, target))
			{
				//target is too close, try to keep distance
				return 1;
			}
		}
	}
	//Chase target
	return 0;
}

/*
void Soldine_Rocket_Base_Explode(int entity, int damage, const float VecPos[3])
{
	PrintToChatAll("Boom! Soldine_Rocket_Base_Explode");
}
*/

void ResetSoldineWeapon(Soldine npc, int weapon_Type)
{
	if(IsValidEntity(npc.m_iWearable1))
	{
		RemoveEntity(npc.m_iWearable1);
	}
	switch(weapon_Type)
	{
		case 1:
		{
			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_rocketlauncher/c_rocketlauncher.mdl");
			SetVariantString("1.0");
			AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		}
		case 0:
		{
			float flPos[3];
			float flAng[3];
			npc.GetAttachment("effect_hand_r", flPos, flAng);
			npc.m_iWearable1 = ParticleEffectAt_Parent(flPos, "raygun_projectile_blue_crit", npc.index, "effect_hand_r", {0.0,0.0,0.0});
		}
	}
}