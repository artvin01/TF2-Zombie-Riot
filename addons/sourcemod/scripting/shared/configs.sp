#pragma semicolon 1
#pragma newdecls required

enum struct WeaponData
{
	char Classname[36];
	float Damage;
	float Pellets;
	float FireRate;
	float Reload;
	float Clip;
	float Charge;
	float Healing;
	float Range;
}

static ArrayList WeaponList;

public void Configs_ConfigsExecuted()
{
	char buffer[PLATFORM_MAX_PATH];
	KeyValues kv;
	
#if defined ZR
	if(!zr_ignoremapconfig.BoolValue)
#endif
	{
		char mapname[64];
		GetCurrentMap(mapname, sizeof(mapname));
		BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG);
		DirectoryListing dir = OpenDirectory(buffer);
		if(dir != INVALID_HANDLE)
		{
			FileType file;
			char filename[68];
			while(dir.GetNext(filename, sizeof(filename), file))
			{
				if(file != FileType_File)
					continue;

				if(SplitString(filename, ".cfg", filename, sizeof(filename)) == -1)
					continue;
					
				if(StrContains(mapname, filename))
					continue;

				kv = new KeyValues("Map");
				Format(buffer, sizeof(buffer), "%s/%s.cfg", buffer, filename);
				if(!kv.ImportFromFile(buffer))
					LogError("[Config] Found '%s' but was unable to read", buffer);

				break;
			}
			delete dir;
		}
		else
		{
			LogError("[Config] Directory '%s' does not exist", buffer);
		}
	}
	
	
#if defined ZR
	Store_ConfigSetup();
	Waves_SetupVote(kv);
	Waves_SetupMiniBosses(kv);
#endif
	
#if defined RPG
	Crafting_ConfigSetup(kv);
	Dungeon_ConfigSetup(kv);
	Fishing_ConfigSetup(kv);
	Garden_ConfigSetup(kv);
	Mining_ConfigSetup(kv);
	Music_ConfigSetup(kv);
	Quests_ConfigSetup(kv);
	Spawns_ConfigSetup(kv);
	Tinker_ConfigSetup(kv);
	
	TextStore_ConfigSetup(kv);

	BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG ... "/soundscript.txt");
	LoadSoundScript(buffer);
#endif

	delete kv;

	delete WeaponList;
	WeaponList = new ArrayList(sizeof(WeaponData));
	
	BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, "weapondata");
	kv = new KeyValues("WeaponData");
	kv.ImportFromFile(buffer);
	
	WeaponData data;
	kv.GotoFirstSubKey();
	do
	{
		if(kv.GetSectionName(data.Classname, sizeof(data.Classname)))
		{
			data.Damage = kv.GetFloat("damage");
			data.Pellets = kv.GetFloat("pellets", 1.0);
			data.FireRate = kv.GetFloat("firerate");
			data.Reload = kv.GetFloat("reload");
			data.Clip = kv.GetFloat("clip");
			data.Charge = kv.GetFloat("chargespeed");
			data.Healing = kv.GetFloat("healing");
			data.Range = kv.GetFloat("range");
			WeaponList.PushArray(data);
		}
	} while(kv.GotoNextKey());
	delete kv;
	
	ConVar_Enable();
	
	AdjustBotCount();
	
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client))
			OnClientPutInServer(client);
	}
}

stock float Config_GetDPSOfEntity(int entity)
{
	static char classname[36];
	GetEntityClassname(entity, classname, sizeof(classname));
	
	static WeaponData data;

	int i;
	int val = WeaponList.Length;

	for(; i<val; i++)
	{
		WeaponList.GetArray(i, data);
		if(StrEqual(classname, data.Classname))
			break;
	}
	
	if(i == val)
		return 1.0;
	
	// Damage and Pellets
	Address address = TF2Attrib_GetByDefIndex(entity, 410);
	if(address == Address_Null)
	{
		address = TF2Attrib_GetByDefIndex(entity, 2);
		if(address != Address_Null)
			data.Damage *= TF2Attrib_GetValue(address);
	}
	else
	{
		data.Damage *= TF2Attrib_GetValue(address);
	}

	address = TF2Attrib_GetByDefIndex(entity, 45);
	if(address != Address_Null)
		data.Pellets *= TF2Attrib_GetValue(address);
	
	data.Damage *= data.Pellets;

	address = TF2Attrib_GetByDefIndex(entity, 6);
	if(address != Address_Null)
		data.FireRate *= TF2Attrib_GetValue(address);
	
	
	address = TF2Attrib_GetByDefIndex(entity, 876);
	if(address != Address_Null)
		data.Damage *= TF2Attrib_GetValue(address);
	

	float damagedps;

	damagedps = data.Damage  / data.FireRate;
	if(damagedps > 1000000.0)
	{
		return 1.0;
	}
	else if(damagedps < 1.0)
	{
		return 1.0;
	}
	return damagedps;
}

void Config_CreateDescription(const char[] classname, const int[] attrib, const float[] value, int attribs, char[] buffer, int length)
{
	static WeaponData data;
	int i;
	int val = WeaponList.Length;

	float damage_Calc;
	float firerate_Calc;
	for(; i<val; i++)
	{
		WeaponList.GetArray(i, data);
		if(StrEqual(classname, data.Classname))
			break;
	}
	
	if(i == val)
		return;
	
	// Damage and Pellets
	if(data.Damage > 0)
	{
		float defaul = data.Damage;
		for(i=0; i<attribs; i++)
		{
			if(attrib[i]==1 || attrib[i]==2 || attrib[i]==1000)
				data.Damage *= value[i];
		}
		
		if(!data.Damage)
		{
			data.Damage = defaul;
			for(i=0; i<attribs; i++)
			{
				if(attrib[i] == 410)
					data.Damage *= value[i];
			}
		}

		if(data.Damage > 0)
		{
			if(data.Damage < 100.0)
			{
				Format(buffer, length, "%s\nDamage: %.1f", buffer, data.Damage);
			}
			else
			{
				Format(buffer, length, "%s\nDamage: %d", buffer, RoundFloat(data.Damage));
			}

			
			for(i=0; i<attribs; i++)
			{
				if(attrib[i] == 45)
					data.Pellets *= value[i];
			}
			
			i = RoundFloat(data.Pellets);
			if(i != 1)
				Format(buffer, length, "%sx%d", buffer, i);


			damage_Calc = data.Damage * data.Pellets;
		}
	}
	
	// Fire Rate
	if(data.FireRate)
	{
		for(i=0; i<attribs; i++)
		{
			if(attrib[i]==5 || attrib[i]==6 || attrib[i]==394 || attrib[i]==396)
				data.FireRate *= value[i];
		}
		
		Format(buffer, length, "%s\nFire Rate: %.3fs", buffer, data.FireRate);
		firerate_Calc = data.FireRate;
	}
	
	// Clip and Ammo
	for(i=0; i<attribs; i++)
	{
		if(attrib[i] == 303)
		{
			data.Clip = value[i];
			break;
		}
				
		if(attrib[i]==3 || attrib[i]==4 || attrib[i]==335 || attrib[i]==424)
			data.Clip *= value[i];
	}
	
	if(data.Clip > 0)
	{
		val = 1;
		for(i=0; i<attribs; i++)
		{
			if(attrib[i] == 298)
			{
				val = RoundFloat(value[i]);
				break;
			}
		}
		
		if(val == 1)
		{
			Format(buffer, length, "%s\nClip: %d", buffer, RoundFloat(data.Clip));
		}
		else
		{
			int clip = RoundFloat(data.Clip);
			int left = clip % val;
			if(left)
			{
				Format(buffer, length, "%s\nClip: %dx%d + %d", buffer, clip/val, val, left);
			}
			else
			{
				Format(buffer, length, "%s\nClip: %dx%d", buffer, clip/val, val);
			}
		}
		
		// Reload
		if(data.Reload)
		{
			for(i=0; i<attribs; i++)
			{
				if(attrib[i]==96 || attrib[i]==97 || attrib[i]==241)
					data.Reload *= value[i];
			}
			
			Format(buffer, length, "%s\nReload: %.3fs", buffer, data.Reload);
		}
	}
	
	bool medigun;
	
	// Healing and Overheal
	if(data.Healing)
	{
		for(i=0; i<attribs; i++)
		{
			if(attrib[i]==7 || attrib[i]==8 || attrib[i]==876)
			{
				data.Healing *= value[i];
			}
			else if(attrib[i] == 493)
			{
				data.Healing *= 1.0 + (value[i]*0.25);
			}
		}
		
		Format(buffer, length, "%s\nHealing: %d", buffer, RoundFloat(data.Healing));
		
		medigun = StrEqual(classname, "tf_weapon_medigun");
		if(medigun)
		{
			float overheal = 1.5;
			for(i=0; i<attribs; i++)
			{
				if(attrib[i]==11 || attrib[i]==105)
				{
					overheal *= value[i];
				}
				else if(attrib[i] == 482)
				{
					overheal *= 1.0 + (value[i]*0.25);
				}
			}
			
			if(overheal > 0)
				Format(buffer, length, "%s\nOverheal: x%.2f", buffer, overheal);
		}
	}
	
	// Charge Speed
	for(i=0; i<attribs; i++)
	{
		if(attrib[i] == 801)
		{
			data.Charge = value[i];
			break;
		}
	}
	
	if(data.Charge > 0)
	{
		for(i=0; i<attribs; i++)
		{
			if(attrib[i]==86 || attrib[i]==87 || attrib[i]==278 || attrib[i]==670 || attrib[i]==874)	// Lower is less time
			{
				data.Charge *= value[i];
			}
			else if(attrib[i]==9 || attrib[i]==10 || attrib[i]==41 || attrib[i]==90 || attrib[i]==91 || attrib[i] == 249)	// Higher is less time
			{
				if(value[i] > 1.0)
				{
					data.Charge *= 2.0 - value[i];
				}
				else if(value[i])
				{
					data.Charge /= value[i];
				}
				else
				{
					data.Charge = 0.0;
					break;
				}
			}
		}
		
		if(data.Charge > 0)
		{
			if(medigun)
			{
				val = 0;
				float duration = 8.0;
				for(i=0; i<attribs; i++)
				{
					if(attrib[i]==86 || attrib[i]==87 || attrib[i]==278 || attrib[i]==670 || attrib[i]==874)
					{
						val = RoundFloat(value[i]);
					}
					else if(attrib[i] == 314)
					{
						duration += value[i];
					}
				}
				
				switch(val)
				{
					case 1:
						Format(buffer, length, "%s\nCharge: %ds (Crits %.1fs)", buffer, RoundFloat(data.Charge), duration);
					case 2:
						Format(buffer, length, "%s\nCharge: %ds (Megaheal %.1fs)", buffer, RoundFloat(data.Charge), duration);
					case 3:
						Format(buffer, length, "%s\nCharge: %ds (Resist %.1fs)", buffer, RoundFloat(data.Charge), duration-5.5);
					default:
						Format(buffer, length, "%s\nCharge: %ds (Uber %.1fs)", buffer, RoundFloat(data.Charge), duration);
				}
			}
			else
			{
				Format(buffer, length, "%s\nCharge: %.2fs", buffer, data.Charge);
			}
		}
	}
	
	// Melee Range
	if(data.Range > 0)
	{
		for(i=0; i<attribs; i++)
		{
			if(attrib[i] == 784)
			{
				data.Range = 1.5;
				break;
			}
		}
		
		for(i=0; i<attribs; i++)
		{
			if(attrib[i] == 264)
			{
				data.Range *= value[i];
				break;
			}
		}
		
		Format(buffer, length, "%s\nRange: x%.2f", buffer, data.Range);
	}

	if(damage_Calc)
	{
		float damagepersecond;

		damagepersecond = damage_Calc / firerate_Calc;

		for(i=0; i<attribs; i++)
		{
			if(attrib[i] == 876)
			{
				damagepersecond *= value[i];
				break;
			}
		}

		Format(buffer, length, "%s\nDPS: %1.f", buffer, damagepersecond);
	}
}

#if defined ZR
bool Config_CreateNPCStats(const char[] classname, const int[] attrib, const float[] value, int attribs, WeaponData data)
{
	int i;
	int val = WeaponList.Length;
	for(; i<val; i++)
	{
		WeaponList.GetArray(i, data);
		if(StrEqual(classname, data.Classname))
			break;
	}
	
	if(i == val)
		return false;
	
	// Damage and Pellets
	if(data.Damage > 0)
	{
		for(i=0; i<attribs; i++)
		{
			if(attrib[i]==1 || attrib[i]==2 || attrib[i]==1000)
				data.Damage *= value[i];
		}
		
		for(i=0; i<attribs; i++)
		{
			if(attrib[i] == 45)
				data.Pellets *= value[i];
		}
	}
	
	// Fire Rate
	if(data.FireRate)
	{
		for(i=0; i<attribs; i++)
		{
			if(attrib[i]==5 || attrib[i]==6 || attrib[i]==394 || attrib[i]==396)
				data.FireRate *= value[i];
		}
	}
	
	// Clip and Ammo
	for(i=0; i<attribs; i++)
	{
		if(attrib[i] == 303)
		{
			data.Clip = value[i];
			break;
		}
				
		if(attrib[i]==3 || attrib[i]==4 || attrib[i]==335 || attrib[i]==424)
			data.Clip *= value[i];
	}
	
	if(data.Clip > 0)
	{
		val = 1;
		for(i=0; i<attribs; i++)
		{
			if(attrib[i] == 298)
			{
				val = RoundFloat(value[i]);
				break;
			}
		}
		
		if(val > 1)
			data.Clip /= float(val);
		
		// Reload
		if(data.Reload)
		{
			for(i=0; i<attribs; i++)
			{
				if(attrib[i]==96 || attrib[i]==97 || attrib[i]==241)
					data.Reload *= value[i];
			}
			
			bool shotgun = (!StrContains(classname, "tf_weapon_scattergun") ||
			!StrContains(classname, "tf_weapon_soda_popper") ||
			!StrContains(classname, "tf_weapon_pep_brawler_blaster") ||
			!StrContains(classname, "tf_weapon_rocketlauncher") ||
			!StrContains(classname, "tf_weapon_particle_cannon") ||
			!StrContains(classname, "tf_weapon_shotgun") ||
			!StrContains(classname, "tf_weapon_raygun") ||
			!StrContains(classname, "tf_weapon_grenadelauncher") ||
			!StrContains(classname, "tf_weapon_pipebomblauncher") ||
			!StrContains(classname, "tf_weapon_sentry_revenge") ||
			!StrContains(classname, "tf_weapon_drg_pomson"));
			
			if(shotgun)
			{
				for(i=0; i<attribs; i++)
				{
					if(attrib[i] == 43)
					{
						shotgun = false;
						break;
					}
				}
				
				if(shotgun)
					data.Reload *= data.Clip;
			}
		}
	}
	
	// Healing and Overheal
	if(data.Healing)
	{
		for(i=0; i<attribs; i++)
		{
			if(attrib[i]==7 || attrib[i]==8 || attrib[i]==876)
			{
				data.Healing *= value[i];
			}
			else if(attrib[i] == 493)
			{
				data.Healing *= 1.0 + (value[i]*0.25);
			}
		}
	}
	
	// Charge Speed
	for(i=0; i<attribs; i++)
	{
		if(attrib[i] == 801)
		{
			data.Charge = value[i];
			break;
		}
	}
	
	if(data.Charge > 0)
	{
		for(i=0; i<attribs; i++)
		{
			if(attrib[i]==86 || attrib[i]==87 || attrib[i]==278 || attrib[i]==670 || attrib[i]==874)	// Lower is less time
			{
				data.Charge *= value[i];
			}
			else if(attrib[i]==9 || attrib[i]==10 || attrib[i]==41 || attrib[i]==90 || attrib[i]==91 || attrib[i] == 249)	// Higher is less time
			{
				if(value[i] > 1.0)
				{
					data.Charge *= 2.0 - value[i];
				}
				else if(value[i])
				{
					data.Charge /= value[i];
				}
				else
				{
					data.Charge = 0.0;
					break;
				}
			}
		}
	}
	
	// Melee Range
	if(data.Range > 0)
	{
		for(i=0; i<attribs; i++)
		{
			if(attrib[i] == 784)
			{
				data.Range = 1.5;
				break;
			}
		}
		
		for(i=0; i<attribs; i++)
		{
			if(attrib[i] == 264)
			{
				data.Range *= value[i];
				break;
			}
		}
	}
	return true;
}
#endif	// ZR
