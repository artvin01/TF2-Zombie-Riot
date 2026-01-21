#pragma semicolon 1
#pragma newdecls required

#define STARSHIP_MODEL			"models/zombie_riot/starship_5.mdl"
#define LANTEAN_NPC_DRONE_MODEL	"models/props_moonbase/moon_gravel_crystal_blue.mdl"//"models/empty.mdl"

static float fl_ShipAcceleration;
static float fl_ShipDeceleration;
static float fl_ShipHyperDecelerationNearDist = 500.0;
static float fl_ShipHyperDecelerationSpeed = 80.0;
static float fl_ShipHyperDecelerationMax = 0.5;
static float fl_ShipTurnSpeed;


static float fl_LanteanDrone_Acceleration;
static float fl_LanteanDrone_Deceleration;
static float fl_LanteanDrone_HyperDecelerationNearDist = 500.0;
static float fl_LanteanDrone_HyperDecelerationSpeed = 80.0;
static float fl_LanteanDrone_HyperDecelerationMax = 0.5;
static float fl_LanteanDrone_TurnSpeed;
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

	NPCData lantean_data;
	strcopy(lantean_data.Name, sizeof(data.Name), "Lantean Drone Projectile");
	strcopy(lantean_data.Plugin, sizeof(data.Plugin), "npc_lantean_drone_projectile");
	//strcopy(lantean_data.Icon, sizeof(data.Icon), "soldier");
	lantean_data.IconCustom = false;
	lantean_data.Flags 		= -1;
	lantean_data.Category 	= Type_Outlaws;
	lantean_data.Func = ClotSummon_Lantean;
	lantean_data.Precache 	= ClotPrecache_Drone;
	NPC_Add(lantean_data);

}
static void ClotPrecache()
{
	PrecacheModel(STARSHIP_MODEL);
	PrecacheSoundArray(g_ShieldDamageSound);
}
static void ClotPrecache_Drone()
{
	PrecacheModel(LANTEAN_NPC_DRONE_MODEL);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return RegaliaClass(vecPos, vecAng, team, data);
}
static any ClotSummon_Lantean(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return LanteanProjectile(client, vecPos, vecAng, team, data);
}

methodmap LanteanProjectile < CClotBody 
{
	property float m_flCurrentSpeed
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; 				}
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flTimeTillDeath
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; 				}
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property int m_iAttacker	//does entref get angry if you try to ent ref the world? no idea.
	{
		public get()							{ return EntRefToEntIndexFast(i_TimesSummoned[this.index]); }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = EntIndexToEntRef(TempValueForProperty); }
	}
	property int m_iPenetrationAmmount
	{
		public get()							{ return this.m_iState; 				}
		public set(int TempValueForProperty) 	{ this.m_iState = TempValueForProperty; }
	}
	property bool m_bUseRaidmodeScaling
	{
		public get()							{ return b_Half_Life_Regen[this.index]; }
		public set(bool TempValueForProperty) 	{ b_Half_Life_Regen[this.index] = TempValueForProperty; }
	}
	public LanteanProjectile(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
	{
		LanteanProjectile npc = view_as<LanteanProjectile>(CClotBody(vecPos, vecAng, LANTEAN_NPC_DRONE_MODEL, "0.75", "1000", team, .CustomThreeDimensions = {25.0, 25.0, 25.0}, .CustomThreeDimensionsextra = {-25.0, -25.0, -25.0}));
		i_NpcWeight[npc.index] = 999;

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");	//uhh

		if(IsValidEntity(npc.m_iWearable1))
			RemoveEntity(npc.m_iWearable1);

		SetEntityRenderMode(npc.index, RENDER_NONE);
		SetEntityRenderColor(npc.index, 0, 0, 0, 0);

		if(GetTeam(client) == team)
			npc.m_iAttacker = client;
		else
			npc.m_iAttacker = npc.index;

		float Origin[3]; GetAbsOrigin(npc.index, Origin);

		if(StrContains(data, "red") != -1)
		{
			npc.m_iWearable1 = ParticleEffectAt_Parent(Origin, "flaregun_energyfield_red", npc.index, "", {0.0,0.0,0.0});
		}
		else if(StrContains(data, "blue") != -1)
		{
			npc.m_iWearable1 = ParticleEffectAt_Parent(Origin, "flaregun_energyfield_blue", npc.index, "", {0.0,0.0,0.0});
		}

		npc.m_bUseRaidmodeScaling = StrContains(data, "raidmodescaling_damage") != -1;

		npc.m_iPenetrationAmmount = 0;

		npc.m_flTimeTillDeath = GetGameTime() + 15.0;	//default value. should be ovewritten by the spawner

		npc.m_iBleedType 					= BLEEDTYPE_PORTAL;

		func_NPCDeath[npc.index]			= LanteanNPC_Death;
		//func_NPCOnTakeDamage[npc.index] 	= LanteanNPC_OnTakeDamage;
		func_NPCThink[npc.index] 			= LanteanNPC_ClotThink;

		float Angles[3];
		GetEntPropVector(npc.index, Prop_Data, "m_angRotation", Angles);
		int iPitch = npc.LookupPoseParameter("body_pitch");
		float flPitch = npc.GetPoseParameter(iPitch);
		flPitch *= -1.0;
		Angles[0] = flPitch;

		fl_AbilityVectorData[npc.index] = Angles;

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

		npc.m_flSpeed = 500.0 + GetRandomFloat(0.0, 100.0);		//MAX SPEED
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StopPathing();	//don't path.

		fl_LanteanDrone_TurnSpeed			 		= 2.0;
		fl_LanteanDrone_Acceleration 				= 25.0;
		fl_LanteanDrone_Deceleration				= 2.5;
		fl_LanteanDrone_HyperDecelerationNearDist 	= 500.0;
		fl_LanteanDrone_HyperDecelerationSpeed 		= 10.0;
		fl_LanteanDrone_HyperDecelerationMax 		= 0.5;

		//detection
		SDKHook(npc.index, SDKHook_Think, 		ProjectileBaseThink);
		//SDKHook(npc.index, SDKHook_ThinkPost, 	ProjectileBaseThinkPost);
		//CBaseCombatCharacter(entity).SetNextThink(GetGameTime());

		WandProjectile_ApplyFunctionToEntity(npc.index, LanteanNPC_SimulateTouch);

		SDKHook(npc.index, SDKHook_StartTouch, Wand_Base_StartTouch);

		return npc;
	}
	//Flight System:
	public void HeadingControl()
	{
		b_NoGravity[this.index] = true;

		this.StopPathing();

		if(!IsValidEntity(this.m_iTarget))
			return;

		float GameTime = GetGameTime(this.index);
		
		float DroneLoc[3], TargetLoc[3];
		GetAbsOrigin(this.index, DroneLoc);
		WorldSpaceCenter(this.m_iTarget, TargetLoc);
		float Dist = GetVectorDistance(DroneLoc, TargetLoc); 

		this.Fly(TargetLoc, Dist);
	}
	property float m_flTurnSpeed
	{
		public get()							{ return fl_LanteanDrone_TurnSpeed; 				}
		public set(float TempValueForProperty) 	{ fl_LanteanDrone_TurnSpeed = TempValueForProperty; }
	}
	property float m_flDecceleration
	{
		public get()							{ return fl_LanteanDrone_Deceleration; 					}
		public set(float TempValueForProperty) 	{ fl_LanteanDrone_Deceleration = TempValueForProperty; 	}
	}
	property float m_flHyperDeccelSpeed
	{
		public get()							{ return fl_LanteanDrone_HyperDecelerationSpeed; 				 }
		public set(float TempValueForProperty) 	{ fl_LanteanDrone_HyperDecelerationSpeed = TempValueForProperty; }
	}
	property float m_flAcceleration
	{
		public get()							{ return fl_LanteanDrone_Acceleration; 					}
		public set(float TempValueForProperty) 	{ fl_LanteanDrone_Acceleration = TempValueForProperty; 	}
	}
	property float m_flHyperDeccelNearDist
	{
		public get()							{ return fl_LanteanDrone_HyperDecelerationNearDist; 				}
		public set(float TempValueForProperty) 	{ fl_LanteanDrone_HyperDecelerationNearDist = TempValueForProperty; }
	}
	property float m_flHyperDeccelMax
	{
		public get()							{ return fl_LanteanDrone_HyperDecelerationMax; 					}
		public set(float TempValueForProperty) 	{ fl_LanteanDrone_HyperDecelerationMax = TempValueForProperty; 	}
	}
	public float[] GetAngles()
	{
		return fl_AbilityVectorData[this.index];
	}
	public void Fly(float Vec[3], float Dist)
	{
		float DroneLoc[3];
		GetAbsOrigin(this.index, DroneLoc);

		float Angles[3];

		float HypeDecell_NearDist 	= this.m_flHyperDeccelNearDist;
		float HypeDecell_Max 		= this.m_flHyperDeccelMax;

		VectorTurnData Data;
		Data.Origin 		= DroneLoc;	//this makes it act form vec to vec rather then from angles to angles.
		Data.TargetVec 		= Vec;
		Data.CurrentAngles 	= this.GetAngles();
		Data.PitchSpeed		= this.m_flTurnSpeed;
		Data.YawSpeed		= this.m_flTurnSpeed;
		Angles = TurnVectorTowardsGoal(Data);
		fl_AbilityVectorData[this.index] = Angles;

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

		fVel[0] = fBuf[0]*FlySpeed;
		fVel[1] = fBuf[1]*FlySpeed;
		fVel[2] = fBuf[2]*FlySpeed;

		const float RotationClamp = 50.0;

		//clamp ship rotational angles
		if(Angles[2] > RotationClamp)
			Angles[2] = RotationClamp;
		else if(Angles[2] < -RotationClamp)
			Angles[2] = -RotationClamp;

		SDKCall_SetLocalAngles(this.index, Angles);
		this.SetVelocity(fVel);
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

		this.m_flCurrentSpeed = FlySpeed;

		return FlySpeed;
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
}
static void LanteanNPC_SimulateTouch(int iNPC, int target)
{
	LanteanProjectile npc = view_as<LanteanProjectile>(iNPC);

	int max_pen = 5;
	bool should_delete = false;
	bool allow_noclip = true;		//issue: currently if spawned near or at ground it breaks.

	if(npc.m_iPenetrationAmmount > max_pen)
		should_delete = true;
	if(target == 0 && !allow_noclip)
		should_delete = true;

	if(should_delete)
	{
		DeleteLanteanProjectile(npc.index);
		return;
	}

	if(target <= 0)
		return;
	if(IsIn_HitDetectionCooldown(npc.index, target))
		return;

	Set_HitDetectionCooldown(npc.index, target, GetGameTime() + 1.0);
	npc.m_iPenetrationAmmount++;
	float damage = 25.0 * (npc.m_bUseRaidmodeScaling ? RaidModeScaling : 10.0);
	int attacker = npc.m_iAttacker;
	if(!IsValidEntity(attacker))
		attacker = npc.index;
	float Origin[3]; GetAbsOrigin(npc.index, Origin);
	SDKHooks_TakeDamage(target, attacker, attacker, damage, DMG_PLASMA, _, _, Origin);
}
static void DeleteLanteanProjectile(int iNPC)
{
	LanteanProjectile npc = view_as<LanteanProjectile>(iNPC);

	func_NPCThink[npc.index] = INVALID_FUNCTION;
	b_NpcUnableToDie[npc.index] = false;

	RequestFrame(KillNpc, EntIndexToEntRef(npc.index));

	SDKUnhook(npc.index, SDKHook_Think, 		ProjectileBaseThink);
	SDKUnhook(npc.index, SDKHook_StartTouch, 	Wand_Base_StartTouch);
}
static void LanteanNPC_ClotThink(int iNPC)
{
	LanteanProjectile npc = view_as<LanteanProjectile>(iNPC);

	float GameTime = GetGameTime(npc.index);

	if(npc.m_flNextDelayTime > GameTime)
		return;

	npc.m_flNextDelayTime = GameTime + DEFAULT_UPDATE_DELAY_FLOAT;

	//should not be affectable by slowdowns
	if(npc.m_flTimeTillDeath < GetGameTime())
	{
		DeleteLanteanProjectile(npc.index);
		return;
	}
	npc.HeadingControl();
	
	npc.Update();

	if(npc.m_flNextThinkTime > GameTime)
		return;
	
	npc.m_flNextThinkTime = GameTime + 0.1;

	npc.m_iTarget = npc.iGetTarget();

	if(!IsValidEntity(npc.m_iTarget))
		return;

	//core of npc logic above should now be complete. now onto the specialist stuff.
}
static void LanteanNPC_Death(int iNPC)
{
	LanteanProjectile npc = view_as<LanteanProjectile>(iNPC);

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

	SDKUnhook(npc.index, SDKHook_Think, 		ProjectileBaseThink);
	SDKUnhook(npc.index, SDKHook_StartTouch, 	Wand_Base_StartTouch);
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
	public RegaliaClass(float vecPos[3], float vecAng[3], int team, const char[] data)
	{
		RegaliaClass npc = view_as<RegaliaClass>(CClotBody(vecPos, vecAng, STARSHIP_MODEL, "1.0", "1000", team, .CustomThreeDimensions = {1000.0, 1000.0, 200.0}, .CustomThreeDimensionsextra = {-1000.0, -1000.0, -200.0}));
		
		i_NpcWeight[npc.index] = 999;

		npc.CleanEntities();
		
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

		fl_ShipTurnSpeed = 1.0;

		fl_ShipAcceleration = 10.0;
		fl_ShipDeceleration	= 2.5;
		fl_ShipHyperDecelerationNearDist = 500.0;
		fl_ShipHyperDecelerationSpeed = 10.0;
		fl_ShipHyperDecelerationMax = 0.5;

		npc.m_flSpeed = 500.0;		//MAX SPEED
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StopPathing();	//don't path.
		
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

		npc.m_flDroneSpawnNext= GetRandomFloat(1.0, 3.0) + GetGameTime();


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
		if(IsVecEmpty(ComparePos))
			GetAbsOrigin(this.index, ComparePos);
		float ShipAngles[3]; ShipAngles = this.GetAngles();
		float Angles[3];
		MakeVectorFromPoints(ComparePos, Loc, Angles);
		GetVectorAngles(Angles, Angles);

		float desiredPitch = Angles[0];
		float desiredYaw   = Angles[1];

		float angleDiff_Yaw 	= this.UTIL_AngleDiff( desiredYaw, 		ShipAngles[1] );	//now get the difference between what we want and what we have as our angles
		float angleDiff_Pitch 	= this.UTIL_AngleDiff( desiredPitch, 	ShipAngles[0] );	//now get the difference between what we want and what we have as our angles

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
		GetAbsOrigin(this.m_iTarget, TargetLoc); //TargetLoc[2]+=250.0;
		float Dist = GetVectorDistance(DroneLoc, TargetLoc); 

		this.Fly(TargetLoc, Dist);

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
	public void Fly(float Vec[3], float Dist)
	{
		float DroneLoc[3];
		GetAbsOrigin(this.index, DroneLoc);

		float Angles[3];

		float HypeDecell_NearDist 	= this.m_flHyperDeccelNearDist;
		float HypeDecell_Max 		= this.m_flHyperDeccelMax;

		VectorTurnData Data;
		Data.Origin 		= DroneLoc;	//this makes it act form vec to vec rather then from angles to angles.
		Data.TargetVec 		= Vec;
		Data.CurrentAngles 	= this.GetAngles();
		Data.PitchSpeed		= this.m_flTurnSpeed;
		Data.YawSpeed		= this.m_flTurnSpeed;
		Angles = TurnVectorTowardsGoal(Data);
		fl_AbilityVectorData[this.index] = Angles;

		float TurnRates[2];
		TurnRates[0] = Data.PitchRotateLeft;
		TurnRates[1] = Data.YawRotateLeft;

		this.m_flPitchLeft 	= Data.PitchRotateLeft;
		this.m_flYawLeft	= Data.YawRotateLeft;

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

		fVel[0] = fBuf[0]*FlySpeed;
		fVel[1] = fBuf[1]*FlySpeed;
		fVel[2] = fBuf[2]*FlySpeed;

		const float RotationClamp = 50.0;

		//clamp ship rotational angles
		if(Angles[2] > RotationClamp)
			Angles[2] = RotationClamp;
		else if(Angles[2] < -RotationClamp)
			Angles[2] = -RotationClamp;

		SDKCall_SetLocalAngles(this.index, Angles);
		this.SetVelocity(fVel);
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

		this.m_flCurrentSpeed = FlySpeed;

		return FlySpeed;
	}
	//public bool bTargetInfront(float TargetLoc[3])
	//{
	//	return false;
	//}


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

	//HandleMainWeapons(npc);
	HandleDroneSystem(npc);

	
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
static void HandleMainWeapons(RegaliaClass npc)
{
	if(!npc.bDoesSectionExist(StarShip_BG_ForwardLance))
		return;

	float GameTime = GetGameTime(npc.index);

	if(npc.m_flLanceRecharge > GameTime && npc.m_flLanceDuration < GameTime)
		return;

	/*        															x		y		z
		$attachment "forward_lance_left_end" 			"weapon_bone" 143.702 -432.962 0.0 rotate 0.0 0.0 0.0
		$attachment "forward_lance_left_start" 			"weapon_bone" 143.702 -314.649 0.0 rotate 0.0 0.0 0.0

		$attachment "forward_lance_right_end" 			"weapon_bone" -143.702 -432.962 0.0 rotate 0.0 0.0 0.0
		$attachment "forward_lance_right_start" 		"weapon_bone" -143.702 -314.649 0.0 rotate 0.0 0.0 0.0

		when translplanting. switch x with z, and then invert x. (which was formerly y before switching)
	*/
	//float Sections[][3] = {
	//	{314.649,  143.702, 0.0},
	//	{432.962,  143.702, 0.0},
	//	{314.649, -143.702, 0.0},
	//	{432.962, -143.702, 0.0}
	//};

	static const char Sections[][] = {
		"forward_lance_left_end" ,
		"forward_lance_right_end"
	};
	
	float TargetLoc[3]; GetAbsOrigin(npc.m_iTarget, TargetLoc); TargetLoc[2]+=50.0;

	float Allowance_Pitch 	= 15.0;
	float Allowance_Yaw 	= 10.0;

	int color[4] = {255, 255, 255, 255};
	float Start_Thickness = 12.0;
	float End_Thickness = 6.0;

	float TE_Duration = 0.15;

	Ruina_Laser_Logic Laser;
	Laser.client = npc.index;

	bool Attacked = false;

	float ShipAngles[3]; ShipAngles = npc.GetAngles();

	for(int i = 0 ; i < 2 ; i++)	//left right
	{
		float End[3]; 	End = npc.GetWeaponSections(Sections[i]);

		if(!npc.bIsShipFacingLoc(End, TargetLoc, Allowance_Pitch, Allowance_Yaw))	//Gimbal lances.
			continue;

		float Angles[3];
		MakeVectorFromPoints(End, TargetLoc, Angles);
		GetVectorAngles(Angles, Angles);

		Laser.DoForwardTrace_Custom(Angles, End, -1.0);

		TE_SetupBeamPoints(End, Laser.End_Point, g_Ruina_BEAM_Laser, 0, 0, 0, TE_Duration, Start_Thickness, End_Thickness, 0, 0.25, color, 3);
		TE_SendToAll();

		Attacked = true;

	}


	if(Attacked && npc.m_flLanceDuration < GameTime)
	{
		npc.m_flLanceRecharge = GameTime + 30.0;
		npc.m_flLanceDuration = GameTime + 20.0;
	}
	
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
		if(!(IsValidClient(clients) && GetClientTeam(clients) == 2 && TeutonType[clients] != TEUTON_WAITING))
			continue;
		ValidEnts[amt] = clients;
		amt++;
	}

	for(int targ; targ< i_MaxcountNpcTotal; targ++)
	{
		int baseboss_index = EntRefToEntIndexFast(i_ObjectsNpcsTotal[targ]);
		if (!(IsValidEntity(baseboss_index) && !b_NpcHasDied[baseboss_index] && team  == GetTeam(baseboss_index)))
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
			player_amt = amt;
			return averageVec;
		}

		AvgDist /=amt;

		int new_amt = 0;
		int newValidEnts[100];

		//now nuke everthing beyond avg dist.

		for(int i=0 ; i < amt ; i++)
		{
			if(AvgDist <= DistFromCore[i])
			{
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