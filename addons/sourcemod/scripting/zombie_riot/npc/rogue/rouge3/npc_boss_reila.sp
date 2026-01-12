#pragma semicolon 1
#pragma newdecls required


static const char g_HurtSounds[][] = {
	")physics/metal/metal_box_impact_bullet1.wav",
	")physics/metal/metal_box_impact_bullet2.wav",
	")physics/metal/metal_box_impact_bullet3.wav",
};


static const char g_nightmare_cannon_core_sound[][] = {
	"zombiesurvival/seaborn/loop_laser.mp3",
};
static const char g_RangedAttackSounds[][] = {
	"npc/combine_gunship/attack_start2.wav",
};
/*
static const char g_IdleAlertedSounds[][] = {
	"vo/medic_sf13_spell_super_jump01.mp3",
	"vo/medic_sf13_spell_super_speed01.mp3",
	"vo/medic_sf13_spell_generic04.mp3",
	"vo/medic_sf13_spell_devil_bargain01.mp3",
	"vo/medic_sf13_spell_teleport_self01.mp3",
	"vo/medic_sf13_spell_uber01.mp3",
	"vo/medic_sf13_spell_zombie_horde01.mp3",
};
*/
static const char g_MeleeAttackSounds[][] = {
	"weapons/gunslinger_swing.wav",
};

static const char g_MeleeHitSounds[][] = {
	"items/powerup_pickup_crits.wav",
};

static const char g_ReilaChargeMeleeDo[][] =
{
	"weapons/vaccinator_charge_tier_01.wav",
};

static const char g_SpawnSoundDrones[][] = {
	"weapons/cow_mangler_explosion_charge_01.wav",
};

static int NPCId;
void BossReila_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_RangedAttackSounds)); i++) { PrecacheSound(g_RangedAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_ReilaChargeMeleeDo)); i++) { PrecacheSound(g_ReilaChargeMeleeDo[i]); }
	for (int i = 0; i < (sizeof(g_SpawnSoundDrones)); i++) { PrecacheSound(g_SpawnSoundDrones[i]); }
	PrecacheModel("models/player/medic.mdl");
	PrecacheSound("misc/halloween/spell_mirv_explode_primary.wav");
	PrecacheSound("weapons/vaccinator_charge_tier_03.wav");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Reila");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_boss_reila");
	strcopy(data.Icon, sizeof(data.Icon), "rbf_reila");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Curtain;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPCId = NPC_Add(data);
}
int Boss_ReilaID()
{
	return NPCId;
}
static void ClotPrecache()
{
	PrecacheSoundCustom("#zombiesurvival/rogue3/reila_battle_ost.mp3");
	NPC_GetByPlugin("reila_beacon_spawner");
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return BossReila(vecPos, vecAng, team, data);
}

methodmap BossReila < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
	//	EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 90);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.25;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		
	}

	public void PlaySpawnSound() 
	{
		EmitSoundToAll(g_SpawnSoundDrones[GetRandomInt(0, sizeof(g_SpawnSoundDrones) - 1)], this.index, SNDCHAN_WEAPON, BOSS_ZOMBIE_SOUNDLEVEL, _, 0.8, GetRandomInt(125, 130));
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, GetRandomInt(125, 130));
	}
	public void PlayChargeMeleeHit() 
	{
		EmitSoundToAll(g_ReilaChargeMeleeDo[GetRandomInt(0, sizeof(g_ReilaChargeMeleeDo) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	property float m_flReflectInMode
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flReflectStatusCD
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flDamageTaken
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flBossSpawnBeacon
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	property float m_flSpawnBallsCD
	{
		public get()							{ return fl_AbilityOrAttack[this.index][4]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][4] = TempValueForProperty; }
	}
	property float m_flSpawnBallsDoingCD
	{
		public get()							{ return fl_AbilityOrAttack[this.index][5]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][5] = TempValueForProperty; }
	}
	property float m_flDoLoseTalk
	{
		public get()							{ return fl_AbilityOrAttack[this.index][6]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][6] = TempValueForProperty; }
	}
	property int m_iBallsLeftToSpawn
	{
		public get()							{ return i_MedkitAnnoyance[this.index]; }
		public set(int TempValueForProperty) 	{ i_MedkitAnnoyance[this.index] = TempValueForProperty; }
	}

	public BossReila(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		bool altEnding = data[0] == 'a' || Rogue_HasNamedArtifact("Reila Assistance");	// Ending3!
		bool badEnding = data[0] == 'b' || Rogue_HasNamedArtifact("Torn Keycard");	// You idiots!

		BossReila npc = view_as<BossReila>(CClotBody(vecPos, vecAng, "models/player/engineer.mdl", "1.0", "3000", ally));
		
		i_NpcWeight[npc.index] = 4;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		SetVariantInt(3);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		npc.SetActivity("ACT_MP_RUN_ITEM2");
		
		npc.m_iBleedType = altEnding ? BLEEDTYPE_UMBRAL : BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		npc.m_bDissapearOnDeath = true;

		func_NPCDeath[npc.index] = view_as<Function>(BossReila_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(BossReila_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(BossReila_ClotThink);
		npc.m_flReflectStatusCD = GetGameTime() + 5.0;
		npc.m_flSpawnBallsCD = GetGameTime() + 5.0;
		npc.m_flSpawnBallsDoingCD = 0.0;
		
		
		if(!IsValidEntity(RaidBossActive))
		{
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidModeTime = GetGameTime(npc.index) + 60.0;
			RaidAllowsBuildings = true;
			RaidModeScaling = 1.0;
		}
		npc.StartPathing();
		npc.m_flSpeed = 330.0;
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/all_class/dec23_boarders_beanie_style2/dec23_boarders_beanie_style2_engineer.mdl");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/all_class/sbox2014_zipper_suit/sbox2014_zipper_suit_engineer.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/engineer/hwn2024_delldozer_style3/hwn2024_delldozer_style3.mdl");
		SetEntityRenderColor(npc.m_iWearable4, 120, 55, 100, 255);
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/all_class/robotarm_silver/robotarm_silver_gem.mdl");
		SetEntityRenderColor(npc.m_iWearable5, 100, 55, 190, 255);
		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/all_class/fall2013_the_special_eyes_style1/fall2013_the_special_eyes_style1_engineer.mdl");
		SetEntityRenderColor(npc.m_iWearable6, 120, 55, 100, 255);
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);

		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", skin);

		if(altEnding)
		{
			SetEntityRenderFx(npc.index, RENDERFX_DISTORT);
			SetEntityRenderColor(npc.index, GetRandomInt(25, 255), GetRandomInt(25, 255), GetRandomInt(25, 255), 255);
			SetEntityRenderFx(npc.m_iWearable1, RENDERFX_DISTORT);
			SetEntityRenderColor(npc.m_iWearable1, GetRandomInt(25, 255), GetRandomInt(25, 255), GetRandomInt(25, 255), 255);
			SetEntityRenderFx(npc.m_iWearable3, RENDERFX_DISTORT);
			SetEntityRenderColor(npc.m_iWearable3, GetRandomInt(25, 255), GetRandomInt(25, 255), GetRandomInt(25, 255), 255);
			SetEntityRenderFx(npc.m_iWearable4, RENDERFX_DISTORT);
			SetEntityRenderColor(npc.m_iWearable4, GetRandomInt(25, 255), GetRandomInt(25, 255), GetRandomInt(25, 255), 255);
			SetEntityRenderFx(npc.m_iWearable5, RENDERFX_DISTORT);
			SetEntityRenderColor(npc.m_iWearable5, GetRandomInt(25, 255), GetRandomInt(25, 255), GetRandomInt(25, 255), 255);
			SetEntityRenderFx(npc.m_iWearable6, RENDERFX_DISTORT);
			SetEntityRenderColor(npc.m_iWearable6, GetRandomInt(25, 255), GetRandomInt(25, 255), GetRandomInt(25, 255), 255);
		
			strcopy(c_NpcName[npc.index], sizeof(c_NpcName[]), "Reila?");

			CPrintToChatAll("{pink}?????{default}: Who are you?!");
		}
		else if(badEnding)
		{
			CPrintToChatAll("{pink}Reila{default}: Is this what you wanted?!");
			fl_Extra_Damage[npc.index] *= 3.0;
			fl_Extra_Speed[npc.index] *= 1.4;
			f_AttackSpeedNpcIncrease[npc.index] *= 0.7;
		}
		else
		{
			CPrintToChatAll("{pink}Reila{default}: リᒷ╎リ リᒷ╎リ! リ╎ᓵ⍑ℸ ̣ ⋮ᒷℸ ̣⨅ℸ ̣!.");
		}
		if(data[0] && !altEnding && !badEnding && !Rogue_HasNamedArtifact("Ascension Stack"))
			i_RaidGrantExtra[npc.index] = 1;
		npc.m_flBossSpawnBeacon = 1.0;

		if(StrContains(data, "force_final_battle") != -1)
		{
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidModeTime = GetGameTime(npc.index) + 60.0;
			RaidAllowsBuildings = true;
			RaidModeScaling = 1.0;
			
			i_RaidGrantExtra[npc.index] = 2;
			MusicEnum music;
			strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/rogue3/reila_battle_ost.mp3");
			music.Time = 100;
			music.Volume = 0.65;
			music.Custom = true;
			strcopy(music.Name, sizeof(music.Name), "Twin Souls");
			strcopy(music.Artist, sizeof(music.Artist), "I HATE MODELS");
			Music_SetRaidMusic(music);
		}
		if(StrContains(data, "force_final_battle") != -1)
		{
			RaidAllowsBuildings = false;
		}

		return npc;
	}
}

public void BossReila_ClotThink(int iNPC)
{
	BossReila npc = view_as<BossReila>(iNPC);
	if(npc.m_flArmorCount > 1.0)
	{
		ApplyStatusEffect(iNPC, iNPC, "War Cry", 0.6);
		ApplyStatusEffect(iNPC, iNPC, "Ancient Melodies", 0.6);
	}
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	if(Reila_LossAnimation(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(RaidModeTime < GetGameTime())
	{
		if(IsValidEntity(RaidBossActive))
		{
			ForcePlayerLoss();
			RaidBossActive = INVALID_ENT_REFERENCE;
		}
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		npc.StopPathing();
	}
	if(RaidModeTime < GetGameTime() + 60.0)
	{
		PlayTickSound(true, false);
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
	ReilaCreateBeacon(npc.index);
	if(ReilaReflectDamageDo(npc.index))
	{
		return;
	}

	if(npc.m_iChanged_WalkCycle != 1)
	{
		if(npc.m_flDamageTaken > 0.0)
		{
			GrantEntityArmor(npc.index, false, 1.0, 0.33, 0, npc.m_flDamageTaken, npc.index);
			npc.m_flDamageTaken = 0.0;
		}
		if(IsValidEntity(npc.m_iWearable7))
			RemoveEntity(npc.m_iWearable7);
		if(IsValidEntity(npc.m_iWearable8))
			RemoveEntity(npc.m_iWearable8);
		if(IsValidEntity(npc.m_iWearable9))
			RemoveEntity(npc.m_iWearable9);
		npc.SetActivity("ACT_MP_RUN_ITEM2");
		npc.RemoveGesture("ACT_MP_ATTACK_STAND_GRENADE");
		npc.m_iChanged_WalkCycle = 1;
		npc.m_flSpeed = 330.0;
		npc.m_bisWalking = true;
		npc.StartPathing();
	}
	/*
	if(IsValidEntity(npc.m_iWearable5) && Rogue_HasNamedArtifact("Bob's Duck"))
	{
		RemoveEntity(npc.m_iWearable5);
		npc.m_iWearable7 = npc.EquipItem("head", "models/workshop/player/items/all_class/all_class_badge_bonusd/all_class_badge_bonusd.mdl");
		SetEntityRenderColor(npc.m_iWearable7, 120, 55, 190, 255);
	}
	*/
	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}

	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
	
		ReilaSpawnBalls(npc.index, vecTarget);
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
		BossReilaSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action BossReila_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	BossReila npc = view_as<BossReila>(victim);
		
	if(Rogue_Mode() && damage >= float(GetEntProp(npc.index, Prop_Data, "m_iHealth")))
	{
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client))
			{
				Music_Stop_All(client); //This is actually more expensive then i thought.
				SetMusicTimer(client, GetTime() + 50);
			}
		}
		Waves_ClearWave();
		for(int i; i < i_MaxcountNpcTotal; i++)
		{
			int entitynpc = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
			if(IsValidEntity(entitynpc))
			{
				if(entitynpc != npc.index  && IsEntityAlive(entitynpc) && GetTeam(npc.index) == GetTeam(entitynpc))
				{
					SmiteNpcToDeath(entitynpc);
				}
			}
		}
		if(i_RaidGrantExtra[npc.index] == 1)
		{
			npc.SetActivity("ACT_MP_STAND_LOSERSTATE");
			RaidBossActive = 0;
			npc.m_flDoLoseTalk = GetGameTime() + 3.0;
			i_RaidGrantExtra[npc.index] = 2;
			npc.m_bisWalking = false;
			ApplyStatusEffect(npc.index, npc.index, "Infinite Will", 50.0);
			CPrintToChatAll("{pink}Reila {snow}Puts her hands up and gives up.");
			damage = 0.0;
			return Plugin_Changed;
		}
		else
		{
			damage *= 4.0;
			return Plugin_Changed;
		}
	}
	if(attacker <= 0)
		return Plugin_Continue;

	if(!npc.Anger)
	{
		if(GetEntProp(npc.index, Prop_Data, "m_iHealth") <= (ReturnEntityMaxHealth(npc.index) / 2))
		{	
			npc.Anger = true;
			ApplyStatusEffect(npc.index, npc.index, "Very Defensive Backup", 10.0);
		//	ApplyStatusEffect(npc.index, npc.index, "Umbral Grace Debuff", 10.0);
			ApplyStatusEffect(npc.index, npc.index, "Umbral Grace", 10.0);
			CPrintToChatAll("{pink}Reila {snow}gets enveloped in an Umbral Aura...");
		}
	}
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	if(npc.m_flReflectInMode > GetGameTime(npc.index))
	{
		damagePosition[2] += 30.0;
		npc.DispatchParticleEffect(npc.index, "medic_resist_match_bullet_blue", damagePosition, NULL_VECTOR, NULL_VECTOR);
		damagePosition[2] -= 30.0;
		npc.m_flDamageTaken += (damage * 0.5);
	}
	return Plugin_Changed;
}


public void BossReila_NPCDeath(int entity)
{
	BossReila npc = view_as<BossReila>(entity);
	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
	if(GameRules_GetRoundState() == RoundState_ZombieRiot && i_RaidGrantExtra[entity] != 2)
	{
		Waves_ClearWave();
		for(int i; i < i_MaxcountNpcTotal; i++)
		{
			int entitynpc = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
			if(IsValidEntity(entitynpc))
			{
				if(entitynpc != INVALID_ENT_REFERENCE && IsEntityAlive(entitynpc) && GetTeam(npc.index) == GetTeam(entitynpc))
				{
					SmiteNpcToDeath(entitynpc);
				}
			}
		}
	}
		
	TE_Particle("pyro_blast", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
	TE_Particle("pyro_blast_lines", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
	TE_Particle("pyro_blast_warp", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
	TE_Particle("pyro_blast_flash", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
	EmitCustomToAll("zombiesurvival/internius/blinkarrival.wav", npc.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME * 2.0);
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

void BossReilaSelfDefense(BossReila npc, float gameTime, int target, float distance)
{
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
				
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 400.0;
				//	if(ShouldNpcDealBonusDamage(target))
				//		damageDealt *= 5.5;

				//	SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);
					SonOfOsiris_Lightning_Strike(npc.index, target, damageDealt, GetTeam(npc.index) == TFTeam_Red);

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
				npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM2");
						
				npc.m_flAttackHappens = gameTime + 0.25;
				npc.m_flDoingAnimation = gameTime + 0.25;
				npc.m_flNextMeleeAttack = gameTime + 0.85;
			}
		}
	}
}



void ReilaCreateBeacon(int iNpc)
{
	BossReila npc = view_as<BossReila>(iNpc);
	if(!npc.m_flBossSpawnBeacon)
		return;

	npc.m_flBossSpawnBeacon = 0.0;
	
	float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
	int EndFound = FindInfoTargetInt("reila_beacon_spawner");
	if(IsValidEntity(EndFound))
	{
		GetEntPropVector(EndFound, Prop_Data, "m_vecAbsOrigin", pos);
	}
	int summon = NPC_CreateByName("npc_beacon_reila", -1, pos, {0.0,0.0,0.0}, GetTeam(npc.index));
	if(IsValidEntity(summon))
	{
		BossReila npcsummon = view_as<BossReila>(summon);
		if(GetTeam(npc.index) != TFTeam_Red)
			Zombies_Currently_Still_Ongoing++;

		npcsummon.m_iTargetAlly = iNpc;
		SetEntProp(summon, Prop_Data, "m_iHealth", ReturnEntityMaxHealth(npc.index)/3);
		SetEntProp(summon, Prop_Data, "m_iMaxHealth", ReturnEntityMaxHealth(npc.index)/3);
		NpcStats_CopyStats(npc.index, summon);
		if(!IsValidEntity(EndFound))
			TeleportDiversioToRandLocation(summon,_,2500.0, 1250.0);

		if(npc.m_iBleedType == BLEEDTYPE_UMBRAL)
		{
			SetEntityRenderFx(npcsummon.index, RENDERFX_DISTORT);
			SetEntityRenderColor(npcsummon.index, GetRandomInt(25, 255), GetRandomInt(25, 255), GetRandomInt(25, 255), 255);
			SetEntityRenderFx(npcsummon.m_iWearable1, RENDERFX_DISTORT);
			SetEntityRenderColor(npcsummon.m_iWearable1, GetRandomInt(25, 255), GetRandomInt(25, 255), GetRandomInt(25, 255), 255);
			SetEntityRenderFx(npcsummon.m_iWearable2, RENDERFX_DISTORT);
			SetEntityRenderColor(npcsummon.m_iWearable2, GetRandomInt(25, 255), GetRandomInt(25, 255), GetRandomInt(25, 255), 255);
		}
	}
}

void ReilaSpawnBalls(int iNpc, float vecTarget[3])
{
	BossReila npc = view_as<BossReila>(iNpc);
	if(npc.m_flSpawnBallsDoingCD < GetGameTime(npc.index) && npc.m_iBallsLeftToSpawn >= 1)
	{
		npc.m_iBallsLeftToSpawn--;
		npc.m_flSpawnBallsDoingCD = GetGameTime(npc.index) + 0.75;					
		int projectile = npc.FireParticleRocket(vecTarget, 2000.0, 400.0, 150.0, "halloween_rockettrail", true);
		float ang_Look[3];
		GetEntPropVector(projectile, Prop_Send, "m_angRotation", ang_Look);
		Initiate_HomingProjectile(projectile,
			npc.index,
			70.0,			// float lockonAngleMax,
			10.0,				//float homingaSec,
			false,				// bool LockOnlyOnce,
			true,				// bool changeAngles,
			ang_Look);// float AnglesInitiate[3]);

		WandProjectile_ApplyFunctionToEntity(projectile, Reila_Rocket_Particle_StartTouch);	
		SDKHook(projectile, SDKHook_ThinkPost, Reila_Rocket_Particle_Think);
		npc.AddGesture("ACT_MP_GESTURE_VC_FISTPUMP_MELEE");
		npc.PlaySpawnSound();
		float flPos[3], flAng[3];
		npc.GetAttachment("effect_hand_l", flPos, flAng);
		spawnRing_Vectors(flPos, 50.0 * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 80, 32, 120, 200, 1, /*duration*/ 0.25, 2.0, 0.0, 1, 1.0);
		
	}
	if(npc.m_flSpawnBallsCD < GetGameTime(npc.index))
	{
		npc.m_iBallsLeftToSpawn = 4;
		npc.m_flSpawnBallsCD = GetGameTime(npc.index) + 15.0;
	}
}
bool ReilaReflectDamageDo(int iNpc)
{
	BossReila npc = view_as<BossReila>(iNpc);

	if(npc.m_flReflectStatusCD < GetGameTime(npc.index) && npc.m_iBallsLeftToSpawn <= 0)
	{
		npc.m_flReflectInMode = GetGameTime(npc.index) + 2.3;
		npc.m_flReflectStatusCD = GetGameTime(npc.index) + 10.0;
		npc.m_flDamageTaken = 0.0;
		if(npc.m_iChanged_WalkCycle != 2)
		{
			npc.AddActivityViaSequence("taunt09");
			npc.SetPlaybackRate(0.1);
			npc.SetCycle(0.776);
			npc.StopPathing();
			npc.m_bisWalking = false;
			int LayerDo = npc.AddGesture("ACT_MP_ATTACK_STAND_GRENADE");
			npc.SetLayerPlaybackRate(LayerDo, 0.0);
			npc.SetLayerCycle(LayerDo, 0.0);
			npc.m_iChanged_WalkCycle = 2;
			npc.m_flSpeed = 0.0;
		}
		//500 base dmg
	}

	if(npc.m_flReflectInMode)
	{
		float TimeLeft = npc.m_flReflectInMode - GetGameTime(npc.index);
		if(TimeLeft <= 1.2)
		{
			TimeLeft *= 1.5;
			if(npc.m_iChanged_WalkCycle != 3)
			{
				EmitCustomToAll(g_nightmare_cannon_core_sound[GetRandomInt(0, sizeof(g_nightmare_cannon_core_sound) - 1)], _, _, SNDLEVEL_RAIDSIREN, _, RAIDBOSSBOSS_ZOMBIE_VOLUME, 160);
				EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], _, _, SNDLEVEL_RAIDSIREN, _, RAIDBOSSBOSS_ZOMBIE_VOLUME, 80);
			
				npc.m_iChanged_WalkCycle = 3;
			}
			if(TimeLeft >= 1.0)
				TimeLeft = 1.0;

			if(TimeLeft <= 0.0)
				TimeLeft = 0.0;

			TimeLeft -= 1.0;
			TimeLeft *= -1.0;

			float VecAngles[3];
			GetEntPropVector(npc.index, Prop_Data, "m_angRotation", VecAngles);
			Reila_DrawBigAssLaser(VecAngles, npc.index, TimeLeft * 2.0);
		}
		else
		{
			npc.PlayChargeMeleeHit();
			float flPos[3], flAng[3];
			npc.GetAttachment("effect_hand_r", flPos, flAng);
			spawnRing_Vectors(flPos, 50.0 * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 80, 32, 120, 200, 1, /*duration*/ 0.25, 2.0, 0.0, 1, 1.0);
		}
		
		if(npc.m_flReflectInMode < GetGameTime(npc.index))
		{
			npc.m_flReflectInMode = 0.0;
		}	
		return true;
	}
	return false;
}




void Reila_DrawBigAssLaser(float Angles[3], int client, float AngleDeviation = 1.0)
{
	BossReila npc = view_as<BossReila>(client);
	Angles[1] -= (30.0 * AngleDeviation);
	float vecForward[3];
	GetAngleVectors(Angles, vecForward, NULL_VECTOR, NULL_VECTOR);
	float LaserFatness = 25.0;
	int Colour[4];

	float VecMe[3]; WorldSpaceCenter(client, VecMe);
	Ruina_Laser_Logic Laser;
	float Distance = 500.0;
	Laser.client = client;
	Laser.DoForwardTrace_Custom(Angles, VecMe, Distance);
	Laser.Damage = 500.0;                //how much dmg should it do?        //100.0*RaidModeScaling
	Laser.Bonus_Damage = 1500.0;            //dmg vs things that should take bonus dmg.
	Laser.damagetype = DMG_PLASMA;        //dmg type.
	Laser.Radius = LaserFatness;                //how big the radius is / hull.
	Laser.Deal_Damage();
	Colour = {0,25,180, 125};
	if(!IsValidEntity(npc.m_iWearable7))
	{
		npc.m_iWearable7 = ParticleEffectAt(Laser.End_Point, "raygun_projectile_blue_crit", 0.0);
	}
	else
	{
		TeleportEntity(npc.m_iWearable7, Laser.End_Point, NULL_VECTOR, NULL_VECTOR);
	}
	ReilaBeamEffect(Laser.Start_Point, Laser.End_Point, Colour, LaserFatness * 2.0);

	Angles[1] += (60.0 * AngleDeviation);
	
	Laser.DoForwardTrace_Custom(Angles, VecMe, Distance);
	Laser.Deal_Damage();
	Colour = {120,25,0, 125};
	if(!IsValidEntity(npc.m_iWearable9))
	{
		npc.m_iWearable9 = ParticleEffectAt(Laser.End_Point, "raygun_projectile_red_crit", 0.0);
	}
	else
	{
		TeleportEntity(npc.m_iWearable9, Laser.End_Point, NULL_VECTOR, NULL_VECTOR);
	}
	ReilaBeamEffect(Laser.Start_Point, Laser.End_Point, Colour, LaserFatness * 2.0);

}


static void ReilaBeamEffect(float startPoint[3], float endPoint[3], int color[4], float diameter)
{
	int colorLayer4[4];
	SetColorRGBA(colorLayer4, color[0], color[1], color[2], color[3]);
	int colorLayer3[4];
	SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, color[3]);
	int colorLayer2[4];
	SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, color[3]);
	int colorLayer1[4];
	SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, color[3]);
	TE_SetupBeamPoints(startPoint, endPoint, g_Ruina_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 1.0, colorLayer1, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(startPoint, endPoint, g_Ruina_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.5 * 1.28), ClampBeamWidth(diameter * 0.5 * 1.28), 0, 1.0, colorLayer2, 3);
	TE_SendToAll(0.0);
//	TE_SetupBeamPoints(startPoint, endPoint, g_Ruina_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.8 * 1.28), ClampBeamWidth(diameter * 0.8 * 1.28), 0, 1.0, colorLayer3, 3);
//	TE_SendToAll(0.0);
// I have removed one TE as its way too many te's at once.
	TE_SetupBeamPoints(startPoint, endPoint, g_Ruina_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 1.0, colorLayer4, 3);
	TE_SendToAll(0.0);
	int glowColor[4];
	SetColorRGBA(glowColor, color[0], color[1], color[2], color[3]);
	TE_SetupBeamPoints(startPoint, endPoint, g_Ruina_BEAM_Glow, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 5.0, glowColor, 0);
	TE_SendToAll(0.0);
}


public void Reila_Rocket_Particle_StartTouch(int entity, int target)
{
	if(target > 0 && target < MAXENTITIES)	//did we hit something???
	{
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		if(!IsValidEntity(owner))
		{
			owner = 0;
		}
		
		int inflictor = h_ArrowInflictorRef[entity];
		if(inflictor != -1)
			inflictor = EntRefToEntIndex(h_ArrowInflictorRef[entity]);

		if(inflictor == -1)
			inflictor = owner;
			
		float ProjectileLoc[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
		float DamageDeal = fl_rocket_particle_dmg[entity];
		if(ShouldNpcDealBonusDamage(target))
			DamageDeal *= h_BonusDmgToSpecialArrow[entity];


		SDKHooks_TakeDamage(target, owner, inflictor, DamageDeal, DMG_BULLET|DMG_PREVENT_PHYSICS_FORCE, -1);	//acts like a kinetic rocket
				
		Reila_Rocket_Particle_Think(entity);
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
	}
	else
	{
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		//we uhh, missed?
		Reila_Rocket_Particle_Think(entity);
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
	}
	RemoveEntity(entity);
}


#define REILA_BOSS_LIGHTNING_RANGE 150.0

#define REILA_BOSS_CHARGE_TIME 1.5
#define REILA_BOSS_CHARGE_SPAN 0.5

void Reila_Rocket_Particle_Think(int entity)
{
	float gameTime = GetGameTime();
	
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if (!IsValidEntity(owner))
		owner = 0;
	
	if (!owner)
	{
		RemoveEntity(entity);
		return;
	}
	BossReila npc = view_as<BossReila>(owner);
	
	float vecPos[3], VecDown[3];
	GetAbsOrigin(entity, vecPos);
	
	float velocity[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsVelocity", velocity);
	velocity[2] += 300.0;
	TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, velocity);		

	VecDown = vecPos;
	VecDown[2] -= 1000.0;
	static const float maxs[] = { 10.0, 10.0, 10.0 };
	static const float mins[] = { -10.0, -10.0, -10.0 };
	Handle trace;
	trace = TR_TraceHullFilterEx(vecPos, VecDown,mins,maxs , MASK_NPCSOLID, TraceRayHitWorldOnly);
	if(TR_DidHit(trace))
	{
		TR_GetEndPosition(VecDown, trace);
		//spawn lighting
				
		Handle pack;
		CreateDataTimer(REILA_BOSS_CHARGE_SPAN, Smite_Timer_REILA_BOSS, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		WritePackCell(pack, EntIndexToEntRef(npc.index));
		WritePackFloat(pack, 0.0);
		WritePackFloat(pack, VecDown[0]);
		WritePackFloat(pack, VecDown[1]);
		WritePackFloat(pack, VecDown[2]);
		WritePackFloat(pack, 1000.0);
		spawnBeam(0.8, 120, 50, 200, 200, "materials/sprites/laserbeam.vmt", 3.0, 0.2, _, 10.0, vecPos, VecDown);	
		EmitSoundToAll("weapons/vaccinator_charge_tier_03.wav", _, SNDCHAN_AUTO, 70, _, 0.65, GetRandomInt(80, 110), _, VecDown);
		spawnRing_Vectors(VecDown, REILA_BOSS_LIGHTNING_RANGE * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 100, 50, 150, 200, 1, REILA_BOSS_CHARGE_TIME, 6.0, 0.1, 1, 1.0);
		
	}
	delete trace;
	CBaseCombatCharacter(entity).SetNextThink(gameTime + 1.0);
}


public Action Smite_Timer_REILA_BOSS(Handle Smite_Logic, DataPack pack)
{
	ResetPack(pack);
	int entity = EntRefToEntIndex(ReadPackCell(pack));
	
	if (!IsValidEntity(entity))
	{
		return Plugin_Stop;
	}
		
	float NumLoops = ReadPackFloat(pack);
	float spawnLoc[3];
	for (int GetVector = 0; GetVector < 3; GetVector++)
	{
		spawnLoc[GetVector] = ReadPackFloat(pack);
	}
	
	float damage = ReadPackFloat(pack);
	
	if (NumLoops >= REILA_BOSS_CHARGE_TIME)
	{
		float secondLoc[3];
		for (int replace = 0; replace < 3; replace++)
		{
			secondLoc[replace] = spawnLoc[replace];
		}
		
		for (int sequential = 1; sequential <= 3; sequential++)
		{
			spawnRing_Vectors(secondLoc, 1.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 120, 50, 200, 120, 1, 0.33, 6.0, 0.4, 1, (REILA_BOSS_LIGHTNING_RANGE * 5.0)/float(sequential));
			secondLoc[2] += 150.0 + (float(sequential) * 20.0);
		}
		
		secondLoc[2] = 1500.0;
		
		spawnBeam(0.8, 120, 50, 200, 255, "materials/sprites/laserbeam.vmt", 4.0, 6.2, _, 2.0, secondLoc, spawnLoc);	
		spawnBeam(0.8, 120, 50, 200, 200, "materials/sprites/lgtning.vmt", 4.0, 5.2, _, 2.0, secondLoc, spawnLoc);	
		spawnBeam(0.8, 120, 50, 200, 200, "materials/sprites/lgtning.vmt", 3.0, 4.2, _, 2.0, secondLoc, spawnLoc);	
		
		EmitSoundToAll("ambient/explosions/explode_9.wav", _, SNDCHAN_AUTO, 75, _, 0.5, 110, _, spawnLoc);
		
		DataPack pack_boom = new DataPack();
		pack_boom.WriteFloat(spawnLoc[0]);
		pack_boom.WriteFloat(spawnLoc[1]);
		pack_boom.WriteFloat(spawnLoc[2]);
		pack_boom.WriteCell(0);
		RequestFrame(MakeExplosionFrameLater, pack_boom);
		
		Explode_Logic_Custom(damage, entity, entity, -1, spawnLoc, REILA_BOSS_LIGHTNING_RANGE * 1.4,_,0.8, true);  //Explosion range increase
	
		return Plugin_Stop;
	}
	else
	{
		spawnRing_Vectors(spawnLoc, REILA_BOSS_LIGHTNING_RANGE * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 120, 50, 200, 120, 1, 0.33, 6.0, 0.1, 1, 1.0);
		ResetPack(pack);
		WritePackCell(pack, EntIndexToEntRef(entity));
		WritePackFloat(pack, NumLoops + REILA_BOSS_CHARGE_TIME);
		WritePackFloat(pack, spawnLoc[0]);
		WritePackFloat(pack, spawnLoc[1]);
		WritePackFloat(pack, spawnLoc[2]);
		WritePackFloat(pack, damage);
	}
	
	return Plugin_Continue;
}


static void spawnBeam(float beamTiming, int r, int g, int b, int a, char sprite[PLATFORM_MAX_PATH], float width=2.0, float endwidth=2.0, int fadelength=1, float amp=15.0, float startLoc[3] = {0.0, 0.0, 0.0}, float endLoc[3] = {0.0, 0.0, 0.0})
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



bool Reila_LossAnimation(int iNpc)
{
	BossReila npc = view_as<BossReila>(iNpc);
	if(npc.m_flDoLoseTalk)
	{
		GiveProgressDelay(4.0);
		if(npc.m_flDoLoseTalk < GetGameTime())
		{
			switch(i_RaidGrantExtra[npc.index])
			{
				case 2:
				{
					CPrintToChatAll("{pink}Reila {snow}she tries to talk but you understand nothing..");
					CPrintToChatAll("{pink}Reila :{default} ∴╎ᒷᓭ𝙹 ⍊ᒷ∷ᓭ⚍ᓵ⍑ᓭℸ ̣ ↸⚍ ᒲ╎ᓵ⍑ ᔑ⚍⎓⨅⚍⍑ꖎℸ ̣ᒷリ??...");
				}
				case 3:
				{
					CPrintToChatAll("{pink}Reila :{default} ∴ᔑ∷ℸ ̣ᒷ ᒲᔑꖎ, ʖ╎ᓭℸ ̣ ↸⚍ üʖᒷ∷⍑ᔑ!¡ℸ ̣ ⍊𝙹リ Almagest? ↸⚍ ꖌᔑリリᓭℸ ̣ ᒲ╎ᓵ⍑ リ╎ᓵ⍑ℸ ̣ ⍊ᒷ∷ᓭℸ ̣ᒷ⍑ᒷリ 𝙹↸ᒷ∷?");
				}
				case 4:
				{
					CPrintToChatAll("{black}Izan :{default} ... Great, languge barrier.");
				}
				case 5:
				{
					CPrintToChatAll("{black}Izan {snow} Shakes his head and points at his ears, then shrugs.");
				}
				case 6:
				{
					CPrintToChatAll("{snow}She hands over something, and asks to leave via gesture...");
					npc.AddGesture("ACT_MP_GESTURE_VC_FINGERPOINT_MELEE");
				}
				case 7:
				{
					CPrintToChatAll("{black}Izan {snow}Allows her to leave.");
				}
				case 8:
				{
					CPrintToChatAll("{black}Izan :{default} Now we have a whole other group to worry about.");
					RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
				}
			}
			i_RaidGrantExtra[npc.index]++;
			npc.m_flDoLoseTalk = GetGameTime() + 3.0;
		}
		return true;
	}
	return false;
}

