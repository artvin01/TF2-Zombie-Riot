#pragma semicolon 1
#pragma newdecls required

public void Weapon_Wand_Beam(int client, int weapon, bool crit)
{
	int mana_cost;
	if(!CanCastWand(client, weapon, mana_cost))
		return;

	SDKhooks_SetManaRegenDelayTime(client, 1.0);
	Mana_Hud_Delay[client] = 0.0;
	Current_Mana[client] -= mana_cost;
	delay_hud[client] = 0.0;

	float damage = 65.0 * Attributes_Get(weapon, 410, 1.0);
	ManaCalculationsBefore(client);

	Player_Laser_Logic Laser;
	float Radius = 7.0;
	Laser.client = client;
	Laser.Damage = damage;
	Laser.Radius = Radius;
	Laser.damagetype = DMG_PLASMA;
	Laser.DoForwardTrace_Basic(1500.0);
	Laser.Deal_Damage();
	Offset_Vector({0.0, -8.0, -10.0}, Laser.Angles, Laser.Start_Point);
	int color[4];
	color = AdjustColorToMana(Laser.client);
	DoPlayerLaserEffectsSmall(Laser, color);
}
void DoPlayerLaserEffectsSmall(Player_Laser_Logic Laser, int color[4])
{
	float Diameter = Laser.Radius * 2.0;

	int colorLayer1[4];
	SetColorRGBA(colorLayer1, color[0] * 5 + 765 / 8, color[1] * 5 + 765 / 8, color[2] * 5 + 765 / 8, color[3]);

	TE_SetupBeamPoints(Laser.Start_Point, Laser.End_Point, g_Ruina_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(Diameter * 0.3 * 1.28), ClampBeamWidth(Diameter * 0.3 * 1.28), 0, 1.0, colorLayer1, 3);
	TE_SendToAll(0.0);

	int glowColor[4];
	SetColorRGBA(glowColor, color[0], color[1], color[2], color[3]);
	TE_SetupBeamPoints(Laser.Start_Point, Laser.End_Point, g_Ruina_BEAM_Glow, 0, 0, 0, 0.22, ClampBeamWidth(Diameter * 0.3 * 1.28), ClampBeamWidth(Diameter * 0.3 * 1.28), 0, 1.5, glowColor, 0);
	TE_SendToAll(0.0);
}
static int[] AdjustColorToMana(int client)
{
	int color[4] = {255, 0, 255, 60};

	float Ratio = float(Current_Mana[client]) / max_mana[client];

	color[0] = RoundToFloor(255 * (1.0-Ratio));

	color[2] = RoundToFloor(255 * Ratio);

	return color;
}
bool CanCastWand(int client, int weapon, int &mana_cost)
{
	mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));
	mana_cost = RoundToNearest(float(mana_cost) * LaserWeapons_ReturnManaCost(weapon));
	if(mana_cost > Current_Mana[client])
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		return false;
	}
	return true;
}
