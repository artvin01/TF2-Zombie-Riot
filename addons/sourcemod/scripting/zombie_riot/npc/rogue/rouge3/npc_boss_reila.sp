#pragma semicolon 1
#pragma newdecls required


static const char g_HurtSounds[][] = {
	")physics/metal/metal_box_impact_bullet1.wav",
	")physics/metal/metal_box_impact_bullet2.wav",
	")physics/metal/metal_box_impact_bullet3.wav",
};


static const char g_IdleAlertedSounds[][] = {
	"vo/medic_sf13_spell_super_jump01.mp3",
	"vo/medic_sf13_spell_super_speed01.mp3",
	"vo/medic_sf13_spell_generic04.mp3",
	"vo/medic_sf13_spell_devil_bargain01.mp3",
	"vo/medic_sf13_spell_teleport_self01.mp3",
	"vo/medic_sf13_spell_uber01.mp3",
	"vo/medic_sf13_spell_zombie_horde01.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/cbar_miss1.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/blade_slice_2.wav",
	"weapons/blade_slice_3.wav",
	"weapons/blade_slice_4.wav",
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
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_ReilaChargeMeleeDo)); i++) { PrecacheSound(g_ReilaChargeMeleeDo[i]); }
	for (int i = 0; i < (sizeof(g_SpawnSoundDrones)); i++) { PrecacheSound(g_SpawnSoundDrones[i]); }
	PrecacheModel("models/player/medic.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Reila");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_almagest_Reila");
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
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 90);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.25;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DefaultMedic_DeathSounds[GetRandomInt(0, sizeof(g_DefaultMedic_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
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
		if(this.m_flMegaSlashNext)
			EmitSoundToAll(g_MeleeHitSoundReila[GetRandomInt(0, sizeof(g_MeleeHitSoundReila) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		else
			EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayChargeMeleeHit() 
	{
		EmitSoundToAll(g_ReilaChargeMeleeDo[GetRandomInt(0, sizeof(g_ReilaChargeMeleeDo) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);

	}

	public BossReila(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		BossReila npc = view_as<BossReila>(CClotBody(vecPos, vecAng, "models/player/engineer.mdl", "1.0", "3000", ally));
		
		i_NpcWeight[npc.index] = 4;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		npc.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(BossReila_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(BossReila_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(BossReila_ClotThink);
		
		
		
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
		npc.m_iWearable2 = npc.EquipItem("head", "models/weapons/c_models/c_engineer_gunslinger.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/all_class/sbox2014_zipper_suit/sbox2014_zipper_suit_engineer.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/engineer/hwn2024_delldozer_style2/hwn2024_delldozer_style2.mdl");
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/all_class/robotarm_silver/robotarm_silver_gem.mdl");
		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/all_class/robotarm_silver/robotarm_silver_gem.mdl");

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

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	Reila_CreateDrones(npc.index);
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
	return Plugin_Changed;
}


public void BossReila_NPCDeath(int entity)
{
	BossReila npc = view_as<BossReila>(entity);
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
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 1))//Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
			{
				target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 650.0;
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 5.5;
					if(npc.m_flMegaSlashNext)
					{
						damageDealt *= 3.0;
						SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);
						Elemental_AddVoidDamage(target, npc.index, 600, true, true);
						float pos[3]; GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", pos);
						spawnRing_Vectors(pos, 50.0 * 2.0, 0.0, 0.0, 5.0, 	"materials/sprites/laserbeam.vmt", 80, 32, 120, 255, 1, /*duration*/ 0.45, 3.0, 1.0, 2, 1.0);
						spawnRing_Vectors(pos, 50.0 * 2.0, 0.0, 0.0, 25.0, 	"materials/sprites/laserbeam.vmt", 80, 32, 120, 255, 1, /*duration*/ 0.45, 3.0, 1.0, 2, 1.0);
						spawnRing_Vectors(pos, 50.0 * 2.0, 0.0, 0.0, 45.0, 	"materials/sprites/laserbeam.vmt", 80, 32, 120, 255, 1, /*duration*/ 0.45, 3.0, 1.0, 2, 1.0);
						spawnRing_Vectors(pos, 50.0 * 2.0, 0.0, 0.0, 65.0, 	"materials/sprites/laserbeam.vmt", 80, 32, 120, 255, 1, /*duration*/ 0.45, 3.0, 1.0, 2, 1.0);
					}
					else
					{
						SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);

						Elemental_AddVoidDamage(target, npc.index, 200, true, true);

					}
					npc.PlayMeleeHitSound();
				} 
			}
			delete swingTrace;
			npc.m_flMegaSlashNext = 0.0;
			npc.m_flSpeed = 330.0;
		}
	}
	if(npc.m_flMegaSlashDoing)
	{
		npc.PlayChargeMeleeHit();
		float flPos[3], flAng[3];
		npc.GetAttachment("effect_hand_r", flPos, flAng);
		spawnRing_Vectors(flPos, 50.0 * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 80, 32, 120, 200, 1, /*duration*/ 0.25, 2.0, 0.0, 1, 1.0);	
		if(npc.m_flMegaSlashDoing < gameTime)
		{
			if(npc.IsValidLayer(npc.m_iLayerSave))
			{
				npc.SetLayerPlaybackRate(npc.m_iLayerSave, 1.5);
			}
			npc.m_flMegaSlashDoing = 0.0;
			npc.m_flMegaSlashNext = 1.0;
		}
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
				if(npc.m_flMegaSlashCD < gameTime)
				{
					int Layer;
					Layer = npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS");
					npc.SetLayerPlaybackRate(Layer, 0.0);
					npc.SetLayerCycle(Layer, 0.15);
					npc.m_iLayerSave = Layer;
							
					npc.m_flMegaSlashDoing = gameTime + 1.0;
					npc.m_flAttackHappens = gameTime + 1.25;
					npc.m_flDoingAnimation = gameTime + 1.25;
					npc.m_flNextMeleeAttack = gameTime + 1.75;
					npc.m_flMegaSlashCD = gameTime + 6.5;
					npc.m_flSpeed = 150.0;
				}
				else
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS");
							
					npc.m_flAttackHappens = gameTime + 0.25;
					npc.m_flDoingAnimation = gameTime + 0.25;
					npc.m_flNextMeleeAttack = gameTime + 0.85;
				}
			}
		}
	}
}
