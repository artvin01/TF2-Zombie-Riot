#pragma semicolon 1
#pragma newdecls required

public void ArenaSpecials_RandomMiniboss(bool end)
{
	if(end)
		return;
	
	MiniBoss boss;
	float pos[3], ang[3];
	if(Waves_GetMiniBoss(boss) && Arena_GetCenterSpawnPoint(pos, ang))
	{
		int Text_Int = GetRandomInt(0, 2);
		if(boss.Sound[0])
		{
			for(int panzer_warning_client=1; panzer_warning_client<=MaxClients; panzer_warning_client++)
			{
				if(IsClientInGame(panzer_warning_client))
				{
					if(IsValidClient(panzer_warning_client))
					{
						SetGlobalTransTarget(panzer_warning_client);
						/*
							https://github.com/SteamDatabase/GameTracking-TF2/blob/master/tf/tf2_misc_dir/scripts/mod_textures.txt	
						
						*/
						switch(Text_Int)
						{
							case 0:
							{
								ShowGameText(panzer_warning_client, boss.Icon, 1, "%t", boss.Text_1);
							}
							case 1:
							{
								ShowGameText(panzer_warning_client, boss.Icon, 1, "%t", boss.Text_2);
							}
							case 2:
							{
								ShowGameText(panzer_warning_client, boss.Icon, 1, "%t", boss.Text_3);
							}
						}
					}

					if(boss.SoundCustom)
					{
						EmitCustomToClient(panzer_warning_client, boss.Sound, panzer_warning_client, SNDCHAN_AUTO, 90, _, 2.0);
					}
					else
					{
						EmitSoundToClient(panzer_warning_client, boss.Sound, panzer_warning_client, SNDCHAN_AUTO, 90, _, 1.0);
						EmitSoundToClient(panzer_warning_client, boss.Sound, panzer_warning_client, SNDCHAN_AUTO, 90, _, 1.0);
					}
				}
			}

			Citizen_MiniBossSpawn();
		}

		if(boss.HealthMulti <= 0.0)
			boss.HealthMulti = 1.0;

		DataPack pack;
		CreateDataTimer(boss.Delay, Timer_Delay_BossSpawn, pack, TIMER_FLAG_NO_MAPCHANGE);

		for(int i; i < 3; i++)
		{
			pack.WriteFloat(pos[i]);
			pack.WriteFloat(ang[i]);
		}

		pack.WriteCell(true);
		pack.WriteCell(boss.Index);
		pack.WriteCell(0);
		pack.WriteFloat(boss.HealthMulti / 30.0);
		pack.WriteString(boss.Data);
	}
}

public void ArenaSpecials_SpawnCar(bool end)
{
	if(end)
	{
		int entity = -1;
		while((entity=FindEntityByClassname(entity, "obj_vehicle")) != -1)
		{
			Vehicle_Exit(entity, false, true);
			RemoveEntity(entity);
		}
	}
	else
	{
		float pos[3], ang[3];

		if(Arena_GetCenterSpawnPoint(pos, ang))
		{
			static const char Vehicles[][] =
			{
				"vehicle_fulljeep",
				"vehicle_ambulance",
				"vehicle_fullapc"
			};

			NPC_CreateByName(Vehicles[GetURandomInt() % sizeof(Vehicles)], -1, pos, ang, TFTeam_Red, _, true);

			BfWrite bf = view_as<BfWrite>(StartMessageAll("HudNotifyCustom"));
			if(bf)
			{
				bf.WriteString("A car is here");
				bf.WriteString("hud_taunt_menu_icon");
				bf.WriteByte(0);
				EndMessage();
			}
		}
	}
}

public void ArenaSpecials_SpawnRebels(bool end)
{
	if(end)
		return;
	
	for(int i; i < 4; i++)
	{
		Citizen_SpawnAtPoint("temp", .team = TFTeam_Red);
		Citizen_SpawnAtPoint("temp", .team = TFTeam_Blue);
	}

	BfWrite bf = view_as<BfWrite>(StartMessageAll("HudNotifyCustom"));
	if(bf)
	{
		bf.WriteString("Got some extra backup");
		bf.WriteString("hud_taunt_menu_icon");
		bf.WriteByte(0);
		EndMessage();
	}
}
