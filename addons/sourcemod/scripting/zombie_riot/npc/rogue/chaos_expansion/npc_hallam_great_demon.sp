#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"vo/halloween_boss/knight_pain01.mp3",
	"vo/halloween_boss/knight_pain02.mp3",
	"vo/halloween_boss/knight_pain03.mp3"
};

static const char g_IdleAlertedSounds[][] =
{
	"vo/halloween_boss/knight_laugh01.mp3",
	"vo/halloween_boss/knight_laugh02.mp3",
	"vo/halloween_boss/knight_laugh03.mp3",
	"vo/halloween_boss/knight_laugh04.mp3"
};

static const char g_MeleeAttackSounds[][] = {
	"misc/halloween/strongman_fast_swing_01.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/halloween_boss/knight_axe_hit.wav",
};

static const char g_RangedAttackSounds[][] = {
	"weapons/airboat/airboat_gun_energy1.wav",
	"weapons/airboat/airboat_gun_energy2.wav",
};
static const char g_SpawnDemonSound[][] =
{
	"ui/halloween_boss_escape_ten.wav",
};



void HallamGreatDemon_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds)); i++) { PrecacheSound(g_RangedAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_SpawnDemonSound)); i++) { PrecacheSound(g_SpawnDemonSound[i]); }
	PrecacheModel("models/player/medic.mdl");
	PrecacheModel("models/props_halloween/eyeball_projectile.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Hallam's Great Demon");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_hallam_great_demon");
	strcopy(data.Icon, sizeof(data.Icon), "chaos_insane");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_BlueParadox;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return HallamGreatDemon(vecPos, vecAng, team);
}
methodmap HallamGreatDemon < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,80);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,130);
	}
	public void PlayRangedSound()
	{
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,80);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,80);

	}
	public void PlayDemonSpawnSound() 
	{
		EmitSoundToAll(g_SpawnDemonSound[GetRandomInt(0, sizeof(g_SpawnDemonSound) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,GetRandomInt(120,130));
	}
	
	property float m_flHealCooldownDo
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flSpawnWhisperer
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property bool m_bFakeClone
	{
		public get()		{	return i_RaidGrantExtra[this.index] < 0;	}
	}
	public HallamGreatDemon(float vecPos[3], float vecAng[3], int ally)
	{
		HallamGreatDemon npc = view_as<HallamGreatDemon>(CClotBody(vecPos, vecAng, "models/player/demo.mdl", "1.4", "15000", ally, _, true));
		
		i_NpcWeight[npc.index] = 3;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_ITEM1");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		

		SetVariantInt(4);
		AcceptEntityInput(npc.index, "SetBodyGroup");


		
		if(!IsValidEntity(RaidBossActive) && !Dungeon_Mode())
		{
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidModeTime = GetGameTime(npc.index) + 9000.0;
			RaidAllowsBuildings = true;
			RaidModeScaling = 1.0;
		}
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		npc.m_flSpawnWhisperer = 1.0;

		func_NPCDeath[npc.index] = view_as<Function>(HallamGreatDemon_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(HallamGreatDemon_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(HallamGreatDemon_ClotThink);
		
		npc.StartPathing();
		npc.m_flSpeed = 250.0;
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_claidheamohmor/c_claidheamohmor.mdl");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/medic/hwn2024_witch_doctor/hwn2024_witch_doctor.mdl");

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/heavy/hwn2022_horror_shawl/hwn2022_horror_shawl.mdl");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);

		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 65, 65, 65, 200);
		SetEntityRenderColor(npc.m_iWearable3, 65, 65, 65, 255);
		SetEntityRenderColor(npc.m_iWearable2, 65, 65, 65, 255);
		SetEntityRenderColor(npc.m_iWearable1, 65, 65, 65, 255);
		
		float flPos[3], flAng[3];
				
		npc.GetAttachment("eyes", flPos, flAng);
		npc.m_iWearable5 = ParticleEffectAt_Parent(flPos, "unusual_smoking", npc.index, "eyes", {10.0,0.0,0.0});
		npc.m_iWearable6 = ParticleEffectAt_Parent(flPos, "unusual_psychic_eye_white_glow", npc.index, "eyes", {10.0,0.0,-15.0});
		
		return npc;
	}
}

public void HallamGreatDemon_ClotThink(int iNPC)
{
	HallamGreatDemon npc = view_as<HallamGreatDemon>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.m_blPlayHurtAnimation = false;
	}

	if(npc.m_flSpawnWhisperer)
	{
		float SelfPos[3];
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", SelfPos);
		float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
		int flMaxHealthally = ReturnEntityMaxHealth(npc.index);
		int spawn_index = NPC_CreateByName("npc_ihanal_demon_whisperer", npc.index, SelfPos, ang, GetTeam(npc.index));
		if(spawn_index > MaxClients)
		{
			NpcStats_CopyStats(npc.index, spawn_index);
			flMaxHealthally /= 2;
			npc.m_iTargetAlly = spawn_index;
			HallamGreatDemon npcally = view_as<HallamGreatDemon>(spawn_index);
			npcally.m_iTargetAlly = npc.index;
			NpcAddedToZombiesLeftCurrently(spawn_index, true);
			SetEntProp(spawn_index, Prop_Data, "m_iHealth", flMaxHealthally);
			SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", flMaxHealthally);
			fl_Extra_MeleeArmor[spawn_index] = fl_Extra_MeleeArmor[npc.index];
			fl_Extra_RangedArmor[spawn_index] = fl_Extra_RangedArmor[npc.index];
			fl_Extra_Speed[spawn_index] = fl_Extra_Speed[npc.index];
			fl_Extra_Damage[spawn_index] = fl_Extra_Damage[npc.index];
			fl_TotalArmor[spawn_index] = fl_TotalArmor[npc.index];
		}
		npc.m_flSpawnWhisperer = 0.0;
		return;
	}
	float DemonScaling = 0.5;
	if(IsValidEntity(npc.m_iTargetAlly))
	{
		//They are alive, get buffs slowly.
		int flMaxHealthally = ReturnEntityMaxHealth(npc.m_iTargetAlly);
		int Currenthealth = GetEntProp(npc.m_iTargetAlly, Prop_Data, "m_iHealth");

		DemonScaling = float(Currenthealth) / float(flMaxHealthally);
		DemonScaling *= -1.0;
		DemonScaling += 1.0;
	}
	else
	{
		DemonScaling = 0.5;
	}
	DemonScaling += 1.0;
	npc.m_flSpeed = 200.0 * DemonScaling;
	RaidModeScaling = 1.0 * DemonScaling;
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if(npc.m_flHealCooldownDo < GetGameTime(npc.index))
	{
		if(MaxEnemiesAllowedSpawnNext(1) > (EnemyNpcAlive - EnemyNpcAliveStatic))
		{
			npc.PlayDemonSpawnSound();
			//spawn little fucks every so often
			float SelfPos[3];
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", SelfPos);
			float AllyAng[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", AllyAng);
			TE_Particle("teleported_blue", SelfPos, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
			int flMaxHealth = ReturnEntityMaxHealth(npc.index);
			int NpcSpawnDemon = NPC_CreateById(AncientDemonNpcId(), -1, SelfPos, AllyAng, GetTeam(npc.index)); //can only be enemy
			if(IsValidEntity(NpcSpawnDemon))
			{
				flMaxHealth /= 80;
				flMaxHealth = RoundToNearest(float(flMaxHealth) * DemonScaling);
				if(GetTeam(NpcSpawnDemon) != TFTeam_Red)
				{
					NpcAddedToZombiesLeftCurrently(NpcSpawnDemon, true);
				}
				i_RaidGrantExtra[NpcSpawnDemon] = -1;
				SetEntProp(NpcSpawnDemon, Prop_Data, "m_iHealth", flMaxHealth);
				SetEntProp(NpcSpawnDemon, Prop_Data, "m_iMaxHealth", flMaxHealth);
				float scale = GetEntPropFloat(npc.index, Prop_Send, "m_flModelScale");
				SetEntPropFloat(NpcSpawnDemon, Prop_Send, "m_flModelScale", scale * 0.7);
				fl_Extra_MeleeArmor[NpcSpawnDemon] = fl_Extra_MeleeArmor[npc.index];
				fl_Extra_RangedArmor[NpcSpawnDemon] = fl_Extra_RangedArmor[npc.index];
				fl_Extra_Speed[NpcSpawnDemon] = fl_Extra_Speed[npc.index];
				fl_Extra_Damage[NpcSpawnDemon] = fl_Extra_Damage[npc.index];
				fl_TotalArmor[NpcSpawnDemon] = fl_TotalArmor[npc.index];
				fl_Extra_Damage[NpcSpawnDemon] *= 2.25;
				fl_Extra_Damage[NpcSpawnDemon] *= DemonScaling;
				float flPos[3], flAng[3];
						
				HallamGreatDemon npcally = view_as<HallamGreatDemon>(NpcSpawnDemon);
				npcally.GetAttachment("eyes", flPos, flAng);
				npcally.m_iWearable6 = ParticleEffectAt_Parent(flPos, "unusual_smoking", npcally.index, "eyes", {0.0,0.0,0.0});
				npcally.m_iWearable7 = ParticleEffectAt_Parent(flPos, "unusual_psychic_eye_white_glow", npcally.index, "eyes", {0.0,0.0,-15.0});
			}
			npc.m_flHealCooldownDo = GetGameTime(npc.index) + 5.5;
			if(RaidModeScaling >= 200.0)
				npc.m_flHealCooldownDo = GetGameTime(npc.index) + 3.0;
		}
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
		HallamGreatDemonSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget, DemonScaling); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action HallamGreatDemon_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	HallamGreatDemon npc = view_as<HallamGreatDemon>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void HallamGreatDemon_NPCDeath(int entity)
{
	HallamGreatDemon npc = view_as<HallamGreatDemon>(entity);
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

void HallamGreatDemonSelfDefense(HallamGreatDemon npc, float gameTime, int target, float distance, float Scaling)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 1))
			{
							
				target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if(IsValidEnemy(npc.index, target))
				{
					int ElementalDamage = RoundToNearest(150.0 * Scaling);
					float damageDealt = 400.0 * Scaling;

					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 1.5;


					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);
					Elemental_AddChaosDamage(target, npc.index, ElementalDamage, true, true);
					
					// Hit sound
					npc.PlayMeleeHitSound();
				} 
			}
			delete swingTrace;
		}
		return;
	}

	if(npc.m_flNextRangedSpecialAttack)
	{
		if(npc.m_flNextRangedSpecialAttack < gameTime)
		{
			npc.m_flNextRangedSpecialAttack = 0.0;
			
			if(npc.m_iTarget > 0)
			{	
				float projectile_speed = 1100.0;
				float vPredictedPos[3];
				PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, projectile_speed, _,vPredictedPos);
				npc.FaceTowards(vPredictedPos, 15000.0);
				
				npc.PlayRangedSound();
				int ElementalDamage = RoundToNearest(150.0 * Scaling);
				float damageDealt = 250.0 * Scaling;

				int entity = npc.FireArrow(vPredictedPos, damageDealt, projectile_speed, "models/props_halloween/eyeball_projectile.mdl");
				i_ChaosArrowAmount[entity] = ElementalDamage;
				
				if(entity != -1)
				{
					if(IsValidEntity(f_ArrowTrailParticle[entity]))
						RemoveEntity(f_ArrowTrailParticle[entity]);

					SetEntityRenderColor(entity, 15, 15, 15, 255);
					
					WorldSpaceCenter(entity, vPredictedPos);
					f_ArrowTrailParticle[entity] = ParticleEffectAt(vPredictedPos, "tranq_distortion_trail", 3.0);
					SetParent(entity, f_ArrowTrailParticle[entity]);
					f_ArrowTrailParticle[entity] = EntIndexToEntRef(f_ArrowTrailParticle[entity]);
				}
			}
		}
		return;
	}
	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
		{
			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM1");
						
				npc.m_flAttackHappens = gameTime + 0.15;
				npc.m_flDoingAnimation = gameTime + 0.15;
				npc.m_flNextMeleeAttack = gameTime + 0.65;
			}
		}		
	}
	if(gameTime > npc.m_flNextRangedAttack)
	{
		if(distance > (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED) && distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 15.0))
		{
			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.AddGesture("ACT_MP_GESTURE_VC_FISTPUMP_MELEE");
						
				npc.m_flNextRangedSpecialAttack = gameTime + 0.15;
				npc.m_flDoingAnimation = gameTime + 0.15;
				npc.m_flNextRangedAttack = gameTime + 1.0;
			}
		}		
	}
}