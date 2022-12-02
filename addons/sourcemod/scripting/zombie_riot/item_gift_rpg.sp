
#define GIFT_MODEL "models/items/tf_gift.mdl"

#define GIFT_CHANCE 0.35 //Extra rare cus alot of zobies

#define SOUND_BEEP			"buttons/button17.wav"

enum
{
	Rarity_Common = 0,
	Rarity_Uncommon = 1,
	Rarity_Rare = 2,
	Rarity_Legend = 3,
	Rarity_Mythic = 4
}

static int RenderColors_RPG[][] =
{
	{255, 255, 255, 255}, 	// 0
	{0, 255, 0, 255, 255}, 	//Green
	{ 65, 105, 225 , 255},	//Blue
	{ 255, 255, 0 , 255},	//yellow
	{ 178, 34, 34 , 255},	//Red
	{ 138, 43, 226 , 255},	//wat
	{0, 0, 0, 255}			//none, black.
};

static const char CommonDrops[][] =
{
	"Scrap Helmet [Common]",
	"Face Mask [Common]",
	"Villager Outfit [Common]",
	"Blue Jeans [Common]",
	"Jordans [Common]",
	"Faster Takedowns [Common]",
	"Flame Jet [Common]",
	"Vigilant Sentries [Common]"
};

static const char UncommonDrops[][] =
{
	"Smithed Scrap Chestplate [Uncommon]",
	"Big Cryo Blast [Uncommon]",
	"Long Turbo [Uncommon]",
	"Accelerated Aerodarts [Uncommon]",
	"Extra Burny Stuff [Uncommon]",
	"Charged Chinooks [Uncommon]",
	"Speedy Brewing [Uncommon]",
	"Deadly Tranquility [Uncommon]",
	"Veteran Monkey Training [Uncommon]",
	"Aztec Warrior Paint [Uncommon]",
	"Iron Ammo Coating [Uncommon]",
	"Sandals [Uncommon]",
	"Baggy Trousers [Uncommon]"
};

static const char RareDrops[][] =
{
	"Fast Tack Attacks [Rare]",
	"Mega Mauler [Rare]",
	"Big Bunch [Rare]",
	"Gun Coolant [Rare]",
	"Flanking Maneuvers [Rare]",
	"SUPER Range [Rare]",
	"Strong Tonic [Rare]",
	"Arcane Impale [Rare]",
	"Tiny Tornadoes [Rare]"
};

static const char LegendDrops[][] =
{
	"Quad Burst [Legendary]",
	"Big Bloon Sabotage [Legendary]",
	"Heavy Knockback [Legendary]",
	"To ARMS! [Legendary]",
	"Healthy Bananas [Legendary]"
};

static const char MythicDrops[][] =
{
	"There Can Be Only One [Mythic]"
};

static int g_BeamIndex = -1;

static int i_RarityType[MAXENTITIES];

static float f_IncreaceChanceManually = 1.0;

public void Map_Precache_Zombie_Drops_Gift()
{
	PrecacheModel(GIFT_MODEL, true);
	PrecacheSound(SOUND_BEEP);
	g_BeamIndex = PrecacheModel("materials/sprites/laserbeam.vmt", true);
}

public void Gift_DropChance(int entity)
{
	char buffer[32];
	zr_tagblacklist.GetString(buffer, sizeof(buffer));
	if(StrContains(buffer, "private", false) == -1)
	{
		if(IsValidEntity(entity))
		{
			if(GetRandomFloat(0.0, 200.0) < ((GIFT_CHANCE / (MultiGlobal + 0.0001)) * f_ExtraDropChanceRarity * f_IncreaceChanceManually)) //Never let it divide by 0
			{
				f_IncreaceChanceManually = 1.0;
				float VecOrigin[3];
				GetEntPropVector(entity, Prop_Data, "m_vecOrigin", VecOrigin);
				for (int client = 1; client <= MaxClients; client++)
				{
					if (IsValidClient(client) && IsPlayerAlive(client) && GetClientTeam(client) == view_as<int>(TFTeam_Red))
					{
						int rarity = RollRandom(); //Random for each clie
						Stock_SpawnGift(VecOrigin, GIFT_MODEL, 45.0, client, rarity);
					}
				}
			}	
			else
			{
				f_IncreaceChanceManually += 0.0015;
			}
		}
	}
}

static int RollRandom()
{
	if(!(GetURandomInt() % 150))
		return Rarity_Mythic;
	
	if(!(GetURandomInt() % 35))
		return Rarity_Legend;
	
	if(!(GetURandomInt() % 15))
		return Rarity_Rare;
	
	if(!(GetURandomInt() % 3))
		return Rarity_Uncommon;
	
	return Rarity_Common;
}


public Action Timer_Detect_Player_Near_Gift(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	int glow = EntRefToEntIndex(pack.ReadCell());
	int client = GetClientOfUserId(pack.ReadCell());
	int ScrapToGive = 0;
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		if(IsValidClient(client))
		{
			float powerup_pos[3];
			float client_pos[3];
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", powerup_pos);
			if(f_RingDelayGift[entity] < GetGameTime())
			{
				f_RingDelayGift[entity] = GetGameTime() + 2.0;
				EmitSoundToClient(client, SOUND_BEEP, entity, _, 90, _, 1.0);
				int color[4];
				
				color[0] = RenderColors_RPG[i_RarityType[entity]][0];
				color[1] = RenderColors_RPG[i_RarityType[entity]][1];
				color[2] = RenderColors_RPG[i_RarityType[entity]][2];
				color[3] = RenderColors_RPG[i_RarityType[entity]][3];
		
				TE_SetupBeamRingPoint(powerup_pos, 10.0, 300.0, g_BeamIndex, -1, 0, 30, 1.0, 10.0, 1.0, color, 0, 0);
	   			TE_SendToClient(client);

				GiftJumpTowardsYou(entity, client); //Terror.
   			}
			if (IsPlayerAlive(client) && GetClientTeam(client) == view_as<int>(TFTeam_Red))
			{
				GetClientAbsOrigin(client, client_pos);
				if (GetVectorDistance(powerup_pos, client_pos, true) <= 4096)
				{
					if (IsValidEntity(glow))
					{
						RemoveEntity(glow);
					}
					if(GetFeatureStatus(FeatureType_Native, "TextStore_GetItems") == FeatureStatus_Available)
					{
						int rand = GetURandomInt();
						int length = TextStore_GetItems();
						for(int r = i_RarityType[entity]; r >= 0; r--)
						{
							for(int i; i<length; i++)
							{
								static char buffer[128];
								TextStore_GetItemName(i, buffer, sizeof(buffer));
								
								if(length && r == Rarity_Mythic)
								{
									if(ScrapToGive == 0)
									{
										ScrapToGive = 6;
									}
									int start = (rand % sizeof(MythicDrops));
									int a = start;
									do
									{
										if(StrEqual(buffer, MythicDrops[a], false))
										{
											int amount;
											TextStore_GetInv(client, i, amount);
											if(!amount)
											{
												CPrintToChat(client,"{default}You have found {darkred}%s{default}!", MythicDrops[a]);
												TextStore_SetInv(client, i, amount + 1);
												length = 0;
											}
											
											break;
										}
										
										if(++a >= sizeof(MythicDrops))
											a = 0;
									} while(a != start);
								}
								
								if(length && r == Rarity_Legend)
								{
									if(ScrapToGive == 0)
									{
										ScrapToGive = 5;
									}
									int start = (rand % sizeof(LegendDrops));
									int a = start;
									do
									{
										if(StrEqual(buffer, LegendDrops[a], false))
										{
											int amount;
											TextStore_GetInv(client, i, amount);
											if(!amount)
											{
												CPrintToChat(client,"{default}You have found {yellow}%s{default}!", LegendDrops[a]);
												TextStore_SetInv(client, i, amount + 1);
												length = 0;
											}
											
											break;
										}
										
										if(++a >= sizeof(LegendDrops))
											a = 0;
									} while(a != start);
								}
								
								if(length && r == Rarity_Rare)
								{
									if(ScrapToGive == 0)
									{
										ScrapToGive = 4;
									}
									int start = (rand % sizeof(RareDrops));
									int a = start;
									do
									{
										if(StrEqual(buffer, RareDrops[a], false))
										{
											int amount;
											TextStore_GetInv(client, i, amount);
											if(!amount)
											{
												CPrintToChat(client,"{default}You have found {blue}%s{default}!", RareDrops[a]);
												TextStore_SetInv(client, i, amount + 1);
												length = 0;
											}
											
											break;
										}
										
										if(++a >= sizeof(RareDrops))
											a = 0;
									} while(a != start);
								}
								
								if(length && r == Rarity_Uncommon)
								{
									if(ScrapToGive == 0)
									{
										ScrapToGive = 2;
									}
									int start = (rand % sizeof(UncommonDrops));
									int a = start;
									do
									{
										if(StrEqual(buffer, UncommonDrops[a], false))
										{
											int amount;
											TextStore_GetInv(client, i, amount);
											if(!amount)
											{
												CPrintToChat(client,"{default}You have found {green}%s{default}!", UncommonDrops[a]);
												TextStore_SetInv(client, i, amount + 1);
												length = 0;
											}
											
											break;
										}
										
										if(++a >= sizeof(UncommonDrops))
											a = 0;
									} while(a != start);
								}
								
								if(length && r == Rarity_Common)
								{
									if(ScrapToGive == 0)
									{
										ScrapToGive = 1;
									}
									int start = (rand % sizeof(CommonDrops));
									int a = start;
									do
									{
										if(StrEqual(buffer, CommonDrops[a], false))
										{
											int amount;
											TextStore_GetInv(client, i, amount);
											if(!amount)
											{
												CPrintToChat(client,"{default}You have found %s!", CommonDrops[a]);
												TextStore_SetInv(client, i, amount + 1);
												length = 0;
											}
											
											break;
										}
										
										if(++a >= sizeof(CommonDrops))
											a = 0;
									} while(a != start);
								}
							}
						}
						
						if(length)
						{
							PrintToChat(client, "You already have everything in this rarity, but where given %i Scrap as a compensation.", ScrapToGive);
							Scrap[client] += ScrapToGive;
						}
					}
					RemoveEntity(entity);
					return Plugin_Stop;
				}
			}
		}
		else
		{
			if (IsValidEntity(glow))
			{
				RemoveEntity(glow);
			}
			RemoveEntity(entity);
			return Plugin_Stop;			
		}
	}
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

stock void Stock_SpawnGift(float position[3], const char[] model, float lifetime, int client, int rarity)
{
	int m_iGift = CreateEntityByName("prop_physics_override")
	if(m_iGift != -1)
	{
		char targetname[100];

		Format(targetname, sizeof(targetname), "gift_%i", m_iGift);

		DispatchKeyValue(m_iGift, "model", model);
		DispatchKeyValue(m_iGift, "targetname", targetname);
		DispatchKeyValue(m_iGift, "physicsmode", "2");
		DispatchKeyValue(m_iGift, "massScale", "1.0");
		DispatchSpawn(m_iGift);
		
		SetEntProp(m_iGift, Prop_Send, "m_usSolidFlags", 8);
		SetEntityCollisionGroup(m_iGift, 1);
	
		TeleportEntity(m_iGift, position, NULL_VECTOR, NULL_VECTOR);
		
		i_RarityType[m_iGift] = rarity;
		
		int glow = TF2_CreateGlow(m_iGift);
		
		int color[4];
		
		color[0] = RenderColors_RPG[i_RarityType[m_iGift]][0];
		color[1] = RenderColors_RPG[i_RarityType[m_iGift]][1];
		color[2] = RenderColors_RPG[i_RarityType[m_iGift]][2];
		color[3] = RenderColors_RPG[i_RarityType[m_iGift]][3];
		
		SetVariantColor(view_as<int>(color));
		AcceptEntityInput(glow, "SetGlowColor");
		
		SetEntPropEnt(glow, Prop_Send, "m_hOwnerEntity", client);
		SetEntPropEnt(m_iGift, Prop_Send, "m_hOwnerEntity", client);
			
	//	i_DyingParticleIndication[victim] = EntIndexToEntRef(entity);
		
		f_RingDelayGift[m_iGift] = GetGameTime() + 2.0;

		DataPack pack;
		CreateDataTimer(0.1, Timer_Detect_Player_Near_Gift, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		pack.WriteCell(EntIndexToEntRef(m_iGift));
		pack.WriteCell(EntIndexToEntRef(glow));	
		pack.WriteCell(GetClientUserId(client));
		
		
		DataPack pack_2;
		CreateDataTimer(lifetime, Timer_Despawn_Gift, pack_2, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		pack_2.WriteCell(EntIndexToEntRef(m_iGift));
		pack_2.WriteCell(EntIndexToEntRef(glow));	
		
	//	SDKHook(entity, SDKHook_SetTransmit, GiftTransmit);
		SDKHook(m_iGift, SDKHook_SetTransmit, GiftTransmit);
	}
}


public Action Timer_Despawn_Gift(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	int glow = EntRefToEntIndex(pack.ReadCell());
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		if (IsValidEntity(glow))
		{
			RemoveEntity(glow);
		}
		RemoveEntity(entity);
	}
	return Plugin_Handled;
}

public Action GiftTransmit(int entity, int target)
{
	if(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == target)
		return Plugin_Continue;

	return Plugin_Handled;
}

//This is probably the silliest thing ever.
public void GiftJumpTowardsYou(int Gift, int client)
{
	float Jump_1_frame[3];
	GetEntPropVector(Gift, Prop_Data, "m_vecOrigin", Jump_1_frame);
	float Jump_1_frame_Client[3];
	GetEntPropVector(client, Prop_Data, "m_vecOrigin", Jump_1_frame_Client);
	
	float vecNPC[3], vecJumpVel[3];
	GetEntPropVector(Gift, Prop_Data, "m_vecOrigin", vecNPC);
		
	float gravity = GetEntPropFloat(Gift, Prop_Data, "m_flGravity");
	if(gravity <= 0.0)
		gravity = FindConVar("sv_gravity").FloatValue;
		
	// How fast does the headcrab need to travel to reach the position given gravity?
	float flActualHeight = Jump_1_frame_Client[2] - vecNPC[2];
	float height = flActualHeight;
	if ( height < 72 )
	{
		height = 72.0;
	}

	float additionalHeight = 0.0;
		
	if ( height < 35 )
	{
		additionalHeight = 50.0;
	}
		
	height += additionalHeight;
	
	float speed = SquareRoot( 2 * gravity * height );
	float time = speed / gravity;
	
	time += SquareRoot( (2 * additionalHeight) / gravity );
		
	// Scale the sideways velocity to get there at the right time
	SubtractVectors( Jump_1_frame_Client, vecNPC, vecJumpVel );
	vecJumpVel[0] /= time;
	vecJumpVel[1] /= time;
	vecJumpVel[2] /= time;
	
	// Speed to offset gravity at the desired height.
	vecJumpVel[2] = speed;
		
	// Don't jump too far/fast.
	float flJumpSpeed = GetVectorLength(vecJumpVel);
	float flMaxSpeed = 350.0;
	if ( flJumpSpeed > flMaxSpeed )
	{
		vecJumpVel[0] *= flMaxSpeed / flJumpSpeed;
		vecJumpVel[1] *= flMaxSpeed / flJumpSpeed;
		vecJumpVel[2] *= flMaxSpeed / flJumpSpeed;
	}
	TeleportEntity(Gift, NULL_VECTOR, NULL_VECTOR, vecJumpVel);
}