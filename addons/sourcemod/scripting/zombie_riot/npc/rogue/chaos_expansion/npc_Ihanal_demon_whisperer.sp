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
	"player/invuln_off_vaccinator.wav"
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


void HallamDemonWhisperer_OnMapStart_NPC()
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
	strcopy(data.Name, sizeof(data.Name), "Ihanal Demon Whisperer");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_ihanal_demon_whisperer");
	strcopy(data.Icon, sizeof(data.Icon), "spy");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_BlueParadox;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return HallamDemonWhisperer(vecPos, vecAng, team);
}
methodmap HallamDemonWhisperer < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,80);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,80);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,75);
	}
	public void PlayRangedSound()
	{
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,80);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,80);

	}
	
	property float m_flHealCooldownDo
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property bool m_bFakeClone
	{
		public get()		{	return i_RaidGrantExtra[this.index] < 0;	}
	}
	property float m_flSilvesterHudCD
	{
		public get()							{ return fl_AbilityOrAttack[this.index][6]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][6] = TempValueForProperty; }
	}
	public HallamDemonWhisperer(float vecPos[3], float vecAng[3], int ally)
	{
		HallamDemonWhisperer npc = view_as<HallamDemonWhisperer>(CClotBody(vecPos, vecAng, "models/player/spy.mdl", "1.0", "15000", ally));
		
		i_NpcWeight[npc.index] = 3;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_ITEM1");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		if(!IsValidEntity(RaidBossActive))
		{
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidModeTime = GetGameTime(npc.index) + 9000.0;
			RaidAllowsBuildings = true;
			RaidModeScaling = 100.0;
		}
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(HallamDemonWhisperer_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(HallamDemonWhisperer_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(HallamDemonWhisperer_ClotThink);
		
		npc.StartPathing();
		npc.m_flSpeed = 330.0;
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_acr_hookblade/c_acr_hookblade.mdl");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/spy/dec24_le_frosteaux/dec24_le_frosteaux.mdl");

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/demo/hwn2024_badlands_bandido_style1/hwn2024_badlands_bandido_style1.mdl");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);

		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 125, 125, 125, 255);
		SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable3, 125, 125, 125, 255);
		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable2, 125, 125, 125, 255);
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, 125, 125, 125, 255);

		float flPos[3], flAng[3];
				
		npc.GetAttachment("eyes", flPos, flAng);
		npc.m_iWearable5 = ParticleEffectAt_Parent(flPos, "unusual_smoking", npc.index, "eyes", {0.0,0.0,0.0});
		npc.m_iWearable6 = ParticleEffectAt_Parent(flPos, "unusual_psychic_eye_white_glow", npc.index, "eyes", {0.0,0.0,-15.0});
		npc.StartPathing();
		
		return npc;
	}
}

public void HallamDemonWhisperer_ClotThink(int iNPC)
{
	HallamDemonWhisperer npc = view_as<HallamDemonWhisperer>(iNPC);
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
	//Set raid to this one incase the previous one has died or somehow vanished
	
	if(npc.m_flSilvesterHudCD < GetGameTime())
	{
		npc.m_flSilvesterHudCD = GetGameTime() + 0.2;
		//Set raid to this one incase the previous one has died or somehow vanished
		if(IsEntityAlive(EntRefToEntIndex(RaidBossActive)) && RaidBossActive != EntIndexToEntRef(npc.index))
		{
			for(int EnemyLoop; EnemyLoop <= MaxClients; EnemyLoop ++)
			{
				if(IsValidClient(EnemyLoop)) //Add to hud as a duo raid.
				{
					Calculate_And_Display_hp(EnemyLoop, npc.index, 0.0, false);	
				}	
			}
		}
		else if(EntRefToEntIndex(RaidBossActive) != npc.index && !IsEntityAlive(EntRefToEntIndex(RaidBossActive)))
		{	
			RaidBossActive = EntIndexToEntRef(npc.index);
		}
	}

	if(IsValidAlly(npc.index, npc.m_iTargetAlly))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTargetAlly, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED)
		{
			//too close.
			npc.StopPathing();
		}
		else if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3];
			PredictSubjectPosition(npc, npc.m_iTargetAlly,_,_, vPredictedPos);
			NPC_SetGoalVector(npc.index, vPredictedPos);
			npc.StartPathing();
		}
		else 
		{
			NPC_SetGoalEntity(npc.index, npc.m_iTargetAlly);
			npc.StartPathing();
		}
		HallamDemonWhispererSelfDefense(npc,GetGameTime(npc.index), npc.m_iTargetAlly, flDistanceToTarget); 
	}
	else
	{
		for(int Loop; Loop <= 15; Loop++)
		{
			float SelfPos[3];
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", SelfPos);
			float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
			TE_Particle("teleported_blue", SelfPos, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
			int flMaxHealthally = ReturnEntityMaxHealth(npc.index);
			int NpcSpawnDemon = NPC_CreateById(AncientDemonNpcId(), -1, SelfPos, AllyAng, GetTeam(npc.index)); //can only be enemy
			if(IsValidEntity(NpcSpawnDemon))
			{
				flMaxHealth /= 20;
				flMaxHealth *= DemonScaling;
				if(GetTeam(NpcSpawnDemon) != TFTeam_Red)
				{
					NpcAddedToZombiesLeftCurrently(NpcSpawnDemon, true);
				}
				i_RaidGrantExtra[NpcSpawnDemon] = -1;
				SetEntProp(NpcSpawnDemon, Prop_Data, "m_iHealth", flMaxHealth);
				SetEntProp(NpcSpawnDemon, Prop_Data, "m_iMaxHealth", flMaxHealth);
				float scale = GetEntPropFloat(self, Prop_Send, "m_flModelScale");
				SetEntPropFloat(NpcSpawnDemon, Prop_Send, "m_flModelScale", scale * 0.7);
				fl_Extra_MeleeArmor[NpcSpawnDemon] = fl_Extra_MeleeArmor[npc.index];
				fl_Extra_RangedArmor[NpcSpawnDemon] = fl_Extra_RangedArmor[npc.index];
				fl_Extra_Speed[NpcSpawnDemon] = fl_Extra_Speed[npc.index];
				fl_Extra_Damage[NpcSpawnDemon] = fl_Extra_Damage[npc.index];
				fl_TotalArmor[NpcSpawnDemon] = fl_TotalArmor[npc.index];
				fl_Extra_Damage[NpcSpawnDemon] *= 3.0;

				HallamGreatDemon npcally = view_as<HallamGreatDemon>(spawn_index);
				npcally.GetAttachment("eyes", flPos, flAng);
				npcally.m_iWearable6 = ParticleEffectAt_Parent(flPos, "unusual_smoking", npcally.index, "eyes", {0.0,0.0,0.0});
				npcally.m_iWearable7 = ParticleEffectAt_Parent(flPos, "unusual_psychic_eye_white_glow", npcally.index, "eyes", {0.0,0.0,-15.0});
			}
		}
		for(int LoopExplode; LoopExplode <= 10; LoopExplode++)
		{
			float pos1[3];
			GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", pos1);
			pos1[0] += GetRandomFloat(-30.0,30.0);
			pos1[1] += GetRandomFloat(-30.0,30.0);
			pos1[2] += GetRandomFloat(15.0,60.0);
			DataPack pack_boom1 = new DataPack();
			pack_boom1.WriteFloat(pos1[0]);
			pack_boom1.WriteFloat(pos1[1]);
			pack_boom1.WriteFloat(pos1[2]);
			pack_boom1.WriteCell(0);
			RequestFrame(MakeExplosionFrameLater, pack_boom1);
		}
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		npc.m_flNextThinkTime = FAR_FUTURE;
		RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
		//If ally somehow dies before him, explode into like 20 demons.
	}
	npc.PlayIdleAlertSound();
}

public Action HallamDemonWhisperer_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	HallamDemonWhisperer npc = view_as<HallamDemonWhisperer>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		if(attacker <= MaxClients && (TeutonType[attacker] != TEUTON_NONE) || dieingstate[attacker] != 0)
			return Plugin_Changed;

		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;

		float vecTarget[3]; WorldSpaceCenter(attacker, vecTarget );
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 5.0) 
		{
			if(IsValidAlly(npc.index, npc.m_iTargetAlly))
			{
				ApplyStatusEffect(npc.index, npc.m_iTargetAlly, "False Therapy", 3.0);
				HallamDemonWhisperer npcally = view_as<HallamDemonWhisperer>(npc.m_iTargetAlly);
				npc.m_iTarget = attacker;
				float vecAlly[3]; WorldSpaceCenter(npc.m_iTargetAlly, vecAlly);
				float vecMe[3]; WorldSpaceCenter(attacker, vecMe);
				spawnBeam(0.3, 255, 50, 50, 50, "materials/sprites/laserbeam.vmt", 4.0, 6.2, _, 2.0, vecAlly, vecMe);	
				spawnBeam(0.3, 255, 50, 50, 50, "materials/sprites/lgtning.vmt", 4.0, 5.2, _, 2.0, vecAlly, vecMe);	
			}
			//if close enough.
		}
		//when hurt, forces main demon to attack said target
	}
	
	return Plugin_Changed;
}

public void HallamDemonWhisperer_NPCDeath(int entity)
{
	HallamDemonWhisperer npc = view_as<HallamDemonWhisperer>(entity);
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

void HallamDemonWhispererSelfDefense(HallamDemonWhisperer npc, float gameTime, int target, float distance)
{
	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 2.0))
		{
			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy_Only(npc.index, npc.m_iTargetAlly);
					
			if(IsValidAlly(npc.index, Enemy_I_See))
			{
				float vecAlly[3]; WorldSpaceCenter(Enemy_I_See, vecAlly);
				float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM1");
						
				npc.m_flAttackHappens = gameTime + 0.15;
				npc.m_flDoingAnimation = gameTime + 0.15;
				npc.m_flNextMeleeAttack = gameTime + 0.65;
				
				ApplyStatusEffect(entity, npc.m_iTargetAlly, "Buff Banner", 3.0);	
				ApplyStatusEffect(entity, npc.m_iTargetAlly, "Battilons Backup", 3.0);	
				ApplyStatusEffect(entity, npc.m_iTargetAlly, "Squad Leader", 3.0);
				HealEntityGlobal(entity, npc.m_iTargetAlly, float(maxhealth) / 100, 1.0, 0.0, HEAL_SELFHEAL);
				spawnBeam(0.8, 50, 255, 50, 50, "materials/sprites/laserbeam.vmt", 4.0, 6.2, _, 2.0, vecAlly, vecMe);	
				spawnBeam(0.8, 50, 255, 50, 50, "materials/sprites/lgtning.vmt", 4.0, 5.2, _, 2.0, vecAlly, vecMe);	
				spawnRing_Vectors(vecAlly, 0.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 50, 255, 50, 255, 2, 1.0, 5.0, 12.0, 1, 150.0);
				spawnRing_Vectors(vecAlly, 0.0, 0.0, 0.0, 40.0, "materials/sprites/laserbeam.vmt", 50, 255, 50, 255, 2, 1.0, 5.0, 12.0, 1, 150.0);
				spawnRing_Vectors(vecAlly, 0.0, 0.0, 0.0, 80.0, "materials/sprites/laserbeam.vmt", 50, 255, 50, 255, 2, 1.0, 5.0, 12.0, 1, 150.0);
			}
		}		
	}
}