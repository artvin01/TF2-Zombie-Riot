#pragma semicolon 1
#pragma newdecls required

static int Ms_HitEntities[MAXENTITIES];
static float Ms_Weapon_Energy[MAXPLAYERS];
static float Ms_Weapon_Energy_Max[MAXPLAYERS];
static Handle MSwordTimer[MAXPLAYERS];
static float MSwordHUDDelay[MAXPLAYERS];
static int i_Current_Pap[MAXPLAYERS];

static bool Task_I[MAXPLAYERS];
static bool Task_II[MAXPLAYERS];
static bool Task_III[MAXPLAYERS];
static bool Task_IV[MAXPLAYERS];
static bool Task_V[MAXPLAYERS];

/*public void Market_Gardener_Attack(int client, int weapon, bool crit)
{
	return;
}*/

public void MSword_OnMapStart()
{
	PrecacheSoundCustom("baka_zr/minecraft_challenge_complete.mp3");
	PrecacheSoundCustom("baka_zr/blacksmith_tick_quad.mp3");
	PrecacheSoundCustom("baka_zr/blacksmith_tick_five.mp3");
	PrecacheSoundCustom("baka_zr/blacksmith_tick_quad_friend.mp3");
	PrecacheSoundCustom("baka_zr/blacksmith_tick_five_friend.mp3");
	
	Zero(Ms_Weapon_Energy);
	Zero(Ms_Weapon_Energy_Max);
	Zero(Ms_HitEntities);
	Zero(MSwordHUDDelay);
	Zero(i_Current_Pap);
	
	Zero(Task_I);
	Zero(Task_II);
	Zero(Task_III);
	Zero(Task_IV);
	Zero(Task_V);
}

public void MSword_Enable(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if(MSwordTimer[client] != null)
	{
		if(i_CustomWeaponEquipLogic[weapon]==WEAPON_MINECRAFT_SWORD)
		{
			i_Current_Pap[client] = RoundToFloor(Attributes_Get(weapon, 122, 0.0));
			Ms_Weapon_Energy_Max[client]=Attributes_Get(weapon, 41, 2.0);
			static char name[32], advancement[32];
			GetClientName(client, name, sizeof(name));
			switch(i_Current_Pap[client])
			{
				case 1:
				{
					if(!Task_I[client])
					{
						Format(advancement, sizeof(advancement), "[%t]", "Task Stone Age");
						CPrintToChatAll("%t", "Minecraft Sword Advancement", name, advancement);
						Task_I[client]=true;
					}
				}
				case 2:
				{
					if(!Task_II[client])
					{
						Format(advancement, sizeof(advancement), "[%t]", "Task Isn't It Iron Pick");
						CPrintToChatAll("%t", "Minecraft Sword Advancement", name, advancement);
						Task_II[client]=true;
					}
				}
				case 3:
				{
					if(!Task_III[client])
					{
						Format(advancement, sizeof(advancement), "[%t]", "Task Enchanter");
						CPrintToChatAll("%t", "Minecraft Sword Advancement", name, advancement);
						Task_III[client]=true;
					}
				}
				case 4:
				{
					if(!Task_IV[client])
					{
						Format(advancement, sizeof(advancement), "[%t]", "Task Diamonds!");
						CPrintToChatAll("%t", "Minecraft Sword Advancement", name, advancement);
						Task_IV[client]=true;
					}
				}
				case 5:
				{
					if(!Task_V[client])
					{
						Format(advancement, sizeof(advancement), "[%t]", "Task Cover Me in Debris");
						CPrintToChatAll("%t", "Minecraft Sword Challenge", name, advancement);
						EmitCustomToAll("baka_zr/minecraft_challenge_complete.mp3", _, _, _, _, 1.0);
						EmitCustomToAll("baka_zr/minecraft_challenge_complete.mp3", _, _, _, _, 1.0);
						Task_V[client]=true;
					}
				}
			}
			delete MSwordTimer[client];
			MSwordTimer[client] = null;
			DataPack pack;
			MSwordTimer[client] = CreateDataTimer(0.2, Timer_MSword, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
	}
	else if(i_CustomWeaponEquipLogic[weapon]==WEAPON_MINECRAFT_SWORD)
	{
		i_Current_Pap[client] = RoundToFloor(Attributes_Get(weapon, 122, 0.0));
		Ms_Weapon_Energy_Max[client]=Attributes_Get(weapon, 41, 2.0);
		DataPack pack;
		MSwordTimer[client] = CreateDataTimer(0.2, Timer_MSword, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}

static Action Timer_MSword(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon) || i_CustomWeaponEquipLogic[weapon]!=WEAPON_MINECRAFT_SWORD)
	{
		MSwordTimer[client] = null;
		return Plugin_Stop;
	}
	if(GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon") == weapon)
	{
		if(Ms_Weapon_Energy_Max[client]>0.0)
		{
			if(Ms_Weapon_Energy[client] < Ms_Weapon_Energy_Max[client])Ms_Weapon_Energy[client] += 0.25;
			if(Ms_Weapon_Energy[client] > Ms_Weapon_Energy_Max[client])Ms_Weapon_Energy[client] = Ms_Weapon_Energy_Max[client];
			if(MSwordHUDDelay[client] < GetGameTime())
			{
				PrintHintText(client, "휩쓸기 [%i％]", RoundToFloor(Ms_Weapon_Energy[client]/Ms_Weapon_Energy_Max[client]*100.0));
				StopSound(client, SNDCHAN_STATIC, "ui/hint.wav");
				MSwordHUDDelay[client] = GetGameTime() + 0.5;
			}
		}
	}
	return Plugin_Continue;
}

public void MSword_Attack(int client, int weapon, bool &result, int slot)
{
	if(Ms_Weapon_Energy_Max[client]>0.0)
	{
		if(Ms_Weapon_Energy[client] >= Ms_Weapon_Energy_Max[client])
		{
			DataPack pack;
			CreateDataTimer(0.25, Timer_MSword_Attack, pack, TIMER_FLAG_NO_MAPCHANGE);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		MSwordHUDDelay[client]=0.0;
	}
}

static Action Timer_MSword_Attack(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon) || i_CustomWeaponEquipLogic[weapon]!=WEAPON_MINECRAFT_SWORD)
		return Plugin_Stop;
	float damage=130.0;
	
	damage *= Attributes_Get(weapon, 2, 1.0);
	damage *= Attributes_Get(weapon, 425, 1.0);
	damage *= 0.25;
	
	DataPack pack2 = new DataPack();
	pack2.WriteCell(GetClientUserId(client));
	pack2.WriteCell(EntIndexToEntRef(weapon));
	pack2.WriteCell(RoundToFloor(Attributes_Get(weapon, 4, 4.0)));
	pack2.WriteFloat(Attributes_Get(weapon, 99, 150.0));
	pack2.WriteFloat(damage);
	RequestFrames(Weapon_Sweeping_Edge, 12, pack2);
	Ms_Weapon_Energy[client]=0.0;
	return Plugin_Stop;
}

public void MSword_NPCTakeDamage(int attacker, int victim, float &damage, int weapon)
{
	if(!IsValidEntity(victim) || GetTeam(victim) == TFTeam_Red)
		return;
	if(!IsValidClient(attacker))
		return;
	if(CheckInHud())
		return;
	else if(!(GetEntityFlags(attacker) & FL_ONGROUND))
	{
		damage*=Attributes_Get(weapon, 410, 1.1);
		DisplayCritAboveNpc(victim, attacker, true, _, _, false);
	}
	float f_Silenced = Attributes_Get(weapon, 411, 1.0);
	f_Silenced-=1.0;
	if(f_Silenced>0.0)
		ApplyStatusEffect(attacker, victim, "Silenced", f_Silenced);
	f_Silenced = Attributes_Get(weapon, 397, 1.0);
	f_Silenced-=1.0;
	if(f_Silenced>0.0)
		NPC_Ignite(victim, attacker, f_Silenced, weapon);
}

static void Weapon_Sweeping_Edge(DataPack pack)
{
	pack.Reset();
	int client = 	GetClientOfUserId(pack.ReadCell());
	int weapon = EntRefToEntIndex(pack.ReadCell());
	int MaxTarget = pack.ReadCell();
	float MaxRange = pack.ReadFloat();
	float damage = pack.ReadFloat();
	if(IsValidClient(client) && IsValidCurrentWeapon(client, weapon))
	{
		//This melee is too unique, we have to code it in a different way.
		static float pos2[3], ang2[3];
		GetClientEyePosition(client, pos2);
		GetClientEyeAngles(client, ang2);
		/*
			Extra effects on bare swing
		*/
		/*static float AngEffect[3];
		AngEffect = ang2;
		AngEffect[1] -= 90.0;
		
		float Speed = 1500.0;
		int MaxRepeats = 4;
		int PreviousProjectile;
		for(int repeat; repeat <= MaxRepeats; repeat++)
		{
			int projectile = Wand_Projectile_Spawn(client, Speed, 99999.9, 0.0, -1, weapon, "", AngEffect);
			DataPack pack2 = new DataPack();
			int laser = projectile;
			if(IsValidEntity(PreviousProjectile))
			{
				laser = ConnectWithBeam(projectile, PreviousProjectile, 200, 200, 200, 10.0, 10.0, 1.0);
			}
			SetEntityMoveType(projectile, MOVETYPE_NOCLIP);
			PreviousProjectile = projectile;
			pack2.WriteCell(EntIndexToEntRef(projectile));
			pack2.WriteCell(EntIndexToEntRef(laser));
			RequestFrames(Sweeping_Edge_DeleteLaserAndParticle, 18, pack2);
			AngEffect[1] += (180.0 / float(MaxRepeats));
		}*/

		float vecSwingForward[3];
		GetAngleVectors(ang2, vecSwingForward, NULL_VECTOR, NULL_VECTOR);
		ang2[0] = fixAngle(ang2[0]);
		ang2[1] = fixAngle(ang2[1]);
		
		b_LagCompNPC_No_Layers = true;
		StartLagCompensation_Base_Boss(client);
		
		ArrayList targetList = new ArrayList();
		// TR_EnumerateEntitiesSphere(pos2, MaxRange, PARTITION_NON_STATIC_EDICTS, TraceSweeping_Edge, client);
		targetList.Push(client);
		TR_EnumerateEntitiesSphere(pos2, MaxRange, PARTITION_NON_STATIC_EDICTS, TraceSweeping_Edge, targetList);
		
		FinishLagCompensation_Base_boss();
		// Remove client from target list
		// Avoid shifting by swapping last element and client
		int length = targetList.Length;
		targetList.SwapAt(0, length - 1);
		targetList.Erase(--length);
		for (int i; i < length; i++) {
			if(i>=MaxTarget)
				break;
			static float ang3[3];
			
			int target = targetList.Get(i);
			
			float pos1[3];
			WorldSpaceCenter(target, pos1);
			GetVectorAnglesTwoPoints(pos2, pos1, ang3);
			
			// fix all angles
			ang3[0] = fixAngle(ang3[0]);
			ang3[1] = fixAngle(ang3[1]);

			// verify angle validity
			if(!(fabs(ang2[0] - ang3[0]) <= 90.0 || (fabs(ang2[0] - ang3[0]) >= (360.0-90.0))))
				continue;

			if(!(fabs(ang2[1] - ang3[1]) <= 90.0 || (fabs(ang2[1] - ang3[1]) >= (360.0-90.0))))
				continue;
			
			// ensure no wall is obstructing
			if(Can_I_See_Enemy_Only(client, target))
			{
				// success
				float damage_force[3]; CalculateDamageForce(vecSwingForward, 100000.0, damage_force);
				SDKHooks_TakeDamage(target, client, client, damage, DMG_CLUB, weapon, damage_force, pos1);
			}
		}
		
		delete targetList;
		/*
		for(int i=0; i < MAXENTITIES; i++)
		{
			Ms_HitEntities[i] = 0;
		}
		TR_EnumerateEntitiesSphere(pos2, MaxRange, PARTITION_NON_STATIC_EDICTS, TraceSweeping_Edge, client);
		
		//	bool Hit = false;
		for (int entity_traced = 0; entity_traced < 8; entity_traced++)
		{
			if(Ms_HitEntities[entity_traced] > 0)
			{
				static float ang3[3];

				float pos1[3];
				WorldSpaceCenter(Ms_HitEntities[entity_traced], pos1);
				GetVectorAnglesTwoPoints(pos2, pos1, ang3);

				// fix all angles
				ang3[0] = fixAngle(ang3[0]);
				ang3[1] = fixAngle(ang3[1]);

				// verify angle validity
				if(!(fabs(ang2[0] - ang3[0]) <= 90.0 ||
				(fabs(ang2[0] - ang3[0]) >= (360.0-90.0))))
					continue;

				if(!(fabs(ang2[1] - ang3[1]) <= 90.0 ||
				(fabs(ang2[1] - ang3[1]) >= (360.0-90.0))))
					continue;

				// ensure no wall is obstructing
				if(Can_I_See_Enemy_Only(client, Ms_HitEntities[entity_traced]))
				{
					// success
			//		Hit = true;
					float damage_force[3]; CalculateDamageForce(vecSwingForward, 100000.0, damage_force);
					SDKHooks_TakeDamage(Ms_HitEntities[entity_traced], client, client, damage, DMG_CLUB, weapon, damage_force, pos1);
				}
			}
			else
			{
				break;
			}
		}
		*/
	}
	delete pack;
}

static void Sweeping_Edge_DeleteLaserAndParticle(DataPack pack)
{
	pack.Reset();
	int Projectile = EntRefToEntIndex(pack.ReadCell());
	int Laser = EntRefToEntIndex(pack.ReadCell());
	if(IsValidEntity(Projectile))
	{
		int particle = EntRefToEntIndex(i_WandParticle[Projectile]);
		if(IsValidEntity(particle))
			RemoveEntity(particle);
		
		RemoveEntity(Projectile);
	}
	if(Projectile != Laser)
	{
		if(IsValidEntity(Laser))
			RemoveEntity(Laser);
	}
	delete pack;
}

static bool TraceSweeping_Edge(int entity, ArrayList list)
{
	if(IsValidEnemy(list.Get(0), entity, true, true)) //Must detect camo.
	{
		list.Push(entity);
		if (list.Length >= 8) {
			return false;
		}
	}
	return true;
}

/*
static bool TraceSweeping_Edge(int entity, int filterentity)
{
	if(IsValidEnemy(filterentity, entity, true, true)) //Must detect camo.
	{
		//This will automatically take care of all the checks, very handy. force it to also target invul enemies.
		for(int i=0; i < MAXENTITIES; i++)
		{
			if(!Ms_HitEntities[i])
			{
				Ms_HitEntities[i] = entity;
				break;
			}
		}
	}
	//always keep going!
	return true;
}
*/