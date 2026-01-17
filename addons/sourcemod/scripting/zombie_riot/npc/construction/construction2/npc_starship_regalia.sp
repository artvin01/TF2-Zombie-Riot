#pragma semicolon 1
#pragma newdecls required

#define STARSHIP_MODEL	"models/zombie_riot/starship_4.mdl"

static float fl_ShipAcceleration;
static float fl_ShipDeceleration;
static float fl_ShipHyperDecelerationNearDist = 500.0;
static float fl_ShipHyperDecelerationSpeed = 80.0;
static float fl_ShipHyperDecelerationMax = 0.5;

static float fl_ShipTurnSpeed;
/*
	Behaviors:


	Flight isssues:
	Required turn can become too high resulting in the ship going inverted due to rotational turn adjustment.
		add max limits.

	When going over a target ship rotation get wonky.
*/

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
	PrecacheModel(STARSHIP_MODEL, true);
    NPCData data;
	strcopy(data.Name, sizeof(data.Name), "HMS: Regalia");	//Regalia Class battlecruisers
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_starship_regalia");
	strcopy(data.Icon, sizeof(data.Icon), "soldier");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = 0;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return RegaliaClass(vecPos, vecAng, team, data);
}

methodmap RegaliaClass < CClotBody
{
	property float m_flCurrentSpeed
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	public RegaliaClass(float vecPos[3], float vecAng[3], int team, const char[] data)
	{
		RegaliaClass npc = view_as<RegaliaClass>(CClotBody(vecPos, vecAng, STARSHIP_MODEL, "1.0", "1250", team, .CustomThreeDimensions = {1000.0, 1000.0, 200.0}, .CustomThreeDimensionsextra = {-1000.0, -1000.0, -200.0}));
		
		i_NpcWeight[npc.index] = 999;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.CreateBody();
		npc.ShieldState(true);
		
		npc.m_iBleedType 			= BLEEDTYPE_METAL;
		//npc.m_iStepNoiseType 		= STEPSOUND_NORMAL;	
		//npc.m_iNpcStepVariation 	= STEPTYPE_NORMAL;

		func_NPCDeath[npc.index]			= NPC_Death;
		func_NPCOnTakeDamage[npc.index] 	= OnTakeDamage;
		func_NPCThink[npc.index] 			= ClotThink;

		fl_ShipTurnSpeed = 0.5;

		fl_ShipAcceleration = 10.0;
		fl_ShipDeceleration	= 2.5;
		fl_ShipHyperDecelerationNearDist = 500.0;
		fl_ShipHyperDecelerationSpeed = 10.0;
		fl_ShipHyperDecelerationMax = 0.5;

		npc.m_flSpeed = 1000.0;		//MAX SPEED
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StopPathing();	//don't path.
		
		//npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_claidheamohmor/c_claidheamohmor.mdl");	//claidemor
		//SetVariantString("1.0");
		//AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		//
		int skin = 1;	//1=blue, 0=red
		SetVariantInt(1);	
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		fl_AbilityVectorData[npc.index] = npc.GetAngles();


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
		float Angles[3];
		GetEntPropVector(this.index, Prop_Data, "m_angRotation", Angles);
		int iPitch = this.LookupPoseParameter("body_pitch");
				
		float flPitch = this.GetPoseParameter(iPitch);
		flPitch *= -1.0;
		Angles[0] = flPitch;

		return Angles;
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
		GetAbsOrigin(this.m_iTarget, TargetLoc); TargetLoc[2]+=250.0;
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
	public void Fly(float Vec[3], float Dist)
	{
		float DroneLoc[3];
		GetAbsOrigin(this.index, DroneLoc);

		float Angles[3];

		VectorTurnData Data;
		Data.Origin 		= DroneLoc;	//this makes it act form vec to vec rather then from angles to angles.
		Data.TargetVec 		= Vec;
		Data.CurrentAngles 	= fl_AbilityVectorData[this.index];
		Data.PitchSpeed		= fl_ShipTurnSpeed;
		Data.YawSpeed		= fl_ShipTurnSpeed;
		Angles = TurnVectorTowardsGoal(Data);
		fl_AbilityVectorData[this.index] = Angles;

		float TurnRates[2];
		TurnRates[0] = Data.PitchRotateLeft;
		TurnRates[1] = Data.YawRotateLeft;

		float MaxSpeed = this.m_flSpeed;
		//we gotta turn ALOT, so slow down the this.index to make its turning circle smaller.

		bool HyperDeccel = (Dist < fl_ShipHyperDecelerationNearDist);

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
			
			float SpeedRatio = Dist / fl_ShipHyperDecelerationNearDist;

			if(SpeedRatio < fl_ShipHyperDecelerationMax)
				SpeedRatio = fl_ShipHyperDecelerationMax;

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

		SDKCall_SetLocalAngles(this.index, Angles);
		this.SetVelocity(fVel);
	}
	public float GetShipFlightSpeed(float MaxSpeed, bool HyperDeccel, bool DoNotAccel)
	{
		float FlySpeed = this.m_flCurrentSpeed;
		float Acceleration = fl_ShipAcceleration;
		float Deccel = HyperDeccel ? fl_ShipHyperDecelerationSpeed : fl_ShipDeceleration;


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

	

	
}
static Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	RegaliaClass npc = view_as<RegaliaClass>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;

	return Plugin_Continue;
}
static void NPC_Death(int iNPC)
{
	RegaliaClass npc = view_as<RegaliaClass>(iNPC);
}