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
	if(kv)
	{
		int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(IsValidEntity(weapon))
		{
			static char classname[36];
			GetEntityClassname(weapon, classname, sizeof(classname));
			if (i_IsWandWeapon[weapon])
			{
				Weapon_Wand_FireBallSpell(client, weapon, 1);
				return (GetGameTime() + 15.0);
			}
			else
			{
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				ShowGameText(client,"leaderboard_streak", 0, "Not usable Without a Magic Wand.");
				return 0.0;
			}
		}

	//	if(kv.GetNum("consume", 1))

	}
	return 0.0;
}
public void Weapon_Wand_FireBallSpell(int client, int weapon, int level)
{
	float damage;
	
	damage = Config_GetDPSOfEntity(weapon);

	damage *= 1.9;	

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

	i_FireBallsToThrow[client] = 1;
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