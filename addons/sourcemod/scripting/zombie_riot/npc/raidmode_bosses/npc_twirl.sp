#pragma semicolon 1
#pragma newdecls required



static const char g_IdleSounds[][] = {
	"vo/medic_standonthepoint01.mp3",
	"vo/medic_standonthepoint02.mp3",
	"vo/medic_standonthepoint03.mp3",
	"vo/medic_standonthepoint04.mp3",
	"vo/medic_standonthepoint05.mp3"
};

static const char g_IdleAlertedSounds[][] = {
	"vo/medic_battlecry01.mp3",
	"vo/medic_battlecry02.mp3",
	"vo/medic_battlecry03.mp3",
	"vo/medic_battlecry04.mp3",
	"vo/medic_battlecry05.mp3",
	"vo/medic_item_secop_domination01.mp3",
	"vo/medic_item_secop_idle03.mp3",
	"vo/medic_item_secop_idle01.mp3",
	"vo/medic_item_secop_idle02.mp3"
};

static const char g_MeleeHitSounds[][] = {
	"weapons/batsaber_hit_flesh1.wav",
	"weapons/batsaber_hit_flesh2.wav",
	"weapons/batsaber_hit_world1.wav",
	"weapons/batsaber_hit_world2.wav"
};
static const char g_MeleeAttackSounds[][] = {
	"weapons/batsaber_swing1.wav",
	"weapons/batsaber_swing2.wav",
	"weapons/batsaber_swing3.wav"
};

static const char g_RangeAttackSounds[][] = {
	"ui/hitsound_vortex1.wav",
	"ui/hitsound_vortex2.wav",
	"ui/hitsound_vortex3.wav",
	"ui/hitsound_vortex4.wav",
	"ui/hitsound_vortex5.wav"
};
static char g_TeleportSounds[][] = {
	"weapons/bison_main_shot.wav"
};
static const char g_AngerSounds[][] = {
	"vo/medic_mvm_get_upgrade01.mp3",
	"vo/medic_mvm_get_upgrade02.mp3",
	"vo/medic_mvm_get_upgrade03.mp3",
	"vo/medic_hat_taunts01.mp3",
	"vo/medic_hat_taunts04.mp3",
	"vo/medic_item_secop_round_start05.mp3",
	"vo/medic_item_secop_round_start07.mp3",
	"vo/medic_item_secop_kill_assist01.mp3"
};
static const char g_LaserComboSound[][] = {
	"zombiesurvival/seaborn/loop_laser.mp3",
};
static const char g_FractalSound[][] = {
	"weapons/capper_shoot.wav"
};

static int i_lunar_entities[MAXENTITIES][3];

#define TWIRL_TE_DURATION 0.1
//#define RAIDBOSS_TWIRL_THEME "#zombiesurvival/ruina/ruler_of_ruina_decends.mp3", now used for wave 15, deivid cant decide 
#define RAIDBOSS_TWIRL_THEME "#zombiesurvival/ruina/twirl_theme_new.mp3"
static float fl_player_weapon_score[MAXPLAYERS];
static float fl_next_textline;
static float fl_raidmode_freeze;
static float fl_npc_basespeed;

static bool b_tripple_raid;
static bool b_force_transformation;
static bool b_lastman;
static bool b_wonviatimer;
static bool b_wonviakill;
static bool b_allow_final;
static bool b_allow_final_invocation;
static bool b_test_mode;

static int i_current_Text;

static char gGlow1;	//blue
#define TWIRL_THUMP_SOUND				"ambient/machines/thumper_hit.wav"
#define TWIRL_COSMIC_GAZE_LOOP_SOUND1 	"weapons/physcannon/energy_sing_loop4.wav"
#define TWIRL_LASER_SOUND 				"zombiesurvival/seaborn/loop_laser.mp3"
#define TWIRL_COSMIC_GAZE_END_SOUND1 	"weapons/physcannon/physcannon_drop.wav"
#define TWIRL_COSMIC_GAZE_END_SOUND2 	"ambient/energy/whiteflash.wav"

#define TWIRL_IONIC_FRACTURE_EXPLOSION		"misc/halloween/spell_mirv_explode_primary.wav"
#define TWIRL_IONIC_FRACTURE_PASSIVE_SOUND 	"ambient/machines/thumper_amb.wav"
#define TWIRL_IONIC_FRACTURE_PASSIVE_SOUND2 "npc/combine_gunship/dropship_engine_near_loop1.wav"
#define TWIRL_IONIC_FRACTURE_PASSIVE_SOUND3	"ambient/alarms/combine_bank_alarm_loop4.wav"
#define TWIRL_IONIC_FRACTURE_INIT_SOUND		"weapons/cguard/charging.wav"


#define TWIRL_MAGIA_OVERFLOW_DURATION 8.0

static bool PrecacheTwirl;
void Twirl_OnMapStart_NPC()
{
	PrecacheTwirl = false;
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Twirl");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_ruina_twirl");
	data.Category = Type_Raid;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	strcopy(data.Icon, sizeof(data.Icon), "twirl"); 						//leaderboard_class_(insert the name)
	data.IconCustom = true;												//download needed?
	data.Flags = 0;						//example: MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;, forces these flags.	
	NPC_Add(data);
}

void PrecacheTwirlMusic()
{
	if(PrecacheTwirl)
		return;

	PrecacheTwirl = true;
	PrecacheSoundCustom(RAIDBOSS_TWIRL_THEME);
}
static void ClotPrecache()
{
	gGlow1 = PrecacheModel("sprites/blueglow2.vmt", true);
	PrecacheSound(TWIRL_IONIC_FRACTURE_EXPLOSION, true);
	PrecacheSound(TWIRL_IONIC_FRACTURE_PASSIVE_SOUND, true);
	PrecacheSound(TWIRL_IONIC_FRACTURE_PASSIVE_SOUND2, true);
	PrecacheSound(TWIRL_IONIC_FRACTURE_PASSIVE_SOUND3, true);
	PrecacheSound(TWIRL_IONIC_FRACTURE_INIT_SOUND, true);
	PrecacheSoundArray(g_DefaultMedic_DeathSounds);
	PrecacheSoundArray(g_DefaultMedic_HurtSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_RangeAttackSounds);
	PrecacheSoundArray(g_TeleportSounds);
	PrecacheSoundArray(g_DefaultLaserLaunchSound);
	PrecacheSoundArray(g_FractalSound);
	PrecacheSound(TWIRL_THUMP_SOUND, true);
	PrecacheSound(TWIRL_COSMIC_GAZE_LOOP_SOUND1, true);
	PrecacheSound(TWIRL_COSMIC_GAZE_END_SOUND1, true);
	PrecacheSound(TWIRL_COSMIC_GAZE_END_SOUND2, true);
	PrecacheTwirlMusic();

	PrecacheSound(NPC_PARTICLE_LANCE_BOOM);
	PrecacheSound(NPC_PARTICLE_LANCE_BOOM1);
	PrecacheSound(NPC_PARTICLE_LANCE_BOOM2);
	PrecacheSound(NPC_PARTICLE_LANCE_BOOM3);

	PrecacheSound("player/taunt_surgeons_squeezebox_draw_accordion.wav");
	PrecacheSound("player/taunt_surgeons_squeezebox_music.wav");
	PrecacheSound("ui/rd_2base_alarm.wav");
	PrecacheSound("npc/attack_helicopter/aheli_charge_up.wav");

	PrecacheSound("mvm/mvm_tele_deliver.wav");

	PrecacheModel("models/player/medic.mdl");
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Twirl(vecPos, vecAng, team, data);
}

static const char NameColour[] = "{purple}";
static const char TextColour[] = "{snow}";

/*
	The notepad:

	fl_ruina_battery_timeout[npc.index]	//used for abilities that DON'T want to overlap, eg: Laser combo. Retreat Laser. Cosmic Gaze
	Things to do:

	sound effects for launcing a fractal
*/

methodmap Twirl < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	public void PlayTeleportSound() {
		EmitSoundToAll(g_TeleportSounds[GetRandomInt(0, sizeof(g_TeleportSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME);
	}
	public void PlayFractalSound() {
		EmitSoundToAll(g_FractalSound[GetRandomInt(0, sizeof(g_FractalSound) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME);
	}
	property bool m_bInKame
	{
		public get()							{ return b_InKame[this.index]; }
		public set(bool TempValueForProperty) 	{ b_InKame[this.index] = TempValueForProperty; }
	}
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		EmitSoundToAll(g_DefaultMedic_HurtSounds[GetRandomInt(0, sizeof(g_DefaultMedic_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);	
	}
	public void PlayDeathSound() {
		EmitSoundToAll(g_DefaultMedic_DeathSounds[GetRandomInt(0, sizeof(g_DefaultMedic_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
	}
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
	}
	public void PlayRangeAttackSound() {
		EmitSoundToAll(g_RangeAttackSounds[GetRandomInt(0, sizeof(g_RangeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
	}
	public void PlayAngerSound() {
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
	}
	public void PlayMagiaOverflowSound() {
		if(fl_nightmare_cannon_core_sound_timer[this.index] > GetGameTime())
			return;
		EmitCustomToAll(g_LaserComboSound[GetRandomInt(0, sizeof(g_LaserComboSound) - 1)], _, _, SNDLEVEL_RAIDSIREN, _, RAIDBOSSBOSS_ZOMBIE_VOLUME);
		fl_nightmare_cannon_core_sound_timer[this.index] = GetGameTime() + 2.25;
	}
	public void Predictive_Ion(int Target, float Time, float Radius, float dmg)
	{
		float Predicted_Pos[3],
		SubjectAbsVelocity[3];
		float vecTarget[3];
		WorldSpaceCenter(Target, vecTarget);
		GetEntPropVector(Target, Prop_Data, "m_vecAbsVelocity", SubjectAbsVelocity);

		ScaleVector(SubjectAbsVelocity, Time);
		AddVectors(vecTarget, SubjectAbsVelocity, Predicted_Pos);

		Ruina_Proper_To_Groud_Clip({24.0,24.0,24.0}, 300.0, Predicted_Pos);

		this.Ion_On_Loc(Predicted_Pos, Radius, dmg, Time);
		
	}
	public void Ion_On_Loc(float Predicted_Pos[3], float Radius, float dmg, float Time)
	{
		int color[4]; 
		Ruina_Color(color, i_current_wave[this.index]);

		float Thickness = 6.0;
		TE_SetupBeamRingPoint(Predicted_Pos, Radius*2.0, 0.0, g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, Time, Thickness, 0.75, color, 1, 0);
		TE_SendToAll();
		TE_SetupBeamRingPoint(Predicted_Pos, Radius*2.0, Radius*2.0+0.5, g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, Time, Thickness, 0.1, color, 1, 0);
		TE_SendToAll();

		Ruina_IonSoundInvoke(Predicted_Pos);
		
		DataPack pack;
		CreateDataTimer(Time, Ruina_Generic_Ion, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(EntIndexToEntRef(this.index));
		pack.WriteFloatArray(Predicted_Pos, sizeof(Predicted_Pos));
		pack.WriteCellArray(color, sizeof(color));
		pack.WriteFloat(Radius);
		pack.WriteFloat(dmg);
		pack.WriteFloat(0.25);			//Sickness %
		pack.WriteCell(100);			//Sickness flat
		pack.WriteCell(this.Anger);		//Override sickness timeout

		float Sky_Loc[3]; Sky_Loc = Predicted_Pos; Sky_Loc[2]+=500.0; Predicted_Pos[2]-=100.0;

		int laser;
		laser = ConnectWithBeam(-1, -1, color[0], color[1], color[2], 4.0, 4.0, 5.0, BEAM_COMBINE_BLACK, Predicted_Pos, Sky_Loc);

		CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);
		int loop_for = 5;
		float Add_Height = 500.0/loop_for;
		for(int i=0 ; i < loop_for ; i++)
		{
			Predicted_Pos[2]+=Add_Height;
			TE_SetupBeamRingPoint(Predicted_Pos, (Radius*2.0)/(i+1), 0.0, g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, Time, Thickness, 0.75, color, 1, 0);
			TE_SendToAll();
		}
		
	}
	public bool Add_Combo(int amt)
	{
		bool fired = false;
		if(this.m_iMeleeCombo>amt)
		{
			this.m_iMeleeCombo = 0;
			fired = true;
		}
		else
		{
			this.m_iMeleeCombo++;
		}
		if(this.m_iMeleeCombo>=amt)
		{
			if(!IsValidEntity(EntRefToEntIndex(this.m_iHandParticle)))
			{
				float flPos[3], flAng[3];
				this.GetAttachment("effect_hand_r", flPos, flAng);
				this.m_iHandParticle = EntIndexToEntRef(ParticleEffectAt_Parent(flPos, "raygun_projectile_blue_crit", this.index, "effect_hand_r", {0.0,0.0,0.0}));
			}
		}
		else
		{
			int ent = EntRefToEntIndex(this.m_iHandParticle);
			if(IsValidEntity(ent))
			{
				RemoveEntity(ent);
				this.m_iHandParticle = INVALID_ENT_REFERENCE;
			}
				
		}
		return fired;

	}
	public void Handle_Weapon()
	{
		switch(this.i_stance_status())
		{
			case -1:
			{
				//CPrintToChatAll("Invalid target");
				return;
			}
			case 0:	//melee
			{
				if(this.m_fbGunout)
				{
					this.m_fbGunout = false;
					/*if(this.m_flNextMeleeAttack > GetGameTime(this.index) + 0.5)
					{
						//CPrintToChatAll("Reset CD MELEE");
						this.m_flNextMeleeAttack = GetGameTime(this.index) + 0.5;
					}*/
						
					SetVariantInt(this.i_weapon_type());
					AcceptEntityInput(this.m_iWearable1, "SetBodyGroup");
					//CPrintToChatAll("Melee enemy");
				}
				
			}
			default:	//ranged/undecided
			{
				if(!this.m_fbGunout)
				{
					this.m_iState = 0;

					/*if(this.m_flReloadIn > GetGameTime(this.index) + 0.5)
					{
						this.m_flReloadIn = GetGameTime(this.index) + 0.5;
						//CPrintToChatAll("Reset CD RANGED");
					}*/
						

					this.m_fbGunout = true;
					//CPrintToChatAll("Ranged enemy");
					SetVariantInt(this.i_weapon_type());
					AcceptEntityInput(this.m_iWearable1, "SetBodyGroup");
				}
				
			}

		}
	}
	public int i_stance_status()
	{
		//Enemy npc's will always be conisdered "ranged"
		int type = this.PlayerType();
		float GameTime = GetGameTime(this.index);

		//We recently retreated, so lets use ranged attacks
		if(this.m_flForceRanged > GameTime)
			type = 1;

		//the player is a "ranged" player, now do 1 extra check!
		if(type == 1)
		{	
			//we are still reloading, switch to melee. add a 1s buffer.
			if(this.m_flReloadIn > (GameTime + 1.0))
				type = 0;	//melee

			return type;
		}
		//now what's left is what we think is a melee player!
		
		float vecTarget[3]; WorldSpaceCenter(this.m_iTarget, vecTarget);
		
		float VecSelfNpc[3]; WorldSpaceCenter(this.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);

		//do a range check, if the melee player is 50 miles away, use a ranged attack.
		if(flDistanceToTarget > (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 7.5))	
			type = 1;	//ranged
		else
			type = 0;	//melee

		//if the decided stance was ranged, BUT we are still reloading, go back to a melee stance.
		if(this.m_flReloadIn > (GameTime + 1.0))
			type = 0;	//melee

		return type;

	}
	public int i_weapon_type()
	{
		int wave = i_current_wave[this.index];

		if(this.m_fbGunout)	//ranged
		{
			if(wave<=10)	
			{
				return RUINA_TWIRL_CREST_1;
			}
			else if(wave <=20)	
			{
				return RUINA_TWIRL_CREST_2;
			}
			else if(wave <= 30)	
			{
				return RUINA_TWIRL_CREST_3;
			}
			else
			{
				return RUINA_TWIRL_CREST_4;
			}
		}
		else				//melee
		{
			if(wave<=10)	
			{
				return RUINA_TWIRL_MELEE_1;
			}
			else if(wave <=20)	
			{
				return RUINA_TWIRL_MELEE_2;
			}
			else if(wave <= 30)	
			{
				return RUINA_TWIRL_MELEE_3;
			}
			else
			{
				return RUINA_TWIRL_MELEE_4;
			}
		}
	}
	public int PlayerType()
	{
		if(!IsValidEnemy(this.index, this.m_iTarget))
			return -1;

		if(this.m_iTarget > MaxClients)
			return 1;						//its an npc? fuck em

		if(fl_player_weapon_score[this.m_iTarget]>=0.0)
			return 0;	//their social credit score is positive or 0.0, they are a good citizen of the state, treat them well by not shoting them on sight.
		else
			return 1;	//their soclai credit score is not positive, ON SIGHT, KILL ON SIGHT.
		
		/*
		int weapon = GetEntPropEnt(this.m_iTarget, Prop_Send, "m_hActiveWeapon");

		if(!IsValidEntity(weapon))
			return 1;						//someohw invalid weapon, asume its a ranged player.
		
		if(i_IsWandWeapon[weapon])
			return 1;						//the weapon they are holding a wand, so its a ranged player	
			//fun fact: due to the lance being classed as a magic weapon, the lance player gets blasted by twirl.
			//However, due to how STRONG the lance is single target, thats fine.

		if(i_IsWrench[weapon])
			return 1;						//engie player shall be burned.
											//in essence, I don't want "engineer" players to act as distractions, when what I want is the melee players who actually HAVE to get close to deal damage to be the ones who are "honoured"

		char classname[32];
		GetEntityClassname(weapon, classname, 32);

		int weapon_slot = TF2_GetClassnameSlot(classname);

		//weapons like angelica are technically a "primary" but they are melee, doing this will make sure that such melee weapons that use special slots don't get shot dead on the spot. 
		if(i_OverrideWeaponSlot[weapon] != -1)
		{
			weapon_slot = i_OverrideWeaponSlot[weapon];
		}

		//if they are NOT holding a melee, instantly go ranged.
		if(weapon_slot != TFWeaponSlot_Melee)
			return 1;

		//now the "Easy" checks are done and now the not so easy checks are left.
		//assume they are a melee player until proven otherwise.
		//this gets triggered if:
		
			//The player is NOT holding a: ranged weapon, a magic weapon, a wrench.
			//This code checks if they are HOLDING a weapon in some other slot of theirs
			//So that they cannot abuse this and avoid getting shot at while they are actually a ranged player.

		

		int type = 0;	//this way a ranged player can't switch to their melee to avoid attacks.
		int i, entity;
		while(TF2_GetItem(this.m_iTarget, entity, i))
		{
			if(StoreWeapon[entity] > 0)
			{
				if(i_IsWandWeapon[entity] || i_IsWrench[entity])
				{
					type = 1;
					break;
				}
				char buffer[255];
				GetEntityClassname(entity, buffer, sizeof(buffer));
				int slot = TF2_GetClassnameSlot(buffer);

				//same case as above, although, why would someone use both angelica and a normal melee at the same time? 
				//note: this still loops through the current held weapon.
				if(i_OverrideWeaponSlot[entity] != -1)
				{
					slot = i_OverrideWeaponSlot[entity];
				}

				if(slot != TFWeaponSlot_Melee)
				{
					type = 1;
					break;
				}
			}
		}*/
		//edge case: player is a mage, has 2 weapons that take the melee slot, the player could take out a melee weapon to trick this system into thinking they are a melee when in reality they are a mage.
		//hypothesis: 
		//even if it isn't him who discovers it, I'll have to add a thing that checks multiple weapon slots too...

		//return type;
	}
	property float m_flTempIncreaseCDTeleport
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flIonicFractureCD
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flIonicFractureEndTimer
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flIonicFractureChargeTimer
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	property float m_flIonicFractureWindUpTimer
	{
		public get()							{ return fl_BEAM_ThrottleTime[this.index]; }
		public set(float TempValueForProperty) 	{ fl_BEAM_ThrottleTime[this.index] = TempValueForProperty; }
	}
	property float m_flIonicFractureAnimTimer
	{
		public get()							{ return fl_BEAM_ChargeUpTime[this.index]; }
		public set(float TempValueForProperty) 	{ fl_BEAM_ChargeUpTime[this.index] = TempValueForProperty; }
	}
	property float m_flIonicFractureHoverTimer
	{
		public get()							{ return fl_BEAM_RechargeTime[this.index]; }
		public set(float TempValueForProperty) 	{ fl_BEAM_RechargeTime[this.index] = TempValueForProperty; }
	}
	property float m_flMagiaOverflowRecharge
	{
		public get()							{ return fl_AbilityOrAttack[this.index][4]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][4] = TempValueForProperty; }
	}
	property float m_flLunarTimer
	{
		public get()							{ return fl_AbilityOrAttack[this.index][5]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][5] = TempValueForProperty; }
	}
	property float m_flLunarThrottle
	{
		public get()							{ return fl_AbilityOrAttack[this.index][6]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][6] = TempValueForProperty; }
	}
	property float m_flLunarLoop
	{
		public get()							{ return fl_AbilityOrAttack[this.index][7]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][7] = TempValueForProperty; }
	}
	property int m_iLunarAmmo
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}
	property float m_flCosmicGazeTimer
	{
		public get()							{ return fl_AbilityOrAttack[this.index][8]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][8] = TempValueForProperty; }
	}
	property float m_flRetreatTimer
	{
		public get()							{ return fl_AbilityOrAttack[this.index][9]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][9] = TempValueForProperty; }
	}
	property float m_flForceRanged
	{
		public get()							{ return fl_Dead_Ringer_Invis[this.index]; }
		public set(float TempValueForProperty) 	{ fl_Dead_Ringer_Invis[this.index] = TempValueForProperty; }
	}
	property float m_flCosmicGazeActive
	{
		public get()							{ return fl_Dead_Ringer[this.index]; }
		public set(float TempValueForProperty) 	{ fl_Dead_Ringer[this.index] = TempValueForProperty; }
	}
	property int m_iRangedAmmo
	{
		public get()							{ return i_MedkitAnnoyance[this.index]; }
		public set(int TempValueForProperty) 	{ i_MedkitAnnoyance[this.index] = TempValueForProperty; }
	}
	property int m_iMeleeCombo
	{
		public get()							{ return i_OverlordComboAttack[this.index]; }
		public set(int TempValueForProperty) 	{ i_OverlordComboAttack[this.index] = TempValueForProperty; }
	}
	property int m_iBarrageAmmo
	{
		public get()							{ return i_AttacksTillReload[this.index]; }
		public set(int TempValueForProperty) 	{ i_AttacksTillReload[this.index] = TempValueForProperty; }
	}
	property int m_iHandParticle
	{
		public get()							{ return i_WeaponArchetype[this.index]; }
		public set(int TempValueForProperty) 	{ i_WeaponArchetype[this.index] = TempValueForProperty; }
	}
	property float m_flFinalInvocationTimer
	{
		public get()							{ return fl_Charge_delay[this.index]; }
		public set(float TempValueForProperty) 	{ fl_Charge_delay[this.index] = TempValueForProperty; }
	}
	property float m_flFinalInvocationLogic
	{
		public get()							{ return fl_Charge_Duration[this.index]; }
		public set(float TempValueForProperty) 	{ fl_Charge_Duration[this.index] = TempValueForProperty; }
	}
	property float m_flCosmicGazeThrottle
	{
		public get()							{ return fl_BEAM_ThrottleTime[this.index]; }
		public set(float TempValueForProperty) 	{ fl_BEAM_ThrottleTime[this.index] = TempValueForProperty; }
	}
	property float m_flCosmicGazeWindUp
	{
		public get()							{ return fl_BEAM_ChargeUpTime[this.index]; }
		public set(float TempValueForProperty) 	{ fl_BEAM_ChargeUpTime[this.index] = TempValueForProperty; }
	}
	property float m_flCosmicGazeDurationOffset
	{
		public get()							{ return fl_BEAM_DurationTime[this.index]; }
		public set(float TempValueForProperty) 	{ fl_BEAM_DurationTime[this.index] = TempValueForProperty; }
	}
	property float m_flCosmicGazeDistance
	{
		public get()							{ return fl_BEAM_RechargeTime[this.index]; }
		public set(float TempValueForProperty) 	{ fl_BEAM_RechargeTime[this.index] = TempValueForProperty; }
	}
	property float m_flRetreatLaserThrottle
	{
		public get()							{ return fl_BEAM_ThrottleTime[this.index]; }
		public set(float TempValueForProperty) 	{ fl_BEAM_ThrottleTime[this.index] = TempValueForProperty; }
	}
	property bool m_bAnimationSet
	{
		public get()							{ return b_Half_Life_Regen[this.index]; }
		public set(bool TempValueForProperty) 	{ b_Half_Life_Regen[this.index] = TempValueForProperty; }
	}
	property float m_flMagiaAngle
	{
		public get()							{ return fl_ThrowDelay[this.index]; }
		public set(float TempValueForProperty) 	{ fl_ThrowDelay[this.index] = TempValueForProperty; }
	}

	public char[] GetName()
	{
		char Name[255];
		Format(Name, sizeof(Name), "%s%s%s:", NameColour, NpcStats_ReturnNpcName(this.index), TextColour);
		return Name;
	}
	public void AdjustWalkCycle()
	{
		if(this.IsOnGround())
		{
			if(this.m_iChanged_WalkCycle == 0)
			{
				this.m_bisWalking = true;
				this.SetActivity("ACT_MP_RUN_MELEE");
				this.m_iChanged_WalkCycle = 1;
			}
		}
		else
		{
			if(this.m_iChanged_WalkCycle == 1)
			{
				this.m_bisWalking = true;
				this.SetActivity("ACT_MP_JUMP_FLOAT_MELEE");
				this.m_iChanged_WalkCycle = 0;
			}
		}
	}
	public void RangedArmour()
	{
		float GameTime = GetGameTime(this.index);
		float armour = 1.0;
		
		//check if lunar radiance is active.
		int ent = EntRefToEntIndex(i_lunar_entities[this.index][0]);
		if(IsValidEntity(ent))
			armour *= 0.3;

		//check if cosmic gaze is active
		if(this.m_flCosmicGazeActive > GameTime)
			armour *= 0.3;

		//check if ionic fracture is active
		if(this.m_flIonicFractureEndTimer > GameTime)
			armour *= 0.3;

		if(b_force_transformation)
			armour *= 0.5;

		this.m_flRangedArmor = armour;
	}
	public void MeleeArmour()
	{
		float GameTime = GetGameTime(this.index);
		float armour = 1.25;

		//check if lunar radiance is active.
		int ent = EntRefToEntIndex(i_lunar_entities[this.index][0]);
		if(IsValidEntity(ent))
			armour *= 0.625;

		//check if cosmic gaze is active
		if(this.m_flCosmicGazeActive > GameTime)
			armour *= 0.625;

		//check if ionic fracture is active
		if(this.m_flIonicFractureEndTimer > GameTime)
			armour *= 0.625;

		if(b_force_transformation)
			armour *= 0.75;

		this.m_flMeleeArmor = armour;
	}
	public Twirl(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Twirl npc = view_as<Twirl>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "1250", ally));

		//data: sc%% ; test, verkia, force15, force30, force45, force60, triple_enemies, final_item, blockinv, anger
		
		npc.m_iChanged_WalkCycle = 1;
		npc.m_iBarrageAmmo = 0;
		npc.m_iMeleeCombo = 0;
		npc.m_iLunarAmmo = 0;
		b_lastman = false;
		b_wonviatimer = false;
		b_wonviakill = false;

		Zero(b_said_player_weaponline);
		fl_said_player_weaponline_time[npc.index] = GetGameTime() + GetRandomFloat(0.0, 5.0);

		c_NpcName[npc.index] = "Twirl";

		b_force_transformation = false;

		b_test_mode = StrContains(data, "test") != -1;
		b_force_transformation = StrContains(data, "verkia") != -1;

		int wave = Waves_GetRoundScale()+1;

		if(StrContains(data, "force10") != -1)
			wave = 10;
		if(StrContains(data, "force20") != -1)
			wave = 20;
		if(StrContains(data, "force30") != -1)
			wave = 30;
		if(StrContains(data, "force40") != -1)
			wave = 40;

		npc.m_bDissapearOnDeath = true;
		npc.m_fbGunout = true;
		i_current_wave[npc.index] = wave;

		i_NpcWeight[npc.index] = 4;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		npc.m_bisWalking = true;
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = false;
	
		fl_next_textline = 0.0;
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "item_armor", 1, "%t", "Twirl Spawn");
			}
		}
		b_tripple_raid = false;
		bool default_theme = true;
		if((StrContains(data, "triple_enemies") != -1))
		{
			b_tripple_raid = true;
			default_theme = false;
		}
		RemoveAllDamageAddition();
			

		if(default_theme)
		{
			MusicEnum music;
			strcopy(music.Path, sizeof(music.Path), RAIDBOSS_TWIRL_THEME);
			music.Time = 190;
			music.Volume = 1.65;
			music.Custom = true;
			strcopy(music.Name, sizeof(music.Name), "Night life in Ruina");
			strcopy(music.Artist, sizeof(music.Artist), "Grandpa Bard");
			Music_SetRaidMusic(music);	
		}
		
		b_allow_final = StrContains(data, "final_item") != -1;
		TwirlEarsApply(npc.index,_,0.75);

		if(b_allow_final)
		{
			b_NpcUnableToDie[npc.index] = true;
		}
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flReloadIn = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCFuncWin[npc.index] = view_as<Function>(Twirl_WinLine);
		func_NPCDeath[npc.index] = view_as<Function>(NPC_Death);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(ClotThink);

		fl_npc_basespeed = 290.0;
		npc.m_flSpeed = fl_npc_basespeed;
		npc.m_bisWalking = true;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();

		b_thisNpcIsARaid[npc.index] = true;

		npc.m_bThisNpcIsABoss = true;
		
		RaidModeTime = GetGameTime(npc.index) + 250.0;
		
		char buffers[3][64];
		ExplodeString(data, ";", buffers, sizeof(buffers), sizeof(buffers[]));
		//the very first and 2nd char are SC for scaling
		if(buffers[0][0] == 's' && buffers[0][1] == 'c')
		{
			//remove SC
			ReplaceString(buffers[0], 64, "sc", "");
			float value = StringToFloat(buffers[0]);
			RaidModeScaling = value;
		}
		else
		{	
			RaidModeScaling = float(Waves_GetRoundScale()+1);
		}
		
		if(RaidModeScaling < 35)
		{
			RaidModeScaling *= 0.25; //abit low, inreacing
		}
		else
		{
			RaidModeScaling *= 0.5;
		}
		
		float amount_of_people = ZRStocks_PlayerScalingDynamic();
		
		if(amount_of_people > 12.0)
		{
			amount_of_people = 12.0;
		}
		
		amount_of_people *= 0.12;
		
		if(amount_of_people < 1.0)
			amount_of_people = 1.0;
			
		RaidModeScaling *= amount_of_people;

		RaidModeScaling *= 1.1;
				
		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
		npc.m_bTeamGlowDefault = false;
			
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		SetVariantColor(view_as<int>({125, 0, 125, 255}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
				
		fl_ruina_battery[npc.index] = 0.0;
		b_ruina_battery_ability_active[npc.index] = false;
		fl_ruina_battery_timer[npc.index] = 0.0;

		int skin = 1;	//1=blue, 0=red
		SetVariantInt(1);	
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		npc.m_iWearable1 = npc.EquipItem("head", RUINA_CUSTOM_MODELS_3);
		npc.m_iWearable2 = npc.EquipItem("head", RUINA_CUSTOM_MODELS_3);
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/dec23_puffed_practitioner/dec23_puffed_practitioner.mdl", _, skin);
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/all_class/witchhat/witchhat_medic.mdl", _, skin);
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/all_class/jogon/jogon_medic.mdl", _, skin);
		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/medic/medic_wintercoat_s02/medic_wintercoat_s02.mdl", _, skin);
		npc.m_iWearable7 = npc.EquipItem("head", "models/workshop_partner/player/items/all_class/tomb_readers/tomb_readers_medic.mdl", _, skin);
		float flPos[3], flAng[3];
		npc.GetAttachment("head", flPos, flAng);	
		npc.m_iWearable8 = ParticleEffectAt_Parent(flPos, "unusual_invasion_boogaloop_2", npc.index, "head", {0.0,0.0,0.0});
		
		SetVariantInt(RUINA_WINGS_4);
		AcceptEntityInput(npc.m_iWearable2, "SetBodyGroup");
		SetVariantInt(npc.i_weapon_type());
		AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");

		npc.Anger = false;

		if(b_tripple_raid)
		{
			Twirl_Lines(npc, "Oh my, looks like the expidonsans went easy on you, we sure wont my dears. Us ruanians work differently~");
			Twirl_Lines(npc, "... Except Karlas but shhhh!");
			CPrintToChatAll("{crimson}Karlas{snow}: .....");
			CPrintToChatAll("{crimson}Karlas{snow}: :(");
			RaidModeTime = GetGameTime(npc.index) + 500.0;
			GiveOneRevive(true);

			npc.m_iRangedAmmo = 18;
		}
		else if(wave <=10)
		{
			npc.m_iRangedAmmo = 5;
			switch(GetRandomInt(0, 5))
			{
				case 0: Twirl_Lines(npc, "Ahhh, it feels nice to venture out into the world every once in a while...");
				case 1: Twirl_Lines(npc, "Oh the joy I will get from {crimson}fighting{snow} you all");
				case 2: Twirl_Lines(npc, "From what {aqua}Stella{snow}'s told, this should be great {purple}fun{snow}..");
				case 3: Twirl_Lines(npc, "Let's see who dies {crimson}first{snow}!");
				case 4: Twirl_Lines(npc, "Huh interesting, who might you be? no matter, you look strong, {crimson}ima fight you");	//HEY ITS ME GOKU, I HEARD YOUR ADDICTION IS STRONG, LET ME FIGHT IT
				case 5: Twirl_Lines(npc, "Its time to \"Twirl\" like a beyblade");
			}
		}
		else if(wave <=20)
		{
			npc.m_iRangedAmmo = 7;
			switch(GetRandomInt(0, 4))
			{
				case 0: Twirl_Lines(npc, "Last time, it was a great workout, {crimson}Time to do it again{snow}!");
				case 1: Twirl_Lines(npc, "Our last fight was so fun, I hope this fight is as fun as the last one!");
				case 2: Twirl_Lines(npc, "{aqua}Stella{snow} was right, you all ARE great fun to play with!");
				case 3: Twirl_Lines(npc, "Ehe, now who will die {crimson}last{snow}?");
				case 4: Twirl_Lines(npc, "You spin me right round..");
			}
		}
		else if(wave <=30)
		{
			npc.m_iRangedAmmo = 9;
			switch(GetRandomInt(0, 4))
			{
				case 0: Twirl_Lines(npc, "My Oh my, you're still here, {purple}how wonderful!");
				case 1: Twirl_Lines(npc, "You must enjoy fighting as much as {purple}I do{snow}, considering you've made it this far!");
				case 2: Twirl_Lines(npc, "{aqua}Stella{snow}, you understated how {purple}fun{snow} this would be!");
				case 3: Twirl_Lines(npc, "I've brought some {purple}Heavy Equipment{snow} heh");
				case 4: Twirl_Lines(npc, "Time to \"Twirl\", heh");
			}
		}
		else if(wave <=40)
		{	
			npc.m_iRangedAmmo = 12;
			switch(GetRandomInt(0, 4))
			{
				case 0: Twirl_Lines(npc, "Its time for the final show, {purple}I hope yoyou're all as excited as I am{snow}!");
				case 1: Twirl_Lines(npc, "Ah, the fun that {aqua}Stella{snow}'s missing out on,{purple} a shame{snow}.");
				case 2: Twirl_Lines(npc, "I hope you're ready for this final {purple}battle{snow}.");
				case 3: Twirl_Lines(npc, "Kuru Kuru~");
				case 4:
				{
					switch(GetRandomInt(0, 2))
					{
						case 1:	//1/6*1/3 ~ 5.(5)% of it happening
						{
							Twirl_Lines(npc, "You know, there's something I've always wondered about, why do you people keep on calling me a masochist.");
							Twirl_Lines(npc, "Since like, I'm not one for the record, and yet some of the \"people\" I've fought in the past keep calling me that.");
							Twirl_Lines(npc, "And I'm at a loss as to WHY they say that, if anything it would be more accurate to call me a sadist, for the record, I'm not..");
							Twirl_Lines(npc, "So yaknow, if you can, try and explain it, please?");
						}
						default: Twirl_Lines(npc, "Kururing~");
					}
				}
			}
			if(!b_tripple_raid)
				RaidModeScaling *=0.9;
		}
		else	//freeplay
		{
			if(!b_tripple_raid)
				RaidModeScaling *=0.9;
			npc.m_iRangedAmmo = 12;
			switch(GetRandomInt(0, 3))
			{
				case 1: Twirl_Lines(npc, "So the flow of magic lead me here, {purple}how interesting{snow}...");
				case 2: Twirl_Lines(npc, "Oh, its you all, hey, wanna {crimson}fight{snow}? {purple}of course you do{snow}!");
				case 3: Twirl_Lines(npc, "I need to unwind, and you all look {crimson}perfect{snow} for that!");
			}
		}

		i_current_Text = 0;

		npc.m_flDoingAnimation = 0.0;

		npc.m_flNextTeleport = GetGameTime(npc.index) + GetRandomFloat(5.0, 10.0);
		npc.m_flNextRangedBarrage_Spam = GetGameTime(npc.index) + GetRandomFloat(5.0, 10.0);
		npc.m_flCosmicGazeTimer = GetGameTime(npc.index)  + GetRandomFloat(5.0, 10.0);
		npc.m_flLunarTimer = GetGameTime(npc.index) + GetRandomFloat(10.0, 20.0);
		npc.m_flMagiaOverflowRecharge = GetGameTime(npc.index) + GetRandomFloat(10.0, 20.0);
		
		npc.m_flIonicFractureCD = GetGameTime(npc.index) + GetRandomFloat(15.0, 20.0);// GetRandomFloat(10.0, 20.0);

		npc.m_flFinalInvocationTimer = 0.0;
		npc.m_flFinalInvocationLogic = 0.0;
		b_allow_final_invocation = false;

		Ruina_Set_Heirarchy(npc.index, RUINA_GLOBAL_NPC);
		Ruina_Set_Master_Heirarchy(npc.index, RUINA_GLOBAL_NPC, true, 999, 999);	

		if(!b_test_mode)	//my EARS
		{
			EmitSoundToAll("mvm/mvm_tele_deliver.wav", _, _, _, _, _, RUINA_NPC_PITCH);
			EmitSoundToAll("mvm/mvm_tele_deliver.wav", _, _, _, _, _, RUINA_NPC_PITCH);
		}	

		if(b_test_mode)
		{
			RaidModeTime = FAR_FUTURE;
		}

		npc.m_bInKame = false;

		if(StrContains(data, "blockinv") != -1)
			npc.m_flFinalInvocationTimer = FAR_FUTURE;

		npc.Anger = (StrContains(data, "anger") != -1);

		Zero(fl_player_weapon_score);
		Ruina_Set_Battery_Buffer(npc.index, true);
		fl_ruina_battery_max[npc.index] = 1000000.0; //so high itll never be reached.
		fl_ruina_battery[npc.index] = 0.0;
		
		return npc;
	}
}

void TwirlSetBatteryPercentage(int entity, float percentage)
{
	fl_ruina_battery_max[entity] = 1000000.0; //so high itll never be reached.
	fl_ruina_battery[entity] = ((percentage * 100) * 10000.0);
}

static void Twirl_WinLine(int entity)
{
	b_wonviakill = true;
	Twirl npc = view_as<Twirl>(entity);
	if(b_wonviatimer)
		return;

	if(b_force_transformation)
	{
		Twirl_Lines(npc, "{crimson}Perish");
		return;
	}

	switch(GetRandomInt(0, 10))
	{
		case 0: Twirl_Lines(npc, "Wait, you're all dead already??");
		case 1: Twirl_Lines(npc, "This was quite fun, I thank you for the experience!");
		case 2: Twirl_Lines(npc, "Huh, I guess this was all you were capable of, a shame");
		case 3: Twirl_Lines(npc, "I, as the empress, thank you for this wonderful time");
		case 4: Twirl_Lines(npc, "Ahhh, that was a great workout, time to hit the showers");
		case 5: Twirl_Lines(npc, "You call this fighting? We call this resisting arrest");
		case 6: Twirl_Lines(npc, "Another one bites the dust");
		case 7: Twirl_Lines(npc, "Ah foolish Mercenaries, maybe next time think about a proper strategy");
		case 8: Twirl_Lines(npc, "Raw power is good and all, but you know what's better? {crimson}Debuffs");
		case 9: Twirl_Lines(npc, "Perhaps if you all had more {aqua}supports{snow} you'd might have won. Allas");
		case 10: Twirl_Lines(npc, "{crimson}How Cute{snow}.");
		case 11: Twirl_Lines(npc, "And you're all supposed to be strong?");
	}

}

static void ClotThink(int iNPC)
{
	Twirl npc = view_as<Twirl>(iNPC);
	
	float GameTime = GetGameTime(npc.index);

	CheckChargeTimeTwirl(npc);
	if(npc.m_flNextThinkTime == FAR_FUTURE && b_allow_final)
	{
		GameTime = GetGameTime();	//No slowing it down!
		RaidModeTime = fl_raidmode_freeze + GameTime;	//"freeze" the raid timer
		if(npc.m_iChanged_WalkCycle != 99)
		{
			if(IsValidEntity(npc.m_iWearable1))
				RemoveEntity(npc.m_iWearable1);

			npc.m_iChanged_WalkCycle = 99;
			npc.m_bisWalking = false;
			npc.AddActivityViaSequence("competitive_loserstate_idle");
			
		}
		if(fl_next_textline < GameTime)
		{	
			fl_next_textline = GameTime + 3.0;
			switch(i_current_Text)
			{
				case 0: Twirl_Lines(npc, "So then, you managed to beat me");
				case 1: Twirl_Lines(npc, "Thats great, why you may ask?");
				case 2: Twirl_Lines(npc, "Its quite simple, it shows that you've all gone far");
				case 3: Twirl_Lines(npc, "You beat several world ending infections, alongside that gained many allies");
				case 4: Twirl_Lines(npc, "But the future holds many more hardships and dangers");
				case 5: Twirl_Lines(npc, "And so, it was decided that we the Ruanian's would test your skills");
				case 6: Twirl_Lines(npc, "To see if you’re all ready for what the future holds");
				case 7: Twirl_Lines(npc, "And well, you do, you are certainly ready for the future");
				case 8: Twirl_Lines(npc, "But do keep this in mind, the ''Ruina'' that you fought here, was just a mere...");
				case 9: Twirl_Lines(npc, "Heh.. Yeah, a mere fraction of what we are capable off");
				case 10:
				{
					Twirl_Lines(npc, "Regardless take this, it's something that might help in your future adventures");

					npc.m_bDissapearOnDeath = true;

					RaidBossActive = INVALID_ENT_REFERENCE;
					func_NPCThink[npc.index] = INVALID_FUNCTION;

					b_NpcUnableToDie[npc.index] = false;

					RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
					for (int client = 1; client <= MaxClients; client++)
					{
						if(IsValidClient(client) && GetClientTeam(client) == 2 && TeutonType[client] != TEUTON_WAITING && PlayerPoints[client] > 500)
						{
							Items_GiveNamedItem(client, "Twirl's Hairpins");
							CPrintToChat(client,"You have been given {purple}%s{snow}'s hairpins...", c_NpcName[npc.index]);
						}
					}
					Twirl_Lines(npc, "Make sure to take good care of them... or else.");
					return;
				}
			}
			i_current_Text++;
		}
		return;
	}

	if(LastMann && !b_lastman)
	{
		b_lastman = true;
		if(b_force_transformation)
		{
			switch(GetRandomInt(0, 7))
			{
				case 0: Twirl_Lines(npc, "Oh my, quite the situation you’re in here");
				case 1: Twirl_Lines(npc, "Come now, {purple}is this all you can do{snow}? Prove me wrong.");
				case 2: Twirl_Lines(npc, "I know you're capable more than just this");
				case 3: Twirl_Lines(npc, "You're the last one alive, {purple}but{snow} are you the strongest?");
				case 4: Twirl_Lines(npc, "Interesting, perhaps I overestimated you all.");
				case 5: Twirl_Lines(npc, "If you have some form of {purple}secret weapon{snow}, its best to use it now.");
				case 6: Twirl_Lines(npc, "Such is the battlefield, {purple}they all die one by one{snow}, until there is but one standing...");
				case 7: Twirl_Lines(npc, "{crimson}How Cute{snow}. You alone, its such a view");
			}
		}
	}

	if(HandleRaidTimer(npc))
		return;

	if((npc.Anger) && npc.m_flNextChargeSpecialAttack < GetGameTime(npc.index) && npc.m_flNextChargeSpecialAttack != FAR_FUTURE)
	{
		npc.m_flNextChargeSpecialAttack = FAR_FUTURE;

		b_NpcIsInvulnerable[npc.index] = false; //Special huds for invul targets
		f_NpcTurnPenalty[npc.index] = 1.0;

		if(b_force_transformation)
		{
			switch(GetRandomInt(0, 2))
			{
				case 0: Twirl_Lines(npc, "You ain't getting a normal phase shift");
				case 1: Twirl_Lines(npc, "This time, I ain't waiting");
				case 2: Twirl_Lines(npc, "Its time to ramp the heater up to {crimson}max");
			}
		}
		else
		{
			switch(GetRandomInt(0, 6))
			{
				case 0: Twirl_Lines(npc, "Time to ramp up the {purple}heat");
				case 1: Twirl_Lines(npc, "Ahhh, this is {purple}fun{snow}, lets step it up a notch");
				case 2: Twirl_Lines(npc, "Round 2. Fight!");
				case 3: Twirl_Lines(npc, "Ai, this is getting fun");
				case 4: Twirl_Lines(npc, "I’m extremely curious to see how you fair {purple}against this");
				case 5: Twirl_Lines(npc, "Ahahahah, the joy of battle, don't act like you’re not enjoying this");
				case 6: Twirl_Lines(npc, "The flow of {aqua}mana{snow} is so {purple}intense{snow}, I love this oh so much!");
			}
		}
		
		npc.m_flMagiaOverflowRecharge -= 15.0;
		npc.m_flNextTeleport -= 10.0;

		b_NoKnockbackFromSources[npc.index] = false;
		RemoveSpecificBuff(npc.index, "Clear Head");
		RemoveSpecificBuff(npc.index, "Solid Stance");
		RemoveSpecificBuff(npc.index, "Fluid Movement");
		
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 255);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		Explode_Logic_Custom(500.0*RaidModeScaling, npc.index, npc.index, -1, VecSelfNpc, 350.0, _, _, true, _, false, _, LifelossExplosion);
		if(npc.m_bThisNpcIsABoss)
		{
			npc.DispatchParticleEffect(npc.index, "hightower_explosion", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("eyes"), PATTACH_POINT_FOLLOW, true);
		}
		EmitSoundToAll(NPC_PARTICLE_LANCE_BOOM, npc.index, SNDCHAN_STATIC, 120, _, 0.6);
		EmitSoundToAll(NPC_PARTICLE_LANCE_BOOM, npc.index, SNDCHAN_STATIC, 120, _, 0.6);

		switch(GetRandomInt(1,3))
		{
			case 1:
				EmitSoundToAll(NPC_PARTICLE_LANCE_BOOM1, npc.index, SNDCHAN_STATIC, 120, _, 1.0);
			case 2:
				EmitSoundToAll(NPC_PARTICLE_LANCE_BOOM2, npc.index, SNDCHAN_STATIC, 120, _, 1.0);
			case 3:
				EmitSoundToAll(NPC_PARTICLE_LANCE_BOOM3, npc.index, SNDCHAN_STATIC, 120, _, 1.0);
		}
		npc.m_bisWalking = true;
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		npc.m_iChanged_WalkCycle = 1;
		if(iActivity > 0) npc.StartActivity(iActivity);

		fl_npc_basespeed = 310.0;

		npc.m_bisWalking = true;
		npc.m_flSpeed = fl_npc_basespeed;
	}

	npc.RangedArmour();
	npc.MeleeArmour();

	if(npc.m_flNextDelayTime > GameTime)
		return;

	if(b_allow_final_invocation)
	{
		if(npc.m_flFinalInvocationTimer != FAR_FUTURE)
		{
			npc.m_flFinalInvocationTimer = FAR_FUTURE;
			//npc.m_flFinalInvocationLogic = GetGameTime() + 5.0;
			Final_Invocation(npc);
		}
	}
	
	npc.m_flNextDelayTime = GameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();

	if(npc.m_flGetClosestTargetTime < GameTime)
	{
		if(npc.m_bInKame)
		{
			npc.m_iTarget = i_Get_Laser_Target(npc);
			npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 0.2;
		}
		else
		{
			npc.m_iTarget = GetClosestTarget(npc.index);
			npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
		}
		
	}
	if(npc.m_bInKame)
	{
		if(IsValidEnemy(npc.index, npc.m_iTarget))
		{
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);

			float Turn_Speed = (npc.Anger ? 30.0 : 19.0);
			//if there are more then 3 players near twirl, her laser starts to turn faster.
			int Nearby = Nearby_Players(npc, (npc.Anger ? 300.0 : 250.0));
			if(Nearby > 3)
			{
				Turn_Speed *= (Nearby/2.0)*1.2;
			}
			npc.FaceTowards(vecTarget, Turn_Speed);
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);

			int iPitch = npc.LookupPoseParameter("body_pitch");
			if(iPitch < 0)
				return;		

			//Body pitch
			float v[3], ang[3];
			SubtractVectors(VecSelfNpc, vecTarget, v); 
			NormalizeVector(v, v);
			GetVectorAngles(v, ang); 
									
			float flPitch = npc.GetPoseParameter(iPitch);
									
			npc.SetPoseParameter(iPitch, ApproachAngle(ang[0], flPitch, 10.0));
		}
		else
		{
			npc.m_flGetClosestTargetTime = 0.0;
		}
	}
			
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

	if(!IsValidEntity(RaidBossActive))
	{
		RaidBossActive=EntIndexToEntRef(npc.index);
	}
	
	npc.m_flNextThinkTime = GameTime + 0.1;

	Ruina_Add_Battery(npc.index, 0.75);

	if(npc.m_flDoingAnimation > GetGameTime(npc.index))
		return;

	if(npc.IsOnGround())
		Retreat(npc);

	npc.AdjustWalkCycle();

	npc.Handle_Weapon();	//adjusts weapon model/state depending on target
	
	int PrimaryThreatIndex = npc.m_iTarget;	

	Ruina_Ai_Override_Core(npc.index, PrimaryThreatIndex, GameTime);	//handles movement, also handles targeting

	if(b_allow_final_invocation)
		SacrificeAllies(npc.index);

	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		if(npc.IsOnGround())
		{
			Fractal_Gram(npc, PrimaryThreatIndex);
			Cosmic_Gaze(npc, PrimaryThreatIndex);
			lunar_Radiance(npc);
			if(Magia_Overflow(npc))
				return;
			if(IonicFracture(npc))
				return;

			if(npc.m_flDoingAnimation > GetGameTime(npc.index))
				return;
		}
		float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);

		int iPitch = npc.LookupPoseParameter("body_pitch");
		if(iPitch < 0)
			return;		

		//Body pitch
		float v[3], ang[3];
		SubtractVectors(VecSelfNpc, vecTarget, v); 
		NormalizeVector(v, v);
		GetVectorAngles(v, ang); 
								
		float flPitch = npc.GetPoseParameter(iPitch);
								
		npc.SetPoseParameter(iPitch, ApproachAngle(ang[0], flPitch, 10.0));

		npc.StartPathing();

		bool backing_up = KeepDistance(npc, flDistanceToTarget, PrimaryThreatIndex, GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 7.5);

		if(flDistanceToTarget < GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 5.0)
		{
			npc.m_bAllowBackWalking = true;
			npc.FaceTowards(vecTarget, RUINA_FACETOWARDS_BASE_TURNSPEED*2.0);
		}

		Self_Defense(npc, flDistanceToTarget, PrimaryThreatIndex, vecTarget);

		if(npc.m_bAllowBackWalking && backing_up)
		{
			npc.m_flSpeed = fl_npc_basespeed*RUINA_BACKWARDS_MOVEMENT_SPEED_PENALTY;	
			npc.FaceTowards(vecTarget, RUINA_FACETOWARDS_BASE_TURNSPEED*2.0);
		}
		else
		{
			npc.m_flSpeed = fl_npc_basespeed;
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
static float Target_Angle_Value(Twirl npc, int Target)
{
	// need position of either the inflictor or the attacker
	float Vic_Pos[3];
	WorldSpaceCenter(Target, Vic_Pos);
	float npc_pos[3];
	float angle[3];
	float eyeAngles[3];
	WorldSpaceCenter(npc.index, npc_pos);
	
	GetVectorAnglesTwoPoints(npc_pos, Vic_Pos, angle);
	GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyeAngles);

	// need the yaw offset from the player's POV, and set it up to be between (-180.0..180.0)
	float yawOffset = fixAngle(angle[1]) - fixAngle(eyeAngles[1]);
	if (yawOffset <= -180.0)
		yawOffset += 360.0;
	else if (yawOffset > 180.0)
		yawOffset -= 360.0;

	//if its more then 180, its on the other side of the npc / behind
	return fabs(yawOffset);
}
//don't just search for the nearest target when using the laser.
//Instead search for the target NEAREST to our BEAM's length.
static int i_Get_Laser_Target(Twirl npc)
{
	UnderTides npcGetInfo = view_as<UnderTides>(npc.index);
	int enemy_2[MAXPLAYERS];
	//It should target upto 20 people only, if its anymore it starts becomming un dodgeable due to the nature of AOE laser attacks
	GetHighDefTargets(npcGetInfo, enemy_2, sizeof(enemy_2), true, true);
	//only bother getting targets infront of twirl that are players. + wall check obv
	int Tmp_Target = -1;
	float Angle_Val = 420.0;
	for(int i; i < sizeof(enemy_2); i++)
	{
		if(enemy_2[i])
		{
			float Target_Angles = Target_Angle_Value(npc, enemy_2[i]);
			if(Target_Angles < 45.0 && Target_Angles < Angle_Val)
			{
				Angle_Val = Target_Angles;
				Tmp_Target = enemy_2[i];
				
				//CPrintToChatAll("Player %N within 45 degress: %f", Tmp_Target, Target_Angles);
			}
		}
	}
	//if we don't find any targets within 90 degrees infront, give up and use normal targeting!
	//and by 90 degress I mean -45 -> 45. \/
	
	if(!IsValidEnemy(npc.index, Tmp_Target))
	{
		//CPrintToChatAll("Backup Target used");
		npc.m_iTarget = GetClosestTarget(npc.index,_,_,_,_,_,_,true);
		if(npc.m_iTarget < 1)
		{
			npc.m_iTarget = GetClosestTarget(npc.index);
		}
		return npc.m_iTarget;
	}
	else
	{
		//CPrintToChatAll("Chose Target: %N with angle var: %f", Tmp_Target, Angle_Val);
		return Tmp_Target;
	}
		
}
static void Final_Invocation(Twirl npc)
{
	Ruina_Set_Overlord(npc.index, true);
	Ruina_Master_Rally(npc.index, true);
	int MaxHealth = ReturnEntityMaxHealth(npc.index);
	float Tower_Health = MaxHealth*0.175;

	for(int i=0 ; i < 4 ; i++)
	{
		float AproxRandomSpaceToWalkTo[3];
		WorldSpaceCenter(npc.index, AproxRandomSpaceToWalkTo);
		int spawn_index = NPC_CreateByName("npc_ruina_magia_anchor", npc.index, AproxRandomSpaceToWalkTo, {0.0,0.0,0.0}, GetTeam(npc.index), "force60;raid;noweaver;full");
		if(spawn_index > MaxClients)
		{
			NpcStats_CopyStats(npc.index, spawn_index);
			if(GetTeam(npc.index) != TFTeam_Red)
			{
				NpcAddedToZombiesLeftCurrently(spawn_index, true);
			}
			int Decicion = TeleportDiversioToRandLocation(spawn_index,_,1250.0, 500.0);

			if(Decicion == 2)
				Decicion = TeleportDiversioToRandLocation(spawn_index, _, 1250.0, 250.0);

			if(Decicion == 2)
				Decicion = TeleportDiversioToRandLocation(spawn_index, _, 1250.0, 0.0);
				
			SetEntProp(spawn_index, Prop_Data, "m_iHealth", RoundToCeil(Tower_Health));
			SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", RoundToCeil(Tower_Health));
		}
	}
	if(b_force_transformation)
	{
		switch(GetRandomInt(0, 3))
		{
			case 0: Twirl_Lines(npc, "I refuse to let you go beyond this point");
			case 1: Twirl_Lines(npc, "{crimson}Perish.");
			case 2: Twirl_Lines(npc, "{crimson}I Got a Glock in my rari.");
			case 3: Twirl_Lines(npc, "{crimson}I'm going to mount your heads on a staff as a warning for others not to fuck with me");
		}
	}
	else
	{
		switch(GetRandomInt(0, 7))
		{
			case 0: Twirl_Lines(npc, "If you think I’m all you have to deal with, {crimson}well then...");
			case 1: Twirl_Lines(npc, "Ahahah, I am a ruler Afterall, {purple}and a ruler usually has an army");
			case 2: Twirl_Lines(npc, "How's your aoe situation?");
			case 3: Twirl_Lines(npc, "Don't worry, the {aqua}Stellar Weaver{snow} won't be showing up from them");
			case 4: Twirl_Lines(npc, "Hmm, how about a bit of support, {crimson}for myself");
			case 5: Twirl_Lines(npc, "Aye, this’ll do, now go forth my minion’s {crimson}and crush them{snow}!");
			case 6: Twirl_Lines(npc, "The Final Invocation!");
			case 7: Twirl_Lines(npc, "{lightblue}Alaxios{default} Oh HIM, yeah I maaay have borrowed this from him, heh, just don't tell him or his ''god''lines might get hurt.");
		}
	}
	
	RaidModeTime += 60.0;

	GiveOneRevive(false);

	if(!b_force_transformation)
	{
		switch(GetRandomInt(0, 1))
		{
			case 0: Twirl_Lines(npc, "Hm? Whats this? You seem eager?");
			case 1: Twirl_Lines(npc, "Oh my, looks like this wont be as easy as i thought...");
		}
	}
	

	for(int i=1 ; i <= MaxClients ; i++)
	{
		if(IsValidClient(i) && IsClientInGame(i) && IsPlayerAlive(i) && TeutonType[i] == TEUTON_NONE && dieingstate[i] == 0)
		{
			HealEntityGlobal(i, i, float(SDKCall_GetMaxHealth(i)) * 0.5, 1.0, 1.0, HEAL_ABSOLUTE);
			CPrintToChat(i, "{green}Adrenalive rushes through your body, healing you and giving you an extra revive.");
		}
	}
}
static void LifelossExplosion(int entity, int victim, float damage, int weapon)
{
	if(IsValidClient(victim))
		Client_Shake(victim, 0, 7.5, 7.5, 3.0);

	Custom_Knockback(entity, victim, 1000.0, true);
}

static int i_Lunar_RadianceAmt(Twirl npc)
{
	int amt = (npc.Anger ? 14 : 7);

	return amt;
}
static float fl_Lunar_RadianceTimer(Twirl npc)
{
	float time = (npc.Anger ? 0.7 : 1.2);
	return time;
}
static void lunar_Radiance(Twirl npc)
{
	if(i_current_wave[npc.index] <=30)
		return;
	float GameTime = GetGameTime(npc.index);
	if(fl_ruina_battery_timeout[npc.index] > GameTime)
		return;
	if(npc.m_flDoingAnimation > GameTime)
		return;
	if(npc.m_flLunarTimer > GameTime)
		return;

	EmitSoundToAll("player/taunt_surgeons_squeezebox_draw_accordion.wav", npc.index, SNDCHAN_STATIC, SNDLEVEL_RAIDSIREN, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL);
	EmitSoundToAll("player/taunt_surgeons_squeezebox_draw_accordion.wav", npc.index, SNDCHAN_STATIC, SNDLEVEL_RAIDSIREN, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL);

	EmitSoundToAll("npc/attack_helicopter/aheli_charge_up.wav");
	EmitSoundToAll("npc/attack_helicopter/aheli_charge_up.wav");
	
	npc.StopPathing();

	npc.m_flLunarLoop = 0.0;

	for(int i= 0 ; i < 3 ; i ++)
	{
		int ent = EntRefToEntIndex(i_lunar_entities[npc.index][i]);
		if(IsValidEntity(ent))
			RemoveEntity(ent);

		i_lunar_entities[npc.index][i] = INVALID_ENT_REFERENCE;
	}

	if(!b_force_transformation)
	{
		switch(GetRandomInt(0, 17))
		{
			case 0: Twirl_Lines(npc, "These are just my own personal {crimson}ION{snow}'s. Ruina's ones are far scarier~");
			case 2: Twirl_Lines(npc, "Watch your {crimson}Step{snow}!");
			case 5: Twirl_Lines(npc, "Lookout {crimson}Above{snow}!");
			case 7: Twirl_Lines(npc, "I hope you're all split up, {crimson}Or else {snow}this won't end well");
			case 9: Twirl_Lines(npc, "Music is a core part of our {aqua}Magic{snow} too!");
			case 11: Twirl_Lines(npc, "Dance little merc, dance...");
			case 13: Twirl_Lines(npc, "{crimson}Ehe{snow}.");
			case 15: Twirl_Lines(npc, "Annihilation in {crimson}F# {snow}Minor");
			case 17: Twirl_Lines(npc, "Oh, {crimson}poor{snow} you...");
		}
	}

	float flPos[3], flAng[3];
	npc.GetAttachment("effect_hand_r", flPos, flAng);
	int ent1 = ParticleEffectAt_Parent(flPos, "raygun_projectile_blue_crit", npc.index, "effect_hand_r", {0.0,0.0,0.0});
	npc.GetAttachment("effect_hand_l", flPos, flAng);
	int ent2 = ParticleEffectAt_Parent(flPos, "raygun_projectile_red_crit", npc.index, "effect_hand_l", {0.0,0.0,0.0});
	if(IsValidEntity(ent1) && IsValidEntity(ent2))
	{
		i_lunar_entities[npc.index][0] = EntIndexToEntRef(ent1);
		i_lunar_entities[npc.index][1] = EntIndexToEntRef(ent2);
		int color[4];
		Ruina_Color(color, i_current_wave[npc.index]);
		int laser = ConnectWithBeamClient(ent1, ent2, color[0], color[1], color[2], 5.0, 5.0, 1.0, LASERBEAM);
		if(IsValidEntity(laser))
		{
			i_lunar_entities[npc.index][2] = EntIndexToEntRef(laser);
		}
	}
	else
	{
		if(IsValidEntity(ent1))
			RemoveEntity(ent1);
		if(IsValidEntity(ent2))
			RemoveEntity(ent2);
	}

	

	npc.m_flLunarThrottle = GameTime + 0.5;
	fl_ruina_battery_timeout[npc.index] = GameTime + 2.5;
	npc.m_flDoingAnimation = GameTime + 2.5;

	SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
	SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 1);

	npc.m_flLunarTimer = 0.0;
	npc.m_bisWalking = false;
	npc.AddActivityViaSequence("taunt_surgeons_squeezebox");
	npc.SetPlaybackRate(0.7);
	npc.SetCycle(0.01);

	npc.m_iLunarAmmo = 0;

	npc.m_flSpeed = 0.0;
	
	SDKUnhook(npc.index, SDKHook_Think, Lunar_Radiance_Tick);
	SDKHook(npc.index, SDKHook_Think, Lunar_Radiance_Tick);
}
static Action Lunar_Radiance_RestoreAnim(Handle Timer, int ref)
{
	int iNPC = EntRefToEntIndex(ref);
	if(!IsValidEntity(iNPC))
		return Plugin_Stop;
	
	Twirl npc = view_as<Twirl>(iNPC);

	float GameTime = GetGameTime(npc.index);

	npc.m_iState = 0;
	npc.m_flNextMeleeAttack = GameTime + 0.5;
	npc.m_flReloadIn = GameTime + 0.5;
	npc.m_fbGunout = true;
	SetVariantInt(npc.i_weapon_type());
	AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");

	SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
	SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 255);

	npc.m_flSpeed = fl_npc_basespeed;
	npc.StartPathing();

	if(npc.m_iChanged_WalkCycle != 99)
	{
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		npc.m_bisWalking = true;
		npc.m_iChanged_WalkCycle = 1;
		if(iActivity > 0) npc.StartActivity(iActivity);
	}

	return Plugin_Stop;
}
static void Lunar_Radiance_Tick(int iNPC)
{
	Twirl npc = view_as<Twirl>(iNPC);

	float GameTime = GetGameTime(npc.index);

	if(npc.m_flLunarThrottle > GameTime)
		return;

	if(npc.m_flLunarLoop < GameTime)
	{
		npc.m_flLunarLoop = FAR_FUTURE;
		EmitSoundToAll("player/taunt_surgeons_squeezebox_music.wav", npc.index, SNDCHAN_STATIC, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL);
	}

	npc.m_flLunarThrottle = GameTime + 0.1;

	fl_ruina_battery_timeout[npc.index] = GameTime + 2.0;
	npc.m_flDoingAnimation = GameTime + 2.0;

	int amt = i_Lunar_RadianceAmt(npc);

	if(npc.m_iLunarAmmo > amt)
	{
		npc.m_iLunarAmmo = 0;
		npc.m_flLunarTimer = GameTime + (npc.Anger ? 55.0 : 75.0);
		if(b_tripple_raid)
			npc.m_flLunarTimer = GameTime + (npc.Anger ? 60.0 : 90.0);

		StopSound(npc.index, SNDCHAN_STATIC, "player/taunt_surgeons_squeezebox_music.wav");

		fl_ruina_battery_timeout[npc.index] = GameTime + 0.6;
		npc.m_flDoingAnimation = GameTime + 0.6;

		CreateTimer(0.6, Lunar_Radiance_RestoreAnim, EntIndexToEntRef(npc.index), TIMER_FLAG_NO_MAPCHANGE);

		if(npc.m_iChanged_WalkCycle != 99)
		{
			npc.AddActivityViaSequence("taunt_surgeons_squeezebox_outro");
			npc.SetPlaybackRate(1.0);	
			npc.SetCycle(0.01);
		}

		for(int i= 0 ; i < 3 ; i ++)
		{
			int ent = EntRefToEntIndex(i_lunar_entities[npc.index][i]);
			if(IsValidEntity(ent))
				RemoveEntity(ent);

			i_lunar_entities[npc.index][i] = INVALID_ENT_REFERENCE;
		}

		SDKUnhook(npc.index, SDKHook_Think, Lunar_Radiance_Tick);

		return;
	}

	if(npc.m_flLunarTimer > GameTime)
		return;

	npc.m_flLunarTimer = GameTime + fl_Lunar_RadianceTimer(npc);

	npc.m_iLunarAmmo +=1;

	UnderTides npcGetInfo = view_as<UnderTides>(npc.index);
	int enemy_2[RAIDBOSS_GLOBAL_ATTACKLIMIT]; 
	//It should target upto 20 people only, if its anymore it starts becomming un dodgeable due to the nature of AOE laser attacks
	GetHighDefTargets(npcGetInfo, enemy_2, sizeof(enemy_2), false, false);
	int i_te_used = 0;
	for(int i; i < sizeof(enemy_2); i++)
	{
		if(enemy_2[i])
		{
			//the actual amount of TE created is less then 9, doing 9 will allow for a bit of room just incase.
			i_te_used+=9;
			float Radius = (npc.Anger ? 225.0 : 150.0);
			float dmg = Modify_Damage(-1, 12.0);
			if(i_te_used > 31)
			{
				int DelayFrames = (i_te_used / 32);
				DelayFrames *= 2;
				DataPack pack_TE = new DataPack();
				pack_TE.WriteCell(EntIndexToEntRef(npc.index));
				pack_TE.WriteCell(EntIndexToEntRef(enemy_2[i]));
				pack_TE.WriteFloat(dmg);
				pack_TE.WriteFloat(Radius);
				pack_TE.WriteFloat(GameTime);
				RequestFrames(Twirl_DelayIons, DelayFrames, pack_TE);
				//Game cannot send more then 31 te's in the same frame, a fix is too just delay it.
			}
			else
			{
				npc.Predictive_Ion(enemy_2[i], (npc.Anger ? 1.4 : 1.8), Radius, dmg);
			}
		}
	}
}
static void Twirl_DelayIons(DataPack pack)
{
	pack.Reset();
	int iNPC = EntRefToEntIndex(pack.ReadCell());
	int Target = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidEntity(iNPC))
	{
		delete pack;
		return;
	}
	Twirl npc = view_as<Twirl>(iNPC);
	if(!IsValidEnemy(npc.index, Target))
	{
		delete pack;
		return;
	}
	float dmg = pack.ReadFloat();
	float Radius = pack.ReadFloat();
	float time = (pack.ReadFloat() - GetGameTime(npc.index)) + (npc.Anger ? 1.4 : 1.8);	//get the difference in time from how long this attack was delayed. so it matches up timing wise with other ions!
	npc.Predictive_Ion(Target, time, Radius, dmg);
	delete pack;
}

static bool KeepDistance(Twirl npc, float flDistanceToTarget, int PrimaryThreatIndex, float Distance)
{
	bool backing_up = false;
	if(flDistanceToTarget < Distance  && npc.m_fbGunout)
	{
		int Enemy_I_See;
			
		Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
		//Target close enough to hit
		if(IsValidEnemy(npc.index, Enemy_I_See)) //Check if i can even see.
		{
			if(flDistanceToTarget < (Distance*0.9))
			{
				Ruina_Runaway_Logic(npc.index, PrimaryThreatIndex);
				npc.m_bAllowBackWalking=true;
				backing_up = true;
			}
			else
			{
				npc.StopPathing();
				
				npc.m_bAllowBackWalking=false;
			}
		}
		else
		{
			npc.StartPathing();
			
			npc.m_bAllowBackWalking=false;
		}		
	}
	else
	{
		npc.StartPathing();
		
		npc.m_bAllowBackWalking=false;
	}

	return backing_up;
}
static float fl_self_defense_multiattack_speed(Twirl npc)
{
	float speed = (npc.Anger ? 0.2 : 0.4);
	return speed;
}
static void Self_Defense(Twirl npc, float flDistanceToTarget, int PrimaryThreatIndex, float vecTarget[3])
{
	float GameTime = GetGameTime(npc.index);

	if(npc.m_fbGunout)
	{
		//enemy is too far
		if(flDistanceToTarget > (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 15.0))	
		{
			if(npc.m_flReloadIn < GameTime)	//might as well check if we are done reloading so our "clip" is refreshed
				npc.m_iState = 0;

			return;
		}
			
		//we are "reloading", so keep distance.
		if(npc.m_flReloadIn > GameTime)
		{
			KeepDistance(npc, flDistanceToTarget, PrimaryThreatIndex, GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 7.5);
			npc.m_flSpeed = fl_npc_basespeed*RUINA_BACKWARDS_MOVEMENT_SPEED_PENALTY;	
			npc.FaceTowards(vecTarget, RUINA_FACETOWARDS_BASE_TURNSPEED*2.0);
			return;
		}

		int Enemy_I_See;	
		Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
		//I cannot see the target.
		if(!IsValidEnemy(npc.index, Enemy_I_See))
			return;
		//our special multi attack is still recharging
		if(fl_multi_attack_delay[npc.index] > GameTime)
			return;

		float	Multi_Delay = fl_self_defense_multiattack_speed(npc),
				Reload_Delay = (npc.Anger ? 2.0 : 4.0);
		
		if(npc.m_iState >= npc.m_iRangedAmmo)	//"ammo"
		{
			npc.m_iState = 0;
			npc.m_flReloadIn = GameTime + Reload_Delay;	//"reload" time
		}
		else
		{
			npc.m_iState++;
		}
				
		fl_multi_attack_delay[npc.index] = GameTime + Multi_Delay;

		fl_ruina_in_combat_timer[npc.index]=GameTime+5.0;

		npc.FaceTowards(vecTarget, 100000.0);
		npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
		npc.PlayRangeAttackSound();

		float 	flPos[3], // original
				flAng[3]; // original
			
		GetAttachment(npc.index, "effect_hand_r", flPos, flAng);

		float target_vec[3];
		WorldSpaceCenter(PrimaryThreatIndex, target_vec);

		float Dmg = 21.0;
		char Particle[50];
		if(npc.m_iState % 2)
			Particle = "raygun_projectile_blue";
		else
			Particle = "raygun_projectile_red";

		float start_speed = 50.0;

		float Ang[3];
		MakeVectorFromPoints(flPos, target_vec, Ang);
		GetVectorAngles(Ang, Ang);

		Ruina_Projectiles Projectile;
		Projectile.iNPC = npc.index;
		Projectile.Start_Loc = flPos;
		Projectile.Angles = Ang;
		Projectile.speed = start_speed;
		Projectile.radius = 0.0;
		Projectile.damage = Modify_Damage(-1, Dmg);
		Projectile.bonus_dmg = Modify_Damage(-1, Dmg)*2.5;
		Projectile.Time = 5.0;
		Projectile.visible = false;
		int projectile = Projectile.Launch_Projectile(FuncTwirlParticleRocketTouch);
		Projectile.Apply_Particle(Particle);

		if(IsValidEntity(projectile))
			Initiate_Projectile_ParticleAccelerator(npc, projectile, PrimaryThreatIndex);
	}
	else
	{
		float Swing_Speed = (npc.Anger ? 1.0 : 2.0);
		float Swing_Delay = (npc.Anger ? 0.1 : 0.2);

		if(npc.m_flAttackHappens)
		{
			if(npc.m_flAttackHappens < GameTime)
			{
				npc.m_flAttackHappens = 0.0;

				npc.m_flRetreatTimer = GameTime+(Swing_Speed*0.35);

				Handle swingTrace;
				float VecEnemy[3]; WorldSpaceCenter(PrimaryThreatIndex, VecEnemy);
				npc.FaceTowards(VecEnemy, 15000.0);
				if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex))
				{	
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);

					if(IsValidEnemy(npc.index, target))
					{
						if(npc.Add_Combo(10))
						{
							float Radius = (npc.Anger ? 225.0 : 150.0);
							float dmg = 75.0;
							dmg *= RaidModeScaling;
							npc.Predictive_Ion(target, (npc.Anger ? 1.0 : 1.5), Radius, dmg);
						}
			
						SDKHooks_TakeDamage(target, npc.index, npc.index, Modify_Damage(target, 40.0), DMG_CLUB, -1, _, vecHit);

						Ruina_Add_Battery(npc.index, 250.0);
						
						if(!b_test_mode)	//while testing the kb is annoying *Who would have guessed*
						{
							float Kb = (npc.Anger ? 900.0 : 450.0);

							Custom_Knockback(npc.index, target, Kb, true);
							if(target <= MaxClients)
							{
								TF2_AddCondition(target, TFCond_LostFooting, 0.5);
								TF2_AddCondition(target, TFCond_AirCurrent, 0.5);
							}
						}
						Ruina_Add_Mana_Sickness(npc.index, target, 0.2, RoundToNearest(Modify_Damage(target, 7.0)));
					}
					npc.PlayMeleeHitSound();
					
				}
				delete swingTrace;
			}
		}
		else
		{
			if(npc.m_flRetreatTimer > GameTime || (flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*2.0 && npc.m_flNextMeleeAttack > GameTime))
			{
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, PrimaryThreatIndex,_,vBackoffPos);
				npc.SetGoalVector(vBackoffPos, true);
				npc.FaceTowards(vecTarget, 20000.0);
				npc.m_flSpeed =  fl_npc_basespeed*RUINA_BACKWARDS_MOVEMENT_SPEED_PENALTY;
			}
		}

		if(npc.m_flNextMeleeAttack < GameTime && flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*1.25))	//its a lance so bigger range
		{
			int Enemy_I_See;
									
			Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				fl_ruina_in_combat_timer[npc.index]=GameTime+5.0;
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
				npc.m_flAttackHappens = GameTime + Swing_Delay;
				npc.m_flNextMeleeAttack = GameTime + Swing_Speed;
			}
		}
	}
}
static void FuncTwirlParticleRocketTouch(int entity, int other)
{
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if(!IsValidEntity(owner))	//owner is invalid, evacuate.
	{
		Ruina_Remove_Projectile(entity);
		return;
	}

	float ProjectileLoc[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);

	if(fl_ruina_Projectile_radius[entity]>0.0)
	{
		Explode_Logic_Custom(fl_ruina_Projectile_dmg[entity] , owner , owner , -1 , ProjectileLoc , fl_ruina_Projectile_radius[entity] , _ , _ , true, _,_, fl_ruina_Projectile_bonus_dmg[entity]);
		TE_Particle(fl_BEAM_DurationTime[entity] % 2 ? "spell_batball_impact_blue" : "spell_batball_impact_red", ProjectileLoc, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
	}
	else
	{
		float dmg = fl_ruina_Projectile_dmg[entity];

		if(ShouldNpcDealBonusDamage(other))
			dmg *=fl_ruina_Projectile_bonus_dmg[entity];

		SDKHooks_TakeDamage(other, owner, owner, dmg, DMG_PLASMA|DMG_PREVENT_PHYSICS_FORCE, -1, _, ProjectileLoc);
	}
	
	Ruina_Remove_Projectile(entity);
}
//makes a projectile accelerate from slow speeds to really high speeds in 1 second.
static float fl_projectile_acceleration_time = 0.75;
static void Initiate_Projectile_ParticleAccelerator(Twirl npc, int projectile, int PrimaryThreatIndex)
{
	float GameTime = GetGameTime();
	fl_BEAM_ChargeUpTime[projectile] = GameTime + fl_projectile_acceleration_time;

	fl_BEAM_DurationTime[projectile] = float(npc.m_iState);

	float 	Homing_Power = 3.0,
			Homing_Lockon = 80.0;

	float angles[3];
	GetEntPropVector(projectile, Prop_Data, "m_angRotation", angles);

	Initiate_HomingProjectile(projectile,
	npc.index,
	Homing_Lockon,			// float lockonAngleMax,
	Homing_Power,			// float homingaSec,
	true,				// bool LockOnlyOnce,
	true,					// bool changeAngles,
	angles,
	PrimaryThreatIndex
	);

	SDKHook(projectile, SDKHook_Think, Projectile_ParticleCannonThink);
	SDKHook(projectile, SDKHook_ThinkPost, ProjectileBaseThinkPost);

}
static Action Projectile_ParticleCannonThink(int entity)
{
	float GameTime = GetGameTime();
	float speed = 375.0;	//this is a magical number that reults in 3k speed in at the end of the formula.
	//projectile acceleration is complete, kill the think hook

	float Angles[3]; GetRocketAngles(entity, Angles);
	if(fl_BEAM_ChargeUpTime[entity] < GameTime)
	{
		ReplaceProjectileParticle(entity, fl_BEAM_DurationTime[entity] % 2 ? "drg_manmelter_trail_blue" : "drg_manmelter_trail_red");
		HomingProjectile_SetProjectileSpeed(entity, 3000.0);
		SetProjectileSpeed(entity, 3000.0, Angles);
		//CPrintToChatAll("killed proj hook");
		SDKUnhook(entity, SDKHook_Think, Projectile_ParticleCannonThink);
		HomingProjectile_Deactivate(entity);	//also kill homing

		//make the projectile deal AOE once its fully speed up.

		fl_ruina_Projectile_dmg[entity] *=1.1;
		fl_ruina_Projectile_radius[entity] = 300.0;

		return Plugin_Stop;
	}
	float Ratio = 1.0 - (fl_BEAM_ChargeUpTime[entity] - GameTime) / fl_projectile_acceleration_time;
	float Original = Ratio;

	//make it start out slower
	Ratio *= 0.25;
	if(Original > 0.75)
		Ratio *= 4.0;//then omega buff it
	
	float CalcRatio = (1.0+Ratio);	//when the math isn't math-ing, same issue I had with stella, UGH
	float projectile_speed = speed * (CalcRatio*CalcRatio*CalcRatio);

	//CPrintToChatAll("speed: %.1f",projectile_speed);

	HomingProjectile_SetProjectileSpeed(entity, projectile_speed);
	SetProjectileSpeed(entity, projectile_speed, Angles);
	return Plugin_Continue;
}
//since homing only sets speeds every 0.1s and this is a every tick operation, in some instances the projectile will have uneven acceleration, and even won't accelerate fully.
//as such, we need to also manually set the speed real time every tick.
static void SetProjectileSpeed(int projectile, float speed, float angles[3])
{
	float forward_direction[3];
	GetAngleVectors(angles, forward_direction, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(forward_direction, speed);
	TeleportEntity(projectile, NULL_VECTOR, NULL_VECTOR, forward_direction);
}
static void ReplaceProjectileParticle(int projectile, const char[] particle_string)
{
	int particle = EntRefToEntIndex(i_rocket_particle[projectile]);
	if(IsValidEntity(particle))
		RemoveEntity(particle);

	float ProjLoc[3];
	WorldSpaceCenter(projectile, ProjLoc);
	particle = ParticleEffectAt(ProjLoc, particle_string, 0.0); //Inf duartion
	i_rocket_particle[projectile]= EntIndexToEntRef(particle);
	SetParent(projectile, particle);	
}

static float Modify_Damage(int Target, float damage)
{
	if(ShouldNpcDealBonusDamage(Target))
		damage*=10.0;

	damage*=RaidModeScaling;

	return damage;
}
static float fl_cosmic_gaze_range = 1500.0;
static float fl_cosmic_gaze_radius = 750.0;
static void Cosmic_Gaze(Twirl npc, int Target)
{
	if(i_current_wave[npc.index]<=20)
		return;

	float GameTime = GetGameTime(npc.index);
	if(fl_ruina_battery_timeout[npc.index] > GameTime)
		return;

	if(npc.m_flCosmicGazeTimer > GameTime)
		return;

	int Enemy_I_See;
			
	Enemy_I_See = Can_I_See_Enemy(npc.index, Target);
	//Target close enough to hit
	if(!IsValidEnemy(npc.index, Enemy_I_See)) //Check if i can even see.
		return;

	Target = Enemy_I_See;

	EmitSoundToAll("ui/rd_2base_alarm.wav");

	npc.m_iState = 0;
	npc.m_flNextMeleeAttack = GameTime + 0.5;
	npc.m_flReloadIn = GameTime + 0.5;
	npc.m_fbGunout = true;
	SetVariantInt(npc.i_weapon_type());
	AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");

	SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
	SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 255);

	float Windup = 2.0;
	float Duration;
	float Baseline = 1.75;

	float Ratio = (Baseline/Windup);

	float anim_ratio = Ratio;
	Duration = 1.3 * (Windup/Baseline);

	npc.m_bisWalking = false; 
	npc.m_flDoingAnimation = GameTime + Duration + Windup + 0.2;
	fl_ruina_battery_timeout[npc.index] = GameTime + Duration +Windup;
	npc.m_flCosmicGazeWindUp = GameTime + Windup;

	npc.m_flCosmicGazeActive = fl_ruina_battery_timeout[npc.index];

	npc.m_bAnimationSet = false;
	npc.m_flCosmicGazeThrottle = 0.0;
	
	npc.AddActivityViaSequence("taunt08");
	npc.SetPlaybackRate(1.36*anim_ratio);	
	npc.SetCycle(0.01);

	float VecTarget[3]; WorldSpaceCenter(Target, VecTarget);
	npc.FaceTowards(VecTarget, 10000.0);

	npc.StopPathing();
	

	npc.m_flSpeed = 0.0;

	float Angles[3], Start[3];
	WorldSpaceCenter(npc.index, Start);
	GetEntPropVector(npc.index, Prop_Data, "m_angRotation", Angles);
	int iPitch = npc.LookupPoseParameter("body_pitch");
		
	float flPitch = npc.GetPoseParameter(iPitch);

	flPitch *= -1.0;
	if(flPitch>15.0)
		flPitch=15.0;
	if(flPitch <-15.0)
		flPitch = -15.0;
	Angles[0] = flPitch;
	Ruina_Laser_Logic Laser;
	Laser.client = npc.index;
	Laser.DoForwardTrace_Custom(Angles, Start, fl_cosmic_gaze_range);
	float EndLoc[3];
	EndLoc = Laser.End_Point;

	npc.m_flCosmicGazeDistance = GetVectorDistance(EndLoc, Start);
	float Thickness = 15.0;
	int color[4]; Ruina_Color(color, i_current_wave[npc.index]);
	TE_SetupBeamRingPoint(EndLoc, fl_cosmic_gaze_radius*2.0, 0.0, g_Ruina_BEAM_Combine_Black, g_Ruina_HALO_Laser, 0, 1, (Duration + Windup-0.75), Thickness, 1.5, color, 1, 0);
	TE_SendToAll();
	TE_SetupBeamRingPoint(EndLoc, fl_cosmic_gaze_radius*2.0, fl_cosmic_gaze_radius*2.0+0.1, g_Ruina_BEAM_Combine_Black, g_Ruina_HALO_Laser, 0, 1, (Duration + Windup-0.75), Thickness, 1.5, color, 1, 0);
	TE_SendToAll();

	SDKUnhook(npc.index, SDKHook_Think, Cosmic_Gaze_Tick);
	SDKHook(npc.index, SDKHook_Think, Cosmic_Gaze_Tick);
}
static Action Cosmic_Gaze_Tick(int iNPC)
{
	Twirl npc = view_as<Twirl>(iNPC);
	float GameTime = GetGameTime(npc.index);
	if(fl_ruina_battery_timeout[npc.index] < GameTime)
	{
		npc.m_flCosmicGazeTimer = GameTime + (npc.Anger ? 45.0 : 60.0);
		if(b_tripple_raid)
			npc.m_flCosmicGazeTimer = GameTime + (npc.Anger ? 60.0 : 90.0);
		SDKUnhook(npc.index, SDKHook_Think, Cosmic_Gaze_Tick);
		f_NpcTurnPenalty[npc.index] = 1.0;
		npc.m_flSpeed = fl_npc_basespeed;
		npc.StartPathing();

		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		npc.m_bisWalking = true;
		npc.m_iChanged_WalkCycle = 1;
		if(iActivity > 0) npc.StartActivity(iActivity);

		return Plugin_Stop;
	}

	bool tick = false;
	if(npc.m_flCosmicGazeThrottle < GameTime)
	{
		tick = true;
	}

	npc.m_iState = 0;
	npc.m_flNextMeleeAttack = GameTime + 0.5;
	npc.m_flReloadIn = GameTime + 0.5;
	npc.m_fbGunout = true;

	if(npc.m_flCosmicGazeWindUp < GameTime)
	{
		if(!npc.m_bAnimationSet)
		{
			npc.SetPlaybackRate(0.25);

			EmitSoundToAll(g_DefaultLaserLaunchSound[GetRandomInt(0, sizeof(g_DefaultLaserLaunchSound) - 1)], npc.index, SNDCHAN_STATIC, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL);
			EmitSoundToAll(g_DefaultLaserLaunchSound[GetRandomInt(0, sizeof(g_DefaultLaserLaunchSound) - 1)], npc.index, SNDCHAN_STATIC, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL);

			EmitSoundToAll(TWIRL_COSMIC_GAZE_LOOP_SOUND1, npc.index, SNDCHAN_STATIC, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL);
			EmitSoundToAll(TWIRL_COSMIC_GAZE_LOOP_SOUND1, npc.index, SNDCHAN_STATIC, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL);
			
			npc.m_bAnimationSet = true;

			npc.m_flCosmicGazeDurationOffset = GameTime + 0.72;
		}
		if(npc.m_flCosmicGazeDurationOffset > GameTime && npc.m_flCosmicGazeDurationOffset !=FAR_FUTURE)
		{
			float Angles[3], Start[3];
			WorldSpaceCenter(npc.index, Start);
			GetEntPropVector(npc.index, Prop_Data, "m_angRotation", Angles);
			int iPitch = npc.LookupPoseParameter("body_pitch");
				
			float flPitch = npc.GetPoseParameter(iPitch);

			flPitch *= -1.0;
			if(flPitch>15.0)
				flPitch=15.0;
			if(flPitch <-15.0)
				flPitch = -15.0;
			Angles[0] = flPitch;

			float	EndLoc[3],
					Radius = 30.0,
					diameter = Radius*2.0;

			if(tick)
			{
				Ruina_Laser_Logic Laser;
				Laser.client = npc.index;
				
				float Eye_Loc[3];
				WorldSpaceCenter(npc.index, Eye_Loc);
				
				Laser.DoForwardTrace_Custom(Angles, Eye_Loc, fl_cosmic_gaze_range);
				
				EndLoc = Laser.End_Point;

				Laser.Radius = Radius;
				Laser.damagetype = DMG_PLASMA;
				Laser.Damage = Modify_Damage(-1, 35.0);
				Laser.Bonus_Damage = Modify_Damage(-1, 60.0);
				Laser.Deal_Damage(On_LaserHit);

				npc.m_flCosmicGazeDistance = GetVectorDistance(EndLoc, Start);	
			}
			Get_Fake_Forward_Vec(npc.m_flCosmicGazeDistance, Angles, EndLoc, Start);

			float 	flPos[3], // original
					flAng[3]; // original
			
			GetAttachment(npc.index, "effect_hand_r", flPos, flAng);

			float TE_Duration = 0.1;

			int color[4]; Ruina_Color(color, i_current_wave[npc.index]);

			float Offset_Loc[3];
			Get_Fake_Forward_Vec(100.0, Angles, Offset_Loc, flPos);

			int colorLayer4[4];
			SetColorRGBA(colorLayer4, color[0], color[1], color[2], color[1]);
			int colorLayer3[4];
			SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, color[3]);
			int colorLayer2[4];
			SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, color[3]);
			int colorLayer1[4];
			SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 7255 / 8, colorLayer4[1] * 5 + 7255 / 8, colorLayer4[2] * 5 + 7255 / 8, color[3]);

			float 	Rng_Start = GetRandomFloat(diameter*0.5, diameter*0.7);

			float 	Start_Diameter1 = ClampBeamWidth(Rng_Start*0.7),
					Start_Diameter2 = ClampBeamWidth(Rng_Start*0.9),
					Start_Diameter3 = ClampBeamWidth(Rng_Start);
				
			float 	End_Diameter1 = ClampBeamWidth(diameter*0.7),
					End_Diameter2 = ClampBeamWidth(diameter*0.9),
					End_Diameter3 = ClampBeamWidth(diameter);

			int Beam_Index = g_Ruina_BEAM_Combine_Black;

			TE_SetupBeamPoints(flPos, Offset_Loc, Beam_Index, 	0, 0, 66, TE_Duration, 0.0, Start_Diameter1, 0, 10.0, colorLayer2, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(flPos, Offset_Loc, Beam_Index, 	0, 0, 66, TE_Duration, 0.0, Start_Diameter2, 0, 10.0, colorLayer3, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(flPos, Offset_Loc, Beam_Index,	0, 0, 66, TE_Duration, 0.0, Start_Diameter3, 0, 10.0, colorLayer4, 3);
			TE_SendToAll(0.0);

			TE_SetupBeamPoints(Offset_Loc, EndLoc, Beam_Index, 	0, 0, 66, TE_Duration, Start_Diameter1*0.9, End_Diameter1, 0, 0.1, colorLayer2, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(Offset_Loc, EndLoc, Beam_Index, 	0, 0, 66, TE_Duration, Start_Diameter2*0.9, End_Diameter2, 0, 0.1, colorLayer3, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(Offset_Loc, EndLoc, Beam_Index, 	0, 0, 66, TE_Duration, Start_Diameter3*0.9, End_Diameter3, 0, 0.1, colorLayer4, 3);
			TE_SendToAll(0.0);

			Get_Fake_Forward_Vec(-50.0, Angles, Offset_Loc, EndLoc);

			TE_SetupGlowSprite(Offset_Loc, gGlow1, TE_Duration, 3.0, 255);
			TE_SendToAll();

		}
		else if(npc.m_flCosmicGazeDurationOffset != FAR_FUTURE)
		{
			npc.m_flCosmicGazeDurationOffset = FAR_FUTURE;
			npc.SetPlaybackRate(1.36*0.72);

			Ruina_Laser_Logic Laser;
			Laser.client = npc.index;
			float Angles[3], Start[3];
			WorldSpaceCenter(npc.index, Start);
			GetEntPropVector(npc.index, Prop_Data, "m_angRotation", Angles);
			int iPitch = npc.LookupPoseParameter("body_pitch");
				
			float flPitch = npc.GetPoseParameter(iPitch);
			if(flPitch>15.0)
				flPitch=15.0;
			if(flPitch <-15.0)
				flPitch = -15.0;
			flPitch *= -1.0;
			Angles[0] = flPitch;
			Laser.DoForwardTrace_Custom(Angles, Start, fl_cosmic_gaze_range);
			float EndLoc[3];
			EndLoc = Laser.End_Point;

			Do_Cosmic_Gaze_Explosion(npc.index, EndLoc);
		}
	}
	return Plugin_Continue;
}
static void Do_Cosmic_Gaze_Explosion(int client, float Loc[3])
{
	float Radius = fl_cosmic_gaze_radius;

	int create_center = Ruina_Create_Entity(Loc, 3.0, true);

	if(IsValidEntity(create_center))
	{
		i_haloslot[client] = EntIndexToEntRef(create_center);
	}

	int color[4]; Ruina_Color(color, i_current_wave[client]);

	float Time = 0.25;
	float Thickness = 10.0;

	float Offset_Loc[3]; Offset_Loc = Loc;
	
	Loc[2]+=Thickness*0.5;

	TE_SetupBeamRingPoint(Loc, Radius*2.0+1.0, Radius*2.0, g_Ruina_BEAM_Combine_Black, g_Ruina_HALO_Laser, 0, 1, 3.0, Thickness, 1.5, color, 1, 0);
	TE_SendToAll();

	StopSound(client, SNDCHAN_STATIC, TWIRL_COSMIC_GAZE_LOOP_SOUND1);
	StopSound(client, SNDCHAN_STATIC, TWIRL_COSMIC_GAZE_LOOP_SOUND1);

	EmitSoundToAll(TWIRL_COSMIC_GAZE_END_SOUND1);
	
	int loop_for = GetRandomInt(4, 7);
	for(int i=0 ; i < loop_for ; i++)
	{	
		float Random_Loc[3];
		float Ang[3]; Ang[1] = (360.0/loop_for)*i+GetRandomFloat(-(360.0/loop_for)*0.25, (360.0/loop_for)*0.25);	//what in the fuck did I create here?
		float Dist = GetRandomFloat(Radius*0.4, Radius*0.75);
		Get_Fake_Forward_Vec(Dist, Ang, Random_Loc, Offset_Loc);
		Ruina_Proper_To_Groud_Clip({24.0,24.0,24.0}, 300.0, Random_Loc);
		float Sky_Loc[3]; Sky_Loc = Random_Loc; Sky_Loc[2]+=9999.0;
		TE_SetupBeamPoints(Random_Loc, Sky_Loc, g_Ruina_BEAM_Combine_Black, g_Ruina_HALO_Laser, 0, 66, Time*i+2.5, 5.0*Thickness, Thickness*0.25, 10, 0.1, color, 10);
		TE_SendToAll(i/10.0);
		float Radius_Ratio = 1.0 - (Dist/Radius);
		TE_SetupBeamRingPoint(Random_Loc, 0.0, (Radius_Ratio*Radius)*2.0, g_Ruina_BEAM_Combine_Black, g_Ruina_HALO_Laser, 0, 1, Time+0.5, Thickness, 1.0, color, 1, 0);
		TE_SendToAll(i/10.0);

		DataPack explosion;
		CreateDataTimer(i/10.0, Delayed_Explosion, explosion, TIMER_FLAG_NO_MAPCHANGE);
		explosion.WriteCell(EntIndexToEntRef(client));
		explosion.WriteFloatArray(Random_Loc, 3);
		explosion.WriteFloat((Radius_Ratio*Radius));

		char SoundString[255];
		SoundString = TWIRL_THUMP_SOUND;
		DataPack data;
		CreateDataTimer(i/10.0, Timer_Repeat_Sound, data, TIMER_FLAG_NO_MAPCHANGE);
		data.WriteString(SoundString);
		data.WriteCell(2);
		data.WriteFloat(1.0);
		data.WriteFloatArray(Random_Loc, 3);

		TE_SetupGlowSprite(Random_Loc, gGlow1, Time*i+2.5, 0.5, 255);
		TE_SendToAll(i/10.0);

	}
}
static Action Delayed_Explosion(Handle Timer, DataPack data)
{
	data.Reset();
	int iNPC = EntRefToEntIndex(data.ReadCell());
	float Loc[3];
	data.ReadFloatArray(Loc, 3);
	float Radius = data.ReadFloat();

	if(!IsValidEntity(iNPC))
		return Plugin_Stop;

	int creater = EntRefToEntIndex(i_haloslot[iNPC]);

	if(IsValidEntity(creater))
	{
		int Beam_Index = g_Ruina_BEAM_Diamond;	

		int color[4]; Ruina_Color(color, i_current_wave[iNPC]);

		int create_center = Ruina_Create_Entity(Loc, 1.0, true);

		if(IsValidEntity(create_center))
		{
			TE_SetupBeamRing(creater, create_center, Beam_Index, g_Ruina_HALO_Laser, 0, 10, 0.75, 7.5, 1.0, color, 10, 0);	
			TE_SendToAll(0.0);
		}
	}

	Explode_Logic_Custom(Modify_Damage(-1, 60.0), iNPC, iNPC, -1, Loc, Radius, _, _, true, _, false, _, Cosmic_Gaze_Boom_OnHit);

	return Plugin_Stop;
}
static Action Timer_Repeat_Sound(Handle Timer, DataPack data)
{
	ResetPack(data);
	char Sound[255];
	data.ReadString(Sound, sizeof(Sound));
	int type = data.ReadCell();
	float Volume = data.ReadFloat();

	switch(type)
	{
		case 1:
		{
			EmitSoundToAll(Sound, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, Volume, SNDPITCH_NORMAL);
		}
		case 2:
		{
			float Loc[3];
			data.ReadFloatArray(Loc, 3);
			EmitSoundToAll(Sound, 0, SNDCHAN_AUTO, 120, SND_NOFLAGS, Volume, SNDPITCH_NORMAL, -1, Loc);
		}
		default:
		{
			EmitSoundToAll(Sound, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, Volume, SNDPITCH_NORMAL);
		}
	}

	return Plugin_Stop;
}
static void Cosmic_Gaze_Boom_OnHit(int entity, int victim, float damage, int weapon)
{
	if(IsValidClient(victim))
		Client_Shake(victim, 0, 7.5, 7.5, 3.0);
}
static int i_Fractal_Gram_Amt(Twirl npc)
{
	int amt = (npc.Anger ? 20 : 10);
	if(b_force_transformation)
		amt = 40;

	return amt;
}
static float fl_Fractal_Gram_SpamTimer(Twirl npc)
{
	float timer = (npc.Anger ? 0.2 : 0.4);
	if(b_force_transformation)
		timer = 0.1;
	return timer;
}
static void Fractal_Gram(Twirl npc, int Target)
{
	if(i_current_wave[npc.index]<=10)
		return;

	float GameTime = GetGameTime(npc.index);
	if(npc.m_flNextRangedBarrage_Spam > GameTime)
		return;
	
	if(npc.m_flNextRangedBarrage_Singular > GameTime)
		return;

	if(fl_ruina_battery_timeout[npc.index] > GameTime)
		return;

	int amt = i_Fractal_Gram_Amt(npc);

	if(npc.m_iBarrageAmmo > amt)
	{
		if(IsValidEntity(npc.m_iWearable1))
		{
			SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 255);
		}
		npc.m_iBarrageAmmo = 0;
		npc.m_flNextRangedBarrage_Spam = GameTime + (npc.Anger ? 25.0 : 30.0);
		if(b_tripple_raid)
			npc.m_flNextRangedBarrage_Spam = GameTime + (npc.Anger ? 45.0 : 60.0);
		return;
	}

	int Enemy_I_See;
			
	Enemy_I_See = Can_I_See_Enemy(npc.index, Target);
	//Target close enough to hit
	if(!IsValidEnemy(npc.index, Enemy_I_See)) //Check if i can even see.
	{
		if(IsValidEntity(npc.m_iWearable1))
		{
			SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 255);
		}
		return;
	}
		

	npc.PlayFractalSound();

	npc.m_flNextMeleeAttack = GameTime + 1.0;
	npc.m_flReloadIn = GameTime + 1.0;

	Target = Enemy_I_See;

	npc.m_iBarrageAmmo++;

	npc.m_flNextRangedBarrage_Singular = GameTime + fl_Fractal_Gram_SpamTimer(npc);

	npc.AddGesture("ACT_MP_GESTURE_VC_FINGERPOINT_PRIMARY");

	if(IsValidEntity(npc.m_iWearable1))
	{
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 1);
	}
	

	float vecTarget[3];
	WorldSpaceCenter(Target, vecTarget);
	//(int iNPC, float VecTarget[3], float dmg, float speed, float radius, float direct_damage, float direct_radius, float time)
	float Laser_Dmg = 2.5;
	float Speed = (npc.Anger ? 1300.0 : 1100.0);
	float Direct_Dmg = 3.5;
	Fractal_Attack(npc.index, vecTarget, Modify_Damage(-1, Laser_Dmg), Speed, 15.0, Modify_Damage(-1, Direct_Dmg), 0.0, 5.0);
	npc.FaceTowards(vecTarget, 30000.0);
}
static void Fractal_Attack(int iNPC, float VecTarget[3], float dmg, float speed, float radius, float direct_damage, float direct_radius, float time)
{
	float SelfVec[3];
	Ruina_Projectiles Projectile;
	WorldSpaceCenter(iNPC, SelfVec);
	Projectile.iNPC = iNPC;
	Projectile.Start_Loc = SelfVec;
	float Ang[3];
	MakeVectorFromPoints(SelfVec, VecTarget, Ang);
	GetVectorAngles(Ang, Ang);
	Projectile.Angles = Ang;
	Projectile.speed = speed;
	Projectile.radius = direct_radius;
	Projectile.damage = direct_damage;
	Projectile.bonus_dmg = direct_damage*2.5;
	Projectile.Time = time;
	Projectile.visible = false;
	int Proj = Projectile.Launch_Projectile(Func_On_Proj_Touch);

	if(IsValidEntity(Proj))
	{
		float 	f_start = 0.3*radius,
				f_end = 0.2*radius,
				amp = 0.25;
	
		int color[4];
		Ruina_Color(color, i_current_wave[iNPC]);
		Twirl npc = view_as<Twirl>(iNPC);
		int beam = ConnectWithBeamClient(npc.m_iWearable1, Proj, color[0], color[1], color[2], f_start, f_end, amp, LASERBEAM);
		i_rocket_particle[Proj] = EntIndexToEntRef(beam);
		DataPack pack;
		CreateDataTimer(0.1, Laser_Projectile_Timer, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		pack.WriteCell(EntIndexToEntRef(iNPC));
		pack.WriteCell(EntIndexToEntRef(beam));
		pack.WriteCell(EntIndexToEntRef(Proj));
		pack.WriteCellArray(color, sizeof(color));
		pack.WriteFloat(radius);
		pack.WriteFloat(dmg);
	}
}

static void Func_On_Proj_Touch(int entity, int other)
{
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if(!IsValidEntity(owner))	//owner is invalid, evacuate.
	{
		Ruina_Remove_Projectile(entity);
		return;
	}

	int beam = EntRefToEntIndex(i_rocket_particle[entity]);
	if(IsValidEntity(beam))
		RemoveEntity(beam);

	i_rocket_particle[entity] = INVALID_ENT_REFERENCE;
	
	float ProjectileLoc[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);


	if(fl_ruina_Projectile_radius[entity]>0.0)
		Explode_Logic_Custom(fl_ruina_Projectile_dmg[entity] , owner , owner , -1 , ProjectileLoc , fl_ruina_Projectile_radius[entity] , _ , _ , true, _,_, fl_ruina_Projectile_bonus_dmg[entity]);
	else
		SDKHooks_TakeDamage(other, owner, owner, fl_ruina_Projectile_dmg[entity], DMG_PLASMA, -1, _, ProjectileLoc);

	TE_Particle("spell_batball_impact_blue", ProjectileLoc, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
	if(i_current_wave[owner] >= 30)
	{
		Twirl npc = view_as<Twirl>(owner);
		float radius = (npc.Anger ? 300.0 : 250.0);
		float dmg = Modify_Damage(-1, 12.0);

		float Time = (npc.Anger ? 1.45 : 1.9);
		npc.Ion_On_Loc(ProjectileLoc, radius, dmg, Time);
	}

	Ruina_Remove_Projectile(entity);

}
static Action Laser_Projectile_Timer(Handle timer, DataPack data)
{
	data.Reset();
	int iNPC = EntRefToEntIndex(data.ReadCell());
	int Laser_Entity = EntRefToEntIndex(data.ReadCell());
	int Projectile = EntRefToEntIndex(data.ReadCell());
	int color[4];
	data.ReadCellArray(color, sizeof(color));
	float Radius	= data.ReadFloat();
	float dmg 		= data.ReadFloat();

	if(!IsValidEntity(iNPC) || !IsValidEntity(Laser_Entity) || !IsValidEntity(Projectile))
	{
		if(IsValidEntity(Laser_Entity))
			RemoveEntity(Laser_Entity);

		if(IsValidEntity(Projectile))
			RemoveEntity(Projectile);
		
		return Plugin_Stop;
	}

	Ruina_Laser_Logic Laser;

	float SelfVec[3];
	WorldSpaceCenter(iNPC, SelfVec);
	float Proj_Vec[3];
	GetEntPropVector(Projectile, Prop_Data, "m_vecAbsOrigin", Proj_Vec);

	float Dist = GetVectorDistance(Proj_Vec, SelfVec);
	if(Dist > 1750.0)
	{
		SetEntityMoveType(Projectile, MOVETYPE_FLYGRAVITY);
	}
	Laser.client = iNPC;
	Laser.Start_Point = SelfVec;
	Laser.End_Point = Proj_Vec;

	Laser.Radius = Radius;
	Laser.Damage = dmg;
	Laser.Bonus_Damage = dmg*6.0;
	Laser.damagetype = DMG_PLASMA;

	Laser.Deal_Damage(On_LaserHit);


	return Plugin_Continue;
}
static int i_targets_inrange;

static int Nearby_Players(Twirl npc, float Radius)
{
	i_targets_inrange = 0;
	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	Explode_Logic_Custom(0.0, npc.index, npc.index, -1, VecSelfNpc, Radius, _, _, true, 15, false, _, CountTargets);
	return i_targets_inrange;
}

static void CheckChargeTimeTwirl(Twirl npc)
{
	float GameTime = GetGameTime(npc.index);
	float PercentageCharge = 0.0;
	float TimeUntillTeleLeft = npc.m_flNextTeleport - GameTime;

	PercentageCharge = (TimeUntillTeleLeft  / (npc.Anger ? 15.0 : 30.0));

	if(PercentageCharge <= 0.0)
		PercentageCharge = 0.0;

	if(PercentageCharge >= 1.0)
		PercentageCharge = 1.0;

	PercentageCharge -= 1.0;
	PercentageCharge *= -1.0;

	TwirlSetBatteryPercentage(npc.index, PercentageCharge);
}
static bool Retreat(Twirl npc, bool block_ions = false)
{
	float GameTime = GetGameTime(npc.index);
	float Radius = 320.0;	//if too many people are next to her, she just teleports in a direction to escape.
	

	if((npc.m_flNextTeleport > GameTime || npc.m_flTempIncreaseCDTeleport > GameTime))	//internal teleportation device is still recharging...
		return false;

	npc.m_flTempIncreaseCDTeleport = GameTime + 1.0;

	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	

	if(Nearby_Players(npc, Radius) < 4)	//not worth "retreating"
		return false;

	//OH SHIT OH FUCK, WERE BEING OVERRUN, TIME TO GET THE FUCK OUTTA HERE

	float Angles[3];
	int loop_for = 8;
	float Ang_Adjust = 360.0/loop_for;
	
	GetEntPropVector(npc.index, Prop_Data, "m_angRotation", Angles);
	Angles[0] =0.0;
	Angles[1]+=180.0;	//she prefers teleporting backwards first
	Angles[2] =0.0;

	bool success = false;

	
	switch(GetRandomInt(0, 1))
	{
		case 1:
			Ang_Adjust*=-1.0;
	}
	//float Final_Vec[3];
	for(int i=0 ; i < loop_for ; i++)
	{
		float Test_Vec[3];
		if(Directional_Trace(npc, VecSelfNpc, Angles, Test_Vec))
		{
			Test_Vec[2]+=10.0;
			static float hullcheckmaxs[3];
			static float hullcheckmins[3];
			hullcheckmaxs = view_as<float>( { 24.0, 24.0, 82.0 } );
			hullcheckmins = view_as<float>( { -24.0, -24.0, 0.0 } );	
			if(Npc_Teleport_Safe(npc.index, Test_Vec, hullcheckmins, hullcheckmaxs, true))
			{
				//TE_SetupBeamPoints(VecSelfNpc, Test_Vec, g_Ruina_BEAM_Laser, 0, 0, 0, 5.0, 15.0, 15.0, 0, 0.1, {255, 255, 255,255}, 3);
				//TE_SendToAll();
				//Final_Vec = Test_Vec;
				success = true;
				break;
			}
		}
		Angles[1]+=Ang_Adjust;
	}
	if(!success)
		return false;
	
	npc.m_flNextTeleport = GameTime + (npc.Anger ? 15.0 : 30.0);
	
	//YAY IT WORKED!!!!!!!

	npc.PlayTeleportSound();

	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
			
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
		npc.FaceTowards(vecTarget, 30000.0);
	
	}
	else
	{
		npc.FaceTowards(VecSelfNpc, 30000.0);
	}

	int wave = i_current_wave[npc.index];

	float start_offset[3], end_offset[3];
	start_offset = VecSelfNpc;

	float effect_duration = 0.25;
	
	WorldSpaceCenter(npc.index, end_offset);
	
	for(int help=1 ; help<=8 ; help++)
	{	
		Lanius_Teleport_Effect(RUINA_BALL_PARTICLE_BLUE, effect_duration, start_offset, end_offset);
		
		start_offset[2] += 12.5;
		end_offset[2] += 12.5;
	}

	//for non standard teleport, don't do the AOE ion strikes when she teleports
	if(block_ions)
		return true;

	npc.m_flForceRanged = GameTime + 5.0;	//now force ranged mode for a bit, wouldn't make sense to just rush straight into the same situation you just escaped from

	if(wave<=10)	//stage 1: a simple ion where she was.
	{
		float radius = (npc.Anger ? 325.0 : 250.0);
		float dmg = 50.0;
		dmg *= RaidModeScaling;

		float Time = (npc.Anger ? 1.25 : 1.5);
		npc.Ion_On_Loc(VecSelfNpc, radius, dmg, Time);
	}
	else if(wave <=30)	//stage 2, 3: an ion cast on anyone near her previous location when she teleports
	{
		float aoe_check = (npc.Anger ? 250.0 : 175.0);
		Explode_Logic_Custom(0.0, npc.index, npc.index, -1, VecSelfNpc, aoe_check, _, _, true, _, false, _, AoeIonCast);
		float radius = (npc.Anger ? 325.0 : 250.0);
		float dmg = 50.0;
		dmg *= RaidModeScaling;

		float Time = (npc.Anger ? 1.25 : 1.5);
		npc.Ion_On_Loc(VecSelfNpc, radius, dmg, Time);
	}
	else
	{
		float aoe_check = (npc.Anger ? 350.0 : 250.0);
		float radius = (npc.Anger ? 325.0 : 250.0);
		float dmg = 50.0;
		dmg *= RaidModeScaling;

		float Time = (npc.Anger ? 1.25 : 1.5);
		Explode_Logic_Custom(0.0, npc.index, npc.index, -1, VecSelfNpc, aoe_check, _, _, true, _, false, _, AoeIonCast);
		npc.Ion_On_Loc(VecSelfNpc, radius, dmg, Time);
		Retreat_Laser(npc, VecSelfNpc);
		//2 second duration laser.
		npc.m_flForceRanged = GameTime + 8.0;	
	}

	if(b_force_transformation)
		return true;

	switch(GetRandomInt(0, 13))
	{
		case 0: Twirl_Lines(npc, "{crimson}Twirly Wirly{snow}~");
		case 1: Twirl_Lines(npc, "You really think you can {purple}catch {snow}me?");
		case 2: Twirl_Lines(npc, "Ahaaa, {crimson}bad");
		case 3: Twirl_Lines(npc, "So close, yet far");
		case 4: Twirl_Lines(npc, "{crimson}Kururing{snow}~");
		case 5: Twirl_Lines(npc, "HEY, {purple}personal{snow} space buddy");
		case 6: Twirl_Lines(npc, "You think I'd let myself get {purple}surrounded{snow} like that?");
		case 7: Twirl_Lines(npc, "Don't surround me like that.");
		case 8: Twirl_Lines(npc, "When will you learn this,{crimson} DON'T COME NEAR ME");
		case 9: Twirl_Lines(npc, "My innocence, you won't get close to it that easily");
		case 10: Twirl_Lines(npc, "Aiya, how rude of you to come close.");
		case 11: Twirl_Lines(npc, "{crimson}Kuru Kuru{snow}~");
		case 12: Twirl_Lines(npc, "Oh my, ganging up on someone as {purple}innocent{snow} as me?");
		case 13: Twirl_Lines(npc, "Aaa, hai hai~");
	}
	return true;
}
//taunt_the_scaredycat_medic
static void Retreat_Laser(Twirl npc, float Last_Pos[3])
{
	float GameTime = GetGameTime(npc.index);
	npc.AddActivityViaSequence("secondrate_sorcery_medic");
	
	npc.SetPlaybackRate(1.0);	
	npc.SetCycle(0.01);

	SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
	SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 1);

	EmitCustomToAll(TWIRL_LASER_SOUND, npc.index, SNDCHAN_AUTO, 120, _, 1.0, SNDPITCH_NORMAL);

	float Duration = 2.0;
	npc.m_bisWalking = false;
	fl_ruina_battery_timeout[npc.index] = GameTime + Duration + 0.7;
	npc.m_flDoingAnimation = GameTime + Duration + 0.75;
	npc.m_flRetreatLaserThrottle = GameTime + 0.7;

	npc.FaceTowards(Last_Pos, 10000.0);

	if(!npc.Anger)
	{
		npc.StopPathing();
		
	}

	npc.m_bAnimationSet = false;

	npc.m_flSpeed = 0.0;

	f_NpcTurnPenalty[npc.index] = (npc.Anger ? 0.01 : 0.0);

	SDKUnhook(npc.index, SDKHook_Think, Retreat_Laser_Tick);
	SDKHook(npc.index, SDKHook_Think, Retreat_Laser_Tick);
}
static Action Retreat_Laser_Tick(int iNPC)
{
	Twirl npc = view_as<Twirl>(iNPC);
	float GameTime = GetGameTime(npc.index);

	if(fl_ruina_battery_timeout[npc.index] < GameTime)
	{
		SDKUnhook(npc.index, SDKHook_Think, Retreat_Laser_Tick);

		npc.m_bisWalking = true;
		f_NpcTurnPenalty[npc.index] = 1.0;
		npc.m_flSpeed = fl_npc_basespeed;
		npc.StartPathing();
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 255);

		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		npc.m_iChanged_WalkCycle = 1;
		if(iActivity > 0) npc.StartActivity(iActivity);

		return Plugin_Stop;
	}

	npc.m_flSpeed = 0.0;	//DON'T MOVE

	if(npc.m_flRetreatLaserThrottle > GameTime)
		return Plugin_Continue;

	if(!npc.m_bAnimationSet)
	{
		npc.SetCycle(0.51948051);	//math bitch!
		npc.m_bAnimationSet = true;
		npc.SetPlaybackRate(0.0);	
		//npc.SetCycle(0.4);
	}
	npc.m_flRetreatLaserThrottle = GameTime + 0.1;

	float Radius = 30.0;
	float diameter = Radius*2.0;
	Ruina_Laser_Logic Laser;
	Laser.client = npc.index;
	float 	flPos[3], // original
			flAng[3]; // original
	float Angles[3];
	GetAttachment(npc.index, "effect_hand_r", flPos, flAng);
	//flPos[2]+=37.0;
	Get_Fake_Forward_Vec(15.0, Angles, flPos, flPos);

	float tmp[3];
	float actualBeamOffset[3];
	float BEAM_BeamOffset[3];
	BEAM_BeamOffset[0] = 0.0;
	BEAM_BeamOffset[1] = -5.0;
	BEAM_BeamOffset[2] = 0.0;

	tmp[0] = BEAM_BeamOffset[0];
	tmp[1] = BEAM_BeamOffset[1];
	tmp[2] = 0.0;
	VectorRotate(BEAM_BeamOffset, Angles, actualBeamOffset);
	actualBeamOffset[2] = BEAM_BeamOffset[2];
	flPos[0] += actualBeamOffset[0];
	flPos[1] += actualBeamOffset[1];
	flPos[2] += actualBeamOffset[2];

	GetEntPropVector(npc.index, Prop_Data, "m_angRotation", Angles);
	Laser.DoForwardTrace_Custom(Angles, flPos, -1.0);
	Laser.Damage = Modify_Damage(-1, 10.0);
	Laser.Radius = Radius;
	Laser.Bonus_Damage = Modify_Damage(-1, 10.0)*6.0;
	Laser.damagetype = DMG_PLASMA;
	Laser.Deal_Damage();

	float TE_Duration = 0.1;
	float EndLoc[3]; EndLoc = Laser.End_Point;

	int color[4]; Ruina_Color(color, i_current_wave[npc.index]);

	float Offset_Loc[3];
	Get_Fake_Forward_Vec(100.0, Angles, Offset_Loc, flPos);

	int colorLayer4[4];
	SetColorRGBA(colorLayer4, color[0], color[1], color[2], color[1]);
	int colorLayer3[4];
	SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, color[3]);
	int colorLayer2[4];
	SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, color[3]);
	int colorLayer1[4];
	SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 7255 / 8, colorLayer4[1] * 5 + 7255 / 8, colorLayer4[2] * 5 + 7255 / 8, color[3]);

	float 	Rng_Start = GetRandomFloat(diameter*0.5, diameter*0.7);

	float 	Start_Diameter1 = ClampBeamWidth(Rng_Start*0.7),
			Start_Diameter2 = ClampBeamWidth(Rng_Start*0.9),
			Start_Diameter3 = ClampBeamWidth(Rng_Start);
		
	float 	End_Diameter1 = ClampBeamWidth(diameter*0.7),
			End_Diameter2 = ClampBeamWidth(diameter*0.9),
			End_Diameter3 = ClampBeamWidth(diameter);

	int Beam_Index = g_Ruina_BEAM_Combine_Black;

	TE_SetupBeamPoints(flPos, Offset_Loc, Beam_Index, 	0, 0, 66, TE_Duration, 0.0, Start_Diameter1, 0, 10.0, colorLayer2, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(flPos, Offset_Loc, Beam_Index, 	0, 0, 66, TE_Duration, 0.0, Start_Diameter2, 0, 10.0, colorLayer3, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(flPos, Offset_Loc, Beam_Index,	0, 0, 66, TE_Duration, 0.0, Start_Diameter3, 0, 10.0, colorLayer4, 3);
	TE_SendToAll(0.0);

	TE_SetupBeamPoints(Offset_Loc, EndLoc, Beam_Index, 	0, 0, 66, TE_Duration, Start_Diameter1*0.9, End_Diameter1, 0, 0.1, colorLayer2, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(Offset_Loc, EndLoc, Beam_Index, 	0, 0, 66, TE_Duration, Start_Diameter2*0.9, End_Diameter2, 0, 0.1, colorLayer3, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(Offset_Loc, EndLoc, Beam_Index, 	0, 0, 66, TE_Duration, Start_Diameter3*0.9, End_Diameter3, 0, 0.1, colorLayer4, 3);
	TE_SendToAll(0.0);


	return Plugin_Continue;

}
static bool Directional_Trace(Twirl npc, float Origin[3], float Angle[3], float Result[3])
{
	Ruina_Laser_Logic Laser;

	float Distance = 750.0;
	Laser.client = npc.index;
	Laser.DoForwardTrace_Custom(Angle, Origin, Distance);
	float Dist = GetVectorDistance(Origin, Laser.End_Point);

	//TE_SetupBeamPoints(Origin, Laser.End_Point, g_Ruina_BEAM_Laser, 0, 0, 0, 1.0, 15.0, 15.0, 0, 0.1, {255, 255, 255,255}, 3);
	//TE_SendToAll();

	//the distance it too short, try a new angle
	if(Dist < 500.0)
		return false;

	Result = Laser.End_Point;
	ConformLineDistance(Result, Origin, Result, Dist - 100.0);	//need to add a bit of extra room to make sure its a valid teleport location. otherwise she might materialize into a wall
	Ruina_Proper_To_Groud_Clip({24.0,24.0,24.0}, 300.0, Result);	//now get the vector but on the floor.
	float Ang[3];
	MakeVectorFromPoints(Origin, Result, Ang);
	GetVectorAngles(Ang, Ang);

	//TE_SetupBeamPoints(Origin, Result, g_Ruina_BEAM_Laser, 0, 0, 0, 1.0, 15.0, 15.0, 0, 0.1, {255, 0, 0, 255}, 3);
	//TE_SendToAll();

	float Sub_Dist = GetVectorDistance(Origin, Result);

	Laser.DoForwardTrace_Custom(Ang, Origin, Sub_Dist);	//check if we can see that vector
	//TE_SetupBeamPoints(Origin, Laser.End_Point, g_Ruina_BEAM_Laser, 0, 0, 0, 1.0, 15.0, 15.0, 0, 0.1, {0, 0, 255, 255}, 3);
	//TE_SendToAll();
	if(Similar_Vec(Result, Laser.End_Point))			//then check if its similar to the one that was traced via a ground clip
	{
		float sky[3]; sky = Result; sky[2]+=500.0;
		//TE_SetupBeamPoints(sky, Result, g_Ruina_BEAM_Laser, 0, 0, 0, 1.0, 15.0, 15.0, 0, 0.1, {0, 255, 0, 255}, 3);
		//TE_SendToAll();
		Result = Laser.End_Point;
		return true;
	}
	return false;
}
static void AoeIonCast(int entity, int victim, float damage, int weapon)
{
	Twirl npc = view_as<Twirl>(entity);

	float radius = (npc.Anger ? 325.0 : 250.0);
	float dmg = 35.0;
	dmg *= RaidModeScaling;
	float Target_Vec[3];
	WorldSpaceCenter(victim, Target_Vec);
	float Time = (npc.Anger ? 1.5 : 2.0);
	npc.Ion_On_Loc(Target_Vec, radius, dmg, Time);
}
static void CountTargets(int entity, int victim, float damage, int weapon)
{
	i_targets_inrange++;
}
static void On_LaserHit(int client, int target, int damagetype, float damage)
{
	Twirl npc = view_as<Twirl>(client);
	Ruina_Add_Mana_Sickness(npc.index, target, 0.1, (npc.Anger ? 55 : 45), true);
}
static float fl_ionic_fracture_range = 1000.0;
static float fl_ionic_fracture_detionation_radius = 1500.0;
static int 	 i_ionic_fracture_amt = 12;
static float fl_ionic_fracture_det_timer = 2.5;
static float fl_ionic_fracture_windup = 2.0;
static float fl_ionic_fracture_charge_time = 2.0;
static float fl_ionic_fracture_hover_time = 1.0;

static float fl_ionic_fracture_timer_ratio;

static bool IonicFracture(Twirl npc)
{
	if(i_current_wave[npc.index] < 30)
		return false;

	float GameTime = GetGameTime(npc.index);
	if(npc.m_flIonicFractureCD > GameTime)
		return false;

	if(fl_ruina_battery_timeout[npc.index] > GameTime)
		return false;

	fl_ionic_fracture_range = (npc.Anger ? 1500.0 : 1000.0);
		
	if(Nearby_Players(npc, fl_ionic_fracture_range) < 5 && !b_test_mode)
		return false;

	fl_ionic_fracture_detionation_radius = (npc.Anger ? 1250.0 : 800.0);
	i_ionic_fracture_amt = (npc.Anger ? 16 : 12);

	fl_ionic_fracture_timer_ratio = (npc.Anger ? 0.8 : 0.9);

	float ratio = fl_ionic_fracture_timer_ratio;

	EmitSoundToAll(TWIRL_IONIC_FRACTURE_INIT_SOUND);
	EmitSoundToAll(TWIRL_IONIC_FRACTURE_INIT_SOUND);

	EmitSoundToAll(TWIRL_IONIC_FRACTURE_PASSIVE_SOUND3, npc.index, SNDCHAN_STATIC, SNDLEVEL_RAIDSIREN, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL);
	EmitSoundToAll(TWIRL_IONIC_FRACTURE_PASSIVE_SOUND3, npc.index, SNDCHAN_STATIC, SNDLEVEL_RAIDSIREN, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL);
	
	//these values are heavily fine tuned relative to the animation.
	fl_ionic_fracture_windup = 2.5		* ratio;
	fl_ionic_fracture_det_timer = 2.25	* ratio;
	fl_ionic_fracture_hover_time = 0.75	* ratio;
	fl_ionic_fracture_charge_time = 1.5 * ratio;

	float charge_time = fl_ionic_fracture_charge_time;
	float windup = fl_ionic_fracture_windup;
	float det_time = fl_ionic_fracture_det_timer + fl_ionic_fracture_hover_time;

	npc.m_flIonicFractureHoverTimer = GameTime + fl_ionic_fracture_windup + fl_ionic_fracture_charge_time + fl_ionic_fracture_hover_time;

	npc.AddActivityViaSequence("taunt01");
	npc.SetPlaybackRate(0.65 / ratio);
	npc.SetCycle(0.1);
	npc.m_bAnimationSet = false;
	npc.m_flIonicFractureAnimTimer = GameTime + 1.0;

	float Origin[3]; GetAbsOrigin(npc.index, Origin); Origin[2]+=5.0;

	float Radius = fl_ionic_fracture_detionation_radius;
	int color[4]; Ruina_Color(color, i_current_wave[npc.index]);
	TE_SetupBeamRingPoint(Origin, 0.0, Radius*2.0, g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, windup , 50.0, 0.75, color, 1, 0);
	TE_SendToAll();

	SDKUnhook(npc.index, SDKHook_Think, IonicFracture_Think);
	SDKHook(npc.index, SDKHook_Think, IonicFracture_Think);

	npc.StopPathing();
	
	npc.m_flSpeed = 0.0;
	npc.m_bisWalking = false;

	NPCStats_RemoveAllDebuffs(npc.index);

	SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
	SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 1);

	npc.m_flIonicFractureCD = GameTime + (npc.Anger ? 90.0 : 120.0);
	fl_BEAM_DurationTime[npc.index] = 0.0;

	npc.m_flDoingAnimation = GameTime + charge_time + det_time + windup + 0.5;
	fl_ruina_battery_timeout[npc.index] = GameTime + charge_time + det_time + windup + 0.5;
	npc.m_flIonicFractureEndTimer = GameTime + charge_time + det_time + windup;
	npc.m_flIonicFractureChargeTimer = GameTime + charge_time + windup;
	npc.m_flIonicFractureWindUpTimer = GameTime + windup;

	return true;
}
static void FuncTwirlIonicFractalProjectileTouch(int entity, int other)
{
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if(!IsValidEntity(owner))	//owner is invalid, evacuate.
	{
		Ruina_Remove_Projectile(entity);
		return;
	}
	//we have hit the world, time to start the light show.
	if(other == 0 && fl_BEAM_ChargeUpTime[entity] == -1)
	{
		fl_BEAM_ChargeUpTime[entity] = 1.0;
		TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, {0.0, 0.0, 0.0});
	}

	if(fl_BEAM_ChargeUpTime[entity] != -1.0)
		return;

	if(other == 0)
		return;
	
	if(IsIn_HitDetectionCooldown(owner,other))
		return;
			
	Set_HitDetectionCooldown(owner,other, GetGameTime() + 0.25);	//if they walk backwards, its likely to hit them 2 times, but who on earth would willingly walk backwards/alongside the trajectory of the projectile

	float ProjectileLoc[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);

	if(fl_ruina_Projectile_radius[entity]>0.0)
	{
		Explode_Logic_Custom(fl_ruina_Projectile_dmg[entity] , owner , owner , -1 , ProjectileLoc , fl_ruina_Projectile_radius[entity] , _ , _ , true, _,_, fl_ruina_Projectile_bonus_dmg[entity]);
		TE_Particle(fl_BEAM_DurationTime[entity] % 2 ? "spell_batball_impact_blue" : "spell_batball_impact_red", ProjectileLoc, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
	}
	else
	{
		float dmg = fl_ruina_Projectile_dmg[entity];

		if(ShouldNpcDealBonusDamage(other))
			dmg *=fl_ruina_Projectile_bonus_dmg[entity];

		SDKHooks_TakeDamage(other, owner, owner, dmg, DMG_PLASMA|DMG_PREVENT_PHYSICS_FORCE, -1, _, ProjectileLoc);
	}
}
static Action IonicFracture_Think(int iNPC)
{
	Twirl npc = view_as<Twirl>(iNPC);
	float GameTime = GetGameTime(npc.index);
	if(!npc.m_bAnimationSet && npc.m_flIonicFractureAnimTimer < GameTime)
	{
		npc.m_flIonicFractureAnimTimer = GameTime + 2.0;
		npc.SetPlaybackRate(0.3 / fl_ionic_fracture_timer_ratio);
		npc.m_bAnimationSet = true;
	}

	ApplyStatusEffect(npc.index, npc.index, "Hardened Aura", 0.25);
	ApplyStatusEffect(npc.index, npc.index, "Solid Stance", 0.25);

	if(npc.m_flIonicFractureWindUpTimer < GameTime)
	{
		npc.m_flIonicFractureWindUpTimer = FAR_FUTURE;
		float Dmg = 20.0;
		float Origin[3]; GetAbsOrigin(npc.index, Origin);
		Origin[2]+=50.0;
		Ruina_Projectiles Projectile;
		Projectile.iNPC = npc.index;
		Projectile.Start_Loc = Origin;
		Projectile.radius = 150.0;
		Projectile.damage = Modify_Damage(-1, Dmg);
		Projectile.bonus_dmg = Modify_Damage(-1, Dmg)*2.5;
		Projectile.Time = (npc.m_flIonicFractureEndTimer - GameTime) + 10.0;	//the +10.0 is for potential npc stuns and such. the projectile gets deleted by the ability itself anyway so technically the timer isn't even needed, but its here just incase
		Projectile.visible = false;

		Origin[2]-=45.0;

		float Radius = fl_ionic_fracture_detionation_radius;
		int color[4]; Ruina_Color(color, i_current_wave[npc.index]);
		TE_SetupBeamRingPoint(Origin, Radius*2.0, Radius*2.0 + 0.5, g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, (npc.m_flIonicFractureEndTimer - GameTime) , 50.0, 0.75, color, 1, 0);
		TE_SendToAll();

		Origin[2]+=45.0;

		EmitSoundToAll(TWIRL_IONIC_FRACTURE_PASSIVE_SOUND, npc.index, SNDCHAN_STATIC, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL);
		EmitSoundToAll(TWIRL_IONIC_FRACTURE_PASSIVE_SOUND, npc.index, SNDCHAN_STATIC, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL);
		EmitSoundToAll(TWIRL_IONIC_FRACTURE_PASSIVE_SOUND2, npc.index, SNDCHAN_STATIC, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL);
		EmitSoundToAll(TWIRL_IONIC_FRACTURE_PASSIVE_SOUND2, npc.index, SNDCHAN_STATIC, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL);


		for(int i = 0 ; i < i_ionic_fracture_amt ; i++)
		{
			char Particle[50];
			if(i % 2)
				Particle = "drg_manmelter_trail_blue";
			else
				Particle = "drg_manmelter_trail_red";
			
			float Angles[3]; Angles = GetNPCAngles(npc);
			Angles[0] = 0.0; Angles[2] = 0.0;
			Angles[1] = Angles[1] + 360.0/i_ionic_fracture_amt*i;	//go in a 360 angle, evenly spaced depending on loop count
			Ruina_Laser_Logic Laser;
			Laser.client = npc.index;
			Laser.DoForwardTrace_Custom(Angles, Origin, fl_ionic_fracture_range);

			float distance = GetVectorDistance(Laser.Start_Point, Laser.End_Point);	//get the distance from start to end loc, adjust for what distance we want
			float speed = distance / fl_ionic_fracture_charge_time;	//then adjust speed acordingly.
			Projectile.speed = speed;
			Projectile.Angles = Angles;
			int projectile = Projectile.Launch_Projectile(FuncTwirlIonicFractalProjectileTouch);
			
			if(!IsValidEntity(projectile))
				continue;

			fl_BEAM_DurationTime[projectile] = float(i);
			//fractals[i] = projectile;

			SetEntProp(projectile, Prop_Send, "m_usSolidFlags", 12); 

			Projectile.Apply_Particle(Particle);
			fl_BEAM_ChargeUpTime[projectile] = -1.0;
			SDKHook(projectile, SDKHook_Think, IonicFracture_ProjectileThink);
			SDKHook(projectile, SDKHook_ThinkPost, ProjectileBaseThinkPost);
		}
	}

	if(npc.m_flIonicFractureChargeTimer < GameTime)
	{
		int color[4]; Ruina_Color(color, i_current_wave[npc.index]);
		float Radius = fl_ionic_fracture_detionation_radius;
		float Thickness = 20.0;
		float ground[3]; GetAbsOrigin(npc.index, ground);

		ground[2] += fl_BEAM_DurationTime[npc.index];

		TE_SetupBeamRingPoint(ground, Radius*2.0, Radius*2.0+0.5, g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, TWIRL_TE_DURATION , Thickness, 0.75, color, 1, 0);
		TE_SendToAll();

		fl_BEAM_DurationTime[npc.index]+=3.0;

		if(fl_BEAM_DurationTime[npc.index] > 60.0)
			fl_BEAM_DurationTime[npc.index] = 1.0;
	}

	if(npc.m_flIonicFractureEndTimer < GameTime)
	{
		npc.SetPlaybackRate(1.0);

		float Origin[3]; GetAbsOrigin(npc.index, Origin);

		fl_ruina_battery_timeout[npc.index] = GameTime + 0.6;
		npc.m_flDoingAnimation = GameTime + 0.6;

		CreateTimer(0.6, Lunar_Radiance_RestoreAnim, EntIndexToEntRef(npc.index), TIMER_FLAG_NO_MAPCHANGE);

		SDKUnhook(npc.index, SDKHook_Think, IonicFracture_Think);

		int color[4];
		Ruina_Color(color, i_current_wave[npc.index]);
		color[3] = 175;
		int loop_for = 15;		//15
		float height = 1500.0;	//1500
		float sky_loc[3]; sky_loc = Origin; sky_loc[2]+=height;
		float radius = fl_ionic_fracture_detionation_radius;

		Explode_Logic_Custom(Modify_Damage(-1, 200.0), npc.index, npc.index, -1, Origin, radius,_,0.8, true);
		Ruina_AOE_Add_Mana_Sickness(Origin, npc.index, radius, 0.5, 200, true);

		StopSound(npc.index, SNDCHAN_STATIC, TWIRL_IONIC_FRACTURE_PASSIVE_SOUND);
		StopSound(npc.index, SNDCHAN_STATIC, TWIRL_IONIC_FRACTURE_PASSIVE_SOUND);
		StopSound(npc.index, SNDCHAN_STATIC, TWIRL_IONIC_FRACTURE_PASSIVE_SOUND);
		StopSound(npc.index, SNDCHAN_STATIC, TWIRL_IONIC_FRACTURE_PASSIVE_SOUND2);
		StopSound(npc.index, SNDCHAN_STATIC, TWIRL_IONIC_FRACTURE_PASSIVE_SOUND2);
		StopSound(npc.index, SNDCHAN_STATIC, TWIRL_IONIC_FRACTURE_PASSIVE_SOUND2);
		StopSound(npc.index, SNDCHAN_STATIC, TWIRL_IONIC_FRACTURE_PASSIVE_SOUND3);
		StopSound(npc.index, SNDCHAN_STATIC, TWIRL_IONIC_FRACTURE_PASSIVE_SOUND3);
		StopSound(npc.index, SNDCHAN_STATIC, TWIRL_IONIC_FRACTURE_PASSIVE_SOUND3);

		EmitAmbientSound(TWIRL_IONIC_FRACTURE_EXPLOSION, Origin, _, 120, _, _, GetRandomInt(55, 75));
		EmitAmbientSound(TWIRL_IONIC_FRACTURE_EXPLOSION, Origin, _, 120, _, _, GetRandomInt(55, 75));
		TE_SetupBeamRingPoint(Origin, 1.0, radius*2.0, g_Ruina_Laser_BEAM, g_Ruina_HALO_Laser, 0, 1, 1.0, 20.0, 1.0, color, 1, 0);
		TE_SendToAll();
		
		float start = 75.0;
		float end = 75.0;
		TE_SetupBeamPoints(Origin, sky_loc, g_Ruina_BEAM_Diamond, 0, 0, 0, 1.0, start, end, 0, 1.0, color, 3);
		TE_SendToAll();
		TE_SetupBeamPoints(Origin, sky_loc, g_Ruina_BEAM_Diamond, 0, 0, 0, 1.25, start*0.5, end*0.5, 0, 1.0, color, 3);
		TE_SendToAll();
		TE_SetupBeamPoints(Origin, sky_loc, g_Ruina_BEAM_Diamond, 0, 0, 0, 1.5, start*0.25, end*0.25, 0, 1.0, color, 3);
		TE_SendToAll();

		TE_SetupBeamPoints(Origin, sky_loc, g_Ruina_BEAM_Combine_Blue, g_Ruina_HALO_Laser, 0, 0, 1.0, start, end, 0, 1.0, color, 3);
		TE_SendToAll();
		TE_SetupBeamPoints(Origin, sky_loc, g_Ruina_BEAM_Combine_Blue, g_Ruina_HALO_Laser, 0, 0, 1.25, start*0.5, end*0.5, 0, 1.0, color, 3);
		TE_SendToAll();
		TE_SetupBeamPoints(Origin, sky_loc, g_Ruina_BEAM_Combine_Blue, g_Ruina_HALO_Laser, 0, 0, 1.5, start*0.25, end*0.25, 0, 1.0, color, 3);
		TE_SendToAll();

		float Time = 1.0;

		float thicc = 4.0;
		float Seperation = height / loop_for;
		float Offset_Time = Time / loop_for;
		for(int i = 1 ; i <= loop_for ; i++)
		{
			float timer = Offset_Time*i+0.3;
			if(timer<=0.02)
				timer=0.02;
			float end_ratio = (((loop_for/2.0)/i));
			float final_radius = radius*end_ratio;
			if(final_radius > 4096.0)	//so apperantly there is a max endradius, these are the types of things you only findout if you are dumb enough to even try...
				final_radius= 4095.0;
			TE_SetupBeamRingPoint(Origin, 0.0, final_radius, g_Ruina_Laser_BEAM, g_Ruina_Laser_BEAM, 0, 1, timer, thicc, 0.1, color, 1, 0);

			TE_SendToAll();
			Origin[2]+=Seperation;
		}

		return Plugin_Stop;
	}
	return Plugin_Continue;
}
static Action IonicFracture_ProjectileThink(int entity)
{
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if(!IsValidEntity(owner))	//owner is invalid, evacuate.
	{
		Ruina_Remove_Projectile(entity);
		return Plugin_Stop;
	}
	Twirl npc = view_as<Twirl>(owner);
	//make it so the ionic fracture fragments are affected by things that stun npc's
	float GameTime = GetGameTime(npc.index);

	//light show has *yet* to begin.
	if(npc.m_flIonicFractureChargeTimer > GameTime)
		return Plugin_Continue;

	//we are still charging, don't do anything yet.
	if(npc.m_flIonicFractureChargeTimer > GameTime)
		return Plugin_Continue;

	if(npc.m_flIonicFractureEndTimer < GameTime)
	{
		Ruina_Remove_Projectile(entity);
		return Plugin_Stop;
	}

	float ProjectileLoc[3], Origin[3]; GetAbsOrigin(npc.index, Origin); Origin[2]+=50.0;
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);

	float Distance = GetVectorDistance(Origin, ProjectileLoc);

	if(fl_BEAM_ChargeUpTime[entity] < 2.0 && npc.m_flIonicFractureChargeTimer < GameTime)
	{	
		TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, {0.0, 0.0, 0.0});
		if(npc.m_flIonicFractureHoverTimer < GameTime)
		{
			int particle = EntRefToEntIndex(i_rocket_particle[entity]);
			if(IsValidEntity(particle))
				RemoveEntity(particle);

			float Angles[3];
			MakeVectorFromPoints(ProjectileLoc, Origin, Angles);
			GetVectorAngles(Angles, Angles);
			float speed = Distance / (fl_ionic_fracture_det_timer);
			SetProjectileSpeed(entity, speed, Angles);
			fl_BEAM_ChargeUpTime[entity] = 2.0;
		}
	}

	if(npc.m_flIonicFractureChargeTimer > GameTime)
		return Plugin_Continue;

	// do visuals
	int Beam_Index = g_Ruina_BEAM_Combine_Blue;

	float sky[3]; sky = ProjectileLoc; sky[2]+=1500.0; 
	float ground[3]; ground = ProjectileLoc;
	Ruina_Proper_To_Groud_Clip({24.0,24.0,24.0}, 300.0, ground); ground[2]-=50.0;

	int color[4]; Ruina_Color(color, i_current_wave[npc.index]);

	float diameter = 80.0;

	float Diameter_Rng = GetRandomFloat(diameter*0.5, diameter);

	float TE_Duration = TWIRL_TE_DURATION;

	TE_SetupBeamPoints(ground, sky, Beam_Index,	g_Ruina_BEAM_Combine_Black, 0, 66, TE_Duration, Diameter_Rng, Diameter_Rng, 0, 0.1, color, 3);
	TE_SendToAll(0.0);

	//do dmg

	Ruina_Laser_Logic Laser;
	Laser.client = owner;
	Laser.Start_Point = ground;
	Laser.End_Point = sky;
	Laser.Radius = diameter;
	Laser.damagetype = DMG_PLASMA;
	Laser.Damage = Modify_Damage(-1, 10.0);
	Laser.Bonus_Damage = Modify_Damage(-1, 14.0);
	Laser.Deal_Damage(On_LaserHit);

	return Plugin_Continue;
}


static bool Magia_Overflow(Twirl npc)
{
	float GameTime = GetGameTime(npc.index);
	if(npc.m_flMagiaOverflowRecharge > GameTime)
		return false;

	if(fl_ruina_battery_timeout[npc.index] > GameTime)
		return false;
		
	if(Nearby_Players(npc, 500.0) > 3)
		return false;

	if(Nearby_Players(npc, 300.0) <= 0)
		return false;
		
	npc.m_flTempIncreaseCDTeleport = 0.0;	//so it doesn't block this specific teleport
	Retreat(npc, true);

	fl_ruina_shield_break_timeout[npc.index] = 0.0;		//make 100% sure she WILL get the shield.
	//give the shield to itself.
	if(Waves_InFreeplay())
		Ruina_Npc_Give_Shield(npc.index, 0.65);
	else
		Ruina_Npc_Give_Shield(npc.index, 0.45);
	
	npc.AddActivityViaSequence("taunt_the_scaredycat_medic");
	npc.SetPlaybackRate(1.0);	
	npc.SetCycle(0.01);

	SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
	SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 1);

	//EmitCustomToAll(TWIRL_LASER_SOUND, npc.index, SNDCHAN_AUTO, 120, _, 1.0, SNDPITCH_NORMAL);

	float Duration = TWIRL_MAGIA_OVERFLOW_DURATION;
	npc.m_bisWalking = false;
	fl_ruina_battery_timeout[npc.index] = GameTime + Duration + 0.7;
	npc.m_flDoingAnimation = GameTime + Duration + 0.75;
	npc.m_flRetreatLaserThrottle = GameTime + 0.7;
	npc.m_flMagiaOverflowRecharge = GameTime + Duration + 0.7 + (npc.Anger ? 30.0 : 45.0);

	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	int color[4]; 
	Ruina_Color(color, i_current_wave[npc.index]);
	float Thickness = 6.0;
	VecSelfNpc[2]-=2.5;
	//create a ring around twirl showing the radius for her special "if you're near me, my laser turns faster"
	TE_SetupBeamRingPoint(VecSelfNpc, (npc.Anger ? 350.0 : 275.0)*2.0, (npc.Anger ? 350.0 : 275.0)*2.0+0.5, g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, Duration+0.7, Thickness, 0.75, color, 1, 0);
	TE_SendToAll();

	npc.m_bAnimationSet = false;

	npc.StopPathing();
	
	npc.m_flSpeed = 0.0;

	npc.m_flMagiaAngle = GetRandomFloat(0.0, 360.0);

	npc.m_bInKame = true;
	NPCStats_RemoveAllDebuffs(npc.index);

	SDKUnhook(npc.index, SDKHook_Think, Magia_Overflow_Tick);
	SDKHook(npc.index, SDKHook_Think, Magia_Overflow_Tick);

	return true;
}
static Action Magia_Overflow_Tick(int iNPC)
{
	Twirl npc = view_as<Twirl>(iNPC);
	float GameTime = GetGameTime(npc.index);

	if(fl_ruina_battery_timeout[npc.index] < GameTime)
	{
		SDKUnhook(npc.index, SDKHook_Think, Magia_Overflow_Tick);

		StopSound(npc.index, SNDCHAN_STATIC, TWIRL_LASER_SOUND);
		StopSound(npc.index, SNDCHAN_STATIC, TWIRL_LASER_SOUND);

		npc.m_bisWalking = true;
		f_NpcTurnPenalty[npc.index] = 1.0;
		npc.m_flSpeed = fl_npc_basespeed;
		npc.StartPathing();

		npc.m_bInKame = false;
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 255);

		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		npc.m_iChanged_WalkCycle = 1;
		if(iActivity > 0) npc.StartActivity(iActivity);

		return Plugin_Stop;
	}
	ApplyStatusEffect(npc.index, npc.index, "Hardened Aura", 0.25);
	ApplyStatusEffect(npc.index, npc.index, "Solid Stance", 0.25);

	npc.m_flSpeed = 0.0;	//DON'T MOVE

	bool update = false;
	if(npc.m_flRetreatLaserThrottle < GameTime)
	{
		update = true;
		npc.m_flRetreatLaserThrottle = GameTime + 0.1;
	}

	if(!npc.m_bAnimationSet && update)
	{
		npc.m_bAnimationSet = true;
		npc.SetPlaybackRate(0.0);	
		//npc.SetCycle(0.4);
	}
	if(!npc.m_bAnimationSet)
		return Plugin_Continue;

	npc.PlayMagiaOverflowSound();
	
	float Radius = 30.0;
	float diameter = Radius*2.0;
	Ruina_Laser_Logic Laser;
	Laser.client = npc.index;
	float 	flPos[3], // original
			flAng[3]; // original
	float Angles[3];

	GetEntPropVector(npc.index, Prop_Data, "m_angRotation", Angles);	//pitch code stolen from fusion. ty artvin

	int iPitch = npc.LookupPoseParameter("body_pitch");
	if(iPitch < 0)
		return Plugin_Continue;

	float flPitch = npc.GetPoseParameter(iPitch);
	flPitch *= -1.0;
	Angles[0] = flPitch;
	GetAttachment(npc.index, "effect_hand_r", flPos, flAng);
	//flPos[2]+=37.0;
	Get_Fake_Forward_Vec(15.0, Angles, flPos, flPos);

	float tmp[3];
	float actualBeamOffset[3];
	float BEAM_BeamOffset[3];
	BEAM_BeamOffset[0] = 0.0;
	BEAM_BeamOffset[1] = -0.0;//5
	BEAM_BeamOffset[2] = 0.0;

	tmp[0] = BEAM_BeamOffset[0];
	tmp[1] = BEAM_BeamOffset[1];
	tmp[2] = 0.0;
	VectorRotate(BEAM_BeamOffset, Angles, actualBeamOffset);
	actualBeamOffset[2] = BEAM_BeamOffset[2];
	flPos[0] += actualBeamOffset[0];
	flPos[1] += actualBeamOffset[1];
	flPos[2] += actualBeamOffset[2];

	Laser.DoForwardTrace_Custom(Angles, flPos, -1.0);
	if(update)
	{
		float Duration = fl_ruina_battery_timeout[npc.index] - GameTime;
		float Ratio = (1.0 - (Duration / TWIRL_MAGIA_OVERFLOW_DURATION));
		if(Ratio<0.1)
			Ratio=0.1;
		float Dps = Modify_Damage(-1, 35.0)*Ratio;
		Laser.Damage = Dps;
		Laser.Radius = Radius;
		Laser.Bonus_Damage = Dps*6.0;
		Laser.damagetype = DMG_PLASMA;
		Laser.Deal_Damage(On_LaserHit);
	}
	

	float TE_Duration = TWIRL_TE_DURATION;
	float EndLoc[3]; EndLoc = Laser.End_Point;

	int color[4]; Ruina_Color(color, i_current_wave[npc.index]);
	if(i_current_wave[npc.index] >=40)
	{
		color[0] = 0;
		color[1] = 250;
		color[2] = 237;	
	}
	color[3] = 255;

	float Offset_Loc[3];
	Get_Fake_Forward_Vec(100.0, Angles, Offset_Loc, flPos);

	int colorLayer4[4];
	SetColorRGBA(colorLayer4, color[0], color[1], color[2], color[1]);
	int colorLayer3[4];
	SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, color[3]);
	int colorLayer2[4];
	SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, color[3]);
	int colorLayer1[4];
	SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 7255 / 8, colorLayer4[1] * 5 + 7255 / 8, colorLayer4[2] * 5 + 7255 / 8, color[3]);

	float 	Rng_Start = GetRandomFloat(diameter*0.5, diameter*0.7);

	float 	Start_Diameter1 = ClampBeamWidth(Rng_Start*0.7),
			Start_Diameter2 = ClampBeamWidth(Rng_Start*0.9),
			Start_Diameter3 = ClampBeamWidth(Rng_Start);
		
	float 	End_Diameter1 = ClampBeamWidth(diameter*0.7),
			End_Diameter2 = ClampBeamWidth(diameter*0.9),
			End_Diameter3 = ClampBeamWidth(diameter);

	int Beam_Index = g_Ruina_BEAM_Combine_Blue;

	TE_SetupBeamPoints(flPos, Offset_Loc, Beam_Index, 	0, 0, 66, TE_Duration, 0.0, Start_Diameter1, 0, 10.0, colorLayer2, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(flPos, Offset_Loc, Beam_Index, 	0, 0, 66, TE_Duration, 0.0, Start_Diameter2, 0, 10.0, colorLayer3, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(flPos, Offset_Loc, Beam_Index,	0, 0, 66, TE_Duration, 0.0, Start_Diameter3, 0, 10.0, colorLayer4, 3);
	TE_SendToAll(0.0);

	TE_SetupBeamPoints(Offset_Loc, EndLoc, Beam_Index, 	0, 0, 66, TE_Duration, Start_Diameter1*0.9, End_Diameter1, 0, 0.1, colorLayer2, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(Offset_Loc, EndLoc, Beam_Index, 	0, 0, 66, TE_Duration, Start_Diameter2*0.9, End_Diameter2, 0, 0.1, colorLayer3, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(Offset_Loc, EndLoc, Beam_Index, 	0, 0, 66, TE_Duration, Start_Diameter3*0.9, End_Diameter3, 0, 0.1, colorLayer4, 3);
	TE_SendToAll(0.0);

	if(npc.m_flMagiaAngle>360.0)
		npc.m_flMagiaAngle -=360.0;
	
	npc.m_flMagiaAngle+=2.5/TickrateModify;

	Twirl_Magia_Rings(npc, Offset_Loc, Angles, 3, true, 50.0, 1.0, TE_Duration, color, EndLoc);

	return Plugin_Continue;

}
static void Twirl_Magia_Rings(Twirl npc, float Origin[3], float Angles[3], int loop_for, bool Type=true, float distance_stuff, float ang_multi, float TE_Duration, int color[4], float drill_loc[3])
{
	float buffer_vec[3][3];
		
	for(int i=0 ; i<loop_for ; i++)
	{	
		float tempAngles[3], Direction[3], endLoc[3];
		tempAngles[0] = Angles[0];
		tempAngles[1] = Angles[1];	//has to the same as the beam
		tempAngles[2] = (npc.m_flMagiaAngle+((360.0/loop_for)*float(i)))*ang_multi;	//we use the roll angle vector to make it speeen
		/*
			Using this method we can actuall keep proper pitch/yaw angles on the turning, unlike say fantasy blade or mlynar newspaper's special swing thingy.
		*/
		
		if(tempAngles[2]>360.0)
			tempAngles[2] -= 360.0;
	
					
		GetAngleVectors(tempAngles, Direction, NULL_VECTOR, Direction);
		ScaleVector(Direction, distance_stuff);
		AddVectors(Origin, Direction, endLoc);
		
		buffer_vec[i] = endLoc;
		
		if(Type)
		{
			int r=175, g=175, b=175, a=175;
			float diameter = 15.0;
			int colorLayer4[4];
			SetColorRGBA(colorLayer4, r, g, b, a);
			int colorLayer1[4];
			SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, a);
										
			TE_SetupBeamPoints(endLoc, drill_loc, g_Ruina_BEAM_Combine_Blue, 0, 0, 0, TE_Duration, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 0.25, colorLayer1, 3);
										
			TE_SendToAll();
		}
		
	}
	
	TE_SetupBeamPoints(buffer_vec[0], buffer_vec[loop_for-1], g_Ruina_BEAM_Combine_Blue, 0, 0, 0, TE_Duration, 5.0, 5.0, 0, 0.01, color, 3);	
	TE_SendToAll(0.0);
	for(int i=0 ; i<(loop_for-1) ; i++)
	{
		TE_SetupBeamPoints(buffer_vec[i], buffer_vec[i+1], g_Ruina_BEAM_Combine_Blue, 0, 0, 0, TE_Duration, 5.0, 5.0, 0, 0.01, color, 3);	
		TE_SendToAll(0.0);
	}
	
}

static Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Twirl npc = view_as<Twirl>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;

	if(IsValidClient(attacker))
	{
		//doing it via "damage" instead of instances of damage so a player with a cheap high firerate weapon cant trick twirl into thinking they are a melee when they switch to a hyper bursty slow attacking weapon.
		if(damagetype & DMG_CLUB)
			fl_player_weapon_score[attacker]+=damage;
		else
			fl_player_weapon_score[attacker]-=damage;
	}

	int Health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
	int MaxHealth = ReturnEntityMaxHealth(npc.index);

	if(b_allow_final)
	{
		int Health_After_Damage = RoundToCeil(float(Health)-damage);
		if(Health_After_Damage <= 5)
		{
			i_current_Text = 0;
			npc.m_flNextThinkTime = FAR_FUTURE;
			b_NpcIsInvulnerable[npc.index] = true;
			damage = 0.0;

			b_NoKnockbackFromSources[npc.index] = true;
			ApplyStatusEffect(npc.index, npc.index, "Clear Head", 999999.0);	
			ApplyStatusEffect(npc.index, npc.index, "Solid Stance", 999999.0);	
			ApplyStatusEffect(npc.index, npc.index, "Fluid Movement", 999999.0);	

			ReviveAll(true);

			npc.m_flSpeed = 0.0;
			f_NpcTurnPenalty[npc.index] = 0.0;

			float timer = RaidModeTime - GetGameTime();
			if(timer < 75.0)	//to avoid the "you are running out of time" thing.
				timer = 75.0;
			fl_raidmode_freeze = timer;

			RaidModeTime +=0.1;

			Kill_Abilities(npc);
			return Plugin_Changed;
		}
	}
		
	Ruina_NPC_OnTakeDamage_Override(npc.index, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

	Twirl_Ruina_Weapon_Lines(npc, attacker);
		
	//Ruina_Add_Battery(npc.index, damage);	//turn damage taken into energy

	

	if(npc.m_flNextChargeSpecialAttack > GetGameTime(npc.index) && npc.m_flNextChargeSpecialAttack != FAR_FUTURE)
	{
		damage=0.0;
		//CPrintToChatAll("Damage nulified");
		return Plugin_Changed;
	}
	if(!b_allow_final_invocation && (MaxHealth/4) >= Health && i_current_wave[npc.index] >=40 && npc.m_flDoingAnimation < GetGameTime(npc.index))
	{
		b_allow_final_invocation = true;
	}
	if(!npc.Anger && (((MaxHealth/2) >= Health) || b_force_transformation ) && i_current_wave[npc.index] >=20) //Anger after half hp
	{
		Kill_Abilities(npc);	//force kill abilities when entering a transformation.
		npc.Anger = true; //	>:(
		npc.PlayAngerSound();

		npc.m_bisWalking = false;
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 1);

		npc.m_flSpeed = 0.0;
		f_NpcTurnPenalty[npc.index] = 0.0;
		RaidModeScaling *= 1.35;

		b_NpcIsInvulnerable[npc.index] = true; //Special huds for invul targets
		b_NoKnockbackFromSources[npc.index] = true;
		ApplyStatusEffect(npc.index, npc.index, "Clear Head", 999999.0);	
		ApplyStatusEffect(npc.index, npc.index, "Solid Stance", 999999.0);	
		ApplyStatusEffect(npc.index, npc.index, "Fluid Movement", 999999.0);	

		int color[4]; 
		Ruina_Color(color, i_current_wave[npc.index]);
		float Radius = 350.0;
		float Thickness = 6.0;
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		TE_SetupBeamRingPoint(VecSelfNpc, Radius*2.0, 0.0, g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, 2.5, Thickness, 0.75, color, 1, 0);
		TE_SendToAll();
		TE_SetupBeamRingPoint(VecSelfNpc, Radius*2.0, Radius*2.0+0.5, g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, 2.5, Thickness, 0.1, color, 1, 0);
		TE_SendToAll();

		npc.AddActivityViaSequence("primary_death_burning");
		npc.SetPlaybackRate(1.0);	
		npc.SetCycle(0.01);

		float GameTime = GetGameTime(npc.index);
		npc.m_flDoingAnimation = GameTime + 2.5;
		fl_ruina_battery_timeout[npc.index] = GameTime + 2.5;
		npc.m_flNextChargeSpecialAttack = GameTime + 2.5;
		

		npc.m_iRangedAmmo += RoundToFloor(npc.m_iRangedAmmo*0.5);

	}
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flNextTeleport -= 0.25;
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}
static void Twirl_Ruina_Weapon_Lines(Twirl npc, int client)
{
	if(b_force_transformation)
		return;

	if(client > MaxClients)
		return;

	if(b_said_player_weaponline[client])	//only 1 line per player.
		return;

	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

	if(!IsValidEntity(weapon))	//invalid weapon, go back and get a valid one you <...>
		return;

	float GameTime = GetGameTime();	//no need to throttle this.

	if(fl_said_player_weaponline_time[npc.index] > GameTime)	//no spamming in chat please!
		return;

	bool valid = true;
	char Text_Lines[255];

	Text_Lines = "";

	switch(i_CustomWeaponEquipLogic[weapon])
	{
		case WEAPON_MAGNESIS: switch(GetRandomInt(0,1)) 			{case 0: Format(Text_Lines, sizeof(Text_Lines), "I've had it up to here MISTER {gold}%N{snow}.", client); 												case 1: Format(Text_Lines, sizeof(Text_Lines), "How would you feel {gold}%N{snow} if I grabbed YOU?", client);}
		
		case WEAPON_KIT_BLITZKRIEG_CORE: switch(GetRandomInt(0,1)) 	{case 0: Format(Text_Lines, sizeof(Text_Lines), "Oh my, {gold}%N{snow}, you're trying to copy the Machine?", client); 									case 1: Format(Text_Lines, sizeof(Text_Lines), "Ah, how foolish {gold}%N{snow} Blitzkrieg was a poor mistake to copy...", client);}	//IT ACTUALLY WORKS, LMFAO
		case WEAPON_COSMIC_TERROR: switch(GetRandomInt(0,1)) 		{case 0: Format(Text_Lines, sizeof(Text_Lines), "Ah, the Cosmic Terror, haven't seen that relic in a long while"); 										case 1: Format(Text_Lines, sizeof(Text_Lines), "The moon is a deadly laser, am I right {gold}%N{snow}?",client);}
		case WEAPON_LANTEAN: switch(GetRandomInt(0,1)) 				{case 0: Format(Text_Lines, sizeof(Text_Lines), "Ah, {gold}%N{snow}, Those drones, {crimson}how cute...", client); 										case 1: Format(Text_Lines, sizeof(Text_Lines), "I applaud your efforts {gold}%N{snow} for trying to use the Lantean staff here...", client);}
		case WEAPON_YAMATO: switch(GetRandomInt(0,1)) 				{case 0: Format(Text_Lines, sizeof(Text_Lines), "Oh, {gold}%N{snow}'s a little {aqua}Motivated", client); 												case 1: Format(Text_Lines, sizeof(Text_Lines), "Go fourth {gold}%N{snow}, AND BECOME {aqua}THE STORM THAT IS APROACHING{crimson}!", client);}
		case WEAPON_BEAM_PAP: switch(GetRandomInt(0,1)) 			{case 0: Format(Text_Lines, sizeof(Text_Lines), "Ah, dual energy Pylons, nice choice {gold}%N", client); 												case 1: Format(Text_Lines, sizeof(Text_Lines), "So, are you Team {aqua}Particle Cannon{snow} or Team{orange} Particle Beam{gold} %N{snow}?", client);}	
		case WEAPON_FANTASY_BLADE: switch(GetRandomInt(0,1)) 		{case 0: Format(Text_Lines, sizeof(Text_Lines), "Oh how {crimson}cute{gold} %N{snow}, you're using {crimson}Karlas's{snow} Old blade", client); 		case 1: Format(Text_Lines, sizeof(Text_Lines), "The Fantasy blade is quite the weapon, {gold}%N{snow} but you're not using it correctly.", client);}	
		case WEAPON_QUINCY_BOW: switch(GetRandomInt(0,1)) 			{case 0: Format(Text_Lines, sizeof(Text_Lines), "Oh, {gold}%N{snow}'s being a {aqua}Quincy{snow}, quick call the {crimson}Shinigami{snow}!", client);	case 1: Format(Text_Lines, sizeof(Text_Lines), "Ah, what a shame {gold}%N{snow} Here I thought you were a true {aqua}Quincy", client);}	
		case WEAPON_ION_BEAM: switch(GetRandomInt(0,1)) 			{case 0: Format(Text_Lines, sizeof(Text_Lines), "That laser is still quite young {gold}%N{snow} It needs more upgrades",client); 						case 1: Format(Text_Lines, sizeof(Text_Lines), "Your Prismatic Laser has potential {gold}%N{snow}!", client);}	
		case WEAPON_ION_BEAM_PULSE: switch(GetRandomInt(0,1)) 		{case 0: Format(Text_Lines, sizeof(Text_Lines), "I see, {gold}%N{snow}, You decided to go down the pulse path!", client); 								case 1: Format(Text_Lines, sizeof(Text_Lines), "I do quite enjoy a faster pulsating laser, just like you {gold}%N{snow} by the looks of it", client);}	
		case WEAPON_ION_BEAM_NIGHT: switch(GetRandomInt(0,1)) 		{case 0: Format(Text_Lines, sizeof(Text_Lines), "Oh my, are you {gold}%N{snow}, trying to cosplay as {aqua}Stella{snow}?", client); 					case 1: Format(Text_Lines, sizeof(Text_Lines), "That Laser Tickles {gold}%N{crimson} Get a bigger laser{aqua} NOW!", client);}
		case WEAPON_ION_BEAM_FEED: switch(GetRandomInt(0,1)) 		{case 0: Format(Text_Lines, sizeof(Text_Lines), "A cascading feedback loop laser, ballsy {gold}%N", client); 											case 1: Format(Text_Lines, sizeof(Text_Lines), "Prismatic Feedback loop is a very powerful weapon, but its also quite hard to master... {gold}%N", client);}				
		case WEAPON_IMPACT_LANCE: switch(GetRandomInt(0,1)) 		{case 0: Format(Text_Lines, sizeof(Text_Lines), "You’re seriously trying to poke me with that thing {gold}%N{snow}?", client); 							case 1: Format(Text_Lines, sizeof(Text_Lines), "{gold}%N{snow}, You don't have the needed skills to properly use the lance.", client);}	
		case WEAPON_GRAVATON_WAND: switch(GetRandomInt(0,1)) 		{case 0: Format(Text_Lines, sizeof(Text_Lines), "How does it feel to control a fraction of gravity{gold} %N{snow}?", client); 							case 1: Format(Text_Lines, sizeof(Text_Lines), "The Gravaton wand was only a partial success, and yet {gold}%N{snow}, you’re using it...", client);}
		case WEAPON_BOBS_GUN:  Format(Text_Lines, sizeof(Text_Lines), "BOBS GUN?! {crimson}GET AWAY FROM ME!!!!!!!!!! {gold}%N", client); 	
		
		case WEAPON_KIT_FRACTAL: 
		{
			switch(GetRandomInt(0,4)) 		
			{
				case 0: Format(Text_Lines, sizeof(Text_Lines), "Ahhh, so your trying to use my own power's against me {gold}%N{snow}?", client); 				
				case 1: Format(Text_Lines, sizeof(Text_Lines), "Tell me {gold}%N{snow} Do you take pleasure in stealing other people's belongings?", client);
				case 2: Format(Text_Lines, sizeof(Text_Lines), "So you {gold}%N{snow} just taught me that the people at the department of anti-theft are complete idiots, I'm firing them when I get home", client);
				case 3:
				{
					if(!IsValidEntity(Cosmetic_WearableExtra[client]))
						Format(Text_Lines, sizeof(Text_Lines), "{gold}%N{snow} You don't even have the wings, how dare you use that?", client);
					else
					{
						if(MagiaWingsDo(client))
						{
							Format(Text_Lines, sizeof(Text_Lines), "{gold}%N{snow} You, you have OUR WINGS???, And your using the {aqua}Fractal{snow}, atleast that makes sense", client);
						}
						else if(SilvesterWingsDo(client))
						{
							Format(Text_Lines, sizeof(Text_Lines), "{gold}%N{snow} Wait a minute, those are {gold}Silvesters{snow} wings, and your using our spells?. That doesn't make sense", client);
						}
						else
						{
							Format(Text_Lines, sizeof(Text_Lines), "You Mr {gold}%N{snow} are using MY {aqua}Fractal{snow}, but you're wings aren't known to me.. huh?", client);
						}
					}
				}
				case 4: Format(Text_Lines, sizeof(Text_Lines), "Mr {gold}%N{snow}. I'm coming for you. {crimson}you cannot hide{snow}. You will pay for stealing the {aqua}Fractal{snow}.", client);
			}
		}
		default:
		{
			valid = false;
		}
	}

	if(valid)
	{
		Twirl_Lines(npc, Text_Lines);
		fl_said_player_weaponline_time[npc.index] = GameTime + GetRandomFloat(17.0, 26.0);
		b_said_player_weaponline[client] = true;
	}
}

static void Kill_Abilities(Twirl npc)
{
	SDKUnhook(npc.index, SDKHook_Think, Retreat_Laser_Tick);
	SDKUnhook(npc.index, SDKHook_Think, Cosmic_Gaze_Tick);
	SDKUnhook(npc.index, SDKHook_Think, Magia_Overflow_Tick);
	SDKUnhook(npc.index, SDKHook_Think, Lunar_Radiance_Tick);
	SDKUnhook(npc.index, SDKHook_Think, IonicFracture_Think);

	for(int i= 0 ; i < 3 ; i ++)
	{
		int ent = EntRefToEntIndex(i_lunar_entities[npc.index][i]);
		if(IsValidEntity(ent))
			RemoveEntity(ent);

		i_lunar_entities[npc.index][i] = INVALID_ENT_REFERENCE;
	}

	npc.m_flIonicFractureEndTimer = 0.0;

	StopSound(npc.index, SNDCHAN_STATIC, "player/taunt_surgeons_squeezebox_music.wav");
	StopSound(npc.index, SNDCHAN_STATIC, TWIRL_COSMIC_GAZE_LOOP_SOUND1);
	StopSound(npc.index, SNDCHAN_STATIC, TWIRL_COSMIC_GAZE_LOOP_SOUND1);
	StopSound(npc.index, SNDCHAN_STATIC, TWIRL_LASER_SOUND);
	StopSound(npc.index, SNDCHAN_STATIC, TWIRL_LASER_SOUND);
	StopSound(npc.index, SNDCHAN_STATIC, TWIRL_IONIC_FRACTURE_PASSIVE_SOUND);
	StopSound(npc.index, SNDCHAN_STATIC, TWIRL_IONIC_FRACTURE_PASSIVE_SOUND);
	StopSound(npc.index, SNDCHAN_STATIC, TWIRL_IONIC_FRACTURE_PASSIVE_SOUND);
	StopSound(npc.index, SNDCHAN_STATIC, TWIRL_IONIC_FRACTURE_PASSIVE_SOUND2);
	StopSound(npc.index, SNDCHAN_STATIC, TWIRL_IONIC_FRACTURE_PASSIVE_SOUND2);
	StopSound(npc.index, SNDCHAN_STATIC, TWIRL_IONIC_FRACTURE_PASSIVE_SOUND2);
	StopSound(npc.index, SNDCHAN_STATIC, TWIRL_IONIC_FRACTURE_PASSIVE_SOUND3);
	StopSound(npc.index, SNDCHAN_STATIC, TWIRL_IONIC_FRACTURE_PASSIVE_SOUND3);
	StopSound(npc.index, SNDCHAN_STATIC, TWIRL_IONIC_FRACTURE_PASSIVE_SOUND3);

	npc.m_bInKame = false;
}

static void NPC_Death(int entity)
{
	Twirl npc = view_as<Twirl>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}

	Kill_Abilities(npc);

	Ruina_NPCDeath_Override(npc.index);
	ExpidonsaRemoveEffects(entity);


	int ent = EntRefToEntIndex(npc.m_iHandParticle);
	if(IsValidEntity(ent))
	{
		RemoveEntity(ent);
	}
	npc.m_iHandParticle = INVALID_ENT_REFERENCE;

	b_tripple_raid = false;


	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
	ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);

	if(!b_wonviakill && !b_wonviatimer && !b_allow_final)
	{	
		int wave = i_current_wave[npc.index];
		if(b_force_transformation)
		{
			switch(GetRandomInt(0, 1))
			{
				case 0: Twirl_Lines(npc, "{crimson}Bye");
				case 1: Twirl_Lines(npc, "{crimson}I'm Leaving.");
			}
		}
		else if(wave <=10)
		{
			switch(GetRandomInt(0, 4))
			{
				case 0: Twirl_Lines(npc, "Ah, this is great, I have high hopes for our next encounter");
				case 1: Twirl_Lines(npc, "You're strong, I like that, till next time");						//HEY ITS ME GOKU, I HEARD YOUR ADDICTION IS STRONG, LET ME FIGHT IT
				case 2: Twirl_Lines(npc, "Ahaha, toodles");
				case 3: Twirl_Lines(npc, "Magnificent, just what I was hoping for");
				case 4: Twirl_Lines(npc, "How interesting..");
			}
		}
		else if(wave <=20)
		{
			switch(GetRandomInt(0, 4))
			{
				case 0: Twirl_Lines(npc, "This was great fun, better not let me down and not make it to our next battle!");
				case 1: Twirl_Lines(npc, "Oh my, I may have underestimated you, this is great news");
				case 2: Twirl_Lines(npc, "I'll have to give {aqua}Stella{snow} a little treat, this has been great fun");
				case 3: Twirl_Lines(npc, "Most excellent, you bested me, hope to see you again!");
				case 4: Twirl_Lines(npc, "The simulations seem to be off..");
			}
		}
		else if(wave <=30)
		{
			switch(GetRandomInt(0, 4))
			{
				case 0: Twirl_Lines(npc, "Even with my {purple}''Heavy Equipment''{snow} you bested me, good work");
				case 1: Twirl_Lines(npc, "You're quite strong, can't wait for our next match");
				case 2: Twirl_Lines(npc, "I hope you all had as much fun as I did");
				case 3: Twirl_Lines(npc, "You've all exceeded my expectations, I do believe our next and final battle will be the {crimson}most fun{snow}!");
				case 4: Twirl_Lines(npc, "Whoever made those simulations is gonna get fired..");
			}
		}
		else
		{
			if(b_tripple_raid)
			{
				switch(GetRandomInt(0, 2))
				{
					case 0: Twirl_Lines(npc, "Nice job.");
					case 1: Twirl_Lines(npc, "Ehe, this has been quite entertaining, I hope we meet again in the future");
					case 2: Twirl_Lines(npc, "Good luck with the rest~");
				}
			}
			else
			{
				switch(GetRandomInt(1, 4))
				{
					case 1: Twirl_Lines(npc, "Ehe, this has been quite entertaining, I hope we meet again in the future");
					case 2: Twirl_Lines(npc, "And so, our battle has ended, you've won this.");
					case 3: Twirl_Lines(npc, "toodles!");
					case 4: Twirl_Lines(npc, "{crimson}How Cute{snow}.");
				}
			}
		}
	}

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
	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);
	if(IsValidEntity(npc.m_iWearable8))
		RemoveEntity(npc.m_iWearable8);
	
}

static void Get_Fake_Forward_Vec(float Range, float vecAngles[3], float Vec_Target[3], float Pos[3])
{
	float Direction[3];
	
	GetAngleVectors(vecAngles, Direction, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(Direction, Range);
	AddVectors(Pos, Direction, Vec_Target);
}
bool Similar_Vec(float Vec1[3], float Vec2[3])
{
	for(int i=0 ; i < 3 ; i ++)
	{
		if(!Similar(Vec1[i], Vec2[i]))
			return false;
	}
	return true;
}
static bool Similar(float val1, float val2)
{
	return fabs(val1 - val2) < 2.0;
}

static void Twirl_Lines(Twirl npc, const char[] text)
{
	if(b_test_mode)
		return;

	CPrintToChatAll("%s %s", npc.GetName(), text);
}
static float[] GetNPCAngles(CClotBody npc)
{
	float Angles[3];
	GetEntPropVector(npc.index, Prop_Data, "m_angRotation", Angles);
	int iPitch = npc.LookupPoseParameter("body_pitch");
			
	float flPitch = npc.GetPoseParameter(iPitch);
	flPitch *= -1.0;
	Angles[0] = flPitch;

	return Angles;
}
static bool HandleRaidTimer(Twirl npc)
{
	if(RaidModeTime < GetGameTime())
	{
		ForcePlayerLoss();
		RaidBossActive = INVALID_ENT_REFERENCE;
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		int wave = i_current_wave[npc.index];
		b_wonviatimer = true;
		if(b_force_transformation)
		{
			Twirl_Lines(npc, "Begone. Times Up.");
		}
		else if(wave <=40)
		{
			switch(GetRandomInt(0, 9))
			{
				case 0: Twirl_Lines(npc, "Ahhh, that was a nice walk");
				case 1: Twirl_Lines(npc, "Heh, I suppose that was somewhat fun");
				case 2: Twirl_Lines(npc, "I must say {aqua}Stella{snow} may have overhyped this..");
				case 3: Twirl_Lines(npc, "Amazingly you were all too slow to die.");
				case 4: Twirl_Lines(npc, "Times up, I’ve got better things to do, so here, {crimson}have this parting gift{snow}!");
				case 5: Twirl_Lines(npc, "Clearly you all lack proper fighting spirit to take this long, that’s it, {crimson}I’m ending this");
				case 6: Twirl_Lines(npc, "My oh my, even after having such a large amount of time, you still couldn't do it, shame");
				case 7: Twirl_Lines(npc, "I dont even have {gold}Expidonsan{default} shielding, cmon.");
				case 8: Twirl_Lines(npc, "Tell me why you're this slow?");
				case 9: Twirl_Lines(npc, "I’m bored. {crimson}Ei, jus viršui, atekit čia ir užbaikit juos");
			}
		}
		else	//freeplay
		{
			switch(GetRandomInt(0, 2))
			{
				case 0: Twirl_Lines(npc, "Well considering you all were just some randoms this was to be expected");
				case 1: Twirl_Lines(npc, "Guess my sense of magic's been off lately, this was exceedingly boring.");
				case 2: Twirl_Lines(npc, "{crimson}How Cute{snow}.");
			}
		}
		
		return true;
	}
	return false;
}
void Twirl_OnStellaKarlasDeath()
{
	int Raids[3];
	Raids = i_GetAllPartiesInvolved();
	//twirl is dead, simple.

	int Twirl_index = Raids[0],
		Stella_index = Raids[1],
		Karlas_index = Raids[2];

	if(!IsValidEntity(Twirl_index))
		return;

	Twirl npc = view_as<Twirl>(Twirl_index);

	//stella died first.
	if(!Stella_index && Karlas_index)
	{
		Twirl_Lines(npc, "{crimson}Karlas{snow}! Switch to me, I'm now your priority");

		Set_Karlas_Ally(npc.index, Karlas_index, i_current_wave[npc.index], false, true);
		Stella stella = view_as<Stella>(npc.index);
		Karlas karl = view_as<Karlas>(Karlas_index);
		karl.m_flNextRangedBarrage_Singular -= 15.0;
		karl.Anger = true;
		stella.m_bKarlasRetreat = false;
	}
	//Karlas died first
	else if(Stella_index && !Karlas_index)
	{
		switch(GetRandomInt(0, 2))
		{
			case 0: Twirl_Lines(npc, "Hey, just because hes the only man here doesn't mean he should have died first.");
			case 1: Twirl_Lines(npc, "Oh, neat, now {aqua}Stella{snow}'s all mine.");
			case 2: Twirl_Lines(npc, "Huh, there goes my rival.");
		}
		
	}
	//both are dead.
	else if(!Stella_index && !Karlas_index)
	{
		b_force_transformation = true;
		switch(GetRandomInt(0, 2))
		{
			case 0:Twirl_Lines(npc, "Ohoh, You think this is gonna end easily, you are {crimson}SORELY MISTAKEN");
			case 1:Twirl_Lines(npc, "{crimson}I won't let you win");
			case 2:Twirl_Lines(npc, "{crimson}This is where your story ends");
		}
		b_tripple_raid = false;
		if(fl_Extra_Damage[npc.index] < 1.0)
			fl_Extra_Damage[npc.index] = 1.0;
		if(fl_Extra_Speed[npc.index] < 1.0)
			fl_Extra_Speed[npc.index] = 1.0;
		npc.m_iRangedAmmo += RoundToFloor(npc.m_iRangedAmmo*0.5);

		ApplyStatusEffect(npc.index, npc.index, "Ruina's Defense", 999.0);
		NpcStats_RuinaDefenseStengthen(npc.index, 0.8);	//20% resistances
		ApplyStatusEffect(npc.index, npc.index, "Ruina's Agility", 999.0);
		NpcStats_RuinaAgilityStengthen(npc.index, 1.2); //20% speed bonus, going bellow 1.0 will make npc's slower
		ApplyStatusEffect(npc.index, npc.index, "Ruina's Damage", 999.0);
		NpcStats_RuinaDamageStengthen(npc.index, 0.2);	//20% dmg bonus
	}
}
static int[] i_GetAllPartiesInvolved()
{
	int BothAlive[3] = {0, 0, 0};
	for(int i; i < i_MaxcountNpcTotal; i++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if(IsValidEntity(entity))
		{
			char npc_classname[60];
			NPC_GetPluginById(i_NpcInternalId[entity], npc_classname, sizeof(npc_classname));

			if(entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity) && !b_NpcHasDied[entity])
			{
				if(StrEqual(npc_classname, "npc_ruina_twirl"))
				{
					BothAlive[0] = entity;
				}
				else if(StrEqual(npc_classname, "npc_stella"))
				{
					BothAlive[1] = entity;
				}
				else if(StrEqual(npc_classname, "npc_karlas"))
				{
					BothAlive[2] = entity;
				}
			}
		}
	}
	return BothAlive;
}


void TwirlEarsApply(int iNpc, char[] attachment = "head", float size = 1.0)
{
	int red = 255;
	int green = 255;
	int blue = 255;
	float flPos[3];
	float flAng[3];
	int particle_ears1 = InfoTargetParentAt({0.0,0.0,0.0}, "", 0.0); //This is the root bone basically
	
	//fist ear
	float DoApply[3];
	DoApply = {0.0,-2.5,-7.5};
	DoApply[0] *= size;
	DoApply[1] *= size;
	DoApply[2] *= size;
	int particle_ears2 = InfoTargetParentAt(DoApply, "", 0.0); //First offset we go by
	DoApply = {0.0,0.0,-11.5};
	DoApply[0] *= size;
	DoApply[1] *= size;
	DoApply[2] *= size;
	int particle_ears3 = InfoTargetParentAt(DoApply, "", 0.0); //First offset we go by
	DoApply = {0.0,-12.0,-7.5};
	DoApply[0] *= size;
	DoApply[1] *= size;
	DoApply[2] *= size;
	int particle_ears4 = InfoTargetParentAt(DoApply, "", 0.0); //First offset we go by
	
	//fist ear
	DoApply = {0.0,2.5,-7.5};
	DoApply[0] *= size;
	DoApply[1] *= size;
	DoApply[2] *= size;
	int particle_ears2_r = InfoTargetParentAt(DoApply, "", 0.0); //First offset we go by
	DoApply = {0.0,0.0,-11.5};
	DoApply[0] *= size;
	DoApply[1] *= size;
	DoApply[2] *= size;
	int particle_ears3_r = InfoTargetParentAt(DoApply, "", 0.0); //First offset we go by
	DoApply = {0.0,12.0,-7.5};
	DoApply[0] *= size;
	DoApply[1] *= size;
	DoApply[2] *= size;
	int particle_ears4_r = InfoTargetParentAt(DoApply, "", 0.0); //First offset we go by

	SetParent(particle_ears1, particle_ears2, "",_, true);
	SetParent(particle_ears1, particle_ears3, "",_, true);
	SetParent(particle_ears1, particle_ears4, "",_, true);
	SetParent(particle_ears1, particle_ears2_r, "",_, true);
	SetParent(particle_ears1, particle_ears3_r, "",_, true);
	SetParent(particle_ears1, particle_ears4_r, "",_, true);
	Custom_SDKCall_SetLocalOrigin(particle_ears1, flPos);
	SetEntPropVector(particle_ears1, Prop_Data, "m_angRotation", flAng); 
	SetParent(iNpc, particle_ears1, attachment,_);


	int Laser_ears_1 = ConnectWithBeamClient(particle_ears4, particle_ears2, red, green, blue, 1.0 * size, 1.0 * size, 1.0, LASERBEAM);
	int Laser_ears_2 = ConnectWithBeamClient(particle_ears4, particle_ears3, red, green, blue, 1.0 * size, 1.0 * size, 1.0, LASERBEAM);

	int Laser_ears_1_r = ConnectWithBeamClient(particle_ears4_r, particle_ears2_r, red, green, blue, 1.0 * size, 1.0 * size, 1.0, LASERBEAM);
	int Laser_ears_2_r = ConnectWithBeamClient(particle_ears4_r, particle_ears3_r, red, green, blue, 1.0 * size, 1.0 * size, 1.0, LASERBEAM);
	

	i_ExpidonsaEnergyEffect[iNpc][0] = EntIndexToEntRef(particle_ears1);
	i_ExpidonsaEnergyEffect[iNpc][1] = EntIndexToEntRef(particle_ears2);
	i_ExpidonsaEnergyEffect[iNpc][2] = EntIndexToEntRef(particle_ears3);
	i_ExpidonsaEnergyEffect[iNpc][3] = EntIndexToEntRef(particle_ears4);
	i_ExpidonsaEnergyEffect[iNpc][4] = EntIndexToEntRef(Laser_ears_1);
	i_ExpidonsaEnergyEffect[iNpc][5] = EntIndexToEntRef(Laser_ears_2);
	i_ExpidonsaEnergyEffect[iNpc][6] = EntIndexToEntRef(particle_ears2_r);
	i_ExpidonsaEnergyEffect[iNpc][7] = EntIndexToEntRef(particle_ears3_r);
	i_ExpidonsaEnergyEffect[iNpc][8] = EntIndexToEntRef(particle_ears4_r);
	i_ExpidonsaEnergyEffect[iNpc][9] = EntIndexToEntRef(Laser_ears_1_r);
	i_ExpidonsaEnergyEffect[iNpc][10] = EntIndexToEntRef(Laser_ears_2_r);
}
