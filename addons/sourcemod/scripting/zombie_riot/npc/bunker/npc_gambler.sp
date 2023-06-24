#pragma semicolon 1
#pragma newdecls required

//GAMBLERS CASH NEEDS TO BE IN ZOMBIE_RIOT.SP WITH A CUSTOM HEALTH HUD THERE IS NO OTHER WAY MAKING IT SEEABLE WITHOUT
//DOING AN UGLY WAY. LINE 100 IS THE ONE NEEDED
//JUST A REMINDER THIS .SP WILL GET A BETTER WAY OF DOING THE GUNS I JUST COPY AND PASTED IT CONSTANTLY FOR NO REASON
//ORB IS DISABLED CAUSE I HAVE NO IDEA HOW TO PROPERLY DO IT AND IT NEEDS A 7TH WEARABLE SLOT ANYWAY

static const char g_DeathSounds[][] = {
	"vo/spy_paincrticialdeath01.mp3",
	"vo/spy_paincrticialdeath02.mp3",
	"vo/spy_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/spy_painsharp01.mp3",
	"vo/spy_painsharp02.mp3",
	"vo/spy_painsharp03.mp3",
	"vo/spy_painsharp04.mp3",
};

static const char g_IdleSounds[][] = {
	"vo/spy_laughshort01.mp3",
	"vo/spy_laughshort02.mp3",
	"vo/spy_laughshort03.mp3",
	"vo/spy_laughshort04.mp3",
	"vo/spy_laughshort05.mp3",
	"vo/spy_laughshort06.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/spy_battlecry01.mp3",
	"vo/spy_battlecry02.mp3",
	"vo/spy_battlecry03.mp3",
	"vo/spy_battlecry04.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/blade_hit1.wav",
	"weapons/blade_hit2.wav",
	"weapons/blade_hit3.wav",
	"weapons/blade_hit4.wav",
};

static const char g_MeleeHitSoundsJawbreaker[][] = {
	"misc/doomsday_missile_explosion.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/knife_swing.wav",
};

static const char g_MeleeMissSounds[][] = {
	"weapons/cbar_miss1.wav",
};

static const char g_RangedAttackSounds[][] = {
	"weapons/ambassador_shoot.wav",
};

static const char g_RangedReloadSound[][] = {
	"weapons/revolver_worldreload.wav",
};

static const char g_RangeAttackTwo[][] = {
	"weapons/letranger_shoot.wav",
};

static const char g_RangeAttackThird[][] = {
	"weapons/doom_sniper_smg.wav",
};

static float GamblerNormalSpeed = 330.0;//Zooming speed
static float DefaultDamage = 125.0;//Default Damage
static float CashGain_OnHit = 70.0;//How much cash can he gain on hit
static float DefaultNpcBuildingDamage = 3400.0;//Default Damage on buildings/npcs
static float Jawbreaker_Damage = 19400.0;//InstaKill
static float Jawbreaker_DamageNpcBuilding = 35400.0;//InstaKill fuck your buildings and allied npcs
static float Jawbreaker_Cashgain_OnHit = 150.0;//How much cash he gains 
static float Exodia_MinDamage = 170.0;//How low the Min Damage is
static float Exodia_MaxDamage = 3000.0;//How much the Max Damage is 
static float Archers_Anhilation_Damage = 140.0;//How much Archer deals
static float PelletGun_Damage = 60.0;//How much pellet deals
static float WeakMachineGun_Smg_Damage = 15.0;//How much machine deals

static bool TempOpener4[MAXENTITIES]= {false, ...};
static bool AllowExperimentalGearDamage[MAXENTITIES] = {false, ...};
static bool ExperimentalGear_On[MAXENTITIES] = {false, ...};
static float ExperimentalGear_Time[MAXENTITIES];
static float ExperimentalGear_FirstUsageTimer = 10.0;//First use on experimental
static float ExperimentalGear_ReUsageTimer = 15.0;//After First use cooldown
static float ExperimentalGear_Wearoff = 15.0;//How long he keeps the res/damage bonus
static float ExperimentalGearDamageTakenMin = 1.20;//How much damage taken he can gain
static float ExperimentalGearDamageTakenMax = 0.01;//How much damage res he can gain
static float ExperimentalGearDamage[MAXENTITIES];
static float CasinoDamageMin = 50.0;//How low the Min Damage is
static float CasinoDamageMax = 430.0;//How much the Max Damage is 

static bool Gambler_AbilityManagement[MAXENTITIES] = {false, ...};
static float Gambler_AbilityManagement_Timer[MAXENTITIES];
static float Gambler_AbilityManagementFirstTimer = 10.0;//First use on his weapons(thats if he has the cash)
static float Gambler_AbilityManagementReuseTimer = 15.0;//Reuse on his weapons(thats if he has the cash once again)

static bool SlotMachine_Usage[MAXENTITIES] = {false, ...};
static bool TempOpener5[MAXENTITIES] = {false, ...};
static float SlotMachine_Timer[MAXENTITIES];
static float SlotMachine_FirstUsageTimer = 6.0;//How long he takes to use it first
static float SlotMachine_ReusageTimer = 6.0;//Reuse timer
static float SlotMachine_CashMin = 0.75;//how much can he lose
static float SlotMachine_CashMax = 1.45;//how much can he win

//static bool Cash_Usage[MAXENTITIES];//idk i don't remember why i used this??
static float Cash_RegainTimer[MAXENTITIES];
//static float GamblersCash[MAXENTITIES];
float GamblersCash[MAXENTITIES];
static float Cash_Timer = 0.33;//How much he gets per xx sec
//static float Cash_Gain = 0.60;//How much cash gain he gets
static float Cash_Gain = 0.60;//How much cash gain he gets

static bool ActivateArchersAnhilation[MAXENTITIES] = {false, ...};
static bool Archers_Anhilation[MAXENTITIES] = {false, ...};
static float Archers_Anhilation_Timer[MAXENTITIES];
static float Archers_Anhilation_Wearoff = 7.0;//How long it should last

static bool ActivateJawBreaker[MAXENTITIES] = {false, ...};
static bool Jawbreaker_On[MAXENTITIES] = {false, ...};
static float Jawbreaker_Time[MAXENTITIES];
static int Jawbreaker_Hits[MAXENTITIES];
static float Jawbreaker_Wearoff = 10.0;//How long it should last
static int Jawbreaker_MaxHits = 1;//How long it should last
//static float Jawbreaker_FirstUsageTimer = 30.0;
//static float Jawbreaker_ReUsageTimer = 30.0;

static bool ActivateExodia[MAXENTITIES] = {false, ...};
static bool Exodia_TheFuckYouGun[MAXENTITIES] = {false, ...};
static float Exodia_Timer[MAXENTITIES];
static int Exodia_Hits[MAXENTITIES];
static float ExodiaWearoff = 7.0;//How long it should last
static int Exodia_MaxHits = 2;//How long it should last

static bool ActivatePelletGun[MAXENTITIES] = {false, ...};
static bool Pellet_Gun[MAXENTITIES] = {false, ...};
static float PelletGun_Timer[MAXENTITIES];
static float PelletGun_Wearoff = 6.0;//How long it should last

static bool ActivateWeakMachineGunSmg[MAXENTITIES] = {false, ...};
static bool WeakMachineGun_Smg[MAXENTITIES] = {false, ...};
static float WeakMachineGun_SmgTimer[MAXENTITIES];
static float WeakMachineGun_Smg_Wearoff = 10.0;//How long it should last

static bool ActivateTheHolyOrb[MAXENTITIES] = {false, ...};//those are still active (cause i am a lazy shithead removing every line off it)
static bool TheHolyOrb[MAXENTITIES] = {false, ...};
/*
static float TheHolyOrb_Timer[MAXENTITIES];
static float TheHolyOrb_Wearoff = 6.0;
static float Orb_Damage_Projectile[MAXENTITIES];
static int Orb_Projectile_To_Client[MAXENTITIES]={0, ...};
static int Orb_Projectile_To_Particle[MAXENTITIES];
static float Orb_Damage_Reduction[MAXENTITIES] = {0.0, ...};
static float Orb_Damage_Tornado[MAXENTITIES] = {0.0, ...};
static float Orb_Radius[MAXTF2PLAYERS];
static int Gambler_Beam_laser;
static int Gambler_Beam_Glow;*/

#define GAMBLERMODEL "models/freak_fortress_2/bvb_normalgambler/bvb_normalgambler.mdl"
#define EXPERIMENTALDING "ui/chime_rd_2base_pos.wav"
#define SLOTMACHINEFAIL "mvm/mvm_player_died.wav"
#define SLOTMACHINESUCCESS "mvm/mvm_bought_upgrade.wav"
#define BADWEAPON "freak_fortress_2/gambler_raid/gamblerv3_badweapon2.mp3"
#define GOODWEAPON1 "freak_fortress_2/gambler_raid/gamblerv3_goodweapon1.mp3"
#define JAWBREAKER_HIDINGWONTSAVEYOUFIGHTINGWONTSAVEYOUNOTHINGWILLSAVEYOU "freak_fortress_2/gambler_raid/gamblerv3_goodweapon4.mp3"
//#define ENERGY_BALL_MODEL	"models/weapons/w_models/w_drg_ball.mdl"
//#define SOUND_WAND_SHOT 	"weapons/capper_shoot.wav"
//#define SOUND_ZAP "misc/halloween/spell_lightning_ball_impact.wav"

void TheGambler_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeHitSoundsJawbreaker));	i++) { PrecacheSound(g_MeleeHitSoundsJawbreaker[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++) { PrecacheSound(g_RangedAttackSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedReloadSound));   i++) { PrecacheSound(g_RangedReloadSound[i]);   }
	for (int i = 0; i < (sizeof(g_RangeAttackTwo));   i++) { PrecacheSound(g_RangeAttackTwo[i]);   }
	for (int i = 0; i < (sizeof(g_RangeAttackThird));   i++) { PrecacheSound(g_RangeAttackThird[i]);   }
	
	PrecacheModel("models/props_wasteland/rockgranite03b.mdl");
	PrecacheModel("models/weapons/w_bullet.mdl");
	PrecacheModel("models/weapons/w_grenade.mdl");
	PrecacheModel("models/weapons/c_models/c_ava_roseknife/c_ava_roseknife.mdl");
	PrecacheModel("models/weapons/c_models/c_boxing_gloves/c_boxing_gloves.mdl");
	PrecacheModel("models/weapons/c_models/c_bow/c_bow_thief.mdl");
	PrecacheModel("models/weapons/c_models/c_letranger/c_letranger.mdl");
	PrecacheModel("models/weapons/c_models/c_pro_smg/c_pro_smg.mdl");
	//PrecacheModel("models/weapons/c_models/c_drg_pomson/c_drg_pomson.mdl");
	
	PrecacheSound("ambient/explosions/citadel_end_explosion2.wav",true);
	PrecacheSound("ambient/explosions/citadel_end_explosion1.wav",true);
	PrecacheSound("ambient/energy/weld1.wav",true);
	PrecacheSound("ambient/halloween/mysterious_perc_01.wav",true);
	
	PrecacheSound("player/flow.wav");
	PrecacheSound(EXPERIMENTALDING, true);
	PrecacheSound(SLOTMACHINEFAIL, true);
	PrecacheSound(SLOTMACHINESUCCESS, true);
	PrecacheSound(BADWEAPON, true);
	PrecacheSound(GOODWEAPON1, true);
	PrecacheSound(JAWBREAKER_HIDINGWONTSAVEYOUFIGHTINGWONTSAVEYOUNOTHINGWILLSAVEYOU, true);
	PrecacheModel(GAMBLERMODEL, true);
	//Gambler_Beam_laser = PrecacheModel("materials/sprites/laser.vmt", false);
	//Gambler_Beam_Glow = PrecacheModel("sprites/glow02.vmt", true);
	//PrecacheModel("models/freak_fortress_2/bvb_normalgambler/bvb_normalgambler.mdl", true);
}

methodmap TheGambler < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleSound()");
		#endif
	}
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleAlertSound()");
		#endif
	}
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayHurtSound()");
		#endif
	}
	public void PlayDeathSound() {
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayDeathSound()");
		#endif
	}
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayRangedSound()");
		#endif
	}
	public void PlayRangedTwoSound() {
		EmitSoundToAll(g_RangeAttackTwo[GetRandomInt(0, sizeof(g_RangeAttackTwo) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayRangedSound()");
		#endif
	}
	public void PlayRangedThirdSound() {
		EmitSoundToAll(g_RangeAttackThird[GetRandomInt(0, sizeof(g_RangeAttackThird) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayRangedSound()");
		#endif
	}
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayRangedSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeHitSoundJawbreaker() {
		EmitSoundToAll(g_MeleeHitSoundsJawbreaker[GetRandomInt(0, sizeof(g_MeleeHitSoundsJawbreaker) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayMeleeMissSound()");
		#endif
	}
	
	public TheGambler(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		TheGambler npc = view_as<TheGambler>(CClotBody(vecPos, vecAng, GAMBLERMODEL, "1.0", "180000", ally));
		
		i_NpcInternalId[npc.index] = THE_GAMBLER;
		//RaidBossGambler = EntRefToEntIndex(npc.index);
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		if(!b_IsAlliedNpc[npc.index])
		{
			RaidBossActive = EntRefToEntIndex(npc.index);
			for(int client_check=1; client_check<=MaxClients; client_check++)
			{
				if(IsClientInGame(client_check) && !IsFakeClient(client_check))
				{
					//LookAtTarget(client_check, npc.index);
					SetGlobalTransTarget(client_check);
					ShowGameText(client_check, "item_armor", 1, "%t", "Gambler Spawn Message");
				}
			}
			RaidModeTime = GetGameTime(npc.index) + 200.0;	
		}
		npc.m_bThisNpcIsABoss = true;
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		
		SDKHook(npc.index, SDKHook_Think, TheGambler_ClotThink);		
		
		npc.m_iAttacksTillReload = 6;
		
		//SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		//SetEntityRenderColor(npc.index, 255, 255, 255, 60);

		npc.m_fbGunout = false;
		npc.m_bmovedelay = false;
		ExperimentalGear_Time[npc.index] = GetGameTime(npc.index) + ExperimentalGear_FirstUsageTimer;
		Gambler_AbilityManagement_Timer[npc.index] = GetGameTime(npc.index) + Gambler_AbilityManagementFirstTimer;
		Cash_RegainTimer[npc.index] = GetGameTime(npc.index) + Cash_Timer;
		SlotMachine_Timer[npc.index] = GetGameTime(npc.index) + SlotMachine_FirstUsageTimer;
		//Jawbreaker_Time[npc.index] = GetGameTime(npc.index) + Jawbreaker_FirstUsageTimer;
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		npc.m_iState = 0;
		npc.m_flSpeed = GamblerNormalSpeed;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		GamblersCash[npc.index] = 0.1;
		Jawbreaker_Hits[npc.index] = 0;
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_ambassador/c_ambassador.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_ava_roseknife/c_ava_roseknife.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_boxing_gloves/c_boxing_gloves.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		npc.m_iWearable4 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_bow/c_bow_thief.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		
		npc.m_iWearable5 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_letranger/c_letranger.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		
		npc.m_iWearable6 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_pro_smg/c_pro_smg.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");
		
		//npc.m_iWearable7 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_drg_pomson/c_drg_pomson.mdl");
		//SetVariantString("1.0");
		//AcceptEntityInput(npc.m_iWearable7, "SetModelScale");
		if(b_IsAlliedNpc[npc.index])
		{
			int skin = 0;
			SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		}
		else
		{
			int skin = 1;
			SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
			SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
			//SetEntProp(npc.m_iWearable7, Prop_Send, "m_nSkin", skin);
		}
		AcceptEntityInput(npc.m_iWearable1, "Disable");
		AcceptEntityInput(npc.m_iWearable2, "Enable");
		AcceptEntityInput(npc.m_iWearable3, "Disable");
		AcceptEntityInput(npc.m_iWearable4, "Disable");
		AcceptEntityInput(npc.m_iWearable5, "Disable");
		AcceptEntityInput(npc.m_iWearable6, "Disable");
		//AcceptEntityInput(npc.m_iWearable7, "Disable");
		
		return npc;
	}
}

public void TheGambler_ClotThink(int iNPC)
{
	TheGambler npc = view_as<TheGambler>(iNPC);
	
	float CasinoChosenDamage = GetRandomFloat(CasinoDamageMin, CasinoDamageMax);
	float RandomizedDamageTaken = GetRandomFloat(ExperimentalGearDamageTakenMin, ExperimentalGearDamageTakenMax);
	float SlotMachineMaxCashGain = GetRandomFloat(SlotMachine_CashMin, SlotMachine_CashMax);
	float ExodiaRandomizedDamage = GetRandomFloat(Exodia_MinDamage, Exodia_MaxDamage);
	
	if(RaidModeTime < GetGameTime())
	{
		int entity = CreateEntityByName("game_round_win"); //You loose.
		DispatchKeyValue(entity, "force_map_reset", "1");
		SetEntProp(entity, Prop_Data, "m_iTeamNum", TFTeam_Blue);
		DispatchSpawn(entity);
		AcceptEntityInput(entity, "RoundWin");
		Music_RoundEnd(entity);
		RaidBossActive = INVALID_ENT_REFERENCE;
		SDKUnhook(npc.index, SDKHook_Think, TheGambler_ClotThink);
	}
	
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
	
	if(Cash_RegainTimer[npc.index] <= GetGameTime(npc.index) && GamblersCash[npc.index] <= 50000.0)
	{
		Cash_RegainTimer[npc.index] = Cash_Timer;
		GamblersCash[npc.index] += Cash_Gain;
	}
	if(GamblersCash[npc.index] >= 50000.0)
	{
		GamblersCash[npc.index] = 50000.0;
	}
	if(!ExperimentalGear_On[npc.index] && ExperimentalGear_Time[npc.index] <= GetGameTime(npc.index) && !TempOpener4[npc.index] && !AllowExperimentalGearDamage[npc.index] && GamblersCash[npc.index] >= 500.0)
	{
		//ExperimentalGear_Time = GetGameTime(npc.index) + ExperimentalGear_ReUsageTimer;
		ExperimentalGear_Time[npc.index] = GetGameTime(npc.index) + ExperimentalGear_Wearoff;
		ExperimentalGear_On[npc.index] = true;
		AllowExperimentalGearDamage[npc.index] = true;
		TempOpener4[npc.index] = true;
		GamblersCash[npc.index] += -500.0;
		EmitSoundToAll(EXPERIMENTALDING, _, _, _, _, 1.0);
		//CPrintToChatAll("DING");
	}
	if(AllowExperimentalGearDamage[npc.index])
	{
		AllowExperimentalGearDamage[npc.index] = false;
		ExperimentalGearDamage[npc.index] = CasinoChosenDamage;
		CPrintToChatAll("{cyan}[Bunker] {green}Gambler Now deals additional {orange}%.0f Damage.", ExperimentalGearDamage[npc.index]);
	}
	if(ExperimentalGear_On[npc.index] && TempOpener4[npc.index])
	{
		npc.m_flMeleeArmor = RandomizedDamageTaken;
		npc.m_flRangedArmor = RandomizedDamageTaken;
		
		if(RandomizedDamageTaken < 0.99)
		{
			CPrintToChatAll("{cyan}[Bunker] {green}Gambler Now takes {yellow}%i%% less Damage.", 100 - RoundFloat(100 * RandomizedDamageTaken));
		}
		else
		{
			CPrintToChatAll("{cyan}[Bunker] {green}Gambler Now takes {red}%i%% more Damage.", -(100 - RoundFloat(100 * RandomizedDamageTaken)));
		}
		TempOpener4[npc.index] = false;
	}
	if(ExperimentalGear_On[npc.index] && ExperimentalGear_Time[npc.index] <= GetGameTime(npc.index))
	{
		//ExperimentalGear_Time = GetGameTime(npc.index) + ExperimentalGear_ReUsageTimer;
		ExperimentalGear_Time[npc.index] = GetGameTime(npc.index) + ExperimentalGear_ReUsageTimer;
		ExperimentalGear_On[npc.index] = false;
		npc.m_flMeleeArmor = 1.0;
		npc.m_flRangedArmor = 1.0;
		EmitSoundToAll(EXPERIMENTALDING, _, _, _, _, 1.0);
		//CPrintToChatAll("DING2");
	}
	if(SlotMachine_Timer[npc.index] <= GetGameTime(npc.index) && !SlotMachine_Usage[npc.index] && !TempOpener5[npc.index] && GamblersCash[npc.index] <= 49999.99)
	{
		//GamblersCash[npc.index] * SlotMachineMaxCashGain;
		SlotMachine_Usage[npc.index] = true;
		TempOpener5[npc.index] = true;
		SlotMachine_Timer[npc.index] = GetGameTime(npc.index) + SlotMachine_ReusageTimer;
	}
	if(SlotMachine_Usage[npc.index] && TempOpener5[npc.index])
	{
		GamblersCash[npc.index] *= SlotMachineMaxCashGain;
		SlotMachine_Usage[npc.index] = false;
		TempOpener5[npc.index] = false;
		if(SlotMachineMaxCashGain <= 1.00)
		{
			EmitSoundToAll(SLOTMACHINEFAIL, _, _, _, _, 1.0);
			CPrintToChatAll("{cyan}[Bunker] {green}Gambler lost {yellow}%i%% {green}of his cash.", 100 - RoundFloat(100 * SlotMachineMaxCashGain));
		}
		if(SlotMachineMaxCashGain >= 1.00)
		{
			EmitSoundToAll(SLOTMACHINESUCCESS, _, _, _, _, 1.0);
			CPrintToChatAll("{cyan}[Bunker] {green}Gambler won {red}%i%% {green}of his cash.", -(100 - RoundFloat(100 * SlotMachineMaxCashGain)));
		}
	}
	if(Gambler_AbilityManagement_Timer[npc.index] <= GetGameTime(npc.index) && !Gambler_AbilityManagement[npc.index] && !Jawbreaker_On[npc.index] && !Archers_Anhilation[npc.index] && !Exodia_TheFuckYouGun[npc.index] && !Pellet_Gun[npc.index] && !WeakMachineGun_Smg[npc.index] && !TheHolyOrb[npc.index] && GamblersCash[npc.index] >= 700.0)
	{
		switch(GetRandomInt(1, 6))
		{
			case 1:
			{
				ActivateJawBreaker[npc.index] = true;
			}
			case 2:
			{
				ActivateArchersAnhilation[npc.index] = true;
			}
			case 3:
			{
				ActivateExodia[npc.index] = true;
			}
			case 4:
			{
				ActivatePelletGun[npc.index] = true;
			}
			case 5:
			{
				ActivateWeakMachineGunSmg[npc.index] = true;
			}
			//case 6:
			//{
			//	ActivateTheHolyOrb[npc.index] = true;
			//}
			default:
			{
				EmitSoundToAll(BADWEAPON, _, _, _, _, 1.0);
				CPrintToChatAll("{cyan}[Bunker] {green}Gambler gained a broken gun and threw it away.");
			}
		}
		GamblersCash[npc.index] += -700.0;
		Gambler_AbilityManagement_Timer[npc.index] = GetGameTime(npc.index) + Gambler_AbilityManagementReuseTimer;
	}//The Reason why it has so many disable and enable input is just for SAFTY that it won't fuck up again since on my testserver it liked to go on client weapons somehow?
	if(!Jawbreaker_On[npc.index] && Jawbreaker_Time[npc.index] <= GetGameTime(npc.index) && ActivateJawBreaker[npc.index] && !Archers_Anhilation[npc.index] && !ActivateExodia[npc.index] && !ActivatePelletGun[npc.index] && !ActivateWeakMachineGunSmg[npc.index] && !ActivateTheHolyOrb[npc.index])
	{
		EmitSoundToAll(JAWBREAKER_HIDINGWONTSAVEYOUFIGHTINGWONTSAVEYOUNOTHINGWILLSAVEYOU, _, _, _, _, 1.0);
		Jawbreaker_Time[npc.index] = GetGameTime(npc.index) + Jawbreaker_Wearoff;
		ActivateJawBreaker[npc.index] = false;
		Jawbreaker_On[npc.index] = true;
		CPrintToChatAll("{crimson}[WARNING!!]{Default} {yellow}Gambler Obtained {red}JAWBREAKER!");
	}
	if(Jawbreaker_On[npc.index] && Jawbreaker_Time[npc.index] <= GetGameTime(npc.index) || Jawbreaker_On[npc.index] && Jawbreaker_Hits[npc.index] == Jawbreaker_MaxHits)
	{
		Jawbreaker_On[npc.index] = false;
		Jawbreaker_Hits[npc.index] = 0;
		//Jawbreaker_Time[npc.index] = GetGameTime(npc.index) + Jawbreaker_ReUsageTimer;
	}
	if(!Archers_Anhilation[npc.index] && Archers_Anhilation_Timer[npc.index] <= GetGameTime(npc.index) && ActivateArchersAnhilation[npc.index] && !ActivateJawBreaker[npc.index] && !ActivateExodia[npc.index] && !ActivatePelletGun[npc.index] && !ActivateWeakMachineGunSmg[npc.index] && !ActivateTheHolyOrb[npc.index])
	{
		EmitSoundToAll(GOODWEAPON1, _, _, _, _, 1.0);
		Archers_Anhilation_Timer[npc.index] = GetGameTime(npc.index) + Archers_Anhilation_Wearoff;
		ActivateArchersAnhilation[npc.index] = false;
		Archers_Anhilation[npc.index] = true;
		CPrintToChatAll("{crimson}[WARNING!!]{Default} {yellow}Gambler Obtained {red}ARCHERS ANHILATION!");
	}
	if(Archers_Anhilation[npc.index] && Archers_Anhilation_Timer[npc.index] <= GetGameTime(npc.index))
	{
		Archers_Anhilation[npc.index] = false;
		//Jawbreaker_Time[npc.index] = GetGameTime(npc.index) + Jawbreaker_ReUsageTimer;
	}
	if(!Exodia_TheFuckYouGun[npc.index] && Exodia_Timer[npc.index] <= GetGameTime(npc.index) && ActivateExodia[npc.index] && !ActivateArchersAnhilation[npc.index] && !ActivateJawBreaker[npc.index] && !ActivatePelletGun[npc.index] && !ActivateWeakMachineGunSmg[npc.index] && !ActivateTheHolyOrb[npc.index])
	{
		EmitSoundToAll(GOODWEAPON1, _, _, _, _, 1.0);
		Exodia_Timer[npc.index] = GetGameTime(npc.index) + ExodiaWearoff;
		ActivateExodia[npc.index] = false;
		Exodia_TheFuckYouGun[npc.index] = true;
		CPrintToChatAll("{crimson}[WARNING!!]{Default} {yellow}Gambler Obtained {red}EXODIA!");
	}
	if(Exodia_TheFuckYouGun[npc.index] && Exodia_Timer[npc.index] <= GetGameTime(npc.index)  || !Exodia_TheFuckYouGun[npc.index] && Exodia_Hits[npc.index] == Exodia_MaxHits)
	{
		Exodia_TheFuckYouGun[npc.index] = false;
		Exodia_Hits[npc.index] = 0;
	}
	if(!Pellet_Gun[npc.index] && PelletGun_Timer[npc.index] <= GetGameTime(npc.index) && ActivatePelletGun[npc.index] && !ActivateArchersAnhilation[npc.index] && !ActivateJawBreaker[npc.index] && !ActivateExodia[npc.index] && !ActivateWeakMachineGunSmg[npc.index] && !ActivateTheHolyOrb[npc.index])
	{
		EmitSoundToAll(GOODWEAPON1, _, _, _, _, 1.0);
		PelletGun_Timer[npc.index] = GetGameTime(npc.index) + PelletGun_Wearoff;
		ActivatePelletGun[npc.index] = false;
		Pellet_Gun[npc.index] = true;
		CPrintToChatAll("{crimson}[WARNING!!]{Default} {yellow}Gambler Obtained {green}Pellet Gun!");
	}
	if(Pellet_Gun[npc.index] && PelletGun_Timer[npc.index] <= GetGameTime(npc.index))
	{
		Pellet_Gun[npc.index] = false;
	}
	if(!WeakMachineGun_Smg[npc.index] && WeakMachineGun_SmgTimer[npc.index] <= GetGameTime(npc.index) && ActivateWeakMachineGunSmg[npc.index] && !ActivateArchersAnhilation[npc.index] && !ActivateJawBreaker[npc.index] && !ActivateExodia[npc.index] && !ActivatePelletGun[npc.index] && !ActivateTheHolyOrb[npc.index])
	{
		EmitSoundToAll(GOODWEAPON1, _, _, _, _, 1.0);
		WeakMachineGun_SmgTimer[npc.index] = GetGameTime(npc.index) + WeakMachineGun_Smg_Wearoff;
		ActivateWeakMachineGunSmg[npc.index] = false;
		WeakMachineGun_Smg[npc.index] = true;
		CPrintToChatAll("{crimson}[WARNING!!]{Default} {yellow}Gambler Obtained {orange}Weak Machine Gun Smg!");
	}
	if(WeakMachineGun_Smg[npc.index] && WeakMachineGun_SmgTimer[npc.index] <= GetGameTime(npc.index))
	{
		WeakMachineGun_Smg[npc.index] = false;
	}
	/*if(!TheHolyOrb[npc.index] && TheHolyOrb_Timer[npc.index] <= GetGameTime(npc.index) && ActivateTheHolyOrb[npc.index] && !ActivateWeakMachineGunSmg[npc.index] && !ActivateArchersAnhilation[npc.index] && !ActivateJawBreaker[npc.index] && !ActivateExodia[npc.index] && !ActivatePelletGun[npc.index])
	{
		EmitSoundToAll(GOODWEAPON1, _, _, _, _, 1.0);
		TheHolyOrb_Timer[npc.index] = GetGameTime(npc.index) + TheHolyOrb_Wearoff;
		ActivateTheHolyOrb[npc.index] = false;
		TheHolyOrb[npc.index] = true;
		CPrintToChatAll("{crimson}[WARNING!!]{Default} {yellow}Gambler Obtained {red}THE HOLY ORB!");
	}
	if(TheHolyOrb[npc.index] && TheHolyOrb_Timer[npc.index] <= GetGameTime(npc.index))
	{
		TheHolyOrb[npc.index] = false;
	}*/
	if(npc.m_iChanged_WalkCycle != 2 && !Jawbreaker_On[npc.index] && !Archers_Anhilation[npc.index] && !Exodia_TheFuckYouGun[npc.index] && !WeakMachineGun_Smg[npc.index] && !Pellet_Gun[npc.index] && !TheHolyOrb[npc.index])
	{//Back to original melee
		npc.m_iChanged_WalkCycle = 2;
		AcceptEntityInput(npc.m_iWearable1, "Disable");
		AcceptEntityInput(npc.m_iWearable2, "Enable");
		AcceptEntityInput(npc.m_iWearable3, "Disable");
		AcceptEntityInput(npc.m_iWearable4, "Disable");
		AcceptEntityInput(npc.m_iWearable5, "Disable");
		AcceptEntityInput(npc.m_iWearable6, "Disable");
		//AcceptEntityInput(npc.m_iWearable7, "Disable");
		int iActivity_melee = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
	}
	if(npc.m_iChanged_WalkCycle != 2 && Jawbreaker_On[npc.index] && !Archers_Anhilation[npc.index] && !Exodia_TheFuckYouGun[npc.index] && !WeakMachineGun_Smg[npc.index] && !Pellet_Gun[npc.index] && !TheHolyOrb[npc.index])
	{//Jawbreaker
		npc.m_iChanged_WalkCycle = 2;
		AcceptEntityInput(npc.m_iWearable1, "Disable");
		AcceptEntityInput(npc.m_iWearable2, "Disable");
		AcceptEntityInput(npc.m_iWearable3, "Enable");
		AcceptEntityInput(npc.m_iWearable4, "Disable");
		AcceptEntityInput(npc.m_iWearable5, "Disable");
		AcceptEntityInput(npc.m_iWearable6, "Disable");
		//AcceptEntityInput(npc.m_iWearable7, "Disable");
		int iActivity_melee = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
	}
	if(npc.m_iChanged_WalkCycle != 1 && Archers_Anhilation[npc.index] && !Jawbreaker_On[npc.index] && !Exodia_TheFuckYouGun[npc.index] && !WeakMachineGun_Smg[npc.index] && !Pellet_Gun[npc.index] && !TheHolyOrb[npc.index])
	{//Archer
		npc.m_iChanged_WalkCycle = 1;
		AcceptEntityInput(npc.m_iWearable1, "Disable");
		AcceptEntityInput(npc.m_iWearable2, "Disable");
		AcceptEntityInput(npc.m_iWearable3, "Disable");
		AcceptEntityInput(npc.m_iWearable4, "Enable");
		AcceptEntityInput(npc.m_iWearable5, "Disable");
		AcceptEntityInput(npc.m_iWearable6, "Disable");
		//AcceptEntityInput(npc.m_iWearable7, "Disable");
		int iActivity_melee = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
		if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
	}
	if(npc.m_iChanged_WalkCycle != 1 && Exodia_TheFuckYouGun[npc.index] && !Archers_Anhilation[npc.index] && !Jawbreaker_On[npc.index] && !WeakMachineGun_Smg[npc.index] && !Pellet_Gun[npc.index] && !TheHolyOrb[npc.index])
	{//Exodia
		npc.m_iChanged_WalkCycle = 1;
		AcceptEntityInput(npc.m_iWearable1, "Enable");
		AcceptEntityInput(npc.m_iWearable2, "Disable");
		AcceptEntityInput(npc.m_iWearable3, "Disable");
		AcceptEntityInput(npc.m_iWearable4, "Disable");
		AcceptEntityInput(npc.m_iWearable5, "Disable");
		AcceptEntityInput(npc.m_iWearable6, "Disable");
		//AcceptEntityInput(npc.m_iWearable7, "Disable");
		int iActivity_melee = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
		if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
	}
	if(npc.m_iChanged_WalkCycle != 1 && Pellet_Gun[npc.index] && !Exodia_TheFuckYouGun[npc.index] && !Archers_Anhilation[npc.index] && !Jawbreaker_On[npc.index] && !WeakMachineGun_Smg[npc.index] && !TheHolyOrb[npc.index])
	{//Exodia
		npc.m_iChanged_WalkCycle = 1;
		AcceptEntityInput(npc.m_iWearable1, "Disable");
		AcceptEntityInput(npc.m_iWearable2, "Disable");
		AcceptEntityInput(npc.m_iWearable3, "Disable");
		AcceptEntityInput(npc.m_iWearable4, "Disable");
		AcceptEntityInput(npc.m_iWearable5, "Enable");
		AcceptEntityInput(npc.m_iWearable6, "Disable");
		//AcceptEntityInput(npc.m_iWearable7, "Disable");
		int iActivity_melee = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
		if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
	}
	if(npc.m_iChanged_WalkCycle != 1 && WeakMachineGun_Smg[npc.index] && !Pellet_Gun[npc.index] && !Exodia_TheFuckYouGun[npc.index] && !Archers_Anhilation[npc.index] && !Jawbreaker_On[npc.index] && !TheHolyOrb[npc.index])
	{//Exodia
		npc.m_iChanged_WalkCycle = 1;
		AcceptEntityInput(npc.m_iWearable1, "Disable");
		AcceptEntityInput(npc.m_iWearable2, "Disable");
		AcceptEntityInput(npc.m_iWearable3, "Disable");
		AcceptEntityInput(npc.m_iWearable4, "Disable");
		AcceptEntityInput(npc.m_iWearable5, "Disable");
		AcceptEntityInput(npc.m_iWearable6, "Enable");
		//AcceptEntityInput(npc.m_iWearable7, "Disable");
		int iActivity_melee = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
		if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
	}
	/*
	if(npc.m_iChanged_WalkCycle != 1 && TheHolyOrb[npc.index] && !WeakMachineGun_Smg[npc.index] && !Pellet_Gun[npc.index] && !Exodia_TheFuckYouGun[npc.index] && !Archers_Anhilation[npc.index] && !Jawbreaker_On[npc.index])
	{//Exodia
		npc.m_iChanged_WalkCycle = 1;
		AcceptEntityInput(npc.m_iWearable1, "Disable");
		AcceptEntityInput(npc.m_iWearable2, "Disable");
		AcceptEntityInput(npc.m_iWearable3, "Disable");
		AcceptEntityInput(npc.m_iWearable4, "Disable");
		AcceptEntityInput(npc.m_iWearable5, "Disable");
		AcceptEntityInput(npc.m_iWearable6, "Disable");
		AcceptEntityInput(npc.m_iWearable7, "Enable");
		int iActivity_melee = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
		if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
	}*/
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex, true))
	{
		float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
		float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
		//Predict their pos.
		
		if(flDistanceToTarget < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, PrimaryThreatIndex);
			//int color[4];
			//color[0] = 255;
			//color[1] = 255;
			//color[2] = 0;
			//color[3] = 255;
			
			//int xd = PrecacheModel("materials/sprites/laserbeam.vmt");
			
			//TE_SetupBeamPoints(vPredictedPos, vecTarget, xd, xd, 0, 0, 0.25, 0.5, 0.5, 5, 5.0, color, 30);
			//TE_SendToAllInRange(vecTarget, RangeType_Visibility);
			NPC_SetGoalVector(npc.index, vPredictedPos);
		}
		else
		{
			NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
		}//REMIND ME TO REDO THE GUNS THIS IS THE MOST UGILIEST WAY DOING THIS BUT IT WORKS STILL THANK YOU!!!
		if(npc.m_flNextRangedAttack < GetGameTime(npc.index) && flDistanceToTarget < 1425000 && npc.m_flReloadDelay < GetGameTime(npc.index) && Archers_Anhilation[npc.index])
		{//Archer
			int target;
			
			target = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
			if(!IsValidEnemy(npc.index, target))
			{
				npc.StartPathing();
			}
			else
			{
				vecTarget = PredictSubjectPositionForProjectiles(npc, PrimaryThreatIndex, 1400.0);
				//NPC_StopPathing(npc.index);
				//npc.m_bPathing = false;
				npc.FaceTowards(vecTarget, 10000.0);
				npc.m_flNextRangedAttack = GetGameTime(npc.index) + 0.4;
				//npc.m_iAttacksTillReload -= 1;
				
				float vecSpread = 0.1;
				
				float eyePitch[3];
				GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
				
				float x, y;
				x = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
				y = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
				
				float vecDirShooting[3], vecRight[3], vecUp[3];
				
				vecTarget[2] += 15.0;
				MakeVectorFromPoints(WorldSpaceCenter(npc.index), vecTarget, vecDirShooting);
				GetVectorAngles(vecDirShooting, vecDirShooting);
				vecDirShooting[1] = eyePitch[1];
				GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
				
				if(npc.m_iAttacksTillReload == 0)
				{
					npc.AddGesture("ACT_MP_RELOAD_STAND_SECONDARY");
					npc.m_flReloadDelay = GetGameTime(npc.index) + 1.0;
					npc.m_iAttacksTillReload = 500;
					//npc.PlayRangedReloadSound();
					//npc.AddGesture("ACT_MP_DEPLOYED_IDLE_ITEM");
				}
				
				npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY");
				float vecDir[3];
				vecDir[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
				vecDir[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
				vecDir[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
				NormalizeVector(vecDir, vecDir);
				
				if(ExperimentalGear_On[npc.index])
				{
					npc.FireArrow(vecTarget, Archers_Anhilation_Damage + ExperimentalGearDamage[npc.index], 1400.0, _, 1.0);
				}
				else
				{
					npc.FireArrow(vecTarget, Archers_Anhilation_Damage, 1400.0, _, 1.0);
				}
				
				//FireBullet(npc.index, npc.m_iWearable1, WorldSpaceCenter(npc.index), vecDir, 50.0, 9500.0, DMG_BULLET, "bullet_tracer01_red");
				//npc.PlayRangedSound();
			}
		}
		if(npc.m_flNextRangedAttack < GetGameTime(npc.index) && flDistanceToTarget < 1425000 && npc.m_flReloadDelay < GetGameTime(npc.index) && Exodia_TheFuckYouGun[npc.index])
		{//Exodia
			int target;
			
			target = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
			if(!IsValidEnemy(npc.index, target))
			{
				npc.StartPathing();
			}
			else
			{
				vecTarget = PredictSubjectPositionForProjectiles(npc, PrimaryThreatIndex, 1400.0);
				//NPC_StopPathing(npc.index);
				//npc.m_bPathing = false;
				npc.FaceTowards(vecTarget, 10000.0);
				npc.m_flNextRangedAttack = GetGameTime(npc.index) + 1.4;
				//npc.m_iAttacksTillReload -= 1;
				
				float vecSpread = 0.1;
				
				float eyePitch[3];
				GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
				
				float x, y;
				x = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
				y = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
				
				float vecDirShooting[3], vecRight[3], vecUp[3];
				
				vecTarget[2] += 15.0;
				MakeVectorFromPoints(WorldSpaceCenter(npc.index), vecTarget, vecDirShooting);
				GetVectorAngles(vecDirShooting, vecDirShooting);
				vecDirShooting[1] = eyePitch[1];
				GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
				
				if(npc.m_iAttacksTillReload == 0)
				{
					npc.AddGesture("ACT_MP_RELOAD_STAND_SECONDARY");
					npc.m_flReloadDelay = GetGameTime(npc.index) + 1.0;
					npc.m_iAttacksTillReload = 500;
					npc.PlayRangedReloadSound();
					//npc.AddGesture("ACT_MP_DEPLOYED_IDLE_ITEM");
				}
				
				npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY");
				float vecDir[3];
				vecDir[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
				vecDir[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
				vecDir[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
				NormalizeVector(vecDir, vecDir);
				
				if(ExperimentalGear_On[npc.index])
				{
					npc.FireArrow(vecTarget, ExodiaRandomizedDamage + ExperimentalGearDamage[npc.index], 1400.0, _, 1.0);
				}
				else
				{
					npc.FireArrow(vecTarget, ExodiaRandomizedDamage, 1400.0, _, 1.0);
				}
				Exodia_Hits[npc.index]++;
				//FireBullet(npc.index, npc.m_iWearable1, WorldSpaceCenter(npc.index), vecDir, 50.0, 9500.0, DMG_BULLET, "bullet_tracer01_red");
				npc.PlayRangedSound();
			}
		}
		if(npc.m_flNextRangedAttack < GetGameTime(npc.index) && flDistanceToTarget < 1425000 && npc.m_flReloadDelay < GetGameTime(npc.index) && Pellet_Gun[npc.index])
		{//Pellet
			int target;
			
			target = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
			if(!IsValidEnemy(npc.index, target))
			{
				npc.StartPathing();
			}
			else
			{
				vecTarget = PredictSubjectPositionForProjectiles(npc, PrimaryThreatIndex, 1400.0);
				//NPC_StopPathing(npc.index);
				//npc.m_bPathing = false;
				npc.FaceTowards(vecTarget, 10000.0);
				npc.m_flNextRangedAttack = GetGameTime(npc.index) + 0.4;
				//npc.m_iAttacksTillReload -= 1;
				
				float vecSpread = 0.1;
				
				float eyePitch[3];
				GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
				
				float x, y;
				x = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
				y = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
				
				float vecDirShooting[3], vecRight[3], vecUp[3];
				
				vecTarget[2] += 15.0;
				MakeVectorFromPoints(WorldSpaceCenter(npc.index), vecTarget, vecDirShooting);
				GetVectorAngles(vecDirShooting, vecDirShooting);
				vecDirShooting[1] = eyePitch[1];
				GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
				
				if(npc.m_iAttacksTillReload == 0)
				{
					npc.AddGesture("ACT_MP_RELOAD_STAND_SECONDARY");
					npc.m_flReloadDelay = GetGameTime(npc.index) + 1.0;
					npc.m_iAttacksTillReload = 500;
					npc.PlayRangedReloadSound();
					//npc.AddGesture("ACT_MP_DEPLOYED_IDLE_ITEM");
				}
				
				npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY");
				float vecDir[3];
				vecDir[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
				vecDir[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
				vecDir[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
				NormalizeVector(vecDir, vecDir);
				
				if(ExperimentalGear_On[npc.index])
				{
					npc.FireArrow(vecTarget, PelletGun_Damage + ExperimentalGearDamage[npc.index], 1400.0, _, 1.0);
				}
				else
				{
					npc.FireArrow(vecTarget, PelletGun_Damage, 1400.0, _, 1.0);
				}
				
				//FireBullet(npc.index, npc.m_iWearable1, WorldSpaceCenter(npc.index), vecDir, 50.0, 9500.0, DMG_BULLET, "bullet_tracer01_red");
				npc.PlayRangedTwoSound();
			}
		}
		if(npc.m_flNextRangedAttack < GetGameTime(npc.index) && flDistanceToTarget < 1425000 && npc.m_flReloadDelay < GetGameTime(npc.index) && WeakMachineGun_Smg[npc.index])
		{//Machine
			int target;
			
			target = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
			if(!IsValidEnemy(npc.index, target))
			{
				npc.StartPathing();
			}
			else
			{
				vecTarget = PredictSubjectPositionForProjectiles(npc, PrimaryThreatIndex, 1400.0);
				//NPC_StopPathing(npc.index);
				//npc.m_bPathing = false;
				npc.FaceTowards(vecTarget, 10000.0);
				npc.m_flNextRangedAttack = GetGameTime(npc.index) + 0.05;
				//npc.m_iAttacksTillReload -= 1;
				
				float vecSpread = 0.1;
				
				float eyePitch[3];
				GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
				
				float x, y;
				x = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
				y = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
				
				float vecDirShooting[3], vecRight[3], vecUp[3];
				
				vecTarget[2] += 15.0;
				MakeVectorFromPoints(WorldSpaceCenter(npc.index), vecTarget, vecDirShooting);
				GetVectorAngles(vecDirShooting, vecDirShooting);
				vecDirShooting[1] = eyePitch[1];
				GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
				
				if(npc.m_iAttacksTillReload == 0)
				{
					npc.AddGesture("ACT_MP_RELOAD_STAND_SECONDARY");
					npc.m_flReloadDelay = GetGameTime(npc.index) + 1.0;
					npc.m_iAttacksTillReload = 500;
					npc.PlayRangedReloadSound();
				}
				
				npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY");
				float vecDir[3];
				vecDir[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
				vecDir[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
				vecDir[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
				NormalizeVector(vecDir, vecDir);
				
				if(ExperimentalGear_On[npc.index])
				{
					npc.FireArrow(vecTarget, WeakMachineGun_Smg_Damage + ExperimentalGearDamage[npc.index], 1400.0, _, 1.0);
				}
				else
				{
					npc.FireArrow(vecTarget, WeakMachineGun_Smg_Damage, 1400.0, _, 1.0);
				}
				
				//FireBullet(npc.index, npc.m_iWearable1, WorldSpaceCenter(npc.index), vecDir, 50.0, 9500.0, DMG_BULLET, "bullet_tracer01_red");
				npc.PlayRangedThirdSound();
			}
		}
		/*if(npc.m_flNextRangedAttack < GetGameTime(npc.index) && flDistanceToTarget < 1425000 && npc.m_flReloadDelay < GetGameTime(npc.index) && TheHolyOrb[npc.index])
		{//Orb
			int target;
			
			target = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
			if(!IsValidEnemy(npc.index, target))
			{
				npc.StartPathing();
			}
			else
			{
				vecTarget = PredictSubjectPositionForProjectiles(npc, PrimaryThreatIndex, 1400.0);
				//NPC_StopPathing(npc.index);
				//npc.m_bPathing = false;
				npc.FaceTowards(vecTarget, 10000.0);
				npc.m_flNextRangedAttack = GetGameTime(npc.index) + 2.0;
				//npc.m_iAttacksTillReload -= 1;
				
				float vecSpread = 0.1;
				
				float eyePitch[3];
				GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
				
				float x, y;
				x = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
				y = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
				
				float vecDirShooting[3], vecRight[3], vecUp[3];
				
				vecTarget[2] += 15.0;
				MakeVectorFromPoints(WorldSpaceCenter(npc.index), vecTarget, vecDirShooting);
				GetVectorAngles(vecDirShooting, vecDirShooting);
				vecDirShooting[1] = eyePitch[1];
				GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
				
				if(npc.m_iAttacksTillReload == 0)
				{
					npc.AddGesture("ACT_MP_RELOAD_STAND_SECONDARY");
					npc.m_flReloadDelay = GetGameTime(npc.index) + 1.0;
					npc.m_iAttacksTillReload = 500;
					//npc.PlayRangedReloadSound();
					//npc.AddGesture("ACT_MP_DEPLOYED_IDLE_ITEM");
				}
				
				npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY");
				float vecDir[3];
				vecDir[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
				vecDir[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
				vecDir[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
				NormalizeVector(vecDir, vecDir);
				
				float speed = 700.0;
		
				int iRot = CreateEntityByName("func_door_rotating");
				if(iRot == -1) return;
	
				DispatchKeyValueVector(iRot, "origin", eyePitch);
				DispatchKeyValue(iRot, "distance", "99999");
				DispatchKeyValueFloat(iRot, "speed", speed);
				DispatchKeyValue(iRot, "spawnflags", "12288"); // passable|silent
				DispatchSpawn(iRot);
				SetEntityCollisionGroup(iRot, 27);
	
				SetVariantString("!activator");
				AcceptEntityInput(iRot, "Open");
				EmitSoundToAll(SOUND_WAND_SHOT, npc.index, _, 65, _, 0.45);
		
				float damage = 50.0;
				
				if(ExperimentalGear_On[npc.index])
				{
					Orb_Launched(npc.index, iRot, speed, 5.0, damage + ExperimentalGearDamage[npc.index]);
				}
				else
				{
					Orb_Launched(npc.index, iRot, speed, 5.0, damage);
				}
				
				//FireBullet(npc.index, npc.m_iWearable1, WorldSpaceCenter(npc.index), vecDir, 50.0, 9500.0, DMG_BULLET, "bullet_tracer01_red");
				//npc.PlayRangedSound();
			}
		}*/
		if(flDistanceToTarget > 142500 || flDistanceToTarget < 142500)
		{
			npc.StartPathing();
		}
		if(flDistanceToTarget < 13000 && !Archers_Anhilation[npc.index] && !Exodia_TheFuckYouGun[npc.index] && !Pellet_Gun[npc.index] && !WeakMachineGun_Smg[npc.index] || npc.m_flAttackHappenswillhappen && !Archers_Anhilation[npc.index] && !Exodia_TheFuckYouGun[npc.index] && !Pellet_Gun[npc.index] && !WeakMachineGun_Smg[npc.index])
		{
			//Look at target so we hit.
			//npc.FaceTowards(vecTarget, 1000.0);
			//Can we attack right now?
			if(npc.m_flNextMeleeAttack < GetGameTime(npc.index))
			{
				//Play attack ani
				if (!npc.m_flAttackHappenswillhappen)
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
					npc.PlayMeleeSound();
					npc.m_flAttackHappens = GetGameTime(npc.index)+0.2;
					npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.34;
					npc.m_flAttackHappenswillhappen = true;
				}
				if (npc.m_flAttackHappens < GetGameTime(npc.index) && npc.m_flAttackHappens_bullshit >= GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					Handle swingTrace;
					npc.FaceTowards(vecTarget, 20000.0);
					if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex))
					{
						int target = TR_GetEntityIndex(swingTrace);	
						
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);
						
						if(target > 0) 
						{
							if(target <= MaxClients)
							{
								if(ExperimentalGear_On[npc.index] && !Jawbreaker_On[npc.index])
								{
									SDKHooks_TakeDamage(target, npc.index, npc.index, DefaultDamage + ExperimentalGearDamage[npc.index], DMG_CLUB, -1, _, vecHit);
									GamblersCash[npc.index] += CashGain_OnHit;
								}
								else if(!ExperimentalGear_On[npc.index] && Jawbreaker_On[npc.index])
								{
									SDKHooks_TakeDamage(target, npc.index, npc.index, Jawbreaker_Damage, DMG_CLUB, -1, _, vecHit);
									Jawbreaker_Hits[npc.index]++;
									cvarTimeScale.SetFloat(0.3);
									CreateTimer(0.5, SetTimeBack);
									GamblersCash[npc.index] += Jawbreaker_Cashgain_OnHit;
								}
								else if(ExperimentalGear_On[npc.index] && Jawbreaker_On[npc.index])
								{
									SDKHooks_TakeDamage(target, npc.index, npc.index, Jawbreaker_Damage + ExperimentalGearDamage[npc.index], DMG_CLUB, -1, _, vecHit);
									Jawbreaker_Hits[npc.index]++;
									for(int i=1; i<=MaxClients; i++)
									{
										if(IsClientInGame(i) && !IsFakeClient(i))
										{
											SendConVarValue(i, sv_cheats, "1");
										}
									}
									cvarTimeScale.SetFloat(0.3);
									CreateTimer(0.5, SetTimeBack);
									GamblersCash[npc.index] += Jawbreaker_Cashgain_OnHit;
								}
								else
								{
									SDKHooks_TakeDamage(target, npc.index, npc.index, DefaultDamage, DMG_CLUB, -1, _, vecHit);
									GamblersCash[npc.index] += CashGain_OnHit;
								}
							}
							else
							{
								if(ExperimentalGear_On[npc.index] && !Jawbreaker_On[npc.index])
								{
									SDKHooks_TakeDamage(target, npc.index, npc.index, DefaultNpcBuildingDamage + ExperimentalGearDamage[npc.index], DMG_CLUB, -1, _, vecHit);
								}
								else if(!ExperimentalGear_On[npc.index] && Jawbreaker_On[npc.index])//no ally npc's should survive it either >:(
								{
									SDKHooks_TakeDamage(target, npc.index, npc.index, Jawbreaker_DamageNpcBuilding, DMG_CLUB, -1, _, vecHit);
								}
								else if(ExperimentalGear_On[npc.index] && Jawbreaker_On[npc.index])
								{
									SDKHooks_TakeDamage(target, npc.index, npc.index, Jawbreaker_DamageNpcBuilding + ExperimentalGearDamage[npc.index], DMG_CLUB, -1, _, vecHit);
								}
								else
								{
									SDKHooks_TakeDamage(target, npc.index, npc.index, DefaultNpcBuildingDamage, DMG_CLUB, -1, _, vecHit);
								}
							}
							// Hit sound
							if(Jawbreaker_On[npc.index])
							{
								npc.PlayMeleeHitSoundJawbreaker();
							}
							else
							{
								npc.PlayMeleeHitSound();
							}
						} 
					}
					delete swingTrace;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.26;
					npc.m_flAttackHappenswillhappen = false;
				}
				else if(npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					npc.m_flAttackHappenswillhappen = false;
					
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.26;
				}
			}
		}
	}
	else
	{
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action TheGambler_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	TheGambler npc = view_as<TheGambler>(victim);
	
	if(npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void TheGambler_NPCDeath(int entity)
{
	TheGambler npc = view_as<TheGambler>(entity);
	/*if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}*/
	npc.PlayDeathSound();
	if(!b_IsAlliedNpc[npc.index])
	{
		RaidBossActive = INVALID_ENT_REFERENCE;
	}
	
	
	SDKUnhook(npc.index, SDKHook_Think, TheGambler_ClotThink);		
	
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
	//if(IsValidEntity(npc.m_iWearable7))
	//	RemoveEntity(npc.m_iWearable7);
}
//couldn't get this to work :(, anyway needs a 7th slot to even use it lol which we don't have
/*
static void Orb_Launched(int iNPC, int iRot, float speed, float time, float damage)
{
	TheGambler npc = view_as<TheGambler>(iNPC);
	float fAng[3], fPos[3];
	//GetClientEyeAngles(npc.index, fAng);
	//GetClientEyePosition(npc.index, fPos);
	GetEntPropVector(npc.index, Prop_Data, "m_angRotation", fAng);
	GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", fPos);

	int iCarrier = CreateEntityByName("prop_physics_override");
	if(iCarrier == -1) return;

	float fVel[3], fBuf[3];
	GetAngleVectors(fAng, fBuf, NULL_VECTOR, NULL_VECTOR);
	fVel[0] = fBuf[0]*speed;
	fVel[1] = fBuf[1]*speed;
	fVel[2] = fBuf[2]*speed;

	SetEntPropEnt(iCarrier, Prop_Send, "m_hOwnerEntity", npc.index);
	DispatchKeyValue(iCarrier, "model", ENERGY_BALL_MODEL);
	DispatchKeyValue(iCarrier, "modelscale", "0");
	DispatchSpawn(iCarrier);

	TeleportEntity(iCarrier, fPos, NULL_VECTOR, fVel);
	SetEntityMoveType(iCarrier, MOVETYPE_FLY);
	
	SetEntProp(iCarrier, Prop_Send, "m_iTeamNum", npc.index);
	SetEntProp(iRot, Prop_Send, "m_iTeamNum", npc.index);
	//RequestFrame(See_Projectile_Team, EntIndexToEntRef(iCarrier));
	//RequestFrame(See_Projectile_Team, EntIndexToEntRef(iRot));
	
	SetVariantString("!activator");
	AcceptEntityInput(iRot, "SetParent", iCarrier, iRot, 0);
	SetEntityCollisionGroup(iCarrier, 27);
	
	Orb_Damage_Projectile[npc.index] = damage;
	
	float position[3];
	
	GetEntPropVector(iCarrier, Prop_Data, "m_vecAbsOrigin", position);
	
	int particle = 0;
	
	particle = ParticleEffectAt(position, "drg_cow_rockettrail_normal", 5.0);
	
	//drg_cowmangler_trail_charged cool black wave
	
	float Angles[3];
	GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", Angles);
	TeleportEntity(particle, NULL_VECTOR, Angles, NULL_VECTOR);
	TeleportEntity(iCarrier, NULL_VECTOR, Angles, NULL_VECTOR);
	TeleportEntity(iRot, NULL_VECTOR, Angles, NULL_VECTOR);	
	SetParent(iCarrier, particle);	
	
	Orb_Projectile_To_Particle[npc.index] = EntIndexToEntRef(particle);
	
	SetEntityRenderMode(iCarrier, RENDER_TRANSCOLOR);
	SetEntityRenderColor(iCarrier, 255, 255, 255, 0);
	SetEntProp(iCarrier, Prop_Send, "m_usSolidFlags", 200);
	SetEntProp(iCarrier, Prop_Data, "m_nSolidType", 0);
	SetEntityCollisionGroup(iCarrier, 0);
	
	Orb_Damage_Tornado[npc.index] = damage;
	CreateTimer(0.2, Gambler_Timer_Electric_Think, iCarrier, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
	DataPack pack;
	CreateDataTimer(time, Timer_RemoveEntity_CustomProjectile, pack, TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(EntIndexToEntRef(iCarrier));
	pack.WriteCell(EntIndexToEntRef(particle));
	pack.WriteCell(EntIndexToEntRef(iRot));
	
	SDKHook(iCarrier, SDKHook_StartTouch, Gambler_Orb_IEM_OnHatTouch);
}

public Action Gambler_Orb_IEM_OnHatTouch(int entity, int client)
{
	int target = GetClientOfUserId(client);
	int iNPC;
	TheGambler npc = view_as<TheGambler>(iNPC);
	if(target > 0)	
	{
		//Code to do damage position and ragdolls
		static float angles[3];
		GetEntPropVector(npc.index, Prop_Send, "m_angRotation", angles);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		static float Entity_Position[3];
		Entity_Position = WorldSpaceCenter(target);
		//Code to do damage position and ragdolls
		
		SDKHooks_TakeDamage(client, npc.index, npc.index, Orb_Damage_Projectile[npc.index], DMG_PLASMA, -1, CalculateDamageForce(vecForward, 10000.0), Entity_Position, _ , ZR_DAMAGE_LASER_NO_BLAST);	// 2048 is DMG_NOGIB?
	}
	else if(target == 1)
	{
		int particle = EntRefToEntIndex(Orb_Projectile_To_Particle[npc.index]);
		if(IsValidEntity(particle) && particle != 0)
		{
			EmitSoundToAll(SOUND_ZAP, entity, SNDCHAN_STATIC, 70, _, 0.9);
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
	return Plugin_Handled;
}

public Action Gambler_Timer_Electric_Think(Handle timer, int iCarrier)
{
	int iNPC;
	TheGambler npc = view_as<TheGambler>(iNPC);
	//int entity = EntRefToEntIndex(npc.index);
	int client = Orb_Projectile_To_Client[npc.index];
	int particle = Orb_Projectile_To_Particle[npc.index];
	
	if(!IsValidEdict(iCarrier) || client<=MaxClients)
	{
		if(IsValidEdict(particle) && particle>MaxClients)
		{
			RemoveEntity(particle);
		}
		
		if(IsValidEdict(iCarrier) && client>MaxClients)
		{
			RemoveEntity(iCarrier);
		}
		
		KillTimer(timer);
		return Plugin_Stop;
	}
	
	if(!IsValidClient(client))
	{
		if(IsValidEdict(particle) && particle>MaxClients)
		{
			RemoveEntity(particle);
		}
		
		if(IsValidEdict(iCarrier) && iCarrier>MaxClients)
		{
			RemoveEntity(iCarrier);
		}
		
		KillTimer(timer);
		return Plugin_Stop;
	}
	
	float flCarrierPos[3], targPos[3];
	GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", flCarrierPos);
	
	Orb_Damage_Reduction[npc.index] = 1.0;
	
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsValidClient(i))
		{
			targPos = WorldSpaceCenter(i);
			if(GetVectorDistance(flCarrierPos, targPos) <= Orb_Radius[npc.index])
			{
				//Code to do damage position and ragdolls
				float angles[3];
				GetEntPropVector(npc.index, Prop_Data, "m_angRotation", angles);
				float vecForward[3];
				GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
				
				float distance_1 = GetVectorDistance(flCarrierPos, targPos);
				float damage_1 = Custom_Explosive_Logic(npc.index, distance_1, 0.75, Orb_Damage_Tornado[npc.index], Orb_Radius[npc.index]+1.0);				
				damage_1 /= Orb_Damage_Reduction[npc.index];
				
				SDKHooks_TakeDamage(i, npc.index, npc.index, damage_1, DMG_PLASMA, -1, CalculateDamageForce(vecForward, 10000.0), targPos);
				int r = 255;
				int g = 125;
				int b = 125;
				float diameter = 15.0;
				
				int colorLayer4[4];
				SetColorRGBA(colorLayer4, r, g, b, 60);
				int colorLayer3[4];
				SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, 60);
				int colorLayer2[4];
				SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, 60);
				int colorLayer1[4];
				SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, 60);
				TE_SetupBeamPoints(flCarrierPos, targPos, Gambler_Beam_laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 1.0, colorLayer1, 3);
				TE_SendToAll(0.0);
				TE_SetupBeamPoints(flCarrierPos, targPos, Gambler_Beam_laser, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 0.5 * 1.28), ClampBeamWidth(diameter * 0.5 * 1.28), 0, 1.0, colorLayer2, 3);
				TE_SendToAll(0.0);
				TE_SetupBeamPoints(flCarrierPos, targPos, Gambler_Beam_laser, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 0.8 * 1.28), ClampBeamWidth(diameter * 0.8 * 1.28), 0, 1.0, colorLayer3, 3);
				TE_SendToAll(0.0);
				TE_SetupBeamPoints(flCarrierPos, targPos, Gambler_Beam_laser, 0, 0, 0, 0.33, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 1.0, colorLayer4, 3);
				int glowColor[4];
				SetColorRGBA(glowColor, r, g, b, 200);
				TE_SetupBeamPoints(flCarrierPos, targPos, Gambler_Beam_Glow, 0, 0, 0, 0.33, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 5.0, glowColor, 0);
				TE_SendToAll(0.0);
				
				Orb_Damage_Reduction[npc.index] *= EXPLOSION_AOE_DAMAGE_FALLOFF;
				//use blast cus it does its own calculations for that ahahahah im evil (you scare me sometime man)
			}
		}
	}
	
	return Plugin_Continue;
}*/