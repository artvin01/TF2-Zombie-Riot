#pragma semicolon 1
#pragma newdecls required

static float ability_cooldown[MAXPLAYERS+1]={0.0, ...};
static int i_FireBallsToThrow[MAXPLAYERS+1]={0, ...};
static float f_OriginalDamage[MAXPLAYERS];
static int i_weaponused[MAXPLAYERS];

#define SOUND_WAND_ATTACKSPEED_ABILITY "weapons/physcannon/energy_disintegrate4.wav"
#define WAND_FIREBALL_SOUND "misc/halloween/spell_fireball_cast.wav"

public void Wand_Fire_Spell_ClearAll()
{
	
	Zero(i_FireBallsToThrow);
	Zero(ability_cooldown);
}

void Wand_FireBall_Map_Precache()
{
	Wand_Fire_Spell_ClearAll();
	PrecacheSound(WAND_FIREBALL_SOUND);
	PrecacheSound(SOUND_WAND_ATTACKSPEED_ABILITY);
}

public float AbilityFireball(int client, int index, char name[48])
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
	if (!i_IsWandWeapon[weapon])
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		ShowGameText(client,"leaderboard_streak", 0, "Not usable Without a Magic Wand.");
		return 0.0;
	}
	if(Stats_Intelligence(client) < 25)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		ShowGameText(client,"leaderboard_streak", 0, "You do not have enough Intelligence [25]");
		return 0.0;
	}

	int StatsForCalcMultiAdd;
	Stats_Artifice(client, StatsForCalcMultiAdd);
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
	float Time = 15.0;
	if(ChronoShiftReady(client) == 2)
	{
		ChronoShiftDoCooldown(client);
		Time = 0.0;
	}
	else
	{
		RPGCore_StaminaReduction(weapon, client, StatsForCalcMultiAdd / 2);
	}
	RPGCore_ResourceReduction(client, StatsForCalcMultiAdd_Capacity);
	
	StatsForCalcMultiAdd = Stats_Artifice(client);

	float damageDelt = RPGStats_FlatDamageSetStats(client, 0, StatsForCalcMultiAdd);

	damageDelt *= 1.6;

	Weapon_Wand_FireBallSpell(client, 1, weapon, damageDelt);

	return (GetGameTime() + Time);
}

public void Weapon_Wand_FireBallSpell(int client, int weapon, int level, float damage)
{
	f_OriginalDamage[client] = damage;
	
	i_weaponused[client] = EntIndexToEntRef(weapon);

	float fAng[3], fPos[3];
	GetClientEyeAngles(client, fAng);
	GetClientEyePosition(client, fPos);

	static float speed = 1000.0;

	float fVel[3], fBuf[3];
	GetAngleVectors(fAng, fBuf, NULL_VECTOR, NULL_VECTOR);
	fVel[0] = fBuf[0]*speed;
	fVel[1] = fBuf[1]*speed;
	fVel[2] = fBuf[2]*speed;

	i_FireBallsToThrow[client] = 1;
	int entity = CreateEntityByName("tf_projectile_spellfireball");
	if(IsValidEntity(entity))
	{
		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
		SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 0.0, true);	// Damage
		SetEntProp(entity, Prop_Send, "m_iTeamNum", GetEntProp(client, Prop_Send, "m_iTeamNum"));
		SetTeam(entity, GetEntProp(client, Prop_Send, "m_iTeamNum"));
		if(MagicFocusReady(client))
		{
			SetEntProp(entity, Prop_Send, "m_iTeamNum", 3);
			f_OriginalDamage[client] *= 1.3;
			MagicFocusUse(client);
			i_FireBallsToThrow[client] = 2;
		}
		TeleportEntity(entity, fPos, fAng, NULL_VECTOR);
		DispatchSpawn(entity);
		TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, fVel);
		f_CustomGrenadeDamage[entity] = f_OriginalDamage[client];
		SetEntPropEnt(entity, Prop_Send, "m_hLauncher", EntRefToEntIndex(i_weaponused[client]));
	}
	EmitSoundToAll(WAND_FIREBALL_SOUND, client, SNDCHAN_AUTO, 80, _, 0.7);

	CreateTimer(0.2, FireMultipleFireBalls, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
}

public Action FireMultipleFireBalls(Handle Timer, int ref)
{
	int client = EntRefToEntIndex(ref);
	if (IsValidClient(client))
	{
		if(i_FireBallsToThrow[client] > 0)
		{
			float fAng[3], fPos[3];
			GetClientEyeAngles(client, fAng);
			GetClientEyePosition(client, fPos);

			static float speed = 1000.0;

			float fVel[3], fBuf[3];
			GetAngleVectors(fAng, fBuf, NULL_VECTOR, NULL_VECTOR);
			fVel[0] = fBuf[0]*speed;
			fVel[1] = fBuf[1]*speed;
			fVel[2] = fBuf[2]*speed;

			int entity = CreateEntityByName("tf_projectile_spellfireball");
			if(IsValidEntity(entity))
			{
				SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
				SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 0.0, true);	// Damage
				SetEntProp(entity, Prop_Send, "m_iTeamNum", GetEntProp(client, Prop_Send, "m_iTeamNum"));
				TeleportEntity(entity, fPos, fAng, NULL_VECTOR);
				DispatchSpawn(entity);
				TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, fVel);
				f_CustomGrenadeDamage[entity] = f_OriginalDamage[client];
				SetEntPropEnt(entity, Prop_Send, "m_hLauncher", EntRefToEntIndex(i_weaponused[client]));
			}
			EmitSoundToAll(WAND_FIREBALL_SOUND, client, SNDCHAN_AUTO, 80, _, 0.7);
			i_FireBallsToThrow[client] -= 1;
							
			return Plugin_Continue;
		}
		else
		{
			return Plugin_Stop;
		}
	}
	return Plugin_Stop;
}