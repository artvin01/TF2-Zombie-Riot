#pragma semicolon 1
#pragma newdecls required

// static int Weapon_Id[MAXTF2PLAYERS]; // Why did I do taht?

Handle g_hHell_Hoe_Management[MAXPLAYERS+1] = {INVALID_HANDLE, ...};
static bool isStrikeHorizontal[MAXPLAYERS+1] = {false, ...};
static bool isCorruptedNightmare[MAXPLAYERS+1] = {false, ...};
static float flCorruptedLastDmg[MAXPLAYERS+1] = {0.0, ...};
static float flCorruptedLastHealthTook[MAXPLAYERS+1] = {0.0, ...};
static float flCorruptedLastHealthGain[MAXPLAYERS+1] = {0.0, ...};
bool g_isPlayerInDeathMarch_HellHoe[MAXPLAYERS+1] = {false, ...};
static float nextDeathMarch[MAXPLAYERS+1] = {0.0, ...};
static int iCurrentAngelHit[MAXPLAYERS+1] = {1, ...};

static float Damage_Projectile[MAXENTITIES]={0.0, ...};
static float Healing_Projectile[MAXENTITIES]={0.0, ...};
static int Projectile_To_Client[MAXENTITIES]={0, ...};
static int Projectile_To_Particle[MAXENTITIES]={0, ...};

//static int Projectile_To_Last[MAXENTITIES]={0, ...}; // I wanted to link them

static int Beam_Laser;
static int Beam_Glow;

#define HELL_HOE_TICK 0.1
#define SOUND_WAND_JUNKER_SHOT 	"weapons/bumper_car_decelerate_quick.wav"
#define SOUND_HELL_HOE 	"weapons/breadmonster/gloves/bm_gloves_attack_04.wav"
#define SOUND_SOUL_HIT "player/souls_receive2.wav"
#define NIGHTMARE_RADIUS 300.0
#define ANGEL_BLESSING_HIT_COUNT 40


void Hell_Hoe_MapStart()
{
	PrecacheSound(SOUND_WAND_JUNKER_SHOT, true);
	PrecacheSound(SOUND_HELL_HOE, true);
	PrecacheSound(SOUND_SOUL_HIT, true);
	Beam_Laser = PrecacheModel("materials/sprites/laser.vmt", false);
	Beam_Glow = PrecacheModel("sprites/glow02.vmt", true);
}


// yeah, i love recycle (see survival knife)
public void Reset_Management_Hell_Hoe(int client) //This is on disconnect/connect
{
	if (g_hHell_Hoe_Management[client] != INVALID_HANDLE)
	{
		delete g_hHell_Hoe_Management[client];
	}
	g_hHell_Hoe_Management[client] = INVALID_HANDLE;
	isStrikeHorizontal[client] = false;
	isCorruptedNightmare[client] = false;
	g_isPlayerInDeathMarch_HellHoe[client] = false;
	iCurrentAngelHit[client] = 0;
}

public void Enable_Management_Hell_Hoe(int client, int weapon) 
{
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_HELL_HOE_1 || i_CustomWeaponEquipLogic[weapon] == WEAPON_HELL_HOE_2 || i_CustomWeaponEquipLogic[weapon] == WEAPON_HELL_HOE_3)
	{
		Reset_Management_Hell_Hoe(client);
		DataPack pack;
		g_hHell_Hoe_Management[client] = CreateDataTimer(HELL_HOE_TICK, Timer_Management_Hell_Hoe, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}

public Action Timer_Management_Hell_Hoe(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());

	if (!IsValidMulti(client)) {
		g_hHell_Hoe_Management[client] = INVALID_HANDLE;
		return Plugin_Stop;
	}
	
	if(IsValidEntity(weapon))
	{
		if (IsPlayerAlive(client))
		{
			int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			if(weapon_holding == weapon) {
				if (i_CustomWeaponEquipLogic[weapon] == WEAPON_HELL_HOE_1 ) {
					if (isStrikeHorizontal[client] || g_isPlayerInDeathMarch_HellHoe[client]) {
						TF2_AddCondition(client, TFCond_CritCanteen, HELL_HOE_TICK + 0.2);
					}
				}
				else if (i_CustomWeaponEquipLogic[weapon] == WEAPON_HELL_HOE_2) {
					if (!isStrikeHorizontal[client] && !g_isPlayerInDeathMarch_HellHoe[client]) {
						TF2_AddCondition(client, TFCond_CritCanteen, HELL_HOE_TICK + 0.2);
					}
				}
				else if (i_CustomWeaponEquipLogic[weapon] == WEAPON_HELL_HOE_3) {
					TF2_AddCondition(client, TFCond_CritCanteen, HELL_HOE_TICK + 0.2);

					
					if (isPlayerMad(client)) {
						if (!g_isPlayerInDeathMarch_HellHoe[client]) {
							g_isPlayerInDeathMarch_HellHoe[client] = true;

							float Original_Res = 1.0;
							Original_Res = Attributes_Get(weapon, 205, 1.0);
							Attributes_Set(weapon, 205, Original_Res / 1.2);

							Original_Res = 1.0;
							Original_Res = Attributes_Get(weapon, 206, 1.0);
							Attributes_Set(weapon, 206, Original_Res / 1.2);
						}
					}
					else {
						if (g_isPlayerInDeathMarch_HellHoe[client]) {
							g_isPlayerInDeathMarch_HellHoe[client] = false;

							float Original_Res = 1.0;
							Original_Res = Attributes_Get(weapon, 205, 1.0);
							Attributes_Set(weapon, 205, Original_Res * 1.2);

							Original_Res = 1.0;
							Original_Res = Attributes_Get(weapon, 206, 1.0);
							Attributes_Set(weapon, 206, Original_Res * 1.2);
						}
					}
				}
			}


			
			if (i_CustomWeaponEquipLogic[weapon] == WEAPON_HELL_HOE_2 && g_isPlayerInDeathMarch_HellHoe[client]) {
				int newMana = Current_Mana[client] - 10;
				SDKhooks_SetManaRegenDelayTime(client, 1.0);
				Mana_Hud_Delay[client] = 0.0;
				
				if (newMana <= 0) {
					Current_Mana[client] = 0;
					
					float Original_Atackspeed = 1.0;
					Original_Atackspeed = Attributes_Get(weapon, 6, 1.0);
					Attributes_Set(weapon, 6, Original_Atackspeed / 0.5);
					
					nextDeathMarch[client] = GetGameTime() + 20.0;
					g_isPlayerInDeathMarch_HellHoe[client] = false;
					SetDefaultHudPosition(client);
					SetGlobalTransTarget(client);
					ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Angel hoe off");
				}
				else {
					Current_Mana[client] = newMana;
				}
			}
			
			if (isCorruptedNightmare[client]) 
			{
				int health = GetClientHealth(client);
				int healthToLoose = RoundFloat(flCorruptedLastHealthTook[client]);
				flCorruptedLastHealthTook[client] *= 1.05;
				if (health <= healthToLoose)
				{
					TF2_StunPlayer(client, 2.0, 100.0, TF_STUNFLAGS_NORMALBONK);
					isCorruptedNightmare[client] = false;
					nextDeathMarch[client] = GetGameTime() + 10.0;
					g_isPlayerInDeathMarch_HellHoe[client] = false;
					
					ClientCommand(client, "playgamesound ui/halloween_boss_summoned_monoculus.wav");
					SetDefaultHudPosition(client);
					SetGlobalTransTarget(client);
					ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Stop playing with");
					return Plugin_Continue;
				}
				health -= healthToLoose;
				SetEntProp(client, Prop_Data, "m_iHealth", health);
				
				float flHealToGainNotRounded = 0.0;
				float flClientPos[3];
				GetEntPropVector(client, Prop_Send, "m_vecOrigin", flClientPos);
				for(int targ; targ<i_MaxcountNpc; targ++)
				{
					int baseboss_index = EntRefToEntIndexFast(i_ObjectsNpcsTotal[targ]);
					if (IsValidEntity(baseboss_index))
					{
						if(!b_NpcHasDied[baseboss_index])
						{
							if (GetTeam(client)!=GetTeam(baseboss_index)) 
							{
								float targPos[3];
								WorldSpaceCenter(baseboss_index, targPos);
								if (GetVectorDistance(flClientPos, targPos) <= NIGHTMARE_RADIUS)
								{
									//Code to do damage position and ragdolls
									static float angles[3];
									GetEntPropVector(baseboss_index, Prop_Send, "m_angRotation", angles);
									float vecForward[3];
									GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
									//Code to do damage position and ragdolls
									float damage_force[3]; CalculateDamageForce(vecForward, 10000.0, damage_force);
									SDKHooks_TakeDamage(baseboss_index, client, client, flCorruptedLastDmg[client], DMG_PLASMA, -1, damage_force, targPos, _, ZR_DAMAGE_LASER_NO_BLAST);
									
									
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
									TE_SetupBeamPoints(flClientPos, targPos, Beam_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 1.0, colorLayer1, 3);
									TE_SendToAll(0.0);
									TE_SetupBeamPoints(flClientPos, targPos, Beam_Laser, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 0.5 * 1.28), ClampBeamWidth(diameter * 0.5 * 1.28), 0, 1.0, colorLayer2, 3);
									TE_SendToAll(0.0);
									TE_SetupBeamPoints(flClientPos, targPos, Beam_Laser, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 0.8 * 1.28), ClampBeamWidth(diameter * 0.8 * 1.28), 0, 1.0, colorLayer3, 3);
									TE_SendToAll(0.0);
									TE_SetupBeamPoints(flClientPos, targPos, Beam_Laser, 0, 0, 0, 0.33, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 1.0, colorLayer4, 3);
									int glowColor[4];
									SetColorRGBA(glowColor, r, g, b, 200);
									TE_SetupBeamPoints(flClientPos, targPos, Beam_Glow, 0, 0, 0, 0.33, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 5.0, glowColor, 0);
									TE_SendToAll(0.0);
										
									flHealToGainNotRounded += flCorruptedLastHealthGain[client];
								}
							}
						}
					}
				}
				flCorruptedLastHealthGain[client] *= 1.05;
				flCorruptedLastDmg[client] *= 1.05;
				
				if (flHealToGainNotRounded > 0.0) {
					int playerMaxHp = SDKCall_GetMaxHealth(client);
					HealEntityGlobal(client, client, flHealToGainNotRounded, 1.0,_,HEAL_ABSOLUTE|HEAL_SELFHEAL, playerMaxHp/2);
				}
			}
		}
		else {
			g_hHell_Hoe_Management[client] = INVALID_HANDLE;
			return Plugin_Stop;
		}
	}
	else {
		g_hHell_Hoe_Management[client] = INVALID_HANDLE;
		return Plugin_Stop;
	}
		
	return Plugin_Continue;
}



public Action Weapon_Junker_Staff(int client, int weapon, const char[] classname, bool &result)
{
	int mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));
	if(mana_cost <= Current_Mana[client])
	{
		float damage = 65.0;
		damage *= Attributes_Get(weapon, 410, 1.0);
		
		SDKhooks_SetManaRegenDelayTime(client, 1.0);
		Mana_Hud_Delay[client] = 0.0;
		
		Current_Mana[client] -= mana_cost;
		
		delay_hud[client] = 0.0;
			
		float speed = 1100.0;
		speed *= Attributes_Get(weapon, 103, 1.0);
		speed *= Attributes_Get(weapon, 104, 1.0);
		speed *= Attributes_Get(weapon, 475, 1.0);
	
	
		float time = 500.0/speed;
		time *= Attributes_Get(weapon, 101, 1.0);
		time *= Attributes_Get(weapon, 102, 1.0);
		
		EmitSoundToAll(SOUND_WAND_JUNKER_SHOT, client, 80, _, _, 1.0);
		HellHoeLaunch(client, weapon, damage, speed, time, 5, 50.0, "drg_manmelter_projectile");
		
		result = isStrikeHorizontal[client];
		return Plugin_Changed;
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		return Plugin_Continue;
	}
}

public Action Weapon_Junker_Staff_PAP1(int client, int weapon, const char[] classname, bool &result)
{
	int mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));
	if(mana_cost <= Current_Mana[client])
	{
		float damage = 65.0;
		damage *= Attributes_Get(weapon, 410, 1.0);
		
		SDKhooks_SetManaRegenDelayTime(client, 1.0);
		Mana_Hud_Delay[client] = 0.0;
		
		Current_Mana[client] -= mana_cost;
		
		delay_hud[client] = 0.0;
			
		float speed = 1100.0;
		speed *= Attributes_Get(weapon, 103, 1.0);
		speed *= Attributes_Get(weapon, 104, 1.0);
		speed *= Attributes_Get(weapon, 475, 1.0);
	
	
		float time = 500.0/speed;
		time *= Attributes_Get(weapon, 101, 1.0);
		time *= Attributes_Get(weapon, 102, 1.0);
		
		if (isPlayerMad(client) && i_CustomWeaponEquipLogic[weapon] == WEAPON_HELL_HOE_3) {
			EmitSoundToAll(SOUND_HELL_HOE, client, 80, _, _, 1.0);
			HellHoeLaunch(client, weapon, damage, speed/2, time/3, 5, 50.0, "spell_teleport_red", 0.008);
		}
		else {
			EmitSoundToAll(SOUND_WAND_JUNKER_SHOT, client, 80, _, _, 1.0);
			HellHoeLaunch(client, weapon, damage, speed, time, 7, 50.0, "drg_manmelter_projectile");
		}
		
		
		result = isStrikeHorizontal[client];
		return Plugin_Changed;
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		return Plugin_Continue;
	}
}

/* Got a better idea for that

public Action Weapon_Junker_Staff_PAP2(int client, int weapon, const char[] classname, bool &result)
{
	int mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));
	if(mana_cost <= Current_Mana[client])
	{
		float damage = 65.0;
		damage *= Attributes_Get(weapon, 410, 1.0);
		
		SDKhooks_SetManaRegenDelayTime(client, 1.0);
		Mana_Hud_Delay[client] = 0.0;
		
		Current_Mana[client] -= mana_cost;
		
		delay_hud[client] = 0.0;
			
		float speed = 1100.0;
		speed *= Attributes_Get(weapon, 103, 1.0);
		speed *= Attributes_Get(weapon, 104, 1.0);
		speed *= Attributes_Get(weapon, 475, 1.0);
	
	
		float time = 500.0/speed;
		time *= Attributes_Get(weapon, 101, 1.0);
		time *= Attributes_Get(weapon, 102, 1.0);
		
		EmitSoundToAll(SOUND_WAND_JUNKER_SHOT, client, 80, _, _, 1.0);
		HellHoeLaunch(client, weapon, damage, speed, time, 7, 50.0, "drg_manmelter_projectile", _, true);
		
		result = isStrikeHorizontal[client];
		return Plugin_Changed;
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		return Plugin_Continue;
	}
}
*/

public Action Weapon_Angel_Sword(int client, int weapon, const char[] classname, bool &result)
{
	int mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));

	if(mana_cost <= Current_Mana[client])
	{
		float damage = 65.0;
		damage *= Attributes_Get(weapon, 410, 1.0);
		
		SDKhooks_SetManaRegenDelayTime(client, 1.0);
		Mana_Hud_Delay[client] = 0.0;
		
		Current_Mana[client] -= mana_cost;
		
		delay_hud[client] = 0.0;
			
		float speed = 1100.0;
		speed *= Attributes_Get(weapon, 103, 1.0);
		speed *= Attributes_Get(weapon, 104, 1.0);
		speed *= Attributes_Get(weapon, 475, 1.0);
	
	
		float time = 500.0/speed;
		time *= Attributes_Get(weapon, 101, 1.0);
		time *= Attributes_Get(weapon, 102, 1.0);
			
		HellHoeLaunch(client, weapon, damage, speed, time, 5, 50.0, "superrare_halo");
		
		result = isStrikeHorizontal[client];
		return Plugin_Changed;
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		return Plugin_Continue;
	}
}

public Action Weapon_Angel_Sword_PAP(int client, int weapon, const char[] classname, bool &result)
{
	int mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));

	if(mana_cost <= Current_Mana[client])
	{
		float damage = 65.0;
		damage *= Attributes_Get(weapon, 410, 1.0);
		
		SDKhooks_SetManaRegenDelayTime(client, 1.0);
		Mana_Hud_Delay[client] = 0.0;
		
		Current_Mana[client] -= mana_cost;
		
		delay_hud[client] = 0.0;
			
		float speed = 1100.0;
		speed *= Attributes_Get(weapon, 103, 1.0);
		speed *= Attributes_Get(weapon, 104, 1.0);
		speed *= Attributes_Get(weapon, 475, 1.0);
	
	
		float time = 500.0/speed;
		time *= Attributes_Get(weapon, 101, 1.0);
		time *= Attributes_Get(weapon, 102, 1.0);
			
		HellHoeLaunch(client, weapon, damage, speed, time, 7, 50.0, "superrare_halo", -2.0);
		
		result = isStrikeHorizontal[client];
		return Plugin_Changed;
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		return Plugin_Continue;
	}
}



public Action Weapon_Hell_Hoe(int client, int weapon, const char[] classname, bool &result)
{
	int mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));

	if(mana_cost <= Current_Mana[client])
	{
		float damage = 65.0;
		damage *= Attributes_Get(weapon, 410, 1.0);
		
		SDKhooks_SetManaRegenDelayTime(client, 1.0);
		Mana_Hud_Delay[client] = 0.0;
		
		Current_Mana[client] -= mana_cost;
		
		delay_hud[client] = 0.0;
			
		float speed = 1100.0;
		speed *= Attributes_Get(weapon, 103, 1.0);
		speed *= Attributes_Get(weapon, 104, 1.0);
		speed *= Attributes_Get(weapon, 475, 1.0);
	
	
		float time = 500.0/speed;
		time *= Attributes_Get(weapon, 101, 1.0);
		time *= Attributes_Get(weapon, 102, 1.0);
		
		if (g_isPlayerInDeathMarch_HellHoe[client])
		{
			int flMaxHealth = SDKCall_GetMaxHealth(client);
			int health = GetClientHealth(client);
			
			if (health > RoundFloat(flMaxHealth * 0.1)) {
				int newHealth = health - RoundFloat(flMaxHealth * 0.1);
				
				if (newHealth > flMaxHealth)
					newHealth = flMaxHealth;
					
				SetEntProp(client, Prop_Data, "m_iHealth", newHealth);
				
				EmitSoundToAll(SOUND_HELL_HOE, client, 80, _, _, 1.0);
				HellHoeLaunch(client, weapon, damage, speed, time, 5, 50.0, "spell_teleport_red", 0.008);
			}
			else {
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Health", RoundFloat(flMaxHealth * 0.1));
			}
		}
		else {
			EmitSoundToAll(SOUND_HELL_HOE, client, 80, _, _, 1.0);
			HellHoeLaunch(client, weapon, damage, speed, time, 5, 50.0, "spell_teleport_red", -1.0);
		}
		
		result = isStrikeHorizontal[client];
		return Plugin_Changed;
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		return Plugin_Continue;
	}
}

public void Hell_Hoe_Transformation(int client, int weapon, bool crit) {
	if (!g_isPlayerInDeathMarch_HellHoe[client])
	{
		if (nextDeathMarch[client] > GetGameTime()) {
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Let the beast sleeps", nextDeathMarch[client] - GetGameTime());
			return;
		}
		
		g_isPlayerInDeathMarch_HellHoe[client] = true;
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Evil hoe on");
	}
	else
	{
		nextDeathMarch[client] = GetGameTime() + 10.0;
		g_isPlayerInDeathMarch_HellHoe[client] = false;
		isCorruptedNightmare[client] = false;
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Evil hoe off");
	}
}

public void Angel_Sword_Transformation(int client, int weapon, bool crit) {
	if (!g_isPlayerInDeathMarch_HellHoe[client])
	{
		if (nextDeathMarch[client] > GetGameTime()) {
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Wait for power", nextDeathMarch[client] - GetGameTime());
			return;
		}
		
		float Original_Atackspeed = 1.0;
		Original_Atackspeed = Attributes_Get(weapon, 6, 1.0);
		Attributes_Set(weapon, 6, Original_Atackspeed * 0.5);
		
		g_isPlayerInDeathMarch_HellHoe[client] = true;
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Angel hoe on");
		ClientCommand(client, "playgamesound ui/mm_medal_gold.wav");
	}
	else
	{
		float Original_Atackspeed = 1.0;
		Original_Atackspeed = Attributes_Get(weapon, 6, 1.0);
		Attributes_Set(weapon, 6, Original_Atackspeed / 0.5);
		
		nextDeathMarch[client] = GetGameTime() + 20.0;
		g_isPlayerInDeathMarch_HellHoe[client] = false;
		isCorruptedNightmare[client] = false;
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Angel hoe off");
		ClientCommand(client, "playgamesound ui/mm_medal_none.wav");
	}
}

public void Weapon_Hell_Hoe_M2(int client, int weapon, const char[] classname, bool &result)
{
	if (!g_isPlayerInDeathMarch_HellHoe[client]) {
		if (!isStrikeHorizontal[client])
		{
			isStrikeHorizontal[client] = true;
			PrintHintText(client, "Weapon Mode: Horizontal");
		}
		else
		{
			isStrikeHorizontal[client] = false;
			PrintHintText(client, "Weapon Mode: Vertical");
		}
	}
}

public void Weapon_Angel_Sword_PAP_M2(int client, int weapon, const char[] classname, bool &result)
{
	if (!g_isPlayerInDeathMarch_HellHoe[client]) {
		if (!isStrikeHorizontal[client])
		{
			isStrikeHorizontal[client] = true;
			PrintHintText(client, "Weapon Mode: Horizontal");
		}
		else
		{
			isStrikeHorizontal[client] = false;
			PrintHintText(client, "Weapon Mode: Vertical");
		}
	}
	else {
		if (iCurrentAngelHit[client] < ANGEL_BLESSING_HIT_COUNT) {
			ClientCommand(client, "playgamesound items/medshotno1.wav");
		}
		else {
			float BannerPos[3];
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", BannerPos);
		
			int clientMaxHp = SDKCall_GetMaxHealth(client);
			float targPos[3];
			for(int ally=1; ally<=MaxClients; ally++)
			{
				iCurrentAngelHit[client] = 0;
				if(IsClientInGame(ally) && IsPlayerAlive(ally) && dieingstate[ally] == 0 && TeutonType[ally] == TEUTON_NONE)
				{
					GetEntPropVector(ally, Prop_Data, "m_vecAbsOrigin", targPos);
					if (GetVectorDistance(BannerPos, targPos, true) <= 500.0)
					{
						int playerMaxHp = SDKCall_GetMaxHealth(ally);
						if (playerMaxHp<clientMaxHp)
							playerMaxHp=clientMaxHp;
						HealEntityGlobal(client, ally, playerMaxHp * 0.3, 10.0,_,HEAL_ABSOLUTE);
						
						ClientCommand(ally, "playgamesound player/taunt_medic_heroic.wav");
					}
				}
			}
		}
	}
}



public void Weapon_Hell_Hoe_PAP_M2(int client, int weapon, const char[] classname, bool &result)
{
	if (!g_isPlayerInDeathMarch_HellHoe[client]) {
		if (!isStrikeHorizontal[client])
		{
			isStrikeHorizontal[client] = true;
			PrintHintText(client, "Weapon Mode: Horizontal");
		}
		else
		{
			isStrikeHorizontal[client] = false;
			PrintHintText(client, "Weapon Mode: Vertical");
		}
	}
	else {
		if (isCorruptedNightmare[client]) {
			nextDeathMarch[client] = GetGameTime() + 10.0;
			g_isPlayerInDeathMarch_HellHoe[client] = false;
			isCorruptedNightmare[client] = false;
			ClientCommand(client, "playgamesound misc/halloween/spell_spawn_boss_disappear.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Evil hoe off");
		}
		else {
			ClientCommand(client, "playgamesound misc/halloween/spell_spawn_boss.wav");
			isCorruptedNightmare[client] = true;
			
			int flMaxHealth = SDKCall_GetMaxHealth(client);
			flCorruptedLastHealthTook[client] = flMaxHealth * 0.015;
			flCorruptedLastHealthGain[client] = flMaxHealth * 0.01;
			
			float damage = 10.0;
			damage *= Attributes_Get(weapon, 410, 1.0);
			
			flCorruptedLastDmg[client] = damage;
		}
	}
}

public void Weapon_DRMad_Reload(int client, int weapon, bool crit, int slot)
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		int clientMaxHp = SDKCall_GetMaxHealth(client);
		int health = GetClientHealth(client);
		
		if (health > clientMaxHp/2)
		{
			float BannerPos[3];
			float targPos[3];
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", BannerPos);
			SetEntProp(client, Prop_Data, "m_iHealth", health-(clientMaxHp/2));

			ApplyTempAttrib(weapon, 205, 0.65, 10.0);
			ApplyTempAttrib(weapon, 206, 0.65, 10.0);
			for(int ally=1; ally<=MaxClients; ally++)
			{
				if(IsClientInGame(ally) && IsPlayerAlive(ally) && dieingstate[ally] == 0 && TeutonType[ally] == TEUTON_NONE && client!=ally)
				{
					GetEntPropVector(ally, Prop_Data, "m_vecAbsOrigin", targPos);
					if (GetVectorDistance(BannerPos, targPos, true) <= 500.0)
					{
						int playerMaxHp = SDKCall_GetMaxHealth(ally);
						if (playerMaxHp<clientMaxHp)
							playerMaxHp=clientMaxHp;
						HealEntityGlobal(client, ally, playerMaxHp * 0.5, 10.0,_,HEAL_ABSOLUTE);
						
						ClientCommand(ally, "playgamesound player/taunt_medic_heroic.wav");
					}
				}
			}
			ClientCommand(client, "playgamesound weapons/grappling_hook_impact_flesh.wav");
		}
		else
		{
			TF2_StunPlayer(client, 2.0, 100.0, TF_STUNFLAGS_NORMALBONK);
			HealEntityGlobal(client, client, clientMaxHp * 1.0, 1.0,2.0,HEAL_ABSOLUTE|HEAL_SELFHEAL);
			ClientCommand(client, "playgamesound misc/halloween/spell_overheal.wav");
		}
		Ability_Apply_Cooldown(client, slot, 15.0);
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
	}
}

public void Weapon_DRMad_M2(int client, int weapon, bool &result, int slot)
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		int clientMaxHp = SDKCall_GetMaxHealth(client);
		int health = GetClientHealth(client);
		
		if (health > clientMaxHp/2)
		{
			float BannerPos[3];
			float targPos[3];
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", BannerPos);
			SetEntProp(client, Prop_Data, "m_iHealth", health-RoundFloat(clientMaxHp*0.1));
			for(int ally=1; ally<=MaxClients; ally++)
			{
				if(IsClientInGame(ally) && IsPlayerAlive(ally) && dieingstate[ally] == 0 && TeutonType[ally] == TEUTON_NONE && client!=ally)
				{
					GetEntPropVector(ally, Prop_Data, "m_vecAbsOrigin", targPos);
					if (GetVectorDistance(BannerPos, targPos, true) <= 500.0)
					{
						int playerMaxHp = SDKCall_GetMaxHealth(ally);
						if (playerMaxHp<clientMaxHp)
							playerMaxHp=clientMaxHp;
						HealEntityGlobal(client, ally, playerMaxHp * 0.1, 10.0,_,HEAL_ABSOLUTE);
						
						ClientCommand(ally, "playgamesound player/taunt_medic_heroic.wav");
					}
				}
			}
			ClientCommand(client, "playgamesound weapons/grappling_hook_impact_flesh.wav");
			Ability_Apply_Cooldown(client, slot, 1.0);
		}
		else if (health > clientMaxHp*0.20)
		{
			health-=RoundFloat(clientMaxHp*0.2);
			SetEntProp(client, Prop_Data, "m_iHealth", health);

			float flClientPos[3];
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", flClientPos);
			for(int targ; targ<i_MaxcountNpc; targ++)
			{
				int baseboss_index = EntRefToEntIndexFast(i_ObjectsNpcsTotal[targ]);
				if (IsValidEntity(baseboss_index))
				{
					if(!b_NpcHasDied[baseboss_index])
					{
						if (GetTeam(client)!=GetTeam(baseboss_index)) 
						{
							float targPos[3];
							WorldSpaceCenter(baseboss_index, targPos);
							if (GetVectorDistance(flClientPos, targPos) <= NIGHTMARE_RADIUS)
							{
								//Code to do damage position and ragdolls
								static float angles[3];
								GetEntPropVector(baseboss_index, Prop_Send, "m_angRotation", angles);
								float vecForward[3];
								GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
								//Code to do damage position and ragdolls
								float damage_force[3]; CalculateDamageForce(vecForward, 10000.0, damage_force);
								SDKHooks_TakeDamage(baseboss_index, client, client, clientMaxHp*0.05*(clientMaxHp-health), DMG_PLASMA, -1, damage_force, targPos, _, ZR_DAMAGE_LASER_NO_BLAST);
							}
						}
					}
				}
			}
			ClientCommand(client, "playgamesound weapons/grappling_hook_impact_flesh.wav");
			Ability_Apply_Cooldown(client, slot, 10.0);
		}
		
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
	}
}

stock void HellHoeLaunch(int client, int weapon, float dmg, float speed, float time, int projectile_number, float spaceBetweenProj, char[] particleName, float healthGain = 0.0) {
	float fAng[3], fPos[3];
	GetClientEyeAngles(client, fAng);
	GetClientEyePosition(client, fPos);
	
	float fRight[3], fFowardd[3];
	GetAngleVectors(fAng, fFowardd, fRight, NULL_VECTOR);
	
	if(projectile_number > 3)
	{
		dmg *= float(projectile_number) / 3.0;
		spaceBetweenProj /= float(projectile_number) / 3.0;
		if(healthGain > 0.0)
			healthGain *= float(projectile_number) / 3.0;
		projectile_number = 3;
	}
	
	if (isStrikeHorizontal[client] || g_isPlayerInDeathMarch_HellHoe[client] || i_CustomWeaponEquipLogic[weapon] == WEAPON_HELL_HOE_3) 
	{
		fPos[0] += spaceBetweenProj * fRight[0] - 10.0;
		fPos[1] += spaceBetweenProj * fRight[1] - 0.0;
		fPos[2] -= spaceBetweenProj / 2.0 + 1.0;
	}
	else
	{
		fPos[2] += spaceBetweenProj + 5.0;
	}
	
	for (int c = 0; c < projectile_number; c++) 
	{

		if (isStrikeHorizontal[client] || g_isPlayerInDeathMarch_HellHoe[client] || i_CustomWeaponEquipLogic[weapon] == WEAPON_HELL_HOE_3)  
		{
			fPos[0] -= ((spaceBetweenProj*2.0)/projectile_number) * fRight[0];
			fPos[1] -= ((spaceBetweenProj*2.0)/projectile_number) * fRight[1];
		}
		else 
		{
			fPos[2] -= (spaceBetweenProj*2.0)/projectile_number;
		}
		
		int iCarrier = CreateHellHoeProjectile(client, speed, fPos, fAng, time, particleName);	
		Projectile_To_Client[iCarrier] = client;
		Damage_Projectile[iCarrier] = dmg;
		Healing_Projectile[iCarrier] = healthGain;
		SDKHook(iCarrier, SDKHook_StartTouch, Event_Hell_Hoe_OnHatTouch);
	}
}

public Action Event_Hell_Hoe_OnHatTouch(int entity, int other)
{
	int target = Target_Hit_Wand_Detection(entity, other);
	if (target > 0)	
	{
		//Code to do damage position and ragdolls
		static float angles[3];
		GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		static float Entity_Position[3];
		WorldSpaceCenter(target, Entity_Position);
		//Code to do damage position and ragdolls
		float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);
		SDKHooks_TakeDamage(other, Projectile_To_Client[entity], Projectile_To_Client[entity], Damage_Projectile[entity], DMG_PLASMA, -1, Dmg_Force, Entity_Position, _ , ZR_DAMAGE_LASER_NO_BLAST);	// 2048 is DMG_NOGIB?

		Damage_Projectile[entity] *= 0.5;
		
		if (Healing_Projectile[entity] > 0.0) 
		{
			int client = Projectile_To_Client[entity];
			int flMaxHealth = SDKCall_GetMaxHealth(client);
			
			HealEntityGlobal(client, client, float(flMaxHealth) * Healing_Projectile[entity], 1.0,_, HEAL_SELFHEAL);
		}
		else if (Healing_Projectile[entity] == -2.0) 
		{
			int client = Projectile_To_Client[entity];
			if (iCurrentAngelHit[client] < ANGEL_BLESSING_HIT_COUNT) {
				iCurrentAngelHit[client] += 1;
				PrintHintText(client, "Holy Charge: %i/%i", iCurrentAngelHit[client], ANGEL_BLESSING_HIT_COUNT);
			}
		}
	}
	else if(target == 0)
	{
		int particle = EntRefToEntIndex(Projectile_To_Particle[entity]);
		if(IsValidEntity(particle) && particle != 0)
		{
			if (Healing_Projectile[entity] > 0.0 || Healing_Projectile[entity] == -1.0)
				EmitSoundToAll(SOUND_SOUL_HIT, entity, SNDCHAN_STATIC, 70, _, 0.9);
			else
				EmitSoundToAll(SOUND_ZAP, entity, SNDCHAN_STATIC, 70, _, 0.3);
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
	return Plugin_Handled;
}


stock int CreateHellHoeProjectile(int client, float flSpeed, float flPos[3], float flAng[3], float flDuration, char[] particleName)
{
	int iRot = CreateEntityByName("func_door_rotating");
	if(iRot == -1) return -1;

	DispatchKeyValueVector(iRot, "origin", flPos);
	DispatchKeyValue(iRot, "distance", "99999");
	DispatchKeyValueFloat(iRot, "speed", flSpeed);
	DispatchKeyValue(iRot, "spawnflags", "12288"); // passable|silent
	DispatchSpawn(iRot);
	SetEntityCollisionGroup(iRot, 27);

	SetVariantString("!activator");
	AcceptEntityInput(iRot, "Open");
	
	
	int iCarrier = CreateEntityByName("prop_physics_override");
	if(iCarrier == -1) return -1;

	float fVel[3], fBuf[3];
	GetAngleVectors(flAng, fBuf, NULL_VECTOR, NULL_VECTOR);
	fVel[0] = fBuf[0]*flSpeed;
	fVel[1] = fBuf[1]*flSpeed;
	fVel[2] = fBuf[2]*flSpeed;

	SetEntPropEnt(iCarrier, Prop_Send, "m_hOwnerEntity", client);
	DispatchKeyValue(iCarrier, "model", ENERGY_BALL_MODEL);
	DispatchKeyValue(iCarrier, "modelscale", "0");
	DispatchSpawn(iCarrier);

	TeleportEntity(iCarrier, flPos, NULL_VECTOR, fVel);
	SetEntityMoveType(iCarrier, MOVETYPE_FLY);
	
	SetTeam(iCarrier, GetClientTeam(client));
	SetTeam(iRot, GetClientTeam(client));
	
	SetVariantString("!activator");
	AcceptEntityInput(iRot, "SetParent", iCarrier, iRot, 0);
	SetEntityCollisionGroup(iCarrier, 27);
	
	float position[3];
	GetEntPropVector(iCarrier, Prop_Data, "m_vecAbsOrigin", position);
	int particle = ParticleEffectAt(position, particleName, flDuration);
	
	
	TeleportEntity(particle, NULL_VECTOR, flAng, NULL_VECTOR);
	TeleportEntity(iCarrier, NULL_VECTOR, flAng, NULL_VECTOR);
	TeleportEntity(iRot, NULL_VECTOR, flAng, NULL_VECTOR);	
	SetParent(iCarrier, particle);	
	
	Projectile_To_Particle[iCarrier] = EntIndexToEntRef(particle);
	
	SetEntityRenderMode(iCarrier, RENDER_TRANSCOLOR);
	SetEntityRenderColor(iCarrier, 255, 255, 255, 0);
	SetEntProp(iCarrier, Prop_Send, "m_usSolidFlags", 200);
	SetEntProp(iCarrier, Prop_Data, "m_nSolidType", 0);
	SetEntityCollisionGroup(iCarrier, 0);
	
	DataPack pack;
	CreateDataTimer(flDuration, Timer_RemoveEntity_CustomProjectile, pack, TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(EntIndexToEntRef(iCarrier));
	pack.WriteCell(EntIndexToEntRef(particle));
	pack.WriteCell(EntIndexToEntRef(iRot));
	
	return iCarrier;
}