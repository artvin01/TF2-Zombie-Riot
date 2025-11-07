#pragma semicolon 1
#pragma newdecls required


/*
	Once close enough and it sees an enemy, slightly hovers up and then launches at the enemy
	When colliding with an enemy it deals damage once
	after which they behave like an erasus
*/


static const char g_IdleAlertedSounds[][] = {
	")vo/medic_battlecry01.mp3",
	")vo/medic_battlecry02.mp3",
	")vo/medic_battlecry03.mp3",
	")vo/medic_battlecry04.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/knife_swing.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/neon_sign_hit_01.wav",
	"weapons/neon_sign_hit_02.wav",
	"weapons/neon_sign_hit_03.wav",
	"weapons/neon_sign_hit_04.wav"
};
static const char g_SuperJumpSound[][] = {
	"weapons/physcannon/energy_sing_explosion2.wav"
};
static const char g_SuperJumpSoundLaunch[][] = {
	"misc/halloween/spell_mirv_explode_primary.wav",
};
void Flaigus_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DefaultMedic_DeathSounds));	   i++) { PrecacheSound(g_DefaultMedic_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_DefaultMedic_HurtSounds));		i++) { PrecacheSound(g_DefaultMedic_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_DefaultMedic_PlayAnnoyedSound)); i++) { PrecacheSound(g_DefaultMedic_PlayAnnoyedSound[i]); }
	for (int i = 0; i < (sizeof(g_SuperJumpSound)); i++) { PrecacheSound(g_SuperJumpSound[i]); }
	for (int i = 0; i < (sizeof(g_SuperJumpSoundLaunch)); i++) { PrecacheSound(g_SuperJumpSoundLaunch[i]); }
	PrecacheModel("models/player/medic.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Flaigus");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_flaigus");
	strcopy(data.Icon, sizeof(data.Icon), "scout");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Expidonsa;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Flaigus(vecPos, vecAng, team);
}

methodmap Flaigus < CClotBody
{
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
	
	public void PlaySuperJumpSound()
	{
		EmitSoundToAll(g_SuperJumpSound[GetRandomInt(0, sizeof(g_SuperJumpSound) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlaySuperJumpLaunch()
	{
		EmitSoundToAll(g_SuperJumpSoundLaunch[GetRandomInt(0, sizeof(g_SuperJumpSoundLaunch) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);

	}
	public void PlayAnnoyedSound() 
	{
		this.m_flNextHurtSound = GetGameTime(this.index) + 1.0;
		EmitSoundToAll(g_DefaultMedic_PlayAnnoyedSound[GetRandomInt(0, sizeof(g_DefaultMedic_PlayAnnoyedSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);

	}
	property float m_flPrepareFlyAtEnemyCD
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flPrepareFlyAtEnemy
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	public Flaigus(float vecPos[3], float vecAng[3], int ally)
	{
		Flaigus npc = view_as<Flaigus>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "10000", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		
		func_NPCDeath[npc.index] = Flaigus_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Flaigus_OnTakeDamage;
		func_NPCThink[npc.index] = Flaigus_ClotThink;
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		SetEntPropFloat(npc.index, Prop_Data, "m_flElementRes", 1.0, Element_Chaos);
		VausMagicaGiveShield(npc.index, 3);
		npc.m_flPrepareFlyAtEnemyCD = GetGameTime() + 1.0;
		
		
		
		npc.StartPathing();
		npc.m_flSpeed = 330.0;
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/medic/sf14_purity_wings/sf14_purity_wings.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");


		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/all_class/bak_batarm/bak_batarm_medic.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/all_class/hwn2024_duality_mantle/hwn2024_duality_mantle_medic.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);

		DualReaEffects(npc.index);
		
		npc.m_iWearable9 = npc.EquipItem("head", WINGS_MODELS_1);
		SetVariantInt(1);
		AcceptEntityInput(npc.m_iWearable9, "SetBodyGroup");	
		SetVariantString("0.85");
		AcceptEntityInput(npc.m_iWearable9, "SetModelScale");
		SetEntityRenderColor(npc.m_iWearable9, 255, 255, 255, 2);
		
		return npc;
	}
}

public void Flaigus_ClotThink(int iNPC)
{
	Flaigus npc = view_as<Flaigus>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	//If shield breaks, gain powers
	

	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;
	FlaigusAnimationChange(npc);

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
		FlaigusSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action Flaigus_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Flaigus npc = view_as<Flaigus>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.PlayHurtSound();
	}
	
	return Plugin_Changed;
}

public void Flaigus_NPCDeath(int entity)
{
	Flaigus npc = view_as<Flaigus>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	ExpidonsaRemoveEffects(entity);
		
	
	if(IsValidEntity(npc.m_iWearable9))
		RemoveEntity(npc.m_iWearable9);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

}

void FlaigusSelfDefense(Flaigus npc, float gameTime, int target, float distance)
{
	
	if(npc.m_flPrepareFlyAtEnemyCD < GetGameTime(npc.index) && distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 13.0))
	{	
		if(IsValidEntity(target) && Can_I_See_Enemy_Only(npc.index, target))
		{
			//steal alaxios jump :D
			static float flPos[3]; 
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
			static float flPosEnemy[3]; 
			GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", flPosEnemy);
			float flDistanceToTarget = GetVectorDistance(flPos, flPosEnemy);
			float SpeedToPredict = flDistanceToTarget * 1.0;
			PredictSubjectPositionForProjectiles(npc, target, SpeedToPredict, _,f3_NpcSavePos[npc.index]);
			flPos[2] += 5.0;
			ParticleEffectAt(flPos, "taunt_flip_land_red", 0.25);
			npc.PlaySuperJumpSound();
			flPos[2] += 400.0;
			npc.SetVelocity({0.0,0.0,0.0});
			PluginBot_Jump(npc.index, flPos);
			ApplyStatusEffect(npc.index, npc.index, "Solid Stance", 1.0);	
			npc.m_flPrepareFlyAtEnemy = GetGameTime(npc.index) + 0.6;

			float cooldownDo = 20.0;
			npc.m_flPrepareFlyAtEnemyCD = GetGameTime(npc.index) + cooldownDo;

			npc.m_iChanged_WalkCycle = 0;
			npc.FaceTowards(f3_NpcSavePos[npc.index], 15000.0);
		}
	}
	if(npc.m_flPrepareFlyAtEnemy)
	{
		static float Size = 75.0;
		spawnRing_Vectors(f3_NpcSavePos[npc.index], Size * 2.0, 0.0, 0.0, 10.0, "materials/sprites/laserbeam.vmt", 200, 200, 100, 200, 1, 0.15, 6.0, 6.0, 2);
		
		if(npc.m_flPrepareFlyAtEnemy < GetGameTime(npc.index))
		{
			npc.PlaySuperJumpLaunch();
			npc.m_flPrepareFlyAtEnemy = 0.0;
			PluginBot_Jump(npc.index, f3_NpcSavePos[npc.index], 2500.0, true);
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
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
			{
							
				target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 110.0;
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 5.0;


					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);

					// Hit sound
					npc.PlayMeleeHitSound();
				} 
			}
			delete swingTrace;
		}
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
		{
			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
						
				npc.m_flAttackHappens = gameTime + 0.25;
				npc.m_flDoingAnimation = gameTime + 0.25;
				npc.m_flNextMeleeAttack = gameTime + 0.85;
			}
		}
	}
}



void FlaigusAnimationChange(Flaigus npc)
{
	if(npc.m_iChanged_WalkCycle == 0)
	{
		npc.m_iChanged_WalkCycle = -1;
	}
	if (npc.IsOnGround())
	{
		if(npc.m_iChanged_WalkCycle != 3)
		{
			npc.m_iChanged_WalkCycle = 3;
			npc.SetActivity("ACT_MP_RUN_MELEE");
			npc.AddGesture("ACT_MP_JUMP_LAND_MELEE");
		}	
	}
	else
	{
		if(npc.m_iChanged_WalkCycle != 4)
		{
			npc.m_iChanged_WalkCycle = 4;
			npc.SetActivity("ACT_MP_JUMP_FLOAT_MELEE");
		}	
	}
}