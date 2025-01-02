#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/medic_paincrticialdeath01.mp3",
	"vo/medic_paincrticialdeath02.mp3",
	"vo/medic_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/medic_painsharp01.mp3",
	"vo/medic_painsharp02.mp3",
	"vo/medic_painsharp03.mp3",
	"vo/medic_painsharp04.mp3",
	"vo/medic_painsharp05.mp3",
	"vo/medic_painsharp06.mp3",
	"vo/medic_painsharp07.mp3",
	"vo/medic_painsharp08.mp3",
};

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

static bool b_InKame[MAXENTITIES];
#define TWIRL_TE_DURATION 0.1
#define RAIDBOSS_TWIRL_THEME "#zombiesurvival/ruina/raid_theme_2.mp3"
static bool b_said_player_weaponline[MAXTF2PLAYERS];
static float fl_said_player_weaponline_time[MAXENTITIES];
static float fl_player_weapon_score[MAXTF2PLAYERS];

static int i_melee_combo[MAXENTITIES];
static int i_current_wave[MAXENTITIES];
static float fl_retreat_timer[MAXENTITIES];
static int i_ranged_ammo[MAXENTITIES];
static int i_hand_particles[MAXENTITIES];
static float fl_force_ranged[MAXENTITIES];
static float fl_comsic_gaze_timer[MAXENTITIES];
static bool b_tripple_raid[MAXENTITIES];

static float fl_npc_basespeed;

static int i_barrage_ammo[MAXENTITIES];
static int i_lunar_ammo[MAXENTITIES];
static float fl_lunar_timer[MAXENTITIES];
static bool b_lastman[MAXENTITIES];
static bool b_wonviatimer[MAXENTITIES];
static bool b_wonviakill[MAXENTITIES];
static bool b_allow_final[MAXENTITIES];
static float fl_next_textline[MAXENTITIES];
static float fl_raidmode_freeze[MAXENTITIES];
static int i_current_Text[MAXENTITIES];

static float fl_final_invocation_timer[MAXENTITIES];
static bool b_allow_final_invocation[MAXENTITIES];
static float fl_final_invocation_logic[MAXENTITIES];

static float fl_magia_overflow_recharge[MAXENTITIES];
static bool b_test_mode[MAXENTITIES];

static const char Cosmic_Launch_Sounds[][] ={
	"weapons/physcannon/superphys_launch1.wav",
	"weapons/physcannon/superphys_launch2.wav",
	"weapons/physcannon/superphys_launch3.wav",
	"weapons/physcannon/superphys_launch4.wav"
}; 
static char gGlow1;	//blue
#define TWIRL_THUMP_SOUND				"ambient/machines/thumper_hit.wav"
#define TWIRL_COSMIC_GAZE_LOOP_SOUND1 	"weapons/physcannon/energy_sing_loop4.wav"
#define TWIRL_LASER_SOUND 		"zombiesurvival/seaborn/loop_laser.mp3"
#define TWIRL_COSMIC_GAZE_END_SOUND1 	"weapons/physcannon/physcannon_drop.wav"
#define TWIRL_COSMIC_GAZE_END_SOUND2 	"ambient/energy/whiteflash.wav"

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
	Zero(i_barrage_ammo);
	Zero(fl_force_ranged);
	Zero(fl_retreat_timer);
	Zero(fl_comsic_gaze_timer);
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_RangeAttackSounds);
	PrecacheSoundArray(g_TeleportSounds);
	PrecacheSoundArray(Cosmic_Launch_Sounds);
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
static float fl_nightmare_cannon_core_sound_timer[MAXENTITIES];
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
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleSound()");
		#endif
	}
	
	public void PlayTeleportSound() {
		EmitSoundToAll(g_TeleportSounds[GetRandomInt(0, sizeof(g_TeleportSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayTeleportSound()");
		#endif
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
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
			
	}

	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
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
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::Playnpc.AngerSound()");
		#endif
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
		Ruina_Color(color);

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
		if(i_melee_combo[this.index]>amt)
		{
			i_melee_combo[this.index] = 0;
			fired = true;
		}
		else
		{
			i_melee_combo[this.index]++;
		}
		if(i_melee_combo[this.index]>=amt)
		{
			if(!IsValidEntity(EntRefToEntIndex(i_hand_particles[this.index])))
			{
				float flPos[3], flAng[3];
				this.GetAttachment("effect_hand_r", flPos, flAng);
				i_hand_particles[this.index] = EntIndexToEntRef(ParticleEffectAt_Parent(flPos, "raygun_projectile_blue_crit", this.index, "effect_hand_r", {0.0,0.0,0.0}));
			}
		}
		else
		{
			int ent = EntRefToEntIndex(i_hand_particles[this.index]);
			if(IsValidEntity(ent))
			{
				RemoveEntity(ent);
				i_hand_particles[this.index] = INVALID_ENT_REFERENCE;
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
		if(fl_force_ranged[this.index] > GameTime)
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
			if(wave<=15)	
			{
				return RUINA_TWIRL_CREST_1;
			}
			else if(wave <=30)	
			{
				return RUINA_TWIRL_CREST_2;
			}
			else if(wave <= 45)	
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
			if(wave<=15)	
			{
				return RUINA_TWIRL_MELEE_1;
			}
			else if(wave <=30)	
			{
				return RUINA_TWIRL_MELEE_2;
			}
			else if(wave <= 45)	
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

	public char[] GetName()
	{
		char Name[255];
		Format(Name, sizeof(Name), "%s%s%s:", NameColour, c_NpcName[this.index], TextColour);
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
	
	
	public Twirl(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Twirl npc = view_as<Twirl>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "1250", ally));
		
		npc.m_iChanged_WalkCycle = 1;
		i_barrage_ammo[npc.index] = 0;
		i_melee_combo[npc.index] = 0;
		i_lunar_ammo[npc.index] = 0;
		b_lastman[npc.index] = false;
		b_wonviatimer[npc.index] = false;
		b_wonviakill[npc.index] = false;

		Zero(b_said_player_weaponline);
		fl_said_player_weaponline_time[npc.index] = GetGameTime() + GetRandomFloat(0.0, 5.0);

		c_NpcName[npc.index] = "Twirl";

		b_test_mode[npc.index] = StrContains(data, "test") != -1;

		int wave = ZR_GetWaveCount()+1;

		if(StrContains(data, "force15") != -1)
			wave = 15;
		if(StrContains(data, "force30") != -1)
			wave = 30;
		if(StrContains(data, "force45") != -1)
			wave = 45;
		if(StrContains(data, "force60") != -1)
			wave = 60;

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
	
		fl_next_textline[npc.index] = 0.0;
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "item_armor", 1, "%t", "Twirl Spawn");
			}
		}
		b_tripple_raid[npc.index] = false;
		bool default_theme = true;
		if((StrContains(data, "triple_enemies") != -1))
		{
			b_tripple_raid[npc.index] = true;
			default_theme = false;
		}
		RemoveAllDamageAddition();
			

		if(default_theme)
		{
			MusicEnum music;
			strcopy(music.Path, sizeof(music.Path), RAIDBOSS_TWIRL_THEME);
			music.Time = 285;
			music.Volume = 2.0;
			music.Custom = true;
			strcopy(music.Name, sizeof(music.Name), "Solar Sect of Mystic Wisdom ~ Nuclear Fusion");
			strcopy(music.Artist, sizeof(music.Artist), "maritumix/まりつみ");
			Music_SetRaidMusic(music);	
		}
		
		b_allow_final[npc.index] = StrContains(data, "final_item") != -1;
		TwirlEarsApply(npc.index,_,0.75);


		if(b_allow_final[npc.index])
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
		
		RaidModeScaling = float(ZR_GetWaveCount()+1);
		
		if(RaidModeScaling < 55)
		{
			RaidModeScaling *= 0.19; //abit low, inreacing
		}
		else
		{
			RaidModeScaling *= 0.38;
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

		
		

		if(StrContains(data, "triple_enemies") != -1)
		{
			Twirl_Lines(npc, "Oh my, looks like the expidonsans went easy on you, we sure wont my dears. Us ruanians work differently~");
			Twirl_Lines(npc, "... Except Karlas but shhhh!");
			CPrintToChatAll("{crimson}Karlas{snow}: .....");
			CPrintToChatAll("{crimson}Karlas{snow}: :(");
			RaidModeTime = GetGameTime(npc.index) + 500.0;
			GiveOneRevive(true);
		}
		else if(wave <=15)
		{
			i_ranged_ammo[npc.index] = 5;
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
		else if(wave <=30)
		{
			i_ranged_ammo[npc.index] = 7;
			switch(GetRandomInt(0, 4))
			{
				case 0: Twirl_Lines(npc, "Last time, it was a great workout, {crimson}Time to do it again{snow}!");
				case 1: Twirl_Lines(npc, "Our last fight was so fun, I hope this fight is as fun as the last one!");
				case 2: Twirl_Lines(npc, "{aqua}Stella{snow} was right, you all ARE great fun to play with!");
				case 3: Twirl_Lines(npc, "Ehe, now who will die {crimson}last{snow}?");
				case 4: Twirl_Lines(npc, "You spin me right round..");
			}
		}
		else if(wave <=45)
		{
			i_ranged_ammo[npc.index] = 9;
			switch(GetRandomInt(0, 4))
			{
				case 0: Twirl_Lines(npc, "My Oh my, you're still here, {purple}how wonderful!");
				case 1: Twirl_Lines(npc, "You must enjoy fighting as much as {purple}I do{snow}, considering you've made it this far!");
				case 2: Twirl_Lines(npc, "{aqua}Stella{snow}, you understated how {purple}fun{snow} this would be!");
				case 3: Twirl_Lines(npc, "I've brought some {purple}Heavy Equipment{snow} heh");
				case 4: Twirl_Lines(npc, "Time to \"Twirl\", heh");
			}
		}
		else if(wave <=60)
		{	
			i_ranged_ammo[npc.index] = 12;
			switch(GetRandomInt(0, 5))
			{
				case 0: Twirl_Lines(npc, "Its time for the final show, {purple}I hope yoyou're all as excited as I am{snow}!");
				case 1: Twirl_Lines(npc, "Ah, it was a {purple}brilliant idea to not use my powers {snow}and only use this crest instead.");
				case 2: Twirl_Lines(npc, "Ah, the fun that {aqua}Stella{snow}'s missing out on,{purple} a shame{snow}.");
				case 3: Twirl_Lines(npc, "I hope you're ready for this final {purple}battle{snow}.");
				case 4: Twirl_Lines(npc, "Kuru Kuru~");
				case 5:
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
			RaidModeScaling *=0.9;
		}
		else	//freeplay
		{
			RaidModeScaling *=0.9;
			i_ranged_ammo[npc.index] = 12;
			switch(GetRandomInt(0, 3))
			{
				case 1: Twirl_Lines(npc, "So the flow of magic lead me here, {purple}how interesting{snow}...");
				case 2: Twirl_Lines(npc, "Oh, its you all, hey, wanna {crimson}fight{snow}? {purple}of course you do{snow}!");
				case 3: Twirl_Lines(npc, "I need to unwind, and you all look {crimson}perfect{snow} for that!");
			}
		}

		i_current_Text[npc.index] = 0;

		npc.m_flDoingAnimation = 0.0;

		npc.m_flNextTeleport = GetGameTime(npc.index) + GetRandomFloat(5.0, 10.0);
		npc.m_flNextRangedBarrage_Spam = GetGameTime(npc.index) + GetRandomFloat(5.0, 10.0);
		fl_comsic_gaze_timer[npc.index] = GetGameTime(npc.index)  + GetRandomFloat(5.0, 10.0);
		fl_lunar_timer[npc.index] = GetGameTime(npc.index) + GetRandomFloat(10.0, 20.0);
		fl_magia_overflow_recharge[npc.index] = GetGameTime(npc.index) + GetRandomFloat(10.0, 20.0);
		fl_final_invocation_timer[npc.index] = 0.0;
		fl_final_invocation_logic[npc.index] = 0.0;
		b_allow_final_invocation[npc.index] = false;

		Ruina_Set_Heirarchy(npc.index, RUINA_GLOBAL_NPC);
		Ruina_Set_Master_Heirarchy(npc.index, RUINA_GLOBAL_NPC, true, 999, 999);	

		if(!b_test_mode[npc.index])	//my EARS
		{
			EmitSoundToAll("mvm/mvm_tele_deliver.wav", _, _, _, _, _, RUINA_NPC_PITCH);
			EmitSoundToAll("mvm/mvm_tele_deliver.wav", _, _, _, _, _, RUINA_NPC_PITCH);
		}	

		if(b_test_mode[npc.index])
		{
			RaidModeTime = FAR_FUTURE;
		}

		npc.m_flMeleeArmor = 1.5;

		npc.m_bInKame = false;

		if(StrContains(data, "blockinv") != -1)
			fl_final_invocation_timer[npc.index] = FAR_FUTURE;

		Zero(fl_player_weapon_score);
		
		return npc;
	}
}


static void Twirl_WinLine(int entity)
{
	b_wonviakill[entity] = true;
	Twirl npc = view_as<Twirl>(entity);
	if(b_wonviatimer[npc.index])
		return;

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

	if(npc.m_flNextThinkTime == FAR_FUTURE && b_allow_final[npc.index])
	{
		GameTime = GetGameTime();	//No slowing it down!
		RaidModeTime = fl_raidmode_freeze[npc.index] + GameTime;	//"freeze" the raid timer
		if(npc.m_iChanged_WalkCycle != 99)
		{
			if(IsValidEntity(npc.m_iWearable1))
				RemoveEntity(npc.m_iWearable1);

			npc.m_iChanged_WalkCycle = 99;
			npc.m_bisWalking = false;
			npc.AddActivityViaSequence("competitive_loserstate_idle");
			
		}
		if(fl_next_textline[npc.index] < GameTime)
		{	
			fl_next_textline[npc.index] = GameTime + 3.0;
			switch(i_current_Text[npc.index])
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
					for (int client = 0; client < MaxClients; client++)
					{
						if(IsValidClient(client) && GetClientTeam(client) == 2 && TeutonType[client] != TEUTON_WAITING)
						{
							Items_GiveNamedItem(client, "Twirl's Hairpins");
							CPrintToChat(client,"You have been given {purple}%s{snow}'s hairpins...", c_NpcName[npc.index]);
						}
					}
					Twirl_Lines(npc, "Make sure to take good care of them... or else.");
					return;
				}
			}
			i_current_Text[npc.index]++;
		}
		return;
	}

	if(LastMann && !b_lastman[npc.index])
	{
		b_lastman[npc.index] = true;
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

	if(RaidModeTime < GetGameTime())
	{
		ForcePlayerLoss();
		RaidBossActive = INVALID_ENT_REFERENCE;
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		int wave = i_current_wave[npc.index];
		b_wonviatimer[npc.index] = true;
		if(wave <=60)
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
		
		return;
	}

	if(npc.Anger && npc.m_flNextChargeSpecialAttack < GetGameTime(npc.index) && npc.m_flNextChargeSpecialAttack != FAR_FUTURE)
	{
		npc.m_flNextChargeSpecialAttack = FAR_FUTURE;

		b_NpcIsInvulnerable[npc.index] = false; //Special huds for invul targets
		f_NpcTurnPenalty[npc.index] = 1.0;
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
		fl_magia_overflow_recharge[npc.index] -= 15.0;
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

	if(npc.m_flNextDelayTime > GameTime)
	{
		return;
	}

	if(b_allow_final_invocation[npc.index])
	{
		if(fl_final_invocation_timer[npc.index] != FAR_FUTURE)
		{
			fl_final_invocation_timer[npc.index] = FAR_FUTURE;
			//fl_final_invocation_logic[npc.index] = GetGameTime() + 5.0;
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

	if(b_allow_final_invocation[npc.index])
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
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
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
	int enemy_2[MAXTF2PLAYERS];
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
			if(GetTeam(npc.index) != TFTeam_Red)
			{
				NpcAddedToZombiesLeftCurrently(spawn_index, true);
			}
			TeleportDiversioToRandLocation(spawn_index, true);
			SetEntProp(spawn_index, Prop_Data, "m_iHealth", RoundToCeil(Tower_Health));
			SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", RoundToCeil(Tower_Health));
		}
	}
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
	RaidModeTime += 60.0;

	GiveOneRevive(false);
	switch(GetRandomInt(0, 1))
	{
		case 0: Twirl_Lines(npc, "Hm? Whats this? You seem eager?");
		case 1: Twirl_Lines(npc, "Oh my, looks like this wont be as easy as i thought...");
	}

	for(int i=0 ; i < MaxClients ; i++)
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
static float fl_lunar_throttle[MAXENTITIES];
static int i_lunar_entities[MAXENTITIES][3];
static float fl_lunar_loop[MAXENTITIES];
static void lunar_Radiance(Twirl npc)
{
	if(i_current_wave[npc.index] <=45)
		return;
	float GameTime = GetGameTime(npc.index);
	if(fl_ruina_battery_timeout[npc.index] > GameTime)
		return;
	if(npc.m_flDoingAnimation > GameTime)
		return;
	if(fl_lunar_timer[npc.index] > GameTime)
		return;

	EmitSoundToAll("player/taunt_surgeons_squeezebox_draw_accordion.wav", npc.index, SNDCHAN_STATIC, SNDLEVEL_RAIDSIREN, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL);
	EmitSoundToAll("player/taunt_surgeons_squeezebox_draw_accordion.wav", npc.index, SNDCHAN_STATIC, SNDLEVEL_RAIDSIREN, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL);

	EmitSoundToAll("npc/attack_helicopter/aheli_charge_up.wav");
	EmitSoundToAll("npc/attack_helicopter/aheli_charge_up.wav");
	
	NPC_StopPathing(npc.index);

	fl_lunar_loop[npc.index] = 0.0;

	for(int i= 0 ; i < 3 ; i ++)
	{
		int ent = EntRefToEntIndex(i_lunar_entities[npc.index][i]);
		if(IsValidEntity(ent))
			RemoveEntity(ent);

		i_lunar_entities[npc.index][i] = INVALID_ENT_REFERENCE;
	}

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
		Ruina_Color(color);
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

	npc.m_flRangedArmor = 0.3;
	npc.m_flMeleeArmor = 0.5;

	fl_lunar_throttle[npc.index] = GameTime + 0.5;
	fl_ruina_battery_timeout[npc.index] = GameTime + 2.5;
	npc.m_flDoingAnimation = GameTime + 2.5;

	SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
	SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 1);

	fl_lunar_timer[npc.index] = 0.0;
	npc.m_bisWalking = false;
	npc.AddActivityViaSequence("taunt_surgeons_squeezebox");
	npc.SetPlaybackRate(0.7);
	npc.SetCycle(0.01);

	i_lunar_ammo[npc.index] = 0;

	npc.m_flSpeed = 0.0;
	
	SDKUnhook(npc.index, SDKHook_Think, lunar_Radiance_Tick);
	SDKHook(npc.index, SDKHook_Think, lunar_Radiance_Tick);
}
static Action Lunar_Radiance_RestoreAnim(Handle Timer, int ref)
{
	int iNPC = EntRefToEntIndex(ref);
	if(!IsValidEntity(iNPC))
		return Plugin_Stop;
	
	Twirl npc = view_as<Twirl>(iNPC);

	float GameTime = GetGameTime(npc.index);

	npc.m_flRangedArmor = 1.0;
	npc.m_flMeleeArmor = 1.5;

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
static void lunar_Radiance_Tick(int iNPC)
{
	Twirl npc = view_as<Twirl>(iNPC);

	float GameTime = GetGameTime(npc.index);

	if(fl_lunar_throttle[npc.index] > GameTime)
		return;

	if(fl_lunar_loop[npc.index] < GameTime)
	{
		fl_lunar_loop[npc.index] = FAR_FUTURE;
		EmitSoundToAll("player/taunt_surgeons_squeezebox_music.wav", npc.index, SNDCHAN_STATIC, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL);
	}

	fl_lunar_throttle[npc.index] = GameTime + 0.1;

	fl_ruina_battery_timeout[npc.index] = GameTime + 2.0;
	npc.m_flDoingAnimation = GameTime + 2.0;

	int amt = i_Lunar_RadianceAmt(npc);

	if(i_lunar_ammo[npc.index] > amt)
	{
		i_lunar_ammo[npc.index] = 0;
		fl_lunar_timer[npc.index] = GameTime + (npc.Anger ? 30.0 : 45.0);
		if(b_tripple_raid[npc.index])
			fl_lunar_timer[npc.index] = GameTime + (npc.Anger ? 50.0 : 60.0);

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

		SDKUnhook(npc.index, SDKHook_Think, lunar_Radiance_Tick);

		return;
	}

	if(fl_lunar_timer[npc.index] > GameTime)
		return;

	fl_lunar_timer[npc.index] = GameTime + fl_Lunar_RadianceTimer(npc);

	i_lunar_ammo[npc.index] +=1;

	UnderTides npcGetInfo = view_as<UnderTides>(npc.index);
	int enemy_2[MAXENTITIES];
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
				NPC_StopPathing(npc.index);
				npc.m_bPathing = false;
				npc.m_bAllowBackWalking=false;
			}
		}
		else
		{
			npc.StartPathing();
			npc.m_bPathing = true;
			npc.m_bAllowBackWalking=false;
		}		
	}
	else
	{
		npc.StartPathing();
		npc.m_bPathing = true;
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
		
		if(npc.m_iState >= i_ranged_ammo[npc.index])	//"ammo"
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

		float 	projectile_speed = (npc.Anger ? 1800.0 : 900.0),
				target_vec[3];

		PredictSubjectPositionForProjectiles(npc, PrimaryThreatIndex, projectile_speed, _,target_vec);

		float Dmg = 21.0;
		float Radius = (npc.Anger ? 150.0 : 100.0);
		char Particle[50];
		if(npc.m_iState % 2)
			Particle = "raygun_projectile_blue";
		else
			Particle = "raygun_projectile_red";

		npc.FireParticleRocket(target_vec, Modify_Damage(-1, Dmg) , projectile_speed , Radius , Particle, _, _, true, flPos);
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

				fl_retreat_timer[npc.index] = GameTime+(Swing_Speed*0.35);

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
						
						if(!b_test_mode[npc.index])	//while testing the kb is annoying *Who would have guessed*
						{
							float Kb = (npc.Anger ? 900.0 : 450.0);

							Custom_Knockback(npc.index, target, Kb, true);
							if(target < MaxClients)
							{
								TF2_AddCondition(target, TFCond_LostFooting, 0.5);
								TF2_AddCondition(target, TFCond_AirCurrent, 0.5);
							}
						}
						Ruina_Add_Mana_Sickness(npc.index, target, 0.1, RoundToNearest(Modify_Damage(target, 7.0)));
					}
					npc.PlayMeleeHitSound();
					
				}
				delete swingTrace;
			}
		}
		else
		{
			if(fl_retreat_timer[npc.index] > GameTime || (flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*2.0 && npc.m_flNextMeleeAttack > GameTime))
			{
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, PrimaryThreatIndex,_,vBackoffPos);
				NPC_SetGoalVector(npc.index, vBackoffPos, true);
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

static float Modify_Damage(int Target, float damage)
{
	if(ShouldNpcDealBonusDamage(Target))
		damage*=10.0;

	damage*=RaidModeScaling;

	return damage;
}
static bool b_animation_set[MAXENTITIES];
static float fl_cosmic_gaze_throttle[MAXENTITIES];
static float fl_cosmic_gaze_windup[MAXENTITIES];
static float fl_cosmic_gaze_duration_offset[MAXENTITIES];
static float fl_gaze_Dist[MAXENTITIES];
static float fl_cosmic_gaze_range = 1500.0;
static float fl_cosmic_gaze_radius = 750.0;
static void Cosmic_Gaze(Twirl npc, int Target)
{
	if(i_current_wave[npc.index]<=30)
		return;

	float GameTime = GetGameTime(npc.index);
	if(fl_ruina_battery_timeout[npc.index] > GameTime)
		return;

	if(fl_comsic_gaze_timer[npc.index] > GameTime)
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

	float Windup = 2.0;
	float Duration;
	float Baseline = 1.75;

	float Ratio = (Baseline/Windup);

	float anim_ratio = Ratio;
	Duration = 1.3 * (Windup/Baseline);

	npc.m_bisWalking = false; 
	npc.m_flDoingAnimation = GameTime + Duration + Windup + 0.2;
	fl_ruina_battery_timeout[npc.index] = GameTime + Duration +Windup;
	fl_cosmic_gaze_windup[npc.index] = GameTime + Windup;

	b_animation_set[npc.index] = false;
	fl_cosmic_gaze_throttle[npc.index] = 0.0;
	
	npc.AddActivityViaSequence("taunt08");
	npc.SetPlaybackRate(1.36*anim_ratio);	
	npc.SetCycle(0.01);

	float VecTarget[3]; WorldSpaceCenter(Target, VecTarget);
	npc.FaceTowards(VecTarget, 10000.0);

	NPC_StopPathing(npc.index);
	npc.m_bPathing = false;

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

	fl_gaze_Dist[npc.index] = GetVectorDistance(EndLoc, Start);
	float Thickness = 15.0;
	int color[4]; Ruina_Color(color);
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
		fl_comsic_gaze_timer[npc.index] = GameTime + (npc.Anger ? 45.0 : 60.0);
		if(b_tripple_raid[npc.index])
			fl_comsic_gaze_timer[npc.index] = GameTime + (npc.Anger ? 60.0 : 90.0);
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
	if(fl_cosmic_gaze_throttle[npc.index] < GameTime)
	{
		tick = true;
	}

	npc.m_iState = 0;
	npc.m_flNextMeleeAttack = GameTime + 0.5;
	npc.m_flReloadIn = GameTime + 0.5;
	npc.m_fbGunout = true;

	if(fl_cosmic_gaze_windup[npc.index] < GameTime)
	{
		if(!b_animation_set[npc.index])
		{
			npc.SetPlaybackRate(0.25);

			EmitSoundToAll(Cosmic_Launch_Sounds[GetRandomInt(0, sizeof(Cosmic_Launch_Sounds) - 1)], npc.index, SNDCHAN_STATIC, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL);
			EmitSoundToAll(Cosmic_Launch_Sounds[GetRandomInt(0, sizeof(Cosmic_Launch_Sounds) - 1)], npc.index, SNDCHAN_STATIC, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL);

			EmitSoundToAll(TWIRL_COSMIC_GAZE_LOOP_SOUND1, npc.index, SNDCHAN_STATIC, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL);
			EmitSoundToAll(TWIRL_COSMIC_GAZE_LOOP_SOUND1, npc.index, SNDCHAN_STATIC, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL);
			
			b_animation_set[npc.index] = true;

			fl_cosmic_gaze_duration_offset[npc.index] = GameTime + 0.72;
		}
		if(fl_cosmic_gaze_duration_offset[npc.index] > GameTime && fl_cosmic_gaze_duration_offset[npc.index] !=FAR_FUTURE)
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
				Laser.Deal_Damage();

				fl_gaze_Dist[npc.index] = GetVectorDistance(EndLoc, Start);	
			}
			Get_Fake_Forward_Vec(fl_gaze_Dist[npc.index], Angles, EndLoc, Start);

			float 	flPos[3], // original
					flAng[3]; // original
			
			GetAttachment(npc.index, "effect_hand_r", flPos, flAng);

			float TE_Duration = 0.1;

			int color[4]; Ruina_Color(color);

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
		else if(fl_cosmic_gaze_duration_offset[npc.index] != FAR_FUTURE)
		{
			fl_cosmic_gaze_duration_offset[npc.index] = FAR_FUTURE;
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
static int i_explosion_core[MAXENTITIES];
static void Do_Cosmic_Gaze_Explosion(int client, float Loc[3])
{
	float Radius = fl_cosmic_gaze_radius;

	int create_center = Ruina_Create_Entity(Loc, 3.0, true);

	if(IsValidEntity(create_center))
	{
		i_explosion_core[client] = EntIndexToEntRef(create_center);
	}

	int color[4]; Ruina_Color(color);

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

	int creater = EntRefToEntIndex(i_explosion_core[iNPC]);

	if(IsValidEntity(creater))
	{
		int Beam_Index = g_Ruina_BEAM_Diamond;	

		int color[4]; Ruina_Color(color);

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

	return amt;
}
static float fl_Fractal_Gram_SpamTimer(Twirl npc)
{
	float timer = (npc.Anger ? 0.2 : 0.4);
	return timer;
}
static void Fractal_Gram(Twirl npc, int Target)
{
	if(i_current_wave[npc.index]<=15)
		return;

	float GameTime = GetGameTime(npc.index);
	if(npc.m_flNextRangedBarrage_Spam > GameTime)
		return;
	
	if(npc.m_flNextRangedBarrage_Singular > GameTime)
		return;

	if(fl_ruina_battery_timeout[npc.index] > GameTime)
		return;

	int amt = i_Fractal_Gram_Amt(npc);

	if(i_barrage_ammo[npc.index] > amt)
	{
		i_barrage_ammo[npc.index] = 0;
		npc.m_flNextRangedBarrage_Spam = GameTime + (npc.Anger ? 25.0 : 30.0);
		if(b_tripple_raid[npc.index])
			npc.m_flNextRangedBarrage_Spam = GameTime + (npc.Anger ? 45.0 : 60.0);
		return;
	}

	int Enemy_I_See;
			
	Enemy_I_See = Can_I_See_Enemy(npc.index, Target);
	//Target close enough to hit
	if(!IsValidEnemy(npc.index, Enemy_I_See)) //Check if i can even see.
		return;

	npc.PlayFractalSound();

	npc.m_flNextMeleeAttack = GameTime + 1.0;
	npc.m_flReloadIn = GameTime + 1.0;

	Target = Enemy_I_See;

	i_barrage_ammo[npc.index]++;

	npc.m_flNextRangedBarrage_Singular = GameTime + fl_Fractal_Gram_SpamTimer(npc);

	float vecTarget[3];
	WorldSpaceCenter(Target, vecTarget);
	//(int iNPC, float VecTarget[3], float dmg, float speed, float radius, float direct_damage, float direct_radius, float time)
	float Laser_Dmg = 2.5;
	float Speed = (npc.Anger ? 1300.0 : 1100.0);
	float Direct_Dmg = 3.5;
	Fractal_Attack(npc.index, vecTarget, Modify_Damage(-1, Laser_Dmg), Speed, 15.0, Modify_Damage(-1, Direct_Dmg), 0.0, 5.0);
}
static int i_laser_entity[MAXENTITIES];
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
		Ruina_Color(color);
		Twirl npc = view_as<Twirl>(iNPC);
		int beam = ConnectWithBeamClient(npc.m_iWearable1, Proj, color[0], color[1], color[2], f_start, f_end, amp, LASERBEAM);
		i_laser_entity[Proj] = EntIndexToEntRef(beam);
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

	int beam = EntRefToEntIndex(i_laser_entity[entity]);
	if(IsValidEntity(beam))
		RemoveEntity(beam);

	i_laser_entity[entity] = INVALID_ENT_REFERENCE;
	
	float ProjectileLoc[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);


	if(fl_ruina_Projectile_radius[entity]>0.0)
		Explode_Logic_Custom(fl_ruina_Projectile_dmg[entity] , owner , owner , -1 , ProjectileLoc , fl_ruina_Projectile_radius[entity] , _ , _ , true, _,_, fl_ruina_Projectile_bonus_dmg[entity]);
	else
		SDKHooks_TakeDamage(other, owner, owner, fl_ruina_Projectile_dmg[entity], DMG_PLASMA, -1, _, ProjectileLoc);

	TE_Particle("spell_batball_impact_blue", ProjectileLoc, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
	if(i_current_wave[owner] >= 45)
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

	Laser.Deal_Damage();


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
static bool Retreat(Twirl npc, bool custom = false)
{
	float GameTime = GetGameTime(npc.index);
	float Radius = 320.0;	//if too many people are next to her, she just teleports in a direction to escape.
	
	if(npc.m_flNextTeleport > GameTime && !custom)	//internal teleportation device is still recharging...
		return false;

	if(!custom)
		npc.m_flNextTeleport = GameTime + 1.0;

	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	

	if(Nearby_Players(npc, Radius) < 4 && !custom)	//not worth "retreating"
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
	
	if(!custom)
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

	if(custom)
		return true;

	fl_force_ranged[npc.index] = GameTime + 5.0;	//now force ranged mode for a bit, wouldn't make sense to just rush straight into the same situation you just escaped from

	if(wave<=15)	//stage 1: a simple ion where she was.
	{
		float radius = (npc.Anger ? 325.0 : 250.0);
		float dmg = 50.0;
		dmg *= RaidModeScaling;

		float Time = (npc.Anger ? 1.25 : 1.5);
		npc.Ion_On_Loc(VecSelfNpc, radius, dmg, Time);
	}
	else if(wave <=45)	//stage 2, 3: an ion cast on anyone near her previous location when she teleports
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
		fl_force_ranged[npc.index] = GameTime + 8.0;	
	}

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
static float fl_retreat_laser_throttle[MAXENTITIES];
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
	fl_retreat_laser_throttle[npc.index] = GameTime + 0.7;

	npc.FaceTowards(Last_Pos, 10000.0);

	if(!npc.Anger)
	{
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
	}

	b_animation_set[npc.index] = false;

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

	if(fl_retreat_laser_throttle[npc.index] > GameTime)
		return Plugin_Continue;

	if(!b_animation_set[npc.index])
	{
		npc.SetCycle(0.51948051);	//math bitch!
		b_animation_set[npc.index] = true;
		npc.SetPlaybackRate(0.0);	
		//npc.SetCycle(0.4);
	}
	fl_retreat_laser_throttle[npc.index] = GameTime + 0.1;

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

	int color[4]; Ruina_Color(color);

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
static float fl_magia_angle[MAXENTITIES];
static bool Magia_Overflow(Twirl npc)
{
	float GameTime = GetGameTime(npc.index);
	if(fl_magia_overflow_recharge[npc.index] > GameTime)
		return false;

	if(fl_ruina_battery_timeout[npc.index] > GameTime)
		return false;

	if(!Retreat(npc, true))
		return false;

	fl_ruina_shield_break_timeout[npc.index] = 0.0;		//make 100% sure she WILL get the shield.
	Ruina_Npc_Give_Shield(npc.index, 0.45);				//give the shield to itself.
	
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
	fl_retreat_laser_throttle[npc.index] = GameTime + 0.7;
	fl_magia_overflow_recharge[npc.index] = GameTime + Duration + 0.7 + (npc.Anger ? 30.0 : 45.0);

	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	int color[4]; 
	Ruina_Color(color);
	float Thickness = 6.0;
	VecSelfNpc[2]-=2.5;
	//create a ring around twirl showing the radius for her special "if you're near me, my laser turns faster"
	TE_SetupBeamRingPoint(VecSelfNpc, (npc.Anger ? 350.0 : 275.0)*2.0, (npc.Anger ? 350.0 : 275.0)*2.0+0.5, g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, Duration+0.7, Thickness, 0.75, color, 1, 0);
	TE_SendToAll();

	b_animation_set[npc.index] = false;

	NPC_StopPathing(npc.index);
	npc.m_bPathing = false;
	npc.m_flSpeed = 0.0;

	fl_magia_angle[npc.index] = GetRandomFloat(0.0, 360.0);

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
	if(fl_retreat_laser_throttle[npc.index] < GameTime)
	{
		update = true;
		fl_retreat_laser_throttle[npc.index] = GameTime + 0.1;
	}

	if(!b_animation_set[npc.index] && update)
	{
		b_animation_set[npc.index] = true;
		npc.SetPlaybackRate(0.0);	
		//npc.SetCycle(0.4);
	}
	if(!b_animation_set[npc.index])
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
		float Dps = Modify_Damage(-1, 5.25)*Ratio;
		Laser.Damage = Dps;
		Laser.Radius = Radius;
		Laser.Bonus_Damage = Dps*6.0;
		Laser.damagetype = DMG_PLASMA;
		Laser.Deal_Damage(On_LaserHit);
	}
	

	float TE_Duration = TWIRL_TE_DURATION;
	float EndLoc[3]; EndLoc = Laser.End_Point;

	int color[4]; Ruina_Color(color);
	if(i_current_wave[npc.index] >=60)
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

	if(fl_magia_angle[npc.index]>360.0)
		fl_magia_angle[npc.index] -=360.0;
	
	fl_magia_angle[npc.index]+=2.5/TickrateModify;

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
		tempAngles[2] = (fl_magia_angle[npc.index]+((360.0/loop_for)*float(i)))*ang_multi;	//we use the roll angle vector to make it speeen
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

	if(b_allow_final[npc.index])
	{
		int Health_After_Damage = RoundToCeil(float(Health)-damage);
		if(Health_After_Damage <= 5)
		{
			i_current_Text[npc.index] = 0;
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
			fl_raidmode_freeze[npc.index] = timer;

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
	if(!b_allow_final_invocation[npc.index] && (MaxHealth/4) >= Health && i_current_wave[npc.index] >=60 && npc.m_flDoingAnimation < GetGameTime(npc.index))
	{
		b_allow_final_invocation[npc.index] = true;
	}

	if(!npc.Anger && (MaxHealth/2) >= Health && i_current_wave[npc.index] >=30) //Anger after half hp
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
		Ruina_Color(color);
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
		

		i_ranged_ammo[npc.index] += RoundToFloor(i_ranged_ammo[npc.index]*0.5);

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
		/*can't think of any lines */ //case WEAPON_HEAVY_PARTICLE_RIFLE: switch(GetRandomInt(0,1)) {case 0: Format(Text_Lines, sizeof(Text_Lines), ""); case 1: Format(Text_Lines, sizeof(Text_Lines), "");}		
		
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

	for(int i= 0 ; i < 3 ; i ++)
	{
		int ent = EntRefToEntIndex(i_lunar_entities[npc.index][i]);
		if(IsValidEntity(ent))
			RemoveEntity(ent);

		i_lunar_entities[npc.index][i] = INVALID_ENT_REFERENCE;
	}

	npc.m_flRangedArmor = 1.0;
	npc.m_flMeleeArmor = 1.5;

	StopSound(npc.index, SNDCHAN_STATIC, "player/taunt_surgeons_squeezebox_music.wav");
	StopSound(npc.index, SNDCHAN_STATIC, TWIRL_COSMIC_GAZE_LOOP_SOUND1);
	StopSound(npc.index, SNDCHAN_STATIC, TWIRL_COSMIC_GAZE_LOOP_SOUND1);
	StopSound(npc.index, SNDCHAN_STATIC, TWIRL_LASER_SOUND);
	StopSound(npc.index, SNDCHAN_STATIC, TWIRL_LASER_SOUND);

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


	int ent = EntRefToEntIndex(i_hand_particles[npc.index]);
	if(IsValidEntity(ent))
	{
		RemoveEntity(ent);
	}
	i_hand_particles[npc.index] = INVALID_ENT_REFERENCE;

	b_tripple_raid[npc.index] = false;


	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
	ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);

	if(!b_wonviakill[npc.index] && !b_wonviatimer[npc.index] && !b_allow_final[npc.index])
	{	
		int wave = i_current_wave[npc.index];
		if(wave <=15)
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
		else if(wave <=30)
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
		else if(wave <=45)
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
			if(b_tripple_raid[npc.index])
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
				switch(GetRandomInt(0, 4))
				{
					case 0: Twirl_Lines(npc, "Ahhh, you've won, ahaha, this is why I always limit myself, cause otherwise its no fun!");
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
	if(b_test_mode[npc.index])
		return;

	CPrintToChatAll("%s %s", npc.GetName(), text);
}
void Twirl_OnStellaKarlasDeath(int karlas)
{
	int Twirl_Index = -1;
	for(int i; i < i_MaxcountNpcTotal; i++)
	{
		int entity = EntRefToEntIndex(i_ObjectsNpcsTotal[i]);
		if(IsValidEntity(entity))
		{
			char npc_classname[60];
			NPC_GetPluginById(i_NpcInternalId[entity], npc_classname, sizeof(npc_classname));

			if(entity != INVALID_ENT_REFERENCE && (StrEqual(npc_classname, "npc_ruina_twirl") && IsEntityAlive(entity)))
			{
				Twirl_Index = entity;
				break;
			}
		}
	}
	
	//twirl is dead, simple.
	if(!IsValidEntity(Twirl_Index))
		return;

	Twirl npc = view_as<Twirl>(Twirl_Index);
	//karlas is dead.
	//-2 == karlas is dead 100%
	//is valid ent is for when stella dies, we need to check if karlas is still valid or not.
	//TECHNICALLY, its possible for karlas to die first, meaning stella is still alive when twirl unlocks herself.
	//but like, when the fuck is karlas ever killed first????
	if(karlas == -2 || !IsValidEntity(karlas))
	{
		switch(GetRandomInt(0, 2))
		{
			case 0:Twirl_Lines(npc, "Ohoh, You think this is gonna end easily, you are {crimson}SORELY MISTAKEN");
			case 1:Twirl_Lines(npc, "{crimson}I won't let you win");
			case 2:Twirl_Lines(npc, "{crimson}This is where your story ends");
		}
		b_tripple_raid[Twirl_Index] = false;
		return;
	}
	else
	{
		Twirl_Lines(npc, "{crimson}Karlas{snow}! Switch to me, I'm now your priority");
	}
	Set_Karlas_Ally(Twirl_Index, karlas, i_current_wave[Twirl_Index], false, true);
	Stella stella = view_as<Stella>(Twirl_Index);
	Karlas karl = view_as<Karlas>(karlas);
	karl.m_flNextRangedBarrage_Singular -= 15.0;
	stella.m_bKarlasRetreat = false;
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
	

	i_ExpidonsaEnergyEffect[iNpc][50] = EntIndexToEntRef(particle_ears1);
	i_ExpidonsaEnergyEffect[iNpc][51] = EntIndexToEntRef(particle_ears2);
	i_ExpidonsaEnergyEffect[iNpc][52] = EntIndexToEntRef(particle_ears3);
	i_ExpidonsaEnergyEffect[iNpc][53] = EntIndexToEntRef(particle_ears4);
	i_ExpidonsaEnergyEffect[iNpc][54] = EntIndexToEntRef(Laser_ears_1);
	i_ExpidonsaEnergyEffect[iNpc][55] = EntIndexToEntRef(Laser_ears_2);
	i_ExpidonsaEnergyEffect[iNpc][56] = EntIndexToEntRef(particle_ears2_r);
	i_ExpidonsaEnergyEffect[iNpc][57] = EntIndexToEntRef(particle_ears3_r);
	i_ExpidonsaEnergyEffect[iNpc][58] = EntIndexToEntRef(particle_ears4_r);
	i_ExpidonsaEnergyEffect[iNpc][59] = EntIndexToEntRef(Laser_ears_1_r);
	i_ExpidonsaEnergyEffect[iNpc][60] = EntIndexToEntRef(Laser_ears_2_r);
}