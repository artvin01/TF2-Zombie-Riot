#pragma semicolon 1
#pragma newdecls required

public void Weapon_Anti_Material_Rifle(int client, int weapon, const char[] classname, bool &result)
{
	EmitSoundToAll("npc/vort/attack_shoot.wav", client, SNDCHAN_STATIC, 80, _, 1.0);
	Client_Shake(client, 0, 50.0, 25.0, 1.5);
}

public void Weapon_Anti_Material_Rifle_Deploy(int client, int weapon)
{
	if(Items_HasNamedItem(client, "Head Equipped Blue Goggles"))
	{
		Attributes_Set(weapon, 304, 1.1);
	}
}