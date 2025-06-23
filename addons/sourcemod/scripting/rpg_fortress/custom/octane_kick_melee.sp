
float f_OctaneDashDamage[MAXPLAYERS];
float f_OctaneDashDuration[MAXPLAYERS];


void OctaneKick_Map_Precache()
{
	PrecacheSound("ambient/explosions/explode_3.wav", true);
	PrecacheSound("weapons/physcannon/energy_sing_flyby2.wav", true);
	PrecacheSound("ambient/atmosphere/terrain_rumble1.wav", true);
	PrecacheSound("ambient/explosions/explode_9.wav", true);
}

public float AbilityOctaneKick(int client, int index, char name[48])
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
	if (TF2_GetClassnameSlot(classname, weapon) != TFWeaponSlot_Melee || i_IsWandWeapon[weapon])
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		ShowGameText(client,"leaderboard_streak", 0, "Not usable Without a Melee Weapon.");
		return 0.0;
	}

	if(Stats_Intelligence(client) < 1250)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		ShowGameText(client,"leaderboard_streak", 0, "You do not have enough Intelligence [1250]");
		return 0.0;
	}
	
	int StatsForCalcMultiAdd;
	Stats_Strength(client, StatsForCalcMultiAdd);
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
	RPGCore_StaminaReduction(weapon, client, StatsForCalcMultiAdd);
	StatsForCalcMultiAdd = Stats_Strength(client);

	float damageDelt = RPGStats_FlatDamageSetStats(client, 0, StatsForCalcMultiAdd);

	damageDelt *= 4.5;

	Ability_OnAbility_OctaneKick(client, 1, weapon, damageDelt);
	return (GetGameTime() + 15.0);
}

bool f_OctaneDashHitTarget[MAXPLAYERS][MAXENTITIES];
int i_ParticleIndex[MAXPLAYERS];
public void Ability_OnAbility_OctaneKick(int client, int level, int weapon, float damage)
{	
	
	int viewmodelModel;
	viewmodelModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);

	if(!IsValidEntity(viewmodelModel))
		return;

	f_OctaneDashDamage[client] = damage;
	f_OctaneDashDuration[client] = GetGameTime() + 1.0;
	
	float flPos[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);
	flPos[2] += 40.0;
	int particle = ParticleEffectAt(flPos, "scout_dodge_red", 3.0);
	SetParent(viewmodelModel, particle);
	i_ParticleIndex[client] = EntIndexToEntRef(particle);
	
	for(int i = 1; i < MAXENTITIES; i++)
	{
		if(f_OctaneDashHitTarget[client][i])
		{
			f_OctaneDashHitTarget[client][i] = false;
		}
	}

	SDKUnhook(client, SDKHook_PreThink, OctaneKick_ClientPrethink);
	SDKHook(client, SDKHook_PreThink, OctaneKick_ClientPrethink);
	EmitCustomToAll("rpg_fortress/enemy/whiteflower_dash.mp3", client, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, 1.2, 100);

	static float EntLoc[3];
			
	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", EntLoc);
			
	static float anglesB[3];
	GetClientEyeAngles(client, anglesB);
	static float velocity[3];
	GetAngleVectors(anglesB, velocity, NULL_VECTOR, NULL_VECTOR);
	float knockback = 1250.0;
			
	ScaleVector(velocity, knockback);
	if ((GetEntityFlags(client) & FL_ONGROUND) != 0 || GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 1)
		velocity[2] = fmax(velocity[2], 300.0);
	else
		velocity[2] += 150.0; // a little boost to alleviate arcing issues
			
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
}

void OctaneKick_ClientPrethink(int client)
{
	if(f_OctaneDashDuration[client] < GetGameTime())
	{
		//ability is over.
		SDKUnhook(client, SDKHook_PreThink, OctaneKick_ClientPrethink);
		if(IsValidEntity(i_ParticleIndex[client]))
		{
			RemoveEntity(i_ParticleIndex[client]); 
		}
		return;
	}
	OctaneKick_Logic(client);
}

//Borrowed from npc_combine_whiteflower , WhiteflowerKickLogic()
void OctaneKick_Logic(int iNPC)
{
	
	static float flMyPos[3];
	GetEntPropVector(iNPC, Prop_Data, "m_vecAbsOrigin", flMyPos);
	float vecUp[3];
	float vecForward[3];
	float vecRight[3];

	GetVectors(iNPC, vecForward, vecRight, vecUp); //Sorry i dont know any other way with this :(

	float vecSwingEnd[3];
	vecSwingEnd[0] = flMyPos[0] + vecForward[0] * (25.0);
	vecSwingEnd[1] = flMyPos[1] + vecForward[1] * (25.0);
	vecSwingEnd[2] = flMyPos[2];
				

	static float hullcheckmaxs[3];
	static float hullcheckmins[3];
	hullcheckmaxs = view_as<float>( { 24.0, 24.0, 82.0 } );
	hullcheckmins = view_as<float>( { -24.0, -24.0, 0.0 } );			
		
	//Fat kick!
	hullcheckmaxs[0] *= 2.5;
	hullcheckmaxs[1] *= 2.5;
	hullcheckmaxs[2] *= 2.5;

	hullcheckmins[0] *= 2.5;
	hullcheckmins[1] *= 2.5;
	hullcheckmins[2] *= 2.5;
	
	ResetTouchedentityResolve();
	
	ResolvePlayerCollisions_Npc_Internal(vecSwingEnd, hullcheckmins, hullcheckmaxs, iNPC);

	for (int entity_traced = 0; entity_traced < MAXENTITIES; entity_traced++)
	{
		if(!TouchedNpcResolve(entity_traced))
			break;
		
		OctaneKick_KickTouched(iNPC,ConvertTouchedResolve(entity_traced));
	}
	ResetTouchedentityResolve();
}


static void OctaneKick_KickTouched(int entity, int enemy)
{
	if(!IsValidEnemy(entity, enemy))
		return;

	if(f_OctaneDashHitTarget[entity][enemy])
		return;

	f_OctaneDashHitTarget[entity][enemy] = true;
	
	float targPos[3];
	WorldSpaceCenter(enemy, targPos);
	SDKHooks_TakeDamage(enemy, entity, entity, f_OctaneDashDamage[entity], DMG_CLUB, -1, NULL_VECTOR, targPos);
	EmitSoundToAll("plats/tram_hit4.wav", entity, SNDCHAN_STATIC, 80, _, 0.8);

	TE_Particle("skull_island_embers", targPos, NULL_VECTOR, NULL_VECTOR, entity, _, _, _, _, _, _, _, _, _, 0.0);

	if(enemy <= MaxClients)
	{
		Custom_Knockback(entity, enemy, 1500.0, true, true);
		f_AntiStuckPhaseThrough[enemy] = GetGameTime() + 1.0;
		ApplyStatusEffect(enemy, enemy, "Intangible", 1.0);
		TF2_AddCondition(enemy, TFCond_LostFooting, 0.5);
		TF2_AddCondition(enemy, TFCond_AirCurrent, 0.5);
	}
	else
	{
		Custom_Knockback(entity, enemy, 750.0, true, true);
	}
}