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

void ReilaBeacon_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_ReilaChargeMeleeDo)); i++) { PrecacheSound(g_ReilaChargeMeleeDo[i]); }
	for (int i = 0; i < (sizeof(g_SpawnSoundDrones)); i++) { PrecacheSound(g_SpawnSoundDrones[i]); }
	PrecacheModel("models/player/medic.mdl");
	PrecacheSound("mvm/mvm_bought_in.wav");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Reila's Beacon");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_beacon_reila");
	strcopy(data.Icon, sizeof(data.Icon), "reilaconstruct");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Interitus;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	return;
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return ReilaBeacon(vecPos, vecAng, team);
}

methodmap ReilaBeacon < CClotBody
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
	property float m_flSpawnAnnotation
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}

	public ReilaBeacon(float vecPos[3], float vecAng[3], int ally)
	{
		ReilaBeacon npc = view_as<ReilaBeacon>(CClotBody(vecPos, vecAng, IBERIA_BEACON, "0.3", "99999", ally, .NpcTypeLogic = 1));
		
		i_NpcWeight[npc.index] = 999;
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_flMeleeArmor = 1.25;
		npc.m_flRangedArmor = 1.0;

		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;
		npc.m_bDissapearOnDeath = true;
		npc.SetPlaybackRate(1.435);	
		npc.m_flSpawnAnnotation = GetGameTime() + 0.5;
		b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true;

		f_ExtraOffsetNpcHudAbove[npc.index] = 500.0;
		i_NpcIsABuilding[npc.index] = true;
		ApplyStatusEffect(npc.index, npc.index, "Infinite Will", 9999.0);

		//these are default settings! please redefine these when spawning!

		func_NPCDeath[npc.index] = view_as<Function>(ReilaBeacon_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(ReilaBeacon_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(ReilaBeacon_ClotThink);

		npc.m_iWearable1 = npc.EquipItemSeperate("models/buildables/sentry_shield.mdl", "idle"			, .skin = 1, .model_size = 1.5);
		npc.m_iWearable2 = npc.EquipItemSeperate("models/props_moonbase/moon_gravel_crystal.mdl", "idle", .model_size = 1.4);

		//counts as a static npc, means it wont count towards NPC limit.
		AddNpcToAliveList(npc.index, 1);
		SetEntityRenderColor(npc.index, 255, 255, 255, 255);
		

		return npc;
	}
}

public void ReilaBeacon_ClotThink(int iNPC)
{
	ReilaBeacon npc = view_as<ReilaBeacon>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	//Need to check this often sadly.
	if(!IsValidAlly(npc.index, GetClosestAlly(npc.index)))
	{
		//there is no more valid ally, suicide.
		SmiteNpcToDeath(npc.index);
		return;
	}
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}

	npc.m_flNextThinkTime = GetGameTime(npc.index) + 1.0;
	ReilaBeacon_SpawnAnnotation(iNPC);
}

public Action ReilaBeacon_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	ReilaBeacon npc = view_as<ReilaBeacon>(victim);

	
	if(damage >= float(GetEntProp(npc.index, Prop_Data, "m_iHealth")))
	{
		if(IsValidEntity(npc.m_iTargetAlly))
		{
			f_AttackSpeedNpcIncrease[npc.m_iTargetAlly] *= 0.9;
			fl_Extra_Speed[npc.m_iTargetAlly] 			*= 1.05;
			fl_Extra_Damage[npc.m_iTargetAlly] 			*= 1.25;
			ApplyStatusEffect(npc.m_iTargetAlly, npc.m_iTargetAlly, "Very Defensive Backup", 0.6);
			RaidModeScaling *= 1.25;
		}
		float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
		TE_Particle("xms_snowburst_child01", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
		EmitSoundToAll("mvm/mvm_bought_in.wav", _, _, SNDLEVEL_RAIDSIREN, _, RAIDBOSSBOSS_ZOMBIE_VOLUME, 80);
		EmitSoundToAll("mvm/mvm_bought_in.wav", _, _, SNDLEVEL_RAIDSIREN, _, RAIDBOSSBOSS_ZOMBIE_VOLUME, 80);
		ApplyStatusEffect(npc.index, npc.index, "Unstoppable Force", 10.0);
		
		CPrintToChatAll("{green}You gain more time before the Curtain closes...{crimson} However, both {pink}Reila{crimson} and the Construct become stronger.");
		SetEntProp(npc.index, Prop_Data, "m_iHealth", ReturnEntityMaxHealth(npc.index));
		MultiHealth(npc.index, 1.5);
		RaidModeTime = GetGameTime(npc.index) + 80.0;
		damage = 0.0;
		return Plugin_Changed;
	}
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}


public void ReilaBeacon_NPCDeath(int entity)
{
	ReilaBeacon npc = view_as<ReilaBeacon>(entity);
	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
		
	TE_Particle("pyro_blast", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
	TE_Particle("pyro_blast_lines", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
	TE_Particle("pyro_blast_warp", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
	TE_Particle("pyro_blast_flash", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
	EmitCustomToAll("zombiesurvival/internius/blinkarrival.wav", npc.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME * 2.0);
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


void ReilaBeacon_SpawnAnnotation(int iNPC)
{
	ReilaBeacon npc = view_as<ReilaBeacon>(iNPC);
	if(!npc.m_flSpawnAnnotation)
		return;
	if(npc.m_flSpawnAnnotation > GetGameTime())	
		return;
	npc.m_flSpawnAnnotation = 0.0;

	Event event = CreateEvent("show_annotation");
	if(event)
	{
		static float pos[3];
		GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", pos);
		pos[2] += 160.0;
		event.SetFloat("worldPosX", pos[0]);
		event.SetFloat("worldPosY", pos[1]);
		event.SetFloat("worldPosZ", pos[2]);
		event.SetInt("follow_entindex", npc.index);
		event.SetFloat("lifetime", 8.0);
		event.SetString("text", "Curtain closer!\nDestroy to regain timer!");
		event.SetString("play_sound", "vo/null.mp3");
		event.SetInt("id", 6000+npc.index);
		event.Fire();
	}
}



static void MultiHealth(int entity, float amount)
{
	SetEntProp(entity, Prop_Data, "m_iHealth", RoundFloat(GetEntProp(entity, Prop_Data, "m_iHealth") * amount));
	SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundFloat(ReturnEntityMaxHealth(entity) * amount));
}
