#pragma semicolon 1
#pragma newdecls required

//A alternate pap path for the beam wand.
//Also I genuinely couldn't find a good name for this

/*

	Pap 1. hold m1 to fire a constant beam 
	
	pap 2. press m2 to alternate from a constant beam to a burst beam. 
	Particle Beam
	Particle Cannon
*/

static int i_cannon_charge[MAXPLAYERS];
static int i_original_weapon_ID[MAXPLAYERS];
static float f_attack_timer[MAXPLAYERS];
static int i_weapon_pap_tier[MAXPLAYERS];
static int i_mana_cost_base[MAXPLAYERS];


static bool bl_particle_type[MAXPLAYERS];
static bool bl_alternate[MAXPLAYERS];
static bool bl_overdrive_beam[MAXPLAYERS];
static bool bl_orbtial_cannon[MAXPLAYERS];
static bool bl_sound_active[MAXPLAYERS];

#define BEAM_WAND_BEAM_SOUND "npc/combine_gunship/dropship_engine_distant_loop1.wav"	//"weapons/physcannon/energy_sing_loop4.wav"
#define BEAM_WAND_OVERDRIVE_CHARGEUP_SOUND	"npc/attack_helicopter/aheli_charge_up.wav"
#define BEAM_WAND_OVERDRIVE_CHARGEUP_END_SOUND "npc/scanner/cbot_energyexplosion1.wav"

#define BEAN_WAND_PARTICLE_CANNON_SOUND	"npc/combine_gunship/attack_stop2.wav"
#define BEAM_WAND_PARTICLE_ORBITAL_CANNON_CHARGEUP_SOUND "misc/halloween/hwn_plumes_capture.wav"	//"freak_fortress_2/bvb_kapdok_duo/doktor/moonlight_activate.mp3"
#define BEAM_WAND_PARTICLE_ORBITAL_CANNON_FIRE_SOUND "misc/halloween/spell_meteor_impact.wav"	//"freak_fortress_2/bvb_kapdok_duo/doktor/psychic_blast.mp3"

#define BEAM_WAND_PAP_ALT_TRACE_DELAY 0.1	//does a trace 10 times a second!


//Configute base stats here.


//beam, 1=pap1, 2=pap2.

#define BEAM_WAND_BEAM_MANA_MULTI 0.05			//By how much is the mana cost multiplied by, the mana is consumed quite rapidly due to it happening really really fast
#define BEAM_WAND_BEAM_DAMAGE_MULTI	0.04		//by how much the damage is multiplied by, same reason as above
#define BEAM_WAND_BEAM_OVERDRIVE_DURATION 5.0
#define BEAM_WAND_BEAM_OVERDRIVE_COUNT 6		//this is *mostly* visual, however it does affect the delay by making it slightly less
#define BEAM_WAND_BEAM_OVERDRIVE_CHARGEUP 1.15	//relative to sound

static float f_beam_delay[3] = { 0.0, 0.25, 0.1 };						//delay in seconds per each singular shot
static float fl_beam_overdrive_dmg_multi[3] = { 0.0, 1.2, 1.3};		//by how much the damage is multiplied during overdrive. beware this thing if given the chance CAN and WILL do more damage in its duration than the orbital strike
static float fl_beam_overdrive_cost[3] = { 0.0, 4000.0, 3000.0};	//how much mana has to be consumed WHILE dealing damage to activate the ability. this can be triggered by multiple npc's at the same time. aka shooting 1 npc slow gain, shooting 10 npc, fast gain
static float fl_beam_range[3] = { 0.0, 1500.0, 1800.0 };			//range of the beam wand
static float fl_beam_overdrive_damage[MAXPLAYERS];

//cannon.

#define BEAM_WAND_CANNON_DELAY	0.75			//delay in seconds per each singular shot
#define BEAM_WAND_CANNON_RANGE	2000.0			//range of primary cannon fire	//cannon has 5k range
#define BEAM_WAND_CANNON_DMG_MULTI	1.0

#define BEAM_WAND_CANNON_ABILITY_COST	34		//34 shots needed to charge ability.
#define BEAM_WAND_CANNON_ABILITY_DMG_MULTI	10.0	//by how much the damage is multiplied for the ability
#define BEAM_WAND_CANNON_ABILITY_DELAY	5.0		//how long for the cannon ability to "charge" until it deals damage. in seconds. oh also if you change it, beware the sound probably won't match up
#define BEAM_WAND_CANNON_ABILITY_RANGE	125.0	//Range of the explosion.


static float fl_hud_delay[MAXPLAYERS];
static float fl_effect_throttle[MAXPLAYERS];
static float fl_laser_edge_vec[MAXPLAYERS][BEAM_WAND_BEAM_OVERDRIVE_COUNT+3][3];
static float fl_last_known_vec[MAXPLAYERS][3];
static float fl_trace_delay[MAXPLAYERS];
static float fl_chargup_duration[MAXPLAYERS];
static float fl_mana_consumed_recent[MAXPLAYERS];
static float fl_beam_overdrive_charge[MAXPLAYERS];
static float fl_ability_duration[MAXPLAYERS];
static float fl_angle[MAXPLAYERS];
static float fl_oribtal_cannon_vec[MAXPLAYERS][3][3];
static float fl_mana_timeout[MAXPLAYERS];


static int BeamWand_Laser;
static int BeamWand_Glow;

static char gGlow1;
static char gExplosive1;
static char gLaser2;

#define MAX_BEAMWAND_TARGETS_HIT 5

void Beam_Wand_Pap_OnMapStart()
{
	Zero(i_original_weapon_ID);
	Zero(bl_particle_type);
	Zero(f_attack_timer);
	Zero(fl_hud_delay);
	Zero(fl_effect_throttle);
	Zero(i_weapon_pap_tier);
	Zero2(fl_last_known_vec);
	Zero(fl_trace_delay);
	Zero(bl_alternate);
	Zero(bl_overdrive_beam);
	Zero(bl_sound_active);
	Zero(bl_orbtial_cannon);
	Zero(fl_chargup_duration);
	Zero(i_cannon_charge);
	Zero(fl_mana_consumed_recent);
	Zero(fl_beam_overdrive_charge);
	Zero(fl_mana_timeout);
	gLaser2= PrecacheModel("materials/sprites/laserbeam.vmt");
	PrecacheModel("materials/sprites/laserbeam.vmt");
	BeamWand_Laser = PrecacheModel("materials/sprites/laser.vmt", false);
	BeamWand_Glow = PrecacheModel("sprites/glow02.vmt", true);
	gGlow1 = PrecacheModel("sprites/blueglow2.vmt", true);
	PrecacheSound(BEAM_WAND_BEAM_SOUND);
	PrecacheSound(BEAM_WAND_OVERDRIVE_CHARGEUP_SOUND);
	PrecacheSound(BEAM_WAND_OVERDRIVE_CHARGEUP_END_SOUND); 
	
	PrecacheSound(BEAN_WAND_PARTICLE_CANNON_SOUND);
	PrecacheSound(BEAM_WAND_PARTICLE_ORBITAL_CANNON_CHARGEUP_SOUND);
	PrecacheSound(BEAM_WAND_PARTICLE_ORBITAL_CANNON_FIRE_SOUND);
}

public void Npc_OnTakeDamage_BeamWand_Pap(int client, int dmg_type)
{
	if(dmg_type & DMG_PLASMA && !bl_overdrive_beam[client])
	{
		if(bl_particle_type[client])	//cannon
		{
			if(BEAM_WAND_CANNON_ABILITY_COST>=i_cannon_charge[client])
			{
				i_cannon_charge[client]++;
			}
		}
		else	//default false, beam
		{
			if(fl_beam_overdrive_cost[i_weapon_pap_tier[client]]>=fl_beam_overdrive_charge[client])
			{
				fl_beam_overdrive_charge[client] += fl_mana_consumed_recent[client];
			}
		}
	}
}

public void Activate_Beam_Wand_Pap(int client, int weapon)
{
	//CPrintToChatAll("Atempting hook");
	
	
	
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_BEAM_PAP)	//is it OUR weapon?
	{
		//CPrintToChatAll("Hooked!");
		bl_particle_type[client] = false;
		bl_overdrive_beam[client] = false;
		bl_orbtial_cannon[client] = false;
		i_original_weapon_ID[client] = weapon;
		
		SDKUnhook(client, SDKHook_PreThink, Beam_Wand_pap_Tick);
		
		int pap;

		pap = RoundFloat(Attributes_Get(weapon, 122, 1.0));

		fl_effect_throttle[client] = 0.0;
		f_attack_timer[client] = 0.0;

		int mana_cost;
		mana_cost = RoundFloat(Attributes_Get(weapon, 733, 1.0));
		mana_cost = RoundToNearest(float(mana_cost) * LaserWeapons_ReturnManaCost(weapon));
			
		i_mana_cost_base[client] = mana_cost;	//as far as I am aware there are no effects currently that can affect a weapons mana cost realtime, so rather than getting the attribute every time the weapon fires, we only need to get it if a refresh happens
		i_weapon_pap_tier[client] = pap;
				
		SDKHook(client, SDKHook_PreThink, Beam_Wand_pap_Tick);
	}
	else //no? well bye!
	{
		//CPrintToChatAll("Not Beam");
	}
}

public void Weapon_Wand_Beam_Alt_Pap_M2(int client, int weapon, bool crit)
{
	if(bl_overdrive_beam[client] || bl_orbtial_cannon[client])
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		if(bl_overdrive_beam[client])
		{
			ShowSyncHudText(client,  SyncHud_Notifaction, "Overdrive Active! Ability blocked");
		}
		else
		{
			ShowSyncHudText(client,  SyncHud_Notifaction, "Orbital Cannon Active! Ability blocked");
		}
		return;
	}
	float duration;
	if(bl_particle_type[client])
	{
		if(i_cannon_charge[client]>=BEAM_WAND_CANNON_ABILITY_COST || CvarInfiniteCash.BoolValue)
		{
			Rogue_OnAbilityUse(client, weapon);
			i_cannon_charge[client] = 0;
			Kill_Sound(client);
			bl_orbtial_cannon[client] = true;
			duration = BEAM_WAND_CANNON_ABILITY_DELAY;
			fl_oribtal_cannon_vec[client][1] = fl_last_known_vec[client];
			fl_oribtal_cannon_vec[client][2] = fl_last_known_vec[client];
			EmitSoundToAll(BEAM_WAND_PARTICLE_ORBITAL_CANNON_CHARGEUP_SOUND, client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL);
		}
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "Your Weapon is not charged enough.");
			return;
		}
	}
	else
	{
		if(fl_beam_overdrive_cost[i_weapon_pap_tier[client]]<=fl_beam_overdrive_charge[client] || CvarInfiniteCash.BoolValue)
		{		
			Rogue_OnAbilityUse(client, weapon);
			duration = BEAM_WAND_BEAM_OVERDRIVE_DURATION+BEAM_WAND_BEAM_OVERDRIVE_CHARGEUP;
			
			Kill_Sound(client);
			
			bl_overdrive_beam[client] = true;
			fl_chargup_duration[client] = GetGameTime()+BEAM_WAND_BEAM_OVERDRIVE_CHARGEUP;
			
			EmitSoundToClient(client,BEAM_WAND_OVERDRIVE_CHARGEUP_SOUND,_, SNDCHAN_STATIC, 100, _, 1.0, 125);
			EmitSoundToClient(client,BEAM_WAND_OVERDRIVE_CHARGEUP_SOUND,_, SNDCHAN_STATIC, 100, _, 1.0, 125);
			
			fl_beam_overdrive_charge[client] = 0.0;
		}
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "Your Weapon is not charged enough.");
			return;
		}
	}
	
	Mana_Regen_Delay[client] = GetGameTime() + duration; //stopp mana regen for duration of ability
	fl_ability_duration[client] =GetGameTime() + duration;
}

public void Weapon_Wand_Beam_Alt_Pap_R(int client, int weapon, bool crit)
{
	if(bl_overdrive_beam[client] || bl_orbtial_cannon[client])
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		if(bl_overdrive_beam[client])
		{
			ShowSyncHudText(client,  SyncHud_Notifaction, "Overdrive Active! Ability blocked");
		}
		else
		{
			ShowSyncHudText(client,  SyncHud_Notifaction, "Orbital Cannon Active! Ability blocked");
		}
		return;
	}
	Kill_Sound(client);
	if(bl_particle_type[client])
	{
		bl_particle_type[client] = false;
	}
	else
	{
		bl_particle_type[client] = true;
	}
}

public Action Beam_Wand_pap_Tick(int client)
{	
	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	int weapon = i_original_weapon_ID[client];
	

	if(IsValidEntity(weapon))
	{

		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_BEAM_PAP)	//this loop will work if the holder doesn't have it in there hands, but they have it bought
		{

			if(weapon_holding==weapon)	//is it OUR weapon again?
			{
				
				float gametime = GetGameTime();
				
				float  ability_duration_remain;
				
				bool FIRE = false;
				
				if(bl_overdrive_beam[client] || bl_orbtial_cannon[client])
				{
					if(fl_ability_duration[client]<=gametime)
					{
						if(bl_orbtial_cannon[client])
						{
							FIRE = true;
						}
						bl_overdrive_beam[client] = false;
						bl_orbtial_cannon[client] = false;
					}
					else
					{
						ability_duration_remain = fl_ability_duration[client] - gametime;
					}
				}
				
				int colour[4];
					
				int manacost;
				if(bl_particle_type[client])
				{
					colour[0]=150;
					colour[1]=150;
					colour[2]=255;
					colour[3]=150;
					manacost = i_mana_cost_base[client];
				}
				else	//default false.
				{
					if(bl_overdrive_beam[client])
					{
						colour[0]=75;
						colour[1]=125;
						colour[2]=255;
						colour[3]=45;
					}
					else
					{
						colour[0]=255;
						colour[1]=150;
						colour[2]=50;
						colour[3]=150;
						
						manacost = RoundToFloor(i_mana_cost_base[client] * BEAM_WAND_BEAM_MANA_MULTI);
					}
				}
	
							
				int pap = i_weapon_pap_tier[client];
					
				float target_vec[3];
				Beam_Wand_Client_Target_Vec(client, target_vec, gametime);

				bool update = false;
				if(fl_effect_throttle[client] < gametime)
				{
					update = true;
					Beam_Wand_Spawn_Effect(client, target_vec, colour);
				}
				
				if(FIRE)
				{
					float damage = 65.0;
					damage *= Attributes_Get(weapon, 410, 1.0);
						
					Beam_Wand_Oribtal_Cannon_Fire(client, target_vec, damage*BEAM_WAND_CANNON_ABILITY_DMG_MULTI, colour);
				}
			
				if(Current_Mana[client]>=manacost && fl_mana_timeout[client]<= gametime)
				{
					if(fl_hud_delay[client]<=gametime)
					{
						Beam_Wand_pap_Hud(client, false, RoundToFloor(ability_duration_remain));
						fl_hud_delay[client] = gametime + 0.5;
					}		
					if(f_attack_timer[client]<gametime)
					{
						bl_alternate[client] = !bl_alternate[client];
						if(fl_chargup_duration[client]>=gametime && bl_overdrive_beam[client])
						{
							Particle_Beam(client, pap, target_vec, colour, fl_beam_overdrive_damage[client], true);
						}
						else
						{
							bool M1Down = (GetClientButtons(client) & IN_ATTACK) != 0;
							if(bl_overdrive_beam[client] || bl_orbtial_cannon[client])
							{	
								if(bl_overdrive_beam[client])
								{			
									Particle_Beam(client, pap, target_vec, colour, fl_beam_overdrive_damage[client], false);
									
									float delay = 1.0;
									delay = Attributes_Get(weapon, 6, 1.0);
									f_attack_timer[client] = gametime + 0.07*delay;
									if(!bl_sound_active[client])
									{
										EmitSoundToClient(client,BEAM_WAND_OVERDRIVE_CHARGEUP_END_SOUND,_, SNDCHAN_STATIC, 100, _, 1.0, 125);
										EmitSoundToClient(client,BEAM_WAND_BEAM_SOUND,_, SNDCHAN_STATIC, 100, _, 0.5, 125);
										EmitSoundToClient(client,BEAM_WAND_BEAM_SOUND,_, SNDCHAN_STATIC, 100, _, 0.5, 125);
									}
									bl_sound_active[client] = true;
								}
								else
								{
									Beam_Wand_Orbital_Cannon_Charging(client, target_vec, colour, ability_duration_remain);
									
									f_attack_timer[client] = gametime + 0.1; 
								}
							}
							else if(M1Down)
							{
								float damage = 65.0;
								float delay = 1.0;
								damage *= Attributes_Get(weapon, 410, 1.0);
								
								delay = Attributes_Get(weapon, 6, 1.0);
								
								fl_beam_overdrive_damage[client] = damage;
								
								SDKhooks_SetManaRegenDelayTime(client, 1.0);
								Mana_Hud_Delay[client] = 0.0;
								
								Current_Mana[client] -= manacost;
								
								delay_hud[client] = 0.0;
								if(bl_particle_type[client])
								{
									Particle_Cannon(client, target_vec, colour, damage);
									EmitSoundToClient(client, BEAN_WAND_PARTICLE_CANNON_SOUND, _, SNDCHAN_STATIC, 100, _, 0.35);
									f_attack_timer[client] = gametime + (BEAM_WAND_CANNON_DELAY*delay);
								}
								else	//default false.
								{
									Particle_Beam(client, pap, target_vec, colour, damage, false);
									fl_mana_consumed_recent[client] = float(manacost);
									f_attack_timer[client] = gametime + (f_beam_delay[pap]*delay);
									if(!bl_sound_active[client])
									{
										EmitSoundToClient(client,BEAM_WAND_BEAM_SOUND,_, SNDCHAN_STATIC, 100, _, 0.35, GetRandomInt(90, 100));
									}
									bl_sound_active[client] = true;
								}
							}
							else
							{
								Kill_Sound(client);
							}
						}
					}
				}
				else
				{
					if(fl_mana_timeout[client] <= gametime-1.0)
					{
						fl_mana_timeout[client] = gametime + 5.0;
					}
					float time_out = fl_mana_timeout[client] - gametime;
					if(fl_hud_delay[client]<=gametime)
					{
						Beam_Wand_pap_Hud(client, true, RoundToFloor(time_out));
						fl_hud_delay[client] = gametime + 0.5;
					}
					Kill_Sound(client);
				}
				
				if(update)
				{
					fl_effect_throttle[client] = gametime + 0.1;
				}
			}
		}
		else
		{
			Kill_Hook(client);
			//CPrintToChatAll("UN HOOKED, WEAPON==WEPHOLD");
			return Plugin_Handled;
			
		}
	}
	else
	{
		Kill_Hook(client);
		//CPrintToChatAll("UN HOOKED, WEP INVALID");
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

static void Kill_Sound(int client)
{
	if(bl_sound_active[client])
	{
		StopSound(client, SNDCHAN_STATIC, BEAM_WAND_BEAM_SOUND);	//CEASE THY SOUND
		StopSound(client, SNDCHAN_STATIC, BEAM_WAND_BEAM_SOUND);
		StopSound(client, SNDCHAN_STATIC, BEAM_WAND_BEAM_SOUND);
		StopSound(client, SNDCHAN_STATIC, BEAM_WAND_BEAM_SOUND);
		StopSound(client, SNDCHAN_STATIC, BEAM_WAND_BEAM_SOUND);
		StopSound(client, SNDCHAN_STATIC, BEAM_WAND_BEAM_SOUND);
		bl_sound_active[client] = false;
	}
}

static void Kill_Hook(int client)
{
	SDKUnhook(client, SDKHook_PreThink, Beam_Wand_pap_Tick);
	Kill_Sound(client);
}

static void Particle_Cannon(int client, float target_vec[3], int colour[4], float dmg)
{
	dmg *= BEAM_WAND_CANNON_DMG_MULTI;
	if(bl_alternate[client])
	{
		Beam_Wand_Laser_Attack(client, target_vec, 1, dmg);
		Beam_Wand_Laser_Effect(client, target_vec, colour, 1);
	}
	else
	{
		Beam_Wand_Laser_Attack(client, target_vec, 2, dmg);
		Beam_Wand_Laser_Effect(client, target_vec, colour, 2);
	}
	
}

static void Particle_Beam(int client, int pap, float target_vec[3], int colour[4], float dmg, bool sfx)
{
	dmg *= BEAM_WAND_BEAM_DAMAGE_MULTI;
	if(!bl_overdrive_beam[client])
	{
		if(bl_alternate[client])
		{
			Beam_Wand_Laser_Attack(client, target_vec, 1, dmg);
			Beam_Wand_Laser_Effect(client, target_vec, colour, 1);
		}
		else
		{
			Beam_Wand_Laser_Attack(client, target_vec, 2, dmg);
			Beam_Wand_Laser_Effect(client, target_vec, colour, 2);
		}
	}
	else
	{
		dmg *= fl_beam_overdrive_dmg_multi[pap];
		if(bl_alternate[client])
		{
			for(int loop=1 ; loop<=BEAM_WAND_BEAM_OVERDRIVE_COUNT/2 ; loop++)
			{
				if(sfx)
				{
					TE_SetupGlowSprite(fl_laser_edge_vec[client][loop], gGlow1, 0.11, 0.25, 255);
					TE_SendToAll();
				}
				else
				{
					Beam_Wand_Laser_Effect(client, target_vec, colour, loop);
				}
			}
			if(!sfx)
			{
				Beam_Wand_Laser_Attack(client, target_vec, 1, dmg);
			}
		}
		else
		{
			for(int loop=BEAM_WAND_BEAM_OVERDRIVE_COUNT/2+1 ; loop<=BEAM_WAND_BEAM_OVERDRIVE_COUNT ; loop++)
			{
				
				if(sfx)
				{
					TE_SetupGlowSprite(fl_laser_edge_vec[client][loop], gGlow1, 0.11, 0.25, 255);
					TE_SendToAll();
				}
				else
				{
					Beam_Wand_Laser_Effect(client, target_vec, colour, loop);
				}
			}
			if(!sfx)
			{
				Beam_Wand_Laser_Attack(client, target_vec, 2, dmg);
			}
		}
	}
}
static void Beam_Wand_Laser_Attack(int client, float endVec_2[3], int num, float damage)
{
	Player_Laser_Logic Laser;
	Laser.weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	Laser.client = client;
	Laser.Damage = damage;
	Laser.Radius = 25.0;
	Laser.damagetype = DMG_PLASMA;
	Laser.End_Point = endVec_2;
	Laser.Start_Point = fl_laser_edge_vec[client][num];
	Laser.max_targets = bl_particle_type[client] ? 2 : MAX_BEAMWAND_TARGETS_HIT;
	Laser.Deal_Damage();
}
static void Beam_Wand_Laser_Effect(int client, float endVec_2[3], int colour[4], int num)
{
	float endVec[3]; endVec = fl_laser_edge_vec[client][num];
	float diameter = 75.0;
	float duration1 = 0.11;
	float duration2 = 0.22;
	int a;
	if(bl_overdrive_beam[client])
	{
		a = colour[3];
		diameter = 50.0;
		diameter /= 2.0;
	}
	else
	{
		a = 75;
	}
	if(bl_particle_type[client])
	{
		diameter = 150.0;
		duration1 = 0.75;
		duration2 = 0.5;
	}
	int r, g, b;
	r = colour[0];
	g = colour[1];
	b = colour[2];
	int colorLayer4[4];
	SetColorRGBA(colorLayer4, r, g, b, a);
	int colorLayer3[4];
	SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, a);
	int colorLayer2[4];
	SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, a);
	int colorLayer1[4];
	SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, a);
	if(bl_overdrive_beam[client])
	{
		TE_SetupBeamPoints(endVec, endVec_2, BeamWand_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 0.5, colorLayer1, 3);
	}
	else
	{
		TE_SetupBeamPoints(endVec, endVec_2, BeamWand_Laser, 0, 0, 0, duration1, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 0.5, colorLayer1, 3);
	}
	TE_SendToAll(0.0);
	int glowColor[4];
	
	diameter /= 1.5;
	SetColorRGBA(glowColor, r, g, b, a);
	if(bl_overdrive_beam[client])
	{
		TE_SetupBeamPoints(endVec, endVec_2, BeamWand_Glow, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 0.25, glowColor, 0);
	}
	else
	{
		TE_SetupBeamPoints(endVec, endVec_2, BeamWand_Glow, 0, 0, 0, duration2, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 0.4, glowColor, 0);
	}
	TE_SendToAll(0.0);
}
static void Beam_Wand_Spawn_Effect(int client,float target_vec[3], int colour[4])
{
	float UserLoc[3], angles[3];
	GetClientEyePosition(client, UserLoc);
	GetClientEyeAngles(client, angles);
	
	int count;
	
	if(bl_overdrive_beam[client])
	{
		count = BEAM_WAND_BEAM_OVERDRIVE_COUNT;
	}
	else
	{
		count = 2;
	}
	
	float distance = 120.0;
	
	float tempAngles[3], endLoc[3], Direction[3];
	
	float base = 180.0 / count;
	
	float tmp=base;
	
	UserLoc[2] -= 50.0;
	
	for(int i=1 ; i<=count ; i++)
	{	
		tempAngles[0] =	tmp*float(i)+180-(base/2);	//180 = Directly upwards, minus half the "gap" angle
		tempAngles[1] = angles[1]-90.0;
		tempAngles[2] = 0.0;
			
		if(tempAngles[0]>=360)
		{
			tempAngles[0] -= 360;
		}
						
		GetAngleVectors(tempAngles, Direction, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(Direction, distance);
		AddVectors(UserLoc, Direction, endLoc);
				
		float vecAngles[3];
				
		MakeVectorFromPoints(UserLoc, endLoc, vecAngles);
		GetVectorAngles(vecAngles, vecAngles);
			
		Create_Energy_Pylon(client, endLoc, i, target_vec, colour);
	}
}

static void Create_Energy_Pylon(int client, float SpawnVec[3], int num, float TargetVec[3], int colour[4])
{	
	float Range = 115.0;
	
	float endLoc[3], vecAngles[3];
	
	float alt_vec[3];

	float Te_Duration = 0.1;
	
	float Direction[3];
	if(bl_orbtial_cannon[client])
	{
		alt_vec = fl_oribtal_cannon_vec[client][num];
		MakeVectorFromPoints(SpawnVec, alt_vec, vecAngles);
		GetVectorAngles(vecAngles, vecAngles);
		
		GetAngleVectors(vecAngles, Direction, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(Direction, Range);
		AddVectors(SpawnVec, Direction, endLoc);
		
		TE_SetupBeamPoints(alt_vec, endLoc, gLaser2, 0, 0, 0, Te_Duration, 0.25, 0.5, 0, 0.75, colour, 0);
		TE_SendToClient(client);
		float sky_loc[3]; sky_loc = alt_vec; sky_loc[2] += 5000.0;
		
		TE_SetupBeamPoints(sky_loc, alt_vec, gLaser2, 0, 0, 0, Te_Duration, 0.25, 0.5, 0, 0.25, colour, 0);
		TE_SendToAll();
	}
	else
	{
		MakeVectorFromPoints(SpawnVec, TargetVec, vecAngles);
		GetVectorAngles(vecAngles, vecAngles);
		
		GetAngleVectors(vecAngles, Direction, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(Direction, Range);
		AddVectors(SpawnVec, Direction, endLoc);
	}
	
	fl_laser_edge_vec[client][num] = endLoc;
	TE_SetupBeamPoints(endLoc, SpawnVec, gLaser2, 0, 0, 0, Te_Duration, 0.75, 5.0, 0, 0.1, colour, 1);
	TE_SendToAll();
}

static void Beam_Wand_pap_Hud(int client, bool type, int duration)
{
	if(type)
	{
		PrintHintText(client,"Mana Time Out! {%i}", duration);
	}
	else
	{
		if(bl_particle_type[client])
		{
			if(bl_orbtial_cannon[client])
			{
				PrintHintText(client,"ORBITAL CANNON FIRING IN: {%i}", duration);
			}
			else if(i_cannon_charge[client]<BEAM_WAND_CANNON_ABILITY_COST)
			{
				PrintHintText(client,"Particle Cannon | Charge: [%i%/%i]", i_cannon_charge[client], BEAM_WAND_CANNON_ABILITY_COST);
			}
			else
			{
				PrintHintText(client,"Particle Cannon | Charge: [FULL!]");
			}
		}
		else
		{
			if(bl_overdrive_beam[client])
			{
				PrintHintText(client,"OVERDRIVE ACTIVE! | {%i}", duration);
			}
			else if(fl_beam_overdrive_cost[i_weapon_pap_tier[client]]>fl_beam_overdrive_charge[client])
			{
				PrintHintText(client,"Particle Beam | Charge: [%i%/%i]", RoundToFloor(fl_beam_overdrive_charge[client]), RoundToFloor(fl_beam_overdrive_cost[i_weapon_pap_tier[client]]));
			}
			else
			{
				PrintHintText(client,"Particle Beam | Charge: [FULL!]");
			}
		}
		
	}
	
}

static void Beam_Wand_Client_Target_Vec(int client, float vec[3], float gametime)
{
	if(fl_trace_delay[client]<=gametime)
	{
		fl_trace_delay[client] = gametime + BEAM_WAND_PAP_ALT_TRACE_DELAY;

		float range;
		if(bl_particle_type[client])
		{
			if(bl_orbtial_cannon[client])
			{
				range = 5000.0;
			}
			else
			{
				range = BEAM_WAND_CANNON_RANGE;
			}
			
		}
		else
		{
			range = fl_beam_range[i_weapon_pap_tier[client]];
		}

		Player_Laser_Logic Laser;
		Laser.client = client;
		Laser.DoForwardTrace_Basic(range);
		fl_last_known_vec[client] = Laser.End_Point;
		vec = Laser.End_Point;

	}
	else
	{
		vec = fl_last_known_vec[client];
	}
}



static void Beam_Wand_Orbital_Cannon_Charging(int client, float vec[3], int colour[4], float duration)
{
	float range = BEAM_WAND_CANNON_ABILITY_RANGE;
	
	range *= duration / BEAM_WAND_CANNON_ABILITY_DELAY;
	
	spawnRing_Vector(vec, range*2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt" , colour[0], colour[1], colour[2], colour[3], 1, 0.25, 2.0, 1.25, 1);
	
	if(fl_angle[client]>=360.0)
	{
		fl_angle[client] = 0.0;
	}
	fl_angle[client] += 10.0;
	float EndLoc[3];
	for (int j = 0; j < 2; j++)
	{
		float tempAngles[3], Direction[3];
		tempAngles[0] = 0.0;
		tempAngles[1] = fl_angle[client] + (float(j) * 180.0);
		tempAngles[2] = 0.0;
			
		GetAngleVectors(tempAngles, Direction, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(Direction, range);
		AddVectors(vec, Direction, EndLoc);
		fl_oribtal_cannon_vec[client][j+1] = EndLoc;
	}
}
static void Beam_Wand_Oribtal_Cannon_Fire(int client, float vec[3], float damage, int colour[4])
{
	float startPosition[3], position[3];
	startPosition = vec;
	
	spawnRing_Vector(vec, 0.0, 0.0, 0.0, 1.0, "materials/sprites/laserbeam.vmt" , colour[0], colour[1], colour[2], colour[3], 1, 0.10, 5.0, 1.25, 1 , BEAM_WAND_CANNON_ABILITY_RANGE*3.25);
	spawnRing_Vector(vec, 0.0, 0.0, 0.0, 2.0, "materials/sprites/laserbeam.vmt" , colour[0], colour[1], colour[2], colour[3], 1, 0.2, 5.0, 1.25, 1 , BEAM_WAND_CANNON_ABILITY_RANGE*2.0);
	spawnRing_Vector(vec, 0.0, 0.0, 0.0, 3.5, "materials/sprites/laserbeam.vmt" , colour[0], colour[1], colour[2], colour[3], 1, 0.35, 5.0, 1.25, 1 , BEAM_WAND_CANNON_ABILITY_RANGE*1.75);
	
	TE_SetupExplosion(startPosition, gExplosive1, 0.1, 1, 0, 0, 0);
	TE_SendToAll();
	Explode_Logic_Custom(damage, client, client, -1, startPosition, BEAM_WAND_CANNON_ABILITY_RANGE);
	EmitSoundToAll(BEAM_WAND_PARTICLE_ORBITAL_CANNON_FIRE_SOUND, client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL);
			
	position[0] = startPosition[0];
	position[1] = startPosition[1];
	position[2] += startPosition[2] + 900.0;
	startPosition[2] += -200;
	TE_SetupBeamPoints(startPosition, position, BeamWand_Laser, 0, 0, 0, 2.0, 11.0, 11.0, 0, 1.0, colour, 3);
	TE_SendToAll();
	TE_SetupBeamPoints(startPosition, position, BeamWand_Laser, 0, 0, 0, 1.66, 22.0, 22.0, 0, 1.0, colour, 3);
	TE_SendToAll();
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