#pragma semicolon 1
#pragma newdecls required

#define PARTICLE_JARATE		""
#define SOUND_JAREXPLODE	"weapons/weapons/jar_explode.wav"

void Wand_Potions_ClearAll()
{
	Zero(i_FireBallsToThrow);
	Zero(ability_cooldown);
}

void Wand_Potions_Precache()
{
	PrecacheSound(SOUND_JAREXPLODE);
}

public void Weapon_Wand_PotionBasicM1(int client, int weapon, bool &crit, int slot)
{
	PotionM1(client, weapon, Weapon_Wand_PotionBasicTouch);
}

static void PotionM1(int client, int weapon, SDKHookCB touch)
{
	int mana_cost;
	Address address = TF2Attrib_GetByDefIndex(weapon, 733);
	if(address != Address_Null)
		mana_cost = RoundToCeil(TF2Attrib_GetValue(address));
	
	if(Current_Mana[client] < mana_cost)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + 0.5);
		return;
	}

	Mana_Regen_Delay[client] = GetGameTime() + 1.0;
	Mana_Hud_Delay[client] = 0.0;
	Current_Mana[client] -= mana_cost;
	delay_hud[client] = 0.0;

	int entity = CreateEntityByName("tf_projectile_pipe");
	if(entity > MaxClients)
	{
		float pos[3], ang[3], vel[3];
		GetClientEyeAngles(client, ang);
		GetClientEyePosition(client, pos);

		float damage = 65.0;
		address = TF2Attrib_GetByDefIndex(weapon, 410);
		if(address != Address_Null)
			damage *= TF2Attrib_GetValue(address);
		
		float speed = 1000.0;
		address = TF2Attrib_GetByDefIndex(weapon, 103);
		if(address != Address_Null)
			speed *= TF2Attrib_GetValue(address);
		
		vel[0] = Cosine(DegToRad(ang[0])) * Cosine(DegToRad(ang[1])) * speed;
		vel[1] = Cosine(DegToRad(ang[0])) * Sine(DegToRad(ang[1])) * speed;
		vel[2] = Sine(DegToRad(ang[0])) * -speed;

		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
		SetEntProp(entity, Prop_Send, "m_iTeamNum", TFTeam_Red);
		SetEntProp(entity, Prop_Send, "m_nSkin", 0);
		SetEntPropEnt(entity, Prop_Send, "m_hThrower", client);
		SetEntPropEnt(entity, Prop_Send, "m_hOriginalLauncher", weapon);
		SetEntPropEnt(entity, Prop_Send, "m_hLauncher", weapon);

		int model = GetEntProp(weapon, Prop_Send, "m_iWorldModelIndex");
		for(int i; i < 4; i++)
		{
			SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", model, _, i);
		}
		
		DispatchSpawn(entity);
		TeleportEntity(entity, pos, ang, vel);
		IsCustomTfGrenadeProjectile(entity, damage);
		SDKHook(entity, SDKHook_StartTouchPost, touch);
	}
}

public void Weapon_Wand_PotionBasicTouch(int entity, int target)
{
	if(target)
	{
		if(target <= MaxClients)
			return;
		
		if(GetEntProp(target, Prop_Send, "m_iTeamNum") == TFTeam_Red)
			return;
	}

	SDKUnhook(entity, SDKHook_StartTouchPost, Weapon_Wand_PotionBasicTouch);

	float pos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
	ParticleEffectAt(pos, )

	/*float pos1[3], pos2[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos1);
	
	float damage = 4.0;
	address = TF2Attrib_GetByDefIndex(weapon, 410);
	if(address != Address_Null)
		damage *= TF2Attrib_GetValue(address);
	
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	int weapon = GetEntPropEnt(entity, Prop_Send, "m_hLauncher");

	int i = MaxClients + 1;
	while((i = FindEntityByClassname(i, "base_boss")) != -1)
	{
		if(!b_NpcHasDied[i] && GetEntProp(i, Prop_Send, "m_iTeamNum") != 2)
		{
			GetEntPropVector(i, Prop_Data, "m_vecAbsOrigin", pos2);
			if(GetVectorDistance(pos1, pos2, true) < (EXPLOSION_RADIUS * EXPLOSION_RADIUS)) 
			{
				StartBleedingTimer(i, owner, damage, 4, weapon);
			}
		}
	}*/
}

public void Weapon_Wand_PotionBasicM2(int client, int weapon, bool &crit, int slot)
{
	static const int mana_cost = 100;
	if(Current_Mana[client] < mana_cost)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + 0.5);
		return;
	}
	
	if(Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + 0.5);
		return;
	}

	Ability_Apply_Cooldown(client, slot, 10.0);
}