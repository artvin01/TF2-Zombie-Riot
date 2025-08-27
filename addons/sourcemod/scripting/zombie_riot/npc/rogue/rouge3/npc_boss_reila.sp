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
	"mvm/mvm_tele_deliver.wav",
};

static int NPCId;
void BossReila_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
//	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds)); i++) { PrecacheSound(g_RangedAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_ReilaChargeMeleeDo)); i++) { PrecacheSound(g_ReilaChargeMeleeDo[i]); }
	for (int i = 0; i < (sizeof(g_SpawnSoundDrones)); i++) { PrecacheSound(g_SpawnSoundDrones[i]); }
	PrecacheModel("models/player/medic.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Reila");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_boss_reila");
	strcopy(data.Icon, sizeof(data.Icon), "heavy");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Interitus;
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
	return;
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
		EmitSoundToAll(g_SpawnSoundDrones[GetRandomInt(0, sizeof(g_SpawnSoundDrones) - 1)], _, _, _, _, 0.65);
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

	public BossReila(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		BossReila npc = view_as<BossReila>(CClotBody(vecPos, vecAng, "models/player/engineer.mdl", "1.0", "3000", ally));
		
		i_NpcWeight[npc.index] = 4;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		SetVariantInt(3);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		npc.SetActivity("ACT_MP_RUN_ITEM2");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		npc.m_bDissapearOnDeath = true;

		func_NPCDeath[npc.index] = view_as<Function>(BossReila_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(BossReila_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(BossReila_ClotThink);
		npc.m_flReflectStatusCD = GetGameTime() + 5.0;
		

		if(!IsValidEntity(RaidBossActive))
		{
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidModeTime = GetGameTime(npc.index) + 9000.0;
			RaidAllowsBuildings = true;
			RaidModeScaling = 0.0;
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

		CPrintToChatAll("{pink}Reila{default} : .");
		

		return npc;
	}
}

public void BossReila_ClotThink(int iNPC)
{
	BossReila npc = view_as<BossReila>(iNPC);
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
		if(IsValidEntity(npc.m_iWearable10))
			RemoveEntity(npc.m_iWearable10);
		npc.SetActivity("ACT_MP_RUN_ITEM2");
		npc.RemoveGesture("ACT_MP_ATTACK_STAND_GRENADE");
		npc.m_iChanged_WalkCycle = 1;
		npc.m_flSpeed = 330.0;
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
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	if(npc.m_flReflectInMode > GetGameTime(npc.index))
	{
		npc.m_flDamageTaken += (damage * 0.25);
	}
	return Plugin_Changed;
}


public void BossReila_NPCDeath(int entity)
{
	BossReila npc = view_as<BossReila>(entity);
	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
		
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




bool ReilaReflectDamageDo(int iNpc)
{
	BossReila npc = view_as<BossReila>(iNpc);

	if(npc.m_flReflectStatusCD < GetGameTime(npc.index))
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
			npc.m_flReflectInMode = false;
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

	float VectorForward = 5000.0; //a really high number.

	float VecMe[3]; WorldSpaceCenter(client, VecMe);
	Ruina_Laser_Logic Laser;
	float Distance = 500.0;
	Laser.client = client;
	Laser.DoForwardTrace_Custom(Angles, VecMe, Distance);
	Laser.Damage = 500.0;                //how much dmg should it do?        //100.0*RaidModeScaling
	Laser.Bonus_Damage = 150.0;            //dmg vs things that should take bonus dmg.
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