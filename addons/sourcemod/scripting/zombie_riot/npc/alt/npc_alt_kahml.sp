#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"weapons/rescue_ranger_teleport_receive_01.wav",
	"weapons/rescue_ranger_teleport_receive_02.wav",
};

static const char g_HurtSounds[][] = {
	"vo/heavy_painsharp01.mp3",
	"vo/heavy_painsharp02.mp3",
	"vo/heavy_painsharp03.mp3",
	"vo/heavy_painsharp04.mp3",
	"vo/heavy_painsharp05.mp3",
};

static const char g_IdleSounds[][] = {
	"vo/heavy_meleedare10.mp3",
	"vo/heavy_meleedare09.mp3",
	"vo/heavy_meleedare08.mp3",
	"vo/heavy_meleedare03.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/heavy_meleedare13.mp3",
	"vo/heavy_meleedare12.mp3",
	"vo/heavy_meleedare07.mp3",
	"vo/heavy_meleedare06.mp3",
	"vo/heavy_meleedare05.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/metal_gloves_hit_flesh1.wav",
	"weapons/metal_gloves_hit_flesh2.wav",
	"weapons/metal_gloves_hit_flesh3.wav",
	"weapons/metal_gloves_hit_flesh4.wav",
};
static const char g_MeleeAttackSounds[][] = {
	"weapons/boxing_gloves_swing1.wav",
	"weapons/boxing_gloves_swing2.wav",
	"weapons/boxing_gloves_swing4.wav",
};

static const char g_MeleeMissSounds[][] = {
	"weapons/bat_draw_swoosh1.wav",
	"weapons/bat_draw_swoosh2.wav",
};
static char g_TeleportSounds[][] = {
	"weapons/bison_main_shot.wav",
};
static const char g_charge_sound[][] = {
	"vo/heavy_incoming03.mp3",
	"vo/heavy_scream2012_falling01.mp3",
	"vo/heavy_specials04.mp3",
};
static const char g_RangedAttackSounds[][] = {
	"weapons/airstrike_fire_crit.wav",
};
static const char g_RangedAttackSoundsSecondary[][] = {
	"vo/heavy_meleeing01.mp3",
	"vo/heavy_meleeing02.mp3",
	"vo/heavy_meleeing03.mp3",
	"vo/heavy_meleeing04.mp3",
	"vo/heavy_meleeing05.mp3",
	"vo/heavy_meleeing06.mp3",
	"vo/heavy_meleeing07.mp3",
	"vo/heavy_meleeing08.mp3",
};
static float fl_attack_timeout[MAXENTITIES];
//All the funny static things.	//Fast1	//this thing is likely unorganised at this point, god knows how it works at this point?, unless im retarded
//Combo system
static int i_kahml_combo[MAXENTITIES];	//which weapon on combo is being used
static int i_kahml_combo_offest[MAXENTITIES]; //used for stufffffff.
static int i_kahml_megahit[MAXENTITIES];	//how many hits until we make it do extra dmg
static int i_kahml_teleport_combo[MAXENTITIES];	//how many hits to get a single tp charge
static int i_kahml_dash_combo[MAXENTITIES];	//how many hits to get a single dash charge
static float fl_kahml_knockback[MAXENTITIES];

static bool b_kahml_inNANOMACHINESSON[MAXENTITIES]; //NANOMACHINES SON, THEY don't HARDEN IN RESPONSE TO PHYSICAL TRAUMA.
static bool b_kahml_incombo[MAXENTITIES];	//In combo?
static bool b_kahml_annihilation[MAXENTITIES]; //In annihilation?
static bool b_kahml_annihilation_used[MAXENTITIES];
//Movement System.
static int i_kahml_teleport_charge[MAXENTITIES];
static int i_kahml_dash_charge[MAXENTITIES];
//timers.
static float fl_kahml_combo_reset_timer[MAXENTITIES];
static float fl_kahml_annihilation_reset_timer[MAXENTITIES];
static float fl_kahml_annihilation_firerate[MAXENTITIES];
static float fl_kahml_nano_reset[MAXENTITIES];

static float fl_TheFinalCountdown[MAXENTITIES];
static float fl_TheFinalCountdown2[MAXENTITIES];
//Other stuff
static float fl_kahml_main_melee_damage[MAXENTITIES];
static float fl_kahml_galactic_strenght[MAXENTITIES];	//used dmg bonus
static float fl_kahml_bulletres[MAXENTITIES];
static float fl_kahml_meleeres[MAXENTITIES];
static float fl_kahml_melee_speed[MAXENTITIES];

public void Kahmlstein_OnMapStart_NPC()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_MeleeMissSounds);
	PrecacheSoundArray(g_TeleportSounds);
	PrecacheSoundArray(g_charge_sound);
	PrecacheSoundArray(g_RangedAttackSounds);
	PrecacheSoundArray(g_RangedAttackSoundsSecondary);
	
	PrecacheSound("mvm/mvm_tank_horn.wav");
	PrecacheSound("items/powerup_pickup_knockout_melee_hit.wav");
	PrecacheSound("weapons/vaccinator_charge_tier_01.wav");
	PrecacheSound("weapons/vaccinator_charge_tier_02.wav");
	PrecacheSound("weapons/vaccinator_charge_tier_03.wav");
	PrecacheSound("weapons/vaccinator_charge_tier_04.wav");
	
	PrecacheSound("vo/heavy_domination08.mp3");
	PrecacheSound("vo/heavy_domination12.mp3");
	PrecacheSound("vo/heavy_domination13.mp3");
	PrecacheSound("vo/heavy_domination14.mp3");
	PrecacheSound("vo/heavy_domination17.mp3");
	
	PrecacheSound("vo/heavy_domination06.mp3");	//annihalation 
	PrecacheSound("vo/heavy_mvm_rage01.mp3");	//I am angry :(
	PrecacheSound("vo/heavy_domination16.mp3");	//necksnap
	
	PrecacheSound("mvm/mvm_cpoint_klaxon.wav");
	PrecacheSound("mvm/mvm_tank_end.wav");
	
	PrecacheModel("models/effects/combineball.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Kahmlstein?");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_kahml");
	data.Category = Type_Alt;
	data.Func = ClotSummon;
	strcopy(data.Icon, sizeof(data.Icon), "kahmlstein"); 		//leaderboard_class_(insert the name)
	data.IconCustom = true;													//download needed?
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;																//example: MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;, forces these flags.	
	NPC_Add(data);

}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Kahmlstein(vecPos, vecAng, team);
}

methodmap Kahmlstein < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		

	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		
		
		
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		
		
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		

	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		

	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		
		
	}
	public void PlayTeleportSound() {
		EmitSoundToAll(g_TeleportSounds[GetRandomInt(0, sizeof(g_TeleportSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		

	}
	public void PlayChargeSound() {
		EmitSoundToAll(g_charge_sound[GetRandomInt(0, sizeof(g_charge_sound) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		

	}
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		

	}
	public void PlayRangedAttackSecondarySound() {
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		

	}
	
	public Kahmlstein(float vecPos[3], float vecAng[3], int ally)
	{
		Kahmlstein npc = view_as<Kahmlstein>(CClotBody(vecPos, vecAng, "models/player/heavy.mdl", "1.35", "15000", ally, false, true));
		
		i_NpcWeight[npc.index] = 4;
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPSOUND_NORMAL;

		if(!IsValidEntity(RaidBossActive))
		{
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidModeTime = GetGameTime(npc.index) + 9000.0;
			RaidModeScaling = MultiGlobalHealth;
			if(RaidModeScaling == 1.0) //Dont show scaling if theres none.
				RaidModeScaling = 0.0;
			RaidAllowsBuildings = true;
		}
		
		npc.m_bDissapearOnDeath = true;
		
		func_NPCDeath[npc.index] = view_as<Function>(Internal_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Internal_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Internal_ClotThink);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_fists_of_steel/c_fists_of_steel.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop_partner/player/items/all_class/dex_glasses/dex_glasses_heavy.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/heavy/Robo_Heavy_Chief/Robo_Heavy_Chief.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		
		npc.m_iWearable6 = npc.EquipItem("head", "models/player/items/heavy/heavy_wolf_chest.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");
		
		SetEntityRenderColor(npc.index, 21, 71, 171, 255);
		
		SetEntityRenderColor(npc.m_iWearable4, 21, 71, 171, 255);
		SetEntityRenderColor(npc.m_iWearable5, 21, 71, 171, 255);
		SetEntityRenderColor(npc.m_iWearable6, 21, 71, 171, 255);
		
		float flPos[3]; // original
		float flAng[3]; // original
	
		npc.GetAttachment("effect_hand_r", flPos, flAng);
		npc.m_iWearable2 = ParticleEffectAt_Parent(flPos, "raygun_projectile_blue_crit", npc.index, "effect_hand_r", {0.0,0.0,0.0});
		npc.GetAttachment("", flPos, flAng);
		
		npc.GetAttachment("effect_hand_l", flPos, flAng);
		npc.m_iWearable3 = ParticleEffectAt_Parent(flPos, "raygun_projectile_blue_crit", npc.index, "effect_hand_l", {0.0,0.0,0.0});
		npc.GetAttachment("", flPos, flAng);
		
		//IDLE
		npc.m_flSpeed = 310.0;
		npc.m_iState = 0;
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();

		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		//fast2
		i_kahml_teleport_charge[npc.index] = 2;	//starts out with 2 tp charges
		i_kahml_dash_charge[npc.index] = 0;
		//Bool system.
		b_kahml_incombo[npc.index] = false;
		b_kahml_inNANOMACHINESSON[npc.index] = false;
		b_kahml_annihilation[npc.index] = false;
		b_kahml_annihilation_used[npc.index] = false;
		//Combo system.
		i_kahml_dash_combo[npc.index] = 0;
		i_kahml_teleport_combo[npc.index] = 0;
		i_kahml_megahit[npc.index] = 0;
		i_kahml_combo_offest[npc.index] = 0;
		i_kahml_combo[npc.index] = 0;
		fl_kahml_knockback[npc.index] = 0.0;
		
		fl_kahml_melee_speed[npc.index] = 1.0;
		
		//Scaling stuff on hp.
		fl_kahml_bulletres[npc.index] = 1.0;
		fl_kahml_meleeres[npc.index] = 1.0;
		fl_kahml_galactic_strenght[npc.index] = 1.0;	//bonus damage kahml gets from losing hp.
		fl_kahml_main_melee_damage[npc.index] = 0.0;	//this damage is the one going directly in the hooks thingy, 
		
		//timers.
		fl_kahml_combo_reset_timer[npc.index] = 0.0;
		fl_kahml_annihilation_reset_timer[npc.index] = 0.0;
		fl_kahml_annihilation_firerate[npc.index] = 0.0;
		fl_kahml_nano_reset[npc.index] = 60.0 + GetGameTime(npc.index);
		
		fl_TheFinalCountdown[npc.index] = 0.0;
		fl_TheFinalCountdown2[npc.index] = 0.0;
		
		npc.m_flCharge_Duration = 0.0;
		npc.m_flCharge_delay = GetGameTime(npc.index) + 2.0;
		
		return npc;
	}
}


static void Internal_ClotThink(int iNPC)
{
	Kahmlstein npc = view_as<Kahmlstein>(iNPC);

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

	if(npc.m_flGetClosestTargetTime < GameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GameTime + GetRandomRetargetTime();
	}
	
	float Health = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));
	float MaxHealth = float(ReturnEntityMaxHealth(npc.index));
	
	fl_kahml_galactic_strenght[npc.index] = 1+(1-(Health/MaxHealth))*1.5;
	fl_kahml_galactic_strenght[npc.index] *= 2.0;
	
	float armour_melee;
	float armour_ranged;
	
	armour_ranged=fl_kahml_bulletres[npc.index];
	armour_melee=fl_kahml_meleeres[npc.index];
	if(armour_ranged<0.25)	//blocks resistances from going higher than 75% resist to all. however this should never kick in unless somehow kahml got over 75% resist.
		armour_ranged=0.25;
	if(armour_melee<0.25)
		armour_melee=0.25;
	npc.m_flRangedArmor = armour_ranged;
	npc.m_flMeleeArmor = armour_melee;
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		if(i_kahml_teleport_combo[npc.index] >= 12)	//Hit 9 human beings to teleport, a fair deal.
		{
			i_kahml_teleport_combo[npc.index] = 0;
			i_kahml_teleport_charge[npc.index]++;
		}
		if(i_kahml_dash_combo[npc.index] >= 16)	//Truth be told, no idea if dash's work.
		{
			i_kahml_dash_combo[npc.index] = 0;
			i_kahml_dash_charge[npc.index]++;
		}
		if(i_kahml_megahit[npc.index]>5)	//hit a thing 5 times to deal 50% extra damage.
		{
			fl_kahml_main_melee_damage[npc.index] *=1.5;
			i_kahml_megahit[npc.index]=0;
			if(!b_kahml_inNANOMACHINESSON[npc.index])
			{
			EmitSoundToAll("items/powerup_pickup_knockout_melee_hit.wav");
			}
		}//fast3
		if(fl_kahml_combo_reset_timer[npc.index] <= GameTime && i_kahml_combo_offest[npc.index] != 0 && !b_kahml_annihilation[npc.index] && !b_kahml_inNANOMACHINESSON[npc.index])
		{
			fl_kahml_main_melee_damage[npc.index] = 40.0 * fl_kahml_galactic_strenght[npc.index];
			i_kahml_combo_offest[npc.index] = 0;
			i_kahml_combo[npc.index] = 0;
			if(IsValidEntity(npc.m_iWearable1))
				RemoveEntity(npc.m_iWearable1);
			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_fists_of_steel/c_fists_of_steel.mdl");
			SetVariantString("1.0");
			AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
			fl_kahml_bulletres[npc.index] = 0.85;
			fl_kahml_meleeres[npc.index] = 1.15;
			
			fl_kahml_knockback[npc.index] = 0.0;
			
			fl_kahml_melee_speed[npc.index] = 0.45;
			
			b_kahml_incombo[npc.index] = false;
		}
		if(i_kahml_combo[npc.index] == 3 && i_kahml_combo_offest[npc.index] == 0 && !b_kahml_annihilation[npc.index] && !b_kahml_inNANOMACHINESSON[npc.index])
		{
			fl_kahml_main_melee_damage[npc.index] = 37.5 * fl_kahml_galactic_strenght[npc.index];
			fl_kahml_combo_reset_timer[npc.index] = GameTime + 2.5;
			i_kahml_combo_offest[npc.index]++;
			if(IsValidEntity(npc.m_iWearable1))
				RemoveEntity(npc.m_iWearable1);
			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_eviction_notice/c_eviction_notice.mdl");
			SetVariantString("1.0");
			AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
			EmitSoundToAll("weapons/vaccinator_charge_tier_01.wav");
		
			npc.PlayRangedAttackSecondarySound();
		
			EmitSoundToAll("vo/heavy_domination08.mp3");
		
			fl_kahml_melee_speed[npc.index] = 0.5;
			fl_kahml_knockback[npc.index] = 100.0;
			fl_kahml_bulletres[npc.index] = 1.0;
			fl_kahml_meleeres[npc.index] = 1.0;
		
			b_kahml_incombo[npc.index] = true;
		}
		if(i_kahml_combo[npc.index] == 5 && i_kahml_combo_offest[npc.index] == 1 && !b_kahml_annihilation[npc.index] && !b_kahml_inNANOMACHINESSON[npc.index])
		{
			fl_kahml_main_melee_damage[npc.index] = 40.0 * fl_kahml_galactic_strenght[npc.index];
			fl_kahml_combo_reset_timer[npc.index] = GameTime + 2.5;
			i_kahml_combo_offest[npc.index]++;
			if(IsValidEntity(npc.m_iWearable1))
				RemoveEntity(npc.m_iWearable1);
			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_boxing_gloves/c_boxing_gloves.mdl");
			SetVariantString("1.0");
			AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
			EmitSoundToAll("weapons/vaccinator_charge_tier_02.wav");
		
			npc.PlayRangedAttackSecondarySound();
		
			EmitSoundToAll("vo/heavy_domination12.mp3");
		
			fl_kahml_melee_speed[npc.index] = 0.25;
			fl_kahml_knockback[npc.index] = 125.0;
			fl_kahml_bulletres[npc.index] = 1.0;
			fl_kahml_meleeres[npc.index] = 1.0;
		
			b_kahml_incombo[npc.index] = true;
		}
		if(i_kahml_combo[npc.index] == 7 && i_kahml_combo_offest[npc.index] == 2 && !b_kahml_annihilation[npc.index] && !b_kahml_inNANOMACHINESSON[npc.index])
		{
			fl_kahml_main_melee_damage[npc.index] = 40.0 * fl_kahml_galactic_strenght[npc.index];
			fl_kahml_combo_reset_timer[npc.index] = GameTime + 2.5;
			i_kahml_combo_offest[npc.index]++;
			if(IsValidEntity(npc.m_iWearable1))
				RemoveEntity(npc.m_iWearable1);
			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_sr3_punch/c_sr3_punch.mdl");
			SetVariantString("1.0");
			AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
			
			EmitSoundToAll("weapons/vaccinator_charge_tier_03.wav");
			
			fl_kahml_melee_speed[npc.index] = 0.25;
			
			npc.PlayRangedAttackSecondarySound();
		
			EmitSoundToAll("vo/heavy_domination13.mp3");
			fl_kahml_knockback[npc.index] = 125.0;
			fl_kahml_bulletres[npc.index] = 1.0;
			fl_kahml_meleeres[npc.index] = 1.0;
		
			b_kahml_incombo[npc.index] = true;
		}
		if(i_kahml_combo[npc.index] == 8 && i_kahml_combo_offest[npc.index] == 3 && !b_kahml_annihilation[npc.index] && !b_kahml_inNANOMACHINESSON[npc.index]) 
		{
			fl_kahml_main_melee_damage[npc.index] = 45.0 * fl_kahml_galactic_strenght[npc.index];
			fl_kahml_combo_reset_timer[npc.index] = GameTime + 2.5;
			i_kahml_combo_offest[npc.index]++;
			if(IsValidEntity(npc.m_iWearable1))
				RemoveEntity(npc.m_iWearable1);
			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_xms_gloves/c_xms_gloves.mdl");
			SetVariantString("1.0");
			AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
			EmitSoundToAll("weapons/vaccinator_charge_tier_04.wav");
		
			fl_kahml_melee_speed[npc.index] = 0.25;
			
			npc.PlayRangedAttackSecondarySound();
		
			EmitSoundToAll("vo/heavy_domination14.mp3");
			fl_kahml_knockback[npc.index] = 140.0;
			fl_kahml_bulletres[npc.index] = 1.0;
			fl_kahml_meleeres[npc.index] = 1.0;
		
			b_kahml_incombo[npc.index] = true;
		}
		if(i_kahml_combo[npc.index] == 9 && i_kahml_combo_offest[npc.index] == 4 && !b_kahml_annihilation[npc.index] && !b_kahml_inNANOMACHINESSON[npc.index])
		{
			fl_kahml_main_melee_damage[npc.index] = 40.0 * fl_kahml_galactic_strenght[npc.index];
			fl_kahml_combo_reset_timer[npc.index] = GameTime + 30.0;
			i_kahml_combo_offest[npc.index]++;
			if(IsValidEntity(npc.m_iWearable1))
				RemoveEntity(npc.m_iWearable1);
			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_fists_of_steel/c_fists_of_steel.mdl");
			SetVariantString("1.0");
			AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
			npc.PlayRangedAttackSecondarySound();
		
			fl_kahml_melee_speed[npc.index] = 0.75;
			
			fl_kahml_bulletres[npc.index] = 0.85;
			fl_kahml_meleeres[npc.index] = 1.15;
			
			b_kahml_incombo[npc.index] = false;
		}
		if(i_kahml_combo[npc.index] == 15 && i_kahml_combo_offest[npc.index] == 5 && !b_kahml_annihilation[npc.index] && !b_kahml_inNANOMACHINESSON[npc.index])
		{	//necksnap
			npc.m_flSpeed = 310.0;
			fl_kahml_main_melee_damage[npc.index] = 750.0 * fl_kahml_galactic_strenght[npc.index];	//so will likely 1 shot most players unless they invest in armour
			fl_attack_timeout[npc.index]=GameTime + 0.5;
			EmitSoundToAll("mvm/mvm_tank_horn.wav");
			EmitSoundToAll("vo/heavy_domination16.mp3");
			CPrintToChatAll("{blue}캄르스타인{default}: {crimson}널 박살내주마.");
			fl_kahml_combo_reset_timer[npc.index] = GameTime + 12.5;
			i_kahml_combo_offest[npc.index]++;
			if(IsValidEntity(npc.m_iWearable1))
				RemoveEntity(npc.m_iWearable1);
			fl_kahml_knockback[npc.index] = 1000.0;	//lots of kb, have fun whoever got snaped.
			fl_kahml_bulletres[npc.index] = 1.0;
			fl_kahml_meleeres[npc.index] = 1.0;
		
			b_kahml_incombo[npc.index] = true;
		}
		if(i_kahml_combo[npc.index] == 16 && i_kahml_combo_offest[npc.index] == 6)
		{
			npc.m_flSpeed = 315.0;
			fl_kahml_combo_reset_timer[npc.index] = GameTime + 0.1;
			fl_kahml_knockback[npc.index] = 0.0;
		}
		if(Health/MaxHealth>0 && Health/MaxHealth<0.25 && !b_kahml_annihilation[npc.index] && !b_kahml_inNANOMACHINESSON[npc.index] && !b_kahml_annihilation_used[npc.index])
		{
			
			fl_kahml_main_melee_damage[npc.index] = 35.0 * fl_kahml_galactic_strenght[npc.index];
			if(IsValidEntity(npc.m_iWearable1))
				RemoveEntity(npc.m_iWearable1);
			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_gatling_gun/c_gatling_gun.mdl");
			SetVariantString("1.0");
			AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
			EmitSoundToAll("vo/heavy_domination06.mp3");
		
			fl_kahml_bulletres[npc.index] = 0.1;
			fl_kahml_meleeres[npc.index] = 0.1;
			
			fl_attack_timeout[npc.index] = GameTime + 3.5;
			b_kahml_annihilation[npc.index]=true;
			b_kahml_annihilation_used[npc.index]=true;
			i_kahml_combo_offest[npc.index] = 0;
			i_kahml_combo[npc.index] = 0;
		
			fl_kahml_annihilation_reset_timer[npc.index] = GameTime + 18.5;	
		}
		if(b_kahml_annihilation_used[npc.index] && fl_kahml_annihilation_reset_timer[npc.index] <= GameTime)
		{
			npc.m_flSpeed = 320.0;
			fl_kahml_bulletres[npc.index] = 1.0;
			fl_kahml_meleeres[npc.index] = 1.0;
			b_kahml_annihilation[npc.index]=false;
			if(IsValidEntity(npc.m_iWearable1))
				RemoveEntity(npc.m_iWearable1);
			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_fists_of_steel/c_fists_of_steel.mdl");
			SetVariantString("1.0");
			AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
			fl_kahml_annihilation_reset_timer[npc.index] = GameTime + 100000000.0;	//we are long long timer.
		}
		if(b_kahml_inNANOMACHINESSON[npc.index])
		{
			fl_kahml_main_melee_damage[npc.index] = 35.0 * fl_kahml_galactic_strenght[npc.index];	//cause funny 3x thingy makes this thing go brrrrrrr and his dmg becomes god-like
		}
		if(fl_kahml_nano_reset[npc.index] <= GameTime && !b_kahml_annihilation[npc.index] && !b_kahml_inNANOMACHINESSON[npc.index])
		{
			CPrintToChatAll("{blue}캄르스타인{default}: 이러고 있을 시간 없다.");
			fl_kahml_main_melee_damage[npc.index] = 20.0 * fl_kahml_galactic_strenght[npc.index];
			fl_kahml_bulletres[npc.index] = 0.75;
			fl_kahml_meleeres[npc.index] = 0.9;
			b_kahml_inNANOMACHINESSON[npc.index] = true;
			//nano timers.
			fl_kahml_nano_reset[npc.index] = 30.0 + GameTime;
			
			fl_kahml_knockback[npc.index] = 0.0;
			
			npc.m_flSpeed = 345.0;
			
			fl_kahml_melee_speed[npc.index] = 0.2;
			
			EmitSoundToAll("mvm/mvm_tank_end.wav");
			
			if(IsValidEntity(npc.m_iWearable1))
				RemoveEntity(npc.m_iWearable1);
			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_fists_of_steel/c_fists_of_steel.mdl");
			SetVariantString("1.0");
			AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
			
			float flPos[3]; // original
			float flAng[3]; // original
			npc.GetAttachment("effect_hand_r", flPos, flAng);
			npc.DispatchParticleEffect(npc.index, "hammer_bell_ring_shockwave2", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("effect_hand_r"), PATTACH_POINT_FOLLOW, true);
		
		}
		if(fl_kahml_nano_reset[npc.index] <= GameTime && b_kahml_inNANOMACHINESSON[npc.index])
		{
			b_kahml_inNANOMACHINESSON[npc.index] = false;
			fl_kahml_bulletres[npc.index] = 1.0;
			fl_kahml_meleeres[npc.index] = 1.0;
			fl_kahml_melee_speed[npc.index] = 0.4;
			CPrintToChatAll("{blue}캄르스타인{default}: 잘 살아남았군. 잘 했다.");
			fl_kahml_nano_reset[npc.index] = 120.0 + GameTime;
			fl_kahml_combo_reset_timer[npc.index] = 60.0 + GameTime;
			i_kahml_combo_offest[npc.index] = 0;
			i_kahml_combo[npc.index] = 0;
		}
		if(Health/MaxHealth>0 && Health/MaxHealth<0.25 && !b_kahml_annihilation[npc.index] && !b_kahml_inNANOMACHINESSON[npc.index] && !b_kahml_annihilation_used[npc.index])
		{
			
			fl_kahml_main_melee_damage[npc.index] = 90.0 * fl_kahml_galactic_strenght[npc.index];
			if(IsValidEntity(npc.m_iWearable1))
				RemoveEntity(npc.m_iWearable1);
			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_gatling_gun/c_gatling_gun.mdl");
			SetVariantString("1.0");
			AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
			EmitSoundToAll("vo/heavy_domination06.mp3");
		
			fl_TheFinalCountdown2[npc.index] = GameTime+7.5;
		
			fl_kahml_bulletres[npc.index] = 0.25;
			fl_kahml_meleeres[npc.index] = 0.25;
		
			b_kahml_annihilation[npc.index]=true;
			b_kahml_annihilation_used[npc.index]=true;
		
			fl_kahml_annihilation_reset_timer[npc.index] = GameTime + 15.0;	
		}
		if(b_kahml_annihilation_used[npc.index] && fl_kahml_annihilation_reset_timer[npc.index] <= GameTime)
		{
			fl_kahml_bulletres[npc.index] = 0.85;
			fl_kahml_meleeres[npc.index] = 1.15;
			b_kahml_annihilation[npc.index]=false;
			if(IsValidEntity(npc.m_iWearable1))
				RemoveEntity(npc.m_iWearable1);
			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_fists_of_steel/c_fists_of_steel.mdl");
			SetVariantString("1.0");
			AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
			i_kahml_combo_offest[npc.index] = 0;
			i_kahml_combo[npc.index] = 0;
		}
		float vecTarget[3];	WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		
		float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex, 0.3,_, vPredictedPos);
		
		if(npc.m_flCharge_Duration < GameTime && i_kahml_dash_charge[npc.index] > 2)
		{
			//npc.m_flSpeed = 300.0;
			if(npc.m_flCharge_delay < GameTime)
			{
				int Enemy_I_See;
				Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
				//Target close enough to hit
				if(IsValidEnemy(npc.index, Enemy_I_See) && Enemy_I_See == PrimaryThreatIndex && flDistanceToTarget > (250.0 * 250.0) && flDistanceToTarget < (500.0 * 500.0))
				{
					i_kahml_dash_charge[npc.index]-=2;
					npc.PlayChargeSound();
					npc.m_flCharge_delay = GameTime + 1.0;
					npc.m_flCharge_Duration = GameTime + 10.0;
					PluginBot_Jump(npc.index, vecTarget);
					npc.m_flSpeed = 400.0;
				}
			}
		}
		if(npc.m_flNextTeleport < GameTime && flDistanceToTarget > (125.0* 125.0) && flDistanceToTarget < (500.0 * 500.0) && i_kahml_teleport_charge[npc.index] > 0)
		{
			static float flVel[3];
			GetEntPropVector(PrimaryThreatIndex, Prop_Data, "m_vecVelocity", flVel);
		
			if (flVel[0] >= 190.0)
			{
				npc.FaceTowards(vecTarget);
				npc.FaceTowards(vecTarget);
				npc.m_flNextTeleport = GameTime + 11.0;
				float Tele_Check = GetVectorDistance(vPredictedPos, vecTarget);
				if(Tele_Check > 120.0)
				{
					bool Succeed = NPC_Teleport(npc.index, vPredictedPos);
					if(Succeed)
					{
						i_kahml_dash_charge[npc.index]--;
						npc.PlayTeleportSound();
					}
					else
					{
						npc.m_flNextTeleport = GameTime + 1.0;
					}
				}
			}
		}
		if(flDistanceToTarget < npc.GetLeadRadius())
		{
				npc.SetGoalVector(vPredictedPos);
		}
		else
		{
			npc.SetGoalEntity(PrimaryThreatIndex);
		}
		npc.StartPathing();
		//Target close enough to hit
		if(!b_kahml_annihilation[npc.index])
		{
			//Target close enough to hit
			if(flDistanceToTarget < 50000 || npc.m_flAttackHappenswillhappen)
			{
				
				//Look at target so we hit.
			//	npc.FaceTowards(vecTarget, 1000.0);
				
				//Can we attack right now?
				if(npc.m_flNextMeleeAttack < GameTime && fl_attack_timeout[npc.index] < GameTime)
				{
					//Play attack ani
					if (!npc.m_flAttackHappenswillhappen)
					{
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
						npc.PlayMeleeSound();
						npc.m_flAttackHappens = 0.0;
						npc.m_flAttackHappens_bullshit = GameTime+fl_kahml_melee_speed[npc.index];
						npc.m_flAttackHappenswillhappen = true;
					}
					if (npc.m_flAttackHappens < GameTime && npc.m_flAttackHappens_bullshit >= GameTime && npc.m_flAttackHappenswillhappen)
					{
						Handle swingTrace;
						npc.FaceTowards(vecTarget, 20000.0);
						if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex, { 100.0, 100.0, 100.0 }, { -100.0, -100.0, -100.0 })) 
						{
							int target = TR_GetEntityIndex(swingTrace);	
							
							float vecHit[3];
							TR_GetEndPosition(vecHit, swingTrace);
							
							if(target > 0) 
							{
								if(target <= MaxClients)
								{
									
									i_kahml_teleport_combo[npc.index]++;
									i_kahml_dash_combo[npc.index]++;
									
									float Bonus_damage = 1.0;
									int weapon = GetEntPropEnt(target, Prop_Send, "m_hActiveWeapon");
									if(IsValidEntity(weapon))
									{
										char classname[32];
										GetEntityClassname(weapon, classname, 32);
										
										int weapon_slot = TF2_GetClassnameSlot(classname, weapon);
										
										if(i_OverrideWeaponSlot[weapon] != -1)
										{
											weapon_slot = i_OverrideWeaponSlot[weapon];
										}
										if(weapon_slot != 2)
										{
											Bonus_damage = 1.5;
										}
									}
									fl_kahml_main_melee_damage[npc.index] *= Bonus_damage;
									SDKHooks_TakeDamage(target, npc.index, npc.index, fl_kahml_main_melee_damage[npc.index] * MultiGlobalHealth, DMG_CLUB, -1, _, vecHit);
								}
								else if(ShouldNpcDealBonusDamage(target))
								{
									SDKHooks_TakeDamage(target, npc.index, npc.index, 25.0*fl_kahml_main_melee_damage[npc.index] * MultiGlobalHealth, DMG_CLUB, -1, _, vecHit);
								
								}
								else
								{
									SDKHooks_TakeDamage(target, npc.index, npc.index, fl_kahml_main_melee_damage[npc.index] * MultiGlobalHealth, DMG_CLUB, -1, _, vecHit);
								}
								if(IsValidClient(target))
								{
									Custom_Knockback(npc.index, target, fl_kahml_knockback[npc.index]);
								}	
								i_kahml_combo[npc.index]++;
								i_kahml_megahit[npc.index]++;
								
								
								// Hit sound
								npc.PlayMeleeHitSound();
								
							} 
						}
						delete swingTrace;
						npc.m_flNextMeleeAttack = GameTime + fl_kahml_melee_speed[npc.index];
						npc.m_flAttackHappenswillhappen = false;
					}
					else if (npc.m_flAttackHappens_bullshit < GameTime && npc.m_flAttackHappenswillhappen)
					{
						npc.m_flAttackHappenswillhappen = false;
						npc.m_flNextMeleeAttack = GameTime + fl_kahml_melee_speed[npc.index];
					}
				}
			}
			else
			{
				npc.StartPathing();
			}
		}
		else if(b_kahml_annihilation[npc.index])	//&& !b_kahml_inNANOMACHINESSON[npc.index]
		{
			npc.m_flSpeed = 150.0;
			if(flDistanceToTarget < 10000000)
			{
				int Enemy_I_See;
				
				Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
				//Target close enough to hit
				if(IsValidEnemy(npc.index, Enemy_I_See))
				{
					//Look at target so we hit.
					npc.FaceTowards(vecTarget, 1500.0);
					
					//Can we attack right now?
					if(npc.m_flNextMeleeAttack < GameTime)
					{
						//Play attack anim
						npc.AddGesture("ACT_MP_DEPLOYED_PRIMARY");
						if(fl_attack_timeout[npc.index] < GameTime)
						{
							npc.PlayRangedSound();
							npc.FireRocket(vecTarget, fl_kahml_main_melee_damage[npc.index] * MultiGlobalHealth, 2500.0, "models/effects/combineball.mdl", 1.0, EP_NO_KNOCKBACK);
						}
						npc.m_flNextMeleeAttack = GameTime + 0.075 / fl_kahml_galactic_strenght[npc.index];
						
					}
				}
				else
				{
					npc.StartPathing();
				}
			}
			else
			{
				npc.StartPathing();
			}
		}
	}
	else
	{
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	if(b_kahml_annihilation[npc.index] && fl_TheFinalCountdown[npc.index] <= GameTime)
	{
		EmitSoundToAll("mvm/mvm_cpoint_klaxon.wav");
		fl_TheFinalCountdown[npc.index] = GameTime+1.0;
	}
	npc.PlayIdleAlertSound();
}

static Action Internal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Kahmlstein npc = view_as<Kahmlstein>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void Internal_NPCDeath(int entity)
{
	Kahmlstein npc = view_as<Kahmlstein>(entity);
	npc.PlayDeathSound();	
	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
	ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
	CPrintToChatAll("{blue}캄르스타인{default}: 점점 지겹군. 잘 있어라.");

	if(npc.index==EntRefToEntIndex(RaidBossActive))
		RaidBossActive=INVALID_ENT_REFERENCE;
	
	if(IsValidEntity(npc.m_iWearable1))	//used for all weps
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))	//particles
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))	//particles
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
}