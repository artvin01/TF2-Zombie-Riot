#pragma semicolon 1
#pragma newdecls required

static const char g_MeleeAttackSounds[][] = {
	"weapons/samurai/tf_katana_01.wav",
	"weapons/samurai/tf_katana_02.wav",
	"weapons/samurai/tf_katana_03.wav",
	"weapons/samurai/tf_katana_04.wav",
	"weapons/samurai/tf_katana_05.wav",
	"weapons/samurai/tf_katana_06.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/samurai/tf_katana_slice_01.wav",
	"weapons/samurai/tf_katana_slice_02.wav",
	"weapons/samurai/tf_katana_slice_03.wav",
};


static const char g_FantasiaSound[][] = {
	"ambient/machines/thumper_hit.wav",
};

static int i_damage_taken[MAXENTITIES];

void Ruianus_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Ruianus");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_ruina_ruianus");
	data.Category = Type_Ruina;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	strcopy(data.Icon, sizeof(data.Icon), "demoknight_samurai"); 						//leaderboard_class_(insert the name)
	data.IconCustom = false;												//download needed?
	data.Flags = 0;						//example: MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;, forces these flags.	
	NPC_Add(data);
}
static void ClotPrecache()
{
	PrecacheSoundArray(g_DefaultMedic_DeathSounds);
	PrecacheSoundArray(g_DefaultMedic_HurtSounds);
	PrecacheSoundArray(g_DefaultMedic_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_DefaultMeleeMissSounds);
	PrecacheSoundArray(g_FantasiaSound);
	Zero(i_damage_taken);
	PrecacheModel("models/player/medic.mdl");
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Ruianus(vecPos, vecAng, team);
}
methodmap Ruianus < CClotBody
{
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_DefaultMedic_IdleAlertedSounds[GetRandomInt(0, sizeof(g_DefaultMedic_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_DefaultMedic_HurtSounds[GetRandomInt(0, sizeof(g_DefaultMedic_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		
		
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DefaultMedic_DeathSounds[GetRandomInt(0, sizeof(g_DefaultMedic_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_DefaultMeleeMissSounds[GetRandomInt(0, sizeof(g_DefaultMeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		
	}

	public void PlayFantasiaSound() {
		EmitSoundToAll(g_FantasiaSound[GetRandomInt(0, sizeof(g_FantasiaSound) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}
	
	public void AdjustWalkCycle()
	{
		if(this.IsOnGround())
		{
			if(this.m_iChanged_WalkCycle == 0)
			{
				this.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
				this.m_iChanged_WalkCycle = 1;
			}
		}
		else
		{
			if(this.m_iChanged_WalkCycle == 1)
			{
				this.SetActivity("ACT_MP_JUMP_FLOAT_SECONDARY");
				this.m_iChanged_WalkCycle = 0;
			}
		}
	}
	
	
	public Ruianus(float vecPos[3], float vecAng[3], int ally)
	{
		Ruianus npc = view_as<Ruianus>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "25000", ally));
		
		i_NpcWeight[npc.index] = 3;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		if(iActivity > 0) npc.StartActivity(iActivity);

		npc.m_iChanged_WalkCycle = 1;

		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(NPC_Death);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(ClotThink);

		/*

			Angel of Death - 	"models/workshop/player/items/medic/xms2013_medic_robe/xms2013_medic_robe.mdl"
			Low Grav Loafers -	"models/workshop/player/items/medic/hw2013_moon_boots/hw2013_moon_boots.mdl"
			Byte'd beak			"models/workshop/player/items/medic/robo_medic_blighted_beak/robo_medic_blighted_beak.mdl"
			Demonic Dome - 		"models/workshop/player/items/all_class/hwn2023_demonic_dome/hwn2023_demonic_dome_medic.mdl"
			El Jefe				"models/player/items/scout/rebel_cap.mdl"

		*/
		
		//IDLE
		npc.m_flSpeed = 300.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		static const char Items[][] = {
			"models/workshop/player/items/medic/xms2013_medic_robe/xms2013_medic_robe.mdl",
			"models/workshop/player/items/medic/hw2013_moon_boots/hw2013_moon_boots.mdl",
			"models/workshop/player/items/medic/robo_medic_blighted_beak/robo_medic_blighted_beak.mdl",
			"models/workshop/player/items/all_class/hwn2023_demonic_dome/hwn2023_demonic_dome_medic.mdl",
			"models/player/items/scout/rebel_cap.mdl",
			RUINA_CUSTOM_MODELS_1
		};	
		
		int skin = 1;	//1=blue, 0=red
		SetVariantInt(1);	
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		npc.m_iWearable1 = npc.EquipItem("head", Items[0], _, skin);
		npc.m_iWearable2 = npc.EquipItem("head", Items[1], _, skin);
		npc.m_iWearable3 = npc.EquipItem("head", Items[2], _, skin);
		npc.m_iWearable4 = npc.EquipItem("head", Items[3], _, skin);
		npc.m_iWearable5 = npc.EquipItem("head", Items[4], _, skin);
		npc.m_iWearable6 = npc.EquipItem("head", Items[5]);
		//npc.m_iWearable7 = npc.EquipItem("head", Items[6]);

		SetVariantInt(RUINA_BLADE_1);
		AcceptEntityInput(npc.m_iWearable6, "SetBodyGroup");	

		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		fl_ruina_battery[npc.index] = 0.0;
		b_ruina_battery_ability_active[npc.index] = false;
		fl_ruina_battery_timer[npc.index] = 0.0;

		npc.Anger = false;
		
		Ruina_Set_Heirarchy(npc.index, RUINA_MELEE_NPC);	//is a melee npc
		Ruina_Set_Master_Heirarchy(npc.index, RUINA_MELEE_NPC, true, 10, 4);		//priority 4, just lower then the actual bosses

		b_ruina_nerf_healing[npc.index] = true;

		return npc;
	}
	
	
}


static void ClotThink(int iNPC)
{
	Ruianus npc = view_as<Ruianus>(iNPC);

	float GameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > GameTime)
	{
		return;
	}
	
	npc.m_flNextDelayTime = GameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
			
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = GameTime + 0.1;

	npc.AdjustWalkCycle();
	
	if(npc.m_flGetClosestTargetTime < GameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GameTime + GetRandomRetargetTime();
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	

	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{

		Ruina_Ai_Override_Core(npc.index, PrimaryThreatIndex, GameTime);	//handles movement

		float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		float Npc_Vec[3]; WorldSpaceCenter(npc.index, Npc_Vec);
		float flDistanceToTarget = GetVectorDistance(vecTarget, Npc_Vec, true);

		if(npc.m_flDoingAnimation < GameTime)
		{
			if(!IsValidEntity(npc.m_iWearable6))
			{
				npc.m_iWearable6 = npc.EquipItem("head", RUINA_CUSTOM_MODELS_1);
				SetVariantInt(RUINA_BLADE_1);
				AcceptEntityInput(npc.m_iWearable6, "SetBodyGroup");
			}

			Ruina_Self_Defense Melee;

			Melee.iNPC = npc.index;
			Melee.target = PrimaryThreatIndex;
			Melee.fl_distance_to_target = flDistanceToTarget;
			Melee.range = NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*1.25;
			Melee.damage = 55.0;
			Melee.bonus_dmg = 325.0;
			Melee.attack_anim = "ACT_MP_ATTACK_STAND_MELEE_ALLCLASS";
			Melee.swing_speed = 1.0;
			Melee.swing_delay = 0.35;
			Melee.turn_speed = 20000.0;
			Melee.gameTime = GameTime;
			Melee.status = 0;
			Melee.Swing_Melee(OnRuina_MeleeAttack);

			switch(Melee.status)
			{
				case 1:	//we swung
					npc.PlayMeleeSound();
				case 2:	//we hit something
					npc.PlayMeleeHitSound();
				case 3:	//we missed
					npc.PlayMeleeMissSound();
				//0 means nothing.
			}
		}

	}
	else
	{
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

static void OnRuina_MeleeAttack(int iNPC, int Target)
{
	Ruina_Add_Mana_Sickness(iNPC, Target, 0.1, 50);
}

static Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Ruianus npc = view_as<Ruianus>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;

	float GameTime = GetGameTime(npc.index);

	Ruina_NPC_OnTakeDamage_Override(npc.index, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
	
	if(fl_ruina_battery_timer[npc.index]<GameTime)
	{
		int Max_Health = ReturnEntityMaxHealth(npc.index);
		fl_ruina_battery_timer[npc.index]=GameTime+5.0;
		int healing = RoundToFloor(i_damage_taken[npc.index]*0.35);

		if(healing > RoundToFloor(Max_Health*0.2))
			healing = RoundToFloor(Max_Health*0.2);

		//CPrintToChatAll("Healing: %i",healing);
			
		Helia_Healing_Logic(npc.index, healing, 500.0, GameTime, 0.5);

		i_damage_taken[npc.index]=0;
	}
	else
	{
		i_damage_taken[npc.index]+=damage;
	}

	if (npc.m_flHeadshotCooldown < GameTime)
	{
		npc.m_flHeadshotCooldown = GameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void NPC_Death(int entity)
{
	Ruianus npc = view_as<Ruianus>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}

	Ruina_NPCDeath_Override(entity);
		
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
}