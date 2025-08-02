#pragma semicolon 1
#pragma newdecls required

public void Weapon_Bison(int client, int weapon, bool crit, int slot)
{
	float damage = 18.0;
	damage *= Attributes_Get(weapon, 1, 1.0);
	damage *= Attributes_Get(weapon, 2, 1.0);

	Player_Laser_Logic Laser;
	float Radius = 5.0;
	Laser.client = client;
	Laser.Radius = Radius;
	Laser.damagetype = DMG_PLASMA;
	Laser.DoForwardTrace_Basic(1500.0);
	PlayerLaserDoDamageCombined(Laser, damage, damage);
	Offset_Vector({0.0, -8.0, -10.0}, Laser.Angles, Laser.Start_Point);
	int color[4] = {255, 0, 0, 60};
	DoPlayerLaserEffectsSmall(Laser, color);
}
