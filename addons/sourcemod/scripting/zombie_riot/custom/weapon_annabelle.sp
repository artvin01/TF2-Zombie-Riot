#pragma semicolon 1
#pragma newdecls required


public void Weapon_Annabelle(int client, int weapon, bool crit, int slot)
{
	EmitSoundToAll("weapons/shotgun/shotgun_fire7.wav", client, SNDCHAN_STATIC, 80, _, 1.0);
//	Client_Shake(client, 0, 7.0, 4.0, 0.25);
}