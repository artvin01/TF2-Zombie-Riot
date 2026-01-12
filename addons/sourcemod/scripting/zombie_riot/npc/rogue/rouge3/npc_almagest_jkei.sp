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

static const char g_JkeiChargeMeleeDo[][] =
{
	"weapons/vaccinator_charge_tier_01.wav",
};

static const char g_MeleeHitSoundjkei[][] = {
	"weapons/halloween_boss/knight_axe_hit.wav",
};
static const char g_SpawnSoundDrones[][] = {
	"mvm/mvm_tele_deliver.wav",
};

static int NPCId;
void AlmagestJkei_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSoundjkei)); i++) { PrecacheSound(g_MeleeHitSoundjkei[i]); }
	for (int i = 0; i < (sizeof(g_JkeiChargeMeleeDo)); i++) { PrecacheSound(g_JkeiChargeMeleeDo[i]); }
	for (int i = 0; i < (sizeof(g_SpawnSoundDrones)); i++) { PrecacheSound(g_SpawnSoundDrones[i]); }
	PrecacheModel("models/player/medic.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Jkei");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_almagest_jkei");
	strcopy(data.Icon, sizeof(data.Icon), "rbf_jkei");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Curtain;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPCId = NPC_Add(data);
}

int Almagest_JkeiID()
{
	return NPCId;
}
static void ClotPrecache()
{
	PrecacheSoundCustom("#zombiesurvival/rogue3/rogue3_almagestboss.mp3");
	NPC_GetByPlugin("npc_jkei_drone");
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return AlmagestJkei(vecPos, vecAng, team, data);
}

methodmap AlmagestJkei < CClotBody
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
			EmitSoundToAll(g_MeleeHitSoundjkei[GetRandomInt(0, sizeof(g_MeleeHitSoundjkei) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		else
			EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayChargeMeleeHit() 
	{
		EmitSoundToAll(g_JkeiChargeMeleeDo[GetRandomInt(0, sizeof(g_JkeiChargeMeleeDo) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);

	}
	public void SetJkeiSpeed(float speed) 
	{
		if(HasSpecificBuff(this.index, "Unstoppable Force"))
			speed *= 0.75;
		this.m_flSpeed = speed;
	}
	property float m_flSummonCircularDudes
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property int m_iBattleStageAt
	{
		public get()							{ return i_OverlordComboAttack[this.index]; }
		public set(int TempValueForProperty) 	{ i_OverlordComboAttack[this.index] = TempValueForProperty; }
	}
	property int m_iDroneLevelAt
	{
		public get()							{ return i_MedkitAnnoyance[this.index]; }
		public set(int TempValueForProperty) 	{ i_MedkitAnnoyance[this.index] = TempValueForProperty; }
	}
	property float m_flMegaSlashCD
	{
		public get()							{ return fl_AbilityOrAttack[this.index][4]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][4] = TempValueForProperty; }
	}
	property float m_flMegaSlashDoing
	{
		public get()							{ return fl_AbilityOrAttack[this.index][5]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][5] = TempValueForProperty; }
	}
	property float m_flMegaSlashNext
	{
		public get()							{ return fl_AbilityOrAttack[this.index][6]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][6] = TempValueForProperty; }
	}
	property int m_iLayerSave
	{
		public get()							{ return i_AttacksTillMegahit[this.index]; }
		public set(int TempValueForProperty) 	{ i_AttacksTillMegahit[this.index] = TempValueForProperty; }
	}
	public int EquipItemSword(
	const char[] attachment,
	const char[] model,
	const char[] anim = "",
	int skin = 0,
	float model_size = 1.0)
	{
		int item = CreateEntityByName("prop_dynamic_override");
		if(!IsValidEntity(item))
		{
			PrintToServer("Failed!!! Retry!!!!");
			//warning, warning!!!
			//infinite loop this untill it works!
			//Tf2 has a very very very low chance to fail to spawn a prop, because reasons!
			return this.EquipItemSword(
			attachment,
			model,
			anim,
			skin,
			model_size);
		}
		DispatchKeyValue(item, "model", model);

		if(model_size != 1.0)
		{
		//	DispatchKeyValueFloat(item, "modelscale", GetEntPropFloat(this.index, Prop_Send, "m_flModelScale"));
			DispatchKeyValueFloat(item, "modelscale", model_size);
		}
		DispatchSpawn(item);
		SetEntProp(item, Prop_Send, "m_fEffects", EF_BONEMERGE|EF_PARENT_ANIMATES|EF_NOSHADOW );
		SetEntityMoveType(item, MOVETYPE_NONE);
		SetEntProp(item, Prop_Data, "m_nNextThinkTick", -1.0);
	
		if(anim[0])
		{
			SetVariantString(anim);
			AcceptEntityInput(item, "SetAnimation");
		}
		b_ThisEntityIgnored[item] = true;

#if defined RPG
		SetEntPropFloat(item, Prop_Send, "m_fadeMinDist", 1600.0);
		SetEntPropFloat(item, Prop_Send, "m_fadeMaxDist", 1800.0);
#endif

		this.m_iWearable5 = Trail_Attach(item, ARROW_TRAIL, 255, 1.0, 40.0, 3.0, 5);
		SetEntityRenderColor(this.m_iWearable5, 80, 32, 120, 255);
		SetVariantString("!activator");
		AcceptEntityInput(item, "SetParent", this.index);

		if(attachment[0])
		{
			SetVariantString(attachment);
			AcceptEntityInput(item, "SetParentAttachmentMaintainOffset"); 
		}	
		SetEntProp(item, Prop_Send, "m_nSkin", skin);
		
		MakeObjectIntangeable(item);

		return item;
	}

	
	public AlmagestJkei(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		if(StrContains(data, "battle_stage_2") != -1)
		{
			for(int i; i < i_MaxcountNpcTotal; i++)
			{
				int other = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
				if(other != -1 && i_NpcInternalId[other] == Almagest_JkeiID() && IsEntityAlive(other))
				{
					if(HasSpecificBuff(other, "Unstoppable Force"))
						fl_Extra_Damage[other] 	*= (1.0 / 0.75);
					RemoveSpecificBuff(other, "Unstoppable Force");
					view_as<AlmagestJkei>(other).SetJkeiSpeed(330.0);
					if(view_as<AlmagestJkei>(other).m_flMegaSlashDoing)
						view_as<AlmagestJkei>(other).SetJkeiSpeed(150.0);
					CPrintToChatAll("{black}Jkei{crimson} gains more strength.");
					f_AttackSpeedNpcIncrease[other] *= 0.85;
				//	fl_Extra_Speed[other] 	*= 1.05;
					fl_Extra_Damage[other] 	*= 1.2;
					fl_TotalArmor[other] *= 0.85;
					i_OverlordComboAttack[other] = 2;
					return view_as<AlmagestJkei>(-1);
				}
			}
		}
		if(StrContains(data, "battle_stage_3") != -1)
		{
			for(int i; i < i_MaxcountNpcTotal; i++)
			{
				int other = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
				if(other != -1 && i_NpcInternalId[other] == Almagest_JkeiID() && IsEntityAlive(other))
				{
					if(!HasSpecificBuff(other, "Unstoppable Force"))
						fl_Extra_Damage[other] 	*= (1.0 / 0.75);
					RemoveSpecificBuff(other, "Unstoppable Force");
					view_as<AlmagestJkei>(other).SetJkeiSpeed(330.0);
					if(view_as<AlmagestJkei>(other).m_flMegaSlashDoing)
						view_as<AlmagestJkei>(other).SetJkeiSpeed(150.0);
					CPrintToChatAll("{black}Jkei{crimson} gains more strength, Now's the time to kill him off!");
					RemoveFromNpcAliveList(other);
					AddNpcToAliveList(other, 0);
					f_AttackSpeedNpcIncrease[other] *= 0.8;
				//s	fl_Extra_Speed[other] 	*= 1.05;
					fl_Extra_Damage[other] 	*= 1.25;
					fl_TotalArmor[other] *= 0.7;
					i_OverlordComboAttack[other] = 3;
					return view_as<AlmagestJkei>(-1);
				}
			}
		}
		AlmagestJkei npc = view_as<AlmagestJkei>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.35", "3000", ally, false, true));
		
		i_NpcWeight[npc.index] = 4;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		npc.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		
		
		if(StrContains(data, "force_final_battle") != -1)
		{
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidModeTime = GetGameTime(npc.index) + 9000.0;
			RaidAllowsBuildings = true;
			RaidModeScaling = 0.0;
			MusicEnum music;
			strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/rogue3/rogue3_almagestboss.mp3");
			music.Time = 101;
			music.Volume = 0.65;
			music.Custom = true;
			strcopy(music.Name, sizeof(music.Name), "Nostaglica");
			strcopy(music.Artist, sizeof(music.Artist), "I HATE MODELS");
			Music_SetRaidMusic(music);
			npc.m_iBattleStageAt = 3;
		}
		else
		{
			AddNpcToAliveList(npc.index, 1);
			npc.m_iBattleStageAt = 1;
		}
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		npc.m_flSummonCircularDudes = GetGameTime() + 10.0;

		func_NPCDeath[npc.index] = view_as<Function>(AlmagestJkei_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(AlmagestJkei_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(AlmagestJkei_ClotThink);
		
		
		
		if(!IsValidEntity(RaidBossActive))
		{
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidModeTime = GetGameTime(npc.index) + 9000.0;
			RaidAllowsBuildings = true;
			RaidModeScaling = 0.0;
		}
		if(StrContains(data, "force_final_battle") != -1)
		{
			RaidAllowsBuildings = false;
		}
		npc.StartPathing();
		npc.SetJkeiSpeed(330.0);
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/player/items/medic/medic_mtg.mdl");
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/medic/hwn2023_medical_mummy/hwn2023_medical_mummy.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/sf14_vampiric_vesture/sf14_vampiric_vesture.mdl");
		npc.m_iWearable4 = npc.EquipItemSword("head", "models/workshop_partner/weapons/c_models/c_shogun_katana/c_shogun_katana_soldier.mdl");
		SetEntityRenderColor(npc.m_iWearable4, 80, 32, 120, 255);
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 2);
		CPrintToChatAll("{black}Jkei{default} : ∴ᒷリリ ↸⚍ ⨅⚍ {black}Shadowing darkness{default}... ⍑ ∴ᔑ∷ℸ ̣ᒷ ᒲᔑꖎ, ↸⚍ ∴╎∷ᓭℸ ̣ ᒷ⍑ ⊣ꖎᒷ╎ᓵ⍑ ⍊ᒷ∷∷ᒷᓵꖌᒷリ.");
		

		return npc;
	}
}

public void AlmagestJkei_ClotThink(int iNPC)
{
	AlmagestJkei npc = view_as<AlmagestJkei>(iNPC);
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
	Jkei_CreateDrones(npc.index);
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
		AlmagestJkeiSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action AlmagestJkei_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	AlmagestJkei npc = view_as<AlmagestJkei>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	float MaxHealthRatioDamage = 1.0;
	switch(npc.m_iBattleStageAt)
	{
		case 1:
			MaxHealthRatioDamage = 0.75;
		case 2:
			MaxHealthRatioDamage = 0.35;
		case 3:
			MaxHealthRatioDamage = 0.0;
	}

	if(MaxHealthRatioDamage != 0.0 && !HasSpecificBuff(npc.index, "Unstoppable Force"))
	{
		float CurrentRatio = (float(GetEntProp(npc.index, Prop_Data, "m_iHealth")) + damage) / float(ReturnEntityMaxHealth(npc.index));
		if(CurrentRatio <= MaxHealthRatioDamage)
		{
			CPrintToChatAll("{black}Jkei{crimson} gains a shield, his soldiers give him strength, kill them off.");
			ApplyStatusEffect(npc.index, npc.index, "Unstoppable Force", 9999.0);
			fl_Extra_Damage[npc.index] 	*= 0.75;
			view_as<AlmagestJkei>(npc.index).SetJkeiSpeed(330.0);
			if(npc.m_flMegaSlashDoing)
				view_as<AlmagestJkei>(npc.index).SetJkeiSpeed(150.0);
			damage = 0.0;
			//set to hp
			SetEntProp(npc.index, Prop_Data, "m_iHealth", RoundToNearest(float(ReturnEntityMaxHealth(npc.index)) * MaxHealthRatioDamage));
			return Plugin_Changed;
		}
	}

	return Plugin_Changed;
}


public void AlmagestJkei_NPCDeath(int entity)
{
	AlmagestJkei npc = view_as<AlmagestJkei>(entity);
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

void AlmagestJkeiSelfDefense(AlmagestJkei npc, float gameTime, int target, float distance)
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

						Elemental_AddVoidDamage(target, npc.index, 150, true, true);

					}
					npc.PlayMeleeHitSound();
				} 
			}
			delete swingTrace;
			npc.m_flMegaSlashNext = 0.0;
			npc.SetJkeiSpeed(330.0);
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
					npc.SetJkeiSpeed(150.0);
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


void Jkei_CreateDrones(int iNpc)
{
	AlmagestJkei npc = view_as<AlmagestJkei>(iNpc);
	if(npc.m_flSummonCircularDudes > GetGameTime(iNpc))
	{
		return;
	}
	npc.m_iDroneLevelAt++;
	npc.m_flSummonCircularDudes = GetGameTime(iNpc) + 30.0;
	int MaxenemySpawnScaling = 2;
	MaxenemySpawnScaling = RoundToNearest(float(MaxenemySpawnScaling) * MultiGlobalEnemy);
	npc.AddGesture("ACT_MP_GESTURE_VC_FISTPUMP_MELEE");
	npc.PlaySpawnSound();
	float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
	TE_Particle("teleported_blue", vecMe, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
	TE_Particle("spell_batball_impact_blue", vecMe, NULL_VECTOR, {0.0,0.0,0.0}, -1, _, _, _, _, _, _, _, _, _, 0.0);

	float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
	int MaxHealthGet = ReturnEntityMaxHealth(npc.index);

	MaxHealthGet = RoundToNearest(float(MaxHealthGet) * 0.003);

	for(int i; i<MaxenemySpawnScaling; i++)
	{
		int summon = NPC_CreateByName("npc_jkei_drone", -1, pos, {0.0,0.0,0.0}, GetTeam(npc.index));
		if(IsValidEntity(summon))
		{
			AlmagestJkei npcsummon = view_as<AlmagestJkei>(summon);
			if(GetTeam(npc.index) != TFTeam_Red)
				Zombies_Currently_Still_Ongoing++;

			npcsummon.m_iTargetAlly = iNpc;
			npcsummon.m_iTargetWalkTo = iNpc;
			npcsummon.m_flNextDelayTime = GetGameTime() + GetRandomFloat(0.1, 0.5);
			npcsummon.m_iDroneLevelAt = npc.m_iDroneLevelAt;
			
			
			SetEntProp(summon, Prop_Data, "m_iHealth", MaxHealthGet);
			SetEntProp(summon, Prop_Data, "m_iMaxHealth", MaxHealthGet);

			NpcStats_CopyStats(npc.index, summon);
			fl_Extra_MeleeArmor[summon] = fl_Extra_MeleeArmor[npc.index];
			fl_Extra_RangedArmor[summon] = fl_Extra_RangedArmor[npc.index];
			fl_Extra_Speed[summon] = fl_Extra_Speed[npc.index];
			fl_Extra_Damage[summon] = fl_Extra_Damage[npc.index];
		}
	}
	//not buildings,
	b_NpcIgnoresbuildings[npc.index] = true;
	Explode_Logic_Custom(0.0, npc.index, npc.index, -1, _, 9999.9, _, _, true, RAIDBOSS_GLOBAL_ATTACKLIMIT,_,_,_,Jkei_SpawnMinionsToEnemy);
	b_NpcIgnoresbuildings[npc.index] = false;
}


void Jkei_SpawnMinionsToEnemy(int entity, int victim, float damage, int weapon)
{
	AlmagestJkei npc = view_as<AlmagestJkei>(entity);
	int MaxHealthGet = ReturnEntityMaxHealth(npc.index);

	float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
	MaxHealthGet = RoundToNearest(float(MaxHealthGet) * 0.003);
	int summon = NPC_CreateByName("npc_jkei_drone", -1, pos, {0.0,0.0,0.0}, GetTeam(npc.index));
	if(IsValidEntity(summon))
	{
		AlmagestJkei npcsummon = view_as<AlmagestJkei>(summon);
		if(GetTeam(npc.index) != TFTeam_Red)
			Zombies_Currently_Still_Ongoing++;

		npcsummon.m_iTargetAlly = npc.index;
		npcsummon.m_iTarget = victim;
		npcsummon.m_flNextDelayTime = GetGameTime() + GetRandomFloat(0.1, 0.5);
		npcsummon.m_iDroneLevelAt = npc.m_iDroneLevelAt;
		
		SetEntProp(summon, Prop_Data, "m_iHealth", MaxHealthGet);
		SetEntProp(summon, Prop_Data, "m_iMaxHealth", MaxHealthGet);

		NpcStats_CopyStats(npc.index, summon);
		fl_Extra_MeleeArmor[summon] = fl_Extra_MeleeArmor[npc.index];
		fl_Extra_RangedArmor[summon] = fl_Extra_RangedArmor[npc.index];
		fl_Extra_Speed[summon] = fl_Extra_Speed[npc.index];
		fl_Extra_Damage[summon] = fl_Extra_Damage[npc.index];
	}
}
