#pragma semicolon 1
#pragma newdecls required

public void Weapon_Star_shooter(int client, int weapon, bool crit, int slot)
{
	int chose = GetRandomInt(0, sizeof(g_DefaultLaserLaunchSound)-1);
	EmitSoundToAll(g_DefaultLaserLaunchSound[chose], client, 80, _, _, 1.0);

	Client_Shake(client, 0, 30.0, 15.0, 0.5);

	float damage = 50.0;
	damage *= Attributes_Get(weapon, 1, 1.0);
	damage *= Attributes_Get(weapon, 2, 1.0);

	Player_Laser_Logic Laser;
	float Radius = 5.0;
	Laser.client = client;
	Laser.Radius = Radius;
	Laser.damagetype = DMG_PLASMA;
	Laser.DoForwardTrace_Basic(9000.0);	//holy shit thats a big range, no wonder the 2x dmg bonus at max range almost never kicks in!
	PlayerLaserDoDamageCombined(Laser, damage, 2.0*damage);	//star shooter does 2x dmg at max range!
	Offset_Vector({0.0, -8.0, -10.0}, Laser.Angles, Laser.Start_Point);
	int color[4] = {128, 0, 128, 60};
	DoPlayerLaserEffectsBigger(Laser, color);
}
