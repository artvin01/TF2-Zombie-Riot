#pragma semicolon 1
#pragma newdecls required

#define STARSHIP_MODEL			"models/zombie_riot/starship_5.mdl"

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

	Passive:

		Constructor:
			-Ship becomes stationary.
			-4 Beacons spawn. (has a construction phase. like 5 seconds?)
			-create beams from weapon ports to beacon pos.
			-Once beacons are constructed. ship goes to normal behavior.

			-Can only create beacons up to a total of 4.
				so if there are 2 alive, and ship decides to build more, it will only build 2 more to reach the total of 4.

	Beacons:

		Basic Functionality:
			- Beacons have 5% of ship hp.
			- When beacon is damage, 25%(?) of damage taken is transfered to ship

		Beacon Shield Phase:
			Every X seconds the beacons gain a shield (armour) if you don't destroy the armour of all beacons. the ship gains a massive shield (armour)

		Passive:
			While beacon is active, a orbital beam is active. acts like stella's orbital ray. should make the system independant.

	Flight isssues:
	

		When going over a target ship rotation get wonky.


	Notes:

		Seperate various parts of flight system into seperate functions:
			Turning.
			Velocity.
			Destination.
*/

static const char g_ShieldDamageSound[][] = {
	"physics/glass/glass_impact_bullet1.wav",
	"physics/glass/glass_impact_bullet2.wav",
	"physics/glass/glass_impact_bullet3.wav"
};
#define REGALIA_IOC_EXPLOSION_SOUND		"misc/halloween/spell_mirv_explode_primary.wav"

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
//todo: get vector points:
/*
	Center of arena.
	Corners of arena top, bottom, etc.
*/
static const float VaultVectorPoints[][3] = {
	{0.0, 0.0, 0.0},
	{0.0, 0.0, 0.0}
};

static Function func_ShipTurn[MAXENTITIES];
void StarShip_Regalia_OnMapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "HMS: Regalia");	//Regalia Class battlecruisers
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_starship_regalia");
	strcopy(data.Icon, sizeof(data.Icon), "soldier");
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
	PrecacheSound(REGALIA_IOC_EXPLOSION_SOUND);
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return RegaliaClass(vecPos, vecAng, team, data);
}
methodmap RegaliaClass < CClotBody
{
	public void EmitShieldSound()
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + GetRandomFloat(0.15, 0.3);

		int pitch = GetRandomInt(40, 70);
		EmitSoundToAll(g_ShieldDamageSound[GetRandomInt(0, sizeof(g_ShieldDamageSound) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, 0.25, pitch);
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
	property float m_flRevertControlOverride
	{
		public get()							{ return i_ClosestAllyCDTarget[this.index]; }
		public set(float TempValueForProperty) 	{ i_ClosestAllyCDTarget[this.index] = TempValueForProperty; }
	}
	public RegaliaClass(float vecPos[3], float vecAng[3], int team, const char[] data)
	{
		RegaliaClass npc = view_as<RegaliaClass>(CClotBody(vecPos, vecAng, STARSHIP_MODEL, "1.0", "1000", team, .CustomThreeDimensions = {1000.0, 1000.0, 200.0}, .CustomThreeDimensionsextra = {-1000.0, -1000.0, -200.0}));
		
		i_NpcWeight[npc.index] = 999;

		npc.CleanEntities();
		
		SetEntityRenderMode(npc.index, RENDER_NORMAL);
		SetEntityRenderColor(npc.index, 255, 255, 255, 255);

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");

		if(StrContains(data, "raid_hud") != -1)
		{
			RaidBossActive = EntIndexToEntRef(npc.index);
		}
		
		npc.CreateBody();
		npc.ShieldState(false);
		
		npc.m_iBleedType 			= BLEEDTYPE_METAL;
		//npc.m_iStepNoiseType 		= STEPSOUND_NORMAL;	
		//npc.m_iNpcStepVariation 	= STEPTYPE_NORMAL;

		func_NPCDeath[npc.index]			= NPC_Death;
		func_NPCOnTakeDamage[npc.index] 	= OnTakeDamage;
		func_NPCThink[npc.index] 			= ClotThink;
		func_ShipTurn[npc.index]			= INVALID_FUNCTION;

		fl_ShipTurnSpeed = 0.5;

		fl_ShipAcceleration = 1.2;
		fl_ShipDeceleration	= 0.8;
		fl_ShipHyperDecelerationNearDist = 500.0;
		fl_ShipHyperDecelerationSpeed = 5.0;
		fl_ShipHyperDecelerationMax = 0.5;

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
		int skin = 1;	//1=blue, 0=red
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		float Angles[3];
		GetEntPropVector(npc.index, Prop_Data, "m_angRotation", Angles);
		int iPitch = npc.LookupPoseParameter("body_pitch");
		float flPitch = npc.GetPoseParameter(iPitch);
		flPitch *= -1.0;
		Angles[0] = flPitch;

		fl_AbilityVectorData[npc.index] = Angles;

		//Weapons System.
		npc.m_flLanceRecharge = GetRandomFloat(1.0, 3.0) + GetGameTime();
		npc.m_flLanceDuration = 0.0;
		npc.m_bPrimaryLancesActive = false;

		npc.m_flDroneSpawnNext= GetRandomFloat(1.0, 3.0) + GetGameTime();
		npc.m_flUnderSlung_Type0_Recharge = GetRandomFloat(1.0, 3.0) + GetGameTime();
		npc.m_flUnderSlung_PrimaryRecharge = 0.0;


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
		//b_ForceCollisionWithProjectile[npc.index]=true;
		npc.m_bDissapearOnDeath 				= true;


		npc.Handle_SectionParticles();
		
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
		if(this.m_flGetClosestTargetTime > GameTime)
			return this.m_iTarget;

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

		return current & group;
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
	public void AddParticleEntity(int entity)
	{
		for(int i=0 ; i < RUINA_MAX_PARTICLE_ENTS; i++)
		{
			if(i_particle_ref_id[this.index][i] == INVALID_ENT_REFERENCE)
			{
				i_particle_ref_id[this.index][i] = EntIndexToEntRef(entity);
				return;
			}
		}
		LogStackTrace("Regalia has run out of particle slots. gg");
	}
	public void AddLaserEntity(int entity)
	{
		for(int i=0 ; i < RUINA_MAX_PARTICLE_ENTS; i++)
		{
			if(i_laser_ref_id[this.index][i] == INVALID_ENT_REFERENCE)
			{
				i_laser_ref_id[this.index][i] = EntIndexToEntRef(entity);
				return;
			}
		}
		LogStackTrace("Regalia has run out of laser slots. gg");
	}
	public void CleanEntities()
	{
		Ruina_Clean_Particles(this.index);
	}
	//Flight System:
	public void SetFlightSystemGoal(float GoalVec[3], Function FuncTurn = INVALID_FUNCTION)
	{
		if(this.m_bShipFlightTowardsActive)
		{
			LogStackTrace("Regalia Attempted to set new pathing logic when we already have a path. this is not supported and might break ship logic. as such aborting");
			return;
		}

		func_ShipTurn[this.index] = FuncTurn;

		this.m_bShipFlightTowardsActive = true;

		f3_NpcSavePos[this.index] = GoalVec;
	}
	public void EndFlightSystemGoal()
	{
		fl_AbilityVectorData[this.index] 	= this.GetAngles();
		this.m_bShipFlightTowardsActive 	= false;
		this.m_bVectoredThrust 				= false;
		this.m_flShipAbilityActive 			= GetGameTime(this.index) + 1.0;
		func_ShipTurn[this.index]			= INVALID_FUNCTION;
	}
	public void HeadingControl()
	{
		b_NoGravity[this.index] = true;

		this.StopPathing();

		if(!IsValidEntity(this.m_iTarget))
			return;

		float GameTime = GetGameTime(this.index);

		//orbiting behavior for future use

		//if(target == -2)
		//{
		//	float Loc[3];
		//	GetAbsOrigin(client, Loc); Loc[2]+=50.0;
		//	for(int y=0 ; y < 2 ; y++)
		//	{
		//		Loc[y] +=GetRandomFloat(-150.0, 150.0);
		//	}
		//	Loc[2] +=GetRandomFloat(0.0, 200.0);
		//	DroneFly_Travel(this.index, Loc, FAR_FUTURE);
		//	return;
		//}

		float DroneLoc[3], TargetLoc[3];
		GetAbsOrigin(this.index, DroneLoc);


		if(this.m_bShipFlightTowardsActive)
		{
			TargetLoc = f3_NpcSavePos[this.index];
		}
		else
		{
			WorldSpaceCenter(this.m_iTarget, TargetLoc);
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

		this.Fly(TargetLoc, Dist, Vectored_Thrust);

		this.m_bVectoredThrust_InUse = Vectored_Thrust;

		if(this.m_flRevertControlOverride < GameTime)
		{
			this.m_flRevertControlOverride 		= FAR_FUTURE;
			func_ShipTurn[this.index] 			= INVALID_FUNCTION;
			fl_AbilityVectorData[this.index] 	= this.GetAngles();
			this.m_bVectoredThrust				= false;
		}

		if(func_ShipTurn[this.index] && func_ShipTurn[this.index] != INVALID_FUNCTION)
		{
			Call_StartFunction(null, func_ShipTurn[this.index]);
			Call_PushCell(this.index);
			Call_Finish();
		}

		/*
		return;

		//target is still far away, go straight for them.
		if(Dist > fl_drone_orbit_range)
		{
			DroneFly_Travel(this.index, TargetLoc, Dist);
			return;
		}
		
		float Angles[3];
		GetRayAngles(DroneLoc, TargetLoc, Angles);

		float TurnRate = fl_ShipTurnSpeed;

		VectorTurnData Data;
		Data.TargetVec 		= Angles;
		Data.CurrentAngles 	= fl_AbilityVectorData[this.index];
		Data.PitchSpeed		= TurnRate;
		Data.YawSpeed		= TurnRate;
		Angles = TurnVectorTowardsGoal(Data);
		fl_AbilityVectorData[this.index] = Angles;

		Angles[2] = -1.0 * Data.YawRotateLeft;

		TeleportEntity(this.index, NULL_VECTOR, Angles, NULL_VECTOR);

		if(this.m_flCurrentSpeed > this.m_flSpeed)
			this.m_flCurrentSpeed -= fl_ShipDeceleration;

		if(this.m_flCurrentSpeed < this.m_flSpeed)
			this.m_flCurrentSpeed = this.m_flSpeed;

		//if(Flight_Computer_V2[this.index].AttackSpeed > GameTime)
		//	return;
		
		if(fabs(Data.YawRotateLeft)> fl_drone_attack_accuracy || fabs(Data.PitchRotateLeft) > fl_drone_attack_accuracy)
			return;

		this.SetVelocity(vecVel);

		*/
	}
	property float m_flTurnSpeed
	{
		public get()							{ return fl_ShipTurnSpeed; 				}
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

		float MaxSpeed = this.m_flSpeed;
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

			if(fabs(TurnRates[i]) > 100.0 && this.m_flCurrentSpeed > this.m_flSpeed*0.5)
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
		
		const float RotationClamp = 50.0;

		//clamp ship rotational angles
		if(Angles[2] > RotationClamp)
			Angles[2] = RotationClamp;
		else if(Angles[2] < -RotationClamp)
			Angles[2] = -RotationClamp;

		if(Vectored_Thrust && this.m_bShipFlightTowardsActive)
		{

			if(Dist < (50.0*50.0))
			{
				this.m_flCurrentSpeed = 0.0;
				this.SetVelocity({0.0, 0.0, 0.0});
				fl_AbilityVectorData[this.index] = this.GetAngles();
				return;
			}
			if(FlySpeed < 10.0)
				FlySpeed = 10.0;

		}

		fVel[0] = fBuf[0]*FlySpeed;
		fVel[1] = fBuf[1]*FlySpeed;
		fVel[2] = fBuf[2]*FlySpeed;

		if(!Vectored_Thrust)
			this.RotateShipModel(Angles);

		this.SetVelocity(fVel);
	}
	public void RotateShipModel(float Angles[3])
	{
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
				if(MaxSpeed == this.m_flSpeed)
					FlySpeed = MaxSpeed;
			}
		}

		//we too fast
		if(FlySpeed > MaxSpeed || DoNotAccel) {
			//we faster the base speed. force set
			if(FlySpeed > this.m_flSpeed) {
				FlySpeed = this.m_flSpeed;
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


		this.Apply_LanceEffects();
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

			this.AddLaserEntity(ConnectWithBeamClient(particle_1, particle_2, color[0], color[1], color[2], start, end, amp, BEAM_DIAMOND));

			this.AddParticleEntity(particle_1);
			this.AddParticleEntity(particle_2);
		}

	
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

	
}
static void HandleUnderSlungWeapons(RegaliaClass npc)
{
	if(!npc.bDoesSectionExist(StarShip_BG_BottomWeps))
		return;

	int type = 0;

	float GameTime = GetGameTime(npc.index);

	if(npc.m_flShipAbilityActive > GameTime || npc.m_flUnderSlung_PrimaryRecharge > GameTime)
		return;

	//CPrintToChatAll("POST npc.m_flShipAbilityActive: %.3f", npc.m_flShipAbilityActive - GameTime);
	
	bool Done = false;
	while(!Done && type <= 4)
	{
		switch(type)
		{
			case 0:
			{
				if(npc.m_flUnderSlung_Type0_Recharge > GameTime)
				{
					type++;
					continue;
				}
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

				const float DetTime = 5.0;
				
				if(amt != -1)
				{
					f3_LastValidPosition[npc.index] 	= Loc;
					npc.m_flUnderSlung_Type0_Recharge 	= GameTime + 15.0;
					npc.m_flUnderSlung_PrimaryRecharge 	= npc.m_flUnderSlung_Type0_Recharge + 5.0;
					npc.m_flShipAbilityActive			= GameTime + DetTime + 1.0;
					npc.m_bVectoredThrust 				= true;
					func_ShipTurn[npc.index] 			= IOC_TurnControl;
					npc.m_flRevertControlOverride		= npc.m_flShipAbilityActive - 1.0;

					Invoke_RegaliaIOC(npc, Loc, DetTime);
				}
				return;
			}
			default:
			{
				if(npc.m_flUnderSlung_PrimaryRecharge < GameTime + 1.0)
					npc.m_flUnderSlung_PrimaryRecharge = GameTime + 1.0;
				return;
			}
		}
		type++;
	}
}
static void IOC_TurnControl(int iNPC)
{
	RegaliaClass npc = view_as<RegaliaClass>(iNPC);

	float WantedLoc[3]; WantedLoc = f3_LastValidPosition[npc.index];

	float Angles[3];
	VectorTurnData Data;
	Angles = npc.RotateShipModelTowards(WantedLoc, Data, 2.0);

	//float OffsetLoc[3]; GetAbsOrigin(npc.index, OffsetLoc);
	//TE_SetupBeamPoints(OffsetLoc, WantedLoc, g_Ruina_BEAM_Laser, 0, 0, 0, 0.1, 50.0, 50.0, 0, 0.1, {255,255,255,255}, 3);
	//TE_SendToAll();

	Angles[2] = -1.0 * Data.YawRotateLeft;
	const float RotationClamp = 50.0;
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
static void Invoke_RegaliaIOC(RegaliaClass npc, float EndLoc[3], const float DetTime)
{
	float dmg = ModifyDamage(100.0);
	const float Radius = 250.0;
	int Color[4] = {255, 255, 255, 255};

	DataPack Pack = new DataPack();
	Pack.WriteCell(EntIndexToEntRef(npc.index));
	Pack.WriteFloatArray(EndLoc, 3);
	Pack.WriteFloat(DetTime + GetGameTime());
	Pack.WriteFloat(dmg);
	Pack.WriteFloat(Radius);
	Pack.WriteFloat(0.0);		//angle modif
	RequestFrames(RegaliaIOC_Tick, 1, Pack);

	const float Thickness = 25.0;

	TE_SetupBeamRingPoint(EndLoc, Radius*2.0, 0.0,			 	g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, DetTime, Thickness, 0.75, Color, 1, 0);
	TE_SendToAll();
	TE_SetupBeamRingPoint(EndLoc, Radius*2.0, Radius*2.0+0.5, 	g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, DetTime, Thickness, 0.1, Color, 1, 0);
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


	AngleModif+=GetRandomFloat(1.0, 2.0);

	if(AngleModif > 360.0)
		AngleModif -= 360.0;

	const float Thickness = 25.0;
	const float TE_Duration = 0.1;
	const float Amp = 0.1;
	int Color[4] = {255, 255, 255, 255};
	const float height =  1500.0;	//1500

	for(int i=0 ; i < Sections ; i++)
	{
		float Angles[3]; Angles[1] = (360.0 / Sections) * float(i) + AngleModif;
		float OffsetLoc[3];
		Get_Fake_Forward_Vec(Radius, Angles, OffsetLoc, EndLoc);

		//CPrintToChatAll("Number: %i", i / 2);

		float SkyLoc[3]; SkyLoc = OffsetLoc; SkyLoc[2]+=height;

		TE_SetupBeamPoints(OffsetLoc, SkyLoc, g_Ruina_BEAM_Laser, 0, 0, 0, TE_Duration, Thickness, Thickness, 0, Amp, Color, 3);
		TE_SendToAll();

		TE_SetupBeamPoints(OffsetLoc, SectionLoc[i / 2], g_Ruina_BEAM_Laser, 0, 0, 0, TE_Duration, Thickness*0.5, Thickness*0.5, 0, Amp, Color, 3);
		TE_SendToAll();
	}

	if(DetTimer < GetGameTime())
	{
		Explode_Logic_Custom(dmg, npc.index, npc.index, -1, EndLoc, Radius,_,0.8, true);

		EmitAmbientSound(REGALIA_IOC_EXPLOSION_SOUND, EndLoc, _, 120, _, _, GetRandomInt(60, 80));
		EmitAmbientSound(REGALIA_IOC_EXPLOSION_SOUND, EndLoc, _, 120, _, _, GetRandomInt(60, 80));

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
			TE_SetupBeamRingPoint(spawnLoc, 0.0, final_radius, g_Ruina_Laser_BEAM, g_Ruina_Laser_BEAM, 0, 1, timer, thicc, 0.1, Color, 1, 0);
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
	int Drone = NPC_CreateByName("npc_lantean_drone_projectile", npc.index, Loc, Angles, GetTeam(npc.index), "blue;");

	int health = 100;
	if(Drone > MaxClients)
	{
		SetEntProp(Drone, Prop_Data, "m_iHealth", health);
		SetEntProp(Drone, Prop_Data, "m_iMaxHealth", health);

		LanteanProjectile drone_npc = view_as<LanteanProjectile>(Drone);
		fl_AbilityVectorData[drone_npc.index] = Angles;

		drone_npc.m_flTimeTillDeath = GetGameTime() + 10.0;
		drone_npc.m_flSpeed = npc.m_flSpeed + 200.0 * GetRandomFloat(0.8, 1.2);
	}
}
static float ModifyDamage(float dmg)
{
	return dmg * RaidModeScaling;
}
static float fl_PrimaryLanceDuration_Base 		= 5.0;
static float fl_PrimaryLanceRecharge_Base 		= 120.0;
static float fl_PrimaryLanceTravelDist			= 800.0;
static float fl_PrimaryLanceTravelDetectionSize = 25.0;
static float fl_PrimaryLanceDetectionSize 		= 600.0;
static void LanceeWeaponTurnControl(int iNPC)
{
	float WantedLoc[3];
	RegaliaClass npc = view_as<RegaliaClass>(iNPC);

	if(!npc.m_bVectoredThrust_InUse)
		return;

	if(npc.m_flLanceDuration != FAR_FUTURE)
	{
		float GameTime = GetGameTime(npc.index);
		float Ratio = 1.0 - 2.0 * ((npc.m_flLanceDuration - GameTime) / fl_PrimaryLanceDuration_Base);
		Get_Fake_Forward_Vec(-fl_PrimaryLanceTravelDist * Ratio, fl_AbilityVectorData_2[npc.index], WantedLoc, f3_LastValidPosition[npc.index]);

		static const char Sections[][] = {
			"forward_lance_left_end" ,
			"forward_lance_right_end"
		};
		int color[4] = {255, 255, 255, 255};
		const float Start_Thickness = 30.0;
		const float End_Thickness = 20.0;
		const float TE_Duration = 0.1;
		const float Amp = 0.1;

		float Origin[3]; GetAbsOrigin(npc.index, Origin);

		//float TargetLoc[3];
		//TargetLoc = f3_LastValidPosition[npc.index];

		for(int i = 0 ; i < 2 ; i++)	//left right
		{
			float End[3]; 	End = npc.GetWeaponSections(Sections[i]);

			float Angles[3]; Angles = fl_AbilityVectorData_2[npc.index];

			//if(!npc.bIsShipFacingLoc(End, WantedLoc, Allowance_Pitch, Allowance_Yaw))	//Gimbal lances.
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

			TE_SetupBeamPoints(End, FinalLoc, g_Ruina_BEAM_Laser, 0, 0, 0, TE_Duration, Start_Thickness, End_Thickness, 0, Amp, color, 3);
			TE_SendToAll();
		}
	}
	else
		WantedLoc = f3_LastValidPosition[npc.index];
	
	
	float Angles[3];
	VectorTurnData Data;
	Angles = npc.RotateShipModelTowards(WantedLoc, Data, npc.m_flLanceRecharge == FAR_FUTURE ? 1.1 : 1.2);

	Angles[2] = -1.0 * Data.YawRotateLeft;
		
	const float RotationClamp = 50.0;

	//clamp ship rotational angles
	if(Angles[2] > RotationClamp)
		Angles[2] = RotationClamp;
	else if(Angles[2] < -RotationClamp)
		Angles[2] = -RotationClamp;

	npc.RotateShipModel(Angles);

}
static void HandleMainWeapons(RegaliaClass npc)
{
	float GameTime = GetGameTime(npc.index);
	if(!npc.bDoesSectionExist(StarShip_BG_ForwardLance))
	{
		if(npc.m_flLanceDuration == FAR_FUTURE && npc.m_flShipAbilityActive > GameTime)
		{
			npc.m_flLanceDuration = 0.0;
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
			Get_Fake_Forward_Vec(fl_PrimaryLanceTravelDist*3.0, Angles, WantedLoc, GoalVec);

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
			//TE_SetupBeamPoints(Origin, f3_LastValidPosition[npc.index], g_Ruina_BEAM_Laser, 0, 0, 0, 0.1, 60.0, 60.0, 0, 0.25, {0, 255, 0, 255}, 3);
			//TE_SendToAll();

			float WantedLoc[3];
			Get_Fake_Forward_Vec(fl_PrimaryLanceTravelDist, fl_AbilityVectorData_2[npc.index], WantedLoc, f3_LastValidPosition[npc.index]);

			if(npc.bIsShipFacingLoc(Origin, WantedLoc, 10.0, 10.0))
			{
				npc.m_flLanceDuration = GameTime + fl_PrimaryLanceDuration_Base;
				npc.m_flShipAbilityActive = GameTime + fl_PrimaryLanceDuration_Base + 1.0;
				npc.m_flLanceRecharge = FAR_FUTURE;
			}
		}
		//else
		//{
		//	TE_SetupBeamPoints(Origin, f3_LastValidPosition[npc.index], g_Ruina_BEAM_Laser, 0, 0, 0, 0.1, 60.0, 60.0, 0, 0.25, {0, 0, 255, 255}, 3);
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

	int color[4] = {255, 255, 255, 255};
	const float Start_Thickness = 30.0;
	const float End_Thickness = 20.0;
	const float TE_Duration = 0.1;
	const float Amp = 0.1;


	Ruina_Laser_Logic Laser;
	Laser.client 		= npc.index;
	Laser.Radius 		= Start_Thickness * 0.5;
	Laser.Damage		= ModifyDamage(50.0);
	Laser.Bonus_Damage 	= ModifyDamage(50.0);
	Laser.damagetype 	= DMG_PLASMA;

	//float ShipAngles[3]; ShipAngles = npc.GetAngles();

	float Origin[3]; GetAbsOrigin(npc.index, Origin);

	//TE_SetupBeamPoints(Origin, TargetLoc, g_Ruina_BEAM_Laser, 0, 0, 0, 1.0, 60.0, 60.0, 0, 0.25, {255, 0, 0, 255}, 3);
	//TE_SendToAll();

	float Ratio = 1.0 - 2.0 * ((npc.m_flLanceDuration - GameTime) / fl_PrimaryLanceDuration_Base);

	float WantedLoc[3];

	float Angles[3]; Angles = fl_AbilityVectorData_2[npc.index];
	Get_Fake_Forward_Vec(-fl_PrimaryLanceTravelDist * Ratio, Angles, WantedLoc, TargetLoc);

	for(int i = 0 ; i < 2 ; i++)	//left right
	{
		float End[3]; 	End = npc.GetWeaponSections(Sections[i]);

		

		//if(!npc.bIsShipFacingLoc(End, WantedLoc, Allowance_Pitch, Allowance_Yaw))	//Gimbal lances.
		//	continue;

		float BeamAngles[3];
		MakeVectorFromPoints(End, WantedLoc, BeamAngles);
		GetVectorAngles(BeamAngles, BeamAngles);

		Laser.DoForwardTrace_Custom(BeamAngles, End, -1.0);
		Laser.Deal_Damage();

		TE_SetupBeamPoints(End, Laser.End_Point, g_Ruina_BEAM_Laser, 0, 0, 0, TE_Duration, Start_Thickness, End_Thickness, 0, Amp, color, 3);
		TE_SendToAll();

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
		
	f3_LastValidPosition[npc.index] = Loc;
	fl_AbilityVectorData_2[npc.index] = vGetBestAngles(npc, Loc, fl_PrimaryLanceTravelDist, fl_PrimaryLanceTravelDetectionSize, 1.0, amt);

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
		Angle_Val +=faster ? angle_adjust * 6.0 : angle_adjust;
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

	if(npc.m_flArmorCount > 0.0)
	{
		npc.EmitShieldSound();
	}

	return Plugin_Continue;
}
static void NPC_Death(int iNPC)
{
	RegaliaClass npc = view_as<RegaliaClass>(iNPC);

	npc.CleanEntities();
}