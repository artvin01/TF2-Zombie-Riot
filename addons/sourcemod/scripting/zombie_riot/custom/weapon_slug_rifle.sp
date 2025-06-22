#pragma semicolon 1
#pragma newdecls required

float Uranium_TimeTillBigHit[MAXPLAYERS][MAXENTITIES];
void Uranium_MapStart()
{
	Zero2(Uranium_TimeTillBigHit);
}

void EnemyResetUranium(int enemy)
{
	for(int client; client <= MaxClients ; client++)
	{
		Uranium_TimeTillBigHit[client][enemy] = 0.0;
	}
}

public void Weapon_Anti_Material_Rifle(int client, int weapon, const char[] classname, bool &result)
{
	EmitSoundToAll("npc/vort/attack_shoot.wav", client, SNDCHAN_STATIC, 80, _, 1.0);
	Client_Shake(client, 0, 50.0, 25.0, 1.5);
}


public void Weapon_Anti_Material_Rifle_Deploy(int client, int weapon)
{
	if (i_CustomWeaponEquipLogic[weapon] == WEAPON_URANIUM_RIFLE)	 // 125
	{
	//	if(Items_HasNamedItem(client, "Head Equipped Blue Goggles"))
		{
			Attributes_Set(weapon, 304, 1.1);
		}
	}
}


void WeaponUranium_OnTakeDamage(int attacker,int victim, float &damage, float damagePosition[3])
{
	if(Uranium_TimeTillBigHit[attacker][victim] < GetGameTime())
	{
		damage *= 2.2;
		if(!CheckInHud())
		{
			Uranium_TimeTillBigHit[attacker][victim] = GetGameTime() + 40.0;
			EmitSoundToClient(attacker, "weapons/physcannon/energy_sing_explosion2.wav", attacker, SNDCHAN_STATIC, 80, _, 1.0);
			TE_Particle("mvm_soldier_shockwave", damagePosition, NULL_VECTOR, {0.0,0.0,0.0}, -1, _, _, _, _, _, _, _, _, _, 0.0, .clientspec = attacker);
		}
	}
}