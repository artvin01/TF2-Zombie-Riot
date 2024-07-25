#pragma semicolon 1
#pragma newdecls required

#define NEUVELLETE_MAIN_BEAM_SOUND	"npc/combine_gunship/dropship_engine_distant_loop1.wav"	//"weapons/physcannon/energy_sing_loop4.wav"
#define NEUVELLETE_ION_KABOOM_SOUND	"misc/doomsday_missile_explosion.wav"
#define NEUVELLETE_ION_CAST_SOUND	"misc/doomsday_cap_open_start.wav"
#define NEUVELLETE_ION_EXTRA_SOUND0	"misc/ks_tier_04.wav"
#define NEUVELLETE_ION_EXTRA_SOUND1	"misc/ks_tier_04_death.wav"
#define NEUVELLETE_MAIN_BEAM_START_SONUD		"misc/ks_tier_04.wav"


//NOTE!!!! this affects ALL STATS, how fast it turns, how fast it deal damage, etc etc etc
#define NEUVELLETE_THROTTLE_SPEED 0.1//6.0/float(TickrateModifyInt)	//this thing was a bitch to try and figure out correctly the timings, and even then its not perfect
#define NEUVELLETE_TE_DURATION 0.1//6.6/float(TickrateModifyInt)

#define MAX_NEUVELLETE_TARGETS_HIT 10	//how many targets the laser can penetrate BASELINE!!!!

static Handle h_TimerNeuvellete_Management[MAXPLAYERS+1] = {null, ...};
static int i_hand_particle[MAXTF2PLAYERS+1][11];
static float fl_hud_timer[MAXTF2PLAYERS+1];

static float fl_ion_charge_ammount[MAXTF2PLAYERS+1];
static float fl_Ion_timer[MAXTF2PLAYERS + 1];

static int Prismatic_TargetHit[MAX_NEUVELLETE_TARGETS_HIT+6];
static bool b_special_active[MAXTF2PLAYERS+1];
static float fl_beam_angle[MAXTF2PLAYERS+1][2];
static float fl_throttle[MAXTF2PLAYERS+1];
static float fl_throttle2[MAXTF2PLAYERS+1];
static float fl_extra_effects_timer[MAXTF2PLAYERS + 1];
static float fl_m2_timer[MAXTF2PLAYERS + 1];
static int i_Neuvellete_penetration[MAXTF2PLAYERS + 1];

static float fl_Neuvellete_Beam_Timeout[MAXTF2PLAYERS + 1];
static bool b_skill_points_give_at_pap[MAXTF2PLAYERS + 1][6];
static int i_skill_point_used[MAXTF2PLAYERS + 1];
static int i_Neuvellete_HEX_Array[MAXTF2PLAYERS + 1];
static int i_Neuvellete_Skill_Points[MAXTF2PLAYERS + 1];

static float fl_Special_Timer[MAXTF2PLAYERS + 1];

static int i_pap[MAXTF2PLAYERS];


static int BeamWand_Laser;
static int BeamWand_Glow;
static char gExplosive1;
//static int BeamWand_LaserBeam;

static char gGlow1;
//static char gLaser2;
public void Ion_Beam_Wand_MapStart()
{
	Zero(fl_Ion_timer);
	Zero(fl_ion_charge_ammount);
	Zero(fl_Special_Timer);
	Zero(fl_Neuvellete_Beam_Timeout);
	Zero(h_TimerNeuvellete_Management);
	Zero(fl_hud_timer);
	Zero(i_Neuvellete_Skill_Points);
	Zero(i_Neuvellete_HEX_Array);
	Zero2(b_skill_points_give_at_pap);
	Zero(i_skill_point_used);
	Zero(b_special_active);
	Zero2(fl_beam_angle);
	Zero(fl_throttle);
	Zero(fl_throttle2);
	Zero(fl_extra_effects_timer);
	Zero(fl_m2_timer);
	PrecacheSound(NEUVELLETE_MAIN_BEAM_SOUND);
	PrecacheSound(NEUVELLETE_ION_CAST_SOUND);
	PrecacheSound(NEUVELLETE_ION_EXTRA_SOUND0);
	PrecacheSound(NEUVELLETE_ION_EXTRA_SOUND1);
	PrecacheSound(NEUVELLETE_MAIN_BEAM_START_SONUD);
	PrecacheSound(NEUVELLETE_ION_KABOOM_SOUND);
	PrecacheModel("materials/sprites/laserbeam.vmt");
	BeamWand_Laser = PrecacheModel("materials/sprites/laser.vmt", false);
	//BeamWand_LaserBeam = PrecacheModel("materials/sprites/laserbeam.vmt");
	BeamWand_Glow = PrecacheModel("sprites/glow02.vmt", true);
	gGlow1 = PrecacheModel("sprites/blueglow2.vmt", true);
	//gLaser2= PrecacheModel("materials/sprites/lgtning.vmt");
}

#define NEUVELLETE_HEXAGON_CHARGE_TIME 3.5
#define NEUVELLETE_HEXAGON_CHARGE_TIME_PRIMER 1.5	//THIS MUST ALWAYS BE LESS THEN THE ONE ABOVE IT
//Tottal charge time is these 2 combined

#define NEUVELLETE_BASELINE_ION_DMG 750.0
#define NEUVELLETE_BASELINE_ION_RANGE 15.0

#define NEUVELLETE_BASELINE_DAMAGE 140.0
#define NEUVELLETE_BASELINE_RANGE 1000.0				//how far the laser can reach
#define NEUVELLETE_BASELINE_TURN_SPEED (1.75*10.0)/float(TickrateModifyInt)
#define NEUVELLETE_BASELINE_PITCH_SPEED (1.75*10.0)/float(TickrateModifyInt)

#define FLAG_NEUVELLETE_PAP_1_DMG				(1 << 1)
#define FLAG_NEUVELLETE_PAP_1_TURNRATE			(1 << 2)
#define FLAG_NEUVELLETE_PAP_1_MANA_EFFICIENCY	(1 << 3)

#define FLAG_NEUVELLETE_PAP_2_DMG				(1 << 4)
#define FLAG_NEUVELLETE_PAP_2_RANGE				(1 << 5)
#define FLAG_NEUVELLETE_PAP_2_PENETRATION		(1 << 6)

#define FLAG_NEUVELLETE_PAP_3_PENETRATION_FALLOFF	(1 << 7)
#define FLAG_NEUVELLETE_PAP_3_TURNRATE			(1 << 8)
#define FLAG_NEUVELLETE_PAP_3_RANGE				(1 << 9)	

#define FLAG_NEUVELLETE_PAP_4_PENETRATION		(1 << 10)
#define FLAG_NEUVELLETE_PAP_4_TURNRATE			(1 << 11)
#define FLAG_NEUVELLETE_PAP_4_MANA_EFFICIENCY	(1 << 12)

//	"Overclocks" - Heavily changes the weapon, buffs one thing nerfs another, mostly optional stuff if the player wants to

//Nightmare: Heavily reduces turnrate, heavily increases damage
//Pulse: Instead of the beam being constant, the beam only lasts for 2.5 seconds, but has huge turnrate, and resonable damage, increases the useage cooldown
//Feedback: the longer its active, the more damage it deals, beam also moves slower the longer its active

static float fl_turnspeed[MAXTF2PLAYERS + 1];
static float fl_pitchspeed[MAXTF2PLAYERS + 1];
static float fl_main_damage[MAXTF2PLAYERS + 1];
static float fl_main_range[MAXTF2PLAYERS + 1];
static int i_manacost[MAXTF2PLAYERS + 1];
static int i_Effect_Hex[MAXTF2PLAYERS + 1];
static float fl_penetration_falloff[MAXTF2PLAYERS + 1];

static void Neuvellete_Adjust_Stats_To_Flags(int client, float &Turn_Speed, float &Pitch_Speed, float &DamagE, float &Range, int &Penetration, int &Mana_Cost, float &Pen_FallOff, int &Effects, int weapon)
{
	int flags = i_Neuvellete_HEX_Array[client];
	float GameTime = GetGameTime();
	
	//note: These can be gotten in any order. so for example:
	/*
		Pap1: Turnrate
		Pap2: Dmg
		pap3: range
		pap4: Pen
	
	*/

	if(RaidbossIgnoreBuildingsLogic(1))
	{
		DamagE *=1.33;
		Turn_Speed += 1.25;
		Pitch_Speed += 1.25;
	}


	if(flags & FLAG_NEUVELLETE_PAP_1_DMG)
	{
		DamagE *= 1.1;
	}
	if(flags & FLAG_NEUVELLETE_PAP_1_TURNRATE)
	{
		Turn_Speed += 0.25;
		Pitch_Speed += 0.25;
		Effects |= (1 << 2);	//adds +1 to the spinning shape
	}
	if(flags & FLAG_NEUVELLETE_PAP_1_MANA_EFFICIENCY)
	{
		Mana_Cost -= RoundToFloor(float(Mana_Cost) * 0.25);
		Effects |= (1 << 1); //adds the spinning shape
	}
	
	
	if(flags & FLAG_NEUVELLETE_PAP_2_DMG)
	{
		DamagE *= 1.2;
		Effects |= (1 << 1);	//adds the spinning shape
	}
	if(flags & FLAG_NEUVELLETE_PAP_2_PENETRATION)	//baseline+6 is array size!
	{
		Penetration += 2;
		Effects |= (1 << 1);	//adds the spinning shape
		Effects |= (1 << 3);	//adds +1 to the spinning shape
	}
	if(flags & FLAG_NEUVELLETE_PAP_2_RANGE)
	{
		Range *= 1.15;
		Effects |= (1 << 1);	//adds the spinning shape
	}
	
	
	if(flags & FLAG_NEUVELLETE_PAP_3_RANGE)	//heavy increase due to the other relative upgrades
	{
		Range *= 1.5;
		Effects |= (1 << 4);	//adds +1 to the spinning shape
	}
	if(flags & FLAG_NEUVELLETE_PAP_3_PENETRATION_FALLOFF)
	{
		Pen_FallOff = 0.85;
	}
	if(flags & FLAG_NEUVELLETE_PAP_3_TURNRATE)
	{
		Turn_Speed += 0.3;
		Pitch_Speed += 0.3;
	}
	
	
	if(flags & FLAG_NEUVELLETE_PAP_4_TURNRATE)
	{
		Turn_Speed += 0.25;
		Pitch_Speed += 0.1;
	}
	if(flags & FLAG_NEUVELLETE_PAP_4_PENETRATION)
	{
		Penetration += 2;
	}
	if(flags & FLAG_NEUVELLETE_PAP_4_MANA_EFFICIENCY)
	{
		Mana_Cost -= RoundToFloor(float(Mana_Cost) * 0.25);
		Effects |= (1 << 5);	//adds +1 to the spinning shape
	}

	if(!IsValidEntity(weapon))
	{
		if(i_pap[client]>=5)
		{
			DamagE *= 2.0;
		}
		return;
	}
		

	switch(i_CustomWeaponEquipLogic[weapon])
	{
		case WEAPON_ION_BEAM_FEED:
		{
			float Duration = fl_Special_Timer[client] - GameTime; Duration *= -1.0;
			float Ration = Duration*1.15 - Duration;
			
			if(Ration>2.5)
				Ration = 2.5;
			
			DamagE *= Ration;

			if(Ration< 1.0)
				Ration= 1.0;

			Mana_Cost += RoundToFloor(float(Mana_Cost)*0.2*Ration);
		
			Effects |= (1 << 8); //feedback
		}
		case WEAPON_ION_BEAM_NIGHT:
		{
			Range *= 1.25;
		
			Turn_Speed *= 0.5;
			Pitch_Speed *= 0.5;
			
			DamagE *= 2.1;

			Mana_Cost -= RoundToFloor(float(Mana_Cost)*0.1);
			
			Effects |= (1 << 6);	//nightmare
		}
		case WEAPON_ION_BEAM_PULSE:
		{
			if(GameTime > fl_Special_Timer[client] + 1.75)
			{
				Kill_Beam_Hook(client, 0.0);
				return;
			}
			Mana_Cost += RoundToFloor(float(Mana_Cost)*0.1);
			
			DamagE *= 1.9;
			
			Effects |= (1 << 7); //
			
		}
	}
}

public void Activate_Neuvellete(int client, int weapon)
{
	if (h_TimerNeuvellete_Management[client] != null)
	{
		//This timer already exists.
		if(IsPrismatic(weapon))
		{
			//Is the weapon it again?
			//Yes?
			delete h_TimerNeuvellete_Management[client];
			h_TimerNeuvellete_Management[client] = null;
			
			int pap = Get_Pap(weapon);
			if(pap!=0 && pap < 6)
				Give_Skill_Points(client, pap);

			i_pap[client] = pap;

			DataPack pack;
			h_TimerNeuvellete_Management[client] = CreateDataTimer(0.1, Timer_Management_Neuvellete, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(IsPrismatic(weapon))
	{
		int pap = Get_Pap(weapon);
		if(pap!=0 && pap < 6)
			Give_Skill_Points(client, pap);

		i_pap[client] = pap;
		
		DataPack pack;
		h_TimerNeuvellete_Management[client] = CreateDataTimer(0.1, Timer_Management_Neuvellete, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}
static void Create_Hand_Particle(int client)
{
	int viewmodelModel;
	viewmodelModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
	
	if(!IsValidEntity(viewmodelModel))
		return;

	for(int RepeatDeletion; RepeatDeletion < 11; RepeatDeletion ++)
	{
		if(IsValidEntity(i_hand_particle[client][RepeatDeletion]))
			RemoveEntity(i_hand_particle[client][RepeatDeletion]);
	}
	if(AtEdictLimit(EDICT_PLAYER))
		return;
		
	float flPos[3];
	float flAng[3];
	GetAttachment(viewmodelModel, "effect_hand_r", flPos, flAng);
	
	int particle_1 = ParticleEffectAt({-4.0,0.0,0.0}, "raygun_projectile_blue_crit", 0.0);
	AddEntityToThirdPersonTransitMode(client, particle_1);

	//float RotateVector[3];
	//RotateVector = {45.0,0.0,0.0};

	float VectorSet[3];

	//http://www.mathforengineers.com/math-calculators/3D-point-rotation-calculator.html
//	VectorSet = {8.0,8.0,-8.0};
	VectorSet = {-4.000,12.000,-5.657};
//RotateVectorViaAngleVector(RotateVector, VectorSet);
	int	particle_2 = InfoTargetParentAt(VectorSet, "", 0.0); //First offset we go by

	VectorSet = {-12.000,4.000,5.657};
	int	particle_3 = InfoTargetParentAt(VectorSet, "", 0.0); //First offset we go by

	VectorSet = {-5.657,-5.657,-8.000};
	int	particle_4 = InfoTargetParentAt(VectorSet, "", 0.0); //First offset we go by

	VectorSet = {6.828,-1.172,4.000};
	int	particle_5 = InfoTargetParentAt(VectorSet, "", 0.0); //First offset we go by

	SetParent(particle_1, particle_2, "",_, true);
	SetParent(particle_1, particle_3, "",_, true);
	SetParent(particle_1, particle_4, "",_, true);
	SetParent(particle_1, particle_5, "",_, true);

	Custom_SDKCall_SetLocalOrigin(particle_1, flPos);
	SetEntPropVector(particle_1, Prop_Data, "m_angRotation", flAng); 
	SetParent(viewmodelModel, particle_1, "effect_hand_r",_);

	int red = 200;
	int green = 200;
	int blue = 200;

	int Laser_1 = ConnectWithBeamClient(particle_2, particle_3, red, green, blue, 1.0, 1.0, 1.0, LASERBEAM, client);
	int Laser_2 = ConnectWithBeamClient(particle_2, particle_4, red, green, blue, 1.0, 1.0, 1.0, LASERBEAM, client);
	int Laser_3 = ConnectWithBeamClient(particle_3, particle_4, red, green, blue, 1.0, 1.0, 1.0, LASERBEAM, client);
	int Laser_4 = ConnectWithBeamClient(particle_5, particle_2, red, green, blue, 1.0, 1.0, 1.0, LASERBEAM, client);
	int Laser_5 = ConnectWithBeamClient(particle_5, particle_3, red, green, blue, 1.0, 1.0, 1.0, LASERBEAM, client);
	int Laser_6 = ConnectWithBeamClient(particle_5, particle_4, red, green, blue, 1.0, 1.0, 1.0, LASERBEAM, client);
	

	i_hand_particle[client][0] = EntIndexToEntRef(particle_1);
	i_hand_particle[client][1] = EntIndexToEntRef(particle_2);
	i_hand_particle[client][2] = EntIndexToEntRef(particle_3);
	i_hand_particle[client][3] = EntIndexToEntRef(particle_4);
	i_hand_particle[client][4] = EntIndexToEntRef(particle_5);
	i_hand_particle[client][5] = EntIndexToEntRef(Laser_1);
	i_hand_particle[client][6] = EntIndexToEntRef(Laser_2);
	i_hand_particle[client][7] = EntIndexToEntRef(Laser_3);
	i_hand_particle[client][8] = EntIndexToEntRef(Laser_4);
	i_hand_particle[client][9] = EntIndexToEntRef(Laser_5);
	i_hand_particle[client][10] = EntIndexToEntRef(Laser_6);
}
public Action Timer_Management_Neuvellete(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client))
	{
		Kill_Neuvellete_Extras(client);
		h_TimerNeuvellete_Management[client] = null;
		return Plugin_Stop;
	}	

	if(!Neuvellete_Loop_Logic(client, EntRefToEntIndex(pack.ReadCell())))
	{
		Kill_Neuvellete_Extras(client);
		h_TimerNeuvellete_Management[client] = null;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}
bool IsPrismatic(int weapon)
{
	switch(i_CustomWeaponEquipLogic[weapon])
	{
		case WEAPON_ION_BEAM:
			return true;

		case WEAPON_ION_BEAM_FEED:
			return true;

		case WEAPON_ION_BEAM_NIGHT:
			return true;
		
		case WEAPON_ION_BEAM_PULSE:
			return true;
	}
	return false;
}
static bool Neuvellete_Loop_Logic(int client, int weapon)
{
	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

	if(IsValidEntity(weapon))
	{
		if(IsPrismatic(weapon))	//this loop will work if the holder doesn't have it in there hands, but they have it bought
		{
			if(weapon_holding==weapon)	//And this will only work if they have the weapon in there hands and bought
			{	
				float GameTime = GetGameTime();
				int buttons = GetClientButtons(client);
				bool attack2 = (buttons & IN_ATTACK2) != 0;
				if(fl_hud_timer[client]<GameTime)
				{
					fl_hud_timer[client] = GameTime + 0.5;
					Neuvellete_Hud(client, weapon);
				}
				
				if(b_special_active[client])
				{
					int main_mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));
					
					float Turn_Speed = NEUVELLETE_BASELINE_TURN_SPEED;
					float Pitch_Speed = NEUVELLETE_BASELINE_PITCH_SPEED;
					float DamagE = NEUVELLETE_BASELINE_DAMAGE;
					float Range = NEUVELLETE_BASELINE_RANGE;
					int Penetration = MAX_NEUVELLETE_TARGETS_HIT;
					float Pen_Falloff = LASER_AOE_DAMAGE_FALLOFF;
					int Effects = 0;
							
					Neuvellete_Adjust_Stats_To_Flags(client, Turn_Speed, Pitch_Speed, DamagE, Range, Penetration, main_mana_cost, Pen_Falloff, Effects, weapon);
					
					DamagE *=Attributes_Get(weapon, 410, 1.0);
					
					Range *= Attributes_Get(weapon, 103, 1.0);
					Range *= Attributes_Get(weapon, 104, 1.0);
					Range *= Attributes_Get(weapon, 475, 1.0);
					Range *= Attributes_Get(weapon, 101, 1.0);
					Range *= Attributes_Get(weapon, 102, 1.0);
					
					/*
					float firerate1 = Attributes_Get(weapon, 6, 1.0);
					float firerate2 = Attributes_Get(weapon, 5, 1.0);
					Turn_Speed /= firerate1;
					Turn_Speed /= firerate2;
					Pitch_Speed /= firerate1;
					Pitch_Speed /= firerate2;
					*/
			
					fl_turnspeed[client] = Turn_Speed;
					fl_pitchspeed[client] = Pitch_Speed;
					fl_main_damage[client] = DamagE;
					fl_main_range[client] = Range;
					i_manacost[client] = main_mana_cost;
					i_Effect_Hex[client] = Effects;
					i_Neuvellete_penetration[client] = Penetration;
					fl_penetration_falloff[client] = Pen_Falloff;
				}
				
				if(i_pap[client]>=3)
				{
					if(attack2 && fl_Ion_timer[client]<=GameTime)
					{
						int mana_cost = 10;
						
						if(Current_Mana[client]>=mana_cost)
						{		
							if(fl_ion_charge_ammount[client]<=1000.0)
							{
								fl_ion_charge_ammount[client] += mana_cost;
								float Null = 0.0;
								int Null2 = 0;
								Neuvellete_Adjust_Stats_To_Flags(client, Null, Null, Null, Null, Null2, mana_cost, Null, Null2, -1);
								if(mana_cost>10)
									mana_cost = 10;
								Current_Mana[client] -=mana_cost;
							}
						}
						Mana_Regen_Delay[client] = GameTime + 1.0;
					}
					else if(fl_ion_charge_ammount[client]>250.0 && fl_Ion_timer[client] < GameTime)
					{
						fl_Ion_timer[client] = GameTime + 30.0+NEUVELLETE_HEXAGON_CHARGE_TIME+NEUVELLETE_HEXAGON_CHARGE_TIME_PRIMER;
						
						Witch_Hexagon_Witchery(client, weapon);
						EmitSoundToClient(client, NEUVELLETE_ION_CAST_SOUND, _, SNDCHAN_STATIC, 100, _, SNDVOL_NORMAL, SNDPITCH_NORMAL); 
						EmitSoundToClient(client, NEUVELLETE_ION_EXTRA_SOUND0, _, SNDCHAN_STATIC, 100, _, SNDVOL_NORMAL, SNDPITCH_NORMAL); 
					}
					else if(fl_ion_charge_ammount[client]>0.0 && fl_Ion_timer[client] < GameTime)
					{
						fl_ion_charge_ammount[client] = 0.0;
					}
				}
				if(!IsValidEntity(EntRefToEntIndex(i_hand_particle[client][0])))
				{
					Create_Hand_Particle(client);
				}
				
			}
			else
			{
				if(IsValidEntity(EntRefToEntIndex(i_hand_particle[client][0])))
				{
					RemoveEntity(EntRefToEntIndex(i_hand_particle[client][0]));
				}
				if(IsValidEntity(EntRefToEntIndex(i_hand_particle[client][1])))
				{
					RemoveEntity(EntRefToEntIndex(i_hand_particle[client][1]));
				}
				if(b_special_active[client])
				{
					if(i_CustomWeaponEquipLogic[weapon]==WEAPON_ION_BEAM_PULSE)
					{
						Kill_Beam_Hook(client, 0.0);
					}
					else
					{
						Kill_Beam_Hook(client, 2.5);
					}
				}		
			}
		}
		else
		{
			return false;
		}
	}
	else
	{
		return false;
	}
	return true;
}

static void Neuvellete_Hud(int client, int weapon)
{
	char HUDText[255] = "";
	
	float GameTime = GetGameTime();
	
	if(b_special_active[client])
	{
		if(i_CustomWeaponEquipLogic[weapon]==WEAPON_ION_BEAM_FEED)
		{
			float Duration = fl_Special_Timer[client] - GameTime; Duration *= -1.0;
			float Ration = Duration*1.15 - Duration;
			
			if(Ration>2.5)
				Ration = 2.5;
				
			Format(HUDText, sizeof(HUDText), "%sPrismatic Laser: [Online | Power: (%.1f/2.5)]", HUDText, Ration);
		}
		else
		{
			Format(HUDText, sizeof(HUDText), "%sPrismatic Laser: [Online]", HUDText);
		}
	}
	else
	{
		Format(HUDText, sizeof(HUDText), "%sPrismatic Laser: [Offline]", HUDText);
	}

	if(i_pap[client]>=3)
	{
		if(fl_Ion_timer[client]<=GameTime)
		{
			if(fl_ion_charge_ammount[client]<=0.0)
			{
				Format(HUDText, sizeof(HUDText), "%s\nHexagon Cannon: [Offline] ", HUDText);
			}
			else if(fl_ion_charge_ammount[client]>0.0)
			{
				float charge_precent = fl_ion_charge_ammount[client] / 10.0;
				Format(HUDText, sizeof(HUDText), "%s\nHexagon Cannon: [Charging | %.1f％]", HUDText, charge_precent);
			}
		}
		else
		{
			float duration = fl_Ion_timer[client] - GameTime;
			Format(HUDText, sizeof(HUDText), "%s\nHexagon Cannon: [Recharging | %.1f] ", HUDText, duration);
		}
	}
	
	
	PrintHintText(client, HUDText);
	StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
}
static bool b_hexagon_ancored[MAXTF2PLAYERS];
static bool b_hexagon_created[MAXTF2PLAYERS];
static float fl_hexagon_vec[MAXTF2PLAYERS][3];
static float fl_ability_timer[MAXTF2PLAYERS];
static float fl_dmg[MAXTF2PLAYERS];
static float fl_range[MAXTF2PLAYERS];
static void Witch_Hexagon_Witchery(int client, int weapon)
{
	fl_throttle2[client] = 0.0;
	b_hexagon_ancored[client] = false;
	b_hexagon_created[client] = false;
	float time = NEUVELLETE_HEXAGON_CHARGE_TIME_PRIMER+NEUVELLETE_HEXAGON_CHARGE_TIME;
	float gametime = GetGameTime();
	fl_ability_timer[client] = gametime + time;
	SDKHook(client, SDKHook_PreThink, Hexagon_Witchery_Tick);
	
	float DamagE = NEUVELLETE_BASELINE_ION_DMG*(fl_ion_charge_ammount[client]/100.0);
	
	float range = NEUVELLETE_BASELINE_ION_RANGE * (fl_ion_charge_ammount[client]/100.0);
		
	
	
	
	float Null = 0.0;
	int Null2 = 0;
	Neuvellete_Adjust_Stats_To_Flags(client, Null, Null, DamagE, range, Null2, Null2, Null, Null2, -1);
	
	DamagE *=Attributes_Get(weapon, 410, 1.0);
	range *= Attributes_Get(weapon, 103, 1.0);
	range *= Attributes_Get(weapon, 104, 1.0);
	range *= Attributes_Get(weapon, 475, 1.0);
	range *= Attributes_Get(weapon, 101, 1.0);
	range *= Attributes_Get(weapon, 102, 1.0);
	fl_dmg[client] = DamagE;
	fl_range[client] = range;
}
static float fl_hexagon_angle[MAXTF2PLAYERS];

static Action Hexagon_Witchery_Tick(int client)
{
	float gametime = GetGameTime();
	
	if(fl_throttle2[client]>gametime)
		return Plugin_Continue;
		
	float offset_time = NEUVELLETE_HEXAGON_CHARGE_TIME_PRIMER;
	float time = NEUVELLETE_HEXAGON_CHARGE_TIME;
	float range = fl_range[client];
	float origin_vec[3];
	int amount = 5;

	fl_throttle2[client] = gametime + NEUVELLETE_THROTTLE_SPEED;
	
	float DamagE = fl_dmg[client];
	
	if(!b_hexagon_ancored[client])
	{
		Handle swingTrace;
		float Vec_offset[3] , vec[3];
								
		b_LagCompNPC_No_Layers = true;
		StartLagCompensation_Base_Boss(client);
		DoSwingTrace_Custom(swingTrace, client, Vec_offset, 9999.9, false, 10.0, false); //infinite range, and (doesn't)ignore walls!	
		FinishLagCompensation_Base_boss();
	
		int target = TR_GetEntityIndex(swingTrace);	
		if(IsValidEnemy(client, target))
		{
			WorldSpaceCenter(target, vec);
			
		}
		else
		{
			TR_GetEndPosition(vec, swingTrace);
		}
		delete swingTrace;
		vec[2] += 50.0;
		fl_hexagon_vec[client] = vec;
		origin_vec = vec;
		b_hexagon_ancored[client] = true;
	}
	else
	{
		origin_vec = fl_hexagon_vec[client];
	}
	float duration = fl_ability_timer[client] - gametime+offset_time;
	
	
	
	//Now, with an anchor point set the fun can "begin"
	if(duration>offset_time)
	{
		if(duration-time>offset_time)	//we don't start "reeling" it in until after this
		{
			if(!b_hexagon_created[client])
			{
				fl_hexagon_angle[client] = 0.0;
				b_hexagon_created[client] = true;
				for (int j = 0; j < amount; j++)
				{
					float offset = (360.0/amount) * float(j);
					float vec_temp[4][3];
					for(int i=1 ; i<=3 ; i++)
					{
						float tempAngles[3], Direction[3], EndLoc[3];
						tempAngles[0] = 0.0;
						tempAngles[1] = float(i) * ((360.0/amount)*3)+offset;
						tempAngles[2] = 0.0;
						
						GetAngleVectors(tempAngles, Direction, NULL_VECTOR, NULL_VECTOR);
						ScaleVector(Direction, range*2.0);
						AddVectors(origin_vec, Direction, EndLoc);
						vec_temp[i] = EndLoc;
					}			
					int colour[4];
					float start_size = 4.0;
					float end_size = 4.0;
					colour[3] = 150;
		
					colour[0] = 255;
					colour[1] = 255;
					colour[2] = 255;
					
					TE_SetupBeamPoints(vec_temp[1], vec_temp[2], BeamWand_Laser, 0, 0, 0, offset_time, start_size, end_size, 0, 0.1, colour, 0);
					if(!LastMann)
						TE_SendToClient(client);
					else
						TE_SendToAll();
					
					TE_SetupBeamPoints(vec_temp[1], vec_temp[3], BeamWand_Laser, 0, 0, 0, offset_time, start_size, end_size, 0, 0.1, colour, 0);
					if(!LastMann)
						TE_SendToClient(client);
					else
						TE_SendToAll();
	
					TE_SetupGlowSprite(vec_temp[1], gGlow1, offset_time, 0.5, 255);
					if(!LastMann)
						TE_SendToClient(client);
					else
						TE_SendToAll();

				}
			}
		}
		else
		{
			fl_hexagon_angle[client] += 3.5;
			if(fl_hexagon_angle[client]>360.0)
			{
				fl_hexagon_angle[client] = 0.0;
			}
			range *= (duration-offset_time) / time;
			
			for (int j = 0; j < amount; j++)
			{
				float offset = (360.0/amount) * float(j);
				float vec_temp[4][3];
				for(int i=1 ; i<=3 ; i++)
				{
					float tempAngles[3], Direction[3], EndLoc[3];
					tempAngles[0] = 0.0;
					tempAngles[1] = fl_hexagon_angle[client]+float(i) * ((360.0/amount)*3)+offset;
					tempAngles[2] = 0.0;
					
					GetAngleVectors(tempAngles, Direction, NULL_VECTOR, NULL_VECTOR);
					ScaleVector(Direction, range*2.0);
					AddVectors(origin_vec, Direction, EndLoc);
					vec_temp[i] = EndLoc;
				}			
				int colour[4];
				float start_size = 4.0;
				float end_size = 4.0;
				colour[3] = 150;
	
				colour[0] = 255;
				colour[1] = 255;
				colour[2] = 255;
				
				TE_SetupBeamPoints(vec_temp[1], vec_temp[2], BeamWand_Laser, 0, 0, 0, NEUVELLETE_TE_DURATION, start_size, end_size, 0, 0.1, colour, 0);
				if(!LastMann)
					TE_SendToClient(client);
				else
					TE_SendToAll();
				TE_SetupBeamPoints(vec_temp[1], vec_temp[3], BeamWand_Laser, 0, 0, 0, NEUVELLETE_TE_DURATION, start_size, end_size, 0, 0.1, colour, 0);
				if(!LastMann)
					TE_SendToClient(client);
				else
					TE_SendToAll();

				TE_SetupGlowSprite(vec_temp[1], gGlow1, NEUVELLETE_TE_DURATION, 0.5, 255);
				if(!LastMann)
					TE_SendToClient(client);
				else
					TE_SendToAll();

			}
		}
	}
	else
	{
		SDKUnhook(client, SDKHook_PreThink, Hexagon_Witchery_Tick);
		//FIRE!
		int colour[4];
		colour[3] = 150;
		
		Explode_Logic_Custom(DamagE, client, client, -1, origin_vec, range);
		
		colour[0] = 255;
		colour[1] = 255;
		colour[2] = 255;
		spawnRing_Vector(origin_vec, 0.0, 0.0, 0.0, 1.0, "materials/sprites/laserbeam.vmt" , colour[0], colour[1], colour[2], colour[3], 1, 0.10, 5.0, 1.25, 1 , BEAM_WAND_CANNON_ABILITY_RANGE*3.25);
		spawnRing_Vector(origin_vec, 0.0, 0.0, 0.0, 2.0, "materials/sprites/laserbeam.vmt" , colour[0], colour[1], colour[2], colour[3], 1, 0.2, 5.0, 1.25, 1 , BEAM_WAND_CANNON_ABILITY_RANGE*2.0);
		spawnRing_Vector(origin_vec, 0.0, 0.0, 0.0, 3.5, "materials/sprites/laserbeam.vmt" , colour[0], colour[1], colour[2], colour[3], 1, 0.35, 5.0, 1.25, 1 , BEAM_WAND_CANNON_ABILITY_RANGE*1.75);
		
		TE_SetupExplosion(origin_vec, gExplosive1, 0.1, 1, 0, 0, 0);
		TE_SendToAll();
		
		EmitSoundToAll(NEUVELLETE_ION_KABOOM_SOUND, client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL);
		EmitSoundToAll(NEUVELLETE_ION_EXTRA_SOUND1, client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL);
				
		float position[3];
		position[0] = origin_vec[0];
		position[1] = origin_vec[1];
		position[2] += origin_vec[2] + 900.0;
		origin_vec[2] += -200;
		TE_SetupBeamPoints(origin_vec, position, BeamWand_Laser, 0, 0, 0, 2.0, 11.0, 11.0, 0, 1.0, colour, 3);
		TE_SendToAll();
		TE_SetupBeamPoints(origin_vec, position, BeamWand_Laser, 0, 0, 0, 1.66, 22.0, 22.0, 0, 1.0, colour, 3);
		
		
		float skyloc[3];
		
		fl_ion_charge_ammount[client] = 0.0;
		
		skyloc = origin_vec;
		skyloc[2] += 99999.0;
		TE_SetupBeamPoints(origin_vec, skyloc, BeamWand_Laser, 0, 0, 0, 2.0, 11.0, 11.0, 0, 1.0, colour, 3);
		if(!LastMann)
			TE_SendToClient(client);
		else
			TE_SendToAll();
		TE_SetupBeamPoints(origin_vec, skyloc, BeamWand_Laser, 0, 0, 0, 1.66, 22.0, 22.0, 0, 1.0, colour, 3);
		if(!LastMann)
			TE_SendToClient(client);
		else
			TE_SendToAll();
		TE_SetupBeamPoints(origin_vec, skyloc, BeamWand_Laser, 0, 0, 0, 1.33, 33.0, 33.0, 0, 1.0, colour, 3);
		if(!LastMann)
			TE_SendToClient(client);
		else
			TE_SendToAll();
		
		return Plugin_Stop;
	}
	return Plugin_Continue;
}
public void Kill_Neuvellete_Extras(int client)
{
	if(IsValidEntity(EntRefToEntIndex(i_hand_particle[client][0])))
	{
		RemoveEntity(EntRefToEntIndex(i_hand_particle[client][0]));
	}
	if(IsValidEntity(EntRefToEntIndex(i_hand_particle[client][1])))
	{
		RemoveEntity(EntRefToEntIndex(i_hand_particle[client][1]));
	}
	if(IsValidClient(client))
	{
		int weapon_active = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(IsValidEntity(weapon_active) && i_CustomWeaponEquipLogic[weapon_active]==WEAPON_ION_BEAM_PULSE)
			Kill_Beam_Hook(client, 0.0);
		else
			Kill_Beam_Hook(client, 2.5);
	}
	
}

public void Ion_Beam_On_Buy_Reset(int client)
{
	i_Neuvellete_HEX_Array[client] = 0;
	i_Neuvellete_Skill_Points[client] = 0;
	i_skill_point_used[client] = 0;
	for(int i=0 ; i < 6 ; i++)
	{
		b_skill_points_give_at_pap[client][i] = false;
	}
}

static int Get_Pap(int weapon)
{
	return RoundFloat(Attributes_Get(weapon, 122, 0.0));
}
static void Give_Skill_Points(int client, int pap)
{
	if(!b_skill_points_give_at_pap[client][pap])	//no going back!
	{
		b_skill_points_give_at_pap[client][pap] = true;
		i_Neuvellete_Skill_Points[client]++;
	}
}

public void Prismatic_Nightmare(int client, int weapon, bool crit)
{	
	Weapon_Ion_Wand_Beam(client, weapon, crit);
}
public void Prismatic_Pulse(int client, int weapon, bool crit)
{
	float GameTime = GetGameTime();

	if(fl_Neuvellete_Beam_Timeout[client] > GameTime)
	{
		float Cooldown = fl_Neuvellete_Beam_Timeout[client] - GameTime;
				
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Cooldown);
		return;
	}

	Kill_Beam_Hook(client, 0.0);

	fl_Special_Timer[client] = GameTime;
	float Angles[3];
	GetClientEyeAngles(client, Angles);
	b_special_active[client]=true;

	fl_beam_angle[client][0] = Angles[1];	//Yaw
	fl_beam_angle[client][1] = Angles[0];	//Pitch

	EmitSoundToClient(client, NEUVELLETE_MAIN_BEAM_SOUND, _, SNDCHAN_STATIC, 100, _, 0.5, 85);
	EmitSoundToClient(client, NEUVELLETE_MAIN_BEAM_START_SONUD, _, SNDCHAN_STATIC, 100, _, 0.25, 85);

	fl_throttle[client] = 0.0;
	fl_extra_effects_timer[client] = 0.0;

	Prismatic_Adjust_Stats(client, weapon);

	SDKHook(client, SDKHook_PreThink, Neuvellete_tick);
}
public void Prismatic_FeedBack(int client, int weapon, bool crit)
{
	Weapon_Ion_Wand_Beam(client, weapon, crit);
}

public void Weapon_Ion_Wand_Beam(int client, int weapon, bool crit)
{
	float GameTime = GetGameTime();
	if(!b_special_active[client])
	{
		if (fl_Neuvellete_Beam_Timeout[client]<=GameTime)
		{
			fl_Special_Timer[client] = GameTime;
			float Angles[3];
			GetClientEyeAngles(client, Angles);
			b_special_active[client]=true;
			SDKHook(client, SDKHook_PreThink, Neuvellete_tick);
			
			EmitSoundToClient(client, NEUVELLETE_MAIN_BEAM_SOUND, _, SNDCHAN_STATIC, 100, _, 0.5, 85);
			EmitSoundToClient(client, NEUVELLETE_MAIN_BEAM_START_SONUD, _, SNDCHAN_STATIC, 100, _, 0.25, 85);
			
			fl_beam_angle[client][0] = Angles[1];	//Yaw
			fl_beam_angle[client][1] = Angles[0];	//Pitch
			
			fl_throttle[client] = 0.0;
			fl_extra_effects_timer[client] = 0.0;
			
			Prismatic_Adjust_Stats(client, weapon);
		}
		else
		{
			float Cooldown = fl_Neuvellete_Beam_Timeout[client] - GameTime;
				
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Cooldown);
		}
		
	}
	else
	{
		Kill_Beam_Hook(client, 5.0);
		b_special_active[client] = false;
	}
}

static void Prismatic_Adjust_Stats(int client, int weapon)
{
	//to avoid an uber edge case where stats are null
	int main_mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));
			
	float Turn_Speed = NEUVELLETE_BASELINE_TURN_SPEED;
	float Pitch_Speed = NEUVELLETE_BASELINE_PITCH_SPEED;
	float DamagE = NEUVELLETE_BASELINE_DAMAGE;
	float Range = NEUVELLETE_BASELINE_RANGE;
	int Penetration = MAX_NEUVELLETE_TARGETS_HIT;
	float Pen_Falloff = LASER_AOE_DAMAGE_FALLOFF;
	int Effects = 0;
			
	Neuvellete_Adjust_Stats_To_Flags(client, Turn_Speed, Pitch_Speed, DamagE, Range, Penetration, main_mana_cost, Pen_Falloff, Effects, weapon);
	
	DamagE *=Attributes_Get(weapon, 410, 1.0);
	
	Range *= Attributes_Get(weapon, 103, 1.0);
	Range *= Attributes_Get(weapon, 104, 1.0);
	Range *= Attributes_Get(weapon, 475, 1.0);
	Range *= Attributes_Get(weapon, 101, 1.0);
	Range *= Attributes_Get(weapon, 102, 1.0);
	
	/*
	float firerate1 = Attributes_Get(weapon, 6, 1.0);
	float firerate2 = Attributes_Get(weapon, 5, 1.0);
	Turn_Speed /= firerate1;
	Turn_Speed /= firerate2;
	Pitch_Speed /= firerate1;
	Pitch_Speed /= firerate2;
	*/

	fl_turnspeed[client] = Turn_Speed;
	fl_pitchspeed[client] = Pitch_Speed;
	fl_main_damage[client] = DamagE;
	fl_main_range[client] = Range;
	i_manacost[client] = main_mana_cost;
	i_Effect_Hex[client] = Effects;
	i_Neuvellete_penetration[client] = Penetration;
	fl_penetration_falloff[client] = Pen_Falloff;
}

static float fl_spinning_angle[MAXTF2PLAYERS+1];
public Action Neuvellete_tick(int client)
{
	//if(IsValidClient(client))
	{
		float GameTime = GetGameTime();

		float Target_Angles[3], Beam_Angles[3], Start_Loc[3], Target_Loc[3];
		float Ignore = 0.0;
		GetClientEyeAngles(client, Target_Angles);
		Movement_Laser_Logic(Beam_Angles, fl_beam_angle[client], Target_Angles, fl_turnspeed[client], fl_pitchspeed[client], Ignore);	//warp
				
		if(fl_throttle[client]>GameTime)
			return Plugin_Continue;
		
		int mana_cost= i_manacost[client];

		int weapon_active = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		
		if(Current_Mana[client]<=mana_cost)
		{
			if(IsValidEntity(weapon_active) && i_CustomWeaponEquipLogic[weapon_active]==WEAPON_ION_BEAM_PULSE)
				Kill_Beam_Hook(client, 3.0);
			else
				Kill_Beam_Hook(client, 6.0);
			return Plugin_Stop;
		}
		fl_throttle[client] = GameTime + NEUVELLETE_THROTTLE_SPEED;
		int Effects = i_Effect_Hex[client];	

		Current_Mana[client] -=mana_cost;
		Mana_Regen_Delay[client] = GameTime + 1.0;

		if(IsValidEntity(weapon_active) && i_CustomWeaponEquipLogic[weapon_active] == WEAPON_ION_BEAM_PULSE)
		{
			Beam_Angles = Target_Angles;
		}

		float Main_Beam_Dist;

		Get_Loc(client, Start_Loc, Beam_Angles, Target_Loc, Main_Beam_Dist);	
		
		fl_spinning_angle[client]+=5.0;
		
		if(fl_spinning_angle[client]>=360.0)
		fl_spinning_angle[client] = 0.0;

		int Amt_Spin = 0;
		if(Effects & (1 << 1))
		{	
			Amt_Spin = 3;
			if(Effects & (1<<2))
				Amt_Spin++;
			if(Effects & (1<<3))
				Amt_Spin++;
			if(Effects & (1<<4))
				Amt_Spin++;
			if(Effects & (1<<5))
				Amt_Spin++;
		}
		

		if(IsValidEntity(weapon_active))
		{	
			float Distance_Stuff = 40.0;
			switch(i_CustomWeaponEquipLogic[weapon_active])
			{
				case WEAPON_ION_BEAM_FEED:
				{			
					Distance_Stuff = 35.0;
				}
				case WEAPON_ION_BEAM_NIGHT:
				{
					Amt_Spin++;
					if(Effects & (1 << 1))
					{
						float diststance_moonlight[2]; diststance_moonlight[0] = 40.0; diststance_moonlight[1] = 80.0;
						//Neuvellete_Create_Spinning_Beams_ALT_ALT_ALT(client, Start_Loc, Beam_Angles, Main_Beam_Dist, diststance_moonlight, 1.5);	//Moonlight
						Neuvellete_Create_Spinning_Beams(client, Start_Loc, Beam_Angles, Amt_Spin,  Main_Beam_Dist, true, diststance_moonlight[0], 1.0);						//Spining beams
						Neuvellete_Create_Spinning_Beams(client, Start_Loc, Beam_Angles, 3,  Main_Beam_Dist, false, diststance_moonlight[1], -1.0);						//Spining beams
					}
				}
				case WEAPON_ION_BEAM_PULSE:
				{				
					fl_spinning_angle[client] +=5.0;
					Amt_Spin++;	
					Distance_Stuff = 32.5;
					if(Effects & (1 << 1))
						Neuvellete_Create_Spinning_Beams(client, Start_Loc, Beam_Angles, Amt_Spin,  Main_Beam_Dist, true, Distance_Stuff, -1.0);
				}
			}	
			if(i_CustomWeaponEquipLogic[weapon_active] != WEAPON_ION_BEAM_NIGHT)
			{
				if(Effects & (1 << 1))
					Neuvellete_Create_Spinning_Beams(client, Start_Loc, Beam_Angles, Amt_Spin,  Main_Beam_Dist, true, Distance_Stuff, 1.0);
			}
		}

		Neuvellete_Base_Central_Beam(Start_Loc, Target_Loc);
		Prismatic_Damage_Trace(client, Start_Loc, Target_Loc, fl_main_damage[client]);	
	}
	
	return Plugin_Continue;
}
static void Get_Loc(int client, float Start_Loc[3], float Beam_Angles[3], float Target_Loc[3], float &Main_Beam_Dist)
{
	float Pos[3];
	GetClientEyePosition(client, Pos);
	float PosEffects[3];
	PosEffects = Pos;
	
	int viewmodelModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);

	bool HasWings = view_as<bool>(Store_HasNamedItem(client, "Magia Wings [???]"));	//note: redo the laser turning so its less choopy, also make it use ENV beams instead of Te
	
	if(IsValidEntity(viewmodelModel) && !HasWings)
	{
		float flAng[3];
		GetAttachment(viewmodelModel, "effect_hand_r", PosEffects, flAng);	
	}
	else
	{
		PosEffects[2] -= 35.0;
		Pos[2] -= 35.0;
	}

	Handle trace = TR_TraceRayFilterEx(Pos, Beam_Angles, 11, RayType_Infinite, Prismatic_TraceWallsOnly);
	TR_GetEndPosition(Target_Loc, trace);
	delete trace;
	Pos = PosEffects;
	
	ConformLineDistance(Target_Loc, Pos, Target_Loc, fl_main_range[client]);
	
	Main_Beam_Dist = GetVectorDistance(Pos, Target_Loc);
	
	if(Main_Beam_Dist>30.0)
	{
		Get_Fake_Forward_Vec(30.0, Beam_Angles, Start_Loc, Pos);	//make the beam origin not inside but a bit further away from the player
	}
	else
	{
		Get_Fake_Forward_Vec(Main_Beam_Dist, Beam_Angles, Start_Loc, Pos);	//make the beam origin not inside but a bit further away from the player
	}
}
static void Kill_Beam_Hook(int client, float time)
{
	fl_Neuvellete_Beam_Timeout[client] = GetGameTime()+time; 
		
	SDKUnhook(client, SDKHook_PreThink, Neuvellete_tick);
	b_special_active[client]=false;

	StopSound(client, SNDCHAN_STATIC, NEUVELLETE_MAIN_BEAM_SOUND);	//CEASE THY SOUND
	StopSound(client, SNDCHAN_STATIC, NEUVELLETE_MAIN_BEAM_SOUND);
	StopSound(client, SNDCHAN_STATIC, NEUVELLETE_MAIN_BEAM_SOUND);
	StopSound(client, SNDCHAN_STATIC, NEUVELLETE_MAIN_BEAM_SOUND);
	StopSound(client, SNDCHAN_STATIC, NEUVELLETE_MAIN_BEAM_SOUND);
	StopSound(client, SNDCHAN_STATIC, NEUVELLETE_MAIN_BEAM_SOUND);
}

static void Neuvellete_Base_Central_Beam(float Start_Loc[3], float Target_Loc[3])
{
	int r=1, g=255, b=255, a=75;
	float diameter = 40.0;
	int colorLayer4[4];  
	SetColorRGBA(colorLayer4, r, g, b, a);
	int colorLayer1[4];
	SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, a);
	
	TE_SetupBeamPoints(Start_Loc, Target_Loc, BeamWand_Laser, 0, 0, 66, NEUVELLETE_TE_DURATION, ClampBeamWidth(diameter * 0.7 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 1.25, colorLayer1, 15);
								
	TE_SendToAll(0.0);
	
	TE_SetupGlowSprite(Start_Loc, gGlow1, NEUVELLETE_TE_DURATION, 0.5, 255);
	TE_SendToAll(0.0);
	
	int glowColor[4];
	
	diameter /= 1.5;
	SetColorRGBA(glowColor, r, g, b, a);
	TE_SetupBeamPoints(Start_Loc, Target_Loc, BeamWand_Glow, 0, 0, 66, NEUVELLETE_TE_DURATION, ClampBeamWidth(diameter * 0.7 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 0.25, glowColor, -25);								
	TE_SendToAll(0.0);
}
static void Get_Fake_Forward_Vec(float Range, float vecAngles[3], float Vec_Target[3], float Pos[3])
{
	float Direction[3];
	
	GetAngleVectors(vecAngles, Direction, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(Direction, Range);
	AddVectors(Pos, Direction, Vec_Target);
}
static void Neuvellete_Create_Spinning_Beams(int client, float Origin[3], float Angles[3], int loop_for, float Main_Beam_Dist, bool Type=true, float distance_stuff, float ang_multi)
{
	
	float buffer_vec[10][3];
		
	for(int i=1 ; i<=loop_for ; i++)
	{	
		float tempAngles[3], Direction[3], endLoc[3], End_Loc[3];
		tempAngles[0] = Angles[0];
		tempAngles[1] = Angles[1];	//has to the same as the beam
		tempAngles[2] = (fl_spinning_angle[client]+((360.0/loop_for)*float(i)))*ang_multi;	//we use the roll angle vector to make it speeen
		
		if(tempAngles[2]>360.0)
			tempAngles[2] -= 360.0;
	
					
		GetAngleVectors(tempAngles, Direction, NULL_VECTOR, Direction);
		ScaleVector(Direction, distance_stuff);
		AddVectors(Origin, Direction, endLoc);
		
		buffer_vec[i] = endLoc;
		
		Get_Fake_Forward_Vec(Main_Beam_Dist, Angles, End_Loc, endLoc);
		
		if(Type)
		{
			int r=1, g=1, b=255, a=255;
			float diameter = 15.0;
			int colorLayer4[4];
			SetColorRGBA(colorLayer4, r, g, b, a);
			int colorLayer1[4];
			SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, a);
										
			TE_SetupBeamPoints(endLoc, End_Loc, BeamWand_Laser, 0, 0, 0, NEUVELLETE_TE_DURATION, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 0.25, colorLayer1, 3);
										
			if(!LastMann)
				TE_SendToClient(client);
			else
				TE_SendToAll();
		}
		
	}
	
	int color[4]; color[0] = 1; color[1] = 255; color[2] = 255; color[3] = 255;
	
	TE_SetupBeamPoints(buffer_vec[1], buffer_vec[loop_for], BeamWand_Laser, 0, 0, 0, NEUVELLETE_TE_DURATION, 5.0, 5.0, 0, 0.01, color, 3);	
	TE_SendToAll(0.0);
	for(int i=1 ; i<loop_for ; i++)
	{
		TE_SetupBeamPoints(buffer_vec[i], buffer_vec[i+1], BeamWand_Laser, 0, 0, 0, NEUVELLETE_TE_DURATION, 5.0, 5.0, 0, 0.01, color, 3);	
		TE_SendToAll(0.0);
	}
	
}
/*
static void Neuvellete_Create_Spinning_Beams_ALT_ALT(int client, float Origin[3], float Angles[3], int loop_for, float Main_Beam_Dist, float Cycle_Speed)
{
	float GameTime = GetGameTime();
	
	
	if(fl_extra_effects_timer[client] < GameTime)
	{
		fl_extra_effects_timer[client] = GameTime + Cycle_Speed;
	}
	
	float Duration = fl_extra_effects_timer[client] - GameTime;
	
	float Range_Current = Main_Beam_Dist - (Main_Beam_Dist * (Duration / Cycle_Speed));
	if(Range_Current<1.0)
		Range_Current = 1.0;
		
	for(int i=1 ; i<=loop_for ; i++)
	{	
		float tempAngles[3], Direction[3], endLoc[3], End_Loc[3];
		tempAngles[0] =	Angles[0];
		tempAngles[1] = Angles[1];	//has to the same as the beam
		tempAngles[2] = fl_spinning_angle[client]+((360.0/loop_for)*float(i));	//we use the roll angle vector to make it speeen
		
		if(tempAngles[2]>360.0)
			tempAngles[2] -= 360.0;
	
		
		Get_Fake_Forward_Vec(Range_Current, Angles, End_Loc, Origin);
		
		GetAngleVectors(tempAngles, Direction, NULL_VECTOR, Direction);
		ScaleVector(Direction, 40.0);
		AddVectors(End_Loc, Direction, endLoc);
			
			
		int r=1, g=1, b=255, a=255;
		float diameter = 15.0;
		int colorLayer4[4];
		SetColorRGBA(colorLayer4, r, g, b, a);
		int colorLayer1[4];
		SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, a);
									
		TE_SetupBeamPoints(endLoc, End_Loc, BeamWand_Laser, 0, 0, 0, NEUVELLETE_TE_DURATION, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 2.5, colorLayer1, 3);
									
		if(!LastMann)
			TE_SendToClient(client);
		else
			TE_SendToAll();
		
		
	}
	
}*/
static void Prismatic_Damage_Trace(int client, float playerPos[3], float endVec_2[3], float damage)
{
	static float hullMin[3];
	static float hullMax[3];

	Zero(Prismatic_TargetHit);
	
	hullMin[0] = -25.0;
	hullMin[1] = hullMin[0];
	hullMin[2] = hullMin[0];
	hullMax[0] = -hullMin[0];
	hullMax[1] = -hullMin[1];
	hullMax[2] = -hullMin[2];
	b_LagCompNPC_No_Layers = true;
	StartLagCompensation_Base_Boss(client);
	Handle trace;
	trace = TR_TraceHullFilterEx(playerPos, endVec_2, hullMin, hullMax, 1073741824, BEAM_TraceUsers, client);	// 1073741824 is CONTENTS_LADDER?
	delete trace;
	FinishLagCompensation_Base_boss();
	
	float vecForward[3];
	float vecAngles[3];
	GetAngleVectors(vecAngles, vecForward, NULL_VECTOR, NULL_VECTOR);

	float BEAM_Targets_Hit = 1.0;

	int weapon_active = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon_active > 0)
	{
		for (int building = 0; building < i_Neuvellete_penetration[client]; building++)
		{
			int Victim = Prismatic_TargetHit[building];
			if(Victim)
			{
				if(IsValidEntity(Victim))
				{
					float trg_loc[3];
					WorldSpaceCenter(Victim, trg_loc);
					
					float damage_force[3]; CalculateDamageForce(vecForward, 10000.0, damage_force);
					SDKHooks_TakeDamage(Victim, client, client, damage*BEAM_Targets_Hit, DMG_PLASMA, weapon_active, damage_force);
					
					BEAM_Targets_Hit *= fl_penetration_falloff[client];
				}
			}
		}
	}
}

static bool BEAM_TraceUsers(int entity, int contentsMask, int client)
{
	if (IsValidEntity(entity))
	{
		entity = Target_Hit_Wand_Detection(client, entity);
		if(0 < entity)
		{
			for(int i=1; i <= (i_Neuvellete_penetration[client] -1 ); i++)
			{
				if(!Prismatic_TargetHit[i])
				{
					Prismatic_TargetHit[i] = entity;
					break;
				}
			}
		}
	}
	return false;
}
static bool Prismatic_TraceWallsOnly(int entity, int contentsMask)
{
	return !entity;
}

public void Neuvellete_Menu(int client, int weapon)
{	
	if(!IsValidClient(client))
		return;
		
	Menu menu2 = new Menu(Neuvellete_Menu_Selection);
	int flags = i_Neuvellete_HEX_Array[client];
	
	if(i_Neuvellete_Skill_Points[client]>0)
	{
		menu2.SetTitle("%t", "Neuvellete Menu First", i_Neuvellete_Skill_Points[client]);
		
		switch(i_skill_point_used[client]+1)
		{
			case 1:
			{
				char buffer[255];
				FormatEx(buffer, sizeof(buffer), "%t", "Neuvellete dmg");
				menu2.AddItem("1", buffer);
				
				FormatEx(buffer, sizeof(buffer), "%t", "Neuvellete Turn");
				menu2.AddItem("2", buffer);
				
				FormatEx(buffer, sizeof(buffer), "%t", "Neuvellete Mana");
				menu2.AddItem("3", buffer);
			}
			case 2:
			{
				char buffer[255];
				FormatEx(buffer, sizeof(buffer), "%t", "Neuvellete dmg");
				menu2.AddItem("1", buffer);
				
				FormatEx(buffer, sizeof(buffer), "%t", "Neuvellete Range");
				menu2.AddItem("2", buffer);
				
				FormatEx(buffer, sizeof(buffer), "%t", "Neuvellete Pen");
				menu2.AddItem("3", buffer);
			}
			case 3:
			{
				char buffer[255];
				FormatEx(buffer, sizeof(buffer), "%t", "Neuvellete PenFallOff");
				menu2.AddItem("1", buffer);
				
				FormatEx(buffer, sizeof(buffer), "%t", "Neuvellete Turn");
				menu2.AddItem("2", buffer);
				
				FormatEx(buffer, sizeof(buffer), "%t", "Neuvellete Range");
				menu2.AddItem("3", buffer);
			}
			case 4:
			{
				char buffer[255];
				FormatEx(buffer, sizeof(buffer), "%t", "Neuvellete Pen");
				menu2.AddItem("1", buffer);
				
				FormatEx(buffer, sizeof(buffer), "%t", "Neuvellete Turn");
				menu2.AddItem("2", buffer);
				
				FormatEx(buffer, sizeof(buffer), "%t", "Neuvellete Mana");
				menu2.AddItem("3", buffer);
			}
			//"Neuvellete Overclock Info"
			//"Neuvellete Pulse"
			//"Neuvellete Nightmare"
			//"Neuvellete Feedback"
		}
	}
	else
	{
		if(i_skill_point_used[client]!=0)
		{
			menu2.SetTitle("%t", "Neuvellete Menu Third");
			
			char buffer[255];
			
			FormatEx(buffer, sizeof(buffer), "%t", "Neuvellete pap0");
			menu2.AddItem("4", buffer, ITEMDRAW_DISABLED);
			
			if(flags & FLAG_NEUVELLETE_PAP_1_DMG)
			{
				FormatEx(buffer, sizeof(buffer), "%t", "Neuvellete dmg");
				menu2.AddItem("4", buffer, ITEMDRAW_DISABLED);
			}
			if(flags & FLAG_NEUVELLETE_PAP_1_TURNRATE)
			{
				FormatEx(buffer, sizeof(buffer), "%t", "Neuvellete Turn");
				menu2.AddItem("4", buffer, ITEMDRAW_DISABLED);
				
			}
			if(flags & FLAG_NEUVELLETE_PAP_1_MANA_EFFICIENCY)
			{
				FormatEx(buffer, sizeof(buffer), "%t", "Neuvellete Mana");
				menu2.AddItem("4", buffer, ITEMDRAW_DISABLED);
			}
			
			if(i_skill_point_used[client]>=2)
			{
				
				FormatEx(buffer, sizeof(buffer), "%t", "Neuvellete pap1");
				menu2.AddItem("4", buffer, ITEMDRAW_DISABLED);
				if(flags & FLAG_NEUVELLETE_PAP_2_DMG)
				{
					FormatEx(buffer, sizeof(buffer), "%t", "Neuvellete dmg");
					menu2.AddItem("4", buffer, ITEMDRAW_DISABLED);
				}
				if(flags & FLAG_NEUVELLETE_PAP_2_PENETRATION)
				{
					FormatEx(buffer, sizeof(buffer), "%t", "Neuvellete Pen");
					menu2.AddItem("4", buffer, ITEMDRAW_DISABLED);
				}
				if(flags & FLAG_NEUVELLETE_PAP_2_RANGE)
				{
					FormatEx(buffer, sizeof(buffer), "%t", "Neuvellete Range");
					menu2.AddItem("4", buffer, ITEMDRAW_DISABLED);
				}
				
				if(i_skill_point_used[client]>=3)
				{
					FormatEx(buffer, sizeof(buffer), "%t", "Neuvellete pap2");
					menu2.AddItem("4", buffer, ITEMDRAW_DISABLED);
					if(flags & FLAG_NEUVELLETE_PAP_3_RANGE)
					{
						FormatEx(buffer, sizeof(buffer), "%t", "Neuvellete Range");
						menu2.AddItem("4", buffer, ITEMDRAW_DISABLED);
					}
					if(flags & FLAG_NEUVELLETE_PAP_3_PENETRATION_FALLOFF)
					{
						FormatEx(buffer, sizeof(buffer), "%t", "Neuvellete PenFallOff");
						menu2.AddItem("4", buffer, ITEMDRAW_DISABLED);
					}
					if(flags & FLAG_NEUVELLETE_PAP_3_TURNRATE)
					{
						FormatEx(buffer, sizeof(buffer), "%t", "Neuvellete Turn");
						menu2.AddItem("4", buffer, ITEMDRAW_DISABLED);
					}
					
					if(i_skill_point_used[client]>=4)
					{
						FormatEx(buffer, sizeof(buffer), "%t", "Neuvellete pap3");
						menu2.AddItem("4", buffer, ITEMDRAW_DISABLED);
						if(flags & FLAG_NEUVELLETE_PAP_4_TURNRATE)
						{
							FormatEx(buffer, sizeof(buffer), "%t", "Neuvellete Turn");
							menu2.AddItem("4", buffer, ITEMDRAW_DISABLED);
						}
						if(flags & FLAG_NEUVELLETE_PAP_4_PENETRATION)
						{
							FormatEx(buffer, sizeof(buffer), "%t", "Neuvellete Pen");
							menu2.AddItem("4", buffer, ITEMDRAW_DISABLED);
						}
						if(flags & FLAG_NEUVELLETE_PAP_4_MANA_EFFICIENCY)
						{
							FormatEx(buffer, sizeof(buffer), "%t", "Neuvellete Mana");
							menu2.AddItem("4", buffer, ITEMDRAW_DISABLED);
						}
					}
				}
			}
		}
	}
	
	
	menu2.Display(client, MENU_TIME_FOREVER); // they have 3 seconds.
	
}

static int Neuvellete_Menu_Selection(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Select:
		{
			char buffer[24];
			menu.GetItem(choice, buffer, sizeof(buffer));
			int id = StringToInt(buffer);
			
			if(id==4)
			{
				return 0;	//do nothing
			}
			
			i_Neuvellete_Skill_Points[client]--;
			
			switch(i_skill_point_used[client]+1)
			{
				case 1:
				{
					switch(id)
					{
						case 1:
						{
							i_Neuvellete_HEX_Array[client] |= FLAG_NEUVELLETE_PAP_1_DMG;
						}
						case 2:
						{
							i_Neuvellete_HEX_Array[client] |= FLAG_NEUVELLETE_PAP_1_TURNRATE;
						}
						case 3:
						{
							i_Neuvellete_HEX_Array[client] |= FLAG_NEUVELLETE_PAP_1_MANA_EFFICIENCY;
						}
					}
				}
				case 2:
				{
					switch(id)
					{
						case 1:
						{
							i_Neuvellete_HEX_Array[client] |= FLAG_NEUVELLETE_PAP_2_DMG;
						}
						case 2:
						{
							i_Neuvellete_HEX_Array[client] |= FLAG_NEUVELLETE_PAP_2_RANGE;
						}
						case 3:
						{
							i_Neuvellete_HEX_Array[client] |= FLAG_NEUVELLETE_PAP_2_PENETRATION;
						}
					}
				}
				case 3:
				{
					switch(id)
					{
						case 1:
						{
							i_Neuvellete_HEX_Array[client] |= FLAG_NEUVELLETE_PAP_3_PENETRATION_FALLOFF;
						}
						case 2:
						{
							i_Neuvellete_HEX_Array[client] |= FLAG_NEUVELLETE_PAP_3_TURNRATE;
						}
						case 3:
						{
							i_Neuvellete_HEX_Array[client] |= FLAG_NEUVELLETE_PAP_3_RANGE;
						}
					}
				}
				case 4:
				{
					switch(id)
					{
						case 1:
						{
							i_Neuvellete_HEX_Array[client] |= FLAG_NEUVELLETE_PAP_4_PENETRATION;
						}
						case 2:
						{
							i_Neuvellete_HEX_Array[client] |= FLAG_NEUVELLETE_PAP_4_TURNRATE;
						}
						case 3:
						{
							i_Neuvellete_HEX_Array[client] |= FLAG_NEUVELLETE_PAP_4_MANA_EFFICIENCY;
						}
					}
				}
			}
			i_skill_point_used[client]++;
		}
	}
	return 0;	//do nothing
}
stock void Movement_Laser_Logic(float Beam_Angles[3], float Input_Beam_Angles[2], float Angles[3], float Turn_Speed, float Pitch_Speed, float &Spin_angle, float Ratio_Max=-1.0, float Ratio_Min=-1.0, float Baseline=180.0)	
{
	float travel_distance = Input_Beam_Angles[0] - Angles[1];
	float travel_distance_pitch = Input_Beam_Angles[1] - Angles[0];
	
	
	if(travel_distance<180.0 && -180.0<travel_distance)	//travel distance is less then 180.0 we do it normaly
	{
		
		if(Ratio_Max!=-1.0 || Ratio_Min!=-1.0)
		{
			float Speed_Multi = abs(RoundToFloor(travel_distance))/Baseline;

			if(Ratio_Max!=-1.0)
				if(Speed_Multi>Ratio_Max)
					Speed_Multi=Ratio_Max;
			
			if(Ratio_Min!=-1.0)
				if(Speed_Multi<Ratio_Min)
					Speed_Multi=Ratio_Min;

			Turn_Speed *=Speed_Multi;
			Spin_angle *=Speed_Multi;
		}

		
		bool turned = false;
		if(travel_distance>Turn_Speed)		
		{
			Input_Beam_Angles[0] -= Turn_Speed;
			turned=true;
		}
		else if(travel_distance < Turn_Speed*-1.0)
		{
			Spin_angle *=-1.0;
			Input_Beam_Angles[0] += Turn_Speed;
			turned=true;
		}
		
		if(abs(RoundFloat(travel_distance)) < Turn_Speed && !turned && abs(RoundFloat(travel_distance))>0)
		{
			float travel_amt = travel_distance/Turn_Speed;
			Input_Beam_Angles[0] += travel_amt;
			Spin_angle*=travel_amt;
		}
		else if(!turned)
		{
			int amt = abs(RoundToFloor(travel_distance));
			if(amt==0 || amt<2)
			{
				Spin_angle=0.0;
			}
			else
			{
				float travel_amt = travel_distance/Turn_Speed;
				if(travel_amt>0.1 || travel_amt <-0.1)
				{
					Spin_angle*=travel_amt;
					Input_Beam_Angles[0] += travel_amt;
				}
			}
		}	
	}
	else	//otherwise we invert
	{
		if(Ratio_Max!=-1.0 || Ratio_Min!=-1.0)
		{
			float Speed_Multi = (360.0-abs(RoundToFloor(travel_distance)))/Baseline;

			if(Ratio_Max!=-1.0)
				if(Speed_Multi>Ratio_Max)
					Speed_Multi=Ratio_Max;
			
			if(Ratio_Min!=-1.0)
				if(Speed_Multi<Ratio_Min)
					Speed_Multi=Ratio_Min;

			Turn_Speed *=Speed_Multi;
			Spin_angle *=Speed_Multi;
		}

		if(travel_distance>0.5)		
		{
			Input_Beam_Angles[0] += Turn_Speed;
			Spin_angle *=-1.0;
		}
		else if(travel_distance < -0.5)
		{		
			Input_Beam_Angles[0] -= Turn_Speed;
		}
	}
	
	if(travel_distance_pitch<90.0 && -90.0<travel_distance_pitch)	//unlike YAW pitch should be pretty easy to do
	{
		if(travel_distance_pitch>Pitch_Speed)		
		{
			Input_Beam_Angles[1] -= Pitch_Speed;
		}
		else if(travel_distance_pitch < Pitch_Speed*-1.0)
		{
			Input_Beam_Angles[1] += Pitch_Speed;
		}
		
		if(travel_distance_pitch<Pitch_Speed && travel_distance_pitch>0.1)			//finetune control
		{
			Input_Beam_Angles[1] -= 0.1;
		}
		else if(travel_distance_pitch > Pitch_Speed*-1.0 && travel_distance_pitch<-0.1)
		{
			Input_Beam_Angles[1] += 0.1;
		}
	}
	
	if(Input_Beam_Angles[0]>180.0)
		Input_Beam_Angles[0] = -180.0;
		
	if(Input_Beam_Angles[0]<-180.0)
		Input_Beam_Angles[0] = 180.0;
	
		
	Beam_Angles[0] = Input_Beam_Angles[1]; Beam_Angles[2] = 0.0; Beam_Angles[1] = Input_Beam_Angles[0];
		
		
}

static void spawnRing_Vector(float center[3], float range, float modif_X, float modif_Y, float modif_Z, char sprite[255], int r, int g, int b, int alpha, int fps, float life, float width, float amp, int speed, float endRange = -69.0) //Spawns a TE beam ring at a client's/entity's location
{
	center[0] += modif_X;
	center[1] += modif_Y;
	center[2] += modif_Z;
	
	int ICE_INT = PrecacheModel(sprite);
	
	int color[4];
	color[0] = r;
	color[1] = g;
	color[2] = b;
	color[3] = alpha;
	
	if (endRange == -69.0)
	{
		endRange = range + 0.5;
	}
	
	TE_SetupBeamRingPoint(center, range, endRange, ICE_INT, ICE_INT, 0, fps, life, width, amp, color, speed, 0);
	TE_SendToAll();
}

/*
"Neuv"
			{
				"cost"		"1"
				"desc"		"Neuv pap0"
				"tags"		"medieval"
				
				"classname"	"tf_weapon_bonesaw"
				"index"		"173"
				"attributes"	"1 ; 0 ; 410 ; 1.0 ; 264 ; 0 ; 733 ; 10 ; 122 ; 0" 
				
				"func_onbuy"	"Ion_Beam_On_Buy_Reset"
				
				// 410 = % increased wand dmg
				// 733 = Mana cost
				
				"tier"		"0"
				"rarity"	"1"
				"model_weapon_override"					"models/empty.mdl"
				
				"func_attack"	"Weapon_Ion_Wand_Beam"
				
				"is_a_wand"		"1"
				
				"lag_comp" 						"0"
				"lag_comp_collision" 		"0"
				"lag_comp_extend_boundingbox" 		"0"
				"lag_comp_dont_move_building" 	"1"
				"weapon_archetype"	"26"
				"int_ability_onequip"	"56"
				
				"pap_1_desc"		"Neuv pap1"
				
				"pap_1_cost"			"2550"
				"pap_1_classname"		"tf_weapon_bonesaw"
				"pap_1_index"			"173"
				"pap_1_attributes"	"1 ; 0 ; 410 ; 1.2 ; 264 ; 0 ; 733 ; 10 ; 122 ; 1" 
				
				"pap_1_func_attack"	"Weapon_Ion_Wand_Beam"
				"pap_1_model_weapon_override"					"models/empty.mdl"
				
				"pap_1_lag_comp" 						"0"
				"pap_1_lag_comp_collision" 		"0"
				"pap_1_lag_comp_extend_boundingbox" 		"0"
				"pap_1_lag_comp_dont_move_building" 	"1"
				
				"pap_1_is_a_wand"		"1"
				"pap_1_weapon_archetype"	"26"
				"pap_1_int_ability_onequip"	"56"
				
				"pap_2_desc"		"Neuv pap2"
				
				"pap_2_cost"			"3300"
				"pap_2_classname"		"tf_weapon_bonesaw"
				"pap_2_index"			"173"
				"pap_2_attributes"	"1 ; 0 ; 410 ; 1.4 ; 264 ; 0 ; 733 ; 10 ; 122 ; 2" 
				
				"pap_2_func_attack"	"Weapon_Ion_Wand_Beam"
				
				"pap_2_lag_comp" 						"0"
				"pap_2_lag_comp_collision" 		"0"
				"pap_2_lag_comp_extend_boundingbox" 		"0"
				"pap_2_lag_comp_dont_move_building" 	"1"
				
				"pap_2_is_a_wand"		"1"
				"pap_2_weapon_archetype"	"26"
				"pap_2_int_ability_onequip"	"56"
				"pap_2_model_weapon_override"					"models/empty.mdl"
				
				"pap_3_desc"		"Neuv pap3"
				
				"pap_3_cost"			"4000"
				"pap_3_classname"		"tf_weapon_bonesaw"
				"pap_3_index"			"173"
				"pap_3_attributes"	"1 ; 0 ; 410 ; 1.6 ; 264 ; 0 ; 733 ; 10 ; 122 ; 3" 
				
				"pap_3_func_attack"	"Weapon_Ion_Wand_Beam"
				
				"pap_3_lag_comp" 						"0"
				"pap_3_lag_comp_collision" 		"0"
				"pap_3_lag_comp_extend_boundingbox" 		"0"
				"pap_3_lag_comp_dont_move_building" 	"1"
				
				"pap_3_is_a_wand"		"1"
				"pap_3_weapon_archetype"	"26"
				"pap_3_int_ability_onequip"	"56"
				"pap_3_model_weapon_override"					"models/empty.mdl"
				
				"pap_4_desc"		"Neuv pap4"
				
				"pap_4_func_attack"	"Weapon_Ion_Wand_Beam"
				
				"pap_4_cost"			"5000"
				"pap_4_classname"		"tf_weapon_bonesaw"
				"pap_4_index"			"173"
				"pap_4_attributes"	"1 ; 0 ; 410 ; 1.8 ; 264 ; 0 ; 733 ; 10 ; 122 ; 4" 
				
				"pap_4_lag_comp" 						"0"
				"pap_4_lag_comp_collision" 		"0"
				"pap_4_lag_comp_extend_boundingbox" 		"0"
				"pap_4_lag_comp_dont_move_building" 	"1"
				
				"pap_4_is_a_wand"		"1"
				"pap_4_weapon_archetype"	"26"
				"pap_4_int_ability_onequip"	"56"
				"pap_4_model_weapon_override"					"models/empty.mdl"
				
				"pap_5_desc"		"Neuv pap5"
				
				"pap_5_cost"			"5000"
				"pap_5_classname"		"tf_weapon_bonesaw"
				"pap_5_index"			"173"
				"pap_5_attributes"	"1 ; 0 ; 410 ; 2.0 ; 264 ; 0 ; 733 ; 10 ; 122 ; 5" 
				
				"pap_5_func_attack"	"Weapon_Ion_Wand_Beam"
				
				"pap_5_lag_comp" 						"0"
				"pap_5_lag_comp_collision" 		"0"
				"pap_5_lag_comp_extend_boundingbox" 		"0"
				"pap_5_lag_comp_dont_move_building" 	"1"
				
				"pap_5_is_a_wand"		"1"
				"pap_5_weapon_archetype"	"26"
				"pap_5_int_ability_onequip"	"56"
				"pap_5_model_weapon_override"					"models/empty.mdl"
				
			}
*/

/*
    |cos θ   −sin θ   0| |x|   |x cos θ − y sin θ|   |x'|
    |sin θ    cos θ   0| |y| = |x sin θ + y cos θ| = |y'|
    |  0       0      1| |z|   |        z        |   |z'|
*/
/*
void RotateVectorViaAngleVector(float AngleVector[3], float SpaceVector[3])
{
	// X Axis
}*/