#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"vo/spy_paincrticialdeath01.mp3",
	"vo/spy_paincrticialdeath02.mp3",
	"vo/spy_paincrticialdeath03.mp3"
};

static const char g_HurtSounds[][] =
{
	"vo/spy_painsharp01.mp3",
	"vo/spy_painsharp02.mp3",
	"vo/spy_painsharp03.mp3",
	"vo/spy_painsharp04.mp3"
};

static const char g_IdleAlertedSounds[][] =
{
	"vo/spy_laughshort01.mp3",
	"vo/spy_laughshort02.mp3",
	"vo/spy_laughshort03.mp3",
	"vo/spy_laughshort04.mp3",
	"vo/spy_laughshort05.mp3",
	"vo/spy_laughshort06.mp3"
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/knife_swing.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/blade_hit1.wav",
	"weapons/blade_hit2.wav",
	"weapons/blade_hit3.wav",
	"weapons/blade_hit4.wav"
};

static const char g_RangedAttackSounds[][] = {
	"weapons/airboat/airboat_gun_energy1.wav",
	"weapons/airboat/airboat_gun_energy2.wav",
};

static int NPCId;

void DesertAncientDemon_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds)); i++) { PrecacheSound(g_RangedAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	PrecacheModel("models/player/medic.mdl");
	PrecacheModel("models/props_halloween/eyeball_projectile.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Ancient Demon");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_ancient_demon");
	strcopy(data.Icon, sizeof(data.Icon), "spy");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Interitus;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);
}

int AncientDemonNpcId()
{
	return NPCId;
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return DesertAncientDemon(vecPos, vecAng, team);
}
methodmap DesertAncientDemon < CClotBody
{
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
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRangedSound()
	{
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);

	}
	
	property bool m_bFakeClone
	{
		public get()		{	return i_RaidGrantExtra[this.index] < 0;	}
	}
	public DesertAncientDemon(float vecPos[3], float vecAng[3], int ally)
	{
		DesertAncientDemon npc = view_as<DesertAncientDemon>(CClotBody(vecPos, vecAng, "models/player/spy.mdl", "1.0", "15000", ally));
		
		i_NpcWeight[npc.index] = 3;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_ITEM1");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		i_RaidGrantExtra[npc.index] = 1;

		func_NPCDeath[npc.index] = view_as<Function>(DesertAncientDemon_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(DesertAncientDemon_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(DesertAncientDemon_ClotThink);
		func_NPCDeathForward[npc.index] = view_as<Function>(DesertAncientDemon_NPCDeathAlly);
		
		npc.StartPathing();
		npc.m_flSpeed = 250.0;

		if(Rogue_Paradox_ExtremeHeat())
			fl_Extra_Speed[npc.index] *= 1.2;
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_acr_hookblade/c_acr_hookblade.mdl");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/all_class/hwn2023_demonic_dome/hwn2023_demonic_dome_spy.mdl");

		npc.m_iWearable3 = npc.EquipItem("head", "models/player/items/spy/hwn_spy_misc2.mdl");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/spy/sum22_tactical_turtleneck/sum22_tactical_turtleneck.mdl");
		
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/spy/hwn2018_bandits_boots/hwn2018_bandits_boots.mdl");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);

		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 255, 255, 255, 200);
		SetEntityRenderMode(npc.m_iWearable5, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable5, 255, 255, 255, 200);
		SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable4, 255, 255, 255, 200);
		SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable3, 255, 255, 255, 200);
		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable2, 255, 255, 255, 200);
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 200);
		
		return npc;
	}
}

public void DesertAncientDemon_ClotThink(int iNPC)
{
	DesertAncientDemon npc = view_as<DesertAncientDemon>(iNPC);
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
		DesertAncientDemonSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action DesertAncientDemon_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	DesertAncientDemon npc = view_as<DesertAncientDemon>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void DesertAncientDemon_NPCDeath(int entity)
{
	DesertAncientDemon npc = view_as<DesertAncientDemon>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
	
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

void DesertAncientDemonSelfDefense(DesertAncientDemon npc, float gameTime, int target, float distance)
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
					int ElementalDamage = 30;
					float damageDealt = 75.0;

					if(npc.m_bFakeClone)
					{
						ElementalDamage = 20;
						damageDealt = 35.0;
					}

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
				float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
				npc.FaceTowards(vecTarget, 15000.0);
				
				npc.PlayRangedSound();
				int ElementalDamage = 20;
				float damageDealt = 50.0;

				if(npc.m_bFakeClone)
				{
					ElementalDamage = 10;
					damageDealt = 25.0;
				}
				int entity = npc.FireArrow(vecTarget, damageDealt, 800.0, "models/props_halloween/eyeball_projectile.mdl");
				i_ChaosArrowAmount[entity] = ElementalDamage;
				
				if(entity != -1)
				{
					if(IsValidEntity(f_ArrowTrailParticle[entity]))
						RemoveEntity(f_ArrowTrailParticle[entity]);

					SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
					SetEntityRenderColor(entity, 100, 100, 255, 255);
					
					WorldSpaceCenter(entity, vecTarget);
					f_ArrowTrailParticle[entity] = ParticleEffectAt(vecTarget, "tranq_distortion_trail", 3.0);
					SetParent(entity, f_ArrowTrailParticle[entity]);
					f_ArrowTrailParticle[entity] = EntIndexToEntRef(f_ArrowTrailParticle[entity]);
				}
			}
		}
		return;
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
				npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM1");
						
				npc.m_flAttackHappens = gameTime + 0.15;
				npc.m_flDoingAnimation = gameTime + 0.15;
				npc.m_flNextMeleeAttack = gameTime + 0.85;
			}
		}		
	}
	if(gameTime > npc.m_flNextRangedAttack)
	{
		if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED) && distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.0))
		{
			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_MP_THROW");
						
				npc.m_flNextRangedSpecialAttack = gameTime + 0.15;
				npc.m_flDoingAnimation = gameTime + 0.15;
				npc.m_flNextRangedAttack = gameTime + 1.85;
			}
		}		
	}
}



public void DesertAncientDemon_NPCDeathAlly(int self, int ally)
{
	DesertAncientDemon npc = view_as<DesertAncientDemon>(self);
	
	if(npc.m_bFakeClone)
	{
		return;
	}
	if(GetTeam(ally) != GetTeam(self))
	{
		return;
	}

	if(i_NpcInternalId[ally] == NPCId)
	{
		return;
	}
	if(i_RaidGrantExtra[ally] == 999)
	{
		return;
	}
	float AllyPos[3];
	GetEntPropVector(ally, Prop_Data, "m_vecAbsOrigin", AllyPos);
	float SelfPos[3];
	GetEntPropVector(self, Prop_Data, "m_vecAbsOrigin", SelfPos);
	float flDistanceToTarget = GetVectorDistance(SelfPos, AllyPos, true);
	if(flDistanceToTarget > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 24.0))
		return;
	
	float AllyAng[3];
	GetEntPropVector(ally, Prop_Data, "m_angRotation", AllyAng);
	int flMaxHealth = GetEntProp(self, Prop_Data, "m_iMaxHealth");
	int flMaxHealthally = ReturnEntityMaxHealth(ally);
	float pos[3]; 
	WorldSpaceCenter(ally, pos);
	pos[2] -= 10.0;
	DesertAncientDemon npc1 = view_as<DesertAncientDemon>(ally);
	npc1.m_bDissapearOnDeath = true;
	//they get eaten by the demon

	HealEntityGlobal(self, self, float(flMaxHealthally / 10), 2.0);
	float ProjLoc[3];
	GetEntPropVector(self, Prop_Data, "m_vecAbsOrigin", ProjLoc);
	ProjLoc[2] += 100.0;
	TE_Particle("health_text", ProjLoc, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
	fl_TotalArmor[self] = fl_TotalArmor[self] * 0.985;
	fl_Extra_Speed[self] = fl_Extra_Speed[self] + 0.01;
	if(fl_TotalArmor[self] <= 0.35)
	{
		fl_TotalArmor[self] = 0.35;
	}
	TE_Particle("teleported_blue", pos, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
	int NpcSpawnDemon = NPC_CreateById(NPCId, -1, SelfPos, AllyAng, GetTeam(npc.index)); //can only be enemy
	i_RaidGrantExtra[ally] = 999;
	if(IsValidEntity(NpcSpawnDemon))
	{
		NpcStats_CopyStats(npc.index, NpcSpawnDemon);
		flMaxHealth /= 40;
		if(GetTeam(NpcSpawnDemon) != TFTeam_Red)
		{
			NpcAddedToZombiesLeftCurrently(NpcSpawnDemon, true);
		}
		i_RaidGrantExtra[NpcSpawnDemon] = -1;
		SetEntProp(NpcSpawnDemon, Prop_Data, "m_iHealth", flMaxHealth);
		SetEntProp(NpcSpawnDemon, Prop_Data, "m_iMaxHealth", flMaxHealth);
		TeleportDiversioToRandLocation(NpcSpawnDemon,_,_, _);
		float scale = GetEntPropFloat(self, Prop_Send, "m_flModelScale");
		SetEntPropFloat(NpcSpawnDemon, Prop_Send, "m_flModelScale", scale * 0.7);
		fl_Extra_MeleeArmor[NpcSpawnDemon] = fl_Extra_MeleeArmor[npc.index];
		fl_Extra_RangedArmor[NpcSpawnDemon] = fl_Extra_RangedArmor[npc.index];
		fl_Extra_Speed[NpcSpawnDemon] = fl_Extra_Speed[npc.index];
		fl_Extra_Damage[NpcSpawnDemon] = fl_Extra_Damage[npc.index];
		fl_TotalArmor[NpcSpawnDemon] = fl_TotalArmor[npc.index];
	}
}