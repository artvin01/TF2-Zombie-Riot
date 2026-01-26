#pragma semicolon 1
#pragma newdecls required


#define LANTEAN_NPC_DRONE_MODEL	"models/props_moonbase/moon_gravel_crystal_blue.mdl"//"models/empty.mdl"


static float fl_LanteanDrone_Acceleration;
static float fl_LanteanDrone_Deceleration;
static float fl_LanteanDrone_HyperDecelerationNearDist = 500.0;
static float fl_LanteanDrone_HyperDecelerationSpeed = 80.0;
static float fl_LanteanDrone_HyperDecelerationMax = 0.5;
static float fl_LanteanDrone_TurnSpeed;

void Lantean_Drone_Projectile_OnMapStart()
{
	NPCData lantean_data;
	strcopy(lantean_data.Name, sizeof(lantean_data.Name), "Lantean Drone Projectile");
	strcopy(lantean_data.Plugin, sizeof(lantean_data.Plugin), "npc_lantean_drone_projectile");
	//strcopy(lantean_data.Icon, sizeof(data.Icon), "soldier");
	lantean_data.IconCustom = false;
	lantean_data.Flags 		= -1;
	lantean_data.Category 	= Type_Outlaws;
	lantean_data.Func 		= ClotSummon_Lantean;
	lantean_data.Precache 	= ClotPrecache_Drone;
	NPC_Add(lantean_data);

}
static void ClotPrecache_Drone()
{
	PrecacheModel(LANTEAN_NPC_DRONE_MODEL);
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

		npc.m_bNoKillFeed = true;

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
		func_NPCOnTakeDamage[npc.index] 	= INVALID_FUNCTION;
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
		npc.b_BlockDropChances					= true;

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

	SetEntityRenderMode(npc.index, RENDER_NORMAL);
	SetEntityRenderColor(npc.index, 255, 255, 255, 255);

	SDKUnhook(npc.index, SDKHook_Think, 		ProjectileBaseThink);
	SDKUnhook(npc.index, SDKHook_StartTouch, 	Wand_Base_StartTouch);
}