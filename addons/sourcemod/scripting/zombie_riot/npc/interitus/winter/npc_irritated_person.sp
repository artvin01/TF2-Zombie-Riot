#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/heavy_paincrticialdeath01.mp3",
	"vo/heavy_paincrticialdeath02.mp3",
	"vo/heavy_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/heavy_painsharp01.mp3",
	"vo/heavy_painsharp02.mp3",
	"vo/heavy_painsharp03.mp3",
	"vo/heavy_painsharp04.mp3",
	"vo/heavy_painsharp05.mp3",
};


static const char g_IdleAlertedSounds[][] = {
	"vo/heavy_battlecry03.mp3",
	"vo/heavy_battlecry05.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"vo/heavy_meleeing01.mp3",
	"vo/heavy_meleeing02.mp3",
	"vo/heavy_meleeing03.mp3",
	"vo/heavy_meleeing04.mp3",
	"vo/heavy_meleeing05.mp3",
	"vo/heavy_meleeing06.mp3",
	"vo/heavy_meleeing07.mp3",
	"vo/heavy_meleeing08.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/cbar_hitbod1.wav",
	"weapons/cbar_hitbod2.wav",
	"weapons/cbar_hitbod3.wav",
};

static const char g_SuperJumpSound[][] = {
	"misc/halloween/spell_blast_jump.wav",
};


void WinterIrritatedPerson_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_SuperJumpSound)); i++) { PrecacheSound(g_SuperJumpSound[i]); }
	PrecacheModel("models/player/medic.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Irritated Person");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_irritated_person");
	strcopy(data.Icon, sizeof(data.Icon), "heavy_urgent");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Interitus;
	data.Func = ClotSummon;
	int id = NPC_Add(data);
	Rogue_Paradox_AddWinterNPC(id);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return WinterIrritatedPerson(vecPos, vecAng, team);
}

methodmap WinterIrritatedPerson < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 4.0);
		
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
	}
	public void PlaySuperJumpSound()
	{
		EmitSoundToAll(g_SuperJumpSound[GetRandomInt(0, sizeof(g_SuperJumpSound) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_SuperJumpSound[GetRandomInt(0, sizeof(g_SuperJumpSound) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);

	}
	
	
	public WinterIrritatedPerson(float vecPos[3], float vecAng[3], int ally)
	{
		WinterIrritatedPerson npc = view_as<WinterIrritatedPerson>(CClotBody(vecPos, vecAng, "models/player/heavy.mdl", "1.1", "60000", ally));
		
		i_NpcWeight[npc.index] = 3;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(WinterIrritatedPerson_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(WinterIrritatedPerson_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(WinterIrritatedPerson_ClotThink);
		
		
		npc.StartPathing();
		npc.m_flSpeed = 250.0;
		npc.g_TimesSummoned = 0;
		npc.m_flJumpCooldown = GetGameTime(npc.index) + 5.0;
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, WinterIrritatedPerson_OnTakeDamagePost);
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_bear_claw/c_bear_claw.mdl");
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/heavy/jul13_bear_necessitys/jul13_bear_necessitys.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/heavy/sbox2014_leftover_trap/sbox2014_leftover_trap.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/heavy/diehard_dynafil/diehard_dynafil.mdl");
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/heavy/sbox2014_rat_stompers/sbox2014_rat_stompers.mdl");
		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/heavy/xms2013_heavy_pants/xms2013_heavy_pants.mdl");
		
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", skin);

		return npc;
	}
}

public void WinterIrritatedPerson_ClotThink(int iNPC)
{
	WinterIrritatedPerson npc = view_as<WinterIrritatedPerson>(iNPC);
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
	if (!npc.m_bisWalking && npc.IsOnGround())
	{
		float damageDealt = 1500.0;
		switch(npc.g_TimesSummoned)
		{
			case 1:
				damageDealt *= 1.1;
			case 2:
				damageDealt *= 1.2;
			case 3:
				damageDealt *= 1.3;
			case 4:
				damageDealt *= 1.4;
		}

		static float flMyPos[3];
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flMyPos);
		flMyPos[2] += 15.0;
		Explode_Logic_Custom(damageDealt, npc.index, npc.index, -1, flMyPos,250.0, 1.0, _, true, 20);
		TE_Particle("asplode_hoodoo", flMyPos, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
		EmitSoundToAll(SOUND_WAND_LIGHTNING_ABILITY_PAP_SMITE, 0, SNDCHAN_AUTO, 100, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, flMyPos);
		EmitSoundToAll(SOUND_WAND_LIGHTNING_ABILITY_PAP_SMITE, 0, SNDCHAN_AUTO, 100, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, flMyPos);
		npc.m_bisWalking = true;
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
	
	fl_TotalArmor[npc.index] = fl_TotalArmor[npc.index] + 0.0025;
	if(fl_TotalArmor[npc.index] > 1.0)
	{
		fl_TotalArmor[npc.index] = 1.0;
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
		WinterIrritatedPersonSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
		if(npc.g_TimesSummoned <= 2 && npc.m_flJumpCooldown < GetGameTime(npc.index))
		{
			if(flDistanceToTarget > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 4.0) && flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.0))
			{
				if(Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
				{
					npc.FaceTowards(vecTarget, 15000.0);
					PluginBot_Jump(npc.index, vecTarget);
					npc.PlayIdleAlertSound();
					npc.m_flJumpCooldown = GetGameTime(npc.index) + 7.5;
					npc.PlaySuperJumpSound();
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
				}
			}
		}
		else if(npc.g_TimesSummoned > 2 && npc.m_flJumpCooldown < GetGameTime(npc.index))
		{
			if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 3.0))
			{
				static float flMyPos[3];
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flMyPos);
				static float hullcheckmaxs[3];
				static float hullcheckmins[3];

				hullcheckmaxs = view_as<float>( { 35.0, 35.0, 200.0 } ); //check if above is free
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

					flMyPos[2] += 200.0;
					PluginBot_Jump(npc.index, flMyPos);
					npc.PlaySuperJumpSound();
					npc.m_bisWalking = false;
					npc.m_flJumpCooldown = GetGameTime(npc.index) + 7.5;
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

public Action WinterIrritatedPerson_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	WinterIrritatedPerson npc = view_as<WinterIrritatedPerson>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void WinterIrritatedPerson_NPCDeath(int entity)
{
	WinterIrritatedPerson npc = view_as<WinterIrritatedPerson>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
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

void WinterIrritatedPersonSelfDefense(WinterIrritatedPerson npc, float gameTime, int target, float distance)
{
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
					float damageDealt = 100.0;
					switch(npc.g_TimesSummoned)
					{
						case 1:
							damageDealt *= 1.1;
						case 2:
							damageDealt *= 1.2;
						case 3:
							damageDealt *= 1.3;
						case 4:
							damageDealt *= 1.4;
					}
					if(npc.m_iOverlordComboAttack >= 3)
					{
						damageDealt *= 2.0;
						Custom_Knockback(npc.index, target, 550.0, true, true); 
						fl_TotalArmor[npc.index] = fl_TotalArmor[npc.index] * 0.85;
						if(fl_TotalArmor[npc.index] < 0.25)
						{
							fl_TotalArmor[npc.index] = 0.25;
						}
					}

					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 5.0;


					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);

					// Hit sound
					npc.PlayMeleeHitSound();
				} 
			}
			if(npc.m_iOverlordComboAttack >= 3)
			{
				npc.m_iOverlordComboAttack = 0;
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
				npc.m_iOverlordComboAttack++;
				if(npc.m_iOverlordComboAttack >= 3)
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_SECONDARY");
				}
				else
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
				}
						
				npc.m_flAttackHappens = gameTime + 0.25;
				npc.m_flDoingAnimation = gameTime + 0.25;
				npc.m_flNextMeleeAttack = gameTime + 0.40;
			}
		}
	}
}


public void WinterIrritatedPerson_OnTakeDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype) 
{
	WinterIrritatedPerson npc = view_as<WinterIrritatedPerson>(victim);
	float maxhealth = float(ReturnEntityMaxHealth(npc.index));
	float health = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));
	float Ratio = health / maxhealth;
	if(Ratio <= 0.85 && npc.g_TimesSummoned < 1)
	{
		npc.g_TimesSummoned = 1;
		npc.m_flRangedArmor = 1.1;
		npc.m_flMeleeArmor = 1.1;
		npc.m_flSpeed = 270.0;
	}
	else if(Ratio <= 0.55 && npc.g_TimesSummoned < 2)
	{
		npc.g_TimesSummoned = 2;
		npc.m_flRangedArmor = 1.2;
		npc.m_flMeleeArmor = 1.2;
		npc.m_flSpeed = 285.0;
	}
	else if(Ratio <= 0.35 && npc.g_TimesSummoned < 3)
	{
		npc.g_TimesSummoned = 3;
		npc.m_flRangedArmor = 1.4;
		npc.m_flMeleeArmor = 1.4;
		npc.m_flSpeed = 330.0;
	}
	else if(Ratio <= 0.20 && npc.g_TimesSummoned < 4)
	{
		npc.g_TimesSummoned = 4;
		npc.m_flRangedArmor = 2.0;
		npc.m_flMeleeArmor = 2.0;
		npc.m_flSpeed = 450.0;
	}
}