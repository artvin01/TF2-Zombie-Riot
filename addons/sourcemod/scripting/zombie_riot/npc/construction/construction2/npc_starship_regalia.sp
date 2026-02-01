#pragma semicolon 1
#pragma newdecls required

#define STARSHIP_MODEL			"models/zombie_riot/starship_7.mdl"

static float fl_ShipAcceleration;
static float fl_ShipDeceleration;
static float fl_ShipHyperDecelerationNearDist = 500.0;
static float fl_ShipHyperDecelerationSpeed = 80.0;
static float fl_ShipHyperDecelerationMax = 0.5;
static float fl_ShipTurnSpeed;
/*
	Artvins Requirements:
		@jDeivid for the boss i need:

		An escape sequence (follows certain paths, i can code that)
		If "killed" itll try to escape
			(Simple vector points can be used. since the npc/ship flight system follows vectors.)

		It will fly off, and you must be in a radius near it or you take dmg and die
			(use special krilian dome thing.)

		It spawns beacons on the floor of which, if damaged, damages the ship (see it as stabilitezers so melees can do shit)
			(steal anchor code, improve ten fold.)

		Otherwise have fun with its abilities!!!

	Behaviors:

	
	Weapons System:

		Primary/Forward Lances:

			Conditions To Enter:

			-Ship Max Speed reduced to 5%.
			-Ship Turn Rate increased by 300%

				-Maybe on vault map. ship goes towards set points and begins beam phase.
			
			Lance Firing Sequence.
				Follows a path.
			Aquire Optimal path:
				Find avg center of all players with the highest chance of hitting people.
				That becomes the center of the beam.
				Then beam start / end points are offset in a direction. roughly left to right from ship location towards enemy location. with a bit of randomness added.
					(Mornye E skill like beams, but instead of forwards, its sideways)
					(Or like Arqebus Balteus beam phase)
					(Or like lelouch's crystal target crystal beams)
					^ references for myself to understand what the fuck I typed.

			Once optimal path is created. ship bow follows path. Beams fire from forward lances.
			
			Once path is complete. ship returns to standard behavior.
		
		Central Weapon Ports

			Type 1:	"Lantean Drone Launchers"
				Conditions To Enter:

				Uses central weapons ports.
				Fires x lantean projectiles.
				Projectiles *should* in theory be killable by players.

				apart from that. they behave like lantean drone projectiles (won't have perfect homing turning.)
				-Projectile speeds would have a base speed. but an additional randomised speed. that way the projectiles won't clump up into 1 ball of doom.

				Does not affect current mode. however cannot be used during beam phase.

			Type 2: "Sprial"
				Conditions To Enter:

				-Ship becomes stationary
				-Central Bottom weapons ports each create 5 beams
				-Beams spin.
				-Beams start to fan out. (like new pablo lasershow start.)
				-Ability ends once beams have reach 90 degress from start.
				

		Underslung Weapons:

			Type 1:
				Conditions To Enter: Avg Vec point must have atleast X players before commiting

				-Get average highest players concentration in a circle.
				-Create IOC.
				-IOC Draw points originate from underslung weapon ports.
				-While IOC is charging. ship speed slowed. and forced to look towards the IOC end point.
				-IOC spins.

			Type 2:
				Conditions To Enter: Avg Vec point must have atleast X players before commiting

				-Get average highest players concentration in a circle.
				-Create delayed X lasers pattern barrages.

				-When creating a laser pattern. use underslung weapons to create a line from beam to start point.

			Type 3: "Fuck You In Particular"
				Conditions To Enter: Single player has to have done 25% of total hp of damage. can only be done oncer per player. only works if player count is above 7

				-Ship becomes stationary.
				-IOC begins charging. however it can move.
				-IOC follows said player.
				-IOC spins. weapon ports create beam from ports to ground end points
				-Deals True Damage

			Type 4: "Cosmic Terror"
				Conditions To Enter: 

				-Ship speed set to 80%.
				-4 cosmic terrors appear. each one controled by a seperate weapons port.
				-Acts like cosmic terror. just better coded.
				Cosmic terrors last for X seconds.

		Special Weapons Slot:

			Ship aims downwards (Like the entire ship pitches down), and spawns a special npc. (npc coded by Artvin)
			Use forward "bay" area as the origin point.
				(need to add an attachment there.)

			- Maybe reuse temple of scarlets V0.1 VFX for summoning/teleporting
			- multi use
	Passive:

		Constructor:
			Beacons passively spawn randomly.
			somewhere randomly on the arena.
			has a max limit.

	Beacons:

		Basic Functionality:
			- Beacons have 0.5% of ship

		Beacon Shield Phase:
			Every X seconds the beacons gain a shield (armour) if you don't destroy the armour of all beacons. the ship gains a massive shield (armour)

		Passive:
			While beacon is active, a orbital beam is active. acts like stella's orbital ray. should make the system independant.

		beacons transfer 100% of damage taken to ship.
		so a player does 100 dmg to a beacon. both the beacon and ship take 100 dmg.

	Flight isssues:


	make beacons on life 2 summon kampfers on like a 30s cd or smth.
	


	Notes:
		Make lantean drone proj deal less dmg to buildings.

		Seperate various parts of flight system into seperate functions:
			Turning.
			Velocity.
			Destination.
*/

/*
	

*/

static const char g_ShieldDamageSound[][] = {
	")physics/glass/glass_impact_bullet1.wav",
	")physics/glass/glass_impact_bullet2.wav",
	")physics/glass/glass_impact_bullet3.wav"
};
static const char g_ShieldBreakSound[][] = {
	")physics/glass/glass_largesheet_break1.wav"
};
static const char g_DoGAttackSound[][] = {
	")npc/combine_gunship/attack_stop2.wav"
};
static const char g_HL2_TeleSounds[][] = {
	")ambient/machines/teleport1.wav",
	")ambient/machines/teleport3.wav",
	")ambient/machines/teleport4.wav",
};
static const char g_HurtSounds[][] = {
	")physics/metal/metal_box_impact_bullet1.wav",
	")physics/metal/metal_box_impact_bullet2.wav",
	")physics/metal/metal_box_impact_bullet3.wav",
};
static const char g_LifeLossSounds[][] = {
	")ambient/atmosphere/thunder1.wav",
	")ambient/atmosphere/thunder2.wav",
	")ambient/atmosphere/thunder3.wav",
	")ambient/atmosphere/thunder4.wav",
};
#define REGALIA_IOC_EXPLOSION_SOUND				")misc/halloween/spell_mirv_explode_primary.wav"
#define REGALIA_IOC_STARTUP						")ambient/machines/thumper_startup1.wav"
#define REGALIA_IOC_CHARGE_LOOP					")ambient/machines/thumper_amb.wav"
#define REGALIA_PATTERNS_CHARGE_SOUND			")friends/friend_online.wav"
#define REGALIA_SPECIAL_IOC_EXPLOSION_SOUND		")ambient/levels/labs/teleport_postblast_thunder1.wav"
#define REGALIA_SPECIAL_IOC_EXPLOSION_SOUND_2	")ambient/levels/citadel/portal_beam_shoot2.wav"
#define REGALIA_SPECIAL_IOC_CHARGE_LOOP			")ambient/levels/citadel/zapper_warmup4.wav"

#define REGALIA_SPIRALGLAVE_SOUND				")ambient/levels/labs/teleport_mechanism_windup4.wav"
#define REGALIA_DEATH_EXPLOSION_SOUND			")ambient/levels/citadel/portal_open1_adpcm.wav"

#define REGALIA_LANTEAN_DRONE_SHOOT_1 	")weapons/physcannon/energy_sing_flyby1.wav"
#define REGALIA_LANTEAN_DRONE_SHOOT_2 	")weapons/physcannon/energy_sing_flyby2.wav"
enum 
{
	StarShip_BG_Main 		= 1,
	StarShip_BG_Bridge 		= 2,
	StarShip_BG_MainDrive   = 4,
	StarShip_BG_TopDeco		= 8,
	StarShip_BG_BottomDeco  = 16,
	StarShip_BG_CoreDeco	= 32,
	StarShip_BG_ForwardLance= 64,
	StarShip_BG_BottomWeps	= 128,
	StarShip_BG_Shield		= 256,
}
static const float fl_ShipRollClamps = 50.0;

/*
	sound\ambient\machines\wall_crash1.wav
*/
/*
	//corners


*/
static const float fl_BeaconSpawnPos[][3] = {
	{7622.043945, -619.331421, 	-5929.582520},
	{5854.175293, -764.341980, 	-5929.582520},
	{4585.667969, 470.419800, 	-5929.582520}, 
	{4599.006836, 1457.004517, 	-5929.582520},
	{4820.345215, 2404.140381, 	-5929.582520},
	{5775.631348, 2674.651367, 	-5929.582520},
	{7084.973633, 2730.071045, 	-5929.582520},
	{7824.516113, 1989.070312, 	-5929.582520},
	{7729.678223, 802.875183, 	-5929.582520}, 
	{7437.662109, -382.637848, 	-5929.582520},
	{7208.161621, 592.429443, 	-5929.582520}, 
	{6539.422852, 1764.437744, 	-5929.582520},
	{5495.158203, 2109.176758, 	-5929.582520},
	{5124.044434, 1051.976807, 	-5929.582520},
	{6872.589844, -677.584900, 	-5929.582520},
	{7891.919434, 123.480782, 	-5929.582520}, 
	{7863.694824, 1293.345093, 	-5929.582520},
	{7957.625000, 2559.701904, 	-5929.582520},
	{6137.000488, 2693.118896, 	-5929.582520},
	{4979.221191, 1951.209839, 	-5929.582520},
	{4312.235840, 281.892914, 	-5929.582520}, 
	{4259.996582, -741.711670, 	-5929.582520},
	{6291.461914, 195.441269, 	-5929.582520}, 
	{4852.110840, 1.806172, 	-5929.582520} 
};
static float fl_beacon_spawned_at_pos_recently[sizeof(fl_BeaconSpawnPos)-1];
static const float VaultVectorPoints[][3] = {
	{5975.277344, 880.963745, -4436.267578},

	{9082.631836, -2384.214600, -4436.337402},
	{6062.663086, -2601.933350, -4586.610352},
	{2630.493408, -2371.841553, -4586.610352},
	{2868.126465, 4183.577148, -4586.610352},
	{6048.231934, 4628.753906, -4586.610352},
	{9135.420898, 4535.649902, -4586.610352},
	{9945.458984, 953.970703, -4586.610352},
	{9603.561523, -2316.691650, -4586.610352}
};
#define REGALIA_RANDOM_LOC_AMT 8

static ArrayList AL_RegaliaAttachedEntities[MAXENTITIES] = {null, ...};
static Function func_ShipTurn[MAXENTITIES];
static bool bShipRaidModeScaling;
void StarShip_Regalia_OnMapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "HMS: Regalia");	//Regalia Class battlecruisers
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_starship_regalia");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags 		= 0;
	data.Category 	= Type_Outlaws;
	data.Precache 	= ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}
static void ClotPrecache()
{
	PrecacheModel(STARSHIP_MODEL);
	PrecacheSoundArray(g_ShieldDamageSound);
	PrecacheSoundArray(g_ShieldBreakSound);
	PrecacheSoundArray(g_DefaultCapperShootSound);
	PrecacheSoundArray(g_DoGAttackSound);
	PrecacheSoundArray(g_HL2_TeleSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_LifeLossSounds);
	PrecacheSound(REGALIA_IOC_EXPLOSION_SOUND);
	PrecacheSound(REGALIA_PATTERNS_CHARGE_SOUND);
	PrecacheSound(REGALIA_IOC_STARTUP);
	PrecacheSound(REGALIA_IOC_CHARGE_LOOP);
	PrecacheSound(REGALIA_SPECIAL_IOC_EXPLOSION_SOUND);
	PrecacheSound(REGALIA_SPECIAL_IOC_EXPLOSION_SOUND_2);
	PrecacheSound(REGALIA_SPECIAL_IOC_CHARGE_LOOP);
	PrecacheSound(REGALIA_LANTEAN_DRONE_SHOOT_1);
	PrecacheSound(REGALIA_LANTEAN_DRONE_SHOOT_2);
	PrecacheSound(REGALIA_SPIRALGLAVE_SOUND);
	PrecacheSound(REGALIA_DEATH_EXPLOSION_SOUND);

}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return RegaliaClass(vecPos, vecAng, team, data);
}
methodmap RegaliaClass < CClotBody
{
	public void EmitShieldSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + GetRandomFloat(0.15, 0.3);

		int pitch = GetRandomInt(40, 70);
		EmitSoundToAll(g_ShieldDamageSound[GetRandomInt(0, sizeof(g_ShieldDamageSound) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, 0.25, pitch);
	}
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;	
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
	}
	public void EmitShieldBreakSound() {
		EmitSoundToAll(g_ShieldBreakSound[GetRandomInt(0, sizeof(g_ShieldBreakSound) - 1)], this.index, _, SNDLEVEL_RAIDSIREN, _, 1.0, 60);
	}
	public void PlayCapperSound() {
		EmitSoundToAll(g_DefaultCapperShootSound[GetRandomInt(0, sizeof(g_DefaultCapperShootSound) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME, 80);	
	}
	public void PlayPattenShootSound(float Loc[3]) {
		EmitSoundToAll(g_DoGAttackSound[GetRandomInt(0, sizeof(g_DoGAttackSound) - 1)], _, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, 0.9, 80, _, Loc);	
	}
	public void PlayHL2TeleSound(float Loc[3]) {
		EmitSoundToAll(g_HL2_TeleSounds[GetRandomInt(0, sizeof(g_HL2_TeleSounds) - 1)], _, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, 0.9, 80, _, Loc);	
	}
	public void EmitGenerciLaserSound() {
		if(fl_RuinaLaserSoundTimer[this.index] > GetGameTime())
			return;

		EmitCustomToAll(g_RuinaLaserLoop[GetRandomInt(0, sizeof(g_RuinaLaserLoop) - 1)], this.index, SNDCHAN_STATIC, SNDLEVEL_RAIDSIREN, _, RAIDBOSSBOSS_ZOMBIE_VOLUME);
		fl_RuinaLaserSoundTimer[this.index] = GetGameTime() + 2.25;
	}
	public void EndGenericLaserSound() {
		StopCustomSound(this.index, SNDCHAN_STATIC, g_RuinaLaserLoop[GetRandomInt(0, sizeof(g_RuinaLaserLoop) - 1)]);
	}
	public void PlayLifeLossSound() {
		EmitSoundToAll(g_LifeLossSounds[GetRandomInt(0, sizeof(g_LifeLossSounds) - 1)], _, SNDCHAN_VOICE, SNDLEVEL_RAIDSIREN, _, 1.0, 100);	
	}
	property float m_flCurrentSpeed
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; 				}
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flPitchLeft
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; 				}
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flYawLeft
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; 				}
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flLanceRecharge
	{
		public get()							{ return fl_BEAM_RechargeTime[this.index]; 				}
		public set(float TempValueForProperty) 	{ fl_BEAM_RechargeTime[this.index] = TempValueForProperty; }
	}
	property float m_flLanceDuration
	{
		public get()							{ return fl_BEAM_DurationTime[this.index]; 				}
		public set(float TempValueForProperty) 	{ fl_BEAM_DurationTime[this.index] = TempValueForProperty; }
	}
	property float m_flDroneSpawnNext
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; 				}
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	property float m_flUnderSlung_PrimaryRecharge
	{
		public get()							{ return fl_AbilityOrAttack[this.index][4]; 				}
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][4] = TempValueForProperty; }
	}
	property float m_flUnderSlung_Type0_Recharge
	{
		public get()							{ return fl_AbilityOrAttack[this.index][5]; 				}
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][5] = TempValueForProperty; }
	}
	property float m_flUnderSlung_Type1_Recharge
	{
		public get()							{ return fl_AbilityOrAttack[this.index][6]; 				}
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][6] = TempValueForProperty; }
	}
	property float m_flSprial_Recharge
	{
		public get()							{ return fl_AbilityOrAttack[this.index][7]; 				}
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][7] = TempValueForProperty; }
	}
	property float m_flUnderSlung_Type2_Recharge
	{
		public get()							{ return fl_AbilityOrAttack[this.index][8]; 				}
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][8] = TempValueForProperty; }
	}
	property float m_flBeaconRespawnTimer
	{
		public get()							{ return fl_AbilityOrAttack[this.index][9]; 				}
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][9] = TempValueForProperty; }
	}
	property float m_flConstructorCooldown
	{
		public get()							{ return fl_AttackHappensMaximum[this.index][9]; 				}
		public set(float TempValueForProperty) 	{ fl_AttackHappensMaximum[this.index][9] = TempValueForProperty; }
	}
	property float m_flConstructorDuration
	{
		public get()							{ return fl_AttackHappensMinimum[this.index]; 				}
		public set(float TempValueForProperty) 	{ fl_AttackHappensMinimum[this.index] = TempValueForProperty; }
	}
	property float m_flShipAbilityActive
	{
		public get()							{ return fl_ruina_battery_timeout[this.index]; 				}
		public set(float TempValueForProperty) 	{ fl_ruina_battery_timeout[this.index] = TempValueForProperty; }
	}
	property float m_flLastDist_One
	{
		public get()							{ return fl_ThrowPlayerCooldown[this.index]; 				}
		public set(float TempValueForProperty) 	{ fl_ThrowPlayerCooldown[this.index] = TempValueForProperty; }
	}
	property float m_flLastDist_Two
	{
		public get()							{ return fl_ThrowPlayerImmenent[this.index]; 				}
		public set(float TempValueForProperty) 	{ fl_ThrowPlayerImmenent[this.index] = TempValueForProperty; }
	}
	property float m_flRevertControlOverride
	{
		public get()							{ return i_ClosestAllyCDTarget[this.index]; }
		public set(float TempValueForProperty) 	{ i_ClosestAllyCDTarget[this.index] = TempValueForProperty; }
	}
	property float m_flCurrentRoll
	{
		public get()							{ return f_NemesisCauseInfectionBox[this.index]; }
		public set(float TempValueForProperty) 	{ f_NemesisCauseInfectionBox[this.index] = TempValueForProperty; }
	}
	property float m_flEmergencyThrustAdjuster
	{
		public get()							{ return fl_RegainWalkAnim[this.index]; }
		public set(float TempValueForProperty) 	{ fl_RegainWalkAnim[this.index] = TempValueForProperty; }
	}
	property bool m_bVectoredThrust
	{
		public get()							{ return b_Half_Life_Regen[this.index]; }
		public set(bool TempValueForProperty) 	{ b_Half_Life_Regen[this.index] = TempValueForProperty; }
	}
	property bool m_bVectoredThrust_InUse
	{
		public get()							{ return b_Dead_Ringer_Invis_bool[this.index]; }
		public set(bool TempValueForProperty) 	{ b_Dead_Ringer_Invis_bool[this.index] = TempValueForProperty; }
	}
	property bool m_bShipFlightTowardsActive
	{
		public get()							{ return b_movedelay_gun[this.index]; }
		public set(bool TempValueForProperty) 	{ b_movedelay_gun[this.index] = TempValueForProperty; }
	}
	property bool m_bPrimaryLancesActive
	{
		public get()							{ return b_new_target[this.index]; }
		public set(bool TempValueForProperty) 	{ b_new_target[this.index] = TempValueForProperty; }
	}
	property bool m_bCutThrust
	{
		public get()							{ return b_FUCKYOU[this.index]; }
		public set(bool TempValueForProperty) 	{ b_FUCKYOU[this.index] = TempValueForProperty; }
	}
	property bool m_bCutThrust_Hyper
	{
		public get()							{ return b_FUCKYOU_move_anim[this.index]; }
		public set(bool TempValueForProperty) 	{ b_FUCKYOU_move_anim[this.index] = TempValueForProperty; }
	}
	property int m_iInternalTravelVaultVectors
	{
		public get()							{ return i_SemiAutoWeapon[this.index]; }
		public set(int TempValueForProperty) 	{ i_SemiAutoWeapon[this.index] = TempValueForProperty; }
	}
	property int m_iBeaconsExist
	{
		public get()							{ return i_SurvivalKnifeCount[this.index]; }
		public set(int TempValueForProperty) 	{ i_SurvivalKnifeCount[this.index] = TempValueForProperty; }
	}
	public RegaliaClass(float vecPos[3], float vecAng[3], int team, const char[] data)
	{
		RegaliaClass npc = view_as<RegaliaClass>(CClotBody(vecPos, vecAng, STARSHIP_MODEL, "1.0", "1000", team, .CustomThreeDimensions = {1000.0, 1000.0, 200.0}, .CustomThreeDimensionsextra = {-1000.0, -1000.0, -200.0}));
		
		i_NpcWeight[npc.index] = 999;

		bShipRaidModeScaling = false;

		npc.CleanEntities();
		
		SetEntityRenderMode(npc.index, RENDER_NORMAL);
		SetEntityRenderColor(npc.index, 255, 255, 255, 255);

		npc.m_iBeaconsExist = 0;

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");

		if(StrContains(data, "raid_hud") != -1)
		{
			RaidBossActive = EntIndexToEntRef(npc.index);
		}
		if(StrContains(data, "raid_damage_scaling") != -1)
		{
			Do_RaidModeScaling(data);
			bShipRaidModeScaling = true;
		}
		
		//Setting it to 999 will make our lag comp not resize collision box on shoot
		b_BoundingBoxVariant[npc.index] = BBV_DontAlter; 

		//SOLID_OBB_YAW		= 4,	// an OBB, constrained so that it can only yaw
		// could also try:  SOLID_CUSTOM		= 5,	// Always call into the entity for tests
		//or if youre very cool, maybe use 
		//SOLID_VPHYSICS		= 6,	// solid vphysics object, get vcollide from the model and collide with that
		//but that requires modeling that crudely.
		//SetEntProp(npc.index, Prop_Data, "m_nSolidType", 4); 

		npc.m_iInternalTravelVaultVectors = -1;
		
		npc.CreateBody();
		npc.ShieldState(false);
		
		npc.m_iBleedType 					= BLEEDTYPE_METAL;
		//npc.m_iStepNoiseType 				= STEPSOUND_NORMAL;	
		//npc.m_iNpcStepVariation 			= STEPTYPE_NORMAL;

		func_NPCDeath[npc.index]			= NPC_Death;
		func_NPCOnTakeDamage[npc.index] 	= OnTakeDamage;
		func_NPCThink[npc.index] 			= ClotThink;
		func_ShipTurn[npc.index]			= INVALID_FUNCTION;

		npc.m_flTurnSpeed			= 0.5;
		npc.m_flAcceleration 		= 1.2;
		npc.m_flDecceleration		= 0.8;
		npc.m_flHyperDeccelNearDist = 500.0;
		npc.m_flHyperDeccelSpeed 	= 5.0;
		npc.m_flHyperDeccelMax 		= 0.5;

		npc.m_bCutThrust_Hyper			= true;
		npc.m_bCutThrust				= false;
		npc.m_bShipFlightTowardsActive 	= false;
		npc.m_bVectoredThrust 			= false;
		npc.m_bVectoredThrust_InUse		= false;
		npc.m_flSpeed 					= 600.0;		//MAX SPEED
		npc.m_flGetClosestTargetTime 	= 0.0;
		npc.m_flShipAbilityActive 		= 0.0;
		npc.StopPathing();	//don't path.

		npc.m_flLastDist_One = 0.0;
		npc.m_flLastDist_Two = 0.0;
		npc.m_flRevertControlOverride = FAR_FUTURE;
		

		//npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_claidheamohmor/c_claidheamohmor.mdl");	//claidemor
		//SetVariantString("1.0");
		//AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		//
		int skin = 0;	//1=blue, 0=red
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		float Angles[3];
		GetEntPropVector(npc.index, Prop_Data, "m_angRotation", Angles);
		int iPitch = npc.LookupPoseParameter("body_pitch");
		float flPitch = npc.GetPoseParameter(iPitch);
		flPitch *= -1.0;
		Angles[0] = flPitch;

		fl_AbilityVectorData[npc.index] = Angles;

		//Weapons System.
		//Forward Lances
		npc.m_flLanceRecharge 				= GetRandomFloat(60.0, 75.0) + GetGameTime();
		npc.m_flLanceDuration 				= 0.0;
		npc.m_bPrimaryLancesActive 			= false;

		//under slungs
		npc.m_flUnderSlung_Type0_Recharge 	= GetRandomFloat(30.0, 45.0) 	+ GetGameTime();
		npc.m_flUnderSlung_Type1_Recharge	= GetRandomFloat(15.0, 60.0) 	+ GetGameTime();
		npc.m_flUnderSlung_Type2_Recharge	= GetRandomFloat(60.0, 120.0)	+ GetGameTime();
		npc.m_flUnderSlung_PrimaryRecharge  = 0.0;

		//core deco weapons
		npc.m_flSprial_Recharge				= GetRandomFloat(90.0, 120.0) 	+ GetGameTime();
		npc.m_flDroneSpawnNext				= GetRandomFloat(1.0, 3.0) 		+ GetGameTime();

		//Special

		npc.m_flConstructorCooldown 		= GetRandomFloat(30.0, 80.0)	+ GetGameTime();
		npc.m_flConstructorDuration			= FAR_FUTURE;

		//Make immune to speed debuffs and the like
		ApplyStatusEffect(npc.index, npc.index, "Clear Head", FAR_FUTURE);	
		ApplyStatusEffect(npc.index, npc.index, "Solid Stance", FAR_FUTURE);	
		ApplyStatusEffect(npc.index, npc.index, "Fluid Movement", FAR_FUTURE);	

		//dissable collision checks / safeties
		b_DoNotUnStuck[npc.index]				= true;
		f_NoUnstuckVariousReasons[npc.index] 	= FAR_FUTURE;
		f_StuckOutOfBoundsCheck[npc.index]		= FAR_FUTURE;
		b_NoKnockbackFromSources[npc.index] 	= true;
		b_ThisNpcIsImmuneToNuke[npc.index] 		= true;
		b_IgnoreAllCollisionNPC[npc.index]		= true;
		npc.m_bDissapearOnDeath 				= true;

		//CommLines("", "%t", "Regalia Test Line");
		//PrecacheSound("zombie_riot/attackofmrbeast.mp3");
		//CommLines("zombie_riot/attackofmrbeast.mp3", "%t", "Regalia Test Line Formated", 1, 3, 4);

		npc.m_iHealthBar = 1;

		//for spawn beacons
		RequestFrame(SummonBeaconsFrameLater, EntIndexToEntRef(npc.index));

		npc.Handle_SectionParticles();

		Zero(fl_player_weapon_score);
		npc.m_fbRangedSpecialOn = true;		
		return npc;
	}
	public void CreateBody()
	{	//assign primary bodygroups. except for shield.
		int group = 0;
		for(int i=0 ; i < 8 ; i++)
		{
			group |= (1 << i);
		}
		SetVariantInt(group);
		AcceptEntityInput(this.index, "SetBodyGroup");	
	}
	public void ShieldState(bool state)
	{
		if(state)
			this.AddSection(StarShip_BG_Shield);
		else
			this.RemoveSection(StarShip_BG_Shield);
	}
	public void RemoveSection(int group)
	{
		//get current bodygroups
		int current = GetEntProp(this.index, Prop_Data, "m_nBody");

		//then remove the specific bodygroup from the list
		current &= ~group;

		SetVariantInt(current);
		AcceptEntityInput(this.index, "SetBodyGroup");

	}
	public void AddSection(int group)
	{
		//get current bodygroups.
		int current = GetEntProp(this.index, Prop_Data, "m_nBody");

		//and then add the group to the whole.
		current |= group;

		SetVariantInt(current);
		AcceptEntityInput(this.index, "SetBodyGroup");
	}
	public int iGetTarget()
	{
		if(!IsValidEnemy(this.index, this.m_iTarget))
			this.m_flGetClosestTargetTime = 0.0;

		float GameTime = GetGameTime(this.index);
		if(this.m_flGetClosestTargetTime > GameTime && !this.m_bPrimaryLancesActive)
			return this.m_iTarget;
		if(this.m_bPrimaryLancesActive)
		{
			this.m_iTarget = i_Get_Laser_Target(this);
			if(!IsValidEntity(this.m_iTarget))
			{
				this.m_iTarget = GetClosestTarget(this.index, _, _ , true, _, _, f3_LastValidPosition[this.index], _, _, _, true);
			}
		}
		else
			this.m_iTarget = GetClosestTarget(this.index, _, _ , true, _, _, _, _, _, _, true);
		this.m_flGetClosestTargetTime = GetGameTime(this.index) + GetRandomRetargetTime();
		
		/*
		int entity,
		
		bool IgnoreBuildings = false,
		float fldistancelimit = 99999.9,
		bool camoDetection=false,

		bool onlyPlayers = false,
		int ingore_client = -1, 
		float EntityLocation[3] = {0.0,0.0,0.0},

		bool CanSee = false,
		float fldistancelimitAllyNPC = 450.0,
		bool IgnorePlayers = false, //also assumes npcs, only buildings are attacked

		bool UseVectorDistance = false,
		float MinimumDistance = 0.0,
		Function ExtraValidityFunction = INVALID_FUNCTION)
		*/

		return this.m_iTarget;
	}
	public bool bDoesSectionExist(int group)
	{
		int current = GetEntProp(this.index, Prop_Data, "m_nBody");

		return view_as<bool>(current & group);
	}
	public float[] GetAngles()
	{
		return fl_AbilityVectorData_3[this.index];
	}
	public float[] GetShipFlightAngles()
	{
		return fl_AbilityVectorData[this.index];
	}
	//is the ship facing completely forward relative to its current flight path.
	//can set how much of an allowence we wil let.
	public bool bIsShipFacingForward(float Pitch_Allow, float Yaw_Allow)
	{
		if(fabs(this.m_flYawLeft) > Yaw_Allow || fabs(this.m_flPitchLeft) > Pitch_Allow)
			return false;

		return true;
	}
	//is the ship's forward section facing our wanted location.
	//can set how much of an allowance we will let.
	public bool bIsShipFacingLoc(float ComparePos[3], float Loc[3], float Pitch_Allow, float Yaw_Allow)
	{
		//TE_SetupBeamPoints(ComparePos, Loc, g_Ruina_BEAM_Laser, 0, 0, 0, 1.0, 60.0, 60.0, 0, 0.25, {100, 255, 0, 255}, 3);
		//TE_SendToAll();

		float ShipAngles[3]; ShipAngles = this.GetAngles();
		float Angles[3];
		MakeVectorFromPoints(ComparePos, Loc, Angles);
		GetVectorAngles(Angles, Angles);

		//float Paranoia_Loc[3];
		//Get_Fake_Forward_Vec(500.0 , Angles , Paranoia_Loc, ComparePos);
		//TE_SetupBeamPoints(ComparePos, Paranoia_Loc, g_Ruina_BEAM_Laser, 0, 0, 0, 1.0, 60.0, 60.0, 0, 0.25, {255, 255, 100, 255}, 3);
		//TE_SendToAll();

		//Get_Fake_Forward_Vec(500.0 , ShipAngles , Paranoia_Loc, ComparePos);
		//TE_SetupBeamPoints(ComparePos, Paranoia_Loc, g_Ruina_BEAM_Laser, 0, 0, 0, 1.0, 60.0, 60.0, 0, 0.25, {50, 255, 100, 255}, 3);
		//TE_SendToAll();

		float desiredPitch = Angles[0];
		float desiredYaw   = Angles[1];

		float angleDiff_Pitch 	= UTIL_AngleDiff( desiredPitch, 	ShipAngles[0] );	//now get the difference between what we want and what we have as our angles
		float angleDiff_Yaw 	= UTIL_AngleDiff( desiredYaw, 		ShipAngles[1] );	//now get the difference between what we want and what we have as our angles
		angleDiff_Pitch	 = fixAngle(angleDiff_Pitch);
		angleDiff_Yaw	 = fixAngle(angleDiff_Yaw);

		//CPrintToChatAll("angleDiff_Pitch:  %.3f", angleDiff_Pitch);
		//CPrintToChatAll("angleDiff_Yaw:    %.3f", angleDiff_Yaw);

		if(fabs(angleDiff_Yaw) > Yaw_Allow || fabs(angleDiff_Pitch) > Pitch_Allow)
			return false;

		return true;
	}
	//Weapons Sections
	public float[] GetWeaponSections(const char[] Attachment)
	{
		float flPos[3], flAng[3];
		this.GetAttachment(Attachment, flPos, flAng);
		return flPos;
	}
	public void AddAttachedEntity(int entity)
	{
		if(AL_RegaliaAttachedEntities[this.index] == null)
		{
			AL_RegaliaAttachedEntities[this.index] = new ArrayList();
		}
		AL_RegaliaAttachedEntities[this.index].Push(EntIndexToEntRef(entity));
	}
	public void CleanEntities()
	{
		if(AL_RegaliaAttachedEntities[this.index] == null)
			return;

		for(int i = 0 ; i < AL_RegaliaAttachedEntities[this.index].Length ; i++)
		{
			int ent = EntRefToEntIndex(AL_RegaliaAttachedEntities[this.index].Get(i));
			if(IsValidEntity(ent))
				RemoveEntity(ent);
		}
		delete AL_RegaliaAttachedEntities[this.index];
		AL_RegaliaAttachedEntities[this.index] = null;
	}
	//Flight System:
	public void SetFlightSystemGoal(float GoalVec[3], Function FuncTurn = INVALID_FUNCTION)
	{
		if(this.m_bShipFlightTowardsActive)
		{
			LogStackTrace("Regalia Attempted to set new pathing logic when we already have a path. this is not supported and might break ship logic. as such aborting");
			return;
		}

		this.m_bCutThrust_Hyper				= false;
		this.m_bCutThrust					= false;
		this.m_flRevertControlOverride		= FAR_FUTURE;
		func_ShipTurn[this.index] 			= FuncTurn;
		this.m_bShipFlightTowardsActive 	= true;
		f3_NpcSavePos[this.index] 			= GoalVec;
	}
	public void EndFlightSystemGoal()
	{
		this.m_flRevertControlOverride		= FAR_FUTURE;
		fl_AbilityVectorData[this.index] 	= this.GetAngles();
		this.m_bShipFlightTowardsActive 	= false;
		this.m_bVectoredThrust 				= false;
		this.m_flShipAbilityActive 			= GetGameTime(this.index) + 1.0;
		func_ShipTurn[this.index]			= INVALID_FUNCTION;
		this.m_bCutThrust					= false;
		this.m_bCutThrust_Hyper				= false;
		this.m_iInternalTravelVaultVectors 	= -1;
	}
	public void HeadingControl()
	{
		b_NoGravity[this.index] = true;

		this.StopPathing();

		bool Wondering = false;

		if(!IsValidEntity(this.m_iTarget))
			Wondering = true;

		if(fabs(this.m_flYawLeft) < 10.0)
		{
			if(this.m_flEmergencyThrustAdjuster < GetGameTime() - 5.0)
			{
				if(fabs(this.m_flYawLeft) <= 2.5)
					this.m_flEmergencyThrustAdjuster = GetGameTime();
			}
			else
			{
				this.m_flEmergencyThrustAdjuster = GetGameTime();
			}
		}

		float GameTime = GetGameTime(this.index);

		float DroneLoc[3], TargetLoc[3];
		GetAbsOrigin(this.index, DroneLoc);

		if(this.m_bShipFlightTowardsActive)
		{
			TargetLoc = f3_NpcSavePos[this.index];
		}
		else if(Wondering)
		{
			if(this.m_iInternalTravelVaultVectors != -1)
			{
				if(this.m_iInternalTravelVaultVectors == 0)
					this.m_iInternalTravelVaultVectors = GetRandomInt(1, REGALIA_RANDOM_LOC_AMT);

				TargetLoc = VaultVectorPoints[this.m_iInternalTravelVaultVectors];
			}

			float Dist2D = Get2DVectorDistances(DroneLoc, TargetLoc, true);
			if(Dist2D < (150.0 * 150.0))
			{
				if(this.m_iInternalTravelVaultVectors != 0)
				{
					int currently_on = this.m_iInternalTravelVaultVectors;

					while(currently_on == this.m_iInternalTravelVaultVectors)
					{
						this.m_iInternalTravelVaultVectors = GetRandomInt(1, REGALIA_RANDOM_LOC_AMT);
					}
				}
			}
		}
		else
		{
			bool is_player = false;
			if(this.m_iInternalTravelVaultVectors != -1)
			{
				TargetLoc = VaultVectorPoints[this.m_iInternalTravelVaultVectors];

			}
			else
			{
				is_player = true;
				WorldSpaceCenter(this.m_iTarget, TargetLoc);
				TargetLoc[2]+=1000.0;
			}

			float Dist2D = Get2DVectorDistances(DroneLoc, TargetLoc, true);
			if(Dist2D < (is_player ? (300.0 * 300.0) : (150.0 * 150.0)))
			{
				if(this.m_iInternalTravelVaultVectors == -1)
				{
					this.m_iInternalTravelVaultVectors = GetRandomInt(1, REGALIA_RANDOM_LOC_AMT);
				}
				else if(this.m_iInternalTravelVaultVectors != 0)
				{
					this.m_iInternalTravelVaultVectors = -1;
				}
			}
			
		}
		
		float Dist = GetVectorDistance(DroneLoc, TargetLoc, true); 

		bool Vectored_Thrust = false;	
		//so simply put. space ships aren't limited to the usual "plane movement", they can move in 3d space freely.
		//however coding that is annoying and I don't have time for it.
		//however, I can partially simulate it by making it so:
		//if we are traveling towards a set vector point, and we allow drifting
		//and are about to reach said point we can initiate "fake thrust vectoring"
		//aka the ship model turns, but the ship's actual velocity vector stays the same
		//obv the ship's main engies are nolonger being used as the main engies, as such to
		//make it more believable we will slow the ship by 50%.
		//since big engines on back == big speed.
		//big engines cause big mass.
		//TL;DR: it look cool.

		if(this.m_bShipFlightTowardsActive)
		{
			if(this.m_bVectoredThrust)	//do we have "tokyo drifto" mode active?
			{
				float DistCheck = 500.0*500.0;
				if(Dist < DistCheck)	
					Vectored_Thrust = true;
			}
		}
		else 
		{
			Vectored_Thrust = this.m_bVectoredThrust;
		}

		if(this.m_bCutThrust)
			Vectored_Thrust = true;

		this.Fly(TargetLoc, Dist, Vectored_Thrust);

		this.m_bVectoredThrust_InUse = Vectored_Thrust;

		if(this.m_flRevertControlOverride < GameTime)
		{
			this.m_flRevertControlOverride 		= FAR_FUTURE;
			func_ShipTurn[this.index] 			= INVALID_FUNCTION;
			fl_AbilityVectorData[this.index] 	= this.GetAngles();
			this.m_bVectoredThrust				= false;
			this.m_bCutThrust					= false;
			this.m_bCutThrust_Hyper 			= false;
		}

		if(func_ShipTurn[this.index] && func_ShipTurn[this.index] != INVALID_FUNCTION)
		{
			Call_StartFunction(null, func_ShipTurn[this.index]);
			Call_PushCell(this.index);
			Call_Finish();
		}
	}
	property float m_flTurnSpeed
	{
		public get()							
		{ 
			float speed = fl_ShipTurnSpeed;

			if(this.m_flEmergencyThrustAdjuster < GetGameTime() - 8.0)
			{
				float timer = GetGameTime() - this.m_flEmergencyThrustAdjuster;

				timer = timer / 8.0;

				speed *= timer;
			}
			if(this.m_bVectoredThrust_InUse)
			{
				speed *= 2.0;
			}	
			return speed; 				
		}
		public set(float TempValueForProperty) 	{ fl_ShipTurnSpeed = TempValueForProperty; }
	}
	property float m_flDecceleration
	{
		public get()							{ return fl_ShipDeceleration; 				}
		public set(float TempValueForProperty) 	{ fl_ShipDeceleration = TempValueForProperty; }
	}
	property float m_flHyperDeccelSpeed
	{
		public get()							{ return fl_ShipHyperDecelerationSpeed; 				}
		public set(float TempValueForProperty) 	{ fl_ShipHyperDecelerationSpeed = TempValueForProperty; }
	}
	property float m_flAcceleration
	{
		public get()							{ return fl_ShipAcceleration; 				}
		public set(float TempValueForProperty) 	{ fl_ShipAcceleration = TempValueForProperty; }
	}
	property float m_flHyperDeccelNearDist
	{
		public get()							{ return fl_ShipHyperDecelerationNearDist; 				}
		public set(float TempValueForProperty) 	{ fl_ShipHyperDecelerationNearDist = TempValueForProperty; }
	}
	property float m_flHyperDeccelMax
	{
		public get()							{ return fl_ShipHyperDecelerationMax; 				}
		public set(float TempValueForProperty) 	{ fl_ShipHyperDecelerationMax = TempValueForProperty; }
	}
	public VectorTurnData RotateShipFlightPathTowards(float GoalVec[3], float multi = 1.0)
	{
		float DroneLoc[3]; GetAbsOrigin(this.index, DroneLoc);
		VectorTurnData Data;
		Data.Origin 		= DroneLoc;	//this makes it act form vec to vec rather then from angles to angles.
		Data.TargetVec 		= GoalVec;
		Data.CurrentAngles 	= this.GetShipFlightAngles();
		Data.PitchSpeed		= this.m_flTurnSpeed * multi;
		Data.YawSpeed		= this.m_flTurnSpeed * multi;
		fl_AbilityVectorData[this.index] = TurnVectorTowardsGoal(Data);
		this.m_flPitchLeft 	= Data.PitchRotateLeft;
		this.m_flYawLeft	= Data.YawRotateLeft;
		return Data;
	}
	public float[] RotateShipModelTowards(float GoalVec[3], VectorTurnData Data, float multi = 1.0)
	{
		float DroneLoc[3]; GetAbsOrigin(this.index, DroneLoc);
		Data.Origin 		= DroneLoc;	//this makes it act form vec to vec rather then from angles to angles.
		Data.TargetVec 		= GoalVec;
		Data.CurrentAngles 	= this.GetAngles();
		Data.PitchSpeed		= this.m_flTurnSpeed * multi;
		Data.YawSpeed		= this.m_flTurnSpeed * multi;
		fl_AbilityVectorData_3[this.index] = TurnVectorTowardsGoal(Data);
		return fl_AbilityVectorData_3[this.index];
	}
	public void Fly(float Vec[3], float Dist, bool Vectored_Thrust)
	{
		float DroneLoc[3];
		GetAbsOrigin(this.index, DroneLoc);

		float Angles[3];

		float HypeDecell_NearDist 	= this.m_flHyperDeccelNearDist * this.m_flHyperDeccelNearDist;
		float HypeDecell_Max 		= this.m_flHyperDeccelMax;

		VectorTurnData Data;
		Data = this.RotateShipFlightPathTowards(Vec);

		Angles = fl_AbilityVectorData[this.index];

		float TurnRates[2];
		TurnRates[0] = Data.PitchRotateLeft;
		TurnRates[1] = Data.YawRotateLeft;

		float MaxSpeed = this.fGetBaseSpeed();
		//we gotta turn ALOT, so slow down the this.index to make its turning circle smaller.

		bool HyperDeccel = (Dist < HypeDecell_NearDist);

		float TurnReduce = 45.0;

		bool SubDeccel = false;

		for(int i=0 ; i < 2 ; i++)
		{
			if(fabs(TurnRates[i]) > TurnReduce) {
				MaxSpeed *= ( TurnReduce / fabs(TurnRates[i]));
			}

			if(fabs(TurnRates[i]) > 45.0)
				HyperDeccel = false;

			if(fabs(TurnRates[i]) > 100.0 && this.m_flCurrentSpeed > this.m_flSpeed * 0.5)
				SubDeccel = true;
		}
		
		if(HyperDeccel) {
			
			float SpeedRatio = Dist / HypeDecell_NearDist;

			if(SpeedRatio < HypeDecell_Max)
				SpeedRatio = HypeDecell_Max;

			MaxSpeed *=SpeedRatio;
		}
		
		if(SubDeccel)
			HyperDeccel = SubDeccel;

		float fBuf[3], fVel[3];
		GetAngleVectors(Angles, fBuf, NULL_VECTOR, NULL_VECTOR);

		float FlySpeed = this.GetShipFlightSpeed(MaxSpeed, HyperDeccel, SubDeccel);

		Angles[2] = -1.0 * Data.YawRotateLeft;
		
		float RotationClamp = fl_ShipRollClamps;

		//clamp ship rotational angles
		if(Angles[2] > RotationClamp)
			Angles[2] = RotationClamp;
		else if(Angles[2] < -RotationClamp)
			Angles[2] = -RotationClamp;

		/*if(Vectored_Thrust && this.m_bShipFlightTowardsActive)
		{

			if(Dist < (125.0*125.0))
			{
				this.m_flCurrentSpeed = 0.0;
				this.SetVelocity({0.0, 0.0, 0.0});
				fl_AbilityVectorData[this.index] = this.GetAngles();
				return;
			}
			if(FlySpeed < 10.0)
				FlySpeed = 10.0;

		}*/

		fVel[0] = fBuf[0]*FlySpeed;
		fVel[1] = fBuf[1]*FlySpeed;
		fVel[2] = fBuf[2]*FlySpeed;

		if(!Vectored_Thrust)
			this.RotateShipModel(Angles);

		this.SetVelocity(fVel);
	}
	public float fGetBaseSpeed()
	{
		float speed = this.m_flSpeed;

		if(this.m_bVectoredThrust_InUse)
			speed *= 0.8;

		if(this.m_bCutThrust)
		{
			speed = this.m_flCurrentSpeed - ( this.m_bCutThrust_Hyper ? this.m_flHyperDeccelSpeed : this.m_flDecceleration);
		}

		if(speed <= 0.0)
			speed = 0.0;

		return speed;
	}
	public void AdjustShipRoll(float Roll)
	{
		float RollChange 	= fabs(this.m_flCurrentRoll - Roll);
		float RollSpeed		= this.m_flTurnSpeed;

		if(RollChange > RollSpeed)
		{
			if(this.m_flCurrentRoll > Roll)
				this.m_flCurrentRoll  -=RollSpeed;
			else
				this.m_flCurrentRoll  +=RollSpeed;
		}
		else
		{
			if(this.m_flCurrentRoll > Roll)
				this.m_flCurrentRoll  -=RollChange;
			else
				this.m_flCurrentRoll  +=RollChange;
		}
	}
	public void RotateShipModel(float Angles[3])
	{
		this.AdjustShipRoll(Angles[2]);
		Angles[2] = this.m_flCurrentRoll;
		fl_AbilityVectorData_3[this.index] = Angles;
		SDKCall_SetLocalAngles(this.index, Angles);	
		//TeleportEntity(this.index, NULL_VECTOR, Angles);
	}
	public float GetShipFlightSpeed(float MaxSpeed, bool HyperDeccel, bool DoNotAccel)
	{
		float FlySpeed = this.m_flCurrentSpeed;
		float Acceleration = this.m_flAcceleration;
		float Deccel = HyperDeccel ? this.m_flHyperDeccelSpeed : this.m_flDecceleration;

		if(!DoNotAccel) {
			if(FlySpeed+Acceleration < MaxSpeed)
				FlySpeed+=Acceleration;
			else {
				if(MaxSpeed == this.fGetBaseSpeed())
					FlySpeed = MaxSpeed;
			}
		}

		//we too fast
		if(FlySpeed > MaxSpeed || DoNotAccel) {
			//we faster the base speed. force set
			if(FlySpeed > this.fGetBaseSpeed()) {
				FlySpeed = this.fGetBaseSpeed();
			}
			else {
				//we faster then the max speed assigned due to rotational difference, apply gradual Deceleration and not instant.

				FlySpeed -= Deccel;

				if(FlySpeed < MaxSpeed)
					FlySpeed = MaxSpeed;

				if(FlySpeed < 0.0 && HyperDeccel)
					FlySpeed = 0.0;
			}
		}
		
		//if(DriftMode)
		//	FlySpeed *= 0.5;

		this.m_flCurrentSpeed = FlySpeed;

		return FlySpeed;
	}
	// Particle VFX application
	public void Handle_SectionParticles()
	{
		this.CleanEntities();

		this.ApplyEngineEffects();
		this.Apply_LanceEffects();

		this.ApplyWingBottomEffects();
		this.ApplyWingsTopEffects();
	}
	public void ApplyEngineEffects()
	{
		if(!this.bDoesSectionExist(StarShip_BG_MainDrive))
			return;

		static const char Sections[][] = {
			"upper_center_engine_block" ,
			"lower_center_engine_block" ,

			"upper_left_engine_block" 	,
			"center_left_engine_block" 	,

			"lower_left_engine_block" 	,
			"upper_right_engine_block" 	,

			"center_right_engine_block" ,
			"lower_right_engine_block" 	
		};

		int rendermode 		= 4;
		float startwidth 	= 100.0;
		float endwidth 		= 25.0;
		float lifetime		= 2.5;

		int skin = GetEntProp(this.index, Prop_Data, "m_nSkin");

		//"effects/beam001_white.vmt"
		//"effects/beam001_red.vmt" : "effects/beam001_blu.vmt"
		for(int i= 0 ; i < 8 ; i++)
		{
			int trail = TrailAttach_Bone(this.index, Sections[i], skin == 1 ? "effects/beam001_blu.vmt" : "effects/beam001_red.vmt", 255, lifetime, startwidth, endwidth, rendermode);
			if(IsValidEntity(trail))
				this.AddAttachedEntity(trail);
			trail = TrailAttach_Bone(this.index, Sections[i], "effects/beam001_white.vmt", 255, lifetime, startwidth, endwidth, rendermode);
			if(IsValidEntity(trail))
				this.AddAttachedEntity(trail);
		}

		
		
	}
	public void ApplyWingBottomEffects()
	{	
		if(!this.bDoesSectionExist(StarShip_BG_BottomDeco))
			return;

		static const char Sections[][] = {
			"bottom_left_wing_block",
			"bottom_right_wing_block"
		};

		int skin = GetEntProp(this.index, Prop_Data, "m_nSkin");

		for(int i=0 ; i < 2 ; i ++)
		{
			int particle_1 = ParticleEffectAt({0.0,0.0,0.0}, skin == 1 ? "raygun_projectile_blue_crit" : "raygun_projectile_red_crit", 0.0);
			SetParent(this.index, particle_1, Sections[i]);
			this.AddAttachedEntity(particle_1);
		}
	}
	public void ApplyWingsTopEffects()
	{
		if(!this.bDoesSectionExist(StarShip_BG_TopDeco))
			return;

		static const char Sections[][] = {
			"top_left_wing_block",
			"top_right_wing_block" 
		};

		int skin = GetEntProp(this.index, Prop_Data, "m_nSkin");

		for(int i=0 ; i < 2 ; i ++)
		{
			int particle_1 = ParticleEffectAt({0.0,0.0,0.0}, skin == 1 ? "raygun_projectile_blue_crit" : "raygun_projectile_red_crit", 0.0);
			SetParent(this.index, particle_1, Sections[i]);
			this.AddAttachedEntity(particle_1);
		}
	}
	public void Apply_LanceEffects()
	{
		if(!this.bDoesSectionExist(StarShip_BG_ForwardLance))
			return;

		/*
			$attachment "forward_lance_left_end" 			"weapon_bone" 143.702 -432.962 0.0 rotate 0.0 0.0 0.0
			$attachment "forward_lance_left_start" 			"weapon_bone" 143.702 -314.649 0.0 rotate 0.0 0.0 0.0

			$attachment "forward_lance_right_end" 			"weapon_bone" -143.702 -432.962 0.0 rotate 0.0 0.0 0.0
			$attachment "forward_lance_right_start" 		"weapon_bone" -143.702 -314.649 0.0 rotate 0.0 0.0 0.0
		*/

		float start = 2.0;
		float end	= 6.0;
		float amp 	= 0.1;

		int color[3] = {255, 255, 255};

		static const char Sections[][] = {
			"forward_lance_left_start",
			"forward_lance_left_end" ,
			
			"forward_lance_right_start",
			"forward_lance_right_end"
		};

		for(int i=0 ; i < 2 ; i ++)
		{
			int loop= i * 2;

			int particle_1 = ParticleEffectAt({0.0,0.0,0.0}, "flaregun_energyfield_blue", 0.0); //This is the root bone basically
			int particle_2 = ParticleEffectAt({0.0,0.0,0.0}, "flaregun_energyfield_blue", 0.0); //This is the root bone basically
			
			SetParent(this.index, particle_1, Sections[loop]);
			SetParent(this.index, particle_2, Sections[loop+1]);

			this.AddAttachedEntity(ConnectWithBeamClient(particle_1, particle_2, color[0], color[1], color[2], start, end, amp, BEAM_DIAMOND));

			this.AddAttachedEntity(particle_1);
			this.AddAttachedEntity(particle_2);
		}

	
	}
}
static void CommLines(const char[] SoundString, const char[] TextLines, any...)
{
	if(SoundString[0])
	{
		EmitSoundToAll(SoundString);
	}
	CCheckTrie();
	for(int i=1 ; i <= MaxClients ; i++)
	{
		if(!IsValidClient(i))
			continue;

		char buffer[MAX_BUFFER_LENGTH], buffer2[MAX_BUFFER_LENGTH];
		SetGlobalTransTarget(i);
		Format(buffer, sizeof(buffer), "\x01%s", TextLines);
		VFormat(buffer2, sizeof(buffer2), buffer, 3);
		CReplaceColorCodes(buffer2);
		CSendMessage(i, buffer2);
	}
}
static void SummonBeaconsFrameLater(int ref)
{
	int iNPC = EntRefToEntIndex(ref);

	if(!IsValidEntity(iNPC))
		return;

	RegaliaClass npc = view_as<RegaliaClass>(iNPC);
	for(int i=0 ; i < 5 ; i++)
	{
		npc.m_flBeaconRespawnTimer = 0.0;
		HandleBeacons(npc);
	}
}
static void ClotThink(int iNPC)
{
	RegaliaClass npc = view_as<RegaliaClass>(iNPC);

	float GameTime = GetGameTime(npc.index);

	if(npc.m_flNextDelayTime > GameTime)
		return;

	npc.m_flNextDelayTime = GameTime + DEFAULT_UPDATE_DELAY_FLOAT;

	npc.HeadingControl();
	
	npc.Update();

	if(npc.m_flNextThinkTime > GameTime)
		return;
	
	npc.m_flNextThinkTime = GameTime + 0.1;

	npc.m_iTarget = npc.iGetTarget();

	if(!IsValidEntity(npc.m_iTarget))
		return;

	//core of npc logic above should now be complete. now onto the specialist stuff.

	npc.ShieldState(npc.m_flArmorCount>0.0);	//shield VFX will take directly from npc armour.

	HandleUnderSlungWeapons(npc);
	HandleMainWeapons(npc);
	HandleDroneSystem(npc);
	Handle_SpiralGlaive(npc);
	HandleBeacons(npc);
	HandleConstructor(npc);
}
static float fl_constructor_summon_time;
static void HandleConstructor(RegaliaClass npc)
{
	float GameTime = GetGameTime(npc.index);

	if(npc.m_flConstructorDuration < GameTime)
	{
		npc.m_flShipAbilityActive	= GameTime + 1.0;
		npc.m_flConstructorCooldown = GameTime + GetRandomFloat(60.0, 90.0);
		npc.m_flConstructorDuration = FAR_FUTURE;
		
		f3_LastValidPosition[npc.index][2] +=10.0;
		
		npc.PlayHL2TeleSound(f3_LastValidPosition[npc.index]);
		npc.EndFlightSystemGoal();
		npc.EndGenericLaserSound();

		int health = RoundToFloor(ReturnEntityMaxHealth(npc.index) * 0.05);	//0.5% of ship hp

		float Radius = 300.0;
		float TE_Duration = 1.0;
		float ThicknessRing = 30.0;

		int style = GetEntProp(npc.index, Prop_Data, "m_nSkin");

		if(style == 3)
			style = 0;
		else if(style == 4)
			style = 1;
		TE_SetupBeamRingPoint(f3_LastValidPosition[npc.index], Radius*2.0, 0.0, iGetTeamBeamIndex((style == 1 ? 3 : 2)), 0, 0, 1, TE_Duration, ThicknessRing, 0.1, {255, 255, 255, 255}, 1, 0);
		TE_SendToAll();

		f3_LastValidPosition[npc.index][2] +=40.0;

		for(int i = 0 ; i < 4 ; i++)
		{
			int SpwanIndex = NPC_CreateByName("npc_almagest_proxima", npc.index, f3_LastValidPosition[npc.index], {0.0, 0.0, 0.0}, GetTeam(npc.index));

			if(SpwanIndex > MaxClients)
			{
				SetEntProp(SpwanIndex, Prop_Data, "m_iHealth", health);
				SetEntProp(SpwanIndex, Prop_Data, "m_iMaxHealth", health);
			}
		}
	}

	if(npc.m_flConstructorCooldown > GameTime)
		return;

	if(npc.m_flShipAbilityActive > GameTime)
		return;

	float ShipLoc[3]; GetAbsOrigin(npc.index, ShipLoc);

	int entity = MaxClients + 1;

	int vault_core = 0;
	bool Found = false;
	while((entity = FindEntityByClassname(entity, "obj_building")) != -1)
	{
		if(IsValidEnemy(npc.index, entity))
		{
			if(IsDungeonCenterId() == i_NpcInternalId[entity])
			{
				Found = true;
				vault_core = entity;
				break;
			}
		}
	}

	if(Found)
	{
		float VaultLoc[3]; GetAbsOrigin(vault_core, VaultLoc);
		float Dist = Get2DVectorDistances(ShipLoc, VaultLoc, true);

		if(Dist < (500.0 * 500.0))
			return;

		if(Dist > (1500.0 * 1500.0))
			return;
	}
	else
	{
		float Dist = Get2DVectorDistances(ShipLoc, VaultVectorPoints[0], true);

		if(Dist > (1500.0 * 1500.0))
			return;
	}

	npc.m_flConstructorDuration = FAR_FUTURE;
	npc.m_flConstructorCooldown = FAR_FUTURE;
	npc.m_flShipAbilityActive	= FAR_FUTURE;

	float WantedLoc[3];
	bool dungeon = Dungeon_Mode();

	int selection = 0;
	for(int i=0 ; i < sizeof(fl_BeaconSpawnPos)-1 ; i++)
	{
		if(!dungeon)
			break;

		//CPrintToChatAll("fl_beacon_spawned_at_pos_recently[%i] = %.3f", i, fl_beacon_spawned_at_pos_recently[i]);
		if(fl_beacon_spawned_at_pos_recently[i] == 0.0)
		{
			selection = i;
			break;
		}

		if(fl_beacon_spawned_at_pos_recently[i] < fl_beacon_spawned_at_pos_recently[selection])
			selection = i;
	}

	WantedLoc = fl_BeaconSpawnPos[selection];
	fl_beacon_spawned_at_pos_recently[selection] = GetGameTime();

	fl_constructor_summon_time	= 10.0;

	//float OffsetLoc[3]; GetAbsOrigin(npc.index, OffsetLoc);
	//TE_SetupBeamPoints(OffsetLoc, WantedLoc, g_Ruina_BEAM_Laser, 0, 0, 0, 15.0, 50.0, 50.0, 0, 0.1, {255,0,0,255}, 3);
	//TE_SendToAll();

	f3_LastValidPosition[npc.index] = WantedLoc;

	WantedLoc[2]+=1500.0;

	//TE_SetupBeamPoints(OffsetLoc, WantedLoc, g_Ruina_BEAM_Laser, 0, 0, 0, 15.0, 50.0, 50.0, 0, 0.1, {0,0,255,255}, 3);
	//TE_SendToAll();

	npc.SetFlightSystemGoal(WantedLoc, ConstructorTurnControl);
	npc.m_bVectoredThrust = true;


	//npc_almagest_proxima
}
static void ConstructorTurnControl(int iNPC)
{
	RegaliaClass npc = view_as<RegaliaClass>(iNPC);

	if(!npc.m_bVectoredThrust_InUse)
		return;

	float Origin[3]; GetAbsOrigin(npc.index, Origin);
	float WantedLoc[3]; WantedLoc = f3_LastValidPosition[npc.index];
	float Dist = Get2DVectorDistances(Origin, WantedLoc, true);

	float Angles[3];
	VectorTurnData Data;
	Angles = npc.RotateShipModelTowards(WantedLoc, Data, 1.0);
	if(npc.m_flConstructorDuration == FAR_FUTURE)
	{
		if(Dist < (50.0*50.0) && npc.bIsShipFacingLoc(Origin, WantedLoc, 10.0, 10.0))
		{
			npc.m_flCurrentSpeed *= 0.5;	//THE ULTRA SPEED BRAKES!
			float ShipNewAngles[3];
			MakeVectorFromPoints(Origin, WantedLoc, ShipNewAngles);
			GetVectorAngles(ShipNewAngles, ShipNewAngles);
			fl_AbilityVectorData[npc.index] = ShipNewAngles;
			npc.Fly(WantedLoc, Dist, true);	//update current speed / heading	
			
			npc.m_flConstructorDuration = GetGameTime(npc.index) + fl_constructor_summon_time;
			//and now apply the stationary holding system
			npc.m_bCutThrust_Hyper 	= true;
			npc.m_bCutThrust = true;
		}
	}
	else
	{
		float OffsetLoc[3]; GetAbsOrigin(npc.index, OffsetLoc);

		float Radius = 15.0;
		Ruina_Laser_Logic Laser;
		Laser.client = npc.index;
		Laser.Radius 		= Radius;
		Laser.Damage		= ModifyDamage(50.0);
		Laser.Bonus_Damage 	= ModifyDamage(10.0);
		Laser.damagetype 	= DMG_PLASMA|DMG_PREVENT_PHYSICS_FORCE;
		Laser.Start_Point 	= OffsetLoc;
		Laser.End_Point 	= WantedLoc;
		Laser.Detect_Entities(On_LaserHit);

		npc.EmitGenerciLaserSound();

		float RingRadius = 1200.0;
		float TE_Duration = 0.1;
		float ThicknessRing = 30.0;

		int style = GetEntProp(npc.index, Prop_Data, "m_nSkin");

		if(style == 3)
			style = 0;
		else if(style == 4)
			style = 1;
		
		DoPrimaryLanceEffects(npc, OffsetLoc, WantedLoc, Radius * 2.0);

		int beam_index = iGetTeamBeamIndex((style == 1 ? 3 : 2));

		OffsetLoc[2]+=600.0;
		TE_SetupBeamRingPoint(OffsetLoc, RingRadius*2.0, RingRadius * 2.0 - 1.0, beam_index, 0, 0, 1, TE_Duration, ThicknessRing, 0.1, {255, 255, 255, 255}, 1, 0);
		TE_SendToAll();

		RingRadius *=0.5;
		OffsetLoc[2]-=300.0;
		TE_SetupBeamRingPoint(OffsetLoc, RingRadius*2.0, RingRadius * 2.0 - 1.0, beam_index, 0, 0, 1, TE_Duration, ThicknessRing, 0.1, {255, 255, 255, 255}, 1, 0);
		TE_SendToAll();

		RingRadius *=0.5;
		OffsetLoc[2]-=300.0;
		TE_SetupBeamRingPoint(OffsetLoc, RingRadius*2.0, RingRadius * 2.0 - 1.0, beam_index, 0, 0, 1, TE_Duration, ThicknessRing, 0.1, {255, 255, 255, 255}, 1, 0);
		TE_SendToAll();

		WantedLoc[2]+=10.0;
		TE_SetupBeamRingPoint(WantedLoc, RingRadius*2.0, RingRadius * 2.0 - 1.0, beam_index, 0, 0, 1, TE_Duration, ThicknessRing, 0.1, {255, 255, 255, 255}, 1, 0);
		TE_SendToAll();
	}

	Angles[2] = -1.0 * Data.YawRotateLeft;
	float RotationClamp = fl_ShipRollClamps;

	//clamp ship rotational angles
	if(Angles[2] > RotationClamp)
		Angles[2] = RotationClamp;
	else if(Angles[2] < -RotationClamp)
		Angles[2] = -RotationClamp;

	if(npc.m_bCutThrust)	//in this case, make roll default to 0.0 to avoid the "Insert Interstellar theme here dot media player four" 
	{
		Angles[2] = 0.0;
	}

	npc.RotateShipModel(Angles);
}
static void HandleBeacons(RegaliaClass npc)
{
	//we allow 5 beacons
	if(npc.m_iBeaconsExist >= 5)
		return;

	float GameTime = GetGameTime(npc.index);

	if(npc.m_flShipAbilityActive > GameTime)
		return;

	if(npc.m_flBeaconRespawnTimer > GameTime)
		return;

	bool dungeon = Dungeon_Mode();

	int Beacon = -2;
	int selection = 0;
	for(int i=0 ; i < sizeof(fl_BeaconSpawnPos)-1 ; i++)
	{
		if(!dungeon)
			break;

		//CPrintToChatAll("fl_beacon_spawned_at_pos_recently[%i] = %.3f", i, fl_beacon_spawned_at_pos_recently[i]);
		if(fl_beacon_spawned_at_pos_recently[i] == 0.0)
		{
			selection = i;
			break;
		}

		if(fl_beacon_spawned_at_pos_recently[i] < fl_beacon_spawned_at_pos_recently[selection])
			selection = i;
	}
	
	Beacon = NPC_CreateByName("npc_starship_beacon", npc.index, fl_BeaconSpawnPos[selection], {0.0, 0.0, 0.0}, GetTeam(npc.index), "style1");
	int health = RoundToFloor(ReturnEntityMaxHealth(npc.index) * 0.05);	//like 5% hp of ship
	if(Beacon < MaxClients)
		return;

	npc.m_flBeaconRespawnTimer = GameTime + GetRandomFloat(10.0, 11.0 + (5.0 * npc.m_iBeaconsExist));
	npc.m_iBeaconsExist++;

	SetEntProp(Beacon, Prop_Data, "m_iHealth", health);
	SetEntProp(Beacon, Prop_Data, "m_iMaxHealth", health);

	Starship_Beacon beacon_npc = view_as<Starship_Beacon>(Beacon);
	beacon_npc.m_iState = EntIndexToEntRef(npc.index);

	fl_beacon_spawned_at_pos_recently[selection] = GetGameTime();

	//CPrintToChatAll("Selection: %i", fl_beacon_spawned_at_pos_recently);
	//CPrintToChatAll("Selection = %.3f", fl_beacon_spawned_at_pos_recently[selection]);

	if(!dungeon)
	{
		int Decicion = TeleportDiversioToRandLocation(Beacon,_,1250.0, 500.0);

		if(Decicion == 2)
			Decicion = TeleportDiversioToRandLocation(Beacon, _, 1250.0, 250.0);

		if(Decicion == 2)
			Decicion = TeleportDiversioToRandLocation(Beacon, _, 1250.0, 0.0);
	}
}
enum struct Regalia_SpiralGlave_Data {
	int iNPC_ref;
	
	float Duration;
	float Windup;

	float Angle;

	float Duration_Base;
	float Windup_Base;

}
static void Handle_SpiralGlaive(RegaliaClass npc)
{
	if(!npc.bDoesSectionExist(StarShip_BG_CoreDeco))
		return;

	float GameTime = GetGameTime(npc.index);

	if(npc.m_flSprial_Recharge > GameTime)
		return;
	
	if(npc.m_flShipAbilityActive > GameTime)
		return;

	float ShipLoc[3]; GetAbsOrigin(npc.index, ShipLoc);

	int entity = MaxClients + 1;

	int vault_core = 0;
	bool Found = false;
	while((entity = FindEntityByClassname(entity, "obj_building")) != -1)
	{
		if(IsValidEnemy(npc.index, entity))
		{
			if(IsDungeonCenterId() == i_NpcInternalId[entity])
			{
				Found = true;
				vault_core = entity;
				break;
			}
		}
	}

	if(Found)
	{
		float VaultLoc[3]; GetAbsOrigin(vault_core, VaultLoc);
		float Dist = Get2DVectorDistances(ShipLoc, VaultLoc, true);

		if(Dist < (500.0 * 500.0))	//makes it so the downward deathray doesn't activate right above the main building thus leading to an instant game over.
			return;

		if(Dist > (1500.0 * 1500.0))
			return;
	}
	else
	{
		float Dist = Get2DVectorDistances(ShipLoc, VaultVectorPoints[0], true);

		if(Dist > (1500.0 * 1500.0))
			return;
	}

	npc.m_flSprial_Recharge = GameTime + 1.0;
	
	Regalia_SpiralGlave_Data Data;

	Data.iNPC_ref = EntIndexToEntRef(npc.index);
	Data.Duration_Base 	= 10.0;
	Data.Windup_Base 	= 5.0;
	Data.Angle = GetRandomFloat(0.0, 360.0);

	Data.Duration 				= GameTime + Data.Duration_Base + Data.Windup_Base;
	Data.Windup 				= GameTime + Data.Windup_Base;

	npc.m_flShipAbilityActive 	= GameTime + Data.Duration_Base + Data.Windup_Base + 1.0;

	Data.Duration_Base 	*= ReturnEntityAttackspeed(npc.index);
	Data.Windup_Base	*= ReturnEntityAttackspeed(npc.index);

	f3_LastValidPosition[npc.index] 	= VaultVectorPoints[0];
	npc.m_bVectoredThrust 				= true;
	func_ShipTurn[npc.index] 			= IOC_TurnControl;
	npc.m_flRevertControlOverride		= npc.m_flShipAbilityActive - 1.0;
	npc.m_bCutThrust					= true;

	npc.m_flSprial_Recharge				= GameTime + 30.0;	//NOT THE ACTUAL RECHARGE!!!! ACTUAL ONE IS LOWER.

	DataPack Pack = new DataPack();
	Pack.WriteCellArray(Data, sizeof(Data));

	EmitSoundToAll(REGALIA_SPIRALGLAVE_SOUND, npc.index, SNDCHAN_VOICE, SNDLEVEL_RAIDSIREN, _, 1.0, RoundToCeil(100 * (14.0/(Data.Duration_Base + Data.Windup_Base))));
	EmitSoundToAll(REGALIA_SPIRALGLAVE_SOUND, npc.index, SNDCHAN_VOICE, SNDLEVEL_RAIDSIREN, _, 1.0, RoundToCeil(100 * (14.0/(Data.Duration_Base + Data.Windup_Base))));
	EmitSoundToAll(REGALIA_SPIRALGLAVE_SOUND, npc.index, SNDCHAN_VOICE, SNDLEVEL_RAIDSIREN, _, 1.0, RoundToCeil(100 * (14.0/(Data.Duration_Base + Data.Windup_Base))));

	RequestFrames(SpiralGlave_Tick, 1, Pack);
}
static void SpiralGlave_Tick(DataPack IncomingData)
{
	IncomingData.Reset();
	Regalia_SpiralGlave_Data Data;
	IncomingData.ReadCellArray(Data, sizeof(Data));

	delete IncomingData;

	int iNPC = EntRefToEntIndex(Data.iNPC_ref);

	if(!IsValidEntity(iNPC))
	{
		return;
	}

	RegaliaClass npc = view_as<RegaliaClass>(iNPC);

	float GameTime = GetGameTime(npc.index);

	if(Data.Duration < GameTime)
	{
		npc.m_flSprial_Recharge	= GameTime + 160.0;
		return;
	}

	float Ratio = (Data.Duration - GameTime) / Data.Duration_Base;

	float RotationSpeed = 4.5 * Ratio;

	Data.Angle +=RotationSpeed;

	bool Windup = (Data.Windup > GameTime);

	if(Data.Angle > 360.0)
		Data.Angle -= 360.0; 

	static const char ShipWeaponsSections[][] = {
		"central_weapons_port_left_bottom",
		"central_weapons_port_right_bottom"
	};

	float MiddleLoc[3];
	Zero(MiddleLoc);
	for(int i=0 ; i < 2 ; i++)
	{
		float Loc[3]; Loc = npc.GetWeaponSections(ShipWeaponsSections[i]);

		MiddleLoc[0] += Loc[0];
		MiddleLoc[1] += Loc[1];
	}

	MiddleLoc[0] /=2.0;
	MiddleLoc[1] /=2.0;

	float ShipOrigin[3]; GetAbsOrigin(npc.index, ShipOrigin);

	MiddleLoc[2] = ShipOrigin[2] - 150.0;

	const float Radius = 300.0;
	const float TE_Duration = 0.1;
	const float ThicknessRing = 25.0;
	const float Thickness = 50.0;
	int color[4] = {255, 255, 255, 255};
	color = iRegaliaColor(npc);

	if(Windup)
		color[3] = RoundToFloor(255.0 * (1.0 - Ratio));

	float RingLoc[3]; RingLoc = MiddleLoc;
	
	RingLoc[2]+=25.0;
	TE_SetupBeamRingPoint(RingLoc, Radius*2.0, Radius*2.0 - 1.0, g_Ruina_BEAM_Laser, 0, 0, 1, TE_Duration, ThicknessRing, 0.1, color, 1, 0);
	TE_SendToAll();
	RingLoc[2]-=50.0;
	TE_SetupBeamRingPoint(RingLoc, Radius*2.0, Radius*2.0 - 1.0, g_Ruina_BEAM_Laser, 0, 0, 1, TE_Duration, ThicknessRing, 0.1, color, 1, 0);
	TE_SendToAll();

	const float Length = 7000.0;
	const int loops = 8;

	Ruina_Laser_Logic Laser;	//this trace/damage is done every tick. so yeah.
	Laser.client = npc.index;
	Laser.Radius 		= Thickness * 0.5;
	Laser.Damage		= ModifyDamage(50.0);
	Laser.Bonus_Damage 	= ModifyDamage(10.0);
	Laser.damagetype 	= DMG_PLASMA|DMG_PREVENT_PHYSICS_FORCE;

	const float AngleFinal = 75.0;
	float Adjusted = 90.0 - AngleFinal;

	for(int i=0 ; i < loops ; i++)
	{
		float Angles[3]; Angles[1] = (360.0 / loops) * i + Data.Angle;
		float OffsetLoc[3];
		Get_Fake_Forward_Vec(Radius, Angles, OffsetLoc, MiddleLoc);
		float EndOffsetLoc[3];
		Angles[0] = Adjusted + AngleFinal * Ratio;
		Get_Fake_Forward_Vec(Length, Angles, EndOffsetLoc, OffsetLoc);
		
		TE_SetupBeamPoints(OffsetLoc, EndOffsetLoc, g_Ruina_BEAM_Laser, 0, 0, 0, TE_Duration, Thickness, Thickness, 0, 0.1, color, 3);
		TE_SendToAll();

		if(!Windup)
		{
			Laser.Start_Point 	= OffsetLoc;
			Laser.End_Point 	= EndOffsetLoc;
			Laser.Detect_Entities(On_LaserHit);
			//do damage!
		}
	}

	DataPack Pack = new DataPack();
	Pack.WriteCellArray(Data, sizeof(Data));

	RequestFrames(SpiralGlave_Tick, 1, Pack);
}
static void On_LaserHit(int client, int target, int damagetype, float damage)
{
	if(IsIn_HitDetectionCooldown(client,target))
		return;
			
	Set_HitDetectionCooldown(client, target, GetGameTime() + 0.25);	//if they walk backwards, its likely to hit them 2 times, but who on earth would willingly walk backwards/alongside the trajectory of the projectile

	float DamageOrigin[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", DamageOrigin);

	SDKHooks_TakeDamage(target, client, client, damage, damagetype, _, DamageOrigin); 
}
static float fl_Type1_CycleSpeed;
static void HandleUnderSlungWeapons(RegaliaClass npc)
{
	if(!npc.bDoesSectionExist(StarShip_BG_BottomWeps))
		return;

	float GameTime = GetGameTime(npc.index);

	if(npc.m_flShipAbilityActive > GameTime || npc.m_flUnderSlung_PrimaryRecharge > GameTime)
		return;

	//CPrintToChatAll("POST npc.m_flShipAbilityActive: %.3f", npc.m_flShipAbilityActive - GameTime);

	if(npc.m_flUnderSlung_Type0_Recharge < GameTime)
	{
		/*
		Type 1:
			Conditions To Enter: Avg Vec point must have atleast X players before commiting

			-Get average highest players concentration in a circle.
			-Create IOC.
			-IOC Draw points originate from underslung weapon ports.
			-While IOC is charging. ship speed slowed. and forced to look towards the IOC end point.
			-IOC spins.
		*/

		float radius = 500.0;
		int amt = 4;
		float Loc[3];
		Loc = vGetBestAverageWithinRadius(npc, radius, amt);

		float DetTime = 5.0;
		
		if(amt != -1)
		{
			f3_LastValidPosition[npc.index] 	= Loc;
			npc.m_flUnderSlung_Type0_Recharge 	= GameTime + 90.0;
			npc.m_flUnderSlung_PrimaryRecharge 	= GameTime + DetTime + 2.5;
			npc.m_flShipAbilityActive			= GameTime + DetTime + 1.0;
			npc.m_bVectoredThrust 				= true;
			func_ShipTurn[npc.index] 			= IOC_TurnControl;
			npc.m_flRevertControlOverride		= npc.m_flShipAbilityActive - 1.0;
			npc.m_bCutThrust					= true;

			Invoke_RegaliaIOC(npc, Loc, DetTime);
			return;
		}
	}
	if(npc.m_flUnderSlung_Type1_Recharge < GameTime)
	{
		/*
			Type 2:
			Conditions To Enter: Avg Vec point must have atleast X players before commiting

			-Get average highest players concentration in a circle.
			-Create delayed X lasers pattern barrages.

			-When creating a laser pattern. use underslung weapons to create a line from beam to start point.
		*/

		float radius = 500.0;
		int amt = 4;
		float Loc[3];
		Loc = vGetBestAverageWithinRadius(npc, radius, amt);

		if(amt != -1)
		{
			fl_Type1_CycleSpeed = 2.5;
		
			const int Duration = 6;	//how many cycles to do
			const float Recharge = 120.0;

			f3_LastValidPosition[npc.index] 	= Loc;
			npc.m_flUnderSlung_Type1_Recharge 	= GameTime + Recharge;
			npc.m_flUnderSlung_PrimaryRecharge 	= GameTime + 5.0;
			npc.m_flShipAbilityActive			= GameTime + 5.0;
			npc.m_bVectoredThrust 				= true;
			func_ShipTurn[npc.index] 			= IOC_TurnControl;
			npc.m_flRevertControlOverride		= GameTime + 5.0;
			npc.m_bCutThrust					= true;

			Invoke_RegaliaDoGPatterns(npc, Loc, Duration, radius);

			float Thickness = 30.0;
			int color[4] = {255, 255, 255, 255};
			color = iRegaliaColor(npc);
			for(int i=0 ; i < 4 ; i++)
			{
				TE_SetupBeamRingPoint(Loc, radius*2.0, radius*2.0 - 1.0, g_Ruina_BEAM_Laser, 0, 0, 1, fl_Type1_CycleSpeed, Thickness, 0.1, color, 1, 0);
				TE_SendToAll();
				Loc[2]+=25.0;
			}
			return;
		}
	}
	if(npc.m_flUnderSlung_Type2_Recharge < GameTime)
	{
		npc.m_flUnderSlung_Type2_Recharge = GameTime + 5.0;

		float Windup = 5.0;

		if(Invoke_RegaliaAnnihilateTarget(npc, Windup))
		{
			npc.m_flUnderSlung_Type2_Recharge = GameTime + 60.0;

			npc.m_flUnderSlung_PrimaryRecharge 	= GameTime + Windup + 2.5;
			npc.m_flShipAbilityActive			= GameTime + Windup + 0.5;
			npc.m_bVectoredThrust 				= true;
			func_ShipTurn[npc.index] 			= IOC_TurnControl;
			npc.m_flRevertControlOverride		= GameTime + Windup + 0.5;
			npc.m_bCutThrust					= true;
		}
	}

	if(npc.m_flUnderSlung_PrimaryRecharge < GameTime + 1.0)
		npc.m_flUnderSlung_PrimaryRecharge = GameTime + 1.0;
				
}
enum struct RegaliaAnnihilateTarget_Data {
	int iNPC;
	int Victim;

	float Windup;
	float Windup_Base;

	float CuttoffAt;
	float LastLoc[3];

	float AngleModif;

	float SoundTimer;

}
static bool Invoke_RegaliaAnnihilateTarget(RegaliaClass npc, float Windup)
{
	int count = CountPlayersOnRed(2);

	if(count <= 5)
		return false;
	
	float RatioRequired = 0.15;
	int highest = 0; 
	for(int client = 1 ; client <= MaxClients ; client++)
	{
		if(fl_player_weapon_score[client] <= 0.0)
			continue;
			
		if(fl_player_weapon_score[client] > fl_player_weapon_score[highest])
			highest = client;
	}

	if(highest == 0)
		return false;

	int MaxHealth = ReturnEntityMaxHealth(npc.index);

	float Damage_Dealt = fl_player_weapon_score[highest] / MaxHealth;

	//CPrintToChatAll("highest      : %N", highest);
	//CPrintToChatAll("Damage_Dealt : %.5f", Damage_Dealt);
	//CPrintToChatAll("RatioRequired: %.5f", RatioRequired);

	if(Damage_Dealt < RatioRequired)
		return false;

	fl_player_weapon_score[highest] = 0.0;

	GetAbsOrigin(highest, f3_LastValidPosition[npc.index]);

	RegaliaAnnihilateTarget_Data Data;
	Data.iNPC 		= EntIndexToEntRef(npc.index);
	Data.Victim 	= EntIndexToEntRef(highest);							//target to annihilate
	Data.CuttoffAt 	= GetGameTime(npc.index) + Windup - 1.25;
	Data.Windup_Base= Windup;
	Data.Windup 	= GetGameTime(npc.index) + Data.Windup_Base;
	Data.LastLoc 	= f3_LastValidPosition[npc.index];
	Data.AngleModif = GetRandomFloat(0.0, 360.0);
	Data.SoundTimer = 0.0;

	Data.Windup_Base *= ReturnEntityAttackspeed(npc.index);

	DataPack Pack = new DataPack();
	Pack.WriteCellArray(Data, sizeof(Data));

	RequestFrames(Regalia_AnnihilateTarget_Tick, 1, Pack);

	return true;
}
static int i_who_to_kill;
static void Regalia_AnnihilateTarget_Tick(DataPack IncomingData)
{
	IncomingData.Reset();
	RegaliaAnnihilateTarget_Data Data;
	IncomingData.ReadCellArray(Data, sizeof(Data));

	int iNPC 		= EntRefToEntIndex(Data.iNPC);
	int target 		= EntRefToEntIndex(Data.Victim);

	delete IncomingData;

	if(!IsValidEntity(iNPC))
	{
		return;
	}

	RegaliaClass npc = view_as<RegaliaClass>(iNPC);

	float GameTime = GetGameTime(npc.index);
	if(!IsValidClient(target) || TeutonType[target] != TEUTON_NONE)
	{
		npc.m_flUnderSlung_PrimaryRecharge 	= GameTime + 1.0;
		npc.m_flShipAbilityActive			= GameTime + 1.0;
		npc.m_flRevertControlOverride		= GameTime + 1.0;
	}

	float Ratio = (Data.Windup - GameTime) / Data.Windup_Base;

	if(Data.CuttoffAt > GameTime)
	{
		GetAbsOrigin(target, f3_LastValidPosition[npc.index]);
	}

	Data.LastLoc = f3_LastValidPosition[npc.index];
	const float radius = 300.0;

	Data.AngleModif += 5.0*Ratio;

	if(Data.AngleModif > 360.0)
		Data.AngleModif -= 360.0;

	const float Thickness = 15.0;
	const float TE_Duration = 0.1;
	const float Amp = 0.1;
	int color[4] = {255, 255, 255, 255};
	color = iRegaliaColor(npc);
	const float height =  1500.0;	//1500
	const int Sections = 8;

	float SectionLoc[4][3];
	static const char ShipWeaponsSections[][] = {
		"underside_weapons_left_outer",
		"underside_weapons_left_inner",
		"underside_weapons_right_outer",
		"underside_weapons_right_inner"
	};

	for(int i=0 ; i < 4 ; i++)
	{
		SectionLoc[i] = npc.GetWeaponSections(ShipWeaponsSections[i]);
	}

	if(Data.SoundTimer < GameTime)
	{
		Data.SoundTimer = GameTime + 0.2;
		EmitSoundToAll(REGALIA_SPECIAL_IOC_CHARGE_LOOP, target, SNDCHAN_VOICE, SNDLEVEL_NORMAL, _, 0.7, 166 - RoundToFloor(100 * (1.0 - Ratio)), _, Data.LastLoc);
	}

	TE_SetupBeamRingPoint(Data.LastLoc, radius*2.0, radius*2.0 - 1.0, g_Ruina_BEAM_Combine_Black, 0, 0, 1, TE_Duration, Thickness*1.5, Amp, {255, 255, 255, 255}, 1, 0);
	TE_SendToAll();

	if(Data.Windup < GameTime)
	{	
		i_who_to_kill = target;
		Explode_Logic_Custom(0.0, npc.index, npc.index, -1, Data.LastLoc, radius,_,_, true, _, _, 0.2, Regalia_Annihilate_IonHitPre);

		Data.LastLoc[2]+=10.0;
		TE_SetupBeamRingPoint(Data.LastLoc, radius*2.0, 0.0, g_Ruina_BEAM_Combine_Black, 0, 0, 1, 1.75, Thickness*1.5, Amp, {255, 255, 255, 255}, 1, 0);
		TE_SendToAll();

		//a fucking THUNDER CLAP FROM GOD the sound
		EmitSoundToAll(REGALIA_SPECIAL_IOC_EXPLOSION_SOUND, _, _, SNDLEVEL_RAIDSIREN, _, 1.0, 50);
		EmitSoundToAll(REGALIA_SPECIAL_IOC_EXPLOSION_SOUND, _, _, SNDLEVEL_RAIDSIREN, _, 1.0, 50);

		EmitSoundToAll(REGALIA_SPECIAL_IOC_EXPLOSION_SOUND_2, _, _, SNDLEVEL_RAIDSIREN, _, 1.0, 100);	

		for(int z=1 ; z <= 3 ; z++)
		{
			for(int i=0 ; i < Sections ; i++)
			{
				float OffsetLoc[3]; OffsetLoc = vCreateDoGVectorMesh(Data.LastLoc, i, Sections, (radius / 3.0) * z, Data.AngleModif);

				float SkyLoc[3]; SkyLoc = OffsetLoc; SkyLoc[2]+=height;
				OffsetLoc[2]-= 250.0;

				TE_SetupBeamPoints(OffsetLoc, SkyLoc, g_Ruina_BEAM_Combine_Black, 0, 0, 0, (2.0 - (0.25*z)), Thickness, Thickness, 0, Amp, {255, 255, 255, 255}, 3);
				TE_SendToAll();
			}
		}

		return;
	}
	else
	{
		for(int i=0 ; i < Sections ; i++)
		{
			float OffsetLoc[3]; OffsetLoc = vCreateDoGVectorMesh(Data.LastLoc, i, Sections, radius * Ratio, Data.AngleModif);

			float SkyLoc[3]; SkyLoc = OffsetLoc; SkyLoc[2]+=height;

			TE_SetupBeamPoints(OffsetLoc, SkyLoc, g_Ruina_BEAM_Laser, 0, 0, 0, TE_Duration, Thickness, Thickness, 0, Amp, color, 3);
			TE_SendToAll();

			TE_SetupBeamPoints(OffsetLoc, SectionLoc[i / 2], g_Ruina_Laser_BEAM, 0, 0, 0, TE_Duration, Thickness*0.1, Thickness*0.1, 0, Amp, color, 3);
			TE_SendToAll();
		}
		
	}


	DataPack Pack = new DataPack();
	Pack.WriteCellArray(Data, sizeof(Data));

	RequestFrames(Regalia_AnnihilateTarget_Tick, 1, Pack);
}
static void Regalia_Annihilate_IonHitPre(int entity, int victim, float damage, int weapon)
{
	if(victim == i_who_to_kill)
	{
		SDKHooks_TakeDamage(victim, entity, entity, ModifyDamage(150.0), DMG_TRUEDAMAGE|DMG_PLASMA|DMG_PREVENT_PHYSICS_FORCE, _, f3_LastValidPosition[entity]); 
	}
	else
	{
		SDKHooks_TakeDamage(victim, entity, entity, ModifyDamage(75.0), DMG_PLASMA|DMG_PREVENT_PHYSICS_FORCE, _, f3_LastValidPosition[entity]); 
	}
}
enum struct RegaliaIONSection {
	float Dist;
	float Angles[3];
	float LastLoc[3];
}
enum struct Regalia_DoG_IonData {
	int iNPC;
	float Loc[3];
	float Recharge;
	float Radius;
	int cylce;
	float AngleModif;
	float CycleSpeed;
	float SoundTimer;
	ArrayList SectionData;

	int Current_Amt;
	int CycleDuration;
}
static void Invoke_RegaliaDoGPatterns(RegaliaClass npc, float Loc[3], int Duration, float Radius)
{
	Loc[2]+=50.0;
	Regalia_DoG_IonData Data;
	Data.iNPC			= EntIndexToEntRef(npc.index);
	Data.Loc			= Loc;
	Data.CycleDuration  = Duration;
	Data.Radius			= Radius;
	Data.cylce			= 0;
	Data.AngleModif		= GetRandomFloat(0.0, 360.0);
	Data.CycleSpeed		= GetGameTime() + fl_Type1_CycleSpeed;
	Data.SoundTimer		= 0.0;
	Data.Recharge 		= 0.0;

	Data.Current_Amt 	= 4;
	Data.SectionData	= new ArrayList(sizeof(RegaliaIONSection));

	for(int i= 0 ; i < 16 ; i++)
	{
		RegaliaIONSection Section;
		Section.Dist = 0.0;
		Zero(Section.Angles);
		Zero(Section.LastLoc);
		Data.SectionData.PushArray(Section);
	}

	Loc[2]-=50.0;

	DataPack Pack = new DataPack();
	Pack.WriteCellArray(Data, sizeof(Data));

	RequestFrames(DoG_PatternTick, 1, Pack);
}
static void DoG_PatternTick(DataPack IncomingData)
{
	IncomingData.Reset();
	Regalia_DoG_IonData Data;
	IncomingData.ReadCellArray(Data, sizeof(Data));

	int iNPC 		= EntRefToEntIndex(Data.iNPC);
	float Radius 	= Data.Radius;

	delete IncomingData;

	if(!IsValidEntity(iNPC))
	{
		delete Data.SectionData;
		return;
	}

	RegaliaClass npc = view_as<RegaliaClass>(iNPC);

	float GameTime = GetGameTime(npc.index);
	
	if(Data.CycleDuration < 0)
	{
		npc.m_flUnderSlung_PrimaryRecharge 	= GameTime + 1.0;
		npc.m_flShipAbilityActive			= GameTime + 1.0;
		npc.m_flRevertControlOverride		= GameTime + 1.0;
		delete Data.SectionData;
		return;
	}

	npc.m_flUnderSlung_PrimaryRecharge 	= GameTime + 5.0;
	npc.m_flShipAbilityActive			= GameTime + 5.0;
	npc.m_flRevertControlOverride		= GameTime + 5.0;

	float BaseChargeTime = fl_Type1_CycleSpeed;

	float SectionLoc[4][3];
	static const char ShipWeaponsSections[][] = {
		"underside_weapons_left_outer",
		"underside_weapons_left_inner",
		"underside_weapons_right_outer",
		"underside_weapons_right_inner"
	};

	for(int i=0 ; i < 4 ; i++)
	{
		SectionLoc[i] = npc.GetWeaponSections(ShipWeaponsSections[i]);
	}

	int Sections = Data.Current_Amt;

	if(Data.Recharge > GameTime)
	{
		DataPack Pack = new DataPack();
		Pack.WriteCellArray(Data, sizeof(Data));
		int ticks = RoundToCeil(11 * ReturnEntityAttackspeed(npc.index));
		RequestFrames(DoG_PatternTick, ticks, Pack);
		return;
	}

	int color[4] = {255, 255, 255, 255};
	color = iRegaliaColor(npc);

	const float Thickness = 18.0;
	const float TE_Duration = 0.1;
	const float Amp = 0.1;

	Data.AngleModif+=1.0;
	
	if(Data.AngleModif > 360.0)
		Data.AngleModif -= 360.0;

	if(Data.CycleSpeed > GameTime)
	{
		float Ratio = (Data.CycleSpeed - GameTime) / (BaseChargeTime * ReturnEntityAttackspeed(npc.index));

		bool trace_update = false;
		if(Data.SoundTimer < GameTime)
		{
			EmitSoundToAll(REGALIA_PATTERNS_CHARGE_SOUND, _, _, BOSS_ZOMBIE_SOUNDLEVEL, _, 0.22, RoundFloat(Ratio * 80.0) + 50, _, Data.Loc);
			Data.SoundTimer = GameTime + 0.1;
			trace_update = true;
		}

		for(int i=0 ; i < Sections ; i++)
		{
			float OffsetLoc[3]; OffsetLoc = vCreateDoGVectorMesh(Data.Loc, i, Sections, Radius, Data.AngleModif);

			float LookAtLoc[3];

			switch(Data.cylce)
			{
				case 0:
				{
					LookAtLoc = Data.Loc;
				}
				case 1:
				{
					LookAtLoc = vCreateDoGVectorMesh(Data.Loc, i, Sections, Radius * 0.2, Data.AngleModif + 45.0);
				}
				case 2:
				{
					LookAtLoc = vCreateDoGVectorMesh(Data.Loc, i, Sections, Radius * 0.75, Data.AngleModif + 45.0);
				}
				case 3:
				{
					LookAtLoc = vCreateDoGVectorMesh(Data.Loc, i, Sections, Radius * 0.5, Data.AngleModif + 90.0);
				}
				case 4:
				{
					LookAtLoc = vCreateDoGVectorMesh(Data.Loc, i, Sections, Radius * 0.5, Data.AngleModif * - 1.0 + 90.0);
				}
				case 5:
				{
					LookAtLoc = vCreateDoGVectorMesh(Data.Loc, i, Sections, Radius * Ratio, Data.AngleModif * - 1.0 + (90.0 * Ratio));
				}
				default:
				{
					Data.cylce  = 0;
				}
			}

			float AnglesToCore[3];
			MakeVectorFromPoints(OffsetLoc, LookAtLoc, AnglesToCore);
			GetVectorAngles(AnglesToCore, AnglesToCore);

			RegaliaIONSection Section;
			Data.SectionData.GetArray(i, Section);

			Ruina_Laser_Logic Laser;
			if(trace_update)	//don't do a trace every tick. only once every 0.1s
			{
				Laser.DoForwardTrace_Custom(AnglesToCore, OffsetLoc, Radius);
				
				Section.Dist = GetVectorDistance(Laser.Start_Point, Laser.End_Point);
			}
			else
			{
				Laser.Start_Point = OffsetLoc;
				Get_Fake_Forward_Vec(Section.Dist, AnglesToCore, Laser.End_Point, Laser.Start_Point);
			}
			Section.Angles = AnglesToCore;
			Section.LastLoc = Laser.Start_Point;

			Data.SectionData.SetArray(i, Section);
			TE_SetupBeamPoints(Laser.Start_Point, Laser.End_Point, g_Ruina_BEAM_Laser, 0, 0, 0, TE_Duration, Thickness, Thickness, 0, Amp, color, 3);
			TE_SendToAll();
		}
		for(int i=0 ; i < 4 ; i++)
		{
			float OffsetLoc[3]; OffsetLoc = vCreateDoGVectorMesh(Data.Loc, i, 4, Radius, Data.AngleModif);
			TE_SetupBeamPoints(OffsetLoc, SectionLoc[i], g_Ruina_Laser_BEAM, 0, 0, 0, TE_Duration, Thickness*0.25, Thickness*0.25, 0, Amp, color, 3);
			TE_SendToAll();
		}
	}
	else	//FIRE!
	{
		Data.SoundTimer = 0.0;

		Data.CycleDuration--;
		Data.Current_Amt +=2;

		float recharge_speed = 2.0;

		Data.Recharge = GameTime + recharge_speed;

		Data.cylce++;
		Data.CycleSpeed = GameTime + BaseChargeTime + recharge_speed;
		

		Ruina_Projectiles Projectile;
		Projectile.iNPC = npc.index;
		
		//Projectile.radius = 0.0;
		Projectile.damage 	= ModifyDamage(100.0);
		Projectile.bonus_dmg= 0.2;
		Projectile.speed 	= 3000.0;
		Projectile.visible 	= false;

		for(int i=0 ; i < Sections ; i++)
		{
			RegaliaIONSection Section;
			Data.SectionData.GetArray(i, Section);

			Projectile.Start_Loc = Section.LastLoc;
			Projectile.Angles	 = Section.Angles;
			
			npc.PlayPattenShootSound(Projectile.Start_Loc);

			char Particle[50];
			if(i % 2)
				Particle = "drg_manmelter_trail_blue";
			else
				Particle = "drg_manmelter_trail_red";

			Projectile.Time 	= Section.Dist / Projectile.speed;

			int projectile = Projectile.Launch_Projectile(Func_On_Proj_DoG_Patterns);

			if(!IsValidEntity(projectile))
				continue;

			//SetEntProp(projectile, Prop_Send, "m_usSolidFlags", 12); 

			MakeObjectIntangeable(projectile);
			Projectile.Apply_Particle(Particle);

			TE_SetupBeamPoints(Projectile.Start_Loc, SectionLoc[GetRandomInt(0, 3)], g_Ruina_Laser_BEAM, 0, 0, 0, TE_Duration*2.0, Thickness, Thickness, 0, Amp*2.0, color, 3);
			TE_SendToAll();
		}

		if(Data.CycleDuration < 0)
		{
			delete Data.SectionData;
			npc.m_flUnderSlung_PrimaryRecharge 	= GameTime + 1.0;
			npc.m_flShipAbilityActive			= GameTime + 1.0;
			npc.m_flRevertControlOverride		= GameTime + 1.0;
			return;
		}

		Data.AngleModif	= GetRandomFloat(0.0, 360.0);

		int amt = 4;
		float Loc[3];
		Loc = vGetBestAverageWithinRadius(npc, Radius, amt);

		Data.Loc = Loc;
	
		if(amt == -1)
		{
			delete Data.SectionData;
			npc.m_flUnderSlung_PrimaryRecharge 	= GameTime + 1.0;
			npc.m_flShipAbilityActive			= GameTime + 1.0;
			npc.m_flRevertControlOverride		= GameTime + 1.0;
			return;
		}

		float Ring_TE_Duration = fl_Type1_CycleSpeed + recharge_speed * ReturnEntityAttackspeed(npc.index);

		float ThicknessRing = 30.0;
		for(int i=0 ; i < 4 ; i++)
		{
			TE_SetupBeamRingPoint(Loc, Radius*2.0, Radius*2.0 - 1.0, g_Ruina_BEAM_Laser, 0, 0, 1, Ring_TE_Duration, ThicknessRing, 0.1, color, 1, 0);
			TE_SendToAll();
			Loc[2]+=25.0;
		}

		Data.Loc[2]+=50.0;
	}

	DataPack Pack = new DataPack();
	Pack.WriteCellArray(Data, sizeof(Data));
	RequestFrames(DoG_PatternTick, 1, Pack);
}
static void Func_On_Proj_DoG_Patterns(int entity, int other)
{
	if(other <= 0)
	{
		return;
	}

	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if(!IsValidEntity(owner))
	{
		Ruina_Remove_Projectile(entity);
		return;
	}

	if(IsIn_HitDetectionCooldown(entity,other))
		return;
			
	Set_HitDetectionCooldown(entity, other, GetGameTime() + 0.25);	//if they walk backwards, its likely to hit them 2 times, but who on earth would willingly walk backwards/alongside the trajectory of the projectile

	float ProjectileLoc[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);

	float dmg = fl_ruina_Projectile_dmg[entity];

	if(ShouldNpcDealBonusDamage(other))
		dmg *= fl_ruina_Projectile_bonus_dmg[entity];

	SDKHooks_TakeDamage(other, entity, entity, dmg, DMG_PLASMA|DMG_PREVENT_PHYSICS_FORCE, _, ProjectileLoc); 
}
static float[] vCreateDoGVectorMesh(float Core[3], int section, int max_sections, float radius, float modif)
{
	float Angles[3]; Angles[1] = (360.0 / max_sections) * section + modif;
	float OffsetLoc[3];
	Get_Fake_Forward_Vec(radius, Angles, OffsetLoc, Core);
	return OffsetLoc;
}
static void IOC_TurnControl(int iNPC)
{
	RegaliaClass npc = view_as<RegaliaClass>(iNPC);

	float WantedLoc[3]; WantedLoc = f3_LastValidPosition[npc.index];

	float Angles[3];
	VectorTurnData Data;
	Angles = npc.RotateShipModelTowards(WantedLoc, Data, 1.0);

	//float OffsetLoc[3]; GetAbsOrigin(npc.index, OffsetLoc);
	//TE_SetupBeamPoints(OffsetLoc, WantedLoc, g_Ruina_BEAM_Laser, 0, 0, 0, 0.1, 50.0, 50.0, 0, 0.1, {255,255,255,255}, 3);
	//TE_SendToAll();

	Angles[2] = -1.0 * Data.YawRotateLeft;
	float RotationClamp = fl_ShipRollClamps;
	const float PitchClamp = 15.0;
	//clamp ship pitch angles
	if(Angles[0] > PitchClamp)
		Angles[0] = PitchClamp;
	else if(Angles[0] < -PitchClamp)
		Angles[0] = -PitchClamp;
	

	//clamp ship rotational angles
	if(Angles[2] > RotationClamp)
		Angles[2] = RotationClamp;
	else if(Angles[2] < -RotationClamp)
		Angles[2] = -RotationClamp;

	npc.RotateShipModel(Angles);
}
static void Invoke_RegaliaIOC(RegaliaClass npc, float EndLoc[3], float DetTime)
{
	float dmg = ModifyDamage(100.0);
	const float Radius = 250.0;
	int color[4] = {255, 255, 255, 255};
	color = iRegaliaColor(npc);

	EmitSoundToAll(REGALIA_IOC_STARTUP, _, _, SNDLEVEL_RAIDSIREN, _, 1.0, 50);
	EmitSoundToAll(REGALIA_IOC_CHARGE_LOOP, npc.index, SNDCHAN_VOICE, SNDLEVEL_RAIDSIREN, _, 1.0, 50, _, EndLoc);

	DataPack Pack = new DataPack();
	Pack.WriteCell(EntIndexToEntRef(npc.index));
	Pack.WriteFloatArray(EndLoc, 3);
	Pack.WriteFloat(DetTime + GetGameTime(npc.index));
	Pack.WriteFloat(dmg);
	Pack.WriteFloat(Radius);
	Pack.WriteFloat(0.0);		//angle modif
	RequestFrames(RegaliaIOC_Tick, 1, Pack);

	DetTime *=ReturnEntityAttackspeed(npc.index);

	EndLoc[2]+=10.0;

	const float Thickness = 25.0;

	TE_SetupBeamRingPoint(EndLoc, Radius*2.0, 0.0,			 	g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, DetTime, Thickness, 0.75, color, 1, 0);
	TE_SendToAll();
	TE_SetupBeamRingPoint(EndLoc, Radius*2.0, Radius*2.0+0.5, 	g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, DetTime, Thickness, 0.1, color, 1, 0);
	TE_SendToAll();
}
static void RegaliaIOC_Tick(DataPack Data)
{
	Data.Reset();

	int iNPC = EntRefToEntIndex(Data.ReadCell());
	float EndLoc[3]; Data.ReadFloatArray(EndLoc, 3);
	float DetTimer 	= Data.ReadFloat();
	float dmg 		= Data.ReadFloat();
	float Radius	= Data.ReadFloat();
	float AngleModif= Data.ReadFloat();

	delete Data;

	if(!IsValidEntity(iNPC))
		return;

	RegaliaClass npc = view_as<RegaliaClass>(iNPC);

	int Sections = 8;

	float SectionLoc[4][3];
	static const char ShipWeaponsSections[][] = {
		"underside_weapons_left_outer",
		"underside_weapons_left_inner",
		"underside_weapons_right_outer",
		"underside_weapons_right_inner"
	};
	for(int i=0 ; i < 4 ; i++)
	{
		SectionLoc[i] = npc.GetWeaponSections(ShipWeaponsSections[i]);
	}


	AngleModif+=GetRandomFloat(1.0, 2.0) * ReturnEntityAttackspeed(npc.index);

	if(AngleModif > 360.0)
		AngleModif -= 360.0;

	const float Thickness = 25.0;
	const float TE_Duration = 0.1;
	const float Amp = 0.1;
	int color[4] = {255, 255, 255, 255};
	color = iRegaliaColor(npc);
	const float height =  1500.0;	//1500

	for(int i=0 ; i < Sections ; i++)
	{
		float Angles[3]; Angles[1] = (360.0 / Sections) * float(i) + AngleModif;
		float OffsetLoc[3];
		Get_Fake_Forward_Vec(Radius, Angles, OffsetLoc, EndLoc);

		//CPrintToChatAll("Number: %i", i / 2);

		float SkyLoc[3]; SkyLoc = OffsetLoc; SkyLoc[2]+=height;

		TE_SetupBeamPoints(OffsetLoc, SkyLoc, g_Ruina_BEAM_Laser, 0, 0, 0, TE_Duration, Thickness, Thickness, 0, Amp, color, 3);
		TE_SendToAll();

		TE_SetupBeamPoints(OffsetLoc, SectionLoc[i / 2], g_Ruina_Laser_BEAM, 0, 0, 0, TE_Duration, Thickness*0.5, Thickness*0.5, 0, Amp, color, 3);
		TE_SendToAll();
	}

	if(DetTimer < GetGameTime(npc.index))
	{
		StopSound(npc.index, SNDCHAN_VOICE, REGALIA_IOC_CHARGE_LOOP);
		Explode_Logic_Custom(dmg, npc.index, npc.index, -1, EndLoc, Radius,_,0.8, true, _, _, 0.2);

		EmitAmbientSound(REGALIA_IOC_EXPLOSION_SOUND, EndLoc, _, 100, _, _, GetRandomInt(60, 80));

		const float Time = 1.0;
		const int loop_for = 15;

		const float thicc = 4.0;
		float Seperation = height / loop_for;
		float Offset_Time = Time / loop_for;

		float spawnLoc[3]; spawnLoc = EndLoc;
		for(int i = 1 ; i <= loop_for ; i++)
		{
			float timer = Offset_Time*i+0.3;
			if(timer<=0.02)
				timer=0.02;
			float end_ratio = (((loop_for/2.0)/i));
			float final_radius = Radius*end_ratio;
			if(final_radius > 4096.0)
				final_radius= 4095.0;
			TE_SetupBeamRingPoint(spawnLoc, 0.0, final_radius, g_Ruina_Laser_BEAM, g_Ruina_Laser_BEAM, 0, 1, timer, thicc, 0.1, color, 1, 0);
			TE_SendToAll();
			spawnLoc[2]+=Seperation;
		}
		return;
	}
	
	DataPack Pack = new DataPack();
	Pack.WriteCell(EntIndexToEntRef(npc.index));
	Pack.WriteFloatArray(EndLoc, 3);
	Pack.WriteFloat(DetTimer);
	Pack.WriteFloat(dmg);
	Pack.WriteFloat(Radius);
	Pack.WriteFloat(AngleModif);
	RequestFrames(RegaliaIOC_Tick, 1, Pack);

}
static void HandleDroneSystem(RegaliaClass npc)
{
	if(!npc.bDoesSectionExist(StarShip_BG_CoreDeco))
		return;

	float GameTime = GetGameTime(npc.index);

	if(npc.m_flDroneSpawnNext > GameTime)
		return;

	npc.m_flDroneSpawnNext = GameTime + 12.5;

	bool TopSection 	= true;
	bool BottomSection 	= true;

	if(npc.m_flShipAbilityActive > GameTime)
		BottomSection = false;

	int SpawnAmt = 4;
	
	static const char Sections[][] = {
		"central_weapons_port_left_top",
		"central_weapons_port_right_top",
		"central_weapons_port_left_bottom",
		"central_weapons_port_right_bottom" 
	};

	if(!TopSection && !BottomSection)
	{
		npc.m_flDroneSpawnNext = GameTime + 1.0;
		return;
	}

	float ShipAngles[3]; ShipAngles = npc.GetAngles();

	if(TopSection)
	{
		for(int i=0 ; i < 2 ; i++)
		{
			float Loc[3]; Loc = npc.GetWeaponSections(Sections[i]);
			for(int loop=0 ; loop < SpawnAmt ; loop++)
			{
				float Angles[3]; Angles = ShipAngles;
				Angles[2] = 0.0;
				Angles[1] += (360.0 / SpawnAmt) * loop;
				Angles[0] = -45.0;
				FireDrones(npc, Loc, Angles);
			}
		}
	}
	if(BottomSection)
	{
		for(int i=2 ; i < 4 ; i++)
		{
			float Loc[3]; Loc = npc.GetWeaponSections(Sections[i]);
			for(int loop=0 ; loop < SpawnAmt ; loop++)
			{
				float Angles[3]; Angles = ShipAngles;
				Angles[2] = 0.0;
				Angles[1] += (360.0 / SpawnAmt) * loop;
				Angles[0] = 45.0;
				FireDrones(npc, Loc, Angles);
			}
		}
	}
}
static void FireDrones(CClotBody npc, float Loc[3], float Angles[3])
{
	int Drone = NPC_CreateByName("npc_lantean_drone_projectile", npc.index, Loc, Angles, GetTeam(npc.index), "blue;raidmodescaling_damage");
	int health = RoundToFloor(ReturnEntityMaxHealth(npc.index) * 0.001);	//like 0.1% hp of ship

	const float DroneSpeed = 750.0;
	if(Drone > MaxClients)
	{
		SetEntProp(Drone, Prop_Data, "m_iHealth", health);
		SetEntProp(Drone, Prop_Data, "m_iMaxHealth", health);

		LanteanProjectile drone_npc = view_as<LanteanProjectile>(Drone);
		fl_AbilityVectorData[drone_npc.index] = Angles;

		drone_npc.m_flTimeTillDeath = GetGameTime() + 10.0 + GetRandomFloat(0.5, 1.5);
		drone_npc.m_flSpeed = DroneSpeed + 200.0 * GetRandomFloat(0.8, 1.2);

		switch(GetRandomInt(1, 2))
		{
			case 1:
			{
				EmitSoundToAll(REGALIA_LANTEAN_DRONE_SHOOT_1, drone_npc.index, _, 65, _, 0.35, 160);
			}
			case 2:
			{
				EmitSoundToAll(REGALIA_LANTEAN_DRONE_SHOOT_2, drone_npc.index, _, 65, _, 0.35, 160);
			}
		}
	}
}
static float ModifyDamage(float dmg)
{
	if(bShipRaidModeScaling)
		return dmg * RaidModeScaling;

	return dmg * 10.0;
}
static float fl_PrimaryLanceDuration_Base 		= 20.0;
static float fl_PrimaryLanceRecharge_Base 		= 120.0;
static float fl_PrimaryLancesTravelSpeed		= 35.0;
static float fl_PrimaryLancesTurnSpeed			= 2.5;
static float fl_primaryLanceDistanceRegulation	= 3000.0;
static float fl_PrimaryLanceTravelDetectionSize = 25.0;
static float fl_PrimaryLanceDetectionSize 		= 600.0;
static void LanceeWeaponTurnControl(int iNPC)
{
	float WantedLoc[3];
	RegaliaClass npc = view_as<RegaliaClass>(iNPC);

	if(!npc.m_bVectoredThrust_InUse && !npc.m_bCutThrust)
		return;

	if(!IsValidEntity(npc.m_iTarget))
		return;

	if(npc.m_flLanceDuration != FAR_FUTURE)
	{
		//float GameTime = GetGameTime(npc.index);

		static const char Sections[][] = {
			"forward_lance_left_end" ,
			"forward_lance_right_end"
		};
		const float Start_Thickness = 30.0;

		float Origin[3]; GetAbsOrigin(npc.index, Origin);

		float BeamSpeed = fl_PrimaryLancesTravelSpeed * 0.1515;
		float TurnSpeed = fl_PrimaryLancesTurnSpeed;

		float TargetLoc[3]; WorldSpaceCenter(npc.m_iTarget, TargetLoc);
		
		VectorTurnData Data;
		Data.Origin			= f3_LastValidPosition[npc.index];
		Data.TargetVec 		= TargetLoc;
		Data.CurrentAngles 	= fl_AbilityVectorData_2[npc.index];
		Data.PitchSpeed		= TurnSpeed;
		Data.YawSpeed		= TurnSpeed;
		fl_AbilityVectorData_2[npc.index] = TurnVectorTowardsGoal(Data);

		Get_Fake_Forward_Vec(BeamSpeed, fl_AbilityVectorData_2[npc.index], f3_LastValidPosition[npc.index], f3_LastValidPosition[npc.index]);

		WantedLoc = f3_LastValidPosition[npc.index];

		//TE_SetupBeamPoints(Origin, WantedLoc, g_Ruina_BEAM_Laser, 0, 0, 0, 0.1, 60.0, 60.0, 0, 0.25, {0, 0, 255, 255}, 3);
		//TE_SendToAll();

		//float TargetLoc[3];
		//TargetLoc = f3_LastValidPosition[npc.index];

		for(int i = 0 ; i < 2 ; i++)	//left right
		{
			float End[3]; 	End = npc.GetWeaponSections(Sections[i]);

			//float Angles[3]; Angles = fl_AbilityVectorData_2[npc.index];

			//if(!npc.bIsShipFacingLoc(End, WantedLoc, 5.0, 5.0))	//Gimbal lances.
			//	continue;

			float BeamAngles[3];
			MakeVectorFromPoints(End, WantedLoc, BeamAngles);
			GetVectorAngles(BeamAngles, BeamAngles);

			float Dist;
			if(i)
				Dist = npc.m_flLastDist_Two;
			else
				Dist = npc.m_flLastDist_One;

			float FinalLoc[3];
			Get_Fake_Forward_Vec(Dist, BeamAngles, FinalLoc, End);

			DoPrimaryLanceEffects(npc, End, FinalLoc, Start_Thickness);
		}
	}
	else
	{
		Get_Fake_Forward_Vec(fl_PrimaryLancesTravelSpeed * 5.0 * fl_PrimaryLanceDuration_Base + 100.0, fl_AbilityVectorData_2[npc.index], WantedLoc, f3_LastValidPosition[npc.index]);
	}
	
	
	float Angles[3];
	VectorTurnData Data;
	Angles = npc.RotateShipModelTowards(WantedLoc, Data, 1.0);

	Angles[2] = -1.0 * Data.YawRotateLeft;
		
	float RotationClamp = fl_ShipRollClamps;

	//clamp ship rotational angles
	if(Angles[2] > RotationClamp)
		Angles[2] = RotationClamp;
	else if(Angles[2] < -RotationClamp)
		Angles[2] = -RotationClamp;

	npc.RotateShipModel(Angles);

}
static int i_Get_Laser_Target(RegaliaClass npc)
{
	UnderTides npcGetInfo = view_as<UnderTides>(npc.index);
	int enemy_2[MAXPLAYERS];
	GetHighDefTargets(npcGetInfo, enemy_2, sizeof(enemy_2), false, false);
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
	return Tmp_Target;
}
static float Target_Angle_Value(RegaliaClass npc, int Target)
{
	// need position of either the inflictor or the attacker
	float Vic_Pos[3];
	WorldSpaceCenter(Target, Vic_Pos);
	float npc_pos[3];
	float angle[3];
	float eyeAngles[3];
	npc_pos = f3_LastValidPosition[npc.index];
	eyeAngles = fl_AbilityVectorData_2[npc.index];
	
	GetVectorAnglesTwoPoints(npc_pos, Vic_Pos, angle);

	// need the yaw offset from the player's POV, and set it up to be between (-180.0..180.0)
	float yawOffset = fixAngle(angle[1]) - fixAngle(eyeAngles[1]);
	if (yawOffset <= -180.0)
		yawOffset += 360.0;
	else if (yawOffset > 180.0)
		yawOffset -= 360.0;

	//if its more then 180, its on the other side of the npc / behind
	return fabs(yawOffset);
}
static void DoPrimaryLanceEffects(RegaliaClass npc, float EndLoc[3], float flPos[3], float diameter)
{
	float TE_Duration = 0.1;

	int style = GetEntProp(npc.index, Prop_Data, "m_nSkin");

	if(style == 3)
		style = 0;
	else if(style == 4)
		style = 1;


	int color[4] = {200, 200, 200, 170};

	color[1] = GetRandomInt(80, 255);
	color[3] = 100;

	if (style == 1)
	{
		color[0] = GetRandomInt(50, 175);
		color[2] = GetRandomInt(200, 255);
	}
	else
	{
		color[0] = GetRandomInt(200, 255);
		color[2] = GetRandomInt(50, 175);

	}

	float Start_Diameter1 = diameter*0.8;
	float End_Diameter = diameter * 0.5;

	const int Speed_Body = 15;
	const int Speed_Glow = 15;

	const int FrameRate = 9;
	const int StartFrame = 0;
	const int FadeLength = 33;

	TE_SetupBeamPoints(flPos, EndLoc, HYDRAGUT_Beam, 0, StartFrame, FrameRate, TE_Duration, Start_Diameter1, End_Diameter, FadeLength, 1.0, color, Speed_Body);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(flPos, EndLoc, HYDRAGUTCAP_Beam, 0, StartFrame, FrameRate, TE_Duration, Start_Diameter1, End_Diameter, FadeLength, 1.0, color, Speed_Body);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(flPos, EndLoc, iGetTeamBeamIndex((style == 1 ? 3 : 2)), 0, StartFrame, FrameRate, TE_Duration, 0.0, End_Diameter, FadeLength, 1.0, {255, 255, 255, 255}, Speed_Body);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(flPos, EndLoc, g_Ruina_BEAM_Glow, 0, StartFrame, FrameRate, TE_Duration, 0.0, ClampBeamWidth(diameter * 1.28), FadeLength, 1.2, color, Speed_Glow);
	TE_SendToAll(0.0);
}
static void HandleMainWeapons(RegaliaClass npc)
{
	float GameTime = GetGameTime(npc.index);
	if(!npc.bDoesSectionExist(StarShip_BG_ForwardLance))
	{
		if(npc.m_bPrimaryLancesActive)
		{
			npc.EndFlightSystemGoal(); 
			npc.EndGenericLaserSound();
			npc.m_flLanceDuration = 0.0;
			npc.m_flShipAbilityActive = GameTime + 1.0;
			npc.m_bPrimaryLancesActive = false;
		}
		return;
	}

	if(npc.m_flShipAbilityActive > GameTime && !npc.m_bPrimaryLancesActive)
		return;

	if(npc.m_flLanceRecharge == FAR_FUTURE && npc.m_flLanceDuration < GameTime)
	{
		npc.EndFlightSystemGoal(); 
		npc.EndGenericLaserSound();
		npc.m_flLanceRecharge = GameTime + fl_PrimaryLanceRecharge_Base;
		npc.m_bPrimaryLancesActive = false;

	}

	if(npc.m_flLanceRecharge > GameTime && npc.m_flLanceDuration < GameTime)
		return;

	if(npc.m_flLanceRecharge < GameTime)
	{
		if(!bInitialiseMainLances(npc))
		{
			npc.m_flLanceRecharge = GameTime + 5.0;
			npc.m_flLanceDuration = 0.0;
			return;
		}
		else
		{
			npc.m_bPrimaryLancesActive = true;
			npc.m_flLanceRecharge = GameTime + fl_PrimaryLanceRecharge_Base;

			npc.m_flShipAbilityActive = FAR_FUTURE;
			npc.m_flLanceDuration = FAR_FUTURE;

			float GoalVec[3]; GoalVec = f3_LastValidPosition[npc.index];
			float WantedLoc[3];

			//semi temp system.
			float Angles[3]; Angles = fl_AbilityVectorData_2[npc.index];
			Angles[1] += GetRandomInt(0, 1) == 0 ? 90.0 : -90.0;
			Angles[0] = -30.0;
			Ruina_Laser_Logic Laser;
			Laser.client = npc.index;
			Laser.DoForwardTrace_Custom(Angles, GoalVec, fl_primaryLanceDistanceRegulation + 300.0);

			Get_Fake_Forward_Vec(-300.0, Angles, WantedLoc, Laser.End_Point);

			//TE_SetupBeamPoints(GoalVec, WantedLoc, g_Ruina_BEAM_Laser, 0, 0, 0, 10.0, 60.0, 60.0, 0, 0.25, {255, 255, 255, 255}, 3);
			//TE_SendToAll();

			npc.SetFlightSystemGoal(WantedLoc, LanceeWeaponTurnControl);
			npc.m_bVectoredThrust = true;
		}
	}

	if(npc.m_flLanceDuration == FAR_FUTURE && npc.m_flShipAbilityActive > GameTime)
	{
		float Origin[3]; GetAbsOrigin(npc.index, Origin);
		
		npc.m_flLanceRecharge = GameTime + fl_PrimaryLanceRecharge_Base;
		npc.m_flShipAbilityActive = GameTime + 5.0;
		if(npc.m_bVectoredThrust_InUse)
		{
			float WantedLoc[3];
			Get_Fake_Forward_Vec(fl_PrimaryLancesTravelSpeed * 5.0 * fl_PrimaryLanceDuration_Base + 100.0, fl_AbilityVectorData_2[npc.index], WantedLoc, f3_LastValidPosition[npc.index]);

			//TE_SetupBeamPoints(Origin, WantedLoc, g_Ruina_BEAM_Laser, 0, 0, 0, 0.1, 60.0, 60.0, 0, 0.25, {0, 255, 0, 255}, 3);
			//TE_SendToAll();

			if(npc.bIsShipFacingLoc(Origin, WantedLoc, 5.0, 5.0))
			{

				float BeamAngles[3];
				MakeVectorFromPoints(WantedLoc, f3_LastValidPosition[npc.index], BeamAngles);
				GetVectorAngles(BeamAngles, BeamAngles);
				fl_AbilityVectorData_2[npc.index] = BeamAngles;
				f3_LastValidPosition[npc.index] = WantedLoc;
				npc.m_bCutThrust = true;
				npc.m_flLanceDuration = GameTime + fl_PrimaryLanceDuration_Base;
				npc.m_flShipAbilityActive = GameTime + fl_PrimaryLanceDuration_Base + 1.0;
				npc.m_flLanceRecharge = FAR_FUTURE;

				
			}
		}
		//else
		//{
		//	float WantedLoc[3];
		//	Get_Fake_Forward_Vec(fl_PrimaryLancesTravelSpeed * 5.0 * fl_PrimaryLanceDuration_Base + 100.0, fl_AbilityVectorData_2[npc.index], WantedLoc, f3_LastValidPosition[npc.index]);
		//	TE_SetupBeamPoints(Origin, WantedLoc, g_Ruina_BEAM_Laser, 0, 0, 0, 0.1, 60.0, 60.0, 0, 0.25, {0, 0, 255, 255}, 3);
		//	TE_SendToAll();
		//}
		return;
	}

	if(npc.m_flLanceDuration < GameTime)
		return;

	static const char Sections[][] = {
		"forward_lance_left_end" ,
		"forward_lance_right_end"
	};
	
	float TargetLoc[3];

	TargetLoc = f3_LastValidPosition[npc.index];

	npc.EmitGenerciLaserSound();

	const float Start_Thickness = 30.0;

	Ruina_Laser_Logic Laser;
	Laser.client 		= npc.index;
	Laser.Radius 		= Start_Thickness * 0.5;
	Laser.Damage		= ModifyDamage(50.0);
	Laser.Bonus_Damage 	= ModifyDamage(10.0);
	Laser.damagetype 	= DMG_PLASMA;

	//float ShipAngles[3]; ShipAngles = npc.GetAngles();

	float Origin[3]; GetAbsOrigin(npc.index, Origin);

	//TE_SetupBeamPoints(Origin, TargetLoc, g_Ruina_BEAM_Laser, 0, 0, 0, 1.0, 60.0, 60.0, 0, 0.25, {255, 0, 0, 255}, 3);
	//TE_SendToAll();

	for(int i = 0 ; i < 2 ; i++)	//left right
	{
		float End[3]; 	End = npc.GetWeaponSections(Sections[i]);

		//if(!npc.bIsShipFacingLoc(End, TargetLoc, 10.0, 10.0))	//Gimbal lances.
		//	continue;

		float BeamAngles[3];
		MakeVectorFromPoints(End, TargetLoc, BeamAngles);
		GetVectorAngles(BeamAngles, BeamAngles);

		Laser.DoForwardTrace_Custom(BeamAngles, End, -1.0);
		Laser.Deal_Damage();

		DoPrimaryLanceEffects(npc, End, Laser.End_Point, Start_Thickness);

		DataPack pack = new DataPack();
		pack.WriteFloat(Laser.End_Point[0]);
		pack.WriteFloat(Laser.End_Point[1]);
		pack.WriteFloat(Laser.End_Point[2]);
		pack.WriteCell(1);
		RequestFrame(MakeExplosionFrameLater, pack);

		if(i)
			npc.m_flLastDist_Two = GetVectorDistance(End, Laser.End_Point);
		else
			npc.m_flLastDist_One = GetVectorDistance(End, Laser.End_Point);
	}
}
static bool bInitialiseMainLances(RegaliaClass npc)
{
	float radius = fl_PrimaryLanceDetectionSize;
	int amt = 4;

	float Loc[3];
	Loc = vGetBestAverageWithinRadius(npc, radius, amt);
	
	if(amt == -1)
		return false;

	//float Thickness = 60.0;
	//TE_SetupBeamRingPoint(Loc, radius*2.0, radius*2.0 - 1.0, g_Ruina_BEAM_Laser, 0, 0, 1, 10.0, Thickness, 0.75, {255, 0, 0, 255}, 1, 0);
	//TE_SendToAll();
	
	Loc[2]+=25.0;
	f3_LastValidPosition[npc.index] = Loc;
	fl_AbilityVectorData_2[npc.index] = vGetBestAngles(npc, Loc, fl_PrimaryLancesTravelSpeed * 5.0 * fl_PrimaryLanceDuration_Base + 100.0, fl_PrimaryLanceTravelDetectionSize, 1.0, amt);

	return true;
}
static float[] vGetBestAngles(RegaliaClass npc, float Center[3], float Dist, float radius, float angle_adjust = 1.0, int expected = 0)
{
	float Angle_Val = 0.0;
	bool stop = false;

	int BestCount = 0;
	float BestAngles[3];

	Ruina_Laser_Logic Laser;
	Laser.client = npc.index;
	Laser.Radius = radius;

	//do a 180 circle trace thing.
	//get from what line we get the highest chance of hitting targets.

	bool faster = false;

	while(!stop)
	{
		if(Angle_Val > 180.0)
		{
			stop = true;
			break;
		}
		Angle_Val +=faster ? angle_adjust * 3.0 : angle_adjust;
		float Angles[3]; Angles[1] = Angle_Val;
		Get_Fake_Forward_Vec(-Dist, Angles, Laser.Start_Point, Center);
		Get_Fake_Forward_Vec(Dist, Angles, Laser.End_Point, Center);

		int count = 0;

		Laser.Enumerate_Simple();
		//get victims from the "Enumerate_Simple"
		for (int loop = 0; loop < sizeof(i_Ruina_Laser_BEAM_HitDetected); loop++)
		{
			int victim = i_Ruina_Laser_BEAM_HitDetected[loop];
			if(!victim)
				break;

			count++;
		}
		
		//if we happen to find a perfect line where we get all or more of our "counted" targets, we most likely found the best angle, however to make 300% sure we will do all the other calcs. but we will make the angle adjustment far higher. that way its less total calculations.
		if(expected > 0 && count >= expected)
		{
			faster = true;
		}
		if(count > BestCount)
		{
			BestCount = count;
			BestAngles = Angles;
		}
	}

	return BestAngles;
}
static void Get_Fake_Forward_Vec(float Range, float vecAngles[3], float Vec_Target[3], float Pos[3])
{
	float Direction[3];
	
	GetAngleVectors(vecAngles, Direction, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(Direction, Range);
	AddVectors(Pos, Direction, Vec_Target);
}
/*
	@param npc 			//for referencing what to track
	@param radius 		//how big of a radius is the checking. lower = more harsh and less likely to find a good spot. higher = more leniant, meaning better chance of fiding a vector, but the players will be more spread out
	@param player_amt	//how many players within radius. if you make input 0 it will simply return amt. if you set a value above 0 it will only return a valid vector if it finds this many players inside radius.
*/
stock float[] vGetBestAverageWithinRadius(CClotBody npc, float radius, int &player_amt)
{
	int amt;

	int ValidEnts[100];	//save all our aquired targets.

	Zero(ValidEnts);

	int team = GetTeam(npc.index);

	for(int clients = 1 ; clients <= MaxClients ; clients++)
	{
		if(!IsValidClient(clients))
			continue;

		if(GetClientTeam(clients) != 2)
			continue;

		if(TeutonType[clients] != TEUTON_NONE)
			continue;

		if(view_as<CClotBody>(clients).m_bThisEntityIgnored)
			continue;
		
		ValidEnts[amt] = clients;
		amt++;
	}

	for(int targ; targ< i_MaxcountNpcTotal; targ++)
	{
		int baseboss_index = EntRefToEntIndexFast(i_ObjectsNpcsTotal[targ]);
		if(!IsValidEntity(baseboss_index))
			continue;

		if(b_NpcHasDied[baseboss_index])
			continue;

		if(team == GetTeam(baseboss_index))
			continue;
		
		if(view_as<CClotBody>(baseboss_index).m_bThisEntityIgnored)
			continue;

		if(b_NpcIsInvulnerable[baseboss_index])
			continue;
		
		if(b_ThisEntityIgnoredByOtherNpcsAggro[baseboss_index])
			continue;

		ValidEnts[amt] = baseboss_index;
		amt++;
	}

	float averageVec[3];
	averageVec = vGetAvgFromArrayOfEnts(ValidEnts, amt);

	//we now have the true average of all enemy players/enemies.

	radius *=radius;	//square it

	int failsafe = 0;

	while(failsafe < 100)
	{
		failsafe++;

		float DistFromCore[100];
		float AvgDist = 0.0;
		float LargestRadius = 0.0;

		//get distances
		for(int i=0 ; i < amt ; i++)
		{
			int ent = ValidEnts[i];
			float vec[3]; GetAbsOrigin(ent, vec);
			DistFromCore[i] = GetVectorDistance(vec, averageVec, true);	//do everything squared to make it less performance heavy.
			AvgDist += DistFromCore[i];

			if(LargestRadius < DistFromCore[i])
				LargestRadius = DistFromCore[i];
		}

		//so the checked location's largest radius is within our wanted radius value, AND it has our wanted target amout. sooo we found a valid location.
		//ship it!
		if(LargestRadius <= radius && (player_amt == 0 || amt >=player_amt))
		{
			//CPrintToChatAll("EARLY RETURN");
			player_amt = amt;
			return averageVec;
		}

		//float Thickness = 6.0;
		//TE_SetupBeamRingPoint(averageVec, SquareRoot(LargestRadius)*2.0, SquareRoot(LargestRadius)*2.0 - 1.0, g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, 2.0, Thickness, 0.75, {255, 255, 255, 255}, 1, 0);
		//TE_SendToAll();
		

		AvgDist /=amt;

		//CPrintToChatAll("%iamt:             %i", failsafe, amt);
		//CPrintToChatAll("%iAvgDist:         %.3f", failsafe, SquareRoot(AvgDist));
		//CPrintToChatAll("%iLargestRadius:   %.3f", failsafe, SquareRoot(LargestRadius));

		int new_amt = 0;
		int newValidEnts[100];

		//now nuke everthing beyond avg dist.

		for(int i=0 ; i < amt ; i++)
		{
			//CPrintToChatAll("%i-%iDistFromCore: %.3f", failsafe, i, SquareRoot(DistFromCore[i]));
			if(AvgDist >= DistFromCore[i])
			{
				//CPrintToChatAll("%i-%iNewEntAdded:  %i", failsafe, i, ValidEnts[i]);
				newValidEnts[new_amt] = ValidEnts[i];
				new_amt++;
			}
		}

		//Now clean everything and prepare for new loop!
		Zero(ValidEnts);

		for(int i=0 ; i < new_amt ; i++)
		{
			ValidEnts[i] = newValidEnts[i];
		}
		amt = new_amt;

		//CPrintToChatAll("%inew_amt:       %i", failsafe, new_amt);

		averageVec = vGetAvgFromArrayOfEnts(ValidEnts, amt);
		
	}
	player_amt = -1;
	return NULL_VECTOR;
}
static float[] vGetAvgFromArrayOfEnts(int Array[100], int amt)
{
	float averageVec[3];
	for(int i=0 ; i < amt ; i++)
	{
		float vec[3]; GetAbsOrigin(Array[i], vec);
		AddVectors(averageVec, vec, averageVec);
	}
	averageVec[0] /= amt;
	averageVec[1] /= amt;
	averageVec[2] /= amt;
	return averageVec;

}
static Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	RegaliaClass npc = view_as<RegaliaClass>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;

	if(IsValidClient(attacker))
	{
		fl_player_weapon_score[attacker]+=damage;
	}

	if(npc.m_flArmorCount > 0.0)
	{
		npc.m_fbRangedSpecialOn = false;
		npc.EmitShieldSound();
	}
	else if(!npc.m_fbRangedSpecialOn)
	{
		npc.m_fbRangedSpecialOn = true;
		npc.EmitShieldBreakSound();
	}
	else
	{
		npc.PlayHurtSound();
	}

	if(npc.m_iHealthBar <= 0 && !npc.Anger)
	{
		if(bShipRaidModeScaling)
			RaidModeScaling *= 1.1;
		npc.Anger = true;
		npc.PlayLifeLossSound();
		ApplyStatusEffect(npc.index, npc.index, "Ancient Melodies", FAR_FUTURE);
	//	CommLines("", "M I S T E R  B E A S T");
	
		Waves_ClearWave();
		Waves_Progress(_,_, true);
		//go to next wave instantly
	}

	return Plugin_Continue;
}
static void NPC_Death(int iNPC)
{
	RegaliaClass npc = view_as<RegaliaClass>(iNPC);

	StopSound(npc.index, SNDCHAN_VOICE, REGALIA_IOC_CHARGE_LOOP);
	npc.EndGenericLaserSound();

	EmitSoundToAll(REGALIA_DEATH_EXPLOSION_SOUND, npc.index, SNDCHAN_VOICE, SNDLEVEL_RAIDSIREN, _, 1.0, 175);
	EmitSoundToAll(REGALIA_DEATH_EXPLOSION_SOUND, npc.index, SNDCHAN_VOICE, SNDLEVEL_RAIDSIREN, _, 1.0, 150);
	EmitSoundToAll(REGALIA_DEATH_EXPLOSION_SOUND, npc.index, SNDCHAN_VOICE, SNDLEVEL_RAIDSIREN, _, 1.0, 125);
	EmitSoundToAll(REGALIA_DEATH_EXPLOSION_SOUND, npc.index, SNDCHAN_VOICE, SNDLEVEL_RAIDSIREN, _, 1.0, 100);
	EmitSoundToAll(REGALIA_DEATH_EXPLOSION_SOUND, npc.index, SNDCHAN_VOICE, SNDLEVEL_RAIDSIREN, _, 1.0, 75);

	float Loc[3]; GetAbsOrigin(npc.index, Loc);
	int particle = ParticleEffectAt(Loc, "hammer_bell_ring_shockwave2", 1.0);

	if(IsValidEntity(particle))
		CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);

	npc.CleanEntities();
}
static int[] iRegaliaColor(RegaliaClass npc)
{
	int skin = GetEntProp(npc.index, Prop_Data, "m_nSkin");

	int color[4];

	switch(skin)
	{
		case 0: color = {255, 200, 75, 255};
		case 1: color = {0, 255, 255, 255};
		default:color = {255, 255, 255, 255};
	}
	return color;
}
static void Do_RaidModeScaling(const char[] data)
{
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
}

//static float Get2DVectorLength(float Vec1[3], bool not_squared = false)
//{
//	float x = Vec1[0]*Vec1[0];
//	float y = Vec1[1]*Vec1[1];
//	return not_squared ? x+y : SquareRoot(x+y);
//}
static float Get2DVectorDistances(float Vec1[3], float Vec2[3], bool not_squared = false)
{
	float x = Vec2[0] - Vec1[0];
	float y = Vec2[1] - Vec1[1];

	x = x * x;
	y = y * y;

	return not_squared ? x+y : SquareRoot(x+y);
}