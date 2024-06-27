#pragma semicolon 1
#pragma newdecls required

// Metal drain per second
#define MERCHANT_METAL_DRAIN	10
#define Ammo_Merchant	28

enum
{
	Merchant_Jaye = 0,
	Merchant_Nothing,
	Merchant_Lee,
	Merchant_Swire
}

enum
{
	Nothing_Debuff = 0,
	Nothing_Damage,
	Nothing_Res,
}

static const int SupportBuildings[] = { 2, 5, 9, 14, 14, 15 };
static int MerchantLevel[MAXTF2PLAYERS] = {-1, ...};
static int i_AdditionalSupportBuildings[MAXTF2PLAYERS] = {0, ...};

static int MerchantWeaponRef[MAXTF2PLAYERS] = {-1, ...};
static int MerchantAbilitySlot[MAXTF2PLAYERS];
static int MerchantEffect[MAXTF2PLAYERS];
static float MerchantLeftAt[MAXTF2PLAYERS];
static ArrayList MerchantAttribs[MAXTF2PLAYERS];

static int ParticleRef[MAXTF2PLAYERS] = {-1, ...};
static int MerchantStyle[MAXTF2PLAYERS] = {-1, ...};
static Handle EffectTimer[MAXTF2PLAYERS];

void Merchant_RoundStart()
{
	Zero(i_AdditionalSupportBuildings);

	for(int i; i < sizeof(MerchantStyle); i++)
	{
		MerchantStyle[i] = -1;
	}
}

int Merchant_Additional_SupportBuildings(int client)
{
	return i_AdditionalSupportBuildings[client];
}

bool Merchant_IsAMerchant(int client)
{
	return view_as<bool>(EffectTimer[client]);
}

void Merchant_Enable(int client, int weapon)
{
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_MERCHANT)
	{
		MerchantLevel[client] = RoundFloat(Attributes_Get(weapon, 868, 0.0));

		if(MerchantLevel[client] >= sizeof(SupportBuildings))
			MerchantLevel[client] = sizeof(SupportBuildings) - 1;

		if(!EffectTimer[client])
			EffectTimer[client] = CreateTimer(0.5, TimerEffect, client, TIMER_REPEAT);

		i_AdditionalSupportBuildings[client] = SupportBuildings[MerchantLevel[client]];
	}
}

static Action TimerEffect(Handle timer, int client)
{
	if(IsClientInGame(client) && MerchantLevel[client] > -1)
	{
		if(!dieingstate[client] && IsPlayerAlive(client) && TeutonType[client] == TEUTON_NONE && i_HealthBeforeSuit[client] == 0)
		{
			if(MerchantWeaponRef[client] != -1)
			{
				int weapon = EntRefToEntIndex(MerchantWeaponRef[client]);
				if(weapon != -1)
				{
					if(MerchantStyle[client] == Merchant_Swire || GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon") == weapon)
					{
						b_IsCannibal[client] = true;

						if(!Waves_InSetup())
						{
							int ammo = GetAmmo(client, Ammo_Metal);
							int cost = MERCHANT_METAL_DRAIN / 2;
							if(cost > ammo)
							{
								MerchantEnd(client);
								return Plugin_Continue;
							}
							
							MerchantThink(client, cost);
							SetAmmo(client, Ammo_Metal, ammo - cost);
							CurrentAmmo[client][Ammo_Metal] = ammo - cost;
						}

						return Plugin_Continue;
					}
				}

				MerchantEnd(client);
			}

			if(MerchantWeaponRef[client] == -1)
			{
				int weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
				if(weapon != -1)
				{
					if(i_CustomWeaponEquipLogic[weapon] == WEAPON_MERCHANT)
						return Plugin_Continue;
				}
			}
		}
		else
		{
			MerchantEnd(client);
			return Plugin_Continue;
		}
	}

	MerchantLevel[client] = -1;
	MerchantWeaponRef[client] = -1;
		
	if(ParticleRef[client] != -1)
	{
		int entity = EntRefToEntIndex(ParticleRef[client]);
		if(entity > MaxClients)
		{
			TeleportEntity(entity, OFF_THE_MAP);
			RemoveEntity(entity);
		}
		
		ParticleRef[client] = -1;
	}
	i_AdditionalSupportBuildings[client] = 0;
	EffectTimer[client] = null;
	return Plugin_Stop;
}

public void Weapon_MerchantSecondary_M2(int client, int weapon, bool crit, int slot)
{
	if(MerchantStyle[client] < 0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Reload to Interact");
		return;
	}

	if(dieingstate[client] != 0 || (Ability_Check_Cooldown(client, slot) > 0.0 && !CvarInfiniteCash.BoolValue))
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}

	MerchantStart(client, slot);
}

public void Weapon_MerchantSecondary_R(int client, int weapon, bool crit, int slot)
{
	if(MerchantWeaponRef[client] != -1)
		MerchantEnd(client);

	Menu menu = new Menu(MerchantMenuH);

	menu.SetTitle("Select Merchant Style:\n ");

	switch(MerchantLevel[client])
	{
		case -1:
		{
		}
		case 0:
		{
			menu.AddItem("0", "Fish Market");
			menu.AddItem("-1", "Martial Artist (Upgrade Needed)", ITEMDRAW_DISABLED);
			menu.AddItem("-1", "The Investigator (Upgrade Needed)", ITEMDRAW_DISABLED);
			menu.AddItem("-1", "Wine Market (Upgrade Needed)", ITEMDRAW_DISABLED);
		}
		case 1:
		{
			menu.AddItem("0", "Fish Market (Anti-Seaborn)");
			menu.AddItem("1", "Martial Artist (Retreats)");
			menu.AddItem("-1", "The Investigator (Upgrade Needed)", ITEMDRAW_DISABLED);
			menu.AddItem("-1", "Wine Market (Upgrade Needed)", ITEMDRAW_DISABLED);
		}
		case 2:
		{
			menu.AddItem("0", "Fish Market (Anti-Seaborn)");
			menu.AddItem("1", "Martial Artist (Retreats, Stuns)");
			menu.AddItem("2", "The Investigator (Steal Attack Speed)");
			menu.AddItem("-1", "Wine Market (Upgrade Needed)", ITEMDRAW_DISABLED);
		}
		default:
		{
			menu.AddItem("0", "Fish Market (Anti-Seaborn)");
			menu.AddItem("1", "Martial Artist (Retreats, Stuns)");
			menu.AddItem("2", "The Investigator (Steal Attack Speed, Anti-Stun)");
			menu.AddItem("3", "Wine Market (Ranged Guns, Self Revive)");
		}
	}

	menu.Display(client, MENU_TIME_FOREVER);
}

static int MerchantMenuH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Select:
		{
			char buffer[4];
			menu.GetItem(choice, buffer, sizeof(buffer));

			MerchantStyle[client] = StringToInt(buffer);
		}
	}
	return 0;
}

public void Weapon_MerchantPrimary_M2(int client, int weapon, bool crit, int slot)
{
	Store_SwapItems(client);
}

void Merchant_NPCTakeDamage(int victim, int attacker, float &damage, int weapon)
{
	if(MerchantWeaponRef[attacker] == -1)
		return;
	
	switch(MerchantStyle[attacker])
	{
		case Merchant_Jaye:
		{
			// Jaye: Bonus Damage vs Seaborn
			if(i_BleedType[victim] == BLEEDTYPE_SEABORN)
			{
				switch(MerchantLevel[attacker])
				{
					case 1:
						damage *= 1.125;
					
					case 2:
						damage *= 1.15;
					
					case 3:
						damage *= 1.25;
					
					case 4:
						damage *= 1.275;
					
					case 5:
						damage *= 1.3;
				}
			}

			// Jaye: Silence Effect
			if(!MerchantEffect[attacker])
				NpcStats_SilenceEnemy(victim, MerchantLevel[attacker] > 3 ? 2.0 : 1.0);
		}
		case Merchant_Nothing:
		{
			if(MerchantEffect[attacker] >= 0)
			{
				float gameTime = GetGameTime();
				
				// Nothing: Debuff Effect
				if(MerchantEffect[attacker] == Nothing_Debuff)
				{
					float time = gameTime + 2.5;
					if(f_CrippleDebuff[victim] < time)
						f_CrippleDebuff[victim] = time;
				}

				// Nothing: Stun Effect
				if(TF2_IsPlayerInCondition(attacker, TFCond_FocusBuff))
				{
					TF2_RemoveCondition(attacker, TFCond_FocusBuff);
					
					float stun;

					switch(MerchantLevel[attacker])
					{
						case 2:
						{
							damage *= 1.25;
							stun = 1.5;
						}
						case 3:
						{
							damage *= 1.5;
							stun = 2.0;
						}
						case 4:
						{
							damage *= 1.65;
							stun = 2.5;
						}
						case 5:
						{
							damage *= 1.75;
							stun = 2.5;
						}
					}

					if(b_thisNpcIsARaid[victim])
						stun *= 0.25;

					FreezeNpcInTime(victim, stun);
				}

				MerchantLeftAt[attacker] = GetGameTime();
			}
		}
		case Merchant_Lee:
		{
			f_BombEntityWeaponDamageApplied[victim][attacker] = damage * (MerchantLevel[attacker] > 4 ? 0.133333 : 0.1);
			i_HowManyBombsOnThisEntity[victim][attacker]++;
			i_HowManyBombsHud[victim]++;
			Apply_Particle_Teroriser_Indicator(victim);

			bool blocking = EntRefToEntIndex(MerchantEffect[attacker]) == victim;
			bool elite = MerchantLevel[attacker] > 2;

			float pos1[3];
			GetClientAbsOrigin(attacker, pos1);
			ParticleEffectAt(pos1, elite ? "heavy_ring_of_fire_fp" : "heavy_ring_of_fire_fp_child03", 0.5);

			if(blocking || elite)
			{
				float pos2[3];

				bool alone = true;
				for(int i; i < i_MaxcountNpcTotal; i++)
				{
					int entity = EntRefToEntIndex(i_ObjectsNpcsTotal[i]);
					if(entity != -1 && entity != victim && !b_NpcHasDied[entity] && GetTeam(entity) != TFTeam_Red)
					{
						GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos2);
						if(GetVectorDistance(pos1, pos2, true) < 100000.0)	// 300 HU
						{
							alone = false;
							
							if(elite)
							{
								if(i_NpcWeight[entity] < 3 && !b_NoKnockbackFromSources[entity])
								{
									FreezeNpcInTime(entity, 0.1);

									if(i_NpcWeight[entity] != 2)
										Custom_Knockback(attacker, entity, 400.0, true, true, true);
								}
							}
							else
							{
								break;
							}
						}
					}
				}

				if(blocking)
				{
					int strength = elite ? 1 : 0;
					if(alone)
						strength++;
					
					float reduce;
					switch(strength)
					{
						case 0:
						{
							f_LeeMinorEffect[victim] = GetGameTime() + 0.75;
							reduce -= 0.035;
						}
						case 1:
						{
							f_LeeMajorEffect[victim] = GetGameTime() + 0.75;
							reduce -= 0.07;
						}
						case 2:
						{
							f_LeeSuperEffect[victim] = GetGameTime() + 0.75;
							reduce -= 0.14;
						}
					}

					SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack") - reduce);
				}
			}
		}
	}
}

void Merchant_GunTakeDamage(int victim, int attacker, float &damage)
{
	if(MerchantWeaponRef[attacker] == -1)
		return;
	
	damage *= Attributes_GetOnPlayer(attacker, 287, true) / Attributes_GetOnPlayer(attacker, 343, true, true);

	int force = MerchantLevel[attacker] > 4 ? 4 : 3;
	if(i_NpcWeight[victim] < force && !b_NoKnockbackFromSources[victim])
	{
		Custom_Knockback(attacker, victim, 400.0, true, true, true);
	}
}

void Merchant_NPCTakeDamagePost(int attacker, float damage, int weapon)
{
	if(MerchantWeaponRef[attacker] == -1)
		return;
	
	// Jaye: Healing Effect
	if(MerchantStyle[attacker] == Merchant_Jaye && MerchantEffect[attacker])
	{
		float base = 65.0 * Attributes_Get(weapon, 2, 1.0);
		if(damage && base)
		{
			// Res/Buffs effects healing
			float healing = damage / base;
			if(healing > 2.0)
				healing = 2.0;

			int health = GetClientHealth(attacker);
			int target = health < SDKCall_GetMaxHealth(attacker) ? attacker : 0;
			if(!target)
				health = 9999;
			
			float pos1[3], pos2[3];
			GetClientAbsOrigin(attacker, pos1);
			
			for(int i = 1; i <= MaxClients; i++)
			{
				if(i != attacker && TeutonType[i] == TEUTON_NONE && !dieingstate[i] && IsClientInGame(i) && IsPlayerAlive(i))
				{
					GetClientAbsOrigin(attacker, pos2);
					if(GetVectorDistance(pos1, pos2, true) < 100000.0)	// 300 HU
					{
						int hp = GetClientHealth(i);
						if(hp > 0 && hp < health && hp < SDKCall_GetMaxHealth(i))
						{
							target = i;
							health = hp;
						}
					}
				}
			}

			for(int i; i < i_MaxcountNpcTotal; i++)
			{
				int entity = EntRefToEntIndex(i_ObjectsNpcsTotal[i]);
				if(entity != -1 && !b_NpcHasDied[entity] && GetTeam(entity) == TFTeam_Red)
				{
					GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos2);
					if(GetVectorDistance(pos1, pos2, true) < 100000.0)	// 300 HU
					{
						int hp = GetEntProp(entity, Prop_Data, "m_iHealth");
						if(hp > 0 && hp < health && hp < GetEntProp(entity, Prop_Data, "m_iMaxHealth"))
						{
							target = entity;
							health = hp;
						}
					}
				}
			}

			if(target)
			{
				healing *= MerchantLevel[attacker] * 25.0;

				HealEntityGlobal(attacker, target, healing, 1.0, 1.0);
			}
		}
	}
}

void Merchant_SelfTakeDamage(int victim, int attacker, float &damage)
{
	if(MerchantWeaponRef[victim] == -1)
		return;
	
	switch(MerchantStyle[victim])
	{
		case Merchant_Nothing:
		{
			int maxhealth = SDKCall_GetMaxHealth(victim);
			if((GetClientHealth(victim) - RoundFloat(damage)) < (maxhealth / 5))
			{
				float healing = MerchantLevel[victim] > 1 ? (0.5 + (MerchantLevel[victim] * 0.05)) : 0.45;
				HealEntityGlobal(victim, victim, maxhealth * healing, 1.0, 5.0, HEAL_SELFHEAL);
				TF2_AddCondition(victim, TFCond_SpeedBuffAlly, 5.0, victim);
				MerchantEnd(victim);
			}
		}
		case Merchant_Lee:
		{
			//float pos1[3], pos2[3];
			//GetClientAbsOrigin(victim, pos1);
			//GetEntPropVector(attacker, Prop_Data, "m_vecAbsOrigin", pos2);
			//if(GetVectorDistance(pos1, pos2, true) < 100000.0)	// 300 HU
			if(IsValidEnemy(victim, attacker, true, true))
				MerchantEffect[victim] = EntIndexToEntRef(attacker);
		}
	}
}

bool Merchant_OnLethalDamage(int client)
{
	if(MerchantWeaponRef[client] != -1 && MerchantStyle[client] == Merchant_Swire)
	{
		int ammo = GetAmmo(client, Ammo_Metal);
		int cost = MERCHANT_METAL_DRAIN * 10 * RoundFloat(Pow(2.0, float(MerchantEffect[client])));
		if(ammo >= cost)
		{
			SetAmmo(client, Ammo_Metal, ammo - cost);
			CurrentAmmo[client][Ammo_Metal] = ammo - cost;
			MerchantEffect[client]++;

			SetEntityHealth(client, SDKCall_GetMaxHealth(client) * 7 / 10);
			return true;
		}
	}
	return false;
}

static void MerchantStart(int client, int slot)
{
	if(MerchantWeaponRef[client] != -1)
	{
		MerchantEnd(client);
		return;
	}

	float fcost;
	switch(MerchantStyle[client])
	{
		case Merchant_Jaye:
		{
			MerchantEffect[client] = 0;

			if(MerchantLevel[client] > 2)
			{
				int buttons = GetClientButtons(client);
				if(buttons & IN_JUMP)
				{
				}
				else if((buttons & IN_DUCK) || (GetURandomInt() % 2))
				{
					MerchantEffect[client] = 1;
				}
			}

			if(MerchantEffect[client])
			{
				// Healing
				switch(MerchantLevel[client])
				{
					case 2:
						fcost = 17.0;
					
					case 3:
						fcost = 11.666667;
					
					case 4:
						fcost = 11.0;
					
					case 5:
						fcost = 10.333333;
				}
			}
			else
			{
				// Silence
				switch(MerchantLevel[client])
				{
					case 0:
						fcost = 13.0;
					
					case 1, 2:	// E0 S4 P0, E1 S7 P1
						fcost = 12.0;
					
					case 3:	// Pot 5
						fcost = 10.0;
					
					case 4:	// Module
						fcost = 8.333333;
					
					case 5:
						fcost = 7.666667;
				}
			}
		}
		case Merchant_Nothing:
		{
			MerchantEffect[client] = MerchantLevel[client] > 1 ? (GetURandomInt() % 3) : -1;

			if((MerchantLeftAt[client] + 10.0) > GetGameTime())
			{
				// Redeploy has a discount
				if(MerchantLevel[client] > 4)
				{
					fcost = 3.333333;
				}
				else
				{
					fcost = 5.0;
				}
			}
			else
			{
				switch(MerchantLevel[client])
				{
					case 1:
						fcost = 6.0;
					
					case 2:
						fcost = 13.0;
					
					case 3:	// Pot 1
						fcost = 12.0;
					
					case 4, 5:	// Module
						fcost = 10.333333;
				}
			}
		}
		case Merchant_Lee:
		{
			MerchantEffect[client] = -1;

			switch(MerchantLevel[client])
			{
				case 2:
					fcost = 19.0;
				
				case 3:
					fcost = 20.0;
				
				case 4:
					fcost = 19.0;
				
				case 5:	// Module
					fcost = 15.666667;
			}
		}
		case Merchant_Swire:
		{
			MerchantEffect[client] = 0;
			fcost = 9.0;
		}
	}

	int ammo = GetAmmo(client, Ammo_Metal);
	int cost = RoundFloat(MERCHANT_METAL_DRAIN * fcost);
	if(ammo < (cost * 2))
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "No Ammo Supplies");
		Ability_Apply_Cooldown(client, slot, 0.3);
		return;
	}

	int weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
	if(weapon != -1)
	{
		Rogue_OnAbilityUse(weapon);

		MerchantAbilitySlot[client] = slot;
		MerchantWeaponRef[client] = EntIndexToEntRef(weapon);
		SetAmmo(client, Ammo_Metal, ammo - cost);
		CurrentAmmo[client][Ammo_Metal] = ammo - cost;

		float damage = 2.0;
		float speed = 0.5;

		char particle[64];

		switch(MerchantStyle[client])
		{
			case Merchant_Jaye:
			{
				ClientCommand(client, "playgamesound player/invuln_on_vaccinator.wav");

				if(MerchantEffect[client])
				{
					strcopy(particle, sizeof(particle), "utaunt_balloonicorn_reindeer_snowfloor");

					// Healing
					switch(MerchantLevel[client])
					{
						case 2:
							damage *= 1.4;
						
						case 3:
							damage *= 1.5;
						
						case 4:
							damage *= 1.55;
						
						case 5:
							damage *= 1.6;
					}
				}
				else
				{
					strcopy(particle, sizeof(particle), "utaunt_arcane_green_sparkle_ring");

					// Silence
					switch(MerchantLevel[client])
					{
						case 0:
							damage *= 1.15;
						
						case 1:
							damage *= 1.3;
						
						case 2:
							damage *= 1.45;
						
						case 3:
							damage *= 1.5;
						
						case 4:
							damage *= 1.6;
						
						case 5:
							damage *= 1.7;
					}
				}
			}
			case Merchant_Nothing:
			{
				ClientCommand(client, "playgamesound player/invuln_on_vaccinator.wav");
				
				if(MerchantEffect[client] >= 0)
				{
					MerchantLeftAt[client] = GetGameTime();

					switch(MerchantLevel[client])
					{
						case 2:
							damage *= 1.4;
						
						case 3:
							damage *= 1.5;
						
						case 4:
							damage *= 1.55;
						
						case 5:
							damage *= 1.6;
					}

					switch(MerchantEffect[client])
					{
						case Nothing_Debuff:
						{
							strcopy(particle, sizeof(particle), "utaunt_arcane_green_sparkle_ring");
						}
						case Nothing_Damage:
						{
							speed *= MerchantLevel[client] > 4 ? 0.78125 : 0.8;
							strcopy(particle, sizeof(particle), "utaunt_arcane_yellow_sparkle_ring");
						}
						case Nothing_Res:
						{
							MerchantAddAttrib(client, 206, (MerchantLevel[client] == 6 ? 0.5 : (MerchantLevel[client] == 3 ? 0.6 : 0.55)));
							strcopy(particle, sizeof(particle), "utaunt_arcane_purple_sparkle_ring");
						}
					}
				}
				else
				{
					strcopy(particle, sizeof(particle), "utaunt_arcane_purple_sparkle_ring");
				}
			}
			case Merchant_Lee:
			{
				strcopy(particle, sizeof(particle), "utaunt_gifts_floorglow_brown");
				
				if(MerchantLevel[client] > 2)
				{
					ClientCommand(client, "playgamesound mvm/mvm_tank_horn.wav");

					damage *= (MerchantLevel[client] > 4 ? 1.5 : (MerchantLevel[client] == 4 ? 1.45 : 1.4));
					MerchantAddAttrib(client, 205, MerchantLevel[client] > 4 ? 0.3 : 0.4);
					MerchantAddAttrib(client, 206, 0.75);
				}
				else
				{
					ClientCommand(client, "playgamesound player/invuln_on_vaccinator.wav");
					
					damage *= 1.4;
					MerchantAddAttrib(client, 205, 0.75);
				}
			}
			case Merchant_Swire:
			{
				strcopy(particle, sizeof(particle), "utaunt_electricity_cloud_electricity_WY");
				
				ClientCommand(client, "playgamesound mvm/sentrybuster/mvm_sentrybuster_intro.wav");

				SetAmmo(client, Ammo_Merchant, 1);

				Store_GiveSpecificItem(client, "Loyalty and Generosity");
				Store_GiveSpecificItem(client, "Courtesy Gift");
				Store_GiveSpecificItem(client, "Lavish and Prodigal");
			}
		}

		if(particle[0])
		{
			float pos[3]; GetClientAbsOrigin(client, pos);
			pos[2] += 1.0;

			int entity = ParticleEffectAt(pos, particle, -1.0);
			if(entity > MaxClients)
			{
				SetParent(client, entity);
				ParticleRef[client] = EntIndexToEntRef(entity);
			}
		}

		MerchantAddAttrib(client, 2, damage);
		MerchantAddAttrib(client, 6, speed);
		SetPlayerActiveWeapon(client, weapon);
	}
}

static void MerchantAddAttrib(int client, int attrib, float value)
{
	int weapon = EntRefToEntIndex(MerchantWeaponRef[client]);
	if(weapon != -1)
	{
		any array[2];
		if(!MerchantAttribs[client])
			MerchantAttribs[client] = new ArrayList(2);
		
		Attributes_SetMulti(weapon, attrib, value);

		array[0] = view_as<any>(attrib);
		array[1] = view_as<any>(value);
		MerchantAttribs[client].PushArray(array);
	}
}

static void MerchantEnd(int client)
{
	if(MerchantWeaponRef[client] == -1)
		return;

	if(ParticleRef[client] != -1)
	{
		int entity = EntRefToEntIndex(ParticleRef[client]);
		if(entity > MaxClients)
		{
			TeleportEntity(entity, OFF_THE_MAP);
			RemoveEntity(entity);
		}

		ParticleRef[client] = -1;
	}

	int weapon = EntRefToEntIndex(MerchantWeaponRef[client]);
	if(weapon != -1)
	{
		if(MerchantAttribs[client])
		{
			any array[2];
			int length = MerchantAttribs[client].Length;
			for(int i; i < length; i++)
			{
				MerchantAttribs[client].GetArray(i, array);
				Attributes_SetMulti(weapon, view_as<int>(array[0]), 1.0 / view_as<float>(array[1]));
			}
		}
	}

	weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
	if(weapon != -1)
	{
		float cooldown = 25.0;

		switch(MerchantStyle[client])
		{
			case Merchant_Jaye:
			{
				if(MerchantLevel[client] > 2)
					cooldown -= 3.0;
			}
			case Merchant_Nothing:
			{
				//cooldown = 5.0;
			}
		}

		Ability_Apply_Cooldown(client, MerchantAbilitySlot[client], cooldown, weapon);
	}
	
	Store_RemoveSpecificItem(client, "Loyalty and Generosity");
	Store_RemoveSpecificItem(client, "Courtesy Gift");
	Store_RemoveSpecificItem(client, "Lavish and Prodigal");

	for( int entity = 1; entity <= MAXENTITIES; entity++ ) 
	{
		if (IsValidEntity(entity))
		{
			static char buffer[64];
			GetEntityClassname(entity, buffer, sizeof(buffer));
			if(IsEntitySpikeValue(entity) == 1 && !StrContains(buffer, "tf_projectile_pipe_remote"))
			{
				int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
				if(owner == client) //Hardcode to this index.
				{
					SetEntitySpike(entity, 0);
					RemoveEntity(entity);
				}
			}
		}
	}

	ClientCommand(client, "playgamesound player/invuln_off_vaccinator.wav");

	b_IsCannibal[client] = false;
	MerchantWeaponRef[client] = -1;
	MerchantLeftAt[client] = GetGameTime();
	delete MerchantAttribs[client];
	SetAmmo(client, Ammo_Merchant, 0);
}

static void MerchantThink(int client, int &cost)
{
	switch(MerchantStyle[client])
	{
		case Merchant_Jaye:
		{
			if(MerchantLevel[client] > 2)
				cost = cost * 2 / 3;
		}
		case Merchant_Nothing:
		{
			if(MerchantLevel[client] > 2 && !TF2_IsPlayerInCondition(client, TFCond_FocusBuff))
			{
				if((MerchantLeftAt[client] + (MerchantLevel[client] == 5 ? 6.0 : 8.0)) < GetGameTime())
					TF2_AddCondition(client, TFCond_FocusBuff);
			}

			if(MerchantLevel[client] > 3)
				cost = cost * 2 / 3;
			
		}
		case Merchant_Lee:
		{
			if(MerchantLevel[client] > 2 && TF2_IsPlayerInCondition(client, TFCond_Dazed))
			{
				TF2_RemoveCondition(client, TFCond_Dazed);

				int entity = EntRefToEntIndex(MerchantEffect[client]);
				if(IsValidEnemy(client, entity, true, true))
				{
					if(!b_thisNpcIsARaid[entity])
						FreezeNpcInTime(entity, 3.0);
				}

				cost += MERCHANT_METAL_DRAIN * 2;
			}
			else if(MerchantLevel[client] > 4)
			{
				cost = cost * 2 / 3;
			}
		}
		case Merchant_Swire:
		{
			if(GetAmmo(client, Ammo_Heal) < 300)
				SetAmmo(client, Ammo_Heal, 300);

			int ammo = GetAmmo(client, Ammo_Merchant);
			if(ammo < 10 && !(GetURandomInt() % 6))
			{
				SetAmmo(client, Ammo_Merchant, ammo + 1);
				ClientCommand(client, "playgamesound items/ammo_pickup.wav");
				ClientCommand(client, "playgamesound items/ammo_pickup.wav");
			}
		}
	}
}