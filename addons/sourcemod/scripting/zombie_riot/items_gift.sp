/*public Action CommandKillTheNPC(int client, int args)
{
	if(!IsValidClient(client) || IsFakeClient(client))
	{
		PrintToConsole(client, "Command is in-game only");
		return Plugin_Handled;
	}
	char arg[12], arg2[12];
	GetCmdArg(1, arg, sizeof(arg));
	GetCmdArg(2, arg2, sizeof(arg2));
	int mode = StringToInt(arg);
	float DMG = StringToFloat(arg2);

	float pos[3], ang[3];
	GetClientEyePosition(client, pos);
	GetClientEyeAngles(client, ang);
	
	int victim;
	Handle trace = TR_TraceRayFilterEx(pos, ang, MASK_SHOT, RayType_Infinite, KillCommand_TraceNotMe, client);
	if(TR_GetFraction(trace) < 1.0)
	{
		int target = TR_GetEntityIndex(trace);
		if(target > 0 && IsValidEntity(target))
			victim = target;
	}
	delete trace;
	
	if(!IsValidEntity(victim))
	{
		PrintToConsole(client, "No NPC/Client detected.");
		return Plugin_Handled;
	}
	if(mode==2)
	{
		if(GetTeam(client) != GetTeam(victim) && !IsValidClient(victim))
			SDKHooks_TakeDamage(victim, client, client, DMG, DMG_TRUEDAMAGE|DMG_PREVENT_PHYSICS_FORCE, -1);
		else if(GetTeam(client) == GetTeam(victim) || GetTeam(client) != TFTeam_Red)
			SDKHooks_TakeDamage(victim, 0, 0, DMG, DMG_TRUEDAMAGE|DMG_PREVENT_PHYSICS_FORCE, -1);
		else
			SDKHooks_TakeDamage(victim, client, client, DMG, DMG_TRUEDAMAGE|DMG_PREVENT_PHYSICS_FORCE, -1);
		return Plugin_Handled;
	}
	else if(mode==1)
	{
		b_NpcForcepowerupspawn[victim] = 0;
		i_RaidGrantExtra[victim] = 0;
		b_DissapearOnDeath[victim] = true;
		b_DoGibThisNpc[victim] = true;
	}
	SmiteNpcToDeath(victim);
	
	return Plugin_Handled;
}*/

public Action CommandSpawnGift(int client, int args)
{
	if(args < 1)
	{
		ReplyToCommand(client, "[ZR] Usage: sm_spawn_gift [xp:0 / Item:1] <0:Common 1:Uncommon 2:Rare 3:Legend 4:Mythic>");
		return Plugin_Handled;
	}
	if(!IsValidClient(client))
	{
		PrintToConsole(client, "Command is in-game only");
		return Plugin_Handled;
	}
	float vecClientEyePos[3], vecClientEyeAng[3];
	GetClientEyePosition(client, vecClientEyePos);
	GetClientEyeAngles(client, vecClientEyeAng);
	//vecClientEyePos[2]-=20.0;

	Handle hTrace;
	float TargetPos[3];
	hTrace = TR_TraceRayFilterEx(vecClientEyePos, vecClientEyeAng, MASK_PLAYERSOLID, RayType_Infinite, Filter_NoPlayers, client);
	TR_GetEndPosition(TargetPos, hTrace);
	delete hTrace;
	TargetPos[2]+=5.0;
	
	char arg[65], arg2[8];
	int index=0;
	GetCmdArg(1, arg, sizeof(arg));
	GetCmdArg(2, arg2, sizeof(arg2));
	if(StringToInt(arg, index))
	{
		StringToIntEx(arg2, index);
		if(!index) index=0;
		Stock_SpawnInvGift(TargetPos, GIFT_MODEL, 45.0, GetRarity(index));
	}
	else
	{
		StringToIntEx(arg2, index);
		if(!index) index=0;
		Stock_SpawnGift(TargetPos, GIFT_MODEL, 45.0, GetRarity(index)); 
	}
	return Plugin_Handled;
}

static ZRGiftRarity GetRarity(int rarity)
{
	switch(rarity)
	{
		case 1:
			return Uncommon;
		case 2:
			return Rare;
		case 3:
			return Legend;
		case 4:
			return Mythic;
	}
	return Common;
}

/*static bool KillCommand_TraceNotMe(int entity, int contentsMask, any data)
{
	if(entity == data)
		return false;

	return true;
}*/

enum struct InvGiftItem
{
	char Name[64];
	int Rarity;
}

static ArrayList GiftItems;

static int g_BeamIndex = -1;

void Map_Precache_Zombie_Drops_InvGift()
{
	PrecacheModel(GIFT_MODEL, true);
	g_BeamIndex = PrecacheModel(LASERBEAM, true);
}

void InvItems_SetupConfig()
{
	delete GiftItems;
	GiftItems = new ArrayList(sizeof(InvGiftItem));
	
	char buffer[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, "giftitems");

	KeyValues kv = new KeyValues("GiftItems");
	kv.ImportFromFile(buffer);
	kv.GotoFirstSubKey();
	
	InvGiftItem item;
	do	// TODO: Replace ArrayList with IntMap
	{
		kv.GetSectionName(item.Name, sizeof(item.Name));
		int index = StringToInt(item.Name);

		item.Name[0] = 0;
		item.Rarity = view_as<int>(None);
		while(GiftItems.Length < index)
		{
			GiftItems.PushArray(item);
		}

		kv.GetString("name", item.Name, sizeof(item.Name));
		item.Rarity = kv.GetNum("rarity", view_as<int>(None));
		if(GiftItems.Length == index)
		{
			GiftItems.PushArray(item);
		}
		else
		{
			GiftItems.SetArray(index, item);
		}
	}
	while(kv.GotoNextKey());
	/*for(int i; ; i++)	// Done this method due to saving by ID instead
	{
		IntToString(i, item.Name, sizeof(item.Name));
		if(kv.JumpToKey(item.Name))
		{
			kv.GetString("name", item.Name, sizeof(item.Name));
			item.Rarity = kv.GetNum("rarity", Rarity_None);
			GiftItems.PushArray(item);

			kv.GoBack();
		}
		else
		{
			break;
		}
	}*/
	delete kv;
}

/*public Action Timer_Detect_Player_Near_InvGift(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	int glow = EntRefToEntIndex(pack.ReadCell());
	int client = GetClientOfUserId(pack.ReadCell());
	ZRGiftRarity Rarity = pack.ReadCell();
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		if(IsValidClient(client))
		{
			int IRarity = view_as<int>(Rarity);
			float powerup_pos[3];
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", powerup_pos);
			float client_pos[3];
			if(f_RingDelayGift[entity] < GetGameTime())
			{
				float AddTime = 2.0;
				EmitSoundToClient(client, SOUND_BEEP, entity, _, 90, _, 1.0);
				int color[4];
				int ColorGiveRarity = IRarity;
				color[0] = RenderColors_RPG[ColorGiveRarity][0];
				color[1] = RenderColors_RPG[ColorGiveRarity][1];
				color[2] = RenderColors_RPG[ColorGiveRarity][2];
				color[3] = RenderColors_RPG[ColorGiveRarity][3];
		
				TE_SetupBeamRingPoint(powerup_pos, 10.0, 300.0, g_BeamIndex, -1, 0, 30, 1.0, 10.0, 1.0, color, 0, 0);
	   			TE_SendToClient(client);
				float TargetLocation[3]; WorldSpaceCenter(client, TargetLocation);
				float TargetDistance = GetVectorDistance(powerup_pos, TargetLocation, true); 
				if(TargetDistance <= (500.0 * 500.0)) GiftJumpAwayYou(entity, client);
				else if(TargetDistance >= (1000.0 * 1000.0)) {GiftJumpTowardsYou(entity, client); AddTime=1.0;}
				f_RingDelayGift[entity] = GetGameTime() + AddTime;
   			}
			if(GetTeam(client)== TFTeam_Red && IsEntityAlive(client))
			{
				GetClientAbsOrigin(client, client_pos);
				if(GetVectorDistance(powerup_pos, client_pos, true) < 4096.0)
				{
					if(IsValidEntity(glow))
						RemoveEntity(glow);
					
					RemoveEntity(entity);
					
					static InvGiftItem item;
					int rand = GetURandomInt();
					int length = GiftItems.Length;
					int[] items = new int[length];
					for(int r = IRarity; r >= 0; r--)
					{
						int maxitems;
						for(int i; i < length; i++)
						{
							GiftItems.GetArray(i, item);
							if(item.Rarity == r)
							{
								items[maxitems++] = i;
							}
						}

						int start = (rand % maxitems);
						int i = start;
						do
						{
							i++;
							if(i >= maxitems)
							{
								i = -1;
								continue;
							}

							if(Items_GiveIdItem(client, items[i]))	// Gives item, returns true if newly obtained, false if they already have
							{
								static const char Colors[][] = { "default", "green", "blue", "yellow", "darkred" };
								GiftItems.GetArray(items[i], item);
								CPrintToChat(client, "%t {%s}\"%t\"{snow}!", "Pickup Inventory Gift", Colors[r], item.Name);
								r = -1;
								length = 0;
								break;
							}
						}
						while(i != start);
					}
					
					if(length)
					{
						SetGlobalTransTarget(client);
						int MultiExtra = 1;
						switch(Rarity)
						{
							case Common:
								MultiExtra = 1;
							case Uncommon:
								MultiExtra = 2;
							case Rare:
								MultiExtra = 5;
							case Legend:
								MultiExtra = 10;
							case Mythic:
								MultiExtra = 40;
						}
						//xp to give?
						int TempCalc = Level[client];
						if(TempCalc >= 101)
							TempCalc = 101;

						TempCalc = LevelToXp(TempCalc) - LevelToXp(TempCalc - 1);
						TempCalc /= 40;
						int XpToGive = TempCalc * MultiExtra;
						CPrintToChat(client,"%t", "Pickup Gift Single", XpToGive);
						XP[client] += XpToGive;
						GiveXP(client, 0);
					}
					return Plugin_Stop;
				}
			}
		}
		else
		{
			if(IsValidEntity(glow))
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
}*/

public Action Timer_Detect_Player_Near_InvGift(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	int glow = EntRefToEntIndex(pack.ReadCell());
	ZRGiftRarity Rarity = pack.ReadCell();
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		int IRarity = view_as<int>(Rarity);
		float powerup_pos[3];
		WorldSpaceCenter(entity, powerup_pos);
		bool DoJump = false;
		if(f_RingDelayGift[entity] < GetGameTime())
		{
			float DelayTime = 2.0;
			switch(Rarity)
			{
				case Common:
					DelayTime = 3.0;
				case Uncommon:
					DelayTime = 2.0;
				case Rare:
					DelayTime = 1.0;
				case Legend:
					DelayTime = 0.9;
				case Mythic:
					DelayTime = 0.75;
			}
			f_RingDelayGift[entity] = GetGameTime() + DelayTime;
			EmitSoundToAll(SOUND_BEEP, entity, _, 90, _, 1.0);
			int color[4];
			SetColorRGBA(color, RenderColors_RPG[IRarity][0], RenderColors_RPG[IRarity][1], RenderColors_RPG[IRarity][2], RenderColors_RPG[IRarity][3]);
	
			TE_SetupBeamRingPoint(powerup_pos, 10.0, 300.0, g_BeamIndex, -1, 0, 30, 1.0, 10.0, 1.0, color, 0, 0);
			TE_SendToAll();
			DoJump = true;
		}
		float TargetDistance = 0.0; 
		int ClosestTarget = 0; 
		for( int i = 1; i <= MaxClients; i++ ) 
		{
			if (IsValidClient(i))
			{
				if (GetTeam(i)== TFTeam_Red && IsEntityAlive(i))
				{
					float TargetLocation[3]; 
					WorldSpaceCenter(i, TargetLocation);
					
					
					float distance = GetVectorDistance( powerup_pos, TargetLocation, true ); 
					if( TargetDistance ) 
					{
						if( distance < TargetDistance ) 
						{
							ClosestTarget = i; 
							TargetDistance = distance;		  
						}
					} 
					else 
					{
						ClosestTarget = i; 
						TargetDistance = distance;
					}		
				}
			}
		}
		if(ClosestTarget > 0 && TargetDistance <= (50.0 * 50.0))
		{
			//picked up!
			char NameOfTheHero[64];
			Format(NameOfTheHero, sizeof(NameOfTheHero), "%N", ClosestTarget);
			for( int client = 1; client <= MaxClients; client++ ) 
			{
				if(IsValidClient(client))
				{
					if(GetTeam(client)== TFTeam_Red)
					{
						SetGlobalTransTarget(client);
						CPrintToChat(client,"%t", "Pickup Gift Hero", NameOfTheHero);
						static InvGiftItem item;
						int rand = GetURandomInt();
						int length = GiftItems.Length;
						int[] items = new int[length];
						for(int r = IRarity; r >= 0; r--)
						{
							int maxitems;
							for(int i; i < length; i++)
							{
								GiftItems.GetArray(i, item);
								if(item.Rarity == r)
								{
									items[maxitems++] = i;
								}
							}

							int start = (rand % maxitems);
							int i = start;
							do
							{
								i++;
								if(i >= maxitems)
								{
									i = -1;
									continue;
								}

								if(Items_GiveIdItem(client, items[i]))	// Gives item, returns true if newly obtained, false if they already have
								{
									static const char Colors[][] = { "default", "green", "blue", "yellow", "darkred" };
									GiftItems.GetArray(items[i], item);
									CPrintToChat(client, "%t {%s}\"%t\"{snow}!", "Pickup Inventory Gift", Colors[r], item.Name);
									/*CPrintToChat(client, "%t", "Pickup Inventory Gift");
									CPrintToChat(client, "{%s}\"%t\"", Colors[r], item.Name);*/
									r = -1;
									length = 0;
									break;
								}
							}
							while(i != start);
						}
						
						if(length)
						{
							int MultiExtra = 1;
							switch(Rarity)
							{
								case Common:
									MultiExtra = 1;
								case Uncommon:
									MultiExtra = 2;
								case Rare:
									MultiExtra = 5;
								case Legend:
									MultiExtra = 10;
								case Mythic:
									MultiExtra = 40;
							}
							//xp to give?
							int TempCalc = Level[client];
							if(TempCalc >= 101) //fix shitty rounding to 995 xp to 1000 xp
								TempCalc = 101;

							TempCalc = LevelToXp(TempCalc) - LevelToXp(TempCalc - 1);
							TempCalc /= 40;

							int XpToGive = TempCalc * MultiExtra;
							CPrintToChat(client,"%t", "Pickup XP Gift", XpToGive);
							XP[client] += XpToGive;
							Native_ZR_OnGetXP(client, XpToGive, 0);
							GiveXP(client, 0);
						}
					}
				}
			}
			Native_ZR_OnGiftCollected(ClosestTarget, Rarity);
			if(IsValidEntity(glow))
				RemoveEntity(glow);
			RemoveEntity(entity);
			return Plugin_Stop;		
		}
		if(DoJump)
		{
			if(ClosestTarget > 0 && TargetDistance <= (500.0 * 500.0)) GiftJumpAwayYou(entity, ClosestTarget);
			else if(ClosestTarget > 0 && TargetDistance >= (1000.0 * 1000.0)) {GiftJumpTowardsYou(entity, ClosestTarget); f_RingDelayGift[entity] += 1.0;}
		}
	}
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

stock bool Stock_SpawnInvGift(float position[3], const char[] model, float lifetime, ZRGiftRarity rarity)
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
		
		//i_RarityType[m_iGift] = rarity;
		
		int glow = TF2_CreateGlow(m_iGift);
		
		int color[4];
		int ColorGiveRarity = view_as<int>(rarity);
		color[0] = RenderColors_RPG[ColorGiveRarity][0];
		color[1] = RenderColors_RPG[ColorGiveRarity][1];
		color[2] = RenderColors_RPG[ColorGiveRarity][2];
		color[3] = RenderColors_RPG[ColorGiveRarity][3];
		
		SetVariantColor(view_as<int>(color));
		AcceptEntityInput(glow, "SetGlowColor");
		
		f_RingDelayGift[m_iGift] = 0.0;

		DataPack pack;
		CreateDataTimer(0.1, Timer_Detect_Player_Near_InvGift, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		pack.WriteCell(EntIndexToEntRef(m_iGift));
		pack.WriteCell(EntIndexToEntRef(glow));	
		pack.WriteCell(rarity);

		/*DataPack pack;
		CreateDataTimer(0.1, Timer_Detect_Player_Near_InvGift, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		pack.WriteCell(EntIndexToEntRef(m_iGift));
		pack.WriteCell(EntIndexToEntRef(glow));	
		pack.WriteCell(GetClientUserId(client));
		pack.WriteCell(rarity);*/
		
		DataPack pack_2;
		CreateDataTimer(lifetime, Timer_Despawn_Gift, pack_2, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		pack_2.WriteCell(EntIndexToEntRef(m_iGift));
		pack_2.WriteCell(EntIndexToEntRef(glow));	
		
		//SDKHook(m_iGift, SDKHook_SetTransmit, GiftTransmit);
		return true;
	}
	return false;
}

//This is probably the silliest thing ever.
static void GiftJumpTowardsYou(int Gift, int client)
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
	float flJumpSpeed = 400.0;
	float flMaxSpeed = 300.0;
	if ( flJumpSpeed > flMaxSpeed )
	{
		vecJumpVel[0] *= flMaxSpeed / flJumpSpeed;
		vecJumpVel[1] *= flMaxSpeed / flJumpSpeed;
		vecJumpVel[2] *= flMaxSpeed / flJumpSpeed;
	}
	TeleportEntity(Gift, NULL_VECTOR, NULL_VECTOR, vecJumpVel);
}