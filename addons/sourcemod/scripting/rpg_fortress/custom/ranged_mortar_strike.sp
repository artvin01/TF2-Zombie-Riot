#define MORTAR_SHOT	"weapons/mortar/mortar_fire1.wav"
#define MORTAR_BOOM	"beams/beamstart5.wav"
#define MORTAR_SHOT_INCOMMING	"weapons/mortar/mortar_shell_incomming1.wav"

void Mortar_MapStart()
{
	PrecacheSound(MORTAR_SHOT);
	PrecacheSound(MORTAR_BOOM); 
	PrecacheSound(MORTAR_SHOT_INCOMMING); 
	PrecacheSound("weapons/drg_wrench_teleport.wav");
}

public float AbilityMortarRanged(int client, int index, char name[48])
{
	KeyValues kv = TextStore_GetItemKv(index);
	if(!kv)
	{
		return 0.0;
	}

	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(!IsValidEntity(weapon))
	{
		return 0.0;
	}

	static char classname[36];
	GetEntityClassname(weapon, classname, sizeof(classname));
	if (TF2_GetClassnameSlot(classname, weapon) == TFWeaponSlot_Melee || i_IsWandWeapon[weapon])
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		ShowGameText(client,"leaderboard_streak", 0, "Not usable Without a Ranged Weapon.");
		return 0.0;
	}
	if(Stats_Intelligence(client) < 25)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		ShowGameText(client,"leaderboard_streak", 0, "You do not have enough Intelligence [25]");
		return 0.0;
	}

	int StatsForCalcMultiAdd;
	Stats_Precision(client, StatsForCalcMultiAdd);
	StatsForCalcMultiAdd /= 4;
	//get base endurance for cost
	if(i_CurrentStamina[client] < StatsForCalcMultiAdd)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%s", "Not Enough Stamina");
		return 0.0;
	}

	int StatsForCalcMultiAdd_Capacity;

	StatsForCalcMultiAdd_Capacity = StatsForCalcMultiAdd * 2;

	if(Current_Mana[client] < StatsForCalcMultiAdd_Capacity)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%s", "Not Enough Mana");
		return 0.0;
	}
	RPGCore_StaminaReduction(weapon, client, StatsForCalcMultiAdd / 2);
	RPGCore_ResourceReduction(client, StatsForCalcMultiAdd_Capacity);

	StatsForCalcMultiAdd = Stats_Precision(client);

	float damageDelt = RPGStats_FlatDamageSetStats(client, 0, StatsForCalcMultiAdd);

	damageDelt *= 2.2;

	Ability_MortarRanged(client, 1, weapon, damageDelt);
	return (GetGameTime() + 15.0);
}
static float f_MarkerPosition[MAXPLAYERS][3];
static float f_Damage[MAXPLAYERS];



public void Ability_MortarRanged(int client, int level, int weapon, float damage)
{
	if(damage < 1.0)
	{
		f_Damage[client] = 1.0;
	}
	else
	{
		f_Damage[client] = damage;
	}	
	
	BuildingMortarAction(client);
}
	

public void BuildingMortarAction(int client)
{
	float spawnLoc[3];
	float eyePos[3];
	float eyeAng[3];
			   
	GetClientEyePosition(client, eyePos);
	GetClientEyeAngles(client, eyeAng);
	
	b_LagCompNPC_No_Layers = true;
	StartLagCompensation_Base_Boss(client);
	
	Handle trace = TR_TraceRayFilterEx(eyePos, eyeAng, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
	
	FinishLagCompensation_Base_boss();
	if (TR_DidHit(trace))
	{
		TR_GetEndPosition(spawnLoc, trace);
	} 
	int color[4];
	color[0] = 255;
	color[1] = 255;
	color[2] = 0;
	color[3] = 255;
									
	if (GetTeam(client) == TFTeam_Blue)
	{
		color[2] = 255;
		color[0] = 0;
	}
	GetAttachment(client, "effect_hand_R", eyePos, eyeAng);
	int SPRITE_INT = PrecacheModel("materials/sprites/laserbeam.vmt", false);
	float amp = 0.2;
	float life = 0.1;
	TE_SetupBeamPoints(eyePos, spawnLoc, SPRITE_INT, 0, 0, 0, life, 2.0, 2.2, 1, amp, color, 0);
	TE_SendToAll();
								
	delete trace;
	
	EmitSoundToAll("weapons/drg_wrench_teleport.wav", client, SNDCHAN_AUTO, 70);
	static float pos[3];
	CreateTimer(1.0, MortarFire_Anims, client, TIMER_FLAG_NO_MAPCHANGE);
	f_MarkerPosition[client] = spawnLoc;
	float position[3];
	position[0] = spawnLoc[0];
	position[1] = spawnLoc[1];
	position[2] = spawnLoc[2];
				
	position[2] += 3000.0;

	int particle = ParticleEffectAt(position, "kartimpacttrail", 2.0);
	SetEdictFlags(particle, (GetEdictFlags(particle) | FL_EDICT_ALWAYS));	
	CreateTimer(1.7, MortarFire_Falling_Shot, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);
	ParticleEffectAt(pos, "utaunt_portalswirl_purple_warp2", 2.0);
}

public Action MortarFire_Falling_Shot(Handle timer, int ref)
{
	int particle = EntRefToEntIndex(ref);
	if(particle>MaxClients && IsValidEntity(particle))
	{
		float position[3];
		GetEntPropVector(particle, Prop_Send, "m_vecOrigin", position);
		position[2] -= 3700;
		TeleportEntity(particle, position, NULL_VECTOR, NULL_VECTOR);
	}
	return Plugin_Handled;
}
public Action MortarFire_Anims(Handle timer, int client)
{
	if(IsClientInGame(client) && IsPlayerAlive(client))
	{
		EmitSoundToAll(MORTAR_SHOT_INCOMMING, 0, SNDCHAN_AUTO, 90, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, f_MarkerPosition[client]);
		EmitSoundToAll(MORTAR_SHOT_INCOMMING, 0, SNDCHAN_AUTO, 90, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, f_MarkerPosition[client]);
		//	SetColorRGBA(glowColor, r, g, b, alpha);
		ParticleEffectAt(f_MarkerPosition[client], "taunt_flip_land_ring", 1.0);
		CreateTimer(0.8, MortarFire, client, TIMER_FLAG_NO_MAPCHANGE);
	}	
	return Plugin_Handled;
}

public Action MortarFire(Handle timer, int client)
{
	if(IsClientInGame(client) && IsPlayerAlive(client))
	{
		Explode_Logic_Custom(f_Damage[client], client, client, -1, f_MarkerPosition[client], 350.0, 1.45, _, false);

		CreateEarthquake(f_MarkerPosition[client], 0.5, 350.0, 16.0, 255.0);
		EmitSoundToAll(MORTAR_BOOM, 0, SNDCHAN_AUTO, 90, SND_NOFLAGS, 0.8, SNDPITCH_NORMAL, -1, f_MarkerPosition[client]);
		EmitSoundToAll(MORTAR_BOOM, 0, SNDCHAN_AUTO, 90, SND_NOFLAGS, 0.8, SNDPITCH_NORMAL, -1, f_MarkerPosition[client]);
		ParticleEffectAt(f_MarkerPosition[client], "rd_robot_explosion", 1.0);
	}
	return Plugin_Handled;
}