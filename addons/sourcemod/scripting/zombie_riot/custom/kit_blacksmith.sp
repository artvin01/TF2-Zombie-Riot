#pragma semicolon 1
#pragma newdecls required

#define TINKER_LIMIT	4

enum struct TinkerEnum
{
	int AccountId;
	int StoreIndex;
	int Attrib[TINKER_LIMIT];
	float Value[TINKER_LIMIT];
	float Luck[TINKER_LIMIT];
	char Name[64];
	int Rarity;
	bool Addition[TINKER_LIMIT];
	int CustomMode[TINKER_LIMIT];
}

static const int SupportBuildings[] = { 2, 2, 5, 9, 14, 14, 15 };
static const int MetalGain[] = { 0, 5, 8, 11, 15, 20, 35 };
static const float Cooldowns[] = { 150.0, 130.0, 110.0, 90.0, 70.0, 50.0, 30.0 };
static int SmithLevel[MAXPLAYERS] = {-1, ...};
static int i_AdditionalSupportBuildings[MAXPLAYERS] = {0, ...};

static int ParticleRef[MAXPLAYERS] = {-1, ...};
static Handle EffectTimer[MAXPLAYERS];

static ArrayList Tinkers;

void Blacksmith_RoundStart()
{
	Zero(i_AdditionalSupportBuildings);
	delete Tinkers;
}

bool Blacksmith_Lastman(int client)
{
	bool Purnell_Went_Nuts = false;
	if(EffectTimer[client] != null)
		Purnell_Went_Nuts = true;
	
	return Purnell_Went_Nuts;
}
int Blacksmith_Additional_SupportBuildings(int client)
{
	return i_AdditionalSupportBuildings[client];
}

bool Blacksmith_HasTinker(int client, int index)
{
	if(Tinkers)
	{
		int account = GetSteamAccountID(client, false);
		if(account)
		{
			static TinkerEnum tinker;
			int length = Tinkers.Length;
			for(int a; a < length; a++)
			{
				Tinkers.GetArray(a, tinker);
				if(tinker.AccountId == account && tinker.StoreIndex == index)
					return true;
			}
		}
	}
	
	return false;
}

void Blacksmith_ExtraDesc(int client, int index)
{
	if(Tinkers)
	{
		int account = GetSteamAccountID(client, false);
		if(account)
		{
			static TinkerEnum tinker;
			int length = Tinkers.Length;
			for(int a; a < length; a++)
			{
				Tinkers.GetArray(a, tinker);
				if(tinker.AccountId == account && tinker.StoreIndex == index)
				{
					CPrintToChat(client, "{yellow}%s (Tier %d)", tinker.Name, tinker.Rarity + 1);

					for(int b; b < sizeof(tinker.Attrib); b++)
					{
						if(!tinker.Attrib[b])
							break;
						
						Blacksmith_PrintAttribValue(client, tinker.Attrib[b], tinker.Value[b], tinker.Luck[b],  tinker.Addition[b], tinker.CustomMode[b]);
					}

					break;
				}
			}
		}
	}
}

bool Blacksmith_IsASmith(int client)
{
	return view_as<bool>(EffectTimer[client]);
}

void Blacksmith_Enable(int client, int weapon)
{
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_BLACKSMITH)
	{
		SmithLevel[client] = RoundFloat(Attributes_Get(weapon, 868, 0.0)) + 1;

		if(SmithLevel[client] >= sizeof(MetalGain))
			SmithLevel[client] = sizeof(MetalGain) - 1;

		delete EffectTimer[client];
		EffectTimer[client] = CreateTimer(0.5, Blacksmith_TimerEffect, client, TIMER_REPEAT);

		i_AdditionalSupportBuildings[client] = SupportBuildings[SmithLevel[client]];
		Weapon_OnBuyUpdateBuilding(client);
	}

	if(Tinkers)
	{
		int account = GetSteamAccountID(client, false);
		if(account)
		{
			static TinkerEnum tinker;
			int length = Tinkers.Length;
			for(int a; a < length; a++)
			{
				Tinkers.GetArray(a, tinker);
				if(tinker.AccountId == account && tinker.StoreIndex == StoreWeapon[weapon])
				{
					ApplyStatusEffect(weapon, weapon, "Tinkering Curiosity", 99999999.9);
					for(int b; b < sizeof(tinker.Attrib); b++)
					{
						if(!tinker.Attrib[b])
							break;
						
						Attributes_SetMulti(weapon, tinker.Attrib[b], tinker.Value[b]);
					}

					break;
				}
			}
		}
	}
}

public Action Blacksmith_TimerEffect(Handle timer, int client)
{
	if(IsClientInGame(client) && SmithLevel[client] > -1)
	{
		if(!dieingstate[client] && IsPlayerAlive(client) && TeutonType[client] == TEUTON_NONE && i_HealthBeforeSuit[client] == 0)
		{
			int weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
			if(weapon != -1)
			{
				if(i_CustomWeaponEquipLogic[weapon] == WEAPON_BLACKSMITH)
				{
					if(!Waves_InSetup() && GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon") == weapon)
					{
						SetAmmo(client, Ammo_Metal, GetAmmo(client, Ammo_Metal) + MetalGain[SmithLevel[client]]);
						CurrentAmmo[client][3] = GetAmmo(client, 3);
					}

					i_AdditionalSupportBuildings[client] = SupportBuildings[SmithLevel[client]];

					if(SmithLevel[client] > 0 && ParticleRef[client] == -1)
					{
						float pos[3]; GetClientAbsOrigin(client, pos);
						pos[2] += 1.0;

						int entity = ParticleEffectAt(pos, "utaunt_hands_floor2_red", -1.0);
						if(entity > MaxClients)
						{
							SetParent(client, entity);
							ParticleRef[client] = EntIndexToEntRef(entity);
						}
					}
					
					return Plugin_Continue;
				}
			}
		}
		else
		{
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

			return Plugin_Continue;
		}
	}

	SmithLevel[client] = -1;
		
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

public void Weapon_BlacksmithMelee_M2(int client, int weapon, bool crit, int slot)
{
	if(dieingstate[client] != 0 || Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}

	Rogue_OnAbilityUse(client, weapon);
	Ability_Apply_Cooldown(client, slot, 10.0);

	ClientCommand(client, "playgamesound weapons/gunslinger_three_hit.wav");

	ApplyTempAttrib(weapon, 2, 2.0, 2.0);
	ApplyTempAttrib(weapon, 6, 0.25, 2.0);
}

/*
int Blacksmith_Level(int client)
{
	return SmithLevel[client];
}
*/

static int AnvilClickedOn[MAXPLAYERS];
static int ClickedWithWeapon[MAXPLAYERS];
void Blacksmith_BuildingUsed(int entity, int client)
{
	AnvilClickedOn[client] = EntIndexToEntRef(entity);
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon == -1)
		return;
	ClickedWithWeapon[client] = EntIndexToEntRef(weapon);

	Anvil_Menu(client);
}
void Blacksmith_BuildingUsed_Internal(int weapon ,int entity, int client, int owner, bool reset)
{
	if(owner == -1 || SmithLevel[owner] < 0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		DestroyBuildingDo(entity);
		SPrintToChat(client, "%t", "The Blacksmith Failed!");
		return;
	}
	
	int account = GetSteamAccountID(client, false);
	if(!account)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		ApplyBuildingCollectCooldown(entity, client, 3.0);
		return;
	}

	TinkerEnum tinker;
	int found = -1;
	if(Tinkers)
	{
		int length = Tinkers.Length;
		for(int a; a < length; a++)
		{
			Tinkers.GetArray(a, tinker);
			if(tinker.AccountId == account && tinker.StoreIndex == StoreWeapon[weapon])
			{
				found = a;
				break;
			}
		}
	}

	if(found == -1)
	{
		tinker.AccountId = account;
		tinker.StoreIndex = StoreWeapon[weapon];
	}
	
	Zero(tinker.Attrib);
	Zero(tinker.CustomMode);
	Zero(tinker.Addition);
	tinker.Rarity = 0;
	if(reset)
	{
		SetGlobalTransTarget(client);
		
		if(found == -1)
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Blacksmith No Attribs");

			ApplyBuildingCollectCooldown(entity, client, 2.0);
			return;
		}

		tinker.Rarity = -1;
		Tinkers.Erase(found);
		PrintToChat(client, "%t", "Removed Tinker Attributes");
	}
	else
	{
		switch(SmithLevel[owner])
		{
			case 0, 1:
			{
				
			}
			case 2:
			{
				if((GetURandomInt() % 4) == 0)
					tinker.Rarity = 1;
			}
			case 3:
			{
				int rand = GetURandomInt();
				if((rand % 7) == 0)
				{
					tinker.Rarity = 2;
				}
				else if((rand % 3) == 0)
				{
					tinker.Rarity = 1;
				}
			}
			case 4:
			{
				int rand = GetURandomInt();
				if((rand % 5) == 0)
				{
					tinker.Rarity = 2;
				}
				else if((rand % 2) == 0)
				{
					tinker.Rarity = 1;
				}
			}
			default:
			{
				if((GetURandomInt() % 3) == 0)
				{
					tinker.Rarity = 2;
				}
				else
				{
					tinker.Rarity = 1;
				}
			}
		}

		for(int i; i < sizeof(tinker.Luck); i++)
		{
			tinker.Luck[i] = GetURandomFloat();
		}

		char classname[64];
		GetEntityClassname(weapon, classname, sizeof(classname));
		int slot = TF2_GetClassnameSlot(classname, weapon);

		if(i_OverrideWeaponSlot[weapon] != -1)
		{
			slot = i_OverrideWeaponSlot[weapon];
		}
		bool BlockNormal = false;
		switch(i_CustomWeaponEquipLogic[weapon])
		{
			case WEAPON_BOOMERANG:
			{
				BlockNormal = true;
				//boomerang is very special.
				switch(GetURandomInt() % 4)
				{
					case 0:
						TinkerMeleeRapidSwing(tinker.Rarity, tinker);
					case 1:
						TinkerHeavyTrigger(tinker.Rarity, tinker);
					case 2:
						TinkerRangedSlowHeavyProj(tinker.Rarity, tinker);
					case 3:
						TinkerRangedFastProj(tinker.Rarity, tinker);
				}
			}
			case WEAPON_SIGIL_BLADE:
			{
				BlockNormal = true;
				// Mage Weapon
				switch(GetURandomInt() % 3)
				{
					case 0:
						TinkerHastyMage(tinker.Rarity, tinker);
					case 1:
						TinkerHeavyMage(tinker.Rarity, tinker);
					case 2:
						TinkerTankMage(tinker.Rarity, tinker);
				}
			}
			case WEAPON_MINECRAFT_SWORD:
			{
				BlockNormal = true;
				switch(SmithLevel[owner])
				{
					case 0:
					{
						tinker.Rarity = 0;
					}
					case 1:
					{
						if((GetURandomInt() % 4) == 0)
							tinker.Rarity = 1;
						else tinker.Rarity = 0;
					}
					case 2:
					{
						int rand = GetURandomInt();
						if((rand % 7) == 0)
						{
							tinker.Rarity = 2;
						}
						else if((rand % 3) == 0)
						{
							tinker.Rarity = 1;
						}
						else tinker.Rarity = 0;
					}
					case 3:
					{
						int rand = GetURandomInt();
						if((rand % 12) == 0)
						{
							tinker.Rarity = 3;
						}
						else if((rand % 7) == 0)
						{
							tinker.Rarity = 2;
						}
						else if((rand % 3) == 0)
						{
							tinker.Rarity = 1;
						}
						else tinker.Rarity = 0;
					}
					case 4:
					{
						int rand = GetURandomInt();
						if((rand % 12) == 0)
						{
							tinker.Rarity = 4;
						}
						if((rand % 7) == 0)
						{
							tinker.Rarity = 3;
						}
						else if((rand % 5) == 0)
						{
							tinker.Rarity = 2;
						}
						else if((rand % 2) == 0)
						{
							tinker.Rarity = 1;
						}
						else tinker.Rarity = 0;
					}
					default:
					{
						int rand = GetURandomInt();
						if((rand % 7) == 0)
						{
							tinker.Rarity = 4;
						}
						else if((rand % 5) == 0)
						{
							tinker.Rarity = 3;
						}
						else if((rand % 3) == 0)
						{
							tinker.Rarity = 2;
						}
						else if((rand % 2) == 0)
						{
							tinker.Rarity = 1;
						}
						else tinker.Rarity = 0;
					}
				}
				switch(GetURandomInt() % 7)
				{
					case 0:Tinker_MS_Sharpness(tinker.Rarity, tinker);
					case 1:Tinker_MS_Smite(tinker.Rarity, tinker);
					case 2:Tinker_MS_SweepingEdge(tinker.Rarity, tinker);
					case 3:Tinker_MS_BaneofArthropods(tinker.Rarity, tinker);
					case 4:Tinker_MS_FireAspect(tinker.Rarity, tinker);
					case 5:Tinker_MS_QuickCharge(tinker.Rarity, tinker);
					case 6:Tinker_MS_CurseofGlassy(tinker.Rarity, tinker);
					default:Tinker_MS_Sharpness(tinker.Rarity, tinker);
				}
			}
		}
		if(!BlockNormal)
		{
			if(i_IsWandWeapon[weapon])
			{
				// Mage Weapon
				switch(GetURandomInt() % 4)
				{
					case 0:
						TinkerHastyMage(tinker.Rarity, tinker);
					case 1:
						TinkerHeavyMage(tinker.Rarity, tinker);
					case 2:
						TinkerConcentrationMage(tinker.Rarity, tinker);
					case 3:
						TinkerTankMage(tinker.Rarity, tinker);
				}
			}
			else if(Attributes_Get(weapon, 8, 0.0) != 0.0)
			{
				//mediguns, they work uniqurely
				if(StrEqual(classname, "tf_weapon_medigun"))
				{
					switch(GetURandomInt() % 3)
					{
						case 0:
							TinkerMedigun_FastHeal(tinker.Rarity, tinker);
						case 1:
							TinkerMedigun_Overhealer(tinker.Rarity, tinker);
						case 2:
							TinkerMedigun_Uberer(tinker.Rarity, tinker);
					}
				}
				else
				{
					if(slot == TFWeaponSlot_Melee)
					{
						TinkerMedicWeapon_GlassyMedic(tinker.Rarity, tinker);
					}
					else
					{
						switch(GetURandomInt() % 2)
						{
							case 0:
								TinkerMedicWeapon_GlassyMedic(tinker.Rarity, tinker);
							case 1:
								TinkerMedicWeapon_BurstHealMedic(tinker.Rarity, tinker);
						}					
					}

					//anything else.
				}
			}
			else if(i_IsWrench[weapon] && slot != TFWeaponSlot_Melee)
			{
				//any wrench weapon that isnt melee?
				TinkerBuilderRepairMaster(tinker.Rarity, tinker);
			}
			else if(slot == TFWeaponSlot_Melee)
			{
				if(i_IsWrench[weapon])
				{
					if(Attributes_Get(weapon, 264, 0.0) != 0.0)
					{
						switch(GetURandomInt() % 2)
						{
							case 0:
								TinkerBuilderRepairMaster(tinker.Rarity, tinker);
							case 1:
								TinkerBuilderLongSwing(tinker.Rarity, tinker);
						}
					}
					else
					{
						switch(GetURandomInt() % 2)
						{
							case 0:
								TinkerBuilderRepairMaster(tinker.Rarity, tinker);
							case 1:
								TinkerBuilderLongSwing(tinker.Rarity, tinker);
						}					
					}
					// Wrench Weapon
				}
				else
				{
					// Melee Weapon
					switch(GetURandomInt() % 4)
					{
						case 0:
							TinkerMeleeGlassy(tinker.Rarity, tinker);
						case 1:
							TinkerMeleeRapidSwing(tinker.Rarity, tinker);
						case 2:
							TinkerMeleeHeavySwing(tinker.Rarity, tinker);
						case 3:
							TinkerMeleeLongSwing(tinker.Rarity, tinker);
					}
				}
			}

			else if(slot < TFWeaponSlot_Melee)
			{
				if(Attributes_Has(weapon, 101) || Attributes_Has(weapon, 102) || Attributes_Has(weapon, 103) || Attributes_Has(weapon, 104))
				{
					//infinite fire
					if(Attributes_Has(weapon, 303))
					{
						switch(GetURandomInt() % 4)
						{
							case 0:
								TinkerMeleeRapidSwing(tinker.Rarity, tinker);
							case 1:
								TinkerRangedSlowHeavyProj(tinker.Rarity, tinker);
							case 2:
								TinkerRangedFastProj(tinker.Rarity, tinker);
							case 3:
								TinkerHeavyTrigger(tinker.Rarity, tinker);
						}
					}
					else
					{
						switch(GetURandomInt() % 6)
						{
							case 0:
								TinkerMeleeRapidSwing(tinker.Rarity, tinker);
							case 1:
								TinkerRangedSlowHeavyProj(tinker.Rarity, tinker);
							case 2:
								TinkerRangedFastProj(tinker.Rarity, tinker);
							case 3:
								TinkerIntensiveClip(tinker.Rarity, tinker);
							case 4:
								TinkerConcentratedClip(tinker.Rarity, tinker);
							case 5:
								TinkerHeavyTrigger(tinker.Rarity, tinker);
							case 6:
								TinkerSmallerSmarterBullets(tinker.Rarity, tinker);
						}
					}
					// Projectile Weapon
				}
				else
				{
					//infinite fire
					if(Attributes_Has(weapon, 303))
					{
						for(int RetryTillWin; RetryTillWin < 10; RetryTillWin++)
						{
							switch(GetURandomInt() % 3)
							{
								case 0:
								{
									TinkerMeleeRapidSwing(tinker.Rarity, tinker);
									RetryTillWin = 11;
								}
								case 1:
								{
									TinkerHeavyTrigger(tinker.Rarity, tinker);
									RetryTillWin = 11;
								}
								case 2:
								{
									if(Attributes_Get(weapon, 45, 0.0) > 0.0)
									{
										RetryTillWin = 11;
										TinkerSprayAndPray(tinker.Rarity, tinker);
									}
								}
							}	
						}
					}
					else if(StrEqual(classname, "tf_weapon_flamethrower"))
					{
						//flamethrowers get different logic.
						switch(GetURandomInt() % 3)
						{
							case 0:
							{
								TinkerMeleeRapidSwing(tinker.Rarity, tinker);
							}
							case 1:
							{
								TinkerHeavyTrigger(tinker.Rarity, tinker);
							}
							case 2:
							{
								TinkerSmallerSmarterBullets(tinker.Rarity, tinker);
							}
						}	
					}
					else
					{
						for(int RetryTillWin; RetryTillWin < 10; RetryTillWin++)
						{
							switch(GetURandomInt() % 6)
							{
								case 0:
								{
									TinkerMeleeRapidSwing(tinker.Rarity, tinker);
									RetryTillWin = 11;
								}
								case 1:
								{
									TinkerIntensiveClip(tinker.Rarity, tinker);
									RetryTillWin = 11;
								}
								case 2:
								{
									TinkerConcentratedClip(tinker.Rarity, tinker);
									RetryTillWin = 11;
								}
								case 3:
								{
									TinkerHeavyTrigger(tinker.Rarity, tinker);
									RetryTillWin = 11;
								}
								case 4:
								{
									TinkerSmallerSmarterBullets(tinker.Rarity, tinker);
									RetryTillWin = 11;
								}
								case 5:
								{
									if(Attributes_Get(weapon, 45, 0.0) > 0.1)
									{
										RetryTillWin = 11;
										TinkerSprayAndPray(tinker.Rarity, tinker);
									}
								}
							}	
						}
					}
					// Hitscan Weapon
				}
			}
			else
			{
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Blacksmith Underleveled");

				ApplyBuildingCollectCooldown(entity, client, 2.0);
				return;
			}
	}

		CPrintToChat(client, "{yellow}%s (Tier %d)", tinker.Name, tinker.Rarity + 1);

		for(int i; i < sizeof(tinker.Attrib); i++)
		{
			if(!tinker.Attrib[i])
				break;
			
			Blacksmith_PrintAttribValue(client, tinker.Attrib[i], tinker.Value[i], tinker.Luck[i],  tinker.Addition[i], tinker.CustomMode[i]);
		}

		if(found == -1)
		{
			if(!Tinkers)
				Tinkers = new ArrayList(sizeof(TinkerEnum));
			
			Tinkers.PushArray(tinker);
		}
		else
		{
			Tinkers.SetArray(found, tinker);
		}
	}

	Building_GiveRewardsUse(client, owner, 25, true, 0.6, true);
	Store_ApplyAttribs(client);
	Store_GiveAll(client, GetClientHealth(client));	

	switch(tinker.Rarity)
	{
		case -1:
		{
			ClientCommand(client, "playgamesound ui/quest_decode.wav");
		}
		case 0:
		{
			ClientCommand(client, "playgamesound ui/quest_status_tick_novice.wav");
		}
		case 1:
		{
			ClientCommand(client, "playgamesound ui/quest_status_tick_advanced.wav");
		}
		case 2:
		{
			ClientCommand(client, "playgamesound ui/quest_status_tick_expert.wav");
		}
	}

	float cooldown = Cooldowns[SmithLevel[owner]];
	if(client != owner && Store_HasWeaponKit(client))
		cooldown *= 0.5;
	
	ApplyBuildingCollectCooldown(entity, client, cooldown);

	if(!Rogue_Mode() && owner != client)
	{
		switch(tinker.Rarity)
		{
			case 0:
			{
				ClientCommand(owner, "playgamesound ui/quest_status_tick_novice_friend.wav");
			}
			case 1:
			{
				ClientCommand(owner, "playgamesound ui/quest_status_tick_advanced_friend.wav");
			}
			default:
			{
				ClientCommand(owner, "playgamesound ui/quest_status_tick_expert_friend.wav");
			}
		}
	}
}

static bool AttribIsInverse(int attrib)
{
	switch(attrib)
	{
		case 5, 6, 96, 97, 205, 206, 252, 343, 412, Attrib_TerrianRes:
			return true;
	}

	return false;
}

void Blacksmith_PrintAttribValue(int client, int attrib, float value, float luck, bool addition = false, int CustomMode = 0)
{
	if(attrib == 264)
	{
		return;
	}
	bool inverse = AttribIsInverse(attrib);

	char buffer[64];
	if(addition)
	{
		FormatEx(buffer, sizeof(buffer), "%d ", RoundToCeil(value));
	}
	else if(value < 1.0)
	{
		FormatEx(buffer, sizeof(buffer), "%d％ ", RoundToCeil((1.0 - value) * 100.0));
	}
	else
	{
		FormatEx(buffer, sizeof(buffer), "%d％ ", RoundToCeil((value - 1.0) * 100.0));
	}

	//inverse the inverse!
	bool inverse_color = false;
	if(attrib == 733)
	{
		inverse_color = true;
	}
	if(attrib == 41 && CustomMode==1)
		inverse=true;

	if(((value < (addition ? 0.0 : 1.0)) ^ inverse))
	{
		if(!inverse_color)
		{
			Format(buffer, sizeof(buffer), "{crimson}-%s", buffer);
		}
		else
		{
			Format(buffer, sizeof(buffer), "{green}-%s", buffer);
		}
	}
	else
	{
		if(!inverse_color)
		{
			Format(buffer, sizeof(buffer), "{green}+%s", buffer);
		}
		else
		{
			Format(buffer, sizeof(buffer), "{crimson}+%s", buffer);
		}
	}

	switch(attrib)
	{
		case 1:
			Format(buffer, sizeof(buffer), "%s 물리 피해량", buffer);
		
		case 2:
			Format(buffer, sizeof(buffer), "%s 기본 피해량", buffer);
		
		case 3, 4:
		{
			if(CustomMode==1)
				Format(buffer, sizeof(buffer), "%s 휩쓸기 최대 적중수", buffer);
			else
				Format(buffer, sizeof(buffer), "%s 장탄수", buffer);
		}
		
		case 5, 6:
			Format(buffer, sizeof(buffer), "%s 공격 속도", buffer);
		
		case 8:
			Format(buffer, sizeof(buffer), "%s 치유 속도", buffer);
		
		case 10, 9:
			Format(buffer, sizeof(buffer), "%sÜberCharge Rate", buffer);
		
		case 16:
			Format(buffer, sizeof(buffer), "%s 적중시 회복", buffer);
		
		case 26:
			Format(buffer, sizeof(buffer), "%s 최대 체력", buffer);
			
		case 41:
		{
			if(CustomMode==1)
				Format(buffer, sizeof(buffer), "%s 휩쓸기 충전속도", buffer);
		}
		
		case 45:
			Format(buffer, sizeof(buffer), "%s 발사되는 탄환 수", buffer);
		
		case 54, 107:
			Format(buffer, sizeof(buffer), "%s 이동 속도", buffer);
		
		case 57:
			Format(buffer, sizeof(buffer), "%s 초당 체력 재생", buffer);
		
		case 95:
			Format(buffer, sizeof(buffer), "%s 수리 효율", buffer);
		
		case 96, 97:
			Format(buffer, sizeof(buffer), "%s 재장전 속도", buffer);
		
		case 99, 100:
		{
			if(CustomMode==1)
				Format(buffer, sizeof(buffer), "%s 휩쓸기 사거리", buffer);
			else
				Format(buffer, sizeof(buffer), "% 폭발 반경", buffer);
		}
		
		case 101, 102:
			Format(buffer, sizeof(buffer), "%s 투사체 날아가는 거리", buffer);
		
		case 103, 104:
			Format(buffer, sizeof(buffer), "%s 투사체 속도", buffer);

		case 106:
			Format(buffer, sizeof(buffer), "%s 탄환 집탄도", buffer);
		
		case 149:
			Format(buffer, sizeof(buffer), "%s 출혈 지속시간", buffer);
		
		case 205:
			Format(buffer, sizeof(buffer), "%s 원거리 저항력", buffer);
		
		case 206:
			Format(buffer, sizeof(buffer), "%s 근접 저항력", buffer);
		
		case 252:
			Format(buffer, sizeof(buffer), "%s 넉백 저항력", buffer);
		
		case 287:
			Format(buffer, sizeof(buffer), "%s 센트리 피해량", buffer);
		
		case 319:
			Format(buffer, sizeof(buffer), "%s 버프 지속 시간", buffer);
		
		case 326:
			Format(buffer, sizeof(buffer), "%s 점프 높이", buffer);
		
		case 343:
			Format(buffer, sizeof(buffer), "%s 센트리 공격 속도", buffer);
			
		case 397:
		{
			if(CustomMode==1)
				Format(buffer, sizeof(buffer), "%s초 동안 적이 불에 탐", buffer);
		}
		
		case 410:
		{
			if(CustomMode==1)
				Format(buffer, sizeof(buffer), "%s 점프 치명타 피해량", buffer);
			else
				Format(buffer, sizeof(buffer), "%s 기본 피해량", buffer);
		}
		
		case 411:
		{
			if(CustomMode==1)
				Format(buffer, sizeof(buffer), "%s초 동안 적이 침묵 디버프가 적용됨.", buffer);
		}
		
		case 412:
			Format(buffer, sizeof(buffer), "%s 모든 피해 저항력", buffer);
			
		case 425:
		{
			if(CustomMode==1)
				Format(buffer, sizeof(buffer), "%s 휩쓸기 피해량", buffer);
		}

		case 733:
			Format(buffer, sizeof(buffer), "%s 마나 소모량", buffer);

		case 4001:
			Format(buffer, sizeof(buffer), "%s 근접 무기 사거리", buffer);

		case 4002:
			Format(buffer, sizeof(buffer), "%s 메디건 추가 과치료율", buffer);

		case Attrib_TerrianRes:
			Format(buffer, sizeof(buffer), "%s 장판 피해 저항력", buffer);

		case Attrib_ElementalDef:
			Format(buffer, sizeof(buffer), "%s 원소 피해 저항력", buffer);

		case Attrib_SlowImmune:
			Format(buffer, sizeof(buffer), "%s 둔화 저항력", buffer);

		case Attrib_ObjTerrianAbsorb:
			Format(buffer, sizeof(buffer), "%s 구조물의 장판 흡수 확률", buffer);

		case Attrib_SetArchetype:
			Format(buffer, sizeof(buffer), "%s 무기 유형", buffer);
		
		case 4019:
			Format(buffer, sizeof(buffer), "%s 최대 마나", buffer);

	}
	
	CPrintToChat(client, "%s {yellow}(%d％)", buffer, RoundToCeil(luck * 100.0));
}

static void TinkerMeleeGlassy(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "유리 대포");
	tinker.Attrib[0] = 2;
	tinker.Attrib[1] = 205;
	tinker.Attrib[2] = 206;
	float DamageLuck = (0.1 * (tinker.Luck[0]));
	float RangedDmgVulLuck = (0.05 * (1.0 + (-1.0*(tinker.Luck[1]))));
	float MeleeDmgVulLuck = (0.05 * (1.0 + (-1.0*(tinker.Luck[2]))));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.1 + DamageLuck;
			tinker.Value[1] = 1.05 + RangedDmgVulLuck;
			tinker.Value[2] = 1.05 + MeleeDmgVulLuck;
		}
		case 1:
		{
			tinker.Value[0] = 1.15 + DamageLuck;
			tinker.Value[1] = 1.05 + RangedDmgVulLuck;
			tinker.Value[2] = 1.05 + MeleeDmgVulLuck;
		}
		case 2:
		{
			tinker.Value[0] = 1.2 + DamageLuck;
			tinker.Value[1] = 1.05 + RangedDmgVulLuck;
			tinker.Value[2] = 1.05 + MeleeDmgVulLuck;
		}
	}
}


static void TinkerMeleeRapidSwing(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "성급함");
	tinker.Attrib[0] = 2; //damage
	tinker.Attrib[1] = 6; //attackspeed
	//less damage
	//but faster attackspeed
	//inverts the luck
	float DamageLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[0]))));
	float AttackspeedLuck = (0.1 * (tinker.Luck[1]));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 0.95 - DamageLuck;
			tinker.Value[1] = 0.9 - AttackspeedLuck;
		}
		case 1:
		{
			tinker.Value[0] = 0.85 - DamageLuck;
			tinker.Value[1] = 0.8 - AttackspeedLuck;
		}
		case 2:
		{
			tinker.Value[0] = 0.8 - DamageLuck;
			tinker.Value[1] = 0.7 - AttackspeedLuck;
		}
	}
}

static void TinkerMeleeHeavySwing(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "묵직한 강타");
	tinker.Attrib[0] = 2; //damage
	tinker.Attrib[1] = 6; //attackspeed
	//less damage
	//but faster attackspeed
	//inverts the luck
	float DamageLuck = (0.1 * (tinker.Luck[0]));
	float AttackspeedLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[1]))));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.25 + DamageLuck;
			tinker.Value[1] = 1.15 + AttackspeedLuck;
		}
		case 1:
		{
			tinker.Value[0] = 1.3 + DamageLuck;
			tinker.Value[1] = 1.2 + AttackspeedLuck;
		}
		case 2:
		{
			tinker.Value[0] = 1.4 + DamageLuck;
			tinker.Value[1] = 1.25 + AttackspeedLuck;
		}
	}
}

static void TinkerMeleeLongSwing(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "늘~어나는 팔");
	tinker.Attrib[0] = 2; //damage
	tinker.Attrib[1] = 6; //attackspeed
	tinker.Attrib[2] = 4001; //ExtraMeleeRange
	
	float DamageLuck = (0.1 * (tinker.Luck[0]));
	float AttackspeedLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[1]))));
	float ExtraRangeLuck = (0.1 * (tinker.Luck[2]));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.10 + DamageLuck;
			tinker.Value[1] = 1.15 + AttackspeedLuck;
			tinker.Value[2] = 1.15 + ExtraRangeLuck;
		}
		case 1:
		{
			tinker.Value[0] = 1.15 + DamageLuck;
			tinker.Value[1] = 1.2 + AttackspeedLuck;
			tinker.Value[2] = 1.2 + ExtraRangeLuck;
		}
		case 2:
		{
			tinker.Value[0] = 1.20 + DamageLuck;
			tinker.Value[1] = 1.25 + AttackspeedLuck;
			tinker.Value[2] = 1.35 + ExtraRangeLuck;
		}
	}
}

static void TinkerHastyMage(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "성급한 마법사");
	tinker.Attrib[0] = 6;
	tinker.Attrib[1] = 733;
	float AttackspeedLuck = (0.1 * (tinker.Luck[1]));
	float MageShootExtraCost = (0.15 * (1.0 + (-1.0*(tinker.Luck[1]))));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 0.8 + AttackspeedLuck;
			tinker.Value[1] = 1.25 + MageShootExtraCost;
		}
		case 1:
		{
			tinker.Value[0] = 0.75 + AttackspeedLuck;
			tinker.Value[1] = 1.35 + MageShootExtraCost;
		}
		case 2:
		{
			tinker.Value[0] = 0.7 + AttackspeedLuck;
			tinker.Value[1] = 1.45 + MageShootExtraCost;
		}
	}
}
static void TinkerHeavyMage(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "강격의 마법사");
	tinker.Attrib[0] = 6;
	tinker.Attrib[1] = 733;
	tinker.Attrib[2] = 410;
	float AttackspeedLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[1]))));
	float MageShootExtraCost = (0.15 * (1.0 + (-1.0*(tinker.Luck[1]))));
	float DamageLuck = (0.1 * (tinker.Luck[2]));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.1 + AttackspeedLuck;
			tinker.Value[1] = 1.55 + MageShootExtraCost;
			tinker.Value[2] = 1.25 + DamageLuck;
		}
		case 1:
		{
			tinker.Value[0] = 1.15 + AttackspeedLuck;
			tinker.Value[1] = 1.65 + MageShootExtraCost;
			tinker.Value[2] = 1.3 + DamageLuck;
		}
		case 2:
		{
			tinker.Value[0] = 1.2 + AttackspeedLuck;
			tinker.Value[1] = 1.75 + MageShootExtraCost;
			tinker.Value[2] = 1.35 + DamageLuck;
		}
	}
}

static void TinkerConcentrationMage(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "집중형 마법");
	tinker.Attrib[0] = 103;
	tinker.Attrib[1] = 410;
	float ProjectileSpeed = (0.1 * (tinker.Luck[0]));
	float DamageLuck = (0.1 * (tinker.Luck[1]));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 0.4 + ProjectileSpeed;
			tinker.Value[1] = 1.15 + DamageLuck;
		}
		case 1:
		{
			tinker.Value[0] = 0.45 + ProjectileSpeed;
			tinker.Value[1] = 1.2 + DamageLuck;
		}
		case 2:
		{
			tinker.Value[0] = 0.5 + ProjectileSpeed;
			tinker.Value[1] = 1.25 + DamageLuck;
		}
	}
}


static void TinkerTankMage(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "튼튼한 마법사");
	tinker.Attrib[0] = 733;
	tinker.Attrib[1] = 410;
	tinker.Attrib[2] = 205;
	tinker.Attrib[3] = 206;
	float MageShotCost = (0.1 * (1.0 + (-1.0*(tinker.Luck[0]))));
	float DamageLuck = (0.1 * (tinker.Luck[1]));
	float RangedDmgLuck = (0.05 * (tinker.Luck[2]));
	float MeleeDmgLuck = (0.05 * (tinker.Luck[3]));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.15 + MageShotCost;
			tinker.Value[1] = 0.95 + DamageLuck;
			tinker.Value[2] = 0.95 - RangedDmgLuck;
			tinker.Value[3] = 0.95 - MeleeDmgLuck;
		}
		case 1:
		{
			tinker.Value[0] = 1.2 + MageShotCost;
			tinker.Value[1] = 0.93 + DamageLuck;
			tinker.Value[2] = 0.93 - RangedDmgLuck;
			tinker.Value[3] = 0.93 - MeleeDmgLuck;
		}
		case 2:
		{
			tinker.Value[0] = 1.25 + MageShotCost;
			tinker.Value[1] = 0.92 + DamageLuck;
			tinker.Value[2] = 0.9 - RangedDmgLuck;
			tinker.Value[3] = 0.9 - MeleeDmgLuck;
		}
	}
}


static void TinkerMedigun_FastHeal(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "치유 과충전");
	tinker.Attrib[0] = 8; //more heal rate
	tinker.Attrib[1] = 9; //Less uber rate
	tinker.Attrib[2] = 4002; //Less Overheal
	float MoreHealRateLuck = (0.1 * (tinker.Luck[0]));
	float LessUberRateLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[1]))));
	float LessOverhealRateLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[2]))));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.15 + MoreHealRateLuck;
			tinker.Value[1] = 0.95 - LessUberRateLuck;
			tinker.Value[2] = 0.96 - LessOverhealRateLuck;
		}
		case 1:
		{
			tinker.Value[0] = 1.25 + MoreHealRateLuck;
			tinker.Value[1] = 0.92 - LessUberRateLuck;
			tinker.Value[2] = 0.95 - LessOverhealRateLuck;
		}
		case 2:
		{
			tinker.Value[0] = 1.35 + MoreHealRateLuck;
			tinker.Value[1] = 0.88 - LessUberRateLuck;
			tinker.Value[2] = 0.9 - LessOverhealRateLuck;
		}
	}
}
static void TinkerMedigun_Overhealer(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "오메가 과치료");
	tinker.Attrib[0] = 8;
	tinker.Attrib[1] = 4002; 
	float LessHealRateLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[0]))));
	float MoreOverhealLuck = (0.1 * (tinker.Luck[1]));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.05 - LessHealRateLuck;
			tinker.Value[1] = 1.1 + MoreOverhealLuck;
		}
		case 1:
		{
			tinker.Value[0] = 1.0 - LessHealRateLuck;
			tinker.Value[1] = 1.15 + MoreOverhealLuck;
		}
		case 2:
		{
			tinker.Value[0] = 0.95 - LessHealRateLuck;
			tinker.Value[1] = 1.20 + MoreOverhealLuck;
		}
	}
}


static void TinkerMedigun_Uberer(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "순수한 우버맨");
	tinker.Attrib[0] = 8;
	tinker.Attrib[1] = 9;
	float LessHealRate = (0.1 * (1.0 + (-1.0*(tinker.Luck[0]))));
	float MoreUberRate = (0.1 * (tinker.Luck[1]));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 0.9 - LessHealRate;
			tinker.Value[1] = 1.1 + MoreUberRate;
		}
		case 1:
		{
			tinker.Value[0] = 0.85 - LessHealRate;
			tinker.Value[1] = 1.15 + MoreUberRate;
		}
		case 2:
		{
			tinker.Value[0] = 0.8 - LessHealRate;
			tinker.Value[1] = 1.25 + MoreUberRate;
		}
	}
}


static void TinkerMedicWeapon_GlassyMedic(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "유리 대포");
	tinker.Attrib[0] = 8; //more heal rate
	tinker.Attrib[1] = 6; 
	tinker.Attrib[2] = 205;
	tinker.Attrib[3] = 206;
	float HealRateLuck = (0.1 * (tinker.Luck[0]));
	float AttackRateLuck = (0.1 * (tinker.Luck[1]));
	float RangedDmgVulLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[2]))));
	float MeleeDmgVulLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[3]))));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.05 + HealRateLuck;
			tinker.Value[1] = 0.9 - AttackRateLuck;
			tinker.Value[2] = 1.05 + RangedDmgVulLuck;
			tinker.Value[3] = 1.05 + MeleeDmgVulLuck;
		}
		case 1:
		{
			tinker.Value[0] = 1.1 + HealRateLuck;
			tinker.Value[1] = 0.86 - AttackRateLuck;
			tinker.Value[2] = 1.075 + RangedDmgVulLuck;
			tinker.Value[3] = 1.075 + MeleeDmgVulLuck;
		}
		case 2:
		{
			tinker.Value[0] = 1.15 + HealRateLuck;
			tinker.Value[1] = 0.84 - AttackRateLuck;
			tinker.Value[2] = 1.10 + RangedDmgVulLuck;
			tinker.Value[3] = 1.10 + MeleeDmgVulLuck;
		}
	}
}


static void TinkerMedicWeapon_BurstHealMedic(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "폭발 치유");
	tinker.Attrib[0] = 8; //more heal rate
	tinker.Attrib[1] = 6; 
	tinker.Attrib[2] = 97; 
	float HealRateLuck = (0.2 * (tinker.Luck[0]));
	float AttackRateLuck = (0.12 * (tinker.Luck[1]));
	float ReloadRateLuck = (0.12 * (tinker.Luck[2]));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.75 + HealRateLuck;
			tinker.Value[1] = 1.6 + AttackRateLuck;
			tinker.Value[2] = 1.6 + ReloadRateLuck;
		}
		case 1:
		{
			tinker.Value[0] = 1.9 + HealRateLuck;
			tinker.Value[1] = 1.75 + AttackRateLuck;
			tinker.Value[2] = 1.75 + ReloadRateLuck;
		}
		case 2:
		{
			tinker.Value[0] = 2.1 + HealRateLuck;
			tinker.Value[1] = 1.85 + AttackRateLuck;
			tinker.Value[2] = 1.85 + ReloadRateLuck;
		}
	}
}


static void TinkerBuilderLongSwing(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "구조물 개조자");
	tinker.Attrib[0] = 6; //attackspeed
	tinker.Attrib[1] = 264; //ExtraMeleeRange
	tinker.Attrib[2] = 4001; //ExtraMeleeRange
	
	float AttackspeedLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[0]))));
	float ExtraRangeLuck = (0.1 * (tinker.Luck[1]));

	tinker.Luck[2] = tinker.Luck[1];

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.25 + AttackspeedLuck;
			tinker.Value[1] = 1.5 + ExtraRangeLuck;
			tinker.Value[2] = 1.5 + ExtraRangeLuck;
		}
		case 1:
		{
			tinker.Value[0] = 1.35 + AttackspeedLuck;
			tinker.Value[1] = 1.5 + ExtraRangeLuck;
			tinker.Value[2] = 1.75 + ExtraRangeLuck;
		}
		case 2:
		{
			tinker.Value[0] = 1.4 + AttackspeedLuck;
			tinker.Value[1] = 1.5 + ExtraRangeLuck;
			tinker.Value[2] = 2.0 + ExtraRangeLuck;
		}
	}
}


static void TinkerBuilderRepairMaster(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "수리의 달인");
	tinker.Attrib[0] = 95; //RepairRate
	tinker.Attrib[1] = 107; //movementspeed
	
	float RepairRate = (0.1 * (tinker.Luck[0]));
	float MovementSpeed = (0.05 * (1.0 + (-1.0*(tinker.Luck[1]))));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.25 + RepairRate;
			tinker.Value[1] = 0.98 - MovementSpeed;
		}
		case 1:
		{
			tinker.Value[0] = 1.3 + RepairRate;
			tinker.Value[1] = 0.98 - MovementSpeed;
		}
		case 2:
		{
			tinker.Value[0] = 1.4 + RepairRate;
			tinker.Value[1] = 0.98 - MovementSpeed;
		}
	}
}



static void TinkerRangedSlowHeavyProj(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "느리고 강한 에너지");
	tinker.Attrib[0] = 2; //damage
	tinker.Attrib[1] = 103; //ProjectileSpeed
	tinker.Attrib[2] = 6; //attackspeed
	
	float DamageLuck = (0.1 * (tinker.Luck[0]));
	float ProjectileSpeedLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[1]))));
	float AttackspeedLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[2]))));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.15 + DamageLuck;
			tinker.Value[1] = 0.7 - ProjectileSpeedLuck;
			tinker.Value[2] = 1.05 + AttackspeedLuck;
		}
		case 1:
		{
			tinker.Value[0] = 1.20 + DamageLuck;
			tinker.Value[1] = 0.65 - ProjectileSpeedLuck;
			tinker.Value[2] = 1.1 + AttackspeedLuck;
		}
		case 2:
		{
			tinker.Value[0] = 1.3 + DamageLuck;
			tinker.Value[1] = 0.6 - ProjectileSpeedLuck;
			tinker.Value[2] = 1.12 + AttackspeedLuck;
		}
	}
}

static void TinkerRangedFastProj(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "급가속 탄환");
	tinker.Attrib[0] = 2; //damage
	tinker.Attrib[1] = 103; //ProjectileSpeed
	tinker.Attrib[2] = 6; //attackspeed
	
	float DamageLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[0]))));
	float ProjectileSpeedLuck = (0.1 * (tinker.Luck[1]));
	float AttackspeedLuck = (0.1 * (tinker.Luck[2]));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 0.9 - DamageLuck;
			tinker.Value[1] = 1.35 + ProjectileSpeedLuck;
			tinker.Value[2] = 0.95 - AttackspeedLuck;
		}
		case 1:
		{
			tinker.Value[0] = 0.9 - DamageLuck;
			tinker.Value[1] = 1.5 + ProjectileSpeedLuck;
			tinker.Value[2] = 0.93 - AttackspeedLuck;
		}
		case 2:
		{
			tinker.Value[0] = 0.85 - DamageLuck;
			tinker.Value[1] = 1.65 + ProjectileSpeedLuck;
			tinker.Value[2] = 0.9 - AttackspeedLuck;
		}
	}
}


static void TinkerIntensiveClip(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "묵직한 탄환");
	tinker.Attrib[0] = 6; //attackspeed
	tinker.Attrib[1] = 4; //Clipsize
	tinker.Attrib[2] = 97; //ReloadSpeed
	
	float AttackSpeedLuck = (0.07 * (tinker.Luck[0]));
	float ClipSizeLuck = (0.15 * (tinker.Luck[1]));
	float ReloadSpeedLuck = (0.15 * (1.0 + (-1.0*(tinker.Luck[2]))));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 0.95 - AttackSpeedLuck;
			tinker.Value[1] = 1.5 + ClipSizeLuck;
			tinker.Value[2] = 1.7 + ReloadSpeedLuck;
		}
		case 1:
		{
			tinker.Value[0] = 0.93 - AttackSpeedLuck;
			tinker.Value[1] = 1.65 + ClipSizeLuck;
			tinker.Value[2] = 1.8 + ReloadSpeedLuck;
		}
		case 2:
		{
			tinker.Value[0] = 0.92 - AttackSpeedLuck;
			tinker.Value[1] = 1.75 + ClipSizeLuck;
			tinker.Value[2] = 1.9 + ReloadSpeedLuck;
		}
	}
}

static void TinkerConcentratedClip(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "집중형 탄환");
	tinker.Attrib[0] = 2; //Damage
	tinker.Attrib[1] = 97; //ReloadSpeed
	
	float ExtraDamage = (0.1 * (tinker.Luck[0]));
	float ReloadSpeedLuck = (0.2 * (1.0 + (-1.0*(tinker.Luck[1]))));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.15 + ExtraDamage;
			tinker.Value[1] = 1.35 + ReloadSpeedLuck;
		}
		case 1:
		{
			tinker.Value[0] = 1.2 + ExtraDamage;
			tinker.Value[1] = 1.4 + ReloadSpeedLuck;
		}
		case 2:
		{
			tinker.Value[0] = 1.25 + ExtraDamage;
			tinker.Value[1] = 1.5 + ReloadSpeedLuck;
		}
	}
}


static void TinkerHeavyTrigger(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "중량 방아쇠");
	tinker.Attrib[0] = 2; //Damage
	tinker.Attrib[1] = 6; //attackspeed
	tinker.Attrib[2] = 97; //Reload speed
	
	float ExtraDamage = (0.1 * (tinker.Luck[0]));
	float attackspeedSpeedLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[1]))));
	float reloadSpeedLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[2]))));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.2 + ExtraDamage;
			tinker.Value[1] = 1.1 + attackspeedSpeedLuck;
			tinker.Value[2] = 1.1 + reloadSpeedLuck;
		}
		case 1:
		{
			tinker.Value[0] = 1.25 + ExtraDamage;
			tinker.Value[1] = 1.15 + attackspeedSpeedLuck;
			tinker.Value[2] = 1.15 + reloadSpeedLuck;
		}
		case 2:
		{
			tinker.Value[0] = 1.3 + ExtraDamage;
			tinker.Value[1] = 1.2 + attackspeedSpeedLuck;
			tinker.Value[2] = 1.2 + reloadSpeedLuck;
		}
	}
}

static void TinkerSprayAndPray(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "난사");
	tinker.Attrib[0] = 45; //BulletsPetShot
	tinker.Attrib[1] = 2; //damage
	
	float BulletPetShotBonus = (0.1 * (tinker.Luck[0]));
	float AccuracySuffering = (0.1 * (1.0 + (-1.0*(tinker.Luck[1]))));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.35 + BulletPetShotBonus;
			tinker.Value[1] = 0.85 - AccuracySuffering;
		}
		case 1:
		{
			tinker.Value[0] = 1.4 + BulletPetShotBonus;
			tinker.Value[1] = 0.83 - AccuracySuffering;
		}
		case 2:
		{
			tinker.Value[0] = 1.45 + BulletPetShotBonus;
			tinker.Value[1] = 0.8 - AccuracySuffering;
		}
	}
}

static void TinkerSmallerSmarterBullets(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "소형화 스마트 탄환");
	tinker.Attrib[0] = 2; //Less Damage
	tinker.Attrib[1] = 6; //Faster Shooting
	tinker.Attrib[2] = 97; //faster Reload
	
	float DamageLuck = (0.1 * (tinker.Luck[0]));
	float AttackSpeedLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[1]))));
	float FasterReloadLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[2]))));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 0.85 + DamageLuck;
			tinker.Value[1] = 0.8 + AttackSpeedLuck;
			tinker.Value[2] = 0.8 + FasterReloadLuck;
		}
		case 1:
		{
			tinker.Value[0] = 0.8 + DamageLuck;
			tinker.Value[1] = 0.7 + AttackSpeedLuck;
			tinker.Value[2] = 0.7 + FasterReloadLuck;
		}
		case 2:
		{
			tinker.Value[0] = 0.7 + DamageLuck;
			tinker.Value[1] = 0.6 + AttackSpeedLuck;
			tinker.Value[2] = 0.6 + FasterReloadLuck;
		}
	}
}


public void Anvil_Menu(int client)
{
	if(dieingstate[client] == 0)
	{	
		CancelClientMenu(client);
		SetStoreMenuLogic(client, false);
		static char buffer[128];
		Menu menu = new Menu(Anvil_MenuH);
		AnyMenuOpen[client] = 1.0;

		SetGlobalTransTarget(client);
		
		menu.SetTitle("%t", "Anvil Menu Main");

		FormatEx(buffer, sizeof(buffer), "%t", "Re-Roll Weapon Stats");
		menu.AddItem("-1", buffer);

		FormatEx(buffer, sizeof(buffer), "%t", "Remove Weapon Stats");
		menu.AddItem("-2", buffer);

		FormatEx(buffer, sizeof(buffer), "%t", "Display Current Stats");
		menu.AddItem("-3", buffer);
									
		menu.ExitButton = true;
		menu.Display(client, MENU_TIME_FOREVER);
	}
}

public int Anvil_MenuH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
			if(IsValidClient(client))
				AnyMenuOpen[client] = 0.0;
		}
		case MenuAction_Select:
		{
			AnyMenuOpen[client] = 0.0;
			ResetStoreMenuLogic(client);
			char buffer[24];
			menu.GetItem(choice, buffer, sizeof(buffer));
			int id = StringToInt(buffer);
			int weapon;
			int anvil;
			int owner;
			
			if(IsValidClient(client))
			{
				weapon = EntRefToEntIndex(ClickedWithWeapon[client]);
				anvil = EntRefToEntIndex(AnvilClickedOn[client]);
			}
			else
				return 0;

			if(!IsValidEntity(weapon) || !IsValidEntity(anvil))
				return 0;
			else
			{
				owner = GetEntPropEnt(anvil, Prop_Send, "m_hOwnerEntity");
			}

			switch(id)
			{
				case -1:
				{
					Blacksmith_BuildingUsed_Internal(weapon, anvil, client, owner, false);
				}
				case -2:
				{
					Blacksmith_BuildingUsed_Internal(weapon, anvil, client, owner, true);
				}
				case -3:
				{
					Blacksmith_ExtraDesc(client, StoreWeapon[weapon]);
				}
			}
		}
		case MenuAction_Cancel:
		{
			ResetStoreMenuLogic(client);
		}
	}
	return 0;
}

static void Tinker_MS_Sharpness(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "날카로움");
	tinker.Attrib[0] = 2;
	float DamageLuck = (0.1 * (tinker.Luck[0]));
	
	switch(rarity)
	{
		case 0:tinker.Value[0] = 1.1 + DamageLuck;
		case 1:tinker.Value[0] = 1.15 + DamageLuck;
		case 2:tinker.Value[0] = 1.2 + DamageLuck;
		case 3:tinker.Value[0] = 1.25 + DamageLuck;
		case 4:tinker.Value[0] = 1.32 + DamageLuck;
	}
}

static void Tinker_MS_Smite(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "강타");
	tinker.Attrib[0] = 2;
	tinker.Attrib[1] = 410;
	tinker.Attrib[2] = 41;
	tinker.CustomMode[1]=1;
	tinker.CustomMode[2]=1;
	float DamageLuck = (0.01 * (tinker.Luck[0]));
	float CritLuck = (0.025 * (tinker.Luck[1]));
	float ChargeRate = (0.1 * (tinker.Luck[2]));
	
	switch(rarity)
	{
		case 0:{tinker.Value[0] = 1.1 + DamageLuck;tinker.Value[1] = 1.2 + CritLuck;tinker.Value[2] = 2.0 + ChargeRate;}
		case 1:{tinker.Value[0] = 1.12 + DamageLuck;tinker.Value[1] = 1.26 + CritLuck;tinker.Value[2] = 1.75 + ChargeRate;}
		case 2:{tinker.Value[0] = 1.15 + DamageLuck;tinker.Value[1] = 1.31 + CritLuck;tinker.Value[2] = 1.5 + ChargeRate;}
		case 3:{tinker.Value[0] = 1.2 + DamageLuck;tinker.Value[1] = 1.35 + CritLuck;tinker.Value[2] = 1.25 + ChargeRate;}
		case 4:{tinker.Value[0] = 1.35 + DamageLuck;tinker.Value[1] = 1.43 + CritLuck;tinker.Value[2] = 1.1 + ChargeRate;}
	}
}

static void Tinker_MS_SweepingEdge(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "휩쓸기");
	tinker.Attrib[0] = 99;
	tinker.Attrib[1] = 4;
	tinker.Attrib[2] = 425;
	tinker.CustomMode[0]=1;
	tinker.CustomMode[1]=1;
	tinker.CustomMode[2]=1;
	tinker.Addition[1]=true;
	float RangeLuck = (0.1 * (tinker.Luck[0]));
	float MaxTargetLuck = (0.5 * (tinker.Luck[1]));
	float DamageLuck = (0.1 * (tinker.Luck[2]));

	switch(rarity)
	{
		case 0:{tinker.Value[0] = 1.25 + RangeLuck;tinker.Value[1] = 1.0 + MaxTargetLuck;tinker.Value[2] = 1.05 + DamageLuck;}
		case 1:{tinker.Value[0] = 1.5 + RangeLuck;tinker.Value[1] = 2.0 + MaxTargetLuck;tinker.Value[2] = 1.1 + DamageLuck;}
		case 2:{tinker.Value[0] = 1.75 + RangeLuck;tinker.Value[1] = 3.0 + MaxTargetLuck;tinker.Value[2] = 1.2 + DamageLuck;}
		case 3:{tinker.Value[0] = 2.0 + RangeLuck;tinker.Value[1] = 4.0 + MaxTargetLuck;tinker.Value[2] = 1.25 + DamageLuck;}
		case 4:{tinker.Value[0] = 2.5 + RangeLuck;tinker.Value[1] = 4.5 + MaxTargetLuck;tinker.Value[2] = 1.3 + DamageLuck;}
	}
}

static void Tinker_MS_QuickCharge(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "빠른 충전");
	tinker.Attrib[0] = 41;
	tinker.Attrib[1] = 6;
	tinker.Attrib[2] = 425;
	tinker.CustomMode[0]=1;
	tinker.CustomMode[2]=1;
	float ChargeRate = (0.01 * (1.0 + (-1.0*(tinker.Luck[0]))));
	float AttackSpeedLuck = (0.1 * (tinker.Luck[1]));
	float DamageLuck = (0.1 * (tinker.Luck[2]));

	switch(rarity)
	{
		case 0:{tinker.Value[0] = 0.9 + ChargeRate;tinker.Value[1] = 0.9 - AttackSpeedLuck;tinker.Value[2] = 0.7 + DamageLuck;}
		case 1:{tinker.Value[0] = 0.87 + ChargeRate;tinker.Value[1] = 0.87 - AttackSpeedLuck;tinker.Value[2] = 0.72 + DamageLuck;}
		case 2:{tinker.Value[0] = 0.8 + ChargeRate;tinker.Value[1] = 0.85 - AttackSpeedLuck;tinker.Value[2] = 0.75 + DamageLuck;}
		case 3:{tinker.Value[0] = 0.65 + ChargeRate;tinker.Value[1] = 0.8 - AttackSpeedLuck;tinker.Value[2] = 0.77 + DamageLuck;}
		case 4:{tinker.Value[0] = 0.5 + ChargeRate;tinker.Value[1] = 0.75 - AttackSpeedLuck;tinker.Value[2] = 0.8 + DamageLuck;}
	}
}

static void Tinker_MS_BaneofArthropods(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "살충");
	tinker.Attrib[0] = 2;
	tinker.Attrib[1] = 411;
	tinker.Addition[1]=true;
	tinker.CustomMode[1]=1;
	float DamageLuck = (0.1 * (tinker.Luck[0]));
	float SilencedLuck = (0.5 * (tinker.Luck[1]));

	switch(rarity)
	{
		case 0:{tinker.Value[0] = 0.65 + DamageLuck;tinker.Value[1] = 1.0 + SilencedLuck;}
		case 1:{tinker.Value[0] = 0.7 + DamageLuck;tinker.Value[1] = 1.5 + SilencedLuck;}
		case 2:{tinker.Value[0] = 0.72 + DamageLuck;tinker.Value[1] = 2.0 + SilencedLuck;}
		case 3:{tinker.Value[0] = 0.75 + DamageLuck;tinker.Value[1] = 3.0 + SilencedLuck;}
		case 4:{tinker.Value[0] = 0.79 + DamageLuck;tinker.Value[1] = 4.0 + SilencedLuck;}
	}
}

static void Tinker_MS_FireAspect(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "발화");
	tinker.Attrib[0] = 2;
	tinker.Attrib[1] = 397;
	tinker.Addition[1]=true;
	tinker.CustomMode[1]=1;
	float DamageLuck = (0.1 * (tinker.Luck[0]));
	float FireLuck = (0.5 * (tinker.Luck[1]));

	switch(rarity)
	{
		case 0:{tinker.Value[0] = 0.62 + DamageLuck;tinker.Value[1] = 1.0 + FireLuck;}
		case 1:{tinker.Value[0] = 0.66 + DamageLuck;tinker.Value[1] = 2.0 + FireLuck;}
		case 2:{tinker.Value[0] = 0.71 + DamageLuck;tinker.Value[1] = 3.0 + FireLuck;}
		case 3:{tinker.Value[0] = 0.73 + DamageLuck;tinker.Value[1] = 5.0 + FireLuck;}
		case 4:{tinker.Value[0] = 0.76 + DamageLuck;tinker.Value[1] = 8.0 + FireLuck;}
	}
}

static void Tinker_MS_CurseofGlassy(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "유리 저주");
	tinker.Attrib[0] = 2;
	tinker.Attrib[1] = 425;
	tinker.Attrib[2] = 205;
	tinker.Attrib[3] = 206;
	tinker.CustomMode[1]=1;
	float DamageLuck = (0.1 * (tinker.Luck[0]));
	float SweepingLuck = (0.1 * (tinker.Luck[1]));
	float RangedDmgVulLuck = (0.05 * (1.0 + (-1.0*(tinker.Luck[2]))));
	float MeleeDmgVulLuck = (0.05 * (1.0 + (-1.0*(tinker.Luck[3]))));

	switch(rarity)
	{
		case 0:{tinker.Value[0] = 1.1 + DamageLuck;tinker.Value[1] = 1.25 + SweepingLuck;tinker.Value[2] = 1.05 + RangedDmgVulLuck;tinker.Value[3] = 1.05 + MeleeDmgVulLuck;}
		case 1:{tinker.Value[0] = 1.3 + DamageLuck;tinker.Value[1] = 1.3 + SweepingLuck;tinker.Value[2] = 1.075 + RangedDmgVulLuck;tinker.Value[3] = 1.075 + MeleeDmgVulLuck;}
		case 2:{tinker.Value[0] = 1.4 + DamageLuck;tinker.Value[1] = 1.35 + SweepingLuck;tinker.Value[2] = 1.1 + RangedDmgVulLuck;tinker.Value[3] = 1.1 + MeleeDmgVulLuck;}
		case 3:{tinker.Value[0] = 1.5 + DamageLuck;tinker.Value[1] = 1.4 + SweepingLuck;tinker.Value[2] = 1.25 + RangedDmgVulLuck;tinker.Value[3] = 1.25 + MeleeDmgVulLuck;}
		case 4:{tinker.Value[0] = 1.6 + DamageLuck;tinker.Value[1] = 1.45 + SweepingLuck;tinker.Value[2] = 1.35 + RangedDmgVulLuck;tinker.Value[3] = 1.35 + MeleeDmgVulLuck;}
	}
}